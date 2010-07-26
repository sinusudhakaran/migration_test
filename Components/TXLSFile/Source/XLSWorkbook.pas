unit XLSWorkbook;

{-----------------------------------------------------------------
    SM Software, 2000-2009

    TXLSFile v.4.0

    Rev history:
    2003-05-11  Boolean cell values supported
    2003-07-21  Rows and columns grouping added
    2003-12-13  TCell.Value can be WideString (Unicode values supported) 
    2004-01-25  A lot of useful Move/Copy/Delete/Clear methods added
    2004-02-21  The function to find used range added.
                The functions to find merged rectangle for cell added.
    2004-02-27  TSheets.Delete added
    2004-03-10  Save to HTML methods added
    2004-03-13  TSheets.Copy added    
    2004-03-14  Save to TXT methods added
    2004-04-09  PageSetup header and footer text separated to Left/Center/Right     
    2004-06-15  TCustomXLSItems.Destroy fixed
    2004-07-26  Using virtual font table
    2004-08-14  Add: Unicode font names support added    
    2004-10-23  Using virtual XF table
    2004-12-26  Add: cell indent
    2005-03-29  Fix: GetValueAsString fixed for percent formats  
    2005-05-21  Add: Freezing of sheets added
    2005-12-16  Add: RichFormat property
    2006-01-10  Add: TSheet.Name and TCell.Hyperlink are WideString
    2006-08-27  Add: TColumns.AutoFit
    2007-01-20  Fix: Use XFTable.DefaultIndex 
    2008-02-07  Fix: internal copy methods improved
    2008-02-23  Add: Sheet protection
    2008-04-04  Fix: TWorkbook.Clear fixed
    2008-05-05  Add: Link table
    2008-05-26  Add: Cell comments
                     TSheet.Visible flag
                     TXLSImages new add methods
    2008-06-11  GetValueAsString changed
    2008-10-12  Add: Hidden property to TRow, TColumn
    2008-11-04  Add: set values to a merged range changes one cell
    2009-02-15  Add: TSheet.ProtectWithMode

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses
  Classes, SysUtils, CFile, HList, XLSError, XLSFormat, XLSBase,
  XLSFormatStr, XLSRects, XLSFont, XLSFormatXF, XLSCellValidation,
  XLSLinkTable, XLSCellComment, XLSHyperlink, Streams;

type
  TCustomXLSItems = class;
  TCells = class;
  TSheet = class;
  TWorkbook = class;

  {TCommonWorkbookCellData}
  {common data for all cells in the workbook}
  TCommonWorkbookCellData = packed record
    FontTable: TVirtualFontTable;
    XFTable: TVirtualXFTable;
    FormatStringsTable: TFormatStrings;
    ProcessingState: TXLSProcessingState;
  end;
  PCommonWorkbookCellData = ^TCommonWorkbookCellData;

  {TCustomXLSItem}
  TCustomXLSItem = class
  protected
    FStored: Boolean;
    FOwner: TCustomXLSItems;
    FCommonCellData: PCommonWorkbookCellData;
    FXFTableIndex: Integer;

    {set format methods}
    procedure SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex); virtual;
    procedure SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex); virtual;
    procedure SetFillPatternBGColorRGB(AColorRGB: Integer); virtual;
    procedure SetFillPatternFGColorRGB(AColorRGB: Integer); virtual;
    procedure SetFillPattern(APattern: TXLPattern); virtual;
    procedure SetHAlign(AHalign: TCellHAlignment); virtual;
    procedure SetVAlign(AValign: TCellVAlignment); virtual;
    procedure SetMerged(AMerged: Boolean); virtual;
    procedure SetWrap(AWrap: Boolean); virtual;
    procedure SetRotation(ARotation: TCellRotation); virtual;
    procedure SetIndent(AIndent: Byte); virtual;
    procedure SetLocked(ALocked: Boolean); virtual;
    procedure SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex); virtual;
    procedure SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer); virtual;
    procedure SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle); virtual;
    procedure SetFormatStringIndex(AFormatStringIndex: Integer); virtual;
    procedure SetXFTableIndex(AXFIndex: Integer); 

    {get format methods}
    function GetFillPatternBGColorIndex: TXLColorIndex;
    function GetFillPatternFGColorIndex: TXLColorIndex;
    function GetFillPatternBGColorRGB: Integer;
    function GetFillPatternFGColorRGB: Integer;
    function GetFillPattern: TXLPattern;
    function GetHAlign: TCellHAlignment;
    function GetVAlign: TCellVAlignment;
    function GetMerged: Boolean;
    function GetWrap: Boolean;
    function GetRotation: TCellRotation;
    function GetIndent: Byte;
    function GetLocked: Boolean;
    function GetBorderColorIndex(Index: TCellBorderIndex): TXLColorIndex;
    function GetBorderColorRGB(Index: TCellBorderIndex): Integer;
    function GetBorderStyle(Index: TCellBorderIndex): TXLBorderStyle;
    function GetFormatStringIndex: Integer;

    { set font methods }
    procedure SetFontBold(AValue: Boolean); virtual;
    procedure SetFontItalic(AValue: Boolean); virtual;
    procedure SetFontUnderline(AValue: Boolean); virtual;
    procedure SetFontStrikeOut(AValue: Boolean); virtual;
    procedure SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle); virtual;
    procedure SetFontSSStyle(AValue: TXLFontSSStyle); virtual;
    procedure SetFontName(AValue: WideString); virtual;
    procedure SetFontColorIndex(AValue: TXLColorIndex); virtual;
    procedure SetFontColorRGB(AValue: Integer); virtual;
    procedure SetFontHeight(AValue: Word); virtual;
    procedure SetFontTableIndex(AIndex: Integer);
    { get font methods }
    function GetFontBold: Boolean;
    function GetFontItalic: Boolean;
    function GetFontUnderline: Boolean;
    function GetFontStrikeOut: Boolean;
    function GetFontUnderlineStyle: TXLFontUnderlineStyle;
    function GetFontSSStyle: TXLFontSSStyle;
    function GetFontName: WideString;
    function GetFontColorIndex: TXLColorIndex;
    function GetFontColorRGB: Integer;
    function GetFontHeight: Word;
    function GetFontTableIndex: Integer;

  public
    constructor Create(AOwner: TCustomXLSItems; const ACommonCellData: PCommonWorkbookCellData);
    destructor Destroy; override;

    {format properties}
    property BorderColorIndex[Index: TCellBorderIndex]: TXLColorIndex read GetBorderColorIndex write SetBorderColorindex;
    property BorderColorRGB[Index: TCellBorderIndex]: Integer read GetBorderColorRGB write SetBorderColorRGB;
    property BorderStyle[Index: TCellBorderIndex]: TXLBorderStyle read GetBorderStyle write SetBorderStyle;
    property FillPatternBGColorIndex: TXLColorIndex read GetFillPatternBGColorIndex
      write SetFillPatternBGColorIndex;
    property FillPatternFGColorIndex: TXLColorIndex read GetFillPatternFGColorIndex
      write SetFillPatternFGColorIndex;
    property FillPatternBGColorRGB: Integer read GetFillPatternBGColorRGB
      write SetFillPatternBGColorRGB;
    property FillPatternFGColorRGB: Integer read GetFillPatternFGColorRGB
      write SetFillPatternFGColorRGB;
    property FillPattern: TXLPattern read GetFillPattern write SetFillPattern;
    property FormatStringIndex: Integer read GetFormatStringIndex write SetFormatStringIndex;
    property HAlign: TCellHAlignment read GetHAlign write SetHAlign;
    property VAlign: TCellVAlignment read GetVAlign write SetVAlign;
    property Merged: Boolean read GetMerged write SetMerged;
    property Locked: Boolean read GetLocked write SetLocked;
    property Wrap: Boolean read GetWrap write SetWrap;
    property Rotation: TCellRotation read GetRotation write SetRotation;
    property Indent: Byte read GetIndent write SetIndent;

    { font properties }
    property FontBold: Boolean read GetFontBold write SetFontBold;
    property FontItalic: Boolean read GetFontItalic write SetFontItalic;
    property FontUnderline: Boolean read GetFontUnderline write SetFontUnderline;
    property FontStrikeOut: Boolean read GetFontStrikeOut write SetFontStrikeOut;
    property FontUnderlineStyle: TXLFontUnderlineStyle read GetFontUnderlineStyle write SetFontUnderlineStyle;
    property FontSSStyle: TXLFontSSStyle read GetFontSSStyle write SetFontSSStyle;
    property FontName: WideString read GetFontName write SetFontName;
    property FontColorIndex: TXLColorIndex read GetFontColorIndex write SetFontColorIndex;
    property FontColorRGB: Integer read GetFontColorRGB write SetFontColorRGB;
    property FontHeight: Word read GetFontHeight write SetFontHeight;
    property FontTableIndex: Integer read GetFontTableIndex;
    property XFTableIndex: Integer read FXFTableIndex write SetXFTableIndex;
    { format index }
    property FormatIndex: Integer read FXFTableIndex write SetXFTableIndex;
  end;

  {TCustomXLSItems}
  TCustomXLSItems = class
  protected
    FOwner: TSheet;
    FTmpItem: TCustomXLSItem;
    FItems: THashedList;
    FPreventStoreItems: Boolean;
    FCommonWorkbookCellData: PCommonWorkbookCellData;
    procedure ForceStoreItem(AItem: TCustomXLSItem); virtual;
    procedure GetItemKey(AItem: Pointer; var Key: AnsiString); virtual; abstract;
    function GetItemIndex(AItem: Pointer): Integer; virtual;
    procedure Add(AItem: TCustomXLSItem);
    function GetItem(Ind: Integer): TCustomXLSItem;
    function GetCount: Integer;
  public
    constructor Create(const AOwner: TSheet);
    destructor Destroy; override;
    property Item[Ind: Integer]: TCustomXLSItem read GetItem;
    property Count: Integer read GetCount;
  end;

  {TCellData}
  TCellData = packed record
    Value: Variant;
    { StringData is a common buffer for formula, hyperlink, rich format }
    StringData: AnsiString;
    Row, Col: Word;
  end;

  {TCell}
  TCell = class(TCustomXLSItem)
  protected
    FData: TCellData;
    procedure ClearData;
    procedure CopyFromCell(ASourceCell: TCell);
    procedure SetValue(AValue: Variant);
    procedure SetFormula(AFormula: AnsiString);
    procedure SetHyperlink(AHyperlink: WideString);
    procedure SetHyperlinkType(AHyperlinkType: TCellHyperlinkType);
    procedure SetRichFormat(ARichFormat: AnsiString);
    function GetFormula: AnsiString;
    function GetHyperlink: WideString;
    function GetHyperlinkType: TCellHyperlinkType;
    function GetRichFormat: AnsiString;
    function GetValueAsString: WideString;
    procedure InheritRowColumnXF;
   public
    constructor Create(AOwner: TCells; const ARow, ACol: Word; const ACommonCellData: PCommonWorkbookCellData);
    destructor Destroy; override;
    procedure Clear;
    property Col: Word read FData.Col;
    property Row: Word read FData.Row;
    property Formula: AnsiString read GetFormula write SetFormula;
    property Hyperlink: WideString read GetHyperlink write SetHyperlink;
    property HyperlinkType: TCellHyperlinkType read GetHyperlinkType write SetHyperlinkType;
    property RichFormat: AnsiString read GetRichFormat write SetRichFormat;
    property Value: Variant read FData.Value write SetValue;
    property ValueAsString: WideString read GetValueAsString;
  end;

  {TCells}
  TCells = class(TCustomXLSItems)
  protected
    function FindRowCol(ARow, ACol: Word): TCell;
    function GetCell(ARow, ACol: Word): TCell;
    function GetCellByA1Ref(ACellA1Ref: AnsiString): TCell;
    procedure SetKey(ARow, ACol: Word; var Key: AnsiString);
    procedure GetItemKey(AItem: Pointer; var Key: AnsiString); override;
    function GetItem(Ind: Integer): TCell;
    procedure RemoveCell(ACell: TCell);

    procedure InternalCellMove(const AIndex: Integer; const ANewRow, ANewColumn: Word);
    procedure InternalCopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
      ADestTopRow, ADestLeftColumn: Integer;
      MoveCells: Boolean;
      ProcessRanges: Boolean);
    procedure InternalDeleteRow(ARow: Word);
    procedure InternalDeleteColumn(AColumn: Word);
    procedure InternalInsertRow(ARowAfter: Word);
    procedure InternalInsertColumn(AfterColumn: Word);
    procedure InternalCopyRow(ASourceRow, ADestRow: Integer);
    procedure InternalCopyColumn(ASourceColumn, ADestColumn: Integer);
  public
    constructor Create(const AOwner: TSheet);
    destructor Destroy; override;
    procedure ClearCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word);
    procedure MoveCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
      ADestTopRow, ADestLeftColumn: Word);
    procedure CopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
      ADestTopRow, ADestLeftColumn: Word);

    property Cell[ARow, ACol: Word]: TCell read GetCell; default;
    property Item[Ind: Integer]: TCell read GetItem;
    property CellByA1Ref[ACell: AnsiString]: TCell read GetCellByA1Ref;
  end;

  TCustomRowCols = class;

  {TCustomRowCol}
  TCustomRowCol = class(TCustomXLSItem)
  protected
    FOutlineLevel: Byte;
    FSize: Double;
    FSizePx: Integer;
    FHidden: Boolean;
    FIndex: Word;
    FChanged: Boolean;
    FSizeChanged: Boolean;
    procedure SetHidden(AHidden: Boolean);
  public
    constructor Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData); dynamic;
    destructor Destroy; override;
    procedure IncOutlineLevel;
    procedure DecOutlineLevel;
    property Index: Word read FIndex;
    property OutlineLevel: Byte read FOutlineLevel;
    property Changed: Boolean read FChanged;
    property SizeChanged: Boolean read FSizeChanged;
    property Hidden: Boolean read FHidden write SetHidden;
  end;

  {TColumn}
  TColumn = class(TCustomRowCol)
  protected
    procedure InternalClear;
    procedure InternalCopyFromColumn(ASourceColumn: TColumn);
    procedure SetWidth(ASize: double);
    procedure SetWidthPx(ASizePx: Integer);
    function GetVisibleWidth: Double;
    function GetVisibleWidthPx: Integer;

    {set format methods}
    procedure SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex); override;
    procedure SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex); override;
    procedure SetFillPatternBGColorRGB(AColorRGB: Integer); override;
    procedure SetFillPatternFGColorRGB(AColorRGB: Integer); override;
    procedure SetFillPattern(APattern: TXLPattern); override;
    procedure SetHAlign(AHalign: TCellHAlignment); override;
    procedure SetVAlign(AValign: TCellVAlignment); override;
    procedure SetMerged(AMerged: Boolean); override;
    procedure SetWrap(AWrap: Boolean); override;
    procedure SetRotation(ARotation: TCellRotation); override;
    procedure SetIndent(AIndent: Byte); override;
    procedure SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex); override;
    procedure SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer); override;
    procedure SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle); override;
    procedure SetFormatStringIndex(AFormatStringIndex: Integer); override;
    { set font methods }
    procedure SetFontBold(AValue: Boolean); override;
    procedure SetFontItalic(AValue: Boolean); override;
    procedure SetFontUnderline(AValue: Boolean); override;
    procedure SetFontStrikeOut(AValue: Boolean); override;
    procedure SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle); override;
    procedure SetFontSSStyle(AValue: TXLFontSSStyle); override;
    procedure SetFontName(AValue: WideString); override;
    procedure SetFontColorIndex(AValue: TXLColorIndex); override;
    procedure SetFontColorRGB(AValue: Integer); override;
    procedure SetFontHeight(AValue: Word); override;

  public
    constructor Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData); override;
    procedure Clear;
    property Width: Double read FSize write SetWidth;
    property WidthPx: Integer read FSizePx write SetWidthPx;
    property VisibleWidth: Double read GetVisibleWidth;
    property VisibleWidthPx: Integer read GetVisibleWidthPx;
  end;

  {Row}
  TRow = class(TCustomRowCol)
  protected
    procedure InternalClear;
    procedure InternalCopyFromRow(ASourceRow: TRow);
    procedure SetHeight(ASize: double);
    procedure SetHeightPx(ASizePx: Integer);
    function GetVisibleHeight: Double;
    function GetVisibleHeightPx: Integer;

    {set format methods}
    procedure SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex); override;
    procedure SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex); override;
    procedure SetFillPatternBGColorRGB(AColorRGB: Integer); override;
    procedure SetFillPatternFGColorRGB(AColorRGB: Integer); override;
    procedure SetFillPattern(APattern: TXLPattern); override;
    procedure SetHAlign(AHalign: TCellHAlignment); override;
    procedure SetVAlign(AValign: TCellVAlignment); override;
    procedure SetMerged(AMerged: Boolean); override;
    procedure SetWrap(AWrap: Boolean); override;
    procedure SetRotation(ARotation: TCellRotation); override;
    procedure SetIndent(AIndent: Byte); override;
    procedure SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex); override;
    procedure SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer); override;
    procedure SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle); override;
    procedure SetFormatStringIndex(AFormatStringIndex: Integer); override;

    { set font methods }
    procedure SetFontBold(AValue: Boolean); override;
    procedure SetFontItalic(AValue: Boolean); override;
    procedure SetFontUnderline(AValue: Boolean); override;
    procedure SetFontStrikeOut(AValue: Boolean); override;
    procedure SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle); override;
    procedure SetFontSSStyle(AValue: TXLFontSSStyle); override;
    procedure SetFontName(AValue: WideString); override;
    procedure SetFontColorIndex(AValue: TXLColorIndex); override;
    procedure SetFontColorRGB(AValue: Integer); override;
    procedure SetFontHeight(AValue: Word); override;
  public
    constructor Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData); override;
    procedure AutoFit;
    procedure Clear;
    property Height: Double read FSize write SetHeight;
    property HeightPx: Integer read FSizePx write SetHeightPx;
    property VisibleHeight: Double read GetVisibleHeight;    
    property VisibleHeightPx: Integer read GetVisibleHeightPx;
  end;

  {TCustomRowCols}
  TCustomRowCols = class(TCustomXLSItems)
  protected
    function FindByNumber(ANumber: Word): TCustomRowCol;
    procedure SetKey(ANumber: Word; var Key: AnsiString);
    procedure GetItemKey(AItem: Pointer; var Key: AnsiString); override;
  public
    constructor Create(const AOwner: TSheet); 
    destructor Destroy; override;
  end;

  {TColumns}
  TColumns = class(TCustomRowCols)
  private
    function GetColumn(ACol: Word): TColumn;
    function GetItem(Ind: Integer): TColumn;
    procedure InternalCopyColumns(ALeftColumn, ARightColumn: Word;
      ADestLeftColumn: Integer; MoveColumns: Boolean);
    procedure RemoveColumn(AColumn: TColumn);
    function IsStored(ACol: Word): Boolean;    
  public
    {$IFDEF XLF_D3}
    procedure AutoFit(const ALeftColumn, ARightColumn: Word;
      const ATopRow, ABottomRow: Integer; const AMaxWidthPx: Word); 
    {$ELSE}
    procedure AutoFit(const ALeftColumn, ARightColumn: Word;
      const ATopRow, ABottomRow: Integer; const AMaxWidthPx: Word); overload;
    procedure AutoFit(const ALeftColumn, ARightColumn: Word; const AMaxWidthPx: Word); overload;
    procedure AutoFit(const ALeftColumn, ARightColumn: Word); overload;    
    procedure AutoFit; overload;
    {$ENDIF}
    procedure DeleteColumns(ALeftColumn, ARightColumn: Word);
    procedure InsertColumns(AColumnAfter: Word; ColumnCountToInsert: Word);
    procedure ClearColumns(ALeftColumn, ARightColumn: Word);
    procedure CopyColumns(ALeftColumn, ARightColumn: Word; ADestLeftColumn: Word);
    procedure MoveColumns(ALeftColumn, ARightColumn: Word; ADestLeftColumn: Word);
    property Column[ACol: Word]:TColumn read GetColumn; default;
    property Item[Ind: Integer]: TColumn read GetItem;
  end;

  {TRows}
  TRows = class(TCustomRowCols)
  private
    function GetRow(ARow: Word): TRow;
    function GetItem(Ind: Integer): TRow;
    procedure InternalCopyRows(ATopRow, ABottomRow: Word;
      ADestTopRow: Integer; MoveRows: Boolean);
    procedure RemoveRow(ARow: TRow);
    function IsStored(ARow: Word): Boolean;
  public
    procedure DeleteRows(ATopRow, ABottomRow: Word);
    procedure InsertRows(ARowAfter: Word; RowCountToInsert: Word);
    procedure ClearRows(ATopRow, ABottomRow: Word);
    procedure CopyRows(ATopRow, ABottomRow: Word; ADestTopRow: Word);
    procedure MoveRows(ATopRow, ABottomRow: Word; ADestTopRow: Word);
    property Row[ARow: Word]:TRow read GetRow; default;
    property Item[Ind: Integer]: TRow read GetItem;
  end;

  {TRange}
  TRange = class(TRangeRects)
  protected
    FSheet: TSheet;
    FName: WideString;
    FMerged: Boolean;
    procedure InternalCopyFromRange(ASourceRange: TRange);
    procedure SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex);
    procedure SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer);
    procedure SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle);
    function GetEmpty: Boolean;
    procedure SetValue(AValue: Variant);
    procedure SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex);
    procedure SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex);
    procedure SetFillPatternBGColorRGB(AColorRGB: Integer);
    procedure SetFillPatternFGColorRGB(AColorRGB: Integer);
    procedure SetFillPattern(APattern: TXLPattern);
    procedure SetFontBold(AValue: Boolean);
    procedure SetFontItalic(AValue: Boolean);
    procedure SetFontUnderline(AValue: Boolean);
    procedure SetFontStrikeOut(AValue: Boolean);
    procedure SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle);
    procedure SetFontSSStyle(AValue: TXLFontSSStyle);
    procedure SetFontName(AValue: WideString);
    procedure SetFontColorIndex(AValue: TXLColorIndex);
    procedure SetFontColorRGB(AValue: Integer);
    procedure SetFontHeight(AValue: Word);
    procedure SetFormatStringIndex(AValue: Integer);
    procedure SetHAlign(AHalign: TCellHAlignment);
    procedure SetVAlign(AValign: TCellVAlignment);
    procedure SetWrap(AWrap: Boolean);
    procedure SetLocked(ALocked: Boolean);
    procedure SetRotation(ARotation: TCellRotation);
    procedure SetIndent(AIndent: Byte);    
    procedure SetFormula(AFormula: AnsiString);
    procedure SetHyperlink(AHyperlink: WideString);
    procedure SetHyperlinkType(AHyperlinkType: TCellHyperlinkType);
    procedure SetName(AName: WideString);
  public
    constructor Create(ASheet: TSheet);
    constructor CreateFromA1Ref(ASheet: TSheet; ARangeA1Ref: AnsiString);
    destructor Destroy; override;
    procedure Clear;    
    procedure MergeCells;
    procedure UnMergeCells;    
    procedure BordersOutline(AColorIndex: TXLColorIndex; AStyle: TXLBorderStyle);
    procedure BordersEdge(AColorIndex: TXLColorIndex;  AStyle: TXLBorderStyle; Edge: TCellBorderIndex);
    procedure BordersOutlineRGB(AColorRGB: Integer; AStyle: TXLBorderStyle);
    procedure BordersEdgeRGB(AColorRGB: Integer; AStyle: TXLBorderStyle; Edge: TCellBorderIndex);

    property BorderColorIndex[Index: TCellBorderIndex]: TXLColorIndex write SetBorderColorindex;
    property BorderColorRGB[Index: TCellBorderIndex]: Integer write SetBorderColorRGB;
    property BorderStyle[Index: TCellBorderIndex]: TXLBorderStyle write SetBorderStyle;
    property Empty: Boolean read GetEmpty;
    property FillPatternBGColorIndex: TXLColorIndex write SetFillPatternBGColorIndex;
    property FillPatternFGColorIndex: TXLColorIndex write SetFillPatternFGColorIndex;
    property FillPatternBGColorRGB: Integer write SetFillPatternBGColorRGB;
    property FillPatternFGColorRGB: Integer write SetFillPatternFGColorRGB;
    property FillPattern: TXLPattern write SetFillPattern;
    property FontBold: Boolean write SetFontBold;
    property FontItalic: Boolean write SetFontItalic;
    property FontUnderline: Boolean write SetFontUnderline;
    property FontStrikeOut: Boolean write SetFontStrikeOut;
    property FontUnderlineStyle: TXLFontUnderlineStyle write SetFontUnderlineStyle;
    property FontSSStyle: TXLFontSSStyle write SetFontSSStyle;
    property FontName: WideString write SetFontName;
    property FontColorIndex: TXLColorIndex write SetFontColorIndex;
    property FontColorRGB: Integer write SetFontColorRGB;
    property FontHeight: Word write SetFontHeight;
    property FormatStringIndex: Integer write SetFormatStringIndex;
    property HAlign: TCellHAlignment write SetHAlign;
    property VAlign: TCellVAlignment write SetVAlign;
    property Wrap: Boolean write SetWrap;
    property Rotation: TCellRotation write SetRotation;
    property Indent: Byte write SetIndent;
    property Merged: Boolean read FMerged;
    property Locked: Boolean write SetLocked;
    property Name: WideString read FName write SetName;
    property Formula: AnsiString write SetFormula;
    property Hyperlink: WideString write SetHyperlink;
    property HyperlinkType: TCellHyperlinkType write SetHyperlinkType;
    property Value: variant write SetValue;
    property Sheet: TSheet read FSheet;
  end;

  {TRanges}
  TRanges = class
  protected
    FSheet: TSheet;
    FItems: TList;
    function GetRange(AIndex: Integer): TRange;
    function GetRangesCount: Integer;
    function GetRangeByName(AName: WideString): TRange;
  public
    constructor Create(ASheet: TSheet);
    destructor Destroy; override;
    function Add: TRange;
    function AddFromA1Ref(ARangeA1Ref: AnsiString): TRange;
    property Sheet: TSheet read FSheet;
    property RangesCount: Integer read GetRangesCount;
    property Range[Ind: Integer]: TRange read GetRange; default;
    property RangeByName[Name: WideString]: TRange read GetRangeByName;
  end;

  {TPageSetup}
  TPageSetup = class
  protected
    FSheet: TSheet;
    FPrintArea: TRange;
    FPrintRowsOnEachPageFrom: Integer;
    FPrintRowsOnEachPageTo: Integer;
    FPrintColumnsOnEachPageFrom: Integer;
    FPrintColumnsOnEachPageTo: Integer;
    procedure InternalCopy(ASourcePageSetup: TPageSetup);
  public
    PaperSize         : TXLPaperSize; // paper size
    Zoom              : Boolean;      // true: scale print area with Scale
                                      // false: fit print area into number of pages
    Scale             : Word;         // use scale for printing
    StartPageNum      : Word;         // starting page number
    FitPagesWidth     : Word;         // number of pages to fit in width
    FitPagesHeight    : Word;         // number of pages to fit in height
    PrintPagesOrder   : TXLSPrintOrder;  // print down-and-over or over-and-down
    Orientation       : TXLSPageOrientation;  // portrait or landscape
    HeaderMargin      : Double;       // header margin in inches
    FooterMargin      : Double;       // footer margin in inches
    TopMargin         : Double;       // top margin in inches
    BottomMargin      : Double;       // bottom margin in inches
    LeftMargin        : Double;       // left margin in inches
    RightMargin       : Double;       // right margin in inches
    BlackAndWhite     : Boolean;      // use black and white colors for printing
    Draft             : Boolean;      // draft mode
    PrintGrid         : Boolean;      // print gridlines
    PrintRowColLabels : Boolean;      // print rows and columns headers
    CenterHorizontally: Boolean;      // center print data horizontally between left and right margins
    CenterVertically  : Boolean;      // center print data vertically between top and bottom margins
    HeaderText        : WideString;   // header caption
    HeaderTextRight   : WideString;
    HeaderTextLeft    : WideString;
    FooterText        : WideString;   // footer caption
    FooterTextRight   : WideString;
    FooterTextLeft    : WideString;
    RowGroupAtTop     : Boolean;
    ColumnGroupAtLeft : Boolean;
    constructor Create(ASheet: TSheet);
    destructor Destroy; override;
    procedure PrintTitleRows(const RowFrom, RowTo: Integer);
    procedure PrintTitleColumns(const ColumnFrom, ColumnTo: Integer);
    property PrintArea: TRange read FPrintArea; 
    property PrintRowsOnEachPageFrom: Integer read FPrintRowsOnEachPageFrom write FPrintRowsOnEachPageFrom;
    property PrintRowsOnEachPageTo: Integer read FPrintRowsOnEachPageTo write FPrintRowsOnEachPageTo;
    property PrintColumnsOnEachPageFrom: Integer read FPrintColumnsOnEachPageFrom write FPrintColumnsOnEachPageFrom;
    property PrintColumnsOnEachPageTo: Integer read FPrintColumnsOnEachPageTo write FPrintColumnsOnEachPageTo;
  end;

  {TXLSImageType}
  TXLSImageType = (xlimgNone, xlimgBMP, xlimgJPG, xlimgPNG, xlimgWMF, xlimgEMF);
  
  {TXLSImage}
  TXLSImage = class
  private
    FFileName: AnsiString;
    FLeftColumn: Integer;
    FTopRow: Integer;
    FRightColumn: Integer;
    FBottomRow: Integer;
    FStretchToWidthPx: Integer;
    FStretchToHeightPx: Integer;
    FLeftColumnOffsetPx: Integer;
    FTopRowOffsetPx: Integer;
    FImageData: TEasyStream;
    FImageType: TXLSImageType;
    FBLIPType: Integer;
    function GetImageType: TXLSImageType;
  public
    constructor Create(const AFileName: AnsiString;
      const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
    constructor CreateFromStream(Stream: TEasyStream;
      const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
    constructor CreatePx(const AFileName: AnsiString;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
      const AStretchToWidthPx, AStretchToHeightPx: Integer);
    constructor CreateFromStreamPx(Stream: TEasyStream;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
      const AStretchToWidthPx, AStretchToHeightPx: Integer);
    destructor Destroy; override;
    procedure SaveAs(const AFileName: AnsiString; const AutoExtension: Boolean);
    property FileName: AnsiString read FFileName;
    property ImageData: TEasyStream read FImageData;
    property ImageType: TXLSImageType read GetImageType;
    property LeftColumn: Integer read FLeftColumn;
    property TopRow: Integer read FTopRow;
    property RightColumn: Integer read FRightColumn;
    property BottomRow: Integer read FBottomRow;
    property LeftColumnOffsetPx: Integer read FLeftColumnOffsetPx;
    property TopRowOffsetPx: Integer read FTopRowOffsetPx;
    property StretchToWidthPx: Integer read FStretchToWidthPx;
    property StretchToHeightPx: Integer read FStretchToHeightPx;
  end;

  {TXLSImages}
  TXLSImages = class
  protected
    FItems: TList;
    function GetItem(Index: Integer): TXLSImage;
    function GetCount: Integer;
  public
    constructor Create(ASheet: TSheet);
    destructor Destroy; override;
    procedure AddItem(AImage: TXLSImage);
    { Add with rows/columns position }
    procedure AddStretch(const AFileName: AnsiString;
      const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
    procedure Add(const AFileName: AnsiString; const ALeftColumn, ATopRow: Integer);
    procedure AddFromStream(AStream: TStream;
      const AStreamPositionFrom, AStreamBytesToRead: Integer;
      const ALeftColumn, ATopRow: Integer);
    procedure AddStretchFromStream(AStream: TStream;
      const AStreamPositionFrom, AStreamBytesToRead: Integer;
      const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
    { Add with pixels position }
    procedure AddPx(const AFileName: AnsiString;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer);
    procedure AddStretchPx(const AFileName: AnsiString;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
      const AStretchToWidthPx, AStretchToHeightPx: Integer);
    procedure AddFromStreamPx(AStream: TStream;
      const AStreamPositionFrom, AStreamBytesToRead: Integer;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer);
    procedure AddStretchFromStreamPx(AStream: TStream;
      const AStreamPositionFrom, AStreamBytesToRead: Integer;
      const ALeftColumn, ATopRow: Integer;
      const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
      const AStretchToWidthPx, AStretchToHeightPx: Integer);
    procedure Delete(Index: Integer);
    procedure Clear;
    property Item[Index: Integer]: TXLSImage read GetItem; default;
    property Count: Integer read GetCount;
  end;

  {TSheetWindowOptions}
  TSheetWindowOptions = packed record
    DisplayGrids: Boolean;
    DisplayRightToLeft: Boolean;
    DisplayRowColHeaders: Boolean;
    DisplayZero: Boolean;
    FreezePoint: TCellCoord;
    ZoomPercent: Byte;
    PageBreakPreview: Boolean;
  end;

  {TSheet}
  TSheet = class
  private
    FWbk: TWorkbook;
    FCells: TCells;
    FColumns: TColumns;
    FRows: TRows;
    FRanges: TRanges;
    FIndex: Integer;
    FName: WideString;
    FPageSetup: TPageSetup;
    FPageBreaks: TCellCoords;
    FImages: TXLSImages;
    FCommonWorkbookCellData: PCommonWorkbookCellData;
    FProtectPassword: AnsiString;
    FProtectPasswordHash: Word;
    FProtectMode: Word;
    FCellValidations: TCellValidations;
    FCellComments: TCellComments;
    FVisible: Boolean;
    procedure SetName(AName: WideString);
    procedure RefreshIndex;
    procedure CopyFromSheet(ASourceSheet: TSheet);
    function GetIsProtected: Boolean;
  public
    WindowOptions: TSheetWindowOptions;
    constructor Create(AWbk: TWorkbook);
    destructor Destroy; override;
    function FindMergedRectContainingCellCoord(const ARow: Word;
      const AColumn: Byte; var ARect: TRangeRect): Boolean;
    function FindMergedRectContainingCell(ACell: TCell; var ARect: TRangeRect): Boolean;
    function GetUsedRect(var ARect: TRangeRect): Boolean;
    procedure Freeze(const ARow: Word; AColumn: Byte);
    procedure UnFreeze;
    { Row/Column group }
    procedure GroupRows(const ARowFrom, ARowTo: Word);
    procedure GroupColumns(const AColumnFrom, AColumnTo: Byte);
    procedure UnGroupRows(const ARowFrom, ARowTo: Word);
    procedure UnGroupColumns(const AColumnFrom, AColumnTo: Byte);
    { Export }
    procedure SaveAsHTML(const AFileName: AnsiString);
    procedure SaveToStreamAsHTML(const AStream: TStream);
    procedure SaveRectAsHTML(const AFileName: AnsiString; const ARect: TRangeRect);
    procedure SaveRectToStreamAsHTML(const AStream: TStream; const ARect: TRangeRect);
    procedure SaveAsTXT(const AFileName: AnsiString; const AFileType: TTXTFileType);
    procedure SaveToStreamAsTXT(const AStream: TStream; const AFileType: TTXTFileType);
    procedure SaveRectAsTXT(const AFileName: AnsiString; const AFileType: TTXTFileType; const ARect: TRangeRect);
    procedure SaveRectToStreamAsTXT(const AStream: TStream; const AFileType: TTXTFileType; const ARect: TRangeRect);
    { Protection }
    procedure Protect(const APassword: AnsiString);
    procedure ProtectWithMode(const APassword: AnsiString; const AProtectMode: Word);    
    function UnProtect(const APassword: AnsiString): Boolean;
    procedure UnProtectWithoutPassword;
    { Properties }
    property Cells: TCells read FCells;
    property CellValidations: TCellValidations read FCellValidations;
    property CellComments: TCellComments read FCellComments;
    property Columns: TColumns read FColumns;
    property Rows: TRows read FRows;
    property Ranges: TRanges read FRanges;
    property Name: WideString read FName write SetName;
    property Index: Integer read FIndex;
    property PageSetup: TPageSetup read FPageSetup;
    property PageBreaks: TCellCoords read FPageBreaks;
    property Images: TXLSImages read FImages;
    property IsProtected: Boolean read GetIsProtected;
    property ProtectPasswordHash: Word read FProtectPasswordHash write FProtectPasswordHash;
    property ProtectMode: Word read FProtectMode write FProtectMode;    
    property Visible: Boolean read FVisible write FVisible;
  end;

  {TSheets}
  TSheets = class
  protected
    FSheets: TList;
    FWbk: TWorkbook;
    function GetSheet(Ind: Integer): TSheet;
    function GetSheetsCount: Integer;
    function GetSheetByName(ASheetName: WideString): TSheet;
    function VerifySheetName(ASheetName: WideString): TXLSErrorCode;
  public
    constructor Create(AWbk: TWorkbook);
    destructor Destroy; override;
    procedure Add(const ASheetName: WideString);
    procedure Clear;
    procedure Copy(const ASourceInd: Integer; const ADestInd: Integer; const ANewSheetName: WideString);
    procedure Delete(const Ind: Integer);
    procedure DeleteByName(const ASheetName: WideString);
    property Item[Ind: Integer]: TSheet read GetSheet; default;
    property SheetByName[ASheetName: WideString]: TSheet read GetSheetByName;
    property Count: Integer read GetSheetsCount;
  end;

  {TWorkbook}
  TWorkbook = class
  private
    FSheets: TSheets;
    FFormatStrings: TFormatStrings;
    FFontTable: TVirtualFontTable;
    FXFTable: TVirtualXFTable;
    { FCommonWorkbookCellData is a record with common data
      for all cells in the workbook }
    FCommonWorkbookCellData: TCommonWorkbookCellData;
    FProtectPassword: AnsiString;
    FProtectPasswordHash: Word;
    FLinkTable: TXLSLinkTable;
    function GetIsProtected: Boolean;
  public
    constructor Create(ASheetCount: Integer);
    destructor Destroy; override;
    function SheetByName(const ASheetName: WideString): TSheet;
    procedure Clear;
    procedure SetProcessingState(const State: TXLSProcessingState);

    { Protection }
    procedure Protect(const APassword: AnsiString);
    function UnProtect(const APassword: AnsiString): Boolean;
    procedure UnProtectWithoutPassword;

    property Sheets: TSheets read FSheets;
    property FormatStrings: TFormatStrings read FFormatStrings;
    property FontTable: TVirtualFontTable read FFontTable;
    property XFTable: TVirtualXFTable read FXFTable;
    property LinkTable: TXLSLinkTable read FLinkTable;
    property IsProtected: Boolean read GetIsProtected;
    property ProtectPasswordHash: Word read FProtectPasswordHash write FProtectPasswordHash;
  end;

implementation

uses
  XLSWriterHTML
, XLSWriterTXT
, XLSStrUtil
, XLSRichString
, XLSProtect
, XLSMsoDraw
, Unicode
{$IFDEF XLF_D6}
, Variants
{$ENDIF}
{$IFDEF XLF_D2009}
, AnsiStrings
{$ENDIF}
;

{TCustomXLSItem}
constructor TCustomXLSItem.Create(AOwner: TCustomXLSItems; const ACommonCellData: PCommonWorkbookCellData);
begin
  FStored:= False;
  FOwner:= AOwner;
  FCommonCellData := ACommonCellData;

  { set XF table index }
  FXFTableIndex:= FCommonCellData^.XFTable.DefaultIndex;
end;

destructor TCustomXLSItem.Destroy;
begin
  inherited;
end;

{ Format properties }
procedure TCustomXLSItem.SetFormatStringIndex(AFormatStringIndex: Integer);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.FormatIndex <> AFormatStringIndex then
  begin
    XFData^.FormatIndex:= AFormatStringIndex;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    FOwner.ForceStoreItem(Self);
  end;
end;

function TCustomXLSItem.GetFormatStringIndex: Integer;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.FormatIndex;
end;

procedure TCustomXLSItem.SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.BGColor <> AColorIndex then
  begin
    XFData^.BGColor:= AColorIndex;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AColorIndex <> xlColorNone then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.FGColor <> AColorIndex then
  begin
    XFData^.FGColor:= AColorIndex;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AColorIndex <> xlColorAuto then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFillPatternBGColorRGB(AColorRGB: Integer);
begin
  SetFillPatternBGColorIndex(ColorToXLSColorIndex(RGBToColor(AColorRGB)));
end;

procedure TCustomXLSItem.SetFillPatternFGColorRGB(AColorRGB: Integer);
begin
  SetFillPatternFGColorIndex(ColorToXLSColorIndex(RGBToColor(AColorRGB)));
end;

function TCustomXLSItem.GetFillPatternBGColorRGB: Integer;
begin
  Result:= XLSColorIndexToColorRGB(GetFillPatternBGColorIndex);
end;

function TCustomXLSItem.GetFillPatternFGColorRGB: Integer;
begin
  Result:= XLSColorIndexToColorRGB(GetFillPatternFGColorIndex);
end;

procedure TCustomXLSItem.SetFillPattern(APattern: TXLPattern);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.FillPattern <> APattern  then
  begin
    XFData^.FillPattern:= APattern;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if APattern <> xlPatternNone then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetHAlign(AHalign: TCellHAlignment);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.HAlign <> AHAlign then
  begin
    XFData^.HAlign:= AHAlign;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AHAlign <> xlHAlignGeneral then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetVAlign(AVAlign: TCellVAlignment);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.VAlign <> AVAlign then
  begin
    XFData^.VAlign:= AVAlign;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AVAlign <> xlVAlignTop then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetWrap(AWrap: Boolean);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.Wrap <> AWrap then
  begin
    XFData^.Wrap:= AWrap;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AWrap <> False then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetMerged(AMerged: Boolean);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.Merge <> AMerged then
  begin
    XFData^.Merge:= AMerged;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AMerged <> False then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetLocked(ALocked: Boolean);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.Locked <> ALocked then
  begin
    XFData^.Locked:= ALocked;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if ALocked <> True then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetRotation(ARotation: TCellRotation);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.Rotation <> ARotation then
  begin
    XFData^.Rotation:= ARotation;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if ARotation <> xlRotationNone then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetIndent(AIndent: Byte);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.Indent <> AIndent then
  begin
    { Indent is 4-bit value }
    if AIndent > $0F then
      XFData^.Indent:= $0F
    else
      XFData^.Indent:= AIndent;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AIndent <> 0 then
      FOwner.ForceStoreItem(Self);
  end;
end;

function TCustomXLSItem.GetFillPatternBGColorIndex: TXLColorIndex;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.BgColor;
end;

function TCustomXLSItem.GetFillPatternFGColorIndex: TXLColorIndex;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.FgColor;
end;

function TCustomXLSItem.GetFillPattern: TXLPattern;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.FillPattern;
end;

function TCustomXLSItem.GetHAlign: TCellHAlignment;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.HAlign;
end;

function TCustomXLSItem.GetVAlign: TCellVAlignment;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.VAlign;
end;

function TCustomXLSItem.GetMerged: Boolean;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.Merge;
end;

function TCustomXLSItem.GetLocked: Boolean;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.Locked;
end;

function TCustomXLSItem.GetWrap: Boolean;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.Wrap;
end;

function TCustomXLSItem.GetRotation: TCellRotation;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.Rotation;
end;

function TCustomXLSItem.GetIndent: Byte;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.Indent;
end;

function TCustomXLSItem.GetBorderColorIndex(Index: TCellBorderIndex): TXLColorIndex;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  case Index of
    xlBorderLeft   : Result:= XFData^.LeftBorderColor;
    xlBorderRight  : Result:= XFData^.RightBorderColor;
    xlBorderTop    : Result:= XFData^.TopBorderColor;
    xlBorderBottom : Result:= XFData^.BottomBorderColor;
    else             Result:= xlColorNone;
  end;
end;

procedure TCustomXLSItem.SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);

  if Index = xlBorderAll then
  begin
    XFData^.LeftBorderColor:= AColorIndex;
    XFData^.RightBorderColor:= AColorIndex;
    XFData^.TopBorderColor:= AColorIndex;
    XFData^.BottomBorderColor:= AColorIndex;
  end
  else
  begin
    case Index of
      xlBorderLeft   : XFData^.LeftBorderColor:= AColorIndex;
      xlBorderRight  : XFData^.RightBorderColor:= AColorIndex;
      xlBorderTop    : XFData^.TopBorderColor:= AColorIndex;
      xlBorderBottom : XFData^.BottomBorderColor:= AColorIndex;
    end
  end;

  FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
  FOwner.ForceStoreItem(Self);
end;

function TCustomXLSItem.GetBorderColorRGB(Index: TCellBorderIndex): Integer;
begin
  Result:= XLSColorIndexToColorRGB(GetBorderColorIndex(Index));
end;

procedure TCustomXLSItem.SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer);
begin
  SetBorderColorIndex(Index, ColorToXLSColorIndex(RGBToColor(AColorRGB)));
end;

function TCustomXLSItem.GetBorderStyle(Index: TCellBorderIndex): TXLBorderStyle;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  case Index of
    xlBorderLeft   : Result:= XFData^.LeftBorderStyle;
    xlBorderRight  : Result:= XFData^.RightBorderStyle;
    xlBorderTop    : Result:= XFData^.TopBorderStyle;
    xlBorderBottom : Result:= XFData^.BottomBorderStyle;
    else             Result:= bsNone;
  end;
end;

procedure TCustomXLSItem.SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);

  if Index = xlBorderAll then
  begin
    XFData^.LeftBorderStyle:= AStyle;
    XFData^.RightBorderStyle:= AStyle;
    XFData^.TopBorderStyle:= AStyle;
    XFData^.BottomBorderStyle:= AStyle;
  end
  else
  begin
    case Index of
      xlBorderLeft   : XFData^.LeftBorderStyle:= AStyle;
      xlBorderRight  : XFData^.RightBorderStyle:= AStyle;
      xlBorderTop    : XFData^.TopBorderStyle:= AStyle;
      xlBorderBottom : XFData^.BottomBorderStyle:= AStyle;
    end
  end;

  FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
  FOwner.ForceStoreItem(Self);
end;

procedure TCustomXLSItem.SetXFTableIndex(AXFIndex: Integer);
begin
  if ( FXFTableIndex <> AXFIndex ) then
  begin
    FXFTableIndex:= AXFIndex;
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontTableIndex(AIndex: Integer);
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  if XFData^.FontIndex <> AIndex then
  begin
    XFData^.FontIndex:= AIndex;
    FXFTableIndex:= FCommonCellData^.XFTable.SaveChangedBuffer;
    if AIndex <> 0 then
      FOwner.ForceStoreItem(Self);
  end;
end;

function TCustomXLSItem.GetFontTableIndex: Integer;
var
  XFData: PXFData;
begin
  XFData:= FCommonCellData^.XFTable.LoadXFToBuffer(FXFTableIndex);
  Result:= XFData^.FontIndex;
end;

{ Font properties }
procedure TCustomXLSItem.SetFontBold(AValue: Boolean);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.Bold <> AValue then
  begin
    FontData^.Bold:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontItalic(AValue: Boolean);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.Italic <> AValue then
  begin
    FontData^.Italic:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontUnderline(AValue: Boolean);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.Underline <> AValue then
  begin
    FontData^.Underline:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontStrikeOut(AValue: Boolean);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.StrikeOut <> AValue then
  begin
    FontData^.StrikeOut:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.UnderlineStyle <> AValue then
  begin
    FontData^.UnderlineStyle:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontSSStyle(AValue: TXLFontSSStyle);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.SSStyle <> AValue then
  begin
    FontData^.SSStyle:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontName(AValue: WideString);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if String(PAnsiChar(@FontData^.Name)) <> AValue then
  begin
    SetFontDataNameAsString(FontData, AValue);
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontColorIndex(AValue: TXLColorIndex);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.ColorIndex <> AValue then
  begin
    FontData^.ColorIndex:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomXLSItem.SetFontColorRGB(AValue: Integer);
begin
  SetFontColorIndex(ColorToXLSColorIndex(RGBToColor(AValue)));
  FOwner.ForceStoreItem(Self);
end;

procedure TCustomXLSItem.SetFontHeight(AValue: Word);
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  if FontData^.Height <> AValue then
  begin
    FontData^.Height:= AValue;
    SetFontTableIndex(FCommonCellData^.FontTable.SaveChangedBuffer);
    FOwner.ForceStoreItem(Self);
  end;
end;

function TCustomXLSItem.GetFontBold: Boolean;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.Bold;
end;

function TCustomXLSItem.GetFontItalic: Boolean;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.Italic;
end;

function TCustomXLSItem.GetFontUnderline: Boolean;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.Underline;
end;

function TCustomXLSItem.GetFontStrikeOut: Boolean;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.StrikeOut;
end;

function TCustomXLSItem.GetFontUnderlineStyle: TXLFontUnderlineStyle;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.UnderlineStyle;
end;

function TCustomXLSItem.GetFontSSStyle: TXLFontSSStyle;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.SSStyle;
end;

function TCustomXLSItem.GetFontColorIndex: TXLColorIndex;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.ColorIndex;
end;

function TCustomXLSItem.GetFontColorRGB: Integer;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= XLSColorIndexToColorRGB(FontData^.ColorIndex);
end;

function TCustomXLSItem.GetFontHeight: Word;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= FontData^.Height;
end;

function TCustomXLSItem.GetFontName: WideString;
var
  FontData: PFontData;
begin
  FontData:= FCommonCellData^.FontTable.LoadFontToBuffer(GetFontTableIndex);
  Result:= GetFontDataNameAsString(FontData);
end;

{TCustomXLSItems}
constructor TCustomXLSItems.Create(const AOwner: TSheet);
begin
  FOwner:= AOwner;
  FCommonWorkbookCellData:= AOwner.FCommonWorkbookCellData;
  FPreventStoreItems:= False;
  FItems:= THashedList.Create(1024 * 128 - 1, GetItemKey);
  FTmpItem:= nil;
end;

destructor TCustomXLSItems.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      TCustomXLSItem(FItems[I]).Destroy;
  FItems.Destroy;

  if Assigned(FTmpItem) then
    FTmpItem.Destroy;

  inherited;    
end;

procedure TCustomXLSItems.ForceStoreItem(AItem: TCustomXLSItem);
begin
  if FPreventStoreItems then Exit;
  
  if not AItem.FStored then
    Add(AItem);
  if AItem = FTmpItem then begin
    FTmpItem:= nil;
  end;
end;

procedure TCustomXLSItems.Add(AItem: TCustomXLSItem);
begin
  FItems.Add(AItem);
  AItem.FStored:= true; {here and only here}
end;

function TCustomXLSItems.GetCount: Integer;
begin
  Result:= FItems.Count;
end;

function TCustomXLSItems.GetItem(Ind: Integer): TCustomXLSItem;
begin
  if (Ind >= 0) and (Ind < FItems.Count) then
    Result:= TCustomXLSItem(FItems[Ind])
  else
    raise ERangeError.Create('List index (' + IntToStr(Ind) + ') out of bounds');
end;

function TCustomXLSItems.GetItemIndex(AItem: Pointer): Integer;
var
  Key: AnsiString;
begin
  GetItemKey(AItem, Key);
  Result:= FItems.IndexByKey(Key);
end;

{TCell}
constructor TCell.Create(AOwner: TCells; const ARow, ACol: Word;
  const ACommonCellData: PCommonWorkbookCellData);
begin
  inherited Create(AOwner, ACommonCellData);

  { !note: some properties assigned in inherited constructor }

  FCommonCellData := ACommonCellData;
  FData.Col:= ACol;
  FData.Row:= ARow;
  FData.Value:= Unassigned;
  FData.StringData:= '';
  FStored:= False;

  { If reading from file not in progress then inherit format from row/column }
  if (FCommonCellData.ProcessingState <> psReading) then
    InheritRowColumnXF;
end;

destructor TCell.Destroy;
begin
  inherited;
end;

procedure TCell.ClearData;
begin
  FData.StringData:= '';
  FData.Value:= Unassigned;

  { Set default XF }
  FXFTableIndex:= FCommonCellData^.XFTable.DefaultIndex;
end;

procedure TCell.Clear;
begin
  if Assigned(FOwner) then
    TCells(FOwner).RemoveCell(Self);
end;

procedure TCell.CopyFromCell(ASourceCell: TCell);
var
  ARow, AColumn: Word;
begin
  if Assigned(ASourceCell) then
  begin
    {Save row and column}
    ARow:= FData.Row;
    AColumn:= FData.Col;
    FData:= ASourceCell.FData;
    FData.Row:= ARow;
    FData.Col:= AColumn;

    {copy XF index}
    FXFTableIndex:= ASourceCell.FXFTableIndex;

    if ASourceCell.FStored then
      FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCell.InheritRowColumnXF;
var
  RowXF, ColumnXF: Integer;
  ARow: TRow;
  AColumn: TColumn;
  ADefaultXFIndex: Integer;
  ASheet: TSheet;
begin
  ASheet:= FOwner.FOwner;
  ADefaultXFIndex:= FCommonCellData^.XFTable.DefaultIndex;

  if ASheet.FRows.IsStored(FData.Row) then
    RowXF:= ASheet.FRows[FData.Row].FXFTableIndex
  else
    RowXF:= ADefaultXFIndex;

  if ASheet.FColumns.IsStored(FData.Col) then
    ColumnXF:= ASheet.FColumns[FData.Col].FXFTableIndex
  else
    ColumnXF:= ADefaultXFIndex;

  { If row is not formatted then use column style }
  if (RowXF = ADefaultXFIndex) then
  begin
    FXFTableIndex:= ColumnXF;
    Exit;
  end;

  { If column is not formatted then use row style }
  if (ColumnXF = ADefaultXFIndex) then
  begin
    FXFTableIndex:= RowXF;
    Exit;
  end;

  { If both row and column are formatted then merge styles }

  { <<<<<<< Prevent storing }
  FOwner.FPreventStoreItems:= True;

  ARow:= ASheet.FRows[FData.Row];
  AColumn:= ASheet.FColumns[FData.Col];

  {border color}
  if ARow.BorderColorIndex[xlBorderLeft] <> xlColorNone then
    BorderColorIndex[xlBorderLeft]:= ARow.BorderColorIndex[xlBorderLeft]
  else
    BorderColorIndex[xlBorderLeft]:= AColumn.BorderColorIndex[xlBorderLeft];

  if ARow.BorderColorIndex[xlBorderRight] <> xlColorNone then
    BorderColorIndex[xlBorderRight]:= ARow.BorderColorIndex[xlBorderRight]
  else
    BorderColorIndex[xlBorderRight]:= AColumn.BorderColorIndex[xlBorderRight];

  if ARow.BorderColorIndex[xlBorderTop] <> xlColorNone then
    BorderColorIndex[xlBorderTop]:= ARow.BorderColorIndex[xlBorderTop]
  else
    BorderColorIndex[xlBorderTop]:= AColumn.BorderColorIndex[xlBorderTop];

  if ARow.BorderColorIndex[xlBorderBottom] <> xlColorNone then
    BorderColorIndex[xlBorderBottom]:= ARow.BorderColorIndex[xlBorderBottom]
  else
    BorderColorIndex[xlBorderBottom]:= AColumn.BorderColorIndex[xlBorderBottom];

  {border style}
  if ARow.BorderStyle[xlBorderLeft] <> bsNone then
    BorderStyle[xlBorderLeft]:= ARow.BorderStyle[xlBorderLeft]
  else
    BorderStyle[xlBorderLeft]:= AColumn.BorderStyle[xlBorderLeft];

  if ARow.BorderStyle[xlBorderRight] <> bsNone then
    BorderStyle[xlBorderRight]:= ARow.BorderStyle[xlBorderRight]
  else
    BorderStyle[xlBorderRight]:= AColumn.BorderStyle[xlBorderRight];

  if ARow.BorderStyle[xlBorderTop] <> bsNone then
    BorderStyle[xlBorderTop]:= ARow.BorderStyle[xlBorderTop]
  else
    BorderStyle[xlBorderTop]:= AColumn.BorderStyle[xlBorderTop];

  if ARow.BorderStyle[xlBorderBottom] <> bsNone then
    BorderStyle[xlBorderBottom]:= ARow.BorderStyle[xlBorderBottom]
  else
    BorderStyle[xlBorderBottom]:= AColumn.BorderStyle[xlBorderBottom];

  {bg color}
  if ARow.FillPatternBGColorIndex <> xlColorNone then
    FillPatternBGColorIndex:= ARow.FillPatternBGColorIndex
  else
    FillPatternBGColorIndex:= AColumn.FillPatternBGColorIndex;

  {fg color}
  if ARow.FillPatternFGColorIndex <> xlColorAuto then
    FillPatternFGColorIndex:= ARow.FillPatternFGColorIndex
  else
    FillPatternFGColorIndex:= AColumn.FillPatternFGColorIndex;

  if ARow.FillPattern <> xlPatternNone then
    FillPattern:= ARow.FillPattern
  else
    FillPattern:= AColumn.FillPattern;

  if ARow.FormatStringIndex <> 0 then
    FormatStringIndex:= ARow.FormatStringIndex
  else
    FormatStringIndex:= AColumn.FormatStringIndex;

  if ARow.HAlign <> xlHAlignGeneral then
    HAlign:= ARow.HAlign
  else
    HAlign:= AColumn.HAlign;

  if ARow.VAlign <> xlVAlignTop then
    VAlign:= ARow.VAlign
  else
    VAlign:= AColumn.VAlign;

  Wrap:= ARow.Wrap or AColumn.Wrap;

  if ARow.Rotation <> 0 then
    Rotation:= ARow.Rotation
  else
    Rotation:= AColumn.Rotation;

  if ARow.Indent <> 0 then
    Indent:= ARow.Indent
  else
    Indent:= AColumn.Indent;

  FontBold:= ARow.FontBold or AColumn.FontBold;
  FontItalic:= ARow.FontItalic or AColumn.FontItalic;
  FontUnderline:= ARow.FontUnderline or AColumn.FontUnderline;
  FontStrikeOut:= ARow.FontStrikeOut or AColumn.FontStrikeOut;

  if ARow.FontUnderlineStyle <> xlFontUnderlineNone then
    FontUnderlineStyle:= ARow.FontUnderlineStyle
  else
    FontUnderlineStyle:= AColumn.FontUnderlineStyle;

  if ARow.FontSSStyle <> xlFontSSNone then
    FontSSStyle:= ARow.FontSSStyle
  else
    FontSSStyle:= AColumn.FontSSStyle;

  if ARow.FontName <> 'Arial' then
    FontName:= ARow.FontName
  else
    FontName:= AColumn.FontName;

  if ARow.FontColorIndex <> xlColorAuto then
    FontColorIndex:= ARow.FontColorIndex
  else
    FontColorIndex:= AColumn.FontColorIndex;

  if ARow.FontHeight <> 10 then
    FontHeight:= ARow.FontHeight
  else
    FontHeight:= AColumn.FontHeight;

  { >>>>>>>> Un-Prevent storing }
  FOwner.FPreventStoreItems:= False;
end;

procedure TCell.SetValue(AValue: Variant);
var
  AValueType, AOldValueType: Integer;

  procedure CheckString;
  begin
    if   (AValueType = xfVarString)
      or (AValueType = xfVarUString)
      or (AValueType = xfVarOleStr) then
      if Length(String(AValue)) > ((1 shl 16) - 1) then
        raise EXLSError.Create(EXLS_BADCELLVALUE);
  end;

begin
  AValueType:= VarType(AValue);
  AOldValueType:= VarType(FData.Value);

  case AValueType of
    xfVarSmallint,
    xfVarInteger,
    xfVarSingle,
    xfVarDouble,
    xfVarCurrency,
    xfVarByte,
    xfVarShortInt,
    xfVarWord,
    xfVarLongWord,
    xfVarInt64,
    xfVarDate,
    xfVarString,
    xfVarUString,
    xfVarOleStr,
    xfVarBoolean:
      begin
        CheckString;

        { If data type changed from non-date to date, and format is not
          changed (it is equal 0) - then set up default date format }
        if    (AValueType = xfVarDate) and (AOldValueType <> xfVarDate)
          and (FormatStringIndex = 0)  then
            SetFormatStringIndex(13);

        { type or value changed }
        if ( AOldValueType <> AValueType ) or ( FData.Value <> AValue ) then
          FData.Value:= AValue;

        if not VarIsNull(FData.Value) then
          FOwner.ForceStoreItem(Self);
      end;
    else
      raise EXLSError.Create(EXLS_BADCELLVALUE);
  end;
end;

procedure TCell.SetFormula(AFormula: AnsiString);
var
  FFormula: AnsiString;
begin
  FFormula:= GetFormula;
  if FFormula <> AFormula then
  begin
    FData.StringData:= SetStringDataItem(FData.StringData, 'F', AFormula);
    FOwner.ForceStoreItem(Self);
  end;
end;

function TCell.GetFormula: AnsiString;
begin
  Result:= GetStringDataItem(FData.StringData, 'F');
end;

procedure TCell.SetHyperlink(AHyperlink: WideString);
var
  FSHyperlink: AnsiString;
  ASHyperlink: AnsiString;
begin
  ASHyperlink:= WideStringToANSIWideString(AHyperlink);
  FSHyperlink:= WideStringToANSIWideString(GetHyperlink);
  if FSHyperlink <> ASHyperlink then
  begin
    FData.StringData:= SetStringDataItem(FData.StringData, 'H', ASHyperlink);
    SetFontColorIndex(xlColorBlue);
    SetFontUnderline(True);
    {if the  value not assigned then use hylerlink value}
    if VarIsEmpty(Self.Value) then
      Self.Value:= AHyperlink;

    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCell.SetHyperlinkType(AHyperlinkType: TCellHyperlinkType);
var
  B: Byte;
begin
  B:= Byte(AHyperlinkType);
  FData.StringData:= SetStringDataItem(FData.StringData, 'L', AnsiChar(B));
end;

function TCell.GetHyperlink: WideString;
var
  ASHyperlink: AnsiString;
begin
  ASHyperlink:= GetStringDataItem(FData.StringData, 'H');
  Result:= ANSIWideStringToWideString(ASHyperlink);
end;

function TCell.GetHyperlinkType: TCellHyperlinkType;
var
  SType: AnsiString;
begin
  SType:= GetStringDataItem(FData.StringData, 'L');
  if (SType <> '') then
    Result:= TCellHyperlinkType(Byte(SType[1]))
  else
    Result:= hltAuto;
end;

procedure TCell.SetRichFormat(ARichFormat: AnsiString);
var
  FRichFormat: AnsiString;
begin
  FRichFormat:= GetRichFormat;
  if FRichFormat <> ARichFormat then
  begin
    FData.StringData:= SetStringDataItem(FData.StringData, 'R', ARichFormat);
    FOwner.ForceStoreItem(Self);
  end;
end;

function TCell.GetRichFormat: AnsiString;
begin
  Result:= GetStringDataItem(FData.StringData, 'R');
end;

function TCell.GetValueAsString: WideString;
var
  FormatString: WideString;
begin
  { If data from file, get format from file }
  { If format is used-defined, use this format }
  if   (FCommonCellData.ProcessingState = psDataFromFile)
    or IfmtIsUserDefined(FCommonCellData.FormatStringsTable[FormatStringIndex].ifmt) then
    FormatString:= FCommonCellData.FormatStringsTable[FormatStringIndex].FormatString
  else
    FormatString:= '';

  Result:= FormatValueAsString( Value
            , FCommonCellData.FormatStringsTable[FormatStringIndex].ifmt
            , FormatString
            );
end;

{TCells}
constructor TCells.Create(const AOwner: TSheet);
begin
  inherited Create(AOwner);
end;

destructor TCells.Destroy;
begin
  inherited;
end;

procedure TCells.SetKey(ARow, ACol: Word; var Key: AnsiString);
begin
  SetLength(Key, 4);
  Key[1]:= AnsiChar(Lo(ARow));
  Key[2]:= AnsiChar(Hi(ARow));
  Key[3]:= AnsiChar(Lo(ACol));
  Key[4]:= AnsiChar(Hi(ACol));
end;

procedure TCells.GetItemKey(AItem: Pointer; var Key: AnsiString);
var
  C: TCell;
begin
  C:= TCell(AItem);
  SetKey(C.FData.Row, C.FData.Col, Key);
end;

function TCells.FindRowCol(ARow, ACol: Word): TCell;
var
  Key: AnsiString;
begin
  SetKey(ARow, ACol, Key);
  Result:= TCell(FItems.ItemByKey(Key));
end;

function TCells.GetCell(ARow, ACol: Word): TCell;
  procedure CheckRowCol;
  begin
    if ACol > (BIFF8_MAXCOLS - 1) then
      raise EXLSError.Create(EXLS_BADROWCOL);
  end;
begin
  CheckRowCol;
  Result:= FindRowCol(ARow, ACol);
  if not Assigned(Result) then
  begin
    if Assigned(FTmpItem) then
    begin
      FTmpItem.Destroy;
      FTmpItem:= nil;
    end;
    Result:= TCell.Create(Self, ARow, ACol, FCommonWorkbookCellData);
    FTmpItem:= Result;
  end;
end;

function TCells.GetCellByA1Ref(ACellA1Ref: AnsiString): TCell;
var
  CellCoord: TCellCoord;
begin
  {$IFDEF XLF_D2009}
  CellCoord:= ParseCellA1Ref(AnsiStrings.AnsiUpperCase(ACellA1Ref));
  {$ELSE}
  CellCoord:= ParseCellA1Ref(AnsiUpperCase(ACellA1Ref));
  {$ENDIF}
  Result:= GetCell(CellCoord.Row, CellCoord.Column);
end;

function TCells.GetItem(Ind: Integer): TCell;
begin
  Result:= TCell(inherited Item[Ind]);
end;

procedure TCells.RemoveCell(ACell: TCell);
var
  Key: AnsiString;
begin
  if ACell.FStored then
  begin
    GetItemKey(ACell, Key);
    FItems.RemoveItemByKey(Key);
    ACell.Destroy;
  end;
end;

procedure TCells.ClearCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word);
var
  I: Integer;
  C: TCell;
begin
  for I:= Count - 1 downto 0 do
  begin
    C:= Item[I];
    if    (C.Row >= ATopRow)
      and (C.Row <= ABottomRow)
      and (C.Col >= ALeftColumn)
      and (C.Col <= ARightColumn) then
      C.Clear;
  end;
end;

procedure TCells.InternalCellMove(const AIndex: Integer; const ANewRow, ANewColumn: Word);
var
  OldKey: AnsiString;
begin
  self.GetItemKey(Item[AIndex], OldKey);
  Item[AIndex].FData.Row:= ANewRow;
  Item[AIndex].FData.Col:= ANewColumn;
  FItems.ItemKeyChanged(AIndex, OldKey);
end;

procedure TCells.InternalCopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
  ADestTopRow, ADestLeftColumn: Integer;
  MoveCells: Boolean;
  ProcessRanges: Boolean);
var
  C: TCell;
  Chain: TList;
  CellIndex: Integer;
  CellsCount :Integer;
  ShiftedFlags: PAnsiChar;
  DeletedFlags: PAnsiChar;
  ADestRow, ADestColumn: Integer;

  procedure BuildChain;
  var
    FCellIndex: Integer;
    ADestRow, ADestColumn: Integer;
  begin
    FCellIndex:= CellIndex;

    repeat
      Chain.Add(Pointer(FCellIndex));

      { Find destination row and column }
      if not (   (C.Row + (ADestTopRow - ATopRow) <= ABottomRow)
             and (C.Row + (ADestTopRow - ATopRow) >= ATopRow)
             and (C.Col + (ADestLeftColumn - ALeftColumn) <= ARightColumn)
             and (C.Col + (ADestLeftColumn - ALeftColumn) >= ALeftColumn)
             ) then
      begin
        Break;
      end
      else
      begin
        ADestRow:= C.Row + (ADestTopRow - ATopRow);
        ADestColumn:= C.Col + (ADestLeftColumn - ALeftColumn);
        C:= Cell[ADestRow, ADestColumn];
        FCellIndex:= GetItemIndex(C);

        if (FCellIndex >= 0) and (FCellIndex < CellsCount) then
        begin
          if ShiftedFlags[FCellIndex] = #1 then
            Break;
        end
        else
          Break;
      end;

    until False;
  end;

  procedure ProcessChain;
  var
    I, FCellIndex, FPrevCellIndex: Integer;
    ADestRow, ADestColumn: Integer;
  begin
    if Chain.Count = 0 then Exit;

    { Process last cell }
    FPrevCellIndex:= Integer(Chain[Chain.Count - 1]);
    ShiftedFlags[FPrevCellIndex]:= #1;

    { If destination cell is out of sheet, not copy  }
    if    IsValidRow(Integer(Item[FPrevCellIndex].Row + (ADestTopRow - ATopRow)))
      and IsValidColumn(Integer(Item[FPrevCellIndex].Col + (ADestLeftColumn - ALeftColumn))) then
    begin
      ADestRow:= Item[FPrevCellIndex].Row + (ADestTopRow - ATopRow);
      ADestColumn:= Item[FPrevCellIndex].Col + (ADestLeftColumn - ALeftColumn);

      FCellIndex:= GetItemIndex(Cell[ADestRow, ADestColumn]);
      if (FCellIndex >=0) and (FCellIndex < CellsCount) then
        DeletedFlags[FCellIndex]:= #0;

      Cell[ADestRow, ADestColumn].CopyFromCell(Item[FPrevCellIndex]);
    end;

    { Shift chain }
    for I:= Chain.Count - 1 downto 1 do
    begin
      FCellIndex:= Integer(Chain[I]);
      FPrevCellIndex:= Integer(Chain[I - 1]);
      Item[FCellIndex].CopyFromCell(Item[FPrevCellIndex]);
      ShiftedFlags[FPrevCellIndex]:= #1;
      DeletedFlags[FCellIndex]:= #0;
    end;

    { Empty chain }
    Chain.Clear;
  end;

  procedure RemoveDeletedCells;
  var
    FCellIndex: Integer;
  begin
    for FCellIndex:= CellsCount - 1 downto 0 do
    begin
      if DeletedFlags[FCellIndex] = #1 then
        RemoveCell(Item[FCellIndex]);
    end;
  end;

  procedure AdjustRanges;
  var
    RangeInd: Integer;
    Range: TRange;
  begin
    for RangeInd:= 0 to FOwner.Ranges.RangesCount - 1 do
    begin
      Range:= FOwner.Ranges[RangeInd];
      if Range.Merged then
      begin
        Range.InternalShift(ATopRow, ABottomRow, ALeftColumn, ARightColumn
            , ADestTopRow, ADestLeftColumn, MoveCells);
        Range.MergeCells;
      end;
    end;
  end;

begin
  { If nothing to copy then exit }
  if (  (ALeftColumn > ARightColumn)
     or (ATopRow > ABottomRow)
     or ( (ATopRow = ADestTopRow) and (ALeftColumn = ADestLeftColumn) )
     ) then Exit;

  CellsCount:= Self.Count;

  { Init deleted flags }
  GetMem(DeletedFlags, CellsCount);
  FillChar(DeletedFlags^, CellsCount, 0);

  { Move cells }
  if MoveCells then
  begin
    for CellIndex:= 0 to CellsCount - 1 do
    begin
      C:= Item[CellIndex];
      if     (C.Row >= ATopRow)
         and (C.Row <= ABottomRow)
         and (C.Col >= ALeftColumn)
         and (C.Col <= ARightColumn)  then
      begin
        { If destination cell is out of sheet, not copy }
        if    IsValidRow(Integer(C.Row + (ADestTopRow - ATopRow)))
          and IsValidColumn(Integer(C.Col + (ADestLeftColumn - ALeftColumn))) then
        begin
          ADestRow:= C.Row + (ADestTopRow - ATopRow);
          ADestColumn:= C.Col + (ADestLeftColumn - ALeftColumn);
          InternalCellMove(CellIndex, ADestRow, ADestColumn);
        end
        else
        begin
          DeletedFlags[CellIndex]:= #1;
        end;
      end;
    end;
  end
  else
  { Copy cells }
  begin
    { Init objects }
    GetMem(ShiftedFlags, CellsCount);
    FillChar(ShiftedFlags^, CellsCount, 0);
    Chain:= TList.Create;

    for CellIndex:= 0 to CellsCount - 1 do
    begin
      C:= Item[CellIndex];

      { If a cell is not shifted and cell in the source range }
      if (ShiftedFlags[CellIndex] = #0)
         and (C.Row >= ATopRow)
         and (C.Row <= ABottomRow)
         and (C.Col >= ALeftColumn)
         and (C.Col <= ARightColumn)  then
      begin
        { Build and process shifting chain }
        BuildChain;
        ProcessChain;
      end;
    end;

    { Free objects }
    Chain.Destroy;
    FreeMem(ShiftedFlags);
  end;

  {Remove deleted cells}
  RemoveDeletedCells;

  { Adjust merged ranges}
  if ProcessRanges then
    AdjustRanges;

  { Free deleted flags }
  FreeMem(DeletedFlags);
end;

procedure TCells.MoveCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
  ADestTopRow, ADestLeftColumn: Word);
begin
  InternalCopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn,
    ADestTopRow, ADestLeftColumn, True, True);
end;

procedure TCells.CopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn: Word;
  ADestTopRow, ADestLeftColumn: Word);
begin
  InternalCopyCellsRange(ATopRow, ABottomRow, ALeftColumn, ARightColumn,
    ADestTopRow, ADestLeftColumn, False, True);
end;

procedure TCells.InternalDeleteRow(ARow: Word);
begin
  if ARow = BIFF8_MAXROWS - 1 then
    ClearCellsRange(ARow, ARow, 0, BIFF8_MAXCOLS - 1)
  else
    InternalCopyCellsRange(ARow + 1, BIFF8_MAXROWS - 1, 0, BIFF8_MAXCOLS - 1,
      ARow, 0, True, True);
end;

procedure TCells.InternalDeleteColumn(AColumn: Word);
begin
  if AColumn = BIFF8_MAXCOLS - 1 then
    ClearCellsRange(0, BIFF8_MAXROWS - 1, AColumn, AColumn)
  else
    InternalCopyCellsRange(0, BIFF8_MAXROWS - 1, AColumn + 1, BIFF8_MAXCOLS - 1,
      0, AColumn, True, True);
end;

procedure TCells.InternalInsertRow(ARowAfter: Word);
begin
  if ARowAfter = BIFF8_MAXROWS - 2 then
    ClearCellsRange(ARowAfter + 1, ARowAfter + 1, 0, BIFF8_MAXCOLS - 1)
  else if ARowAfter < BIFF8_MAXROWS - 2 then
    InternalCopyCellsRange(ARowAfter + 1, BIFF8_MAXROWS - 1, 0, BIFF8_MAXCOLS - 1,
      ARowAfter + 2, 0, True, True);
end;

procedure TCells.InternalInsertColumn(AfterColumn: Word);
begin
  if AfterColumn = BIFF8_MAXCOLS - 2 then
    ClearCellsRange(0, BIFF8_MAXROWS - 1, AfterColumn + 1, AfterColumn + 1)
  else if AfterColumn < BIFF8_MAXCOLS - 2 then
    InternalCopyCellsRange(0, BIFF8_MAXROWS - 1, AfterColumn + 1, BIFF8_MAXCOLS - 1,
      0, AfterColumn + 2, True, True);
end;

procedure TCells.InternalCopyRow(ASourceRow, ADestRow: Integer);
begin
  InternalCopyCellsRange(ASourceRow, ASourceRow, 0, BIFF8_MAXCOLS - 1,
    ADestRow, 0, False, True);
end;

procedure TCells.InternalCopyColumn(ASourceColumn, ADestColumn: Integer);
begin
  InternalCopyCellsRange(0, BIFF8_MAXROWS - 1, ASourceColumn, ASourceColumn,
    0, ADestColumn, False, True);
end;

{TCustomRowCol}
constructor TCustomRowCol.Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData);
begin
  inherited Create(AOwner, ACommonCellData);
  FIndex:= AIndex;
  FStored:= false;
  FSize:= 0;
  FOutlineLevel:= 0;
  FHidden:= False;
  FChanged:= False;
  FSizeChanged:= False;
end;

destructor TCustomRowCol.Destroy;
begin
  inherited;
end;

procedure TCustomRowCol.IncOutlineLevel;
begin
  if FOutlineLevel < BIFF_MAXOUTLINELEVEL - 1 then
  begin
    FOutlineLevel:= FOutlineLevel + 1;
    FChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomRowCol.DecOutlineLevel;
begin
  if FOutlineLevel > 0 then
  begin
    FOutlineLevel:= FOutlineLevel - 1;
    FChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TCustomRowCol.SetHidden(AHidden: Boolean);
begin
  if AHidden <> False then
  begin
    FHidden:= AHidden;
    FChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

{TRow}
constructor TRow.Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData);
begin
  inherited Create(AOwner, AIndex, ACommonCellData);
  InternalClear;
end;

procedure TRow.InternalClear;
begin
  FSizePx:= xlDefaultRowHeightPx;
  FSize:= PixToXLSHeight(FSizePx);
  FHidden:= False;
  FXFTableIndex:= FCommonCellData^.XFTable.DefaultIndex;
end;

procedure TRow.SetHeight(ASize: double);
begin
  if FSize <> ASize then begin
    FSize:= ASize;
    FSizePx:= round(XLSHeightToPix(ASize));
    FChanged:= True;
    FSizeChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TRow.SetHeightPx(ASizePx: Integer);
begin
  if FSizePx <> ASizePx then
  begin
    FSizePx:= ASizePx;
    FSize:= PixToXLSHeight(ASizePx);
    FChanged:= True;
    FSizeChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

function TRow.GetVisibleHeight: Double;
begin
  if FHidden then
    Result:= 0
  else
    Result:= FSize;
end;

function TRow.GetVisibleHeightPx: Integer;
begin
  if FHidden then
    Result:= 0
  else
    Result:= FSizePx;
end;

procedure TRow.AutoFit;
begin
  FSizeChanged:= False;
end;

procedure TRow.Clear;
begin
  if Assigned(FOwner) then
    TRows(FOwner).ClearRows(Index, Index);
end;

procedure TRow.InternalCopyFromRow(ASourceRow: TRow);
begin
  Height:= ASourceRow.Height;
  Hidden:= ASourceRow.Hidden;
  FXFTableIndex:= ASourceRow.FXFTableIndex;
  FOwner.ForceStoreItem(Self);
end;

{set format methods}
procedure TRow.SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFillPatternBGColorIndex(AColorIndex);
end;

procedure TRow.SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFillPatternFGColorIndex(AColorIndex);
end;

procedure TRow.SetFillPatternBGColorRGB(AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFillPatternBGColorRGB(AColorRGB);
end;

procedure TRow.SetFillPatternFGColorRGB(AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFillPatternFGColorRGB(AColorRGB);
end;

procedure TRow.SetFillPattern(APattern: TXLPattern);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFillPattern(APattern);
end;

procedure TRow.SetHAlign(AHalign: TCellHAlignment);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetHAlign(AHalign);
end;

procedure TRow.SetVAlign(AValign: TCellVAlignment);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetVAlign(AValign);
end;

procedure TRow.SetMerged(AMerged: Boolean);
begin
  inherited;
end;

procedure TRow.SetWrap(AWrap: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetWrap(AWrap);
end;

procedure TRow.SetRotation(ARotation: TCellRotation);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetRotation(ARotation);
end;

procedure TRow.SetIndent(AIndent: Byte);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetIndent(AIndent);
end;

procedure TRow.SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetBorderColorIndex(Index, AColorIndex);
end;

procedure TRow.SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetBorderColorRGB(Index, AColorRGB);
end;

procedure TRow.SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetBorderStyle(Index, AStyle);
end;

procedure TRow.SetFormatStringIndex(AFormatStringIndex: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFormatStringIndex(AFormatStringIndex);
end;


{ set font methods }
procedure TRow.SetFontBold(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontBold(AValue);
end;

procedure TRow.SetFontItalic(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontItalic(AValue);
end;

procedure TRow.SetFontUnderline(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontUnderline(AValue);
end;

procedure TRow.SetFontStrikeOut(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontStrikeOut(AValue);
end;

procedure TRow.SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontUnderlineStyle(AValue);
end;

procedure TRow.SetFontSSStyle(AValue: TXLFontSSStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontSSStyle(AValue);
end;

procedure TRow.SetFontName(AValue: WideString);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontName(AValue);
end;

procedure TRow.SetFontColorIndex(AValue: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontColorIndex(AValue);
end;

procedure TRow.SetFontColorRGB(AValue: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontColorRGB(AValue);
end;

procedure TRow.SetFontHeight(AValue: Word);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TRows(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Row = FIndex) then
          Item[I].SetFontHeight(AValue);
end;

{TColumn}
constructor TColumn.Create(AOwner: TCustomRowCols; AIndex: Word; const ACommonCellData: PCommonWorkbookCellData);
begin
  inherited Create(AOwner, AIndex, ACommonCellData);
  InternalClear;
end;

procedure TColumn.SetWidth(ASize: double);
begin
  if FSize <> ASize then
  begin
    FSize:= ASize;
    FSizePx:= round(XLSWidthToPix(ASize));
    FChanged:= True;
    FSizeChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

procedure TColumn.SetWidthPx(ASizePx: Integer);
begin
  if FSizePx <> ASizePx then
  begin
    FSizePx:= ASizePx;
    FSize:= PixToXLSWidth(ASizePx);
    FChanged:= True;
    FSizeChanged:= True;
    FOwner.ForceStoreItem(Self);
  end;
end;

function TColumn.GetVisibleWidth: Double;
begin
  if FHidden then
    Result:= 0
  else
    Result:= FSize;
end;

function TColumn.GetVisibleWidthPx: Integer;
begin
  if FHidden then
    Result:= 0
  else
    Result:= FSizePx;
end;

procedure TColumn.InternalClear;
begin
  FSizePx:= xlDefaultColumnWidthPx;
  FSize:= PixToXLSWidth(FSizePx);
  FHidden:= False;
  FXFTableIndex:= FCommonCellData^.XFTable.DefaultIndex;
end;

procedure TColumn.InternalCopyFromColumn(ASourceColumn: TColumn);
begin
  Width:= ASourceColumn.Width;
  Hidden:= ASourceColumn.Hidden;
  FXFTableIndex:= ASourceColumn.FXFTableIndex;
  FOwner.ForceStoreItem(Self);  
end;

procedure TColumn.Clear;
begin
  if Assigned(FOwner) then
    TColumns(FOwner).ClearColumns(Index, Index);
end;

{set format methods}
procedure TColumn.SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFillPatternBGColorIndex(AColorIndex);
end;

procedure TColumn.SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFillPatternFGColorIndex(AColorIndex);
end;

procedure TColumn.SetFillPatternBGColorRGB(AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFillPatternBGColorRGB(AColorRGB);
end;

procedure TColumn.SetFillPatternFGColorRGB(AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFillPatternFGColorRGB(AColorRGB);
end;

procedure TColumn.SetFillPattern(APattern: TXLPattern);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFillPattern(APattern);
end;

procedure TColumn.SetHAlign(AHalign: TCellHAlignment);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetHAlign(AHalign);
end;

procedure TColumn.SetVAlign(AValign: TCellVAlignment);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetVAlign(AValign);
end;

procedure TColumn.SetMerged(AMerged: Boolean);
begin
  inherited;
end;

procedure TColumn.SetWrap(AWrap: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetWrap(AWrap);
end;

procedure TColumn.SetRotation(ARotation: TCellRotation);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetRotation(ARotation);
end;

procedure TColumn.SetIndent(AIndent: Byte);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetIndent(AIndent);
end;

procedure TColumn.SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetBorderColorIndex(Index, AColorIndex);
end;

procedure TColumn.SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetBorderColorRGB(Index, AColorRGB);
end;

procedure TColumn.SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetBorderStyle(Index, AStyle);
end;

procedure TColumn.SetFormatStringIndex(AFormatStringIndex: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFormatStringIndex(AFormatStringIndex);
end;


{ set font methods }
procedure TColumn.SetFontBold(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontBold(AValue);
end;

procedure TColumn.SetFontItalic(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontItalic(AValue);
end;

procedure TColumn.SetFontUnderline(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontUnderline(AValue);
end;

procedure TColumn.SetFontStrikeOut(AValue: Boolean);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontStrikeOut(AValue);
end;

procedure TColumn.SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontUnderlineStyle(AValue);
end;

procedure TColumn.SetFontSSStyle(AValue: TXLFontSSStyle);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontSSStyle(AValue);
end;

procedure TColumn.SetFontName(AValue: WideString);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontName(AValue);
end;

procedure TColumn.SetFontColorIndex(AValue: TXLColorIndex);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontColorIndex(AValue);
end;

procedure TColumn.SetFontColorRGB(AValue: Integer);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontColorRGB(AValue);
end;

procedure TColumn.SetFontHeight(AValue: Word);
var
  I: Integer;
begin
  inherited;
  if Assigned(FOwner) then
    with TColumns(FOwner).FOwner.Cells do
      for I:= 0 to Count - 1 do
        if (Item[I].Col = FIndex) then
          Item[I].SetFontHeight(AValue);
end;

{TCustomRowCols}
constructor TCustomRowCols.Create(const AOwner: TSheet);
begin
  inherited Create(AOwner);
end;

destructor TCustomRowCols.Destroy;
begin
  inherited;
end;

procedure TCustomRowCols.SetKey(ANumber: Word; var Key: AnsiString);
begin
  SetLength(Key, 2);
  Key[1]:= AnsiChar(Lo(ANumber));
  Key[2]:= AnsiChar(Hi(ANumber));
end;

procedure TCustomRowCols.GetItemKey(AItem: Pointer; var Key: AnsiString);
begin
  SetKey(TCustomRowCol(AItem).Index, Key);
end;

function TCustomRowCols.FindByNumber(ANumber: Word): TCustomRowCol;
var
  Key: AnsiString;
begin
  SetKey(ANumber, Key);
  Result:= TCustomRowCol(FItems.ItemByKey(Key));
end;

{TColumns}
function TColumns.GetColumn(ACol: Word): TColumn;
begin
  Result:= TColumn(FindByNumber(ACol));
  if not Assigned(Result) then begin
    if Assigned(FTmpItem) then
      FTmpItem.Destroy;
    Result:= TColumn.Create(Self, ACol, FCommonWorkbookCellData);
    FTmpItem:= TCustomXLSItem(Result);
  end;
end;

function TColumns.GetItem(Ind: Integer): TColumn;
begin
  Result:= TColumn(inherited Item[Ind]);
end;

function TColumns.IsStored(ACol: Word): Boolean;
begin
  Result:= Assigned(FindByNumber(ACol));
end;

procedure TColumns.RemoveColumn(AColumn: TColumn);
var
  Key: AnsiString;
begin
  if AColumn.FStored then
  begin
    GetItemKey(AColumn, Key);
    FItems.RemoveItemByKey(Key);
    AColumn.Destroy;
  end;
end;

procedure TColumns.InternalCopyColumns(ALeftColumn, ARightColumn: Word;
  ADestLeftColumn: Integer; MoveColumns: Boolean);
var
  C: TColumn;
  Chain: TList;
  ColumnIndex: Integer;
  ColumnsCount :Integer;
  ShiftedFlags: PAnsiChar;
  DeletedFlags: PAnsiChar;
  ProcessRangesForCells: Boolean;  

  procedure BuildChain;
  var
    FColumnIndex: Integer;
    ADestColumn: Integer;
  begin
    FColumnIndex:= ColumnIndex;

    repeat
      Chain.Add(Pointer(FColumnIndex));

      { Find destination Column }
      if not (   (C.Index + (ADestLeftColumn - ALeftColumn) <= ARightColumn)
             and (C.Index + (ADestLeftColumn - ALeftColumn) >= ALeftColumn)
             ) then
      begin
        Break;
      end
      else
      begin
        ADestColumn:= C.Index + (ADestLeftColumn - ALeftColumn);
        C:= Column[ADestColumn];
        FColumnIndex:= GetItemIndex(C);

        if (FColumnIndex >= 0) and (FColumnIndex < ColumnsCount) then
        begin
          if ShiftedFlags[FColumnIndex] = #1 then
            Break;
        end
        else
          Break;
      end;

    until False;
  end;

  procedure ProcessChain;
  var
    I, FColumnIndex, FPrevColumnIndex: Integer;
    ADestColumn: Integer;
  begin
    if Chain.Count = 0 then Exit;

    { Process last cell }
    FPrevColumnIndex:= Integer(Chain[Chain.Count - 1]);
    ShiftedFlags[FPrevColumnIndex]:= #1;

    { If dest coords is out of sheet, then not copy }
    if IsValidColumn(Item[FPrevColumnIndex].Index + (ADestLeftColumn - ALeftColumn)) then
    begin
      ADestColumn:= Item[FPrevColumnIndex].Index + (ADestLeftColumn - ALeftColumn);

      FColumnIndex:= GetItemIndex(Column[ADestColumn]);
      if (FColumnIndex >=0) and (FColumnIndex < ColumnsCount) then
        DeletedFlags[FColumnIndex]:= #0;

      Column[ADestColumn].InternalCopyFromColumn(Item[FPrevColumnIndex]);
    end;

    { Shift chain }
    for I:= Chain.Count - 1 downto 1 do
    begin
      FColumnIndex:= Integer(Chain[I]);
      FPrevColumnIndex:= Integer(Chain[I - 1]);
      Item[FColumnIndex].InternalCopyFromColumn(Item[FPrevColumnIndex]);
      ShiftedFlags[FPrevColumnIndex]:= #1;
      DeletedFlags[FColumnIndex]:= #0;
    end;

    { If move then delete last Column in chain }
    if MoveColumns then
    begin
      DeletedFlags[FPrevColumnIndex]:= #1;
    end;

    { Empty chain }
    Chain.Clear;
  end;

  procedure RemoveDeletedColumns;
  var
    FColumnIndex: Integer;
  begin
    for FColumnIndex:= ColumnsCount - 1 downto 0 do
    begin
      if DeletedFlags[FColumnIndex] = #1 then
        RemoveColumn(Item[FColumnIndex]);
    end;
  end;

  procedure AdjustRanges;
  var
    RangeInd: Integer;
    Range: TRange;
    RangeIsMerged: Boolean;
  begin
    for RangeInd:= 0 to FOwner.Ranges.RangesCount - 1 do
    begin
      Range:= FOwner.Ranges[RangeInd];
      RangeIsMerged:= Range.Merged;

      if RangeIsMerged then
        Range.UnMergeCells;

      RangeRectsApplyColumnsShift(TRangeRects(Range), ALeftColumn, ARightColumn, ADestLeftColumn);

      if RangeIsMerged then
        Range.MergeCells;
    end;
  end;

begin
  { If nothing to copy then exit }
  if (  (ALeftColumn > ARightColumn)
     or (ALeftColumn = ADestLeftColumn)
     ) then Exit;

  { Copy/move columns }
  ColumnsCount:= Self.Count;
  if ColumnsCount > 0 then
  begin
    { Init labels }
    GetMem(ShiftedFlags, ColumnsCount);
    FillChar(ShiftedFlags^, ColumnsCount, 0);
    GetMem(DeletedFlags, ColumnsCount);
    FillChar(DeletedFlags^, ColumnsCount, 0);

    { If Move then mark all columns from ( destination \ source ) area for delete }
    if MoveColumns then
    begin
      for ColumnIndex:= 0 to ColumnsCount - 1 do
      begin
        C:= Item[ColumnIndex];

        { If a cell in ( destination \ source ) }
        if ( not ( (C.Index >= ALeftColumn)
               and (C.Index <= ARightColumn))
           )
           and
           (     (C.Index >= ADestLeftColumn)
             and (C.Index <= Integer(ARightColumn + (ADestLeftColumn - ALeftColumn)))
           ) then
          DeletedFlags[ColumnIndex]:= #1;
      end;
    end;

    { Shift Columns }
    Chain:= TList.Create;
    for ColumnIndex:= 0 to ColumnsCount - 1 do
    begin
      C:= Item[ColumnIndex];

      { If a Column is not shifted and Column in the source range }
      if (ShiftedFlags[ColumnIndex] = #0)
         and (C.Index >= ALeftColumn)
         and (C.Index <= ARightColumn) then
      begin
        { Build and process shifting chain }
        BuildChain;
        ProcessChain;
      end;
    end;

    RemoveDeletedColumns;

    { Free objects }
    Chain.Destroy;
    FreeMem(ShiftedFlags);
    FreeMem(DeletedFlags);
  end;

  {Copy cells}
  if Assigned(FOwner) then
  begin
    ProcessRangesForCells:= not MoveColumns;
    TSheet(FOwner).Cells.InternalCopyCellsRange(0, BIFF8_MAXROWS - 1
      , ALeftColumn, ARightColumn, 0, ADestLeftColumn
      , MoveColumns
      , ProcessRangesForCells
      );
  end;

  { Adjust merged ranges }
  if MoveColumns then
    AdjustRanges;
end;

procedure TColumns.DeleteColumns(ALeftColumn, ARightColumn: Word);
begin
  ClearColumns(ALeftColumn, ARightColumn);
  InternalCopyColumns(ARightColumn + 1, BIFF8_MAXCOLS - 1, ALeftColumn, True);
end;

procedure TColumns.InsertColumns(AColumnAfter: Word; ColumnCountToInsert: Word);
begin
  InternalCopyColumns(AColumnAfter + 1, BIFF8_MAXCOLS - 1, AColumnAfter + 1 + ColumnCountToInsert, True);
end;

procedure TColumns.ClearColumns(ALeftColumn, ARightColumn: Word);
var
  I: Integer;
  C: TColumn;
begin
  if (ALeftColumn > ARightColumn) then
    Exit;

  for I:= 0 to Count - 1 do
  begin
    C:= Item[I];
    if (C.Index>= ALeftColumn) and (C.Index <= ARightColumn) then
      C.InternalClear;
  end;

  { Clear cells }
  if Assigned(FOwner) then
    TSheet(FOwner).Cells.ClearCellsRange(0, BIFF8_MAXROWS - 1, ALeftColumn, ARightColumn);
end;

procedure TColumns.CopyColumns(ALeftColumn, ARightColumn: Word; ADestLeftColumn: Word);
begin
  InternalCopyColumns(ALeftColumn, ARightColumn, ADestLeftColumn, False);
end;

procedure TColumns.MoveColumns(ALeftColumn, ARightColumn: Word; ADestLeftColumn: Word);
begin
  InternalCopyColumns(ALeftColumn, ARightColumn, ADestLeftColumn, True);
end;

procedure TColumns.AutoFit(const ALeftColumn, ARightColumn: Word;
      const ATopRow, ABottomRow: Integer; const AMaxWidthPx: Word);
var
  Cells: TCells;
  FontTable: TVirtualFontTable;
  I, ColumnIndex, RowIndex: Integer;
  Width: Integer;
  ColumnWidth: array[0..BIFF8_MAXCOLS-1] of Integer;
  OldColumnWidth: array[0..BIFF8_MAXCOLS-1] of Integer;
begin
  if not Assigned(FOwner)
    then Exit;

  Cells:= TSheet(FOwner).Cells;
  FontTable:= TSheet(FOwner).FCommonWorkbookCellData.FontTable;

  { Init width array }
  for ColumnIndex:= 0 to BIFF8_MAXCOLS-1 do
  begin
    ColumnWidth[ColumnIndex]:= 0;
    OldColumnWidth[ColumnIndex]:= Self.Column[ColumnIndex].WidthPx;
  end;

  for I:= 0 to Cells.Count-1 do
  begin
    ColumnIndex:= Cells.Item[I].Col;
    RowIndex:= Cells.Item[I].Row;
    if     (ColumnIndex >= ALeftColumn) and (ColumnIndex <= ARightColumn)
       and (RowIndex>= ATopRow) and (RowIndex <= ABottomRow)
       then
    begin
      Width:= GetRichTextWidthPx(Cells.Item[I].ValueAsString
                                , Cells.Item[I].Rotation
                                , Cells.Item[I].RichFormat
                                , Cells.Item[I].GetFontTableIndex
                                , FontTable);

      { if a cell is wrapped and new width is more than old then not resize }
      if Cells.Item[I].Wrap and (Width > OldColumnWidth[ColumnIndex]) then
        Width:= 0;

      { if a cell is merged then not resize it }
      if Cells.Item[I].Merged then
        Width:= 0;
        
      if Width > 0 then
      begin
        if Width > AMaxWidthPx then Width:= AMaxWidthPx;
        if Width > ColumnWidth[ColumnIndex] then ColumnWidth[ColumnIndex]:= Width;
      end;
    end;
  end;

  { set column width }
  for ColumnIndex:= 0 to BIFF8_MAXCOLS-1 do
    if ColumnWidth[ColumnIndex] > 0 then
      Self.Column[ColumnIndex].WidthPx:= ColumnWidth[ColumnIndex];
end;

{$IFNDEF XLF_D3}
procedure TColumns.AutoFit(const ALeftColumn, ARightColumn: Word; const AMaxWidthPx: Word);
begin
  AutoFit(ALeftColumn, ARightColumn, 0, BIFF8_MAXROWS-1, AMaxWidthPx);
end;

procedure TColumns.AutoFit(const ALeftColumn, ARightColumn: Word);
begin
  AutoFit(ALeftColumn, ARightColumn, 0, BIFF8_MAXROWS-1, 10000);
end;

procedure TColumns.AutoFit;
begin
  AutoFit(0, BIFF8_MAXCOLS-1, 0, BIFF8_MAXROWS-1, 10000);
end;
{$ENDIF}

{TRows}
function TRows.GetRow(ARow: Word): TRow;
begin
  Result:= TRow(FindByNumber(ARow));
  if not Assigned(Result) then begin
    if Assigned(FTmpItem) then
      FTmpItem.Destroy;
    Result:= TRow.Create(Self, ARow, FCommonWorkbookCellData);
    FTmpItem:= TCustomXLSItem(Result);
  end;
end;

function TRows.GetItem(Ind: Integer): TRow;
begin
  Result:= TRow(inherited Item[Ind]);
end;

function TRows.IsStored(ARow: Word): Boolean;
begin
  Result:= Assigned(FindByNumber(ARow));
end;

procedure TRows.RemoveRow(ARow: TRow);
var
  Key: AnsiString;
begin
  if ARow.FStored then
  begin
    GetItemKey(ARow, Key);
    FItems.RemoveItemByKey(Key);
    ARow.Destroy;
  end;
end;

procedure TRows.InternalCopyRows(ATopRow, ABottomRow: Word;
  ADestTopRow: Integer; MoveRows: Boolean);
var
  R: TRow;
  Chain: TList;
  RowIndex: Integer;
  RowsCount :Integer;
  ShiftedFlags: PAnsiChar;
  DeletedFlags: PAnsiChar;
  ProcessRangesForCells: Boolean;

  procedure BuildChain;
  var
    FRowIndex: Integer;
    ADestRow: Integer;
  begin
    FRowIndex:= RowIndex;

    repeat
      Chain.Add(Pointer(FRowIndex));

      { Find destination row }
      if not (   (R.Index + (ADestTopRow - ATopRow) <= ABottomRow)
             and (R.Index + (ADestTopRow - ATopRow) >= ATopRow)
             ) then
      begin
        Break;
      end
      else
      begin
        ADestRow:= R.Index + (ADestTopRow - ATopRow);
        R:= Row[ADestRow];
        FRowIndex:= GetItemIndex(R);

        if (FRowIndex >= 0) and (FRowIndex < RowsCount) then
        begin
          if ShiftedFlags[FRowIndex] = #1 then
            Break;
        end
        else
          Break;
      end;

    until False;
  end;

  procedure ProcessChain;
  var
    I, FRowIndex, FPrevRowIndex: Integer;
    ADestRow: Integer;
  begin
    if Chain.Count = 0 then Exit;

    { Process last cell }
    FPrevRowIndex:= Integer(Chain[Chain.Count - 1]);
    ShiftedFlags[FPrevRowIndex]:= #1;

    { If dest coords is out of sheet, then not copy }
    if IsValidRow(Item[FPrevRowIndex].Index + (ADestTopRow - ATopRow)) then
    begin
      ADestRow:= Item[FPrevRowIndex].Index + (ADestTopRow - ATopRow);

      FRowIndex:= GetItemIndex(Row[ADestRow]);
      if (FRowIndex >=0) and (FRowIndex < RowsCount) then
        DeletedFlags[FRowIndex]:= #0;

      Row[ADestRow].InternalCopyFromRow(Item[FPrevRowIndex]);
    end;

    { Shift chain }
    for I:= Chain.Count - 1 downto 1 do
    begin
      FRowIndex:= Integer(Chain[I]);
      FPrevRowIndex:= Integer(Chain[I - 1]);
      Item[FRowIndex].InternalCopyFromRow(Item[FPrevRowIndex]);
      ShiftedFlags[FPrevRowIndex]:= #1;
      DeletedFlags[FRowIndex]:= #0;
    end;

    { If move then delete last Row in chain }
    if MoveRows then
    begin
      DeletedFlags[FPrevRowIndex]:= #1;
    end;

    { Empty chain }
    Chain.Clear;
  end;

  procedure RemoveDeletedRows;
  var
    FRowIndex: Integer;
  begin
    for FRowIndex:= RowsCount - 1 downto 0 do
    begin
      if DeletedFlags[FRowIndex] = #1 then
        RemoveRow(Item[FRowIndex]);
    end;
  end;

  procedure AdjustRanges;
  var
    RangeInd: Integer;
    Range: TRange;
    RangeIsMerged: Boolean;
  begin
    for RangeInd:= 0 to FOwner.Ranges.RangesCount - 1 do
    begin
      Range:= FOwner.Ranges[RangeInd];
      RangeIsMerged:= Range.Merged;

      if RangeIsMerged then
        Range.UnMergeCells;

      RangeRectsApplyRowsShift(TRangeRects(Range), ATopRow, ABottomRow, ADestTopRow);

      if RangeIsMerged then
        Range.MergeCells;
    end;
  end;

begin
  { If nothing to copy then exit }
  if (  (ATopRow > ABottomRow)
     or (ATopRow = ADestTopRow)
     ) then Exit;

  { Copy/move rows }
  RowsCount:= Self.Count;
  if RowsCount > 0 then
  begin
    { Init labels }
    GetMem(ShiftedFlags, RowsCount);
    FillChar(ShiftedFlags^, RowsCount, 0);
    GetMem(DeletedFlags, RowsCount);
    FillChar(DeletedFlags^, RowsCount, 0);

    { If Move then mark all rows from ( destination \ source ) area for delete }
    if MoveRows then
    begin
      for RowIndex:= 0 to RowsCount - 1 do
      begin
        R:= Item[RowIndex];

        { If a cell in ( destination \ source ) }
        if ( not ( (R.Index >= ATopRow)
               and (R.Index <= ABottomRow))
           )
           and
           (     (R.Index >= ADestTopRow)
             and (R.Index <= Integer(ABottomRow + (ADestTopRow - ATopRow)))
           ) then
          DeletedFlags[RowIndex]:= #1;
      end;
    end;

    { Shift rows }
    Chain:= TList.Create;
    for RowIndex:= 0 to RowsCount - 1 do
    begin
      R:= Item[RowIndex];

      { If a row is not shifted and row in the source range }
      if (ShiftedFlags[RowIndex] = #0)
         and (R.Index >= ATopRow)
         and (R.Index <= ABottomRow) then
      begin
        { Build and process shifting chain }
        BuildChain;
        ProcessChain;
      end;
    end;

    { Remove deleted rows from TRows }
    RemoveDeletedRows;

    { Free objects }
    Chain.Destroy;
    FreeMem(ShiftedFlags);
    FreeMem(DeletedFlags);
  end;


  {Copy cells}
  if Assigned(FOwner) then
  begin
    ProcessRangesForCells:= not MoveRows;
    TSheet(FOwner).Cells.InternalCopyCellsRange(ATopRow, ABottomRow,
      0, BIFF8_MAXCOLS - 1, ADestTopRow, 0, MoveRows, ProcessRangesForCells
      );
  end;

  { Adjust merged ranges }
  if MoveRows then
    AdjustRanges;
end;

procedure TRows.DeleteRows(ATopRow, ABottomRow: Word);
begin
  ClearRows(ATopRow, ABottomRow);
  InternalCopyRows(ABottomRow + 1, BIFF8_MAXROWS - 1, ATopRow, True);
end;

procedure TRows.InsertRows(ARowAfter: Word; RowCountToInsert: Word);
begin
  InternalCopyRows(ARowAfter + 1, BIFF8_MAXROWS - 1, ARowAfter + 1 + RowCountToInsert, True);
end;

procedure TRows.CopyRows(ATopRow, ABottomRow: Word; ADestTopRow: Word);
begin
  InternalCopyRows(ATopRow, ABottomRow, ADestTopRow, False);
end;

procedure TRows.MoveRows(ATopRow, ABottomRow: Word; ADestTopRow: Word);
begin
  InternalCopyRows(ATopRow, ABottomRow, ADestTopRow, True);
end;

procedure TRows.ClearRows(ATopRow, ABottomRow: Word);
var
  I: Integer;
  R: TRow;
begin
  if (ATopRow > ABottomRow) then
    Exit;

  for I:= 0 to Count - 1 do
  begin
    R:= Item[I];
    if (R.Index>= ATopRow) and (R.Index <= ABottomRow) then
      R.InternalClear;
  end;

  { Clear cells }
  if Assigned(FOwner) then
    TSheet(FOwner).Cells.ClearCellsRange(ATopRow, ABottomRow, 0, BIFF8_MAXCOLS - 1);
end;

{TRange}
constructor TRange.Create(ASheet: TSheet);
begin
  inherited Create;
  FSheet:= ASheet;
  FName:= '';
  FMerged:= false;
end;

constructor TRange.CreateFromA1Ref(ASheet: TSheet; ARangeA1Ref: AnsiString);
var
  Rects: TRangeRects;
begin
  Create(ASheet);
  Rects:= ParseRangeA1Ref(ARangeA1Ref);
  if Assigned(Rects) then
  begin
    AddRangeRects(Rects);
    Rects.Destroy;
  end;
end;

destructor TRange.Destroy;
begin
  inherited;
end;

function TRange.GetEmpty: Boolean;
begin
  Result:= (RectsCount = 0);
end;

procedure TRange.Clear;
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Clear;
end;

procedure TRange.InternalCopyFromRange(ASourceRange: TRange);
begin
  FName:= ASourceRange.Name;
  FMerged:= ASourceRange.Merged;
  AddRangeRects(ASourceRange);
end;

procedure TRange.SetBorderColorIndex(Index: TCellBorderIndex; AColorIndex: TXLColorIndex);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].BorderColorIndex[Index]:= AColorIndex;
end;

procedure TRange.SetBorderColorRGB(Index: TCellBorderIndex; AColorRGB: Integer);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].BorderColorRGB[Index]:= AColorRGB;
end;

procedure TRange.SetBorderStyle(Index: TCellBorderIndex; AStyle: TXLBorderStyle);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].BorderStyle[Index]:= AStyle;
end;

procedure TRange.SetValue(AValue: Variant);
var
  I: Integer;
  Row: Word;
  Column: Byte;
  ExitAfter1stSet: Boolean;
begin
  ExitAfter1stSet:= Self.Merged;
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
      begin
        FSheet.Cells[Row, Column].Value:= AValue;
        if ExitAfter1stSet then Exit;
      end;
end;

procedure TRange.SetFormula(AFormula: AnsiString);
var
  I: Integer;
  Row: Word;
  Column: Byte;
  ExitAfter1stSet: Boolean;
begin
  ExitAfter1stSet:= Self.Merged;
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
      begin
        FSheet.Cells[Row, Column].Formula:= AFormula;
        if ExitAfter1stSet then Exit;
      end;
end;

procedure TRange.SetHyperlink(AHyperlink: WideString);
var
  I: Integer;
  Row: Word;
  Column: Byte;
  ExitAfter1stSet: Boolean;
begin
  ExitAfter1stSet:= Self.Merged;
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
      begin
        FSheet.Cells[Row, Column].Hyperlink:= AHyperlink;
        if ExitAfter1stSet then Exit;
      end;
end;

procedure TRange.SetHyperlinkType(AHyperlinkType: TCellHyperlinkType);
var
  I: Integer;
  Row: Word;
  Column: Byte;
  ExitAfter1stSet: Boolean;
begin
  ExitAfter1stSet:= Self.Merged;
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
      begin
        FSheet.Cells[Row, Column].HyperlinkType:= AHyperlinkType;
        if ExitAfter1stSet then Exit;
      end;
end;

procedure TRange.SetFillPatternBGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FillPatternBGColorIndex:= AColorIndex;
end;

procedure TRange.SetFillPatternFGColorIndex(AColorIndex: TXLColorIndex);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FillPatternFGColorIndex:= AColorIndex;
end;

procedure TRange.SetFillPatternBGColorRGB(AColorRGB: Integer);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FillPatternBGColorRGB:= AColorRGB;
end;

procedure TRange.SetFillPatternFGColorRGB(AColorRGB: Integer);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FillPatternFGColorRGB:= AColorRGB;
end;

procedure TRange.SetFillPattern(APattern: TXLPattern);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FillPattern:= APattern;
end;

procedure TRange.SetHAlign(AHalign: TCellHAlignment);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].HAlign:= AHalign;
end;

procedure TRange.SetVAlign(AValign: TCellVAlignment);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].VAlign:= AValign;
end;

procedure TRange.SetWrap(AWrap: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Wrap:= AWrap;
end;

procedure TRange.SetLocked(ALocked: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Locked:= ALocked;
end;

procedure TRange.SetRotation(ARotation: TCellRotation);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Rotation:= ARotation;
end;

procedure TRange.SetIndent(AIndent: Byte);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Indent:= AIndent;
end;

procedure TRange.SetFormatStringIndex(AValue: Integer);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FormatStringIndex:= AValue;
end;

procedure TRange.SetFontBold(AValue: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontBold:= AValue;
end;

procedure TRange.SetFontItalic(AValue: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontItalic:= AValue;
end;

procedure TRange.SetFontUnderline(AValue: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontUnderline:= AValue;
end;

procedure TRange.SetFontStrikeOut(AValue: Boolean);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontStrikeOut:= AValue;
end;

procedure TRange.SetFontUnderlineStyle(AValue: TXLFontUnderlineStyle);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontUnderlineStyle:= AValue;
end;

procedure TRange.SetFontSSStyle(AValue: TXLFontSSStyle);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontSSSTyle:= AValue;
end;

procedure TRange.SetFontName(AValue: WideString);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontName:= AValue;
end;

procedure TRange.SetFontColorIndex(AValue: TXLColorIndex);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontColorIndex:= AValue;
end;

procedure TRange.SetFontColorRGB(AValue: Integer);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontColorRGB:= AValue;
end;

procedure TRange.SetFontHeight(AValue: Word);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].FontHeight:= AValue;
end;

procedure TRange.SetName(AName: WideString);
begin
  if Pos(' ', AName)>0 then
     raise EXLSError.CreateFmt(EXLS_INVALIDNAME, [AName]);
  if FName <> AName then
    FName:= AName;
end;

procedure TRange.MergeCells;
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  FMerged:= True;
  for I:= 0 to RectsCount - 1 do
  begin
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Merged:= True;
  end;
end;

procedure TRange.UnMergeCells;
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  FMerged:= False;
  for I:= 0 to RectsCount - 1 do
  begin
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
         FSheet.Cells[Row, Column].Merged:= False;
  end;
end;

procedure TRange.BordersOutline(AColorIndex: TXLColorIndex; AStyle: TXLBorderStyle);
var
  I: Integer;
  Row: Word;
  Column: Byte;
begin
  for I:= 0 to RectsCount - 1 do
    for Row:= Rect[I].RowFrom to Rect[I].RowTo do
      for Column:= Rect[I].ColumnFrom to Rect[I].ColumnTo do
      begin
        if Row = Rect[I].RowFrom then
        begin
          FSheet.Cells[Row, Column].BorderStyle[xlBorderTop]:= AStyle;
          FSheet.Cells[Row, Column].BorderColorIndex[xlBorderTop]:= AColorIndex;
        end;
        if Row = Rect[I].RowTo then
        begin
          FSheet.Cells[Row, Column].BorderStyle[xlBorderBottom]:= AStyle;
          FSheet.Cells[Row, Column].BorderColorindex[xlBorderBottom]:= AColorIndex;
        end;
        if Column = Rect[I].ColumnFrom then
        begin
          FSheet.Cells[Row, Column].BorderStyle[xlBorderLeft]:= AStyle;
          FSheet.Cells[Row, Column].BorderColorIndex[xlBorderLeft]:= AColorIndex;
        end;
        if Column = Rect[I].ColumnTo then
        begin
          FSheet.Cells[Row, Column].BorderStyle[xlBorderRight]:= AStyle;
          FSheet.Cells[Row, Column].BorderColorIndex[xlBorderRight]:= AColorIndex;
        end;
      end;
end;

procedure TRange.BordersOutlineRGB(AColorRGB: Integer; AStyle: TXLBorderStyle);
begin
  BordersOutline(ColorToXLSColorIndex(RGBToColor(AColorRGB)), ASTyle);
end;

procedure TRange.BordersEdge(AColorIndex: TXLColorIndex;
  AStyle: TXLBorderStyle; Edge: TCellBorderIndex);
var
  I: Integer;
  Row: Word;
  Column: Byte;
  rFrom, rTo    : Integer;
  cFrom, cTo    : Integer;
begin
  if Edge = xlBorderAll then
    begin
      BordersOutline(AColorIndex, AStyle);
      Exit;
    end;

  for I:= 0 to RectsCount - 1 do
  begin
    case Edge of
      xlBorderLeft     :
      begin
        cFrom := Rect[I].ColumnFrom;
        cTo   := Rect[I].ColumnFrom;
        rFrom := Rect[I].RowFrom;
        rTo   := Rect[I].RowTo;
      end;
      xlBorderRight    :
      begin
        rFrom := Rect[I].RowFrom;
        rTo   := Rect[I].RowTo;
        cFrom := Rect[I].ColumnTo;
        cTo   := Rect[I].ColumnTo;
      end;
      xlBorderTop      :
      begin
        cFrom := Rect[I].ColumnFrom;
        cTo   := Rect[I].ColumnTo;
        rFrom := Rect[I].RowFrom;
        rTo   := Rect[I].RowFrom;
      end;
      else {xlBorderBottom   :}
      begin
        cFrom := Rect[I].ColumnFrom;
        cTo   := Rect[I].ColumnTo;
        rFrom := Rect[I].RowTo;
        rTo   := Rect[I].RowTo;
      end;
    end;

    for Row:= rFrom to rTo do
      for Column:= cFrom to cTo do
      begin
        FSheet.Cells[Row, Column].BorderStyle[Edge] := AStyle;
        FSheet.Cells[Row, Column].BorderColorIndex[Edge]:= AColorIndex;
      end;
    end;
end;

procedure TRange.BordersEdgeRGB(AColorRGB: Integer; AStyle: TXLBorderStyle; Edge: TCellBorderIndex);
begin
  BordersEdge(ColorToXLSColorIndex(RGBToColor(AColorRGB)), ASTyle, Edge);
end;

{TRanges}
constructor TRanges.Create(ASheet: TSheet);
begin
  FSheet:= ASheet;
  FItems:= TList.Create;
end;

destructor TRanges.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      TRange(FItems[I]).Destroy;
  FItems.Destroy;

  inherited;  
end;

function TRanges.Add: TRange;
begin
  Result:= TRange.Create(FSheet);
  FItems.Add(Result);
end;

function TRanges.AddFromA1Ref(ARangeA1Ref: AnsiString): TRange;
begin
  Result:= TRange.CreateFromA1Ref(FSheet, ARangeA1Ref);
  FItems.Add(Result);
end;

function TRanges.GetRange(AIndex: Integer): TRange;
begin
  Result:= TRange(FItems[AIndex]);
end;

function TRanges.GetRangesCount: Integer;
begin
  Result:= FItems.Count;
end;

function TRanges.GetRangeByName(AName: WideString): TRange;
var
  I: Integer;
begin
  Result:= nil;
  for I:= 0 to FItems.Count - 1 do
    if TRange(FItems[I]).Name = AName then
    begin
      Result:= TRange(FItems[I]);
      break;
    end;
end;

{TPageSetup}
constructor TPageSetup.Create(ASheet: TSheet);
begin
  FSheet:= ASheet;
  PaperSize         := xlPaperDefault;
  Zoom              := true;
  Scale             := 100;
  StartPageNum      := xlAutomatic;
  FitPagesWidth     := 1;
  FitPagesHeight    := 1;
  PrintPagesOrder   := xlDownOver;
  Orientation       := xlPortrait;
  { Default margins values }
  HeaderMargin      := 0.5;
  FooterMargin      := 0.5;
  TopMargin         := 1;
  BottomMargin      := 1;
  LeftMargin        := 0.8;
  RightMargin       := 0.8;
  BlackAndWhite     := false;
  Draft             := false;
  PrintGrid         := false;
  PrintRowColLabels := false;
  CenterHorizontally:= false;
  CenterVertically  := false;
  HeaderText        := '';
  HeaderTextLeft    := '';
  HeaderTextRight   := '';
  FooterText        := '';
  FooterTextLeft    := '';
  FooterTextRight   := '';
  RowGroupAtTop     := False;
  ColumnGroupAtLeft := False;

  FPrintArea        := TRange.Create(ASheet);

  FPrintRowsOnEachPageFrom:= -1;
  FPrintRowsOnEachPageTo:= -1;
  FPrintColumnsOnEachPageFrom:= -1;
  FPrintColumnsOnEachPageTo:= -1;
end;

destructor TPageSetup.Destroy;
begin
  FPrintArea.Destroy;
  inherited;
end;

procedure TPageSetup.InternalCopy(ASourcePageSetup: TPageSetup);
begin
  FPrintArea.InternalCopyFromRange(ASourcePageSetup.FPrintArea);
  FPrintRowsOnEachPageFrom:= ASourcePageSetup.FPrintRowsOnEachPageFrom;
  FPrintRowsOnEachPageTo:= ASourcePageSetup.FPrintRowsOnEachPageTo;
  FPrintColumnsOnEachPageFrom:= ASourcePageSetup.FPrintColumnsOnEachPageFrom;
  FPrintColumnsOnEachPageTo:= ASourcePageSetup.FPrintColumnsOnEachPageTo;

  PaperSize         := ASourcePageSetup.PaperSize;
  Zoom              := ASourcePageSetup.Zoom;
  Scale             := ASourcePageSetup.Scale;
  StartPageNum      := ASourcePageSetup.StartPageNum;
  FitPagesWidth     := ASourcePageSetup.FitPagesWidth;
  FitPagesHeight    := ASourcePageSetup.FitPagesHeight;
  PrintPagesOrder   := ASourcePageSetup.PrintPagesOrder;
  Orientation       := ASourcePageSetup.Orientation;
  HeaderMargin      := ASourcePageSetup.HeaderMargin;
  FooterMargin      := ASourcePageSetup.FooterMargin;
  TopMargin         := ASourcePageSetup.TopMargin;
  BottomMargin      := ASourcePageSetup.BottomMargin;
  LeftMargin        := ASourcePageSetup.LeftMargin;
  RightMargin       := ASourcePageSetup.RightMargin;
  BlackAndWhite     := ASourcePageSetup.BlackAndWhite;
  Draft             := ASourcePageSetup.Draft;
  PrintGrid         := ASourcePageSetup.PrintGrid;
  PrintRowColLabels := ASourcePageSetup.PrintRowColLabels;
  CenterHorizontally:= ASourcePageSetup.CenterHorizontally;
  CenterVertically  := ASourcePageSetup.CenterVertically;
  HeaderText        := ASourcePageSetup.HeaderText;
  HeaderTextLeft    := ASourcePageSetup.HeaderTextLeft;
  HeaderTextRight   := ASourcePageSetup.HeaderTextRight;
  FooterText        := ASourcePageSetup.FooterText;
  FooterTextLeft    := ASourcePageSetup.FooterTextLeft;
  FooterTextRight   := ASourcePageSetup.FooterTextRight;
  RowGroupAtTop     := ASourcePageSetup.RowGroupAtTop;
  ColumnGroupAtLeft := ASourcePageSetup.ColumnGroupAtLeft;
end;

procedure TPageSetup.PrintTitleRows(const RowFrom, RowTo: Integer);
begin
  FPrintRowsOnEachPageFrom:= RowFrom;
  FPrintRowsOnEachPageTo:= RowTo;
end;

procedure TPageSetup.PrintTitleColumns(const ColumnFrom, ColumnTo: Integer);
begin
  FPrintColumnsOnEachPageFrom:= ColumnFrom;
  FPrintColumnsOnEachPageTo:= ColumnTo;
end;

{TXLSImage}
constructor TXLSImage.Create(const AFileName: AnsiString;
  const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
begin
  FFileName:= AFileName;
  FLeftColumn:= ALeftColumn;
  FTopRow:= ATopRow;
  FRightColumn:= ARightColumn;
  FBottomRow:= ABottomRow;
  FImageData:= nil;
  FImageType:= xlimgNone;
  FBLIPType:= MSOBLIP_UNKNOWN;
  FLeftColumnOffsetPx:= 0;
  FTopRowOffsetPx:= 0;
  FStretchToWidthPx:= 0;
  FStretchToHeightPx:= 0;
end;

constructor TXLSImage.CreateFromStream(Stream: TEasyStream;
  const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
begin
  FImageData:= Stream;
  FFileName:= '';
  FLeftColumn:= ALeftColumn;
  FTopRow:= ATopRow;
  FRightColumn:= ARightColumn;
  FBottomRow:= ABottomRow;
  FLeftColumnOffsetPx:= 0;
  FTopRowOffsetPx:= 0;
  FStretchToWidthPx:= 0;
  FStretchToHeightPx:= 0;
end;

constructor TXLSImage.CreatePx(const AFileName: AnsiString;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
  const AStretchToWidthPx, AStretchToHeightPx: Integer);
begin
  FFileName:= AFileName;
  FLeftColumn:= ALeftColumn;
  FTopRow:= ATopRow;
  FRightColumn:= -1;
  FBottomRow:= -1;
  FLeftColumnOffsetPx:= ALeftColumnOffsetPx;
  FTopRowOffsetPx:= ATopRowOffsetPx;
  FStretchToWidthPx:= AStretchToWidthPx;
  FStretchToHeightPx:= AStretchToHeightPx;
  FImageData:= nil;
end;

constructor TXLSImage.CreateFromStreamPx(Stream: TEasyStream;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
  const AStretchToWidthPx, AStretchToHeightPx: Integer);
begin
  FImageData:= Stream;
  FFileName:= '';
  FLeftColumn:= ALeftColumn;
  FTopRow:= ATopRow;
  FRightColumn:= -1;
  FBottomRow:= -1;
  FLeftColumnOffsetPx:= ALeftColumnOffsetPx;
  FTopRowOffsetPx:= ATopRowOffsetPx;
  FStretchToWidthPx:= AStretchToWidthPx;
  FStretchToHeightPx:= AStretchToHeightPx;
end;

destructor TXLSImage.Destroy;
begin
  if Assigned(FImageData) then
    FImageData.Destroy;
  inherited;    
end;

function TXLSImage.GetImageType: TXLSImageType;
var
  DataFromFile: Boolean;
  TmpImageData: TEasyStream;
  Buff: array[0..10] of Byte;
  BLIPType: Integer;
begin
  if FImageType <> xlimgNone then
  begin
    Result:= FImageType;
    Exit;
  end;

  DataFromFile:= True;
  if Assigned(FImageData) then
  begin
    DataFromFile:= False;
    TmpImageData:= ImageData;
  end
  else
    TmpImageData:= TEasyStream.Create;

  try
    if DataFromFile then
      TmpImageData.LoadFromFile(String(FFileName));

    { Get type }
    FImageType:= xlimgNone;
    TmpImageData.Position:= 0;
    TmpImageData.ReadBuffer(Buff[0], 10);
    TmpImageData.Position:= 0;    
    BLIPType:= RecognizeBLIPType(@Buff[0]);
    Self.FBLIPType:= BLIPType;

    case BLIPType of
      MSOBLIP_JPEG : FImageType:= xlimgJPG;
      MSOBLIP_PNG  : FImageType:= xlimgPNG;
      MSOBLIP_DIB  : FImageType:= xlimgBMP;
      MSOBLIP_EMF  : FImageType:= xlimgEMF;
      MSOBLIP_WMF  : FImageType:= xlimgWMF;
    end;
  finally
    if DataFromFile then TmpImageData.Destroy;
  end;

  Result:= FImageType;
end;

procedure TXLSImage.SaveAs(const AFileName: AnsiString; const AutoExtension: Boolean);
var
  OutFileName: AnsiString;
  TmpImageData: TEasyStream;
  ImageType: TXLSImageType;
begin
  TmpImageData:= TEasyStream.Create;

  try
    if Assigned(FImageData) then
    begin
      TmpImageData.CopyFrom(FImageData, 0);
      FImageData.Position:= 0;
    end
    else
      TmpImageData.LoadFromFile(String(FFileName));

    { Get type }
    ImageType:= Self.GetImageType;

    { Get name }
    OutFileName:= AFileName;
    if AutoExtension then
      case ImageType of
        xlimgBMP: OutFileName:= OutFileName + '.bmp';
        xlimgJPG: OutFileName:= OutFileName + '.jpg';
        xlimgPNG: OutFileName:= OutFileName + '.png';
        xlimgWMF: OutFileName:= OutFileName + '.wmz';
        xlimgEMF: OutFileName:= OutFileName + '.emz';
      end;

    SaveImageStreamToFile(TmpImageData, OutFileName, Self.FBLIPType);
  finally
    TmpImageData.Destroy;
  end;
end;

{TXLSImages}
constructor TXLSImages.Create(ASheet: TSheet);
begin
  FItems:= TList.Create;
end;

destructor TXLSImages.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      Item[I].Destroy;
  FItems.Destroy;

  inherited;  
end;

function TXLSImages.GetItem(Index: Integer): TXLSImage;
begin
  Result:= TXLSImage(FItems[Index]);
end;

function TXLSImages.GetCount: Integer;
begin
  Result:= FItems.Count;
end;

procedure TXLSImages.AddStretch(const AFileName: AnsiString;
  const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
var
  Image: TXLSImage;
begin
  Image:= TXLSImage.Create(AFileName, ALeftColumn, ATopRow, ARightColumn, ABottomRow);
  FItems.Add(Image);
end;

procedure TXLSImages.Delete(Index: Integer);
begin
  if Assigned(FItems[Index]) then
    Item[Index].Destroy;

  FItems.Delete(Index);  
end;

procedure TXLSImages.Clear;
var
  I: Integer;
begin
  for I:= 0 to FItems.Count - 1 do
    if Assigned(FItems[I]) then
      Item[I].Destroy;

  FItems.Clear;
end;

procedure TXLSImages.Add(const AFileName: AnsiString;
  const ALeftColumn, ATopRow: Integer);
begin
  AddStretch(AFileName, ALeftColumn, ATopRow, -1, -1);
end;

procedure TXLSImages.AddStretchFromStream(AStream: TStream;
  const AStreamPositionFrom, AStreamBytesToRead: Integer;
  const ALeftColumn, ATopRow, ARightColumn, ABottomRow: Integer);
var
  Image: TXLSImage;
  Stream: TEasyStream;
begin
  { Get data from AStream to Stream }
  Stream:= TEasyStream.Create;
  AStream.Position:= AStreamPositionFrom;
  Stream.CopyFrom(AStream, AStreamBytesToRead);

  { Create image, and add to list }
  Image:= TXLSImage.CreateFromStream(Stream, ALeftColumn, ATopRow, ARightColumn, ABottomRow);
  FItems.Add(Image);
end;

procedure TXLSImages.AddFromStream(AStream: TStream;
  const AStreamPositionFrom, AStreamBytesToRead: Integer;
  const ALeftColumn, ATopRow: Integer);
begin
  AddStretchFromStream(AStream, AStreamPositionFrom, AStreamBytesToRead,
    ALeftColumn, ATopRow, -1, -1);
end;

procedure TXLSImages.AddPx(const AFileName: AnsiString;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer);
begin
  AddStretchPx(AFileName, ALeftColumn, ATopRow,
    ALeftColumnOffsetPx, ATopRowOffsetPx, 0, 0);
end;

procedure TXLSImages.AddStretchPx(const AFileName: AnsiString;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
  const AStretchToWidthPx, AStretchToHeightPx: Integer);
var
  Image: TXLSImage;
begin
  Image:= TXLSImage.CreatePx(AFileName, ALeftColumn, ATopRow,
    ALeftColumnOffsetPx, ATopRowOffsetPx, AStretchToWidthPx, AStretchToHeightPx);
  FItems.Add(Image);
end;

procedure TXLSImages.AddFromStreamPx(AStream: TStream;
  const AStreamPositionFrom, AStreamBytesToRead: Integer;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer);
begin
  AddStretchFromStreamPx(AStream, AStreamPositionFrom, AStreamBytesToRead,
    ALeftColumn, ATopRow,
    ALeftColumnOffsetPx, ATopRowOffsetPx, 0, 0);
end;

procedure TXLSImages.AddStretchFromStreamPx(AStream: TStream;
  const AStreamPositionFrom, AStreamBytesToRead: Integer;
  const ALeftColumn, ATopRow: Integer;
  const ALeftColumnOffsetPx, ATopRowOffsetPx: Integer;
  const AStretchToWidthPx, AStretchToHeightPx: Integer);
var
  Image: TXLSImage;
  Stream: TEasyStream;
begin
  { Get data from AStream to Stream }
  Stream:= TEasyStream.Create;
  AStream.Position:= AStreamPositionFrom;
  Stream.CopyFrom(AStream, AStreamBytesToRead);

  { Create image, and add to list }
  Image:= TXLSImage.CreateFromStreamPx(Stream,
    ALeftColumn, ATopRow,
    ALeftColumnOffsetPx, ATopRowOffsetPx,
    AStretchToWidthPx, AStretchToHeightPx);
  FItems.Add(Image)
end;

procedure TXLSImages.AddItem(AImage: TXLSImage);
begin
  FItems.Add(AImage);
end;

{TSheet}
constructor TSheet.Create(AWbk: TWorkbook);
begin
  FWbk:= AWbk;
  FCommonWorkbookCellData:= @FWbk.FCommonWorkbookCellData;
  FProtectPassword:= '';
  FProtectPasswordHash:= 0;
  FProtectMode:= BIFF8_SHEETPROTECT_DEFAULT;   

  FCells:= TCells.Create(Self);
  FColumns:= TColumns.Create(Self);
  FRows:= TRows.Create(Self);
  FRanges:= TRanges.Create(Self);
  FPageSetup:= TPageSetup.Create(Self);
  FPageBreaks:= TCellCoords.Create;
  FImages:= TXLSImages.Create(Self);
  FCellValidations:= TCellValidations.Create;
  FCellComments:= TCellComments.Create;
  FVisible:= True;
  
  RefreshIndex;

  {window options}
  WindowOptions.DisplayGrids:= True;
  WindowOptions.DisplayRightToLeft:= False;
  WindowOptions.DisplayRowColHeaders:= True;
  WindowOptions.DisplayZero:= True;
  WindowOptions.FreezePoint.Row:= 0;
  WindowOptions.FreezePoint.Column:= 0;
  WindowOptions.ZoomPercent:= 100;
  WindowOptions.PageBreakPreview:= False;
end;

destructor TSheet.Destroy;
begin
  FCells.Destroy;
  FColumns.Destroy;
  FRows.Destroy;
  FRanges.Destroy;
  FPageSetup.Destroy;
  FPageBreaks.Destroy;
  FImages.Destroy;
  FCellValidations.Destroy;
  FCellComments.Destroy;
  inherited;  
end;

procedure TSheet.RefreshIndex;
begin
  FIndex:= FWbk.Sheets.FSheets.IndexOf(Pointer(Self));
end;

function TSheet.GetIsProtected: Boolean;
begin
  Result:= (FProtectPasswordHash <> 0);
end;

procedure TSheet.SetName(AName: WideString);
var
  Err: TXLSErrorCode;
begin
  Err:= FWbk.FSheets.VerifySheetName(AName);
  if Err <> EXLS_NOERROR then
    raise EXLSError.Create(Err)
  else
    if FName <> AName then
      FName:= AName;
end;

procedure TSheet.CopyFromSheet(ASourceSheet: TSheet);
var
  Row: Word;
  Column: Byte;
  I: Integer;
  Range: TRange;
begin
  { Copy cells }
  for I:= 0 to ASourceSheet.Cells.Count - 1 do
  begin
    Row:= ASourceSheet.Cells.Item[I].Row;
    Column:= ASourceSheet.Cells.Item[I].Col;
    Cells[Row, Column].CopyFromCell(ASourceSheet.Cells.Item[I]);
  end;

  { Copy rows }
  for I:= 0 to ASourceSheet.Rows.Count - 1 do
  begin
    Row:= ASourceSheet.Rows.Item[I].Index;
    Rows[Row].InternalCopyFromRow(ASourceSheet.Rows.Item[I]);
  end;

  { Copy columns }
  for I:= 0 to ASourceSheet.Columns.Count - 1 do
  begin
    Column:= ASourceSheet.Columns.Item[I].Index;
    Columns[Column].InternalCopyFromColumn(ASourceSheet.Columns.Item[I]);
  end;

  { Copy ranges }
  for I:= 0 to ASourceSheet.Ranges.RangesCount - 1 do
  begin
    Range:= Ranges.Add;
    Range.InternalCopyFromRange(ASourceSheet.Ranges[I]);
  end;

  { Copy page setup }
  PageSetup.InternalCopy(ASourceSheet.PageSetup);

  { Copy page breaks }
  FPageBreaks.AddCellCoords(ASourceSheet.PageBreaks);

  { Copy images }
  for I:= 0 to ASourceSheet.Images.Count - 1 do
    FImages.AddStretch(
      ASourceSheet.Images[I].FileName,
      ASourceSheet.Images[I].LeftColumn,
      ASourceSheet.Images[I].TopRow,
      ASourceSheet.Images[I].RightColumn,
      ASourceSheet.Images[I].BottomRow);

  { Copy window options }
  WindowOptions:= ASourceSheet.WindowOptions;
end;

procedure TSheet.GroupRows(const ARowFrom, ARowTo: Word);
var
  Row: Word;
begin
  for Row:= ARowFrom to ARowTo do
    Rows[Row].IncOutlineLevel;
end;

procedure TSheet.GroupColumns(const AColumnFrom, AColumnTo: Byte);
var
  Column: Byte;
begin
  for Column:= AColumnFrom to AColumnTo do
    Columns[Column].IncOutlineLevel;
end;

procedure TSheet.UnGroupRows(const ARowFrom, ARowTo: Word);
var
  Row: Word;
begin
  for Row:= ARowFrom to ARowTo do
    Rows[Row].DecOutlineLevel;
end;

procedure TSheet.UnGroupColumns(const AColumnFrom, AColumnTo: Byte);
var
  Column: Byte;
begin
  for Column:= AColumnFrom to AColumnTo do
    Columns[Column].DecOutlineLevel;
end;

function TSheet.FindMergedRectContainingCellCoord(const ARow: Word;
  const AColumn: Byte; var ARect: TRangeRect): Boolean;
var
  I: Integer;
begin
  Result:= False;
  for I:= 0 to FRanges.RangesCount - 1 do
  begin
    if FRanges.Range[I].Merged then
    begin
      Result:= FRanges.Range[I].FindRectContainingCellCoord(ARow, AColumn, ARect);
      if Result then Exit;
    end;
  end;
end;

function TSheet.FindMergedRectContainingCell(ACell: TCell;
  var ARect: TRangeRect): Boolean;
begin
  Result:= FindMergedRectContainingCellCoord(ACell.Row, ACell.Col, ARect);
end;

function TSheet.GetUsedRect(var ARect: TRangeRect): Boolean;
var
  I: Integer;
begin
  { If cells count is 0 then the used range is empty }
  Result:= (Cells.Count <> 0);
  if not Result then Exit;

  ARect.RowFrom:= Word(BIFF8_MAXROWS - 1);
  ARect.ColumnFrom:= Byte(BIFF8_MAXCOLS - 1);
  ARect.RowTo:= 0;
  ARect.ColumnTo:= 0;

  for I:= 0 to Cells.Count - 1 do
  begin
    if Cells.Item[I].Row > ARect.RowTo then ARect.RowTo:= Cells.Item[I].Row;
    if Cells.Item[I].Col > ARect.ColumnTo then ARect.ColumnTo:= Cells.Item[I].Col;
    if Cells.Item[I].Row < ARect.RowFrom then ARect.RowFrom:= Cells.Item[I].Row;
    if Cells.Item[I].Col < ARect.ColumnFrom then ARect.ColumnFrom:= Cells.Item[I].Col;
  end;
end;

procedure TSheet.Freeze(const ARow: Word; AColumn: Byte);
begin
  WindowOptions.FreezePoint.Row:= ARow;
  WindowOptions.FreezePoint.Column:= AColumn;
end;

procedure TSheet.UnFreeze;
begin
  WindowOptions.FreezePoint.Row:= 0;
  WindowOptions.FreezePoint.Column:= 0;
end;

procedure TSheet.Protect(const APassword: AnsiString);
begin
  ProtectWithMode(APassword, BIFF8_SHEETPROTECT_DEFAULT);
end;

procedure TSheet.ProtectWithMode(const APassword: AnsiString; const AProtectMode: Word);
begin
  FProtectPassword:= APassword;
  FProtectPasswordHash:= XLSProtectGetPasswordHash(APassword);
  FProtectMode:= AProtectMode;
end;

function TSheet.UnProtect(const APassword: AnsiString): Boolean;
var
  APasswordHash: Word;
begin
  Result:= False;
  APasswordHash:= XLSProtectGetPasswordHash(APassword);
  if (APasswordHash = FProtectPasswordHash) then
  begin
    Result:= True;
    FProtectPassword:= '';
    FProtectPasswordHash:= 0;
    FProtectMode:= BIFF8_SHEETPROTECT_DEFAULT;
  end;
end;

procedure TSheet.UnProtectWithoutPassword;
begin
  FProtectPassword:= '';
  FProtectPasswordHash:= 0;
  FProtectMode:= BIFF8_SHEETPROTECT_DEFAULT;  
end;

procedure TSheet.SaveAsHTML(const AFileName: AnsiString);
var
  UsedRect: TRangeRect;
  Writer: TXLSWriterHTML;
begin
  if GetUsedRect(UsedRect) then
  begin
    Writer:= TXLSWriterHTML.Create(Self);
    try
      Writer.Save(AFileName, UsedRect);
    finally
      Writer.Destroy;
    end;
  end;
end;

procedure TSheet.SaveToStreamAsHTML(const AStream: TStream);
var
  UsedRect: TRangeRect;
  Writer: TXLSWriterHTML;
begin
  if GetUsedRect(UsedRect) then
  begin
    Writer:= TXLSWriterHTML.Create(Self);
    try
      Writer.SaveToStream(AStream, UsedRect);
    finally
      Writer.Destroy;
    end;
  end;
end;

procedure TSheet.SaveRectAsHTML(const AFileName: AnsiString; const ARect: TRangeRect);
var
  Writer: TXLSWriterHTML;
begin
  Writer:= TXLSWriterHTML.Create(Self);
  try
    Writer.Save(AFileName, ARect);
  finally
    Writer.Destroy;
  end;
end;

procedure TSheet.SaveRectToStreamAsHTML(const AStream: TStream; const ARect: TRangeRect);
var
  Writer: TXLSWriterHTML;
begin
  Writer:= TXLSWriterHTML.Create(Self);
  try
    Writer.SaveToStream(AStream, ARect);
  finally
    Writer.Destroy;
  end;
end;

procedure TSheet.SaveAsTXT(const AFileName: AnsiString; const AFileType: TTXTFileType);
var
  UsedRect: TRangeRect;
  Writer: TXLSWriterTXT;
begin
  if GetUsedRect(UsedRect) then
  begin
    Writer:= TXLSWriterTXT.Create(Self);
    try
      Writer.Save(AFileName, AFileType, UsedRect);
    finally
      Writer.Destroy;
    end;
  end;
end;

procedure TSheet.SaveToStreamAsTXT(const AStream: TStream; const AFileType: TTXTFileType);
var
  UsedRect: TRangeRect;
  Writer: TXLSWriterTXT;
begin
  if GetUsedRect(UsedRect) then
  begin
    Writer:= TXLSWriterTXT.Create(Self);
    try
      Writer.SaveToStream(AStream, AFileType, UsedRect);
    finally
      Writer.Destroy;
    end;
  end;
end;

procedure TSheet.SaveRectAsTXT(const AFileName: AnsiString; const AFileType: TTXTFileType; const ARect: TRangeRect);
var
  Writer: TXLSWriterTXT;
begin
  Writer:= TXLSWriterTXT.Create(Self);
  try
    Writer.Save(AFileName, AFileType, ARect);
  finally
    Writer.Destroy;
  end;
end;

procedure TSheet.SaveRectToStreamAsTXT(const AStream: TStream; const AFileType: TTXTFileType; const ARect: TRangeRect);
var
  Writer: TXLSWriterTXT;
begin
  Writer:= TXLSWriterTXT.Create(Self);
  try
    Writer.SaveToStream(AStream, AFileType, ARect);
  finally
    Writer.Destroy;
  end;
end;

{TSheets}
constructor TSheets.Create(AWbk: TWorkbook);
begin
  FSheets:= TList.Create;
  FWbk:= AWbk;
end;

destructor TSheets.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FSheets.Count -1 do
    TSheet(FSheets[I]).Destroy;
  FSheets.Destroy;
  inherited;
end;

function TSheets.GetSheet(Ind: Integer): TSheet;
begin
  if (Ind>=0) and (Ind< FSheets.Count) then
    Result:= TSheet(FSheets[Ind])
  else
    raise ERangeError.Create('List index (' + IntToStr(Ind) + ') out of bounds !');
end;

function TSheets.GetSheetsCount: Integer;
begin
  Result:= FSheets.Count;
end;

function TSheets.GetSheetByName(ASheetName: WideString): TSheet;
var
  I: Integer;
begin
  Result:= nil;
  for I:= 0 to FSheets.Count-1 do
    if TSheet(FSheets[I]).Name = ASheetName then
    begin
      Result:= TSheet(FSheets[I]);
      break;
    end;
end;

procedure TSheets.Add(const ASheetName: WideString);
var
  ASheet: TSheet;
  Err: TXLSErrorCode;
begin
  Err:= VerifySheetName(ASheetName);
  if Err <> EXLS_NOERROR then
    raise EXLSError.Create(Err)
  else
  begin
    ASheet:= TSheet.Create(FWbk);
    ASheet.Name:= ASheetName;
    FSheets.Add(ASheet);
    ASheet.FIndex:= FSheets.Count - 1;
  end;
end;

procedure TSheets.Copy(const ASourceInd: Integer; const ADestInd: Integer;
  const ANewSheetName: WideString);
var
  I: Integer;
  ASheet: TSheet;
  Err: TXLSErrorCode;
begin
  Err:= VerifySheetName(ANewSheetName);
  if Err <> EXLS_NOERROR then
    raise EXLSError.Create(Err)
  else
  begin
    ASheet:= TSheet.Create(FWbk);
    ASheet.Name:= ANewSheetName;
    ASheet.CopyFromSheet(FWbk.Sheets[ASourceInd]);
    FSheets.Insert(ADestInd, ASheet);

    { Update sheets indexes }
    for I:= 0 to FSheets.Count-1 do
      TSheet(FSheets[I]).RefreshIndex;
  end;
end;

procedure TSheets.Delete(const Ind: Integer);
var
  I: Integer;
begin
  { Delete sheet }
  TSheet(FSheets[Ind]).Destroy;
  FSheets.Delete(Ind);

  { Update sheets indexes }
  for I:= 0 to FSheets.Count-1 do
    TSheet(FSheets[I]).RefreshIndex;
end;

procedure TSheets.DeleteByName(const ASheetName: WideString);
var
  ASheet: TSheet;
  Ind: Integer;
begin
  ASheet:= GetSheetByName(ASheetName);
  if Assigned(ASheet) then
  begin
    Ind:= ASheet.Index;
    Delete(Ind);
  end;
end;

function TSheets.VerifySheetName(ASheetName: WideString): TXLSErrorCode;
var
  L: Integer;
begin
  Result:= EXLS_NOERROR;
  L:= Length(ASheetName);
  if (L = 0) or (L > 255) then
    Result:= EXLS_BADSHEETNAMELENGTH
  else
  if trim(ASheetName) = '' then
    Result:= EXLS_BADSHEETNAME
  else
  if Assigned(GetSheetByName(ASheetName)) then
    Result:= EXLS_BADSHEETNAME;
end;

procedure TSheets.Clear;
var
  I: Integer;
begin
  for I:= 0 to FSheets.Count -1 do
    TSheet(FSheets[I]).Destroy;

  FSheets.Clear;
end;

{TWorkbook}
constructor TWorkbook.Create(ASheetCount: Integer);
var
  I: Integer;
begin
  FFormatStrings:= TFormatStrings.Create;
  FFontTable:= TVirtualFontTable.Create;
  FXFTable:= TVirtualXFTable.Create;
  FLinkTable:= TXLSLinkTable.Create;
  FProtectPassword:= '';
  FProtectPasswordHash:= 0;   

  FCommonWorkbookCellData.FormatStringsTable:= FFormatStrings;
  FCommonWorkbookCellData.FontTable:= FFontTable;
  FCommonWorkbookCellData.XFTable:= FXFTable;
  FCommonWorkbookCellData.ProcessingState:= psNothing;
  
  FSheets:= TSheets.Create(Self);
  for I:= 1 to ASheetCount do
    FSheets.Add('Sheet' + IntToStr(I));
end;

destructor TWorkbook.Destroy;
begin
  { do not change order }
  FSheets.Destroy;
  FFormatStrings.Destroy;
  FFontTable.Destroy;
  FXFTable.Destroy;
  FLinkTable.Destroy;
  inherited;
end;

procedure TWorkbook.SetProcessingState(const State: TXLSProcessingState);
begin
  FCommonWorkbookCellData.ProcessingState:= State;
end;

function TWorkbook.SheetByName(const ASheetName: WideString): TSheet;
begin
  Result:= FSheets.GetSheetByName(ASheetName);
end;

procedure TWorkbook.Clear;
begin
  FSheets.Destroy;
  FFormatStrings.Destroy;
  FFontTable.Destroy;
  FXFTable.Destroy;

  FSheets:= TSheets.Create(Self);
  FLinkTable.Clear;
  
  FFormatStrings:= TFormatStrings.Create;
  FFontTable:= TVirtualFontTable.Create;
  FXFTable:= TVirtualXFTable.Create;

  FCommonWorkbookCellData.FormatStringsTable:= FFormatStrings;
  FCommonWorkbookCellData.FontTable:= FFontTable;
  FCommonWorkbookCellData.XFTable:= FXFTable;

  FProtectPassword:= '';
  FProtectPasswordHash:= 0;
end;

function TWorkbook.GetIsProtected: Boolean;
begin
  Result:= (FProtectPasswordHash <> 0);
end;

procedure TWorkbook.Protect(const APassword: AnsiString);
begin
  FProtectPassword:= APassword;
  FProtectPasswordHash:= XLSProtectGetPasswordHash(APassword);
end;

function TWorkbook.UnProtect(const APassword: AnsiString): Boolean;
var
  APasswordHash: Word;
begin
  Result:= False;
  APasswordHash:= XLSProtectGetPasswordHash(APassword);
  if (APasswordHash = FProtectPasswordHash) then
  begin
    Result:= True;
    FProtectPassword:= '';
    FProtectPasswordHash:= 0;
  end;
end;

procedure TWorkbook.UnProtectWithoutPassword;
begin
  FProtectPassword:= '';
  FProtectPasswordHash:= 0;
end;

end.
