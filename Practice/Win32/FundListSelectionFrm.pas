unit FundListSelectionFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids_ts, TSGrid, UBGLServer, Grids, OsFont,
  ovcbase, ovctcmmn, ovctable, ovctcedt, ovctcell, ovctcstr, ovctchdr;

type
  TSortOrder = (soAcsending, soDescending);
  TFundSelectionFrm = class(TForm)
    pnlBottom: TPanel;
    ShapeBorder: TShape;
    btnYes: TButton;
    btnNo: TButton;
    pnlSearch: TPanel;
    Shape1: TShape;
    Label2: TLabel;
    edtSearch: TEdit;
    ShapeBorderTop: TShape;
    pnlGridContainer: TPanel;
    sgFunds: TStringGrid;
    procedure btnNoClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgFundsDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure edtSearchChange(Sender: TObject);
    procedure sgFundsMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure sgFundsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
    FFundListJSON : TFundList_Obj;
    FSelectedFundID: string;
    FSelectedFundName : string;
    FCurrentCol : Integer;
    FCurrentRow : Integer;
    procedure LoadFunds(aFilterFund : string);
  public
    { Public declarations }
    property FundListJSON: TFundList_Obj read  FFundListJSON write FFundListJSON;
    property SelectedFundID : string read FSelectedFundID write FSelectedFundID;
    property SelectedFundName : string read FSelectedFundName write FSelectedFundName;
  end;

var
  FundSelectionFrm: TFundSelectionFrm;
  SortColumn : Integer;
  SortDirection : TSortOrder;

implementation

{$R *.dfm}

{Sort Compare function used to sort the contentful list}
function CompareFunds(Item1, Item2 : Pointer):Integer;
var
  FirstValue , SecondValue : string;
begin
  if SortColumn = 0 then
  begin
    FirstValue := TFundObj(Item1).FundCode;
    SecondValue := TFundObj(Item2).FundCode;
  end
  else if SortColumn = 1 then
  begin
    FirstValue := TFundObj(Item1).FundName;
    SecondValue := TFundObj(Item2).FundName;
  end
  else if SortColumn = 2 then
  begin
    FirstValue := TFundObj(Item1).ABN;
    SecondValue := TFundObj(Item2).ABN;
  end;

  if SortDirection = soAcsending then
    Result := CompareStr(FirstValue, SecondValue)
  else
    Result := CompareStr(SecondValue,FirstValue);
end;

procedure TFundSelectionFrm.btnNoClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TFundSelectionFrm.btnYesClick(Sender: TObject);
var
  tmpFund: TFundObj;
begin
  if FundListJSON.Count > 0 then
  begin
    tmpFund:= TFundObj(FundListJSON.Items[sgFunds.Row-1]);
    if Assigned(tmpFund) then
    begin
      FSelectedFundID := tmpFund.FundID;
      FSelectedFundName := tmpFund.FundName;
    end;
  end;
  ModalResult := mrOk;
end;

procedure TFundSelectionFrm.edtSearchChange(Sender: TObject);
begin
  LoadFunds(edtSearch.Text);
end;

procedure TFundSelectionFrm.FormCreate(Sender: TObject);
begin
  FSelectedFundID := '';
  FFundListJSON := Nil;
  SortColumn := 0;
  SortDirection := soAcsending;
end;

procedure TFundSelectionFrm.FormShow(Sender: TObject);
begin
  if not Assigned(FundListJSON) then
    Exit;

  sgFunds.Cells[0,0] := 'Fund Code';
  sgFunds.Cells[1,0] := 'Fund Name';
  sgFunds.Cells[2,0] := 'ABN';
  edtSearch.Text := '';

  FundListJSON.SortFunction := CompareFunds;
  FundListJSON.SortList;

  LoadFunds('');
end;

procedure TFundSelectionFrm.LoadFunds(aFilterFund:string);
var
  i , Index, Row: Integer;
  tmpFund: TFundObj;
  NeedFund : Boolean;
begin
  sgFunds.RowCount := 2;
  Index := 1;
  Row := 1;
  aFilterFund := UpperCase(aFilterFund);

  for i := 0 to FundListJSON.Count - 1 do
  begin
    tmpFund:= TFundObj(FundListJSON.Items[i]);
    NeedFund := True;
    if Trim(aFilterFund) <> '' then
    begin
      NeedFund := False;
      if ((Pos(aFilterFund, UpperCase(tmpFund.FundCode)) > 0) or
          (Pos(aFilterFund, UpperCase(tmpFund.FundName)) > 0) or
          (Pos(aFilterFund, UpperCase(tmpFund.ABN)) > 0)) then
        NeedFund := True;
    end;

    if NeedFund then
    begin
      if ((FSelectedFundID <> '') and (FSelectedFundID =  tmpFund.FundID))  then
        Index := Row;

      sgFunds.Cells[0,Row] := tmpFund.FundCode;
      sgFunds.Cells[1,Row] := tmpFund.FundName;
      sgFunds.Cells[2,Row] := tmpFund.ABN;

      Inc(Row);
      sgFunds.RowCount := sgFunds.RowCount + 1;
    end;
  end;

  //To remove the extra row added
  if FundListJSON.Count > 0 then
    sgFunds.RowCount := sgFunds.RowCount - 1;

  sgFunds.Row := Index;
end;

procedure TFundSelectionFrm.sgFundsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
begin

  if ARow = 0 then
  begin
    sgFunds.Canvas.Brush.Color := clBtnFace;
    sgFunds.Canvas.FillRect(Rect);
    sgFunds.Canvas.TextRect(Rect,Rect.Left,Rect.Top,sgFunds.Cells[ACol,ARow]);
  end
  else if (gdSelected in State) then
  begin
    sgFunds.Canvas.Brush.Color := HyperLinkColor;
    sgFunds.Canvas.FillRect(Rect);
    sgFunds.Canvas.TextRect(Rect,Rect.Left,Rect.Top,sgFunds.Cells[ACol,ARow]);
  end;
end;

procedure TFundSelectionFrm.sgFundsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  sgFunds.MouseToCell(X, Y, FCurrentCol, FCurrentRow);
  if FCurrentRow = 0 then
  begin
    if SortColumn = FCurrentCol then
    begin
      if SortDirection = soAcsending then
        SortDirection := soDescending
      else
        SortDirection := soAcsending;
    end
    else
      SortDirection := soAcsending;

    SortColumn := FCurrentCol;

    FundListJSON.SortFunction := CompareFunds;
    FundListJSON.SortList;
    LoadFunds(edtSearch.Text);
  end;
end;

procedure TFundSelectionFrm.sgFundsMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  //
  //if FCurrentRow = 0 then
    //sgFunds.Row := 1;
end;

end.
