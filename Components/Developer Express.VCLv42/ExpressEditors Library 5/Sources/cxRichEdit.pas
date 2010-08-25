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

unit cxRichEdit;

{$I cxVer.inc}

interface
                              
uses
  Variants, Windows, Messages, ActiveX, OleDlg, OleConst, OleCtnrs, Classes,
  ClipBrd, ComCtrls, Controls, Dialogs, Forms, Graphics,
  Menus, RichEdit, StdCtrls, SysUtils, cxClasses, cxContainer,
  cxControls, cxEdit, cxDrawTextUtils, cxGraphics, cxLookAndFeels, cxMemo,
  cxScrollbar, cxTextEdit;

(*$HPPEMIT 'DECLARE_DINTERFACE_TYPE(IOleLink);'*)

type
  TcxRichEditStreamMode = (resmSelection, resmPlainRtf, resmRtfNoObjs, resmUnicode, resmTextIzed);
  TcxRichEditStreamModes = set of TcxRichEditStreamMode;

  TcxTextRange = record
    chrg: TCharRange;
    lpstrText: PChar;
  end;

  TReObject = packed record
    cbStruct: DWORD;        // Size of structure
    cp: Cardinal;           // Character position of object
    clsid: TCLSID;          // Class ID of object
    oleobj: IOleObject;     // OLE object interface
    stg: IStorage;          // Associated storage interface
    olesite: IOLEClientSite;// Associated client site interface
    sizel: TSize;           // Size of object (may be 0,0)
    dvaspect: DWORD;        // Display aspect to use
    dwFlags: DWORD;         // Object status flags
    dwUser: DWORD;          // Dword for user's use
  end;

  TcxCustomRichEdit = class;
  
  TcxRichEditURLClickEvent = procedure(Sender: TcxCustomRichEdit; const URLText: string;
    Button: TMouseButton) of object;
  TcxRichEditURLMoveEvent = procedure(Sender: TcxCustomRichEdit; const URLText: string) of object;
  TcxRichEditQueryInsertObjectEvent = procedure(Sender: TcxCustomRichEdit; var AAllowInsertObject: Boolean;
    const ACLSID: TCLSID) of object;

  TcxCustomRichEditViewInfo = class(TcxCustomMemoViewInfo)
  public
    DrawBitmap: HBITMAP;
    IsDrawBitmapDirty: Boolean;
    PrevDrawBitmapSize: TSize;
    constructor Create; override;
    destructor Destroy; override;
    procedure DrawNativeStyleEditBackground(ACanvas: TcxCanvas; ADrawBackground: Boolean;
      ABackgroundStyle: TcxEditBackgroundPaintingStyle; ABackgroundBrush: TBrushHandle); override;
    procedure DrawText(ACanvas: TcxCanvas); override;
    function GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion; override;
    function NeedShowHint(ACanvas: TcxCanvas; const P: TPoint;
      const AVisibleBounds: TRect; out AText: TCaption;
      out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean; override;
    procedure Paint(ACanvas: TcxCanvas); override;
  end;

  TcxCustomRichEditProperties = class;

  TcxCustomRichEditViewData = class(TcxCustomMemoViewData)
  private
    function GetProperties: TcxCustomRichEditProperties;
  protected
    function InternalGetEditContentSize(ACanvas: TcxCanvas;
      const AEditValue: TcxEditValue;
      const AEditSizeProperties: TcxEditSizeProperties): TSize; override;
  public
    procedure Calculate(ACanvas: TcxCanvas; const ABounds: TRect; const P: TPoint;
      Button: TcxMouseButton; Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
      AIsMouseEvent: Boolean); override;
    property Properties: TcxCustomRichEditProperties read GetProperties;
  end;

  {IRichEditOleCallback}

  TcxRichInnerEdit = class;

  IcxRichEditOleCallback = interface(IUnknown)
    ['{00020D00-0000-0000-C000-000000000046}']
    function GetNewStorage(out stg: IStorage): HRESULT; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame;
      out Doc: IOleInPlaceUIWindow; lpFrameInfo: POleInPlaceFrameInfo): HRESULT; stdcall;
    function ShowContainerUI(fShow: BOOL): HRESULT; stdcall;
    function QueryInsertObject(const clsid: TCLSID; stg: IStorage; cp: longint): HRESULT; stdcall;
    function DeleteObject(oleobj: IOLEObject): HRESULT; stdcall;
    function QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
      reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
      out dataobj: IDataObject): HRESULT; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
      var dwEffect: DWORD): HRESULT; stdcall;
    function GetContextMenu(seltype: Word; oleobj: IOleObject;
      const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
  end;

  { IRichEditOle }

  IcxRichEditOle = interface(IUnknown)
    ['{00020D00-0000-0000-C000-000000000046}']
    function GetClientSite(out clientSite: IOleClientSite): HResult; stdcall;
    function GetObjectCount: HResult; stdcall;
    function GetLinkCount: HResult; stdcall;
    function GetObject(iob: Longint; out reobject: TReObject;
      dwFlags: DWORD): HResult; stdcall;
    function InsertObject(var reobject: TReObject): HResult; stdcall;
    function ConvertObject(iob: Longint; rclsidNew: TIID;
      lpstrUserTypeNew: LPCSTR): HResult; stdcall;
    function ActivateAs(rclsid: TIID; rclsidAs: TIID): HResult; stdcall;
    function SetHostNames(lpstrContainerApp: LPCSTR;
      lpstrContainerObj: LPCSTR): HResult; stdcall;
    function SetLinkAvailable(iob: Longint; fAvailable: BOOL): HResult; stdcall;
    function SetDvaspect(iob: Longint; dvaspect: DWORD): HResult; stdcall;
    function HandsOffStorage(iob: Longint): HResult; stdcall;
    function SaveCompleted(iob: Longint; const stg: IStorage): HResult; stdcall;
    function InPlaceDeactivate: HResult; stdcall;
    function ContextSensitiveHelp(fEnterMode: BOOL): HResult; stdcall;
    function GetClipboardData(var chrg: TCharRange; reco: DWORD;
      out dataobj: IDataObject): HResult; stdcall;
    function ImportDataObject(dataobj: IDataObject; cf: TClipFormat;
      hMetaPict: HGLOBAL): HResult; stdcall;
  end;

  { TcxRichEditOleCallback }

  TcxRichEditOleCallback = class(TcxIUnknownObject, IcxRichEditOleCallback)
  private
    FEdit: TcxRichInnerEdit;
    FDocParentForm: IVCLFrameForm;
    FParentFrame: IVCLFrameForm;
    FAccelTable: HAccel;
    FAccelCount: Integer;
    procedure AssignParentFrame;
    procedure CreateAccelTable;
    procedure DestroyAccelTable;
  protected
    property ParentFrame: IVCLFrameForm read FParentFrame;
    property DocParentForm: IVCLFrameForm read FDocParentForm;
  public
    constructor Create(AOwner: TcxRichInnerEdit);

    //IRichEditOleCallback
    function ContextSensitiveHelp(fEnterMode: BOOL): HRESULT; stdcall;
    function DeleteObject(oleobj: IOLEObject): HRESULT; stdcall;
    function GetClipboardData(const chrg: TCharRange; reco: DWORD;
      out dataobj: IDataObject): HRESULT; stdcall;
    function GetContextMenu(seltype: Word; oleobj: IOleObject;
      const chrg: TCharRange; var menu: HMENU): HRESULT; stdcall;
    function GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
      var dwEffect: DWORD): HRESULT; stdcall;
    function GetInPlaceContext(out Frame: IOleInPlaceFrame;
      out Doc: IOleInPlaceUIWindow; lpFrameInfo: POleInPlaceFrameInfo): HRESULT; stdcall;
    function GetNewStorage(out stg: IStorage): HRESULT; stdcall;
    function QueryInsertObject(const clsid: TCLSID; stg: IStorage; cp: longint): HRESULT; stdcall;
    function QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
      reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT; stdcall;
    function ShowContainerUI(fShow: BOOL): HRESULT; stdcall;
  end;

  { TcxCustomRichEditProperties }

  TcxRichEditClass = (recRichEdit10, recRichEdit20);

  TcxCustomRichEditProperties = class(TcxCustomMemoProperties)
  private
    FAllowObjects: Boolean;
    FAutoURLDetect: Boolean;
    FHideScrollBars: Boolean;
    FMemoMode: Boolean;
    FPlainText: Boolean;
    FPlainTextChanged: Boolean;
    FRichEditClass: TcxRichEditClass;
    FSelectionBar: Boolean;
    FStreamModes: TcxRichEditStreamModes;
    FOnQueryInsertObject: TcxRichEditQueryInsertObjectEvent;
    FOnProtectChange: TRichEditProtectChange;
    FOnResizeRequest: TRichEditResizeEvent;
    FOnSaveClipboard: TRichEditSaveClipboard;
    FOnSelectionChange: TNotifyEvent;
    FOnURLClick: TcxRichEditURLClickEvent;
    FOnURLMove: TcxRichEditURLMoveEvent;
    procedure SetAllowObjects(const Value: Boolean);
    procedure SetAutoURLDetect(const Value: Boolean);
    procedure SetHideScrollBars(Value: Boolean);
    procedure SetMemoMode(Value: Boolean);
    procedure SetPlainText(Value: Boolean);
    procedure SetRichEditClass(AValue: TcxRichEditClass);
    procedure SetSelectionBar(Value: Boolean);
    procedure SetStreamModes(const Value: TcxRichEditStreamModes);
    procedure SetOnQueryInsertObject(Value: TcxRichEditQueryInsertObjectEvent);
  protected
    function CanValidate: Boolean; override;
    class function GetViewDataClass: TcxCustomEditViewDataClass; override;
    property PlainTextChanged: Boolean read FPlainTextChanged;
  public
    constructor Create(AOwner: TPersistent); override;

    procedure Assign(Source: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetDisplayText(const AEditValue: TcxEditValue;
      AFullText: Boolean = False; AIsInplace: Boolean = True): WideString; override;
    function GetSupportedOperations: TcxEditSupportedOperations; override;
    class function GetViewInfoClass: TcxContainerViewInfoClass; override;
    function IsResetEditClass: Boolean; override;
    property AllowObjects: Boolean read FAllowObjects write SetAllowObjects default False;
    property AutoURLDetect: Boolean read FAutoURLDetect write SetAutoURLDetect default False;
    property PlainText: Boolean read FPlainText write SetPlainText default False;
    property RichEditClass: TcxRichEditClass read FRichEditClass write SetRichEditClass default recRichEdit20;
    // !!!
    property HideScrollBars: Boolean read FHideScrollBars
      write SetHideScrollBars default True;
    property MemoMode: Boolean read FMemoMode write SetMemoMode default False;
    property SelectionBar: Boolean read FSelectionBar write SetSelectionBar
      default False;
    property StreamModes: TcxRichEditStreamModes read FStreamModes
      write SetStreamModes default [];
    property OnQueryInsertObject: TcxRichEditQueryInsertObjectEvent read FOnQueryInsertObject
      write SetOnQueryInsertObject;
    property OnProtectChange: TRichEditProtectChange read FOnProtectChange
      write FOnProtectChange;
    property OnResizeRequest: TRichEditResizeEvent read FOnResizeRequest
      write FOnResizeRequest;
    property OnSaveClipboard: TRichEditSaveClipboard read FOnSaveClipboard
      write FOnSaveClipboard;
    property OnSelectionChange: TNotifyEvent read FOnSelectionChange
      write FOnSelectionChange;
    property OnURLClick: TcxRichEditURLClickEvent read FOnURLClick
      write FOnURLClick;
    property OnURLMove: TcxRichEditURLMoveEvent read FOnURLMove
      write FOnURLMove;
  end;

  { TcxRichEditProperties }

  TcxRichEditProperties = class(TcxCustomRichEditProperties)
  published
    property Alignment;
    property AllowObjects;
    property AssignedValues;
    property AutoSelect;
    property AutoURLDetect;
    property ClearKey;
    property HideScrollBars;
    property HideSelection;
    property ImeMode;
    property ImeName;
    property MaxLength;
    property MemoMode;
    property OEMConvert;
    property PlainText;
    property ReadOnly;
    property RichEditClass;
    property ScrollBars;
    property SelectionBar;
    property StreamModes;
    property VisibleLineCount;
    property WantReturns;
    property WantTabs;
    property WordWrap;
    property OnQueryInsertObject;
    property OnChange;
    property OnEditValueChanged;
    property OnProtectChange;
    property OnResizeRequest;
    property OnSaveClipboard;
    property OnSelectionChange;
    property OnURLClick;
    property OnURLMove;
  end;

  { TcxOleUILinkInfo }

  TcxOleUILinkInfo = class(TcxIUnknownObject, IOleUILinkInfo)
  private
    FRichEdit: TcxRichInnerEdit;
    FReObject: TReObject;
    FOleLink: IOleLink;
  public
    constructor Create(AOwner: TcxRichInnerEdit; AReObject: TReObject);
    destructor Destroy; override;

    //IOleUILinkInfo
    function GetLastUpdate(dwLink: Longint; var LastUpdate: TFileTime): HResult; stdcall;

    //IOleUILinkContainer
    function GetNextLink(dwLink: Longint): Longint; stdcall;
    function SetLinkUpdateOptions(dwLink: Longint; dwUpdateOpt: Longint): HResult; stdcall;
    function GetLinkUpdateOptions(dwLink: Longint;
      var dwUpdateOpt: Longint): HResult; stdcall;
    function SetLinkSource(dwLink: Longint; pszDisplayName: PChar;
      lenFileName: Longint; var chEaten: Longint;
      fValidateSource: BOOL): HResult; stdcall;
    function GetLinkSource(dwLink: Longint; var pszDisplayName: PChar;
      var lenFileName: Longint; var pszFullLinkType: PChar;
      var pszShortLinkType: PChar; var fSourceAvailable: BOOL;
      var fIsSelected: BOOL): HResult; stdcall;
    function OpenLinkSource(dwLink: Longint): HResult; stdcall;
    function UpdateLink(dwLink: Longint; fErrorMessage: BOOL;
      fErrorAction: BOOL): HResult; stdcall;
    function CancelLink(dwLink: Longint): HResult; stdcall;
  end;

  { TcxOleUIObjInfo }

  TcxOleUIObjInfo = class(TcxIUnknownObject, IOleUIObjInfo)
  private
    FRichEdit: TcxRichInnerEdit;
    FReObject: TReObject;

    function GetObjectDataSize: Integer;
  public
    constructor Create(AOwner: TcxRichInnerEdit; AReObject: TReObject);

    //IOleUIObjInfo
    function GetObjectInfo(dwObject: Longint;
      var dwObjSize: Longint; var lpszLabel: PChar;
      var lpszType: PChar; var lpszShortType: PChar;
      var lpszLocation: PChar): HResult; stdcall;
    function GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
      var wFormat: Word; var ConvertDefaultClassID: TCLSID;
      var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult; stdcall;
    function ConvertObject(dwObject: Longint; const clsidNew: TCLSID): HResult; stdcall;
    function GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
      var dvAspect: Longint; var nCurrentScale: Integer): HResult; stdcall;
    function SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
      dvAspect: Longint; nCurrentScale: Integer;
      bRelativeToOrig: BOOL): HResult; stdcall;
  end;

  { TcxCustomRichEdit }

  TcxCustomRichEdit = class(TcxCustomMemo)
  private
    FEditPopupMenu: TComponent;
    FIsNullEditValue: Boolean;
    FLastLineCount: Integer;
    FPropertiesChange: Boolean;
    procedure DoProtectChange(Sender: TObject; AStartPos, AEndPos: Integer;
      var AAllowChange: Boolean);
    procedure DoSaveClipboard(Sender: TObject; ANumObjects, ANumChars: Integer;
      var ASaveClipboard: Boolean);
    procedure EditPopupMenuClick(Sender: TObject);
    function GetLines: TStrings;
    function GetInnerRich: TcxRichInnerEdit;
    procedure SetLines(Value: TStrings);
    function GetActiveProperties: TcxCustomRichEditProperties;
    function GetProperties: TcxCustomRichEditProperties;
    function GetRichVersion: Integer;
    procedure SetProperties(Value: TcxCustomRichEditProperties);
    function GetCanUndo: Boolean;
    function GetDefAttributes: TTextAttributes;
    function GetDefaultConverter: TConversionClass;
    function GetPageRect: TRect;
    function GetParagraph: TParaAttributes;
    function GetSelAttributes: TTextAttributes;
    procedure RefreshScrollBars;
    procedure SetDefAttributes(const Value: TTextAttributes);
    procedure SetDefaultConverter(Value: TConversionClass);
    procedure SetPageRect(const Value: TRect);
    procedure SetSelAttributes(const Value: TTextAttributes);
    procedure EMCanPaste(var Message: TMessage); message EM_CANPASTE;
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
  protected
    procedure AdjustInnerEdit; override;
    function CanFocusOnClick: Boolean; override;
    function CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean; override;
    procedure ContainerStyleChanged(Sender: TObject); override;
    function DoShowPopupMenu(AMenu: TComponent; X, Y: Integer): Boolean; override;
    function GetEditValue: TcxEditValue; override;
    function GetInnerEditClass: TControlClass; override;
    procedure ChangeHandler(Sender: TObject); override;
    procedure Scroll(AScrollBarKind: TScrollBarKind; AScrollCode: TScrollCode;
      var AScrollPos: Integer); override;
    procedure Initialize; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    procedure InternalValidateDisplayValue(const ADisplayValue: TcxEditValue); override;
    function CanDeleteSelection: Boolean;
    procedure Changed(Sender: TObject);
    procedure DoOnResizeRequest(const R: TRect);
    procedure DoOnSelectionChange;
    procedure DoTextChanged; override;
    procedure PropertiesChanged(Sender: TObject); override;
    procedure ResetEditValue; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure SynchronizeDisplayValue; override;
    procedure SynchronizeEditValue; override;
    procedure UpdateScrollBars; override;
    function GetEditPopupMenuInstance: TComponent; virtual;
    function IsNavigationKey(Key: Word; Shift: TShiftState): Boolean; virtual;
    function UpdateContentOnFocusChanging: Boolean; override;
    procedure UpdateEditPopupMenuItems(APopupMenu: TComponent); virtual;
    property EditPopupMenu: TComponent read FEditPopupMenu write FEditPopupMenu;
    property InnerRich: TcxRichInnerEdit read GetInnerRich;
    property PropertiesChange: Boolean read FPropertiesChange;
  public
    destructor Destroy; override;

    procedure ClearSelection; override;
    procedure CutToClipboard; override;
    function FindTexT(const ASearchStr: string; AStartPos, ALength: Integer;
      AOptions: TSearchTypes): Integer;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure PasteFromClipboard; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure Print(const Caption: string); virtual;
    procedure SaveSelectionToStream(Stream: TStream); virtual;
    procedure Undo; override;
    function InsertObject: Boolean;
    function PasteSpecial: Boolean;
    function ShowObjectProperties: Boolean;
    class procedure RegisterConversionFormat(const AExtension: string;
      AConversionClass: TConversionClass);
    property ActiveProperties: TcxCustomRichEditProperties
      read GetActiveProperties;
    property CanUndo: Boolean read GetCanUndo;
    property DefAttributes: TTextAttributes read GetDefAttributes write SetDefAttributes;
    property DefaultConverter: TConversionClass
      read GetDefaultConverter write SetDefaultConverter;
    property Lines: TStrings read GetLines write SetLines;
    property PageRect: TRect read GetPageRect write SetPageRect;
    property Paragraph: TParaAttributes read GetParagraph;
    property Properties: TcxCustomRichEditProperties read GetProperties
      write SetProperties;
    property RichVersion: Integer read GetRichVersion;
    property SelAttributes: TTextAttributes read GetSelAttributes write SetSelAttributes;
  end;

  { TcxRichEdit }

  TcxRichEdit = class(TcxCustomRichEdit)
  private
    function GetActiveProperties: TcxRichEditProperties;
    function GetProperties: TcxRichEditProperties;
    procedure SetProperties(Value: TcxRichEditProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxRichEditProperties read GetActiveProperties;
  published
    property Align;
    property Anchors;
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
    property Properties: TcxRichEditProperties read GetProperties
      write SetProperties;
    property Lines; // must be after Properties because of Properties.Alignment
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
    property OnMouseWheel;
    property OnMouseWheelDown;
    property OnMouseWheelUp;
    property OnStartDock;
    property OnStartDrag;
  end;

  TcxRichInnerEditHelper = class(TcxInterfacedPersistent,
    IcxContainerInnerControl, IcxCustomInnerEdit, IcxInnerTextEdit,
    IcxInnerMemo)
  private
    FEdit: TcxRichInnerEdit;
  protected
    property Edit: TcxRichInnerEdit read FEdit;
  public
    constructor Create(AEdit: TcxRichInnerEdit); reintroduce; virtual;

    // IcxContainerInnerControl
    function GetControlContainer: TcxContainer;
    function GetControl: TWinControl;

    // IcxCustomInnerEdit
    function CallDefWndProc(AMsg: UINT; WParam: WPARAM;
      LParam: LPARAM): LRESULT;
    function GetEditValue: TcxEditValue;
    function GetOnChange: TNotifyEvent;
    procedure LockBounds(ALock: Boolean);
    procedure SafelySetFocus;
    procedure SetEditValue(const Value: TcxEditValue);
    procedure SetParent(Value: TWinControl);
    procedure SetOnChange(Value: TNotifyEvent);

    // IcxInnerTextEdit
    procedure ClearSelection;
    procedure CopyToClipboard;
    function GetAlignment: TAlignment;
    function GetAutoSelect: Boolean;
    function GetCharCase: TEditCharCase;
    function GetEchoMode: TcxEditEchoMode;
    function GetFirstVisibleCharIndex: Integer;
    function GetHideSelection: Boolean;
    function GetImeLastChar: Char;
    function GetImeMode: TImeMode;
    function GetImeName: TImeName;
    function GetInternalUpdating: Boolean;
    function GetMaxLength: Integer;
    function GetMultiLine: Boolean;
    function GetOEMConvert: Boolean;
    function GetOnSelChange: TNotifyEvent;
    function GetPasswordChar: TCaptionChar;
    function GetReadOnly: Boolean;
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    function GetSelText: string;
    procedure SelectAll;
    procedure SetAlignment(Value: TAlignment);
    procedure SetAutoSelect(Value: Boolean);
    procedure SetCharCase(Value: TEditCharCase);
    procedure SetEchoMode(Value: TcxEditEchoMode);
    procedure SetHideSelection(Value: Boolean);
    procedure SetInternalUpdating(Value: Boolean);
    procedure SetImeMode(Value: TImeMode);
    procedure SetImeName(const Value: TImeName);
    procedure SetMaxLength(Value: Integer);
    procedure SetOEMConvert(Value: Boolean);
    procedure SetOnSelChange(Value: TNotifyEvent);
    procedure SetPasswordChar(Value: TCaptionChar);
    procedure SetReadOnly(Value: Boolean);
    procedure SetSelLength(Value: Integer);
    procedure SetSelStart(Value: Integer);
    procedure SetSelText(Value: string);
  {$IFDEF DELPHI12}
    function GetTextHint: string;
    procedure SetTextHint(Value: string);
  {$ENDIF}

    // IcxInnerMemo
    function GetCaretPos: TPoint;
    function GetLines: TStrings;
    function GetScrollBars: TScrollStyle;
    function GetWantReturns: Boolean;
    function GetWantTabs: Boolean;
    function GetWordWrap: Boolean;
    procedure SetCaretPos(const Value: TPoint);
    procedure SetScrollBars(Value: TScrollStyle);
    procedure SetWantReturns(Value: Boolean);
    procedure SetWantTabs(Value: Boolean);
    procedure SetWordWrap(Value: Boolean);
  end;

  { TcxRichEditStrings }

  TcxRichEditStreamOperation = (esoLoadFrom, esoSaveTo);

  TcxRichEditStreamOperationInfo = record
    EditStream: TEditStream;
    StreamInfo: TRichEditStreamInfo;
    TextType: Longint;
  {$IFDEF DELPHI12}
    Encoding: TEncoding
  {$ENDIF}
  end;

  TcxRichEditStrings = class(TStrings)
  private
    FConverter: TConversion;
    FRichEdit: TcxRichInnerEdit;
    FTextType: Longint;
    function CalcStreamTextType(AStreamOperation: TcxRichEditStreamOperation; ACustom: Boolean = False;
      ACustomStreamModes: TcxRichEditStreamModes = []): Longint;
    function GetAllowStreamModesByStreamOperation(AStreamOperation: TcxRichEditStreamOperation): TcxRichEditStreamModes;
    function GetStreamModes: TcxRichEditStreamModes;
  protected
    function Get(Index: Integer): string; override;
    procedure InitConverter(const AFileName: string); virtual;
    procedure InitStreamOperation(AStream: TStream;
      var AStreamOperationInfo: TcxRichEditStreamOperationInfo;
      AStreamOperation: TcxRichEditStreamOperation; ACustom: Boolean = False;
      ACustomStreamModes: TcxRichEditStreamModes = []);
    function GetCount: Integer; override;
    procedure Put(Index: Integer; const S: string); override;
    procedure SetUpdateState(Updating: Boolean); override;
    procedure SetTextStr(const Value: string); override;
    function GetLineBreakString: string; virtual;
    property RichEdit: TcxRichInnerEdit read FRichEdit;
  public
    constructor Create(ARichEdit: TcxRichInnerEdit); virtual;
    destructor Destroy; override;
    procedure Clear; override;
    procedure AddStrings(Strings: TStrings); override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure LoadFromFile(const FileName: string{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF}); override;
    procedure LoadFromStream(Stream: TStream{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF}); override;
    procedure SaveToFile(const FileName: string{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF}); override;
    procedure SaveToStream(Stream: TStream{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF}); override;
  end;

  { TcxRichInnerEdit }

  TcxRichInnerEdit = class(TRichEdit, IUnknown,
    IcxContainerInnerControl, IcxInnerEditHelper)
  private
    FAllowObjects: Boolean;
    FAutoSelect: Boolean;
    FAutoURLDetect: Boolean;
    FURLClickRange: TCharRange;
    FURLClickBtn: TMouseButton;
    FEchoMode: TcxEditEchoMode;
    FEscapePressed: Boolean;
    FHelper: TcxRichInnerEditHelper;
    FInternalUpdating: Boolean;
    FIsEraseBackgroundLocked: Boolean;
    FKeyPressProcessed: Boolean;
    FLockBoundsCount: Integer;
    FMemoMode: Boolean;
    FRichEditClass: TcxRichEditClass;
    FRichEditOle: IUnknown;
    FRichEditOleCallback: TObject;
    FRichVersion: Integer;
    FSavedPlainText: Boolean;
    FSelectionBar: Boolean;
    FStreamModes: TcxRichEditStreamModes;
    FRichLines: TcxRichEditStrings;
    FUseCRLF: Boolean;
    FOnQueryInsertObject: TcxRichEditQueryInsertObjectEvent;

    procedure CloseOleObjects;
    // IcxContainerInnerControl
    function GetControl: TWinControl;
    function GetControlContainer: TcxContainer;

    // IcxInnerEditHelper
    function GetHelper: IcxCustomInnerEdit;

    function GetAutoURLDetect: Boolean;
    function GetContainer: TcxCustomRichEdit;
    function GetLineCount: Integer;
    function GetLineIndex(AIndex: Integer): Integer;
    function GetLineLength(AIndex: Integer): Integer;
    function GetRichLines: TcxRichEditStrings;
    function GetRichEditOle: IcxRichEditOle;
    function GetRichEditOleCallBack: TcxRichEditOleCallback;
    function GetTextRange(AStartPos, AEndPos: Longint): string;
    procedure InternalSetMemoMode(AForcedReload: Boolean = False);
    procedure SetAllowObjects(Value: Boolean);
    procedure SetAutoURLDetect(Value: Boolean);
    procedure SetMemoMode(Value: Boolean);
    procedure SetRichEditClass(AValue: TcxRichEditClass);
    procedure SetRichLines(Value: TcxRichEditStrings);
    procedure SetSelectionBar(Value: Boolean);
    procedure SetOleControlActive(AActive: Boolean);
    procedure CMDocWindowActivate(var Message: TMessage); message CM_DOCWINDOWACTIVATE;
    procedure WMChar(var Message: TWMChar); message WM_CHAR;
    procedure WMClear(var Message: TMessage); message WM_CLEAR;
    procedure WMCut(var Message: TMessage); message WM_CUT;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
    procedure WMKeyDown(var Message: TWMKeyDown); message WM_KEYDOWN;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMMButtonDown(var Message: TWMMButtonDown); message WM_MBUTTONDOWN;
    procedure WMNCCalcSize(var Message: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMSetFont(var Message: TWMSetFont); message WM_SETFONT;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMHScroll(var Message: TWMHScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMVScroll); message WM_VSCROLL;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure WMWindowPosChanging(var Message: TWMWindowPosChanging); message WM_WINDOWPOSCHANGING;
    procedure EMReplaceSel(var Message: TMessage); message EM_REPLACESEL;
    procedure EMSetCharFormat(var Message: TMessage); message EM_SETCHARFORMAT;
    procedure EMSetParaFormat(var Message: TMessage); message EM_SETPARAFORMAT;
    procedure CMColorChanged(var Message: TMessage); message CM_COLORCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure CNNotify(var Message: TWMNotify); message CN_NOTIFY;
    procedure CNCommand(var Message: TWMCommand); message CN_COMMAND;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
    procedure WMGetText(var Message: TMessage); message WM_GETTEXT;
    procedure WMGetTextLength(var Message: TWMGetTextLength); message WM_GETTEXTLENGTH;
    procedure WMSetText(var Message: TWMSetText); message WM_SETTEXT;
    procedure WMIMEComposition(var Message: TMessage); message WM_IME_COMPOSITION;
    procedure EMExLineFromChar(var Message: TMessage); message EM_EXLINEFROMCHAR;
    procedure EMLineLength(var Message: TMessage); message EM_LINELENGTH;
  protected
    procedure BeforeInsertObject(var AAllowInsertObject: Boolean; const ACLSID: TCLSID); dynamic;
    procedure Click; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWindowHandle(const Params: TCreateParams); override;
    procedure DestroyWindowHandle; override;
    procedure CreateWnd; override;
    procedure DblClick; override;
    procedure DestroyWnd; override;
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    function GetSelText: string; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseLeave(AControl: TControl); dynamic;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure RequestAlign; override;
    procedure RequestSize(const Rect: TRect); override;
    procedure RichCreateParams(var Params: TCreateParams;
      out ARichVersion: Integer); virtual;
    procedure SelectionChange; override;
    procedure URLClick(const AURLText: string; AButton: TMouseButton); dynamic;
    procedure URLMove(const AURLText: string); dynamic;
    procedure WndProc(var Message: TMessage); override;
    function CanPaste: Boolean;
    function GetSelection: TCharRange; virtual;

    property AllowObjects: Boolean read FAllowObjects write SetAllowObjects default True;
    property AutoSelect: Boolean read FAutoSelect write FAutoSelect default False;
    property AutoURLDetect: Boolean read GetAutoURLDetect write SetAutoURLDetect default True;
    property Container: TcxCustomRichEdit read GetContainer;
    property Helper: TcxRichInnerEditHelper read FHelper;
    property MemoMode: Boolean read FMemoMode write SetMemoMode default False;
    property RichEditClass: TcxRichEditClass read FRichEditClass write SetRichEditClass;
    property RichEditOle: IcxRichEditOle read GetRichEditOle;
    property RichEditOleCallBack: TcxRichEditOleCallback read GetRichEditOleCallBack;
    property RichVersion: Integer read FRichVersion write FRichVersion;
    property SelectionBar: Boolean read FSelectionBar write SetSelectionBar
      default False;
    property StreamModes: TcxRichEditStreamModes read FStreamModes
      write FStreamModes default [];
    property OnQueryInsertObject: TcxRichEditQueryInsertObjectEvent
      read FOnQueryInsertObject write FOnQueryInsertObject;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DefaultHandler(var Message); override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    function ExecuteAction(Action: TBasicAction): Boolean; override;
    function FindTexT(const ASearchStr: string;
      AStartPos, ALength: Longint; AOptions: TSearchTypes): Integer;
    function InsertObject: Boolean;
    function ShowObjectProperties: Boolean;
    function PasteSpecial: Boolean;
    procedure Print(const Caption: string); override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    function UpdateAction(Action: TBasicAction): Boolean; override;
    function CanFocus: Boolean; override;
    function CanRedo: Boolean; virtual;
    procedure Redo; virtual;
    procedure Undo; virtual;
    property RichLines: TcxRichEditStrings
      read GetRichLines write SetRichLines;
  end;

function AdjustRichLineBreaks(ADest, ASource: PChar; AShortBreak: Boolean = False): Integer;
function AdjustRichLineBreaksA(ADest, ASource: PAnsiChar; AShortBreak: Boolean = False): Integer;
function AdjustRichLineBreaksW(ADest, ASource: PWideChar; AShortBreak: Boolean = False): Integer;
procedure SetRichEditText(ARichEdit: TRichEdit;
  const AEditValue: TcxEditValue);

implementation

uses
  CommDlg, Printers, cxEditPaintUtils, cxEditUtils, cxExtEditConsts, cxVariants,
  cxDWMAPI, dxUxTheme, dxThemeConsts, dxThemeManager, ComObj, CommCtrl,
  Math, Types, cxGeometry, dxCore;

type
  TcxStringArray = array of string;
  TStringsAccess = class(TStrings);
  PcxENLink = ^TENLink;

  PcxConversionFormat = ^TcxConversionFormat;

  TcxConversionFormat = record
    ConversionClass: TConversionClass;
    Extension: string;
    Next: PcxConversionFormat;
  end;

const
  cxMinVersionRichEditClass = {$IFNDEF DELPHI12}recRichEdit10{$ELSE}recRichEdit20{$ENDIF};

  RTFConversionFormat: TcxConversionFormat = (
    ConversionClass: TConversion;
    Extension: 'rtf';
    Next: nil
  );
  TextConversionFormat: TcxConversionFormat = (
    ConversionClass: TConversion;
    Extension: 'txt';
    Next: @RTFConversionFormat
  );
  cxRichReadError = $0001;
  cxRichWriteError = $0002;
  cxRichNoError = $0000;

const
  cxRichEditVersions: array [TcxRichEditClass] of Integer =
    (100, 200);//, 300, 410, 500);
  cxRichEditClassNames: array [TcxRichEditClass] of string =
    ('RICHEDIT',
    {$IFDEF DELPHI12}'RICHEDIT20W'{$ELSE}'RICHEDIT20A'{$ENDIF}{,
    'RICHEDIT30',
    'RICHEDIT41',
    'RICHEDIT50'});

const
  // Flags to specify which interfaces should be returned in the structure above
  REO_GETOBJ_NO_INTERFACES  = $00000000;
  REO_GETOBJ_POLEOBJ        = $00000001;
  REO_GETOBJ_PSTG           = $00000002;
  REO_GETOBJ_POLESITE       = $00000004;
  REO_GETOBJ_ALL_INTERFACES = $00000007;

  // Place object at selection
  REO_CP_SELECTION = $FFFFFFFF;

  // Use character position to specify object instead of index
  REO_IOB_SELECTION = $FFFFFFFF;
  REO_IOB_USE_CP    = $FFFFFFFE;

  // Object flags
  REO_NULL            = $00000000;	// No flags
  REO_READWRITEMASK   = $0000003F;	// Mask out RO bits
  REO_DONTNEEDPALETTE = $00000020;	// Object doesn't need palette
  REO_BLANK           = $00000010;	// Object is blank
  REO_DYNAMICSIZE     = $00000008;	// Object defines size always
  REO_INVERTEDSELECT  = $00000004;	// Object drawn all inverted if sel
  REO_BELOWBASELINE   = $00000002;	// Object sits below the baseline
  REO_RESIZABLE       = $00000001;	// Object may be resized
  REO_LINK            = $80000000;	// Object is a link (RO)
  REO_STATIC          = $40000000;	// Object is static (RO)
  REO_SELECTED        = $08000000;	// Object selected (RO)
  REO_OPEN            = $04000000;	// Object open in its server (RO)
  REO_INPLACEACTIVE   = $02000000;	// Object in place active (RO)
  REO_HILITED         = $01000000;	// Object is to be hilited (RO)
  REO_LINKAVAILABLE   = $00800000;	// Link believed available (RO)
  REO_GETMETAFILE     = $00400000;	// Object requires metafile (RO)

  RECO_PASTE          = $00000000;	// paste from clipboard
  RECO_DROP           = $00000001;	// drop
  RECO_COPY           = $00000002;	// copy to the clipboard
  RECO_CUT            = $00000003;	// cut to the clipboard
  RECO_DRAG           = $00000004;	// drag

  cxDataFormatCount = 6;
  cxPasteFormatCount = 6;

var
  FRichEditLibrary: HMODULE = 0;
  FRichRenderer, FRichConverter: TcxRichInnerEdit;
  FConversionFormatList: PcxConversionFormat = @TextConversionFormat;

  FRichEditDLLNames: TcxStringArray;

  CFObjectDescriptor: Integer;
  CFEmbeddedObject: Integer;
  CFLinkSource: Integer;
  CFRtf: Integer;
  CFRETextObj: Integer;

procedure ReleaseObject(var AObj);
begin
  if IUnknown(AObj) <> nil then
    IUnknown(AObj)._Release;
  IUnknown(AObj) := nil;
end;

function cxIsFormMDIChild(AForm: TCustomForm): Boolean;
begin
  Result := (AForm is TForm) and (TForm(AForm).FormStyle = fsMDIChild);
end;

function cxSetDrawAspect(AOleObject: IOleObject; AIconic: Boolean;
  AIconMetaPict: HGlobal; var ADrawAspect: Cardinal): HResult;
var
  AOleCache: IOleCache;
  AEnumStatData: IEnumStatData;
  AOldAspect: Cardinal;
  AAdviseFlags, AConnection: Longint;
  ATempMetaPict: HGlobal;
  AFormatEtc: TFormatEtc;
  AMedium: TStgMedium;
  AClassID: TCLSID;
  AStatData: TStatData;
  AViewObject: IViewObject;
begin
  AOldAspect := ADrawAspect;
  if AIconic then
  begin
    ADrawAspect := DVASPECT_ICON;
    AAdviseFlags := ADVF_NODATA;
  end else
  begin
    ADrawAspect := DVASPECT_CONTENT;
    AAdviseFlags := ADVF_PRIMEFIRST;
  end;
  if (ADrawAspect <> AOldAspect) or (ADrawAspect = DVASPECT_ICON) then
  begin
    AOleCache := AOleObject as IOleCache;
    if ADrawAspect <> AOldAspect then
    begin
      OleCheck(AOleCache.EnumCache(AEnumStatData));
      if AEnumStatData <> nil then
        while AEnumStatData.Next(1, AStatData, nil) = 0 do
          if AStatData.formatetc.dwAspect = Integer(AOldAspect) then
            AOleCache.Uncache(AStatData.dwConnection);
      FillChar(AFormatEtc, SizeOf(FormatEtc), 0);
      AFormatEtc.dwAspect := ADrawAspect;
      AFormatEtc.lIndex := -1;
      OleCheck(AOleCache.Cache(AFormatEtc, AAdviseFlags, AConnection));
      if AOleObject.QueryInterface(IViewObject, AViewObject) = 0 then
        AViewObject.SetAdvise(ADrawAspect, 0, nil);
    end;
    if ADrawAspect = DVASPECT_ICON then
    begin
      ATempMetaPict := 0;
      if AIconMetaPict = 0 then
      begin
        OleCheck(AOleObject.GetUserClassID(AClassID));
        ATempMetaPict := OleGetIconOfClass(AClassID, nil, True);
        AIconMetaPict := ATempMetaPict;
      end;
      try
        with AFormatEtc do
        begin
          cfFormat := CF_METAFILEPICT;
          ptd := nil;
          dwAspect := DVASPECT_ICON;
          lindex := -1;
          tymed := TYMED_MFPICT;
        end;
        with AMedium do
        begin
          tymed := TYMED_MFPICT;
          hMetaFilePict := AIconMetaPict;
          unkForRelease := nil;
        end;
        OleCheck(AOleCache.SetData(AFormatEtc, AMedium, False));
      finally
        DestroyMetaPict(ATempMetaPict);
      end;
    end;
    if ADrawAspect <> DVASPECT_ICON then
      AOleObject.Update;
  end;
  Result := S_OK;
end;

procedure cxCreateStorage(var AStorage: IStorage);
var
  ALockBytes: ILockBytes;
begin
  OleCheck(CreateILockBytesOnHGlobal(0, True, ALockBytes));
  OleCheck(StgCreateDocfileOnILockBytes(ALockBytes, STGM_READWRITE
    or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, AStorage));
  ReleaseObject(ALockBytes);
end;

function cxWStrLen(AStr: PWideChar): Integer;
begin
  Result := 0;
  while AStr[Result] <> #0 do Inc(Result);
end;

procedure cxCenterWindow(Wnd: HWnd);
var
  ARect: TRect;
begin
  ARect := cxGetWindowRect(Wnd);
  SetWindowPos(Wnd, 0,
    (GetSystemMetrics(SM_CXSCREEN) - cxRectWidth(ARect)) div 2,
    (GetSystemMetrics(SM_CYSCREEN) - cxRectHeight(ARect)) div 3,
    0, 0, SWP_NOACTIVATE or SWP_NOSIZE or SWP_NOZORDER);
end;

function cxOleDialogHook(Wnd: HWnd; Msg, WParam, LParam: Longint): Longint; stdcall;
begin
  Result := 0;
  if Msg = WM_INITDIALOG then
  begin
    if GetWindowLong(Wnd, GWL_STYLE) and WS_CHILD <> 0 then
      Wnd := GetWindowLong(Wnd, GWL_HWNDPARENT);
    cxCenterWindow(Wnd);
    Result := 1;
  end;
end;

function cxOleStdGetFirstMoniker(const AMoniker: IMoniker): IMoniker;
var
  AMksys: Longint;
  AEnumMoniker: IEnumMoniker;
begin
  Result := nil;
  if AMoniker <> nil then
  begin
    if (AMoniker.IsSystemMoniker(AMksys) = 0) and
      (AMksys = MKSYS_GENERICCOMPOSITE) then
    begin
      if AMoniker.Enum(True, AEnumMoniker) <> 0 then Exit;
      AEnumMoniker.Next(1, Result, nil);
    end
    else
      Result := AMoniker;
  end;
end;

function cxOleStdGetLenFilePrefixOfMoniker(const AMoniker: IMoniker): Integer;
var
  AMkFirst: IMoniker;
  ABindCtx: IBindCtx;
  AMksys: Longint;
  P: PWideChar;
begin
  Result := 0;
  if AMoniker <> nil then
  begin
    AMkFirst := cxOleStdGetFirstMoniker(AMoniker);
    if (AMkFirst <> nil) and
      (AMkFirst.IsSystemMoniker(AMksys) = 0) and
      (AMksys = MKSYS_FILEMONIKER) and
      (CreateBindCtx(0, ABindCtx) = 0) and
      (AMkFirst.GetDisplayName(ABindCtx, nil, P) = 0) and (P <> nil) then
    begin
      Result := cxWStrLen(P);
      CoTaskMemFree(P);
    end;
  end;
end;

function cxCoAllocCStr(const S: AnsiString): PAnsiChar; overload;
begin
  Result := StrCopy(CoTaskMemAlloc(Length(S) + 1), PAnsiChar(S));
end;

function cxCoAllocCStr(const S: WideString): PChar; overload;
begin
{$IFDEF DELPHI12}
  Result := StrCopy(CoTaskMemAlloc(Length(S) + 1), PChar(S));
{$ELSE}
  Result := cxCoAllocCStr(dxWideStringToAnsiString(S));
{$ENDIF}
end;

function cxGetOleLinkDisplayName(const AOleLink: IOleLink): PChar;
var
  P: PWideChar;
begin
  AOleLink.GetSourceDisplayName(P);
  Result := cxCoAllocCStr(P);
end;

function cxGetOleObjectFullName(const AOleObject: IOleObject): PChar;
var
  P: PWideChar;
begin
  AOleObject.GetUserType(USERCLASSTYPE_FULL, P);
  Result := cxCoAllocCStr(P);
  CoTaskMemFree(P);
end;

function cxGetOleObjectShortName(const AOleObject: IOleObject): PChar;
var
  P: PWideChar;
begin
  AOleObject.GetUserType(USERCLASSTYPE_SHORT, P);
  Result := cxCoAllocCStr(P);
  CoTaskMemFree(P);
end;

function cxGetIconMetaPict(AOleObject: IOleObject; ADrawAspect: Longint): HGlobal;
var
  ADataObject: IDataObject;
  AFormatEtc: TFormatEtc;
  AMedium: TStgMedium;
  AClassID: TCLSID;
begin
  Result := 0;
  if ADrawAspect = DVASPECT_ICON then
  begin
    AOleObject.QueryInterface(IDataObject, ADataObject);
    if ADataObject <> nil then
    begin
      with AFormatEtc do
      begin
        cfFormat := CF_METAFILEPICT;
        ptd := nil;
        dwAspect := DVASPECT_ICON;
        lIndex := -1;
        tymed := TYMED_MFPICT;
      end;
      if Succeeded(ADataObject.GetData(AFormatEtc, AMedium)) then
        Result := AMedium.hMetaFilePict;
      ReleaseObject(ADataObject);
    end;
  end;
  if Result = 0 then
  begin
    OleCheck(AOleObject.GetUserClassID(AClassID));
    Result := OleGetIconOfClass(AClassID, nil, True);
  end;
end;

function cxRichEditGetOleInterface(ARichEdit: TcxRichInnerEdit;
  out AOleInterface: IcxRichEditOle): Boolean;
begin
  Result := Assigned(ARichEdit) and ARichEdit.HandleAllocated and
    Boolean(SendMessage(ARichEdit.Handle, EM_GETOLEINTERFACE, 0, longint(@AOleInterface)));
end;

function cxRichEditSetOleCallback(ARichEdit: TcxRichInnerEdit;
  AOleInterface: IcxRichEditOleCallback): Boolean;
begin
  Result := Assigned(ARichEdit) and ARichEdit.HandleAllocated and
    Boolean(SendMessage(ARichEdit.Handle, EM_SETOLECALLBACK, 0, longint(AOleInterface)));
end;

function cxGetVCLFrameForm(AForm: TCustomForm): IVCLFrameForm;
begin
  if AForm.OleFormObject = nil then
    TOleForm.Create(AForm);
  Result := AForm.OleFormObject as IVCLFrameForm;
end;

function cxSendStructMessageEx(AHandle: THandle; AMsg: UINT; const AStructure; AParam: Integer; AStructureIsLParam: Boolean): LRESULT; overload;
begin
  if AStructureIsLParam then
    Result := SendMessage(AHandle, AMsg, AParam, Integer(@AStructure))
  else
    Result := SendMessage(AHandle, AMsg, Integer(@AStructure), AParam);
end;

function cxSendStructMessage(AHandle: THandle; AMsg: UINT; WParam: WPARAM; const LParam): LRESULT; overload;
begin
  Result := cxSendStructMessageEx(AHandle, AMsg, LParam, WParam, True);
end;

function cxSendStructMessage(AHandle: THandle; AMsg: UINT; const WParam; LParam: LParam): LRESULT; overload;
begin
  Result := cxSendStructMessageEx(AHandle, AMsg, WParam, LParam, False);
end;

function cxRichEditDLLNames: TcxStringArray;

  procedure InitRichEditDLLNames;
  const
    cxRichEditDLLNamesCount = 3;
  begin
    SetLength(FRichEditDLLNames, cxRichEditDLLNamesCount);
    FRichEditDLLNames[0] :=  'Riched32.dll';
    FRichEditDLLNames[1] :=  'Riched20.dll';
    FRichEditDLLNames[2] :=  'Msftedit.dll';
  end;

begin
  if Length(FRichEditDLLNames) = 0 then
    InitRichEditDLLNames;
  Result := FRichEditDLLNames;
end;

function AdjustRichLineBreaksW(ADest, ASource: PWideChar; AShortBreak: Boolean = False): Integer;
var
  APrevDest: PWideChar;
begin
  APrevDest := ADest;
  repeat
    if (ASource^ = WideChar($0D)) or (ASource^ = WideChar($0A)) then
    begin
      if AShortBreak then
        ADest^ := WideChar($0D)
      else
      begin
        ADest^ := WideChar($0D);
        Inc(ADest);
        ADest^ := WideChar($0A);
      end;
      if (ASource^ = WideChar($0D)) and ((ASource + 1)^ = WideChar($0A)) then
        Inc(ASource);
    end
    else
      ADest^ := ASource^;
    Inc(ASource);
    Inc(ADest);
  until ASource^ = WideChar($00);
  ADest^ := WideChar($00);
  Result := ADest - APrevDest;
end;

function AdjustRichLineBreaksA(ADest, ASource: PAnsiChar; AShortBreak: Boolean = False): Integer;
var
  APrevDest: PAnsiChar;
begin
  APrevDest := ADest;
  repeat
    if (ASource^ = AnsiChar($0D)) or (ASource^ = AnsiChar($0A)) then
    begin
      if AShortBreak then
        ADest^ := AnsiChar($0D)
      else
      begin
        ADest^ := AnsiChar($0D);
        Inc(ADest);
        ADest^ := AnsiChar($0A);
      end;
      if (ASource^ = AnsiChar($0D)) and ((ASource + 1)^ = AnsiChar($0A)) then
        Inc(ASource);
    end
    else
      ADest^ := ASource^;
    Inc(ASource);
    Inc(ADest);
  until ASource^ = AnsiChar($00);
  ADest^ := AnsiChar($00);
  Result := ADest - APrevDest;
end;

function AdjustRichLineBreaks(ADest, ASource: PChar; AShortBreak: Boolean = False): Integer;
begin
{$IFDEF DELPHI12}
  Result := AdjustRichLineBreaksW(ADest, ASource, AShortBreak);
{$ELSE}
  Result := AdjustRichLineBreaksA(ADest, ASource, AShortBreak);
{$ENDIF}
end;

function cxRichEditStreamLoad(dwCookie: Longint; pbBuff: PByte;
  cb: Longint; var pcb: Longint): Longint; stdcall;
var
  AStreamInfo: TRichEditStreamInfo;
{$IFDEF DELPHI12}
  P, APreamble: TBytes;
{$ENDIF}
begin
  Result := cxRichNoError;
  try
    pcb := 0;
    AStreamInfo := PRichEditStreamInfo(dwCookie)^;
    if AStreamInfo.Converter <> nil then
    begin
    {$IFNDEF DELPHI12}
      pcb := AStreamInfo.Converter.ConvertReadStream(AStreamInfo.Stream, PAnsiChar(pbBuff), cb);
    {$ELSE}
      SetLength(P, cb + 1);
      pcb := AStreamInfo.Converter.ConvertReadStream(AStreamInfo.Stream, P, cb);
      if AStreamInfo.PlainText then
      begin
        if AStreamInfo.Encoding = nil then
        begin
          P := TEncoding.Convert(TEncoding.Default, TEncoding.Unicode, P, 0, pcb);
          pcb := Length(P);
        end
        else
        begin
          if not TEncoding.Unicode.Equals(AStreamInfo.Encoding) then
          begin
            P := TEncoding.Convert(AStreamInfo.Encoding, TEncoding.Unicode, P, 0, pcb);
            pcb := Length(P);
          end;
        end;
      end;
      APreamble := TEncoding.Unicode.GetPreamble;
      if (pcb >= 2) and (P[0] = APreamble[0]) and (P[1] = APreamble[1]) then
      begin
        AStreamInfo.Stream.Position := 2;
        pcb := AStreamInfo.Converter.ConvertReadStream(AStreamInfo.Stream, P, cb);
      end;
      Move(P[0], pbBuff^, pcb);
    {$ENDIF}
    end;
  except
    Result := cxRichReadError;
  end;
end;

function cxRichEditStreamSave(dwCookie: Longint; pbBuff: PByte; cb: Longint;
  var pcb: Longint): Longint; stdcall;

{$IFDEF DELPHI12}
  function BytesOf(AValue: PAnsiChar): TBytes;
  var
    ALength: Integer;
  begin
    ALength := StrLen(AValue) + 1;
    SetLength(Result, ALength);
    Move(AValue^, PAnsiChar(Result)^, ALength);
  end;
{$ENDIF}

var
  AStreamInfo: TRichEditStreamInfo;
{$IFDEF DELPHI12}
  P: TBytes;
{$ENDIF}
begin
  Result := cxRichNoError;
  try
    pcb := 0;
    AStreamInfo := PRichEditStreamInfo(dwCookie)^;
    if AStreamInfo.Converter <> nil then
    begin
    {$IFDEF DELPHI12}
      SetLength(P, cb);
      Move(pbBuff^, P[0], cb);
      if AStreamInfo.PlainText then
      begin
        if AStreamInfo.Encoding = nil then
          P := TEncoding.Convert(TEncoding.Unicode, TEncoding.Default, P)
        else
        begin
          if not TEncoding.Unicode.Equals(AStreamInfo.Encoding) then
            P := TEncoding.Convert(TEncoding.Unicode, AStreamInfo.Encoding, P);
        end;
      end;
      pcb := AStreamInfo.Converter.ConvertWriteStream(AStreamInfo.Stream, P, Length(P));
      if (pcb <> cb) and (pcb = Length(P)) then
        pcb := cb;
    {$ELSE}
      pcb := AStreamInfo.Converter.ConvertWriteStream(AStreamInfo.Stream, PAnsiChar(pbBuff), cb);
    {$ENDIF}
    end;
  except
    Result := cxRichWriteError;
  end;
end;

function IsRichText(const AText: string): Boolean;
const
  ARichPrefix = '{\rtf';
begin
  Result := Copy(AText, 1, Length(ARichPrefix)) = ARichPrefix;
end;

procedure LoadRichFromString(ALines: TStrings; const S: string);

  procedure PrepareStream(
    AStream: TStringStream);
  begin
  end;

var
  AStream: TStringStream;
{$IFDEF DELPHI12}
  AEncoding: TEncoding;
{$ENDIF}
begin
{$IFDEF DELPHI12}
  if IsRichText(S) then
    AEncoding := TEncoding.Default
  else
    AEncoding := TEncoding.Unicode;
{$ENDIF}
  AStream := TStringStream.Create(S{$IFDEF DELPHI12}, AEncoding{$ENDIF});
  try
    PrepareStream(AStream);
    ALines.LoadFromStream(AStream{$IFDEF DELPHI12}, AEncoding{$ENDIF});
  finally
    AStream.Free;
  end;
end;

procedure ReleaseConversionFormatList;
var
  AConversionFormatList: PcxConversionFormat;
begin
  while FConversionFormatList <> @TextConversionFormat do
  begin
    AConversionFormatList := FConversionFormatList^.Next;
    Dispose(FConversionFormatList);
    FConversionFormatList := AConversionFormatList;
  end;
end;

function CreateInnerRich: TcxRichInnerEdit;
begin
  Result := nil;
  if Application.Handle <> 0 then
  begin
    Result := TcxRichInnerEdit.Create(nil);
    Result.ParentWindow := Application.Handle;
    SendMessage(Result.Handle, EM_SETEVENTMASK, 0, 0);
  end;
end;

function RichRenderer: TcxRichInnerEdit;
begin
  if FRichRenderer = nil then
    FRichRenderer := CreateInnerRich;
  Result := FRichRenderer;
end;

function RichConverter: TcxRichInnerEdit;
begin
  if FRichConverter = nil then
    FRichConverter := CreateInnerRich;
  Result := FRichConverter;
end;

procedure InternalSetRichEditText(ARichEdit: TRichEdit; const AText: string);
begin
  if not ARichEdit.PlainText then
    LoadRichFromString(ARichEdit.Lines, AText)
  else
    ARichEdit.Perform(WM_SETTEXT, 0, Longint(PChar(AText)));
end;

function ConvertRichText(const AText: string): string;
begin
  InternalSetRichEditText(RichConverter, AText);
  Result := RichConverter.Text;
end;

procedure SetRichDefAttributes(AEdit: TRichEdit; AFont: TFont; ATextColor: TColor);
begin
  if not AEdit.HandleAllocated then
    Exit;

  AEdit.DefAttributes.Assign(AFont);
  AEdit.DefAttributes.Color := ATextColor;
end;

procedure InitRichRenderer(AProperties: TcxCustomRichEditProperties;
  AFont: TFont; AColor, ATextColor: TColor; const AText: string);
begin
  with RichRenderer do
  begin
    MemoMode := TcxCustomRichEditProperties(AProperties).MemoMode;
    PlainText := TcxCustomRichEditProperties(AProperties).PlainText;
    Alignment := TcxCustomRichEditProperties(AProperties).Alignment;
    AutoURLDetect := TcxCustomRichEditProperties(AProperties).AutoURLDetect;
    AllowObjects := TcxCustomRichEditProperties(AProperties).AllowObjects;
    RichEditClass := TcxCustomRichEditProperties(AProperties).RichEditClass;
    HandleNeeded;

    if not RichRenderer.MemoMode then
      LoadRichFromString(RichLines, AText)
    else
      Text := AText;

    if not IsRichText(AText) or MemoMode or PlainText then
      SetRichDefAttributes(RichRenderer, AFont, ATextColor);
    SendMessage(Handle, EM_SETBKGNDCOLOR, 0, ColorToRGB(AColor));
  end;
end;

procedure DrawRichEdit(ADC: HDC; const ARect: TRect; const AText: string;
  AProperties: TcxCustomRichEditProperties; AFont: TFont;
  AColor, ATextColor: TColor; ACalculateHeight: Boolean; out AHeight: Integer);
const
  TwipsPerInch = 1440;
var
  AFormatRange: TFormatRange;
  AStartIndex: Integer;
begin
  if not ACalculateHeight then
    FillRect(ADC, Rect(0, 0, ARect.Right - ARect.Left,
      ARect.Bottom - ARect.Top), GetSolidBrush(AColor));
  InitRichRenderer(AProperties, AFont, AColor, ATextColor, AText);
  SendMessage(RichRenderer.Handle, EM_FORMATRANGE, 0, 0);

  if ACalculateHeight then
    AHeight := 0;
  AFormatRange.hdc := ADC;
  AFormatRange.hdcTarget := ADC;
  AFormatRange.chrg.cpMin := 0;
  AFormatRange.chrg.cpMax := -1;
  repeat
    AFormatRange.rc := cxEmptyRect;
    AFormatRange.rc.Right := (ARect.Right - ARect.Left) * TwipsPerInch div GetDeviceCaps(ADC, LOGPIXELSX);
    if ACalculateHeight then
      AFormatRange.rc.Bottom := TwipsPerInch
    else
      AFormatRange.rc.Bottom := (ARect.Bottom - ARect.Top)(*65535*) * TwipsPerInch div GetDeviceCaps(ADC, LOGPIXELSY);
    AFormatRange.rcPage := AFormatRange.rc;
    AStartIndex := AFormatRange.chrg.cpMin;
    AFormatRange.chrg.cpMin := cxSendStructMessage(RichRenderer.Handle, EM_FORMATRANGE,
      WPARAM(not ACalculateHeight), AFormatRange);
    if AFormatRange.chrg.cpMin <= AStartIndex then
      Break;
    if ACalculateHeight then
      Inc(AHeight, AFormatRange.rc.Bottom - AFormatRange.rc.Top);
  until not ACalculateHeight;
  if ACalculateHeight then
    AHeight := AHeight * GetDeviceCaps(ADC, LOGPIXELSY) div TwipsPerInch;

  SendMessage(RichRenderer.Handle, EM_FORMATRANGE, 0, 0);
end;

procedure SetRichEditText(ARichEdit: TRichEdit; const AEditValue: TcxEditValue);
begin
  InternalSetRichEditText(ARichEdit, VarToStr(AEditValue));
end;

{ TcxRichEdit }

class function TcxRichEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxRichEditProperties;
end;

function TcxRichEdit.GetActiveProperties: TcxRichEditProperties;
begin
  Result := TcxRichEditProperties(InternalGetActiveProperties);
end;

function TcxRichEdit.GetProperties: TcxRichEditProperties;
begin
  Result := TcxRichEditProperties(FProperties);
end;

procedure TcxRichEdit.SetProperties(Value: TcxRichEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxRichInnerEditHelper }

constructor TcxRichInnerEditHelper.Create(AEdit: TcxRichInnerEdit);
begin
  inherited Create(nil);
  FEdit := AEdit;
  FEdit.PlainText := False;
  FEdit.WordWrap := False;
end;

function TcxRichInnerEditHelper.GetControl: TWinControl;
begin
  Result := Edit;
end;

procedure TcxRichInnerEditHelper.LockBounds(ALock: Boolean);
begin
  with Edit do
    if ALock then
      Inc(FLockBoundsCount)
    else
      if FLockBoundsCount > 0 then
        Dec(FLockBoundsCount);
end;

function TcxRichInnerEditHelper.GetOnChange: TNotifyEvent;
begin
  Result := Edit.OnChange;
end;

procedure TcxRichInnerEditHelper.SafelySetFocus;
var
  APrevAutoSelect: Boolean;
begin
  with Edit do
  begin
    APrevAutoSelect := AutoSelect;
    AutoSelect := False;
    SetFocus;
    AutoSelect := APrevAutoSelect;
  end;
end;

function TcxRichInnerEditHelper.CallDefWndProc(AMsg: UINT; WParam: WPARAM;
  LParam: LPARAM): LRESULT;
begin
  Result := CallWindowProc(Edit.DefWndProc, Edit.Handle, AMsg, WParam, LParam);
end;

function TcxRichInnerEditHelper.GetEditValue: TcxEditValue;
begin
  with Edit do
    Result := Text;
end;

procedure TcxRichInnerEditHelper.SetEditValue(const Value: TcxEditValue);
var
  AContainer: TcxCustomRichEdit;
begin
  AContainer := Edit.Container;
  if AContainer.PropertiesChange then
    Exit;

  if AContainer.ActiveProperties.MemoMode or not CanAllocateHandle(Edit) then
    Edit.Text := VarToStr(Value)
  else
  begin
    Edit.Container.LockChangeEvents(True);
    try
      Edit.HandleNeeded;
      LoadRichFromString(Edit.RichLines, VarToStr(Value));
    finally
      Edit.Container.LockChangeEvents(False);
    end;
  end;
end;

procedure TcxRichInnerEditHelper.SetParent(Value: TWinControl);
begin
  Edit.Parent := Value;
end;

procedure TcxRichInnerEditHelper.SetOnChange(Value: TNotifyEvent);
begin
  Edit.OnChange := Value;
end;

// IcxInnerTextEdit 
procedure TcxRichInnerEditHelper.ClearSelection;
begin
  Edit.ClearSelection;
end;

procedure TcxRichInnerEditHelper.CopyToClipboard;
begin
  Edit.CopyToClipboard;
end;

function TcxRichInnerEditHelper.GetAlignment: TAlignment;
begin
  Result := Edit.Alignment;
end;

function TcxRichInnerEditHelper.GetAutoSelect: Boolean;
begin
  Result := Edit.AutoSelect;
end;

function TcxRichInnerEditHelper.GetCharCase: TEditCharCase;
begin
  Result := Edit.CharCase;
end;

function TcxRichInnerEditHelper.GetEchoMode: TcxEditEchoMode;
begin
  Result := eemNormal;
end;

function TcxRichInnerEditHelper.GetFirstVisibleCharIndex: Integer;
var
  R: TRect;
begin
  SendMessage(Edit.Handle, EM_GETRECT, 0, Integer(@R));
  Result := SendMessage(Edit.Handle, EM_CHARFROMPOS, 0, LParam(@R.TopLeft));
end;

function TcxRichInnerEditHelper.GetHideSelection: Boolean;
begin
  Result := Edit.HideSelection;
end;

function TcxRichInnerEditHelper.GetInternalUpdating: Boolean;
begin
  Result := Edit.FInternalUpdating;
end;

function TcxRichInnerEditHelper.GetMaxLength: Integer;
begin
  Result := Edit.MaxLength;
end;

function TcxRichInnerEditHelper.GetMultiLine: Boolean;
begin
  Result := True;
end;

function TcxRichInnerEditHelper.GetOEMConvert: Boolean;
begin
  Result := Edit.OEMConvert;
end;

function TcxRichInnerEditHelper.GetOnSelChange: TNotifyEvent;
begin
  Result := Edit.OnSelectionChange;
end;

function TcxRichInnerEditHelper.GetPasswordChar: TCaptionChar;
begin
  Result := #0;
end;

function TcxRichInnerEditHelper.GetReadOnly: Boolean;
begin
  Result := Edit.ReadOnly;
end;

function TcxRichInnerEditHelper.GetSelLength: Integer;
begin
  Result := Edit.SelLength;
end;

function TcxRichInnerEditHelper.GetSelStart: Integer;
begin
  Result := Edit.SelStart;
end;

function TcxRichInnerEditHelper.GetSelText: string;
begin
  Result := Edit.SelText;
end;

procedure TcxRichInnerEditHelper.SelectAll;
begin
  with Edit do
    if HandleAllocated then
      SelectAll;
end;

procedure TcxRichInnerEditHelper.SetAlignment(Value: TAlignment);
begin
  Edit.Alignment := Value;
end;

procedure TcxRichInnerEditHelper.SetAutoSelect(Value: Boolean);
begin
  Edit.AutoSelect := Value;
end;

procedure TcxRichInnerEditHelper.SetCharCase(Value: TEditCharCase);
begin
  Edit.CharCase := Value;
end;

procedure TcxRichInnerEditHelper.SetEchoMode(Value: TcxEditEchoMode);
begin
end;

procedure TcxRichInnerEditHelper.SetHideSelection(Value: Boolean);
begin
  if not Edit.Container.IsInplace then
    Edit.HideSelection := Value;
end;

procedure TcxRichInnerEditHelper.SetInternalUpdating(Value: Boolean);
begin
  Edit.FInternalUpdating := Value;
end;

procedure TcxRichInnerEditHelper.SetImeMode(Value: TImeMode);
begin
  Edit.ImeMode := Value;
end;

procedure TcxRichInnerEditHelper.SetImeName(const Value: TImeName);
begin
  Edit.ImeName := Value;
end;

procedure TcxRichInnerEditHelper.SetMaxLength(Value: Integer);
begin
  Edit.MaxLength := Value;
end;

procedure TcxRichInnerEditHelper.SetOEMConvert(Value: Boolean);
begin
  Edit.OEMConvert := Value;
end;

procedure TcxRichInnerEditHelper.SetOnSelChange(Value: TNotifyEvent);
begin
  Edit.OnSelectionChange := Value;
end;

procedure TcxRichInnerEditHelper.SetPasswordChar(Value: TCaptionChar);
begin
end;

procedure TcxRichInnerEditHelper.SetReadOnly(Value: Boolean);
begin
  Edit.ReadOnly := Value;
end;

procedure TcxRichInnerEditHelper.SetSelLength(Value: Integer);
begin
  Edit.SelLength := Value;
end;

procedure TcxRichInnerEditHelper.SetSelStart(Value: Integer);
begin
  with Edit do
    SelStart := Value;
end;

procedure TcxRichInnerEditHelper.SetSelText(Value: string);
begin
  Edit.SelText := Value;
end;

function TcxRichInnerEditHelper.GetImeLastChar: Char;
begin
  Result := #0;
end;

function TcxRichInnerEditHelper.GetImeMode: TImeMode;
begin
  Result := Edit.ImeMode;
end;

function TcxRichInnerEditHelper.GetImeName: TImeName;
begin
  Result := Edit.ImeName;
end;

function TcxRichInnerEditHelper.GetControlContainer: TcxContainer;
begin
  Result := Edit.Container;
end;

// IcxInnerMemo
function TcxRichInnerEditHelper.GetCaretPos: TPoint;
begin
  Result := Edit.CaretPos;
end;

function TcxRichInnerEditHelper.GetLines: TStrings;
begin
  Result := Edit.Lines;
end;

function TcxRichInnerEditHelper.GetScrollBars: TScrollStyle;
begin
  Result := Edit.ScrollBars;
end;

function TcxRichInnerEditHelper.GetWantReturns: Boolean;
begin
  Result := Edit.WantReturns;
end;

function TcxRichInnerEditHelper.GetWantTabs: Boolean;
begin
  Result := Edit.WantTabs;
end;

function TcxRichInnerEditHelper.GetWordWrap: Boolean;
begin
  Result := Edit.WordWrap;
end;

{$IFDEF DELPHI12}
function TcxRichInnerEditHelper.GetTextHint: string;
begin
  Result := Edit.TextHint;
end;

procedure TcxRichInnerEditHelper.SetTextHint(Value: string);
begin
  Edit.TextHint := Value;
end;
{$ENDIF}

procedure TcxRichInnerEditHelper.SetCaretPos(const Value: TPoint);
begin
  SetMemoCaretPos(Edit, Value);
end;

procedure TcxRichInnerEditHelper.SetScrollBars(Value: TScrollStyle);
begin
  Edit.ScrollBars := Value;
end;

procedure TcxRichInnerEditHelper.SetWantReturns(Value: Boolean);
begin
  Edit.WantReturns := Value;
end;

procedure TcxRichInnerEditHelper.SetWantTabs(Value: Boolean);
begin
  Edit.WantTabs := Value;
end;

procedure TcxRichInnerEditHelper.SetWordWrap(Value: Boolean);
begin
  Edit.WordWrap := Value;
end;

{ TcxRichEditStrings }

constructor TcxRichEditStrings.Create(ARichEdit: TcxRichInnerEdit);
begin
  inherited Create;
  FRichEdit := ARichEdit;
  FTextType := SF_TEXT;
end;

destructor TcxRichEditStrings.Destroy;
begin
  FreeAndNil(FConverter);
  inherited Destroy;
end;

procedure TcxRichEditStrings.Clear;
begin
  if Count > 0 then
    RichEdit.Lines.Clear;
end;

function TcxRichEditStrings.CalcStreamTextType(AStreamOperation: TcxRichEditStreamOperation; ACustom: Boolean;
  ACustomStreamModes: TcxRichEditStreamModes): Longint;
var
  AStreamModes, AAllowStreamModes: TcxRichEditStreamModes;
begin
  if ACustom then
    AStreamModes := ACustomStreamModes
  else
    AStreamModes := GetStreamModes;
  if csDesigning in RichEdit.ComponentState then
  begin
    Result := SF_RTF;
    Exit;
  end;
  AAllowStreamModes := GetAllowStreamModesByStreamOperation(AStreamOperation);
  if RichEdit.MemoMode or RichEdit.PlainText then
  begin
    Result := SF_TEXT{$IFDEF DELPHI12} or SF_UNICODE{$ENDIF};
    if (resmUnicode in AStreamModes) and (resmUnicode in AAllowStreamModes) then
      Result := Result or SF_UNICODE;
    if (resmTextIzed in AStreamModes) and (resmTextIzed in AAllowStreamModes) then
      Result := SF_TEXTIZED;
  end
  else
  begin
    Result := SF_RTF;
    if (resmRtfNoObjs in AStreamModes) and (resmRtfNoObjs in AAllowStreamModes) then
      Result := SF_RTFNOOBJS;
    if (resmPlainRtf in AStreamModes) and (resmPlainRtf in AAllowStreamModes) then
      Result := Result or SFF_PLAINRTF;
  end;
  if (resmSelection in AStreamModes) and (resmSelection in AAllowStreamModes) then
    Result := Result or SFF_SELECTION;
end;

function TcxRichEditStrings.GetAllowStreamModesByStreamOperation(AStreamOperation: TcxRichEditStreamOperation): TcxRichEditStreamModes;
begin
  if AStreamOperation = esoSaveTo then
    Result := [resmSelection, resmPlainRtf, resmRtfNoObjs, resmUnicode, resmTextIzed]
  else
    Result := [resmSelection, resmPlainRtf, resmUnicode];
end;

function TcxRichEditStrings.GetStreamModes: TcxRichEditStreamModes;
begin
  Result := FRichEdit.StreamModes;
end;

procedure TcxRichEditStrings.AddStrings(Strings: TStrings);
var
  APrevSelectionChange: TNotifyEvent;
begin
  APrevSelectionChange := RichEdit.OnSelectionChange;
  RichEdit.OnSelectionChange := nil;
  try
    inherited AddStrings(Strings);
  finally
    RichEdit.OnSelectionChange := APrevSelectionChange;
  end;
end;

procedure TcxRichEditStrings.Delete(Index: Integer);
begin
  FRichEdit.Lines.Delete(Index);
end;

procedure TcxRichEditStrings.Insert(Index: Integer; const S: string);
var
  AFormat: string;
  AStr: PChar;
  ASelection: TCharRange;
begin
  if (Index < 0) or (Index > Count) then
    Exit;
  ASelection.cpMin := FRichEdit.GetLineIndex(Index);
  if ASelection.cpMin < 0 then
  begin
    ASelection.cpMin := FRichEdit.GetLineIndex(Index - 1);
    if ASelection.cpMin < 0 then
      ASelection.cpMin := 0
    else
      ASelection.cpMin := ASelection.cpMin + FRichEdit.GetLineLength(Index - 1);
    AFormat := GetLineBreakString + '%s';
  end
  else
    AFormat := '%s'+ GetLineBreakString;
  ASelection.cpMax := ASelection.cpMin;
  AStr := PChar(Format(AFormat, [S]));
  cxSendStructMessage(FRichEdit.Handle, EM_EXSETSEL, 0, ASelection);
  AdjustRichLineBreaks(AStr, PChar(Format(AFormat, [S])), Length(GetLineBreakString) = 1);
  SendMessage(FRichEdit.Handle, EM_REPLACESEL, 0, LongInt(AStr));
  if FRichEdit.SelStart <> (ASelection.cpMax + Length(AStr)) then
    raise EOutOfResources.Create(
      cxGetResourceString(@cxSEditRichEditLineInsertionError));
end;

procedure TcxRichEditStrings.LoadFromFile(const FileName: string{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF});
begin
  InitConverter(FileName);
  inherited LoadFromFile(FileName{$IFDEF DELPHI12}, Encoding{$ENDIF});
  FRichEdit.Container.EditModified := False
end;

procedure TcxRichEditStrings.LoadFromStream(Stream: TStream{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF});
var
  APos: Longint;
  AStreamOperationInfo: TcxRichEditStreamOperationInfo;
begin
  APos := Stream.Position;
  try
  {$IFDEF DELPHI12}
    AStreamOperationInfo.StreamInfo.Encoding := Encoding;
  {$ENDIF}
    InitStreamOperation(Stream, AStreamOperationInfo, esoLoadFrom);
    with AStreamOperationInfo do
    begin
      cxSendStructMessage(RichEdit.Handle, EM_STREAMIN, TextType, EditStream);
      if ((TextType and SF_RTF) = SF_RTF) and (EditStream.dwError <> 0) then
      begin
        Stream.Position := APos;
        TextType := SF_TEXT{$IFDEF DELPHI12} or SF_UNICODE{$ENDIF};
        cxSendStructMessage(RichEdit.Handle, EM_STREAMIN, TextType, EditStream);
      end;
      if EditStream.dwError <> 0 then
        raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditLoadFail));
      FTextType := TextType;
    end;
  finally
    if FConverter = nil then
      FreeAndNil(AStreamOperationInfo.StreamInfo.Converter);
  end;

  with FRichEdit do
    if Container <> nil then
      Container.EditModified := False;
end;

procedure TcxRichEditStrings.SaveToFile(const FileName: string{$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF});
begin
  InitConverter(FileName);
  inherited SaveToFile(FileName{$IFDEF DELPHI12}, Encoding{$ENDIF});
end;

procedure TcxRichEditStrings.SaveToStream(Stream: TStream
  {$IFDEF DELPHI12}; Encoding: TEncoding{$ENDIF});
var
  AStreamOperationInfo: TcxRichEditStreamOperationInfo;
{$IFDEF DELPHI12}
  APreamble: TBytes;
{$ENDIF}
begin
  try
  {$IFDEF DELPHI12}
    AStreamOperationInfo.StreamInfo.Encoding := Encoding;
  {$ENDIF}
    InitStreamOperation(Stream, AStreamOperationInfo, esoSaveTo);
  {$IFDEF DELPHI12}
    if (Encoding <> nil) and RichEdit.PlainText then
    begin
      APreamble := Encoding.GetPreamble;
      if Length(APreamble) > 0 then
        Stream.WriteBuffer(APreamble[0], Length(APreamble));
    end;
  {$ENDIF}
    with AStreamOperationInfo do
    begin
      cxSendStructMessage(RichEdit.Handle, EM_STREAMOUT, TextType, EditStream);
      if EditStream.dwError <> 0 then
        raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditSaveFail));
    end;
  finally
    if FConverter = nil then
      FreeAndNil(AStreamOperationInfo.StreamInfo.Converter);
  end;
end;

function TcxRichEditStrings.Get(Index: Integer): string;
begin
  Result := FRichEdit.Lines[Index];
  while (Length(Result) > 0) and dxCharInSet(Result[Length(Result)], [#10, #13]) do
    System.Delete(Result, Length(Result), 1);
end;

procedure TcxRichEditStrings.InitConverter(const AFileName: string);
var
  AExtension: string;
  AConversionFormat: PcxConversionFormat;
begin
  AExtension := AnsiLowerCaseFileName(ExtractFileExt(AFilename));
  System.Delete(AExtension, 1, 1);
  AConversionFormat := FConversionFormatList;
  while AConversionFormat <> nil do
    with AConversionFormat^ do
      if Extension <> AExtension then AConversionFormat := Next
      else Break;
  if AConversionFormat = nil then
    AConversionFormat := @TextConversionFormat;
  if (FConverter = nil) or
    (FConverter.ClassType <> AConversionFormat^.ConversionClass) then
  begin
    FreeAndNil(FConverter);
    FConverter := AConversionFormat^.ConversionClass.Create;
  end;
end;

procedure TcxRichEditStrings.InitStreamOperation(AStream: TStream;
  var AStreamOperationInfo: TcxRichEditStreamOperationInfo;
  AStreamOperation: TcxRichEditStreamOperation; ACustom: Boolean;
      ACustomStreamModes: TcxRichEditStreamModes);

{$IFDEF DELPHI12}
  function ContainsPreamble(AStream: TStream; ASignature: TBytes): Boolean;
  var
    ABuffer: TBytes;
    I, ALBufLen, ALSignatureLen, ALPosition: Integer;
  begin
    Result := True;
    ALSignatureLen := Length(ASignature);
    ALPosition := AStream.Position;
    try
      SetLength(ABuffer, ALSignatureLen);
      ALBufLen := AStream.Read(ABuffer[0], ALSignatureLen);
    finally
      AStream.Position := ALPosition;
    end;

    if ALBufLen = ALSignatureLen then
    begin
      for I := 1 to ALSignatureLen do
        if ABuffer[I - 1] <> ASignature [I - 1] then
        begin
          Result := False;
          Break;
        end;
    end
    else
      Result := False;
  end;

  function GetEncoding: TEncoding;
  begin
    if ContainsPreamble(AStream, TEncoding.Unicode.GetPreamble) then
      Result := TEncoding.Unicode
    else
      if ContainsPreamble(AStream, TEncoding.BigEndianUnicode.GetPreamble) then
        Result := TEncoding.BigEndianUnicode
      else
        if ContainsPreamble(AStream, TEncoding.UTF8.GetPreamble) then
          Result := TEncoding.UTF8
        else
          Result := TEncoding.Default;
  end;
{$ENDIF}

var
  AConverter: TConversion;
begin
  if FConverter <> nil then
    AConverter := FConverter
  else
    AConverter := RichEdit.DefaultConverter.Create;
  with AStreamOperationInfo do
  begin
  {$IFDEF DELPHI12}
    if (StreamInfo.Encoding = nil) and (AStreamOperation = esoLoadFrom) then
      StreamInfo.Encoding := GetEncoding;
    StreamInfo.PlainText := RichEdit.PlainText;
  {$ENDIF}
    StreamInfo.Converter := AConverter;
    StreamInfo.Stream := AStream;
    EditStream.dwCookie := Longint(Pointer(@StreamInfo));
    EditStream.dwError := 0;
    if AStreamOperation = esoLoadFrom then
      EditStream.pfnCallBack := @cxRichEditStreamLoad
    else
      EditStream.pfnCallBack := @cxRichEditStreamSave;
    TextType := CalcStreamTextType(AStreamOperation, ACustom, ACustomStreamModes);
  end;
end;

function TcxRichEditStrings.GetCount: Integer;
begin
  Result := RichEdit.GetLineCount;
  if (Result > 0) and (RichEdit.GetLineLength(Result - 1) = 0) then
    Dec(Result);
end;

procedure TcxRichEditStrings.Put(Index: Integer; const S: string);
begin
  TStringsAccess(FRichEdit.Lines).Put(Index, S);
end;

procedure TcxRichEditStrings.SetUpdateState(Updating: Boolean);
begin
  TStringsAccess(FRichEdit.Lines).SetUpdateState(Updating);
end;

procedure TcxRichEditStrings.SetTextStr(const Value: string);
begin
  FRichEdit.Container.Text := Value;
end;

function TcxRichEditStrings.GetLineBreakString: string;
begin
  if FRichEdit.RichVersion >= 200 then
    Result := #13
  else
    Result := #13#10
end;

{ TcxRichInnerEdit }

constructor TcxRichInnerEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentColor := True;
  ParentFont := True;
  FAllowObjects := False;
  FAutoURLDetect := False;
  FEchoMode := eemNormal;
  FHelper := TcxRichInnerEditHelper.Create(Self);
  FInternalUpdating := False;
  FRichLines := TcxRichEditStrings.Create(Self);
  FStreamModes := [];
  FUseCRLF := True;
  FRichEditOleCallback := TcxRichEditOleCallback.Create(Self);
  RichEditClass := recRichEdit20;
end;

destructor TcxRichInnerEdit.Destroy;
begin
  CloseOleObjects;
  FRichEditOle := nil;
  FreeAndNil(FRichLines);
  FreeAndNil(FHelper);
  inherited Destroy;
  FreeAndNil(FRichEditOleCallBack);
end;

procedure TcxRichInnerEdit.DefaultHandler(var Message);
begin
  if (Container = nil) or not Container.InnerControlDefaultHandler(TMessage(Message)) then
    inherited DefaultHandler(Message);
end;

procedure TcxRichInnerEdit.DragDrop(Source: TObject; X, Y: Integer);
begin
  Container.DragDrop(Source, Left + X, Top + Y);
end;

function TcxRichInnerEdit.ExecuteAction(Action: TBasicAction): Boolean;
begin
  Result := inherited ExecuteAction(Action) or (Container <> nil) and
    Container.DataBinding.ExecuteAction(Action);
end;

function TcxRichInnerEdit.FindText(const ASearchStr: string;
  AStartPos, ALength: Longint; AOptions: TSearchTypes): Integer;

  function GetFindTextFlags: Integer;
  begin
    Result := FR_DOWN;
    if stWholeWord in AOptions then
      Result := Result or {$IFDEF DELPHI12}FR_WHOLEWORD{$ELSE}FT_WHOLEWORD{$ENDIF};
    if stMatchCase in AOptions then
      Result := Result or {$IFDEF DELPHI12}FR_MATCHCASE{$ELSE}FT_MATCHCASE{$ENDIF};
  end;

  procedure PrepareCharRange(var ACharRange: TCharRange);
  begin
    ACharRange.cpMin := AStartPos;
    ACharRange.cpMax := AStartPos + ALength;
  end;

var
  AFindText: TFindText;
  AFindTextW: TFindTextW;
begin
  if RichVersion >= 200 then
  begin
    PrepareCharRange(AFindTextW.Chrg);
    AFindTextW.lpstrText := PWideChar(dxStringToWideString(ASearchStr));
    Result := cxSendStructMessage(Handle, EM_FINDTEXT, GetFindTextFlags, AFindTextW);
  end
  else
  begin
    PrepareCharRange(AFindText.Chrg);
    AFindText.lpstrText := PChar(ASearchStr);
    Result := cxSendStructMessage(Handle, EM_FINDTEXT, GetFindTextFlags, AFindText);
  end;
end;

function TcxRichInnerEdit.InsertObject: Boolean;
var
  AData: {$IFDEF DELPHI12}TOleUIInsertObjectA{$ELSE}TOleUIInsertObject{$ENDIF};
  ANameBuffer: array[0..255] of AnsiChar;
  AOleClientSite: IOleClientSite;
  AStorage: IStorage;
  AReObject: TReObject;
  AOleObject: IOleObject;
  ASelection: TCharRange;
  AIsNewObject: Boolean;
begin
  Result := False;
  if not FAllowObjects or not Assigned(FRichEditOle) then
    Exit;
  FillChar(AData, SizeOf(AData), 0);
  FillChar(ANameBuffer, SizeOf(ANameBuffer), 0);
  AStorage := nil;
  try
    cxCreateStorage(AStorage);
    RichEditOle.GetClientSite(AOleClientSite);
    with AData do
    begin
      cbStruct := SizeOf(AData);
      dwFlags := IOF_SELECTCREATENEW or IOF_VERIFYSERVERSEXIST or
        IOF_CREATENEWOBJECT or IOF_CREATEFILEOBJECT or IOF_CREATELINKOBJECT;
      hWndOwner := Handle;
      lpfnHook := cxOleDialogHook;
      lpszFile := ANameBuffer;
      cchFile := SizeOf(ANameBuffer);
      oleRender := OLERENDER_DRAW;
      iid := IOleObject;
      lpIOleClientSite := AOleClientSite;
      lpIStorage := AStorage;
      ppvObj := @AOleObject;
    end;
    if {$IFDEF DELPHI12}OleUIInsertObjectA{$ELSE}OleUIInsertObject{$ENDIF}(AData) = OLEUI_OK then
      try
        AIsNewObject := AData.dwFlags and IOF_SELECTCREATENEW = IOF_SELECTCREATENEW;
        FillChar(AReObject, SizeOf(AReObject), 0);
        with AReObject do
        begin
          cbStruct := SizeOf(AReObject);
          cp := REO_CP_SELECTION;
          clsid := AData.clsid;
          oleobj := AOleObject;
          stg := AStorage;
          olesite := AOleClientSite;
          dvaspect := DVASPECT_CONTENT;
          dwFlags := REO_RESIZABLE;
          if AIsNewObject then
            dwFlags := dwFlags or REO_BLANK;
          OleCheck(cxSetDrawAspect(AOleObject, AData.dwFlags and IOF_CHECKDISPLAYASICON <> 0,
            AData.hMetaPict, dvaspect));
        end;
        if HandleAllocated then
        begin
          SendMessage(Handle, EM_EXGETSEL, 0, Longint(@ASelection));
          ASelection.cpMax := ASelection.cpMin + 1;
        end;
        if Succeeded(RichEditOle.InsertObject(AReObject)) then
        begin
          if HandleAllocated then
          begin
            SendMessage(Handle, EM_EXSETSEL, 0, Longint(@ASelection));
            SendMessage(Handle, EM_SCROLLCARET, 0, 0);
          end;
          RichEditOle.SetDvaspect(Longint(REO_IOB_SELECTION), AReObject.dvaspect);
          if AIsNewObject then OleCheck(AReObject.oleobj.DoVerb(OLEIVERB_SHOW, nil,
            AOleClientSite, 0, Handle, ClientRect));
          Result := True;
        end;
      finally
        DestroyMetaPict(AData.hMetaPict);
        ReleaseObject(AOleObject);
        ZeroMemory(@AReObject,SizeOf(AReObject));
      end;
  finally
    ZeroMemory(@AData,SizeOf(AData));
  end;
end;

function TcxRichInnerEdit.ShowObjectProperties: Boolean;
var
  AObjectProps: TOleUIObjectProps;
  APropSheet: TPropSheetHeader;
  AGeneralProps: TOleUIGnrlProps;
  AViewProps: TOleUIViewProps;
  ALinkProps: TOleUILinkProps;
  ADialogCaption: string;
  AReObject: TReObject;
begin
  Result := False;
  if not Assigned(FRichEditOle) or
      (RichEditOle.GetObjectCount <= 0) then
    Exit;
  if HandleAllocated and
      not (SendMessage(Handle, EM_SELECTIONTYPE, 0, 0) in [SEL_OBJECT, SEL_MULTIOBJECT]) then
    Exit;
  FillChar(AObjectProps, SizeOf(AObjectProps), 0);
  FillChar(APropSheet, SizeOf(APropSheet), 0);
  FillChar(AGeneralProps, SizeOf(AGeneralProps), 0);
  FillChar(AViewProps, SizeOf(AViewProps), 0);
  FillChar(ALinkProps, SizeOf(ALinkProps), 0);
  AReObject.cbStruct := SizeOf(AReObject);
  OleCheck(RichEditOle.GetObject(Longint(REO_IOB_SELECTION), AReObject, REO_GETOBJ_POLEOBJ or
    REO_GETOBJ_POLESITE or REO_GETOBJ_PSTG));
  with AObjectProps do
  begin
    cbStruct := SizeOf(AObjectProps);
    dwFlags := 0;
    lpPS := @APropSheet;
    lpObjInfo := TcxOleUIObjInfo.Create(Self, AReObject);
    if (AReObject.dwFlags and REO_LINK) <> 0 then
    begin
      dwFlags := AObjectProps.dwFlags or OPF_OBJECTISLINK;
      lpLinkInfo := TcxOleUILinkInfo.Create(Self, AReObject);
    end;
    lpGP := @AGeneralProps;
    lpVP := @AViewProps;
    lpLP := @ALinkProps;
  end;
  with APropSheet do
  begin
    dwSize := SizeOf(APropSheet);
    hWndParent := Application.Handle;
    hInstance := MainInstance;
    ADialogCaption := Format(SPropDlgCaption, [cxGetOleObjectFullName(AReObject.oleobj)]);
    pszCaption := PChar(ADialogCaption);
   end;
  AGeneralProps.cbStruct := SizeOf(AGeneralProps);
  AGeneralProps.lpfnHook := cxOleDialogHook;
  with AViewProps do
  begin
    cbStruct := SizeOf(AViewProps);
    dwFlags := VPF_DISABLESCALE;
  end;
  ALinkProps.cbStruct := SizeOf(ALinkProps);
  ALinkProps.dwFlags := ELF_DISABLECANCELLINK;
  Result := Container.CanModify and Container.DoEditing and
    (OleUIObjectProperties(AObjectProps) = OLEUI_OK);
  ZeroMemory(@AObjectProps, SizeOf(AObjectProps));
  ZeroMemory(@APropSheet, SizeOf(APropSheet));
  ZeroMemory(@AGeneralProps, SizeOf(AGeneralProps));
  ZeroMemory(@AViewProps, SizeOf(AViewProps));
  ZeroMemory(@ALinkProps, SizeOf(ALinkProps));
  ZeroMemory(@AReObject, SizeOf(AReObject));
end;

function TcxRichInnerEdit.PasteSpecial: Boolean;

  procedure SetPasteFormats(var APasteFormat: TOleUIPasteEntry; AFormat: TClipFormat;
    Atymed: DWORD; const AFormatName, AResultText: string; AFlags: DWORD);
  begin
    with APasteFormat do begin
      fmtetc.cfFormat := AFormat;
      fmtetc.dwAspect := DVASPECT_CONTENT;
      fmtetc.lIndex := -1;
      fmtetc.tymed := Atymed;
      if AFormatName <> '' then
        lpstrFormatName := PChar(AFormatName)
      else
        lpstrFormatName := '%s';
      if AResultText <> '' then
        lpstrResultText := PChar(AResultText)
      else
        lpstrResultText := '%s';
      dwFlags := AFlags;
    end;
  end;

var
  AData: TOleUIPasteSpecial;
  APasteFormats: array[0..cxPasteFormatCount - 1] of TOleUIPasteEntry;
  AFormat: Integer;
  AReObject: TReObject;
  AClientSite: IOleClientSite;
  AStorage: IStorage;
  AOleObject: IOleObject;
  ASelection: TCharRange;
begin
  Result := False;
  if not CanPaste then Exit;
  if not Assigned(FRichEditOle) then Exit;
  FillChar(AData, SizeOf(AData), 0);
  FillChar(APasteFormats, SizeOf(APasteFormats), 0);
  with AData do
  begin
    cbStruct := SizeOf(AData);
    dwFlags := PSF_SELECTPASTE;
    hWndOwner := Application.Handle;
    lpfnHook := cxOleDialogHook;
    arrPasteEntries := @APasteFormats;
    cPasteEntries := cxPasteFormatCount;
    arrLinkTypes := @CFLinkSource;
    cLinkTypes := 1;
  end;
  SetPasteFormats(APasteFormats[0], CFEmbeddedObject, TYMED_ISTORAGE,
    '%s', '%s', OLEUIPASTE_PASTE or OLEUIPASTE_ENABLEICON);
  SetPasteFormats(APasteFormats[1], CFLinkSource, TYMED_ISTREAM,
    '%s', '%s', OLEUIPASTE_LINKTYPE1 or OLEUIPASTE_ENABLEICON);
  SetPasteFormats(APasteFormats[2], CF_BITMAP, TYMED_GDI,
    'Windows bitmap', 'bitmap image', OLEUIPASTE_PASTE);
  SetPasteFormats(APasteFormats[3], CFRtf, TYMED_ISTORAGE,
    CF_RTF, CF_RTF, OLEUIPASTE_PASTE);
  SetPasteFormats(APasteFormats[4], CF_TEXT, TYMED_HGLOBAL,
    'Unformatted text', 'text without any formatting', OLEUIPASTE_PASTE);
  SetPasteFormats(APasteFormats[5], CFRETextObj, TYMED_ISTORAGE,
    CF_RETEXTOBJ, CF_RETEXTOBJ, OLEUIPASTE_PASTE);
  try
    if OleUIPasteSpecial(AData) = OLEUI_OK then
    begin
      if AData.nSelectedIndex in [0, 1] then // CFEmbeddedObject, CFLinkSource
      begin
        FillChar(AReObject, SizeOf(AReObject), 0);
        RichEditOle.GetClientSite(AClientSite);
        cxCreateStorage(AStorage);
        try
          case AData.nSelectedIndex of
            0: {CFEmbeddedObject}
              OleCheck(OleCreateFromData(AData.lpSrcDataObj, IOleObject,
               OLERENDER_DRAW, nil, AClientSite, AStorage, AOleObject));
            1: {CFLinkSource}
              OleCheck(OleCreateLinkFromData(AData.lpSrcDataObj, IOleObject,
               OLERENDER_DRAW, nil, AClientSite, AStorage, AOleObject));
          end;
          try
            with AReObject do
            begin
              cbStruct := SizeOf(AReObject);
              cp := REO_CP_SELECTION;
              oleobj := AOleObject;
              AOleObject.GetUserClassID(clsid);
              stg := AStorage;
              olesite := AClientSite;
              dvaspect := DVASPECT_CONTENT;
              dwFlags := REO_RESIZABLE;
              OleCheck(cxSetDrawAspect(oleobj,
                AData.dwFlags and PSF_CHECKDISPLAYASICON <> 0,
                AData.hMetaPict, dvaspect));
            end;
            SendMessage(Handle, EM_EXGETSEL, 0, Longint(@ASelection));
            ASelection.cpMax := ASelection.cpMin + 1;
            if Succeeded(RichEditOle.InsertObject(AReObject)) then
            begin
              SendMessage(Handle, EM_EXSETSEL, 0, Longint(@ASelection));
              OleCheck(RichEditOle.SetDvaspect(Longint(REO_IOB_SELECTION), AReObject.dvaspect));
            end;
          finally
            ZeroMemory(@AReObject, SizeOf(AReObject));
          end;
        finally
          ReleaseObject(AClientSite);
          ReleaseObject(AStorage);
        end;
      end
      else
      begin
        AFormat := APasteFormats[AData.nSelectedIndex].fmtetc.cfFormat;
        if not Succeeded(RichEditOle.ImportDataObject(AData.lpSrcDataObj,
            AFormat, AData.hMetaPict)) then
          Exit;
      end;
      Result := True;
    end;
  finally
    DestroyMetaPict(AData.hMetaPict);
    ReleaseObject(AData.lpSrcDataObj);
    ZeroMemory(@AData, SizeOf(AData));
  end;
end;

procedure TcxRichInnerEdit.Print(const Caption: string);
var
  AIsCRLFUsed: Boolean;
begin
  AIsCRLFUsed := FUseCRLF;
  FUseCRLF := False;
  try
    inherited;
  finally
    FUseCRLF := AIsCRLFUsed;
  end;
end;

procedure TcxRichInnerEdit.BeforeInsertObject(var AAllowInsertObject: Boolean;
  const ACLSID: TCLSID);
begin
  if Assigned(OnQueryInsertObject) then
    OnQueryInsertObject(Container, AAllowInsertObject, ACLSID);
end;

procedure TcxRichInnerEdit.Click;
begin
  inherited Click;
  _TcxContainerAccess.Click(Container);
end;

procedure TcxRichInnerEdit.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  RichCreateParams(Params, FRichVersion);
  with Params.WindowClass do
    style := style or CS_VREDRAW or CS_HREDRAW;
  if SelectionBar then
    Params.Style := Params.Style or ES_SELECTIONBAR;
  Params.Style := Params.Style or WS_CLIPSIBLINGS or WS_CLIPCHILDREN;
end;

procedure TcxRichInnerEdit.CreateWindowHandle(const Params: TCreateParams);
begin
  inherited CreateWindowHandle(Params);
  if FAllowObjects then
  begin
    if not cxRichEditGetOleInterface(Self, IcxRichEditOle(FRichEditOle)) then
      raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditOleInterfaceFail));
    if not cxRichEditSetOleCallback(Self, RichEditOlecallback) then
      raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditCallBackFail));
  end;
  if HandleAllocated then
    SendMessage(Handle, EM_AUTOURLDETECT, Longint(FAutoURLDetect and not MemoMode and ((Container = nil) or not Container.IsDesigning)), 0);
end;

procedure TcxRichInnerEdit.DestroyWindowHandle;
begin
  SetOleControlActive(False);
  CloseOleObjects;
  FRichEditOle := nil;
  inherited DestroyWindowHandle;
end;

procedure TcxRichInnerEdit.CreateWnd;
begin
  if Container <> nil then
  begin
    Alignment := Container.ActiveProperties.Alignment;
    Container.ClearSavedChildControlRegions;
    PlainText := FSavedPlainText;
  end;
  inherited CreateWnd;
  if Container <> nil then
    PlainText := Container.ActiveProperties.PlainText or Container.ActiveProperties.MemoMode;
  SendMessage(Handle, EM_SETEVENTMASK, 0, ENM_CHANGE or ENM_SELCHANGE or ENM_IMECHANGE or
    ENM_REQUESTRESIZE or ENM_PROTECTED or ENM_KEYEVENTS or ENM_LINK or ENM_LANGCHANGE or
    ENM_OBJECTPOSITIONS);
  if MaxLength = 0 then
    SendMessage(Handle, EM_EXLIMITTEXT, 0, MaxLongint);
  InternalSetMemoMode;
end;

procedure TcxRichInnerEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if FLockBoundsCount = 0 then
    inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

function TcxRichInnerEdit.UpdateAction(Action: TBasicAction): Boolean;
begin
  Result := inherited UpdateAction(Action) or (Container <> nil) and
    Container.DataBinding.UpdateAction(Action);
end;

function TcxRichInnerEdit.CanFocus: Boolean;
begin
  if Container = nil then
    Result := inherited CanFocus
  else
    Result := Container.CanFocus;
end;

function TcxRichInnerEdit.CanRedo: Boolean;
begin
  Result := False;
  if HandleAllocated then
    Result := SendMessage(Handle, EM_CANREDO, 0, 0) <> 0;
end;

procedure TcxRichInnerEdit.Redo;
begin
  if HandleAllocated then
    SendMessage(Handle, EM_REDO, 0, 0);
end;

procedure TcxRichInnerEdit.Undo;
begin
  if HandleAllocated then
    SendMessage(Handle, EM_UNDO, 0, 0);
end;

procedure TcxRichInnerEdit.DblClick;
begin
  inherited DblClick;
  _TcxContainerAccess.DblClick(Container);
end;

procedure TcxRichInnerEdit.DestroyWnd;
begin
  FSavedPlainText := PlainText;
  CloseOleObjects;
  FRichEditOle := nil;
  inherited DestroyWnd;
end;

procedure TcxRichInnerEdit.DragOver(Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  _TcxContainerAccess.DragOver(Container, Source, Left + X, Top + Y, State, Accept);
end;

function TcxRichInnerEdit.GetSelText: string;
var
  ALen: Integer;
  AResult: WideString;
begin
  if RichVersion >= 200 then
  begin
    SetLength(AResult, GetSelLength + 1);
    ALen := SendMessageW(Handle, EM_GETSELTEXT, 0, Longint(PWideChar(AResult)));
    Result := dxWideStringToString(AResult);
  end
  else
  begin
    SetLength(Result, GetSelLength + 1);
    ALen := SendMessage(Handle, EM_GETSELTEXT, 0, Longint(PChar(Result)));
  end;
  SetLength(Result, ALen);
end;

procedure TcxRichInnerEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  FInternalUpdating := False;
  _TcxContainerAccess.KeyDown(Container, Key, Shift);
  if Key = 0 then
    FInternalUpdating := True
  else
    inherited KeyDown(Key, Shift);
  if (Key = VK_RETURN) and Assigned(dxISpellChecker) then
    Invalidate;
  if (RichVersion >= 200) and (Key = VK_RETURN) and not WantReturns and
    not(ssCtrl in InternalGetShiftState) then
  begin
    Key := 0;
    Exit;
  end;
end;

procedure TcxRichInnerEdit.KeyPress(var Key: Char);
begin
  FInternalUpdating := False;
// Ctrl+I calls KeyPress with Key = Char(VK_TAB). A tab must be inserted even when WantTabs = False
//  if not WantTabs and (Key = Char(VK_TAB)) then
//    Key := #0;
  _TcxContainerAccess.KeyPress(Container, Key);
  if Key = #0 then
    FInternalUpdating := True
  else
    inherited KeyPress(Key);
end;

procedure TcxRichInnerEdit.KeyUp(var Key: Word; Shift: TShiftState);
begin
  FInternalUpdating := False;
  if not WantTabs and ((Key = VK_TAB)) then
    Key := 0;
  _TcxContainerAccess.KeyUp(Container, Key, Shift);
  if Key = 0 then
    FInternalUpdating := True
  else
    inherited KeyUp(Key, Shift);
end;

procedure TcxRichInnerEdit.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  _TcxContainerAccess.MouseDown(Container, Button, Shift, X + Left, Y + Top);
end;

procedure TcxRichInnerEdit.MouseLeave(AControl: TControl);
begin
  Container.ShortRefreshContainer(True);
end;

procedure TcxRichInnerEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseMove(Shift, X, Y);
  _TcxContainerAccess.MouseMove(Container, Shift, X + Left, Y + Top);
end;

procedure TcxRichInnerEdit.MouseUp(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  _TcxContainerAccess.MouseUp(Container, Button, Shift, X + Left, Y + Top);
end;

procedure TcxRichInnerEdit.RequestAlign;
begin
end;

procedure TcxRichInnerEdit.RequestSize(const Rect: TRect);
var
  R: TRect;
begin
  if Container <> nil then
  begin
    R := Rect;
    Dec(R.Left, Left);
    Dec(R.Top, Top);
    Inc(R.Right, Container.Width - Width - Left);
    Inc(R.Bottom, Container.Height - Height - Top);
    OffsetRect(R, Container.Left, Container.Top);
    Container.DoOnResizeRequest(R);
  end;
end;

procedure TcxRichInnerEdit.RichCreateParams(var Params: TCreateParams;
  out ARichVersion: Integer);
var
  ARichClassName: string;
  AWndClass: TWndClass;
  I: Integer;
  ARichClass: TcxRichEditClass;
begin
  if FRichEditLibrary = 0 then
    for I := High(cxRichEditDLLNames) downto Low(cxRichEditDLLNames) do
    begin
      FRichEditLibrary := LoadLibrary(PChar(cxRichEditDLLNames[I]));
      if FRichEditLibrary <> 0 then
        Break;
    end;
  if FRichEditLibrary = 0 then
    raise EcxEditError.Create(cxGetResourceString(@cxSEditRichEditLibraryError));

  for ARichClass := RichEditClass downto cxMinVersionRichEditClass do
  begin
    ARichClassName := cxRichEditClassNames[ARichClass];
    if GetClassInfo(HInstance, PChar(ARichClassName), AWndClass) then
      Break;
  end;

  if GetClassInfo(HInstance, PChar(ARichClassName), AWndClass) then
    ARichVersion := cxRichEditVersions[ARichClass]
  else
    raise EcxEditError.Create(cxGetResourceString(@cxSEditRichEditLibraryError));
  CreateSubClass(Params, PChar(ARichClassName));
end;

procedure TcxRichInnerEdit.SelectionChange;
begin
  inherited SelectionChange;
  if Container <> nil then
    Container.DoOnSelectionChange;
end;

procedure TcxRichInnerEdit.URLClick(const AURLText: string; AButton: TMouseButton);
begin
  if Assigned(Container.ActiveProperties.OnURLClick) then
    Container.ActiveProperties.OnURLClick(Container, AURLText, AButton);
end;

procedure TcxRichInnerEdit.URLMove(const AURLText: string);
begin
  if Assigned(Container.ActiveProperties.OnURLMove) then
    Container.ActiveProperties.OnURLMove(Container, AURLText);
end;

procedure TcxRichInnerEdit.WndProc(var Message: TMessage);
begin
  if (Container <> nil) then
    if Container.InnerControlMenuHandler(Message) then
      Exit;
  if ((Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONDBLCLK)) and
    (Container.DragMode = dmAutomatic) and not Container.IsDesigning then
  begin
    _TcxContainerAccess.BeginAutoDrag(Container);
    Exit;
  end;
  inherited WndProc(Message);
end;

function TcxRichInnerEdit.CanPaste: Boolean;
begin
  Result := HandleAllocated and
    (SendMessage(Handle, EM_CANPASTE, 0, 0) <> 0);
end;

function TcxRichInnerEdit.GetSelection: TCharRange;
begin
  cxSendStructMessage(Handle, EM_EXGETSEL, 0, Result);
end;

function TcxRichInnerEdit.GetAutoURLDetect: Boolean;
begin
  Result := FAutoURLDetect;
  if HandleAllocated and not (csDesigning in ComponentState) then
    Result := Boolean(SendMessage(Handle, EM_GETAUTOURLDETECT, 0, 0));
end;

procedure TcxRichInnerEdit.CloseOleObjects;
var
  I: Integer;
  AReObject: TReObject;
begin
  if Assigned(FRichEditOle) then
  begin
    FillChar(AReObject, SizeOf(AReObject), 0);
    AReObject.cbStruct := SizeOf(AReObject);
    with IcxRichEditOle(FRichEditOle) do
    begin
      for I := GetObjectCount - 1 downto 0 do
        if Succeeded(GetObject(I, AReObject, REO_GETOBJ_POLEOBJ)) then
        begin
          if AReObject.dwFlags and REO_INPLACEACTIVE <> 0 then
            InPlaceDeactivate;
          AReObject.oleobj.Close(OLECLOSE_NOSAVE);
        end;
    end;
  end;
end;

//IcxContainerInnerControl
function TcxRichInnerEdit.GetControl: TWinControl;
begin
  Result := Self;
end;

function TcxRichInnerEdit.GetControlContainer: TcxContainer;
begin
  Result := Container;
end;

// IcxInnerEditHelper
function TcxRichInnerEdit.GetHelper: IcxCustomInnerEdit;
begin
  Result := Helper;
end;

function TcxRichInnerEdit.GetContainer: TcxCustomRichEdit;
begin
  if Parent is TcxCustomRichEdit then
    Result := TcxCustomRichEdit(Parent)
  else
    Result := nil;
end;

function TcxRichInnerEdit.GetLineCount: Integer;
begin
  Result := SendMessage(Handle, EM_GETLINECOUNT, 0, 0);
end;

function TcxRichInnerEdit.GetLineIndex(AIndex: Integer): Integer;
begin
  Result := SendMessage(Handle, EM_LINEINDEX , AIndex, 0);
end;

function TcxRichInnerEdit.GetLineLength(AIndex: Integer): Integer;
begin
  if GetLineIndex(AIndex) <> -1 then
    Result := SendMessage(Handle, EM_LINELENGTH, GetLineIndex(AIndex), 0)
  else
    Result := 0;
end;

function TcxRichInnerEdit.GetRichLines: TcxRichEditStrings;
begin
  Result := FRichLines;
end;

function TcxRichInnerEdit.GetRichEditOle: IcxRichEditOle;
begin
  if FRichEditOle <> nil then
    Result := FRichEditOle as IcxRichEditOle
  else
    Result := nil;
end;

function TcxRichInnerEdit.GetRichEditOleCallBack: TcxRichEditOleCallback;
begin
  if Assigned(FRichEditOleCallback) then
    Result := FRichEditOleCallback as TcxRichEditOleCallback
  else
    Result := nil;
end;

function TcxRichInnerEdit.GetTextRange(AStartPos, AEndPos: Longint): string;
var
  ATextRange: TcxTextRange;
begin
  SetLength(Result, AEndPos - AStartPos + 1);
  ATextRange.chrg.cpMin := AStartPos;
  ATextRange.chrg.cpMax := AEndPos;
  ATextRange.lpstrText := PChar(Result);
  SetLength(Result, SendMessage(Handle, EM_GETTEXTRANGE, 0, Longint(@ATextRange)));
end;

procedure TcxRichInnerEdit.InternalSetMemoMode(AForcedReload: Boolean);
var
  AText: string;
  ATextMode: LRESULT;
begin
  if not HandleAllocated then
    Exit;
  ATextMode := SendMessage(Handle, EM_GETTEXTMODE, 0, 0);
  if MemoMode and (ATextMode and TM_PLAINTEXT <> 0) or
    not MemoMode and (ATextMode and TM_RICHTEXT <> 0) and
    not AForcedReload then
      Exit;
  AText := Text;
  SendMessage(Handle, WM_SETTEXT, 0, 0);
  if MemoMode then
    ATextMode := ATextMode and not TM_RICHTEXT or TM_PLAINTEXT
  else
    ATextMode := ATextMode and not TM_PLAINTEXT or TM_RICHTEXT;
  SendMessage(Handle, EM_SETTEXTMODE, ATextMode, 0);
  Text := AText;
end;

procedure TcxRichInnerEdit.SetAllowObjects(Value: Boolean);
begin
  if FAllowObjects <> Value then
  begin
    FAllowObjects := Value;
    if not FAllowObjects then
    begin
      CloseOleObjects;
      FRichEditOle := nil;
    end;
    RecreateWnd;
  end;
end;

procedure TcxRichInnerEdit.SetAutoURLDetect(Value: Boolean);
begin
  if Value <> FAutoURLDetect then
  begin
    FAutoURLDetect := Value;
    RecreateWnd;
  end;
end;

procedure TcxRichInnerEdit.SetMemoMode(Value: Boolean);
begin
  if Value <> FMemoMode then
  begin
    FMemoMode := Value;
    RecreateWnd;
  end;
end;

procedure TcxRichInnerEdit.SetRichEditClass(AValue: TcxRichEditClass);
begin
  if AValue <> FRichEditClass then
  begin
    FRichEditClass := AValue;
    RecreateWnd;
  end;
end;

procedure TcxRichInnerEdit.SetRichLines(Value: TcxRichEditStrings);
begin
  FRichLines.Assign(Value);
end;

procedure TcxRichInnerEdit.SetSelectionBar(Value: Boolean);
begin
  if Value <> FSelectionBar then
  begin
    FSelectionBar := Value;
    RecreateWnd;
  end;
end;

procedure TcxRichInnerEdit.SetOleControlActive(AActive: Boolean);
var
  AForm: TCustomForm;
begin
  try
    AForm := GetParentForm(Self);
    if AForm <> nil then
      if AActive and Container.CanModify and Container.DoEditing then
      begin
        if (AForm.ActiveOleControl <> nil) and (AForm.ActiveOleControl <> Self) then
          AForm.ActiveOleControl.Perform(CM_UIDEACTIVATE, 0, 0);
        AForm.ActiveOleControl := Self;
        if AllowObjects and CanFocus then SetFocus;
      end
      else
      begin
        if AForm.ActiveOleControl = Self then
          AForm.ActiveOleControl := nil;
        if (AForm.ActiveControl = Self) and AllowObjects then
        begin
          Windows.SetFocus(Handle);
          SelectionChange;
        end;
      end;
  except
    Application.HandleException(Self);
  end;
end;

procedure TcxRichInnerEdit.WMClear(var Message: TMessage);
begin
  if (Self.SelLength > 0) and Container.DoEditing then
    inherited;
end;

procedure TcxRichInnerEdit.WMCut(var Message: TMessage);
begin
  if SelLength > 0 then
    if Container.DoEditing then
      inherited
    else
      Container.CopyToClipboard;
end;

procedure TcxRichInnerEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  if FIsEraseBackgroundLocked or (Container <> nil) and Container.IsInplace then
    Message.Result := 1
  else
    CallWindowProc(DefWndProc, Handle, Message.Msg, Message.DC, 0);
end;

procedure TcxRichInnerEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  inherited;
  if Container.TabsNeeded and (GetKeyState(VK_CONTROL) >= 0) then
    Message.Result := Message.Result or DLGC_WANTTAB;
  if FEscapePressed then
    Message.Result := Message.Result and not DLGC_WANTALLKEYS;
end;

procedure TcxRichInnerEdit.WMKeyDown(var Message: TWMKeyDown);
var
  AKey: Word;
  APrevState: TcxCustomInnerTextEditPrevState;
  AShiftState: TShiftState;
begin
  if Message.CharCode <> VK_ESCAPE then
    FKeyPressProcessed := True;
  try
    SaveTextEditState(Helper, False, APrevState);
    FInternalUpdating := False;
    inherited;
    Container.SetScrollBarsParameters;
    if FInternalUpdating then
      Exit;
  finally
    FKeyPressProcessed := False;
  end;
  AShiftState := KeyDataToShiftState(Message.KeyData);
  AKey := Message.CharCode;
  if (AKey <> 0) and not Container.CanKeyDownModifyEdit(AKey, AShiftState) and
    not CheckTextEditState(Helper, APrevState) and
    not Container.IsNavigationKey(AKey, AShiftState) then
      Container.DoAfterKeyDown(AKey, AShiftState);
  Message.CharCode := AKey;
end;

procedure TcxRichInnerEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) then
    Container.FocusChanged;
end;

procedure TcxRichInnerEdit.WMMButtonDown(var Message: TWMMButtonDown);
begin
  Message.Result := 1;
  SendMessage(Container.Handle, WM_MBUTTONDOWN, 0,
    MakeLParam(Message.XPos + Left, Message.YPos + Top));
end;

procedure TcxRichInnerEdit.WMNCCalcSize(var Message: TWMNCCalcSize);
begin
  inherited;
  if (Container <> nil) and not Container.ScrollBarsCalculating then
    Container.SetScrollBarsParameters;
end;

procedure TcxRichInnerEdit.WMNCPaint(var Message: TWMNCPaint);

  procedure FillSizeGrip;
  var
    ABrush: HBRUSH;
    DC: HDC;
  begin
    if Container.NeedsScrollBars and Container.HScrollBar.Visible and
      Container.VScrollBar.Visible then
    begin
      DC := GetWindowDC(Handle);
      ABrush := 0;
      try
        with Container.LookAndFeel do
          ABrush := CreateSolidBrush(ColorToRGB(Painter.DefaultSizeGripAreaColor));
        FillRect(DC, GetSizeGripRect(Self), ABrush);
      finally
        if ABrush <> 0 then
          Windows.DeleteObject(ABrush);
        ReleaseDC(Handle, DC);
      end;
    end;
  end;

begin
  inherited;
  if (Container = nil) or not UsecxScrollBars then
    Exit;
  FillSizeGrip;
end;

procedure TcxRichInnerEdit.WMPaint(var Message: TWMPaint);
begin
  if RichVersion >= 200 then
    FIsEraseBackgroundLocked := True;
  try
    inherited;
  finally
    FIsEraseBackgroundLocked := False;
  end;
end;

procedure TcxRichInnerEdit.WMPaste(var Message: TMessage);
begin
  if (Clipboard.FormatCount > 0) and Container.DoEditing then
    inherited;
end;

procedure TcxRichInnerEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  if not(csDestroying in ComponentState) and (Message.FocusedWnd <> Container.Handle) then
    Container.FocusChanged;
  if AutoSelect and HandleAllocated then
    PostMessage(Handle, EM_SETSEL, 0, -1);
end;

procedure TcxRichInnerEdit.WMSetFont(var Message: TWMSetFont);
begin
  if HandleAllocated and MemoMode then
  begin
    with TMessage(Message) do
      Result := CallWindowProc(DefWndProc, Handle, Msg, WParam, LParam);
    DefAttributes.Color := Font.Color;
  end
  else
    inherited;
end;

procedure TcxRichInnerEdit.WMTimer(var Message: TWMTimer);
begin
  inherited;
  if Container <> nil then
    Container.RefreshScrollBars;
end;

procedure TcxRichInnerEdit.WMHScroll(var Message: TWMHScroll);
begin
  inherited;
  if not Focused then
    Container.SetScrollBarsParameters;
end;

procedure TcxRichInnerEdit.WMVScroll(var Message: TWMVScroll);
begin
  inherited;
  if not Focused then
    Container.SetScrollBarsParameters;
end;

procedure TcxRichInnerEdit.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  if Container <> nil then
    Container.SetScrollBarsParameters;
  inherited;
end;

procedure TcxRichInnerEdit.WMWindowPosChanging(var Message: TWMWindowPosChanging);
var
  ARgn: HRGN;
begin
  inherited;
  if (Container <> nil) and not(csDestroying in ComponentState) and
    Container.NeedsScrollBars and Container.HScrollBar.Visible and Container.VScrollBar.Visible then
  begin
    ARgn := CreateRectRgnIndirect(GetSizeGripRect(Self));
    SendMessage(Handle, WM_NCPAINT, ARgn, 0);
    Windows.DeleteObject(ARgn);
  end;
end;

procedure TcxRichInnerEdit.EMReplaceSel(var Message: TMessage);
begin
  if (Container <> nil) and Container.Focused then
    Container.DoEditing;
  inherited;
end;

procedure TcxRichInnerEdit.EMSetCharFormat(var Message: TMessage);
begin
  if Focused and (Message.WParam = SCF_SELECTION) and (SelLength > 0) then
    Container.DoEditing;
  inherited;
end;

procedure TcxRichInnerEdit.EMSetParaFormat(var Message: TMessage);
begin
  if (Container <> nil) and not Container.IsDestroying and
    (Container.ComponentState * [csLoading, csReading] = []) and Focused then
      Container.DoEditing;
  inherited;
end;

procedure TcxRichInnerEdit.CMColorChanged(var Message: TMessage);
begin
  if (Container <> nil) and not Container.IsInplace then
    inherited;
end;

procedure TcxRichInnerEdit.CMFontChanged(var Message: TMessage);
begin
  if HandleAllocated and MemoMode then
    Perform(WM_SETFONT, Font.Handle, 0)
  else
    if (Container <> nil) and not Container.IsInplace then
      SetRichDefAttributes(Self, Font,
        Container.ActiveStyle.GetVisibleFont.Color);
end;

procedure TcxRichInnerEdit.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if Message.lParam = 0 then
    MouseLeave(Self)
  else
    MouseLeave(TControl(Message.lParam));
end;

procedure TcxRichInnerEdit.CNNotify(var Message: TWMNotify);

  procedure SetOutRange(var ARange: TCharRange);
  begin
    ARange.cpMin := -1;
    ARange.cpMax := -1;
  end;

begin
  if not (csDesigning in ComponentState) then
    with Message do
      case NMHdr^.code of
        EN_REQUESTRESIZE:
          begin
            if NMHdr^.idFrom = 0 then
              Exit;
          end;
        EN_LINK:
          with PcxENLink(NMHdr)^ do
          begin
            case Msg of
              WM_RBUTTONDOWN:
                begin
                  FURLClickRange := chrg;
                  FURLClickBtn := mbRight;
                end;
              WM_RBUTTONUP:
                begin
                  if (FURLClickBtn = mbRight) and (FURLClickRange.cpMin = chrg.cpMin) and
                      (FURLClickRange.cpMax = chrg.cpMax) then
                    URLClick(GetTextRange(chrg.cpMin, chrg.cpMax), mbRight);
                  SetOutRange(FURLClickRange);
                end;
              WM_LBUTTONDOWN:
                begin
                  FURLClickRange := chrg;
                  FURLClickBtn := mbLeft;
                end;
              WM_LBUTTONUP:
                begin
                  if (FURLClickBtn = mbLeft) and (FURLClickRange.cpMin = chrg.cpMin) and
                      (FURLClickRange.cpMax = chrg.cpMax) then
                    URLClick(GetTextRange(chrg.cpMin, chrg.cpMax), mbLeft);
                  SetOutRange(FURLClickRange);
                end;
              WM_MOUSEMOVE:
                URLMove(GetTextRange(chrg.cpMin, chrg.cpMax));
            end;
          end;
      end;
  inherited;
end;

procedure TcxRichInnerEdit.CMDocWindowActivate(var Message: TMessage);
begin
  if Assigned(FRichEditOleCallback) then
    with TcxRichEditOleCallback(FRichEditOleCallback) do
      if Assigned(DocParentForm) and
        cxIsFormMDIChild(DocParentForm.Form) then
      begin
        if Message.WParam = 0 then
        begin
          ParentFrame.SetMenu(0, 0, 0);
          ParentFrame.ClearBorderSpace;
        end;
      end;
end;

procedure TcxRichInnerEdit.WMChar(var Message: TWMChar);
begin
  if Message.CharCode <> VK_ESCAPE then
    FKeyPressProcessed := True;
  try
    inherited;
  finally
    FKeyPressProcessed := False;
  end;
end;

procedure TcxRichInnerEdit.CNCommand(var Message: TWMCommand);
begin
  if Message.NotifyCode <> EN_CHANGE then
  begin
    inherited;
    Exit;
  end;

  if (Container <> nil) and not Container.IsDestroying and
    (Container.ComponentState * [csLoading, csReading] = []) and
    Focused and FKeyPressProcessed then
      Container.DoEditing;
  inherited;
end;

procedure TcxRichInnerEdit.CNKeyDown(var Message: TWMKeyDown);
begin
  if Message.CharCode = VK_ESCAPE then
    FEscapePressed := True;
  try
    inherited;
  finally
    FEscapePressed := False;
  end;
end;

const
  UseCRLFFlag: array[Boolean] of DWORD = (0, 1);

procedure TcxRichInnerEdit.WMGetText(var Message: TMessage);
var
  ATextInfo: TGetTextEx;
begin
  if (RichVersion >= 200) and HandleAllocated then
  begin
    ZeroMemory(@ATextInfo, SizeOf(ATextInfo));
    ATextInfo.flags := UseCRLFFlag[FUseCRLF];
    if IsWindowUnicode(Handle) then
    begin
      ATextInfo.codepage := 1200;
      ATextInfo.cb := Message.WParam * SizeOf(WideChar);
    end
    else
      ATextInfo.cb := Message.WParam;
    Message.Result := cxSendStructMessage(Handle, EM_GETTEXTEX, ATextInfo, Message.LParam);
  end
  else
    inherited;
end;

procedure TcxRichInnerEdit.WMGetTextLength(var Message: TWMGetTextLength);
var
  ATextInfo: TGetTextLengthEx;
begin
  if (RichVersion >= 200) and HandleAllocated then
  begin
    ZeroMemory(@ATextInfo, SizeOf(ATextInfo));
    ATextInfo.flags := GTL_PRECISE or GTL_NUMCHARS or UseCRLFFlag[FUseCRLF];
    if IsWindowUnicode(Handle) then
      ATextInfo.codepage := 1200;
    Message.Result := cxSendStructMessage(Handle, EM_GETTEXTLENGTHEX, ATextInfo, 0);
  end
  else
    inherited;
end;

procedure TcxRichInnerEdit.WMSetText(var Message: TWMSetText);
begin
  if MemoMode and IsRichText(Message.Text) then
    Message.Text := PChar(ConvertRichText(Message.Text));
  inherited;
end;

procedure TcxRichInnerEdit.WMIMEComposition(var Message: TMessage);
begin
  if Container.DoEditing then
    inherited;
end;

procedure TcxRichInnerEdit.EMExLineFromChar(var Message: TMessage);
begin
  inherited;
  if MemoMode then
  begin
    if GetLineIndex(Message.Result + 1) = Message.LParam then
      Message.Result := Message.Result + 1;
  end;
end;

procedure TcxRichInnerEdit.EMLineLength(var Message: TMessage);
var
  ALineIndex: Integer;
begin
  inherited;
  if MemoMode then
  begin
    ALineIndex := SendMessage(Handle, EM_EXLINEFROMCHAR, 0, Message.WParam);
    if (ALineIndex = GetLineCount - 1) and (Lines[ALineIndex] = '') then
      Message.Result := 0;
  end;
end;

{ TcxOleUILinkInfo }

constructor TcxOleUILinkInfo.Create(AOwner: TcxRichInnerEdit; AReObject: TReObject);
begin
  inherited Create;
  FRichEdit := AOwner;
  FReObject := AReObject;
  FReObject.oleobj.QueryInterface(IOleLink, FOleLink);
end;

destructor TcxOleUILinkInfo.Destroy;
begin
  ReleaseObject(FOleLink);
  inherited Destroy;
end;

//IOleUILinkInfo
function TcxOleUILinkInfo.GetLastUpdate(dwLink: Longint;
  var LastUpdate: TFileTime): HResult;
begin
  Result := S_OK;
end;

//IOleUILinkContainer
function TcxOleUILinkInfo.GetNextLink(dwLink: Longint): Longint;
begin
  if dwLink = 0 then
    Result := Longint(FRichEdit)
  else
    Result := 0;
end;

function TcxOleUILinkInfo.SetLinkUpdateOptions(dwLink: Longint;
  dwUpdateOpt: Longint): HResult;
begin
  Result := FOleLink.SetUpdateOptions(dwUpdateOpt);
  if Succeeded(Result) then
    FRichEdit.Modified := True;
end;

function TcxOleUILinkInfo.GetLinkUpdateOptions(dwLink: Longint;
  var dwUpdateOpt: Longint): HResult;
begin
  Result := FOleLink.GetUpdateOptions(dwUpdateOpt);
end;

function TcxOleUILinkInfo.SetLinkSource(dwLink: Longint; pszDisplayName: PChar;
  lenFileName: Longint; var chEaten: Longint;
  fValidateSource: BOOL): HResult;
var
  ADisplayName: string;
  ABuffer: array[0..255] of WideChar;
begin
  Result := E_FAIL;
  if fValidateSource then
  begin
    ADisplayName := pszDisplayName;
    if Succeeded(FOleLink.SetSourceDisplayName(StringToWideChar(ADisplayName,
      ABuffer, SizeOf(ABuffer) div 2))) then
    begin
      chEaten := Length(ADisplayName);
      OleCheck(FReObject.oleobj.Update);
      Result := S_OK;
    end;
  end
  else
    raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditLinkFail));
end;

function TcxOleUILinkInfo.GetLinkSource(dwLink: Longint; var pszDisplayName: PChar;
  var lenFileName: Longint; var pszFullLinkType: PChar;
  var pszShortLinkType: PChar; var fSourceAvailable: BOOL;
  var fIsSelected: BOOL): HResult;
var
  AMoniker: IMoniker;
begin
  if @pszDisplayName <> nil then
    pszDisplayName := cxGetOleLinkDisplayName(FOleLink);
  if @lenFileName <> nil then
  begin
    lenFileName := 0;
    FOleLink.GetSourceMoniker(AMoniker);
    if AMoniker <> nil then
    begin
      lenFileName := cxOleStdGetLenFilePrefixOfMoniker(AMoniker);
      if Assigned(AMoniker) then
        AMoniker._Release;
    end;
  end;
  if @pszFullLinkType <> nil then
    pszFullLinkType := cxGetOleObjectFullName(FReObject.oleobj);
  if @pszShortLinkType <> nil then
    pszShortLinkType := cxGetOleObjectShortName(FReObject.oleobj);
  Result := S_OK;
end;

function TcxOleUILinkInfo.OpenLinkSource(dwLink: Longint): HResult;
begin
  OleCheck(FReObject.oleobj.DoVerb(OLEIVERB_SHOW, nil, FReObject.olesite,
    0, FRichEdit.Handle, FRichEdit.ClientRect));
  Result := S_OK;
end;

function TcxOleUILinkInfo.UpdateLink(dwLink: Longint; fErrorMessage: BOOL;
  fErrorAction: BOOL): HResult;
begin
  OleCheck(FReObject.oleobj.Update);
  Result := S_OK;
end;

function TcxOleUILinkInfo.CancelLink(dwLink: Longint): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TcxOleUIObjInfo }

constructor TcxOleUIObjInfo.Create(AOwner: TcxRichInnerEdit; AReObject: TReObject);
begin
  inherited Create;
  FRichEdit := AOwner;
  FReObject := AReObject;
end;

function TcxOleUIObjInfo.GetObjectDataSize: Integer;
begin
  Result := -1;
end;

//IOleUIObjInfo
function TcxOleUIObjInfo.GetObjectInfo(dwObject: Longint;
  var dwObjSize: Longint; var lpszLabel: PChar;
  var lpszType: PChar; var lpszShortType: PChar;
  var lpszLocation: PChar): HResult;
begin
  if @dwObjSize <> nil then
    dwObjSize := GetObjectDataSize;
  if @lpszLabel <> nil then
    lpszLabel := cxGetOleObjectFullName(FReObject.oleobj);
  if @lpszType <> nil then
    lpszType := cxGetOleObjectFullName(FReObject.oleobj);
  if @lpszShortType <> nil then
    lpszShortType := cxGetOleObjectShortName(FReObject.oleobj);
  if @lpszLocation <> nil then
  {$IFDEF DELPHI12}
    lpszLocation := PChar(Application.Title);
  {$ELSE}
    lpszLocation := cxCoAllocCStr(Application.Title);
  {$ENDIF}
  Result := S_OK;
end;

function TcxOleUIObjInfo.GetConvertInfo(dwObject: Longint; var ClassID: TCLSID;
  var wFormat: Word; var ConvertDefaultClassID: TCLSID;
  var lpClsidExclude: PCLSID; var cClsidExclude: Longint): HResult;
begin
  FReObject.oleobj.GetUserClassID(ClassID);
  Result := S_OK;
end;

function TcxOleUIObjInfo.ConvertObject(dwObject: Longint; const clsidNew: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TcxOleUIObjInfo.GetViewInfo(dwObject: Longint; var hMetaPict: HGlobal;
  var dvAspect: Longint; var nCurrentScale: Integer): HResult;
begin
  if @hMetaPict <> nil then
    hMetaPict := cxGetIconMetaPict(FReObject.oleobj, FReObject.dvaspect);
  if @dvAspect <> nil then
    dvAspect := FReObject.dvaspect;
  if @nCurrentScale <> nil then
    nCurrentScale := 100;
  Result := S_OK;
end;

function TcxOleUIObjInfo.SetViewInfo(dwObject: Longint; hMetaPict: HGlobal;
  dvAspect: Longint; nCurrentScale: Integer;
  bRelativeToOrig: BOOL): HResult;
var
  AShowAsIcon: Boolean;
begin
  if not Assigned(FRichEdit.FRichEditOle) then
  begin
    Result := E_NOTIMPL;
    Exit;
  end;
  case dvAspect of
    DVASPECT_CONTENT: AShowAsIcon := False;
    DVASPECT_ICON: AShowAsIcon := True;
  else
    AShowAsIcon := FReObject.dvaspect = DVASPECT_ICON;
  end;
  FRichEdit.RichEditOle.InPlaceDeactivate;
  Result := cxSetDrawAspect(FReObject.oleobj, AShowAsIcon, hMetaPict,
    FReObject.dvaspect);
  if Succeeded(Result) then
    FRichEdit.RichEditOle.SetDvaspect(Longint(REO_IOB_SELECTION),
      FReObject.dvaspect);
end;

{ TcxRichEdit }

destructor TcxCustomRichEdit.Destroy;
begin
  FreeAndNil(FEditPopupMenu);
  inherited Destroy;
end;

function TcxCustomRichEdit.GetInnerEditClass: TControlClass;
begin
  Result := TcxRichInnerEdit;
end;

procedure TcxCustomRichEdit.DoProtectChange(Sender: TObject;
  AStartPos, AEndPos: Integer; var AAllowChange: Boolean);
begin
  with Properties do
    if Assigned(OnProtectChange) then
      OnProtectChange(Self, AStartPos, AEndPos, AAllowChange);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnProtectChange) then
        OnProtectChange(Self, AStartPos, AEndPos, AAllowChange);
end;

procedure TcxCustomRichEdit.DoSaveClipboard(Sender: TObject;
  ANumObjects, ANumChars: Integer; var ASaveClipboard: Boolean);
begin
  if IsDestroying then
    Exit;
  with Properties do
    if Assigned(OnSaveClipboard) then
      OnSaveClipboard(Self, ANumObjects, ANumChars, ASaveClipboard);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnSaveClipboard) then
        OnSaveClipboard(Self, ANumObjects, ANumChars, ASaveClipboard);
end;

procedure TcxCustomRichEdit.EditPopupMenuClick(Sender: TObject);
begin
  case Integer(TMenuItem(Sender).Tag) of
    -1: Undo;
    -2: InnerRich.Redo;
    -3: CutToClipboard;
    -4: CopyToClipboard;
    -5: PasteFromClipboard;
    -6: ClearSelection;
    -7: InnerRich.SelectAll;
  end;
end;

function TcxCustomRichEdit.GetLines: TStrings;
begin
  Result := InnerRich.RichLines;
end;

function TcxCustomRichEdit.GetInnerRich: TcxRichInnerEdit;
begin
  Result := TcxRichInnerEdit(InnerControl);
end;

procedure TcxCustomRichEdit.SetLines(Value: TStrings);
begin
  InnerRich.RichLines.Assign(Value);
end;

procedure TcxCustomRichEdit.ChangeHandler(Sender: TObject);
begin
  FIsNullEditValue := False;
  inherited ChangeHandler(Sender);
  DoEditValueChanged;
end;

procedure TcxCustomRichEdit.Scroll(AScrollBarKind: TScrollBarKind;
  AScrollCode: TScrollCode; var AScrollPos: Integer);

  function GetScrollBarHandle(AScrollBarKind: TScrollBarKind): HWND;
  var
    AScrollBar: TcxScrollBar;
  begin
    Result := 0;
    if AScrollBarKind = sbHorizontal then
      AScrollBar := HScrollBar
    else
      AScrollBar := VScrollBar;
    if AScrollBar <> nil then
      Result := AScrollBar.Handle;
  end;

const
  ScrollBarIDs: array[TScrollBarKind] of Integer = (SB_HORZ, SB_VERT);
  ScrollMessages: array[TScrollBarKind] of UINT = (WM_HSCROLL, WM_VSCROLL);
begin
  with InnerRich do
  begin
    CallWindowProc(DefWndProc, Handle, ScrollMessages[AScrollBarKind],
      Word(AScrollCode) + Word(AScrollPos) shl 16, GetScrollBarHandle(AScrollBarKind));
    if AScrollCode <> scTrack then
      AScrollPos := GetScrollPos(Handle, ScrollBarIDs[AScrollBarKind]);
  end;
  DoLayoutChanged;
  if AScrollCode <> scTrack then
    SetScrollBarsParameters;
end;

procedure TcxCustomRichEdit.AdjustInnerEdit;
begin
  if ActiveProperties.MemoMode then
    inherited AdjustInnerEdit
  else
  begin
    InnerRich.Color := ViewInfo.BackgroundColor;
    InnerRich.Font := Style.GetVisibleFont;
  end;
end;

function TcxCustomRichEdit.CanFocusOnClick: Boolean;
begin
  Result := inherited CanFocusOnClick and
    not(csLButtonDown in InnerRich.ControlState);
end;

function TcxCustomRichEdit.CanKeyDownModifyEdit(Key: Word; Shift: TShiftState): Boolean;
begin
  Result := inherited CanKeyDownModifyEdit(Key, Shift) or
   (((Key = VK_DELETE) or (Key = VK_INSERT)) and (ssShift in Shift)) or
   (((Key = Ord('V')) or (Key = Ord('X')) and (ssCtrl in Shift))) and
   (Clipboard.FormatCount > 0);
  Result := Result or (Key = VK_BACK); // !!!
end;

procedure TcxCustomRichEdit.ContainerStyleChanged(Sender: TObject);
begin
  inherited ContainerStyleChanged(Sender);
  if not IsInplace and DataBinding.IDefaultValuesProvider.IsDataStorage and
    not ActiveProperties.MemoMode and not ModifiedAfterEnter then
      Reset;
end;

function TcxCustomRichEdit.DoShowPopupMenu(AMenu: TComponent; X, Y: Integer): Boolean;
begin
  if Assigned(AMenu) then
    Result := inherited DoShowPopupMenu(AMenu, X, Y)
  else
  begin
    UpdateEditPopupMenuItems(GetEditPopupMenuInstance);
    Result := inherited DoShowPopupMenu(GetEditPopupMenuInstance, X, Y);
    EditingChanged;
  end;
end;

function TcxCustomRichEdit.GetEditValue: TcxEditValue;
begin
  if FIsNullEditValue then
    Result := Null
  else
    PrepareEditValue('', Result, False);
end;

{ TcxCustomRichEditViewData }

procedure TcxCustomRichEditViewData.Calculate(ACanvas: TcxCanvas;
  const ABounds: TRect; const P: TPoint; Button: TcxMouseButton;
  Shift: TShiftState; AViewInfo: TcxCustomEditViewInfo;
  AIsMouseEvent: Boolean);
begin
  inherited Calculate(ACanvas, ABounds, P, Button, Shift, AViewInfo, AIsMouseEvent);
  TcxCustomRichEditViewInfo(AViewInfo).IsDrawBitmapDirty := True;
end;

function TcxCustomRichEditViewData.InternalGetEditContentSize(
  ACanvas: TcxCanvas; const AEditValue: TcxEditValue;
  const AEditSizeProperties: TcxEditSizeProperties): TSize;
var
  ADC: HDC;
  AHeight: Integer;
begin
  if (AEditSizeProperties.Width = -1) or (Properties.VisibleLineCount > 0) then
    Result := inherited InternalGetEditContentSize(ACanvas, AEditValue,
      AEditSizeProperties)
  else
  begin
    ADC := CreateCompatibleDC(ACanvas.Handle);
    try
      Result.cx := AEditSizeProperties.Width;
      DrawRichEdit(ADC, Rect(0, 0, AEditSizeProperties.Width, 0), VarToStr(AEditValue),
        Properties, Style.Font, clWhite, clBlack, True, AHeight);
      if AHeight > 0 then
        Inc(AHeight, GetEditContentSizeCorrection.cy);
      Result.cy := AHeight;
    finally
      DeleteDC(ADC);
    end;
  end;
end;

function TcxCustomRichEditViewData.GetProperties: TcxCustomRichEditProperties;
begin
  Result := TcxCustomRichEditProperties(FProperties);
end;

{ TcxRichEditOleCallback }

constructor TcxRichEditOleCallback.Create(AOwner: TcxRichInnerEdit);
begin
  inherited Create;
  FEdit := AOwner;
  FAccelCount := 0;
end;

function TcxRichEditOleCallback.ContextSensitiveHelp(fEnterMode: BOOL): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TcxRichEditOleCallback.DeleteObject(oleobj: IOLEObject): HRESULT;
begin
  if Assigned(oleobj) then
    oleobj.Close(OLECLOSE_NOSAVE);
  Result := S_OK;
end;

function TcxRichEditOleCallback.GetClipboardData(const chrg: TCharRange; reco: DWORD;
  out dataobj: IDataObject): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TcxRichEditOleCallback.GetContextMenu(seltype: Word; oleobj: IOleObject;
  const chrg: TCharRange; var menu: HMENU): HRESULT;
var
  P: TPoint;
begin
  P := GetMouseCursorPos;
  PostMessage(FEdit.Container.Handle, WM_CONTEXTMENU, FEdit.Handle, Integer(PointToSmallPoint(P)));
  Result := S_OK;
end;

function TcxRichEditOleCallback.GetDragDropEffect(fDrag: BOOL; grfKeyState: DWORD;
  var dwEffect: DWORD): HRESULT;
  var Effect: DWORD;
begin
  Result:= S_OK;
  if not fDrag then
  begin
    if ((grfKeyState and (MK_CONTROL or MK_SHIFT)) = (MK_CONTROL or MK_SHIFT)) then
      Effect := DROPEFFECT_LINK
    else if ((grfKeyState and MK_CONTROL) = MK_CONTROL) then
      Effect := DROPEFFECT_COPY
    else
      Effect := DROPEFFECT_MOVE;
    if (Effect and dwEffect <> 0) then
      dwEffect := Effect;
  end;
end;

function TcxRichEditOleCallback.GetInPlaceContext(out Frame: IOleInPlaceFrame;
  out Doc: IOleInPlaceUIWindow;
  lpFrameInfo: POleInPlaceFrameInfo): HRESULT;
begin
  AssignParentFrame;
  if Assigned(FParentFrame) and FEdit.AllowObjects then
  begin
    Frame := FParentFrame;
    Doc := FDocParentForm;
    CreateAccelTable;
    with lpFrameInfo^ do
    begin
      fMDIApp := False;
      FParentFrame.GetWindow(hWndFrame);
      hAccel := FAccelTable;
      cAccelEntries := FAccelCount;
    end;
    Result := S_OK;
  end
  else
    Result := E_NOTIMPL;
end;

function TcxRichEditOleCallback.GetNewStorage(out stg: IStorage): HRESULT;
var
  LockBytes: ILockBytes;
begin
  Result:= S_OK;
  try
    OleCheck(CreateILockBytesOnHGlobal(0, True, LockBytes));
    OleCheck(StgCreateDocfileOnILockBytes(LockBytes, STGM_READWRITE
      or STGM_SHARE_EXCLUSIVE or STGM_CREATE, 0, stg));
  except
    Result:= E_OUTOFMEMORY;
  end;
end;

function TcxRichEditOleCallback.QueryAcceptData(dataobj: IDataObject; var cfFormat: TClipFormat;
  reco: DWORD; fReally: BOOL; hMetaPict: HGLOBAL): HRESULT;
begin
  Result := S_OK;
end;

function TcxRichEditOleCallback.QueryInsertObject(const clsid: TCLSID;
  stg: IStorage; cp: longint): HRESULT;
var
  AAllowInsertObject: Boolean;
begin
  Result := S_OK;
  if cp <> -1 then
    Exit;
  AAllowInsertObject := True;
  FEdit.BeforeInsertObject(AAllowInsertObject, clsid);
  if not AAllowInsertObject then
    Result := E_NOTIMPL;
end;

function TcxRichEditOleCallback.ShowContainerUI(fShow: BOOL): HRESULT;
begin
  if not fShow then AssignParentFrame;
  if Assigned(FEdit) then
  begin
    if fShow then
    begin
      FParentFrame.ClearBorderSpace;
      DestroyAccelTable;
      FParentFrame := nil;
      FDocParentForm := nil;
      FEdit.SetOleControlActive(False);
    end
    else
      FEdit.SetOleControlActive(True);
    Result := S_OK;
  end
  else
    Result := E_NOTIMPL;
end;

procedure TcxRichEditOleCallback.AssignParentFrame;
begin
  if (GetParentForm(FEdit) <> nil) and not Assigned(FParentFrame) and
    FEdit.AllowObjects then
  begin
    FDocParentForm := cxGetVCLFrameForm(ValidParentForm(FEdit));
    FParentFrame := FDocParentForm;
    if cxIsFormMDIChild(FDocParentForm.Form) then
      FParentFrame := cxGetVCLFrameForm(Application.MainForm);
  end;
end;

procedure TcxRichEditOleCallback.CreateAccelTable;
var
  AMenu: TMainMenu;
begin
  if (FAccelTable = 0) and Assigned(FParentFrame) then
  begin
    AMenu := FParentFrame.Form.Menu;
    if AMenu <> nil then
      AMenu.GetOle2AcceleratorTable(FAccelTable, FAccelCount, [0, 2, 4]);
  end;
end;

procedure TcxRichEditOleCallback.DestroyAccelTable;
begin
  if FAccelTable <> 0 then
  begin
    DestroyAcceleratorTable(FAccelTable);
    FAccelTable := 0;
    FAccelCount := 0;
  end;
end;

{ TcxCustomRichEditProperties }

constructor TcxCustomRichEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FHideScrollBars := True;
  FAutoURLDetect := False;
  FAllowObjects := False;
  FStreamModes := [];
  FRichEditClass := recRichEdit20;
end;

procedure TcxCustomRichEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomRichEditProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with Source as TcxCustomRichEditProperties do
      begin
        Self.AllowObjects := AllowObjects;
        Self.AutoURLDetect := AutoURLDetect;
        Self.HideScrollBars := HideScrollBars;
        Self.MemoMode := MemoMode;
        Self.PlainText := PlainText;
        Self.RichEditClass := RichEditClass;
        Self.SelectionBar := SelectionBar;
        Self.StreamModes := StreamModes;
        Self.OnQueryInsertObject := OnQueryInsertObject;
        Self.OnProtectChange := OnProtectChange;
        Self.OnResizeRequest := OnResizeRequest;
        Self.OnSaveClipboard := OnSaveClipboard;
        Self.OnSelectionChange := OnSelectionChange;
        Self.OnURLClick := OnURLClick;
        Self.OnURLMove := OnURLMove;
      end;
    finally
      EndUpdate;
    end
  end
  else
    inherited Assign(Source);
end;

class function TcxCustomRichEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxRichEdit;
end;

function TcxCustomRichEditProperties.GetDisplayText(
  const AEditValue: TcxEditValue; AFullText: Boolean = False;
  AIsInplace: Boolean = True): WideString;
begin
  if (MemoMode or not PlainText) and IsRichText(VarToStr(AEditValue)) then
    Result := inherited GetDisplayText(ConvertRichText(VarToStr(AEditValue)), AFullText)
  else
    Result := inherited GetDisplayText(AEditValue, AFullText);
end;

function TcxCustomRichEditProperties.GetSupportedOperations: TcxEditSupportedOperations;
begin
  Result := [esoAutoHeight, esoEditing, esoHorzAlignment];
end;

function TcxCustomRichEditProperties.CanValidate: Boolean;
begin
  Result := False;
end;

class function TcxCustomRichEditProperties.GetViewDataClass: TcxCustomEditViewDataClass;
begin
  Result := TcxCustomRichEditViewData;
end;

class function TcxCustomRichEditProperties.GetViewInfoClass: TcxContainerViewInfoClass;
begin
  Result := TcxCustomRichEditViewInfo;
end;

function TcxCustomRichEditProperties.IsResetEditClass: Boolean;
begin
  Result := False;
end;

procedure TcxCustomRichEditProperties.SetAllowObjects(
  const Value: Boolean);
begin
  if FAllowObjects <> Value then
  begin
    FAllowObjects := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetAutoURLDetect(
  const Value: Boolean);
begin
  if Value <> FAutoURLDetect then
  begin
    FAutoURLDetect := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetHideScrollBars(Value: Boolean);
begin
  if Value <> FHideScrollBars then
  begin
    FHideScrollBars := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetMemoMode(Value: Boolean);
begin
  if Value <> FMemoMode then
  begin
    FMemoMode := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetPlainText(Value: Boolean);
begin
  if FPlainText <> Value then
  begin
    FPlainText := Value;
    FPlainTextChanged := True;
    try
      Changed;
    finally
      FPlainTextChanged := False;
    end;
  end;
end;

procedure TcxCustomRichEditProperties.SetRichEditClass(AValue: TcxRichEditClass);
begin
  if (AValue <> FRichEditClass) and (AValue >= cxMinVersionRichEditClass) then
  begin
    FRichEditClass := AValue;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetSelectionBar(Value: Boolean);
begin
  if Value <> FSelectionBar then
  begin
    FSelectionBar := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetStreamModes(const Value: TcxRichEditStreamModes);
begin
  if Value <> FStreamModes then
  begin
    FStreamModes := Value;
    Changed;
  end;
end;

procedure TcxCustomRichEditProperties.SetOnQueryInsertObject(
  Value: TcxRichEditQueryInsertObjectEvent);
begin
  FOnQueryInsertObject := Value;
  Changed;
end;

{ TcxCustomRichEditViewInfo }

constructor TcxCustomRichEditViewInfo.Create;
begin
  inherited Create;
  PrevDrawBitmapSize.cx := -1;
  PrevDrawBitmapSize.cy := -1;
end;

destructor TcxCustomRichEditViewInfo.Destroy;
begin
  if DrawBitmap <> 0 then
    DeleteObject(DrawBitmap);
  inherited Destroy;
end;

procedure TcxCustomRichEditViewInfo.DrawNativeStyleEditBackground(ACanvas: TcxCanvas; ADrawBackground: Boolean;
  ABackgroundStyle: TcxEditBackgroundPaintingStyle; ABackgroundBrush: TBrushHandle);
begin
  if IsInplace or (BorderStyle = ebsNone) or not IsCompositionEnabled then
    inherited DrawNativeStyleEditBackground(ACanvas, ADrawBackground, ABackgroundStyle, ABackgroundBrush)
  else
    DrawThemeBackground(OpenTheme(totEdit), ACanvas.Handle, EP_EDITTEXT, ETS_NORMAL, Bounds);
end;

procedure TcxCustomRichEditViewInfo.DrawText(ACanvas: TcxCanvas);

  procedure PrepareDrawBitmap;
  var
    ADC: HDC;
    APrevBitmap: HBITMAP;
    ATempVar: Integer;
  begin
    if IsDrawBitmapDirty then
    begin
      if (DrawBitmap = 0) or (PrevDrawBitmapSize.cx <> TextRect.Right - TextRect.Left) or
        (PrevDrawBitmapSize.cy <> TextRect.Bottom - TextRect.Top) then
      begin
        if DrawBitmap <> 0 then
          DeleteObject(DrawBitmap);
        DrawBitmap := CreateCompatibleBitmap(ACanvas.Handle,
          TextRect.Right - TextRect.Left, TextRect.Bottom - TextRect.Top);
      end;
      ADC := CreateCompatibleDC(ACanvas.Handle);
      APrevBitmap := 0;
      try
        APrevBitmap := SelectObject(ADC, DrawBitmap);
        DrawRichEdit(ADC, TextRect, Text, TcxCustomRichEditProperties(EditProperties),
          Font, BackgroundColor, TextColor, False, ATempVar);
      finally
        if APrevBitmap <> 0 then
          SelectObject(ADC, APrevBitmap);
        DeleteDC(ADC);
      end;
      IsDrawBitmapDirty := False;
    end;
  end;

var
  ADC: HDC;
  APrevBitmap: HBITMAP;
begin
  PrepareDrawBitmap;
  ADC := CreateCompatibleDC(ACanvas.Handle);
  APrevBitmap := 0;
  try
    APrevBitmap := SelectObject(ADC, DrawBitmap);
    with TextRect do
      BitBlt(ACanvas.Handle, Left, Top, Right - Left, Bottom - Top, ADC, 0, 0, SRCCOPY);
  finally
    if APrevBitmap <> 0 then
      SelectObject(ADC, APrevBitmap);
    DeleteDC(ADC);
  end;
end;

function TcxCustomRichEditViewInfo.GetUpdateRegion(AViewInfo: TcxContainerViewInfo): TcxRegion;
begin
  Result := TcxRegion.Create(Self.Bounds);
end;

function TcxCustomRichEditViewInfo.NeedShowHint(ACanvas: TcxCanvas;
  const P: TPoint; const AVisibleBounds: TRect; out AText: TCaption;
  out AIsMultiLine: Boolean; out ATextRect: TRect): Boolean;
begin
  Result := False;
end;

procedure TcxCustomRichEditViewInfo.Paint(ACanvas: TcxCanvas);
begin
  ACanvas.Canvas.Lock;
  try
    if IsInplace and not Focused or IsDBEditPaintCopyDrawing then
    begin
      DrawText(ACanvas);
      ACanvas.ExcludeClipRect(TextRect);
    end;
    DrawCustomEdit(ACanvas, Self, True, bpsComboListEdit);
  finally
    ACanvas.Canvas.Unlock;
  end;
end;

function TcxCustomRichEdit.GetActiveProperties: TcxCustomRichEditProperties;
begin
  Result := TcxCustomRichEditProperties(InternalGetActiveProperties);
end;

function TcxCustomRichEdit.GetProperties: TcxCustomRichEditProperties;
begin
  Result := TcxCustomRichEditProperties(FProperties);
end;

function TcxCustomRichEdit.GetRichVersion: Integer;
begin
  Result := InnerRich.RichVersion;
end;

procedure TcxCustomRichEdit.SetProperties(Value: TcxCustomRichEditProperties);
begin
  FProperties.Assign(Value);
end;

function TcxCustomRichEdit.GetCanUndo: Boolean;
begin
  Result := InnerRich.CanUndo;
end;

procedure TcxCustomRichEdit.Initialize;
begin
  inherited Initialize;
  InnerRich.OnProtectChange := DoProtectChange;
  InnerRich.OnSaveClipboard := DoSaveClipboard;
  Width := 185;
  Height := 89;
  FIsNullEditValue := True;
end;

procedure TcxCustomRichEdit.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);
begin
  LockChangeEvents(True);
  try
    if HandleAllocated then
      SendMessage(InnerRich.Handle, WM_SETREDRAW, 0, 0);
    try
      if HandleAllocated then
        SendMessage(InnerRich.Handle, WM_SETTEXT, 0, Integer(PChar('')));
      InnerEdit.EditValue := Value;
      EditModified := False;
      FIsNullEditValue := VarIsNull(Value);
    finally
      if Parent <> nil then
      begin
        if HandleAllocated then
          SendMessage(InnerRich.Handle, WM_SETREDRAW, 1, 0);
        InnerRich.Invalidate;
      end;
    end;
  finally
    LockChangeEvents(False);
  end;
end;

procedure TcxCustomRichEdit.InternalValidateDisplayValue(const ADisplayValue: TcxEditValue);
begin
end;

procedure TcxCustomRichEdit.DoTextChanged;
var
  ALineCount: Integer;
begin
  inherited DoTextChanged;
  if InnerControl.HandleAllocated and Assigned(dxISpellChecker) then
  begin
    ALineCount := InnerRich.Lines.Count;
    if FLastLineCount <> ALineCount then
    begin
      FLastLineCount := ALineCount;
      Invalidate;
    end;
  end;
end;

procedure TcxCustomRichEdit.PropertiesChanged(Sender: TObject);
begin
  with InnerRich do
  begin
    HideScrollBars := ActiveProperties.HideScrollBars;
    MemoMode := ActiveProperties.MemoMode;
    PlainText := ActiveProperties.PlainText or MemoMode;
    SelectionBar := ActiveProperties.SelectionBar;
    AutoURLDetect := ActiveProperties.AutoURLDetect;
    AllowObjects := ActiveProperties.AllowObjects;
    RichEditClass := ActiveProperties.RichEditClass;
    StreamModes := ActiveProperties.StreamModes;
    OnQueryInsertObject := ActiveProperties.OnQueryInsertObject;
  end;
  if not(IsInplace or IsDBEdit) then
    FPropertiesChange := True;
  try
    inherited PropertiesChanged(Sender);
  finally
    FPropertiesChange := False;
  end;
end;

procedure TcxCustomRichEdit.ResetEditValue;
begin
  if not IsInplace and IsDBEdit then
    Reset;
end;

procedure TcxCustomRichEdit.SetParent(AParent: TWinControl);
begin
  inherited SetParent(AParent);
  RefreshScrollBars;
end;

procedure TcxCustomRichEdit.SynchronizeDisplayValue;
begin
end;

procedure TcxCustomRichEdit.SynchronizeEditValue;
begin
end;

function TcxCustomRichEdit.GetDefAttributes: TTextAttributes;
begin
  Result := InnerRich.DefAttributes;
end;

function TcxCustomRichEdit.GetDefaultConverter: TConversionClass;
begin
  Result := InnerRich.DefaultConverter;
end;

function TcxCustomRichEdit.GetPageRect: TRect;
begin
  Result := InnerRich.PageRect;
end;

function TcxCustomRichEdit.GetParagraph: TParaAttributes;
begin
  Result := InnerRich.Paragraph;
end;

function TcxCustomRichEdit.GetSelAttributes: TTextAttributes;
begin
  if ActiveProperties.MemoMode then
    Result := InnerRich.DefAttributes
  else
    Result := InnerRich.SelAttributes;
end;

procedure TcxCustomRichEdit.RefreshScrollBars;
var
  ARgn: HRGN;
begin
  if HandleAllocated then
  begin
    if not NeedsScrollBars then
      DoLayoutChanged
    else
    begin
      ARgn := CreateRectRgnIndirect(GetControlRect(InnerRich));
      SendMessage(InnerRich.Handle, WM_NCPAINT, ARgn, 0);
      SetScrollBarsParameters;                  
      VScrollBar.Invalidate;
      HScrollBar.Invalidate;
      DeleteObject(ARgn);
    end;
  end;
end;

procedure TcxCustomRichEdit.SetDefAttributes(const Value: TTextAttributes);
begin
  InnerRich.DefAttributes := Value;
end;

procedure TcxCustomRichEdit.SetDefaultConverter(Value: TConversionClass);
begin
  InnerRich.DefaultConverter := Value;
end;

procedure TcxCustomRichEdit.SetPageRect(const Value: TRect);
begin
  InnerRich.PageRect := Value;
end;

procedure TcxCustomRichEdit.SetSelAttributes(const Value: TTextAttributes);
begin
  InnerRich.SelAttributes := Value;
end;

procedure TcxCustomRichEdit.EMCanPaste(var Message: TMessage);
begin
  InnerRich.Dispatch(Message);
end;

procedure TcxCustomRichEdit.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  RefreshScrollBars;
end;

function TcxCustomRichEdit.UpdateContentOnFocusChanging: Boolean;
begin
  Result := False;
end;

procedure TcxCustomRichEdit.UpdateScrollBars;
begin
end;

function TcxCustomRichEdit.CanDeleteSelection: Boolean;
begin
  Result := (SelLength > 0) and CanModify;
end;

procedure TcxCustomRichEdit.Changed(Sender: TObject);
begin
  DoEditing;
end;

procedure TcxCustomRichEdit.DoOnResizeRequest(const R: TRect);
begin
  with Properties do
    if Assigned(OnResizeRequest) then
      OnResizeRequest(Self, R);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnResizeRequest) then
        OnResizeRequest(Self, R);
end;

procedure TcxCustomRichEdit.DoOnSelectionChange;
begin
  with Properties do
    if Assigned(OnSelectionChange) then
      OnSelectionChange(Self);
  if RepositoryItem <> nil then
    with ActiveProperties do
      if Assigned(OnSelectionChange) then
        OnSelectionChange(Self);
  InternalCheckSelection;
end;

function TcxCustomRichEdit.GetEditPopupMenuInstance: TComponent;

  function NewItem(const ACaption: string; ATag: Integer): TMenuItem;
  begin
    Result := TMenuItem.Create(Self);
    with Result do
    begin
      Caption := ACaption;
      Tag := ATag;
      OnClick := EditPopupMenuClick;
    end;
  end;

var
  APopupMenu: TPopupMenu;
begin
  if Assigned(FEditPopupMenu) then
  begin
    Result := FEditPopupMenu;
    Exit;
  end;
  APopupMenu := TPopupMenu.Create(Self);
  FEditPopupMenu := APopupMenu;
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditUndoCaption), -1));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditRedoCaption), -2));
  APopupMenu.Items.Add(NewItem('-', MaxInt));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditCutCaption), -3));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditCopyCaption), -4));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditPasteCaption), -5));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditDeleteCaption), -6));
  APopupMenu.Items.Add(NewItem('-', MaxInt));
  APopupMenu.Items.Add(
    NewItem(cxGetResourceString(@cxSEditRichEditSelectAllCaption), -7));
  Result := APopupMenu;
end;

function TcxCustomRichEdit.IsNavigationKey(Key: Word;
  Shift: TShiftState): Boolean;
begin
  Result := (((Key = VK_UP) or (Key = VK_DOWN) or
    (Key = VK_LEFT) or (Key = VK_RIGHT)) and (Shift = [])) or
    (Key = VK_NEXT) or (Key = VK_PRIOR) or (Key = VK_HOME) or (Key = VK_END);
end;

procedure TcxCustomRichEdit.UpdateEditPopupMenuItems(APopupMenu: TComponent);

  procedure UpdateItems(APopupMenu: TPopupMenu);
  begin
    APopupMenu.Items[0].Enabled := InnerRich.CanUndo and
      ((ActiveProperties.RichEditClass = recRichEdit20) or not InnerRich.CanRedo);
    APopupMenu.Items[1].Enabled := InnerRich.CanRedo;
    APopupMenu.Items[3].Enabled := CanDeleteSelection;
    APopupMenu.Items[4].Enabled := InnerRich.SelLength > 0;
    APopupMenu.Items[5].Enabled := InnerRich.CanPaste;
    APopupMenu.Items[6].Enabled := CanDeleteSelection;
    APopupMenu.Items[8].Enabled := True;
  end;

begin
  if not (APopupMenu is TPopupMenu) then
    Exit;
  InnerRich.ReadOnly := inherited RealReadOnly;
  UpdateItems(TPopupMenu(APopupMenu));
  InnerRich.ReadOnly := RealReadOnly; // !!! ReadOnly must be True in DBRichEdit while DataSet is not in EditMode (for AddictSpellChecker)
end;

procedure TcxCustomRichEdit.ClearSelection;
begin
  InnerRich.ClearSelection;
end;

procedure TcxCustomRichEdit.CutToClipboard;
begin
  InnerRich.CutToClipboard;
end;

function TcxCustomRichEdit.FindText(const ASearchStr: string;
  AStartPos, ALength: Integer; AOptions: TSearchTypes): Integer;
begin
  Result := InnerRich.FindText(ASearchStr, AStartPos, ALength, AOptions);
end;

class function TcxCustomRichEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomRichEditProperties;
end;

procedure TcxCustomRichEdit.PasteFromClipboard;
begin
  InnerRich.PasteFromClipboard;
end;

procedure TcxCustomRichEdit.PrepareEditValue(const ADisplayValue: TcxEditValue;
  out EditValue: TcxEditValue; AEditFocused: Boolean);
var
  AStream: TStringStream;
begin
  if ActiveProperties.MemoMode or ActiveProperties.PlainText or
    (Parent = nil) or not Parent.HandleAllocated then
      EditValue := InnerRich.Text
  else
  begin
    AStream := TStringStream.Create('');
    try
      Lines.SaveToStream(AStream);
      EditValue := AStream.DataString;
    finally
      AStream.Free;
    end;
  end;
end;

procedure TcxCustomRichEdit.Print(const Caption: string);
begin
  InnerRich.Print(Caption);
end;

procedure TcxCustomRichEdit.SaveSelectionToStream(Stream: TStream);
var
  AStreamOperationInfo: TcxRichEditStreamOperationInfo;
  ACustomStreamModes: TcxRichEditStreamModes;
begin
  ACustomStreamModes := [resmSelection];
  TcxRichEditStrings(Lines).InitStreamOperation(Stream,
    AStreamOperationInfo, esoSaveTo, True, ACustomStreamModes);
  with AStreamOperationInfo do
  begin
    cxSendStructMessage(InnerRich.Handle, EM_STREAMOUT, TextType, EditStream);
    if EditStream.dwError <> 0 then
      raise EOutOfResources.Create(cxGetResourceString(@cxSEditRichEditSelectionSaveFail));
  end;
end;

procedure TcxCustomRichEdit.Undo;
begin
  InnerRich.Undo;
end;

function TcxCustomRichEdit.InsertObject: Boolean;
begin
  Result := InnerRich.InsertObject;
end;

function TcxCustomRichEdit.PasteSpecial: Boolean;
begin
  Result := InnerRich.PasteSpecial;
end;

function TcxCustomRichEdit.ShowObjectProperties: Boolean;
begin
  Result := InnerRich.ShowObjectProperties;
end;

class procedure TcxCustomRichEdit.RegisterConversionFormat(
  const AExtension: string; AConversionClass: TConversionClass);
var
  AConversionFormat: PcxConversionFormat;
begin
  New(AConversionFormat);
  with AConversionFormat^ do
  begin
    Extension := AnsiLowerCaseFileName(AExtension);
    ConversionClass := AConversionClass;
    Next := FConversionFormatList;
  end;
  FConversionFormatList := AConversionFormat;
  TCustomRichEdit.RegisterConversionFormat(AExtension, AConversionClass);
end;

procedure Initialize;
begin
  GetRegisteredEditProperties.Register(TcxRichEditProperties,
    cxGetResourceString(@scxSEditRepositoryRichEditItem));
  CFObjectDescriptor := RegisterClipboardFormat('Object Descriptor');
  CFEmbeddedObject := RegisterClipboardFormat('Embedded Object');
  CFLinkSource := RegisterClipboardFormat('Link Source');
  CFRtf := RegisterClipboardFormat(CF_RTF);
  CFRETextObj := RegisterClipboardFormat(CF_RETEXTOBJ);
end;

initialization
  Initialize;
finalization
  FreeAndNil(FRichRenderer);
  FreeAndNil(FRichConverter);
  GetRegisteredEditProperties.Unregister(TcxRichEditProperties);
  if FRichEditLibrary <> 0 then
    FreeLibrary(FRichEditLibrary);
  ReleaseConversionFormatList;
end.
