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
  MaskHint,
  ovcbase,
  ovcef,
  ovcpb,
  ovcpf,
  MaskValidateEdit;

type
  TInstitutionType = (inNone, inOther, inBLO);

  TfrmTPA = class(TForm)
    Opendlg: TOpenDialog;
    btnPreview: TButton;
    btnFile: TButton;
    btnEmail: TButton;
    btnPrint: TButton;
    btnImport: TButton;
    btnClear: TButton;
    btnCancel: TButton;
    pnlMain: TPanel;
    pnlInstTop: TPanel;
    lblInstitution: TLabel;
    lblInstitutionOther: TLabel;
    cmbInstitution: TComboBox;
    edtInstitutionName: TEdit;
    pnlInstitution: TPanel;
    pnlInstData: TPanel;
    lblAccountHintLine: TLabel;
    edtBranch: TEdit;
    edtNameOfAccount: TEdit;
    pnlInstLabels: TPanel;
    lblBranch: TLabel;
    lblAccount: TLabel;
    lblNameOfAccount: TLabel;
    pnlInstSpacer: TPanel;
    pnlClient: TPanel;
    pnlClientLabel: TPanel;
    lblCostCode: TLabel;
    lblClientCode: TLabel;
    lblStartDate: TLabel;
    pnlClientData: TPanel;
    edtClientCode: TEdit;
    edtClientStartDte: TOvcPictureField;
    edtCostCode: TEdit;
    pnlClientSpacer: TPanel;
    pnlData: TPanel;
    lblRecieved: TLabel;
    lblSecureCode: TLabel;
    chkExistingClient: TCheckBox;
    chkDataToClient: TCheckBox;
    cmbRecieved: TComboBox;
    edtSecureCode: TEdit;
    pnlRural: TPanel;
    lblRuralInstitutions: TLabel;
    radReDateTransactions: TRadioButton;
    radDateShown: TRadioButton;
    mskAccountNumber: TMaskValidateEdit;
    pnlAccountError: TPanel;
    lblAccountValidationError: TLabel;
    edtAccountNumber: TEdit;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edtExit(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtKeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbInstitutionChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumberExit(Sender: TObject);
    procedure mskAccountNumberEnter(Sender: TObject);
    procedure mskAccountNumberMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkDataToClientClick(Sender: TObject);
    procedure chkExistingClientClick(Sender: TObject);
    procedure mskAccountNumberValidateError(var aRaiseError: Boolean);
    procedure mskAccountNumberValidateEdit(var aRunExistingValidate: Boolean);
    procedure edtAccountNumberExit(Sender: TObject);
  private
    fValidAccount : boolean;
    fAccountNumber : string;

    fValidateError : boolean;
    fPracticeCode : string;
    fPracticeName : string;
    FButton: Byte;
    fMaskHint : TMaskHint;
    FImportFile: string;
    fInstitutionType : TInstitutionType;

    procedure SetInstitutionControls(aInstitutionType : TInstitutionType);
    procedure RemovePanelBorders();

    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask;
    procedure SetDataSentToClient(aEnabled : boolean);
    procedure SetExistingClient(aEnabled : boolean);

    function ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
  public
    { Public declarations }
    property ButtonPressed: Byte read FButton;
    property ImportFile: string read FImportFile write SetImportFile;
    property PracticeCode : string read fPracticeCode write fPracticeCode;
    property PracticeName : string read fPracticeName write fPracticeName;

    property ValidAccount  : boolean read fValidAccount  write fValidAccount;
    property AccountNumber : string  read fAccountNumber write fAccountNumber;
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
  COUNTRY_CODE = 'NZ';
  OTHER_BANK_WIDTH = 175;

{ TfrmTPA }
//------------------------------------------------------------------------------
procedure TfrmTPA.FormCreate(Sender: TObject);
var
  Index : integer;
begin
  fValidAccount := false;
  fAccountNumber := '';
  fMaskHint := TMaskHint.create;

  RemovePanelBorders;
  lblAccountHintLine.Caption := '';
  lblAccountValidationError.Caption := '';

  // Institution Names
  cmbInstitution.AddItem('Other', nil);
  for Index := 0 to Institutions.Count-1 do
  begin
    if (TInstitutionItem(Institutions.Items[Index]).CountryCode = COUNTRY_CODE) and
       (TInstitutionItem(Institutions.Items[Index]).Enabled) then
    begin
      if TInstitutionItem(Institutions.Items[Index]).HasNewName then
        cmbInstitution.AddItem(TInstitutionItem(Institutions.Items[Index]).NewName, TInstitutionItem(Institutions.Items[Index]))
      else
        cmbInstitution.AddItem(TInstitutionItem(Institutions.Items[Index]).Name, TInstitutionItem(Institutions.Items[Index]));
    end;
  end;
  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);
  fValidateError := false;

  // Data Sent Direct to Client
  cmbRecieved.AddItem('BankLink Books Secure', nil);
  cmbRecieved.AddItem('BankLink Online Secure', nil);
  cmbRecieved.ItemIndex := 0;

  SetDataSentToClient(false);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMaskHint);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormShow(Sender: TObject);
begin
  FButton := BTN_NONE;
  BKHelpSetUp(Self, BKH_Accessing_a_Third_Party_Authority_form);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FButton := BTN_NONE;
end;

//------------------------------------------------------------------------------
function TfrmTPA.ValidateAccount(aAccountNumber : string; var aFailedReason : string) : boolean;
var
  FailedReason : string;
  InstCode : string;
  AccountNumber : string;
begin
  Result := false;
  fValidAccount := false;
  fAccountNumber := '';

  if length(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber)) = 0 then
  begin
    aFailedReason := 'You must enter an Account Number.';
    Exit;
  end;

  if fValidateError then
  begin
    aFailedReason := 'The Account Number has not been fully Entered.';
    Exit;
  end;

  AccountNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    InstCode := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code;
    Result := ProductConfigService.ValidateAccount(AccountNumber, InstCode, COUNTRY_CODE, aFailedReason, true);

    if Result then
    begin
      fValidAccount := true;
      fAccountNumber := AccountNumber;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmTPA.ValidateForm: Boolean;
begin
  Result := True;

  // Institution Name
  if Result and (cmbInstitution.ItemIndex = -1) then
  begin
    HelpfulErrorMsg('You must choose a Bank Name.', 0);
    cmbInstitution.SetFocus;
    Result := False;
  end;

  // Institution Other Name
  if Result and (cmbInstitution.ItemIndex = 0) and (edtInstitutionName.text = '') then
  begin
    HelpfulErrorMsg('You must enter a Bank Name.', 0);
    edtInstitutionName.SetFocus;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.chkDataToClientClick(Sender: TObject);
begin
  SetDataSentToClient(chkDataToClient.Checked);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.chkExistingClientClick(Sender: TObject);
begin
  SetExistingClient(chkExistingClient.Checked);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.cmbInstitutionChange(Sender: TObject);
begin
  case cmbInstitution.ItemIndex of
    -1 : SetInstitutionControls(inNone);
    0 : SetInstitutionControls(inOther);
  else
    SetInstitutionControls(inBLO);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberEnter(Sender: TObject);
begin
  lblAccountValidationError.Caption := '';
  UpdateMask;
  mskAccountNumber.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberExit(Sender: TObject);
var
  FailedReason : string;
begin
  lblAccountValidationError.Caption := '';
  if not ValidateAccount(mskAccountNumber.EditText, FailedReason) then
    lblAccountValidationError.Caption := FailedReason;

  lblAccountHintLine.Repaint;
  fValidateError := false;
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
procedure TfrmTPA.mskAccountNumberValidateEdit(var aRunExistingValidate: Boolean);
begin
  aRunExistingValidate := false;

  fValidateError := mskAccountNumber.DoValidation;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberValidateError(var aRaiseError: Boolean);
begin
  aRaiseError := false;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.RemovePanelBorders;
begin
  pnlInstitution.BevelOuter  := bvNone;
  pnlInstData.BevelOuter     := bvNone;
  pnlInstLabels.BevelOuter   := bvNone;
  pnlInstSpacer.BevelOuter   := bvNone;
  pnlClient.BevelOuter       := bvNone;
  pnlClientLabel.BevelOuter  := bvNone;
  pnlClientData.BevelOuter   := bvNone;
  pnlClientSpacer.BevelOuter := bvNone;
  pnlData.BevelOuter         := bvNone;
  pnlRural.BevelOuter        := bvNone;
  pnlInstTop.BevelOuter      := bvNone;
  pnlAccountError.BevelOuter := bvNone;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetDataSentToClient(aEnabled: boolean);
begin
  cmbRecieved.Visible       := aEnabled;
  lblRecieved.Visible       := aEnabled;
  chkExistingClient.Visible := aEnabled;

  if not aEnabled then
  begin
    chkExistingClient.Checked := false;
    SetExistingClient(false);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetExistingClient(aEnabled: boolean);
begin
  lblSecureCode.Visible := aEnabled;
  edtSecureCode.Visible := aEnabled;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetImportFile(const Value: string);
begin
  FImportFile := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetInstitutionControls(aInstitutionType : TInstitutionType);
var
  enableControls : boolean;
begin
  fInstitutionType := aInstitutionType;

  mskAccountNumber.EditMask := '';
  mskAccountNumber.EditText := '';
  edtInstitutionName.Text := '';
  edtAccountNumber.Text := '';
  lblAccountValidationError.Caption := '';
  pnlRural.Visible := false;

  case aInstitutionType of
    inNone  : begin
      mskAccountNumber.Visible := false;
      edtAccountNumber.Visible := true;
      enableControls := false;
      edtInstitutionName.Visible := false;
      lblInstitutionOther.Visible := false;
      cmbInstitution.Width := edtBranch.Width;
    end;
    inOther, inBLO : begin
      enableControls := true;

      case aInstitutionType of
        inOther  : begin
          mskAccountNumber.Visible := false;
          edtAccountNumber.Visible := true;
          edtInstitutionName.Visible := true;
          lblInstitutionOther.Visible := true;
          cmbInstitution.Width := OTHER_BANK_WIDTH;
        end;
        inBLO  : begin
          mskAccountNumber.Visible := true;
          edtAccountNumber.Visible := false;
          edtInstitutionName.Visible := false;
          lblInstitutionOther.Visible := false;
          cmbInstitution.Width := edtBranch.Width;

          if (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
             (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
          begin
            pnlRural.Visible := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).HasRuralCode;

            mskAccountNumber.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
          end;
        end;
      end;
    end;
  end;

  lblNameOfAccount.enabled  := enableControls;
  edtNameOfAccount.enabled  := enableControls;
  lblAccount.enabled        := enableControls;
  mskAccountNumber.enabled  := enableControls;
  lblClientCode.enabled     := enableControls;
  edtClientCode.Enabled     := enableControls;
  lblCostCode.Enabled       := enableControls;
  edtCostCode.Enabled       := enableControls;
  //lblStartDate.Enabled      := enableControls;
  //edtClientStartDte.Enabled := enableControls;
  edtBranch.Enabled         := enableControls;
  lblBranch.Enabled         := enableControls;
  chkDataToClient.Enabled   := enableControls;

  lblAccountHintLine.Repaint;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.UpdateMask;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine, mskAccountNumber, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
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
procedure TfrmTPA.edtAccountNumberExit(Sender: TObject);
begin
  fAccountNumber := trim(edtAccountNumber.Text);
  fValidAccount := (length(fAccountNumber) > 0);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.edtExit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
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
procedure TfrmTPA.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_FILE;
    ModalResult := mrOk;
  end;
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
procedure TfrmTPA.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PRINT;
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
procedure TfrmTPA.btnClearClick(Sender: TObject);
begin
  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);

  edtBranch.Text := '';
  edtNameOfAccount.Text := '';
  edtAccountNumber.Text := '';
  mskAccountNumber.EditMask := '';
  mskAccountNumber.EditText := '';
  edtClientCode.Text := '';
  edtClientStartDte.Text := '';
  edtCostCode.Text := '';
  edtSecureCode.Text := '';
  chkExistingClient.Checked := false;
  chkDataToClient.Checked := false;
  lblAccountValidationError.Caption := '';
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnCancelClick(Sender: TObject);
begin
  FButton := BTN_NONE;
  ModalResult := mrCancel;
end;

end.
