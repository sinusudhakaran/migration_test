unit WPCTRRich;
//******************************************************************************
// WPTools V5, WPTools 6 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPCTRRich - WPTools 5+6 editor control wrapper to provide the best possible
// compatibility to WPTools V4. Please note that the procedures and properties
// provided here will not be supported in the upcoming WPTools.NET for WinForms
// Product.
//******************************************************************************

{$I WPINC.INC}
{$R WPFillBits.res}
{$DEFINE IWPGUTTER}

{.$DEFINE DONT_REPORT_DEFAULT_ATTR}//OFF: If font name or font size is undefined, dont report default and style attributes
// Since DONT_REPORT_DEFAULT_ATTR is also used in WPActions.PAS it has to be defined globally !
{.$DEFINE DONT_REPORT_DEFAULT_ATTR_STYLE}//OFF: If the style (bold etc) is undefined, dont report default and style attributes
{.$DEFINE DONT_REPORT_DEFAULT_ATTR_COLOR}//OFF: If the color is undefined, dont report default and style attributes
{.$DEFINE NUMBERACTION_SIMPLE}//OFF (V5.19.7) when pressing the number action simple numbering is used
{$DEFINE RESTART_NUMBERING_ALA_MSWORD} //ON
{.$DEFINE REPLACEALL_FROM_CP}//OFF: ReplaceAll in dialog only replaces from current cursor position
{.$DEFINE COMBINECELLTOTAL}//V5.20.8 use CombineCellsVertHorz in place of CombineCells
{-$DEFINE REPLACEPROTECTED}//V5.44. should be OFF 

interface

uses Forms, SysUtils, Windows, StdCtrls, ExtCtrls, Messages,
{$IFNDEF DISABLEPRINTER}{$IFDEF WPXPRN}WPX_Printers, WPX_Dialogs, {$ELSE}Printers, Dialogs, {$ENDIF}{$ENDIF}
  Classes, Controls, Graphics, ExtDlgs, WPRTEDefs, WPRTEPaint,
  WPCTRMemo, ActnList, ClipBrd, WPRuler
  ;

const DefaultAttrAlsoForSelectedText = false;  //V5.37 - true to report empty font if selection returns empty string

type
  TWPSetModeControl = class;
  TWPCustomRichText = class;
  TWPCustomToolCtrl = class;

  TNotifyRTFEditChangedEvent = procedure(Sender: TObject; NewRTFEdit:
    TWPCustomRichText) of object;

  TWPOnTextNotFound = procedure(Sender: TObject; var TryFromStart: Boolean)
    of object;

  TWPNotifyAttrEvent = procedure(Sender: TObject; Attribute: TWPSetModeControl)
    of object;

  {:: @depreciated
   This flags are used by TParProps. TParProps are used by FastAddText, the
  "version 4" way to create text by program code. }
  TParPropsOption = (ppoEnabled,
    ppoIndentfirst,
    ppoIndentleft,
    ppoIndentright,
    ppoSpacebefore,
    ppoSpaceafter,
    ppoSpacebetween,
    ppoMultSpacing,
    ppoBorderType,
    // obsolete ppoTabs,
    ppoNewPage,
    ppoColor,
    ppoShading,
    ppoAlign,
    ppoAttr,
    ppoTabsList,
    ppoParProtected,
    ppoParID,
    ppoCellAlign);

  TParPropsOptions = set of TParPropsOption;

{$IFDEF V4COMAPT}
  TWhatToChange = set of (wtcFont, wtcSize, wtcColor, wtcBKColor, wtcStyle,
    wtcAddStyle, wtcSubStyle);
{$ENDIF}

  TParProps = record
    Options: TParPropsOptions;
    Indentfirst, Indentleft, Indentright: Integer;
    Spacebefore, Spaceafter, Spacebetween: Integer;
    BorderType: TBorder;
    Color: Integer;
    Shading: Integer;
    Align: TParAlign;
    TabsPosList: array[0..5] of Integer;
    TabsKindList: array[0..5] of TTabKind;
    //obsolete in V5: Tab: TTabFlag;
    ParProtected: Boolean;
    CellAlignCenter: Boolean; // Option ppoCellVertAlign
    CellAlignBottom: Boolean; // Option ppoCellVertAlign
    Id: Integer;
    { --- }
    Attr: TAttr;
    Text: string;
    wText: WideString; // new in V5
    //obsolete in V5: pText: PChar;

    // This is only supported in the NON CLR version
    pa: PTAttr;

    parr: array of TAttr; // New version of 'pa'
    Obj: TObject; // Graphic of type TWPObject
    // Old, width/255 value. Please no not use:
    CWidth: Integer;
    // New Width in Percent *100
    Width_PC: Integer; // new in V5
    // New Width in Twips
    Width_TW: Integer; // new in V5
    NewPage: Boolean;
    ColSpan: Integer;
    CellName: string;
    CellCommand: string;
    CellFormat: Integer;
  end;

  {:: This type is not supported in Delphi 8 since there pointers are not allowed }
  PTParProps = ^TParProps;

{$IFDEF IWPGUTTER}
  TWPCustomGutter = class(TCustomPanel)
  protected
    FEditBox: TWPCustomRichText;
    procedure ChangeCurrentPar; virtual; abstract;
    procedure ChangeDisplay; virtual; abstract;
  end;
{$ENDIF}

  TWPCustomRichText = class(TWPCustomRtfEdit) // from unit WPCTRMemo
  private

{$IFDEF V4COMAPT}
    FANSIText: string;
{$ENDIF}
    FCurrAttr: TWPSetModeControl;
    FTempFont : TFont;
    FDiaParam: string;
    FReplaceDialog_last_was_search: Boolean;
    FReplaceDialog_last_sel_start: Integer;
    FIOLocked: Boolean;
    FHeaderFooterTextRange: TWPPagePropertyRange;
    FOnTextNotFound: TWPOnTextNotFound;
    FInitialDir, FDefaultIOFormat: string;
    function GetWorkOnText: TWPPagePropertyKind;
    procedure SetWorkOnText(x: TWPPagePropertyKind);
    procedure SetHeaderFooterTextRange(x: TWPPagePropertyRange);
    function GetHeaderFooterTextRange: TWPPagePropertyRange;
    procedure FastSetText(par: TParagraph; const prp: TParProps);

  protected

    FUnSetHidden, FUpdateActionStateAtOnce: Boolean;
    FCharacterAttrChange: TWPNotifyAttrEvent;
    FInsertedObj: TWPTextObj;

    FCommandDiabled: array[0..15] of Cardinal;
    FCommandChecked: array[0..15] of Cardinal;

    procedure UpdateIcon(FGroup, FNum: Integer; State: Boolean);
    function UpdateIconCheck(FGroup, FNum: Integer; State: Boolean): Boolean;
    procedure DoUpdate(WPUPD_Code, Param: Integer); override;
{$IFDEF USEEXECDIA}function ExecDialog(Dia: TCommonDialog): Boolean; virtual; {$ENDIF}
    procedure OnFindClose(Sender: TObject);
    procedure OnFind(Sender: TObject);
    procedure OnReplace(Sender: TObject);
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function CalcFilterIndex(filterStr: string; FileName: string): Integer;

  public
    {:: This function (- which is known since WPTools version 2 - creates and deletes tabstops. It is
    provided for compatibility only. We recommend to use <see method="TabstopDelete"> and
    <see method="TabstopAdd">.<br>
    The first parameter is the position in twips, the second is the kind of the tabstop. Possible values are:<br>
    tkLeft - standard LEFT  (default)<br>
    tkRight - Flush-right tab.<br>
    tkCenter - Centered tab.<br>
    tkDecimal - Decimal tab.<br>
    tkBarTab - Draw bar (Unlike in Word, Fillmodes are supported, too!)<br>
    The parameter delete_it must be false, otherwise the tabstop with the given value is deleted.<br>
    Version 5 adds 2 optional parameter to specify the fillmode and the fill color. <i>The kind 'tkAll' is
    not supported anymore. To delete all tabstops use TabstopClear;</i> }
    function SetTabPos(PosInTwips: Integer;
      kind: TTabKind = tkLeft; delete_it: Boolean = False; FillMode: TTabFill = tkNoFill; FillColor: Integer = 0): Boolean;
    function CanClose: Boolean;

{$IFDEF V4COMAPT}
    function GetSelTextBuf(bug: PChar; len: Integer): Integer;
    procedure InsertParText(Index: Longint; const Buffer: Pchar; Size: Integer);
    procedure ChangeAttr(var a: TAttr; what: TWhatToChange);
    function GetParText(Index: Longint; Buffer: Pchar; Size: Integer): Integer;
{$ENDIF}

    procedure OnToolBarSelection(Sender: TObject; var Typ: TWpSelNr;
      const str: string; const num: Integer); override;
    function UpdateFontValues: TFont;
    procedure ApplyFont(x: TFont);
    procedure OnToolBarIconSelection(Sender: TObject;
      var Typ: TWpSelNr; const str: string; const group, num, index: Integer); virtual;

    function OpenDialog(DialogType: TWPCustomRtfEditDialog): Boolean; override;
    procedure SetFocusValues(Always: Boolean); override;
    procedure UpdateRulerValues; virtual;
    procedure DoUpdateParAttr; override;
    procedure DoUpdateCharAttr; override;
    procedure DoUpdateEditStateEx(selection_marked, clipboard_not_empty: Boolean; sel: TWPSelectionContents); override;
    procedure DoUpdateUndoState; override;
    function HasFocus: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure RemoveRTFData; override;
    procedure SetRTFData(ARTFData: TWPRTFDataCollection); override;
    function FontSelect: Boolean;
    function Insert(InitPath: string = ''; Filter: string = ''): Boolean;
    {:: This function uses the "word converter DLLs" through
       unit wpwordconv.pas to load a file. This converter DLLs may or may be no installed on your
       system. They can be used to convert different file types to
       RTF. }
    function LoadWithConverter(FileName: string): Boolean;
    function Load(InitPath: string = ''; Filter: string = ''): Boolean;
    function LoadEx(InitPath: string = ''; Filter: string = ''; UseConvDLLIfAvailable: Boolean = true): Boolean;
    function Save(InitPath: string = ''; Filter: string = ''): Boolean;
    function SaveAs(InitPath: string = ''; Filter: string = ''): Boolean;
    {:: This procedure shows a dialog to load a graphic. Optionally you can specify if the
    the object should be embedded or linked. You can also set some additional
    modes for the created object. The following 'OptionModes' are available:<br>
    <code> wpobjRelativeToParagraph, // place object relatively to paragraph
    wpobjRelativeToPage, // relatively to page
    wpobjPositionAtRight, // auto calc RelX to position at right (=HTML ALIGN=RIGHT)
    wpobjPositionAtCenter, // auto calc RelX to position at right (=HTML ALIGN=CENTER)
    wpobjPositionInMargin, // Position 0.2 cm from left or right border of the text, whatever margin is larger
    wpobjLockedPos, // This object cannot be moved
    wpobjSizingDisabled, // The user cannot change the width/height at all
    wpobjSizingAspectRatio // the user may only change the aspect ratio</code>}
    function InsertGraphicDialog(filter: string = ''; InsertLink: Boolean = FALSE;
      ObjectModes: TWPTextObjModes = []): TWPObject;

    function PrintDialog(PageRange: string = ''): Boolean;
    function PrinterSetup: Boolean;
    {:: Reads the page size and orientation from the current printer }
    procedure ReadPrinterProperties;
    //:: Show the Search Text dialog. You can pass the initial text or '@SELECTED@' to use the first 60 characters of the selected text
    function FindDialog(initaltext : string = ''): Boolean;  //V5.36
    //:: Show the Replace Text dialog. You can pass the initial text or '@SELECTED@' to use the first 60 characters of the selected text
    function ReplaceDialog(initaltext : string = ''): Boolean;
    //:: Displays a edit disalog to add or change a hyperlink
    function EditHyperlink(linktext: string = ''): Boolean;

     //:: Create or edit a bookmark. You can preset the name edit field
    function BookmarkEdit(initialname : string = ''): Boolean;

    {:: Delete the characters which are marked with cafsDelete. If the result value
    is true the deletion took place in at least one paragraph. }
    function DeleteMarkedChar(InAllText: Boolean = TRUE): Boolean;

    {:: This utility function applies a certain fontname and character set to all characters within a certain range of unicode characters.
        The parameter FontName can be also passed as empty string.
        The function returns the count of found characters.
     }
    function SetCharacterSet(FromChar, ToChar: Integer; FontName: string; CharSet: Integer): Integer;

    // ---------------------------------------------------------------------------------
    // Fast routines - THIS ARE DEPRECIATED METHODS, RELICTS FROM WPTOOLS 3 AND EARLIER!
    // ---------------------------------------------------------------------------------
    procedure FastResetParagraph;
    procedure FastResetAttr;
    {:: Appends a paragraph at the end }
    function FastAppendParagraph: TParagraph;
    {:: Function for old WPTools 4 projects:
        Creates a new paragraph after current. When inside a table,
        create a new cell in _after_ the current cell. }
    function FastInputParagraph: TParagraph;
    {:: Splits the current paragraph in 2 parts and moves the cursor to the second part.
    You can also use <see method="InputParagraph"> which returns the paragraph which
    was created. FastInsertParagraph always returns TRUE. (For compatibility with V4)}
    function FastInsertParagraph: Boolean;

    {:: This function creates a nested paragraph. It should be only used while the editor
    is in HTML mode. Please also see <see method="InputParagraph">. }
    function InputParagraphChild: TParagraph;
    {:: This deletes the current paragraph.
       Please also see <see class="TParagraph" method="DeleteParagraph">. }
    function FastDeleteParagraph: Boolean;
    {:: Moves a TParagraph object, NOT the cursor ! }
    function FastMoveParagraph(Dest: TParagraph; after: Boolean): Boolean;
    function FastDeleteLine: Boolean;
    procedure FastSetPageBreak(yes: Boolean; ReuseParInAppendText: Boolean = TRUE);
    procedure FastApplyPProp(par: TParagraph; const prp: TParProps;
      Options: TParPropsOptions = [
      ppoIndentFirst, ppoindentleft, ppoindentright,
        ppospacebefore, ppospaceafter, ppospacebetween,
        ppoalign, ppoborderType, ppocolor, pposhading {NO:, ppoNewPage}, ppoParID]); //new V5
    function FastGetCharAttrFromOldAttr(const Attr: TAttr): Cardinal; //new V5
    procedure FastInputText(const prp: TParProps);
    procedure FastAddText(const prp: TParProps);
    procedure FastAddTable(col: Integer; const Pprp: array of TParProps);

    overload;
    procedure FastAddTable(col: Integer; Pprp: PTParProps); overload;

    procedure FastCopyProperties(source: TObject);
    {:: This path is used for the load/save dialogs created by the WPTools
        standard actions and the toolbar. It is also used when the procedure Load or
        Save is called with an InitPath argument set to ''. }
    property InitialDir: string read FInitialDir write FInitialDir;
    {:: This format (RTF, ANSI, WPTOOLS, HTML ) will be used by the load and save dialog }
    property DefaultIOFormat: string read FDefaultIOFormat write FDefaultIOFormat;
  protected

{$IFNDEF NOTOOLBAR}
    FToolBar: TWPCustomToolCtrl;
{$ENDIF}
    FRuler: TWPRuler;
    FVRuler: TWPVertRuler;
{$IFDEF IWPGUTTER}FGutter: TWPCustomGutter; {$ENDIF}
    FActionList: TCustomActionList;
  private
    procedure SetRuler(x: TWPRuler);
    procedure SetVRuler(x: TWPVertRuler);
{$IFNDEF NOTOOLBAR}procedure SetToolBar(x: TWPCustomToolCtrl); {$ENDIF}
{$IFDEF IWPGUTTER}procedure SetGutter(x: TWPCustomGutter); {$ENDIF}
    procedure SetActionList(x: TCustomActionList);
    function GetActionList: TCustomActionList;

  public
    property CurrAttr: TWPSetModeControl read FCurrAttr;
    property WorkOnText: TWPPagePropertyKind read GetWorkOnText write SetWorkOnText;
    property HeaderFooterTextRange: TWPPagePropertyRange read GetHeaderFooterTextRange write SetHeaderFooterTextRange;
    property OnCharacterAttrChange: TWPNotifyAttrEvent read FCharacterAttrChange
      write FCharacterAttrChange;
    property OnTextNotFound: TWPOnTextNotFound read FOnTextNotFound write FOnTextNotFound;
    property AllowMultiView default FALSE;
    property Header; //1.
    property RTFText; // 2.
    property RTFVariables;
{$IFNDEF NOTOOLBAR}property WPToolBar: TWPCustomToolCtrl read FToolBar write SetToolBar; {$ENDIF}
    property WPRuler: TWPRuler read FRuler write SetRuler;
    property VRuler: TWPVertRuler read FVRuler write SetVRuler;
{$IFDEF IWPGUTTER}property WPGutter: TWPCustomGutter read FGutter write SetGutter; {$ENDIF}
    property ActionList: TCustomActionList read GetActionList write SetActionList;
  end;

{:: Interface to the 'current' character and paragraph attributes.
    You can use the provided properties to modify character and paragraph attributes.<br>
    @depreciated This interface is provided for compatibility to WPTools Version 4 and earlier.
    This property hides one of the best features of WPTools 5: all properties have a null state
    but its source (unit WPCtrRich.PAS) is a good example how the properties of the text can
    be retrieved and changed. The interface is easy to use and will so be supported in future version
    of WPTools, too. It will not be supported in a pure OCX or .NET version of WPTools though.<br>
    Please note that the class TWPSetModeControl only works as a interface to the text
    manahed by the "RTF-Engine". It cannot be used to store properties. Please use the property
    WPCSS to get a string with property definitions if you need to store and transfer properties.
    <br>
    <b>Upgrade notes:</b>
    The properties "Tabs" and "BorderProp" are not anymore defined.<br>
    The property MultSpaceBetween is not used anymore. In WPTools 5 a paragraph can have
    either a LineHeight defined in % or the SpaceBetween value as a positive (=minimum) or negative (=exact) twips value.
    <br>Size is now a floating point value (type: single)
     }

  TWPSetModeControl = class(TPersistent)
  private

    // The hosting TWPRichText
    FRichText: TWPCustomRtfEdit;
    // Shortcut to the cursor of the text. It is initialized the first time
    // the interface is used
FCursor: TWPRTFDataCursor;

  protected

    function GetCursor: TWPRTFDataCursor;
    function GetRTFProps: TWPRTFProps;
    function GetAlign: TParAlign;
    procedure SetAlign(x: TParAlign);
    function GetVertAlign: TParVertAlign;
    procedure SetVertAlign(x: TParVertAlign);
    function GetOutlineLevel: Integer;
    procedure SetOutlineLevel(x: Integer);
    function GetOutlineStyle: TWPNumberStyle;
    procedure SetOutlineStyle(x: TWPNumberStyle);
    function GetCurrNumberStyle: Integer;
    procedure SetCurrNumberStyle(x: Integer);
    function GetCurrNumberStart: Integer;
    procedure SetCurrNumberStart(x: Integer);
    function GetOutlineMode: Boolean;
    procedure SetOutlineMode(x: Boolean);
    function GetOutlineStyles(index: Integer): TWPRTFNumberingStyle;
    function GetNumberStyleEx: TWPRTFNumberingStyle;
    procedure SetNumberStyleEx(x: TWPRTFNumberingStyle);
    // function GetBorderProp: PTBorder;
    // procedure SetBorderProp(x: PTBorder);
    function GetStyle: WrtStyle;
    procedure SetStyle(x: WrtStyle);
    function GetUnderlineMode: Integer;
    procedure SetUnderlineMode(x: Integer);
    function GetColor: Integer;
    procedure SetColor(x: Integer);
    function GetBKColor: Integer;
    procedure SetBKColor(x: Integer);
    function GetFontName: TFontName;
    procedure SetFontName(x: TFontName);
    function GetCharSet: Integer;
    procedure SetCharSet(x: Integer);
    function GetFontNr: Integer;
    procedure SetFontNr(x: Integer);
    function GetSize: Single;
    procedure SetSize(x: Single);
    function GetParColor: Integer;
    procedure SetParColor(x: Integer);
    function GetParShading: Integer;
    procedure SetParShading(x: Integer);
    function GetIndentFirst: Longint;
    function GetIndentRight: Longint;
    function GetIndentLeft: Longint;
    procedure SetIndentFirst(x: Longint);
    procedure SetIndentRight(x: Longint);
    procedure SetIndentLeft(x: Longint);
    function GetSpaceBefore: Longint;
    function GetSpaceBetween: Longint;
    function GetLineheight: Longint;
    function GetParId: Integer;
    procedure SetParId(x: Integer);
    // function GetMultSpaceBetween: Boolean;
    function GetSpaceAfter: Longint;
    procedure SetSpaceBefore(x: Longint);
    procedure SetSpaceBetween(x: Longint);
    procedure SetLineHeight(x: Longint);
    // procedure SetMultSpaceBetween(x: Boolean);
    procedure SetSpaceAfter(x: Longint);
    // procedure UpdateBorderArray;
    function GetLineVisible(index: TWPBrdLine): Boolean;
    procedure SetLineVisible(index: TWPBrdLine; x: Boolean);
    function GetLineColor(index: TWPBrdLine): Integer;
    procedure SetLineColor(index: TWPBrdLine; x: Integer);
    function GetLineWidth(index: TWPBrdLine): Integer;
    procedure SetLineWidth(index: TWPBrdLine; x: Integer);
    // function GetLineStyle: TBorderType;
    // procedure SetLineStyle(x: TBorderType);
    { support of tabstops	}
    // procedure UpdateTabArray;
    function GetTabPosition(index: integer): Longint;
    function GetTabKind(index: integer): TTabKind;
    function GetTabFill(index: integer): TTabFill;
    function GetTabCount: Integer;
    function GetStyleName: string;
    procedure SetStyleName(const x: string);
    { Calculation in Tables }
    procedure SetCellName(const x: string);
    procedure SetCellCommand(const x: string);
    procedure SetCellFormat(x: Integer);
    function GetCellName: string;
    function GetCellCommand: string;
    function GetCellFormat: Integer;
    procedure SetTableName(const x: string);
    function GetTableName: string;
    { Special Paragraph properties }
    procedure SetParProtect(x: Boolean);
    function GetParProtect: Boolean;
    procedure SetParKeep(x: Boolean);
    function GetParKeep: Boolean;
    procedure SetParKeepNext(x: Boolean);
    function GetParKeepNext: Boolean;
    procedure SetOutlineBreak(x: Boolean);
    function GetOutlineBreak: Boolean;
    // procedure ApplyChanges;
    // procedure CharUpdate(Sender: TObject);
    // procedure ParagraphUpdate(Sender: TObject);
    //procedure QuickUpdate(par: PTParagraph; pa: PTAttr);

  public
    // property Tabs: TTabFlag read GetTabs write SetTabs;
    procedure Assign(Source: TPersistent); override;
    procedure AddTab(pos: Longint; Kind: TTabKind = tkLeft;
      Fill: TTabFill = tkNoFill; ColorNr: Integer = 0);
    procedure ClearAllTabs;
    {:: This function clears the paragraph and character attributes of all
    paragraphs in the text which use the provided style. If the StyleNr=-1 all
    paragraphs are changed }
    procedure ClearAttributes(StyleNr: Integer = -1);
    procedure DeleteTab(pos: Longint);
    procedure SetTableLeftRight(tbLeft, tbRight: Longint);
    function GetTableLeftRight(var tbLeft, tbRight: Longint): Boolean;
    {:: see TWPRichText.Table }
    function CurrentTable: TParagraph;
    function NrToColor(x: Integer): TColor;
    function ColorToNr(x: TColor; add: Boolean = true): Integer;
    procedure IncSize(n: Single);
    procedure DecSize(n: Single);
    procedure SetCellBorders(left, top, right, bottom, inner: TThreeState);
    {:: This procedure can be used instead of Memo.Set_ParBorder(LineType: TBorderType;
          Thick: Integer;
          LColor, RColor, TColor, BColor, Space: Integer); }
    procedure SetBorders(
      LineSelection: TBorderType = [blEnabled, blLeft, blTop, blRight, blBottom];
      WPBRD_mode: Integer = -1;
      ThicknessTW: Integer = -1;
      LeftColor: Integer = -1;
      RightColor: Integer = -1;
      TopColor: Integer = -1;
      BottomColor: Integer = -1;
      AllPadding: Integer = -1;
      DeleteDefaultSettings: Boolean = TRUE);
    {:: This are the current tab stops as a sorted array.
    Use TabstopCount to get the count of tabstops. We recommend to rather use
    WPRichText1.TextCursor.CurrAttribute.TabstopCount, TabstopGet etc to
    get the tabstop information. }
    property TabPosition[index: integer]: Longint read GetTabPosition;
    property TabKind[index: integer]: TTabKind read GetTabKind;
    property TabFill[index: integer]: TTabFill read GetTabFill;
    property TabCount: integer read GetTabCount;
    property LineVisible[index: TWPBrdLine]: Boolean read GetLineVisible write SetLineVisible;
    property LineColor[index: TWPBrdLine]: Integer read GetLineColor write SetLineColor;
    property LineWidth[index: TWPBrdLine]: Integer read GetLineWidth write SetLineWidth;
    // property LineStyle: TBorderType read GetLineStyle write SetLineStyle;
    // property BorderProp: PTBorder read GetBorderProp write SetBorderProp;
  public
    property Cursor: TWPRTFDataCursor read GetCursor;
    property RTFProps: TWPRTFProps read GetRTFProps;
    property Style: WrtStyle read GetStyle write SetStyle;
    property UnderlineMode: Integer read GetUnderlineMode write SetUnderlineMode;
    property Alignment: TParAlign read GetAlign write SetAlign;
    property VertAlignment: TParVertAlign read GetVertAlign write SetVertAlign;
 {:: This is the text color. Like all color properties this is an index. You need to use <see method="ColorToNr"> to convert a
   regular color value into a color index. }
    property Color: Integer read GetColor write SetColor;
 {:: This is the text background color. Like all color properties this is an index. You need to use <see method="ColorToNr"> to convert a
   regular color value into a color index. }
    property BKColor: Integer read GetBKColor write SetBKColor;
    property FontName: TFontName read GetFontName write SetFontName;
    property CharSet: Integer read GetCharSet write SetCharSet;
    property FontNr: Integer read GetFontNr write SetFontNr;
    property OutlineLevel: Integer read GetOutlineLevel write SetOutlineLevel;
    property OutlineStyle: TWPNumberStyle read GetOutlineStyle write SetOutlineStyle;
    property NumberStyle: Integer read GetCurrNumberStyle write SetCurrNumberStyle;
    property NumberStart: Integer read GetCurrNumberStart write SetCurrNumberStart;
    property ExNumberStyle: TWPRTFNumberingStyle read GetNumberStyleEx write setNumberStyleEx;
    {:: This property will set a flag to create \oulinelevel tags  }
    property OutlineMode: Boolean read GetOutlineMode write SetOutlineMode;
    property Size: Single read GetSize write SetSize;
    property ParColor: Integer read GetParColor write SetParColor;
    property ParShading: Integer read GetParShading write SetParShading;
    property IndentLeft: Longint read GetIndentLeft write SetIndentLeft;
    property IndentRight: Longint read GetIndentRight write SetIndentRight;
    property IndentFirst: Longint read GetIndentFirst write SetIndentFirst;
    property SpaceBefore: Longint read GetSpaceBefore write SetSpaceBefore;
    property SpaceAfter: Longint read GetSpaceAfter write SetSpaceAfter;
    property SpaceBetween: Longint read GetSpaceBetween write SetSpaceBetween;
    property LineHeight: Longint read GetLineHeight write SetLineHeight;
    // property MultSpaceBetween .., removed
    property ParId: Integer read GetParId write SetParId;
    property StyleName: string read GetStyleName write SetStyleName;
    { -- Calculation in Tables requires WPReporter !!! -------------- }
    property CellName: string read GetCellName write SetCellName;
    property CellCommand: string read GetCellCommand write SetCellCommand;
    property CellFormat: Integer read GetCellFormat write SetCellFormat;
    property TableName: string read GetTableName write SetTableName;
    { -- Special Paragraph Properties ------------------------------- }
    property ParProtect: Boolean read GetParProtect write SetParProtect;
    property ParKeep: Boolean read GetParKeep write SetParKeep;
    property ParKeepNext: Boolean read GetParKeepNext write SetParKeepNext;
    // New number
    property OutlineBreak: Boolean read GetOutlineBreak write SetOutlineBreak;
  public
    constructor Create(aOwner: TWPCustomRtfEdit);
    destructor Destroy; override;
    function AGet(WPAT_Code: Byte; var Value: Integer): Boolean;
    function AGetDefault(WPAT_Code: Byte; Value: Integer = 0): Integer;
    procedure ADel(WPAT_Code: Byte);
    procedure ASet(WPAT_Code: Byte; Value: Integer);
    procedure BeginUpdate;
    function EndUpdate: Boolean;
    //:: This procedure clears the attributes of the selected text
    procedure ClearAttr(ParAttr, CharAttr: Boolean);
    procedure AddStyle(x: WrtStyle);
    {:: This function can be used to check for the colors with the ids
      WPAT_CharColor, WPAT_ParColor, WPAT_CharBgColor. The result value is
      -1 if the color is not assigned }
    function GetColorEx(WPAT_Code: Integer): Integer;
    procedure DeleteStyle(x: WrtStyle);
    //:: depending on parameter AddStyle "AddStyle" or "DeleteStyle" is executed
    procedure TextStyle(x: WrtStyle; AddStyle: Boolean);
    procedure SetFontStyle(x: TFontStyles);
    procedure IncOutlineLevel;
    procedure DecOutlineLevel;
    procedure IncIndent;
    procedure DecIndent;
    procedure AutoIndentFirst(defaultvalue: Integer = 0);
    procedure HidePar(Status: Boolean);
    procedure SetNoWordWrapInPar(Status: Boolean);
    function SetNumberStyle(const TextB, TextA, BulletFont: string;
      Style: TWPNumberStyle; indent: Integer): Integer;
    function AddNumberStyle(
      const Style: TWPNumberStyle;
      const TextB, TextA: string;
      const BulletFont: string;
      const Indent: Integer): Integer;
    function GetNumberStyle(nr: Integer): TWPRTFNumberingStyle;
    {:: Change the current font and charset }
    procedure SetFontCharset(const fontname: string; charset: Integer);
    property OutlineStyles[index: Integer]: TWPRTFNumberingStyle read
    GetOutlineStyles;
  end;

  TWPRichText = class(TWPCustomRichText)
  published
    property AllowMultiView;
    property RTFText;
    property Header;
    property RTFVariables;
    property PrintParameter;
    property SpellCheckStrategie;
    property SpellIgnoredForObj;
    property Readonly;
{$IFNDEF NOTOOLBAR}property WPToolBar; {$ENDIF}
    property WPRuler;
    property VRuler;
    property GraphicPopupMenu;
{$IFDEF IWPGUTTER}property WPGutter; {$ENDIF}
    property ActionList;
    property OnInitializeRTFDataObject;
    property OnInitializedRTFData;
    property OnPrepareParForPaint;
    property AfterImageSaving;
    property OnLeaveRTFDataBlock; //V5.20.7 TWPLeaveRTFDataBlockEvent;
    property BeforeObjectSelection;
    property AfterObjectSelection;
    property OnTestForLinkEvent;
    property OnChange;
    property OnChangeLastFileName;
    property OnResize;
    property OnPaintPageHint;
    property OnCharacterAttrChange;
    property OnTextNotFound;
   { property BorderStyle;
    property ColorDesktop;
    property MaxLength;
    property DragAndDropSupport;

    property OnWorkOnTextChanged;  }
    property OnChangeZooming;
    property OnQueryDrag;
    //NOT POSSIBLE: property HeaderFooter;
    property DefaultIOFormat;
    property XOffset;
    property YOffset;
    property XBetween;
    property YBetween;
    property AutoZoom;
    property Zooming;
    property Resizing;
    property PageColumns;
    property LayoutMode;
    property PaperColor;
    property ColorDesktop;
    property ScrollBars;
    property WantTabs;
    property WantReturns;
    property EditOptions;
    property EditOptionsEx;
    property ViewOptions;
    property ClipboardOptions;
    property FormatOptions;
    property FormatOptionsEx;
    property EditBoxModes;
    property WordWrap;
    property AcceptFiles;
    property AcceptFilesOptions;

    property ProtectedProp;
    property OnCheckProtection;
    property OnEditFieldGetSize;
    property OnEditFieldFocus;

    property BorderStyle;
    property Transparent;

    property HyperLinkCursor;
    property TextObjectCursor;

    property InsertPointAttr;
    property HyperlinkTextAttr;
    property BookmarkTextAttr;
    property SPANObjectTextAttr;
    property HiddenTextAttr;
    property AutomaticTextAttr;
    property ProtectedTextAttr;
    property FieldObjectTextAttr;
    property WriteObjectMode;

    property OnRequestStyle;
    property OnRequestHTTPString;
    property OnRequestHTTPImage;
    property OnPrepareImageforSaving;
    property OnGetPageGapText;

    property OnClickHotText;
    property ClickableCodes;
    property OneClickHyperlink;
    property HyperLinkEvent;
    property OnCustomLinePaintBefore;
    property OnCustomLinePaintAfter;
    property BeforeInitializePar;
    property OnDropFile;
    property OnClickCreateHeaderFooter;

    property OnClick;

    property OnDblClick;

    property OnUpdateExternScrollbar;
    property OnEditBoxChangeHeight;
    property OnSetupPrinterEvent;
    property OnEditBoxChangeWidth;

    property OnChangeViewMode;

    property OnChangeSelection;
    property OnUndoStateChanged;
    property OnEditStateChanged;
    property OnMailMergeGetText;

    property OnNewRTFDataBlock;
    property OnClear;
    property AfterLoadText;
    property OnOpenDialog;
    property BeforePasteText;
    property BeforePasteImage;
    property BeforeDropText;
    property BeforeOverwriteFile;
    property BeforeCopyText;
    property BeforeCutText;
    property AfterCopyToClipboard;

    property OnTextObjectMouseMove;
    property OnTextObjectMouseDown;
    property OnTextObjectMouseUp;
    property OnTextObjectClick;
    property OnTextObjectDblClick;
    property OnTextObjectPaint;
    property OnTextObjectMove;

    property OnDelayedUpdate;
    property AfterDelayedUpdate;

    property OnGetAttributeColor; // was: OnGetAttrColor

    property OnTextObjGetTextEx;

    property BeforeEditBoxNeedFocus;

    property OnWorkOnTextChanged;

    property OnChangeCursorPos;

    property OnMeasureTextPage;

    property BeforeDestroyPaintPage;

    property OnPaintWatermark;

    property OnPaintExternPage;

    property OnMouseDownWord;

    property AfterCompleteWordEvent;

    property OnActivatingHotStyle;
    property OnActivateHint;
    property OnClickText;
    property OnCalcPageNr;
    property OnDeactivateHotStyle;

    property OnGetSpecialText;
    // -------------------------------------------
    // The following properties require WPTools 6
    {$IFDEF WP6}
    property ShowMergeFieldNames default false;
    //not published:  property CustomSyntax;
    property Font;
    property SecurityOptions default [];
    property TextSaveFormatClipboard;
    property TextLoadFormatClipboard;
    property HideTableBorders default wpDontHide;
    {$ENDIF}
    // -------------------------------------------
 // ------------ Standard Properties ----------------------------
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
    property OnStartDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property Anchors;
    property Constraints;

  end;

 // The TWPCustomToolCtrl is internally used as interface to attached tool panels
 // which inherit of this class.

  TWPCustomToolCtrl = class(TCustomControl)

  protected
    FNextWPTCtrl: TWPCustomToolCtrl;
    FRtfEdit: TWPCustomRichText;
    FRTFEditChanged: TNotifyRTFEditChangedEvent;
    FAutoEnabling: Boolean;
    procedure SetRTFedit(x: TWPCustomRichText); virtual;
    function GetRTFProps: TWPRTFProps;
    procedure UpdateSel; virtual;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    FDefaultPalette: array[0..15] of TColor;
    procedure OnColorDropDown(Sender: TObject);
    function SelectIcon(index, group, num: Integer): Boolean; virtual; abstract;
    procedure UpdateEnabledState; virtual;
    procedure SetPreviewButtons; virtual;
    function DeselectIcon(index, group, num: Integer): Boolean; virtual;
      abstract;
    function EnableIcon(index, group, num: Integer; enabled: Boolean): Boolean;
      virtual; abstract;
    procedure UpdateSelection(Typ: TWpSelNr; const str: string; num: Integer);
      virtual; abstract;
    procedure PerformAll(m: Cardinal; w, l: Longint); virtual; abstract;
    property RtfEdit: TWPCustomRichText read FRtfEdit write SetRtfEdit;
    property NextToolBar: TWPCustomToolCtrl read FNextWPTCtrl write
      FNextWPTCtrl;
    property RTFProps: TWPRTFProps read GetRTFProps;
    property AutoEnabling: Boolean read FAutoEnabling write FAutoEnabling;
  published
    property RTFEditChanged: TNotifyRTFEditChangedEvent read FRTFEditChanged
      write FRTFEditChanged;

  end;

  TWPBasicRulerType = class(TCustomPanel)
  protected

    FRtfEdit: TWPCustomRichText;
    FTextAreaLeft, FTextAreaWidth: Integer;
    FIndentAreaLeft, FIndentAreaWidth, FLineY: Integer;
    FTextAreaTop, FLineX: Integer;
    FTopOffset: Integer;
    procedure SetRtfEdit(x: TWPCustomRichText); virtual; abstract;
    procedure SetResolution(x: Integer); virtual; abstract;
    procedure SetIndent(IFirst, ILeft, IRight, TableTag: Integer); virtual;
      abstract;
    procedure SetMargin(mLeft, mRight, mTop, mBottom: Integer); virtual;
      abstract;
    procedure SetOffset(PageOffset, TextOffset: Integer); virtual; abstract;
    procedure UpdateIntervall; virtual; abstract;
    procedure SetVPageStart(y, h: Integer); virtual; abstract;
    procedure DisableMargins(disable: Boolean); virtual; abstract;

  end;

  TWPToolsBasicCustomAction = class(TCustomAction)
  protected

    FControl: TWPCustomRichText;
    FGroup, FNr: Integer;
    FShortCutSave: TShortCut;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure SetRTFEdit(edit: TWPCustomRichText); virtual; abstract;
  public
    procedure Loaded; override;
    procedure UpdateCaption; virtual; abstract;
    function Update: Boolean; override;

  end;

const // Command numbers and groups used by the proced OnToolBarIconSelection
  WPI_IDX_INTERN = 0;
  WPI_GR_USER0 = $0000;

  WPI_GR_STYLE = $0100; { allow all up }
  WPI_GR_ALIGN = $0200; { radion button }
  WPI_GR_EDIT = $0300; { copy,  paste ... }
  WPI_GR_DISK = $0400; { new,open,save  ... }
  WPI_GR_PRINT = $0500; { print, print setup }
  WPI_GR_DATA = $0600; { prev,  next ... }
  WPI_GR_PARAGRAPH = $0700;
  WPI_GR_TABLE = $0800; { table tools }
  WPI_GR_OUTLINE = $0900; { Outline tools       }
  WPI_GR_EXTRA = $0A00; // Extra, like InsertNumber etc
  WPI_GR_DROPDOWN = $0B00; { Comboboxes }
  WPI_GR_USER1 = $0C00; { User definied group 2 }
  WPI_GR_USER2 = $0D00; { User definied group 3 }
  WPI_GR_USER3 = $0E00; { User definied group 4 }
  //  Group: WPI_GR_STYLE ------------------------------------------------------
  WPI_CO_Normal = 1;
  WPI_CO_Bold = 2;
  WPI_CO_Italic = 3;
  WPI_CO_Under = 4;
  WPI_CO_Hyperlink = 5;
  WPI_CO_StrikeOut = 6;
  WPI_CO_SUPER = 7;
  WPI_CO_SUB = 8;
  WPI_CO_HIDDEN = 9;
  WPI_CO_RTFCODE = 10;
  WPI_CO_PROTECTED = 11;
  WPI_CO_UPPERCASE = 12; // afsUpperCaseStyle
  WPI_CO_SMALLCAPS = 13; // afsSmallCaps
  //  Group: WPI_GR_ALIGN ------------------------------------------------------
  WPI_CO_Left = 1;
  WPI_CO_Right = 2;
  WPI_CO_Justified = 3;
  WPI_CO_Center = 4;
  //  Group: WPI_GR_EDIT ------------------------------------------------------
  WPI_CO_Copy = 1;
  WPI_CO_Cut = 2;
  WPI_CO_Paste = 3;
  WPI_CO_SelAll = 4;
  WPI_CO_HideSel = 5;
  WPI_CO_Find = 6;
  WPI_CO_Replace = 7;
  WPI_CO_SpellCheck = 8;
  WPI_CO_Undo = 9;
  WPI_CO_FindNext = 10;
  WPI_CO_DeleteText = 11;
  WPI_CO_Redo = 12;
  WPI_CO_SpellAsYouGo = 13;
  WPI_CO_Thesaurus = 14;
  WPI_CO_SpellCheckSetup = 15;
  //  Group: WPI_GR_DISK ------------------------------------------------------
  WPI_CO_Exit = 1;
  WPI_CO_New = 2;
  WPI_CO_Open = 3;
  WPI_CO_Save = 4;
  WPI_CO_Close = 5;
  //  Group: WPI_PRINT ------------------------------------------------------
  WPI_CO_Print = 1;
  WPI_CO_PrintSetup = 2;
  WPI_CO_FitWidth = 3; { AutoZoomWidth }
  WPI_CO_FitHeight = 4; { AutoZoomHeight }
  WPI_CO_ZoomIn = 5;
  WPI_CO_ZoomOut = 6;
  WPI_CO_NextPage = 7;
  WPI_CO_PriorPage = 8;
  WPI_CO_PrintDialog = 9;
  //  Group: WPI_DATA ------------------------------------------------------
  WPI_CO_Next = 1;
  WPI_CO_Prev = 2;
  WPI_CO_Add = 3;
  WPI_CO_Del = 4;
  WPI_CO_Edit = 5;
  WPI_CO_Cancel = 6;
  WPI_CO_ToStart = 7;
  WPI_CO_ToEnd = 8;
  WPI_CO_Post = 9;
  //  Group: WPI_GR_PARAGRAPH --------------------------------------------------
  WPI_CO_PARPROTECT = 1;
  WPI_CO_PARKEEP = 2;
  //  Group: WPI_TABLE ---------------------------------------------------------
  WPI_CO_CreateTable = 1;
  WPI_CO_BAllOff = 2;
  WPI_CO_BLeft = 3;
  WPI_CO_BTop = 4;
  WPI_CO_BBottom = 5;
  WPI_CO_BRight = 6;
  WPI_CO_SelRow = 7;
  WPI_CO_InsRow = 8;
  WPI_CO_DelRow = 9;
  WPI_CO_DelCol = 10;
  WPI_CO_InsCol = 11;
  WPI_CO_SelCol = 12;
  WPI_CO_SplitCell = 13;
  WPI_CO_CombineCell = 14;
  WPI_CO_BAllOn = 15;
  WPI_CO_BInner = 16;
  WPI_CO_BOuter = 17;
  //  Group: WPI_GR_OUTLINE ----------------------------------------------------
  WPI_CO_Bullets = 1;
  WPI_CO_Numbers = 2;
  WPI_CO_NextLevel = 3; // Only for numbers
  WPI_CO_PriorLevel = 4;
  WPI_CO_IsOutline = 5; // Include in TOC
  WPI_CO_OutlineUp = 6; // Outline Level
  WPI_CO_OutlineDown = 7;
  WPI_CO_InsertNumber = 1; { Group: WPI_GR_EXTRA}
  WPI_CO_InsertField = 2;
  WPI_CO_EditHyperlink = 3;

function ActiveRTFEdit(p: TWPCustomRtfEdit): TWPCustomRtfEdit;
function AssignedActiveRTFEdit(p: TWPCustomRtfEdit): Boolean;

var
  FFindDialog: TFindDialog;
  FReplaceDialog: TReplaceDialog;

//************************************************************************
//********* SOME CONSTANTS FOR BETTER COMPATIBILITY TO WPTOOLS 4 *********
//************************************************************************
const wpcoBookMark = wpobjBookmark; // For OpenCodesAtCP(
  wpcoReference = wpobjReference;
  wpHeader = wpIsHeader; // For 'WorkOnText'
  wpBody = wpIsBody;
  wpFooter = wpIsFooter;
  ppAutomatic = ppIsMergedText; // Used by protectedProp
  KeepOldValue = -1000;

var // Displays dialog, too. Assigned in unit WPWordConv
  WPLoadWithConverter: function(Source: TWPCustomRichText; Insert, Dialog: Boolean; const FileName: string): Boolean;
  WPSaveWithConverter: function(Source: TWPCustomRichText; Selection, Dialog: Boolean; const FileName: string): Boolean;


implementation

uses WPPrTab1, Math;

function ActiveRTFEdit(p: TWPCustomRtfEdit): TWPCustomRtfEdit;
begin
  if assigned(p) then
    Result := p
  else
    Result := WPLastActiveRTFEdit;
end;

function AssignedActiveRTFEdit(p: TWPCustomRtfEdit): Boolean;
begin
  Result := assigned(p) or assigned(WPLastActiveRTFEdit);
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPCustomRichText
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
{$IFNDEF NOTOOLBAR}

procedure TWPCustomRichText.SetToolBar(x: TWPCustomToolCtrl);
begin
  FToolBar := x;
  if Assigned(FToolBar) then
  begin
    FToolBar.FreeNotification(Self);
    FToolBar.RtfEdit := Self;
  end;
end;
{$ENDIF}

procedure TWPCustomRichText.SetRuler(x: TWPRuler);
begin
  FRuler := x;
  if ComponentState = [csDestroying] then exit;
  if Assigned(FRuler) then
  begin
    FRuler.FreeNotification(Self);
  end;
end;

procedure TWPCustomRichText.SetActionList(x: TCustomActionList);
var
  i: Integer;
begin
  // Un-link the actions
  if assigned(FActionList) and (x <> FActionList) then
  try
    for i := 0 to FActionList.ActionCount - 1 do
    begin
      if FActionList.Actions[i] is TWPToolsBasicCustomAction then
        TWPToolsBasicCustomAction(FActionList.Actions[i]).FControl := nil;
    end;
  except
  end;
  // link the actions
  FActionList := x;
  if FActionList <> nil then
  begin
    FActionList.FreeNotification(Self);
    for i := 0 to FActionList.ActionCount - 1 do
    begin
      if FActionList.Actions[i] is
        TWPToolsBasicCustomAction then
      begin
        TWPToolsBasicCustomAction(FActionList.Actions[i]).UpdateCaption;
      end;
    end;
  end;
end;

function TWPCustomRichText.GetActionList: TCustomActionList;
begin
  Result := FActionList;
end;

function TWPCustomRichText.GetWorkOnText: TWPPagePropertyKind;
begin
  if not Memo.HasData or
    (Memo.Cursor.RTFData = nil) then
    Result := wpIsDeleted // = undefined
  else Result := Memo.Cursor.RTFData.Kind;
end;

procedure TWPCustomRichText.SetWorkOnText(x: TWPPagePropertyKind);
begin
  if Memo.HasData then
  begin
    if x = wpIsBody then
      Memo.Cursor.RTFData := Memo.Body
    else
      Memo.Cursor.RTFData := Memo.RTFData.Get(x, FHeaderFooterTextRange, '');
    if LayoutMode in [wplayNormal, wpWordWrapView, wplayShowManualPageBreaks, // Like wplayNormal but show a dashed line for page breakes
      wplayPageGap, wplayExtendedPageGap, wplayShrunkenLayout] then
      Memo.DisplayedText := Memo.Cursor.RTFData;
  end;
end;

function TWPCustomRichText.GetHeaderFooterTextRange: TWPPagePropertyRange;
begin
  if not Memo.HasData or
    (Memo.Cursor.RTFData = nil) then
    Result := wpraIgnored // = undefined
  else Result := Memo.Cursor.RTFData.Range;
end;

procedure TWPCustomRichText.SetHeaderFooterTextRange(x: TWPPagePropertyRange);
begin
  FHeaderFooterTextRange := x;
  if GetWorkOnText <> wpIsDeleted then SetWorkOnText(GetWorkOnText);
end;

procedure TWPCustomRichText.DoUpdate(WPUPD_Code, Param: Integer);
begin
  inherited DoUpdate(WPUPD_Code, Param);
  if not PendingUpdate(WPUPD_REFORMAT)
    and (ActiveText <> nil) and
    (DisplayedText <> nil) and
    (DisplayedText.PageCount > 0)
    then
  begin
    if WPUPD_Code = WPUPD_UPDATERULER then
    begin
      UpdateRulerValues;
    end
    else if WPUPD_Code = WPUPD_UPDATERULER_CP then
    begin
      UpdateRulerValues;
    end;
  end;
end;

procedure TWPCustomRichText.UpdateRulerValues;
var
  x, y, w, h: Integer;
begin
  if (ActiveText = nil) or
    (DisplayedText = nil) or
    (DisplayedText.PageCount = 0) then exit;

{$IFDEF IWPGUTTER}
  if Assigned(FGutter) and not (csDestroying in FGutter.ComponentState) then
  begin
    FGutter.FEditBox := Self;
    FGutter.Invalidate;
    if not FWM_WPTOOLSUPDATEFlags[WPUPD_REFORMAT] then //V5.24.3   (Himmer)
      FGutter.Update;
  end; {$ENDIF}

  if (FRuler <> nil) or (FVRuler <> nil) then
    with Memo.Cursor do
      if active_paragraph <> nil then
      begin
        Memo.GetTextPageScreenRect(
          ActiveParagraph,
          ActivePosInPar,
          X, Y, W, H);
        if FRuler <> nil then
        begin
          FRuler.Zoom := Memo.CurrentZooming;
          FRuler.Offset := x + Left;

          if LayoutMode in [wplayNormal, wpWordWrapView,
            wplayShowManualPageBreaks, wplayPageGap] then
            FRuler.Margins := []
          else FRuler.Margins := [wpStartMargin, wpEndMargin];

          FRuler.UpdateFrom(Memo.RTFData, Self, nil);

        end;
        if FVRuler <> nil then
        begin
          FVRuler.Zoom := Memo.CurrentZooming;
          FVRuler.Offset := y;

          if LayoutMode in [wplayNormal, wpWordWrapView, wplayShrunkenLayout, wplayExtendedPageGap,
            wplayShowManualPageBreaks, wplayPageGap] then
            FVRuler.Margins := []
          else FVRuler.Margins := [wpStartMargin, wpEndMargin];

          FVRuler.UpdateFrom(Memo.RTFData, Self, nil);
        end;
      end else
      begin
        if FRuler <> nil then
          FRuler.UpdateFrom(Memo.RTFData, nil, nil);
        if FVRuler <> nil then
          FVRuler.UpdateFrom(Memo.RTFData, nil, nil);

      end;
end;

procedure TWPCustomRichText.UpdateIcon(FGroup, FNum: Integer; State: Boolean);
var
  i: Integer;
begin
  i := FGroup shr 8;
  (* IF RTFText.FReadOnly THEN
   BEGIN
     state := FALSE;
     for j:=0 to 15 do
        FCommandDiabled[j] := TabsAllWord;
     if assigned(FToolBar) then
     begin
        FToolBar.EnableIcon(0, WPI_GR_STYLE, 0, state);
        FToolBar.EnableIcon(0, WPI_GR_ALIGN, 0, state);
        FToolBar.EnableIcon(0, WPI_GR_EDIT, 0, state);
        FToolBar.EnableIcon(0, WPI_GR_PARAGRAPH, 0, state);
        FToolBar.EnableIcon(0, WPI_GR_TABLE, 0, state);
        FToolBar.EnableIcon(0, WPI_GR_OUTLINE, 0, state);
     end;
   END else *)
  begin
    if FNum <= 0 then
    begin
      if state then
        FCommandDiabled[i] := 0
      else
        FCommandDiabled[i] := $FFFFFFF;
    end
    else
    begin
      if not state then
        FCommandDiabled[i] := FCommandDiabled[i] or BitMaskL[FNum]
      else if (FCommandDiabled[i] and BitMaskL[FNum] <> 0) then
        FCommandDiabled[i] := FCommandDiabled[i] - BitMaskL[FNum];
    end;
{$IFNDEF NOTOOLBAR}if assigned(FToolBar) then
      FToolBar.EnableIcon(0, FGroup, Fnum, state); {$ENDIF}
  end;
end;

function TWPCustomRichText.UpdateIconCheck(FGroup, FNum: Integer; State:
  Boolean): Boolean;
var
  i: Integer;
begin
  i := FGroup shr 8;
{$IFNDEF NOTOOLBAR}
  if assigned(FToolBar) then
  begin
    if state then
      FToolBar.SelectIcon(0, FGroup, Fnum)
    else
      FToolBar.DeSelectIcon(0, FGroup, Fnum);
  end;
{$ENDIF}
  if state then
    FCommandChecked[i] := FCommandChecked[i] or BitMaskL[FNum]
  else if (FCommandChecked[i] and BitMaskL[FNum] <> 0) then
    FCommandChecked[i] := FCommandChecked[i] - BitMaskL[FNum];
  Result := State;
end;

procedure TWPCustomRichText.DoUpdateEditStateEx(selection_marked, clipboard_not_empty: Boolean; sel: TWPSelectionContents);
begin
  inherited DoUpdateEditStateEx(selection_marked, clipboard_not_empty, sel);
  try
    if {$IFNDEF NOTOOLBAR}(WPToolBar <> nil) or {$ENDIF}(ActionList <> nil) then
    begin
      UpdateIcon(WPI_GR_EDIT, WPI_CO_PASTE, clipboard_not_empty);
      UpdateIcon(WPI_GR_EDIT, WPI_CO_CUT, selection_marked);
      UpdateIcon(WPI_GR_EDIT, WPI_CO_DELETETEXT, selection_marked);
      UpdateIcon(WPI_GR_EDIT, WPI_CO_HIDESEL, selection_marked);
      UpdateIcon(WPI_GR_EDIT, WPI_CO_COPY, selection_marked);
      UpdateIconCheck(WPI_GR_EDIT, WPI_CO_SELALL, wpSelAllText in sel);
    end;
  except
    // Clipboard execpetion
  end;
end;

procedure TWPCustomRichText.DoUpdateUndoState;
begin
  inherited DoUpdateUndoState;
{$IFDEF ALLOWUNDO}
  UpdateIcon(WPI_GR_EDIT, WPI_CO_UNDO, Memo.RTFData.UndoStack.CanUndo);
  UpdateIcon(WPI_GR_EDIT, WPI_CO_REDO, Memo.RTFData.UndoStack.CanRedo);
{$ENDIF}
end;

procedure TWPCustomRichText.DoUpdateParAttr;
var bInTable: Boolean;
  numstyle: TWPRTFNumberingStyle;
  alignment: TParAlign;
  bgcolor, fgcolor, bflags: Integer;
  aCell, aPar: TParagraph;
  sellcnt: TWPSelectionContents;
begin
  inherited DoUpdateParAttr;
  FUpdateActionStateAtOnce := TRUE;

  UpdateIconCheck(WPI_GR_PRINT, WPI_CO_FitWidth, AutoZoom = wpAutoZoomWidth);
  UpdateIconCheck(WPI_GR_PRINT, WPI_CO_FitHeight, AutoZoom = wpAutoZoomFullPage);

  {if IsSelected then   //get first CELL
       aPar := Memo.Cursor.GetBlockStart(bflags)
  else aPar := nil;
  if aPar=nil then }aPar := Memo.Cursor.active_paragraph;
  if aPar <> nil then aCell := aPar.Cell else aCell := nil;

  sellcnt := Memo.Cursor.SelectionContents;

  bInTable := not Readonly and (aCell <> nil);

    // (paprIsTable in Memo.Cursor.active_paragraph.prop);   V5.17
  if Readonly then
    UpdateIcon(WPI_GR_TABLE, WPI_CO_CreateTable, false)
  else
    if (wpAllowCreateTableInTable in EditOptions) then
      UpdateIcon(WPI_GR_TABLE, WPI_CO_CreateTable, true) else
      UpdateIcon(WPI_GR_TABLE, WPI_CO_CreateTable, not bInTable);

  if Readonly then
  begin
    UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell, false);
    UpdateIcon(WPI_GR_TABLE, WPI_CO_CombineCell, false);
  end else
    if bInTable then
    begin
      if wpAllowSplitOfCombinedCellsOnly in EditOptionsEx then
      begin
        if IsSelected then
          UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell,
            wpMergedColumns in sellcnt)
        else UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell, (aCell.NextPar <> nil) and
            (paprColMerge in aCell.NextPar.prop));
      end
      else UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell, true);

      UpdateIcon(WPI_GR_TABLE, WPI_CO_CombineCell, wpSelTableCells in sellcnt);
    end else
    begin
{$IFDEF SPLITCELL_OUTSIDE_TABLE}
      UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell, true);
{$ELSE}
      UpdateIcon(WPI_GR_TABLE, WPI_CO_SplitCell, false);
{$ENDIF}
      UpdateIcon(WPI_GR_TABLE, WPI_CO_CombineCell, false);
    end;

  UpdateIcon(WPI_GR_TABLE, WPI_CO_SelRow, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_InsRow, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_SelCol, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_DelRow, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_DelCol, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_InsCol, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_BAllOn, bInTable);
  UpdateIcon(WPI_GR_TABLE, WPI_CO_BInner, bInTable);

  if aCell <> nil then bflags := aCell.AGetDefInherited(WPAT_BorderFlags, 0)
  else if aPar <> nil then bflags := aPar.AGetDefInherited(WPAT_BorderFlags, 0)
  else bflags := 0;

  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BLeft, (bflags and WPBRD_DRAW_Left) <> 0);
  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BTop, (bflags and WPBRD_DRAW_Top) <> 0);
  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BRight, (bflags and WPBRD_DRAW_Right) <> 0);
  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BBottom, (bflags and WPBRD_DRAW_Bottom) <> 0);

  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BOuter, (bflags and WPBRD_DRAW_Left) <> 0);
  UpdateIconCheck(WPI_GR_TABLE, WPI_CO_BInner, (bflags and WPBRD_DRAW_Right) <> 0);

{$IFDEF SET_OUTLINE_WITH_MODE}
  UpdateIconCheck(WPI_GR_OUTLINE, WPI_CO_IsOutline, CurrAttr.OutlineLevel > 0);
{$ELSE}
  UpdateIconCheck(WPI_GR_OUTLINE, WPI_CO_IsOutline, CurrAttr.OutlineMode);
{$ENDIF}

  numstyle := CurrAttr.ExNumberStyle;
  UpdateIconCheck(WPI_GR_OUTLINE, WPI_CO_Bullets, (numstyle <> nil) and
    (numstyle.Style in [wp_bullet, wp_circle]));

  UpdateIconCheck(WPI_GR_OUTLINE, WPI_CO_NUMBERS, (numstyle <> nil) and
    not (numstyle.Style in [wp_bullet, wp_circle, wp_none]));

  alignment := CurrAttr.Alignment;
  UpdateIconCheck(WPI_GR_ALIGN, WPI_CO_Left, alignment = paralLeft);
  UpdateIconCheck(WPI_GR_ALIGN, WPI_CO_Right, alignment = paralRight);
  UpdateIconCheck(WPI_GR_ALIGN, WPI_CO_Center, alignment = paralCenter);
  UpdateIconCheck(WPI_GR_ALIGN, WPI_CO_Justified, alignment = paralBlock);
{$IFNDEF NOTOOLBAR}
  if (FToolBar <> nil) and (Memo.Cursor.active_paragraph <> nil) then
  begin
    bgcolor := 0;
    fgcolor := 0;
    Memo.Cursor.active_paragraph.AGetFBBGCOlor(bgcolor, fgcolor);
    if bgcolor <> 0 then
      FToolBar.UpdateSelection(wptParColor, '', bgcolor)
    else FToolBar.UpdateSelection(wptParColor, '', fgcolor);
  end;
{$ENDIF}
end;

procedure TWPCustomRichText.DoUpdateCharAttr;
var NewStyle: WrtStyle;
  b: Boolean;
  s: Single;
  a: Integer;
  str: string;
  fnt: TFontName;
begin
  inherited DoUpdateCharAttr;
  DoUpdateParAttr;

  NewStyle := CurrAttr.Style;

  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_BOLD, afsBold in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_ITALIC, afsItalic in NewStyle);
  a := CurrAttr.UnderlineMode;
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_UNDER, (afsUnderline in
    NewStyle) or ((a > 0) and (a < WPUND_NoLine)));
   // UpdateIconCheck(WPI_GR_STYLE, WPI_CO_HYPERLINK, afsHyperlink in
   //   NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_STRIKEOUT, afsStrikeout in
    NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_SUPER, afsSuper in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_SUB, afsSub in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_UPPERCASE, afsUpperCaseStyle in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_SMALLCAPS, afsSmallCaps in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_HIDDEN, afsHidden in NewStyle);
  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_PROTECTED, afsProtected in NewStyle);

  if WPNoPrinterInstalled
  then
  begin
    UpdateIcon(WPI_GR_PRINT, WPI_CO_Print, false);
    UpdateIcon(WPI_GR_PRINT, WPI_CO_PrintDialog, false);
    UpdateIcon(WPI_GR_PRINT, WPI_CO_PrintSetup, false);
  end else
  begin
    UpdateIcon(WPI_GR_PRINT, WPI_CO_Print, true);
    UpdateIcon(WPI_GR_PRINT, WPI_CO_PrintDialog, true);
    UpdateIcon(WPI_GR_PRINT, WPI_CO_PrintSetup, true);
  end;

  FUnSetHidden := (afsHidden in NewStyle);

  UpdateIconCheck(WPI_GR_STYLE, WPI_CO_NORMAL,
    not (NewStyle >= [afsBold, afsItalic, afsUnderline, afsStrikeOut,
    afsSuper, afsSub, afsHidden, afsProtected]) and
      not IsSelected);
{$IFNDEF NOTOOLBAR}
  if (FToolBar <> nil) then
  begin
    if IsSelected then
    begin
      if not SelectedTextAttr.GetFontName(fnt) then
        fnt := '  ';
      FToolBar.UpdateSelection(wptName, fnt, 0);
    end else
    begin
      FToolBar.UpdateSelection(wptName, CurrAttr.FontName, 0);
    end;
    str := CurrAttr.StyleName;
    FToolBar.UpdateSelection(wptTyp, str, 0);
    FToolBar.UpdateSelection(wptStyleNames, str, 0);
    FToolBar.UpdateSel;

      //was: FToolBar.UpdateSelection(wptSize, '', Round(CurrAttr.Size));
    if IsSelected then
      b := Memo.Cursor.SelectedTextAttr.GetFontSize(s)
    else b := Memo.Cursor.WritingTextAttr.GetFontSize(s);
    if b then
      FToolBar.UpdateSelection(wptSize, '', Round(s))
    else FToolBar.UpdateSelection(wptSize, '', Round(CurrAttr.Size) {-1});

    FToolBar.UpdateSelection(wptColor, '', CurrAttr.Color);
    FToolBar.UpdateSelection(wptBKColor, '', CurrAttr.BKColor);
  end;
{$ENDIF}
  if FActionList <> nil then
    for a := 0 to FActionList.ActionCount - 1 do
    begin
      if FActionList.Actions[a] is
        TWPToolsBasicCustomAction then
      begin
        TWPToolsBasicCustomAction(FActionList.Actions[a]).SetRTFEdit(Self);
        if FUpdateActionStateAtOnce then
          TWPToolsBasicCustomAction(FActionList.Actions[a]).Update;
      end;
    end;

  if assigned(FCharacterAttrChange) then
    FCharacterAttrChange(Self, FCurrAttr);

end;

function TWPCustomRichText.HasFocus: Boolean;
begin
  Result := Focused;
end;

procedure TWPCustomRichText.SetVRuler(x: TWPVertRuler);
begin
  FVRuler := x;
  if Assigned(FVRuler) then
  begin
    FVRuler.FreeNotification(Self);
  end;
end;

{$IFDEF IWPGUTTER}

procedure TWPCustomRichText.SetGutter(x: TWPCustomGutter);
begin
  if Assigned(FGutter) and (FGutter.FEditBox = Self) then
    FGutter.FEditBox := nil;
  FGutter := x;
  if Assigned(FGutter) then
  begin
    FGutter.FreeNotification(Self);
    FGutter.FEditBox := Self;
    FGutter.Invalidate;
  end;
end; {$ENDIF}

{----------------------------------------------------------------------
 this function may be called by anybody outside of richtext
  (although it may usually be called by the toolbar)
 -----------------------------------------------------------------------}

procedure TWPCustomRichText.OnToolBarSelection(
  Sender: TObject; var Typ: TWpSelNr;
  const str: string; const num: Integer);
begin
  inherited OnToolBarSelection(Sender, Typ, str, num);
  // if FFastMode <= 0 then
  begin
    if Typ <> wptNone then
    begin
      if (Changing = FALSE) or ReadOnly then
      begin
        // LastError := ecNoChangeAllowed;
        exit;
      end;
      case Typ of
        wptName:
          begin
            CurrAttr.FontName := str;
          {  chars := Memo.header.FontCharSet[CurrAttr.FontNr];
            if chars = SYMBOL_CHARSET then chars := 0;
            CurrAttr.FontNr := Memo.header.AddFontNameCharset(str, chars);}
          end;
        wptSize: CurrAttr.Size := num;
        wptTyp:
          begin
            if (str = '') or (str = WPLoadStr(meUndefinedStyle)) then
              CurrAttr.StyleName := ''
            else if str = WPLoadStr(meEditCurrStyle) then
              OpenDialog(wpdiaEditCurrentStyle)
            else if str = WPLoadStr(meCreateNewStyle) then
              OpenDialog(wpdiaCreateNewStyle)
            else CurrAttr.StyleName := str;
          end;
        wptColor: CurrAttr.Color := num;
        wptBKColor:
          CurrAttr.BKColor := num;
        wptParColor:
          begin
            if IsSelected then
            begin
              if num = 0 then
              begin
                SelectedTextAttr.BeginUpdate;
                SelectedTextAttr.ADel(WPAT_ShadingValue);
                SelectedTextAttr.ADel(WPAT_ShadingType);
                SelectedTextAttr.ADel(WPAT_BGColor);
                SelectedTextAttr.ADel(WPAT_FGColor);
                SelectedTextAttr.EndUpdate;
              end else
              begin
                SelectedTextAttr.BeginUpdate;
                SelectedTextAttr.ASet(WPAT_ShadingType, WPSHAD_solidbg);
                if CurrAttr.ParShading = 0 then
                  SelectedTextAttr.ASet(WPAT_ShadingValue, 100);
                SelectedTextAttr.ASet(WPAT_FGColor, num);
                SelectedTextAttr.ASet(WPAT_BGColor, num);
                SelectedTextAttr.EndUpdate;
              end;
            end else
            begin
              if num = 0 then
              begin
                ActiveParagraph.ADel(WPAT_ShadingValue);
                ActiveParagraph.ADel(WPAT_ShadingType);
                ActiveParagraph.ADel(WPAT_BGColor);
                ActiveParagraph.ADel(WPAT_FGColor);
              end else
              begin
                ActiveParagraph.ASet(WPAT_ShadingType, WPSHAD_solidbg);
                if ActiveParagraph.AGetDef(WPAT_ShadingValue, 0) = 0 then
                  ActiveParagraph.ASet(WPAT_ShadingValue, 100);
                ActiveParagraph.ASet(WPAT_FGColor, num);
                ActiveParagraph.ASet(WPAT_BGColor, num);
              end;
              Repaint;
            end;
          end;
        wptParAlign:
          case num of
            0: CurrAttr.Alignment := paralLeft;
            1: CurrAttr.Alignment := paralCenter;
            2: CurrAttr.Alignment := paralRight;
            3: CurrAttr.Alignment := paralBlock;
          end;
        wptStyleNames:
          begin
            if (str = '') or (str = WPLoadStr(meUndefinedStyle)) then
              CurrAttr.StyleName := ''
            else if str = WPLoadStr(meEditCurrStyle) then
              OpenDialog(wpdiaEditCurrentStyle)
            else if str = WPLoadStr(meCreateNewStyle) then
              OpenDialog(wpdiaCreateNewStyle)
            else CurrAttr.StyleName := str;
          end;
      end;
      Typ := wptNone;
      ChangeApplied;
      //if IsSelected then StartUpdate(WPUPD_UPDSELECTION);
      FUpdateActionStateAtOnce := TRUE;
      DoUpdateCharAttr;
      FUpdateActionStateAtOnce := FALSE;
    end;
  end;
end;

procedure TWPCustomRichText.OnToolBarIconSelection(Sender: TObject;
  var Typ: TWpSelNr; const str: string; const group, num, index: Integer);
var
  desel, bStartNumber: Boolean;
  ts: TThreeState;
  zdiff, gr, numlevel: Integer;
  par, block_s_par: PTParagraph;
  numsty: TWPRTFNumberingStyle;
  nsty: TWPTextStyle;
begin
  FDiaParam := str;
  desel := FALSE;
  try
    { if Focused then  }
    begin
      if Typ <> wptNone then
      begin
        gr := group shr 8;
        if (gr >= 0) and (gr < Length(FCommandChecked)) then
          FCommandChecked[gr] := FCommandChecked[gr] xor BitMaskL[num];

        if group = WPI_GR_TABLE then
        begin
          if typ = wptIconSel then
            ts := tsTRUE
          else
            ts := tsFALSE;
          typ := wptIconSel;
        end
        else
          ts := tsFALSE;

        if typ = wptIconSel then
        begin
          if group = WPI_GR_DISK then
            case num of
              WPI_CO_New:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  if OpenDialog(wpdiaCanClose) then OpenDialog(wpStartNewDocument);
                end;
              WPI_CO_OPEN:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  OpenDialog(wpdiaLoad);
                  //V5.24.3 Removed Except
                end;
              WPI_CO_SAVE:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  OpenDialog(wpdiaSaveAs);
                end;
              WPI_CO_ClOSE:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  if OpenDialog(wpStartSave) then OpenDialog(wpStartNewDocument);
                  { you may call Clear :
                    if LastError=ecOk   then Clear;
                    But be careful: if you are working on a database,
                    WPI_CO_CLOSE not usable
                  }
                end;
            end
          else if group = WPI_GR_PRINT then
            case num of
              WPI_CO_PRINT:
                begin
                 { if (FWPToolsEnviroment <> nil) and assigned(TWPToolsEnviroment(FWPToolsEnviroment).FOnPrint) then
                    TWPToolsEnviroment(FWPToolsEnviroment).FOnPrint(FWPToolsEnviroment, Self)
                  else }
                  desel := TRUE;
                  Typ := wptNone;
                  OpenDialog(wpStartPrint); // use wpdiaPrint to use dialog!
                end;
              WPI_CO_PrintDialog:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  OpenDialog(wpdiaPrint);
                end;
              WPI_CO_PrintSetup:
                begin
                  desel := TRUE;
                  Typ := wptNone;
                  OpenDialog(wpdiaPrinterSetup);
                end;
              WPI_CO_ZoomIn:
                begin
                  AutoZoom := wpAutoZoomOff;
                  if Zooming > 200 then
                    zdiff := 50
                  else if Zooming >= 100 then
                    zdiff := 20
                  else
                    zdiff := 10;
                  if Zooming < 999 then
                    Zooming := ((Zooming + zdiff + 1) div zdiff) * zdiff
                  else
                    Zooming := 1000;
                  Typ := wptNone;
                  desel := TRUE;
                  DoUpdateParAttr;
                  Memo.ShowCursor;
                end;
              WPI_CO_ZoomOut:
                begin
                  AutoZoom := wpAutoZoomOff;
                  if Zooming > 200 then
                    zdiff := 50
                  else if Zooming >= 100 then
                    zdiff := 20
                  else
                    zdiff := 10;
                  if Zooming > 10 then
                    Zooming := ((Zooming - zdiff) div zdiff) * zdiff
                  else
                    Zooming := 10;
                  Typ := wptNone;
                  desel := TRUE;
                  DoUpdateParAttr;
                  Memo.ShowCursor;
                end;
              WPI_CO_NextPage:
                begin
                  // Memo._ShowTopOfPage := TRUE;
                  if CaretDisabled then
                    PageNumber := PageNumber + 1
                  else CPPage := CPPage + 1;
                  Typ := wptNone;
                  desel := TRUE;
                end;
              WPI_CO_PriorPage:
                begin
                  if CaretDisabled then
                    PageNumber := PageNumber - 1
                  else CPPage := CPPage - 1;
                  Typ := wptNone;
                  desel := TRUE;
                end;
              WPI_CO_FitWidth:
                begin
                  if AutoZoom <> wpAutoZoomWidth then
                    AutoZoom := wpAutoZoomWidth
                  else
                    AutoZoom := wpAutoZoomOff;
                  Typ := wptNone;
                  DoUpdateParAttr;
                end;
              WPI_CO_FitHeight:
                begin
                  if AutoZoom <> wpAutoZoomFullPage then
                    AutoZoom := wpAutoZoomFullPage
                  else
                    AutoZoom := wpAutoZoomOff;
                  Typ := wptNone;
                  DoUpdateParAttr;
                end;
            end
          else if group = WPI_GR_EDIT then
            case num of
              WPI_CO_CUT:
                begin
                  if Changing then
                  begin
                    CutToClipboard;
                    ChangeApplied;
                  end;
                  desel := TRUE;
                  Typ := wptNone;
                end;
              WPI_CO_COPY:
                begin
                  CopyToClipboard;
                  desel := TRUE;
                  Typ := wptNone;
                end;
              WPI_CO_PASTE:
                begin
                  if Changing then
                  begin
                    PasteFromClipboard;
                    ChangeApplied;
                  end;
                  desel := TRUE;
                  Typ := wptNone;
                end;
              WPI_CO_SELALL:
                begin
                  SelectAll;
                  Typ := wptNone;
                end;
              WPI_CO_HIDESEL:
                begin
                  SetSelPosLen(0, 0);
                  Typ := wptNone;
                end;
              WPI_CO_Find:
                begin
                  desel := TRUE;
                  OpenDialog(wpdiaFind);
                end;

              WPI_CO_FindNext:
                begin
                  desel := TRUE;
                  OpenDialog(wpStartFindNext);
                end;
              WPI_CO_Replace:
                begin
                  desel := TRUE;
                  if not readonly then OpenDialog(wpdiaReplace);
                end;
              WPI_CO_SpellCheck:
                begin
                  desel := TRUE;
                  StartSpellCheck(wpStartSpellCheck);
                end;
              WPI_CO_Thesaurus:
                begin
                  desel := TRUE;
                  StartSpellCheck(wpStartThesuarus);
                end;
              WPI_CO_SpellAsYouGo:
                begin
                  desel := FALSE;
                  StartSpellCheck(wpStartSpellAsYouGo);
                end;
              WPI_CO_SpellCheckSetup:
                begin
                  StartSpellCheck(wpShowSpellCheckSetup);
                  desel := TRUE;
                end;
              WPI_CO_Undo:
                begin
                  Undo;
                  desel := TRUE;
                end;
              WPI_CO_Redo:
                begin
                  Redo;
                  desel := TRUE;
                end;
              WPI_CO_DeleteText:
                begin
                  if IsSelected then ClearSelection; desel := TRUE;
                end;
            end
          else if group = WPI_GR_STYLE then
          begin
            case num of
              WPI_CO_BOLD:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsBold], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_ITALIC:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsItalic], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_UNDER:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsUnderline], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SUPER:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSub], false);
                    CurrAttr.TextStyle([afsSuper], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SUB:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSuper], false);
                    CurrAttr.TextStyle([afsSub], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_HIDDEN:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsHidden], not FUnSetHidden);
                    FUnSetHidden := not FUnSetHidden; { V1.92 }
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_RTFCODE:
                begin
                  Typ := wptNone;
                  if Changing then
                  begin
                    OpenDialog(wpdiaInsertCode);
                    ChangeApplied;
                  end;
                end;

              WPI_CO_HYPERLINK:
                begin
                  Typ := wptNone;
                  desel := true;
                  OpenDialog(wpEditHyperlink);
                end;

              WPI_CO_STRIKEOUT:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsStrikeOut], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_PROTECTED:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsProtected], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_UPPERCASE:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsUpperCaseStyle], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SMALLCAPS:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSmallCaps], true);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_NORMAL:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([
                      afsBold, afsItalic,
                        afsUnderline, afsStrikeOut, afsSuper,
                        afsSub, afsUppercaseStyle, afsSmallCaps,
                        afsLowercaseStyle, afsNoProof,
                        afsDoubleStrikeOut], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
            end;
            //if IsSelected then StartUpdate(WPUPD_UPDSELECTION);
            desel := FALSE;
          end
          else if group = WPI_GR_ALIGN then
          begin
            if Changing then
            begin
              case num of
                WPI_CO_LEFT: CurrAttr.Alignment := parAlLeft;
                WPI_CO_CENTER: CurrAttr.Alignment := parAlCenter;
                WPI_CO_JUSTIFIED: CurrAttr.Alignment := parAlBlock;
                WPI_CO_RIGHT: CurrAttr.Alignment := parAlRight;
              end;
              DoUpdateParAttr;
              ChangeApplied;
            end;
          end
          else if group = WPI_GR_TABLE then
          begin
            if Changing then
            begin
              case num of
                WPI_CO_CreateTable: if Changing then
                  begin
                    if Sender is TControl then
                    { -----------------------------------------------------
                      IF YOU GET A COMPILER ERROR YOU HAVE ----------------
                      WPTOOLS 4 IN YOUR SEARCH PATH OR THE WPTOOLS 4
                      PACKAGE IN 'REQUIRES' OF YOUR PACKAGE PROJECT -------
                      ----------------------------------------------------- }
                      WPCreateTableForm(Parent, TControl(Sender), Self, wpAllowCreateTableInTable in EditOptions)
                    { ------------------------------------------------------ }
                    else
                      WPCreateTableForm(Parent, nil, Self, wpAllowCreateTableInTable in EditOptions);
                    Memo.Repaint;
                    desel := TRUE;
                  end;
                {  WPI_CO_BBox        :;   }{ left, top, right, bottom, inner }
                WPI_CO_BLeft: if Changing then
                    CurrAttr.SetCellBorders(ts, tsIgnore, tsIgnore,
                      tsIgnore, tsIgnore);
                WPI_CO_BTop: if Changing then
                    CurrAttr.SetCellBorders(tsIgnore, ts, tsIgnore, tsIgnore,
                      tsIgnore);
                WPI_CO_BRight: if Changing then
                    CurrAttr.SetCellBorders(tsIgnore, tsIgnore, ts,
                      tsIgnore, tsIgnore);
                WPI_CO_BBottom: if Changing then
                    CurrAttr.SetCellBorders(tsIgnore, tsIgnore, tsIgnore,
                      ts, tsIgnore);
                WPI_CO_BAllOff: if Changing then
                  begin
                    CurrAttr.SetCellBorders(tsFalse, tsFalse, tsFalse, tsFalse,
                      tsFalse); desel := TRUE;
                  end;
                WPI_CO_BAllOn: if Changing then
                  begin
                    CurrAttr.SetCellBorders(tsTRUE, tsTRUE, tsTRUE, tsTRUE,
                      tsTRUE); desel := TRUE;
                  end;
                WPI_CO_BInner: if Changing then
                    CurrAttr.SetCellBorders(tsIgnore, tsIgnore, tsIgnore,
                      tsIgnore, ts);
                WPI_CO_BOuter: if Changing then
                  begin
                    SetOuterCellBorders(ts = tsTrue, -1);
                   { if ts = tsTrue then
                      CurrAttr.SetCellBorders(ts, ts, ts, ts, tsFalse)
                    else  CurrAttr.SetCellBorders(ts, ts, ts, ts, tsIgnore); }
                  end;
                WPI_CO_SelRow: if Changing then
                  begin
                    Memo.Cursor.SelectThisRow(false);
                    desel := TRUE;
                  end;
                WPI_CO_InsRow: if Changing then
                  begin
                    if GetAsyncKeyState(VK_CONTROL) < 0 then
                      InsertRowAbove
                    else InsertRow;
                    Memo.ShowCursor;
                    desel := TRUE;
                  end;
                WPI_CO_DelRow: if Changing then
                  begin
                    if not Memo.IsProtectedRow(TableRow, false) then //V5.15.5
                      DeleteRow;
                    Memo.ShowCursor;
                    desel := TRUE;
                  end;
                WPI_CO_DelCol: if Changing then
                  begin
                    DeleteColumn;
                    desel := TRUE;
                  end;
                WPI_CO_InsCol: if Changing then
                  begin
                    InsertColumn;
                    desel := TRUE;
                  end;
                WPI_CO_SelCol:
                  begin
                    Memo.Cursor.SelectThisColumn(false);
                    desel := TRUE;
                  end;
                WPI_CO_SplitCell: if Changing then
                  begin
                    SplitCells; desel := TRUE;
                  end;
                WPI_CO_CombineCell: if Changing then
                  begin
{$IFDEF COMBINECELLTOTAL}
                    CombineCellsVertHorz;
{$ELSE}
                    CombineCells;
{$ENDIF}
                    desel := TRUE;
                  end;
              end;
              Typ := wptNone;
              ChangeApplied;
            end;
          end
          else if group = WPI_GR_PARAGRAPH then
          begin
            if Changing then
            begin
              case num of
                WPI_CO_PARPROTECT: if Changing then
                  begin
                    CurrAttr.ParProtect := TRUE;
                    ChangeApplied;
                  end;
                WPI_CO_PARKEEP: if Changing then
                  begin
                    CurrAttr.ParKeep := TRUE;
                    ChangeApplied;
                  end;
              end;
            end;
          end
            // EXTRA - with param in 'str'
          else if group = WPI_GR_EXTRA then
          begin
            if Changing then
            begin
              Typ := wptNone;
              desel := true;
              case num of
                WPI_CO_InsertNumber: InputTextFieldName(Str);
                WPI_CO_InsertField: InputMergeField(str, Str);
                WPI_CO_EditHyperlink: OpenDialog(wpEditHyperlink);
              end;
            end;
          end
            // --------------------------
          else if group = WPI_GR_OUTLINE then
          begin
            if Changing then
            begin
              case num of
                WPI_CO_BULLETS: if Changing then
                  begin
                    RTFData.StartUndolevel;
{$IFDEF RESTART_NUMBERING_ALA_MSWORD} //JZ Restart matching bullet list
                    if IsSelected then
                    begin
                      par := TextCursor.GetBlockStart(gr);
                      if par <> nil then par := par.prev;
                    end
                    else par := ActivePar.prev;
                    while (par <> nil) do
                    begin
                      par.GetNumberText(nsty, true);
                      if (nsty <> nil) then
                      begin
                        gr := nsty.AGetDef(WPAT_NumberMODE, 0);
                        if (numlevel > 0) or (gr <> WPNUM_BULLET) then par := nil;
                        break;
                      end;
                      if not par.IsEmpty then
                      begin
                        par := nil;
                        break;
                      end;
                      par := par.prev;
                    end;
                    if par <> nil then
                    begin
                      TextCursor.CurrAttribute.ADel(WPAT_NumberLEVEL);
                      TextCursor.CurrAttribute.ASet(WPAT_NumberSTYLE,
                        par.AGetDef(WPAT_NumberSTYLE, 0)
                        );
                    end
                    else
{$ENDIF}
{$IFDEF NUMBERACTION_SIMPLE}
                      CurrAttr.NumberStyle := Integer(wp_bullet);
{$ELSE}
                      CurrAttr.OutlineStyle := wp_bullet;
{$ENDIF}
                    CurrAttr.AutoIndentFirst(DefaultNumberIndent);
                    RTFData.EndUndolevel;
                    ChangeApplied;
                    //DoUpdateCharAttr;
                  end;
                WPI_CO_NUMBERS:
                  if Changing then
                  begin
                    RTFData.StartUndolevel;
                    if IsSelected then
                    begin
                      par := TextCursor.GetBlockStart(gr);
                      if (par <> nil) and (par.prev <> nil) then
                        par := par.prev;
                    end
                    else par := ActivePar.prev;
                    numsty := nil;
                    if CurrAttr.OutlineStyle in [wp_none, wp_bullet] then
                    begin
                      if (par <> nil) and (numsty <> nil) then
                        CurrAttr.ExNumberStyle := numsty
                      else
{$IFDEF NUMBERACTION_SIMPLE}
                        CurrAttr.NumberStyle := Integer(wp_1);
{$ELSE}
                      begin
                        if (par <> nil) and par.AGet(WPAT_NumberSTYLE, gr) and
                          (par.AGetDef(WPAT_NumberLEVEL, 0) = 0) then
                        begin
                          CurrAttr.NumberStyle := gr;
                        end
                        else CurrAttr.OutlineStyle := wp_1;

{$IFDEF RESTART_NUMBERING_ALA_MSWORD}
                        // - previous par is "empty" and pre-previous par is
                        // "numbered" then this number will continue
                        // - previous par is "non-empty" and pre-previous par is
                        // "numbered" then this number will restart

                        //JZ: Changed ActivePar to TextCursor.CurrAttribute
                        //JZ: Skip bullets V5.20.8
                        bStartNumber := FALSE;
                        if (par <> nil) then
                        begin
                          // empty, and non-numbered, remains searching
                          // while (par <> nil) and (par.IsEmpty ) and (not par.AGet(WPAT_NumberSTYLE, gr)) do
                          //  par := par.prev;

                          while par <> nil do
                          begin
                            par.GetNumberText(nsty, true);
                            if nsty <> nil then
                            begin
                              gr := nsty.AGetDef(WPAT_NumberMODE, 0);
                              if (par.AGetDef(WPAT_NumberLevel, 0) > 0) or
                                ((gr <> WPNUM_BULLET) and (gr <> WPNUM_CIRCLE)) then
                              begin
                                gr := par.AGetDef(WPAT_NumberSTYLE, 0);
                                break;
                              end else bStartNumber := TRUE;
                            end
                            else if not par.IsEmpty then break;
                            par := par.prev;
                          end;

                          if GetAsyncKeyState(VK_CONTROL) < 0 then
                            bStartNumber := not bStartNumber;

                          if (par <> nil) then
                          begin
                            if IsSelected then
                              block_s_par := TextCursor.GetBlockStart(zdiff) else block_s_par := nil;
                            if block_s_par = nil then block_s_par := ActiveParagraph;

                            // Remove Number Start Attribute
                            TextCursor.CurrAttribute.ADel(WPAT_NumberStart);
                            TextCursor.CurrAttribute.BeginUpdate;
                            if (not par.IsEmpty) then // non empty, restart !
                            begin
                              if not par.AGet(WPAT_NumberSTYLE, gr) then
                              begin
                                if not bStartNumber then
                                  block_s_par.ASet(WPAT_NumberStart, 1)
                              end
                              else
                              begin
                                TextCursor.CurrAttribute.ASet(WPAT_NumberSTYLE, gr);

                                if bStartNumber then
                                  block_s_par.ASet(WPAT_NumberStart, 1);

                                if par.AGet(WPAT_NumberLevel, numlevel) then
                                  TextCursor.CurrAttribute.ASet(WPAT_NumberLevel, numlevel)
                                else
                                  TextCursor.CurrAttribute.ADel(WPAT_NumberLevel);
                              end;
                            end;
                          end;
                          TextCursor.CurrAttribute.EndUpdate;
                        end;
{$ENDIF RESTART_NUMBERING_ALA_MSWORD}

                      end
{$ENDIF}
                    end
                    else
                      CurrAttr.OutlineStyle := wp_none;
                    CurrAttr.AutoIndentFirst(DefaultNumberIndent);
                    //DoUpdateCharAttr;

                    RTFData.EndUndolevel;
                    ChangeApplied;
                  end;
                WPI_CO_NextLevel: if Changing then
                  begin
                    if CurrAttr.NumberStyle <> 0 then
                      CurrAttr.IncOutlineLevel;
                    CurrAttr.IncIndent;
                    desel := TRUE;
                    //DoUpdateCharAttr;
                    ChangeApplied;
                  end;
                WPI_CO_PriorLevel: if Changing then
                  begin
                    if CurrAttr.NumberStyle <> 0 then
                      CurrAttr.DecOutlineLevel;
                    CurrAttr.DecIndent;
                    desel := TRUE;
                    //DoUpdateCharAttr;
                    ChangeApplied;
                  end;
                WPI_CO_IsOutline:
                  if Changing then
                  begin
                    CurrAttr.OutlineMode := TRUE;
{$IFDEF SET_OUTLINE_WITH_MODE}
                    CurrAttr.OutlineLevel := 1; // WE SET THE OUTLINE LEVEL
{$ENDIF}
                    ChangeApplied;
                  end;
              {  WPI_CO_OutlineUp:
                  if Changing then
                  begin
                    Memo.LEVELInc;
                    desel := TRUE;
                    ChangeApplied;
                  end;
                WPI_CO_OutlineDown:
                  if Changing then
                  begin
                    Memo.LEVELDec;
                    desel := TRUE;
                    ChangeApplied;
                  end;  }
              end;
            end;
          end;
        end
        else if typ = wptIconDesel then
        begin
          if group = WPI_GR_STYLE then
          begin
            case num of
              WPI_CO_BOLD:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsBold], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_ITALIC:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsItalic], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_UNDER:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsUnderline], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SUPER:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSuper], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SUB:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSub], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_STRIKEOUT:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsStrikeOut], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_PROTECTED:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsProtected], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_UPPERCASE:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsUpperCaseStyle], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_SMALLCAPS:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsSmallCaps], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_HIDDEN:
                begin
                  if Changing then
                  begin
                    CurrAttr.TextStyle([afsHidden], false);
                    ChangeApplied;
                  end;
                  Typ := wptNone;
                end;
              WPI_CO_RTFCODE:
                begin
                  // now a code dialog
                  Typ := wptNone;
                end;
              WPI_CO_HYPERLINK:
                begin
                  // now a code dialog
                  Typ := wptNone;
                end;
            end;
            //if IsSelected then StartUpdate(WPUPD_UPDSELECTION);
            desel := FALSE;
          end
          else if group = WPI_GR_EDIT then
          begin
            case num of
              WPI_CO_SELALL,
                WPI_CO_HIDESEL:
                begin
                  SetSelPosLen(0, 0);
                  Typ := wptNone;
                end;
              WPI_CO_SpellAsYouGo:
                begin
                  StartSpellCheck(wpStopSpellAsYouGo);
                  Typ := wptNone;
                end;
            end;
          end
          else if group = WPI_GR_PARAGRAPH then
          begin
            if Changing then
            begin
              case num of
                WPI_CO_PARPROTECT:
                  begin
                    CurrAttr.ParProtect := FALSE;
                    ChangeApplied;
                  end;
                WPI_CO_PARKEEP:
                  begin
                    CurrAttr.ParKeep := FALSE;
                    ChangeApplied;
                  end;
              end;
            end;
          end
          else if group = WPI_GR_OUTLINE then
          begin
            case num of
              WPI_CO_BULLETS, WPI_CO_NUMBERS:
                if Changing then
                begin
                  if CurrAttr.IndentFirst < 0 then
                  begin
                    CurrAttr.IndentLeft := CurrAttr.IndentLeft + CurrAttr.IndentFirst;
                    CurrAttr.IndentFirst := 0;
                  end;
                  CurrAttr.NumberStyle := 0;
                  ChangeApplied;
                  //DoUpdateCharAttr;
                end;
              WPI_CO_NextLevel, WPI_CO_PriorLevel: ;
              WPI_CO_IsOutline:
                if Changing then
                begin
                  CurrAttr.OutlineMode := FALSE;
{$IFDEF SET_OUTLINE_WITH_MODE}
                  CurrAttr.OutlineLevel := 0; // WE SET THE OUTLINE LEVEL
{$ENDIF}
                  ChangeApplied;
                end;
              WPI_CO_OutlineUp:
                begin
                end;
              WPI_CO_OutlineDown:
                begin
                end;
            end;
          end
          else if group = WPI_GR_PRINT then
            case num of
              WPI_CO_FitWidth, WPI_CO_FitHeight:
                begin
                  AutoZoom := wpAutoZoomOff;
                  Zooming := 100;
                  DoUpdateParAttr;
                end;
            end;
        end;
      end;
    end;
  finally
    if desel then
    begin
      UpdateIconCheck(group, num, FALSE);
    end;
    FUpdateActionStateAtOnce := TRUE;
    DoUpdateCharAttr;
    FUpdateActionStateAtOnce := FALSE;
    FDiaParam := '';
  end;
end;

constructor TWPCustomRichText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTempFont := TFont.Create;
  FCurrAttr := TWPSetModeControl.Create(Self);
  Width := 100;
  Height := 100;
  AvailableDialogs := [
    wpStartPrint, // starts printing without dialog
    wpdiaPrint,
    wpdiaPrinterSetup,
    wpStartSave, // starts saving without dialog
    wpdiaSaveAs,
    wpdiaLoad,
    wpdiaCanClose,
    wpStartNewDocument,
    wpEditHyperlink,
   //wpdiaSaveAsPDF,
   //wpdiaSpellCheck,
   //wpdiaThesaurus,
  wpdiaFind,
    wpStartFindNext,
    wpdiaReplace
   //wpdiaSendByEMail
  ];
end;

destructor TWPCustomRichText.Destroy;
begin
{$IFNDEF NOTOOLBAR}WPToolBar := nil; {$ENDIF}
  WPRuler := nil;
  ActionList := nil;
  VRuler := nil;
  WPGutter := nil;
  FTempFont.Free;
  FCurrAttr.Free;
  if FFindDialog <> nil then FFindDialog.OnFind := nil;
  if FReplaceDialog <> nil then
  begin
    FReplaceDialog.OnReplace := nil;
    FReplaceDialog.OnFind := nil;
  end;
  inherited Destroy;
end;

procedure TWPCustomRichText.RemoveRTFData;
begin
  FCurrAttr.FCursor := nil;
  inherited RemoveRTFData;
end;

procedure TWPCustomRichText.SetRTFData(ARTFData: TWPRTFDataCollection);
begin
  inherited SetRTFData(ARTFData);
  if ARTFData <> nil then FCurrAttr.FCursor := ARTFData.Cursor;
end;

procedure TWPCustomRichText.SetFocusValues(Always: Boolean);
var
  a: Integer;
begin
  inherited SetFocusValues(Always);
  if csDestroying in ComponentState then exit;

  if assigned(FActionList)
    and not (csDestroying in FActionList.ComponentState) then
  begin
    for a := 0 to FActionList.ActionCount - 1 do
    begin
      if FActionList.Actions[a] is
        TWPToolsBasicCustomAction then
        TWPToolsBasicCustomAction(FActionList.Actions[a]).SetRTFEdit(Self);
    end;
  end;
  (* happens already in  UpdateRulerValues!
{$IFDEF IWPGUTTER}
  if Assigned(FGutter) and not (csDestroying in FGutter.ComponentState) then
  begin
    FGutter.FEditBox := Self;
    FGutter.Invalidate;
  end; {$ENDIF}     *)

  UpdateRulerValues;
{$IFNDEF NOTOOLBAR}
  if Assigned(FToolBar)
    and not (csDestroying in FToolBar.ComponentState) then
  begin
    FToolBar.RtfEdit := Self;
  end;
{$ENDIF}

  if FFindDialog <> nil then FFindDialog.OnFind := OnFind;
  if FReplaceDialog <> nil then
  begin
    FReplaceDialog.OnReplace := OnReplace;
    FReplaceDialog.OnFind := OnFind;
  end;
  DoUpdateCharAttr;
  DoUpdateEditState;
end;

function TWPCustomRichText.OpenDialog(DialogType: TWPCustomRtfEditDialog): Boolean;
begin
  Result := inherited OpenDialog(DialogType);
  if Result = false then
    case DialogType of
      wpStartPrint: Result := Print();
      wpdiaPrint: Result := PrintDialog;
      wpdiaPrinterSetup: Result := PrinterSetup;
      wpStartSave: Result := Save;
      wpdiaSaveAs: Result := SaveAs;
      wpdiaLoad: Result := Load;
      wpdiaCanClose: Result := CanClose;
      wpEditHyperlink: Result := EditHyperlink('');
      wpStartNewDocument:
        begin
          ClearEx(wpDontClearStylesInNew in EditOptionsEx,
            wpDontResetPagesizeInNew in EditOptionsEx,
            wpSetDefaultAttrInNew in EditOptionsEx);
          ActiveParagraph := FirstPar;
          LastFileName := '';
          Invalidate;
          ShowCursor;
          Result := TRUE;
        end;
      wpdiaSaveAsPDF: begin end;
      wpdiaSpellCheck: begin end;
      wpdiaThesaurus: begin end;
      wpdiaFind: Result := FindDialog('@SELECTED@');
      wpdiaReplace: Result := ReplaceDialog('@SELECTED@');
      wpdiaSendByEMail: begin end;

    end;
  SetFocusValues(true);
end;

function TWPCustomRichText.SetTabPos(PosInTwips: Integer;
  kind: TTabKind = tkLeft;
  delete_it: Boolean = False;
  FillMode: TTabFill = tkNoFill;
  FillColor: Integer = 0): Boolean;
begin
  if PosInTwips > 262143 then PosInTwips := 262143;

  if delete_it then
    Result := TabstopDelete(PosInTwips)
  else Result := TabstopAdd(PosInTwips, kind, FillMode, FillColor);
end;

{$IFDEF V4COMAPT}

function TWPCustomRichText.GetSelTextBuf(bug: PChar; len: Integer): Integer;
begin
  if bug = nil then
  begin
    FANSIText := AsANSIString('ANSI', true, false);
    Result := Length(FANSIText);
  end else
  begin
    StrPLCopy(bug, FANSIText, len);
    Result := Length(FANSIText);
    FANSIText := '';
  end;
end;

procedure TWPCustomRichText.InsertParText(Index: Longint; const Buffer: Pchar;
  Size: Integer);
begin
  CPParNr := Index;
  InputString(#13);
  if (Buffer <> nil) then InputString(StrPas(Buffer));
end;

procedure TWPCustomRichText.ChangeAttr(var a: TAttr; what: TWhatToChange);
begin
  if wtcFont in what then CurrAttr.SetFontNr(a.Font);
  if wtcSize in what then CurrAttr.SetSize(a.Size);
  if wtcColor in what then CurrAttr.SetColor(a.Color);
  if wtcBKColor in what then CurrAttr.SetColor(a.BGColor);
  if wtcStyle in what then CurrAttr.SetStyle(a.Style);
  if wtcAddStyle in what then CurrAttr.AddStyle(a.Style);
  if wtcSubStyle in what then CurrAttr.DeleteStyle(a.Style);
end;

function TWPCustomRichText.GetParText(Index: Longint; Buffer: Pchar; Size: Integer): Integer;
var par: TParagraph;
begin
  par := GetPar(Index);
  if par = nil then Result := 0 else
  begin
    Result := par.CharCount;
    if Buffer <> nil then StrPLCopy(Buffer, par.ANSIText, Size);
  end;
end;
{$ENDIF}

function TWPCustomRichText.CanClose: Boolean;
var
  buf1, buf2: string; i: Integer;
begin
  Result := TRUE;
  if Modified then
  begin
    buf1 := WPLoadStr(meSaveChangedText);
    buf2 := Application.Title;

    i := MessageBox(Handle, PChar(buf1), PChar(buf2), MB_YESNOCANCEL or MB_TASKMODAL);
    if i = mrYes then
      Result := Save
    else if i = mrCancel then
      Result := FALSE
    else if i = mrNo then
      Modified := FALSE;
  end;
end;

function TWPCustomRichText.UpdateFontValues: TFont;
var sty: WrtStyle;
  fst: TFontStyles;
begin
  FTempFont.Name := CurrAttr.FontName;
  fst := [];
  sty := CurrAttr.Style;
  if afsBold in sty then include(fst, fsBold);
  if afsUnderline in sty then include(fst, fsUnderline);
  if afsItalic in sty then include(fst, fsItalic);
  if afsStrikeout in sty then include(fst, fsStrikeout);
  FTempFont.Style := fst;
  if CurrAttr.Color <> 0 then FTempFont.Color := CurrAttr.NrToColor(CurrAttr.Color)
  else FTempFont.Color := clNone;
  FTempFont.Size := Round(CurrAttr.Size);
  Result := FTempFont;
end;

procedure TWPCustomRichText.ApplyFont(x: TFont);
var fst: WrtStyle;
  sty: TFontStyles;
begin
  CurrAttr.BeginUpdate;
  try
    CurrAttr.FontName := x.Name;
    fst := [];
    sty := x.Style;
    if fsBold in sty then include(fst, afsBold);
    if fsUnderline in sty then include(fst, afsUnderline);
    if fsItalic in sty then include(fst, afsItalic);
    if fsStrikeout in sty then include(fst, afsStrikeout);
    if fst <> [afsBold, afsUnderline, afsItalic, afsStrikeout] then
      CurrAttr.DeleteStyle([afsBold, afsUnderline, afsItalic, afsStrikeout] - fst);
    if fst <> [] then CurrAttr.AddStyle(fst);
    if x.Color <> clNone then
      CurrAttr.Color := CurrAttr.ColorToNr(x.Color);
    if x.Size > 0 then
      CurrAttr.Size := x.Size;
  finally
    CurrAttr.EndUpdate;
    SetFocusValues(false);
  end;
end;

function TWPCustomRichText.FontSelect: Boolean;
var
  FontDialog1: TFontDialog;
  BlockAttr: TWPBlockAttribute;
begin
  Result := FALSE;
  if Changing then
  begin
    FontDialog1 := nil;
    try
      FontDialog1 := TFontDialog.Create(Self);
{$IFNDEF DISABLEPRINTER}
      if not WPNoPrinterInstalled and (Printer.Printers.Count > 0) then
        FontDialog1.Device := fdPrinter;
{$ENDIF}
      if Memo.Selected then
      begin
        Memo.GetBlockAttr(BlockAttr, TRUE);
        // Also assigns the asttributes to 'Attr'
        if BlockAttr.FontDiffers then
          FontDialog1.Options := FontDialog1.Options + [fdNoFaceSel];
        if BlockAttr.SizeDiffers then
          FontDialog1.Options := FontDialog1.Options + [fdNoSizeSel];
      end;
      FontDialog1.Font.Assign(UpdateFontValues);
{$IFDEF USEEXECDIA}if ExecDialog(FontDialog1) then {$ELSE}
      if FontDialog1.Execute then {$ENDIF}
      begin
        ApplyFont(FontDialog1.Font);
        ChangeApplied;
        Result := TRUE;
      end;
    finally
      FontDialog1.Free;
    end;
    ChangeApplied;
  end;
end;

function TWPCustomRichText.Insert(InitPath: string = ''; Filter: string = ''): Boolean;
var
  dia: TOpenDialog;
  oldenabled: Boolean;
  def: string;
  i: Integer;
begin
  Result := FALSE;
  WorkOnText := wpIsBody;
  if not ReadOnly and not FIOLocked then
  begin
    if not Changing then exit;

    if assigned(WPLoadWithConverter) then
      Result := WPLoadWithConverter(Self, False, True, FInitialDir)
    else
    begin
      dia := TOpenDialog.Create(Self);
      oldenabled := Enabled;
      try
        FIOLocked := TRUE;
        if InitPath <> '' then
          dia.InitialDir := InitPath else
          dia.InitialDir := InitialDir;
        if Filter = '' then
          dia.Filter := WPLoadStr(meFilter)
        else dia.Filter := Filter;

        if DefaultIOFormat <> '' then def := DefaultIOFormat
        else def := TextLoadFormat;

        if CompareText(def, 'HTML') = 0 then
          dia.FilterIndex := 2
        else if CompareText(def, 'ANSI') = 0 then
          dia.FilterIndex := 3
        else if CompareText(def, 'WPTOOLS') = 0 then
          dia.FilterIndex := 4
        else dia.FilterIndex := CalcFilterIndex(dia.Filter, dia.FileName);

        dia.Options := [ofNoChangeDir, ofNoChangeDir, ofNoReadOnlyReturn, ofHideReadOnly];
{$IFDEF USEEXECDIA}if ExecDialog(dia) then {$ELSE}
        if dia.Execute then {$ENDIF}
        begin
          try
            i := Pos('-', def); //V5.21 - keep options but use AUTO!!
            if i > 0 then
              def := 'AUTO' + Copy(def, i, Length(def))
            else def := '';
            Result := LoadFromFile(dia.Filename, false, def);
            if Result then LastFileName := dia.Filename;
          except
            on E: Exception do
            begin

              raise;
            end;
          end;
        end;
      finally
        dia.Free;
        FIOLocked := FALSE;
        Enabled := OldEnabled;
      end;
    end;
  end;
end;

// Private code
{$IFDEF USEEXECDIA}

function TWPCustomRichText.ExecDialog(Dia: TCommonDialog): Boolean;
begin
  Result := Dia.Execute;
end;
{$ENDIF}

function TWPCustomRichText.LoadWithConverter(FileName: string): Boolean;
begin
  Result := FALSE;
  if not FIOLocked then
  begin
    WorkOnText := wpIsBody;
    Changing; // Required if this is a database control !
    if assigned(WPLoadWithConverter) then
      Result := WPLoadWithConverter(Self, False, False, FileName);
  end;
end;

function TWPCustomRichText.Load(InitPath: string = ''; Filter: string = ''): Boolean;
begin
  Result := LoadEx(InitPath, Filter, true);
end;

function TWPCustomRichText.LoadEx(InitPath: string = ''; Filter: string = ''; UseConvDLLIfAvailable: Boolean = true): Boolean;
var
  dia: TOpenDialog;
  oldenabled: Boolean;
  def: string;
  i: Integer;
begin
  Result := FALSE;
  WorkOnText := wpIsBody;
  if not ReadOnly and not FIOLocked then
  begin
    if not Changing then exit;

    if UseConvDLLIfAvailable and assigned(WPLoadWithConverter) then
      Result := WPLoadWithConverter(Self, False, True, FInitialDir)
    else
    begin
      dia := TOpenDialog.Create(Self);
      oldenabled := Enabled;
      try
        FIOLocked := TRUE;
        if InitPath <> '' then
          dia.InitialDir := InitPath else
          dia.InitialDir := InitialDir;
        if Filter = '' then
          dia.Filter := WPLoadStr(meFilter)
        else dia.Filter := Filter;

        if DefaultIOFormat <> '' then def := DefaultIOFormat
        else def := TextLoadFormat;

        if Pos('HTML', def) = 1 then
          dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.HTM')
        else if Pos('ANSI', def) = 1 then
          dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.TXT')
        else if Pos('WPTOOLS', def) = 1 then
          dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.WPT')
        else if Pos('RTF', def) = 1 then
          dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.RTF')
        else dia.FilterIndex := CalcFilterIndex(dia.Filter, dia.FileName);

        dia.Options := [ofNoChangeDir, ofNoReadOnlyReturn, ofHideReadOnly];
{$IFDEF USEEXECDIA}if ExecDialog(dia) then {$ELSE}
        if dia.Execute then {$ENDIF}
        try
          i := Pos('-', def); //V5.21 - keep options but use AUTO!!
          if i > 0 then
            def := 'AUTO' + Copy(def, i, Length(def))
          else def := '';
          Result := LoadFromFile(dia.Filename, true, def);
          if Result then LastFileName := dia.Filename;
        except
          on E: Exception do
          begin

            raise;
          end;
        end;
      finally
        dia.Free;
        FIOLocked := FALSE;
        Enabled := OldEnabled;
      end;
    end;
  end;
end;

function TWPCustomRichText.Save(InitPath: string = ''; Filter: string = ''): Boolean;
begin
  WorkOnText := wpBody;
  if LastFileName = '' then
    Result := SaveAs(InitPath, Filter)
  else
  begin
    try
      Result := SaveToFile(LastFileName);
      if Result then modified := false;
    except
      on E: Exception do
      begin

        raise;
      end;
    end;
  end;
end;

function TWPCustomRichText.CalcFilterIndex(filterStr: string; FileName: string): Integer;
var i, j: Integer;
  str: TStringList;
  one: Boolean;
begin
  if FileName = '' then
    FileName := Uppercase(ExtractFileExt(LastFileName))
  else FileName := Uppercase(ExtractFileExt(FileName));
  Result := 0;
  str := TStringList.Create;
  try
    j := 1;
    i := 1;
    one := FALSE;
    filterStr := filterStr + '|';
    while i < Length(filterStr) do
    begin
      if filterStr[i] = '|' then
      begin
        if one then
        begin
          str.Add(Copy(filterStr, j, i - j - 1));
          j := i + 1;
          one := FALSE;
        end else one := TRUE;
      end;
      inc(i);
    end;
    for i := 0 to str.Count - 1 do
    begin
      if Pos('*' + FileName, Uppercase(str[i])) > 0 then
      begin
        Result := i + 1;
        exit;
      end;
    end;
  finally
    str.Free;
  end;
end;

function TWPCustomRichText.SaveAs(InitPath: string = ''; Filter: string = ''): Boolean;
var
  dia: TSaveDialog;
  ext, def: string; i: Integer;
begin
  Result := FALSE;
  WorkOnText := wpBody;
  dia := TSaveDialog.Create(Self);
  try
    if Filter <> '' then
      dia.Filter := Filter
    else dia.Filter := WPLoadStr(meFilter);

    dia.Options := dia.Options + [ofNoChangeDir, ofOverwritePrompt];

    if InitPath <> '' then
      dia.InitialDir := InitPath else
      dia.InitialDir := InitialDir;
    if FInitialDir <> '' then
      dia.FileName := ExtractFileName(LastFileName)
    else
      dia.FileName := LastFileName;

    if DefaultIOFormat <> '' then def := DefaultIOFormat
    else def := TextSaveFormat;

    if Pos('HTML', def) = 1 then
    begin
      dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.HTM');
      dia.DefaultExt := '.HTM';
    end
    else if Pos('ANSI', def) = 1 then
    begin
      dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.TXT');
      dia.DefaultExt := '.TXT';
    end
    else if Pos('WPTOOLS', def) = 1 then
    begin
      dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.WPT');
      dia.DefaultExt := '.WPT';
    end
    else if Pos('RTF', def) = 1 then
    begin
      dia.FilterIndex := CalcFilterIndex(dia.Filter, 'a.RTF');
      dia.DefaultExt := '.RTF';
    end
    else dia.FilterIndex := CalcFilterIndex(dia.Filter, dia.FileName);

{$IFDEF USEEXECDIA}if ExecDialog(dia) then {$ELSE}
    if dia.Execute then {$ENDIF}
    begin
      ext := ExtractFileExt(dia.FileName);
      i := 1;
      // Invalidate only numbers as extension
      while (i <= Length(ext)) and (ext[i] in ['.', '0'..'9']) do inc(i);
      if i > Length(ext) then
      begin
        case dia.FilterIndex of
          2: dia.fileName := dia.FileName + '.HTM';
          3: dia.fileName := dia.FileName + '.TXT';
          4: dia.fileName := dia.FileName + '.WPT';
        else
          dia.fileName := dia.FileName + '.RTF';
        end;
      end
      //V5.20.5 - auto extension
{$IFDEF CREATE_AUTOEXTENSION} //should be off!
      else case dia.FilterIndex of
          2: if not SameText(ExtractFileExt(dia.FileName), '.HTM')
            and not SameText(ExtractFileExt(dia.FileName), '.HTML')
              and not SameText(ExtractFileExt(dia.FileName), '.XML') then
              dia.fileName := dia.FileName + '.HTM';
          3: if not SameText(ExtractFileExt(dia.FileName), '.TXT') then
              dia.fileName := dia.FileName + '.TXT';
          4: if not SameText(ExtractFileExt(dia.FileName), '.WPT') then
              dia.fileName := dia.FileName + '.WPT';
          1: if not SameText(ExtractFileExt(dia.FileName), '.RTF')
            and not SameText(ExtractFileExt(dia.FileName), '.DOC') then
              dia.fileName := dia.FileName + '.RTF';
        end;
{$ELSE}
      else
        if not SameText(ExtractFileExt(dia.FileName), '.HTM')
          and not SameText(ExtractFileExt(dia.FileName), '.HTML')
          and not SameText(ExtractFileExt(dia.FileName), '.WPT')
          and not SameText(ExtractFileExt(dia.FileName), '.RTF')
          and not SameText(ExtractFileExt(dia.FileName), '.DOC')
          and not SameText(ExtractFileExt(dia.FileName), '.TXT')
          and not SameText(ExtractFileExt(dia.FileName), '.XML')
        then case dia.FilterIndex of
            2: def := 'HTML' + '-__' + def; // Reuse the options defined in the format !
            3: def := 'ANSI' + '-__' + def;
            4: def := 'WPT' + '-__' + def;
            1: def := 'RTF' + '-__' + def;
          end
        else def := 'AUTO' + '-__' + def;
{$ENDIF}

      try
        Result := SaveToFile(dia.Filename, false, def);
        if Result then
          LastFileName := dia.FileName;
      except
        on E: Exception do
        begin

          raise;
        end;
      end;
    end;
    if Result then modified := false;
  finally;
    dia.Free;
  end;
end;

function TWPCustomRichText.InsertGraphicDialog(filter: string = '';
  InsertLink: Boolean = FALSE; ObjectModes: TWPTextObjModes = []):
  TWPObject;
var
  dia: TOpenPictureDialog;
  PaintPageNr, X, Y: Integer;
begin
  Result := nil;
  FInsertedObj := nil;
  if not ReadOnly then
  begin
    if Changing = FALSE then
    begin
      // LastError := ecNoChangeAllowed;
      exit;
    end;
    dia := TOpenPictureDialog.Create(Self);
    try
      dia.InitialDir := InitialDir;
{$IFDEF GRAPHICEX}
      if filter = '' then filter := WPLoadStr(meObjGraphicFilterExt);
{$ELSE}
      if filter = '' then filter := WPLoadStr(meObjGraphicFilter);
{$ENDIF}
      dia.Filter := filter;
      dia.Options := [ofNoChangeDir];
{$IFDEF USEEXECDIA}if ExecDialog(dia) then {$ELSE}
      if dia.Execute then {$ENDIF}
      begin
        Result := WPLoadObjectFromFile(Self, dia.FileName, InsertLink);
        FInitialDir := ExtractFilePath(dia.Filename);
        if Result <> nil then
        begin
          Result.WriteRTFMode := wobBoth;

          X := GetXPositionTw;
          {Result.Font.Style := [];
          Result.ParentColor := FALSE;
          Result.ParentFont := FALSE; }
          FInsertedObj := TextObjects.Insert(Result);
          if FInsertedObj <> nil then
          begin
            // Already done by 'Insert'!
            // txtobj.Width := Result.ContentsWidth;
            // txtobj.Height := Result.ContentsHeight;
            FInsertedObj.Mode :=
              FInsertedObj.Mode +
              (ObjectModes * [
              wpobjRelativeToParagraph, // old  wpotPar mode
                wpobjRelativeToPage, // old  wpotPar mode  (=HTML ALIGN=LEFT)
                wpobjPositionAtRight, // auto calc RelX to position at right (=HTML ALIGN=RIGHT)
                wpobjPositionAtCenter, // auto calc RelX to position at right (=HTML ALIGN=CENTER)
                wpobjPositionInMargin, // Position 0.2 cm from left or right border of the text, whatever margin is larger
                wpobjLockedPos, // This object cannot be moved
                wpobjSizingDisabled, // The user cannot change the width/height at all
                wpobjSizingAspectRatio]);

            if wpobjRelativeToParagraph in FInsertedObj.Mode then
            begin
              FInsertedObj.RelX := X; // calculated by GetXPositionTw BEFORE Insert
              if FMemo.GetXYPositionAtRTFTW(// margins included!
                FMemo.Cursor.RTFData,
                FMemo.Cursor.active_paragraph,
                0, PaintPageNr, X, Y, TRUE) then
              begin
                FInsertedObj.RelY := GetYPositionTw - Y;
                if FInsertedObj.RelY < 0 then FInsertedObj.RelY := 0;
              end;
            end else
              if wpobjRelativeToPage in FInsertedObj.Mode then
              begin
                FInsertedObj.RelX := X;
                FInsertedObj.RelY := GetYPositionTw;
              end;
          end else FreeAndNil(Result);
        end;
      end;
    finally
      dia.Free;
    end;
  end;
  if Result <> nil then ChangeApplied;
end;

function TWPCustomRichText.PrintDialog(PageRange: string = ''): Boolean;
{$IFDEF DISABLEPRINTER}
begin Result := FALSE;
end;
{$ELSE}
var
  dia: TPrintDialog;
  f, t, Copies, pw, ph: Integer;
  land, nh, nh2: Boolean;
  i: Integer;
  aPrintCtrl, aTempPrintCtrl: TWPCustomRTFEdit;
begin
  if WPNoPrinterInstalled then begin Result := FALSE; exit; end;
  if FIsDynamic then
    dia := TPrintDialog.Create(nil)
  else dia := TPrintDialog.Create(Self);

  Result := FALSE;
  nh := false;
{$IFDEF ALLOWWORDWRAPPRINT}
  nh2 := FALSE;
{$ELSE} // Need to change it NOW - otherwise the page count is not correct
  nh2 := WordWrap;
  if nh2 then
  begin
    WordWrap := FALSE;
    ReformatAll;
  end;
{$ENDIF}

  aTempPrintCtrl := nil;
  aPrintCtrl := Self;
  try
    if (IsSelected) and not (wpDontAllowSelectionPrinting in PrintParameter.PrintOptions) then
      dia.Options := [poPageNums, poSelection] //V5.18.1
    else
    begin // No text is selected, should we hide the merge fields?
      dia.Options := [poPageNums];
      if not InsertPointAttr.Hidden and (wpAlwaysHideFieldmarkers in PrintParameter.PrintOptions) then
      begin
        InsertPointAttr.Hidden := TRUE;
        ReformatAll;
        nh := TRUE;
      end;
    end;
    dia.PrintRange := prAllPages;
    dia.MinPage := 1;
    f := PageCount;
    if f <= 0 then f := 1;
    dia.MaxPage := f;
    dia.FromPage := 1;
    dia.ToPage := dia.MaxPage;
    dia.Copies := 1;
    dia.Collate := TRUE;

    UpdatePrinterProperties(Printer, 0); //V5.18.1 -  Inserted

    if FMemo.RTFData._LastReformatWasSpeedReformat then ReformatAll;
{$IFDEF USEEXECDIA}if ExecDialog(dia) then {$ELSE}
    if dia.Execute then {$ENDIF}
    begin
      if dia.PrintRange = prSelection then // Print the selected text
      begin
        aTempPrintCtrl := TWPCustomRTFEdit.CreateDynamic;
        // Option "-writeheaderfooter," would copy header+footer!
        aTempPrintCtrl.AsString := Self.AsANSIString('WPTOOLS', true);
        aTempPrintCtrl.AssignPrintProperties(Self);
        if wpAlwaysHideFieldmarkers in PrintParameter.PrintOptions then
          aTempPrintCtrl.InsertPointAttr.Hidden := TRUE;
        // This code would adjust the page numbering
        { aTempPrintCtrl.Memo.OverridePageCount := PageCount;
        aTempPrintCtrl.Memo.OverridePageOffset := Memo.GetPageWithSelectionStart;
        if aTempPrintCtrl.Memo.OverridePageOffset<0 then
           aTempPrintCtrl.Memo.OverridePageOffset := 0; }
        aTempPrintCtrl.ReformatAll; // Don't wait!
        aPrintCtrl := aTempPrintCtrl;
      end else // OK, no selection printing - NOW hide the merge fields!
      begin
        if not nh and not InsertPointAttr.Hidden and
          (wpAlwaysHideFieldmarkers in PrintParameter.PrintOptions) then
        begin
          InsertPointAttr.Hidden := TRUE;
          ReformatAll;
          nh := TRUE;
        end;
      end;

      pw := MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALWIDTH), 1440,
        GetDeviceCaps(Printer.Handle, LOGPIXELSX));
      ph := MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT), 1440,
        GetDeviceCaps(Printer.Handle, LOGPIXELSY));
      land := Printer.Orientation = poLandscape;

      // Update Page Size according to Printer --------------------------
      if (Abs(aPrintCtrl.Header.PageWidth - pw) < 2) or (Abs(aPrintCtrl.Header.PageHeight - ph) < 2)
        or (aPrintCtrl.Header.Landscape <> land) then
      begin
        aPrintCtrl.Header.BeginUpdate;
        aPrintCtrl.Header.Landscape := Printer.Orientation = poLandscape;
        aPrintCtrl.Header.PageWidth := pw;
        aPrintCtrl.Header.PageHeight := ph;
        aPrintCtrl.Header.EndUpdate;
        aPrintCtrl.ReformatAll; // Don't wait!
      end;
      // Update screeen ... (only if we are not printing the selection!)
      if aTempPrintCtrl = nil then
      begin
        FMemo._DBufferIsValid := FALSE;
        Paint;
        SetFocusValues(true);
      end;
      // PrintParameter.PageRange := wprAllPages;
      if dia.PrintRange = prAllPages then
      begin
        f := 1;
        t := aPrintCtrl.PageCount;
      end
      else {if dia.PrintRange=prPageNums  then   }
      begin
        f := dia.FromPage;
        t := dia.ToPage;
      end;
      if dia.Collate then
      begin
        Printer.Copies := 1;
        Copies := dia.Copies;
      end
      else
      begin
        Printer.Copies := dia.Copies;
        Copies := 1;
      end;
      for i := 1 to Copies do
      begin
        aPrintCtrl.PrintPages(f, t);
        Result := TRUE; // Copies =0 ???
      end;
    end;
  finally
    FreeAndNil(aTempPrintCtrl);
    dia.Free;
{$IFDEF ALLOWWORDWRAPPRINT}
    if nh2 then WordWrap := TRUE;
{$ENDIF}
    if nh and (wpAlwaysHideFieldmarkers in PrintParameter.PrintOptions) then
    begin
      InsertPointAttr.Hidden := FALSE;
      ReformatAll;
    end;
  end;
end;
{$ENDIF}

function TWPCustomRichText.PrinterSetup: Boolean;
{$IFDEF DISABLEPRINTER}
begin
  Result := FALSE;
end;
{$ELSE}
var
  dia: TPrinterSetupDialog;
begin
  if WPNoPrinterInstalled then begin Result := FALSE; exit; end;
  // Make sure the printer shows the current properties!
  UpdatePrinterProperties(Printer, 0, Header.PageWidth, Header.PageHeight);
  // And show the dialog
  if FIsDynamic then
    dia := TPrinterSetupDialog.Create(nil)
  else dia := TPrinterSetupDialog.Create(Self);

  try
{$IFDEF USEEXECDIA}Result := ExecDialog(dia); {$ELSE}
    Result := dia.Execute; {$ENDIF}
    if Result then
    begin
      ReadPrinterProperties;
    end;
  finally
    dia.Free;
  end;
end;
{$ENDIF}

procedure TWPCustomRichText.ReadPrinterProperties;
{$IFDEF DISABLEPRINTER}
begin
end;
{$ELSE}
begin
  if WPNoPrinterInstalled then exit;
  Header.Landscape := Printer.Orientation = poLandscape;
  Header.PageWidth :=
    MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALWIDTH), 1440,
    GetDeviceCaps(Printer.Handle, LOGPIXELSX));
  Header.PageHeight :=
    MulDiv(GetDeviceCaps(Printer.Handle, PHYSICALHEIGHT), 1440,
    GetDeviceCaps(Printer.Handle, LOGPIXELSY));
  if Visible then
  begin
    invalidate;
    SetFocusValues(true);
  end;
end;
{$ENDIF}

type
  TWPFindDialog = class(TFindDialog)
  public
    destructor Destroy; override;
  end;

  TWPReplaceDialog = class(TReplaceDialog)
  public
    destructor Destroy; override;
  end;

destructor TWPFindDialog.Destroy;
begin
  FFindDialog := nil;
  inherited Destroy;
end;

destructor TWPReplaceDialog.Destroy;
begin
  FReplaceDialog := nil;
  inherited Destroy;
end;

function TWPCustomRichText.FindDialog(initaltext : string = ''): Boolean;
begin
  if FReplaceDialog <> nil then FReplaceDialog.CloseDialog;
  if FFindDialog = nil then
    FFindDialog := TWPFindDialog.Create(Application);

  if initaltext<>'' then
  begin
  if initaltext='@SELECTED@' then
       FFindDialog.FindText := Copy(SelText,1,60)
  else FFindDialog.FindText := initaltext;
  end;

  FFindDialog.OnFind := OnFind;
  FFindDialog.OnClose := OnFindClose;
  FFindDialog.Options := [frDown];
{$IFDEF USEEXECDIA}Result := ExecDialog(FFindDialog); {$ELSE}
  Result := FFindDialog.Execute; {$ENDIF}
end;

function TWPCustomRichText.ReplaceDialog(initaltext : string = ''): Boolean;
begin
  if FFindDialog <> nil then FFindDialog.CloseDialog;
  if FReplaceDialog = nil then
    FReplaceDialog := TWPReplaceDialog.Create(Application);

  if initaltext<>'' then
  begin
  if initaltext='@SELECTED@' then
       FReplaceDialog.FindText := Copy(SelText,1,60)
  else FReplaceDialog.FindText := initaltext;
  end;

  FReplaceDialog.OnFind := OnFind;
  FReplaceDialog.OnClose := OnFindClose;
  FReplaceDialog.OnReplace := OnReplace;
  FReplaceDialog.Options := [];
  FReplaceDialog_last_was_search := FALSE;
  FReplaceDialog_last_sel_start := -1;
{$IFDEF USEEXECDIA}Result := ExecDialog(FReplaceDialog); {$ELSE}
  Result := FReplaceDialog.Execute; {$ENDIF}
end;

procedure TWPCustomRichText.OnFindClose(Sender: TObject);
begin
  IgnoreMouse;
end;

procedure TWPCustomRichText.OnFind(Sender: TObject);
var
  pos: Longint;
  len: Integer;
  foundatext, FContinue, done: Boolean;
label Nochmal; // :-)
begin
  done := FALSE;
  if (Sender is TFindDialog) or (Sender is TReplaceDialog) then
    with Sender as TFindDialog do
    begin
      with Finder do
      begin
        CharAttr.Clear;
        EndAtWord := FALSE;
        EndAtSpace := FALSE;
        pos := CPPosition;
        Position := pos;
        if frDown in TFindDialog(Sender).Options then
          done := pos = 0;
        WildCard := '*';
        Nochmal:
        WholeWord := frWholeWord in TFindDialog(Sender).Options;
        CaseSensitive := (frMatchCase in TFindDialog(Sender).Options);
        if frDown in TFindDialog(Sender).Options then
          foundatext := Next(TFindDialog(Sender).FindText)
        else
          foundatext := Prev(TFindDialog(Sender).FindText);
        if foundatext then
        begin
          pos := FoundPosition;
          len := FoundLength;
          SetSelPosLen(pos, len);
          if frDown in TFindDialog(Sender).Options then
            CPPosition := pos + len
          else
            CPPosition := pos;
          ShowCursor;
          FReplaceDialog_last_was_search := TRUE;
          FReplaceDialog_last_sel_start := pos;
        end
        else if not done and Assigned(OnTextNotFound) then
        begin
          FContinue := FALSE;
          FOnTextNotFound(Self, FContinue);
          if FContinue then
          begin
            done := TRUE;
            if frDown in TFindDialog(Sender).Options then
              ToStart
            else ToEnd;
            goto Nochmal;
          end;
        end else
          MessageBox(Handle, PChar(WPLoadStr(meTextNotFound)), '', MB_OK);
        IgnoreMouse;
      end;
    end;
end;

procedure TWPCustomRichText.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
  begin
{$IFNDEF NOTOOLBAR}if AComponent = WPToolBar then WPToolBar := nil
    else {$ENDIF}if AComponent = WPRuler then WPRuler := nil
      else if AComponent = VRuler then VRuler := nil
      else if AComponent = WPGutter then WPGutter := nil
      else if AComponent = ActionList then FActionList := nil; // was: ActionList := nil;
  end;
  inherited Notification(AComponent, Operation);
end;

//8.7.2005: JZ, undo, replace in selection only, replace all works with complete text (V5.17.3)

procedure TWPCustomRichText.OnReplace(Sender: TObject);
var
  pos, len, nCountReplaces: Integer;
  sel_start, sel_length: Integer;
  afound : Boolean;
begin
  len := 0;
  nCountReplaces := 0;
  sel_start := SelStart;
  sel_length := SelLength;
  Finder.WildCard := '*';
  Finder.WholeWord := frWholeWord in TReplaceDialog(Sender).Options;
  Finder.CaseSensitive := (frMatchCase in TReplaceDialog(Sender).Options);

  if FReplaceDialog_last_was_search and
    (sel_start = FReplaceDialog_last_sel_start) then
  begin
    if not (frReplaceAll in TReplaceDialog(Sender).Options) and IsSelected then
    begin
      Changing;
      SelText := TReplaceDialog(Sender).ReplaceText;
      if not TextCursor._SectionIsProtected then
        Finder.Position := sel_start + Length(TReplaceDialog(Sender).ReplaceText);
      {$IFNDEF REPLACEPROTECTED} //V5.44
      repeat
          afound := Finder.Next(TReplaceDialog(Sender).FindText);
      until (not afound or not (wpNoDeleteChar in Memo.IsProtected(
            Finder.FoundParagraph,  Finder.FoundPosition, false)) );
      {$ELSE}
      afound := Finder.Next(TReplaceDialog(Sender).FindText);
      {$ENDIF}
      if afound then
      begin
        FReplaceDialog_last_was_search := TRUE;
        FReplaceDialog_last_sel_start := Finder.FoundPosition;
        SetSelPosLen(FReplaceDialog_last_sel_start, Finder.FoundLength); // V5.12.1
      end else
      begin
        MessageBox(Handle, PChar(WPLoadStr(meTextNotFound)), '', MB_OK);
      end;
      exit;
    end;
    sel_length := 0;
    sel_start := 0;
  end;

  if Sender is TReplaceDialog then
  try
    with Finder do
    begin
      CharAttr.Clear;
      EndAtWord := FALSE;
      EndAtSpace := FALSE;

      if sel_length > 0 then
      begin
        Position := sel_start;
        pos := sel_start;
        _EndPar := TextCursor.GetBlockEnd(_EndPosInPar);
      end
      else
      begin
        pos := CPPosition;
        Position := pos;
        _EndPar := nil;
      end;

      if (FoundLength = 0) and not
        (frReplaceAll in TReplaceDialog(Sender).Options) then
      begin
      {$IFNDEF REPLACEPROTECTED} //V5.44
      repeat
          afound := Finder.Next(TReplaceDialog(Sender).FindText);
      until (not afound or not (wpNoDeleteChar in Memo.IsProtected(
            Finder.FoundParagraph,  Finder.FoundPosition, false)) );
      {$ELSE}
      afound := Finder.Next(TReplaceDialog(Sender).FindText);
      {$ENDIF}
        if afound then
        begin
          Changing;
          FReplaceDialog_last_was_search := TRUE;
          FReplaceDialog_last_sel_start := FoundPosition;
          SetSelPosLen(FReplaceDialog_last_sel_start, FoundLength); // V5.12.1
          sel_length := 0;
        end else
        begin
          MessageBox(Handle, PChar(WPLoadStr(meTextNotFound)), '', MB_OK);
          exit;
        end;
      end;

      if (sel_length = 0) and (SelLength > 0) then
      begin
        pos := SelStart;
        len := Length(TReplaceDialog(Sender).ReplaceText);
        SelText := TReplaceDialog(Sender).ReplaceText;
        inc(nCountReplaces);
        SetSelPosLen(pos, len);
        Position := pos + len;
        ChangeApplied;
      end;
      if frReplaceAll in TReplaceDialog(Sender).Options then
      try
        HeaderFooter.StartUndolevel;
        WildCard := '*';
{$IFNDEF REPLACEALL_FROM_CP}
        if sel_length = 0 then ToStart; // FROM START!!!
{$ENDIF}
        nCountReplaces := nCountReplaces + ReplaceAll(TReplaceDialog(Sender).FindText, TReplaceDialog(Sender).ReplaceText);
        Refresh;
        ChangeApplied;
        if nCountReplaces <= 0 then
          MessageBox(Handle, PChar(WPLoadStr(meTextNotFound)), '', MB_OK)
        else MessageBox(Handle,
            PChar(Format(WPLoadStr(meTextFoundAndReplaced), [nCountReplaces])), '', MB_OK);
      finally
        HeaderFooter.EndUndolevel;
      end;

      if frDown in TReplaceDialog(Sender).Options then
        CPPosition := pos + len
      else
        CPPosition := pos;
      Position := pos;
    end;
  finally
    Finder._EndPar := nil;
  end;
end;

function TWPCustomRichText.EditHyperlink(linktext: string = ''): Boolean;
var obj: TWPTextObj;
  s: string;
begin
  obj := HyperlinkAtCP;
  if obj <> nil then s := obj.Source
  else s := '';
  FKeyInLock := true;
  try
    if InputQuery(WPLoadStr(wpInsertHyperlink), WPLoadStr(wpInsertHyperlink_URL), s) then
    begin
      if obj <> nil then obj.Source := s
      else if IsSelected then
        InputHyperlink(s)
      else if linktext = '' then //V5.26
        InputHyperlink(s, s) //V5.26
      else InputHyperlink(linktext, s);
      Result := TRUE;
    end else
      Result := FALSE;
  finally
    FKeyInLock := false;
  end;
end;


function TWPCustomRichText.BookmarkEdit(initialname : string = ''): Boolean;
var obj: TWPTextObj;
  s: string;
begin
  obj := BookmarkAtCP;
  if obj <> nil then s := obj.Name
  else s := initialname;
  if InputQuery(WPLoadStr(wpInsertBookmark), WPLoadStr(wpInsertBookmark_Name), s) then
  begin
    if obj <> nil then obj.Name := s
    else BookmarkInput(s, false);
    Result := TRUE;
  end else
    Result := FALSE;
end;

function TWPCustomRichText.DeleteMarkedChar(InAllText: Boolean = TRUE): Boolean;
var par: TParagraph;
begin
  Result := FALSE;
  if InAllText then
  begin
    par := Memo.RTFData.FirstPar;
    while par <> nil do
    begin
      if par.DeleteMarkedChar then Result := TRUE;
      par := par.globalnext;
    end;
  end else
    if (TextCursor.RTFdata <> nil) and not (TextCursor.RTFdata.Empty) then
    begin
      par := TextCursor.RTFdata.FirstPar;
      while par <> nil do
      begin
        if par.DeleteMarkedChar then Result := TRUE;
        par := par.next;
      end;
    end;
  if Result then DelayedReformat;
end;

function TWPCustomRichText.SetCharacterSet(FromChar, ToChar: Integer; FontName: string; CharSet: Integer): Integer;
var par: TParagraph;
  newca, lastca, ca: Cardinal;
  attr: TWPStoredCharAttrInterface;
  c, i: Integer;
begin
  attr := TWPStoredCharAttrInterface.Create(RTFData.RTFProps);
  lastca := $FFFFFFFF; // undefined for start
  newca := 0;
  Result := 0;
  try
    par := Memo.RTFData.FirstPar;
    while par <> nil do
    begin
      for i := 0 to par.CharCount - 1 do
      begin
        c := Integer(par.CharItem[i]);
        if (c >= FromChar) and (c <= ToChar) then
        begin
          ca := par.CharAttr[i] and $FFFFFF;
          if (ca <> lastca) then
          begin
            attr.CharAttr := ca;
            lastca := ca;
            if FontName <> '' then
              attr.SetFontName(FontName);
            attr.SetFontCharSet(CharSet);

            attr.SetColor(clRed);

            newca := attr.CharAttr;
          end;
          par.CharAttr[i] := (par.CharAttr[i] and $FF000000) or newca;
          inc(Result);
        end;
      end;
      par := par.globalnext;
    end;
  finally
    attr.Free;
  end;
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// depreciated "FAST" procedures
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

procedure TWPCustomRichText.FastResetParagraph;
begin
  ActivePar.ClearProps;
end;

procedure TWPCustomRichText.FastResetAttr;
begin
  Memo.RTFData.DefaultAttr.Clear;
end;

function TWPCustomRichText.FastInputParagraph: TParagraph;
var acell: TParagraph;
begin
  CheckHasBody;
  if ActiveText.Empty or (TextCursor.active_paragraph = nil) then
  begin
    Result := ActiveText.AppendNewPar;
    Memo.Cursor.MoveTo(Result, 0, false);
  end else
  begin
    acell := TextCursor.active_paragraph.Cell;
    if acell <> nil then
    begin
      Result := TParagraph.Create(ActiveText);
      include(Result.prop, paprIsTable);
      acell.NextPar := Result;
    end else
    begin
      Result := TParagraph.Create(ActiveText);
      TextCursor.active_paragraph.NextPar := Result;
    end;
    Memo.Cursor.MoveTo(Result, 0, false);
  end;
end;

function TWPCustomRichText.FastAppendParagraph: TParagraph;
begin
  CheckActiveText;
  Result := ActiveText.AppendNewPar;
  Memo.Cursor.MoveTo(Result, 0, false);
end;

// only for compatibility with V4

function TWPCustomRichText.FastInsertParagraph: Boolean;
begin
  InputParagraph;
  Result := TRUE;
end;

function TWPCustomRichText.InputParagraphChild: TParagraph;
var par: TParagraph;
begin
  if IsEmpty then
  begin
    CheckActiveText;
    Result := ActiveText.AppendNewPar;
  end else
  begin
    par := ActivePar;
    if ActivePosInPar < par.CharCount then
      par.SplitAt(ActivePosInPar, true);
    Result := TParagraph.Create(par.RTFData);
    par.ChildPar := Result;
  end;
  Memo.Cursor.MoveTo(Result, 0, false);
end;

function TWPCustomRichText.FastDeleteParagraph: Boolean;
var npar: TParagraph;
begin
  if not IsEmpty then
  begin
    CheckActiveText;
    npar := ActivePar.DeleteParagraph;
    Memo.Cursor.MoveTo(npar, 0, false);
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRichText.FastMoveParagraph(Dest: TParagraph; after: Boolean): Boolean;
begin
  if ActivePar <> Dest then
  begin
    if after then
      Dest.NextPar := ActivePar
    else Dest.PrevPar := ActivePar;
    Result := TRUE;
  end else Result := FALSE;
end;

function TWPCustomRichText.FastDeleteLine: Boolean;
var lin: Integer;
begin
  with Memo.Cursor do
  begin
    if ActivePar.LineCount <= 1 then
    begin
      ActivePar.ClearText(false);
      ActivePar.DeleteParagraphEnd;
      Result := FALSE;
    end else
    begin
      lin := ActivePar.LineOfPos(active_posinpar);
      Result := ClearTextInbetween(ActivePar, ActivePar.LineOffset(lin),
        ActivePar, ActivePar.LineEndOffset(lin));
    end;
  end;
end;

procedure TWPCustomRichText.FastSetPageBreak(yes: Boolean; ReuseParInAppendText: Boolean = TRUE);
var par: TParagraph;
begin
  // Not in first line !
  par := ActivePar;
  if (par.prev <> nil) and yes then include(par.prop, paprNewPage)
  else exclude(par.prop, paprNewPage);
  if ReuseParInAppendText then
    include(par.prop, paprCanRemoveInAppend);
end;

procedure TWPCustomRichText.FastApplyPProp(par: TParagraph; const prp: TParProps;
  Options: TParPropsOptions = [
  ppoIndentFirst, ppoindentleft, ppoindentright,
    ppospacebefore, ppospaceafter, ppospacebetween,
    ppoalign, ppoborderType, ppocolor, pposhading {, ppoNewPage}, ppoParID]);
var
  i: Integer;
begin
  if par = nil then exit;
  if ppoEnabled in prp.Options then
    Options := prp.Options;
  if ppoIndentFirst in Options then
    par.ASet(WPAT_IndentFirst, prp.indentfirst);
  if ppoindentleft in Options then
    par.ASet(WPAT_IndentLeft, prp.indentleft);
  if ppoindentright in Options then
    par.ASet(WPAT_IndentRight, prp.indentright);
  if ppospacebefore in Options then
    par.ASet(WPAT_SpaceBefore, prp.spacebefore);
  if ppospaceafter in Options then
    par.ASet(WPAT_SpaceAfter, prp.spaceafter);
  if ppospacebetween in Options then
  begin
    if ppoMultSpacing in Options then
    begin
      par.ADel(WPAT_SpaceBetween);
      par.ASet(WPAT_LineHeight, MulDiv(prp.spacebetween, 100, 240));
    end
    else
    begin
      par.ADel(WPAT_LineHeight);
      par.ASet(WPAT_SpaceBetween, prp.spacebetween);
    end;
  end;
  if ppoalign in Options then
    par.ASet(WPAT_Alignment, Integer(prp.align));
  if ppoborderType in Options then
    par.ASetBorder(prp.BorderType);
  { if ppotabs in Options then
    par.tabs := prp.Tab;  }
  if ppocolor in Options then
    par.ASet(WPAT_FGColor, prp.Color);
  if pposhading in Options then
    par.ASet(WPAT_ShadingValue, prp.Shading);
  if ppoNewPage in Options then
    include(par.prop, paprNewPage)
  else
    exclude(par.prop, paprNewPage);
  if ppoParProtected in Options then
  begin
    if prp.ParProtected then
      par.ASet(WPAT_ParProtected, 1)
    else
      par.ADel(WPAT_ParProtected);
  end;
  { easier support for tabs }
  if ppoTabsList in Options then
    for i := 0 to Length(prp.TabsPosList) - 1 do
      if prp.TabsPosList[i] > 0 then
        par.TabstopAdd(prp.TabsPosList[i], prp.TabsKindList[i]);
  if ppoParID in Options then
    par.ASet(WPAT_ParID, prp.ID);
  if ppoCellAlign in Options then
  begin
    if prp.CellAlignCenter then
      par.ASet(WPAT_VertAlignment, Integer(paralVertCenter))
    else if prp.CellAlignBottom then
      par.ASet(WPAT_VertAlignment, Integer(paralVertBottom))
    else par.ADel(WPAT_VertAlignment);
  end;
end;

function TWPCustomRichText.FastGetCharAttrFromOldAttr(const Attr: TAttr): Cardinal;
var FFastCharAttr: TWPStoredCharAttrInterface;
begin
  FFastCharAttr := TWPStoredCharAttrInterface.Create(Memo.RTFData);
  try
    FFastCharAttr.SetFont(Attr.Font);
    if Attr.Color <> 0 then FFastCharAttr.SetColorNr(Attr.Color);
    if Attr.BGColor <> 0 then FFastCharAttr.SetBGColorNr(Attr.BGColor);
    if Attr.Style <> [] then FFastCharAttr.SetStyles(Attr.Style);
    if Attr.CharSet <> 0 then FFastCharAttr.SetFontCharset(Attr.CharSet);
    if Attr.Size <> 0 then FFastCharAttr.SetFontSize(Attr.Size);
    Result := FFastCharAttr.CharAttr;
  finally
    FFastCharAttr.Free;
  end;
end;

procedure TWPCustomRichText.FastInputText(const prp: TParProps);
var par: TParagraph;
  charattr: Cardinal;
i: Integer; pa: PTAttr; 
begin
  par := ActivePar;
  FastApplyPProp(par, prp);

  if prp.pa <> nil then
  begin
    pa := prp.pa;
    if prp.wText <> '' then
      for i := 0 to Length(prp.Text) do
      begin
        par.Insert(par.CharCount, prp.Text[i], FastGetCharAttrFromOldAttr(pa^));
        inc(pa);
      end
    else if prp.Text <> '' then
      for i := 0 to Length(prp.wText) do
      begin
        par.Insert(par.CharCount, prp.wText[i], FastGetCharAttrFromOldAttr(pa^));
        inc(pa);
      end;
  end
  else

  begin
    charattr := FastGetCharAttrFromOldAttr(prp.Attr);
    if prp.wText <> '' then
      par.Insert(par.CharCount, prp.wText, charattr)
    else if prp.Text <> '' then
      par.Insert(par.CharCount, prp.Text, charattr)
  end;
end;

procedure TWPCustomRichText.FastSetText(par: TParagraph; const prp: TParProps);
var w: WideString;
  charattr: Cardinal;
  i: Integer;
pa: PTAttr; 
begin
  if prp.parr <> nil then
  begin
    if prp.wText <> '' then
      for i := 1 to Length(prp.Text) do
      begin
        par.Insert(par.CharCount, prp.Text[i], FastGetCharAttrFromOldAttr(prp.parr[i]));
      end
    else if prp.Text <> '' then
      for i := 1 to Length(prp.Text) do
      begin
        par.Insert(par.CharCount, prp.Text[i], FastGetCharAttrFromOldAttr(prp.parr[i]));
      end;
  end

  else if prp.pa <> nil then
  begin
    pa := prp.pa;
    if prp.wText <> '' then
      for i := 1 to Length(prp.Text) do
      begin
        par.Insert(par.CharCount, prp.Text[i], FastGetCharAttrFromOldAttr(pa^));
        inc(pa);
      end
    else if prp.Text <> '' then
      for i := 1 to Length(prp.Text) do
      begin
        par.Insert(par.CharCount, prp.Text[i], FastGetCharAttrFromOldAttr(pa^));
        inc(pa);
      end;
  end
  else

  begin
    charattr := FastGetCharAttrFromOldAttr(prp.Attr);
    if prp.wText <> '' then
      par.SetText(prp.wText, charattr)
    else
      if prp.Text <> '' then
      begin
        w := prp.Text;
        par.SetText(w, charattr);
      end;
  end;
end;

procedure TWPCustomRichText.FastAddText(const prp: TParProps);
var par: TParagraph;
begin
  par := FastInputParagraph;
  if par = nil then
    par := FastInputParagraph;
  FastApplyPProp(par, prp);
  FastSetText(par, prp);
end;

procedure TWPCustomRichText.FastAddTable(col: Integer; Pprp: PTParProps);
var wptable: TParagraph;
  wprowstyle: TWPTableRowStyle;
  cell, par: TParagraph;
  i: Integer;
begin
  if col <= 0 then exit;
  cell := nil;
  wptable := Table;
  if (wptable = nil) or FBeginTable and FBeginTableCreate then
  begin
    CheckActiveText;
    par := ActiveParagraph;
    if (par <> nil) and (par.next <> nil) then
      wptable := TParagraph.CreateTable(par) else //V5.20.8a
      wptable := ActiveText.CreateTable(nil);
    FBeginTableCreate := FALSE;
    wptable.Name := FBeginTableName;
  end;
  wprowstyle := wptable.CreateRow(nil, true);
  try
    for i := 0 to col - 1 do
    begin
      cell := wprowstyle.InputCell;
      if Pprp <> nil then
      begin
        FastApplyPProp(cell, Pprp^);
        if Pprp.Width_PC <> 0 then
          cell.ASet(WPAT_COLWIDTH_PC, Pprp.Width_PC)
        else if Pprp.Width_TW <> 0 then
          cell.ASet(WPAT_COLWIDTH, Pprp.Width_TW)
        else if Pprp.CWidth <> 0 then
          cell.ASet(WPAT_COLWIDTH_PC, MulDiv(Pprp.CWidth, 10000, 255))
        else cell.ASet(WPAT_COLWIDTH_PC, 10000 div col);
        FastSetText(cell, Pprp^);
        inc(Pprp);
      end;
    end;
    Memo.Cursor.MoveTo(cell, 0);
  finally
    wptable.EndRow(wprowstyle);
  end;
end;

procedure TWPCustomRichText.FastAddTable(col: Integer; const Pprp: array of TParProps);
var wptable: TParagraph;
  wprowstyle: TWPTableRowStyle;
  cell: TParagraph;
  i, c: Integer;
begin
  if col <= 0 then exit;
  cell := nil;
  wptable := Table;
  if (wptable = nil) or FBeginTable and FBeginTableCreate then
  begin
    CheckActiveText;
    wptable := ActiveText.CreateTable(nil);
    FBeginTableCreate := FALSE;
    wptable.Name := FBeginTableName;
  end;
  wprowstyle := wptable.CreateRow(nil, true);
  try
    c := 0;
    for i := 0 to col - 1 do
    begin
      cell := wprowstyle.InputCell;
      if Length(Pprp) > 0 then
      begin
        FastApplyPProp(cell, Pprp[c]);
        if Pprp[c].Width_PC <> 0 then
          cell.ASet(WPAT_COLWIDTH_PC, Pprp[c].Width_PC)
        else if Pprp[c].Width_TW <> 0 then
          cell.ASet(WPAT_COLWIDTH, Pprp[c].Width_TW)
        else if Pprp[c].CWidth <> 0 then
          cell.ASet(WPAT_COLWIDTH_PC, MulDiv(Pprp[c].CWidth, 10000, 255))
        else cell.ASet(WPAT_COLWIDTH_PC, 10000 div col);
        FastSetText(cell, Pprp[c]);
        if c < Length(Pprp) - 1 then inc(c);
      end;
    end;
    Memo.Cursor.MoveTo(cell, 0);
  finally
    wptable.EndRow(wprowstyle);
  end;
end;

procedure TWPCustomRichText.FastCopyProperties(source: TObject);
begin
  //OBSOLETE!
  Header.Assign((source as TWPCustomRichText).Header);
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPSetModeControl (TWPCustomRichText.CurrAttr)
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

constructor TWPSetModeControl.Create(aOwner: TWPCustomRtfEdit);
begin
  inherited Create;
  FRichText := aOwner;
end;

destructor TWPSetModeControl.Destroy;
begin
  inherited Destroy;
end;

{ RichText.FMemo.Cursor requires a RTFData to be attached to the
  RTF engine so we executed this in the latest possible moment! }

function TWPSetModeControl.GetCursor: TWPRTFDataCursor;
begin
  if FCursor = nil then
    FCursor := FRichText.Memo.Cursor;
  Result := FCursor;
end;

function TWPSetModeControl.GetRTFProps: TWPRTFProps;
begin
  if FCursor = nil then
    FCursor := FRichText.Memo.Cursor;
  Result := FCursor.RTFProps;
end;

function TWPSetModeControl.AGet(WPAT_Code: Byte; var Value: Integer): Boolean;
begin
  if Cursor.IsSelected then
  begin
    Result := Cursor.SelectedTextAttr.AGet(WPAT_Code, Value);
  end
  else Result := Cursor.WritingTextAttr.AGet(WPAT_Code, Value);
  {$IFNDEF DONT_REPORT_DEFAULT_ATTR}
  if not Cursor.IsSelected or DefaultAttrAlsoForSelectedText then begin
  if not Result and (Cursor.active_paragraph<>nil) then
       Result := Cursor.active_paragraph.AGetInherited(WPAT_Code, Value);
  end;
  {$ENDIF}
end;

// Used to update GUI
function TWPSetModeControl.AGetDefault(WPAT_Code: Byte; Value: Integer = 0): Integer;
var b : Boolean;
begin
  if Cursor.IsSelected then
       b := Cursor.SelectedTextAttr.AGet(WPAT_Code, Result)
  else b := Cursor.WritingTextAttr.AGet(WPAT_Code, Result);  
  {$IFNDEF DONT_REPORT_DEFAULT_ATTR}
  if not Cursor.IsSelected or DefaultAttrAlsoForSelectedText then begin
  if not b and (Cursor.active_paragraph<>nil) then
       b := Cursor.active_paragraph.AGetInherited(WPAT_Code, Result);
  end;
  {$ENDIF}
  if not b then Result := Value;
end;

procedure TWPSetModeControl.ADel(WPAT_Code: Byte);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.ADel(WPAT_Code)
  else Cursor.WritingTextAttr.ADel(WPAT_Code);
end;

procedure TWPSetModeControl.ASet(WPAT_Code: Byte; Value: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.ASet(WPAT_Code, Value)
  else if FRichText.CheckHasBody then
    Cursor.WritingTextAttr.ASet(WPAT_Code, Value);
end;

procedure TWPSetModeControl.BeginUpdate;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.BeginUpdate
  else if FRichText.CheckHasBody then
    Cursor.WritingTextAttr.BeginUpdate;
end;

function TWPSetModeControl.EndUpdate: Boolean;
begin
  if Cursor.IsSelected then
  begin
    Result := Cursor.SelectedTextAttr.EndUpdate;
  end
  else Result := Cursor.WritingTextAttr.EndUpdate;
end;

procedure TWPSetModeControl.Assign(Source: TPersistent);
begin
  if Source is TWPSetModeControl then
  begin
    BeginUpdate;
    try
      Alignment := TWPSetModeControl(Source).Alignment;
    // BorderProp := TWPSetModeControl(Source).BorderProp;
      Color := TWPSetModeControl(Source).Color;
      BKColor := TWPSetModeControl(Source).BKColor;
      FontName := TWPSetModeControl(Source).FontName;
    { FontNr	  := TWPSetModeControl(Source).FontNr ; }
      OutlineLevel := TWPSetModeControl(Source).OutlineLevel;
    // OutlineStyle := TWPSetModeControl(Source).OutlineStyle;
      OutlineMode := TWPSetModeControl(Source).OutlineMode;
      Size := TWPSetModeControl(Source).Size;
      ParColor := TWPSetModeControl(Source).ParColor;
      IndentLeft := TWPSetModeControl(Source).IndentLeft;
      IndentRight := TWPSetModeControl(Source).IndentRight;
      IndentFirst := TWPSetModeControl(Source).IndentFirst;
      SpaceBefore := TWPSetModeControl(Source).SpaceBefore;
      SpaceAfter := TWPSetModeControl(Source).SpaceAfter;
      if TWPSetModeControl(Source).LineHeight <> 0 then
        LineHeight := TWPSetModeControl(Source).LineHeight
      else SpaceBetween := TWPSetModeControl(Source).SpaceBetween;
      ParId := TWPSetModeControl(Source).ParID;

    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TWPSetModeControl.SetFontCharset(const fontname: string; charset: Integer);
begin
  BeginUpdate;
  Self.FontName := fontname;
  Self.Charset := charset;
  EndUpdate;
end;

function TWPSetModeControl.GetIndentFirst: Longint;
begin
  Result := AGetDefault(WPAT_IndentFirst);
end;

function TWPSetModeControl.GetIndentRight: Longint;
begin
  Result := AGetDefault(WPAT_IndentRight);
end;

function TWPSetModeControl.GetIndentLeft: Longint;
begin
  Result := AGetDefault(WPAT_IndentLeft);
end;

procedure TWPSetModeControl.SetIndentFirst(x: Longint);
begin
  ASet(WPAT_IndentFirst, x);
end;

procedure TWPSetModeControl.SetIndentRight(x: Longint);
begin
  ASet(WPAT_IndentRight, x);
end;

procedure TWPSetModeControl.SetIndentLeft(x: Longint);
begin
  ASet(WPAT_IndentLeft, x);
end;

procedure TWPSetModeControl.SetParId(x: Integer);
begin
  ASet(WPAT_ParID, x);
end;

procedure TWPSetModeControl.HidePar(Status: Boolean);
begin
  if Cursor.IsSelected then
  begin
    if Status then
      Cursor.SelectedTextAttr.ASetAdd(WPAT_Visibility, WPVIS_Hidden)
    else
      Cursor.SelectedTextAttr.ASetDel(WPAT_Visibility, WPVIS_Hidden);
  end
  else
  begin
    if Status then
      Cursor.WritingTextAttr.ASetAdd(WPAT_Visibility, WPVIS_Hidden)
    else
      Cursor.WritingTextAttr.ASetDel(WPAT_Visibility, WPVIS_Hidden);
  end;
end;

procedure TWPSetModeControl.SetNoWordWrapInPar(Status: Boolean);
begin
  if Cursor.IsSelected then
  begin
    if Status then
      Cursor.SelectedTextAttr.ASetAdd(WPAT_CELLFlags, WPCELL_NOWORDWRAP)
    else
      Cursor.SelectedTextAttr.ASetDel(WPAT_CELLFlags, WPCELL_NOWORDWRAP);
  end
  else
  begin
    if Status then
      Cursor.WritingTextAttr.ASetAdd(WPAT_CELLFlags, WPCELL_NOWORDWRAP)
    else
      Cursor.WritingTextAttr.ASetDel(WPAT_CELLFlags, WPCELL_NOWORDWRAP);
  end;
end;

function TWPSetModeControl.GetParId: Integer;
begin
  Result := AGetDefault(WPAT_ParID);
end;

function TWPSetModeControl.GetStyleName: string;
begin
  Result := FRichText.ActiveStyleName;
end;

procedure TWPSetModeControl.ClearAttr(ParAttr, CharAttr: Boolean);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.ClearAttr(ParAttr, CharAttr)
  else
    Cursor.WritingTextAttr.ClearAttr(ParAttr, CharAttr);
end;

procedure TWPSetModeControl.SetStyleName(const x: string);
begin
  FRichText.ActiveStyleName := x;
end;

function TWPSetModeControl.GetSpaceBefore: Longint;
begin
  Result := AGetDefault(WPAT_SpaceBefore);
end;

function TWPSetModeControl.GetSpaceBetween: Longint;
begin
  Result := AGetDefault(WPAT_SpaceBetween);
end;

function TWPSetModeControl.GetLineHeight: Longint;
begin
  Result := AGetDefault(WPAT_LineHeight);
end;

function TWPSetModeControl.GetSpaceAfter: Longint;
begin
  Result := AGetDefault(WPAT_SpaceAfter);
end;

procedure TWPSetModeControl.SetSpaceBefore(x: Longint);
begin
  ASet(WPAT_SpaceBefore, x);
end;

procedure TWPSetModeControl.SetSpaceBetween(x: Longint);
begin
  ADel(WPAT_LineHeight);
  ASet(WPAT_SpaceBetween, x);
end;

procedure TWPSetModeControl.SetLineHeight(x: Longint);
begin
  ADel(WPAT_SpaceBetween);
  ASet(WPAT_LineHeight, x);
end;

procedure TWPSetModeControl.SetSpaceAfter(x: Longint);
begin
  ASet(WPAT_SpaceAfter, x);
end;

function TWPSetModeControl.GetAlign: TParAlign;
begin
  Result := TParAlign(AGetDefault(WPAT_Alignment, 0));
end;

procedure TWPSetModeControl.SetAlign(x: TParAlign);
begin
  ASet(WPAT_Alignment, Integer(x));
end;

function TWPSetModeControl.GetVertAlign: TParVertAlign;
begin
  Result := TParVertAlign(AGetDefault(WPAT_VertAlignment, 0));
end;

procedure TWPSetModeControl.SetVertAlign(x: TParVertAlign);
begin
  ASet(WPAT_VertAlignment, Integer(x));
end;

function TWPSetModeControl.GetParColor: Integer;
var a: Integer;
begin
  Result := AGetDefault(WPAT_FGColor, 0);
  if (AGet(WPAT_ShadingValue, a) and (a = 0)) or
    (AGet(WPAT_ShadingType, a) and (a = WPSHAD_solidbg)) then
    Result := AGetDefault(WPAT_BGColor, Result);
end;

procedure TWPSetModeControl.SetParColor(x: Integer);
begin
  if x <= 0 then
  begin
    ADel(WPAT_FGColor);
    ADel(WPAT_BGColor);
  end
  else
  begin
    ADel(WPAT_ShadingType);
    ASet(WPAT_FGColor, x);
    ASet(WPAT_BGColor, x);
  end;
end;

function TWPSetModeControl.GetParShading: Integer;
begin
  Result := AGetDefault(WPAT_ShadingValue, 0);
end;

procedure TWPSetModeControl.SetParShading(x: Integer);
begin
  if (x <= 0) or (x >= 100) then ADel(WPAT_ShadingValue)
  else ASet(WPAT_ShadingValue, x);
end;

function TWPSetModeControl.GetTabPosition(index: integer): Longint;
var Kind: TTabKind; FillMode: TTabFill; FillColor: Integer;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopGet(index, Result, Kind, FillMode, FillColor)
  else Cursor.WritingTextAttr.TabstopGet(index, Result, Kind, FillMode, FillColor);
end;

function TWPSetModeControl.GetTabKind(index: integer): TTabKind;
var Value: Integer; FillMode: TTabFill; FillColor: Integer;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopGet(index, Value, Result, FillMode, FillColor)
  else Cursor.WritingTextAttr.TabstopGet(index, Value, Result, FillMode, FillColor);
end;

function TWPSetModeControl.GetTabFill(index: integer): TTabFill;
var Value: Integer; Kind: TTabKind; FillColor: Integer;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopGet(index, Value, Kind, Result, FillColor)
  else Cursor.WritingTextAttr.TabstopGet(index, Value, Kind, Result, FillColor);
end;

function TWPSetModeControl.GetTabCount: Integer;
begin
  if Cursor.IsSelected then
    Result := Cursor.SelectedTextAttr.TabstopCount
  else Result := Cursor.WritingTextAttr.TabstopCount;
end;

procedure TWPSetModeControl.SetCellName(const x: string);
var i: Integer;
begin
  i := Cursor.RTFProps.AStringToNumber(x);
  ASet(WPAT_PAR_NAME, i);
end;

procedure TWPSetModeControl.SetCellCommand(const x: string);
var i: Integer;
begin
  i := Cursor.RTFProps.AStringToNumber(x);
  ASet(WPAT_PAR_COMMAND, i);
end;

procedure TWPSetModeControl.SetCellFormat(x: Integer);
begin
  ASet(WPAT_PAR_FORMAT, x);
end;

function TWPSetModeControl.GetCellName: string;
begin
  Result := Cursor.RTFProps.ANumberToString(AGetDefault(WPAT_PAR_NAME, 0));
end;

function TWPSetModeControl.GetCellCommand: string;
begin
  Result := Cursor.RTFProps.ANumberToString(AGetDefault(WPAT_PAR_COMMAND, 0));
end;

function TWPSetModeControl.GetCellFormat: Integer;
begin
  Result := AGetDefault(WPAT_PAR_FORMAT, 0);
end;

function TWPSetModeControl.CurrentTable: TParagraph;
begin
  if Cursor.active_paragraph <> nil then
  begin
    Result := Cursor.active_paragraph.ParentTable;
  end else Result := nil;
end;

procedure TWPSetModeControl.SetTableName(const x: string);
var par: TParagraph;
begin
  par := CurrentTable;
  if par <> nil then par.Name := x;
end;

function TWPSetModeControl.GetTableName: string;
var par: TParagraph;
begin
  par := CurrentTable;
  if par <> nil then
    Result := par.Name
  else Result := '';
end;

procedure TWPSetModeControl.SetParProtect(x: Boolean);
begin
  ASet(WPAT_ParProtected, Ord(x));
end;

function TWPSetModeControl.GetParProtect: Boolean;
begin
  Result := AGetDefault(WPAT_ParProtected, 0) <> 0;
end;

procedure TWPSetModeControl.SetParKeep(x: Boolean);
begin
  ASet(WPAT_ParKeep, Ord(x));
end;

function TWPSetModeControl.GetParKeep: Boolean;
begin
  Result := AGetDefault(WPAT_ParKeep, 0) <> 0;
end;

procedure TWPSetModeControl.SetParKeepNext(x: Boolean);
begin
  ASet(WPAT_ParKeepN, Ord(x));
end;

function TWPSetModeControl.GetParKeepNext: Boolean;
begin
  Result := AGetDefault(WPAT_ParKeepN, 0) <> 0;
end;

procedure TWPSetModeControl.SetOutlineBreak(x: Boolean);
begin
  ASet(WPAT_ParOutlineBreak, Ord(x));
end;

function TWPSetModeControl.GetOutlineBreak: Boolean;
begin
  Result := AGetDefault(WPAT_ParOutlineBreak, 0) <> 0;
end;

procedure TWPSetModeControl.AddTab(pos: Longint; Kind: TTabKind = tkLeft;
  Fill: TTabFill = tkNoFill; ColorNr: Integer = 0);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopAdd(pos, Kind, Fill, Color)
  else Cursor.WritingTextAttr.TabstopAdd(pos, Kind, Fill, Color);
end;

procedure TWPSetModeControl.DeleteTab(pos: Longint);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopDelete(pos)
  else Cursor.WritingTextAttr.TabstopDelete(pos);
end;

procedure TWPSetModeControl.ClearAttributes(StyleNr: Integer = -1);
var
  i: Integer;
  par: PTParagraph;
begin
  if Cursor.RTFData = nil then exit;
  par := Cursor.RTFData.FirstPar;
  while par <> nil do
  begin
    if (StyleNr < 0) or (par.Style = StyleNr) then
    begin
      for i := 0 to par.CharCount - 1 do
        par.CharAttr[i] := par.CharAttr[i] and $FF000000;
      par.ADelAllFromTo(WPAT_FirstCharAttr, WPAT_LastParAttr);
    end;
    include(par.prop, paprMustReformat);
    par := par.next;
  end;
end;

{ Set the position of the table }

procedure TWPSetModeControl.SetTableLeftRight(tbLeft, tbRight: Longint);
var par: TParagraph;
begin
  par := CurrentTable;
  if par <> nil then
  begin
    if tbLeft <> KeepOldValue then
      par.ASet(WPAT_BoxMarginLeft, tbLeft);
    if tbRight <> KeepOldValue then
      par.ASet(WPAT_BoxMarginRight, tbRight);
    FRichText.ReformatAll;
  end;
end;

function TWPSetModeControl.GetTableLeftRight(var tbLeft, tbRight: Longint):
  Boolean;
var par: TParagraph;
begin
  par := CurrentTable;
  if par <> nil then
  begin
    tbLeft := par.AGetDef(WPAT_BoxMarginLeft, 0);
    tbRight := par.AGetDef(WPAT_BoxMarginRight, 0);
    Result := TRUE;
  end else
  begin
    tbLeft := 0;
    tbRight := 0;
    Result := FALSE;
  end;
end;

procedure TWPSetModeControl.ClearAllTabs;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.TabstopClear
  else Cursor.WritingTextAttr.TabstopClear;
end;

function TWPSetModeControl.GetOutlineStyles(index: Integer): TWPRTFNumberingStyle;
begin
  if index < 1 then
    index := 1
  else if index > 9 then
    index := 9;
  Result := Cursor.RTFProps.NumberStyles.AddOutlineStyle(1, index);
end;

function TWPSetModeControl.GetNumberStyleEx: TWPRTFNumberingStyle;
var numlevel: Integer;
  SkipNumbering: Boolean;
begin
  Result := Cursor.RTFProps.NumberStyles.FindParNumberStyle(Cursor.active_paragraph, numlevel, SkipNumbering);
end;

procedure TWPSetModeControl.SetNumberStyleEx(x: TWPRTFNumberingStyle);
begin
  if x = nil then
  begin
    ASet(WPAT_NumberSTYLE, 0);
    ASet(WPAT_NumberLevel, 0);
  end
  else
  begin
    ASet(WPAT_NumberSTYLE, x.Number);
    ASet(WPAT_NumberLevel, x.LevelInGroup);
  end;
end;

function TWPSetModeControl.GetOutlineLevel: Integer;
begin
  Result := AGetDefault(WPAT_NumberLevel, 0);
end;

procedure TWPSetModeControl.SetOutlineLevel(x: Integer);
begin
  ASet(WPAT_NumberLevel, x);
  if AGetDefault(WPAT_NumberStyle, 0) = 0 then
    ASet(WPAT_NumberStyle, Cursor.RTFProps.NumberStyles.AddOutlineStyle(1, x).Number);
end;

function TWPSetModeControl.GetCurrNumberStart: Integer;
begin
  if Cursor.active_paragraph <> nil then
  begin
    Result := Cursor.active_paragraph.AGetDef(WPAT_Number_STARTAT, -1);
  end else Result := -1;
end;

procedure TWPSetModeControl.SetCurrNumberStart(x: Integer);
begin
  if Cursor.active_paragraph <> nil then
  begin
    if x <= 0 then Cursor.active_paragraph.ADel(WPAT_Number_STARTAT)
    else Cursor.active_paragraph.ASet(WPAT_Number_STARTAT, x);
  end;
end;

function TWPSetModeControl.GetCurrNumberStyle: Integer;
begin
  Result := AGetDefault(WPAT_NumberSTYLE, 0);
end;

procedure TWPSetModeControl.SetCurrNumberStyle(x: Integer);
begin
  if x <= 0 then
  begin
    ADel(WPAT_NumberSTYLE);
    ADel(WPAT_NumberLevel);
  end
  else
  begin
    ASet(WPAT_NumberSTYLE, x);
  end;
end;

function TWPSetModeControl.GetOutlineStyle: TWPNumberStyle;
var i: Integer; sty: TWPRTFNumberingStyle;
begin
  Result := wp_none;
  if AGet(WPAT_NumberSTYLE, i) then
  begin
    sty := FRichText.Memo.RTFData.RTFProps.NumberStyles.Items[i];
    if sty <> nil then
      Result := sty.Style;
  end;
end;

procedure TWPSetModeControl.SetOutlineStyle(x: TWPNumberStyle);
var i: Integer;
begin
  if x = wp_none then
  begin
    ASet(WPAT_NumberSTYLE, 0);
    ASet(WPAT_NumberLevel, 0);
  end
  else
  begin
    with FRichText.Memo.RTFData.RTFProps.NumberStyles do
    begin
      InitGroupArray(1);
      for i := 1 to 9 do
        if (GroupItems[i] <> nil) and
          (GroupItems[i].Style = x) then
        begin
          ASet(WPAT_NumberSTYLE, GroupItems[i].Number);
          ASet(WPAT_NumberLevel, i);
          exit;
        end;
    end;
    if x = wp_bullet then
    begin
      ASet(WPAT_NumberSTYLE, AddNumberStyle(x,
        BulletChar, '', BulletFont, FRichText.DefaultNumberIndent));
    end;
  end;
end;

procedure TWPSetModeControl.IncOutlineLevel;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.AInc(WPAT_NumberLevel, 1, 0)
  else Cursor.WritingTextAttr.AInc(WPAT_NumberLevel, 1, 0);
end;

procedure TWPSetModeControl.DecOutlineLevel;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.AInc(WPAT_NumberLevel, -1, 0)
  else Cursor.WritingTextAttr.AInc(WPAT_NumberLevel, -1, 0);
end;

procedure TWPSetModeControl.AutoIndentFirst(defaultvalue: Integer = 0);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.AutoIndentFirst(defaultvalue)
  else Cursor.WritingTextAttr.AutoIndentFirst(defaultvalue)
end;

procedure TWPSetModeControl.IncIndent;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.IncIndent
  else Cursor.WritingTextAttr.IncIndent
end;

procedure TWPSetModeControl.DecIndent;
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.DecIndent
  else Cursor.WritingTextAttr.DecIndent
end;

function TWPSetModeControl.GetOutlineMode: Boolean;
begin
  Result := AGetDefault(WPAT_ParIsOutline, 0) <> 0;
end;

procedure TWPSetModeControl.SetOutlineMode(x: Boolean);
begin
  if x then ASet(WPAT_ParIsOutline, 1)
  else ADel(WPAT_ParIsOutline);
end;

function TWPSetModeControl.SetNumberStyle(const TextB, TextA, BulletFont:
  string; Style: TWPNumberStyle; indent: Integer): Integer;
begin
  if indent = 0 then indent := Abs(BulletIndent);
  Result := AddNumberStyle(Style, TextB, TextA, BulletFont, Indent);
  NumberStyle := Result;
end;

(*function TWPSetModeControl.GetOutlineStyle: TWPNumberStyle;
var
  p: TWPRTFNumberingStyle;
begin
  p := Cursor.RTFProps.NumberStyles.FindParNumberStyle(Cursor.active_paragraph);
  if p <> nil then
    Result := p.style
  else
    Result := wp_none;
end; *)

function TWPSetModeControl.GetNumberStyle(nr: Integer): TWPRTFNumberingStyle;
begin
  Result := Cursor.RTFProps.NumberStyles.FindNumberStyle(nr, 0);
end;

// Changed - does not apply attribute anymore

function TWPSetModeControl.AddNumberStyle(
  const Style: TWPNumberStyle; const TextB, TextA: string;
  const BulletFont: string; const Indent: Integer): Integer;
begin
  Result := Cursor.RTFProps.NumberStyles.AddNumberStyle(
    Style, TextB, TextA, BulletFont, Indent, 0, False, 0, 0);
end;

(*procedure TWPSetModeControl.SetOutlineStyle(x: TWPNumberStyle);
var
  n, i: integer;
  nTextB, nTextA: string;
  nFont: string;
  NeededGroup: Integer;
  par: PTParagraph;
  ps: TWPRTFNumberingStyle;
begin
  if x = wp_none then
    n := 0
  else
  begin
    par := RTFText.active_paragraph;
    NeededGroup := 0; // Search in Group ?
    n := -1;
    // Look before the current text if we find a bullet or matching number
    while n < 0 do
    begin
      while (par <> nil) and ((par.number = 0) or (par.numlevel <> 0)) do
        par := par.prev;

      if par = nil then
      begin
        for i := 0 to RTFText.FNumberStyles.Count - 1 do
          if (RTFText.FNumberStyles[i].Style = x) and
            (RTFText.FNumberStyles[i].Group = NeededGroup) and
            ((x <> wp_Bullet) or
            ((RTFText.FNumberStyles[i].TextB = BulletChar) and
            (CompareText(RTFText.FNumberStyles[i].Font, BulletFont) = 0))) then
          begin
            n := RTFText.FNumberStyles[i].Number;
            break;
          end;
        break;
      end
      else
      begin
        ps := RTFText.FNumberStyles.FindNumberStyle(par.number, 0);
        if (ps <> nil) and (ps.Style = x) then
        begin
          n := ps.Number;
          break;
        end;
        par := par.prev;
      end;
    end;

    if n < 0 then
    begin
      nTextB := '';
      nTextA := '';
      nFont := '';
      case x of
        wp_bullet:
          begin
            nTextB := BulletChar;
            nFont := BulletFont;
          end;
        wp_lg_a, wp_a:
          begin
            nTextA := ')';
            nTextB := '';
          end;
        wp_lg_i, wp_i, wp_1:
          begin
            nTextA := '.';
            nTextB := '';
          end;
      end;
      n := RTFText.FNumberStyles.AddNumberStyle(x, nTextB, nTextA, nFont,
        RTFText.FNewStyleBulletsFirst, 0,
        FALSE,
        0, 0);
    end;
  end;
  FToChangePar.Number := n;
  include(FParChanges, wpchNumber);
  ApplyChanges;
  FCurrPar.Number := n;
end; *)

function TWPSetModeControl.GetLineVisible(index: TWPBrdLine): Boolean;
var i: Integer;
begin
  Result := (AGet(WPAT_BorderFlags, i) and ((i and WPBRD_BrdLine[index]) <> 0));
end;

procedure TWPSetModeControl.SetLineVisible(index: TWPBrdLine; x: Boolean);
begin
  if Cursor.IsSelected then
  begin
    if x then Cursor.SelectedTextAttr.ASetAdd(WPAT_BorderFlags, WPBRD_BrdLine[index])
    else Cursor.SelectedTextAttr.ASetDel(WPAT_BorderFlags, WPBRD_BrdLine[index]);
  end else
  begin
    if x then Cursor.WritingTextAttr.ASetAdd(WPAT_BorderFlags, WPBRD_BrdLine[index])
    else Cursor.WritingTextAttr.ASetDel(WPAT_BorderFlags, WPBRD_BrdLine[index]);
  end;
end;

function TWPSetModeControl.GetLineColor(index: TWPBrdLine): Integer;
begin
  if not AGet(WPBRD_BorderColorTranslate[WPBRD_BrdLineToType[index]], Result) then
    Result := AGetDefault(WPAT_BorderColor, 0);
end;

procedure TWPSetModeControl.SetLineColor(index: TWPBrdLine; x: Integer);
begin
  ASet(WPBRD_BorderColorTranslate[WPBRD_BrdLineToType[index]], x);
end;

function TWPSetModeControl.GetLineWidth(index: TWPBrdLine): Integer;
begin
  if not AGet(WPBRD_BorderWidthTranslate[WPBRD_BrdLineToType[index]], Result) then
    Result := AGetDefault(WPAT_BorderWidth, 0);
end;

procedure TWPSetModeControl.SetLineWidth(index: TWPBrdLine; x: Integer);
begin
  ASet(WPBRD_BorderWidthTranslate[WPBRD_BrdLineToType[index]], x);
end;

(*function TWPSetModeControl.GetLineStyle: TBorderType;
begin
  if not AGet(WPBRD_BorderColorTranslate[WPBRD_BrdLineToType[index]],Result) then
       Result := AGetDefault(WPAT_BorderColor,0);
end;

procedure TWPSetModeControl.SetLineStyle(x: TBorderType);
begin
  FToChangePar.Border.LineType := x;
  include(FParChanges, wpchBrdStyle);
  ApplyChanges;
end;*)
{ ++++++++++++++++ Character Attributes	++++++++++++++++++++ }

function TWPSetModeControl.NrToColor(x: Integer): TColor;
begin
  Result := Cursor.RTFProps.ColorTable[x];
end;

function TWPSetModeControl.ColorToNr(x: TColor; add: Boolean = true): Integer;
var found: Boolean;
begin
  if x = clNone then Result := 0 else
  begin
    found := Cursor.RTFProps.FindMatchingColor(x, add, Result);
    if not found and add then
      raise Exception.Create(WPLoadStr(mePaletteCompletelyUsed));
  end;
end;

function TWPSetModeControl.GetStyle: WrtStyle;
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_STYLE}
var stymask, styon: WrtStyle;
{$ENDIF}
begin
  if Cursor.IsSelected then
  begin
    if not Cursor.SelectedTextAttr.GetStyles(Result) then Result := [];
  end else
  begin
{$IFDEF DONT_REPORT_DEFAULT_ATTR_STYLE}
    if not Cursor.WritingTextAttr.GetStyles(Result) then Result := [];
{$ELSE}
    stymask := [];
    styon := [];
    Cursor.WritingTextAttr.GetStylesEx(styon, stymask);
    if (Cursor.active_paragraph <> nil) then
    begin
      Cursor.active_paragraph.AGetStylesEx(styon, stymask);
      if Cursor.active_paragraph.ABaseStyle <> nil then
        Cursor.active_paragraph.ABaseStyle.AGetStylesEx(styon, stymask);
    end;
    FRichText.DefaultAttr.GetStylesEx(styon, stymask);
    Result := styon * stymask;
{$ENDIF}
  end;
end;

procedure TWPSetModeControl.SetStyle(x: WrtStyle);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetStyles(x)
  else Cursor.WritingTextAttr.SetStyles(x);
end;

procedure TWPSetModeControl.AddStyle(x: WrtStyle);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.IncludeStyles(x)
  else Cursor.WritingTextAttr.IncludeStyles(x);
end;

procedure TWPSetModeControl.SetFontStyle(x: TFontStyles);
begin
  BeginUpdate;
  try
    if Cursor.IsSelected then
    begin
      if fsBold in x then
        Cursor.SelectedTextAttr.IncludeStyle(afsBold)
      else Cursor.SelectedTextAttr.ExcludeStyle(afsBold);
      if fsItalic in x then
        Cursor.SelectedTextAttr.IncludeStyle(afsItalic)
      else Cursor.SelectedTextAttr.ExcludeStyle(afsItalic);
      if fsUnderline in x then
        Cursor.SelectedTextAttr.IncludeStyle(afsUnderline)
      else Cursor.SelectedTextAttr.ExcludeStyle(afsUnderline);
      if fsStrikeout in x then
        Cursor.SelectedTextAttr.IncludeStyle(afsStrikeout)
      else Cursor.SelectedTextAttr.ExcludeStyle(afsStrikeout);
    end else
    begin
      if fsBold in x then
        Cursor.WritingTextAttr.IncludeStyle(afsBold)
      else Cursor.WritingTextAttr.ExcludeStyle(afsBold);
      if fsItalic in x then
        Cursor.WritingTextAttr.IncludeStyle(afsItalic)
      else Cursor.WritingTextAttr.ExcludeStyle(afsItalic);
      if fsUnderline in x then
        Cursor.WritingTextAttr.IncludeStyle(afsUnderline)
      else Cursor.WritingTextAttr.ExcludeStyle(afsUnderline);
      if fsStrikeout in x then
        Cursor.WritingTextAttr.IncludeStyle(afsStrikeout)
      else Cursor.WritingTextAttr.ExcludeStyle(afsStrikeout);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TWPSetModeControl.TextStyle(x: WrtStyle; AddStyle: Boolean);
begin
  if AddStyle then Self.AddStyle(x)
  else DeleteStyle(x);
end;

procedure TWPSetModeControl.DeleteStyle(x: WrtStyle);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.ExcludeStyles(x)
  else Cursor.WritingTextAttr.ExcludeStyles(x);
end;


function TWPSetModeControl.GetColorEx(WPAT_Code: Integer): Integer;
begin
  Result := -1;
  if Cursor.IsSelected then
  begin
    if WPAT_Code = WPAT_CharColor then
      Cursor.SelectedTextAttr.GetColorNr(Result)
    else if WPAT_Code = WPAT_CharBGColor then
      Cursor.SelectedTextAttr.GetBGColorNr(Result)
    else Cursor.SelectedTextAttr.AGet(WPAT_Code, Result);
  end
  else
  begin
    if WPAT_Code = WPAT_CharColor then
    begin
      Cursor.WritingTextAttr.GetColorNr(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}
      if (Result < 0) and (Cursor.active_paragraph <> nil) then
        Cursor.active_paragraph.AGetInherited(WPAT_CharColor, Result);
      if (Result < 0) then FRichText.DefaultAttr.GetColorNr(Result);
{$ENDIF}
    end
    else if WPAT_Code = WPAT_CharBGColor then
    begin
      Cursor.WritingTextAttr.GetBGColorNr(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}
      if (Result < 0) and (Cursor.active_paragraph <> nil) then
        Cursor.active_paragraph.AGetInherited(WPAT_CharBGColor, Result);
      if (Result < 0) then FRichText.DefaultAttr.GetBGColorNr(Result);
{$ENDIF}
    end
    else Cursor.WritingTextAttr.AGet(WPAT_Code, Result);
  end
end;

function TWPSetModeControl.GetColor: Integer;
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}var res: Boolean; {$ENDIF}
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetColorNr(Result)
  else
  begin
    res := Cursor.WritingTextAttr.GetColorNr(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}
    if not res and (Cursor.active_paragraph <> nil) then
      res := Cursor.active_paragraph.AGetInherited(WPAT_CharColor, Result);
    if not res then FRichText.DefaultAttr.GetColorNr(Result);
{$ENDIF}
  end;
end;

procedure TWPSetModeControl.SetColor(x: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetColorNr(x)
  else Cursor.WritingTextAttr.SetColorNr(x);
end;

function TWPSetModeControl.GetUnderlineMode: Integer;
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetUnderlineMode(Result)
  else Cursor.WritingTextAttr.GetUnderlineMode(Result);
end;

procedure TWPSetModeControl.SetUnderlineMode(x: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetUnderlineMode(x)
  else Cursor.WritingTextAttr.SetUnderlineMode(x);
end;

function TWPSetModeControl.GetBKColor: Integer;
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}var res: Boolean; {$ENDIF}
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetBGColorNr(Result)
  else
  begin
    res := Cursor.WritingTextAttr.GetBGColorNr(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR_COLOR}
    if not res and (Cursor.active_paragraph <> nil) then
      res := Cursor.active_paragraph.AGetInherited(WPAT_CharBGColor, Result);
    if not res then FRichText.DefaultAttr.GetBGColorNr(Result);
{$ENDIF}
  end;
end;

procedure TWPSetModeControl.SetBKColor(x: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetBGColorNr(x)
  else Cursor.WritingTextAttr.SetBGColorNr(x);
end;

function TWPSetModeControl.GetFontNr: Integer;
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetFont(Result)
  else Cursor.WritingTextAttr.GetFont(Result);
end;

procedure TWPSetModeControl.SetFontNr(x: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetFont(x)
  else Cursor.WritingTextAttr.SetFont(x);
end;

function TWPSetModeControl.GetFontName: TFontName;
var a : Integer;
begin
  Result := '';
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetFontName(Result)
  else Cursor.WritingTextAttr.GetFontName(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR} // also see DONT_REPORT_DEFAULT_ATTR_STYLE and DONT_REPORT_DEFAULT_ATTR_COLOR
  if not Cursor.IsSelected or DefaultAttrAlsoForSelectedText then begin
  if (Result = '') and (Cursor.active_paragraph <> nil) then
  begin
    if Cursor.active_paragraph.AGetInherited(WPAT_CharFont, a) then
        Result := FRichText.GetFontName(a);
  end;
  if Result = '' then
    FRichText.DefaultAttr.GetFontName(Result);
  if Result = '' then Result := DefaultFontName;
  end;
{$ENDIF}
end;

function TWPSetModeControl.GetSize: Single;
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetFontSize(Result)
  else Cursor.WritingTextAttr.GetFontSize(Result);
{$IFNDEF DONT_REPORT_DEFAULT_ATTR}
  if not Cursor.IsSelected or DefaultAttrAlsoForSelectedText then begin
  if (Result = 0) and (Cursor.active_paragraph <> nil) and
    (Cursor.active_paragraph.ABaseStyle <> nil) then
    Result := Cursor.active_paragraph.ABaseStyle.AGetDefInherited(//V5.20.9-inherited
      WPAT_CharFontSize, 0) / 100;
  if Result = 0 then
    FRichText.DefaultAttr.GetFontSize(Result);
  if Result = 0 then Result := DefaultFontSize;
  end;
{$ENDIF}
end;

procedure TWPSetModeControl.SetFontName(x: TFontName);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetFontName(x)
  else Cursor.WritingTextAttr.SetFontName(x);
end;

procedure TWPSetModeControl.SetSize(x: Single);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetFontSize(x)
  else Cursor.WritingTextAttr.SetFontSize(x);
end;

function TWPSetModeControl.GetCharSet: Integer;
begin
  Result := 0;
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.GetFontCharset(Result)
  else Cursor.WritingTextAttr.GetFontCharset(Result);
end;

procedure TWPSetModeControl.SetCharSet(x: Integer);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.SetFontCharset(x)
  else Cursor.WritingTextAttr.SetFontCharset(x);
end;

procedure TWPSetModeControl.IncSize(n: Single);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.AInc(WPAT_CharFontSize, Round(n * 100), 0)
  else Cursor.WritingTextAttr.AInc(WPAT_CharFontSize, Round(n * 100), 0);
end;

procedure TWPSetModeControl.DecSize(n: Single);
begin
  if Cursor.IsSelected then
    Cursor.SelectedTextAttr.AInc(WPAT_CharFontSize, -Round(n * 100), 0)
  else Cursor.WritingTextAttr.AInc(WPAT_CharFontSize, -Round(n * 100), 0);
end;

procedure TWPSetModeControl.SetBorders(
  LineSelection: TBorderType = [blEnabled, blLeft, blTop, blRight, blBottom];
  WPBRD_mode: Integer = -1;
  ThicknessTW: Integer = -1;
  LeftColor: Integer = -1;
  RightColor: Integer = -1;
  TopColor: Integer = -1;
  BottomColor: Integer = -1;
  AllPadding: Integer = -1;
  DeleteDefaultSettings: Boolean = TRUE);
    // The interface is passed as 'const' - this is very important, otherwise
    // the destructor is called and an AV is thrown
  procedure WidthIntDo(const Int: TWPAbstractCharParAttrInterface);
  var i, brd: Integer;
    procedure SetValue(wpat_code, val: Integer);
    begin
      if val >= 0 then Int.ASet(wpat_code, val)
      else if DeleteDefaultSettings then Int.ADel(wpat_code);
    end;
  begin
    if not (blEnabled in LineSelection) or
      (LineSelection * [blLeft, blTop, blRight, blBottom] = []) then
    begin
      for i := WPAT_BorderTypeL to WPAT_BorderFlags do Int.ADel(i);
    end else
    begin
      brd := 0;
      if blLeft in LineSelection then brd := brd or WPBRD_DRAW_Left;
      if blTop in LineSelection then brd := brd or WPBRD_DRAW_Top;
      if blRight in LineSelection then brd := brd or WPBRD_DRAW_Right;
      if blBottom in LineSelection then brd := brd or WPBRD_DRAW_Bottom;
      Int.ASet(WPAT_BorderFlags, brd);
      SetValue(WPAT_BorderType, WPBRD_mode);
      SetValue(WPAT_BorderWidth, ThicknessTW);
      SetValue(WPAT_BorderColorL, LeftColor);
      SetValue(WPAT_BorderColorT, RightColor);
      SetValue(WPAT_BorderColorB, TopColor);
      SetValue(WPAT_BorderColorR, BottomColor);
      SetValue(WPAT_PaddingLeft, AllPadding);
      SetValue(WPAT_PaddingTop, AllPadding);
      SetValue(WPAT_PaddingRight, AllPadding);
      SetValue(WPAT_PaddingBottom, AllPadding);
    end;
  end;
begin
  if Cursor.IsSelected then
  try
    Cursor.SelectedTextAttr.BeginUpdate;
    WidthIntDo(Cursor.SelectedTextAttr);
  finally
    Cursor.SelectedTextAttr.EndUpdate;
  end
  else
  try
    Cursor.WritingTextAttr.BeginUpdate;
    WidthIntDo(Cursor.WritingTextAttr);
  finally
    Cursor.WritingTextAttr.EndUpdate;
  end;
end;

{ This procedure applies the lines to the selected cells.
  It is a good example to understand how the cells are organized and hoe the border
  properties can be used.
  note: We kept a few lines which were used in WPTools 4 as comments.
}

procedure TWPSetModeControl.SetCellBorders(left, top, right, bottom, inner: TThreeState);
var
  is_top, is_bottom, is_first_in_row, is_last_in_row: Boolean;
  par, par1: TParagraph;
  procedure UpdateAParagraph(aPar: TParagraph);
  var borderflags: Integer;
  begin
    { In WPTools 4 the code was
       exclude(aPar^.border.LineType, blBox);
      No we do boolean operators with the 'borderflags', in this example
         borderflags := borderflags and not WPBRD_DRAW_All4
         -or-
         borderflags := borderflags or WPBRD_DRAW_Top
    }
    borderflags := aPar.AGetDef(WPAT_BorderFlags, 0);
    //NO!!! borderflags := borderflags and not WPBRD_DRAW_All4;
    if top = tsTRUE then
      borderflags := borderflags or WPBRD_DRAW_Top
    else if top = tsFALSE then
      borderflags := borderflags and not WPBRD_DRAW_Top;

    if left = tsTRUE then
      borderflags := borderflags or WPBRD_DRAW_Left
    else if left = tsFALSE then
      borderflags := borderflags and not WPBRD_DRAW_Left;

    if right = tsTRUE then
      borderflags := borderflags or WPBRD_DRAW_Right
    else if right = tsFALSE then
      borderflags := borderflags and not WPBRD_DRAW_Right;

    if bottom = tsTRUE then
      borderflags := borderflags or WPBRD_DRAW_Bottom
    else if bottom = tsFALSE then
      borderflags := borderflags and not WPBRD_DRAW_Bottom;

    // include(aPar^.border.LineType, blenabled); - not required anymore
    // if (aPar^.border.linetype = [blEnabled]) or
    //  (aPar^.border.linetype = [blEnabled, blFinish]) then aPar^.border.linetype := [];
    // include(aPar^.locked, wpseBrdLines); - not required anymore

    aPar.ASet(WPAT_BorderFlags, borderflags);
  end;
var borderflags: Integer;
begin
  with Cursor do
  try

{$IFDEF ALLOWUNDO}
    if (wpActivateUndo in FRichText.EditOptions) then
      RTFProps._UNDO_RTF_DATA := RTFDataCollection;
{$ENDIF}

    // StartUndoLevel;
    if parblock_count = 0 then
    begin
      if (block_s_par <> nil) and (block_e_par <> nil) then
      begin
        if block_reverse then
        begin
          par := block_e_par;
          par1 := block_s_par;
          if (par <> par1) and (block_s_par.prev <> nil) and
            {(block_s_lin.prev = nil) and}(block_s_cp = 0) then
            par1 := par1.prev;
        end
        else
        begin
          par1 := block_e_par;
          par := block_s_par;
          if (par <> par1) and (block_e_par.prev <> nil) and
            {(block_e_lin.prev = nil) and}(block_e_cp = 0) then
            par1 := par1.prev;
        end;
        while par <> nil do
        begin
          //was: exclude(par^.border.LineType, blFinish);
          par.ASetDel(WPAT_BorderFlags, WPBRD_DRAW_Finish);
          UpdateAParagraph(par);
          if par = par1 then
          begin
            //was: include(par^.border.LineType, blFinish);
            par.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Finish);
            break;
          end;
          par := par.next;
        end;
      end
      else
      begin
        // UndoBufferSaveTo(active_paragraph, wpuSetParBorder, wputChangeBorder);
        UpdateAParagraph(active_paragraph);
        // include(active_paragraph^.border.LineType, blFinish);
        active_paragraph.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Finish);
      end;

      // ReformatText(TRUE);
      FRichText.Repaint;
      exit;
    end;
   { any := (left = tsTrue) or (top = tsTrue) or (right = tsTrue) or (bottom =
      tsTrue) or (inner = tsTrue);  }
    { -------------------------------------------------- }
    par := FirstPar;
    borderflags := 0;
    while par <> nil do
    begin
      if (paprCellIsSelected in par.prop) and (paprIsTable in par.prop) then
      begin
        // UndoBufferSaveTo(par, wpuSetParBorder, wputChangeBorder);
        borderflags := Par.AGetDef(WPAT_BorderFlags, 0);
        // if any then include(par^.border.linetype, blEnabled);
        // exclude(par^.border.linetype, blBox);
        borderflags := borderflags and not WPBRD_DRAW_All4;
        //was: if left <> tsIgnore then exclude(par^.border.linetype, blLeft); ..

        if top <> tsIgnore then borderflags := borderflags and not WPBRD_DRAW_Top;
        if left <> tsIgnore then borderflags := borderflags and not WPBRD_DRAW_Left;
        if right <> tsIgnore then borderflags := borderflags and not WPBRD_DRAW_Right;
        if bottom <> tsIgnore then borderflags := borderflags and not WPBRD_DRAW_Bottom;

        include(par.prop, paprMustReformat); { Spacing can change ! }
        // include(par^.locked, wpseBrdLines);
      end;
      par := par.next;
    end;
    { -------------------------------------------------- }
    par := FirstPar;
    is_top := TRUE;
    repeat
      while (par <> nil) and (par.next <> nil) and
        not (paprCellIsSelected in par.prop) do
        par := par.next;
      par1 := par;
      while (par1 <> nil) and par1.paprIsLeftPar do //was: (paprIsLeftPar in par1^.prop) do
        par1 := par1.nextcell; //was: par1.next;
      if par1 <> nil then par1 := par1.nextcell;
      while (par1 <> nil) and not (paprCellIsSelected in par1.prop) do
        par1 := par1.nextcell;
      is_bottom := (par1 = nil);
      is_first_in_row := TRUE;
      while par <> nil do
      begin
        if paprCellIsSelected in par.prop then
        begin
          // ALREADY DONE: ! UndoBufferSaveTo(par, wpuSetParBorder, wputChangeBorder);
          borderflags := par.AGetDef(WPAT_BorderFlags, 0);
          if is_top then
          begin
            if top = tsTRUE then
              borderflags := borderflags or WPBRD_DRAW_Top
            else if top = tsFALSE then
              borderflags := borderflags and not WPBRD_DRAW_Top;

          end
          else
          begin
            if inner = tsTRUE then
              borderflags := borderflags or WPBRD_DRAW_Top
            else if inner = tsFALSE then
              borderflags := borderflags and not WPBRD_DRAW_Top;
          end;
          if not is_bottom then
            borderflags := borderflags and not WPBRD_DRAW_Bottom
          else
          begin
            if bottom = tsTRUE then
              borderflags := borderflags or WPBRD_DRAW_Bottom
            else if bottom = tsFALSE then
              borderflags := borderflags and not WPBRD_DRAW_Bottom;
          end;
          // borderflags := borderflags and not WPBRD_DRAW_Right;
          if is_first_in_row then
          begin
            if par.paprIsRightPar then
            begin
             // if not (paprCellIsSelected in par^.prev^.prop) then
             //   UndoBufferSaveTo(par^.prev, wpuSetParBorder, wputChangeBorder);
              borderflags := borderflags and not WPBRD_DRAW_Right;
              //obsolete: include(par^.prev^.locked, wpseBrdLines);
            end;
            if left = tsTRUE then
              borderflags := borderflags or WPBRD_DRAW_Left
            else if left = tsFALSE then
              borderflags := borderflags and not WPBRD_DRAW_Left;
          end
          else
          begin
            if inner = tsTRUE then
              borderflags := borderflags or WPBRD_DRAW_Left
            else if inner = tsFALSE then
              borderflags := borderflags and not WPBRD_DRAW_Left;
          end;
          is_last_in_row := not par.paprIsLeftPar or not (paprCellIsSelected in par.nextcell.prop);

          if is_last_in_row then
          begin
            if par.paprIsLeftPar then
            begin
              borderflags := borderflags and not WPBRD_DRAW_Right;
              if right = tsTRUE then
              begin
                // if not (paprCellIsSelected in par^.next^.prop) then
                //   UndoBufferSaveTo(par^.next, wpuSetParBorder, wputChangeBorder);
                //was: include(par^.next^.border.LineType, blLeft);
                par.nextcell.ASetAdd(WPAT_BorderFlags, WPBRD_DRAW_Left);
              end
              else if right = tsFALSE then
              begin
                // if not (paprCellIsSelected in par^.next^.prop) then
                //  UndoBufferSaveTo(par^.next, wpuSetParBorder, wputChangeBorder);
                borderflags := borderflags and not WPBRD_DRAW_Left;
              end;
            end
            else
            begin
              if right = tsTRUE then
                borderflags := borderflags or WPBRD_DRAW_Right
              else if right = tsFALSE then
                borderflags := borderflags and not WPBRD_DRAW_Right;
            end;
          end
          else
            borderflags := borderflags and not WPBRD_DRAW_Right;
        end
        else
          break;
        par.ASet(WPAT_BorderFlags, borderflags);

        if not par.paprIsLeftPar or
          (par.nextcell = nil) or
          not (paprCellIsSelected in par.nextcell.prop) then break;
       { if par^.border.linetype = [blEnabled] then
        begin
          par^.border.linetype := [];
        end; }
        par := par.nextcell;
        is_first_in_row := FALSE;
      end;
      is_top := FALSE;
      if par <> nil then par := par.nextcell;
    until is_bottom or (par = nil);

{$IFDEF ALLOWUNDO}
    RTFProps._UNDO_RTF_DATA := nil;
{$ENDIF}
  finally
    // EndUndoLevel;
    // ReformatText(TRUE);
  end;
  FRichText.DelayedReformat;
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//  TWPCustomToolCtrl
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

procedure TWPCustomToolCtrl.SetRTFedit(x: TWPCustomRichText);
begin

  if assigned(FRTFEditChanged) then FRTFEditChanged(Self, x);
end;

procedure TWPCustomToolCtrl.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (AComponent = FRtfEdit) then SetRTFedit(nil);
  end;
end;

procedure TWPCustomToolCtrl.UpdateSel;
begin
end;

function TWPCustomToolCtrl.GetRTFProps: TWPRTFProps;
begin
  if (FRtfEdit <> nil) and
    (FRtfEdit.Memo.HasData) then
    Result := FRtfEdit.Memo.RTFData.RTFProps
  else Result := nil;
end;

procedure TWPCustomToolCtrl.UpdateEnabledState;
begin
end;

procedure TWPCustomToolCtrl.OnColorDropDown(Sender: TObject);
var
  i: Integer;
begin
  if (RtfEdit <> nil) and (Sender is TComboBox) then
  begin
    TComboBox(Sender).Items.Clear;
    for i := 0 to RtfEdit.TextColorCount - 1 do
    begin
      TComboBox(Sender).Items.AddObject(IntToStr(i), Pointer(
        RtfEdit.TextColors[i]
        ));
    end;
  end;
end;

procedure TWPCustomToolCtrl.SetPreviewButtons;
begin
end;

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// TWPToolsBasicCustomAction
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

procedure TWPToolsBasicCustomAction.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FControl <> nil) and
      (AComponent = FControl) then FControl := nil;
  end;
end;

procedure TWPToolsBasicCustomAction.Loaded;
begin
  inherited Loaded;
  FShortCutSave := ShortCut;
end;

function TWPToolsBasicCustomAction.Update: Boolean;
begin
  if (FControl <> nil) and not (csDesigning in ComponentState) then //V5.20.7
  begin
    if (FGroup = WPI_GR_EDIT) and
      (FNr in [WPI_CO_Copy, WPI_CO_Cut, WPI_CO_Paste, WPI_CO_SelAll]) then
    begin
      Enabled :=
        FControl.HasFocus and
        ((FControl.FCommandDiabled[FGroup shr 8] and BitMaskL[FNr]) = 0);
      Checked := (FControl.FCommandChecked[FGroup shr 8] and BitMaskL[FNr]) <> 0;
      if not Enabled then
        ShortCut := 0
      else if (FShortCutSave <> 0)
        and (FShortCutSave <> ShortCut) then
        ShortCut := FShortCutSave;
      Result := TRUE;
    end
    else if ((FGroup shr 8) in [0..15]) and (FNr in [0..31]) then
    begin
      Enabled := (FControl.FCommandDiabled[FGroup shr 8] and BitMaskL[FNr]) = 0;
      Checked := (FControl.FCommandChecked[FGroup shr 8] and BitMaskL[FNr]) <> 0;
      Result := TRUE;
    end
    else
    begin
      Result := FALSE;
    end;
  end
  else
    Result := FALSE;
end;

end.

