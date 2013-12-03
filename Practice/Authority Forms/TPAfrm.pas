// Third Party Authority Form for NZ accounts
// Note if you change this form you probably will need to change the other Authority forms too
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
  OSFont,
  Mask,
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
    lblSecureCode: TLabel;
    chkDataSecureExisting: TCheckBox;
    chkDataSecureNew: TCheckBox;
    edtSecureCode: TEdit;
    pnlRural: TPanel;
    lblRuralInstitutions: TLabel;
    radReDateTransactions: TRadioButton;
    radDateShown: TRadioButton;
    mskAccountNumber: TMaskValidateEdit;
    pnlAccountError: TPanel;
    lblAccountValidationError: TLabel;
    edtAccountNumber: TEdit;
    lblNoteAddFormReq: TLabel;
    lblBookSecureLink: TLabel;
    lblOrContactiBizz: TLabel;
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
    procedure chkDataSecureNewClick(Sender: TObject);
    procedure chkDataSecureExistingClick(Sender: TObject);
    procedure mskAccountNumberValidateError(var aRaiseError: Boolean);
    procedure mskAccountNumberValidateEdit(var aRunExistingValidate: Boolean);
    procedure edtAccountNumberExit(Sender: TObject);
    procedure radDateShownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure radDateShownMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure radReDateTransactionsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure radReDateTransactionsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure lblBookSecureLinkClick(Sender: TObject);
    procedure lblBookSecureLinkMouseEnter(Sender: TObject);
    procedure lblBookSecureLinkMouseLeave(Sender: TObject);
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

    procedure MaskValidateAccNumber();
    function GetInstitutionCode() : string;
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
    property InstitutionType : TInstitutionType read fInstitutionType write fInstitutionType;
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
  OTHER_BANK_WIDTH = 108;

{ TfrmTPA }
//------------------------------------------------------------------------------
procedure TfrmTPA.FormCreate(Sender: TObject);
var
  Index : integer;
  SortList : TStringList;
begin
  fValidAccount := false;
  fAccountNumber := '';
  fMaskHint := TMaskHint.create;

  RemovePanelBorders;
  lblAccountHintLine.Caption := '';
  lblAccountValidationError.Caption := '';

  // Institution Names
  SortList := TStringList.Create;
  SortList.Clear;
  try
    //Sorts the data in a string list
    for Index := 0 to Institutions.Count-1 do
    begin
      if (TInstitutionItem(Institutions.Items[Index]).CountryCode = COUNTRY_CODE) and
       (TInstitutionItem(Institutions.Items[Index]).Enabled) then
      begin
        if TInstitutionItem(Institutions.Items[Index]).HasNewName then
          SortList.AddObject(TInstitutionItem(Institutions.Items[Index]).NewName, TInstitutionItem(Institutions.Items[Index]))
        else
          SortList.AddObject(TInstitutionItem(Institutions.Items[Index]).Name, TInstitutionItem(Institutions.Items[Index]));
      end;
    end;

    SortList.Sort;

    // Adds other to the Top of the list after sorting
    cmbInstitution.AddItem('Other', nil);
    for Index := 0 to SortList.Count-1 do
      cmbInstitution.AddItem(SortList.Strings[Index], SortList.Objects[Index]);

  finally
    FreeAndNil(SortList);
  end;

  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);
  fValidateError := false;

  SetDataSentToClient(false);

  edtClientStartDte.AsDateTime := now();

  lblBookSecureLink.hint := PRACINI_SecureFormLinkNZ;
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

  cmbInstitution.SetFocus;
end;

//------------------------------------------------------------------------------
function TfrmTPA.GetInstitutionCode: string;
begin
  Result := '';

  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    if (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).HasRuralCode) and
       (radDateShown.checked) then
      Result := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).RuralCode
    else
      Result := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.lblBookSecureLinkClick(Sender: TObject);
var
  link : string;
begin
  link := PRACINI_SecureFormLinkNZ;

  if length(link) = 0 then
    exit;

  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.lblBookSecureLinkMouseEnter(Sender: TObject);
begin
  lblBookSecureLink.Font.Style := [fsUnderline];
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.lblBookSecureLinkMouseLeave(Sender: TObject);
begin
  lblBookSecureLink.Font.Style := [];
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

  // Check if there is any data entered
  if length(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber)) = 0 then
  begin
    aFailedReason := 'Please enter an Account Number.';
    Exit;
  end;

  // check if the Mask validation failed
  if fValidateError then
  begin
    aFailedReason := 'Account Number is invalid, please re-enter.';
    Exit;
  end;

  // Call the Online Validation
  AccountNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    InstCode := GetInstitutionCode();

    // Exception code for ANZ and National Bank, removed National bank so must set to NAT when
    // ANZ is selected and Account bank is for national
    if Institutions.DoInstituionExceptionCode(AccountNumber, InstCode) = ieNAT then
      InstCode := 'NAT';

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
  if Result and (fInstitutionType = inNone) then
  begin
    HelpfulErrorMsg('Please choose an Institution.', 0);
    cmbInstitution.SetFocus;
    Result := False;
  end;

  // Institution Other Name
  if Result and (fInstitutionType = inOther) and (edtInstitutionName.text = '') then
  begin
    HelpfulErrorMsg('Please enter an Institution Name.', 0);
    edtInstitutionName.SetFocus;
    Result := False;
  end;

  // Name of Account
  if Result and (edtNameOfAccount.text = '') then
  begin
    HelpfulErrorMsg('Please enter the Name of Account.', 0);
    edtNameOfAccount.SetFocus;
    Result := False;
  end;

  // Account Number
  if Result and (fInstitutionType = inOther) and (edtAccountNumber.text = '') then
  begin
    HelpfulErrorMsg('Please enter an Account Number.', 0);
    edtAccountNumber.SetFocus;
    Result := False;
  end;

  //Account Validation
  if (Result) and (fValidAccount = false) and (fInstitutionType = inBLO) then
  begin
    if length(lblAccountValidationError.Caption) > 0 then
      HelpfulErrorMsg(lblAccountValidationError.Caption, 0)
    else
    begin
      MaskValidateAccNumber();
      if fValidAccount = false then
        HelpfulErrorMsg(lblAccountValidationError.Caption, 0);
    end;

    if fValidAccount = false then
    begin
      mskAccountNumber.SetFocus;
      Result := False;
    end;
  end;

  // Secure Code
  if Result and (chkDataSecureExisting.Checked = true) and (edtSecureCode.text = '') then
  begin
    HelpfulErrorMsg('Please enter a Secure Code.', 0);
    edtSecureCode.SetFocus;
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.chkDataSecureNewClick(Sender: TObject);
begin
  SetDataSentToClient(chkDataSecureNew.Checked);
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.chkDataSecureExistingClick(Sender: TObject);
begin
  SetExistingClient(chkDataSecureExisting.Checked);
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
  UpdateMask;
  mskAccountNumber.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.MaskValidateAccNumber();
var
  FailedReason : string;
begin
  // Calls Validation on Exit of Account Number Control
  lblAccountValidationError.Caption := '';
  if not ValidateAccount(mskAccountNumber.EditText, FailedReason) then
    lblAccountValidationError.Caption := FailedReason;

  lblAccountHintLine.Repaint;
  fValidateError := false;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.mskAccountNumberExit(Sender: TObject);
begin
  MaskValidateAccNumber();
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
procedure TfrmTPA.radDateShownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (not radDateShown.checked) and
     (fInstitutionType = inBLO) then
  begin
    lblAccountValidationError.Caption := '';
    fValidAccount := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.radDateShownMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (not radDateShown.checked) and
     (fInstitutionType = inBLO) then
  begin
    lblAccountValidationError.Caption := '';
    fValidAccount := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.radReDateTransactionsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (not radReDateTransactions.checked) and
     (fInstitutionType = inBLO) then
  begin
    lblAccountValidationError.Caption := '';
    fValidAccount := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.radReDateTransactionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (not radReDateTransactions.checked) and
     (fInstitutionType = inBLO) then
  begin
    lblAccountValidationError.Caption := '';
    fValidAccount := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.RemovePanelBorders;
begin
  // I kept the Borders here so we can see the controls when developing but when running
  // they need to be removed
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
  lblNoteAddFormReq.Visible := aEnabled;
  lblBookSecureLink.Visible := aEnabled;
  lblOrContactiBizz.Visible := aEnabled;

  if aEnabled then
    chkDataSecureExisting.Checked := false;
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.SetExistingClient(aEnabled: boolean);
begin
  lblSecureCode.Visible := aEnabled;
  edtSecureCode.Visible := aEnabled;

  if aEnabled then
    chkDataSecureNew.Checked := false;
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
  oldInstDroppedDown : boolean;
begin
  // Set Controls depending on what Istitution Type is selected
  fInstitutionType := aInstitutionType;

  mskAccountNumber.EditMask := '';
  mskAccountNumber.EditText := '';
  edtInstitutionName.Text := '';
  edtAccountNumber.Text := '';
  lblAccountValidationError.Caption := '';
  pnlRural.Visible := false;

  oldInstDroppedDown := cmbInstitution.DroppedDown;

  case aInstitutionType of
    inNone  : begin
      mskAccountNumber.Visible := true;
      edtAccountNumber.Visible := false;
      enableControls := false;
      edtInstitutionName.Visible := false;
      lblInstitutionOther.Visible := false;
      cmbInstitution.Width := edtBranch.Width;
      chkDataSecureNew.Checked := false;
      chkDataSecureExisting.Checked := false;
      SetDataSentToClient(false);
      SetExistingClient(false);
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
          // Combo has no option to set the Drop down wider than the combo so this is
          // how you set it
          SendMessage(cmbInstitution.Handle, CB_SETDROPPEDWIDTH, edtBranch.Width, 0);
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

            if TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).HasNewMask then
              mskAccountNumber.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NewMask
            else
              mskAccountNumber.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
          end;
        end;
      end;
    end;
  end;

  cmbInstitution.DroppedDown := oldInstDroppedDown;

  lblNameOfAccount.enabled      := enableControls;
  edtNameOfAccount.enabled      := enableControls;
  lblAccount.enabled            := enableControls;
  mskAccountNumber.enabled      := enableControls;
  lblClientCode.enabled         := enableControls;
  edtClientCode.Enabled         := enableControls;
  lblCostCode.Enabled           := enableControls;
  edtCostCode.Enabled           := enableControls;
  edtBranch.Enabled             := enableControls;
  lblBranch.Enabled             := enableControls;
  chkDataSecureNew.Enabled      := enableControls;
  chkDataSecureExisting.Enabled := enableControls;

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
  chkDataSecureNew.Checked := false;
  chkDataSecureExisting.Checked := false;
  lblAccountValidationError.Caption := '';
end;

//------------------------------------------------------------------------------
procedure TfrmTPA.btnCancelClick(Sender: TObject);
begin
  FButton := BTN_NONE;
  ModalResult := mrCancel;
end;

end.
