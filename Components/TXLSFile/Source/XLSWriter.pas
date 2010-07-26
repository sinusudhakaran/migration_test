unit XLSWriter;

{-----------------------------------------------------------------
    SM Software, 2000-2009

    TXLSFile v.4.0

    Rev history:
    2003-05-06   Add: Always set option "Outline symbols visible"
    2003-08-28   Fix: Write print area only if it is not empty
    2003-08-29   Add: SaveToStream added
    2003-10-30   Add: Do not save built-in number formats
    2003-11-02   Fix: Write BLIP list only if BLIP count > 0
    2003-12-04   Fix: Bug in ClearImageList fixed, when TSheetShapeList destroyed and used again
    2003-12-09   Fix: All objects destroy corectly
    2004-03-30   Add: OnProgress event added
    2004-07-26   Add: Using virtual font table    
    2004-09-30   Add: Dimensions record added, so the sheet may be used as an ODBC data source
    2005-05-21   Add: WritePanes added    
    2005-11-08   Fix: WritePanes option writing fixed
    2005-11-29   Add: Writing of hyperlinks to cells inside the workbook added
    2005-12-30   Add: Writing of rich strings
    2006-06-17   Add: Align data blocks to $200 to comply with OpenOffice 2.0.2      
    2008-02      Add: Data protection
    2008-04-09   Add: Country information added required for F1Book component.
    2008-05-05   Add: Link table
    2008-05-26   Add: Cell comments
                      MSO drawing related methods changed
    2008-10-05   Fix: write local names sorted by sheet name. It prevents
                      "Name Conflict" dialog box in Excel 2003.                      

-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, Lists, XLSFile, CFile, XLSWorkbook, XLSBase, XLSError,
  HList, Unicode, XLSFormat, XLSRects, RPNParser, XLSMsoDraw,
  XLSFormatStr, BiffStream, XLSFont, XLSFormatXF, XLSProtect,
  XLSCellValidation, XLSLinkTable, XLSCellComment;

type
  {TXLSWriter}        
  TXLSWriter = class
  private
    FXLSFile: TXLSFile; {xls user data}
    FCFile: TCFile;     {OLE compound file to save}

    FWorkbook: TWorkbook;  {workbook data}
    FWorkbookStream: TCFileStream; {workbook stream in file}

    FCurrentStream: TCFileStream;
    FBytesWrote: Integer;

    FBIFF8EncryptionPassword: WideString;
    FBIFF8EncryptionDigest: TMD5Digest;

    FSSTIndex: TList;
    FSST: THashedStringList;

    FMSOData: TMSOData;
    FSheetsOffsets: TList;
    FFormulaParser: TXLSFormulaParser;
    FLinkTable: TXLSLinkTable;

    FOnProgress: TProgressEvent;
    FProgressRate: Double;
    FProgressForOneCell: Double;
    FDefaultXFCount: Integer;

    procedure DoProgress;

    procedure WriteGlobal;
    procedure WriteCell(ASheetInd, ACellInd: integer);
    procedure WriteSheet(ASheetInd: integer);
    procedure WriteSST;
    procedure WriteWorkbook;
    procedure WriteXFTable;
    procedure WriteFontTable;
    procedure WriteFormatTable;
    procedure WriteStyleTable;
    procedure FillLinkTable;
    procedure WriteLinkTable;

    procedure BIFF8EncryptWorkbookStream;
    procedure AlignWorkbookStream;

    procedure WriteByte(const B:Byte);
    procedure WriteWord(const W: Word);
    procedure WriteDWord(const D: LongWord);
    procedure WriteBytes(Buff: Pointer; Size: Integer);

    procedure SaveXLSFile;    
  public
    constructor Create(AXLSFile: TXLSFile);
    destructor Destroy; override;
    procedure SaveAs(const AFileName: WideString);
    procedure SaveAsProtected(const AFileName: WideString; const APassword: WideString);
    procedure SaveToStream(const AStream: TStream);
    procedure SaveToStreamProtected(const AStream: TStream; const APassword: WideString);
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
  end;

  {PWord}
  PWord = ^Word;
  {PByte}
  PByte = ^Byte;
  {PDWord}
  PDWord = ^Longword;

implementation

uses
{$IFDEF XLF_D6}
  Variants,
{$ENDIF}
  Graphics,
  Math,
  SysUtils,
  XLSRichString,
  Streams,
  XLSHyperlink;


{TXLSWriter}
constructor TXLSWriter.Create(AXLSFile: TXLSFile);
begin
  FXLSFile:= AXLSFile;
  FWorkbook:= FXLSFile.Workbook;
  FBIFF8EncryptionPassword:= '';

  FSheetsOffsets:= TList.Create;
  FLinkTable:= FWorkbook.LinkTable;
  FFormulaParser:= TXLSFormulaParser.Create(FLinkTable);

  FillLinkTable;  
end;

destructor TXLSWriter.Destroy;
begin
  FLinkTable.Clear;
  FFormulaParser.Destroy;
  FSheetsOffsets.Destroy;
  inherited;
end;

procedure TXLSWriter.FillLinkTable;
var
  SheetIndex, RangeIndex, MapIndex: Integer;
  R: TRange;
  SheetNamesSorted: TAnsiStringList;
  SheetIndexesMap: TList;

  procedure PreParseFormulas;
  var
    SheetIndex, CellIndex, CVIndex: Integer;
    Formula: AnsiString;
  begin
    for SheetIndex:= 0 to FWorkbook.Sheets.Count - 1 do
      for CellIndex:= 0 to FWorkbook.Sheets[SheetIndex].Cells.Count - 1 do
      begin
        Formula:= FWorkbook.Sheets[SheetIndex].Cells.Item[CellIndex].Formula;
        if (Formula <> '') then
          FFormulaParser.Parse(Formula);
      end;

    for SheetIndex:= 0 to FWorkbook.Sheets.Count - 1 do
      for CVIndex:= 0 to FWorkbook.Sheets[SheetIndex].CellValidations.Count - 1 do
      begin
        CellValidationToDVData(FWorkbook.Sheets[SheetIndex].CellValidations[CVIndex],
          FFormulaParser);
      end;
  end;

  procedure FillSheetIndexesMap;
  var
    SheetIndex, MapIndex, I: Integer;
    S: AnsiString;
  begin
    SheetNamesSorted:= TAnsiStringList.Create;
    try
      for SheetIndex:= 0 to FWorkbook.Sheets.Count - 1 do
      begin
        S:= AnsiString(FWorkbook.Sheets[SheetIndex].Name);
        SheetNamesSorted.Add(S);
      end;
      SheetNamesSorted.Sort;

      for MapIndex:= 0 to SheetNamesSorted.Count - 1 do
      begin
        S:= SheetNamesSorted[MapIndex];
        SheetIndex:= -1;
        { Find sheet by ansi name }
        for I := 0 to FWorkbook.Sheets.Count - 1 do
        begin
          if (S = AnsiString(FWorkbook.Sheets[I].Name)) then
          begin
            SheetIndex:= I;
            break;
          end;
        end;

        if SheetIndex >= 0 then
          SheetIndexesMap.Add(Pointer(SheetIndex));
      end;
    finally
      SheetNamesSorted.Destroy;
    end;
  end;

begin
  { Add sheet names }
  for SheetIndex:= 0 to FWorkbook.Sheets.Count - 1 do
    FLinkTable.LocalDocument.AddSheetName(FWorkbook.Sheets[SheetIndex].Name);

  { Add local sheet indexes }
  FLinkTable.AddLocalSheetIndexes;

  { Add all local names: user-defined and built-in.
    Excel 2003 requires(?) local names to be ordered by sheet name's ascending.
  }
  try
    { Create indexes map ordered by sheet name }
    SheetIndexesMap:= TList.Create;
    FillSheetIndexesMap;

    { Enumerate sheets by name }
    for MapIndex:= 0 to SheetIndexesMap.Count - 1 do
    begin
      SheetIndex:= Integer(SheetIndexesMap[MapIndex]);

      { Add named ranges }
      for RangeIndex:= 0 to FWorkbook.Sheets[SheetIndex].Ranges.RangesCount - 1 do
      begin
        R:= FWorkbook.Sheets[SheetIndex].Ranges[RangeIndex];
        if (R.Name <> '') then
          FLinkTable.LocalDocument.AddName(R.Name, R, binNoName, SheetIndex);
      end;

      { Add print areas }
      if not FWorkbook.Sheets[SheetIndex].PageSetup.PrintArea.Empty then
      begin
        FLinkTable.LocalDocument.AddName('', FWorkbook.Sheets[SheetIndex].PageSetup.PrintArea
          , binPrintArea, SheetIndex);
      end;

      { Add repeatable rows/columns }
      R:= TRange.Create(FWorkbook.Sheets[SheetIndex]);
      try
        if (   (FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageFrom <> -1)
           and (FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageTo <> -1)) then
        begin
          R.AddRect(FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageFrom,
            FWorkbook.Sheets[SheetIndex].PageSetup.PrintRowsOnEachPageTo,
            0, byte(BIFF8_MAXCOLS - 1));
        end;
        if (   (FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageFrom <> -1)
           and (FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageTo <> -1)) then
        begin
          R.AddRect(0, word(BIFF8_MAXROWS - 1),
            FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageFrom,
            FWorkbook.Sheets[SheetIndex].PageSetup.PrintColumnsOnEachPageTo);
        end;
        if not R.Empty then
          FLinkTable.LocalDocument.AddName('', R, binPrintTitles, SheetIndex);
      finally
        R.Destroy;
      end;
    end;  
  finally
    SheetIndexesMap.Destroy;
  end;

  { Add all links from formulas }
  PreParseFormulas;
end;

procedure TXLSWriter.WriteByte(const B: Byte);
begin
  FCurrentStream.WriteByte(B);
  FBytesWrote:= FBytesWrote + 1;
end;

procedure TXLSWriter.WriteWord(const W: Word);
begin
  FCurrentStream.WriteWord(W);
  FBytesWrote:= FBytesWrote + 2;
end;

procedure TXLSWriter.WriteDWord(const D: LongWord);
begin
  FCurrentStream.WriteDWord(D);
  FBytesWrote:= FBytesWrote + 4;
end;

procedure TXLSWriter.WriteBytes(Buff: Pointer; Size: Integer);
begin
  FCurrentStream.WriteBytes(Buff, Size);
  FBytesWrote:= FBytesWrote + Size;  
end;

procedure TXLSWriter.SaveXLSFile;
begin
  WriteWorkbook;
end;

procedure TXLSWriter.AlignWorkbookStream;
var
  WorkbookStreamSize, AlignSize: Integer;
  AlignBuffer: AnsiString;
begin
  {align size to $200 block}
  WorkbookStreamSize:= FWorkbookStream.Size;

  if (WorkbookStreamSize mod $200) <> 0 then
  begin
    AlignSize:= $200 - (WorkbookStreamSize mod $200);
    SetLength(AlignBuffer, AlignSize);
    FillChar(AlignBuffer[1], AlignSize, #0);
    FWorkbookStream.WriteBytes(@AlignBuffer[1], AlignSize);
    SetLength(AlignBuffer, 0);
  end;
end;

procedure TXLSWriter.SaveAs(const AFileName: WideString);
begin
  FBIFF8EncryptionPassword:= '';

  { Protected workbook means encrypting }
  if FWorkbook.IsProtected then
    FBIFF8EncryptionPassword:= BIFF8_BOOKPROTECT_CRYPTPASSWORD;

  SaveAsProtected(AFileName, FBIFF8EncryptionPassword);
end;

procedure TXLSWriter.SaveAsProtected(const AFileName: WideString; const APassword: WideString);
begin
  FBIFF8EncryptionPassword:= APassword;

  FCFile:= TCFile.Create(cfCreateNew, AFileName);
  try
    {create workbook stream in file}
    FWorkbookStream:= FCFile.Root.AddNewStream('Workbook');
    SaveXLSFile;

    {align size to $200 block}
    AlignWorkbookStream;

    { Encrypt }
    if (FBIFF8EncryptionPassword <> '') then
      BIFF8EncryptWorkbookStream;
  finally
    FCFile.Destroy;
  end;
end;

procedure TXLSWriter.SaveToStream(const AStream: TStream);
begin
  SaveToStreamProtected(AStream, '');
end;

procedure TXLSWriter.SaveToStreamProtected(const AStream: TStream; const APassword: WideString);
begin
  FBIFF8EncryptionPassword:= APassword;

  FCFile:= TCFile.Create(cfCreateNewInMemory, '');
  try
    {create workbook stream in file}
    FWorkbookStream:= FCFile.Root.AddNewStream('Workbook');
    SaveXLSFile;

    {align size to $200 block}
    AlignWorkbookStream;

    { Encrypt }
    if (FBIFF8EncryptionPassword <> '') then
      BIFF8EncryptWorkbookStream;

    FCFile.SaveLockBytesToStream(AStream);
  finally
    FCFile.Destroy;
  end;
end;

procedure TXLSWriter.WriteWorkbook;
var
  I: integer;
  CellsCount: Integer;

  procedure CreateSST;
  var
    I, J: Integer;
    Ind: Integer;
    S: AnsiString;
    SI: TList;
    C: TCell;
    ValueType: Integer;
    WS: WideString;
    Options: Byte;
    FormattingRuns: AnsiString;
    FormattingRunsCount: Word;
    CharsCount: Word;
    CharsString: AnsiString;
  begin
    FSST:= THashedStringList.Create(1024 * 4 - 1);
    FSSTIndex:= TList.Create;

    FSSTIndex.Capacity:= FWorkbook.Sheets.Count;
    for I:= 0 to FWorkbook.Sheets.Count-1 do
    begin
      SI:= TList.Create;
      FSSTIndex.Add(SI);
      SI.Capacity:= FWorkbook.Sheets[I].Cells.Count;

      for J:= 0 to FWorkbook.Sheets[I].Cells.Count-1 do
      begin
        C:= FWorkbook.Sheets[I].Cells.Item[J];
        ValueType:= VarType(C.Value);

        if   (ValueType = xfVarString)
          or (ValueType = xfVarUString)
          or (ValueType = xfVarOleStr) then
        begin
          Options:= 0;
          FormattingRuns:='';
          CharsCount:= 0;

          if (ValueType = xfVarString) then
          begin
            CharsString:= AnsiSTring(C.Value);
            CharsString:= StringToSSTString(CharsString);
            if (CharsString[1] = #1) then
            begin
              Options:= 1;
              CharsCount:= (Length(CharsString)-1) div 2;
            end
            else
              CharsCount:= (Length(CharsString)-1);
            CharsString:= Copy(CharsString, 2, Length(CharsString) - 1);
          end
          else
          if (ValueType = xfVarOleStr) or (ValueType = xfVarUString) then
          begin
            Options:= 1;
            WS:= WideString(C.Value);
            CharsCount:= Length(WS);
            CharsString:= WideStringToANSIWideString(WS);
          end;

          S:= AnsiChar( Byte(CharsCount and $FF) )
            + AnsiChar( Byte((CharsCount and $FF00) shr 8) );

          if (C.RichFormat <> '') then
          begin
            Options:= Options or $08;
            FormattingRuns:= RichFormatToRichSSTPart(C.RichFormat, C.FontTableIndex, FWorkbook.FontTable);
            FormattingRunsCount:= Length(FormattingRuns) div 4;
            S:= S
              + AnsiChar(Options)
              + AnsiChar( Byte(FormattingRunsCount and $FF) )
              + AnsiChar( Byte((FormattingRunsCount and $FF00) shr 8) );
          end
          else
            S:= S + AnsiChar(Options);

          S:= S + CharsString;

          if (C.RichFormat <> '') then
            S:= S + FormattingRuns;

          Ind:= FSST.IndexByKey(S);
          if Ind < 0 then begin
            Ind:= FSST.Count;
            FSST.Add(S);
          end;
          SI.Add(Pointer(Ind));
        end
        else
          SI.Add(Pointer(0));
      end;
    end;
  end;

  procedure ClearSST;
  var
    I: integer;
  begin
    if Assigned(FSSTIndex) then begin
      for I:= 0  to FSSTIndex.Count-1 do
        try
          TList(FSSTIndex[I]).Destroy;
        except end;
      FSSTIndex.Destroy;
    end;
    if Assigned(FSST) then FSST.Destroy;
  end;

  procedure CreateMsoData;

    procedure CalcAnchorPointRow(
      const ARow: Integer;
      const ARowOffsetPx: Integer;
      const ASheetIndex: Integer;
      var AnchorRow: Integer;
      var AnchorRowAddition: Integer);
    var
      RowIndex: Integer;
      RowsHeightPx, LastRowHeightPx: Integer;
    begin
      RowsHeightPx:= 0;
      RowIndex:= ARow;

      repeat
        LastRowHeightPx:= FWorkbook.Sheets[ASheetIndex].Rows[RowIndex].VisibleHeightPx;

        RowsHeightPx:= RowsHeightPx + LastRowHeightPx;
        if (RowsHeightPx < ARowOffsetPx) then
        begin
          { If upper limit reached }
          if not IsValidRow(RowIndex + 1) then
          begin
            AnchorRow:= RowIndex;
            AnchorRowAddition:= RowOffsetPxToAddition(LastRowHeightPx, LastRowHeightPx);
            Exit;
          end
          else
            RowIndex:= RowIndex + 1;
        end;
      until (RowsHeightPx >= ARowOffsetPx);

      AnchorRow:= RowIndex;

      if LastRowHeightPx > 0 then
        AnchorRowAddition:= RowOffsetPxToAddition(
            LastRowHeightPx - (RowsHeightPx - ARowOffsetPx)
          , LastRowHeightPx)
      else
        AnchorRowAddition:= 0;
    end;

    procedure CalcAnchorPointColumn(
      const AColumn: Integer;
      const AColumnOffsetPx: Integer;
      const ASheetIndex: Integer;
      var AnchorColumn: Integer;
      var AnchorColumnAddition: Integer);
    var
      ColumnIndex: Integer;
      ColumnsWidthPx, LastColumnWidthPx: Integer;
    begin
      ColumnsWidthPx:= 0;
      ColumnIndex:= AColumn;

      repeat
        LastColumnWidthPx:= FWorkbook.Sheets[ASheetIndex].Columns[ColumnIndex].VisibleWidthPx;

        ColumnsWidthPx:= ColumnsWidthPx + LastColumnWidthPx;
        if (ColumnsWidthPx < AColumnOffsetPx) then
        begin

          { If upper limit reached }
          if not IsValidColumn(ColumnIndex + 1) then
          begin
            AnchorColumn:= ColumnIndex;
            AnchorColumnAddition:= ColumnOffsetPxToAddition(LastColumnWidthPx, LastColumnWidthPx);
            Exit;
          end
          else
            ColumnIndex:= ColumnIndex + 1;
        end;
      until (ColumnsWidthPx >= AColumnOffsetPx);

      AnchorColumn:= ColumnIndex;

      if LastColumnWidthPx > 0 then
        AnchorColumnAddition:= ColumnOffsetPxToAddition(
            LastColumnWidthPx - (ColumnsWidthPx - AColumnOffsetPx)
          , LastColumnWidthPx)
      else
        AnchorColumnAddition:= 0;
    end;

    procedure AddImageData(const AImage: TXLSImage; const ASheetIndex: Integer);
    var
      BLIPID: Integer;
      ColumnFrom         : Integer;
      ColumnFromAddition : Integer;
      RowFrom            : Integer;
      RowFromAddition    : Integer;
      ColumnTo           : Integer;
      ColumnToAddition   : Integer;
      RowTo              : Integer;
      RowToAddition      : Integer;
      WidthPx, HeightPx  : Integer;
      OriginalWidthPx, OriginalHeightPx: Integer;      
      RowFromOffsetPx, ColumnFromOffsetPx: Integer;
    begin
      FMSOData.AddBLIPData(
          WideString(AImage.FileName)
        , AImage.ImageData
        , BLIPID
        , OriginalWidthPx
        , OriginalHeightPx);

      { Find anchor for shape }

      { top left point }
      RowFrom            := AImage.TopRow;
      ColumnFrom         := AImage.LeftColumn;
      RowFromOffsetPx    := AImage.TopRowOffsetPx;
      ColumnFromOffsetPx := AImage.LeftColumnOffsetPx;

      CalcAnchorPointRow(
          AImage.TopRow
        , RowFromOffsetPx
        , ASheetIndex
        , RowFrom
        , RowFromAddition);
      CalcAnchorPointColumn(
          AImage.LeftColumn
        , ColumnFromOffsetPx
        , ASheetIndex
        , ColumnFrom
        , ColumnFromAddition);

      { bottom right point }
      if (    (AImage.BottomRow = -1)
          and (AImage.RightColumn = -1)
         ) then
      begin
        RowTo:= AImage.BottomRow;
        ColumnTo:= AImage.RightColumn;

        HeightPx:= OriginalHeightPx;
        if (AImage.StretchToHeightPx > 0) then
          HeightPx:= AImage.StretchToHeightPx;

        WidthPx:= OriginalWidthPx;
        if (AImage.StretchToWidthPx > 0) then
          WidthPx:= AImage.StretchToWidthPx;

        CalcAnchorPointRow(
            AImage.TopRow
          , HeightPx + RowFromOffsetPx
          , ASheetIndex
          , RowTo
          , RowToAddition);
        CalcAnchorPointColumn(
            AImage.LeftColumn
          , WidthPx + ColumnFromOffsetPx
          , ASheetIndex
          , ColumnTo
          , ColumnToAddition);
      end
      else
      begin
        RowToAddition:= 0;
        RowTo:= AImage.BottomRow + 1;
        ColumnToAddition:= 0;
        ColumnTo:= AImage.RightColumn + 1;
      end;

      { Add new shape }
      FMSOData.AddShapeImage(
          ASheetIndex
        , BLIPID
        , ColumnFrom
        , ColumnFromAddition
        , RowFrom
        , RowFromAddition
        , ColumnTo
        , ColumnToAddition
        , RowTo
        , RowToAddition
        );
    end;

    procedure AddCommentData(const AComment: TCellComment; const ASheetIndex: Integer);
    var
      ColumnFrom         : Integer;
      ColumnFromAddition : Integer;
      RowFrom            : Integer;
      RowFromAddition    : Integer;
      ColumnTo           : Integer;
      ColumnToAddition   : Integer;
      RowTo              : Integer;
      RowToAddition      : Integer;
      WidthPx, HeightPx  : Integer;
      RichFormat: AnsiString;
      RichFormatLastPart: AnsiString;
      L: Word;
      R, C: Integer;
    begin
      R:= AComment.Row;
      C:= AComment.Column;

      if (R = 0) then
        RowFrom := 0
      else if (R + 10 > BIFF8_MAXROWS) then
        RowFrom:= R - 10
      else
        RowFrom:= R - 1;

      if (C + 6 > BIFF8_MAXCOLS) then
        ColumnFrom:= C - 6
      else
        ColumnFrom:= C + 1;

      WidthPx:= AComment.WidthPx;
      HeightPx:= AComment.HeightPx;

      CalcAnchorPointRow(
          RowFrom
        , 10
        , ASheetIndex
        , RowFrom
        , RowFromAddition);
      CalcAnchorPointColumn(
          ColumnFrom
        , 15
        , ASheetIndex
        , ColumnFrom
        , ColumnFromAddition);

      CalcAnchorPointRow(
          RowFrom
        , HeightPx + 10
        , ASheetIndex
        , RowTo
        , RowToAddition);

      CalcAnchorPointColumn(
          ColumnFrom
        , WidthPx + 15
        , ASheetIndex
        , ColumnTo
        , ColumnToAddition);
      
      L:= Length(AComment.Text);

      { Compile rich format }
      RichFormat:= '';
      if (L > 0) then
      begin
        RichFormat:= RichFormatToRichCommentPart
          ( AComment.RichFormat
          , 0
          , FWorkbook.FontTable);

        { Add last format part }  
        RichFormatLastPart:= #0#0#0#0 + #0#0#0#0;
        Move(L, RichFormatLastPart[1], 2);

        if (Length(RichFormat) >= 8) then
          if (Copy(RichFormat, Length(RichFormat) - 7, 8) <> RichFormatLastPart) then
            RichFormat:= RichFormat + RichFormatLastPart;
      end;
      
      { Add new shape }
      FMSOData.AddShapeComment(
          ASheetIndex
        , AComment.Row
        , AComment.Column
        , AComment.Text
        , AComment.Author
        , RichFormat 
        , ColumnFrom
        , ColumnFromAddition
        , RowFrom
        , RowFromAddition
        , ColumnTo
        , ColumnToAddition
        , RowTo
        , RowToAddition);
    end;

  var
    SheetIndex, ImageIndex, CommentIndex: Integer;
  begin
    FMSOData:= TMSOData.Create;

    {Add images to MSO data }
    for SheetIndex:= 0 to FWorkbook.Sheets.Count-1 do
    begin
      for ImageIndex:= 0 to FWorkbook.Sheets[SheetIndex].Images.Count - 1 do
        AddImageData(FWorkbook.Sheets[SheetIndex].Images[ImageIndex], SheetIndex);
    end;

    {Add cell comments to MSO data}
    for SheetIndex:= 0 to FWorkbook.Sheets.Count-1 do
    begin
      for CommentIndex:= 0 to FWorkbook.Sheets[SheetIndex].CellComments.Count - 1 do
        AddCommentData(FWorkbook.Sheets[SheetIndex].CellComments.Item[CommentIndex], SheetIndex);
    end;

    {Prepare MSO data for writing}
    FMSOData.PrepareWriteMSOData;
  end;

  procedure ClearMsoData;
  begin
    if Assigned(FMSOData) then
      FMSOData.Destroy;
  end;

begin
  FProgressRate:= 0;
  DoProgress;

  { Check if the workbook contains sheets }
  if FWorkbook.Sheets.Count = 0 then
    raise EXLSError.Create(EXLS_NOSHEETS);

  FCurrentStream:= FWorkbookStream;
  FBytesWrote:= 0;

  { SST }
  CreateSST;
  FProgressRate:= 5.0 / 100;
  DoProgress;

  { Images list }
  CreateMsoData;
  FProgressRate:= 6.0 / 100;
  DoProgress;

  try
    { Write global }
    WriteGlobal;
    FProgressRate:= 10.0 / 100;
    DoProgress;

    { Find total cells count }
    CellsCount:= 0;
    for I:= 0 to FWorkbook.Sheets.Count - 1 do
      CellsCount:= CellsCount + FWorkbook.Sheets.Item[I].Cells.Count;

    { Find progress for one cell }
    if CellsCount > 0 then
      FProgressForOneCell:= (0.9 - FProgressRate) / CellsCount;

    { Write sheets }
    for I:= 0 to FWorkbook.Sheets.Count - 1 do
      WriteSheet(I);
  finally
    ClearSST;
    ClearMsoData;
  end;

  { Complete progress }
  FProgressRate:= 1;
  DoProgress;
end;

procedure TXLSWriter.WriteGlobal;

  procedure WriteBoundsheet(ASheetInd: integer);
  var
    WS: WideString;
    S: AnsiString;
    Size: Byte;
    Options: Word;
  begin
    { Name }
    WS:= FWorkbook.Sheets[ASheetInd].Name;
    Size:= Length(WS);
    S:= WideStringToANSIWideString(WS);
    S:= AnsiChar(Size) + AnsiChar(1) + S;

    { Options }
    Options:= 0;
    if not FWorkbook.Sheets[ASheetInd].Visible then
      Options:= Options or (1);

    WriteWord(BIFF_BOUNDSHEET);
    WriteWord(6 + Length(S));
    FSheetsOffsets[ASheetInd]:= Pointer(FBytesWrote);
    WriteDWord(0);
    WriteWord(Options);
    WriteBytes(@S[1], Length(S));
  end;

  procedure WriteMSODataGlobal;
  var
    Data: TEasyStream;
    ToSave, BytesWrote, BiffRecSize: Integer;
    BiffRecNum: Word;
  begin
    Data:= TEasyStream.Create;
    try
      FMSOData.WriteMSODataGlobal(Data);
      Data.Position:= 0;

      { save to BIFF records, and split if data too long}
      ToSave:= Data.Size;
      BiffRecNum:= BIFF_MSODRAWINGGROUP;
      BytesWrote:= 0;

      while (ToSave > 0) do
      begin
        { min(BIFF8_MAXRECSIZE, ToSave) }
        if BIFF8_MAXRECSIZE < ToSave then
          BiffRecSize:= BIFF8_MAXRECSIZE
        else
          BiffRecSize:= ToSave;
        ToSave:= ToSave - BiffRecSize;

        WriteWord(BiffRecNum);
        WriteWord(BiffRecSize);
        WriteBytes(PByte(PAnsiChar(Data.Memory) + BytesWrote), BiffRecSize);

        Inc(BytesWrote, BiffRecSize);
        BiffRecNum:= BIFF_CONTINUE;
      end;
    finally
      Data.Destroy;
    end;
  end;

  procedure WriteWorkbookProtection;
  var
    Hash: Word;
  begin
    Hash:= FWorkbook.ProtectPasswordHash;
    if (Hash <> 0) then
    begin
      WriteWord(BIFF_PROTECT);  WriteWord(2); WriteWord(1);
      WriteWord(BIFF_WINDOWPROTECT); WriteWord(2); WriteWord(0);      
      WriteWord(BIFF_PASSWORD); WriteWord(2); WriteWord(Hash);
    end
    else
    begin
      WriteWord(BIFF_WINDOWPROTECT); WriteWord(2); WriteWord(0);
      WriteWord(BIFF_PROTECT);       WriteWord(2); WriteWord(0);
    end;  
  end;

  procedure WriteFilePass;
  var
    DocID: TArray16Byte;
    Salt: TArray64Byte;
    HashedSalt: TArray16Byte;
  begin
    if (FBIFF8EncryptionPassword = '') then Exit;

    BIFF8ProtectPrepareCrypt(FBIFF8EncryptionPassword, DocID, Salt, HashedSalt, FBIFF8EncryptionDigest);

    WriteWord(BIFF_FILEPASS);
    WriteWord(54);

    WriteWord(1);   // BIFF8 encryption
    WriteWord(1);
    WriteWord(1);   // Standard encryption
    WriteBytes(@DocID[0], 16);
    WriteBytes(@Salt[0], 16);
    WriteBytes(@HashedSalt[0], 16);
  end;

  procedure WriteCountry;
  begin
    WriteWord(BIFF_COUNTRY);
    WriteWord(4);
    WriteWord(1); WriteWord(1);
  end;

  procedure WritePalette;
  var
    W, PaletteLength: Word;
    ColorIndex: TXLColorIndex;
  begin
    PaletteLength:= High(TXLColorIndex) - 2;
    WriteWord(BIFF_PALETTE);
    W:= PaletteLength * 4 + 2;
    WriteWord(W);
    WriteWord(PaletteLength);
    for ColorIndex:= 1 to High(TXLColorIndex) - 2 do
      WriteDWord(XLSColorIndexToColorMap[ColorIndex]);
  end;

var
  I: integer;
begin
  {BOF}
  WriteWord(BIFF_BOF or (BIFF_VER578 shl 8));
  WriteWord(16);
  WriteWord(BIFF8_VERNMB);
  WriteWord(BIFF_STYPE_GLOBALS);
  {some version stuff}
  WriteWord($1846); {Excel build id}
  WriteWord($07CD); {Excel build year}
  WriteWord($40C1);
  WriteWord($0000);
  WriteWord($0106);
  WriteWord($0000);

  { File protection }
  WriteFilePass;

  {some interface}
  WriteWord(BIFF_INTERFACEHDR); WriteWord(2); WriteWord($04b0);
  WriteWord(BIFF_MMS);          WriteWord(0);
  WriteWord(BIFF_INTERFACEEND); WriteWord(0);

  {if Excel 2000}
  WriteWord(BIFF_XL2000); WriteWord(0);

  {DSF}
  WriteWord(BIFF_DSF); WriteWord(2); WriteWord(0);

  {Tabid}
  WriteWord(BIFF_TABID);
  WriteWord(2 * FWorkbook.Sheets.Count);
  for I:= 0 to FWorkbook.Sheets.Count-1 do WriteWord(I);

  { Protection }
  WriteWorkbookProtection;

  {Window1}
  WriteWord(BIFF_WINDOW1);
  WriteWord(SizeOf(BIFF_WINDOW1_DATA));
  WriteBytes(@BIFF_WINDOW1_DATA[0], SizeOf(BIFF_WINDOW1_DATA));

  WriteWord(BIFF_HIDEOBJ);       WriteWord(2); WriteWord(0);

  {We use 1900 date/time system}
  WriteWord(BIFF_1904);          WriteWord(2); WriteWord(0);

  {Formats}
  WriteFontTable;
  WriteFormatTable;
  WriteXFTable;
  WriteStyleTable;

  {Palette}
  WritePalette;  
  
  {Boundsheets}
  for I:= 0 to FWorkbook.Sheets.Count - 1 do
  begin
    FSheetsOffsets.Add(nil);
    WriteBoundsheet(I);
  end;

  { Country record. Required for F1Book component, but not for Excel, OpenOffice.}
  WriteCountry;

  { Link table }
  WriteLinkTable;

  {MSO data}
  WriteMSODataGlobal;

  {BIFF_UNKNOWN_1C1}
  {required to suppress a message "Excel recalculates formulas etc."}
  WriteWord(BIFF_UNKNOWN_1C1);
  WriteWord(SizeOf(BIFF_1C1_DATA));
  WriteBytes(@BIFF_1C1_DATA[0], SizeOf(BIFF_1C1_DATA));

  {SST}
  WriteSST;

  {EOF}
  WriteWord(BIFF_EOF); WriteWord(0);
end;

procedure TXLSWriter.WriteSheet(ASheetInd: integer);
var
  I: Integer;
  CurrentPosition, NewPosition: Integer;

  procedure WritePageBreaks;
  var
    I: Integer;
  begin
    {horizontal breaks}
    WriteWord(BIFF_HORIZONTALPAGEBREAKS);
    WriteWord(2 + 6 * FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount);
    WriteWord(FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount);
    for I:= 0 to FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount - 1 do
    begin
      WriteWord(FWorkbook.Sheets[ASheetInd].PageBreaks.Item[I].Row);
      WriteWord(0);
      WriteWord($FF);
    end;

    {vertical breaks}
    WriteWord(BIFF_VERTICALPAGEBREAKS);
    WriteWord(2 + 6 * FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount);
    WriteWord(FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount);
    for I:= 0 to FWorkbook.Sheets[ASheetInd].PageBreaks.ItemsCount - 1 do
    begin
      WriteWord(FWorkbook.Sheets[ASheetInd].PageBreaks.Item[I].Column);
      WriteWord(0);
      WriteWord($FFFF);
    end;
  end;

  procedure WritePanes;
  var
    Freeze: Boolean;
    ActivePane: Word;
  begin
    Freeze:= (   (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Row > 0)
             or (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Column > 0)
            );

    if Freeze then
    begin
      WriteWord(BIFF_PANE);
      WriteWord(10);
      WriteWord(FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Column);
      WriteWord(FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Row);
      WriteWord(FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Row);
      WriteWord(FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Column);

      if (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Column = 0) then
        ActivePane:= 2
      else if (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Row = 0) then
        ActivePane:= 1
      else
        ActivePane:= 0;

      WriteWord(ActivePane);
    end;        
  end;

  procedure WriteWindowOptions;
  var
    W: Word;
    Freeze: Boolean;
  begin
    Freeze:= (   (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Row > 0)
             or (FWorkbook.Sheets[ASheetInd].WindowOptions.FreezePoint.Column > 0)
            );

    WriteWord(BIFF_WINDOW2);
    WriteWord(18);
    W:= 0;

    if Freeze then
      W:= $08           {the panes in the window should be frozen}
          or (1 shl 8); {the panes in the window are frozen but there is no split}

    W:= W
     or (Byte(FWorkbook.Sheets[ASheetInd].WindowOptions.DisplayGrids) shl 1)
     or (Byte(FWorkbook.Sheets[ASheetInd].WindowOptions.DisplayRowColHeaders) shl 2)
     or (Byte(FWorkbook.Sheets[ASheetInd].WindowOptions.DisplayZero) shl 4)
     or (Byte(FWorkbook.Sheets[ASheetInd].WindowOptions.DisplayRightToLeft) shl 6)
     or $20
     or ($04 shl 8)  {the sheet is currently being displayed in the workbook window}
     or (Word(FWorkbook.Sheets[ASheetInd].WindowOptions.PageBreakPreview) shl 11)
     or $80;         {set option "Outline symbols visible"}

    {first sheet selected}
    if (ASheetInd = 0) then W:= W or ($02 shl 8);
    
    WriteWord(W);
    WriteWord(0); WriteWord(0); WriteDWord(0);
    WriteWord(0); WriteWord(0); WriteDWord(0);

    {write Zoom}
    if (FWorkbook.Sheets[ASheetInd].WindowOptions.ZoomPercent <> 100) then
    begin
      WriteWord(BIFF_SCL);
      WriteWord(4);
      WriteWord(FWorkbook.Sheets[ASheetInd].WindowOptions.ZoomPercent);
      WriteWord(100);
    end;
  end;
  
  procedure WritePageSetup;
  var
    Opt, W, L: Word;
    B: Byte;
    D: Double;
    S: AnsiString;
    WS: WideString;
    I: Integer;
    MaxRowsOutlineLevel: Byte;
    MaxColumnsOutlineLevel: Byte;
    PageSetup: TPageSetup;
  begin
    PageSetup:= FWorkbook.Sheets[ASheetInd].PageSetup;

    WriteWord(BIFF_SETUP);
    WriteWord($22);

    {paper size}
    WriteWord(Word(PageSetup.PaperSize));

    {scale}
    WriteWord(PageSetup.Scale);

    {starting page number}
    WriteWord(PageSetup.StartPageNum);

    {fit to page number}
    if PageSetup.Zoom then
    begin
      WriteWord(1);
      WriteWord(1);
    end
    else
    begin
      WriteWord(PageSetup.FitPagesWidth);
      WriteWord(PageSetup.FitPagesHeight);
    end;

    {options}
    Opt:= 0;
    if PageSetup.PrintPagesOrder = xlOverDown then
      Opt:= Opt or $01;
    if PageSetup.Orientation = xlPortrait then
      Opt:= Opt or ($01 shl 1);
    //Opt:= Opt or ($01 shl 2);
    if PageSetup.BlackAndWhite then
      Opt:= Opt or ($01 shl 3);
    if PageSetup.Draft then
      Opt:= Opt or ($01 shl 4);
    if PageSetup.StartPageNum <> xlAutomatic then
      Opt:= Opt or ($01 shl 7);
    WriteWord(Opt);

    {print resolution}
    WriteWord(0);
    {vertical print resolution}
    WriteWord(0);

    {header margin in inched}
    D:= PageSetup.HeaderMargin;
    WriteBytes(PByte(@D), 8);
    {footer margin in inches}
    D:= PageSetup.FooterMargin;
    WriteBytes(PByte(@D), 8);

    {number of copies}
    WriteWord(0);

    {fit to pages flag}
    WriteWord(BIFF_WSBOOL);
    WriteWord(2);
    W:= 0;
    if not PageSetup.RowGroupAtTop then
      W:= W or $40;
    if not PageSetup.ColumnGroupAtLeft then
      W:= W or $80;

    if PageSetup.Zoom then
      W:= W or $400
    else
      W:= W or $500;

    WriteWord(W);

    {print row/col headers}
    WriteWord(BIFF_PRINTHEADERS);
    WriteWord(2);
    if PageSetup.PrintRowColLabels then
      WriteWord(1)
    else
      WriteWord(0);

    {print gridlines}
    WriteWord(BIFF_PRINTGRIDLINES);
    WriteWord(2);
    if PageSetup.PrintGrid then
      WriteWord(1)
    else
      WriteWord(0);

    {find max outline level for rows}
    MaxRowsOutlineLevel:= 0;
    for I:= 0 to FWorkbook.Sheets[ASheetInd].Rows.Count - 1 do
      if FWorkbook.Sheets[ASheetInd].Rows.Item[I].OutlineLevel > MaxRowsOutlineLevel then
        MaxRowsOutlineLevel:= FWorkbook.Sheets[ASheetInd].Rows.Item[I].OutlineLevel;
    {find max outline level for columns}
    MaxColumnsOutlineLevel:= 0;
    for I:= 0 to FWorkbook.Sheets[ASheetInd].Columns.Count - 1 do
      if FWorkbook.Sheets[ASheetInd].Columns.Item[I].OutlineLevel > MaxColumnsOutlineLevel then
        MaxColumnsOutlineLevel:= FWorkbook.Sheets[ASheetInd].Columns.Item[I].OutlineLevel;
    {write gutters info}
    WriteWord(BIFF_GUTS);
    WriteWord(8);
    WriteWord(MaxRowsOutlineLevel * $1d);
    WriteWord(MaxColumnsOutlineLevel * $1d);
    if MaxRowsOutlineLevel > 0 then
      WriteWord(MaxRowsOutlineLevel + 1)
    else
      WriteWord(0);
    if MaxColumnsOutlineLevel > 0 then
      WriteWord(MaxColumnsOutlineLevel + 1)
    else
      WriteWord(0);

    {top margin in inches}
    WriteWord(BIFF_TOPMARGIN);
    WriteWord(8);
    D:= PageSetup.TopMargin;
    WriteBytes(PByte(@D), 8);
    {bottom margin in inches}
    WriteWord(BIFF_BOTTOMMARGIN);
    WriteWord(8);
    D:= PageSetup.BottomMargin;
    WriteBytes(PByte(@D), 8);
    {Left margin in inches}
    WriteWord(BIFF_LEFTMARGIN);
    WriteWord(8);
    D:= PageSetup.LeftMargin;
    WriteBytes(PByte(@D), 8);
    {Right margin in inches}
    WriteWord(BIFF_RIGHTMARGIN);
    WriteWord(8);
    D:= PageSetup.RightMargin;
    WriteBytes(PByte(@D), 8);

    {center horizontally}
    WriteWord(BIFF_HCENTER);
    WriteWord(2);
    if PageSetup.CenterHorizontally then
      WriteWord(1)
    else
      WriteWord(0);
    {center vertically}
    WriteWord(BIFF_VCENTER);
    WriteWord(2);
    if PageSetup.CenterVertically then
      WriteWord(1)
    else
      WriteWord(0);

    {header text}
    WS:= '';
    if PageSetup.HeaderTextLeft <> ''  then WS:= WS + '&L' + PageSetup.HeaderTextLeft;
    if PageSetup.HeaderText <> ''      then WS:= WS + '&C' + PageSetup.HeaderText;
    if PageSetup.HeaderTextRight <> '' then WS:= WS + '&R' + PageSetup.HeaderTextRight;
    if (WS <> '') then
    begin
      L:= Length(WS);
      S:= WideStringToANSIWideString(WS);
      W:= Length(S) + 3;
      WriteWord(BIFF_HEADER);
      WriteWord(W);
      WriteWord(L);
      B:= 1;
      WriteBytes(@B, 1);
      WriteBytes(@S[1], Length(S));
    end;

    {footer text}
    WS:= '';
    if PageSetup.FooterTextLeft <> ''  then WS:= WS + '&L' + PageSetup.FooterTextLeft;
    if PageSetup.FooterText <> ''      then WS:= WS + '&C' + PageSetup.FooterText;
    if PageSetup.FooterTextRight <> '' then WS:= WS + '&R' + PageSetup.FooterTextRight;
    if (WS <> '') then
    begin
      L:= Length(WS);
      S:= WideStringToANSIWideString(WS);
      W:= Length(S) + 3;
      WriteWord(BIFF_FOOTER);
      WriteWord(W);
      WriteWord(L);
      B:= 1;
      WriteBytes(@B, 1);
      WriteBytes(@S[1], Length(S));
    end;
  end;

  procedure WriteMergedCells;
  var
    Count, RI, I: Integer;
    CountToWrite, TotalCountWrote, CountWrote: Integer;
  begin
    {count merged areas}
    Count:= 0;
    for RI:= 0 to FWorkbook.Sheets[ASheetInd].Ranges.RangesCount-1 do
      if FWorkbook.Sheets[ASheetInd].Ranges[RI].Merged then
        Count:= Count + FWorkbook.Sheets[ASheetInd].Ranges[RI].RectsCount;
    if Count = 0 then
      Exit;

    TotalCountWrote:= 0;
    CountWrote:= 0;
    {min(Count, $400)}
    if Count < $400 then
      CountToWrite:= Count
    else
      CountToWrite:= $400;

    WriteWord(BIFF_MERGECELLS);
    WriteWord(2 + CountToWrite * 8);
    WriteWord(CountToWrite);

    for RI:= 0 to FWorkbook.Sheets[ASheetInd].Ranges.RangesCount-1 do
      with FWorkbook.Sheets[ASheetInd].Ranges[RI] do
      begin
        if Merged then
        begin
          for I:= 0 to RectsCount - 1 do
          begin
            if CountWrote = CountToWrite then
            begin
              TotalCountWrote:= TotalCountWrote + CountWrote;
              CountWrote:= 0;

              { min(Count - TotalCountWrote, $400) }
              if (Count - TotalCountWrote) < $400 then
                CountToWrite:= Count - TotalCountWrote
              else
                CountToWrite:= $400;
                
              WriteWord(BIFF_MERGECELLS);
              WriteWord(CountToWrite * 8 + 2);
              WriteWord(CountToWrite);
            end;

            WriteWord(Rect[I].RowFrom);
            WriteWord(Rect[I].RowTo);
            WriteWord(Rect[I].ColumnFrom);
            WriteWord(Rect[I].ColumnTo);

            CountWrote:= CountWrote + 1;
          end;
        end;
      end;
  end;

  procedure WriteColinfo;
  var
    I: integer;
    B: Byte;
    Columns: TColumns;
    Column: TColumn;
    Options: Word;
    XFIndex: Integer;
  begin
    Columns:= FWorkbook.Sheets[ASheetInd].Columns;

    for I:= 0 to Columns.Count - 1 do
    begin
      Column:= Columns.Item[I];
      XFIndex:= Column.XFTableIndex + FDefaultXFCount;
      WriteWord(BIFF_COLINFO);
      WriteWord(11);
      WriteWord(Column.Index);
      WriteWord(Column.Index);
      WriteWord(XLSWidthToStoredWidth(Column.Width));
      WriteWord(XFIndex);
      { Options }
      Options:= (Column.OutlineLevel and $07) shl 8;
      if Column.Hidden then
        Options:= Options or 1;
      WriteWord(Options);
      B:= 0;
      WriteBytes(@B, 1);
    end;
  end;

  procedure WriteDimensionsInfo;
  var
    UsedRect: TRangeRect;
  begin
    if FWorkbook.Sheets[ASheetInd].GetUsedRect(UsedRect) then
    begin
      WriteWord(BIFF_DIMENSIONS);
      WriteWord(14);
      WriteDWord(UsedRect.RowFrom);
      WriteDWord(UsedRect.RowTo + 1);   // +1 - strange but documented feature
      WriteWord(UsedRect.ColumnFrom);
      WriteWord(UsedRect.ColumnTo + 1);
      WriteWord(0);
    end;
  end;

  procedure WriteRowinfo;
  var
    I: integer;
    Rows: TRows;
    Row: TRow;
    Options: Word;
    XFIndex: Integer;
  begin
    WriteWord(BIFF_DEFAULTROWHEIGHT);
    WriteWord(4);
    WriteWord(0);
    WriteWord($ff);

    {write row info}
    Rows:= FWorkbook.Sheets[ASheetInd].Rows;
    for I:= 0 to Rows.Count - 1 do
    begin
      Row:= Rows.Item[I];

      WriteWord(BIFF_ROW);
      WriteWord(16);
      WriteWord(Row.Index);
      WriteWord(0);
      WriteWord(0);
      {row height}
      WriteWord(round(Row.Height * xlRowHeightMult));
      WriteWord(0);
      WriteWord(0);
      {options}
      Options:= 0;
      if Row.SizeChanged then
        Options:= Options or (1 shl 6);   // 0 - AutoFit row
      Options:= Options
                or (1 shl 7)
                or (1 shl 8)
                or (Row.OutlineLevel and $07);
      if Row.Hidden then
        Options:= Options or $20;
      WriteWord(Options);
      {XF index}
      XFIndex:= Row.XFTableIndex + FDefaultXFCount;
      WriteWord(XFIndex);
    end;
  end;

  procedure WriteMSODataSheet;
  var
    Data: TEasyStream;
  begin
    Data:= TEasyStream.Create;
    try
      FMSOData.WriteMSODataSheet(Data, ASheetInd);
      Data.Position:= 0;
      if (Data.Size > 0) then
        WriteBytes(PByte(Data.Memory), Data.Size);
    finally
      Data.Destroy;
    end;
  end;

  procedure WriteHyperlinks;
  var
    I: Integer;
    WSHyperlink: WideString;
    HyperlinkType: TCellHyperlinkType;
    S: AnsiString;
  begin
    for I:= 0 to FWorkbook.Sheets[ASheetInd].Cells.Count-1 do
    begin
      WSHyperlink:= FWorkbook.Sheets[ASheetInd].Cells.Item[I].Hyperlink;
      if (WSHyperlink <> '') then
      begin
        HyperlinkType:= FWorkbook.Sheets[ASheetInd].Cells.Item[I].HyperlinkType;

        S:= CompileCellHyperlink(WSHyperlink, HyperlinkType);

        if (S <> '') then
        begin
          WriteWord(BIFF_HLINK);
          WriteWord(8 + Length(S));
          WriteWord(FWorkbook.Sheets[ASheetInd].Cells.Item[I].Row);
          WriteWord(FWorkbook.Sheets[ASheetInd].Cells.Item[I].Row);
          WriteWord(FWorkbook.Sheets[ASheetInd].Cells.Item[I].Col);
          WriteWord(FWorkbook.Sheets[ASheetInd].Cells.Item[I].Col);
          WriteBytes(@S[1], Length(S));
        end;  
      end;
    end;  
  end;

  procedure WriteSheetProtection;
  var
    Hash, Mode: Word;
  begin
    Hash:= FWorkbook.Sheets[ASheetInd].ProtectPasswordHash;
    Mode:= FWorkbook.Sheets[ASheetInd].ProtectMode;
    if (Hash <> 0) then
    begin
      WriteWord(BIFF_PROTECT);
      WriteWord(2);
      WriteWord(1);

      WriteWord(BIFF_SCENPROTECT);
      WriteWord(2);
      WriteWord(1);

      WriteWord(BIFF_OBJPROTECT);
      WriteWord(2);
      WriteWord(1);

      WriteWord(BIFF_PASSWORD);
      WriteWord(2);
      WriteWord(Hash);

      WriteWord(BIFF_SHEETPROTECTION);
      WriteWord(23);
      WriteWord($867); WriteWord(0); // 67 08 00 00
      WriteDWord(0); // 00 00 00 00
      WriteDWord(0); // 00 00 00 00
      WriteWord(2); WriteByte(1); // 02 00 01
      WriteWord($FFFF); WriteWord($FFFF);
      WriteWord(Mode);
      WriteWord(0);
    end;
  end;

  procedure WriteCellValidations;
  var
    S: AnsiString;
    D: LongWord;
    I: Integer;
  begin
    D:= FWorkbook.Sheets[ASheetInd].CellValidations.Count;
    if (D > 0) then
    begin
      WriteWord(BIFF_DVAL);
      WriteWord(18);
      WriteWord(4);
      WriteDword(0);
      WriteDword(0);
      WriteDWord(Longword($ffffffff));
      WriteDword(D);

      for I:= 0 to D - 1 do
      begin
        S:= CellValidationToDVData(
              FWorkbook.Sheets[ASheetInd].CellValidations[I], FFormulaParser);
        WriteWord(BIFF_DV);
        WriteWord(Length(S));
        WriteBytes(@S[1], Length(S));      
      end;
    end;
  end;

begin
  {change boundsheet for this sheet}
  CurrentPosition:= FCurrentStream.Position;
  NewPosition:= Longint(FSheetsOffsets[ASheetInd]);
  FCurrentStream.Position:= NewPosition;
  FCurrentStream.WriteDWord(FBytesWrote);
  FCurrentStream.Position:= CurrentPosition;

  {BOF}
  WriteWord(BIFF_BOF or (BIFF_VER578 shl 8));
  WriteWord(16);
  WriteWord(BIFF8_VERNMB);
  WriteWord(BIFF_STYPE_SHEET);
  {some version stuff}
  WriteWord($1846); {Excel build id}
  WriteWord($07CD); {Excel build year}
  WriteWord($40C1);
  WriteWord($0000);
  WriteWord($0106);
  WriteWord($0000);

  {index record}
  { Excel works without this record.
    But OLE DB/ODBC need it when working with file as with database table }
  WriteWord(BIFF_INDEX);
  WriteWord(16);
  WriteDWord(0);
  WriteDWord(0);     {first sheet row}
  WriteDWord($ffff); {last sheet row}
  WriteDWord(0);

  {page breaks}
  WritePageBreaks;

  {page setup}
  WritePageSetup;

  {sheet protection}
  WriteSheetProtection;

  {colinfo}
  WriteColinfo;

  {dimensions info}
  WriteDimensionsInfo;

  {rowinfo}
  WriteRowinfo;

  {cells}
  for I:= 0 to FWorkbook.Sheets[ASheetInd].Cells.Count-1 do
  begin
    WriteCell(ASheetInd, I);

    FProgressRate:= FProgressRate + FProgressForOneCell;
    DoProgress;    
  end;

  {MSO data}
  WriteMSODataSheet;

  {Window options}
  WriteWindowOptions;

  {Freeze panes}
  WritePanes;
  
  {Merged cells}
  WriteMergedCells;

  {Hyperlinks}
  WriteHyperlinks;

  { Cell validations }
  WriteCellValidations;

  {EOF}
  WriteWord(BIFF_EOF);
  WriteWord(0);
end;

procedure TXLSWriter.WriteCell(ASheetInd, ACellInd: integer);
var
  XFIndex: Word;
  SSTIndex: Integer;
  Cell: TCell;
  RecCommonHeader: array[1..5] of Word;

  function DateToXLSNumber(const D: TDateTime): Double;
  {  An Excel file can use one of two different date/time systems.
     In these systems, a floating point number represents the number of days
     (and fractional parts of the day) since a start point.
     The two systems ('1900' and '1904') use different starting points:
     system '1900' - '1.00' is 1 Jan 1900 BUT 1900 is incorrectly regarded as
              a leap year - see: http://support.microsoft.com/support/kb/articles/Q181/3/70.asp
     system '1904' - '1.00' is 2 Jan 1904.

     The '1904' system is the default for Apple Macs. Windows versions of
     Excel have the option to use the '1904' system.   }
  var
    StartD, MagicD: TDateTime;
  begin
    {We use '1900' date/time system}
    MagicD:= EncodeDate(1900, 3, 1);
    StartD:= EncodeDate(1900, 1, 1);
    if D < MagicD then
      Result:= D - StartD + 1
    else
      Result:= D - StartD + 2;
  end;
  
  procedure WriteFormula(const Formula: AnsiString;
    const Val: Variant;
    const Row, Col: word;
    const XF: word);
  var
    ParsedFormula: AnsiString;
    Sz: Word;
    WriteNextString: Boolean;
    LastValue: array[1..8] of Byte;
    D: Double;
    WS: WideString;
    S: AnsiString;
  begin
    ParsedFormula:= FFormulaParser.Parse(Formula);

    Sz:=
      2 + // row
      2 + // col
      2 + // XF index
      8 + // last saved value
      2 + // options
      4 + // magic
      2 + // parsed formula size
      Length(ParsedFormula);

    RecCommonHeader[1]:= BIFF_FORMULA;
    RecCommonHeader[2]:= Sz;
    RecCommonHeader[3]:= Row;
    RecCommonHeader[4]:= Col;
    RecCommonHeader[5]:= XF;
    WriteBytes(@RecCommonHeader[1], 10);

    // last saved value
    WriteNextString:= False;
    FillChar(LastValue[1], 8, 0);

    if   VarIsEmpty(Val)
      or VarIsNull(Val) then
    begin
      LastValue[1]:= 3;
      LastValue[7]:= $FF;
      LastValue[8]:= $FF;
    end
    else
    begin
      case VarType(Val) of
        xfVarSmallint,
        xfVarInteger,
        xfVarSingle,
        xfVarDouble,
        xfVarCurrency,
        xfVarDecimal,
        xfVarShortInt,
        xfVarByte,
        xfVarWord,
        xfVarLongWord,
        xfVarInt64,
        xfVarWord64:
          begin
            D:= Val;
            Move(D, LastValue[1], 8);
          end;

        xfVarDate:
          begin
            D:= DateToXLSNumber(TDateTime(Val));
            Move(D, LastValue[1], 8);
          end;

        xfVarBoolean:
          begin
            LastValue[1]:= 1;
            if Val = True then LastValue[3]:= 1 else LastValue[3]:= 0;
            LastValue[7]:= $FF;
            LastValue[8]:= $FF;
          end;

        xfVarString,
        xfVarUString,
        xfVarOleStr:
          begin
            if Val = '' then
            begin
              LastValue[1]:= 3;
              LastValue[7]:= $FF;
              LastValue[8]:= $FF;
            end
            else
            begin
              WriteNextString:= True;
              LastValue[1]:= 0;
              LastValue[7]:= $FF;
              LastValue[8]:= $FF;
            end;
          end;
      end;
    end;
    WriteBytes(@LastValue[1], 8);

    // options: set 02 - calculate on load
    WriteWord(2);
    // magic
    WriteDWord(0);
    // parsed formula size
    WriteWord(Length(ParsedFormula));
    // parsed formula
    if Length(ParsedFormula) > 0 then
      WriteBytes(@ParsedFormula[1], Length(ParsedFormula));

    // write string value
    if WriteNextString then
    begin
      case VarType(Val) of
        xfVarString:
          begin
            S:= AnsiString(Val);
            WS:= StringToWideString(S);
          end;
        xfVarOleStr,
        xfVarUString:
          WS:= WideString(Val);
      end;

      S:= WideStringToANSIWideString(WS);
      Sz:= Length(WS);
      if Sz > 0 then
      begin
        WriteWord(BIFF_STRING);
        WriteWord(3 + Length(S));
        WriteWord(Sz);
        WriteByte(1); // Unicode
        WriteBytes(@S[1], Length(S));
      end;
    end;
  end;

  procedure WriteNumber(Val: Variant; Row, Col: word; XF: word);
  var
    VFloat: Double;
    procedure WriteAsNumber;
    begin
      RecCommonHeader[1]:= BIFF_NUMBER;
      RecCommonHeader[2]:= 14;
      RecCommonHeader[3]:= Row;
      RecCommonHeader[4]:= Col;
      RecCommonHeader[5]:= XF;
      WriteBytes(@RecCommonHeader[1], 10);
      WriteBytes(PByte(@VFloat), sizeof(VFloat));
    end;
  begin
    VFloat:= Double(Val);
    {  Use NUMBER (8 bytes) instead of RK (4 bytes).
       It is not always optimal but it always works.  }
    WriteAsNumber;
  end;

  procedure WriteDate(Val: Variant; Row, Col: word; XF: word);
  var
    D: TDateTime;
  begin
    D:= TDateTime(Val);
    WriteNumber(DateToXLSNumber(D), Row, Col, XF);
  end;

begin
  Cell:= FWorkbook.Sheets[ASheetInd].Cells.Item[ACellInd];
  XFIndex:= Cell.XFTableIndex + FDefaultXFCount;

  if Cell.Formula <> '' then
  begin
    WriteFormula(Cell.Formula, Cell.Value, Cell.Row, Cell.Col, XFIndex);
  end
  else
  begin
    case VarType(Cell.Value) of
      xfVarString,
      xfVarUString,
      xfVarOleStr:
        begin
          SSTIndex:= Integer(TList(FSSTIndex[ASheetInd]).Items[ACellInd]);
          RecCommonHeader[1]:= BIFF_LABELSST;
          RecCommonHeader[2]:= 10;
          RecCommonHeader[3]:= Cell.Row;
          RecCommonHeader[4]:= Cell.Col;
          RecCommonHeader[5]:= XFIndex;
          WriteBytes(@RecCommonHeader[1], 10);
          WriteDWord(SSTIndex);
        end;
      xfVarEmpty:
        begin
          RecCommonHeader[1]:= BIFF_BLANK;
          RecCommonHeader[2]:= 6;
          RecCommonHeader[3]:= Cell.Row;
          RecCommonHeader[4]:= Cell.Col;
          RecCommonHeader[5]:= XFIndex;
          WriteBytes(@RecCommonHeader[1], 10);
        end;
      xfVarInteger,
      xfVarSmallint,
      xfVarByte,
      xfVarShortInt,
      xfVarWord,
      xfVarLongWord,
      xfVarInt64,
      xfVarSingle,
      xfVarDouble,
      xfVarDecimal,
      xfVarCurrency:
        begin
          WriteNumber(Cell.Value, Cell.Row, Cell.Col, XFIndex);
        end;
      xfVarDate:
        begin
          WriteDate(Cell.Value, Cell.Row, Cell.Col, XFIndex);
        end;
      xfVarBoolean:
        begin
          RecCommonHeader[1]:= BIFF_BOOLERR;
          RecCommonHeader[2]:= 8;
          RecCommonHeader[3]:= Cell.Row;
          RecCommonHeader[4]:= Cell.Col;
          RecCommonHeader[5]:= XFIndex;
          WriteBytes(@RecCommonHeader[1], 10);
          if Cell.Value = True then
            WriteWord(1)
          else
            WriteWord(0);
        end;
    end;
  end;
end;

procedure TXLSWriter.WriteSST;
var
  CurrentPosition, StartPosition: Integer;
  I, Size, RecBytesWrote : integer;
  Options: Byte;
  OptionsUnicode: Byte;
  S: AnsiString;

  procedure CorrectSize;
  begin
    CurrentPosition:= FCurrentStream.Position;
    FCurrentStream.Position:= StartPosition;
    FCurrentStream.WriteWord(RecBytesWrote);
    FCurrentStream.Position:= CurrentPosition;
  end;

  procedure WriteString;
  var
    ToWrite, ToWriteInThisRecord: integer;
    BytesRead: integer;
    StrBytesWrote: integer;
  begin
    ToWrite:= Size;
    BytesRead:= 0;
    StrBytesWrote:= 0;
    while ToWrite > 0 do begin
      if (BIFF8_MAXRECSIZE - RecBytesWrote) < 4 then begin
        CorrectSize;

        WriteWord(BIFF_CONTINUE);
        StartPosition:= FBytesWrote;
        WriteWord(0);

        if StrBytesWrote > 0 then begin
          WriteBytes(@OptionsUnicode, 1);
          RecBytesWrote:= 1;
        end
        else
          RecBytesWrote:= 0;
      end;

      if (BIFF8_MAXRECSIZE - RecBytesWrote < ToWrite) then
        ToWriteInThisRecord:= BIFF8_MAXRECSIZE - RecBytesWrote
      else
        ToWriteInThisRecord:= ToWrite;

      if (OptionsUnicode <> 0) and not Odd(ToWriteInThisRecord + StrBytesWrote) then
        ToWriteInThisRecord:= ToWriteInThisRecord -1;

      WriteBytes(@S[BytesRead + 1], ToWriteInThisRecord);
      Inc(StrBytesWrote, ToWriteInThisRecord);
      Inc(RecBytesWrote, ToWriteInThisRecord);
      Inc(BytesRead, ToWriteInThisRecord);
      Dec(ToWrite, ToWriteInThisRecord);
    end;
  end;

begin
  WriteWord(BIFF_SST);
  StartPosition:= FBytesWrote;
  WriteWord(0);
  WriteDWord(FSST.Count);
  WriteDWord(FSST.Count);
  RecBytesWrote:= 8;

  for I:= 0 to FSST.Count - 1 do
  begin
    S:= FSST[I];
    Options:= Byte(S[3]);
    OptionsUnicode:= Options and $01;
    Size:= Length(S);

    WriteString;
  end;

  CorrectSize;

  WriteWord(BIFF_EXTSST);
  WriteWord(2);
  WriteWord(0);
end;

procedure TXLSWriter.WriteFontTable;
var
  I, Size: integer;
  FontData: PFontData;
  FontString: AnsiString;
begin
  for I:= 0 to FWorkbook.FontTable.Count - 1 do
  begin
    FontData:= FWorkbook.FontTable.Font[I];
    FontString:= GetFontStringFromFontData(FontData);

    WriteWord(BIFF_FONT);
    Size:= Length(FontString);
    WriteWord(Size);
    WriteBytes(@FontString[1], Size);
  end;
end;

procedure TXLSWriter.WriteFormatTable;
var
  I, Size: Integer;
  S: AnsiString;
  WS: WideString;
begin
  { Do not save built-in formats - Excel knows them,
     and can display values formatted with built-in formats
     using curent system Locale. Great!
     Save only custom formats.
   }
  for I:= xlBuiltinFormatsCount to FWorkbook.FormatStrings.FormatsCount - 1 do
  begin
    SetLength(S, 5);
    PWORD(@S[1])^:= FWorkbook.FormatStrings.Formats[I].ifmt;
    PWORD(@S[3])^:= Length(FWorkbook.FormatStrings.Formats[I].FormatString);
    PByte(@S[5])^:= 1;
    WS:= FWorkbook.FormatStrings.Formats[I].FormatString;
    S:= S + WideStringToANSIWideString(WS);

    WriteWord(BIFF_FORMAT);
    Size:= Length(S);
    WriteWord(Size);
    WriteBytes(@(S[1]), Size);
  end;
end;

procedure TXLSWriter.WriteXFTable;
var
  I: Integer;
  XFData: PXFData;
  XFString: AnsiString;

  procedure WriteXFString;
  var
    Size: Integer;
  begin
    WriteWord(BIFF_XF);
    Size:= Length(XFString);
    WriteWord(Size);
    WriteBytes(@(XFString[1]), Size);
  end;

begin
  if FXLSFile.DataFromFile then
    FDefaultXFCount:= 0
  else
  begin
    { Add default XFs ( count = FDefaultXFCount ) }
    FDefaultXFCount:= 21;

    {15 default style XF}
    SetLength(XFString, 20);
    Move(DefaultStyleXFData[1], XFString[1], 20);
    for I:= 1 to 15 do WriteXFString;

    {1 default cell XF}
    Move(DefaultCellXFData[1], XFString[1], 20);
    WriteXFString;

    {5 style XF}
    Move(DefaultExStyleXFData_1[1], XFString[1], 20);
    WriteXFString;
    Move(DefaultExStyleXFData_2[1], XFString[1], 20);
    WriteXFString;
    Move(DefaultExStyleXFData_3[1], XFString[1], 20);
    WriteXFString;
    Move(DefaultExStyleXFData_4[1], XFString[1], 20);
    WriteXFString;
    Move(DefaultExStyleXFData_5[1], XFString[1], 20);
    WriteXFString;

  end;
    
  { Add custom XFs }
  for I:= 0 to FWorkbook.XFTable.Count - 1 do
  begin
    XFData:= FWorkbook.XFTable.XF[I];

    { Skip $04 font }
    if (XFData^.FontIndex >= $04) then
      XFData^.FontIndex:= XFData^.FontIndex + 1;

    { get ifmt from FormatIndex}
    XFData^.FormatIndex := FWorkbook.FormatStrings[XFData^.FormatIndex].ifmt;

    XFString:= GetXFStringFromXFData(XFData);
    WriteXFString;
  end;
end;

procedure TXLSWriter.WriteStyleTable;
const
  {note : xlBuiltinStyles: array[0..5] of byte = (4,7,0,3,6);}
  MagicXFIndexes: array[0..5] of byte = ($10, $11, 0, $12, $13, $14);
var
  I, Size: integer;
  S: AnsiString;
begin
  for I:= Low(xlBuiltinStyles) to High(xlBuiltinStyles) do
  begin
    SetLength(S, 4);
    PWORD(@S[1])^:= MagicXFIndexes[I] or (word(1) shl 15);
    PByte(@S[3])^:= xlBuiltinStyles[I];
    PByte(@S[4])^:= $FF;

    WriteWord(BIFF_STYLE);
    Size:= Length(S);
    WriteWord(Size);
    WriteBytes(@(S[1]), Size);
  end;
end;

procedure TXLSWriter.WriteLinkTable;
var
  DocumentIndex, NameIndex: Integer;
  S: AnsiString;
begin

  for DocumentIndex:= 0 to FLinkTable.DocumentsCount - 1 do
  begin
    { Write document data }
    S:= FLinkTable.GetSupbookData(DocumentIndex);
    WriteWord(BIFF_SUPBOOK);
    WriteWord(Length(S));
    if Length(S) > 0 then
      WriteBytes(@S[1], Length(S));

    { Write external names }
    if not (FLinkTable.Document[DocumentIndex].IsLocal) then
    begin
      for NameIndex:= 0 to FLinkTable.Document[DocumentIndex].NamesCount - 1 do
      begin
        S:= FLinkTable.GetExternalNameData(DocumentIndex, NameIndex);

        WriteWord(BIFF_EXTERNNAME);
        WriteWord(Length(S));
        if Length(S) > 0 then
          WriteBytes(@S[1], Length(S));
      end;
    end;
  end;

  { Write externsheet table }
  S:= FLinkTable.GetExternsheetData;
  WriteWord(BIFF_EXTERNSHEET);
  WriteWord(Length(S));
  if Length(S) > 0 then
    WriteBytes(@S[1], Length(S));

  { Write local names }
  for NameIndex:= 0 to FLinkTable.LocalDocument.NamesCount - 1 do
  begin
    S:= FLinkTable.GetNameData(NameIndex);
    WriteWord(BIFF_NAME);
    WriteWord(Length(S));
    if Length(S) > 0 then
      WriteBytes(@S[1], Length(S));
  end;
end;

procedure TXLSWriter.DoProgress;
begin
  if Assigned(FOnProgress) then
    if FProgressRate > 1 then
      FOnProgress(1)
    else if FProgressRate < 0 then
      FOnProgress(0)
    else
      FOnProgress(FProgressRate);
end;

procedure TXLSWriter.BIFF8EncryptWorkbookStream;
var
  RecData: AnsiString;
  Size, ReadOffset, WriteOffset: Longword;
  RecNum, PrevRecNum, RecSize: Word;
  WriteBIFFStream: TBiffStream;
  EncryptionStarted: Boolean;
begin
  ReadOffset:= 0;
  WriteOffset:= 0;
  EncryptionStarted:= False;
  Size:= FWorkbookStream.Size;
  PrevRecNum:= 0;

  WriteBIFFStream:= TBiffStream.Create(FWorkbookStream);


  try
    while (ReadOffset < Size) do
    begin

      { Read }
      FWorkbookStream.Position:= ReadOffset;
      if not FWorkbookStream.ReadWord(@RecNum) then Break;
      if not FWorkbookStream.ReadWord(@RecSize) then Break;
      if (RecSize > 0) then
      begin
        SetLength(RecData, RecSize);
        if not FWorkbookStream.ReadBytes(@RecData[1], RecSize) then Break;
      end;
      ReadOffset:= FWorkbookStream.Position;

      { Write }
      FWorkbookStream.Position:= WriteOffset;
      WriteBIFFStream.BIFFRecord.RecNum:= RecNum;
      WriteBIFFStream.BIFFRecord.Size:= RecSize;
      WriteBIFFStream.BIFFRecord.Data.SetSize(RecSize);
      WriteBIFFStream.BIFFRecord.Data.Position:= 0;
      WriteBIFFStream.BIFFRecord.Data.WriteBytes(@RecData[1], RecSize);
      WriteBIFFStream.WriteBIFFRecord;

      WriteOffset:= FWorkbookStream.Position;

      { Start encryption }
      if (PrevRecNum = BIFF_FILEPASS) then
      begin
        if not EncryptionStarted then
        begin
          WriteBIFFStream.SetBIFF8EncryptionForWrite(FBIFF8EncryptionDigest);
          EncryptionStarted:= True;
        end;
      end;
      
      PrevRecNum:= RecNum;
    end;

    FWorkbookStream.Position:= WriteOffset;    
    WriteBIFFStream.WriteBIFFRecordFinal;
  finally
    WriteBIFFStream.Destroy;
  end;
end;

end.
