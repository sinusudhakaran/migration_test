// Client Authority Form for AU accounts
unit CAFfrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  OSFont;

type
  TfrmCAF = class(TForm)
    ScrollBox1: TScrollBox;
    lblTo: TLabel;
    lblManager: TLabel;
    lblBankLink: TLabel;
    lblPos: TLabel;
    lblClause1: TLabel;
    lblPos2: TLabel;
    lblSign: TLabel;
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblSubtitle: TLabel;
    lblAddress: TLabel;
    pnlAccount3: TPanel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtName3: TEdit;
    edtBSB3: TEdit;
    edtNumber3: TEdit;
    edtClient3: TEdit;
    edtCost3: TEdit;
    edtBank: TEdit;
    pnlAccount2: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    edtName2: TEdit;
    edtBSB2: TEdit;
    edtNumber2: TEdit;
    edtClient2: TEdit;
    edtCost2: TEdit;
    pnlFooter: TPanel;
    lblForm: TLabel;
    pnlAccount1: TPanel;
    lblAcName: TLabel;
    lblAcNum: TLabel;
    lblClient: TLabel;
    lblCost: TLabel;
    edtName1: TEdit;
    edtBSB1: TEdit;
    edtNumber1: TEdit;
    edtClient1: TEdit;
    edtCost1: TEdit;
    edtYear: TEdit;
    edtAdvisors: TEdit;
    edtPractice: TEdit;
    cmbMonth: TComboBox;
    Panel6: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnCancel: TButton;
    btnPrint: TButton;
    pnlBank: TPanel;
    pnl1: TPanel;
    pnl2: TPanel;
    pnl3: TPanel;
    pnl4: TPanel;
    pnlSign: TPanel;
    lblClause2: TLabel;
    lblClause3: TLabel;
    lblClause45: TLabel;
    btnEmail: TButton;
    btnClear: TButton;
    btnImport: TButton;
    Opendlg: TOpenDialog;
    pnlFrequency: TPanel;
    lblPracticeCode: TLabel;
    lblTheGeneralManager: TLabel;
    Panel1: TPanel;
    lblAdditionalInfo: TLabel;
    lblServiceFrequency: TLabel;
    rbMonthly: TRadioButton;
    rbWeekly: TRadioButton;
    rbDaily: TRadioButton;
    cbProvisional: TCheckBox;
    cmbInstitutionCountry: TComboBox;
    Label1: TLabel;
    edtInstitutionName: TEdit;
    lblPos1: TLabel;
    cmbInstitutionName: TComboBox;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtExit(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cmbMonthChange(Sender: TObject);
    procedure edtKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbInstitutionNameChange(Sender: TObject);
  private
    { Private declarations }
    FButton: Byte;
    FImportFile: string;
    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);
  public
    { Public declarations }
    property ButtonPressed: Byte read FButton;
    property ImportFile: string read FImportFile write SetImportFile;
  end;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ErrorMoreFrm,
  bkConst,
  Globals,
  AuthorityUtils,
  WinUtils,
  InfoMoreFrm,
  ShellAPI,
  bkHelp,
  InstitutionCol;

Const
  UNIT_NAME = 'TPAfrm';
  COUNTY_CODE = 'OZ';
  SET_BANK_WIDTH = 437;
  OTHER_BANK_WIDTH = 129;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormCreate(Sender: TObject);
var
  Index : integer;
  CountryIndex : integer;
begin
  // Institution Country Names
  for Index := 0 to Institutions.CountryCodes.Count-1 do
  begin
    if Institutions.CountryCodes.Strings[Index] = COUNTY_CODE then
      CountryIndex := Index;

    cmbInstitutionCountry.AddItem(Institutions.CountryNames.Strings[Index],nil);
  end;
  cmbInstitutionCountry.itemindex := CountryIndex;
  cmbInstitutionCountry.Enabled := false;

  // Institution Names
  cmbInstitutionName.AddItem('Other', nil);
  for Index := 0 to Institutions.Count-1 do
  begin
    if TInstitutionItem(Institutions.Items[Index]).CountryCode = COUNTY_CODE then
      cmbInstitutionName.AddItem(TInstitutionItem(Institutions.Items[Index]).Name ,Institutions.Items[Index]);
  end;

  cmbInstitutionName.Width := SET_BANK_WIDTH;
  edtInstitutionName.Enabled := false;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateForm: Boolean;
var
  y: string;
  yr: Integer;
begin
  Result := True;
  y := edtYear.Text;
  if (Length(y) > 1) and (y[1] = '0') then
    y := Copy(y, 2, 1);
  yr := StrToIntDef(y, -1);
  if Length(edtYear.Text) = 1 then
    edtYear.Text := '0' + edtYear.Text;
  if (yr = -1) and (y <> '') then
  begin
    HelpfulErrorMsg('You must enter a valid starting year', 0);
    edtYear.SetFocus;
    Result := False;
  end
  else if (cmbMonth.ItemIndex > 1) and (edtYear.Text = '') then
  begin
    HelpfulErrorMsg('You must enter the starting year', 0);
    edtYear.SetFocus;
    Result := False;
  end
  else if (cmbMonth.ItemIndex = 0) and (edtYear.Text <> '') then
  begin
    HelpfulErrorMsg('You must choose the starting month', 0);
    cmbMonth.SetFocus;
    Result := False;
  end
  else if edtAdvisors.Text = '' then
  begin
    HelpfulErrorMsg('You must enter your practice name', 0);
    edtAdvisors.SetFocus;
    Result := False;
  end
  else if edtPractice.Text = '' then
  begin
    HelpfulErrorMsg('You must enter your practice code', 0);
    edtPractice.SetFocus;
    Result := False;
  end;

    // Institution Name
  if Result and (cmbInstitutionName.ItemIndex = -1) then
  begin
    HelpfulErrorMsg('You must choose a Bank Name.', 0);
    cmbInstitutionName.SetFocus;
    Result := False;
  end;

  // Institution Other Name
  if Result and (cmbInstitutionName.ItemIndex = 0) and (edtInstitutionName.text = '') then
  begin
    HelpfulErrorMsg('You must enter a Bank Name.', 0);
    edtInstitutionName.SetFocus;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnPreviewClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PREVIEW;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnClearClick(Sender: TObject);
begin
  edtName1.Clear;
  edtName2.Clear;
  edtName3.Clear;
  edtBSB1.Clear;
  edtBSB2.Clear;
  edtBSB3.Clear;
  edtNumber1.Clear;
  edtNumber2.Clear;
  edtNumber3.Clear;
  edtClient1.Clear;
  edtClient2.Clear;
  edtClient3.Clear;
  edtCost1.Clear;
  edtcost2.Clear;
  edtCost3.Clear;
  edtbank.Clear;
  edtYear.Clear;
  cmbMonth.ItemIndex := 0;
  cmbMonthChange(Sender);
  rbMonthly.Checked := False;
  rbWeekly.Checked := False;
  rbDaily.Checked := False;
  cbProvisional.Checked := False;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnEmailClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_EMAIL;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_FILE;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnImportClick(Sender: TObject);
begin
  OpenDlg.FileName := ImportFile;
  if OpenDlg.Execute then
  begin
    ImportFile := OpenDlg.FileName;
    FButton := BTN_IMPORT;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PRINT;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.cmbInstitutionNameChange(Sender: TObject);
begin
  if cmbInstitutionName.ItemIndex = 0 then
  begin
    cmbInstitutionName.Width := OTHER_BANK_WIDTH;
    edtInstitutionName.text := '';
    edtInstitutionName.Enabled := true;
  end
  else
  begin
    cmbInstitutionName.Width := SET_BANK_WIDTH;
    edtInstitutionName.Enabled := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.cmbMonthChange(Sender: TObject);
begin
  if cmbMonth.ItemIndex = 1 then
  begin
    edtYear.Enabled := False;
    edtYear.Text := '';
  end
  else
    edtYear.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnCancelClick(Sender: TObject);
begin
  FButton := BTN_NONE;
  ModalResult := mrCancel;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FButton := BTN_NONE;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormShow(Sender: TObject);
begin
  FButton := BTN_NONE;
  BKHelpSetUp(Self, BKH_Accessing_a_Client_Authority_Form);
  ScrollBox1.ScrollInView(lblTitle); // scroll to top
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetImportFile(const Value: string);
begin
  FImportFile := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edtKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key < 'a') or (Key >'z')) and
     ((Key < 'A') or (Key >'Z')) and
     ((Key < '0') or (Key >'9')) and
     (Key <> #8) then     
    Key := #0;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edtExit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

end.
