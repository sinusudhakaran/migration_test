// Client Authority Form for AU accounts

// Note if you change this form you probably will need to change the other Authority forms too
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
  MaskHint,
  ovcbase,
  ovcef,
  ovcpb,
  ovcpf,
  MaskValidateEdit;

type
  TInstitutionType = (inNone, inOther, inBLO);

  TfrmCAF = class(TForm)
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
    mskAccountNumber: TMaskValidateEdit;
    pnlAccountError: TPanel;
    edtAccountNumber: TEdit;
    imgInfoAdditionalMsg: TImage;
    lblNoteAddFormReq: TLabel;
    lblBookSecureLink: TLabel;
    chkSupplyAsProvisional: TCheckBox;
    lblMaskErrorHint: TLabel;
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
    procedure lblBookSecureLinkClick(Sender: TObject);
    procedure lblBookSecureLinkMouseEnter(Sender: TObject);
    procedure lblBookSecureLinkMouseLeave(Sender: TObject);
    procedure mskAccountNumberChange(Sender: TObject);
  private
    fValidAccount : boolean;
    fAccountNumber : string;
    fMaskBsb : String;
    fOldInstName : string;

    fValidateError : boolean;
    fPracticeCode : string;
    fPracticeName : string;
    FButton: Byte;
    fMaskHint : TMaskHint;
    FImportFile: string;
    fInstitutionType : TInstitutionType;
    fCurrentDisplayError : string;

    procedure MaskValidateAccNumber();
    procedure SetInstitutionControls(aInstitutionType : TInstitutionType);
    procedure RemovePanelBorders();

    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask;
    procedure ClearForm();
    procedure SetDataSentToClient(aEnabled : boolean);
    procedure SetExistingClient(aEnabled : boolean);

    function ValidateAccount(aAccountNumber : string; var aFailedReason : string; var aShowDlg : boolean) : boolean;
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
  BanklinkOnlineServices,
  imagesfrm,
  AccountValidationErrorDlg;

Const
  UNIT_NAME = 'TfrmCAF';
  COUNTRY_CODE = 'AU';
  OTHER_BANK_WIDTH = 108;

{ TfrmTPA }
//------------------------------------------------------------------------------
procedure TfrmCAF.FormCreate(Sender: TObject);
var
  Index : integer;
  SortList : TStringList;
begin
  fValidAccount := false;
  fAccountNumber := '';
  fMaskBsb := '';
  fMaskHint := TMaskHint.create;

  RemovePanelBorders;
  lblMaskErrorHint.Caption := '';
  lblAccountHintLine.Caption := '';

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

  lblBookSecureLink.hint  := PRACINI_SecureFormLinkAU;
  fCurrentDisplayError := '';

  AppImages.ilFileActions_ClientMgr.GetBitmap(FILE_ACTIONS_INFO2, imgInfoAdditionalMsg.Picture.Bitmap);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMaskHint);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormShow(Sender: TObject);
begin
  FButton := BTN_NONE;
  BKHelpSetUp(Self, BKH_Accessing_a_Client_Authority_Form);

  if fInstitutionType = inOther then
    cmbInstitution.Width := OTHER_BANK_WIDTH
  else
    cmbInstitution.Width := edtBranch.Width;

  cmbInstitution.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.lblBookSecureLinkClick(Sender: TObject);
var
  link : string;
begin
  link := PRACINI_SecureFormLinkAU;

  if length(link) = 0 then
    exit;

  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.lblBookSecureLinkMouseEnter(Sender: TObject);
begin
  lblBookSecureLink.Font.Style := [fsUnderline];
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.lblBookSecureLinkMouseLeave(Sender: TObject);
begin
  lblBookSecureLink.Font.Style := [];
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if ModalResult = mrCancel then
    FButton := BTN_NONE;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateAccount(aAccountNumber : string; var aFailedReason : string; var aShowDlg : boolean) : boolean;
var
  InstCode : string;
  AccNumber : string;
begin
  Result := false;
  fValidAccount := false;
  fAccountNumber := '';
  aShowDlg := true;

    // Check if the Mapping File is set to ignore Validation
  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    if TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).IgnoreValidation then
    begin
      AccNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
      fAccountNumber := AccNumber;
      fValidAccount := true;
      Result := true;
      Exit;
    end;
  end;

  // Check if there is any data entered
  if length(fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.Text), fMaskBsb)) = 0 then
  begin
    aFailedReason := 'Please enter an Account Number.';
    aShowDlg := false;
    Exit;
  end;

  // check if the Mask validation failed
  if fValidateError then
  begin
    aFailedReason := 'Account Number is invalid, please re-enter.';
    aShowDlg := true;
    Exit;
  end;

  // Call the Online Validation
  AccNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    InstCode := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code;

    // Exception code for Bank of Queensland to insert zeros into the account portion of the account number
    // less than 10 zeros and more than 7
    if Institutions.DoInstituionExceptionCode(AccNumber, InstCode) = ieBOQ then
      Result := ProductConfigService.ValidateAccount(Institutions.PadQueensLandAccWithZeros(AccNumber), InstCode, COUNTRY_CODE, aFailedReason, true)
    else
      Result := ProductConfigService.ValidateAccount(AccNumber, InstCode, COUNTRY_CODE, aFailedReason, true);

    if Result then
    begin
      fValidAccount := true;
      fAccountNumber := AccNumber;
    end;
    aShowDlg := true;
  end;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateForm: Boolean;
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
    if length(fCurrentDisplayError) > 0 then
    begin
      ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                                 trim(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.EditText)),
                                 fCurrentDisplayError);
    end
    else
    begin
      MaskValidateAccNumber();
      if fValidAccount = false then
        ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                                   trim(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.EditText)),
                                   fCurrentDisplayError);
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
procedure TfrmCAF.chkDataSecureNewClick(Sender: TObject);
begin
  SetDataSentToClient(chkDataSecureNew.Checked);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.chkDataSecureExistingClick(Sender: TObject);
begin
  SetExistingClient(chkDataSecureExisting.Checked);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.cmbInstitutionChange(Sender: TObject);
begin
  case cmbInstitution.ItemIndex of
    -1 : SetInstitutionControls(inNone);
    0 : SetInstitutionControls(inOther);
  else
    SetInstitutionControls(inBLO);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberChange(Sender: TObject);
begin
  fValidAccount := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberEnter(Sender: TObject);
begin
  UpdateMask;
  mskAccountNumber.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.MaskValidateAccNumber();
var
  FailedReason : string;
  ShowDlg : boolean;
begin
  // Calls Validation on Exit of Account Number Control
  fCurrentDisplayError := '';
  lblMaskErrorHint.Caption := '';
  if not ValidateAccount(mskAccountNumber.EditText, FailedReason, ShowDlg) then
  begin
    if ShowDlg then
    begin
      ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                                 trim(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.EditText)),
                                 FailedReason);
    end
    else
    begin
      lblMaskErrorHint.Caption := FailedReason;
    end;

    fCurrentDisplayError := FailedReason;
  end;

  lblAccountHintLine.Repaint;
  fValidateError := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberExit(Sender: TObject);
begin
  MaskValidateAccNumber();
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberValidateEdit(var aRunExistingValidate: Boolean);
begin
  aRunExistingValidate := false;

  fValidateError := mskAccountNumber.DoValidation;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumberValidateError(var aRaiseError: Boolean);
begin
  aRaiseError := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.RemovePanelBorders;
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
  pnlInstTop.BevelOuter      := bvNone;
  pnlAccountError.BevelOuter := bvNone;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetDataSentToClient(aEnabled: boolean);
begin
  lblNoteAddFormReq.Visible := aEnabled;
  lblBookSecureLink.Visible := aEnabled;
  imgInfoAdditionalMsg.Visible := aEnabled;

  if aEnabled then
    chkDataSecureExisting.Checked := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetExistingClient(aEnabled: boolean);
begin
  lblSecureCode.Visible := aEnabled;
  edtSecureCode.Visible := aEnabled;

  if aEnabled then
    chkDataSecureNew.Checked := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetImportFile(const Value: string);
begin
  FImportFile := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetInstitutionControls(aInstitutionType : TInstitutionType);
var
  enableControls : boolean;
  oldInstDroppedDown : boolean;
  AccountNumber : string;

  function CanCopyData(): boolean;
  begin
    Result := not ((edtBranch.Text = '') and
                   (edtNameOfAccount.Text = '') and
                   (AccountNumber = '') and
                   (edtClientCode.Text = '') and
                   (edtCostCode.Text = '') and
                   (edtSecureCode.Text = ''));
  end;
begin
  edtInstitutionName.Text := '';
  edtAccountNumber.Text := '';
  if (fInstitutionType = inBLO) and (aInstitutionType = inOther) then
  begin
    AccountNumber := fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.Text), fMaskBsb);
    if CanCopyData() then
    begin
      edtInstitutionName.Text := fOldInstName;
      edtAccountNumber.Text := AccountNumber;
    end;
  end;

  // Set Controls depending on what Istitution Type is selected
  fInstitutionType := aInstitutionType;
  
  mskAccountNumber.EditMask := '';
  mskAccountNumber.EditText := '';
  fCurrentDisplayError := '';
  lblMaskErrorHint.Caption := '';
  fMaskBsb := '';
  fOldInstName := '';

  oldInstDroppedDown := cmbInstitution.DroppedDown;

  enableControls := false;
  case aInstitutionType of
    inNone  : begin
      chkSupplyAsProvisional.Visible := false;
      mskAccountNumber.Visible := true;
      edtAccountNumber.Visible := false;
      enableControls := false;
      edtInstitutionName.Visible := false;
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
          chkSupplyAsProvisional.Visible := true;
          mskAccountNumber.Visible := false;
          edtAccountNumber.Visible := true;
          edtInstitutionName.Visible := true;
          cmbInstitution.Width := OTHER_BANK_WIDTH;
          // Combo has no option to set the Drop down wider than the combo so this is
          // how you set it
          SendMessage(cmbInstitution.Handle, CB_SETDROPPEDWIDTH, edtBranch.Width, 0);
        end;
        inBLO  : begin
          chkSupplyAsProvisional.Visible := false;
          mskAccountNumber.Visible := true;
          edtAccountNumber.Visible := false;
          edtInstitutionName.Visible := false;
          cmbInstitution.Width := edtBranch.Width;

          if (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
             (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
          begin
            if TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).HasNewMask then
              mskAccountNumber.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NewMask
            else
              mskAccountNumber.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
          end;
          fMaskBsb := fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber.Text);

          fOldInstName := cmbInstitution.Text;
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
procedure TfrmCAF.UpdateMask;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine, mskAccountNumber, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
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
procedure TfrmCAF.edtAccountNumberExit(Sender: TObject);
begin
  fAccountNumber := trim(edtAccountNumber.Text);
  fValidAccount := (length(fAccountNumber) > 0);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edtExit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.ClearForm;
begin
  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);

  fMaskBsb := '';
  fAccountNumber := '';
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
  chkSupplyAsProvisional.Checked := false;
  fCurrentDisplayError := '';
  fCurrentDisplayError := '';
  lblMaskErrorHint.Caption := '';
  edtClientStartDte.AsDateTime := now();
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
procedure TfrmCAF.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_FILE;
    ModalResult := mrOk;
  end;
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
procedure TfrmCAF.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    FButton := BTN_PRINT;
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
    ClearForm();
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnClearClick(Sender: TObject);
begin
  ClearForm();
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnCancelClick(Sender: TObject);
begin
  FButton := BTN_NONE;
  ModalResult := mrCancel;
end;

end.

