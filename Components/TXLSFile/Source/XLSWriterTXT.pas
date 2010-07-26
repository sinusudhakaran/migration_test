unit XLSWriterTXT;

{-----------------------------------------------------------------
    SM Software, 2000-2006

    TXLSFile v.4.0

    TXLSFile to TXT export
    
-----------------------------------------------------------------}

{$I XLSFile.inc}

interface
uses Classes, XLSWorkbook, XLSRects, XLSBase;

type
  {TXLSWriterTXT}
  TXLSWriterTXT = class
  private
    FSheet: TSheet;
  public
    constructor Create(ASheet: TSheet);
    procedure Save(const AFileName: AnsiString; const AFileType: TTXTFileType;
      const ARect: TRangeRect);
    procedure SaveToStream(const AStream: TStream; const AFileType: TTXTFileType;
      const ARect: TRangeRect);
  end;

implementation

constructor TXLSWriterTXT.Create(ASheet: TSheet);
begin
  FSheet:= ASheet;
end;

procedure TXLSWriterTXT.Save(const AFileName: AnsiString; const AFileType: TTXTFileType;
  const ARect: TRangeRect);
var
  FStream: TStream;
begin
  FStream:= TFileStream.Create(String(AFileName), fmCreate);
  try
    SaveToStream(FStream, AFileType, ARect);
  finally
    FStream.Destroy;
  end;
end;

procedure TXLSWriterTXT.SaveToStream(const AStream: TStream;
  const AFileType: TTXTFileType; const ARect: TRangeRect);
var
  Row: Word;
  Column: Byte;
  Buff: AnsiString;  
begin
  for Row:= ARect.RowFrom to ARect.RowTo do
  begin
    Buff:= '';
    for Column:= ARect.ColumnFrom to ARect.ColumnTo do
    begin
      if AFileType = txtCSV then Buff:= Buff + '"';
      Buff:= Buff + AnsiString(FSheet.Cells[Row, Column].ValueAsString);
      if AFileType = txtCSV then Buff:= Buff + '"';

      { Values separator }
      if Column < ARect.ColumnTo then
        if AFileType = txtCSV then
          Buff:= Buff + ','
        else
          if AFileType = txtTab
            then Buff := Buff + #9;
    end;

    { Row seperator }
    Buff:= Buff + #13#10;
    AStream.WriteBuffer(Buff[1], Length(Buff));
  end;  
end;

end.
