unit WPCTRMemo;
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPCTRMemo - WPTools 5 main editor control
//******************************************************************************

{$I WPINC.INC}

{.$DEFINE NOPAGENHINT}//OFF, Do *not* show the hint when scrollbar is in track mode
{.$DEFINE PAGENHINT_WHEEL}//OFF, Show page hint when using mouse wheel
{--$DEFINE DISABLEPRINTER}// Dont use Printer (must be defined in project!
{.$DEFINE NOFILEMANSUPPORT}//OFF : Do not support file dropping (see property AcceptFiles)
{$DEFINE USE_INPUTBUFFER} //ON: Use PeekMessage - improves performave for fast writers!
{.$DEFINE USE_INPUTBUFFER_WAIT10}//OFF: wait 10ms to let user type some more chars. Maybe good for terminal server
{$DEFINE UPDATE_CURSOR_ATONCE} //ON: Do not wait for UpdSelection when cursor keys were pressed
{$DEFINE UPDATECODEPAGE} //ON: update codepage from current keyboard layout. Can be deactivated in EditOptionsEx
{$DEFINE IMEINPUT} // Use ImmGetCompositionString
{--$DEFINE DONT_USE_MOUSEWHEEL}//OFF
{$DEFINE PLAINLINKS} //ON, -- requires event OnTestForLinkEvent to be assigned

{$DEFINE WPDONT_USE_SHIFTCTRL} // Do not use PageUp/Doww keys if CTRL and SHIFT is pressed together
// they will never be used if ALT is pressed

{$DEFINE USETIMER} //ON, new handling of DelayedInvalidate (WPTools V5.18.10)

// -------- additional, experimental flags:
{---$DEFINE UNICODEINPUT}//OFF: use ToUnicode(VK_ ...) API - does not work
{---$DEFINE DEBUGPAPERNAMES}//OFF - Display Selected Papername during printing
{---$DEFINE WPSAVEMODE}//OFF -  select active text automatically
{---$DEFINE NODOUBLEBUFFER}//OFF: experimental only
{---$DEFINE WriteObjectModeSTD}//OFF: default to wobStandard as in old WPTools

// -------- WYSIWYG pre selection:
// use: "WPRichText1.HeaderFooter.UpdateReformatMode(true);" to format with printer as reference!
{$IFNDEF NOPRINTOPTIMATION}{$IFNDEF xxUSEIN_PDFCONTROL}
{$DEFINE RM600} // DEFAULT=ON : use highresolution reformat
  // You can disable this for each TRTFDataCollection using FormatOption wpfAlwaysFormatWithScreenRes
{$ENDIF}{$ENDIF}

{$IFDEF USEIN_PDFCONTROL}
{$DEFINE DISABLEPRINTER}
{$ENDIF}


interface

uses
{$IFDEF CLR}
  System.Text,
  System.Runtime.InteropServices, // for PasteFromClipboard
{$ENDIF}
  Windows, Forms, Menus, StdCtrls, Dialogs, ExtCtrls, Controls, SysUtils, Messages,
  Classes, Graphics, WPRTEDefs, WPRTEPaint,
{$IFNDEF DISABLEPRINTER}Printers, WinSpool, {$ENDIF}
  ClipBrd, WPIO
{$IFDEF IMEINPUT}, Imm{$ENDIF}
{$IFNDEF NOFILEMANSUPPORT}, ShellAPI{$ENDIF};


{$IFNDEF WPALLWARN}
{$IFDEF VER150}
{$WARN UNIT_PLATFORM OFF}
{$WARN SYMBOL_PLATFORM OFF}
{$ENDIF}
{$ENDIF}

{$IFDEF T2H}
type
{:: This is a standard event type. Please cast the 'Sender' to the
object class which triggered the event to read out any properties. }
  TNotifyEvent = procedure(Sender: TObject) of object;
{$ENDIF}

const
  WPHistoryMaxCount = 40;
  // Using the windows message WM_WPTOOLSUPDATE we can send deleayed commands to the control.
  // This avoids multiple repaints or updates of the GUI
  // This codes are used with StartUpdate(...)
  WM_WPTOOLSUPDATE = WM_USER + 21; // Message event
  WPUPD_REFORMAT = 1;
  WPUPD_REORDERPAGES = 2;
  WPUPD_REPAINT = 3;
  WPUPD_UPDATTRIBUTES = 4;
  WPUPD_UPDSELECTION = 5;
  WPUPD_SHOWCURSOR = 6;
  WPUPD_UNDOCHANGE = 7;
  WPUPD_NEEDFOCUS = 8; // created by engine WPBROADCAST_NEEDFOCUS
  WPUPD_AFTER_REORDERPAGES = 9; // Used to update the TWPPreview
  WPUPD_SHOWCURSOR_NOSCROLL = 10; // Update GUI but do not use ShowCursor
  WPUPD_DID_SCROLL = 11;
  WPUPD_DID_LOCATE = 12;
  WPUPD_UPDATERULER = 13; // Zooming
  WPUPD_UPDATERULER_CP = 14; // Cursor Movement
  WPUPD_AFTER_LOAD = 15;
  WPUPD_SPEEDREFORMAT = 16;
  WPUPD_DELAYEDINVALIDATE = 17; // invalidate when 100 sec idle!  Uses FLockInvalidateTime
  WPUPD_NEEDSELECTBODY = 18; // Select a body
  WPUPD_SETSCROLLBARS = 19;
  WPUPD_NEEDRESIZE = 20;
  // Some special keys. The event OnDelayedUpdate can be used
  // to react. This event is triggered asynchronly!
  // Of course the event OnKeyDown can be used to capture all key events!
  WPUPD_CTRL_SPACE_KEY = 50;
  WPUPD_SHIFTCTRL_TAB = 51; //suggested action: move to previous field

  WPUPD_USERFIRST = 100;
  WPUPD_USERLAST = 200;
  // Scroll codes - they are executed as soon as they are detected
  WPUPD_SCROLL_UP = 201;
  WPUPD_SCROLL_DN = 202;
  WPUPD_SCROLL_LE = 203;
  WPUPD_SCROLL_RI = 204;

type
  TWPCustomRtfEdit = class;
  TWPPreview = class;
  TWPEditBoxLinkCollection = class;

{$IFDEF DISABLEPRINTER}
  TPrinter = class(TObject);
{$ENDIF}

  EWPToolsProgError = Exception; // Programmers error. Shold bnever occur at runtime


  {:: This event type is used by event <see class="TWPCustomRtfEdit" event="OnEditBoxChangeHeight"> and
    <see class="TWPCustomRtfEdit" event="OnEditBoxChangeWidth">.
    It requires the property EditBoxModes to be
    set as well and only works in normal layout mode.}
  TWPChangeBoxEvent = procedure(Sender: TObject;
    var NewWidth, NewHeight: Integer; var Change: Boolean) of object;

  TWPCreateTableOfContentsMode = set of (
    wptocAlsoProcessTables, // Also look in tables for marked paragraphs. Only the first paragraph of a cell is checked!
    wptocCreateHyperlinks, // Create hyperlinks for the headlines
    wptocLocateTextAfterBookmark, // use the text after bookmarks as headline
    wptocUseParIsOutline, // only use paragraphs which use the WPAT_ParIsOutline attribute
    wptocCreateOutlineBookmarks, // if WPAT_ParIsOutline then create bookmark if not existing
    wptocCreateHyperlinkNumbers // Place the page numbers in hyperlinks
    );

  TWPAcceptFilesOptions = set of
    (wpDropCreatesLinkedImage, // Only the pathname of the image will be stored
    wpDropCreatesMovableParObject, // The image will be positioned relatively to paragraph
    wpDropCreatesMovablePageObject, // -or- The image will be positioned relatively to page
    wpDropCreatesNoWrapImage); // with wpDropCreatesMovable ... the text will not wrap

  TWPDebugMode = set of (wpClipDebug);

  TWPCodeLocateOptions =
    set of (wpGlobalSearch, wpStartAtCursorPosition, wpCompareName, wpCompareSource, wpCompareParams);

  {:: This type is used a parameter for the procedure OnToolbarSelection }
  TWpSelNr = (wptNone, wptName, wptSize, wptColor, wptBkColor,
    wptTyp, wptIconSel, wptIconDeSel, wptPage, wptParagraph, wptParColor,
    wptParAlign, wptStyleNames);

  TWPDeleteParagraphBreakModes = set of (
    wpWorkWithSelection, // Compress selected paragraphs
    wpReplaceWithNL, // Replace removed breaks with new lines
    wpReplaceWithSPC, // Replace removed breaks with space
    wpKeepLogicalPar, // Do not remove if there is an empty line before this paragraph
    wpKeepIfStartWith3SPC, // Do not remove if it starts with 3 space or hard spaced codes
    // if both, wpKeepIfStartWith3SPC and wpKeepLogicalPar are used, both conditions
    // must be true to keep a paragraph break!
    wpDeleteTrailingSpaces, // Reomove trailing spaces from all processed paragraphs
    wpDeleteDoubleSpaceBetweenWord // 2 or 3 spaces between words are deleted
    );

  {:: The TWPCustomRtfEdit does not implement any dialogs. Using this property the
  preview dialog 'knows' which dialogs and actions
  are available through events or overridden procedures }
  TWPCustomRtfEditDialog =
    (wpStartPrint, // starts printing without dialog
    wpdiaPrint,
    wpdiaPrinterSetup,
    wpStartSave, // starts saving without dialog
    wpdiaSaveAs,
    wpdiaLoad,
    wpdiaCanClose,
    wpStartNewDocument, // = Clear
    wpdiaSaveAsPDF,
    wpdiaSpellCheck,
    wpEditHyperlink,
    wpdiaThesaurus,
    wpdiaFind,
    wpStartFindNext,
    wpdiaReplace,
    wpdiaSendByEMail,
    wpdiaInsertCode,
    wpdiaEditCurrentStyle, // not handled by the editor!
    wpdiaCreateNewStyle, // not handled by the editor!
    wpdiaSpellCheckSetup // not handled by the editor!
    );
  TWPCustomRtfEditDialogs = set of TWPCustomRtfEditDialog;

  TWPCustomRtfEditDialogEvent = procedure(Sender: TObject;
    DiaType: TWPCustomRtfEditDialog;
    var ResultValue: Boolean) of object;

  TWPToolBarSelectionEvent = procedure(Sender: TObject; var Typ: TWpSelNr;
    const str: string; const num: Integer) of object;

  TWPPaintPageHintEvent = procedure(Sender: TObject; toCanvas: TCanvas;
    TopRight: TPoint; PageNr, PageCount: Integer; var DisplayStr: string; var Ignore: Boolean) of object;

  TWPNewRTFDataBlockEvent = procedure(Sender: TObject; RTFDataBlock: TWPRTFDataBlock) of object;

  TWPTestForLinkEvent = procedure(Sender: TObject; par: TParagraph;
    var posinpar, len: Integer; var IsLink: Boolean) of object;

   // event class for OnTextHover, OnTextClick and OnTextHint
  {TWPTextMouseEvent = procedure(Sender: TObject;
    starttag, endtag: TWPTextObj; // Contains reference to paragraph!
    var Ignore: Boolean;
    var Text: string) of object; }

   {:: The event type is used by OnWordClick }
  TWPMouseDownRightEvent = procedure(
    Sender: TObject;
    Button: TMouseButton;
    Shift: TShiftState;
    X, Y: Integer;
    par: TParagraph;
    posinpar: Integer;
    CPPos: Integer;
    len: Integer;
    var text: string;
    var CharAttr: Cardinal;
    var Abort: Boolean) of object;

  TWPStartSpellcheckMode = (wpStartSpellCheck, wpStartThesuarus,
    wpStartSpellAsYouGo, wpStopSpellAsYouGo, wpShowSpellCheckSetup);

  {:: This used to be handled globally by the variable WPONStartSpellcheck.
   It is now element of the WPTools Enviroment }
  TWPStartSpellcheckEvent = procedure(Sender: TObject; Mode: TWPStartSpellcheckMode) of object;

  TWPAfterCompleteWordEvent =
    procedure(Sender: TObject; var lastchar: Char) of object;

  TWPInternalAfterCompleteWordEvent =
    procedure(Sender: TObject; var lastchar: Char; var ignoreextern: Boolean) of object;



(*
{$IFNDEF T2H}
  TWPObjectEnvHitType = (ohLeft, ohRight, ohTop,
    ohBottom, ohLeftMid, ohHMiddle, ohVMiddle);
  TWPObjectEnvHitBorders = set of TWPObjectEnvHitType;
  TWPObjectEnvIconType = (ohTopLeft, ohTopMiddle, ohTopRight, ohRightMiddle,
    ohBottomRight, ohBottomMiddle, ohBottomLeft, ohLeftMiddle);

  TWPFrameObject = class;

  TWPFrameObjectIcon = class(TGraphicControl)
  private
    FParent: TWPFrameObject;
    FType: TWPObjectEnvIconType;
    FSizeW, FSizeH: Integer; // Resize method: 0, dont, 1=normal, -1 = min of (w,h)
  public
    procedure Paint; override;
  end;
  {$ENDIF}

  {:: This is the frame which is displayed when an object is selected.
      Using the global variable WPFrameObjectClass you can link in your own
      frame class (which inherits of this class)  "use at your own risk :-)"   }
  TWPFrameObject = class(TCustomControl)
  protected
    FRTFData : TWPRTFDataCollection;
    the_obj : TWPTextObj;
    the_par : TParagraph;
    the_posinpar : Integer;

    FUserat: Boolean;
    FMoveLock: DWORD;
    FIgnoreNextMove: boolean;
    FFrameWidth: Integer;
    FNowResizing, FWhileSizerMouseMove: Boolean;
    FMoving: Boolean;
    OrgWidth, OrgHeight: Integer;
    FOrgPos: TPoint;
    FIcons: array[TWPObjectEnvIconType] of TWPFrameObjectIcon;
    // procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    // procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure AlignIcons; virtual;
    // Resizing
    procedure SizerMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
      Integer); virtual;
    procedure SizerMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); virtual;
    procedure SizerMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y:
      Integer); virtual;
    procedure DblClick; override;
    // Moving
    procedure MouseDown(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
  end;
  TWPFrameObjectClass = class of TWPFrameObject;
*)
{$IFNDEF NOFILEMANSUPPORT}
  TWPOnDropFileEvent = procedure(Sender: TObject;
    const FileName: string; var Proceed: Boolean) of object;
{$ENDIF}

  TOnClickPageEvent = procedure(Sender: TObject; Pagenumber: Integer) of object;

  TWPOnDelayedUpdate = procedure(Sender: TObject;
    var WPUPD_Code: Integer; Param: Integer) of object;

  TWPAbortNotifyEvent = procedure(Sender: TObject; var Abort: Boolean) of object;

  {:: This event is triggered in the mouse up event }

  TWPClickHotTextEvent = procedure(Sender: TObject;
    par: TParagraph;
    posinpar: Integer;
    X, Y: Integer; // Client coordinates
    Button: TMouseButton;
    Shift: TShiftState;
    TxtObj: TWPTextObj) of object;


  TWPPaperDefinition = class(TCollectionItem)
  private
{$IFNDEF T2H}
    FName: string; // DINA4
    FDisplayName: string; // localizable text
    FWidth, FHeight: Integer; // Size in 1/10 mm
    FDEFCode: Integer;
    FLocked: Boolean;
{$ENDIF}
  protected
{$IFNDEF T2H}
    // Creates a description and warning information
    function GetDisplayName: string; override;
    function Compare(W, H: Integer): Integer;
{$ENDIF}
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    //: This is the name for this paper format. It can be used to access the definition
    property Name: string read FName write FName;
    //: This text, the name of the format, can be localizes
    property DisplayName: string read FDisplayName write FDisplayName;
    //: Width in twips
    property Width: Integer read FWidth write FWidth;
    //: Height in twips
    property Height: Integer read FHeight write FHeight;
    //: Using 'Locked' you can lock this format style to be cleard
    property Locked: Boolean read FLocked write FLocked;
    //: DEFCode is used to select a paper in the printer. If 0 the
    //: width/height values are used to define a custom size
    property DEFCode: Integer read FDEFCode write FDEFCode;
  end;

  TWPSetupPrinterFields = set of (
    wpPageSize,
    wpOrientation,
    wpPaperTay,
    wpDuplexMode);

  TWPSetupPrinterEvent = procedure(
    Sender: TWPCustomRtfEdit;
    PrintParameter: TWPPrintParameter;
    aPrinter: TPrinter;
    BeforeStartDoc: Boolean;
    DevMode: PDevMode;
    PaintPageNumber: Integer;
    startpar: TParagraph;
    startposinpar: Integer;
    const PaintPage: TWPRTFEnginePaintPages;
    RTFPage: TWPVirtPage; // can be nil!
    ChangeFields: TWPSetupPrinterFields) of object;

  {:: This event type is used for <see class="TWPCustomRtfEdit" method="DeleteParWithCondition">. }
  TWPCheckParagraph = function(Sender: TObject; par: TParagraph): Boolean of object;

  TWPPaperDefinitionCollection = class(TCollection)
  private
{$IFNDEF T2H}
    FOwner: TWPCustomRtfEdit;
    function GetItem(index: Integer): TWPPaperDefinition;
    procedure SetItem(index: Integer; x: TWPPaperDefinition);
{$ENDIF}
  protected
{$IFNDEF T2H}
    function GetOwner: TPersistent; override;
{$ENDIF}
  public
    constructor Create;
    procedure Init(FromPrinter: Boolean);
    function FindDEF(DEFCode: Integer): Integer;
    function FindWH(w, h: Integer): Integer;
    property aOwner: TWPCustomRtfEdit write FOwner;
    property Items[index: Integer]: TWPPaperDefinition read GetItem write SetItem; default;
  end;



  {:: This class controls the caret (text input cursor) in the memo control.
   It is for intern use only }
  TWPCaret = class
  private
{$IFNDEF T2H}
    FSx, FSy: Integer;
    FSw, FSh: Integer;
    FSactive: Boolean;
    FSblink: Boolean;
    created: Boolean;
    FSvisible: Boolean;
    FUpdated, FSDisabled: Boolean;
{$ENDIF}
  protected
{$IFNDEF T2H}
    procedure Move;
    procedure Make;
    procedure SetVisible(x: Boolean);
    procedure SetActive(a: Boolean);
    procedure SetBlink(a: Boolean);
    function GetActive: Boolean;
    function GetBlink: Boolean;
    procedure SetDisabled(x: Boolean);
{$ENDIF}
  public
    constructor Create(ParentControl: TWinControl; Memo: TWPRTFEnginePaint);
    destructor Destroy; override;
    procedure UpdatePos;
  public
    Handle: HWND;
    Parent: TWinControl;
    FMemo: TWPRTFEnginePaint;
    FRTFEdit: TWPCustomRtfEdit;
    property blink: Boolean read GetBlink write SetBlink;
    property active: Boolean read GetActive write SetActive;
    property Visible: Boolean read FSvisible write Setvisible;
    property Disabled: Boolean read FSDisabled write SetDisabled;
  end;

  TWPCustomRtfEditClick = procedure(Sender: TWPCustomRtfEdit; PageNo, X, Y: Integer; var Ignore: Boolean) of object;

  TWPUpdateExternScrollbar = procedure(Sender: TWPCustomRtfEdit;
    ScrollBar: TScrollStyle;
    Range, Page, Pos: Integer) of object;

{$IFNDEF T2H}
  TWPDrawFrameVar = class(TObject)
  private
{$IFNDEF T2H}
    fWorkObj: TObject;
    FCanvas: TCanvas;
    fx, fy, fw, fh: Integer;
    FObjectOffsetX, FObjectOffsetY: Integer;
    fVisible: Boolean;
    fActive: Boolean;
    procedure SetActive(x: Boolean);
{$ENDIF}
  public
    procedure Draw;
    procedure Start(Canvas: TCanvas; aWorkObj: TObject; sx, sy, sw, sh: Integer);
    procedure Move(dx, dy: Integer; var RelX, RelY: Integer);
    procedure Size(deltaw, deltah: Integer; var RelX, RelY: Integer;
      mode: TWPPaintSizerRects = wpSizeNone);
    property x: Integer read fx;
    property y: Integer read fy;
    property w: Integer read fw;
    property h: Integer read fh;
    property Visible: Boolean read fVisible write fVisible;
    property Active: Boolean read fActive write SetActive;
    property WorkObj: TObject read FWorkObj write FWorkObj;
  end;
{$ENDIF}

  TWPOnInitializeRTFDataObjectEvent = procedure(Sender: TObject;
    var RTFDataObject: TWPRTFDataCollection;
    var RTFPropsObject: TWPRTFProps) of object;

  TTextObjectResizeEvent = procedure(Sender: TWPCustomRtfEdit; pobj: PTTextObj;
    obj: TWPObject) of object;

  TTextObjectMouseEvent = procedure(Sender: TWPCustomRtfEdit; pobj: PTTextObj;
    obj: TWPObject;
    Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer) of object;

  TTextObjectClickEvent = procedure(Sender: TWPCustomRtfEdit; pobj: PTTextObj;
    obj: TWPObject;
    var ignore: Boolean) of object;

{:: This event can be passed as callback to the procedure <see class="TWPCustomRTFEdit" method="TableAdd">
   and <see class="TWPSuperMerge" method="AddReportGroup">.
  You can use it to
modify the style of a new new table cell after it was created or add text.<br>
RowNr will be set to -1 for header and to -2 for footer rows }
  TWPTableAddCellEvent = procedure(RowNr, ColNr: Integer; par: TParagraph) of object;

{:: This set controls how the procedure TableAdd operates. Using the flags
   wptblCreateHeaderRow and wptblCreateFooterRow special rows can be created
   which are repeated on each page. The callback receives the cells of header rows
   as row=-1 and footer rows as row=-2. }
  TWPTableAddOptions = set of (
    wptblActivateBorders,
    wptblCreateHeaderRow,
    wptblCreateFooterRow,
    wptblAllowNestedTables,
    wptblPlaceCursorInLastCell,
    wptblAppendTableAtEnd,
    wptblDontApplyWritingAttr);

{:: Options for the InputCode function}
  TWPInputCodeOptions = set of
    (wpinpWrapSelectedText, // wrap the selected text in the given codes
    wpinpDeleteSelectedText, // Replace the selected text with the code pair
    wpinpPlaceCursorAfterStart, // Position the cursor after the start point
    wpinpDropMarkersOutside, // 1. Drop markers before the start and after the end code
    wpinpDropMarkersInside // 2. Drop markers after start code and before end code
    // See Cursor.SelectMarker for information about markers. The last marker
    // dropped by InputCode has the value _InputCodeMarker. You can access the previous
    // 1 or 3 using _InputCodeMarker-1
    );


  TNotifyWPTextObjEventIgnore = procedure(Sender: TObject;
    txtobj: TWPTextObj; var Ignore: Boolean) of object;
  TNotifyWPTextObjEvent = procedure(Sender: TObject;
    txtobj: TWPTextObj) of object;

  TWPActivateHintEvent = procedure(Sender: TObject;
    txtobj: TWPTextObj; par: TParagraph; posinpar: Integer) of object;

  TWPClickTextEvent = procedure(Sender: TObject;
    txtobj: TWPTextObj; par: TParagraph; posinpar: Integer) of object;

  TWPOnBeforePaste = procedure(
    Sender: TObject;
    RTFData: TWPRTFDataCollection;
    par: TParagraph;
    Stream: TStream;
    Reader: TWPCustomTextReader;
    OnlyBodyText: Boolean;
    var LoadedText: TWPRTFDataBlock) of object;

  TWPOnBeforePasteImage = procedure(
    Sender: TObject;
    RTFData: TWPRTFDataCollection;
    var TxtObj: TWPObject) of object;

  TOnBeforeCopyEvent = procedure(Sender: TObject; var doIt: Boolean) of object;

  TWPAfterCopyToClipboardEvent = procedure(Sender: TObject; InCutToClipboard: Boolean) of object;

  TWPOnBeforeDropText = procedure(
    Destination: TWPCustomRtfEdit;
    X, Y: Integer;
    par: TParagraph;
    posinpar: Integer;
    Source: TWPCustomRtfEdit;
    var Abort: Boolean) of object;

  TWPSaveToFileState = (wpInSaveTextToFile, wpInSaveSelectionToFile);

  TWPBeforeOverwriteFile = procedure(
    Sender: TObject;
    FileName: string; FormatString: string;
    State: TWPSaveToFileState;
    var Abort: Boolean) of object;


  TWPPaintEnginePaintSize = class(TCollectionItem)
  private
    FWidth: Integer;
    FHeight: Integer;
    FMarginLeft: Integer;
    FMarginTop: Integer;
    FMarginRight: Integer;
    FMarginBottom: Integer;
    FReferenceResolution: Integer;
    // Some variables which can be used by the application
    FX: Integer;
    FY: Integer;
    FTitle: string;
    function GetReferenceResolution: Integer;
  protected
{$IFNDEF T2H}
    function GetDisplayName: string; override;
{$ENDIF}
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property MarginLeft: Integer read FMarginLeft write FMarginLeft;
    property MarginTop: Integer read FMarginTop write FMarginTop;
    property MarginRight: Integer read FMarginRight write FMarginRight;
    property MarginBottom: Integer read FMarginBottom write FMarginBottom;
    {:: If this value is >0 the Width and Height values are measured in pixels.
       Otherwise they are twips }
    property ReferenceResolution: Integer read GetReferenceResolution write FReferenceResolution;
    //:: This property is not used - it can be used by the application
    property X: Integer read FX write FX;
    //:: This property is not used - it can be used by the application
    property Y: Integer read FY write FY;
    //:: This property is not used - it can be used by the application
    property Title: string read FTitle write FTitle;
  end;

  TWPPaintEnginePaintSizes = class(TCollection)
  private
{$IFNDEF T2H}
    FOwner: TPersistent;
    function GetItem(index: Integer): TWPPaintEnginePaintSize;
    procedure SetItem(index: Integer; x: TWPPaintEnginePaintSize);
{$ENDIF}
  protected
{$IFNDEF T2H}
    function GetOwner: TPersistent; override;
{$ENDIF}
  public
    constructor Create;
    function Add(const Width, Height: Integer): TWPPaintEnginePaintSize;
    property Items[index: Integer]: TWPPaintEnginePaintSize read GetItem write SetItem; default;
  end;

  {:: This component paints the text in the attached
      <see property="RTFData"> text object to a given Canvas
      using its method <see method="Draw">.
    <code>
// Paint at 100%
procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  WPPaintEngine1.Draw(PaintBox1.Canvas,
            10, 10, PaintBox1.Height,
            WPScreenPixelsPerInch,
            WPScreenPixelsPerInch, 0 );
end;

// Paint at 50%
procedure TForm1.PaintBox1Paint(Sender: TObject);
begin
  WPPaintEngine1.Draw(PaintBox1.Canvas,
            10, 10, PaintBox1.Height,
            WPScreenPixelsPerInch div 2,
            WPScreenPixelsPerInch div 2, 0 );
end;
    </code>
    Note: In case you need to use one RTFData object
    with one TWPPaintEngine you can create one instance of
    the <see class="TWPPaintEngineAndData"> class.  To edit the text You can assign
    the RTFData to the property <see class="TWPCustomRtfEdit" property="ViewRTFData">.
      }
  TWPPaintEngine = class(TComponent)
  private
    FMemo: TWPRTFEnginePaint;
    FRTFData: TWPRTFDataCollection;
    FOwnRTFData: TWPRTFDataCollection;
    FPageSizes: TWPPaintEnginePaintSizes;
    FUseDoMeasurePage: Boolean;
    function GetPageSizes: TWPPaintEnginePaintSizes;
    procedure SetPageSizes(x: TWPPaintEnginePaintSizes);
    procedure DoMeasurePage(Sender: TObject; PageInfo: TWPMeasurePageParam);
  protected
    function GetARTFData: TWPRTFDataCollection; virtual;
    procedure SetARTFData(x: TWPRTFDataCollection); virtual;
    procedure RemoveRTFData; virtual;
    procedure SetRTFData(ARTFData: TWPRTFDataCollection); virtual;
    procedure InitCanvas(toCanvas: TCanvas; Start: Boolean); virtual;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure MakeRTFData;
    {:: Forces the text to be formatted.  }
    procedure ReformatAll(InitializeAll: Boolean = FALSE);
    {:: Counts the pages in the document.
       The text must be formatted with <see method="ReformatAll">. }
    function PageCount: Integer;
    {:: This method has to be used the same way as
      <see class="TWPCustomRtfEdit" method="Draw">. Before You can use
      the component a <see class="TWPRTFDataCollection"> must be attached to property
      RTFData. }
    function Draw(outCanvas: TCanvas;
      x, y: Integer; // The offset
      h: Integer; // The height to be filled
      xres, yres: Integer; // For x,y,h
      starty: Integer; // from last run
      HandlePageBreaks: Boolean = FALSE): Integer; overload;
    function Draw(outCanvas: TCanvas;
      r: TRect;
      zoom: Integer;
      starty: Integer; // from last run
      HandlePageBreaks: Boolean = FALSE): Integer; overload;
    {:: This procedure reformats the text using the current page information (RTFData.Header:PageWidth ...) }
    function Reformat: Integer;
    {:: This procedure deletes the text which is displayed in the body text on
    page 'index'. }
    procedure DeletePage(index: Integer);

    {:: This procedure can be used to paint one of the pages. See
       <see class="TWPCustomRtfEdit" method="PaintPageOnCanvas">. }
    function PaintPageOnCanvas(PaintPageNr: Integer;
      x, y, pw, ph: Integer; DestCanvas: TCanvas;
      PaintMode: TWPPaintModes = [];
      DestXRes: Integer = 0; DestYRes: Integer = 0;
      ClipY: Integer = -1;
      ClipH: Integer = -1;
      PaintPageMode: TWPRTFEnginePaintPagesModes = [wpUseProvidedWidthHeight]): Boolean;
    {:: This function can be used to retrieve a certain page a s metafile. The
    result value will be nil if there were not enough pages in the document.  }
    function GetMetafile(pagenr: Integer; WithHeaderFooter: Boolean = FALSE): TMetafile;
    {:: Before You can use the component a <see class="TWPRTFDataCollection"> must be attached to property
      RTFData. }
    property RTFData: TWPRTFDataCollection read GetARTFData write SetARTFData;
    {:: Reference to the internal paint engine }
    property Memo: TWPRTFEnginePaint read FMemo;
  published
    property Name;
    {:: This collection can be used to pre-define page sizes for the text. These page sizes
    will be used with highest priority. The X and Y properties can be used for any purpose.
    <br>This example paints the pages in a paint box:<br>
    <code>
var i, res : Integer;
    sizebox : TWPPaintEnginePaintSize;
begin
   for i:=0 to WPPaintEngine1.PageSizes.Count-1 do
   begin
      sizebox := WPPaintEngine1.PageSizes.Items[i];
      res := sizebox.ReferenceResolution;
      WPPaintEngine1.PaintPageOnCanvas(
         i,
         MulDiv( sizebox.X, WPScreenPixelsPerInch, res),
         MulDiv( sizebox.Y, WPScreenPixelsPerInch, res),
         MulDiv( sizebox.Width, WPScreenPixelsPerInch, res),
         MulDiv( sizebox.Height, WPScreenPixelsPerInch, res),
         PaintBox1.Canvas
         );
   end;
end;
    </code> }
    property PageSizes: TWPPaintEnginePaintSizes read GetPageSizes write SetPageSizes;
  end;

  TWPClickCreateHeaderFooterEvent = procedure(Sender: TObject; Kind: TWPPagePropertyKind; var Range: TWPPagePropertyRange) of object;


  TWPPaintEngineAndDataPageSize = class(TCollectionItem);


  {:: This class combines a <see class="TWPPaintEngine"> and a
    <see class="TWPRTFDataCollection">. You can read the
    <see property="RTFData"> to let a WPTools editor edit the
    text. This class is used by WPForm to build a text path. }
  TWPPaintEngineAndData = class(TWPPaintEngine)
  private
    FOwnedRTFData: TWPRTFDataCollection;
    FAnyData: TObject;
  protected
    procedure SetARTFData(x: TWPRTFDataCollection); override;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    {:: This property can be used to store a reference to an object
    which should be automatically freed with this instance of the
    TWPPaintEngineAndData class }
    property AnyData: TObject read FAnyData write FAnyData;
  end;

  TWPCustomRtfEdit = class(TWPCustomRTFControl)
  protected
    FDebugMode: TWPDebugMode;
    FCurrentDoubleBuffer: TBitmap;
    FLockDestroy, FSuspended: Integer;
    FNowDestroy, FInResize, FNowReformat, FDidTriggerPaintEvent: Boolean;
    FInScrollTrackMode: Boolean;
    FAlwaysShowCaret: Boolean;
    FIsDynamic: Boolean;
    FThisIsWPPreview: Boolean;
    FIgnoreNextVCLDrop, FDoMergeEnumFields: Boolean;
    FAutoConvertTabs: Boolean;
    FISInplaceEditor: Boolean;
    FInWaitForPaintEditor: Boolean;
    FAttachedEditBox: TWPCustomRtfEdit; // used by TWPPreview ONLY
{$IFNDEF USETIMER}
    FLockInvalidateTime: Cardinal;
{$ELSE}
    FTimerHandle, FTimerWinHandle: Cardinal;
{$ENDIF}
    FWin9X: Boolean;
    procedure CheckActiveText;
    procedure SetInWaitForPaintEditor(x: Boolean);
  private
{$IFNDEF T2H}
{$IFDEF UNICODEINPUT}
    lpKeyState: TKeyboardState;
{$ENDIF}
    FViewRTFData: TWPRTFDataCollection;
    FPreview: TWPPreview;
    FHyperlinkObj: TWPTextObj;
    FJustCreatedAutomaticHyperlink: Boolean;
    FSetZoomMode_AutoZoom: TWPAutoZoom;
    FSetZoomMode_PageLayout: TWPLayoutMode;
    FLocked: Integer;
    FInMouseDown, FAutoScrollActive, FInAfterCompleteWordEvent: Boolean;
    FAutoScrollSpeed: Integer;
    FMouseClickFrameBorder: TWPFrameBorder;
    FLastSelectionChange: Cardinal;
    FSpaceAtGetCPWordFoundPos, FCPWordModified: Boolean;
    FGetCPWordFoundLen, FGetCPWordFoundPos: Integer;
    FGraphicPopupMenu: TPopupMenu;
  // --- events
    FOnClickCreateHeaderFooter: TWPClickCreateHeaderFooterEvent;
    FOnEditBoxChangeHeight, FOnEditBoxChangeWidth: TWPChangeBoxEvent;
    FOnUpdateExternScrollbar: TWPUpdateExternScrollbar;
    FOnSetupPrinterEvent: TWPSetupPrinterEvent;
    FOnMailMergeGetText: TWPMailMergeGetTextEvent;
    FOnChangeViewMode: TNotifyEvent;
    FOnChangeZooming: TNotifyEvent;
    FOnChangeSelection: TNotifyEvent;
    FBeforeObjectSelection: TNotifyWPTextObjEventIgnore;
    FAfterObjectSelection: TNotifyWPTextObjEvent;
    FBeforePasteText: TWPOnBeforePaste;
    FBeforePasteImage: TWPOnBeforePasteImage;
    FBeforeCopyEvent, FBeforeCutEvent: TOnBeforeCopyEvent;
    FInCutToClipboard: Boolean;
    FAfterCopyToClipboard: TWPAfterCopyToClipboardEvent;
    FBeforeDropText: TWPOnBeforeDropText;
    FBeforeOverwriteFile: TWPBeforeOverwriteFile;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FOnInitializeRTFDataObject, FOnInitializedRTFData: TWPOnInitializeRTFDataObjectEvent;
    FOnTextObjectMouseMove: TTextObjectMouseEvent;
    FOnTextObjectMouseDown: TTextObjectMouseEvent;
    FOnTextObjectMouseUp: TTextObjectMouseEvent;
    FOnTextObjectClick: TTextObjectClickEvent;
    FOnTextObjectDblClick: TTextObjectClickEvent;
    FOnUndoStateChanged: TNotifyEvent;
    FLastMovedObject: TWPTextObj;
    FOnTextObjectMove: TTextObjectResizeEvent;
    FOnDelayedUpdate: TWPOnDelayedUpdate;
    FAfterDelayedUpdate: TWPOnDelayedUpdate;
    FBeforeEditBoxNeedFocus: TWPAbortNotifyEvent;
    FOnChangeCursorPos: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FLastCurrPar: TParagraph;
    FOnWorkOnTextChanged: TNotifyEvent;
    FOnResize, FBeforeResize: TNotifyEvent;
    FAvailableDialogs: TWPCustomRtfEditDialogs;
    FOnStartSpellCheck: TWPStartSpellcheckEvent;
    FAfterCompleteWordEvent: TWPAfterCompleteWordEvent;
    FOnOpenDialog: TWPCustomRtfEditDialogEvent;
    FOnToolBarSelection: TWPToolBarSelectionEvent;
    FOnPaintPageHint: TWPPaintPageHintEvent;
    FOnNewRTFDataBlock: TWPNewRTFDataBlockEvent;
    FOnTestForLinkEvent: TWPTestForLinkEvent;
    FOnClear, FAfterLoadText: TNotifyEvent;
    FOnMouseDownWord: TWPMouseDownRightEvent;
    FOnPrepareImageforSaving: TWPPrepareImageforSavingEvent;
    FAfterImageSaving: TWPAfterImageSaving;
    FOnRequestHTTPImage: TWPRequestHTTPImageEvent;
    FOnPaint: TNotifyEvent;
    FEditBoxLinkCollections: TList;
    FHyperLinkCursor, FTextObjectCursor: TCursor;

  // for WM_WPTOOLSUPDATE
    FWM_WPTOOLSUPDATEFlags: array[0..WPUPD_USERLAST] of Boolean;
    FBeginEndUpdateFlags: array[0..WPUPD_USERLAST] of Boolean;
    FShowCursorAfterReformat: Boolean;
  // --- vars
    FAttrStack: array of Cardinal;
    FSelStart: Integer;
    FLockScreen, FLockScreenTopOffset, FLockScreenScrollPosition, FLockScreenLeftOffset: Integer;
    FLockScreenZooming: Extended;
    FWantTabs, FWantReturns: Boolean;
{$IFNDEF NOFILEMANSUPPORT}
    FAcceptFiles: Boolean;
    FAcceptFilesOptions: TWPAcceptFilesOptions;
    FOnDropFile: TWPOnDropFileEvent;
{$ENDIF}
    // FAllowMultiView    : Boolean; // Only for Designtime
    FIDETextHeader: TTextHeader; // Only for Designtime

    // FIDENumberStyles : TWPRTFNumberStyleCollection; // Only for Designtime
    FIDERTFVariables: TWPRTFExtraDataCollection; // Only for Designtime
    FIDEPrintParameter: TWPPrintParameter; // Only for Designtime
    FIDEFormatOptions: TWPFormatOptions;
    FIDEFormatOptionsEx: TWPFormatOptionsEx;
    FIDEValueLoaded: Boolean; // The first time the RTFData object is used!
    FIDEOnRequestStyle: TWPOnRequestStyleEvent;
    FIDEOnRequestHTTPString: TWPRequestHTTPStringEvent;
    FIDEWriteObjectMode: TWPObjectWriteRTFModeGlobal;
    FOnClickPage: TOnClickPageEvent;
    FBorderStyle: TBorderStyle;
    FOnActivateHint: TWPActivateHintEvent;
    FOnClickText: TWPClickTextEvent;
    FVKLeftMouseButton: Integer;
    FOnClick: TWPCustomRtfEditClick;
    FOnDblClick: TWPCustomRtfEditClick;
    FFrameVar: TWPDrawFrameVar;
    FDefaultNumberIndent: Integer;
    // In RTF coordinates
    FMouseX, FMouseY, FMousePage: Integer;
    FMouseMarginArea: TWPMouseMarginArea;
    FMouseNoParFound: Boolean;
    // In window coordinates
    FClientMouseX, FClientMouseY: Integer;
    FCurrentWindowMouseX, FCurrentWindowMouseY, osize_x: Integer;
    FLastMouseWasDrag, FNeedToResetCursor, FDragingObject: Boolean;
    FCurrentMouseButton: TMouseButton;
    FMouseSizeLine: TWPFrameBorder;
    FMouseSizePar, FMouseSelectCell: TParagraph;
    FOnClickHotText: TWPClickHotTextEvent;
    FClickableCodes: TWPTextObjTypes;
    FHyperLinkEvent: THyperLinkEvent;
    FOneClickHyperlink: Boolean;
    FMouseSizeStartX, FMouseSizeStartY: Integer;
    FMouseSizeMinX, FMouseSizeMaxX: Integer;
    FMouseSizeing, FNeedInitRTFData: Boolean;
    FScrollVMulti, FScrollHMulti: Single;
    FPaperDefs: TWPPaperDefinitionCollection;
    FTheLastFileName: string;
    FOnChangeLastFileName: TNotifyEvent;
   // Background image - for pseudo transparency
    FBackgroundImageRef: TObject;
    FRTFText: TWPRTFBlobContents;
    FReadonly: Boolean;
    FClipboardOptions: TWPClipboardOptions;
    FFindInParText: string;
    function cmpFindInPar(Sender: TObject; par: TParagraph): Boolean;
    function cmpIsEmpty(Sender: TObject; par: TParagraph): Boolean;
    function IsHeaderStored: Boolean;
    function GetRTFVariables: TWPRTFExtraDataCollection;
    procedure SetRTFVariables(x: TWPRTFExtraDataCollection);
    function GetPrintParameter: TWPPrintParameter;
    procedure SetPrintParameter(x: TWPPrintParameter);
    function GetSpellCheckStrategie: TWPSpellCheckStrategie;
    procedure SetSpellCheckStrategie(x: TWPSpellCheckStrategie);
    function GetSpellIgnoredForObj: TWPTextObjTypes;
    procedure SetSpellIgnoredForObj(x: TWPTextObjTypes);
    // function GetNumberStyles: TWPRTFNumberStyleCollection;
    // procedure SetNumberStyles(x: TWPRTFNumberStyleCollection);
    function GetRTFText: TWPRTFBlobContents;
    procedure SetRTFText(x: TWPRTFBlobContents);

    function GetTransparent: Boolean;
    procedure SetTransparent(x: Boolean);
    procedure SetGraphicPopupMenu(x: TPopupMenu);

    procedure DoInitializeRTFDataObject(Sender: TObject);
    procedure DoInitializedRTFData(Sender: TObject);
    procedure DoAfterInitializeRTFDataObject(Sender: TObject);
    function GetHeaderFooter: TWPRTFDataCollection;
    function GetBodyText: TWPRTFDataBlock;
    procedure SetScrollBars(Value: TScrollStyle);
    function GetTextObjects: TWPObjectEnv;
    function GetMemo: TWPRTFEnginePaint;
    function GetFinder: TWPTextFinder;
    procedure SetBorderStyle(Value: TBorderStyle);
    procedure SetEditOptions(x: TWPEditOptions);
    function GetEditOptions: TWPEditOptions;
    procedure SetEditOptionsEx(x: TWPEditOptionsEx);
    function GetEditOptionsEx: TWPEditOptionsEx;
    function GetViewOptions: TWPViewOptions;
    procedure SetViewOptions(x: TWPViewOptions);
    function GetFormatOptions: TWPFormatOptions;
    procedure SetFormatOptions(x: TWPFormatOptions);
    function GetFormatOptionsEx: TWPFormatOptionsEx;
    procedure SetFormatOptionsEx(x: TWPFormatOptionsEx);
    procedure SetSinglePageMode(x: Boolean);
    function GetSinglePageMode: Boolean;

    procedure SetOnRequestStyle(x: TWPOnRequestStyleEvent);
    function GetOnRequestStyle: TWPOnRequestStyleEvent;
    procedure SetOnRequestHTTPString(x: TWPRequestHTTPStringEvent);
    function GetOnRequestHTTPString: TWPRequestHTTPStringEvent;

    procedure SetWriteObjectMode(x: TWPObjectWriteRTFModeGlobal);
    function GetWriteObjectMode: TWPObjectWriteRTFModeGlobal;

    procedure SetCaretDisabled(x: Boolean);
    function GetCaretDisabled: Boolean;
    procedure SetTopOffset(y: Integer);
    function GetTopOffset: Integer;
    procedure SetLeftOffset(x: Integer);
    function GetLeftOffset: Integer;

    function GetLines: TStrings;
    procedure SetLines(x: TStrings);

    function GetDrawGrid: Boolean;
    procedure SetDrawGrid(x: Boolean);
    function GetShowPagenumber: Boolean;
    procedure SetShowPagenumber(x: Boolean);
    function GetColumns: Integer;
    procedure SetColumns(x: Integer);
    function GetRows: Integer;
    procedure SetRows(x: Integer);

    function IsTextAttrStored: Boolean;

    function GetProtectProp: TProtectProp;
    procedure SetProtectProp(x: TProtectProp);
    function GetInserting: Boolean;
    procedure SetInserting(x: Boolean);
    function GetOnCheckProtection: TWPCheckProtectedEvent;
    procedure SetOnCheckProtection(x: TWPCheckProtectedEvent);
    function GetOnEditFieldGetSize: TWPEditFieldGetSize;
    procedure SetOnEditFieldGetSize(x: TWPEditFieldGetSize);
    function GetOnEditFieldFocus: TWPEditFieldFocusEvent;
    procedure SetOnEditFieldFocus(x: TWPEditFieldFocusEvent);
    procedure SetInsertPointAttr(x: TCharacterAttrTags);
    function GetInsertPointAttr: TCharacterAttrTags;
    procedure SetHiddenTextAttr(x: TCharacterAttr);
    function GetHiddenTextAttr: TCharacterAttr;
    procedure SetAutomaticTextAttr(x: TCharacterAttr);
    function GetAutomaticTextAttr: TCharacterAttr;
    procedure SetHyperlinkTextAttr(x: TCharacterAttrTags);
    function GetHyperlinkTextAttr: TCharacterAttrTags;
    procedure SetProtectedTextAttr(x: TCharacterAttr);
    function GetProtectedTextAttr: TCharacterAttr;
    procedure SetBookmarkTextAttr(x: TCharacterAttrTags);
    function GetBookmarkTextAttr: TCharacterAttrTags;
    procedure SetFieldObjectTextAttr(x: TCharacterAttr);
    function GetFieldObjectTextAttr: TCharacterAttr;
    procedure SetSPANObjectTextAttr(x: TCharacterAttrTags);
    function GetSPANObjectTextAttr: TCharacterAttrTags;


    function GetEditBoxModes: TWPEditBoxModes;
    procedure SetEditBoxModes(x: TWPEditBoxModes);
    function GetWordWrap: Boolean;
    procedure SetWordWrap(x: Boolean);

    function GetTextLoadFormat: string;
    procedure SetTextLoadFormat(x: string);
    function GetTextSaveFormat: string;
    procedure SetTextSaveFormat(x: string);
    function GetTextLoadSaveOptions: string;
    procedure SetTextLoadSaveOptions(x: string);

    function GetOnGetAttrColor: TWPGetAttrColorEvent;
    procedure SetOnGetAttrColor(x: TWPGetAttrColorEvent);
    function GetOnTextObjectPaint: TWPTextObjectPaintEvent;
    procedure SetOnTextObjectPaint(x: TWPTextObjectPaintEvent);
    function GetOnTextObjGetTextEx: TWPOnTextObjGetTextEvent;
    procedure SetOnTextObjGetTextEx(x: TWPOnTextObjGetTextEvent);
    function GetOnGetPageGapText: TWPOnGetPageGapText;
    procedure SetOnGetPageGapText(x: TWPOnGetPageGapText);
    function GetOnActivatingHotStyle: TWPActivatingHotStyle;
    procedure SetOnActivatingHotStyle(x: TWPActivatingHotStyle);
    function GetOnDeactivateHotStyle: TWPDeactivateHotStyle;
    procedure SetOnDeactivateHotStyle(x: TWPDeactivateHotStyle);
    function GetOnCustomLinePaintBefore: TWPVirtPagePaintEvent;
    procedure SetOnCustomLinePaintBefore(x: TWPVirtPagePaintEvent);
    function GetOnCustomLinePaintAfter: TWPVirtPagePaintEvent;
    procedure SetOnCustomLinePaintAfter(x: TWPVirtPagePaintEvent);
    function GetBeforeInitializePar: TWPInitializeParEvent;
    procedure SetBeforeInitializePar(x: TWPInitializeParEvent);
    function GetOnPrepareParForPaint: TWPInitializeParEvent;
    procedure SetOnPrepareParForPaint(x: TWPInitializeParEvent);
    function GetBeforeDestroyPaintPage: TWPBeforeDestroyPaintPage;
    function GetOnPaintWatermark: TWPOnPaintWatermarkEvent;
    function GetOnPaintExternPage: TWPOnPaintExternPageEvent;
    procedure SetBeforeDestroyPaintPage(x: TWPBeforeDestroyPaintPage);
    procedure SetOnPaintWatermark(x: TWPOnPaintWatermarkEvent);
    procedure SetOnPaintExternPage(x: TWPOnPaintExternPageEvent);

    procedure SetOnCalcPageNr(x: TWPOnCalcPageNr);
    function GetOnCalcPageNr: TWPOnCalcPageNr;

    function GetOnGetSpecialText: TWPOnGetSpecialTextEvent;
    procedure SetOnGetSpecialText(x: TWPOnGetSpecialTextEvent);
    function GetMemoCanvas: TCanvas;

    procedure SetOnMeasureTextPage(x: TWPMeasurePageEvent);
    function GetOnMeasureTextPage: TWPMeasurePageEvent;

{$IFNDEF NOFILEMANSUPPORT}
    procedure SetAcceptFiles(x: Boolean);
{$ENDIF}
    procedure SetActiveStyleName(const x: string);
    function GetActiveStyleName: string;
    function GetActiveLineStart: Integer;
    function GetActiveLineLen: Integer;
    function GetActivePosInPar: Integer;
    procedure SetActivePosInPar(x: Integer);
    function GetActiveParagraph: TParagraph;
    procedure SetActiveParagraph(x: TParagraph);
    function GetFirstParagraph: TParagraph;
    function GetLastParagraph: TParagraph;
    function GetActiveFirstPar: TParagraph;
    // CP Properties
    procedure SetCPPosition(x: Integer);
    function GetCPPosition: Integer;
    function GetSelStart: Integer;
    function GetSelLength: Integer;
    procedure SetSelStart(x: Integer);
    procedure SetSelLength(x: Integer);
    function GetSelRect: TRect;

    function GetCPXpos: Integer;
    function GetCPYpos: Integer;
    procedure SetCPLineNr(x: Integer);
    procedure SetCPParNr(x: Integer);
    procedure SetCPosInPar(x: Integer);
    function GetCPosInPar: Integer;
    function GetCPObj: TWPTextObj;
    function GetSelectedObject: TWPTextObj;
    procedure SetSelectedObject(x: TWPTextObj);
    procedure SetCPLine(const x: string);
    procedure SetCPPar(const x: string);
    function GetCPPar: string;
    function GetCPParNr: Integer;
    function GetCpLineNrLog: Longint;
    function GetCPLineNr: Integer;
    function GetCPLine: string;
    function GetCPWord: string;
    procedure SetCPWord(X: string);
    function GetCursorCol: Integer;
    procedure SetCursorCol(x: Integer);
    function GetCPPage: Integer;
    procedure SetCPPage(x: Integer);
    function GetCPWideChar: WideChar;
    function GetCPChar: Char;
    function GetCPPrevChar: Char;
    function GetCPPrevWideChar: WideChar;
    function GetCPCharPlusIndex(index: Integer): WideChar;
    procedure SetCPCharPlusIndex(index: Integer; C: WideChar);
    procedure SetCPWideChar(x: WideChar);
    procedure SetCPChar(x: Char);
    procedure SetCPPrevWideChar(x: WideChar);
    procedure SetCPPrevChar(x: Char);
    function GetCPCharAttr: Cardinal;
    procedure SetCPCharAttr(x: Cardinal);
    function GetOldAttr: TAttr;
    procedure SetOldAttr(const x: TAttr);
    function GetViewRTFData: TWPRTFDataCollection;
    procedure SetViewRTFData(x: TWPRTFDataCollection);
    function GetHeader: TTextHeader;
    procedure SetHeader(x: TTextHeader);
    procedure SetTextColor(Index: Integer; col: TColor);
    function GetTextColor(Index: Integer): TColor;
    function GetTextColorCount: Integer;

    // Table functions
    function GetTable: TParagraph;
    function GetCell(rownr, colnr: Integer): TParagraph;
    function GetTableCell: TParagraph;
    function GetTableRow: TParagraph;
    procedure SetTable(x: TParagraph);
    procedure SetTableCell(x: TParagraph);
    procedure SetTableRow(x: TParagraph);

    function GetTableColCount: Integer;
    function GetTableCellWidth: Integer;
    procedure SetTableCellWidth(x: Integer);
    function GetTableColNumber: Integer;
    procedure SetTableColNumber(ColumnNumber: Integer);
    function GetTableRowCount: Integer;
    function GetTableRowNumber: Integer;
    procedure SetTableRowNumber(RowNumber: Integer);


    function GetAsString: string;
    procedure SetAsString(const x: string);
    function GetSelectionAsString: string;
    procedure SetSelectionAsString(const x: string);
    procedure SetLastFileName(const x: string);

    function GetText: string;
    procedure SetText(const x: string);
    function GetSelText: string;
    procedure SetSelText(const x: string);

    // Change GUI Options
    function GetZooming: Integer;
    procedure SetZooming(x: Integer);
    function GetResizing: Integer;
    procedure SetResizing(x: Integer);
    function GetXOffset: Integer;
    procedure SetXOffset(x: Integer);
    function GetYOffset: Integer;
    procedure SetYOffset(x: Integer);
    function GetXBetween: Integer;
    procedure SetXBetween(x: Integer);
    function GetYBetween: Integer;
    procedure SetYBetween(x: Integer);
    procedure SetAutoZoom(x: TWPAutoZoom);
    function GetAutoZoom: TWPAutoZoom;
    procedure SetLayoutMode(x: TWPLayoutMode);
    function GetLayoutMode: TWPLayoutMode;
    function GetPageColumns: Integer;
    procedure SetPageColumns(x: Integer);

    function GetPageNumber: Integer;
    procedure SetPageNumber(x: Integer);
    function GetPageCount: Integer;
    function GetCurrentZooming: Integer;

    procedure SetPaperColor(x: TColor);
    function GetPaperColor: TColor;
    procedure SetHighLightColor(x: TColor);
    function GetHighLightColor: TColor;
    procedure SetHighLightTextColor(x: TColor);
    function GetHighLightTextColor: TColor;
    procedure SetDeskColor(x: TColor);
    function GetDeskColor: TColor;
    function GetActiveText: TWPRTFDataBlock;
    function DontAllowLeaveRTFDataBlock: Boolean;
    procedure SetActiveText(x: TWPRTFDataBlock);
    function GetCursorOnText: TWPRTFDataBlock;
    procedure SetCursorOnText(x: TWPRTFDataBlock);
    function GetDisplayedText: TWPRTFDataBlock;
    procedure SetDisplayedText(x: TWPRTFDataBlock);
    function GetTopVisiblePar: TParagraph;
    procedure SetTopVisiblePar(x: TParagraph);
{$ENDIF}
  protected
{$IFNDEF T2H}
    procedure DragOver(Source: TObject; X, Y: Integer; State: TDragState;
      var Accept: Boolean); override;
    procedure DoEndDrag(Target: TObject; X, Y: Integer); override;
    procedure DoStartDrag(var DragObject: TDragObject); override;
    procedure SetReadOnly(Value: Boolean); virtual;
    function GetReadOnly: Boolean; virtual;
    procedure SetModified(Value: Boolean); virtual;
    function GetModified: Boolean; virtual;
    procedure MailMergeCallBack(Sender: TObject; const inspname: string; Contents: TWPMMInsertTextContents); virtual;
    // Raises exception when not set
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoChangeZooming(Sender: TObject); virtual;
{$ENDIF}
  public
    // Used by the data provider !
    _IntegernOnMailMergeGetText: TWPMailMergeGetTextEvent;
    //:: Define standard TControl method: GetTextLen
    function GetTextLen: Integer;

    procedure RemoveRTFData; virtual;
    {:: Calculate the x,y position of the baseline of certain text measured in screen pixels. }
    function GetParXYBaselineScreen(par: TParagraph;
      PosInPar: Integer; var x, y: Integer): Boolean;
    {:: This function locates an image at a certain screen position. It modifies the
      variables img_x, img_y, img_w,img_h accordingly.
      This function can be used to locate images which are placed in header or footer texts.
      <code>
      procedure TForm1.WPRichText1MouseMove(Sender: TObject;
        Shift: TShiftState; X, Y: Integer);
      var ix, iy, iw, ih : Integer;
  img : TWPTextObj;
begin
  img := WPRichText1.GetImageAtXY(X,Y,ix, iy, iw, ih);
  if img<>nil then
  begin
       WPRichText1.Canvas.Pen.Color := clRed;
       WPRichText1.Canvas.Brush.Style := bsClear;
       WPRichText1.Canvas.Rectangle(ix,iy,ix+iw,iy+ih);
  end;
  end;
      </code>
      }
    function GetImageAtXY(
      X, Y: Integer; var img_x, img_y, img_w, img_h: Integer): TWPTextObj;

    {:: This function returns a reference to the
       current enviroment. If no enviroment can be found
       and exception is created }
    function Enviroment: TWPToolsBasicEnviroment;

    procedure SetRTFData(RTFData: TWPRTFDataCollection); virtual;

    //:: Define standard TControl method: GetTextBuf
{$IFNDEF CLR}
    function GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
{$ENDIF}
    {:: This function returns the current paragraph. If the text is
    empty it will create a paragraph! To create a new empty paragraph
    use <see method="InsertPar">. }
    function ActivePar: TParagraph; virtual;
    {:: This function will insert a paragraph at the current cursor
    position and return a reference to it. To use the current paragraph
    use <see method="ActivePar">. }
    function InsertPar: TParagraph;

    {:: This method updates any atached link collection, for example to update
    a style collection }
    procedure DoUpdateState(State: TWPEditBoxLinkMsg); override;

    procedure DragDrop(Source: TObject; X, Y: Integer); override;

    {:: Moves the cursor to a certain cell in the curerent table. If this was
      not possible the result value is false.
      Optionally a table name can be passed. If this is name is not '' the
      editor tries to locate the table with the given name and moves there. }
    function MoveToCell(Col, Row: Integer; TableName: string = ''): Boolean;

    {:: Assigns the contents and all properties which are important for the
        display (InsertPointTextAttr, BookmarkTextAttr etc, ViewOptions and FormatOptions). }
    procedure Assign(Source: TPersistent); override;
    {:: This function provides a reference to the number style collection }
    function ParStyles: TWPRTFStyleCollection;
    {:: This function paints the name of a paragraph style
    into a rectangle using the character attributes of the style.
    If the rectangle is passed with a width of 0 the required height
    for preview which uses the correct height is calculated and returned. }
    function ParStylePaint(StyleName: string;
      toCanvas: TCanvas; R: TRect): Integer;

    {:: This procedure removes the paragraph and character attributes
    from all paragraphs which are using the named style. It returns the count of
    paragraphs which were found and formatted. }
    function ParStyleNormalizePar(const StyleName: string): Integer;
    {:: This procedure makes sure the text is reformatted and the paragraphs which
    are using the named style are initialized. It returns the count of
    paragraphs which were actually found. }
    function ParStyleMarkForReformat(const StyleName: string): Integer;
    {:: This function starts at the cursor position to locate the next style using the
    named style. If it was found TRUE is returned and the cursor is moved to the paragraph.
    The paragraph is also selected. If the end of the text was reached the search
    starts again at the beginning - so please do not use this procedure to
    modify all paragraphs which are using a certain style. Instead use a loop
    like the one in procedure ParStyleMarkForReformat! Also see ParStyleLocateFirst! }
    function ParStyleCPMoveTo(const StyleName: string): Boolean;
    {:: This function starts with the given or the first paragraph of the active text if StartPar=nil.
      If sucessful TRUE is returned. }
    function ParStyleLocateFirst(const StyleName: string; StartPar: TParagraph = nil): Boolean;

    {:: This function provides a reference to the paragraph style collection }
    function NumberStyles: TWPRTFNumberStyleCollection;
    {:: Spellcheck Interface
    @cat Spellcheck Interface    }
    function StartSpellCheck(Mode: TWPStartSpellcheckMode): Boolean;
    {:: Spellcheck Interface: Replace the selected word.
    @cat Spellcheck Interface    }
    procedure Spell_ReplaceWord(const s: string);
    {:: Spellcheck Interface: Select Word at cursor position.
    @cat Spellcheck Interface    }
    procedure Spell_SelectWord;
    {:: Spellcheck Interface: Select Word at X,Y.
    @cat Spellcheck Interface    }
    procedure Spell_SelectWordXY(var x, y: Integer);
    {:: Spellcheck Interface: Get next word and select it.
    @cat Spellcheck Interface    }
    function Spell_GetNextWord: string;
    {:: Spellcheck Interface: Start spellcheck from the start.
    @cat Spellcheck Interface    }
    procedure Spell_FromStart;
    {:: Spellcheck Interface: Start Spellcheck from the current cursor position.
    @cat Spellcheck Interface    }
    procedure Spell_FromCursorPos;
    {:: Spellcheck Interface: Top position in screen coordinates of the selected text.
    @cat Spellcheck Interface    }
    function Spell_TopPosition: Integer;
    {:: This procedure removes the misspell markers from repetions of the give word.
    @cat Spellcheck Interface  }
    procedure Spell_IgnoreWord(const AWord: string; MarkCorrect: Boolean);

    {:: This procedure removes all misspell markers .
    @cat Spellcheck Interface   }
    procedure Spell_RemoveMarkers;

    {:: This procedure is used to execute delaied update actions. The reqested action will
    be activated in the next idle state. If the action is already pending it will not be
    put on the list agaian }
    procedure StartUpdate(WPUPD_Code: Integer; Param: Integer = 0); virtual;
    {:: Returns TRUE if a certain update code will be soon executed. }
    function PendingUpdate(WPUPD_Code: Integer): Boolean;
    //:: This function returns true if the text may be changed
    function Changing: Boolean; virtual;

    {:: This procedure is important for data sensistive controls.
      It makes sure the dataset is set to EditMode withot loading the
      data blob. It also sets the Modified flag. The procedure SaveChanging
      is called before an object or table is resized }
    function SaveChanging: Boolean; virtual;
    {:: This procedure is called after the text has been changed. It
        sets the Modified flag to true and triggers the even OnChange.
        (Please do not mix up with 'Changed' which is used by the VCL) }
    procedure ChangeApplied; virtual;

    {:: This function returns FALSE if no text is selected }
    function IsSelected: Boolean;
    {:: This function returns TRUE if the cursor is are currently inside of a table }
    function InTable: Boolean;
    {:: This function returns TRUE if the body of then text is empty and
    there are neither header nor footer texts defined. }
    function IsEmpty: Boolean;

    {:: This function returns TRUE if the current is the first line in the text. }
    function IsFirstLine: Boolean;
    {:: This function returns TRUE if the current is the first line in the text. }
    function IsLastLine: Boolean;

    {:: This procedure makes sure all tables in the text use fixed widths for their columns.
    If certain columns are defined by contents or by percent values the width which is
    currently displayed will be used a fixed width. Also see <see method="TableAdjustCellWidth">.
    Optionally you can provide a 'snap' value in twips, this is value will be used to round
    each width. }
    procedure TableFixAllCellWidths(SnapValue: Integer = 0);

    {:: If you have changed the pagewidth You can use <see method="TableAdjustCellWidth">
        to make sure all columns stay visible. You can provide a value for
        the MinimumRightMargin right margin allowed for tables, the dfeault is 0.
        Also see <see method="TableFixAllCellWidths">. }
    procedure TableAdjustCellWidth(MinimumRightMargin: Integer = 0);
    procedure TableMakeCellWidthPC;
    {:: Set the properties for a table which is added by <see method="AddTable">,
     <see method="TableAdd"> and FastAddTable; }
    procedure BeginTable(const tablename: string; trgap, l, r: Integer);
    {:: Moves the cursor to the table with a given name. }
    function MoveToTable(const tablename: string): Boolean;
    {:: Duplicate the current table row and place the
    cursor in the first cell. The new row is inserted after the current row.
    Also see <see method="InsertRowAbove">. }
    function InsertRow: Boolean;
    {:: Duplicate the current table row and place the
    cursor in the first cell. The new row is inserted before the current row. Also see <see method="InsertRow">. }
    function InsertRowAbove: Boolean;

    {:: Delete the current row }
    function DeleteRow: Boolean;
    {:: Delete the current table column. }
    function DeleteColumn: Boolean;

    function InsertColumn: Boolean;
    function DeleteTable: Boolean;
    function SplitTable: Boolean;
    {:: This method splits cells. If the flag wpAllowSplitOfCombinedCellsOnly was used in EditOptionsEx
      only merged cells can be splitted. Should be combined with the EditOptionsEx flag
      wpKeepCellsWhenCombiningCells. }
    function SplitCells: Boolean;
    {:: This procedure merges the selected cells horizontally. Please note that the CombineCells procedure not always merges cells by using a colspan flag:
       by default it will remove subsequent cells and change this size of the first cell. You can
       change this behaviour in property EditOptionsEx, option wpKeepCellsWhenCombiningCells. }
    function CombineCells: Boolean;
    {:: This procedure merges the selected cells vertically. }
    function CombineCellsVertically: Boolean;

    procedure SelectThisRow;
    procedure SelectThisColumn;
    procedure SelectThisCell;
    procedure SelectThisTable;


    {:: This procedure deletes the text which is displayed in the body text on
    the page 'index'. }
    procedure DeletePage(index: Integer);

    {:: This procedure removes the paragraph breaks from the text.
    Depending on 'mode' it can replace them with \n signs or
    keep paragraph breaks of paragraphs which start with 3 spaces }
    procedure DeleteParagraphBreaks(Mode: TWPDeleteParagraphBreakModes);

    {:: This procedure uses a callback procedure to check if
        a paragraph will be deleted or not.<br>
        This procedure will also search through the tables on the first level
        (nested tables are ignored). Inside tables cless are cleared
        when the condition is true. If the condition is true for all cells
        in a row that row will be deleted. }
    function DeleteParWithCondition(Condition: TWPCheckParagraph): Boolean;
    {::  This function uses the method <see method="DeleteParWithCondition"> to
      delete paragraphs which do only contains some empty fields and spaces.
      The result value is TRUE if text or paragraphs were deleted.}
    function DeleteParWithEmptyFields: Boolean;
    {:: This function uses the method <see method="DeleteParWithCondition"> to
      delete paragraphs which contain a certain text. }
    function DeleteParWithText(const FindText: string): Boolean;
    {:: This procedure removes space characters and empty paragraphs
      at the end of the text.
      Also see <see method="DeleteLeadingSpace">. }
    function DeleteTrailingSpace(EmptyFieldsToo: Boolean): Boolean;
    {:: Delete Spaces and empty paragraphs at the beginning of the text.
       If the parameter EmptyFieldsToo is true empty field will be also deleted.
       If the value of the optional parameter 'InFirstPar' is true (default)
       the spaces at the beginning of the first
       not empty paragraph will be deleted, too.
       Also see <see method="DeleteTrailingSpace">. }
    function DeleteLeadingSpace(EmptyFieldsToo: Boolean;
      InFirstPar: Boolean = TRUE): Boolean;

    {:: Locates a table with a given name. }
    function FindTable(const tablename: string): TParagraph;
    {:: Locates a paragraph which containes a certain text.
      This can be very useful to search for hidden text which markes certain
      tables or paragraphs.  }
    function FindParWithText(const searchtext: string): TParagraph;
    // procedure BalanceCells(start_of_row: Boolean);
    {:: Closes the table bracket which was opened by AddTable }
    procedure EndTable;
    {:: Simple procedure to add a table. Please also see <see method="TableAdd"> }
    procedure AddTable(colcount, lincount: integer; Border: Boolean = TRUE);
    {:: The function TableAdd creates a new table. As default it will not create tables
inside of tablecells. This feature has to be activated using the flag 'wptblAllowNestedTables' in
the parameter options. Instead the new rows will be created inside the current table.<br>
Using the optional callback event 'CallBackForText' you can add text to the created cells
<code>par.text := 'demo'; //Example to add text to a paragraph</code> or modify their properties
<code>par.ASetColor(WPAT_BGCOLOR, clRed); //Example to set the background color</code>
<br>
The function returns the first created cell.<br>
<br>upgrade note: This function replaces the procedure 'AddTable' from WPTools 4.
<br>If the flags wptblCreateHeaderRow or wptblCreateFooterRow are used special rows will
be added which are repeated on each page. The callback routine will receive the header cells
using the row number -1 and the footer using the row number -2.
<br>
Unless the flag wptblDontApplyWritingAttr is used, AddTable will apply the current
<see property="WritingAttr"> to all new cells. You can either use this flag or
clear the writing attributes with:  WPRichText1.WritingAttr.Clear;
}
    function TableAdd(
      ColCount, RowCount: Integer;
      Options: TWPTableAddOptions = [];
      StyleForNewCells: TWPTextStyle = nil;
      CallBackForText: TWPTableAddCellEvent = nil): TParagraph;

    {:: This function can be used to access the text cursor class.
    This is the same as Memo.Cursor.  }
    function TextCursor: TWPRTFDataCursor;

    {:: This function can be used to read the current attributes. If text is selected
       the properties fo the selected text are read, otherwise the properties
       at the cursor position }
    // The following 3 procedures are also defined in TWPSetModeControl
    function AGet(WPAT_Code: Byte; var Value: Integer): Boolean;
    {:: This procedure deletes an attribute from the current text }
    procedure ADel(WPAT_Code: Byte);
    {:: This procedure sets the attribute for current text }
    procedure ASet(WPAT_Code: Byte; Value: Integer);
    {:: This procedure sets the attribute for current text by adding ("OR") a bit pattern
    to a property. }
    procedure ASetAdd(WPAT_Code: Byte; Value: Cardinal);
    {:: This procedure sets the attribute for current text by removing ("AND NOT")
    a bit pattern to a property. }
    procedure ASetDel(WPAT_Code: Byte; Value: Cardinal);
    {:: This function provides an interface to the default attributes. This are the attributes which
    are used for text which does not have any attached or inherited character attributes. It is
    also used by the reader when loading new text }
    function DefaultAttr: TWPOwnedCharAttrInterface;
    {:: This function provides an interface to the writting attributes. This are the attributes which
    are used for text which is inserted by typing or the reader. }
    function WritingAttr: TWPCurrentWritingmodeAttrInterface;
    {:: This is a shortcurt to
         Memo.RTFData.RTFProps.AttrHelper }
    function AttrHelper: TWPStoredCharAttrInterface;

    function SelectedTextAttr: TWPSelectedTextAttrInterface;

   {:: This function adds a tabstop. The first parameter is the position in twips,
        the second is the kind of the tabstop. Possible values are:<br>
        tkLeft - standard LEFT  (default)<br>
        tkRight - Flush-right tab.<br>
        tkCenter - Centered tab.<br>
        tkDecimal - Decimal tab.<br>
        tkBarTab - Draw bar (Unlike in Word, Fillmodes are supported, too!)<br>
        Two optional parameter are used to specify the fillmode and the fill color. }
    function TabstopAdd(PosInTwips: Integer;
      kind: TTabKind = tkLeft; FillMode: TTabFill = tkNoFill; FillColor: Integer = 0): Boolean;

     {:: Deletes the tabstop at the given position in the current or the select paragraphs }
    function TabstopDelete(PosInTwips: Integer): Boolean;


     {:: Clears the tabstops in the current paragraph or the selected text }
    procedure TabstopClear;

    { ------------ Footnote Stuff ----------------------------------------- }

    {:: Insert a simple footnote. This kind of footnotes can be used to add properties
    to a text, for example to create keywords in HLP files created by the HCW compiler.<br><br>
    Please note that the created footnotes will not be displayed or printed.
    To use printable footnotes you need WPTools PREMIUM. Then you can use the
    procedure InputFootnote to create a new footnote which will be editable. }
    function FootNoteInsert(C: Char; nr: Integer; const str: string): TWPTextObj; overload;
    function FootNoteInsert(nr: Integer; const str: string): TWPTextObj; overload;
    function FootNoteAtCP: TWPTextObj;
    function FootnoteFindNext: Boolean;
    function FootnoteFindPrior: Boolean;
    procedure FootnoteGetList(list: TStrings; FromAllBlock: Boolean = FALSE); overload;
    procedure FootnoteGetList(list: TWPTextObjList; FromAllBlock: Boolean = FALSE); overload;

    { ------------ Hyperlink Stuff ----------------------------------------- }
    procedure DeleteHyperlink(RemoveText: Boolean);
    function HyperlinkConvertOldWPT3Links(OnlyIfHiddenTextWasFound: Boolean = FALSE): Integer;
    function HyperlinkSelect(const URL: string; OnlyText: Boolean): Boolean; // finds and selects
    function HyperlinkMoveTo(const AName: string): Boolean; // locates and moves Cursor
    function InputHyperlink(link, URL: string): TWPTextObj; overload;
    {:: This function wrap the text which is currently selected in hyperlink tags.
        If tags already exist at the start and the end of the selection
        the URL of these tags will be updated, no new tags will be created.
        <br> <br>
        This code will automatically create hyperlinks:<br>
        <code>
  with WPRichText1.Finder do
  begin
     ToStart;
     EndAtSpace := TRUE;
     while Next('http://*') do
     begin
       SelectText;
       WPRichText1.InputHyperlink(FoundText);
     end;
  end;
        </code> }
    function InputHyperlink(URL: string): TWPTextObj; overload;
    function ReadHyperlink(var link, stamp: string): Boolean;
    function HyperlinkAtCP: TWPTextObj;
    { Bookmark stuff }
    {:: Creates or updates the table of contents.
      The table of contents will be placed in a mergefield named '__TOC__' (WPTOC_FIELDNAME). This
      name must not be changed!

      StyleParent.InputMergeField(WPTOC_FIELDNAME,'TOC Created here ....');

      }
    function CreateTableOfContents(
      const AName: string = ''; const BookMarkId: string = '_Toc';
      Mode: TWPCreateTableOfContentsMode = [];
      StopPar: PTParagraph = nil; const TitleText: string = '';
      FirstPar: PTParagraph = nil): Integer; // wptocRecreateAllBookmarks

    //:: finds and selects a Bookmark
    function BookmarkSelect(const AName: string; OnlyText: Boolean): Boolean;
    //:: locates a bookmark and and moves Cursor
    function BookmarkMoveTo(const AName: string; DoGlobalSearch: Boolean = FALSE): Boolean;
    //:: locates a bookmark and and moves Cursor. Start at the current position
    function BookmarkMoveToNext(const AName: string): Boolean; // locates and moves Cursor to next ..
    //:: locates and returns position (or -1 iof not found)
    function BookmarkFind(const AName: string; DoGlobalSearch: Boolean = FALSE): Integer;
    {:: Creates a bookmark. If text is currently selected the selected text
       will be put iside of the new bookmark markers }
    function BookmarkInput(const AName: string; PlaceCursorBetweenTags: Boolean = FALSE): TWPTextObj;
    procedure BookmarkDeleteAllMarkers;
    {:: Deletes the bookmark markers with the given name. This procedure
    searches through all blocks of the current text }
    procedure BookmarkDeleteMarkers(const AName: string);
    procedure BookmarkDelete(const AName: string; Marks, Text: Boolean);
    function BookmarkDeleteInPar(const NameStart: string; par: TParagraph): Boolean;
    {:: Fills a TStrings list with names of bookmarks. }
    procedure BookmarkGetList(list: TStrings; FromAllBlock: Boolean = FALSE); overload;
    {:: Fills a TWPTextObjList with references to bookmarks.
        Internally <see method="GetCodeTags"> is used. }
    procedure BookmarkGetList(list: TWPTextObjList; FromAllBlock: Boolean = FALSE); overload;

    {:: This functions checks if the text at the given position is locate
    inside of a bookmark.<br>
    To check if there is a bookmark object under the mouse
    cursor use CodeAtXY(X,Y,Code)! }
    function BookmarkAtXY(x, y: Integer; var Bookmark: TWPTextObj): Boolean;
    {:: This functions checks if the cursor is inside of a bookmark.<br>
    To check for a text object, such a bookmark object at the cursor position
    use CPAttr.GetObject  }
    function BookmarkAtCP: TWPTextObj;
    function BookmarkFirstInPar(par: TParagraph): string;
    function BookmarkFirstObjInPar(par: TParagraph): TWPTextObj;
    function BookmarkAtParLin(par: TParagraph; pos_in_par: Integer): TWPTextObj;
    function BookmarkForceInPar(par: TParagraph; const frmstr: string): string;

    { Text Field stuff (page numbers and co) }
    function InputTextField(typ: TWPTextFieldType; FieldMask: string = ''): TWPTextObj;
    {:: }
    function InputTextFieldName(const FieldName: string; FieldMask: string = ''): TWPTextObj;

    {:: This function can be used to fill a combobox with the names of the available
      paper trays. The code for each item will be added in the objects[]
      array of the list. The first item will be set to the given name }
    procedure GetPaperBins(aPrinter: TPrinter; list: TStrings;
      FirstName: string = '');
{:: Prints a page on the current Printer Canvas. Does not create a new page.
    The page number is 1 based }
    function PrintPage(n, xoff, yoff: Integer;
      options: TWPPrintOptions = []): Boolean;
//:: Prints pages from..to (The first page is 1!)
    function PrintPages(FromPage, ToPage: Integer): Boolean;
{:: Starts a printer job. StartPageNumber should be set to the first page number which
    will be printed in the range 0..CountPages-1.<br>
    Info: Using the PrinteParameter.PrintOptions it is possible to
    create a continous page numbering.
     }
    function BeginPrint(Title: string = ''; StartPageNumber: Integer = 0): Boolean;
//:: Closes a printer job
    function EndPrint: Boolean;
    {:: Updates the printer with the current print parameter. It tries to
        select the correct paper in the printer by comparing the paper sizes.
        It allows and error of 1.5 mm. }
    procedure UpdatePrinterProperties(aPrinter: TPrinter; PaintPageNr: Integer; pw: Integer = 0; ph: Integer = 0);
    {:: Retrieves the X,Y coordinate of the cursor position in screen coordinates }
    function GetCPXYPoint(var ScreenPoint: TPoint): Boolean;
    {:: Retrieves the X,Y position in client coordinates from a certain par,
      posinpar combination.
      <br>
      This example calculates the screen position for a popmenu for a hyperlink
      or similar object:
      <code>
    p := WPRichText1.GetPointFromParLin(hyperobj.ParentPar,hyperobj.ParentPosInPar);
    inc(p.y, MulDiv(hyperobj.ParentPar.CharPos[hyperobj.ParentPosInPar+1].Height,
       WPScreenPixelsPerInch, WPRichText1.Memo.CurrentYPixelsPerInch));
    p := WPRichText1.ClientToScreen(p);
      </code>
       }
    function GetPointFromParLin(par: TParagraph; posinpar: Integer): TPoint;
    {:: Retrieves the current X position in twips. This value is measured
    from the left border of the text, not including the left page margin!}
    function GetXPositionTw: Integer;
    {:: Retrieves the current Y position in twips. This includes the top margin! }
    function GetYPositionTw: Integer;

    {:: procedure ScrollLinePos(par, posinpar) makes this text line first of screen (when text long enough). }
    procedure ScrollLinePos(par: TParagraph; posinpar: Integer);

    {:: This procedure assigns the zoom value as string }
    procedure SetZoom(ZoomValue: string);

    {:: This procedure changes the properties layout mode, autozoom and zooming at once. }

    procedure SetZoomMode(ZoomShortcutValue: Integer);

    {::   }
    function CPAttr: TWPTAttrEmulator;
    {:: This property provides an interface to the
      character attributes at the cursor position. It works like
      <see property="CPAttr"> and provides the same reference as
      <see class="TWPRTFDataCursor" property="CurrentCharAttr">  and
      CPAttr.Ex }
    function CurrentCharAttr: TWPCursorCharAttrInterface;

    {:: This procedure stores the current writing mode (character styles) on a 'stack'.
       Using PopAttr the old mode can be restored. Please note that 'Clear' invalidates the stored writing modes.}
    procedure PushAttr;
    {:: This procedure restores the writing mode which was stored using PushAttr }
    procedure PopAttr;

    //:: Count the lines in the text
    function CountLines: Integer;
    //:: Count the words in the text
    function CountWords: Integer;
    //:: Count the pages in the text
    function CountPages: Integer;
    //:: Count the paragraphs in the text
    function CountParagraphs: Integer;
    //:: This property is only defined inside of the HyperlinkEvent to read the current link objects
    property HyperlinkObj: TWPTextObj read FHyperlinkObj;

    //::@depreciated This property is only provided for compatibility reason
    property Attr: TAttr read GetOldAttr write SetOldAttr;
    property CPCharAttr: Cardinal read GetCPCharAttr write SetCPCharAttr;
    function CPMoveNext: Boolean;
    function CPMoveBack: Boolean;
    function CPMoveDownLine: Boolean;
    function CPMoveDownPar: Boolean;
    function CPMoveUpLine: Boolean;
    function CPMoveUpPar: Boolean;
    {:: This property allows direct manipulation of the character at the
    cursor position - except for the #13 character which marks the end
    of a paragraph. Please also see <see property="CPChar">.  }
    property CPChar: Char read GetCPChar write SetCPChar;
    {:: This property allows direct manipulation of the character BEFORE the
    cursor position - except for the #13 character which marks the end
    of a paragraph. Please also see <see property="CPPrevChar">. }
    property CPPrevChar: Char read GetCPPrevChar write SetCPPrevChar;
    {:: This property can be used to read the characters starting with the cursor
    position plus a certain index. This property is only provided to make it easier
    to convert code which was using pointers.
    We suggest to work directly with ActiveParagraph and ActivePosInPar. }
    property CPChars[index: Integer]: WideChar read GetCPCharPlusIndex write SetCPCharPlusIndex;
    property CPWideChar: WideChar read GetCPWideChar write SetCPWideChar;
    {::  }
    property CPPrevWideChar: WideChar read GetCPPrevWideChar write SetCPPrevWideChar;
    {::  }
    property CPPosition: Integer read GetCpPosition write SetCPPosition;
    {::  }
    property ActiveStyleName: string read GetActiveStyleName write SetActiveStyleName;

    {:: }
    property ActivePosInPar: Integer read GetActivePosInPar write SetActivePosInPar;
    {:: This is the start offset of the current line in the
      <see property="ActiveParagraph" text="current paragraph">. }
    property ActiveLineStart: Integer read GetActiveLineStart;
    {:: This is the length of the current line in the
      <see property="ActiveParagraph" text="current paragraph">. }
    property ActiveLineLen: Integer read GetActiveLineLen;

    {::  }
    property ActiveParagraph: TParagraph read GetActiveParagraph write SetActiveParagraph;
    {:: This is the first paragraph of the displayed text which is usually the body text.
      Please also see <see property="ActiveFirstPar">.
      Please also see <see class="TRTFDataCollection" property="FirstPar"
        text="HeaderFooter.FirstPar"> which can be used with par.globalnext
        to loop through <b>all</b> paragraphs in any parts of the text.   }
    property FirstPar: TParagraph read GetFirstParagraph;
    {:: This is the last paragraph (in the first level) of the displayed text.
        Please also see <see property="FirstPar">.
    }
    property LastPar: TParagraph read GetLastParagraph;

    {:: This is the first paragraph of the edited text. This can be the header, footer or body.
        Please also see <see property="FirstPar">}
    property ActiveFirstPar: TParagraph read GetActiveFirstPar;

    {:: This property reads the start position of the current selection. To set a selection you must
    first set SelStart and then SelLength. Note: Changing SelStart alone does <b>not</b>
    remove a selection and does not change the value of SelLength. }
    property SelStart: Integer read GetSelStart write SetSelStart;
    {:: This property reads the length of the selection. To set a selection you must
    first set SelStart and then SelLength. }
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelRect: TRect read GetSelRect;
    property CPXPos: Integer read GetCPXpos;
    property CPYPos: Integer read GetCPYpos;
    {:: This is the absolute line number counted from the start of the text - also see <see property="CpLineNrLog"> }
    property CPLineNr: Integer read GetCPLineNr write SetCpLineNr;
    {:: This is the logical line number - this property should be used to display a number in the status bar }
    property CpLineNrLog: Integer read GetCpLineNrLog;
    property CPParNr: Integer read GetCPParNr write SetCpParNr;
    property CPColNr: Integer read GetCursorCol write SetCursorCol;
    property CPLine: string read GetCpLine write SetCpLine;
    property CPPar: string read GetCPPar write SetCPPar;
    property CPPosInPar: Integer read GetCPosInPar write SetCPosInPar;
    property CPWord: string read GetCPWord write SetCPWord;
    property CPObj: TWPTextObj read GetCPObj;
    property CPPage: Integer read GetCPPage write SetCPPage;
    property SelectedObject: TWPTextObj read GetSelectedObject write SetSelectedObject;
    property Header: TTextHeader read GetHeader write SetHeader stored IsHeaderStored;
    {:: This property can be used to temporarily assign an external RTF data object
       to be edited by this editor.
       We recommend to use it with the class <see class="TWPPaintEngineAndData"> }
    property ViewRTFData: TWPRTFDataCollection read GetViewRTFData write SetViewRTFData;

    property TextColors[Index: Integer]: TColor read GetTextColor write SetTextColor;
    property TextColorCount: Integer read GetTextColorCount;
    {:: This property is used by the bullet and number dialog to
        indent the numbered text. It is also used by the bullet toolbutton.
        The default value is 360 }
    property DefaultNumberIndent: Integer read FDefaultNumberIndent write FDefaultNumberIndent;

    {:: This property selects which text is currently changed. It works
    like 'WorkOnText' but is more versatile. It automatically changes the
    property <see property="CursorOnText"> and <see property="DisplayedText">. }
    property ActiveText: TWPRTFDataBlock read GetActiveText write SetActiveText;
    {:: This is the text which is currently edited. }
    property CursorOnText: TWPRTFDataBlock read GetCursorOnText write SetCursorOnText;
    {:: This is the text which is currently displayed. }
    property DisplayedText: TWPRTFDataBlock read GetDisplayedText write SetDisplayedText;
    {:: This is first paragraph which is displayed in the editor. }
    property TopVisiblePar: TParagraph read GetTopVisiblePar write SetTopVisiblePar;
    {:: Read:  Retrieves the parent table of the current cell<br>
        Write: Moves the cursor to the first cell in a certain table. Only if no cell exists the
        table will be selected! }
    property Table: TParagraph read GetTable write SetTable;
    {:: If the cursor is already inside of a table You can use this property
       to access a certain cell in the same table.
       Please make sure to check the result value for nil.
       <br>rownr and colnr are counted from 0.
       <code>
       var cell : TParagraph;
       cell := WPRichText1.Cell[2,2];
       if cell<>nil then  cell.SetText('NEWTEXT');
       WPRichText1.Refresh;
       </code>
       Also see <see class="TParagraph" method="GetCell">.
        }
    property Cell[rownr, colnr: Integer]: TParagraph read GetCell;
    {:: Read:  Retrieves the parent row of the current cell<br>
        Write: Moves the cursor to the first cell in a certain row. Only if no cell exists the
        row will be selected!  }
    property TableRow: TParagraph read GetTableRow write SetTableRow;
    {:: Read:  Retrieves the parent cell of the current paragraph<br>
        Write: Moves the cursor to the first paragraph in a certain cell }
    property TableCell: TParagraph read GetTableCell write SetTableCell;
    {:: This property retrieves the column number of the current row or -1 if
    the cursor is not inside of a table row }
    property TableColNumber: Integer read GetTableColNumber write SetTableColNumber;
    {:: This property retrieves the row number of the current row or -1 if
    the cursor is not inside of a table row }
    property TableRowNumber: Integer read GetTableRowNumber write SetTableRowNumber;
    property TableColCount: Integer read GetTableColCount;
    property TableRowCount: Integer read GetTableRowCount;
    {:: This is the width of the current cell. It is the actual width in twips, as displayed on screen and
    can be changed by several properties, such as the page width and the values of the
    WPAT_COLWIDTH and WPAT_COLWIDTH_PC properties.
    The value is only valid if the text is reformated, so the execution of
    'ReformatAll' is required if the cell has been just added in code. }
    property TableCellWidth: Integer read GetTableCellWidth write
      SetTableCellWidth;
    {:: see event: OnUpdateExternScrollbar }
    property ScrollVertMultiplicator: Single read FScrollVMulti;
    {:: see event: OnUpdateExternScrollbar }
    property ScrollHorzMultiplicator: Single read FScrollHMulti;

    property PaperDefs: TWPPaperDefinitionCollection read FPaperDefs;
    property RTFText: TWPRTFBlobContents read GetRTFText write SetRTFText;
    property GraphicPopupMenu: TPopupMenu read FGraphicPopupMenu write SetGraphicPopupMenu;
    property RTFVariables: TWPRTFExtraDataCollection read GetRTFVariables
      write SetRTFVariables stored IsHeaderStored;
    property PrintParameter: TWPPrintParameter read
      GetPrintParameter write SetPrintParameter; //  stored IsHeaderStored;
    {:: This property controls how the spell-as-you-go events are created.
    SpellAsYouGo (a.k.a. life-spell) is available with our own product WPSpell,
    with Addict Spelll and with EDSSpell (see partner page on www.wpcubed.com).<br>
    Note: Changing this propetry has no immediate effect. }
    property SpellCheckStrategie: TWPSpellCheckStrategie read
      GetSpellCheckStrategie write SetSpellCheckStrategie;

    {:: Text within objects with ObjTypes which are part this set
        is ignored in the spell-as-you-go routine.
        This requires the objects to be in the same paragraph!
        The default is [wpobjMergeField,wpobjHyperlink]. Please note that this set includes all
        object types, even those which are reserved (custom, pagesize and pageprops) and also
        those which are not used in pairs, such as wpobjImage and wpObjTextObject.<br>
    }
    property SpellIgnoredForObj: TWPTextObjTypes read GetSpellIgnoredForObj
      write SetSpellIgnoredForObj default [wpobjMergeField, wpobjHyperlink];

    // property NumberStyles: TWPRTFNumberStyleCollection read GetNumberStyles
    //  write  SetNumberStyles stored IsHeaderStored;
    property AsString: string read GetAsString write SetAsString;
    property SelectionAsString: string read GetSelectionAsString write SetSelectionAsString;
    property LastFileName: string read FTheLastFileName write SetLastFileName;
    property OnChangeLastFileName: TNotifyEvent read FOnChangeLastFileName write FOnChangeLastFileName;
    property Text: string read GetText write SetText;
    property SelText: string read GetSelText write SetSelText;
    //:: The offset to the text /page in pt
    property XOffset: Integer read GetXOffset write SetXOffset default 72;
    //:: The offset to the text /page in pt
    property YOffset: Integer read GetYOffset write SetYOffset default 72;
    //:: The offset between pages "on the desktop"
    property XBetween: Integer read GetXBetween write SetXBetween default 72;
    //:: The offset between pages "on the desktop"
    property YBetween: Integer read GetYBetween write SetYBetween default 72;
    //:: The zooming mode - ignored for the layout modes thumbnail and wpDualPageView
    property AutoZoom: TWPAutoZoom read GetAutoZoom write SetAutoZoom default wpAutoZoomOff;
    //:: The zooming value - ignored for the layout modes thumbnail and wpDualPageView and if  AutoZoom<> off
    property Zooming: Integer read GetZooming write SetZooming default 100;
    {:: The 'Resizing Value'. This affects the reform procedure by increasing the font height
      by a certain percentage. Please don't mix it up with 'Zooming'. If you change the Resizing value
      it will affect all editors which are attached to the same RTFData! }
    property Resizing: Integer read GetResizing write SetResizing default 100;
    //:: Count of pages displayed side by side. Only usuable with the fullpage layout modes
    property PageColumns: Integer read GetPageColumns write SetPageColumns default 1;
    {:: The number of the page which is currently displayed. This is not necessarily
    the page the cursor is in (CPPage). It works with 'PaintPages' and not with 'RTFPages' }
    property PageNumber: Integer read GetPageNumber write SetPageNumber;
    {:: The number of PaintPages we currently display.
    Note: It works with 'PaintPages' and not with 'RTFPages' like function CountPages }
    property PageCount: Integer read GetPageCount;
    {:: The active layout mode. If you chane it or any of the offset and zoom properties you
     need to execute ReorderPages to update the display }
    property LayoutMode: TWPLayoutMode read GetLayoutMode write SetLayoutMode;
    {:: This is the zooming value which is calculated by the RTF-Engine.
        Please note that this value should be used in the event OnChangeZooming. You
        should not use this value after changing 'Zooming' for example since the
        CurrentZooming is updated asynchronly, in the next idele phase
        of the application. }
    property CurrentZooming: Integer read GetCurrentZooming;

    {:: This event is triggered when the <see property="CurrentZooming"> is changed.
        If you need to update the GUI you should use OnChangeViewMode since
        OnChangeZooming is triggered when the actual zoom value is changed.
        This value is controlled by many properties, most important <see property="AutoZoom">. }
    property OnChangeZooming: TNotifyEvent read FOnChangeZooming write FOnChangeZooming;


    {:: The color for the virtual paper. Can be changed in the OnPageInit event }
    property PaperColor: TColor read GetPaperColor write SetPaperColor default clWindow;
    {:: The color for the desktop }
    property ColorDesktop: TColor read GetDeskColor write SetDeskColor default clBtnShadow;
    {:: This is the background color which is used to mark selected text }
    property HighLightColor: TColor read GetHighLightColor write SetHighLightColor default WPDefaultHighlightColor;
    {:: This is the foreground color which is used to mark selected text }
    property HighLightTextColor: TColor read GetHighLightTextColor write SetHighLightTextColor default WPDefaultHighlightTextColor;
    {:: One 'paint page' can be selected. It will be surrounded by a blue reactangel.
      If no page is selected this value is -1 }
  protected
{$IFNDEF T2H}
    // Variables set by 'BeginTable'
    FBeginTable, FBeginTableCreate: Boolean;
    FHistory: array[1..WPHistoryMaxCount] of Char;
    FHistoryPos: Integer;
    FBeginTableName: string;
    FBeginTableL, FBeginTableR, FBeginTableGR: Integer;

    // Set this to true to disable the standard mouse handling
    FIgnoreMouse, FIgnoreMouseMove, FTextObjectSizing, FTableSizing: Boolean;
    FTextObjectSizingMode, FTableSizingMode: TWPPaintSizerRects;
    FTextObjectUnderMouse: TWPTextObj;
    FDisableSelection: Boolean;
    // This variable is TRUE while the mouse button is pressed
    // FMemo._FMouseDown
    // The hosted RTF Engine
    FMemo: TWPRTFEnginePaint;
    _FAfterTextObjectClick: Boolean;
    FCaret: TWPCaret;
    FScrollBars: TScrollStyle;
    FormatWPT, FormatHTM, FormatRTF: Integer;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure CloseAutoLink; // used by KeyPress
    procedure KeyPress(var Key: Char); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DoContextPopup(MousePos: TPoint; var Handled: Boolean); override;
    function DoMouseDownWord(par: TParagraph;
      pos_in_par: Integer; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer): Boolean; virtual;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
{$IFDEF PLAINLINKS}function IsLinkAtParPos(par: TParagraph; pos_in_par: Integer): string; {$ENDIF}
    procedure Click; override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;

    procedure DoPaintStart(Sender: TObject; ThisDoubleBuffer: TBitmap); virtual;
    procedure DoPaintEnd(Sender: TObject); virtual;
    procedure AfterPrepareDoubleBuffer(Sender: TObject); virtual;
    procedure DoBroadcastMsg(Sender: TWPRTFEnginePaint; var Code: Integer; Param: TObject); virtual;
    procedure KillFocus; virtual;
    procedure GetFocus; virtual;
    procedure DoHyperlinkEvent(openObj: TWPTextObj); virtual;
//######## User Interaction
    procedure DoClick(PageNo, X, Y: Integer);
    procedure DoDblClick(PageNo, X, Y: Integer);
//######## SOME WINDOWS STUFF ##################################################
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMGetDlgCode(var Message: TWMGetDlgCode); message WM_GETDLGCODE;
{$IFDEF USETIMER}
    procedure WMTimer(var Message: TMessage); message WM_TIMER;
{$ENDIF}
{$IFNDEF NOFILEMANSUPPORT}
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
{$ENDIF}
{$IFDEF IMEINPUT}
    procedure WndProc(var Message: TMessage); override;
    procedure WMIMEStartComposition(var Message: TMessage); message WM_IME_STARTCOMPOSITION;
    procedure WMIMEEndComposition(var Message: TMessage); message WM_IME_ENDCOMPOSITION;
    procedure WMIMEComposition(var Message: TMessage); message WM_IME_COMPOSITION;
{$ENDIF}
    procedure WMHScroll(var Message: TWMScroll); message WM_HSCROLL;
    procedure WMVScroll(var Message: TWMScroll); message WM_VSCROLL;

    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;

    function DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    function DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean; override;
    procedure DoChangeScrollPosition(Sender: TObject;
      RTFEngine: TWPRTFEnginePaint; HorzScroll: Boolean; var Ignore: Boolean); virtual;
    procedure ProcessMessages;
    procedure WMWPTOOLSUPDATE(var Message: TMessage); message WM_WPTOOLSUPDATE;
    procedure DoUpdate(WPUPD_Code, Param: Integer); virtual;
    function GetRTFEngine: TWPRTFEngineBasis; override;
    function GetRTData: TWPRTFDataCollection; override;
    procedure DoAfterCompleteWordEvent(var key: Char); virtual;
    procedure AddHistoryChar(aChar: Char);
    procedure InternBeforePasteEvent(RTFData: TWPRTFDataCollection;
      Stream: TStream; Reader: TWPCustomTextReader; OnlyBodyText: Boolean; var LoadedText: TWPRTFDataBlock); virtual;
{$ENDIF}
  public
    _InputCodeMarker: Integer;
    _NoDelayedUpdate: Boolean;
    constructor Create(AOwner: TComponent); override;
    {:: This constructor creates a dynamic RTF-Engine. Please note that since it
    has no window handle the delayed reformat does not work.
    So the text will be never reformatted. Please make sure that you execute
    ReformatAll when, and only when, you need the text to be formatted.
    <br>C++Developers need to call the regular constructore and after that the
    function _MakeDynamic();
     }
    constructor CreateDynamic;
    {:: This procedure can be used to prepare the editor to be destroyed. This can be useful
    to avoid AV problems when closing a form which consists of different linked controls, such as a TWPPreview and ad a TWPRichText. }
    procedure BeforeDestruction; override;

    (*:: If you are using C++Builder and cannot use the
       "CreateDynamic" construcor simply use the regular constructor
       and call MakeDynamic.
     <code>
  void __fastcall TForm1::Button1Click(TObject *Sender)
{
   TWPCustomRtfEdit *test = new TWPCustomRtfEdit();
   test->_MakeDynamic();

   test->InputString("Some text");

   test->ReformatAll(true, false);

   test->PrintPages(1,MaxInt);

  //different test:
  // WPRichText1->AsString = test->AsString;

   delete test;
}
     </code>

        *)
    procedure _MakeDynamic;
    procedure _RefreshMsglist;
    {:: This functions retrieves the last characters which were typed since
    the last movement of the cursor. The maximum length of the string which can be
    retrieved is count with an upper limit of WPHistoryMaxCount (=40).<br>
    This function is used by the auto-detect-hyperlinks feature
    (<see property="EditOptions">) and can also be very useful to display
    hints when certain character combinations are pressed. The history is implemented
    using an efficient circular buffer. Backspace will delete the last typed character. }
    function GetHistoryChars(count: Integer): string;

    {:: This procedure executes the delayed operations which were not executed
    before due to Begin/EndUpdate or because the editor was created with <see method="CreateDynamic">. }
    procedure ProcessDelayedUpdates;
    {:: This procedure changes the width and the height of the control
    accodingly to the property <see property="EditBoxModes">. Note that
    this will only work if the <see property="LayoutMode"> has been set to
    wplayNormal }
    procedure UpdateEditBox;
    procedure DelayedReformat; virtual;
    {:: Use this procedure to attach a TWPRTFDataCollection or a TWPRTFProps object to the RTF engine
      This must be done before the RTF-Engine is used the first time }
    procedure SetRTFDataOrProps(NewRTFData: TWPRTFDataCollection; NewRTFProps: TWPRTFProps);
    destructor Destroy; override;
    procedure ShowCursor; virtual;
    procedure Paint; override;
    function PaintPageOnCanvas(PaintPageNr: Integer;
      x, y, pw, ph: Integer; DestCanvas: TCanvas;
      PaintMode: TWPPaintModes = []; DestXRes: Integer = 0;
      DestYRes: Integer = 0; ClipY: Integer = -1; ClipH: Integer = -1;
      PaintPageMode: TWPRTFEnginePaintPagesModes = [wpUseProvidedWidthHeight]): Boolean;
    function Draw(outCanvas: TCanvas;
      x, y: Integer; // The offset
      h: Integer; // The height to be filled
      xres, yres: Integer; // For x,y,h
      starty: Integer; // from last run
      HandlePageBreaks: Boolean = FALSE): Integer; overload;
    function Draw(outCanvas: TCanvas;
      r: TRect;
      zoom: Integer;
      starty: Integer; // from last run
      HandlePageBreaks: Boolean = FALSE): Integer; overload;
    {:: This function returns the y value of the last line
    which was printed by function Draw(). It is measured in
    twips. }
    function PrintBottomPos: Integer;
    procedure SetFocus; override;
    procedure DoUpdateParAttr; virtual;
    procedure DoUpdateCharAttr; virtual;
    procedure DoUpdateEditState; virtual;
    procedure DoUpdateUndoState; virtual;
    {:: Utility procedure to process a scroll event. Internally used }
    procedure ProcessScrollEvent(var Message: TWMScroll; vertical: Boolean);
    procedure Repaint; override;
    procedure Invalidate; override;
    {:: This procedure cazses the window to be refreshed after the
       application was idle for 800 mms. }
    procedure DelayedInvalidate;
    {:: This function moves the cursor to a certain Screen coordinate. }
    function CPMoveTo(X, Y: Integer; DontLeaveDataBlock: Boolean = FALSE): Boolean;
    //: Updates the properties MouseX, MouseY, MousePage. The page number (MousePage) is returned
    function CalcMousePageAtXY(WindowX, WindowY: Integer): Integer;
    {:: This function calculates the coordinates of the line which contains a
    certain position of a certain paragraph in screen coordinates. This function is
    used by the ruler to update the text area but can also be used to invert a block on
    the screen or for similar effects. If the parameter CharOffset = TRUE this function calculates
    the position of a single character.<br>
    <code>
      var x,y,w,h : Integer;
begin
    WPRichText1.GetTextScreenRect(
         WPRichText1.Memo.Cursor.active_paragraph,
         WPRichText1.Memo.Cursor.active_posinpar,
         x,y,w,h );
   WPRichText1.Canvas.Brush.Style := bsClear;
   WPRichText1.Canvas.Pen.Color := clRed;
   WPRichText1.Canvas.Rectangle(x,y,x+w,y+h);
end;

    </code>
    }
    function GetTextScreenRect(par: TParagraph; posinpar: Integer; var x, y, w, h: Integer;
      CharOffset: Boolean = FALSE): Boolean;
    {:: Converts the Screen X,Y Position to a RTF-Page Nr and Position on this
      Page which uses the resolution which was used to initialize the text. }
    function ScreenToRTFPage(ScreenX, ScreenY: Integer; var X, Y, RTFPageNr: Integer;
      IgnoreX: Boolean = FALSE): Boolean;
    {:: This function finds the paragraph at a certain screen position. It can be used in the
    OnMouseMove event to locate the text under the mouse without moving the caret.
      <code>
procedure TForm1.WPRichText1MouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var  par: TParagraph;
     e, posinpar: Integer;
begin
  if WPRichText1.GetLineFromXY(X,Y, par,posinpar)  then
  begin
    e := posinpar;
    while (posinpar>0) and not par.IsWordDelimiter(posinpar) do dec(posinpar);
    while (e<par.CharCount) and not par.IsWordDelimiter(e) do inc(e);
    StatusLabel.Caption := par.GetSubText(posinpar, e-posinpar);
  end;
end;
      </code>
     }
    function GetLineFromXY(ScreenX, ScreenY: Integer;
      var par: TParagraph; var posinpar: Integer): Boolean;
    {:: This function converts a mouse position into a page position in twips.
      This is useful to place images in Drag&amp;Drop operations.
      The parameter 'par' will be set to the first paragraph on this page. }
    function GetPageXYfromXY(ScreenX, ScreenY: Integer;
      var PageNr, PageXTW, PageYTW: Integer;
      var par: TParagraph): Boolean;

    {:: This function finds the TWPTextObj at a certain screen position. }
    function GetObjectFromXY(ScreenX, ScreenY: Integer;
      var TextObject: TWPTextObj): Boolean;
    {:: Returns the paragraph with the given index  }
    function GetPar(ParIndex: Integer): TParagraph;

    //: Don't update the screen (can be nested!)
    procedure LockScreen;
    //: Allow updating the screen agaian (afzter loccking with LockScreen). Does not paint the window at once!
    procedure UnLockScreen(RestoreScrollPosition: Boolean);
    {:: This procedure is used to attach dialogs which are implemented in external code or which
        have been attached using the OnOpenDialog event }
    function OpenDialog(DialogType: TWPCustomRtfEditDialog): Boolean; virtual;
    {:: This procedure is used by GUI elements to change the current writing mode. }
    procedure OnToolBarSelection(Sender: TObject; var Typ: TWpSelNr;
      const str: string; const num: Integer); virtual;
    {:: This procedure is executed before an image object is saved. It is ideal
      to add code to compress the image ro to save it to file or database.
    }
    procedure DoPrepareImageforSaving(RTFData: TWPRTFDataCollection; Writer: TWPCustomTextWriter;
      TextObject: TWPTextObj; var DontSave: Boolean); virtual;
    {:: This procedure is executed after an image object was saved. It is ideal
      to clean up temporary objects created in DoPrepareImageforSaving }
    procedure DoAfterImageSaving(RTFData: TWPRTFDataCollection;
      Writer: TWPCustomTextWriter; TextObject: TWPTextObj);

    {:: This procedure is exeucted when loading a file with an linked image. }
    procedure DoRequestHTTPImage(RTFData: TWPRTFDataCollection;
      Reader: TWPCustomTextReader; const LoadPath, URL: string;
      TextObject: TWPTextObj; var Ok: Boolean); virtual;

    {:: This function is called after the control has received the focus. }
    procedure SetFocusValues(Always: Boolean); virtual;

    procedure DeleteFocusValues; virtual;
    //:: Initialize when required, reformat when required, reorder pages and paint
    procedure Refresh(SpellCheck: Boolean = FALSE); virtual; // override;
    //:: Inside all mouse event you can abort the further processing
    procedure IgnoreMouse;
    {:: This procedure is used to draw a line over the text, for example if
    the user changes the indents using the ruler.
    The Position is passed as screen coordinate. }
    procedure FrameLine(Mode: TWPFrameLineMode; ScreenPos: Integer = 0);

    // Select Procedure --------------------------------------------------------
    {:: Removes the selection. This does not delete text, it simply removes the selection mark. If
    the text was selected the result value is TRUE, otherwise it is FALSE. }
    function HideSelection: Boolean;
    {:: Deletes the selected text and the selection mark. If
    the text was selected the result value is TRUE, otherwise it is FALSE. }
    function ClearSelection(OverwriteProtection: Boolean = FALSE): Boolean;
    {:: Selectes the complete text }
    procedure SelectAll;
    {:: Selects the given or the current paragraph }
    procedure SelectParagraph(par: TParagraph = nil);
    {:: Selects the text from the start of the give page nr startpage (0..) until the start of the
    page which is following <i>endpage</i>.<br>Note: If inside a table the selection will
    not work since it is not possible to select parts of a cell. }
    function SelectPages(startpage, endpage: Integer): Boolean;
    {:: Selects the text from the start of the give page nr startpage (0..) until the start of the
    following page.<br>Note: If inside a table the selection will not work since it is not
    possible to select parts of a cell. }
    function SelectPage(pagenr: Integer): Boolean;
    {:: Reads the text of certain pages. Internally uses SelectPages. Note: If inside a table
    the extraction will not work since it is not possible to select parts of a cell.
    This procedure has been only provided for better compatibility with WPTools Version4. }
    function GetPagesAsString(frompage, topage: Integer; const format: string = 'ANSI'): string;
    {:: Selects the word at the cursor position }
    procedure SelectWord;
    {:: Selects (only) the given or the current cell. If the parameter 'add' is TRUE
      the previously selected cells will not be deselected. If the parameter 'add' is true and the
      cell is already selected it will be deselected! }
    procedure SelectCell(par: TParagraph = nil; add: Boolean = FALSE);

    {:: Selects the current line }
    procedure SelectLine;

    procedure SetScrollBarSize(horz: Boolean);

    procedure MovePosition(how: TWPMoveMode; DoSelection: Boolean);
    {:: This procedure retrieves the current absolute character position (the same as CPPosition),
       Line number and Paragraph number  }
    procedure GetPosition(var pos, lin, par, pos_in_par: Integer);
    {:: This procedure moves the cursor to the given position by using the
    variable topos, tolin or topar/topos_in_par if its respective value is <> 0 }
    procedure SetPosition(topos, tolin, topar, topos_in_par: Integer);

    {:: This procedure moves the cursor to the given X,Y position in client coordinates }
    procedure SetPositionXY(X, Y: Integer);

    {:: This procedure can be used to move to a certain position in the text.
        The relative x and y position is the desired x and y offset from the top
        left corner in pixels }
    procedure ScrollToPosition(pos: Longint; relx, rely: Integer);

    {:: Selects text. If the UpdateDisplay is true the screen will be updated,
    the default mode is to not update the screen }
    procedure SetSelPosLen(pos, len: Integer; UpdateDisplay: Boolean = FALSE);
    {:: Retrieves the start position and the length of the selection. Returns TRUE if text is actually selected }
    function GetSelPosLen(var pos, len: Integer): Boolean;
    {:: This function returns a formt name for a certain clipboard fromat ID,
      such as 'CF_TEXT'. }
    function ClipbrdFormatName(cfFormat: Integer): string;

    {:: Paste the text which is in the clipboard }
    procedure PasteFromClipboard; virtual;
    {:: Copies the selected text to the clipboard and then deletes the selection }
    procedure CutToClipboard; virtual;
    {:: Copy the selected text, or if CompleteText=TRUE the complete body to
    the clipboard. }
    procedure CopyToClipboard(CompleteText: Boolean = FALSE); virtual;

    {:: Append text from a different texdt buffer as a new section }
    function AppendAsSection(FromEditor: TWPCustomRtfEdit): TWPRTFSectionProps;


    // "Fast" Procedures -------------------------------------------------------
    function FastAppendText(source: TWPCustomRtfEdit;
      AsNewSection: Boolean = FALSE): TWPRTFSectionProps;
    procedure FastAppendTextParID(source: TWPCustomRtfEdit; id: Integer; ProtectedFlag: Boolean);
    procedure FastAppendTextWithParID(source: TWPCustomRtfEdit; id: Integer);
    function FastAppendActiveLine(source: TWPCustomRtfEdit): Boolean;

    // State procedure - for compativility -------------------------------------
    //:: Retrieves the correct number (Index) for a certain font
    function GetFontNr(AName: TFontName): Integer;
    //:: Retrieves the name of the font with the given index
    function GetFontName(nr: Integer): TFontName;
    //:: Retrieves the style number for a certain style name
    function GetStyleNrForName(const StyleName: string): Integer;
    //:: Retrieves the name for a style with a certain name
    function GetStyleNameForNr(const StyleNr: Integer): string;
    //:: Retrieves the correct number for a certain color. Also see <see method="NrToColor">
    function GetColorNr(aColor: TColor): Integer;
    //:: Retrieves the correct color for a certain color index. Also see <see method="GetColorNr">
    function NrToColor(ColorIndex: Integer): TColor;

    // Input Procedures --------------------------------------------------------
    {:: Checks wether text can be currently entered in the RTF engine. If the
       RTF engine is empty it creates a new RTF text }
    function CheckHasBody: Boolean;

    {:: Low level function to insert a new TWPTextObj instance. This function works
    similar to <see class="TParagraph" method="AppendNewObject"> and
    <see class="TParagraph" method="InsertNewObject"> but always inserts the
    object at the cursor position. The cursor is then moved after the new object.
    This function requires a call to <see method="DelayedReformat">. }
    function InputNewObject(objtype: TWPTextObjType;
      HasClosing: Boolean = FALSE; IsClosing: Boolean = FALSE; CharAttrIndex: Cardinal = 0): TWPTextObj;

    {:: Inserts text at the current writing position. Optionally a codepage can be specified!
        The control codes #127 for "Delete", #8 (backspace), #13 (carriage Return)
        #12 (Form feed) and #10 (new line) are handled }
    procedure InputString(const Text: AnsiString; CodePage: Integer = 0);

    procedure InputStringInt(const Value: Integer);

    //:: Inserts text at the current writing position. Does not handle control codes like <see method="InputString">!
    procedure InputStringW(const Text: WideString);

    //:: Deletes Count character at cursor position
    procedure DeleteChar(Count: Integer = 1);

    {:: Supported by WPTools Premium only:<br>
      Create a new footnote with optional text. Optionally places the cursor into the
      new footnote to let the user edit the text.
      Using the optional 'Mode' parameter you can also disable the creation of a number and
      optionally select super script for the created number. }
    function InputFootnote(InitText: string = #32; Mode: TWPInputFootnoteModes = []): TWPTextObj; overload;
    {:: This is the old implementation of InputFootnote, you will get more features when
    using the new InputFootnote(InitText, Mode). }
    function InputFootnote(PlaceCursor: Boolean; CreateNumber: Boolean = TRUE;
      InitText: string = #32): TWPTextObj; overload;


    // Replaced by InputMergeField:
{$IFDEF T2H}
    {:depreciated}
    function InputField(c: Char; const text, fieldname: string): Integer;
{$ENDIF}
    function InputMergeField(
      const FieldName: string;
      const DisplayText: string = '';
      Command: string = '';
      Format: Integer = 0;
      DisplayChar: Char = #0 //<-- obsolete parameter!
      ): TWPTextObj;
    function InputEditField(const FieldName: string;
      DisplayText: string = '';
      PlaceCaret: Boolean = FALSE;
      Command: string = '';
      Format: Integer = 0): TWPTextObj;

    {:: Reads the text which is displayed inside of the field with the given name.
     Please note that you can also use twptextobj.EmbeddedText;  }

    function FieldReadText(const fieldname: string): string;

    {:: Fills a string list will the names of all fields in the document. }

    procedure FieldGetNames(list: TStrings; FromAllBlock: Boolean = FALSE);

    // function GetFieldName(tag: Integer): string;


    {:: Get the field which contains the text in the given
        paragraph at the given position. If the given position actually <b>is</b>
  a mergefield start or end tag it is returned, too!
      <br>  This function is implemented as: <code>
function TWPCustomRtfEdit.FieldGetInPar(par: TParagraph; posinpar: Integer): TWPTextObj;
begin
  if (par=nil) or (posinpar<0) then
      Result := nil
  else
  begin
    Result := par.ObjectRef[posinpar];
    if (Result<>nil) and (Result.ObjType=wpobjMergeField) then exit;
    Result := CodeInsideOf(par, posinpar, wpobjMergeField);
  end;
end;
   </code>     }

    function FieldGetInPar(par: TParagraph; posinpar: Integer): TWPTextObj;

    {:: Get the name of the field which contains the text in the given
    paragraph at the given position. If the given position actually <b>is</b> a mergefield start or end tag
    its name is returned, too!  Please also see function <see method="FieldGetInPar">.  }

    function FieldGetNameInPar(par: TParagraph; posinpar: Integer): string;
    {:: Delete all mail merge fields but keeps the merged text. }
    procedure DeleteFields;
    {:: Delete a certain mail merge fields but keeps the merged text. }
    procedure DeleteField(const AName: string);


    {:: list a list with references to fields which all start with
    a given text. The comarision is case sensitive! This list which will be filled must be created:
    list := TWPTextObjList.Create; }
    procedure FieldGetList(
      list: TWPTextObjList; FromAllBlock: Boolean = FALSE;
      NameStartWith: string = '');

    {:: Renames all occurances of a certain field.
      Returns the count of renames - this includes opening and closing tags! }
    function FieldRename(OldName, NewName: string;
      FromAllBlocks: Boolean = TRUE;
      CaseSensitive: Boolean = TRUE): Integer;

    {:: returns the name of the field the cursor is currently in }

    function CurrentEditField: string;

    {:: This function provides a reference to the field at the cursor position. The cursor may
    be before the field or inside. Please note that always the start object for that field
    is reported, even if the cursor is at the end object.  }
    function FieldAtCP: TWPTextObj;

    {:: Checks if a certain field exists in the text. Does not move the cursor! }
    function FieldExists(const fieldname: string): Boolean;


    {:: Moves the cursor to a certain field. You can use this code to move to the next
    field with a given name. This works prefectly when we are in form fill mode, too.
    To enter the form filling mode set the property : ProtectedProp := [ppAllExceptForEditFields].
    <code>
   // If this is the current, move on ...
   if DataEdit.CurrentEditField=fieldname then
        DataEdit.MoveToNextField(false);
   // Try from here
   if DataEdit.MoveToField(fieldname,false) then
      DataEdit.SelectFieldAtCP(false, true)
   // or from start
   else if DataEdit.MoveToField(fieldname,true) then
      DataEdit.SelectFieldAtCP(false, true);
   DataEdit.SetFocus;
    </code> }
    function MoveToField(const fieldname: string; from_start: Boolean = TRUE): Boolean;

    {:: Moves the cursor to the next field and returns its name }
    function MoveToNextField(from_start: Boolean = FALSE): string;

    {:: Moves the cursor to the previous field and returns its name.

    <code>
var s: string;
begin
  s := WPRichText1.MoveToNextField(false);
  Label1.Caption := s;
  if s <> '' then
    WPRichText1.SelectFieldAtCP(false, true);
  WPRichText1.SetFocus;
end;

var s: string;
begin
  s := WPRichText1.MoveToPreviousField(false);
  Label1.Caption := s;
  if s <> '' then
    WPRichText1.SelectFieldAtCP(false, true);
  WPRichText1.SetFocus;
end;
    </code>

     }
    function MoveToPreviousField(from_end: Boolean = false): string;

    {:: Deletes the field at the cursor position }
    function DeleteFieldAtCP: Boolean;

    {:: Selects the field at the cursor position }
    function SelectFieldAtCP(IncludingTags: Boolean = TRUE;
      PlaceCursorBetweenTags: Boolean = FALSE): Boolean;
    {:: Replaces  text such as &gt;NAME&lt; by mailmerge fields. Works in the
    text which is currently active }
    function ReplaceTokens(const opening, closing: string): Integer;
    {:: Replaces  text such as &gt;NAME&lt; by mailmerge fields. Processes all texts.
        Also see <see method="ReplaceTokensInAllTexts">. }
    function ReplaceTokensInAllTexts(const opening, closing: string): Integer;

    {:: Start the merge procedure. If a name is provided only the fields with this name will be used.
        If 'AllText' = TRUE all texts in the data collection will be merged, otherwise
        the procedure will only work with the text which is displayed in the editor, or the body
        text if no text is displayed.<br>
     }
    procedure MergeText(const FieldName: string = ''; AllTexts: Boolean = FALSE); virtual;
    {:: This procedure merges all fields in the active text, this is the text the cursor is located in. }
    procedure MergeActiveText(const FieldName: string = '');

    {:: Enumberate the mail merge fields. If a name is provided only the fields with this name will be used }
    procedure MergeEnumFields(const FieldName: string = ''; AllTexts: Boolean = FALSE);
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    // Support for codes
    {:: The function OpenCodes fills a list with references to TTextObj instances which
      are used embedded codes.
      It returns the first code which was found.
      The following codes are possible:<br>
       wpobjCustom - can be anything - use 'is' operator <br>
       wpobjMergeField,<br>
       wpobjHyperlink,<br>
       wpobjBookmark,<br>
       wpobjTextProtection -  Text cannot be edited within<br>
       wpobjSPANStyle - Special texts styles<br>
       wpobjCode - Custom Codes<br>
       The following object types are usually used sigular and should not be
       used with 'OpenCodes'.
       wpobjTextObject,wpobjPageSize,wpobjPageProps,wpobjFootnote,wpobjImage.
       <br>
       Upgrade note: In WPTools 4 the declaration was:
       <code>function  OpenCodes(par: PTParagraph; lin: PTLine; pos: Integer;
         List: TList; Code: TTextObjCodes): Integer; The references it collected were integers (tag), not
         object references.</code> }
    function OpenCodes(par: TParagraph; PosInPar: Integer;
      List: TWPTextObjList; CheckedCodes: TWPTextObjTypes;
      MaxCount: Integer = 0): TWPTextObj; overload;
    {:: Works like OpenCodes(par: TParagraph; PosInPar: Integer ...
        but is used with x and y as screen-client coordinates. This makes it easy
        to use this function in the MouseDown or similar event. Please
        note that OpenCodes checks for <u>all</u> open object brackets and can
        be so quite slow in long text. Procedure <see method="CodeInsideOf">
        only looks for a certain object type (such as meil merge fields) and
        can be sometimes the better choice }
    function OpenCodes(x, y: Integer;
      List: TWPTextObjList; CheckedCodes: TWPTextObjTypes;
      MaxCount: Integer = 0): TWPTextObj; overload;

    {:: Works like <see method="OpenCodes"> for the codes at the current cursor position}
    function OpenCodesAtCP(List: TWPTextObjList; Code: TWPTextObjType): TWPTextObj;
    {:: Checks if a certain position lies within a certain object }
    function OpenCodeAt(par: TParagraph; PosInPar: Integer;
      CheckedCodes: TWPTextObjTypes): TWPTextObj; overload;

    function OpenCodeAt(x, y: Integer;
      CheckedCodes: TWPTextObjTypes): TWPTextObj; overload;
    {:: This functions works similar to the function
       <see method="GetCodeTags"> but does not create a TWPTextObjList instance. }
    function GetCodeTags(List: TWPTextObjList; Code: TWPTextObjType;
      AName: string = '*ALL*'; GlobalSearch: Boolean = FALSE): Boolean;
    // not supported:
    // function  FindCodeFromTagList(var StartPar: PTParagraph; var StartLin: PTLine; var CP: Integer; TagList: TList): Integer;
    // function  FindCodesFromTagList(Pars, Lines, CPs, Tags, TagList: TList): Integer;
    // function  FindCode(Closing: Boolean;
    //  var StartPar: PTParagraph; var StartLin: PTLine; var CP: Integer; Tag: Integer): PTAttr;
    // procedure RefreshCodes;
    {:: This function deletes a single code. Unlike the
    function  DeleteCode(Closing: Boolean;
      StartPar: PTParagraph; StartLin: PTLine; CP: Integer; Tag: Integer): PTParagraph;
    procedure DeleteCodesFromList(List : TList);  }
    {::  This function creates a TWPTextObjList and fills it with all objects which have a certain
     type. Internally <see method="GetCodeTags"> is used.

This functions fills a list with TTextObj instances with the
      given type (Code) and name (if <>'')<br>
      <br>
      This sample code renames all bookmarks in the document:<br>
      <code>
  objlist := WPRichText1.CodeListTags(wpobjBookmark, '*ALL*', true);
  for i:=0 to objlist.Count-1 do
  if objlist.Closing[i]<>nil then
  begin
      objlist[i].Name := objlist[i].Name + '_changed';
      objlist.Closing[i].Name := objlist[i].Name;
  end;
  objlist.Free;
     </code>
     Alternatively the loop
     <code>
     for i:=0 to objlist.Count-1 do
       objlist.Names[i] := objlist.Names[i] + '_changed';
     </code>
     can be used.
     }
    function CodeListTags(Code: TWPTextObjType;
      AName: string = '*ALL*'; GlobalSearch: Boolean = FALSE): TWPTextObjList;

    {:: This function returns true if the text containes any special codes. It
      is optimized for speed to quickly check if fields or links exist in the document.
      Optionally a staring paragraph can be provided. If this is not nil, this paragraphs
      and all its siblings will be checked. GlobalSearch MUST be false in this case! }
    function CodeExistInText(Code: TWPTextObjType; GlobalSearch: Boolean;
      StartPar: TParagraph = nil): Boolean;

    {::  }
    function CodeInsideOf(par: TParagraph; posinpar: Integer; ObjType: TWPTextObjType): TWPTextObj; overload;
    function CodeInsideOf(x, y: Integer; ObjType: TWPTextObjType): TWPTextObj; overload;
    //:: This version is useful if you need to do further checks on the par/posinpar
    function CodeInsideOf(x, y: Integer; ObjType: TWPTextObjType; var par: TParagraph; var pos_in_par: Integer): TWPTextObj; overload;
    function CodeInsideOf(ObjType: TWPTextObjType): TWPTextObj; overload;

    {:: This function moves the cursor at a certain code. It compares the name if it is not '*ALL*',
    the type and checks wether the mode and the given CmpModes have union elements.
    CmpModes Is not checked if [] }
    function CodeMoveTo(const AName: string; Code: TWPTextObjType;
      CmpModes: TWPTextObjModes = [wpobjIsOpening];
      LocateOptions: TWPCodeLocateOptions = [wpCompareName]): Boolean;
    {:: Works like <see method="CodeMoveTo"> but sets the result
        variables ResultPar and ResultPosInPar }
    function CodeLocate(var ResultPar: TParagraph;
      var ResultPosInPar: Integer; const AName: string; Code: TWPTextObjType;
      CmpModes: TWPTextObjModes = [wpobjIsOpening];
      LocateOptions: TWPCodeLocateOptions = [wpCompareName];
      CmpStr2: string = ''): Boolean;

    {:: This function changes the the name of all codes which are using a certain
    object type. It us used by <see method="FieldRename">. }
    function CodeRename(ObjType: TWPTextObjType; OldName, NewName: string; FromAllBlocks: Boolean = TRUE;
      CaseSensitive: Boolean = TRUE): Integer;

    {:: Selects the text within a certain object. If the optional parameter "OnlyText" is true
    only the text within the codes is selected. The option parameter StopAtParEnd controls wether
    the search for the end tag stops at the end of the paragraph or not (=default).<br>
    <br>
    Upgrade note: In WPTools 4 the declaration was:
    <code>function CodeSelect(const Name: string; Code: TTextObjCodes;OnlyText: Boolean):Boolean;</code> }
    function CodeSelect(const AName: string; Code: TWPTextObjType;
      OnlyText: Boolean = FALSE; StopAtParEnd: Boolean = FALSE;
      LocateOptions: TWPCodeLocateOptions = [wpCompareName]): Boolean;
    {:: This function checks if there is a text object at the given position }
    function CodeObjectAtXY(x, y: Integer; var Code: TWPTextObj): Boolean;

    {:: Selects the text within the give tag and the coresponding end tag.
    Optionally the tags can be also selected.
    <br>
    This code selects the hyperlink at the current position and
    assigns a large font:
    <code>
    if WPRichText1.CodeSelectText(WPRichText1.HyperlinkAtCP) then
      WPRichText1.SelectedTextAttr.SetFontSize(22);
    </code>
    }
    function CodeSelectText(StartTag: TWPTextObj; IncludingTags: Boolean = FALSE): Boolean;

    {:: Create a new code pair at cursor position and return a reference to the opening object (=TWPTextObj).
     <br>
     available options are:<br>
     wpinpWrapSelectedText - wrap the selected text in the given codes<br>
      wpinpDeleteSelectedText -  Replace the selected text with the code pair<br>
    wpinpPlaceCursorAfterStart - Position the cursor after the start point<br>
    wpinpDropMarkersOutside - First drop markers before the start and after the end code<br>
    wpinpDropMarkersWithin  - Then drop markers after start code and before end code<br>
     See Cursor.SelectMarker for information about markers. The last marker
     dropped by InputCode has the value _InputCodeMarker. You can access the previous
     1 or 3 using _InputCodeMarker-1  }
    function InputCode(Code: TWPTextObjType; const AName: string = '';
      const command: string = ''; Options: TWPInputCodeOptions = []): TWPTextObj;
    {:: Create a new single code and return a reference to a TWPTextObj }
    function InputSingleCode(Code: TWPTextObjType;
      const AName: string = ''; const Command: string = ''): TWPTextObj;

   //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    function Undo: Boolean;
    function Redo: Boolean;
    function CanUndo: Boolean;
    function CanRedo: Boolean;
    procedure UndoClear;
    procedure StartUndolevel;
    procedure NewUndolevel;
    procedure EndUndolevel;
{$IFDEF ALLOWUNDO}
    procedure UndoBufferSaveTo(aStyle: TWPTextStyle; typ: TWPUndoType; kind: TWPUndoKind = wputAny);
{$ENDIF}
    //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    {:: This procedure erases the complete text buffer (<see class="TWPRTFDataCollection">).
      If you want to add text you need to create a new <see class="TWPRTFDataBlock">,
      for example with the the line ActiveText:=HeaderFooter.Get().
      If you just need a new body text with the cursor placed on a new empty paragraph use
      the procedure CheckHasBody. This procedure is also called when the editor gets the focus.
      <br>
      <code>
  WPRichText1.Clear;
  WPRichText1.ActiveText:= WPRichText1.HeaderFooter.Get(wpIsHeader,wpraOnAllPages,'');
  WPRichText1.TableAdd(4,4,[wptblActivateBorders]);
  WPRichText1.DisplayedText := WPRichText1.BodyText;
  </code>
  The Clear procedure will also delete all styles. If you need to keep those use
    <see method="ClearEx" text="ClearEx(true, false)">.
    The current page size will remain unchanged if the flag wpDontResetPagesizeInClear was used
    in EditOptionsEx.
    <br>This function should not be called when you are working with a shared TWPRTFProps object.
   }

    procedure Clear; virtual;
    {:: This procedure cleares the text, optionally the styles can be kept.
    Optionally the current writing mode can be reset, the font information of the
    <see property="DefaultAttr"> will be then applied. The current page size will remain unchanged if the flag
    DontResetPageSize was set to true. (Also see wpDontResetPagesizeInNew in EditOptionsEx.)
    }
    procedure ClearEx(DontClearStyles, DontResetPageSize, ResetWritingAttr: Boolean);

    procedure ClearBody; virtual;
    procedure Loaded; override;
    {:: This procedure copies the properties and event handlers which
        influence the display (and print) of the text. This are the event handlers for
        watermark printing, object printing and the FormatOpoptions.
        The PrintDialog will use this procedure when a selection is printed to
        set the properties in the temporary memo control.
        note: The Hot-Styles will not be copied! }
    procedure AssignPrintProperties(Source: TWPCustomRtfEdit); virtual;

    {:: Thbis procedure forces an immediate reformat of the text }
    procedure ReformatAll(
      InitializeAll: Boolean = FALSE;
      RepaintMemo: Boolean = FALSE);
   {:: Loops the complete text to calculate the formulas. It can calculate
    paragraph and TWTTextObject formulas (only wpobjTextObj type).
    @cat Calculation }
    function RecalcText(pars, fields: Boolean): Boolean;
    {:: Loads all paragraph names into a list
    @cat Calculation }
    procedure GetCellNames(List: TStrings);
    {:: Loads all paragraph formulas into a list
    @cat Calculation }
    procedure GetCellCommands(List: TStrings);

    {:: Use this procedure to disable any formatting and screen output.
      Within the BeginUpdate and EndUpdate brackets
      any text protection is disabled }
    procedure BeginUpdate;
    {:: See <see method="BeginUpdate">. }
    procedure EndUpdate;

    {:: This procedure deletes a hader with 'Source=nil' or creates a new one for the
    given 'Range' and assigns the source object to it.<br>
    Supported Source objects are the TWPRichText object, Memo and RTFText }
    procedure AssignToHeader(Source: TObject; Range: TWPPagePropertyRange = wpraOnAllPages);
    {:: This procedure deletes a hader with 'Source=nil' or creates a new one for the
    given 'Range' and assigns the source object to it.<br>
    Supported Source objects are the TWPRichText object, Memo and RTFText }
    procedure AssignToFooter(Source: TObject; Range: TWPPagePropertyRange = wpraOnAllPages);
    procedure ClearHeaderFooter;

    function SaveToStream(s: TStream; FormatName: string = ''): Boolean; virtual;
    {:: Loads the contents from a stream. Only if WithClear=TRUE or
    the text is empty (see: <see method="IsEmpty">) the page format
    and header and footer texts and sections are loaded! }
    function LoadFromStream(s: TStream; FormatName: string = ''; WithClear: Boolean = FALSE): Boolean; virtual;
{$IFNDEF CLR}
    function LoadFromBuffer(buffer: PChar; bufferlen: Integer; FormatName: string = ''; WithClear: Boolean = FALSE): Boolean;
{$ENDIF}
    function SaveSelectionToStream(s: TStream; FormatName: string = ''): Boolean; virtual;
    function LoadSelectionFromStream(s: TStream; FormatName: string = ''): Boolean; virtual;
    function SaveToFile(const FileName: string; SelectionOnly: Boolean = FALSE; FormatName: string = ''): Boolean; virtual;
    {:: Loads the contents from a file. Only if WithClear=TRUE or
    the text is empty (see: <see method="IsEmpty">) the page format
    and header and footer texts and sections are loaded! }
    function LoadFromFile(const FileName: string; WithClear: Boolean = FALSE; FormatName: string = ''): Boolean; virtual;
    {:: This function receives the complete contents or the current selection as a string.
      You can use the format strings to retrieve the text is a special format, for
      example AsANSIString('WPTOOLS', true) to also retrieve the selected text. }
    function AsANSIString(FormatName: string = 'ANSI'; OnlySelection: Boolean = FALSE;
      CellsAsParagraphs: Boolean = FALSE): AnsiString; virtual;


  public
    _3RDParty_OnMouseDownWord: TWPMouseDownRightEvent; // For spell check
    _3RDParty_AfterCompleteWord: TWPInternalAfterCompleteWordEvent;
    _3rdParty_MouseLock: Boolean;
    {:: The finder is located in
        Memo.RTFData.Cursor.Finder }

    {:: This event is triggered when the RTFData or RTFProps are required the first time.
    This is the chance to get the objects from a different RTFEditor to have 2 editors working
    with the same text.<br>
    Alternatively you can assign a global TWPRTFProps object to make different RTF editors
    work with different texts but the same properties, such as style and color tables:
    <code>
WPGlobalRTFProps : TWPRTFProps; // global variable

// in the main form, the MDI parent
procedure TWPGlobalStyle.FormCreate(Sender: TObject);
begin
  // Inititialize WPGlobalRTFProps
  WPGlobalRTFProps := TWPRTFProps.Create;
end;
// in the MDI child:
procedure TWPGlobalStyleChild.WPRichText1InitializeRTFDataObject(
  Sender: TObject; var RTFDataObject: TWPRTFDataCollection;
  var RTFPropsObject: TWPRTFProps);
begin
   RTFPropsObject := WPGlobalRTFProps;
end;
    </code>
     }
    {:@event}
    property OnInitializeRTFDataObject: TWPOnInitializeRTFDataObjectEvent
      read FOnInitializeRTFDataObject write FOnInitializeRTFDataObject;
    {:: This event is triggered <b>after</b> the RTFData has been created and the
    FormatOptions and Header properties have been assigned.
    Please note that this event will be only triggered for
    RTFData objects which are created by the memo control, not for objects which are
    created outside. If you want to attach a global RTFData or RTFProps object use
    <see event="OnInitializeRTFDataObject">. }
    {:@event}
    property OnInitializedRTFData: TWPOnInitializeRTFDataObjectEvent
      read FOnInitializedRTFData write FOnInitializedRTFData;

    {:: This event is executed after text was loaded from the clipboad and before
    it is inserted at the cursor position.
     This event makes it possible to modify the text before it is inserted!
     <br>
     This Example changes the attributes of the inserted text to 'Courier, 10.5, blue':
     <code>
procedure TForm1.WPRichText1BeforePasteText(Sender: TObject;
  RTFData: TWPRTFDataCollection; par: TParagraph; Stream: TStream;
  Reader: TWPCustomTextReader; OnlyBodyText: Boolean;
  var LoadedText: TWPRTFDataBlock);
var i : Integer;
    CharAttrIndex : Cardinal;
begin
  // This is an example to change the format
  // of all inserted text to a given font and size

  // 'AttrHelper' is our working horse to create the attribute
  RTFData.RTFProps.AttrHelper.Clear;
  RTFData.RTFProps.AttrHelper.SetFontName('Courier New');
  RTFData.RTFProps.AttrHelper.SetFontSize(10.5);
  RTFData.RTFProps.AttrHelper.SetColor(clBlue);
  CharAttrIndex := RTFData.RTFProps.AttrHelper.CharAttr;

  // At this point we can calculate another CharAttrIndex

  while par<>nil do
  begin
     for i:=0 to par.CharCount-1 do
     begin
        par.CharAttr[i] := CharAttrIndex;
     end;
     par := par.next;
  end;
end;
</code>
     }
    property BeforePasteText: TWPOnBeforePaste read FBeforePasteText write FBeforePasteText;
    property BeforePasteImage: TWPOnBeforePasteImage read FBeforePasteImage write FBeforePasteImage;
    property BeforeDropText: TWPOnBeforeDropText read FBeforeDropText write FBeforeDropText;
    {:: This event is triggered before a file is overwritten by the editor. We suggest to
    make a backup copy of the existing file, maybe even support different versions. Backup copies can be
    also created in special designated 'backup' directories.  }
    property BeforeOverwriteFile: TWPBeforeOverwriteFile read FBeforeOverwriteFile write FBeforeOverwriteFile;
    property BeforeCopyText: TOnBeforeCopyEvent read FBeforeCopyEvent write
      FBeforeCopyEvent;
    property BeforeCutText: TOnBeforeCopyEvent read FBeforeCutEvent write
      FBeforeCutEvent;
    {:: This event can be used to add custom objects to the clipboard }
    property AfterCopyToClipboard: TWPAfterCopyToClipboardEvent read
      FAfterCopyToClipboard write FAfterCopyToClipboard;

    property ImeMode;
    property ImeName;

    property Finder: TWPTextFinder read GetFinder;
    {:: This is the RTF-Engine }
    property Memo: TWPRTFEnginePaint read GetMemo;
    property TextObjects: TWPObjectEnv read GetTextObjects;
    property HeaderFooter: TWPRTFDataCollection read GetHeaderFooter;
    {:: This is a reference to the the <see class="TWPRTFDataCollection"> which stores the
    text blocks. }
    property RTFData: TWPRTFDataCollection read GetHeaderFooter;
    property BodyText: TWPRTFDataBlock read GetBodyText;
    property ScrollBars: TScrollStyle read FScrollBars write SetScrollBars;
    property WantTabs: Boolean read FWantTabs write FWantTabs default TRUE;
    property WantReturns: Boolean read FWantReturns write FWantReturns default TRUE;
    {:: This property modifies the way the editor works. You can protect text outside of
    a table to simulate a spreadsheet, protect the objects and activate or deactivate undo+redo }
    property EditOptions: TWPEditOptions read GetEditOptions write SetEditOptions;
    property EditOptionsEx: TWPEditOptionsEx read GetEditOptionsEx write SetEditOptionsEx default [];
    property ClipboardOptions: TWPClipboardOptions read FClipboardOptions write FClipboardOptions default [];
    property CaretDisabled: Boolean read GetCaretDisabled write SetCaretDisabled default false;
    property TopOffset: Integer read GetTopOffset write SetTopOffset;
    property LeftOffset: Integer read GetLeftOffset write SetLeftOffset;
    {:: This property gives access to the <see class="TWPRtfStrings"> interface of
     the <see property="ActiveText">.

     }
    property Lines: TStrings read GetLines write SetLines;
    property Readonly: Boolean read GetReadonly write SetReadonly default false;
    property Modified: Boolean read GetModified write SetModified;
    {:: This property makes it possible in a WPPreview to limit the display to just one page }
    property SinglePageMode: Boolean read GetSinglePageMode
      write SetSinglePageMode;
    property ViewOptions: TWPViewOptions read GetViewOptions write SetViewOptions default [];
    property FormatOptions: TWPFormatOptions read GetFormatOptions write SetFormatOptions;
    property FormatOptionsEx: TWPFormatOptionsEx read GetFormatOptionsEx write SetFormatOptionsEx; //  default [];

    { Using this property the editor can be forced to resize itself or to
    limit the text which can be entered. The event <see event="OnEditBoxChangeWidth"> will be
    triggered when the editor is resized.
    <br><b>Note:</b> if you use 'auto size' the editor should not
    be resized by other code, such as the 'align' property. }
    property EditBoxModes: TWPEditBoxModes read GetEditBoxModes write SetEditBoxModes default [];
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default FALSE;

    property DrawGrid: Boolean read GetDrawGrid write SetDrawGrid default FALSE;
    property ShowPagenumber: Boolean read GetShowPagenumber write SetShowPagenumber;
    property Columns: Integer read GetColumns write SetColumns;
    property Rows: Integer read GetRows write SetRows;

    property ProtectedProp: TProtectProp read GetProtectProp write SetProtectProp;
    property Inserting: Boolean read GetInserting write SetInserting;
    property OnCheckProtection: TWPCheckProtectedEvent read GetOnCheckProtection write SetOnCheckProtection;

    property OnEditFieldGetSize: TWPEditFieldGetSize read
      GetOnEditFieldGetSize write SetOnEditFieldGetSize;
    property OnEditFieldFocus: TWPEditFieldFocusEvent read
      GetOnEditFieldFocus write SetOnEditFieldFocus;

    property InWaitForPaintEditor: Boolean read FInWaitForPaintEditor write SetInWaitForPaintEditor;

    property InsertPointAttr: TCharacterAttrTags read GetInsertPointAttr write SetInsertPointAttr stored IsTextAttrStored;
    property HyperlinkTextAttr: TCharacterAttrTags read GetHyperlinkTextAttr write SetHyperlinkTextAttr stored IsTextAttrStored;
    property BookmarkTextAttr: TCharacterAttrTags read GetBookmarkTextAttr write SetBookmarkTextAttr stored IsTextAttrStored;
    property SPANObjectTextAttr: TCharacterAttrTags read GetSPANObjectTextAttr write SetSPANObjectTextAttr stored IsTextAttrStored;
    property HiddenTextAttr: TCharacterAttr read GetHiddenTextAttr write SetHiddenTextAttr stored IsTextAttrStored;
    property AutomaticTextAttr: TCharacterAttr read GetAutomaticTextAttr write SetAutomaticTextAttr stored IsTextAttrStored;
    property ProtectedTextAttr: TCharacterAttr read GetProtectedTextAttr write SetProtectedTextAttr stored IsTextAttrStored;
    property FieldObjectTextAttr: TCharacterAttr read GetFieldObjectTextAttr write SetFieldObjectTextAttr stored IsTextAttrStored;

    property WriteObjectMode: TWPObjectWriteRTFModeGlobal read GetWriteObjectMode write SetWriteObjectMode;

    {:: Select a certain writer class for text saving.
        Use RTF, HTML, ANSI, AUTO or the name of the class.<br>
        You can also add write options, see <see class="TWPToolsReaderWriter" method="SetOptions">.
        If you only want to set options but want to keep the automatic format detection
        use <see property="TextLoadSaveOptions">. }
    property TextSaveFormat: string read GetTextSaveFormat write SetTextSaveFormat;
    {:: Select a certain reader class for text loading. Use RTF, HTML, ANSI, AUTO
       or the name of the class.<br>
       You can also add read options, see <see class="TWPToolsReaderWriter" method="SetOptions">.
       If you only want to set options but want to keep the automatic format detection
       use <see property="TextLoadSaveOptions">. }
    property TextLoadFormat: string read GetTextLoadFormat write SetTextLoadFormat;
    {:: Select read and write options, see <see class="TWPToolsReaderWriter" method="SetOptions">, for
    example '-nomergefields' to automatically strip merage fileds when a file
    is saved.The options
        which are specified here are attached to all format strings used by
        the Load and Save procedures of this editor, except for clipboard operations!
        <code>
  ReporterDestText.TextLoadSaveOptions := '-nomergefields,-ignorecollapsedpar';
  try
    ReporterDestText.SaveAs;
  finally
    ReporterDestText.TextLoadSaveOptions := '';
  end;
        </code>  }
    property TextLoadSaveOptions: string read GetTextLoadSaveOptions write SetTextLoadSaveOptions;
{$IFNDEF NOFILEMANSUPPORT}
    {:: If this property is true it is possible to drop image files from the windows explorer
    into the text. You can also modify the <see property="AcceptFilesOptions"> to create a movable images.}
    property AcceptFiles: Boolean read FAcceptFiles write SetAcceptFiles default FALSE;
    {:: Initial options for the created images. (<see property="AcceptFiles">) Dropped images can be movable and
    also linked to external files.
    <code>
  WPRichText1.AcceptFiles := TRUE;
  WPRichText1.AcceptFilesOptions := [wpDropCreatesMovableParObject, wpDropCreatesLinkedImage];
    </code>
    }
    property AcceptFilesOptions: TWPAcceptFilesOptions read FAcceptFilesOptions write
      FAcceptFilesOptions default [];
    {:@event}
    property OnDropFile: TWPOnDropFileEvent read FOnDropFile write FOnDropFile;
{$ENDIF}
    property BorderStyle: TBorderStyle read FBorderStyle write SetBorderStyle default bsNone;
    property Transparent: Boolean read GetTransparent write SetTransparent default FALSE;
    property OnClick: TWPCustomRtfEditClick read FOnClick write FOnClick;
    property OnDblClick: TWPCustomRtfEditClick read FOnDblClick write FOnDblClick;
    {:: This event makes it possible to update the position of an
        external scrollbar. The parameters are automatically limited
        to a maximal value of 20000 my calculating a multiplicator value.
        This values are accessible through the properties
        ScrollVertMultiplicator and ScrollHorzMultiplicator.<br>
        <b>Example:</b><code>
// Update the position of the scrollbar
procedure TForm1.WPRichText1UpdateExternScrollbar(
  Sender: TWPCustomRtfEdit; ScrollBar: TScrollStyle; Range, Page,
  Pos: Integer);
begin
  if ScrollBar=ssVertical then
  begin
  ScrollBar1.PageSize := Page;
  ScrollBar1.Max := Range;
  ScrollBar1.Position := Pos;
  end;
end;

// Change position when Scroll event happens
procedure TForm1.ScrollBar1Scroll(Sender: TObject;
  ScrollCode: TScrollCode; var ScrollPos: Integer);
begin
  WPRichText1.TopOffset := Round(ScrollPos / WPRichText1.ScrollVertMultiplicator);
end;
</code>
         }
    property OnUpdateExternScrollbar: TWPUpdateExternScrollbar read FOnUpdateExternScrollbar write
      FOnUpdateExternScrollbar;
    {:: This event is triggered at print time before printing starts and
    between each page }
    property OnSetupPrinterEvent: TWPSetupPrinterEvent read FOnSetupPrinterEvent write FOnSetupPrinterEvent;

    {:: This event is used with <see property="EditBoxModes"> in <see property="LayoutMode"
       text="LayoutMode=wplayNormal">. Before the editor resizes itself you
       may modify the new width according to the needs of the application or modify the
       layout of the form. OnEditBoxChangeWidth is triggered before OnEditBoxChangeHeight to make it possible
       to adjust, when the <see property="WordWrap"> mode has been activated,
       the width before the height is measured again.
       }
    property OnEditBoxChangeWidth: TWPChangeBoxEvent read FOnEditBoxChangeWidth write FOnEditBoxChangeWidth;
    {:: This event is used with <see property="EditBoxModes"> in <see property="LayoutMode"
       text="LayoutMode=wplayNormal">. Before the editor resizes itself you
       may modify the new height according to the needs of the application or modify the
       layout of the form. }
    property OnEditBoxChangeHeight: TWPChangeBoxEvent read FOnEditBoxChangeHeight write FOnEditBoxChangeHeight;
    {:: This event is triggered when the MergeText or MergeEnumFields procedure is used }
    property OnMailMergeGetText: TWPMailMergeGetTextEvent read FOnMailMergeGetText
      write FOnMailMergeGetText;
    {:: This event makes it possible to set the 'range' for a newly created header or footer.
    It is triggered after a double click in the header or footer area.
    To abort the creation of a header or footer set the 'Range' to wpraIgnored.
    This is the default value unless the flag wpDblClickCreateHeaderFooter was used in property EditOptionsEx.}
    property OnClickCreateHeaderFooter: TWPClickCreateHeaderFooterEvent read FOnClickCreateHeaderFooter write FOnClickCreateHeaderFooter;

    property OnChangeSelection: TNotifyEvent read FOnChangeSelection write FOnChangeSelection;
    property OnUndoStateChanged: TNotifyEvent read FOnUndoStateChanged write FOnUndoStateChanged;
    property BeforeObjectSelection: TNotifyWPTextObjEventIgnore read FBeforeObjectSelection write FBeforeObjectSelection;
    property AfterObjectSelection: TNotifyWPTextObjEvent read FAfterObjectSelection write FAfterObjectSelection;
    {:: This event is triggered when the layout mode, autozoom or zooming is changed }
    property OnChangeViewMode: TNotifyEvent read FOnChangeViewMode write FOnChangeViewMode;
    property OnClickPage: TOnClickPageEvent read FOnClickPage write FOnClickPage;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
    property OnTextObjectMouseMove: TTextObjectMouseEvent read FOnTextObjectMouseMove write FOnTextObjectMouseMove;
    property OnTextObjectMouseDown: TTextObjectMouseEvent read FOnTextObjectMouseDown write FOnTextObjectMouseDown;
    property OnTextObjectMouseUp: TTextObjectMouseEvent read FOnTextObjectMouseUp write FOnTextObjectMouseUp;
    property OnTextObjectClick: TTextObjectClickEvent read FOnTextObjectClick write FOnTextObjectClick;
    property OnTextObjectDblClick: TTextObjectClickEvent read FOnTextObjectDblClick write FOnTextObjectDblClick;
    property OnTextObjectMove: TTextObjectResizeEvent read FOnTextObjectMove write FOnTextObjectMove;
    //:: This event is triggered in the next idle cycle after the StartUpdate procedure
    property OnDelayedUpdate: TWPOnDelayedUpdate read FOnDelayedUpdate write FOnDelayedUpdate;
    property AfterDelayedUpdate: TWPOnDelayedUpdate read FAfterDelayedUpdate write FAfterDelayedUpdate;
    property BeforeEditBoxNeedFocus: TWPAbortNotifyEvent read FBeforeEditBoxNeedFocus write FBeforeEditBoxNeedFocus;
    {:: This event is triggered when the use clicks on text which is surrounded
    by objects which types are present in the property <see property="ClickableCodes">.  }
    property OnClickHotText: TWPClickHotTextEvent read FOnClickHotText write FOnClickHotText;
    {:: This property selects the object classes which can trigger the <see event="OnClickHotText">. }
    property ClickableCodes: TWPTextObjTypes read
      FClickableCodes write FClickableCodes default [wpobjHyperlink];
    property OneClickHyperlink: Boolean read FOneClickHyperlink write
      FOneClickHyperlink;
    {:: This event is triggered wheh the user clicks on a link. The parameter
      'IgnoredNumber' has no meaning.
      The link object is accessible as property <see property="HyperlinkObj">. }
    property HyperLinkEvent: THyperLinkEvent read FHyperLinkEvent write
      FHyperLinkEvent;
    {:: This event is used like OnCustomLinePaintAfter but is triggered before the text has been
    rendered. This makes it possible to draw to the background of the text.
    <br>
    This example code will draw brackets into the left margin to show how paragraphs are linked
    together using the KeepN property:<br>
    <code>
    procedure TWPTBXForm.WPRichText1CustomLinePaintBefore(Sender: TObject;
  RTFEngine: TWPRTFEngineBasis; Param: TWPVirtPagePaintParam;
  EndOfPageRun: Boolean);
var r: TRect; o: Integer; par: TParagraph; thiskeep, prevkeep, nextkeep: Boolean;
begin
  if (Param.Par.ParentTable = nil) and (Param.PaintingInEditor) then
  begin
    if not EndOfPageRun then
    begin
      Param.CallAgainToClose := TRUE; // Make sure we get that EndOfPageRun!
    end else
    begin
      par := Param.Par.prev;
      prevkeep := (par <> nil) and (par.AGetDef(WPAT_ParKeepN, 0) = 1);
      thiskeep := Param.par.AGetDef(WPAT_ParKeepN, 0) = 1;
      nextkeep := TRUE;
      par := Param.Par.next;
      if (par = nil) or (par.AGetDef(WPAT_ParKeepN, 0) = 0) then
      begin
        nextkeep := FALSE;
      end;
      r := Param.UnionRect;
      o := 30;
      Param.Canvas.Pen.Width := 0;
      Param.Canvas.Pen.Color := clRed;
      if thiskeep and not prevkeep then
      begin
        Param.Canvas.MoveTo(r.Left, r.Top);
        Param.Canvas.LineTo(r.Left - o, r.Top);
      end;

      if thiskeep or prevkeep then
      begin
        Param.Canvas.MoveTo(r.Left - o, r.Top);
        Param.Canvas.LineTo(r.Left - o, r.Bottom);
      end;

      if not thiskeep and prevkeep and not nextkeep then
      begin
        Param.Canvas.MoveTo(r.Left - o, r.Bottom);
        Param.Canvas.LineTo(r.Left, r.Bottom);
      end;
    end;
  end;
end;


    </code>
    }
    property OnCustomLinePaintBefore: TWPVirtPagePaintEvent read
      GetOnCustomLinePaintBefore write SetOnCustomLinePaintBefore;
    {:: This event is used like OnCustomLinePaintBefore but is triggered after the text has been
    rendered. This makes it possible to draw over the text.
    Param is an object which is usually reused for each paragraph.
    FirstRect is initialized to the rectangle of the first line
    of this paragraph on the page. Rect is the current rectangle.
    If the property UseUntilIncludingPar is set to a certain paragraph the object is reused for
    all paragraphs until the given one. If CallAgainToClose has been set to
    TRUE the event is triggered again after the last line.
    <br>
    The following example draws a line around each paragraph or
    consecuative paragraphs starting with one which contains $start and
    ends with one which containes $end.
    <code>
    procedure Form1.WPRichText1CustomLinePaintAfter(Sender: TObject;
  RTFEngine: TWPRTFEngineBasis; Param: TWPVirtPagePaintParam;
  EndOfPageRun: Boolean);
var r: TRect; par: TParagraph;
begin
  if not EndOfPageRun then
  begin
    if Param.Tag = 0 then
    begin
      par := Param.Par;
      if par.HasText('$start') then
      begin
        while par <> nil do
        begin
          if par.HasText('$end') then
            break;
        par := par.next;
        end;
        Param.UseUntilIncludingPar := par;
      end;
    end;
    Param.Tag := 1;
    Param.CallAgainToClose := TRUE;
  end
else
  begin
    r := Param.UnionRect;
    Param.Canvas.Brush.Style := bsClear;
    Param.Canvas.Pen.COlor := clRed;
    Param.Canvas.Pen.Width := 0;
    Param.Canvas.Rectangle(
      r.Left, r.Top, r.Right, r.Bottom);
  end;
end; </code>
<br>
Note: The API UnionRect() deals differently with rectangle which have a
height of 0 than Param.UnionRect!.
 }
    property OnCustomLinePaintAfter: TWPVirtPagePaintEvent read
      GetOnCustomLinePaintAfter write SetOnCustomLinePaintAfter;
    {:: This event is triggered before a paragraph is initialized.
    This happens after each change in the paragraph. This event makes it possible
    to prepocess the paragraph, for example to hide it "include(par.prop, paprHidden)"
    or to change the attributes depending on the contents of the paragraph.
    <br>
    This example hides paragraphs which contain empty merge fields and spaces only:<br>
    <code>
      if par.HasObjects(false,[wpobjMergeField]) and
     not par.IsNonSpace([wpobjMergeField]) then
        include(par.prop, paprHidden)
      else  exclude(par.prop, paprHidden);
    </code>
     }
    property BeforeInitializePar: TWPInitializeParEvent read GetBeforeInitializePar write SetBeforeInitializePar;
        {:: This event is triggered by the paint routine for a paragraph which
       uses the flag paprNeedPreparePaintEvent in  'props'. This event
       may update some character properties but no properties which change
       the width of a character. Normally this event is used best
       to implement SpellAsYouGo, otherwise better use <see event="BeforeInitializePar">. }
    property OnPrepareParForPaint: TWPInitializeParEvent read
      GetOnPrepareParForPaint write SetOnPrepareParForPaint;
    property OnWorkOnTextChanged: TNotifyEvent read FOnWorkOnTextChanged write FOnWorkOnTextChanged;
    property OnActivatingHotStyle: TWPActivatingHotStyle read GetOnActivatingHotStyle write SetOnActivatingHotStyle;
    property OnDeactivateHotStyle: TWPDeactivateHotStyle read GetOnDeactivateHotStyle write SetOnDeactivateHotStyle;


    property OnActivateHint: TWPActivateHintEvent read FOnActivateHint write FOnActivateHint;
    property OnClickText: TWPClickTextEvent read FOnClickText write FOnClickText;

    {:: This event is triggered after the cursor has been moved. It is triggered
    asynchronly, in the next idle state. }
    property OnChangeCursorPos: TNotifyEvent read FOnChangeCursorPos write FOnChangeCursorPos;
    {:: This event is triggered when the control is resized. Please use the event
     BeforeResize (not published) if you need to change the zooming value of
     a control which also uses property WordWrap set to true. }
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    {:: This event is triggered before the control is resized - you can use it to adjust the
      zooming value. }
    property BeforeResize: TNotifyEvent read FBeforeResize write FBeforeResize;

    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property AvailableDialogs: TWPCustomRtfEditDialogs read FAvailableDialogs write FAvailableDialogs;
    {:: This event is triggered when a new RTFDataBlock is created.
        This happens at load time or when the text is cleared. Please note that
        header and footer also are RTFDataBlocks.<br>
        <code>
        procedure TForm1.WPRichText1NewRTFDataBlock(Sender: TObject;
  RTFDataBlock: TWPRTFDataBlock);
begin
  if RTFDataBlock.Kind=wpIsBody then
  begin
     // a) Set first paragraph attribute
     // RTFDataBlock.FirstPar.ASetColor(WPAT_CharColor, clRed);
     // RTFDataBlock.FirstPar.ASetFontName('Courier New');

     // b) Set default character attribute
     RTFDataBlock.RTFProps.AttrHelper.Clear;
     RTFDataBlock.RTFProps.AttrHelper.SetFontName('Times new Roman');
     RTFDataBlock.RTFProps.AttrHelper.SetFontSize(9.5);
     RTFDataBlock.FirstPar.LoadedCharAttr :=
        RTFDataBlock.RTFProps.AttrHelper.CharAttr;

     // c) create a default text
     RTFDataBlock.FirstPar.SetText('Please type here ...');
  end;
end;
        </code>
         }
    property OnNewRTFDataBlock: TWPNewRTFDataBlockEvent read FOnNewRTFDataBlock write FOnNewRTFDataBlock;
    {:: This event is used to check the word under the cursor if it is a hyperlink or not.
    <code>
procedure TForm1.DoTestLink(Sender: TObject; par : TParagraph;
      var posinpar, len : Integer; var IsLink : Boolean);
var s : string;
begin
  if par.CompareW(posinpar,'http://') then IsLink := TRUE;
end;
    </code> }
    property OnTestForLinkEvent: TWPTestForLinkEvent read FOnTestForLinkEvent write FOnTestForLinkEvent;
    {:: This event is triggered after a Clear of the TWPRTFDataCollection }
    property OnClear: TNotifyEvent read FOnClear write FOnClear;
    {:: This event is triggered after text was loaded using LoadFromStrea, AsString or LoadFromFile.
    It will also be triggered if text was inserted or pasted! This event can be used to
    preprocess the loaded text, for example to set protection markers. }
    property AfterLoadText: TNotifyEvent read FAfterLoadText write FAfterLoadText;
    property OnOpenDialog: TWPCustomRtfEditDialogEvent read FOnOpenDialog write FOnOpenDialog;
    {:: This event makes it possible to either paint the page hint in your own code - then set Ignore to TRUE
       or to modify the Canvas.Brush, -Pen and -Font properties and let the engine use its usual paint code. }
    property OnPaintPageHint: TWPPaintPageHintEvent read FOnPaintPageHint write FOnPaintPageHint;
    property OnToolBarSelectionEvent: TWPToolBarSelectionEvent read FOnToolBarSelection write FOnToolBarSelection;
    {:: This event is used for context menuse. It is triggered usually when the ContextMenu key was pressed,
    or the right mouse button. You can set the flag wpDontTriggerPopupInContextEvent in EditOptionsEx, then this
    event will be always triggered in the MouseDown event. }
    property OnMouseDownWord: TWPMouseDownRightEvent read FOnMouseDownWord write FOnMouseDownWord;
    { This event is triggered after the controls content was painted. Since v5.19.8 it is
    possible to paint flickerfree since while this event is triggered the property 'Canvas' will
    provide the reference to the current double buffer canvas. }
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnRequestStyle: TWPOnRequestStyleEvent read GetOnRequestStyle write SetOnRequestStyle;
    {:: This event is triggered by the HTML reader when a linked style sheet is requested. }
    property OnRequestHTTPString: TWPRequestHTTPStringEvent read GetOnRequestHTTPString write SetOnRequestHTTPString;
    {:: This event is triggered when a linked image (an image without image blob) is loaded. }
    property OnRequestHTTPImage: TWPRequestHTTPImageEvent read FOnRequestHTTPImage write FOnRequestHTTPImage;
    {:: This event is triggered before an image is saved. You can use this event to
    compress the image or save it to file and store the link.
      <br>
      <code>
      procedure TForm1.WPRichText1PrepareImageforSaving(
  RTFData: TWPRTFDataCollection; Writer: TWPCustomTextWriter;
  TextObject: TWPTextObj; var DontSave: Boolean);
begin
 // use WPIOHTML, WPOBJ_IMAGE
 if (Writer is TWPHTMLWriter) and TextObject.IsImage and
    (TextObject.Source='') and (TextObject.ObjRef.FileName='') and
    (TextObject.ObjRef.StreamName='') then
 begin
   TextObject.ObjRef.FileName :=
     TextObject.ObjRef.SaveToFile(Writer.SavePath,Writer.SaveName,'_img%d');
 end;
end;
      </code>
      note: To clean up you can use the event <b>AfterImageSaving</b>.
     }
    property OnPrepareImageforSaving: TWPPrepareImageforSavingEvent read FOnPrepareImageforSaving write FOnPrepareImageforSaving;
    {:: This event is triggered after an image was saved. }
    property AfterImageSaving: TWPAfterImageSaving read FAfterImageSaving write FAfterImageSaving;

    property OnStartSpellCheck: TWPStartSpellcheckEvent read FOnStartSpellCheck write FOnStartSpellCheck;
    property AfterCompleteWordEvent: TWPAfterCompleteWordEvent read FAfterCompleteWordEvent write FAfterCompleteWordEvent;
    property OnGetAttributeColor: TWPGetAttrColorEvent read GetOnGetAttrColor write SetOnGetAttrColor;

    property OnTextObjectPaint: TWPTextObjectPaintEvent read GetOnTextObjectPaint write SetOnTextObjectPaint;
    {:: This event is triggered for alls TWPTextObj ecxept for images and horizontal lines }
    property OnTextObjGetTextEx: TWPOnTextObjGetTextEvent read GetOnTextObjGetTextEx write SetOnTextObjGetTextEx;
    {:: This function can be used to calculate the the string which should be displayed
    under thumbnails or between the pages. It is activated by the Viewption wpShowPageNRinGap.
    Please note that the 'Sender' of this event is the RTF.Engine class (TWPRTFEnginePaint) not the editor box }
    property OnGetPageGapText: TWPOnGetPageGapText read GetOnGetPageGapText write SetOnGetPageGapText;
    property BeforeDestroyPaintPage: TWPBeforeDestroyPaintPage read
      GetBeforeDestroyPaintPage write SetBeforeDestroyPaintPage;
    property OnPaintWatermark: TWPOnPaintWatermarkEvent read
      GetOnPaintWatermark write SetOnPaintWatermark;
    property OnPaintExternPage: TWPOnPaintExternPageEvent read
      GetOnPaintExternPage write SetOnPaintExternPage;
    property OnGetSpecialText: TWPOnGetSpecialTextEvent read GetOnGetSpecialText write
      SetOnGetSpecialText;
    {:: This event can be used to overwrite the page numbers which are internally calculated.
    You can check for the name of the TextObject. It can have the following values:
    PAGE, NUMPAGES, NEXTPAGE, PRIORPAGE and SECTIONPAGES. The passed RTFPageNr is 0 based.
    The passed PaintPageNr can be -1 if the event is not executed from painting code,
    othewise it is the 0 based number of the current page page (see ExternalPages demo).<br>
    Note, if the var PrintedPageNr is set to  0 nothing will be printed! }
    property OnCalcPageNr: TWPOnCalcPageNr read GetOnCalcPageNr write SetOnCalcPageNr;

    property OnMeasureTextPage: TWPMeasurePageEvent read GetOnMeasureTextPage write SetOnMeasureTextPage;
    property OnMouseDown;
    property OnMouseUp;
  public
    property MouseX: Integer read FMouseX;
    property MouseY: Integer read FMouseY;
    property MousePage: Integer read FMousePage;
    property MouseMarginArea: TWPMouseMarginArea read FMouseMarginArea;
    property Canvas read GetMemoCanvas;
    property HyperLinkCursor: TCursor read FHyperLinkCursor write FHyperLinkCursor;
    property TextObjectCursor: TCursor read FTextObjectCursor write FTextObjectCursor;
  end;

  { This class inherits from the TWPCustomRtfEdit class which is also
  used to build an editor for text.<br>
  The difference to the latter class the TWPPreview has been specially
  preconfigurated to view text which is displayed also in an TWPCustomRtfEdit
  control. It cannot be used without any TWPCustomRtfEdit control attached to it.<br>
  <br>
  The preview is not automatically updated when text is added to the editor.
  You need to add some code to the OnDelayedUpdate event:
  <code>
  procedure TForm1.WPRichText1DelayedUpdate(Sender: TObject;
  var WPUPD_Code: Integer; Param: Integer);
  begin
     if WPUPD_Code=WPUPD_AFTER_REORDERPAGES then
             WPPreview1.Refresh;
  end;
  </code>
   }
  TWPPreview = class(TWPCustomRtfEdit)
  private
    FLoaded, FInPaintProc: Boolean;
    procedure SetWPRichText(x: TWPCustomRtfEdit);
  protected
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure DoBroadcastMsg(Sender: TWPRTFEnginePaint; var Code: Integer; Param: TObject); override;
  public
    constructor Create(aOwner: TComponent); override;
    procedure BeforeDestruction; override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure Loaded; override;
    {:: This procedure makes sure the display of the preview shows
    pages which have been added to the attached TWPRichText component.
    It does not format the text, it just initializes the pages }
    procedure Refresh(SpellCheck: Boolean = FALSE); override;
  published
    //property OnClose: TNotifyEvent read FOnClose write FOnClose;
    property OnResize;
    property WPRichText: TWPCustomRtfEdit read FAttachedEditBox write SetWPRichText;
    property SinglePageMode;
    property PageNumber;
    property Zooming default 100;
    property DrawGrid default FALSE;
    property ShowPagenumber default FALSE;
    property Columns default 1;
    property Rows default 1;
    property XOffset;
    property YOffset;
    property XBetween;
    property YBetween;
    property AutoZoom;
    property PageColumns;
    property LayoutMode;
    property PaperColor;
    property ColorDesktop;
    property ScrollBars;
    property ViewOptions;
    property BorderStyle;
    property Transparent;
    property OnClickHotText;
    property ClickableCodes;
    property OneClickHyperlink;
    property HyperLinkEvent;
    property OnClick;
    property OnDblClick;
    property OnUpdateExternScrollbar;
    property OnChangeViewMode;
    property OnTextObjectMouseMove;
    property OnTextObjectMouseDown;
    property OnTextObjectMouseUp;
    property OnTextObjectClick;
    property OnGetAttributeColor; // was: OnGetAttrColor
    property OnTextObjectPaint;
    property OnPaintWatermark;
    property OnPaintExternPage;
    property OnActivatingHotStyle;
    property OnActivateHint;
    property OnClickText;
    property OnCalcPageNr;
    property OnDeactivateHotStyle;
    property OnCustomLinePaintBefore;
    property OnCustomLinePaintAfter;
{$IFNDEF T2H} // ------------ Standard Properties ----------------------------
    property Align;
    property Ctl3D;
    property DragCursor;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseUp;
    property OnPaint;
    property Anchors;
    property Constraints;
{$ENDIF}
    {:: As ususal this event is triggered when the mouse is moved over the editor.
     You can use <see method="GetLineFromXY"> to optain the text position. }
    property OnMouseMove;
  end;

  {:: This event is triggered by the TWPToolsEnviroment }
  TWPToolsEnviromentEvent = procedure(Sender: TObject;
    WPRichText: TWPCustomRtfEdit; var Abort: Boolean) of object;

  TWPToolsEnviromentDialogEvent = procedure(Sender: TObject;
    WPRichText: TWPCustomRtfEdit; DialogCtrl: TComponent; Form: TForm; var Abort: Boolean) of object;

  TWPToolsShowDialogEnviromentEvent = procedure(Sender: TObject;
    WPRichText: TWPCustomRtfEdit; DialogCtrl: TComponent; Form: TForm) of object;

  TWPToolsSimpleEnviromentEvent = procedure(Sender: TObject;
    WPRichText: TWPCustomRtfEdit) of object;

  {:: This event is triggered by the TWPToolsEnviroment }
  TWPToolsOpenDialogEnviromentEvent = procedure(Sender: TObject;
    WPRichText: TWPCustomRtfEdit;
    DialogType: TWPCustomRtfEditDialog;
    var ResultValue: Boolean) of object;

{:: This class is responsible to create the reference canvas for reformat
which is used by the RTF Engine. The RTF Engine needs the references to be defined
otherwise reformat is not possible.
<br>
To use the events You need to create the enviroment in Form.OnCreate.
Then you can assign event handler, such as BeforeShowDialog:
     <code>
      Enviroment := TWPToolsEnviroment.Create(Self);
  Enviroment.Assign(GlobalWPToolsCustomEnviroment);
  GlobalWPToolsCustomEnviroment.Free;
  GlobalWPToolsCustomEnviroment := Enviroment;
  Enviroment.BeforeShowDialog := EnviromentBeforeShowDialog; </code>
  In Form.OnDestroy the enviroment must be deleted:
  <code>
  Enviroment.Free;
  GlobalWPToolsCustomEnviroment := nil;
  </code>
  This is the example BeforeShowDialog event which modifies the bullet dialog.
  <code>
procedure TForm1.EnviromentBeforeShowDialog(Sender: TObject;
    WPRichText: TWPCustomRtfEdit; DialogCtrl: TComponent;
    Form: TForm);
begin
  if Form is TWPBulletDialog then
     TWPBulletDialog(Form).TabSheet3.TabVisible := FALSE;
end;
  </code>
 }
  TWPToolsEnviroment = class(TWPToolsBasicEnviroment)
  private
{$IFNDEF T2H}
    FFindDialog: TFindDialog;
    FReplaceDialog: TReplaceDialog;
    FScreenReferenceDC: Cardinal;
    FAfterCreate: TWPToolsSimpleEnviromentEvent;
    FOnLoaded: TWPToolsSimpleEnviromentEvent;
    FOnClear: TWPToolsSimpleEnviromentEvent;
    FOnSetFocus: TWPToolsSimpleEnviromentEvent;
    FBeforeExecuteDialog: TWPToolsEnviromentDialogEvent;
    FOnOpenDialog: TWPToolsOpenDialogEnviromentEvent;
    FRTFEditors: TList; // TWPCustomRtfEdit
    FSpellEngine_OnStartSpellcheck: TWPStartSpellcheckEvent;
    FSpellEngine: TObject;
    FScreenResolution: Integer;
    WPPrinterCanvas: TCanvas;
    WPPrinterName: string;
    PrinterCanvasPX, PrinterCanvasPY: Integer;
    ScreenCanvasPX, ScreenCanvasPY: Integer;
    WPPrinterHDC: HDC;
    FBeforeShowDialog: TWPToolsShowDialogEnviromentEvent;
    FNoPrinterInstalled: Boolean;
    FWPPrinterCanvasHasHandle: Boolean;
    function GetEditorArray(index: Integer): TWPCustomRtfEdit;
    function GetEditorCount: Integer;
{$ENDIF}
  protected
{$IFNDEF T2H}
    function GetScreenReference: TObject; override;
    function GetPrinterReference: TObject; override;
    function GetScreenXPixelsPerInch: Integer; override;
    function GetScreenYPixelsPerInch: Integer; override;
    function GetPrinterXPixelsPerInch: Integer; override;
    function GetPrinterYPixelsPerInch: Integer; override;
    procedure WPPrinterOpenName(pname: string = '');
    procedure WPPrinterClose;
{$ENDIF}
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function FindDialog: TFindDialog;
    function ReplaceDialog: TReplaceDialog;
    function MayOpenDialog(WPRichText: TWPCustomRtfEdit; Dialog: TComponent; Form: TForm): Boolean;
    procedure DoBeforeShow(WPRichText: TWPCustomRtfEdit; DialogCtrl: TComponent; Form: TForm);
    property EditCount: Integer read GetEditorCount;
    property Edit[index: Integer]: TWPCustomRtfEdit read GetEditorArray; default;
    //:: This event is assigned by the spellcheck engine - not included in WPTools!
    property SpellEngine_OnStartSpellcheck: TWPStartSpellcheckEvent
      read FSpellEngine_OnStartSpellcheck write FSpellEngine_OnStartSpellcheck;
    //:: When the spellcheck engine modifies SpellEngine_OnStartSpellcheck it sets a reference here
    property SpellEngine: TObject read FSpellEngine write FSpellEngine;
    {::  }
    property ScreenResolution: Integer read FScreenResolution write FScreenResolution;
  published
    property OnClear: TWPToolsSimpleEnviromentEvent read FOnClear write FOnClear;
    property OnLoaded: TWPToolsSimpleEnviromentEvent read FOnLoaded write FOnLoaded;
    property OnSetFocus: TWPToolsSimpleEnviromentEvent read FOnSetFocus write FOnSetFocus;
    property AfterCreate: TWPToolsSimpleEnviromentEvent read FAfterCreate write FAfterCreate;
    property OnPropertiesLoaded: TWPToolsSimpleEnviromentEvent read FOnLoaded write FOnLoaded;
    //:: This event can be used to link in your own dialogs
    property BeforeExecuteDialog: TWPToolsEnviromentDialogEvent read FBeforeExecuteDialog write FBeforeExecuteDialog;
    property OnOpenDialog: TWPToolsOpenDialogEnviromentEvent read FOnOpenDialog write FOnOpenDialog;
    {:: This event can be used to modify the dialog before it becomes visible.
    }


    property BeforeShowDialog: TWPToolsShowDialogEnviromentEvent read FBeforeShowDialog write FBeforeShowDialog;
  end;


    {:: This collection item is used to create a link from any collection
    to a editor  }

  TWPEditBoxLink = class(TCollectionItem)
  private
{$IFNDEF T2H}
    FEditBox: TWPCustomRtfEdit;
    FName: string;
    FTag: Integer;
    function GetEditBox: TWPCustomRtfEdit;
    procedure SetEditBox(x: TWPCustomRtfEdit);
{$ENDIF}
  public
    constructor Create(Collection: TCollection); override;
{$IFNDEF CLR}destructor Destroy; override; {$ENDIF}
    procedure Assign(Source: TPersistent); override;
  published
    {:: Use this property to create a link to a TWPRichText }
    property EditBox: TWPCustomRtfEdit read GetEditBox write SetEditBox;
    {:: This property can be used to save any information, it is not used otherwise }
    property Name: string read FName write FName;
    {:: This property can be used to save any information, it is not used otherwise }
    property Tag: Integer read FTag write FTag;
  end;


  TWPEditBoxLinkUpdateState = procedure(
    Sender: TPersistent;
    EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg) of object;

  TWPEditBoxLinkCollection = class(TCollection)
  private
    FOwner: TPersistent;
    FOnUpdateState: TWPEditBoxLinkUpdateState;
    function GetItem(index: Integer): TWPEditBoxLink;
    procedure SetItem(index: Integer; x: TWPEditBoxLink);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
    procedure DoUpdateState(EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg);
  public
    constructor Create(Owner: TPersistent);
    function Add: TWPEditBoxLink;
    procedure Remove(EditBox: TWPCustomRtfEdit);
    function FirstEditBox: TWPCustomRtfEdit;
    procedure ReformatAll(
      InitializeAll: Boolean = FALSE;
      RepaintMemo: Boolean = FALSE);
    property Items[index: Integer]: TWPEditBoxLink read GetItem write SetItem; default;
    property OnOnUpdateState: TWPEditBoxLinkUpdateState read FOnUpdateState write FOnUpdateState;
  end;

{:: This function renders formatted text into a given rectangle. }
// function WPRenderText(toCanvas : TCanvas; R : TRect;
//   const Text : String; XRes : Integer=0; YRes : Integer=0; StartPos : Integer = 0):Integer;

function WPRenderText(toCanvas: TCanvas; R: TRect;
  const Text: string; WidthTW, HeightTW: Integer; StartPos: Integer = 0): Integer;

function WPRenderMeta(Width, Height: Integer;
  const Text: string; StartPos: Integer = 0): TMetafile;

  //:: frequently used by WPTools 4 to create a new object instance for a certain file
function WPLoadObjectFromFile(aOwner: TWPCustomRtfEdit; filename: string; AsLink: Boolean): TWPObject;
  //:: frequently used by WPTools 4 to create a new object instance for a extension. You can also use a classname directly!
function WPCreateObjectForExtension(aOwner: TWPCustomRtfEdit; ext: string): TWPObject;

var WPImageSizeMoveCursors: array[TWPPaintSizerRects] of TCursor =
  (
    crSizeAll,
    crSizeNWSE,
    crSizeNS,
    crSizeNESW,
    crSizeWE,
    crSizeNWSE,
    crSizeNS,
    crSizeNESW,
    crSizeWE
    );

{.$DEFINE DONTSETSIZERCURSOR}

var WPLastActiveRTFEdit: TWPCustomRtfEdit;
  WPMINCursorWidth: Integer = 1; // the minimum cursor width
  WPNoPrinterInstalled: Boolean; // Set to true to disable printing, also see DISABLEPRINTER
  WPPageHintStr: string = ' %d / %d ';

implementation

function WPRenderText(toCanvas: TCanvas; R: TRect;
  const Text: string; WidthTW, HeightTW: Integer; StartPos: Integer = 0): Integer;
var wp: TWPCustomRtfEdit;
  meta: TMetafile;
  metacan: TMetafileCanvas;
begin
  Result := -1;
  wp := TWPCustomRtfEdit.CreateDynamic;
  try
    wp.AsString := Text;
    wp.Memo.RTFData.PrintParameter.PrintHeaderFooter := wprNever;
    { wp.Header.SetPageWH(
         WidthTW,
         HeightTW, 0,0,0,0);  }
    wp.ReformatAll(true);
    meta := TMetafile.Create;
    meta.MMWidth := Round(wp.Header.PageWidth / 1440 * 2540);
    meta.MMHeight := Round(wp.Header.PageHeight / 1440 * 2540);
    metacan := TMetafileCanvas.Create(meta, 0);
    try
      wp.Memo.PaintRTFPage(0,
        0, 0, 0, 0,
        metacan,
        [wppShowMargins],
        WPScreenPixelsPerInch, WPScreenPixelsPerInch,
        -1, -1,
        [wpRTF2DestResConversion],
        nil
        );
    finally
      metacan.Free;
      toCanvas.StretchDraw(R, meta);
       // meta.SaveToFile('c:\a.emf');
      meta.Free;
    end;
  finally
    wp.free;
  end;
end;

(* function WPRenderText(toCanvas : TCanvas; R : TRect;
   const Text : String; XRes : Integer=0; YRes : Integer=0; StartPos : Integer=0):Integer;
var wp : TWPCustomRtfEdit;
    meta : TMetafile;
    metacan : TMetafileCanvas;
    currX, currY : Integer;
begin
   wp := TWPCustomRtfEdit.CreateDynamic;
   try
     wp.AsString := Text;
     if XRes = 0 then XRes := GetDeviceCaps(toCanvas.Handle, LOGPIXELSX);
     if YRes = 0 then YRes := GetDeviceCaps(toCanvas.Handle, LOGPIXELSY);
     wp.Memo.RTFData.PrintParameter.PrintHeaderFooter := wprNever;
     wp.Header.SetPageWH(
         MulDiv(R.Right-R.Left,1440,XRes),
         MulDiv(r.Bottom-R.Top,1440,YRes), 0,0,0,0);
     wp.ReformatAll(true);

     meta := TMetafile.Create;
     meta.Width  := R.Right-R.Left;
     meta.Height := R.Bottom-R.Top;
     metacan := TMetafileCanvas.Create(meta,0);
     try
   {  currX := GetDeviceCaps(metacan.Handle, LOGPIXELSX);
     currY := GetDeviceCaps(metacan.Handle, LOGPIXELSY);
     SetMapMode(metacan.Handle, MM_ANISOTROPIC);
     SetWindowExtEx(metacan.Handle, XRes, YRes, nil);
     SetViewPortExtEx(metacan.Handle, currX, currY, nil);
     SetViewPortOrgEx(metacan.Handle, 0, 0, nil);
     SetWindowOrgEx(metacan.Handle, 0, 0, nil); }
    { metacan.Rectangle(Rect(0,0, R.Right-R.Left-2,R.Bottom-R.Top-2 ));
     metacan.MoveTo(0,0);
     metacan.LineTo( (R.Right-R.Left) div 2,(R.Bottom-R.Top)div 2  );  }
     Result :=  wp.Draw(metacan,
        0,
        0,
        // R.Right-R.Left, - NO WIDTH!!!
        R.Bottom-R.Top,
        0,0, // WPScreenPixelsPerInch, WPScreenPixelsPerInch, // Xres, YRes,
        StartPos);
     finally
       metacan.Free;
       toCanvas.StretchDraw(R, meta);
       // meta.SaveToFile('c:\a.emf');
       meta.Free;
     end;
   finally
     wp.free;
   end;
end; *)

function WPRenderMeta(Width, Height: Integer;
  const Text: string; StartPos: Integer = 0): TMetafile;
var wp: TWPCustomRtfEdit;
  metacan: TMetafileCanvas;
begin
  wp := TWPCustomRtfEdit.CreateDynamic;
  try
    wp.AsString := Text;
    wp.Memo.RTFData.PrintParameter.PrintHeaderFooter := wprNever;
    wp.Header.SetPageWH(
      MulDiv(Width, 1440, WPScreenPixelsPerInch),
      MulDiv(Height, 1440, WPScreenPixelsPerInch), 0, 0, 0, 0);
    wp.ReformatAll(true);

    Result := TMetafile.Create;
    Result.Width := Width;
    Result.Height := Height;
    metacan := TMetafileCanvas.Create(Result, 0);
    try
      wp.Draw(metacan,
        0,
        0,
        Height,
        0, 0,
        StartPos);
    finally
      metacan.Free;
       // Result.SaveToFile('c:\a.emf');
    end;
  finally
    wp.free;
  end;
end;

function WPLoadObjectFromFile(aOwner: TWPCustomRtfEdit; filename: string; AsLink: Boolean): TWPObject; overload;
var
  objclass: TWPObjectClass;
  rtfdata: TWPRTFDataCollection;
begin
  Result := nil;
  rtfdata := aOwner.FMemo.RTFData;
  objclass := rtfdata.RTFProps.Enviroment.GetWPObjectForExtension(rtfdata, ExtractFileExt(filename));
  if objclass <> nil then
  begin
    Result := objclass.Create(rtfdata);
    try
      //Result.Color := clWindow;
       { Result.FileName := filename; }
      Result.HeightTW := 0;
      Result.WidthTW := 0;
      // Result.FWidthHeightModified := FALSE;
      {  if (Result.Control<>nil) and (aOwner is TWinControl) then
           Result.Control.Parent := TWinControl(aOwner);  }
      if AsLink then
      begin
        Result.StreamName := filename;
        if FileExists(filename) then
        begin
          Result.LoadFromFile(filename);
        end;
      end else if FileExists(filename) then
      begin
        Result.LoadFromFile(filename);
        if Result.WidthTW = 0 then Result.WidthTW := Result.ContentsWidth;
        if Result.HeightTW = 0 then Result.HeightTW := Result.ContentsHeight;
      end;
    except
      Result.Free;
      raise;
    end;
  end;
end;

function WPCreateObjectForExtension(aOwner: TWPCustomRtfEdit; ext: string): TWPObject;
var
  objclass: TWPObjectClass;
  rtfdata: TWPRTFDataCollection;
begin
  rtfdata := aOwner.FMemo.RTFData;
  objclass := rtfdata.RTFProps.Enviroment.GetWPObjectForExtension(rtfdata, ext);
  if objclass <> nil then Result := objclass.Create(rtfdata) else Result := nil;
end;

//##############################################################################
// TWPPaintEnginePaintSize
//##############################################################################

function TWPPaintEnginePaintSize.GetDisplayName: string;
begin
  Result := Format('%d x %d', [FWidth, FHeight]);
end;

constructor TWPPaintEnginePaintSize.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FReferenceResolution := 1440;
  FWidth := WPCentimeterToTwips(10);
  FHeight := WPCentimeterToTwips(4);
end;

function TWPPaintEnginePaintSize.GetReferenceResolution: Integer;
begin
  if FReferenceResolution <= 0 then
    Result := 1440
  else Result := FReferenceResolution;
end;

destructor TWPPaintEnginePaintSize.Destroy;
begin
  FTitle := '';
  inherited Destroy;
end;

procedure TWPPaintEnginePaintSize.Assign(Source: TPersistent);
begin
  if Source is TWPPaintEnginePaintSize then
  begin
    FWidth := TWPPaintEnginePaintSize(Source).FWidth;
    FHeight := TWPPaintEnginePaintSize(Source).FHeight;
  end
  else inherited Assign(Source);
end;


//##############################################################################
// TWPPaintEnginePaintSizes
//##############################################################################

function TWPPaintEnginePaintSizes.GetItem(index: Integer): TWPPaintEnginePaintSize;
begin
  Result := TWPPaintEnginePaintSize(inherited Items[index]);
end;

procedure TWPPaintEnginePaintSizes.SetItem(index: Integer; x: TWPPaintEnginePaintSize);
begin
  TWPPaintEnginePaintSize(inherited Items[index]).Assign(x);
end;

function TWPPaintEnginePaintSizes.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

constructor TWPPaintEnginePaintSizes.Create;
begin
  inherited Create(TWPPaintEnginePaintSize);
end;


function TWPPaintEnginePaintSizes.Add(const Width, Height: Integer): TWPPaintEnginePaintSize;
begin
  Result := TWPPaintEnginePaintSize(inherited Add);
  Result.Width := Width;
  Result.Height := Height;
end;



//##############################################################################
// TWPPaintEngine
//##############################################################################

constructor TWPPaintEngine.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FPageSizes := TWPPaintEnginePaintSizes.Create;
  FPageSizes.FOwner := Self;
  FMemo := TWPRTFEnginePaint.Create(nil);
  FOwnRTFData := nil;
end;

destructor TWPPaintEngine.Destroy;
begin
  FreeAndNil(FPageSizes);
  if FRTFData <> nil then
    RemoveRTFData;
  FreeAndNil(FOwnRTFData);
  FreeAndNil(FMemo);
  inherited Destroy;
end;

procedure TWPPaintEngine.SetPageSizes(x: TWPPaintEnginePaintSizes);
begin
  FPageSizes.Assign(x);
end;

function TWPPaintEngine.GetPageSizes: TWPPaintEnginePaintSizes;
begin
  Result := FPageSizes;
end;

procedure TWPPaintEngine.MakeRTFData;
begin
  if FRTFData <> nil then
    RemoveRTFData;
  FOwnRTFData.Free;
  FOwnRTFData := TWPRTFDataCollection.Create(TWPRTFDataBlock);
  FOwnRTFData.FormatOptions := [wpDisableAutosizeTables, wpfAlwaysFormatWithScreenRes];
{$IFDEF DONTADDEXTERNALLEADING}
  FOwnRTFData.FormatOptionsEx := [wpDontAddExternalFontLeading];
{$ENDIF}
  FOwnRTFData.MakeRTFProps;
  SetARTFData(FOwnRTFData);
end;

function TWPPaintEngine.GetARTFData: TWPRTFDataCollection;
begin
  Result := FRTFData;
end;

procedure TWPPaintEngine.SetARTFData(x: TWPRTFDataCollection);
begin
  if x <> RTFData then
  begin
    RemoveRTFData;
    if x <> nil then SetRTFData(x);
  end;
end;

{ This is the event handler for the internal OnMeaurePage event which is
  executed with highest priority. It set the page size defined in the
  PageSizes collection. }

procedure TWPPaintEngine.DoMeasurePage(Sender: TObject; PageInfo: TWPMeasurePageParam);
var item: TWPPaintEnginePaintSize;
  res: Integer;
begin
  if FPageSizes.Count > 0 then
  begin
    if PageInfo.pagenr >= FPageSizes.Count then
      item := FPageSizes[FPageSizes.Count - 1]
    else item := FPageSizes[PageInfo.pagenr - 1];
    res := item.ReferenceResolution;
    PageInfo.widthtw := MulDiv(item.Width, 1440, res);
    PageInfo.heighttw := MulDiv(item.Height, 1440, res);
    PageInfo.marginleft := MulDiv(item.marginleft, 1440, res);
    PageInfo.margintop := MulDiv(item.margintop, 1440, res);
    PageInfo.marginright := MulDiv(item.marginright, 1440, res);
    PageInfo.marginbottom := MulDiv(item.marginbottom, 1440, res);
    PageInfo.changed := TRUE;
  end;
end;

procedure TWPPaintEngine.RemoveRTFData;
begin
  if FUseDoMeasurePage then
  begin
    FRTFData._InternOnMeasurePage_PaintEngine := nil;
    FUseDoMeasurePage := FALSE;
  end;
  FMemo.RemoveRTFData;
  FRTFData := nil;
end;

procedure TWPPaintEngine.SetRTFData(ARTFData: TWPRTFDataCollection);
begin
  FRTFData := ARTFData;
  FMemo.SetRTFDataOrProps(FRTFData, nil);
  if not assigned(ARTFData._InternOnMeasurePage_PaintEngine) then
  begin
    FUseDoMeasurePage := TRUE;
    ARTFData._InternOnMeasurePage_PaintEngine :=
      DoMeasurePage;
  end else FUseDoMeasurePage := FALSE;
  FMemo.DisplayedText := FRTFData.Get(wpIsBody, wpraOnAllPages);
end;

function TWPPaintEngine.Reformat: Integer;
begin
  if FRTFData <> nil then
  begin
    FMemo.DisplayedText := FRTFData.Get(wpIsBody, wpraOnAllPages);
    FMemo.ReformatAll(false);
    FMemo.InitializePaintPages;
    Result := FMemo.PaintPageCount;
  end else Result := 0;
end;

procedure TWPPaintEngine.DeletePage(index: Integer);
begin
  FMemo.DeletePage(index);
end;

procedure TWPPaintEngine.InitCanvas(toCanvas: TCanvas; Start: Boolean);
begin
end;

function TWPPaintEngine.PaintPageOnCanvas(PaintPageNr: Integer;
  x, y, pw, ph: Integer; DestCanvas: TCanvas;
  PaintMode: TWPPaintModes = [];
  DestXRes: Integer = 0; DestYRes: Integer = 0;
  ClipY: Integer = -1;
  ClipH: Integer = -1;
  PaintPageMode: TWPRTFEnginePaintPagesModes = [wpUseProvidedWidthHeight]): Boolean;
begin
  if DestCanvas = nil then raise EWPToolsProgError.Create('Canvas may not be nil!');
  if (PaintPageNr < 0) or (PaintPageNr >= FMemo.PaintPageCount) then Result := FALSE
  else
  begin
    InitCanvas(DestCanvas, true);
    FMemo.PaintRTFPage(PaintPageNr, x, y, pw, ph,
      DestCanvas, PaintMode, DestXRes, DestYRes, ClipY, ClipH, PaintPageMode, nil);
    InitCanvas(DestCanvas, false);
    Result := TRUE;
  end;
end;

function TWPPaintEngine.GetMetafile(pagenr: Integer; WithHeaderFooter: Boolean = FALSE): TMetafile;
var metacan: TMetafileCanvas;
begin
  if (pagenr < 0) or (pagenr >= FMemo.PaintPageCount) then Result := nil
  else
  begin
    Result := TMetafile.Create;
   // Result.MMWidth  :=MulDiv(FMemo.PaintPageWidth[pagenr],2540,WPScreenPixelsPerInch);
   // Result.MMHeight :=MulDiv(FMemo.PaintPageHeight[pagenr],2540,WPScreenPixelsPerInch);
    Result.Width := FMemo.PaintPageWidth[pagenr];
    if WithHeaderFooter then
      Result.Height := FMemo.PaintPageHeight[pagenr]
    else Result.Height := FMemo.PaintPageTextHeight[pagenr];
    metacan := TMetafileCanvas.Create(Result, 0);
    try
      InitCanvas(metacan, true);
      if WithHeaderFooter then
        FMemo.PaintRTFPage(pagenr, 0, 0, 0, 0, metacan,
          [wppInPaintForwPDF, wppOutputToPrinter])
      else FMemo.PaintRTFPage(pagenr, 0, 0, 0, 0, metacan,
          [wppNoPageBackground, wppNoHeaderFooter,
          wppInPaintForwPDF, wppOutputToPrinter],
            0, 0, -1, -1, [wpUseTextHeight]);
      InitCanvas(metacan, false);
    finally
      metacan.Free;
    end;
  end;

end;

function TWPPaintEngine.Draw(outCanvas: TCanvas;
  x, y: Integer; // The offset
  h: Integer; // The height to be filled
  xres, yres: Integer; // For x,y,h
  starty: Integer; // from last run
  HandlePageBreaks: Boolean = FALSE): Integer;
begin
  Result := FMemo.Draw(outCanvas, x, y, h, xres, yres, starty, HandlePageBreaks);
end;

function TWPPaintEngine.PageCount: Integer;
begin
  Result := FMemo.PaintPageCount;
end;

procedure TWPPaintEngine.ReformatAll(InitializeAll: Boolean = FALSE);
begin
  FMemo.ReformatAll(InitializeAll, false);
end;

function TWPPaintEngine.Draw(outCanvas: TCanvas;
  r: TRect;
  zoom: Integer;
  starty: Integer; // from last run
  HandlePageBreaks: Boolean = FALSE): Integer;
var xres, yres: Integer;
  SizeA, SizeB: TSize;
begin
  if zoom = 0 then zoom := 100;
  xres := GetDeviceCaps(outCanvas.Handle, LOGPIXELSX);
  yres := GetDeviceCaps(outCanvas.Handle, LOGPIXELSY);
  InitCanvas(outCanvas, true);
  GetViewportExtEx(outCanvas.Handle, SizeA);
  GetWindowExtEx(outCanvas.Handle, SizeB);
  xres := Round((xres * zoom / 100) * (SizeA.cx / SizeB.cx)); // *(xres/FMemo.CurrentXPixelsPerInch));
  yres := Round((yres * zoom / 100) * (SizeA.cy / SizeB.cy)); //*(yres/FMemo.CurrentYPixelsPerInch));
  Result := FMemo.Draw(outCanvas, r.Left, r.Top,
    r.Bottom - r.Top, xres, yres, starty, HandlePageBreaks);
  InitCanvas(outCanvas, false);
end;

//##############################################################################
// TWPPaintEngineAndData
//##############################################################################

procedure TWPPaintEngineAndData.SetARTFData(x: TWPRTFDataCollection);
begin
  raise Exception.Create('TWPPaintEngineAndData uses local RTFData object');
end;

constructor TWPPaintEngineAndData.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FOwnedRTFData := TWPRTFDataCollection.Create(TWPRTFDataBlock);
  FOwnedRTFData.MakeRTFProps;
  SetRTFData(FOwnedRTFData);
  FAnyData := nil;
end;

destructor TWPPaintEngineAndData.Destroy;
begin
  RemoveRTFData;
  FOwnedRTFData.Free;
  if FAnyData <> nil then FAnyData.Free;
  inherited Destroy;
end;


//##############################################################################
// TWPCustomRtfEdit Create/Destroy
//##############################################################################

constructor TWPCustomRtfEdit.CreateDynamic;
begin
  Create(nil);
  _MakeDynamic;
end;

procedure TWPCustomRtfEdit._MakeDynamic;
begin
  FIDEValueLoaded := TRUE; //V5.17.5
  FIsDynamic := TRUE;
end;

constructor TWPCustomRtfEdit.Create(AOwner: TComponent);
var os: OSVERSIONINFO;
begin
  inherited Create(AOwner);
  FIDEFormatOptions := [wpDisableAutosizeTables];
{$IFDEF DONTADDEXTERNALLEADING}
  FIDEFormatOptionsEx := [wpDontAddExternalFontLeading];
{$ENDIF}
  FillChar(os, SizeOf(os), 0);
  os.dwOSVersionInfoSize := SizeOf(os);
  GetVersionEx(os);
  if os.dwMajorVersion <= 4 then // Win98 only!
    FWin9X := TRUE
  else FWin9X := FALSE;
{$IFNDEF WriteObjectModeSTD}
  FIDEWriteObjectMode := wobRTF; // DEFAULT TO RTF!!!
{$ENDIF}
  FEditBoxLinkCollections := TList.Create;
  FScrollBars := ssBoth;
  FWantTabs := TRUE;
  FWantReturns := TRUE;
  ControlStyle := ControlStyle - [csAcceptsControls, csSetCaption] +
    [csClickEvents, csDoubleClicks, csFramed, csCaptureMouse];
  FPaperDefs := TWPPaperDefinitionCollection.Create;
  FPaperDefs.FOwner := Self;
  FFrameVar := TWPDrawFrameVar.Create;
  FDefaultNumberIndent := 360;
  FMemo := TWPRTFEnginePaint.Create(nil);
  //NO, this is only for PREVIEW! FMemo._RTFDataMemo := Self;
  FMemo._EditBox := Self;
  //nope: FMemo.Parent := Self;
  FMemo.DualPageViewAlternate := TRUE;
  FMemo._OnInitializeRTFDataObject := DoInitializeRTFDataObject;
  FMemo._OnInitializedRTFData := DoInitializedRTFData;
  FMemo._AfterInitializeRTFDataObject := DoAfterInitializeRTFDataObject;
  FMemo.OnChangeZooming := DoChangeZooming;
  FCaret := TWPCaret.Create(Self, FMemo);
  FCaret.FRTFEdit := Self;
  FMemo._OnStartPaint := DoPaintStart;
  FMemo._AfterPrepareDoubleBuffer := AfterPrepareDoubleBuffer;
  FMemo._OnEndPaint := DoPaintEnd;
  FMemo._OnBroadcastMsg := DoBroadcastMsg;
  FMemo._EditBox := Self;
  FMemo.OnChangeScrollPosition := DoChangeScrollPosition;
  FHyperLinkCursor := crArrow;
  FTextObjectCursor := crHandPoint;
  FRTFText := TWPRTFBlobContents.Create(FMemo);
  FIDETextHeader := TTextHeader.Create(nil);
  // FIDENumberStyles := TWPRTFNumberStyleCollection.Create(nil,TWPRTFNumberingStyle);
  FIDERTFVariables := TWPRTFExtraDataCollection.Create;
  FIDERTFVariables.aOwner := Self;
  FIDEPrintParameter := TWPPrintParameter.Create;
  FClickableCodes := [wpobjHyperlink];

  if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
    FVKLeftMouseButton := VK_RBUTTON
  else
    FVKLeftMouseButton := VK_LBUTTON;
  FScrollVMulti := 1;
  FScrollHMulti := 1;
  FormatWPT := RegisterClipboardFormat('WPTOOLS Format');
  FormatHTM := RegisterClipboardFormat('HTML Format');
  FormatRTF := RegisterClipboardFormat('Rich Text Format');
  XOffset := 144;
  XBetween := 144;
  YOffset := 144;
  YBetween := 144;
  SetZoomMode(0);
  FAvailableDialogs := [wpStartPrint];
end;

procedure TWPCustomRtfEdit.SetRTFDataOrProps(NewRTFData: TWPRTFDataCollection; NewRTFProps: TWPRTFProps);
begin
  FMemo.SetRTFDataOrProps(NewRTFData, NewRTFProps);
end;

destructor TWPCustomRtfEdit.Destroy;
var i: Integer;
begin
  FNowDestroy := TRUE;
{$IFDEF USETIMER}
  if FTimerHandle <> 0 then
  begin
    KillTimer(FTimerWinHandle, FTimerHandle); { If the application calls SetTimer with hWnd set to NULL, this parameter must be the timer identifier returned by SetTimer. }
    FTimerHandle := 0;
  end;
{$ELSE}
  while FLockDestroy > 0 do
    Application.ProcessMessages;
{$ENDIF}

  _RefreshMsglist;
  if FPreview <> nil then
  try
    FPreview.WPRichText := nil;
    FPreview := nil;
  except
  end;
  if WPLastActiveRTFEdit = Self then
    WPLastActiveRTFEdit := nil;
  for i := 0 to FEditBoxLinkCollections.Count - 1 do
    TWPEditBoxLinkCollection(FEditBoxLinkCollections[i]).Remove(Self);
  FEditBoxLinkCollections.Free;
  FFrameVar.Free;
  FCaret.Free;
  FMemo.Free;
  FPaperDefs.Free;
  FAttrStack := nil;
  FRTFText.Free;
  FIDETextHeader.Free;
  // FIDENumberStyles.Free;
  FIDERTFVariables.Free;
  FIDEPrintParameter.Free;
  inherited Destroy;
end;

procedure TWPCustomRtfEdit.CreateParams(var Params: TCreateParams);
const
  BorderStyles: array[TBorderStyle] of DWORD = (0, WS_BORDER);
begin
  inherited CreateParams(Params);
  if Transparent and (FBackgroundImageRef = nil) then
    Params.ExStyle := Params.ExStyle + WS_EX_Transparent;
  if TabStop then
    Params.Style := Params.Style or WS_TABSTOP or WS_CLIPCHILDREN
  else
    Params.Style := Params.Style and not WS_TABSTOP or WS_CLIPCHILDREN;
{$IFNDEF NOFILEMANSUPPORT}
  if AcceptFiles then
    Params.ExStyle := Params.ExStyle + WS_EX_ACCEPTFILES;
{$ENDIF}
  with Params do
    Style := Style or BorderStyles[FBorderStyle];
end;

procedure TWPCustomRtfEdit.CreateWnd;
begin
  inherited CreateWnd;
  if not FIDEValueLoaded then Loaded;
  Resize;
  FCaret.Handle := Handle;
  if FNeedInitRTFData then
  begin
    CheckHasBody;
    invalidate;
    FNeedInitRTFData := FALSE;
  end;
  StartUpdate(WPUPD_REFORMAT);
  StartUpdate(WPUPD_REPAINT);
end;

procedure TWPCustomRtfEdit.SetScrollBars(Value: TScrollStyle);
begin
  if FScrollBars <> Value then
  begin
    FScrollBars := Value;
    RecreateWnd;
  end;
end;

procedure TWPCustomRtfEdit.BeforeDestruction;
begin
  FNowDestroy := TRUE;
  inherited BeforeDestruction;
  FCaret.Active := FALSE;
  FCaret.Visible := FALSE;
  _RefreshMsglist;
  if FPreview <> nil then
  begin
    FPreview.WPRichText := nil;
    FPreview := nil;
  end;
end;

procedure TWPCustomRtfEdit.DestroyWnd;
begin
  FCaret.Active := FALSE;
  FCaret.Visible := FALSE;
  inherited DestroyWnd;
  _RefreshMsglist;
end;

procedure TWPCustomRtfEdit._RefreshMsglist;
var i: Integer;
begin
  for i := 0 to Length(FWM_WPTOOLSUPDATEFlags) - 1 do
    FWM_WPTOOLSUPDATEFlags[i] := FALSE;
end;

//##############################################################################
// Intern Events
//##############################################################################

{ Event: Hide	Cursor }

procedure TWPCustomRtfEdit.DoPaintStart(Sender: TObject; ThisDoubleBuffer: TBitmap);
begin
  if HandleAllocated and Focused then FCaret.Active := FALSE;
  FFrameVar.Visible := FALSE;
  FCurrentDoubleBuffer := ThisDoubleBuffer;
end;

{ Event: Show	Cursor }

procedure TWPCustomRtfEdit.DoPaintEnd(Sender: TObject);
begin
  if HandleAllocated and Focused then
  begin
    FCaret.UpdatePos;
    FCaret.Active := not CaretDisabled;
    if FFrameVar.Active then FFrameVar.Draw;
  end;
  FCurrentDoubleBuffer := nil;
end;

procedure TWPCustomRtfEdit.AfterPrepareDoubleBuffer(Sender: TObject);
{$IFNDEF NOPAGENHINT}var s: string; w, h: Integer; Ignore: Boolean; {$ENDIF}
begin
  FDidTriggerPaintEvent := TRUE;
{$IFNDEF NOPAGENHINT}
  if FInScrollTrackMode and not (wpDontDisplayScrollPageHint in ViewOptions) and
    (WPPageHintStr <> '') then
  begin
    if (FAttachedEditBox <> nil) and (Self is TWPPreview) then
      w := FAttachedEditBox.PageCount
    else w := PageCount;

    Canvas.Font.Color := clBlack;
    Canvas.Font.Charset := DEFAULT_CHARSET;
    Canvas.Font.Name := 'Tahoma';
    Canvas.Font.Style := [];
    Canvas.Font.Size := 9;
    Canvas.Pen.Color := clRed;
    Canvas.Pen.Width := 0;
    Canvas.Pen.Style := psSolid;
    Canvas.Brush.Color := clYellow;
    Canvas.Brush.Style := bsSolid;
    Ignore := w <= 1;
    if Memo.SinglePageMode then
      h := Memo._LastSetPageNumber + 1
    else h := PageNumber + 1;
    s := Format(WPPageHintStr, [h, w]);
    if assigned(FOnPaintPageHint) then
      FOnPaintPageHint(Self, Canvas, Point(ClientWidth, 0), h, w, s, Ignore);
    if not Ignore then
    begin
      w := Canvas.TextWidth(s) + 4;
      h := Canvas.TextHeight(s) + 4;
      Canvas.Rectangle(Width - 50 - w, 10, Width - 50, 10 + h);
      Canvas.TextOut(Width - 50 - w + 2, 12, s);
    end;
  end;
{$ENDIF}
  if Assigned(FOnPaint) then
  begin
    if FCurrentDoubleBuffer <> nil then
    begin
      FCurrentDoubleBuffer.Canvas.Brush.Color := clWhite;
      FCurrentDoubleBuffer.Canvas.Brush.Style := bsSolid;
      FCurrentDoubleBuffer.Canvas.Pen.Width := 0;
      FCurrentDoubleBuffer.Canvas.Pen.Color := clBlack;
      FCurrentDoubleBuffer.Canvas.Pen.Style := psSolid;
      FCurrentDoubleBuffer.Canvas.Font.Assign(Font);
    end;
    FOnPaint(Self);
  end;
end;

procedure TWPCustomRtfEdit.DelayedInvalidate;
begin
  if not FNowDestroy then
  begin
{$IFDEF USETIMER}
    if FTimerHandle <> 0 then
    begin
      KillTimer(FTimerWinHandle, FTimerHandle);
      FTimerHandle := 0;
    end;
    FTimerWinHandle := Handle;
    FTimerHandle := SetTimer(FTimerWinHandle, WPUPD_DELAYEDINVALIDATE, 800, nil); // --> WM_TIMER message
{$ELSE}
    FLockInvalidateTime := GetTickCount + 800;
    PostMessage(Handle, WM_WPTOOLSUPDATE, WPUPD_DELAYEDINVALIDATE, 0);
{$ENDIF}
  end;
end;

procedure TWPCustomRtfEdit.DoBroadcastMsg(Sender: TWPRTFEnginePaint; var Code: Integer; Param: TObject);
begin
  if csDestroying in ComponentState then exit;
  // --------------- Update attached TWPPreview ------------------------
  if (FPreview <> nil) and ((Code = WPBROADCAST_REPAINT)
    or (Code = WPBROADCAST_UPDATE_SELECTION))
    and not (csDestroying in FPreview.ComponentState) then
  begin
    if (FPreview.PageCount = 0) or
      (FPreview.Focused and not FPreview.CaretDisabled) then
      FPreview.Invalidate // if the preview is editable update at once
    else FPreview.DelayedInvalidate;
  end;
  // -------------------------------------------------------------------

  case Code of
    WPBROADCAST_UPDATE_HSCROLL: SetScrollBarSize(true);
    WPBROADCAST_UPDATE_VSCROLL: SetScrollBarSize(false);
    WPBROADCAST_UPDATE_CURSOR:
      begin
        if Focused then
        begin
          StartUpdate(WPUPD_SHOWCURSOR);
          StartUpdate(WPUPD_UPDATTRIBUTES);
        end;
      end;
    WPBROADCAST_UPDATE_CURSOR_AUTOSCROLL:
      begin
        if Focused then
        begin
          StartUpdate(WPUPD_SHOWCURSOR_NOSCROLL);
          StartUpdate(WPUPD_UPDATTRIBUTES);
        end;
      end;
    WPBROADCAST_UPDATE_DID_SCROLL:
      begin
        if Focused then
        begin
          StartUpdate(WPUPD_DID_SCROLL);
        end;
      end;
    WPBROADCAST_UPDATERULER:
      begin
        StartUpdate(WPUPD_UPDATERULER);
      end;
    WPBROADCAST_UPDATERULER_CP:
      begin
        StartUpdate(WPUPD_UPDATERULER_CP);
      end;
    WPBROADCAST_UPDATE_SELECTION:
      begin
        if Focused or not FAllowMultiView then
        begin
          if SelectedObject <> FFrameVar.fWorkObj then
          begin
            FFrameVar.Active := FALSE;
            FTextObjectUnderMouse := SelectedObject;
            FFrameVar.fWorkObj := SelectedObject;
            FTextObjectUnderMouse := FTextObjectUnderMouse;
          end;
          StartUpdate(WPUPD_UPDSELECTION);
        end;
      end;
    WPBROADCAST_REPAINT:
      begin
        StartUpdate(WPUPD_REPAINT);
        Code := 0;
      end;
    WPBROADCAST_NEED_REFORMAT:
      begin
        FMemo.RTFData.NeedReformat;
        StartUpdate(WPUPD_REFORMAT);
       // if ActiveText<>nil then ReformatAll(false, true);
        Code := 0;
      end;
    WPBROADCAST_NEED_SPEEDREFORMAT:
      begin
        StartUpdate(WPUPD_SPEEDREFORMAT);
        Code := 0;
      end;
    WPBROADCAST_NEED_SELECTBODY:
      begin
        StartUpdate(WPUPD_NEEDSELECTBODY);
      end;
    WPBROADCAST_UNDOCHANGE:
      begin
        StartUpdate(WPUPD_UNDOCHANGE);
      end;
    WPBROADCAST_NEED_REFORMATLATER:
      begin
        FMemo.RTFData.NeedReformat;
        StartUpdate(WPUPD_REFORMAT);
        Code := 0;
      end;
    WPBROADCAST_UNSELECTOBJECT:
      begin
        if FTextObjectUnderMouse = Param then FTextObjectUnderMouse := nil;
        if FFrameVar.WorkObj = Param then
        begin
          if FFrameVar.Active then FFrameVar.Active := FALSE;
          FFrameVar.WorkObj := nil;
        end;
      end;
    WPBROADCAST_NEEDFOCUS: StartUpdate(WPUPD_NEEDFOCUS);
    WPBROADCAST_WORKONTEXTCHANGE:
      begin
        if assigned(FOnWorkOnTextChanged) then FOnWorkOnTextChanged(Self);
        invalidate;
      end;
    WPBROADCAST_AFTER_REORDERPAGES: StartUpdate(WPUPD_AFTER_REORDERPAGES);
    WPBROADCAST_AFTER_LOAD:
      begin
        if wpAlwaysColWidthPC in EditOptionsEx then
        begin
          ReformatAll(false, false);
          TableMakeCellWidthPC;
        end;
        if assigned(FAfterLoadText) then FAfterLoadText(Self);
        StartUpdate(WPUPD_AFTER_LOAD);
      end;
    WPBROADCAST_NEWRTFBLOCK:
      if Assigned(FOnNewRTFDataBlock) then FOnNewRTFDataBlock(Self, Param as TWPRTFDataBlock);
    WPBROADCAST_AFTER_CLEARTEXT:
      if Assigned(FOnClear) then FOnClear(Self);
  end;
end;

//##############################################################################
// User Interaction
//##############################################################################

procedure TWPCustomRtfEdit.ShowCursor;
begin
  StartUpdate(WPUPD_SHOWCURSOR);
end;

function TWPCustomRtfEdit.GetHistoryChars(count: Integer): string;
var l, i: Integer;
begin
  l := 0;
  SetLength(Result, count);
  i := FHistoryPos;
  try
    while i > 0 do
    begin
      if (l = count) or (FHistory[i] = #0) then exit;
      Result[count - l] := FHistory[i];
      inc(l);
      dec(i);
    end;
    i := Length(FHistory);
    while i > FHistoryPos do
    begin
      if (l = count) or (FHistory[i] = #0) then exit;
      Result[count - l] := FHistory[i];
      inc(l);
      dec(i);
    end;
  finally
    if l < count then Delete(Result, 1, count - l);
  end;
end;

procedure TWPCustomRtfEdit.AddHistoryChar(aChar: Char);
begin
  if (aChar = #8) then // backspace!
  begin
    if FHistoryPos > 0 then FHistory[FHistoryPos] := #0;
    if FHistoryPos > 1 then dec(FHistoryPos)
    else FHistoryPos := WPHistoryMaxCount;
  end else
  begin
    if FHistoryPos >= WPHistoryMaxCount then FHistoryPos := 0;
    inc(FHistoryPos);
    FHistory[FHistoryPos] := aChar;
  end;
end;

procedure TWPCustomRtfEdit.DoAfterCompleteWordEvent(var key: Char);
var ignore: Boolean;
begin
  try
    FInAfterCompleteWordEvent := TRUE;
    FCPWordModified := FALSE;
    ignore := FALSE;
    if Assigned(_3RDParty_AfterCompleteWord) then
      _3RDParty_AfterCompleteWord(Self, key, ignore);
    if not ignore and assigned(FAfterCompleteWordEvent) then
      FAfterCompleteWordEvent(Self, key);
  finally
    FInAfterCompleteWordEvent := FALSE;
  end;
end;

// used by KeyPress to complete and exit a hyperlink

procedure TWPCustomRtfEdit.CloseAutoLink;
var hyp: TWPTextObj;
begin
  if (TextCursor.ObjAtCP <> nil) and
    (TextCursor.ObjAtCP.ObjType = wpobjHyperlink) then
  begin
             // This is the current Hyperlink
    hyp := HyperlinkAtCP;
    if (hyp <> nil) and (wpobjReadSourceFromEmbeddedText in hyp.Mode) then
    begin
                // This locks in the URL = the current link
                {hyp.Source := hyp.Source;
                hyp.Mode := hyp.Mode - [wpobjReadSourceFromEmbeddedText];  }
                // if empty then delete that link
      if Trim(hyp.EmbeddedText) = '' then
        DeleteHyperlink(false)
      else CPMoveNext; // Jump over the end ...
    end;
  end;
  FJustCreatedAutomaticHyperlink := FALSE;
end;

procedure TWPCustomRtfEdit.KeyPress(var Key: Char);
var msg: TMsg;
  s: string;
  aobj, bobj: TWPTextObj;
{$IFDEF USE_INPUTBUFFER}WasProcessed: Boolean; {$ENDIF}
  procedure MakeLinkLastChars(count: Integer);
  begin
    if HyperlinkAtCP = nil then
    begin
      TextCursor.Inserting := TRUE;
      TextCursor.MoveBack(count);
      aobj := TextObjects.InsertNewObject(wpobjHyperlink, true, false);
      aobj.Mode := aobj.Mode + [wpobjReadSourceFromEmbeddedText];
      TextCursor.MoveNext(count);
      bobj := TextObjects.InsertNewObject(wpobjHyperlink, true, true);
      bobj.SetTag(aobj.NewTag);
          // bobj.Mode := bobj.Mode + [wpobjReadSourceFromEmbeddedText];
      TextCursor.MoveBack(1);
      FJustCreatedAutomaticHyperlink := TRUE;
    end;
  end;
    // -------------------------------------------------------------------------
{$IFDEF USE_INPUTBUFFER_WAIT10}var tim: Cardinal; {$ENDIF}
begin
  inherited KeyPress(Key);

{$IFDEF USE_INPUTBUFFER}
  WasProcessed := FALSE;
  try
{$ENDIF}
    if not FMemo.HasData or (Readonly and (Key <> #3)) then exit;
    if Key < #32 then
    begin
      case Key of
        #3:
          if (GetKeyState(VK_SHIFT) >= 0) then
          begin
            CopyToClipboard; key := #0;
            ShowCursor;
          end;
        #22:
          if (GetKeyState(VK_SHIFT) >= 0) and CheckHasBody then
          begin
            if Changing then
            begin
              PasteFromClipboard;
              ChangeApplied;
              key := #0;
              ChangeApplied;
              ShowCursor;
            end;
          end;
        #24:
{$IFNDEF WINCOM}if (GetKeyState(VK_SHIFT) >= 0) then {$ENDIF}
          begin
            if Changing then
            begin
              CutToClipboard;
              FMemo.RePaint;
              ChangeApplied;
            end else CopyToClipboard;
            key := #0;
            ShowCursor;
          end;
        #27:
          begin
            if FJustCreatedAutomaticHyperlink then CloseAutoLink;
            HideSelection;
            FMemo._FMouseDown := FALSE; // Disable selection if any
          end;
        end;
      end
    else
    begin
      if WPWordDelimiterArray[key] then
      begin
        DoAfterCompleteWordEvent(key);
        if FCPWordModified and (key = #32) then
        begin
          AddHistoryChar(#0);
          Memo.InputString(#32); // Otherwise skipped!
        end;
      end;
    // Auto detect hyperlinks --------------------------------------------------
      if (Key = '.') and (wpAutoDetectHyperlinks in EditOptions) then
      begin
        s := GetHistoryChars(3);
        if s = 'www' then MakeLinkLastChars(3);
      end
      else if (Key = '/') and (wpAutoDetectHyperlinks in EditOptions) then
      begin
        s := GetHistoryChars(6);
        if s = 'http:/' then MakeLinkLastChars(6);
        s := GetHistoryChars(5);
        if s = 'ftp:/' then MakeLinkLastChars(5);
      end
      else if (Key = ':') and (wpAutoDetectHyperlinks in EditOptions) then
      begin
        s := GetHistoryChars(6);
        if s = 'mailto' then MakeLinkLastChars(6);
      end;
    // Frequently links are placed in () so exit when the closing is typed
      if FJustCreatedAutomaticHyperlink and (Key = ')') then CloseAutoLink;
    // -------------------------------------------------------------------------
      AddHistoryChar(key);
    // -------------------------------------------------------------------------
{$IFNDEF UNICODEINPUT}
      if (Key >= #32) and (Key <> #127) and Changing and CheckHasBody then
      begin
      // We check the code page each time since it can be changed ANYTIME!
{$IFDEF UPDATECODEPAGE}
        if not (wpDisableAutoCharsetSelection in EditOptionsEx) then
          FMemo.UpdateCodePage;
{$ENDIF}
        if (Key > #32) then
        begin
{$IFNDEF CLR}FillChar(msg, SizeOf(msg), 0); {$ENDIF}
{$IFDEF USE_INPUTBUFFER}
{$IFDEF USE_INPUTBUFFER_WAIT10}
          if (Length(FMemo._InputBuffer) < 10) and
            not PeekMessage(msg, Handle, WM_KEYDOWN, WM_KEYDOWN, PM_NOREMOVE) and
            not PeekMessage(msg, Handle, WM_MOUSEFIRST, WM_MOUSELAST, PM_NOREMOVE) then
          begin
               // Wait for N mms until mouse or key event ....
            tim := GetTickCount + 100; // 10 to 100 - experimental
            repeat
              Sleep(1);
            until (GetTickCount > tim) or
              PeekMessage(msg, Handle, WM_KEYDOWN, WM_KEYDOWN {WM_KEYFIRST, WM_KEYLAST}, PM_NOREMOVE)
              or PeekMessage(msg, Handle, WM_MOUSEFIRST, WM_MOUSELAST, PM_NOREMOVE);
          end;
{$ENDIF}
          if (Length(FMemo._InputBuffer) < 10)
            and PeekMessage(msg, Handle, WM_KEYDOWN, WM_KEYDOWN {WM_KEYFIRST, WM_KEYLAST}, PM_NOREMOVE)
            and not PeekMessage(msg, Handle, WM_MOUSEFIRST, WM_MOUSELAST, PM_NOREMOVE)
            then
          begin
            FMemo._InputBuffer := FMemo._InputBuffer + Key;
            WasProcessed := TRUE;
          end
          else
{$ELSE}
          if (key = #13) and PeekMessage(msg, Handle, WM_KEYFIRST, WM_KEYLAST, PM_NOREMOVE) then
            FMemo._UseSpeedReformatThisCR := TRUE // at least use speed reformat!
          else FMemo._UseSpeedReformatThisCR := FALSE;
{$ENDIF}
          begin
            FMemo.InputString(Key, true, FMemo._CodePage);
            ChangeApplied;
            ShowCursor;
{$IFDEF USE_INPUTBUFFER}WasProcessed := TRUE; {$ENDIF}
          end;
        end else
        begin
         // #32 ->
            if not ((GetAsyncKeyState(VK_CONTROL) < 0)or
                    (GetAsyncKeyState(VK_SHIFT) < 0) or (GetAsyncKeyState(VK_LSHIFT) < 0)) then
            begin
                if FJustCreatedAutomaticHyperlink then CloseAutoLink;
                FMemo.InputString(#32, true, FMemo._CodePage);
                ChangeApplied;
                ShowCursor;
                FMemo.RTFData.NewUndolevel;
            end;
         end;
      end;
{$ENDIF}
    end;
  // Maybe there was a key but that did not lead to an input, so wee need to finish here
{$IFDEF USE_INPUTBUFFER}
  finally
    if not WasProcessed and (Length(FMemo._InputBuffer) > 0) then
    begin
      FMemo.InputString('', true, FMemo._CodePage); // empties _InputBuffer
      ChangeApplied;
      ShowCursor;
    end;
  end;
{$ENDIF}
end;

procedure TWPCustomRtfEdit.DeleteChar(Count: Integer = 1);
var NeedFullReformat: Boolean;
begin
  NeedFullReformat := FALSE;
  while count > 0 do
  begin
    FMemo.DeleteOne(NeedFullReformat);
    dec(count);
  end;
  if NeedFullReformat then
    StartUpdate(WPUPD_REFORMAT);
end;

function TWPCustomRtfEdit.InsertRow: Boolean;
var row, nrow, par: TParagraph;
  i: Integer;
begin
  row := TableRow;
  HideSelection;
  if row <> nil then
  begin
    nrow := row.NextPar;
    par := row.Duplicate(false, false);
    // Make sure we can append an unmerged row to a table!
    for i := 0 to par.ColCount - 1 do
    begin
      if paprRowMerge in par.Cols[i].prop then
      begin
        if (nrow = nil) or (nrow.Cols[i] = nil) or not
          (paprRowMerge in nrow.Cols[i].prop)
          then exclude(par.Cols[i].prop, paprRowMerge);
      end;
    end;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(par, wpuDeletePar, wputInput);
{$ENDIF}
    TextCursor.active_posinpar := 0;
    ActiveParagraph := par.ColFirst;
    TextCursor.GetCharAttr;
    Result := TRUE;
    DelayedReformat;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.InsertRowAbove: Boolean;
var row, nrow, par: TParagraph;
  i: Integer;
begin
  row := TableRow;
  HideSelection;
  if row <> nil then
  begin
    nrow := row.NextPar;
    par := row.Duplicate(false, false);
    par.SwapWithPrevPar;
    // Make sure we can append an unmerged row to a table!
    for i := 0 to par.ColCount - 1 do
    begin
      if paprRowMerge in par.Cols[i].prop then
      begin
        if (nrow = nil) or (nrow.Cols[i] = nil) or not
          (paprRowMerge in nrow.Cols[i].prop)
          then exclude(par.Cols[i].prop, paprRowMerge);
      end;
    end;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(par, wpuDeletePar, wputInput);
{$ENDIF}
    TextCursor.active_posinpar := 0;
    ActiveParagraph := par.ColFirst;
    TextCursor.GetCharAttr;
    Result := TRUE;
    DelayedReformat;
  end else Result := FALSE;
end;


function TWPCustomRtfEdit.DeleteRow: Boolean;
var par, npar: TParagraph;
begin
  par := TableRow;
  HideSelection;
  if par <> nil then
  begin
    npar := par.NextPar;
    if npar = nil then npar := par.PrevPar;
    if npar = nil then
    begin
      par := par.ParentPar;
      npar := par.NextPar;
      if npar = nil then npar := par.PrevPar;
    end else npar := npar.ColFirst;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(par, wpuInsertPar, wputDeleteText);
{$ENDIF}
    if par.ParagraphType = wpIsTable then
    begin
      npar := par.PrevPar;
      par.DeleteParagraph;
      if npar = nil then npar := FirstPar;
      TextCursor.MoveTo(npar, MaxInt);
    end else
    begin
      par.DeleteParagraph;
      if npar <> nil then ActiveParagraph := npar
      else ActiveParagraph := FirstPar;
    end;
    TextCursor.GetCharAttr;
    DelayedReformat;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.DeleteColumn: Boolean;
var partable: TParagraph;
begin
  Result := FALSE;
  if Memo.Cursor.SelectThisColumn(false) then
  try
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      Memo.RTFData.UndoBufferSaveTo(Table,
        wpuReplaceParTotal, wputDeleteText, 0, false);
    Memo.RTFData.UndoDisable;
{$ENDIF}
    with TextCursor.GetSelectedCells(true) do
    try
      HideSelection;
      partable := Table;
      if TableCell.NextPar <> nil then
        ActiveParagraph := TableCell.NextPar
      else if TableCell.PrevPar <> nil then
        ActiveParagraph := TableCell.PrevPar
      else
      begin
        ActiveParagraph := Table;
        if ActiveParagraph.PrevPar <> nil then
        begin
          TextCursor.MoveTo(ActiveParagraph.PrevPar, MaxInt);
        end;
      end;
      while Current <> nil do
      begin
        Current.DeleteParagraph;
        NextPar;
        Result := TRUE;
      end;
    finally
      Free;
    end;
    if Result then
    begin
      partable.ValidateTable;
      DelayedReformat;
    end;
  finally
{$IFDEF ALLOWUNDO}
    Memo.RTFData.UndoEnable;
{$ENDIF}
  end;
end;

function TWPCustomRtfEdit.InsertColumn: Boolean;
begin
  if Memo.Cursor.SelectThisColumn(false) then
  begin
    SplitCells;
    HideSelection;
    Result := TRUE;
  end
  else Result := FALSE;
end;


function TWPCustomRtfEdit.DeleteTable: Boolean;
var par, npar: TParagraph;
begin
  par := Table;
  if par <> nil then
  begin
    if par.NextPar <> nil then npar := par.NextPar
    else npar := par.PrevPar;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(par, wpuInsertPar, wputDeleteText);
{$ENDIF}
    par.DeleteParagraph;
    if npar = nil then ActiveParagraph := FirstPar
    else ActiveParagraph := npar;
    DelayedReformat;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.SplitTable: Boolean;
var
  apar, par, atable: PTParagraph;
begin
  par := TableRow;
  if (par <> nil) and (par.NextPar <> nil) then
  begin
    atable := par.ParentTable;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(atable, wpuReplaceParTotal);
{$ENDIF}
    apar := TParagraph.Create(atable.RTFData);
    apar.Assign(atable, false);
    apar.ParagraphType := wpIsTable;
    apar.ChildPar := par.NextPar.UnlinkParagraphList;
    atable.NextPar := apar;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(apar, wpuDeletePar);
{$ENDIF}
    apar := apar.ColFirst;
    TextCursor.MoveTo(apar, 0);
    Result := TRUE;
    DelayedReformat;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.SplitCells: Boolean;
begin
  Result := FALSE;
  if not TextCursor.IsSelected and (TableCell <> nil) then
  begin
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      UndoBufferSaveTo(TableCell.ParentRow, wpuReplaceParTotal);
{$ENDIF}
    TableCell.SplitCell;
    Result := TRUE;
  end else
    with TextCursor.GetSelectedCells(true, true) do
    try
      if (wpActivateUndo in EditOptions) then StartUndolevel;

      while Current <> nil do
      begin
{$IFDEF ALLOWUNDO}
        if (wpActivateUndo in EditOptions) then
          UndoBufferSaveTo(Current.ParentRow, wpuReplaceParTotal);
{$ENDIF}
        if wpAllowSplitOfCombinedCellsOnly in EditOptionsEx then
          Current.SplitCell(MaxInt, [wpOnlySplitMergedCells])
        else Current.SplitCell(MaxInt, []);
        NextPar;
        Result := TRUE;
      end;
      if (wpActivateUndo in EditOptions) then EndUndolevel;
    finally
      Free;
    end;
  if Result then DelayedReformat;
end;

{ In this implementation we actually combine the cells! }

function TWPCustomRtfEdit.CombineCells: Boolean;
begin
  Result := FALSE;
  with TextCursor.GetSelectedCells(true) do
  try
    HeaderFooter.StartUndolevel;
    ToEnd;
    while Current <> nil do
    begin
      if (Current.NextPar <> nil) and (paprCellIsSelected in Current.NextPar.prop) then
      begin
        Current.MergeCell(wpKeepCellsWhenCombiningCells in EditOptionsEx);
        Result := TRUE;
      end;
      PrevPar;
    end;
  finally
    Free;
    HeaderFooter.EndUndolevel;
  end;
  if Result then DelayedReformat;
end;

function TWPCustomRtfEdit.CombineCellsVertically: Boolean;
var firstrow, r: Integer;
  lastcell, firstcell: TParagraph;
begin
  Result := FALSE;
  firstrow := -1;
  firstcell := nil;
  lastcell := nil;
  with TextCursor.GetSelectedCells do
  try
    HeaderFooter.StartUndolevel;
    ToStart;
    while Current <> nil do
    begin
      if paprCellIsSelected in Current.prop then
      begin
        lastcell := Current;
        if firstcell = nil then firstcell := Current;
        r := Current.RowNr;
        if firstrow < 0 then firstrow := r;
{$IFDEF ALLOWUNDO}
        if wpActivateUndo in EditOptions then
          HeaderFooter.UndoBufferSaveTo(Current, wpuUpdatePROP, wputAny);
{$ENDIF}
        if r > firstrow then
        begin
          include(Current.prop, paprRowMerge);
          Result := TRUE;
        end
        else include(Current.prop, paprRowMergeFirst);
      end;
      NextPar;
    end;
    if firstcell <> lastcell then
    begin
{$IFDEF ALLOWUNDO}
      if wpActivateUndo in EditOptions then
        HeaderFooter.UndoBufferSaveTo(lastcell, wpuUpdateAttr, wputAny);
{$ENDIF}
      if (lastcell.AGetDef(WPAT_BorderFlags, 0) and WPBRD_DRAW_Bottom) <> 0 then
      begin
        firstcell.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Bottom);
        firstcell.ASetNeutral(WPAT_BorderWidthB, lastcell.AGetDef(WPAT_BorderWidthB, 0));
        firstcell.ASetNeutral(WPAT_BorderColorB, lastcell.AGetDef(WPAT_BorderColorB, 0));
        firstcell.ASetNeutral(WPAT_BorderTypeB, lastcell.AGetDef(WPAT_BorderTypeB, 0));
      end;
    end;
  finally
    HeaderFooter.EndUndolevel;
    Free;
  end;
  if Result then DelayedReformat;
end;

procedure TWPCustomRtfEdit.SelectThisRow;
begin
  TextCursor.SelectThisRow;
end;

procedure TWPCustomRtfEdit.SelectThisColumn;
begin
  TextCursor.SelectThisColumn;
end;

procedure TWPCustomRtfEdit.SelectThisCell;
begin
  TextCursor.SelectThisCell;
end;

procedure TWPCustomRtfEdit.SelectThisTable;
begin
  TextCursor.SelectThisTable;
end;

function TWPCustomRtfEdit.cmpFindInPar(Sender: TObject; par: TParagraph): Boolean;
begin
  Result := par.HasText(FFindInParText, false, false);
end;

function TWPCustomRtfEdit.cmpIsEmpty(Sender: TObject; par: TParagraph): Boolean;
begin
  // Children paragraphs in table cells are ignored. They were handled differently!
  Result := par.HasObjects(false, [wpobjMergeField]);
  if Result then
    Result := not par.IsNonSpace([wpobjMergeField], (paprIsTable in par.prop));
end;

function TWPCustomRtfEdit.DeleteParWithCondition(Condition: TWPCheckParagraph): Boolean;
var apar, arow, row, cell, ccell, accell, par: TParagraph;
  b, d, c: Boolean;
begin
  par := LastPar;
  b := FALSE;
  while par <> nil do
  begin
    apar := par.PrevPar;
    if par.ParagraphType = wpIsSTDPar then
    begin
      if Condition(Self, par) then
      begin
        par.DeleteParagraph;
        b := TRUE;
      end;
    end else
      if par.ParagraphType = wpIsTable then
      begin
        row := par.LastChild;
        d := TRUE;
        while row <> nil do
        begin
          arow := row.PrevPar;
          if row.ParagraphType = wpIsTableRow then
          begin
            c := TRUE;
            cell := row.ChildPar;
            while cell <> nil do
            begin
              ccell := cell.LastChild;
              if ccell = nil then // Simple cell, no children
              begin
                if Condition(Self, cell) then
                begin
                  cell.ClearText(false);
                  b := TRUE;
                end
                else c := FALSE;
              end else // has children . check them, too
              begin
                while ccell <> nil do
                begin
                  accell := ccell.PrevPar;
                  if (ccell.ParagraphType = wpIsSTDPar)
                    and Condition(Self, ccell) then
                  begin
                    ccell.DeleteParagraph;
                    b := TRUE;
                  end
                  else c := FALSE;
                  ccell := accell;
                end;
                if Condition(Self, cell) then
                begin
                  cell.ClearText(false);
                  cell.DeleteParagraphEnd;
                  b := TRUE;
                end
                else c := FALSE;
              end;
              cell := cell.NextPar;
            end;
            if c then
            begin
              row.DeleteParagraph;
              b := TRUE;
            end else d := FALSE;
          end;
          row := arow;
        end;
        if d then par.DeleteParagraph; // Complete Table is empty ....
      end;
    par := apar;
  end;
  if b then
  begin
    CPPosition := 0;
    DelayedReformat;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.DeleteParWithEmptyFields: Boolean;
begin
  Result := DeleteParWithCondition(cmpIsEmpty);
end;

function TWPCustomRtfEdit.DeleteParWithText(const FindText: string): Boolean;
begin
  FFindInParText := FindText;
  Result := DeleteParWithCondition(cmpFindInPar);
end;

procedure TWPCustomRtfEdit.DeletePage(index: Integer);
begin
  FMemo.DeletePage(index);
end;

procedure TWPCustomRtfEdit.DeleteParagraphBreaks(Mode: TWPDeleteParagraphBreakModes);
var alen: Integer;
  procedure Process(par, epar: TParagraph);
  var cha: Cardinal;
    npar: TParagraph;
    delit: Boolean;
    i, l: Integer;
  begin
    while par <> nil do
    begin
      if par.ParagraphType = wpIsSTDPar then
      begin
        if wpDeleteDoubleSpaceBetweenWord in mode then
        begin
          i := 0;
          while (i < par.CharCount) and par.IsSpace(i) do inc(i);
          while i < par.CharCount do
          begin
            if (par.ANSIChr[i] = #32) and
              (par.ANSIChr[i + 1] = #32) then
            begin
              if not par.IsSpace(i + 2) then
              begin par.DeleteChar(i); end
              else if (par.ANSIChr[i + 2] = #32) and
                not par.IsSpace(i + 3) then
              begin
                par.DeleteChar(i);
                par.DeleteChar(i);
              end;
              while (i < par.CharCount) and par.IsSpace(i) do inc(i);
            end
            else inc(i);
          end;
        end;
        npar := par.NextPar;
        delit := (npar <> nil) and (npar.ParagraphType = wpIsSTDPar);
        // Keep if after empty paragraph
        if delit and (wpKeepLogicalPar in Mode) then
        begin
          if not par.IsNonSpace([], false) then
          begin
             // Keep paragraphs which ALSO start with 3 spaces
            if (wpKeepIfStartWith3SPC in Mode) then
            begin
              if (npar.CharCount > 2) and
                ((npar.CharItem[0] = #32) or (npar.CharItem[0] = #160)) and
                ((npar.CharItem[1] = #32) or (npar.CharItem[1] = #160)) and
                ((npar.CharItem[2] = #32) or (npar.CharItem[2] = #160))
                then
              begin
                par := par.PrevPar; // Keep this empty line
                if par <> nil then par := par.PrevPar;
                continue;
              end
              else delit := (par.PrevPar = nil) or not par.PrevPar.IsNonSpace([], false);
            end else
              delit := FALSE;
          end;
        end // Keep paragraphs which start with 3 spaces
        else if delit and (wpKeepIfStartWith3SPC in Mode) then
        begin
          if (npar.CharCount > 2) and
            ((npar.CharItem[0] = #32) or (npar.CharItem[0] = #160)) and
            ((npar.CharItem[1] = #32) or (npar.CharItem[1] = #160)) and
            ((npar.CharItem[2] = #32) or (npar.CharItem[2] = #160))
            then
          begin
            delit := FALSE;
          end;
        end;

        // Remove the start spaces from this paragraph, even if we do not delete the break!
        if delit and (wpDeleteTrailingSpaces in Mode) then
        begin
          i := 0;
          while i < npar.CharCount do
          begin
            if (npar.CharItem[i] <> #32) and
              (npar.CharItem[i] <> #160) and
              (npar.CharItem[i] <> #9) then break;
            inc(i);
          end;
          if i > 0 then
            npar.DeleteChars(0, i);
        end;

        // Delete that break, unless it is a logical
        if delit then
        begin
          l := npar.CharCount;
          i := par.CharCount;
          if i > 0 then
            cha := par.CharAttr[i - 1]
          else cha := 0;
          if par.DeleteParagraphEnd then
          begin
            // Insert a space or new line code
            if (i > 0) then
            begin
              if wpReplaceWithNL in Mode then
                par.Insert(i, #10, cha)
              else
                if (wpReplaceWithSPC in Mode) and (l > 0) then
                  par.Insert(i, #32, cha);
            end
            else dec(alen);
          end;
        end;
      end;

      if (par = epar) or (par.PrevPar = nil) then
      begin
        // Remove the start spaces from this last paragraph
        if wpDeleteTrailingSpaces in Mode then
        begin
          i := 0;
          while i < par.CharCount do
          begin
            if (par.CharItem[i] <> #32) and (par.CharItem[i] <> #160) and
              (par.CharItem[i] <> #9) then break;
            inc(i);
          end;
          if i > 0 then par.DeleteChars(0, i);
        end;
        break;
      end;
      par := par.PrevPar;
    end;
  end;
var par, epar: TParagraph; spos: Integer; epos: Integer;
begin
  alen := 0;
  FMemo.RTFData.UndoStoreComplete;
  FMemo.RTFData.UndoDisable;
  try
    if wpWorkWithSelection in mode then
    begin
      par := TextCursor.GetBlockStart(spos);
      epar := TextCursor.GetBlockEnd(epos);
      if (par <> epar) then
      begin
        GetSelPosLen(spos, alen);
        Process(epar.PrevPar, par);
        SetSelPosLen(spos, alen);
      end;
    end else
    begin
      if ActiveText <> nil then
        par := ActiveText.FirstPar
      else par := FirstPar;
      while par.NextPar <> nil do par := par.NextPar;
      Process(par, nil);
    end;
  finally
    FMemo.RTFData.UndoEnable;
  end;
  DelayedReformat;
end;

function TWPCustomRtfEdit.DeleteTrailingSpace(EmptyFieldsToo: Boolean): Boolean;
var par, apar: TParagraph;
  b: Boolean;
  i: Integer;
  IgnoredObjTypes: TWPTextObjTypes;
begin
  par := LastPar;
  b := FALSE;
  if EmptyFieldsToo then IgnoredObjTypes := [wpobjMergeField]
  else IgnoredObjTypes := [];
  while par <> nil do
  begin
    apar := par.PrevPar;
    if (par.ParagraphType = wpIsSTDPar) and
      not par.IsNonSpace([wpobjMergeField]) then
    begin
      par.DeleteParagraph;
      b := TRUE;
    end else
    begin
         // Truncate that last line ....
      if par.ParagraphType = wpIsSTDPar then
      begin
        i := par.CharCount - 1;
        while (i >= 0) and par.IsSpace(i) do dec(i);
        par.CharCount := i + 1;
        if (TextCursor.active_paragraph = par) and
          (TextCursor.active_posinpar > par.CharCount) then
        begin
          TextCursor.active_posinpar := par.CharCount;
          ShowCursor;
        end;
      end;
      break;
    end;
    par := apar;
  end;
  if b then DelayedReformat;
  Result := b;
end;

function TWPCustomRtfEdit.DeleteLeadingSpace(EmptyFieldsToo: Boolean; InFirstPar: Boolean = TRUE): Boolean;
var
  par: TParagraph;
  i: Integer;
  b: Boolean;
  IgnoredObjTypes: TWPTextObjTypes;
begin
  b := FALSE;
  if EmptyFieldsToo then IgnoredObjTypes := [wpobjMergeField]
  else IgnoredObjTypes := [];

  par := FirstPar;
  while par <> nil do
  begin
    if (par.ParagraphType <> wpIsSTDPar) or
      par.IsNonSpace(IgnoredObjTypes) then break;
    par := par.DeleteParagraph;
    b := TRUE;
  end;
  if InFirstPar and (par <> nil) then
  begin
    i := 0;
    while par.IsSpace(i) and (i < par.CharCount) do inc(i);
    if i > 0 then
    begin
      par.DeleteChars(0, i);
      b := TRUE;
    end;
  end;
  CPPosition := 0;

  if b then DelayedReformat;
  Result := b;
end;

procedure TWPCustomRtfEdit.KeyDown(var Key: Word; Shift: TShiftState);
var ScrollMessage: TWMScroll;
{$IFDEF UNICODEINPUT}
  wide: WideString;
  res: Integer;
{$ENDIF}
  par, newpar: TParagraph;
  b: Boolean;
  i: Integer;
  procedure MoveLeft;
  begin
    if not (ssShift in Shift) then HideSelection;
    FMemo.CompleteSpellCheck;
    if ssCtrl in Shift then
      FMemo.c_move(wpmWLeft, ssShift in Shift)
    else FMemo.c_move(wpmCLeft, ssShift in Shift);
    FMemo.Cursor.GetCharAttr;
    FMemo.RTFData.NewUndolevel;
    AddHistoryChar(#0);
  end;
  procedure MoveRight;
  begin
    if not (ssShift in Shift) then HideSelection;
    FMemo.CompleteSpellCheck;
    if ssCtrl in Shift then
      FMemo.c_move(wpmWRight, ssShift in Shift)
    else FMemo.c_move(wpmCRight, ssShift in Shift);
    FMemo.Cursor.GetCharAttr;
    FMemo.RTFData.NewUndolevel;
    AddHistoryChar(#0);
  end;
begin
  inherited KeyDown(Key, Shift);
  if not FMemo.HasData then exit;
  case Key of
   VK_SPACE:
      if Shift = [ssCtrl] then // Special command, Ctrl + Space
      begin
       // The event OnDelayedUpdate can be used
       // to react. This event is triggered asynchronly!
        StartUpdate(WPUPD_CTRL_SPACE_KEY, 0);
      end else if Shift = [ssShift, ssCtrl] then
      begin
        if Changing then
        begin
          if FJustCreatedAutomaticHyperlink then CloseAutoLink;
          FMemo.InputString(#160, true, FMemo._CodePage); // hard space
          ChangeApplied;
          ShowCursor;
          FMemo.RTFData.NewUndolevel;
        end;
      end;
    VK_LEFT: MoveLeft; { if (FMemo.Cursor.active_paragraph = nil) or
      not (paprRightToLeft in FMemo.Cursor.active_paragraph.prop) then
        MoveLeft else MoveRight;  }
    VK_RIGHT: MoveRight; { if (FMemo.Cursor.active_paragraph = nil) or
      not (paprRightToLeft in FMemo.Cursor.active_paragraph.prop) then
        MoveRight else MoveLeft; }
    VK_DOWN:
      begin
        if not (ssShift in Shift) then HideSelection;
        FMemo.CompleteSpellCheck;
        if not FMemo.c_move(wpmCDown, ssShift in Shift) and (ssShift in Shift) then
          FMemo.c_move(wpmLEnd, ssShift in Shift);
        FMemo.Cursor.GetCharAttr;
        FMemo.RTFData.NewUndolevel;
        AddHistoryChar(#0);
      end;
    VK_UP:
      begin
        if not (ssShift in Shift) then HideSelection;
        FMemo.CompleteSpellCheck;
        if not FMemo.c_move(wpmCUp, ssShift in Shift) and (ssShift in Shift) then
          FMemo.c_move(wpmLStart, ssShift in Shift);
        FMemo.Cursor.GetCharAttr;
        FMemo.RTFData.NewUndolevel;
        AddHistoryChar(#0);
      end;
    VK_DELETE: if Changing then
      begin
        FMemo.RTFData.NewUndolevel;
        if ssCtrl in Shift then
        begin
          if IsSelected then CutToClipboard else
          begin
            par := ActiveParagraph;
            i := ActivePosInPar;
            if par.IsSpace(i) then
            begin
              while par.IsSpace(i) and (i < par.CharCount) do inc(i);
              if not par.IsSpace(ActivePosInPar - 1) then
                while not par.IsSpace(i) and (i < par.CharCount) do inc(i);
            end
            else
            begin
              while not par.IsSpace(i) and (i < par.CharCount) do inc(i);
              if par.IsSpace(ActivePosInPar - 1) then
                while par.IsSpace(i) and (i < par.CharCount) do inc(i);
            end;
            i := i - ActivePosInPar;
            if i <= 0 then i := 1;
            while i > 0 do
            begin
              FMemo.InputString(#127, true);
              dec(i);
            end;
          end;
        end
        else FMemo.InputString(#127, true);
        ChangeApplied;
        ShowCursor;
      end;
    VK_INSERT:
      if ssShift in Shift then PasteFromClipboard
      else if ssCtrl in Shift then CopyToClipboard
      else
        if (TextCursor.active_paragraph <> nil) and
          (TextCursor.active_paragraph.ParagraphType = wpIsReportGroup) then
        begin
          newpar := TParagraph.Create(TextCursor.RTFData);
          TextCursor.active_paragraph.NextPar := newpar;
          DelayedReformat;
          ChangeApplied;
          TextCursor.MoveTo(newpar);
        end else
        begin
          if not TextCursor.Inserting or not
            (wpAlwaysInsert in EditOptions) then
            TextCursor.Inserting := not TextCursor.Inserting;
          ShowCursor;
        end;
    VK_BACK: if Changing then
      begin
        if ssAlt in Shift then
        begin
          if (ssShift in Shift) and (wpActivateRedoHotkey in EditOptions) then
            Redo
          else if wpActivateUndoHotkey in EditOptions then Undo;
        end
        else
        begin
          if ssCtrl in Shift then
          begin
            b := FALSE;
            while (CPPrevChar in [#9, #32, #160]) and FMemo.DeleteLast do b := TRUE;
            while (CPPrevChar > #32) and FMemo.DeleteLast do b := TRUE;
            if b then DelayedReformat
            else
            begin
{$IFDEF USE_INPUTBUFFER} // required because of the CPMoveBack;!
              if Length(FMemo._InputBuffer) > 0 then FMemo.InputString('', false, FMemo._CodePage);
{$ENDIF}
              CPMoveBack;
              FMemo.InputString(#127, true);
            end;
          end else
          begin
{$IFDEF USE_INPUTBUFFER}
            if Length(FMemo._InputBuffer) > 0 then
              SetLength(FMemo._InputBuffer, Length(FMemo._InputBuffer) - 1)
            else
{$ENDIF}
              FMemo.InputString(#8, true);
          end;
          ChangeApplied;
        end;
        ShowCursor;
        key := 0;
        AddHistoryChar(#8);
      end;
    VK_TAB:
      if Shift = [ssShift, ssCtrl] then
      begin
        // The event OnDelayedUpdate can be used
        // to react. This event is triggered asynchronly!
        StartUpdate(WPUPD_SHIFTCTRL_TAB, 0);
      end else
        if wpTABMovesToNextEditField in EditOptionsEx then
        begin
          if ssCtrl in Shift then
            MoveToPreviousField(false)
          else MoveToNextField(false)
        end else
          if WantTabs then
          begin
            if FJustCreatedAutomaticHyperlink then CloseAutoLink;
            if FAutoConvertTabs and not FWantTabs then Shift := [];
        // 5.11.1 new wpSpreadsheetCursorMovement code
            if (Shift <> [ssCtrl]) and
              (wpSpreadsheetCursorMovement in EditOptions) and InTable then
            begin
              par := ActiveParagraph.Cell;
              if par <> nil then
              begin
                if Shift = [ssShift] then
                begin
                  if par.PrevCell <> nil then par := par.PrevCell
                  else if (wpNoEditOutsideTable in EditOptions) then par := nil
                  else par := par.ParentTable.PrevPar;
                end
                else
                begin
                  if (wpAutoInsertRow in EditOptions) and (par.NextCell = nil) then
                  begin
                    InsertRow;
                    par := nil;
                  end else
                  begin
                    if par.NextCell <> nil then par := par.NextCell
                    else if (wpNoEditOutsideTable in EditOptions) then par := nil
                    else par := par.ParentTable.NextPar;
                  end;
                end;
                if par <> nil then
                begin
                  if TextCursor.MoveTo(par, 0) then
                  begin
                    TextCursor.GetCharAttr;
                    ShowCursor;
                  end;
                end;
              end;
            end else
              if not Readonly then
              begin
                FMemo.RTFData.NewUndolevel;
                FMemo.InputString(#9, true);
                ChangeApplied;
                ShowCursor;
              end;
          end;
    VK_RETURN:
      if WantReturns and Changing then
      begin
        if FJustCreatedAutomaticHyperlink then CloseAutoLink;
        AddHistoryChar(#13);
        FMemo.RTFData.NewUndolevel;
        if ssShift in Shift then
          FMemo.InputString(#10, true)
        else if ssCtrl in Shift then
          FMemo.InputString(#12, true)
        else FMemo.InputString(#13, true);
        ChangeApplied;
        ShowCursor;
      end;
    189, VK_SUBTRACT: if Changing then // Hyphen
        if (wpUseHyphenation in FormatOptions) and (Shift = [ssCtrl]) then
        begin
          if not WPIsWordDelimiter(CPWideChar) then
          begin
            CPCharAttr := CPCharAttr xor cafsHyphen;
            if FMemo.Cursor.active_paragraph.Reformat then
              FMemo.ReformatAll;
            ChangeApplied;
            Memo.RePaint;
          // Memo.ShowCursor;
          end;
          Key := 0;
        end;
    VK_HOME:
      if not (ssAlt in Shift) then
      begin
        if not (ssShift in Shift) then HideSelection;

        if (ssShift in Shift) and (ssCtrl in Shift) and
          (ActivePosInPar >= ActiveParagraph.CharCount - 1) and ActiveParagraph.IsLastPar then
        begin
          SelectAll; // Quickly select ALL text
          FMemo.c_move(wpmHome, false);
        end
        else if ssCtrl in Shift then
          FMemo.c_move(wpmHome, ssShift in Shift)
        else
          FMemo.c_move(wpmLStart, ssShift in Shift);
        FMemo.Cursor.GetCharAttr;
        FMemo.RTFData.NewUndolevel;
        ShowCursor;
        AddHistoryChar(#0);
      end;
    VK_END:
      if not (ssAlt in Shift) then
      begin
        if not (ssShift in Shift) then HideSelection;

        if (ssShift in Shift) and (ssCtrl in Shift) and
          (ActivePosInPar = 0) and ActiveParagraph.IsFirstPar then
        begin
          SelectAll; // Quickly select ALL text
          FMemo.c_move(wpmEnd, false);
        end
        else if ssCtrl in Shift then
          FMemo.c_move(wpmEnd, ssShift in Shift)
        else
          FMemo.c_move(wpmLEnd, ssShift in Shift);
        FMemo.Cursor.GetCharAttr;
        FMemo.RTFData.NewUndolevel;
        ShowCursor;
        AddHistoryChar(#0);
      end;
    VK_NEXT:
      if not (ssAlt in Shift)
{$IFDEF WPDONT_USE_SHIFTCTRL}
      and not ((Shift * [ssShift, ssCtrl]) = [ssShift, ssCtrl])
{$ENDIF} then
      begin
        if not (ssShift in Shift) and not (Shift = [ssCtrl]) then HideSelection;
        if Shift = [ssCtrl] then
        begin
          ScrollMessage.ScrollCode := Integer(scPageDown);
          WMVScroll(ScrollMessage);
        end
        else
        begin
          FMemo.c_move(wpmPagDown, ssShift in Shift);
          FMemo.Cursor.GetCharAttr;
          FMemo.RTFData.NewUndolevel;
        end;
        AddHistoryChar(#0);
      end;
    VK_Prior:
      if not (ssAlt in Shift)
{$IFDEF WPDONT_USE_SHIFTCTRL}
      and not ((Shift * [ssShift, ssCtrl]) = [ssShift, ssCtrl])
{$ENDIF} then
      begin
        if not (ssShift in Shift) and not (Shift = [ssCtrl]) then HideSelection;
        if Shift = [ssCtrl] then
        begin
          ScrollMessage.ScrollCode := Integer(scPageUp);
          WMVScroll(ScrollMessage);
        end
        else
        begin
          FMemo.c_move(wpmPagUp, ssShift in Shift);
          FMemo.Cursor.GetCharAttr;
          FMemo.RTFData.NewUndolevel;
        end;
        AddHistoryChar(#0);
      end;
    VK_ESCAPE:
      begin
        if FJustCreatedAutomaticHyperlink then CloseAutoLink;
        if (CursorOnText <> DisplayedText) and
          (CursorOnText <> nil) and
          (CursorOnText.Kind <> wpIsBody) then
        begin
          if Memo.ExitEditor then ShowCursor;
        end;
      end;
  else
    begin
      //B5.13.5 Shift is only [ssCtrl], no ALT and no SHIFT !
      if (Shift = [ssCtrl]) and (wpActivateRedoHotkey in EditOptions) and
        (key = Integer('Y')) then
      begin
        Redo;
      end
      else if (Shift = [ssCtrl]) and (key = Integer('A')) then
      begin
        SelectAll;
      end
      else if (Shift = [ssCtrl]) and (wpActivateUndoHotkey in EditOptions)
        and (key = Integer('Z')) then
      begin
        Undo;
        AddHistoryChar(#0);
      end
      else
      begin
{$IFDEF UNICODEINPUT}
        wide := '    ';
        res := ToUnicode(Key,
          0,
          lpKeyState,
          wide[1],
          4,
          0);
        if (res > 0) and Changing then
        begin
          SetLength(wide, res);
          FMemo.InsertWideString(wide, true); // NOT InputString!
          ChangeApplied;
          Changed;
        end;

        if wide = #32 then FMemo.RTFData.NewUndolevel;
{$ENDIF}
      end;
    end;
  end;

{$IFDEF UPDATE_CURSOR_ATONCE}
  // Make sure the screen/cursor is updated at once!
  if (key = VK_LEFT) or (key = VK_RIGHT) or
    (key = VK_UP) or (key = VK_DOWN) then
  begin
    if IsSelected then Update
    else
    begin
      FCaret.UpdatePos;
      FCaret.Move;
      AddHistoryChar(#0);
    end;
  end;
{$ENDIF}

  if (key = VK_NEXT) or (key = VK_Prior) or
    (key = VK_HOME) or (key = VK_END) then
  begin
    if (FPreview <> nil) and not (csDestroying in FPreview.ComponentState) then
      FPreview.DelayedInvalidate;
  end;

end;

function TWPCustomRtfEdit.DoMouseDownWord(par: TParagraph;
  pos_in_par: Integer;
  Button: TMouseButton;
  Shift: TShiftState;
  X, Y: Integer): Boolean;
var i, len, cppos: Integer;
  oText, text: string;
  oCharAttr, CharAttr: Cardinal;
  Abort, HasChanged: Boolean;
begin
  Abort := FALSE;
  HasChanged := FALSE;
  if assigned(FOnMouseDownWord) or assigned(_3RDParty_OnMouseDownWord) then
  begin
    if (pos_in_par >= 0) and (pos_in_par < par.CharCount) and
      not par.IsWordDelimiter(pos_in_par) then
    begin
      while (pos_in_par > 0) and not par.IsWordDelimiter(pos_in_par) do dec(pos_in_par);
      if par.IsWordDelimiter(pos_in_par) then inc(pos_in_par);
      len := 0;
      while not par.IsWordDelimiter(pos_in_par + len) do inc(len);
      CharAttr := par.CharAttr[pos_in_par];
      oCharAttr := CharAttr;
      text := par.GetSubText(pos_in_par, len);
      oText := text;

      cppos := par.RTFData.GetPosition(par, pos_in_par);

      if not Abort and assigned(_3RDParty_OnMouseDownWord)
        then
        _3RDParty_OnMouseDownWord(Self, Button, Shift, X, Y, par,
          pos_in_par, cppos, len, text, CharAttr, Abort);

      if not Abort and assigned(FOnMouseDownWord)
        then
        FOnMouseDownWord(Self, Button, Shift, X, Y, par,
          pos_in_par, cppos, len, text, CharAttr, Abort);

       // The text has been changed
      if oText <> text then
      begin
        SaveChanging;
        // Quickly adjust selection
        with TextCursor do
        begin
          if (TextCursor.block_e_par = par) and not TextCursor.block_reverse and
            (TextCursor.block_e_posinpar = pos_in_par + Length(oText)) then
            TextCursor.block_e_posinpar := pos_in_par + Length(text);
        end;

{$IFDEF ALLOWUNDO}
        if (wpActivateUndo in EditOptions) then
          HeaderFooter.UndoBufferSaveTo(par, wpuReplaceParText, wputReplace);
{$ENDIF}

        par.Replace(pos_in_par, len, text);
        HasChanged := TRUE;
      end;
       // Attrib has changed
      if (CharAttr and $00FFFFFF) <> (oCharAttr and $00FFFFFF) then
      begin
        SaveChanging;
{$IFDEF ALLOWUNDO}
        if not HasChanged and (wpActivateUndo in EditOptions) then
          HeaderFooter.UndoBufferSaveTo(par, wpuReplaceParText, wputReplace);
{$ENDIF}

        for i := 0 to len - 1 do
          par.CharAttr[pos_in_par + i] := CharAttr;
        HasChanged := TRUE;
      end else
       // Only the CAFS marker have been changed
        if (CharAttr and $FF000000) <> (oCharAttr and $FF000000) then
        begin
          for i := 0 to len - 1 do
            par.CharAttr[pos_in_par + i] :=
              (par.CharAttr[pos_in_par + i] and $00FFFFFF) or
              (CharAttr and $FF000000);
        end;

      FIgnoreMouse := FALSE;

      if HasChanged then
      begin
        include(par.prop, paprMustInit);
        // instead of 'DelayedReformat;' do this:
        if (FLocked <= 0) and (FLockScreen <= 0) then
        begin
          FMemo.RTFData.NeedReformat;
          StartUpdate(WPUPD_REFORMAT);
          StartUpdate(WPUPD_UPDATTRIBUTES);
           //NO!!! StartUpdate(WPUPD_SHOWCURSOR);
          invalidate;
        end;
      end;
    end;
  end;
  Result := not Abort;
end;

// Handle ContextMenu --- V5.19.8

procedure TWPCustomRtfEdit.DoContextPopup(MousePos: TPoint; var Handled: Boolean);
var x, y, w, h: Integer; aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par: Integer;
  FrameBorder: TWPFrameBorder;
  SizerElement: TWPPaintSizerRects;
  p: TPoint;
  Button: TMouseButton;
begin
  Handled := FALSE;
  if (MousePos.X = -1) and (MousePos.Y = -1) and
    GetTextScreenRect(ActiveParagraph, ActivePosInPar, x, y, w, h, true) then
  begin
    MousePos.X := X;
    MousePos.Y := Y;
  end;
  if not (wpDontTriggerPopupInContextEvent in EditOptionsEx) then
  begin
    X := MousePos.X;
    Y := MousePos.Y;
    FCurrentWindowMouseX := X;
    FCurrentWindowMouseY := Y;
    FLastMouseWasDrag := False;
    Button := mbRight;
    CalcMousePageAtXY(X, Y);
    FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
      par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement);
    FMouseNoParFound := par = nil;
    if (Button = mbRight) and
      (FGraphicPopupMenu <> nil) and (FTextObjectUnderMouse <> nil) and
      (FTextObjectUnderMouse.ObjRef <> nil) and
      (FTextObjectUnderMouse.ObjType = wpobjImage) then
    begin
      p := ClientToScreen(Point(X, Y));
      FGraphicPopupMenu.Popup(p.x, p.y);
      Handled := TRUE;
    end
    else
    begin
      if (FTextObjectUnderMouse = nil) and (par <> nil) and not par.IsCharObject(pos_in_par)
        then
      begin
        if not DoMouseDownWord(par, pos_in_par, Button, [], X, Y) then Handled := TRUE;
      end;
    end;
  end;
  inherited;
  if not Handled and (PopupMenu <> nil) and PopupMenu.AutoPopup then
  begin
    p := ClientToScreen(Point(X, Y));
    PopupMenu.Popup(p.X, p.Y);
    Handled := TRUE;
  end;
end;

procedure TWPCustomRtfEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var ox, oy, ow, oh, val, val2: Integer;
  aRTFData: TWPRTFDataBlock;
  par, par2: TParagraph;
  pos_in_par: Integer;
  FrameBorder: TWPFrameBorder;
  SizerElement: TWPPaintSizerRects;
  oldobj: TWPTextObj;
  Ignore: Boolean;
  p: TPoint;
begin
  if FInMouseDown or _3rdParty_MouseLock then exit;
  try
    FInMouseDown := TRUE;

    if not FMemo.HasData then
    begin
      inherited MouseDown(Button, Shift, X, Y);
      exit;
    end;

    FCurrentWindowMouseX := X;
    FCurrentWindowMouseY := Y;
    FLastMouseWasDrag := False;
    FCurrentMouseButton := Button;

    CalcMousePageAtXY(X, Y);
    oldobj := FTextObjectUnderMouse;
    FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
      par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement);

    FMouseNoParFound := par = nil;

    if (FTextObjectUnderMouse <> nil) and assigned(FOnTextObjectMouseDown) then
    begin
      // Images only!
      if FMemo.ObjectWindowRect(FTextObjectUnderMouse, ox, oy, ow, oh, FMousePage) then
        FOnTextObjectMouseDown(Self, FTextObjectUnderMouse,
          FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X - ox, Y - oy)
      else FOnTextObjectMouseDown(Self, FTextObjectUnderMouse,
          FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X, Y);

      if (Screen.Cursor <> Cursor) and FIgnoreMouse then
      begin
        Screen.Cursor := crDefault;
        FNeedToResetCursor := FALSE;
      end;
      if FIgnoreMouse then exit;
    end;

    FMouseClickFrameBorder := FrameBorder;
    // If we change the cursor to a sizing cursor we might loose the sizer element!
    if FTextObjectSizing and (oldobj <> nil) then
    begin
      FTextObjectUnderMouse := oldobj;
      SizerElement := FTextObjectSizingMode;
    end;

    // Shortcut to open GraphiMenu - suppress inherited MouseDown!
    if (wpDontTriggerPopupInContextEvent in EditOptionsEx) and
      (Button = mbRight) and
      (FGraphicPopupMenu <> nil) and (FTextObjectUnderMouse <> nil) and
      (FTextObjectUnderMouse.ObjRef <> nil) and
      (FTextObjectUnderMouse.ObjType = wpobjImage) then
    begin
      p := ClientToScreen(Point(FCurrentWindowMouseX, FCurrentWindowMouseY));
      FGraphicPopupMenu.Popup(p.x, p.y);
    end
    else //!!
      inherited MouseDown(Button, Shift, X, Y);

    if (wpDontTriggerPopupInContextEvent in EditOptionsEx) and
      (FTextObjectUnderMouse = nil) and //V5.14
      (par <> nil) and not par.IsCharObject(pos_in_par) //V5.14
      then
    begin
      if not DoMouseDownWord(par, pos_in_par, Button, Shift,
        FCurrentWindowMouseX,
        FCurrentWindowMouseY) then
      begin
       //  FDisableSelection := TRUE;
        exit;
      end;
    end;

    FMemo.RTFData.NewUndolevel;
    if not Focused and Enabled then SetFocus;

    if not FIgnoreMouse then // and not Readonly then
    begin
      if (FMouseSizeLine <> []) and not Readonly then
      begin
        FMouseSizeStartX := FCurrentWindowMouseX;
        // FMouseSizeStartY := FCurrentWindowMouseY;
        FMouseSizeing := TRUE;

        FMouseSizeMinX := 0;
        FMouseSizeMaxX := MaxInt;

        if (wpLineLeft in FMouseSizeLine) and
          (wpIsTableBorder in FMouseSizeLine) and
          (FMouseSizePar <> nil) then
        begin
          par2 := FMouseSizePar.ParentTable;
          if par2 <> nil then
          begin
            val := par2.AGetDef(WPAT_BoxWidth, par2._IsWidthTw);
            val2 := par2.AGetDef(WPAT_BoxMarginLeft, 0) +
              Header.LeftMargin;
            if not (wpIsTableBorder in FMouseSizeLine) then
            begin
              FMouseSizeMinX := FMouseSizeStartX -
                Round(val2 * Screen.PixelsPerInch * FMemo.CurrentZooming / 1440);
              FMouseSizeMaxX := FMouseSizeStartX +
                Round((Header.PageWidth - val - val2) * Screen.PixelsPerInch * FMemo.CurrentZooming / 1440);
            end;
          end;
        end else
          if (wpLineRight in FMouseSizeLine) and (FMouseSizePar <> nil) then
          begin
            par2 := FMouseSizePar.ParentTable;
            if wpIsTableBorder in FMouseSizeLine then
            begin
              val := par2.AGetDef(WPAT_BoxWidth, par2._IsWidthTw);
              val := Header.PageWidth -
                (val + par2.AGetDef(WPAT_BoxMarginLeft, 0) +
                Header.LeftMargin);
            end else
              val := FMouseSizePar.NextPar.AGetDef(WPAT_COLWIDTH,
                FMouseSizePar.NextPar._IsWidthTw) - 1440 div 8;
            val2 := FMouseSizePar.AGetDef(WPAT_COLWIDTH, FMouseSizePar._IsWidthTw);
            if not (wpIsTableBorder in FMouseSizeLine) then
            begin
              FMouseSizeMaxX := FMouseSizeStartX +
                Round(val * Screen.PixelsPerInch * FMemo.CurrentZooming / 1440);
              FMouseSizeMinX := FMouseSizeStartX -
                Round((val2 - 1440 div 8) * Screen.PixelsPerInch * FMemo.CurrentZooming / 1440);
            end;
          end;


      end; //NOT: ELSE

      if (MousePage < 0) and
        (LayoutMode in [wplayNormal, wpWordWrapView, wplayShowManualPageBreaks]) then
      begin
        if Y > Round((FMemo.PaintPagesHeight - FMemo.TopOffset) * FMemo.CurrentZooming) then
          CPPosition := MaxInt;
      end else
      // if MousePage >= 0 then
      begin
        if FTextObjectUnderMouse <> nil then
        begin
          if FTextObjectUnderMouse.ObjType = wpObjImage then
          begin
            Ignore := not (wpObjectSelecting in EditOptions); //V5.19.2
            if assigned(FBeforeObjectSelection) then
              FBeforeObjectSelection(Self,
                FTextObjectUnderMouse, Ignore);
            if not Ignore then
            begin
              if FNeedToResetCursor then
              begin
                Screen.Cursor := crDefault;
                FNeedToResetCursor := FALSE;
              end;
              Ignore := FALSE;
              if assigned(FBeforeObjectSelection) then
                FBeforeObjectSelection(Self,
                  FTextObjectUnderMouse, Ignore);
              if not Ignore then
              begin
                if FTextObjectUnderMouse.ObjRef <> nil then
                begin
                  FTextObjectUnderMouse.ObjRef._AllowFrame := FALSE;
                  FTextObjectUnderMouse.ObjRef.Select(true);
                end;
                //V5.18.1 - we allow the selection of objects without TWPObject!
                if (FTextObjectUnderMouse.ObjRef = nil) or
                  FTextObjectUnderMouse.ObjRef._AllowFrame then
                begin
                  FMemo.Cursor.MoveTo(
                    FTextObjectUnderMouse.ParentPar,
                    FTextObjectUnderMouse.ParentPosInPar);
                  TextCursor.SelectedObject := FTextObjectUnderMouse;
                  FLastSelectionChange := GetTickCount + 300;
                  if assigned(FAfterObjectSelection) then
                    FAfterObjectSelection(Self, FTextObjectUnderMouse);
                  RePaint;
                end;
              end;
            end;
          end // if (FTextObjectUnderMouse.ObjRef...  else
          else
          begin
            if FMemo.Cursor.MoveTo(
              FTextObjectUnderMouse.ParentPar,
              FTextObjectUnderMouse.ParentPosInPar) then
              FMemo.Cursor.GetCharAttr;
            Ignore := not (wpTextObjectSelecting in EditOptionsEx);
            if assigned(FBeforeObjectSelection) then
              FBeforeObjectSelection(Self,
                FTextObjectUnderMouse, Ignore);
            if not Ignore then
            begin
              TextCursor.SelectedObject := FTextObjectUnderMouse;
              if assigned(FAfterObjectSelection) then
                FAfterObjectSelection(Self, FTextObjectUnderMouse);
              if assigned(FOnChangeSelection) then
                FOnChangeSelection(Self);
              FLastSelectionChange := GetTickCount + 300;
              RePaint;
            end;
          end;
          // FDisableSelection := TRUE;   //replaced in V5.12.1 by
          FDisableSelection := (FTextObjectUnderMouse <> nil) and
            (FTextObjectUnderMouse.ObjType = wpobjImage);
        end
        else
        begin
          if TextCursor.SelectedObject <> nil then
          begin
            TextCursor.SelectedObject := nil;
            RePaint;
          end;
          if not FDisableSelection then
          begin
            if (ssShift in Shift) and (Button = mbLeft) then
            begin
              FMemo.Cursor.SelectText := TRUE;
              FLastMouseWasDrag := TRUE;
            end else
              if (GetTickCount > FLastSelectionChange) and
                ((FMouseClickFrameBorder * [wpClickLeftMargin, wpClickRightMargin]) = [])
                then
                FMemo.Cursor.SelectText := FALSE;
          end;
          if FMemo.MoveCursor(MousePage, MouseX, MouseY,
            DontAllowLeaveRTFDataBlock
            ) then
          begin
            if TextCursor.Moved then
            begin
              FCaret.UpdatePos;
              AddHistoryChar(#0);
            end;
          end;
        end;
      end;
    end;
    FMemo._FMouseDown := Button = mbLeft;
    if FMemo._FMouseDown and not (wpNoAutoScroll in EditOptions) then
      MouseCapture := TRUE; // For Autoscroll
  finally
    FInMouseDown := FALSE;
  end;
end;

procedure TWPCustomRtfEdit.DragOver(Source: TObject; X, Y: Integer; State: TDragState;
  var Accept: Boolean);
var
  aRTFData: TWPRTFDataBlock;
  pos_in_par: Integer;
  FrameBorder: TWPFrameBorder;
  SizerElement: TWPPaintSizerRects;
  par: TParagraph;
begin
  if not Readonly and
    not (wpcoNoInternalDragAndDrop in FClipboardOptions) and
    (not (wpcoNoDragAndDropFromOutside in FClipboardOptions)
    or (Source = Self)) then
  begin
    Accept := Source is TWPCustomRtfEdit;

    if Accept and not (wpAllowDrawDropBetweenTextBlocks in EditOptionsEx) then
    begin
      CalcMousePageAtXY(X, Y);
      FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
        par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement,
        true, []);
      FMouseNoParFound := par = nil;
      if aRTFData <> ActiveText then Accept := FALSE;

      if not (wpNoAutoScroll in EditOptions) then // AUTOSCROLL!!!   - V5.19.6
      begin
        if x < 2 then begin StartUpdate(WPUPD_SCROLL_LE); exit; end
        else if x > Width - 4 then begin StartUpdate(WPUPD_SCROLL_RI); exit; end
        else if y < 2 then begin StartUpdate(WPUPD_SCROLL_UP); exit; end
        else if y > Height - 4 then begin StartUpdate(WPUPD_SCROLL_DN); exit; end;
      end;
    end;

    if Accept and not (wpcoDontMoveCursorDuringDrag in FClipboardOptions)
      then
    begin
      if not CPMoveTo(X, Y, Source = Self) or
        (FMemo.IsProtected(ActiveParagraph, ActivePosInPar, true) <> [])
        then
        Accept := FALSE; //V5.13.5
    end;
  end
  else Accept := FALSE;
  if not Accept then
    inherited DragOver(Source, X, Y, State, Accept);
end;

procedure TWPCustomRtfEdit.DoEndDrag(Target: TObject; X, Y: Integer);
begin
  inherited DoEndDrag(Target, X, Y);
  FMemo.Cursor.LockSelection := FALSE;
  FLastMouseWasDrag := FALSE;
end;

procedure TWPCustomRtfEdit.DragDrop(Source: TObject; X, Y: Integer);
var s: string;
  sel: TWPSelectionContents;
  spar, epar, par, tabpar: TParagraph;
  spos, epos, pos: Integer;
  Abort, MoveLater: Boolean;
  aRTFData: TWPRTFDataBlock;
  pos_in_par: Integer;
  FrameBorder: TWPFrameBorder;
  SizerElement: TWPPaintSizerRects;
begin
  SaveChanging;
  inherited DragDrop(Source, X, Y);

  if FIgnoreNextVCLDrop then
  begin
    FIgnoreNextVCLDrop := FALSE;
    exit;
  end;

  if (Source is TWPCustomRtfEdit) and
    not FReadonly and
    not (wpcoNoInternalDragAndDrop in FClipboardOptions) and
    (not (wpcoNoDragAndDropFromOutside in FClipboardOptions)
    or (Source = Self))
    then
  begin
    CalcMousePageAtXY(X, Y);

    if wpAllowDrawDropBetweenTextBlocks in EditOptionsEx then
      FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
        par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement,
        true, [wpRTFData_HasPriority])
    else
      FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
        par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement,
        true, []);
    FMouseNoParFound := par = nil;

    if not (wpAllowDrawDropBetweenTextBlocks in EditOptionsEx) and
      (aRTFData <> ActiveText) then exit;

    if (Source = Self) and (aRTFData <> nil)
      and (aRTFData <> ActiveText)
      and not aRTFData.Readonly then
      MoveLater := TRUE
    else MoveLater := FALSE;

    if assigned(FBeforeDropText) then
    begin
      Abort := FALSE;
      FBeforeDropText(Self, X, Y, par, pos_in_par, TWPCustomRtfEdit(Source), Abort);
      if Abort then exit;
    end;

    if not MoveLater and (MousePage >= 0) and FMemo.MoveCursor(MousePage, MouseX, MouseY,
      DontAllowLeaveRTFDataBlock) then
    begin
     // if wpLineSmallerThanX in FrameBorder then
     //      TextCursor.
      FCaret.UpdatePos;
      AddHistoryChar(#0);
    end;

    if not MoveLater and not (wpcoNoAutoSelSpaceExtension in FClipboardOptions) then
    begin
      spar := TWPCustomRtfEdit(Source).TextCursor.GetBlockStart(spos);
      epar := TWPCustomRtfEdit(Source).TextCursor.GetBlockEnd(epos);

      if (spar <> nil) and (epar <> nil) then
      begin
        if spar.IsSpace(spos - 1) and not spar.IsSpace(spos)
          and not epar.IsSpace(epos - 1) and epar.IsSpace(epos) then
        begin
          if not ActiveParagraph.IsSpace(ActivePosInPar) and
            ActiveParagraph.IsSpace(ActivePosInPar - 1)
            then
            TWPCustomRtfEdit(Source).TextCursor.SelectionExtend(1)
          else if ActiveParagraph.IsSpace(ActivePosInPar) and
            not ActiveParagraph.IsSpace(ActivePosInPar - 1) then
            TWPCustomRtfEdit(Source).TextCursor.SelectionShiftStart(-1);
        end;
      end else exit;
    end;

    if not MoveLater and (FMemo.IsProtected(ActiveParagraph, ActivePosInPar, true) <> []) then
      exit; //V5.13.5

    if not MoveLater and (Source = Self) and
      FMemo.Cursor.IsTextSelected(FMemo.Cursor.active_paragraph,
      FMemo.Cursor.active_posinpar)
      then
      TextCursor.LockSelection := FALSE // Abort!
    else
    begin
      sel := FMemo.Cursor.SelectionContents; //
{$IFDEF ALLOWUNDO}
      if MoveLater or (wpSelTableCells in sel) then // or (wpSelCompleteTable in sel) then
        Memo.RTFData.UndoStreamStart(wputDragAndDrop)
      else Memo.RTFData.NewUndolevel;
{$ENDIF}
      try
        s := TWPCustomRtfEdit(Source).AsANSIString('WPTOOLS', true); //V5.13.5 was: 'RTF'

        if ((wpcoAlwaysDeleteInDragSource in FClipboardOptions) or (Source = Self))
          and (TextCursor.block_s_par <> nil) then
        begin
          tabpar := TextCursor.block_s_par.ParentTable;
          if (wpSelCompleteTable in sel) and (tabpar <> nil) then
          begin
            HideSelection;
            tabpar.DeleteParagraph;
          end
          else TWPCustomRtfEdit(Source).ClearSelection;
        end else HideSelection;

        if MoveLater then
        begin
          ActiveText := aRTFData;

          if not FMemo.MoveCursor(MousePage, MouseX, MouseY, true) then
          begin
            Undo;
            exit;
          end;
        end;
        par := ActiveParagraph;
        pos := ActivePosInPar;
        SelectionAsString := s;
        if par.Cell <> nil then
        begin

        end;
        if Source = Self then
        begin
          TextCursor.LockSelection := FALSE;
          TextCursor.SelectFromHere(par, pos);
          TextCursor.SelectToHere(ActiveParagraph, ActivePosInPar);
        end;

      finally
{$IFDEF ALLOWUNDO}
        if MoveLater or (wpSelTableCells in sel) then
          Memo.RTFData.UndoStreamEnd
{$ENDIF}
      end;
      ChangeApplied;
      ReformatAll(false, true);
    end;
  end;
end;

procedure TWPCustomRtfEdit.DoStartDrag(var DragObject: TDragObject);
begin
  inherited DoStartDrag(DragObject);
end;

//#: procedure TWPCustomRtfEdit.MouseMove

procedure TWPCustomRtfEdit.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par: Integer;
  FrameBorder: TWPFrameBorder;
  FoundLine: Boolean;
  StartPar, EndPar: TParagraph;
  StartPosInPar, EndPosInPar: Integer;
  codeobj, TextObject: TWPTextObj;
  ox, oy, ow, oh, a, b: Integer;
  sel: TWPSelectionContents;
  SizerElement: TWPPaintSizerRects;
  ca: TWPCharAttr;
begin
  if FInMouseDown or _3rdParty_MouseLock then exit;
  if (FLastMouseWasDrag or FMemo._FMouseDown) and not (wpNoAutoScroll in EditOptions)
    and not FTextObjectSizing //V5.19.4
    then // AUTOSCROLL!!!
  begin
    if x < 0 then begin StartUpdate(WPUPD_SCROLL_LE); FAutoScrollActive := TRUE; exit; end
    else if x > Width then begin StartUpdate(WPUPD_SCROLL_RI); FAutoScrollActive := TRUE; exit; end
    else if y < 0 then begin StartUpdate(WPUPD_SCROLL_UP); FAutoScrollActive := TRUE; exit; end
    else if y > Height then begin FAutoScrollActive := TRUE; StartUpdate(WPUPD_SCROLL_DN); exit; end
    else if x < 2 then begin StartUpdate(WPUPD_SCROLL_LE); exit; end
    else if x > Width - 2 then begin StartUpdate(WPUPD_SCROLL_RI); exit; end
    else if y < 2 then begin StartUpdate(WPUPD_SCROLL_UP); exit; end
    else if y > Height - 2 then begin StartUpdate(WPUPD_SCROLL_DN); exit; end;
  end;
  FAutoScrollActive := FALSE;
  FAutoScrollSpeed := 100;

  TextCursor._DontCallShowCursor := TRUE;
  try
    if not FMemo.HasData then
    begin
      inherited MouseMove(Shift, X, Y);
      exit;
    end;
    CalcMousePageAtXY(X, Y);

{$IFDEF AUTOSWITCH_BEAMCURSOR}
    if not (LayoutMode in [wplayNormal, wpWordWrapView, wplayShowManualPageBreaks]) and
      (Screen.Cursor = crDefault) then
    begin
      if (Cursor = crIBeam) and (FMousePage < 0) then
        Screen.Cursor := crArrow
      else Screen.Cursor := crDefault;
    end;
{$ENDIF}

    if not FMemo._FMouseDown then
    begin
      FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
        par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement);
      FMouseNoParFound := par = nil;
  (*  if wpIsTableBorder in FrameBorder then
    begin
   //   resize table
        {$IFDEF DONTSETSIZERCURSOR}
          Screen.Cursor := crDefault;
        {$ELSE}
          Screen.Cursor := WPImageSizeMoveCursors[wpSiz_ML];
        {$ENDIF}
          FTableSizing := TRUE;
          if wpLineLeft in FrameBorder then FTableSizingMode := wpSiz_ML
          else FTableSizingMode :=  wpSiz_MR;
          FMouseSizePar := par;
    end else  *)
      if FTextObjectUnderMouse <> nil then
      begin
        if assigned(FOnTextObjectMouseMove) then
        begin
          if FMemo.ObjectWindowRect(FTextObjectUnderMouse, ox, oy, ow, oh, FMousePage) then
            FOnTextObjectMouseMove(Self, FTextObjectUnderMouse,
              FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X - ox, Y - oy)
          else FOnTextObjectMouseMove(Self, FTextObjectUnderMouse,
              FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X, Y);
        end;

        if not FIgnoreMouse then
        begin
          if ((wpobjIsSelected in FTextObjectUnderMouse.Mode)
            or (FTextObjectUnderMouse.Width < 36)
            or (FTextObjectUnderMouse.Height < 36)) and
            (SizerElement <> wpSizeNone) then
          begin
{$IFDEF DONTSETSIZERCURSOR}
            Screen.Cursor := crDefault;
{$ELSE}
            Screen.Cursor := WPImageSizeMoveCursors[SizerElement];
{$ENDIF}
            FTextObjectSizing := TRUE;
            FTextObjectSizingMode := SizerElement;
            FNeedToResetCursor := TRUE;
          end
          else
          begin
            Screen.Cursor := FTextObjectCursor;
            FTextObjectSizing := FALSE;
            FNeedToResetCursor := TRUE;
          end;
        end;
      end
      else if not FIgnoreMouse and (par <> nil) then
      begin
       { if FrameBorder=[wpInLineBottomArea] then
        begin
          Screen.Cursor := crCross;
          FNeedToResetCursor := TRUE;
          FMouseSizePar := nil;
          FMouseSelectCell := nil;
        end else }
        if (FrameBorder = [wpLineBottomLeft]) and
          not (wpIgnoreSingleCellSelection in EditOptionsEx) and
          not (wpDisableSelection in EditOptionsEx) then
        begin
          Screen.Cursor := crUpArrow; // SELECT
          FMouseSizeLine := FrameBorder;
          FMouseSizePar := nil;
          FMouseSelectCell := par.Cell;
          FNeedToResetCursor := TRUE;
        end else
          if (FrameBorder * [wpLineRight, wpLineLeft]) <> [] then
          begin
            if wpIsTableBorder in FrameBorder then
              Screen.Cursor := crSizeWE
            else Screen.Cursor := crHSplit;
            FMouseSizeLine := FrameBorder;
            FMouseSizePar := par.Cell;
            FNeedToResetCursor := TRUE;
          end
        // EditOption "wpTableRowResizing" --> wpLineBottom, wpLineTop
          else if (FrameBorder * [{wpLineTop,}wpLineBottom]) <> [] then
          begin
            Screen.Cursor := crVSplit;
            FMouseSizeLine := FrameBorder;
            FMouseSizePar := par.Cell;
            FNeedToResetCursor := TRUE;
          end
          else
          begin
            Screen.Cursor := crDefault;
            FMouseSizeLine := []; //V5.12.1
            FMouseSizePar := nil;
          end;
      end;


      if not FIgnoreMouse and (par <> nil) and not (wpLineSmallerThanX in FrameBorder) then
      begin
{$IFDEF PLAINLINKS}
        if assigned(FOnTestForLinkEvent) and (IsLinkAtParPos(par, pos_in_par) <> '') then
        begin
          Screen.Cursor := FHyperLinkCursor;
          FNeedToResetCursor := TRUE;
          codeobj := nil;
        end else
{$ENDIF}
          codeobj := par.ObjectRef[pos_in_par];
        if (wpTextObjectMoving in EditOptionsEx) and
          not FieldObjectTextAttr.Hidden and
          (FTextObjectUnderMouse <> nil) and
          (codeobj <> nil) and
          (codeobj.ObjType = wpobjTextObject) then
        begin
          // MoveImageObject
          TextObject := FTextObjectUnderMouse;
          FFrameVar.Start(Canvas, TextObject, ox, oy, ow, oh);
          FFrameVar.FObjectOffsetX := ox - X;
          FFrameVar.FObjectOffsetY := oy - Y;
          FDragingObject := TRUE;
          FNeedToResetCursor := TRUE;
        end;

        if (codeobj <> nil) and (codeobj.ObjType = wpobjTextObject)
          and not FieldObjectTextAttr.Hidden
          and (FieldObjectTextAttr.HotStyleIsActive or
          (FieldObjectTextAttr.OnHintEventIsActive and
          Assigned(FOnActivateHint)))
          then
        begin
          if FieldObjectTextAttr.HotStyleIsActive and
            FMemo.SetHOTStyle(par, par, pos_in_par, pos_in_par + 1, 0) then Invalidate;
          if FieldObjectTextAttr.OnHintEventIsActive and
            Assigned(FOnActivateHint) then
            FOnActivateHint(Self, codeobj, par, pos_in_par);
        end else
      { Check merge field objects }
          if (codeobj <> nil) and (codeobj.ObjType = wpobjMergeField)
            and not InsertPointAttr.Hidden
            and (InsertPointAttr.HotStyleIsActive or
            (InsertPointAttr.OnHintEventIsActive and
            Assigned(FOnActivateHint)))
            then
          begin
            if InsertPointAttr.HotStyleIsActive and
              (codeobj.Name <> '__TOC__') and
              FMemo.SetHOTStyle(par, par, pos_in_par, pos_in_par + 1, 0) then Invalidate;
            if InsertPointAttr.OnHintEventIsActive and
              Assigned(FOnActivateHint) then
              FOnActivateHint(Self, codeobj, par, pos_in_par);
          end else
          begin
     { Check Protected and Hidden text hot styles }
            par.GetCharAttrAt(pos_in_par, ca);
            if ProtectedTextAttr.HotStyleIsActive and
              not ProtectedTextAttr.Hidden and
              ((ca.Values[WPAT_CharStyleON] and WPSTY_PROTECTED) <> 0) then
            begin
              a := pos_in_par;
              while a > 0 do
              begin
                par.GetCharAttrAt(a, ca);
                if (ca.Values[WPAT_CharStyleON] and WPSTY_PROTECTED) = 0 then break;
                dec(a);
              end;
              b := pos_in_par;
              while b < par.CharCount do
              begin
                par.GetCharAttrAt(b, ca);
                if (ca.Values[WPAT_CharStyleON] and WPSTY_PROTECTED) = 0 then break;
                inc(b);
              end;

              if FMemo.SetHOTStyle(par, par, a, b, 0) then Invalidate;
            end
            else
              if not HiddenTextAttr.Hidden and
                (HiddenTextAttr.HotStyleIsActive or
                (HiddenTextAttr.OnHintEventIsActive and
                Assigned(FOnActivateHint))) and
                ((ca.Values[WPAT_CharStyleON] and WPSTY_HIDDEN) <> 0) then
              begin
                a := pos_in_par;
                while a > 0 do
                begin
                  par.GetCharAttrAt(a, ca);
                  if (ca.Values[WPAT_CharStyleON] and WPSTY_HIDDEN) = 0 then break;
                  dec(a);
                end;
                b := pos_in_par;
                while b < par.CharCount do
                begin
                  par.GetCharAttrAt(b, ca);
                  if (ca.Values[WPAT_CharStyleON] and WPSTY_HIDDEN) = 0 then break;
                  inc(b);
                end;

                if HiddenTextAttr.HotStyleIsActive and FMemo.SetHOTStyle(par, par, a, b, 0) then Invalidate;
                if HiddenTextAttr.OnHintEventIsActive and
                  Assigned(FOnActivateHint) then
                  FOnActivateHint(Self, nil, par, a);
              end
              else
           { Hyperlinks hotstyles - priority over bookmarks and fields}
              begin
                if par = nil then
                  codeobj := nil
                else
                begin
                  codeobj := TextObjects.LocateInner(par, pos_in_par, [wpobjHyperlink],
                    StartPar, EndPar, StartPosInPar, EndPosInPar);
                end;
                if codeobj <> nil then
                begin
                  if HyperlinkTextAttr.HotStyleIsActive and
                    FMemo.SetHOTStyle(StartPar, EndPar, StartPosInPar, EndPosInPar, 0) then
                  begin
                    Invalidate;
                    Screen.Cursor := FHyperLinkCursor;
                    FNeedToResetCursor := TRUE;
                  end;
                  if HyperlinkTextAttr.OnHintEventIsActive and
                    Assigned(FOnActivateHint) then
                    FOnActivateHint(Self, codeobj, StartPar, StartPosInPar);
                end
                else
                begin // Bookmarked and automatic, merged text
                  codeobj := TextObjects.LocateInner(par, pos_in_par, [wpobjBookmark, wpobjMergeField],
                    StartPar, EndPar, StartPosInPar, EndPosInPar);

                 // NO TEXT SELECTED!
                { if (StartPar=EndPar) and
                    (StartPosInPar+1>EndPosInPar-1) then
                       codeobj := nil;   }

                  if (codeobj <> nil) and (codeobj.ObjType = wpobjMergeField) and not
                    AutomaticTextAttr.Hidden and
                    (AutomaticTextAttr.HotStyleIsActive or
                    (AutomaticTextAttr.OnHintEventIsActive and
                    Assigned(FOnActivateHint)))
                    then
                  begin
                    if AutomaticTextAttr.HotStyleIsActive and (codeobj.Name <> '__TOC__') and FMemo.SetHOTStyle(StartPar, EndPar, StartPosInPar + 1, EndPosInPar, 0) then Invalidate;
                    if AutomaticTextAttr.OnHintEventIsActive and
                      Assigned(FOnActivateHint) then
                      FOnActivateHint(Self, codeobj, StartPar, StartPosInPar + 1);
                  end else
                    if (codeobj <> nil) and (codeobj.ObjType = wpobjBookmark) and not BookmarkTextAttr.Hidden
                      and (BookmarkTextAttr.HotStyleIsActive or
                      (BookmarkTextAttr.OnHintEventIsActive and
                      Assigned(FOnActivateHint))) then
                    begin
                      if BookmarkTextAttr.HotStyleIsActive and FMemo.SetHOTStyle(StartPar, EndPar, StartPosInPar + 1, EndPosInPar, 0) then Invalidate;
                      if BookmarkTextAttr.OnHintEventIsActive and
                        Assigned(FOnActivateHint) then
                        FOnActivateHint(Self, codeobj, StartPar, StartPosInPar + 1);
                    end else
                    begin
                      if FMemo.SetHOTStyle(nil, nil, 0, 0, 0) then Invalidate;
                    end;
                end;
              end;
          end;
      end //if not FIgnoreMouse then
      else if FMemo.SetHOTStyle(nil, nil, 0, 0, 0) then Invalidate;

    end else if not FIgnoreMouse then // If MouseDown
    begin
      if FFrameVar.Active then
      begin
        if FTextObjectSizing then
        begin
          FFrameVar.Size(
            x - FCurrentWindowMouseX,
            y - FCurrentWindowMouseY,
            FCurrentWindowMouseX,
            FCurrentWindowMouseY,
            FTextObjectSizingMode
            );
          FLastMovedObject := FTextObjectUnderMouse;
        end
        else if wpObjectMoving in EditOptions then
        begin
          FFrameVar.Move(
            x - FCurrentWindowMouseX,
            y - FCurrentWindowMouseY,
            FCurrentWindowMouseX,
            FCurrentWindowMouseY
            );
          FLastMovedObject := FTextObjectUnderMouse;
        end;
      end else
        if FTableSizing and (FMouseSizePar <> nil) and (FMouseSizePar.ParagraphType = wpIsTable) then
        begin
        // Resize Table
          if SaveChanging then
            FMemo.FrameLine(wpVertFrameLine, x);
          osize_x := x;
        end else
          if (FMouseSizeing) and (FMouseSizePar <> nil) and (paprIsTable in FMouseSizePar.prop) then
          begin
            if (x < FMouseSizeMinX) or (x > FMouseSizeMaxX) then
            begin
            // --- wrong value !!
            end else
        // Resize Cell
              if FMouseSizeLine * [wpLineRight, wpLineLeft] <> [] then
              begin
                FMemo.FrameLine(wpVertFrameLine, x);
              end
              else if FMouseSizeLine * [wpLineTop, wpLineBottom] <> [] then
              begin
                FMemo.FrameLine(wpHorzFrameLine, y);
              end
          end else
            if FMemo._FMouseDown and
              not FLastMouseWasDrag and
              ((Abs(x - FCurrentWindowMouseX) > 2) or
              (Abs(y - FCurrentWindowMouseY) > 2)) then
            begin
              FoundLine := FMemo.GetRTFPositionAtXY(
                MousePage, MouseX, MouseY, aRTFData, par,
                pos_in_par, FrameBorder, TextObject, SizerElement);
              // MoveImageObject
              if (TextObject <> nil) and (TextObject = FTextObjectUnderMouse) then
              begin
                if FMemo.ObjectWindowRect(TextObject, ox, oy, ow, oh, FMousePage) and
                  (wpObjectMoving in EditOptions) then
                begin
                  FFrameVar.Start(Canvas, TextObject, ox, oy, ow, oh);
                  FFrameVar.FObjectOffsetX := ox - X;
                  FFrameVar.FObjectOffsetY := oy - Y;
                  FDragingObject := TRUE;
                  FNeedToResetCursor := TRUE;
                  if FTextObjectSizing then
                  begin
{$IFDEF DONTSETSIZERCURSOR}
                    Screen.Cursor := crDefault;
{$ELSE}
                    Screen.Cursor := WPImageSizeMoveCursors[FTextObjectSizingMode];
{$ENDIF}
                  end
                  else Screen.Cursor := crMultiDrag;
                end;
              end else if not (wpDisableSelection in EditoptionsEx) then
              begin
                if FoundLine and FMemo.Cursor.IsTextSelected(par, pos_in_par) then
                begin
                  sel := FMemo.Cursor.SelectionContents;
                  if (not (wpSelTableCells in sel) or (wpSelCompleteTable in sel))
                    and (GetTickCount > FLastSelectionChange)
                    then
                  begin
                    FMemo.Cursor.LockSelection := TRUE;
                    FLastMouseWasDrag := TRUE;
                    BeginDrag(true);
                  end;
                end else
                  FMemo.Cursor.SelectText := TRUE;
                FLastMouseWasDrag := TRUE;
              end;
            end else
            begin
              FMouseSizeLine := [];
              FMouseSizePar := nil;
            end;
    end;
    inherited MouseMove(Shift, X, Y);
    if not FIgnoreMouse then
    begin
      if FMemo._FMouseDown and not (wpDisableSelection in EditOptionsEx)
        and not _FAfterTextObjectClick then
      begin
        if FDisableSelection and FMemo.Cursor.SelectText then
          FMemo.Cursor.SelectText := FALSE;
        if MousePage >= 0 then
        begin
       //R6.5 - better selection over page borders
          if FMemo.MoveCursor(MousePage, MouseX, MouseY,
            DontAllowLeaveRTFDataBlock) then
          begin
            if TextCursor.Moved then
            begin
              FCaret.UpdatePos;
              AddHistoryChar(#0);
            end;
          end else
            if (MouseMarginArea in [wpAfterTextBody, wpBottomMargin]) and not TextCursor.block_reverse
              and (TextCursor.block_e_par <> nil) then
            begin
              if TextCursor.MoveTo(
                TextCursor.block_e_par,
                TextCursor.block_e_par.PosOfCP(TextCursor.block_e_posinpar, MaxInt)
                ) then FCaret.UpdatePos;
            end else
              if (MouseMarginArea in [wpTopMargin]) and TextCursor.block_reverse and
                (TextCursor.block_e_par <> nil) then
              begin
                if TextCursor.MoveTo(
                  TextCursor.block_e_par,
                  TextCursor.block_e_par.PosOfCP(TextCursor.block_e_posinpar, 0)
                  ) then FCaret.UpdatePos;
              end;
        end;
      // Protect our selection for 300 mms
        if FMemo.Cursor.SelectText then
          FLastSelectionChange := GetTickCount + 300;
      end;
    end;
  finally
    TextCursor._DontCallShowCursor := FALSE;
  end;
end;

{$IFDEF PLAINLINKS}

function TWPCustomRtfEdit.IsLinkAtParPos(par: TParagraph; pos_in_par: Integer): string;
var ah, eh: Integer; IsLink: Boolean;
begin
  if assigned(FOnTestForLinkEvent) and (par <> nil) then
  begin
    Result := '';
    ah := pos_in_par;
    eh := pos_in_par;
    while (ah > 0) and not par.IsSpace(ah) do dec(ah);
    while not par.IsSpace(eh) do inc(eh);
    if eh > ah then
    begin
      IsLink := FALSE;
      if par.IsSpace(ah) then inc(ah);
      eh := eh - ah;
      FOnTestForLinkEvent(Self, par, ah, eh, IsLink);
      if IsLink then
        Result := par.GetSubText(ah, eh)
      else Result := '';
    end;
  end;
end;
{$ENDIF}

procedure TWPCustomRtfEdit.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var diff, val: Integer;
  RtfX, RtfY, RtfX1, RtfY1, RTFPageNr: Integer;
  ox, oy, ow, oh, new_h, new_w: Integer;
  aRTFData: TWPRTFDataBlock;
  par, par2: TParagraph;
  pos_in_par: Integer;
  OffP: TPoint;
  bCurrDisableSelection: Boolean;
  openObj, MoveThisObject: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
  scx, scy, scw, sch, org_y: Integer;
  FrameBorder: TWPFrameBorder;
begin
  org_y := y;
  FCurrentWindowMouseX := X;
  FCurrentWindowMouseY := Y;
  FLastMouseWasDrag := False;
  FCurrentMouseButton := Button;
  CalcMousePageAtXY(X, Y);
  FMemo.GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
    par, pos_in_par, FrameBorder, FTextObjectUnderMouse, SizerElement);
  FMouseNoParFound := par = nil;
 (* if (wpTriggerPopupInMouseUp in EditOptionsEx) then
  begin
    if (Button = mbRight) and
      (FGraphicPopupMenu <> nil) and (FTextObjectUnderMouse <> nil) and
      (FTextObjectUnderMouse.ObjRef <> nil) and
      (FTextObjectUnderMouse.ObjType = wpobjImage) then
    begin
      p := ClientToScreen(Point(FCurrentWindowMouseX, FCurrentWindowMouseY));
      FGraphicPopupMenu.Popup(p.x, p.y);
    end
    else
    begin
      if (FTextObjectUnderMouse = nil) and //V5.14
         (par <> nil) and not par.IsCharObject(pos_in_par) //V5.14
      then
      begin
        if not DoMouseDownWord(par, pos_in_par, Button, Shift,
          FCurrentWindowMouseX,  FCurrentWindowMouseY) then exit;
      end;
      inherited MouseUp(Button, Shift, X, Y);
    end;
  end else *)
  if FInMouseDown or _3rdParty_MouseLock then
  begin
    inherited MouseUp(Button, Shift, X, Y);
    exit;
  end;

  if FMemo._FMouseDown and not (wpNoAutoScroll in EditOptions) and not FTextObjectSizing
    then MouseCapture := FALSE;
  bCurrDisableSelection := FDisableSelection;
  FDisableSelection := FALSE;
  if not FMemo.HasData then
  begin
    inherited MouseUp(Button, Shift, X, Y);
    exit;
  end;
  if _FAfterTextObjectClick then
  begin
    _FAfterTextObjectClick := FALSE;
    exit;
  end;
  if FTableSizing and (FMouseSizePar <> nil) and (FMouseSizePar.ParagraphType = wpIsTable) and SaveChanging then
  begin
    new_w := MulDiv(x - osize_x, 1440, Screen.PixelsPerInch);
    FMouseSizePar.ASet(WPAT_BoxMarginLeft, new_w);
    if ssCtrl in Shift then FMouseSizePar.FixAllRightCellWidths(true, 0, wpAlwaysColWidthPC in EditOptionsEx);
    DelayedReformat;
  end;
  if Assigned(FOnClickHotText) and (par <> nil) then
  begin
    openObj := OpenCodes(par, pos_in_par, nil, FClickableCodes, 1);
    if openObj <> nil then
    begin
      FOnClickHotText(Self, par, pos_in_par, X, Y, Button, Shift, openObj);
    end;
  end;

  if (FTextObjectUnderMouse <> nil) and
    assigned(FOnTextObjectMouseUp) then
  begin
    if FMemo.ObjectWindowRect(FTextObjectUnderMouse, ox, oy, ow, oh, FMousePage) then
      FOnTextObjectMouseUp(Self, FTextObjectUnderMouse,
        FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X - ox, Y - oy)
    else FOnTextObjectMouseUp(Self, FTextObjectUnderMouse,
        FTextObjectUnderMouse.ObjRef, FCurrentMouseButton, Shift, X, Y);
  end;

  if FNeedToResetCursor or FFrameVar.Active then
  begin
    Screen.Cursor := crDefault;
    FNeedToResetCursor := FALSE;

    if (FMouseSizeLine = [wpLineBottomLeft]) and
      (FMouseSelectCell <> nil) then
    begin
      // NO!!! HideSelection;
      SelectCell(FMouseSelectCell, ssCtrl in Shift);
    end;

    if FFrameVar.Active then
    try
      StartUndolevel;
      if (FFrameVar.WorkObj <> nil) and (FFrameVar.WorkObj is TWPTextObj) then
      begin
        // Character Objects
        if TWPTextObj(FFrameVar.WorkObj).PositionMode = wpotChar then
        begin
          if FTextObjectSizing and SaveChanging then
          begin
            ow := TWPTextObj(FFrameVar.WorkObj).Width;

            new_w := Round(FFrameVar.w * 1440 / WPScreenPixelsPerInch / FMemo.CurrentZooming);

            if (ow <> 0) and
              (FTextObjectSizingMode in [wpSiz_TL, wpSiz_TR, wpSiz_BR, wpSiz_BL])
              then new_h := Round(new_w *
                TWPTextObj(FFrameVar.WorkObj).Height / ow)
            else new_h := Round(FFrameVar.h * 1440 / WPScreenPixelsPerInch / FMemo.CurrentZooming);

            TextObjects.TextObjectBounds(TWPTextObj(FFrameVar.WorkObj),
              new_w, new_h);
            FFrameVar.Active := FALSE;
            FMemo.ReformatAll;
            ChangeApplied;
            RePaint;
          end else
            if FMemo.Cursor.active_paragraph.ParagraphType = wpIsStdPar then
            begin
              MoveThisObject := TWPTextObj(FFrameVar.WorkObj);
              if SaveChanging and TextObjects.MoveCharObjectTo(
                MoveThisObject,
                FMemo.Cursor.active_paragraph,
                FMemo.Cursor.active_posinpar) then
              begin
                FFrameVar.Active := FALSE;
                FMemo.ReformatAll;
                FMemo.Cursor.SelectedObject := MoveThisObject;
              // SelectFromHere(FMemo.Cursor.active_paragraph,FMemo.Cursor.active_posinpar);
              // FMemo.Cursor.SelectToHere(FMemo.Cursor.active_paragraph,FMemo.Cursor.active_posinpar+1);
                RePaint;
                ChangeApplied;
              end;
            end;
        end else
      // Page or PAR objects
        begin
          if ScreenToRTFPage(FFrameVar.fx,
            FFrameVar.fy, RtfX, RtfY, RTFPageNr, TRUE) and SaveChanging then
          begin

            if not ScreenToRTFPage(FFrameVar.fx + FFrameVar.fw, // IGNORE X, V5-11.2 moved here with IF
              FFrameVar.fy
{$IFNDEF AllowTallObjects} + FFrameVar.fh{$ENDIF},
              RtfX1, RtfY1, RTFPageNr, TRUE) then
            begin
              RtfX1 := RtfX + MulDiv(FFrameVar.fw, Memo.CurrentXPixelsPerInch, WPScreenPixelsPerInch);
              RtfY1 := RtfY + MulDiv(FFrameVar.fh, Memo.CurrentYPixelsPerInch, WPScreenPixelsPerInch);
            end;

            if (TWPTextObj(FFrameVar.WorkObj).ParentPar.RTFData.Kind <> wpIsBody) and
              FMemo.RTFDataOffset(RTFPageNr, TWPTextObj(FFrameVar.WorkObj).ParentPar.RTFData, OffP, false) then
            begin
              dec(RtfY, OffP.y);
              dec(RtfX, OffP.x);
              dec(RtfY1, OffP.y);
              dec(RtfX1, OffP.x);
            end;
            if FTextObjectSizing then
            begin
              ow := TWPTextObj(FFrameVar.WorkObj).Width;
              new_w :=
                MulDiv(RtfX1 - RtfX, 1440, FMemo.CurrentXPixelsPerInch);
              if (ow <> 0) and
                (FTextObjectSizingMode in [wpSiz_TL, wpSiz_TR, wpSiz_BR, wpSiz_BL])
                then new_h := Round(new_w * TWPTextObj(FFrameVar.WorkObj).Height / ow)
              else new_h := MulDiv(RtfY1 - RtfY, 1440, FMemo.CurrentYPixelsPerInch);

              TextObjects.TextObjectBounds(TWPTextObj(FFrameVar.WorkObj), new_w, new_h);
            end;

            // No auto positioning
            TWPTextObj(FFrameVar.WorkObj).Mode := TWPTextObj(FFrameVar.WorkObj).Mode -
              [wpobjPositionAtCenter, wpobjPositionAtRight];

            TextObjects.MoveParObjectTo(
              TWPTextObj(FFrameVar.WorkObj),
              nil, RTFPageNr, RtfX, RtfY);
            FFrameVar.Active := FALSE;
            FMemo.ReformatAll;
            RePaint;
            ChangeApplied;
          end;
        end;
      end;
    finally
      EndUndolevel;
      FTextObjectUnderMouse := nil;
      FFrameVar.Active := FALSE;
    end;
    (* ---------- Drag&Drop only in event DragDrop !!!
    else if not Readonly and FLastMouseWasDrag and not
      bCurrDisableSelection and IsSelected
      and (GetTickCount > FLastSelectionChange) then
    begin
      sel := FMemo.Cursor.SelectionContents; //TWPSelectionContents
      if not (wpSelTableCells in sel) then // or (wpSelCompleteTable in sel) then
      begin
      //:# MOUSE --- Drag and Drop
        s := AsANSIString('WPTOOLS', true);
        if s <> '' then
        begin
{$IFDEF ALLOWUNDO}
          if wpActivateUndo in EditOptions then
            StartUndoLevel;
{$ENDIF}
          try
            ClearSelection(true);
            SelectionAsString := s;
            ReformatAll;
            ChangeApplied;
            Invalidate;
          finally
{$IFDEF ALLOWUNDO}
            if wpActivateUndo in EditOptions then
              EndUndoLevel;
{$ENDIF}
          end;
        end;
      end;
    end; *)
  end;
  FIgnoreMouse := FALSE;
  FMouseSelectCell := nil;

  inherited MouseUp(Button, Shift, X, Y);
  FMemo._FMouseDown := FALSE;
  if not Readonly and FMouseSizeing and (FMouseSizePar <> nil) and (FMouseSizeLine <> []) then
  begin
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      Memo.RTFData.RTFProps._UNDO_RTF_DATA := Memo.RTFData;
{$ENDIF}

    if x < FMouseSizeMinX then x := FMouseSizeMinX;
    if x > FMouseSizeMaxX then x := FMouseSizeMaxX;

    if not FMemo.FrameLineWasMoved then
    begin
      FMemo.FrameLine(wpNoFrameLine, y); // use wpDisableFrameLine for avoid repaint
    end
    else
    begin
      FMemo.FrameLine(wpNoFrameLine, y); // use wpDisableFrameLine for avoid repaint
      if (FMouseSizeLine * [wpLineLeft, wpLineRight]) <> [] then
        diff := Round((x - FMouseSizeStartX) / Screen.PixelsPerInch / FMemo.CurrentZooming * 1440)
      else diff := Round((y - FMouseSizeStartY) / Screen.PixelsPerInch / FMemo.CurrentZooming * 1440);

      if (wpLineBottom in FMouseSizeLine) then
      begin
      // val := FMouseSizePar.ParentRow.AGetDef(WPAT_BoxMaxHeight, 0);

        if FMemo.GetTextScreenRect(FMouseSizePar.ParentRow.ColFirst, 0, scx, scy, scw, sch, false)
          and SaveChanging then
        begin
       { Canvas.Pen.Color := clRed;
        Canvas.Pen.Width := 1;
        Canvas.MoveTo(0, scy);
        Canvas.LineTo(Width, scy); }
          diff := Round((org_y - scy) / WPScreenPixelsPerInch / FMemo.CurrentZooming * 1440);
          if (diff > 10) then
          begin
            if (wpfIgnoreMinimumRowheight in HeaderFooter.FormatOptions) and
              not (wpfIgnoreMaximumRowheight in HeaderFooter.FormatOptions) then
            begin
              FMouseSizePar.ParentRow.ADel(WPAT_BoxMinHeight);
              FMouseSizePar.ParentRow.ASet(WPAT_BoxMaxHeight, diff)
            end else
              if not (wpfIgnoreMinimumRowheight in HeaderFooter.FormatOptions) and
                (wpfIgnoreMaximumRowheight in HeaderFooter.FormatOptions) then
              begin
                FMouseSizePar.ParentRow.ASet(WPAT_BoxMinHeight, diff);
                FMouseSizePar.ParentRow.ADel(WPAT_BoxMaxHeight);
              end else
              begin
                FMouseSizePar.ParentRow.ASet(WPAT_BoxMinHeight, diff);
                if ssCtrl in Shift then
                  FMouseSizePar.ParentRow.ASet(WPAT_BoxMaxHeight, diff)
                else FMouseSizePar.ParentRow.ADel(WPAT_BoxMaxHeight);
              end;
          end
          else
          begin
            FMouseSizePar.ParentRow.ADel(WPAT_BoxMinHeight);
            FMouseSizePar.ParentRow.ADel(WPAT_BoxMaxHeight);
          end;
          FMemo.ReformatAll;
          DelayedInvalidate;
          ChangeApplied;
          SetFocusValues(true);
        end;
      end else
        if (wpLineLeft in FMouseSizeLine) and
          (wpIsTableBorder in FMouseSizeLine) and
          (FMouseSizePar <> nil) and SaveChanging then
        begin
          par2 := FMouseSizePar.ParentTable;
          if par2 <> nil then
          begin
            val := par2.AGetDef(WPAT_BoxMarginLeft, 0);
            par2.ASet(WPAT_BoxMarginLeft, val + diff);
            if ssCtrl in Shift then par2.FixAllRightCellWidths(true, 0, wpAlwaysColWidthPC in EditOptionsEx);
            FMemo.ReformatAll;
            RePaint;
            ChangeApplied;
            SetFocusValues(true);
          end;
        end else
          if (wpLineRight in FMouseSizeLine) and (FMouseSizePar <> nil) and SaveChanging then
          begin
      // Assigns the _ActCellWidth to all columns of the table
            par2 := FMouseSizePar.ParentTable;
            if not (wpIsTableBorder in FMouseSizeLine) and (par2 <> nil) then
              par2._FixAllCellWidths;
            if (wpIsTableBorder in FMouseSizeLine) and (par2 <> nil) then
            begin
              val := par2.AGetDef(WPAT_BoxWidth,
                par2._IsWidthTw
                );
              par2.ASet(WPAT_BoxWidth, val + diff);

              par2.FixAllRightCellWidths(ssCtrl in Shift, 0, wpAlwaysColWidthPC in EditOptionsEx);
            end else
            begin
              val := FMouseSizePar._ActCellWidth;
              if val = 0 then val := FMouseSizePar.AGetDef(WPAT_COLWIDTH, 0);
              val := val + diff;

              if val > 0 then
              begin
                FMouseSizePar.ADelColumn(WPAT_COLWIDTH_PC);
                FMouseSizePar.ASetColumn(WPAT_COLWIDTH, val);
              end;

              if FMouseSizePar.NextPar <> nil then
              begin
                val := FMouseSizePar.NextPar.AGetDef(WPAT_COLWIDTH, FMouseSizePar.NextPar._ActCellWidth);
                // if val<=0 then val := FMouseSizePar.NextPar._ActCellWidth;
                // if val = 0 then val := FMouseSizePar.NextPar.AGetDef(WPAT_COLWIDTH, 0);
                val := val - diff;
                if val > 0 then
                begin
                  FMouseSizePar.NextPar.ADelColumn(WPAT_COLWIDTH_PC);
                  FMouseSizePar.NextPar.ASetColumn(WPAT_COLWIDTH, val);
                end;
              end;

              if (wpAlwaysColWidthPC in EditOptionsEx) and (FMouseSizePar.ParentTable <> nil) then
                FMouseSizePar.ParentTable.FixAllRightCellWidths(false, 0, true);
            end;
            FMemo.ReformatAll;
            RePaint;
            ChangeApplied;
            SetFocusValues(true);
          end;
    end; // if FMemo.FrameLineWasMoved
    FMouseSizeing := FALSE;
{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in EditOptions) then
      Memo.RTFData.RTFProps._UNDO_RTF_DATA := nil;
{$ENDIF}
  end else
    if not bCurrDisableSelection and
      not FIgnoreMouse and (Button = mbLeft) and not (wpDisableSelection in EditoptionsEx) then
    begin
      if ssShift in Shift then
      begin
        FMemo.Cursor.SelectToHere(FMemo.Cursor.active_paragraph, FMemo.Cursor.active_posinpar);
      end;
    end;
  FIgnoreMouse := FALSE;
  FMouseSizePar := nil;
  FTextObjectUnderMouse := nil;
  if not (wpDisableSelection in EditoptionsEx) and not bCurrDisableSelection then
    StartUpdate(WPUPD_UPDSELECTION);
end;

{ wee cannot use  'DblClick' since 'Click' is also triggered for DblClicks }

procedure TWPCustomRtfEdit.Click;
var tim: DWord;
  isDblClick, ignore: Boolean;
  obj: TWPTextObj;
begin
  if FLastMouseWasDrag or FInMouseDown or _3rdParty_MouseLock then exit;
  isDblClick := FALSE;


  tim := GetTickCount + 100;
  while (GetTickCount < tim) do ;
  tim := GetTickCount + 100;
  while (GetTickCount < tim) and not isDblClick do
    if GetAsyncKeyState(FVKLeftMouseButton) < 0 then isDblClick := TRUE;

  if not isDblClick and IsSelected and (FTextObjectUnderMouse = nil) and (FMouseSelectCell = nil)
    and ((FMouseClickFrameBorder * [wpClickLeftMargin, wpClickRightMargin]) = [])
    then
  begin
    HideSelection;
    RePaint;
  end;


  if (not isDblClick and assigned(FOnTextObjectClick)) or
    (isDblClick and assigned(FOnTextObjectDblClick)) then
  begin
    if FTextObjectUnderMouse <> nil then obj := FTextObjectUnderMouse
    else if not CodeObjectAtXY(FClientMouseX, FClientMouseY, obj) then obj := nil;
    if (obj <> nil) and not (FLastMovedObject = obj) then
    begin
      ignore := FALSE;
      if isDblClick then
        FOnTextObjectDblClick(Self, obj, obj.ObjRef, ignore)
      else FOnTextObjectClick(Self, obj, obj.ObjRef, ignore);
      if ignore then
      begin
        _FAfterTextObjectClick := TRUE;
        exit;
      end;
    end;
  end;
  FLastMovedObject := nil;

  if isDblClick then DoDblClick(MousePage, FMouseX, FMouseY)
  else if Memo.HasData then
  begin
    if not (wpDisableSelection in EditoptionsEx) and (GetTickCount > FLastSelectionChange)
      and not (SelectedObject <> nil)
      and (FMouseSelectCell = nil)
      then HideSelection;
    if assigned(FOnClickPage) then FOnClickPage(Self, MousePage);
    if FMemo._HasSelectionPaint then
      StartUpdate(WPUPD_REPAINT);
    DoClick(MousePage, FMouseX, FMouseY);
  end;
  if not (wpDisableSelection in EditoptionsEx) then StartUpdate(WPUPD_UPDSELECTION);
end;

procedure TWPCustomRtfEdit.DoHyperlinkEvent(openObj: TWPTextObj);
begin
  if assigned(FHyperLinkEvent) then
    FHyperLinkEvent(Self, openObj.EmbeddedText, openObj.Source, 0);
end;

procedure TWPCustomRtfEdit.DoClick(PageNo, X, Y: Integer);
var Ignore: Boolean;
  openObj: TWPTextObj;
  par: TParagraph;
  posinpar: Integer;
{$IFDEF PLAINLINKS}s: string; {$ENDIF}
begin
  Ignore := FALSE;
  if assigned(FOnClick) then FOnClick(Self, PageNo, X, Y, Ignore);
  if not Ignore and FOneClickHyperlink{$IFNDEF WINCOM} and Assigned(FHyperLinkEvent){$ENDIF} then
  begin
    openObj := CodeInsideOf(FClientMouseX, FClientMouseY, wpobjHyperlink, par, posinpar);
    if openObj <> nil then
    begin
      FHyperlinkObj := openObj;
      DoHyperlinkEvent(openObj);
      Ignore := TRUE;
    end;
    FHyperlinkObj := nil;
{$IFDEF PLAINLINKS}
    if assigned(FOnTestForLinkEvent) then
      if (openObj = nil) and (par <> nil) then
      begin
        s := IsLinkAtParPos(par, posinpar);
        if s <> '' then
        begin
          FHyperLinkEvent(Self, s, s, 0);
          Ignore := TRUE;
        end;
      end;
{$ENDIF}
  end;
  if not Ignore and not Focused then
  begin
    SetFocus;
  end;
end;

procedure TWPCustomRtfEdit.DoDblClick(PageNo, X, Y: Integer);
var
  Ignore: Boolean;
  openObj: TWPTextObj;
  newblock: TWPRTFDataBlock;
  Range: TWPPagePropertyRange;
  par: TParagraph;
  posinpar: Integer;
{$IFDEF PLAINLINKS}s: string; {$ENDIF}
begin
  Ignore := FALSE;
  if assigned(FOnDblClick) then FOnDblClick(Self, PageNo, X, Y, Ignore);
  if not Ignore and not (wpDisableSelection in EditoptionsEx) then
  begin
    //V5.19.1 - we didn't find a par, check for header and footer
    if (FMouseNoParFound) and (MousePage >= 0) then
    begin
      if wpDblClickCreateHeaderFooter in EditOptionsEx then
        range := wpraOnAllPages
      else range := wpraIgnored;
      if FMouseMarginArea = wpTopMargin then
      begin
        newblock := Memo.GetRTFBlockOnPaintPage(wpIsHeader, MousePage);
        if (newblock = nil) then
        begin
          if Assigned(FOnClickCreateHeaderFooter) then
            OnClickCreateHeaderFooter(Self, wpIsHeader, range);
          if range <> wpraIgnored then
            newblock := HeaderFooter.Get(wpIsHeader, range, '');
        end;
        if newblock <> nil then ActiveText := newblock;
      end else
        if FMouseMarginArea = wpBottomMargin then
        begin
          newblock := Memo.GetRTFBlockOnPaintPage(wpIsFooter, MousePage);
          if (newblock = nil) and (wpDblClickCreateHeaderFooter in EditOptionsEx) then
          begin
            if Assigned(FOnClickCreateHeaderFooter) then
              OnClickCreateHeaderFooter(Self, wpIsHeader, range);
            if range <> wpraIgnored then
              newblock := HeaderFooter.Get(wpIsFooter, range, '');
          end;
          if newblock <> nil then ActiveText := newblock;
        end;
    end;

    if not Ignore{$IFNDEF WINCOM} and Assigned(FHyperLinkEvent){$ENDIF} then
    begin
      openObj := CodeInsideOf(FClientMouseX, FClientMouseY, wpobjHyperlink, par, posinpar);
      if openObj <> nil then
      begin
        FHyperlinkObj := openObj;
        DoHyperlinkEvent(openObj);
        Ignore := TRUE;
      end;
      FHyperlinkObj := nil;
{$IFDEF PLAINLINKS}
      if assigned(FOnTestForLinkEvent) then
        if (openObj = nil) and (par <> nil) then
        begin
          s := IsLinkAtParPos(par, posinpar);
          if s <> '' then
          begin
            FHyperLinkEvent(Self, s, s, 0);
            Ignore := TRUE;
          end;
        end;
{$ENDIF}
    end;
    if not Ignore then
    begin
      if (FMemo.Cursor.active_paragraph.ParagraphType = wpIsReportGroup) and
        (FMouseX < 300) and assigned(FMemo.RTFData._PaintBand) then
      begin
        if paprIsCollapsed in FMemo.Cursor.active_paragraph.prop then
          exclude(FMemo.Cursor.active_paragraph.prop, paprIsCollapsed)
        else include(FMemo.Cursor.active_paragraph.prop, paprIsCollapsed);
        ReformatAll;
        Repaint;
      end else
        if not FLastMouseWasDrag then
        begin
          if FMouseClickFrameBorder * [wpClickLeftMargin, wpClickRightMargin] <> [] then
          begin
            if wpSelectPageOnDblClick in EditOptions then
              FMemo.SelectedPage := MousePage
            else if not (FMemo.Cursor.IsSelected) or
              (FMemo.Cursor.active_paragraph <> FMemo.Cursor.block_s_par) or
              (FMemo.Cursor.active_paragraph <> FMemo.Cursor.block_e_par) then
              FMemo.Cursor.SelectLine
            else FMemo.Cursor.SelectParagraph;
          end else
          begin
            FMemo.Cursor.SelectWord(FMemo.Cursor.active_paragraph, FMemo.Cursor.active_posinpar, true);
          end;
        end;
    end;
  end;
end;

//##############################################################################
// property ViewRTFData
//##############################################################################


function TWPCustomRtfEdit.GetViewRTFData: TWPRTFDataCollection;
begin
  Result := FViewRTFData;
end;

procedure TWPCustomRtfEdit.SetViewRTFData(x: TWPRTFDataCollection);
begin
  if x <> ViewRTFData then
  begin
    Memo.RemoveRTFData;
    FViewRTFData := nil;
    if x <> nil then
    begin
      Memo.SetRTFDataOrProps(x, nil);
      Memo.DisplayedText := x.Get(wpIsBody, wpraOnAllPages);
      FViewRTFData := x;
    end;
  end;
end;


//##############################################################################
// Paint and Print
//##############################################################################

procedure TWPCustomRtfEdit.Paint;
var pm: TWPPaintDesktopModes;
begin
  FDidTriggerPaintEvent := FALSE;
  if csDestroying in ComponentState then exit;
  inherited Paint;
      // Canvas.Brush.Color := clWhite;
      // Canvas.FillRect(Canvas.ClipRect);
  if Focused and not FThisIsWPPreview then
    pm := [wpDrawFocusOptional]
  else pm := [];

{$IFDEF NODOUBLEBUFFER}
  include(pm, wpDontUseDoubleBuffer);
{$ENDIF}
  if Transparent then
  begin
    pm := pm + [wpDontUseDoubleBuffer, wpDontClearBackground];
  end;

  if not (csLoading in ComponentState) and (FMemo <> nil)
    then FMemo.PaintDesktop(Canvas, ClientWidth, ClientHeight, pm);
  // Paint on Top!
  if not Transparent and assigned(FOnPaint) and not FDidTriggerPaintEvent then FOnPaint(Self);
end;

function TWPCustomRtfEdit.Draw(outCanvas: TCanvas;
  x, y: Integer; // The offset
  h: Integer; // The height to be filled
  xres, yres: Integer; // For x,y,h
  starty: Integer; // from last run
  HandlePageBreaks: Boolean = FALSE): Integer;
begin
  Result := Memo.Draw(outCanvas, x, y, h, xres, yres, starty, HandlePageBreaks);
end;

function TWPCustomRtfEdit.Draw(outCanvas: TCanvas;
  r: TRect;
  zoom: Integer;
  starty: Integer; // from last run
  HandlePageBreaks: Boolean = FALSE): Integer;
var xres, yres: Integer;
  SizeA, SizeB: TSize;
begin
  if zoom = 0 then zoom := 100;
  xres := GetDeviceCaps(outCanvas.Handle, LOGPIXELSX);
  yres := GetDeviceCaps(outCanvas.Handle, LOGPIXELSY);
  GetViewportExtEx(outCanvas.Handle, SizeA);
  GetWindowExtEx(outCanvas.Handle, SizeB);
  xres := Round((xres * zoom / 100) * (SizeA.cx / SizeB.cx)); // *(xres/FMemo.CurrentXPixelsPerInch));
  yres := Round((yres * zoom / 100) * (SizeA.cy / SizeB.cy)); //*(yres/FMemo.CurrentYPixelsPerInch));
  Result := FMemo.Draw(outCanvas, r.Left, r.Top,
    r.Bottom - r.Top, xres, yres, starty, HandlePageBreaks);
end;

function TWPCustomRtfEdit.PrintBottomPos: Integer;
begin
  Result := MulDiv(FMemo._PaintBottomPos, 1440, FMemo.CurrentYPixelsPerInch);
end;

function TWPCustomRtfEdit.PaintPageOnCanvas(PaintPageNr: Integer;
  x, y, pw, ph: Integer; DestCanvas: TCanvas;
  PaintMode: TWPPaintModes = [];
  DestXRes: Integer = 0; DestYRes: Integer = 0;
  ClipY: Integer = -1;
  ClipH: Integer = -1;
  PaintPageMode: TWPRTFEnginePaintPagesModes = [wpUseProvidedWidthHeight]): Boolean;
begin
  if DestCanvas = nil then raise EWPToolsProgError.Create('Canvas may not be nil!');
  if (PaintPageNr < 0) or (PaintPageNr >= FMemo.PaintPageCount) then Result := FALSE
  else
  begin
    FMemo.PaintRTFPage(PaintPageNr, x, y, pw, ph,
      DestCanvas, PaintMode, DestXRes, DestYRes, ClipY, ClipH, PaintPageMode, nil);
    Result := TRUE;
  end;
end;


procedure TWPCustomRtfEdit.SetZoom(ZoomValue: string);
var i: Integer;
begin
  i := Pos('%', ZoomValue);
  if i > 0 then ZoomValue := Copy(ZoomValue, 1, i - 1);
  i := StrToIntDef(ZoomValue, 0);
  if i > 0 then
    Zooming := i;
end;

procedure TWPCustomRtfEdit.SetZoomMode(ZoomShortcutValue: Integer);
begin
  case ZoomShortcutValue of
    0:
      begin
        FSetZoomMode_AutoZoom := wpAutoZoomAdjustColumnCount;
        FSetZoomMode_PageLayout := wplayFullLayout;
        // ... other modes
      end;
    -1:
      begin
        FSetZoomMode_AutoZoom := wpAutoZoomAdjustColumnCount;
      end;
    -2:
      begin
        FSetZoomMode_AutoZoom := wpAutoZoomOff;
      end;
    -3:
      begin
        FSetZoomMode_PageLayout := wplayFullLayout;
      end;
    -4:
      begin
        FSetZoomMode_PageLayout := wplayShrunkenLayout;
      end;
     // ... reserved
    -10:
      begin
        WordWrap := FALSE;
        LayoutMode := wplayShowManualPageBreaks;
        Columns := 1;
        AutoZoom := wpAutoZoomOff;
        Zooming := 100;
      end;
    -11:
      begin
        WordWrap := FALSE;
        LayoutMode := wplayExtendedPageGap;
        Columns := 1;
        AutoZoom := wpAutoZoomOff;
        Zooming := 100;
      end;
    -12:
      begin
        WordWrap := FALSE;
        LayoutMode := FSetZoomMode_PageLayout;
        Columns := 1;
        AutoZoom := wpAutoZoomOff;
        Zooming := 100;
      end;
    -13:
      begin
        WordWrap := FALSE;
        if LayoutMode <> wpDualPageView then
          LayoutMode := FSetZoomMode_PageLayout;
        Columns := 1;
        AutoZoom := wpAutoZoomWidth;
      end;
    -14:
      begin
        WordWrap := FALSE;
        if LayoutMode <> wpDualPageView then
          LayoutMode := FSetZoomMode_PageLayout;
        Columns := 1;
        AutoZoom := wpAutoZoomFullPage;
      end;
    -15:
      begin
        WordWrap := FALSE;
        Columns := 1;
        LayoutMode := wpDualPageView;
        if AutoZoom <> wpAutoZoomWidth then
          AutoZoom := wpAutoZoomFullPage;
      end;
    -16:
      begin
        WordWrap := FALSE;
        LayoutMode := wpDualPageView;
        Columns := 1;
        if AutoZoom <> wpAutoZoomFullPage then
          AutoZoom := wpAutoZoomWidth;
      end;
    -17:
      begin
        LayoutMode := FSetZoomMode_PageLayout;
        Columns := 1;
        Zooming := 100;
        AutoZoom := wpAutoZoomOff;
        WordWrap := TRUE;
      end;
    -18:
      begin
        LayoutMode := wplayShowManualPageBreaks;
        Columns := 1;
        Zooming := 100;
        AutoZoom := wpAutoZoomOff;
        WordWrap := TRUE;
      end;
    -19:
      begin
        WordWrap := FALSE;
        LayoutMode := wpThumbNailView;
        Columns := 1;
        AutoZoom := wpAutoZoomOff;
      end;
    -20:
      begin
        WordWrap := FALSE;
        Columns := 1;
        LayoutMode := wpDualPageView;
        AutoZoom := wpAutoZoomWidth;
      end;
  else
    begin
      if LayoutMode in [wpDualPageView, wpThumbNailView] then
        LayoutMode := wplayFullLayout;
      if not WordWrap and (ZoomShortcutValue <= 50) and
        (LayoutMode in [wplayShrunkenLayout, wplayLayout, wplayFullLayout])
        and (FSetZoomMode_AutoZoom = wpAutoZoomAdjustColumnCount) then
        AutoZoom := wpAutoZoomAdjustColumnCount
      else AutoZoom := wpAutoZoomOff;
      Zooming := ZoomShortcutValue;
    end;
  end;
end;

procedure TWPCustomRtfEdit.LockScreen;
begin
  if FLockScreen = 0 then
  begin
    if FMemo.ScrollPosition > 0 then
      FLockScreenScrollPosition := FMemo.ScrollPosition;
    FLockScreenTopOffset := FMemo.TopOffset;
    FLockScreenLeftOffset := FMemo.LeftOffset;
    FLockScreenZooming := FMemo.CurrentZooming;
  end;
  inc(FLockScreen);
  if FLockScreen > 0 then FMemo.PaintState := FMemo.PaintState + [wpLockPaint];
end;

procedure TWPCustomRtfEdit.Refresh(SpellCheck: Boolean = FALSE);
begin
  if FLocked <= 0 then
  begin
    FMemo.ReformatAll(false, true);
    FMemo.ReorderPaintPages;
  end;
  if HandleAllocated then
  begin
    SetScrollBarSize(false);
    SetScrollBarSize(true);
    if FLockScreen <= 0 then
    begin
      FMemo.PaintDesktop(Canvas, ClientWidth, ClientHeight, [wpClearDoubleBuffer]);
      if assigned(FOnPaint) then FOnPaint(Self);
    end;
  end;
end;

procedure TWPCustomRtfEdit.IgnoreMouse;
begin
  FIgnoreMouse := TRUE;
  FIgnoreMouseMove := TRUE;
  FTextObjectUnderMouse := nil;
end;

procedure TWPCustomRtfEdit.FrameLine(Mode: TWPFrameLineMode; ScreenPos: Integer = 0);
var p: TPoint;
begin
  if Mode = wpHorzFrameLine then
  begin
    p.X := 0;
    p.Y := ScreenPos;
    p := ScreenToClient(P);
    ScreenPos := p.Y;
  end else
    if Mode = wpVertFrameLine then
    begin
      p.Y := 0;
      p.X := ScreenPos;
      p := ScreenToClient(P);
      ScreenPos := p.X;
    end;
  FMemo.FrameLine(Mode, ScreenPos);
end;

    //: Update the screen

procedure TWPCustomRtfEdit.UnLockScreen(RestoreScrollPosition: Boolean);
begin
  dec(FLockScreen);
  if FLockScreen <= 0 then
  begin
    if RestoreScrollPosition then
    begin
      if Abs(FMemo.CurrentZooming - FLockScreenZooming) < 0.001 then
        FMemo.TopOffset := FLockScreenTopOffset
      else FMemo.ScrollPosition := FLockScreenScrollPosition;
      FMemo.LeftOffset := FLockScreenLeftOffset;
    end;
    FMemo.PaintState := FMemo.PaintState - [wpLockPaint];
    //NOT HERE! FMemo.PaintDesktop(Canvas, ClientWidth, ClientHeight, true);
  end;
end;

procedure TWPCustomRtfEdit.SetFocusValues(Always: Boolean);
begin
  if Always or Focused then
    DoUpdateState(wpAfterGetFocus);
end;

procedure TWPCustomRtfEdit.DeleteFocusValues;
begin
end;

function TWPCustomRtfEdit.OpenDialog(DialogType: TWPCustomRtfEditDialog): Boolean;
begin
  Result := FALSE;
  if visible and assigned(FOnOpenDialog) then FOnOpenDialog(Self, DialogType, Result);
end;

procedure TWPCustomRtfEdit.OnToolBarSelection(Sender: TObject; var Typ: TWpSelNr;
  const str: string; const num: Integer);
begin
  if assigned(FOnToolBarSelection) then
    FOnToolBarSelection(Self, Typ, str, num);
end;

procedure TWPCustomRtfEdit.DoPrepareImageforSaving(RTFData: TWPRTFDataCollection;
  Writer: TWPCustomTextWriter; TextObject: TWPTextObj; var DontSave: Boolean);
begin
  if Assigned(FOnPrepareImageforSaving) then
    FOnPrepareImageforSaving(RTFData, Writer, TextObject, DontSave);
end;

procedure TWPCustomRtfEdit.DoAfterImageSaving(RTFData: TWPRTFDataCollection;
  Writer: TWPCustomTextWriter; TextObject: TWPTextObj);
begin
  if Assigned(FAfterImageSaving) then
    FAfterImageSaving(RTFData, Writer, TextObject);
end;

procedure TWPCustomRtfEdit.DoRequestHTTPImage(RTFData: TWPRTFDataCollection;
  Reader: TWPCustomTextReader; const LoadPath, URL: string;
  TextObject: TWPTextObj; var Ok: Boolean);
begin
  if Assigned(FOnRequestHTTPImage) then
    FOnRequestHTTPImage(RTFData, Reader, LoadPath, URL, TextObject, Ok);
end;

procedure TWPCustomRtfEdit.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TWPCustomRtfEdit.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FNeedToResetCursor then
  begin
    Screen.Cursor := crDefault;
    FNeedToResetCursor := FALSE;
  end;
  if assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

//##############################################################################
// Gather Information
//##############################################################################


function TWPCustomRtfEdit.CalcMousePageAtXY(WindowX, WindowY: Integer): Integer;
begin
  FClientMouseX := WindowX;
  FClientMouseY := WindowY;
  Result := FMemo.GetPageAtXY(WindowX, WindowY, FMouseMarginArea);
  FMouseX := WindowX;
  FMouseY := WindowY;
  FMouseNoParFound := false;
  FMousePage := Result;
end;

function TWPCustomRtfEdit.CPMoveTo(X, Y: Integer; DontLeaveDataBlock: Boolean = FALSE): Boolean;
var PageNr: Integer;
begin
  PageNr := FMemo.GetPageAtXY(X, Y);
  if PageNr >= 0 then
  begin
    Result := FMemo.MoveCursor(PageNr, X, Y, DontLeaveDataBlock); //V5.18.1
    if Result then
    begin
      FCaret.UpdatePos;
      AddHistoryChar(#0);
    end;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.GetTextScreenRect(par: TParagraph; posinpar: Integer;
  var x, y, w, h: Integer; CharOffset: Boolean = FALSE): Boolean;
begin
  Result := FMemo.GetTextScreenRect(par, posinpar, x, y, w, h, CharOffset);
end;

function TWPCustomRtfEdit.ScreenToRTFPage(ScreenX, ScreenY: Integer; var X, Y, RTFPageNr: Integer;
  IgnoreX: Boolean = FALSE): Boolean;
var PaintPage: Integer;
  rtfpage: TWPVirtPage;

begin
  X := ScreenX;
  Y := ScreenY;
  rtfpage := FMemo.GetRTFPageAtXY(X, Y, PaintPage, RTFPageNr, IgnoreX);
  Result := rtfpage <> nil;
end;

function TWPCustomRtfEdit.GetLineFromXY(ScreenX, ScreenY: Integer;
  var par: TParagraph; var posinpar: Integer): Boolean;
var RTFPageNr, PaintPage: Integer;
  rtfpage: TWPVirtPage;
  aRTFData: TWPRTFDataBlock;
  FrameBorder: TWPFrameBorder;
  TextObject: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
begin
  Result := FALSE;
  par := nil;
  posinpar := 0;
  // after the call to GetRTFPageAtXY ScreenX, ScreenY is in RTF coordinates!
  rtfpage := FMemo.GetRTFPageAtXY(ScreenX, ScreenY, PaintPage, RTFPageNr, True);
  if rtfpage <> nil then
  begin
    Result := FMemo.GetRTFPositionAtXY(PaintPage, ScreenX, ScreenY,
      aRTFData, par, posinpar, FrameBorder, TextObject, SizerElement, false,
      [wpCoordProcessedBy_GetRTFPageAtXY]);
  end;
end;

function TWPCustomRtfEdit.GetPageXYfromXY(ScreenX, ScreenY: Integer;
  var PageNr, PageXTW, PageYTW: Integer;
  var par: TParagraph): Boolean;
var RTFPageNr, PaintPage: Integer;
  rtfpage: TWPVirtPage;
begin
  Result := FALSE;
  PageNr := -1;
  par := nil;
  PageXTW := 0;
  PageYTW := 0;
  // after the call to GetRTFPageAtXY ScreenX, ScreenY is in RTF coordinates!
  rtfpage := FMemo.GetRTFPageAtXY(ScreenX, ScreenY, PaintPage, RTFPageNr, false);
  if rtfpage <> nil then
  begin
    PageXTW := MulDiv(ScreenX, 1440, Memo.CurrentXPixelsPerInch);
    PageYTW := MulDiv(ScreenY, 1440, Memo.CurrentXPixelsPerInch);
    par := rtfpage.FindFirstTextParStart(false);
    Result := (par <> nil);
  end;
end;

function TWPCustomRtfEdit.GetObjectFromXY(ScreenX, ScreenY: Integer;
  var TextObject: TWPTextObj): Boolean;
var RTFPageNr, PaintPage: Integer;
  rtfpage: TWPVirtPage;
  aRTFData: TWPRTFDataBlock;
  par: PTParagraph;
  posinpar: Integer;
  FrameBorder: TWPFrameBorder;
  SizerElement: TWPPaintSizerRects;
begin
  Result := FALSE;
  par := nil;
  TextObject := nil;
  posinpar := 0;
  rtfpage := FMemo.GetRTFPageAtXY(ScreenX, ScreenY, PaintPage, RTFPageNr);
  if rtfpage <> nil then
  begin
    if FMemo.GetRTFPositionAtXY(PaintPage, ScreenX, ScreenY,
      aRTFData, par, posinpar, FrameBorder, TextObject, SizerElement, false) then
      Result := TextObject <> nil;
  end;
end;


function TWPCustomRtfEdit.GetPar(ParIndex: Integer): TParagraph;
begin
  Result := FirstPar;
  while (Result <> nil) and (ParIndex > 0) do
  begin Result := Result.next; dec(ParIndex); end;
end;

//##############################################################################
// Update Text
//##############################################################################

procedure TWPCustomRtfEdit.DelayedReformat;
begin
  if (FLocked > 0) or (FLockScreen > 0) then exit;
  FMemo.RTFData.NeedReformat;
  StartUpdate(WPUPD_REFORMAT);
  StartUpdate(WPUPD_UPDATTRIBUTES);
  StartUpdate(WPUPD_SHOWCURSOR);
  invalidate;
end;

procedure TWPCustomRtfEdit.UpdateEditBox;
var w, h, off: Integer; Change: Boolean;
begin
  if (FMemo.LayoutMode in [wplayNormal, wplayShowManualPageBreaks]) and
    (EditBoxModes * [wpemAutoSizeHeight, wpemAutoSizeWidth] <> []) then
  begin
    w := Width;
    h := Height;
    Change := FALSE;
    if (wpemAutoSizeWidth in EditBoxModes) and not (Align in [alTop, alBottom, alClient]) then
    begin
      FMemo._UseAutoSizeWidth := TRUE;
      try
        ReformatAll; // NOW apply wordwrap!
        FMemo.InitializePaintPages;
        FMemo.ReorderPaintPages;
      finally
        FMemo._UseAutoSizeWidth := FALSE;
      end;
      off := MulDiv(XOffset, WPScreenPixelsPerInch, 720); // =2*XOffset
      w := Round(FMemo.TextWidth * FMemo.CurrentZooming * WPScreenPixelsPerInch / FMemo.CurrentXPixelsPerInch) + off;
      h := Round(FMemo.PaintPagesHeight * FMemo.CurrentZooming);
      if w < 20 + off then w := 20 + off;
      if Abs(FMemo.WindowWidth - w) > 2 then
        Change := TRUE;
      if assigned(FOnEditBoxChangeWidth) then
      begin
        FOnEditBoxChangeWidth(Self, w, h, Change);
        if h < 10 then h := 10;
        if w < 10 then w := 10;
        if Change or WordWrap then
        begin
          FMemo.WindowWidth := w - off;
          FMemo.WindowHeight := h;
          ReformatAll; // NOW apply wordwrap!
          FMemo.InitializePaintPages;
          FMemo.ReorderPaintPages;
        end;
      end;
    end;

    if (wpemAutoSizeHeight in EditBoxModes) and not (Align in [alLeft, alRight, alClient]) then
    begin
      h := Round(FMemo.PaintPagesHeight * FMemo.CurrentZooming);
      if ScrollBars in [ssHorizontal, ssBoth] then inc(h, Height - ClientHeight);
      if Abs(Height - h) > 2 then Change := TRUE;
      if assigned(FOnEditBoxChangeHeight) then
        FOnEditBoxChangeHeight(Self, w, h, Change);
      if h < 10 then h := 10;
      if w < 10 then w := 10;
    end;
    if Change then SetBounds(Left, Top, w, h);
  end;
end;

procedure TWPCustomRtfEdit.Resize;
var sw, ww, wh: Integer;
begin
  if FInResize then exit;
  try
    FInResize := TRUE;
    if assigned(FBeforeResize) then FBeforeResize(Self);
    LockScreen;
    inherited Resize;
    if WordWrap and (FScrollBars in [ssBoth, ssVertical]) then sw := 16 else sw := 0;
    if WordWrap and (LayoutMode = wplayNormal) then inc(sw,
        MulDiv(XOffset, WPScreenPixelsPerInch, 1440));

  // if FScrollBars in [ssBoth, ssHorizontal] then sh := 16 else sh := 0;
    ww := ClientWidth - sw; // Width - sw;
    wh := ClientHeight; // Height - sh;
    if (wh <> FMemo.WindowWidth) or (ww <> FMemo.WindowWidth) then
    begin
      FMemo.WindowWidth := ww;
      FMemo.WindowHeight := wh;
      FMemo.ReorderPaintPages;
    end else
    begin
      FMemo.WindowWidth := ww;
      FMemo.WindowHeight := wh;
    end;
    UnlockScreen(true);
    if assigned(FOnResize) then FOnResize(Self);

    if WordWrap and not (AutoZoom in [wpAutoZoomWidth, wpAutoZoomFullPage]) then
    begin
      DelayedReformat;
    end else
    begin
      SetScrollBarSize(false);
      SetScrollBarSize(true);
    end;
  // ShowCursor; - not a good idea!
  finally
    FInResize := FALSE;
  end;
end;

procedure TWPCustomRtfEdit.Repaint;
begin
  FMemo._DBufferIsValid := FALSE;
  Invalidate;
  if not Transparent then Update;
end;

procedure TWPCustomRtfEdit.Invalidate;
var r: TRect;
begin
  if Transparent and (Parent <> nil) then
  begin
    r := BoundsRect;
    InvalidateRect(Parent.Handle, @r, true);
  end;
  inherited Invalidate;
end;

//##############################################################################
// Focus
//##############################################################################

procedure TWPCustomRtfEdit.KillFocus;
begin
  if HandleAllocated and (FCaret <> nil) then FCaret.Active := FALSE;
  if (FSuspended <= 0) and (wpHideSelectionNonFocussed in ViewOptions) and IsSelected then
  begin
    FMemo._DBufferIsValid := FALSE;
    FMemo.Repaint;
  end;
end;

procedure TWPCustomRtfEdit.GetFocus;
begin
  if HandleAllocated and not (csDesigning in ComponentState) and Enabled then
  begin
    if (WPLastActiveRTFEdit <> nil) and (WPLastActiveRTFEdit <> Self) and
      (FSuspended <= 0) and
      (wpHideSelectionNonFocussedAndInactive in WPLastActiveRTFEdit.ViewOptions) and
      WPLastActiveRTFEdit.IsSelected
      then
    begin
      WPLastActiveRTFEdit.FMemo._DBufferIsValid := FALSE;
      WPLastActiveRTFEdit.FMemo.Repaint;
    end;
    WPLastActiveRTFEdit := self;
    if (FSuspended <= 0) and (wpHideSelectionNonFocussed in ViewOptions) and IsSelected then
    begin
      FMemo._DBufferIsValid := FALSE;
      FMemo.Repaint;
    end;

    if wpDisableCaret in EditOptionsEx then
    begin
      if FCaret <> nil then
      begin
        FCaret.Active := FALSE;
        FCaret.Visible := FALSE;
      end;
    end else
    begin
      FMemo.Cursor.RTFEngine := FMemo;

    // If there is no text create and select the Body !
      if FMemo.DisplayedText = nil then
      begin
        FMemo.DisplayedText := FMemo.Body;
        FMemo.Cursor.MoveTo(FMemo.DisplayedText.FirstPar, 0);
        DelayedReformat;
      end else
      begin
        if FMemo.Cursor.RTFData = nil then
          FMemo.Cursor.RTFData := FMemo.DisplayedText;
      end;

      if FCaret <> nil then
      begin
        if (wpDisableCaret in EditOptionsEx) then
        begin
          FCaret.Active := FALSE;
          FCaret.Visible := FALSE;
        end
        else if not FCaret.Active then
        begin
          FCaret.UpdatePos;
          FCaret.Visible := TRUE;
          FCaret.Active := TRUE;
        end;
      end;
    // DoEditState;
    end;
    SetFocusValues(false);
    if assigned(FOnChangeCursorPos) then
      FOnChangeCursorPos(Self);
  end;
end;

function TWPCustomRtfEdit.GetActiveText: TWPRTFDataBlock;
begin
  if FMemo.DisplayedText <> nil then
  begin
    if FMemo.Cursor.RTFData = nil then
      Result := FMemo.DisplayedText
    else Result := FMemo.Cursor.RTFData;
  end else Result := FMemo.Cursor.RTFData;
end;

function TWPCustomRtfEdit.DontAllowLeaveRTFDataBlock: Boolean;
begin
  if (wpDisableEditOfNonBodyDataBlocks in EditOptionsEx)
    or (LayoutMode = wplayLayout) then
    with FMemo.Cursor do
    begin
      if (RTFData = nil) or (RTFData.Kind <> wpIsBody) then
        Result := FALSE
      else Result := TRUE;
    end else Result := FALSE;
end;

procedure TWPCustomRtfEdit.SetActiveText(x: TWPRTFDataBlock);
begin
  if GetActiveText <> x then
  begin
    if (FMemo.DisplayedText <> nil) and
      (FMemo.DisplayedText.Kind = wpIsBody)
      and (LayoutMode in
      [wplayFullLayout, wpDualPageView, wpThumbNailView])
      then
      FMemo.Cursor.RTFData := x
    else
    begin
      Memo.DisplayedText := x;
      Memo.CursorOntext := x;
      invalidate;
    end;
  end;
end;

function TWPCustomRtfEdit.GetCursorOnText: TWPRTFDataBlock;
begin
  Result := Memo.CursorOntext;
end;

procedure TWPCustomRtfEdit.SetCursorOnText(x: TWPRTFDataBlock);
begin
  if x <> nil then
    Memo.CursorOntext := x;
end;

function TWPCustomRtfEdit.GetDisplayedText: TWPRTFDataBlock;
begin
  Result := Memo.DisplayedText;
end;

procedure TWPCustomRtfEdit.SetDisplayedText(x: TWPRTFDataBlock);
begin
  if x <> nil then
    Memo.DisplayedText := x;
end;

function TWPCustomRtfEdit.GetTopVisiblePar: TParagraph;
var par: PTParagraph;
  posinpar: Integer;
begin
  Result := FirstPar;
  if GetLineFromXY(0, 0, par, posinpar) then
    Result := par;
end;

procedure TWPCustomRtfEdit.SetTopVisiblePar(x: TParagraph);
begin

end;

procedure TWPCustomRtfEdit.SetReadOnly(Value: Boolean);
begin
  FReadonly := Value;
end;

procedure TWPCustomRtfEdit.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FGraphicPopupMenu <> nil) and
      (AComponent = FGraphicPopupMenu) then FGraphicPopupMenu := nil;
  end;
end;

procedure TWPCustomRtfEdit.DoChangeZooming(Sender: TObject);
begin
  if assigned(FOnChangeZooming) then FOnChangeZooming(Self);
end;

function TWPCustomRtfEdit.GetReadOnly: Boolean;
begin
  Result := FReadonly and (Memo._NotingIsProtected = 0);
end;

procedure TWPCustomRtfEdit.SetModified(Value: Boolean);
begin
  if Memo.HasData then
    Memo.RTFData.Modified := Value;
end;

function TWPCustomRtfEdit.GetModified: Boolean;
begin
  if not Memo.HasData then Result := FALSE
  else Result := Memo.RTFData.Modified;
end;

//##############################################################################
// handle the memory buffer and properties
//##############################################################################

procedure TWPCustomRtfEdit.DoInitializeRTFDataObject(Sender: TObject);
var RTFDataObject: TWPRTFDataCollection;
  RTFPropsObject: TWPRTFProps;
begin
  if assigned(FOnInitializeRTFDataObject) then
  begin
    RTFDataObject := nil;
    RTFPropsObject := nil;
    FOnInitializeRTFDataObject(Self, RTFDataObject, RTFPropsObject);
    if (RTFDataObject <> nil) or (RTFPropsObject <> nil) then
      FMemo.SetRTFDataOrProps(RTFDataObject, RTFPropsObject);
  end;
end;

procedure TWPCustomRtfEdit.DoInitializedRTFData(Sender: TObject);
var RTFDataObject: TWPRTFDataCollection;
  RTFPropsObject: TWPRTFProps;
begin
  RTFDataObject := FMemo.RTFData;
  RTFPropsObject := FMemo.RTFData.RTFProps;
  if assigned(FOnInitializedRTFData) then
  begin
    FOnInitializedRTFData(Self, RTFDataObject, RTFPropsObject);
  end;
  if not FIDEValueLoaded then
  begin
    FIDEValueLoaded := TRUE;
    Header := FIDETextHeader;
    RTFVariables := FIDERTFVariables;
    PrintParameter := FIDEPrintParameter;
    // NumberStyles := FIDENumberStyles;
    FormatOptions := FIDEFormatOptions;
    FormatOptionsEx := FIDEFormatOptionsEx;
    RTFDataObject.OnRequestStyle := FIDEOnRequestStyle;
    RTFDataObject.OnRequestHTTPString := FIDEOnRequestHTTPString;
    RTFDataObject._InternOnRequestHTTPImage := DoRequestHTTPImage;
    RTFDataObject._InternOnPrepareImageforSaving := DoPrepareImageforSaving;
    RTFDataObject._InternAfterImageSaving := DoAfterImageSaving;
    RTFDataObject.WriteObjectMode := FIDEWriteObjectMode;
    RTFDataObject.RTFVariables.aOwner := Self; //V5.13
  end;
end;

procedure TWPCustomRtfEdit.DoAfterInitializeRTFDataObject(Sender: TObject);
begin
   // Nothing to do here
end;



//##############################################################################
// Object events - only used for embeded TWinControls
//##############################################################################
(*
procedure TWPCustomRtfEdit.DoTxtObjMouseMove(Sender: TObject; Shift:
  TShiftState; X, Y: Integer);
var
  obj: TWPObject;
  p: TPoint;
  pobj: PTTextObj;
begin
  if assigned(FOnTextObjectMouseMove) and (Sender is TControl) then
  try
    obj := TWPObject(TControl(Sender).Tag);
    if obj <> nil then
    begin
      p.x := 1;
      p.y := 1;
      p := TControl(Sender).ClientToScreen(p);
      p := Self.ScreenToClient(p);
      pobj := TextObjectAtScreenXY(p.x, p.y);
      if pobj <> nil then
      begin
        FThisObject := TWPObject(pobj^.obj);
        FOnTextObjectMouseMove(Self, pobj, obj, mbLeft, Shift, x, y);
      end;
    end;
  except
  end;
end;


procedure TWPCustomRtfEdit.DoTxtObjMouseDown(Sender: TObject; Button:
  TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  obj: TWPObject;
  p: TPoint;
  pobj: PTTextObj;
begin
  if assigned(FOnTextObjectMouseDown) and (Sender is TControl) then
  try
    obj := TWPObject(TControl(Sender).Tag);
    if obj <> nil then
    begin
      p.x := 1;
      p.y := 1;
      p := TControl(Sender).ClientToScreen(p);
      p := Self.ScreenToClient(p);
      pobj := TextObjectAtScreenXY(p.x, p.y);
      if pobj <> nil then
      begin
        FThisObject := TWPObject(pobj^.obj);
        FOnTextObjectMouseDown(Self, pobj, obj, Button, Shift, x, y);
      end;
    end;
  except
  end;
end;


procedure TWPCustomRtfEdit.DoTxtObjMouseUp(Sender: TObject; Button:
  TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  obj: TWPObject;
  p: TPoint;
  pobj: PTTextObj;
begin
  if assigned(FOnTextObjectMouseUp) and (Sender is TControl) then
  try
    obj := TWPObject(TControl(Sender).Tag);
    if obj <> nil then
    begin
      p.x := 1;
      p.y := 1;
      p := TControl(Sender).ClientToScreen(p);
      p := Self.ScreenToClient(p);
      pobj := TextObjectAtScreenXY(p.x, p.y);
      FThisObject := TWPObject(pobj^.obj);
      FOnTextObjectMouseUp(Self, pobj, obj, Button, Shift, x, y);
    end;
  except
  end;
end;

procedure TWPCustomRtfEdit.DoTxtObjClick(Sender: TObject);
var
  obj: TWPObject;
  p: TPoint;
  pobj: PTTextObj;
  ignore: Boolean;
begin
  if assigned(FOnTextObjectClick) and (Sender is TControl) then
  try
    obj := TWPObject(TControl(Sender).Tag);
    if obj <> nil then
    begin
      p.x := 1;
      p.y := 1;
      p := TControl(Sender).ClientToScreen(p);
      p := Self.ScreenToClient(p);
      pobj := TextObjectAtScreenXY(p.x, p.y);
      ignore := TRUE;
      FThisObject := TWPObject(pobj^.obj);
      FOnTextObjectClick(Self, pobj, obj, ignore);
    end;
  except
  end;
end;  *)

//##############################################################################
// Get/Set Properties
//##############################################################################

function TWPCustomRtfEdit.IsHeaderStored: Boolean;
begin
  Result := not AllowMultiView;
end;


function TWPCustomRtfEdit.GetRTFText: TWPRTFBlobContents;
begin
  Result := FRTFText;
end;

procedure TWPCustomRtfEdit.SetRTFText(x: TWPRTFBlobContents);
begin
  if x = nil then FRTFText.Empty := TRUE
  else FRTFText.Assign(x);
end;

function TWPCustomRtfEdit.GetTransparent: Boolean;
begin
  Result := FMemo._Transparent;
end;

procedure TWPCustomRtfEdit.SetTransparent(x: Boolean);
begin
  if FMemo._Transparent <> x then
  begin
    FMemo._Transparent := x;
    ReCreateWnd;
  end;
end;

procedure TWPCustomRtfEdit.SetGraphicPopupMenu(x: TPopupMenu);
begin
  FGraphicPopupMenu := x;
  if FGraphicPopupMenu <> nil then
    FGraphicPopupMenu.FreeNotification(Self);
end;

function TWPCustomRtfEdit.GetTextLen: Integer;
begin
  Result := GetTextBuf(nil, 0);
end;

{$IFNDEF CLR}

function TWPCustomRtfEdit.GetTextBuf(Buffer: PChar; BufSize: Integer): Integer;
var i: Integer;
  par: TParagraph;
  s: string;
begin
  Result := 0;
  if (ActiveText <> nil) and not ActiveText.Empty then
  begin
    par := ActiveText.FirstPar;
    while par <> nil do
    begin
      if not (par.ParagraphType in [wpIsTable, wpIsTableRow]) then
      begin
        s := par.ANSIText; // Does not include object codes !
        i := Length(s);
        if (Buffer <> nil) and (BufSize > 0) then
        begin
          if BufSize < i + 1 then
            StrPLCopy(Buffer, s, BufSize - 1)
          else StrPLCopy(Buffer, s, i);
          dec(BufSize, i);
          inc(Buffer, i);
          if (BufSize > 1) then
          begin
            Buffer^ := #13;
            dec(BufSize);
            inc(Buffer);
          end;
         { if BufSize>1 then  // Closing #0
            Buffer^ := #0;   }
        end;
        inc(Result, i + 1);
      end;
      par := par.next;
    end;
  end;
end;
{$ENDIF}

procedure TWPCustomRtfEdit.DoUpdateState(State: TWPEditBoxLinkMsg);
var i: Integer;
begin
  for i := 0 to FEditBoxLinkCollections.Count - 1 do
    TWPEditBoxLinkCollection(FEditBoxLinkCollections[i]).DoUpdateState(Self, State);
end;

function TWPCustomRtfEdit.GetHeaderFooter: TWPRTFDataCollection;
begin
  Result := FMemo.RTFData;
end;

function TWPCustomRtfEdit.GetBodyText: TWPRTFDataBlock;
begin
  Result := FMemo.Body;
  if Result = nil then raise Exception.Create('The text has no body yet');
end;

function TWPCustomRtfEdit.GetTextObjects: TWPObjectEnv;
begin
  Result := Memo.RTFData.TextObjects;
end;

function TWPCustomRtfEdit.GetMemo: TWPRTFEnginePaint;
begin
  Result := FMemo;
end;


procedure TWPCustomRtfEdit.RemoveRTFData;
begin
  FMemo.RemoveRTFData;
end;

procedure TWPCustomRtfEdit.SetRTFData(RTFData: TWPRTFDataCollection);
begin
  FMemo.SetRTFDataOrProps(RTFData, nil);
  FMemo.Cursor.RTFEngine := FMemo;
  FMemo.DisplayedText := RTFData.Get(wpIsBody, wpraOnAllPages);
  FMemo.Cursor.RTFData := FMemo.DisplayedText;
  DelayedReformat;
end;

function TWPCustomRtfEdit.Enviroment: TWPToolsBasicEnviroment;
begin
  Result := FMemo.RTFData.RTFProps.Enviroment;
  if Result = nil then raise Exception.Create('No WPTools Enviroment created!');
end;

function TWPCustomRtfEdit.GetFinder: TWPTextFinder;
begin
  Result := FMemo.RTFData.Cursor.Finder;
end;

{$IFNDEF NOFILEMANSUPPORT}

procedure TWPCustomRtfEdit.SetAcceptFiles(x: Boolean);
begin
  if FAcceptFiles <> x then
  begin
    FAcceptFiles := x;
    ReCreateWnd;
  end;
end;
{$ENDIF}

procedure TWPCustomRtfEdit.SetBorderStyle(Value: TBorderStyle);
begin
  if FBorderStyle <> Value then
  begin
    FBorderStyle := Value;
    RecreateWnd;
  end;
end;

procedure TWPCustomRtfEdit.SetEditOptions(x: TWPEditOptions);
begin
  FMemo.EditOptions := x;
end;

function TWPCustomRtfEdit.GetEditOptions: TWPEditOptions;
begin
  Result := FMemo.EditOptions;
end;

procedure TWPCustomRtfEdit.SetEditOptionsEx(x: TWPEditOptionsEx);
begin
  FMemo.EditOptionsEx := x;
end;

function TWPCustomRtfEdit.GetEditOptionsEx: TWPEditOptionsEx;
begin
  Result := FMemo.EditOptionsEx;
end;


//##############################################################################
//######## Update        #######################################################
//##############################################################################

function TWPCustomRtfEdit.Changing: Boolean;
begin
  Result := not FReadonly;
end;

function TWPCustomRtfEdit.SaveChanging: Boolean;
begin
  // We do not check 'FReadonly' here since object resizing anf
  // table resizing is controlled by the 'EditOptions' !
  Result := TRUE;
  Modified := TRUE;
end;

procedure TWPCustomRtfEdit.ChangeApplied;
begin
  Modified := TRUE;
  if assigned(FOnChange) then FOnChange(Self);
end;


function TWPCustomRtfEdit.IsSelected: Boolean;
begin
  Result := Memo.Cursor.IsSelected(true); {(Memo.Cursor.block_s_par <> nil) and
    (Memo.Cursor.block_e_par <> nil); }//V5.20.1
end;

function TWPCustomRtfEdit.TextCursor: TWPRTFDataCursor;
begin
  // can be optimized !
  Result := FMemo.Cursor;
end;

function TWPCustomRtfEdit.AGet(WPAT_Code: Byte; var Value: Integer): Boolean;
begin
  if IsSelected then
    Result := Memo.Cursor.SelectedTextAttr.AGet(WPAT_Code, Value)
  else Result := Memo.Cursor.WritingTextAttr.AGet(WPAT_Code, Value);
end;

procedure TWPCustomRtfEdit.ADel(WPAT_Code: Byte);
begin
  SaveChanging;
  if IsSelected then
    Memo.Cursor.SelectedTextAttr.ADel(WPAT_Code)
  else Memo.Cursor.WritingTextAttr.ADel(WPAT_Code);
end;

procedure TWPCustomRtfEdit.ASet(WPAT_Code: Byte; Value: Integer);
begin
  SaveChanging;
  if IsSelected then
    Memo.Cursor.SelectedTextAttr.ASet(WPAT_Code, Value)
  else
  begin
    Memo.Cursor.WritingTextAttr.ASet(WPAT_Code, Value);
  end;
end;

procedure TWPCustomRtfEdit.ASetAdd(WPAT_Code: Byte; Value: Cardinal);
begin
  SaveChanging;
  if IsSelected then
    Memo.Cursor.SelectedTextAttr.ASetAdd(WPAT_Code, Value)
  else Memo.Cursor.WritingTextAttr.ASetAdd(WPAT_Code, Value);
end;

procedure TWPCustomRtfEdit.ASetDel(WPAT_Code: Byte; Value: Cardinal);
begin
  SaveChanging;
  if IsSelected then
    Memo.Cursor.SelectedTextAttr.ASetDel(WPAT_Code, Value)
  else Memo.Cursor.WritingTextAttr.ASetDel(WPAT_Code, Value);
end;



function TWPCustomRtfEdit.TabstopAdd(PosInTwips: Integer;
  kind: TTabKind = tkLeft;
  FillMode: TTabFill = tkNoFill;
  FillColor: Integer = 0): Boolean;
begin
  SaveChanging;
  if IsSelected then
    Result := Memo.Cursor.SelectedTextAttr.TabstopAdd(PosInTwips, kind, FillMode, FillColor)
  else Result := Memo.Cursor.WritingTextAttr.TabstopAdd(PosInTwips, kind, FillMode, FillColor);
end;

function TWPCustomRtfEdit.TabstopDelete(PosInTwips: Integer): Boolean;
begin
  SaveChanging;
  if IsSelected then
    Result := Memo.Cursor.SelectedTextAttr.TabstopDelete(PosInTwips)
  else Result := Memo.Cursor.WritingTextAttr.TabstopDelete(PosInTwips);
end;

procedure TWPCustomRtfEdit.TabstopClear;
begin
  SaveChanging;
  if IsSelected then
    Memo.Cursor.SelectedTextAttr.TabstopClear
  else Memo.Cursor.WritingTextAttr.TabstopClear;
end;


//##############################################################################
// Code / TWPTextObj Procedures
//##############################################################################

function TWPCustomRtfEdit.OpenCodes(x, y: Integer;
  List: TWPTextObjList; CheckedCodes: TWPTextObjTypes; MaxCount: Integer = 0): TWPTextObj;
var aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par, CurrPage: Integer;
  FrameBorder: TWPFrameBorder;
  FloatingImage: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
begin
  Result := nil;
  if Memo.HasData then
  begin
    CurrPage := FMemo.GetPageAtXY(X, Y);
    FMemo.GetRTFPositionAtXY(CurrPage, X, Y, aRTFData,
      par, pos_in_par, FrameBorder, FloatingImage, SizerElement);
    if Par <> nil then
    begin
      Result := OpenCodes(par, pos_in_par, List, CheckedCodes, MaxCount);
    end;
  end;
end;


function TWPCustomRtfEdit.OpenCodes(par: TParagraph; PosInPar: Integer;
  List: TWPTextObjList; CheckedCodes: TWPTextObjTypes; MaxCount: Integer = 0): TWPTextObj;
var obj: TWPTextObj;
  level: Integer;
  first: Boolean;
begin
  level := 0;
  Result := nil;
  first := TRUE;
  with Memo.RTFData do
  begin
    if par = nil then
    begin
      par := Cursor.active_paragraph;
      PosInPar := Cursor.active_posinpar;
    end;
    while par <> nil do
    begin
      if par.HasObjects(false, CheckedCodes) then
      begin
        while PosInPar >= 0 do
        begin
          obj := par.ObjectRef[PosInPar];
          if (obj <> nil) and (wpobjUsedPairwise in obj.Mode) and not first
            and (obj.ObjType in CheckedCodes) then
          begin
            if (wpobjIsClosing in obj.Mode) then inc(level)
            else if (wpobjIsOpening in obj.Mode) then
            begin
              if level > 0 then dec(level)
              else
              begin if List <> nil then List.Add(obj);
                if Result = nil then Result := obj;
                if (List = nil) or ((MaxCount > 0) and (List.Count >= MaxCount)) then exit;
              end;
            end;
          end;
          first := FALSE;
          dec(PosInPar);
        end;
      end;
      first := FALSE;
      par := par.prev;
      if par <> nil then PosInPar := par.CharCount;
    end;
  end;
end;

function TWPCustomRtfEdit.OpenCodesAtCP(List: TWPTextObjList; Code: TWPTextObjType): TWPTextObj;
begin
  Result := OpenCodes(nil, 0, List, [Code]);
end;

function TWPCustomRtfEdit.OpenCodeAt(par: TParagraph; PosInPar: Integer;
  CheckedCodes: TWPTextObjTypes): TWPTextObj;
begin
  Result := OpenCodes(par, posinpar, nil, CheckedCodes);
end;

function TWPCustomRtfEdit.OpenCodeAt(x, y: Integer;
  CheckedCodes: TWPTextObjTypes): TWPTextObj;
begin
  Result := OpenCodes(x, y, nil, CheckedCodes);
end;

function TWPCustomRtfEdit.CodeListTags(Code: TWPTextObjType;
  AName: string = '*ALL*'; GlobalSearch: Boolean = FALSE): TWPTextObjList;
begin
  Result := TWPTextObjList.Create;
  try
    GetCodeTags(Result, Code, AName, GlobalSearch);
  except
    Result.Free;
    raise;
  end;
end;

function TWPCustomRtfEdit.GetCodeTags(List: TWPTextObjList; Code: TWPTextObjType;
  AName: string = '*ALL*'; GlobalSearch: Boolean = FALSE): Boolean;
var par: TParagraph;
  i, j: Integer;
  obj: TWPTextObj;
begin
  if GlobalSearch then par := Memo.RTFData.FirstPar
  else par := ActiveFirstPar;
  while par <> nil do
  begin
    if par.HasObjects(false, [Code]) then
      for i := 0 to par.CharCount do
      begin
        obj := par.ObjectRef[i];
        if (obj <> nil) and (obj.ObjType = Code) then
        begin
          if wpobjUsedPairwise in obj.Mode then
          begin
            if (wpobjIsOpening in obj.Mode) and
              ((AName = '*ALL*') or (CompareText(obj.Name, AName) = 0)) then
            begin
              List.Add(obj);
            end else if (wpobjIsClosing in obj.Mode) then
            begin
              j := List.IndexOfTagBackwards(obj.Tag);
              if j >= 0 then List.Closing[j] := obj;
            end;
          end else if (AName = '*ALL*') or (CompareText(obj.Name, AName) = 0) then List.Add(obj);
        end;
      end;
    if GlobalSearch then par := par.globalnext
    else par := par.next;
  end;
  Result := List.Count > 0;
end;

function TWPCustomRtfEdit.CodeExistInText(Code: TWPTextObjType; GlobalSearch: Boolean;
  StartPar: TParagraph = nil): Boolean;
begin
  Result := FALSE;
  if StartPar = nil then
  begin
    if GlobalSearch then
      StartPar := HeaderFooter.FirstPar
    else if (ActiveText <> nil) and not ActiveText.Empty then
      StartPar := ActiveText.FirstPar;
  end;
  while StartPar <> nil do
  begin
    if StartPar.HasObjects(false, [Code]) then // Found an object
    begin Result := TRUE;
      exit;
    end;
    if GlobalSearch then StartPar := StartPar.globalnext
    else StartPar := StartPar.next;
  end;
end;

function TWPCustomRtfEdit.CodeInsideOf(x, y: Integer; ObjType: TWPTextObjType): TWPTextObj;
var par: TParagraph; posinpar: Integer;
begin
  Result := CodeInsideOf(x, y, ObjType, par, posinpar);
end;

function TWPCustomRtfEdit.CodeInsideOf(x, y: Integer; ObjType: TWPTextObjType; var par: TParagraph; var pos_in_par: Integer): TWPTextObj;
var aRTFData: TWPRTFDataBlock;
  CurrPage: Integer;
  FrameBorder: TWPFrameBorder;
  FloatingImage: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
begin
  Result := nil;
  par := nil;
  if Memo.HasData then
  begin
    CurrPage := FMemo.GetPageAtXY(X, Y);
    FMemo.GetRTFPositionAtXY(CurrPage, X, Y, aRTFData,
      par, pos_in_par, FrameBorder, FloatingImage, SizerElement);
    if Par <> nil then
    begin
      Result := CodeInsideOf(par, pos_in_par, ObjType);
    end;
  end;
end;

function TWPCustomRtfEdit.CodeInsideOf(ObjType: TWPTextObjType): TWPTextObj;
begin
  Result := CodeInsideOf(ActiveParagraph, ActivePosInPar, ObjType);
end;

function TWPCustomRtfEdit.CodeInsideOf(par: TParagraph; posinpar: Integer;
  ObjType: TWPTextObjType): TWPTextObj;
var obj: TWPTextObj;
  level: Integer;
  first: Boolean;
begin
  Result := nil;
  level := 0;
  first := TRUE;

  // We "SIT" on the end onbect   -- V5.19.0
  if par <> nil then
  begin
    obj := par.ObjectRef[posinpar];
    if (obj <> nil) and (obj.ObjType = ObjType) and not (wpobjIsOpening in obj.Mode) then
    begin
      Result := obj.StartTag;
      if Result <> nil then exit;
    end;
  end;
  // aPar := par;
  // aposinpar := posinpar;
  try
    while par <> nil do
    begin
      if par.HasObjects(false, [ObjType]) then
      begin
        while posinpar >= 0 do
        begin
          obj := par.ObjectRef[posinpar];
          if (obj <> nil) and (obj.ObjType = ObjType) then
          begin
            if (wpobjIsClosing in obj.Mode) then inc(level) else
              if not first and (wpobjIsOpening in obj.Mode) then
              begin
                if level = 0 then
                begin
                  Result := obj;
                  exit;
                end else dec(level);
              end;
          end;
          first := FALSE;
          dec(posinpar);
        end;
      end;
      first := FALSE;
      par := par.prev;
      if par <> nil then posinpar := par.CharCount - 1;
    end;
  // We don't want to find it if we are sitting on it !
  finally
 //  if (Result<>nil) and
 //     (aPar.ObjectRef[aposinpar]=Result) then Result := nil;
  end;
end;



function TWPCustomRtfEdit.CodeMoveTo(const AName: string; Code: TWPTextObjType;
  CmpModes: TWPTextObjModes = [wpobjIsOpening];
  LocateOptions: TWPCodeLocateOptions = [wpCompareName]): Boolean;
var ResultPar: TParagraph;
  ResultPosInPar: Integer;
begin
  Result := CodeLocate(ResultPar, ResultPosInPar,
    AName, Code, CmpModes, LocateOptions);
  if Result then
  begin
    Memo.Cursor.MoveTo(ResultPar, ResultPosInPar);
     //not here: TextCursor.GetCharAttr;
  end;
end;

type
  TWPObjectRenameParam = class
  public
    ObjType: TWPTextObjType;
    OldName: string;
    NewName: string;
    CaseSensitive: Boolean;
    Count: Integer;
  end;

procedure LoopRenameObjects(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
var fp: TWPObjectRenameParam;
begin
  fp := TWPObjectRenameParam(param);
  if obj.ObjType = fp.ObjType then
  begin
    if fp.CaseSensitive then
    begin
      if obj.Name = fp.OldName then
      begin
        obj.Name := fp.NewName;
        inc(fp.Count);
      end;
    end else
    begin
      if CompareText(obj.Name, fp.OldName) = 0 then
      begin
        obj.Name := fp.NewName;
        inc(fp.Count);
      end;
    end;
  end;
end;

function TWPCustomRtfEdit.CodeRename(ObjType: TWPTextObjType; OldName, NewName: string; FromAllBlocks: Boolean = TRUE;
  CaseSensitive: Boolean = TRUE): Integer;
var param: TWPObjectRenameParam;
begin
  param := TWPObjectRenameParam.Create;
  try
    param.ObjType := ObjType;
    param.OldName := OldName;
    param.NewName := NewName;
    param.CaseSensitive := CaseSensitive;
    param.Count := 0;
    if FromAllBlocks then Memo.RTFData.LoopAllObj(param, LoopRenameObjects, nil)
    else Memo.RTFData.LoopAllObj(param, LoopRenameObjects, Memo.DisplayedText);
    Result := param.Count;
    if Result > 0 then SaveChanging;
  finally
    param.Free;
  end;
end;

function TWPCustomRtfEdit.CodeLocate(
  var ResultPar: TParagraph;
  var ResultPosInPar: Integer;
  const AName: string; Code: TWPTextObjType;
  CmpModes: TWPTextObjModes = [wpobjIsOpening];
  LocateOptions: TWPCodeLocateOptions = [wpCompareName];
  CmpStr2: string = ''): Boolean;
var par: TParagraph;
  i: Integer;
  obj: TWPTextObj;
  found: Boolean;
begin
  i := 0;
  ResultPar := nil;
  ResultPosInPar := 0;
  if (wpStartAtCursorPosition in LocateOptions) and (Memo.Cursor.active_paragraph <> nil) then
  begin
    par := Memo.Cursor.active_paragraph;
    i := Memo.Cursor.active_posinpar;
  end else
    if (wpGlobalSearch in LocateOptions) then par := Memo.RTFData.FirstPar
    else par := ActiveFirstPar;
  Result := FALSE;

  while par <> nil do
  begin
    if par.HasObjects(false, [Code]) then
    begin
      while i < par.CharCount do
      begin
        obj := par.ObjectRef[i];
        if (obj <> nil) and
          ((CmpModes = []) or ((CmpModes * obj.Mode) <> []))
          then
        begin
          if (wpCompareName in LocateOptions) and
            (wpCompareSource in LocateOptions) then
            found := (CompareText(obj.Name, AName) = 0) and
              (CompareText(obj.Source, CmpStr2) = 0)
          else if wpCompareName in LocateOptions then
            found := CompareText(obj.Name, AName) = 0
          else if wpCompareSource in LocateOptions then
            found := CompareText(obj.Source, AName) = 0
          else found := TRUE;


          if found then
          begin
            ResultPar := par;
            ResultPosInPar := i;
            Result := TRUE;
            exit;
          end;
        end;
        inc(i);
      end;
    end;
    i := 0;
    if (wpGlobalSearch in LocateOptions) then par := par.globalnext
    else par := par.next;
  end;
end;


function TWPCustomRtfEdit.CodeSelect(const AName: string; Code: TWPTextObjType;
  OnlyText: Boolean = FALSE; StopAtParEnd: Boolean = FALSE;
  LocateOptions: TWPCodeLocateOptions = [wpCompareName]): Boolean;
var par, endp: TParagraph;
  i, start_i, startindex, endindex: Integer;
  obj: TWPTextObj;
begin
  start_i := 0;
  if (wpStartAtCursorPosition in LocateOptions) and (Memo.Cursor.active_paragraph <> nil) then
  begin
    par := Memo.Cursor.active_paragraph;
    start_i := Memo.Cursor.active_posinpar;
  end else
    if (wpGlobalSearch in LocateOptions) then par := Memo.RTFData.FirstPar
    else par := ActiveFirstPar;
  Result := FALSE;
  while par <> nil do
  begin
    if par.HasObjects(false, [Code]) then
      for i := start_i to par.CharCount do
      begin
        obj := par.ObjectRef[i];
        if (obj <> nil) and
          (wpobjUsedPairwise in obj.Mode) and
          (wpobjIsOpening in obj.Mode) and
          (obj.ObjType = Code) and
          (not (wpCompareName in LocateOptions)
          or (CompareText(obj.Name, AName) = 0)) and
          (not (wpCompareSource in LocateOptions)
          or (CompareText(obj.Source, AName) = 0)) and
          (not (wpCompareParams in LocateOptions)
          or (CompareText(obj.Params, AName) = 0)) then
        begin
          endindex := i;
          endp := obj.GetEndTag(par, endindex);
          if StopAtParEnd and (endp <> par) then
          begin
            endp := par;
            endindex := par.CharCount;
          end else
            if not OnlyText then inc(endindex);
          if OnlyText then startindex := i + 1 else startindex := i;
          if endp <> nil then
          begin
            Memo.Cursor.SelectFromHere(par, startindex);
            Memo.Cursor.SelectToHere(endp, endindex);
            Result := TRUE;
            exit;
          end;
        end;
      end;
    if (wpGlobalSearch in LocateOptions) then par := par.globalnext
    else par := par.next;
    start_i := 0;
  end;
end;

function TWPCustomRtfEdit.CodeSelectText(StartTag: TWPTextObj; IncludingTags: Boolean = FALSE): Boolean;
var endtag: TWPTextObj;
begin
  Result := FALSE;
  if (StartTag <> nil) then
  begin
    if wpobjIsClosing in StartTag.Mode then
    begin
      endtag := StartTag;
      StartTag := StartTag.StartTag;
      if StartTag = nil then exit;
    end
    else endtag := StartTag.EndTag;

    if endtag <> nil then
    begin
      if IncludingTags then
      begin
        TextCursor.SelectFromHere(StartTag.ParentPar, StartTag.ParentPosInPar);
        Result := TextCursor.SelectToHere(endtag.ParentPar, endtag.ParentPosInPar + 1);
      end else
      begin
        TextCursor.SelectFromHere(StartTag.ParentPar, StartTag.ParentPosInPar + 1);
        Result := TextCursor.SelectToHere(endtag.ParentPar, endtag.ParentPosInPar);
      end;
    end;
  end;
end;

function TWPCustomRtfEdit.CodeObjectAtXY(x, y: Integer; var Code: TWPTextObj): Boolean;
var aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par, CurrPage: Integer;
  FrameBorder: TWPFrameBorder;
  FloatingImage: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
begin
  Result := FALSE;
  Code := nil;
  if Memo.HasData then
  begin
    CurrPage := FMemo.GetPageAtXY(X, Y);
    FMemo.GetRTFPositionAtXY(CurrPage, X, Y, aRTFData,
      par, pos_in_par, FrameBorder, FloatingImage, SizerElement);
    if Par <> nil then
    begin
      Code := par.ObjectRef[pos_in_par];
      Result := (Code <> nil) and
        not (wpobjRelativeToParagraph in Code.Mode) and
        not (wpobjRelativeToPage in Code.Mode);
    end;
  end;
end;

function TWPCustomRtfEdit.InputCode(Code: TWPTextObjType; const AName: string = '';
  const command: string = ''; Options: TWPInputCodeOptions = []): TWPTextObj;
var closing: TWPTextObj;
  spar, epar: TParagraph;
  sposinpar, eposinpar: Integer;
  bSelText: Boolean;
begin
  bSelText := FALSE;
  try
    Changing;
    StartUndolevel;
    Memo.DisableProtection;
    if not CheckHasBody then Result := nil else
      with Memo.RTFData do
      try
        if (wpinpDeleteSelectedText in Options) and IsSelected then
        begin
          spar := Cursor.GetBlockStart(sposinpar);
          epar := spar;
          eposinpar := sposinpar;
          Cursor.ClearSelection(true, true, true);
        end else
          if (wpinpWrapSelectedText in Options) and IsSelected then
          begin
            spar := Cursor.GetBlockStart(sposinpar);
            epar := Cursor.GetBlockEnd(eposinpar);
            bSelText := TRUE;
            Cursor.active_paragraph := spar;
            Cursor.active_posinpar := sposinpar;
            HideSelection;
          end else
          begin
            spar := Cursor.active_paragraph;
            sposinpar := Cursor.active_posinpar;
            epar := spar;
            eposinpar := sposinpar;
          end;
        Result := TextObjects.InsertClass('', 0, 0, wpobjOpening, spar, sposinpar);
        if spar = epar then inc(eposinpar);
        if Result <> nil then
        begin
          Result._SetObjType(Code);
          Result.Name := AName;
          Result.Source := Command;
          closing := TextObjects.InsertClass('', 0, 0, wpobjClosing, epar, eposinpar);
          inc(eposinpar);
          if closing <> nil then
          begin
            closing._SetObjType(Code);
            closing.Name := AName;
            closing.SetTag(Result.NewTag); // Build a pair !
          end;
        end;

        _InputCodeMarker := 0;

        if wpinpDropMarkersOutside in Options then
        begin
          Memo.Cursor.DropMarkerAt(spar, sposinpar);
          _InputCodeMarker := Memo.Cursor.DropMarkerAt(epar, eposinpar);
        end;

        if wpinpDropMarkersInside in Options then
        begin
          Memo.Cursor.DropMarkerAt(spar, sposinpar + 1);
          _InputCodeMarker := Memo.Cursor.DropMarkerAt(epar, eposinpar - 1);
        end;

        if wpinpPlaceCursorAfterStart in Options then
          Cursor.MoveTo(spar, sposinpar + 1) else
          Cursor.MoveTo(epar, eposinpar);

        if bSelText then
        begin
          Cursor.SelectFromHere(spar, sposinpar + 1);
          Cursor.SelectToHere(epar, eposinpar - 1);
        end;
      finally
        DelayedReformat;
      end;
  finally
    EndUndolevel;
    Memo.EnableProtection;
    ChangeApplied;
  end;
end;


function TWPCustomRtfEdit.InputSingleCode(Code: TWPTextObjType;
  const AName: string = ''; const Command: string = ''): TWPTextObj;
begin
  if not CheckHasBody then Result := nil else
  begin
    Changing;
    with Memo.RTFData.TextObjects do
    begin
      Result := InsertClass('', 0, 0, wpobjSingle, nil, 0);
      if Result <> nil then
      begin
        Result._SetObjType(Code);
        Result.Name := AName;
        Result.Source := Command;
      end;
    end;
    ChangeApplied;
  end;
end;

//##############################################################################
//######## Footnote support ####################################################
//##############################################################################


function TWPCustomRtfEdit.InputFootnote(InitText: string = #32;
  Mode: TWPInputFootnoteModes = []): TWPTextObj;
begin
{$IFDEF WPPREMIUM}
   { ------------------------------------------
     If you have purchased WPTools PREMIUM and
     still get a compiler error in the following
     line please check if the WPTools Premium
     RTF-Engine files (WPRTFEDefs and WPRTEPaint)
     have been copied to the WPTools directory
     ------------------------------------------ }
  Changing;
  Result := FMemo.InputFootnote(InitText, Mode);
  ChangeApplied;
{$ELSE}
  Result := FootNoteInsert('#', 0, InitText);
  // raise Exception.Create('InputFootnote() is available in WPTools PREMIUM only!');
{$ENDIF}
end;

function TWPCustomRtfEdit.InputFootnote(PlaceCursor: Boolean; CreateNumber: Boolean = TRUE;
  InitText: string = #32): TWPTextObj;
var Mode: TWPInputFootnoteModes;
begin
  Mode := [];
  if CreateNumber then include(Mode, wpCreateNumberInFootnote);
  if PlaceCursor then include(Mode, wpPlaceCursorInFootnote);
  Result := InputFootnote(InitText, Mode);
end;

function TWPCustomRtfEdit.FootNoteInsert(C: Char; nr: Integer; const str: string): TWPTextObj;
begin
  Changing;
  Result := InputSingleCode(wpobjFootnote, '');
  if Result <> nil then
  begin
    Result.Name := '';
    Result.Params := C;
    Result.Source := str;
    Result.Initialize;
    ChangeApplied;
  end;
end;

function TWPCustomRtfEdit.FootNoteInsert(nr: Integer; const str: string): TWPTextObj;
begin
  Changing;
  Result := InputSingleCode(wpobjFootnote, '');
  if Result <> nil then
  begin
    Result.Name := '';
    Result.Params := '';
    Result.Source := str;
    Result.Initialize;
    ChangeApplied;
  end;
end;

{function TWPCustomRtfEdit.FootNoteGet(var tag: Integer; var nr: Integer; var str: string;
  Format: string = 'ANSI'): TWPTextObj;
begin
end;}

function TWPCustomRtfEdit.FootNoteAtCP: TWPTextObj;
begin
  Result := TextCursor.ObjAtCP;
  if (Result <> nil) and (Result.ObjType <> wpobjFootnote) then
    Result := nil;
end;

function TWPCustomRtfEdit.FootnoteFindNext: Boolean;
var marker: Integer;
  obj: TWPTextObj;
begin
  with TextCursor do
  begin
    marker := DropMarker;
    while MoveNext(1) do
    begin
      obj := ObjAtCP;
      if (obj <> nil) and (obj.ObjType = wpobjFootnote) then
      begin
        Result := TRUE;
        CollectMarker(marker);
        exit;
      end;
    end;
    Result := FALSE;
    GotoMarker(true, marker);
  end;
end;

function TWPCustomRtfEdit.FootnoteFindPrior: Boolean;
var marker: Integer;
  obj: TWPTextObj;
begin
  with TextCursor do
  begin
    marker := DropMarker;
    while MoveBack(1) do
    begin
      obj := ObjAtCP;
      if (obj <> nil) and (obj.ObjType = wpobjFootnote) then
      begin
        Result := TRUE;
        CollectMarker(marker);
        exit;
      end;
    end;
    Result := FALSE;
    GotoMarker(true, marker);
  end;
end;

procedure LoopFootnotesA(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
begin
  if (obj.ObjType = wpobjFootnote) then
    TStrings(param).AddObject(obj.Name + '=' + obj.Source, obj);
end;

procedure TWPCustomRtfEdit.FootnoteGetList(list: TStrings; FromAllBlock: Boolean = FALSE);
begin
  List.Clear;
  if FromAllBlock then Memo.RTFData.LoopAllObj(List, LoopFootnotesA, nil)
  else Memo.RTFData.LoopAllObj(List, LoopFootnotesA, Memo.DisplayedText);
end;

procedure LoopFootnotesB(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
begin
  if (obj.ObjType = wpobjFootnote) then
    TWPTextObjList(param).Add(obj);
end;

procedure TWPCustomRtfEdit.FootnoteGetList(list: TWPTextObjList; FromAllBlock: Boolean = FALSE);
begin
  List.Clear;
  if FromAllBlock then Memo.RTFData.LoopAllObj(List, LoopFootnotesB, nil)
  else Memo.RTFData.LoopAllObj(List, LoopFootnotesB, Memo.DisplayedText);
end;

//##############################################################################
//######## Hyperlink support ###################################################
//##############################################################################

procedure TWPCustomRtfEdit.DeleteHyperlink(RemoveText: Boolean);
var hyp: TWPTextObj;
begin
  hyp := HyperlinkAtCP;
  if hyp <> nil then with TextCursor do
    begin
      ObjAtCP := hyp;
      if RemoveText then
      begin
        SelectText := TRUE;
        ObjAtCP := hyp.EndTag;
        CPMoveNext;
        ClearSelection(true, true, true);
      end else InputString(#127);
    end;
end;

function TWPCustomRtfEdit.HyperlinkConvertOldWPT3Links(OnlyIfHiddenTextWasFound: Boolean = FALSE): Integer;
var DoubleStart, HiddenEnd, DoubleEnd, mode: Integer;
  Yes: Boolean;
  url: string;
begin
  Result := 0;
  with TextCursor do
  begin
    Position := 0;
    SelectText := FALSE;
    repeat
      if (CurrentCharAttr.GetUnderlineMode(mode)) and (mode = WPUND_Double) then
      begin
        DoubleStart := DropMarker;
        repeat
          CurrentCharAttr.HasStyle(afsHidden, Yes);
          if CurrentCharAttr.HasAStyle(afsHidden)
            or not CurrentCharAttr.GetUnderlineMode(mode)
            or (mode <> WPUND_Double) then break;
        until not CPMoveNext;
        DoubleEnd := DropMarker;
        if not CurrentCharAttr.HasAStyle(afsHidden) then
        begin
          url := '';
        end
        else
        begin
          repeat
            if not CurrentCharAttr.HasAStyle(afsHidden) then break;
          until not CPMoveNext;
          HiddenEnd := DropMarker;
          SelectMarker(DoubleEnd, HiddenEnd);
          url := SelText;
          ClearSelection(true, true, false);
        end;
        if not OnlyIfHiddenTextWasFound or (url <> '') then
        begin
          SelectMarker(DoubleStart, DoubleEnd);
          InputCode(wpobjHyperlink, '', url, [wpinpWrapSelectedText]);
        end;
        GotoMarker(DoubleEnd);
        CollectAllMarker;
      end;
    until not CPMoveNext;
  end;
  if Result > 0 then ReformatAll;
end;

function TWPCustomRtfEdit.HyperlinkSelect(const URL: string; OnlyText: Boolean): Boolean; // finds and selects
begin
  Result := CodeSelect(URL, wpobjHyperlink, OnlyText, FALSE, [wpCompareSource]);
end;

function TWPCustomRtfEdit.HyperlinkMoveTo(const AName: string): Boolean; // locates and moves Cursor
begin
  Result := CodeMoveTo(AName, wpobjHyperlink, [wpobjIsOpening], [wpCompareSource]);
end;

function TWPCustomRtfEdit.InputHyperlink(link, URL: string): TWPTextObj;
begin
  HideSelection;
  Result := InputCode(wpobjHyperlink, '', URL, [wpinpWrapSelectedText, wpinpPlaceCursorAfterStart]);
  InputString(link);
  CPMoveNext;
end;

function TWPCustomRtfEdit.InputHyperlink(URL: string): TWPTextObj;
var b, a: TWPTextObj;
begin
  // We avoid the double insertion of hyperlinks
  b := TextCursor.ObjBeforeSelection;
  a := TextCursor.ObjAfterSelection;
  if (b <> nil) and (a <> nil) and
    (b.ObjType = wpobjHyperlink) and
    (a.ObjType = wpobjHyperlink) and
    (b.Tag = a.Tag) then
  begin
    b.Source := URL;
    a.Source := URL;
    Result := b;
  end
  else
    Result := InputCode(wpobjHyperlink, '', URL, [wpinpWrapSelectedText, wpinpPlaceCursorAfterStart]);
end;

function TWPCustomRtfEdit.ReadHyperlink(var link, stamp: string): Boolean;
var obj: TWPTextObj;
begin
  obj := OpenCodesAtCP(nil, wpobjHyperlink);
  if obj <> nil then
  begin
    link := obj.EmbeddedText;
    stamp := obj.Source;
    Result := TRUE;
  end else
  begin
    link := '';
    stamp := '';
    Result := FALSE;
  end;
end;

function TWPCustomRtfEdit.HyperlinkAtCP: TWPTextObj;
begin
  if Memo.HasData then
  begin
    // also check if the cursor is BEFORE the link!
    Result := TextCursor.ObjAtCP;
    if (Result <> nil) and (Result.ObjType = wpobjHyperlink) then
    begin
      if wpobjIsClosing in Result.Mode then
        Result := Result.StartTag;
      exit;
    end;
    Result := CodeInsideOf(Memo.Cursor.active_paragraph,
      Memo.Cursor.active_posinpar, wpobjHyperlink)
  end else Result := nil;
end;


//##############################################################################
//######## Bookmark Procedures #################################################
//##############################################################################

function TWPCustomRtfEdit.CreateTableOfContents(
  const AName: string = '';
  const BookMarkId: string = '_Toc';
  Mode: TWPCreateTableOfContentsMode = [];
  StopPar: PTParagraph = nil;
  const TitleText: string = '';
  FirstPar: PTParagraph = nil): Integer; // wptocRecreateAllBookmarks
var ResultPar: TParagraph;
  ResultPosInPar: Integer;
  bobj, bobje: TWPTextObj;
var s: WideString;
  outl, i: Integer;
  tocobje, tocobj, hyperobj, beobj: TWPTextObj;
  FNeedCr: Boolean;
  sty: TWPTextStyle;
  uniqueid: Cardinal;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure Process(par: TParagraph);
    procedure AppendParText;
    var i: Integer;
      c: WideChar;
    begin
      for i := 0 to par.CharCount - 1 do
      begin
        c := par.CharItem[i];
        if (Integer(c) > 9) and
          ((Integer(c) > 32) or (ActiveParagraph.CharCount > 0))
          then ActiveParagraph.AppendChar(c, 0);
      end;
    end;
  begin
    if (wptocUseParIsOutline in Mode) and
      ((par.AGetInherited(WPAT_ParIsOutline, outl)) and (outl > 0))
      then
    begin
      outl := 1;
        // If the paragraph uses a style we can use the number level
        // WPAT_ParIsOutline can come from style OR paragraph!
      sty := par.ABaseStyle;
      if (sty <> nil) and sty.AGet(WPAT_NumberLEVEL, i) and (i > 0) then
        outl := i;
      bobj := BookmarkFirstObjInPar(par);
      if (wptocCreateOutlineBookmarks in Mode) and (bobj = nil) then
      begin
        bobj := par.InsertNewObject(0, wpobjBookmark, true, false);
        bobj.Name := BookMarkId + IntToStr(uniqueid);
        inc(uniqueid);
        bobje := par.InsertNewObject(par.CharCount, wpobjBookmark, true, true);
        bobje.SetTag(bobj.NewTag);
      end;
    end else
      if not (wptocUseParIsOutline in Mode) then
        bobj := BookmarkFirstObjInPar(par)
      else bobj := nil;

    if (bobj <> nil) and ((BookMarkId = '') or (Pos(BookMarkId, bobj.Name) > 0)) then
    begin
      if FNeedCr then InputString(#13);
        // Create Hyperklink START
      if wptocCreateHyperlinks in Mode then
      begin
        hyperobj := InputNewObject(wpobjHyperlink);
        hyperobj.Source := bobj.Name;
        hyperobj.Mode := [wpobjUsedPairwise, wpobjIsOpening];
      end else hyperobj := nil;

      if wptocLocateTextAfterBookmark in Mode then
      begin
        par := par.NextPar;
        AppendParText;
      end else
           // This is the usual code which uses the embedded text
      begin
        s := bobj.EmbeddedText;
        InputString(s);
        beobj := bobj.EndTag;
        if beobj <> nil then par := beobj.ParentPar;
      end;
      inc(Result);
      InputString(#9);

      ActiveParagraph.ASet(WPAT_IndentLeft, (outl - 1) * 360);
      ActiveParagraph.ADel(WPAT_IndentFirst);

        // Create Hyperklink START
      if (hyperobj = nil) and (wptocCreateHyperlinkNumbers in Mode) then
      begin
        hyperobj := InputNewObject(wpobjHyperlink);
        hyperobj.Source := bobj.Name;
        hyperobj.Mode := [wpobjUsedPairwise, wpobjIsOpening];
      end;

      ActiveParagraph.TabstopAdd(Header.PageWidth -
        Header.LeftMargin - Header.RightMargin - 360, tkRight, tkDots);
      InputNewObject(wpobjReference).Name_Spaces := bobj.Name;

        // Create hyperlink closing
      if hyperobj <> nil then
        with InputNewObject(wpobjHyperlink) do
        begin
          hyperobj.CParam := WPHYPER_BOOKMARKLINK;
          SetTag(hyperobj.NewTag); // Link together
          Mode := [wpobjUsedPairwise, wpobjIsClosing];
        end;

        //NO: this would move after the closing field obj:
        // ActivePosInPar := ActiveParagraph.CharCount;
      FNeedCr := TRUE;
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var par, rpar, cpar: TParagraph;
begin
  Result := 0;
  uniqueid := GetTickCount;
{$IFDEF ALLOWUNDO}
  if wpActivateUndo in EditOptions then
  begin
    Memo.RTFData.UndoStreamStart(wputInsertObject);
    Memo.RTFData.UndoDisable;
  end;
{$ENDIF}
  try
    if CodeLocate(ResultPar, ResultPosInPar, WPTOC_FIELDNAME, wpobjMergefield,
      [wpobjIsOpening],
      [wpCompareName, wpCompareSource], AName) then
    begin
      ActiveParagraph := ResultPar;
      ActivePosInPar := ResultPosInPar;
      TextCursor.GetCharAttr;
      tocobj := nil;
    end else
    begin
      HideSelection;
      tocobj := InputSingleCode(wpobjMergeField, WPTOC_FIELDNAME, AName);
      tocobj.Mode := [wpobjUsedPairwise, wpobjIsOpening];
      ResultPar := ActiveParagraph;
      ResultPosInPar := ActivePosInPar;
    end;
  // -------------------------
    if (tocobj <> nil) or SelectFieldAtCP(false, true) then
    begin
      ClearSelection(true);
      ResultPar := ActiveParagraph;
      InputString(TitleText);
      FNeedCr := TitleText <> '';
      if FirstPar = nil then
        par := Self.FirstPar
      else par := FirstPar;
      while par <> nil do
      begin
        if (wptocAlsoProcessTables in Mode) and (par.ParagraphType = wpIsTable) then
        begin
          rpar := par.ChildPar;
          while rpar <> nil do
          begin
            cpar := rpar.ChildPar;
            while cpar <> nil do
            begin
              Process(cpar);
              cpar := cpar.NextPar;
            end;
            rpar := rpar.NextPar;
          end;
        end else Process(par);
        if par = StopPar then break;
        par := par.NextPar;
      end;
      if FNeedCr then InputString(#13);
      if tocobj <> nil then
      begin
        tocobje := InputSingleCode(wpobjMergeField, WPTOC_FIELDNAME, AName);
        tocobje.Mode := [wpobjUsedPairwise, wpobjIsClosing];
        tocobje.SetTag(tocobj.NewTag);
      end;

      ReformatAll(true);
    end;
  finally
{$IFDEF ALLOWUNDO}
    if wpActivateUndo in EditOptions then
    begin
      Memo.RTFData.UndoStreamEnd;
      Memo.RTFData.UndoEnable;
    end;
{$ENDIF}
  end;
end;



function TWPCustomRtfEdit.BookmarkSelect(const AName: string; OnlyText: Boolean): Boolean; // finds and selects
begin
  Result := CodeSelect(AName, wpobjBookmark, OnlyText, FALSE);
end;

function TWPCustomRtfEdit.BookmarkMoveTo(const AName: string; DoGlobalSearch: Boolean = FALSE): Boolean; // locates and moves Cursor
begin
  if DoGlobalSearch then
    Result := CodeMoveTo(AName, wpobjBookmark, [wpobjIsOpening], [wpCompareName, wpGlobalSearch])
  else Result := CodeMoveTo(AName, wpobjBookmark, [wpobjIsOpening], [wpCompareName]);
end;

function TWPCustomRtfEdit.BookmarkMoveToNext(const AName: string): Boolean; // locates and moves Cursor to next ..
begin
  Result := CodeMoveTo(AName, wpobjBookmark, [wpobjIsOpening], [wpCompareName, wpStartAtCursorPosition]);
end;

function TWPCustomRtfEdit.BookmarkFind(const AName: string; DoGlobalSearch: Boolean = FALSE): Integer; // locates and returns position (or -1 iof not found)
var par: TParagraph; i: Integer;
  opt: TWPCodeLocateOptions;
begin
  opt := [wpCompareName];
  if DoGlobalSearch then
    include(opt, wpGlobalSearch);
  if CodeLocate(par, i, AName, wpobjBookmark, [wpobjIsOpening], opt) then
    Result := Memo.DisplayedText.GetPosition(par, i)
  else Result := -1;
end;

function TWPCustomRtfEdit.BookmarkInput(const AName: string; PlaceCursorBetweenTags: Boolean = FALSE): TWPTextObj;
begin
  if PlaceCursorBetweenTags then
    Result := InputCode(wpobjBookmark, AName, '', [wpinpWrapSelectedText, wpinpPlaceCursorAfterStart])
  else Result := InputCode(wpobjBookmark, AName, '', [wpinpWrapSelectedText]);
end;

procedure TWPCustomRtfEdit.BookmarkDeleteAllMarkers;
begin
  BookmarkDeleteMarkers('*ALL*');
end;

procedure TWPCustomRtfEdit.BookmarkDeleteMarkers(const AName: string);
var List: TWPTextObjList;
  i: Integer;
  eobj: TWPTextObj;
  par1, par2: TParagraph;
begin
  List := TWPTextObjList.Create;

  try
    if GetCodeTags(List, wpobjBookmark, AName, true) then
      for i := 0 to List.Count - 1 do
      begin
        eobj := List[i].EndTag;
        if eobj <> nil then
        begin
          par1 := eobj.ParentPar;
          eobj.Free;
        end else par1 := nil;
        par2 := List[i].ParentPar;
        List[i].Free;
        if par1 = par2 then par1.DeleteMarkedChar
        else
        begin
          if par1 <> nil then par1.DeleteMarkedChar;
          if par2 <> nil then par2.DeleteMarkedChar;
        end;
      end;
    DelayedReformat;
  finally
    List.Free;
  end;
end;

procedure TWPCustomRtfEdit.BookmarkDelete(const AName: string; Marks, Text: Boolean);
begin
  if Text then
  begin
    if BookmarkSelect(AName, not Marks) then ClearSelection(true);
  end else
  begin
    BookmarkDeleteMarkers(AName);
  end;
end;

function TWPCustomRtfEdit.BookmarkDeleteInPar(const NameStart: string; par: TParagraph): Boolean;
var i: Integer;
  obj: TWPTextObj;
begin
  Result := FALSE;
  if (par <> nil) and (par.HasObjects(false, [wpobjBookmark])) then
    for i := par.CharCount - 1 downto 0 do
    begin
      obj := par.ObjectRef[i];
      if (obj <> nil) and (obj.ObjType = wpobjBookmark) and
        (Pos(Uppercase(NameStart), Uppercase(obj.Name)) = 1) then
      begin
        Result := TRUE;
        obj.Free;
      end;
    end;
  if Result then
  begin
    par.DeleteMarkedChar;
  end;
end;

procedure LoopBookmarksA(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
begin
  if (obj.ObjType = wpobjBookmark) and (wpobjIsOpening in obj.Mode) and
    (obj.Name <> '') then TStrings(param).AddObject(obj.Name, obj);
end;

procedure TWPCustomRtfEdit.BookmarkGetList(list: TStrings; FromAllBlock: Boolean = FALSE);
begin
  List.Clear;
  if FromAllBlock then Memo.RTFData.LoopAllObj(List, LoopBookmarksA, nil)
  else Memo.RTFData.LoopAllObj(List, LoopBookmarksA, Memo.DisplayedText);
end;

procedure TWPCustomRtfEdit.BookmarkGetList(list: TWPTextObjList; FromAllBlock: Boolean = FALSE);
begin
  List.Clear;
  GetCodeTags(list, wpobjBookmark, '*ALL*', FromAllBlock);
end;

function TWPCustomRtfEdit.BookmarkAtXY(x, y: Integer; var Bookmark: TWPTextObj): Boolean;
var aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par, CurrPage: Integer;
  FrameBorder: TWPFrameBorder;
  DummyObj: TWPTextObj;
  SizerElement: TWPPaintSizerRects;
begin
  Result := FALSE;
  Bookmark := nil;
  if Memo.HasData then
  begin
    CurrPage := FMemo.GetPageAtXY(X, Y);
    FMemo.GetRTFPositionAtXY(CurrPage, X, Y, aRTFData,
      par, pos_in_par, FrameBorder, DummyObj, SizerElement);
    if par <> nil then
    begin
      Bookmark := CodeInsideOf(par, pos_in_par, wpobjBookmark);
      Result := Bookmark <> nil;
    end;
  end;
end;

function TWPCustomRtfEdit.BookmarkAtCP: TWPTextObj;
begin
  if Memo.HasData then
    Result := CodeInsideOf(Memo.Cursor.active_paragraph, Memo.Cursor.active_posinpar, wpobjBookmark)
  else Result := nil;
end;

function TWPCustomRtfEdit.BookmarkFirstInPar(par: TParagraph): string;
var i: Integer;
  obj: TWPTextObj;
begin
  Result := '';
  if (par <> nil) and (par.HasObjects(false, [wpobjBookmark])) then
    for i := 0 to par.CharCount - 1 do
    begin
      obj := par.ObjectRef[i];
      if (obj <> nil) and (obj.ObjType = wpobjBookmark) and
        (wpobjIsOpening in obj.Mode) then
      begin
        Result := obj.Name;
        exit;
      end;
    end;
end;

function TWPCustomRtfEdit.BookmarkFirstObjInPar(par: TParagraph): TWPTextObj;
var i: Integer;
  obj: TWPTextObj;
begin
  Result := nil;
  if (par <> nil) and (par.HasObjects(false, [wpobjBookmark])) then
    for i := 0 to par.CharCount - 1 do
    begin
      obj := par.ObjectRef[i];
      if (obj <> nil) and (obj.ObjType = wpobjBookmark) and
        (wpobjIsOpening in obj.Mode) then
      begin
        Result := obj;
        exit;
      end;
    end;
end;


function TWPCustomRtfEdit.BookmarkAtParLin(par: TParagraph; pos_in_par: Integer): TWPTextObj;
begin
  if (par <> nil) then
  begin
    Result := par.ObjectRef[pos_in_par];
    if (Result <> nil) and (Result.ObjType <> wpobjBookmark) then Result := nil;
  end else Result := nil;
end;

function TWPCustomRtfEdit.BookmarkForceInPar(par: TParagraph; const frmstr: string): string;
var
  obj: TWPTextObj;
begin
  obj := BookmarkFirstObjInPar(par);
  if obj = nil then
  begin
    SelectParagraph;
    obj := BookmarkInput('', false);
    Result := Format(frmstr, [obj.Tag]);
    obj.Name := Result;
    HideSelection;
  end else Result := obj.Name;
end;

//##############################################################################
//######## Text Field stuff ####################################################
//##############################################################################

function TWPCustomRtfEdit.InputTextField(typ: TWPTextFieldType; FieldMask: string = ''): TWPTextObj;
begin
  Result := InputTextFieldName(WPTextFieldNames[typ], FieldMask);
end;

function TWPCustomRtfEdit.InputTextFieldName(const FieldName: string; FieldMask: string = ''): TWPTextObj;
begin
  Memo.RTFData.NewUndolevel;
  Result := TextObjects.InsertClass('', 0, 0, wpobjSingle);
  Result._SetObjType(wpobjTextObject);
  Result.Name := FieldName;
  Result.Source := FieldMask;
  // Result.Params := ... initial text!
end;

//##############################################################################
//######## Table Procedures ####################################################
//##############################################################################

function TWPCustomRtfEdit.GetTable: TParagraph;
begin
  Result := Memo.Cursor.active_paragraph;
  if Result <> nil then Result := Result.ParentTable;
end;

function TWPCustomRtfEdit.GetCell(rownr, colnr: Integer): TParagraph;
var tbl: TParagraph;
begin
  tbl := GetTable;
  if tbl <> nil then Result := tbl.GetCell(rownr, colnr)
  else Result := nil;
end;

function TWPCustomRtfEdit.GetTableCell: TParagraph;
begin
  Result := Memo.Cursor.active_paragraph;
  if Result <> nil then Result := Result.Cell;
end;

function TWPCustomRtfEdit.GetTableRow: TParagraph;
begin
  Result := Memo.Cursor.active_paragraph;
  if Result <> nil then Result := Result.ParentRow;
end;

procedure TWPCustomRtfEdit.SetTable(x: TParagraph);
begin
  if (x = nil) or (x.ParagraphType <> wpIsTable) then
    raise Exception.Create('Table expected in assignment!')
  else if x.RowFirst <> nil then SetTableRow(x.RowFirst)
  else SetActiveParagraph(x);
end;

procedure TWPCustomRtfEdit.SetTableRow(x: TParagraph);
begin
  if (x = nil) or (x.ParagraphType <> wpIsTableRow) then
    raise Exception.Create('Row expected in assignment!')
  else if x.ColFirst <> nil then SetTableRow(x.ColFirst)
  else SetActiveParagraph(x);
end;

procedure TWPCustomRtfEdit.SetTableCell(x: TParagraph);
begin
  if (x = nil) or not (paprIsTable in x.prop) then
    raise Exception.Create('Cell expected in assignment!')
  else SetActiveParagraph(x);
end;

function TWPCustomRtfEdit.InTable: Boolean;
begin
  Result := (GetTable <> nil);
end;

function TWPCustomRtfEdit.IsEmpty: Boolean;
var i: Integer;
  block: TWPRTFDataBlock;
begin
  Result := TRUE;
  if FMemo.HasData then
    for i := 0 to FMemo.RTFData.Count - 1 do
    begin
      block := FMemo.RTFData.Items[i];
      if (block.Kind in [wpIsHeader, wpIsFooter, wpIsBody
{$IFDEF KEEPFOOTNOTES}
        , wpIsFootnote, wpIsOwnerSelected
{$ENDIF}]) and
        not block.Empty then
      begin
        Result := FALSE;
        exit;
      end;
    end;
end;

function TWPCustomRtfEdit.IsFirstLine: Boolean;
begin
  if FMemo.HasData then
    Result := (ActiveParagraph.prev = nil) and (TextCursor.active_line = 0)
  else Result := TRUE;
end;

function TWPCustomRtfEdit.IsLastLine: Boolean;
begin
  if FMemo.HasData then
    Result := (ActiveParagraph.next = nil) and (TextCursor.active_line >= ActiveParagraph.LineCount - 1)
  else Result := TRUE;
end;

function TWPCustomRtfEdit.GetTableColCount: Integer;
var tpar: TParagraph;
begin
  tpar := GetTableRow;
  if tpar = nil then Result := -1
  else Result := tpar.ColCount;
end;

function TWPCustomRtfEdit.GetTableCellWidth: Integer;
var tpar: TParagraph;
begin
  tpar := GetTableCell;
  if tpar <> nil then
    Result := tpar._ActCellWidth
  else Result := 0;
end;

procedure TWPCustomRtfEdit.SetTableCellWidth(x: Integer);
var tpar: TParagraph;
begin
  tpar := GetTableCell;
  if tpar <> nil then
  begin
    tpar.ADel(WPAT_COLWIDTH_PC);
    tpar.ASet(WPAT_COLWIDTH, x);
  end;
end;

function TWPCustomRtfEdit.MoveToCell(Col, Row: Integer; TableName: string = ''): Boolean;
var tpar, cpar: TParagraph;
begin
  Result := FALSE;
  if TableName <> '' then
  begin
    tpar := Memo.RTFData.FindParByName(tablename, ActiveText);
    if (tpar <> nil) and (tpar.ParagraphType <> wpIsTable) then exit;
  end
  else tpar := GetTable;
  if tpar = nil then exit
  else
  begin
    cpar := tpar.Rows[Row];
    if cpar = nil then exit;
    cpar := cpar.Cols[Col];
    if cpar = nil then exit;
    Result := TextCursor.MoveTo(cpar, 0);
  end;
end;


function TWPCustomRtfEdit.GetTableColNumber: Integer;
var tpar: TParagraph;
begin
  tpar := GetTableCell;
  if tpar = nil then Result := -1
  else Result := tpar.ColNr;
end;

procedure TWPCustomRtfEdit.SetTableColNumber(ColumnNumber: Integer);
var tpar: TParagraph;
begin
  tpar := GetTableRow;
  if tpar <> nil then
  begin
    tpar := tpar.Cols[ColumnNumber];
    if tpar <> nil then SetActiveParagraph(tpar);
  end;
end;

function TWPCustomRtfEdit.GetTableRowCount: Integer;
var tpar: TParagraph;
begin
  tpar := GetTable;
  if tpar = nil then Result := -1
  else Result := tpar.RowCount;
end;

function TWPCustomRtfEdit.GetTableRowNumber: Integer;
var tpar: TParagraph;
begin
  tpar := GetTableRow;
  if tpar = nil then Result := -1
  else Result := tpar.RowNr;
end;

procedure TWPCustomRtfEdit.SetTableRowNumber(RowNumber: Integer);
var tpar: TParagraph;
begin
  tpar := GetTable;
  if tpar <> nil then
  begin
    tpar := tpar.Rows[RowNumber];
    if tpar <> nil then SetActiveParagraph(tpar.ColFirst);
  end;
end;

procedure TWPCustomRtfEdit.TableFixAllCellWidths(SnapValue: Integer = 0);
var par: TParagraph;
  b: Boolean;
begin
  par := HeaderFooter.FirstPar;
  b := FALSE;
  while par <> nil do
  begin
    if par.ParagraphType = wpIsTable then
    begin
      par.FixAllCellWidths(SnapValue);
      b := TRUE;
    end;
    par := par.next;
  end;
  if b then DelayedReformat;
end;

procedure TWPCustomRtfEdit.TableMakeCellWidthPC;
var par: TParagraph;
  b: Boolean;
begin
  par := HeaderFooter.FirstPar;
  b := FALSE;
  while par <> nil do
  begin
    if par.ParagraphType = wpIsTable then
    begin
      par.FixAllRightCellWidths(true, 0, true);
      b := TRUE;
    end;
    par := par.next;
  end;
  if b then DelayedReformat;
end;

procedure TWPCustomRtfEdit.TableAdjustCellWidth(MinimumRightMargin: Integer = 0);
var par: TParagraph;
  l, w, r: Integer;
  sect: TWPRTFSectionProps;
  b: Boolean;
begin
  par := HeaderFooter.FirstPar;
  b := FALSE;
  while par <> nil do
  begin
    if par.ParagraphType = wpIsTable then
    begin
      l := par.AGetDef(WPAT_BoxMarginLeft, 0);
      sect := HeaderFooter.GetPageProps(par);
      if par.AGet(WPAT_BoxWidth, w) then
      begin
        r := sect.LeftMargin + l + w;
        if sect.PageWidth - r < MinimumRightMargin then
        begin
          w := sect.PageWidth - (sect.LeftMargin + l);
          par.ASet(WPAT_BoxWidth, w);
        end;
      end else w := sect.PageWidth - sect.RightMargin - (sect.LeftMargin + l);
      par.FixAllRightCellWidths(true, w, false);
      b := TRUE;
    end;
    par := par.next;
  end;
  if b then DelayedReformat;
end;

procedure TWPCustomRtfEdit.BeginTable(const tablename: string; trgap, l, r: Integer);
begin
  FBeginTable := TRUE;
  FBeginTableName := tablename;
  FBeginTableGR := trgap;
  FBeginTableL := L;
  FBeginTableR := R;
  FBeginTableCreate := TRUE;
end;

function TWPCustomRtfEdit.MoveToTable(const tablename: string): Boolean;
var par: TParagraph;
begin
  par := Memo.RTFData.FindParByName(tablename, ActiveText);
  if par <> nil then
  begin
    Memo.Cursor.MoveTo(par, 0);
    TextCursor.GetCharAttr;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.FindTable(const tablename: string): TParagraph;
begin
  Result := Memo.RTFData.FindParByName(tablename, ActiveText);
end;

function TWPCustomRtfEdit.FindParWithText(const searchtext: string): TParagraph;
begin
  Result := Memo.RTFData.FindParWithText(searchtext, ActiveText);
end;

procedure TWPCustomRtfEdit.EndTable;
begin
  FBeginTable := FALSE;
  FBeginTableName := '';
  FBeginTableGR := 0;
  FBeginTableL := 0;
  FBeginTableR := 0;
  FBeginTableCreate := FALSE;
end;

procedure TWPCustomRtfEdit.AddTable(colcount, lincount: integer; Border: Boolean = TRUE);
var sty: TWPTextStyle;
  i, j: Integer;
begin
  sty := TWPTextStyle.Create(Memo.RTFData.RTFProps); //V5.13 - use the props of the current paragraph
  try
    sty.Assign(ActiveParagraph);
    sty.ADelAllIn([WPAT_COLWIDTH_PC, WPAT_COLWIDTH]);
  // This can cause the cell to be far too narrow  - V5.13.5
    if sty.AGet(WPAT_IndentLeft, i) then
    begin
      if i > 360 then
      begin
        sty.ASet(WPAT_IndentLeft, 360);
        i := 360;
      end;
    end else i := 0;
    if sty.AGet(WPAT_IndentFirst, j) then
    begin
      if (j < -i) then
      begin
        sty.ASet(WPAT_IndentFirst, -i)
      end else if j > 360 then sty.ASet(WPAT_IndentFirst, 360);
    end;

  // Make the right indent the left indent at the most
    if sty.AGet(WPAT_IndentRight, j) and (j > i) then
      sty.ASet(WPAT_IndentRight, i);

    if Border then
      TableAdd(colcount, lincount, [wptblActivateBorders, wptblPlaceCursorInLastCell], sty)
    else TableAdd(colcount, lincount, [wptblPlaceCursorInLastCell], sty);
  finally
    sty.Free;
  end;
end;

procedure TWPCustomRtfEdit.CheckActiveText;
begin
  if ActiveText = nil then
    raise EWPToolsProgError.Create(
      'Undefined ActiveText - please use CheckHasBody()');
end;

procedure TWPCustomRtfEdit.SetInWaitForPaintEditor(x: Boolean);
begin
  FInWaitForPaintEditor := x;
{$IFDEF USETIMER}
  if not x and (FTimerHandle <> 0) then
  begin
    KillTimer(FTimerWinHandle, FTimerHandle);
    FTimerHandle := 0;
  end;
{$ENDIF}
end;

function TWPCustomRtfEdit.TableAdd(
  ColCount, RowCount: Integer;
  Options: TWPTableAddOptions = [];
  StyleForNewCells: TWPTextStyle = nil;
  CallBackForText: TWPTableAddCellEvent = nil): TParagraph;
var wptable, afterpar, par, cell: TParagraph;
  wprowstyle: TWPTableRowStyle;
  i, w, tw, c, rownr, isFooter, isHeader: Integer;
  CreatedAtEnd: Boolean;
  loadca: Cardinal;
begin
  CheckActiveText;
  Result := nil;
  cell := nil;
  if RowCount <= 0 then exit;
  if ColCount <= 0 then ColCount := 1;

{$IFDEF ALLOWUNDO}
  if (wpActivateUndo in EditOptions) then
  begin
    HeaderFooter.StartUndolevel;
    HeaderFooter.UndoBufferSaveTo(nil, wpuStoreCursorPos, wputInput);
  end;
{$ENDIF}


  if wptblAppendTableAtEnd in Options then
  begin
    par := ActiveText.AppendNewPar(true);
    wptable := par;
    wptable.ParagraphType := wpIsTable;
    afterpar := nil;
    if FBeginTable then
      wptable.Name := FBeginTableName;
  end else
  begin
    par := ActiveParagraph;

    if FBeginTable and FBeginTableCreate then
    begin
      if (par.CharCount = 0) and
        (par.ParagraphType = wpIsSTDPar) and
        not par.HasChildren then
      begin
        if paprIsTable in par.prop then
          par := par.AppendChild(nil);
        wptable := par;
        wptable.ParagraphType := wpIsTable;
      end
      else wptable := TParagraph.CreateTable(par);
      // make sure the table does not use some properties which would be then
      // inherited
      wptable.ADelAllFromTo(WPAT_FirstCharAttr, WPAT_LastCopiedParProp); //V5.13
      FBeginTableCreate := FALSE;
      wptable.Name := FBeginTableName;
      afterpar := nil;
    end else
      if not (wptblAllowNestedTables in Options) then
      begin
        wptable := GetTable;
        afterpar := GetTableRow;
      end else
      begin
        wptable := nil;
        afterpar := nil;
      end;

    if wptable = nil then
    begin
      if FMemo.Cursor.active_posinpar < par.CharCount then
        par.SplitAt(FMemo.Cursor.active_posinpar, wpActivateUndo in EditOptions);
      if (par.CharCount = 0) and
        (par.ParagraphType = wpIsSTDPar) and
        not par.HasChildren then
      begin
        if paprIsTable in par.prop then
        begin
          par.ChildPar := TParagraph.Create(par.RTFData);
          par := par.ChildPar;
        end;
        wptable := par;
        wptable.ParagraphType := wpIsTable;
      end
      else wptable := TParagraph.CreateTable(par);
      wptable.ADelAllFromTo(WPAT_FirstCharAttr, WPAT_LastCopiedParProp); //V5.13
    end;

  end;

{$IFDEF ALLOWUNDO}
  if (wpActivateUndo in EditOptions) then
    FMemo.RTFData.UndoBufferSaveTo(
      wptable, wpuDeletePar, wputChangeTable);
{$ENDIF}

  if wptblCreateHeaderRow in Options then
  begin
    inc(RowCount);
    isHeader := 1;
  end else isHeader := 0;

  if wptblCreateFooterRow in Options then
  begin
    inc(RowCount);
    isFooter := RowCount;
  end else isFooter := 0;

  CreatedAtEnd := (afterpar = nil) or (afterpar.NextPar = nil);
  loadca := WritingAttr.CharAttr;
  for i := 1 to RowCount do
  begin
    // Create at end if afterpar=nil:
    wprowstyle := wptable.CreateRow(afterpar, afterpar = nil);
    wprowstyle.Assign(StyleForNewCells);

    if wptblActivateBorders in Options then
    begin
      wprowstyle.ASet(WPAT_BorderFlags, WPBRD_DRAW_Left + WPBRD_DRAW_Top);
      wprowstyle.ASet(WPAT_BorderWidth, 10);
      if (i = RowCount) and CreatedAtEnd then
        wprowstyle.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Bottom)
      else wprowstyle.ASetDel(WPAT_BorderFlags, WPBRD_DRAW_Bottom);
    end;
    try

      if i = isHeader then rownr := -1
      else if i = isFooter then rownr := -2
      else rownr := i - isHeader;
      w := 10000 div ColCount;
      tw := 0;
      for c := 1 to ColCount do
      begin
        cell := wprowstyle.InputCell;
        if Result = nil then Result := cell;
        if c = ColCount then w := 10000 - tw;
        with cell do
        begin
          // AnsiText := IntToStr(i);
          // ASetColor(WPAT_BGColor, clRed);
          ADel(WPAT_COLWIDTH);
          ASet(WPAT_COLWIDTH_PC, w);

          if not (wptblDontApplyWritingAttr in Options) then
            cell.LoadedCharAttr := loadca;

          inc(tw, w);

          if (wptblActivateBorders in Options) then
          begin
            if c = ColCount then
              cell.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Right)
            else cell.ASetDel(WPAT_BorderFlags, WPBRD_DRAW_Right);
          end;
        end;

        if assigned(CallBackForText) then CallBackForText(rownr, c, cell);
      end;
    finally
      afterpar := wptable.EndRow(wprowstyle);
      if i = isHeader then include(afterpar.prop, paprIsHeader)
      else if i = isFooter then include(afterpar.prop, paprIsFooter);
    end;
  end;

  if wptblAppendTableAtEnd in Options then
    Result := wptable
  else
    if (cell <> nil) and (wptblPlaceCursorInLastCell in Options) then
    begin
      TextCursor.MoveTo(cell, 0);
      TextCursor.GetCharAttr;
    end;

{$IFDEF ALLOWUNDO}
  if (wpActivateUndo in EditOptions) then
  begin
    HeaderFooter.EndUndolevel;
  end;
{$ENDIF}

  DelayedReformat;
end;

//##############################################################################
//######## CP Properties #######################################################
//##############################################################################

function TWPCustomRtfEdit.GetActivePosInPar: Integer;
begin
  Result := Memo.Cursor.active_posinpar;
end;

procedure TWPCustomRtfEdit.SetActivePosInPar(x: Integer);
begin
  Memo.Cursor.MoveTo(Memo.Cursor.active_paragraph, x);
end;

function TWPCustomRtfEdit.GetActiveLineStart: Integer;
begin
  with Memo.Cursor do
  begin
    Result := active_paragraph.LineOffset(active_line);
  end;
end;

function TWPCustomRtfEdit.GetActiveLineLen: Integer;
begin
  with Memo.Cursor do
  begin
    Result := active_paragraph.LineLength(active_line);
  end;
end;

function TWPCustomRtfEdit.GetActiveStyleName: string;
var i: Integer;
  sty: TWPTextStyle;
  Cursor: TWPRTFDataCursor;
begin
  Result := '';
  Cursor := TextCursor;
  if Cursor.IsSelected then
    i := Cursor.SelectedTextAttr.GetStyle
  else if Cursor.active_paragraph <> nil then
  begin
    Result := Cursor.active_paragraph.ABaseStyleName;
    exit;
  end
  else i := Cursor.WritingTextAttr.GetStyle;
  if i > 0 then
  begin
    sty := Cursor.RTFProps.ParStyles.GetTextStyle(i);
    if sty <> nil then
      Result := sty.Name;
  end;
end;

procedure TWPCustomRtfEdit.SetActiveStyleName(const x: string);
var sty: TWPRTFStyleElement;
  i: Integer;
  Cursor: TWPRTFDataCursor;
begin
  HeaderFooter.AlwaysNewUndolevel;
  Cursor := TextCursor;
  if x <> '' then
    sty := Cursor.RTFProps.ParStyles.Add(x)
  else sty := nil;
  if sty <> nil then i := sty.ID else i := 0;
  if Cursor.IsSelected then
  begin
    Cursor.SelectedTextAttr.SetStyle(i,
      wpClearAttrOnStyleChange in EditOptions, wpClearAttrOnStyleChange in EditOptions);
  end
  else
  begin
    if x = '' then Cursor.GetCharAttr
    else
    begin
      Cursor.WritingTextAttr.ClearAttr(true, true);
      Memo.RTFData.DefaultAttr.Clear;
    end;
    Cursor.LockGetCharAttr(true);

    Cursor.WritingTextAttr.SetStyle(i, wpClearAttrOnStyleChange in EditOptions, wpClearAttrOnStyleChange in EditOptions);
  end;
  DoUpdateParAttr;
  if assigned(FOnChangeCursorPos) then
    FOnChangeCursorPos(Self);
end;


function TWPCustomRtfEdit.GetActiveParagraph: TParagraph;
begin
  if CheckHasBody then
    Result := Memo.Cursor.active_paragraph
  else Result := nil;
end;

function TWPCustomRtfEdit.ActivePar: TParagraph;
begin
  Result := Memo.Cursor.active_paragraph;
  if Result = nil then
  begin
    CheckHasBody;
    Result := Memo.Cursor.active_paragraph;
    if Result = nil then
      raise EWPToolsProgError.Create('The ActiveParagraph has not been set. Please use CPPosition');
  end;
end;

function TWPCustomRtfEdit.InsertPar: TParagraph;
begin
  Result := Memo.Cursor.active_paragraph;
  if Result = nil then
  begin
    CheckHasBody;
    Result := Memo.Cursor.active_paragraph;
    if Result = nil then
      raise Exception.Create('The ActiveParagraph has not been set. Please use CPPosition');
  end else
  begin
    Result := Result.SplitAt(Memo.Cursor.active_posinpar, false);
    if Result.CharCount > 0 then Result.SplitAt(0);
  end;
end;

procedure TWPCustomRtfEdit.SetActiveParagraph(x: TParagraph);
begin
  Memo.Cursor.active_paragraph := x;
end;

function TWPCustomRtfEdit.GetFirstParagraph: TParagraph;
begin
  if CheckHasBody then
    Result := Memo.FirstPar
  else if FMemo.HasData then
    Result := Memo.FirstPar
  else Result := nil;
end;

function TWPCustomRtfEdit.GetLastParagraph: TParagraph;
begin
  if CheckHasBody then Result := Memo.FirstPar
  else if FMemo.HasData then Result := Memo.FirstPar
  else Result := nil;
  if Result <> nil then
    while Result.NextPar <> nil do Result := Result.NextPar;
end;

function TWPCustomRtfEdit.GetActiveFirstPar: TParagraph;
begin
  if (ActiveText <> nil) and not ActiveText.Empty then
    Result := ActiveText.FirstPar
  else Result := nil;
end;

procedure TWPCustomRtfEdit.SetCPPosition(x: Integer);
begin
  if (FMemo.Cursor.RTFData <> nil) and
    (FMemo.Cursor.active_paragraph = nil) then
  begin
    FMemo.Cursor.active_paragraph
      := FMemo.Cursor.RTFData.FirstPar;
    FMemo.Cursor.active_posinpar := 0;
  end;

  if CheckHasBody then with FMemo.Cursor do
    begin
      if RTFData = nil then RTFData := FMemo.DisplayedText;
      SelectText := FALSE;
      Position := x;
      GetCharAttr;
    end;
end;

function TWPCustomRtfEdit.GetCPPosition: Integer;
begin
  Result := FMemo.Cursor.Position;
end;

function TWPCustomRtfEdit.GetSelStart: Integer;
begin
  if FMemo.Cursor.IsSelected then
    Result := FMemo.Cursor.SelStart
  else Result := GetCPPosition;
  FSelStart := Result;
end;

function TWPCustomRtfEdit.GetSelLength: Integer;
begin
  Result := FMemo.Cursor.SelLength;
end;

procedure TWPCustomRtfEdit.SetSelStart(x: Integer);
begin
  FSelStart := x;
  CPPosition := x;
end;

procedure TWPCustomRtfEdit.SetSelLength(x: Integer);
begin
  if IsSelected and (x = 0) then
    HideSelection
  else
  begin
    FMemo.Cursor.SetSelPosLen(FSelStart, x);
    CPPosition := FSelStart + x;
  end;
end;

function TWPCustomRtfEdit.GetParXYBaselineScreen(par: TParagraph; PosInPar: Integer; var x, y: Integer): Boolean;
var PaintPageNr: Integer;
begin
  x := 0; y := 0;
  Result := Memo.GetXYPositionAtRTF(par.RTFData, par, PosInPar, PaintPageNr, x, y, [wpCalcScrolling, wpUseBaseline]);
end;

function TWPCustomRtfEdit.GetImageAtXY(
  X, Y: Integer; var img_x, img_y, img_w, img_h: Integer): TWPTextObj;
var PageNr: Integer; mrg: TWPMouseMarginArea;
begin
  PageNr := FMemo.GetPageAtXY(X, Y, mrg);
  if PageNr < 0 then Result := nil
  else
  begin
    X := MulDiv(X, Memo.CurrentXPixelsPerInch, 1440);
    Y := MulDiv(Y, Memo.CurrentYPixelsPerInch, 1440);
    if Memo.GetImageAtXY(PageNr, X, Y, Result, img_x, img_y, img_w, img_h) then
    begin
      img_x := Round((img_x * WPScreenPixelsPerInch / Memo.CurrentXPixelsPerInch
        ) * Memo.CurrentZooming) - LeftOffset + Memo.PaintPageLeft[PageNr];
      img_y := Round((img_y * WPScreenPixelsPerInch / Memo.CurrentXPixelsPerInch
        ) * Memo.CurrentZooming) - TopOffset + Memo.PaintPageTop[PageNr];
      img_w := Round(img_w * WPScreenPixelsPerInch / Memo.CurrentXPixelsPerInch * Memo.CurrentZooming);
      img_h := Round(img_h * WPScreenPixelsPerInch / Memo.CurrentXPixelsPerInch * Memo.CurrentZooming);

    end;
  end;
end;

function TWPCustomRtfEdit.GetCPXpos: Integer;
var PaintPageNr, X, Y: Integer;
begin
  if FMemo.GetXYPositionAtRTF(
    FMemo.Cursor.RTFData,
    FMemo.Cursor.active_paragraph,
    FMemo.Cursor.active_posinpar, PaintPageNr, X, Y) then
  begin
    Result := MulDiv(X, Screen.PixelsPerInch, Memo.CurrentXPixelsPerInch) +
      FMemo.PaintPageLeft[PaintPageNr] -
      FMemo.LeftOffset;
  end
  else Result := -1;
end;

function TWPCustomRtfEdit.GetCPYpos: Integer;
var PaintPageNr, X, Y: Integer;
begin
  if FMemo.GetXYPositionAtRTF(
    FMemo.Cursor.RTFData,
    FMemo.Cursor.active_paragraph,
    FMemo.Cursor.active_posinpar, PaintPageNr, X, Y) then
  begin
    Result := MulDiv(Y, Screen.PixelsPerInch, Memo.CurrentXPixelsPerInch) +
      FMemo.PaintPageTop[PaintPageNr] -
      FMemo.TopOffset;
  end
  else Result := -1;
end;

function TWPCustomRtfEdit.GetSelRect: TRect; // Modified for R6.5
var
  spar: TParagraph;
  spos: Integer;
  function Calc(var P: TPoint): Boolean;
  var PaintPageNr, X, Y: Integer;
  begin
    if (spar <> nil) and
      FMemo.GetXYPositionAtRTF(
      FMemo.Cursor.RTFData,
      spar, spos, PaintPageNr, X, Y) then
    begin
      P.X := X - FMemo.LeftOffset;
      P.Y := Y - FMemo.TopOffset;
      Result := TRUE;
    end else Result := FALSE;
  end;
var P1, P2: TPoint;
  x: integer;
begin
  spar := FMemo.Cursor.GetBlockStart(spos);
  Calc(P1);
  spar := FMemo.Cursor.GetBlockEnd(spos);
  if Calc(P2) and (spos >= 0) and (spos < Length(spar.CharPos)) then
    inc(P2.Y, Round(spar.CharPos[spos].Height * WPScreenPixelsPerInch
      / Memo.CurrentYPixelsPerInch * Memo.CurrentZooming));
  if P2.X < P1.X then
  begin
    x := P1.X;
    P1.X := P2.X;
    P2.X := X;
  end;
  Result.TopLeft := P1;
  Result.BottomRight := P2;
end;


//V5.17.1 - revised

function TWPCustomRtfEdit.GetCPXYPoint(var ScreenPoint: TPoint): Boolean;
var
  PaintPageNr, X, Y: Integer;
  P: TPoint;
begin
  if FMemo.GetXYPositionAtRTF(
    FMemo.Cursor.RTFData,
    FMemo.Cursor.active_paragraph,
    FMemo.Cursor.active_posinpar, PaintPageNr, X, Y) then
  begin
    P.X := X - FMemo.LeftOffset;
    P.Y := Y - FMemo.TopOffset;
    ScreenPoint := ClientToScreen(P);
    Result := TRUE;
  end else Result := FALSE; ;
end;

function TWPCustomRtfEdit.GetPointFromParLin(par: TParagraph; posinpar: Integer): TPoint;
var PaintPageNr: Integer;
begin
  Result.X := 0;
  Result.Y := 0;
  if FMemo.GetXYPositionAtRTF(
    FMemo.Cursor.RTFData,
    par,
    posinpar, PaintPageNr, Result.X, Result.Y) then
  begin
    Result.X := Result.X - FMemo.LeftOffset;
    Result.Y := Result.Y - FMemo.TopOffset;
  end else // Try again but use different RTFData
    if (FMemo.Cursor.RTFData <> par.RTFData) and
      FMemo.GetXYPositionAtRTF(
      par.RTFData,
      par,
      posinpar, PaintPageNr, Result.X, Result.Y) then
    begin
      Result.X := Result.X - FMemo.LeftOffset;
      Result.Y := Result.Y - FMemo.TopOffset;
    end;
end;

procedure TWPCustomRtfEdit.SetCPParNr(x: Integer);
var par, npar: TParagraph;
begin
  par := FMemo.Cursor.RTFData.FirstPar;
  while (par <> nil) and (x > 0) do
  begin
    npar := par.next;
    if npar = nil then break;
    par := npar;
    dec(x);
  end;
  FMemo.Cursor.MoveTo(par, 0);
end;

function TWPCustomRtfEdit.GetCPParNr: Integer;
var par, endpar: TParagraph;
begin
  par := FMemo.Cursor.RTFData.FirstPar;
  endpar := FMemo.Cursor.active_paragraph;
  Result := 0;
  while (par <> nil) and (par <> endpar) do
  begin
    inc(Result);
    par := par.next;
    if par = nil then break;
  end;
end;

function TWPCustomRtfEdit.GetCpLineNrLog: Longint;
begin
  if FMemo.Cursor.active_paragraph <> nil then
    Result := FMemo.Cursor.active_paragraph.LineStartNr + FMemo.Cursor.active_line
  else Result := 0;
end;

function TWPCustomRtfEdit.GetCpLineNr: Longint;
var
  pos, par, pos_in_par: Longint;
begin
  GetPosition(pos, Result, par, pos_in_par);
end;

procedure TWPCustomRtfEdit.SetCPLineNr(x: Integer);
begin
  SetPosition(0, x, 0, 0);
end;

procedure TWPCustomRtfEdit.SetPositionXY(X, Y: Integer);
begin
  Memo.c_pos(X, Y, FALSE, FALSE);
end;

procedure TWPCustomRtfEdit.SetCPosInPar(x: Integer);
begin
  FMemo.Cursor.MoveTo(FMemo.Cursor.active_paragraph, X);
end;

function TWPCustomRtfEdit.GetCPosInPar: Integer;
begin
  Result := FMemo.Cursor.active_posinpar;
end;

procedure TWPCustomRtfEdit.SetCPLine(const x: string);
var nr, i, l: Integer;
  a: Cardinal;
begin
  if FMemo.Cursor.active_paragraph <> nil then
  begin
    nr := FMemo.Cursor.active_line;
    i := FMemo.Cursor.active_paragraph.LineOffset(nr);
    l := FMemo.Cursor.active_paragraph.LineLength(nr);
    a := FMemo.Cursor.active_paragraph.CharAttr[i];
    FMemo.Cursor.active_paragraph.DeleteChars(i, l);
    FMemo.Cursor.active_paragraph.Insert(i, x, a);
     // NO REFORMAT
  end;
end;

procedure TWPCustomRtfEdit.SetCPPar(const x: string);
begin
  if FMemo.Cursor.active_paragraph <> nil then
    FMemo.Cursor.active_paragraph.SetText(x);
end;

function TWPCustomRtfEdit.GetCPPar: string;
begin
  if FMemo.Cursor.active_paragraph = nil then Result := ''
  else Result := FMemo.Cursor.active_paragraph.GetText;
end;




function TWPCustomRtfEdit.GetCPLine: string;
var nr, i, l: Integer;
begin
  if FMemo.Cursor.active_paragraph <> nil then
  begin
    nr := FMemo.Cursor.active_line;
    i := FMemo.Cursor.active_paragraph.LineOffset(nr);
    l := FMemo.Cursor.active_paragraph.LineLength(nr);
    Result := FMemo.Cursor.active_paragraph.GetSubText(i, l)
  end else Result := '';
end;

function TWPCustomRtfEdit.GetCPObj: TWPTextObj;
begin
  Result := TextCursor.ObjAtCP;
end;

function TWPCustomRtfEdit.GetSelectedObject: TWPTextObj;
begin
  Result := TextCursor.SelectedObject;
end;

procedure TWPCustomRtfEdit.SetSelectedObject(x: TWPTextObj);
begin
  TextCursor.SelectedObject := x;
end;

function TWPCustomRtfEdit.GetCPWord: string;
var
  pc, l: Integer;
begin
  Result := '';
  FSpaceAtGetCPWordFoundPos := FALSE;
  with Memo.Cursor do
  begin
    FGetCPWordFoundPos := active_posinpar;
    FGetCPWordFoundLen := 0;

    if active_paragraph = nil then exit;
    pc := active_posinpar;

    if FInAfterCompleteWordEvent then dec(pc);

    // First space AFTER the word!
    if active_paragraph.IsWordDelimiter(pc) and (pc > 0) then dec(pc);
    // overread the word
    while (pc > 0) and not active_paragraph.IsWordDelimiter(pc) do dec(pc);
    // Skip this space
    if active_paragraph.IsWordDelimiter(pc) then
    begin
      FSpaceAtGetCPWordFoundPos := TRUE;
      inc(pc);
    end;
    // Skip a field marker (afsIsInsertPoint)
    if active_paragraph.IsCharObject(pc) then inc(pc);
    // Get Length
    l := 0;
    FGetCPWordFoundPos := pc;
    // When we are in 'AfterCompleteWordEvent' we only read the characters
    // until the cursor position
    while not active_paragraph.IsWordDelimiter(pc + l) and
      (not FInAfterCompleteWordEvent or (pc + l < active_posinpar)) do inc(l);
    Result := active_paragraph.GetSubText(pc, l);
    FGetCPWordFoundLen := l;
  end;
end;

procedure TWPCustomRtfEdit.SetCPWord(X: string);
begin
  with Memo.Cursor do
  begin
    if active_paragraph <> nil then
    begin
      GetCPWord;
      active_paragraph.Replace(FGetCPWordFoundPos, FGetCPWordFoundLen, X);
      active_posinpar := FGetCPWordFoundPos + Length(x);
      FCPWordModified := TRUE;
      StartUpdate(WPUPD_REFORMAT);
    end;
  end;
end;

function TWPCustomRtfEdit.GetCursorCol: Integer;
begin
  Result := FMemo.Cursor.cursor_pos;
end;

procedure TWPCustomRtfEdit.SetCursorCol(x: Integer);
begin
  FMemo.Cursor.cursor_pos := x;
end;

//##############################################################################
//######## PUBLIC FUNCTIONS TO WORK WITH TEXT AT CURSOR POSITION ###############
//##############################################################################

function TWPCustomRtfEdit.GetXPositionTw: Integer;
var PaintPageNr, X, Y: Integer;
begin
  if FMemo.GetXYPositionAtRTFTW(// no margin!
    FMemo.Cursor.RTFData,
    FMemo.Cursor.active_paragraph,
    FMemo.Cursor.active_posinpar, PaintPageNr, X, Y, FALSE) then
  begin
    Result := X;
  end
  else Result := -1;
end;

function TWPCustomRtfEdit.GetYPositionTw: Integer;
var PaintPageNr, X, Y: Integer;
begin
  if FMemo.GetXYPositionAtRTFTW(// margins included!
    FMemo.Cursor.RTFData,
    FMemo.Cursor.active_paragraph,
    FMemo.Cursor.active_posinpar, PaintPageNr, X, Y, TRUE) then
  begin
    Result := Y;
  end
  else Result := -1;
end;

procedure TWPCustomRtfEdit.ScrollLinePos(par: TParagraph; posinpar: Integer);
begin
  Memo.ScrollLinePos(par, posinpar, nil, 0, true);
end;


function TWPCustomRtfEdit.CPAttr: TWPTAttrEmulator;
begin
  Result := FMemo.Cursor.CPAttr;
end;

function TWPCustomRtfEdit.CurrentCharAttr: TWPCursorCharAttrInterface;
begin
  Result := FMemo.Cursor.CurrentCharAttr;
end;

function TWPCustomRtfEdit.GetOldAttr: TAttr;
begin
{$IFNDEF CLR}
  FillChar(Result, SizeOf(Result), 0);
{$ENDIF}
  with FMemo.RTFData.DefaultAttr do
  begin
    GetFont(Result.Font);
    GetFontCharset(Result.CharSet);
    GetFontSize(Result.Size);
    GetStyles(Result.Style);
    GetColorNr(Result.Color);
    GetBGColorNr(Result.BGColor);
  end;
end;

procedure TWPCustomRtfEdit.SetOldAttr(const x: TAttr);
begin
  with FMemo.RTFData.DefaultAttr do
  begin
    BeginUpdate;
    SetFont(x.Font);
    SetFontCharset(x.CharSet);
    SetFontSize(x.Size);
    SetStyles(x.Style);
    SetColorNr(x.Color);
    SetBGColorNr(x.BGColor);
    EndUpdate;
  end;
end;

procedure TWPCustomRtfEdit.PushAttr;
var l: Integer;
begin
  l := Length(FAttrStack);
  SetLength(FAttrStack, l + 1);
  FAttrStack[l] := FMemo.RTFData.DefaultAttr.CharAttr;
end;

procedure TWPCustomRtfEdit.PopAttr;
var l: Integer;
begin
  l := Length(FAttrStack);
  if l > 0 then
  begin
    dec(l);
    FMemo.RTFData.DefaultAttr.CharAttr;
    SetLength(FAttrStack, l);
  end;
end;

function TWPCustomRtfEdit.CountLines: Integer;
var par: TParagraph;
  rtf: TWPRTFDataBlock;
begin
  rtf := Memo.DisplayedText;
  if rtf = nil then rtf := HeaderFooter.Find(wpIsBody, wpraOnAllPages, '');
  if (rtf <> nil) and not rtf.Empty then
  begin
    Result := 0;
    par := rtf.FirstPar;
    while par <> nil do
    begin
        // Only list paragraphs which contain text!
      if not (par.ParagraphType in
        [wpIsTable, wpIsTableRow, wpIsReportGroup,
        wpIsReportHeaderBand, wpIsReportDataBand, wpIsReportFooterBand]) then
      begin
        inc(Result, par.LineCount);
      end;
      par := par.next;
    end;
  end else Result := 1;
end;

function TWPCustomRtfEdit.CountWords: Integer;
var par: TParagraph;
  i: Integer;
  InWord: Boolean;
  rtf: TWPRTFDataBlock;
begin
  Result := 0;
  rtf := Memo.DisplayedText;
  if rtf = nil then rtf := HeaderFooter.Find(wpIsBody, wpraOnAllPages, '');
  if (rtf <> nil) and not rtf.Empty then
  begin
    par := rtf.FirstPar;
    while par <> nil do
    begin
        // Only list paragraphs which contain text!
      if not (par.ParagraphType in
        [wpIsTable, wpIsTableRow, wpIsReportGroup,
        wpIsReportHeaderBand, wpIsReportDataBand, wpIsReportFooterBand]) then
      begin
        InWord := FALSE;
        for i := 0 to par.CharCount - 1 do
        begin
          if (par.CharItem[i] > #32)
            and (par.CharItem[i] <> '.')
            and (par.CharItem[i] <> ',')
            and (par.CharItem[i] <> '!')
            and (par.CharItem[i] <> '?')
            then
          begin
            if not InWord then
            begin
              inc(Result);
              InWord := TRUE;
            end;
          end
          else InWord := FALSE;
        end;
      end;
      par := par.next;
    end;
  end;
end;

function TWPCustomRtfEdit.CountPages: Integer;
begin
  Result := Memo.PaintPageCount;
  if Result <= 0 then Result := 1;
end;

function TWPCustomRtfEdit.CountParagraphs: Integer;
var par: TParagraph;
  rtf: TWPRTFDataBlock;
begin

  rtf := Memo.DisplayedText;
  if rtf = nil then rtf := HeaderFooter.Find(wpIsBody, wpraOnAllPages, '');
  if (rtf <> nil) and not rtf.Empty then
  begin
    par := rtf.FirstPar;
    Result := 0;
    while par <> nil do
    begin
        // Only list paragraphs which contain text!
      if not (par.ParagraphType in
        [wpIsTable, wpIsTableRow, wpIsReportGroup,
        wpIsReportHeaderBand, wpIsReportDataBand, wpIsReportFooterBand]) then
      begin
        inc(Result, 1);
      end;
      par := par.next;
    end;
  end else Result := 1;
end;

function TWPCustomRtfEdit.GetCPPage: Integer;
begin
  with TextCursor do
  begin
    if active_paragraph = nil then
      Result := -1
    else
    begin
      Result := FMemo.GetPageWithPar(active_paragraph, active_posinpar);
      if Result < 0 then Result := active_paragraph.pagenr;
    end;
  end;
end;

procedure TWPCustomRtfEdit.SetCPPage(x: Integer);
var par: TParagraph;
  posinpar: Integer;
begin
  FMemo.TopOffset :=
    FMemo.PaintPageTop[x];
  if FMemo.GetFirstParOnPage(x, par, posinpar) then
    TextCursor.MoveTo(par, posinpar, false);
  invalidate;
end;

function TWPCustomRtfEdit.GetCPWideChar: WideChar;
begin
  if FMemo.Cursor.active_paragraph = nil then
    Result := #0
  else if (FMemo.Cursor.active_posinpar < 0) or
    (FMemo.Cursor.active_posinpar >= FMemo.Cursor.active_paragraph.CharCount) then
    Result := #13
  else Result := FMemo.Cursor.active_paragraph.CharItem[FMemo.Cursor.active_posinpar];
end;

function TWPCustomRtfEdit.GetCPPrevWideChar: WideChar;
begin
  if FMemo.Cursor.active_paragraph = nil then
    Result := #0
  else if (FMemo.Cursor.active_posinpar <= 0) or
    (FMemo.Cursor.active_posinpar > FMemo.Cursor.active_paragraph.CharCount) then
    Result := #13
  else Result := FMemo.Cursor.active_paragraph.CharItem[FMemo.Cursor.active_posinpar - 1];
end;

function TWPCustomRtfEdit.GetCPChar: Char;
begin
  Result := Char(GetCPWideChar); // - USE CODEPAGE !!!
end;

function TWPCustomRtfEdit.GetCPPrevChar: Char;
begin
  Result := Char(GetCPPrevWideChar); // - USE CODEPAGE !!!
end;

function TWPCustomRtfEdit.GetCPCharPlusIndex(index: Integer): WideChar;
begin
  with FMemo.Cursor do
  begin
    if active_paragraph = nil then Result := #0
    else if (active_posinpar + index < 0) or
      (active_posinpar + index >= active_paragraph.CharCount) then
      Result := #13
    else Result := active_paragraph.CharItem[active_posinpar + index];
  end;
end;

procedure TWPCustomRtfEdit.SetCPCharPlusIndex(index: Integer; C: WideChar);
begin
  with FMemo.Cursor do if (active_paragraph <> nil) and
    (active_posinpar + index >= 0) and (active_posinpar + index < active_paragraph.CharCount) then
    begin
      active_paragraph.CharItem[active_posinpar + index] := C;
      include(active_paragraph.prop, paprMustInit);
    end;
end;

procedure TWPCustomRtfEdit.SetCPWideChar(x: WideChar);
begin
  with FMemo.Cursor do if (active_paragraph <> nil) and
    (active_posinpar >= 0) and (active_posinpar < active_paragraph.CharCount) then
    begin
      active_paragraph.CharItem[active_posinpar] := x;
      include(active_paragraph.prop, paprMustInit);
    end;
end;

procedure TWPCustomRtfEdit.SetCPPrevWideChar(x: WideChar);
begin
  with FMemo.Cursor do if (active_paragraph <> nil) and
    (active_posinpar > 0) and (active_posinpar < active_paragraph.CharCount + 1) then
    begin
      active_paragraph.CharItem[active_posinpar - 1] := x;
      include(active_paragraph.prop, paprMustInit);
    end;
end;

procedure TWPCustomRtfEdit.SetCPChar(x: Char);
begin
  SetCPWideChar(WideChar(x));
end;

procedure TWPCustomRtfEdit.SetCPPrevChar(x: Char);
begin
  SetCPWideChar(WideChar(x));
end;

function TWPCustomRtfEdit.GetCPCharAttr: Cardinal;
begin
  if (FMemo.Cursor.active_paragraph = nil) or
    (FMemo.Cursor.active_posinpar < 0) or
    (FMemo.Cursor.active_posinpar >= FMemo.Cursor.active_paragraph.CharCount) then
    Result := 0
  else Result := FMemo.Cursor.active_paragraph.CharAttr[FMemo.Cursor.active_posinpar];
end;

procedure TWPCustomRtfEdit.SetCPCharAttr(x: Cardinal);
begin
  if not ((FMemo.Cursor.active_paragraph = nil) or
    (FMemo.Cursor.active_posinpar < 0) or
    (FMemo.Cursor.active_posinpar >= FMemo.Cursor.active_paragraph.CharCount)) then
    FMemo.Cursor.active_paragraph.CharAttr[FMemo.Cursor.active_posinpar] := x;
end;


function TWPCustomRtfEdit.CPMoveNext: Boolean;
begin
  Result := FMemo.Cursor.CPMoveNext;
end;

function TWPCustomRtfEdit.CPMoveBack: Boolean;
begin
  Result := FMemo.Cursor.CPMoveBack;
end;

function TWPCustomRtfEdit.CPMoveDownLine: Boolean;
begin
  Result := FMemo.Cursor.MoveDownLine;
end;

function TWPCustomRtfEdit.CPMoveDownPar: Boolean;
begin
  Result := FMemo.Cursor.MoveDownPar;
end;

function TWPCustomRtfEdit.CPMoveUpLine: Boolean;
begin
  Result := FMemo.Cursor.MoveUpLine;
end;

function TWPCustomRtfEdit.CPMoveUpPar: Boolean;
begin
  Result := FMemo.Cursor.MoveUpPar;
end;

function TWPCustomRtfEdit.GetHeader: TTextHeader;
begin
  if not FIDEValueLoaded then
    Result := FIDETextHeader
  else Result := FMemo.RTFData.Header;
end;

procedure TWPCustomRtfEdit.SetHeader(x: TTextHeader);
begin
  if not FIDEValueLoaded then
    FIDETextHeader.Assign(x)
  else
  begin
    FMemo.RTFData.Header.Assign(x);
    if csDesigning in ComponentState then
      FIDETextHeader.Assign(x);
  end;
end;


function TWPCustomRtfEdit.GetRTFVariables: TWPRTFExtraDataCollection;
begin
  if not FIDEValueLoaded then
    Result := FIDERTFVariables
  else Result := FMemo.RTFData.RTFVariables;
end;

procedure TWPCustomRtfEdit.SetRTFVariables(x: TWPRTFExtraDataCollection);
begin
  if not FIDEValueLoaded then
    FIDERTFVariables.Assign(x)
  else FMemo.RTFData.RTFVariables.Assign(x);
end;

function TWPCustomRtfEdit.GetPrintParameter: TWPPrintParameter;
begin
  if not FIDEValueLoaded then
    Result := FIDEPrintParameter
  else Result := FMemo.RTFData.PrintParameter;
end;

procedure TWPCustomRtfEdit.SetPrintParameter(x: TWPPrintParameter);
begin
  if not FIDEValueLoaded then
    FIDEPrintParameter.Assign(x)
  else FMemo.RTFData.PrintParameter.Assign(x);
end;

function TWPCustomRtfEdit.GetSpellCheckStrategie: TWPSpellCheckStrategie;
begin
  Result := FMemo.SpellCheckStrategie;
end;

procedure TWPCustomRtfEdit.SetSpellCheckStrategie(x: TWPSpellCheckStrategie);
begin
  FMemo.SpellCheckStrategie := x;
end;

function TWPCustomRtfEdit.GetSpellIgnoredForObj: TWPTextObjTypes;
begin
  Result := FMemo.SpellIgnoredForObj;
end;

procedure TWPCustomRtfEdit.SetSpellIgnoredForObj(x: TWPTextObjTypes);
begin
  FMemo.SpellIgnoredForObj := x;
end;

function ResetDCA(DC: HDC; const p2: PDeviceMode): HDC; stdcall; external gdi32 name 'ResetDCA';

(*
  TWPSetupPrinterFields = set of (
    wpPageSize,
    wpOrientation,
    wpPaperTay,
    wpDuplexMode);

  TWPSetupPrinterEvent = procedure(
    Sender: TWPCustomRtfEdit;
    PrintParameter: TWPPrintParameter;
    aPrinter : TPrinter;
    BeforeStartDoc : Boolean;
    var DevMode: DevMode;
    PaintPageNumber: Integer;
    startpar: TParagraph;
    startposinpar: Integer;
    const PaintPage: TWPRTFEnginePaintPages;
    RTFPage: TWPVirtPage; // can be nil!
    ChangeFields: TWPSetupPrinterFields) of object;
*)

procedure TWPCustomRtfEdit.GetPaperBins(aPrinter: TPrinter; list: TStrings;
  FirstName: string = '');
{$IFDEF DISABLEPRINTER}
begin
  // raise Exception.Create('Printing disabled');
end;
{$ELSE}
type
  TBinName = array[0..23] of Char;
var
  DevMode: PDeviceMode;
ADevice, ADriver, APort: array[0..256] of Char; var
  ADeviceMode: THandle;
  i, Count: Integer;
  BinNames: array of TBinName;
  Bins: array of Word;
  buffer: array[0..30] of Char;
begin
  if WPNoPrinterInstalled then begin exit; end;
  aPrinter.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
  List.Clear;
  if FirstName <> '' then List.Add(FirstName);
  DevMode := GlobalLock(ADeviceMode);
  if DevMode <> nil then
  try
    Count := DeviceCapabilities(
      aDevice, // pointer to a printer-name string
      Aport,
      DC_BINNAMES, // device capability to query
      nil, DevMode);

    if Count > 0 then
    begin
      SetLength(BinNames, Count);
      SetLength(Bins, Count);
      try
        DeviceCapabilities(aDevice, Aport, DC_BINNAMES, PChar(@BinNames[0]), nil); // DevMode);
        DeviceCapabilities(aDevice, Aport, DC_BINS, PChar(@Bins[0]), nil); // DevMode);
        for i := 0 to Count - 1 do
        begin
          StrLCopy(buffer, PChar(@BinNames[i]), 24);
          List.AddObject(StrPas(buffer), TObject(Bins[i]));
        end;
      finally
        SetLength(BinNames, 0);
        SetLength(Bins, 0);
      end;
    end;
  finally
    GlobalUnlock(ADeviceMode);
  end;
end;
{$ENDIF}

procedure TWPCustomRtfEdit.UpdatePrinterProperties(
  aPrinter: TPrinter;
  PaintPageNr: Integer; // PaintPageNr = 0 based!
  pw: Integer = 0;
  ph: Integer = 0);
{$IFDEF DISABLEPRINTER}
begin

end;
{$ELSE}
var
  DevMode: PDeviceMode;
  ADevice, ADriver, APort: array[0..256] of Char;
  ADeviceMode: THandle;
  Changed: Boolean;
  FPrintParameter: TWPPrintParameter;
  ChangeFields: TWPSetupPrinterFields;
  aPageWidth, aPageHeight, presx, presy: Integer;
  PaintPage: TWPRTFEnginePaintPages;
  RTFPage: TWPVirtPage;
  startpar: TParagraph;
  startposinpar: Integer;
  linedata: TWPVirtPageImageLineRef;
  env: TWPToolsBasicEnviroment;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  procedure InitPaperDefs;
  var
    numPaperformats, i: Integer;
  begin
    numPaperformats := 0;
    if ADeviceMode <> 0 then
    begin
      numPaperformats := DeviceCapabilities(ADevice, APort, DC_PAPERS, nil, nil);
      if numPaperformats > 0 then
      begin
        SetLength(env._globale_PaperDEFCodes, numPaperformats);
        SetLength(env._globale_PaperDEFSizes, numPaperformats);
{$IFDEF DEBUGPAPERNAMES}SetLength(env._globale_PaperDEFNames, numPaperformats); {$ENDIF}
        try
          DeviceCapabilities(ADevice, APort, DC_PAPERS, PChar(@env._globale_PaperDEFCodes[0]), nil);
          DeviceCapabilities(ADevice, APort, DC_PAPERSIZE, PChar(@env._globale_PaperDEFSizes[0]), nil);
{$IFDEF DEBUGPAPERNAMES}
          DeviceCapabilities(ADevice, APort, DC_PAPERNAMES, PChar(@env._globale_PaperDEFNames[0]), nil);
{$ENDIF}
          // Convert to twips ....
          for i := 0 to numPaperformats - 1 do
          begin
            env._globale_PaperDEFSizes[i].x := WPCentimeterToTwips(env._globale_PaperDEFSizes[i].x / 100);
            env._globale_PaperDEFSizes[i].y := WPCentimeterToTwips(env._globale_PaperDEFSizes[i].y / 100);
          end;
        except
          numPaperformats := 0;
        end;
      end;
    end;
    if numPaperformats = 0 then
    begin
      SetLength(env._globale_PaperDEFCodes, 0);
      SetLength(env._globale_PaperDEFSizes, 0);
{$IFDEF DEBUGPAPERNAMES}SetLength(env._globale_PaperDEFNames, 0); {$ENDIF}
    end;
  end;
  // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
var i, PaperDEF, tray: Integer; landscape: Boolean;
  options: TWPPrintOptions;
begin
  FPrintParameter := FMemo.RTFData.PrintParameter;
  env := Enviroment;
  if env._globale_Printing = 0 then
    options := FPrintParameter.PrintOptions
  else options := env._globale_PrintOptions;

  if FMemo.GetPaintPage(PaintPageNr, PaintPage, RTFPage)
  { -- do it always --- !!!!
    and (Assigned(FOnSetupPrinterEvent) or not
    (wpDoNotChangePrinterDefaults in options)) }
  then
  begin
    aPrinter.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
    DevMode := GlobalLock(ADeviceMode);
    Changed := FALSE;
    ChangeFields := [];
    try
  // When this is the first call we collect the paper definitions
      if not aPrinter.Printing and
        (aPrinter.Handle <> env._globale_LastInitPrinterHandle) then
      begin
        env._globale_LastInitPrinterHandle := aPrinter.Handle;
        InitPaperDefs;
      end;

      presx := GetDeviceCaps(Printer.Handle, LOGPIXELSX);
      presy := GetDeviceCaps(Printer.Handle, LOGPIXELSY);
  // -------------------------------------------------------------------
      if (FPrintParameter.FirstPagePaperSource <> 0) or
        (FPrintParameter.AllPagePaperSource <> 0) then
        include(ChangeFields, wpPaperTay);
  // if PaintPage.Width> ... // Landscape !
      if (pw <= 0) or (ph <= 0) then // Called from PageSetupDialog!
      begin
        pw := PaintPage.WidthTw;
        if pw = 0 then pw := MulDiv(PaintPage.Width, 1440, WPScreenPixelsPerInch);
        ph := PaintPage.HeightTw;
        if ph = 0 then ph := MulDiv(PaintPage.Height, 1440, WPScreenPixelsPerInch);
      end;
      landscape := pw > ph;

      aPageWidth := MulDiv(GetDeviceCaps(aPrinter.Handle, PHYSICALWIDTH), 1440, presx);
      aPageHeight := MulDiv(GetDeviceCaps(aPrinter.Handle, PHYSICALHEIGHT), 1440, presy);

      if landscape <> (aPrinter.Orientation = poLandscape) then
      begin
        include(ChangeFields, wpOrientation);
    // Check rotated values!
        if (Abs(aPageWidth - ph) > 10) or (Abs(aPageHeight - pw) > 10) then
          include(ChangeFields, wpPageSize);
      end
      else if (Abs(aPageWidth - pw) > 10) or (Abs(aPageHeight - ph) > 10) then
        include(ChangeFields, wpPageSize);

      if landscape then
      begin
        i := pw;
        pw := ph;
        ph := i;
      end;

      if (FPrintParameter.DuplexMode <> wpdDontChangeDuplex) and
        ((DevMode^.dmFields and DM_DUPLEX) <> 0) then
        include(ChangeFields, wpDuplexMode);

  // if Printer. Orientation

  // -------------------------------------------------------------------
      if Assigned(FOnSetupPrinterEvent) then
      begin
        startpar := nil;
        startposinpar := 0;
        if RTFPage <> nil then
        begin
          i := RTFPage.FindFirstTextLine;
          if i >= 0 then
          begin
            RTFPage.GetLine(i, linedata);
            startpar := linedata.par;
            if startpar <> nil then
              startposinpar := startpar.LineOffset(linedata.linenr);
          end;
        end;
        FOnSetupPrinterEvent(Self, FPrintParameter, aPrinter,
          not aPrinter.Printing, DevMode,
          PaintPageNr, startpar, startposinpar,
          PaintPage, RTFPage, ChangeFields);
      end;
  // -------------------------------------------------------------------
      if wpPageSize in ChangeFields then
      begin
        PaperDEF := -1;
      // Find paper def
        for i := 0 to Length(env._globale_PaperDEFSizes) - 1 do
        begin
          if (Abs(env._globale_PaperDEFSizes[i].x - pw) < 2) and // exact value (2 twips error)
            (Abs(env._globale_PaperDEFSizes[i].y - ph) < 2) then
          begin
            PaperDEF := env._globale_PaperDefCodes[i];
{$IFDEF DEBUGPAPERNAMES}
            ShowMessage(StrPas(env._globale_PaperDEFNames[i]));
{$ENDIF}
            break;
          end
          else if (Abs(env._globale_PaperDEFSizes[i].x - pw) < 90) and // Best bet with 1.5mm error
            (Abs(env._globale_PaperDEFSizes[i].y - ph) < 90) then
          begin
            PaperDEF := env._globale_PaperDefCodes[i];
          end;
        end;
      // Set Paper DEFCode OR Paper Size
        if PaperDEF >= 0 then
        begin
          if DevMode^.dmPaperSize <> PaperDEF then
          begin
            DevMode^.dmPaperSize := PaperDEF;
            DevMode^.dmFields := DevMode^.dmFields or DM_PaperSize;
            Changed := TRUE;
          end;
        end else
        begin
          DevMode^.dmPaperSize := DMPAPER_USER;
          DevMode^.dmPaperWidth := Round(WPTwipsToCentimeter(pw) * 100);
          DevMode^.dmPaperLength := Round(WPTwipsToCentimeter(ph) * 100);
          DevMode^.dmFields := DevMode^.dmFields
            or DM_PAPERSIZE or DM_PAPERWIDTH or DM_PAPERLENGTH;
        end;
      end;
  // -------------------------------------------------------------------
      if wpOrientation in ChangeFields then
      begin
        if Landscape then i := 2 else i := 1;
        if DevMode^.dmOrientation <> i then
        begin
          DevMode^.dmOrientation := i;
          DevMode^.dmfields := DevMode^.dmfields or DM_Orientation;
          Changed := TRUE;
        end;
        if not aPrinter.Printing then
        begin
          if Landscape then aPrinter.Orientation := poLandscape
          else aPrinter.Orientation := poPortrait;
        end;
      end;
  // -------------------------------------------------------------------
      if wpDuplexMode in ChangeFields then
      begin
        case FPrintParameter.DuplexMode of
          wpdNone:
            if Devmode^.dmDuplex <> dmdup_simplex then
            begin
              Devmode^.dmDuplex := dmdup_simplex;
              DevMode^.dmFields := DevMode^.dmFields or
                DM_DUPLEX;
              Changed := TRUE;
            end;
          wpdHorizontal:
            if Devmode^.dmDuplex <> DMDUP_HORIZONTAL then
            begin
              Devmode^.dmDuplex := DMDUP_HORIZONTAL;
              DevMode^.dmFields := DevMode^.dmFields or
                DM_DUPLEX;
              Changed := TRUE;
            end;
          wpdVertical:
            if Devmode^.dmDuplex <> dmdup_vertical then
            begin
              Devmode^.dmDuplex := dmdup_vertical;
              DevMode^.dmFields := DevMode^.dmFields or
                DM_DUPLEX;
              Changed := TRUE;
            end;
        end;
      end;

  // -------------------------------------------------------------------
      if wpPaperTay in ChangeFields then
      begin
      // First page = two pages in duplex mode!
        if (Devmode^.dmDuplex = dmdup_vertical)
          or (Devmode^.dmDuplex = DMDUP_HORIZONTAL) then
          i := 2
        else i := 1;
      // Need first or all paper bin
        if PaintPageNr < i then
        begin
          tray := FPrintParameter.FirstPagePaperSource;
          if tray = 0 then tray := FPrintParameter.AllPagePaperSource;
        end
        else tray := FPrintParameter.AllPagePaperSource;

        if Integer(DevMode^.dmDEFAULTSOURCE) <> tray then
        begin
          DevMode^.dmDEFAULTSOURCE := tray;
          DevMode^.dmFields := DevMode^.dmFields or DM_DEFAULTSOURCE;
          Changed := TRUE;
        end;
      end;

  // -------------------------------------------------------------------
      if Changed then
      begin
        if aPrinter.Printing then
        begin
        // if ResetDCA(aPrinter.Handle, DevMode)<>0 then aPrinter.Canvas.Refresh;
          ResetDCA(aPrinter.Handle, DevMode);
        end
        else Printer.SetPrinter(ADevice, ADriver, APort, ADeviceMode);
      end;
  // -------------------------------------------------------------------
    finally
      if DevMode <> nil then GlobalUnlock(ADeviceMode);
    end;
  end;
end;
{$ENDIF}



(*
function TWPCustomRtfEdit.GetNumberStyles: TWPRTFNumberingStyleCollection;
begin
  if not FIDEValueLoaded then
    Result := FIDENumberStyles
  else Result := FMemo.RTFData.RTFProps.NumberStyles;
end;

procedure TWPCustomRtfEdit.SetNumberStyles(x: TWPRTFNumberingStyleCollection);
begin
  if not FIDEValueLoaded then
    FIDENumberStyles.Assign(x)
  else FMemo.RTFData.RTFProps.NumberStyles.Assign(x);
end; *)


//##############################################################################
//######## PRINTING ############################################################
//##############################################################################


{:: Prints a page on the current Printer Canvas. Does not create a new page.
    The page number is 1 based }

function TWPCustomRtfEdit.PrintPage(n, xoff, yoff: Integer;
  options: TWPPrintOptions = []): Boolean;
{$IFDEF DISABLEPRINTER}
begin
  Result := FALSE;
end;
{$ELSE}
var mode: TWPPaintModes;
begin
  mode := [wppWhiteIsTransparent, wppOutputToPrinter];
  if wpIgnoreBorders in options then
    include(mode, wppNoParLines);
  if wpDontPrintWatermark in options then
    include(mode, wppNoWatermarks);
  if wpIgnoreShading in options then
    include(mode, wppNoParShading);
  if wpIgnoreGraphics in options then
    include(mode, wppNoImages);
  if wpIgnoreText in options then
    include(mode, wppNoTextAtAll);
  if wpUsePrintPageNumber in options then
    include(mode, wppUsePrintPageNumberFromEnviroment);
  Result := PaintPageOnCanvas(n - 1, xoff, yoff, 0, 0,
    Printer.Canvas, mode, 0, 0, -1, -1, []);
end;
{$ENDIF}

{- The following values are stored in the WPToolsEnviroment
   and used during the print process:
    _globale_Printing            : Integer;
    _globale_PrintingNeedEndPage : Boolean;
    _globale_JustStartedPrinting : Boolean;
    _globale_PrintOptions        : TWPPrintOptions;
    _globale_PrintingPageNr      : Integer;
    _globale_PrintingPageCount   : Integer;
    _globale_InPrintPages        : Boolean;
    property CombinedPrintPageCount : Integer
 ---------------------------------------------------------- }

function TWPCustomRtfEdit.BeginPrint(Title: string = '';
  StartPageNumber: Integer = 0): Boolean;
{$IFDEF DISABLEPRINTER}
begin
  Result := FALSE;
end;
{$ELSE}
var env: TWPToolsBasicEnviroment;
begin
  if WPNoPrinterInstalled then begin Result := FALSE; exit; end;
  if (Title = '') and (Printer.Title = '') then Title :=
    'Printing ' + TimeToStr(Now);
  env := Enviroment;

  inc(env._globale_Printing);
  if env._globale_Printing = 1 then
  begin
    // Use the same print options for the complete process!
    env._globale_PrintOptions := PrintParameter.PrintOptions;
    // wpUsePrintPageNumber only makes sense when BeginPrint is explicitely called:
    if env._globale_InPrintPages then
      exclude(env._globale_PrintOptions, wpUsePrintPageNumber);

    // Do we need to reformat ?
    if FMemo.RTFData._LastReformatWasSpeedReformat then
      ReformatAll;
    if Title <> '' then Printer.Title := Title;

    // We need to set up the properties for the first page BEFORE the BeginDoc
    if not env._globale_InPrintPages then
    begin
      if Assigned(FOnSetupPrinterEvent) or
        not (wpDoNotChangePrinterDefaults in env._globale_PrintOptions)
        then UpdatePrinterProperties(Printer, StartPageNumber);
    end;
    Printer.BeginDoc;
    env._globale_JustStartedPrinting := TRUE;
    env._globale_PrintingNeedEndPage := FALSE;
    env._globale_PrintingPageNr := 0;
    Result := TRUE;
  end else Result := FALSE;
end;
{$ENDIF}

function TWPCustomRtfEdit.EndPrint: Boolean;
{$IFDEF DISABLEPRINTER}
begin
  Result := FALSE;
end;
{$ELSE}
var env: TWPToolsBasicEnviroment;
begin
  if WPNoPrinterInstalled then begin Result := FALSE; exit; end;
  env := Enviroment;
  dec(env._globale_Printing);
  if env._globale_Printing < 0 then
  begin
    env._globale_Printing := 0; // this should NOT happen!
    Result := TRUE;
  end
  else if env._globale_Printing = 0 then
  begin
    // _globale_PrintingNeedEndPage: EndPage is done in EndDoc!
    Printer.EndDoc;
    Result := TRUE;
    env._globale_JustStartedPrinting := TRUE;
    env._globale_PrintingNeedEndPage := FALSE;
  end else Result := FALSE;
end;
{$ENDIF}

function TWPCustomRtfEdit.PrintPages(FromPage, ToPage: Integer): Boolean;
{$IFDEF DISABLEPRINTER}
begin
  Result := FALSE;
end;
{$ELSE}
var i: Integer;
  newpage: Boolean;
  updateprinterprops: Boolean;
  options: TWPPrintOptions;
  env: TWPToolsBasicEnviroment;
begin
  if WPNoPrinterInstalled then begin Result := FALSE; exit; end;
  env := Enviroment;
  if env._globale_InPrintPages then
    raise Exception.Create('Illegal Recursion in PrintPages()!');
  try
    env._globale_InPrintPages := TRUE;

    if FMemo.RTFData._LastReformatWasSpeedReformat or
      (Memo.PaintPageCount = 0) then
      ReformatAll;
    Result := TRUE;

  // Use the same options for all TWPRichText which are printing
    if env._globale_Printing = 0 then
      options := PrintParameter.PrintOptions
    else options := env._globale_PrintOptions;

  // Update Printer Props
    updateprinterprops := Assigned(FOnSetupPrinterEvent) or
      not (wpDoNotChangePrinterDefaults in options);
    if ToPage >= FromPage then
    begin
      if ToPage > Memo.PaintPageCount then ToPage := Memo.PaintPageCount;
      if FromPage = 0 then FromPage := 1;
    end else
    begin
      if FromPage > Memo.PaintPageCount then FromPage := Memo.PaintPageCount;
      if ToPage = 0 then ToPage := 1;
    end;
    //if FromPage <= ToPage then -- no check required !
    //begin
    // Used in a big BeginPrint/EndPrint Loop
    if env._globale_PrintingNeedEndPage then
    begin
      EndPage(Printer.Handle);
      env._globale_PrintingNeedEndPage := FALSE;
    end;
    // Set the next properties
    if updateprinterprops then
      UpdatePrinterProperties(Printer, FromPage - 1);
    newpage := not BeginPrint and not env._globale_JustStartedPrinting;
    options := env._globale_PrintOptions; // adjusted by BeginPrint!
    try
     // PrinterNewPage(Printer.Handle, Printer.Canvas, nil);
      i := FromPage;
      while ((i <= ToPage) and (ToPage >= FromPage)) or
        ((i >= ToPage) and (ToPage < FromPage)) do
      begin
        // Increase current PageNumber !
        inc(env._globale_PrintingPageNr); // Starts with 0!

        if updateprinterprops and (i <> FromPage) then
          UpdatePrinterProperties(Printer, i - 1);
        if newpage then
        begin
          if updateprinterprops then
          begin
            StartPage(Printer.Handle);
            env._globale_PrintingNeedEndPage := TRUE;
            Printer.Canvas.Refresh;
          end
          else Printer.NewPage;
        end;
        if not PrintPage(i, -GetDeviceCaps(Printer.Canvas.Handle, PHYSICALOFFSETX),
          -GetDeviceCaps(Printer.Canvas.Handle, PHYSICALOFFSETY),
          options) then
          Result := FALSE;
        newpage := TRUE;
        env._globale_JustStartedPrinting := FALSE;
        env._globale_PrintingNeedEndPage := TRUE; //V5.12.2
        if updateprinterprops then
        begin
          if ((i + 1 <= ToPage) and (ToPage >= FromPage)) or
            ((i - 1 >= ToPage) and (ToPage < FromPage)) then //V5.12.2
          begin
            EndPage(Printer.Handle);
            env._globale_PrintingNeedEndPage := FALSE;
          end;
        end;
          // while loop:
        if ToPage >= FromPage then inc(i) else dec(i);
      end;
    finally
      EndPrint;
    end;
    //end else Result := FALSE;
  finally
    env._globale_InPrintPages := FALSE;
  end;
end;
{$ENDIF}


//##############################################################################
//######## SOME WINDOWS STUFF ##################################################
//##############################################################################

procedure TWPCustomRtfEdit.WMKillFocus(var Message: TWMKillFocus);
begin
  KillFocus;
  inherited;
end;

procedure TWPCustomRtfEdit.WMSetFocus(var Message: TWMSetFocus);
begin
  inherited;
  GetFocus;
  if assigned(OnEnter) then OnEnter(Self);
end;

procedure TWPCustomRtfEdit.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TWPCustomRtfEdit.WMGetDlgCode(var Message: TWMGetDlgCode);
begin
  Message.Result := DLGC_WANTARROWS + DLGC_WANTCHARS + DLGC_WANTALLKEYS;
  if WantTabs then Message.Result := Message.Result + DLGC_WANTTAB;
end;

{$IFDEF USETIMER}

procedure TWPCustomRtfEdit.WMTimer(var Message: TMessage);
begin
  FInWaitForPaintEditor := FALSE;
  if FTimerHandle <> 0 then
  begin
    KillTimer(FTimerWinHandle, FTimerHandle);
    FTimerHandle := 0;
  end;
  if Message.WParam = WPUPD_DELAYEDINVALIDATE then
  begin
    FInScrollTrackMode := FALSE;
    FMemo._DBufferIsValid := FALSE;
    Invalidate;
  end;
end;
{$ENDIF}

{$IFNDEF NOFILEMANSUPPORT}

procedure TWPCustomRtfEdit.WMDropFiles(var Msg: TWMDropFiles);
var
{$IFNDEF CLR}
  filename: array[0..MAX_PATH] of Char;
{$ELSE}
  filename: StringBuilder;
{$ENDIF}
  proceed: Boolean;
  ext: string;
  obj: TWPObject;
  p: TPoint;
  rtfX, rtfy, rtfX1, rtfy1, dummy, rtfPage: Integer;
  txtobj: TWPTextObj;
begin
  if FAcceptFiles then
  try
    if DragQueryFile(Msg.Drop, 0, filename, MAX_PATH) > 0 then
    try
      //Memo.NewUndolevel;
      //Memo.StartUndoLevel;
      Changing;
      Windows.GetCursorPos(p);
      p := ScreenToClient(p);
      FMemo.c_pos(p.x, p.y, FALSE, TRUE);
      proceed := TRUE;
      if assigned(FOnDropFile) then
        FOnDropFile(Self, {$IFNDEF CLR}StrPas(filename){$ELSE}filename.ToString{$ENDIF}, proceed);
      if proceed then
      begin
        ext := ExtractFileExt({$IFNDEF CLR}StrPas(filename){$ELSE}filename.ToString{$ENDIF});
        if (CompareText(ext, '.RTF') = 0) or (CompareText(ext, '.HTM') = 0)
          or (CompareText(ext, '.HTML') = 0) or (CompareText(ext, '.TXT') = 0) then
        begin
          LoadFromFile({$IFNDEF CLR}StrPas(filename){$ELSE}filename.ToString{$ENDIF});
          invalidate;
        end
        else
        begin
          obj := WPLoadObjectFromFile(Self, {$IFNDEF CLR}StrPas(filename){$ELSE}filename.ToString{$ENDIF},
            wpDropCreatesLinkedImage in FAcceptFilesOptions);
            // embedd data
          if obj <> nil then
          begin
            obj.WriteRTFMode := wobBoth;
            // obj.Font.Style := [];
            // obj.ParentColor := FALSE;
            // obj.ParentFont := FALSE;
            try
              if (FAcceptFilesOptions * [wpDropCreatesMovableParObject,
                wpDropCreatesMovablePageObject]) <> [] then //V5.18.1
              begin
                if ScreenToRTFPage(p.X, p.y, rtfX, rtfy, rtfPage) then
                begin
                  ActivePosInPar := 0; // Ansert anchor at start!
                  txtobj := TextObjects.InsertMovableImage(obj);
                  if wpDropCreatesNoWrapImage in FAcceptFilesOptions then
                    txtobj.Wrap := wpwrNone
                  else txtobj.Wrap := wpwrBoth;
                  if wpDropCreatesMovableParObject in FAcceptFilesOptions then
                  begin
                    txtobj.PositionMode := wpotPar;
                    rtfx := MulDiv(rtfx, 1440, Memo.CurrentYPixelsPerInch);
                    rtfy := MulDiv(rtfy, 1440, Memo.CurrentYPixelsPerInch);
                    if Memo.GetXYPositionAtRTFTW(ActiveText, ActiveParagraph, 0,
                      dummy, rtfx1, rtfy1) and (rtfy1 < rtfy) then
                      rtfy := rtfy - rtfy1;
                    txtobj.RelX := rtfx;
                    txtobj.RelY := rtfy;
                  end else
                  begin
                    txtobj.PositionMode := wpotPage;
                    TextObjects.MoveParObjectTo(txtobj, ActiveParagraph, rtfPage, rtfX, rtfy);
                  end;
                end
                else TextObjects.InsertMovableImage(obj);
              end else
              begin
                TextObjects.Insert(obj, obj.WidthTW, obj.HeightTW);
                ReformatAll;
              end;
              Invalidate;
            except
              obj.Free;
            end;
          end;
        end;
      end;
      Msg.Result := 0;
    finally
      //Memo.EndUndoLevel;
      //Memo.NewUndolevel;
    end;
  finally
    DragFinish(Msg.Drop);
    ChangeApplied;
  end;
end;
{$ENDIF}

{$IFDEF IMEINPUT}

procedure TWPCustomRtfEdit.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_IME_CHAR:
      Exit;
  end;
  inherited WndProc(Message);
end;

procedure TWPCustomRtfEdit.WMIMEStartComposition(var Message: TMessage);
var IMEContext: HIMC;
  CF: TCompositionForm;
begin
  inherited;
  IMEContext := ImmGetContext(Handle);
  if IMEContext <> 0 then
  try
    CF.dwStyle := CFS_FORCE_POSITION;
    CF.rcArea := ClientRect;
    CF.ptCurrentPos.x := FCaret.FSx;
    CF.ptCurrentPos.y := FCaret.FSy;
    ImmSetCompositionWindow(IMEContext, @CF);
    CF.rcArea.TopLeft := CLientToScreen(CF.rcArea.TopLeft);
    CF.rcArea.BottomRight := CLientToScreen(CF.rcArea.BottomRight);
    CF.ptCurrentPos := ScreenToClient(CF.ptCurrentPos);
  finally
    ImmReleaseContext(Handle, IMEContext);
  end;
end;

procedure TWPCustomRtfEdit.WMIMEEndComposition(var Message: TMessage);
begin
  inherited;
end;

// http://msdn.microsoft.com/library/default.asp?url=/library/en-us/intl/ime_9ulh.asp

procedure TWPCustomRtfEdit.WMIMEComposition(var Message: TMessage);
var IMEContext: HIMC;
  l, i: Integer;
  s: WideString;
  ss: string;
begin
  IMEContext := ImmGetContext(Handle);
  if IMEContext <> 0 then
  try
    if FWin9X then // This code is under windows 98 ----------------------------
    begin
      l := ImmGetCompositionStringA(IMEContext, GCS_RESULTSTR, nil, 0) + 10;
      SetLength(ss, l);
      for i := 1 to l do ss[i] := #0;
      l := ImmGetCompositionStringA(IMEContext, GCS_RESULTSTR, PChar(@ss[1]), l - 2);
{$IFDEF UPDATECODEPAGE}
      if not (wpDisableAutoCharsetSelection in EditOptionsEx) then
        FMemo.UpdateCodePage;
{$ENDIF}
      if l > 0 then
        FMemo.InputString(ss, true, FMemo._CodePage);
    end else
    begin // Usual XP code -----------------------------------------------------
      l := ImmGetCompositionStringW(IMEContext, GCS_RESULTSTR, nil, 0) + 10;
      SetLength(s, l);
      for i := 1 to l do s[i] := #0;
      l := ImmGetCompositionStringW(IMEContext, GCS_RESULTSTR, PChar(@s[1]), l - 2);
      if l > 0 then FMemo.InsertWideString(s, true);
    end;
  finally
    ImmReleaseContext(Handle, IMEContext);
    inherited; // We 'eat' the WM_IME_CHAR in WndProc()!
  end;
end;
{$ENDIF}

procedure TWPCustomRtfEdit.SetScrollBarSize(horz: Boolean);
var
  Code: Word;
  ScrollInfo: TScrollInfo;
  FCalcRange, FCalcPage, FCalcPosition: Integer;
begin
  if not Visible or (FMemo = nil) or not HandleAllocated then exit;
  if horz then
  begin
    if WordWrap then
    begin
      FCalcPage := 0;
      FCalcPosition := 0;
      FCalcRange := 0;
    end else
    begin
      if LayoutMode in [wplayNormal, wpWordWrapView, wplayShowManualPageBreaks, wplayPageGap] then
        FCalcRange := FMemo.DeskWidth -
          MulDiv(XOffset * 2, WPScreenPixelsPerInch, 1440)
      else FCalcRange := FMemo.DeskWidth;
      if FCalcRange > 0 then
      begin
        FScrollHMulti := 20000 / FCalcRange;
        if FScrollHMulti > 1 then FScrollHMulti := 1;
        FCalcRange := Round(FCalcRange * FScrollHMulti);
      end
      else FScrollHMulti := 1;
      FCalcPage := Trunc(FMemo.WindowWidth * FScrollHMulti);
      FCalcPosition := Trunc(FMemo.LeftOffset * FScrollHMulti);
    end;
    Code := SB_HORZ;
  end else
  begin
    if SinglePageMode and (LayoutMode in [wplayLayout, wplayFullLayout]) and
      (Self is TWPPreview) and (FAttachedEditBox <> nil) then
    begin
      FCalcRange := PageCount - 1;
      FCalcPage := Columns;
      FCalcPosition := PageNumber;
    end else
    begin
      FCalcRange := FMemo.DeskHeight;
      if FCalcRange > 0 then
      begin
        FScrollVMulti := 20000 / FCalcRange;
        if FScrollVMulti > 1 then FScrollVMulti := 1;
        FCalcRange := Round(FCalcRange * FScrollVMulti);
      end
      else FScrollVMulti := 1;
      FCalcPage := Trunc(FMemo.WindowHeight * FScrollVMulti);
      FCalcPosition := Trunc(FMemo.topoffset * FScrollVMulti);
    end;
    FMemo._LocatePosition := $5250;
    Code := SB_VERT
  end;
  if FCalcRange < FCalcPage then
  begin
    FCalcRange := 0;
    FCalcPage := 0;
  end;
  if FCalcPage < 0 then FCalcPage := 0;

  if assigned(FOnUpdateExternScrollbar) then
  begin
    if horz then FOnUpdateExternScrollbar(Self, ssHorizontal, FCalcRange, FCalcPage, FCalcPosition)
    else FOnUpdateExternScrollbar(Self, ssVertical, FCalcRange, FCalcPage, FCalcPosition);
  end;

  if (FScrollBars = ssNone) or
    (horz and (FScrollBars = ssVertical)) or
    (not horz and (FScrollBars = ssHorizontal)) then
  begin
{$IFNDEF CLR}
    FillChar(ScrollInfo, SizeOf(ScrollInfo), 0);
{$ENDIF}
  end else
  begin
    ScrollInfo.cbSize := SizeOf(ScrollInfo);
    ScrollInfo.fMask := SIF_ALL;
    ScrollInfo.nMin := 0;
    ScrollInfo.nMax := FCalcRange;
    ScrollInfo.nPage := FCalcPage;
    ScrollInfo.nPos := FCalcPosition;
    ScrollInfo.nTrackPos := FCalcPosition;
  end;
  SetScrollInfo(Handle, Code, ScrollInfo, True);
end;

function TWPCustomRtfEdit.DoMouseWheelDown(Shift: TShiftState; MousePos: TPoint): Boolean;
{$IFNDEF DONT_USE_MOUSEWHEEL}var Last: Integer; {$ENDIF}
begin
  Result := inherited DoMouseWheelDown(Shift, MousePos);
{$IFNDEF DONT_USE_MOUSEWHEEL}
  if not Result and not (wpNoVertScrolling in EditOptions) then
  begin
    if FMemo.RTFData._LastReformatWasSpeedReformat then ReformatAll;
    Last := FMemo.TopOffset;
    FMemo.TopOffset := FMemo.TopOffset + 72 div 4;

{$IFDEF PAGENHINT_WHEEL}
    if WPPageHintStr <> '' then
    begin
      FInScrollTrackMode := TRUE;
      DelayedInvalidate;
    end;
{$ENDIF}

    if FMemo.TopOffset > Last then Invalidate
    else
    begin
      Last := WPBROADCAST_MOUSEWHEEL_ATEND;
      DoBroadcastMsg(Memo, Last, nil);
    end;
  end;
{$ENDIF}
end;

function TWPCustomRtfEdit.DoMouseWheelUp(Shift: TShiftState; MousePos: TPoint): Boolean;
{$IFNDEF DONT_USE_MOUSEWHEEL}var Last: Integer; {$ENDIF}
begin
  Result := inherited DoMouseWheelUp(Shift, MousePos);
{$IFNDEF DONT_USE_MOUSEWHEEL}
  if not Result and not (wpNoVertScrolling in EditOptions) then
  begin
    if FMemo.RTFData._LastReformatWasSpeedReformat then ReformatAll;
    Last := FMemo.TopOffset;
    FMemo.TopOffset := FMemo.TopOffset - 72 div 4;

{$IFDEF PAGENHINT_WHEEL}
    if WPPageHintStr <> '' then
    begin
      FInScrollTrackMode := TRUE;
      DelayedInvalidate;
    end;
{$ENDIF}

    if FMemo.TopOffset < Last then Invalidate
    else
    begin
      Last := WPBROADCAST_MOUSEWHEEL_ATSTART;
      DoBroadcastMsg(Memo, Last, nil);
    end;
  end;
{$ENDIF}
end;

procedure TWPCustomRtfEdit.DoChangeScrollPosition(
  Sender: TObject;
  RTFEngine: TWPRTFEnginePaint;
  HorzScroll: Boolean;
  var Ignore: Boolean);
begin
  SetScrollBarSize(HorzScroll);
end;

procedure TWPCustomRtfEdit.ProcessMessages;
begin
  if not FNowDestroy then
  begin
    inc(FLockDestroy);
    try
      Application.ProcessMessages;
    finally
      dec(FLockDestroy);
    end;
  end;
end;

procedure TWPCustomRtfEdit.WMWPTOOLSUPDATE(var Message: TMessage);
var Last: Integer;
  function ScrollSpeed: Integer;
  begin
    inc(FAutoScrollSpeed);
    if FAutoScrollSpeed > 400 then Result := WPScreenPixelsPerInch
    else Result := MulDiv(WPScreenPixelsPerInch, FAutoScrollSpeed, 800)
  end;
{$IFNDEF USETIMER}var tim: Cardinal; {$ENDIF}
begin
  if (csDestroying in ComponentState) or FNowDestroy then exit;
  if Message.WParam = WPUPD_SCROLL_UP then
  begin
    Last := TopOffset;
    TopOffset := TopOffset - ScrollSpeed;
    if TopOffset < Last then
    begin
      ProcessMessages;
      if FNowDestroy then exit;
      if FAutoScrollActive then StartUpdate(Message.WParam);
    end;
  end
  else if Message.WParam = WPUPD_SCROLL_DN then
  begin
    Last := TopOffset;
    TopOffset := TopOffset + ScrollSpeed;
    if TopOffset > Last then
    begin
      ProcessMessages;
      if FNowDestroy then exit;
      if FAutoScrollActive then StartUpdate(Message.WParam);
    end;
  end
  else if Message.WParam = WPUPD_SCROLL_LE then
  begin
    Last := LeftOffset;
    LeftOffset := LeftOffset - ScrollSpeed;
    if LeftOffset < Last then
    begin
      ProcessMessages;
      if FNowDestroy then exit;
      if FAutoScrollActive then StartUpdate(Message.WParam);
    end;
  end
  else if Message.WParam = WPUPD_SCROLL_RI then
  begin
    Last := LeftOffset;
    LeftOffset := LeftOffset + ScrollSpeed;
    if LeftOffset > Last then
    begin
      ProcessMessages;
      if FNowDestroy then exit;
      if FAutoScrollActive then StartUpdate(Message.WParam);
    end;
  end
  else if Message.WParam = WPUPD_DID_LOCATE then
  begin
    FMemo._DBufferIsValid := FALSE;
    Message.Result := FMemo._LocatePosition;
  end
{$IFNDEF USETIMER} // code is not active when we use a timer!
  else if Message.WParam = WPUPD_DELAYEDINVALIDATE then
  begin
    if not InWaitForPaintEditor then
    begin
      InWaitForPaintEditor := TRUE;
      tim := GetTickCount;
      if tim < FLockInvalidateTime then
      begin
        while not FNowDestroy and InWaitForPaintEditor and (GetTickCount < tim + 300) do
          ProcessMessages;
        if FNowDestroy or not InWaitForPaintEditor then exit;
        PostMessage(Self.Handle, WM_WPTOOLSUPDATE, WPUPD_DELAYEDINVALIDATE, 0)
      end
      else
      begin
        FMemo._DBufferIsValid := FALSE;
        Invalidate;
      end;
      InWaitForPaintEditor := FALSE;
    end;
  end
{$ENDIF}
  else if Message.WParam in [1..WPUPD_USERLAST] then
    FWM_WPTOOLSUPDATEFlags[Message.WParam] := FALSE;
  DoUpdate(Message.WParam, Message.LParam);
end;

procedure TWPCustomRtfEdit.StartUpdate(WPUPD_Code: Integer; Param: Integer = 0);
begin
  if FNowReformat and
    ((WPUPD_Code = WPUPD_SPEEDREFORMAT) or
    (WPUPD_Code = WPUPD_REFORMAT)) then exit;

  if FIsDynamic or _NoDelayedUpdate then DoUpdate(WPUPD_Code, Param) else
    if HandleAllocated then
    begin
      if WPUPD_Code in [1..WPUPD_USERLAST] then
      begin
        if not FWM_WPTOOLSUPDATEFlags[WPUPD_Code] then
        begin
          FWM_WPTOOLSUPDATEFlags[WPUPD_Code] := TRUE;
          PostMessage(Self.Handle, WM_WPTOOLSUPDATE, WPUPD_Code, Param);
        end;
      end else PostMessage(Self.Handle, WM_WPTOOLSUPDATE, WPUPD_Code, Param);
    end;
end;

function TWPCustomRtfEdit.PendingUpdate(WPUPD_Code: Integer): Boolean;
begin
  Result := (WPUPD_Code in [1..WPUPD_USERLAST]) and
    FWM_WPTOOLSUPDATEFlags[WPUPD_Code];
end;

procedure TWPCustomRtfEdit.DoUpdate(WPUPD_Code, Param: Integer);
var Abort: Boolean;
begin
  Abort := FALSE;
  if assigned(FOnDelayedUpdate) then
    FOnDelayedUpdate(Self, WPUPD_Code, Param);

  if FIsDynamic or (FLocked > 0) then
  begin
    FBeginEndUpdateFlags[WPUPD_Code] := TRUE;
  end else
  begin
    if WPUPD_Code = WPUPD_AFTER_LOAD then
    try
      // Make sure an attached WPPreview component is updated !
      if (FPreview <> nil) and (FPreview.FAttachedEditBox = Self) and not (csDestroying in FPreview.ComponentState) then
      begin
        InWaitForPaintEditor := FALSE;
        FPreview.InWaitForPaintEditor := FALSE;

        { it is possible that FPreview.FMemo.DisplayedText is a different block type
        inside the loaded text }
        if (FPreview.FMemo.HasData) and
          ((FPreview.FMemo.DisplayedText = nil) or not
          FPreview.FMemo.RTFData.Verify(FPreview.FMemo.DisplayedText) or
          (FPreview.FMemo.DisplayedText.Kind <> wpIsBody)) then
          FPreview.FMemo.DisplayedText :=
            FPreview.HeaderFooter.Find(wpIsBody, wpraOnAllPages);
        FPreview.Memo.InitializePaintPages;
        FPreview.Memo.ReorderPaintPages;
        FPreview.SetScrollBarSize(false);
        FPreview.SetScrollBarSize(true);
        FPreview.Resize;
      end;
    except end
    else
      if not FInResize and (WPUPD_Code = WPUPD_REORDERPAGES) then
      begin
        InWaitForPaintEditor := FALSE;
        Memo.ReorderPaintPages;
        SetScrollBarSize(true);
        SetScrollBarSize(false);
        invalidate;
      end
      else if WPUPD_Code = WPUPD_SETSCROLLBARS then
      begin
        InWaitForPaintEditor := FALSE;
        SetScrollBarSize(true);
        SetScrollBarSize(false);
      end else if WPUPD_Code = WPUPD_NEEDRESIZE then
      begin
        Resize;
      end else if WPUPD_Code = WPUPD_SHOWCURSOR then
      begin
        if FWM_WPTOOLSUPDATEFlags[WPUPD_REFORMAT] then
          FShowCursorAfterReformat := TRUE
        else
        begin
          InWaitForPaintEditor := FALSE;
          Memo.ShowCursor;
          if Focused then
          begin
            FCaret.UpdatePos;
            if assigned(FOnChangeCursorPos) then
              FOnChangeCursorPos(Self);
            if FLastCurrPar <> TextCursor.active_paragraph then
            begin
              FLastCurrPar := TextCursor.active_paragraph;
              DoUpdateParAttr;
            end;
          end;
        end;
      end else if WPUPD_Code = WPUPD_SHOWCURSOR_NOSCROLL then
      begin
        if FWM_WPTOOLSUPDATEFlags[WPUPD_REFORMAT] then
          FShowCursorAfterReformat := TRUE
        else
        begin
        // dont scroll!
          FCaret.UpdatePos;
          if assigned(FOnChangeCursorPos) then
            FOnChangeCursorPos(Self);
        end;
      end else if WPUPD_Code = WPUPD_UPDATTRIBUTES then
      begin
        DoUpdateParAttr;
        DoUpdateCharAttr;
      end else if WPUPD_Code = WPUPD_UPDSELECTION then
      begin
        InWaitForPaintEditor := FALSE;
        DoUpdateEditState;
        FMemo._DBufferIsValid := FALSE;
        invalidate;
        DoUpdateCharAttr;
        if Assigned(FOnChangeSelection) then FOnChangeSelection(Self);
      end else if WPUPD_Code = WPUPD_UNDOCHANGE then
      begin
        DoUpdateUndoState;
      end else if WPUPD_Code = WPUPD_REPAINT then
      begin
        InWaitForPaintEditor := FALSE;
        FMemo._DBufferIsValid := FALSE;
        Invalidate;
      end else
        if (WPUPD_Code = WPUPD_REFORMAT) or
          ((WPUPD_Code = WPUPD_SPEEDREFORMAT) and
          (EditBoxModes <> []))
          then
        begin
          InWaitForPaintEditor := FALSE;
          if FMemo.RTFData.RTFEngineParams.NeedReformat then
          try
            FNowReformat := TRUE;
            FMemo.RTFData.NeedReformat(false);
            FMemo.ReformatAll;
            UpdateEditBox;
            SetScrollBarSize(false);
            SetScrollBarSize(true);
          finally
            FNowReformat := FALSE;
          end;
          if FShowCursorAfterReformat and Focused then
          begin
            Memo.ShowCursor;
            FCaret.UpdatePos;
            FShowCursorAfterReformat := FALSE;
            if assigned(FOnChangeCursorPos) then
              FOnChangeCursorPos(Self);
          end;
        end
        else if WPUPD_Code = WPUPD_NEEDSELECTBODY then
        begin
          InWaitForPaintEditor := FALSE;
          CheckHasBody;
        end
        else if WPUPD_Code = WPUPD_SPEEDREFORMAT then
        begin
          InWaitForPaintEditor := FALSE;
          if not FMemo.RTFData.RTFEngineParams.NeedReformat then
          begin
            FMemo.DisplayedText.Reformat(
              FMemo.RTFData._FrmFromPage,
              FMemo.RTFData._FrmToPage
              );
            if not FMemo.RTFData._LastReformatWasSpeedReformatNeedInitPages then
            begin
              FMemo.InitializePaintPages;
              FMemo.ReorderPaintPages;
              if Focused then ShowCursor;
            end;
            Invalidate;
          end;
        end
        else if WPUPD_Code = WPUPD_NEEDFOCUS then
        begin
          if Assigned(FBeforeEditBoxNeedFocus) then
            FBeforeEditBoxNeedFocus(Self, Abort);
          if not Abort and Visible and Enabled then SetFocus;
        end;

  end; // if FLocked=0
  if assigned(FAfterDelayedUpdate) then
    FAfterDelayedUpdate(Self, WPUPD_Code, Param);
end;

function TWPCustomRtfEdit.GetRTFEngine: TWPRTFEngineBasis;
begin
  Result := FMemo;
end;

function TWPCustomRtfEdit.GetRTData: TWPRTFDataCollection;
begin
  Result := FMemo.RTFData;
end;

procedure TWPCustomRtfEdit.SetFocus;
begin
  inherited SetFocus;
  //in WMSetFocus: GetFocus;
end;

procedure TWPCustomRtfEdit.GetCellNames(List: TStrings);
begin
  FMemo.RTFData.ListNamesAndCommands([wpListParCalcNames], List);
end;

procedure TWPCustomRtfEdit.GetCellCommands(List: TStrings);
begin
  FMemo.RTFData.ListNamesAndCommands([wpListParCommands], List);
end;

procedure TWPCustomRtfEdit.DoUpdateParAttr;
begin
end;

procedure TWPCustomRtfEdit.DoUpdateCharAttr;
begin
end;

procedure TWPCustomRtfEdit.DoUpdateEditState;
begin
end;

procedure TWPCustomRtfEdit.DoUpdateUndoState;
begin
  if assigned(FOnUndoStateChanged) then
    FOnUndoStateChanged(Self);
end;

procedure TWPCustomRtfEdit.ProcessScrollEvent(
  var Message: TWMScroll;
  vertical: Boolean);
begin
  if vertical then
  begin

    if FMemo.RTFData._LastReformatWasSpeedReformat then
      ReformatAll;

  // if WP_Global_Disable then exit;
  //WhileScrollEvent := TRUE;
    case Message.ScrollCode of
      SB_LINEUP: FMemo.TopOffset := FMemo.TopOffset - 72 div 4;
      SB_LINEDOWN: FMemo.TopOffset := FMemo.TopOffset + 72 div 4;
      SB_PAGEUP: FMemo.TopOffset := FMemo.TopOffset - FMemo.WindowHeight;
      SB_PAGEDOWN: FMemo.TopOffset := FMemo.TopOffset + FMemo.WindowHeight;
      SB_THUMBPOSITION: FMemo.TopOffset := Trunc(Message.Pos / FScrollVMulti);
      SB_THUMBTRACK:
        if FMemo.LayoutMode <> wpThumbNailView then
        begin
          FInScrollTrackMode := TRUE;
          FMemo.TopOffset := Trunc(Message.Pos / FScrollVMulti);
        end else exit;
      SB_TOP: FMemo.TopOffset := 0;
      SB_BOTTOM: FMemo.TopOffset := MaxInt;
      SB_ENDSCROLL: FInScrollTrackMode := FALSE;
    else
      exit;
    end;
  // FMemo.VNowScroll(ScrollCode, Message.Pos);
  // SetScrollBarSize(false);
    if Transparent then Invalidate else
      FMemo.PaintDesktop(Canvas, ClientWidth, ClientHeight, [wpClearDoubleBuffer]);
    if assigned(FOnPaint) then FOnPaint(Self);
  // if assigned(FMemo.OnYPosChanged) then FMemo.OnYPosChanged(Self);
  end else // ------------------------------------------------------------------
  begin
  // if WP_Global_Disable then exit;
  // WhileScrollEvent := TRUE;
    case Message.ScrollCode of
      SB_LINEUP: FMemo.LeftOffset := FMemo.LeftOffset - 72;
      SB_LINEDOWN: FMemo.LeftOffset := FMemo.LeftOffset + 72;
      SB_PAGEUP: FMemo.LeftOffset := FMemo.LeftOffset - FMemo.WindowWidth;
      SB_PAGEDOWN: FMemo.LeftOffset := FMemo.LeftOffset + FMemo.WindowWidth;
      SB_THUMBPOSITION: FMemo.LeftOffset := Trunc(Message.Pos / FScrollHMulti);
      SB_THUMBTRACK:
        if FMemo.LayoutMode = wpThumbNailView then
          exit
        else FMemo.LeftOffset := Trunc(Message.Pos / FScrollHMulti);
      SB_TOP: FMemo.LeftOffset := 0;
      SB_BOTTOM: FMemo.LeftOffset := MaxInt;
   // SB_ENDSCROLL: FMemo.LeftOffset := Trunc(Message.Pos/FScrollHMulti);
    else
      exit;
    end;
 { if HScrollRange > 0 then
    FMemo.HNowScroll(ScrollCode, FMemo.ScreenToTwip(Message.Pos))
  else
    FMemo.HNowScroll(ScrollCode, 0);  }
  // FMemo.HNowScroll(ScrollCode, Message.Pos);
  // SetScrollBarSize(true);
    FMemo.PaintDesktop(Canvas, ClientWidth, ClientHeight, [wpClearDoubleBuffer]);
    if assigned(FOnPaint) then FOnPaint(Self);
  // if assigned(FMemo.OnXPosChanged) then FMemo.OnXPosChanged(Self);
  end;
end;

procedure TWPCustomRtfEdit.WMHScroll(var Message: TWMScroll);
begin
  inherited;
  ProcessScrollEvent(Message, false);
end;

procedure TWPCustomRtfEdit.WMVScroll(var Message: TWMScroll);
begin
  inherited;
  if SinglePageMode and (LayoutMode in [wplayLayout, wplayFullLayout]) and
    (Self is TWPPreview) then
  begin
    case Message.ScrollCode of
      SB_LINEUP, SB_PAGEUP: PageNumber := PageNumber - 1;
      SB_LINEDOWN, SB_PAGEDOWN: PageNumber := PageNumber + 1;
      SB_THUMBTRACK, SB_THUMBPOSITION:
        begin
          FInScrollTrackMode := TRUE;
          PageNumber := Message.Pos;
        end;
      SB_TOP: PageNumber := 0;
      SB_BOTTOM: PageNumber := MaxInt;
      SB_ENDSCROLL: FInScrollTrackMode := FALSE;
    end;
    SetScrollBarSize(false);
  end else ProcessScrollEvent(Message, true);
end;

//##############################################################################
// Spellcheck Interface
//##############################################################################

function TWPCustomRtfEdit.StartSpellCheck(Mode: TWPStartSpellcheckMode): Boolean;
var
  par: PTParagraph;
  i: Integer;
begin
  if Mode = wpStopSpellAsYouGo then
  begin
    par := Memo.RTFData.FirstPar;
    while par <> nil do
    begin
      for i := 0 to par.CharCount - 1 do
        par.CharAttr[i] := par.CharAttr[i] and not (cafsMisspelled or cafsWasChecked);
      exclude(par.prop, paprNeedSpellCheckBeforePaint);
      par := par.globalnext;
    end;
    Memo.RePaint;
  end;
  if assigned(FOnStartSpellCheck) then
  begin
    FOnStartSpellCheck(Self, Mode);
    Result := TRUE;
  end
  else
    if (GlobalWPToolsCustomEnviroment <> nil) and
      (GlobalWPToolsCustomEnviroment is TWPToolsEnviroment) and
      assigned(TWPToolsEnviroment(GlobalWPToolsCustomEnviroment
      ).FSpellEngine_OnStartSpellcheck) then
    begin
      TWPToolsEnviroment(GlobalWPToolsCustomEnviroment
        ).FSpellEngine_OnStartSpellcheck(Self, Mode);
      Result := TRUE;
    end
    else Result := FALSE;
  if Mode = wpStartSpellAsYouGo then
    Refresh(True);
end;


procedure TWPCustomRtfEdit.Spell_ReplaceWord(const s: string);
begin
  SelectionAsString := s;
end;

procedure TWPCustomRtfEdit.Spell_SelectWord;
begin
  FMemo._DBufferIsValid := FALSE;
  Invalidate;
  ShowCursor;
end;

procedure TWPCustomRtfEdit.Spell_SelectWordXY(var x, y: Integer);
begin
end;

function TWPCustomRtfEdit.Spell_GetNextWord: string;
var par1: TParagraph; pos1: Integer;
begin
  Result := '';
  with TextCursor do
  begin
    if active_paragraph <> nil then
    begin
      while IsWordDelimiter and MoveNext(1) do ;
      if not IsWordDelimiter then
      begin
        par1 := active_paragraph;
        pos1 := active_posinpar;
        // SelectFromHere(active_paragraph, active_posinpar);
        while not IsWordDelimiter do
        begin
          Result := Result + CPChar;
          MoveNext(1);
        end;
        SpeedSelectFromTo(par1, pos1, active_paragraph, active_posinpar);
      end;
    end;
  end;
end;

procedure TWPCustomRtfEdit.Spell_FromStart;
begin
  CPPosition := 0;
end;

procedure TWPCustomRtfEdit.Spell_FromCursorPos;
begin
  // nothing ...
end;

function TWPCustomRtfEdit.Spell_TopPosition: Integer;
var r: TRect;
begin
  ShowCursor;
  r := SelRect;
  r.TopLeft := ClientToScreen(r.TopLeft);
  Result := r.Top;
end;

procedure TWPCustomRtfEdit.Spell_RemoveMarkers;
var
  par: TParagraph;
  i: Integer;
begin
  par := FirstPar;
  while par <> nil do
  begin
    for i := 0 to par.CharCount - 1 do
    begin
      par.CharAttr[i] := (par.CharAttr[i] and not cafsMisspelled) and not cafsWasChecked;
    end;
    par := par.next;
  end;
  RePaint;
end;

procedure TWPCustomRtfEdit.Spell_IgnoreWord(const AWord: string; MarkCorrect: Boolean);
var
  par: TParagraph;
  l, i, j: Integer;
  ca: Cardinal;
begin
  par := FirstPar;
  if par = nil then exit;
  l := Length(AWord);
  if l > 0 then
  begin
    while par <> nil do
    begin
      i := 0;
      while i < par.CharCount - l + 1 do
      begin
        if par.IsWordDelimiter(i + l) and par.IsWordDelimiter(i - 1) and
          par.Compare(i, AWord, false) then
        begin
          for j := 0 to l - 1 do
          begin
            ca := par.CharAttr[i + j];
            ca := ca and not cafsMisspelled;
            if (MarkCorrect) then
              ca := ca or cafsWasChecked
            else ca := ca and not cafsWasChecked;
            par.CharAttr[i + j] := ca;
          end;
          inc(i, l);
        end else inc(i);
      end;
      par := par.next;
    end;
  end;
  Repaint;
end;


//##############################################################################
// UNDO methods
//##############################################################################

function TWPCustomRtfEdit.Undo: Boolean;
var cp: Integer;
begin
  FMemo.RTFData._ActivateRedo := wpActivateRedo in EditOptions;
  cp := CPPosition;
  Result := FMemo.RTFData.Undo;
  if Result then
  begin
    if CPPosition = 0 then CPPosition := cp;
    CheckHasBody;
    TextCursor.GetCharAttr;
    SetFocusValues(true);
    ChangeApplied;
    StartUpdate(WPUPD_UNDOCHANGE);
    invalidate;
  end;
end;

function TWPCustomRtfEdit.Redo: Boolean;
begin
  Result := Memo.RTFData.Redo;
  if Result then
  begin
    TextCursor.GetCharAttr;
    SetFocusValues(true);
    ChangeApplied;
    StartUpdate(WPUPD_UNDOCHANGE);
    invalidate;
  end;
end;

function TWPCustomRtfEdit.CanUndo: Boolean;
begin
  Result := Memo.RTFData.CanUndo;
end;

function TWPCustomRtfEdit.CanRedo: Boolean;
begin
  Result := Memo.RTFData.CanRedo;
end;

procedure TWPCustomRtfEdit.UndoClear;
begin
  Memo.RTFData.UndoClear;
end;

procedure TWPCustomRtfEdit.StartUndolevel;
begin
{$IFDEF ALLOWUNDO}
  Memo.RTFData.StartUndolevel;
{$ENDIF}
end;

procedure TWPCustomRtfEdit.EndUndolevel;
begin
{$IFDEF ALLOWUNDO}
  Memo.RTFData.EndUndolevel;
{$ENDIF}
end;

procedure TWPCustomRtfEdit.NewUndolevel;
begin
{$IFDEF ALLOWUNDO}
  Memo.RTFData.AlwaysNewUndolevel;
{$ENDIF}
end;

{$IFDEF ALLOWUNDO}

procedure TWPCustomRtfEdit.UndoBufferSaveTo(aStyle: TWPTextStyle; typ: TWPUndoType; kind: TWPUndoKind = wputAny);
begin
  Memo.RTFData.UndoBufferSaveTo(aStyle, typ, kind);
end;
{$ENDIF}

//##############################################################################
// Select Procedure
//##############################################################################

function TWPCustomRtfEdit.HideSelection: Boolean;
begin
  Result := Memo.Cursor.HideSelection;
  if Result then
  begin
    invalidate;
    Memo._DBufferIsValid := FALSE;
  end;
end;

function TWPCustomRtfEdit.ClearSelection(OverwriteProtection: Boolean = FALSE): Boolean;
var sel: TWPSelectionContents;
  old_undo: Boolean;
begin
  sel := FMemo.Cursor.SelectionContents; //TWPSelectionContents
  if not FInCutToClipboard and
    (wpSelTableCells in sel) and not (wpSelCompleteTable in sel) then Result := FALSE
  else
  begin
    old_undo := Memo.Cursor.RTFData.ActivateUNDO;
    Memo.Cursor.RTFData.ActivateUNDO := old_undo or (wpActivateUndo in EditOptions);
    Result := Memo.Cursor.ClearSelection(true, OverwriteProtection, false);
    Memo._DBufferIsValid := FALSE;
    Memo.Cursor.RTFData.ActivateUNDO := old_undo;
  end;
  DelayedReformat;
end;

procedure TWPCustomRtfEdit.SetSelPosLen(pos, len: Integer; UpdateDisplay: Boolean = FALSE);
begin
  HideSelection;
  Memo.Cursor.SetSelPosLen(pos, len);
  if UpdateDisplay then Repaint;
end;

function TWPCustomRtfEdit.GetSelPosLen(var pos, len: Integer): Boolean;
begin
  Result := Memo.Cursor.GetSelPosLen(pos, len);
end;

procedure TWPCustomRtfEdit.SelectAll;
begin
  SetSelPosLen(0, MaxInt);
end;

procedure TWPCustomRtfEdit.SelectParagraph(par: TParagraph = nil);
begin
  TextCursor.SelectParagraph(par);
end;

function TWPCustomRtfEdit.SelectPage(pagenr: Integer): Boolean;
begin
  Result := SelectPages(pagenr, pagenr);
end;

function TWPCustomRtfEdit.GetPagesAsString(frompage, topage: Integer; const format: string = 'ANSI'): string;
begin
  if SelectPages(frompage, topage) then
  begin
    Result := AsANSIString(format, true);
    HideSelection;
  end
  else Result := '';
end;

function TWPCustomRtfEdit.SelectPages(startpage, endpage: Integer): Boolean;
var par: TParagraph;
  posinpar: Integer;
begin
  Result := FALSE;
  if (startpage < CountPages) and Memo.GetFirstParOnPage(startpage, par, posinpar) then
  begin
    TextCursor.MoveTo(par, posinpar);
    TextCursor.SelectFromHere(par, posinpar);
    if CountPages <= endpage + 1 then
    begin
      par := LastPar;
      posinpar := par.CharCount;
    end else if not Memo.GetFirstParOnPage(endpage + 1, par, posinpar) then
    begin
      HideSelection;
      exit;
    end;
    Result := TextCursor.SelectToHere(par, posinpar);
  end;
end;

procedure TWPCustomRtfEdit.SelectWord;
begin
  with TextCursor do
  begin
    if (active_posinpar > 0) and active_paragraph.IsWordDelimiter(active_posinpar) and
      not active_paragraph.IsWordDelimiter(active_posinpar - 1) then CPMoveBack; //V5.17.3

    while not active_paragraph.IsWordDelimiter(active_posinpar) and
      (active_posinpar > 0) and //V5.17.3
      CPMoveBack do ;
    if active_paragraph.IsWordDelimiter(active_posinpar) then CPMoveNext;
    SelectFromHere(active_paragraph, active_posinpar);
    while not active_paragraph.IsWordDelimiter(active_posinpar) and
      CPMoveNext do ;
    SelectToHere(active_paragraph, active_posinpar);
  end;
end;

procedure TWPCustomRtfEdit.SelectCell(par: TParagraph = nil; add: Boolean = FALSE);
var sel: Boolean;
  atbl, arow, acell: TParagraph;

begin
  with TextCursor do
  begin
    if par = nil then par := TableCell;
    if par <> nil then
    begin
      atbl := par.ParentTable;
      if atbl = nil then exit;
      // Must be in same Table !
      if not add or
        ((block_s_par <> nil) and (block_s_par.ParentTable <> atbl)) then
      begin
        TextCursor.HideSelection;
        sel := TRUE;
      end else sel := not (paprCellIsSelected in par.prop);

      // Select!
      if sel then
      begin
        include(par.prop, paprCellIsSelected);
        par.IncludeProp(paprIsSelected);
      end else
      begin
        exclude(par.prop, paprCellIsSelected);
        par.ExcludeProp(paprIsSelected);
      end;
      // Fix par_blockcount
      block_s_par := nil;
      block_e_par := nil;
      block_reverse := FALSE;
      parblock_count := 0;
      block_s_posinpar := 0;
      arow := atbl.RowFirst;
      while arow <> nil do
      begin
        acell := arow.ChildPar;
        while acell <> nil do
        begin
          if paprCellIsSelected in acell.prop then
          begin
            inc(parblock_count);
            if block_s_par = nil then
              block_s_par := acell;
            block_e_par := acell;
          end;
          acell := acell.NextPar;
        end;
        arow := arow.NextPar;
      end;
      if block_e_par <> nil then
      begin
        if block_e_par.ChildPar <> nil then
          block_e_par := block_e_par.LastInnerChild;
        block_e_posinpar := block_e_par.CharCount;
      end;
      RePaint;
    end;
  end;
end;

procedure TWPCustomRtfEdit.SelectLine;
begin
  TextCursor.SelectLine;
end;

procedure TWPCustomRtfEdit.MovePosition(how: TWPMoveMode; DoSelection: Boolean);
begin
  FMemo.c_move(how, DoSelection);
end;

// Depreceated !!

procedure TWPCustomRtfEdit.GetPosition(var pos, lin, par, pos_in_par: Integer);
var apar, epar: TParagraph;
begin
  pos := 0;
  lin := 0;
  par := 0;
  pos_in_par := 0;
  apar := FirstPar;
  epar := ActiveParagraph;
  while (apar <> nil) and (apar <> epar) do
  begin
    inc(pos, apar.CharCount);
    inc(lin, apar.LineCount);
    inc(par);
    apar := apar.next;
  end;
  if (apar <> nil) and (apar = epar) then
  begin
    pos_in_par := ActivePosInPar;
    inc(pos, pos_in_par);
    inc(lin, apar.LineOfPos(pos_in_par));
  end;
end;

procedure TWPCustomRtfEdit.SetPosition(topos, tolin, topar, topos_in_par: Integer);
var apar: TParagraph;
  lin, par: Integer;
begin
  if (topos <> 0) or
    ((tolin = 0) and (topar = 0) and (topos_in_par = 0))
    then
    CPPosition := topos
  else
  begin
    lin := 0;
    par := 0;
    apar := FirstPar;
    while apar <> nil do
    begin
      if (tolin <> 0) and (lin + apar.LineCount > tolin) then
      begin
        Memo.Cursor.MoveTo(apar, apar.LineOffset(tolin - lin));
        exit;
      end
      else if (topar <> 0) and (par = topar) then
      begin
        Memo.Cursor.MoveTo(apar, topos_in_par);
        exit;
      end;
      inc(lin, apar.LineCount);
      inc(par);
      if apar.next = nil then
      begin
        Memo.Cursor.MoveTo(apar, apar.CharCount);
        break;
      end;
      apar := apar.next;
    end;
  end;
end;

procedure TWPCustomRtfEdit.ScrollToPosition(pos: Longint; relx, rely: Integer);
var
  posinpar, PaintPageNr, x, y: Integer;
  par: TParagraph;
begin
  if (ActiveText <> nil) then
  begin
    par := ActiveText.SetPosition(pos, posinpar);
    if (par <> nil) and Memo.GetXYPositionAtRTF(ActiveText, par, posinpar, PaintPageNr, x, y) then
    begin
      x := x + Memo.PaintPageLeft[PaintPageNr] - relx;
      y := y + Memo.PaintPageLeft[PaintPageNr] - rely;
      Memo.TopOffset := y;
      Memo.LeftOffset := x;
      Invalidate;
    end;
  end;
end;

procedure TWPCustomRtfEdit.InternBeforePasteEvent(
  RTFData: TWPRTFDataCollection; Stream: TStream;
  Reader: TWPCustomTextReader; OnlyBodyText: Boolean;
  var LoadedText: TWPRTFDataBlock);
begin
  if assigned(FBeforePasteText) then
    FBeforePasteText(Self, RTFData,
      LoadedText.FirstPar, Stream, Reader, OnlyBodyText, LoadedText);
end;

function TWPCustomRtfEdit.ClipbrdFormatName(cfFormat: Integer): string;
begin
  if cfFormat = FormatRTF then
    Result := 'RTF'
  else if cfFormat = FormatWPT then
    Result := 'WPTOOLS'
  else if cfFormat = FormatHTM then
    Result := 'HTML'
  else if cfFormat = CF_TEXT then
    Result := 'ANSI'
  else if cfFormat = CF_UNICODETEXT then
    Result := 'UNICODE'
  else Result := '';
end;


procedure TWPCustomRtfEdit.PasteFromClipboard;
var
  Stream: TMemoryStream;
  AppendSPC, load, Abort, NoWHAdjust: Boolean;
  ImageLink: string;
  pers: TPersistent;
{$IFNDEF CLR}
  p: PChar;
  p2: PChar;
  p3: PWideChar;
{$ELSE}
  p: IntPtr;
  Buffer: TBytes;
{$ENDIF}
  MemHand: THandle;
  siz2, siz3: Integer;
  comp: TComponent;
  wpobj: TWPObject;
  temp: TPicture;
  w, h: Integer;
  m1, m2: Single;
  readerclass: TWPToolsReaderWriterClass;
  Reader: TWPCustomTextReader;
  TryWithImages, FReadPictOpt: Boolean;
  extra_frm: string;
begin
  Stream := nil;
  Reader := nil;
  load := false;
  TryWithImages := TRUE;
  FReadPictOpt := FALSE;
  if not Changing then exit;

  if (wpNoEditOutsideTable in Editoptions) and (ActiveParagraph.Cell = nil) then exit;
  //V5.13.5 Check for protected text!
  if FMemo.IsProtected(ActiveParagraph, ActivePosInPar, true) <> [] then
    exit;

  ClipBoard.Open;
  ImageLink := '';

  readerclass := nil;

  extra_frm := '';
  if wpcoDontPasteGraphics in ClipboardOptions then
    extra_frm := extra_frm + '-noimages,'; // NoImages

{$IFNDEF ALWAYS_PASTENESTEDTABLE} // behaviour before V5.13.5!
  if not (wpcoPasteAsNestedTable in ClipboardOptions) then
    extra_frm := extra_frm + '-dontnesttable,';
{$ENDIF}

  if (wpcoDontPasteFonts in ClipboardOptions) then
    extra_frm := extra_frm + '-ignorefonts,';

  if (wpcoDontPasteFontSizes in ClipboardOptions) then
    extra_frm := extra_frm + '-ignorefontsize,';

  extra_frm := extra_frm + '-clipboardoperation,';

  FMemo._InClipboardOP := TRUE;
  try
    // FMemo.StartUndolevel;
    try
      siz3 := 0;

      if not (wpcoDontPasteWPT in ClipboardOptions) and (ClipBoard.HasFormat(FormatWPT)) and (FMemo.GetReaderClass(nil, 'WPTOOLS' + extra_frm) <> nil) then
      begin
        MemHand := ClipBoard.GetAsHandle(FormatWPT);
        if MemHand <> 0 then
        begin
          readerclass := FMemo.GetReaderClass(nil, 'WPTOOLS' + extra_frm);
          siz3 := 1;
        end;
      end else MemHand := 0;

      if (MemHand = 0) then
      begin
        if (FMemo.GetReaderClass(nil, 'HTML' + extra_frm) <> nil) and
          (ClipBoard.HasFormat(FormatHTM)) and
          ((wpcoPasteHTMLWhenAvailable in FClipboardOptions) or
          not ClipBoard.HasFormat(FormatRTF)) then
        begin
          MemHand := ClipBoard.GetAsHandle(FormatHTM);
          if MemHand <> 0 then
          begin
            readerclass := FMemo.GetReaderClass(nil, 'HTML' + extra_frm);
            FReadPictOpt := ClipBoard.HasFormat(CF_BITMAP);
            siz3 := 1;
          end;
        end;
      end;

      if (MemHand = 0) and not (wpcoDontPasteRTF in FClipboardOptions) and
        (ClipBoard.HasFormat(FormatRTF)) then
      begin
        readerclass := FMemo.GetReaderClass(nil, 'RTF' + extra_frm);
        if readerclass <> nil then
        begin
          MemHand := ClipBoard.GetAsHandle(FormatRTF);
        end;
      end;

      if (MemHand = 0) and not (wpcoDontPasteUNICODE in FClipboardOptions)
        and ClipBoard.HasFormat(CF_UNICODETEXT) then
      begin
        readerclass := FMemo.GetReaderClass(nil, 'UNICODE');
        if readerclass <> nil then
        begin
          MemHand := ClipBoard.GetAsHandle(CF_UNICODETEXT);
          siz3 := 2;
        end;
      end;

      if (MemHand = 0) and not (wpcoDontPasteANSI in FClipboardOptions)
        and ClipBoard.HasFormat(CF_TEXT) then
      begin
        readerclass := FMemo.GetReaderClass(nil, 'ANSI');
        if readerclass <> nil then
        begin
          MemHand := ClipBoard.GetAsHandle(CF_TEXT);
          siz3 := 1;
          // Experiment: Test for FireFox HTML Code
         { if wpcoPasteHTMLWhenAvailable in FClipboardOptions then
          begin
            p := GlobalLock(MemHand);
            if p <> nil then
            begin
              siz2 := GlobalSize(MemHand);
              if siz2 > 200 then siz2 := 200;
              SetString(str, p, siz2);
              if (Pos('StartFragment', str) > 0) and (Pos('EndFragment', str) > 0) and (Pos('<html>', str) > 0) then
              begin
                 readerclass := FMemo.GetReaderClass(nil, 'HTML' + extra_frm);
                 if readerclass=nil then readerclass := FMemo.GetReaderClass(nil, 'ANSI')
                 else siz3 := 1;
              end;
              GlobalUnLock(MemHand);
            end;
          end; }
        end;
      end;

      if ReaderClass <> nil then
        Reader := ReaderClass.Create(FMemo.RTFData) as TWPCustomTextReader
      else Reader := nil;

      if (MemHand <> 0) and (Reader <> nil) then
      try
        if FReadPictOpt then
        begin
          Reader._DefaultImage := TPicture.Create;
          Reader._DefaultImage.Assign(Clipboard);
        end;

        TryWithImages := FALSE;
        Stream := TMemoryStream.Create;
        siz2 := GlobalSize(MemHand);
        if siz2 <= 0 then exit;
        p := GlobalLock(MemHand);
        if p = nil then Exit;
        // Only the RTFReader will detect the end of the data.
        if siz3 = 1 then // ANSI
        begin
          p2 := p;
          siz3 := siz2;
          siz2 := 0;
          while siz3 > 0 do
          begin
            if p2^ = #0 then break;
            inc(p2);
            dec(siz3);
            inc(siz2);
          end;
        end else
          if siz3 = 2 then // unicode
          begin
            p3 := Pointer(p);
            siz3 := siz2 div 2;
            siz2 := 0;
            while siz3 > 0 do
            begin
              if p3^ = #0 then break;
              inc(p3);
              dec(siz3);
              inc(siz2, 2);
            end;
          end;
{$IFDEF CLR}
        SetLength(Buffer, siz2);
        Marshal.Copy(p, Buffer, 0, Length(Buffer));
        Stream.WriteBuffer(Buffer, Length(Buffer));
        Stream.Position := 0;
{$ELSE}
        Stream.SetSize(siz2);
        Stream.Write(PChar(p)^, siz2);
        GlobalUnLock(MemHand);
{$ENDIF}
        if wpClipDebug in FDebugMode then
        begin
          Stream.SaveToFile('c:\clpbrd.txt');
          MessageBox(Handle, 'c:\clpbrd.txt has been written', '', 0);
        end;
        Stream.Position := 0;
        ClearSelection(false);
        AppendSPC :=
          not (wpcoDontAutoAppendSpace in FClipboardOptions) and
          not (CPChar in [#32, #9, #160, #10, #13, #1, #2, #3, '<', '>', '(', ')', ':', '.', '!', '?', '\', '/']);
        Reader.LoadHTMLOptions := [loIgnoreTextOutsideOfHTMLTag, loIgnoreTextOutsideOfBodyTag];
        Reader.SetOptions(extra_frm);
        load := FMemo.LoadFromStream(Stream,
          not (wpcoDoNotUseInsertMode in FClipboardOptions)
          , '', false, Reader, InternBeforePasteEvent);
        if load and AppendSPC and (ActivePosInPar > 0) then
        begin
          if CPMoveBack then
          begin
            AppendSPC := not (CPChar in [#32, #9, #160, #10, #13, #1, #2, #3, '<', '>', '(', ')', ':']);
            CPMoveNext;
            if AppendSPC then
            begin
              InputString(#32);
            end;
          end;
        end;
      finally
        Stream.Free;
      end;
    finally
      if Reader <> nil then
      begin
        Reader._DefaultImage.Free;
        Reader.Free;
      end;
    end;

    if load then ChangeApplied; // Set Modified

    if not TryWithImages then exit;

    { Load Pictures }
    if ClipBoard.HasFormat(CF_COMPONENT) then
    begin
      comp := ClipBoard.GetComponent(Self, Self);
      if not (comp is TWPObject) then
      begin
        comp.Free;
        comp := nil;
      end;
    end
    else
      comp := nil;
    if comp <> nil then
    begin
      wpobj := comp as TWPObject;
      if assigned(FBeforePasteImage) then FBeforePasteImage(Self, HeaderFooter, wpobj);
      if wpobj <> nil then
      begin
        TextObjects.Insert(wpobj);
        ChangeApplied; // Set Modified
      end;
    end
    else if not (wpcoDontPasteGraphics in FClipboardOptions) and (
      not load and (ClipBoard.HasFormat(CF_METAFILEPICT)
      or ClipBoard.HasFormat(CF_ENHMETAFILE)
      or ClipBoard.HasFormat(CF_BITMAP)
      or ClipBoard.HasFormat(CF_PICTURE))) then
    begin
      temp := TPicture.Create;
      try
        try
          temp.Assign(Clipboard);
          Abort := FALSE;
          NoWHAdjust := FALSE;
          ImageLink := '';
        //  if assigned(FOnBeforePasteImage) then
        //        FOnBeforePasteImage( Self, temp, ImageLink, NoWHAdjust, Abort );
          if not Abort and not temp.Graphic.empty then
          begin
            h := MulDiv(temp.Graphic.Height, 1440, Screen.PixelsPerInch);
            w := MulDiv(temp.Graphic.Width, 1440, Screen.PixelsPerInch);
            if not NoWHAdjust and
              ((w > Header._Layout.paperw - Header._Layout.margl - Header._Layout.margr)
              or (h > Header._Layout.paperh - Header._Layout.margt - Header._Layout.margb)) then
            begin
              m1 := (Header._Layout.paperw - Header._Layout.margl - Header._Layout.margr) / w;
              m2 := (Header._Layout.paperh - Header._Layout.margt - Header._Layout.margb) / h;
              if m1 < m2 then
              begin
                w := Round(w * m1); h := Round(h * m1);
              end
              else
              begin
                w := Round(w * m2); h := Round(h * m2);
              end;
            end
            else
            begin
              w := 0;
              h := 0;
            end;
            if temp.Graphic is TPersistent then
            begin
              pers := TPersistent(temp.Graphic);
              if TextObjects.NewWPObjectFromData(true, pers, wpobj, w, h) then
              begin
                wpobj.WidthTW := w;
                wpobj.HeightTW := h;
                if assigned(FBeforePasteImage) then FBeforePasteImage(Self, HeaderFooter, wpobj);
                if wpobj <> nil then
                begin
                  TextObjects.Insert(wpobj, wpobj.WidthTW, wpobj.HeightTW, '', ImageLink);
                  wpobj.Compress;
                  ChangeApplied;
                end;
              end;
            end;
          end;
        except
        end;
      finally
        temp.Free;
      end;
    end;
  finally
    ClipBoard.Close;
    FMemo._InClipboardOP := FALSE;
    ReformatAll; invalidate;
  end;
end;

procedure TWPCustomRtfEdit.CutToClipboard;
var
  DoCut: boolean;
begin
  DoCut := TRUE;
  if (wpcoDontCopyProtectedText in ClipBoardOptions) and
    TextCursor.IsSelectionProtected then exit;
  if Assigned(FBeforeCutEvent) then
    FBeforeCutEvent(Self, DoCut);
  if not DoCut then exit;

  FInCutToClipboard := TRUE;
  try
    CopyToClipboard;
    ClearSelection;
  finally
    FInCutToClipboard := FALSE;
  end;
end;


procedure TWPCustomRtfEdit.CopyToClipboard(CompleteText: Boolean = FALSE);
var
  Stream: TMemoryStream;
  c, anz: Integer;
  extra_frm: string;
 // OldFormat: TWPNewLoadFormat;
{$IFNDEF CLR}
  p: PChar;
  RTFMemHand, WPTMemHand, ANSIMemHand, UNIMemHand: THandle;
{$ENDIF}
  endc: Integer;
  FCopyToClipboard: Boolean;
  // APalette : HPALETTE;
 { par_s, par_e: PTParagraph;
  cp_s, cp_e: Integer;
  obj: TWPObject;   }
{$IFDEF CLR}
  procedure SetBuffer(Format: Word; Buffer: TBytes; Size: Integer);
  var
    Data: THandle;
    DataPtr: IntPtr;
  begin
    Data := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE, Size);
    try
      DataPtr := GlobalLock(Data);
      try
        Marshal.Copy(Buffer, 0, DataPtr, Size);
        Clipboard.SetAsHandle(Format, Data);
      finally
        GlobalUnlock(Data);
      end;
    except
      GlobalFree(Data);
      raise;
    end;
  end;
{$ENDIF}
begin
  FCopyToClipboard := TRUE;
  if FInCutToClipboard and Assigned(FBeforeCutEvent) then
    FBeforeCutEvent(Self, FCopyToClipboard)
  else
  begin
    if (wpcoDontCopyProtectedText in ClipBoardOptions) and
      TextCursor.IsSelectionProtected then exit;
    if Assigned(FBeforeCopyEvent) then
      FBeforeCopyEvent(Self, FCopyToClipboard);
  end;
  if not FCopyToClipboard then exit;

  FMemo._InClipboardOP := TRUE;
  try
{$IFNDEF CLR}
    RTFMemHand := 0;
    ANSIMemHand := 0;
    WPTMemHand := 0;
    UNIMemHand := 0;
{$ENDIF}
    endc := 0;

    (* TODO
    if not CompleteText and (TextObjects.Selected <> nil) then
    begin
      { DOES NOT WORK: ALWAY 'WRONG' CLIPBOARD FORMAT !!!
       ANSIMemHand := TextObjects.Selected.CopyDataToClipboard(Format,APalette);
       if ANSIMemHand<>0 then
       begin
         ClipBoard.Clear;
         ClipBoard.SetAsHandle(Format, RTFMemHand);
         if APalette<>0 then
             SetClipboardData(CF_PALETTE, APalette);
       end; }
      obj := TextObjects.Selected;
    //  obj.CopyToClipboard;
    // if FInCutToClipboard then
    //    TextObjects.Delete(obj);
    end
    else  *)

    if IsSelected or CompleteText then
    begin
      ClipBoard.Open;
      ClipBoard.Clear;

      extra_frm := '';
      if wpcoDontPasteGraphics in ClipboardOptions then
        extra_frm := extra_frm + '-noimages,'; // NoImages

      if wpcoDontCopyProtectedAttribute in ClipboardOptions then
        extra_frm := extra_frm + '-noafsProtected,'; // Dont write protected attribute

      Stream := TMemoryStream.Create;
      try
        // ----------------------------------------------------------------  RTF
        if not (wpcoDontCopyRTF in ClipboardOptions) and
          (Memo.GetWriterClass('RTF') <> nil) then
        begin
          if CompleteText then SaveToStream(Stream, 'RTF' + extra_frm)
          else SaveSelectionToStream(Stream, 'RTF' + extra_frm);
          Stream.Write(endc, SizeOf(endc));
          c := Stream.Size;
          if c > SizeOf(endc) then
          begin
{$IFDEF CLR}
            SetBuffer(FormatRTF, Stream.Memory, c + 1);
{$ELSE}
            RTFMemHand := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE + GMEM_ZEROINIT, c + 1);
            if RTFMemHand <> 0 then
            begin
              p := GlobalLock(RTFMemHand);
              Stream.Seek(0, 0);
              Stream.Read(p^, c);
              anz := 0;
              Stream.Read(anz, 1);
              GlobalUnlock(RTFMemHand);
            end;
{$ENDIF}
          end;
        end else RTFMemHand := 0;

        // ---------------------------------------------------------------- ANSI
        if not (wpcoDontCopyANSI in ClipboardOptions) and
          (Memo.GetWriterClass('ANSI') <> nil) then
        begin
          Stream.Clear;
          if CompleteText then SaveToStream(Stream, 'ANSI' + extra_frm)
          else SaveSelectionToStream(Stream, 'ANSI' + extra_frm);
          Stream.Write(endc, SizeOf(endc));
          c := Stream.Size;
          if c > SizeOf(endc) then
          begin
{$IFDEF CLR}
            SetBuffer(CF_TEXT, Stream.Memory, c + 1);
{$ELSE}
            ANSIMemHand := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE + GMEM_ZEROINIT, c + 1);
            if ANSIMemHand <> 0 then
            begin
              p := GlobalLock(ANSIMemHand);
              Stream.Seek(0, 0);
              Stream.Read(p^, c);
              anz := 0;
              Stream.Read(anz, 1);
              GlobalUnlock(ANSIMemHand);
            end;
{$ENDIF}
          end;
        end else ANSIMemHand := 0;

        // ---------------------------------------------------------------- UNICODE
        if not (wpcoDontCopyUNICODE in ClipboardOptions) and
          (Memo.GetWriterClass('UNICODE') <> nil) then
        begin
          Stream.Clear;
          if CompleteText then SaveToStream(Stream, 'UNICODE' + extra_frm)
          else SaveSelectionToStream(Stream, 'UNICODE' + extra_frm);
          c := Stream.Size;
          if c > 0 then
          begin
{$IFDEF CLR}
            SetBuffer(CF_UNICODETEXT, Stream.Memory, c + 2);
{$ELSE}
            UNIMemHand := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE + GMEM_ZEROINIT, c + 2);
            if UNIMemHand <> 0 then
            begin
              p := GlobalLock(UNIMemHand);
              Stream.Seek(0, 0);
              Stream.Read(p^, c);
              anz := 0;
              Stream.Read(anz, 2);
              GlobalUnlock(UNIMemHand);
            end;
{$ENDIF}
          end;
        end else UNIMemHand := 0;

        // ------------------------------------------------------------- WPTOOLS
        if not (wpcoDontCopyWPTOOLS in ClipboardOptions) and
          (Memo.GetWriterClass('WPTOOLS') <> nil) then
        begin
          Stream.Clear;
          if CompleteText then SaveToStream(Stream, 'WPTOOLS' + extra_frm)
          else SaveSelectionToStream(Stream, 'WPTOOLS' + extra_frm);
          Stream.Write(endc, SizeOf(endc));
          c := Stream.Size;
          if c > SizeOf(endc) then
          begin
{$IFDEF CLR}
            SetBuffer(FormatWPT, Stream.Memory, c + 1);
{$ELSE}
            WPTMemHand := GlobalAlloc(GMEM_MOVEABLE + GMEM_DDESHARE + GMEM_ZEROINIT, c + 1);
            if WPTMemHand <> 0 then
            begin
              p := GlobalLock(WPTMemHand);
              Stream.Seek(0, 0);
              Stream.Read(p^, c);
              anz := 0;
              Stream.Read(anz, 1);
              GlobalUnlock(WPTMemHand);
            end;
{$ENDIF}
          end;
        end else WPTMemHand := 0;

        // ---------------------------------------------------------------- STORE
{$IFNDEF CLR}
        if WPTMemHand <> 0 then ClipBoard.SetAsHandle(FormatWPT, WPTMemHand);
        if RTFMemHand <> 0 then ClipBoard.SetAsHandle(FormatRTF, RTFMemHand);
        if ANSIMemHand <> 0 then ClipBoard.SetAsHandle(CF_TEXT, ANSIMemHand);
        if UNIMemHand <> 0 then ClipBoard.SetAsHandle(CF_UNICODETEXT, UNIMemHand);
{$ENDIF}
      finally
        ClipBoard.Close;
        Stream.Free;
      end;
      // -------------------------------------------------------------------------
    end;
  finally
    if assigned(FAfterCopyToClipboard) then
      FAfterCopyToClipboard(Self, FInCutToClipboard);
    FMemo._InClipboardOP := FALSE;
  end;
  StartUpdate(WPUPD_UPDSELECTION);
end;

//##############################################################################
// State procedure - for compativility -------------------------------------
//##############################################################################

function TWPCustomRtfEdit.GetFontNr(AName: TFontName): Integer;
begin
  Result := Memo.RTFData.RTFProps.AddFontName(AName);
end;

function TWPCustomRtfEdit.GetFontName(nr: Integer): TFontName;
begin
  Result := Memo.RTFData.RTFProps.GetFontName(nr);
end;

function TWPCustomRtfEdit.GetStyleNrForName(const StyleName: string): Integer;
var sty: TWPRTFStyleElement;
begin
  sty := Memo.RTFData.RTFProps.ParStyles.FindStyle(StyleName);
  if sty <> nil then Result := sty.ID
  else Result := 0;
end;

function TWPCustomRtfEdit.GetStyleNameForNr(const StyleNr: Integer): string;
var sty: TWPRTFStyleElement;
begin
  sty := Memo.RTFData.RTFProps.ParStyles.GetStyle(StyleNr);
  if sty <> nil then Result := sty.Name
  else Result := '';
end;

function TWPCustomRtfEdit.GetColorNr(aColor: TColor): Integer;
begin
  Result := Memo.RTFData.RTFProps.AddColor(aColor);
end;

function TWPCustomRtfEdit.NrToColor(ColorIndex: Integer): TColor;
begin
  Result := Memo.RTFData.RTFProps.ColorTable[ColorIndex];
end;

procedure TWPCustomRtfEdit.SetTextColor(Index: Integer; col: TColor);
begin
  FMemo.RTFData.RTFProps.ColorTable[index] := col;
end;

function TWPCustomRtfEdit.GetTextColor(Index: Integer): TColor;
begin
  Result := FMemo.RTFData.RTFProps.ColorTable[index];
end;

function TWPCustomRtfEdit.GetTextColorCount: Integer;
begin
  Result := FMemo.RTFData.RTFProps.ColorTableCount;
end;

function TWPCustomRtfEdit.AppendAsSection(FromEditor: TWPCustomRtfEdit): TWPRTFSectionProps;
begin
  Result := HeaderFooter.AppendAsSection(FromEditor.HeaderFooter);
end;

//##############################################################################
// Input Procedures
// Other "FAST" Input Procedures are all defined in unit WPCTRRich
//##############################################################################

function TWPCustomRtfEdit.FastAppendText(source: TWPCustomRtfEdit;
  AsNewSection: Boolean = FALSE): TWPRTFSectionProps;
var par, aLastPar: TParagraph;
begin
  SaveChanging;
  Result := nil;
  if (Source <> nil) and
    (source.ActiveText <> nil) and
    CheckHasBody then
  begin
    par := Source.FirstPar;
    aLastPar := nil;
    while par <> nil do
    begin
      aLastPar := ActiveText.AppendParCopy(par, [], aLastPar);
      if AsNewSection then
      begin
        if aLastPar.PrevPar <> nil then
        begin
          Result := HeaderFooter.AddSectionProps;
          include(aLastPar.prop, paprNewSection);
          aLastPar.SectionID := Result.SectionID;
        end
        else Result := HeaderFooter.Header;
        AsNewSection := FALSE;
      end;
    end;
    TextCursor.active_paragraph := ActiveText.LastPar;
    TextCursor.active_posinpar := TextCursor.active_paragraph.CharCount;
    DelayedReformat;
  end;
end;

procedure TWPCustomRtfEdit.FastAppendTextParID(source: TWPCustomRtfEdit; id: Integer; ProtectedFlag: Boolean);
var par, newpar, LastPar: TParagraph;
begin
  SaveChanging;
  if (Source <> nil) and
    (source.ActiveText <> nil) and
    CheckHasBody then
  begin
    par := Source.FirstPar;
    LastPar := nil;
    while par <> nil do
    begin
      newpar := ActiveText.AppendParCopy(par, [], LastPar);
      LastPar := newpar;
      while newpar <> nil do
      begin
        newpar.ASet(WPAT_ParID, id);
        if ProtectedFlag then newpar.ASet(WPAT_ParProtected, 1)
        else newpar.ADel(WPAT_ParProtected);
        newpar := newpar.next;
      end;
    end;
    TextCursor.active_paragraph := ActiveText.LastPar;
    TextCursor.active_posinpar := TextCursor.active_paragraph.CharCount;
    DelayedReformat;
  end;
end;

procedure TWPCustomRtfEdit.FastAppendTextWithParID(source: TWPCustomRtfEdit; id: Integer);
var par, LastPar: TParagraph;
  a: Integer;
begin
  SaveChanging;
  if (Source <> nil) and
    (source.ActiveText <> nil) and
    CheckHasBody then
  begin
    par := Source.FirstPar;
    LastPar := nil;
    while par <> nil do
    begin
      if par.AGet(WPAT_ParID, a) and (a = id) then
        LastPar := ActiveText.AppendParCopy(par, [], LastPar)
      else par := par.NextPar;
    end;
    TextCursor.active_paragraph := ActiveText.LastPar;
    TextCursor.active_posinpar := TextCursor.active_paragraph.CharCount;
    DelayedReformat;
  end;
end;

function TWPCustomRtfEdit.FastAppendActiveLine(source: TWPCustomRtfEdit): Boolean;
var par: TParagraph;
begin
  SaveChanging;
  if (Source <> nil) and
    (source.ActiveText <> nil) and
    CheckHasBody then
  begin
    par := Source.ActiveParagraph;
    if par <> nil then
    begin
      ActiveText.AppendParCopy(par);
      if par <> nil then
        Source.ActiveParagraph := par;
      ReformatAll;
    end;
    TextCursor.active_paragraph := ActiveText.LastPar;
    TextCursor.active_posinpar := TextCursor.active_paragraph.CharCount;
    Result := TRUE;
  end else Result := FALSE;
end;

//##############################################################################
// Input Procedures
//##############################################################################

function TWPCustomRtfEdit.CheckHasBody: Boolean;
begin
{$IFDEF WPSAVEMODE}
  if (FMemo.DisplayedText <> nil) and not
    FMemo.RTFData.Verify(FMemo.DisplayedText) then
    FMemo.DisplayedText := nil;
{$ENDIF}

  if FMemo.DisplayedText = nil then
  begin
    FMemo.DisplayedText := FMemo.Body;
    FNeedInitRTFData := TRUE;
  end;
  if FMemo.Cursor.RTFData = nil then
    FMemo.Cursor.RTFData := FMemo.DisplayedText;
  if (FMemo.Cursor.active_paragraph = nil) and (FMemo.Cursor.RTFData <> nil) then
  begin
    FMemo.Cursor.active_paragraph := FMemo.Cursor.RTFData.FirstPar;
    StartUpdate(WPUPD_REFORMAT);
    StartUpdate(WPUPD_REPAINT);
  end;
  Result := (FMemo.Cursor.active_paragraph <> nil);
  StartUpdate(WPUPD_UNDOCHANGE);
end;

procedure TWPCustomRtfEdit.InputStringInt(const Value: Integer);
begin
  InputString(IntToStr(Value));
end;

function TWPCustomRtfEdit.InputNewObject(objtype: TWPTextObjType;
  HasClosing: Boolean = FALSE;
  IsClosing: Boolean = FALSE;
  CharAttrIndex: Cardinal = 0): TWPTextObj;
begin
  Result := nil;
  if CheckHasBody then
    with TextCursor do
    begin
      Result := active_paragraph.InsertNewObject(
        active_posinpar, objtype, HasClosing, IsClosing, CharAttrIndex);
      if Inserting then inc(active_posinpar);
    end;
end;

procedure TWPCustomRtfEdit.InputString(const Text: AnsiString; CodePage: Integer = 0);
begin
  if CheckHasBody then
  begin
    FMemo.InputString(Text, false);
    DelayedReformat;
  end;
end;

procedure TWPCustomRtfEdit.InputStringW(const Text: WideString);
begin
  if CheckHasBody then
  begin
    FMemo.InsertWideString(Text, false);
  end;
end;

function TWPCustomRtfEdit.InputMergeField(
  const FieldName: string;
  const DisplayText: string = '';
  Command: string = '';
  Format: Integer = 0;
  DisplayChar: Char = #0 //<-- obsolete parameter!
  ): TWPTextObj;
var obj: TWPTextObj;
begin
  Changing; // don't check, could be readonly!
  if CheckHasBody then
  try
    Memo.DisableProtection;
    Memo.RTFData.StartUndolevel;
    obj := InputCode(wpobjMergeField, FieldName, Command, [wpinpWrapSelectedText, wpinpPlaceCursorAfterStart]);
    obj.IParam := Format;
    obj.Params := DisplayText;
    obj.CParam := Integer(DisplayChar);
    Assert(obj.EndTag <> nil, 'Cannot find end tag!');
    if DisplayText <> '' then InputString(DisplayText);
    CPMoveNext;
    Result := obj;
  finally
    Memo.RTFData.EndUndolevel;
    Memo.EnableProtection;
    ChangeApplied;
  end else Result := nil;
end;

procedure TWPCustomRtfEdit.DeleteFields;
begin
  DeleteField('*ALL*');
end;

procedure TWPCustomRtfEdit.DeleteField(const AName: string);
var List: TWPTextObjList;
  i: Integer;
  eobj: TWPTextObj;
  par1, par2: TParagraph;
begin
  Changing; // don't check, could be readonly!
  List := TWPTextObjList.Create;
  try
    if GetCodeTags(List, wpobjMergeField, AName, true) then
      for i := 0 to List.Count - 1 do
      begin
        eobj := List[i].EndTag;
        if eobj <> nil then
        begin
          par1 := eobj.ParentPar;
          eobj.Free;
        end
        else par1 := nil;
        par2 := List[i].ParentPar;
        List[i].Free;
        if par1 = par2 then par1.DeleteMarkedChar
        else
        begin
          if par1 <> nil then par1.DeleteMarkedChar;
          if par2 <> nil then par2.DeleteMarkedChar;
        end;
      end;
    DelayedReformat;
  finally
    List.Free;
    ChangeApplied;
  end;
end;

function TWPCustomRtfEdit.InputEditField(const FieldName: string;
  DisplayText: string = '';
  PlaceCaret: Boolean = FALSE;
  Command: string = '';
  Format: Integer = 0): TWPTextObj;
var obj: TWPTextObj;
begin
  Changing; // don't check, could be readonly!
  try
    Memo.DisableProtection;
    obj := InputCode(wpobjMergeField, FieldName, Command, [wpinpPlaceCursorAfterStart]);
    obj.IParam := Format;
    obj.Params := DisplayText;
    obj.CParam := Integer(WPEditFieldStart);
    obj.Mode := obj.Mode + [wpobjWithinEditable];
    Result := obj; //moved here, V5.19.5
    obj := obj.EndTag;
    Assert(obj <> nil, 'Cannot find end tag!');
    if obj <> nil then obj.Mode := obj.Mode + [wpobjWithinEditable];
    if DisplayText <> '' then InputString(DisplayText);
    if not PlaceCaret then CPMoveNext;
  finally
    Memo.EnableProtection;
    ChangeApplied;
  end;
end;


function TWPCustomRtfEdit.FieldReadText(const fieldname: string): string;
var FieldPar: TParagraph;
  obj: TWPTextObj;
  FieldPosInPar: Integer;
begin
  Result := '';
  if CodeLocate(FieldPar, FieldPosInPar, fieldname, wpobjMergeField,
    [wpobjIsOpening], [wpGlobalSearch, wpCompareName]) then
  begin
    obj := FieldPar.ObjectRef[FieldPosInPar];
    if obj <> nil then Result := obj.EmbeddedText;
  end
end;

procedure LoopFields(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
begin
  if (obj.ObjType = wpobjMergeField) and
    (wpobjIsOpening in obj.Mode) and
    (obj.Name <> '') then
    TStrings(param).Add(obj.Name);
end;

procedure TWPCustomRtfEdit.FieldGetNames(list: TStrings; FromAllBlock: Boolean = FALSE);
begin
  List.Clear;
  if FromAllBlock then Memo.RTFData.LoopAllObj(List, LoopFields, nil)
  else Memo.RTFData.LoopAllObj(List, LoopFields, Memo.DisplayedText);
end;

procedure LoopFieldsB(RTFData: TWPRTFDataCollection;
  RTFDataBlock: TWPRTFDataBlock;
  par: TParagraph;
  obj: TWPTextObj;
  param: TObject);
begin
  if (obj.ObjType = wpobjMergeField) and
    (wpobjIsOpening in obj.Mode) and
    ((TWPTextObjList(param)._StringParam = '') or
    (Copy(obj.Name, 1, Length(TWPTextObjList(param)._StringParam)) =
    TWPTextObjList(param)._StringParam)) then
    TWPTextObjList(param).Add(obj);
end;

procedure TWPCustomRtfEdit.FieldGetList(
  list: TWPTextObjList; FromAllBlock: Boolean = FALSE;
  NameStartWith: string = '');
begin
  List.Clear;
  List._StringParam := NameStartWith;
  if FromAllBlock then Memo.RTFData.LoopAllObj(List, LoopFieldsB, nil)
  else Memo.RTFData.LoopAllObj(List, LoopFieldsB, Memo.DisplayedText);
end;

function TWPCustomRtfEdit.FieldRename(OldName, NewName: string; FromAllBlocks: Boolean = TRUE;
  CaseSensitive: Boolean = TRUE): Integer;
begin
  Result := CodeRename(wpobjMergeField,
    OldName, NewName, FromAllBlocks, CaseSensitive);
end;

function TWPCustomRtfEdit.FieldGetInPar(par: TParagraph; posinpar: Integer): TWPTextObj;
begin
  if (par = nil) or (posinpar < 0) then
    Result := nil
  else
  begin
    Result := par.ObjectRef[posinpar];
    if (Result <> nil) and (Result.ObjType = wpobjMergeField) then exit;
    Result := CodeInsideOf(par, posinpar, wpobjMergeField);
  end;
end;

function TWPCustomRtfEdit.FieldGetNameInPar(par: TParagraph; posinpar: Integer): string;
var obj: TWPTextObj;
begin
  obj := FieldGetInPar(par, posinpar);
  if obj <> nil then Result := obj.Name
  else Result := '';
end;

function TWPCustomRtfEdit.CurrentEditField: string;
var f: TWPTextObj;
begin
  f := FieldAtCP;
  if f <> nil then
    Result := f.Name
  else Result := '';
end;

function TWPCustomRtfEdit.FieldAtCP: TWPTextObj;
begin
  if Memo.HasData then with Memo.Cursor do
    begin
      Result := ObjAtCP;
      if (Result <> nil) and (Result.ObjType = wpobjMergeField) then
      begin
        if wpobjIsClosing in Result.Mode then
          Result := Result.StartTag;
        exit;
      end;
      Result := ObjBeforeCP;
      if (Result <> nil) and (Result.ObjType = wpobjMergeField)
        and (wpobjIsClosing in Result.Mode) then exit;
      Result := CodeInsideOf(active_paragraph, active_posinpar, wpobjMergeField)
    end
  else Result := nil;
end;

function TWPCustomRtfEdit.FieldExists(const fieldname: string): Boolean;
var par: TParagraph;
  i: Integer;
begin
  Result := CodeLocate(par, i, fieldname, wpobjMergeField, [wpobjIsOpening], [wpGlobalSearch, wpCompareName]);
end;

function TWPCustomRtfEdit.MoveToField(const fieldname: string; from_start: Boolean = TRUE): Boolean;
var par: TParagraph;
  i: Integer;
  LocateOptions: TWPCodeLocateOptions;
  d: Integer;
begin
  try
    TextCursor.DisableForms;
    d := TextCursor.DropMarker;
    LocateOptions := [wpCompareName];
    if not from_start then include(LocateOptions, wpStartAtCursorPosition);
    if CodeLocate(par, i, fieldname, wpobjMergeField, [wpobjIsOpening], LocateOptions) then
    begin
      if ppAllExceptForEditFields in ProtectedProp then inc(i);
      Result := TextCursor.MoveTo(par, i);
      TextCursor.CollectMarker(d);
      if wpRepaintOnFieldMove in EditOptionsEx then
      begin
        FMemo._DBufferIsValid := FALSE;
        Invalidate;
      end;
      TextCursor.GetCharAttr;
      if FLocked = 0 then ShowCursor;
    end
    else
    begin
      Result := FALSE;
      TextCursor.GotoMarker(d);
    end;
  finally
    TextCursor.EnableForms;
  end;
end;

function TWPCustomRtfEdit.MoveToNextField(from_start: Boolean = FALSE): string;
var obj: TWPTextObj;
  d: Integer;
  Abort: Boolean;
begin
  d := TextCursor.DropMarker;
  try
    TextCursor.DisableForms;
    // check if we may leave current field -------------------------------------
    obj := FieldAtCP;
    if obj <> nil then
    begin
      Abort := false;
      if Assigned(FMemo.OnEditFieldFocus) then
        FMemo.OnEditFieldFocus(Self, obj.Name, false, obj, Abort);
      if Abort then exit; // goto "finally"
    end;
    // -------------------------------------------------------------------------
    if from_start then
      CPPosition := 0
    else CPMoveNext;
    Result := '';
    with TextCursor do
    begin
      repeat obj := ObjAtCP;
      until ((obj <> nil) and (obj.ObjType = wpobjMergeField) and
        (wpObjIsOpening in obj.Mode)) or not CPMoveNext;
    end;

    if (obj <> nil) and
      (obj.ObjType = wpobjMergeField) and
      (wpObjIsOpening in obj.Mode) then
    begin
      Abort := FALSE;
      if assigned(FMemo.OnEditFieldFocus) then
        FMemo.OnEditFieldFocus(Self, obj.Name, true, obj, Abort);
    end else Abort := TRUE;

    if not Abort then
    begin
      Result := obj.Name;
      TextCursor.CollectMarker(d);
      if ppAllExceptForEditFields in ProtectedProp then
        CPMoveNext;
      if wpRepaintOnFieldMove in EditOptionsEx then
      begin
        FMemo._DBufferIsValid := FALSE;
        Invalidate;
      end;
      TextCursor.GetCharAttr;
      if FLocked = 0 then ShowCursor;
    end
    else TextCursor.GotoMarker(true, d);
  finally
    TextCursor.EnableForms;
  end;
end;

function TWPCustomRtfEdit.MoveToPreviousField(from_end: Boolean = false): string;
var obj, currobj: TWPTextObj;
  d: Integer;
  Abort: Boolean;
begin
  d := TextCursor.DropMarker;
  try
    TextCursor.DisableForms;
    if from_end then
    begin
      CPPosition := MaxInt;
      currobj := nil;
    end
    else
    begin
      currobj := CodeInsideOf(wpobjMergeField);
    end;
    Result := '';
    with TextCursor do
      repeat obj := ObjAtCP;
      until ((obj <> nil) and (obj.ObjType = wpobjMergeField) and (obj <> currobj)
        and (wpObjIsOpening in obj.Mode)) or not CPMoveBack;

    if (obj <> nil) and
      (obj.ObjType = wpobjMergeField) and
      (wpObjIsOpening in obj.Mode) then
    begin
      Abort := FALSE;
      if assigned(FMemo.OnEditFieldFocus) then
        FMemo.OnEditFieldFocus(Self, obj.Name, true, obj, Abort);
    end else Abort := TRUE;

    if not Abort then
    begin
      Result := obj.Name;
      TextCursor.CollectMarker(d);
      if ppAllExceptForEditFields in ProtectedProp then
        CPMoveNext;
      if wpRepaintOnFieldMove in EditOptionsEx then
      begin
        FMemo._DBufferIsValid := FALSE;
        Invalidate;
      end;
      TextCursor.GetCharAttr;
      if FLocked = 0 then ShowCursor;
    end
    else TextCursor.GotoMarker(true, d);
  finally
    TextCursor.EnableForms;
  end;
end;


function TWPCustomRtfEdit.DeleteFieldAtCP: Boolean;
var startp, endp: TWPTextObj;
begin
  startp := FieldAtCP;
  Result := FALSE;
  if startp <> nil then
  begin
    endp := startp.EndTag;
    if endp <> nil then
      with Memo.Cursor do
      begin
        SelectFromHere(startp.ParentPar, startp.ParentPar.PositionOfObject(startp));
        SelectToHere(endp.ParentPar, endp.ParentPar.PositionOfObject(endp) + 1);
        ClearTextInbetween(startp.ParentPar, startp.ParentPar.PositionOfObject(startp),
          endp.ParentPar, endp.ParentPar.PositionOfObject(endp) + 1);
        DelayedReformat;
        HideSelection;
        Result := TRUE;
      end;
  end;
end;


function TWPCustomRtfEdit.SelectFieldAtCP(
  IncludingTags: Boolean = TRUE;
  PlaceCursorBetweenTags: Boolean = FALSE): Boolean;
var startp, endp: TWPTextObj;
begin
  startp := FieldAtCP;
  Result := FALSE;
  if startp <> nil then
  begin
    if wpobjIsClosing in startp.Mode then
    begin
      endp := startp;
      startp := endp.EndTag;
      if startp = nil then exit;
    end else
      endp := startp.EndTag;
    if endp <> nil then
      with Memo.Cursor do
      begin
        if PlaceCursorBetweenTags then
        begin
          MoveTo(startp.ParentPar, startp.ParentPar.PositionOfObject(startp) + 1);
        end;
        if not IncludingTags then
        begin
          SelectFromHere(startp.ParentPar, startp.ParentPar.PositionOfObject(startp) + 1);
          SelectToHere(endp.ParentPar, endp.ParentPar.PositionOfObject(endp));
        end else
        begin
          SelectFromHere(startp.ParentPar, startp.ParentPar.PositionOfObject(startp));
          SelectToHere(endp.ParentPar, endp.ParentPar.PositionOfObject(endp) + 1);
        end;
        SelectText := FALSE;
        if PlaceCursorBetweenTags then ShowCursor;
        invalidate;
        Result := TRUE;
      end;
  end;
end;

function TWPCustomRtfEdit.ReplaceTokensInAllTexts(const opening, closing: string): Integer;
var i: Integer;
  block, r: TWPRTFDataBlock;
begin
  block := ActiveText;
  Result := 0;
  try
    for i := 0 to HeaderFooter.Count - 1 do
    begin
      r := HeaderFooter[i];
      if not (r.Kind in [wpIsLoadedBody, wpIsDeleted]) and not r.Readonly then
      begin
        ActiveText := r;
        CPPosition := 0;
        Result := Result + ReplaceTokens(opening, closing);
      end;
    end;
  finally
    ActiveText := block;
    CPPosition := 0;
  end;
end;

function TWPCustomRtfEdit.ReplaceTokens(const opening, closing: string): Integer;
var
  s, r: string;
  StartID, SelStartID, SelEndID, rl: Integer;
  RestoreSel: Boolean;
  startf, endf: TWPTextObj;
begin
  StartID := 0;
  RestoreSel := FALSE;
  SelEndID := 0;
  SelStartID := 0;
  Result := 0;
  with TextCursor do
  try
    s := opening + '*' + closing;
    StartID := DropMarker;
    SelStartID := DropMarkerAtSelStart;
    SelEndID := DropMarkerAtSelEnd;
    RestoreSel := HideSelection;
    with Finder do
    begin
      ToStart;
      while Next(s) do
      begin
        r := FoundText;
        rl := FoundLength;
        CPPosition := FoundPosition + rl - Length(closing);
        DeleteChar(Length(closing));

        r := Copy(r, Length(opening) + 1,
          Length(r) - Length(opening) - Length(closing));

        endf := InputSingleCode(wpobjMergeField, r);
        endf.Mode := [wpobjUsedPairwise, wpobjIsClosing];

        CPPosition := FoundPosition;
        DeleteChar(Length(opening));

        startf := InputSingleCode(wpobjMergeField, r);
        startf.Mode := [wpobjUsedPairwise, wpobjIsOpening];
        endf.SetTag(startf.NewTag);

        MoveNext(Length(r));
        inc(Result);
      end;
    end;
  finally
    HideSelection;
    if RestoreSel then
    begin
      TextCursor.SelectMarker(SelEndID, SelStartID);
    end;
    TextCursor.GotoMarker(StartID);
    Refresh;
  end;
end;

procedure TWPCustomRtfEdit.MailMergeCallBack(Sender: TObject;
  const inspname: string;
  Contents: TWPMMInsertTextContents);
begin
  if assigned(_IntegernOnMailMergeGetText) then
    _IntegernOnMailMergeGetText(Self, inspname, Contents);
  if assigned(FOnMailMergeGetText) then
    FOnMailMergeGetText(Self, inspname, Contents);
end;

procedure TWPCustomRtfEdit.MergeText(const FieldName: string = ''; AllTexts: Boolean = FALSE);
var i: Integer;
  modified: Boolean;
  FCollection: TWPRTFDataCollection;
begin
  SaveChanging;
  modified := FALSE;
  FCollection := FMemo.RTFData;
  FCollection.RTFEngineParams.AbortMerge := FALSE;
  FCollection.FWorkRTFEngine := FMemo;
{$IFDEF ALLOWUNDO}
  FCollection.UndoDisable;
{$ENDIF}
  Memo.DisableProtection;
  try
    if AllTexts then
    begin
     // First merge the body text
      for i := 0 to FCollection.Count - 1 do
        if FCollection.Items[i].Kind = wpIsBody then
        begin
          if FCollection.Items[i].MergeText(Self, MailMergeCallBack, FDoMergeEnumFields, FieldName)
            then modified := TRUE;
          if FCollection.RTFEngineParams.AbortMerge then exit;
        end;
     // Then merge header and footer
      for i := 0 to FCollection.Count - 1 do
        if (FCollection.Items[i].Kind <> wpIsBody) and
          (FCollection.Items[i].Kind <> wpIsDeleted) and
          (FCollection.Items[i].Kind <> wpIsLoadedBody) and
          not FCollection.Items[i].Empty then
        begin
          if FCollection.Items[i].MergeText(Self, MailMergeCallBack, FDoMergeEnumFields, FieldName)
            then modified := TRUE;
          if FCollection.RTFEngineParams.AbortMerge then exit;
        end;
    end else
    begin
      if FMemo.DisplayedText = nil then
        modified := FMemo.Body.MergeText(Self, MailMergeCallBack, FDoMergeEnumFields, FieldName)
      else modified := FMemo.DisplayedText.MergeText(Self, MailMergeCallBack, FDoMergeEnumFields, FieldName);
    end;
  finally
    if not FDoMergeEnumFields and modified then
    begin
      DelayedReformat;
    end;
{$IFDEF ALLOWUNDO}
    FCollection.UndoEnable;
{$ENDIF}
    Memo.EnableProtection;
    HideSelection;
  end;
end;

procedure TWPCustomRtfEdit.MergeActiveText(const FieldName: string = '');
begin
  if FMemo.Cursor.RTFData <> nil then
  begin
    SaveChanging;
    try
{$IFDEF ALLOWUNDO}
      HeaderFooter.UndoDisable;
{$ENDIF}
      Memo.DisableProtection;
      if FMemo.Cursor.RTFData.MergeText(Self, MailMergeCallBack, false, FieldName) then
        DelayedReformat;
    finally
{$IFDEF ALLOWUNDO}
      HeaderFooter.UndoEnable;
{$ENDIF}
      Memo.EnableProtection;
      HideSelection;
    end;
  end;
end;

procedure TWPCustomRtfEdit.MergeEnumFields(const FieldName: string = ''; AllTexts: Boolean = FALSE);
begin
  FDoMergeEnumFields := TRUE;
  try
    MergeText(FieldName, AllTexts);
  finally
    FDoMergeEnumFields := FALSE;
    HideSelection;
  end;
end;

procedure TWPCustomRtfEdit.BeginUpdate;
var i: Integer;
begin
  if FLocked = 0 then
  begin
    Memo.DisableProtection;
    for i := Low(FBeginEndUpdateFlags) to High(FBeginEndUpdateFlags) do
      FBeginEndUpdateFlags[i] := FALSE;
  end;
  inc(FLocked);
  Memo._ScreenIsLocked := TRUE;
  Memo.RTFData.BeginUpdate;
end;

procedure TWPCustomRtfEdit.EndUpdate;
begin
  Memo.RTFData.EndUpdate;
  dec(FLocked);
  if FLocked <= 0 then
  begin
    if FLocked = 0 then
      Memo.EnableProtection;
    Memo._ScreenIsLocked := FALSE;
    DelayedReformat;
  end;
end;

procedure TWPCustomRtfEdit.ProcessDelayedUpdates;
var i: Integer;
begin
  if FBeginEndUpdateFlags[WPUPD_REFORMAT] then
    DoUpdate(WPUPD_REFORMAT, 0);
  if FBeginEndUpdateFlags[WPUPD_REORDERPAGES] then
    DoUpdate(WPUPD_REORDERPAGES, 0);
  if FBeginEndUpdateFlags[WPUPD_SHOWCURSOR] then
    DoUpdate(WPUPD_SHOWCURSOR, 0);
  if FBeginEndUpdateFlags[WPUPD_REPAINT] then
    DoUpdate(WPUPD_REPAINT, 0);
  if FBeginEndUpdateFlags[WPUPD_UPDATTRIBUTES] then
    DoUpdate(WPUPD_UPDATTRIBUTES, 0);
  if FBeginEndUpdateFlags[WPUPD_UPDSELECTION] then
    DoUpdate(WPUPD_UPDSELECTION, 0);
  if FBeginEndUpdateFlags[WPUPD_NEEDFOCUS] then
    DoUpdate(WPUPD_NEEDFOCUS, 0);
  for i := Low(FBeginEndUpdateFlags) to High(FBeginEndUpdateFlags) do
    FBeginEndUpdateFlags[i] := FALSE;
end;

//##############################################################################
// Loading and Saving ----------------------------------------------------------
//##############################################################################

procedure TWPCustomRtfEdit.Clear;
begin
  ClearEx(false, false, false);
end;

procedure TWPCustomRtfEdit.ClearEx(DontClearStyles, DontResetPageSize, ResetWritingAttr: Boolean);
var s: string;
begin
  DoUpdateState(wpBeforeClear);
  if ResetWritingAttr then
    Memo.RTFData.DefaultAttr.Clear;
  if DontClearStyles and (Memo.RTFData.RTFProps.AttachedRTFDataCount <= 1) then
  begin
     // We don't use  Clear(false ..) since that would not clear the character attr cache!
     // so: make a backup copy and reaply
    s := ParStyles.GetWPCSS;
    Memo.RTFData.Clear(true, not DontResetPageSize, nil);
    ParStyles.SetWPCSS(s, false);
  end
  else Memo.RTFData.Clear(not DontClearStyles, not DontResetPageSize, nil);
  if ResetWritingAttr then
    Memo.RTFData.DefaultAttr.Assign(Memo.RTFData.ANSITextAttr);
  Memo.TopOffset := 0;
  Memo._DBufferIsValid := FALSE;
  DoUpdateState(wpAfterClear);
  invalidate;
  SetFocusValues(WPLastActiveRTFEdit = self);
end;

procedure TWPCustomRtfEdit.ClearBody;
begin
  Memo.Body.Clear(false);
  Memo.Body.FirstPar.ClearProps;
  Memo.TopOffset := 0;
  Memo._DBufferIsValid := FALSE;
  invalidate;
end;

procedure TWPCustomRtfEdit.Loaded;
begin
  if not FAllowMultiView then
  begin
    CheckHasBody;
  end;
  inherited Loaded;
  if not FRTFText.Empty then
  begin
    FNeedInitRTFData := TRUE;
    FRTFText.ApplyDontLoadVars; // was: Apply;   V5.11.2
  end;
  // Allow the direct change at runtime!
  if not (csDesigning in ComponentState) then
    FIDEValueLoaded := TRUE;
end;

procedure TWPCustomRtfEdit.AssignToHeader(Source: TObject; Range: TWPPagePropertyRange = wpraOnAllPages);
begin
  if Source = nil then
    HeaderFooter.DeleteText(wpIsHeader, Range)
  else if Source is TWPCustomRtfEdit then
    HeaderFooter.Get(wpIsHeader, Range).Assign(TWPCustomRtfEdit(Source).ActiveText)
  else HeaderFooter.Get(wpIsHeader, Range).Assign(Source as TPersistent);
  StartUpdate(WPUPD_REFORMAT);
end;

procedure TWPCustomRtfEdit.AssignToFooter(Source: TObject; Range: TWPPagePropertyRange = wpraOnAllPages);
begin
  if Source = nil then
    HeaderFooter.DeleteText(wpIsFooter, Range)
  else if Source is TWPCustomRtfEdit then
    HeaderFooter.Get(wpIsFooter, Range).Assign(TWPCustomRtfEdit(Source).ActiveText)
  else HeaderFooter.Get(wpIsFooter, Range).Assign(Source as TPersistent);
  StartUpdate(WPUPD_REFORMAT);
end;

procedure TWPCustomRtfEdit.ClearHeaderFooter;
var i: Integer;
begin
  with Memo.RTFData do
    for i := Count - 1 downto 0 do
      if Items[i].Kind in [wpIsHeader, WPIsFooter] then
        Delete(i);
  StartUpdate(WPUPD_REFORMAT);
end;

function TWPCustomRtfEdit.RecalcText(pars, fields: Boolean): Boolean;
begin
  Result := Memo.RTFData.RecalcText(pars, fields);
  DelayedReformat;
end;

procedure TWPCustomRtfEdit.AssignPrintProperties(Source: TWPCustomRtfEdit);
begin
  if Source <> nil then
  begin
     // If the RTFData is shared don't bother
    if HeaderFooter <> Source.HeaderFooter then
    begin
      InsertPointAttr.CopyPrintProps(Source.InsertPointAttr);
      HyperlinkTextAttr.CopyPrintProps(Source.HyperlinkTextAttr);
      BookmarkTextAttr.CopyPrintProps(Source.BookmarkTextAttr);
      SPANObjectTextAttr.CopyPrintProps(Source.SPANObjectTextAttr);
      AutomaticTextAttr.CopyPrintProps(Source.AutomaticTextAttr);
      ProtectedTextAttr.CopyPrintProps(Source.ProtectedTextAttr);
      FieldObjectTextAttr.CopyPrintProps(Source.FieldObjectTextAttr);
      FormatOptions := Source.FormatOptions;
      FormatOptionsEx := Source.FormatOptionsEx;
    end;
    ViewOptions := Source.ViewOptions;
     // The events must be copied
    OnCustomLinePaintBefore := Source.OnCustomLinePaintBefore;
    OnCustomLinePaintAfter := Source.OnCustomLinePaintAfter;
    OnGetAttributeColor := Source.OnGetAttributeColor;
    OnTextObjGetTextEx := Source.OnTextObjGetTextEx;
    OnPaintWatermark := Source.OnPaintWatermark;
    //no: OnPaintExternPage := Source.OnPaintExternPage;
  end;
end;

procedure TWPCustomRtfEdit.ReformatAll(InitializeAll: Boolean = FALSE;
  RepaintMemo: Boolean = FALSE);
begin
  if FLocked > 0 then exit;
  if CheckHasBody then
  begin
    FMemo.RTFData.NeedReformat(false);
    FMemo.ReformatAll(InitializeAll);
    if RepaintMemo then FMemo.RePaint;
  end;
  if (FMemo.DisplayedText <> nil) and // V5.13 - security
    not HeaderFooter.Verify(FMemo.DisplayedText) then
    FMemo.DisplayedText := BodyText;

  StartUpdate(WPUPD_SETSCROLLBARS, 0);
end;

function TWPCustomRtfEdit.SaveToStream(s: TStream; FormatName: string = ''): Boolean;
begin
  Result := Memo.SaveToStream(s, FormatName);
end;

function TWPCustomRtfEdit.LoadFromStream(s: TStream; FormatName: string = ''; WithClear: Boolean = FALSE): Boolean;
var IsBody: Boolean;
begin
  if Pos(':', FormatName) > 0 then
    FormatName := ExtractFileExt(FormatName);

  IsBody := (Memo.DisplayedText <> nil) and (Memo.DisplayedText.Kind = wpIsBody)
    and (Memo.CursorOnText = Memo.DisplayedText);
  if WithClear then Clear;
  Result := Memo.LoadFromStream(s, not IsEmpty, FormatName);
  if IsBody then
  begin
    Memo.DisplayedText := Memo.Body;
    Memo.CursorOnText := Memo.Body;
  end;
  if assigned(FOnChangeCursorPos) then
    FOnChangeCursorPos(Self);
  SetFocusValues(WPLastActiveRTFEdit = self);
end;

{$IFNDEF CLR}

function TWPCustomRtfEdit.LoadFromBuffer(buffer: PChar; bufferlen: Integer; FormatName: string = ''; WithClear: Boolean = FALSE): Boolean;
var mem: TMemoryStream;
begin
  mem := TMemoryStream.Create;
  try
    mem.Write(buffer^, bufferlen);
    mem.Position := 0;
    Result := LoadFromStream(mem, FormatName, WithClear);
  finally
    mem.Free;
  end;
end;
{$ENDIF}

function TWPCustomRtfEdit.SaveSelectionToStream(s: TStream; FormatName: string = ''): Boolean;
begin
  Result := Memo.SaveSelectionToStream(s, FormatName);
end;

function TWPCustomRtfEdit.LoadSelectionFromStream(s: TStream; FormatName: string = ''): Boolean;
var par: TParagraph; pos: Integer;
begin
  if CheckHasBody then
  begin
    par := TextCursor.GetBlockStart(pos);
    if par <> nil then
    begin
      TextCursor.active_paragraph := par;
      TextCursor.active_posinpar := pos;
    end;
    TextCursor.GetCharAttr;
    ClearSelection(false);
    Result := Memo.LoadFromStream(s, true, FormatName, false);
    if assigned(FOnChangeCursorPos) then
      FOnChangeCursorPos(Self);
  end else Result := FALSE;
end;

function TWPCustomRtfEdit.SaveToFile(const FileName: string;
  SelectionOnly: Boolean = FALSE; FormatName: string = ''): Boolean;
var f: TFileStream; op: string; Abort: Boolean;
begin
  Abort := FALSE;
  // Check for file overwrite --------------------------------------------------
  if assigned(FBeforeOverwriteFile) and FileExists(FileName) then
  begin
    if SelectionOnly then
      FBeforeOverwriteFile(Self, FileName, FormatName, wpInSaveSelectionToFile, Abort)
    else FBeforeOverwriteFile(Self, FileName, FormatName, wpInSaveTextToFile, Abort);
  end;
  // ------------------------------------------------------------ continue -----
  if Abort then Result := FALSE
  else
  begin
    f := TFileStream.Create(FileName, fmCreate);
    op := Memo.RTFData._SaveFilenameAndPath;
    try
      Memo.RTFData._SaveFilenameAndPath := FileName; // not just path!
      if FormatName = '' then FormatName := TextSaveFormat;

      if (FormatName = '') or (CompareText(FormatName, 'AUTO') = 0) then
        FormatName := ExtractFileExt(FileName);

      if SelectionOnly then Result := SaveSelectionToStream(f, FormatName)
      else
      begin
        Result := SaveToStream(f, FormatName);
        if Result then LastFileName := FileName;
      end;
    finally
      Memo.RTFData._SaveFilenameAndPath := op;
      f.Free;
    end;
  end;
end;

function TWPCustomRtfEdit.GetAsString: string;
var f: TStringStream;
begin
  f := TStringStream.Create('');
  try
    SaveToStream(f, FMemo.TextSaveFormat);
    Result := f.DataString;
  finally
    f.Free;
  end;
end;


procedure TWPCustomRtfEdit.SetAsString(const x: string);
var f: TStringStream;
begin
  BeginUpdate;
  try
    f := TStringStream.Create(x);
    try
      LoadFromStream(f, TextLoadFormat, true);
    finally
      f.Free;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TWPCustomRtfEdit.Assign(Source: TPersistent);
var mem: TMemoryStream;
  a: TWPSpecialCharacterAttrKind;
  FName: string;
  FRange: TWPPagePropertyRange;
  FKind: TWPPagePropertyKind;
  t: TWPRTFDataBlock;
begin
  if Source is TWPCustomRtfEdit then
  begin
    BeginUpdate;
    mem := TMemoryStream.Create;
    try
      if FMemo.DisplayedText <> nil then
      begin
        FName := FMemo.DisplayedText.Name;
        FRange := FMemo.DisplayedText.Range;
        FKind := FMemo.DisplayedText.Kind;
      end else
        if TWPCustomRtfEdit(Source).Memo.DisplayedText <> nil then
        begin
          FName := TWPCustomRtfEdit(Source).Memo.DisplayedText.Name;
          FRange := TWPCustomRtfEdit(Source).Memo.DisplayedText.Range;
          FKind := TWPCustomRtfEdit(Source).Memo.DisplayedText.Kind;
        end else
        begin
          FName := '';
          FRange := wpraOnAllPages;
          FKind := wpIsBody;
        end;
      for a := wpHiddenText to wpFieldTextObjects do
        FMemo.RTFData.SpecialTextAttr[a].Assign(
          TWPCustomRtfEdit(Source).Memo.RTFData.SpecialTextAttr[a]);
      ViewOptions := TWPCustomRtfEdit(Source).ViewOptions;
      FormatOptions := TWPCustomRtfEdit(Source).FormatOptions;
      FormatOptionsEx := TWPCustomRtfEdit(Source).FormatOptionsEx;
      TWPCustomRtfEdit(Source).SaveToStream(mem, 'WPTOOLS-wptembbin');
      mem.Position := 0;
      LoadFromStream(mem, 'WPTOOLS', true);
      t := HeaderFooter.Find(FKind, FRange, FName);
      if t <> nil then
      begin
        FMemo.DisplayedText := t;
        ActiveText := t;
      end;
    finally
      mem.Free;
      EndUpdate;
    end;
  end else inherited Assign(Source);
end;

function TWPCustomRtfEdit.ParStyles: TWPRTFStyleCollection;
begin
  if (FMemo <> nil) and (FMemo.HasData) then
    Result := FMemo.RTFData.RTFProps.ParStyles
  else Result := nil;
end;

function TWPCustomRtfEdit.ParStylePaint(StyleName: string;
  toCanvas: TCanvas; R: TRect): Integer;
var sty: TWPTextStyle;
begin
  sty := ParStyles.FindTextStyle(StyleName);
  if sty = nil then
  begin
    Result := toCanvas.TextHeight(StyleName);
    if R.Right > R.Left then
      toCanvas.TextOut(R.Left + 1, R.Top + 1, StyleName);
  end else
  begin
    Result := Memo.PaintSinglePar(
      sty,
      toCanvas,
      R,
      Screen.PixelsPerInch,
      Screen.PixelsPerInch,
      StyleName
      );
  end;
end;

function TWPCustomRtfEdit.ParStyleNormalizePar(const StyleName: string): Integer;
var par: TParagraph;
  stynr: Integer;
begin
  Result := 0;
  stynr := ParStyles.GetID(StyleName);
  if stynr <> 0 then
  begin
    par := Memo.RTFData.FirstPar;
    while par <> nil do
    begin
      if par.Style = stynr then
      begin
        inc(Result);
        par.ClearCharAttributes(true);
      end;
      par := par.globalnext;
    end;
  end;
  if Result > 0 then DelayedReformat;
end;

function TWPCustomRtfEdit.ParStyleMarkForReformat(const StyleName: string): Integer;
var par: TParagraph;
  stynr: Integer;
begin
  Result := 0;
  stynr := ParStyles.GetID(StyleName);
  if stynr <> 0 then
  begin
    par := Memo.RTFData.FirstPar;
    while par <> nil do
    begin
      if par.Style = stynr then
      begin
        inc(Result);
        include(par.prop, paprMustInit);
      end;
      par := par.globalnext;
    end;
  end;
end;


function TWPCustomRtfEdit.ParStyleLocateFirst(const StyleName: string; StartPar: TParagraph = nil): Boolean;
var par: TParagraph;
  stynr: Integer;
begin
  Result := FALSE;
  stynr := ParStyles.GetID(StyleName);
  if stynr <> 0 then
  begin
    if StartPar <> nil then par := StartPar
    else par := FirstPar;
    while par <> nil do
    begin
      if (par <> nil) and (par.Style = stynr) then break;
      par := par.next;
    end;
    if par <> nil then
    begin
      Result := TRUE;
      HideSelection;
      if TextCursor.MoveTo(par, 0) then
      begin
        TextCursor.SelectParagraph;
        ShowCursor;
      end;
    end;
  end;
end;

function TWPCustomRtfEdit.ParStyleCPMoveTo(const StyleName: string): Boolean;
begin
  Result := ParStyleLocateFirst(StyleName, ActiveParagraph.Next);
  if not Result then Result := ParStyleLocateFirst(StyleName, nil);
end;

(*
function TWPCustomRtfEdit.ParStyleCPMoveTo(const StyleName: string): Boolean;
var par: TParagraph;
  stynr: Integer;
begin
  Result := FALSE;
  stynr := ParStyles.GetID(StyleName);
  if stynr <> 0 then
  begin
    par := ActiveParagraph;
    while par <> nil do
    begin
      par := par.next;
      if (par <> nil) and (par.Style = stynr) then break;
    end;
    if par = nil then
    begin
      par := FirstPar;
      while par <> nil do
      begin
        par := par.next;
        if (par <> nil) and (par.Style = stynr) then break;
      end;
    end;
    if par <> nil then
    begin
      Result := TRUE;
      HideSelection;
      if TextCursor.MoveTo(par, 0) then
      begin
        TextCursor.SelectParagraph;
        // ShowCursor does not work if the focus is not set!
        Memo.ShowCursor;
        FCaret.UpdatePos;
        if assigned(FOnChangeCursorPos) then
            FOnChangeCursorPos(Self);
        if FLastCurrPar<>TextCursor.active_paragraph then
        begin
             FLastCurrPar := TextCursor.active_paragraph;
             DoUpdateParAttr;
        end;
      end;
    end;
  end;
end;   *)

function TWPCustomRtfEdit.NumberStyles: TWPRTFNumberStyleCollection;
begin
  if (FMemo <> nil) and (FMemo.HasData) then
    Result := FMemo.RTFData.RTFProps.NumberStyles
  else Result := nil;
end;

function TWPCustomRtfEdit.GetSelectionAsString: string;
var f: TStringStream;
begin
  f := TStringStream.Create('');
  try
    SaveSelectionToStream(f, 'RTF');
    Result := f.DataString;
  finally
    f.Free;
  end;
end;

function TWPCustomRtfEdit.GetText: string;
begin
  Result := AsANSIString('ANSI-codepage' + IntToStr(Memo._CodePage), false);
end;

procedure TWPCustomRtfEdit.SetText(const x: string);
var f: TStringStream;
begin
  f := TStringStream.Create(x);
  try
    Memo.LoadFromStream(f, false, 'ANSI-codepage' + IntToStr(Memo._CodePage));
  finally
    f.Free;
  end;
end;

procedure TWPCustomRtfEdit.SetSelText(const x: string);
var f: TStringStream; p: Integer;
begin
  f := TStringStream.Create(x);
  try
    FMemo.Cursor._SectionIsProtected := FALSE;
    if FMemo.Cursor.IsSelected then
    begin
      p := SelStart;
      CPPosition := p;
      ClearSelection;
    end else p := CPPosition;
    // Memo.LoadFromStream(f, true, 'ANSI');
    if not FMemo.Cursor._SectionIsProtected then //V5.17.4
    begin
      Memo.LoadFromStream(f, true, 'ANSI-codepage' + IntToStr(Memo._CodePage));
      SetSelPosLen(p, CPPosition - p);
    end;
  finally
    f.Free;
  end;
end;

function TWPCustomRtfEdit.GetSelText: string;
begin
  //V5.14.5 added possibility to use "codepage" in GetSelText
  Result := TextCursor.GetSelText(Memo._CodePage);
  // so we do not need AsANSIString anymore.
  // Result := AsANSIString('ANSI-codepage' + IntToStr(Memo._CodePage), true);
end;

function TWPCustomRtfEdit.AsANSIString(FormatName: string = 'ANSI'; OnlySelection: Boolean = FALSE
  ; CellsAsParagraphs: Boolean = FALSE): AnsiString;
var f: TStringStream;
  o: TStoreOptions;
begin
  f := TStringStream.Create('');
  o := FMemo.StoreOptions;
  try
    if CellsAsParagraphs then
      FMemo.StoreOptions := FMemo.StoreOptions + [soWriteCellsAsParagraphs];
    if OnlySelection then
      SaveSelectionToStream(f, FormatName)
    else SaveToStream(f, FormatName);
    Result := f.DataString;
  finally
    f.Free;
    FMemo.StoreOptions := o;
  end;
end;

procedure TWPCustomRtfEdit.SetSelectionAsString(const x: string);
var f: TStringStream;
begin
  f := TStringStream.Create(x);
  try
    LoadSelectionFromStream(f, 'AUTO');
  finally
    f.Free;
  end;
end;

procedure TWPCustomRtfEdit.SetLastFileName(const x: string);
begin
  if FTheLastFileName <> x then
  begin
    FTheLastFileName := x;
    if assigned(FOnChangeLastFileName) then FOnChangeLastFileName(Self);
  end;
end;

function TWPCustomRtfEdit.LoadFromFile(const FileName: string;
  WithClear: Boolean = FALSE; FormatName: string = ''): Boolean;
var f: TFileStream;
  IsBody, bEmpty: Boolean;
begin
  f := TFileStream.Create(FileName, fmOpenRead + fmShareDenyWrite);
  if FormatName = '' then FormatName := TextLoadFormat;
  try
    if WithClear then
    begin
      Clear;
      IsBody := TRUE;
    end
    else
      if (ActiveText <> nil) and
        (ActiveText.Kind <> wpIsBody) then
        IsBody := FALSE
      else
        IsBody := (Memo.DisplayedText <> nil) and (Memo.DisplayedText.Kind = wpIsBody);
    Memo.FileLoadPath := ExtractFilePath(FileName);
    Memo.FileLoadNameAndPath := FileName;
    bEmpty := IsEmpty;
    Result := Memo.LoadFromStream(f, not bEmpty, FormatName);
    if IsBody then
    begin
      Memo.DisplayedText := Memo.Body;
      Memo.CursorOntext := Memo.DisplayedText;
    end;
    if Result and (WithClear or bEmpty) then
      LastFileName := FileName;
    StartUpdate(WPUPD_REFORMAT);
    if assigned(FOnChangeCursorPos) then
      FOnChangeCursorPos(Self);
    SetFocusValues(WPLastActiveRTFEdit = self);
  finally
    f.Free;
  end;
end;

//##############################################################################
// Change GUI Options ----------------------------------------------------------
//##############################################################################

function TWPCustomRtfEdit.GetZooming: Integer;
begin
  Result := FMemo.Zooming;
end;

procedure TWPCustomRtfEdit.SetZooming(x: Integer);
begin
  if FMemo.Zooming <> x then
  begin
    FMemo.Zooming := x;
    if FMemo.HasData and WordWrap then DelayedReformat
    else StartUpdate(WPUPD_REORDERPAGES);
    StartUpdate(WPUPD_UPDATTRIBUTES);
    if assigned(FOnChangeViewMode) then FOnChangeViewMode(Self);
  end;
end;

function TWPCustomRtfEdit.GetResizing: Integer;
begin
  Result := FMemo.Resizing;
end;

procedure TWPCustomRtfEdit.SetResizing(x: Integer);
begin
  if FMemo.Resizing <> x then
  begin
    FMemo.Resizing := x;
    StartUpdate(WPUPD_REFORMAT);
  end;
end;

function TWPCustomRtfEdit.GetXOffset: Integer;
begin
  Result := FMemo.XOffset;
end;

procedure TWPCustomRtfEdit.SetXOffset(x: Integer);
begin
  if FMemo.XOffset <> x then
  begin
    FMemo.XOffset := x;
    StartUpdate(WPUPD_REORDERPAGES);
  end;
end;

function TWPCustomRtfEdit.GetYOffset: Integer;
begin
  Result := FMemo.YOffset;
end;

procedure TWPCustomRtfEdit.SetYOffset(x: Integer);
begin
  if FMemo.YOffset <> x then
  begin
    FMemo.YOffset := x;
    StartUpdate(WPUPD_REORDERPAGES);
  end;
end;

function TWPCustomRtfEdit.GetXBetween: Integer;
begin
  Result := FMemo.XBetween;
end;

procedure TWPCustomRtfEdit.SetXBetween(x: Integer);
begin
  if FMemo.XBetween <> x then
  begin
    FMemo.XBetween := x;
    StartUpdate(WPUPD_REORDERPAGES);
  end;
end;

function TWPCustomRtfEdit.GetYBetween: Integer;
begin
  Result := FMemo.YBetween;
end;

procedure TWPCustomRtfEdit.SetYBetween(x: Integer);
begin
  if FMemo.YBetween <> x then
  begin
    FMemo.YBetween := x;
    StartUpdate(WPUPD_REORDERPAGES);
  end;
end;

procedure TWPCustomRtfEdit.SetAutoZoom(x: TWPAutoZoom);
begin
  if FMemo.AutoZoom <> x then
  begin
    if FMemo.AutoZoom = wpAutoZoomAdjustColumnCount then
      FMemo.PageColumns := 1;
    FMemo.AutoZoom := x;
    StartUpdate(WPUPD_REORDERPAGES);
    StartUpdate(WPUPD_REPAINT);
    if assigned(FOnChangeViewMode) then FOnChangeViewMode(Self);
  end;
end;

function TWPCustomRtfEdit.GetAutoZoom: TWPAutoZoom;
begin
  Result := FMemo.AutoZoom;
end;

procedure TWPCustomRtfEdit.SetLayoutMode(x: TWPLayoutMode);
begin
  if FMemo.LayoutMode <> x then
  begin
    if not (x in [wplayNormal, // Only show the text area without margins - do not paint background color
      wpWordWrapView, // Like wplayNormal
        wplayShowManualPageBreaks, // Like wplayNormal but show a dashed line for page breakes
        wplayPageGap, // Only show the text area without margins - paint background color between pages
        wplayExtendedPageGap]) then
    begin
      EditBoxModes := EditBoxModes - [wpemLimitTextWidth];
      ReformatAll;
    end;
    FMemo.LayoutMode := x;
    StartUpdate(WPUPD_REORDERPAGES);
    StartUpdate(WPUPD_REPAINT);
    if assigned(FOnChangeViewMode) then FOnChangeViewMode(Self);
  end;
end;

function TWPCustomRtfEdit.GetLayoutMode: TWPLayoutMode;
begin
  Result := FMemo.LayoutMode;
end;

function TWPCustomRtfEdit.GetPageColumns: Integer;
begin
  Result := FMemo.PageColumns;
end;

procedure TWPCustomRtfEdit.SetPageColumns(x: Integer);
begin
  if FMemo.PageColumns <> x then
  begin
    FMemo.PageColumns := x;
    StartUpdate(WPUPD_REORDERPAGES);
    StartUpdate(WPUPD_REPAINT);
  end;
end;

function TWPCustomRtfEdit.GetPageNumber: Integer;
begin
  Result := FMemo.PageNumber;
end;

function TWPCustomRtfEdit.GetPageCount: Integer;
begin
  if SinglePageMode and (FAttachedEditBox <> nil) then
    Result := FAttachedEditBox.PageCount // for TWPPreview!
  else Result := FMemo.PaintPageCount;
end;

function TWPCustomRtfEdit.GetCurrentZooming: Integer;
begin
  Result := Round(FMemo.CurrentZooming * 100);
end;

procedure TWPCustomRtfEdit.SetPageNumber(x: Integer);
begin
  if x < 0 then x := 0;
  FMemo.PageNumber := x;
  Invalidate;
end;

procedure TWPCustomRtfEdit.SetPaperColor(x: TColor);
begin
  if FMemo.PaperColor <> x then
  begin
    FMemo.PaperColor := x;
    FMemo._DBufferIsValid := FALSE;
    FMemo.InitializePaintPages;
    FMemo.ReorderPaintPages;
    Invalidate;
  end;
end;

function TWPCustomRtfEdit.GetPaperColor: TColor;
begin
  Result := FMemo.PaperColor;
end;

procedure TWPCustomRtfEdit.SetDeskColor(x: TColor);
begin
  if FMemo.DeskColor <> x then
  begin
    FMemo.DeskColor := x;
    FMemo._DBufferIsValid := FALSE;
    FMemo.InitializePaintPages;
    FMemo.ReorderPaintPages;
    Invalidate;
  end;
end;

function TWPCustomRtfEdit.GetDeskColor: TColor;
begin
  Result := FMemo.DeskColor;
end;

procedure TWPCustomRtfEdit.SetHighLightColor(x: TColor);
begin
  FMemo.HighLightColor := x;
end;

function TWPCustomRtfEdit.GetHighLightColor: TColor;
begin
  Result := FMemo.HighLightColor;
end;

procedure TWPCustomRtfEdit.SetHighLightTextColor(x: TColor);
begin
  FMemo.HighLightTextColor := x;
end;

function TWPCustomRtfEdit.GetHighLightTextColor: TColor;
begin
  Result := FMemo.HighLightTextColor;
end;


function TWPCustomRtfEdit.GetFormatOptions: TWPFormatOptions;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    Result := FIDEFormatOptions
  else Result := FMemo.RTFData.FormatOptions;
end;

procedure TWPCustomRtfEdit.SetFormatOptions(x: TWPFormatOptions);
var par: TParagraph;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    FIDEFormatOptions := x
  else
  begin
    if x <> FMemo.RTFData.FormatOptions then
    begin
      par := FMemo.RTFData.FirstPar;
      while par <> nil do
      begin
        include(par.prop, paprMustInit);
        par := par.globalnext;
      end;
    end;

    if (FMemo.RTFData.FormatOptions * [wpfAlwaysFormatWithScreenRes])
      <> (x * [wpfAlwaysFormatWithScreenRes]) then
    begin
      FMemo.RTFData.FormatOptions := x;
      FMemo.RTFData.UpdateReformatMode;
    end else
    begin
      FMemo.RTFData.FormatOptions := x;
      DelayedReformat;
    end;
  end;
end;

function TWPCustomRtfEdit.GetFormatOptionsEx: TWPFormatOptionsEx;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    Result := FIDEFormatOptionsEx
  else Result := FMemo.RTFData.FormatOptionsEx;
end;

procedure TWPCustomRtfEdit.SetFormatOptionsEx(x: TWPFormatOptionsEx);
var par: TParagraph;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    FIDEFormatOptionsEx := x
  else
  begin
    if x <> FMemo.RTFData.FormatOptionsEx then
    begin
      par := FMemo.RTFData.FirstPar;
      while par <> nil do
      begin
        include(par.prop, paprMustInit);
        par := par.globalnext;
      end;
      FMemo.RTFData.FormatOptionsEx := x;
      DelayedReformat;
    end;
  end;
end;

procedure TWPCustomRtfEdit.SetSinglePageMode(x: Boolean);
begin
  FMemo.SinglePageMode := x;
end;

function TWPCustomRtfEdit.GetSinglePageMode: Boolean;
begin
  Result := FMemo.SinglePageMode;
end;

function TWPCustomRtfEdit.DefaultAttr: TWPOwnedCharAttrInterface;
begin
  Result := FMemo.RTFData.ANSITextAttr;
end;

function TWPCustomRtfEdit.WritingAttr: TWPCurrentWritingmodeAttrInterface;
begin
  Result := FMemo.RTFData.Cursor.WritingTextAttr;
end;

function TWPCustomRtfEdit.AttrHelper: TWPStoredCharAttrInterface;
begin
  Result := FMemo.RTFData.RTFProps.AttrHelper;
end;

function TWPCustomRtfEdit.SelectedTextAttr: TWPSelectedTextAttrInterface;
begin
  Result := FMemo.RTFData.Cursor.SelectedTextAttr;
end;


procedure TWPCustomRtfEdit.SetOnRequestStyle(x: TWPOnRequestStyleEvent);
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    FIDEOnRequestStyle := x
  else
    FMemo.RTFData.OnRequestStyle := x;
end;

function TWPCustomRtfEdit.GetOnRequestStyle: TWPOnRequestStyleEvent;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    Result := FIDEOnRequestStyle
  else Result := FMemo.RTFData.OnRequestStyle;
end;

procedure TWPCustomRtfEdit.SetOnRequestHTTPString(x: TWPRequestHTTPStringEvent);
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    FIDEOnRequestHTTPString := x
  else
    FMemo.RTFData.OnRequestHTTPString := x;
end;

function TWPCustomRtfEdit.GetOnRequestHTTPString: TWPRequestHTTPStringEvent;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    Result := FIDEOnRequestHTTPString
  else Result := FMemo.RTFData.OnRequestHTTPString;
end;

function TWPCustomRtfEdit.GetViewOptions: TWPViewOptions;
begin
  Result := FMemo.ViewOptions;
end;

procedure TWPCustomRtfEdit.SetViewOptions(x: TWPViewOptions);
begin
  if FMemo.ViewOptions <> x then
  begin
    FMemo.ViewOptions := x;
    StartUpdate(WPUPD_REPAINT);
  end;
end;

procedure TWPCustomRtfEdit.SetCaretDisabled(x: Boolean);
begin
  if x then
    EditOptionsEx := EditOptionsEx + [wpDisableCaret]
  else EditOptionsEx := EditOptionsEx - [wpDisableCaret];

  if (FCaret <> nil) and Focused then
  begin
    if x then
    begin
      FCaret.Active := FALSE;
      FCaret.Visible := FALSE;
      FCaret.Move;
    end else
    begin
      FCaret.Visible := TRUE;
      FCaret.Active := TRUE;
      FCaret.Move;
    end;
  end;
end;

function TWPCustomRtfEdit.GetCaretDisabled: Boolean;
begin
  Result := wpDisableCaret in EditOptionsEx;
end;

procedure TWPCustomRtfEdit.SetTopOffset(y: Integer);
begin
  if FMemo.TopOffset <> y then
  begin
    FMemo._DBufferIsValid := FALSE;
    FMemo.TopOffset := y;
    invalidate;
  end;
end;

function TWPCustomRtfEdit.GetTopOffset: Integer;
begin
  Result := FMemo.TopOffset;
end;

procedure TWPCustomRtfEdit.SetLeftOffset(x: Integer);
begin
  if FMemo.LeftOffset <> x then
  begin
    FMemo._DBufferIsValid := FALSE;
    FMemo.LeftOffset := x;
    invalidate;
  end;
end;

function TWPCustomRtfEdit.GetLines: TStrings;
begin
  CheckActiveText;
  Result := ActiveText.Lines;
end;

procedure TWPCustomRtfEdit.SetLines(x: TStrings);
begin
  CheckActiveText;
  ActiveText.Lines.Assign(x);
end;

function TWPCustomRtfEdit.GetLeftOffset: Integer;
begin
  Result := FMemo.LeftOffset;
end;

function TWPCustomRtfEdit.GetDrawGrid: Boolean;
begin
  Result := FALSE; //TODO
end;

procedure TWPCustomRtfEdit.SetDrawGrid(x: Boolean);
begin

end;

function TWPCustomRtfEdit.GetShowPagenumber: Boolean;
begin
  Result := wpShowPageNRinGap in ViewOptions;
end;

procedure TWPCustomRtfEdit.SetShowPagenumber(x: Boolean);
begin
  if x <> (wpShowPageNRinGap in ViewOptions) then
  begin
    if x then ViewOptions := ViewOptions + [wpShowPageNRinGap]
    else ViewOptions := ViewOptions - [wpShowPageNRinGap];
  end;
end;

function TWPCustomRtfEdit.GetColumns: Integer;
begin
  Result := FMemo.PageColumns;
end;

procedure TWPCustomRtfEdit.SetColumns(x: Integer);
begin
  FMemo.PageColumns := x;
end;

function TWPCustomRtfEdit.GetRows: Integer;
begin
  Result := FMemo.PageRows;
end;

procedure TWPCustomRtfEdit.SetRows(x: Integer);
begin
  FMemo.PageRows := x;
end;

function TWPCustomRtfEdit.GetProtectProp: TProtectProp;
begin
  Result := FMemo.ProtectedProp;
end;

procedure TWPCustomRtfEdit.SetProtectProp(x: TProtectProp);
begin
  FMemo.ProtectedProp := x;
end;

function TWPCustomRtfEdit.GetInserting: Boolean;
begin
  if FMemo.HasData then
    Result := TextCursor.Inserting
  else Result := TRUE; // deafult
end;

procedure TWPCustomRtfEdit.SetInserting(x: Boolean);
begin
  TextCursor.Inserting := x;
end;

function TWPCustomRtfEdit.GetOnCheckProtection: TWPCheckProtectedEvent;
begin
  Result := FMemo.OnCheckProtection;
end;

procedure TWPCustomRtfEdit.SetOnCheckProtection(x: TWPCheckProtectedEvent);
begin
  FMemo.OnCheckProtection := x;
end;

function TWPCustomRtfEdit.GetOnEditFieldGetSize: TWPEditFieldGetSize;
begin
  Result := FMemo.OnEditFieldGetSize;
end;

procedure TWPCustomRtfEdit.SetOnEditFieldGetSize(x: TWPEditFieldGetSize);
begin
  FMemo.OnEditFieldGetSize := x;
end;

function TWPCustomRtfEdit.GetOnEditFieldFocus: TWPEditFieldFocusEvent;
begin
  Result := FMemo.OnEditFieldFocus;
end;

procedure TWPCustomRtfEdit.SetOnEditFieldFocus(x: TWPEditFieldFocusEvent);
begin
  FMemo.OnEditFieldFocus := x;
end;

//++++++++++++++ TCharacterAttr, -Tags +++++++++++++++++++++++++++++++++++++++++

function TWPCustomRtfEdit.IsTextAttrStored: Boolean;
begin
  Result := not FAllowMultiView;
end;

procedure TWPCustomRtfEdit.SetInsertPointAttr(x: TCharacterAttrTags);
begin
  FMemo.RTFData.SpecialTextAttr[wpInsertpoints].Assign(x);
end;

function TWPCustomRtfEdit.GetInsertPointAttr: TCharacterAttrTags;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpInsertpoints] as TCharacterAttrTags;
end;

procedure TWPCustomRtfEdit.SetHiddenTextAttr(x: TCharacterAttr);
begin
  FMemo.RTFData.SpecialTextAttr[wpHiddenText].Assign(x);
end;

function TWPCustomRtfEdit.GetHiddenTextAttr: TCharacterAttr;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpHiddenText];
end;

procedure TWPCustomRtfEdit.SetAutomaticTextAttr(x: TCharacterAttr);
begin
  FMemo.RTFData.SpecialTextAttr[wpAutomaticText].Assign(x);
end;

function TWPCustomRtfEdit.GetAutomaticTextAttr: TCharacterAttr;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpAutomaticText];
end;

procedure TWPCustomRtfEdit.SetHyperlinkTextAttr(x: TCharacterAttrTags);
begin
  FMemo.RTFData.SpecialTextAttr[wpHyperlink].Assign(x);
end;

function TWPCustomRtfEdit.GetHyperlinkTextAttr: TCharacterAttrTags;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpHyperlink] as TCharacterAttrTags;
end;

procedure TWPCustomRtfEdit.SetProtectedTextAttr(x: TCharacterAttr);
begin
  FMemo.RTFData.SpecialTextAttr[wpProtectedText].Assign(x);
end;

function TWPCustomRtfEdit.GetProtectedTextAttr: TCharacterAttr;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpProtectedText];
end;

procedure TWPCustomRtfEdit.SetBookmarkTextAttr(x: TCharacterAttrTags);
begin
  FMemo.RTFData.SpecialTextAttr[wpBookmarkedText].Assign(x);
end;

function TWPCustomRtfEdit.GetBookmarkTextAttr: TCharacterAttrTags;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpBookmarkedText] as TCharacterAttrTags;
end;

procedure TWPCustomRtfEdit.SetFieldObjectTextAttr(x: TCharacterAttr);
begin
  FMemo.RTFData.SpecialTextAttr[wpFieldTextObjects].Assign(x);
end;

function TWPCustomRtfEdit.GetFieldObjectTextAttr: TCharacterAttr;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpFieldTextObjects];
end;

procedure TWPCustomRtfEdit.SetSPANObjectTextAttr(x: TCharacterAttrTags);
begin
  FMemo.RTFData.SpecialTextAttr[wpSPANStyle].Assign(x);
end;

function TWPCustomRtfEdit.GetSPANObjectTextAttr: TCharacterAttrTags;
begin
  Result := FMemo.RTFData.SpecialTextAttr[wpSPANStyle] as TCharacterAttrTags;
end;

procedure TWPCustomRtfEdit.SetWriteObjectMode(x: TWPObjectWriteRTFModeGlobal);
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    FIDEWriteObjectMode := x
  else
    FMemo.RTFData.WriteObjectMode := x;
end;

function TWPCustomRtfEdit.GetWriteObjectMode: TWPObjectWriteRTFModeGlobal;
begin
  if not FIDEValueLoaded or not FMemo.HasData then
    Result := FIDEWriteObjectMode
  else Result := FMemo.RTFData.WriteObjectMode;
end;

// +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


function TWPCustomRtfEdit.GetEditBoxModes: TWPEditBoxModes;
begin
  Result := FMemo.EditBoxModes;
end;

procedure TWPCustomRtfEdit.SetEditBoxModes(x: TWPEditBoxModes);
begin
  FMemo.EditBoxModes := x;
  if FMemo.HasData then
  begin
    FMemo.RTFData.NeedReformat;
    StartUpdate(WPUPD_REFORMAT);
  end;
end;

function TWPCustomRtfEdit.GetWordWrap: Boolean;
begin
  Result := wpemLimitTextWidth in EditBoxModes;
end;

procedure TWPCustomRtfEdit.SetWordWrap(x: Boolean);
begin
  if x <> GetWordWrap then
  begin
    if x then
    begin
      EditBoxModes := EditBoxModes + [wpemLimitTextWidth];
      ReformatAll;
      if not (LayoutMode in [wplayNormal, // Only show the text area without margins - do not paint background color
        wpWordWrapView, // Like wplayNormal
          wplayShowManualPageBreaks, // Like wplayNormal but show a dashed line for page breakes
          wplayPageGap, // Only show the text area without margins - paint background color between pages
          wplayExtendedPageGap]) then LayoutMode := wplayNormal;
    end
    else
    begin
      EditBoxModes := EditBoxModes - [wpemLimitTextWidth];
      ReformatAll;
    end;
    if assigned(FOnChangeViewMode) then FOnChangeViewMode(Self);
  end;
end;

function TWPCustomRtfEdit.GetTextLoadFormat: string;
begin
  Result := FMemo.TextLoadFormat;
end;

procedure TWPCustomRtfEdit.SetTextLoadFormat(x: string);
begin
  FMemo.TextLoadFormat := x;
end;

function TWPCustomRtfEdit.GetTextSaveFormat: string;
begin
  Result := FMemo.TextSaveFormat;
end;

procedure TWPCustomRtfEdit.SetTextSaveFormat(x: string);
begin
  FMemo.TextSaveFormat := x;
end;

function TWPCustomRtfEdit.GetTextLoadSaveOptions: string;
begin
  Result := FMemo.TextLoadSaveOptions;
end;

procedure TWPCustomRtfEdit.SetTextLoadSaveOptions(x: string);
begin
  FMemo.TextLoadSaveOptions := x;
end;

function TWPCustomRtfEdit.GetOnGetAttrColor: TWPGetAttrColorEvent;
begin
  Result := FMemo.OnGetAttributeColor;
end;

procedure TWPCustomRtfEdit.SetOnGetAttrColor(x: TWPGetAttrColorEvent);
begin
  FMemo.OnGetAttributeColor := x;
end;

function TWPCustomRtfEdit.GetOnTextObjectPaint: TWPTextObjectPaintEvent;
begin
  Result := FMemo.OnTextObjectPaint;
end;

procedure TWPCustomRtfEdit.SetOnTextObjectPaint(x: TWPTextObjectPaintEvent);
begin
  FMemo.OnTextObjectPaint := x;
end;

function TWPCustomRtfEdit.GetOnTextObjGetTextEx: TWPOnTextObjGetTextEvent;
begin
  Result := FMemo.OnTextObjGetText;
end;

procedure TWPCustomRtfEdit.SetOnTextObjGetTextEx(x: TWPOnTextObjGetTextEvent);
begin
  FMemo.OnTextObjGetText := x;
end;

function TWPCustomRtfEdit.GetOnGetPageGapText: TWPOnGetPageGapText;
begin
  Result := FMemo.OnGetPageGapText;
end;

procedure TWPCustomRtfEdit.SetOnGetPageGapText(x: TWPOnGetPageGapText);
begin
  FMemo._OnGetPageGapText := x;
end;

function TWPCustomRtfEdit.GetOnActivatingHotStyle: TWPActivatingHotStyle;
begin
  Result := FMemo.OnActivatingHotStyle;
end;

procedure TWPCustomRtfEdit.SetOnActivatingHotStyle(x: TWPActivatingHotStyle);
begin
  FMemo.OnActivatingHotStyle := x;
end;

function TWPCustomRtfEdit.GetOnDeactivateHotStyle: TWPDeactivateHotStyle;
begin
  Result := FMemo.OnDeactivateHotStyle;
end;

procedure TWPCustomRtfEdit.SetOnDeactivateHotStyle(x: TWPDeactivateHotStyle);
begin
  FMemo.OnDeactivateHotStyle := x;
end;

function TWPCustomRtfEdit.GetOnCustomLinePaintBefore: TWPVirtPagePaintEvent;
begin
  Result := FMemo.OnCustomLinePaintBefore;
end;

procedure TWPCustomRtfEdit.SetOnCustomLinePaintBefore(x: TWPVirtPagePaintEvent);
begin
  FMemo.OnCustomLinePaintBefore := x;
end;

function TWPCustomRtfEdit.GetOnCustomLinePaintAfter: TWPVirtPagePaintEvent;
begin
  Result := FMemo.OnCustomLinePaintAfter;
end;

procedure TWPCustomRtfEdit.SetOnCustomLinePaintAfter(x: TWPVirtPagePaintEvent);
begin
  FMemo.OnCustomLinePaintAfter := x;
end;


function TWPCustomRtfEdit.GetBeforeInitializePar: TWPInitializeParEvent;
begin
  Result := FMemo.BeforeInitializePar;
end;

procedure TWPCustomRtfEdit.SetBeforeInitializePar(x: TWPInitializeParEvent);
begin
  FMemo.BeforeInitializePar := x;
end;

function TWPCustomRtfEdit.GetOnPrepareParForPaint: TWPInitializeParEvent;
begin
  Result := FMemo.OnPrepareParForPaint;
end;

procedure TWPCustomRtfEdit.SetOnPrepareParForPaint(x: TWPInitializeParEvent);
begin
  FMemo.OnPrepareParForPaint := x;
end;

function TWPCustomRtfEdit.GetBeforeDestroyPaintPage: TWPBeforeDestroyPaintPage;
begin
  Result := FMemo.BeforeDestroyPaintPage;
end;

function TWPCustomRtfEdit.GetOnPaintWatermark: TWPOnPaintWatermarkEvent;
begin
  Result := FMemo.OnPaintWatermark;
end;

function TWPCustomRtfEdit.GetOnPaintExternPage: TWPOnPaintExternPageEvent;
begin
  Result := FMemo.OnPaintExternPage;
end;

procedure TWPCustomRtfEdit.SetBeforeDestroyPaintPage(x: TWPBeforeDestroyPaintPage);
begin
  FMemo.BeforeDestroyPaintPage := x;
end;

procedure TWPCustomRtfEdit.SetOnPaintWatermark(x: TWPOnPaintWatermarkEvent);
begin
  FMemo.OnPaintWatermark := x;
end;

procedure TWPCustomRtfEdit.SetOnPaintExternPage(x: TWPOnPaintExternPageEvent);
begin
  FMemo.OnPaintExternPage := x;
end;

procedure TWPCustomRtfEdit.SetOnMeasureTextPage(x: TWPMeasurePageEvent);
begin
  FMemo.OnMeasureTextPage := x;
end;

function TWPCustomRtfEdit.GetOnGetSpecialText: TWPOnGetSpecialTextEvent;
begin
  Result := FMemo.RTFData.OnGetSpecialText;
end;

function TWPCustomRtfEdit.GetMemoCanvas: TCanvas;
begin
  if FCurrentDoubleBuffer <> nil then Result := FCurrentDoubleBuffer.Canvas
  else Result := inherited Canvas;
end;

procedure TWPCustomRtfEdit.SetOnGetSpecialText(x: TWPOnGetSpecialTextEvent);
begin
  if Assigned(x) or FMemo.HasData then
    FMemo.RTFData.OnGetSpecialText := x;
end;

procedure TWPCustomRtfEdit.SetOnCalcPageNr(x: TWPOnCalcPageNr);
begin
  FMemo.OnCalcPageNr := x;
end;

function TWPCustomRtfEdit.GetOnCalcPageNr: TWPOnCalcPageNr;
begin
  Result := FMemo.OnCalcPageNr;
end;

function TWPCustomRtfEdit.GetOnMeasureTextPage: TWPMeasurePageEvent;
begin
  Result := FMemo.OnMeasureTextPage;
end;

//##############################################################################
// TWPPreview
//##############################################################################

constructor TWPPreview.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  //FMemo._LockRTFData := TRUE;
  FThisIsWPPreview := TRUE;
  Readonly := TRUE;
  ViewOptions := ViewOptions + [wpHideSelection, wpUseOwnDoubleBuffer, wpDisableMisspellMarkers,
    wpDontGrayHeaderFooterInLayout];
  EditOptions := [];
  EditOptionsEx := [wpDisableSelection, wpDisableCaret];
end;

procedure TWPPreview.Paint;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then exit;

  if (FAttachedEditBox <> nil)
    and (csDestroying in FAttachedEditBox.ComponentState) then exit;

  if (FAttachedEditBox <> nil) and
    (FMemo.HasData) and
    ((FMemo.DisplayedText = nil) or not
    FMemo.RTFData.Verify(FMemo.DisplayedText)) then
    FMemo.DisplayedText :=
      HeaderFooter.Find(wpIsBody, wpraOnAllPages);

 // If we are displaying the same text make sure we use the same count
 // of paint pages

  if not FInPaintProc and
    not SinglePageMode and
    (FAttachedEditBox <> nil) and
    (FMemo.DisplayedText <> nil) and
    (FMemo.DisplayedText = FAttachedEditBox.DisplayedText) and
    (FMemo.HasData) and
    (FMemo.RTFData.Header._UpdatedPageSize or
    (FAttachedEditBox.PageCount <> PageCount)
    ) then
  try
    FMemo.RTFData.Header._UpdatedPageSize := FALSE;
    FInPaintProc := TRUE;
    FMemo.InitializePaintPages;
    FMemo.ReorderPaintPages;
  finally
    FInPaintProc := FALSE;
  end;

  inherited Paint;
end;

procedure TWPPreview.BeforeDestruction;
begin
  inherited BeforeDestruction;
  if FAttachedEditBox <> nil then
  begin
    SetWPRichText(nil);
  end;
end;

destructor TWPPreview.Destroy;
begin
  FMemo.RemoveRTFData;
  FMemo._RTFDataMemo := nil;
  inherited Destroy;
end;

procedure TWPPreview.SetWPRichText(x: TWPCustomRtfEdit);
begin
  if (x is TWPPreview) then x := nil;
  if FAttachedEditBox <> x then
  begin
    FMemo._RTFDataMemo := nil;
    if FAttachedEditBox <> nil then
      FAttachedEditBox.FPreview := nil;
    FAttachedEditBox := x;
    if assigned(FAttachedEditBox) then
    begin
      FAttachedEditBox.FreeNotification(Self);
      if not (csLoading in ComponentState) then
      begin
        FMemo.RemoveRTFData;
        FMemo._RTFDataMemo := FAttachedEditBox;
        FAttachedEditBox.FPreview := Self;
      end;
    end;
  end;
end;

procedure TWPPreview.Loaded;
begin
  inherited Loaded;
  FLoaded := TRUE;
  if FAttachedEditBox <> nil then
  begin
    FMemo.RemoveRTFData;
    FMemo._RTFDataMemo := FAttachedEditBox;
    FAttachedEditBox.FPreview := Self;
  end;
end;

procedure TWPPreview.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FAttachedEditBox <> nil) and
      (AComponent = FAttachedEditBox) then SetWPRichText(nil);
  end;
end;

procedure TWPPreview.Refresh(SpellCheck: Boolean = FALSE);
begin
  if FAttachedEditBox <> nil then
  begin
    FMemo.InitializePaintPages;
    FMemo.ReorderPaintPages;
    Invalidate;
  end else inherited Refresh(SpellCheck);
end;

procedure TWPPreview.DoBroadcastMsg(Sender: TWPRTFEnginePaint; var Code: Integer; Param: TObject);
begin
  if csDestroying in ComponentState then exit;
  inherited DoBroadcastMsg(Sender, Code, Param);
  if (Code = WPBROADCAST_CHANGE_DISPLAYTEXT) and
    (Param <> nil) and
    ((Param as TWPRTFEnginePaint)._EditBox = FAttachedEditBox) then
  begin
    Memo.DisplayedText := (Param as TWPRTFEnginePaint).DisplayedText;
    invalidate;
  end;
end;

procedure TWPPreview.CreateWnd;
begin
  inherited CreateWnd;
  if (FAttachedEditBox <> nil) and FLoaded then
    FMemo.DisplayedText := FAttachedEditBox.Memo.DisplayedText;
  StartUpdate(WPUPD_REORDERPAGES);
  StartUpdate(WPUPD_REPAINT);
end;

procedure TWPPreview.DestroyWnd;
begin
  FMemo.RemoveRTFData;
  inherited DestroyWnd;
end;

//##############################################################################
// TWPCaret - manages the caret in the memo control ----------------------------
//##############################################################################

constructor TWPCaret.Create(ParentControl: TWinControl; Memo: TWPRTFEnginePaint);
begin
  inherited Create;
  FSx := 0;
  FSy := 0;
  FSw := 3;
  FSh := 16;
  FSactive := FALSE;
  FSblink := FALSE;
  created := FALSE;
  Parent := ParentControl;
  FMemo := Memo;
end;

destructor TWPCaret.Destroy;
begin
  inherited Destroy;
end;

function TWPCaret.GetActive: Boolean;
begin
  Result := FSactive
end;

function TWPCaret.GetBlink: Boolean;
begin
  Result := FSBlink;
end;

procedure TWPCaret.SetVisible(x: Boolean);
begin
  FSvisible := x;
  if x then Handle := Parent.Handle;
end;

procedure TWPCaret.SetDisabled(x: Boolean);
begin
  FSDisabled := x;
  if FSDisabled then
  begin
    created := false;
    DestroyCaret;
    FSactive := FALSE;
  end;
end;

procedure TWPCaret.UpdatePos;
var
  act: Boolean;
  X, Y, H, W: Integer;
begin
  act := FALSE;
  if not FRTFEdit.FAlwaysShowCaret and
    not (wpDontHideCaret in FRTFEdit.FClipboardOptions) and
    ((wpcoDontMoveCursorDuringDrag in FRTFEdit.FClipboardOptions)
    or not FMemo.Cursor.LockSelection) and
    (FMemo.Cursor.IsSelected(true)) then
  begin
    FMemo.GetCursorXYWH(X, Y, W, H); //<-- Update CursorXY !
    Active := FALSE;
    exit;
  end;
  // Hide cursor when in a WPReporter Band, V5.15.6
  if (FMemo.Cursor.active_paragraph <> nil) and
    (FMemo.Cursor.active_paragraph.ParagraphType in
    [wpIsReportGroup, wpIsReportHeaderBand,
    wpIsReportDataBand, wpIsReportFooterBand]) then
  begin
    FMemo.GetCursorXYWH(X, Y, W, H);
    Active := FALSE;
    exit;
  end;

  if not Active then Active := TRUE;
  FMemo.GetCursorXYWH(X, Y, W, H);
  FUpdated := TRUE;
  if w < WPMINCursorWidth then w := WPMINCursorWidth;

  if (FSh <> H) and FSactive then
  begin
    if H < 4 then H := 4;
    active := FALSE;
    act := TRUE;
  end;
  if (FSw <> W) and FSactive then
  begin
    if w < WPMINCursorWidth then w := WPMINCursorWidth;
    active := FALSE;
    act := TRUE;
  end;
  FSx := X;
  FSy := Y;
  FSh := H;
  FSw := W;
  Move;
  if act then active := TRUE;
end;

procedure TWPCaret.Move;
begin
  if created and Visible then
  begin
    if Parent.Focused or FRTFEdit.FAlwaysShowCaret then
    begin
      SetCaretPos(FSx, FSy);
    end;
  end;
end;

procedure TWPCaret.SetBlink(a: Boolean);
begin
  FSblink := a; { how is  ist possible to	turn blinking on or off	? }
end;

procedure TWPCaret.SetActive(a: Boolean);
begin
  if not FUpdated and not visible or not Parent.HandleAllocated then exit;

  if not (wpDontHideCaret in FRTFEdit.FClipboardOptions) and
    ((wpcoDontMoveCursorDuringDrag in FRTFEdit.FClipboardOptions)
    or not FMemo.Cursor.LockSelection
    or FRTFEdit.FAlwaysShowCaret
    ) and
    (FMemo.Cursor.IsSelected(true)) then a := FALSE;

  if (FMemo.Cursor.active_paragraph <> nil) and
    (FMemo.Cursor.active_paragraph.ParagraphType in // WPREPORTER!!!
    [wpIsReportGroup, wpIsReportHeaderBand,
    wpIsReportDataBand, wpIsReportFooterBand]) then a := FALSE;

  if a = TRUE then
  begin
    Make;
    Move;
    if Parent.Focused or FRTFEdit.FAlwaysShowCaret then
    begin
      ShowCaret(Handle);
      FSactive := TRUE;
    end;
  end
  else
  begin
    created := false;
    DestroyCaret;
    FSactive := FALSE;
  end;
end;

procedure TWPCaret.Make;
begin
  if (not visible) or FSDisabled or not Parent.HandleAllocated then exit;
  if Parent.Focused or FRTFEdit.FAlwaysShowCaret then
    CreateCaret(Handle, 0, FSw, FSh);
  created := true;
end;

//##############################################################################
// TWPEditBoxLinks
//##############################################################################

function TWPEditBoxLink.GetEditBox: TWPCustomRtfEdit;
begin
  Result := FEditBox;
end;

procedure TWPEditBoxLink.SetEditBox(x: TWPCustomRtfEdit);
var i: Integer;
begin
  if (FEditBox <> nil) and
    (Collection is TWPEditBoxLinkCollection) then
  begin
    i := FEditBox.FEditBoxLinkCollections.IndexOf(Collection);
    if i >= 0 then
      FEditBox.FEditBoxLinkCollections.Delete(i);
  end;
  FEditBox := x;
  if (FEditBox <> nil) and
    (Collection is TWPEditBoxLinkCollection) and
    (FEditBox.FEditBoxLinkCollections.IndexOf(Collection) < 0) then
    FEditBox.FEditBoxLinkCollections.Add(Collection as TWPEditBoxLinkCollection);
end;

constructor TWPEditBoxLink.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

{$IFNDEF CLR}

destructor TWPEditBoxLink.Destroy;
begin
  EditBox := nil;
  inherited Destroy;
end;
{$ENDIF}

procedure TWPEditBoxLink.Assign(Source: TPersistent);
begin
  if Source is TWPEditBoxLink then
  begin
    EditBox := TWPEditBoxLink(Source).EditBox;
  end
  else
    inherited Assign(Source);
end;

function TWPEditBoxLinkCollection.GetItem(index: Integer): TWPEditBoxLink;
begin
  Result := inherited Items[index] as TWPEditBoxLink;
end;

function TWPEditBoxLinkCollection.FirstEditBox: TWPCustomRtfEdit;
var i: Integer;
begin
  Result := nil;
  for i := 0 to Count - 1 do
  begin
    Result := Items[i].EditBox;
    if Result <> nil then exit;
  end;
end;

procedure TWPEditBoxLinkCollection.ReformatAll(
  InitializeAll: Boolean = FALSE;
  RepaintMemo: Boolean = FALSE);
var i: Integer;
begin
  for i := 0 to Count - 1 do
    if Items[i].EditBox <> nil then
      Items[i].EditBox.ReformatAll(InitializeAll, RepaintMemo);
end;

procedure TWPEditBoxLinkCollection.SetItem(index: Integer; x: TWPEditBoxLink);
var link: TWPEditBoxLink;
begin
  link := (inherited Items[index]) as TWPEditBoxLink;
  link.Assign(x);
end;

function TWPEditBoxLinkCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TWPEditBoxLinkCollection.Remove(EditBox: TWPCustomRtfEdit);
var i: Integer;
begin
  for i := Count - 1 downto 0 do
    if Items[i].EditBox = EditBox then
    begin
      Delete(i);
    end;
end;

procedure TWPEditBoxLinkCollection.DoUpdateState(EditBox: TWPCustomRtfEdit; State: TWPEditBoxLinkMsg);
begin
  if assigned(FOnUpdateState) then
    FOnUpdateState(FOwner, EditBox, State);
end;

procedure TWPEditBoxLinkCollection.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
end;

constructor TWPEditBoxLinkCollection.Create(Owner: TPersistent);
begin
  inherited Create(TWPEditBoxLink);
  FOwner := Owner;
end;

function TWPEditBoxLinkCollection.Add: TWPEditBoxLink;
begin
  Result := inherited Add as TWPEditBoxLink;
end;


//##############################################################################
// TWPDrawFrameVar - draws a frame
//##############################################################################

procedure TWPDrawFrameVar.Draw;
var cl: TColor; pw: Integer;
begin
  if fVisible or fActive then
  begin
    cl := FCanvas.Pen.Color;
    pw := FCanvas.Pen.Width;
    FCanvas.Pen.Color := clWhite;
    FCanvas.Pen.Width := 1;
    FCanvas.Pen.Mode := pmXor;
    FCanvas.Pen.Style := psDot;
    FCanvas.Brush.Style := bsClear;
    FCanvas.Rectangle(fx, fy, fx + fw, fy + fh);
    FCanvas.Rectangle(fx - 1, fy - 1, fx + fw + 1, fy + fh + 1);
    FCanvas.Pen.Mode := pmCopy;
    FCanvas.Pen.Color := cl;
    FCanvas.Pen.Width := pw;
    fVisible := not fVisible;
  end;
end;

procedure TWPDrawFrameVar.Start(Canvas: TCanvas; aWorkObj: TObject; sx, sy, sw, sh: Integer);
begin
  if fVisible and (FCanvas = Canvas) then Draw;
  FCanvas := Canvas;
  fx := sx;
  fy := sy;
  fw := sw;
  fh := sh;
  WorkObj := aWorkObj;
  fActive := TRUE;
  FObjectOffsetX := 0;
  FObjectOffsetY := 0;
  Draw;
end;

procedure TWPDrawFrameVar.Move(dx, dy: Integer; var RelX, RelY: Integer);
var ox, oy: Integer;
begin
  if (dx <> 0) or (dy <> 0) then
  begin
    if fVisible then Draw;
    ox := fx;
    oy := fy;
    fx := fx + dx;
    fy := fy + dy;
       //TODO Check if ok ?
       // if fx<0 then fx := 0;

       // modify Rel
    RelX := RelX + (fx - ox);
    RelY := RelY + (fy - oy);
    Draw;
  end;
end;

procedure TWPDrawFrameVar.Size(deltaw, deltah: Integer; var RelX, RelY: Integer;
  mode: TWPPaintSizerRects = wpSizeNone);
var dw, dh, ox, oy, ow, oh: Integer;
  mult: Extended;
begin
  if (deltaw <> 0) or (deltah <> 0) then
  begin
    if fVisible then Draw;
    if (fw < 5) or (fh < 5) then
      mult := 1
    else mult := fh / fw;
    dw := deltaw;
    dh := deltah;
    ow := fw;
    oh := fh;
    ox := fx;
    oy := fy;
    case mode of
      wpSiz_TL:
        begin dw := -dw;
          dh := -dh;
        end;
      wpSiz_TM:
        begin
          dw := 0;
          dh := -dh;
        end;
      wpSiz_TR:
        begin
          dw := dw;
          dh := -dh;
        end;
      wpSiz_MR:
        begin
          dh := 0;
        end;
      wpSiz_BR:
        begin
          dw := dw;
          dh := dh;
        end;
      wpSiz_BM:
        begin
          dw := 0;
        end;
      wpSiz_BL:
        begin
          dw := -dw;
          dh := dh;
        end;
      wpSiz_ML:
        begin
          dh := 0;
          dw := -dw;
        end;
    end;
    if mode in [wpSiz_TL, wpSiz_TR, wpSiz_BR, wpSiz_BL] then
    begin
      if Abs(dw) < abs(dh) then
      begin
        fw := fw + dw;
        fh := round(fw * mult);
      end else
      begin
        fh := fh + dh;
        fw := round(fh / mult);
      end;
    end
    else
    begin
      fw := fw + dw;
      fh := fh + dh;
    end;
    if fw < 1 then fw := 1;
    if fh < 1 then fh := 1;
    case mode of
      wpSiz_TL:
        begin fx := ox + ow - fw;
          fy := oy + oh - fh;
        end;
      wpSiz_TM:
        begin
          fy := oy + oh - fh;
        end;
      wpSiz_TR:
        begin
          fy := oy + oh - fh;
        end;
      wpSiz_BL:
        begin
          fx := ox + ow - fw;
        end;
      wpSiz_ML:
        begin
          fx := ox + ow - fw;
        end;
    end;
    RelX := RelX + deltaw;
    RelY := RelY + deltah;
    Draw;
  end;
end;

procedure TWPDrawFrameVar.SetActive(x: Boolean);
begin
  if not x then
  begin
    if fVisible then Draw;
    fActive := FALSE;
  end
  else
  begin
    fActive := TRUE;
    if not fVisible then Draw;
  end;
end;

//##############################################################################
// TWPPaperDefinitionCollection
//##############################################################################

function TWPPaperDefinition.GetDisplayName: string;
begin
  Result := Format('%s=%s: %d X %d', [FName, FDisplayName, FWidth, FHeight]);
end;

function TWPPaperDefinition.Compare(W, H: Integer): Integer;
begin
  if (Abs(Width - w) < 14) and (Abs(Height - h) < 14) then // 14 twips = 2 mm
    Result := 0 // equal
  else if (Width < w) or (Height < h) then
    Result := -1 // smaller
  else
    Result := 1; // larger
end;

constructor TWPPaperDefinition.Create(Collection: TCollection);
begin
  inherited Create(Collection);
end;

destructor TWPPaperDefinition.Destroy;
begin
  FName := '';
  FDisplayName := '';
  inherited Destroy;
end;

procedure TWPPaperDefinition.Assign(Source: TPersistent);
begin
  if Source is TWPPaperDefinition then
  begin
    // We do not check if this is valid !
    FName := TWPPaperDefinition(Source).FName;
    FDisplayName := TWPPaperDefinition(Source).FDisplayName;
    FWidth := TWPPaperDefinition(Source).FWidth;
    FHeight := TWPPaperDefinition(Source).FHeight;
    FDEFCode := TWPPaperDefinition(Source).FDEFCode;
    FLocked := TWPPaperDefinition(Source).FLocked;
  end
  else
    inherited Assign(Source);
end;

{ ----------------------------------------------------------------------------- }


constructor TWPPaperDefinitionCollection.Create;
begin
  inherited Create(TWPPaperDefinition);
end;

function TWPPaperDefinitionCollection.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TWPPaperDefinitionCollection.GetItem(index: Integer): TWPPaperDefinition;
begin
  Result := TWPPaperDefinition(inherited items[index]);
end;

procedure TWPPaperDefinitionCollection.SetItem(index: Integer; x: TWPPaperDefinition);
begin
  TWPPaperDefinition(inherited items[index]).Assign(x);
end;

function TWPPaperDefinitionCollection.FindDEF(DEFCode: Integer): Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (Items[Result].DEFCode <> DEFCode) do
    dec(Result);
end;

function TWPPaperDefinitionCollection.FindWH(w, h: Integer): Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and
    ((Items[Result].DefCode = $100) or //V5.18.1 Custom ??
    (Items[Result].DefCode = 0) or
    (Items[Result].Compare(W, H) <> 0)) do
    dec(Result);
  if Result < 0 then
  begin
    Result := Count - 1;
    while (Result >= 0) and
      (Items[Result].Compare(W, H) <> 0) do
      dec(Result);
  end;
end;

//: Deletes not locked definitions and creates a new list

procedure TWPPaperDefinitionCollection.Init(FromPrinter: Boolean);
{$IFDEF DISABLEPRINTER}
begin
end;
{$ELSE}
type
  PPaperCodeArray = ^Word;
  PPaperSizeArray = ^TPOINT;
  TPaperNameArray = array[0..63] of Char;
  PPaperNameArray = ^TPaperNameArray;
var
  i, w, h: Integer;
  pp: TWPPageSettings;
ADevice, ADriver, APort: array[0..1024] of Char; var
  ADeviceMode: THandle;
  numPaperformats: Integer;
  pPaperSizes, pps: PPaperSizeArray;
  pPaperCodes, ppc: PPaperCodeArray;
  pPaperNames, pName: PPaperNameArray;
  Done: Boolean;
begin
  if WPNoPrinterInstalled then exit;
  i := Count - 1;
  while i >= 0 do
  begin
    if not Items[i].Locked then Items[i].Free; // Delete(i);
    dec(i);
  end;
  Done := FALSE;
  // Read values from printer
  if FromPrinter and (FOwner <> nil)
    and not (wpDontReadPapernamesFromPrinter in FOwner.Memo.RTFData.PrintParameter.PrintOptions)
    then
  try
    Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);
    if ADeviceMode <> 0 then
    begin
      numPaperformats := DeviceCapabilities(ADevice, APort, DC_PAPERS, nil, nil);

      if numPaperformats > 0 then
      begin
        GetMem(pPaperSizes, (numPaperformats + 1) * Sizeof(TPOINT));
        GetMem(pPaperCodes, (numPaperformats + 1) * Sizeof(Word));
        GetMem(pPaperNames, (numPaperformats + 1) * Sizeof(TPaperNameArray));
        try
          DeviceCapabilities(ADevice, APort, DC_PAPERS, PChar(pPaperCodes), nil);
          DeviceCapabilities(ADevice, APort, DC_PAPERSIZE, PChar(pPaperSizes), nil);
          DeviceCapabilities(ADevice, APort, DC_PAPERNAMES, PChar(pPaperNames), nil);

          pName := pPaperNames;
          ppc := pPaperCodes;
          pps := pPaperSizes;
          for i := 0 to numPaperformats - 1 do
          begin
            if ppc^ >= 1 then
            begin
              w := WPCentimeterToTwips(pps^.x / 100);
              h := WPCentimeterToTwips(pps^.y / 100);

            // if FindWH(w,h)<0 then  - always add
              with TWPPaperDefinition(Add) do
              begin
                Width := w;
                Height := h;
                DefCode := ppc^;
                DisplayName := StrPas(PChar(pName));
              end;
            end;
            inc(pName);
            inc(ppc);
            inc(pps);
          end; // for I

        finally
          FreeMem(pPaperSizes);
          FreeMem(pPaperCodes);
          FreeMem(pPaperNames);
        end;
        Done := TRUE;
      end;

    end; // if ADeviceMode <> 0 then
  except
    // no printer error here
  end;

  // Use a few predefined values - Only if there is NO locked entry !
  if not Done and (Count = 0) then
  begin
    for pp := Low(TWPPageSettings) to High(TWPPageSettings) do
    begin
      if WPPageSettings[pp].UseCM then
      begin
        w := WPCentimeterToTwips(WPPageSettings[pp].Width);
        h := WPCentimeterToTwips(WPPageSettings[pp].Height);
      end
      else
      begin
        w := WPInchToTwips(WPPageSettings[pp].Width);
        h := WPInchToTwips(WPPageSettings[pp].Height);
      end;
      if FindWH(w, h) < 0 then
        with
          TWPPaperDefinition(Add) do
        begin
          Width := w;
          Height := h;
          DefCode := WPPageSettings[pp].ID;
          DisplayName := WPPageSettings[pp].Name;
        end;
    end;
  end;
end;
{$ENDIF}





//##############################################################################
// This class is responsible to create the reference canvas for reformat
// which is used by the RTF Engine. The RTF Engine needs the references to be
// defined otherwise reformat is not possible
//##############################################################################

constructor TWPToolsEnviroment.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  WPPrinterCanvas := TCanvas.Create;
{$IFDEF RM600}
  FScreenResolution := 600;
{$ENDIF}
end;

destructor TWPToolsEnviroment.Destroy;
begin
  if FWPPrinterCanvasHasHandle then
    WPPrinterClose;
  WPPrinterCanvas.Free;
  // Free DC ...
  if FScreenReference <> nil then
  begin
    TCanvas(FScreenReference).Handle := 0;
    if FScreenReferenceDC <> 0 then
      DeleteDC(FScreenReferenceDC);
    FScreenReferenceDC := 0;
    FScreenReference.Free;
  end;
  inherited Destroy;
end;

// The Result should be a TCanvas but WPDefsNET does not deal with graphics

function TWPToolsEnviroment.GetScreenReference: TObject;
var ScreenDC: HDC;
begin
  if FScreenReference = nil then
  begin
    ScreenDC := GetDC(0);
    try
      FScreenReferenceDC := CreateCompatibleDC(ScreenDC);
      FScreenReference := TCanvas.Create;
      TCanvas(FScreenReference).Handle := FScreenReferenceDC;
      ScreenCanvasPX := GetDeviceCaps(FScreenReferenceDC, LOGPIXELSX);
      ScreenCanvasPY := GetDeviceCaps(FScreenReferenceDC, LOGPIXELSY);

      if FScreenResolution = 0 then
      begin
{$IFDEF RM1440}
        SetMapMode(FScreenReferenceDC, MM_TWIPS);
        ScreenCanvasPX := 1440;
        ScreenCanvasPY := 1440;
{$ENDIF}
      end else if FScreenResolution = 1440 then
      begin
        SetMapMode(FScreenReferenceDC, MM_TWIPS);
        ScreenCanvasPX := 1440;
        ScreenCanvasPY := 1440;
      end else
      begin
        SetMapMode(FScreenReferenceDC, MM_ANISOTROPIC);
        SetWindowExtEx(FScreenReferenceDC, ScreenCanvasPX, ScreenCanvasPY, nil);
        SetViewPortExtEx(FScreenReferenceDC, FScreenResolution, FScreenResolution, nil);
        SetViewPortOrgEx(FScreenReferenceDC, 0, 0, nil);
        ScreenCanvasPX := FScreenResolution;
        ScreenCanvasPY := FScreenResolution;
      end;
    finally
      ReleaseDC(0, ScreenDC);
    end;
  end;
  Result := FScreenReference;
end;

procedure WPCheckPrinterAvail;
{$IFDEF DISABLEPRINTER}
begin
  WPNoPrinterInstalled := TRUE;
end;
{$ELSE}
var
  Flags, Count, NumInfo: DWORD;
  Level: Byte;
begin
  if Win32Platform = VER_PLATFORM_WIN32_NT then
  begin
    Flags := PRINTER_ENUM_CONNECTIONS or PRINTER_ENUM_LOCAL;
    Level := 4;
  end
  else
  begin
    Flags := PRINTER_ENUM_LOCAL;
    Level := 5;
  end;
  Count := 0;
  EnumPrinters(Flags, nil, Level, nil, 0, Count, NumInfo);
  WPNoPrinterInstalled := (Count = 0);
end;
{$ENDIF}

procedure TWPToolsEnviroment.WPPrinterOpenName(pname: string = '');
{$IFDEF DISABLEPRINTER}
begin
  FNoPrinterInstalled := TRUE;
  PrinterCanvasPX := ScreenCanvasPX;
  PrinterCanvasPY := ScreenCanvasPY;
end;
{$ELSE}
var
  ADevice, ADriver, APort: {$IFDEF CLR}string; {$ELSE}array[0..1024] of char; {$ENDIF}
  ADeviceMode: {$IFDEF CLR}IntPtr; {$ELSE}THandle; {$ENDIF}
  hd: HDC;
  i: Integer;
begin
  PrinterCanvasPX := ScreenCanvasPX;
  PrinterCanvasPY := ScreenCanvasPY;
  FNoPrinterInstalled := WPNoPrinterInstalled or (Printer.Printers.Count <= 0);
  if (WPPrinterCanvas = nil) or FNoPrinterInstalled then exit;
  if FWPPrinterCanvasHasHandle then WPPrinterClose;
  try
    if pname <> '' then
    begin
      if CompareText(pname, 'none') = 0 then exit;
      i := Printer.Printers.IndexOf(pname);
      if i >= 0 then Printer.PrinterIndex := i;
    end;
    Printer.GetPrinter(ADevice, ADriver, APort, ADeviceMode);

    if ADevice = '' then
    begin
      FNoPrinterInstalled := TRUE;
      exit;
    end;

    // WAS:  hd := CreateDC(ADriver, ADevice, NIL, nil);
    if ADevice <> '' then
      hd := CreateDC(ADriver, ADevice, nil, nil)
    else
      hd := CreateDC(ADriver, nil, nil, nil);

    if hd <> 0 then
    begin
      i := GetDeviceCaps(hd, TECHNOLOGY);
      PrinterCanvasPX := GetDeviceCaps(hd, LOGPIXELSX);
      PrinterCanvasPY := GetDeviceCaps(hd, LOGPIXELSY);
      if (i = DT_CHARSTREAM) then
      begin
        { ShowMessage('DT_CHARSTREAM -> No WYSIWYG'); }
        DeleteDC(hd);
        exit;
      end;
      WPPrinterHDC := hd;
      WPPrinterName := {$IFNDEF CLR}StrPas{$ENDIF}(ADevice);
      WPPrinterCanvas.Handle := hd;
      FWPPrinterCanvasHasHandle := TRUE;
    end
    else
      WPPrinterHDC := 0;
  except
    FNoPrinterInstalled := TRUE;
  end;
end;
{$ENDIF}

procedure TWPToolsEnviroment.WPPrinterClose;
{$IFDEF DISABLEPRINTER}
begin end;
{$ELSE}
begin
  try
    if WPPrinterCanvas = nil then exit;
    if FWPPrinterCanvasHasHandle then
    begin
      WPPrinterCanvas.Handle := 0;
      DeleteDC(WPPrinterHDC);
      FWPPrinterCanvasHasHandle := FALSE;
      WPPrinterName := '';
      WPPrinterHDC := 0;
    end;
  except
  end;
end;
{$ENDIF}

function TWPToolsEnviroment.GetPrinterReference: TObject;
begin
  if not FWPPrinterCanvasHasHandle then WPPrinterOpenName;
  if FNoPrinterInstalled then Result := GetScreenReference
  else Result := WPPrinterCanvas;
end;

function TWPToolsEnviroment.GetScreenXPixelsPerInch: Integer;
begin
  Result := ScreenCanvasPX;
end;

function TWPToolsEnviroment.GetScreenYPixelsPerInch: Integer;
begin
  Result := ScreenCanvasPY;
end;

function TWPToolsEnviroment.GetPrinterXPixelsPerInch: Integer;
begin
  Result := PrinterCanvasPX;
end;

function TWPToolsEnviroment.GetPrinterYPixelsPerInch: Integer;
begin
  Result := PrinterCanvasPY;
end;

function TWPToolsEnviroment.FindDialog: TFindDialog;
begin
  Result := FFindDialog;
end;


function TWPToolsEnviroment.ReplaceDialog: TReplaceDialog;
begin
  Result := FReplaceDialog;
end;

function TWPToolsEnviroment.MayOpenDialog(WPRichText: TWPCustomRtfEdit;
  Dialog: TComponent; Form: TForm): Boolean;
begin
  Result := TRUE;
  if assigned(FBeforeExecuteDialog) then
    FBeforeExecuteDialog(Self, WPRichText, Dialog, Form, Result);
end;

procedure TWPToolsEnviroment.DoBeforeShow(WPRichText: TWPCustomRtfEdit; DialogCtrl: TComponent; Form: TForm);
begin
  if assigned(FBeforeShowDialog) then
    FBeforeShowDialog(Self, WPRichText, DialogCtrl, Form);
end;

function TWPToolsEnviroment.GetEditorArray(index: Integer): TWPCustomRtfEdit;
begin
  Result := TWPCustomRtfEdit(FRTFEditors[index]);
end;

function TWPToolsEnviroment.GetEditorCount: Integer;
begin
  Result := FRTFEditors.Count;
end;

//##############################################################################
// Create the one global enviroment which contains all working variables
// For multi threaded applications you need to create for each thread an
// individual TWPToolsEnviroment component and assign it to the TRTFProps object
//##############################################################################

var Temp: TWPToolsEnviroment;

initialization
  WPCheckPrinterAvail;
  Temp := TWPToolsEnviroment.Create(nil);
  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    Temp.Assign(GlobalWPToolsCustomEnviroment);
    GlobalWPToolsCustomEnviroment.Free;
  end;
  GlobalWPToolsCustomEnviroment := Temp;

finalization
  GlobalWPToolsCustomEnviroment.Free;
  GlobalWPToolsCustomEnviroment := nil;

end.

