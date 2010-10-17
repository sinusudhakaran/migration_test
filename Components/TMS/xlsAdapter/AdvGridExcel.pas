
unit AdvGridExcel;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
{$IFDEF LINUX}{$INCLUDE ../FLXCONFIG.INC}{$ELSE}{$INCLUDE ..\FLXCONFIG.INC}{$ENDIF}
interface
{$IFDEF FLEXCELADVSTRINGGRID}
uses
  Windows, SysUtils, Classes, XLSAdapter, UExcelAdapter, UFlxUtils, AdvGrid, AdvGridWorkbook,
  UFlxFormats, UFlxMessages, BaseGrid, UXlsPictures, ShellAPI, Dialogs, Controls, Printers, XlsMessages,
{$IFDEF ConditionalExpressions}{$IF CompilerVersion >= 14}Variants, {$IFEND}{$ENDIF} //Delphi 6 or above
{$IFDEF USEPNGLIB}
      //////////////////////////////// IMPORTANT ///////////////////////////////////////
      //To be able to display PNG images and WMFs, you have to install TPNGImage from http://pngdelphi.sourceforge.net/
      //If you don't want to install it, edit ../FLXCONFIG.INC and delete the line:
      // "{$DEFINE USEPNGLIB}" on the file
      //Note that this is only needed on Windows, CLX has native support for PNG
      ///////////////////////////////////////////////////////////////////////////////////
  pngimage, zlibpas,
      ///////////////////////////////////////////////////////////////////////////////////
      //If you are getting an error here, please read the note above.
      ///////////////////////////////////////////////////////////////////////////////////
{$ENDIF}
{$IFDEF FLEXCEL}
  UFlexcelGrid, Math,
{$ENDIF}
  Graphics, JPEG, AsgHTMLE,
  UTextDelim,
  UFlxNumberFormat, Grids;
const
  CellOfs = 0;
type
  TFlxFormatCellEvent = procedure(Sender: TAdvStringGrid; const GridCol, GridRow, XlsCol, XlsRow: integer; const Value: widestring; var DateFormat, TimeFormat: Widestring) of object;
  TFlxFormatCellGenericEvent = procedure(Sender: TAdvStringGrid; const GridCol, GridRow, XlsCol, XlsRow: integer; const Value: widestring; var Format: TFlxFormat) of object;

  TASGIOProgressEvent = procedure(Sender: TObject; SheetNum, SheetTot, RowNum, RowTot: integer) of object;
  TExportColumnFormatEvent = procedure (Sender: TObject; GridCol, GridRow, XlsCol, XlsRow: integer; const Value: widestring; var ExportCellAsString: boolean) of object;
  TGetCommentBoxSizeEvent = procedure (Sender: TObject; const Comment: widestring; var Height, Width: integer) of object;

  TOverwriteMode = (omNever, omAlways, omWarn);

  TInsertInSheet =
  (
      //Clears everything on the sheet before exporting the grid.
      InsertInSheet_Clear,

      //Overwrites existing cells, but does not clear any existing information on the sheet.
      InsertInSheet_OverwriteCells,

      //Inserts the grid inside the existing sheet, moving all the other rows down.
      InsertInSheet_InsertRows,

      //Inserts the grid inside the existing sheet, moving all the other columns to the right.
      InsertInSheet_InsertCols,

      //Inserts the grid inside the existing sheet, moving all the other rows down (Grid.RowCount - 2) rows.
      //The first two rows will be overwrited. This can be used to export for example inside of a chart.
      InsertInSheet_InsertRowsExceptFirstAndSecond,

      //Inserts the grid inside the existing sheet, moving all the other columns right (Grid.ColCount - 2) columns.
      //The first two columns will be overwrited. This can be used to export for example inside of a chart.
      InsertInSheet_InsertColsExceptFirstAndSecond

  )  ;

  TASGIOOptions = class(TPersistent)
  private
    FImportCellProperties: Boolean;
    FImportCellSizes: Boolean;
    FImportCellFormats: Boolean;
    FImportFormulas: Boolean;
    FImportImages: Boolean;
    FImportPrintOptions: boolean;
    FExportCellSizes: Boolean;
    FExportCellFormats: Boolean;
    FExportFormulas: Boolean;
    FExportCellProperties: Boolean;
    FExportWordWrapped: Boolean;
    FExportHTMLTags: Boolean;
    FExportHiddenColumns: Boolean;
    FExportHiddenRows: Boolean;
    FExportShowInExcel: Boolean;
    FExportOverwriteMessage: string;
    FExportOverwrite: TOverwriteMode;
    FExportHardBorders: boolean;
    FUseExcelStandardColorPalette: Boolean;
    FExportShowGridLines: boolean;
    FImportLockedCellsAsReadonly: boolean;
    FExportReadonlyCellsAsLocked: boolean;
    FExportPrintOptions: boolean;
    FExportSummaryRowsBelowDetail: boolean;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property ImportFormulas: Boolean read FImportFormulas write FImportFormulas default True;
    property ImportImages: Boolean read FImportImages write FImportImages default True;
    property ImportCellFormats: Boolean read FImportCellFormats write FImportCellFormats default True;
    property ImportCellProperties: Boolean read FImportCellProperties write FImportCellProperties default False;
    property ImportCellSizes: Boolean read FImportCellSizes write FImportCellSizes default True;
    property ImportLockedCellsAsReadonly: Boolean read FImportLockedCellsAsReadonly write FImportLockedCellsAsReadonly default false;
    property ExportOverwrite: TOverwriteMode read FExportOverwrite write FExportOverwrite default omNever;
    property ExportOverwriteMessage: string read FExportOverwriteMessage write FExportOverwriteMessage;
    property ExportFormulas: Boolean read FExportFormulas write FExportFormulas default True;
    property ExportCellFormats: Boolean read FExportCellFormats write FExportCellFormats default True;
    property ExportCellProperties: Boolean read FExportCellProperties write FExportCellProperties default True;
    property ExportCellSizes: Boolean read FExportCellSizes write FExportCellSizes default True;
    property ExportHiddenColumns: Boolean read FExportHiddenColumns write FExportHiddenColumns default False;
    //this property is not ready yet.
    //property ExportHiddenRows: Boolean read FExportHiddenRows write FExportHiddenRows default False;
    property ExportReadonlyCellsAsLocked: Boolean read FExportReadonlyCellsAsLocked write FExportReadonlyCellsAsLocked default False;
    property ExportWordWrapped: Boolean read FExportWordWrapped write FExportWordWrapped default False;
    property ExportHTMLTags: Boolean read FExportHTMLTags write FExportHTMLTags default True;
    property ExportShowInExcel: Boolean read FExportShowInExcel write FExportShowInExcel default False;
    property ExportHardBorders: Boolean read FExportHardBorders write FExportHardBorders default False;
    property ExportShowGridLines: Boolean read FExportShowGridLines write FExportShowGridLines default True;

    property ExportPrintOptions: Boolean read FExportPrintOptions write FExportPrintOptions default True;
    property ImportPrintOptions: Boolean read FImportPrintOptions write FImportPrintOptions default True;

    property ExportSummaryRowsBelowDetail: Boolean read FExportSummaryRowsBelowDetail write FExportSummaryRowsBelowDetail default False;

    ///<summary>
    /// When true, the standard Excel color palette will be used while exporting. Excel 97/2003 have only 53 available colors,
    /// and any color that does not match must be replaced with the nearest one. If this property is false,
    /// the Excel color palette will be changed to better display the real grid colors. Note that when you want to
    /// edit the generated file, having a custom palette might make it difficult to find the color you need.
    ///</summary>
    property UseExcelStandardColorPalette: Boolean read FUseExcelStandardColorPalette write FUseExcelStandardColorPalette default True;
  end;

  TAGrid = class(TAdvStringGrid)
  end;

  TOneRowBorder= record
    HasBottom: boolean;
    HasRight: boolean;
    BottomColor: integer;
    RightColor: integer;
  end;

  TRowBorderArray = array of TOneRowBorder;

  TAdvGridExcelIO = class(TComponent)
  private
    { Private declarations }
    FAdvStringGrid: TAdvStringGrid;
    FAdvGridWorkbook: TAdvGridWorkbook;
    FAdapter: TExcelAdapter;
    FAutoResizeGrid: boolean;
    FUseUnicode: boolean;
    FSheetNames: array of Widestring;
    FGridStartCol: Integer;
    FGridStartRow: Integer;
    FXlsStartRow: Integer;
    FXlsStartCol: Integer;
    FZoomSaved: Boolean;
    FZoom: Integer;
    FWorkSheet: Integer;
    FWorkSheetNum: Integer;
    FDateFormat: widestring;
    FTimeFormat: widestring;
    FOptions : TASGIOOptions;
    FOnDateTimeFormat: TFlxFormatCellEvent;
    FOnCellFormat: TFlxFormatCellGenericEvent;
    FOnProgress: TASGIOProgressEvent;
    FOnExportColumnFormat: TExportColumnFormatEvent;
    FOnGetCommentBoxSize: TGetCommentBoxSizeEvent;

    // procedure SetAdapter(const Value: TExcelAdapter);
    procedure SetAdvStringGrid(const Value: TAdvStringGrid);
    procedure SetAdvGridWorkbook(const Value: TAdvGridWorkbook);
    function CurrentGrid: TAGrid;
    procedure ImportData(const Workbook: TExcelFile);
    procedure ExportData(const Workbook: TExcelFile);
    procedure CloseFile(var Workbook: TExcelFile);
    function CellFormatDef(const Workbook: TExcelFile; const aRow, aCol: integer): TFlxFormat;
    function GetColor(const Workbook: TExcelFile; const Fm: TFlxFormat): TColor;
    function GetSheetNames(index: integer): widestring;
    function GetSheetNamesCount: integer;
    procedure SetGridStartCol(const Value: integer);
    procedure SetGridStartRow(const Value: integer);
    procedure SetXlsStartCol(const Value: integer);
    procedure SetXlsStartRow(const Value: integer);
    procedure OpenText(const Workbook: TExcelFile; const FileName: TFileName; const Delimiter: char);
    procedure SetZoom(const Value: integer);
    procedure ImportImages(const Workbook: TExcelFile; const Zoom100: extended);
    procedure ExportImage(const Workbook: TExcelFile; const Pic: TGraphic; const rx, cx, cg, rg: integer);
    procedure InternalXLSImport(const FileName: TFileName; const SheetNumber: integer; const SheetName: widestring);
    function SupressCR(s: Widestring): widestring;
    function FindSheet(const Workbook: TExcelFile; const SheetName: widestring; var index: integer): boolean;
    procedure SetOptions(const Value: TASGIOOptions);
    procedure SetBorders(const cg, rg: integer; var LastRowBorders:TRowBorderArray; SpanRow, SpanCol: integer; var Fm: TFlxFormat; const Workbook: TExcelFile; const UsedColors: BooleanArray);
    procedure CopyFmToMerged(const Workbook: TExcelFile;
      const cp: TCellProperties; const rx, cx: integer; const Fm: TFlxFormat);
    procedure ImportNodes(const Workbook: TExcelFile; const first, last, level: integer);
    procedure ImportAllNodes(const Workbook: TExcelFile; const first, last: integer);
    function WideAdjustLineBreaks(const w: widestring): widestring;
    function NearestColorIndex(const Workbook: TExcelFile; const aColor: TColor; const UsedColors: BooleanArray): integer;
    function GetUsedPaletteColors(const Workbook: TExcelFile): BooleanArray;
    procedure OpenFile(const Workbook: TExcelFile; const FileName: string);
    procedure ResizeCommentBox(const Workbook: TExcelFile; const Comment: string; var h, w: integer);
    function GetVersion: string;
    procedure SetVersion(const Value: string);
    function RichToText(const RTFText: string): string;

  protected
    { Protected declarations }
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    { Public declarations }
    procedure XLSImport(const FileName: TFileName); overload;
    procedure XLSImport(const FileName: TFileName; const SheetNumber: integer); overload;
    procedure XLSImport(const FileName: TFileName; const SheetName: widestring); overload;
    procedure XLSExport(const FileName: TFileName; const SheetName: widestring = ''; const SheetPos: integer = -1; const SelectSheet: integer = 1; const InsertInSheet: TInsertInSheet = InsertInSheet_Clear);

    procedure LoadSheetNames(const FileName: string);
    property SheetNames[index: integer]: widestring read GetSheetNames;
    property SheetNamesCount: integer read GetSheetNamesCount;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
   { Published declarations }
    //property Adapter: TExcelAdapter read FAdapter write SetAdapter;
    property AdvStringGrid: TAdvStringGrid read FAdvStringGrid write SetAdvStringGrid;
    property AdvGridWorkbook: TAdvGridWorkbook read FAdvGridWorkbook write SetAdvGridWorkbook;

    property AutoResizeGrid: Boolean read FAutoResizeGrid write FAutoResizeGrid default true;

    property Options: TASGIOOptions read FOptions write SetOptions;

    property UseUnicode: boolean read FUseUnicode write FUseUnicode;

    property GridStartRow: integer read FGridStartRow write SetGridStartRow default 1;
    property GridStartCol: integer read FGridStartCol write SetGridStartCol default 1;
    property XlsStartRow: integer read FXlsStartRow write SetXlsStartRow default 1;
    property XlsStartCol: integer read FXlsStartCol write SetXlsStartCol default 1;

    property ZoomSaved: boolean read FZoomSaved write FZoomSaved default true;
    property Zoom: integer read FZoom write SetZoom default 100;

    property DateFormat: widestring read FDateFormat write FDateFormat;
    property TimeFormat: widestring read FTimeFormat write FTimeFormat;

    property Version: string read GetVersion write SetVersion;

    //Events

    property OnDateTimeFormat: TFlxFormatCellEvent read FOnDateTimeFormat write FOnDateTimeFormat;
    property OnCellFormat: TFlxFormatCellGenericEvent read FOnCellFormat write FOnCellFormat;
    property OnProgress: TASGIOProgressEvent read FOnProgress write FOnProgress;
    property OnExportColumnFormat: TExportColumnFormatEvent read FOnExportColumnFormat write FOnExportColumnFormat;
    property OnGetCommentBoxSize: TGetCommentBoxSizeEvent read FOnGetCommentBoxSize write FOnGetCommentBoxSize;


  end;

procedure Register;
{$ENDIF}
implementation
{$IFDEF FLEXCELADVSTRINGGRID}

procedure Register;
begin
  RegisterComponents('TMS Grids', [TAdvGridExcelIO]);
end;

const
  RtfStart = '{\rtf';

type
TTmpCanvas = class
  private
    bmp: TBitmap;
  public
    Canvas: TCanvas;

    constructor Create;
    destructor Destroy; override;
end;



{ TAdvGridExcelIO }

procedure TAdvGridExcelIO.CloseFile(var Workbook: TExcelFile);
begin
  if Workbook = nil then exit;
  try
    Workbook.CloseFile;
  except
    //nothing;
  end; //Except
  try
    Workbook.Disconnect;
  except
    //nothing;
  end; //Except
  FreeAndNil(Workbook);
end;

function TAdvGridExcelIO.CellFormatDef(const Workbook: TExcelFile; const aRow, aCol: integer): TFlxFormat;
var
  XF: integer;
begin
  XF := Workbook.CellFormat[aRow, aCol];
  if XF < 0 then
  begin

    XF := Workbook.RowFormat[aRow];
    if XF <= 0 then XF := Workbook.ColumnFormat[aCol];
  end;
  if (XF < 0) then XF := 15;
  Result := Workbook.FormatList[XF];
end;

function TAdvGridExcelIO.GetColor(const Workbook: TExcelFile; const Fm: TFlxFormat): TColor;
var
  bc: TColor;
begin
  if Fm.FillPattern.Pattern = 1 then Result := $FFFFFF
  else
  begin
    bc := Fm.FillPattern.FgColorIndex;
    if (bc > 0) and (integer(bc) <= 56) then
      Result := Workbook.ColorPalette[bc] else
      Result := $FFFFFF;
  end;
end;

procedure TAdvGridExcelIO.ImportImages(const Workbook: TExcelFile; const Zoom100: extended);
var
  i: integer;
  Pic: TStream;
  PicType: TXlsImgTypes;
  Picture, TmpPic: TPicture;
  Bmp: TBitmap;
  Anchor: TClientAnchor;
  Handled: boolean;
  w, h: integer;

  StartX, StartY, SpanX, SpanY: integer;
begin
  if FOptions.ImportImages then
  begin
    for i := 0 to Workbook.PicturesCount[-1] - 1 do
    begin
      Pic := TMemoryStream.Create;
      try
        Workbook.GetPicture(-1, i, Pic, PicType, Anchor);

        if Anchor.Dx1 > 1024 div 2 then StartX := Anchor.Col1 + 1 else StartX := Anchor.Col1;
        SpanX := Anchor.Col2 - StartX + 1;
        if Anchor.Dy1 > 255 div 2 then StartY := Anchor.Row1 + 1 else StartY := Anchor.Row1;
        SpanY := Anchor.Row2 - StartY + 1;

        //Resize the grid if too small
        if FAutoResizeGrid then
        begin
          if Anchor.Col2 + GridStartCol - XlsStartCol + 2 > CurrentGrid.ColCount then
            if Anchor.Col2 + GridStartCol - XlsStartCol + 2 > CurrentGrid.FixedCols then
              CurrentGrid.ColCount := Anchor.Col2 + GridStartCol - XlsStartCol + 2;
          if Anchor.Row2 + GridStartRow - XlsStartRow + 2 > CurrentGrid.RowCount then
            if Anchor.Row2 - XlsStartRow + GridStartRow + 2 > CurrentGrid.FixedRows then
              CurrentGrid.RowCount := Anchor.Row2 - XlsStartRow + GridStartRow + 2;
        end;

        if Anchor.Row1 < XlsStartRow then continue;
        if Anchor.Col1 < XlsStartCol then continue;

        if Anchor.Col2 + GridStartCol - XlsStartCol > CurrentGrid.ColCount then continue;
        if Anchor.Row2 + GridStartRow - XlsStartRow > CurrentGrid.RowCount then continue;

        Picture := CurrentGrid.CreatePicture(StartX + GridStartCol - XlsStartCol, StartY + GridStartRow - XlsStartRow, false, noStretch, 0, haLeft, vaTop);
        try
          //Merge picture cells so we get a better size.

          CurrentGrid.MergeCells(StartX + GridStartCol - XlsStartCol, StartY + GridStartRow - XlsStartRow, SpanX, SpanY);
          //Load the image
          Pic.Position := 0;
          CalcImgDimentions(Workbook, Anchor, w, h);
          TmpPic := TPicture.Create;
          try
            SaveImgStreamToGraphic(Pic, PicType, TmpPic, Handled);
            if not Handled then
              raise Exception.Create('Not handled'); //This will be catched below. It is an internal exception so image is deleted
            Bmp := TBitmap.Create;
            try
              Picture.Graphic := Bmp;
            finally
              FreeAndNil(Bmp); //Remember TPicture.Graphic keeps a COPY of the TGraphic
            end;
            (Picture.Graphic as TBitmap).Width := Round(w * Zoom100);
            (Picture.Graphic as TBitmap).Height := Round(h * Zoom100);
            (Picture.Graphic as TBitmap).Canvas.StretchDraw(Rect(0, 0, Round(w * Zoom100), Round(h * Zoom100)), TmpPic.Graphic);
          finally
            FreeAndNil(TmpPic);
          end; //finally
        except
          //CurrentGrid.RemovePicture(Anchor.Col1+GridStartCol-XlsStartCol, Anchor.Row1+GridStartRow-XlsStartRow);
          CurrentGrid.RemovePicture(StartX + GridStartCol - XlsStartCol, StartY + GridStartRow - XlsStartRow);
          //Dont raise... is not a major error;
        end; //except
      finally
        FreeAndNil(Pic);
      end; //Finally
    end;
  end;
end;

procedure TAdvGridExcelIO.ImportNodes(const Workbook: TExcelFile; const first, last, level: integer);
var
  StartNode: integer;
  r: integer;
  CurrentLevel: integer;
begin
  r:=first;
  while r<=last do
  begin
    CurrentLevel:=Workbook.GetRowOutlineLevel(r);
    if CurrentLevel=Level then
    begin
      StartNode:=r;
      inc(r);
      while (r<=last) and (Workbook.GetRowOutlineLevel(r)>=CurrentLevel) do inc(r);
      if (r-StartNode>1) then
        CurrentGrid.AddNode(StartNode-1, r-StartNode+1);
    end
    else inc(r);
  end;
end;

procedure TAdvGridExcelIO.ImportAllNodes(const Workbook: TExcelFile; const first, last: integer);
var
  i: integer;
begin
  for i:=1 to 7 do
    ImportNodes(Workbook, first, last, i);
end;

function TAdvGridExcelIO.WideAdjustLineBreaks(const w: widestring): widestring;
var
  i, p: integer;
begin
  SetLength(Result, Length(w)*2);
  p:=0;
  for i:=1 to Length(w) do
  begin
    if w[i]=#10 then
    begin
      Result[p+i]:=#13;
      inc(p);
    end;
    Result[p+i]:=w[i];
  end;
  SetLength(Result, Length(w)+p);
end;

procedure TAdvGridExcelIO.ImportData(const Workbook: TExcelFile);
var
  r, c, i: integer;
  Fm: TFlxFormat;
  Mb: TXlsCellRange;

  MaxC, MaxR, cg, rg: integer;

  XF: integer;

  Zoom100: extended;
  FontColor: integer;
  w: widestring;
  v: variant;
  HAlign: TAlignment;

  HasTime, HasDate: boolean;
  Formula: string;

begin
  Assert(Workbook <> nil, 'AdvGridWorkbook can''t be nil');
  Assert(CurrentGrid <> nil, 'AdvStringGrid can''t be nil');

  CurrentGrid.BeginUpdate;
  try
    if FZoomSaved then Zoom100 := Workbook.SheetZoom / 100 else Zoom100 := FZoom / 100;

    CurrentGrid.Clear;

    if Options.ImportPrintOptions then
    begin
      if Workbook.PrintOptions and fpo_NoPls = 0 then
      begin
        if (Workbook.PrintOptions and fpo_Orientation = 0) then
        begin
          CurrentGrid.PrintSettings.Orientation := poLandscape;
        end else
        begin
          CurrentGrid.PrintSettings.Orientation := poPortrait;
        end;
      end;
    end;


    if FAutoResizeGrid then
    begin
      if Workbook.MaxRow - XlsStartRow + 1 + GridStartRow > CurrentGrid.FixedRows then
        CurrentGrid.RowCount := Workbook.MaxRow - XlsStartRow + 1 + GridStartRow;
      if Workbook.MaxCol - XlsStartCol + 1 + GridStartCol > CurrentGrid.FixedCols then
        CurrentGrid.ColCount := Workbook.MaxCol - XlsStartCol + 1 + GridStartCol;
    end;

    if FOptions.ImportCellSizes then
    begin
      CurrentGrid.DefaultRowHeight := Round(Workbook.DefaultRowHeight / RowMult * Zoom100) + CellOfs;
      CurrentGrid.DefaultColWidth := Round(Workbook.DefaultColWidth / ColMult * Zoom100) + CellOfs;
    end;

    ImportImages(Workbook, Zoom100); //Load them first, so if there is some resizing to do, it is done here

    if Workbook.MaxRow > CurrentGrid.RowCount + XlsStartRow - 1 - GridStartRow
      then MaxR := CurrentGrid.RowCount + XlsStartRow - 1 - GridStartRow else MaxR := Workbook.MaxRow;
    if Workbook.MaxCol > CurrentGrid.ColCount + XlsStartCol - 1 - GridStartCol
      then MaxC := CurrentGrid.ColCount + XlsStartCol - 1 - GridStartCol else MaxC := Workbook.MaxCol;

    //Adjust Row/Column sizes and set Row/Column formats
    for r := XlsStartRow to MaxR do
    begin
      rg := r + GridStartRow - XlsStartRow;
      if FOptions.ImportCellSizes then
        CurrentGrid.RowHeights[rg] := Round(Workbook.RowHeight[r] / RowMult * Zoom100) + CellOfs + CurrentGrid.XYOffset.Y;

      XF := Workbook.RowFormat[r];

      if (XF >= 0) and FOptions.ImportCellProperties then
      begin
        Fm := Workbook.FormatList[XF];
        CurrentGrid.RowColor[rg] := GetColor(Workbook, Fm);
        if (Fm.Font.ColorIndex > 0) and (integer(Fm.Font.ColorIndex) <= 56) then
          CurrentGrid.RowFontColor[rg] := Workbook.ColorPalette[Fm.Font.ColorIndex];
      end;
    end;

    for c := XlsStartCol to MaxC do
    begin
      cg := c + GridStartCol - XlsStartCol;
      if FOptions.ImportCellSizes then
        CurrentGrid.ColWidths[cg] := Round(Workbook.ColumnWidth[c] / ColMult * Zoom100) + CellOfs + CurrentGrid.XYOffset.X;
    end;

    //Import data
    for r := XlsStartRow to MaxR do
    begin
      rg := r + GridStartRow - XlsStartRow;
      for c := XlsStartCol to MaxC do
      begin
        cg := c + GridStartCol - XlsStartCol;
        Fm := CellFormatDef(Workbook, r, c);

        //Merged Cells
        //We check this first, so if its not the first of a merged cell we exit
        Mb := Workbook.CellMergedBounds[r, c];
        if ((Mb.Left <> c) or (Mb.Top <> r)) then continue;

        if ((Mb.Left = c) and (Mb.Top = r)) and ((Mb.Right > c) or (Mb.Bottom > r)) then
          CurrentGrid.MergeCells(cg, rg, Mb.Right - Mb.Left + 1, Mb.Bottom - Mb.Top + 1);

        if (FOptions.ImportLockedCellsAsReadonly) then
        begin
          CurrentGrid.ReadOnly[cg, rg] := fm.Locked;
        end;

        //Font
        if FOptions.ImportCellProperties then
        begin
          if (Fm.Font.ColorIndex > 0) and (integer(Fm.Font.ColorIndex) <= 56) then
            CurrentGrid.FontColors[cg, rg] := Workbook.ColorPalette[Fm.Font.ColorIndex]
          else
            CurrentGrid.FontColors[cg, rg] := 0;

          CurrentGrid.FontSizes[cg, rg] := Trunc((Fm.Font.Size20 / 20 * Zoom100));

          CurrentGrid.FontNames[cg, rg] := Fm.Font.Name;

          if flsBold in Fm.Font.Style then
            CurrentGrid.FontStyles[cg, rg] := CurrentGrid.FontStyles[cg, rg] + [fsBold];
          if flsItalic in Fm.Font.Style then
            CurrentGrid.FontStyles[cg, rg] := CurrentGrid.FontStyles[cg, rg] + [fsItalic];
          if flsStrikeOut in Fm.Font.Style then
            CurrentGrid.FontStyles[cg, rg] := CurrentGrid.FontStyles[cg, rg] + [fsStrikeOut];
          if Fm.Font.Underline <> fu_None then
            CurrentGrid.FontStyles[cg, rg] := CurrentGrid.FontStyles[cg, rg] + [fsUnderline];
        end;

        //Pattern
        {Bmp:=nil;
        try
          if Fm.FillPattern.Pattern=1 then
          begin
            if (ACanvas.Brush.Color<>clwhite) then
              ACanvas.Brush.Color:=clwhite;
          end else
          if Fm.FillPattern.Pattern=2 then
          begin
            if (ACanvas.Brush.Color<>ABrushFg) then
              ACanvas.Brush.Color:=ABrushFg;
          end else
          begin
            Bmp:=CreateBmpPattern(Fm.FillPattern.Pattern, ABrushFg, ABrushBg);
            Acanvas.Brush.Bitmap:=Bmp;
          end;

          ACanvas.FillRect(Rect(Round(Cw*ZoomPreview), Round(Ch*ZoomPreview), Round((Cw+RealColWidth(Col,Zoom100,XPpi))*ZoomPreview), Round((Ch+RealRowHeight(Row,Zoom100,YPpi))*ZoomPreview)));

        finally
          ACanvas.Brush.Bitmap:=nil;
          FreeAndNil(Bmp);
        end; //finally
        }
        if FOptions.ImportCellProperties then
        begin
          CurrentGrid.Colors[cg, rg] := GetColor(Workbook, Fm);

          if Fm.Rotation > 0 then
            if Fm.Rotation <= 90 then CurrentGrid.SetRotated(cg, rg, Fm.Rotation) else
              if Fm.Rotation <= 180 then CurrentGrid.SetRotated(cg, rg, 90 - Fm.Rotation);
        end;

        //pending: cellborders, brush, cell align, empty right cells, imagesize,
        //pending: fechas y otros formatos, copy/paste, events, comentarios on flexcel .

        //pending: export deafultreowheights/colwidths
        //Ask for: Rotated unicode. Image Size.  Vertical Aligns Word wraps in cells.
        //pending keepexcelformat on import/export don't work with dates
        //pending: export placement of images

        v := Workbook.CellValue[r, c];

        //Cell Align
        if FOptions.ImportCellProperties then
        begin
          case Fm.HAlignment of
            fha_left: HAlign := taLeftJustify;
            fha_center: HAlign := taCenter;
            fha_right: HAlign := taRightJustify;
          else
            begin
              if VarType(v) = VarBoolean then HAlign := taCenter else
                if (VarType(v) <> VarOleStr) and (VarType(v) <> VarString) then HAlign := taRightJustify
                else HAlign := taLeftJustify;
            end;
          end; //case

         //this must be done after reading the alignment, since it depends on the formula value.
        if FOptions.ImportFormulas then
        begin
          Formula := Workbook.CellFormula[r,c];
          if (Pos('=',Formula) = 1) then
            v := Formula;
         end;


          {
          case Fm.VAlignment of
          fva_top: VAlign:=AL_TOP;
          fva_center: VAlign:=AL_VCENTER;
          else VAlign:=AL_BOTTOM ;
          end; //case
          }

          CurrentGrid.Alignments[cg, rg] := HAlign;
        end;

        FontColor := CurrentGrid.FontColors[cg, rg];
        w := XlsFormatValue1904(v, Fm.Format, Workbook.Options1904Dates, FontColor);
        if FOptions.ImportCellProperties then
          CurrentGrid.FontColors[cg, rg] := FontColor;

        if FOptions.ImportCellFormats then
        begin
          if UseUnicode then
            CurrentGrid.WideCells[cg, rg] := WideAdjustLineBreaks(w)
          else
            CurrentGrid.Cells[cg, rg] := Trim(AdjustLineBreaks(w));
        end
        else
        begin
          case VarType(V) of
            varByte,
              varSmallint,
              varInteger: CurrentGrid.Ints[cg, rg] := v;

  {$IFDEF ConditionalExpressions}{$IF CompilerVersion >= 14}varInt64, {$IFEND}{$ENDIF} //Delphi 6 or above
            varCurrency,
              varSingle,
              varDouble:
              begin
                if HasXlsDateTime(Fm.Format, HasDate, HasTime) then
                begin
                  if HasTime and HasDate then //We can't map this to a date or time cell.
                    if UseUnicode then
                      CurrentGrid.WideCells[cg, rg] := w else
                      CurrentGrid.Cells[cg, rg] := w

                  else if HasDate then CurrentGrid.Dates[cg, rg] := v else CurrentGrid.Times[cg, rg] := v
                end
                else CurrentGrid.Floats[cg, rg] := v;
              end;

            varDate: CurrentGrid.Dates[cg, rg] := v;
          else
            if UseUnicode then
              CurrentGrid.WideCells[cg, rg] := w else
              CurrentGrid.Cells[cg, rg] := w;

          end; //case
        end;
      end;

      //Import Comments
      if FOptions.ImportCellProperties then
        for i := 0 to Workbook.CommentsCount[r] - 1 do
          CurrentGrid.AddComment(Workbook.CommentColumn[r, i] + GridStartCol - XlsStartCol, r + GridStartRow - XlsStartRow, Workbook.CommentText[r, i]);

      if Assigned(FOnProgress) then
        FOnProgress(Self, FWorkSheet, FWorkSheetNum, r - XlsStartRow, MaxR - XlsStartRow);
    end;

    //Import nodes
    if FOptions.ImportCellProperties then //After all has been loaded
      ImportAllNodes(Workbook, XlsStartRow, MaxR);
  finally
    CurrentGrid.EndUpdate;
  end;
end;

procedure TAdvGridExcelIO.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if Operation = opRemove then
  begin
    if AComponent = FAdapter then
      FAdapter := nil;
    if AComponent = FAdvStringGrid then
      FAdvStringGrid := nil;
    if AComponent = FAdvGridWorkbook then
      FAdvGridWorkbook := nil;
  end;
end;

//procedure TAdvGridExcelIO.SetAdapter(const Value: TExcelAdapter);
//begin
//  FAdapter := Value;
//end;

procedure TAdvGridExcelIO.SetAdvStringGrid(const Value: TAdvStringGrid);
begin
  FAdvGridWorkbook := nil;
  FAdvStringGrid := Value;
end;

procedure TAdvGridExcelIO.SetAdvGridWorkbook(const Value: TAdvGridWorkbook);
begin
  FAdvStringGrid := nil;
  FAdvGridWorkbook := Value;
end;


procedure TAdvGridExcelIO.OpenText(const Workbook: TExcelFile; const FileName: TFileName; const Delimiter: char);
var
  DataStream: TFileStream;
begin
  DataStream := TFileStream.Create(FileName, fmOpenRead);
  try
    Workbook.NewFile;
    LoadFromTextDelim(DataStream, Workbook, Delimiter, 1, 1, []);
  finally
    FreeAndNil(DataStream);
  end; //finally
end;

procedure TAdvGridExcelIO.InternalXLSImport(const FileName: TFileName; const SheetNumber: integer; const SheetName: widestring);
var
  Workbook: TExcelFile;
  i: integer;
  Ext: string;
  aSheetNumber: integer;
  UseWorkbook: boolean;
begin
  aSheetNumber := SheetNumber;
  UseWorkbook := (FAdvGridWorkbook <> nil) and (SheetNumber < 0) and (SheetName = '');

  if CurrentGrid = nil then raise Exception.Create(ErrNoAdvStrGrid);
  //Open the file
  if FAdapter = nil then
    Workbook := TXLSFile.Create(nil) else
    Workbook := FAdapter.GetWorkbook;
  try
    Workbook.Connect;
    Ext := UpperCase(ExtractFileExt(FileName));
    if Ext = '.CSV' then OpenText(Workbook, FileName, ListSeparator) else //Note that ListSeparator mightbe other than "," (for example ";") so CSV might not be "comma" separated. This is the way excel handles it.
      if Ext = '.TXT' then OpenText(Workbook, FileName, #9) else
        Workbook.OpenFile(FileName);

    if UseWorkbook then
    begin
      FAdvGridWorkbook.ActiveSheet := 0;
      FAdvGridWorkbook.Sheets.Clear;
    end;


    SetLength(FSheetNames, Workbook.SheetCount);

    FWorkSheetNum := Workbook.SheetCount;

    for i := 0 to Workbook.SheetCount - 1 do
    begin
      FWorkSheet := i + 1;
      Workbook.ActiveSheet := i + 1;
      FSheetNames[i] := Workbook.ActiveSheetName;
      if WideUpperCase98(SheetName) = WideUpperCase98(FSheetNames[i]) then aSheetNumber := i + 1;
      if UseWorkbook then
      begin
        FAdvGridWorkbook.Sheets.Add;
        FAdvGridWorkbook.ActiveSheet := i;
        FAdvGridWorkbook.Sheets[i].Name := FSheetNames[i];
        Workbook.ParseComments;
        ImportData(Workbook);
        CurrentGrid.VAlignment := vtaBottom;
      end;
    end;

    if not UseWorkbook then
    begin
      if aSheetNumber < 1 then
        aSheetNumber := 1;

      FWorkSheetNum := 1;
      FWorkSheet := 1;
      if (aSheetNumber = 0) and (SheetName <> '') then raise Exception.CreateFmt(ErrInvalidSheetName, [SheetName]);
      if (aSheetNumber > 0) and (aSheetNumber <= Workbook.SheetCount) then
      begin
        Workbook.ActiveSheet := aSheetNumber;
        Workbook.SelectSheet(aSheetNumber);
      end
      else raise Exception.CreateFmt(ErrIndexOutBounds, [aSheetNumber, 'ActiveSheet', 1, Workbook.SheetCount]);

      Workbook.ParseComments;
      ImportData(Workbook);
      CurrentGrid.VAlignment := vtaBottom;
    end;
  finally
    CloseFile(Workbook);
  end;
end;

procedure TAdvGridExcelIO.XLSImport(const FileName: TFileName);
begin
  XlsImport(FileName, -1);
  if FAdvGridWorkbook <> nil then
    FAdvGridWorkbook.ActiveSheet := 0;
end;

procedure TAdvGridExcelIO.XLSImport(const FileName: TFileName; const SheetName: widestring);
begin
  if SheetName = '' then raise Exception.CreateFmt(ErrInvalidSheetName, [SheetName]);
  InternalXLSImport(FileName, 0, SheetName);
end;

procedure TAdvGridExcelIO.XLSImport(const FileName: TFileName; const SheetNumber: integer);
begin
  InternalXLSImport(FileName, SheetNumber, '');
end;


procedure TAdvGridExcelIO.ExportImage(const Workbook: TExcelFile; const Pic: TGraphic; const rx, cx, cg, rg: integer);
//Adapted from FlexCelImport.AddPicture
var
  s: string;
  Ms: TMemoryStream;
  Props: TImageProperties;
  PicType: TXlsImgTypes;
  JPic: TJPEGImage;
  BPic: TBitmap;
  PSize, CSize: TPoint;
  dh, dw: integer;
  Cr: TCellGraphic;
begin
  PicType := xli_Jpeg;
{$IFDEF USEPNGLIB}
  if Pic is TPNGObject then PicType := xli_Png;
{$ENDIF}

  Ms := TMemoryStream.Create;
  try
    if (PicType = xli_Jpeg) and not (Pic is TJPEGImage) then
    begin //Convert the image
      JPic := TJPEGImage.Create;
      try
        BPic := TBitmap.Create; //we can't assign a metafile to a jpeg, so the temporary bitmap.
        try
          BPic.Width := Pic.Width;
          BPic.Height := Pic.Height;
          BPic.Canvas.Draw(0, 0, Pic);
          JPic.Assign(BPic);
        finally
          FreeAndNil(BPic);
        end; //finally
        JPic.SaveToStream(Ms);
      finally
        FreeAndNil(JPic);
      end; //finally
    end
    else
      Pic.SaveToStream(Ms);

    Ms.Position := 0;
    SetLength(s, Ms.Size);
    Ms.Read(s[1], Ms.Size);
    PSize := CurrentGrid.CellGraphicSize[cg, rg];
    CSize := CurrentGrid.CellSize(cg, rg);
    dh := 1;
    dw := 1;
    Cr := CurrentGrid.CellGraphics[cg, rg];

    case Cr.CellHAlign of
      haLeft:
        begin
        //Nothing, this is default
        end;
      haRight:
        begin
          dw := CSize.X - PSize.X;
        end;
      haCenter:
        begin
          if (PSize.X < CSize.X) then
          begin
            dw := (CSize.X - PSize.X) div 2;
          end
        end;
      haBeforeText:
        begin
        //Nothing
        end;
      haAfterText:
        begin
        //Nothing
        end;
      haFull:
        begin
        //Nothing
        end;
    end;

    case Cr.CellVAlign of
      vaTop, vaAboveText:
        begin
        //This is default
        end;
      vaBottom:
        begin
          dh := CSize.Y - PSize.Y;
        end;
      vaCenter:
        begin
          if PSize.Y < CSize.Y then
          begin
            dh := (CSize.Y - PSize.Y) div 2;
          end
        end;
      vaUnderText:
        begin
        //Nothing
        end;
      vaFull:
        begin
        //Nothing
        end;
    end;


    CalcImgCells(Workbook, rx, cx, dh, dw, PSize.y, PSize.x, Props);
    Workbook.AddImage(s, PicType, Props, at_MoveAndDontResize);
  finally
    FreeAndNil(Ms);
  end; //finally
end;

function IsRtf(const Value: string): Boolean;
begin
  Result := (Pos(RtfStart, Value) = 1);
end;

function TAdvGridExcelIO.RichToText(const RTFText: string): string;
var
  MemoryStream: TMemoryStream;
begin
  if RtfText <> '' then
  begin
    MemoryStream := TMemoryStream.Create;
    try
      MemoryStream.Write(RtfText[1], Length(RtfText));
      MemoryStream.Position := 0;
      CurrentGrid.RichEdit.Lines.LoadFromStream(MemoryStream);
    finally
      MemoryStream.Free;
    end;
  end
  else
    CurrentGrid.RichEdit.Clear;

  Result := CurrentGrid.RichEdit.Text;
end;


function TAdvGridExcelIO.SupressCR(s: Widestring): widestring;
var
  i, k: integer;
begin
  if IsRtf(s) then
  begin
     s := RichToText(s);
  end;


  SetLength(Result, Length(s));
  k := 1;
  for i := 1 to Length(s) do if s[i] <> #13 then
    begin
      Result[k] := s[i];
      inc(k);
    end
    else
    begin
      if (i = Length(s)) or (s[i+1] <> #10) then
      begin
        Result[k] := #10;
        inc(k);
      end
    end;

  SetLength(Result, k - 1);
end;

procedure TAdvGridExcelIO.SetBorders(const cg, rg: integer; var LastRowBorders: TRowBorderArray; SpanRow, SpanCol: integer;
                                     var Fm: TFlxFormat; const Workbook: TExcelFile; const UsedColors: BooleanArray);
var
  Borders: TCellBorders;
  LeftPen, RightPen, TopPen, BottomPen: TPen;
  i: integer;
  Span: integer;
begin
  Span:=SpanCol;
  if (Span<0) then Span:=0;
  if cg+Span>Length(LastRowBorders)-1 then Span:=Length(LastRowBorders)-1-cg;

  Borders:=[];
  LeftPen:=TPen.Create;
  try
  TopPen:=TPen.Create;
  try
  RightPen:=TPen.Create;
  try
  BottomPen:=TPen.Create;
  try
    CurrentGrid.GetCellBorder(cg, rg, TopPen, Borders);
    BottomPen.Assign(TopPen);
    LeftPen.Assign(TopPen);
    RightPen.Assign(LeftPen);

    if Assigned(CurrentGrid.OnGetCellBorderProp) then
       CurrentGrid.OnGetCellBorderProp(CurrentGrid, rg, cg, LeftPen, TopPen, RightPen, BottomPen);

    if (Options.ExportHardBorders) and (CurrentGrid.GridLineWidth>0) then
    begin
      if (goVertLine in CurrentGrid.Options) then
      begin
        if not (cbTop in Borders) then
        begin
          TopPen.Color:= CurrentGrid.GridLineColor;
          Include( Borders, cbTop);
        end;

        if not (cbBottom in Borders) then
        begin
          BottomPen.Color:= CurrentGrid.GridLineColor;
          Include(Borders, cbBottom);
        end;
      end;
      if (goHorzLine in CurrentGrid.Options) then
      begin
        if not (cbLeft in Borders) then
        begin
          LeftPen.Color:= CurrentGrid.GridLineColor;
          Include( Borders, cbLeft);
        end;

        if not (cbRight in Borders) then
        begin
          RightPen.Color:= CurrentGrid.GridLineColor;
          Include(Borders, cbRight);
        end;
      end;
    end;

    if (cbTop in Borders) then
    begin
      Fm.Borders.Top.Style:= fbs_Thin;
      Fm.Borders.Top.ColorIndex:=NearestColorIndex(Workbook, ColorToRGB(TopPen.Color), UsedColors);
    end else
    if (LastRowBorders[cg].HasBottom) then
    begin
      Fm.Borders.Top.Style:= fbs_Thin;
      Fm.Borders.Top.ColorIndex:=LastRowBorders[cg].BottomColor;
    end;

    if (cbLeft in Borders) then
    begin
      Fm.Borders.Left.Style:= fbs_Thin;
      Fm.Borders.Left.ColorIndex:=NearestColorIndex(Workbook, ColorToRGB(LeftPen.Color), UsedColors);
    end
    else
    if (LastRowBorders[cg+Span].HasRight) then
    begin
      Fm.Borders.Left.Style:= fbs_Thin;
      Fm.Borders.Left.ColorIndex:=LastRowBorders[cg+Span].RightColor;
    end;

    if (cbBottom in Borders) then
    begin
      Fm.Borders.Bottom.Style := fbs_Thin;
      Fm.Borders.Bottom.ColorIndex := NearestColorIndex(Workbook, ColorToRGB(BottomPen.Color), UsedColors);
      for i:=0 to Span do
      begin
        LastRowBorders[cg+i].HasBottom := true;
        LastRowBorders[cg+i].BottomColor := Fm.Borders.Bottom.ColorIndex;
      end;
    end else
    begin
      for i:=0 to Span do
      begin
        LastRowBorders[cg+i].HasBottom:=false;
      end;
    end;

    if (cbRight in Borders) then
    begin
      Fm.Borders.Right.Style:= fbs_Thin;
      Fm.Borders.Right.ColorIndex:=NearestColorIndex(Workbook, ColorToRGB(RightPen.Color), UsedColors);

      LastRowBorders[cg+Span+1].HasRight:=true;
      LastRowBorders[cg+Span+1].RightColor:=Fm.Borders.Right.ColorIndex;
    end else
    begin
      LastRowBorders[cg+Span+1].HasRight:=false;
    end;

  finally
    FreeAndNil(BottomPen);
  end;
  finally
    FreeAndNil(RightPen);
  end;
  finally
    FreeAndNil(TopPen);
  end;
  finally
    FreeAndNil(LeftPen);
  end;

end;

procedure TAdvGridExcelIO.CopyFmToMerged(const Workbook: TExcelFile; const cp: TCellProperties; const rx, cx: integer; const Fm: TFlxFormat);
var
  r,c: integer;
  fmi: integer;
begin
  if (cp <> nil) and ((cp.CellSpanX > 0) or (cp.CellSpanY > 0)) then
  begin
    fmi:=Workbook.AddFormat(Fm);
    for c:=cp.CellSpanX downto 0 do
      for r:=cp.CellSpanY downto 0 do
        Workbook.CellFormat[rx+r, cx+c]:=Fmi;
  end;
end;

procedure TAdvGridExcelIO.ResizeCommentBox(const Workbook: TExcelFile; const Comment: string; var h, w: integer);
{$IFDEF FLEXCEL}
var
  TextLines: WidestringArray;
  OutRTFRuns: TRTFRunList;
  RTFRuns: TRTFRunListList;
  TextExtent: TSize;
  TmpCanvas: TTmpCanvas;
{$ENDIF}
begin
{$IFDEF FLEXCEL}
  TmpCanvas := TTmpCanvas.Create();
  try
    TmpCanvas.Canvas.Font.Name:='Arial';
    TmpCanvas.Canvas.Font.Size := 10;
    SetLength(OutRTFRuns, 0);
    TFlexCelGrid.SplitText(Workbook, TmpCanvas.Canvas, Comment, w, TextLines, OutRTFRuns, RTFRuns, TextExtent, false, 1);
    h:= Ceil((TextExtent.cy + 1) * (Length(TextLines) + 1));
  finally
    FreeAndNil(TmpCanvas);
  end; //finally
{$ENDIF}
end;


procedure TAdvGridExcelIO.ExportData(const Workbook: TExcelFile);
var
  Zoom100: extended;
  rg, cg, rx, cx: integer;
  Fm: TFlxFormat;
  w: widestring;
  Pic: TCellGraphic;
  AState: TGridDrawState;
  ABrush: TBrush;
  AColorTo,AMirrorColor,AMirrorColorTo: TColor;
  AFont: TFont;
  HA: TAlignment;
  VA: TVAlignment;
  WW: Boolean;
  cp: TCellProperties;
  AAngle: integer;
  Comment, Formula: string;
  Properties: TImageProperties;
  Cr: TXlsCellRange;
  aDateFormat, aTimeFormat: widestring;
  LastRowBorders: TRowBorderArray;
  HiddenColCount: Integer;
  HiddenRowCount: Integer;
  SpanX, SpanY: integer;
  CReal, RReal: Integer;
  UsedColors: BooleanArray;
  GD: TCellGradientDirection;
  NamedRange: TXlsNamedRange;

  HasFixedRows, HasFixedCols: boolean;
  ExportCellAsString: boolean;
  GridColCount, GridRowCount: integer;
  hid: integer;

  CommentHeight: integer;
  CommentWidth: integer;
  eq: widestring;
begin
  Zoom100 := 1;
  Assert(Workbook <> nil, 'AdvGridWorkbook can''t be nil');
  Assert(CurrentGrid <> nil, 'AdvStringGrid can''t be nil');

  //Workbook.DefaultRowHeight:=Round(CurrentGrid.DefaultRowHeight*RowMult/Zoom100);
  //Workbook.DefaultColWidth:=Round(CurrentGrid.DefaultColWidth*ColMult/Zoom100);

  if Options.ExportPrintOptions then
  begin
    Workbook.PrintScale := 100;
    Workbook.PrintOptions := Workbook.PrintOptions and not fpo_NoPls;
    if (CurrentGrid.PrintSettings.Orientation = poPortrait) then
    begin
      Workbook.PrintOptions := Workbook.PrintOptions or fpo_Orientation;
    end else
    begin
      Workbook.PrintOptions := Workbook.PrintOptions and not fpo_Orientation;
    end;

    HasFixedRows := (CurrentGrid.PrintSettings.RepeatFixedRows) and (CurrentGrid.FixedRows > 0);
    HasFixedcols := (CurrentGrid.PrintSettings.RepeatFixedCols) and (CurrentGrid.FixedCols > 0);

    if HasFixedRows or HasFixedCols then
    begin
      InitializeNamedRange(NamedRange);
      NamedRange.Name:=InternalNameRange_Print_Titles;
      NamedRange.NameSheetIndex:=Workbook.ActiveSheet;
      if HasFixedRows then
      begin
        NamedRange.RangeFormula:='=$A$1:$' + EncodeColumn(Max_Columns+1) + '$' + IntToStr(CurrentGrid.FixedRows);
      end;
      if HasFixedCols then
      begin
        if NamedRange.RangeFormula <> '' then NamedRange.RangeFormula:= NamedRange.RangeFormula+', ' else NamedRange.RangeFormula:='=';
        NamedRange.RangeFormula:= NamedRange.RangeFormula +'$A$1:$' + EncodeColumn(CurrentGrid.FixedCols) + '$' + IntToStr(Max_Rows + 1);
      end;

      Workbook.AddRange(NamedRange);
    end;

  end;

  Workbook.OutlineSummaryRowsBelowDetail := Options.ExportSummaryRowsBelowDetail;
  Workbook.OutlineSummaryColsRightOfDetail := Options.ExportSummaryRowsBelowDetail;


  Workbook.ShowGridLines := Options.ExportShowGridLines;
  //Adjust Row/Column sizes and set Row/Column formats
  UsedColors := GetUsedPaletteColors(Workbook);

  CurrentGrid.ExportNotification(esExportStart,-1);
  HiddenColCount := CurrentGrid.NumHiddenColumns;
  HiddenRowCount := CurrentGrid.NumHiddenRows;

  GridColCount := CurrentGrid.ColCount;
  if Options.ExportHiddenColumns then inc(GridColCount, HiddenColCount);

  CurrentGrid.ColCount := CurrentGrid.ColCount + HiddenColCount;
  try
    GridRowCount := CurrentGrid.RowCount + HiddenRowCount;
    if Options.FExportHiddenRows then
      CurrentGrid.RowCount := CurrentGrid.RowCount + HiddenRowCount;
    try

      if Options.ExportCellSizes then
      begin
        rx := XlsStartRow; hid:=0;
        for rg := GridStartRow to GridRowCount - 1 do
        begin
          if CurrentGrid.IsHiddenRow(rg) then
          begin
            if Options.FExportHiddenRows then
            begin
              Workbook.RowHidden[rx] := true;
              inc(rx);
            end;
            inc(hid);
            continue;

          end;
          Workbook.RowHeight[rx] := Round(CurrentGrid.RowHeights[rg - hid] * RowMult / Zoom100) - CellOfs;
          inc(rx);
        end;

        cx := XlsStartCol;
        for cg := GridStartCol to CurrentGrid.ColCount - 1 do
        begin
          if CurrentGrid.IsHiddenColumn(cg) then
          begin
            if Options.ExportHiddenColumns then Workbook.ColumnHidden[cx] := true else continue;
          end;
          Workbook.ColumnWidth[cx] := Round(CurrentGrid.AllColWidths[cg] * ColMult / Zoom100) - CellOfs;
          inc(cx);
        end;
      end;

      SetLength(LastRowBorders, CurrentGrid.ColCount + 2);
      for cg := 0 to  Length(LastRowBorders) - 1 do
      begin
        LastRowBorders[cg].HasBottom:=false;
        LastRowBorders[cg].HasRight:=false;
      end;

      //Export data
      for rg := GridStartRow to CurrentGrid.RowCount - 1 do
      begin
        CurrentGrid.ExportNotification(esExportNewRow,rg);
        rx := rg - GridStartRow + XlsStartRow;

        if Options.FExportHiddenRows then
        begin
          if (CurrentGrid.IsHiddenRow(rg)) then
            rreal :=CurrentGrid.RowCount - CurrentGrid.NumHiddenRows
          else
            rreal := CurrentGrid.DisplRowIndex(rg);
        end
        else
          rreal := rg;

        for cg := GridStartCol to GridColCount - 1 do
        begin
          cx := cg - GridStartCol + XlsStartCol;

         if Options.ExportHiddenColumns then
           creal := cg
         else
           creal := CurrentGrid.RealColIndex(cg);

          //Merged Cells
          cp := TCellProperties( CurrentGrid.GridObjects[creal,rreal]);

          if (cp <> nil) and not (cp.IsBaseCell) then
            Continue;

          if (cp <> nil) and ((cp.CellSpanX > 0) or (cp.CellSpanY > 0)) then
            Workbook.MergeCells(rx, cx, rx + cp.CellSpanY, cx + cp.CellSpanX);

          Fm := CellFormatDef(Workbook, rx, cx);

          AFont := TFont.Create;
          try
            ABrush := TBrush.Create;
            ABrush.Color := CurrentGrid.Color;
            try
              CurrentGrid.GetVisualProperties(creal, rreal, AState, false, false, false , ABrush, AColorTo,AMirrorColor,AMirrorColorTo, AFont, HA, VA, WW, GD);

              //Font
              Fm.Font.ColorIndex := NearestColorIndex(Workbook, AFont.Color, UsedColors);
              Fm.Font.Size20 := Trunc(-AFont.Height * 72 / AFont.PixelsPerInch * 20 / Zoom100);
              //Fm.Font.Size20 := AFont.Size * 20;

              Fm.Font.Name := AFont.Name;
              if fsBold in AFont.Style then
                Fm.Font.Style := Fm.Font.Style + [flsBold] else Fm.Font.Style := Fm.Font.Style - [flsBold];
              if fsItalic in AFont.Style then
                Fm.Font.Style := Fm.Font.Style + [flsItalic] else Fm.Font.Style := Fm.Font.Style - [flsItalic];
              if fsStrikeOut in AFont.Style then
                Fm.Font.Style := Fm.Font.Style + [flsStrikeOut] else Fm.Font.Style := Fm.Font.Style - [flsStrikeOut];
              if fsUnderline in AFont.Style then
                Fm.Font.Underline := fu_Single else Fm.Font.Underline := fu_None;

              //Pattern
              {Bmp:=nil;
              try
                if Fm.FillPattern.Pattern=1 then
                begin
                  if (ACanvas.Brush.Color<>clwhite) then
                    ACanvas.Brush.Color:=clwhite;
                end else
                if Fm.FillPattern.Pattern=2 then
                begin
                  if (ACanvas.Brush.Color<>ABrushFg) then
                    ACanvas.Brush.Color:=ABrushFg;
                end else
                begin
                  Bmp:=CreateBmpPattern(Fm.FillPattern.Pattern, ABrushFg, ABrushBg);
                  Acanvas.Brush.Bitmap:=Bmp;
                end;

                ACanvas.FillRect(Rect(Round(Cw*ZoomPreview), Round(Ch*ZoomPreview), Round((Cw+RealColWidth(Col,Zoom100,XPpi))*ZoomPreview), Round((Ch+RealRowHeight(Row,Zoom100,YPpi))*ZoomPreview)));

              finally
                ACanvas.Brush.Bitmap:=nil;
                FreeAndNil(Bmp);
              end; //finally
              }

              if (cp = nil) then
              begin
                SpanY := 0;
                SpanX := 0;
              end else
              begin
                SpanY := cp.CellSpanY;
                SpanX := cp.CellSpanX;
              end;
              SetBorders(creal, rreal, LastRowBorders, SpanY, SpanX, Fm, Workbook, UsedColors);

              if ColorToRGB(ABrush.Color) = $FFFFFF then
              begin
                Fm.FillPattern.Pattern := 1; //no fill
              end else
              begin
                Fm.FillPattern.Pattern := 2; //Solid fill
                Fm.FillPattern.FgColorIndex := NearestColorIndex(Workbook, ColorToRGB(ABrush.Color), UsedColors);
              end;

              if CurrentGrid.IsRotated(creal, rreal, AAngle) then
              begin
                if AAngle < 0 then AAngle := 360 - (Abs(AAngle) mod 360) else
                  AAngle := AAngle mod 360;
                if (AAngle >= 0) and (AAngle <= 90) then Fm.Rotation := AAngle
                else if (AAngle >= 270) then Fm.Rotation := 360 - AAngle + 90;
              end;

              if FUseUnicode then
                w := SupressCR(CurrentGrid.WideCells[creal, rreal])
              else
                w := SupressCR(CurrentGrid.SaveCell(creal, rreal));

              Formula := SupressCR(CurrentGrid.SaveCell(creal, rreal));

              if (FOptions.ExportReadonlyCellsAsLocked) then
              begin
                Fm.Locked := CurrentGrid.ReadOnly[creal, rreal];
              end;

              if not Options.ExportHTMLTags then
              begin
                StringReplace(w,'<br>','#13#10',[rfReplaceAll, rfIgnoreCase]);
              end;

              if (pos(#10, w) > 0) or (CurrentGrid.WordWrap and Options.ExportWordWrapped) then
                Fm.WrapText := true;

              eq := '</';

              if (pos(eq,w) > 0) and not Options.ExportHTMLTags then
                w := HTMLStrip(w);

              //Cell Align
              case HA of
                taLeftJustify: Fm.HAlignment := fha_left;
                taCenter: Fm.HAlignment := fha_center;
                taRightJustify: Fm.HAlignment := fha_right;
              else Fm.HAlignment := fha_general;
              end; //case

              case VA of
                vtaTop: Fm.VAlignment := fva_top;
                vtaCenter: Fm.VAlignment := fva_center;
              else Fm.VAlignment := fva_bottom;
              end; //case

              if Assigned(OnCellFormat) then
                OnCellFormat(CurrentGrid, creal, rreal, cx, rx, w, Fm);

              ExportCellAsString := not FOptions.ExportCellFormats;
              if Assigned(OnExportColumnFormat) then OnExportColumnFormat(CurrentGrid, creal, rreal, cx, rx, w, ExportCellAsString);
              if not ExportCellAsString then
              begin
                aDateFormat := FDateFormat;
                aTimeFormat := FTimeFormat;
                if Assigned(OnDateTimeFormat) then
                  OnDateTimeFormat(CurrentGrid, creal, rreal, cx, rx, w, aDateFormat, aTimeFormat);

                if (pos('=',Formula) = 1) and FOptions.ExportFormulas then
                begin
                  Workbook.CellFormula[rx,cx] := Formula;
                  if Options.ExportCellProperties then
                    Workbook.CellFormat[rx, cx] := Workbook.AddFormat(Fm);
                end
                else
                begin
                  if Options.ExportCellProperties then
                    Workbook.SetCellString(rx, cx, w, Fm, aDateFormat, aTimeFormat)
                  else
                  begin
                    Fm := CellFormatDef(Workbook, rx, cx);
                    Workbook.SetCellString(rx, cx, w, Fm, aDateFormat, aTimeFormat);
                  end;
                end;
                CopyFmToMerged(Workbook, cp, rx, cx, Fm) ;
              end
              else
              begin
                if (pos('=',Formula) = 1) and FOptions.ExportFormulas then
                begin
                  Workbook.CellFormula[rx,cx] := Formula;
                end
                else
                begin
                  Workbook.CellValue[rx, cx] := w;
                end;
                if Options.ExportCellProperties then
                begin
                  Workbook.CellFormat[rx, cx] := Workbook.AddFormat(Fm);
                  CopyFmToMerged(Workbook, cp, rx, cx, Fm) ;
                end;
              end;
            finally
              FreeAndNil(ABrush);
            end; //finally
          finally
            FreeAndNil(AFont);
          end; //finally

          //Export Images
          Pic := CurrentGrid.CellGraphics[creal, rreal];
          if (Pic <> nil) and (Pic.CellBitmap <> nil) then
          begin
          if (Pic.CellType = cTBitmap) then
             ExportImage(Workbook, Pic.CellBitmap, rx, cx, creal, rreal);

          if (Pic.CellType = cTPicture) then
             ExportImage(Workbook, TPicture(Pic.CellBitmap).Graphic, rx, cx, creal, rreal);
          end;

        //Export Comments
          if CurrentGrid.IsComment(creal, rreal, Comment) then
          begin
            Cr := Workbook.CellMergedBounds[rx, cx];
            CommentHeight:= 75;
            CommentWidth:= 130;
            Comment := SupressCR(Comment);
            ResizeCommentBox(Workbook, Comment, CommentHeight, CommentWidth);
            if Assigned(OnGetCommentBoxSize) then OnGetCommentBoxSize(CurrentGrid, Comment, CommentHeight, CommentWidth);

            CalcImgCells(Workbook, rx - 1, cx + Cr.Right - Cr.Left + 1, 8, 14, CommentHeight, CommentWidth, Properties);
            Workbook.SetCellComment(rx, cx, Comment, Properties);
          end;

          if Assigned(FOnProgress) then
            FOnProgress(Self, FWorksheet, FWorkSheetNum, rg - GridStartRow, CurrentGrid.RowCount - 1 - GridStartRow);

        end;


        //Export Nodes
        if Options.ExportCellProperties then
          if (CurrentGrid.GetNodeLevel(rreal)>=0) and (CurrentGrid.GetNodeLevel(rreal)<=7) then
            Workbook.SetRowOutlineLevel(rx+1, rx+CurrentGrid.GetNodeSpan(rreal)-1, CurrentGrid.GetNodeLevel(rreal));

      end;
    finally
      if Options.FExportHiddenRows then
        CurrentGrid.RowCount := CurrentGrid.RowCount - HiddenRowCount;
    end; //finally

  finally
    //if Options.ExportHiddenColumns then
      CurrentGrid.ColCount := CurrentGrid.ColCount - HiddenColCount;
  end; //finally

  CurrentGrid.ExportNotification(esExportDone,-1);
end;

function TAdvGridExcelIO.FindSheet(const Workbook: TExcelFile; const SheetName: widestring; var index: integer): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 1 to Workbook.SheetCount do
  begin
    Workbook.ActiveSheet := i;
    if (WideUpperCase98(Workbook.ActiveSheetName) = WideUpperCase98(SheetName)) then
    begin
      Result := True;
      Index := i;
      Exit;
    end;
  end;
end;

procedure TAdvGridExcelIO.OpenFile(const Workbook: TExcelFile; const FileName: string);
begin
  Workbook.OpenFile(FileName);
end;

procedure TAdvGridExcelIO.XLSExport(const FileName: TFileName; const SheetName: widestring = ''; const SheetPos: integer = -1; const SelectSheet: integer = 1; const InsertInSheet: TInsertInSheet = InsertInSheet_Clear);
var
  Workbook: TExcelFile;
  UseWorkbook: boolean;
  Sp, i: integer;
  rows, cols, dr, dc: integer;
  GridRowCount, GridColCount: integer;
begin
  if CurrentGrid = nil then
    raise Exception.Create(ErrNoAdvStrGrid);


  case Options.ExportOverwrite of
  omAlways:
    begin
      if FileExists(FileName) then
        DeleteFile(FileName);
    end;
  omWarn:
    begin
      if FileExists(FileName) then
      begin
        if MessageDlg(Format(Options.ExportOverwriteMessage,[FileName]),mtCOnfirmation,[mbYes,mbNo],0) = mrYes then
          DeleteFile(FileName)
        else
          Exit;
      end;
    end;
  end;

  UseWorkbook := (FAdvGridWorkbook <> nil) and (SheetName = '') and (SheetPos = -1);
  //Open the file
  if FAdapter = nil then
    Workbook := TXLSFile.Create(nil) else
    Workbook := FAdapter.GetWorkbook;
  try
    Workbook.Connect;

    if UseWorkbook then
    begin
      Workbook.NewFile(FAdvGridWorkbook.Sheets.Count);
      for i := 1 to Workbook.SheetCount do
      begin
        Workbook.ActiveSheet := i;
        Workbook.ActiveSheetName := '_xx_@' + IntToStr(i) + '__' + IntToStr(i); //Just to make sure it is an unique name
      end;
    end else
      if FileExists(FileName) then
      begin
        OpenFile(Workbook, FileName);
        if FindSheet(Workbook, SheetName, Sp) then
        begin
          Workbook.ActiveSheet := Sp;
          case InsertInSheet of
             InsertInSheet_Clear:
               Workbook.ClearSheet;
             InsertInSheet_InsertRows,
             InsertInSheet_InsertRowsExceptFirstAndSecond:
             begin
               dr := 0;
               if (InsertInSheet = InsertInSheet_InsertRowsExceptFirstAndSecond) then dr:=1;
               GridRowCount := CurrentGrid.RowCount;
               if Options.FExportHiddenRows then Inc(GridRowCount, CurrentGrid.NumHiddenRows);
               rows := GridRowCount - GridStartRow - dr * 2;
               if rows > 0 then Workbook.InsertAndCopyRows(Max_Rows + 1, Max_Rows + 1, XlsStartRow + dr, rows ,true);
             end;

             InsertInSheet_InsertCols,
             InsertInSheet_InsertColsExceptFirstAndSecond:
             begin
               dc:=0;
               if (InsertInSheet = InsertInSheet_InsertColsExceptFirstAndSecond) then dc:=1;
               GridColCount := CurrentGrid.ColCount;
               if Options.ExportHiddenColumns then Inc(GridColCount, CurrentGrid.NumHiddenColumns);
               cols := GridColCount - GridStartCol - dc * 2;
               if cols > 0 then Workbook.InsertAndCopyRows(Max_Columns + 1, Max_Columns + 1, XlsStartCol + dc, cols ,true);
             end;
          end; //case.
        end else
        begin
          if (SheetPos <= 0) or (SheetPos > Workbook.SheetCount) then
            Sp := Workbook.SheetCount + 1 else Sp := SheetPos;
          Workbook.InsertAndCopySheets(-1, Sp, 1);
          Workbook.ActiveSheet := Sp;
        end;
      end else
        Workbook.NewFile(1);

    if UseWorkbook then
    begin
      FWorkSheetNum := FAdvGridWorkbook.Sheets.Count;
      for i := 1 to FAdvGridWorkbook.Sheets.Count do
      begin
        FWorkSheet := i;
        Workbook.ActiveSheet := i;
        FAdvGridWorkbook.ActiveSheet := i - 1;
        ExportData(Workbook);
        Workbook.ActiveSheetName := FAdvGridWorkbook.Sheets[i - 1].Name;
      end;
    end
    else
    begin
      FWorkSheetNum := 1;
      FWorkSheet := 1;
      ExportData(Workbook);
    end;

    if SheetName <> '' then Workbook.ActiveSheetName := SheetName;
    if FileExists(FileName) then DeleteFile(FileName);
    Workbook.SelectSheet(SelectSheet);
    Workbook.Save(true, FileName, nil);
  finally
    CloseFile(Workbook);
  end;

  if Options.ExportShowInExcel then
    ShellExecute(0,'open',pchar(FileName),nil,nil,SW_NORMAL);
end;

constructor TAdvGridExcelIO.Create(AOwner: TComponent);
begin
  inherited;
  FAutoResizeGrid := true;

  FGridStartCol := 1;
  FGridStartRow := 1;
  FXlsStartCol := 1;
  FXlsStartRow := 1;

  FZoomSaved := true;
  FZoom := 100;

  FOptions := TASGIOOptions.Create;
end;

function TAdvGridExcelIO.GetSheetNames(index: integer): widestring;
begin
  Result := FSheetNames[index];
end;

function TAdvGridExcelIO.GetSheetNamesCount: integer;
begin
  Result := Length(FSheetNames);
end;

procedure TAdvGridExcelIO.SetGridStartCol(const Value: integer);
begin
  if Value >= 0 then FGridStartCol := Value else FGridStartCol := 1;
end;

procedure TAdvGridExcelIO.SetGridStartRow(const Value: integer);
begin
  if Value >= 0 then FGridStartRow := Value else FGridStartRow := 1;
end;

procedure TAdvGridExcelIO.SetXlsStartCol(const Value: integer);
begin
  if Value > 0 then FXlsStartCol := Value else FXlsStartCol := 1;
end;

procedure TAdvGridExcelIO.SetXlsStartRow(const Value: integer);
begin
  if Value > 0 then FXlsStartRow := Value else FXlsStartRow := 1;
end;

procedure TAdvGridExcelIO.SetZoom(const Value: integer);
begin
  if Value < 10 then FZoom := 10 else if Value > 400 then FZoom := 400 else
    FZoom := Value;
end;



function TAdvGridExcelIO.CurrentGrid: TAGrid;
begin
  if FAdvGridWorkbook <> nil then
    Result := TAGrid(FAdvGridWorkbook.Grid)
  else
    Result := TAGrid(FAdvStringGrid);
end;


destructor TAdvGridExcelIO.Destroy;
begin
  FOptions.Free;
  inherited;
end;

procedure TAdvGridExcelIO.SetOptions(const Value: TASGIOOptions);
begin
  FOptions := Value;
end;

procedure TAdvGridExcelIO.LoadSheetNames(const FileName: string);
var
  Workbook: TExcelFile;
  ext: string;
  i: integer;
begin
  if FAdapter = nil then
    Workbook := TXLSFile.Create(nil) else
    Workbook := FAdapter.GetWorkbook;
  try
    Workbook.Connect;
    Ext := UpperCase(ExtractFileExt(FileName));
    if Ext = '.CSV' then OpenText(Workbook, FileName, ListSeparator) else //Note that ListSeparator mightbe other than "," (for example ";") so CSV might not be "comma" separated. This is the way excel handles it.
      if Ext = '.TXT' then OpenText(Workbook, FileName, #9) else
        Workbook.OpenFile(FileName);

    SetLength(FSheetNames, Workbook.SheetCount);
    FWorkSheetNum := Workbook.SheetCount;

    for i := 0 to Workbook.SheetCount - 1 do
    begin
      FWorkSheet := i + 1;
      Workbook.ActiveSheet := i + 1;
      FSheetNames[i] := Workbook.ActiveSheetName;
      end;
  finally
    CloseFile(Workbook);
  end;
end;

function TAdvGridExcelIO.GetUsedPaletteColors(const Workbook: TExcelFile): BooleanArray;
begin
  if Options.UseExcelStandardColorPalette then
    begin Result := nil; exit; end;

  Result := Workbook.GetUsedPaletteColors;
end;

function TAdvGridExcelIO.NearestColorIndex(const Workbook: TExcelFile; const aColor: TColor;
  const UsedColors: BooleanArray): integer;
type
  TCb= array[0..3] of byte;
var
  i: integer;
  sq, MinSq: extended;
  ac1, ac2: TCb;
  Result2: integer;
begin
  Result:=1;
  MinSq:=-1;
  ac1:=TCb(ColorToRgb(aColor));
  for i:=1 to 55 do
  begin
    ac2:=TCb(Workbook.ColorPalette[i]);
    sq := Sqr(ac2[0] - ac1[0]) +
          Sqr(ac2[1] - ac1[1]) +
          Sqr(ac2[2] - ac1[2]);
    if (MinSq<0) or (sq< MinSq) then
    begin
      MinSq:=sq;
      Result:=i;
      if sq=0 then exit; //exact match...
    end;
  end;

  if (UsedColors = nil) then exit;

  //Find the nearest color between the ones that are not in use.
  UsedColors[0] := true; //not really used
  UsedColors[1] := true; //pure black
  UsedColors[2] := true; //pure white

  Result2:=-1;
  MinSq:=-1;
  for i:=1 to 55 do
  begin
    if (Length(UsedColors) <= i) or UsedColors[i] then continue;

    ac2:=TCb(Workbook.ColorPalette[i]);
    sq := Sqr(ac2[0] - ac1[0]) +
          Sqr(ac2[1] - ac1[1]) +
          Sqr(ac2[2] - ac1[2]);
    if (MinSq<0) or (sq< MinSq) then
    begin
      MinSq:=sq;
      Result2:=i;
      if sq=0 then
      begin
        Result := Result2;
        exit; //exact match...
      end;
    end;
  end;

  if (Result2 < 0) or (Result2 >= Length(UsedColors)) then exit;  //Not available colors to modify
  Workbook.ColorPalette[Result2] := ColorToRGB(aColor);
  UsedColors[Result2] := true;
  Result:= Result2;
end;

function TAdvGridExcelIO.GetVersion: string;
begin
  Result := FlexCelVersion;
end;

procedure TAdvGridExcelIO.SetVersion(const Value: string);
begin
end;

{ TASGIOOptions }

procedure TASGIOOptions.Assign(Source: TPersistent);
begin
  if Source is TASGIOOptions then
  begin
    FImportCellProperties := (Source as TASGIOOptions).ImportCellProperties;
    FImportCellFormats := (Source as TASGIOOptions).ImportCellFormats;
    FImportCellSizes := (Source as TASGIOOptions).ImportCellSizes;
    FImportImages := (Source as TASGIOOptions).ImportImages;
  end;
end;

constructor TASGIOOptions.Create;
begin
  inherited Create;
  FImportFormulas := True;
  FImportCellProperties := False;
  FImportCellFormats := True;
  FImportCellSizes := True;
  FImportImages := True;
  FExportFormulas := True;
  FExportCellFormats := True;
  FExportCellProperties := True;
  FExportCellSizes := True;
  FExportWordWrapped := False;
  FExportHTMLTags := True;
  FExportHiddenColumns := False;
  FExportHiddenRows := False;
  FExportOverwrite := omNever;
  FExportShowInExcel := False;
  FExportOverwriteMessage := 'File %s already exists'#13'Ok to overwrite ?';
  FUseExcelStandardColorPalette := true;
  FExportShowGridLines := true;
  FExportPrintOptions := true;
  FImportPrintOptions := true;
end;


{ TTmpCanvas }

constructor TTmpCanvas.Create;
begin
  inherited;
  bmp := TBitmap.Create;
  bmp.Height := 1;
  bmp.Width := 1;
  Canvas := bmp.Canvas;
end;

destructor TTmpCanvas.Destroy;
begin
  FreeAndNil(bmp);
  inherited;
end;
{$ENDIF}

end.
