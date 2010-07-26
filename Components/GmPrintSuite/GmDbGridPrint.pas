{******************************************************************************}
{                                                                              }
{                             GmDbGridPrint.pas                                }
{                                                                              }
{           Copyright (c) 2003 Graham Murt  - www.MurtSoft.co.uk               }
{                                                                              }
{   Feel free to e-mail me with any comments, suggestions, bugs or help at:    }
{                                                                              }
{                           graham@murtsoft.co.uk                              }
{                                                                              }
{******************************************************************************}

unit GmDbGridPrint;

interface

uses Windows, GmGridPrint, Db, DbGrids, GmTypes, Classes, GmCanvas, Graphics,
  GmClasses;

{$I GMPS.INC}

const
  DEFAULT_FIXED_ROWS = 1;
  DEFAULT_FIXED_COLS = 0;
  DEFAULT_DBCELL_PADDING = 70;
  DEFAULT_DB_ROWHEIGHT= 7;

type
  TGmDbDrawCellEvent   = procedure (Sender: TObject; Col, Row: Longint;
    ARect: TGmValueRect; ACanvas: TGmCanvas; AField: TField) of object;

  TGmDbGridPrint = class(TGmAbstractGridPrint)
  private
    FDataset: TDataSet;
    FRowCount: integer;
    FTitles: TStringList;
    // events...
    FOnDrawCell: TGmDbDrawCellEvent;
  protected
    function GetCellText(ACol, ARow: integer): string; override;
    function GetColCount: integer; override;
    function GetColWidthInch(ACol: integer): Extended; override;
    function GetDefaultRowHeight(ARow: integer): Extended; override;
    function GetFixedCellColor: TColor; override;
    function GetGrid: TDbGrid;
    function GetRowCount: integer; override;
    function IsFixedCell(ACol, ARow: integer): Boolean; override;
    function OnDrawCellAssigned: Boolean; override;
    procedure CallOnDrawCell(ACol, ARow: integer; ARect: TGmValueRect); override;
    procedure NextRecord(ACurrentRecord: integer); override;
    procedure SetGrid(AGrid: TDbGrid);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure GridToPage(X, Y, AWidth: Extended; Measurement: TGmMeasurement); override;
  published
    property Grid: TDbGrid read GetGrid write SetGrid;
    property OnDrawCell: TGmDbDrawCellEvent read FOnDrawCell write FOnDrawCell;
  end;

implementation

uses SysUtils, GmErrors, GmFuncs, GmConst, Forms;


{ TGmDbGridPrint }

constructor TGmDbGridPrint.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitles := TStringList.Create;
end;

destructor TGmDbGridPrint.Destroy;
begin
  FTitles.Free;
  inherited Destroy;
end;

function TGmDbGridPrint.GetCellText(ACol, ARow: integer): string;
begin
  if ARow = 0 then
    Result := FTitles[ACol]
  else
  if not FDataset.Fields[ACol].IsBlob then
    Result := FDataset.Fields[ACol].AsString
  else
    Result := FDataset.Fields[ACol].DisplayText;
end;

function TGmDbGridPrint.GetColCount: integer;
begin
  Result :=  Grid.Columns.Count;
end;

function TGmDbGridPrint.GetColWidthInch(ACol: integer): Extended;
begin
  Result := Grid.Columns[ACol].Width / Screen.PixelsPerInch;
end;

function TGmDbGridPrint.GetDefaultRowHeight(ARow: integer): Extended;
begin
  Result := DEFAULT_DB_ROWHEIGHT / 25.4;
end;

function TGmDbGridPrint.GetFixedCellColor: TColor;
begin
  Result := Grid.FixedColor;
end;

function TGmDbGridPrint.GetGrid: TDbGrid;
begin
  Result := TDbGrid(FGrid);
end;

function TGmDbGridPrint.GetRowCount: integer;
begin
  if FRowCount = -1 then
  begin
    Result := FDataset.RecordCount+1;
    FRowCount := Result;
  end
  else
    Result := FRowCount;
end;

procedure TGmDbGridPrint.GridToPage(X, Y, AWidth: Extended; Measurement: TGmMeasurement);
var
  ICount: integer;
begin
  FRowCount := -1;
  FDataset := Grid.DataSource.DataSet;
  FTitles.Clear;
  for ICount := 0 to Grid.Columns.Count-1 do
    FTitles.Add(Grid.Columns[ICount].Title.Caption);
  FDataset.DisableControls;
  inherited GridToPage(X, Y, AWidth, Measurement);
  FDataset.EnableControls;
end;

function TGmDbGridPrint.IsFixedCell(ACol, ARow: integer): Boolean;
begin
  Result := ARow = 0;
end;

function TGmDbGridPrint.OnDrawCellAssigned: Boolean;
begin
  Result := Assigned(FOnDrawCell);
end;

procedure TGmDbGridPrint.CallOnDrawCell(ACol, ARow: integer; ARect: TGmValueRect);
begin
  if Assigned(FOnDrawCell) then FOnDrawCell(Self, ACol, ARow, ARect,
    Preview.Canvas, FDataset.Fields[ACol]);
end;

procedure TGmDbGridPrint.NextRecord(ACurrentRecord: integer);
begin
  if ACurrentRecord <> 0 then FDataset.FindNext;
end;

procedure TGmDbGridPrint.SetGrid(AGrid: TDbGrid);
begin
  FGrid := AGrid;
end;

end.
