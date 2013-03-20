unit rptBalanceSheet;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:      Matthew Hopkins July 2002

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
   ReportDefs, clObj32,uBatchBase;

procedure DoBalanceSheet(Destination: TReportDest; RptBatch: TReportBase = nil );
procedure VerifyBalanceSheetPreconditions(ForClient: TClientObj);
procedure DoBalanceExport;

function GetBSHeading(ClientForReport : TClientObj; No : Integer): string;

//******************************************************************************
implementation

uses
  Controls,
  Forms,
  Graphics,
  Math,
  SysUtils,
  ReportTypes,
  AccountInfoObj,
  BalanceSheetHeadings,
  bkconst,
  bkDateUtils,
  bkdefs,
  BudgetLookup,
  budObj32,
  CalculateAccountTotals,
  CheckBoxOptionsDlg,
  glConst,
  globals,
  InfoMoreFrm,
  MoneyDef,
  NewReportObj,
  NewReportUtils,
  OfficeDM, OpExcel,
  repcols,
  ReportCashflowBase,
  SignUtils,
  stDateSt,
  RptParams,
  CountryUtils,
  StDate,
  ForexHelpers;

type
  //this is the balance sheet report object.  It adds to retrieve values for each account
  TBalanceSheetReport = class( TFinancialReportBase)
  protected
    procedure GetValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray; UsePeriodStartEnd: boolean = false); override;
    procedure GetYTD_ValuesForPeriod(const pAcct : pAccount_Rec; const ForPeriod : integer; var Values : TValuesArray); override;

    procedure SetupColumnsTypes; override;
  public
    function  GetHeading( No : Integer): string; override;
  end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ListBalanceSheet(Sender : TObject);
begin
  with TBalanceSheetReport(Sender) ,MyClient, MyClient.clFields do begin
    TBalanceSheetReport(Sender).ResetControlAccounts;
    //Assets
    RenderTitleLine( GetHeading( bhdAssets));
    if ReportSectionNeedsPrinting( [atCurrentAsset, atStockOnHand, atDebtors, atBankAccount, atGSTReceivable ]) then
      PrintSection( [atCurrentAsset, atStockOnHand, atDebtors, atBankAccount, atGSTReceivable ], bhdCurrent_Assets, bhdTotal_Current_Assets, Debit);
    if ReportSectionNeedsPrinting( [atFixedAssets]) then
      PrintSection( [atFixedAssets], bhdFixed_Assets, bhdTotal_Fixed_Assets, Debit);

    RenderDetailRunningTotal( GetHeading( bhdTotal_Assets), Debit );
    ClearRunningTotals;

    //Liabilities
    RenderTitleLine( GetHeading( bhdLiabilities));
    if ReportSectionNeedsPrinting( [atCurrentLiability, atCreditors, atGSTPayable]) then
      PrintSection( [atCurrentLiability, atCreditors, atGSTPayable], bhdCurrent_Liabilities, bhdTotal_Current_Liabilities, Credit);

    if ReportSectionNeedsPrinting( [atLongTermLiability]) then
      PrintSection( [atLongTermLiability], bhdLong_Term_Liabilities, bhdTotal_Long_Term_Liab, Credit);

    RenderDetailRunningTotal( GetHeading( bhdTotal_Liabilities), Credit );
    ClearRunningTotals;

    //Net Assets
    RenderDetailGrandTotal( GetHeading( bhdNet_Assets), Debit);

    //Equity Section
    PrintSection( [atEquity, atCurrentYearsEarnings], bhdEquity, bhdTotal_Equity, Credit,siGrandTotal );
    DoubleUnderLine;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GetForexFromAndToDate(var aFromDate: TStDate; var aToDate: TStDate);
begin
  with MyClient.clFields do begin
    // Determine the FromDate (always the period start date for opening balances)
    aFromDate := clTemp_Period_Details_This_Year[1].Period_Start_Date;

    // ToDate is always the last day of the month ending
    aToDate := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoBalanceSheet(Destination: TReportDest; RptBatch: TReportBase = nil );
var
   Job               : TBalanceSheetReport;
   i                 : integer;
   cWidth            : double;
   cLeft             : double;
   cGap              : double;
   ReportSettingsID  : string;
   s                 : string;
   TotalPeriodCols   : integer;
   TotalYTDCols      : integer;
   TotalCols         : integer;
   PeriodStartDate   : integer;
   PeriodEndDate     : integer;
   ReportScaleFactor : double;
   NumberFormatStr   : string;
   TotalFormatStr    : string;
   DescriptionWidth  : double;
   aColumn           : TReportColumn;
   BudgetedPeriodsUsed : boolean;

   Old_Show_YTD   : boolean;
   Params : TRptParameters;
   FromDate, ToDate: integer;
   ISOCodes: string;
begin
  //temporarily turn off the YTD flag, not relevant to balance sheet however dont
  //want it to be cleared for cashflow and p&l
  Old_Show_YTD := MyClient.clFields.clFRS_Show_YTD;
  MyClient.clFields.clFRS_Show_YTD := False;

  //TFS 16666
  FlagAllAccountsForUse(MyClient);

  VerifyBalanceSheetPreconditions( MyClient);

   case MyClient.clFields.clFRS_Report_Style of
      crsSinglePeriod   : ReportSettingsID := Report_List_Names[REPORT_BALANCESHEET_SINGLE];
      crsMultiplePeriod : ReportSettingsID := Report_List_Names[REPORT_BALANCESHEET_MULTIPLE];
   else
      ReportSettingsID := Report_List_Names[REPORT_BALANCESHEET_MULTIPLE];
   end;
   MyClient.clFields.clTemp_FRS_Account_Totals_Cash_Only := false;

   //Check Forex
   GetForexFromAndToDate(FromDate, ToDate);
   if not MyClient.HasExchangeRates(ISOCodes, FromDate, ToDate, True, True) then begin
     HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
     Exit;
   end;

   CalculateAccountTotals.AddAutoContraCodes( MyClient);
   try
      CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, True, True);
      CalculateAccountTotals.CalculateCurrentEarnings( MyClient);

      //build the report
      With MyClient, clFields do
      Begin
        if Destination = rdNone then Destination := rdScreen;
        Params := TRptParameters.Create(ord(REPORT_BALANCESHEET_SINGLE),MyClient,RptBatch,dYear);
        Job := TBalanceSheetReport.Create( MyClient, Params);
        try
          Job.LoadReportSettings(UserPrintSettings, ReportSettingsID);


          //Add Headers
          AddCommonHeader(Job);

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          // Build header
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

          s := GetBSHeading(MyClient, bhdBalance_Sheet);
          s := s + ' - ' + frpNames[ clFRS_Reporting_Period_Type] + ' ' + GetGSTString(MyClient);

          if clTemp_FRS_Last_Actual_Period_To_Use < 0 then
            s := 'BUDGETED ' + s;

          s := s + ' ' + StDateToDateString('NNN yyyy', clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date, true);

          AddJobHeader(Job,siTitle,S,true);
          if ( clTemp_FRS_Division_To_Use in [1..glConst.Max_Divisions]) then begin
            s := 'For Division: ' + clCustom_Headings_List.Get_Division_Heading( clTemp_FRS_Division_To_Use);
            AddJobHeader(Job,siSubTitle,S,true);
          end;

          if (clBudget_List.Find_Name( clTemp_FRS_Budget_To_Use) <> nil)
            and ((clFRS_Compare_Type  = cflCompare_To_Budget) or ( clTemp_FRS_Use_Budgeted_Data_If_No_Actual)) then
          begin
            AddJobHeader(Job,siSubTitle, 'Using Budget: ' + clTemp_FRS_Budget_To_Use + ' (' + bkDate2Str( clTemp_FRS_Budget_To_Use_Date) + ')', true);
          end;

          AddJobHeader( Job,siSubTitle, '', true);

          //figure out how many columns there will be
          TotalPeriodCols := Job.iVisiblePeriods * Job.ColumnsPerPeriod;

          if clFRS_Show_YTD then
            TotalYTDCols := Job.ColumnsPerPeriod
          else
            TotalYTDCols := 0;

          //auto calculate width
          TotalCols := TotalPeriodCols + TotalYTDCols;

          if clFRS_Report_Style in [crsSinglePeriod] then begin
            if (Job.ReportTypeParams.RoundValues) then
            begin
              NumberFormatStr  := '#,##0;(#,##0);-';
              TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
            end else
            begin
              NumberFormatStr  := '#,##0.00;(#,##0.00);-';
              TotalFormatStr   := '#,##0.00;(#,##0.00);-';   //note:sign is reversed
            end;
            DescriptionWidth := 22.0;
          end
          else begin
             NumberFormatStr  := '#,##0;(#,##0);-';
             TotalFormatStr   := '#,##0;(#,##0);-';   //note:sign is reversed
             DescriptionWidth := 13.0;
          end;

          //decide on the report scaling factor.  This attempts to automatically
          //reduce the font size to make the columns large enough to contain
          //data
          ReportScaleFactor := 1.0;
          if TotalCols > 13 then begin
            ReportScaleFactor := ( 13 / (TotalCols + 1));
            if ReportScaleFactor > 1.0 then
              ReportScaleFactor := 1.0;

            if ReportScaleFactor < 0.05 then
              ReportScaleFactor := 0.05;
          end;
          cGap := GcGap * ReportScaleFactor;
          Job.ReportScaleFactor := ReportScaleFactor;

          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          //Set up columns for this report
          // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
          cLeft := GcLeft;
          AddColAuto( Job,cLeft ,DescriptionWidth * ReportScaleFactor,cgap, '', jtLeft);          //account column
          cWidth := ( (99.5 - cLeft) / ( TotalCols)) - cGap;

          cWidth := Min(cWidth, 20);

          BudgetedPeriodsUsed := false;
          //Add period columns
          for i := 1 to ( Job.iVisiblePeriods) do begin
            if clFRS_Report_Style in [crsSinglePeriod] then begin
               PeriodStartDate := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_Start_Date;
               PeriodEndDate   := clTemp_Period_Details_This_Year[clTemp_FRS_Last_Period_To_Show].Period_End_Date;
            end
            else begin
              //get period dates, there is a chance that the no of periods in each
              //year may be different, so need to make sure we are getting dates
              //for the correct period
              if i <= clTemp_Periods_This_Year then begin
                 PeriodStartDate := clTemp_Period_Details_This_Year[i].Period_Start_Date;
                 PeriodEndDate   := clTemp_Period_Details_This_Year[i].Period_End_Date;
              end
              else begin
                 PeriodStartDate := clTemp_Period_Details_Last_Year[i].Period_Start_Date;
                 PeriodEndDate   := clTemp_Period_Details_Last_Year[i].Period_End_Date;
              end;
            end;

            //Add actual column
            aColumn :=  AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Actual', jtRight, NumberFormatStr, TotalFormatStr,true);
            case clFRS_Reporting_Period_Type of
              frpMonthly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
              frp2Monthly, frpQuarterly, frp6Monthly, frpYearly : begin
                 aColumn.Caption      := StDatetoDateString('nnn yyyy', PeriodStartDate,true) + '-';
                 aColumn.CaptionLine2 := StDatetoDateString('nnn yyyy', PeriodEndDate,true);
              end;
            end;

            //show the user when budgeted data is being used
            if ( i > clTemp_FRS_Last_Actual_Period_To_Use) and (clTemp_FRS_Use_Budgeted_Data_If_No_Actual) then begin
              if aColumn.CaptionLine2 <> '' then
                aColumn.CaptionLine2 := aColumn.CaptionLine2 + ' **'
              else
                aColumn.Caption := aColumn.Caption + ' **';

              BudgetedPeriodsUsed := true;
            end;

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;

            if clFRS_Report_Style = crsBudgetRemaining then begin
               Assert( false, 'Period columns added to budget remaining report');
            end;
          end;

          if BudgetedPeriodsUsed then
             AddJobFooter( Job,siFootNote, '** = This period contains budgeted data', true);

          //Add YTD columns
          if clFRS_Show_YTD then begin
            //Add actual column
            AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Actual', jtRight, NumberFormatStr, TotalFormatStr,true);

            case clFRS_Compare_Type of
               cflCompare_To_Budget : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Budget', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
               cflCompare_To_Last_Year : begin
                 AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Last Year', jtRight, NumberFormatStr, TotalFormatStr,true);
                 if clFRS_Show_Variance then
                   AddFormatColAuto( Job, cLeft, cWidth, cGap, 'YTD Variance', jtRight, NumberFormatStr, TotalFormatStr,true);
               end;
            end;
          end;


          //Add Footers
          AddCommonFooter(Job);

          Job.OnBKPrint := ListBalanceSheet;
          Job.Generate( Destination, Params );
        finally
         Job.Free;
         Params.Free;
        end;
      end;
   finally
      CalculateAccountTotals.RemoveAutoContraCodes( Myclient);
   end;

   MyClient.clFields.clFRS_Show_YTD := Old_Show_YTD;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetBSHeading(ClientForReport : TClientObj; No : Integer): string;
begin
  result := '';

  if No = -1 then Exit;

  result := ClientForReport.clFields.clBalance_Sheet_Headings[ No ];

  if result = '' then
     result := BalanceSheetHeadings.bhdNames[ No ];

  if Uppercase(result) = 'HIDE' then
     result := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TBalanceSheetReport }

function TBalanceSheetReport.GetHeading(No: Integer): string;
begin
  Result := GetBSHeading(ClientForReport, No);
end;

procedure TBalanceSheetReport.GetValuesForPeriod(const pAcct: pAccount_Rec;
  const ForPeriod: integer; var Values: TValuesArray; UsePeriodStartEnd: boolean = false);
begin
  GetYTD_ValuesForPeriod( pAcct, ForPeriod, Values);
end;

procedure TBalanceSheetReport.GetYTD_ValuesForPeriod(
  const pAcct: pAccount_Rec; const ForPeriod: integer;
  var Values: TValuesArray);
var
  AccountInfo  : TAccountInformation;
  i            : integer;
  ShowLastYear : boolean;
  ShowBudget   : boolean;
begin
  Assert( Length( ColumnTypes) = Length( Values));

  //values for cash flow reports will be in the following order
  // Actual   Comparitive (Budget or Last Year)   Variance    Quantity
  for i := Low( Values) to High( Values) do
     Values[i] := 0;

  ShowLastYear := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Last_Year);
  ShowBudget   := (ClientForReport.clFields.clFRS_Compare_Type = cflCompare_To_Budget);

  AccountInfo := TAccountInformation.Create( ClientForReport);
  try
    AccountInfo.UseBudgetIfNoActualData     := ClientForReport.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
    AccountInfo.LastPeriodOfActualDataToUse := ClientForReport.clFields.clTemp_FRS_Last_Actual_Period_To_Use;
    AccountInfo.AccountCode                 := pAcct.chAccount_Code;
    AccountInfo.UseBaseAmounts              := IsForeignCurrencyClient(ClientForReport);

    for i := Low( Values) to High( Values) do begin
      case ColumnTypes[ i] of
        ftActual : Values[i] := AccountInfo.ClosingBalanceActualOrBudget(ForPeriod);
        ftComparative : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.ClosingBalance_LastYear( ForPeriod);
          if ShowBudget then
             Values[i] := 0;
        end;
        ftVariance : begin
          //does the user want last year or budget
          if ShowLastYear then
             Values[i] := AccountInfo.Variance_ClosingBalance_ActualLastYear( ForPeriod);
          if ShowBudget then
             Values[i] := 0;
        end;
      end;
    end;
  finally
   AccountInfo.Free;
  end;
end;

procedure TBalanceSheetReport.SetupColumnsTypes;
begin
  ClearColumnTypeArray;
  //Assume that the first column will always be actual values
  AddColumnTypeToArray( ftActual);
  with ClientForReport.clFields do begin
    if ( clFRS_Compare_Type in [ cflCompare_To_Budget, cflCompare_To_Last_Year]) then begin
      AddColumnTypeToArray( ftComparative);
      if clFRS_Show_Variance then
         AddColumnTypeToArray( ftVariance);
    end;
  end;
end;

procedure VerifyBalanceSheetPreconditions( ForClient : TClientObj);
begin
   //Check parameters, no need to check booleans
   with ForClient.clFields do begin
     //Persistant Fields
       //clGST_Inclusive_Cashflow
       //clFRS_Print_Chart_Codes
       //clFRS_Show_YTD
       //clFRS_Show_Variance
       //clFRS_Prompt_User_to_use_Budgeted_figures

       Assert( clFRS_Compare_Type in [cflCompare_None, cflCompare_To_Last_Year],
               'clFRS_Compare_Type in [cflCompare_None, cflCompare_To_Last_Year]');
       Assert( clFRS_Reporting_Period_Type in [frpMonthly..frpYearly],
               'clFRS_Reporting_Period_Type in [frpMonthly..frpYearly]');
       Assert( clFRS_Report_Style in [crsSinglePeriod, crsMultiplePeriod],
               'clFRS_Report_Style in [crsSinglePeriod, crsMultiplePeriod]');
       Assert( clReporting_Year_Starts > 0,
               'clReporting_Year_Starts > 0');
       Assert( clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised],
               'clFRS_Report_Detail_Type in [cflReport_Detailed, cflReport_Summarised]');

       //Assert( clGST_Inclusive_Cashflow = false,      allowed as of Nov 2002
       //        'clGST_Inclusive_Cashflow = false');

     //Non-persistant fields
       Assert( clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]],
               'clTemp_FRS_Last_Period_To_Show in [0..pdMaximumNoOfPeriods[ clFRS_Reporting_Period_Type]]');
       Assert( clTemp_FRS_Division_To_Use in [ 0..Max_Divisions],
               'clTemp_FRS_Division_To_Use in [ 0..Max_Divisions]');
       Assert( clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show,
               'clTemp_FRS_Last_Actual_Period_To_Use <= clTemp_FRS_Last_Period_To_Show');

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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
// Export balance sheet data to Excel.
//
procedure DoBalanceExport;
  procedure RenderToExcel(ExcelRange : TOpExcelRange; Col, Row, AFontSize : Integer; FontBold : Boolean; AValue : String);
  begin
    with ExcelRange do begin
      Address := ExcelAddress(Col, Row);
      FontSize := AFontSize;
      if (FontBold) then
        FontAttributes := [xlfaBold]
      else
        FontAttributes := [];
      //format cell
      AsRange.NumberFormat := '@';
      Value := AValue;
    end;
  end;

const
  THIS_YEAR_LEFT = 4;
  LAST_YEAR_LEFT = 17;
  BUDGET_LEFT = 30;
  REPORT_HEADER : Array[0..3] of String =
    ('Code', 'Description', 'Report Group', 'Sub-Group');
var
  dlgCheckBoxOptions: TdlgCheckBoxOptions;
  IncGST, IncBudget : boolean;
  Budget : tBudget;
  MyDataModule : TDataModuleOffice;
  ExcelRange   : TOpExcelRange;

  Old_Show_YTD : boolean;
  i, PeriodNo : Integer;
  CurrentLineNo : Integer;
  HeaderLineNo : Integer;

  PeriodEndDate    : integer;

  pAcct: pAccount_Rec;
  AccountInfo  : TAccountInformation;
  MValue, MTotal : Money;
  S      : string;
begin
  dlgCheckBoxOptions := TdlgCheckBoxOptions.Create(Application.MainForm);
  try
    with dlgCheckBoxOptions do
    begin
      Caption := GetBSHeading(MyClient, bhdBalance_Sheet) + ' - Export';
      lblLine1.Caption := 'Choose which options to include in the Export.';
      chkBox1.Caption := 'GST Inclusive';
      chkBox1.Checked := False;
      chkBox1.Visible := True;
      chkBox2.Caption := 'Include Budget';
      chkBox2.Checked := True;
      chkBox2.Visible := True;
      if (ShowModal = mrOK) then
      begin
        IncGST := chkBox1.Checked;
        IncBudget := chkBox2.Checked;
      end else
        Exit;
    end;
  finally
    dlgCheckBoxOptions.Free;
  end;

  if (IncBudget) then
  begin
    Budget := SelectBudget('Select a Budget', MyClient.clFields.clReporting_Year_Starts);
    if not Assigned( Budget ) then
      Exit;
  end else
    Budget := nil;

  //temporarily turn off the YTD flag, not relevant to balance sheet however dont
  //want it to be cleared for cashflow and p&l
  Old_Show_YTD := MyClient.clFields.clFRS_Show_YTD;

  with MyClient, Myclient.clFields do
  begin
    clFRS_Compare_Type                        := cflCompare_None;

    clFRS_Show_Variance                       := False;
    clFRS_Show_YTD                            := False;
    clFRS_Show_Quantity                       := False;

    clFRS_Reporting_Period_Type               := frpMonthly;
    clFRS_Report_Style                        := crsMultiplePeriod;

    clFRS_Report_Detail_Type                  := cflReport_Detailed;

    clGST_Inclusive_Cashflow                  := IncGst;
    clFRS_Prompt_User_to_use_Budgeted_figures := False;

    //now save temporary client variables
    clTemp_FRS_Last_Period_To_Show            := pdMaximumNoOfPeriods[ frpMonthly];
    clTemp_FRS_Last_Actual_Period_To_Use      := clTemp_FRS_Last_Period_To_Show;
    clTemp_FRS_From_Date                      := 0;
    clTemp_FRS_To_Date                        := 0;
    clTemp_FRS_Account_Totals_Cash_Only       := false;

    if (IncBudget) then
    begin
      clTemp_FRS_Budget_To_Use                := Budget.buFields.buName;
      clTemp_FRS_Budget_To_Use_Date           := Budget.buFields.buStart_Date;
    end
    else
    begin
      clTemp_FRS_Budget_To_Use                := '';
      clTemp_FRS_Budget_To_Use_Date           := -1;
    end;
    //Budgeted data will be shown seperately to the actual data so dont use in actual section
    clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
  end;

  //check pre conditions
  VerifyBalanceSheetPreconditions( MyClient);

  CalculateAccountTotals.AddAutoContraCodes( MyClient);
  try
    CalculateAccountTotals.CalculateAccountTotalsForClient( MyClient, True, nil, -1, False, True, True);

    MyDataModule := TDataModuleOffice.Create( nil);

    if Assigned( MyDataModule) then
    begin
      try
        //create the data module that contains the Excel component
        with MyDataModule do begin
           //connect to Excel
           OpExcel1.Connected := true;

           with OpExcel1 do begin
              WindowState := XlwsNormal;
              Caption     := ShortAppName + ' Report in Microsoft Excel';
              Interactive := False; // Don't let the user access it
              //Add initial workbook and range
              Workbooks.Add;
              ExcelRange := Workbooks[0].Worksheets[0].Ranges.Add;
              // show it
              Visible     := true;

              with ExcelRange do begin
                Address := 'A1';
                AsRange.Font.Color := clNavy;
                AsRange.Font.Size  := 16;
                Value   := 'Generating Report: Loading report data...'
              end;

              with ExcelRange do begin
                Address := 'A2';
                AsRange.Font.Size := 12;
                AsRange.Font.Bold := True;
                //format cell
                AsRange.NumberFormat := '@';
                Value   := MyClient.clFields.clName;

                Address := 'A3';
                AsRange.Font.Size := 16;
                AsRange.Font.Bold := True;
                //format cell
                AsRange.NumberFormat := '@';
                Value   := GetBSHeading(MyClient, bhdBalance_Sheet) + ' - ' + GetGSTString(MyClient) +
                  StDateToDateString('NNN yyyy', MyClient.clFields.clTemp_Period_Details_This_Year[MyClient.clFields.clTemp_FRS_Last_Period_To_Show].Period_End_Date, true);
              end;
              if (IncBudget) then
              begin
                with ExcelRange do begin
                  Address := 'A4';
                  AsRange.Font.Size := 10;
                  AsRange.Font.Bold := True;
                  //format cell
                  AsRange.NumberFormat := '@';
                  Value   := 'Using Budget: ' + MyClient.clFields.clTemp_FRS_Budget_To_Use + ' (' + bkDate2Str( MyClient.clFields.clTemp_FRS_Budget_To_Use_Date) + ')';
                end;
              end;
              CurrentLineNo := 7;

              RenderToExcel(ExcelRange, THIS_YEAR_LEFT + 1, CurrentLineNo-1, 10, True, 'This Year');
              RenderToExcel(ExcelRange, LAST_YEAR_LEFT + 1, CurrentLineNo-1, 10, True, 'Last Year');
              if (IncBudget) then
                RenderToExcel(ExcelRange, BUDGET_LEFT + 1, CurrentLineNo-1, 10, True, 'Budget');

              for i := 0 to 3 do
                RenderToExcel(ExcelRange, i, CurrentLineNo, 10, True, REPORT_HEADER[i]);

              //this year
              for i := 1 to 12 do
              begin
                PeriodEndDate := MyClient.clFields.clTemp_Period_Details_This_Year[i].Period_End_Date;
                RenderToExcel(ExcelRange, THIS_YEAR_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
              end;
              //last year
              for i := 1 to 12 do
              begin
                PeriodEndDate := MyClient.clFields.clTemp_Period_Details_Last_Year[i].Period_End_Date;
                RenderToExcel(ExcelRange, LAST_YEAR_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
              end;
              if (IncBudget) then
              begin
                //budget
                for i := 1 to 12 do
                begin
                  PeriodEndDate := MyClient.clFields.clTemp_Period_Details_This_Year[i].Period_End_Date;
                  RenderToExcel(ExcelRange, BUDGET_LEFT + i, CurrentLineNo, 10, True, StDatetoDateString('nnn yyyy', PeriodEndDate,true));
                end;
              end;

              HeaderLineNo := CurrentLineNo;
              CurrentLineNo := CurrentLineNo + 2;

              AccountInfo := TAccountInformation.Create(MyClient);
              try
                AccountInfo.UseBudgetIfNoActualData     := MyClient.clFields.clTemp_FRS_Use_Budgeted_Data_If_No_Actual;
                AccountInfo.LastPeriodOfActualDataToUse := MyClient.clFields.clTemp_FRS_Last_Actual_Period_To_Use;

                //cycle thru accounts
                for i := 0 to MyClient.clChart.ItemCount - 1 do
                begin
                  pAcct := MyClient.clChart.Account_At(i);
                  RenderToExcel(ExcelRange, 0, CurrentLineNo, 10, False, Trim( pAcct^.chAccount_Code));
                  RenderToExcel(ExcelRange, 1, CurrentLineNo, 10, False, Trim( pAcct^.chAccount_Description));

                  if pAcct^.chAccount_Type in [atMin..atMax] then
                    S := Localise( MyClient.clFields.clCountry, atNames[pAcct^.chAccount_Type])
                  else
                    S := '';
                  RenderToExcel(ExcelRange, 2, CurrentLineNo, 10, False, S);

                  S := Trim(MyClient.clCustom_Headings_List.Get_SubGroup_Heading( pAcct^.chSubType));
                  RenderToExcel(ExcelRange, 3, CurrentLineNo, 10, False, S);

                  AccountInfo.AccountCode := pAcct.chAccount_Code;
                  //this year
                  MTotal := 0;
                  for PeriodNo := 1 to 12 do
                  begin
                    MValue := (AccountInfo.ActualOrBudget(PeriodNo) / 100);
                    MTotal := MTotal + MValue;
                    RenderToExcel(ExcelRange, THIS_YEAR_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MTotal));
                  end;
                  //last year
                  MTotal := 0;
                  for PeriodNo := 1 to 12 do
                  begin
                    MValue := (AccountInfo.LastYear(PeriodNo) / 100);
                    MTotal := MTotal + MValue;
                    RenderToExcel(ExcelRange, LAST_YEAR_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MTotal));
                  end;
                  if (IncBudget) then
                  begin
                    //budget
                    MTotal := 0;
                    for PeriodNo := 1 to 12 do
                    begin
                      MValue := (AccountInfo.Budget(PeriodNo) / 100);
                      MTotal := MTotal + MValue;
                      RenderToExcel(ExcelRange, BUDGET_LEFT + PeriodNo, CurrentLineNo, 10, False, FormatFloat('#,##0.00;(#,##0.00);0',MTotal));
                    end;
                  end;
                  Inc(CurrentLineNo);
                end;
              finally
               AccountInfo.Free;
              end;
           end;

           //autosize columns
           with ExcelRange do
           begin
             Address := 'A1';
             Value   := 'Generating Report: Auto sizing columns...';

             if (IncBudget) then
               Address := ExcelAddress( 0, HeaderLineNo) + ':' + ExcelAddress( BUDGET_LEFT + 12, CurrentLineNo)
             else
               Address := ExcelAddress( 0, HeaderLineNo) + ':' + ExcelAddress( LAST_YEAR_LEFT + 12, CurrentLineNo);

             AsRange.Columns.AutoFit;
           end;

           //remove please wait text...
           with ExcelRange do begin
              Address := 'A1';
              Value   := '';
           end;
           OpExcel1.Interactive := True; // Let the user access it
           //maximise when finished
           OpExcel1.WindowState := xlwsMaximized;
        end;

        HelpfulInfoMsg('Click OK if you have finished using Excel.',0);
      finally
        //Make sure memory is freed before leaving
        MyDataModule.Free;
      end;
    end;

  finally
    CalculateAccountTotals.RemoveAutoContraCodes( MyClient);
  end;

  MyClient.clFields.clFRS_Show_YTD := Old_Show_YTD;
end;

end.
