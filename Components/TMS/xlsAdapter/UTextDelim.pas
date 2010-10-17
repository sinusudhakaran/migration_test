unit UTextDelim;
{$IFDEF LINUX}{$INCLUDE ../FLXCOMPILER.INC}{$ELSE}{$INCLUDE ..\FLXCOMPILER.INC}{$ENDIF}
interface
  uses Classes, SysUtils, UExcelAdapter, UFlxNumberFormat, UFlxMessages;

type
  XLSColumnImportTypes=(xct_general, xct_text, xct_skip);

//***********************************************************************************
{**}  procedure SaveAsTextDelim(const OutStream: TStream; const Workbook: TExcelFile; const Delim: char);
{**}  procedure SaveRangeAsTextDelim(const OutStream: TStream; const Workbook: TExcelFile; const Delim: char; const Range: TXlsCellRange);
{**}  procedure LoadFromTextDelim(const InStream: TStream; const Workbook: TExcelFile; const Delim: char; const FirstRow, FirstCol: integer; const ColumnFormats: array of XLSColumnImportTypes);
//***********************************************************************************
implementation

procedure SaveRangeAsTextDelim(const OutStream: TStream; const Workbook: TExcelFile; const Delim: char; const Range: TXlsCellRange);
var
  r,c: integer;
  s: string;
  Color: integer;
begin
  for r:=Range.Top to Range.Bottom do
  begin
    for c:=Range.Left to Range.Right do
    begin
      s:=XlsFormatValue1904(Workbook.CellValue[r,c],Workbook.FormatList[Workbook.CellFormat[r,c]].Format, Workbook.Options1904Dates, Color);
      if (pos(Delim, s)>0) or (pos('"', s)>0) or (pos(#10,s)>0) or (pos(#13,s)>0) then
      begin
        s:=AnsiQuotedStr(s,'"');
      end;
      if c<Range.Right then s:=s+Delim else s:=s+#13#10;

      OutStream.Write(s[1], Length(s));
    end;
  end;
end;


procedure SaveAsTextDelim(const OutStream: TStream; const Workbook: TExcelFile; const Delim: char);
var
  Range:TXlsCellRange;
begin
  Range.Left:=1;
  Range.Top:=1;
  Range.Right:=Workbook.MaxCol;
  Range.Bottom:=Workbook.MaxRow;
  SaveRangeAsTextDelim(OutStream, Workbook, Delim, Range);
end;

procedure ReadQString(const InStream: TStream; var S: string; var ch: char);
var
  InQuote: boolean;
begin
  InQuote:=false;
  s:='';
  while InStream.Position<InStream.Size do
  begin
    InStream.Read(ch, SizeOf(ch));
    if (ch<>'"') and InQuote then
    begin
      exit;
    end;
    if InQuote or (ch<>'"') then s:=s+ch;
    InQuote:=(ch='"') and not InQuote;
  end;
end;

procedure ReadNString(const InStream: TStream; const Delim: char; var S: string; var ch: char);
begin
  s:=ch;
  while InStream.Position<InStream.Size do
  begin
    InStream.Read(ch, SizeOf(ch));
    if (ch=Delim)or (ch=#13)or (ch=#10)  then exit;
    s:=s+ch;
  end; //while
end;

procedure LoadFromTextDelim(const InStream: TStream; const Workbook: TExcelFile; const Delim: char; const FirstRow, FirstCol: integer; const ColumnFormats: array of XLSColumnImportTypes);
var
  r,c: integer;
  s: string;
  ch: char;
begin
  r:=FirstRow;
  c:=FirstCol;
  if InStream.Position<InStream.Size then InStream.Read(ch, SizeOf(ch));
  while InStream.Position<InStream.Size do
  begin
    if (ch='"') then ReadQString(InStream, s, ch)
    else if (ch=Delim) then
    begin
      inc(c);
      InStream.Read(ch, SizeOf(ch));
      continue;
    end
    else if (ch=#10) then
    begin
      c:=FirstCol;
      inc(r);
      InStream.Read(ch, SizeOf(ch));
      continue;
    end else if (ch=#13) then
    begin
      InStream.Read(ch, SizeOf(ch));
      continue;
    end
    else ReadNString(InStream, Delim, s, ch);

    if c-FirstCol< Length(ColumnFormats) then
      case ColumnFormats[c-FirstCol] of
        xct_text: Workbook.CellValue[r, c]:=s;
        xct_skip: begin end;
        else WorkBook.SetCellString(r,c,s);
      end //case
    else WorkBook.SetCellString(r,c,s);
  end;
end;

end.
