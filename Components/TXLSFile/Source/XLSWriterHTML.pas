unit XLSWriterHTML;

{-----------------------------------------------------------------
    SM Software, 2000-2006

    TXLSFile v.4.0

    TXLSFile to HTML export
    
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, XLSFile, XLSWorkbook, XLSBase, XLSError,
  HList, XLSFormat, XLSRects, XLSFormatStr, XLSFont;

type
  {TXLSWriterHTML}        
  TXLSWriterHTML = class
  private
    FSheet: TSheet;
    FStream: TStream;
    FRect: TRangeRect;
    FCSSList: THashedStringList;
    FCSSCellMap: TList;
    procedure CreateCSSStyles;
    procedure ClearCSSStyles;
    procedure WriteCSSStyles;
    procedure WriteCells;
    procedure SaveHTML;
  public
    constructor Create(ASheet: TSheet);
    destructor Destroy; override;
    procedure Save(const AFileName: AnsiString; const ARect: TRangeRect);
    procedure SaveToStream(const AStream: TStream; const ARect: TRangeRect);
  end;

implementation

uses
  SysUtils
{$IFDEF XLF_D6}
  , Variants
{$ENDIF}
  , XLSStrUtil
{$IFDEF XLF_D2009}
  , AnsiStrings
{$ENDIF}
  ;

function CellHAlignToCSS(ACellHAlignment: TCellHAlignment): AnsiString;
begin
  case ACellHAlignment of
    xlHAlignLeft   : Result:= 'text-align: left;';
    xlHAlignCenter : Result:= 'text-align: center;';
    xlHAlignRight  : Result:= 'text-align: right;';
    xlHAlignJustify: Result:= 'text-align: justify;';
  end;
end;

function CellVAlignToCSS(ACellVAlignment: TCellVAlignment): AnsiString;
begin
  case ACellVAlignment of
    xlVAlignTop     : Result:= 'vertical-align:top;';
    xlVAlignCenter  : Result:= 'vertical-align:center;';
    xlVAlignBottom  : Result:= 'vertical-align:bottom;';
    xlVAlignJustify : Result:= 'vertical-align:justify;';
  end;
end;

function CellBorderStyleToCSS(AXLBorderStyle: TXLBorderStyle): AnsiString;
begin
  case AXLBorderStyle of
    bsThin,
    bsThick,
    bsHair,
    bsMedium: Result:= 'solid';

    bsMediumDashed,
    bsDashDot,
    bsMediumDashDot,
    bsDashed,
    bsSlantedDashDot: Result:= 'dashed';

    bsDashDotDot,
    bsMediumDashDotDot,
    bsDotted: Result:= 'dotted';

    bsDouble: Result:= 'double';
    else Result:= 'none';
  end;
end;

function RGBColorToHTML(Color: Integer): AnsiString;
begin
  Result:= '#'
         + AnsiString(IntToHex((Color and Integer($ff)), 2))
         + AnsiString(IntToHex(((Color and Integer($ff00)) shr 8), 2))
         + AnsiString(IntToHex(((Color and Integer($ff0000)) shr 16), 2));
end;

function CellToCSS(const ASheet: TSheet; const ARow: Word; const AColumn: Byte): AnsiString;
var
  ACell: TCell;
begin
  ACell:= ASheet.Cells[ARow, AColumn];
  
  { Font attributes }
  Result:= 'font-family: ' + AnsiString(ACell.FontName) + ';' + #13#10
         + 'font-size: ' + AnsiString(IntToStr(ACell.FontHeight)) + 'pt;' + #13#10
         + 'color: ' + RGBColorToHTML(ACell.FontColorRGB) + ';' + #13#10;

  if ACell.FontBold then
    Result:= Result + 'font-weight: bold;' + #13#10;
  if ACell.FontItalic then
    Result:= Result + 'font-style: italic;' + #13#10;
  if ACell.FontUnderline then
    Result:= Result + 'text-decoration: underline;' + #13#10;
  if ACell.FontStrikeOut then
    Result:= Result + 'text-decoration: line-through;' + #13#10;

  { Text alignment }
  Result:= Result + CellHAlignToCSS(ACell.HAlign) + #13#10;
  { Vertical alignment }
  Result:= Result + CellVAlignToCSS(ACell.VAlign) + #13#10;

  { Background color }
  if not (ACell.FillPatternBGColorIndex in [xlColorNone, xlColorAuto]) then
    Result:= Result + 'background-color: ' + RGBColorToHTML(ACell.FillPatternBGColorRGB) + ';' + #13#10;

  { Borders }
  { Top}
  if (ACell.BorderStyle[xlBorderTop] <> bsNone) then
    Result:= Result
           + 'border-top-style: ' + CellBorderStyleToCSS(ACell.BorderStyle[xlBorderTop]) + ';' + #13#10
           + 'border-top-color: ' + RGBColorToHTML(ACell.BorderColorRGB[xlBorderTop]) + ';' + #13#10
           + 'border-top-width: ' + AnsiString(IntToStr(XLSLineStyleWidth(ACell.BorderStyle[xlBorderTop]))) + ';' + #13#10;

  {Left}
  if (ACell.BorderStyle[xlBorderLeft] <> bsNone) then
    Result:= Result
           + 'border-left-style: ' + CellBorderStyleToCSS(ACell.BorderStyle[xlBorderLeft]) + ';' + #13#10
           + 'border-left-color: ' + RGBColorToHTML(ACell.BorderColorRGB[xlBorderLeft]) + ';' + #13#10
           + 'border-left-width: ' + AnsiString(IntToStr(XLSLineStyleWidth(ACell.BorderStyle[xlBorderLeft]))) + ';' + #13#10;

  {Bottom}
  if (ACell.BorderStyle[xlBorderBottom] <> bsNone) then
    Result:= Result
           + 'border-bottom-style: ' + CellBorderStyleToCSS(ACell.BorderStyle[xlBorderBottom]) + ';' + #13#10
           + 'border-bottom-color: ' + RGBColorToHTML(ACell.BorderColorRGB[xlBorderBottom]) + ';' + #13#10
           + 'border-bottom-width: ' + AnsiString(IntToStr(XLSLineStyleWidth(ACell.BorderStyle[xlBorderBottom]))) + ';' + #13#10;

  {Right }
  if (ACell.BorderStyle[xlBorderRight] <> bsNone) then
    Result:= Result
           + 'border-right-style: ' + CellBorderStyleToCSS(ACell.BorderStyle[xlBorderRight]) + ';' + #13#10
           + 'border-right-color: ' + RGBColorToHTML(ACell.BorderColorRGB[xlBorderRight]) + ';' + #13#10
           + 'border-right-width: ' + AnsiString(IntToStr(XLSLineStyleWidth(ACell.BorderStyle[xlBorderRight]))) + ';' + #13#10;

end;

{TXLSWriterHTML}
constructor TXLSWriterHTML.Create(ASheet: TSheet);
begin
  FSheet:= ASheet;
end;

destructor TXLSWriterHTML.Destroy;
begin
  inherited;
end;

procedure TXLSWriterHTML.Save(const AFileName: AnsiString; const ARect: TRangeRect);
begin
  FStream:= TFileStream.Create(String(AFileName), fmCreate);
  try
    SaveToStream(FStream, ARect);
  finally
    FStream.Destroy;
  end;
end;

procedure TXLSWriterHTML.SaveToStream(const AStream: TStream; const ARect: TRangeRect);
begin
  FStream:= AStream;
  FRect:= ARect;

  SaveHTML;
end;

procedure TXLSWriterHTML.WriteCSSStyles;
var
  Buff: AnsiString;
  I: Integer;
begin
  Buff:='<style>' + #13#10;
  FStream.WriteBuffer(Buff[1], Length(Buff));

  for I:= 0 to FCSSList.Count - 1 do
  begin
    Buff:= '.xl' + AnsiString(IntToStr(I)) + #13#10 + ' {' + FCSSList.Item[I] + '}' + #13#10;
    FStream.WriteBuffer(Buff[1], Length(Buff));
  end;

  Buff:='</style>' + #13#10;
  FStream.WriteBuffer(Buff[1], Length(Buff));
end;

procedure TXLSWriterHTML.CreateCSSStyles;
var
  Row: Word;
  Column: Byte;
  CSS: AnsiString;
  CSSIndex: Integer;
begin
  FCSSList:= THashedStringList.Create(1024 * 8 - 1);
  FCSSCellMap:= TList.Create;
  FCSSCellMap.Capacity:= (FRect.RowTo - FRect.RowFrom + 1) * (FRect.ColumnTo - FRect.ColumnFrom + 1);

  for Row:= FRect.RowFrom to FRect.RowTo do
    for Column:= FRect.ColumnFrom to FRect.ColumnTo do
    begin
      CSS:= CellToCSS(FSheet, Row, Column);
      CSSIndex:= FCSSList.IndexByKey(CSS);
      if CSSIndex < 0 then
      begin
        CSSIndex:= FCSSList.Count;
        FCSSList.Add(CSS);
      end;

      FCSSCellMap.Add(Pointer(CSSIndex)); 
    end;
end;

procedure TXLSWriterHTML.ClearCSSStyles;
begin
  FCSSList.Destroy;
  FCSSCellMap.Destroy;
end;

procedure TXLSWriterHTML.WriteCells;
var
  Row: Word;
  Column: Byte;
  CSSIndex: Integer;
  CellMapIndex: Integer;
  CellMapWidth: Integer;
  Buff: AnsiString;
  CellValue: AnsiString;
  Cell: TCell;
  MergedRect: TRangeRect;
  IsMerged: Boolean;
  IsMergedTopLeft: Boolean;
  CellWidth, CellHeight: Integer;
  ARow: Word;
  AColumn: Byte;
  ATableWidth: Integer;

  function VerifyHTML(S: AnsiString): AnsiString;
  begin
    Result:= Trim(S);
    { remove tags }
    { remove tags }
    {$IFDEF XLF_D2009}
    Result:= AnsiStrings.StringReplace(Result, '>', '_', [rfReplaceAll]);
    Result:= AnsiStrings.StringReplace(Result, '<', '_', [rfReplaceAll]);
    {$ELSE}
    Result:= StringReplace(Result, '>', '_', [rfReplaceAll]);
    Result:= StringReplace(Result, '<', '_', [rfReplaceAll]);
    {$ENDIF}
    if Result = '' then Result:= '&nbsp;'
  end;

begin
  CellMapWidth:= FRect.ColumnTo - FRect.ColumnFrom + 1;

  { Table size }
  ATableWidth:= 0;
  for AColumn:= FRect.ColumnFrom to FRect.ColumnTo do
    ATableWidth:= ATableWidth + FSheet.Columns[AColumn].VisibleWidthPx + 1;

  Buff:= '<table cellpadding=0 cellspacing=0 border=0 width='
       + AnsiString(IntToStr(ATableWidth))
       + ' style="border-collapse:collapse;"'
       + '>'#13#10;
  FStream.WriteBuffer(Buff[1], Length(Buff));

  for Row:= FRect.RowFrom to FRect.RowTo do
  begin
    { open row tag }
    Buff:= '<tr>' + #13#10;
    FStream.WriteBuffer(Buff[1], Length(Buff));

    { cells }
    for Column:= FRect.ColumnFrom to FRect.ColumnTo do
    begin
      Cell:= FSheet.Cells.Cell[Row, Column];

      { Merged stuff }
      IsMerged:= Cell.Merged;
      IsMergedTopLeft:= False;
      if IsMerged then
      begin
        FSheet.FindMergedRectContainingCell(Cell, MergedRect);
        IsMergedTopLeft:= ((Cell.Row = MergedRect.RowFrom)
                       and (Cell.Col = MergedRect.ColumnFrom));
        if not IsMergedTopLeft then Continue;
      end;

      { Find CSS style }
      CellMapIndex:= (Row - FRect.RowFrom) * CellMapWidth + (Column - FRect.ColumnFrom);
      CSSIndex:= Integer(FCSSCellMap[CellMapIndex]);
      { Value }
      CellValue:= VerifyHTML(AnsiString(Cell.ValueAsString));
      { CSS Style }
      Buff:= '<td class="xl' + AnsiString(IntToStr(CSSIndex)) + '"';

      { Merged stuff }
      if IsMerged and IsMergedTopLeft then
      begin
        Buff:= Buff
             + ' colspan=' + AnsiString(IntToStr(MergedRect.ColumnTo - MergedRect.ColumnFrom + 1))
             + ' rowspan=' + AnsiString(IntToStr(MergedRect.RowTo - MergedRect.RowFrom + 1)) + ' ';

        CellWidth:= 0;
        CellHeight:= 0;
        for ARow:= MergedRect.RowFrom to MergedRect.RowTo do
          CellHeight:= CellHeight + FSheet.Rows[ARow].VisibleHeightPx + 1;
        for AColumn:= MergedRect.ColumnFrom to MergedRect.ColumnTo do
          CellWidth:= CellWidth + FSheet.Columns[AColumn].VisibleWidthPx + 1;
      end
      else
      begin
        CellWidth:= FSheet.Columns[Column].VisibleWidthPx + 1;
        CellHeight:= FSheet.Rows[Row].VisibleHeightPx + 1;
      end;

      { Size }
      Buff:= Buff + ' width=' + AnsiString(IntToStr(CellWidth))
                  + ' height=' + AnsiString(IntToStr(CellHeight)) + '>';

      { Open hyperlink }
      if Cell.Hyperlink <> '' then Buff:= Buff + '<a href="' + AnsiString(Cell.Hyperlink) + '"';

      { Value }
      Buff:= Buff + CellValue;

      { Close hyperlink }
      if Cell.Hyperlink <> '' then Buff:= Buff + '</a>';

      { Close cell }
      Buff:= Buff + '</td>' + #13#10;
      FStream.WriteBuffer(Buff[1], Length(Buff));
    end;

    { close row tag }
    Buff:= '</tr>' + #13#10;
    FStream.WriteBuffer(Buff[1], Length(Buff));
  end;

  Buff:= '</table>' + #13#10;
  FStream.WriteBuffer(Buff[1], Length(Buff));
end;

procedure TXLSWriterHTML.SaveHTML;
var
  Buff: AnsiString;
begin
  Buff:= '<html>' + #13#10;
  FStream.WriteBuffer(Buff[1], Length(Buff));

  CreateCSSStyles;
  try
    WriteCSSStyles;
    WriteCells;
  finally
    ClearCSSStyles;
  end;

  Buff:= '</html>';
  FStream.WriteBuffer(Buff[1], Length(Buff));
end;


end.
