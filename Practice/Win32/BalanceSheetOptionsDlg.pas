unit BalanceSheetOptionsDlg;
//------------------------------------------------------------------------------
{
   Title:       Balance Sheet Reporting Options Dialog

   Description: Updates the financial reporting options that are stored in
                the client file.


   Author:      Matthew Hopkins  May 2002

   Remarks:     All of the financial reporting dialogs could be modified
                to descend from a common form.  Add this to the clean up list

                Budgets are not supported at this stage.  This is due to the fact
                that the budgets in BK5 are hard to set up and would most likely
                generate more support calls than it answered
}
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ProfitAndLossOptionsDlg, StdCtrls, Mask, RzEdit, RzSpnEdt,
  ComCtrls, ExtCtrls, clObj32,RptParams,UBatchBase, PeriodUtils, Buttons,
  OSFont, DivisionSelectorFme, AccountSelectorFme;

type
  TdlgBalanceSheet = class(TdlgProfitAndLossOptions)
    procedure FormCreate(Sender: TObject);
    procedure chkPrintNonPostingChartCodeTitlesClick(Sender: TObject);
    procedure rbDetailedFormatClick(Sender: TObject);
  private
    { Private declarations }
   
  protected
    procedure UpdateControlsOnForm; override;
    function  VerifyForm : boolean; override;
    procedure LoadClientSettings; override;
    procedure GenerateReport; override;
    procedure SaveBatchSettings; override;
    procedure SaveClientSettings(BudgetPrompt : Boolean); override;
  public
    { Public declarations }
  end;

function UpdateBalanceSheetOptions( const aClient : TClientObj; RptBatch : TReportBase = nil) : integer;

//******************************************************************************
implementation

uses
  bkConst,
  bkDateUtils,
  BKHelp,
  ComboUtils,
  Globals,
  JnlUtils32,
  Reports,
  ReportDefs,
  RptTrialBalance,
  WarningMoreFrm,
  YesNoDlg,
  CountryUtils;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateBalanceSheetOptions( const aClient : TClientObj;  RptBatch : TReportBase = nil) : integer;
//all of the reporting variables are now stored in Client.clFields...
//most of the settings are persistent so that the user will see their last
//settings when they reenter the dialog.
//returns the value of the button pressed
var
  BalanceSheet : TdlgBalanceSheet;
begin
  BalanceSheet := TdlgBalanceSheet.Create(Application.MainForm);
   with BalanceSheet do begin
      BKHelpSetUp(BalanceSheet, BKH_Balance_sheet_report);
      Params := TCustomRptParameters.Create(ord(Report_BalanceSheet_Single),AClient,RptBatch,DYear) ;
      try
        ThisClient := aClient;

        With chkGSTInclusive do Caption := Localise( ThisClient.clFields.clCountry, Caption );

        Params.SetDlgButtons(BtnPreview, BtnFile, BtnEmail, BtnSave, BtnPrint);
        if assigned(RptBatch) then with Params, Client.clFields Do begin


           clFRS_Compare_Type                        := GetBatchReportCompare(clFRS_Compare_Type);
           if clFRS_Compare_Type <> cflCompare_None then
              clFRS_Show_Variance := GetBatchBool('Show_Variance',  clFRS_Show_Variance)
           else
              clFRS_Show_Variance := false;

           //clFRS_Show_YTD                            := GetBatchBool('Show_Year_do_Date',  clFRS_Show_YTD);
           //clFRS_Show_Quantity                       := GetBatchBool('Show_Quantities',  clFRS_Show_Quantity);
           clFRS_Reporting_Period_Type               := GetBatchReportPeriod(clFRS_Reporting_Period_Type);
           clFRS_Report_Style                        := GetBatchReportStyle (clFRS_Report_Style);
           clFRS_Report_Detail_Type                  := integer(
                                                           GetBatchBool('Summarised',clFRS_Report_Detail_Type= cflReport_Summarised));

           clGST_Inclusive_Cashflow                  := ShowGST;
           clFRS_Print_Chart_Codes                   := ChartCodes;
           ThisClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles := PrintNPChartCodeTitles;
           ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type := NPChartCodeDetailType;

           (*
           clTemp_FRS_Division_To_Use  := Division;
           if Assigned (Budget) then begin
              clTemp_FRS_Budget_To_Use := Budget.buFields.buName;
              clTemp_FRS_Budget_To_Use_Date := Budget.buFields.buStart_Date;
           end else begin
              clTemp_FRS_Budget_To_Use  := '';
              clTemp_FRS_Budget_To_Use_Date := -1;
           end;
           *)
           Caption := Caption + ' [' + Params.Rptbatch.Name + ']';
        end;

        LoadClientSettings;
        //select all accounts
        fmeAccountSelector1.UpdateSelectedAccounts( Params);
        //select all divisions 
        fmeDivisionSelector1.UpdateSelectedDivisions(Params);

        //*************
        ShowModal;
        //************



        Result := Params.RunBtn ;


      finally
         Params.Free;
         Free;
      end;
   end;
end;


{ TdlgBalanceSheet }

procedure TdlgBalanceSheet.GenerateReport;
var
  Destination : TReportDest;
  ErrorMsg    : string;
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

  //conditions for balance sheet are the same as for trial balance
  RptTrialBalance.VerifyPreConditions( ThisClient, ErrorMsg);
  if ErrorMsg <> '' then begin
    HelpfulWarningMsg('You cannot produce a Balance Sheet Report at this time '+
                      'because of the following errors: '#13 + ErrorMsg , 0);
    if Params.BatchRunMode = R_Batch then begin
        Params.RunBtn := BTN_NONE;
        Close;
    end;
    Exit;
  end;

  if not JnlUtils32.CheckForOpeningBalance( ThisClient, ThisClient.clFields.clReporting_Year_Starts) then begin
    //warn the user that there are no balances
    if not Globals.INI_DontShowMe_NoOpeningBalances then begin
      if YesNoDlg.AskYesNoCheck( 'Generate Report',
                              'You have not entered opening balances on the '+
                              'selected Reporting Year Start date (' + bkDate2Str(ThisClient.clFields.clReporting_Year_Starts) + ').'#13#13 +
                              'Do you still want to generate this report?',
                              'Don''t ask me this again',
                              INI_DontShowMe_NoOpeningBalances,
                              DLG_NO ,0) <> DLG_YES then begin
         if Params.BatchRunMode = R_Batch then begin
            Params.RunBtn := BTN_NONE;
            Close;
         end;
         Exit;
      end;
    end;
  end;
  Params.SaveDates;
  Reports.DoReport( REPORT_BALANCESHEET_MULTIPLE, Destination,0,Params.RptBatch);
end;

procedure TdlgBalanceSheet.LoadClientSettings;
begin
  inherited;
  //Balance Sheet should show Accrual Journals as well. BugzID: 11131
  //All journals are now included by default BugzID: 11686
  fmeAccountSelector1.LoadAccounts( ThisClient);
end;

procedure TdlgBalanceSheet.rbDetailedFormatClick(Sender: TObject);
begin
  inherited;
  UpdateControlsOnForm;
end;

procedure TdlgBalanceSheet.chkPrintNonPostingChartCodeTitlesClick(
  Sender: TObject);
begin
  inherited;
  UpdateControlsOnForm;
end;

procedure TdlgBalanceSheet.FormCreate(Sender: TObject);
var
  Gap: integer;
begin
  inherited;

  //the following controls are not visible for balance sheets
  rbToBudget.Visible         := false;
  cmbBudget.Visible          := false;
  pnlAdvBudget.Visible       := false;
  chkIncludeQuantity.Visible := false;
  chkIncludeYTD.Visible      := false;
  pnlDivision.Visible        := false;
  rbToLastYear.Visible       := false;
  tsbDivisions.TabVisible    := false;
  tbsAdvanced.TabVisible     := false;
  //move gst check box over
  //chkGSTInclusive.Left       := chkIncludeQuantity.Left;

  Gap := (pnlDivision.Top - (pnlReportStyle.Top + pnlReportStyle.Height));
  Self.Height := Self.Height - (pnlAdvBudget.Height + Gap);
  pnlCompare.Top := pnlReportStyle.Top +  pnlReportStyle.Height + Gap;
  Self.Height := Self.Height - (pnlDivision.Height + Gap);
  pnlInclude.Top := pnlCompare.Top + pnlCompare.Height + Gap;
  pnlIncludeNonPost.Top := pnlInclude.Top;
end;


procedure TdlgBalanceSheet.UpdateControlsOnForm;
//this routine takes all of the settings in the top most panel and ensure
//that the options available below are logical
var
  Style : integer;
  //PeriodType : integer;
begin
  if SettingsBeingUpdated then exit;

  Style      := GetComboCurrentIntObject( cmbStyle);
  //PeriodType := GetComboCurrentIntObject( cmbDetail);

  SettingsBeingUpdated := true;
  try
    //report style is always available unless the period type is custom

    //report detail is always available unless the style is budget remaining
    //however this style is not expected for balance sheets
    Assert( Style <> crsBudgetRemaining, 'Style is Budget Remaining');

    //compare settings
    //the compare actual values checkbox is always available expect for when
    //the report style in Budget Remaining.  In this case it MUST be selected

    //last year is available only if compare is checked
    //last year is not available if style is budget remaining
    rbToLastYear.Enabled := chkCompare.Checked;

    //compare to budget is never available for balance sheet
    rbToBudget.Enabled := false;
    rbToBudget.Checked := false;

    //the budget combo is only available if budget has been selected and is enabled
    cmbBudget.Enabled := rbToBudget.checked and rbToBudget.enabled;

    //if compare is checked then make sure something is selected
    //make sure something is selected for cash
    rbToLastYear.checked  := chkCompare.Checked;

    //variance is only available if compare is checked
    chkIncludeVariance.enabled := chkCompare.checked;

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

    //the user should never be prompted for budgeted figures for balance sheets
  finally
    SettingsBeingUpdated := false;
  end;
end;

procedure TdlgBalanceSheet.SaveBatchSettings;
begin
   with params, Client.clFields do begin
           //pick up the settings
           // Do the 'Fixed' ones first
           if clFRS_Report_Style = crsSinglePeriod then
              Rptbatch.Title :=  Report_List_Names[REPORT_BALANCESHEET_SINGLE]
           else
              Rptbatch.Title := Report_List_Names[REPORT_BALANCESHEET_MULTIPLE];

           ShowGst    := clGST_Inclusive_Cashflow;
           ChartCodes := clFRS_Print_Chart_Codes;
           PrintNPChartCodeTitles := ThisClient.clExtra.ceFRS_Print_NP_Chart_Code_Titles;
           NPChartCodeDetailType := ThisClient.clExtra.ceFRS_NP_Chart_Code_Detail_Type;
                                    
           Budget := nil;

           (*
           if cmbDivision.ItemIndex >= 0 then
              Division :=  Integer(cmbDivision.Items.Objects[cmbDivision.ItemIndex])
           else Division := 0;
           *)

           SaveNodesettings;// Clears and saves the fixed ones

           //SetBatchBool('YearTodate',  clFRS_Show_YTD);
           //SetBatchBool('Show_Quantities',  clFRS_Show_Quantity);
           SetBatchBool('Show_Variance',  clFRS_Show_Variance);
           SetBatchBool('Summarised',clFRS_Report_Detail_Type= cflReport_Summarised);
           SaveBatchReportPeriod(clFRS_Reporting_Period_Type);
           SaveBatchReportStyle (clFRS_Report_Style);
           SaveBatchReportCompare(clFRS_Compare_Type);

     end;
end;

procedure TdlgBalanceSheet.SaveClientSettings(BudgetPrompt : Boolean);
var
  PromptWasOn : boolean;
begin
  //the save settings code for balance sheets is 99% the same, however we dont
  //use the prompt user for budgeted figures setting in balance sheets.
  //To prevent the dialog being shown to the user we turn this off temporarily,
  //save the settings are then reset it to the preserved setting
  PromptWasOn := ThisClient.clFields.clFRS_Prompt_User_to_use_Budgeted_figures;
  ThisClient.clFields.clFRS_Prompt_User_to_use_Budgeted_figures := false;

  inherited;

  ThisClient.clFields.clFRS_Prompt_User_to_use_Budgeted_figures := PromptWasOn;
end;

function TdlgBalanceSheet.VerifyForm: boolean;
begin
  result := true;
end;

end.
