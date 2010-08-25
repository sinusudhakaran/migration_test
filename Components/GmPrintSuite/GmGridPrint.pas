{******************************************************************************}
{                                                                              }
{                              GmGridPrint.pas                                 }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmGridPrint;

interface

  {$I GMPS.INC}

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  GmPreview, GmTypes, grids, GmCanvas, GmClasses;

const
  DEFAULT_CELL_PADDING = 0.025;

type
  ENoGridAssigned = class(Exception);

  TGmDrawRowEvent          = procedure (Sender: TObject; Row: integer) of object;
  TGmDrawCellEvent         = procedure (Sender: TObject; Col, Row: Longint; ARect: TGmValueRect; ACanvas: TGmCanvas) of object;
  TGmFinishGridEvent       = procedure (Sender: TObject; YPos: TGmValue) of object;
  TGmGetCellAlignmentEvent = procedure (Sender: TObject; Col, Row: Longint; var Alignment: TAlignment; var VertAlignment: TGmVertAlignment) of object;
  TGmGetColumnWidthEvent   = procedure (Sender: TObject; Col: Longint; ColWidth: TGmValue) of object;
  TGmGetRowHeightEvent     = procedure (Sender: TObject; Row: Longint; RowHeight: TGmValue) of object;
  TGmGridProgressEvent     = procedure (Sender: TObject; Percent: Extended) of object;

  TGmGridOption   = (gmVertLine, gmHorzLine, gmFixedRowPerPage, gmFixedCells3D, gmGridBorder);
  TGmGridOptions  = set of TGmGridOption;

  TGmDrawBorders = record
    Left: Boolean;
    Top: Boolean;
    Right: Boolean;
    Bottom: Boolean;
  end;

  TGmDecimalList = class(TStringList)
  private
    function GetTotal: Extended;
    function GetValue(AIndex: integer): Extended;
    procedure SetValue(AIndex: integer; Value: Extended);
  public
    procedure AddValue(Value: Extended);
    property Value[index: integer]: Extended read GetValue write SetValue; default;
    property Total: Extended read GetTotal;
  end;

  // *** TGmCustomGridPrint ***

  TGmAbstractGridPrint = class(TGmCustomGridPrint)
  private
    FAutoExpandRows: Boolean;
    FCellPenColor: TColor;
    FColWidths: TGmDecimalList;
    FDefaultCellAlign: TAlignment;
    FDefaultCellVertAlign: TGmVertAlignment;
    FFont: TFont;
    FFixedCellFont: TFont;
    FGridWidth: Extended;
    FGridOptions: TGmGridOptions;
    FMarginBottom: TGmValue;
    FMarginTop: TGmValue;
    FMonochrome: Boolean;
    FPreview: TGmPreview;
    FRowCount: integer;
    FRowHeight: Extended;
    FRowRect: TGmRect;
    FScaleText: Boolean;
    FTempValue: TGmValue;
    FTopLeft: TGmPoint;
    FWidthScale: Extended;
    FWordWrap: Boolean;
    // events...
    FAfterDrawRow: TGmDrawRowEvent;
    FBeforeDrawRow: TGmDrawRowEvent;
    FOnFinishGrid: TGmFinishGridEvent;
    FOnGetCellAlignment: TGmGetCellAlignmentEvent;
    FOnGetColWidth: TGmGetColumnWidthEvent;
    FOnGetRowHeight: TGmGetRowHeightEvent;
    FOnGridProgress: TGmGridProgressEvent;
    FOnNewPage: TGmNewPageEvent;
    function GetCutOffInch: Extended;
    procedure DrawCellBackground(ARect: TGmValueRect; ACol, ARow: integer);
    procedure DrawCellText(ARect: TGmValueRect; ACol, ARow: integer);
    procedure SetFont(AFont: TFont);
    procedure SetFixedFont(AFont: TFont);
    procedure SetPreview(APreview: TGmPreview);
  protected
    FCurrentXY: TGmPoint;
    FGrid: TCustomGrid;
    function GetCellText(ACol, ARow: integer): string; virtual; abstract;
    function GetColCount: integer; virtual; abstract;
    function GetColWidth(index: integer; Measurement: TGmMeasurement): Extended;
    function GetColWidthInch(ACol: integer): Extended; virtual; abstract;
    function GetDefaultRowHeight(ARow: integer): Extended; virtual; abstract;
    function GetFixedCellColor: TColor; virtual; abstract;
    function GetGrid: TCustomGrid;
    function GetRowCount: integer; virtual; abstract;
    function GetRowHeightInch(ARow: integer): Extended; virtual;
    function GetScreenGridWidth: TGmValue;
    function IsFixedCell(ACol, ARow: integer): Boolean; virtual; abstract;
    procedure NextRecord(ACurrentRecord: integer); virtual;
    function OnDrawCellAssigned: Boolean; virtual; abstract;
    procedure BuildColWidths; virtual;
    procedure CallOnDrawCell(ACol, ARow: integer; ARect: TGmValueRect); virtual; abstract;
    procedure CloseRow(ARect: TGmRect); virtual;
    procedure DrawRow(ARect: TGmRect; ARow: integer); virtual;
    procedure SetCustomGrid(AGrid: TCustomGrid);
    procedure Notification(AComponent: TComponent; Operation: TOperation);  override;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    procedure DefaultDrawCell(ARect: TGmValueRect; ACol, ARow: integer);
    procedure GridToPage(X, Y, AWidth: Extended; Measurement: TGmMeasurement); virtual;
    procedure NewPage; virtual;
    property AutoExpandRows: Boolean read FAutoExpandRows write FAutoExpandRows default True;
    property BottomMargin: TGmValue read FMarginBottom;
    property ColWidthInch[ACol: integer]: Extended read GetColWidthInch;
    property TopMargin: TGmValue read FMarginTop;
  published
    property CellPenColor: TColor read FCellPenColor write FCellPenColor default clBlack;
    property DefaultCellAlignment: TAlignment read FDefaultCellAlign write FDefaultCellAlign default taLeftJustify;
    property DefaultCellVertAlignment: TGmVertAlignment read FDefaultCellVertAlign write FDefaultCellVertAlign default gmTop;
    property Font: TFont read FFont write SetFont;
    property FixedCellFont: TFont read FFixedCellFont write SetFixedFont;
    property GridOptions: TGmGridOptions read FGridOptions write FGridOptions
      default [gmVertLine, gmHorzLine, gmFixedRowPerPage, gmGridBorder];
    property Monochrome: Boolean read FMonochrome write FMonochrome default False;
    property Preview: TGmPreview read FPreview write SetPreview;
    property ScaleText: Boolean read FScaleText write FScaleText default False;
    property WordWrap: Boolean read FWordWrap write FWordWrap default False;
    // events...
    property AfterDrawRow: TGmDrawRowEvent read FAfterDrawRow write FAfterDrawRow;
    property BeforeDrawRow: TGmDrawRowEvent read FBeforeDrawRow write FBeforeDrawRow;
    property OnDrawProgress: TGmGridProgressEvent read FOnGridProgress write FOnGridProgress;
    property OnFinishGrid: TGmFinishGridEvent read FOnFinishGrid write FOnFinishGrid;
    property OnGetCellAlignment: TGmGetCellAlignmentEvent read FOnGetCellAlignment write FOnGetCellAlignment;
    property OnGetColWidth: TGmGetColumnWidthEvent read FOnGetColWidth write FOnGetColWidth;
    property OnGetRowHeight: TGmGetRowHeightEvent read FOnGetRowHeight write FOnGetRowHeight;
    property OnGridNewPage: TGmNewPageEvent read FOnNewPage write FOnNewPage;
  end;

  // *** TGmGridPrint ***

  TGmGridPrint = class(TGmAbstractGridPrint)
  private
    // events...
    FOnDrawCell: TGmDrawCellEvent;
    function GetGrid: TStringGrid;
    procedure SetGrid(AGrid: TStringGrid);
  protected
    function GetCellText(ACol, ARow: integer): string; override;
    function GetColCount: integer; override;
    function GetColWidthInch(ACol: integer): Extended; override;
    function GetDefaultRowHeight(ARow: integer): Extended; override;
    function GetFixedCellColor: TColor; override;
    function GetRowCount: integer; override;
    //function GetRowHeightInch(ARow: integer): Extended; override;
    function IsFixedCell(ACol, ARow: integer): Boolean; override;
    function OnDrawCellAssigned: Boolean; override;
    procedure CallOnDrawCell(ACol, ARow: integer; ARect: TGmValueRect); override;
  published
    property Grid: TStringGrid read GetGrid write SetGrid;
    property OnDrawCell: TGmDrawCellEvent read FOnDrawCell write FOnDrawCell;
  end;

implementation

uses GmErrors, Dialogs, GmConst, GmObjects, GmFuncs;

//------------------------------------------------------------------------------

procedure TGmDecimalList.AddValue(Value: Extended);
begin
  Add(FloatToStr(Value));
end;

function TGmDecimalList.GetTotal: Extended;
var
  ICount: integer;
begin
  Result := 0;
  for ICount := 0 to Count-1 do
    Result := Result + Value[ICount];
end;

function TGmDecimalList.GetValue(AIndex: integer): Extended;
begin
  Result := StrToFloat(Strings[AIndex]);
end;

procedure TGmDecimalList.SetValue(AIndex: integer; Value: Extended);
begin
  Strings[AIndex] := FloatToStr(Value);
end;

//------------------------------------------------------------------------------

// *** TGmCustomGridPrint ***

constructor TGmAbstractGridPrint.Create(Owner: TComponent);
begin
  inherited Create(Owner);
  FColWidths := TGmDecimalList.Create;
  FTempValue := TGmValue.Create;
  FMarginBottom := TGmValue.Create;
  FMarginTop := TGmValue.Create;
  FFont := TFont.Create;
  FFixedCellFont := TFont.Create;
  FFont.Name := DEFAULT_FONT;
  FFont.Size := 8;
  FFixedCellFont.Assign(FFont);
  FCellPenColor := clBlack;
  FDefaultCellAlign := taLeftJustify;
  FDefaultCellVertAlign := gmTop;
  FGridOptions := [gmVertLine, gmHorzLine, gmFixedRowPerPage, gmGridBorder];
  FMonochrome := False;
  FScaleText := False;
  FWordWrap := False;
  FAutoExpandRows := True;
end;

destructor TGmAbstractGridPrint.Destroy;
begin
  FColWidths.Free;
  FTempValue.Free;
  FMarginBottom.Free;
  FMarginTop.Free;
  FFont.Free;
  FFixedCellFont.Free;
  inherited Destroy;
end;

procedure TGmAbstractGridPrint.DefaultDrawCell(ARect: TGmValueRect; ACol, ARow: integer);
begin
  DrawCellBackground(ARect, ACol, ARow);
  DrawCellText(ARect, ACol, ARow);
end;

procedure TGmAbstractGridPrint.GridToPage(X, Y, AWidth: Extended; Measurement: TGmMeasurement);
var
  ICount: integer;
  AGmValue: TGmValue;
begin
  if not Assigned(FPreview) then
  begin
    ShowGmError(Self, GM_NO_PREVIEW_ASSIGNED);
    Exit;
  end;
  if not Assigned(FGrid) then
  begin
    ShowGmError(Self, GM_NO_GRID_ASSIGNED);
    Exit;
  end;
  FRowCount := -1;

  if AWidth <> 0 then
    FWidthScale := AWidth / GetScreenGridWidth.AsGmValue[Measurement]
  else
    FWidthScale := 1;

  Preview.BeginUpdate;
  BuildColWidths;

  FGridWidth := FColWidths.Total;
  FCurrentXY.X := ConvertValue(X, Measurement, gmInches);
  FCurrentXY.Y := ConvertValue(Y, Measurement, gmInches);
  FTopLeft := FCurrentXY;
  FMarginTop.AsInches := FTopLeft.Y;

  // itterate through grid rows...
  FPreview.Canvas.Font.Assign(FFont);
  for ICount := 0 to GetRowCount-1 do
  begin
    FRowHeight := GetRowHeightInch(ICount);
    if Assigned(FBeforeDrawRow) then FBeforeDrawRow(Self, ICount);
    if FCurrentXY.Y + FRowHeight > GetCutOffInch then NewPage;
    FRowRect := GmRect(FCurrentXY.X,
                       FCurrentXY.Y,
                       FCurrentXY.X + FGridWidth,
                       FCurrentXY.Y + FRowHeight);
    DrawRow(FRowRect, ICount);

  //if fWordWrap then
  //ShowMessage('yes')
  //else
  //ShowMessage('no');

    FCurrentXY.Y := FCurrentXY.Y + FRowHeight;
    if Assigned(FAfterDrawRow) then FAfterDrawRow(Self, ICount);
    if Assigned(FOnGridProgress) then FOnGridProgress(Self, ((ICount+1) / GetRowCount) * 100);
    NextRecord(ICount);
  end;
  if Assigned(FOnFinishGrid) then
  begin
    AGmValue := TGmValue.CreateValue(FCurrentXY.Y, gmInches);
    try
      FOnFinishGrid(Self, AGmValue);
    finally
      AGmValue.Free;
    end;
  end;
  CloseRow(FRowRect);
  Preview.EndUpdate;
end;

procedure TGmAbstractGridPrint.NewPage;
var
  RowRect: TGmRect;
  AHeight: Extended;
begin
  CloseRow(FRowRect);
  if FPreview.CurrentPageNum = FPreview.NumPages then
    FPreview.NewPage
  else
    FPreview.NextPage;
  if Assigned(FOnNewPage) then FOnNewPage(Self, FMarginTop, FMarginBottom);
  FCurrentXY.X := FTopLeft.X;
  FCurrentXY.Y := FMarginTop.AsInches;
  FTopLeft := FCurrentXY;
  AHeight := GetRowHeightInch(0);
  RowRect := GmRect(FCurrentXY.X,
                    FCurrentXY.Y,
                    FCurrentXY.X + FGridWidth,
                    FCurrentXY.Y + AHeight);
  DrawRow(RowRect, 0);
  FCurrentXY.Y := FCurrentXY.Y + AHeight;
end;

function TGmAbstractGridPrint.GetCutOffInch: Extended;
var
  AsInches: TGmSize;
begin
  AsInches := FPreview.GetPageSize(gmInches);
  Result := AsInches.Height - (FMarginBottom.AsInches + FPreview.Footer.Height[gmInches]);
end;

procedure TGmAbstractGridPrint.DrawCellBackground(ARect: TGmValueRect; ACol, ARow: integer);
begin
  if FMonochrome then Exit;
  if (FPreview.Canvas.Brush.Color = clWhite) or (FPreview.Brush.Style = bsClear) then Exit;
  FPreview.Canvas.Pen.Style := psClear;
  FPreview.Canvas.Rectangle(ARect.AsInchRect.Left,
  													ARect.AsInchRect.Top,
                            ARect.AsInchRect.Right,
                            ARect.AsInchRect.Bottom,
                            gmInches);
  //(FPreview.Canvas.LastObject as TGmRectangleShape).RectType := gmPolygon;
end;

procedure TGmAbstractGridPrint.DrawCellText(ARect: TGmValueRect; ACol, ARow: integer);
var
  AAlign: TAlignment;
  AVertAlign: TGmVertAlignment;
  AText: string;
begin
  AText := GetCellText(ACol, ARow);
  if AText = '' then Exit;
  AAlign := FDefaultCellAlign;
  AVertAlign := FDefaultCellVertAlign;
  if Assigned(FOnGetCellAlignment) then
    FOnGetCellAlignment(Self, ACol, ARow, AAlign, AVertAlign);
  FPreview.Canvas.Pen.Style := psClear;
  FPreview.Canvas.Brush.Style := bsClear;
  FPreview.Canvas.WordWrap := False;
  FPreview.Canvas.TextBoxExt(ARect.Left.AsInches,
                            ARect.Top.AsInches,
                            ARect.Right.AsInches,
                            ARect.Bottom.AsInches,
                            DEFAULT_CELL_PADDING,
                            AText,
                            AAlign,
                            AVertAlign,
                            gmInches);
  TGmTextBoxObject(FPreview.Canvas.LastObject).WordBreak := FWordWrap;
  TGmTextBoxObject(FPreview.Canvas.LastObject).ClipText := True;
end;

procedure TGmAbstractGridPrint.SetFont(AFont: TFont);
begin
  FFont.Assign(AFont);
end;

procedure TGmAbstractGridPrint.SetFixedFont(AFont: TFont);
begin
  FFixedCellFont.Assign(AFont);
end;

procedure TGmAbstractGridPrint.SetPreview(APreview: TGmPreview);
begin
  FPreview := APreview;
  if Assigned(FPreview) then
    FMarginBottom.AsInches := (FPreview.Footer.Height[gmInches] + FPreview.Margins.Bottom.AsInches);
end;

function TGmAbstractGridPrint.GetColWidth(index: integer; Measurement: TGmMeasurement): Extended;
begin
  Result := ConvertValue(FColWidths[index], gmInches, Measurement);
end;

function TGmAbstractGridPrint.GetGrid: TCustomGrid;
begin
  Result := FGrid;
end;

function TGmAbstractGridPrint.GetScreenGridWidth: TGmValue;
var
  ICount: integer;
begin
  Result := FTempValue;
  Result.AsInches := 0;
  for ICount := 0 to GetColCount-1 do
    Result.AsInches := Result.AsInches + GetColWidthInch(ICount);
end;

procedure TGmAbstractGridPrint.NextRecord(ACurrentRecord: integer);
begin
  // used in decendant classes...
end;

function TGmAbstractGridPrint.GetRowHeightInch(ARow: integer): Extended;
var
  ARowHeight: TGmValue;
  ICount: integer;
  ACellText: string;
  AColWidth: Extended;
begin
  Result := GetDefaultRowHeight(ARow);
  if Assigned(FOnGetRowHeight) then
  begin
    ARowHeight := TGmValue.Create;
    try
      ARowHeight.AsInches := Result;
      FOnGetRowHeight(Self, ARow, ARowHeight);
      Result := ARowHeight.AsInches;
    finally
      ARowHeight.Free;
    end;
  end;
  if FAutoExpandRows then
  begin
    for ICount := 0 to GetColCount-1 do
    begin
      AColWidth := GetColWidth(ICount, gmInches);
      ACellText := GetCellText(ICount, ARow);
      
      FPreview.Canvas.WordWrap := FWordWrap;

      if ACellText <> '' then
        Result := MaxFloat(FPreview.Canvas.TextBoxHeight(AColWidth, ACellText, gmInches), Result);
    end;
  end;
end;

procedure TGmAbstractGridPrint.BuildColWidths;
var
  ICount: integer;
  AWidth: TGmValue;
begin
  FColWidths.Clear;
  AWidth := TGmValue.Create;
  try
    for ICount := 0 to GetColCount-1 do
    begin
      AWidth.AsInches := GetColWidthInch(ICount) * FWidthScale;
      if Assigned(FOnGetColWidth) then FOnGetColWidth(Self, ICount, AWidth);
      FColWidths.AddValue(AWidth.AsInches);
    end;
  finally
    AWidth.Free;
  end;
end;

procedure TGmAbstractGridPrint.CloseRow(ARect: TGmRect);
begin
  if gmGridBorder in FGridOptions then
  begin
    FPreview.Canvas.Brush.Style := bsClear;
    FPreview.Canvas.Rectangle(FTopLeft.X, FTopLeft.Y, ARect.Right, ARect.Bottom, gmInches);
    //(FPreview.Canvas.LastObject as TGmRectangleShape).RectType := gmPolyline;
  end;
end;

procedure TGmAbstractGridPrint.DrawRow(ARect: TGmRect; ARow: integer);
var
  ICount: integer;
  XPos: Extended;
  CellWidth: Extended;
  CellValueRect: TGmValueRect;
begin
  XPos := ARect.Left;
  CellValueRect := TGmValueRect.Create;
  try
    for ICount := 0 to GetColCount-1 do
    begin
      CellWidth := FColWidths[ICount];
      CellValueRect.AsInchRect := GmRect(XPos, ARect.Top, XPos + CellWidth, ARect.Bottom);
      if IsFixedCell(ICount, ARow) then
      begin
        FPreview.Canvas.Font.Assign(FFixedCellFont);
        FPreview.Canvas.Brush.Color := GetFixedCellColor;
      end
      else
      begin
        FPreview.Canvas.Brush.Color := clWhite;
        FPreview.Canvas.Font.Assign(FFont);
      end;
      if FScaleText then
      begin
      //  if FWidthScale < 1 then
       //   FPreview.Canvas.Font.Size := Round(FPreview.Canvas.Font.Size * FWidthScale);
      end;
      if OnDrawCellAssigned then
        CallOnDrawCell(ICount, ARow, CellValueRect)
      else
        DefaultDrawCell(CellValueRect, ICount, ARow);
      XPos := XPos + CellWidth;
    end;

    // draw grid lines...
    XPos := ARect.Left;
    FPreview.Canvas.Pen.Style := psSolid;
    FPreview.Canvas.Pen.Color := FCellPenColor;
    if (gmHorzLine in FGridOptions) and (ARow > 0) then
      FPreview.Canvas.Line(ARect.Left, ARect.Top, ARect.Right, ARect.Top, gmInches);
    for ICount := 0 to GetColCount-1 do
    begin
      CellWidth := FColWidths[ICount];
      CellValueRect.AsInchRect := GmRect(XPos, ARect.Top, XPos + CellWidth, ARect.Bottom);
      if (gmVertLine in FGridOptions) and (ICount > 0) then
        FPreview.Canvas.Line(XPos, ARect.Top, XPos, ARect.Bottom, gmInches);
      XPos := XPos + CellWidth;
    end;
  finally
    CellValueRect.Free;
  end;
end;

procedure TGmAbstractGridPrint.SetCustomGrid(AGrid: TCustomGrid);
begin
  FGrid := AGrid;
end;

procedure TGmAbstractGridPrint.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FPreview) then
    FPreview := nil;
  if (Operation = opRemove) and (AComponent = FGrid) then
    FGrid := nil;
end;

//------------------------------------------------------------------------------

function TGmGridPrint.GetGrid: TStringGrid;
begin
  Result := TStringGrid(FGrid);
end;

procedure TGmGridPrint.SetGrid(AGrid: TStringGrid);
begin
  inherited SetCustomGrid(AGrid);
end;

function TGmGridPrint.GetCellText(ACol, ARow: integer): string;
begin
  Result := Grid.Cells[ACol, ARow];
end;

function TGmGridPrint.GetColCount: integer;
begin
  Result := Grid.ColCount;
end;

function TGmGridPrint.GetColWidthInch(ACol: integer): Extended;
begin
  Result := Grid.ColWidths[ACol] / Screen.PixelsPerInch;
end;

function TGmGridPrint.GetDefaultRowHeight(ARow: integer): Extended;
begin
  Result := Grid.RowHeights[ARow] / Screen.PixelsPerInch;
end;

function TGmGridPrint.GetFixedCellColor: TColor;
begin
  Result := Grid.FixedColor;
end;

function TGmGridPrint.GetRowCount: integer;
begin
  if FRowCount = -1 then
    FRowCount := Grid.RowCount;
  Result := FRowCount;
end;

function TGmGridPrint.IsFixedCell(ACol, ARow: integer): Boolean;
begin
  Result := (ACol < Grid.FixedCols) or (ARow < Grid.FixedRows);
end;

function TGmGridPrint.OnDrawCellAssigned: Boolean;
begin
  Result := Assigned(FOnDrawCell);
end;

procedure TGmGridPrint.CallOnDrawCell(ACol, ARow: integer; ARect: TGmValueRect);
begin
  if Assigned(FOnDrawCell) then FOnDrawCell(Self, ACol, ARow, ARect, FPreview.Canvas);
end;

end.
