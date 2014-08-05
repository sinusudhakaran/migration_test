unit ProfitAndLossOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:       Profit and Loss Reporting Options Dialog

   Description: Updates the P&L reporting options that are stored in
                the client file.  Used when user has selected "Custom" P&L
                reporting.

   Author:      Matthew Hopkins  May 2002

   Remarks:     All of the financial reporting dialogs could be modified
                to descend from a common form.  Add this to the clean up list
}
//------------------------------------------------------------------------------


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzSpnEdt, ComCtrls, RzDTP, ExtCtrls,
  CheckLst, clObj32, RptParams, UBatchBase, DateSelectorFme, PeriodUtils,
  Buttons,
  bkXPThemes,
  OSFont, DivisionSelectorFme, AccountSelectorFme;

type
  TdlgProfitAndLossOptions = class(TForm)
    pnlButtons: TPanel;
    btnPrint: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    pnlReportStyle: TPanel;
    pnlCompare: TPanel;
    pnlInclude: TPanel;
    Label6: TLabel;
    Label2: TLabel;
    cmbDetail: TComboBox;
    cmbStyle: TComboBox;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Label1: TLabel;
    chkCompare: TCheckBox;
    rbToBudget: TRadioButton;
    rbToLastYear: TRadioButton;
    chkIncludeVariance: TCheckBox;
    chkIncludeYTD: TCheckBox;
    Label5: TLabel;
    rbDetailedFormat: TRadioButton;
    rbSummarisedFormat: TRadioButton;
    cmbBudget: TComboBox;
    chkIncludeCodes: TCheckBox;
    pnlDivision: TPanel;
    pnlAdvBudget: TPanel;
    chkPromptToUseBudget: TCheckBox;
    pnlPeriodDates: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    lblLast: TLabel;
    cmbPeriod: TComboBox;
    chkIncludeQuantity: TCheckBox;
    chkGSTInclusive: TCheckBox;
    stReportStarts: TLabel;
    cbPercentage: TCheckBox;
    btnSave: TBitBtn;
    cbJobs: TComboBox;
    ckAllJobs: TCheckBox;
    Label8: TLabel;
    tsbDivisions: TTabSheet;
    Panel1: TPanel;
    fmeDivisionSelector1: TfmeDivisionSelector;
    tbsAdvanced: TTabSheet;
    Panel2: TPanel;
    fmeAccountSelector1: TfmeAccountSelector;
    pnlIncludeNonPost: TPanel;
    rbSummarisedNonPost: TRadioButton;
    rbDetailedNonPost: TRadioButton;
    chkPrintNonPostingChartCodeTitles: TCheckBox;
    btnEmail: TButton;

    procedure chkCompareClick(Sender: TObject);
    procedure rbDetailedFormatClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure rbToBudgetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbPeriodDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbStartMonthChange(Sender: TObject);
    procedure spnStartYearChange(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbDetailChange(Sender: TObject);
    procedure cmbStyleChange(Sender: TObject);
    procedure cmbPeriodChange(Sender: TObject);
    procedure cmbBudgetChange(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure ckAllJobsClick(Sender: TObject);
    procedure chkPrintNonPostingChartCodeTitlesClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  protected
    { Private declarations }
    LastPeriodOfActualData : integer;
    MonthArray           : TMonthArray;
    ThisClient           : TClientObj;
    tmpYearStarts        : Integer;
    SettingsBeingUpdated : boolean;
    Params :TCustomRptParameters;
    procedure LoadBudgetCombo;
    procedure LoadClientSettings; virtual;
    procedure ReloadJobCombo;
    procedure SetJob(Value: string);
    procedure RecalcDates;
    procedure SaveClientSettings(BudgetPrompt : Boolean); virtual;
    procedure SaveBatchSettings; virtual;
    procedure UpdateStartDate;

    procedure UpdateControlsOnForm; virtual;
    function  VerifyForm : boolean; virtual;
    procedure GenerateReport; virtual;
  public
    { Public declarations }
  end;

  function UpdateProfitandLossReportOptions( const aClient : TClientObj; Rptbatch : TReportBase = nil) : integer;

//******************************************************************************
implementation

uses
   BaList32,
   baObj32,
   bkConst,
   bkDateUtils,
   bkDefs,
   BKHelp,
   budObj32,
   clDateUtils,
   ComboUtils,
   GLConst,
   globals,
   imagesfrm,
   Reports,
   ReportDefs,
   dlgAddFavourite,
   stDate,
   stDatest,
   UseBudgetedDataDlg,
   WarningMoreFrm;

{$R *.dfm}

const
   ValidPeriodTypesForBudgetSet = [ frpMonthly,
                                    frp2Monthly,
                                    frpQuarterly,
                                    frp6Monthly,
                                    frpYearly ];

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.chkCompareClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.chkPrintNonPostingChartCodeTitlesClick(
  Sender: TObject);
begin
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.ckAllJobsClick(Sender: TObject);
begin
   ReloadJobCombo;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.rbDetailedFormatClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.btnCancelClick(Sender: TObject);
begin
   params.RunBtn := Globals.BTN_NONE;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.rbToBudgetClick(Sender: TObject);
begin
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.FormCreate(Sender: TObject);
var
   i : integer;
begin
   //BugzId: 11686
   tbsAdvanced.TabVisible := false;

   //params.RunBtn := Globals.BTN_NONE;
   bkXPThemes.ThemeForm(Self);
   SettingsBeingUpdated := false;

   //load combos with const values
   //load report styles
   cmbStyle.Items.Clear;
   for i := crsMin to crsMax do begin
      //only add value report styles
      if i in [ crsSinglePeriod, crsMultiplePeriod {, crsBudgetRemaining} ] then begin
         cmbStyle.Items.AddObject( crsNames[ i], TObject(i));
      end;
   end;
   //set default
   SetComboIndexByIntObject( crsSinglePeriod, cmbStyle);

   //load report detail (financial reporting periods)
   cmbDetail.Items.Clear;
   for i := frpMin to frpMax do begin
      //only add value report styles
      if i in [ frpMonthly .. frpYearly] then begin
         cmbDetail.Items.AddObject( frpNames[ i], TObject(i));
      end;
   end;
   //set default
   SetComboIndexByIntObject( frpMonthly, cmbDetail);

   //load report year starts months
   cmbStartMonth.Items.Clear;
   for i := ( moMin + 1) to moMax do
      cmbStartMonth.Items.Add( moNames[ i]);
   //set default
   cmbStartMonth.ItemIndex := 0;

   PageControl1.ActivePage := tbsOptions;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.FormDestroy(Sender: TObject);
begin
   MonthArray := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.LoadBudgetCombo;
var
  clM : Integer;
  buD, buM, buY : Integer;
  i : integer;
  S : string;
begin
  clM := cmbStartMonth.ItemIndex + 1;
  //load budget combo
  cmbBudget.Items.Clear;
  with ThisClient do begin
    for i:= clBudget_List.ItemCount-1 downto 0 do
    with clBudget_List.Budget_At(i) do begin
      StDateToDMY(buFields.buStart_Date, buD, buM, buY );
      if (buM = clM) then
      begin
        S := buFields.buName + ' (' + bkDate2Str(buFields.buStart_Date) + ')';
        cmbBudget.Items.AddObject(S, clBudget_List.Budget_At(i));
      end;
    end;
  end;
  if cmbBudget.Items.Count > 0 then
     cmbBudget.ItemIndex := 0
  else
     cmbBudget.ItemIndex := -1; // It will be anyway...
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.LoadClientSettings;
//load the client settings into the dialog
var
   d,m,y : integer;
   bu    : TBudget;
begin
   //set the reporting year starts fields
   tmpYearStarts := ThisClient.clFields.clReporting_Year_Starts;
   StDateToDMY( tmpYearStarts, d, m, y);

   spnStartYear.Value := y;
   cmbStartMonth.ItemIndex := m - 1;

   //fill the ending combo box with valid months
   RecalcDates;

   {load accounts}
   fmeAccountSelector1.LoadAccounts( ThisClient, [ btBank, btCashJournals, btAccrualJournals,
                                                   btStockJournals, btYearEndAdjustments]);

   with ThisClient.clFields do begin
      //load settings
      chkIncludeQuantity.checked := clFRS_Show_Quantity;

      chkIncludeCodes.checked    := clFRS_Print_Chart_Codes;
      chkIncludeYTD.checked      := clFRS_Show_YTD;
      chkIncludeVariance.checked := clFRS_Show_Variance;
      chkPrintNonPostingChartCodeTitles.Checked :=
        ThisClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
      rbDetailedNonPost.checked   :=
        (ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type = cflReport_Detailed);
      rbSummarisedNonPost.checked   :=
        (ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type = cflReport_Summarised);

      chkGSTInclusive.Checked    := clGST_Inclusive_Cashflow;

      chkCompare.Checked         := ( clFRS_Compare_Type <> cflCompare_None);
      rbToBudget.Checked         := ( clFRS_Compare_Type  = cflCompare_To_Budget);
      rbToLastYear.Checked       := ( clFRS_Compare_Type  = cflCompare_To_Last_Year);

      SetComboIndexByIntObject( clFRS_Report_Style,  cmbStyle);
      SetComboIndexByIntObject( clFRS_Reporting_Period_Type, cmbDetail);

      rbDetailedFormat.checked   := ( clFRS_Report_Detail_Type = cflReport_Detailed);
      rbSummarisedFormat.checked := ( clFRS_Report_Detail_Type = cflReport_Summarised);
      cbPercentage.Checked := clProfit_Report_Show_Percentage;
      //load the following temporary settings
      bu := ThisClient.clBudget_List.Find_Name( clTemp_FRS_Budget_To_Use);
      if Assigned(bu) then begin
        //find item that matches this budget
        SetComboIndexByIntObject( Integer( Bu), cmbBudget);
      end
      else
        cmbBudget.ItemIndex := -1;

      chkPromptToUseBudget.checked := clFRS_Prompt_User_to_use_Budgeted_figures;
   end;

   //set the states of all the control
   UpdateControlsOnForm;
   UpdateStartDate;

   //fill the ending combo box with valid months no that have set
   RecalcDates;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.SaveBatchSettings;
var
  i: integer;
begin
   //pick up the settings
   // Do the 'Fixed' ones first
   with params, Client.clFields do begin
     if clFRS_Report_Style= crsSinglePeriod then
        RptBatch.Title := Report_List_Names[REPORT_PROFITANDLOSS_SINGLE]
     else
        RptBatch.Title := Report_List_Names[REPORT_PROFITANDLOSS_MULTIPLE];

     ShowGst    := clGST_Inclusive_Cashflow;
     ChartCodes := clFRS_Print_Chart_Codes;
     PrintNPChartCodeTitles := Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
     NPChartCodeDetailType := Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type;

     if cmbBudget.ItemIndex >= 0 then
        Budget :=  TBudget(cmbBudget.Items.Objects[cmbBudget.ItemIndex])
     else Budget := nil;

     //Load divisions from client into params
     Division := 0;
     Params.DivisionList.Clear;
     if (Length(clTemp_FRS_Divisions) > 0) then
       for i := 0 to Length(clTemp_FRS_Divisions) - 1 do
         if clTemp_FRS_Divisions[i] then
           Params.DivisionList.Add(TObject(i));

     SaveNodesettings;// Clears and saves the fixed ones

     SetBatchBool('Year_To_Date', clFRS_Show_YTD);
     SetBatchBool('Show_Quantity', clFRS_Show_Quantity);
     SetBatchBool('Include_Variance', clFRS_Show_Variance);
     SetBatchBool('Summarised', clFRS_Report_Detail_Type= cflReport_Summarised);
     SaveBatchReportPeriod(clFRS_Reporting_Period_Type);
     SaveBatchReportStyle (clFRS_Report_Style);
     SaveBatchReportCompare(clFRS_Compare_Type);
     SetBatchBool('Show_Percentage', clProfit_Report_Show_Percentage);
     SetBatchBool('Prompt_for_Budget', clFRS_Prompt_User_to_use_Budgeted_figures);
     SetBatchText('Job',cbJobs.Text);
     SetBatchBool('Split_By_Division', clTemp_FRS_Split_By_Division);
     SaveBatchDivisions;
     SaveBatchAccounts;
   end;
end;

procedure TdlgProfitAndLossOptions.SaveClientSettings(BudgetPrompt : Boolean);
var
  BudgetToUse : string;
  BudgetDate: Integer;
  AskForBudget: boolean;
begin
   with ThisClient.clFields do begin
      clFRS_Show_Quantity        := chkIncludeQuantity.checked and chkIncludeQuantity.enabled;
      clFRS_Print_Chart_Codes    := chkIncludeCodes.Checked; // and chkIncludeCodes.Enabled;
      clFRS_Show_YTD             := chkIncludeYTD.Checked; //and chkIncludeYTD.Enabled;
      clGST_Inclusive_Cashflow   := chkGSTInclusive.Checked;
      clProfit_Report_Show_Percentage := cbPercentage.Checked;
      ThisClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles :=
        chkPrintNonPostingChartCodeTitles.Checked;
      ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type := cflReport_Detailed;
      if rbSummarisedNonPost.Checked and chkPrintNonPostingChartCodeTitles.Checked then
        ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type := cflReport_Summarised;

      //clFRS_Compare_Type
      clFRS_Show_Variance        := false;
      clFRS_Compare_Type         := cflCompare_None;
      if chkCompare.Checked then begin      //and chkCompare.Enabled
         if rbToBudget.Checked then
            clFRS_Compare_Type  := cflCompare_To_Budget;
         if rbToLastYear.Checked then
            clFRS_Compare_Type  := cflCompare_To_Last_Year;

         clFRS_Show_Variance     := chkIncludeVariance.Checked;
      end;
      clFRS_Reporting_Period_Type  := GetComboCurrentIntObject( cmbDetail);
      clFRS_Report_Style        := GetComboCurrentIntObject( cmbStyle);
      clReporting_Year_Starts            := tmpYearStarts;
      if rbDetailedFormat.checked then
         clFRS_Report_Detail_Type   := cflReport_Detailed //detailed
      else
         clFRS_Report_Detail_Type   := cflReport_Summarised;  //summaried

      clFRS_Prompt_User_to_use_Budgeted_figures  := chkPromptToUseBudget.Checked;

      clTemp_FRS_Last_Period_To_Show  := cmbPeriod.ItemIndex + 1;
      clTemp_FRS_Last_Actual_Period_To_Use := clTemp_FRS_Last_Period_To_Show;
      cltemp_FRS_from_Date            := 0;
      clTemp_FRS_To_Date            := 0;
      clTemp_FRS_Job_To_Use         := '';

      //Divisions
      clTemp_FRS_Split_By_Division := fmeDivisionSelector1.chkSplitByDivision.Checked;
      clTemp_FRS_Division_To_Use := 0;
      SetLength(clTemp_FRS_Divisions, 0);
      fmeDivisionSelector1.UpdateClientDivisions(ThisClient);

      if cbJobs.ItemIndex > 0 then
         clTemp_FRS_Job_To_Use := cbJobs.Items[cbJobs.ItemIndex]
      else
         clTemp_FRS_Job_To_Use := '';

      Params.FromDate := clReporting_Year_Starts;
      Params.ToDate := MonthArray[clTemp_FRS_Last_Period_To_Show].PeriodEndDate;

      //store this so can use the default if needed in the UseBudgeted... dlg
      BudgetToUse := clTemp_FRS_Budget_To_Use;

      //see if a budget has been specified
      if  (clFRS_Compare_Type = cflCompare_To_Budget)
      and (cmbBudget.Items.Count > 0)
      and (cmbBudget.ItemIndex >= 0) then
      begin
        clTemp_FRS_Budget_To_Use      := TBudget( GetComboCurrentIntObject( cmbBudget)).buFields.buName;
        clTemp_FRS_Budget_To_Use_Date := TBudget( GetComboCurrentIntObject( cmbBudget)).buFields.buStart_Date;
      end else begin
        clTemp_FRS_Budget_To_Use      := '';
        clTemp_FRS_Budget_To_Use_Date := -1;
      end;

      //prompt the user to use budget figures in have selected a period past
      //the lsat period that has data.
      clTemp_FRS_Use_Budgeted_Data_If_No_Actual := false;
      if (clTemp_FRS_Last_Period_To_Show > LastPeriodOfActualData) and
         (clFRS_Prompt_User_to_use_Budgeted_figures) and
         (BudgetPrompt) then
      begin
        //see if should prompt
        //dont prompt if doing budget remaining report
        if not ((clFRS_Report_Style    = crsBudgetRemaining) or
                (cmbBudget.Items.Count = 0) or
                (not(clFRS_Reporting_Period_Type in ValidPeriodTypesForBudgetSet))) then
//                (clCflw_Cash_On_Hand_Style = cflCash_On_Hand_Detailed)) then
        begin
          AskForBudget := (clTemp_FRS_Budget_To_Use = '');

          if UseBudgetedFigures( ThisClient, AskForBudget,
             MonthArray[ LastPeriodOfActualData].PeriodEndDate,
             MonthArray[ clTemp_FRS_Last_Period_To_Show].PeriodEndDate, BudgetToUse, BudgetDate) then
            clTemp_FRS_Use_Budgeted_Data_If_No_Actual := true;

          if AskForBudget then
          begin
            clTemp_FRS_Budget_To_Use := BudgetToUse;
            clTemp_FRS_Budget_To_Use_Date := BudgetDate;
          end;
        end;
      end;
   end;

   //Save bank accounts
   //Don't use account selection for Profit and Loss report TFS 10495
   //fmeAccountSelector1.SaveAccounts(ThisClient, Params);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.SetJob(Value: string);
var lj: pJob_Heading_Rec;
begin
   cbJobs.ItemIndex := cbJobs.Items.IndexOf(Value);
   if cbJobs.ItemIndex < 0 then begin
       lj := ThisClient.clJobs.FindName(Value);
       if lj <> nil then
         cbJobs.ItemIndex := cbJobs.Items.AddObject(Value,TObject(lj.jhLRN));
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.cmbPeriodDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  //This ensures the correct highlite color is used
  cmbPeriod.canvas.fillrect(rect);
  //This line draws the actual bitmap
  AppImages.Period.Draw(cmbPeriod.Canvas,rect.left,rect.top,MonthArray[index+1].ImageIndex);
  //This line writes the text after the bitmap
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+2,rect.top,  MonthArray[index+1].Day);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+20,rect.top,  MonthArray[index+1].Month);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+60,rect.top, MonthArray[index+1].Year);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+100,rect.top, MonthArray[index+1].Status);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.RecalcDates;
type
   tState = ( Coded, Uncoded, NoData );
var
   d,m,y,pd : integer;
   State    : tState;
   MaxCoded : integer;
   PeriodType : integer;
   MaxPeriods : integer;
   tmpYearEnds : integer;
begin
   //get the year starts date from the combo and spin box
   d := 1;
   m := cmbStartMonth.ItemIndex + 1;
   y := spnStartYear.IntValue;
   tmpYearStarts := DmyToStDate( d,m,y, bkDateEpoch);
   tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);

   with ThisClient.clFields do
   begin
      MaxCoded   := 0;
      LastPeriodOfActualData := 0;
      PeriodType := GetComboCurrentIntObject( cmbDetail);

      pnlPeriodDates.Visible := true;
      MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( ThisClient, tmpYearStarts, tmpYearEnds, false, PeriodType,
                                                            clTemp_Period_Details_This_Year);
      //need to resize the months array to the correct size
      cmbPeriod.Items.Clear;
      SetLength( MonthArray, MaxPeriods + 1);

      for pd := 1 to MaxPeriods do
      begin
         cmbPeriod.Items.Add('');

         MonthArray[pd].Day   := stDateToDateString( 'dd',  clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Month := stDateToDateString( 'nnn',  clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Year  := stDateToDateString( 'yyyy', clTemp_Period_Details_This_Year[pd].Period_End_Date, true );

         MonthArray[pd].PeriodStartDate := clTemp_Period_Details_This_Year[pd].Period_Start_Date;
         MonthArray[pd].PeriodEndDate   := clTemp_Period_Details_This_Year[pd].Period_End_Date;

         State := NoData;
         If clTemp_Period_Details_This_Year[pd].HasData then begin
           LastPeriodOfActualData := pd;

           if not( clTemp_Period_Details_This_Year[pd].HasUncodedEntries) then
             State := Coded
           else
             State := Uncoded;
         end;

         Case State of
           Coded    : begin
                        MonthArray[pd].Status := 'CODED';
                        MonthArray[pd].imageIndex := 0;
                      end;

           Uncoded  : begin
                        MonthArray[pd].Status := 'Uncoded';
                        MonthArray[pd].imageIndex := 1;
                      end;

           NoData   : begin
                        MonthArray[pd].Status := '';
                        MonthArray[pd].imageIndex := -1;
                      end;
         end;

         if (State = Coded) and (pd > MaxCoded) then MaxCoded := pd;
      end;

      if MaxCoded > 0 then
        lblLast.caption := 'The last period of CODED data ends '+ MonthArray[MaxCoded].Day + ' '
                                                               + MonthArray[MaxCoded].Month + ' '
                                                               + MonthArray[MaxCoded].Year
      else
      begin
        lblLast.caption := 'There is no period which is completely CODED.';
        MaxCoded := 1;
      end;
      //move to the last coded field by default
      cmbPeriod.ItemIndex := MaxCoded -1;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.ReloadJobCombo;
var selJob: Integer;
begin
  if cbJobs.ItemIndex > 0 then
     SelJob := integer(cbJobs.Items.Objects[cbJobs.ItemIndex])
  else
     SelJob := 0;
  if ckAllJobs.Checked then
     ThisClient.clJobs.AssigntoDropDown(cbJobs.Items, MaxLongint )
  else
     ThisClient.clJobs.AssigntoDropDown(cbJobs.Items);

  if SelJob <> 0 then
    cbJobs.ItemIndex := cbJobs.Items.IndexOfObject(ToBject(SelJob))
  else
    cbJobs.ItemIndex := -1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.cmbStartMonthChange(Sender: TObject);
begin
  RecalcDates;
  LoadBudgetCombo;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.spnStartYearChange(Sender: TObject);
begin
   RecalcDates;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.btnPreviewClick(Sender: TObject);
begin
  if VerifyForm then begin
    params.RunBtn := Globals.BTN_PREVIEW;
    GenerateReport;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.btnEmailClick(Sender: TObject);
begin
  if VerifyForm then begin
    params.RunBtn := Globals.BTN_EMAIL;
    GenerateReport;
  end;
end;

procedure TdlgProfitAndLossOptions.btnFileClick(Sender: TObject);
begin
  if VerifyForm then begin
    params.RunBtn := Globals.BTN_FILE;
    GenerateReport;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.btnPrintClick(Sender: TObject);
begin
  if VerifyForm then begin
    Params.RunBtn := Globals.BTN_OKPRINT;
    GenerateReport;
    if params.BatchRunMode = R_Batch then
       Close;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.BtnSaveClick(Sender: TObject);
begin
  if VerifyForm then begin
    if not Params.CheckForBatch then
       Exit;

    Params.RunBtn  := Globals.BTN_SAVE;
    if params.BatchSave then begin

      SaveClientSettings(False);
      SaveBatchSettings;
      Close

    end else
      Close;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateProfitAndLossReportOptions( const aClient : TClientObj; Rptbatch : TReportBase = nil) : integer;
//all of the reporting variables are now stored in Client.clFields...
//most of the settings are persistent so that the user will see their last
//settings when they reenter the dialog.
//returns the value of the button pressed
var
  ProfitAndLossOptions : TdlgProfitAndLossOptions;
begin
   ProfitAndLossOptions := TdlgProfitAndLossOptions.Create(Application.MainForm);
   with ProfitAndLossOptions do begin
      BKHelpSetUp(ProfitAndLossOptions, BKH_Profit_Loss_Custom);
      Params := TCustomRptParameters.Create(ord(Report_ProfitandLoss_Single),AClient,RptBatch,DYear,True);
      try
        ThisClient := aClient;
        chkGSTInclusive.Caption := aClient.TaxSystemNameUC + ' Inclusive';
        ReloadJobCombo;
        if assigned(RptBatch) then with Params, Client.clFields Do begin
           clProfit_Report_Show_Percentage           := GetBatchBool('Show_Percentage', clProfit_Report_Show_Percentage);
           clFRS_Compare_Type                        := GetBatchReportCompare(clFRS_Compare_Type);
           clFRS_Show_YTD                            := GetBatchBool('Year_To_Date',  clFRS_Show_YTD);
           clFRS_Show_Quantity                       := GetBatchBool('Show_Quantity',  clFRS_Show_Quantity);
           clFRS_Show_Variance                       := GetBatchBool('Include_Variance',  clFRS_Show_Variance);

           clFRS_Reporting_Period_Type               := GetBatchReportPeriod(clFRS_Reporting_Period_Type);
           clFRS_Report_Style                        := GetBatchReportStyle (clFRS_Report_Style);
           clFRS_Report_Detail_Type                  := integer(
                                                           GetBatchBool('Summarised',clFRS_Report_Detail_Type= cflReport_Summarised));

           clGST_Inclusive_Cashflow                  := ShowGST;
           clFRS_Print_Chart_Codes                   := ChartCodes;
           Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles := PrintNPChartCodeTitles;
           Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type := NPChartCodeDetailType;
           clFRS_Prompt_User_to_use_Budgeted_figures := GetBatchBool('Prompt_for_Budget', clFRS_Prompt_User_to_use_Budgeted_figures);

           clTemp_FRS_Division_To_Use  := Division;
           if Division = 0 then
             SetLength(clTemp_FRS_Divisions, 0)
           else begin
             SetLength(clTemp_FRS_Divisions, Max_Divisions);
             clTemp_FRS_Divisions[Division] := True;
           end;

           if Assigned (Budget) then begin
              clTemp_FRS_Budget_To_Use := Budget.buFields.buName;
              clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
           end else begin
              clTemp_FRS_Budget_To_Use  := '';
              clTemp_FRS_Budget_To_Use_Date := -1;
           end;

           setJob(GetBatchText('Job'));
           clTemp_FRS_Split_By_Division := GetBatchBool('Split_By_Division', clTemp_FRS_Split_By_Division);
           // While we are here...
           caption := Caption + ' [' + Rptbatch.Name + ']';
        end;

        fmeDivisionSelector1.LoadDivisions(ThisClient);
        LoadClientSettings;
        LoadBudgetCombo;

        with Params do begin
          if Params.BatchSetup then begin
             //Sellect the settings
             chkGSTInclusive.Checked := ShowGst;
             chkIncludeCodes.Checked := ChartCodes;
             if assigned(Budget) then begin
                //chkPromptToUseBudget.Checked := True;
                cmbBudget.ItemIndex := cmbBudget.Items.IndexOfObject(Budget);
             end;
             //Load saved accounts list
             GetBatchAccounts;
             //Load saved divisions list
             GetBatchDivisions;
          end;
          SetDlgButtons(BtnPreview,BtnFile,Btnsave,BtnPrint);

          //Set selected accounts to checked
          fmeAccountSelector1.UpdateSelectedAccounts( Params);
          //Set selected divisions to checked
          fmeDivisionSelector1.UpdateSelectedDivisions(Params);
        end;

        //************
        ShowModal;
        //************

        Result := Params.RunBtn;
      finally
         Params.Free;
         Free;
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.cmbDetailChange(Sender: TObject);
begin
  RecalcDates;
  UpdateControlsOnForm;
  UpdateStartDate;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgProfitAndLossOptions.GenerateReport;
var
   Destination : TReportDest;
begin
   SaveClientSettings(True);
   case Params.RunBtn  of
     BTN_PRINT   : Destination := rdPrinter;
     BTN_PREVIEW : Destination := rdScreen;
     BTN_FILE    : Destination := rdFile;
     BTN_EMAIL   : Destination := rdEmail;
   else
     Destination := rdScreen;
   end;
   Params.SaveDates; // Can't pass them on..
   Reports.DoReport( REPORT_PROFITANDLOSS_MULTIPLE, Destination,0,Params.RptBatch);
end;

procedure TdlgProfitAndLossOptions.cmbStyleChange(Sender: TObject);
begin
  UpdateControlsOnForm;
  UpdateStartDate;
end;

procedure TdlgProfitAndLossOptions.cmbPeriodChange(Sender: TObject);
begin
  UpdateStartDate;
end;

procedure TdlgProfitAndLossOptions.UpdateStartDate;
var
  StartDate : integer;
  RepStyle  : integer;
  PeriodNo  : integer;
begin
  RepStyle    := GetComboCurrentIntObject( cmbStyle);
  PeriodNo := cmbPeriod.ItemIndex + 1;

  if RepStyle = crsSinglePeriod then
    StartDate := MonthArray[ PeriodNo].PeriodStartDate
  else
    StartDate := MonthArray[ 1].PeriodStartDate;

  stReportStarts.Caption := stDateToDateString( 'dd nnn yyyy',  StartDate, true );
end;

procedure TdlgProfitAndLossOptions.UpdateControlsOnForm;
//this routine takes all of the settings in the top most panel and ensure
//that the options available below are logical
var
  Style : integer;
  PeriodType : integer;
begin
  if SettingsBeingUpdated then exit;

  Style      := GetComboCurrentIntObject( cmbStyle);
  PeriodType := GetComboCurrentIntObject( cmbDetail);

  SettingsBeingUpdated := true;
  try
    //report style is always available unless the period type is custom

    //report detail is always available unless the style is budget remaining
    //if the style is budget remaining then the period must be monthly
    {cmbDetail.enabled := not ( Style = crsBudgetRemaining);
    if Style = crsBudgetRemaining then begin
      SetComboIndexByIntObject( frpMonthly, cmbDetail);
      PeriodType := ...
    end;}

    //compare settings
    //the compare actual values checkbox is always available expect for when
    //the report style in Budget Remaining.  In this case it MUST be selected
    if Style in [ crsBudgetRemaining] then begin
      chkCompare.Enabled   := false;
      chkCompare.Checked   := true;
    end
    else
      chkCompare.Enabled   := true;

    //last year is available only if compare is checked
    //last year is not available if style is budget remaining
    rbToLastYear.Enabled := chkCompare.Checked;

    //compare to budget is available if compare is checked
    //the period type must also be a monthly period
    //if the style is budget remaining then budget must be checked
    if ( chkCompare.checked) and ( PeriodType in ValidPeriodTypesForBudgetSet) then
    begin
      rbToBudget.Enabled := true;
      if Style = crsBudgetRemaining then
        rbtoBudget.checked := true;
    end
    else begin
      rbToBudget.Enabled := false;
      if not( PeriodType in ValidPeriodTypesForBudgetSet) then
        rbToBudget.checked := false;
    end;

    //the budget combo is only available if budget has been selected and is enabled
    cmbBudget.Enabled := rbToBudget.checked and rbToBudget.enabled;

    //if compare is checked then make sure something is selected
    //make sure something is selected for cash
    if ( chkCompare.checked) and not (rbToLastYear.checked or rbToBudget.checked) then begin
      if rbToLastYear.enabled then
        rbToLastYear.checked  := True
      else if rbToBudget.enabled then
        rbToBudget.checked := True;
    end;

    //variance is only available if compare is checked
    chkIncludeVariance.enabled := chkCompare.checked;

    //year to date is always available, but MUST be checked if the style is
    //budget remaining
    chkIncludeYTD.enabled := true;

    //chart codes can only be selected for detailed reports
    chkIncludeCodes.enabled    := rbDetailedFormat.checked;
    chkIncludeQuantity.enabled := rbDetailedFormat.checked;
    chkPrintNonPostingChartCodeTitles.enabled := rbDetailedFormat.checked;
    rbSummarisedNonPost.Enabled := rbDetailedFormat.checked and
                                   chkPrintNonPostingChartCodeTitles.Checked;
    rbDetailedNonPost.Enabled := rbDetailedFormat.checked and
                                 chkPrintNonPostingChartCodeTitles.Checked;

    //gst is always available

    //divisions are always available

  finally
    SettingsBeingUpdated := false;
  end;
end;

function TdlgProfitAndLossOptions.VerifyForm: boolean;
begin
  result := false;
  //Budget selected
  if ( rbToBudget.checked and chkCompare.checked) then begin
    if cmbBudget.ItemIndex < 0 then begin
       HelpfulWarningMsg( 'Please select a budget to use.', 0);
       PageControl1.ActivePageIndex := 0;
       if cmbBudget.Enabled then
         cmbBudget.SetFocus;
       Exit;
    end;
  end;
  result := true;
end;

procedure TdlgProfitAndLossOptions.cmbBudgetChange(Sender: TObject);
begin
   UpdateControlsOnForm;
end;

end.
