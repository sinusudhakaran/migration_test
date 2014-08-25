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
    pnlInstData1: TPanel;
    lblAccountHintLine1: TLabel;
    edtNameOfAccount1: TEdit;
    pnlInstLabels1: TPanel;
    lblAccount1: TLabel;
    lblNameOfAccount1: TLabel;
    mskAccountNumber1: TMaskValidateEdit;
    mskAccountNumber2: TMaskValidateEdit;
    edtAccountNumber1: TEdit;
    lblClientCode1: TLabel;
    lblBranch: TLabel;
    edtBranch: TEdit;
    edtClientCode1: TEdit;
    edtCostCode1: TEdit;
    lblCostCode1: TLabel;
    lblMaskErrorHint1: TLabel;
    edtClientCode2: TEdit;
    edtCostCode2: TEdit;
    pnlInstData2: TPanel;
    lblAccountHintLine2: TLabel;
    lblClientCode2: TLabel;
    lblCostCode2: TLabel;
    lblMaskErrorHint2: TLabel;
    edtNameOfAccount2: TEdit;
    edtAccountNumber2: TEdit;
    pnlInstLabels2: TPanel;
    lblAccount2: TLabel;
    lblNameOfAccount2: TLabel;
    pnlInstData3: TPanel;
    lblAccountHintLine3: TLabel;
    lblClientCode3: TLabel;
    lblCostCode3: TLabel;
    lblMaskErrorHint3: TLabel;
    edtNameOfAccount3: TEdit;
    mskAccountNumber3: TMaskValidateEdit;
    edtAccountNumber3: TEdit;
    edtClientCode3: TEdit;
    edtCostCode3: TEdit;
    pnlInstLabels3: TPanel;
    lblAccount3: TLabel;
    lblNameOfAccount3: TLabel;
    pnlData: TPanel;
    lblSecureCode: TLabel;
    imgInfoAdditionalMsg: TImage;
    lblNoteAddFormReq: TLabel;
    lblBookSecureLink: TLabel;
    chkDataSecureExisting: TCheckBox;
    chkDataSecureNew: TCheckBox;
    edtSecureCode: TEdit;
    chkSupplyAsProvisional: TCheckBox;
    pnlClient: TPanel;
    pnlClientLabel: TPanel;
    lblStartDate: TLabel;
    pnlClientData: TPanel;
    edtClientStartDte: TOvcPictureField;
    pnlClientSpacer: TPanel;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edt1Exit(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edt1KeyPress(Sender: TObject; var Key: Char);
    procedure btnClearClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbInstitutionChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure mskAccountNumber1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumber1Exit(Sender: TObject);
    procedure mskAccountNumber1Enter(Sender: TObject);
    procedure mskAccountNumber1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure chkDataSecureNewClick(Sender: TObject);
    procedure chkDataSecureExistingClick(Sender: TObject);
    procedure mskAccountNumber1ValidateError(var aRaiseError: Boolean);
    procedure mskAccountNumber1ValidateEdit(var aRunExistingValidate: Boolean);
    procedure edtAccountNumber1Exit(Sender: TObject);
    procedure lblBookSecureLinkClick(Sender: TObject);
    procedure lblBookSecureLinkMouseEnter(Sender: TObject);
    procedure lblBookSecureLinkMouseLeave(Sender: TObject);
    procedure mskAccountNumber1Change(Sender: TObject);
    procedure edt3KeyPress(Sender: TObject; var Key: Char);
    procedure mskAccountNumber3ValidateError(var aRaiseError: Boolean);
    procedure edtAccountNumber3Exit(Sender: TObject);
    procedure edtAccountNumber2Exit(Sender: TObject);
    procedure mskAccountNumber2Change(Sender: TObject);
    procedure mskAccountNumber2Enter(Sender: TObject);
    procedure mskAccountNumber2Exit(Sender: TObject);
    procedure mskAccountNumber2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumber2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mskAccountNumber2ValidateEdit(var aRunExistingValidate: Boolean);
    procedure mskAccountNumber2ValidateError(var aRaiseError: Boolean);
    procedure mskAccountNumber3Change(Sender: TObject);
    procedure mskAccountNumber3Enter(Sender: TObject);
    procedure mskAccountNumber3Exit(Sender: TObject);
    procedure mskAccountNumber3KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumber3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mskAccountNumber3ValidateEdit(var aRunExistingValidate: Boolean);
  private
    fValidAccount1 : boolean;
    fValidAccount2 : boolean;
    fValidAccount3 : boolean;
    fAccountNumber : string;
    fMaskBsb1 : String;
    fMaskBsb2 : String;
    fMaskBsb3 : String;
    fOldInstName : string;

    fValidateError : boolean;
    fPracticeCode : string;
    fPracticeName : string;
    FButton: Byte;
    fMaskHint : TMaskHint;
    FImportFile: string;
    fInstitutionType : TInstitutionType;
    fCurrentDisplayError : string;

    procedure MaskValidateAccNumber(AccountNumText: string; WhichAccount: integer);
    procedure MaskValidateAccNumber1();
    procedure MaskValidateAccNumber2();
    procedure MaskValidateAccNumber3();
    procedure SetInstitutionControls(aInstitutionType : TInstitutionType);
    procedure RemovePanelBorders();

    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask;
    procedure ClearForm();
    procedure SetDataSentToClient(aEnabled : boolean);
    procedure SetExistingClient(aEnabled : boolean);

    function ValidateAccount(aAccountNumber : string; WhichAccount: integer; var aFailedReason : string;
                             var aShowDlg : boolean) : boolean;
  public
    { Public declarations }
    property ButtonPressed: Byte read FButton;
    property ImportFile: string read FImportFile write SetImportFile;
    property PracticeCode : string read fPracticeCode write fPracticeCode;
    property PracticeName : string read fPracticeName write fPracticeName;

    property ValidAccount1  : boolean read fValidAccount1  write fValidAccount1;
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
  fValidAccount1 := false;
  fValidAccount2 := false;
  fValidAccount3 := false;
  fAccountNumber := '';
  fMaskBsb1 := '';
  fMaskBsb2 := '';
  fMaskBsb3 := '';
  fMaskHint := TMaskHint.create;

  RemovePanelBorders;
  lblMaskErrorHint1.Caption := '';
  lblAccountHintLine1.Caption := '';
  lblAccountHintLine2.Caption := '';
  lblAccountHintLine3.Caption := '';

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
function TfrmCAF.ValidateAccount(aAccountNumber : string; WhichAccount: integer; var aFailedReason : string; var aShowDlg : boolean) : boolean;
var
  InstCode : string;
  AccNumber : string;
  AccNumberText : string;

  procedure SetValidAccount(Value: boolean);
  begin
    case WhichAccount of
      1: fValidAccount1 := false;
      2: fValidAccount2 := false;
      3: fValidAccount3 := false;
    end;
  end;

begin
  Result := false;
  SetValidAccount(false);
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
      SetValidAccount(true);
      Result := true;
      Exit;
    end;
  end;

  // Check if there is any data entered
  case WhichAccount of
    1: AccNumberText := mskAccountNumber1.Text;
    2: AccNumberText := mskAccountNumber2.Text;
    3: AccNumberText := mskAccountNumber3.Text;
  end;
  if length(fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(AccNumberText), fMaskBsb1)) = 0 then
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
      SetValidAccount(true);
      fAccountNumber := AccNumber;
    end;
    aShowDlg := true;
  end;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateForm: Boolean;

  procedure ShowAccValidationError(AccNumberText: string);
  begin
    ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                               trim(fMaskHint.RemoveUnusedCharsFromAccNumber(AccNumberText)),
                               fCurrentDisplayError);
  end;

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
  if Result and (edtNameOfAccount1.text = '') then
  begin
    HelpfulErrorMsg('Please enter the Name of Account.', 0);
    edtNameOfAccount1.SetFocus;
    Result := False;
  end;

  // Account Number
  if Result and (fInstitutionType = inOther) and (edtAccountNumber1.text = '') then
  begin
    HelpfulErrorMsg('Please enter an Account Number.', 0);
    edtAccountNumber1.SetFocus;
    Result := False;
  end;

  //Account Validation
  if (Result) and (fInstitutionType = inBLO) and not (fValidAccount1 and fValidAccount2 and fValidAccount3) then
  begin
    if length(fCurrentDisplayError) > 0 then
    begin
      // TODO: should show one error for all accounts, not a separate error for each one
      if (fValidAccount1 = false) then
        ShowAccValidationError(mskAccountNumber1.EditText);
      if (fValidAccount2 = false) then
        ShowAccValidationError(mskAccountNumber2.EditText);
      if (fValidAccount3 = false) then
        ShowAccValidationError(mskAccountNumber3.EditText);      
    end
    else
    begin
      MaskValidateAccNumber1();
      if fValidAccount1 = false then
        ShowAccValidationError(mskAccountNumber1.EditText);
    end;

    if fValidAccount1 = false then
    begin
      mskAccountNumber1.SetFocus;
      Result := False;
    end else
    if fValidAccount2 = false then
    begin
      mskAccountNumber2.SetFocus;
      Result := False;
    end else
    if fValidAccount3 = false then
    begin
      mskAccountNumber3.SetFocus;
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
procedure TfrmCAF.mskAccountNumber1Change(Sender: TObject);
begin
  fValidAccount1 := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1Enter(Sender: TObject);
begin
  UpdateMask;
  mskAccountNumber1.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.MaskValidateAccNumber(AccountNumText: string; WhichAccount: integer);
var
  FailedReason : string;
  ShowDlg : boolean;
begin
  // Calls Validation on Exit of Account Number Control
  fCurrentDisplayError := '';
  case WhichAccount of
    1: lblMaskErrorHint1.Caption := '';
    2: lblMaskErrorHint2.Caption := '';
    3: lblMaskErrorHint3.Caption := '';
  end;
  if not ValidateAccount(AccountNumText, 1, FailedReason, ShowDlg) then
  begin
    if ShowDlg then
    begin
      ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                                 trim(fMaskHint.RemoveUnusedCharsFromAccNumber(AccountNumText)), FailedReason);
    end
    else
    begin
      case WhichAccount of
        1: lblMaskErrorHint1.Caption := FailedReason;
        2: lblMaskErrorHint2.Caption := FailedReason;
        3: lblMaskErrorHint3.Caption := FailedReason;
      end;
    end;

    fCurrentDisplayError := FailedReason;
  end;

  case WhichAccount of
    1: lblAccountHintLine1.Repaint;
    2: lblAccountHintLine2.Repaint;
    3: lblAccountHintLine3.Repaint;
  end;
  fValidateError := false;
end;

procedure TfrmCAF.MaskValidateAccNumber1;
begin
  MaskValidateAccNumber(mskAccountNumber1.EditText, 1);
end;

procedure TfrmCAF.MaskValidateAccNumber2;
begin
  MaskValidateAccNumber(mskAccountNumber2.EditText, 2);
end;

procedure TfrmCAF.MaskValidateAccNumber3;
begin
  MaskValidateAccNumber(mskAccountNumber3.EditText, 3);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1Exit(Sender: TObject);
begin
  MaskValidateAccNumber1();
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1ValidateEdit(var aRunExistingValidate: Boolean);
begin
  aRunExistingValidate := false;

  fValidateError := mskAccountNumber1.DoValidation;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1ValidateError(var aRaiseError: Boolean);
begin
  aRaiseError := false;
end;

procedure TfrmCAF.mskAccountNumber2Change(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2Enter(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2Exit(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2ValidateEdit(
  var aRunExistingValidate: Boolean);
begin
//
end;

procedure TfrmCAF.mskAccountNumber2ValidateError(var aRaiseError: Boolean);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3Change(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3Enter(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3Exit(Sender: TObject);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3ValidateEdit(
  var aRunExistingValidate: Boolean);
begin
//
end;

procedure TfrmCAF.mskAccountNumber3ValidateError(var aRaiseError: Boolean);
begin
//
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.RemovePanelBorders;
begin
  // I kept the Borders here so we can see the controls when developing but when running
  // they need to be removed
  pnlInstitution.BevelOuter  := bvNone;
  pnlClient.BevelOuter       := bvNone;
  pnlClientLabel.BevelOuter  := bvNone;
  pnlClientData.BevelOuter   := bvNone;
  pnlClientSpacer.BevelOuter := bvNone;
//  pnlData.BevelOuter         := bvNone;
  pnlInstTop.BevelOuter      := bvNone;
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
  AccNumber1 : string;
  AccNumber2 : string;
  AccNumber3 : string;

  //----------------------------------------------------------------------------
  function CanCopyData(): boolean;
  begin
    Result := not ((edtBranch.Text = '') and
                   (edtNameOfAccount1.Text = '') and
                   (AccNumber1 = '') and
                   (edtClientCode1.Text = '') and
                   (edtCostCode1.Text = '') and
                   (edtSecureCode.Text = ''));
  end;
begin
  edtInstitutionName.Text := '';
  edtAccountNumber1.Text := '';
  edtAccountNumber2.Text := '';
  edtAccountNumber3.Text := '';
  if (fInstitutionType = inBLO) and (aInstitutionType = inOther) then
  begin
    AccNumber1 := fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber1.Text), fMaskBsb1);
    AccNumber2 := fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber2.Text), fMaskBsb2);
    AccNumber3 := fMaskHint.RemovedMaskBsbFromAccountNumber(fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber3.Text), fMaskBsb3);
    if CanCopyData() then
    begin
      edtInstitutionName.Text := fOldInstName;
      edtAccountNumber1.Text := AccNumber1;
      edtAccountNumber2.Text := AccNumber2;
      edtAccountNumber3.Text := AccNumber3;
      fAccountNumber := trim(edtAccountNumber1.Text);
      fValidAccount1 := (length(fAccountNumber) > 0);
      fAccountNumber := trim(edtAccountNumber2.Text);
      fValidAccount2 := (length(fAccountNumber) > 0);
      fAccountNumber := trim(edtAccountNumber3.Text);
      fValidAccount3 := (length(fAccountNumber) > 0);
    end;
  end;

  // Set Controls depending on what Istitution Type is selected
  fInstitutionType := aInstitutionType;
  
  mskAccountNumber1.EditMask := '';
  mskAccountNumber1.EditText := '';
  mskAccountNumber2.EditMask := '';
  mskAccountNumber2.EditText := '';
  mskAccountNumber3.EditMask := '';
  mskAccountNumber3.EditText := '';
  fCurrentDisplayError := '';
  lblMaskErrorHint1.Caption := '';
  lblMaskErrorHint2.Caption := '';
  lblMaskErrorHint3.Caption := '';
  fMaskBsb1 := '';
  fOldInstName := '';

  oldInstDroppedDown := cmbInstitution.DroppedDown;

  enableControls := false;
  case aInstitutionType of
    inNone  : begin
      chkSupplyAsProvisional.Visible := false;
      mskAccountNumber1.Visible := true;
      mskAccountNumber2.Visible := true;
      mskAccountNumber3.Visible := true;
      edtAccountNumber1.Visible := false;
      edtAccountNumber2.Visible := false;
      edtAccountNumber3.Visible := false;
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
          mskAccountNumber1.Visible := false;
          mskAccountNumber2.Visible := false;
          mskAccountNumber3.Visible := false;
          edtAccountNumber1.Visible := true;
          edtAccountNumber2.Visible := true;
          edtAccountNumber3.Visible := true;
          edtInstitutionName.Visible := true;
          cmbInstitution.Width := OTHER_BANK_WIDTH;
          // Combo has no option to set the Drop down wider than the combo so this is
          // how you set it
          SendMessage(cmbInstitution.Handle, CB_SETDROPPEDWIDTH, edtBranch.Width, 0);
        end;
        inBLO  : begin
          chkSupplyAsProvisional.Visible := false;
          mskAccountNumber1.Visible := true;
          mskAccountNumber2.Visible := true;
          mskAccountNumber3.Visible := true;
          edtAccountNumber1.Visible := false;
          edtAccountNumber2.Visible := false;
          edtAccountNumber3.Visible := false;
          edtInstitutionName.Visible := false;
          cmbInstitution.Width := edtBranch.Width;

          if (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
             (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
          begin
            if TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).HasNewMask then
            begin
              mskAccountNumber1.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NewMask;
              mskAccountNumber2.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NewMask;
              mskAccountNumber3.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NewMask;
            end
            else
            begin
              mskAccountNumber1.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
              mskAccountNumber2.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
              mskAccountNumber3.EditMask := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).AccountEditMask;
            end;
          end;
          fMaskBsb1 := fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber1.Text);
          fMaskBsb2 := fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber2.Text);
          fMaskBsb3 := fMaskHint.RemoveUnusedCharsFromAccNumber(mskAccountNumber3.Text);

          fOldInstName := cmbInstitution.Text;
        end;
      end;
    end;
  end;

  cmbInstitution.DroppedDown := oldInstDroppedDown;

  lblNameOfAccount1.enabled      := enableControls;
  edtNameOfAccount1.enabled      := enableControls;
  lblAccount1.enabled            := enableControls;
  mskAccountNumber1.enabled      := enableControls;
  lblClientCode1.enabled         := enableControls;
  edtClientCode1.Enabled         := enableControls;
  lblCostCode1.Enabled           := enableControls;
  edtCostCode1.Enabled           := enableControls;

  lblNameOfAccount2.enabled      := enableControls;
  edtNameOfAccount2.enabled      := enableControls;
  lblAccount2.enabled            := enableControls;
  mskAccountNumber2.enabled      := enableControls;
  lblClientCode2.enabled         := enableControls;
  edtClientCode2.Enabled         := enableControls;
  lblCostCode2.Enabled           := enableControls;
  edtCostCode2.Enabled           := enableControls;

  lblNameOfAccount3.enabled      := enableControls;
  edtNameOfAccount3.enabled      := enableControls;
  lblAccount3.enabled            := enableControls;
  mskAccountNumber3.enabled      := enableControls;
  lblClientCode3.enabled         := enableControls;
  edtClientCode3.Enabled         := enableControls;
  lblCostCode3.Enabled           := enableControls;
  edtCostCode3.Enabled           := enableControls;

  edtBranch.Enabled             := enableControls;
  lblBranch.Enabled             := enableControls;
  chkDataSecureNew.Enabled      := enableControls;
  chkDataSecureExisting.Enabled := enableControls;

  lblAccountHintLine1.Repaint;
  lblAccountHintLine2.Repaint;
  lblAccountHintLine3.Repaint;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.UpdateMask;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine1, mskAccountNumber1, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
  fMaskHint.DrawMaskHint(lblAccountHintLine2, mskAccountNumber2, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
  fMaskHint.DrawMaskHint(lblAccountHintLine3, mskAccountNumber3, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  if ((Key < 'a') or (Key >'z')) and
     ((Key < 'A') or (Key >'Z')) and
     ((Key < '0') or (Key >'9')) and
     (Key <> #8) then
    Key := #0;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edtAccountNumber1Exit(Sender: TObject);
begin
  fAccountNumber := trim(edtAccountNumber1.Text);
  fValidAccount1 := (length(fAccountNumber) > 0);
end;

procedure TfrmCAF.edtAccountNumber2Exit(Sender: TObject);
begin
  fAccountNumber := trim(edtAccountNumber2.Text);
  fValidAccount1 := (length(fAccountNumber) > 0);
end;

procedure TfrmCAF.edtAccountNumber3Exit(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edt1Exit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

procedure TfrmCAF.edt3KeyPress(Sender: TObject; var Key: Char);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmCAF.ClearForm;
begin
  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);

  fMaskBsb1 := '';
  fAccountNumber := '';
  edtBranch.Text := '';

  edtNameOfAccount1.Text := '';
  edtAccountNumber1.Text := '';
  mskAccountNumber1.EditMask := '';
  mskAccountNumber1.EditText := '';
  edtClientCode1.Text := '';
  edtCostCode1.Text := '';
  lblMaskErrorHint1.Caption := '';

  edtNameOfAccount2.Text := '';
  edtAccountNumber2.Text := '';
  mskAccountNumber2.EditMask := '';
  mskAccountNumber2.EditText := '';
  edtClientCode2.Text := '';
  edtCostCode2.Text := '';
  lblMaskErrorHint2.Caption := '';

  edtNameOfAccount3.Text := '';
  edtAccountNumber3.Text := '';
  mskAccountNumber3.EditMask := '';
  mskAccountNumber3.EditText := '';
  edtClientCode3.Text := '';
  edtCostCode3.Text := '';
  lblMaskErrorHint3.Caption := '';

  edtClientStartDte.Text := '';
  edtSecureCode.Text := '';
  chkDataSecureNew.Checked := false;
  chkDataSecureExisting.Checked := false;
  chkSupplyAsProvisional.Checked := false;
  fCurrentDisplayError := '';
  fCurrentDisplayError := '';
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

