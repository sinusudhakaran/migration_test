unit ScheduledCodingReportDlg;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Menus, OvcBase, clObj32, ExtCtrls,
  bkXPThemes, CodingRepDlg, CustomColumnFme, ComCtrls, OSFont;

type
{   TSCRSettings = record
      Style      : byte;
      Sort       : byte;
      Include    : byte;
      LeaveLines : byte;
      RuleLine   : boolean;
      ShowTaxInv : boolean;
      ShowOP     : boolean;
      WrapNarration : boolean;
   end; }

  TdlgSchedCodingReportSettings = class(TForm)
    OvcController1: TOvcController;
    popDates: TPopupMenu;
    LastMonth1: TMenuItem;
    ThisYear1: TMenuItem;
    LastYear1: TMenuItem;
    AllData1: TMenuItem;
    btnOK: TButton;
    btnCancel: TButton;
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    tbsColumns: TTabSheet;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    chkRuleLine: TCheckBox;
    cmbStyle: TComboBox;
    cmbSort: TComboBox;
    cmbInclude: TComboBox;
    cmbLeave: TComboBox;
    chkTaxInvoice: TCheckBox;
    pnlNZOnly: TPanel;
    lblDetailsToShow: TLabel;
    rbShowNarration: TRadioButton;
    rbShowOtherParty: TRadioButton;
    chkWrap: TCheckBox;
    chkRuleVerticalLine: TCheckBox;
    fmeCustomColumn1: TfmeCustomColumn;

    procedure FormCreate(Sender: TObject);
    procedure cmbStyleChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FSettings: TCodingReportSettings;
    FCustomReportSettings: WideString;
    FStandardReportSettings: WideString;
    FCountry: integer;
    FTaxName: string;
    procedure ApplySettings;
    procedure SaveSettings;
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
  end;

  function SetupScheduledCodingReport( aClient : TClientObj;
                                       var Settings : TCodingReportSettings;
                                       var CustomCodingRepSettings: WideString) : boolean;

//******************************************************************************
implementation

uses
  bkConst,
  BKHelp,
  UserReportSettings,
  bkProduct;

{$R *.DFM}

procedure TdlgSchedCodingReportSettings.cmbStyleChange(Sender: TObject);
begin
  FSettings.Style := cmbStyle.ItemIndex;
  if FSettings.CustomReport and (FSettings.Style <> rsCustom) then begin
    //Reload standard report settings
    FSettings.LoadCustomReportXML(FStandardReportSettings);
    FSettings.Style := cmbStyle.ItemIndex; 
    FSettings.CustomReport := False;
    ApplySettings;    
  end else begin
    FSettings.CustomReport := (FSettings.Style = rsCustom);
    if FSettings.CustomReport then begin
      FSettings.LoadCustomReportXML(FCustomReportSettings);
      ApplySettings;
    end;
  end;
end;

procedure TdlgSchedCodingReportSettings.FormCreate(Sender: TObject);
var
  i : integer;
begin
  bkXPThemes.ThemeForm( Self);
  {load combo lists}
  for i := rsMin to rsMax do cmbStyle.Items.Add(rsNames[i]);
  for i := esMin to esMax do cmbInclude.Items.Add(esNames[i]);
  for i := csMin to csMax do
  begin
    if ( csSortByOrder[i] in
               [ csDateEffective,
                 csReference,
                 csChequeNumber,
                 csDatePresented,
                 csAccountCode,
                 csByValue,
                 csByNarration ]) then
      cmbSort.Items.AddObject(TProduct.Rebrand(csNames[csSortByOrder[i]]), TObject(csSortByOrder[i]));  //csByNarration do
  end;
end;

procedure TdlgSchedCodingReportSettings.FormShow(Sender: TObject);
begin
  PageControl1.ActivePage := tbsOptions;
end;

procedure TdlgSchedCodingReportSettings.ApplySettings;
begin
  //Apply settings
  if FSettings.Sort = csByOtherParty then
    FSettings.Sort := csByNarration;

  cmbStyle.ItemIndex         := FSettings.Style;
  cmbSort.ItemIndex          := cmbSort.Items.IndexOfObject(TObject(FSettings.Sort));
  cmbInclude.ItemIndex       := FSettings.Include;
  cmbLeave.ItemIndex         := FSettings.Leave;
  chkRuleLine.Checked        := FSettings.Rule;
  chkTaxInvoice.checked      := FSettings.TaxInvoice;
  chkWrap.Checked            := FSettings.WrapNarration;
  rbShowNarration.checked    := not FSettings.ShowOtherParty;
  rbShowOtherParty.checked   := FSettings.ShowOtherParty;
  chkRuleVerticalLine.Checked := FSettings.RuleLineBetweenColumns;

  case FCountry of
    whAustralia, whUK:
      chkTaxInvoice.Caption := 'Show Ta&x Invoice check box and ' + FTaxName + ' Amount';
    whNewZealand:
      chkTaxInvoice.Caption := 'Show Ta&x Invoice check box';
  end;
  pnlNZOnly.Visible := (FCountry = whNewZealand);

  //Orientation
  fmeCustomColumn1.rbLandscape.Checked := Boolean(FSettings.ColManager.Orientation);
  fmeCustomColumn1.rbportrait.Checked := not fmeCustomColumn1.rbLandscape.Checked;

  //Columns
  fmeCustomColumn1.LoadCustomColumns;

  //Set control states
  tbsColumns.TabVisible := FSettings.CustomReport;
//  chkWrap.Visible := not FSettings.CustomReport;
  chkTaxInvoice.Visible := not FSettings.CustomReport;
  lblDetailsToShow.Visible := not FSettings.CustomReport;
  rbShowNarration.Visible := not FSettings.CustomReport;
  rbShowOtherParty.Visible := not FSettings.CustomReport;
end;

procedure TdlgSchedCodingReportSettings.SaveSettings;
begin
  FSettings.Style       := cmbStyle.ItemIndex;
  FSettings.Sort        := Byte(cmbSort.Items.Objects[cmbSort.ItemIndex]);
  FSettings.Include     := cmbInclude.ItemIndex;
  FSettings.Leave       := cmbLeave.ItemIndex;
  FSettings.Rule        := chkRuleLine.Checked;
  FSettings.TaxInvoice  := chkTaxInvoice.checked;
  FSettings.ShowOtherParty  := rbShowOtherParty.checked;
  FSettings.WrapNarration   := chkWrap.Checked;
  FSettings.RuleLineBetweenColumns := chkRuleVerticalLine.Checked; 

  if FSettings.ShowOtherParty and (FSettings.Sort = csByNarration) then
    FSettings.Sort := csByOtherParty;

end;

procedure TdlgSchedCodingReportSettings.UpdateActions;
begin
  inherited;
  fmeCustomColumn1.UpdateActions;
end;

function SetupScheduledCodingReport( aClient : TClientObj;
                                     var Settings : TCodingReportSettings;
                                     var CustomCodingRepSettings: WideString) : boolean;
var
  SettingsDlg : TdlgSchedCodingReportSettings;
  TempStr: WideString;
begin
  Result := false;
  SettingsDlg := TdlgSchedCodingReportSettings.Create(application.MainForm);
  try
    BKHelpSetUp(SettingsDlg, BKH_Scheduled_Reports);
    with SettingsDlg do begin
      FSettings := Settings;
      //Save non-custom report settings
      FSettings.SaveCustomReportXML(TempStr);
      FStandardReportSettings := TempStr;
      //Save custom report settings for reloading when style changes
      FCustomReportSettings := CustomCodingRepSettings;
      //If style is custom then load from XML
      FSettings.CustomReport := (FSettings.Style = rsCustom);
      if FSettings.CustomReport then
        FSettings.LoadCustomReportXML(FCustomReportSettings);
      FCountry := aClient.clFields.clCountry;
      FTaxName := aClient.TaxSystemNameUC;
      fmeCustomColumn1.ReportParams := Settings;
      fmeCustomColumn1.OnApplySettings := SettingsDlg.ApplySettings;
      fmeCustomColumn1.OnSaveSettings := SettingsDlg.SaveSettings;
      ApplySettings;
      if ShowModal = mrOK then begin
        SaveSettings;
        if FSettings.CustomReport then begin
          FSettings.SaveCustomReportXML(TempStr);
          CustomCodingRepSettings := TempStr;
        end;
        Result := true;
      end else begin
        //Set back to original settings
        Settings.LoadCustomReportXML(FStandardReportSettings);
      end;
    end;
  finally
    SettingsDlg.Free;
  end;
end;

end.
