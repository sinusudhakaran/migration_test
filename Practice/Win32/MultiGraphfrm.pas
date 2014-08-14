unit MultiGraphfrm;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, OvcTCmmn, OvcTable, OvcTCEdt, OvcTCell, OvcTCStr, OvcTCHdr,
  ExtCtrls,rptParams, Chart, Series, StdCtrls,
  TeEngine, TeeFunci, TeeProcs,
  OSFont;

type
  TfrmMultiGraph = class(TForm)
    lblTitle: TLabel;
    sb1: TScrollBox;
    chtResults: TChart;
    chtSales: TChart;
    chtPayments: TChart;
    chtBank: TChart;
    Panel1: TPanel;
    btnPreview: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    lblGST: TLabel;
    btnFile: TButton;
    lblBudget: TLabel;
    Series4: TFastLineSeries;
    Series5: TFastLineSeries;
    Series3: TLineSeries;
    Series2: TLineSeries;
    Series1: TLineSeries;
    FastLineSeries1: TFastLineSeries;
    Series6: TFastLineSeries;
    LineSeries1: TLineSeries;
    LineSeries2: TLineSeries;
    LineSeries3: TLineSeries;
    BInclude: TBevel;
    chBudget: TCheckBox;
    ChGross: TCheckBox;
    chLastYear: TCheckBox;
    ChNett: TCheckBox;
    ChSales: TCheckBox;
    lInclude: TLabel;
    btnEmail: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure chLastYearClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure sb1Resize(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    function TrimToDash(s: string): string;
    { Private declarations }
  public
    { Public declarations }
    BudgetTitle: string;
    Params : TGenRptParameters;
  end;

//******************************************************************************
implementation

uses
  Graphs,
  bkXPThemes,
  ChartFrm,
  ReportDefs,
  Globals,
  CountryUtils;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmMultiGraph.FormCreate(Sender: TObject);
Var
  Country : Byte;
begin
  bkXPThemes.ThemeForm( Self);
  chBudget.Font.Color := clWhite;
  chLastYear.Font.Color := clWhite;      
  lblTitle.Font.Name := Font.Name;
  SetUpHelp;

  Assert( Assigned( MyClient ) );
  Country := MyClient.clFields.clCountry;
  With chtSales.LeftAxis.Title do Caption := Localise( Country, Caption );
  With chtPayments.LeftAxis.Title do Caption := Localise( Country, Caption );
  With chtBank.LeftAxis.Title do Caption := Localise( Country, Caption );
  With chtResults.LeftAxis.Title do Caption := Localise( Country, Caption );
end;
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   lblTitle.Font.Name := Font.Name;
   Self.HelpContext := 0;
   //Components
   chLastYear.Hint  :=
                    'Include Last Year''s figures|' +
                    'Include Last Year''s figures as a line on the graphs';
   chBudget.Hint    :=
                    'Include Budget figures|' +
                    'Include Budget figures as a line on the graphs';
   chSales.Hint  :=
                    'Include Trading Sales figures|' +
                    'Include Trading Sales figures';

   chGross.Hint    :=
                    'Include Trading Gross profit figures|' +
                    'Include Trading Gross profit figures';

   chNett.Hint    :=
                    'Include Trading Operating profit figures|' +
                    'Include Trading Operating profit figures';

   btnPreview.Hint  :=
                    'View the Graphs on screen|' +
                    'View the Graphs on screen prior to printing';
   btnPrint.Hint    :=
                    'Print the Graphs|' +
                    'Print the Graphs directly to the default printer for these Graphs';
end;
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.btnPreviewClick(Sender: TObject);
begin
  PrintMultiGraph(self, rdScreen, [],Params );
end;
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.chLastYearClick(Sender: TObject);
var i: Integer;
begin
   chtSales[S_LAST_YEAR].Active := chLastYear.Checked;
   chtPayments[S_LAST_YEAR].Active := chLastYear.Checked;
   chtBank[S_LAST_YEAR].Active := chLastYear.Checked;

   chtSales[S_BUDGET].Active := chBudget.Checked;
   chtPayments[S_BUDGET].Active := chBudget.Checked;


    for i := 1 to ChtResults.SeriesList.Count -1 do
         ChtResults[i].Active := false;

    if chSales.Checked then begin
         ChtResults[S_THIS_SALES].Active := true;
         ChtResults[S_LAST_SALES].Active := chLastYear.Checked;
         ChtResults[S_BUD_SALES].Active := chBudget.Checked;
    end;

    if chGross.Checked then begin
         ChtResults[S_THIS_GROSS].Active := true;
         ChtResults[S_LAST_GROSS].Active := chLastYear.Checked;
         ChtResults[S_BUD_GROSS].Active := chBudget.Checked;
    end;

    if chNett.Checked then begin
         ChtResults[S_THIS_NET].Active := true;
         ChtResults[S_LAST_NET].Active := chLastYear.Checked;
         ChtResults[S_BUD_NET].Active := chBudget.Checked;
    end;

   if chBudget.Checked then
      lblBudget.Caption := BudgetTitle
   else
      lblBudget.Caption := '';
end;
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
function TfrmMultiGraph.TrimToDash(s: string): string;
var
  DashPos: integer;
begin
  //Trim the string to the right of the dash off
  DashPos := Pos('-',s);
  Result := Copy(s,1,DashPos);
end;




//------------------------------------------------------------------------------
procedure TfrmMultiGraph.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.sb1Resize(Sender: TObject);
const
   Margin = 5;
   MinChartW = 350;
   MinChartH = 230;
var
   Left1, Left2,
   Top1, Top2,
   CHeight, CWidth : integer;
begin
   CWidth := (sb1.Width - (3 * Margin)) div 2;
   CHeight := (sb1.Height - (3 * Margin)) div 2;

   if CWidth < MinChartW then CWidth := MinChartW;
   if CHeight < MinChartH then CHeight := MinChartH;

   Left1 := Margin;
   Left2 := Margin + CWidth + Margin;
   Top1  := Margin;
   Top2  := Margin + CHeight + Margin;

   chtSales.Left := Left1;
   chtSales.Top  := Top1;
   chtSales.Width := CWidth;
   chtSales.Height := CHeight;

   chtPayments.Left := Left2;
   chtPayments.Top  := Top1;
   chtPayments.Width := CWidth;
   chtPayments.Height := CHeight;

   chtResults.Left := Left1;
   chtResults.Top  := Top2;
   chtResults.Width := CWidth;
   chtResults.Height := CHeight;

   chtBank.Left := Left2;
   chtBank.Top  := Top2;
   chtBank.Width := CWidth;
   chtBank.Height := CHeight;
end;
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.btnPrintClick(Sender: TObject);
begin
  PrintMultiGraph(self, rdPrinter, [], Params);
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TfrmMultiGraph.btnEmailClick(Sender: TObject);
begin
  PrintMultiGraph(self, rdEmail, [ffPDF, ffAcclipse], Params);
end;

procedure TfrmMultiGraph.btnFileClick(Sender: TObject);
begin
  PrintMultiGraph(self, rdFile, [ffPDF, ffAcclipse], Params);
end;

end.
