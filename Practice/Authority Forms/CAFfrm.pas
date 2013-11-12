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
  OSFont,
  Mask,
  MaskHint;

type
  TfrmCAF = class(TForm)
    ScrollBox1: TScrollBox;
    Panel6: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnCancel: TButton;
    btnPrint: TButton;
    btnEmail: TButton;
    btnClear: TButton;
    btnImport: TButton;
    Opendlg: TOpenDialog;
    pnlMaskdata: TPanel;
    lblEditMask: TLabel;
    lblEditText: TLabel;
    lblText: TLabel;
    grpRural: TGroupBox;
    Label1: TLabel;
    pnlAccount: TPanel;
    lblAcName: TLabel;
    lblAcNum: TLabel;
    lblClient: TLabel;
    lblCost: TLabel;
    lblAccountNumberLine: TLabel;
    lblAccountNumberHint: TLabel;
    lblAccountValidationError: TLabel;
    edtAccountName: TEdit;
    edtClientCode: TEdit;
    edtCost1: TEdit;
    mskAccountNumber: TMaskEdit;
    pnlInstitution: TPanel;
    lblInstitution: TLabel;
    Label2: TLabel;
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
    procedure FormDestroy(Sender: TObject);
    procedure mskAccountNumberExit(Sender: TObject);
    procedure mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumberEnter(Sender: TObject);
    procedure mskAccountNumberMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    fMaskHint : TMaskHint;

    { Private declarations }
    FButton: Byte;
    FImportFile: string;
    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask;
    function ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
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
  InstitutionCol,
  BanklinkOnlineServices;

Const
  UNIT_NAME = 'CAFfrm';
  COUNTY_CODE = 'AU';
  SET_BANK_WIDTH = 437;
  OTHER_BANK_WIDTH = 129;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormCreate(Sender: TObject);
var
  Index : integer;
  CountryIndex : integer;
begin
  fMaskHint := TMaskHint.create;

  lblAccountValidationError.Caption := '';

  // Institution Names
  cmbInstitutionName.AddItem('Other', nil);
  for Index := 0 to Institutions.Count-1 do
  begin
    if TInstitutionItem(Institutions.Items[Index]).CountryCode = COUNTY_CODE then
      cmbInstitutionName.AddItem(TInstitutionItem(Institutions.Items[Index]).Name ,Institutions.Items[Index]);
  end;

  cmbInstitutionName.Width := SET_BANK_WIDTH;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMaskHint);
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
const
  COUNTRY_CODE = 'AU';
var
  FailedReason : string;
  InstCode : string;
  AccountNumber : string;
begin
  Result := true;

  AccountNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
  if (cmbInstitutionName.ItemIndex > 0) and
     (Assigned(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex])) and
     (cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex] is TInstitutionItem) then
  begin
    InstCode := TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).Code;
    Result := ProductConfigService.ValidateAccount(AccountNumber, InstCode, COUNTRY_CODE, aFailedReason, true);
  end;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateForm: Boolean;
var
  y: string;
  yr: Integer;
begin
  Result := True;
  {y := edtYear.Text;
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
  end;   }
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
  {edtName1.Clear;
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
  rbDaily.Checked := True;
  cbProvisional.Checked := False;
  cmbInstitutionName.ItemIndex := -1;
  cmbInstitutionName.Width := SET_BANK_WIDTH;
  edtInstitutionName.Clear;
  edtInstitutionName.Enabled := false;}
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
    //edtInstitutionName.Enabled := true;
    //edtInstitutionName.Text := '';
    grpRural.Visible := false;
    Label2.caption := '';
  end
  else
  begin
    cmbInstitutionName.Width := SET_BANK_WIDTH;
    //edtInstitutionName.Enabled := false;

    if (Assigned(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex])) and
       (cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex] is TInstitutionItem) then
    begin
      Label2.caption := 'Code - ' + TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).Code;

      grpRural.Visible := TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).HasRuralCode;
      if grpRural.Visible then
        Label1.Caption := 'Rural Code - ' + TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).RuralCode;

      mskAccountNumber.EditText := '';
      mskAccountNumber.EditMask := TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).AccountEditMask;
      UpdateMask;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.cmbMonthChange(Sender: TObject);
begin
  {if cmbMonth.ItemIndex = 1 then
  begin
    edtYear.Enabled := False;
    edtYear.Text := '';
  end
  else
    edtYear.Enabled := True;}
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
  //ScrollBox1.ScrollInView(lblTitle); // scroll to top
end;

procedure TfrmCAF.mskAccountNumberEnter(Sender: TObject);
begin
  lblAccountValidationError.Caption := '';
  UpdateMask;
end;

procedure TfrmCAF.mskAccountNumberExit(Sender: TObject);
var
  FailedReason : string;
begin
  lblEditMask.Caption := mskAccountNumber.EditMask;
  lblEditText.Caption := mskAccountNumber.EditText;
  lblText.Caption := mskAccountNumber.EditMask;

  lblAccountValidationError.Caption := '';
  if not ValidateAccount(mskAccountNumber.EditText, FailedReason) then
  begin
    lblAccountValidationError.Caption := FailedReason;
    //mskAccountNumber.SetFocus;
  end;
end;

procedure TfrmCAF.mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask;
end;

procedure TfrmCAF.mskAccountNumberMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetImportFile(const Value: string);
begin
  FImportFile := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.UpdateMask;
begin
  fMaskHint.DrawMaskHint(lblAccountNumberLine, lblAccountNumberHint, mskAccountNumber, self.Color, $000000FF, $000000FF, 16);
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
