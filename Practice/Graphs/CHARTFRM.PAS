unit ChartFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, TeeProcs, TeEngine, Chart, Series, StdCtrls, Rptparams, GraphDefs, Reports,
  OSFont, TeeFunci;

type
  TfrmChart = class(TForm)
    Panel1: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    chLastYear: TCheckBox;
    chBudget: TCheckBox;
    Chart1: TChart;
    BInclude: TBevel;
    lInclude: TLabel;
    lblTitle: TLabel;
    lblGST: TLabel;
    btnFile: TButton;
    lblBudget: TLabel;
    Series11: TLineSeries;
    Series3: TLineSeries;
    Series2: TLineSeries;
    Series1: TLineSeries;
    Series4: TLineSeries;
    ChSales: TCheckBox;
    ChNett: TCheckBox;
    ChGross: TCheckBox;
    Series5: TLineSeries;
    Series9: TLineSeries;
    procedure btnPreviewClick(Sender: TObject);
    procedure chLastYearClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
  private
    FTrade: Boolean;
    procedure SetTrade(const Value: Boolean);
    { Private declarations }
  public
    { Public declarations }
    BudgetTitle: string;
    GraphType: GRAPH_LIST_TYPE;
    Params: TGenRptParameters;
    procedure RenderChart( ReportCanvas: TCanvas; ReportRect : TRect);
    property Trade: Boolean read FTrade write SetTrade;
  end;

  const
   S_LABEL          = 0;   SERIES_MIN = 0;
   S_LABEL2         = 1;
   // Most Simple graphs
   S_BUDGET         = 2;
   S_LAST_YEAR      = 3;
   S_THIS_YEAR      = 4;

   // Trading Graphs
   S_THIS_NET       = 4;
   S_THIS_GROSS     = 7;
   S_THIS_SALES     = 10;

   S_LAST_NET       = 3;
   S_LAST_GROSS     = 6;
   S_LAST_SALES     = 9;

   S_BUD_NET        = 2;
   S_BUD_GROSS      = 5;
   S_BUD_SALES      = 8;

   SERIES_MAX = 10;



implementation

{$R *.DFM}

uses
  bkXPThemes,
  Graphs,
  UBatchBase,
  ReportDefs,
  Globals,
  CountryUtils;


{ TfrmChart }

procedure TfrmChart.RenderChart(ReportCanvas: TCanvas; ReportRect: TRect);
begin
  Chart1.PrintPartialCanvas(ReportCanvas,ReportRect);
end;


procedure TfrmChart.SetTrade(const Value: Boolean);
begin
  FTrade := Value;
  chGross.Visible := FTrade;
  chSales.Visible := FTrade;
  chNett.Visible := FTrade;
  if FTrade then
     BInclude.Width := 540
  else
     BInclude.Width := 300;
end;

procedure TfrmChart.btnPreviewClick(Sender: TObject);
begin
  PrintGraphReport(GraphType, Self, rdScreen, [],Params);
end;

procedure TfrmChart.chLastYearClick(Sender: TObject);
var i: Integer;
begin
   if Trade  then begin
      for i := 1 to Chart1.SeriesList.Count -1 do
         Chart1[i].Active := false;

      if chSales.Checked then begin
         Chart1[S_THIS_SALES].Active := true;
         Chart1[S_LAST_SALES].Active := chLastYear.Checked;
         Chart1[S_BUD_SALES].Active := chBudget.Checked;
      end;

      if chGross.Checked then begin
         Chart1[S_THIS_GROSS].Active := true;
         Chart1[S_LAST_GROSS].Active := chLastYear.Checked;
         Chart1[S_BUD_GROSS].Active := chBudget.Checked;
      end;

      if chNett.Checked then begin
         Chart1[S_THIS_NET].Active := true;
         Chart1[S_LAST_NET].Active := chLastYear.Checked;
         Chart1[S_BUD_NET].Active := chBudget.Checked;
      end;

   end else begin
      Chart1[S_LAST_YEAR].Active := chLastYear.Checked;
      Chart1[S_BUDGET].Active := chBudget.Checked;
   end;
   if chBudget.Checked then
      lblBudget.Caption := BudgetTitle
   else
      lblBudget.Caption := '';
end;


procedure TfrmChart.btnCancelClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmChart.btnPrintClick(Sender: TObject);
begin
   PrintGraphReport(GraphType, Self, rdPrinter, [], Params);
end;


procedure TfrmChart.FormCreate(Sender: TObject);
Var
  Country : Byte;
begin
  bkXPThemes.ThemeForm( Self);
  lblGst.Font.Name := Font.Name;
  lblTitle.Font.Name := Font.Name;
  GraphType := GRAPH_TRADING_SALES;
  if Globals.PRACINI_DoubleGraphGridLines then
  begin
    Chart1.LeftAxis.Grid.Width := 2;
    Chart1.LeftAxis.Grid.Style := psDash;
    Chart1.BottomAxis.Grid.Width := 2;
    Chart1.BottomAxis.Grid.Style := psDash;
  end;
  Assert( Assigned( MyClient ) );
  Country := MyClient.clFields.clCountry;
  With Chart1.LeftAxis.Title do Caption := Localise( Country, Caption );
end;

procedure TfrmChart.btnFileClick(Sender: TObject);
begin
    PrintGraphReport(GraphType, Self, rdFile, [ffPDF, ffAcclipse],Params);
end;

end.


