// Third Party Authority Form for NZ accounts
unit TPAfrm;

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
  Mask,
  OSFont,
  MaskHint;

type
  TfrmTPA = class(TForm)
    Panel6: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnCancel: TButton;
    btnPrint: TButton;
    btnEmail: TButton;
    btnClear: TButton;
    btnImport: TButton;
    Opendlg: TOpenDialog;
    ScrollBox1: TScrollBox;
    pnlAccount: TPanel;
    lblAcName: TLabel;
    lblAcNum: TLabel;
    lblClient: TLabel;
    lblCost: TLabel;
    edtAccountName: TEdit;
    edtClientCode: TEdit;
    edtCost1: TEdit;
    mskAccountNumber: TMaskEdit;
    lblAccountNumberLine: TLabel;
    lblAccountNumberHint: TLabel;
    pnlInstitution: TPanel;
    cmbInstitutionName: TComboBox;
    lblInstitution: TLabel;
    lblAccountValidationError: TLabel;
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
    procedure mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumberExit(Sender: TObject);
    procedure mskAccountNumberEnter(Sender: TObject);
    procedure mskAccountNumberMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    fPracticeCode : string;
    fPracticeName : string;
    FButton: Byte;
    fMaskHint : TMaskHint;
    FImportFile: string;
    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask;
    function ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
  public
    { Public declarations }
    property ButtonPressed: Byte read FButton;
    property ImportFile: string read FImportFile write SetImportFile;
    property PracticeCode : string read fPracticeCode write fPracticeCode;
    property PracticeName : string read fPracticeName write fPracticeName;
  end;


//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ErrorMoreFrm,
  Globals,
  AuthorityUtils,
  WinUtils,
  InfoMoreFrm,
  ShellAPI,
  bkHelp,
  InstitutionCol,
  BanklinkOnlineServices;

Const
  UNIT_NAME = 'TPAfrm';
  COUNTY_CODE = 'NZ';
  SET_BANK_WIDTH = 437;
  OTHER_BANK_WIDTH = 129;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormCreate(Sender: TObject);
var
  Index : integer;
  CountryIndex : integer;
begin
  fMaskHint := TMaskHint.create;

  {// Institution Country Names
  for Index := 0 to Institutions.CountryCodes.Count-1 do
  begin
    if Institutions.CountryCodes.Strings[Index] = COUNTY_CODE then
      CountryIndex := Index;

    cmbInstitutionCountry.AddItem(Institutions.CountryNames.Strings[Index],nil);
  end;
  cmbInstitutionCountry.itemindex := CountryIndex;
  cmbInstitutionCountry.Enabled := false;}

  lblAccountValidationError.Caption := '';

  // Institution Names
  cmbInstitutionName.AddItem('Other', nil);
  for Index := 0 to Institutions.Count-1 do
  begin
    if (TInstitutionItem(Institutions.Items[Index]).CountryCode = COUNTY_CODE) and
       (TInstitutionItem(Institutions.Items[Index]).Enabled) then
    begin
      if TInstitutionItem(Institutions.Items[Index]).HasNewName then
        cmbInstitutionName.AddItem(TInstitutionItem(Institutions.Items[Index]).NewName, TInstitutionItem(Institutions.Items[Index]))
      else
        cmbInstitutionName.AddItem(TInstitutionItem(Institutions.Items[Index]).Name, TInstitutionItem(Institutions.Items[Index]));
    end;
  end;

  cmbInstitutionName.Width := SET_BANK_WIDTH;
  //edtInstitutionName.Enabled := false;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMaskHint);
end;

//------------------------------------------------------------------------------
function TfrmTPA.ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
const
  COUNTRY_CODE = 'NZ';
var
  FailedReason : string;
  InstCode : string;
begin
  Result := true;
  if (cmbInstitutionName.ItemIndex > 0) and
     (Assigned(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex])) and
     (cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex] is TInstitutionItem) then
  begin
    InstCode := TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).Code;
    Result := ProductConfigService.ValidateAccount(aAccountNumber, InstCode, COUNTRY_CODE, aFailedReason);
  end;
end;

//------------------------------------------------------------------------------
function TfrmTPA.ValidateForm: Boolean;
var
  y: string;
  yr: Integer;
begin
  Result := True;
{  y := edtYear.Text;
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
  // must have day if month or year exist
  else if (cmbDay.ItemIndex = 0) and ((cmbMonth.ItemIndex > 1) or (edtYear.Text <> '')) then
  begin
    HelpfulErrorMsg('You must choose the starting day', 0);
    cmbDay.SetFocus;
    Result := False;
  end
  // must have month if day or year exist
  else if (cmbMonth.ItemIndex = 0) and ((cmbDay.ItemIndex > 0) or (edtYear.Text <> '')) then
  begin
    HelpfulErrorMsg('You must choose the starting month', 0);
    cmbMonth.SetFocus;
    Result := False;
  end
  // must have year if month or day exist
  else if (edtYear.Text = '') and ((cmbDay.ItemIndex > 0) or (cmbMonth.ItemIndex > 1)) then
  begin
    HelpfulErrorMsg('You must enter the starting year', 0);
    edtYear.SetFocus;
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
  // is entered date valid
  if Result and (cmbDay.ItemIndex > 0) and (cmbMonth.ItemIndex > 1) and (edtYear.Text <> '') then
  begin
    try
      EncodeDate(yr, cmbMonth.ItemIndex - 1, StrToIntDef(cmbDay.Text, -1));
    except
      begin
        HelpfulErrorMsg('You must enter a valid starting date', 0);
        cmbDay.SetFocus;
        Result := False;
      end;
    end;
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
  end;}
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnPreviewClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PREVIEW;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnClearClick(Sender: TObject);
begin
  {edtName1.Clear;
  edtName2.Clear;
  edtName3.Clear;
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
  cmbDay.ItemIndex := 0;
  cmbMonth.ItemIndex := 0;
  cmbMonthChange(Sender);
  rbMonthly.Checked := False;
  rbWeekly.Checked := False;
  rbDaily.Checked := True;
  rbReDate.Checked := False;
  rbDate.Checked := False;
  cbProvisional.Checked := False;
  cmbInstitutionName.ItemIndex := -1;
  cmbInstitutionName.Width := SET_BANK_WIDTH;
  edtInstitutionName.Clear;
  edtInstitutionName.Enabled := false;}
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnEmailClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_EMAIL;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_FILE;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnImportClick(Sender: TObject);
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
procedure TfrmTPA.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PRINT;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.cmbInstitutionNameChange(Sender: TObject);
begin
  if cmbInstitutionName.ItemIndex = 0 then
  begin
    cmbInstitutionName.Width := OTHER_BANK_WIDTH;
    //edtInstitutionName.Enabled := true;
    //edtInstitutionName.Text := '';
  end
  else
  begin
    cmbInstitutionName.Width := SET_BANK_WIDTH;
    //edtInstitutionName.Enabled := false;

    if (Assigned(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex])) and
       (cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex] is TInstitutionItem) then
    begin
      mskAccountNumber.EditText := '';
      mskAccountNumber.EditMask := TInstitutionItem(cmbInstitutionName.Items.Objects[cmbInstitutionName.ItemIndex]).AccountEditMask;
      UpdateMask;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.cmbMonthChange(Sender: TObject);
begin
  {if cmbMonth.ItemIndex = 1 then
  begin
    cmbDay.ItemIndex := 0;
    edtYear.Text := '';
    edtYear.Enabled := False;
    cmbDay.Enabled := False;
  end
  else
  begin
    edtYear.Enabled := True;
    cmbDay.Enabled := True;
  end; }
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnCancelClick(Sender: TObject);
begin
  FButton := BTN_NONE;
  ModalResult := mrCancel;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FButton := BTN_NONE;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormShow(Sender: TObject);
begin
  FButton := BTN_NONE;
  BKHelpSetUp(Self, BKH_Accessing_a_Third_Party_Authority_form);
  //ScrollBox1.ScrollInView(lblTitle); // scroll to top
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberEnter(Sender: TObject);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberExit(Sender: TObject);
var
  FailedReason : string;
begin
  if not ValidateAccount(mskAccountNumber.EditText, FailedReason) then
  begin
    lblAccountValidationError.Caption := FailedReason;
    //mskAccountNumber.SetFocus;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetImportFile(const Value: string);
begin
  FImportFile := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.UpdateMask;
begin
  fMaskHint.DrawMaskHint(lblAccountNumberLine, lblAccountNumberHint, mskAccountNumber, self.Color, $000000FF, $000000FF);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.edtKeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key < 'a') or (Key >'z')) and
     ((Key < 'A') or (Key >'Z')) and
     ((Key < '0') or (Key >'9')) and
     (Key <> #8) then
    Key := #0;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.edtExit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

end.
