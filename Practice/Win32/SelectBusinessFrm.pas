unit SelectBusinessFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, PracticeLedgerObj, CashbookMigrationRestData,
  Globals, OSFont;

type
  TSortOrder = (soAcsending, soDescending);
  TSelectBusinessForm = class(TForm)
    pnlGridContainer: TPanel;
    sgClients: TStringGrid;
    pnlSearch: TPanel;
    Shape1: TShape;
    lblFind: TLabel;
    ShapeBorderTop: TShape;
    edtSearch: TEdit;
    pnlBottom: TPanel;
    ShapeBorder: TShape;
    btnYes: TButton;
    btnNo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure sgClientsDblClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure sgClientsMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgClientsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure btnNoClick(Sender: TObject);
    procedure edtSearchChange(Sender: TObject);
  private
    { Private declarations }
    FCurrentCol : Integer;
    FCurrentRow : Integer;
    FSelectedBusinessID : string;
    FSelectedBusinessName : string;
    procedure LoadBusinesses(aFilterBusiness: string);
    procedure ClearHeaderTriangle(ACol, ARow : Integer);
  public
    { Public declarations }
    property SelectedBusinessID : string read FSelectedBusinessID write FSelectedBusinessID;
    property SelectedBusinessName : string read FSelectedBusinessName write FSelectedBusinessName;
  end;

var
  SelectBusinessForm: TSelectBusinessForm;
  SortColumn : Integer;
  SortDirection : TSortOrder;

implementation

{$R *.dfm}

{ TSelectBusinessForm }

function BusinessCompare(Item1, Item2 : pointer):integer;
var
  FirstValue , SecondValue : string;
begin
  {Sort Compare function used to sort the contentful list}
  if SortColumn = 0 then
  begin
    FirstValue := TBusinessData(Item1).Name;
    SecondValue := TBusinessData(Item2).Name;
  end
  else if SortColumn = 1 then
  begin
    FirstValue := TBusinessData(Item1).ClientCode;
    SecondValue := TBusinessData(Item2).ClientCode;
  end
  else if SortColumn = 2 then
  begin
    FirstValue := TBusinessData(Item1).ABN;
    SecondValue := TBusinessData(Item2).ABN;
  end
  else if SortColumn = 3 then
  begin
    FirstValue := TBusinessData(Item1).IRD;
    SecondValue := TBusinessData(Item2).IRD;
  end;

  if SortDirection = soAcsending then
    Result := CompareStr(FirstValue, SecondValue)
  else
    Result := CompareStr(SecondValue,FirstValue);
end;

procedure TSelectBusinessForm.btnNoClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TSelectBusinessForm.btnYesClick(Sender: TObject);
var
  tmpBusiness: TBusinessData;
begin
  if (Assigned(PracticeLedger) and
    Assigned(PracticeLedger.Businesses) and
    (PracticeLedger.Businesses.Count > 0)) then
  begin
    if Trim(sgClients.Cells[sgClients.Col, sgClients.Row]) <> '' then
    begin
      tmpBusiness:= TBusinessData(sgClients.Objects[sgClients.Col, sgClients.Row]);
      if Assigned(tmpBusiness) then
      begin
        FSelectedBusinessID := tmpBusiness.ID;
        FSelectedBusinessName := tmpBusiness.Name;

        ModalResult := mrOk;
      end;
    end;
  end;
end;

procedure TSelectBusinessForm.ClearHeaderTriangle(ACol, ARow: Integer);
var
  Rect : TRect;
begin
  sgClients.Canvas.Brush.Color := clBtnFace;
  sgClients.Canvas.Pen.Color := clBlack;
  Rect := sgClients.CellRect(ACol, ARow);
  sgClients.Canvas.FillRect(Rect);
  sgClients.Canvas.Font.Color := clBlack;
  sgClients.Canvas.TextRect(Rect,Rect.Left + 1,Rect.Top + 2,sgClients.Cells[ACol,ARow]);
end;

procedure TSelectBusinessForm.edtSearchChange(Sender: TObject);
begin
  LoadBusinesses(edtSearch.Text);
end;

procedure TSelectBusinessForm.FormCreate(Sender: TObject);
begin
  FSelectedBusinessID := '';
  FSelectedBusinessName := '';
  SortColumn := 0;
  SortDirection := soAcsending;
end;

procedure TSelectBusinessForm.FormShow(Sender: TObject);
begin
  if not Assigned(PracticeLedger.Businesses) then
    Exit;

  if PracticeLedger.Businesses.Count = 0 then
    ModalResult := mrCancel;

  sgClients.Cells[0,0] := ' Client Name';
  sgClients.Cells[1,0] := ' Client Code';
  sgClients.Cells[2,0] := ' ABN';
  sgClients.Cells[3,0] := ' IRD';

  edtSearch.Text := '';
  PracticeLedger.Businesses.Sort(BusinessCompare);
  LoadBusinesses('');
end;

procedure TSelectBusinessForm.LoadBusinesses(aFilterBusiness: string);
var
  i , Index, Row: Integer;
  NeedFund : Boolean;
  Business : TBusinessData;
begin
  // set row count and clear the first row. keep heading
  sgClients.RowCount := 2;
  sgClients.Cells[0, 1] := '';
  sgClients.Cells[1, 1] := '';
  sgClients.Cells[2, 1] := '';
  sgClients.Cells[3, 1] := '';

  aFilterBusiness := UpperCase(aFilterBusiness);
  Row := 1;
  Index := 1;

  if not Assigned(PracticeLedger.Businesses) then
    Exit;

  if PracticeLedger.Businesses.Count = 0 then
    ModalResult := mrCancel;

  for i := 0 to PracticeLedger.Businesses.Count - 1 do
  begin
    Business := PracticeLedger.Businesses.GetItem(i);
    if Assigned(Business) then
    begin
      NeedFund := True;
      if Trim(aFilterBusiness) <> '' then
      begin
        NeedFund := False;
        if ((Pos(aFilterBusiness, UpperCase(Business.ID)) > 0) or
            (Pos(aFilterBusiness, UpperCase(Business.Name)) > 0) or
            (Pos(aFilterBusiness, UpperCase(Business.IRD)) > 0) or
            (Pos(aFilterBusiness, UpperCase(Business.ClientCode)) > 0) or
            (Pos(aFilterBusiness, UpperCase(Business.ABN)) > 0)) then
          NeedFund := True;
      end;

      if NeedFund then
      begin
        if Business.ID = MyClient.clExtra.cemyMYOBClientIDSelected then
          Index := Row;

        sgClients.Cells[0,Row] := Business.Name;
        sgClients.Cells[1,Row] := Business.ClientCode;
        sgClients.Cells[2,Row] := Business.ABN;
        sgClients.Cells[3,Row] := Business.IRD;

        sgClients.Objects[0,Row] := Business;

        Inc(Row);
        sgClients.RowCount := sgClients.RowCount + 1;
      end;
    end;
  end;
  //To remove the extra row added
  if (PracticeLedger.Businesses.Count > 0) and (sgClients.RowCount > 2) then
    sgClients.RowCount := sgClients.RowCount - 1;

  sgClients.Row := Index;
end;

procedure TSelectBusinessForm.sgClientsDblClick(Sender: TObject);
begin
  if ((FCurrentRow > 0) and (PracticeLedger.Businesses.Count > 0)  and (sgClients.Row > 0 ))then
    btnYesClick(Sender);
end;

procedure TSelectBusinessForm.sgClientsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  Triangle: array [0..2] of TPoint;
  aCanvas: TCanvas;
const
  Spacing = 10;
  TriSize = 3;
begin
  if ARow = 0 then
  begin
    aCanvas := sgClients.Canvas;
    sgClients.Canvas.Pen.Color := clBlack;
    aCanvas.Brush.Color := clBtnFace;
    aCanvas.FillRect(Rect);
    sgClients.Canvas.Font.Color := clBlack;
    sgClients.Canvas.TextRect(Rect,Rect.Left ,Rect.Top + 2, sgClients.Cells[ACol,ARow]);

    if (ACol = SortColumn) then
    begin
      // Shape the triangle top to bottom
      if SortDirection = soDescending then
      begin
        // Centre
        Triangle[0].X := Rect.Right - Spacing;
        Triangle[0].Y := Rect.Bottom * 2 div 4;
        // left
        Triangle[1].X := Triangle[0].X - TriSize;
        Triangle[1].Y := Rect.Bottom * 3 div 4;
        //right
        Triangle[2].X := Triangle[0].X + TriSize;
        Triangle[2].Y := Rect.Bottom * 3 div 4;
      end
      else
      begin // bottom to top
        // Centre
        Triangle[0].X := Rect.Right - Spacing;
        Triangle[0].Y := Rect.Bottom * 3 div 4;
        // left
        Triangle[1].X := Triangle[0].X - TriSize;
        Triangle[1].Y := Rect.Bottom * 2 div 4;
        //right
        Triangle[2].X := Triangle[0].X + TriSize;
        Triangle[2].Y := Rect.Bottom * 2 div 4;
      end;

      // Draw the triangle
      aCanvas.Pen.Color := clGray;
      aCanvas.Brush.Color := clGray;
      aCanvas.Polygon(Triangle);
      aCanvas.Brush.Color := clBtnFace;
      aCanvas.Pen.Color := clBlack;
      aCanvas.FloodFill(Rect.Left + Rect.Right div 2, Rect.Top - 2 + Rect.Bottom div 2, clGray, fsSurface);
    end;
  end
  else if (gdSelected in State) then
  begin
    sgClients.Canvas.Brush.Color := HyperLinkColor;
    sgClients.Canvas.Font.Color := clWhite;
    sgClients.Canvas.FillRect(Rect);
    sgClients.Canvas.TextRect(Rect,Rect.Left + 2,Rect.Top + 2 ,sgClients.Cells[ACol,ARow]);
  end;
end;

procedure TSelectBusinessForm.sgClientsMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  sgClients.MouseToCell(X, Y, FCurrentCol, FCurrentRow);
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

    if Assigned(PracticeLedger) then
      PracticeLedger.Businesses.Sort(BusinessCompare);

    LoadBusinesses(edtSearch.Text);
    ClearHeaderTriangle(0,0);
    ClearHeaderTriangle(1,0);
    ClearHeaderTriangle(2,0);
    ClearHeaderTriangle(3,0);
    sgClientsDrawCell(Sender, SortColumn, 0 , sgClients.CellRect(SortColumn, 0), [gdFixed]);
  end;
end;

end.
