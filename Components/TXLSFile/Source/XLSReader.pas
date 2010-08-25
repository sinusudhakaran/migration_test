unit XLSReader;

{-----------------------------------------------------------------
    SM Software, 2000-2009

    TXLSFile v.4.0

    Rev history:
    2003-05-11  ReadMergedCells added, ReadBoolean added
    2004-02-03  OnProgress event added
    2004-02-12  shr bug fixed in NumberFromRK
    2004-03-20  Read formulas as blank cells
                Skip formatting runs in SST
    2004-03-29  Optimize - do not read empty formatted blank cells
    2004-04-09  Use format strings to find a value type if it isn't found from Ifmt
    2004-07-26  Using virtual font table
    2004-12-12  Read formula's last value
                Read custom formats
    2005-01-30  Read named ranges
    2005-03-12  Read outline levels
    2005-05-01  Fix: ReadColumn now checks Column upper bound
    2005-09-09  Add: Exteneded data in SST strings now recognized and skipped
    2005-09-26  Fix: Typecasts in NumberFromRK
    2006-01-05  Add: Read formulas    
    2006-02-12  Add: Read label strings
    2006-02-16  Add: Raise an error when found a workbook protection
    2006-02-24  Add: Read page setup, Read panes
    2006-04-03  Fix: ReadWsbool fixed
                     Reading of mixed strings in ReadSST fixed
    2006-06-23  Add: ReadFromStream added
    2006-08-31  Add: ReadZoom, ReadSheetWindowOptions added
    2007-01-20  Fix: Use XFTable.DefaultIndex
    2008-02-25  Add: Read sheet protection password hash
    2008-03-04  Add: Read BIFF8 standard protected workbooks
    2008-05-05  Add: Link table
    2008-05-14  Add: MSO drawing
    2008-09-27  Fix: Base format caching code fixed

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, Lists, CFile, XLSFile, BiffStream, XLSWorkbook, XLSFormat,
  XLSBase, XLSFont, XLSFormatStr, XLSFormatXF, PtgParser,
  XLSCellValidation, XLSLinkTable, XLSMsoDraw, XLSCellComment,
  XLSRichString;

type
  {TXLSReader}
  TXLSReader = class
  private
    FXLSFile: TXLSFile;
    FCFile: TCFile;
    FWorkbook: TWorkbook;
    FOnProgress: TProgressEvent;
    FOptions: TReaderOptions;

    {internal data}
    FBOFEOFCounter: Integer;
    FGlobalSubstreamRead: Boolean;
    FCurrentSheetIndex: Integer;
    FBIFFRecordProcessed: Boolean;
    FBIFFRecordFetchCount: Byte;
    FFontRecordsExist: Boolean;
    FXFRecordsExist: Boolean;
    FRow, FColumn: Integer;
    FXFIndex: Integer;
    FPassword: WideString;
    FCacheXFIndex: Integer;
    FCacheBaseValueType: AnsiString;

    {internal objects}
    FWorkbookStream: TBiffStream;
    FBIFFRecord: TBIFFRecord;
    FSST: TAnsiStringList;
    FPtgParser: TPtgParser;
    FFormulas: TAnsiStringList;
    FLinkTable: TXLSLinkTable;
    FMSOData: TMSOData;

    procedure ReadWorkbook;
    procedure ReadDefault;
    procedure ReadBOFEOF;

    {globals functions}
    procedure ReadBoundSheet;
    procedure ReadSST;
    procedure ReadFont;
    procedure ReadXF;
    procedure ReadFormat;
    procedure ReadName;
    procedure ReadExternsheet;
    procedure ReadExternname;
    procedure ReadSupbook;
    procedure ReadPalette;

    {sheet functions}
    procedure ReadLabelSST;
    procedure ReadLabel;    
    procedure ReadRK;
    procedure ReadMulRK;
    procedure ReadNumber;
    procedure ReadBlank;
    procedure ReadMulBlank;
    procedure ReadBoolean;
    procedure ReadRow;
    procedure ReadColumn;
    procedure ReadMergedCells;
    procedure ReadFormula;
    procedure ReadSharedFormula;
    procedure ReadStringValueOfFormula;
    procedure ReadSetup;
    procedure ReadWsbool;
    procedure ReadPrintHeaders;
    procedure ReadPrintGridlines;
    procedure ReadTopMargin;
    procedure ReadBottomMargin;
    procedure ReadLeftMargin;
    procedure ReadRightMargin;
    procedure ReadHcenter;
    procedure ReadVcenter;
    procedure ReadHeader;
    procedure ReadFooter;
    procedure ReadPane;
    procedure ReadZoom;
    procedure ReadSheetWindowOptions;
    procedure ReadProtectionPasswordHash;
    procedure ReadSheetProtection;
    procedure ReadFilepass;
    procedure ReadCellValidation;
    procedure ReadHyperlink;

    {MSO drawing}
    procedure ReadMSODrawingGroup;
    procedure ReadMSODrawing;
    procedure ReadMSOObject;
    procedure ReadMSOTextObject;
    procedure ReadCellComment;

    {help functions}
    procedure SetCellXFIndex(C: TCell; const XFIndex: Word);
    procedure PostReadWorkbook;
    procedure ProcessNames;
    procedure ProcessFormulas;
    procedure ProcessXFTable;
    procedure ProcessMSOShapes;
    procedure CreatePtgParser;

    function FetchBIFFRecord: Boolean;
    function CanUseNextBIFFRecord: Boolean;
    procedure DispatchBIFFRecord;
  public
    constructor Create(AXLSFile: TXLSFile);
    destructor Destroy; override;
    function GetFileVersion(const AFileName: WideString): Byte;
    function GetFileProtectionMethod(const AFileName: WideString): Integer;
    procedure ReadFromFile(const AFileName: WideString; const APassword: WideString; AOptions: TReaderOptions);
    procedure ReadFromStream(const ASTream: TStream; const APassword: WideString; AOptions: TReaderOptions);
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;

  PLongword = ^Longword;

implementation
uses
{$IFDEF XLF_D6}
    Variants,
{$ENDIF}
    SysUtils
  , Math
  , XLSError
  , Unicode
  , XLSRects
  , XLSProtect
  , XLSHyperlink
  , Streams;

{get Double number from RK number}
function NumberFromRK(const RK: Integer): Double;
const
  Mask = Integer($FFFFFFFC);
begin
  if ((RK and $02) > 0) then
    Result:= (Integer(RK and Mask) div 4) // RK shr 2
  else
  begin
    PLongword(PAnsiChar(@Result) + 4)^ := (Longword(RK) and Longword(Mask));
    PLongword(@Result)^ := 0;
  end;
  if (rk and $01) > 0 then
    Result:= Result / 100;
end;

{TXLSReader}
constructor TXLSReader.Create(AXLSFile: TXLSFile);
begin
  FXLSFile:= AXLSFile;
  FWorkbook:= FXLSFile.Workbook;
  FSST:= TAnsiStringList.Create;
  FFormulas:= TAnsiStringList.Create;
  FLinkTable:= FWorkbook.LinkTable;
  FPtgParser:= nil;
  FMSOData:= TMSOData.Create;

  FBOFEOFCounter:= 0;
  FGlobalSubstreamRead:= False;
  FCurrentSheetIndex:= 0;
  FBIFFRecordProcessed:= False;
  FFontRecordsExist:= False;
  FXFRecordsExist:= False;
  FRow:= -1;
  FColumn:= -1;
  FXFIndex:= -1;
  FPassword:= '';
  FCacheXFIndex:= -1;
  FCacheBaseValueType:= '';
end;

destructor TXLSReader.Destroy;
begin
  FSST.Destroy;
  FFormulas.Destroy;
  FMSOData.Destroy;
  if Assigned(FPtgParser) then FPtgParser.Destroy;
  
  inherited;
end;

procedure TXLSReader.ReadFromFile(const AFileName: WideString; const APassword: WideString; AOptions: TReaderOptions);
begin
  FOptions:= AOptions;
  FPassword:= APassword;

  {clear old FXLSFile data before reading}
  FXLSFile.Clear;

  {prepare file for reading}
  FCFile:= TCFile.Create(cfCreateFromFile, AFileName);
  try
    ReadWorkbook;
    PostReadWorkbook;
  finally
    FCFile.Destroy;
  end;
end;

procedure TXLSReader.ReadFromStream(const ASTream: TStream; const APassword: WideString; AOptions: TReaderOptions);
begin
  if not Assigned(AStream) then Exit;
  
  FOptions:= AOptions;
  FPassword:= APassword;

  {clear old FXLSFile data before reading}
  FXLSFile.Clear;

  {create empty TCFile in memory}
  FCFile:= TCFile.CreateFromStream(AStream);
  try
    ReadWorkbook;
    PostReadWorkbook;
  finally
    FCFile.Destroy;
  end;
end;

procedure TXLSReader.ReadWorkbook;
var
  Stream: TCFileStream;
begin
  Stream:= TCFileStream(FCFile.Root.FindItem('Workbook'));
  if not Assigned(Stream) then
    raise EXLSError.CreateFmt(EXLS_STREAMNOTFOUND, ['Workbook']);

  { Notify workbook about reading }
  FWorkbook.SetProcessingState(psReading);

  { Read and parse workbook stream }
  FWorkbookStream:= TBIFFStream.Create(Stream);
  try
    FWorkbookStream.Reset;
    FBIFFRecord:= FWorkbookStream.BIFFRecord;

    FBIFFRecordProcessed:= True;
    while FetchBIFFRecord do
      DispatchBIFFRecord;

  finally
    FWorkbookStream.Destroy;
  end;

  { Notify workbook about finish of reading }
  FWorkbook.SetProcessingState(psDataFromFile);
end;

procedure TXLSReader.PostReadWorkbook;
begin
  { Process names list }
  ProcessNames;
  { Process formulas }
  ProcessFormulas;
  { Process XF table}
  ProcessXFTable;
  { Process linktable }
  FLinkTable.ClearLocalDocumentData;
  { Process MSO drawing data }
  ProcessMSOShapes;
end;

function TXLSReader.FetchBIFFRecord: Boolean;
var
  StreamSize: integer;
begin
  { If current record processed - read the next }
  if FBIFFRecordProcessed then
  begin
    result:= FWorkbookStream.ReadBIFFRecord;
    FBIFFRecordProcessed:= False;
    FBIFFRecordFetchCount:= 0;

    { Reading progress }
    if Assigned(FOnProgress) then
    begin
      StreamSize:= FWorkbookStream.Size;
      if StreamSize = 0 then
        FOnProgress(1)
      else
        FOnProgress(FWorkbookStream.Position / StreamSize );
    end;
  end
  else
  begin
    { Prevent cycling when biff record fetched for processing
      more than once }
    FBIFFRecordFetchCount:= FBIFFRecordFetchCount + 1;
    if FBIFFRecordFetchCount > 1 then
      raise Exception.Create('Error: BIFF record can not be processed');
    result:= True;
  end;
end;

procedure TXLSReader.DispatchBIFFRecord;
begin
  case FBIFFRecord.RecNum of
    BIFF_BOF578,
    BIFF_EOF            : ReadBOFEOF;
    BIFF_BOUNDSHEET     : ReadBoundsheet;
    BIFF_FONT           : ReadFont;
    BIFF_XF             : ReadXF;
    BIFF_FORMAT         : ReadFormat;
    BIFF_NAME           : ReadName;
    BIFF_EXTERNSHEET    : ReadExternsheet;
    BIFF_EXTERNNAME     : ReadExternname;
    BIFF_SUPBOOK        : ReadSupbook;
    BIFF_ROW            : ReadRow;
    BIFF_COLINFO        : ReadColumn;
    BIFF_SST            : ReadSST;
    BIFF_LABELSST       : ReadLabelSST;
    BIFF_LABEL          : ReadLabel;
    BIFF_RK             : ReadRK;
    BIFF_MULRK          : ReadMulRK;
    BIFF_BLANK          : ReadBlank;
    BIFF_MULBLANK       : ReadMulBlank;
    BIFF_NUMBER         : ReadNumber;
    BIFF_BOOLERR        : ReadBoolean;
    BIFF_MERGECELLS     : ReadMergedCells;
    BIFF_FORMULA        : ReadFormula;
    BIFF_SHRFMLA        : ReadSharedFormula;
    BIFF_STRING         : ReadStringValueOfFormula;
    BIFF_SETUP          : ReadSetup;
    BIFF_WSBOOL         : ReadWsbool;
    BIFF_PRINTHEADERS   : ReadPrintHeaders;
    BIFF_PRINTGRIDLINES : ReadPrintGridlines;
    BIFF_TOPMARGIN      : ReadTopMargin;
    BIFF_BOTTOMMARGIN   : ReadBottomMargin;
    BIFF_LEFTMARGIN     : ReadLeftMargin;
    BIFF_RIGHTMARGIN    : ReadRightMargin;
    BIFF_HCENTER        : ReadHcenter;
    BIFF_VCENTER        : ReadVcenter;
    BIFF_HEADER         : ReadHeader;
    BIFF_FOOTER         : ReadFooter;
    BIFF_PANE           : ReadPane;
    BIFF_SCL            : ReadZoom;
    BIFF_WINDOW2        : ReadSheetWindowOptions;
    BIFF_PASSWORD       : ReadProtectionPasswordHash;
    BIFF_SHEETPROTECTION: ReadSheetProtection;
    BIFF_FILEPASS       : ReadFilepass;
    BIFF_DV             : ReadCellValidation;
    BIFF_MSODRAWINGGROUP: ReadMSODrawingGroup;
    BIFF_MSODRAWING     : ReadMSODrawing;
    BIFF_OBJ            : ReadMSOObject;
    BIFF_TXO            : ReadMSOTextObject;
    BIFF_NOTE           : ReadCellComment;
    BIFF_HLINK          : ReadHyperlink;
    BIFF_PALETTE        : ReadPalette
    else                  ReadDefault;
  end;
end;

procedure TXLSReader.CreatePtgParser;
begin
  if not Assigned(FPtgParser) then
    FPtgParser:= TPtgParser.Create(FLinkTable);
end;

procedure TXLSReader.ReadDefault;
begin
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadBOFEOF;
begin
  if FBIFFRecord.RecNum = BIFF_BOF578 then
    FBOFEOFCounter:= FBOFEOFCounter + 1;
  if FBIFFRecord.RecNum = BIFF_EOF then
    FBOFEOFCounter:= FBOFEOFCounter - 1;

  { When counter becomes 0 then the next sheet starts.
    The first substream is Globals substream, and all subsequent
    substreams are sheet substreams.
  }
  if (FBOFEOFCounter = 0) then
  begin
    if not FGlobalSubstreamRead then
      FGlobalSubstreamRead:= true
    else
      FCurrentSheetIndex:= FCurrentSheetIndex + 1;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadBoundsheet;
var
  SheetOffset: Longword;
  Options: Word;
  UnicodeFlag: Byte;
  NameSize: Byte;
  NameBuffer: AnsiString;
  SheetName: WideString;
begin
  FBiffRecord.Data.ReadDWord(SheetOffset);
  FBiffRecord.Data.ReadWord(Options);
  FBiffRecord.Data.ReadByte(NameSize);
  FBiffRecord.Data.ReadByte(UnicodeFlag);

  if ((UnicodeFlag and $01) = $01) then
  begin
    FBiffRecord.Data.ReadString(NameBuffer, NameSize * 2);
    SheetName:= ANSIWideStringToWideString(NameBuffer);
  end
  else
  begin
    FBiffRecord.Data.ReadString(NameBuffer, NameSize);
    SheetName:= StringToWideString(NameBuffer);
  end;

  { Add sheet to workbook }
  FWorkbook.Sheets.Add(SheetName);
  { Add sheet name to link table }
  FLinkTable.LocalDocument.AddSheetName(SheetName);

  { Visibility }
  if ((Options and 1) <> 0) then
    FWorkbook.Sheets[FWorkbook.Sheets.Count - 1].Visible:= False;

  FBIFFRecordProcessed:= True;
end;

function TXLSReader.CanUseNextBIFFRecord: Boolean;
begin
  FBIFFRecordProcessed:= True;
  Result:= FetchBIFFRecord;
  if Result then
    Result:= (FBIFFRecord.RecNum = BIFF_CONTINUE);
end;

procedure TXLSReader.ReadSST;
var
  ReadableSize: Integer;
  Unicode: Boolean;

  StringLen: Word;
  StringLenToRead: Integer;
  StringLenRead: Integer;

  StringOptions: Byte;
  StringText: AnsiString;
  StringTextPart: AnsiString;
  StringTextIsUnicode: Boolean;

  FormattingRuns: Boolean;
  FormattingRunsCount: Word;
  ExtData: Boolean;
  ExtDataSize: Integer;
  BytesSkip: Integer;
  BytesToSkip: Integer;
begin
  { Skip header }
  FBIFFRecord.Data.Position:= 8;

  repeat
    { Read string length }
    ReadableSize:=  FBIFFRecord.Data.ReadableSize;
    if ReadableSize < 2 then
      if not CanUseNextBIFFRecord then
        break;
    FBIFFRecord.Data.ReadWord(StringLen);

    { Read string options }
    ReadableSize:=  FBIFFRecord.Data.ReadableSize;
    if ReadableSize < 1 then
      if not CanUseNextBIFFRecord then
        break;
    FBIFFRecord.Data.ReadByte(StringOptions);
    Unicode:= ((StringOptions and $01) = $01);

    { Formatting runs }
    FormattingRuns:= ((StringOptions and $08) = $08);
    if FormattingRuns then
      FBIFFRecord.Data.ReadWord(FormattingRunsCount);

    { Extended data }
    ExtData:= ((StringOptions and $04) = $04);
    if ExtData then
      FBIFFRecord.Data.ReadInt(ExtDataSize);

    { Read string }
    StringText:= '';
    StringLenRead:= 0;
    StringTextIsUnicode:= False;
    while (StringLenRead < StringLen) do
    begin
      ReadableSize:= FBIFFRecord.Data.ReadableSize;
      if ReadableSize = 0 then
      begin
        if not CanUseNextBIFFRecord then
          break
        else
        begin
          { The 1st byte of continue record is options byte }
          ReadableSize:=  FBIFFRecord.Data.ReadableSize;
          if ReadableSize < 1 then
             if not CanUseNextBIFFRecord then
               break;

          FBIFFRecord.Data.ReadByte(StringOptions);
          Unicode:= ((StringOptions and $01) = $01);
          ReadableSize:=  FBIFFRecord.Data.ReadableSize;
        end;
      end;

      if Unicode then
      begin
        if not StringTextIsUnicode then
        begin
          StringText:= SparseString(StringText);
          StringTextIsUnicode:= True;
        end;

        if (ReadableSize div 2) < (StringLen - StringLenRead) then
          StringLenToRead:= ReadableSize div 2
        else
          StringLenToRead:= StringLen - StringLenRead;
        FBIFFRecord.Data.ReadString(StringTextPart, StringLenToRead * 2)
      end
      else
      begin
        if ReadableSize < (StringLen - StringLenRead) then
          StringLenToRead:= ReadableSize
        else
          StringLenToRead:= StringLen - StringLenRead;

        FBIFFRecord.Data.ReadString(StringTextPart, StringLenToRead);

        if StringTextIsUnicode then
          StringTextPart:= SparseString(StringTextPart);
      end;

      StringLenRead:= StringLenRead + StringLenToRead;
      StringText:= StringText + StringTextPart;
    end;

    { Add compressed flag }
    if StringTextIsUnicode then
      StringText:= #1 + StringText
    else
      StringText:= #0 + StringText;

    { Add string to SST }
    FSST.Add(StringText);

    { Skip formatting runs data }
    if FormattingRuns then
    begin
      BytesToSkip:= FormattingRunsCount * 4;
      BytesSkip:= 0;
      while (BytesSkip < FormattingRunsCount * 4) do
      begin
        ReadableSize:=  FBIFFRecord.Data.ReadableSize;
        if (ReadableSize > 0) then
        begin
          if ReadableSize < BytesToSkip then
            BytesToSkip:= ReadableSize;

          FBIFFRecord.Data.SkipBytes(BytesToSkip);
          BytesSkip:= BytesSkip + BytesToSkip;
          BytesToSkip:= FormattingRunsCount * 4 - BytesSkip;
        end
        else
          if not CanUseNextBIFFRecord then
            break;
      end;
    end;

    { Skip extended data }
    if ExtData then
    begin
      BytesToSkip:= ExtDataSize;
      BytesSkip:= 0;
      while (BytesSkip < ExtDataSize) do
      begin
        ReadableSize:=  FBIFFRecord.Data.ReadableSize;
        if (ReadableSize > 0) then
        begin
          if ReadableSize < BytesToSkip then
            BytesToSkip:= ReadableSize;

          FBIFFRecord.Data.SkipBytes(BytesToSkip);
          BytesSkip:= BytesSkip + BytesToSkip;
          BytesToSkip:= ExtDataSize - BytesSkip;
        end
        else
          if not CanUseNextBIFFRecord then
            break;

      end;
    end;

  until False;
end;

procedure TXLSReader.ReadFont;
var
  Font: PFontData;
  FontString: AnsiString;
begin
  { If read the 1st font record - then clear font table }
  if not FFontRecordsExist then
  begin
    FWorkbook.FontTable.Clear;
    FFontRecordsExist:= True;
  end;

  { Read font and add to font table, duplicate fonts allowed here ! }
  Font:= FWorkbook.FontTable.ClearBuffer;
  FBIFFRecord.Data.ReadString(FontString, FBIFFRecord.Data.Size);
  GetFontDataFromFontString(FontString, Font);
  FWorkbook.FontTable.SaveChangedBufferWithDuplicates;
  
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadFormat;
var
  Ifmt: Word;
  S: AnsiString;
  FormatString: WideString;
  FormatStringLen: Word;
  B: Byte;
begin
  FBIFFRecord.Data.ReadWord(Ifmt);
  FBIFFRecord.Data.ReadWord(FormatStringLen);
  FBIFFRecord.Data.ReadByte(B);
  if ((B and $01) = $01) then
  begin
    FBIFFRecord.Data.ReadString(S, FormatStringLen * 2);
    FormatString:= ANSIWideStringToWideString(S);
  end
  else
  begin
    FBIFFRecord.Data.ReadString(S, FormatStringLen);
    FormatString:= StringToWideString(S);
  end;

  FWorkbook.FormatStrings.AddFormatAndIfmt(FormatString, Ifmt);
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadXF;
var
  XF: PXFData;
  XFString: AnsiString;
  Index: Integer;
begin
  { If read the 1st XF record - then clear XF table }
  if not FXFRecordsExist then
  begin
    FWorkbook.XFTable.Clear;
    FXFRecordsExist:= True;
  end;

  { Read XF and add to XF table, duplicate XFs allowed here ! }
  XF:= FWorkbook.XFTable.ClearBuffer;
  FBIFFRecord.Data.ReadString(XFString, FBIFFRecord.Data.Size);
  GetXFDataFromXFString(XFString, XF);

  {translate font index - skip 04 font}
  if XF^.FontIndex >= 4 then XF^.FontIndex:= XF^.FontIndex - 1;

  {translate format index - from ifmt to FormatStringIndex}
  Index:= FWorkbook.FormatStrings.IndexByIfmt[XF^.FormatIndex];
  if (Index = -1) then
    XF^.FormatIndex:= 0
  else
    XF^.FormatIndex:= Index;

  {add new record to XF table}
  FWorkbook.XFTable.SaveChangedBufferWithDuplicates;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadPalette;
var
  ColorCount, ColorIndex: Word;
  Color: Longword;
begin
  FBIFFRecord.Data.ReadWord(ColorCount);

  for ColorIndex:= 1 to ColorCount do
  begin
    FBIFFRecord.Data.ReadDWord(Color);
    if TXLColorIndex(ColorIndex) <= High(TXLColorIndex) then
      XLSColorIndexToColorMap[TXLColorIndex(ColorIndex)]:= Color;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadName;
var
  S: AnsiString;
begin
  { Read all data and add to link table }
  FBIFFRecord.Data.ReadString(S, FBIFFRecord.Data.ReadableSize);
  FLinkTable.AddName(S);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ProcessNames;
var
  I: Integer;
  Name: TXLSLinkName;
  SheetIndex: Integer;
  R: TRange;
begin
  for I:= 0 to FLinkTable.LocalDocument.NamesCount - 1 do
  begin
    Name:= FLinkTable.LocalDocument.Name[I];
    SheetIndex:= Name.SheetIndex;

    if ((SheetIndex>= 0) and (SheetIndex < FWorkbook.Sheets.Count)) then
    begin

      { Print area }
      if (Name.BuiltInName = binPrintArea) then
       FWorkbook.Sheets[SheetIndex].PageSetup.PrintArea.AddRangeRects(Name.Area);

      { Repeatable rows/columns }
      if (Name.BuiltInName = binPrintTitles) then
      begin
        if (Name.Area.RectsCount >= 1) then
        begin
          FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageFrom:=
            Name.Area.Rect[0].RowFrom;
          FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageTo:=
            Name.Area.Rect[0].RowTo;
        end;
        if (Name.Area.RectsCount >= 2) then
        begin
          FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageFrom:=
            Name.Area.Rect[1].ColumnFrom;
          FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageTo:=
            Name.Area.Rect[1].ColumnTo;
        end;
      end;
       
      { Add user-defined names as ranges into sheets }
      if (Name.BuiltInName = binNoName) then
      begin
        R:= FWorkbook.Sheets[SheetIndex].Ranges.Add;
        R.AddRangeRects(Name.Area);
        R.Name:= Name.Name;
      end;
    end;
  end;
end;

procedure TXLSReader.ReadExternsheet;
var
  S: AnsiString;
begin
  { Read all data and add to link table }
  FBiffRecord.Data.ReadString(S, FBiffRecord.Data.ReadableSize);
  FLinkTable.AddExternsheet(S);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadExternname;
var
  S: AnsiString;
begin
  { Read all data and add to link table }
  FBiffRecord.Data.ReadString(S, FBiffRecord.Data.ReadableSize);
  FLinkTable.AddExternname(S);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadSupbook;
var
  S: AnsiString;
begin
  { Read all data and add to link table }
  FBiffRecord.Data.ReadString(S, FBiffRecord.Data.ReadableSize);
  FLinkTable.AddSupbook(S);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.SetCellXFIndex(C: TCell; const XFIndex: Word);
var
  Ifmt: Word;
  FormatIndex: Integer;
  FormatString: WideString;
  BaseValueType: AnsiString;
  D: TDateTime;
  StartD: TDateTime;
  MagicD: TDateTime;
begin
  if (XFIndex >= FWorkbook.XFTable.Count) then
    Exit;

  { set XF index }
  C.XFTableIndex:= XFIndex;

  { find value base type }
  if (XFIndex = FCacheXFIndex) then
  begin
    BaseValueType:= FCacheBaseValueType;
  end
  else
  begin
    FormatIndex:= C.FormatStringIndex;

    { find and setup data type from format }
    if    (FormatIndex >=0 )
      and (FormatIndex < FWorkbook.FormatStrings.FormatsCount ) then
    begin
      {ifmt}
      Ifmt:= FWorkbook.FormatStrings.Formats[FormatIndex].ifmt;
      BaseValueType:= BuiltinFormatIfmtToBaseType(Ifmt);

      { if type not defined from Ifmt then try to define type from format string}
      if BaseValueType = '' then
      begin
        FormatString:= FWorkbook.FormatStrings.Formats[FormatIndex].FormatString;
        if FormatString <> '' then
          BaseValueType:= FormatToBaseType(FormatString);
      end;

      { set cache }
      FCacheXFIndex:= XFIndex;
      FCacheBaseValueType:= BaseValueType;
    end;
  end;

  { Date stored as number.
   If it is formatted as date, we must convert cell value to TDateTime }
  if (     (BaseValueType = 'date')
       and (VarType(C.Value) in [ xfVarSingle, xfVarDouble, xfVarCurrency
                                , xfVarInteger, xfVarSmallint, xfVarByte
                                , xfVarDecimal, xfVarShortInt, xfVarWord
                                , xfVarLongWord, xfVarInt64
                                ])
     ) then
  begin
    StartD:= EncodeDate(1900, 1, 1);
    MagicD:= EncodeDate(1900, 3, 1);
    D:= StartD + Double(C.Value) - 1;
    if D > MagicD then
      D:= D - 1;
    C.Value:= D;
  end;
end;

procedure TXLSReader.ReadLabelSST;
var
  Row, Column: Word;
  XFIndex: Word;
  SSTIndex: Longword;
  S: AnsiString;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);
  FBIFFRecord.Data.ReadDWord(SSTIndex);

  C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];

  S:= FSST[SSTIndex];
  if S[1] = #0 then
    C.Value:= Copy(S, 2, Length(S) - 1)
  else
    C.Value:= SSTStringToWideString(S);

  SetCellXFIndex(C, XFIndex);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadLabel;
var
  Row, Column,
  XFIndex: Word;
  S: AnsiString;
  StringLen: Word;
  StringOptions: Byte;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);
  FBIFFRecord.Data.ReadWord(StringLen);

  C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];

  if (StringLen > 0) then
  begin
    FBIFFRecord.Data.ReadByte(StringOptions);
    if ((StringOptions and $01) = $01) then
    begin
      FBIFFRecord.Data.ReadString(S, StringLen * 2);
      C.Value:= ANSIWideStringToWideString(S);
    end
    else
    begin
      FBIFFRecord.Data.ReadString(S, StringLen);
      C.Value:= S;
    end;
  end
  else
    C.Value:= '';

  SetCellXFIndex(C, XFIndex);

  FBIFFRecordProcessed:= True;
end;


procedure TXLSReader.ReadRK;
var
  Row, Column: Word;
  XFIndex: Word;
  Num: Double;
  RK: Integer;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);

  FBIFFRecord.Data.ReadBytes(@RK, SizeOf(Integer));
  Num:= NumberFromRK(RK);

  C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];

  C.Value:= Num;
  SetCellXFIndex(C, XFIndex);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadMulRK;
var
  Row, Column: Word;
  XFIndex: Word;
  Num: Double;
  RK: Integer;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);

  while FBIFFRecord.Data.ReadableSize > 6 do
  begin
    FBIFFRecord.Data.ReadWord(XFIndex);
    FBIFFRecord.Data.ReadBytes(@RK, SizeOf(Integer));
    Num:= NumberFromRK(RK);

    C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];
    C.Value:= Num;
    SetCellXFIndex(C, XFIndex);

    Column:= Column + 1;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadNumber;
var
  Row, Column: Word;
  XFIndex: Word;
  Num: Double;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);
  FBIFFRecord.Data.ReadBytes(@Num, SizeOf(Double));

  C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];

  C.Value:= Num;
  SetCellXFIndex(C, XFIndex);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadBlank;
var
  Row, Column: Word;
  XFIndex: Word;
  C: TCell;
begin
  if (not FOptions.ReadEmptyCells) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;
  
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);

  { Optimize - do not read empty formatted blank cells }
  if not IsXFDataEmpty(FWorkbook.XFTable.XF[XFIndex]) then
  begin
    C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];
    SetCellXFIndex(C, XFIndex);
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadMulBlank;
var
  Row, Column: Word;
  XFIndex: Word;
  C: TCell;
begin
  if (not FOptions.ReadEmptyCells) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);

  while FBIFFRecord.Data.ReadableSize > 2 do
  begin
    FBIFFRecord.Data.ReadWord(XFIndex);
    if (XFIndex < FWorkbook.XFTable.Count) then
    begin
      { Optimize - do not read empty formatted blank cells }
      if not IsXFDataEmpty(FWorkbook.XFTable.XF[XFIndex]) then
      begin
        C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];
        SetCellXFIndex(C, XFIndex);
      end;  
    end;

    Column:= Column + 1;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadBoolean;
var
  Row, Column: Word;
  XFIndex: Word;
  BoolErr: Word;
  C: TCell;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);
  FBIFFRecord.Data.ReadWord(BoolErr);

  if (BoolErr = 0) or (BoolErr = 1) then
  begin
    C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];

    if BoolErr = 1 then
      C.Value:= True
    else
      C.Value:= False;
    SetCellXFIndex(C, XFIndex);
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadRow;
var
  W, W2: Word;
  RowIndex: Word;
  OutlineLevel: Byte;
  AutoFit: Boolean;
  Formatted: Boolean;
  Hidden: Boolean;
  I: Integer;
  XFIndex: Word;
begin
  if (not FOptions.ReadRowFormats) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBIFFRecord.Data.ReadWord(RowIndex);
  FBIFFRecord.Data.SkipBytes(4);
  FBIFFRecord.Data.ReadWord(W); // height
  FBIFFRecord.Data.SkipBytes(4);
  FBIFFRecord.Data.ReadWord(W2); // options
  FBIFFRecord.Data.ReadWord(XFIndex); // XF index

  OutlineLevel:= Byte(W2 and $07);
  Hidden:= ((W2 and $20) <> 0);
  AutoFit:= ((W2 and $40) = 0);
  Formatted:= ((W2 and $80) <> 0);  

  FWorkbook.Sheets[FCurrentSheetIndex].Rows[RowIndex].Height:= W * 1.00 / xlRowHeightMult;

  if Hidden then
    FWorkbook.Sheets[FCurrentSheetIndex].Rows[RowIndex].Hidden:= True;

  for I:= 1 to OutlineLevel do
    FWorkbook.Sheets[FCurrentSheetIndex].GroupRows(RowIndex, RowIndex);

  if AutoFit then
    FWorkbook.Sheets[FCurrentSheetIndex].Rows[RowIndex].AutoFit;

  if Formatted then
  begin
    if (XFIndex < FWorkbook.XFTable.Count) then
      FWorkbook.Sheets[FCurrentSheetIndex].Rows[RowIndex].XFTableIndex:= XFIndex;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadColumn;
var
  W, W2: Word;
  I, FirstColumnIndex, LastColumnindex: Word;
  OutlineLevel: Byte;
  Hidden: Boolean;
  XFIndex: Word;
begin
  if (not FOptions.ReadColumnFormats) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBIFFRecord.Data.ReadWord(FirstColumnIndex);
  FBIFFRecord.Data.ReadWord(LastColumnIndex);
  FBIFFRecord.Data.ReadWord(W);  // width
  FBIFFRecord.Data.ReadWord(XFIndex); // XF index
  FBIFFRecord.Data.ReadWord(W2); // options
  OutlineLevel:= Byte((W2 shr 8) and $07);
  Hidden:= ((W2 and $01) <> 0);

  if (LastColumnIndex > (BIFF8_MAXCOLS - 1)) then
    LastColumnIndex:= BIFF8_MAXCOLS - 1;

  for I:= FirstColumnIndex to LastColumnIndex do
  begin
    FWorkbook.Sheets[FCurrentSheetIndex].Columns[I].Width:= StoredWidthToXLSWidth(W);
    
    if Hidden then
      FWorkbook.Sheets[FCurrentSheetIndex].Columns[I].Hidden:= True;

    FWorkbook.Sheets[FCurrentSheetIndex].Columns[I].XFTableIndex:= XFIndex;
  end;

  for I:= 1 to OutlineLevel do
    FWorkbook.Sheets[FCurrentSheetIndex].GroupColumns(FirstColumnIndex, LastColumnIndex);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadMergedCells;
var
  R: TRange;
  RowFrom, RowTo, ColumnFrom, ColumnTo: Word;
begin
  {skip header}
  FBIFFRecord.Data.SkipBytes(2);

  while FBIFFRecord.Data.ReadableSize >=8 do
  begin
    {add new range}
    R:= FWorkbook.Sheets[FCurrentSheetIndex].Ranges.Add;

    {read rect - 8 bytes}
    FBIFFRecord.Data.ReadWord(RowFrom);
    FBIFFRecord.Data.ReadWord(RowTo);
    FBIFFRecord.Data.ReadWord(ColumnFrom);
    FBIFFRecord.Data.ReadWord(ColumnTo);    

    {add rect to range}
    R.AddRect(RowFrom, RowTo, ColumnFrom, ColumnTo);

    {merge rect}
    R.MergeCells;
  end;

  FBIFFRecordProcessed:= True;  
end;

procedure TXLSReader.ReadFormula;
var
  Row, Column: Word;
  XFIndex: Word;
  FormulaValue: array[1..8] of Byte;
  DoubleValue: Double;
  BooleanValue: Boolean;
  SOptions: AnsiString;
  FormulaDataLength: Word;
  FormulaData: AnsiString;
begin
  FBIFFRecord.Data.ReadWord(Row);
  FBIFFRecord.Data.ReadWord(Column);
  FBIFFRecord.Data.ReadWord(XFIndex);

  { read value }
  FBIFFRecord.Data.ReadBytes(@FormulaValue[1], 8);
  if (FormulaValue[7] = $FF) and (FormulaValue[8] = $FF) then
  begin
    case FormulaValue[1] of
      1: begin
          { boolean value }
           if (FormulaValue[3] = 1) then
             BooleanValue:= True
           else
             BooleanValue:= False;

           FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column].Value:= BooleanValue;
         end;
      0: begin
           { string value }
           { Remember row and column, and use them for the next BIFF
            record which is BIFF_STRING }
           FRow:= Row;
           FColumn:= Column;
           FXFIndex:= XFIndex;
         end;
    end;
  end
  else
  begin
    { numeric value }
    Move(FormulaValue[1], DoubleValue, 8);
    FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column].Value:= DoubleValue;
  end;

  { set format }
  with FWorkbook.Sheets[FCurrentSheetIndex] do
    SetCellXFIndex(Cells[Row, Column], XFIndex);

  { Read formula }
  if FOptions.ReadFormulas then
  begin
    FBIFFRecord.Data.ReadString(SOptions, 2);
    FBIFFRecord.Data.SkipBytes(4);
    FBIFFRecord.Data.ReadWord(FormulaDataLength);
    FBIFFRecord.Data.ReadString(FormulaData, FormulaDataLength);
    FFormulas.Add(SOptions + FormulaData);
    FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column].Formula:=
      AnsiString(IntToStr(FFormulas.Count-1));
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadSharedFormula;
var
  SharedFormulaData: AnsiString;
begin
  if FOptions.ReadFormulas then
  begin
    if not Assigned(FPtgParser) then CreatePtgParser;
    FBIFFRecord.Data.ReadString(SharedFormulaData, FBIFFRecord.Data.ReadableSize);
    FPtgParser.SharedFormulas.AddSharedFormula(FCurrentSheetIndex, SharedFormulaData);
  end;
  
  FBIFFRecordProcessed:= True;  
end;

procedure TXLSReader.ReadStringValueOfFormula;
var
  ReadableSize: Integer;
  Unicode: Boolean;

  StringLen: Word;
  StringLenToRead: Integer;
  StringLenRead: Integer;

  StringOptions: Byte;
  StringText: AnsiString;
  StringTextPart: AnsiString;
  StringTextIsUnicode: Boolean;
begin
  { read formula string value, and place it to FRow, FColumn }
  if (FRow >= 0 ) and ( FColumn >=0) and (FXFIndex >=0) then
  begin
    { Read string length }
    FBIFFRecord.Data.ReadWord(StringLen);

    { Read string options }
    FBIFFRecord.Data.ReadByte(StringOptions);
    Unicode:= ((StringOptions and $01) = $01);

   { Read string }
    StringText:= '';
    StringLenRead:= 0;
    StringTextIsUnicode:= False;
    while (StringLenRead < StringLen) do
    begin
      ReadableSize:= FBIFFRecord.Data.ReadableSize;
      if ReadableSize = 0 then
      begin
        if not CanUseNextBIFFRecord then
          break
        else
        begin
          { The 1st byte of continue record is options byte }
          ReadableSize:=  FBIFFRecord.Data.ReadableSize;
          if ReadableSize < 1 then
             if not CanUseNextBIFFRecord then
               break;

          FBIFFRecord.Data.ReadByte(StringOptions);
          Unicode:= ((StringOptions and $01) = $01);
          ReadableSize:=  FBIFFRecord.Data.ReadableSize;
        end;
      end;

      if Unicode then
      begin
        if not StringTextIsUnicode then
        begin
          StringText:= SparseString(StringText);
          StringTextIsUnicode:= True;
        end;

        if (ReadableSize div 2) < (StringLen - StringLenRead) then
          StringLenToRead:= ReadableSize div 2
        else
          StringLenToRead:= StringLen - StringLenRead;
        FBIFFRecord.Data.ReadString(StringTextPart, StringLenToRead * 2)
      end
      else
      begin
        if ReadableSize < (StringLen - StringLenRead) then
          StringLenToRead:= ReadableSize
        else
          StringLenToRead:= StringLen - StringLenRead;

        FBIFFRecord.Data.ReadString(StringTextPart, StringLenToRead);

        if StringTextIsUnicode then
          StringTextPart:= SparseString(StringTextPart);
      end;

      StringLenRead:= StringLenRead + StringLenToRead;
      StringText:= StringText + StringTextPart;
    end;

    with FWorkbook.Sheets[FCurrentSheetIndex] do
    begin
      { set value }
      if StringTextIsUnicode then
        Cells[FRow, FColumn].Value:= ANSIWideStringToWideString(StringText)
      else
        Cells[FRow, FColumn].Value:= StringText;
        
      { set format }
      SetCellXFIndex(Cells[FRow, FColumn], FXFIndex);
    end;  

    { clear parameters }
    FRow:= -1;
    FColumn:= -1;
    FXFIndex:= -1;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadSetup;
var
  W: Word;
  D: Double;
begin
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PaperSize:= TXLPaperSize(W);
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Scale:= W;
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.StartPageNum:= W;

  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FitPagesWidth:= W;
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FitPagesHeight:= W;

  { Options }
  FBiffRecord.Data.ReadWord(W);
  if (W and $01) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintPagesOrder := xlOverDown
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintPagesOrder := xlDownOver;

  if (W and ($01 shl 1)) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Orientation:= xlPortrait
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Orientation:= xlLandscape;  

  if (W and ($01 shl 3)) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.BlackAndWhite:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.BlackAndWhite:= False;

  if (W and ($01 shl 4)) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Draft:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Draft:= False;

  if (W and ($01 shl 7)) = 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.StartPageNum:= xlAutomatic;

  FBiffRecord.Data.SkipBytes(4);
  
  { Header and footer margins }
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.HeaderMargin:= D;
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FooterMargin:= D;

  FBiffRecord.Data.SkipBytes(2);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadWsbool;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);

  if (W and $40) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.RowGroupAtTop:= False
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.RowGroupAtTop:= True;

  if (W and $80) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.ColumnGroupAtLeft:= False
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.ColumnGroupAtLeft:= True;

  if (W and $100) <> 0 then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Zoom:= False
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.Zoom:= True;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadPrintHeaders;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  if (W = 1) then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintRowColLabels:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintRowColLabels:= False;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadPrintGridlines;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  if (W = 1) then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintGrid:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.PrintGrid:= False;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadTopMargin;
var
  D: Double;
begin
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.TopMargin:= D;
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadBottomMargin;
var
  D: Double;
begin
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.BottomMargin:= D;
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadLeftMargin;
var
  D: Double;
begin
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.LeftMargin:= D;
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadRightMargin;
var
  D: Double;
begin
  FBiffRecord.Data.ReadBytes(@D, 8);
  FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.RightMargin:= D;
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadHcenter;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  if (W = 1) then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.CenterHorizontally:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.CenterHorizontally:= False;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadVcenter;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  if (W = 1) then
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.CenterVertically:= True
  else
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.CenterVertically:= False;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadHeader;
var
  UnicodeFlag: Byte;
  Size: Word;
  Buff: AnsiString;
  WS, WSBuff: WideString;
  Pos1, Pos2: Integer;
  PosL, PosC, PosR: Integer;
begin
  if (FBiffRecord.Data.ReadableSize = 0) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBiffRecord.Data.ReadWord(Size);
  FBiffRecord.Data.ReadByte(UnicodeFlag);

  if ((UnicodeFlag and $01) = $01) then
  begin
    FBiffRecord.Data.ReadString(Buff, Size * 2);
    WS:= ANSIWideStringToWideString(Buff);
  end
  else
  begin
    FBiffRecord.Data.ReadString(Buff, Size);
    WS:= StringToWideString(Buff);
  end;

  Pos1:= Pos(WideString('&L'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&C&R';
    PosC:= Pos(WideString('&C'), WSBuff);
    PosR:= Pos(WideString('&R'), WSBuff);
    if (PosC < PosR) then Pos2:= PosC else Pos2:= PosR;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.HeaderTextLeft:= WSBuff;
  end;


  Pos1:= Pos(WideString('&C'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&L&R';
    PosL:= Pos(WideString('&L'), WSBuff);
    PosR:= Pos(WideString('&R'), WSBuff);
    if (PosL < PosR) then Pos2:= PosL else Pos2:= PosR;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.HeaderText:= WSBuff;
  end;

  Pos1:= Pos(WideString('&R'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&L&C';
    PosC:= Pos(WideString('&C'), WSBuff);
    PosL:= Pos(WideString('&L'), WSBuff);
    if (PosC < PosL) then Pos2:= PosC else Pos2:= PosL;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.HeaderTextRight:= WSBuff;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadFooter;
var
  UnicodeFlag: Byte;
  Size: Word;
  Buff: AnsiString;
  WS, WSBuff: WideString;
  Pos1, Pos2: Integer;
  PosL, PosC, PosR: Integer;
begin
  if (FBiffRecord.Data.ReadableSize = 0) then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBiffRecord.Data.ReadWord(Size);
  FBiffRecord.Data.ReadByte(UnicodeFlag);

  if ((UnicodeFlag and $01) = $01) then
  begin
    FBiffRecord.Data.ReadString(Buff, Size * 2);
    WS:= ANSIWideStringToWideString(Buff);
  end
  else
  begin
    FBiffRecord.Data.ReadString(Buff, Size);
    WS:= StringToWideString(Buff);
  end;

  Pos1:= Pos(WideString('&L'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&C&R';
    PosC:= Pos(WideString('&C'), WSBuff);
    PosR:= Pos(WideString('&R'), WSBuff);
    if (PosC < PosR) then Pos2:= PosC else Pos2:= PosR;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FooterTextLeft:= WSBuff;
  end;

  Pos1:= Pos(WideString('&C'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&L&R';
    PosL:= Pos(WideString('&L'), WSBuff);
    PosR:= Pos(WideString('&R'), WSBuff);
    if (PosL < PosR) then Pos2:= PosL else Pos2:= PosR;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FooterText:= WSBuff;
  end;

  Pos1:= Pos(WideString('&R'), WS);
  if (Pos1 > 0) then
  begin
    WSBuff:= Copy(WS, Pos1 + 2, Length(WS)) + '&L&C';
    PosC:= Pos(WideString('&C'), WSBuff);
    PosL:= Pos(WideString('&L'), WSBuff);
    if (PosC < PosL) then Pos2:= PosC else Pos2:= PosL;
    WSBuff:= Copy(WSBuff, 1, Pos2-1);
    FWorkbook.Sheets[FCurrentSheetIndex].PageSetup.FooterTextRight:= WSBuff;
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadPane;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].WindowOptions.FreezePoint.Column:= W;
  FBiffRecord.Data.ReadWord(W);
  FWorkbook.Sheets[FCurrentSheetIndex].WindowOptions.FreezePoint.Row:= W;
  FBiffRecord.Data.SkipBytes(6);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadZoom;
var
  Nom, Denom: Word;
begin
  FBiffRecord.Data.ReadWord(Nom);
  FBiffRecord.Data.ReadWord(Denom);
  if (Denom <> 0) then
    FWorkbook.Sheets[FCurrentSheetIndex].WindowOptions.ZoomPercent:= (100 * Nom) div Denom;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadSheetWindowOptions;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);
  with FWorkbook.Sheets[FCurrentSheetIndex].WindowOptions do
  begin
    DisplayGrids        := ((W and $02) <> 0);
    DisplayRowColHeaders:= ((W and $04) <> 0);
    DisplayZero         := ((W and $10) <> 0);
    DisplayRightToLeft  := ((W and $40) <> 0); 
    PageBreakPreview    := ((W and $800) <> 0);
  end;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadProtectionPasswordHash;
var
  W: Word;
begin
  FBiffRecord.Data.ReadWord(W);

  if FGlobalSubstreamRead then
    { Sheet protection }
    FWorkbook.Sheets[FCurrentSheetIndex].ProtectPasswordHash:= W
  else
    { Workbook protection }
    FWorkbook.ProtectPasswordHash:= W;

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadSheetProtection;
var
  W: Word;
begin
  if (FBiffRecord.Data.ReadableSize >= 21) then
  begin
    FBiffRecord.Data.SkipBytes(19);
    FBiffRecord.Data.ReadWord(W);
    FWorkbook.Sheets[FCurrentSheetIndex].ProtectMode:= W;
  end;
  FBIFFRecordProcessed:= True;  
end;

procedure TXLSReader.ReadFilepass;
var
  IsBIFF8Encryption: Word;
  IsStandardEncryption: Word;
  DocID: TArray16Byte;
  Salt: TArray64Byte;
  HashedSalt: TArray16Byte;
  Digest: TMD5Digest;
  IsValidPassword: Boolean;
begin
  FBiffRecord.Data.ReadWord(IsBIFF8Encryption);

  if (IsBIFF8Encryption <> 1) then
    raise Exception.Create('Error: data is protected, and this encryption type not supported.');

  FBiffRecord.Data.SkipBytes(2);
  FBiffRecord.Data.ReadWord(IsStandardEncryption);
  if (IsStandardEncryption <> 1) then
    raise Exception.Create('Error: strong encryption not supported.');

  { Init BIFF8 standard encryption }
  FillChar(Salt[0], SizeOf(Salt), 0);
  FBiffRecord.Data.ReadBytes(@DocID[0], 16);
  FBiffRecord.Data.ReadBytes(@Salt[0], 16);
  FBiffRecord.Data.ReadBytes(@HashedSalt[0], 16);

  { Try user specified password }
  IsValidPassword:= BIFF8ProtectVerifyPassword(FPassword, DocID, Salt, HashedSalt, Digest);

  { Try workbook protection crypt password (VelvetSweatshop)}
  if not IsValidPassword then
  begin
    IsValidPassword:= BIFF8ProtectVerifyPassword(BIFF8_BOOKPROTECT_CRYPTPASSWORD, DocID, Salt, HashedSalt, Digest);

    if not IsValidPassword then
      raise Exception.Create('Error: file is protected, and password is invalid!');    
  end;

  FWorkbookStream.SetBIFF8Encryption(Digest);  

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadCellValidation;
var
  V: TCellValidation;
  RawData: AnsiString;
begin
  { Read raw data }
  SetLength(RawData, FBiffRecord.Size);
  FBiffRecord.Data.ReadString(RawData, FBiffRecord.Size);

  { Create parser for expresions }
  CreatePtgParser;

  V:= TCellValidation.Create;
  DVDataToCellValidation(RawData, V, FPtgParser, FCurrentSheetIndex, FOptions.RaiseErrorOnReadUnknownFormula);
  FWorkbook.Sheets[FCurrentSheetIndex].CellValidations.AddItem(V);

  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadMSODrawingGroup;
var
  Data: TEasyStream;

  function MSODrawingGroupContinue: Boolean;
  begin
    FBIFFRecordProcessed:= True;
    Result:= FetchBIFFRecord;
    if Result then
      Result:= (FBIFFRecord.RecNum = BIFF_CONTINUE)
            or (FBIFFRecord.RecNum = BIFF_MSODRAWINGGROUP);
  end;

begin
  if not FOptions.ReadDrawings then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FBIFFRecordProcessed:= True;
    
  Data:= TEasyStream.Create;
  try
    Data.CopyFrom(FBiffRecord.Data, FBiffRecord.Data.ReadableSize);
    while MSODrawingGroupContinue do
      Data.CopyFrom(FBiffRecord.Data, FBiffRecord.Data.ReadableSize);

    Data.Position:= 0;
    FMSOData.AddMSODrawingGroupData(Data);
  finally
    Data.Destroy;
  end;
end;

procedure TXLSReader.ReadMSODrawing;
begin
  if not FOptions.ReadDrawings then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FMSOData.AddMSODrawingData(FBiffRecord.Data, FCurrentSheetIndex);
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadMSOObject;
begin
  if not FOptions.ReadDrawings then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FMSOData.AddDescribesObjectData(FBiffRecord.Data, FCurrentSheetIndex);

  FBIFFRecordProcessed:= True;

  { BIFF_CONTINUE after MSO object means BIFF_MSODRAWING }
  if CanUseNextBIFFRecord then
  begin
    FBiffRecord.RecNum:= BIFF_MSODRAWING;
  end;
end;

procedure TXLSReader.ReadMSOTextObject;
begin
  if not FOptions.ReadDrawings then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  { read TXO record }
  FMSOData.AddTextObjectData(FBiffRecord.Data, FCurrentSheetIndex, 0);

  FBIFFRecordProcessed:= True;

  { read BIFF_CONTINUE records }
  { read 1st continue record }
  if CanUseNextBIFFRecord then
    FMSOData.AddTextObjectData(FBiffRecord.Data, FCurrentSheetIndex, 1)
  else
    Exit;
    
  { read 2nd continue record }
  if CanUseNextBIFFRecord then
    FMSOData.AddTextObjectData(FBiffRecord.Data, FCurrentSheetIndex, 2)
  else
    Exit;

  { 3rd BIFF_CONTINUE after TXO means BIFF_MSODRAWING }
  if CanUseNextBIFFRecord then
  begin
    FBiffRecord.RecNum:= BIFF_MSODRAWING;
  end;
end;

procedure TXLSReader.ReadCellComment;
begin
  if not FOptions.ReadDrawings then
  begin
    FBIFFRecordProcessed:= True;
    Exit;
  end;

  FMSOData.AddCommentData(FBiffRecord.Data, FCurrentSheetIndex);
  FBIFFRecordProcessed:= True;
end;

procedure TXLSReader.ReadHyperlink;
var
  Hyperlink: WideString;
  HyperlinkType: TCellHyperlinkType;
  RowFrom: Word;
  RowTo: Word;
  ColumnFrom: Word;
  ColumnTo: Word;
  Row, Column: Integer;
  RawData: AnsiString;
  C: TCell;
begin
  { Read raw data }
  SetLength(RawData, FBiffRecord.Size);
  FBiffRecord.Data.ReadString(RawData, FBiffRecord.Size);

  Hyperlink:= ParseCellHyperlink(RawData, HyperlinkType
    , RowFrom, RowTo, ColumnFrom, ColumnTo);

  if (Hyperlink <> '') then
  begin
    for Row:= RowFrom to RowTo do
      for Column:= ColumnFrom to ColumnTo do
      begin
        C:= FWorkbook.Sheets[FCurrentSheetIndex].Cells[Row, Column];
        C.Hyperlink:= Hyperlink;
        C.HyperlinkType:= HyperlinkType;
      end;
  end;

  FBIFFRecordProcessed:= True;
end;

{ Processing methods }
procedure TXLSReader.ProcessFormulas;
var
  ASheetIndex, ACellIndex, ARow, AColumn: Integer;
  C: TCell;
  AFormulaIndex: Integer;
  AFormulaData: AnsiString;
  AOptions: Word;
  AParcerResult: Integer;
begin
  { If no formulas read then exit }
  if (FFormulas.Count = 0) then Exit;
  { Create parser }
  if not Assigned(FPtgParser) then CreatePtgParser;

  { Enumerate all cells and process formulas }
  for ASheetIndex:= 0 to FWorkbook.Sheets.Count-1 do
  begin
    for ACellIndex:= 0 to FWorkbook.Sheets[ASheetIndex].Cells.Count-1 do
    begin
      C:= FWorkbook.Sheets[ASheetIndex].Cells.Item[ACellIndex];
      AFormulaData:= C.Formula;
      if (AFormulaData <> '') then
      begin
        AFormulaIndex:= StrToInt(String(AFormulaData));
        AFormulaData:= FFormulas[AFormulaIndex];
        ARow:= C.Row;
        AColumn:= C.Col;

        AOptions:= 0;
        Move(AFormulaData[1], AOptions, 2);
        AFormulaData:= Copy(AFormulaData, 3, Length(AFormulaData) - 2);

        try
          AParcerResult:= FPtgParser.Parse(ASheetIndex, ARow, AColumn, AOptions, AFormulaData);
          if (AParcerResult = 0) then
            C.Formula:= FPtgParser.Expression;
        except
          AParcerResult:= -1;
        end;

        if (AParcerResult <> 0) then
        begin
          if FOptions.RaiseErrorOnReadUnknownFormula then
            raise EXLSError.Create(EXLS_UNKNOWNFORMULA)
          else
            C.Formula:= '';
        end;

      end;
    end;
  end;
end;

procedure TXLSReader.ProcessXFTable;
begin
  { Update default XF index after reading }
  FWorkbook.XFTable.UpdateDefaultIndex;
end;

procedure TXLSReader.ProcessMSOShapes;
var
  I: Integer;

  procedure AddImage;
  var
    Image: TMSOShapeImage;
    BLIPID: Integer;
    ImageData: TEasyStream;

    ColumnFromOffsetPx, ColumnToOffsetPx: Integer;
    RowFromOffsetPx, RowToOffsetPx: Integer;
    WidthPx, HeightPx: Integer;
    ColumnIndex, RowIndex: Integer;
  begin
    Image:= TMSOShapeImage(FMSOData.Shape[I]);

    BLIPID:= Image.BLIPID - 1; // get 0-based index
    if not (( BLIPID >= 0) and (BLIPID < FMSOData.BLIPCount)) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);

    if not ((Image.SheetIndex >= 0) and (Image.SheetIndex < FWorkbook.Sheets.Count)) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);

    { Get image size }
    ColumnFromOffsetPx:= ColumnAdditionToOffsetPx(Image.Anchor.ColumnFromAddition,
        FWorkbook.Sheets[Image.SheetIndex].Columns[Image.Anchor.ColumnFrom].VisibleWidthPx);
    ColumnToOffsetPx:= ColumnAdditionToOffsetPx(Image.Anchor.ColumnToAddition,
        FWorkbook.Sheets[Image.SheetIndex].Columns[Image.Anchor.ColumnTo].VisibleWidthPx);
    RowFromOffsetPx:= RowAdditionToOffsetPx(Image.Anchor.RowFromAddition,
        FWorkbook.Sheets[Image.SheetIndex].Rows[Image.Anchor.RowFrom].VisibleHeightPx);
    RowToOffsetPx:= RowAdditionToOffsetPx(Image.Anchor.RowToAddition,
        FWorkbook.Sheets[Image.SheetIndex].Rows[Image.Anchor.RowTo].VisibleHeightPx);

    WidthPx:=  (- ColumnFromOffsetPx + ColumnToOffsetPx);
    for ColumnIndex:= Image.Anchor.ColumnFrom to Image.Anchor.ColumnTo - 1 do
      WidthPx:= WidthPx + FWorkbook.Sheets[Image.SheetIndex].Columns[ColumnIndex].VisibleWidthPx;

    HeightPx:=  (- RowFromOffsetPx + RowToOffsetPx);
    for RowIndex:= Image.Anchor.RowFrom to Image.Anchor.RowTo - 1 do
      HeightPx:= HeightPx + FWorkbook.Sheets[Image.SheetIndex].Rows[RowIndex].VisibleHeightPx;

    FMSOData.BLIP[BLIPID].ImageData.Position:= 0;

    { Get image data }
    ImageData:= TEasyStream.Create;
    try
      ImageData.CopyFrom(FMSOData.BLIP[BLIPID].ImageData,
        FMSOData.BLIP[BLIPID].ImageData.Size);

      { Add image to sheet }
      FWorkbook.Sheets[Image.SheetIndex].Images.AddStretchFromStreamPx(
          ImageData
        , 0
        , ImageData.Size
        , Image.Anchor.ColumnFrom
        , Image.Anchor.RowFrom
        , ColumnFromOffsetPx
        , RowFromOffsetPx
        , WidthPx
        , HeightPx
        );
    finally
      ImageData.Destroy;
    end;
  end;

  procedure AddCellComment;
  var
    ColumnFromOffsetPx, ColumnToOffsetPx: Integer;
    RowFromOffsetPx, RowToOffsetPx: Integer;
    WidthPx, HeightPx: Integer;
    ColumnIndex, RowIndex: Integer;
    Comment: TMSOShapeComment;
    SheetIndex, LinkedToRow, LinkedToColumn: Integer;
    C: TCellComment;

    function ParseRichFormat(const S: AnsiString): AnsiString;
    var
      I: Integer;
      FontIndex: Word;
      CharIndex, NextCharIndex: Word;
    begin
      Result:= '';

      I:= 1;
      while (I + 7 <= Length(S)) do
      begin
        Move(S[I], CharIndex, 2);
        Move(S[I + 2], FontIndex, 2);

       {translate font index - skip 04 font}
        if FontIndex >= 4 then FontIndex:= FontIndex - 1;

        if (I + 9 <= Length(S)) then
          Move(S[I + 8], NextCharIndex, 2)
        else
          NextCharIndex:= Length(Comment.Text) + 1;

        if (CharIndex <= (NextCharIndex - 1)) then
          Result:= Result
                 + FontIndexToRichFormat(CharIndex + 1
                                       , (NextCharIndex - 1) + 1
                                       , FontIndex
                                       , FWorkbook.FontTable);
        I:= I + 8;
      end;
    end;

  begin
    Comment:= TMSOShapeComment(FMSOData.Shape[I]);

    SheetIndex:= Comment.SheetIndex;
    LinkedToRow:= Comment.LinkedToRow;
    LinkedToColumn:= Comment.LinkedToColumn;

    if not ((SheetIndex >= 0) and (SheetIndex < FWorkbook.Sheets.Count)) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);
    if not ((LinkedToRow >= 0) and (LinkedToRow < BIFF8_MAXROWS)) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);
    if not ((LinkedToColumn >= 0) and (LinkedToColumn < BIFF8_MAXCOLS)) then
      raise EXLSError.Create(EXLS_INVALIDDRAWING);

    { Get anchor size }
    ColumnFromOffsetPx:= ColumnAdditionToOffsetPx(Comment.Anchor.ColumnFromAddition,
        FWorkbook.Sheets[SheetIndex].Columns[Comment.Anchor.ColumnFrom].VisibleWidthPx);
    ColumnToOffsetPx:= ColumnAdditionToOffsetPx(Comment.Anchor.ColumnToAddition,
        FWorkbook.Sheets[SheetIndex].Columns[Comment.Anchor.ColumnTo].VisibleWidthPx);
    RowFromOffsetPx:= RowAdditionToOffsetPx(Comment.Anchor.RowFromAddition,
        FWorkbook.Sheets[SheetIndex].Rows[Comment.Anchor.RowFrom].VisibleHeightPx);
    RowToOffsetPx:= RowAdditionToOffsetPx(Comment.Anchor.RowToAddition,
        FWorkbook.Sheets[SheetIndex].Rows[Comment.Anchor.RowTo].VisibleHeightPx);

    WidthPx:=  (- ColumnFromOffsetPx + ColumnToOffsetPx);
    for ColumnIndex:= Comment.Anchor.ColumnFrom to Comment.Anchor.ColumnTo - 1 do
      WidthPx:= WidthPx + FWorkbook.Sheets[SheetIndex].Columns[ColumnIndex].VisibleWidthPx;

    HeightPx:=  (- RowFromOffsetPx + RowToOffsetPx);
    for RowIndex:= Comment.Anchor.RowFrom to Comment.Anchor.RowTo - 1 do
      HeightPx:= HeightPx + FWorkbook.Sheets[SheetIndex].Rows[RowIndex].VisibleHeightPx;

    { Add comment }
    C:= FWorkbook.Sheets[SheetIndex].CellComments[LinkedToRow, LinkedToColumn];
    C.Text:= Comment.Text;
    C.Author:= Comment.Author;
    C.WidthPx:= WidthPx;
    C.HeightPx:= HeightPx;
    C.RichFormat:= ParseRichFormat(Comment.RichFormat);
  end;

begin
  if not FOptions.ReadDrawings then
    Exit;

  { Delete unrecognized shapes }
  FMSOData.DeleteUnconfirmedShapes;

  { Process shapes }
  for I:= 0 to FMSOData.ShapesCount - 1 do
  begin
    if (FMSOData.Shape[I] is TMSOShapeImage) then AddImage
    else
    if (FMSOData.Shape[I] is TMSOShapeComment) then AddCellComment;
  end;
end;

function TXLSReader.GetFileVersion(const AFileName: WideString): Byte;
var
  ACFile: TCFile;
  Stream: TCFileStream;
begin
  Result:= xfVersionBIFFNONE;
  ACFile:= nil;

  try
    ACFile:= TCFile.Create(cfCreateFromFile, AFileName);
  except
    if Assigned(ACFile) then ACFile.Destroy;
    Exit;
  end;

  try
    Stream:= TCFileStream(ACFile.Root.FindItem('Workbook'));
    if Assigned(Stream) then
      Result:= xfVersionBIFF8;

  finally
    ACFile.Destroy;
  end;
end;

function TXLSReader.GetFileProtectionMethod(const AFileName: WideString): Integer;
var
  ACFile: TCFile;
  Stream: TCFileStream;
  AWorkbookStream: TBIFFStream;
  ABIFFRecord: TBIFFRecord;
  Counter, MaxRecordsToFind: Integer;

  function GetFileProtectionMethodAnalyze: Integer;
  var
    IsBIFF8Encryption: Word;
    IsStandardEncryption: Word;
    DocID: TArray16Byte;
    Salt: TArray64Byte;
    HashedSalt: TArray16Byte;
    Digest: TMD5Digest;
    IsValidPassword: Boolean;
  begin
    ABiffRecord.Data.ReadWord(IsBIFF8Encryption);
    if (IsBIFF8Encryption <> 1) then
    begin
      Result:= xfFileEncryptionUnsupported;
      Exit;
    end;

    ABiffRecord.Data.SkipBytes(2);
    ABiffRecord.Data.ReadWord(IsStandardEncryption);
    if (IsStandardEncryption <> 1) then
    begin
      Result:= xfFileEncryptionUnsupported;
      Exit;
    end;

    { Init BIFF8 standard encryption }
    FillChar(Salt[0], SizeOf(Salt), 0);
    ABiffRecord.Data.ReadBytes(@DocID[0], 16);
    ABiffRecord.Data.ReadBytes(@Salt[0], 16);
    ABiffRecord.Data.ReadBytes(@HashedSalt[0], 16);

    Result:= xfFileEncryptionBIFF8Standard;

    { Try workbook protection crypt password (VelvetSweatshop).
      If workbook is protected then return that it is not encrypted.}
    IsValidPassword:= BIFF8ProtectVerifyPassword(BIFF8_BOOKPROTECT_CRYPTPASSWORD, DocID, Salt, HashedSalt, Digest);
    if IsValidPassword then
      Result:= xfFileEncryptionNONE;
  end;

begin
  Result:= xfFileEncryptionNONE;
  ACFile:= TCFile.Create(cfCreateFromFile, AFileName);

  try
    Stream:= TCFileStream(ACFile.Root.FindItem('Workbook'));
    if not Assigned(Stream) then
      raise EXLSError.CreateFmt(EXLS_STREAMNOTFOUND, ['Workbook']);

    AWorkbookStream:= TBIFFStream.Create(Stream);
    try
      AWorkbookStream.Reset;
      ABIFFRecord:= AWorkbookStream.BIFFRecord;

      Counter:= 0;
      MaxRecordsToFind:= 5;
      while (AWorkbookStream.ReadBIFFRecord and (Counter < MaxRecordsToFind)) do
      begin
        Counter:= Counter + 1;

        if (ABIFFRecord.RecNum = BIFF_FILEPASS) then
        begin
          Result:= GetFileProtectionMethodAnalyze;
          Break;
        end;
      end;
    finally
      AWorkbookStream.Destroy;
    end;
  finally
    ACFile.Destroy;
  end;
end;

end.


