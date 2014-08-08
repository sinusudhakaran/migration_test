unit CashflowOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:       Cashflow Reporting Options Dialog

   Description: Updates the cashflow reporting options that are stored in
                the client file.  Used when user has selected "Custom" cash flow
                reporting.

   Author:      Matthew Hopkins  May 2002

   Remarks:

}
//------------------------------------------------------------------------------


interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, RzEdit, RzSpnEdt, ComCtrls, RzDTP, ExtCtrls,
  CheckLst, clObj32, DateSelectorFme, PeriodUtils, AccountSelectorFme, RptParams,UbatchBase,
  Buttons, OsFont, DivisionSelectorFme;


type
  TMyPanel = class( TPanel)
    public
      property Canvas;
  end;

type
  TdlgCashflowOptions = class(TForm)
    pnlButtons: TPanel;
    btnPrint: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    tbsAdvanced: TTabSheet;
    pnlReportStyle: TPanel;
    pnlCompare: TPanel;
    pnlInclude: TPanel;
    pnlCashSummary: TPanel;
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
    chkIncludeCash: TCheckBox;
    chkIncludeQuantity: TCheckBox;
    Label5: TLabel;
    rbDetailedFormat: TRadioButton;
    rbSummarisedFormat: TRadioButton;
    rbDetailedCash: TRadioButton;
    rbSummarisedCash: TRadioButton;
    cmbBudget: TComboBox;
    pnlPeriodDates: TPanel;
    Label3: TLabel;
    Label4: TLabel;
    cmbPeriod: TComboBox;
    lblLast: TLabel;
    chkIncludeCodes: TCheckBox;
    pnlDivision: TPanel;
    chkGSTInclusive: TCheckBox;
    pnlAdvAccounts: TPanel;
    fmeAccountSelector1: TfmeAccountSelector;
    pnlCustomDates: TPanel;
    ecDateSelector: TfmeDateSelector;
    stReportStarts: TLabel;
    BtnSave: TBitBtn;
    cbJobs: TComboBox;
    Label8: TLabel;
    ckAllJobs: TCheckBox;
    pnlAdvBudget: TPanel;
    chkPromptToUseBudget: TCheckBox;
    tbsDivisions: TTabSheet;
    Panel1: TPanel;
    fmeDivisionSelector1: TfmeDivisionSelector;
    Panel3: TPanel;
    rbSummarisedNonPost: TRadioButton;
    rbDetailedNonPost: TRadioButton;
    chkPrintNonPostingChartCodeTitles: TCheckBox;
    btnEmail: TButton;

    procedure ControlChange(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
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
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure fmeAccountSelector1btnSelectAllAccountsClick(
      Sender: TObject);
    procedure fmeAccountSelector1btnClearAllAccountsClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure ckAllJobsClick(Sender: TObject);
    procedure cmbBudgetDropDown(Sender: TObject);
    procedure fmeDivisionSelector1btnSelectAllDivisionsClick(Sender: TObject);
    procedure fmeDivisionSelector1btnClearAllDivisionsClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);

  private
    { Private declarations }
    LastPeriodOfActualData : integer;
    MonthArray           : TMonthArray;
    ThisClient           : TClientObj;
    tmpYearStarts        : Integer;
    BtnPressed           : integer;
    SettingsBeingUpdated : boolean;
    lParams : TCustomRptParameters;


    procedure LoadBudgetCombo;
    procedure ReLoadJobCombo;
    procedure SetJob(Value: string);
    procedure LoadClientSettings;
    procedure RecalcDates;
    procedure SaveClientSettings(BudgetPrompt : Boolean);
    procedure SaveBatchSettings;
    procedure UpdateStartDate;

    procedure UpdateControlsOnForm;
    function  VerifyForm (DoDates: Boolean = True): boolean;

    procedure GenerateReport;
  public
    { Public declarations }
  end;

  function UpdateCashflowReportOptions( const aClient : TClientObj;
                                        RptBatch : TReportBase = nil ) : integer;

//******************************************************************************
implementation

uses
   Math,
   BaList32,
   baObj32,
   bkConst,
   bkDateUtils,
   bkDefs,
   BKHelp,
   budObj32,
   clDateUtils,
   GLConst,
   globals,
   imagesfrm,
   Reports,
   ReportDefs,
   stDate,
   stDatest,
   UseBudgetedDataDlg,
   WarningMoreFrm, buList32,
   bkXPThemes;

{$R *.dfm}

const
   ValidPeriodTypesForBudgetSet = [ frpMonthly,
                                    frp2Monthly,
                                    frpQuarterly,
                                    frp6Monthly,
                                    frpYearly ];
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure SetComboIndexByIntObject( const Value : integer; const aCombo : TComboBox);
//used for location the item index of a combo by matching up an integer that
//has been stored in the Objects[] property.
var
   i : integer;
begin
   for i := 0 to Pred( aCombo.Items.Count) do
      if Integer( aCombo.Items.Objects[ i]) = Value then begin
         aCombo.ItemIndex := i;
         exit;
      end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetComboCurrentIntObject( const aCombo : TComboBox) : integer;
//returns the integer that has been stored in the Objects[] property
//returns -1 if no item selected
begin
   if aCombo.ItemIndex > -1 then
      result := Integer( aCombo.Items.Objects[ aCombo.ItemIndex])
   else
      result := -1;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.ControlChange(Sender: TObject);
begin
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.ckAllJobsClick(Sender: TObject);
begin
  ReLoadJobCombo;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.btnCancelClick(Sender: TObject);
begin
   BtnPressed := Globals.BTN_NONE;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.FormCreate(Sender: TObject);
var
   i : integer;
begin
   bkXPThemes.ThemeForm( Self);

   BtnPressed := Globals.BTN_NONE;
   SettingsBeingUpdated := false;

   PageControl1.ActivePage := tbsOptions;

   //setup date selector frame
   pnlCustomDates.Top  := pnlPeriodDates.Top;
   pnlCustomDates.BorderStyle := bsNone;
   pnlPeriodDates.BorderStyle := bsNone;

   with ecDateSelector do begin
      //set date bounds to first and last trx date
      eDateFrom.asStDate := -1;
      eDateTo.asStDate   := -1;
      btnQuik.Visible := true;
   end;

   //load combos with const values
   //load report styles
   cmbStyle.Items.Clear;
   for i := crsMin to crsMax do begin
      //only add value report styles
      if i in [ crsSinglePeriod, crsMultiplePeriod, crsBudgetRemaining ] then begin
         cmbStyle.Items.AddObject( crsNames[ i], TObject(i));
      end;
   end;
   //set default
   SetComboIndexByIntObject( crsSinglePeriod, cmbStyle);

   //load report detail (financial reporting periods)
   cmbDetail.Items.Clear;
   for i := frpMin to frpMax do begin
      //only add value report styles
      if i in [ frpWeekly .. frpYearly, frpCustom ] then begin
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

   fmeDivisionSelector1.OnDivisionsChanged := UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.FormDestroy(Sender: TObject);
begin
   MonthArray := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.LoadBudgetCombo;
var
  clM : Integer;
  buD, buM, buY : Integer;
  i : integer;
  Budget : TBudget;
  S : string;
begin
  clM := cmbStartMonth.ItemIndex + 1;
  //load budget combo
  cmbBudget.Items.Clear;
  with ThisClient do begin
    for i:= clBudget_List.ItemCount-1 downto 0 do
    begin
      Budget := clBudget_List.Budget_At(i);
      StDateToDMY(Budget.buFields.buStart_Date, buD, buM, buY );
      if (buM = clM) then
      begin
        S := Budget.buFields.buName + ' (' + bkDate2Str(Budget.buFields.buStart_Date) + ')';
        cmbBudget.Items.AddObject(S, Budget);
      end;
    end;

  end;
  if Assigned( lparams.budget) then
     //find item that matches this budget
     SetComboIndexByIntObject( Integer( lparams.budget), cmbBudget)
  else
     if cmbBudget.Items.Count > 0 then
        cmbBudget.ItemIndex := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.LoadClientSettings;
//load the client settings into the dialog
var
   d,m,y : integer;
   i     : integer;
   bu    : TBudget;
begin
   //set the reporting year starts fields
   tmpYearStarts := ThisClient.clFields.clReporting_Year_Starts;
   StDateToDMY( tmpYearStarts, d, m, y);

   spnStartYear.Value := y;
   cmbStartMonth.ItemIndex := m - 1;

   //load period dates into date selector
   ecDateSelector.ClientObj := ThisClient;
   ecDateSelector.InitDateSelect( ClDateUtils.BBankData( ThisClient),
                                  ClDateUtils.EBankData( ThisClient), chkCompare);

   ecDateSelector.eDateFrom.AsStDate := BKNull2St( ThisClient.clFields.clPeriod_Start_Date);
   ecDateSelector.eDateTo.AsStDate   := BKNull2St( ThisClient.clFields.clPeriod_End_Date);

   //fill the ending combo box with valid months
   RecalcDates;

  {load combo lists}
  fmeAccountSelector1.LoadAccounts( ThisClient, [ btBank, btCashJournals]);
  
  if Lparams.AccountList.Count <> 0 then
      for i := 0 to Pred( Lparams.AccountList.Count) do begin
         // Over time could get out of step...
         d := fmeAccountSelector1.AccountCheckBox.Items.IndexOfObject(Lparams.AccountList[i]);
         if d >= 0 then
            fmeAccountSelector1.AccountCheckBox.checked[d]:= True
      end
  else
     fmeAccountSelector1.btnSelectAllAccounts.Click;

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

      chkCompare.Checked         := ( clFRS_Compare_Type <> cflCompare_None);
      rbToBudget.Checked         := ( clFRS_Compare_Type  = cflCompare_To_Budget);
      rbToLastYear.Checked       := ( clFRS_Compare_Type  = cflCompare_To_Last_Year);

      SetComboIndexByIntObject( clFRS_Report_Style,  cmbStyle);
      SetComboIndexByIntObject( clFRS_Reporting_Period_Type, cmbDetail);

      rbDetailedFormat.checked   := ( clFRS_Report_Detail_Type = cflReport_Detailed);
      rbSummarisedFormat.checked := ( clFRS_Report_Detail_Type = cflReport_Summarised);

      chkGSTInclusive.Checked    := clGST_Inclusive_Cashflow;

      //load the following temporary settings
      bu := ThisClient.clBudget_List.Find_Name( clTemp_FRS_Budget_To_Use);
      if Assigned( bu) then begin
        //find item that matches this budget
        SetComboIndexByIntObject( Integer( Bu), cmbBudget);
      end
      else
        cmbBudget.ItemIndex := -1;

      chkPromptToUseBudget.checked := clFRS_Prompt_User_to_use_Budgeted_figures;

      chkIncludeCash.checked     := ( clCflw_Cash_On_Hand_Style <> cflCash_On_Hand_None);
      rbDetailedCash.checked     := ( clCflw_Cash_On_Hand_Style  = cflCash_On_Hand_Detailed);
      rbSummarisedCash.checked   := ( clCflw_Cash_On_Hand_Style  = cflCash_On_Hand_Summarised);

   end;

   //set the states of all the control
   UpdateControlsOnForm;
   UpdateStartDate;

   //fill the ending combo box with valid months no that have set
   RecalcDates;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.SaveBatchSettings;
var
  i: integer;
begin
  with lParams, Client.clFields do begin
    // Update the RptBatch title
    if clFRS_Report_Style = crsMultiplePeriod then
       lParams.RptBatch.Title := REPORT_LIST_NAMES[ Report_Cashflow_Multiple ]
    else
       lParams.RptBatch.Title := REPORT_LIST_NAMES[ Report_Cashflow_Single ];

    // do some of te commnon ones first
    ShowGST  := clGST_Inclusive_Cashflow;
    Division := clTemp_FRS_Division_To_Use;
    ChartCodes := clFRS_Print_Chart_Codes;
    PrintNPChartCodeTitles := Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
    NPChartCodeDetailType := Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type;

    // Clears and saves the ones as above..
    SaveNodesettings;

    case clCflw_Cash_On_Hand_Style of
      //cflCash_On_Hand_None
      cflCash_On_Hand_Detailed   : SetBatchText('Cash_On_Hand', 'Detailed');
      cflCash_On_Hand_Summarised : SetBatchText('Cash_On_Hand', 'Summarised');
      else SetBatchText('Cash_On_Hand', 'None');
    end;
    SetBatchText('Job',cbJobs.Text);

    SetBatchBool('Show_Year_to_Date', clFRS_Show_YTD);
    SetBatchBool('Show_Quantities', clFRS_Show_Quantity);
    SaveBatchReportPeriod(clFRS_Reporting_Period_Type);
    SaveBatchReportStyle(clFRS_Report_Style);
    SaveBatchReportCompare(clFRS_Compare_Type);
    SetBatchBool('Show_Variance', clFRS_Show_Variance);
    SetBatchBool('Prompt_for_Budget', clFRS_Prompt_User_to_use_Budgeted_figures);

    //clReporting_Year_Starts
    SetBatchBool('Summarised', clFRS_Report_Detail_Type= cflReport_Summarised);

    //now save temporary client variables
    if clTemp_FRS_Last_Period_To_Show > 1 then
       SetBatchInteger('_LastShow',clTemp_FRS_Last_Period_To_Show);

    SaveBatchAccounts;

    Division := 0;
    lParams.DivisionList.Clear;
    if (Length(clTemp_FRS_Divisions) > 0) then
       for i := 0 to Length(clTemp_FRS_Divisions) - 1 do
          if clTemp_FRS_Divisions[i] then
             lParams.DivisionList.Add(TObject(i));
    SaveBatchDivisions;
  end;
end;

procedure TdlgCashflowOptions.SaveClientSettings(BudgetPrompt : Boolean);
var
  i : integer;
  ba : TBank_Account;
  BudgetToUse : string;
  BudgetDate: Integer;
  AskForBudget: boolean;
begin
   with ThisClient.clFields do begin
      clFRS_Show_Quantity        := chkIncludeQuantity.checked and chkIncludeQuantity.enabled;
      //clFRS_Cash_On_Hand_Style
      clCflw_Cash_On_Hand_Style  := cflCash_On_Hand_None;
      if chkIncludeCash.Checked and chkIncludeCash.enabled then begin
         if rbDetailedCash.checked then
            clCflw_Cash_On_Hand_Style := cflCash_On_Hand_Detailed;
         if rbSummarisedCash.checked then
            clCflw_Cash_On_Hand_Style := cflCash_On_Hand_Summarised;
      end;

      clFRS_Print_Chart_Codes := chkIncludeCodes.Checked; // and chkIncludeCodes.Enabled;
      ThisClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles :=
        chkPrintNonPostingChartCodeTitles.Checked;
      ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type := cflReport_Detailed;
      if rbSummarisedNonPost.Checked and chkPrintNonPostingChartCodeTitles.Checked then
        ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type := cflReport_Summarised;

      i := GetComboCurrentIntObject( cmbStyle); //Style
      if (i in [ crsBudgetRemaining]) then
        clFRS_Show_YTD := chkIncludeYTD.Checked
      else
        clFRS_Show_YTD := (chkIncludeYTD.Checked and chkIncludeYTD.Enabled);

      //clFRS_Compare_Type
      clFRS_Show_Variance := false;
      clFRS_Compare_Type  := cflCompare_None;
      if chkCompare.Checked then begin      //and chkCompare.Enabled
         if rbToBudget.Checked then
            clFRS_Compare_Type := cflCompare_To_Budget;
         if rbToLastYear.Checked then
            clFRS_Compare_Type := cflCompare_To_Last_Year;

         clFRS_Show_Variance := chkIncludeVariance.Checked;
      end;
      clFRS_Reporting_Period_Type := GetComboCurrentIntObject( cmbDetail);
      clFRS_Report_Style      := GetComboCurrentIntObject( cmbStyle);
      clReporting_Year_Starts := tmpYearStarts;
      if rbDetailedFormat.checked then
         clFRS_Report_Detail_Type   := cflReport_Detailed //detailed
      else
         clFRS_Report_Detail_Type   := cflReport_Summarised;  //summaried

      clGST_Inclusive_Cashflow := chkGSTInclusive.Checked;
      clFRS_Prompt_User_to_use_Budgeted_figures := chkPromptToUseBudget.Checked;

      //now save temporary client variables
      if clFRS_Reporting_Period_Type = frpCustom then begin
        clTemp_FRS_Last_Period_To_Show  := 1;
        clTemp_FRS_Last_Actual_Period_To_Use := clTemp_FRS_Last_Period_To_Show;
        cltemp_FRS_from_Date            := StNull2BK( ecDateSelector.eDateFrom.AsStDate);
        clTemp_FRS_To_Date              := StNull2BK( ecDateSelector.eDateTo.AsStDate);
        Lparams.Fromdate := clTemp_FRS_From_Date;
        LParams.Todate   := clTemp_FRS_To_Date;
      end else begin
        clTemp_FRS_Last_Period_To_Show  := cmbPeriod.ItemIndex + 1;
        clTemp_FRS_Last_Actual_Period_To_Use := clTemp_FRS_Last_Period_To_Show;
        cltemp_FRS_from_Date            := 0;
        clTemp_FRS_To_Date              := 0;
        Lparams.Fromdate := clReporting_Year_Starts;
        Lparams.Todate   := MonthArray[clTemp_FRS_Last_Period_To_Show].PeriodEndDate;
      end;

      //Divisions
      clTemp_FRS_Split_By_Division := fmeDivisionSelector1.chkSplitByDivision.Checked;
      clTemp_FRS_Division_To_Use := 0;
      SetLength(clTemp_FRS_Divisions, 0);
      fmeDivisionSelector1.UpdateClientDivisions(ThisClient);

      if cbJobs.ItemIndex > 0 then
         clTemp_FRS_Job_To_Use := cbJobs.Items[cbJobs.ItemIndex]
      else
        clTemp_FRS_Job_To_Use := '';

      //store this so can use the default if needed in the UseBudgeted... dlg
      BudgetToUse := clTemp_FRS_Budget_To_Use;

      //see if a budget has been specified
      if ( clFRS_Compare_Type = cflCompare_To_Budget)
      and (cmbBudget.Items.Count > 0)
      and (cmbBudget.ItemIndex >= 0) then
      begin
        lparams.Budget := TBudget( GetComboCurrentIntObject( cmbBudget)); // While we are here
        clTemp_FRS_Budget_To_Use      := TBudget( GetComboCurrentIntObject( cmbBudget)).buFields.buName;
        clTemp_FRS_Budget_To_Use_Date := TBudget( GetComboCurrentIntObject( cmbBudget)).buFields.buStart_Date;
      end
      else
      begin
        lparams.Budget := nil;
        clTemp_FRS_Budget_To_Use      := '';
        clTemp_FRS_Budget_To_Use_Date := -1;
      end;

      //prompt the user to use budget figures in have selected a period past
      //the last period that has data.
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

   //now save temporary flag into bank accounts;
   with ThisClient do begin
      for i := 0 to Pred( clBank_Account_List.ItemCount) do begin
         ba := clBank_Account_List.Bank_Account_At(i);
         ba.baFields.baTemp_Include_In_Report := false;
      end;
      LParams.AccountList.Clear;
      //now turn back on accounts which are selected
      for i := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Items.Count) do begin
         ba := TBank_Account(fmeAccountSelector1.AccountCheckBox.Items.Objects[ i]);
         ba.baFields.baTemp_Include_In_Report := fmeAccountSelector1.AccountCheckBox.Checked[ i];
         if fmeAccountSelector1.AccountCheckBox.Checked[ i] then
            LParams.AccountList.Add(ba);
      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.SetJob(Value: string);
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
procedure TdlgCashflowOptions.cmbPeriodDrawItem(Control: TWinControl;
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
procedure TdlgCashflowOptions.RecalcDates;
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

      if PeriodType <> frpCustom then begin
        pnlPeriodDates.Visible := true;
        pnlCustomDates.Visible := false;

        MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( ThisClient, tmpYearStarts, tmpYearEnds, true, PeriodType,
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
        UpdateStartDate;
     end
     else begin
        //custom dates, show date panel
        pnlPeriodDates.Visible := false;
        pnlCustomDates.Visible := true;
     end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.ReLoadJobCombo;
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
  UpdateControlsOnForm;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.cmbStartMonthChange(Sender: TObject);
begin
  RecalcDates;
  LoadBudgetCombo;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.spnStartYearChange(Sender: TObject);
begin
   RecalcDates;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.btnPreviewClick(Sender: TObject);
begin
  if VerifyForm then begin
    BtnPressed := Globals.BTN_PREVIEW;
    GenerateReport;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.btnEmailClick(Sender: TObject);
begin
  if VerifyForm then begin
    BtnPressed := Globals.BTN_EMAIL;
    GenerateReport;
  end;
end;

procedure TdlgCashflowOptions.btnFileClick(Sender: TObject);
begin
  if VerifyForm then begin
    BtnPressed := Globals.BTN_FILE;
    GenerateReport;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.btnPrintClick(Sender: TObject);
begin
  if VerifyForm then begin
    BtnPressed := Globals.BTN_OKPRINT;
    GenerateReport;
  end;
end;
procedure TdlgCashflowOptions.BtnSaveClick(Sender: TObject);
begin
  if VerifyForm(False) then begin
     if LParams.CheckForBatch('Cash Flow', Self.Caption) then begin
        BtnPressed := Globals.BTN_SAVE;
        GenerateReport;

     end else begin
        LParams.RunBtn := Globals.BTN_SAVE;
        ModalResult := MROk;
     end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateCashflowReportOptions( const aClient : TClientObj;
                                            RptBatch : TReportBase = nil) : integer;
//all of the reporting variables are now stored in Client.clFields...
//most of the settings are persistent so that the user will see their last
//settings when they reenter the dialog.
//returns the value of the button pressed

// For the Batched reports, this means have to read the Client from the settings
// For most other reports Params will hold the settings

var
  CashflowOptions : TdlgCashflowOptions;
  s : string;
  procedure CheckToDate;
  var i : integer;
  begin with CashflowOptions, lparams do begin
     if Todate = 0 then
        exit;
     for i := Low(MonthArray) to High(MonthArray) do
        if MonthArray[i].PeriodEndDate >= Todate then begin
           cmbPeriod.ItemIndex := Pred(i); // ? Pred
           Break;
        end;
  end;end;

begin
   CashflowOptions := TdlgCashflowOptions.Create( Application);

   with CashflowOptions do begin
      lParams := TCustomRptParameters.Create(ord(Report_Cashflow_Single), aClient,Rptbatch,dYear,true);
      try
        lParams.AccountFilter := [btBank, btCashJournals];
        lParams.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,BtnSave,BtnPrint);
        if Assigned(RptBatch) then
           Caption := Caption + ' [' + RptBatch.Name + ']';
        BKHelpSetUp(CashflowOptions, BKH_Cash_Flow_Custom);

        ThisClient := aClient;
        ReloadJobCombo;

        chkGSTInclusive.Caption := '&' + ThisClient.TaxSystemNameUC + ' Inclusive';

        with lParams, Client.clFields do if assigned(rptBatch) then begin

           // Read the settings from the Settings...
           GetBatchAccounts;
           s := GetBatchText('Cash_On_Hand','');
           if s > '' then begin
             if sameText(s,'Detailed') then
                clCflw_Cash_On_Hand_Style := cflCash_On_Hand_Detailed
             else   if sameText(s,'Summarised') then
                clCflw_Cash_On_Hand_Style := cflCash_On_Hand_summarised
             else clCflw_Cash_On_Hand_Style := cflCash_On_Hand_None;
           end;


           clFRS_Compare_Type                        := GetBatchReportCompare(clFRS_Compare_Type);
           if clFRS_Compare_Type <> cflCompare_None then
              clFRS_Show_Variance := GetBatchBool('Show_Variance',  clFRS_Show_Variance)
           else
              clFRS_Show_Variance := false;

           clFRS_Show_YTD                            := GetBatchBool('Show_Year_to_Date',  clFRS_Show_YTD);
           clFRS_Show_Quantity                       := GetBatchBool('Show_Quantities',  clFRS_Show_Quantity);
           clFRS_Print_Chart_Codes                   := ChartCodes;
           Client.clExtra.ceFRS_Print_NP_Chart_Code_Titles := PrintNPChartCodeTitles;
           Client.clExtra.ceFRS_NP_Chart_Code_Detail_Type  := NPChartCodeDetailType;
           clFRS_Reporting_Period_Type               := GetBatchReportPeriod(clFRS_Reporting_Period_Type);
           clFRS_Report_Style                        := GetBatchReportStyle (clFRS_Report_Style);
           //clReporting_Year_Starts
           clFRS_Report_Detail_Type                  := integer(
                                                           GetBatchBool('Summarised',clFRS_Report_Detail_Type= cflReport_Summarised));

           clGST_Inclusive_Cashflow                  := ShowGST;
           clFRS_Prompt_User_to_use_Budgeted_figures := GetBatchBool('Prompt_for_Budget',  clFRS_Prompt_User_to_use_Budgeted_figures);

           //now set some temporary client variables

           if clFRS_Reporting_Period_Type = frpCustom then begin
              //clTemp_FRS_From_Date := Fromdate;
              //clTemp_FRS_To_Date   := Todate;
              clTemp_FRS_Last_Period_To_Show := 1;
           end else begin
              //clReporting_Year_Starts := Fromdate;
              clTemp_FRS_Last_Period_To_Show := 1;
           end;

           clTemp_FRS_Last_Actual_Period_To_Use  := clTemp_FRS_Last_Period_To_Show;

           clTemp_FRS_Division_To_Use  := Division;
           if Assigned (Budget) then begin
              clTemp_FRS_Budget_To_Use := Budget.buFields.buName;
              clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
           end else begin
              clTemp_FRS_Budget_To_Use  := '';
              clTemp_FRS_Budget_To_Use_Date := -1;
           end;

           clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;

           SetJob(GetBatchText('Job'));
        end else begin
           clTemp_FRS_Division_To_Use := 0;
           clTemp_FRS_Budget_To_Use  := '';
           clTemp_FRS_Budget_To_Use_Date := -1;
           clTemp_FRS_From_Date := 0;
           clTemp_FRS_To_Date   := 0;
           clTemp_FRS_Last_Period_To_Show := 1;
           cbJobs.ItemIndex := -1;
        end;

        fmeDivisionSelector1.LoadDivisions(ThisClient);



        with lParams do begin
          //Load saved divisions
          if lParams.BatchSetup then
             GetBatchDivisions;
          //Set selected divisions to checked
          fmeDivisionSelector1.UpdateSelectedDivisions(lParams);
        end;
        LoadClientSettings;
         CheckToDate;

        LoadBudgetCombo;
        ShowModal;

        //if not ( BtnPressed = BTN_NONE) then
        //LParams.SaveNodeSettings;

        result := BtnPressed;
      finally
         lParams.Free;
         Free;

      end;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.cmbDetailChange(Sender: TObject);
begin
  RecalcDates;
  UpdateControlsOnForm;
  UpdateStartDate;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashflowOptions.GenerateReport;
var
   Destination : TReportDest;
begin
   SaveClientSettings(True);
   lParams.RunBtn := BtnPressed;
   case BtnPressed of
     BTN_PRINT   : Destination := rdPrinter;
     BTN_PREVIEW : Destination := rdScreen;
     BTN_FILE    : Destination := rdFile;
     BTN_EMAIL   : Destination := rdEmail;
     BTN_Save    : begin
                     SaveBatchSettings;
                     Close;
                     Exit;
                   end
   else
     Destination := rdScreen;
   end;

   Reports.DoReport( REPORT_CASHFLOW_MULTIPLE, Destination,0,LParams.RptBatch);
   if Lparams.BatchRunMode = R_Batch then
      ModalResult := mrOK;
end;

procedure TdlgCashflowOptions.cmbStyleChange(Sender: TObject);
begin
  UpdateControlsOnForm;
  UpdateStartDate;
end;

procedure TdlgCashflowOptions.cmbPeriodChange(Sender: TObject);
begin
  UpdateStartDate;
end;

procedure TdlgCashflowOptions.UpdateStartDate;
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

procedure TdlgCashflowOptions.UpdateControlsOnForm;
//this routine takes all of the settings in the top most panel and ensure
//that the options available below are logical
var
  Style : integer;
  PeriodType : integer;
  AllAccountsSelected, SomeAccountsSelected : boolean;
  i                   : integer;
begin
  if SettingsBeingUpdated then
     exit;

  Style      := GetComboCurrentIntObject( cmbStyle);
  PeriodType := GetComboCurrentIntObject( cmbDetail);
  AllAccountsSelected := true;
  SomeAccountsSelected := false;
  for i := 0 to (fmeAccountSelector1.AccountCheckBox.Items.Count - 1) do
    if not fmeAccountSelector1.AccountCheckBox.Checked[i] then
      AllAccountsSelected := false
    else
      SomeAccountsSelected := True;

  SettingsBeingUpdated := true;
  try
    //report style is always available unless the period type is custom
    cmbStyle.enabled := not ( PeriodType = frpCustom);
    if PeriodType = frpCustom then begin
      SetComboIndexByIntObject( crsSinglePeriod, cmbStyle);
      Style := crsSinglePeriod;
    end;

    //report detail is always available unless the style is budget remaining
    //if the style is budget remaining then the period must be monthly
    cmbDetail.enabled := (not ( Style = crsBudgetRemaining));
    if Style = crsBudgetRemaining then begin
      SetComboIndexByIntObject( frpMonthly, cmbDetail);
      cmbDetail.OnChange(cmbDetail); //call RecalcDates to re-populate cmbPeriod
      PeriodType := frpMonthly;
    end;

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
    if ( chkCompare.Checked) and not ( Style in [ crsBudgetRemaining]) then
      rbToLastYear.Enabled := true
    else begin
      rbToLastYear.Enabled := false;
      if Style in [ crsBudgetRemaining] then
        rbToLastYear.checked := false;
    end;

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

    //if compare is checked then make sure something is selected
    //make sure something is selected for cash
    if ( chkCompare.checked) and not (rbToLastYear.checked or rbToBudget.checked) then begin
      if rbToLastYear.enabled then
        rbToLastYear.checked := True
      else if rbToBudget.enabled then
        rbToBudget.checked := True;
    end;

    //the budget combo is only available if budget has been selected and is enabled
    cmbBudget.Enabled := rbToBudget.checked and rbToBudget.enabled;

    //variance is only available if compare is checked
    chkIncludeVariance.enabled := chkCompare.checked;

    //year to date is always available, but MUST be checked if the style is
    //budget remaining
    if (Style in [ crsBudgetRemaining]) or (PeriodType = frpCustom) then
    begin
      chkIncludeYTD.Enabled := False;
      if (Style in [ crsBudgetRemaining]) then
        chkIncludeYTD.Checked := True;
    end else
      chkIncludeYTD.Enabled := True;

    //chart codes and quantity can only be selected for detailed reports
    chkIncludeCodes.enabled    := rbDetailedFormat.checked;
    chkIncludeQuantity.enabled := rbDetailedFormat.checked;
    chkPrintNonPostingChartCodeTitles.enabled := rbDetailedFormat.checked;
    rbSummarisedNonPost.Enabled := rbDetailedFormat.checked and
                                   chkPrintNonPostingChartCodeTitles.Checked;
    rbDetailedNonPost.Enabled := rbDetailedFormat.checked and
                                 chkPrintNonPostingChartCodeTitles.Checked;

    //gst is always available

    //Include cash on hand summary is always available except for when a
    //division has been selected or if the user has choosen not to use all
    //available cash accounts
    chkIncludeCash.Enabled  := (fmeDivisionSelector1.AllDivisionsSelected)
                            and (cbJobs.ItemIndex < 1)
                            and (SomeAccountsSelected);

    if not chkIncludeCash.Enabled then
      chkIncludeCash.checked := false;

    //detailed cash section is available if include is checked
    //detailed cash is not available if a budget has been selected
    if ( chkIncludeCash.checked) and ( chkIncludeCash.enabled) and ( not (rbToBudget.Checked and chkCompare.checked)) then begin
      rbDetailedCash.enabled := true;
    end
    else begin
      rbDetailedCash.enabled := false;
      if ( rbToBudget.checked and chkCompare.checked) then
        rbDetailedCash.Checked := false;
    end;

    //summarised cash is available if chkInclude is checked
    rbSummarisedCash.enabled := ( chkIncludeCash.Checked) and ( chkIncludeCash.Enabled) and AllAccountsSelected;
    if (not rbSummarisedCash.Enabled) and rbSummarisedCash.Checked and rbDetailedCash.Enabled then
      rbDetailedCash.Checked := True;

    //make sure something is selected for cash
    if ( chkIncludeCash.checked) and not (rbSummarisedCash.checked or rbDetailedCash.checked) then begin
      if rbDetailedCash.enabled then
        rbDetailedCash.checked := True
      else if rbSummarisedCash.enabled then
        rbSummarisedCash.checked := True;
    end;

  finally
    SettingsBeingUpdated := false;
  end;
end;


function TdlgCashflowOptions.VerifyForm(DoDates: Boolean = True): boolean;
var
  AnyAccountsSelected : boolean;
  i                   : integer;
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

  //Accounts selected
  AnyAccountsSelected := false;
  for i := 0 to (fmeAccountSelector1.AccountCheckBox.Items.Count - 1) do
    if fmeAccountSelector1.AccountCheckBox.Checked[i] then
      AnyAccountsSelected := true;

  if not AnyAccountsSelected then begin
     HelpfulWarningMsg( 'You have not selected any accounts to use.  Please select at least one.', 0);
     PageControl1.ActivePage := tbsAdvanced;
     fmeAccountSelector1.chkAccounts.SetFocus;
     Exit;
  end;

  //Dates ok
  if (GetComboCurrentIntObject( cmbDetail) = frpCustom)
  and DoDates then begin
    if (not ecDateSelector.ValidateDates) then begin
      PageControl1.ActivePage := tbsOptions;
      ecDateSelector.eDateFrom.SetFocus;
      Exit;
    end;

    if (ecDateSelector.eDateTo.AsStDate <= 0) or (ecDateSelector.eDateFrom.AsStDate <= 0) then begin
      HelpfulWarningMsg( 'Please select valid dates', 0);
      PageControl1.ActivePage := tbsOptions;
      ecDateSelector.eDateFrom.SetFocus;
      Exit;
    end;

    if (ecDateSelector.eDateFrom.AsStDate > ecDateSelector.eDateTo.AsStDate) then begin
      HelpfulWarningMsg( 'The From Date you have selected is later than the To Date.  Please select valid dates.', 0);
      PageControl1.ActivePage := tbsOptions;
      ecDateSelector.eDateTo.SetFocus;
      Exit;
    end;
  end;

  result := true;
end;


procedure TdlgCashflowOptions.cmbBudgetDropDown(Sender: TObject);
var I, W: Integer;
begin
   // Should make this a class..

   w := cmbBudget.Width;
   for I := 0 to cmbBudget.Items.Count - 1 do
      w := max (w, canvas.TextWidth(cmbBudget.Items[i])+ 10 );

   cmbBudget.Perform(CB_SETDROPPEDWIDTH, w, 0);
end;

procedure TdlgCashflowOptions.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if GetComboCurrentIntObject( cmbDetail) = frpCustom then
    case Msg.CharCode of
      109: begin
             ecDateSelector.btnPrev.Click;
             Handled := true;
           end;
      107: begin
             ecDateSelector.btnNext.click;
             Handled := true;
           end;
      VK_MULTIPLY : begin
             ecDateSelector.btnQuik.click;
             handled := true;
           end;
    end;
end;

procedure TdlgCashflowOptions.fmeAccountSelector1btnSelectAllAccountsClick(
  Sender: TObject);
begin
  fmeAccountSelector1.btnSelectAllAccountsClick(Sender);
  UpdateControlsOnForm;
end;

procedure TdlgCashflowOptions.fmeDivisionSelector1btnClearAllDivisionsClick(
  Sender: TObject);
begin
  fmeDivisionSelector1.btnClearAllDivisionsClick(Sender);
  UpdateControlsOnForm;
end;

procedure TdlgCashflowOptions.fmeDivisionSelector1btnSelectAllDivisionsClick(
  Sender: TObject);
begin
  fmeDivisionSelector1.btnSelectAllDivisionsClick(Sender);
  UpdateControlsOnForm;
end;

procedure TdlgCashflowOptions.fmeAccountSelector1btnClearAllAccountsClick(
  Sender: TObject);
begin
  fmeAccountSelector1.btnClearAllAccountsClick(Sender);
  UpdateControlsOnForm;
end;

end.
