{:: This unit contains the reader and writer classes to support RTF (*.RTF) files }
unit WPIOReadRTF;

//******************************************************************************
// WPTools V5/6 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPIOReadRTF - WPTools 5 RTF Reader  (Replaces WPTools 4 unit WPReader.PAS)
// 23.11.2008
//******************************************************************************

(* r\intbl\adjustright {\ql\b\f1\fs16\ {At The:}\cell}\clvertalt\cltxlrtb \cellx10000\pard
*)

{ Use the option:
    -ignorekeepn;
  to avoid loading the KeepN flag. The KeepN falg will be automatically
  ignored when the file was written by WPTools 5.10 (WrittenByWPToolsVersion<5.11)
  (See new property: WrittenByWPToolsVersion)

  -ignorerowmerge will ignore the merging of table rows
  -dontfixattr will *not* preprocess all paragraphs with styles to remove redundant attributes
  -IgnoreRowHeight removes all rowheights from the loaded text
}

{.$DEFINE NO_RTFSPLIT_TABLES}//OFF: if defined all adjecent tabels will be combined
{.$DEFINE DONT_FIX_STYLES}//OFF: if true the paragraphs will not be checked for styles after reading
{.$DEFINE DONT_FIX_DEFSTYLE}//OFF: if true the pars without a style will be checked for default font/default size
{.DEFINE NEVER_CHARSTYLES}//OFF: Never load charstyles for text (\cs attribute). Otherwise use -NoCharstyles format string
{.$DEFINE RTF_SECURITY_CHECK}//OFF: switch off checks to avoid too large fond (text and bullets) (found in some word and wptools 4 files)
{.$DEFINE NORTF_TITLEPG}//OFF: if defined when loading RTF no first header/footer will be automatically created
{.$DEFINE ALWAYS_IgnoreTableWidth}//OFF: always activate the OptIgnoreTableWidth property
{.$DEFINE LOADLS_WITHOUT_ilvl}// experimental - load lists which misses ilvl
{.$DEFINE DONT_SKIP_RTF_TEXT_AFTER_CLOSING}//OFF: V5.23.2
{$DEFINE NO_BXY_IGNORE} // TRUE - problem with word not writing consistently

{.$DEFINE ALWAYS_HEADER_R_BUG}// Always check for \header bug !

{$IFNDEF _______________WINCOM}
{$DEFINE FIX_FAULTY_TRRH} //V5.30.1
{$ENDIF}

{$IFDEF VER200} //For now - special adaption will be in V6
  {$WARNINGS OFF}
{$ENDIF}

interface
{$I WPINC.INC}

{$DEFINE USEMAX_BOX} // When 2 tables connected apply larger
{$DEFINE NOPARENTHESESINFONTNAMES} // Correct 'Times (Western)' to 'Times'
{.$DEFINE NOATATSTART}// Correct @Terminal to Terminal
{$DEFINE NODOLLARINFONTNAMES} //ON: Correct 'Arial$xxxx'
{.$DEFINE DONT_APPEND_PAR_AFTER_TABLES}//OFF - if last par=table append empty par
{$DEFINE FIXUP_V4_FIELDS} // remove >> and ] signs from mail merge text
{--$DEFINE WPRTFIGNORE_BOOKM}//(off) Ignore all bookmarks
{--$DEFINE DONOTREAD_AUTOWIDTH_TABLES}//(off) to ignore auto width in tables saved by Word
{--$DEFINE SPLIT_TABLES_WITH_DIFFERENTWIDTH}//(off) if the width differs we start a new table

{$DEFINE READ_NEWPAGE} // TRUE - read pagebb
{.$DEFINE DONTUSE_clwWidth}// FALSE, switch OFF percent values for columns
{--$DEFINE NONEWLIST}// FALSE

{$DEFINE USE_wpsec_ResetPageNumber} //new: pgnrestart

// Add the name of the generator which wrote the file to the RTF Varaiables
// Note that this item will be not written, always WPToolsRTFGenerator will be written!
{$DEFINE LOAD_GENERATORNAME} // ON!

{---$DEFINE READ_FIELDS_WITH_SPACE}// but not using quotes. Should not be enabled

{$DEFINE USE_WPTOOLS3_PROTECT} //ON (off in writer) use \shad to define protected text
{$DEFINE IMPORTV4EDITFIELDS} // Import the Version 4 edit fields
{-$DEFINE FIXUP_CHARSTYLES}//Experimental - will fix Attributes which are using styles
{-$DEFINE IGNORE_TBLTAGS}// Ignore proprietary tabstart/end tags (define globally also for writer!)
{-$DEFINE wp_posxc_is_qc}// handle the \posxc as if it was \qc (center align)
{-$DEFINE IGNOREALL_nonshppict}//OFF: experimental, should be off
{-$DEFINE USEAddDefaultParProps}//OFF: experimental, should be off
{$DEFINE READTAGOPT} //should be always on!

{$IFNDEF DONT_FIX_STYLES}{$DEFINE FIX_ANY_STYLE}{$ENDIF}
{$IFNDEF DONT_FIX_DEFSTYLE}{$DEFINE FIX_ANY_STYLE}{$ENDIF}

{ listoverride - first use of ls should apply START tag }

uses Classes, Windows, Sysutils, WPRTEDefs, Forms, {for Screen.Fonts} Graphics
;

const MaxColors = 1024;
  MaxCellAnz = 300;
  MAXFONTTBL = 2048;
  DEFAULTWPTOOLSVERSION = 0;
  aktfontlen = 300;

type
  TWPRTFReader = class;
// RTF Reader State - Controls Translation of Properties -----------------------
  TWPRDS = (rdsNorm, rdsSkip, rdsSkipText, rdsAnyString, rdsAnySVString, rdsFontTbl, rdsColorTable,
    rdsNestRowProps,
    rdsPicture, rdsPicName, rdsPicSource,
    rdsField, rdsFieldStringBuilder, rdsFldrSlt, rdsFieldParams,
    rdsParName, rdsCellName, rdsCellCommand,
    rdsPageRefText,
    rdsStyleSheet,
    rdsListtable, rdsList, rdsListName, rdsListLevel, rdsListOverrideTable, rdsListOverride, rdsLevelText, rdsLevelNumbers,
    rdsPNDef, rdsPNTextA, rdsPNTextB, // \*\pn group
    rdsPNStyle,
    rdsInfoUserRecord, rdsInfoGroup, rdsInfoItem, rdsInfoItemName, rdsUserProps,
    rdsFootnote, rdsUA,
    rdsWPfldfrm, rdsBookmark, rdsWPTObject,
    rdsHeader, rdsFooter,
    rdsWPTable, rdsMergeVar, rdsMergePar,
    rdsObjData, rdsObjName, rdsObjClass, rdsObjTime,
    rdsElementName,
    rdsShpinst, rdsShprslt,
    rdsShpText, rdsShpSP, rdsShpSN, rdsShpSV, rdsShprsltPict, rdsANSITEXT, rdsUNICODETEXT,
    rdsWPBinInfo, rdsWPBinName, rdsWPBinDataHex,
    rdsffname, rdsffdeftext, rdsffformat);

// RTF TagObject -----------------------------------------------------------------
  TWPRTFTagParams = class(TObject)
  public
{$IFDEF READTAGOPT}Name: string; {$ENDIF}
    DefaultValue: Integer; // Default Value - can be used to create sub groups
    UseDefaultValue: Boolean; // Used Default Value
    TagAction: Integer; // Action - what to do with this value
    ActionID: Integer; // Value
  end;

  TWPCurrentPNGroup = record
    Reading: Boolean;
    MODE: Integer;
    LEVEL: Integer;
    // TEXTB : WideString;  --> see FPNTEXTB
    // TEXTA : WideString;  --> see FPNTEXTA
    STARTAT: Integer;
    ALIGN: Integer;
    SPACE: Integer;
    FONT: Integer;
    FONTSIZE: Integer;
    FONTCOLOR: Integer;
    FONTSTYLES: Integer;
    INDENT: Integer;
    FLAGS: Integer;
  end;

  TWPRTFReaderStackProps = record
    InTable: Boolean;
    InNestCell: Boolean;
    InField: Boolean;
    IsRTLPar: Boolean;
    InStyleDef: Boolean;
  end;

  TWPShapeProps = record
    reading: Boolean;
    dx, dy: Integer;
    shpleft: Integer;
    shptop: Integer;
    shpright: Integer;
    shpbottom: Integer;
    shpfhdr: Integer; //1 for header ??
    shpbymethod: Integer;
    shpbypage: Boolean;
    shpbypara: Boolean;
    shpbychar: Boolean;
    shpbyignore, shpbxignore: Boolean;
    shpwr: Integer; // wrap mode 1
    shpwrk: Integer; // wrap mode (type 2 and 4)
    shpfblwtxt: Integer; // 0=over, 1=under text
    shpbxmode: Integer;
    shpbxmethod: Integer;
    shpName: AnsiString;
    WPPosmode: Integer;
    wpFrameMode: Integer;
    wpExtra: Integer;
  end;

  TWPRTFBorderRange = (wpreadParBorder, wpreadRowBorder, wpreadCellBorder, wpreadTSBorder);

  // WPTools4 saves MergeFields as:
  // {\field{\*\fldinst{MERGEFIELD "name name"}} Ctext }  -or-
  // {\field{\*\fldinst{MERGEFIELD name}} Ctext }
  // Word:
  // {\field{\*\fldinst{MERGEFIELD NAME  \b vortext \f nachtext \m \* Upper\* Lower\* FirstCap\* Caps "name" \@ "format" \* MERGEFORMAT}
  //   {\fldrslt Joe Smith}}
  // --> If we find the text 'MERGEFORMAT' in fldinst ignore text which is not inside the fldrslt group

  TWPFieldType = (wpRegularText, wpNewField, wpNewFormField, wpOldStyleInsertPoint, wpMergeField, wpTextObject, wpLinkedImage, wpReference);

  TWPStringBuilderReadRTF = class(TWPStringBuilder)
  private
    FFieldType: TWPFieldType;
    FToObject: TWPTextObj;
  end;

// RTF Reader Stack - optimized for fast Copy operations
  TWPRTFReaderStack = class(TWPTextStyle)
  private
    CharAttr: TWPCharAttr; // Character styles for this char
    FCurrentCodePage: Integer;
    FFieldINST: TWPStringBuilderReadRTF; // Created on demand.
    FFieldINSTAssigned: Boolean;
    FNextHasKeepnN, FHasKeepN, FInTROWD: Boolean;
    RestoreRTFData: TWPRTFDataBlock;
    RestoreCurrentPar: TParagraph;
    RestoreTableDepth: Integer;
    RestoreTableVar: TList;
    FPrevious: TWPRTFReaderStack;
    ParNrStyle: Integer;
    FNeedNewPageNextTime: Boolean;
    FHasDefaultSectionBreak: Boolean;
    FCurrentColumnCount, FColumnCount, FColumn_X, FColumn_Y: Integer;
  public
    Props: TWPRTFReaderStackProps;
    Destination: TWPRDS; // What to do with this RTF code
    AllIgnore: Boolean; // Ignore fields, too
    FIgnoreNextImg: Boolean;
    constructor Create(props: TWPRTFProps);
destructor Destroy; override; 
    function LastStringBuilder: TWPStringBuilderReadRTF;
    property Previous: TWPRTFReaderStack read FPrevious;
  end;

  // The list definition(s)
  TWPRTFReadList = class
  private
    FListID: Integer;
    FListName: string;
    FListSimple: Boolean;
    FListLevel: array[1..9] of TWPTextStyle; // 1 or 9 levels
    FUsedAs: array[1..9] of Integer; // Mapping Table in RTFProps.NumStyles
    FListLevelCount: Integer;
    FRTFProps: TWPRTFProps;
    FRestartSection: Boolean;
    FMappingNumber: Integer;
  public
    function InitNext: Boolean;
    function CurrentStyle: TWPTextStyle;
    function Get(N: Integer): Integer;
    procedure Clear;
    constructor Create(RTFProps: TWPRTFProps);
destructor Destroy; override; 
  end;

  // Used to match \ls values
  TWPRTFReadListOverride = record
    List: TWPRTFReadList;
    DefaultLevel: Integer; // Which level to use (Start with 1)
    UsedInDoc: Boolean; // The first time a list is used a style is created based on
     // the TWPRTFReadList and the OveriddenProps. Optionally the array 'FUsedAs' can also be filled
     // with the already found ids in the RTF text! - use NewOutlineGroup
    listoverridestartat: Integer;
    uselistoverridestartat: Boolean;
    OutlineGroup: Integer
     // OveriddenProps : TWPTextStyle (reserved - very seldom!)
  end;

  TWPRTFReadStyle = record
    FKind: TWPRTFStyleElementKind;
    FStyle: TWPTextStyle;
    FID: Integer;
    FNum: Integer;
    FBasedOn: Integer;
    FNext: Integer;
    FUsedAs: Integer;
    FStyleName: string;
    FStyleElement: TWPRTFStyleElement;
    FIsDefault: Boolean;
  end;

  TWPRTFReadStyleSheet = class
  private
    FLoadOptions: TLoadOptions;
    FStyles: array of TWPRTFReadStyle;
    FRTFProps: TWPRTFProps;
    FStyleCount: Integer;
    FKind: TWPRTFStyleElementKind;
  public
    function InitNext: TWPTextStyle;
    function Get(N: Integer): Integer;
    function GetName(N: Integer): string;
    procedure Clear;
    constructor Create(RTFProps: TWPRTFProps; Kind: TWPRTFStyleElementKind);
destructor Destroy; override; 
  end;

  // The current row properties
  TWPRTFReadTable = record
    CellWidth: array[0..MaxCellAnz] of Integer;
    CellBorder: array[0..MaxCellAnz] of Integer;
    CellBestWidth: array[0..MaxCellAnz] of Integer; // See flags
    CellFlags: array[0..MaxCellAnz] of Integer; //WPRDFLAG_...
    CellCount: Integer;
    ResetCellCount: Boolean;
    CellLast: Integer;
    SpaceBetweenCells: Integer; //NOT trgaph
    SpaceBetweenCellsH: Integer; // trgaph
   // Padding: array[0..3] of Integer; // L T R B  (trpaddl ... )
  //  Spacing: array[0..3] of Integer; // L T R B  (trspdl ... )
    RowWidth: Integer;
    RowLeft: Integer; // trleft
    LastAllWidth, AllWidth: Integer;
    BoxWidth, BoxWidth_PC: Integer;
    RowAlign: Integer; // reserved - 0=left, 1= center, 2 = right
    RowHeight: Integer; // trrh
    RowI, RowBand: Integer;
    RowFlags: Integer; //WPRDFLAG_...
    Row_BGColor: Integer; // Background Color
    Row_FGColor: Integer; // Foreground Shading Color
    Row_ShadingValue: Integer; // Background Shading Percentage  \tscellpct
    Row_ShadingType: Integer; // WPSHAD_
  end;

  TWPRTFTableStack = class
  protected
    FRTFProps: TWPRTFProps;
    FTableParent: TParagraph;
    FTableRow: TParagraph;
    FFirstCellInRow, FLastCellInRow: TParagraph;
    FRowTbl: TWPRTFReadTable;
    FTableRowStyle: TWPTextStyle;
    FTableCellStyle: TList;
    TableFlags: Integer; //WPRDFLAG_...
    FInsideTable, FInsideRow, FInsideCell: Boolean;
    FDontCombineTables: Boolean; // Force separation - even if same size
    function GetTableCellStyle(index: Integer): TWPTextStyle;
  public
    constructor Create(props: TWPRTFProps);
destructor Destroy; override; 
    procedure Clear;
    function CurrentCell: TWPTextStyle;
    property TableCellStyle[index: Integer]: TWPTextStyle read GetTableCellStyle;
  end;

  // RTF Font table reading ----------------------------------------------------
  TWPRTFFontTable = record
    aktnr: Integer;
    aktCharset: Integer;
    aktfont: String;
    Fontnr: array[0..MAXFONTTBL] of Integer;
    FontCharset: array[0..MAXFONTTBL] of Integer;
    FontCodePage: array[0..MAXFONTTBL] of Integer;
    IsNew: array[0..MAXFONTTBL] of Boolean;
  end;
  PTWPRTFFontTable = ^TWPRTFFontTable;

  TWPRTFReader = class(TWPCustomTextReader) { from WPTools.RTE.Defs }
  protected
    FStack: TWPRTFReaderStack;
    FSectionBreakMode: Integer;
    FDelayedTxtObj: TList;
    chLastFontCH: Char;
    FCurrentColumnCount, FColumnCount, FColumn_X, FColumn_Y: Integer;
{$IFDEF FIXUP_CHARSTYLES}FHasCharStyles: Boolean; {$ENDIF}
    FCurrentParagraphBeforePARD: TParagraph;
    FKeepNWasAssignedToThisPar: TParagraph;
    FStartNewPageNextCreatePar: Boolean;
    FHorzLineWidth, FHorzLineColor, FHorzLineOffsets: Integer;
    FTextObjList: TWPTextObjList;
    FFieldModeParam, FFieldIParam, FFieldFrameParam: Integer;
    FFormObject: TWPTextObj;
    FShape: TWPShapeProps;
    // Reading Numbers
    FPNGroup: TWPCurrentPNGroup;
    FPNTEXTB: WideString;
    FPNTEXTA: WideString;
    // Used to skip last \par
    lastTagActionID: Integer;
    // For DBCS and reading
    FCurrentCodePage: Integer;
    FDefaultFontNrDEFF: Integer;
    FDefaultFontNr, FDefaultFontNrMap: Integer;
    FDefaultFontSize: Single;
    FLastWasSTDPar, FNeedStackAssign, FNeedNewPageNextTime, FInTBL: Boolean;
    FTableStart: Integer; // If used once it must be always used!
    FIsNewSection, FRestartPageNr: Boolean;
    FPrevSectionId: Integer;
    FInSpecialText: Boolean; // in header or footer
    FNewSectionID: Integer;
    FIsBookmarkStart: Boolean;
    FInfoItemName, FCurrentMergePar, FCurrentMergeVar, FCurrentElementName: string;
    FWrittenByGenerator: AnsiString;
    FWrittenByWPToolsVersion: Extended;
    FOptIgnoreRowMerge: Boolean;
    FOptOnlyAddUsedStyles: Boolean;
    FOptDontOverwriteStyles: Boolean;
    FOptIgnoreTableWidth: Boolean;
    FOptIgnoreTableSETags: Boolean;
    FOptIngoreSections: Boolean;
    FOptNoCharStyles: Boolean;
    FOptIgnoreFontStyle: Boolean;
    FOptDontFixAttr: Boolean;
    FOptIgnoreRowHeight: Boolean;
    FIsMergePar: Integer;
    FNextIsProtected: Boolean;
    FLoadedLandscape: Boolean;
    FWPBinData: TMemoryStream;
    FInfoItemType: Integer;
    FUNICharCount: Integer;
    FLastPictWasUnknown: Boolean;
    FWaitForInsertPoint: Boolean;
    FHasReportGroups: Boolean;
    FNewTxtObj: TWPTextObj;
    FLastOldInsertPoint: TWPTextObj;
    FIgnoreNextField: Boolean;
    FHasParStyle: Boolean;
    FIgnoreNextPict: Boolean;
    FNextParIsOutline: Integer;
    FStringBuilder: TWPStringBuilder; // Usually belongs to the stack !
    FReadingStyle: TWPTextStyle;
    FFontTbl: TWPRTFFontTable;
    FSwapParColors, FIgnoreNext_Par: Boolean;
    FCurrFieldName, FCurrFieldText, FCurrFieldFormat: string;
    FCurrFieldMaxLen: Integer;
        // We are reading a string
    FCurrentString: TWPStringBuilderReadRTF;
    FCurrentExString: TWPStringBuilderReadRTF;
    FCurrentStringName: string;
    FIsTableName: Boolean;
    FTableName: string;
    FCurrentNumberString: WideString;
    FReadingString: Boolean;
    FStringDestination: Integer; // Wenn done put it into this destination (idestConst)
    // Non stacked flags
    lastSpaceBetween: Integer;
    lastSpaceBetweenHasValue: Boolean; // FALSE if lastSpaceBetween is undefined
    lastSpaceSLMULT: Integer; // -1 for undefined
    FTableVar: TList;
    FTableDepth, Last_TableDepth: Integer;
    trftsWidth_mode: Integer;
    FLastParagraph: TParagraph;
    // Current aktive Layout
    Layout: TWPLayout;
 
    // RTFTagTable
{$IFDEF READTAGOPT}

    readtags: array of TWPRTFTagParams;
    readtaglen: array of Integer;
    readtagsindex: array[AnsiChar] of Integer;
    readtagsblen: array[AnsiChar] of Integer;

{$IFDEF READTAGOPT_HASH}
    readtaghash: array of TWPRTFTagParams;
    readtaghashmult: array of Boolean;
{$ENDIF}
{$ENDIF}
 //experimental
    // Load Color Table
    FColIndex, last_red, last_green: Integer;
    ColorMapTable: array[0..MaxColors] of Integer;
    // Load Borders
    ReadingBorderRange: TWPRTFBorderRange;
    ReadingBorder: TOneBorderType; // [blLeft ...
    ReadingBorderValue: Integer;
    // Reading tabstops
    FThisTabKind: TTabKind;
    FThisTabFill: TTabFill;
    FThisTabColor: Integer;
    // Reading Images
    FPicture: TWPReadPictData;
    FPictureSource, FPictureName: string;
    FWPTextObjOpenTag, FWPTextObjCloseTag: Integer;
    // To import old WPTools Hyperlinks
    FHasDoubleUnderlines: Boolean;
    // Read Number List
    FCurrentList: TWPRTFReadList;
    FListsDefs: TList; // [TWPRTFReadList]
    FListOverrides: array of TWPRTFReadListOverride; // \ls is Index+1 !, Item 0 is ignored !
    FListOverrideCount: Integer;
    FCurrentListNr: Integer;
    // Read OLD Numbering Table .. // pnseclvl1\pnucrm\
    FHasNewListTable: Boolean;
    FOldListTableLevel, FOldListTableGroup: Integer;
    FOldListTable: array[1..9] of TWPTextStyle;
    FOldListTableUseAs: array[1..9] of Integer;
    FStartParWithNumber: Integer;
    // Read Style Sheets
    FStyleSheet: TWPRTFReadStyleSheet;
    DefAttrCharAttr: Cardinal; // assigned when loading
    FLoadInHeaderFooter: Boolean;
    procedure PushStack;
    function PopStack: Boolean;
    procedure SkippedText(aCh: Integer); virtual;
    procedure ApplyShapeProps(txtobj: TWPTextObj); virtual;
    procedure ApplyFrameModeParams(FrameParam, ModeParam: Integer; txtobj: TWPTextObj); virtual;
    function RowReading: Boolean;
    procedure LoadIntoRTFDataBlock(rtfdataobj: TWPRTFDataBlock);
    procedure CloseCurrentRow;
    procedure InitShape; virtual;
{$IFDEF USEAddDefaultParProps}procedure AddDefaultParProps(par: TParagraph); dynamic; {$ENDIF}
    function StartNewSection(par: TParagraph): Boolean; virtual;
    procedure InNewSection(par: TParagraph); virtual;
    procedure CreateImplizitPar;
    procedure CheckOpenCell(i: Integer);
    function GetTableVar(index: Integer): TWPRTFTableStack;
    procedure SetTableDepth(x: Integer);
    function GetTableDepth: Integer;
    function CreateObject: TWPObject;
    function UseThisFont(var aFont: string; aFontTbl: PTWPRTFFontTable): TThreeState; virtual;
    procedure ReadFontTblChar(ch: Char);
 
    procedure CloseDestination(CurrentDest, NewDest: TWPRDS); virtual;
    function ParseEscapeCode(ch: Integer): TWPToolsIOErrCode; virtual;
    procedure LoadLinkedImage(txtobj: TWPTextObj; fname, params: string);
    procedure ChangeDestination(idestCode, Value: Integer); virtual;
    procedure CheckNewParagraph; virtual;
    procedure ChangeProp(ipropCode, Value: Integer); virtual;
    class function UseForFilterName(const Filtername: string): Boolean; override;
    class function UseForContents(const First500Char: AnsiString): Boolean; override; // AUTO ...
    property WrittenByGenerator: AnsiString read FWrittenByGenerator;
    property WrittenByWPToolsVersion: Extended read FWrittenByWPToolsVersion;
    {:: If this flag is set the rowmerge property will be ignored when reading RTF code.
    You can set the flag withg the format option: -ignorerowmerge }
    property OptIgnoreRowMerge: Boolean read FOptIgnoreRowMerge write FOptIgnoreRowMerge;
    {:: If this property is true the RTF reader will <b>not</b> remove redundant attribute
    information, such as fonts, indents etc. Redundant are attributes which are selected by
    the paragraph styles or document font information (DefaultTextAttr). }
    property OptDontFixAttr: Boolean read FOptDontFixAttr write FOptDontFixAttr;
    {:: Do not load and apply the absolute row height defined in RTF code. }
    property OptIgnoreRowHeight: Boolean read FOptIgnoreRowHeight write FOptIgnoreRowHeight;
    {:: If this property is TRUE the RTF reader will only add the styles which are
    used by the loaded text. }
    property OptOnlyAddUsedStyles: Boolean read FOptOnlyAddUsedStyles write FOptOnlyAddUsedStyles;
    {:: If this property is true style information is loaded but existing styles are
    not overwritten. }
    property OptDontOverwriteStyles: Boolean read FOptDontOverwriteStyles write FOptDontOverwriteStyles;
    {:: If this property is used the WPAT_BoxWidth parameter will not be set in tables }
    property OptIgnoreTableWidth: Boolean read FOptIgnoreTableWidth write FOptIgnoreTableWidth;
    {:: If this property is true the optional \tblstart and \tblend tags will be ignored }
    property OptIgnoreTableSETags: Boolean read FOptIgnoreTableSETags write FOptIgnoreTableSETags;
    {:: If this property is treu section breaks are ignored }
    property OptIngoreSections: Boolean read FOptIngoreSections write FOptIngoreSections;
    {:: Don't read character styles (\cs). Use format string -nocharstyles. }
    property OptNoCharStyles: Boolean read FOptNoCharStyles write FOptNoCharStyles;
    {:: Don't read character styles. Use format string -ignorefontstyles. }
    property OptIgnoreFontStyle: Boolean read FOptIgnoreFontStyle write FOptIgnoreFontStyle;
  public
    constructor Create(RTFDataCollection: TWPRTFDataCollection); override;
    destructor Destroy; override;
    procedure SetOptions(optstr: string); override;
    function Parse(datastream: TStream): TWPRTFDataBlock; override;
    function CurrentParagraph: TParagraph; override;
  protected
    property TableDepth: Integer read GetTableDepth write SetTableDepth;
    property TableVar[index: Integer]: TWPRTFTableStack read GetTableVar;
  end;

{:: This function adds a RTF keyword to the global RTF tag list. Please be careful with threading when you do
it in your application. The result value is a reference to the added object of class TWPRTFTagParams
which can be enhanced to hold other parameters and events }

function AddRgSymRtf(const sKeyword: string; DefaultValue: Integer; UseDefaultValue: Boolean;
  TagAction, ActionID: Integer): TWPRTFTagParams;

const
  kwdChar = 1; kwdDest = 2; kwdProp = 3;

implementation

uses Math;

const
  WPRDFLAG_ROWMERGE = 1; // Merged with preceeding row
  WPRDFLAG_CELLMERGE = 2; // Merged with preceeding cell
  WPRDFLAG_FitText = 4; // Auto Size Cell ???
  WPRDFLAG_NoWrap = 8; // don't wrap text
  WPRDFLAG_Use_clpadl = 16; // clpadfl = 3
  WPRDFLAG_Use_clpadt = 32; // clpadft = 3
  WPRDFLAG_Use_clpadr = 64; // clpadfr = 3
  WPRDFLAG_Use_clpadb = 128; // clpadfb = 3
  WPRDFLAG_WIDTH_ISPT = 256;
  WPRDFLAG_WIDTH_ISTW = 512;
  WPRDFLAG_WIDTH_ISOFF = 1024;

   // For Rows  - RowFlags (iproptableflags)
  WPRDFLAG_RIsHeader = 1; //  \trhdr
  WPRDFLAG_RIsFooter = 2; //  ?
  WPRDFLAG_RKeep = 4; //  \trkeep
  WPRDFLAG_RKeepN = 8; //  \trkeepfollow
  WPRDFLAG_RAutoFit = 16; //  \trautofit
  WPRDFLAG_RTL = 32; //  \taprtl
  WPRDFLAG_LTR = 1000;
  WPRDFLAG_RUse_trpaddl = 64; // trpaddfl = 3
  WPRDFLAG_RUse_trpaddt = 128; // trpaddft
  WPRDFLAG_RUse_trpaddr = 256; // trpaddfr
  WPRDFLAG_RUse_trpaddb = 512; // trpaddfb
  WPRDFLAG_RUse_trspdl = 64; // trspdfl = 3
  WPRDFLAG_RUse_trspdt = 128; // trspdft
  WPRDFLAG_RUse_trspdr = 256; // trspdfr
  WPRDFLAG_RUse_trspdb = 512; // trspdfb
  WPRDFLAG_IsLastRow = 1024; // LastRow
  WPRDFLAG_RIsCollapsed = 2048;

   // For Tables
  WPRDFLAG_TAborder = 4; // Flag sets table autoformat to format borders. (tbllk ... )
  WPRDFLAG_TAshading = 8; //	Flag sets table autoformat to affect shading.
  WPRDFLAG_TAfont = 16; // Flag sets table autoformat to affect font.
  WPRDFLAG_TAcolor = 32; // Flag sets table autoformat to affect color.
  WPRDFLAG_TAbestfit = 64; //	Flag sets table autoformat to apply best fit.
  WPRDFLAG_TAhdrrows = 128; //	Flag sets table autoformat to format the first (header) row.
  WPRDFLAG_TAlastrow = 256; //	Flag sets table autoformat to format the last row.
  WPRDFLAG_TAhdrcols = 512; //	Flag sets table autoformat to format the first (header) column.
  WPRDFLAG_TAlastcol = 1024; //	Flag sets table autoformat to format the last column.

{ ----------------------------------------------------------------------------- }
{ We are yet NOT using a list in the enviroment to avoid thread startup delay   }
{ ----------------------------------------------------------------------------- }

var WPRTFTagList: TStringList;

function AddRgSymRtf(const sKeyword: string; DefaultValue: Integer; UseDefaultValue: Boolean;
  TagAction, ActionID: Integer): TWPRTFTagParams;
begin

  Result := TWPRTFTagParams.Create;
{$IFDEF READTAGOPT}

  Result.Name := sKeyword;
{$ENDIF}
  Result.DefaultValue := DefaultValue;
  Result.UseDefaultValue := UseDefaultValue;
  Result.TagAction := TagAction;
  Result.ActionID := ActionID;
  WPRTFTagList.AddObject(sKeyword, Result);
end;

procedure UnPrepareRTFTags;
var i: Integer;
begin
  if WPRTFTagList <> nil then
  begin
    for i := 0 to WPRTFTagList.Count - 1 do
      TWPRTFTagParams(WPRTFTagList.Objects[i]).Free;
    FreeAndNil(WPRTFTagList);
  end;
end;

{ ----------------------------------------------------------------------------- }
const
  //#: RTF REader: iprop Table
//++++++++++++ RTF Destinations +++++++++++++++++
  idestNormal = 1;
  idestSkip = 2;
  idestPicture = 3;
  idestPicIgnorePic = 4;
  idestPicWPTools = 5;
  idestPicSTD = 6;
  idestPicProps = 7;
  idestPicUID = 8;
  idestField = 9;
  idest_________res = 10;
  idestFldInstructions = 11;
  idestFldParams = 12;
  idestParName = 13;
  idestWPTableName = 14;
  idestCellName = 15;
  idestCellCommand = 16;
  idestFldResult = 17;
  idestFontTbl = 18;
  idestColorTable = 19;
  idestNestTableDef = 20;
  idestInfoItem = 21;
  idestInfoUserRecord = 22;
  idestInfoItemName = 23;
  idestWPBinInfo = 24;
  idestWPBinName = 25;
  idestWPBinData = 26;
  idestFootNote = 27; //PR
  idestPictureName = 28;
  idestDelphicontrol = 29;
  idestBookmarkStart = 30;
  idestBookmarkEnd = 31;
  idestHeader = 32;
  idestFooter = 33;
  idestWPElementName = 34;
  idestStyleSheet = 35;
  idestCS = 36;
  idestListtable = 37;
  idestList = 38;
  idestListName = 39;
  idestListlevel = 40;
  idestListOverride = 41;
  idestListOverrideItem = 42;
  idestLevelText = 43;
  idestListStyleName = 44;
  idestLevelNumbers = 45;
  idestListText = 46;
  idestPN = 47;
  idestPNTextA = 48;
  idestPNTextB = 49;
  idestPNText = 50;
  idestPNStyle = 51;
  idestMergePar = 52;
  idestInitCode = 53;
  idestBackgroundImage = 54;
  idestOLEData = 55;
  idestOLEClass = 56;
  idestOLEName = 57;
  idestOLETime = 58;
  idestReadBinaryData = 59;
  idestShpinst = 60;
  idestShprslt = 61;
  idestShpText = 62;
  idestShpSN = 63;
  idestShpSV = 64;
  idestShpSP = 65;
  idestDo = 66;
  idestWPfldfrm = 67;
  idestReadANSITEXT = 68;
  idestReadUNICODE = 69;
  idestGenerator = 70;
  idest_ffname = 71;
  idest_ffdeftext = 72;
  idest_ffformat = 73;
  idestNonesttables = 74;
  idestPicName = 75;
  idestPicSource = 76;
  idestMergeVar = 77;
//++++++++++++ RTF Properties +++++++++++++++++
//+++++++++++++ START GROUP 1 +++++++++++++++++
  ipropUnknown = 0;
  ipropReadBin = 1;
  ipropColorRed = 2;
  ipropColorGreen = 3;
  ipropColorBlue = 4;
  ipropPlain = 5;
  ipropBold = 6;
  ipropItalic = 7;
  ipropUnderline = 8;
  ipropUnderlineMode = 9;
  ipropUnderlineColor = 10;
  ipropFontNr = 11;
  ipropFontCharset = 12;
  ipropFontSize = 13;
  ipropColor = 14;
  ipropBkColor = 15;
  ipropShadowed = 16;
  ipropProtected = 17;
  ipropHidden = 18;
  ipropNoSuperSub = 19;
  ipropSuper = 20;
  ipropSub = 21;
  ipropUPSuper = 22;
  ipropDnSub = 23;
  ipropStrikeOut = 24;
  ipropDblStrikeOut = 25;
  ipropPard = 26;
  ipropLeftInd = 27;
  ipropRightInd = 28;
  ipropFirstInd = 29;
  ipropJust = 30;
  ipropVertJust = 31;
  ipropSpaceBefore = 32;
  ipropSpaceBetween = 33;
  ipropslmult = 34;
  ipropSpaceAfter = 35;
  ipropKeep = 36;
  ipropKeepn = 37;
  ipropParProperty = 38;
      // ------------------------------------------------------------ Tabstops
  ipropTabKind = 39;
  ipropTabFill = 40;
  ipropTabColor = 41;
  ipropTabPos = 42;
  ipropTabPosBar = 43;
  ipropSymbol = 44;
  ipropchftn = 45; //PR
      // ------------------------------------------------------------ Shading
  ipropShading = 46;
  ipropBColor = 47;
  ipropFColor = 48;
  ipropBackgroundPattern = 49;
      // Cells
  ipropShadingCELL = 50;
  ipropBColorCELL = 51;
  ipropFColorCELL = 52;
  ipropBackgroundPatternCELL = 53;
      // Table Style
  ipropShadingTS = 54;
  ipropBColorTS = 55;
  ipropFColorTS = 56;
  ipropBackgroundPatternTS = 57;
    //------------------------------------------------------------- Load Borders
  ipropBorderStartBOX = 58;
  ipropBorderStartDef = 59;
  ipropBorderStartDefROW = 60;
  ipropBorderStartDefCELL = 61;
  ipropBorderStartDefTS = 62;
  ipropBorderType = 63;
  ipropBorderWidth = 64;
  ipropBorderColor = 65;
  ipropBorderSpace = 66;
    //-------------------------------------------------- WPTOOLS PARAGRAPH FLAGS
  ipropCellFormat = 67;
  ipropAutoPageBreak = 68;
  ipropMaxPar = 69;
  ipropNoWordWrap = 70;
  ipropPreformatted = 71;
  ipropLineHeight = 72;
  ipropParID = 73;
  ipropParHidden = 74;
  ipropwpreadonly = 75; // The current RTFDataBlock is readonly! (Cannot be accessed in editor!)
  ipropParFLG = 76;

  ipropGroupEnd1 = 198;

//++++++++++++++ END GROUP 1 ++++++++++++++++++

    //----------------------------------------------------- PARAGRAPHS AND CELLS
  ipropTableStart = 198;
  ipropTableEnd = 199;
  ipropTableRowEnd = 200;
  ipropTableCellEnd = 201;
  ipropInTable = 202;
  ipropNestTableRow = 203;
  ipropNestTableCell = 204;
  ipropNestTableDepth = 205;
      // -------------------------------------------------------------------------
  ipropTableRowDefaults = 206;
  ipropTableCellDefaults = 207;
  ipropRowIndex = 208;
  ipropRowBandIndex = 209;
  ipropIsLastRow = 210;
  iproptrleft = 211;
  ipropTableCellX = 212;
  ipropTable_clmgf = 213;
  ipropTable_clmrg = 214;
  ipropTable_clvmgf = 215;
  ipropTable_clvmrg = 216;
  ipropTable_trftsWidth = 217;
  ipropTable_trwWidth = 218;
  // ---------------------------------------------------------- ROW&CELL PADDING
  iproptrgaph = 219;
  iproptableflags = 220;
  iproprowAutoFit = 221;
  iproprowflags = 222;
  iproprowalign = 223;
  iproprowheight = 224;
  ipropTable_trpaddl = 225;
  ipropTable_trpaddt = 226;
  ipropTable_trpaddr = 227;
  ipropTable_trpaddb = 228;
  ipropTable_trpaddfl = 229;
  ipropTable_trpaddft = 230;
  ipropTable_trpaddfr = 231;
  ipropTable_trpaddfb = 232;
  ipropTable_trspdl = 233;
  ipropTable_trspdt = 234;
  ipropTable_trspdr = 235;
  ipropTable_trspdb = 236;
  ipropTable_trspdfl = 237;
  ipropTable_trspdft = 238;
  ipropTable_trspdfr = 239;
  ipropTable_trspdfb = 240;
  // The RTF control words for setting the left and top
  // margins in a cell has been switched in the Microsft Office programs
  ipropTable_clpadl = 241;
  ipropTable_clpadt = 242;
  ipropTable_clpadr = 243;
  ipropTable_clpadb = 244;
  ipropTable_clpadfl = 245;
  ipropTable_clpadft = 246;
  ipropTable_clpadfr = 247;
  ipropTable_clpadfb = 248;
  ipropTable_clNoWrap = 249;
  ipropTable_clwWidth = 250;
  ipropTable_clwWidthF = 251;
  // Borders ... trbrdrt

        // -------------------------------------------------------- Load Images
  ipropPicSource = 252;
  ipropPicSourcePMeta = 253;
  ipropPicSourceWMeta = 254;
  ipropPicMetaWithBMP = 255;
  ipropPicSourceDIB = 256;
  ipropPicSourceWBit = 257;
  ipropPicPixels = 258;
  ipropPicPlanes = 259;
  ipropPicByteWidth = 260;
  ipropPicW = 261;
  ipropPicH = 262;
  ipropPicGoalW = 263;
  ipropPicGoalH = 264;
  ipropPicScaleX = 265;
  ipropPicScaleY = 266;
  ipropPicScaledMac = 267;
  ipropIsShape = 268;
  ipropCropL = 269;
  ipropCropR = 270;
  ipropCropT = 271;
  ipropCropB = 272;
  ipropPicTag = 273;
  ipropPicUnits = 274;
  ipropPicFloatObj = 275;
  ipropPicFloatObjRelX = 276;
  ipropPicFloatObjRelY = 277;
  ipropPicFloatObjWrap = 278;
  ipropOBJMODE = 279;
  ipropOBJFRAME = 280;
  ipropWPTXTOBJOpenTag = 281;
  ipropWPTXTOBJCloseTag = 282;
  iprop_iparam = 283;
      // ---------------------------------------------------------------- Shapes
  ipropshpleft = 284;
  ipropshptop = 285;
  ipropshpright = 286;
  ipropshpbottom = 287;
  ipropshpfhdr = 288;
  ipropshpbypage = 289;
  ipropshpbypara = 290;
  ipropshpwr = 291;
  ipropshpwrk = 292;
  ipropshpfblwtxt = 293;
  ipropshpbxcolumn = 294;
      // -------------------------------------------------------- Page Numbering
  ipropPgnX = 295;
  ipropPgnY = 296;
  ipropPgnFormat = 297;
      // ----------------------------------------------------------- Page Format
  ipropXaPage = 298;
  ipropYaPage = 299;
  ipropXaLeft = 300;
  ipropXaRight = 301;
  ipropYaTop = 302;
  ipropYaBottom = 303;
  ipropFacingp = 304;
  ipropLandscape = 305;
  ipropDeftab = 306;
  ipropWpspecialhf = 307;
  ipropYaMarginHeader = 308;
  ipropYaMarginFooter = 309;
  ipropWpprheadfoot = 310;
  ipropTitlePg = 311;
  ipropMarginMirror = 312;
  // ---------------------------------------------------------------- PAGE FRAME
  ipropPageFrame = 313;
  ipropPageFrameArt = 314;
  // ---------------------------------------------------------------------------
  ipropPgnStart = 315;
  ipropNewPageB = 316;
  ipropNewPage = 317;
  ipropNewPar = 318;
  ipropNewSection = 319;
  ipropSectionBreakMode = 320;
   // --------------------------------------------------------------------------
  ipropRtlLtrPar = 321;
  ipropwpshppos = 322;
  ipropSelSectionHdr = 323;
  ipropSelResetOutl = 324; // wpresoutl
  ipropPicFloatObjRelXNew = 325;
  ipropwpignpar = 326;
  ipropwppage = 327;
  iprop_frameparam = 328;
  iprop_modeparam = 329;
  iprop_frameextra = 330;
 
  ipropGroupEnd2 = 500;
//++++++++++++++ END GROUP 2 ++++++++++++++++++

  ipropS = 500;
  ipropCS = 501;
  ipropTS = 502;
  ipropDS = 503;
  ipropFN = 504;
  ipropadditive = 505;
  ipropsbasedOn = 506;
  ipropsnext = 507;
  ipropshidden = 508;
  ipropstyleid = 509;
  ipropautoupd = 510;
  ipropssemihidden = 511;
  // ---------------------------------------------------------------------------
  ipropListID = 512;
  ipropOutlineLevel = 513;
  ipropListTemplateID = 514;
  ipropListSimple = 515;
  ipropListRestartSection = 516;
  ipropListStyleID = 517;
  // ---------------------------------------------------------------------------
  ipropLevelStartAt = 518;
  ipropLevelnfc = 519;
  ipropLeveljc = 520;
  ipropLevelOld = 521;
  ipropLevelprev_O = 522;
  ipropLevelprevSpace_O = 523;
  ipropLevelindent_O = 524;
  ipropLevelspace_O = 525;
  ipropLevelFollow = 526;
  ipropLevelLegal = 527;
  ipropLevelNoRestart = 528;
  ipropLevelPicture = 529;
  ipropListOverrideCount = 530;
  ipropListNr = 531;
  ipropListLevel = 532;
  ipropPNLevel = 533;
  ipropPNStyle = 534;
  ipropPNIndent = 535;
  ipropPNFont = 536;
  ipropPNFontSize = 537;
  ipropPNFlag = 538;
  ipropPNStart = 539;
  ipropPNParFlag = 540;
 // ---------------------------------------------------------------------------
 // INIT VALUES
  ipropInfoItemType = 541;
  ipropUNIAnsiCodePage = 542;
  ipropUNICharCount = 543;
  ipropReadUnicodeChar = 544;
  ipropDefaultFont = 545;
  ipropFFMaxLength = 546;
  ipropFieldEdit = 547;
  ipropInsertPoint = 548;
  ipropAutomatic = 549;
  ipropobjtag = 550;
  ipropobjwidth = 551;
  ipropobjheight = 552;
  iproprtfcode = 553;
  ipropwpfnnr = 554;
  ipropBookmark = 555;
  ipropwbmpfile = 556;
  ipropWPNR = 557;
  ipropWPNRstyle = 558;
  ipropWPTableLeft = 559;
  ipropWPTableRight = 560;
  ipropFloatObjWrap = 561;

  ipropReadBinaryData = 567;
  ipropToclevel = 568;
  ipropexpndtw = 569;
  ipropXlevel = 570;
  ipropSpecialCharacters = 571;
  ipropHyphen = 572;
  ipropOutlinebreak = 573;
  ipropUpperCase = 574;
  ipropSelectedPar = 575;
  ipropWPColSpan = 576;
  ipropWPColFormat = 577;

  ipropHorzLineOffSets = 578;
  ipropHorzLineColor = 579;
  ipropHorzLineWidth = 580;
  ipropHorzLine = 581;
  ipropHorzLineTW = 582;

  ipropLowercase = 583;
  ipropSmallCaps = 584;
  ipropsIsDefault = 585;

  ipropswptoolsver = 586; // The tag \wptoolsver4 was only used by WPTools 4.22a and 4.25

  ipropGroupEnd3 = 600;
//++++++++++++++ END GROUP 3 ++++++++++++++++++
//++++++++ PREMIUM STARTS AT 1000 +++++++++++++

  // Some SUB Properties
  sbkNon = 0; sbkCol = 1; sbkEvn = 2; sbkOdd = 3; sbkPg = 4;
  pgDec = 1; pgURom = 2; pgLRom = 3; pgULtr = 4; pgLLtr = 5; pgRestartNumber = 6;

// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

constructor TWPRTFReader.Create(RTFDataCollection: TWPRTFDataCollection);
begin
  inherited Create(RTFDataCollection);
 
end;

destructor TWPRTFReader.Destroy;
begin
 
  inherited Destroy;
end;

procedure TWPRTFReader.PushStack;
var p: TWPRTFReaderStack;
begin
  p := TWPRTFReaderStack.Create(FRTFProps);
  if FStack <> nil then
  begin
    Attr.GetCA(FStack.CharAttr);
    if not FNeedStackAssign and
      (FCurrentParagraph <> nil) and
      not (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow]) then
    begin
      FStack.Assign(FCurrentParagraph);
      FStack.ADel(WPAT_ParProtected);
    end;
    p.Destination := FStack.Destination;
    p.AllIgnore := FStack.AllIgnore;
    p.FHasKeepN := FStack.FNextHasKeepnN; // FNextHasKeepnN !!
    p.FInTROWD := FStack.FInTROWD;
    p.FPrevious := FStack;
    p.Props := FStack.Props;
    p.Assign(FStack);
    p.ParNrStyle := FStack.ParNrStyle;
    p.FIgnoreNextImg := FStack.FIgnoreNextImg;
    p.FCurrentCodePage := FCurrentCodePage;
    FStack.FHasDefaultSectionBreak := FALSE;
  end;
  Attr.GetCA(p.CharAttr);
  // p.TabstopAssign(FCurrentParagraph);
  FStack := p;

  if (FStack.Destination = rdsStyleSheet) and not FStack.Props.InStyleDef then // a '{' in a style sheet!
  begin
    FReadingStyle := FStyleSheet.InitNext;
    FCurrentString.Clear;
    FStack.Props.InStyleDef := TRUE;
  end;
end;

function TWPRTFReader.PopStack: Boolean;
var p: TWPRTFReaderStack;
  i: Integer;
  s: String;
begin
  if (FStack = nil) or (FStack.FPrevious = nil) then
  begin
   //Assert(false, 'Too many "}" in RTF code');
    Result := FALSE
  end
  else
  begin
    p := FStack;

    if FStack.FHasDefaultSectionBreak then
    begin
      NewParagraph(); //V5.24.1
    end;

    if p.FHasKeepN and (FStack.FPrevious <> nil) and
      (not FStack.FPrevious.FHasKeepN)
      and not (FStack.Destination in [rdsField]) then
    begin
      if (FCurrentParagraph <> nil) and
        (FCurrentParagraph.ParagraphType <> wpIsTable) and //V5.24.4
        (FCurrentParagraph.PrevPar <> nil) and
        (FCurrentParagraph.PrevPar <> FKeepNWasAssignedToThisPar)
        then
        FCurrentParagraph.PrevPar.ADel(WPAT_ParKeepN);

    end;

    if (FStack.FPrevious <> nil)
      and ((FStack.FPrevious.Destination <> FStack.Destination) or
      ((FStack.Destination = rdsField)
      and (FStack.FFieldINST <> FStack.FPrevious.FFieldINST)))
      then
      CloseDestination(FStack.Destination, FStack.FPrevious.Destination)
    else if FStack.Destination = rdsStyleSheet then
    begin
     // -- This is one entry in the style table - add it to the List
      if (FStyleSheet <> nil) and (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
      begin
        s := FCurrentString.GetStringEX;
        if (Length(s) > 0) and (s[Length(s)] = ';') then
          FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyleName := Copy(s, 1, Length(s) - 1)
        else FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyleName := s;
        FStyleSheet.FStyles[FStyleSheet.FStyleCount].FUsedAs := 0;
        if not (loAddOnlyUsedStyles in LoadOptions) and
          not OptOnlyAddUsedStyles then
        begin
          for i := 0 to FStyleSheet.FStyleCount do
            FStyleSheet.Get(FStyleSheet.FStyles[i].FNum);
        end;
      end;
      FReadingStyle := nil;
      FCurrentString.Clear;
    end;

   { if FStack.Props.InNestCell and not FStack.FPrevious.Props.InNestCell then
    begin
      Assert(TableDepth > 0, 'Table Nesting Problem');
      if TableDepth > 0 then
      begin
        CloseCurrentRow;
        Dec(TableDepth);
      end;
    end; }
    // Restore previous RTFData
    if FStack.RestoreRTFData <> nil then
    begin

      // Delete the empty line which is caused by the last \par in the RTF code
      if (lastTagActionID = ipropNewPar) and
        (FCurrentParagraph <> nil) and
        (FCurrentParagraph.CharCount = 0) and
        (FCurrentParagraph.PrevPar <> nil) and
        (FCurrentParagraph.ParagraphType = wpIsSTDPar) then
      begin
        if FFirstLoadedFirstPar = FCurrentParagraph then
        begin
          FCurrentParagraph := FCurrentParagraph.DeleteParagraph;
          FFirstLoadedFirstPar := FCurrentParagraph;
        end
        else FCurrentParagraph := FCurrentParagraph.DeleteParagraph;
      end;
      PostProcessRTFData;
      if (FRTFData <> nil) and
        (FRTFData.Kind in [wpIsHeader, wpIsFooter]) and
        (FStack.RestoreRTFData.Kind = wpIsLoadedBody) then
        FLoadInHeaderFooter := false;
      FRTFData := FStack.RestoreRTFData;
      FCurrentColumnCount := FStack.FCurrentColumnCount;
      FColumnCount := FStack.FColumnCount;
      FColumn_X := FStack.FColumn_X;
      FColumn_Y := FStack.FColumn_Y;
      FNeedNewPageNextTime := FStack.FNeedNewPageNextTime;
      FCurrentParagraph := FStack.RestoreCurrentPar;
      if FTableVar <> nil then
      begin
        for i := 0 to FTableVar.Count - 1 do TObject(FTableVar[i]).Free;
        FTableVar.Free;
      end;
      FTableVar := FStack.RestoreTableVar;
      FTableDepth := FStack.RestoreTableDepth;
      FInSpecialText := FALSE;
      FFirstLoadedFirstPar := nil; 
      FStack.RestoreRTFData := nil;
      FStack.FNeedNewPageNextTime := false;
      FStack.RestoreCurrentPar := nil;
      FStack.Clear; // Do not inherit attributes to next text
      FNeedStackAssign := FALSE;
      //V5.26: was WPGetCodePage(OptCodePage);
      if OptCodePage > 0 then
        FCurrentCodePage := OptCodePage
      else FCurrentCodePage := WPGetCodePage(0); // Default!
      lastSpaceBetween := 0;
      lastSpaceBetweenHasValue := FALSE;
      lastSpaceSLMULT := -1;
    end;
    // Reset the global StringBuilder reference.
    if FStack.FFieldINSTAssigned then
    begin
      FStringBuilder := nil;
      FStack.FFieldINSTAssigned := FALSE;
    end;

    if FStack.Destination = rdsFieldStringBuilder then
    begin
      // Propagate the character attributes backwards to the field
      // since we need it for the field object
      FStack := FStack.FPrevious;
    end
    else
    begin
      FStack := FStack.FPrevious;
      Attr.SetCA(FStack.CharAttr);
      FCurrentCodePage := FStack.FCurrentCodePage;
    end;
  {  if FCurrentParagraph<>nil then
       FCurrentParagraph.TabstopAssign(FStack); }
    if (p.Destination <> rdsPNDef) and
      (p.Destination <> rdsCellCommand) and
      (p.Destination <> rdsCellName) and
      (p.Destination <> rdsParName) and
      (FCurrentParagraph <> nil) then // \*\pn group - propagate backwards!
    begin
      //NOT HERE!!!!
      // FCurrentParagraph.Assign(FStack, false);
      FNeedStackAssign := TRUE;
    end;
    p.Free;

    Result := (loNoRTFStartTags in LoadOptions) or (FStack.FPrevious <> nil);
  end;
end;

{$IFDEF USEAddDefaultParProps}

procedure TWPRTFReader.AddDefaultParProps(par: TParagraph);
var TextStyle: TWPTextStyle; dummy: Integer;
begin
  TextStyle := par.ABaseStyle;
  if (TextStyle <> nil) then
  begin
    if (TextStyle.AGet(WPAT_SpaceBetween, dummy) or
      TextStyle.AGet(WPAT_LineHeight, dummy))
      and not par.AGet(WPAT_SpaceBetween, dummy)
      and not par.AGet(WPAT_LineHeight, dummy) then
      par.ASet(WPAT_LineHeight, 100)
  end;
end;
{$ENDIF}

// StartNewSection returns FALSE if no section props should be created !

function TWPRTFReader.StartNewSection(par: TParagraph): Boolean;
begin
  if par <> nil then
  begin
    par.SectionID := FNewSectionID;
    include(par.prop, paprNewSection);
  end;
  Result := TRUE;
end;

// Completes section properties

procedure TWPRTFReader.InNewSection(par: TParagraph);
begin
  if FSectionBreakMode < 3 then // sbkpage, even, odd ...
    include(par.prop, paprNewPage); //ok, row
end;

procedure TWPRTFReader.CreateImplizitPar;
var par: TParagraph;
  i, j: Integer;
  NoPar: Boolean;
{$IFDEF WPPREMIUM} 
  ii: Integer;
{$ENDIF} 
begin
  // 5.20.7 --- this code is not required anymore. It caused extra paragraphs at end of text
{ if not FStack.Props.InTable and
    (FCurrentParagraph <> nil) and
    (FCurrentParagraph.ParagraphType = wpIsTable)
    //V5.20.5 commented
    // and (FCurrentParagraph.PrevPar = nil)
    and (FCurrentParagraph.RTFData.Kind = wpIsLoadedBody) //V5.19.8
    then
  begin
    NewParagraph;
    FNeedStackAssign := TRUE;
    FLastWasSTDPar := FALSE;
  end;  }

  NoPar := FCurrentParagraph = nil;

  if FNeedStackAssign and (FCurrentParagraph <> nil) and
    (FCurrentParagraph.ParagraphType <> wpIsTable) and
    not (paprNewColumn in FCurrentParagraph.prop) and
    (FCurrentParagraph.ParagraphType <> wpIsTableRow)
    then
  begin
{$IFDEF WPPREMIUM} 
    if FCurrentParagraph.AGet(WPAT_COLUMNS, i) then
    begin
      j := FCurrentParagraph.AGetDef(WPAT_COLUMNS_X, 0);
      ii := FCurrentParagraph.AGetDef(WPAT_COLUMNS_Y, 0);
      FCurrentParagraph.Assign(FStack, false);
      FCurrentParagraph.ASet(WPAT_COLUMNS, i);
      if j > 0 then FCurrentParagraph.ASet(WPAT_COLUMNS_X, j);
      if ii > 0 then FCurrentParagraph.ASet(WPAT_COLUMNS_Y, ii);
    end else
{$ENDIF} 
      FCurrentParagraph.Assign(FStack, false);
    FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle);

    if FStack.Props.IsRTLPar then
      include(FCurrentParagraph.prop, paprRightToLeft)
    else exclude(FCurrentParagraph.prop, paprRightToLeft);
  end;
  FNeedStackAssign := FALSE;

  if FLastWasSTDPar and FStack.Props.InTable and
    (FCurrentParagraph <> nil) and (FCurrentParagraph.ParagraphType <> wpIsTable)
    and (FCurrentParagraph.ParagraphType <> wpIsTableRow) then
  begin
    NewParagraph;
    FLastWasSTDPar := FALSE;
  end
  else FLastWasSTDPar := FALSE //V5.19.7 --- simple \pars after \page
    ;

  if FStack.Props.InTable then
  begin
    if FTableStart >= 0 then i := FTableStart else
    begin
      i := 0;
      {par := FCurrentParagraph; // Quickly calculate depth
      while (par<>nil) do
      begin
         if par.ParagraphType = wpIsTable then inc(i);
         par := par.ParentPar;
      end; }
    end;

    //V5.20.7 - fix problem with multiple nested tables in one cell
    if FTableVar <> nil then
      for j := TableDepth + 1 to FTableVar.Count - 1 do
      begin
        TableVar[j].FInsideCell := FALSE;
        TableVar[j].FInsideTable := FALSE;
        TableVar[j].FInsideRow := FALSE;
      end;

    while i <= TableDepth do
    begin
      CheckOpenCell(i);
      inc(i);
    end; // TableDepth

    FCurrentParagraph := TableVar[TableDepth].FLastCellInRow;
    if (FCurrentParagraph <> nil) and (paprIsTable in FCurrentParagraph.prop) then
    begin
      //V5.18.1 was:
      // FCurrentParagraph := FCurrentParagraph.LastInnerChild;
      if FCurrentParagraph.HasChildren then
      begin
        FCurrentParagraph := FCurrentParagraph.LastChild;
        if (FCurrentParagraph = nil) or (FCurrentParagraph.ParagraphType = wpIsTable) then
          NewParagraph(4)
        else FCurrentParagraph := FCurrentParagraph.LastInnerChild;
      end;
    end;
  end
  else if TableVar[TableDepth].FInsideTable then
  begin
    FCurrentParagraph := TableVar[TableDepth].FTableParent;
    //if (FCurrentParagraph.ParagraphType = wpIsTableRow) then ParLevelUp;
    TableVar[TableDepth].FInsideTable := FALSE;
    NewParagraph;
    FCurrentParagraph.Assign(FStack, false);
    FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle); //V5.12.5
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
  end else if FCurrentParagraph = nil then
  begin
    NewParagraph;
    FCurrentParagraph.Assign(FStack, False);
    FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle); //V5.12.5
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
  end;
  // This text is now part of a new setcion (after \sect }
  if not FInSpecialText and FIsNewSection then
  begin
    FIsNewSection := FALSE;
    par := FCurrentParagraph.ParentRow;
    if par = nil then par := FCurrentParagraph;
    if not StartNewSection(par) then
    begin
      RTFDataCollection.LastSectionID := FPrevSectionId;
      FCurrentSectionProps := RTFDataCollection.GetSectionProps(FPrevSectionId);
      RTFDataCollection.DeleteSectionProps(FNewSectionID);
      FNewSectionID := FPrevSectionId;
    end;
    InNewSection(par);
  end;

  if not FInSpecialText and FRestartPageNr then //pgnrestart
  begin
    include(FCurrentParagraph.prop, paprPagenrRestart);
    FRestartPageNr := FALSE;
  end;

  if FStartNewPageNextCreatePar then
  begin
    //was:include(FCurrentParagraph.prop, paprNewPage);
    FCurrentParagraph.IsNewPage := True; //V5.20.5
    FStartNewPageNextCreatePar := FALSE;
  end;

  if FNextParIsOutline > 0 then
  begin
    FCurrentParagraph.ASet(WPAT_ParIsOutline, FNextParIsOutline);
    FNextParIsOutline := 0;
  end;

  if FDelayedTxtObj <> nil then
  begin
{$IFDEF FIXUP_CHARSTYLES}
    if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
    for i := 0 to FDelayedTxtObj.Count - 1 do
      FCurrentParagraph.Append(TWPTextObj(FDelayedTxtObj[i]), Attr.CharAttr);
    FreeAndNil(FDelayedTxtObj);
  end;

  if FNeedNewPageNextTime then
  begin
    //was:include(FCurrentParagraph.prop, paprNewPage);
    FCurrentParagraph.IsNewPage := True; //V5.20.5
    FNeedNewPageNextTime := FALSE;
  end;

  if FStartParWithNumber > 0 then
  begin
    FCurrentParagraph.ASet(WPAT_NumberStart, FStartParWithNumber);
    FStartParWithNumber := 0;
  end;

  if NoPar and FStack.FHasKeepN then //V5.24.4
  begin
    FCurrentParagraph.ASet(WPAT_ParKeepN, 1);
    FKeepNWasAssignedToThisPar := FCurrentParagraph;
  end;
end;

procedure TWPRTFReader.CheckOpenCell(i: Integer); {called by CreateImplizitPar ONLY!}
var v, j: Integer;
  s: String;
  par: TParagraph;
begin
  if not TableVar[i].FInsideCell then
  begin
    // This resets the next, too!
    j := i + 1;
    while j <= TableDepth do
    begin
      TableVar[j].FInsideCell := FALSE;
      TableVar[j].FInsideTable := FALSE;
      TableVar[j].FInsideRow := FALSE;
      inc(j);
    end;

{$IFDEF SPLIT_TABLES_WITH_DIFFERENTWIDTH}
    if TableVar[i].FInsideTable and (TableVar[i].FTableParent <> nil) and
      (TableVar[i].FRowTbl.AllWidth <> TableVar[i].FRowTbl.LastAllWidth) then
    begin
      FCurrentParagraph := TableVar[i].FTableParent;
      NewParagraph(4);
      FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
      TableVar[i].FInsideTable := FALSE;
    end else
{$ENDIF}
      if TableVar[i].FDontCombineTables then //V5.19.6
      begin
        if (TableVar[i].FInsideTable or
          (FCurrentParagraph.ParagraphType = wpIsTable))
          and (TableVar[i].FTableParent <> nil) then
        begin
          FCurrentParagraph := TableVar[i].FTableParent;
          NewParagraph(4);
          FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
          TableVar[i].FInsideTable := FALSE;
        end;
        TableVar[i].FDontCombineTables := FALSE;
      end;

    if not TableVar[i].FInsideTable then
    begin
           // V5.11 - new code to avoid 'tabele in table' reading errors
      if (FCurrentParagraph <> nil) and
        (FCurrentParagraph.ParagraphType = wpIsTableRow) then
      begin
            // SHOULD NOT HAPPEN!!!!
        s := 'RTFReader: Table nesting problem:' + IntToStr(ReadPosition);
        OutputDebugString(PChar(s));
        TableVar[i].FTableParent := FCurrentParagraph.ParentTable;
        TableVar[i].FInsideTable := TRUE;
        TableVar[i].FInsideRow := FALSE;
        TableVar[i].FFirstCellInRow := nil;
        TableVar[i].FLastCellInRow := nil;
      end else
      begin
        if (FCurrentParagraph <> nil) and (paprIsTable in FCurrentParagraph.prop) then
        begin
           // include( FCurrentParagraph.prop, paprNoHeight );
          NewChildParagraph(0);
        end else
          if (FCurrentParagraph = nil) or
            (FCurrentParagraph.CharCount > 0) or
            ((FCurrentParagraph.ParentPar <> nil) and
            (paprIsTable in FCurrentParagraph.ParentPar.prop)) then
          begin
    {        if (FCurrentParagraph=nil) or
          (not ((FCurrentParagraph.CharCount = 0) and
          (TableDepth > 0) and
          (FCurrentParagraph.ParentPar <> nil) and
          (paprIsTable in FCurrentParagraph.ParentPar.prop))) then }
            if (TableDepth > 0) and (FCurrentParagraph <> nil) then
            begin
              if (paprIsTable in FCurrentParagraph.prop) or
                (FCurrentParagraph.ParagraphType <> wpIsSTDPar) then //V5.18.5
                NewChildParagraph
              else if (FCurrentParagraph.CharCount > 0) or
                FLastWasSTDPar then
                NewParagraph(0);
            end
            else
              NewParagraph(0);
            if FCurrentParagraph.CharCount = 0 then
              FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
          end;

        FCurrentParagraph.ParagraphType := wpIsTable;
        FCurrentParagraph.Name := FTableName;
        FTableName := '';

        TableVar[i].FTableParent := FCurrentParagraph;
        TableVar[i].FInsideTable := TRUE;
        TableVar[i].FInsideRow := FALSE;
        TableVar[i].FFirstCellInRow := nil;
        TableVar[i].FLastCellInRow := nil;
      end;
    end;

    if not TableVar[i].FInsideRow then
    begin
      FCurrentParagraph := TableVar[i].FTableParent;

          // V5.17.5 Split the current table if the new row uses different position attributes
{$IFNDEF NO_RTFSPLIT_TABLES}
      begin
        if TableVar[i].FRowTbl.BoxWidth <> 0 then v := TableVar[i].FRowTbl.BoxWidth
        else
        begin
          if TableVar[i].FRowTbl.AllWidth <> 0 then
            v := TableVar[i].FRowTbl.AllWidth //V5.18.9
          else v := FCurrentParagraph.AGetDef(WPAT_BoxWidth, 0);
        end;
        if (FCurrentParagraph.ChildPar <> nil) and
          ((Abs(v - FCurrentParagraph.AGetDef(WPAT_BoxWidth, v)) > 20)
          or ((TableVar[i].FRowTbl.BoxWidth_PC <> 0) and
          (Abs(TableVar[i].FRowTbl.BoxWidth_PC * 2 -
          FCurrentParagraph.AGetDef(WPAT_BoxWidth_PC, 10000)) > 20))
          or (Abs(TableVar[i].FRowTbl.RowLeft -
          FCurrentParagraph.AGetDef(WPAT_BoxMarginLeft, 0)) > 20)
              // not required:  or (FCurrentParagraph.ColCount<>TableVar[i].FRowTbl.CellCount)
          )
          then
        begin
          TableVar[i].FTableParent := TParagraph.Create(FRTFProps, FWorkRTFData);
          FCurrentParagraph.NextPar := TableVar[i].FTableParent;
          FCurrentParagraph := TableVar[i].FTableParent;
          FCurrentParagraph.ParagraphType := wpIsTable;
        end;
      end;
{$ENDIF}
          // -------------------------------------------------------------------

      NewChildParagraph(0);
      FCurrentParagraph.ParagraphType := wpIsTableRow;

      if FNeedNewPageNextTime then
      begin
        include(FCurrentParagraph.prop, paprNewPage); //ok, row
        FNeedNewPageNextTime := FALSE;
      end;

      if OptIgnoreTableWidth then
        TableVar[i].FRowTbl.AllWidth := 0; //V5.19.5a

      TableVar[i].FTableRow := FCurrentParagraph;
      TableVar[i].FInsideRow := TRUE; TableVar[i].FInsideCell := FALSE;
      TableVar[i].FFirstCellInRow := nil;
      TableVar[i].FLastCellInRow := nil;
      if TableVar[i].FRowTbl.RowLeft <> 0 then
      begin

          par := FCurrentParagraph.ParentTable;
        if par <> nil then par.ASet(WPAT_BoxMarginLeft, TableVar[i].FRowTbl.RowLeft);
      end;

      if (((TableVar[i].FRowTbl.RowFlags and WPRDFLAG_RAutoFit) = 0)
        or (wpDisableAutosizeTables in RTFDataCollection.FormatOptions)) //V5.18.1
        and (TableVar[i].FRowTbl.AllWidth <> 0) and
        (TableVar[i].FTableParent <> nil) then
      begin
        if TableVar[i].FRowTbl.BoxWidth > 0 then
          TableVar[i].FTableParent.ASet(WPAT_BoxWidth,
            TableVar[i].FRowTbl.BoxWidth)
        else if TableVar[i].FRowTbl.BoxWidth_PC > 0 then
          TableVar[i].FTableParent.ASet(WPAT_BoxWidth_PC,
            TableVar[i].FRowTbl.BoxWidth_PC * 2)
        else
        begin
          v := TableVar[i].FTableParent.AGetDef(WPAT_BoxWidth, 0); //V5.14
          if TableVar[i].FRowTbl.AllWidth > v then
          begin
            TableVar[i].FTableParent.ASet(WPAT_BoxWidth,
              TableVar[i].FRowTbl.AllWidth);

         //V5.20.9 - error!

            TableVar[i].FRowTbl.BoxWidth := TableVar[i].FRowTbl.AllWidth; //V5.20.5

          end;
            {  if TableVar[i].FRowTbl.AllWidth=7701 then
                TableVar[i].FTableParent.State := TableVar[i].FTableParent.State +
                  [wpstystateDebugLock]; }
        end;
      end;
      TableVar[i].FRowTbl.LastAllWidth := TableVar[i].FRowTbl.AllWidth;
      TableVar[i].FRowTbl.AllWidth := 0; //V5.19.5a
      if i > 0 then // in nested cell trowd comes at the end !
        TableVar[i].FRowTbl.CellCount := 0; //V5.30.3
    end;

    if (FCurrentParagraph <> nil) and //V5.17
      (FCurrentParagraph.ParagraphType = wpIsTableRow) then
    begin
      FCurrentParagraph := FCurrentParagraph;
    end
    else
      FCurrentParagraph := TableVar[i].FTableRow;
    NewChildParagraph;
    if FCurrentParagraph.CharCount = 0 then
      FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
    FCurrentParagraph.Assign(FStack, False);
    FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle);
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
    FCurrentParagraph.ParagraphType := wpIsSTDPar;
      //NO FCurrentParagraph.ASetBaseStyle(0);
    include(FCurrentParagraph.prop, paprIsTable);
    if TableVar[i].FFirstCellInRow = nil then
      TableVar[i].FFirstCellInRow := FCurrentParagraph;
    TableVar[i].FLastCellInRow := FCurrentParagraph;
    TableVar[i].FInsideCell := TRUE;
  end;
end;

procedure TWPRTFReader.SkippedText(aCh: Integer);
begin
end;

procedure TWPRTFReader.ApplyShapeProps(txtobj: TWPTextObj);
var aLeft, aTop: Integer;
begin
  if FShape.shpright < FShape.shpleft then
    aLeft := FShape.shpright 
  else aLeft := FShape.shpleft;

  if FShape.shpbottom < FShape.shptop then
    aTop := FShape.shpbottom 
  else aTop := FShape.shptop;

 
    case FShape.shpbxmode of
      1: txtobj.RelX := aLeft + FShape.dx; // Paragraph
      2: txtobj.RelX := aLeft + Layout.margl; // Column = default
    else txtobj.RelX := aLeft; // Page=Default
    end;

  if FShape.shpfblwtxt = 1 then
    txtobj.Mode := txtobj.Mode + [wpobjObjectUnderText];
  // Simplified: - only check Y mode, WPTools does not mix modes!

 
    if FShape.shpbypara then
    begin
      txtobj.Mode := txtobj.Mode + [wpobjRelativeToParagraph];
      txtobj.RelY := aTop;
    end
    else if FShape.shpbypage or not FShape.shpbychar then //V5.30.5
    begin
      txtobj.Mode := txtobj.Mode + [wpobjRelativeToPage];
      txtobj.RelY := aTop + FShape.dy;
    end
    else if FShape.shpbychar then // images use this mode
    begin
      txtobj.Mode := txtobj.Mode - [wpobjRelativeToParagraph, wpobjRelativeToPage];

    end;

  if (FShape.shpwr = 1) {or (FShape.shpwr=0)} then
    txtobj.Wrap := wpwrUseWholeLine
  else if (FShape.shpwr = 2) or (FShape.shpwr = 4) or (FShape.shpwr = 5) then
    case FShape.shpwrk of
      0: txtobj.Wrap := wpwrBoth;
      1: txtobj.Wrap := wpwrLeft;
      2: txtobj.Wrap := wpwrRight;
    else txtobj.Wrap := wpwrAutomatic;
    end
  else txtobj.Wrap := wpwrNone; // Text through object ! (shpwr=3)

  // obsolte:
  case FShape.WPPosmode of
    1: txtobj.Mode := txtobj.Mode + [wpobjPositionInMargin];
    2: txtobj.Mode := txtobj.Mode + [wpobjPositionAtCenter];
    3: txtobj.Mode := txtobj.Mode + [wpobjPositionAtRight];
  end;
  if (FShape.wpExtra and 1) <> 0 then
    txtobj.Mode := txtobj.Mode + [wpobjDisableAutoSize];

  ApplyFrameModeParams(FFieldFrameParam, FFieldModeParam, txtobj);

  // Set size using the shape position
  if (FShape.shpright - FShape.shpleft <> 0)
    and (FShape.shpbottom - FShape.shptop <> 0)
    and (txtobj.Width = 0) and (txtobj.Height = 0) // picwgoal, pichgoal is better!
    then
  begin
    txtobj.Width := Abs(FShape.shpright - FShape.shpleft);
    // if txtobj.Width < 0 then txtobj.Width := 0;
    txtobj.Height := Abs(FShape.shpbottom - FShape.shptop);
    // if txtobj.Height < 0 then txtobj.Height := 0;
  end;

  FShape.shpbxmethod := 2;
  FShape.shpbymethod := 2;
  FShape.shpbxmode := 2;
  FShape.shpbypara := true;
end;

procedure TWPRTFReader.ApplyFrameModeParams(FrameParam, ModeParam: Integer; txtobj: TWPTextObj);
begin
  if txtobj <> nil then
  begin
    if FrameParam <> 0 then
    begin
      if (FrameParam and 1) <> 0 then txtobj.Frame := txtobj.Frame + [wpframeFine];
      if (FrameParam and 2) <> 0 then txtobj.Frame := txtobj.Frame + [wpframe1pt];
      if (FrameParam and 4) <> 0 then txtobj.Frame := txtobj.Frame + [wpframe2pt];
      if (FrameParam and 8) <> 0 then txtobj.Frame := txtobj.Frame + [wpframeShadow];
    end;

    if (ModeParam <> 0) then
    begin
      if (ModeParam and 1) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjObjectUnderText];
      if (ModeParam and 2) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjPositionAtRight];
      if (ModeParam and 4) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjPositionAtCenter];
      if (ModeParam and 8) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjPositionInMargin];
      if (ModeParam and 16) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjLockedPos];
      if (ModeParam and 32) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjSizingDisabled];
      if (ModeParam and 64) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjSizingAspectRatio];
      if (ModeParam and 128) <> 0 then txtobj.Mode := txtobj.Mode + [wpobjReadSourceFromEmbeddedText];
    end;
  end;
end;

 

procedure TWPRTFReader.CloseDestination(CurrentDest, NewDest: TWPRDS);
var obj: TWPObject;
  txtobj: TWPTextObj;
  ftype, fname, fcommand: string;
  ele: TWPRTFStyleElement;
  ditem: TWPRTFExtraDataItem;
  numstyle: TWPNumberStyle;
  numfont, FieldInst: string;
  i, fontstyle: Integer;
  c: Char;
  FWPToolsVersionDC: Extended;
begin
  if (CurrentDest = rdsPicture) and not OptNoImages then
  begin
    if not FPicture.HasBinData and (FPicture.pData.Size > 0) then
      WPHexStreamToBinStream(FPicture.pData);
    obj := CreateObject;
    try
      if obj <> nil then
      begin
        FLastPictWasUnknown := FALSE;
        CreateImplizitPar;
        txtobj := PrintTextObj(wpobjImage, FPictureName, '', false, false, false);
        txtobj.Source := FPictureSource;
        FPictureSource := '';
        FPictureName := '';
        if obj is TWPTempSaveTextObjHelper then
        begin
          txtobj.ASetWPSS(AnsiString(obj.Extra));
          // TWPTempSaveTextObjHelper are only temporarily used
          FreeAndNil(obj);
        end else
          if obj is TWPODummyObject then
          begin
            if (CompareText(obj.Name, 'TWPOHorzLine') = 0) then
              txtobj.ObjType := wpobjHorizontalLine
            else
            begin
              txtobj.Width := obj.WidthTW;
              txtobj.Height := obj.HeightTW;
            end;
          // TWPODummyObject are only temporarily used
            FreeAndNil(obj);
          end else // regular image
          begin
            txtobj.ObjRef := obj;

            if obj.StreamName <> '' then //V5.17.3
            begin
              RTFDataCollection.RequestHTTPImage(Self, FLoadPath, obj.StreamName, txtobj);
            // see: procedure TWPRTFReader.LoadLinkedImage
              txtobj.Source := obj.StreamName;
            end;

            txtobj.Width := obj.WidthTW;
            txtobj.Height := obj.HeightTW;

          (* V5.19.7 - resizing not required since the format routine does this already!

            if FCurrentSectionProps._Layout.landscape then
            begin
              if txtobj.Height > FCurrentSectionProps._Layout.paperw then
                txtobj.Height := FCurrentSectionProps._Layout.paperw;
              if txtobj.Width > FCurrentSectionProps._Layout.paperh then
                txtobj.Width := FCurrentSectionProps._Layout.paperh;
            end else
            begin
              if txtobj.Width > FCurrentSectionProps._Layout.paperw then
                txtobj.Width := FCurrentSectionProps._Layout.paperw;
              if txtobj.Height > FCurrentSectionProps._Layout.paperh then
                txtobj.Height := FCurrentSectionProps._Layout.paperh;
            end; *)

            if FShape.reading then // WORD wrapmodes
            begin
              ApplyShapeProps(txtobj);

 

            end else
            begin
              if FPicture.wpFloatMode <> 0 then // WPTools WrapModes
              begin
                if FPicture.wpFloatMode = 2 then
                  txtobj.Mode := [wpobjRelativeToPage]
                else txtobj.Mode := [wpobjRelativeToParagraph];
                txtobj.RelX := FPicture.wpFloatX;
                txtobj.RelY := FPicture.wpFloatY;
                if FPicture.wpWrapMode in [0..4] then
                  txtobj.Wrap := TTextObjWrap(FPicture.wpWrapMode);
              end;
              if FPicture.wpModeMode <> 0 then
              begin
                txtobj._IntToMode(FPicture.wpModeMode);
                if (wpobjCreateAutoName in txtobj.Mode) and
                  (txtobj.ObjRef <> nil) then txtobj.ObjRef.MakeUniqueName;
              end;
              if FPicture.wpFrameMode <> 0 then txtobj._IntToFrame(FPicture.wpFrameMode);
            end;
          end; // else: regular image
      end else FLastPictWasUnknown := TRUE;
    finally
      FPicture.Clear;
      FPicture.pReading := FALSE;
      FShape.reading := FALSE;
    end;
  end
 
  else if CurrentDest = rdsFieldStringBuilder then
  begin
     // We just read the field instructions so we need to check if there is some text coming
    if FStack.FFieldINST <> nil then
      FieldInst := Uppercase(FStack.FFieldINST.GetFirstWord)
    else if FStringBuilder <> nil then //V5.12.1
    begin //V5.12.1
      FieldInst := Uppercase(FStringBuilder.GetFirstWord); //V5.12.1
      if FieldInst = 'MERGEFIELD' then //V5.12.1
      begin
        FWaitForInsertPoint := TRUE; //V5.12.1
      end;
    end
    else FieldInst := '';
    if (FStack.FFieldINST <> nil) and (FieldInst = 'MERGEFIELD') then
    begin
      FWaitForInsertPoint := TRUE;
    end else
      if (FStack.FPrevious <> nil) and
        (FStack.FPrevious.FFieldINST <> nil) and (FieldInst = 'MERGEFIELD') then
      begin
        FWaitForInsertPoint := TRUE;
      end
      else if FStack.FFieldINST <> nil then // insert a standard text object
      begin
         // V5.11.2
        CreateImplizitPar;
        PrintTextObj(wpobjTextObject, FieldInst, FStack.FFieldINST.GetRest, false,
          false, false);
      end;
  end
  // WPTools 5 Standard Footnote support
  else if CurrentDest = rdsFootnote then
  begin
    if FCurrentParagraph <> nil then
    begin
      c := Char(FCurrentParagraph.LastChar(true, #32));
      txtobj := PrintTextObj(wpobjFootnote, '', FCurrentString.GetString, false,
        false, false);
      if (txtobj <> nil) and (c > #32) then
        txtobj.Params := c;
    end;
  end
  else if FStack.Destination = rdsLevelText then // also uses StringBuilder!
  begin
    if (FCurrentList <> nil) and (FCurrentList.CurrentStyle <> nil) then
    begin
      // Ignore last ';'!!
      if (FCurrentNumberString <> '') and (FCurrentNumberString[Length(FCurrentNumberString)] = ';') then
        delete(FCurrentNumberString, Length(FCurrentNumberString), 1);

      // Byte1 = Length
      if FCurrentNumberString <> '' then FCurrentNumberString := Copy(FCurrentNumberString, 2,
          Integer(FCurrentNumberString[1]));
      FCurrentList.CurrentStyle.ASet(
        WPAT_NumberTEXT, FCurrentList.CurrentStyle.AStringToNumber(
        FCurrentNumberString));
      FCurrentString.Clear;
    end;
  end
  else if (FStack.Destination = rdsPNDef) and not OptNoNumStyles then // Close Level Group
  begin
    if FPNGroup.Reading then
    begin
      case FPNGroup.MODE of
        WPNUM_ARABIC: numstyle := wp_1;
        WPNUM_UP_ROMAN: numstyle := wp_lg_i;
        WPNUM_LO_ROMAN: numstyle := wp_i;
        WPNUM_UP_LETTER: numstyle := wp_lg_a;
        WPNUM_LO_LETTER: numstyle := wp_a;
        WPNUM_LO_ORDINAL: numstyle := wp_1st;
        WPNUM_Text: numstyle := wp_One;
        WPNUM_ORDINAL_TEXT: numstyle := wp_First;
        WPNUM_WIDECHAR: numstyle := wp_unicode;
        WPNUM_CHAR: numstyle := wp_char;
        WPNUM_CIRCLE: numstyle := wp_circle;
        WPNUM_ARABIC0: numstyle := wp_01;
        WPNUM_BULLET: numstyle := wp_bullet;
      else numstyle := wp_none; // wasd wp_1, V5.185
      end;
      if FPNGroup.Font <= 0 then numfont := ''
      else numfont := FRTFProps.GetFontName(FFontTbl.Fontnr[FPNGroup.Font]);

      if FReadingStyle <> nil then
      begin
        if numstyle <> wp_none then
        begin
          fontstyle := FRTFProps.NumberStyles.AddNumberStyle(numstyle,
            FPNTEXTB, FPNTEXTA, numfont,
            FPNGroup.INDENT, FPNGroup.FONTSIZE,
            (FPNGroup.FLAGS and WPNUM_FLAGS_USEPREV) <> 0,
            0, 0);

          FReadingStyle.ASet(WPAT_NumberSTYLE, fontstyle);
          FReadingStyle.ASet(WPAT_NumberLEVEL, FPNGroup.LEVEL);
        end;
      end else
      begin
        fontstyle := FRTFProps.NumberStyles.AddNumberStyle(numstyle,
          FPNTEXTB, FPNTEXTA, numfont,
          FPNGroup.INDENT, FPNGroup.FONTSIZE,
          (FPNGroup.FLAGS and WPNUM_FLAGS_USEPREV) <> 0,
          0, 0);

        CreateImplizitPar;
        if FCurrentParagraph <> nil then
        begin
          FCurrentParagraph.ASet(WPAT_NumberSTYLE, fontstyle);
          FCurrentParagraph.ASet(WPAT_NumberLEVEL, FPNGroup.LEVEL);
          if not FPNGroup.Reading then FCurrentParagraph.ADel(WPAT_NumberFLAGS);
        end;
      end;
      FPNGroup.Reading := FALSE;
      FPNTEXTA := '';
      FPNTEXTB := '';
    end;
  end
  else if FStack.Destination = rdsPNTextA then // also uses StringBuilder!
  begin
    if FPNGroup.Reading then
      FPNTEXTA := FCurrentString.GetStringEX
    else
      if FReadingStyle <> nil then
        FReadingStyle.ASet(WPAT_NumberTEXTA, FReadingStyle.AStringToNumber(FCurrentString.GetStringEX))
      else if FCurrentParagraph <> nil then
        FCurrentParagraph.ASet(WPAT_NumberTEXTA, FCurrentParagraph.AStringToNumber(FCurrentString.GetStringEX));
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsPNTextB then // also uses StringBuilder!
  begin
    if FPNGroup.Reading then
      FPNTEXTB := FCurrentString.GetStringEX
    else
      if FReadingStyle <> nil then
        FReadingStyle.ASet(WPAT_NumberTEXTB, FReadingStyle.AStringToNumber(FCurrentString.GetStringEX))
      else if FCurrentParagraph <> nil then
        FCurrentParagraph.ASet(WPAT_NumberTEXTB, FCurrentParagraph.AStringToNumber(FCurrentString.GetStringEX));
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsPNStyle then // also uses StringBuilder!
  begin
    if (FOldListTableLevel in [1..9]) and (FOldListTable[FOldListTableLevel] <> nil) then
    begin
      if FOldListTableGroup = 0 then
        FOldListTableGroup := FRTFProps.NewOutlineGroup;
      ele := FRTFProps.NumberStyles.Add('pnlvl' + IntToStr(FOldListTableLevel)); // MASK!!!
      FOldListTable[FOldListTableLevel].ASet(WPAT_NumberLEVEL, FOldListTableLevel - 1);
      ele.TextStyle.Assign(FOldListTable[FOldListTableLevel]);
      ele.Group := FOldListTableGroup;
      ele.LevelInGroup := FOldListTableLevel - 1;
      FOldListTableUseAs[FOldListTableLevel] := ele.ID;
    end;
    FOldListTableLevel := 0;
    FReadingStyle := nil
  end
  else if FStack.Destination = rdsListName then
  begin
    if FCurrentList <> nil then
    begin
      FCurrentList.FListName := FCurrentString.GetStringEX;
      FCurrentString.Clear;
    end;
  end
  else if FStack.Destination = rdsffname then
  begin
    FCurrFieldName := FCurrentExString.GetStringEX;
    FCurrentExString.Clear;
  end
  else if FStack.Destination = rdsffdeftext then
  begin
    FCurrFieldText := FCurrentExString.GetStringEX;
    FCurrentExString.Clear;
  end
  else if FStack.Destination = rdsffformat then
  begin
    FCurrFieldFormat := FCurrentExString.GetStringEX;
    FCurrentExString.Clear;
  end
  else if FStack.Destination = rdsList then
  begin
    FReadingStyle := nil;
  end
  else if FStack.Destination = rdsStyleSheet then
  begin
    FReadingStyle := nil;
  end
  else if FStack.Destination = rdsPicName then
  begin
    FPictureName := FCurrentExString.GetStringEX;
    FCurrentExString.Clear;
  end
  else if FStack.Destination = rdsPicSource then
  begin
    FPictureSource := FCurrentExString.GetStringEX;
    FCurrentExString.Clear;
  end
  else if FStack.Destination = rdsBookmark then
  begin
    fname := FCurrentString.GetStringDequoted;
    if (FCurrentParagraph = nil) or //V5.15.1
      (FCurrentParagraph.ParagraphType <> wpIsSTDPar) or
      (FStack.Props.InTable and
      (FCurrentParagraph.ParagraphType = wpIsSTDPar) and
      (FCurrentParagraph.ParentPar = nil) and
      not (paprisTable in FCurrentParagraph.prop)) then
    begin
       //DANGEROUS!!!  CreateImplizitPar;
       // We delay this object until the next char is printed!
      txtobj := TWPTextObj.Create;
      txtobj.ObjType := wpobjBookmark;
      txtobj.Name := fname;
      if FIsBookmarkStart then
        txtobj.Mode := [wpobjUsedPairwise, wpobjIsOpening]
      else txtobj.Mode := [wpobjUsedPairwise, wpobjIsClosing];
      if FDelayedTxtObj = nil then
        FDelayedTxtObj := TList.Create;
      FDelayedTxtObj.Add(txtobj);
    end else
      PrintTextObj(wpobjBookmark, fname, // Name, Source: string;
        '', true, not FIsBookmarkStart, false);
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsMergeVar then
  begin
    FCurrentMergeVar := FCurrentString.GetString;
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsMergePar then
  begin
    FCurrentMergePar := FCurrentString.GetString;
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsParName then
  begin
    if FIsTableName then
      FTableName := FCurrentString.GetString
    else
    begin
      CreateImplizitPar;
      if (FCurrentParagraph <> nil) then
        FCurrentParagraph.Name := FCurrentString.GetString;
    end;
    FCurrentString.Clear;
    FIsTableName := FALSE;
  end
  else if FStack.Destination = rdsCellName then
  begin
    CreateImplizitPar;
    if (FCurrentParagraph <> nil) then
      FCurrentParagraph.ASetStringProp(WPAT_PAR_NAME, FCurrentString.GetString);
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsCellCommand then
  begin
    CreateImplizitPar;
    if (FCurrentParagraph <> nil) then
      FCurrentParagraph.ASetStringProp(WPAT_PAR_COMMAND, FCurrentString.GetString);
    FCurrentString.Clear;
    FNeedStackAssign := FALSE;
  end
  else if FStack.Destination = rdsElementName then
  begin
    FCurrentElementName := FCurrentString.GetString;
    FCurrentString.Clear;
  end
  else if FStack.Destination = rdsInfoItem then
  begin
    if FInfoItemName = 'Generator' then
    begin
       // Load WPTools Version as FloatingPoint Variable
      FWrittenByGenerator := FCurrentString.GetString;
      // V5.19.7 - modify "generator"
      RTFDataCollection.RTFVariables.Strings['generator'] :=
        FWrittenByGenerator;

      i := Pos('WPTools_', FWrittenByGenerator);
      if i > 0 then
      begin
        inc(i, 8);
        FWrittenByWPToolsVersion := 0;
        FWPToolsVersionDC := 1;
        while (i <= Length(FWrittenByGenerator))
          and (FWrittenByGenerator[i] in ['0'..'9']) do
        begin
          FWrittenByWPToolsVersion := FWrittenByWPToolsVersion * 10 +
            Integer(FWrittenByGenerator[i]) - Integer('0');
          inc(i);
        end;
        if (i <= Length(FWrittenByGenerator)) and
          (FWrittenByGenerator[i] = '.') then
        begin
          inc(i);
          while (i <= Length(FWrittenByGenerator))
            and (FWrittenByGenerator[i] in ['0'..'9']) do
          begin
            FWrittenByWPToolsVersion := FWrittenByWPToolsVersion * 10 +
              Integer(FWrittenByGenerator[i]) - Integer('0');
            FWPToolsVersionDC := FWPToolsVersionDC * 10;
            inc(i);
          end;
        end;
        FWrittenByWPToolsVersion := FWrittenByWPToolsVersion / FWPToolsVersionDC;
          // Ignore KeepN with previous WPTools was <5.11
        if (FWrittenByWPToolsVersion > 0) and (FWrittenByWPToolsVersion < 5.11) then
          OptIgnoreKeepN := TRUE;

      end;
    end
{$IFDEF LOAD_GENERATORNAME}; {$ELSE} else {$ENDIF}
    // This code would create simple <xxx yyy/> objects:
    // txtobj := PrintTextObj(wpobjCode, FInfoItemName,FCurrentString.GetString, false, false, false );
    // We are using this code to add variables to the 'RTFVariables'
      if not (loDontLoadRTFVariables in FLoadOptions) and not OptNoVariables then
      begin
        ditem := RTFDataCollection.RTFVariables.Find(FInfoItemName, wpxText);
        if ((ditem = nil) and not (loDontAddRTFVariables in LoadOptions))
          or ((ditem <> nil) and (wpxLoadFromRTF in ditem.Options)) then
        begin
          if ditem = nil then ditem := TWPRTFExtraDataItem(RTFDataCollection.RTFVariables.Add);
          ditem.Name := FInfoItemName;
          ditem.Mode := wpxText;
          ditem.Options := ditem.Options + [wpxSaveToRTF]; // since we loaded ....
          ditem.Text := FCurrentString.GetString;
          case FInfoItemType of
            3: ditem.SubType := wpxNumber;
            11: ditem.SubType := wpxBoolean;
            64: ditem.SubType := wpxDate;
            30: ditem.SubType := wpxString;
          else
            ditem.SubType := wpxDefault;
          end;
        end;
      end;
    FCurrentString.Clear;
    FInfoItemName := '';
  end
  else if (CurrentDest = rdsWPBinDataHex) and (FInfoItemName <> '') then
  begin
    ditem := RTFDataCollection.RTFVariables.Find(FInfoItemName, wpxData);
    if ((ditem = nil) and not (loDontAddRTFVariables in LoadOptions)
      and not OptDontAddRTFVariables
      )
      or ((ditem <> nil) and (wpxLoadFromRTF in ditem.Options))
      then
    begin
      if ditem = nil then ditem := RTFDataCollection.RTFVariables.AddStreamItem(FInfoItemName);
      ditem.Data.Clear;
      if FWPBinData.Size > 0 then
      begin
        FWPBinData.Position := 0;
        WPHexStreamToBinStream(FWPBinData);
        ditem.Data.CopyFrom(FWPBinData, FWPBinData.Size);
        ditem.Data.Position := 0;
      end;
      FWPBinData.Clear;
      FInfoItemName := '';
    end;
  end
  else if CurrentDest = rdsField then
  begin
    FWaitForInsertPoint := FALSE;
    if FCurrentString.FToObject <> nil then
    begin
      FCurrentString.FToObject.Params := FCurrentString.GetString;
      if (FCurrentString.FToObject.IParam = 0) and (FFieldIParam <> 0) then FCurrentString.FToObject.IParam := FFieldIParam;
      ApplyFrameModeParams(FFieldFrameParam, FFieldModeParam, FCurrentString.FToObject);
      FFieldFrameParam := 0;
      FFieldModeParam := 0;
      FFieldIParam := 0;
      FCurrentString.FToObject := nil;
    end else
      if FStack.FFieldINST <> nil then
      begin
        txtobj := nil;
        ftype := Uppercase(FStack.FFieldINST.GetFirstWord);
        // if ftype = 'PAGENUMBER' then ftype := 'PAGE'; // <-- fix it
        //+++++++++ SINGULAR FIELDS ++++++++++++++++++++++++++++++++++++++++++++
        if (ftype = 'PAGE') or
          (ftype = 'NEXTPAGE') or
          (ftype = 'PRIORPAGE') or
          (ftype = 'PARNUM') or
          (ftype = 'NUMPAGES') or
          (ftype = 'DATE') or
          (ftype = 'TIME')
          then
        begin
          CreateImplizitPar;
          txtobj := PrintTextObj(wpobjTextObject, ftype,
            FStack.FFieldINST.GetRest,
            false, false, false);
          txtobj.Params :=
            FCurrentString.GetString;

          FCurrentString.Clear;
        end
      // Symbol - with Font
        else if ftype = 'SYMBOL' then
        begin
          CreateImplizitPar;
          PrintTextObj(wpobjTextObject, 'SYMBOL',
            FStack.FFieldINST.GetRest,
            false, false, false);
        end
        // always use Wingdings Font
        else if ftype = 'FORMCHECKBOX' then
        begin
          CreateImplizitPar;
          PrintTextObj(wpobjTextObject, 'FORMCHECKBOX',
            #224,
            false, false, false);
        end

        else // ++++++++++ OPEN/CLOSE FIELDS +++++++++++++++++++++++++++++++++++++
        begin
          if ftype = 'HYPERLINK' then
          begin
            if FStack.FFieldINST.Tag > 0 then
            begin
              // \x codes are put to the CParam property:
              fname := FStack.FFieldINST.GetSecondParam;
              if (Length(fname) = 2) and (fname[1] = '\') then
              begin
                i := 1000 + Integer(fname[2]);
                fname := FStack.FFieldINST.GetSecondParam;
              end
              else i := 0;
              txtobj := PrintTextObj(wpobjHyperlink, '', // Title ?
                fname,
                true, true, false);
              txtobj.CParam := i;
              txtobj.SetTag(FStack.FFieldINST.Tag);
            end;
          end
          else if ftype = 'TOC' then // Table of Contents
          begin
            fname := FStack.LastStringBuilder.GetRest;
            i := Pos('\h', fname);
            if i > 0 then Delete(fname, i, 2);
            fname := Trim(fname);

            if FStack.LastStringBuilder.Tag <> 0 then
            begin
              txtobj := PrintTextObj(wpobjMergeField, WPTOC_FIELDNAME,
                fname,
                true, true, false);
              txtobj.SetTag(FStack.LastStringBuilder.Tag);
            end;
          end
          else
            if ftype = 'PAGEREF' then
            begin
          // Word has here start/end tags, we use a single object for life update
              fname := FStack.LastStringBuilder.GetRest;
              i := Pos('\', fname);
              if i > 0 then fname := Trim(Copy(fname, 1, i - 1));
              fname := AnsiDequotedStr(fname, '"');
              txtobj := PrintTextObj(wpobjReference, fname,
                FCurrentString.GetString,
                false, false, false);
              FCurrentString.Clear;
            end
            else if (ftype = 'MERGEFIELD')
              or (ftype = 'FORMTEXT')
              then
            begin
              if FIgnoreNextField then
                FIgnoreNextField := FALSE
              else
              begin
{$IFDEF READ_FIELDS_WITH_SPACE}
                fname := Trim(AnsiDequotedStr(FStack.LastStringBuilder.GetRest));

                fcommand := '';
{$ELSE}
                fname := Trim(FStack.LastStringBuilder.GetNext);
                fcommand := FStack.LastStringBuilder.GetRest;
{$ENDIF}

                if FStack.LastStringBuilder.Tag = 0 then
                begin
                  txtobj := PrintTextObj(wpobjMergeField, fname,
                    fcommand, // Command
                    true, false, false);
                  FStack.LastStringBuilder.Tag := txtobj.NewTag;
                end;

                // CODE to avoid duplicated closing chars when importing V4 insertpoints
{$IFDEF FIXUP_V4_FIELDS}
                if (FLastOldInsertPoint <> nil) and (FCurrentParagraph <> nil)
                  and (FCurrentParagraph.CharCount > 0) then
                begin
                  if ((FLastOldInsertPoint.Params = #171) and // WPEditFieldStart, WPEditFieldEnd!
                    (FCurrentParagraph.CharItem[FCurrentParagraph.CharCount - 1]
                    = #187))
                    or ((FLastOldInsertPoint.Params = '<') and
                    (FCurrentParagraph.CharItem[FCurrentParagraph.CharCount - 1]
                    = '>'))
                    or ((FLastOldInsertPoint.Params = '[') and
                    (FCurrentParagraph.CharItem[FCurrentParagraph.CharCount - 1]
                    = ']'))
                    then FCurrentParagraph.DeleteChar(FCurrentParagraph.CharCount - 1);
                end;
{$ENDIF}
              (* THIS SHOWS ALL MERGE FIELDS !!!!
                if Attr.HasStyle(afsHidden, Yes) and Yes then
                begin
                  // Attr.ExcludeStyle(afsHidden); //V5.18.10
                  txtobj := PrintTextObj(wpobjMergeField, fname,
                    fcommand, // Command
                    true, true, false);
                  Attr.IncludeStyle(afsHidden); //V5.18.10
                end else  *)

                if FCurrentParagraph.ParagraphType = wpIsTable then
                begin
                  NewParagraph();
                  FLastWasSTDPar := false;
                end;

                txtobj := PrintTextObj(wpobjMergeField, fname,
                  fcommand, // Command
                  true, true, false);

                if FStack.LastStringBuilder.FFieldType = wpNewFormField then
                  txtobj.Mode := txtobj.Mode + [wpobjWithinEditable];

                txtobj.SetTag(FStack.LastStringBuilder.Tag);
              end;
            end
            else if ftype = 'WPTOOLSOBJ' then
            begin
              CreateImplizitPar;
              if FWPTextObjCloseTag <> 0 then
              begin
                for i := FTextObjList.Count - 1 downto 0 do
                  if FTextObjList.Tags[i] = FWPTextObjCloseTag then
                  begin
                    txtobj := PrintTextObj(wpobjCustom, '', '',
                      true, true, false);
                     // When we close - we open the first (wpobjIsOpening)!
                    FTextObjList[i].Mode :=
                      FTextObjList[i].Mode + [wpobjUsedPairwise, wpobjIsOpening];
                    txtobj.SetTag(FTextObjList[i].NewTag);
                    txtobj._SetObjType(FTextObjList[i].ObjType);
                    txtobj.Name := FTextObjList[i].Name;
                    FTextObjList.Delete(i);
                    break;
                  end;
              end else
              begin
                txtobj := PrintTextObj(wpobjCustom, '', '',
                  false, false, false);
                txtobj.ASetWPSS(FStack.LastStringBuilder.GetRest);
                if FWPTextObjOpenTag <> 0 then
                begin
                  FTextObjList.Add(txtobj);
                  FTextObjList.Tags[FTextObjList.Count - 1] := FWPTextObjOpenTag;
                end;
              end;
              FWPTextObjOpenTag := 0;
              FWPTextObjCloseTag := 0;
            end
            else if ftype = 'INCLUDEPICTURE' then
            begin
              if FIgnoreNextPict then //V5.17.3 - when loading wptools mixed text
              begin
                FIgnoreNextPict := FALSE;
                exit;
              end;
              fname := Trim(FStack.LastStringBuilder.GetNext);
              CreateImplizitPar;
              txtobj := PrintTextObj(wpobjImage, fname,
                '', // Command
                false, false, false);
              if txtobj <> nil then
                LoadLinkedImage(txtobj, fname, FStack.LastStringBuilder.GetRest);
            end
              ; // else ShowMessage(FStack.FFieldINST.GetString);
          if (FFieldIParam <> 0) and (txtobj <> nil) then
            txtobj.IParam := FFieldIParam;
          ApplyFrameModeParams(FFieldFrameParam, FFieldModeParam, txtobj);
          FFieldFrameParam := 0;
          FFieldModeParam := 0;
          FFieldIParam := 0;
        end; // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      end;
  end;
end;

class function TWPRTFReader.UseForFilterName(const Filtername: string): Boolean;
begin
  Result := inherited UseForFilterName(Filtername)
    or (CompareText(Filtername, 'RTF') = 0)
    or (CompareText(Filtername, 'DOC') = 0);
end;

class function TWPRTFReader.UseForContents(const First500Char: AnsiString): Boolean;
begin
  Result := Copy(First500Char, 1, 5) = '{\rtf';
end;

procedure TWPRTFReader.SetOptions(optstr: string);
var i: Integer;
  aoptstr: string;
begin
  FWrittenByWPToolsVersion := DEFAULTWPTOOLSVERSION; // DEFAULT WPTOOLS VERSION
  i := Pos('-', optstr);
  if i > 0 then
  begin
    aoptstr := lowercase(Copy(optstr, i, Length(optstr) - i + 1)) + ',';
    FOptIgnoreRowMerge := Pos('-ignorerowmerge,', aoptstr) > 0;
    OptDontFixAttr := (Pos('-dontfixattr,', aoptstr) > 0);
    OptIgnoreRowHeight := Pos('-ignorerowheight,', aoptstr) > 0;
    OptOnlyAddUsedStyles := Pos('-onlyusedstyles,', aoptstr) > 0;
    OptDontOverwriteStyles := (Pos('-dontoverwritestyles,', aoptstr) > 0);
    OptIgnoreTableWidth := (Pos('-ignoretablewidth,', aoptstr) > 0);
    OptIngoreSections := (Pos('-ignoresections,', aoptstr) > 0);
    OptIgnoreTableSETags := (Pos('-ignoretablesetags,', aoptstr) > 0);
    OptNoCharStyles := (Pos('-nocharstyles,', aoptstr) > 0);
    OptIgnoreFontStyle := (Pos('-ignorefontstyles,', aoptstr) > 0);
    // do NOT activate symbol NEWTRHANDL!

    if Pos('-wptools3,', aoptstr) > 0 then
      FWrittenByWPToolsVersion := 3.0
    else if Pos('-wptools4,', aoptstr) > 0 then
      FWrittenByWPToolsVersion := 4.0
    else if Pos('-wptools5,', aoptstr) > 0 then
      FWrittenByWPToolsVersion := 5.0;
  end;
  inherited SetOptions(optstr);
{$IFDEF ALWAYS_IgnoreTableWidth}
  OptIgnoreTableWidth := TRUE;
{$ENDIF}
{$IFDEF IGNORE_TBLTAGS}
  OptIgnoreTableSETags := TRUE;
{$ENDIF}
end;

procedure TWPRTFReader.SetTableDepth(x: Integer);
begin
  FTableDepth := x;
end;

function TWPRTFReader.GetTableDepth: Integer;
begin
  if FTableStart >= 0 then Result := FTableStart else Result := FTableDepth;
end;

function TWPRTFReader.GetTableVar(index: Integer): TWPRTFTableStack;
begin
  if FTableVar = nil then FTableVar := TList.Create;
  while FTableVar.Count < index + 1 do
    FTableVar.Add(TWPRTFTableStack.Create(FRTFProps));
  Result := TWPRTFTableStack(FTableVar[index]);
end;

function TWPRTFReader.CurrentParagraph: TParagraph;
begin
  if FCurrentParagraph = nil then
  begin
    CreateImplizitPar;
    Result := FCurrentParagraph;
  end else Result := FCurrentParagraph;
end;

function WPRTFTagListItemCompare(List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := CompareStr(List[Index1], List[Index2]);
end;

function TWPRTFReader.Parse(datastream: TStream): TWPRTFDataBlock;
var
  ch, keywordlen, keywordmax, keyvalue, n: Integer;
  ret: TWPToolsIOErrCode;
  escape, haskeyvalue, FHasControlChar: Boolean;
  keyword: string;
  tempstack: TWPRTFReaderStack;
  parsty: TWPTextStyle;
  remove_default_font: Boolean;
  fs: Single;
  par: TParagraph;
{$IFDEF FIX_ANY_STYLE}
  defstylesheet, defstylesheet_fixed, last_parstyle: TWPTextStyle;
{$ENDIF}
{$IFDEF READTAGOPT_HASH}
  _hashlen: Integer;
  function GetHash(const str: string; strlen: Integer): Integer;
  begin
    Result := WPGetHashCode(str[1], strlen) mod _hashlen;
  end;
{$ENDIF}
 // Reads the keyword after a \ sign. Ignores spaces at first. Also reads the keyvalue. Result := FALSE if #0
  function GetKeyword(firstch: Integer): Boolean;
  begin
    FHasControlChar := FALSE;
    keywordlen := 0;
    keyvalue := 0;
    haskeyvalue := FALSE;
    Result := TRUE;
    if firstch = 0 then ch := ReadChar else ch := firstch;
    while keywordlen < keywordmax - 1 do
    begin
     { if (keywordlen = 0) and ((ch > 0) and (ch <= 32)) then
      begin
                    // Ignore space between \ and keyword --- NOT, this is a mistake in RTF
      end
      else }if (ch >= Integer('a')) and (ch <= Integer('z')) then
      begin
        inc(keywordlen);
        keyword[keywordlen] := Char(ch);
      end
      else if (ch >= Integer('A')) and (ch <= Integer('Z')) then // lowercase!
      begin
        if keywordlen < keywordmax then
        begin
          inc(keywordlen);
          keyword[keywordlen] := Char(ch + 32);
        end;
      end
      else if (ch >= Integer('0')) and (ch <= Integer('9')) or (ch = Integer('-')) then
      begin
        UnReadChar;
        haskeyvalue := TRUE;
        keyvalue := ReadInteger;
        ch := ReadChar;
        if ch > 32 then UnreadChar;
        break;
      end else
      begin
        if ch <= 0 then Result := FALSE
        else if ch > 32 then
          UnreadChar;
        break;
      end;
      ch := ReadChar;
    end;
  end;
 // Finds a keyword ------------------------------------------------------------
  function FindKeyword: TWPRTFTagParams;
  var ind: Integer;
  {$IFDEF READTAGOPT}
    ss: string;
  l, h: Integer;
  {$ENDIF}
  begin
    Result := nil;
    if keywordlen > 0 then
    begin
{$IFDEF READTAGOPT}

{$IFDEF READTAGOPT_HASH}
      h := GetHash(keyword, keywordlen);
      if not readtaghashmult[h] then
      begin
        Result := readtaghash[h];
        if Result = nil then exit;
        ss := Copy(keyword, 1, keywordlen);
        if Result.Name = ss then exit
        else Result := nil;
      end else ss := Copy(keyword, 1, keywordlen);
{$ELSE}
      ss := Copy(keyword, 1, keywordlen);
      h := keywordlen;
{$ENDIF READTAGOPT_HASH}
      ind := readtagsindex[AnsiChar(keyword[1])];
      l := readtagsblen[AnsiChar(keyword[1])];
      while l > 0 do
      begin
        if (readtaglen[ind] = h) and (readtags[ind].Name = ss) then
        begin
          Result := readtags[ind];
          break;
        end;
        inc(ind);
        dec(l);
      end;

{$ELSE}
      ind := WPRTFTagList.IndexOf(Copy(keyword, 1, keywordlen));
      if ind >= 0 then Result := TWPRTFTagParams(WPRTFTagList.Objects[ind]);
{$ENDIF}
    end;
  end;
  // Append one character ------------------------------------------------------
  procedure AppendChar(aCh: Integer; IsUnicode: Boolean = false);
  var by: Byte;
    fname, fcommand: string;
  begin
    if FWaitForInsertPoint and not (FStack.Destination in [rdsFieldParams]) then
    begin
      // OLD STYLE INSERTPOINT !
      if (FStack.LastStringBuilder <> nil) and (FStack.LastStringBuilder.Tag = 0) then
      begin

      //{$IFDEF READ_FIELDS_WITH_SPACE}
      // fname := Trim(AnsiDequotedStr(FStack.LastStringBuilder.GetRest,'"'));
        fname := Trim(FStack.LastStringBuilder.GetRest);
        fcommand := '';
     (* {$ELSE}
      fname := FStack.LastStringBuilder.GetNext;
      fcommand := '';
      {$ENDIF} *)

{$IFDEF IMPORTV4EDITFIELDS}
        if (FLastOldInsertPoint <> nil) and
          (CompareText(FLastOldInsertPoint.Name,
          AnsiDequotedStr(fname, '"') //V5.18.4
          ) = 0) then
        begin
          FLastOldInsertPoint.Mode := FLastOldInsertPoint.Mode
            + [wpobjWithinEditable];
          FLastOldInsertPoint := nil;
          FIgnoreNextField := TRUE;
        end else
{$ENDIF}
        begin
          FIgnoreNextField := FALSE;
          CreateImplizitPar;
          FNewTxtObj := PrintTextObj(wpobjMergeField, fname,
            fcommand, // Command
            true, false, false);
          FStack.LastStringBuilder.Tag := FNewTxtObj.NewTag;
          FNewTxtObj.Params := Char(aCH);
          FLastOldInsertPoint := FNewTxtObj;
        end;
        aCH := 0;
      end;
      FWaitForInsertPoint := FALSE;
    end;
    if FStack.Destination = rdsPicture then
    begin
      if (FPicture.pReading) and not (FPicture.HasBinData) then
      begin
        if Ch > 32 then
        begin
          by := Byte(Ch);
          FPicture.pData.Write(by, 1);
        end;
      end;
    end
    else
      if FStack.Destination = rdsNorm then
      begin
        CreateImplizitPar;
{$IFDEF FIXUP_CHARSTYLES}
        if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
        if not IsUnicode and //V5.24.2
          (FCurrentCodePage <> 0) and (FCurrentCodePage <> 1252) and (aCh < 256) then
          PrintAByte(Integer(aCh), FCurrentCodePage)
        else PrintWideChar(aCh);
        FLastOldInsertPoint := nil;
      end
      else
        if FStack.Destination = rdsAnyString then
        begin
          FCurrentString.AppendChar(AnsiChar(aCh));
        end else
          if FStack.Destination = rdsLevelText then
          begin
            if aCh < 255 then FCurrentNumberString := FCurrentNumberString + Char(aCh)
            else FCurrentNumberString := FCurrentNumberString + WideChar(aCh);
          end
          else if FStack.Destination in [rdsStyleSheet, rdsListName, rdsPNTextA, rdsPNTextB,
            rdsBookmark, rdsMergeVar, rdsMergePar, rdsFootnote, rdsAnySVString, rdsInfoItemName,
            rdsInfoItem, rdsFieldParams, rdsParName, rdsCellName, rdsCellCommand] then
          begin
            FCurrentString.AppendChar(AnsiChar(aCh));
          end else
            if FStack.Destination in [rdsffname, rdsffdeftext, rdsffformat, rdsPicName, rdsPicSource] then
            begin
              FCurrentExString.AppendChar(AnsiChar(aCh)); end
            else
              if FStack.Destination = rdsFieldStringBuilder then
              begin
                if FStringBuilder <> nil then
                  FStringBuilder.AppendChar(AnsiChar(aCh));
              end else
                if FStack.Destination = rdsColorTable then
                begin
                  if (ch = Integer(';')) and (FColIndex < MaxColors) then
                  begin
                    inc(FColIndex);
                    last_red := 0;
                    last_green := 0;
                    ColorMapTable[FColIndex] := 0;
                  end;
                end
                else if FStack.Destination = rdsFontTbl then
                  ReadFontTblChar(Char(aCh))
                else
                  if FStack.Destination = rdsWPBinDataHex then
                  begin
                    by := aCh;
                    FWPBinData.Write(by, 1);

                  end else
                    if FStack.Destination in [rdsSkip, rdsSkipText, rdsShpinst, rdsShprslt, rdsShpText, rdsShpSP, rdsShpSN, rdsShpSV] then
                    begin
{$IFDEF WPPREMIUM}
                      if not (FStack.Destination in [rdsSkip, rdsSkipText]) then
                        SkippedText(aCh);
{$ENDIF}
                    end
                    else
                      if aCh > 0 then
                      begin
    //#: RTF Reader: AppendChar DEBUG
  {  if Char(aCh)='E' then
    begin
       aCh := Integer('R');
    end;  }
                        CreateImplizitPar;
{$IFDEF FIXUP_CHARSTYLES}
                        if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
                        if not IsUnicode and //V5.24.2
                          (FCurrentCodePage <> 0) and (FCurrentCodePage <> 1252) and (aCh < 256) then
                        begin
                          PrintAByte(Byte(aCh), FCurrentCodePage);
                        end
                        else PrintWideChar(aCh);
                      end;
  end;
  // ---------------------------------------------------------------------------
var currTag: TWPRTFTagParams;
  i: Integer;
  str: AnsiString;
  IsControlChar: Boolean;
{$IFNDEF NOSPEED518}by: Byte; {$ENDIF}
{$IFDEF READTAGOPT}
  cchar, lchar: AnsiChar;
  li: Integer;
{$IFDEF READTAGOPT_HASH}j: Integer; {$ENDIF}
{$ENDIF}
label readunicode;
begin
{$IFDEF READTAGOPT}

  SetLength(readtags, WPRTFTagList.Count);
  SetLength(readtaglen, WPRTFTagList.Count);
  FDelayedTxtObj := nil;
{$IFDEF READTAGOPT_HASH}
  _hashlen := WPRTFTagList.Count * 4;
  SetLength(readtaghash, _hashlen);
  SetLength(readtaghashmult, _hashlen);
{$ENDIF}

  // Read from current attributes ----------------------------------------------
  if not Attr.GetFont(FDefaultFontNr) and
    not RTFDataCollection.ANSITextAttr.GetFont(FDefaultFontNr) then
    FDefaultFontNr := 0; //V5.18
  if not Attr.GetFontSize(FDefaultFontSize) and
    not RTFDataCollection.ANSITextAttr.GetFontSize(FDefaultFontSize) then
    FDefaultFontSize := DefaultFontSize;
  FDefaultFontNrMap := -1; //V5.20.6
  // ---------------------------------------------------------------------------

  lchar := #0;
  li := 0;
  FTableStart := -1;
  FUNICharCount := 1;
  FNeedStackAssign := FALSE;

  if OptCodePage > 0 then
    FCurrentCodePage := OptCodePage
  else FCurrentCodePage := WPGetCodePage(0); // Default!
  FIsNewSection := FALSE;
  FRestartPageNr := FALSE;
  FInSpecialText := FALSE;
  FWrittenByGenerator := '';
  FDefaultFontNrDEFF := 0;
  lastSpaceSLMULT := -1; //undefined
  FNewSectionID := 0;
  FPrevSectionId := 0;
{$IFNDEF READTAGOPT}
  WPRTFTagList.Sorted := TRUE;
{$ELSE}
  WPRTFTagList.CustomSort(WPRTFTagListItemCompare);
{$ENDIF}

  for i := 0 to WPRTFTagList.Count - 1 do
  begin
    readtags[i] := TWPRTFTagParams(WPRTFTagList.Objects[i]);
    str := readtags[i].Name;
    cchar := str[1];
{$IFDEF READTAGOPT_HASH}
    j := GetHash(str, Length(str));
    if readtaghash[j] <> nil then
      readtaghashmult[j] := TRUE
    else readtaghash[j] := readtags[i];
    readtaglen[i] := j;
{$ELSE}
    readtaglen[i] := Length(str);
{$ENDIF READTAGOPT_HASH}
    if cchar <> lchar then
    begin
      if lchar <> #0 then
        readtagsblen[AnsiChar(lchar)] := li;
      li := 1;
      lchar := cchar;
      readtagsindex[AnsiChar(lchar)] := i;
    end else inc(li);
  end;
  if lchar <> #0 then
    readtagsblen[AnsiChar(lchar)] := li;

  try
{$ENDIF READTAGOPT}
    currTag := nil;
    FThisTabKind := tkLeft;
    FThisTabFill := tkNoFill;
    FHasDoubleUnderlines := FALSE;
    FHasParStyle := FALSE;
    FStack := TWPRTFReaderStack.Create(FRTFProps);
    FPicture := TWPReadPictData.Create(FRTFProps);
    FTextObjList := TWPTextObjList.Create;
    FWPBinData := TMemoryStream.Create;
    FReadingStyle := nil;
    FIgnoreNextPict := FALSE;
    FCurrentString := TWPStringBuilderReadRTF.Create(500, OptCodePage);
    FCurrentExString := TWPStringBuilderReadRTF.Create(500, OptCodePage);
    FTableVar := TList.Create;
    FHasReportGroups := FALSE;
    FCurrentMergePar := '';
    FCurrentMergeVar := '';
    FCurrentElementName := '';
    FIsMergePar := 0;
    FNextIsProtected := FALSE;
    FLoadedLandscape := FALSE;
    // RTF Defaults:
    Layout.paperh := 15840;
    Layout.paperw := 12240;
    Layout.landscape := FALSE;
    Layout.margl := 1800;
    Layout.margr := 1800;
    Layout.margt := 1440;
    Layout.margb := 1440;
    Layout.deftabstop := 720;

    if not OptNoPageInfo and not FLoadBodyOnly and not (loIgnorePageSize in FLoadOptions) then
      FCurrentSectionProps._Layout := Layout;

    // Read Number List
    FListsDefs := TList.Create; // [TWPRTFReadList]
    FListOverrides := nil; // array of TWPRTFReadListOverride; // \ls is Index+1 !
    FListOverrideCount := 0; // Integer;

    FHasNewListTable := FALSE;
    FOldListTableLevel := 0;
    FOldListTableGroup := 0;
    for i := 1 to 9 do
    begin
      FOldListTableUseAs[i] := 0;
      FreeAndNil(FOldListTable[i]);
    end;
    // Read Style Sheets
    FStyleSheet := TWPRTFReadStyleSheet.Create(FRTFProps, wpIsParStyle);
    FStyleSheet.FLoadOptions := FLoadOptions;
    if OptDontOverwriteStyles then
      include(FStyleSheet.FLoadOptions, loDontOverwriteExistingStyles);

    // Keep the attributes at current position - only with -ignorefonts mode!
    if OptIgnoreFonts then //V5.20.8
    begin
      DefAttrCharAttr := Attr.CharAttr; //V5.20.8
{$IFDEF IGNOREFONTANTSIZE}
      OptIgnoreFontStyle := TRUE; // can be activated, too
{$ENDIF}
    end
    else DefAttrCharAttr := 0;
    Attr.CharAttr := DefAttrCharAttr; //was: Attr.Clear
    Attr.GetCA(FStack.CharAttr); //V5.20.8

    try
      Result := inherited Parse(datastream);
      ret := wpNoError;
      keyword := 'WPTools_Version_5_by_WPCubed_GmbH_Munich-www.wptools.de_______';
      keywordlen := 0;
      keywordmax := Length(keyword);
      haskeyvalue := FALSE;

      TableDepth := 0;
      TableVar[TableDepth].FInsideTable := FALSE;
      TableVar[TableDepth].FInsideRow := FALSE;
      TableVar[TableDepth].FInsideCell := FALSE;
      escape := FALSE;
      FHasControlChar := FALSE;
      try
   // We select the body to ad the data
        SelectRTFData(wpIsBody, wpraIgnored, '');
   // and create the first paragraph
        // NewParagraph;
        repeat
          ch := ReadChar;
          IsControlChar := (ch = Integer('\')) or (ch = Integer('{')) or (ch = Integer('}'));
          if IsControlChar then FHasControlChar := TRUE;
          if FClipboardOperation and (ch = 0) then break //V5.18.1 - #0 is the end marker in clipboard ops
          else if ch < 0 then break //EOF
{$IFNDEF NOSPEED518} // Optimation of version V5.18.1
          else if not FHasControlChar and (FStack.Destination = rdsPicture)
            and (FPicture.pReading) and not (FPicture.HasBinData) then
          begin
            if Ch > 32 then
            begin
              by := Byte(Ch);
              FPicture.pData.Write(by, 1);
            end;
            continue; // QuickSKIP  - V5.18.1
          end
          else if not FHasControlChar and (FStack.Destination = rdsSkip) then
          begin
            continue; // QuickSKIP  - V5.18.1
          end
{$ENDIF}
          else if escape then // After \
          begin
            escape := FALSE;
            if IsControlChar (* (ch = Integer('\')) or
              (ch = Integer('{')) or
              (ch = Integer('}')) *)then AppendChar(ch)
            else if ch = Integer('~') then AppendChar(160)
            else if ch = Integer('_') then AppendChar(Integer('-'))
            else if ch = Integer('-') then FLastWasHyphen := TRUE
            else if ch = Integer('*') then
            begin
              repeat
                ch := ReadChar;
              until (ch < 0) or (ch > 32);
              if ch = Integer('\') then
              begin
                if not GetKeyword(0) then break; // EOF !
              // Find Keyword, if it is not there skip everything on this level!
                currTag := FindKeyword;

                // Fix /*/u
                if (currTag <> nil) and (currTag.Name = 'u') then
                  goto readunicode;

                if (currTag <> nil) and currTag.UseDefaultValue then //V5.24.1
                  keyvalue := currTag.DefaultValue; //V5.24.1

                if (currTag <> nil) and (currTag.TagAction = kwdDest) then
                begin
                  ChangeDestination(currTag.ActionID, keyvalue);
                end else
               (* This would load any \*\xxx tag !
                if FStack.Destination=rdsInfoGroup then
                begin
                   FStack.Destination:=rdsInfoItem;
                   FInfoItemName := Copy(keyword, 1, keywordlen);
                end else  *)
                begin
                  if (currTag <> nil) and
                    (currTag.ActionID = ipropCS) and // Handle \*\csN
                    (FStack.Destination = rdsStyleSheet) then
                    ChangeProp(ipropCS, keyvalue)
                  else ChangeDestination(idestSkip, keyvalue);
                end;
              end else ChangeDestination(idestSkip, keyvalue);
            end else if ch = 39 then
            begin
              if ReadHex(ch) then
              begin
{$IFDEF MALBOR}
                if ((ch = $93) or (ch = $94)) and
                  ((FCurrentCodePage = 0) and (FCurrentCodePage = 1252)) then ch := 34; // Convert to '"'
{$ENDIF}
                AppendChar(ch);
              end
              else AppendChar(39);
            end
            else // Get Keyword
            begin
              if not GetKeyword(ch) then break; // EOF !
              // \u --> Unicode is hard encoded ! (see ipropReadUnicodeChar)
              if (keywordlen = 1) and (keyword[1] = 'u') then
              begin
               { if keyvalue < 0 then
                  AppendChar($FFFF + keyvalue +1)
                else AppendChar(keyvalue); }

                readunicode:
                AppendChar({Integer}Word(keyvalue), true);

                // Skip FUNICharCount chars
                // some writers are buggy and don't write those charse so
                // break if special char is found
                for i := 1 to FUNICharCount do
                begin
                  repeat
                    ch := ReadChar;
                  until (ch <= 0) or (ch >= 32); //V5.17.3 - \r\n after \u

                  if ch = Integer('\') then
                  begin
                    ch := ReadChar;
                    if ch = 39 then // Overread HexCode
                    begin
                      ReadChar;
                      ReadChar;
                    end else // This is a RTF command, such as \u  (buggy RTF writer)
                    begin
                      UnreadChar; // ch
                      UnreadChar; // \
                      break;
                    end;
                  end else
                    if (ch = Integer('{')) or
                      (ch = Integer('}')) then
                    begin
                      UnreadChar; break;
                    end;
                end;
              end else
              begin
                currTag := FindKeyword;
                if currTag <> nil then
                begin
                  if currTag.TagAction = kwdProp then
                  begin
                    if currTag.UseDefaultValue or not haskeyvalue then
                      ChangeProp(currTag.ActionID, currTag.DefaultValue)
                    else
                      ChangeProp(currTag.ActionID, keyvalue);
                  end else if currTag.TagAction = kwdDest then
                  begin
                    if currTag.UseDefaultValue or not haskeyvalue then
                      ChangeDestination(currTag.ActionID, currTag.DefaultValue)
                    else ChangeDestination(currTag.ActionID, keyvalue);
                  end else if currTag.TagAction = kwdChar then
                  begin
                    AppendChar(currTag.ActionID);
                  end;
                end;
              end;
            end;
          end
          else if ch = Integer('\') then escape := TRUE
          else if ch = Integer('{') then
          begin
            FHasControlChar := FALSE;
            PushStack;
          end
          else if ch = Integer('}') then
          begin
            FHasControlChar := FALSE;
            if not PopStack then
            begin
{$IFNDEF DONT_SKIP_RTF_TEXT_AFTER_CLOSING}
              break; //Info: debugger always stops here!
{$ENDIF}
            end;
          end else if ch >= 32 then
          begin
            AppendChar(ch);
          end;

        until ret <> wpNoError;
        ResetReadBuffer;
      except
        str := 'RTF Read error at position ' + IntToStr(ReadPosition);
        OutputDebugString(PChar(str));
        FReadingError := TRUE;
        raise;
      end;

      //V5.20.7 - delete double empty par at end
      {if (FCurrentParagraph<>nil) and (FCurrentParagraph.NextPar<>nil) and
         (FCurrentParagraph.NextPar.CharCount = 0) and
         (FCurrentParagraph.NextPar.ParagraphType = wpIsSTDPar) then
            FCurrentParagraph.NextPar.DeleteParagraph;}

      // Delete the empty line which is caused by the last \par in the RTF code
      if (currTag <> nil) and (currTag.ActionID = ipropNewPar) and
        (FCurrentParagraph <> nil) and
        (FCurrentParagraph.CharCount = 0) and
        (FCurrentParagraph.PrevPar <> nil) and
        (FCurrentParagraph.ParagraphType = wpIsSTDPar) then
      begin
        if FFirstLoadedFirstPar = FCurrentParagraph then
        begin
          FCurrentParagraph := FCurrentParagraph.DeleteParagraph;
          FFirstLoadedFirstPar := FCurrentParagraph;
        end
        else FCurrentParagraph := FCurrentParagraph.DeleteParagraph;
      end;

     // FIX "BASED ON" and "NEXT" references in style sheet --------------------
      if FStyleSheet <> nil then
      begin
        for i := 0 to FStyleSheet.FStyleCount-1 do
          if FStyleSheet.FStyles[i].FStyleElement <> nil then
          begin
            if FStyleSheet.FStyles[i].FNext > 0 then
            begin
              str := FStyleSheet.getName(FStyleSheet.FStyles[i].FNext);
              if str <> '' then
                FStyleSheet.FStyles[i].FStyleElement.NextStyleName := str;
            end;
            if FStyleSheet.FStyles[i].FBasedOn > 0 then
            begin
              str := FStyleSheet.getName(FStyleSheet.FStyles[i].FBasedOn);
              if (str <> '') and (CompareText(str, FStyleSheet.FStyles[i].FStyleName) <> 0) then
                FStyleSheet.FStyles[i].FStyleElement.TextStyle.ABaseStyleName := str;
            end;
            if FStyleSheet.FStyles[i].FIsDefault then
            begin
              FStyleSheet.FStyles[i].FStyleElement.IsDefault := TRUE;
            end;
          end;
      end;

{$IFDEF FIX_ANY_STYLE}
      if {$IFDEF DONT_FIX_DEFSTYLE}FHasParStyle and {$ENDIF}
      not OptDontFixAttr and not (loDontDeleteAttrEqualToParStyle in LoadOptions) then
      begin
        defstylesheet := TWPTextStyle.Create(RTFProps);
        defstylesheet_fixed := TWPTextStyle.Create(RTFProps);
        last_parstyle := nil;
{$IFNDEF DONT_FIX_DEFSTYLE} // set the default attribute
        if not FClipboardOperation and not FLoadBodyOnly then
        begin
          RTFDataCollection.ANSITextAttr.SetFont(FDefaultFontNr);
          RTFDataCollection.ANSITextAttr.SetFontSize(FDefaultFontSize);
        end;
{$ENDIF}
        remove_default_font := FALSE;
        if RTFDataCollection.ANSITextAttr.GetFont(i) and (i = FDefaultFontNr) then
        begin
          defstylesheet.ASet(WPAT_CharFont, FDefaultFontNr);
          remove_default_font := TRUE;
        end;
        if RTFDataCollection.ANSITextAttr.GetFontSize(fs) and (fs = FDefaultFontSize) then
        begin
          defstylesheet.ASet(WPAT_CharFontSize, Round(FDefaultFontSize * 100));
          remove_default_font := TRUE;
        end;

        par := FFirstLoadedFirstPar;
        while par <> nil do
        begin
          if par.style <> 0 then // we have a style, remove the charattr it defines
          begin
{$IFNDEF DONT_FIX_STYLES}
            if (loDontOverwriteExistingStyles in FLoadOptions) or OptDontOverwriteStyles then
            begin
              parsty := nil;
              for n := 0 to Length(FStyleSheet.FStyles) - 1 do
                if FStyleSheet.FStyles[N].FUsedAs = par.style then
                begin
                  parsty := FStyleSheet.FStyles[N].FStyle;
                  break;
                end;
            end else parsty := par.ABaseStyle;
            if parsty <> nil then
            begin
              if par.ParagraphType = wpIsTable then
                par.ASetBaseStyle(0)
              else
              begin
               // remove all redundant attributes
                par.ADeleteEqualSettings(parsty);
              end;
            //V5.18.3 also paragraphs with stylesheet can use a default font!
{$IFNDEF DONT_FIX_DEFSTYLE}
              if remove_default_font then
              begin
                 // V5.19.1 - remove the attributes from defstyle which ARE necessary
                if parsty <> last_parstyle then
                begin
                  defstylesheet.Assign(defstylesheet);
                  if parsty.AGet(WPAT_CharFont, n) then defstylesheet.ADel(WPAT_CharFont);
                  if parsty.AGet(WPAT_CharFontSize, n) then defstylesheet.ADel(WPAT_CharFontSize);
                  if parsty.AGet(WPAT_CharCharset, n) then
                    defstylesheet.ADel(WPAT_CharCharset);
                  if parsty.AGet(WPAT_CharColor, n) then defstylesheet.ADel(WPAT_CharColor);
                  if parsty.AGet(WPAT_CharBGColor, n) then defstylesheet.ADel(WPAT_CharBGColor);
                  last_parstyle := parsty;
                end;
                par.ADeleteEqualSettings(defstylesheet);
              end;
{$ENDIF}
            end;
{$ENDIF}
          end else // we have a style, remove the default fontsize and fontname
          begin
{$IFNDEF DONT_FIX_DEFSTYLE}
            if remove_default_font then
              par.ADeleteEqualSettings(defstylesheet);
{$ENDIF}
          end;

          par.Optimize;
          par := par.next;
        end;
        FreeAndNil(defstylesheet);
        FreeAndNil(defstylesheet_fixed);
      end else // OPTIMIZE ALL! - V5.22.2
{$ENDIF}
      begin
        par := FFirstLoadedFirstPar;
        while par <> nil do
        begin
          par.Optimize;
          par := par.next;
        end;
      end;

{$IFNDEF DONT_APPEND_PAR_AFTER_TABLES}
      if not FHasReportGroups and not FClipboardOperation and (FFirstLoadedFirstPar <> nil) then
      begin
        par := FFirstLoadedFirstPar.LastSibling;
        if (par.ParagraphType = wpIsTable) then
          par.NextPar := TParagraph.Create(par.RTFData);
      end;
{$ENDIF}

      if FHasReportGroups and (FFirstLoadedFirstPar <> nil) then
      begin
        FFirstLoadedFirstPar := FFirstLoadedFirstPar.FirstSibling;
        CreateGroupTree;
      end;
    finally
      FCurrentSectionProps.RecalcLayout;

      // Free the stack without executing any close code
      while FStack.FPrevious <> nil do
      begin
        tempstack := FStack;
        FStack := FStack.FPrevious;
        tempstack.Free;
      end;

      FreeAndNil(FStack);
      //NO: FreeAndNil(FReadingStyle);
      FreeAndNil(FCurrentString);
      FreeAndNil(FCurrentExString);
      FreeAndNil(FPicture);
      FreeAndNil(FTextObjList);
      FreeAndNil(FWPBinData);
      for i := 0 to FTableVar.Count - 1 do
        TObject(FTableVar[i]).Free;
      FreeAndNil(FTableVar);

      for i := 0 to FListsDefs.Count - 1 do
        TObject(FListsDefs[i]).Free;
      for i := 1 to 9 do FreeAndNil(FOldListTable[i]);
      if FDelayedTxtObj <> nil then
      begin
        for i := 0 to FDelayedTxtObj.Count - 1 do
          TObject(FDelayedTxtObj[i]).Free;
        FreeAndNil(FDelayedTxtObj);
      end;
      FreeAndNil(FListsDefs);
      FListOverrides := nil;
      FreeAndNil(FStyleSheet);

    end;
{$IFDEF READTAGOPT}
  finally

    readtags := nil;
    readtaglen := nil;

  end;
{$ENDIF}
end;

procedure TWPRTFReader.CheckNewParagraph;
var tstack: TWPRTFTableStack;
begin
  tstack := TableVar[TableDepth];
  if FCurrentParagraph <> nil then FCurrentParagraph.Optimize;
  FStack.ADel(WPAT_NumberStart);
  if (tstack.FInsideCell) and (paprIsTable in FCurrentParagraph.prop) then
  begin
    NewChildParagraph;
    FCurrentParagraph.Assign(FStack, false);
    FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle);
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
  end else
    if FReadingStyle = nil then
    begin
      FLastParagraph := FCurrentParagraph;
      if (paprIsTable in FCurrentParagraph.prop) and (FCurrentParagraph.ParagraphType = wpIsSTDPar) then
        NewChildParagraph
      else
      begin
        NewParagraph;
      end;
      FCurrentParagraph.Assign(FStack, false);
      FCurrentParagraph.ADel(WPAT_ParFlags);
      FCurrentParagraph.ADel(WPAT_ParID);
      FCurrentParagraph.ASetBaseStyle(FStack.ParNrStyle); //V5.12.5
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
      //NO!!! FCurrentParagraph.TabstopAssign(FLastParagraph);
    end;
end;

procedure TWPRTFReader.ChangeProp(ipropCode, Value: Integer);
var
  par: TParagraph;
  aReadingBorder: Integer; // [blLeft ...
  i, aValue: Integer;
  SelBrd: TOneBorderType; // [blLeft ...
  tstack: TWPRTFTableStack;
  procedure ASet(aType: Byte; aValue: Integer);
  begin
    if (FCurrentParagraph <> nil) and
      (FCurrentParagraph.ParagraphType <> wpIsTable) and
      (FCurrentParagraph.ParagraphType <> wpIsTableRow) then
      FCurrentParagraph.ASet(aType, aValue);
    FStack.ASet(aType, aValue);
  end;
  procedure ADel(aType: Byte);
  begin
    if (FCurrentParagraph <> nil) and
      (FCurrentParagraph.ParagraphType <> wpIsTable) and
      (FCurrentParagraph.ParagraphType <> wpIsTableRow) then
      FCurrentParagraph.ADel(aType);
    FStack.ADel(aType);
  end;
  procedure ASetNeutral(aType: Byte; aValue: Integer);
  var sty: TWPTextStyle;
  begin
    if (FCurrentParagraph <> nil) and
      (FCurrentParagraph.ParagraphType <> wpIsTable) and
      (FCurrentParagraph.ParagraphType <> wpIsTableRow) then
    begin
      sty := FStack.ABaseStyle; //V5.17.3 . make sure we write differing attributes!
      if (sty <> nil) and (sty.AGetDef(aType, aValue) <> aValue) then
      begin
        FCurrentParagraph.ASet(aType, aValue);
        FStack.ASet(aType, aValue);
      end else
      begin
        FCurrentParagraph.ASetNeutral(aType, aValue);
        FStack.ASetNeutral(aType, aValue);
      end;
    end
    else if FStack.ParNrStyle <> 0 then //V5.18.1
      FStack.ASet(aType, aValue) //V5.18.1
    else FStack.ASetNeutral(aType, aValue);
  end;
  procedure StackASetNeutral(aType: Byte; aValue: Integer);
  var sty: TWPTextStyle;
  begin
    sty := FStack.ABaseStyle; //V5.17.3 . make sure we write differing attributes!
    if (sty <> nil) and (sty.AGetDef(aType, aValue) <> aValue) then
    begin
      FStack.ASet(aType, aValue);
    end else
    begin
      FStack.ASetNeutral(aType, aValue);
    end;
  end;
  function InTStack: Boolean;
  begin
    tstack := TableVar[TableDepth];
    Result := TRUE;
  end;
label MakeNewPage;
begin
  try
    tstack := nil;
    lastTagActionID := ipropCode;
    if (FStack.Destination <> rdsSkip) or (ipropCode = ipropReadBin) then
    begin
      if ipropCode < ipropGroupEnd1 then // GROUP 1
        case ipropCode of
          ipropReadBin:
            begin
              if FStack.Destination = rdsPicture then
              begin
              // If we use binary data for a picture we ONLY use binary data
                if not FPicture.HasBinData then
                begin
                  FPicture.HasBinData := TRUE;
                  FPicture.pData.Clear;
                end;
                ReadStream(FPicture.pData, value, false);
              end else
                while Value > 0 do begin ReadChar; dec(Value); end;
            end;
    //-------------------------------------------------------------- COLOR TABLE
          ipropColorRed: last_red := Value;
          ipropColorGreen: last_green := Value;
          ipropColorBlue:
            if FStack.Destination = rdsColorTable then
            begin
              if (FColIndex >= 0) and (FColIndex <= MaxColors) then
              begin
                if (FColIndex > 0) and
                  (last_red = 0) and (last_green = 0) and (Value = 0) then
                  ColorMapTable[FColIndex] := 15 //(works due to TWPRTFProps.Init) - false: FRTFProps.AddColor(clBlack)
                else
                  ColorMapTable[FColIndex] :=
                    FRTFProps.AddColor(last_red, last_green, Value);
              end;
            end;
    //---------------------------------------------------------------- CHAR ATTR
          ipropPlain:
            begin //CHAR-ATTR:NORMAL
              if FReadingStyle <> nil then
              begin
               // nop
              end
              else
              begin
                Attr.CharAttr := DefAttrCharAttr;
{$IFDEF FIXUP_CHARSTYLES}FHasCharStyles := FALSE; {$ENDIF}
{$IFDEF RTFREAD_USEDEFAULTATTR}
                if not OptIgnoreFontStyles then
                begin
                 // Define the color to be DEFAULT
                  Attr.SetColorNr(0);
                 // Define the basic styles to be switched off
                  Attr.SetCharStyles(WPSTY_BOLD + WPSTY_ITALIC + WPSTY_UNDERLINE, 0);
                end;
{$ENDIF}
              end;
              if not OptIgnoreFonts then
              begin
                Attr.SetFont(FDefaultFontNr);
                if FDefaultFontNrMap >= 0 then //V5.20.6
              //  Attr.SetFontCharSet(FFontTbl.FontCharSet[FDefaultFontNrMap]); //V5.20.6
                  Attr.ASet(WPAT_CharCharset, FFontTbl.FontCharSet[FDefaultFontNrMap]); //V5.22.2
                Attr.SetFontSize(FDefaultFontSize); //V5.18.1a
              end;
            end;
          ipropBold:
            begin //CHAR-ATTR:BOLD
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_BOLD)
              else if not OptIgnoreFontStyle then
              begin
                if Value = 0 then
                  Attr.ExcludeStyle(afsBold)
                else Attr.IncludeStyle(afsBold);
              end;
            end;
          ipropItalic:
            begin //CHAR-ATTR:afsItalic
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_ITALIC)
              else if not OptIgnoreFontStyle then
              begin
                if Value = 0 then Attr.ExcludeStyle(afsItalic)
                else Attr.IncludeStyle(afsItalic);
              end;
            end;
          ipropUnderline:
            begin //CHAR-ATTR: Underline
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_UNDERLINE)
              else if not OptIgnoreFontStyle then
              begin
                if Value = 0 then // ALL OFF
                begin
                  Attr.ExcludeStyle(afsUnderline);
                  Attr.SetUnderlineMode(WPUND_NoLine); //!!!
                  Attr.SetUnderlineColorNr(-1);
                end else // Simple underline
                begin
                  Attr.SetUnderlineMode(-1);
                  Attr.IncludeStyle(afsUnderline);
                end;
              end;
            end;
          ipropUnderlineMode:
            begin
              if FReadingStyle <> nil then
              begin
                FReadingStyle.ASet(WPAT_UnderlineMode, Value);
              end
              else
              begin
                if not OptIgnoreFontStyle then
                begin
                  if Value = WPUND_Double then
                  begin
                    FHasDoubleUnderlines := TRUE;
                  end;
                  Attr.SetUnderlineMode(Value);
                end;
              end;
            end;
          ipropUnderlineColor:
            begin
              if FReadingStyle <> nil then
              begin
                FReadingStyle.ASet(WPAT_UnderlineColor, ColorMapTable[Value]);
              end else
                if Value = 0 then Attr.SetUnderlineColorNr(-1)
                else Attr.SetUnderlineColorNr(ColorMapTable[Value]);
            end;
          ipropFontNr:
            begin
              if FStack.Destination = rdsFonttbl then
              begin
                FFontTbl.aktnr := Value;
                FFontTbl.aktCharset := -1;
              end
              else if not OptIgnoreFonts and (Value >= 0) and (Value < MAXFONTTBL) then //V5.17.4
              begin
                if FReadingStyle <> nil then
                begin
                  FReadingStyle.ASet(WPAT_CharFont, FFontTbl.Fontnr[Value]);
                  if FFontTbl.FontCharSet[Value] > 0 then
                    FReadingStyle.ASet(WPAT_CharCharset, FFontTbl.FontCharSet[Value])
                  else FReadingStyle.ADel(WPAT_CharCharset);
                end
                else
                begin
                  Attr.SetFont(FFontTbl.Fontnr[Value]);
                  if FFontTbl.FontCharSet[Value] > 0 then
                    Attr.ASet(WPAT_CharCharset, FFontTbl.FontCharSet[Value])
                  else Attr.ADel(WPAT_CharCharset);
                  FCurrentCodePage := FFontTbl.FontCodePage[Value];
                  FStack.FCurrentCodePage := FCurrentCodePage;
                end;
              end;
            end;
          ipropFontCharset:
            if FStack.Destination = rdsFonttbl then
            begin
              FFontTbl.aktCharset := Value;
            end;
          ipropFontSize:
{$IFNDEF RTF_SECURITY_CHECK}
            if Value < 2000 then // 1000 pt maximum
{$ENDIF}
              if not (loIgnoreFontSize in FLoadOptions) and not OptIgnoreFontSize then
              begin
                if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_CharFontSize, Value * 50)
                else Attr.SetFontSize(Value / 2);
              end;
          ipropColor:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_CharColor, ColorMapTable[Value])
              else Attr.SetColorNr(ColorMapTable[Value]);
            end;
          ipropBkColor:
            begin
              if ColorMapTable[Value] = 0 then
                aValue := FRTFProps.AddColor(clBlack)
              else aValue := ColorMapTable[Value];
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_CharBGColor, aValue)
              else Attr.SetBGColorNr(aValue);
            end;
          ipropShadowed: { shaded or protected Text	}
            begin
{$IFDEF USE_WPTOOLS3_PROTECT}
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_PROTECTED)
              else if Value = 0 then // ALL OFF
                Attr.ExcludeStyle(afsProtected)
              else
                Attr.IncludeStyle(afsProtected);
{$ENDIF}
            end;
          ipropProtected: { \wpprot	}
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_PROTECTED)
              else if Value = 0 then // ALL OFF
                Attr.ExcludeStyle(afsProtected)
              else
                Attr.IncludeStyle(afsProtected);
            end;
          ipropHidden:
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_HIDDEN)
              else if Value = 0 then // ALL OFF
                Attr.ExcludeStyle(afsHidden)
              else
                Attr.IncludeStyle(afsHidden);
            end;
          ipropNoSuperSub:
            begin
              if FReadingStyle <> nil then
              begin
                FReadingStyle.ASetCharStyle(false, WPSTY_SUPERSCRIPT);
                FReadingStyle.ASetCharStyle(false, WPSTY_SUBSCRIPT);
              end else
              begin
                Attr.ExcludeStyle(afsSuper);
                Attr.ExcludeStyle(afsSub);
              end;
            end;
          ipropSuper:
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_SUPERSCRIPT)
              else if Value = 0 then Attr.ExcludeStyle(afsSuper) else
              begin
                Attr.IncludeStyle(afsSuper);
                Attr.ExcludeStyle(afsSub);
              end;
            end;
          ipropSub:
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_SUBSCRIPT)
              else if Value = 0 then Attr.ExcludeStyle(afsSub) else
              begin
                Attr.ExcludeStyle(afsSuper);
                Attr.IncludeStyle(afsSub);
              end;
            end;
          ipropUPSuper:
            begin
              if FReadingStyle <> nil then
              begin
                if Value < $8000 then
                  FReadingStyle.ASet(WPAT_CharLevel, Value)
                else if Value < 0 then
                  FReadingStyle.ASet(WPAT_CharLevel, $8000 + Abs(Value))
                else FReadingStyle.ASet(WPAT_CharLevel, 0);
              end else
              begin
                if Value < $8000 then
                  Attr.SetCharLevel(Value)
                else if Value < 0 then
                  Attr.SetCharLevel($8000 + Abs(Value))
                else Attr.SetCharLevel(0);
              end;
            end;
          ipropDnSub:
            begin
              if FReadingStyle <> nil then
              begin
                if Value < $8000 then
                  FReadingStyle.ASet(WPAT_CharLevel, $8000 + Value)
                else if Value < 0 then
                  FReadingStyle.ASet(WPAT_CharLevel, Abs(Value))
                else FReadingStyle.ASet(WPAT_CharLevel, 0);
              end else
              begin
                if Value < $8000 then
                  Attr.SetCharLevel($8000 + Value)
                else if Value < 0 then
                  Attr.SetCharLevel(Abs(Value))
                else Attr.SetCharLevel(0);
              end;
            end;
          ipropStrikeOut:
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_STRIKEOUT)
              else if Value = 0 then
              begin
                Attr.ExcludeStyle(afsStrikeOut);
                Attr.ExcludeStyle(afsDoubleStrikeOut);
              end else
              begin
                Attr.ExcludeStyle(afsDoubleStrikeOut);
                Attr.IncludeStyle(afsStrikeOut);
              end;
            end;
          ipropDblStrikeOut:
            begin
              if FReadingStyle <> nil then
                FReadingStyle.ASetCharStyle(Value > 0, WPSTY_DBLSTRIKEOUT)
              else if Value = 0 then // ALL OFF
              begin
                Attr.ExcludeStyle(afsStrikeOut);
                Attr.ExcludeStyle(afsDoubleStrikeOut);
              end else
              begin
                Attr.ExcludeStyle(afsStrikeOut);
                Attr.IncludeStyle(afsDoubleStrikeOut);
              end;
            end;
    //----------------------------------------------------------- PARAGRAPH ATTR
          ipropPard:
            begin
              FInTBL := FALSE;
              if FReadingStyle <> nil then begin end // FReadingStyle.ADelAttr(true,true,true)
              else
              begin
                if (FCurrentParagraph <> nil) and (FCurrentParagraph.ParagraphType <> wpIsTable) then //VXX
                begin
                  FCurrentParagraph.ADelAttr(true, true, true);
                  FCurrentParagraph.ASetBaseStyle(0);
                  FCurrentParagraph.TabstopClear;
                  FCurrentParagraph.ADel(WPAT_ParProtected);
                  FCurrentParagraph.ADel(WPAT_ParIsOutline);
                  FCurrentParagraph.ADel(WPAT_ParKeepN);
                  FCurrentParagraph.ADel(WPAT_NoWrap);
                end;
                FStack.ADelAttr(true, true, true);
                FStack.ADel(WPAT_ParProtected);
                FStack.ADel(WPAT_ParIsOutline);
                FStack.ADel(WPAT_ParKeepN);
                FStack.ADel(WPAT_NoWrap);
                FStack.ParNrStyle := 0;
                FStack.TabstopClear;
            // Set some properties to the inherited values ---------------------
                FCurrentParagraphBeforePARD := FCurrentParagraph;

                if FStack.FPrevious <> nil then
                  FStack.Props.InTable := FStack.FPrevious.Props.InTable
                else FStack.Props.InTable := FALSE;

                //!!!
                if Last_TableDepth = 0 then Last_TableDepth := TableDepth;
                TableDepth := 0; // 5.19.5 commented out !
                //!!!!
                lastSpaceBetween := 0;
                lastSpaceBetweenHasValue := FALSE;
                lastSpaceSLMULT := -1;
              end;
            end;
          ipropLeftInd:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_IndentLeft, Value)
              else
              begin
         { ASetNeutral: If the value is 0 it will delete an existing entry
           unless the 0 value is required to override an inherited value }
                ASet(WPAT_IndentLeft, Value);
              end;
            end;
          ipropRightInd:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_IndentRight, Value)
              else begin
                ASet(WPAT_IndentRight, Value); end;
            end;
          ipropFirstInd:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_IndentFirst, Value)
              else begin
                ASet(WPAT_IndentFirst, Value); end;
            end;
          ipropJust:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_Alignment, Value)
              else
              begin
                if (FCurrentParagraph <> nil) and
                  (FCurrentParagraph.ParagraphType in [wpIsTable, wpIsTableRow])
                  then
                begin
                  StackASetNeutral(WPAT_Alignment, Value); //V5.17.3
                  FCurrentParagraph.ADel(WPAT_Alignment); //V5.19.7 better save ...
                  FNeedStackAssign := TRUE; //V5.19.7
                end else ASetNeutral(WPAT_Alignment, Value)
              end;
            end;
          ipropVertJust:
            begin
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_VertAlignment, Value)
              else
                if RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                begin
                  tstack.TableCellStyle[tstack.FRowTbl.CellCount].ASetNeutral(WPAT_VertAlignment, Value);
                end
                else
                  ASetNeutral(WPAT_VertAlignment, Value);
            end;
          ipropSpaceBefore:
            begin
              if Value < 0 then Value := 0;
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_SpaceBefore, Value)
              else ASetNeutral(WPAT_SpaceBefore, Value);
            end;
          ipropSpaceBetween: // spacing in twips
            begin
              if Value = 1000 then Value := 0; // RTF Spec 1.5 = Default!
              lastSpaceBetween := Value;
              lastSpaceBetweenHasValue := lastSpaceSLMULT < 0; // only when there was no slmult
              // Great - slmult was BEFORE \sl ---------------------------------
              if lastSpaceSLMULT = 1 then // SET THE LINE HEIGHT
              begin
                if (FReadingStyle <> nil) and (Value = 240) then Value := 0 //V5.19.3 no default
                else Value := Abs(Round(Value / 240 * 100));
                if FReadingStyle <> nil then
                begin
                  FReadingStyle.ADel(WPAT_SpaceBetween);
                  FReadingStyle.ASetNeutral(WPAT_LineHeight, Value);
                end else
                begin
                  ADel(WPAT_SpaceBetween);
                  ASetNeutral(WPAT_LineHeight, Value);
                end;
              end
              // lastSpaceSLMULT undefined or 0 --------------------------------
              else
              begin
                if FReadingStyle <> nil then
                begin
                  FReadingStyle.ADel(WPAT_LineHeight); //V5.19.3
                  FReadingStyle.ASet(WPAT_SpaceBetween, Value);
                end
                else
                begin
                  ADel(WPAT_LineHeight); //V5.19.3
                  ASetNeutral(WPAT_SpaceBetween, Value);
                end;
              end;
              lastSpaceSLMULT := -1; // we used it now ...
            end;
          ipropslmult: // Line spacing multiple
            begin
              lastSpaceSLMULT := Value;
              // -------- the slmult is AFTER the \sl tag: ---------------------
              if lastSpaceBetweenHasValue and (Value = 1) then
              begin
                if (FReadingStyle <> nil) and (lastSpaceBetween = 240) then Value := 0 //V5.19.3
                else Value := Abs(Round(lastSpaceBetween / 240 * 100));
                if FReadingStyle <> nil then
                begin
                  FReadingStyle.ADel(WPAT_SpaceBetween);
                  FReadingStyle.ASetNeutral(WPAT_LineHeight, Value);
                end else
                begin
                  ADel(WPAT_SpaceBetween);
                  ASetNeutral(WPAT_LineHeight, Value);
                end;
              end;
              lastSpaceBetweenHasValue := FALSE;
            end;
          ipropSpaceAfter:
            begin
              if Value < 0 then Value := 0;
              if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_SpaceAfter, Value)
              else ASetNeutral(WPAT_SpaceAfter, Value);
            end;
          ipropKeep: { Keep paragraph intact }
            begin
              // CreateImplizitPar;   XXXX5.11.5
              ASetNeutral(WPAT_ParKeep, 1);
            end;
          ipropKeepn: { Keep paragraph with the next paragraph }
            if not OptIgnoreKeepN then
            begin
              // CreateImplizitPar;
              ASetNeutral(WPAT_ParKeepN, 1);
              FKeepNWasAssignedToThisPar := FCurrentParagraph; //V5.13
              FStack.FNextHasKeepnN := TRUE; // NEXT LEVEL !!! FHasKeepN := TRUE;
            end;
          ipropParProperty:
            begin
              case Value of
            //  1: include(load_par.prop, paprIgnoreParagraphLines);   OBSOLETE
                2: begin
                    CreateImplizitPar;
                    if FCurrentParagraph <> nil then
                      FCurrentParagraph.ASet(WPAT_ParProtected, 1);
                  end;
                3: FIsMergePar := 1; // Start
               // include(FCurrentParagraph.prop, paprIsMergeCommandStart); // we do this temporariyl
                4: // include(FCurrentParagraph.prop, paprIsMergeCommandEnd);
                  FIsMergePar := 2; // End  - Do it in next \par!  but ignore the \par!
              end;
        {
            if (val in [3, 4]) and assigned(WPAssignMergePar)
              and (FCurrentMergePar <> '') then
            begin
              WPAssignMergePar(FMemo, load_par, FCurrentMergePar);
            end;  }
            end;
      // ------------------------------------------------------------ Tabstops
          ipropTabKind: FThisTabKind := TTabKind(Value and 7);
          ipropTabFill: FThisTabFill := TTabFill(Value and 7);
          ipropTabColor: FThisTabColor := ColorMapTable[Value]; // not RTF
          ipropTabPos:
            begin
              if FCurrentParagraph <> nil then FCurrentParagraph.TabstopAdd(Value, FThisTabKind, FThisTabFill, FThisTabColor);
              FStack.TabstopAdd(Value, FThisTabKind, FThisTabFill, FThisTabColor);
              FThisTabKind := tkLeft;
              FThisTabFill := tkNoFill;
              FThisTabColor := 0;
            end;
          ipropTabPosBar:
            begin
              if FCurrentParagraph <> nil then FCurrentParagraph.TabstopAdd(Value, tkBarTab, FThisTabFill, FThisTabColor);
              FStack.TabstopAdd(Value, tkBarTab, FThisTabFill, FThisTabColor);
              FThisTabKind := tkLeft;
              FThisTabFill := tkNoFill;
              FThisTabColor := 0;
            end;
          ipropSymbol:
            begin
              CreateImplizitPar; //V5.19.3a
              case Value of
                1: //endash
                  PrintTextObj(wpobjTextObject, 'UNICODEC', '', false, false, false).CParam := 2013;
                2: // emdash
                  PrintTextObj(wpobjTextObject, 'UNICODEC', '', false, false, false).CParam := 2014;
                3: // bullet
                  PrintTextObj(wpobjTextObject, 'UNICODEC', '', false, false, false).CParam := $2022; // $25CF;
              end;
            end;
          ipropchftn:
            begin
{$IFDEF FIXUP_CHARSTYLES}
              if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
              PrintAChar('#');
            end;
      // ------------------------------------------------------------ Shading
          ipropShading:
            begin
              Value := abs(Value); //V5.21
              if (Value > 0) and (Value < 100) then Value := 100;
              if FReadingStyle <> nil then
                FReadingStyle.ASet(WPAT_ShadingValue, Value div 100)
              else ASetNeutral(WPAT_ShadingValue, Value div 100);
            end;
          ipropBColor: // used by WPTools4 for background.
            begin
              if Value < 0 then aValue := FRTFProps.AddColor(clWhite) else
                if (ColorMapTable[Value] = 0) then aValue := FRTFProps.BlackColorIndex
                else aValue := ColorMapTable[Value];
              if FSwapParColors then
              begin
                if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_FGColor, aValue)
                else ASetNeutral(WPAT_FGColor, aValue);
              end else
              begin
                if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_BGColor, aValue)
                else ASetNeutral(WPAT_BGColor, aValue);
              end;
            end;
          ipropFColor:
            begin
              if Value < 0 then aValue := FRTFProps.BlackColorIndex else
                if (ColorMapTable[Value] = 0) then
                  aValue := FRTFProps.BlackColorIndex
                else aValue := ColorMapTable[Value];
              if FSwapParColors then
              begin
                if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_BGColor, aValue)
                else ASetNeutral(WPAT_BGColor, aValue);
              end else
              begin
                if FReadingStyle <> nil then FReadingStyle.ASet(WPAT_FGColor, aValue)
                else
                begin
                  ASetNeutral(WPAT_FGColor, aValue);
                   // ASet(WPAT_ShadingValue, 100);  //load from V3
                   // ASet(WPAT_ShadingType, WPSHAD_solidfg); //load from V3
                end;
              end;
            end;
          ipropBackgroundPattern:
            begin
              if Value >= 0 then
                ASetNeutral(WPAT_ShadingType, Value)
              else ASetNeutral(WPAT_ShadingType, WPSHAD_clear);
            end;
      // Cells
          ipropShadingCELL:
            begin
              Value := abs(Value); //V5.21
              if RowReading and InTStack then
              begin
                TableVar[TableDepth].CurrentCell.ASet(WPAT_ShadingValue, Value div 100);
              end;
            end;
          ipropBColorCELL:
            if Value >= 0 then
            begin
              if ColorMapTable[Value] = 0 then
                aValue := FRTFProps.BlackColorIndex
              else aValue := ColorMapTable[Value];
              if RowReading and InTStack then
              begin
                if FSwapParColors then
                begin
                  if FReadingStyle <> nil then TableVar[TableDepth].CurrentCell.ASet(WPAT_FGColor, aValue)
                  else TableVar[TableDepth].CurrentCell.ASetNeutral(WPAT_FGColor, aValue);
                end else
                begin
                  if FReadingStyle <> nil then TableVar[TableDepth].CurrentCell.ASet(WPAT_BGColor, aValue)
                  else TableVar[TableDepth].CurrentCell.ASetNeutral(WPAT_BGColor, aValue);
                end;
              end;
            end;
          ipropFColorCELL:
            if Value >= 0 then
            begin
              if ColorMapTable[Value] = 0 then
                aValue := FRTFProps.BlackColorIndex
              else aValue := ColorMapTable[Value];
              if RowReading and InTStack then
              begin
                if FSwapParColors then
                begin
                  if FReadingStyle <> nil then TableVar[TableDepth].CurrentCell.ASet(WPAT_BGColor, aValue)
                  else TableVar[TableDepth].CurrentCell.ASetNeutral(WPAT_BGColor, aValue);
                end else
                begin
                  if FReadingStyle <> nil then TableVar[TableDepth].CurrentCell.ASet(WPAT_FGColor, aValue)
                  else TableVar[TableDepth].CurrentCell.ASetNeutral(WPAT_FGColor, aValue);
                end;
              end;
            end;
          ipropBackgroundPatternCELL:
            begin
              if Value >= 0 then
                TableVar[TableDepth].CurrentCell.ASet(WPAT_ShadingType, Value)
              else TableVar[TableDepth].CurrentCell.ASet(WPAT_ShadingType, WPSHAD_clear);
            end;
      // Table Style
          ipropShadingTS:
            begin

            end;
          ipropBColorTS:
            begin

            end;
          ipropFColorTS:
            begin

            end;
          ipropBackgroundPatternTS: //V5.12.2
            begin
              if (ReadingBorderRange = wpreadCellBorder) and
                (TableVar[TableDepth] <> nil) and
                (TableVar[TableDepth].CurrentCell <> nil) then
              begin
                if Value >= 0 then
                  TableVar[TableDepth].CurrentCell.ASet(WPAT_ShadingType, Value)
                else
                begin
                  TableVar[TableDepth].CurrentCell.ASet(WPAT_ShadingType, WPSHAD_clear);
                   // TableVar[TableDepth].CurrentCell.ADel(WPAT_FGColor);
                   // TableVar[TableDepth].CurrentCell.ADel(WPAT_BGColor);
                end;
              end;
            end;
    //------------------------------------------------------------- Load Borders
          ipropBorderStartBOX:
            begin
              ReadingBorderRange := wpreadParBorder;
              ReadingBorder := BLBox;
              ReadingBorderValue := WPBRD_DRAW_Box;
            end;
          ipropBorderStartDef:
            begin
              ReadingBorderRange := wpreadParBorder;
              ReadingBorder := TOneBorderType(Value);
              ReadingBorderValue := WPBRD_BorderTranslate[ReadingBorder];
            end;
          ipropBorderStartDefROW:
            begin
              ReadingBorderRange := wpreadRowBorder;
              ReadingBorder := TOneBorderType(Value);
              ReadingBorderValue := WPBRD_BorderTranslate[ReadingBorder];
            end;
          ipropBorderStartDefCELL:
            begin
              ReadingBorderRange := wpreadCellBorder;
              ReadingBorder := TOneBorderType(Value);
              ReadingBorderValue := WPBRD_BorderTranslate[ReadingBorder];
            end;
          ipropBorderStartDefTS:
            begin
              ReadingBorderRange := wpreadTSBorder;
              ReadingBorder := TOneBorderType(Value);
              ReadingBorderValue := WPBRD_BorderTranslate[ReadingBorder];
            end;
          ipropBorderType:
            begin
              if Trunc(WrittenByWPToolsVersion) = 4.0 then
              begin
                SelBrd := BLBox; // Change ALL Borders at once!
              end else SelBrd := ReadingBorder;
            //  if Value=WPBRD_SHADOW then Value := WPBRD_SINGLE;
              if Value <> WPBRD_NONE then
              begin
                case ReadingBorderRange of
                  wpreadParBorder:
                    begin
                      if FCurrentParagraph <> nil then
                      begin
                        FCurrentParagraph.ASetAdd(WPAT_BorderFlags, ReadingBorderValue);
                        if Value <> 0 then FCurrentParagraph.ASet(WPBRD_BorderTypeTranslate[SelBrd], Value);
                      end;
                      FStack.ASetAdd(WPAT_BorderFlags, ReadingBorderValue);
                      if Value <> 0 then FStack.ASet(WPBRD_BorderTypeTranslate[SelBrd], Value);

                    end;
                  wpreadRowBorder:
                    begin
                      if RowReading and InTStack and (TableVar[TableDepth].FTableRowStyle <> nil) then
                      begin
                        TableVar[TableDepth].FTableRowStyle.ASetAdd(WPAT_BorderFlags, ReadingBorderValue);
                        if Value <> 0 then
                          TableVar[TableDepth].FTableRowStyle.ASet(WPBRD_BorderTypeTranslate[SelBrd], Value);
                       // ALL BORDERS
                        TableVar[TableDepth].FTableRowStyle.ASet(WPAT_BorderType, Value);
                      end;
                    end;
                  wpreadCellBorder:
                    begin
                      if RowReading and InTStack then
                      begin
                        // TableVar[TableDepth].CurrentCell.ASetAdd(WPAT_BorderFlags, ReadingBorderValue);
                        TableVar[TableDepth].FRowTbl.CellBorder[
                          TableVar[TableDepth].FRowTbl.CellCount] :=
                          TableVar[TableDepth].FRowTbl.CellBorder[
                          TableVar[TableDepth].FRowTbl.CellCount] or ReadingBorderValue;
                        if Value <> 0 then TableVar[TableDepth].CurrentCell.ASet(WPBRD_BorderTypeTranslate[SelBrd], Value);
                      end;
                    end;
                  wpreadTSBorder:
                    begin

                    end;
                end;
              end;
            end;
          ipropBorderWidth:
            begin
              if Value > 75 then Value := 75 else if Value < 0 then Value := 0;

              if (FWrittenByWPToolsVersion > 0) and (FWrittenByWPToolsVersion < 5) then
                aReadingBorder := WPAT_BorderWidth
              else aReadingBorder := WPBRD_BorderWidthTranslate[ReadingBorder];

              if Value <> 0 then
                case ReadingBorderRange of
                  wpreadParBorder:
                    begin
                      if FCurrentParagraph <> nil then
                        FCurrentParagraph.ASet(aReadingBorder, Value);
                      FStack.ASet(aReadingBorder, Value);
                    end;
                  wpreadRowBorder:
                    begin
                      if RowReading and InTStack and (TableVar[TableDepth].FTableRowStyle <> nil) then
                        TableVar[TableDepth].FTableRowStyle.ASet(aReadingBorder, Value);
                    end;
                  wpreadCellBorder:
                    begin
                      if RowReading and InTStack and (aReadingBorder <> WPAT_BorderFlags) then
                        TableVar[TableDepth].CurrentCell.ASet(aReadingBorder, Value);
                    end;
                  wpreadTSBorder:
                    begin

                    end;
                end;
            end;
          ipropBorderColor:
            begin

              if (FWrittenByWPToolsVersion > 0) and (FWrittenByWPToolsVersion < 5) then
                aReadingBorder := WPAT_BorderColor
              else aReadingBorder := WPBRD_BorderColorTranslate[ReadingBorder];

              if Value <> 0 then
                case ReadingBorderRange of
                  wpreadParBorder:
                    begin
                      if FCurrentParagraph <> nil then
                        FCurrentParagraph.ASet(aReadingBorder, ColorMapTable[Value]);
                      FStack.ASet(aReadingBorder, ColorMapTable[Value]);
                    end;
                  wpreadRowBorder:
                    begin
                      if RowReading and InTStack and (TableVar[TableDepth].FTableRowStyle <> nil) then
                        TableVar[TableDepth].FTableRowStyle.ASet(aReadingBorder, ColorMapTable[Value]);
                    end;
                  wpreadCellBorder:
                    begin
                      if RowReading and InTStack then
                        TableVar[TableDepth].CurrentCell.ASet(aReadingBorder, ColorMapTable[Value]);
                    end;
                  wpreadTSBorder:
                    begin

                    end;
                end;
            end;
          // \ brspN	Space in twips between borders and the paragraph
          ipropBorderSpace:
            begin
              if (FWrittenByWPToolsVersion > 0) and (FWrittenByWPToolsVersion < 5) then
              begin
{$IFDEF MUL_BRDSP_3_WPTOOLS3} //possible WorkAround when reading old wptools files
                if FWrittenByWPToolsVersion = 3 then
                  Value := Round(Value * 2.5);
{$ENDIF}
                aReadingBorder := WPAT_PaddingAll;
              end
              else aReadingBorder := WPBRD_BorderSpaceTranslate[ReadingBorder];

              if (Value <> 0) and (aReadingBorder <> 0) then
                case ReadingBorderRange of
                  wpreadParBorder:
                    begin
                      if FCurrentParagraph <> nil then
                        FCurrentParagraph.ASet(aReadingBorder, Value);
                      FStack.ASet(aReadingBorder, Value);
                    end;
                  wpreadRowBorder:
                    begin
                      if RowReading and InTStack and (TableVar[TableDepth].FTableRowStyle <> nil) then
                        TableVar[TableDepth].FTableRowStyle.ASet(aReadingBorder, Value);
                    end;
                  wpreadCellBorder:
                    begin

                    end;
                  wpreadTSBorder:
                    begin

                    end;
                end;
            end;
    //-------------------------------------------------- WPTOOLS PARAGRAPH FLAGS
          ipropCellFormat:
            begin
              CreateImplizitPar;
              if FCurrentParagraph <> nil then
                FCurrentParagraph.ASet(WPAT_PAR_FORMAT, Value);
            end;
          ipropAutoPageBreak {= 141}: begin end;
          ipropMaxPar:
            begin
              CreateImplizitPar;
              if FCurrentParagraph <> nil then
                FCurrentParagraph.ASet(WPAT_MaxLength, Value);
            end;
          ipropNoWordWrap:
            begin
              ASetNeutral(WPAT_NoWrap, Value);
            end;
          ipropPreformatted:
            begin
            // At least we know that this was WPTools 4 V5 does not use this flag!
            // so we have a positive that this file was saved with Version 4
              FWrittenByWPToolsVersion := 4.0;
            end;
          ipropLineHeight {= 112}: begin end;
          ipropParID:
            begin
              CreateImplizitPar;
              if FCurrentParagraph <> nil then
                FCurrentParagraph.ASet(WPAT_ParID, Value);
            end;
          ipropParHidden:
            begin
              CreateImplizitPar;
              if FCurrentParagraph <> nil then
              begin
                if Value <> 0 then
                  include(FCurrentParagraph.prop, paprHidden)
                else
                  exclude(FCurrentParagraph.prop, paprHidden);
              end;
            end;
          ipropwpreadonly:
            begin
              FRTFData.Readonly := (value <> 0); //V5.11.1
            end;
          ipropParFLG:
            begin
              CreateImplizitPar;
              if FCurrentParagraph <> nil then
                FCurrentParagraph.ASet(WPAT_ParFlags, Value);
            end;
        end
      else
        if ipropCode < ipropGroupEnd2 then // GROUP 2
          case ipropCode of
    //----------------------------------------------------- PARAGRAPHS AND CELLS
{$IFNDEF IGNORE_TBLTAGS}
            ipropTableStart: if not OptIgnoreTableSETags then
              begin
                if FTableStart >= 0 then
                  CreateImplizitPar; // make sure we have a cell!
                inc(FTableStart);
                FStack.Props.InTable := TRUE;
                FStack.ASetBaseStyle(0);
                tstack := TableVar[TableDepth];
                tstack.FInsideTable := FALSE;
                tstack.FInsideRow := FALSE;
                tstack.FInsideCell := FALSE;
                tstack.FLastCellInRow := nil;
                tstack.FFirstCellInRow := nil;
                tstack.Clear; // Clear styles!
                for i := 0 to Length(tstack.FRowTbl.CellWidth) - 1 do
                begin
                  tstack.FRowTbl.CellWidth[i] := 0;
                  tstack.FRowTbl.CellBestWidth[i] := 0;
                  tstack.FRowTbl.CellFlags[i] := 0;
                  tstack.FRowTbl.CellBorder[i] := 0;
                    // tstack.TableCellStyle[i].Clear; done above already!
                end;
                tstack.FRowTbl.AllWidth := 0;
                tstack.FRowTbl.BoxWidth := 0;
                tstack.FRowTbl.BoxWidth_PC := 0;
                tstack.FRowTbl.ResetCellCount := FALSE;
                tstack.FRowTbl.CellCount := 0;
                tstack.FRowTbl.SpaceBetweenCellsH := 0;
                tstack.FRowTbl.SpaceBetweenCells := 0;
                tstack.FRowTbl.RowFlags := 0;
                tstack.FRowTbl.RowHeight := 0;
                tstack.FRowTbl.RowAlign := 0;
                tstack.FRowTbl.RowLeft := 0; //V5.19.8
                tstack.FTableRowStyle.Clear;
                CreateImplizitPar;
              end;
            ipropTableEnd: if not OptIgnoreTableSETags then
              begin
                tstack := TableVar[TableDepth];
                tstack.FDontCombineTables := TRUE;
                if FTableStart >= 0 then dec(FTableStart);
              end;
{$ENDIF}
            ipropTableRowEnd: // \row
              begin
                CloseCurrentRow;
              end;
            ipropTableCellEnd: // \\cell
              begin
          //  CreateImplizitPar;
                if TableDepth > 0 then
                begin
                  TableDepth := 0;
                  FTableStart := 0; //V5.21.1 ALSO WHEN USING START TAGS!!!
                 // Assert(TableVar[TableDepth].FLastCellInRow <> nil, 'Where is the cell in level 0, at ' + IntToStr(ReadPosition));
                  if TableVar[TableDepth].FLastCellInRow <> nil then
                    FCurrentParagraph := TableVar[TableDepth].FLastCellInRow;
                end;

                if not TableVar[TableDepth].FInsideCell then
                begin
                  CreateImplizitPar;
         //   if not TableVar[TableDepth].FInsideRow then
         //   begin
         //     if FCurrentParagraph.ParagraphType<>wpIsTable then
         //     begin
         //        {$IFDEF WPDEBUG}
         //           FRTFDataCollection.StatusMsg(WPST_ReadInfo, 'Problem: wpIsTable');
         //        {$ENDIF}
         //     end;
         //     NewChildParagraph;
         //     FCurrentParagraph.ParagraphType := wpIsTableRow;
         //     TableVar[TableDepth].FTableRow := FCurrentParagraph;
         //     TableVar[TableDepth].FInsideRow := TRUE;
         //     TableVar[TableDepth].FFirstCellInRow := nil;
         //     TableVar[TableDepth].FLastCellInRow := nil;
         //   end;
         //   NewChildParagraph;
         //   include(FCurrentParagraph.prop, paprIsTable);
         //   if TableVar[TableDepth].FFirstCellInRow = nil then
         //     TableVar[TableDepth].FFirstCellInRow := FCurrentParagraph;
         //   TableVar[TableDepth].FLastCellInRow := FCurrentParagraph;
                end;
{$IFDEF FIXUP_CHARSTYLES}
                if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
                if FCurrentParagraph <> nil then
                begin
                  if FCurrentParagraph.CharCount = 0 then
                    FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
                  if not (paprIsTable in FCurrentParagraph.prop) then
                    ParLevelUp;
                  if not (FCurrentParagraph.ParagraphType = wpIsTableRow) then
                    ParLevelUp;
                end;
                TableVar[TableDepth].FInsideCell := FALSE;
                TableVar[TableDepth].FLastCellInRow := nil; // dont needed anymore !
                if not TableVar[TableDepth].FInsideTable then
                  TableVar[TableDepth].FInsideTable := TRUE;
                if not TableVar[TableDepth].FInsideRow then
                  TableVar[TableDepth].FInsideRow := TRUE;
              end;
            ipropInTable: // intbl
              begin
                // V5.11.2 for RTF code such as
                // \pard\plain \ltrpar\ql \li0\ri0\sa120\widctlpar\intbl\faau
                // here the  intbl comes after the properties !
                if not FStack.Props.InTable and
                  (FCurrentParagraph <> nil) and
                  (FCurrentParagraphBeforePARD <> nil) and
                  (FCurrentParagraphBeforePARD <> FCurrentParagraph) and
                  (FCurrentParagraph.CharCount = 0) and
                  (FCurrentParagraphBeforePARD.Cell <> nil) then
                begin
                  FLastWasSTDPar := FALSE;
                end;
                FStack.Props.InTable := TRUE;
                FInTBL := TRUE;
              end;
            ipropNestTableRow: // \nestrow
              begin
                CloseCurrentRow;
                // FLastWasSTDPar := TRUE; not here! new par in CreateImplizitPar !
              end;
            ipropNestTableCell: // \nestcell
              begin
                CreateImplizitPar;
                if FCurrentParagraph.CharCount = 0 then
                  FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
                TableVar[TableDepth].FInsideCell := FALSE;
                FCurrentParagraph := TableVar[TableDepth].FTableRow;
              end;
            ipropNestTableDepth:
              begin
                if (Value = 1) and not FInTBL then
                begin
                  if not FStack.Props.InTable and
                    (FCurrentParagraph <> nil) and
                    (FCurrentParagraphBeforePARD <> nil) and
                    (FCurrentParagraphBeforePARD <> FCurrentParagraph) and
                    (FCurrentParagraph.CharCount = 0) and
                    (FCurrentParagraphBeforePARD.Cell <> nil) then
                  begin
                    FLastWasSTDPar := FALSE;
                  end;
                  FStack.Props.InTable := TRUE;
                  FInTBL := TRUE;
                end;
            (*    if FTableVar <> nil then
                  for i := Value to FTableVar.Count - 1 do //V5.18.5
                    TWPRTFTableStack(FTableVar[i]).FInsideTable := FALSE;
                if Value > 1 then
                  FLastWasSTDPar := FALSE;
                TableDepth := Value - 1;
                if TableDepth < 0 then TableDepth := 0; *)

                TableDepth := Value - 1;
                if TableDepth < 0 then TableDepth := 0;
                if FTableVar <> nil then
                  for i := TableDepth + 1 to FTableVar.Count - 1 do //V5.18.5
                  begin
                    FillChar(TWPRTFTableStack(FTableVar[i]).FRowTbl,
                      SizeOf(TWPRTFReadTable), 0); //V5.24.2
                    if TWPRTFTableStack(FTableVar[i]).FTableRowStyle <> nil then
                      TWPRTFTableStack(FTableVar[i]).FTableRowStyle.Clear; //V5.24.2
                    TWPRTFTableStack(FTableVar[i]).FInsideTable := FALSE;
                  end;
                if Value > 1 then
                  FLastWasSTDPar := FALSE;
              end;

      // -------------------------------------------------------------------------
            ipropTableRowDefaults:
              if InTStack then
              begin
          // trowd sometimes comes BEFORE itap - ResetValues on Demand
                FStack.FInTROWD := TRUE; 
                FStack.Props.InTable := TRUE; 
                FStack.ASetBaseStyle(0);

                if TableVar[TableDepth].FRowTbl.ResetCellCount then
                begin
                  tstack.Clear; // Clear styles!
                  for i := 0 to TableVar[TableDepth].FRowTbl.CellCount do
                  begin
                    tstack.FRowTbl.CellWidth[i] := 0;
                    tstack.FRowTbl.CellBestWidth[i] := 0;
                    tstack.FRowTbl.CellFlags[i] := 0;
                    tstack.FRowTbl.CellBorder[i] := 0;
                    // tstack.TableCellStyle[i].Clear; done above already!
                  end;
                  tstack.FRowTbl.AllWidth := 0;
                  tstack.FRowTbl.BoxWidth := 0;
                  tstack.FRowTbl.BoxWidth_PC := 0;
                  tstack.FRowTbl.ResetCellCount := FALSE;
                  tstack.FRowTbl.CellCount := 0;
                  tstack.FRowTbl.SpaceBetweenCellsH := 0;
                  tstack.FRowTbl.SpaceBetweenCells := 0;
                  tstack.FRowTbl.RowFlags := 0;
                  tstack.FRowTbl.RowHeight := 0;
                  tstack.FRowTbl.RowAlign := 0;
                  tstack.FRowTbl.RowLeft := 0; //V5.19.8
                  tstack.FTableRowStyle.Clear;
                end;
              end;
            ipropTableCellDefaults:
              begin

              end;
            ipropRowIndex: if InTStack then begin tstack.FRowTbl.RowI := Value; end;
            ipropRowBandIndex: if InTStack then begin tstack.FRowTbl.RowBand := Value; end;
            ipropIsLastRow: if InTStack then
              begin
                tstack.FRowTbl.RowFlags :=
                  tstack.FRowTbl.RowFlags or WPRDFLAG_IsLastRow;
              end;
            iproptrleft:
              if InTStack then
              begin
                tstack.FRowTbl.RowLeft := Value;
{$IFNDEF CELLX_EXCLUDES_TRLEFT}
                if (FWrittenByWPToolsVersion > 0) and //V5.21 - import old documents correctly
                  (FWrittenByWPToolsVersion < 5.19) then
                  tstack.FRowTbl.CellLast := 0
                else
                  tstack.FRowTbl.CellLast := Value; // ok
{$ELSE}
                tstack.FRowTbl.CellLast := 0;
{$ENDIF}
              end;
            ipropTableCellX:
              if RowReading and InTStack then
              begin
                if Value < tstack.FRowTbl.CellLast then
                  Value := tstack.FRowTbl.CellLast + 30;
                tstack.FRowTbl.CellWidth[tstack.FRowTbl.CellCount] :=
                  Value - tstack.FRowTbl.CellLast;
                // was: inc(tstack.FRowTbl.AllWidth, Value - tstack.FRowTbl.CellLast);
{$IFNDEF CELLX_EXCLUDES_TRLEFT} // V5.20.5
                tstack.FRowTbl.AllWidth := Value
                  - tstack.FRowTbl.RowLeft; // ok
{$ELSE}
                tstack.FRowTbl.AllWidth := Value;
{$ENDIF}

                tstack.FRowTbl.CellLast := Value;
                inc(tstack.FRowTbl.CellCount);
              end;
            ipropTable_clmgf: // not used anymore ?
              if InTStack then
              begin
              end;
            ipropTable_clmrg:
              if RowReading and InTStack then
              begin
                tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                  WPRDFLAG_CELLMERGE;
              end;
            ipropTable_clvmgf: begin end;
            ipropTable_clvmrg:
              if not OptIgnoreRowMerge and RowReading and InTStack then
              begin
                tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                  WPRDFLAG_ROWMERGE;
              end;
            ipropTable_trftsWidth: trftsWidth_mode := Value;
            ipropTable_trwWidth:
              if RowReading and InTStack then
              begin
                if trftsWidth_mode = 3 then
                  tstack.FRowTbl.BoxWidth := Value
                else if trftsWidth_mode = 2 then
                  tstack.FRowTbl.BoxWidth_PC := Value;
                trftsWidth_mode := 0;
              end;
  // ---------------------------------------------------------- ROW&CELL PADDING
            iproptrgaph: // Half the space between the cells of a table row in twips.
              begin
                if RowReading and InTStack then
                  tstack.FRowTbl.SpaceBetweenCellsH := Value;
              end;
            iproptableflags:
              begin
                if RowReading and InTStack then
                  tstack.TableFlags := tstack.TableFlags or Value;
              end;
            iproprowAutoFit:
              begin
{$IFNDEF DONOTREAD_AUTOWIDTH_TABLES}
                if (Value <> 0) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RAutoFit;
{$ENDIF}
              end;
            iproprowflags:
              begin
                if (Value <> 0) and RowReading and InTStack then
                begin
                  if Value = WPRDFLAG_LTR then
                    tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags and not WPRDFLAG_RTL
                  else
                    tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or Value;
                end;
              end;
            iproprowalign:
              begin
                if RowReading and InTStack then
                begin
                  tstack.FRowTbl.RowAlign := Value;
                  if Value = 0 then
                  begin
                    tstack.FRowTbl.CellLast := 0;
                    tstack.FRowTbl.RowLeft := 0;
                  end;
                end;
              end;
            iproprowheight:
              begin
                if RowReading and InTStack then
                  tstack.FRowTbl.RowHeight := Value; //trrh
              end;
            ipropTable_trpaddl:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_PaddingLeft, Value);
              end;
            ipropTable_trpaddt:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_PaddingTop, Value);
              end;
            ipropTable_trpaddr:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_PaddingRight, Value);
              end;
            ipropTable_trpaddb:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_PaddingBottom, Value);
              end;
            ipropTable_trpaddfl:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trpaddl;
              end;
            ipropTable_trpaddft:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trpaddt;
              end;
            ipropTable_trpaddfr:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trpaddr;
              end;
            ipropTable_trpaddfb:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trpaddb;
              end;
            ipropTable_trspdl:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_CELLSPACEL, Value);
              end;
            ipropTable_trspdt:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_CELLSPACET, Value);
              end;
            ipropTable_trspdr:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_CELLSPACER, Value);
              end;
            ipropTable_trspdb:
              begin
                if RowReading and InTStack then
                  tstack.FTableRowStyle.ASetNeutral(WPAT_CELLSPACEB, Value);
              end;
            ipropTable_trspdfl:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trspdl;
              end;
            ipropTable_trspdft:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trspdt;
              end;
            ipropTable_trspdfr:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trspdr;
              end;
            ipropTable_trspdfb:
              begin
                if (Value = 3) and RowReading and InTStack then
                  tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or WPRDFLAG_RUse_trspdb;
              end;

            ipropTable_clpadl:
              begin
                if RowReading and InTStack then
                begin
                  tstack.CurrentCell.ASetNeutral(WPAT_PaddingLeft, Value);
                end;
              end;
            ipropTable_clpadt:
              begin
                if RowReading and InTStack then
                  tstack.CurrentCell.ASetNeutral(WPAT_PaddingTop, Value);
              end;
            ipropTable_clpadr:
              begin
                if RowReading and InTStack then
                  tstack.CurrentCell.ASetNeutral(WPAT_PaddingRight, Value);
              end;
            ipropTable_clpadb:
              begin
                if RowReading and InTStack then
                  tstack.CurrentCell.ASetNeutral(WPAT_PaddingBottom, Value);
              end;
            ipropTable_clpadfl:
              begin
                if (Value = 3) and RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                    WPRDFLAG_Use_clpadl;
              end;
            ipropTable_clpadft:
              begin
                if (Value = 3) and RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                    WPRDFLAG_Use_clpadt;
              end;
            ipropTable_clpadfr:
              begin
                if (Value = 3) and RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                    WPRDFLAG_Use_clpadr;
              end;
            ipropTable_clpadfb:
              begin
                if (Value = 3) and RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                    WPRDFLAG_Use_clpadb;
              end;
            ipropTable_clNoWrap: // Fit text in cell, compressing each paragraph to the width of the cell.
              begin
                if {RowReading and} InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or
                    WPRDFLAG_NoWrap;
              end;
            ipropTable_clwWidth:
              begin
{$IFNDEF DONTUSE_clwWidth}
                if RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                  tstack.FRowTbl.CellBestWidth[tstack.FRowTbl.CellCount] := Value;
{$ENDIF}
              end;
            ipropTable_clwWidthF: // Value (1=Auto, 2=%, 3=Twips)
              begin
{$IFNDEF DONTUSE_clwWidth}
                if RowReading and InTStack
                  and (tstack.FRowTbl.CellCount <= MaxCellAnz) then
                begin
                  case Value of
                    1: i := WPRDFLAG_WIDTH_ISOFF;
                    2: i := WPRDFLAG_WIDTH_ISPT;
                    3: i := WPRDFLAG_WIDTH_ISTW;
                  else i := 0;
                  end;
                  tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] :=
                    tstack.FRowTbl.CellFlags[tstack.FRowTbl.CellCount] or i;
                end;
{$ENDIF}
              end;
  // Borders ... trbrdrt
    // -------------------------------------------------------------------------

        // -------------------------------------------------------- Load Images
            ipropPicSource:
              if FPicture.pReading then
              begin
                FPicture.pType := TWPRTFPictType(Value);
              end;
            ipropPicSourcePMeta:
              if FPicture.pReading then
              begin
                FPicture.pType := wpreadPictPMMetafile;
                FPicture.pMetafile := Value;
              end;
            ipropPicSourceWMeta:
              if FPicture.pReading then
              begin
                FPicture.pType := wpreadPictWMetafile;
                FPicture.mMetafile := Value;
              end;
            ipropPicMetaWithBMP:
              if FPicture.pReading then
              begin
                FPicture.MetaHasBMP := TRUE;
              end;
            ipropPicSourceDIB:
              if FPicture.pReading then
              begin
                if Value = 0 then FPicture.pType := wpreadPictDBitmap;
              end;
            ipropPicSourceWBit:
              if FPicture.pReading then
              begin
                if Value = 0 then FPicture.pType := wpreadPictWBitmap;
              end;
            ipropPicPixels:
              if FPicture.pReading then
              begin
                FPicture.bPixels := Value;
              end;
            ipropPicPlanes:
              if FPicture.pReading then
              begin
                FPicture.WPlanes := Value;
              end;
            ipropPicByteWidth:
              if FPicture.pReading then
              begin
                FPicture.WWidthBytes := Value;
              end;
            ipropPicW:
              if FPicture.pReading then
              begin
                FPicture.HasWH := true;
                FPicture.w := Value;
              end;
            ipropPicH:
              if FPicture.pReading then
              begin
                FPicture.HasWH := true;
                FPicture.h := Value; // With metafiles this is an fExt value !
              end;
            ipropPicGoalW:
              if FPicture.pReading then
              begin
                FPicture.pGoalWidth := Value;
              end;
            ipropPicGoalH:
              if FPicture.pReading then
              begin
                FPicture.pGoalHeight := Value;
              end;
            ipropPicScaleX:
              if FPicture.pReading then
              begin
                FPicture.pScaleWidth := Value;
              end;
            ipropPicScaleY:
              if FPicture.pReading then
              begin
                FPicture.pScaleHeight := Value;
              end;
            ipropPicScaledMac:
              if FPicture.pReading then
              begin
    // reserved
              end;
            ipropIsShape:
              if FPicture.pReading then
              begin
    // reserved
              end;
            ipropCropL:
              if FPicture.pReading then
              begin
                FPicture.pCropL := Value;
              end;
            ipropCropR:
              if FPicture.pReading then
              begin
                FPicture.pCropR := Value;
              end;
            ipropCropT:
              if FPicture.pReading then
              begin
                FPicture.pCropT := Value;
              end;
            ipropCropB:
              if FPicture.pReading then
              begin
                FPicture.pCropB := Value;
              end;
            ipropPicTag:
              if FPicture.pReading then
              begin
                FPicture.pTag := Value;
              end;
            ipropPicUnits:
              if FPicture.pReading then
              begin
                FPicture.pUnits := Value;
              end;
            ipropPicFloatObj:
              if FPicture.pReading then
              begin
                FPicture.wpFloatMode := Value;
              end;
            ipropPicFloatObjRelX:
              if FPicture.pReading then
              begin
                if FWrittenByWPToolsVersion < 5 then
                  FPicture.wpFloatX := Value + Layout.margl;
              end;
            ipropPicFloatObjRelY:
              if FPicture.pReading then
              begin
                FPicture.wpFloatY := Value;
              end;
            ipropPicFloatObjWrap:
              if FPicture.pReading then
              begin
                FPicture.wpWrapMode := Value;
              end;
            ipropOBJMODE:
              if FPicture.pReading then
              begin
                FPicture.wpModeMode := Value;
              end;
            ipropOBJFRAME:
              if FPicture.pReading then
              begin
                FPicture.wpFrameMode := Value;
                FShape.wpFrameMode := Value;
              end;
            ipropWPTXTOBJOpenTag:
              begin
                FWPTextObjOpenTag := Value;
                FWPTextObjCloseTag := 0;
              end;
            ipropWPTXTOBJCloseTag:
              begin
                FWPTextObjOpenTag := 0;
                FWPTextObjCloseTag := Value;
              end;
            iprop_iparam:
              begin
                FFieldIParam := Value;
              end;
      // ---------------------------------------------------------------- Shapes
            ipropshpleft: FShape.shpleft := Value;
            ipropshptop: FShape.shptop := Value;
            ipropshpright: FShape.shpright := Value;
            ipropshpbottom: FShape.shpbottom := Value;
            ipropshpfhdr: FShape.shpfhdr := Value;
            ipropshpbypage: begin FShape.shpbypage := TRUE; FShape.shpbypara := false; FShape.shpbymethod:=1; end;
            ipropshpbypara: FShape.shpbypara := TRUE;
            ipropshpwr: FShape.shpwr := Value;
            ipropshpwrk: FShape.shpwrk := Value;
            ipropshpfblwtxt: FShape.shpfblwtxt := Value;
            ipropshpbxcolumn:
              if (WrittenByWPToolsVersion < 5) or (WrittenByWPToolsVersion > 5.2) then
              begin
                FShape.shpbxmode := Value; //V5.20.1
                FShape.shpbxmethod := Value;
              end;
      // -------------------------------------------------------- Page Numbering
            ipropPgnX: { not used }
              begin
              end;
            ipropPgnY:
              begin
              end;
            ipropPgnFormat:
              begin
                case Value of
                  pgDec: begin end;
                  pgURom: begin end;
                  pgLRom: begin end;
                  pgULtr: begin end;
                  pgLLtr: begin end;
                  pgRestartNumber:
                    begin
{$IFDEF USE_wpsec_ResetPageNumber}
                      if (FCurrentParagraph <> nil) and (paprNewSection in FCurrentParagraph.prop) and (FCurrentSectionProps <> nil) then
                        FCurrentSectionProps.Select := FCurrentSectionProps.Select + [wpsec_ResetPageNumber]
                      else
{$ENDIF}
                        FRestartPageNr := TRUE;
                    end;
                end;
              end;
      // ----------------------------------------------------------- Page Format
            ipropXaPage:
              begin
                Layout.paperw := Value;
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.paperw := Value;
                end;
              end;
            ipropYaPage:
              begin
                Layout.paperh := Value;
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.paperh := Value;
                  if FLoadedLandscape and (FCurrentSectionProps._Layout.landscape) then
                  begin
                    Value := FCurrentSectionProps._Layout.paperh;
                    FCurrentSectionProps._Layout.paperh := FCurrentSectionProps._Layout.paperw;
                    FCurrentSectionProps._Layout.paperw := Value;
                  end;
                end;
              end;
            ipropXaLeft:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.margl := Value;
                end;
                Layout.margl := Value;
              end;
            ipropXaRight:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.margr := Value;
                end;
                Layout.margr := Value;
              end;
            ipropYaTop:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.margt := Value;
                end;
                Layout.margt := Value;
              end;
            ipropYaBottom:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.margb := Value;
                end;
                Layout.margb := Value;
              end;
            ipropFacingp:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.hasFacingP := (Value <> 0);
                end;
                Layout.hasFacingP := (Value <> 0);
              end;
            ipropLandscape:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.landscape := (Value <> 0);
                  if FCurrentSectionProps._Layout.landscape then
                  begin
                    Value := FCurrentSectionProps._Layout.paperh;
                    FCurrentSectionProps._Layout.paperh := FCurrentSectionProps._Layout.paperw;
                    FCurrentSectionProps._Layout.paperw := Value;
                  end;
                  FLoadedLandscape := TRUE;
                end;
              end;
            ipropDeftab:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) then
                begin
                  if not (loIgnoreDefaultTabstop in FLoadOptions) then
                    FCurrentSectionProps._Layout.deftabstop := Value;
                end;
                Layout.deftabstop := Value;
              end;
            ipropWpspecialhf:
              begin
           // wpspecialhf := TRUE; { Load first, all, last }
              end;
            ipropYaMarginHeader:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.marg_header := Value;
                end;
                Layout.marg_header := Value;
              end;
            ipropYaMarginFooter:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.marg_footer := Value;
                end;
                Layout.marg_footer := Value;
              end;
            ipropWpprheadfoot:
              begin
                // we do not always load this property since it can cause the header/footer
                // to disappear if a text which includes this property is loaded
                if not FLoadBodyOnly and (loPrintHeaderFooterParameter in LoadOptions) then
                  RTFDataCollection.PrintParameter.PrintHeaderFooter := TWPPrintHeaderFooter(value);
              end;
            ipropTitlePg:
              begin
{$IFNDEF NORTF_TITLEPG}
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.hasTitlePg := (Value <> 0);
                end;
{$ENDIF}
              end;
            ipropMarginMirror:
              begin
                if not OptNoPageInfo and not FLoadBodyOnly and (FCurrentSectionProps <> nil) and not (loIgnorePageSize in FLoadOptions) then
                begin
                  FCurrentSectionProps._Layout.marginmirror := (Value <> 0);
                end;
              end;
 
  // ---------------------------------------------------------------------------
            ipropPgnStart: //Beginning page number (the default is 1).
              begin
                if not OptNoPageInfo and not FLoadBodyOnly then
                  RTFDataCollection.PageStartNumber := Value;
              end;
            ipropNewPageB: // \pagebb "Break page before the paragraph"
              begin
{$IFDEF READ_NEWPAGE}
                if FCurrentParagraph <> nil then
                begin
                  if FCurrentParagraph.ParagraphType = wpIsTable then //V5.20.9
                    CreateImplizitPar;
                  FCurrentParagraph.IsNewPage := TRUE;
                end;
{$ENDIF}
              end;

            ipropNewPage:
              if not OptNoPageBreaks then
              begin
             { if FInTBL then
              begin
                 // Ignore \page iside of tables
              end else }
                if FIgnoreNext_Par then
                  FNeedNewPageNextTime := TRUE
                else
                begin
                  if (FCurrentParagraph = nil) or (FCurrentParagraph.CharCount > 0) then
                    goto MakeNewPage;
                  Par := FCurrentParagraph.ParentParentRow;
                  if Par <> nil then
                    include(Par.prop, paprNewPage) //ok, row
                  else
                    FStartNewPageNextCreatePar := TRUE; // V5.11.2
                // include(FCurrentParagraph.prop, paprNewPage);
                end;
              end;

{$IFDEF xxxREAD_NEWPAGE}ipropNewPage, {$ENDIF}
            ipropNewPar:
              begin
                if FIgnoreNext_Par then
                begin
                  FIgnoreNext_Par := FALSE;
                end else
                  if not (FStack.Destination in [rdsSkip, rdsSkipText, rdsShprslt, rdsNestRowProps]) then
                  begin
                    MakeNewPage:
                    if FCurrentParagraph <> nil then
                    begin
                      if (FCurrentParagraph.ParagraphType = wpIsTable) and
                        not FInTBL and //V5.18.10
                        ((TableDepth = 0) or //V5.18.7 - missing par between tables
                        (TableDepth = FCurrentParagraph.TableDepth - 1))
                        then
                      begin
                     //V5.15.5 Append after new paragraph THIS table!
                        NewParagraph(4);
                    // End nested table
                        TableVar[TableDepth + 1].FInsideCell := FALSE;
                        TableVar[TableDepth + 1].FInsideTable := FALSE;
                        TableVar[TableDepth + 1].FInsideRow := FALSE;
                    // End this table - V5.18.8
                        TableVar[TableDepth].FInsideCell := FALSE;
                        TableVar[TableDepth].FInsideTable := FALSE;
                        TableVar[TableDepth].FInsideRow := FALSE;

                        FLastWasSTDPar := false; // "true" would create empty pars before tables!
                      end else
                      begin
{$IFDEF FIXUP_CHARSTYLES}
                        if FHasCharStyles then Attr.RemoveRedundantProps;
{$ENDIF}
                        FCurrentParagraph.LoadedCharAttr := Attr.CharAttr;
                        CreateImplizitPar;
                      end;
                    end
                    else
                    begin
                      CreateImplizitPar;
                      if (ipropCode = ipropNewPage) and (FCurrentParagraph.prev = nil) then //V5.18.10
                      begin
                        NewParagraph(); // We need another one
                        FLastWasSTDPar := TRUE;
                      end;
                    end;

            // Used for WPReporter
                    if FIsMergePar > 0 then
                    begin
                      if FIsMergePar = 1 then
                        include(FCurrentParagraph.prop, paprIsMergeCommandStart)
                      else include(FCurrentParagraph.prop, paprIsMergeCommandEnd);
                      FCurrentParagraph.ASet(WPAT_BANDPAR_STR,
                        FCurrentParagraph.AStringToNumber(FCurrentMergePar));
{$IFDEF GROUPVAR} 
                      FCurrentParagraph.ASet(WPAT_BANDPAR_VAR,
                        FCurrentParagraph.AStringToNumber(FCurrentMergeVar));
                      FCurrentMergeVar := '';
{$ENDIF} 
                      i := Pos(';', FCurrentMergePar);
                      if i > 0 then
                        i := StrToIntDef(Copy(FCurrentMergePar, 1, i - 1), -1);
                      case i of
                        0: begin FCurrentParagraph.ParagraphType := wpIsReportGroup;
                            FHasReportGroups := TRUE;
                          end;
                        1: FCurrentParagraph.ParagraphType := wpIsReportDataBand;
                        2: FCurrentParagraph.ParagraphType := wpIsReportDataBand;
                        3: FCurrentParagraph.ParagraphType := wpIsReportHeaderBand;
                        4: FCurrentParagraph.ParagraphType := wpIsReportFooterBand;
                      end;

                  // V5.18.8 - make sure a band splits the table ---------------
                      if InTStack then
                      begin
                        TStack.FInsideTable := FALSE;
                        TStack.FTableParent := nil; //V5.18.8
                      end;

                      FIsMergePar := 0;
                      FCurrentParagraph._DefaultHeight := 10;
                    end;

          // New Pages only work in the outer rows
{$IFDEF READ_NEWPAGE}
                    if (ipropCode = ipropNewPage) or (ipropCode = ipropNewSection) then
                    begin
                      Par := FCurrentParagraph.ParentParentRow;
                      if Par <> nil then
                        include(Par.prop, paprNewPage) //ok, row
                      else
                      begin
                        if FCurrentParagraph.CharCount > 0 then //V5.11
                        begin
                          CheckNewParagraph;
                          par := FCurrentParagraph;
                        end;
                        include(FCurrentParagraph.prop, paprNewPage);
                      end
                    end else
                    begin
                      Par := nil;
                      FInTBL := FALSE; // itap only good for 1 \par (security!)
                    end;
{$ELSE}
                    Par := nil;
{$ENDIF}
                    if not FLastWasSTDPar and (Par = nil) then //V5.18.9
                    begin
                      FStack.AMerge(FCurrentParagraph, true);
                      CheckNewParagraph;
                    end;

                    if (ipropCode = ipropNewPage) then // comes from "goto" !
                      FLastWasSTDPar := TRUE;
                  end;
              end;
            // Create new section properties
            ipropNewSection:
              if not OptIngoreSections then
              begin
                FIsNewSection := TRUE;
                FSectionBreakMode := 0;
                FPrevSectionId := RTFDataCollection.LastSectionID;
                FNewSectionID := RTFDataCollection.LastSectionID + 1;
                RTFDataCollection.LastSectionID := FNewSectionID;
                FCurrentSectionProps := RTFDataCollection.GetSectionProps(FNewSectionID);
                FCurrentSectionProps.Select := [wpsec_PageSize, wpsec_Margins, wpsec_TabDefault, wpsec_PageMirror];
                FLoadedLandscape := FALSE;
                FStack.FHasDefaultSectionBreak := TRUE; //V5.24.1
              end;
            ipropSectionBreakMode:
              if not OptIngoreSections then
              begin
                FStack.FHasDefaultSectionBreak := FALSE; //V5.24.1
                FSectionBreakMode := Value;
                if FIsNewSection and
                  (FSectionBreakMode < 3) and //V5.20.7
                  (FCurrentParagraph <> nil) and
                  (FCurrentParagraph.CharCount > 0) then
                begin
                  NewParagraph;
                  CreateImplizitPar;
                end;
              end;
   // --------------------------------------------------------------------------
            ipropRtlLtrPar:
              begin
                FStack.Props.IsRTLPar := (Value <> 0);
              end;
            ipropwpshppos:
              begin
                FShape.WPPosmode := Value;
              end;
  // --------------------------------------------------------------------------

            ipropSelSectionHdr:
              begin
                if FCurrentSectionProps <> nil then
                begin
                  if (Value and 1) <> 0 then
                    FCurrentSectionProps.Select :=
                      FCurrentSectionProps.Select + [wpsec_SelectHeaderFooter];
                end;
              end;
            ipropSelResetOutl:
              begin
                if FCurrentSectionProps <> nil then
                begin
                  if (Value and 1) <> 0 then
                    FCurrentSectionProps.Select :=
                      FCurrentSectionProps.Select + [wpsec_ResetOutlineNums];
                end;
              end;
            ipropPicFloatObjRelXNew:
              if FPicture.pReading then
              begin
                FPicture.wpFloatX := Value; // NO!! + Layout.margl;
              end;
            ipropwpignpar:
              begin
                FIgnoreNext_Par := TRUE;
              end;
            ipropwppage:
              begin
                FNeedNewPageNextTime := TRUE;
              end;
            iprop_frameparam:
              begin
                FFieldFrameParam := Value;
                FShape.wpFrameMode := Value;
              end;
            iprop_modeparam:
              begin
                FFieldModeParam := Value;
              end;
            iprop_frameextra:
              begin
                FShape.wpExtra := FShape.wpExtra or Value;
              end;
 
  // --------------------------------------------------------------------------
          end
        else if ipropCode < ipropGroupEnd3 then // GROUP 3
          case ipropCode of
            ipropS:
              begin
                if FStack.Destination = rdsStyleSheet then
                begin
                  if FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles) then
                  begin
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FNum := Value;
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FKind := wpIsParStyle;
                  end;
                end else
                begin
                  if Value = 0 then i := 0
                  else i := FStyleSheet.Get(Value);
                  FStack.ParNrStyle := i;
                  FStack.ASetBaseStyle(i);
                  if FCurrentParagraph <> nil then
                  begin
                    FCurrentParagraph.ASetBaseStyle(i);
{$IFDEF USEAddDefaultParProps}if FStack.ParNrStyle > 0 then AddDefaultParProps(FCurrentParagraph); {$ENDIF}
                  end;
                  if Value <> 0 then FHasParStyle := TRUE;
                end;
              end;
            ipropCS:
              begin
                if FStack.Destination = rdsStyleSheet then
                begin
                  if FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles) then
                  begin
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FNum := Value;
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FKind := wpIsCharStyle;
                  end;
                end
{$IFNDEF NEVER_CHARSTYLES}
                else
                  if not OptNoCharStyles and not (loNoCharStyles in FLoadOptions) then
                  begin
                    Attr.SetCharStyleSheet(FStyleSheet.Get(Value));
{$IFDEF FIXUP_CHARSTYLES}FHasCharStyles := TRUE; {$ENDIF}
                  end
{$ENDIF}
                    ;
              end;
            ipropTS: begin end;
            ipropDS: begin end;
            ipropFN: begin end;
            ipropadditive:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASetAdd(WPAT_STYLE_FLAGS, WPSTYLE_ADDITIVE);
                end;
              end;
            ipropsbasedOn:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                  {  FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASetBaseStyle(
                        FStyleSheet.Get(Value)); - maybe not yet defined!  }
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FBasedOn := Value;
                end;
              end;
            ipropsnext:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                  {  FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASet(
                       WPAT_STYLE_NEXT, FStyleSheet.Get(Value)); - maybe not yet defined! }
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FNext := Value;
                end;
              end;
            ipropshidden:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASetAdd(WPAT_STYLE_FLAGS, WPSTYLE_HIDDEN);
                end;
              end;
            ipropstyleid:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  FStyleSheet.FStyles[FStyleSheet.FStyleCount].FID := Value;
                end;
              end;
            ipropautoupd:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASetAdd(WPAT_STYLE_FLAGS, WPSTYLE_AUTOUPDATE);
                end;
              end;
            ipropssemihidden:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FStyle.ASetAdd(WPAT_STYLE_FLAGS, WPSTYLE_SEMIHIDDEN);
                end;
              end;
  // ---------------------------------------------------------------------------
            ipropListID:
              begin
                if FStack.Destination = rdsList then
                begin
                  FCurrentList.FListID := Value;
                end else
                  if FStack.Destination = rdsListOverride then
                  begin
                    if FListOverrideCount < Length(FListOverrides) then
                    begin
                      for i := 0 to FListsDefs.Count - 1 do
                      begin
                        if TWPRTFReadList(FListsDefs[i]).FListID = Value then
                        begin
                          FListOverrides[FListOverrideCount].List :=
                            TWPRTFReadList(FListsDefs[i]);

                          inc(TWPRTFReadList(FListsDefs[i]).FMappingNumber); //V5.21
                          FListOverrides[FListOverrideCount].DefaultLevel :=
                            TWPRTFReadList(FListsDefs[i]).FMappingNumber; //V5.21

                        end;
                      end;
                    end;
                  end;
              end;
            ipropOutlineLevel: begin end;
            ipropListTemplateID: begin end;
            ipropListSimple: begin end;
            ipropListRestartSection:
              begin
                if FStack.Destination = rdsList then
                begin
                  FCurrentList.FRestartSection := Value > 0;
                end;
              end;
            ipropListStyleID: begin end;
  // ---------------------------------------------------------------------------
            ipropLevelStartAt:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                begin
                  FCurrentList.CurrentStyle.ASet(WPAT_Number_STARTAT, Value);
                end;
              end;
            ipropLevelnfc: // NumberMode -1
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                begin
                  FCurrentList.CurrentStyle.ASet(WPAT_NumberMODE, Value + 1);
                end;
              end;
            ipropLeveljc:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                begin
                  FCurrentList.CurrentStyle.ASet(WPAT_Number_ALIGN, Value);
                end;
              end;
            ipropLevelOld:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) and (Value > 0) then
                  FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_COMPAT);
              end;
            ipropLevelprev_O:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) and (Value > 0) then
                  FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_USEPREV);

              end;
            ipropLevelprevSpace_O:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) and (Value > 0) then
                  FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_USEINDENT);
              end;
            ipropLevelindent_O:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                  FCurrentList.CurrentStyle.ASet(WPAT_NumberINDENT, Value); // V5.11.1 was ASetAdd
              end;
            ipropLevelspace_O:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                  FCurrentList.CurrentStyle.ASet(WPAT_Number_SPACE, Value); // V5.11.1 was ASetAdd
              end;
            ipropLevelFollow:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) then
                begin
       // if Value=0 then      FReadingStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_FOLLOW_TAB)
                  if Value = 1 then FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_FOLLOW_SPACE)
                  else if Value = 2 then FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_FOLLOW_NOTHING);
                end;
              end;
            ipropLevelLegal:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) and (Value > 0) then
                  FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_LEGAL);
              end;
            ipropLevelNoRestart:
              begin
                if (FStack.Destination = rdsListLevel) and (FCurrentList.CurrentStyle <> nil) and (Value > 0) then
                  FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberFLAGS, WPNUM_FLAGS_NORESTART);
              end;
            ipropLevelPicture:
              begin
   { if (FStack.Destination=rdsListLevel) and (FCurrentList.CurrentStyle<>nil) then
       FCurrentList.CurrentStyle.ASetAdd(WPAT_NumberPICTURE, Value); }
              end;
 // ---------------------------------------------------------------------------
            ipropListOverrideCount: begin end;
 // ---------------------------------------------------------------------------
            ipropListNr: // We select the first style in a list - even if we have to use WPAT_NumberLEVEL later!
              begin
                if (FStack.Destination = rdsListOverride) then
                begin

                end else
                begin
{$IFNDEF IGNORELIST}
                  if Value = 0 then
                  begin
                    if FReadingStyle <> nil then
                      FReadingStyle.ADel(WPAT_NumberSTYLE)
                    else
                    begin
                      if FCurrentParagraph <> nil then
                        FCurrentParagraph.ADel(WPAT_NumberSTYLE);
                      FStack.ADel(WPAT_NumberSTYLE);
                    end;
                  end else
                    if (Value > 0) and (Value <= Length(FListOverrides)) and (FListOverrides[Value].List <> nil) then
                    begin
                      if FReadingStyle <> nil then
                        FReadingStyle.ASet(WPAT_NumberSTYLE, FListOverrides[Value].List.Get(1))
                      else
                      begin
                        CreateImplizitPar;
                        if FCurrentParagraph <> nil then
                        begin
                          FCurrentParagraph.ASet(WPAT_NumberSTYLE, FListOverrides[Value].List.Get(1));
                          if not FPNGroup.Reading then FCurrentParagraph.ADel(WPAT_NumberFLAGS);
                        end;
                        FStack.ASet(WPAT_NumberSTYLE, FListOverrides[Value].List.Get(1));
{$IFDEF LOADLS_WITHOUT_ilvl}
                        if FListOverrides[Value].DefaultLevel in [1..9] then
                        begin
                          if FCurrentParagraph <> nil then
                            FCurrentParagraph.ASet(WPAT_NumberLevel, FListOverrides[Value].DefaultLevel);
                          FStack.ASet(WPAT_NumberLevel, FListOverrides[Value].DefaultLevel);
                        end;
{$ENDIF}
                      end;
                      FCurrentListNr := Value;
                    end;
{$ENDIF}
                end;
              end;
            ipropListLevel: // 0 based!
            //  if Value>0 then  //V5.20.7a
              begin
            //    dec(Value); //V5.20.7a
{$IFNDEF IGNORELIST}
                if FReadingStyle <> nil then
                  FReadingStyle.ASet(WPAT_NumberLEVEL, Value + 1)
                else
                begin
                  if FCurrentParagraph <> nil then
                    FCurrentParagraph.ASet(WPAT_NumberLEVEL, Value + 1);
                  FStack.ASet(WPAT_NumberLEVEL, Value + 1);
                end;
{$ENDIF}
              end;
            ipropPNLevel:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FPNGroup.Reading then
                begin
                  if Value in [1..9] then
                    FPNGroup.LEVEL := Value;
                end
                else
            {if Value in [1..9] then
                 i := FOldListTableUseAs[Value]
            else i := 0;

            if Value=10 then  // Number Style
            begin
              Value := 0;  // Level = 0
            end else
            if Value=11 then  // Bullet STyle
            begin
              Value := 0;  // Level = 0
            end else    }
                begin

                  if Value in [1..9] then
                    i := FOldListTableUseAs[Value]
                  else i := 0;

                  if FReadingStyle <> nil then
                  begin
                    FReadingStyle.ASet(WPAT_NumberSTYLE, i);
                    FReadingStyle.ASet(WPAT_NumberLEVEL, Value);
                  end
                  else
                  begin
                    if FCurrentParagraph <> nil then
                    begin
                      FCurrentParagraph.ASet(WPAT_NumberSTYLE, i);
                      FCurrentParagraph.ASet(WPAT_NumberLEVEL, Value);
                      FCurrentParagraph.ADel(WPAT_NumberFLAGS);
                    end;
                    FStack.ASet(WPAT_NumberSTYLE, i);
                    FStack.ASet(WPAT_NumberLEVEL, Value);
                  end;
                end;
              end;
            ipropPNStyle:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FPNGroup.Reading then
                  FPNGroup.MODE := Value
                else
                  if FReadingStyle <> nil then
                    FReadingStyle.ASet(WPAT_NumberMODE, Value)
                  else
                  begin
                    if FCurrentParagraph <> nil then
                    begin
                      FCurrentParagraph.ASet(WPAT_NumberMODE, Value);
                    end;
                    FStack.ASet(WPAT_NumberMODE, Value);
                  end;
              end;
            ipropPNIndent:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FPNGroup.Reading then
                  FPNGroup.INDENT := Value
                else
                  if FReadingStyle <> nil then
                    FReadingStyle.ASet(WPAT_NumberINDENT, Value)
                  else
                  begin if FCurrentParagraph <> nil then
                      FCurrentParagraph.ASet(WPAT_NumberINDENT, Value);
                    FStack.ASet(WPAT_NumberINDENT, Value);
                  end;
              end;
            ipropPNFont:
              if not (loIgnoreNumberDefs in LoadOptions) and (Value >= 0) and (Value < MAXFONTTBL) then
              begin
                if FPNGroup.Reading then
                  FPNGroup.FONT := Value
                else
                  if FReadingStyle <> nil then
                    FReadingStyle.ASet(WPAT_NumberFONT, FFontTbl.Fontnr[Value])
                  else
                  begin if FCurrentParagraph <> nil then
                      FCurrentParagraph.ASet(WPAT_NumberFONT, FFontTbl.Fontnr[Value]);
                    FStack.ASet(WPAT_NumberFONT, FFontTbl.Fontnr[Value]);
                  end;
                FCurrentCodePage := FFontTbl.FontCodePage[Value];
                FStack.FCurrentCodePage := FCurrentCodePage;
              end;
            ipropPNFontSize:
            //  if WPToolsVersionInt<>4 then
{$IFNDEF RTF_SECURITY_CHECK}
              if Value <= 500 then // It sometimes happens that here values are far too large. Ignore!
{$ENDIF}
                if not (loIgnoreNumberDefs in LoadOptions) then
                begin
                  if FPNGroup.Reading then
                    FPNGroup.FONTSIZE := Value div 2 //NO!!!! * 50
                  else
                    if FReadingStyle <> nil then
                      FReadingStyle.ASet(WPAT_NumberFONTSIZE, Value * 50)
                    else
                    begin
                      if FCurrentParagraph <> nil then
                        FCurrentParagraph.ASet(WPAT_NumberFONTSIZE, Value * 50);
                      FStack.ASet(WPAT_NumberFONTSIZE, Value * 50);
                    end
                end;
            ipropPNFlag:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FPNGroup.Reading then
                  FPNGroup.FLAGS := FPNGroup.FLAGS or Value
                else
                  if FReadingStyle <> nil then
                    FReadingStyle.ASetAdd(WPAT_NumberFLAGS, Value)
                  else
                  begin
                    CreateImplizitPar;
                    if FCurrentParagraph <> nil then
                      FCurrentParagraph.ASetAdd(WPAT_NumberFLAGS, Value);
                    FStack.ASetAdd(WPAT_NumberFLAGS, Value);
                  end;
              end;
            ipropPNStart:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FPNGroup.Reading then
                  FPNGroup.STARTAT := Value
                else
                  if FReadingStyle <> nil then
                    FReadingStyle.ASet(WPAT_Number_STARTAT, Value)
                  else
                  begin
                    FStartParWithNumber := Value;
                  end;
              end;
            ipropPNParFlag:
              if not (loIgnoreNumberDefs in LoadOptions) then
              begin
                if FReadingStyle <> nil then
                  FReadingStyle.ASetAdd(WPAT_NumberFLAGS, Value)
                else
                begin
                  CreateImplizitPar;
                  if FCurrentParagraph <> nil then
                    FCurrentParagraph.ASetAdd(WPAT_NumberFLAGS, Value);
                // FStack.ASetAdd(WPAT_NumberFLAGS, Value);
                end;
              end;
 // ---------------------------------------------------------------------------
            ipropInfoItemType:
              begin
                FInfoItemType := Value;
              end;
            ipropUNIAnsiCodePage: OptCodePage := Value;
            ipropUNICharCount: FUNICharCount := Value;
            ipropReadUnicodeChar: // \u
              begin
          // Hardcoded for improved perfomance
              end;
            ipropDefaultFont: FDefaultFontNrDEFF := Value;
            ipropFFMaxLength: FCurrFieldMaxLen := Value;
            ipropFieldEdit: begin end;

            ipropInsertPoint {= 50}: begin end; { \inspnt  , not a RTF	code	}
            ipropAutomatic {= 51}: begin end; { \inaut, not	a RTF code }

            ipropobjtag {= 66}: begin end;
            ipropobjwidth {= 67}: begin end;
            ipropobjheight {= 68}: begin end;
            iproprtfcode {= 69}: begin end;
            ipropwpfnnr {= 70}: begin end;
            ipropBookmark {= 83}: begin end;
            ipropwbmpfile {= 84}: begin end;
            ipropWPNR {= 88}: begin end;
            ipropWPNRstyle {= 89}: begin end;

            ipropWPTableLeft {= 109}: begin end;
            ipropWPTableRight: begin end;

            ipropFloatObjWrap {= 115}: begin end;

            // Reserved :
            562, 563, 564, 565, 566: begin end;

            ipropReadBinaryData: begin end;

            ipropToclevel:
              begin
                if FReadingStyle <> nil then
                  FReadingStyle.ASet(WPAT_ParIsOutline, Value)
                else if Value = 0 then
                begin
                  if FCurrentParagraph <> nil then
                    FCurrentParagraph.ADel(WPAT_ParIsOutline);
                end else
                begin
                  if (FCurrentParagraph <> nil) and (FCurrentParagraph.ParagraphType = wpIsSTDPar) then
                    FCurrentParagraph.ASet(WPAT_ParIsOutline, Value)
                  else FNextParIsOutline := Value;
                end;
              end;
            ipropexpndtw:
              begin
                Attr.SetCharSpacing(Value); // charscalex ?
              end;
            ipropXlevel {= 143}: begin end;
            ipropSpecialCharacters:
              begin
               // chdate Current date (as in headers).
                if Value = 1 then PrintTextObj(wpobjTextObject, 'DATE', '', false, false, false)
                // chdpl Current date in long format (for example, Thursday, October 28, 1993).
                else if Value = 2 then PrintTextObj(wpobjTextObject, 'DATE', '', false, false, false)
                // chdpa Current date in abbreviated format (for example, Thu, Oct 28, 1993).
                else if Value = 3 then PrintTextObj(wpobjTextObject, 'DATE', '', false, false, false)
                // chtime Current time (as in headers).
                else if Value = 4 then PrintTextObj(wpobjTextObject, 'TIME', '', false, false, false)
                // chpgn  Current page number (as in headers).
                else if Value = 5 then PrintTextObj(wpobjTextObject, 'PAGE', '', false, false, false);
              end;
            ipropHyphen: FLastWasHyphen := TRUE;
            ipropOutlinebreak {= 162}: begin end;
            ipropUpperCase:
              begin
                if FReadingStyle <> nil then
                  FReadingStyle.ASetCharStyle(Value > 0, WPSTY_UPPERCASE)
                else
                  if Value = 0 then
                    Attr.ExcludeStyle(afsUppercaseStyle)
                  else Attr.IncludeStyle(afsUppercaseStyle);
              end;
            ipropSelectedPar {= 167}: begin end;
            ipropWPColSpan {= 168}: begin end;
            ipropWPColFormat {= 169}: begin end;

            ipropHorzLineOffSets: FHorzLineOffsets := Value;
            ipropHorzLineColor: FHorzLineColor := Value;
            ipropHorzLineWidth: FHorzLineWidth := Value;
            ipropHorzLine, // (WPTools 4 style!) val = Height in pt
              ipropHorzLineTW: // val = Height in TWIPS
              begin
                if ipropCode = ipropHorzLine then
                  Value := Value * 20;
                CreateImplizitPar;
                with PrintTextObj(wpobjHorizontalLine, '', '', false, false, false) do
                begin
                  Height := Value;
                  Width := FHorzLineWidth;
                  IParam := FHorzLineColor;
                  CParam := FHorzLineOffsets;
                end;
                FHorzLineColor := 0;
                FHorzLineWidth := 0;
                FHorzLineOffsets := 0;
              end;
            ipropLowercase:
              begin
                if FReadingStyle <> nil then
                  FReadingStyle.ASetCharStyle(Value > 0, WPSTY_LOWERCASE)
                else
                  if Value = 0 then
                    Attr.ExcludeStyle(afsLowercaseStyle)
                  else Attr.IncludeStyle(afsLowercaseStyle);
              end;
            ipropSmallCaps:
              begin
                if FReadingStyle <> nil then
                  FReadingStyle.ASetCharStyle(Value > 0, WPSTY_SMALLCAPS)
                else
                  if Value = 0 then
                    Attr.ExcludeStyle(afsSmallCaps)
                  else Attr.IncludeStyle(afsSmallCaps);
              end;
            ipropsIsDefault:
              begin
                if (FStack.Destination = rdsStyleSheet) and
                  (FStyleSheet.FStyleCount < Length(FStyleSheet.FStyles)) then
                begin
                  if Value > 0 then
                    FStyleSheet.FStyles[FStyleSheet.FStyleCount].FIsDefault := TRUE;
                end;
              end;
            ipropswptoolsver: // only used by WPTools V4.22a and 4.25
              begin
               // We have a positive that this file was saved with Version 4
                if Value = 4 then FWrittenByWPToolsVersion := 4.0;
              end;
          end;
    end else
    begin
      // Unknown Code !!!
    end;

  except

  end;
end;

procedure TWPRTFReader.LoadIntoRTFDataBlock(rtfdataobj: TWPRTFDataBlock);
begin
  if rtfdataobj <> nil then
  begin
    FStack.RestoreRTFData := FRTFData;
    FStack.FCurrentColumnCount := FCurrentColumnCount;
    FStack.FColumnCount := FColumnCount;
    FStack.FColumn_X := FColumn_X;
    FStack.FColumn_Y := FColumn_Y;
    FCurrentColumnCount := 0;
    FColumnCount := 0;
    FColumn_X := 0;
    FColumn_Y := 0;
    FStack.FNeedNewPageNextTime := FNeedNewPageNextTime;
    FStack.FNeedNewPageNextTime := FNeedNewPageNextTime;
    FNeedNewPageNextTime := FALSE;
    FStack.RestoreCurrentPar := FCurrentParagraph;
    FStack.Props.InTable := FALSE;
    FStack.RestoreTableDepth := FTableDepth;
    FStack.RestoreTableVar := FTableVar;
    FTableVar := nil;
    FTableDepth := 0;
    FRTFData := rtfdataobj;
    FInSpecialText := TRUE;
    FRTFData.UsedForSectionID := FNewSectionID;
    FCurrentCodePage := WPGetCodePage(OptCodePage); // Default!
    FStack.FCurrentCodePage := FCurrentCodePage;
    FCurrentParagraph := FRTFData.FirstPar;
    FStack.Clear; // start with empty definition
    if rtfdataobj.Kind in [wpIsHeader, wpIsFooter] then
      FLoadInHeaderFooter := true;
  end;
  FStack.Destination := rdsNorm;
end;

function TWPRTFReader.RowReading: Boolean;
begin
  Result := true; // FStack.Props.InTable;
end;

procedure TWPRTFReader.LoadLinkedImage(txtobj: TWPTextObj; fname, params: string);
  function LoadValue(n: string; var value: Integer): Boolean;
  var i: Integer;
  begin
    value := 0;
    i := Pos(n, params);
    if i > 0 then
    begin
      inc(i, Length(n));
      while (i <= Length(params)) and
            (params[i]>='0') and (params[i]<='9') do
      begin
        value := value * 10 + Integer(params[i]) - Integer('0');
        inc(i);
      end;
      Result := TRUE;
    end else Result := FALSE;
  end;
var i, l: Integer;
  value: Integer;
  bs: Boolean;
begin
   // Remove duplicated '\\' signs from fname
  l := 0;
  bs := FALSE;
  for i := 1 to Length(fname) do
  begin
    if fname[i] = '\' then
    begin
      if not bs then
      begin
        inc(l);
        bs := TRUE;
      end;
    end else
    begin
      bs := FALSE;
      inc(l);
    end;
    fname[l] := fname[i];
  end;
  SetLength(fname, l);

  // Set the source
  txtobj.Source := fname;

  // Find the WPTOOLS width and height parameters
  if LoadValue('\w', value) then txtobj.Width := Value;
  {i := Pos('\w', params);
  if i > 0 then
  begin
    inc(i, 2);
    siz := 0;
    while (i <= Length(params)) and
      (params[i] in ['0'..'9']) do
    begin
      siz := siz * 10 + Integer(params[i]) - Integer('0');
      inc(i);
    end;
    txtobj.Width := siz;
  end; }

  if LoadValue('\h', value) then txtobj.Height := Value;
 { i := Pos('\h', params);
  if i > 0 then
  begin
    inc(i, 2);
    siz := 0;
    while (i <= Length(params)) and
      (params[i] in ['0'..'9']) do
    begin
      siz := siz * 10 + Integer(params[i]) - Integer('0');
      inc(i);
    end;
    txtobj.Height := siz;
  end; }

  if LoadValue('\pm', value) and (value in [1, 2]) then //V5.18.8
  begin
    txtobj.PositionMode := TTextObjType(value);
    if LoadValue('\px', value) then txtobj.RelX := Value;
    if LoadValue('\py', value) then txtobj.RelY := Value;
    if LoadValue('\pw', value) and (Value > 0)
      and (Value < Integer(High(TTextObjWrap))) then
      txtobj.Wrap := TTextObjWrap(Value);
  end;

  // Load the image from file or DB
  RTFDataCollection.RequestHTTPImage(Self, FLoadPath, fname, txtobj);

  // Maybe this was sucessful ?
  if txtobj.ObjRef <> nil then
  begin
    if txtobj.Width = 0 then
      txtobj.Width := txtobj.ObjRef.ContentsWidth;
    if txtobj.Height = 0 then
      txtobj.Height := txtobj.ObjRef.ContentsHeight;
    txtobj.ObjRef.StreamName := fname;
  end;
end;

procedure TWPRTFReader.ChangeDestination(idestCode, Value: Integer);
var
  ftype: string;
  txtobj: TWPTextObj;
  fname: string;
  i: Integer;
  aKind: TWPPagePropertyKind;
  rtfdataobj: TWPRTFDataBlock;

begin
  if FStack.AllIgnore then //V5.17.3 Load Header or Footer when only body is wanted
  begin
    FStack.Destination := rdsSkip;
  end else
    case idestCode of
      idestNormal: begin FStack.Destination := rdsSkip; end;
      idestSkip: begin FStack.Destination := rdsSkip; end;
      idestPicture:
        if not (FStack.Destination in [rdsShprslt, rdsSkip]) then
        begin
          if FStack.FIgnoreNextImg or (loIgnoreGraphics in LoadOptions) then
            FStack.Destination := rdsSkip
          else
          begin
            FPicture.Clear;
            FPicture.pReading := TRUE;
            FStack.Destination := rdsPicture;
            //V5.36
            FPictureSource := '';
            FPictureName := '';
          end;
        end;
      idestPicIgnorePic:
        begin
{$IFDEF IGNOREALL_nonshppict}
          FStack.FIgnoreNextImg := TRUE;
          FStack.Destination := rdsSkip;
{$ELSE}
          if FLastPictWasUnknown then
          begin
            FLastPictWasUnknown := FALSE;
            FStack.Destination := rdsNorm;
          end else
            FStack.Destination := rdsSkip;
{$ENDIF}
        end;
      idestPicWPTools:
        begin
          if loIgnoreWPToolsObjects in LoadOptions then
            FStack.Destination := rdsSkip
          else
          begin
            FPicture.Clear;
            FPicture.pReading := TRUE;
            FPicture.pData.Capacity := 200000;
            FPicture.pType := wpreadWPTools;
            FStack.Destination := rdsPicture;
            FPictureSource := '';
            FPictureName := '';
          end;
        end;
      idestPicSTD:
        begin
          FStack.Destination := rdsNorm;
          FLastPictWasUnknown := FALSE;
          InitShape; //V5.30.5
          FShape.shpbypara := false;
          FShape.shpbychar := TRUE;
        end;
      idestPicProps:
        begin FStack.Destination := rdsSkip;
        end;
      idestPicUID:
        begin FStack.Destination := rdsSkip;
        end;
      idestField:
        begin
          if FStack.Props.InField and (Value = 2) then
            FStack.LastStringBuilder.FFieldType := wpNewFormField
          else
          begin
            FCurrFieldName := '';
            FStack.Destination := rdsField;
            FCurrentString.Clear;
            if FStack.FFieldINST = nil then
              FStack.FFieldINST := TWPStringBuilderReadRTF.Create(300, OptCodePage)
            else
            begin
              Assert(false, 'Fields are nested on same level');
              FStack.FFieldINST.Clear(OptCodePage); // Should not happen !
            end;
            if Value = 2 then
              FStack.FFieldINST.FFieldType := wpNewFormField
            else FStack.FFieldINST.FFieldType := wpNewField;
            FStack.FFieldINST.Tag := 0;
            FStack.Props.InField := TRUE;
          end;
        end;
      idest_________res:
        begin
        // reserved
        end;
      idestFldInstructions:
        begin
          if (FStack.Destination = rdsField) and (FStack.LastStringBuilder <> nil) then
          begin
            FStack.Destination := rdsFieldStringBuilder;
            FStringBuilder := FStack.LastStringBuilder;
            FStack.FFieldINSTAssigned := TRUE;
           // Fields can be nested inside the
           // FldResult - but at that time the FieldINST must already be defined !
          end else FStack.Destination := rdsSkip;
        end;
      idestFldParams:
        begin
          if FStack.Destination = rdsField then
          begin
            FStack.Destination := rdsFieldParams;
            FCurrentString.Clear;
          end else FStack.Destination := rdsSkip;
        end;
      idestParName:
        begin
          FStack.Destination := rdsParName;
          FCurrentString.Clear;
          FIsTableName := FALSE;
        end;
      idestWPTableName:
        begin
          FStack.Destination := rdsParName;
          FCurrentString.Clear;
          FIsTableName := TRUE;
          FTableName := '';
        end;
      idestCellName:
        begin
          FStack.Destination := rdsCellName;
          FCurrentString.Clear;
        end;
      idestCellCommand:
        begin
          FStack.Destination := rdsCellCommand;
          FCurrentString.Clear;
        end;
      idestFldResult:
        begin
          FWaitForInsertPoint := FALSE; 
          if FStack.Destination = rdsField then
          begin
          // Check FFieldINST to change the way it works ...
            if FStack.LastStringBuilder <> nil then
            begin
              ftype := Uppercase(FStack.LastStringBuilder.GetFirstWord);
             // ++++++++++++++ SINGULAR FIELDS +++++++++++++++++++++++++++++++++
              if (ftype = 'PAGE') or
                (ftype = 'NEXTPAGE') or
                (ftype = 'PRIORPAGE') or
                (ftype = 'PARNUM') or
                (ftype = 'NUMPAGES') or
                (ftype = 'DATE') or
                (ftype = 'TIME') or
                (ftype = 'SYMBOL')
                then
              begin
                FStack.Destination := rdsAnyString;
                // ... See CloseDestination
              end
              else if ftype = 'PAGEREF' then // wpobjReference
              begin
                FStack.Destination := rdsAnyString;
                FCurrentString.Clear;
              end
              else // ++++++++++ OPEN/CLOSE FIELDS ++++++++++++++++++++++++++++++
              begin
                if ftype = 'HYPERLINK' then
                begin
                  CreateImplizitPar;
                  fname := FStack.LastStringBuilder.GetSecondParam;
                  if (Length(fname) = 2) and (fname[1] = '\') then
                  begin
                    i := 1000 + Integer(fname[2]);
                    fname := FStack.LastStringBuilder.GetSecondParam;
                  end
                  else i := 0;
                  txtobj := PrintTextObj(wpobjHyperlink, 'HYPERLINK',
                    fname, true, false, false);
                  txtobj.CParam := i;
                  FStack.LastStringBuilder.Tag := txtobj.NewTag;
                end
                else if ftype = 'MERGEFIELD' then
                begin
                  CreateImplizitPar;
                  fname := FStack.LastStringBuilder.GetNext;
                  txtobj := PrintTextObj(wpobjMergeField, fname,
                    FStack.LastStringBuilder.GetRest,
                    true, false, false);
                  if FStack.LastStringBuilder.FFieldType = wpNewFormField then
                    txtobj.Mode := txtobj.Mode + [wpobjWithinEditable];
                  txtobj.Params := FCurrentString.GetString;
                  FStack.LastStringBuilder.Tag := txtobj.NewTag;

                // If there is text after fldrsl - ignore it !
                // FStack.FPrevious.Destination := rdsSkip;

                end
                else if ftype = 'FORMTEXT' then
                begin
                  CreateImplizitPar;
                  fname := FStack.LastStringBuilder.GetNext;
                  txtobj := PrintTextObj(wpobjMergeField, fname,
                    FStack.LastStringBuilder.GetRest,
                    true, false, false);
                  txtobj.Mode := txtobj.Mode + [wpobjWithinEditable];
                  txtobj.Params := FCurrentString.GetString;
                  FStack.LastStringBuilder.Tag := txtobj.NewTag;
                  FStack.LastStringBuilder.FFieldType := wpNewFormField;
                  if FCurrFieldName <> '' then
                    txtobj.Name := FCurrFieldName;
                  if FCurrFieldText <> '' then
                    txtobj.Params := FCurrFieldText;
               { if FCurrFieldFormat<>'' then
                begin
                     FCurrFieldFormat ...
                end; }
                  FCurrFieldName := '';
                  FCurrFieldText := '';
                  FCurrFieldFormat := '';

                end
                else if ftype = 'TOC' then
                begin
                  CreateImplizitPar;
                  fname := FStack.LastStringBuilder.GetRest;
                  txtobj := PrintTextObj(wpobjMergeField, '__TOC__',
                    fname,
                    true, false, false);
                  FStack.LastStringBuilder.Tag := txtobj.NewTag;
                end
                else if ftype = 'INCLUDEPICTURE' then
                begin
                  CreateImplizitPar;
                  fname := Trim(FStack.LastStringBuilder.GetNext);
                  txtobj := PrintTextObj(wpobjImage, fname,
                    '', // Command
                    false, false, false);
                  if txtobj <> nil then
                    LoadLinkedImage(txtobj, fname,
                      FStack.LastStringBuilder.GetRest);
                // Read result (this is the ALT text)
                  FStack.Destination := rdsAnyString;
                  FCurrentString.Clear;
                  FCurrentString.FToObject := txtobj;
                end
                else
                begin // any other fields
                  CreateImplizitPar;
                  txtobj := PrintTextObj(wpobjTextObject, ftype,
                    FStack.LastStringBuilder.GetRest,
                    false, false, false);
                // Read result
                  FStack.Destination := rdsAnyString;
                  FCurrentString.Clear;
                  FCurrentString.FToObject := txtobj;
                end
              end; // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            end
            else FStack.Destination := rdsNorm;
          end else FStack.Destination := rdsNorm;
        end;
      idestFontTbl: begin FStack.Destination := rdsFontTbl; end;
      idestColorTable: begin FStack.Destination := rdsColorTable; end;
      idestNestTableDef: begin FStack.Destination := rdsNestRowProps; end;
      idestInfoItem:
        begin
          if (value >= 0) and (value < Length(WPPredefinedFields) {7}) then
          begin
            FInfoItemName := WPPredefinedFields[value];
            FInfoItemType := 0;
            FStack.Destination := rdsInfoItem;
          end
          else
          begin
            FInfoItemName := FCurrentString.GetString;
            FStack.Destination := rdsInfoItem;
          end;
          FCurrentString.Clear;
        end;
      idestInfoUserRecord:
        begin
          if value = 0 then
            FStack.Destination := rdsInfoGroup
          else
            FStack.Destination := rdsUserProps;
        end;
      idestInfoItemName:
        begin
          FStack.Destination := rdsInfoItemName;
          FCurrentString.Clear;
        end;

      idestWPBinInfo:
        begin
          FStack.Destination := rdsWPBinInfo;
          FInfoItemName := '';
          FWPBinData.Clear;
        end;
      idestWPBinName:
        begin
          FStack.Destination := rdsInfoItemName;
          FCurrentString.Clear;
        end;
      idestWPBinData:
        begin
          FStack.Destination := rdsWPBinDataHex;
          FWPBinData.Clear;
          FInfoItemName := FCurrentString.GetString;
          FStack.Destination := rdsWPBinDataHex;
        end;
      idestFootNote:
        begin
          FStack.Destination := rdsFootnote;
          FCurrentString.Clear;
        end;

      idestPictureName: begin FStack.Destination := rdsSkip; end;
      idestDelphicontrol: begin FStack.Destination := rdsSkip; end;
{$IFDEF WPRTFIGNORE_BOOKM}
      idestBookmarkStart:
        begin FStack.Destination := rdsSkip;
        end;
      idestBookmarkEnd:
        begin FStack.Destination := rdsSkip;
        end;
{$ELSE}
      idestBookmarkStart:
        if OptNoBookmarks then
          FStack.Destination := rdsSkip else
        begin FStack.Destination := rdsBookmark;
          FCurrentString.Clear;
          FIsBookmarkStart := TRUE;
        end;
      idestBookmarkEnd:
        if OptNoBookmarks then
          FStack.Destination := rdsSkip else
        begin FStack.Destination := rdsBookmark;
          FCurrentString.Clear;
          FIsBookmarkStart := FALSE;
        end;
{$ENDIF}
      idestHeader,
        idestFooter:
        begin
          if OptOnlyBody
            or (loIgnoreHeaderFooter in FLoadOptions)
            or FClipboardOperation
            then
          begin
            FStack.Destination := rdsSkip; // Ignore it !
            FStack.AllIgnore := TRUE;
          end
          else
          begin
            if idestCode = idestHeader then
              aKind := wpIsHeader else aKind := wpIsFooter;
            //V5.20.7 - fix MSWord 2003 bug - save headerr instead of header
            if not Layout.hasFacingP and
              (Value = 1) and
{$IFNDEF ALWAYS_HEADER_R_BUG}
            (Pos('Microsoft Word', FWrittenByGenerator) > 0) and
{$ENDIF}
            (FRTFDataCollection.Find(aKind, wpraOnAllPages, FCurrentElementName)
              = nil)
              then Value := 0;
            // -----------------------------------------
            rtfdataobj := FRTFDataCollection.Append(aKind,
              TWPPagePropertyRange(Value), FCurrentElementName);
            LoadIntoRTFDataBlock(rtfdataobj);
          end;
        end;
      idestWPElementName:
        begin
          FStack.Destination := rdsElementName;
          FCurrentString.Clear;
        end;
      idestStyleSheet:
        begin
          if OptNoStyles or (loIgnoreStylesheet in LoadOptions) then
            FStack.Destination := rdsSkip
          else FStack.Destination := rdsStyleSheet;
        end;
      idestCS:
        begin
       // This is usually used as \*\cs so wee need to use it like a Destination !
        end;
      idestListtable:
        begin
{$IFDEF NONEWLIST}
          FStack.Destination := rdsSkip;
{$ELSE}
          if OptNoNumStyles or (loIgnoreListTable in LoadOptions) then
            FStack.Destination := rdsSkip
          else
          begin
            FStack.Destination := rdsListtable;
            FHasNewListTable := TRUE;
          end;
{$ENDIF}
        end;
      idestList:
        begin
          if FStack.Destination = rdsListtable then
          begin
            FStack.Destination := rdsList;
            FCurrentList := TWPRTFReadList.Create(FRTFProps);
            FCurrentList.FListLevelCount := 0;
            FListsDefs.Add(FCurrentList);
          end else FStack.Destination := rdsSkip;
        end;
      idestListName:
        begin
          if FStack.Destination = rdsList then
          begin
            FStack.Destination := rdsListName;
            FCurrentString.Clear;
          end else FStack.Destination := rdsSkip;
        end;
      idestListlevel:
        begin
          if (FStack.Destination = rdsList) and (FCurrentList <> nil) and FCurrentList.InitNext then
          begin
            FStack.Destination := rdsListLevel;
            FReadingStyle := FCurrentList.CurrentStyle;
          end
          else FStack.Destination := rdsSkip;
        end;
      idestListOverride:
        begin
          if loIgnoreListTable in LoadOptions then
            FStack.Destination := rdsSkip
          else FStack.Destination := rdsListOverride;
        end;
      idestListOverrideItem:
        begin
          if FStack.Destination = rdsListOverride then
          begin
            if FListOverrideCount + 10 > Length(FListOverrides) then
              SetLength(FListOverrides, FListOverrideCount + 10);
            inc(FListOverrideCount);
          end
          else FStack.Destination := rdsSkip;
        end;
      idestLevelText: // uses FCurrentString
        begin
          if (loIgnoreListTable in LoadOptions) or (FCurrentList = nil) then
            FStack.Destination := rdsSkip
          else
          begin
            FStack.Destination := rdsLevelText;
            FCurrentNumberString := '';
          end;
        end;
      idestListStyleName: begin end;
      idestLevelNumbers:
        begin
          FStack.Destination := rdsSkip;
        end;
      idestListText:
        begin
{$IFDEF IGNORELIST}
          FStack.Destination := rdsNorm;
{$ELSE}
          if loDontIgnoreNumberText in LoadOptions then
            FStack.Destination := rdsNorm
          else FStack.Destination := rdsSkip;
{$ENDIF}
        end;
      idestPN:
        begin
          if not (loIgnoreNumberDefs in LoadOptions) then
          begin
            FStack.Destination := rdsPNDef;

            FillChar(FPNGroup, SizeOf(FPNGroup), 0);

            FPNTEXTB := '';
            FPNTEXTA := '';
            FPNGroup.Reading := TRUE;
          end else FStack.Destination := rdsSkip;
        end;
      idestPNTextA:
        begin
          if ((FReadingStyle = nil) and (FCurrentParagraph <> nil) and //V5.20.7 - ignore bogus TextB
            (FCurrentParagraph.AGetDef(WPAT_NumberStyle, 0) <> 0))
            or (loIgnoreNumberDefs in LoadOptions) then
            FStack.Destination := rdsSkip
          else
          begin
            FStack.Destination := rdsPNTextA;
            FCurrentString.Clear;
          end;
        end;
      idestPNTextB:
        begin
          if ((FReadingStyle = nil) and (FCurrentParagraph <> nil) and //V5.20.7 - ignore bogus TextB
            (FCurrentParagraph.AGetDef(WPAT_NumberStyle, 0) <> 0))
            or (loIgnoreNumberDefs in LoadOptions) then
            FStack.Destination := rdsSkip
          else
          begin
            FStack.Destination := rdsPNTextB;
            FCurrentString.Clear;
          end;
        end;
      idestPNText:
        begin
{$IFDEF IGNORELIST}
          FStack.Destination := rdsNorm;
{$ELSE}
          if (loDontIgnoreNumberText in LoadOptions) or OptNoNumStyles then
            FStack.Destination := rdsNorm
          else FStack.Destination := rdsSkip;
{$ENDIF}
        end;
      idestPNStyle:
        begin
{$IFDEF IGNORELIST}
          FStack.Destination := rdsSkip;
{$ELSE}
          if (loIgnoreOldStyleListTable in LoadOptions) // or FHasNewListTable
            or not (Value in [1..9]) then
            FStack.Destination := rdsSkip
          else
          begin
            FStack.Destination := rdsPNStyle;
            FOldListTableLevel := Value;
            if FOldListTable[FOldListTableLevel] = nil then
              FOldListTable[FOldListTableLevel] := TWPTextStyle.Create(FRTFProps)
            else FOldListTable[FOldListTableLevel].Clear;
            FReadingStyle := FOldListTable[FOldListTableLevel];
            FOldListTableUseAs[FOldListTableLevel] := 0;
          end;
{$ENDIF}
        end;
      idestMergePar:
        begin
          FStack.Destination := rdsMergePar;
          FCurrentString.Clear;
        end;
      idestInitCode: begin FStack.Destination := rdsSkip; end;
      idestBackgroundImage: begin FStack.Destination := rdsSkip; end;
      idestOLEData: begin FStack.Destination := rdsSkip; end;
      idestOLEClass: begin FStack.Destination := rdsSkip; end;
      idestOLEName: begin FStack.Destination := rdsSkip; end;
      idestOLETime: begin FStack.Destination := rdsSkip; end;
      idestReadBinaryData: begin FStack.Destination := rdsSkip; end;
      idestShpinst:
        if FStack.Destination <> rdsShpinst then // NOT NESTED V5.38
        begin
          FStack.Destination := rdsShpinst;
          InitShape;
        end;
      idestShprslt:
        begin
          FStack.Destination := rdsShprslt;
          FStack.FIgnoreNextImg := TRUE;
        end;
      idestShpText: FStack.Destination := rdsShpText;
      idestShpSN: begin FStack.Destination := rdsShpSN; FCurrentString.Clear; end;
      idestShpSV: begin FStack.Destination := rdsShpSV; FCurrentString.Clear; end;
      idestShpSP:
        begin
          FStack.Destination := rdsShpSP;
          FCurrentString.Clear;
          FCurrentStringName := '';
        end;
      idestDo: begin FStack.Destination := rdsSkip; end;
      idestWPfldfrm: begin FStack.Destination := rdsSkip; end;
      idestReadANSITEXT: begin FStack.Destination := rdsSkip; end;
      idestReadUNICODE: begin FStack.Destination := rdsSkip; end;
      idestGenerator:
        begin
          FInfoItemName := 'Generator';
          FInfoItemType := 0;
          FStack.Destination := rdsInfoItem;
        end;
      idest_ffname:
        begin
          FCurrentExString.Clear;
          FStack.Destination := rdsffname;
          FCurrFieldName := '';
        end;
      idest_ffdeftext:
        begin
          FCurrentExString.Clear;
          FStack.Destination := rdsffdeftext;
          FCurrFieldText := '';
        end;
      idest_ffformat:
        begin
          FCurrentExString.Clear;
          FStack.Destination := rdsffformat;
          FCurrFieldFormat := '';
        end;
      idestNonesttables:
        begin
          FStack.Destination := rdsSkip;
        end;
      idestPicName:
        begin
          FStack.Destination := rdsPicName;
          FCurrentExString.Clear;
        end;
      idestPicSource:
        begin
          FStack.Destination := rdsPicSource;
          FCurrentExString.Clear;
        end;
      idestMergeVar:
        begin
{$IFDEF GROUPVAR} 
          FStack.Destination := rdsMergeVar;
          FCurrentString.Clear;
{$ELSE} 
          FStack.Destination := rdsSkip;
{$ENDIF} 
        end;
    else FStack.Destination := rdsSkip;
    end;
end;

// -----------------------------------------------------------------------------
// Close the current row  (Do not apply properties here!)
// -----------------------------------------------------------------------------

procedure TWPRTFReader.CloseCurrentRow;
var par, row: TParagraph; v, b, i, flag, newflag: Integer;
  tstack: TWPRTFTableStack;
begin
  tstack := TableVar[TableDepth];
  par := tstack.FFirstCellInRow;
  row := tstack.FTableRow;

  if (row = nil) and (tstack.FRowTbl.CellCount = 0) then
    exit; // Now cess in this row !

  // Read Row Properties
  if row <> nil then
  begin
    row.Assign(tstack.FTableRowStyle, false);

    if tstack.FRowTbl.SpaceBetweenCellsH <> 0 then
    begin
      row.ASet(WPAT_PaddingLeft, tstack.FRowTbl.SpaceBetweenCellsH);
      row.ASet(WPAT_PaddingRight, tstack.FRowTbl.SpaceBetweenCellsH);
      tstack.FRowTbl.RowFlags := tstack.FRowTbl.RowFlags or
        WPRDFLAG_RUse_trpaddl or WPRDFLAG_RUse_trpaddr;
    end else
      if tstack.FRowTbl.SpaceBetweenCells <> 0 then
        row.ASet(WPAT_PaddingAll, tstack.FRowTbl.SpaceBetweenCells);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RIsHeader) = WPRDFLAG_RIsHeader then
      include(row.prop, paprIsHeader);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RIsFooter) = WPRDFLAG_RIsFooter then
      include(row.prop, paprIsFooter);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RIsCollapsed) = WPRDFLAG_RIsCollapsed then
      include(row.prop, paprIsCollapsed);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RKeep) = WPRDFLAG_RKeep then
    begin
      row.ASet(WPAT_ParKeep, 1); // include(row.prop, paprKeep);
 
    end;
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RKeepN) = WPRDFLAG_RKeepN then
      row.ASet(WPAT_ParKeepN, 1); // include(row.prop, paprKeepN);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RAutoFit) = WPRDFLAG_RAutoFit then
      include(row.prop, paprAutoFit);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RTL) = WPRDFLAG_RTL then
      include(row.prop, paprRightToLeft);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trpaddl) <> WPRDFLAG_RUse_trpaddl then
      row.ADel(WPAT_PaddingLeft);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trpaddt) <> WPRDFLAG_RUse_trpaddt then
      row.ADel(WPAT_PaddingTop);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trpaddr) <> WPRDFLAG_RUse_trpaddr then
      row.ADel(WPAT_PaddingRight);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trpaddb) <> WPRDFLAG_RUse_trpaddb then
      row.ADel(WPAT_PaddingBottom);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trspdl) <> WPRDFLAG_RUse_trspdl then
      row.ADel(WPAT_CELLSPACEL);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trspdl) <> WPRDFLAG_RUse_trspdt then
      row.ADel(WPAT_CELLSPACET);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trspdl) <> WPRDFLAG_RUse_trspdr then
      row.ADel(WPAT_CELLSPACER);
    if (tstack.FRowTbl.RowFlags and WPRDFLAG_RUse_trspdl) <> WPRDFLAG_RUse_trspdb then
      row.ADel(WPAT_CELLSPACEB);

    // trrh:            WPBOXALIGN_RIGHT
    if not OptIgnoreRowHeight
{$IFDEF FIX_FAULTY_TRRH}
    and ((abs(tstack.FRowTbl.RowHeight) < 2880) or (row.ParentParentTable = nil))
{$ENDIF}
    then
    begin
      if tstack.FRowTbl.RowHeight < 0 then
      begin
        row.ASet(WPAT_BoxMaxHeight, -tstack.FRowTbl.RowHeight);
        row.ASet(WPAT_BoxMinHeight, -tstack.FRowTbl.RowHeight); //V5.17.4
      end
      else if tstack.FRowTbl.RowHeight > 0 then
        row.ASet(WPAT_BoxMinHeight, tstack.FRowTbl.RowHeight);
    end;

 

  end;
  i := 0;

  while par <> nil do
  begin
    if (RowReading) and (i < tstack.FRowTbl.CellCount) then
    begin
      par.AMerge(tstack.TableCellStyle[i], false);
      b := tstack.FRowTbl.CellBorder[i];
      if b <> 0 then par.ASet(WPAT_BorderFlags, b);
      flag := tstack.FRowTbl.CellFlags[i];
      newflag := 0;
      if (flag and WPRDFLAG_NoWrap) = WPRDFLAG_NoWrap then
        newflag := newflag or WPCELL_NOWORDWRAP;
      // Width - use BestWidth OR CellWidth
      if tstack.FRowTbl.CellCount = 1 then
      begin
        // We have only one cell, dont set width in cell, just in table!
        //V5.19.4: new code to set width of parent table
        if (tstack.FTableParent <> nil) and (tstack.FTableRow.PrevPar = nil) then
          tstack.FTableParent.ASet(WPAT_BoxWidth, tstack.FRowTbl.CellWidth[0]);
      end else
        if (flag and WPRDFLAG_WIDTH_ISOFF) = WPRDFLAG_WIDTH_ISOFF then
          newflag := newflag or WPCELL_AUTOFIT
        else if (flag and WPRDFLAG_WIDTH_ISPT) = WPRDFLAG_WIDTH_ISPT then
          par.ASet(WPAT_COLWIDTH_PC, tstack.FRowTbl.CellBestWidth[i] * 2)
        else if (flag and WPRDFLAG_WIDTH_ISTW) = WPRDFLAG_WIDTH_ISTW then
          par.ASet(WPAT_COLWIDTH, tstack.FRowTbl.CellBestWidth[i])
        else {$IFDEF NOWIDTH_COLSPAN}if not ((flag and WPRDFLAG_CELLMERGE) = WPRDFLAG_CELLMERGE) then // no width in MERGE CELLS!
{$ENDIF}
            par.ASet(WPAT_COLWIDTH, tstack.FRowTbl.CellWidth[i]);

      if newflag <> 0 then
        par.ASet(WPAT_CELLFlags, newflag);

      if (flag and WPRDFLAG_ROWMERGE) = WPRDFLAG_ROWMERGE then
        include(par.prop, paprRowMerge);
      if (flag and WPRDFLAG_CELLMERGE) = WPRDFLAG_CELLMERGE then
        include(par.prop, paprColMerge);
       // Padding
      if (flag and WPRDFLAG_Use_clpadl) <> WPRDFLAG_Use_clpadl then
        par.ADel(WPAT_CELLSPACEL);
      if (flag and WPRDFLAG_Use_clpadt) <> WPRDFLAG_Use_clpadt then
        par.ADel(WPAT_CELLSPACET);
      if (flag and WPRDFLAG_Use_clpadr) <> WPRDFLAG_Use_clpadr then
        par.ADel(WPAT_CELLSPACER);
      if (flag and WPRDFLAG_Use_clpadb) <> WPRDFLAG_Use_clpadb then
        par.ADel(WPAT_CELLSPACEB);
      inc(i);
    end;
    include(par.prop, paprIsTable);
    par := par.NextPar;
  end;
  // Assign Table Width - in first row only   V5.19.6
  if tstack.FRowTbl.RowLeft <> 0 then
  begin

    par := tstack.FTableParent; 
    if par <> nil then par.ASet(WPAT_BoxMarginLeft, tstack.FRowTbl.RowLeft);
  end;

  if (tstack <> nil) and
    (tstack.FTableParent <> nil) and (row <> nil)
{$IFDEF USEMAX_BOX}
  and
    ((row.PrevPar = nil) or
    (tstack.FTableParent.AGetDef(WPAT_BoxWidth, 0) < tstack.FRowTbl.AllWidth))
{$ELSE}
  and (row.PrevPar = nil)
{$ENDIF}
  then
  begin
    if (((tstack.FRowTbl.RowFlags and WPRDFLAG_RAutoFit) = 0)
      or (wpDisableAutosizeTables in RTFDataCollection.FormatOptions)) //V5.18.1
      and (tstack.FRowTbl.AllWidth <> 0) then
    begin
      if tstack.FRowTbl.BoxWidth > 0 then
        tstack.FTableParent.ASet(WPAT_BoxWidth,
          tstack.FRowTbl.BoxWidth)
      else if tstack.FRowTbl.BoxWidth_PC > 0 then
        tstack.FTableParent.ASet(WPAT_BoxWidth_PC,
          tstack.FRowTbl.BoxWidth_PC * 2)
      else if not OptIgnoreTableWidth then
      begin
        v := tstack.FTableParent.AGetDef(WPAT_BoxWidth, 0);
        if tstack.FRowTbl.AllWidth > v then
        begin
          tstack.FTableParent.ASet(WPAT_BoxWidth,
            tstack.FRowTbl.AllWidth);
          //V5.20.5: Make sure we can split the table
          TableVar[i].FRowTbl.BoxWidth := tstack.FRowTbl.AllWidth;
        end;

      end;
    end;
  end;

  // Init values
  tstack.FRowTbl.ResetCellCount := TRUE;
  tstack.FRowTbl.CellLast := 0;
  tstack.FFirstCellInRow := nil;
  tstack.FLastCellInRow := nil;
  tstack.FTableRow := nil;
  TableVar[TableDepth].FInsideCell := FALSE;
  TableVar[TableDepth].FInsideRow := FALSE;
  FCurrentParagraph := TableVar[TableDepth].FTableParent;
end;

// -----------------------------------------------------------------------------
// InitShape
// -----------------------------------------------------------------------------

procedure TWPRTFReader.InitShape;
begin
  FShape.shpName := '';
  FillChar(FShape, SizeOf(FShape), 0);
  FShape.shpbxmethod := 2;
  FShape.shpbymethod := 2;
  FShape.shpbxmode := 2;
  FShape.shpbypara := true;
 
  FShape.Reading := TRUE;
end;

// -----------------------------------------------------------------------------
// Create an object from the data in 'FPicture'
// -----------------------------------------------------------------------------

function TWPRTFReader.CreateObject: TWPObject;
var objclass: TWPObjectClass; ext: string;
begin
  Result := nil;

  if FSTack.FIgnoreNextImg then exit;

  if not (loIgnoreGraphics in FLoadOptions) then
  begin
    if FPicture.pType = wpreadWPTools then
    begin
       // -------------------------------------------------------------
       // If you get a runtime error 'Class ... not found
       // please check if you have	included the units which
       // contain the implementation for the embedded objects:
       // include "WPOBJImage" for graphic support
      try
        Result := WPReadWPObject(FRTFDataCollection, FPicture.pData, FPicture.pTag, FPictureSource,
          FPicture.w, FPicture.h);
        FIgnoreNextPict := (Result <> nil) and Result.CanSaveAsRTF(nil);
        //was: FIgnoreNextPict := TRUE;
      except
        Result := nil;
      end;
    end else
      if FIgnoreNextPict then FIgnoreNextPict := FALSE
      else
      begin
        ext := '';
        case FPicture.pType of
          wpreadPictBMPFile: ext := 'BMP';
          wpreadPictWMetafile: ext := 'WMF';
          wpreadPictEMF: ext := 'EMF';
          wpreadPictPNG: ext := 'PNG';
          wpreadPictJPEG: ext := 'JPG';
          wpreadPictMAC: ext := 'PICT';
          wpreadPictPMMetafile: ext := 'EMF';
          wpreadPictDBitmap: ext := 'BMP';
          wpreadPictWBitmap: ext := 'BMP';
          wpreadShape: ext := '';
        end;

        if ext <> '' then
        begin
          objclass := RTFProps.Enviroment.GetWPObjectForExtension(
            RTFDataCollection, ext);
          if objclass <> nil then
          begin
            Result := objclass.Create(RTFDataCollection);
            Result.FileExtension := ext;
            if not Result.ReadRTFData(Self, FPicture) then
              FreeAndNil(Result);
          end
        end;
      end;
  end;
end;

// -----------------------------------------------------------------------------
// Virtual method to overwrite and individually allow or forbid fonts
// -----------------------------------------------------------------------------

function TWPRTFReader.UseThisFont(var aFont: String; aFontTbl: PTWPRTFFontTable): TThreeState;
begin
  Result := tsIgnore;
end;

// -----------------------------------------------------------------------------
// Read a font table character
// -----------------------------------------------------------------------------

procedure TWPRTFReader.ReadFontTblChar(ch: Char);
var newfontnr, j, i: Integer;
  WasAdded: Boolean;
  pp: TWPRTFReaderStack;
  fUseThisFont: TThreeState;
  s: String;
begin
  if (ch = ';') and (chLastFontCH <> '$') then
  begin
    s := FFontTbl.aktFont;
    fUseThisFont := UseThisFont(s, @FFontTbl);
    FFontTbl.aktFont := s;

    if (fUseThisFont <> tsFalse) and
      ((fUseThisFont = tsTrue) or
      ((fUseThisFont = tsIgnore) and not (loIgnoreFonts in FLoadOptions) and not OptIgnoreFonts)) then
    begin
      if (FFontTbl.aktnr >= 0) and (FFontTbl.aktnr < 1000) then
      begin
      // -------- Do you want to replace fontnames? Hard-code it here.
      // ....
{$IFDEF NOATATSTART}
        if (FFontTbl.aktFont <> '') and (FFontTbl.aktFont[1] = '@') then
          FFontTbl.aktFont := Copy(FFontTbl.aktFont, 2, Length(FFontTbl.aktFont) - 1);
{$ENDIF}
{$IFDEF NOPARENTHESESINFONTNAMES}
        i := Pos('(', FFontTbl.aktFont);
        if (i > 0) and (Copy(FFontTbl.aktFont, i, 4) <> '(CV)') then
          FFontTbl.aktFont := Trim(Copy(FFontTbl.aktFont, 1, i - 1));
{$ENDIF}
{$IFDEF NODOLLARINFONTNAMES}
        i := Pos('$', FFontTbl.aktFont);
        if i > 0 then
          FFontTbl.aktFont := Trim(Copy(FFontTbl.aktFont, 1, i - 1));
{$ENDIF}
      // -------------------------------------------------------------
        if (Length(FFontTbl.aktFont) > 3) and // remove ' CE' if not installed
          (FFontTbl.aktFont[Length(FFontTbl.aktFont) - 2] = #32) and
        (FFontTbl.aktFont[Length(FFontTbl.aktFont) - 1] = 'C') and
        (FFontTbl.aktFont[Length(FFontTbl.aktFont)] = 'E') then
        begin
          if Screen.Fonts.IndexOf(FFontTbl.aktFont) >= 0 then // ist it installed ?
            newfontnr := FRTFProps.AddFontName(FFontTbl.aktFont, WasAdded)
          else newfontnr := FRTFProps.AddFontName(Copy(FFontTbl.aktFont, 1, Length(FFontTbl.aktFont) - 3));
        end
        else newfontnr := FRTFProps.AddFontName(FFontTbl.aktFont, WasAdded);

        if FFontTbl.aktnr < MAXFONTTBL then
        begin
          FFontTbl.FontNr[FFontTbl.aktnr] := newfontnr;
          // FIX RTF code which is using a symbol font with a wrong charset -----
          if (FFontTbl.aktCharset = 0) and RTFProps._FontIsSymbol(FFontTbl.aktFont) then
            FFontTbl.aktCharset := 2;
          // FIX RTF which is using a barcode font with a wrong charset --------
          if (FFontTbl.aktCharset <> 0) and (
            (CompareText(FFontTbl.aktFont, 'Free 3 of 9 Extended') = 0)
            // or  (CompareText(FFontTbl.aktFont, '...') = 0)
            ) then
            FFontTbl.aktCharset := 1;

          // Assign the loading charset -----------------------------------------
          FFontTbl.FontCharset[FFontTbl.aktnr] := FFontTbl.aktCharset;
          if FFontTbl.aktCharset = 1 then //V5.22 - get current locale !!
          begin
            if HasOptCodePage then // we used the codepage=xxxx format string
              FFontTbl.FontCodePage[FFontTbl.aktnr] := OptCodePage
            else FFontTbl.FontCodePage[FFontTbl.aktnr] := WPAllCodePages[1] // = GetACP - see unit WPCtrMemo
          end
          else if FFontTbl.aktCharset < 2 then  //V5.42
            FFontTbl.FontCodePage[FFontTbl.aktnr] := 0
          else FFontTbl.FontCodePage[FFontTbl.aktnr] :=
            WPGetCodePage(FFontTbl.aktCharset);
        end;

        if (FFontTbl.aktnr = FDefaultFontNrDEFF) and not OptIgnoreFonts then
        begin
          FDefaultFontNr := newfontnr; // attention: "DONT_FIX_DEFSTYLE"
          FDefaultFontNrMap := FFontTbl.aktnr; // Used for charset loading !
          // DefaultFont also sets the CodePage !
          Attr.SetFont(FFontTbl.Fontnr[FDefaultFontNrDEFF]);
          if FFontTbl.FontCharSet[FDefaultFontNrDEFF] > 0 then
            Attr.ASet(WPAT_CharCharset, FFontTbl.FontCharSet[FDefaultFontNrDEFF])
          else Attr.ADel(WPAT_CharCharset);
          FCurrentCodePage := FFontTbl.FontCodePage[FDefaultFontNrDEFF];
          pp := FStack;
          while pp <> nil do // Promote the code page to previous levels
          begin
            pp.FCurrentCodePage := FCurrentCodePage;
            pp := pp.FPrevious;
          end;
          WasAdded := true;
        end;

      // We set IsNew to FALSE when we actually USE this font while reading !
      // We also set it to FALSE if one item is referenced by several entries in the
      // RTF font table !
        if WasAdded then
          FFontTbl.IsNew[FFontTbl.aktnr] := TRUE
        else
        begin
      // Set all references to 'used' since we use it more than once
          for j := 0 to FFontTbl.aktnr do
            if FFontTbl.FontNr[j] = newfontnr then
              FFontTbl.IsNew[j] := FALSE;
        end;
      end;
      // FFontTbl.aktnr := 0;
      FFontTbl.aktnr := -1; // IGNORE next font - require \f in RTF ! V5.25
      FFontTbl.aktCharset := 1;
      FFontTbl.aktFont := '';
    end;
  end
  else if (FFontTbl.aktFont <> '') or (ch <> #32) then
  begin
    FFontTbl.aktFont := FFontTbl.aktFont + ch;
  end;
  chLastFontCH := ch;
end;

// -----------------------------------------------------------------------------
// this is the function you may change to modify Attr using simple ESC codes
// -----------------------------------------------------------------------------

function TWPRTFReader.ParseEscapeCode(ch: Integer): TWPToolsIOErrCode;
{$IFNDEF READ_ESC_EXAMPLE}
begin
  PrintAByte(Byte(ch));
  Result := wpNoError;
end;
{$ELSE}
var c: Integer;
  s: string;
begin
  s := '';
  repeat
    c := ReadChar;
    if (c <= 32) then
    begin
      if c <> 32 then unReadChar; // - only if you want this space!
      break;
    end else
    begin
      s := s + Char(c);
    end;
  until false;
   // process 's'
  if s = 'b' then include(Attr.Style, afsBold)
  else if s = 'n' then exclude(Attr.Style, afsBold);
  Result := wpNoError;
end;
{$ENDIF}

// -----------------------------------------------------------------------------
// TWPRTFReaderStack
// -----------------------------------------------------------------------------

constructor TWPRTFReaderStack.Create(props: TWPRTFProps);
begin
  inherited Create(props);
  FFieldINST := nil;
end;

destructor TWPRTFReaderStack.Destroy;
begin
  FreeAndNil(FFieldINST);
  inherited Destroy;
end;

function TWPRTFReaderStack.LastStringBuilder: TWPStringBuilderReadRTF;
var p: TWPRTFReaderStack;
begin
  p := Self;
  Result := nil;
  while (p <> nil) and (Result = nil) do
  begin
    Result := p.FFieldINST;
    p := p.FPrevious;
  end;
end;

// -----------------------------------------------------------------------------
// TWPRTFReadStyleSheet
// -----------------------------------------------------------------------------

function TWPRTFReadList.InitNext: Boolean;
begin
  inc(FListLevelCount);
  if FListLevelCount <= 9 then
  begin
    FListLevel[FListLevelCount] := TWPTextStyle.Create(FRTFProps);
    Result := TRUE;
  end
  else Result := FALSE;
end;

function TWPRTFReadList.CurrentStyle: TWPTextStyle;
begin
  if FListLevelCount in [1..9] then
    Result := FListLevel[FListLevelCount]
  else Result := nil;
end;

function TWPRTFReadList.Get(N: Integer): Integer;
var ele: TWPRTFStyleElement; i, j, group: Integer;
begin
  Result := 0;
  if (N > 0) and (N <= 9) and (FListLevel[N] <> nil) then
  begin
    if FUsedAs[N] = 0 then
    begin
      if FListLevelCount > 1 then
        group := FRTFProps.NewOutlineGroup
      else group := 0;

      for i := 1 to FListLevelCount do
      begin
        // When loading group try to use the exiting in SAME group!
        ele := nil;
        if group > 0 then
          for j := 0 to FRTFProps.NumberStyles.Count - 1 do
          begin
            ele := FRTFProps.NumberStyles[j];
            if (ele.Group = group) and (ele.LevelInGroup = i) then break
            else ele := nil;
          end;
        if ele = nil then
          ele := FRTFProps.NumberStyles.Add(''); // MASK!!!
        ele._RTF_ID := FListID;
        ele.Group := group;
        ele.TextStyle.Assign(FListLevel[i]);
        if group <> 0 then
        begin
          ele.LevelInGroup := i;
          ele.TextStyle.ASet(WPAT_NumberLEVEL, i);
        end
        else
        begin
          ele.LevelInGroup := 0;
          ele.TextStyle.ADel(WPAT_NumberLEVEL);
        end;
        FUsedAs[i] := ele.ID;
        ele.Name := 'Outline_' + IntToStr(i);
        ///-------ele.TextStyle._DEBUGLOCK := TRUE;

      end;
      //DEBUG---ShowMessage(FRTFProps.NumberStyles.GetWPCSS);
    end;
    Result := FUsedAs[N];
  end;
end;

procedure TWPRTFReadList.Clear;
var i: Integer;
begin
  FListID := 0;
  FListName := '';
  FListLevelCount := 0;
  FListSimple := FALSE;
  for i := 1 to 9 do
  begin
    FreeAndNil(FListLevel[i]);
    FUsedAs[i] := 0;
  end;
end;

constructor TWPRTFReadList.Create(RTFProps: TWPRTFProps);
begin
  inherited Create;
  FRTFProps := RTFProps;
end;

destructor TWPRTFReadList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------
// TWPRTFReadStyleSheet
// -----------------------------------------------------------------------------

function TWPRTFReadStyleSheet.InitNext: TWPTextStyle;
begin
  if FStyleCount + 1 >= Length(FStyles) then
    SetLength(FStyles, FStyleCount + 10);
  inc(FStyleCount);
  FStyles[FStyleCount].FStyle := TWPTextStyle.Create(FRTFProps);
  Result := FStyles[FStyleCount].FStyle;
end;

function TWPRTFReadStyleSheet.GetName(N: Integer): string;
var i: Integer;
begin
  Result := '';
  for i := 0 to FStyleCount do
    if FStyles[i].FNum = N then
    begin Result := FStyles[i].FStyleName;
      break;
    end;
end;

function TWPRTFReadStyleSheet.Get(N: Integer): Integer;
var ele: TWPRTFStyleElement;
  i: Integer;
begin
  Result := 0;
  for i := 0 to FStyleCount do
    if FStyles[i].FNum = N then
    begin N := i;
      break;
    end;

  if (N >= 0) and (N <= FStyleCount) and (FStyles[N].FStyle <> nil) then
  begin

    if FStyles[N].FUsedAs = 0 then
    begin
      {not here - we do this at the end of the reading.
        if FStyles[N].FBasedOn > 0 then
      begin
        FStyles[N].FStyle.ASetBaseStyle(Get(FStyles[N].FBasedOn));
      end; }

      if (FKind = wpIsParStyle) and
        (loDontOverwriteExistingStyles in FLoadOptions) then
      begin
        ele := FRTFProps.ParStyles.FindStyle(FStyles[N].FStyleName);
        if ele <> nil then
        begin
          FStyles[N].FUsedAs := ele.ID;
             //NO - don't overwrite: ele.TextStyle.Assign(FStyles[N].FStyle);
          FStyles[N].FStyleElement := ele;
          Result := FStyles[N].FUsedAs;
          exit;
        end;
      end;

      if (FKind = wpIsCharStyle) and not (loNoCharStyles in FLoadOptions) then
{$IFDEF USE_CHARSTYLES}
        ele := FRTFProps.CharStyles.Add(FStyles[N].FStyleName)
{$ELSE}
        ele := FRTFProps.ParStyles.Add(FStyles[N].FStyleName)
{$ENDIF}
      else if FKind = wpIsParStyle then
        ele := FRTFProps.ParStyles.Add(FStyles[N].FStyleName)
      else ele := nil;

      if ele <> nil then
      begin
        FStyles[N].FUsedAs := ele.ID;
        ele.TextStyle.Assign(FStyles[N].FStyle);
        FStyles[N].FStyleElement := ele;
      end else exit;
    end;
    Result := FStyles[N].FUsedAs;
  end;
end;

procedure TWPRTFReadStyleSheet.Clear;
var i: Integer;
begin
  for i := 0 to FStyleCount do
  begin
    FreeAndNil(FStyles[i].FStyle);
    FStyles[i].FID := 0;
    FStyles[i].FBasedOn := 0;
    FStyles[i].FNext := 0;
    FStyles[i].FUsedAs := 0;
    FStyles[i].FStyleName := '';
    FStyles[i].FStyleElement := nil;
  end;
  FStyleCount := -1;
end;

constructor TWPRTFReadStyleSheet.Create(RTFProps: TWPRTFProps; Kind: TWPRTFStyleElementKind);
begin
  inherited Create;
  FRTFProps := RTFProps;
  FKind := Kind;
  FStyleCount := -1;
  SetLength(FStyles, 10);
end;

destructor TWPRTFReadStyleSheet.Destroy;
begin
  Clear;
  FStyles := nil;
  inherited Destroy;
end;

// -----------------------------------------------------------------------------
// TWPRTFTableStack
// -----------------------------------------------------------------------------

constructor TWPRTFTableStack.Create(props: TWPRTFProps);
begin
  inherited Create;
  FRTFProps := props;
  FTableRowStyle := TWPTextStyle.Create(props);
  FTableCellStyle := TList.Create;
end;

destructor TWPRTFTableStack.Destroy;
var i: Integer;
begin
  for i := 0 to FTableCellStyle.Count - 1 do
    TObject(FTableCellStyle[i]).Free;
  FTableCellStyle.Free;
  FTableRowStyle.Free;
  inherited Destroy;
end;

procedure TWPRTFTableStack.Clear; // V5.12.2
var i: Integer;
begin
  for i := 0 to FTableCellStyle.Count - 1 do
    TWPTextStyle(FTableCellStyle[i]).Clear;
  inherited Create;
end;

function TWPRTFTableStack.GetTableCellStyle(index: Integer): TWPTextStyle;
begin
  while FTableCellStyle.Count < index + 1 do
    FTableCellStyle.Add(TWPTextStyle.Create(FRTFProps));
  Result := TWPTextStyle(FTableCellStyle[index]);
end;

function TWPRTFTableStack.CurrentCell: TWPTextStyle;
begin
  Result := GetTableCellStyle(FRowTbl.CellCount);
end;

// -----------------------------------------------------------------------------
// All all RTF tags which are always defined
// -----------------------------------------------------------------------------

procedure PrepareRTFTags;
begin
  if WPRTFTagList <> nil then exit;
  WPRTFTagList := TStringList.Create;
  WPRTFTagList.Sorted := FALSE;
{$IFNDEF VER130}
  WPRTFTagList.CaseSensitive := TRUE;
{$ENDIF}
  // ---------------------------------------------------------------------------
  AddRgSymRtf('bin', 0, FALSE, kwdProp, ipropReadBin); // \bin N xxxxx

  AddRgSymRtf('plain', 0, FALSE, kwdProp, ipropPlain);
  AddRgSymRTF('f', 0, FALSE, kwdProp, ipropFontNr);
  AddRgSymRTF('fs', 100, FALSE, kwdProp, ipropFontSize);
  AddRgSymRTF('pard', 0, true, kwdProp, ipropPard);
  AddRgSymRTF('li', 0, FALSE, kwdProp, ipropLeftInd);
  AddRgSymRTF('ri', 0, FALSE, kwdProp, ipropRightInd);
  AddRgSymRTF('fi', 0, FALSE, kwdProp, ipropFirstInd);
  AddRgSymRTF('sb', 0, FALSE, kwdProp, ipropSpaceBefore);
  AddRgSymRTF('sa', 0, FALSE, kwdProp, ipropSpaceAfter);
  AddRgSymRTF('sl', 0, FALSE, kwdProp, ipropSpaceBetween);
  AddRgSymRTF('slmult', 0, FALSE, kwdProp, ipropslmult);
  AddRgSymRTF('par', 0, FALSE, kwdProp, ipropNewPar);
  {*}AddRgSymRTF('wpparid', 0, FALSE, kwdProp, ipropParID);
  {*}AddRgSymRTF('wpparflg', 0, FALSE, kwdProp, ipropParFLG);
  {*}AddRgSymRTF('wpparsel', 0, FALSE, kwdProp, ipropSelectedPar);
  AddRgSymRTF('b', 1, FALSE, kwdProp, ipropBold);
  AddRgSymRTF('caps', 1, FALSE, kwdProp, ipropUpperCase);
  AddRgSymRTF('lower', 1, FALSE, kwdProp, ipropLowercase);
  AddRgSymRTF('scaps', 1, FALSE, kwdProp, ipropSmallCaps);
  AddRgSymRTF('v', 1, FALSE, kwdProp, ipropHidden);
  AddRgSymRTF('ul', 1, FALSE, kwdProp, ipropUnderline);
  AddRgSymRTF('ulnone', 0, TRUE, kwdProp, ipropUnderline);
  AddRgSymRTF('uld', WPUND_Dotted, TRUE, kwdProp, ipropUnderlineMode); //V5 - 15 Underline Styles
  AddRgSymRTF('uldash', WPUND_Dashed, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('uldashd', WPUND_Dashdotted, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('uldashdd', WPUND_Dashdotdotted, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('uldb', WPUND_Double, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulhwave', WPUND_Heavywave, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulldash', WPUND_Longdashed, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulth', WPUND_Thick, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulthd', WPUND_Thickdotted, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulthdash', WPUND_Thickdashed, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulthdashd', WPUND_Thickdashdotted, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulthdashdd', WPUND_Thickdashdotdotted, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulthldash', WPUND_Thicklongdashed, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ululdbwave', WPUND_Doublewave, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulw', WPUND_WordUnderline, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulwave', WPUND_wave, TRUE, kwdProp, ipropUnderlineMode);
  {*}AddRgSymRTF('ulcurly', WPUND_curlyunderline, TRUE, kwdProp, ipropUnderlineMode);
  AddRgSymRTF('ulc', 0, FALSE, kwdProp, ipropUnderlineColor);

  AddRgSymRTF('cf', 0, FALSE, kwdProp, ipropColor);
  AddRgSymRTF('cb', 0, FALSE, kwdProp, ipropBkColor);
{$IFNDEF DONTREADHIGHLIGHT}
  AddRgSymRTF('highlight', 0, FALSE, kwdProp, ipropBkColor);
{$ENDIF}
  AddRgSymRTF('i', 1, FALSE, kwdProp, ipropItalic);

  AddRgSymRTF('super', 1, FALSE, kwdProp, ipropSuper);
  AddRgSymRTF('up', 6, FALSE, kwdProp, ipropUPSuper); //V4.08a
  AddRgSymRTF('sub', 1, FALSE, kwdProp, ipropSub);
  AddRgSymRTF('dn', 6, FALSE, kwdProp, ipropDnSub); //V4.08a

  AddRgSymRTF('nosupersub', 1, FALSE, kwdProp, ipropNoSuperSub);
  AddRgSymRTF('strike', 1, FALSE, kwdProp, ipropStrikeOut);
  AddRgSymRTF('striked', 1, FALSE, kwdProp, ipropDblStrikeOut);

  AddRgSymRTF('qc', Integer(paralCenter), TRUE, kwdProp, ipropJust);
{$IFDEF wp_posxc_is_qc}
  AddRgSymRTF('posxc', Integer(paralCenter), TRUE, kwdProp, ipropJust);
{$ENDIF}

  AddRgSymRTF('ql', Integer(paralLeft), TRUE, kwdProp, ipropJust);
  AddRgSymRTF('qr', Integer(paralRight), TRUE, kwdProp, ipropJust);
  AddRgSymRTF('qj', Integer(paralBlock), TRUE, kwdProp, ipropJust);

  AddRgSymRTF('vertalt', Integer(paralVertTop), true, kwdProp, ipropVertJust);
  AddRgSymRTF('vertalc', Integer(paralVertCenter), true, kwdProp, ipropVertJust);
  AddRgSymRTF('vertalb', Integer(paralVertBottom), true, kwdProp, ipropVertJust);
  AddRgSymRTF('vertalj', Integer(paprVertJustified), true, kwdProp, ipropVertJust);

  AddRgSymRTF('bkmkstart', 0, FALSE, kwdDest, idestBookmarkStart);
  AddRgSymRTF('bkmkend', 0, FALSE, kwdDest, idestBookmarkEnd);
  AddRgSymRTF('shad', 1, FALSE, kwdProp, ipropShadowed);

  //V4.20a - PROTECTED TEXT - undefine OLDPROTECTED in WPWrtRTF
  {*}AddRgSymRTF('wpprot', 1, FALSE, kwdProp, ipropProtected);
  //{*}AddRgSymRTF('wpcolspan', 0, FALSE, kwdProp, ipropWPColSpan);
  //{*}AddRgSymRTF('wpcolform', 0, FALSE, kwdProp, ipropWPColFormat);
  {*}AddRgSymRTF('wphzlino', 0, FALSE, kwdProp, ipropHorzLineOffSets);
  {*}AddRgSymRTF('wphzlinc', 0, FALSE, kwdProp, ipropHorzLineColor);
  {*}AddRgSymRTF('wphzlinw', 0, FALSE, kwdProp, ipropHorzLineWidth);
  {*}AddRgSymRTF('wphzlinetw', 0, FALSE, kwdProp, ipropHorzLineTW);
  {*}AddRgSymRTF('wphzline', 0, FALSE, kwdProp, ipropHorzLine);

  

// AddRgSymRTF('bin', 0, FALSE, kwdSpec, ipfnBin);
  //#: NNNN AddRgSymRTF('*', 0, FALSE, kwdSpec, ipfnSkipDest);
  AddRgSymRTF('pict', 0, FALSE, kwdDest, idestPicture);
  AddRgSymRTF('nonshppict', 0, FALSE, kwdDest, idestPicIgnorePic);
  {*}AddRgSymRTF('wptools', 0, FALSE, kwdDest, idestPicWPTools);
  AddRgSymRTF('shppict', 0, FALSE, kwdDest, idestPicSTD);
  AddRgSymRTF('picprop', 0, FALSE, kwdDest, idestPicProps);
  AddRgSymRTF('blipuid', 0, FALSE, kwdDest, idestPicUID);
  //REMOVED:  {*}AddRgSymRTF('picfile', 0, FALSE, kwdDest, idestPictureName);
  AddRgSymRTF('emfblip', Integer(wpreadPictEMF), TRUE, kwdProp, ipropPicSource);
  AddRgSymRTF('bmpblip', Integer(wpreadPictBMPFile), TRUE, kwdProp, ipropPicSource);
  {*}AddRgSymRTF('wbmpfile', Integer(wpreadPictBMPFile), TRUE, kwdProp, ipropPicSource); //READONLY
  AddRgSymRTF('pngblip', Integer(wpreadPictPNG), TRUE, kwdProp, ipropPicSource);
  AddRgSymRTF('jpegblip', Integer(wpreadPictJPEG), TRUE, kwdProp, ipropPicSource);
  AddRgSymRTF('macpict', Integer(wpreadPictMAC), TRUE, kwdProp, ipropPicSource);
  AddRgSymRTF('pmmetafile', 0, FALSE, kwdProp, ipropPicSourcePMeta);
  AddRgSymRTF('wmetafile', 1, FALSE, kwdProp, ipropPicSourceWMeta);
  AddRgSymRTF('picbmp', 0, FALSE, kwdProp, ipropPicMetaWithBMP);
  AddRgSymRTF('dibitmap', 0, FALSE, kwdProp, ipropPicSourceDIB);
  AddRgSymRTF('wbitmap', 0, FALSE, kwdProp, ipropPicSourceWBit);
  AddRgSymRTF('wbmbitspixel', 0, FALSE, kwdProp, ipropPicPixels);
  AddRgSymRTF('picbpp', 0, FALSE, kwdProp, ipropPicPixels);
  AddRgSymRTF('wbmplanes', 1, FALSE, kwdProp, ipropPicPlanes);
  AddRgSymRTF('wbmwidthbytes', 0, FALSE, kwdProp, ipropPicByteWidth);
  AddRgSymRTF('picw', 0, FALSE, kwdProp, ipropPicW);
  AddRgSymRTF('pich', 0, FALSE, kwdProp, ipropPicH);
  AddRgSymRTF('picwgoal', 0, FALSE, kwdProp, ipropPicGoalW);
  AddRgSymRTF('pichgoal', 0, FALSE, kwdProp, ipropPicGoalH);
  AddRgSymRTF('picscalex', 100, FALSE, kwdProp, ipropPicScaleX);
  AddRgSymRTF('picscaley', 100, FALSE, kwdProp, ipropPicScaleY);
  AddRgSymRTF('picscaled', 0, FALSE, kwdProp, ipropPicScaledMac);
  AddRgSymRTF('defshp', 0, FALSE, kwdProp, ipropIsShape);
  AddRgSymRTF('piccropl', 0, FALSE, kwdProp, ipropCropL);
  AddRgSymRTF('piccropr', 0, FALSE, kwdProp, ipropCropR);
  AddRgSymRTF('piccropt', 0, FALSE, kwdProp, ipropCropT);
  AddRgSymRTF('piccropb', 0, FALSE, kwdProp, ipropCropB);
  AddRgSymRTF('bliptag', 0, FALSE, kwdProp, ipropPicTag);
  AddRgSymRTF('blipupi', 0, FALSE, kwdProp, ipropPicUnits);
  {*}AddRgSymRTF('ppar', 1, TRUE, kwdProp, ipropPicFloatObj);
  {*}AddRgSymRTF('ppag', 2, TRUE, kwdProp, ipropPicFloatObj);
  {*}AddRgSymRTF('relx', 0, FALSE, kwdProp, ipropPicFloatObjRelX);
  {*}AddRgSymRTF('wprelx', 0, FALSE, kwdProp, ipropPicFloatObjRelXNew);
  {*}AddRgSymRTF('rely', 0, FALSE, kwdProp, ipropPicFloatObjRelY);
  {*}AddRgSymRTF('picwrap', 0, FALSE, kwdProp, ipropPicFloatObjWrap);
  {*}AddRgSymRTF('wpobjtag', 0, false, kwdProp, ipropPicTag); //READONLY
  {*}AddRgSymRTF('wpobjw', 0, false, kwdProp, ipropPicGoalW); //READONLY
  {*}AddRgSymRTF('wpobjh', 0, false, kwdProp, ipropPicGoalH); //READONLY
  {*}AddRgSymRTF('wpfopen', 0, false, kwdProp, ipropWPTXTOBJOpenTag);
  {*}AddRgSymRTF('wpfclose', 0, false, kwdProp, ipropWPTXTOBJCloseTag);
  {*}AddRgSymRTF('wpomode', 0, false, kwdProp, ipropOBJMODE);
  {*}AddRgSymRTF('wpoframe', 0, false, kwdProp, ipropOBJFRAME);
  {*}AddRgSymRTF('wpiparam', 0, FALSE, kwdProp, iprop_iparam);
  {*}AddRgSymRTF('wpframeparam', 0, FALSE, kwdProp, iprop_frameparam);
  {*}AddRgSymRTF('wpmodeparam', 0, FALSE, kwdProp, iprop_modeparam);
  {*}AddRgSymRTF('wpshpflg', 1, FALSE, kwdProp, iprop_frameextra);
  {*}AddRgSymRTF('wppicname', 0, FALSE, kwdDest, idestPicName);
  {*}AddRgSymRTF('wppicsource', 0, FALSE, kwdDest, idestPicSource);
  // ---------------------------------------------------------------------------
  AddRgSymRTF('shpleft', 0, false, kwdProp, ipropshpleft);
  AddRgSymRTF('shptop', 0, false, kwdProp, ipropshptop);
  AddRgSymRTF('shpright', 0, false, kwdProp, ipropshpright);
  AddRgSymRTF('shpbottom', 0, false, kwdProp, ipropshpbottom);
  AddRgSymRTF('shpfhdr', 0, false, kwdProp, ipropshpfhdr);
  AddRgSymRTF('shpbypage', 0, false, kwdProp, ipropshpbypage);
  AddRgSymRTF('shpbypara', 0, false, kwdProp, ipropshpbypara); // shpbymargin
  AddRgSymRTF('shpwr', 0, false, kwdProp, ipropshpwr);
  AddRgSymRTF('shpwrk', 0, false, kwdProp, ipropshpwrk);
  AddRgSymRTF('shpfblwtxt', 0, false, kwdProp, ipropshpfblwtxt);
  AddRgSymRTF('shpbxpage', 0, false, kwdProp, ipropshpbxcolumn); // Default !
  AddRgSymRTF('shpbxpara', 1, false, kwdProp, ipropshpbxcolumn);
  AddRgSymRTF('shpbxcolumn', 2, false, kwdProp, ipropshpbxcolumn);
 
  // ---------------------------------------------------------------------------

  AddRgSymRTF('footnote', 0, FALSE, kwdDest, idestFootNote);
  AddRgSymRTF('field', 1, TRUE, kwdDest, idestField);
  AddRgSymRTF('ffname', 0, FALSE, kwdDest, idest_ffname);
  AddRgSymRTF('ffdeftext', 0, FALSE, kwdDest, idest_ffdeftext);
  AddRgSymRTF('ffformat', 0, FALSE, kwdDest, idest_ffformat);
  AddRgSymRTF('formfield', 2, TRUE, kwdDest, idestField);
  AddRgSymRTF('ffmaxlen', 0, FALSE, kwdProp, ipropFFMaxLength);
  AddRgSymRTF('fldedit', 0, FALSE, kwdProp, ipropFieldEdit); // Edit Field (such as TOC) read it as text !
  AddRgSymRTF('fldrslt', 0, FALSE, kwdDest, idestFldResult);
  AddRgSymRTF('fldinst', 0, FALSE, kwdDest, idestFldInstructions);
  AddRgSymRTF('wpfldparam', 0, FALSE, kwdDest, idestFldParams);
  AddRgSymRTF('wpfldfrm', 0, FALSE, kwdDest, idestwpfldfrm);

  AddRgSymRTF('wpfnnr', 0, FALSE, kwdProp, ipropwpfnnr);
  //AddRgSymRTF('pict', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('printim', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('rxe', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('tc', 0, FALSE, kwdDest, idestSkip);

  // INFO Items (for compatibility with WPTools V3 these are also allowed outside
  // the info{} structure, too. (in WPTools V3 the info structure was ignored at all!)
  AddRgSymRTF('info', 0, TRUE, kwdDest, idestInfoUserRecord);
  AddRgSymRTF('title', 0, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('subject', 1, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('author', 2, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('keywords', 3, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('operator', 4, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('doccomm', 5, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('comment', 5, TRUE, kwdDest, idestInfoItem); // FOR compatibility only! Use 'doccomm' instead !
  // Generator = 6
  AddRgSymRTF('manager', 7, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('company', 8, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('category', 9, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('hlinkbase', 10, TRUE, kwdDest, idestInfoItem);

  AddRgSymRTF('generator', 0, FALSE, kwdDest, idestGenerator);
  AddRgSymRTF('userprops', 1, TRUE, kwdDest, idestInfoUserRecord);
  AddRgSymRTF('propname', 0, FALSE, kwdDest, idestInfoItemName);
  AddRgSymRTF('staticval', 1000, TRUE, kwdDest, idestInfoItem);
  AddRgSymRTF('proptype', 0, FALSE, kwdProp, ipropInfoItemType);
  { Binaray RTF Varaiables - WPTools specific }
  AddRgSymRTF('wpbininfo', 0, FALSE, kwdDest, idestWPBinInfo);
  AddRgSymRTF('wpbinname', 0, FALSE, kwdDest, idestWPBinName);
  AddRgSymRTF('wpbindata', 0, FALSE, kwdDest, idestWPBinData);

  // ---------------------------------------------------------------------------
  AddRgSymRTF('tx', 0, FALSE, kwdProp, ipropTabPos);
  AddRgSymRTF('tb', 0, FALSE, kwdProp, ipropTabPosBar);
  AddRgSymRTF('tqr', Integer(tkRight), TRUE, kwdProp, ipropTabKind);
  AddRgSymRTF('tqc', Integer(tkCenter), TRUE, kwdProp, ipropTabKind);
  AddRgSymRTF('tqdec', Integer(tkDecimal), TRUE, kwdProp, ipropTabKind);
  AddRgSymRTF('tldot', Integer(tkDots), TRUE, kwdProp, ipropTabFill);
  AddRgSymRTF('tlmdot', Integer(tkMDots), TRUE, kwdProp, ipropTabFill);
  AddRgSymRTF('tlhyph', Integer(tkHyphen), TRUE, kwdProp, ipropTabFill);
  AddRgSymRTF('tlul', Integer(tkUnderline), TRUE, kwdProp, ipropTabFill);
  AddRgSymRTF('tlth', Integer(tkTHyphen), TRUE, kwdProp, ipropTabFill);
  AddRgSymRTF('tleq', Integer(tkEqualSig), TRUE, kwdProp, ipropTabFill);
  {*}AddRgSymRTF('tlarrow', Integer(tkArrow), TRUE, kwdProp, ipropTabFill);
  {*}AddRgSymRTF('tbxcolor', 0, FALSE, kwdProp, ipropTabColor);
 // ---------------------------------------------------------------------------
{$IFNDEF IGNORE_TBLTAGS}
  {*}AddRgSymRTF('tblstart', 0, FALSE, kwdProp, ipropTableStart);
  {*}AddRgSymRTF('tblend', 0, FALSE, kwdProp, ipropTableEnd);
{$ENDIF}
  AddRgSymRTF('row', 0, FALSE, kwdProp, ipropTableRowEnd);
  AddRgSymRTF('cell', 0, FALSE, kwdProp, ipropTableCellEnd);
  AddRgSymRTF('intbl', 0, FALSE, kwdProp, ipropInTable);
  AddRgSymRTF('nestrow', 0, FALSE, kwdProp, ipropNestTableRow);
  AddRgSymRTF('nestcell', 0, FALSE, kwdProp, ipropNestTableCell);
  AddRgSymRTF('nesttableprops', 0, FALSE, kwdDest, idestNestTableDef);
  AddRgSymRTF('nonesttables', 0, FALSE, kwdDest, idestNonesttables);
  AddRgSymRTF('itap', 0, FALSE, kwdProp, ipropNestTableDepth);
 // ---------------------------------------------------------------------------
  AddRgSymRTF('trowd', 0, FALSE, kwdProp, ipropTableRowDefaults);
  AddRgSymRTF('tcelld', 0, FALSE, kwdProp, ipropTableCellDefaults);
  AddRgSymRTF('irow', 0, FALSE, kwdProp, ipropRowIndex);
  AddRgSymRTF('irowband', 0, FALSE, kwdProp, ipropRowBandIndex);
  AddRgSymRTF('lastrow', 0, FALSE, kwdProp, ipropIsLastRow);

  AddRgSymRTF('trleft', 0, FALSE, kwdProp, iproptrleft);
  AddRgSymRTF('cellx', 0, FALSE, kwdProp, ipropTableCellX);
  AddRgSymRTF('clmgf', 0, FALSE, kwdProp, ipropTable_clmgf);
  AddRgSymRTF('clmrg', 0, FALSE, kwdProp, ipropTable_clmrg);
  AddRgSymRTF('clvmgf', 0, FALSE, kwdProp, ipropTable_clvmgf);
  AddRgSymRTF('clvmrg', 0, FALSE, kwdProp, ipropTable_clvmrg);

  AddRgSymRTF('clwwidth', 0, FALSE, kwdProp, ipropTable_clwWidth);
  AddRgSymRTF('clftswidth', 0, FALSE, kwdProp, ipropTable_clwWidthF);

  AddRgSymRTF('trftswidth', 0, FALSE, kwdProp, ipropTable_trftsWidth);
  AddRgSymRTF('trwwidth', 0, FALSE, kwdProp, ipropTable_trwWidth);
 // ---------------------------------------------------------------------------
  AddRgSymRTF('trgaph', 0, FALSE, kwdProp, iproptrgaph);
  AddRgSymRTF('tbllkborder', WPRDFLAG_TAborder, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkshading', WPRDFLAG_TAshading, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkfont', WPRDFLAG_TAfont, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkcolor', WPRDFLAG_TAcolor, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkbestfit', WPRDFLAG_TAbestfit, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkhdrrows', WPRDFLAG_TAhdrrows, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllklastrow', WPRDFLAG_TAlastrow, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllkhdrcols', WPRDFLAG_TAhdrcols, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('tbllklastcol', WPRDFLAG_TAlastcol, TRUE, kwdProp, iproptableflags);
  AddRgSymRTF('trhdr', WPRDFLAG_RIsHeader, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('trhidden', WPRDFLAG_RIsCollapsed, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('trfooter', WPRDFLAG_RIsFooter, TRUE, kwdProp, iproprowflags); // IS FOOTER #RTF
  AddRgSymRTF('trkeep', WPRDFLAG_RKeep, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('trkeepfollow', WPRDFLAG_RKeepN, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('trautofit', 0, FALSE, kwdProp, iproprowAutoFit); //WPRDFLAG_RAutoFit
  AddRgSymRTF('taprtl', WPRDFLAG_RTL, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('rtlrow', WPRDFLAG_RTL, TRUE, kwdProp, iproprowflags);
  AddRgSymRTF('ltrrow', WPRDFLAG_LTR, TRUE, kwdProp, iproprowflags); {not op!}
  AddRgSymRTF('trpaddfl', 0, FALSE, kwdProp, ipropTable_trpaddfl); //WPRDFLAG_RUse_trpaddl
  AddRgSymRTF('trpaddft', 0, FALSE, kwdProp, ipropTable_trpaddft); //WPRDFLAG_RUse_trpaddt
  AddRgSymRTF('trpaddfr', 0, FALSE, kwdProp, ipropTable_trpaddfr); //WPRDFLAG_RUse_trpaddr
  AddRgSymRTF('trpaddfb', 0, FALSE, kwdProp, ipropTable_trpaddfb); //WPRDFLAG_RUse_trpaddb
  AddRgSymRTF('trspdfl', 0, FALSE, kwdProp, ipropTable_trspdfl); //WPRDFLAG_RUse_trspdl
  AddRgSymRTF('trspdft', 0, FALSE, kwdProp, ipropTable_trspdft); //WPRDFLAG_RUse_trspdt
  AddRgSymRTF('trspdfr', 0, FALSE, kwdProp, ipropTable_trspdfr); //WPRDFLAG_RUse_trspdr
  AddRgSymRTF('trspdfb', 0, FALSE, kwdProp, ipropTable_trspdfb); //WPRDFLAG_RUse_trspdb
  AddRgSymRTF('trql', 0, TRUE, kwdProp, iproprowalign);
  AddRgSymRTF('trqc', 1, TRUE, kwdProp, iproprowalign);
  AddRgSymRTF('trqr', 2, TRUE, kwdProp, iproprowalign);
  AddRgSymRTF('trrh', 0, FALSE, kwdProp, iproprowheight);
  AddRgSymRTF('trpaddl', 0, FALSE, kwdProp, ipropTable_trpaddl);
  AddRgSymRTF('trpaddt', 0, FALSE, kwdProp, ipropTable_trpaddt);
  AddRgSymRTF('trpaddr', 0, FALSE, kwdProp, ipropTable_trpaddr);
  AddRgSymRTF('trpaddb', 0, FALSE, kwdProp, ipropTable_trpaddb);
  AddRgSymRTF('trspdl', 0, FALSE, kwdProp, ipropTable_trspdl);
  AddRgSymRTF('trspdt', 0, FALSE, kwdProp, ipropTable_trspdt);
  AddRgSymRTF('trspdr', 0, FALSE, kwdProp, ipropTable_trspdr);
  AddRgSymRTF('trspdb', 0, FALSE, kwdProp, ipropTable_trspdb);
 // ---------------------------------------------------------------------------
  AddRgSymRTF('clpadfl', 0, FALSE, kwdProp, ipropTable_clpadfl); //WPRDFLAG_Use_clpadl
  AddRgSymRTF('clpadft', 0, FALSE, kwdProp, ipropTable_clpadft); //WPRDFLAG_Use_clpadt
  AddRgSymRTF('clpadfr', 0, FALSE, kwdProp, ipropTable_clpadfr); //WPRDFLAG_Use_clpadr
  AddRgSymRTF('clpadfb', 0, FALSE, kwdProp, ipropTable_clpadfb); //WPRDFLAG_Use_clpadb
  AddRgSymRTF('clpadl', 0, FALSE, kwdProp, ipropTable_clpadl);
  AddRgSymRTF('clpadt', 0, FALSE, kwdProp, ipropTable_clpadt);
  AddRgSymRTF('clpadr', 0, FALSE, kwdProp, ipropTable_clpadr);
  AddRgSymRTF('clpadb', 0, FALSE, kwdProp, ipropTable_clpadb);
  AddRgSymRTF('clvertalt', Integer(paralVertTop), true, kwdProp, ipropVertJust);
  AddRgSymRTF('clvertalc', Integer(paralVertCenter), true, kwdProp, ipropVertJust);
  AddRgSymRTF('clvertalb', Integer(paralVertBottom), true, kwdProp, ipropVertJust);
  AddRgSymRTF('clvertalj', Integer(paprVertJustified), true, kwdProp, ipropVertJust); {#RTF!}
  // ---------------------------------------------------------------------------
  AddRgSymRTF('box', 0, false, kwdProp, ipropBorderStartBOX);
  // 0=L 1=T 2=R 3=B 4=IV, 5=IH, 6=DLB, 7=DLR, 8=BAR (vgl. TOneBorderType)
  AddRgSymRTF('brdrl', 0, TRUE, kwdProp, ipropBorderStartDef); // Pars
  AddRgSymRTF('brdrt', 1, TRUE, kwdProp, ipropBorderStartDef);
  AddRgSymRTF('brdrr', 2, TRUE, kwdProp, ipropBorderStartDef);
  AddRgSymRTF('brdrb', 3, TRUE, kwdProp, ipropBorderStartDef);
  AddRgSymRTF('brdrbar', 8, TRUE, kwdProp, ipropBorderStartDef);

  AddRgSymRTF('trbrdrl', 0, TRUE, kwdProp, ipropBorderStartDefROW); // ROWS
  AddRgSymRTF('trbrdrt', 1, TRUE, kwdProp, ipropBorderStartDefROW);
  AddRgSymRTF('trbrdrr', 2, TRUE, kwdProp, ipropBorderStartDefROW);
  AddRgSymRTF('trbrdrb', 3, TRUE, kwdProp, ipropBorderStartDefROW);
  AddRgSymRTF('trbrdrv', 4, TRUE, kwdProp, ipropBorderStartDefROW);
  AddRgSymRTF('trbrdrh', 5, TRUE, kwdProp, ipropBorderStartDefROW);

  AddRgSymRTF('clbrdrl', 0, TRUE, kwdProp, ipropBorderStartDefCELL); // CELLS
  AddRgSymRTF('clbrdrt', 1, TRUE, kwdProp, ipropBorderStartDefCELL);
  AddRgSymRTF('clbrdrr', 2, TRUE, kwdProp, ipropBorderStartDefCELL);
  AddRgSymRTF('clbrdrb', 3, TRUE, kwdProp, ipropBorderStartDefCELL);
  AddRgSymRTF('cldglu', 6, TRUE, kwdProp, ipropBorderStartDefCELL);
  AddRgSymRTF('cldgll', 7, TRUE, kwdProp, ipropBorderStartDefCELL);

  AddRgSymRTF('tsbrdrl', 0, TRUE, kwdProp, ipropBorderStartDefTS); // TABLE STYLES
  AddRgSymRTF('tsbrdrt', 1, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrr', 2, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrb', 3, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrv', 4, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrh', 5, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrdgl', 6, TRUE, kwdProp, ipropBorderStartDefTS);
  AddRgSymRTF('tsbrdrdgr', 7, TRUE, kwdProp, ipropBorderStartDefTS);
  // ---------------------------------------------------------------------------
  AddRgSymRTF('brdrs', WPBRD_SINGLE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtbl', WPBRD_NONE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdnil', WPBRD_NONE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrnone', WPBRD_NONE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrth', WPBRD_DOUBLEW, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrsh', WPBRD_SHADOW, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdb', WPBRD_DOUBLE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdot', WPBRD_DOTTED, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdash', WPBRD_DASHED, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrhair', WPBRD_HAIRLINE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrinset', WPBRD_INSET, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdashsm', WPBRD_DASHEDS, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdashd', WPBRD_DOTDASH, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdashdd', WPBRD_DOTDOTDASH, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdroutset', WPBRD_OUTSET, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtriple', WPBRD_TRIPPLE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthsg', WPBRD_THIKTHINS, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrthtnsg', WPBRD_THINTHICKS, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthtnsg', WPBRD_THINTHICKTHINS, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthmg', WPBRD_THICKTHIN, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrthtnmg', WPBRD_THINTHIK, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthtnmg', WPBRD_THINTHICKTHIN, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthlg', WPBRD_THICKTHINL, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrthtnlg', WPBRD_THINTHICKL, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrtnthtnlg', WPBRD_THINTHICKTHINL, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrwavy', WPBRD_WAVY, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrwavydb', WPBRD_DBLWAVY, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrdashdotstr', WPBRD_STRIPED, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdremboss', WPBRD_EMBOSSED, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrengrave', WPBRD_ENGRAVE, TRUE, kwdProp, ipropBorderType);
  AddRgSymRTF('brdrframe', WPBRD_FRAME, TRUE, kwdProp, ipropBorderType);
  // ---------------------------------------------------------------------------
  AddRgSymRTF('brdrw', 0, false, kwdProp, ipropBorderWidth);
  AddRgSymRTF('brsp', 0, false, kwdProp, ipropBorderSpace);
  AddRgSymRTF('brdrcf', 0, false, kwdProp, ipropBorderColor);
 // ---------------------------------------------------------------------------
 // Shading
  AddRgSymRTF('shading', 0, FALSE, kwdProp, ipropShading);
  AddRgSymRTF('cbpat', 0, FALSE, kwdProp, ipropBColor);
  AddRgSymRTF('cfpat', 0, FALSE, kwdProp, ipropFColor);
  AddRgSymRTF('bgbnil', -1, true, kwdProp, ipropBackgroundPattern); //#RTF
  AddRgSymRTF('bgbdiag', WPSHAD_bdiag, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgcross', WPSHAD_cross, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdcross', WPSHAD_dcross, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkbdiag', WPSHAD_dkbdiag, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkcross', WPSHAD_dkcross, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkdcross', WPSHAD_dkdcross, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkfdiag', WPSHAD_dkfdiag, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkhor', WPSHAD_dkhor, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgdkvert', WPSHAD_dkvert, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgfdiag', WPSHAD_fdiag, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bghoriz', WPSHAD_horiz, true, kwdProp, ipropBackgroundPattern);
  AddRgSymRTF('bgvert', WPSHAD_vert, true, kwdProp, ipropBackgroundPattern);
  // Cell Shading
  AddRgSymRTF('clcbpat', 0, FALSE, kwdProp, ipropBColorCELL);
  AddRgSymRTF('clcfpat', 0, FALSE, kwdProp, ipropFColorCELL);
  AddRgSymRTF('clshdng', 0, FALSE, kwdProp, ipropShadingCELL);
  AddRgSymRTF('clshdnil', -1, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgbdiag', WPSHAD_bdiag, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgcross', WPSHAD_cross, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdcross', WPSHAD_dcross, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkbdiag', WPSHAD_dkbdiag, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkcross', WPSHAD_dkcross, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkdcross', WPSHAD_dkdcross, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkfdiag', WPSHAD_dkfdiag, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkhor', WPSHAD_dkhor, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgdkvert', WPSHAD_dkvert, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgfdiag', WPSHAD_fdiag, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbghoriz', WPSHAD_horiz, true, kwdProp, ipropBackgroundPatternCELL);
  AddRgSymRTF('clbgvert', WPSHAD_vert, true, kwdProp, ipropBackgroundPatternCELL);
  // Table Styles - Shading
  AddRgSymRTF('clcbpatraw', 0, FALSE, kwdProp, ipropBColorTS);
  AddRgSymRTF('clcfpatraw', 0, FALSE, kwdProp, ipropFColorTS);
  AddRgSymRTF('clshdngraw', 0, FALSE, kwdProp, ipropShadingTS);
  AddRgSymRTF('clshdrawnil', -1, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgbdiag', WPSHAD_bdiag, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgcross', WPSHAD_cross, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdcross', WPSHAD_dcross, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkbdiag', WPSHAD_dkbdiag, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkcross', WPSHAD_dkcross, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkdcross', WPSHAD_dkdcross, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkfdiag', WPSHAD_dkfdiag, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkhor', WPSHAD_dkhor, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgdkvert', WPSHAD_dkvert, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgfdiag', WPSHAD_fdiag, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbghoriz', WPSHAD_horiz, true, kwdProp, ipropBackgroundPatternTS);
  AddRgSymRTF('rawclbgvert', WPSHAD_vert, true, kwdProp, ipropBackgroundPatternTS);

  // ---------------------------------------------------------------------------
  AddRgSymRTF('deftab', 720, FALSE, kwdProp, ipropDeftab);

  AddRgSymRTF('keepn', 0, true, kwdProp, ipropKeepn);
  {*}AddRgSymRTF('wpkeepn', 1, true, kwdProp, ipropKeepn); // for table (only this cell!)
  AddRgSymRTF('keep', 1, true, kwdProp, ipropKeep);
  // Special Char --------------------------------------
  AddRgSymRTF('{', 0, FALSE, kwdChar, Integer('{'));
  AddRgSymRTF('}', 0, FALSE, kwdChar, Integer('}'));
  AddRgSymRTF('\', 0, FALSE, kwdChar, Integer('\'));
  AddRgSymRTF('-', 0, FALSE, kwdProp, ipropHyphen);
  AddRgSymRTF('~', 0, FALSE, kwdChar, 160);
  AddRgSymRTF('ldblquote', 0, FALSE, kwdChar, Integer('"'));
  AddRgSymRTF('rdblquote', 0, FALSE, kwdChar, Integer('"'));
  AddRgSymRTF('lquote', 0, FALSE, kwdChar, 39);
  AddRgSymRTF('rquote', 0, FALSE, kwdChar, 39);
  AddRgSymRTF('endash', 1, TRUE, kwdProp, ipropSymbol);
  AddRgSymRTF('emdash', 2, TRUE, kwdProp, ipropSymbol);
  AddRgSymRTF('chftn', 0, FALSE, kwdProp, ipropchftn);
  AddRgSymRTF('bullet', 3, TRUE, kwdProp, ipropSymbol);
  AddRgSymRTF('_', 0, FALSE, kwdChar, $A0);
  AddRgSymRTF('enspace', 0, FALSE, kwdChar, $A0);
  AddRgSymRTF('emspace', 0, FALSE, kwdChar, $A0);
  AddRgSymRTF(#$0A, 0, FALSE, kwdChar, $0A);
  AddRgSymRTF(#$0D, 0, FALSE, kwdChar, $0A);
  AddRgSymRTF('tab', 0, FALSE, kwdChar, $09);
  {*}AddRgSymRTF('wptab', 0, FALSE, kwdChar, 9); { Auto	Tab in tables  }
  AddRgSymRTF('line', 0, FALSE, kwdChar, 10);
  AddRgSymRTF('wptable', 0, FALSE, kwdDest, idestWPTableName);
  AddRgSymRTF('tblleft', 0, FALSE, kwdProp, ipropWPTableLeft);
  AddRgSymRTF('tblright', 0, FALSE, kwdProp, ipropWPTableRight);
  AddRgSymRTF('colortbl', 0, FALSE, kwdDest, idestColorTable);
  AddRgSymRTF('red', 0, FALSE, kwdProp, ipropColorRed);
  AddRgSymRTF('green', 0, FALSE, kwdProp, ipropColorGreen);
  AddRgSymRTF('blue', 0, FALSE, kwdProp, ipropColorBlue);
  // Page Format ---------------------------------------------------------------
  AddRgSymRTF('paperw', 12240, FALSE, kwdProp, ipropXaPage);
  AddRgSymRTF('paperh', 15480, FALSE, kwdProp, ipropYaPage);
  AddRgSymRTF('margl', 1800, FALSE, kwdProp, ipropXaLeft);
  AddRgSymRTF('margr', 1800, FALSE, kwdProp, ipropXaRight);
  AddRgSymRTF('margt', 1440, FALSE, kwdProp, ipropYaTop);
  AddRgSymRTF('margb', 1440, FALSE, kwdProp, ipropYaBottom);
  AddRgSymRTF('margh', 254, FALSE, kwdProp, ipropYaMarginHeader); //WPT_COMP
  AddRgSymRTF('margf', 254, FALSE, kwdProp, ipropYaMarginFooter); //WPT_COMP
  AddRgSymRTF('headery', 254, FALSE, kwdProp, ipropYaMarginHeader);
  AddRgSymRTF('footery', 254, FALSE, kwdProp, ipropYaMarginFooter);
  AddRgSymRTF('pgwsxn', 12240, FALSE, kwdProp, ipropXaPage);
  AddRgSymRTF('pghsxn', 15480, FALSE, kwdProp, ipropYaPage);
  AddRgSymRTF('marglsxn', 1800, FALSE, kwdProp, ipropXaLeft);
  AddRgSymRTF('margrsxn', 1800, FALSE, kwdProp, ipropXaRight);
  AddRgSymRTF('margtsxn', 1440, FALSE, kwdProp, ipropYaTop);
  AddRgSymRTF('margbsxn', 1440, FALSE, kwdProp, ipropYaBottom);
 
  AddRgSymRTF('brdrart', 0, TRUE, kwdProp, ipropPageFrameArt);
  AddRgSymRTF('facingp', 1, TRUE, kwdProp, ipropFacingp);
  AddRgSymRTF('landscape', 1, TRUE, kwdProp, ipropLandscape);
  AddRgSymRTF('lndscpsxn', 1, TRUE, kwdProp, ipropLandscape);
  AddRgSymRTF('titlepg', 1, TRUE, kwdProp, ipropTitlePg);
  AddRgSymRTF('margmirror', 1, TRUE, kwdProp, ipropMarginMirror);
  {*}AddRgSymRTF('sectionpg', 1, TRUE, kwdProp, ipropSelSectionHdr);
  {*}AddRgSymRTF('wpresoutl', 1, TRUE, kwdProp, ipropSelResetOutl);
  // Page Numbering
  AddRgSymRTF('pgnx', 0, FALSE, kwdProp, ipropPgnX);
  AddRgSymRTF('pgny', 0, FALSE, kwdProp, ipropPgnY);
  AddRgSymRTF('pgndec', pgDec, TRUE, kwdProp, ipropPgnFormat);
  AddRgSymRTF('pgnucrm', pgURom, TRUE, kwdProp, ipropPgnFormat);
  AddRgSymRTF('pgnlcrm', pgLRom, TRUE, kwdProp, ipropPgnFormat);
  AddRgSymRTF('pgnucltr', pgULtr, TRUE, kwdProp, ipropPgnFormat);
  AddRgSymRTF('pgnlcltr', pgLLtr, TRUE, kwdProp, ipropPgnFormat);
  AddRgSymRTF('pgnrestart', pgRestartNumber, TRUE, kwdProp, ipropPgnFormat);
  // ---------------------------------------------------------------------------
  AddRgSymRTF('page', 0, FALSE, kwdProp, ipropNewPage);
  AddRgSymRTF('pagebb', 0, FALSE, kwdProp, ipropNewPageB);
  AddRgSymRTF('sect', 0, FALSE, kwdProp, ipropNewSection);
  AddRgSymRTF('wpignpar', 0, FALSE, kwdProp, ipropwpignpar);
  AddRgSymRTF('wppage', 0, FALSE, kwdProp, ipropwppage);
  AddRgSymRTF('pgnstart', 1, FALSE, kwdProp, ipropPgnStart);
  AddRgSymRTF('sbknone', 3, TRUE, kwdProp, ipropSectionBreakMode);
  AddRgSymRTF('sbkcol', 4, TRUE, kwdProp, ipropSectionBreakMode);
  AddRgSymRTF('sbkpage', 0, TRUE, kwdProp, ipropSectionBreakMode);
  AddRgSymRTF('sbkeven', 1, TRUE, kwdProp, ipropSectionBreakMode);
  AddRgSymRTF('sbkodd', 2, TRUE, kwdProp, ipropSectionBreakMode);

  // ---------------------------------------------------------------------------
  AddRgSymRTF('stylesheet', 0, FALSE, kwdDest, idestStyleSheet);
  AddRgSymRTF('additive', 0, false, kwdProp, ipropadditive);
  AddRgSymRTF('sbasedon', 0, false, kwdProp, ipropsbasedOn);
{*}AddRgSymRTF('sdefault', 1, false, kwdProp, ipropsIsDefault);
  AddRgSymRTF('snext', 0, false, kwdProp, ipropsnext);
  AddRgSymRTF('autoupd', 0, false, kwdProp, ipropautoupd);
  AddRgSymRTF('shidden', 0, false, kwdProp, ipropshidden);
  AddRgSymRTF('s', 0, false, kwdProp, ipropS);
  AddRgSymRTF('cs', 0, false, kwdProp, ipropCS);
  AddRgSymRTF('ds', 0, false, kwdProp, ipropDS);
  AddRgSymRTF('fn', 0, false, kwdProp, ipropFN);
 // ---------------------------------------------------------------------------
  AddRgSymRTF('listtable', 0, FALSE, kwdDest, idestListTable);
  AddRgSymRTF('list', 0, FALSE, kwdDest, idestList);
  AddRgSymRTF('listid', 0, FALSE, kwdProp, ipropListID); // either template ID or override ID
  AddRgSymRTF('listtemplateid', 0, FALSE, kwdProp, ipropListTemplateID);
  AddRgSymRTF('listsimple', 0, FALSE, kwdProp, ipropListSimple);
  AddRgSymRTF('listhybrid', 0, TRUE, kwdProp, ipropListSimple);
  AddRgSymRTF('listrestarthdn', 0, FALSE, kwdProp, ipropListRestartSection);
  AddRgSymRTF('listname', 0, FALSE, kwdDest, idestListName);
  AddRgSymRTF('liststyleid', 0, FALSE, kwdProp, ipropListStyleID); // Identifies this list as a list style definition
  AddRgSymRTF('liststylename', 0, FALSE, kwdDest, idestListStyleName); // Identifies this list as a list style definition
 // ---------------------------------------------------------------------------
  AddRgSymRTF('listlevel', 0, FALSE, kwdDest, idestListlevel);
  AddRgSymRTF('levelstartat', 0, FALSE, kwdProp, ipropLevelStartAt);
  AddRgSymRTF('levelnfc', 0, FALSE, kwdProp, ipropLevelnfc); // Specifies the number type for the level:
  AddRgSymRTF('leveljc', 0, FALSE, kwdProp, ipropLeveljc); // Level Justification
  AddRgSymRTF('levelnfcn', 0, FALSE, kwdProp, ipropLevelnfc); // Specifies the number type for the level:
  AddRgSymRTF('leveljcn', 0, FALSE, kwdProp, ipropLeveljc); // Level Justification
  AddRgSymRTF('levelold', 0, FALSE, kwdProp, ipropLevelOld); // 1 = old Level
  AddRgSymRTF('levelprev', 0, FALSE, kwdProp, ipropLevelprev_O); // (Converted) 1 to use prev   requires old list
  AddRgSymRTF('levelprevspace', 0, FALSE, kwdProp, ipropLevelprevSpace_O); // (Converted) 1 to use prev   requires old list
  AddRgSymRTF('levelindent', 0, FALSE, kwdProp, ipropLevelindent_O); // (Converted)  requires old list
  AddRgSymRTF('levelspace', 0, FALSE, kwdProp, ipropLevelspace_O); // (Converted)  requires old list
  AddRgSymRTF('leveltext', 0, FALSE, kwdDest, idestLevelText); // Text, first is length, then 01 02 as numbers
  AddRgSymRTF('levelnumbers', 0, FALSE, kwdDest, idestLevelNumbers); // offset of numbers in leveltext
  AddRgSymRTF('levelfollow', 0, FALSE, kwdProp, ipropLevelFollow); //Specifies which character follows the level text:
  AddRgSymRTF('levellegal', 0, FALSE, kwdProp, ipropLevelLegal); // Convert to arabic ?
  AddRgSymRTF('levelnorestart', 0, FALSE, kwdProp, ipropLevelNoRestart); // don't restart
  AddRgSymRTF('levelpicture', 0, FALSE, kwdProp, ipropLevelPicture); // don't restart
 // ---------------------------------------------------------------------------
  AddRgSymRTF('listoverridetable', 0, FALSE, kwdDest, idestListOverride); // Text, first is length, then 01 02 as numbers
  AddRgSymRTF('listoverride', 0, FALSE, kwdDest, idestListOverrideItem);
  AddRgSymRTF('listoverridecount', 0, FALSE, kwdProp, ipropListOverrideCount);
  AddRgSymRTF('levelid', 0, FALSE, kwdProp, ipropListID); // either template ID or override ID
  AddRgSymRTF('outlinelevel', 0, FALSE, kwdProp, ipropOutlineLevel);
 // ---------------------------------------------------------------------------
  AddRgSymRTF('ls', 0, FALSE, kwdProp, ipropListNr); // in override table NR - in text
  AddRgSymRTF('ilvl', 0, FALSE, kwdProp, ipropListLevel); // Level in list defined by \ls
  AddRgSymRTF('listtext', 0, FALSE, kwdDest, idestListText);
  //  AddRgSymRTF('s', 0, false, kwdProp, ipropOutlineStyle); { style of numbering }
  // The reader simply maps lsN to certain templates
  // Overidden list styles are not supported
  AddRgSymRTF('pntext', 0, FALSE, kwdDest, idestPNText);
  AddRgSymRTF('pntxta', 0, FALSE, kwdDest, idestPNTextA);
  AddRgSymRTF('pntxtb', 0, FALSE, kwdDest, idestPNTextB);
  AddRgSymRTF('pn', 0, FALSE, kwdDest, idestPN);
  AddRgSymRTF('pnseclvl', 0, FALSE, kwdDest, ipropPNLevel);
  AddRgSymRTF('pnlvl', 0, FALSE, kwdProp, ipropPNLevel);
  AddRgSymRTF('pnlvlbody', 10, TRUE, kwdProp, ipropPNLevel); // Simple

  AddRgSymRTF('pnlvlblt', WPNUM_BULLET, TRUE, kwdProp, ipropPNStyle); { *** }
  AddRgSymRTF('pndec', WPNUM_ARABIC, TRUE, kwdProp, ipropPNStyle); { 123 }
  AddRgSymRTF('pnucltr', WPNUM_UP_LETTER, TRUE, kwdProp, ipropPNStyle); { ABC}
  AddRgSymRTF('pnlcltr', WPNUM_LO_LETTER, TRUE, kwdProp, ipropPNStyle); { abc}
  AddRgSymRTF('pnucrm', WPNUM_UP_ROMAN, TRUE, kwdProp, ipropPNStyle); { I II	III }
  AddRgSymRTF('pnlcrm', WPNUM_LO_ROMAN, TRUE, kwdProp, ipropPNStyle); { i ii	iii }
  AddRgSymRTF('pnord', WPNUM_LO_ORDINAL, TRUE, kwdProp, ipropPNStyle); { 1st, 2nd .. }
  AddRgSymRTF('pnordt', WPNUM_ORDINAL_TEXT, TRUE, kwdProp, ipropPNStyle); { First, Second, Third }
  AddRgSymRTF('pncard', WPNUM_TEXT, TRUE, kwdProp, ipropPNStyle); { One, Two, Three }
  AddRgSymRTF('pncnum', WPNUM_CIRCLE, TRUE, kwdProp, ipropPNStyle); { circle }

  AddRgSymRTF('pnindent', 0, FALSE, kwdProp, ipropPNIndent); { indent }
  AddRgSymRTF('pnf', 0, FALSE, kwdProp, ipropPNFont); {	bullet font }
  AddRgSymRTF('pnfs', 0, FALSE, kwdProp, ipropPNFontSize); { font size }
  AddRgSymRTF('pnprev', WPNUM_FLAGS_USEPREV, TRUE, kwdProp, ipropPNFlag); { WPAT_NumberFLAGS }
  AddRgSymRTF('pnhang', WPNUM_FLAGS_HANG, TRUE, kwdProp, ipropPNFlag); { WPAT_NumberFLAGS }
  AddRgSymRTF('pnlvlcont', WPNUM_NumberSKIP, TRUE, kwdProp, ipropPNParFlag); { WPAT_NumberFLAGS }
  AddRgSymRTF('pnstart', 1, FALSE, kwdProp, ipropPNStart); { PNSTART }
 // ---------------------------------------------------------------------------

  AddRgSymRTF('fonttbl', 0, FALSE, kwdDest, idestFonttbl);

  AddRgSymRTF('wpnr', 0, false, kwdProp, ipropWPNR); { automatic numbering text	}
  AddRgSymRTF('wpsnr', 0, false, kwdProp, ipropWPNRstyle);
  { type of the numbering }

  AddRgSymRTF('fcharset', 0, false, kwdProp, ipropFontCharset);

  { level of numbering }
  AddRgSymRTF('buptim', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('creatim', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('private1', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('revtim', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('ftncn', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('ftnsep', 0, FALSE, kwdDest, idestSkip);
  AddRgSymRTF('ftnsepc', 0, FALSE, kwdDest, idestSkip);

  // Header and footer
  AddRgSymRTF('header', Integer(wpraOnAllPages), TRUE, kwdDest, idestHeader);
  AddRgSymRTF('headerf', Integer(wpraOnFirstPage), TRUE, kwdDest, idestHeader);
  AddRgSymRTF('headerl', Integer(wpraOnEvenPages), TRUE, kwdDest, idestHeader);
  AddRgSymRTF('headerr', Integer(wpraOnOddPages), TRUE, kwdDest, idestHeader);
  {*}AddRgSymRTF('wpheader', 0, false, kwdDest, idestHeader);
  AddRgSymRTF('footer', Integer(wpraOnAllPages), TRUE, kwdDest, idestFooter);
  AddRgSymRTF('footerf', Integer(wpraOnFirstPage), TRUE, kwdDest, idestFooter);
  AddRgSymRTF('footerl', Integer(wpraOnEvenPages), TRUE, kwdDest, idestFooter);
  AddRgSymRTF('footerr', Integer(wpraOnOddPages), TRUE, kwdDest, idestFooter);
  {*}AddRgSymRTF('wpfooter', 0, false, kwdDest, idestFooter);
  AddRgSymRTF('wpelementname', 0, false, kwdDest, idestWPElementName);

  AddRgSymRTF('rtlpar', 1, TRUE, kwdProp, ipropRtlLtrPar);
  AddRgSymRTF('ltrpar', 0, TRUE, kwdProp, ipropRtlLtrPar);

  AddRgSymRTF('inspnt', 0, FALSE, kwdProp, ipropInsertPoint); {	# RTF	}
  AddRgSymRTF('inaut', 1, FALSE, kwdProp, ipropAutomatic); { # RTF	}
  AddRgSymRTF('wprtf', 1, FALSE, kwdProp, iproprtfcode); {	# RTF }

  AddRgSymRTF('wpformatted', 0, FALSE, kwdProp, ipropPreformatted); { #	RTF	}
  AddRgSymRTF('wpparhide', 1, TRUE, kwdProp, ipropParHidden); {	# RTF	}
  AddRgSymRTF('wpreadonly', 1, TRUE, kwdProp, ipropwpreadonly); {	# RTF	}

  AddRgSymRTF('wpparnowwrap', 1, TRUE, kwdProp, ipropNoWordWrap); { # RTF - obsolete	}
  AddRgSymRTF('nowwrap', 1, TRUE, kwdProp, ipropNoWordWrap); { No word wrapping	}

  // AddRgSymRTF('wpnoparlines', 1, true, kwdProp, ipropParProperty);   OBSOLETE
  AddRgSymRTF('wpparprot', 2, true, kwdProp, ipropParProperty);
  AddRgSymRTF('wpmergestart', 3, true, kwdProp, ipropParProperty);
  AddRgSymRTF('wpmergeend', 4, true, kwdProp, ipropParProperty);
  AddRgSymRTF('wpmergepar', 0, FALSE, kwdDest, idestMergePar);
  AddRgSymRTF('wpmergevar', 0, FALSE, kwdDest, idestMergeVar);
  AddRgSymRTF('wpbackbmp', 0, FALSE, kwdDest, idestBackgroundImage);
  // AddRgSymRTF('wplin', 0, FALSE, kwdProp, ipropLineHeight); {# RTF - obsolete }
  // AddRgSymRTF('wpnpage', 0, FALSE, kwdProp, ipropAutoPageBreak); {# RTF - obsolete }

  AddRgSymRTF('wpparname', 0, FALSE, kwdDest, idestParName); {# RTF}
  AddRgSymRTF('wpcellname', 0, FALSE, kwdDest, idestCellName); {# RTF}
  AddRgSymRTF('wpcellfrm', 0, FALSE, kwdProp, ipropCellFormat); {# RTF}
  AddRgSymRTF('wpcellcom', 0, FALSE, kwdDest, idestCellCommand); {# RTF}

{*}AddRgSymRTF('toc', 0, FALSE, kwdProp, ipropToclevel);
  {*}AddRgSymRTF('wplevel', 0, FALSE, kwdProp, ipropXlevel);
  {*}AddRgSymRTF('wpspecialhf', 0, FALSE, kwdProp, ipropWpspecialhf);
  {*}AddRgSymRTF('wpmaxpar', 0, FALSE, kwdProp, ipropMaxPar);

  // Drawing Objects (Shapes)
  {*}AddRgSymRTF('wpshppos', 0, FALSE, kwdProp, ipropwpshppos);
  AddRgSymRTF('shpinst', 0, FALSE, kwdDest, idestShpinst);
  AddRgSymRTF('shprslt', 0, FALSE, kwdDest, idestShprslt);
  AddRgSymRTF('shptxt', 0, FALSE, kwdDest, idestShpText);
  AddRgSymRTF('sn', 0, FALSE, kwdDest, idestShpSN);
  AddRgSymRTF('sv', 0, FALSE, kwdDest, idestShpSV);
  AddRgSymRTF('sp', 0, FALSE, kwdDest, idestShpSP);
  AddRgSymRTF('do', 0, FALSE, kwdDest, idestDo);
  {*}AddRgSymRTF('wpprheadfoot', 0, FALSE, kwdProp, ipropWpprheadfoot);
  AddRgSymRTF('expndtw', 0, FALSE, kwdProp, ipropexpndtw);
  //V4.07
  AddRgSymRTF('chdate', 1, TRUE, kwdProp, ipropSpecialCharacters);
  AddRgSymRTF('chdpl', 2, TRUE, kwdProp, ipropSpecialCharacters);
  AddRgSymRTF('chdpa', 3, TRUE, kwdProp, ipropSpecialCharacters);
  AddRgSymRTF('chtime', 4, TRUE, kwdProp, ipropSpecialCharacters);
  AddRgSymRTF('chpgn', 5, TRUE, kwdProp, ipropSpecialCharacters);

  {*}AddRgSymRTF('wpoutlinebreak', 1, TRUE, kwdProp, ipropOutlinebreak);
  { Unicode Stuff }
  AddRgSymRTF('ansicpg', 1252, false, kwdProp, ipropUNIAnsiCodePage);
  AddRgSymRTF('uc', 2, false, kwdProp, ipropUNICharCount); // default 2
  AddRgSymRTF('u', 0, false, kwdProp, ipropReadUnicodeChar); // and skip uc chars!

  AddRgSymRTF('deff', 0, false, kwdProp, ipropDefaultFont); //->FDefaultFontNrDEFF

  // optional - TODO
  // AddRgSymRTF('upr', 0, false, kwdDest, idestReadANSITEXT); // ignored when reading unicode!
  // AddRgSymRTF('ud', 0, false, kwdDest, idestReadUNICODE); // following upr!
  // ---------------------------------------------------------------------------
end;

initialization

  PrepareRTFTags;

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.RegisterReader([TWPRTFReader]);
  end;

finalization

  UnPrepareRTFTags;

  if GlobalWPToolsCustomEnviroment <> nil then
  begin
    GlobalWPToolsCustomEnviroment.UnRegisterReader([TWPRTFReader]);
  end;

{$WARNINGS ON}
end.

