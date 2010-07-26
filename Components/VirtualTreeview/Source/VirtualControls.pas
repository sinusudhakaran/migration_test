unit VirtualControls;

//----------------------------------------------------------------------------------------------------------------------
//
// Copyright © 1995-2001 digital publishing AG
//
//----------------------------------------------------------------------------------------------------------------------
//
// Description:
//   This unit implements extented controls which can hold a virtually unlimited number of entries. These controls do
//   not keep their items internally but query the application whenever necessary.
//
//----------------------------------------------------------------------------------------------------------------------
//
// 09-JAN-2002 fe:
//   - vcoMultiSelection is now really check support
//   - various missing properties now published
//   - TBaseVirtualComboBox.WMNCHitTest was completely wrong (position is in screen coords!)
// 07-DEC-2001 ml:
//   - combobox selection rect fills now entire client area if nothing is selected
// 16-NOV-2001 fe:
//   - WMSizing handler added for popup tree to set cbsResizedOnce instead of DroppedDown
// 06-NOV-2001 ml:
//   - change propagation from popup tree to owner
//   - change handling more compliant to standard combobox
//   - bug fixes
// 05-NOV-2001 ml:
//   - images in list mode
//   - fixed size grip painting in tree popup
//   - minimum size constraint removed (handled by GetDropDownRect)
//   - nc painting improved
// 02-NOV-2001 ml:
//   - painting at design time
// 31-OCT-2001 ml:
//   - correct button hit test (combobox)
//   - ESC handling for combobox
//   - bug fixes
// 29-OCT-2001 ml:
//   - combobox painting (also themed)
//   - combobox sizing
//   - hover/leave for themed combobox window
// 24-OCT-2001 ml:
//   - cleaning up
// 14-SEP-2001 ml:
//   - add JclSysInfo unit to access windows versions
//   - small changes due to renamed event
// 05-SEP-2001 ml:
//   - bug fixes
// 24-AUG-2001 ml:
//   - Delphi 6 compatibility
// 13..14-AUG-2001 ml:
//   - resizing of tree pop up in the combobox with single line border
// 20-JUN-20001 fe:
//   - changes in TBaseVirtualComboBox.CreateParams to avoid doubled border (WS_EX_CLIENTEDGE or WS_BORDER, not both!)
//   - minor changes to DrawEdge parameters to be compatible with regular combo box
//   - SetFocus call on WM_NCLBUTTONDOWN or WM_LBUTTONDOWN
// 02-MAY-2001 ml:
//   - published NodeDataSize, FocusedNode for TreePopup
// 27-APR-2001 ml:
//   - CM_MOUSEBUTTONDOWN in combo box
// 26-APR-2001 ml:
//   - redraw of loosing focus for combo box
// 25-APR-2001 ml:
//   - popup window size fix
//   - initial popup tree visibility fix
// 18-APR-2001 ml:
//   - took further measures to ensure tree popup's initial invisibility
// 02-APR-2001 ml:
//   - tree combo non-client painting
//   - tree combo restructuring (looks now like a normal combo box)
// 30-MAR-2001 ml:
//   - published some more properties and events for the tree combo box
// 06-MAR-2001 ml:
//   - removed NC painting for the Virtual Listbox
//   - bug fixes
// 28-FEB-2001 ml:
//   - popup window handling
//   - key forwarding
//   - intl chars handling
//   - bug fixes
// 23-FEB-2001 ml:
//   - auto update
//   - auto selection
//   - edit handling
//   - bug fixes
// 21..22-FEB-2001 ml:
//   - popup window handling
//   - MultiSelection
//   - base painting and parsing
//   - bu fixes
// 20-FEB-2001 ml:
//   - made the popup treeview visible in object inspector and persistent for direct design time manipulations
//   - wide editor control is used now
//   - bug fixes
// 19-FEB-2001 ml:
//   - removed old virtual combo box because the tree combo box will now take this part
//   - bug fixes
//   - clean up work
// 05-FEB-2001 ml:
//   - adjusted more properties to fit to the changed VT types and properties
//   - bug fixes
// SEP-2000 through JAN-2001
//   - preparation work for tree combo box (base class and handling)
//   - bug fixes
// AUG-98 through OCT-99
//   - TCustomVirtualTreeComboBox and TVirtualTreeComboBox introduction
//   - mouse wheel support for all controls
//   - TVirtualComboBox (general)
//   - TVirtualListBox (general, item cache)
//   - initial version
//----------------------------------------------------------------------------------------------------------------------

interface

uses
  Windows, Graphics, Classes, Controls, ImgList, Messages, StdCtrls, Forms, ExtCtrls, VirtualTrees, EditorW2,
  DPMessages,                                                               
  JwaUxTheme, JwaTmSchema;

type
  TCustomVirtualListBox = class;

  TVirtualListBoxStyle = (
    vlbStandard,
    vlbOwnerDraw
  );

  TDefaultScrollBarMode = (
    sbmRegular,
    sbmFlat,
    sbm3D
  );

  TVLBChangeEvent = procedure(Sender: TObject; Index: Integer; ItemSelected: Boolean) of object;
  TVLBDrawItemEvent = procedure(Sender: TObject; Canvas: TCanvas; Index: Integer; Rect: TRect; Selected,
    Focused: Boolean) of object;
  TVirtualGetItemEvent = procedure(Sender: TObject; Index: Integer; var Text: WideString) of object;
  TVirtualGetImageEvent = procedure(Sender: TObject; Index: Integer; var ImageIndex: Integer) of object;
  TVirtualCompareEvent = procedure(Sender: TObject; Text1, Text2: WideString; var Result: Integer) of object;

  TCustomVirtualListBox = class(TCustomControl)
  private
    FScrollBar: TScrollBar;
    FUseExternScrollBar: Boolean;
    FItemHeight: Integer;
    FItemWidth: Integer;                // Width / Width-ScrollBar.Left
    FLinesInWindow: Integer;            // Set: ItemHeight, SetBounds
    FAutoScroll: Boolean;               // False für Bitmap-Hintergrund
    FStyle: TVirtualListBoxStyle;
    FIntegralHeight: Boolean;
    FMultiSelect: Boolean;
    FExtendedSelect: Boolean;
    FExtSelectionAnchor,
    FTopIndex: Integer;
    FItemIndex: Integer;
    FItemCount: Integer;
    FSelCount: Integer;
    FSelection: Pointer;
    FEraseBkGnd: Boolean;
    FDefaultScrollBarMode: TDefaultScrollBarMode;
    FScrollBarWidth: Integer;
    FScrollFactor: Single;
    FImages: TImageList;
    FScrollTimer: TTimer;
    FChangeTimer: TTimer;
    FLastChangedIndex: Integer;
    FLastChangedItemSelected: Boolean;
    FCacheIndex: Integer;
    FCache: TStringList;
    FBorderStyle: TBorderStyle;
    FFreezeScroll: Boolean;
    FChangeDelay: Integer;              // use to delay OnChange event

    FOnChange: TVLBChangeEvent;
    FOnDrawItem: TVLBDrawItemEvent;
    FOnGetItem: TVirtualGetItemEvent;
    FOnGetImage: TVirtualGetImageEvent;
    FOnCompare: TVirtualCompareEvent;
    procedure CMFontChanged(var Msg: TMessage); message CM_FONTCHANGED;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CNKeyDown(var Msg: TWMKey); message CN_KEYDOWN;
    function GetSelected(Index: Integer): Boolean;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetCustomScrollBar(Value: TScrollbar);
    procedure SetDefaultScrollBarMode(Value: TDefaultScrollBarMode);
    procedure SetImages(Value: TImageList);
    procedure SetIntegralHeight(Value: Boolean);
    procedure SetItemCount(Value: Integer);
    procedure SetItemHeight(Value: Integer);
    procedure SetItemIndex(Value: Integer);
    procedure SetMultiSelect(Value: Boolean);
    procedure SetSelected(Index: Integer; Value: Boolean);
    procedure SetStyle(Value: TVirtualListBoxStyle);
    procedure SetTopIndex(Value: Integer);
    procedure SetScrollBar;
    procedure SetScrollBarWidth(Value: Integer);
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseMove(var Msg: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMVScroll(var Msg: TWMVScroll); message WM_VSCROLL;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure ClearSelection;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoChange(Index: Integer; ItemSelected: Boolean);
    procedure FillCache(NeededIndex: Integer); virtual;
    function GetItem(Index: Integer): WideString;
    procedure InvalidateBox(All: Boolean);
    procedure InvalidateItem(Index: Integer);
    procedure InvalidateToBottom(Index: Integer);
    procedure MoveSelects(StartIndex, Direction: Integer);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure OnScrollTimer(Sender: TObject);
    procedure OnChangeTimer(Sender: TObject);
    procedure ScrollBarChange(Sender: TObject);
    procedure ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);
    procedure SelectItem(Index: Integer; Value: Boolean);
    procedure SelectRange(Start, Stop: Integer);
    procedure ToggleItem(Index: Integer);

    // scroll bar handling
    function GetScrollBarPosition: Integer;
    procedure SetScrollBarMin(Value: Integer);
    procedure SetScrollBarMax(Value: Integer);
    procedure SetScrollBarPosition(Value: Integer);
    procedure SetScrollBarLargeChange(Value: Integer);
    procedure SetScrollBarSmallChange(Value: Integer);

    procedure Paint; override;

    property AutoScroll: Boolean read FAutoScroll write FAutoScroll default True;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property ChangeDelay: Integer read FChangeDelay write FChangeDelay;
    property DefaultScrollBarMode: TDefaultScrollBarMode read FDefaultScrollBarMode write SetDefaultScrollBarMode
      default sbmRegular;
    property ExtendedSelect: Boolean read FExtendedSelect write FExtendedSelect default True;
    property EraseBkGnd: Boolean read FEraseBkGnd write FEraseBkGnd default True;
    property Images: TImageList read FImages write SetImages;
    property IntegralHeight: Boolean read FIntegralHeight write SetIntegralHeight default False;
    property ItemCount: Integer read FItemCount write SetItemCount default 0;
    property ItemHeight: Integer read FItemHeight write SetItemHeight default 16;
    property ItemIndex: Integer read FItemIndex write SetItemIndex default -1;
    property MultiSelect: Boolean read FMultiSelect write SetMultiSelect default False;
    property ParentColor default False;
    property ScrollBarWidth: Integer read FScrollBarWidth write SetScrollBarWidth default 13;
    property Style: TVirtualListBoxStyle read FStyle write SetStyle default vlbStandard;

    property OnChange: TVLBChangeEvent read FOnChange write FOnChange;
    property OnCompare: TVirtualCompareEvent read FOnCompare write FOnCompare;
    property OnDrawItem: TVLBDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnGetImage: TVirtualGetImageEvent read FOnGetImage write FOnGetImage;
    property OnGetItem: TVirtualGetItemEvent read FOngetItem write FOnGetItem;
  public
    constructor Create(AOwner: TComponent); overload; override;
    constructor Create(AOwner: TComponent; AsPopup: Boolean = False); reintroduce; overload;
    destructor Destroy; override;

    procedure Clear;
    function Find(Text: WideString): Boolean;
    procedure InvalidateCache;
    function ItemAtPos(Pos: TSmallPoint; Existing: Boolean): Integer;
    function ItemRect(Index: Integer): TRect;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure WndProc(var Message: TMessage); override;

    property FreezeScroll: Boolean read FFreezeScroll write FFreezeScroll;
    property TopIndex: Integer read FTopIndex write SetTopIndex;
    property CustomScrollBar: TScrollBar read FScrollBar write SetCustomScrollBar;
    property Items[Index: Integer]: WideString read GetItem; default;
    property SelectedCount: Integer read FSelCount;
    property Selected[Index: Integer]: Boolean read GetSelected write SetSelected;
  end;

  TVirtualListBox = class(TCustomVirtualListBox)
  published
    property Align;
    property Anchors;
    property AutoScroll;
    property BevelEdges;
    property BevelInner;
    property BevelOuter;
    property BevelKind;
    property BevelWidth;
    property BorderStyle;
    property Color;
    property Constraints;
    property DefaultScrollBarMode;
    property DragCursor;
    property DragMode;
    property Enabled;
    property EraseBkGnd;
    property ExtendedSelect;
    property Font;
    property Images;
    property IntegralHeight;
    property ItemCount;
    property ItemHeight;
    property ItemIndex;
    property MultiSelect;
    property ParentColor default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBarWidth;
    property ShowHint;
    property Style;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property ChangeDelay;

    property OnChange;
    property OnClick;
    property OnCompare;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnDrawItem;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetImage;
    property OnGetItem;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
  end;

  TVirtualComboboxOption = (
    vcoAutoSelect,     // Changes in the edit are directly reflected in the tree.
    vcoAutoUpdate,     // Update text property for every selection/check change in the treeview.
    vcoHotTrack,       // Selection in popup tree follows the mouse pointer.
    vcoMultiSelection  // Allows several items to be selected (actually check boxes are used).
  );
  TVirtualComboboxOptions = set of TVirtualComboboxOption;

const
  DefaultVirtualComboBoxOptions = [];

type
  TBaseVirtualCombobox = class;
  TCustomVirtualTreeComboBox = class;
  
  TWideVCBEdit = class(TWideEditorControl)
  private
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDblClk(var Message: TWMLButtonDblClk); message WM_LBUTTONDBLCLK;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSysKeyDown(var Message: TWMSysKeydown); message WM_SYSKEYDOWN;
    procedure CMWantSpecialKey(var Msg: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  protected
    procedure DoChange; override;
  end;

  TVirtualComboboxStyle = (
    vcsDropDown,
    vcsDropDownList
  );

  TVirtualComboboxState = (
    cbsAutoSelecting,
    cbsCreating,
    cbsDroppedDown,
    cbsResizedOnce,
    cbsModified
  );
  TVirtualComboboxStates = set of TVirtualComboboxState;

  // State of the combo box button depending on enabled state of the control the mouse state.
  TVCButtonState = (
    vbsNormal,
    vbsHot,
    vbsPressed,
    vbsDisabled
  );

  TEditDoubleClickEvent = procedure(Sender: TBaseVirtualCombobox; Shift: TShiftState; Pos: TPoint) of object;

  TBaseVirtualComboBox = class(TCustomControl)
  private
    FOptions: TVirtualComboboxOptions;
    FEditWindow: TWideVCBEdit;
    FMaxLength: Integer;
    FStyle: TVirtualComboboxStyle;
    FStates: TVirtualComboboxStates;
    FButtonState: TVCButtonState;
    FText,                             // normal combobox text
    FIntlChars: WideString;
    FTextHeight: Integer;
    FAlignment: TAlignment;
    FLayout: TTextLayout;
    FBorderStyle: TBorderStyle;
    FDropDownCount: Cardinal;
    FComboTheme,
    FEditTheme: HTHEME;
    FAnimationDuration: Cardinal;                // specifies how long an animation shall take (drop down)

    FOnChange: TNotifyEvent;
    FOnDropDown: TNotifyEvent;
    FOnEditDoubleClick: TEditDoubleClickEvent;
    procedure CloseThemes;
    procedure EndAutoSelecting;
    function GetAutoSelecting: Boolean;
    function GetDroppedDown: Boolean;
    function GetModified: Boolean;
    procedure ReadIntlChars(Reader: TReader);
    procedure ReadText(Reader: TReader);
    procedure SetAlignment(const Value: TAlignment);
    procedure SetAnimationDuration(const Value: Cardinal);
    procedure SetBorderStyle(const Value: TBorderStyle);
    procedure SetDroppedDown(Value: Boolean);
    procedure SetIntlChars(const Value: WideString);
    procedure SetLayout(const Value: TTextLayout);
    procedure SetModified(Value: Boolean);
    procedure SetOptions(Value: TVirtualComboboxOptions);
    procedure SetSelText(const Value: WideString);
    procedure SetStyle(Value: TVirtualComboboxStyle);
    procedure StartAutoSelecting;
    procedure WriteIntlChars(Writer: TWriter);
    procedure WriteText(Writer: TWriter);

    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKeyUp(var Message: TWMKeyUp); message WM_KEYUP;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMMouseLeave(var Message: TMessage); message WM_MOUSELEAVE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCLButtonDblClk(var Message: TWMNCLButtonDblClk); message WM_NCLBUTTONDBLCLK;
    procedure WMNCLButtonDown(var Message: TWMNCLButtonDown); message WM_NCLBUTTONDOWN;
    procedure WMNCMouseLeave(var Message: TMessage); message WM_NCMOUSELEAVE;
    procedure WMNCMouseMove(var Message: TWMNCMouseMove); message WM_NCMOUSEMOVE;
    procedure WMNCPaint(var Message: TRealWMNCPaint); message WM_NCPAINT;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMThemeChanged(var Message: TMessage); message WM_THEMECHANGED;
  protected
    procedure Changed; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DestroyWnd; override;
    procedure DoSetDroppedDown(Value: Boolean); virtual;
    function Editable: Boolean; virtual;
    procedure EditDoubleClick(var Message: TWMLButtonDblClk);
    function FindItem(const ItemText: WideString): Boolean; virtual;
    function GetPopupWindow: HWND; virtual;
    function GetSelLength: Integer; virtual;
    function GetSelStart: Integer; virtual;
    function GetSelText: WideString; virtual;
    function GetTextRect: TRect; virtual;
    procedure OptionsChanged; virtual;
    procedure RegisterLeaveEvent(IsClientArea: Boolean);
    procedure RepaintWindow(R: PRect = nil);
    procedure SetSelLength(Value: Integer); virtual;
    procedure SetSelStart(Value: Integer); virtual;
    procedure SetText(const Value: WideString); virtual;
    procedure WndProc(var Message: TMessage); override;

    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property AnimationDuration: Cardinal read FAnimationDuration write SetAnimationDuration default 200;
    property AutoSelecting: Boolean read GetAutoSelecting;
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsSingle;
    property Color default clWindow;
    property DropDownCount: Cardinal read FDropDownCount write FDropDownCount default 8;
    property DroppedDown: Boolean read GetDroppedDown write SetDroppedDown;
    property InternationalCharacters: WideString read FIntlChars write SetIntlChars stored False;
    property Layout: TTextLayout read FLayout write SetLayout default tlTop;
    property Modified: Boolean read GetModified write SetModified;
    property Options: TVirtualComboboxOptions read FOptions write SetOptions default DefaultVirtualComboBoxOptions;
    property ParentColor default False;
    property Style: TVirtualComboboxStyle read FStyle write SetStyle default vcsDropDown;
    property Text: WideString read FText write SetText stored False; // We use own storage methods.

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnEditDoubleClick: TEditDoubleClickEvent read FOnEditDoubleClick write FOnEditDoubleClick;
  public
    constructor Create(AOwner: TComponent); override;

    procedure Clear; virtual;
    procedure ClearSelection;
    procedure CopyToClipBoard;
    procedure CutToClipBoard;
    function GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer; virtual;
    procedure Paint; override;
    procedure PasteFromClipboard;
    procedure SelectAll;
    procedure SetSelTextBuf(Buffer: PChar);

    property PopupWindow: HWND read GetPopupWindow;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelText: WideString read GetSelText write SetSelText;
  end;

  // These message records are not declared in D5 and lower.
  TWMSizing = packed record
    Msg: Cardinal;
    fwSide: Integer;
    lprc: PRect;
    Result: Integer;
  end;

  TWMCaptureChanged = packed record
    Msg: Cardinal;
    wParam: Integer;
    hwndNewCapture: HWND;
    Result: Integer;
  end;

  TTreePopup = class(TCustomVirtualStringTree)
  private
    FScrollTheme: HTHEME;    // used for the size gripper
    FPopupAbove: Boolean;    // keep the popup position for hit tests

    procedure CloseTheme;
    function GetOptions: TStringTreeOptions;
    function GetOwner: TCustomVirtualTreeComboBox; reintroduce;
    procedure SetOptions(const Value: TStringTreeOptions);

    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure WMExitSizeMove(var Message: TMessage); message WM_EXITSIZEMOVE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMLButtonUp(var Message: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMMouseActivate(var Message: TWMMouseActivate); message WM_MOUSEACTIVATE;
    procedure WMMouseMove(var Message: TWMMouseMove); message WM_MOUSEMOVE;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCPaint(var Message: TRealWMNCPaint); message WM_NCPAINT;
    procedure WMSetCursor(var Message: TWMSetCursor); message WM_SETCURSOR;
    procedure WMSizing(var Message: TMessage); message WM_SIZING;
    procedure WMThemeChanged(var Message: TMessage); message WM_THEMECHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoChecked(Node: PVirtualNode); override;
    procedure DoChange(Node: PVirtualNode); override;
    procedure DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates); override;
    procedure DoHotChange(Old, New: PVirtualNode); override;
    function GetOptionsClass: TTreeOptionsClass; override;

    property Owner: TCustomVirtualTreeComboBox read GetOwner;
  public
    constructor Create(AOwner: TComponent); override;

    property Canvas;
    property FocusedNode;
  published
    property Alignment;
    property AutoScrollDelay;
    property AutoScrollInterval;
    property Background;
    property BiDiMode;
    property CheckImageKind;
    property Color;
    property Colors;
    property Constraints;
    property CustomCheckImages;
    property DefaultNodeHeight;
    property EditDelay;
    property Font;
    property Header;
    property HintAnimation;
    property HintMode;
    property HotCursor;
    property Indent;
    property Margin;
    property NodeDataSize;
    property TreeOptions: TStringTreeOptions read GetOptions write SetOptions;
    property TextMargin;
    property ParentBiDiMode;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RootNodeCount;
    property ShowHint;
    property StateImages;
  end;

  TCustomVirtualTreeComboBox = class(TBaseVirtualComboBox)
  private
    FNodes: TNodeArray;
    FTreePopup: TTreePopup;
    FImages: TImageList;
    FImageChangeLink: TChangeLink;     // connections to the image list to get notified about changes
    FSeparator: WideChar;
    FPaintNode: PVirtualNode;          // Helper for painting.

    procedure CompareCaptions(Sender: TBaseVirtualTree; Node: PVirtualNode; Caption: Pointer; var Abort: Boolean);
    procedure CompareCaptionsPartial(Sender: TBaseVirtualTree; Node: PVirtualNode; Caption: Pointer;
      var Abort: Boolean);
    procedure DoNodeChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; Caption: Pointer; var Abort: Boolean);
    function GetDropDownRect(var R: TRect): Boolean;
    function GetOnAfterCellPaint: TVTAfterCellPaintEvent;
    function GetOnAfterItemErase: TVTAfterItemEraseEvent;
    function GetOnAfterItemPaint: TVTAfterItemPaintEvent;
    function GetOnAfterPaint: TVTPaintEvent;
    function GetOnBeforeCellPaint: TVTBeforeCellPaintEvent;
    function GetOnBeforeItemErase: TVTBeforeItemEraseEvent;
    function GetOnBeforeItemPaint: TVTBeforeItemPaintEvent;
    function GetOnBeforePaint: TVTPaintEvent;
    function GetOnChecked: TVTChangeEvent;
    function GetOnChecking: TVTCheckChangingEvent;
    function GetOnCollapsed: TVTChangeEvent;
    function GetOnCollapsing: TVTChangingEvent;
    function GetOnColumnResize: TVTHeaderNotifyEvent;
    function GetOnHeaderDraw: TVTHeaderPaintEvent;
    function GetOnExpanded: TVTChangeEvent;
    function GetOnExpanding: TVTChangingEvent;
    function GetOnFreeNode: TVTFreeNodeEvent;
    function GetOnGetHint: TVSTGetTextEvent;
    function GetOnGetImageIndex: TVTGetImageEvent;
    function GetOnGetNodeDataSize: TVTGetNodeDataSizeEvent;
    function GetOnGetText: TVSTGetTextEvent;
    function GetOnPaintText: TVTPaintText;
    function GetOnHeaderClick: TVTHeaderClickEvent;
    function GetOnInitChildren: TVTInitChildrenEvent;
    function GetOnInitNode: TVTInitNodeEvent;
    procedure ReadSeparator(Reader: TReader);
    procedure ReadTree(Stream: TStream);
    procedure SetImages(const Value: TImageList);
    procedure SetOnAfterCellPaint(const Value: TVTAfterCellPaintEvent);
    procedure SetOnAfterItemErase(const Value: TVTAfterItemEraseEvent);
    procedure SetOnAfterItemPaint(const Value: TVTAfterItemPaintEvent);
    procedure SetOnAfterPaint(const Value: TVTPaintEvent);
    procedure SetOnBeforeCellPaint(const Value: TVTBeforeCellPaintEvent);
    procedure SetOnBeforeItemErase(const Value: TVTBeforeItemEraseEvent);
    procedure SetOnBeforeItemPaint(const Value: TVTBeforeItemPaintEvent);
    procedure SetOnBeforePaint(const Value: TVTPaintEvent);
    procedure SetOnChecked(Value: TVTChangeEvent);
    procedure SetOnChecking(Value: TVTCheckChangingEvent);
    procedure SetOnCollapsed(Value: TVTChangeEvent);
    procedure SetOnCollapsing(Value: TVTChangingEvent);
    procedure SetOnColumnResize(Value: TVTHeaderNotifyEvent);
    procedure SetOnExpanded(Value: TVTChangeEvent);
    procedure SetOnExpanding(Value: TVTChangingEvent);
    procedure SetOnFreeNode(Value: TVTFreeNodeEvent);
    procedure SetOnGetHint(Value: TVSTGetTextEvent);
    procedure SetOnGetImageIndex(Value: TVTGetImageEvent);
    procedure SetOnGetNodeDataSize(Value: TVTGetNodeDataSizeEvent);
    procedure SetOnGetText(Value: TVSTGetTextEvent);
    procedure SetOnPaintText(const Value: TVTPaintText);
    procedure SetOnHeaderClick(Value: TVTHeaderClickEvent);
    procedure SetOnHeaderDraw(Value: TVTHeaderPaintEvent);
    procedure SetOnInitChildren(Value: TVTInitChildrenEvent);
    procedure SetOnInitNode(Value: TVTInitNodeEvent);
    procedure SetSeparator(const Value: WideChar);
    procedure SetTree(const Value: TTreePopup);
    procedure WriteSeparator(Writer: TWriter);
    procedure WriteTree(Stream: TStream);

    procedure CMCancelMode(var Message: TCMCancelMode); message CM_CANCELMODE;
    procedure CMMouseWheel(var Message: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    function ApplicationMessageHook(var Msg: TMessage): Boolean;
    procedure DefineProperties(Filer: TFiler); override;
    procedure DoSetDroppedDown(Value: Boolean); override;
    function GetPopupWindow: HWND; override;
    function GetTextRect: TRect; override;
    procedure ImageListChange(Sender: TObject);
    procedure OptionsChanged; override;
    procedure ParseText;
    procedure ParseTree;
    function BuildTextFromTree: WideString;
    procedure SetText(const Value: WideString); override;

    property Images: TImageList read FImages write SetImages;
    property Separator: WideChar read FSeparator write SetSeparator default ',';
    property TreePopup: TTreePopup read FTreePopup write SetTree stored False;

    property OnAfterCellPaint: TVTAfterCellPaintEvent read GetOnAfterCellPaint write SetOnAfterCellPaint;
    property OnAfterItemErase: TVTAfterItemEraseEvent read GetOnAfterItemErase write SetOnAfterItemErase;
    property OnAfterItemPaint: TVTAfterItemPaintEvent read GetOnAfterItemPaint write SetOnAfterItemPaint;
    property OnAfterPaint: TVTPaintEvent read GetOnAfterPaint write SetOnAfterPaint;
    property OnBeforeCellPaint: TVTBeforeCellPaintEvent read GetOnBeforeCellPaint write SetOnBeforeCellPaint;
    property OnBeforeItemErase: TVTBeforeItemEraseEvent read GetOnBeforeItemErase write SetOnBeforeItemErase;
    property OnBeforeItemPaint: TVTBeforeItemPaintEvent read GetOnBeforeItemPaint write SetOnBeforeItemPaint;
    property OnBeforePaint: TVTPaintEvent read GetOnBeforePaint write SetOnBeforePaint;
    property OnChecked: TVTChangeEvent read GetOnChecked write SetOnChecked;
    property OnChecking: TVTCheckChangingEvent read GetOnChecking write SetOnChecking;
    property OnCollapsed: TVTChangeEvent read GetOnCollapsed write SetOnCollapsed;
    property OnCollapsing: TVTChangingEvent read GetOnCollapsing write SetOnCollapsing;
    property OnColumnResize: TVTHeaderNotifyEvent read GetOnColumnResize write SetOnColumnResize;
    property OnExpanded: TVTChangeEvent read GetOnExpanded write SetOnExpanded;
    property OnExpanding: TVTChangingEvent read GetOnExpanding write SetOnExpanding;
    property OnFreeNode: TVTFreeNodeEvent read GetOnFreeNode write SetOnFreeNode;
    property OnGetHint: TVSTGetTextEvent read GetOnGetHint write SetOnGetHint;
    property OnGetImageIndex: TVTGetImageEvent read GetOnGetImageIndex write SetOnGetImageIndex;
    property OnGetNodeDataSize: TVTGetNodeDataSizeEvent read GetOnGetNodeDataSize write SetOnGetNodeDataSize;
    property OnPaintText: TVTPaintText read GetOnPaintText write SetOnPaintText;
    property OnGetText: TVSTGetTextEvent read GetOnGetText write SetOnGetText;
    property OnHeaderClick: TVTHeaderClickEvent read GetOnHeaderClick write SetOnHeaderClick;
    property OnHeaderDraw: TVTHeaderPaintEvent read GetOnHeaderDraw write SetOnHeaderDraw;
    property OnInitChildren: TVTInitChildrenEvent read GetOnInitChildren write SetOnInitChildren;
    property OnInitNode: TVTInitNodeEvent read GetOnInitNode write SetOnInitNode;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Clear; override;
    procedure Paint; override;

    property DroppedDown;
    property Nodes: TNodeArray read FNodes;
  published
    property AnimationDuration;
    property TabStop default True;
  end;

  TVirtualTreeComboBox = class(TCustomVirtualTreeComboBox)
  public
    property Canvas;
  published
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Constraints;
    property Ctl3D;
    property DragCursor;
    property DragKind;
    property DragMode;
    property DropDownCount;
    property Enabled;
    property Font;
    property Images;
    property ImeMode;
    property ImeName;
    property InternationalCharacters;
    property Layout;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Separator;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property TreePopup;
    property Text;
    property Style;
    property Visible;

    property OnChange;
    property OnChecked;
    property OnChecking;
    property OnClick;
    property OnCollapsed;
    property OnCollapsing;
    property OnColumnResize;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnHeaderDraw;
    property OnDropDown;
    property OnEditDoubleClick;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnExpanded;
    property OnExpanding;
    property OnFreeNode;
    property OnGetHint;
    property OnGetImageIndex;
    property OnGetNodeDataSize;
    property OnGetText;
    property OnHeaderClick;
    property OnInitChildren;
    property OnInitNode;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaintText;
    property OnStartDock;
    property OnStartDrag;
  end;

  TVirtualStringGrid = class(TCustomVirtualStringTree)
  end;

  TVirtualDrawGrid = class(TCustomVirtualDrawTree)
  end;

//----------------------------------------------------------------------------------------------------------------------

implementation

uses
  CommCtrl, Menus, SysUtils, FlatSB, DPMisc, JclUnicode, JclSysInfo, Math;

var
  // Redeclaration as variable to prevent static binding.
  AnimateWindow: function(hWnd: HWND; dwTime: DWORD; dwFlags: DWORD): BOOL; stdcall;
  
//----------------------------------------------------------------------------------------------------------------------

type
  EVirtualListBoxError = class(Exception);

  TSelection = record
    StartPos,
    EndPos: Integer;
  end;

const
  ScrollBarProp: array[TDefaultScrollBarMode] of Integer = (
    FSB_REGULAR_MODE,
    FSB_FLAT_MODE,
    FSB_ENCARTA_MODE
  );

//----------------- Utility functions ----------------------------------------------------------------------------------


function GetSel(SelP: Pointer; Index: Integer): Boolean; assembler;

// tests the bit at index Index and returns True if set otherwise False

asm
              BT [EAX], EDX
              SETC AL
end;

//----------------------------------------------------------------------------------------------------------------------

function SetSel(SelP: Pointer; Index: Integer): Boolean; assembler;

// sets the bit at index Index and returns True if this was already set before

asm
              BTS [EAX], EDX
              SETC AL
end;

//----------------------------------------------------------------------------------------------------------------------

function ClearSel(SelP: Pointer; Index: Integer): Boolean; assembler;

// resets the bit at index Index and returns True if it was set before

asm
              BTR [EAX], EDX
              SETC AL
end;

//----------------------------------------------------------------------------------------------------------------------

function ToggleSel(SelP: Pointer; Index: Integer): Boolean; assembler;

// inverts the bit at index Index and returns True if it was set before

asm
              BTC [EAX], EDX
              SETC AL
end;

//----------------------------------------------------------------------------------------------------------------------

procedure ShowError(Sender: TObject; Error: WideString);

begin
  if Sender is TCustomVirtualListBox then
    raise EVirtualListBoxError.Create(Error)
  else
    raise Exception.Create(Error); 
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TCustomVirtualListBox.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);
  FDefaultScrollBarMode := sbmRegular;
  FBorderStyle := bsNone;
  TabStop := True;
  ParentColor := False;
  ControlStyle := [csFramed, csDoubleClicks, csClickEvents, csCaptureMouse, csReflector];
  FItemHeight := 16;
  FEraseBkGnd := True;
  FExtendedSelect := True;
  FAutoScroll := True;
  ItemCount := 0;
  FTopIndex := 0;
  FItemIndex := -1;
  FStyle := vlbStandard;
  FCacheIndex := -1;
  FCache := TStringList.Create;
  Width := 100;
  Height := 120;
  Ctl3D := True;
  FScrollbarWidth := GetSystemMetrics(SM_CXVSCROLL);
  FScrollFactor := 1;
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Enabled := False;
  FScrollTimer.OnTimer := OnScrollTimer;
  FChangeTimer := TTimer.Create(Self);
  FChangeTimer.Enabled := False;
  FChangeTimer.OnTimer := OnChangeTimer;
end;

//----------------------------------------------------------------------------------------------------------------------

constructor TCustomVirtualListBox.Create(AOwner: TComponent; AsPopup: Boolean);

begin
  inherited Create(AOwner);
  FBorderStyle := bsNone;
  TabStop := True;
  ParentColor := False;
  ControlStyle := [csFramed, csOpaque, csDoubleClicks, csClickEvents, csCaptureMouse, csReflector];
  FItemHeight := 16;
  FEraseBkGnd := True;
  FExtendedSelect := True;
  ItemCount := 0;
  FTopIndex := 0;
  FItemIndex := -1;
  FStyle := vlbStandard;
  FCacheIndex := -1;
  FCache := TStringList.Create;
  Width := 100;
  Height := 120;
  Ctl3D := True;
  FScrollbarWidth := GetSystemMetrics(SM_CXVSCROLL);
  FScrollFactor := 1;
  FScrollTimer := TTimer.Create(Self);
  FScrollTimer.Enabled := False;
  FScrollTimer.OnTimer := OnScrollTImer;
  FChangeTimer := TTimer.Create(Self);
  FChangeTimer.Enabled := False;
  FChangeTimer.OnTimer := OnChangeTimer;
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TCustomVirtualListBox.Destroy;

begin
  FCache.Free;
  FScrollTimer.Free;
  if Assigned(FSelection) then
    FreeMem(FSelection);
  inherited Destroy;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.Clear;

begin
  FExtSelectionAnchor := -1;
  FItemCount := 0;
  ClearSelection;
  if Assigned(FSelection) then
  begin
    FreeMem(FSelection);
    FSelection := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.ClearSelection;

begin
  if Assigned(FSelection) then
    ZeroMemory(FSelection, (FItemCount div 8) + 1);
  FSelCount := 0;
  if Parent <> nil then
    InvalidateBox(False);
  DoChange(-1, False);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetItemIndex(Value: Integer);

var
  InvRect: TRect;
  OldItemIndex: Integer;
  FullLinesInWindow: Integer;

begin
  if (FItemCount > 0) and ((FItemIndex <> Value) or ((Value <> -1) and not GetSel(FSelection, Value))) then
  begin
    if Value > FItemCount - 1 then
      Value := FItemCount - 1;
    if Value < 0 then
      Value := -1;

    InvRect := ItemRect(FItemIndex);
    InvalidateRect(Handle, @InvRect, False);

    OldItemIndex := FItemIndex;
    FItemIndex := Value;
    if not MultiSelect then
    begin
      SelectItem(OldItemIndex, False);
      SelectItem(FItemIndex, True);
      UpdateWindow(Handle);             { this is required for Win9x! }
    end;
    if Value < TopIndex then
      TopIndex := Value
    else
    begin
      FullLinesInWindow := Height div ItemHeight;
      if Value >= (TopIndex + FullLinesInWindow) then
        TopIndex := Value - FullLinesInWindow + 1;
    end;
    InvRect := ItemRect(FItemIndex);
    InvalidateRect(Handle, @InvRect, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetBorderStyle(Value: TBorderStyle);

begin
  if Value <> FBorderStyle then
  begin
    FBorderStyle := Value;
    RecreateWnd;
    if not FUseExternScrollBar then
      FlatSB_SetScrollProp(Handle, WSB_PROP_VSTYLE, ScrollBarProp[FDefaultScrollBarMode], True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetCustomScrollBar(Value: TScrollbar);

// for special scrollbars
// Note: (20-SEP-2000 ml) do not use external scrollbars any longer, support will not continue for further controls and
//       will be removed from existing controls.

begin
  FScrollbar := nil;

  if Assigned(Value) then
  begin
    FUseExternScrollBar := True;
    FScrollBar := Value;
    with FScrollBar do
    begin
      Parent := Self;
      Kind := sbVertical;
      OnChange := ScrollBarChange;
      OnScroll := ScrollBarScroll;
    end;
  end
  else
    FUseExternScrollBar := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetDefaultScrollBarMode(Value: TDefaultScrollBarMode);

begin
  if FDefaultScrollBarMode <> Value then
  begin
    FDefaultScrollBarMode := Value;
    if not FUseExternScrollBar then
      FlatSB_SetScrollProp(Handle, WSB_PROP_VSTYLE, ScrollBarProp[Value], True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetImages(Value: TImageList);

begin
  if FImages <> Value then
  begin
    FImages := Value;
    Refresh;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetIntegralHeight(Value: Boolean);

begin
  if Value <> FIntegralHeight then
  begin
    FIntegralHeight := Value;
    if Value then
      Height := (Height div FItemHeight) * FItemHeight // ok *** + 4
    else
      SetScrollBar;
    InvalidateBox(True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetItemCount(Value: Integer);

begin
  if FItemCount <> Value then
  begin
    FItemCount := Value;
    if Value = 0 then
      FItemIndex := -1
    else
      FItemIndex := 0;
    if FTopIndex > FItemCount then
      FTopIndex := 0;
    ReallocMem(FSelection, (FItemCount div 8) + 1);
    ZeroMemory(FSelection, (FItemCount div 8) + 1);
    FSelCount := 0;

    FCacheIndex := -1;                  // Anzeige für Cache neu füllen
    SetScrollBar;
    // Neuzeichnen nur, wenn sich in der Anzeige etwas geändert hat
    if FItemCount < (FTopIndex + FLinesInWindow) then
      Invalidate;
    DoChange(-1, False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetItemHeight(Value: Integer);

begin
  if (FItemHeight <> Value) and (Value > 0) then
  begin
    FItemHeight := Value;
    if IntegralHeight then
    begin
      FIntegralHeight := False;
      IntegralHeight := True;
    end;
    SetScrollBar;
    InvalidateBox(False);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.CMFontChanged(var Msg: TMessage);

var
  Size: TSize;

begin
  inherited;
  if Style = vlbStandard then
  begin
    Canvas.Font := Font;
    GetTextExtentPoint32(Canvas.Handle, 'A', 1, Size);
    FItemHeight := Size.CY;             // Font.Height does not work here

    if IntegralHeight then
    begin
      FIntegralHeight := False;
      IntegralHeight := True;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetMultiSelect(Value: Boolean);

begin
  if FMultiSelect <> Value then
  begin
    FMultiSelect := Value;
    if not Value then
      ClearSelection;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetStyle(Value: TVirtualListBoxStyle);

begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    InvalidateBox(True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.MoveSelects(StartIndex, Direction: Integer);

var
  I, MaxCount: Integer;

begin
  MaxCount := FItemCount - 1;
  if StartIndex < MaxCount then
    case Direction of
      1:
        for I := MaxCount downto StartIndex + 1 do
          if GetSel(FSelection, I - 1) then
            SetSel(FSelection, I)
          else
            ClearSel(FSelection, I);
      -1:
        for I := StartIndex to MaxCount do
          if GetSel(FSelection, I + 1) then
            SetSel(FSelection, I)
          else
            ClearSel(FSelection, I)

        else
          raise Exception.Create('MoveSelects, Direction <> + / -1');
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.GetSelected(Index: Integer): Boolean;

begin
  if (Index >= 0) and (Index < FItemCount) then
    Result := GetSel(FSelection, Index)
  else
    Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SelectItem(Index: Integer; Value: Boolean);

var
  InvRect: TRect;

begin
  if Value then
  begin
    if not SetSel(FSelection, Index) then
      Inc(FSelCount);
  end
  else
  begin
    if ClearSel(FSelection, Index) then
      Dec(FSelCount);
  end;

  InvRect := ItemRect(Index);
  InvalidateRect(Handle, @InvRect, False);
  DoChange(Index, Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SelectRange(Start, Stop: Integer);

// selektiert einen ganzen Bereich ohne Invalidierung des Clientareas

var
  Diff,
    StartByte,
    StopByte: Integer;

begin
  if Start = Stop then
    SelectItem(Start, True)
  else
  begin
    if Stop < Start then
    begin
      StartByte := Start;
      Start := Stop;
      Stop := StartByte;
    end;
    StartByte := (Start div 8);
    StopByte := (Stop div 8);
    Diff := StopByte - StartByte;

    if Diff = 0 then
      PByteArray(FSelection)[StartByte] := LOBYTE($FF shl (Start mod 8)) and ((1 shl ((Stop mod 8) + 1)) - 1)
    else
    begin
      // erstes Byte
      PByteArray(FSelection)[StartByte] := LOBYTE($FF shl (Start mod 8));
      Inc(StartByte);

      // Zwischenbytes komplett füllen
      if Diff >= 2 then
        FillChar(PByteArray(FSelection)[StartByte], Diff - 1, $FF);

      // letztes Byte
      PByteArray(FSelection)[StopByte] := (1 shl ((Stop mod 8) + 1)) - 1;
    end;
  end;
  DoChange(Stop, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetSelected(Index: Integer; Value: Boolean);

begin
  if not MultiSelect then
    if Name <> '' then
      ShowError(Self, Name + ': multi selection not enabled')
    else
      ShowError(Self, 'TCustomVirtualListBox: multi selection not enabled');

  if Index = -1 then                    // Spezialfall: Index = -1 wählt alles aus/ab
  begin
    if Value then
    begin
      FillChar(FSelection^, (FItemCount div 8) + 1, $FF);
      FSelCount := FItemCount;
    end
    else
      ClearSelection;
    InvalidateBox(False);
  end
  else
  begin
    if (Index < 0) or (Index > FItemCount) then
      ShowError(Self, 'List index out of bounds');
    SelectItem(Index, Value);
  end;
  DoChange(Index, Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetTopIndex(Value: Integer);

var
  PixelsToScroll: Integer;
  ClipScroll,
    InvRect: TRect;
  FullLinesInWindow: Integer;
begin
  FullLinesInWindow := Height div FItemHeight;
  if Value > (FItemCount - FullLinesInWindow) then
    Value := FItemCount - FullLinesInWindow;

  if Value < 0 then
    Value := 0;

  if FTopIndex <> Value then
  begin
    PixelsToScroll := (FTopIndex - Value) * FItemHeight;
    FTopIndex := Value;
    SetScrollBarPosition(Value);
    if (Abs(PixelsToScroll) >= Height) or not AutoScroll then
      InvalidateBox(False)
    else
    begin
      ClipScroll := Rect(0, 0, FItemWidth, FLinesInWindow * FItemHeight);
      ScrollDC(Canvas.Handle, 0, PixelsToScroll, ClipScroll, ClipScroll, 0, @InvRect);
      InvalidateRect(Handle, @InvRect, True);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.Find(Text: WideString): Boolean;

// looks for the given text and scrolls the control accordingly if there is an exact item hit so that the item is in view

  //--------------- local functions -------------------------------------------

  function CompareBinary(S1, S2: PWideChar): Integer;

  // binary WideString comparation

  var
    A, B: PWideChar;

  begin
    if Assigned(S1) and Assigned(S2) then
    begin
      A := S1;
      B := S2;
      // advance until an end is reached or there is an unequality
      while (A^ <> #0) and (B^ <> #0) and (Word(A^) = Word(B^)) do
      begin
        Inc(A);
        Inc(B);
      end;

      // set result depending on values we found
      if Word(A^) = Word(B^) then
        Result := 0
      else
        if (A^ = #0) or (Word(A^) < Word(B^)) then
          Result := -1
        else
          Result := 1;
    end
    else
      Result := 0;
  end;

  //--------------- end local functions ---------------------------------------

var
  L, H,
    I, C: Integer;

begin
  Result := False;
  L := 0;
  H := FItemCount - 1;
  if Assigned(FOnCompare) then
  begin
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := 0;
      try
        FOnCompare(Self, GetItem(I), Text, C);
      except
        Result := False;
        Exit;
      end;
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          Result := True;
          L := I;
        end;
      end;
    end
  end
  else
  begin
    while L <= H do
    begin
      I := (L + H) shr 1;
      C := CompareBinary(PWideChar(GetItem(I)), PWideChar(Text));
      if C < 0 then
        L := I + 1
      else
      begin
        H := I - 1;
        if C = 0 then
        begin
          Result := True;
          L := I;
        end;
      end;
    end;
  end;

  if L < FItemCount then
    ItemIndex := L;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.InvalidateCache;

begin
  // this will actually cause a new cache reread the next time the control is painted
  FCacheIndex := -1;
  Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.ItemAtPos(Pos: TSmallPoint; Existing: Boolean): Integer;

begin
  if PtInrect(ClientRect, SmallPointToPoint(Pos)) then
  begin
    Result := FTopIndex + Pos.Y div FItemHeight;
    if Result >= FItemCount then
      if Existing then
        Result := -1
      else
        Result := FItemCount - 1;
  end
  else
    Result := -1;                       // not in the window
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.ItemRect(Index: Integer): TRect;

begin
  if (Index >= FTopIndex) and (Index <= FTopIndex + FLinesInWindow) and
    (Index >= 0) and (Index < FItemCount) then
  begin
    Result := Rect(0, 0, FItemWidth, FItemHeight);
    OffsetRect(Result, 0, (Index - FTopIndex) * FItemHeight);
  end
  else
    // empty listbox
    if Index = 0 then
      Result := Rect(0, 0, FItemWidth, FItemHeight)
    else
      Result := Rect(0, 0, 0, 0);
end;

//--------------------------------------------------------------------------------

procedure TCustomVirtualListBox.CreateParams(var Params: TCreateParams);

begin
  inherited CreateParams(Params);
  with Params do
  begin
    Style := Style and not WS_VISIBLE and not WS_BORDER;
    if FBorderStyle = bsSingle then
    begin
      ControlStyle := ControlStyle - [csFramed];
      ExStyle := ExStyle or WS_EX_CLIENTEDGE;
    end
    else
      ControlStyle := ControlStyle + [csFramed];
    // tool window style, damit das Fenster nicht im Taskbar erscheint, wenn es
    // als Child window des Desktops verwendet wird (siehe Nutzung in TVirtualCustomComboBox)
    ExStyle := ExStyle or WS_EX_TOOLWINDOW;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.CreateWnd;

begin
  inherited CreateWnd;
  if not FUseExternScrollBar then
  begin
    InitializeFlatSB(Handle);
    FlatSB_SetScrollProp(Handle, WSB_PROP_VSTYLE, ScrollBarProp[FDefaultScrollBarMode], True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMSetFocus(var Msg: TWMSetFocus);

var
  YPos: Integer;
  InvRect: TRect;

begin
  inherited;
  if (FItemIndex >= FTopIndex) and (FItemIndex <= (FTopIndex + FLinesInWindow)) then
  begin
    YPos := (ItemIndex - TopIndex) * FItemHeight;
    if Style <> vlbStandard then
    begin
      InvRect := ItemRect(FItemIndex);
      InvalidateRect(Handle, @InvRect, True);
    end
    else
      DrawFocusRect(Canvas.Handle, Rect(0, YPos, FItemWidth, YPos + FItemHeight));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMSize(var Message: TWMSize);

begin
  inherited;
  FCacheIndex := -1;                    // cache needs refill
  SetScrollBar;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMKillFocus;

var
  InvRect: TRect;

begin
  inherited;

  InvRect := ItemRect(FItemIndex);
  InvalidateRect(Handle, @InvRect, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.FillCache(NeededIndex: Integer);

// füllt gegebenenfalls den internen Cache, je nach benötigtem Index
// wird nur aufgerufen, wenn ein Callback event des Anwenders existiert

var
  I: Integer;
  Result: WideString;

begin
  // Cache neu füllen?
  if (FCacheIndex = -1) or (NeededIndex < FCacheIndex) or
    ((NeededIndex > (FCacheIndex + FLinesInWindow)) and ((FCacheIndex + FLinesInWindow) < FItemCount)) then
  begin
    FCacheIndex := NeededIndex;
    FCache.Clear;
    for I := 0 to FLinesInWindow do
      if (FCacheIndex + I) < FItemCount then
      begin
        FOnGetItem(Self, FCacheIndex + I, Result);
        FCache.Add(Result);
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.GetItem(Index: Integer): WideString;

begin
  Result := '';
  if (Index > -1) and (Index < FItemCount) then
    if Assigned(FOnGetItem) then
    begin
      FillCache(Index);
      Result := FCache[Index - FCacheIndex];
    end
    else
      Result := IntToStr(Index);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.InvalidateBox(All: Boolean);

var
  InvRect: TRect;

begin
  if All then
    Invalidate
  else
  begin
    InvRect := Rect(0, 0, FItemWidth, Height);
    InvalidateRect(Handle, @InvRect, True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.InvalidateItem(Index: Integer);

var
  InvRect: TRect;

begin
  InvRect := ItemRect(Index);
  if not IsRectEmpty(InvRect) then
    InvalidateRect(Handle, @InvRect, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.InvalidateToBottom(Index: Integer);

// redraw window starting with item at Index

var
  InvRect: TRect;

begin
  InvRect := ItemRect(Index);
  if not IsRectEmpty(InvRect) then
  begin
    InvRect.Bottom := Height;
    InvalidateRect(Handle, @InvRect, True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarWidth(Value: Integer);

begin
  if FScrollBarWidth <> Value then
  begin
    FScrollBarWidth := Value;
    if FScrollBarWidth < 0 then
      FScrollBarWidth := 0;
    if FUseExternScrollBar then
      FScrollbar.Width := Value
    else
      FlatSB_SetScrollProp(Handle, WSB_PROP_CXVSCROLL, Value, True);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMEraseBkgnd(var Msg: TWMEraseBkgnd);

begin
  if FEraseBkGnd then
    inherited
  else
    Msg.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualListBox.GetScrollBarPosition: Integer;

var
  ScrollInfo: TScrollInfo;

begin
  if FUseExternScrollBar then
    Result := FScrollbar.Position
  else
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_POS;
      FlatSB_GetScrollInfo(Handle, SB_VERT, ScrollInfo);
      Result := Round(nPos * FScrollFactor);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarMin(Value: Integer);

var
  ScrollInfo: TScrollInfo;

begin
  if FUseExternScrollBar then
    FScrollbar.Min := Value
  else
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_RANGE;
      FlatSB_GetScrollInfo(Handle, SB_VERT, ScrollInfo);
      nMin := Value;
      FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarMax(Value: Integer);

var
  ScrollInfo: TScrollInfo;

begin
  if FUseExternScrollBar then
    FScrollbar.Max := Value
  else
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_RANGE;
      FlatSB_GetScrollInfo(Handle, SB_VERT, ScrollInfo);
      nMax := Value;
      // WM_SCROLL kann Werte nur bis ~65000 handeln
      if nMax > 65000 then
      begin
        FScrollFactor := nMax / 65000;
        nMax := 65000 + FLinesInWindow;
      end
      else
        FScrollFactor := 1;
      FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarPosition(Value: Integer);

var
  ScrollInfo: TScrollInfo;

begin
  if FUseExternScrollBar then
    FScrollbar.Position := Value
  else
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_POS;
      nPos := Round(Value / FScrollFactor);
      FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarLargeChange(Value: Integer);

var
  ScrollInfo: TScrollInfo;

begin
  if FUseExternScrollBar then
    FScrollbar.LargeChange := Value
  else
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_PAGE;
      nPage := Value;
      FlatSB_SetScrollInfo(Handle, SB_VERT, ScrollInfo, True);
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBarSmallChange(Value: Integer);

begin
  if FUseExternScrollBar then
    FScrollbar.SmallChange := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.Paint;

var
  YPos,
  Index,
  ImgIndex,
  LastIndex: Integer;
  ClipRect,
  PaintRect: TRect;
  ShowImages,
  CallOwnerDraw: Boolean;
  Selected: Boolean;
  TextVOffset,
  ImageVOffset: Integer;

begin
  ClipRect := Canvas.ClipRect;
  YPos := 0;
  LastIndex := FTopIndex + FLinesInWindow;
  if (ClientHeight mod ItemHeight) = 0 then
    Dec(LastIndex);

  if LastIndex > FItemCount - 1 then
    LastIndex := FItemCount - 1;

  ShowImages := Assigned(FImages) and Assigned(FOnGetImage);
  CallOwnerDraw := (Style <> vlbStandard) and Assigned(FOnDrawItem);

  TextVOffset := (ItemHeight - Abs(Canvas.Font.Height)) div 2;
  if ShowImages then
    ImageVOffset := (ItemHeight - FImages.Height) div 2
  else
    ImageVOffset := 0;

  for Index := TopIndex to LastIndex do
  begin
    PaintRect := Rect(0, YPos, FItemWidth, YPos + FItemHeight);
    if (PaintRect.Bottom > ClipRect.Top) and (PaintRect.Top < ClipRect.Bottom) then
    begin
      // fällt der Streifen ins ClipRect
      Selected := GetSel(FSelection, Index);

      if CallOwnerDraw then
        OnDrawItem(Self, Canvas, Index, PaintRect, Selected, Index = FItemIndex)
      else
      begin
        // Hintergrund löschen
        Canvas.Brush.Color := Color;
        Canvas.FillRect(PaintRect);

        if Selected then
        begin
          Canvas.Brush.Color := clHighLight;
          Canvas.Font.Color := clHighlightText;
          // selection bar
          if ShowImages then
          begin
            Inc(PaintRect.Left, FImages.Width + 8);
            Canvas.FillRect(PaintRect);
            Dec(PaintRect.Left, FImages.Width + 8);
          end
          else
            Canvas.FillRect(PaintRect);
        end
        else
          Canvas.Font.Color := Font.Color;

        if ShowImages then
        begin
          ImgIndex := -1;
          FOnGetImage(Self, Index, ImgIndex);
          FImages.Draw(Canvas, PaintRect.Left + 5, PaintRect.Top + ImageVOffset, ImgIndex);
          Canvas.TextOut(PaintRect.Left + FImages.Width + 10, PaintRect.Top + TextVOffset, GetItem(Index));
        end
        else
          Canvas.TextOut(PaintRect.Left + 5, PaintRect.Top + TextVOffset, GetItem(Index));
        if Index = FItemIndex then
        begin
          if ShowImages then Inc(PaintRect.Left, FImages.Width + 8);
          DrawFocusRect(Canvas.Handle, PaintRect);
        end;
      end;
    end;
    Inc(YPos, FItemHeight);
  end;

  // erase not yet covered parts of the window if necessary
  if not FEraseBkGnd and (LastIndex < (FTopIndex + FLinesInWindow)) then
  begin
    PaintRect := Bounds(0, (LastIndex - FTopIndex + 1) * FItemHeight, FItemWidth,
      ClipRect.Bottom - (LastIndex - FTopIndex + 1) * FItemHeight);
    Canvas.Brush.Color := Color;
    Canvas.FillRect(PaintRect);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);

begin
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if FUseExternScrollBar then
  begin
    with FScrollBar do
      SetBounds(AWidth - Width, 0, Width, AHeight);
  end;
  SetScrollBar;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.ToggleItem(Index: Integer);

var
  InvRect: TRect;

begin
  if not ToggleSel(FSelection, Index) then
    Inc(FSelCount)
  else
    Dec(FSelCount);

  InvRect := ItemRect(Index);
  InvalidateRect(Handle, @InvRect, False);
  DoChange(Index, GetSel(FSelection, Index));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.Notification(AComponent: TComponent; Operation: TOperation);

begin
  if (AComponent = FImages) and (Operation = opRemove) then
  begin
    FImages := nil;
    Refresh;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.ScrollBarChange(Sender: TObject);

begin
  TopIndex := GetScrollBarPosition;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.ScrollBarScroll(Sender: TObject; ScrollCode: TScrollCode; var ScrollPos: Integer);

begin
  if ScrollCode = scEndScroll then
    SetFocus;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.SetScrollBar;

var
  SBMax: Integer;
  FullLinesInWindow: Integer;
begin
  FullLinesInWindow := Height div ItemHeight;
  FLinesInWindow := FullLinesInWindow;
  if Height mod ItemHeight <> 0 then
    Inc(FLinesInWindow);
  if FLinesInWindow = 0 then
    FLinesInWindow := 1;
  SBMax := FItemCount - FullLinesInWindow;
  if SBMax < 0 then
    SBMax := 0;

  if HandleAllocated then
  begin
    SetScrollBarMax(SBMax);
    FItemWidth := ClientWidth;
    if FUseExternScrollbar then
      Dec(FItemWidth, FScrollBar.Left);
    SetScrollBarLargeChange(1);
  end
  else
    FItemWidth := Width;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.CMMouseWheel(var Message: TCMMouseWheel);

var
  ScrollCount: Integer;

begin
  inherited;
  if Message.Result = 0 then
  begin
    with Message do
    begin
      Result := 1;
      if ssCtrl in ShiftState then
        ScrollCount := WheelDelta div WHEEL_DELTA * FLinesInWindow
      else
        ScrollCount := WheelDelta div WHEEL_DELTA;
      TopIndex := TopIndex - ScrollCount;
      Update;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.CNKeyDown(var Msg: TWMKey);

var
  Shift: Boolean;
  ShiftState: TShiftState;
  CurrItem: Integer;

begin
  ShiftState := KeyDataToShiftState(Msg.KeyData);
  Shift := (ssShift in ShiftState) and (FExtSelectionAnchor <> -1);
  case Msg.CharCode of
    VK_LEFT,
    VK_UP:
      CurrItem := FItemIndex - 1;
    VK_RIGHT,
      VK_DOWN:
      CurrItem := FItemIndex + 1;
    VK_END:
      CurrItem := FItemCount - 1;
    VK_HOME:
      CurrItem := 0;
    VK_PRIOR:
      begin
        CurrItem := FItemIndex - FLinesInWindow + 1;
        if CurrItem < 0 then
          CurrItem := 0;
      end;
    VK_NEXT:
      begin
        CurrItem := FItemIndex + FLinesInWindow - 1;
        if CurrItem > FItemCount - 1 then
          CurrItem := FItemCount - 1;
      end;
    VK_SPACE:
      begin
        if MultiSelect then
        begin
          if not ExtendedSelect then
            ToggleItem(FItemIndex)
          else
          begin
            ClearSelection;
            SelectItem(FItemIndex, True);
          end;
        end;
        CurrItem := -1;
      end;
  else
    inherited;
    CurrItem := -1;
  end;

  if (CurrItem < 0) or (CurrItem > FItemCount - 1) then
    Exit;

  if MultiSelect and ExtendedSelect then
  begin
    if Shift then
    begin
      if not GetSel(FSelection, CurrItem) then
        SelectItem(CurrItem, True)
      else
        SelectItem(FItemIndex, False)
    end
    else
    begin
      if FSelCount = 1 then
        SelectItem(ItemIndex, False)
      else
        ClearSelection;
      SelectItem(CurrItem, True);
      FExtSelectionAnchor := CurrItem;
    end
  end
  else
    FExtSelectionAnchor := CurrItem;

  ItemIndex := CurrItem;                // select will be done by SetItemIndex
  Update;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WndProc(var Message: TMessage);

begin
  // for auto drag mode, let listbox handle itself, instead of TControl
  if not (csDesigning in ComponentState) and ((Message.Msg = WM_LBUTTONDOWN) or
    (Message.Msg = WM_LBUTTONDBLCLK)) and not Dragging then
  begin
    if DragMode = dmAutomatic then
    begin
      if IsControlMouseMsg(TWMMouse(Message)) then
        Exit;
      ControlState := ControlState + [csLButtonDown];
      Dispatch(Message);                {overrides TControl's BeginDrag}
      Exit;
    end;
  end;

  inherited WndProc(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMLButtonDown(var Msg: TWMLButtonDown);

var
  ShiftState: TShiftState;
  CurrIndex: Integer;

begin
  ShiftState := KeysToShiftState(Msg.Keys);
  CurrIndex := ItemAtPos(Msg.Pos, True);

  if (DragMode = dmAutomatic) and FMultiSelect and (ShiftState * [ssShift, ssCtrl] = []) and
    (CurrIndex > -1) and GetSel(FSelection, CurrIndex) then
  begin
    BeginDrag(False);
    Exit;
  end;

  inherited;
  if not Focused then
    SetFocus;

  if CurrIndex = -1 then
    Exit;

  // auto-scroll vorbereiten
  with FScrollTImer do
  begin
    Interval := 300;
    Enabled := True;
  end;

  if MultiSelect then
  begin
    if not ExtendedSelect then
      ToggleItem(CurrIndex)
    else
    begin                               // MultiSelect and ExtendedSelect
      if Msg.Keys and (MK_SHIFT or MK_CONTROL) = 0 then
      begin                             // loke not MultiSelect, but clear of all selects
        ClearSelection;
        SelectItem(CurrIndex, True);
        FExtSelectionAnchor := CurrIndex;
      end
      else
      begin
        if (Msg.Keys and MK_SHIFT) <> 0 then
        begin                           // Ctrl does not matter
          ClearSelection;
          if FExtSelectionAnchor = -1 then
            FExtSelectionAnchor := CurrIndex;
          FSelCount := Abs(FExtSelectionAnchor - CurrIndex) + 1;
          SelectRange(FExtSelectionAnchor, CurrIndex);
        end
        else
        begin                           // Ctrl without Shift
          ToggleItem(CurrIndex);
          FExtSelectionAnchor := CurrIndex;
        end;
      end;
    end;
  end;
  // focus rect & selects for not MultiSelect
  ItemIndex := CurrIndex;
  // synchronize painting
  Update;

  if (DragMode = dmAutomatic) and not (FMultiSelect and ((ssCtrl in ShiftState) or (ssShift in ShiftState))) then
    BeginDrag(False);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMLButtonUp(var Msg: TWMLButtonUp);

begin
  FScrollTimer.Enabled := False;
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMMouseMove(var Msg: TWMMouseMove);

var
  Shift: TShiftState;
  CurrItem: Integer;

begin
  inherited;
  CurrItem := ItemAtPos(SmallPoint(2, Msg.YPos), True);
  if CurrItem <> ItemIndex then
  begin
    Shift := KeysToShiftState(Msg.Keys);
    // ssLeft in Shift replaced due to problems with drop down list focus
    if csLButtonDown in ControlState then
    begin
      if (CurrItem > -1) and (CurrItem <> ItemIndex) then
      begin
        if not MultiSelect then
        begin
          SelectItem(FItemIndex, False);
          SelectItem(CurrItem, True);
        end
        else
          if ExtendedSelect then
          begin
            ClearSelection;
            FSelCount := Abs(FExtSelectionAnchor - CurrItem) + 1;
            SelectRange(FExtSelectionAnchor, CurrItem);
          end;
        // MultiSelect and not Extended: Focus only
        ItemIndex := CurrItem;
      end;
      UpdateWindow(Handle);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.WMVScroll(var Msg: TWMVScroll);

begin
  case Msg.ScrollCode of
    SB_BOTTOM:
      TopIndex := FItemCount - 1;
    SB_LINEDOWN:
      TopIndex := FTopIndex + 1;
    SB_LINEUP:
      TopIndex := FTopIndex - 1;
    SB_PAGEDOWN:
      TopIndex := FTopIndex + FLinesInWindow;
    SB_PAGEUP:
      TopIndex := FTopIndex - FLinesInWindow;
    SB_THUMBPOSITION:
      TopIndex := Round(Word(Msg.Pos) * FScrollFactor);
    SB_THUMBTRACK:
      TopIndex := Round(Word(Msg.Pos) * FScrollFactor);
    SB_TOP:
      TopIndex := 0;
  end;
  Update;
  Msg.Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.DoChange(Index: Integer; ItemSelected: Boolean);

begin
  if Assigned(FOnChange) then
  begin
    if FChangeDelay > 0 then
    begin
      FChangeTimer.Enabled := False;
      FLastChangedIndex := Index;
      FLastChangedItemSelected := ItemSelected;
      FChangeTimer.Interval := FChangeDelay;
      FChangeTimer.Enabled := True;
    end
    else
      FOnChange(Self, Index, ItemSelected);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.OnChangeTimer(Sender: TObject);

begin
  if Assigned(FOnChange) then
  begin
    FChangeTimer.Enabled := False;
    FOnChange(Self, FLastChangedIndex, FLastChangedItemSelected);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualListBox.OnScrollTimer(Sender: TObject);

// auto scroll while mouse move with selection

var
  MousePos: TPoint;
  Direction: Integer;
  CurrItem,
    dY, dTime: Integer;
  ScrollInfo: TScrollInfo;

begin
  if (FItemCount > FLinesInWindow) and not FFreezeScroll then
  begin
    GetCursorPos(MousePos);
    MapWindowPoints(0, Handle, MousePos, 1);
    with ScrollInfo do
    begin
      FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
      cbSize := SizeOf(TScrollInfo);
      FMask := SIF_ALL;
      FlatSB_GetScrollInfo(Handle, SB_VERT, ScrollInfo);

      if (MousePos.Y > Height) and (nPos < nMax) then
      begin
        Direction := 1;
        dY := MousePos.Y - Height;
      end
      else
        if (MousePos.Y < 0) and (nPos > 0) then
        begin
          Direction := -1;
          dY := -MousePos.Y;
        end
        else
          Exit;

      if dY <= 100 then
        dTime := 110 - dY
      else
        dTime := 10;

      TopIndex := FTopIndex + Round(Direction * Sqr(dY) / 100);
      FScrollTimer.Interval := dTime;
      if Direction > 0 then
        CurrItem := TopIndex + FLinesInWindow
      else
        CurrItem := TopIndex;

      if not MultiSelect then
      begin
        SelectItem(FItemIndex, False);
        SelectItem(CurrItem, True);
      end
      else
        if ExtendedSelect then
        begin
          ClearSelection;
          FSelCount := Abs(FExtSelectionAnchor - CurrItem) + 1;
          SelectRange(FExtSelectionAnchor, CurrItem);
        end;
      ItemIndex := CurrItem;
    end;
  end;
end;

//----------------- TWideVCBEdit ---------------------------------------------------------------------------------------

procedure TWideVCBEdit.CMMouseWheel(var Message: TCMMouseWheel);

begin
  with Owner as TBaseVirtualComboBox do
    WndProc(TMessage(Message));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.WMKeyDown(var Message: TWMKeyDown);

var
  NeedRedirect: Boolean;
  RedirectKeys: set of Byte;
begin
  RedirectKeys := [VK_RETURN, VK_PRIOR, VK_NEXT, VK_UP, VK_DOWN, VK_MULTIPLY, 187, VK_ADD, 189, VK_SUBTRACT, VK_ESCAPE];
  with Owner as TBaseVirtualComboBox do
    if Style = vcsDropDownList then
      RedirectKeys := RedirectKeys + [VK_END, VK_HOME];

  NeedRedirect := (Message.CharCode in RedirectKeys) or GetKeyState(VK_CONTROL) and (Message.CharCode in [VK_INSERT, VK_DELETE]);

  if NeedRedirect then
    with Owner as TBaseVirtualComboBox do
      WndProc(TMessage(Message))
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.CMWantSpecialKey(var Msg: TCMWantSpecialKey);
begin
  if not (Msg.CharCode in [VK_TAB, VK_RETURN]) then
    Msg.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.WMKillFocus(var Message: TWMKillFocus);

begin
  inherited;

  with Owner as TBaseVirtualComboBox do
    if Message.FocusedWnd <> Handle then
      WndProc(TMessage(Message));
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.WMLButtonDblClk(var Message: TWMLButtonDblClk);

begin
  inherited;

  with Owner as TBaseVirtualComboBox do
    EditDoubleClick(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.WMSetFocus(var Message: TWMSetFocus);

begin
  inherited;

  with Owner as TBaseVirtualComboBox do
    if Message.FocusedWnd <> Handle then
      RepaintWindow;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.WMSysKeyDown(var Message: TWMSysKeydown);

begin
  inherited;

  case Message.CharCode of
    VK_UP,
    VK_DOWN:
      with Owner as TBaseVirtualComboBox do
        DroppedDown := not DroppedDown;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TWideVCBEdit.DoChange;

var
  CurrentIndex: Integer;

begin
  with Owner as TBaseVirtualComboBox do
    if AutoSelecting then
    begin
      StartAutoSelecting;
      try
        CurrentIndex := CaretIndex;
        Text := Self.Text;
        CaretIndex := CurrentIndex;
      finally
        EndAutoSelecting;
      end;
    end;
end;

//----------------- TBaseVirtualComboBox -------------------------------------------------------------------------------

constructor TBaseVirtualComboBox.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);

  FMaxLength := 0;
  FStyle := vcsDropDown;
  ControlStyle := [csClickEvents, csSetCaption, csDoubleClicks, csReflector];
  Width := 150;
  Height := 25;
  TabStop := True;
  Color := clWindow;
  ParentColor := False;
  FBorderStyle := bsSingle;
  FDropDownCount := 8;
  FAnimationDuration := 200;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CloseThemes;

begin
  if FComboTheme <> 0 then
    CloseThemeData(FComboTheme);
  if FEditTheme <> 0 then
    CloseThemeData(FEditTheme);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.EndAutoSelecting;

begin
  Exclude(FStates, cbsAutoSelecting);
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetDroppedDown: Boolean;

begin
  Result := cbsDroppedDown in FStates;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetAutoSelecting: Boolean;

begin
  Result := cbsAutoSelecting in FStates;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetModified: Boolean;

begin
  Result := cbsModified in FStates;
  if not Result and HandleAllocated and Assigned(FEditWindow) then
    Result := FEditWindow.Modified;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.ReadIntlChars(Reader: TReader);

begin
  case Reader.NextValue of
    vaLString, vaString:
      FIntlChars := Reader.ReadString;
  else
    FIntlChars := Reader.ReadWideString;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.ReadText(Reader: TReader);

begin
  case Reader.NextValue of
    vaLString, vaString:
      FText := Reader.ReadString;
  else
    FText := Reader.ReadWideString;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetAlignment(const Value: TAlignment);

begin
  if FAlignment <> Value then
  begin
    FAlignment := Value;
    if HandleAllocated then
     Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetAnimationDuration(const Value: Cardinal);

begin
  FAnimationDuration := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetBorderStyle(const Value: TBorderStyle);

begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetDroppedDown(Value: Boolean);

begin
  if (cbsDroppedDown in FStates) <> Value then
  begin
    DoSetDroppedDown(Value);
    if Value and Assigned(FOnDropDown) then
      FOnDropDown(Self);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetIntlChars(const Value: WideString);

begin
  FIntlChars := Value;
  if Assigned(FEditWindow) then
    FEditWindow.IntlChars := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetLayout(const Value: TTextLayout);

begin
  if FLayout <> Value then
  begin
    FLayout := Value;
    if HandleAllocated then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetModified(Value: Boolean);

begin
  if HandleAllocated and Assigned(FEditWindow) then
    FEditWindow.Modified := Value;

  if Value then
    Include(FStates, cbsModified)
  else
    Exclude(FStates, cbsModified);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetOptions(Value: TVirtualComboboxOptions);

begin
  if FOptions <> Value then
  begin
    FOptions := Value;
    OptionsChanged;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetSelText(const Value: WideString);

begin
  if Assigned(FEditWindow) then
    //FEditWindow.SelText := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetStyle(Value: TVirtualComboboxStyle);

begin
  if FStyle <> Value then
  begin
    FStyle := Value;
    RecreateWnd;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.StartAutoSelecting;

begin
  Include(FStates, cbsAutoSelecting);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WriteIntlChars(Writer: TWriter);

begin
  Writer.WriteWideString(FIntlChars);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WriteText(Writer: TWriter);

begin
  Writer.WriteWideString(FText);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CMEnabledChanged(var Message: TMessage);

begin
  inherited;
  if Enabled then
    FButtonState := vbsNormal
  else
  begin
    FButtonState := vbsDisabled;
    DroppedDown := False;
  end;
  RepaintWindow;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMEraseBkgnd(var Message: TWMEraseBkgnd);

begin
  Message.Result := 1;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMGetDlgCode(var Message: TWMGetDlgCode);

begin
  Message.Result := DLGC_WANTARROWS or DLGC_WANTCHARS;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMKeyDown(var Message: TWMKeyDown);

var
  Shift: TShiftState;

begin
  case Message.CharCode of
    VK_RETURN,
    VK_ESCAPE:
      begin
        DroppedDown := False;
        if Editable then
          FEditWindow.SelectAll;
      end;
    VK_MULTIPLY,
    187,
    VK_ADD,
    189,
    VK_SUBTRACT:
      begin
        Shift := KeyDataToShiftState(Message.KeyData);
        if ssCtrl in Shift then
          with TMessage(Message) do
            Result := SendMessage(PopupWindow, Msg, wParam, lParam);
        Exit;
      end;
  end;

  inherited;
end;

procedure TBaseVirtualComboBox.WMKeyUp(var Message: TWMKeyUp);
begin
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMKillFocus(var Message: TWMKillFocus);

begin
  RepaintWindow;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMLButtonDown(var Message: TWMLButtonDown);

begin
  inherited;
  if not Focused and CanFocus then
    SetFocus;

  if FStyle = vcsDropDownList then
    DroppedDown := not DroppedDown;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMMouseLeave(var Message: TMessage);

// Returns hot button state of the combobox to its normal state.

var
  R: TRect;

begin
  FButtonState := vbsNormal;
  GetWindowRect(Handle, R);
  R.Left := R.Right - GetSystemMetrics(SM_CXVSCROLL) - 2;
  MapWindowPoints(0, Handle, R, 2);
  RepaintWindow(@R);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMMouseMove(var Message: TWMMouseMove);

begin
  inherited;
  if UseThemes then
    RegisterLeaveEvent(True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCCalcSize(var Message: TWMNCCalcSize);

begin
  inherited;

  with Message.CalcSize_Params^ do
  begin
    // Leave space for the drop down arrow.
    // The width of the combobox button is determined by the vertical scrollbar width.
    with RGRC[0] do
      Dec(Right, GetSystemMetrics(SM_CXVSCROLL));
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCDestroy(var Message: TWMNCDestroy);

begin
  CloseThemes;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCHitTest(var Message: TWMNCHitTest);
var
  P: TPoint;

begin
  inherited;
  P.X := Message.XPos;
  P.Y := Message.YPos;
  P := ScreenToClient(P);
  if not (csDesigning in ComponentState) and (P.X >= Width - GetSystemMetrics(SM_CXVSCROLL)) then
    Message.Result := HTBORDER
  else
    Message.Result := HTCLIENT;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCLButtonDblClk(var Message: TWMNCLButtonDblClk);

begin
  // Double click messages are to be handled just like mouse clicks.
  WMNCLButtonDown(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCLButtonDown(var Message: TWMNCLButtonDown);

begin                           
  if not (csDesigning in ComponentState) then
  begin
    if not Focused and CanFocus then
      SetFocus;
    // The message coordinates as well as the button coordinates are relative to screen space.
    if Message.XCursor >= GetSystemMetrics(SM_CXVSCROLL) - 2 then
      DroppedDown := not DroppedDown;
  end;
  
  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCMouseLeave(var Message: TMessage);

// Returns hot button state of the combobox to its normal state.

var
  R: TRect;

begin
  FButtonState := vbsNormal;
  GetWindowRect(Handle, R);
  R.Left := R.Right - GetSystemMetrics(SM_CXVSCROLL) - 2;
  MapWindowPoints(0, Handle, R, 2);
  RepaintWindow(@R);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCMouseMove(var Message: TWMNCMouseMove);

begin
  inherited;
  if UseThemes then
    RegisterLeaveEvent(False);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMNCPaint(var Message: TRealWMNCPaint);

var
  R: TRect;
  BitmapHandle: HBitmap;
  Bitmap: Windows.TBitmap;
  DC: HDC;
  Flags: DWORD;
  ButtonStyle,
  EdgeFlags: Cardinal;
  X, Y: Integer;
  ButtonWidth,
  ButtonFlag,
  BorderFlag: Integer;

begin
  Message.Result := 0;

  Flags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_CLIPCHILDREN or DCX_WINDOW;

  if (Message.Rgn = 1) or not IsWinNT then
    DC := GetDCEx(Handle, 0, Flags)
  else
    DC := GetDCEx(Handle, Message.Rgn, Flags or DCX_INTERSECTRGN);

  try
    R := Rect(0, 0, Width, Height);
    // Determine size of drop down button.
    ButtonWidth := GetSystemMetrics(SM_CXVSCROLL);
    // Exclude the client area from painting.
    if BorderStyle = bsSingle then
      ExcludeClipRect(DC, 2, 2, Width - ButtonWidth - 2, Height - 2)
    else
      ExcludeClipRect(DC, 0, 0, Width - ButtonWidth, Height);

    if UseThemes then
    begin
      // Draw frame.
      if FButtonState = vbsDisabled then
      begin
        ButtonFlag := CBXS_DISABLED;
        BorderFlag := ETS_DISABLED;
      end
      else
      begin
        ButtonFlag := Ord(FButtonState) + 1;
        BorderFlag := ETS_NORMAL;
      end;
      // The disabled border color is not exactly what the system combobox uses, but close enough.
      DrawThemeBackground(FEditTheme, DC, EP_EDITTEXT, BorderFlag, R, @R);
      InflateRect(R, -1, -1);
      // Draw button.
      // The width of the combobox button is determined by the vertical scrollbar width.
      R.Left := R.Right - ButtonWidth;
      DrawThemeBackground(FComboTheme, DC, CP_DROPDOWNBUTTON, ButtonFlag, R, @R);
    end
    else
    begin
      // Draw frame.
      EdgeFlags := BF_ADJUST or BF_RECT or BF_MIDDLE;
      if BorderStyle = bsSingle then
        DrawEdge(DC, R, EDGE_SUNKEN, EdgeFlags);

      // Draw button.
      BitmapHandle := LoadBitmap(0, Pointer(OBM_COMBO));
      GetObject(BitmapHandle, SizeOf(Bitmap), @Bitmap);
      try
        R.Left := R.Right - ButtonWidth;

        X := (R.Left + R.Right - Bitmap.bmWidth) div 2;
        Y := (R.Top + R.Bottom - Bitmap.bmHeight) div 2;

        ButtonStyle := BDR_RAISEDINNER or BDR_RAISEDOUTER;

        if FButtonState = vbsPressed then
        begin
          DrawEdge(DC, R, ButtonStyle, EdgeFlags + BF_FLAT);
          Inc(X);
          Inc(Y);
        end
        else
          DrawEdge(DC, R, ButtonStyle, EdgeFlags);

        DrawState(DC, 0, nil, Integer(BitmapHandle), 0, X, Y, 0, 0, DST_BITMAP or DSS_NORMAL);
      finally
        DeleteObject(BitmapHandle);
      end;
    end;
  finally
    ReleaseDC(Handle, DC);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMSetFocus(var Message: TWMSetFocus);

begin
  inherited;

  if FStyle <> vcsDropDownList then
    SelectAll;
  RepaintWindow;
  if Editable then
    FEditWindow.SetFocus;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMSetFont(var Message: TWMSetFont);

var
  Metrics: TTextMetric;

begin
  inherited;
  Canvas.Font := Font;
  GetTextMetrics(Canvas.Handle, Metrics);
  FTextHeight := Metrics.tmHeight;

  if Assigned(FEditWindow) then
    FEditWindow.Font := Font;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMSize(var Message: TWMSize);

begin
  inherited;

  if Assigned(FEditWindow) then
  begin
    // Center the text vertically in the edit window.
    //FEditWindow.NonClientMargin.Top := (Height - FTextHeight) div 2;
    //FEditWindow.NonClientMargin.Bottom := (Height - FTextHeight) div 2;
  end;
  RepaintWindow;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WMThemeChanged(var Message: TMessage);

// The user has changed the current theme or its enable state.

begin
  CloseThemes;

  if UseThemes then
  begin
    FComboTheme := OpenThemeData(0, 'combobox');
    FEditTheme := OpenThemeData(0, 'edit');
  end;

  RepaintWindow;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.Changed;

begin
  inherited;

  if Assigned(FOnChange) then
    FOnChange(Self);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CreateParams(var Params: TCreateParams);

begin
  inherited CreateParams(Params);

  with Params do
  begin
    Style := Style or WS_CLIPCHILDREN or WS_CLIPSIBLINGS;

    if FBorderStyle = bsSingle then
    begin
      if Ctl3D  then
        ExStyle := ExStyle or WS_EX_CLIENTEDGE
      else
        Style := Style or WS_BORDER;
    end
    else
      Style := Style and not WS_BORDER;

    // We can leave out the redraw flags because we have to repaint the window on resize anyway.
    WindowClass.Style := WindowClass.Style and not (CS_HREDRAW or CS_VREDRAW);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CreateWnd;

begin
  Include(FStates, cbsCreating);
  try
    inherited CreateWnd;
    if UseThemes then
    begin
      FComboTheme := OpenThemeData(0, 'combobox');
      FEditTheme := OpenThemeData(0, 'edit');
    end;

    if not (csDesigning in ComponentState) and (FStyle = vcsDropDown) then
    begin
      FEditWindow := TWideVCBEdit.Create(Self);
      FEditWindow.Parent := Self;
      FEditWindow.Options := [eoCanCopyFrom, eoSingleLine];
      FEditWindow.Align := alClient;
      FEditWindow.Text := Text;
      FEditWindow.BorderStyle := bsNone;
      FEditWindow.IntlChars := FIntlChars;

      FEditWindow.NonClientMargin.Left := 1;
      FEditWindow.NonClientMargin.Right := 1;
      FEditWindow.NonClientMargin.Top := 1;
      FEditWindow.NonClientMargin.Bottom := 1;
    end;

  finally
    Exclude(FStates, cbsCreating);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.DefineProperties(Filer: TFiler);

begin
  inherited;

  Filer.DefineProperty('WideText', ReadText, WriteText, FText <> '');
  Filer.DefineProperty('IntlChars', ReadIntlChars, WriteIntlChars, FIntlChars <> '');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.DestroyWnd;

begin
  DroppedDown := False;
  FreeAndNil(FEditWindow);
  inherited DestroyWnd;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.DoSetDroppedDown(Value: Boolean);

begin
  if Value <> (cbsDroppedDown in FStates) then
  begin
    if Value then
      Include(FStates, cbsDroppedDown)
    else
      Exclude(FStates, cbsDroppedDown);
    RepaintWindow;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.Editable: Boolean;

begin
  Result := (FStyle = vcsDropDown) and Assigned(FEditWindow);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.EditDoubleClick(var Message: TWMLButtonDblClk);

// This method is called when there is an edit and it has been double clicked. This special feature
// is necessary for the property inspector to start a its edit action.

begin
  if Assigned(FOnEditDoubleClick) then
    FOnEditDoubleClick(Self, KeysToShiftState(Message.Keys), SmallPointToPoint(Message.Pos));
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.FindItem(const ItemText: WideString): Boolean;

begin
  Result := False;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetPopupWindow: HWND;

begin
  Result := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetSelLength: Integer;

begin
  if Editable then
    Result := FEditWindow.SelEnd - FEditWindow.SelStart
  else
    Result := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetSelStart: Integer;

begin
  if Editable then
    Result := FEditWindow.SelStart
  else
    Result := -1;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetSelText: WideString;

begin
  if Editable then
    Result := FEditWindow.SelText
  else
    Result := '';
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetTextRect: TRect;

begin
  Result := ClientRect;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.OptionsChanged;

begin
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.RegisterLeaveEvent(IsClientArea: Boolean);

// If the combobox is currently not dropped down then the hover button state is set (if not yet done)
// and the window is registered for tracking the leave event of the mouse.

const
  TME_NONCLIENT = $00000010; // still not defined in Delphi 6

var
  TrackInfo: CommCtrl.TTrackMouseEvent;

begin
  if not (cbsDroppedDown in FStates) and (FButtonState <> vbsHot) then
  begin
    FButtonState := vbsHot;
    RepaintWindow;

    with TrackInfo do
    begin
      cbSize := SizeOf(TrackInfo);
      dwFlags := TME_LEAVE;
      if not IsClientArea then
        dwFlags := dwFlags or TME_NONCLIENT;
      hwndTrack := Handle;
      dwHoverTime := HOVER_DEFAULT;
    end;
    CommCtrl._TrackMouseEvent(@TrackInfo); // this is a wrapper that either calls TrackMouseEvent or emulates it
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.RepaintWindow(R: PRect = nil);

// Initiates an invalidation and repaint of the window, including the non-client area.
// If R <> nil then it should specify the parts of the window to repaint.

begin
  RedrawWindow(Handle, R, 0, RDW_FRAME or RDW_NOERASE or RDW_NOCHILDREN or RDW_INVALIDATE or RDW_VALIDATE or
    RDW_UPDATENOW);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetSelLength(Value: Integer);

begin
  if Editable then
    FEditWindow.SelEnd := FEditWindow.SelStart + Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetSelStart(Value: Integer);

begin
  if Editable then
    FEditWindow.SelStart := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetText(const Value: WideString);

var
  NewText: WideString;

begin
  if (FStyle = vcsDropDownList) or Editable then
  begin
    if Length(Value) > 0 then
      NewText := WideNormalize(Value, nfC)
    else
      NewText := '';
    if NewText <> FText then
    begin
      FText := NewText;
      if Editable then
        FEditWindow.Text := FText;
      Invalidate;
      Changed;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.WndProc(var Message: TMessage);

begin
  if not (csDesigning in ComponentState) then
  begin
    case Message.Msg of
      WM_KEYFIRST..WM_DEADCHAR:
        begin
          if (Message.Msg = WM_KEYDOWN) and (TWMKeyDown(Message).CharCode in [VK_RETURN, VK_ESCAPE]) then
            DroppedDown := False
          else
            with Message do
              SendMessage(PopupWindow, Msg, wParam, lParam);

          inherited; // otherwise we disable KeyPreview
        end;
      WM_SYSKEYDOWN:
        case TWMSysKeyDown(Message).CharCode of
          VK_UP,
          VK_DOWN:
            DroppedDown := not DroppedDown;
        else
          inherited;
        end;
    else
      inherited;
    end;
  end
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.Clear;

begin
  if Assigned(FEditWindow) then
    FEditWindow.Text := '';
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.ClearSelection;

begin
  if Assigned(FEditWindow) then
    FEditWindow.ClearSelection;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CopyToClipBoard;

begin
  if Assigned(FEditWindow) then
    FEditWindow.CopyToClipBoard;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.CutToClipBoard;

begin
  if Assigned(FEditWindow) then
    FEditWindow.CutToClipBoard;
end;

//----------------------------------------------------------------------------------------------------------------------

function TBaseVirtualComboBox.GetSelTextBuf(Buffer: PChar; BufSize: Integer): Integer;

var
  P: PChar;
  StartPos: Integer;

begin
  StartPos := GetSelStart;
  Result := GetSelLength;
  P := StrAlloc(GetTextLen + 1);
  try
    GetTextBuf(P, StrBufSize(P));
    if Result >= BufSize then
      Result := BufSize - 1;
    StrLCopy(Buffer, P + StartPos, Result);
  finally
    StrDispose(P);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.Paint;

var
  R: TRect;
  X, Y: Integer;
  Size: TSize;
  S: WideString;

begin
  with Canvas do
  begin
    // At design time no edit will be created so we have to paint the background in this case too.
    if (FStyle = vcsDropDownList) or (csDesigning in ComponentState) then
    begin
      Font := Self.Font;
      Brush.Color := Color;
      R := GetTextRect;
      FillRect(R);
      if UseThemes then
      begin
        InflateRect(R, -1, -1);
        if Focused and not (cbsDroppedDown in FStates) then
        begin
          Brush.Color := clHighLight;
          FillRect(R);
        end;
      end
      else
      begin
        InflateRect(R, -1, -1);
        if Focused and not (cbsDroppedDown in FStates) then
        begin
          Brush.Color := clHighLight;
          FillRect(R);
          Brush.Color := Color;
          DrawFocusRect(R);
        end;
      end;
      InflateRect(R, -1, -1);

      // Determine text to paint depending on current state.
      S := FText;

      // Paint text according to the alignment and layout values.
      case FAlignment of
        taCenter:
          begin
            GetTextExtentPoint32W(Canvas.Handle, PWideChar(S), Length(S), Size);
            X := (R.Right - R.Left - Size.cx) div 2;
          end;
        taRightJustify:
          begin
            GetTextExtentPoint32W(Canvas.Handle, PWideChar(S), Length(S), Size);
            X := R.Right - R.Left - Size.cx;
          end;
      else
        // taLeftJustify
        X := 0;
      end;
      case FLayout of
        tlCenter:
          Y := (R.Bottom - R.Top - FTextHeight) div 2;
        tlBottom:
          Y := R.Bottom - R.Top - FTextHeight;
      else
        // tlTop
        Y := 0;
      end;

      if Focused and not (cbsDroppedDown in FStates) then
        Font.Color := clWhite;
      SetBkMode(Handle, TRANSPARENT);
      ExtTextOutW(Handle, R.Left + X, R.Top + Y, ETO_CLIPPED, @R, PWideChar(S), Length(S), nil);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.PasteFromClipboard;

begin
  if Assigned(FEditWindow) then
    FEditWindow.PasteFromClipboard;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SelectAll;

begin
  if Assigned(FEditWindow) then
    FEditWindow.SelectAll;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TBaseVirtualComboBox.SetSelTextBuf(Buffer: PChar);

begin
  if Assigned(FEditWindow) then
//    SendMessage(FEditWindow.Handle, EM_REPLACESEL, 0, Integer(Buffer));
end;

//----------------- TTreePopup ----------------------------------------------------------------------------

constructor TTreePopup.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);

  BorderStyle := bsSingle;
  BevelKind := bkNone;

  TreeOptions.PaintOptions := TreeOptions.PaintOptions + [toPopupMode, toThemeAware];

  ScrollBarOptions.ScrollBars := ssBoth;

  Constraints.MinHeight := DefaultNodeHeight;
  Constraints.MinWidth := 2 * GetSystemMetrics(SM_CXVSCROLL);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.CloseTheme;

begin
  if FScrollTheme <> 0 then
    CloseThemeData(FScrollTheme);
  FScrollTheme := 0;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTreePopup.GetOptions: TStringTreeOptions;

begin
  Result := inherited TreeOptions as TStringTreeOptions;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTreePopup.GetOwner: TCustomVirtualTreeComboBox;

begin
  Result := inherited Owner as TCustomVirtualTreeComboBox;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.SetOptions(const Value: TStringTreeOptions);

begin
  inherited TreeOptions.Assign(Value);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.CMMouseLeave(var Message: TMessage);

// Recapture mouse if the tree is currently popped up.

begin
  if Owner.DroppedDown then
  begin
    SetCapture(Self.Handle);
    Windows.SetCursor(Screen.Cursors[crDefault]);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMExitSizeMove(var Message: TMessage);

begin
  Owner.SetFocus;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMKeyDown(var Message: TWMKeyDown);

begin
  if Owner.DroppedDown and (Message.CharCode = VK_ESCAPE) then
    Owner.DroppedDown := False
  else
    inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

const
  SC_SIZELEFT = $F001;
  SC_SIZERIGHT = $F002;
  SC_SIZETOP = $F003;
  SC_SIZETOPLEFT = $F004;
  SC_SIZETOPRIGHT = $F005;
  SC_SIZEBOTTOM = $F006;
  SC_SIZEBOTTOMLEFT = $F007;
  SC_SIZEBOTTOMRIGHT = $F008;
  SC_DRAGMOVE = $F012;

procedure TTreePopup.WMLButtonDown(var Message: TWMLButtonDown);

var
  R: TRect;

begin
  inherited;

  GetWindowRect(Handle, R);
  if not PtInRect(R, ClientToScreen(SmallPointToPoint(Message.Pos))) then
  begin
    Owner.DroppedDown := False;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMLButtonUp(var Message: TWMLButtonUp);

var
  HitInfo: THitInfo;
  WasCaptured,
  IsHit: Boolean;
  P: TPoint;
  R: TRect;

begin
  WasCaptured := GetCapture = Handle;
  inherited;

  // Check first if the mouse is in the tree window at all.
  P := ClientToScreen(SmallPointToPoint(Message.Pos));
  GetWindowRect(Handle, R);
  IsHit := PtInRect(R, P);
  if IsHit then
  begin
    GetHitTestInfoAt(Message.XPos, Message.YPos, True, HitInfo);
    with TreeOptions do
      IsHit := ([hiOnItemLabel, hiOnNormalIcon] * HitInfo.HitPositions <> []) or
        (((toFullRowSelect in SelectionOptions) or (toGridExtensions in MiscOptions)) and
        ([hiOnItemCheckBox, hiOnItemButton] * HitInfo.HitPositions = []) and
        Assigned(HitInfo.HitNode));

    if vcoMultiSelection in Owner.Options then
    begin
      if hiOnItemLabel in HitInfo.HitPositions then
      begin
        if HitInfo.HitNode.CheckState = csUncheckedNormal then
          HitInfo.HitNode.CheckState := csCheckedNormal
        else
          HitInfo.HitNode.CheckState := csUncheckedNormal;
        RepaintNode(HitInfo.HitNode);
        DoChecked(HitInfo.HitNode);
      end;
    end
    else
      if IsHit then
        Owner.DroppedDown := False;
  end
  else
    if WasCaptured then
      SetCapture(Handle);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMMouseActivate(var Message: TWMMouseActivate);

// Prevent window from being activated which would deactivate the owner control and its parent form.

begin
  Message.Result := MA_NOACTIVATE;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMMouseMove(var Message: TWMMouseMove);

var
  R: TRect;

begin
  inherited;

  // Switch off mouse capturing depending on mouse position.
  // This will ensure proper hit testing for the non-client area (resizing!).
  if GetCapture = Handle then
  begin
    GetWindowRect(Handle, R);
    if PtInRect(R, ClientToScreen(SmallPointToPoint(Message.Pos))) then
      ReleaseCapture;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMNCDestroy(var Message: TWMNCDestroy);

begin
  CloseTheme;

  inherited;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMNCHitTest(var Message: TWMNCHitTest);

begin
  inherited;

  with Message do
  begin
    if FPopupAbove then
    begin
      // Popup is shown above the combobox.
      if Abs(YPos - Top) <= 5 then
      begin
        if Abs(XPos - Left - Width) <= 5 then
          Result := HTTOPRIGHT
        else
          Result := HTTOP;
      end
      else
        if Abs(XPos - Left - Width) <= 5 then
          Result := HTRIGHT;
    end
    else
    begin
      // Popup is shown below the combobox.
      if Abs(YPos - Top - Height) <= 5 then
      begin
        if Abs(XPos - Left - Width) <= 5 then
          Result := HTBOTTOMRIGHT
        else
          Result := HTBOTTOM;
      end
      else
        if Abs(XPos - Left - Width) <= 5 then
          Result := HTRIGHT;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMNCPaint(var Message: TRealWMNCPaint);

// Draws a size grip into the little, unsused, right bottom square area.

var
  R: TRect;
  DC: HDC;
  Flags: DWORD;
  SBWidth,
  SBHeight: Integer;

  ScrollInfo: TScrollInfo;

begin
  inherited;

  // Determine whether both scroll bars are visible or not.
  with ScrollInfo do
  begin
    FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
    cbSize := SizeOf(ScrollInfo);
    fMask := SIF_PAGE or SIF_RANGE;
    GetScrollInfo(Handle, SB_VERT, ScrollInfo);
    if nMax > Integer(nPage) then
      SBWidth := GetSystemMetrics(SM_CXVSCROLL)
    else
      SBWidth := 0;

    nMax := 0;
    nPage := 0;
    GetScrollInfo(Handle, SB_HORZ, ScrollInfo);
    if nMax > Integer(nPage) then
      SBHeight := GetSystemMetrics(SM_CYHSCROLL)
    else
      SBHeight := 0;
  end;

  // Paint size box only if both scrollbars are visible.
  if (SBWidth > 0) and (SBHeight > 0) then
  begin
    Flags := DCX_CACHE or DCX_CLIPSIBLINGS or DCX_CLIPCHILDREN or DCX_WINDOW;

    if (Message.Rgn = 1) or not IsWinNT then
      DC := GetDCEx(Handle, 0, Flags)
    else
      DC := GetDCEx(Handle, Message.Rgn, Flags or DCX_INTERSECTRGN);

    if DC <> 0 then
    try
      R := Rect(Width - SBWidth - 1, Height - SBHeight - 1, Width - 1, Height - 1);
      if UseThemes then
        DrawThemeBackground(FScrollTheme, DC, SBP_SIZEBOX, SZB_RIGHTALIGN, R, @R)
      else
        DrawFrameControl(DC, R, DFC_SCROLL, DFCS_SCROLLSIZEGRIP);
    finally
      ReleaseDC(Handle, DC);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMSetCursor(var Message: TWMSetCursor);

begin
  // The VCL screws up the cursors during resize, hence avoid it.
  DefaultHandler(Message);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMSizing(var Message: TMessage);
begin
  inherited;
  Include(Owner.FStates, cbsResizedOnce); // set whenever the user resizes the popup
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.WMThemeChanged(var Message: TMessage);

// The user has changed the current theme or its enable state.

begin
  CloseTheme;

  if UseThemes then
    FScrollTheme := OpenThemeData(0, 'scrollbar');

  RedrawWindow(Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE or RDW_NOERASE or RDW_NOCHILDREN);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.CreateParams(var Params: TCreateParams);

const
  CS_DROPSHADOW = $00020000;
  
begin
  inherited CreateParams(Params);

  with Params do
  begin
    Style := WS_POPUP or WS_BORDER or WS_HSCROLL or WS_VSCROLL;
    ExStyle := ExStyle or WS_EX_TOOLWINDOW or WS_EX_TOPMOST or WS_EX_NOPARENTNOTIFY;

    if IsWinXP then
      with WindowClass do
        Style := Style or CS_DROPSHADOW;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.CreateWnd;

begin
  inherited;

  if UseThemes then
    FScrollTheme := OpenThemeData(0, 'scrollbar');
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.DoChecked(Node: PVirtualNode);

begin
  inherited;

  if vcoAutoUpdate in Owner.FOptions then
    Owner.ParseTree;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.DoChange(Node: PVirtualNode);

var
  DoAutoUpdate: Boolean;
  
begin
  inherited;

  with Owner do
  begin
    DoAutoUpdate := ([vcoAutoUpdate, vcoMultiSelection] * FOptions = [vcoAutoUpdate]) or not (cbsDroppedDown in FStates);
    if DoAutoUpdate and Assigned(Node) and not (cbsAutoSelecting in FStates) then
    begin
      Include(FStates, cbsAutoSelecting);
      try
        Text := Self.Text[Node, Header.MainColumn];
      finally
        Exclude(FStates, cbsAutoSelecting);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.DoInitNode(Parent, Node: PVirtualNode; var InitStates: TVirtualNodeInitStates);
begin
  inherited;
  if vcoMultiSelection in Owner.Options then
    Node.CheckType := ctCheckBox;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TTreePopup.DoHotChange(Old, New: PVirtualNode);

begin
  inherited;

  if vcoHotTrack in Owner.Options then
  begin
    if Assigned(Old) then
      Selected[Old] := False;
    if Assigned(New) then
      Selected[New] := True;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TTreePopup.GetOptionsClass: TTreeOptionsClass;

begin
  Result := TStringTreeOptions;
end;

//----------------- TCustomVirtualTreeComboBox ----------------------------------------------------------------------------

constructor TCustomVirtualTreeComboBox.Create(AOwner: TComponent);

begin
  inherited Create(AOwner);

  FTreePopup := TTreePopup.Create(Self);
  with FTreePopup do
  begin
    // Park the window far outside the screen to avoid it flashing.
    Left := 10000;
    Width := 100;
    ParentWindow := GetDesktopWindow;
    Name := 'TreePopup';
    Visible := False;
    ShowWindow(Handle, SW_HIDE);
  end;

  FImageChangeLink := TChangeLink.Create;
  FImageChangeLink.OnChange := ImageListChange;

  FSeparator := ',';
  FOptions := DefaultVirtualComboBoxOptions;
  
  // The combo box has to hook the main window to get notified when the application becomes inactive.
  if not (csDesigning in ComponentState) then
    Application.HookMainWindow(ApplicationMessageHook);
end;

//----------------------------------------------------------------------------------------------------------------------

destructor TCustomVirtualTreeComboBox.Destroy;

begin
  if not (csDesigning in ComponentState) then
    Application.UnhookMainWindow(ApplicationMessageHook);
  FImageChangeLink.Free;
  FTreePopup.Free; 
  inherited Destroy;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.CompareCaptions(Sender: TBaseVirtualTree; Node: PVirtualNode; Caption: Pointer;
  var Abort: Boolean);

// Callback method to find a node whose text is the same as the current combo box's text.
// Note: Comparation is case insensitive.

var
  AText: WideString;

begin
  with Sender as TTreePopup do
    AText := Text[Node, Header.MainColumn];
  Abort := WideSameText(PWideChar(Caption), AText);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.CompareCaptionsPartial(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Caption: Pointer; var Abort: Boolean);

// Callback method to find a node whose text is the same as the current combo box's text.
// Note: Comparation is case insensitive.

var
  NodeText,
  CurrentText: WideString;


begin
  with Sender as TTreePopup do
    NodeText := Text[Node, Header.MainColumn];
  CurrentText := PWideChar(Caption);
  Abort := StrLICompW(PWideChar(CurrentText), PWideChar(NodeText), Length(CurrentText)) = 0;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.DoNodeChecking(Sender: TBaseVirtualTree; Node: PVirtualNode; Caption: Pointer; var Abort: Boolean);

// Callback method which compares the given node with the nodes stored in the internal FNodes array.
// If Node is in this list then it is check otherwise unchecked.

const
  CheckState: array[Boolean] of TCheckState = (csUncheckedNormal, csCheckedNormal);

var
  I: Integer;

begin
  I := 0;
  while I < Length(FNodes) do
  begin
    if FNodes[I] = Node then
      Break;
    Inc(I);
  end;

  FTreePopup.CheckState[Node] := CheckState[I < Length(FNodes)];
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetDropDownRect(var R: TRect): Boolean;

// Calculates the position and size of the popup window in screen coordinates and returns True if the window is
// above the combo box otherwise False is returned.

var
  AHeight,
  AWidth: Cardinal;

begin
  if not (cbsResizedOnce in FStates) then
  begin
    // Before calculating the position adjust the height of the tree popup depending on the drop down count value.
    if FTreePopup.VisibleCount < FDropDownCount then
      FTreePopup.ClientHeight := Max(1, FTreePopup.VisibleCount) * FTreePopup.DefaultNodeHeight
    else
      FTreePopup.ClientHeight := FDropDownCount * FTreePopup.DefaultNodeHeight;
  end;
  
  AWidth := FTreePopup.Width;
  AHeight := FTreePopup.Height;

  R.TopLeft := Parent.ClientToScreen(Point(Left, Top + Height));
  Result := (R.Top + Integer(AHeight)) > Screen.Height;
  if Result then
    R.TopLeft := Parent.ClientToScreen(Point(Left, Top - Integer(AHeight)));
  R.Right := R.Left + Integer(AWidth);
  R.Bottom := R.Top + Integer(AHeight);
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnAfterCellPaint: TVTAfterCellPaintEvent;

begin
  Result := FTreePopup.OnAfterCellPaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnAfterItemErase: TVTAfterItemEraseEvent;

begin
  Result := FTreePopup.OnAfterItemErase;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnAfterItemPaint: TVTAfterItemPaintEvent;

begin
  Result := FTreePopup.OnAfterItemPaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnAfterPaint: TVTPaintEvent;

begin
  Result := FTreePopup.OnAfterPaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnBeforeCellPaint: TVTBeforeCellPaintEvent;

begin
  Result := FTreePopup.OnBeforeCellPaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnPaintText: TVTPaintText;
begin
  Result := FTreePopup.OnPaintText;
end;



function TCustomVirtualTreeComboBox.GetOnBeforeItemErase: TVTBeforeItemEraseEvent;

begin
  Result := FTreePopup.OnBeforeItemErase;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnBeforeItemPaint: TVTBeforeItemPaintEvent;

begin
  Result := FTreePopup.OnBeforeItemPaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnBeforePaint: TVTPaintEvent;

begin
  Result := FTreePopup.OnBeforePaint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnChecked: TVTChangeEvent;

begin
  Result := FTreePopup.OnChecked;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnChecking: TVTCheckChangingEvent;

begin
  Result := FTreePopup.OnChecking;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnCollapsed: TVTChangeEvent;

begin
  Result := FTreePopup.OnCollapsed;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnCollapsing: TVTChangingEvent;

begin
  Result := FTreePopup.OnCollapsing;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnColumnResize: TVTHeaderNotifyEvent;

begin
  Result := FTreePopup.OnColumnResize;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnHeaderDraw: TVTHeaderPaintEvent;

begin
  Result := FTreePopup.OnHeaderDraw;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnExpanded: TVTChangeEvent;

begin
  Result := FTreePopup.OnExpanded;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnExpanding: TVTChangingEvent;

begin
  Result := FTreePopup.OnExpanding;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnFreeNode: TVTFreeNodeEvent;

begin
  Result := FTreePopup.OnFreeNode;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnGetHint: TVSTGetTextEvent;

begin
  Result := FTreePopup.OnGetHint;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnGetImageIndex: TVTGetImageEvent;

begin
  Result := FTreePopup.OnGetImageIndex;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnGetNodeDataSize: TVTGetNodeDataSizeEvent;

begin
  Result := FTreePopup.OnGetNodeDataSize;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnGetText: TVSTGetTextEvent;

begin
  Result := FTreePopup.OnGetText;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnHeaderClick: TVTHeaderClickEvent;

begin
  Result := FTreePopup.OnHeaderClick;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnInitChildren: TVTInitChildrenEvent;

begin
  Result := FTreePopup.OnInitChildren;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetOnInitNode: TVTInitNodeEvent;

begin
  Result := FTreePopup.OnInitNode;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.ReadSeparator(Reader: TReader);

var
  Value: WideString;

begin
  case Reader.NextValue of
    vaLString, vaString:
      Value := Reader.ReadString;
  else
    Value := Reader.ReadWideString;
  end;

  if Length(Value) > 0 then
    Separator := Value[1];
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.ReadTree(Stream: TStream);

begin
  Stream.ReadComponent(FTreePopup);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetImages(const Value: TImageList);

begin
  if FImages <> Value then
  begin
    if Assigned(FImages) then
      FImages.UnRegisterChanges(FImageChangeLink);
    FImages := Value;
    FTreePopup.Images := Value;
    if Assigned(FImages) then
      FImages.RegisterChanges(FImageChangeLink);
    if not (csLoading in ComponentState) then
      Invalidate;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------


procedure TCustomVirtualTreeComboBox.SetOnPaintText(const Value: TVTPaintText);
begin
  FTreePopup.OnPaintText := Value;
end;


procedure TCustomVirtualTreeComboBox.SetOnAfterCellPaint(const Value: TVTAfterCellPaintEvent);

begin
  FTreePopup.OnAfterCellPaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnAfterItemErase(const Value: TVTAfterItemEraseEvent);

begin
  FTreePopup.OnAfterItemErase := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnAfterItemPaint(const Value: TVTAfterItemPaintEvent);

begin
  FTreePopup.OnAfterItemPaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnAfterPaint(const Value: TVTPaintEvent);

begin
  FTreePopup.OnAfterPaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnBeforeCellPaint(const Value: TVTBeforeCellPaintEvent);

begin
  FTreePopup.OnBeforeCellPaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnBeforeItemErase(const Value: TVTBeforeItemEraseEvent);

begin
  FTreePopup.OnBeforeItemErase := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnBeforeItemPaint(const Value: TVTBeforeItemPaintEvent);

begin
  FTreePopup.OnBeforeItemPaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnBeforePaint(const Value: TVTPaintEvent);

begin
  FTreePopup.OnBeforePaint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnChecked(Value: TVTChangeEvent);

begin
  FTreePopup.OnChecked := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnChecking(Value: TVTCheckChangingEvent);

begin
  FTreePopup.OnChecking := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnCollapsed(Value: TVTChangeEvent);

begin
  FTreePopup.OnCollapsed := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnCollapsing(Value: TVTChangingEvent);

begin
  FTreePopup.OnCollapsing := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnColumnResize(Value: TVTHeaderNotifyEvent);

begin
  FTreePopup.OnColumnResize := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnExpanded(Value: TVTChangeEvent);

begin
  FTreePopup.OnExpanded := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnExpanding(Value: TVTChangingEvent);

begin
  FTreePopup.OnExpanding := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnFreeNode(Value: TVTFreeNodeEvent);

begin
  FTreePopup.OnFreeNode := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnGetHint(Value: TVSTGetTextEvent);

begin
  FTreePopup.OnGetHint := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnGetImageIndex(Value: TVTGetImageEvent);

begin
  FTreePopup.OnGetImageIndex := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnGetNodeDataSize(Value: TVTGetNodeDataSizeEvent);

begin
  FTreePopup.OnGetNodeDataSize := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnGetText(Value: TVSTGetTextEvent);

begin
  FTreePopup.OnGetText := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnHeaderClick(Value: TVTHeaderClickEvent);

begin
  FTreePopup.OnHeaderClick := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnHeaderDraw(Value: TVTHeaderPaintEvent);

begin
  FTreePopup.OnHeaderDraw := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnInitChildren(Value: TVTInitChildrenEvent);

begin
  FTreePopup.OnInitChildren := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetOnInitNode(Value: TVTInitNodeEvent);

begin
  FTreePopup.OnInitNode := Value;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetSeparator(const Value: WideChar);

begin
  if FSeparator <> Value then
  begin
    FSeparator := Value;
    if not (csLoading in ComponentState) then
      ParseTree;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetTree(const Value: TTreePopup);

begin
  // Fake method to make the tree appear in the object inspector.
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.WriteSeparator(Writer: TWriter);

begin
  with Writer do
    WriteWideString(FSeparator);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.WriteTree(Stream: TStream);

begin
  Stream.WriteComponent(FTreePopup);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.CMCancelMode(var Message: TCMCancelMode);

begin
  if Message.Sender <> Self then
    DroppedDown := False;
  inherited;  //##fe?
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.CMMouseWheel(var Message: TCMMouseWheel);

var
  ScrollCount: Integer;
  Node: PVirtualNode;
  NextNode: function(Node: PVirtualNode): PVirtualNode of object;

begin
  if cbsDroppedDown in FStates then
    FTreePopup.WndProc(TMessage(Message))
  else
  begin
    inherited;

    if Message.Result = 0 then
      with Message, FTreePopup do
      begin
        Result := 1;
        // Advance nodes depending on WheelDelta.
        ScrollCount := -WheelDelta div WHEEL_DELTA;
        Node := FocusedNode;
        if ScrollCount > 0 then
          NextNode := GetNext
        else
        begin
          NextNode := GetPrevious;
          ScrollCount := -ScrollCount;
        end;

        while ScrollCount > 0 do
        begin
          Node := NextNode(Node);
          Dec(ScrollCount);
        end;
        FocusedNode := Node;
        Selected[Node] := True;
      end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.WMSize(var Message: TWMSize);

begin
  inherited;

  FTreePopup.Width := Width;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.ApplicationMessageHook(var Msg: TMessage): Boolean;

// Hides dropdown if user switches to another application.

begin
  Result := False;
  if DroppedDown then
  begin
    if ((Msg.Msg = WM_ACTIVATEAPP) and not TWMActivateApp(Msg).Active) then
    begin
      DroppedDown := False;
      Result := True;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.DefineProperties(Filer: TFiler);

begin
  inherited;

  Filer.DefineProperty('SeparatorData', ReadSeparator, WriteSeparator, FSeparator <> ',');
  Filer.DefineBinaryProperty('TreePopupData', ReadTree, WriteTree, True);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.DoSetDroppedDown(Value: Boolean);

const
  StepCount = 32;

var
  I, StepSize: Integer;
  BackBitmap: TBitmap;
  R, ButtonR: TRect;
  ScreenDC: HDC;
  S: WideString;

begin
  inherited;

  if Value then
  begin
    // Paint a pressed button.
    FButtonState := vbsPressed;
    ButtonR := Rect(Width - GetSystemMetrics(SM_CXVSCROLL) - 4, 0, Width, Height);
    RepaintWindow(@ButtonR);

    // Do an animated drop down.
    FTreePopup.FPopupAbove := GetDropDownRect(R);
    with R do
    begin
      BackBitmap := TBitmap.Create;
      BackBitmap.PixelFormat := pf32Bit;
      ScreenDC := GetDC(0);

      try
        BackBitmap.Width := Right - Left;
        BackBitmap.Height := Bottom - Top;
        with FTreePopup do
          ScrollIntoView(FocusedNode, False);
        StepSize := BackBitmap.Height div StepCount;

        if not (IsWin2K or IsWinXP or IsWin98) then
        begin
          with FTreePopup do
            Perform(WM_PRINT, wParam(BackBitmap.Canvas.Handle), PRF_NONCLIENT or PRF_CLIENT);
          if FTreePopup.FPopupAbove then
          begin
            for I := 1 to StepCount do
            begin
              BitBlt(ScreenDC, Left, Top + BackBitmap.Height - I * StepSize, BackBitmap.Width, I * StepSize,
                BackBitmap.Canvas.Handle, 0, 0, SRCCOPY);
              Sleep(1);
            end;
          end
          else
          begin
            for I := 1 to StepCount do
            begin
              BitBlt(ScreenDC, Left, Top, BackBitmap.Width, I * StepSize, BackBitmap.Canvas.Handle, 0, BackBitmap.Height -
                I * StepSize, SRCCOPY);
              Sleep(1);
            end;
          end;
          SetWindowPos(FTreePopup.Handle, 0, Left, Top, Right - Left, Bottom - Top, SWP_SHOWWINDOW or SWP_NOACTIVATE);
        end
        else
        begin
          SetWindowPos(FTreePopup.Handle, 0, Left, Top, Right - Left, Bottom - Top, SWP_NOACTIVATE);
          AnimateWindow(FTreePopup.Handle, FAnimationDuration, AW_BLEND);
          RedrawWindow(FTreePopup.Handle, nil, 0, RDW_FRAME or RDW_INVALIDATE);
        end;
        SetCapture(FTreePopup.Handle);
      finally
        ReleaseDC(0, ScreenDC);
        BackBitmap.Free;
        FButtonState := vbsNormal;
      end;
    end;
    RepaintWindow(@ButtonR);
  end
  else
  begin
    ReleaseCapture;

    //##fe speed up painting before Onchange handle gets called - does it work with vcsDropDown as well?
    S := BuildTextFromTree;
    FText := S;
    RepaintWindow(nil);
    FText := '';
    //##fe

    if IsWin2K or IsWinXP or IsWin98 then
      AnimateWindow(FTreePopup.Handle, FAnimationDuration, AW_BLEND or AW_HIDE)
    else
      ShowWindow(FTreePopup.Handle, SW_HIDE);

    ParseTree;
    SelectAll;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetPopupWindow: HWND;

begin
  Result := FTreePopup.Handle;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.GetTextRect: TRect;

// Returns a smaller text rectangle for list mode if there are images to draw.

begin
  Result := inherited GetTextRect;
  if Assigned(FImages) and not (vcoMultiSelection in FOptions) and Assigned(FPaintNode) then
    Inc(Result.Left, 4 + FImages.Width); // leave a margin of 2 pixels left and right
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.ImageListChange(Sender: TObject);

begin
  if not (csDestroying in ComponentState) then
    Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.OptionsChanged;

begin
  inherited;

  with FTreePopup.TreeOptions do
    if vcoMultiselection in Options then
      MiscOptions := MiscOptions + [toCheckSupport, toToggleOnDblClick]
    else
      MiscOptions := MiscOptions - [toCheckSupport, toToggleOnDblClick]
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.ParseText;

// If multi selection is enabled then this method attempts to split the current text of the combobox into
// node caption and checks the appropriate nodes in the tree popup.

  //--------------- local function --------------------------------------------

  procedure AddNodeToList(Node: PVirtualNode);

  // Checks if the given node is already in the internal node list and adds it if not.

  var
    I: Integer;

  begin
    I := 0;
    while I < Length(FNodes) do
    begin
      if Node = FNodes[I] then
        Break;
      Inc(I);
    end;

    if I = Length(FNodes) then
    begin
      SetLength(FNodes, I + 1);
      FNodes[I] := Node;
    end;
  end;

  //--------------- end local function ----------------------------------------

var
  Node: PVirtualNode;
  Head, Tail: PWideChar;
  S: WideString;

begin
  // Free previously collected values.
  FNodes := nil;
  if vcoMultiselection in FOptions then
  begin
    // Multiple items may be given. Set checked state for each corresponding node.
    Head := PWideChar(FText);
    while Head^ <> WideNull do
    begin
      Tail := Head;
      // Skip any white spaces.
      while (Tail^ <> WideNull) and UnicodeIsWhiteSpace(Word(Tail^)) do
        Inc(Tail);

      Head := Tail;
      if Tail^ <> WideNull then
      begin
        // Collect everything until the end of the string or the next separator character.
        while not (Tail^ in [WideNull, FSeparator]) do
          Inc(Tail);
        // If there was a valid string the search for it in the tree.
        if Tail - Head > 0 then
        begin
          SetString(S, Head, Tail - Head);
          Node := FTreePopup.IterateSubtree(nil, CompareCaptions, PWideChar(S), [], True);
          if Assigned(Node) then
            AddNodeToList(Node);
        end;
        // Finally skip separator character and continue with next part.
        if Tail^ = FSeparator then
          Inc(Tail);
        Head := Tail;
      end;
    end;

    // Once the collection is ready we can iterate through the tree and set check states accordingly.
    FTreePopup.IterateSubtree(nil, DoNodeChecking, nil, [], True);
  end
  else
  begin
    // Single select only. Try to find the first corresponding node and select/focus it.
    Node := FTreePopup.IterateSubtree(nil, CompareCaptionsPartial, PWideChar(FText), [], True);
    if Assigned(Node) then
    begin
      SetLength(FNodes, 1);
      FNodes[0] := Node;

      with FTreePopup do
      begin
        VisiblePath[Node] := True;
        FocusedNode := Node;
        Selected[Node] := True;
        ScrollIntoView(Node, False);
      end;
    end
    else
      FTreePopup.ClearSelection;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TCustomVirtualTreeComboBox.BuildTextFromTree: WideString;

var
  Run: PVirtualNode;

begin
  Result := '';
  with FTreePopup do
  begin
    if vcoMultiselection in FOptions then
    begin
      // Go through all nodes in the tree.
      Run := GetFirst;
      while Assigned(Run) do
      begin
        if Run.CheckState = csCheckedNormal then
          Result := Result + FSeparator + ' ' + Text[Run, Header.MainColumn];
        Run := GetNext(Run);
      end;
      if Length(Result) > 0 then
        Delete(Result, 1, 2);
    end
    else
    begin
      if Assigned(FocusedNode) then
        Result := Text[FocusedNode, Header.MainColumn];
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.ParseTree;

// Collects a list of node captions into the Text property, depending on enabled multiselection.

begin
  Text := BuildTextFromTree;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.SetText(const Value: WideString);

// Whenever new text is set we try to select/check the corresponding item in the popup treeview (if enabled).

begin
  inherited;

  if (vcoAutoSelect in FOptions) and not (cbsAutoSelecting in FStates) then
    ParseText;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.Clear;

begin
  inherited Clear;
  FTreePopup.Clear;
  FNodes := nil;
  Invalidate;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TCustomVirtualTreeComboBox.Paint;

var
  R: TRect;
  Ghosted: Boolean;
  Index: Integer;

begin
  FPaintNode := nil;
  if cbsDroppedDown in FStates then
    FPaintNode := FTreePopup.HotNode;
  if FPaintNode = nil then
    FPaintNode := FTreePopup.GetFirstSelected;

  inherited;

  // If there are images to show then display the image of the currently focused node.
  if Assigned(FImages) and not (vcoMultiSelection in FOptions) then
  begin
    R := GetTextRect;
    R.Right := R.Left;
    R.Left := 0;
    with Canvas do
    begin
      Brush.Color := Color;
      FillRect(R);

      if Assigned(FPaintNode) then
      begin
        FTreePopup.DoGetImageIndex(FPaintNode, ikNormal, FTreePopup.Header.MainColumn, Ghosted, Index);
        if Index > -1 then
          FImages.Draw(Canvas, R.Left + 1, R.Top, Index, Enabled);
      end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

var
  User32Handle: THandle;

initialization
  InitThemeLibrary;
  if IsWin2K or IsWinXP or IsWin98 then
  begin
    // Bind functions which are not available on all platforms dynamically.
    User32Handle := LoadLibrary('User32.DLL');
    @AnimateWindow := GetProcAddress(User32Handle, 'AnimateWindow');
  end;
finalization
  FreeLibrary(User32Handle);
  FreeThemeLibrary;
end.
