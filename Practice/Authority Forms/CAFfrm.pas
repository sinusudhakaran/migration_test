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
  MaskValidateEdit, ComCtrls, WPRTEDefs, WPCTRMemo, WPCTRRich;

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
    lblOrContactiBizz: TLabel;
    lbliBizz: TLabel;
    lblAdditionalFormRequired: TLabel;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    ShapeBorder: TShape;
    pnlAmexMessage: TPanel;
    memMessage: TMemo;
    memAMEXEmailMessage: TMemo;
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
    procedure mskAccountNumber1Enter(Sender: TObject);
    procedure mskAccountNumber1Exit(Sender: TObject);
    procedure mskAccountNumber2Exit(Sender: TObject);
    procedure mskAccountNumber3Exit(Sender: TObject);
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
    procedure mskAccountNumber2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumber2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mskAccountNumber2ValidateEdit(var aRunExistingValidate: Boolean);
    procedure mskAccountNumber2ValidateError(var aRaiseError: Boolean);
    procedure mskAccountNumber3Enter(Sender: TObject);
    procedure mskAccountNumber3KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mskAccountNumber3MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mskAccountNumber3ValidateEdit(var aRunExistingValidate: Boolean);
    procedure edtNameOfAccount1Change(Sender: TObject);
    procedure edtClientCode1Change(Sender: TObject);
    procedure edtCostCode1Change(Sender: TObject);
    procedure edtNameOfAccount2Change(Sender: TObject);
    procedure edtClientCode2Change(Sender: TObject);
    procedure edtCostCode2Change(Sender: TObject);
    procedure mskAccountNumber3Change(Sender: TObject);
    procedure edtAccountNumber1Change(Sender: TObject);
    procedure edtAccountNumber2Change(Sender: TObject);
    procedure edtAccountNumber3Change(Sender: TObject);
    procedure edtInstitutionNameChange(Sender: TObject);
    procedure edt2Exit(Sender: TObject);
    procedure edt2KeyPress(Sender: TObject; var Key: Char);
    procedure edt3Exit(Sender: TObject);
    procedure lbliBizzClick(Sender: TObject);
    procedure lbliBizzMouseEnter(Sender: TObject);
    procedure lbliBizzMouseLeave(Sender: TObject);
    procedure lblAdditionalFormRequiredClick(Sender: TObject);
    procedure lblAdditionalFormRequiredMouseEnter(Sender: TObject);
    procedure lblAdditionalFormRequiredMouseLeave(Sender: TObject);
    procedure edtAccountNumber1Enter(Sender: TObject);
    procedure edtAccountNumber2Enter(Sender: TObject);
    procedure edtAccountNumber3Enter(Sender: TObject);
    procedure pnlDataClick(Sender: TObject);
    procedure lblMaskErrorHint2Click(Sender: TObject);
  private
    fValidAccount1 : boolean;
    fValidAccount2 : boolean;
    fValidAccount3 : boolean;
    fAccountNumber1 : string;
    fAccountNumber2 : string;
    fAccountNumber3 : string;
    fMaskBsb1 : String;
    fMaskBsb2 : String;
    fMaskBsb3 : String;
    Acc1ExitTriggered: boolean;
    Acc2ExitTriggered: boolean;
    Acc3ExitTriggered: boolean;    
    fOldInstName : string;

    fValidateError : boolean;
    fPracticeCode : string;
    fPracticeName : string;
    FButton: Byte;
    fMaskHint : TMaskHint;
    FImportFile: string;
    fInstitutionType : TInstitutionType;
    fCurrentDisplayError1 : string;
    fCurrentDisplayError2 : string;
    fCurrentDisplayError3 : string;
    FLoadMailTemplateFromResource : Boolean;
    FMailReplaceStrings: TStringList;
    FInstitutionCode : widestring;
    FMailSubject : string;
    procedure MaskValidateAccNumber(AccountNumText: string; WhichAccount: integer);
    procedure MaskValidateAccNumber1();
    procedure MaskValidateAccNumber2();
    procedure MaskValidateAccNumber3();
    procedure SetInstitutionControls(aInstitutionType : TInstitutionType);
    procedure RemovePanelBorders();

    function ValidateForm: Boolean;
    procedure SetImportFile(const Value: string);

    procedure UpdateMask1;
    procedure ClearForm();
    procedure SetDataSentToClient(aEnabled : boolean);
    procedure SetExistingClient(aEnabled : boolean);

    function ValidateAccount(aAccountNumber : string; WhichAccount: integer; var aFailedReason : string;
                             var aShowDlg : boolean) : boolean;
    function CheckAccount1Filled: boolean;
    function CheckAccount2Filled: boolean;
    function CheckAccount3Filled: boolean;
    procedure ToggleAccountFields;
    procedure ToggleAccount1Controls(Value: boolean);
    procedure ToggleAccount2Controls(Value: boolean);
    procedure ToggleAccount3Controls(Value: boolean);
    procedure UpdateMask2;
    procedure UpdateMask3;
    procedure FilterKey(var Key: Char);
    procedure RunExitEvents;
  public
    { Public declarations }
    property ButtonPressed: Byte read FButton;
    property ImportFile: string read FImportFile write SetImportFile;
    property PracticeCode : string read fPracticeCode write fPracticeCode;
    property PracticeName : string read fPracticeName write fPracticeName;

    property ValidAccount1  : boolean read fValidAccount1  write fValidAccount1;
    property AccountNumber1 : string  read fAccountNumber1 write fAccountNumber1;
    property AccountNumber2 : string  read fAccountNumber2 write fAccountNumber2;
    property AccountNumber3 : string  read fAccountNumber3 write fAccountNumber3;
    property InstitutionType : TInstitutionType read fInstitutionType write fInstitutionType;
    property InstitutionCode : widestring read FInstitutionCode write FInstitutionCode;
    property LoadMailTemplateFromResource: Boolean read FLoadMailTemplateFromResource write FLoadMailTemplateFromResource;
    property MailReplaceStrings : TStringList read FMailReplaceStrings write FMailReplaceStrings;
    property MailSubject: string read FMailSubject write FMailSubject;
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
  AccountValidationErrorDlg,
  GenUtils,
  bkBranding;

Const
  UNIT_NAME = 'TfrmCAF';
  COUNTRY_CODE = 'AU';
  OTHER_BANK_WIDTH = 108;
  IBIZZ_MESSAGE = 'Please contact iBizz.';

{ TfrmTPA }
//------------------------------------------------------------------------------
procedure TfrmCAF.FormCreate(Sender: TObject);
var
  Index : integer;
  SortList : TStringList;
begin
  LoadMailTemplateFromResource := False;
  FMailReplaceStrings:= TStringList.Create;
  fValidAccount1 := false;
  fValidAccount2 := false;
  fValidAccount3 := false;
  fAccountNumber1 := '';
  fAccountNumber2 := '';
  fAccountNumber3 := '';
  fMaskBsb1 := '';
  fMaskBsb2 := '';
  fMaskBsb3 := '';
  Acc1ExitTriggered := True;
  Acc2ExitTriggered := True;
  Acc3ExitTriggered := True;  
  fMaskHint := TMaskHint.create;

  RemovePanelBorders;
  lblMaskErrorHint1.Caption := '';
  lblAccountHintLine1.Caption := '';
  lblAccountHintLine2.Caption := '';
  lblAccountHintLine3.Caption := '';

  lbliBizz.Font.Color := HyperLinkColor;
  lblBookSecureLink.Font.Color := HyperLinkColor;
  lblAdditionalFormRequired.Font.Color := HyperLinkColor;

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
        TInstitutionItem(Institutions.Items[Index]).NoValidationRules := false;

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
  lblAdditionalFormRequired.hint := PRACINI_AdditionalFormLinkAU;
  lbliBizz.hint := IBIZZ_MESSAGE;
  fCurrentDisplayError1 := '';
  fCurrentDisplayError2 := '';
  fCurrentDisplayError3 := '';

  AppImages.ilFileActions_ClientMgr.GetBitmap(FILE_ACTIONS_INFO2, imgInfoAdditionalMsg.Picture.Bitmap);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.FormDestroy(Sender: TObject);
begin
  FreeAndNil(fMaskHint);
  FreeAndNil(FMailReplaceStrings);
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
  ToggleAccountFields;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.lblAdditionalFormRequiredClick(Sender: TObject);
var
  link : string;
begin
  link := PRACINI_AdditionalFormLinkAU;

  if length(link) = 0 then
    exit;

  ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
end;

procedure TfrmCAF.lblAdditionalFormRequiredMouseEnter(Sender: TObject);
begin
  lblAdditionalFormRequired.Font.Style := [fsUnderline];
end;

procedure TfrmCAF.lblAdditionalFormRequiredMouseLeave(Sender: TObject);
begin
  lblAdditionalFormRequired.Font.Style := [];
end;

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

procedure TfrmCAF.lbliBizzClick(Sender: TObject);
begin
  HelpfulInfoMsg(IBIZZ_MESSAGE, 0 );
end;

procedure TfrmCAF.lbliBizzMouseEnter(Sender: TObject);
begin
  lbliBizz.Font.Style := [fsUnderline];
end;

procedure TfrmCAF.lbliBizzMouseLeave(Sender: TObject);
begin
  lbliBizz.Font.Style := [];
end;

procedure TfrmCAF.lblMaskErrorHint2Click(Sender: TObject);
begin

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
  BloResult : TBloResult;

  procedure SetValidAccount(Value: boolean);
  begin
    case WhichAccount of
      1: fValidAccount1 := Value;
      2: fValidAccount2 := Value;
      3: fValidAccount3 := Value;
    end;
  end;

  procedure SetAccountNumber(Value: string);
  begin
    case WhichAccount of
      1: fAccountNumber1 := Value;
      2: fAccountNumber2 := Value;
      3: fAccountNumber3 := Value;
    end;
  end;

begin
  Result := false;
  SetValidAccount(false);
  SetAccountNumber('');
  aShowDlg := true;

    // Check if the Mapping File is set to ignore Validation
  if (cmbInstitution.ItemIndex > 0) and
     (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
     (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    if (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).IgnoreValidation) or
       (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NoValidationRules) then
    begin
      AccNumber := trim(fMaskHint.RemoveUnusedCharsFromAccNumber(aAccountNumber));
      SetAccountNumber(AccNumber);
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
      BloResult := ProductConfigService.ValidateAccount(Institutions.PadQueensLandAccWithZeros(AccNumber), InstCode, COUNTRY_CODE, aFailedReason, true)
    else
      BloResult := ProductConfigService.ValidateAccount(AccNumber, InstCode, COUNTRY_CODE, aFailedReason, true);

    if BloResult = bloFailedNonFatal then
      TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).NoValidationRules := true;

    if BloResult in [bloSuccess, bloFailedNonFatal] then
    begin
      SetValidAccount(true);
      SetAccountNumber(AccNumber);
      Result := true;
    end;
    aShowDlg := true;
  end;
end;

//------------------------------------------------------------------------------
function TfrmCAF.CheckAccount1Filled: boolean;
var
  MaskIsEmptyOrMatchesBsb: boolean;
begin
  MaskIsEmptyOrMatchesBsb :=
    (mskAccountNumber1.Text = '') or
    (RemoveNonNumericData(mskAccountNumber1.Text, false) = fMaskBsb1);
  Result := (edtNameOfAccount1.Text  <> '') or
            (edtAccountNumber1.Text  <> '') or
            (MaskIsEmptyOrMatchesBsb =  false);
end;

//------------------------------------------------------------------------------
function TfrmCAF.CheckAccount2Filled: boolean;
var
  MaskIsEmptyOrMatchesBsb: boolean;
begin
  MaskIsEmptyOrMatchesBsb :=
    (mskAccountNumber2.Text = '') or
    (RemoveNonNumericData(mskAccountNumber2.Text, false) = fMaskBsb2);
  Result := (edtNameOfAccount2.Text  <> '') or
            (edtAccountNumber2.Text  <> '') or
            (MaskIsEmptyOrMatchesBsb =  false);
  if not Result then
    lblMaskErrorHint2.Caption := '';
end;

//------------------------------------------------------------------------------
function TfrmCAF.CheckAccount3Filled: boolean;
var
  MaskIsEmptyOrMatchesBsb: boolean;
begin
  MaskIsEmptyOrMatchesBsb :=
    (mskAccountNumber3.Text = '') or
    (RemoveNonNumericData(mskAccountNumber3.Text, false) = fMaskBsb3);
  Result := (edtNameOfAccount3.Text  <> '') or
            (edtAccountNumber3.Text  <> '') or
            (MaskIsEmptyOrMatchesBsb =  false);
  if not Result then
    lblMaskErrorHint3.Caption := '';
end;

//------------------------------------------------------------------------------
// We want to force users to fill in the account boxes from top to bottom. This procedure
// ensures that a user will not be able to fill in details for an account box if the
// fields for the box above it are empty
procedure TfrmCAF.ToggleAccountFields;
var
  ShowAccount1: boolean;
begin
  // Don't show the first account if an institution hasn't been selected. If 'other' has been
  // selected, only show the first account if an institution has been entered into the now
  // visible edtInstitutionName
  ShowAccount1 := (cmbInstitution.ItemIndex <> -1);
  ToggleAccount1Controls(ShowAccount1);
  if not CheckAccount1Filled then
  begin
    ToggleAccount2Controls(CheckAccount2Filled);
    ToggleAccount3Controls(CheckAccount3Filled);
  end
  else if not CheckAccount2Filled then
  begin
    ToggleAccount2Controls(True);
    ToggleAccount3Controls(CheckAccount3Filled);
  end
  else
  begin
    ToggleAccount2Controls(True);
    ToggleAccount3Controls(True);
  end;
end;

//------------------------------------------------------------------------------
function TfrmCAF.ValidateForm: Boolean;
var
  Account2Filled, Account3Filled: boolean;
  DoValidateAccount1, DoValidateAccount2, DoValidateAccount3: boolean;
  Error1Filled, Error2Filled, Error3Filled: boolean;

  procedure ShowAccValidationError(AccNumberText: string; CurrentDisplayError: string);
  begin
    ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                               trim(fMaskHint.RemoveUnusedCharsFromAccNumber(AccNumberText)),
                               CurrentDisplayError);
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

  Account2Filled := CheckAccount2Filled;
  Account3Filled := CheckAccount3Filled;
  DoValidateAccount1 := True;
  DoValidateAccount2 := Account2Filled;
  DoValidateAccount3 := Account3Filled;

  // Account Number
  if Result and (fInstitutionType = inOther) then
  begin
    if (edtAccountNumber1.text = '') then
    begin
      HelpfulErrorMsg('Please enter an Account Number.', 0);
      edtAccountNumber1.SetFocus;
      Result := False;
    end else
    if (Account2Filled and (edtAccountNumber2.text = '')) then
    begin
      HelpfulErrorMsg('Please enter an Account Number.', 0);
      edtAccountNumber2.SetFocus;
      Result := False;
    end else
    if (Account3Filled and (edtAccountNumber3.text = '')) then
    begin
      HelpfulErrorMsg('Please enter an Account Number.', 0);
      edtAccountNumber3.SetFocus;
      Result := False;
    end;
  end;



  if Result and Account2Filled and (edtNameOfAccount2.Text = '') then
  begin
    HelpfulErrorMsg('Please enter the Name of Account.', 0);
    edtNameOfAccount2.SetFocus;
    Result := False;
  end;

  if Result and Account3Filled and (edtNameOfAccount3.Text = '') then
  begin
    HelpfulErrorMsg('Please enter the Name of Account.', 0);
    edtNameOfAccount3.SetFocus;
    Result := False;
  end;
  
  //Account Validation
  if (Result) and (fInstitutionType = inBLO) then
  begin
    Error1Filled := (length(fCurrentDisplayError1) > 0);
    Error2Filled := (length(fCurrentDisplayError2) > 0);
    Error3Filled := (length(fCurrentDisplayError3) > 0);
    if Error1Filled or Error2Filled or Error3Filled then
    begin
      if DoValidateAccount1 and Error1Filled then
        ShowAccValidationError(mskAccountNumber1.EditText, fCurrentDisplayError1);
      if DoValidateAccount2 and Error2Filled then
        ShowAccValidationError(mskAccountNumber2.EditText, fCurrentDisplayError2);
      if DoValidateAccount3 and Error3Filled then
        ShowAccValidationError(mskAccountNumber3.EditText, fCurrentDisplayError3);      
    end
    else
    begin
      MaskValidateAccNumber1();
      if Account2Filled then
        MaskValidateAccNumber2();
      if Account3Filled then
        MaskValidateAccNumber3();
      if DoValidateAccount1 and (fCurrentDisplayError1 <> '') then
        ShowAccValidationError(mskAccountNumber1.EditText, fCurrentDisplayError1);
      if DoValidateAccount2 and (fCurrentDisplayError2 <> '') then
        ShowAccValidationError(mskAccountNumber2.EditText, fCurrentDisplayError2);
      if DoValidateAccount3 and (fCurrentDisplayError3 <> '') then
        ShowAccValidationError(mskAccountNumber3.EditText, fCurrentDisplayError3);
    end;

    if (fValidAccount1 = false) and (fCurrentDisplayError1 <> '') then
    begin
      mskAccountNumber1.SetFocus;
      Result := False;
    end else
    if (fValidAccount2 = false) and (fCurrentDisplayError2 <> '') and Account2Filled then
    begin
      mskAccountNumber2.SetFocus;
      Result := False;
    end else
    if (fValidAccount3 = false) and (fCurrentDisplayError3 <> '') and Account3Filled then
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
  ToggleAccountFields;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1Enter(Sender: TObject);
begin
  UpdateMask1;
  mskAccountNumber1.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber2Enter(Sender: TObject);
begin
  UpdateMask2;
  mskAccountNumber2.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber3Change(Sender: TObject);
begin
  fValidAccount3 := false;
end;

procedure TfrmCAF.mskAccountNumber3Enter(Sender: TObject);
begin
  UpdateMask3;
  mskAccountNumber3.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.MaskValidateAccNumber(AccountNumText: string; WhichAccount: integer);
var
  FailedReason : string;
  ShowDlg : boolean;
begin
  // Calls Validation on Exit of Account Number Control
  case WhichAccount of
    1: begin
      fCurrentDisplayError1 := '';
      lblMaskErrorHint1.Caption := '';
    end;
    2: begin
      fCurrentDisplayError2 := '';
      lblMaskErrorHint2.Caption := '';
    end;
    3: begin
      fCurrentDisplayError3 := '';
      lblMaskErrorHint3.Caption := '';
    end;
  end;
  if not ValidateAccount(AccountNumText, WhichAccount, FailedReason, ShowDlg) then
  begin
    if ShowDlg then
      ShowAccountValidationError(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Name,
                                 trim(fMaskHint.RemoveUnusedCharsFromAccNumber(AccountNumText)), FailedReason);
    case WhichAccount of
      1: begin
        fCurrentDisplayError1 := FailedReason;
        if not ShowDlg then
          lblMaskErrorHint1.Caption := FailedReason;
      end;
      2: begin
        fCurrentDisplayError2 := FailedReason;
        if CheckAccount2Filled and not ShowDlg then
          lblMaskErrorHint2.Caption := FailedReason;
      end;
      3: begin
        fCurrentDisplayError3 := FailedReason;
        if CheckAccount3Filled and not ShowDlg then
          lblMaskErrorHint3.Caption := FailedReason;
      end;
    end;
  end;

  case WhichAccount of
    1: lblAccountHintLine1.Repaint;
    2: lblAccountHintLine2.Repaint;
    3: lblAccountHintLine3.Repaint;
  end;
  fValidateError := false;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.MaskValidateAccNumber1;
begin
  MaskValidateAccNumber(mskAccountNumber1.EditText, 1);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.MaskValidateAccNumber2;
begin
  MaskValidateAccNumber(mskAccountNumber2.EditText, 2);
end;

//------------------------------------------------------------------------------
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
procedure TfrmCAF.mskAccountNumber2Exit(Sender: TObject);
begin
  MaskValidateAccNumber2();
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber3Exit(Sender: TObject);
begin
  MaskValidateAccNumber3();
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask1;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask2;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber3KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  UpdateMask3;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.mskAccountNumber1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask1;
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
  fValidAccount2 := false;
  ToggleAccountFields;
end;

procedure TfrmCAF.mskAccountNumber2MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask2;
end;

procedure TfrmCAF.mskAccountNumber2ValidateEdit(var aRunExistingValidate: Boolean);
begin
  aRunExistingValidate := false; 
  fValidateError := mskAccountNumber2.DoValidation;
end;

procedure TfrmCAF.mskAccountNumber2ValidateError(var aRaiseError: Boolean);
begin
  aRaiseError := false;
end;

procedure TfrmCAF.mskAccountNumber3MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  UpdateMask3;
end;

procedure TfrmCAF.mskAccountNumber3ValidateEdit(
  var aRunExistingValidate: Boolean);
begin
  aRunExistingValidate := false; 
  fValidateError := mskAccountNumber3.DoValidation;
end;

procedure TfrmCAF.mskAccountNumber3ValidateError(var aRaiseError: Boolean);
begin
  aRaiseError := false;
end;

procedure TfrmCAF.pnlDataClick(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmCAF.RemovePanelBorders;
begin
  // I kept the Borders here so we can see the controls when developing but when running
  // they need to be removed
  pnlInstitution.BevelOuter  := bvNone;
//  pnlClient.BevelKind        := bkNone;
  pnlClientLabel.BevelOuter  := bvNone;
  pnlClientData.BevelOuter   := bvNone;
  pnlClientSpacer.BevelOuter := bvNone;
  pnlInstTop.BevelOuter      := bvNone;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.SetDataSentToClient(aEnabled: boolean);
begin
  lblNoteAddFormReq.Visible := aEnabled;
  lblBookSecureLink.Visible := aEnabled;
  imgInfoAdditionalMsg.Visible := aEnabled;
  lblOrContactiBizz.Visible := aEnabled;
  lbliBizz.Visible := aEnabled;

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
  FInstitutionCode := '';
  pnlAmexMessage.Visible := False;
  pnlInstitution.Visible := True;
  lblBranch.Visible := True;
  edtBranch.Visible := True;
  Bevel4.Visible := True;
  pnlClient.Visible := True;       
  pnlData.Visible := True;
  if ((cmbInstitution.ItemIndex >= 0) and (Assigned(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])))) then
    FInstitutionCode := TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code;
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
      fAccountNumber1 := trim(edtAccountNumber1.Text);
      fValidAccount1 := (length(fAccountNumber1) > 0);
      fAccountNumber2 := trim(edtAccountNumber2.Text);
      fValidAccount2 := (length(fAccountNumber2) > 0);
      fAccountNumber3 := trim(edtAccountNumber3.Text);
      fValidAccount3 := (length(fAccountNumber3) > 0);
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
  fCurrentDisplayError1 := '';
  fCurrentDisplayError2 := '';
  fCurrentDisplayError3 := '';
  lblMaskErrorHint1.Caption := '';
  lblMaskErrorHint2.Caption := '';
  lblMaskErrorHint3.Caption := '';
  fMaskBsb1 := '';
  fOldInstName := '';
  // Have moved the edit boxes over a bit so that both controls are visible in the
  // coding form, however we want them in the same place during execution
  edtAccountNumber1.Left := mskAccountNumber1.Left;
  edtAccountNumber2.Left := mskAccountNumber2.Left;
  edtAccountNumber3.Left := mskAccountNumber3.Left;

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

          if (cmbInstitution.ItemIndex >= 0) then // P5-171 - DN added check for unselected ItemIndex
            if (Assigned(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex])) and
               (cmbInstitution.Items.Objects[cmbInstitution.ItemIndex] is TInstitutionItem) then
            begin
              if (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX') then
              begin                            // order of making it hidden matters
                pnlData.Visible := False;
                pnlClient.Visible := False;
                Bevel4.Visible := False;
                lblBranch.Visible := False;
                edtBranch.Visible := False;
                pnlInstitution.Visible := False;
                pnlAmexMessage.Visible := True;
              end;

              btnPreview.Visible := (not(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX'));
              btnPrint.Visible := (not(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX'));
              btnFile.Visible := (not(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX'));
              btnImport.Visible := (not(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX'));
              btnClear.Visible := (not(TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX'));
              btnEmail.Left := 183;
              if (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX') then
              begin
                btnEmail.Left := btnPreview.Left;
                //Self.ActiveControl := btnEmail;
                //cmbInstitution.SetFocus;
              end;

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
              lblAdditionalFormRequired.Visible :=
                TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).ShowAdditionalForms;
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

  ToggleAccountFields;

  edtBranch.Enabled             := enableControls;
  lblBranch.Enabled             := enableControls;
  chkDataSecureNew.Enabled      := enableControls;
  chkDataSecureExisting.Enabled := enableControls;

  lblAccountHintLine1.Repaint;
  lblAccountHintLine2.Repaint;
  lblAccountHintLine3.Repaint;
end;

procedure TfrmCAF.ToggleAccount1Controls(Value: boolean);
begin
  lblNameOfAccount1.enabled      := Value;
  edtNameOfAccount1.enabled      := Value;
  lblAccount1.enabled            := Value;
  edtAccountNumber1.enabled      := Value;
  mskAccountNumber1.enabled      := Value;
  lblClientCode1.enabled         := Value;
  edtClientCode1.Enabled         := Value;
  lblCostCode1.Enabled           := Value;
  edtCostCode1.Enabled           := Value;
end;

procedure TfrmCAF.ToggleAccount2Controls(Value: boolean);
begin
  lblNameOfAccount2.enabled      := Value;
  edtNameOfAccount2.enabled      := Value;
  lblAccount2.enabled            := Value;
  edtAccountNumber2.enabled      := Value;
  mskAccountNumber2.enabled      := Value;
  lblClientCode2.enabled         := Value;
  edtClientCode2.Enabled         := Value;
  lblCostCode2.Enabled           := Value;
  edtCostCode2.Enabled           := Value;
end;

procedure TfrmCAF.ToggleAccount3Controls(Value: boolean);
begin
  lblNameOfAccount3.enabled      := Value;
  edtNameOfAccount3.enabled      := Value;
  lblAccount3.enabled            := Value;
  edtAccountNumber3.enabled      := Value;
  mskAccountNumber3.enabled      := Value;
  lblClientCode3.enabled         := Value;
  edtClientCode3.Enabled         := Value;
  lblCostCode3.Enabled           := Value;
  edtCostCode3.Enabled           := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.UpdateMask1;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine1, mskAccountNumber1, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
end;

procedure TfrmCAF.UpdateMask2;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine2, mskAccountNumber2, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
end;

procedure TfrmCAF.UpdateMask3;
begin
  fMaskHint.DrawMaskHint(lblAccountHintLine3, mskAccountNumber3, self.Color, $00000000, $00000000, clInfoBk, clMedGray , 8);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edt1KeyPress(Sender: TObject; var Key: Char);
begin
  FilterKey(Key);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edtAccountNumber1Change(Sender: TObject);
begin
  fValidAccount1 := false;
  ToggleAccountFields;
end;

procedure TfrmCAF.edtAccountNumber1Enter(Sender: TObject);
begin
  Acc1ExitTriggered := False;
end;

procedure TfrmCAF.edtAccountNumber1Exit(Sender: TObject);
begin
  fAccountNumber1 := trim(edtAccountNumber1.Text);
  fValidAccount1 := (length(fAccountNumber1) > 0);
  if not mskAccountNumber1.Visible then
  begin
    if (edtAccountNumber1.Text = '') then
      MaskValidateAccNumber('', 1)
    else
      lblMaskErrorHint1.Caption := '';
  end;
  Acc1ExitTriggered := True;
end;

procedure TfrmCAF.edtAccountNumber2Change(Sender: TObject);
begin
  fValidAccount2 := false;
  ToggleAccountFields;
end;

procedure TfrmCAF.edtAccountNumber2Enter(Sender: TObject);
begin
  Acc2ExitTriggered := False;
end;

procedure TfrmCAF.edtAccountNumber2Exit(Sender: TObject);
begin
  fAccountNumber2 := trim(edtAccountNumber2.Text);
  fValidAccount2 := (length(fAccountNumber2) > 0);
  if not mskAccountNumber2.Visible then
  begin
    if (edtAccountNumber2.Text = '') then
      MaskValidateAccNumber('', 2)
    else
      lblMaskErrorHint2.Caption := '';
  end;
  Acc2ExitTriggered := True;
end;

procedure TfrmCAF.edtAccountNumber3Change(Sender: TObject);
begin
  fValidAccount3 := false;
end;

procedure TfrmCAF.edtAccountNumber3Enter(Sender: TObject);
begin
  Acc3ExitTriggered := False;
end;

procedure TfrmCAF.edtAccountNumber3Exit(Sender: TObject);
begin
  fAccountNumber3 := trim(edtAccountNumber3.Text);
  fValidAccount3 := (length(fAccountNumber3) > 0);
  if not mskAccountNumber3.Visible then
  begin
    if (edtAccountNumber3.Text = '') then
      MaskValidateAccNumber('', 3)
    else
      lblMaskErrorHint3.Caption := '';
  end;
  Acc3ExitTriggered := True;
end;

procedure TfrmCAF.edtClientCode1Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edtClientCode2Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edt2Exit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

procedure TfrmCAF.edtCostCode1Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edtCostCode2Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edt2KeyPress(Sender: TObject; var Key: Char);
begin
  FilterKey(Key);
end;

procedure TfrmCAF.edtInstitutionNameChange(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edtNameOfAccount1Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

procedure TfrmCAF.edtNameOfAccount2Change(Sender: TObject);
begin
  ToggleAccountFields;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.edt1Exit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

procedure TfrmCAF.edt3Exit(Sender: TObject);
var
  e: TEdit;
begin
  e := Sender as TEdit;
  e.Text := Trim(e.Text);
end;

procedure TfrmCAF.edt3KeyPress(Sender: TObject; var Key: Char);
begin
  FilterKey(Key);
end;

procedure TfrmCAF.FilterKey(var Key: Char);
begin
  if ((Key < 'a') or (Key >'z')) and
     ((Key < 'A') or (Key >'Z')) and
     ((Key < '0') or (Key >'9')) and
     (Key <> #8) then
    Key := #0;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.ClearForm;
begin
  cmbInstitution.ItemIndex := -1;
  SetInstitutionControls(inNone);

  fMaskBsb1 := '';
  fMaskBsb2 := '';
  fMaskBsb3 := '';
  fAccountNumber1 := '';
  fAccountNumber2 := '';
  fAccountNumber3 := '';
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
  fCurrentDisplayError1 := '';
  fCurrentDisplayError2 := '';
  fCurrentDisplayError3 := '';
  edtClientStartDte.AsDateTime := now();
  lblAdditionalFormRequired.Visible := False;

  if Self.Visible then
    cmbInstitution.SetFocus;
end;

//------------------------------------------------------------------------------
// This is to deal with situations where Preview, File, etc. have been clicked
// before the exit event has been run for one of the account number fields
procedure TfrmCAF.RunExitEvents;
begin
  if not Acc1ExitTriggered then
    edtAccountNumber1Exit(self);
  if not Acc2ExitTriggered then
    edtAccountNumber2Exit(self);
  if not Acc3ExitTriggered then
    edtAccountNumber3Exit(self);
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnPreviewClick(Sender: TObject);
begin
  RunExitEvents;

  if ValidateForm then
  begin
    FButton := BTN_PREVIEW;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnFileClick(Sender: TObject);
begin
  RunExitEvents;

  if ValidateForm then
  begin
    FButton := BTN_FILE;
    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnEmailClick(Sender: TObject);
var
  Link : string;
begin
  MailReplaceStrings.Clear;
  LoadMailTemplateFromResource := False;
  FMailSubject := '';
  if (TInstitutionItem(cmbInstitution.Items.Objects[cmbInstitution.ItemIndex]).Code = 'AMEX') then
  begin
    FMailSubject := 'Bank feed for American Express bank account/s';
    //Link := '"https://qwww316.americanexpress.com/iFormsSecure/auth_reg/en_AU/iforms.do?cuid=RatingsAndReview_en_AU&evtsrc=link&evttype=0&cpid=email009%20&myobid='+AdminSystem.fdFields.fdBankLink_Code+ '&myobproduct=blp"';
    Link := 'http://myob.com.au/AMEX?myobid='+AdminSystem.fdFields.fdBankLink_Code+ '&myobproduct=blp"';

    LoadMailTemplateFromResource := True;
    MailReplaceStrings.Add('AMEXBANKLINKSITE='+Link);
    MailReplaceStrings.Add('#CODE='+AdminSystem.fdFields.fdBankLink_Code);

    FButton := BTN_EMAIL;
    ModalResult := mrOk;
  end
  else
  begin
    memAMEXEmailMessage.Clear;
    RunExitEvents;

    if ValidateForm then
    begin
      FButton := BTN_EMAIL;
      ModalResult := mrOk;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmCAF.btnPrintClick(Sender: TObject);
begin
  RunExitEvents;

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

