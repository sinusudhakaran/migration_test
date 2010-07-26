unit XLSExportComp;

{-----------------------------------------------------------------
    SM Software, 2002-2004

    XLSExport Export Components v1.1 (uses TXLSFile library)

    Rev history:
    2004-04-23  Fix: Fields[C] -> Fields[I] in TXLSExportDataSource.ExportData
    2006-08-27  Add: TXLSExportDataSource.DataIsUnidirectional
    2008-11-30  Add: convert dbExpress TimeStamp and BCD types to standard date and float

-----------------------------------------------------------------}

{$I XLSFile.inc}

{$R 'XLSExportComp.dcr'}

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, 
  DB, Grids, DBGrids, XLSBase, XLSFile, XLSWorkbook, XLSFormat, XLSRects;

type
  TCell = XLSWorkbook.TCell;

type
  TExportOptionType = (eoptVisibleOnly, eoptVisibleColumnsOnly, eoptNoColumnsTitles);
  TExportOptions = set of TExportOptionType;

  TTotalCalcType = (tcNone, tcUserDef, tcAverage, tcCount, tcMin, tcMax, tcSum);

  { TXLSExportFile }
  TXLSExportFile = class(TComponent)
  private
    FXLSFile: TXLSFile;
    function GetWorkbook: TWorkbook;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Clear;
    procedure SaveToFile(const AFileName: WideString);
    procedure SaveToStream(const AStream: TStream);
    property Workbook: TWorkbook read GetWorkbook;
    property XLSFile: TXLSFile read FXLSFile;
  end;

  {TXLSExportCustomComponent}
  TXLSExportCustomComponent = class(TComponent)
  protected
    FXLSExportFile: TXLSExportFile;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;    
  public
    procedure ExportData(ASheetIndex: Integer; ARow, AColumn: Integer); dynamic; abstract;
    procedure ExportDataSheetName(ASheetName: WideString; ARow, AColumn: Integer); dynamic;
  published
    constructor Create(AOwner: TComponent); override;
    property XLSExportFile: TXLSExportFile read FXLSExportFile write FXLSExportFile;
  end;

  TColumnExportEvent = procedure (Column: DBGrids.TColumn; XLSCell: TCell) of object;
  TColumnTitleExportEvent = procedure (ColIndex: Integer; XLSCell: TCell) of object;
  TColumnFooterExportEvent = procedure (ColIndex: Integer; XLSCell: TCell;
    var TotalCalcType: TTotalCalcType;
    var TotalRange: AnsiString) of object;

  {TXLSExportDBGrid}
  TXLSExportDBGrid = class(TXLSExportCustomComponent)
  protected
    FDBGrid: TDBGrid;
    FOptions: TExportOptions;
    FOnSaveColumn: TColumnExportEvent;
    FOnSaveTitle: TColumnTitleExportEvent;
    FOnSaveFooter: TColumnFooterExportEvent;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ExportData(ASheetIndex: Integer; ARow, AColumn: Integer); override;
  published
    property DBGrid: TDBGrid read FDBGrid write FDBGrid;
    property Options: TExportOptions read FOptions write FOptions;
    property OnSaveColumn: TColumnExportEvent read FOnSaveColumn write FOnSaveColumn;
    property OnSaveTitle: TColumnTitleExportEvent read FOnSaveTitle write FOnSaveTitle;
    property OnSaveFooter: TColumnFooterExportEvent read FOnSaveFooter write FOnSaveFooter;
  end;

  TCellExportEvent = procedure (Row, Col: integer; XLSCell: TCell) of object;

  {TXLSExportStringGrid}
  TXLSExportStringGrid = class(TXLSExportCustomComponent)
  protected
    FStringGrid: TStringGrid;
    FOnSaveCell: TCellExportEvent;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ExportData(ASheetIndex: Integer; ARow, AColumn: Integer); override;
  published
    property StringGrid: TStringGrid read FStringGrid write FStringGrid;
    property OnSaveCell: TCellExportEvent read FOnSaveCell write FOnSaveCell;
  end;

  TFieldExportEvent = procedure (Field: TField; XLSCell: TCell) of object;
  TFieldTitleExportEvent = procedure (FieldIndex: Integer; XLSCell: TCell) of object;
  TFieldFooterExportEvent = procedure (FieldIndex: Integer; XLSCell: TCell;
    var TotalCalcType: TTotalCalcType;
    var TotalRange: AnsiString) of object;

  {TXLSExportDataSource}
  TXLSExportDataSource = class(TXLSExportCustomComponent)
  protected
    FDataSource: TDataSource;
    FDataIsUnidirectional: Boolean;
    FOptions: TExportOptions;
    FOnSaveField: TFieldExportEvent;
    FOnSaveTitle: TFieldTitleExportEvent;
    FOnSaveFooter: TFieldFooterExportEvent;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;    
  public
    constructor Create(AOwner: TComponent); override;
    procedure ExportData(ASheetIndex: Integer; ARow, AColumn: Integer); override;
  published
    property DataSource: TDataSource read FDataSource write FDataSource;
    property Options: TExportOptions read FOptions write FOptions;
    property DataIsUnidirectional: Boolean read FDataIsUnidirectional write FDataIsUnidirectional default False;
    property OnSaveField: TFieldExportEvent read FOnSaveField write FOnSaveField;
    property OnSaveTitle: TFieldTitleExportEvent read FOnSaveTitle write FOnSaveTitle;
    property OnSaveFooter: TFieldFooterExportEvent read FOnSaveFooter write FOnSaveFooter;
  end;

const
  xlTotalCalcFunctions: array [TTotalCalcType] of AnsiString = (
  '', '', 'AVERAGE', 'COUNT', 'MIN', 'MAX', 'SUM');

procedure Register;

implementation

{ TXLSExportFile }
constructor TXLSExportFile.Create(AOwner: TComponent);
begin
  inherited;
  FXLSFile:= TXLSFile.Create;
end;

destructor TXLSExportFile.Destroy;
begin
  FXLSFile.Destroy;
  inherited;
end;

function TXLSExportFile.GetWorkbook: TWorkbook;
begin
  result:= FXLSFile.Workbook;
end;

procedure TXLSExportFile.SaveToFile(const AFileName: WideString);
begin
  FXLSFile.SaveAs(AFileName);
end;

procedure TXLSExportFile.SaveToStream(const AStream: TStream);
begin
  FXLSFile.SaveToStream(AStream);
end;

procedure TXLSExportFile.Clear;
begin
  FXLSFile.Workbook.Clear;
end;

{TXLSExportCustomComponent}
constructor TXLSExportCustomComponent.Create(AOwner: TComponent);
begin
  inherited;
  FXLSExportFile:= nil;
end;

procedure TXLSExportCustomComponent.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FXLSExportFile) then
    FXLSExportFile:= nil;
end;

procedure TXLSExportCustomComponent.ExportDataSheetName(ASheetName: WideString;
  ARow, AColumn: Integer);
var
  Ind: integer;
  Sheet: TSheet;
begin
  if not Assigned(FXLSExportFile) then
    exit;
    
  {find sheet by name or create new}
  Sheet:= FXLSExportFile.Workbook.SheetByName(ASheetName);
  if Assigned(Sheet) then
    Ind:= Sheet.Index
  else
  begin
    FXLSExportFile.Workbook.Sheets.Add(ASheetName);
    Ind:= FXLSExportFile.Workbook.Sheets.Count - 1;
  end;

  Self.ExportData(Ind, ARow, AColumn);
end;

{TXLSExportDBGrid}
constructor TXLSExportDBGrid.Create(AOwner: TComponent);
begin
  inherited;
  FDBGrid:= nil;
  FOptions:= [];
end;

procedure TXLSExportDBGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDBGrid) then
    FDBGrid:= nil;
end;

procedure TXLSExportDBGrid.ExportData(ASheetIndex: Integer; ARow, AColumn: Integer);
var
  S: TSheet;
  R, C, I: integer;
  CalcType: TTotalCalcType;
  CalcRange: AnsiString;
begin
  { do nothing if not binded to TXLSExportFile }
  if not Assigned(FXLSExportFile) then
    exit;

  S:= FXLSExportFile.Workbook.Sheets[ASheetIndex];
  with S do
  begin
    {save title}
    C:= AColumn;
    R:= ARow;
    if not (eoptNoColumnsTitles in FOptions) then
    begin
      for I:= 0 to FDBGrid.Columns.Count-1 do
      begin
        if ((not (eoptVisibleOnly in FOptions))
         or ((eoptVisibleOnly in FOptions) and FDBGrid.Columns[I].Field.Visible)
{$IFNDEF XLF_D3}
         or ((eoptVisibleColumnsOnly in FOptions) and FDBGrid.Columns[I].Visible)
{$ENDIF}
         )
         then
        begin
          Cells[R, C].Value:= FDBGrid.Columns[I].Title.Caption;
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(
            FDBGrid.Columns[I].Title.Alignment);
          Cells[R, C].FontName:= FDBGrid.Columns[I].Title.Font.Name;
          Cells[R, C].FontBold:= (fsBold in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Title.Font.Style);
          Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Title.Font.Style);

          Cells[R, C].FontHeight:= FDBGrid.Columns[I].Title.Font.Size;
          if FDBGrid.Columns[I].Title.Font.Color <> clBlack then
            Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Title.Font.Color);
          if (FDBGrid.Columns[I].Title.Color <> clWindow) and
             (FDBGrid.Columns[I].Title.Color <> clBtnFace) then
          begin
            Cells[R, C].FillPattern:= xlPatternSolid;
            Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Title.Color);
          end;
          Columns[C].Width:= PixToXLSWidth(FDBGrid.Columns[I].Width);

          if Assigned(FOnSaveTitle) then
            FOnSaveTitle(I, Cells[R, C]);

          Inc(C);
        end;
      end;
    end;

    {save data}
    FDBGrid.DataSource.DataSet.DisableControls;
    try
      if not (eoptNoColumnsTitles in FOptions) then
        R:= ARow + 1;
      FDBGrid.DataSource.DataSet.First;
      while not FDBGrid.DataSource.DataSet.Eof do
      begin
        C:= AColumn;
        for I:= 0 to FDBGrid.Columns.Count-1 do
        begin
          if ((not (eoptVisibleOnly in FOptions))
           or ((eoptVisibleOnly in FOptions) and FDBGrid.Columns[I].Field.Visible)
{$IFNDEF XLF_D3}
           or ((eoptVisibleColumnsOnly in FOptions) and FDBGrid.Columns[I].Visible)
{$ENDIF}
           ) then
          begin
            if not FDBGrid.Columns[I].Field.IsNull then
{$IFDEF XLF_D6}
              if FDBGrid.Columns[I].Field.DataType = ftTimeStamp then
                Cells[R, C].Value:= FDBGrid.Columns[I].Field.AsDateTime
              else
                if FDBGrid.Columns[I].Field.DataType = ftFMTBcd then
                  Cells[R, C].Value:= FDBGrid.Columns[I].Field.AsFloat
              else
{$ENDIF}
              if FDBGrid.Columns[I].Field.AsString <> '' then
                Cells[R, C].Value:= FDBGrid.Columns[I].Field.Value;
            Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(FDBGrid.Columns[I].Alignment);
            Cells[R, C].FontName:= FDBGrid.Columns[I].Font.Name;
            Cells[R, C].FontBold:= (fsBold in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Font.Style);
            Cells[R, C].FontHeight:= FDBGrid.Columns[I].Font.Size;

            if FDBGrid.Columns[I].Font.Color <> clBlack then
              Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Font.Color);
            if (FDBGrid.Columns[I].Color <> clWindow) then
            begin
              Cells[R, C].FillPattern:= xlPatternSolid;
              Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Color);
            end;

            if Assigned(FOnSaveColumn) then
              FOnSaveColumn(FDBGrid.Columns[I], Cells[R, C]);
            Inc(C);
          end;
        end;

        FDBGrid.DataSource.DataSet.Next;
        Inc(R);
      end;
    finally
      FDBGrid.DataSource.DataSet.First;
      FDBGrid.DataSource.DataSet.EnableControls;
    end;

    {save totals}
    if Assigned(FOnSaveFooter) then
    begin
      C:= AColumn;
      for I:= 0 to FDBGrid.Columns.Count-1 do
      begin
        if ((not (eoptVisibleOnly in FOptions))
          or ((eoptVisibleOnly in FOptions) and FDBGrid.Columns[I].Field.Visible)
{$IFNDEF XLF_D3}
          or ((eoptVisibleColumnsOnly in FOptions) and FDBGrid.Columns[I].Visible)
{$ENDIF}          
          ) then
        begin
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(FDBGrid.Columns[I].Alignment);
          Cells[R, C].FontName:= FDBGrid.Columns[I].Font.Name;
          Cells[R, C].FontBold:= (fsBold in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontItalic:= (fsItalic in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontUnderline:= (fsUnderline in FDBGrid.Columns[I].Font.Style);
          Cells[R, C].FontStrikeOut:= (fsStrikeOut in FDBGrid.Columns[I].Font.Style);

          Cells[R, C].FontHeight:= FDBGrid.Columns[I].Font.Size;

          if FDBGrid.Columns[I].Font.Color <> clBlack then
            Cells[R, C].FontColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Font.Color);
          if (FDBGrid.Columns[I].Color <> clWindow) then
          begin
            Cells[R, C].FillPattern:= xlPatternSolid;
            Cells[R, C].FillPatternBGColorIndex:= ColorToXLSColorIndex(FDBGrid.Columns[I].Color);
          end;

          CalcRange:= ColIndexToColName(C) + AnsiString(IntToStr(ARow + 2)) + ':' +
            ColIndexToColName(C) +  AnsiString(IntToStr(R));
          CalcType:= tcNone;

          FOnSaveFooter(I, Cells[R, C], CalcType, CalcRange);

          case CalcType of
            tcNone:
              begin
                Cells[R, C].Clear;
              end;
            tcUserDef: ;
            else
              if CalcRange <> '' then
                Cells[R, C].Formula:= xlTotalCalcFunctions[CalcType] +
                  '(' + CalcRange + ')';
          end;
          Inc(C);
        end;
      end;
    end;
  end;
end;

{TXLSExportStringGrid}
constructor TXLSExportStringGrid.Create(AOwner: TComponent);
begin
  inherited;
  FStringGrid:= nil;
end;

procedure TXLSExportStringGrid.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FStringGrid) then
    FStringGrid:= nil;
end;

procedure TXLSExportStringGrid.ExportData(ASheetIndex: Integer; ARow, AColumn: Integer);
var
  S: TSheet;
  R, C: integer;
begin
  { do nothing if not binded to TXLSExportFile}
  if not Assigned(FXLSExportFile) then
    exit;

  S:= FXLSExportFile.Workbook.Sheets[ASheetIndex];
  with S do
  begin
    {save columns widths}
    for C:= 0 to FStringGrid.ColCount-1 do
    begin
      Columns[C + AColumn].Width:= PixToXLSWidth(FStringGrid.ColWidths[C]);
    end;

    {save row heights}
    for R:= 0 to FStringGrid.RowCount-1 do
    begin
      Rows[R + ARow].Height:= FStringGrid.RowHeights[R];
    end;

    {save cells}
    for R:= 0 to FStringGrid.RowCount-1 do
    begin
      for C:= 0 to FStringGrid.ColCount-1 do
      begin
        if FStringGrid.Cells[C, R] <> '' then
         Cells[R + ARow, C + AColumn].Value:= FStringGrid.Cells[C,R];

        if Assigned(FOnSaveCell) then
          FOnSaveCell(R, C, Cells[R + ARow, C + AColumn]);
      end;
    end;
  end;
end;

{TXLSExportDataSource}
constructor TXLSExportDataSource.Create(AOwner: TComponent);
begin
  inherited;
  FDataSource:= nil;
  FOptions:= [];
  FDataIsUnidirectional := False;
end;

procedure TXLSExportDataSource.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FDataSource) then
    FDataSource:= nil;
end;

procedure TXLSExportDataSource.ExportData(ASheetIndex: Integer; ARow, AColumn: Integer);
var
  S: TSheet;
  R, C, I: integer;
  CalcType: TTotalCalcType;
  CalcRange: AnsiString;
begin
  { do nothing if not binded to TXLSExportFile}
  if not Assigned(FXLSExportFile) then
    exit;

  S:= FXLSExportFile.Workbook.Sheets[ASheetIndex];

  with S do
  begin
    {save title}
    C:= AColumn;
    R:= ARow;
    if not (eoptNoColumnsTitles in FOptions) then
    begin
      for I:= 0 to FDataSource.DataSet.FieldCount-1 do
      begin
        if ((not (eoptVisibleOnly in FOptions))
         or ((eoptVisibleOnly in FOptions) and FDataSource.DataSet.Fields[I].Visible)) then
        begin
          if (FDataSource.DataSet.Fields[I].DisplayName <> '') then
            Cells[R, C].Value:= FDataSource.DataSet.Fields[I].DisplayName
          else
            Cells[R, C].Value:= FDataSource.DataSet.Fields[I].FieldName;
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(
            FDataSource.DataSet.Fields[I].Alignment);
          Cells[R, C].FontBold:= True;
          Columns[C].Width:= FDataSource.DataSet.Fields[I].DisplayWidth;

          if Assigned(FOnSaveTitle) then
            FOnSaveTitle(I, Cells[R, C]);
          Inc(C);
        end;
      end;
    end;

    {save data}
    FDataSource.DataSet.DisableControls;
    try
      if not (eoptNoColumnsTitles in FOptions) then
        R:= ARow + 1;

      if not FDataIsUnidirectional then
        FDataSource.DataSet.First;

      while not FDataSource.DataSet.Eof do
      begin
        C:= AColumn;
        for I:= 0 to FDataSource.DataSet.FieldCount-1 do
        begin
          if ((not (eoptVisibleOnly in FOptions))
           or ((eoptVisibleOnly in FOptions) and FDataSource.DataSet.Fields[I].Visible)) then
          begin
            if not FDataSource.DataSet.Fields[I].IsNull then
{$IFDEF XLF_D6}
              if FDataSource.DataSet.Fields[I].DataType = ftTimeStamp then
                Cells[R, C].Value:= FDataSource.DataSet.Fields[I].AsDateTime
              else
              if FDataSource.DataSet.Fields[I].DataType = ftFMTBcd then
                Cells[R, C].Value:= FDataSource.DataSet.Fields[I].AsFloat
              else
{$ENDIF}
              if FDataSource.DataSet.Fields[I].AsString <> '' then
                Cells[R, C].Value:= FDataSource.DataSet.Fields[I].Value;
            Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(
              FDataSource.DataSet.Fields[I].Alignment);
            if Assigned(FOnSaveField) then
              FOnSaveField(FDataSource.DataSet.Fields[I], Cells[R, C]);

            Inc(C);
          end;
        end;
        FDataSource.DataSet.Next;
        Inc(R);
      end;
    finally
      if not FDataIsUnidirectional then
        FDataSource.DataSet.First;
      FDataSource.DataSet.EnableControls;
    end;

    {save totals}
    if Assigned(FOnSaveFooter) then
    begin
      C:= AColumn;
      for I:= 0 to FDataSource.DataSet.FieldCount-1 do
      begin
        if ((not (eoptVisibleOnly in FOptions))
         or ((eoptVisibleOnly in FOptions) and FDataSource.DataSet.Fields[I].Visible)) then
        begin
          CalcRange:= ColIndexToColName(C) + AnsiString(IntToStr(ARow + 2)) + ':'
            + ColIndexToColName(C) +  AnsiString(IntToStr(R));
          CalcType:= tcNone;
          Cells[R, C].HAlign:= TextAlignmentToXLSCellHAlignment(
            FDataSource.DataSet.Fields[I].Alignment);

          FOnSaveFooter(C, Cells[R, C], CalcType, CalcRange);

          case CalcType of
            tcNone:
              begin
                Cells[R, C].Clear;
              end;
            tcUserDef: ;
            else
              if CalcRange <> '' then
                Cells[R, C].Formula:= xlTotalCalcFunctions[CalcType] +
                  '(' + CalcRange + ')';
          end;

          Inc(C);
        end;
      end;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('XLSExport',
  [ TXLSExportFile,
    TXLSExportDBGrid,
    TXLSExportStringGrid,
    TXLSExportDataSource
  ]);
end;

end.
