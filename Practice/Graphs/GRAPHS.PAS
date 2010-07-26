unit Graphs;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    Graphs unit

  Written:
  Authors:  Matthew

  Purpose:  Allows graphs to be printed or previewed before print.

  Notes:    The graphs are printed by asking for the bounds of the Detail
            section of the page being printed.  The detail section is the
            available area on the page once the headers and footers have
            been drawn.

            The bitmap for the current graph is then scaled so that it is the
            same size as the detail area, and then drawn onto the canvas.

            Drawback is that the Graph scaling is determined by the dialog (graph) size.
            The size is firstly determined by the screen resolution (shows maximized),
            but can be altered manually....

  }


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   forms, dialogs, ReportDefs,GraphDefs,rptParams, UBatchBase;


   procedure DoGraph(Graph_Type : Graph_List_Type; RptBatch : TReportBase = nil);
   procedure PrintGraphReport(GraphType : GRAPH_LIST_TYPE; Form : TCustomForm;
                              Destination : TReportDest; FileFormats : TFileFormatSet;
                              Params : TGenRptParameters = nil);

   procedure PrintMultiGraph(Form : TCustomForm; Destination : TReportDest;
                             FileFormats : TFileFormatSet;
                             Params : TGenRptParameters = nil);

{$IFDEF SmartBooks}
   Smart books code has been removed for 5.2
{$ENDIF}


//******************************************************************************
implementation

uses
   NewReportUtils,
   ReportImages,
   ReportTypes,
   AccountInfoObj,
   baObj32,
   bkConst,
   bkdefs,
   bkhelp,
   BudObj32,
   CalculateAccountTotals,
   clObj32,
   Chart,
   ChartFrm,
   classes,
   ClDateUtils,
   GenUtils,
   glConst,
   globals,
   GraphHead,
   graphics,
   GraphRepDlg,
   infoMoreFrm,
   moneyDef,
   MultiGraphFrm,
   NewreportObj,
   StDate,
   repcols,
   Windows,
   //prHead,
   ReportToCanvas,
   series,
   SignUtils,
   rptProfit,
   stDateSt,
   sysutils,
   teEngine,
   bkDateUtils;


 const
   t_lastYear = 'Show_Last_Year';
   t_Budget   = 'Show_Budget';
   t_Sales    = 'Show_Sales';
   t_Gross    = 'Show_Gross_Profit';
   t_Nett     = 'Show_Operational_Profit';


type
   ATTypeSet = set of Byte;

type
 TGraphsTLBRec = Record
    This_Year : Array[ 0..12 ] of Money; { 0 = Opening Balance }
    Last_Year : Array[ 0..12 ] of Money; { 0 = Opening Balance }
    Budget    : Array[ 0..12 ] of Money; { 0 = Opening Balance }

    //first and last non zero periods, used to determine which data to show
    TY_FirstPeriod : integer;
    TY_LastPeriod  : integer;
    LY_FirstPeriod : integer;
    LY_LastPeriod  : integer;
    BU_FirstPeriod : integer;
    BU_LastPeriod  : integer;
 end;

type
 TCashflowTotals = class(TObject)
 public
   Income               : TGraphsTLBRec;
   Direct_Expenses      : TGraphsTLBRec;
   Expenses             : TGraphsTLBRec;
   Gross_Profit         : TGraphsTLBRec;
   Net_Profit           : TGraphsTLBRec;
   Gross_Profit_Percent : TGraphsTLBRec;
   Net_Profit_Percent   : TGraphsTLBRec;

   constructor Create;
   procedure   Calculate(For_Division : integer);
   procedure   ZeroTotals;
 end;

 TGraphReport = class(TBKReport)
 private
    Chart : TChart;
    ChartWindowPPI : integer;
    function GetCanvasRE: TRenderToCanvasEng;
 protected
    procedure BKPrint; override;
 public
    constructor Create(rptType: TReportType); override;
    property  CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;
 end;

 TMultiGraphReport = class(TBKReport)
 private
    Chart1 : TChart;
    Chart2 : TChart;
    Chart4 : TChart;
    Chart3 : TChart;
    ChartWindowPPI : integer;
    function GetCanvasRE: TRenderToCanvasEng;
 protected
    procedure BKPrint; override;
 public
    constructor Create(rptType: TReportType); override;
    property  CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;
 end;
         (*
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddJobHeader(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);
var
    HFLine : THeaderFooterLine;
begin
    HFLine := THeaderFooterLine.Create;
    with HFLine do
    begin
      Alignment := Align;
      FontFactor := FF;
      Text := Caption;
      DoNewLine := NewLine;
     end;        { with }
     CurrJob.AddHeader(HFLine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddJobFooter(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);
var
    HFLine : THeaderFooterLine;
begin
    HFLine := THeaderFooterLine.Create;
    with HFLine do
    begin
      Alignment := Align;
      FontFactor := FF;
      Text := Caption;
      DoNewLine := NewLine;
     end;        { with }
     CurrJob.AddFooter(HFLine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
procedure AddCommonHeader(Job : TBKReport);
begin
  if Assigned(AdminSystem) then
  begin
    case AdminSystem.fdFields.fdReport_Date_Type_Style of
      dtDateTime : AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATETIME>',false);
      dtDate : AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATE>',false);
      dtNone : ;
    end;
  end;
  AddJobFooter(Job,jtLeft,0.8,'CODE: '+MyClient.clFields.clCode,true);
  AddJobHeader(Job,jtRight,0.8,'PAGE  <PAGE>',true);
  AddJobHeader(Job,jtCenter,1.2,MyClient.clFields.clName,true);
end;
*)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetNonZeroPeriodMarkers(var Data: TGraphsTLBRec; PeriodNo  : integer);
//These markers are used when graphing the information so that we only show
//data from the first period with non-zero totals to the last period with
//non-zero totals.  Without this the graphs would always have to show a zero
//point for periods without data
begin
  //This Year
  if Data.This_Year[PeriodNo] <> 0 then begin
    if Data.TY_FirstPeriod = 0 then
      Data.TY_FirstPeriod := PeriodNo;
    Data.TY_LastPeriod := PeriodNo;
  end;
  //Last Year
  if Data.Last_Year[PeriodNo] <> 0 then begin
    if Data.LY_FirstPeriod = 0 then
      Data.LY_FirstPeriod := PeriodNo;
    Data.LY_LastPeriod := PeriodNo;
  end;
  //Budget
  if Data.Budget[PeriodNo] <> 0 then begin
    if Data.BU_FirstPeriod = 0 then
      Data.BU_FirstPeriod := PeriodNo;
     Data.BU_LastPeriod := PeriodNo;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGraphLabel(ClientRec: TClient_Rec; Income: TGraphsTLBRec; Periods:
  integer; LastYear: Boolean): string;
var
  StartDate, EndDate: integer;
  StartYear, EndYear: string;
  FirstPeriod: integer;
begin
  Result := 'This Year';
  with ClientRec do begin
    FirstPeriod := Income.TY_FirstPeriod;
    if FirstPeriod = 0 then
      FirstPeriod := 1;
    StartDate := clTemp_Period_Details_This_Year[FirstPeriod].Period_Start_Date;
    EndDate   := clTemp_Period_Details_This_Year[Periods].Period_Start_Date;
    if LastYear then begin
      Result := 'Last Year';
      StartDate := IncDate(StartDate, 0, 0, -1);
      EndDate := IncDate(EndDate, 0, 0, -1);
    end;
    StartYear := stDatetoDateString('yyyy', StartDate, True);
      EndYear := stDatetoDateString('yyyy', EndDate, True);
  end;

  if (StartYear <> EndYear) then
    Result := Format('%s (%s-%s)',[Result, StartYear, EndYear])
  else
    Result := Format('%s (%s)',[Result, StartYear]);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure VerifyFinancialReportPreconditions( ForClient : TClientObj);
begin
   //Check parameters, no need to check booleans
   with ForClient.clFields do begin
     //Persistant Fields
       //clGST_Inclusive_Cashflow
       //clFRS_Print_Chart_Codes
       //clFRS_Show_YTD
       //clFRS_Show_Variance
       //clFRS_Prompt_User_to_use_Budgeted_figures
       Assert( clFRS_Reporting_Period_Type in [frpWeekly..frpMax]);
       Assert( clReporting_Year_Starts > 0);

     //Non-persistant fields
       Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]], 'clTemp_FRS_Last_Period_To_Show  = ' + inttostr(clTemp_FRS_Last_Period_To_Show ));
       Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]);
       Assert( clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show);

       //clTemp_FRS_Budget_To_Use
       //clTemp_FRS_Account_Totals_Cash_Only
       //clTemp_FRS_Use_Budgeted_Data_If_No_Actual_Data

     //The following fields are filled automatically by the CalculateAccountTotals routine
       //clTemp_Period_Details_This_Year
       //clTemp_Period_Details_Last_Year
       //clTemp_Periods_This_Year
       //clTemp_Periods_Last_Year
       //clTemp_Last_Period_Of_Actual_Data
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetDefaultFinancialReportSettings;
begin
   with MyClient, Myclient.clFields do
   begin
     //set fields required by calculation routine
     //clGST_Inclusive_Cashflow - Set by dialog
     clFRS_Reporting_Period_Type               := frpMonthly;
     clTemp_FRS_Account_Totals_Cash_Only       := false; //true is cashflow
     clTemp_FRS_Division_To_Use                := 0;
     clTemp_FRS_Budget_To_Use                  := '';
     clTemp_FRS_Budget_To_Use_Date             := -1;
     clTemp_FRS_Use_Budgeted_Data_If_No_Actual := false;

     //set periods required by report
     clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
     clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;

     //now set temporary flag into bank accounts;
     FlagAllAccountsForUse( MyClient);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGSTString(aClient : TClientObj) : string;
Var
  TaxName : String;
begin
  TaxName := aClient.TaxSystemNameUC;
  if aClient.clFields.clGST_Inclusive_Cashflow then
    result := '(Incl '+ TaxName + ')'
  else
    result := '(Excl ' + TaxName + ')';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure AddTo( Var TheSum : Money; AnAmount : Money );
Begin
  If AnAmount = Unknown then
     TheSum := UnKnown
  else
  If TheSum<>Unknown then
     TheSum := TheSum + AnAmount;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Procedure AddM12To( Var All, This );
Type
  M12 = Array[ 0..12 ] of Money;
Var
  mAll  : M12 Absolute All;
  mThis : M12 Absolute This;
  p     : Byte;
Begin
  For p := 0 to 12 do AddTo( mAll[p], mThis[p] );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  SomeThere(AccountTypes : ATTypeSet) : boolean;
var
  i : integer;
  AccountRec : pAccount_Rec;
begin
  Result := false;
  for i := 0 to Pred( MyClient.clChart.ItemCount ) do begin
    AccountRec := MyClient.clChart.Account_At( i );
    if AccountRec.chAccount_Type in AccountTypes then begin
      Result := true;
      Exit;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TMultiGraphReport }
procedure TMultiGraphReport.BKPrint;
var
   wasWidth,
   wasHeight : integer;

   ScreenWidth,
   ScreenHeight : integer;

   PageTop,
   PageLeft,
   PageWidth,
   PageHeight,
   PageHeight2,
   PageWidth2 : integer;

   function MMtoScreenPixels(MMValue : integer) : integer;
   begin
      result := round(mmValue / 254) * ChartWindowPPI;
   end;

begin
   if not ((ChartWindowPPI <> 0) and
            Assigned(Chart1) and
            Assigned(Chart2) and
            Assigned(Chart3) and
            Assigned(Chart4))
            then exit;

   {store for later}
   WasWidth   := Chart1.Width;
   WasHeight  := Chart1.Height;

   {expand Chart object to draw at the correct size on the printout or screen}
   with CanvasRenderEng.DetailMMRect do
   begin
     ScreenHeight := MMtoScreenPixels(Bottom - Top) div 2;
     ScreenWidth  := MMtoScreenPixels(Right - Left) div 2;
   end;

   {uses charts attached to job}
   Chart1.Width := ScreenWidth;
   Chart1.Height := ScreenHeight;
   Chart1.BottomAxis.LabelsFont.Size := 8;

   Chart2.Width := ScreenWidth;
   Chart2.Height := ScreenHeight;

   Chart3.Width := ScreenWidth;
   Chart3.Height := ScreenHeight;

   Chart4.Width := ScreenWidth;
   Chart4.Height := ScreenHeight;

   {calc size of paper}
   with CanvasRenderEng.DetailPixelRect do
   begin
     PageTop := Top;
     PageLeft := Left;
     PageWidth := Right - Left;
     PageHeight := bottom - top;
     PageWidth2 := PageWidth div 2;
     PageHeight2 := PageHeight div 2;
   end;

   if PRACINI_GraphPrintResolution <> 0 then
   begin
     Chart1.PrintResolution := PRACINI_GraphPrintResolution;
     Chart2.PrintResolution := PRACINI_GraphPrintResolution;
     Chart3.PrintResolution := PRACINI_GraphPrintResolution;
     Chart4.PrintResolution := PRACINI_GraphPrintResolution;
   end;


   Chart1.PrintPartialCanvas( CanvasRenderEng.OutputBuilder.Canvas, Rect(PageLeft,PageTop,PageLeft + PageWidth2 -1, PageTop + PageHeight2 -1));
   Chart2.PrintPartialCanvas( CanvasRenderEng.OutputBuilder.Canvas, Rect(PageLeft+PageWidth2,PageTop,PageLeft + PageWidth2+ PageWidth2 -1, PageTop + PageHeight2 -1));
   Chart3.PrintPartialCanvas( CanvasRenderEng.OutputBuilder.Canvas, Rect(PageLeft,PageTop+PageHeight2,PageLeft + PageWidth2 -1, PageTop +PageHeight2 +PageHeight2 -1));
   Chart4.PrintPartialCanvas( CanvasRenderEng.OutputBuilder.Canvas, Rect(PageLeft+PageWidth2,PageTop+PageHeight2,PageLeft + PageWidth2+PageWidth2 -1, PageTop + PageHeight2+PageHeight2 -1));

   {resize charts back to normal}
   Chart1.Width  := WasWidth;
   Chart1.Height := WasHeight;

   Chart2.Width  := WasWidth;
   Chart2.Height := WasHeight;

   Chart3.Width  := WasWidth;
   Chart3.Height := WasHeight;

   Chart4.Width  := WasWidth;
   Chart4.Height := WasHeight;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TMultiGraphReport.Create;
begin
   inherited Create(rptType);
   Chart1 := nil;
   Chart2 := nil;
   Chart3 := nil;
   Chart4 := nil;
   ChartWindowPPI := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TGraphReport.BKPrint;
var
  wasTop,
  wasLeft,
  wasWidth,
  wasHeight : integer;

   function MMtoScreenPixels(MMValue : integer) : integer;
   begin
      result := round(mmValue / 254) * ChartWindowPPI;
   end;

begin
   if not ((ChartWindowPPI <> 0) and Assigned(Chart)) then exit;

   WasTop     := Chart.Top;
   WasLeft    := Chart.LEft;
   WasWidth   := Chart.Width;
   wasHeight  := Chart.Height;

   {expand Chart object to draw at the correct size on the printout or screen}
   with  CanvasRenderEng.DetailMMRect do
   begin
     Chart.Top    := MMtoScreenPixels(Top);
     Chart.Left   := MMtoScreenPixels(Left);
     Chart.Height := MMtoScreenPixels(Bottom - Top);
     Chart.Width  := MMtoScreenPixels(Right - Left);
   end;

   if PRACINI_GraphPrintResolution <> 0 then
     Chart.PrintResolution := PRACINI_GraphPrintResolution;

   Chart.PrintPartialCanvas(  CanvasRenderEng.OutputBuilder.Canvas , CanvasRenderEng.DetailPixelRect);

   {resize chart}
   Chart.Top      := MMtoScreenPixels(wasTop);
   Chart.Left     := MMtoScreenPixels(wasLeft);
   Chart.Height   := MMtoScreenPixels(wasHeight);
   Chart.Width    := MMtoScreenPixels(wasWidth);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TGraphReport.Create;
begin
   inherited Create(rptType);
   Chart := nil;
   ChartWindowPPI := 0;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PrintGraphReport(GraphType : GRAPH_LIST_TYPE; Form : TCustomForm;
                           Destination : TReportDest; FileFormats : TFileFormatSet;
                           Params : TGenRptParameters = nil);
var
  Job : TGraphReport;
  ChartForm : TfrmChart;

begin
  if not Assigned(Form) then exit;
  ChartForm := TfrmChart(Form);

  Job := TGraphReport.Create(rptGraph);
  try
    Job.LoadReportSettings(UserPrintSettings,GRAPH_LIST_NAMES[GraphType]);
    NewReportUtils.AddCommonHeader(Job);
    NewReportUtils.AddCommonFooter(Job);

    if ChartForm.lblBudget.Caption <> '' then begin
       AddJobHeader(Job,siTitle,ChartForm.lblTitle.caption + ' ' + ChartForm.lblGST.Caption,true);
       AddJobHeader(Job,siSubTitle,ChartForm.lblBudget.Caption , true);
    end else begin
       AddJobHeader(Job,siTitle,ChartForm.lblTitle.caption,true);
       if ChartForm.lblGST.Caption > '' then
          AddJobHeader(Job,siSubTitle,ChartForm.lblGST.Caption,true);
    end;

    Job.Chart := ChartForm.Chart1;
    Job.ChartWindowPPI := ChartForm.PixelsPerInch;

    Job.FileFormats := FileFormats;
    if Destination in [rdScreen, rdPrinter, rdFile] then
       Job.Generate(Destination,Params);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PrintMultiGraph(Form : TCustomForm; Destination : TReportDest;
                          FileFormats : TFileFormatSet;
                          Params : TGenRptParameters = nil);
var
  Job : TMultiGraphReport;
  ChartForm : TfrmMultiGraph;

begin
  if not Assigned(Form) then exit;
  ChartForm := TfrmMultiGraph(Form);

  Job := TMultiGraphReport.Create(rptGraph);
  try
    Job.LoadReportSettings(UserPrintSettings,GRAPH_LIST_NAMES[GRAPH_SUMMARY]);
  

    NewReportUtils.AddCommonHeader(Job);
    NewReportUtils.AddCommonFooter(Job);

    if ChartForm.lblBudget.Caption <> '' then begin
       AddJobHeader(Job,siTitle,ChartForm.lblTitle.caption + ' ' + ChartForm.lblGST.Caption,true);
       AddJobHeader(Job,siSubTitle,ChartForm.lblBudget.Caption , true);
    end else begin
       AddJobHeader(Job,siTitle,ChartForm.lblTitle.caption,true);
       if ChartForm.lblGST.Caption > '' then
          AddJobHeader(Job,siSubTitle,ChartForm.lblGST.Caption,true);
    end;

    Job.Chart1 := ChartForm.chtSales;
    Job.Chart2 := ChartForm.chtPayments;
    Job.Chart3 := ChartForm.chtResults;
    Job.Chart4 := ChartForm.chtBank;

    Job.ChartWindowPPI := ChartForm.PixelsPerInch;

    Job.FileFormats := FileFormats;
    if Destination in [rdScreen, rdPrinter, rdFile] then
       Job.Generate(Destination, Params);
  finally
    Job.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PopulateSalesChart(Chart1 : TChart; Totals : TCashflowTotals; Periods : Integer);
var
   i : integer;
begin
   with MyClient, MyClient.clFields, Totals do
   begin
      {clear existing data}
      for i := 0 to Chart1.SeriesList.Count -1 do
      begin
        Chart1[i].Clear;
        Chart1[i].Active := false;
      end;
      {setup series}
      chart1[S_LABEL].active := true;
      Chart1[S_THIS_YEAR].Active := true;
      Chart1[S_LAST_YEAR].Active := true;
      Chart1[S_BUDGET].Active := true;

      Chart1[S_THIS_YEAR].Title := GetGraphLabel(MyClient.clFields, Income, Periods, False);
      Chart1[S_LAST_YEAR].Title := GetGraphLabel(MyClient.clFields, Income, Periods, True);
      Chart1[S_BUDGET].Title    := 'Budgeted';

      //xx_FirstPeriond and xx_LastPeriod are markers that indicate which periods
      //the first and last non-zero totals lie in.

      with Income do begin
         //last period of last year
         i := 12;
         Chart1[S_LABEL].Add(0,' ',clTeeColor);
         if ( i >= LY_FirstPeriod ) and ( i <= LY_LastPeriod ) then begin
            Chart1[S_THIS_YEAR].add(-Money2Double(Last_Year[i]),'',clTeeColor);
            TY_FirstPeriod := 1; //set to 1 so that the graph follows on from last years data
         end else
            Chart1[S_THIS_YEAR].AddNull('');
         Chart1[S_LAST_YEAR].AddNull('');
         Chart1[S_BUDGET].AddNull('');
      end;

      //load new data
      for i := 1 to 12 do with Income do
      begin
        Chart1[S_LABEL].add(0,stDatetoDateString('nnn yy', clTemp_Period_Details_This_Year[i].Period_End_Date,true),clTeeColor);

        if ( i >= TY_FirstPeriod )
        and ( i <= TY_LastPeriod)
        and (i <= Periods) then
           Chart1[S_THIS_YEAR].add(-Money2Double(This_Year[i]),'',clTeeColor)
        else
           Chart1[S_THIS_YEAR].AddNull('');

        if ( i >= LY_FirstPeriod )
        and ( i <= LY_LastPeriod )
        and (i <= Periods) then
           Chart1[S_LAST_YEAR].add(-Money2Double(Last_Year[i]),'',clTeeColor)
        else
           Chart1[S_LAST_YEAR].AddNull('');

        if ( i >= BU_FirstPeriod )
        and ( i <= BU_LastPeriod )
        and (i <= Periods) then
           Chart1[S_BUDGET].add(-Money2Double(Budget[i]),'',clTeeColor)
        else
           Chart1[S_BUDGET].AddNull('');
      end;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetGraphHeading(ClientForReport : TClientObj; ghdNo : Integer): string;
begin
  Result := '';

  if ghdNo = -1 then Exit;

  Result := ClientForReport.clFields.clGraph_Headings[ ghdNo ];

  if Result = '' then
     Result := ghdNames[ ghdNo ];

  //some of the default headings have spaces to indent them in the set up dialog
  Result := Trim(Result);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ResetUnusedParams(GraphParams: TGraphParams);
begin
  //Reset any params that are loaded from the Client and not used so that
  //they don't show in the favourite report settings
  GraphParams.ChartCodes := False;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoSalesGraph  (RptBatch : TReportBase = nil);
var
   MyForm  : TfrmChart;
   cTotals : TCashflowTotals;
   LParams :TGraphParams;
begin
   if not SomeThere([atIncome]) then begin
      HelpfulInfoMsg('You do not currently have any chart codes which report to '+
                     atNames[atIncome]+
                     '.  This means there is no information to display.'+#13+#13+

                     'Please set up the report group for any chart codes '+
                     'you wish to appear on this graph.',0);
      exit;
   end;

   LParams := TGraphParams.Create(GraphBase + ord(GRAPH_TRADING_SALES), MyClient,Rptbatch,dYear,true);


   with Lparams do try
      //Client.clFields.clGST_Inclusive_Cashflow  := ShowGST;
      ResetUnusedParams(Lparams);
      ShowLastYear := GetBatchBool(t_LastYear,True);
      ShowBudget := GetBatchBool(t_Budget,True);
      repeat


         if not GetGYearParameters('Graph Monthly Sales', Fromdate,
             true, true, True, False, BKH_Sales_graph,LParams) then exit;

         if Batchsave then begin
            SaveNodeSettings;
            SetBatchBool(t_LastYear,ShowLastYear);
            SetBatchBool(t_Budget,ShowBudget);
            Exit;
         end;

         with Client, clFields do begin
            clReporting_Year_Starts := Fromdate;

            cTotals := TCashflowTotals.Create;
            try
               SetDefaultFinancialReportSettings;

               //set values from dialog
               clGST_Inclusive_Cashflow       := ShowGST;
               clTemp_FRS_Division_To_Use     := Division;
               clTemp_FRS_Job_To_Use  := '';
               if Assigned( Budget) then begin
                  clTemp_FRS_Budget_To_Use      := Budget.buFields.buName;
                  clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
               end else begin
                  clTemp_FRS_Budget_To_Use      := '';
                  clTemp_FRS_Budget_To_Use_Date := -1;
               end;

               VerifyFinancialReportPreconditions(Client);
               CalculateAccountTotals.CalculateAccountTotalsForClient(Client);
               cTotals.Calculate( Division);

               {now create and load the chart form}
               MyForm := TfrmChart.Create(Application.MainForm);
               MyForm.Params := LParams;
               with MyForm do try
                  PopulateSalesChart(MyForm.Chart1, cTotals, Period);
                  GraphType := GRAPH_TRADING_SALES;

                  {display the form}
                  //Caption can be customised in Set up Titles and Headings
                  lblTitle.Caption := GetGraphHeading(Client,ghdMonthlySales);
                  if Division <> 0 then
                     lblTitle.Caption := lblTitle.Caption +  ' - ' + MyClient.clCustom_Headings_List.Get_Division_Heading( Division);

                  lblGST.caption := GetGSTString(MyClient);
                  lblGST.visible := lblGST.caption <> '';

                  if not Assigned(Budget) then begin
                     chBudget.Color := clBtnFace;
                     chBudget.Enabled := false;
                     chBudget.Checked := false;
                     Chart1[S_BUDGET].active   := false;
                     lblBudget.Visible := False;
                  end else begin
                     BudgetTitle := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use +
                        ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';
                     if not LParams.ShowBudget then begin
                         chBudget.Checked := False;
                     end;
                  end;

                  if not LParams.ShowLastYear then begin
                     chLastYear.Checked := False;
                  end;
                  Trade := False;

                  chLastyearClick(nil);

                  if Params.BatchRunMode = R_batch then begin
                     MyForm.SetBounds(1,1,GetDeviceCaps(MyForm.Canvas.Handle,HORZRES)-2,
                                          GetDeviceCaps(MyForm.Canvas.Handle,VERTRES)-2);


                     btnPrintClick(nil);
                  end else begin
                    ShowModal;
                    LParams.ShowLastYear := chLastYear.Checked;
                    Lparams.ShowBudget := chBudget.Checked;
                  end;
               finally
                  MyForm.Free;
               end;
            finally
               cTotals.Free;
            end;
         end;
      until LParams.RunExit(rdScreen)
   finally
     Lparams.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PopulatePaymentsChart(Chart1 : TChart; Totals : TCashflowTotals; Periods : Integer);
var
   i : integer;
   ThisYear,
   LastYear,
   Budgeted    : money;

begin
  with MyClient, MyClient.clFields, Totals do
  begin
    {clear existing data}
    for i := 0 to Chart1.SeriesList.Count -1 do
    begin
      Chart1[i].Clear;
      Chart1[i].Active := false;
    end;

    {setup series}
    chart1[S_LABEL].active := true;
    Chart1[S_THIS_YEAR].Active := true;
    Chart1[S_LAST_YEAR].Active := true;
    Chart1[S_BUDGET].Active := true;

    Chart1[S_THIS_YEAR].Title := GetGraphLabel(MyClient.clFields, Income, Periods, False);
    Chart1[S_LAST_YEAR].Title := GetGraphLabel(MyClient.clFields, Income, Periods, True);
    Chart1[S_BUDGET].Title    := 'Budgeted';

    //xx_FirstPeriond and xx_LastPeriod are markers that indicate which periods
    //the first and last non-zero totals lie in.

    //last period of last year
    i := 12;
    Chart1[S_LABEL].Add(0,' ',clTeeColor); 
    if (( i >= Direct_Expenses.LY_FirstPeriod ) and ( i <= Direct_Expenses.LY_LastPeriod )) or
       (( i >= Expenses.LY_FirstPeriod ) and ( i <= Expenses.LY_LastPeriod )) then
    begin
      LastYear := Direct_Expenses.Last_Year[i] + Expenses.Last_Year[i];
      Chart1[S_THIS_YEAR].add(Money2Double(LastYear),'',clTeeColor);
      //set to 1 so that the graph follows on from last years data
      Direct_Expenses.TY_FirstPeriod := 1;
      Expenses.TY_FirstPeriod := 1;
    end else
      Chart1[S_THIS_YEAR].AddNull('');
    Chart1[S_LAST_YEAR].AddNull('');
    Chart1[S_BUDGET].AddNull('');

    for i := 1 to 12 do begin
      Chart1[S_LABEL].add(0,stDatetoDateString('nnn yy',clTemp_Period_Details_This_Year[i].Period_End_Date,true),clTeeColor);

      if ((( i >= Direct_Expenses.TY_FirstPeriod ) and ( i <= Direct_Expenses.TY_LastPeriod )) or
         (( i >= Expenses.TY_FirstPeriod ) and ( i <= Expenses.TY_LastPeriod ))) and
         (i <= Periods) then
      begin
        ThisYear := Direct_Expenses.This_Year[i] + Expenses.This_Year[i];
        Chart1[S_THIS_YEAR].add(Money2Double(ThisYear),'',clTeeColor)
      end else
        Chart1[S_THIS_YEAR].AddNull('');

      if ((( i >= Direct_Expenses.LY_FirstPeriod ) and ( i <= Direct_Expenses.LY_LastPeriod )) or
         (( i >= Expenses.LY_FirstPeriod ) and ( i <= Expenses.LY_LastPeriod ))) then
      begin
        LastYear := Direct_Expenses.Last_Year[i] + Expenses.Last_Year[i];
        Chart1[S_LAST_YEAR].add(Money2Double(LastYear),'',clTeeColor)
      end else
        Chart1[S_LAST_YEAR].AddNull('');

      if ((( i >= Direct_Expenses.BU_FirstPeriod ) and ( i <= Direct_Expenses.BU_LastPeriod )) or
         (( i >= Expenses.BU_FirstPeriod ) and ( i <= Expenses.BU_LastPeriod ))) and
         (i <= Periods) then
      begin
        Budgeted := Direct_Expenses.Budget[i] + Expenses.Budget[i];
        Chart1[S_BUDGET].add(Money2Double(Budgeted),'',clTeeColor)
      end else
        Chart1[S_BUDGET].AddNull('');
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoPaymentsGraph( RptBatch : TReportBase = nil);
var
   MyForm  : TfrmChart;
   cTotals : TCashflowTotals;
   LParams :TGraphParams;
begin
   if not SomeThere([atPurchases, atDirectExpense, atExpense]) then begin
      HelpfulInfoMsg(Format('You do not currently have any chart codes which ' +
                            'report to either %s, %s or %s.  This means there is ' +
                            'no information to display.%s%s' +
                            'Please setup the report group for any chart codes '+
                            'you wish to appear on this graph.',
                            [atNames[atPurchases], atNames[atDirectExpense],
                             atNames[atExpense],#13,#13]),0);
      exit;
   end;

   LParams := TGraphParams.Create(GraphBase + ord(GRAPH_TRADING_PAYMENTS), MyClient,Rptbatch,dYear,true);
   with LParams do try
      ResetUnusedParams(Lparams);
      Client.clFields.clGST_Inclusive_Cashflow  := ShowGST;
      ShowLastYear := GetBatchBool(t_LastYear,True);
      ShowBudget := GetBatchBool(t_Budget,True);
      repeat
        if not GetGYearParameters('Graph Monthly Payments', Fromdate,
           true, true, True, false, BKH_Payments_graph,LParams) then exit;

        if Lparams.BatchSave then begin
           SaveNodeSettings;
           SetBatchBool(t_LastYear,ShowLastYear);
           SetBatchBool(t_Budget,ShowBudget);
           Exit;
        end;


        with Client, clFields do begin
           clReporting_Year_Starts := FromDate;

           cTotals := TCashflowTotals.Create;
           try
              SetDefaultFinancialReportSettings;

              //set values from dialog
              clGST_Inclusive_Cashflow    := ShowGST;
              clTemp_FRS_Division_To_Use  := Division;
              clTemp_FRS_Job_To_Use  := '';
              if Assigned( Budget) then begin
                 clTemp_FRS_Budget_To_Use      := Budget.buFields.buName;
                 clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
              end else begin
                 clTemp_FRS_Budget_To_Use      := '';
                 clTemp_FRS_Budget_To_Use_Date := -1;
              end;

              VerifyFinancialReportPreconditions(Client);
              CalculateAccountTotals.CalculateAccountTotalsForClient(Client);

              cTotals.Calculate(Division);

              {now create and load the chart form}
              MyForm := TfrmChart.Create(Application.MainForm);
              MyForm.Params := LParams;
              with MyForm do try
                 PopulatePaymentsChart(MyForm.Chart1,cTotals, Period);
                 GraphType := GRAPH_TRADING_PAYMENTS;

                 {display the form}
                 lblTitle.Caption := GetGraphHeading(Client,ghdMonthlyPayments);
                 if Division <> 0 then
                    lblTitle.Caption := lblTitle.Caption +  ' - ' + MyClient.clCustom_Headings_List.Get_Division_Heading( Division);

                 lblGST.caption := GetGSTString(MyClient);
                 lblGST.visible := lblGST.caption <> '';

                 if not Assigned(Budget) then begin
                    chBudget.Color   := clBtnFace;
                    chBudget.enabled := false;
                    chBudget.Checked := false;
                    Chart1[S_BUDGET].active   := false;
                    lblBudget.Visible := False;
                 end else begin
                    BudgetTitle := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use +
                      ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';

                    if not LParams.ShowBudget then begin
                       chBudget.Checked := False;
                    end;

                 end;

                 if not LParams.ShowLastYear then begin
                    chLastYear.Checked := False;
                 end;

                 Trade := false;
                 chLastyearClick(nil);

                 if LParams.BatchRunMode = R_batch then begin
                     MyForm.SetBounds(1,1,GetDeviceCaps(MyForm.Canvas.Handle,HORZRES)-2,
                                          GetDeviceCaps(MyForm.Canvas.Handle,VERTRES)-2);
                    btnPrintClick(nil);
                 end else begin
                    ShowModal;
                    LParams.ShowLastYear := chLastYear.Checked;
                    Lparams.ShowBudget := chBudget.Checked;
                 end;

              finally
                 MyForm.Free;
              end;
           finally
              cTotals.Free;
           end;
        end;   //with

      until RunExit(rdScreen);
   finally
      LParams.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PopulateBankChart(Chart1 : TChart; Totals : TCashflowTotals; Periods : Integer; AccountList: TList = nil);
var
   i,j              : integer;
   TY_PeriodBalance : Money;
   LY_PeriodBalance : Money;
   Bank_Account     : tBank_Account;
   D1,D2            : integer;
   IncludesUnknown  : boolean;
   Bank_Balances    : TGraphsTLBRec;

   d,m,y            : integer;
begin
   D1 := ClDateUtils.BAllData( MyClient );
   D2 := ClDateUtils.EAllData( MyClient );

   //the dates above may not include the first and last days of the month
   //need to correct them so that data for the last month will be shown
   //even if there are no transactions on the last day

   if ( D1 > 0 ) then begin
      StDatetoDmy(D1,d,m,y);
      D1 := DmyToStDate(1,m,y,BKDATEEPOCH);
   end;

   if ( D2 > 0 ) then begin
      StDatetoDmy(D2,d,m,y);
      D2 := DmyToStDate(DaysInMonth(m,y,BKDATEEPOCH),m,y,BKDATEEPOCH);
   end;

   IncludesUnknown := false;

   FillChar(Bank_balances,SizeOf(Bank_Balances),#0);

   with MyClient, MyClient.clfields, Totals, Bank_Balances do begin
    {clear existing data}
    for i := 0 to Chart1.SeriesList.Count -1 do  begin
      Chart1[i].Clear;
      Chart1[i].Active := false;
    end;

    //generate totals for each bank account
    if AccountList=nil then
    begin
      for i := 0 to Pred(clBank_Account_List.ItemCount) do begin
       clBank_Account_List.Bank_Account_At(i).CalculateBalances( clReporting_Year_Starts);
      end;
    end else begin
      for i := 0 to AccountList.Count-1 do begin
        TBank_Account(AccountList[i]).CalculateBalances( clReporting_Year_Starts);
      end;
    end;

    {setup series}
    chart1[S_LABEL].active := true;

    Chart1[S_THIS_YEAR].Active := true;
    Chart1[S_LAST_YEAR].Active := true;

    //Load the Bank_Balances structure
    for i := 0 to 12 do
    begin
      TY_PeriodBalance := 0;
      LY_PeriodBalance := 0;
      if AccountList=nil then
      begin
        for j := 0 to Pred(clBank_Account_List.ItemCount) do begin
           Bank_Account := clBank_Account_List.Bank_Account_At(j);
           With Bank_Account do Begin
              if i = 0 then begin
                TY_PeriodBalance := TY_PeriodBalance - baFields.baOpening_Bank_Balance.This_Year[i + 1];
                LY_PeriodBalance := LY_PeriodBalance - baFields.baOpening_Bank_Balance.Last_Year[i + 1];
              end else begin
                TY_PeriodBalance := TY_PeriodBalance - baFields.baClosing_Bank_Balance.This_Year[i];
                LY_PeriodBalance := LY_PeriodBalance - baFields.baClosing_Bank_Balance.Last_Year[i];
              end;

              IncludesUnknown := (baFields.baCurrent_balance = Unknown);
           end;
        end;
      end else begin
        for j := 0 to Pred(AccountList.Count) do begin
           Bank_Account := TBank_Account(AccountList[j]);
           With Bank_Account do Begin
              if i = 0 then begin
                TY_PeriodBalance := TY_PeriodBalance - baFields.baOpening_Bank_Balance.This_Year[i + 1];
                LY_PeriodBalance := LY_PeriodBalance - baFields.baOpening_Bank_Balance.Last_Year[i + 1];
              end else begin
                TY_PeriodBalance := TY_PeriodBalance - baFields.baClosing_Bank_Balance.This_Year[i];
                LY_PeriodBalance := LY_PeriodBalance - baFields.baClosing_Bank_Balance.Last_Year[i];
              end;

              IncludesUnknown := (baFields.baCurrent_balance = Unknown);
           end;
        end;
      end;

      If IncludesUnknown then  begin
         TY_PeriodBalance := 0;
         LY_PeriodBalance := 0;
      end;

      This_Year[i] := TY_PeriodBalance;
      Last_Year[i] := LY_PeriodBalance;
      SetNonZeroPeriodMarkers(Bank_Balances, i);
    end;

    //Have to get the labels after setting the period indicators in Bank_Balances
    Chart1[S_THIS_YEAR].Title := GetGraphLabel(MyClient.clFields, Bank_Balances, Periods, False);
    Chart1[S_LAST_YEAR].Title := GetGraphLabel(MyClient.clFields, Bank_Balances, Periods, True);

    //Load the data into the graph
    for i := 0 to 12 do begin
      Chart1[S_LABEL].add(0,stDatetoDateString('nnn yy',clTemp_Period_Details_This_Year[i].Period_End_Date,true),clTeeColor);

      if (clTemp_Period_Details_This_Year[i].Period_End_Date >= D1) and
         (clTemp_Period_Details_This_Year[i].Period_End_Date <= D2) and
         (i <= Periods) then
        Chart1[S_THIS_YEAR].add(Money2Double(This_Year[i]),'',clTeeColor)
      else
        Chart1[S_THIS_YEAR].AddNull('');

      if (clTemp_Period_Details_Last_Year[i].Period_End_Date >= D1) and
         (clTemp_Period_Details_Last_Year[i].Period_End_Date <= D2) then
        Chart1[S_LAST_YEAR].add(Money2Double(Last_Year[i]),'',clTeeColor)
      else
        Chart1[S_LAST_YEAR].AddNull('');
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoBankBalance  (RptBatch : TReportBase = nil);
var
   MyForm  : TfrmChart;
   i       : integer;
   NeedsBalance : boolean;
   cTotals : TCashflowTotals;
   LParams : TGraphParams;
begin
   NeedsBalance := false;
   with MyClient.clBank_Account_List do for i := 0 to Pred(itemCount) do
     with Bank_Account_At(i) do
       if (baFields.baCurrent_balance = unknown) then
         NeedsBalance := true;

   If needsBalance then begin
     HelpfulInfoMsg('You need to enter the Bank Account Balances before doing this.',0);
     exit;
   end;


   LParams := TGraphParams.Create(GraphBase + ord(GRAPH_BANK_BALANCE), MyClient,Rptbatch,dYear,true);
   with Lparams do try
      ResetUnusedParams(Lparams);
      ShowGST := False;
      ShowLastYear := GetBatchBool(t_LastYear,True);
      repeat

         Division := -1;  //tells dialog not to display division box
         if not GetGYearParameters('Graph Total Monthly Bank Balance',FromDate ,
          false, false, true, false, BKH_Total_bank_balances_graph,LParams) then exit;

         if Batchsave then begin
            SaveNodeSettings;
            SetBatchBool(t_LastYear,ShowLastYear);
            Exit;
         end;

         with Client, clFields do begin
            SetDefaultFinancialReportSettings;

            //set values from dialog
            clReporting_Year_Starts        := Fromdate;
            clGST_Inclusive_Cashflow       := ShowGST;
            clTemp_FRS_Division_To_Use     := Division;
            clTemp_FRS_Job_To_Use  := '';
            if Assigned(Budget) then begin
               clTemp_FRS_Budget_To_Use      := Budget.buFields.buName;
               clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
            end else begin
               clTemp_FRS_Budget_To_Use      := '';
               clTemp_FRS_Budget_To_Use_Date := -1;
            end;

            VerifyFinancialReportPreconditions(Client);
            //need to fill the period start/end dates so call calc totals
            CalculateAccountTotals.CalculateAccountTotalsForClient(Client);

            cTotals := TCashflowTotals.Create;
            try
               {now create and load the chart form}
               MyForm := TfrmChart.Create(Application.MainForm);
               MyForm.Params := LParams;
               with MyForm do try
                  PopulateBankChart(MyForm.Chart1, cTotals, Period, LParams.AccountList);
                  GraphType := GRAPH_BANK_BALANCE;

                  {display the form}
                  lblTitle.Caption := GetGraphHeading(MyClient, ghdTotalMonthlyBankBalance);
                  if Division <> 0 then
                    lblTitle.Caption := lblTitle.Caption +  ' - ' + MyClient.clCustom_Headings_List.Get_Division_Heading( Division);

                  lblGST.Caption := '';
                  lblGst.Visible := False;

                  if not Assigned(Budget) then begin
                     chBudget.Color := clBtnFace;
                     chBudget.Enabled := false;
                     chBudget.Checked := false;
                     Chart1[S_BUDGET].active   := false;
                     lblBudget.Visible := False;
                  end;

                  Trade := False;

                  if not LParams.ShowLastYear then begin
                     chLastYear.Checked := False;
                     chLastYearClick(nil);
                  end;

                  if LParams.BatchRunMode = R_batch then begin
                      MyForm.SetBounds(1,1,GetDeviceCaps(MyForm.Canvas.Handle,HORZRES)-2,
                                          GetDeviceCaps(MyForm.Canvas.Handle,VERTRES)-2);

                      btnPrintClick(nil);
                  end else begin
                     ShowModal;
                     LParams.ShowLastYear := chLastYear.Checked;
                     Lparams.ShowBudget := chBudget.Checked;
                  end;
               finally
                  MyForm.Free;
               end;
            finally
              cTotals.Free;
            end;
         end;
      until RunExit(rdScreen);
   finally
      LParams.Free;
   end;

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure PopulateResultsChart(Chart1 : TChart; Totals : TCashflowTotals; Periods : Integer);
var
  i : integer;
  Sales,
  GP,
  NP    : money;
  SalesCaption: string;
  GrossProfitCaption: string;
  OperatingProfitCaption: string;
begin
  with MyClient, MyClient.clFields, Totals do
  begin
    {clear existing data}
    for i := 0 to Chart1.SeriesList.Count -1 do
    begin
      Chart1[i].Clear;
      Chart1[i].Active := false;
    end;

    {setup series}
    chart1[S_LABEL].active := true;
    //Chart1[S_THIS_SALES].Active := true;
    //Chart1[S_THIS_GROSS].Active := true;
    //Chart1[S_THIS_NET].Active := true;

    //Captions can be customised
    SalesCaption := GetGraphHeading(MyClient, ghdTRSales);
    GrossProfitCaption := GetGraphHeading(MyClient, ghdTRGrossProfit);
    OperatingProfitCaption := GetGraphHeading(MyClient, ghdTROperatingProfit);

    Chart1[S_THIS_SALES].Title    := SalesCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, False);
    Chart1[S_THIS_GROSS].Title    := GrossProfitCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, False);
    Chart1[S_THIS_NET].Title      := OperatingProfitCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, False);

    Chart1[S_LAST_SALES].Title    := SalesCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, True);
    Chart1[S_LAST_GROSS].Title    := GrossProfitCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, True);
    Chart1[S_LAST_NET].Title      := OperatingProfitCaption + ' '+ GetGraphLabel(MyClient.clFields, Income, Periods, True);

    Chart1[S_BUD_SALES].Title    := SalesCaption + ' Budgeted';
    Chart1[S_BUD_GROSS].Title    := GrossProfitCaption+ ' Budgeted';
    Chart1[S_BUD_NET].Title      := OperatingProfitCaption+ ' Budgeted';

    //xx_FirstPeriond and xx_LastPeriod are markers that indicate which periods
    //the first and last non-zero totals lie in.

    //last period of last year
    i := 12;
    Chart1[S_LABEL].Add(0,' ',clTeeColor);

    if ( i >= Income.LY_FirstPeriod )
    and ( i <= Income.LY_LastPeriod ) then begin
       Sales := -Income.Last_Year[i];
       Chart1[S_THIS_SALES].add(Money2Double(Sales),'',clTeeColor);
       Income.TY_FirstPeriod := 1; //set to 1 so that the graph follows on from last years data
    end else
       Chart1[S_THIS_SALES].AddNull('');

    if ( i >= Gross_Profit.LY_FirstPeriod )
    and ( i <= Gross_Profit.LY_LastPeriod ) then begin
       GP := -Gross_Profit.Last_Year[i];
       Chart1[S_THIS_GROSS].add(Money2Double(GP),'',clTeeColor);
       Gross_Profit.TY_FirstPeriod := 1; //set to 1 so that the graph follows on from last years data
    end else
       Chart1[S_THIS_GROSS].AddNull('');

    if ( i >= Net_Profit.LY_FirstPeriod )
    and ( i <= Net_Profit.LY_LastPeriod ) then begin
       NP := -Net_Profit.Last_Year[i];
       Chart1[S_THIS_NET].add(Money2Double(NP),'',clTeeColor);
       Net_Profit.TY_FirstPeriod := 1; //set to 1 so that the graph follows on from last years data
    end else
       Chart1[S_THIS_NET].AddNull('');

    //Make all other null
    Chart1[S_Last_SALES].AddNull('');
    Chart1[S_Last_GROSS].AddNull('');
    Chart1[S_Last_NET].AddNull('');
    Chart1[S_BUD_SALES].AddNull('');
    Chart1[S_BUD_GROSS].AddNull('');
    Chart1[S_BUD_NET].AddNull('');

    for i := 1 to 12 do begin
       // Fill in the X Lables
       Chart1[S_LABEL].add(0,stDatetoDateString('nnn yy',clTemp_Period_Details_This_Year[i].Period_End_Date,true),clTeeColor);
       Chart1[S_LABEL2].add(0,stDatetoDateString('nnn yy',clTemp_Period_Details_This_Year[i].Period_End_Date,true),clTeeColor);

      // This year sales
      if ( i >= Income.TY_FirstPeriod )
      and ( i <= Income.TY_LastPeriod )
      and (i <= Periods) then begin
         Sales := -Income.This_Year[i];
         Chart1[S_THIS_SALES].add(Money2Double(Sales),'',clTeeColor);
      end else
         Chart1[S_THIS_SALES].AddNull('');

      // This year Gross Profit
      if ( i >= Gross_Profit.TY_FirstPeriod )
      and ( i <= Gross_Profit.TY_LastPeriod )
      and (i <= Periods) then begin
         GP := -Gross_Profit.This_Year[i];
         Chart1[S_THIS_GROSS].add(Money2Double(GP),'',clTeeColor);
      end else
         Chart1[S_THIS_GROSS].AddNull('');

      // This year Nett Profit
      if ( i >= Net_Profit.TY_FirstPeriod )
      and ( i <= Net_Profit.TY_LastPeriod )
      and (i <= Periods) then begin
         NP := -Net_Profit.This_Year[i];
         Chart1[S_THIS_NET].add(Money2Double(NP),'',clTeeColor);
      end else
         Chart1[S_THIS_NET].AddNull('');

      // Last year sales
      if ( i >= Income.LY_FirstPeriod )
      and ( i <= Income.LY_LastPeriod )
      and (i <= Periods) then begin
         Sales := -Income.Last_Year[i];
         Chart1[S_Last_SALES].add(Money2Double(Sales),'',clTeeColor);
      end else
         Chart1[S_Last_SALES].AddNull('');

      if ( i >= Gross_Profit.LY_FirstPeriod )
      and ( i <= Gross_Profit.LY_LastPeriod )
      and (i <= Periods) then begin
         GP := -Gross_Profit.Last_Year[i];
         Chart1[S_Last_GROSS].add(Money2Double(GP),'',clTeeColor);
      end else
         Chart1[S_Last_GROSS].AddNull('');

      if ( i >= Net_Profit.LY_FirstPeriod )
      and ( i <= Net_Profit.LY_LastPeriod )
      and (i <= Periods) then begin
         NP := -Net_Profit.Last_Year[i];
         Chart1[S_Last_NET].add(Money2Double(NP),'',clTeeColor);
      end else
         Chart1[S_Last_NET].AddNull('');

      {BUD year}
      if ( i >= Income.BU_FirstPeriod ) and ( i <= Income.BU_LastPeriod ) and
         (i <= Periods) then
      begin
        Sales := -Income.Budget[i];
        Chart1[S_BUD_SALES].add(Money2Double(Sales),'',clTeeColor);
      end else
        Chart1[S_BUD_SALES].AddNull('');

      if ( i >= Gross_Profit.BU_FirstPeriod ) and ( i <= Gross_Profit.BU_LastPeriod ) and
         (i <= Periods) then
      begin
        GP := -Gross_Profit.Budget[i];
        Chart1[S_BUD_GROSS].add(Money2Double(GP),'',clTeeColor);
      end else
        Chart1[S_BUD_GROSS].AddNull('');

      if ( i >= Net_Profit.BU_FirstPeriod ) and ( i <= Net_Profit.BU_LastPeriod ) and
         (i <= Periods) then
      begin
        NP := -Net_Profit.Budget[i];
        Chart1[S_BUD_NET].add(Money2Double(NP),'',clTeeColor);
      end else
        Chart1[S_BUD_NET].AddNull('');
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoTradingResults( RptBatch : TReportBase = nil);
var
   MyForm  : TfrmChart;
   cTotals : TCashflowTotals;
   LParams : TGraphParams;
  TradingResultsHeading: string;
begin
   if not SomeThere([atIncome, atDirectExpense, atExpense, atPurchases]) then begin
      HelpfulInfoMsg('You do not currently have any chart codes which report to either '+
                      atNames[atIncome]+', '+
                      atNames[atDirectExpense]+','+
                      atNames[atExpense]+','+
                     'or '+atNames[atPurchases]+'.  '+
                     'This means there is no information to display.'+#13+#13+

                     'Please set up the report group for any chart codes '+
                     'you wish to appear on this graph.',0);
      exit;
   end;


   LParams := TGraphParams.Create(GraphBase + ord(GRAPH_TRADING_RESULTS), MyClient,Rptbatch,dYear,true);
   with LParams do try
      ResetUnusedParams(Lparams);
      ShowLastYear := GetBatchBool(t_LastYear,True);
      ShowBudget := GetBatchBool(t_Budget,True);
      ShowSales := GetBatchBool(t_Sales,True);
      ShowGrossProfit := GetBatchBool(t_Gross,True);
      ShowNettProfit := GetBatchBool(t_Nett,True);

      repeat
         if not GetGYearParameters('Graph Monthly Trading Results', FromDate,
          true, true, true, True, BKH_Trading_results_graph, LParams) then exit;

         if batchsave then begin
            SaveNodeSettings;
            SetBatchBool(t_LastYear,ShowLastYear);
            SetBatchBool(t_Budget,ShowBudget);
            SetBatchBool(t_Sales,ShowSales);
            SetBatchBool(t_Gross,ShowGrossProfit);
            SetBatchBool(t_Nett,ShowNettProfit);


            Exit;
         end;


         with Client, clFields do begin

           clReporting_Year_Starts := FromDate;
           clGST_Inclusive_Cashflow := ShowGst;

           cTotals := TCashflowTotals.Create;
           try
              SetDefaultFinancialReportSettings;

              //set values from dialog
              clGST_Inclusive_Cashflow     := ShowGST;
              clTemp_FRS_Division_To_Use   := Division;
              clTemp_FRS_Job_To_Use  := '';
              if Assigned(Budget) then begin
                 clTemp_FRS_Budget_To_Use      := Budget.buFields.buName;
                 clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
              end else begin
                 clTemp_FRS_Budget_To_Use      := '';
                 clTemp_FRS_Budget_To_Use_Date := -1;
              end;

              VerifyFinancialReportPreconditions(Client);
              CalculateAccountTotals.CalculateAccountTotalsForClient(Client);
              cTotals.Calculate(Division);

              {now create and load the chart form}
              MyForm := TfrmChart.Create(Application.MainForm);
              MyForm.Params := LParams;
              with MyForm do try
                 PopulateResultsChart(MyForm.Chart1, cTotals, Period);
                 GraphType := GRAPH_TRADING_RESULTS;

                 {display the form}
                 TradingResultsHeading := GetGraphHeading(MyClient, ghdMonthlyTradingResults);

                 lblTitle.Caption :=  TradingResultsHeading;

                 if Division <> 0 then begin
                    lblTitle.Caption := lblTitle.Caption +  ' - ' + MyClient.clCustom_Headings_List.Get_Division_Heading( Division);
                 end;

                 lblGST.caption := GetGSTString(MyClient);
                 lblGST.visible := lblGST.caption <> '';


                 if not Assigned(Budget) then begin
                    chBudget.Checked := false;
                    chBudget.Enabled := false;
                    lblBudget.Visible := False;

                 end else begin
                    BudgetTitle := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use +
                       ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';
                 end;

                 Trade := True;

                 chLastYear.Checked := LParams.ShowLastYear;
                 chSales.Checked := LParams.ShowSales;
                 chGross.Checked := LParams.ShowGrossProfit;
                 chNett.Checked := LParams.ShowNettProfit;


                 chLastYearClick(nil);

                 if LParams.BatchRunMode = R_batch then begin
                    MyForm.SetBounds(1,1,GetDeviceCaps(MyForm.Canvas.Handle,HORZRES)-2,
                                          GetDeviceCaps(MyForm.Canvas.Handle,VERTRES)-2);
                    btnPrintClick(nil);
                 end else begin
                    ShowModal;
                 end;

              finally
                 MyForm.Free;
              end;
           finally
              cTotals.Free;
           end;
        end;
      until RunExit(rdScreen);
   finally
      LParams.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoSummary(RptBatch : TReportBase = nil);
var
   MyForm  : TfrmMultiGraph;
   NeedsBalance : boolean;
   i : integer;
   cTotals : TCashflowTotals;
   S: string;
   LParams : TGraphParams;
begin
   NeedsBalance := false;
   with MyClient.clBank_Account_List do for i := 0 to Pred(itemCount) do
     with Bank_Account_At(i) do
       if (baFields.baCurrent_balance = unknown) then
         NeedsBalance := true;

   If needsBalance then
   begin
     HelpfulInfoMsg('You need to enter the Bank Account Balances before doing this.',0);
     exit;
   end;

   LParams := TGraphParams.Create(GraphBase + ord(GRAPH_SUMMARY), MyClient,Rptbatch,dYear,true);
   with Lparams do try
      ResetUnusedParams(Lparams);
      ShowLastYear := GetBatchBool(t_LastYear,True);
      ShowBudget := GetBatchBool(t_Budget,True);
      ShowSales := GetBatchBool(t_Sales,True);
      ShowGrossProfit := GetBatchBool(t_Gross,True);
      ShowNettProfit := GetBatchBool(t_Nett,True);

      repeat


         if not GetGYearParameters('Graph One Page Summary', Fromdate,
          true, true,True, true, BKH_One_page_summary, LParams) then exit;

         if BatchSave then begin
            SaveNodeSettings;
            SetBatchBool(t_LastYear,ShowLastYear);
            SetBatchBool(t_Budget,ShowBudget);
            SetBatchBool(t_Sales,ShowSales);
            SetBatchBool(t_Nett,ShowNettProfit);
            SetBatchBool(t_Gross,ShowGrossProfit);

            Exit;
         end;


         with Client, clFields do begin
            clReporting_Year_Starts := FromDate;
            cTotals := TCashflowTotals.Create;
            try
               SetDefaultFinancialReportSettings;

               //set values from dialog
               clGST_Inclusive_Cashflow       := ShowGST;
               clTemp_FRS_Division_To_Use     := Division;
               clTemp_FRS_Job_To_Use  := '';
               if Assigned(Budget) then begin
                  clTemp_FRS_Budget_To_Use      := Budget.buFields.buName;
                  clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
               end else begin
                  clTemp_FRS_Budget_To_Use      := '';
                  clTemp_FRS_Budget_To_Use_Date := -1;
               end;

               VerifyFinancialReportPreconditions(Client);
               CalculateAccountTotals.CalculateAccountTotalsForClient(Client);
               cTotals.Calculate(Division);

               {now create and load the chart form}
               MyForm := TFrmMultiGraph.Create(Application.MainForm);
               MyForm.Params := LParams;
               with MyForm do try
                  Hide;

                  lblTitle.Caption := GetGraphHeading(MyClient,ghdOnePageSummary);
                  if Division <> 0 then
                     lblTitle.Caption := lblTitle.Caption + ' - ' + MyClient.clCustom_Headings_List.Get_Division_Heading( Division);

                  lblGST.caption := GetGSTString(MyClient);
                  lblGST.visible := lblGST.caption <> '';

                  PopulateSalesChart(chtSales, cTotals, Period);
                  chtSales.Title.Text.Clear;
                  chtSales.Title.Text.add(GetGraphHeading(MyClient, ghdMonthlySales));
                  chtSales.Title.Visible := true;

                  PopulatePaymentsChart(chtPayments, cTotals, Period);
                  chtPayments.Title.Text.Clear;
                  chtPayments.Title.Text.add(GetGraphHeading(MyClient, ghdMonthlyPayments));
                  chtPayments.Title.Visible := true;

                  PopulateResultsChart(chtResults, cTotals, Period);
                  chtResults.Title.Text.Clear;
                  chtResults.Title.Text.add(GetGraphHeading(MyClient, ghdMonthlyTradingResults) );
                  chtResults.Title.Visible := true;

                  PopulateBankChart(chtBank, cTotals, Period);
                  chtBank.Title.Text.Clear;
                  S := GetGraphHeading(MyClient, ghdTotalMonthlyBankBalance);
                  if (Division <> 0) then
                    S := S + ' (All Divisions)';
                  chtBank.Title.Text.add(S);
                  chtBank.Title.Visible := true;

                  chtSales[S_BUDGET].Active := Assigned(Budget);
                  chtPayments[S_BUDGET].Active := Assigned(Budget);

                  {display the form}
                  chBudget.Enabled := Assigned(Budget);
                  if not chBudget.enabled then begin
                    chBudget.Checked := False;
                    chBudget.Color := clbtnFace;
                    lblBudget.Visible := False;
                  end else begin
                    BudgetTitle := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use +
                      ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';
                  end;

                  chLastYear.Checked := LParams.ShowLastYear;
                  chBudget.Checked := Lparams.ShowBudget;
                  chSales.Checked := LParams.ShowSales;
                  chGross.Checked := Lparams.ShowGrossProfit;
                  chNett.Checked := LParams.ShowNettProfit;


                  chLastYearClick(nil);

                  if LParams.BatchRunMode = R_batch then begin
                     MyForm.SetBounds(1,1,GetDeviceCaps(MyForm.Canvas.Handle,HORZRES)-2,
                                          GetDeviceCaps(MyForm.Canvas.Handle,VERTRES)-2);
                     btnPrintClick(nil);
                  end else begin
                     ShowModal;

                     LParams.ShowLastYear := chLastYear.Checked;
                     Lparams.ShowBudget := chBudget.Checked;
                     LParams.ShowSales := chSales.Checked;
                     Lparams.ShowGrossProfit := chGross.Checked;
                     LParams.ShowNettProfit := chNett.Checked;
                  end;

               finally
                  MyForm.Free;
               end;
            finally
               cTotals.Free;
            end;
         end;
      until RunExit(rdScreen);
   finally
      LParams.Free;
   end;


end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoGraph(Graph_Type : Graph_List_Type; RptBatch : TReportBase = nil);
begin
   if not Assigned(MyClient) then exit;

   CalculateAccountTotals.AddAutoContraCodes( MyClient);
   CreateReportImageList;
   try
     case Graph_Type of
       GRAPH_TRADING_SALES              : DoSalesGraph(RptBatch);
       GRAPH_TRADING_PAYMENTS           : DoPaymentsGraph(RptBatch);
       GRAPH_TRADING_RESULTS            : DoTradingResults(RptBatch);
       GRAPH_BANK_BALANCE               : DoBankBalance(RptBatch);
       GRAPH_SUMMARY                    : DoSummary(RptBatch);
     else
        ;
     end;
   finally
      CalculateAccountTotals.RemoveAutoContraCodes( Myclient);
      DestroyReportImageList;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TMultiGraphReport.GetCanvasRE: TRenderToCanvasEng;
//returns the Canvas Render Engine object.  Used so that dont need to type cast
//the Custom Render Engine each time
begin
   result := TRenderToCanvasEng( RenderEngine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TGraphReport.GetCanvasRE: TRenderToCanvasEng;
//returns the Canvas Render Engine object.  Used so that dont need to type cast
//the Custom Render Engine each time
begin
   result := TRenderToCanvasEng( RenderEngine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TCashflowTotals }
procedure TCashflowTotals.Calculate(For_Division : integer);
var
  i, j : integer;
  Period : byte;
  AccountInfo : TProfitAndLossAccountInfo;
begin
  ZeroTotals;
  if not Assigned(myClient) then exit;

  with MyClient do begin
    AccountInfo := TProfitAndLossAccountInfo.Create( MyClient);
    try
      With clChart do For i := 0 to Pred( itemCount ) do With Account_At( i )^ do Begin
         AccountInfo.UseBudgetIfNoActualData     := clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
         AccountInfo.LastPeriodOfActualDataToUse := clFields.clTemp_FRS_Last_Actual_Period_To_Use;
         AccountInfo.AccountCode                 := chAccount_Code;

         if (for_Division = 0) or (chPrint_In_Division[For_Division]) then
           Case chAccount_Type of
              atIncome          :
                 Begin
                    for j := 0 to 12 do begin
                      Income.This_Year[j] := Income.This_Year[j] + AccountInfo.ActualOrBudget( j);
                      Income.Last_Year[j] := Income.Last_Year[j] + AccountInfo.LastYear( j);
                      Income.Budget[j]    := Income.Budget[j]    + AccountInfo.Budget( j);
                    end;
                 end;
              atDirectExpense, atPurchases, atOpeningStock, atClosingStock   :
                 Begin
                    for j := 0 to 12 do begin
                      Direct_Expenses.This_Year[j] := Direct_Expenses.This_Year[j] + AccountInfo.ActualOrBudget( j);
                      Direct_Expenses.Last_Year[j] := Direct_Expenses.Last_Year[j] + AccountInfo.LastYear( j);
                      Direct_Expenses.Budget[j]    := Direct_Expenses.Budget[j]    + AccountInfo.Budget( j);
                    end;
                 end;
              atExpense    :
                 Begin
                    for j := 0 to 12 do begin
                      Expenses.This_Year[j] := Expenses.This_Year[j] + AccountInfo.ActualOrBudget( j);
                      Expenses.Last_Year[j] := Expenses.Last_Year[j] + AccountInfo.LastYear( j);
                      Expenses.Budget[j]    := Expenses.Budget[j]    + AccountInfo.Budget( j);
                    end;
                 end;
           end; //case
      end;
    finally
       AccountInfo.Free;
    end;

    //calculate Gross Profit, Net Profit and Net Profit Percentage
    For Period := 0 to 12 do Begin

       //This Year

       Gross_Profit.This_Year[ Period ] :=
          Income.This_Year[ Period ] +
          Direct_Expenses.This_Year[ Period ];

       If Income.This_Year[ Period ]<>0 then
          Gross_Profit_Percent.This_Year[ Period ] :=
             100.0 * Gross_Profit.This_Year[ Period ] / Income.This_Year[ Period ];

       Net_Profit.This_Year[ Period ]   :=
          Gross_Profit.This_Year[ Period ] +
          Expenses.This_Year[ Period ];

       If Income.This_Year[ Period ]<>0 then
          Net_Profit_Percent.This_Year[ Period ] :=
             100.0 * Net_Profit.This_Year[ Period ] / Income.This_Year[ Period ];

       //Last Year

       Gross_Profit.Last_Year[ Period ] :=
          Income.Last_Year[ Period ] +
          Direct_Expenses.Last_Year[ Period ];

       If Income.Last_Year[ Period ]<>0 then
          Gross_Profit_Percent.Last_Year[ Period ] :=
             100.0 * Gross_Profit.Last_Year[ Period ] / Income.Last_Year[ Period ];

       Net_Profit.Last_Year[ Period ]   :=
          Gross_Profit.Last_Year[ Period ] +
          Expenses.Last_Year[ Period ];

       If Income.Last_Year[ Period ]<>0 then
          Net_Profit_Percent.Last_Year[ Period ] :=
             100.0 * Net_Profit.Last_Year[ Period ] / Income.Last_Year[ Period ];

       //Budget
       Gross_Profit.Budget[ Period ] :=
          Income.Budget[ Period ] +
          Direct_Expenses.Budget[ Period ];

       If Income.Budget[ Period ]<>0 then
          Gross_Profit_Percent.Budget[ Period ] :=
             100.0 * Gross_Profit.Budget[ Period ] / Income.Budget[ Period ];

       Net_Profit.Budget[ Period ]   :=
          Gross_Profit.Budget[ Period ] +
          Expenses.Budget[ Period ];

       If Income.Budget[ Period ]<>0 then
          Net_Profit_Percent.Budget[ Period ] :=
             100.0 * Net_Profit.Budget[ Period ] / Income.Budget[ Period ];
    end;

    //set the first and last non zero period markers
    for Period := 1 to 12 do begin
       SetNonZeroPeriodMarkers(Income,Period);

       SetNonZeroPeriodMarkers(Direct_Expenses,Period);

       SetNonZeroPeriodMarkers(Expenses,Period);

       SetNonZeroPeriodMarkers(Gross_Profit,Period);

       SetNonZeroPeriodMarkers(Net_Profit,Period);

       SetNonZeroPeriodMarkers(Net_Profit_Percent,Period);
    end;

  end;  //with myClient
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TCashflowTotals.Create;
begin
  inherited Create;
  ZeroTotals;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TCashflowTotals.ZeroTotals;
begin
  FillChar(Income,               Sizeof(Income),              0);
  FillChar(Direct_Expenses,      Sizeof(Direct_Expenses),     0);
  FillChar(Expenses,             Sizeof(Expenses),            0);
  FillChar(Gross_Profit,         Sizeof(Gross_Profit),        0);
  FillChar(Net_Profit,           Sizeof(Net_Profit),          0);
  FillChar(Gross_Profit_Percent, Sizeof(Gross_Profit_Percent),0);
  FillChar(Net_Profit_Percent,   Sizeof(Net_Profit_Percent),  0);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.

