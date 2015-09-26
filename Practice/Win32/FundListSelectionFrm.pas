unit FundListSelectionFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids_ts, TSGrid, UBGLServer, Grids, OsFont;

type
  TFundSelectionFrm = class(TForm)
    pnlBottom: TPanel;
    ShapeBorder: TShape;
    btnYes: TButton;
    btnNo: TButton;
    sgFunds: TStringGrid;
    procedure btnNoClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FFundListJSON : TFundList_Obj;
    FSelectedFundID: string;
  public
    { Public declarations }
    property FundListJSON: TFundList_Obj read  FFundListJSON write FFundListJSON;
    property SelectedFundID : string read FSelectedFundID write FSelectedFundID;
  end;

var
  FundSelectionFrm: TFundSelectionFrm;

implementation

{$R *.dfm}

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
    tmpFund:= TFundObj(FundListJSON.Items[sgFunds.Row]);
    if Assigned(tmpFund) then    
      FSelectedFundID := tmpFund.FundID;
  end;
  ModalResult := mrOk;
end;

procedure TFundSelectionFrm.FormCreate(Sender: TObject);
begin
  FSelectedFundID := '';
  FFundListJSON := Nil;
end;

procedure TFundSelectionFrm.FormShow(Sender: TObject);
var
  i , Index: Integer;
  tmpFund: TFundObj;
begin
  if not Assigned(FundListJSON) then
    Exit;
    
  sgFunds.RowCount := 2;
  sgFunds.Cells[0,0] := 'Fund Code';
  sgFunds.Cells[1,0] := 'Fund Name';
  sgFunds.Cells[2,0] := 'ABN';
  Index := 0;
  for i := 0 to FundListJSON.Count - 1 do
  begin
    tmpFund:= TFundObj(FundListJSON.Items[i]);
    if ((FSelectedFundID <> '') and (FSelectedFundID =  tmpFund.FundID))  then
      Index := i;
      
    sgFunds.Cells[0,i+1] := tmpFund.FundCode;
    sgFunds.Cells[1,i+1] := tmpFund.FundName;
    sgFunds.Cells[2,i+1] := tmpFund.ABN;
    
    sgFunds.RowCount := sgFunds.RowCount + 1; 
  end;
  sgFunds.RowCount := sgFunds.RowCount - 1;
  sgFunds.Row := Index;
end;

end.
