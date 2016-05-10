// Client Authority Form for UK accounts
unit NewCAFfrm;

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
  PdfFieldEditor;

type
  TfrmNewCAF = class(TForm)
    btnFile: TButton;
    btnEmail: TButton;
    btnPrint: TButton;
    btnResetForm: TButton;
    btnCancel: TButton;
    PdfFieldEdit: TPdfFieldEdit;
    PrintDialog: TPrintDialog;
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFileClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnResetFormClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FButton: Byte;
    FClientEmail: string;
    fCountry : integer;
    fInstitution : integer;
    cmbBankName : TComboBox;

    procedure UpperCaseTextKeyPress(Sender: TObject; var Key: Char);
    procedure UpperCaseOnlyTextKeyPress(Sender: TObject; var Key: Char);

    procedure NumericDashKeyPress(Sender: TObject; var Key: Char);
    procedure NumericKeyPress(Sender: TObject; var Key: Char);

    procedure CAFStartMonthChange(Sender: TObject);
    procedure WMGetMinMaxInfo( var Message :TWMGetMinMaxInfo ); message WM_GETMINMAXINFO;
    procedure cmbBankNameChange(Sender: TObject);
  protected
    procedure SetRadioValues(aDaily, aWeekly, aMonthly : boolean);

    Procedure RadDailyOnClick(Sender: TObject);
    Procedure RadWeeklyOnClick(Sender: TObject);
    Procedure RadMonthlyOnClick(Sender: TObject);
    procedure SetClientEmail(value: string);

    function ValidateForm: Boolean;

    function GetPDFFormFieldEdit(aTitle : WideString) : TPDFFormFieldItemEdit;
    function GetPDFFormFieldCombo(aTitle : WideString) : TPDFFormFieldItemComboBox;
    function GetPDFFormFieldRadio(aTitle : WideString) : TPDFFormFieldItemRadioButton;
    function GetPDFFormFieldCheck(aTitle : WideString) : TPDFFormFieldItemCheckBox;
    function InitPDF : boolean;
    procedure InitFields;
    procedure SetFocusForPDFControl;
    procedure ResetFields;
    procedure SendPDFViaEmail;
    procedure SaveToFile;
    procedure PrintPDF;
    procedure CreateQRCode;
  public
    function Execute(aCountry, aInstitution : integer) : boolean;

    property ClientEmail: string read FClientEmail write SetClientEmail;
    property ButtonPressed: Byte read FButton;
  end;

  function OpenCustAuth(w_PopupParent: Forms.TForm; aCountry : integer; aClientEmail : string) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ErrorMoreFrm,
  InfoMoreFrm,
  bkConst,
  globals,
  SelectInstitutionfrm,
  MailFrm,
  Printers,
  GenUtils,
  SaveReportToDlg,
  ReportDefs,
  YesNoDlg,
  ShellAPI,
  BKHelp,
  {$IFNDEF PRACTICE-7}
  CafQrCode,
  {$EndIf}
  WebUtils,
  InstitutionCol,
  bkBranding,
  bkTemplates,
  ReportFileFormat,
  bkProduct;

const
  COUNTRY_CODE = 'UK';
  SET_BANK_WIDTH = 457;
  OTHER_BANK_WIDTH = 129;
  SET_BRANCH_WIDTH_HSBC = 250;

//------------------------------------------------------------------------------
function OpenCustAuth(w_PopupParent: Forms.TForm; aCountry : integer; aClientEmail : string) : boolean;
var
  frmNewCAF: TfrmNewCAF;
  Institution : integer;
begin
  Result := false;
  Institution := istUKNone;

  if aCountry = whUK then
  begin
    Institution := PickCAFInstitution(w_PopupParent, aCountry);
    if Institution = istUKNone then
      Exit;
  end;

  frmNewCAF := TfrmNewCAF.Create(Application);
  try
    //Required for the proper handling of the window z-order so that a modal window does not show-up behind another window
    frmNewCAF.PopupParent := w_PopupParent;
    frmNewCAF.PopupMode   := pmExplicit;
    frmNewCaf.ClientEmail := aClientEmail;

    Result := frmNewCAF.Execute(aCountry, Institution);
  finally
    FreeAndNil(frmNewCAF);
  end;
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.Execute(aCountry, aInstitution : integer): boolean;
begin
  Result := false;

  fCountry := aCountry;
  fInstitution := aInstitution;

  if not (aCountry = whUK) then
    Exit;

  if aInstitution = istUKNone then
    Exit;

  if not InitPDF then
    Exit;

  ShowModal;

  Result := true;
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.GetPDFFormFieldEdit(aTitle : WideString) : TPDFFormFieldItemEdit;
var
  PDFFormFieldItem : TPDFFormFieldItem;
begin
  Result := Nil;

  PDFFormFieldItem := PdfFieldEdit.PDFFormFields.GetFieldByTitle(aTitle);
  if (PDFFormFieldItem is TPDFFormFieldItemEdit) then
    Result := TPDFFormFieldItemEdit(PDFFormFieldItem);
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.GetPDFFormFieldCombo(aTitle : WideString) : TPDFFormFieldItemComboBox;
var
  PDFFormFieldItem : TPDFFormFieldItem;
begin
  Result := Nil;

  PDFFormFieldItem := PdfFieldEdit.PDFFormFields.GetFieldByTitle(aTitle);
  if (PDFFormFieldItem is TPDFFormFieldItemComboBox) then
    Result := TPDFFormFieldItemComboBox(PDFFormFieldItem);
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.GetPDFFormFieldRadio(aTitle : WideString) : TPDFFormFieldItemRadioButton;
var
  PDFFormFieldItem : TPDFFormFieldItem;
begin
  Result := Nil;

  PDFFormFieldItem := PdfFieldEdit.PDFFormFields.GetFieldByTitle(aTitle);
  if (PDFFormFieldItem is TPDFFormFieldItemRadioButton) then
    Result := TPDFFormFieldItemRadioButton(PDFFormFieldItem);
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.GetPDFFormFieldCheck(aTitle : WideString) : TPDFFormFieldItemCheckBox;
var
  PDFFormFieldItem : TPDFFormFieldItem;
begin
  Result := Nil;

  PDFFormFieldItem := PdfFieldEdit.PDFFormFields.GetFieldByTitle(aTitle);
  if (PDFFormFieldItem is TPDFFormFieldItemCheckBox) then
    Result := TPDFFormFieldItemCheckBox(PDFFormFieldItem);
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.InitPDF : boolean;
var
  PDFFilePath : Widestring;
  PublicKeyFilePath : Widestring;
begin
  Result := false;
  {$IfNdef PRACTICE-7}
  if not DirectoryExists( GLOBALS.TemplateDir ) then
  begin
    HelpfulErrorMsg('Can''t find Templates Directory - ' + GLOBALS.TemplateDir, 0);
    Exit;
  end;

  PDFFilePath := GLOBALS.TemplateDir + TTemplates.UKCafTemplates[fInstitution];

  if not FileExists( PDFFilePath ) then
  begin
    HelpfulErrorMsg('Can''t find Template - ' + PDFFilePath, 0);
    Exit;
  end;

  if not DirectoryExists( GLOBALS.PublicKeysDir ) then
  begin
    HelpfulErrorMsg('Can''t find Publickeys Directory - ' + GLOBALS.PublicKeysDir, 0);
    Exit;
  end;

  PublicKeyFilePath := GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CAF_QRCODE;

  if not FileExists( PublicKeyFilePath ) then
  begin
    HelpfulErrorMsg('Can''t find CAF QrCode Publickey - ' + PublicKeyFilePath, 0);
    Exit;
  end;

  try
    PdfFieldEdit.PDFFilePath := PDFFilePath;
    PdfFieldEdit.Zoom := 3;
    PdfFieldEdit.Active := true;

    InitFields;

    PdfFieldEdit.AutoSetControlTabs;

    ResetFields;

    Result := True;
  except
    on E : Exception do
      HelpfulErrorMsg('Error loading Customer Authority form - ' +  e.Message , 0);
  end;
  {$EndIf}
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.cmbBankNameChange(Sender: TObject);
var
  PDFFormFieldItemEdit : TPDFFormFieldItemEdit;
begin
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
  if Assigned(PDFFormFieldItemEdit) then
  begin

    if cmbBankName.ItemIndex = 0 then
    begin
      cmbBankName.Width := OTHER_BANK_WIDTH;
      PDFFormFieldItemEdit.Edit.text := '';
      PDFFormFieldItemEdit.Edit.Enabled := true;
    end
    else
    begin
      cmbBankName.Width := SET_BANK_WIDTH;
      PDFFormFieldItemEdit.Edit.text := cmbBankName.Text;
      PDFFormFieldItemEdit.Edit.Enabled := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCaf.InitFields;
var
  MonthIndex : integer;
  RadButtonTop : integer;
  NewBankLabel : TLabel;

  BankIndex : integer;
  shpNewBankDetails           : TShape;
  PDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;
  PDFFormFieldItemRadioButton : TPDFFormFieldItemRadioButton;
  PDFFormFieldItemCheckBox    : TPDFFormFieldItemCheckBox;
  BankNameFieldItem: TPDFFormFieldItemEdit;
begin
  RadButtonTop := 0; // For the compiler

  // Name of Account
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFNameOfAccount);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 60;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the account name';

    if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFNameOfAccount2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFNameOfAccount3);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFNameOfAccount4);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFNameOfAccount5);
    end;
  end;

  // Bank Code / Sort Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 8;
    PDFFormFieldItemEdit.Edit.OnKeyPress := NumericDashKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the sort code for this account';

    if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBankCode2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBankCode3);
    end;
  end;

  // Account Number
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFAccountNumber);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 22;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the account number';

    if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFAccountNumber2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFAccountNumber3);
    end;
  end;

  // Client Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFClientCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 8;
    PDFFormFieldItemEdit.Edit.CharCase := ecUpperCase;
    PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseTextKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the code your practice uses for this client';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFClientCode2);
  end;

  // Cost Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFCostCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 8;
    PDFFormFieldItemEdit.Edit.CharCase := ecUpperCase;
    PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseTextKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the cost code your practice uses for this client';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFCostCode2);
  end;

  // Bank Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
  shpNewBankDetails := nil;
  if Assigned(PDFFormFieldItemEdit) then
  begin
    case fInstitution of
      istUKNormal : begin
        // Clear out a section for the controls
        shpNewBankDetails := TShape.Create(nil);
        shpNewBankDetails.Parent := PdfFieldEdit;
        shpNewBankDetails.Pen.Color := $00FFFFFF;
        shpNewBankDetails.Top    := PDFFormFieldItemEdit.Edit.Top - 20;
        shpNewBankDetails.Left   := PDFFormFieldItemEdit.Edit.Left - 20;
        shpNewBankDetails.Height := PDFFormFieldItemEdit.Edit.Height + 60;
        shpNewBankDetails.Width  := 474;

        // New Drop down
        cmbBankName := TComboBox.Create(nil);
        cmbBankName.Parent := PdfFieldEdit;
        cmbBankName.Style := csDropDownList;
        cmbBankName.Top    := shpNewBankDetails.Top + 5;
        cmbBankName.Left   := shpNewBankDetails.Left + 5;
        cmbBankName.Height := 20;
        cmbBankName.ShowHint := true;
        cmbBankName.Hint := 'Select the name of the bank where the account is held';
        cmbBankName.OnChange := cmbBankNameChange;

        // Bank Name Label
        NewBankLabel := TLabel.Create(nil);
        NewBankLabel.Parent := PdfFieldEdit;
        NewBankLabel.Caption := '(Bank Name)';
        NewBankLabel.Top := shpNewBankDetails.Top + 27;
        NewBankLabel.Left := shpNewBankDetails.Left + 10;
        NewBankLabel.Font.Size := 7;
        NewBankLabel.Font.Color := $00444444;

        // Branch Name Label
        NewBankLabel := TLabel.Create(nil);
        NewBankLabel.Parent := PdfFieldEdit;
        NewBankLabel.Caption := '(Branch Name)';
        NewBankLabel.Top := shpNewBankDetails.Top + 59;
        NewBankLabel.Left := shpNewBankDetails.Left + 10;
        NewBankLabel.Font.Size := 7;
        NewBankLabel.Font.Color := $00444444;

        // Load the Institution Names
        cmbBankName.AddItem('Other', nil);
        for BankIndex := 0 to Institutions.Count-1 do
        begin
          if (TInstitutionItem(Institutions.Items[BankIndex]).CountryCode = COUNTRY_CODE) and
             (TInstitutionItem(Institutions.Items[BankIndex]).Code <> 'HSBC') then
            cmbBankName.AddItem(TInstitutionItem(Institutions.Items[BankIndex]).Name ,Institutions.Items[BankIndex]);
        end;
        cmbBankName.Width := SET_BANK_WIDTH;

        PDFFormFieldItemEdit.Edit.MaxLength := 60;
        PDFFormFieldItemEdit.Edit.ShowHint := true;
        PDFFormFieldItemEdit.Edit.Top   := shpNewBankDetails.Top + 5;
        PDFFormFieldItemEdit.Edit.Left  := shpNewBankDetails.Left + 139;
        PDFFormFieldItemEdit.Edit.Width := 322;
        PDFFormFieldItemEdit.Edit.Hint := 'Enter the name of the bank where the account is held';
        PDFFormFieldItemEdit.Edit.Enabled := false;
      end;
      istUKHSBC : begin
        PDFFormFieldItemEdit.Edit.Text := 'HSBC';
        PDFFormFieldItemEdit.Edit.Enabled := false;
        PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBankName2);
      end;
    end;
  end;

  // Branch Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBranchName);

  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 60;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the name of the branch where the account is held';

    if fInstitution = istUKHSBC then
    begin                        
      BankNameFieldItem := GetPDFFormFieldEdit(ukCAFBankName);

      PDFFormFieldItemEdit.Edit.Top   := BankNameFieldItem.Edit.Top;
      PDFFormFieldItemEdit.Edit.Left  := BankNameFieldItem.Edit.Left + BankNameFieldItem.Edit.Width + 15;

      PDFFormFieldItemEdit.Edit.Width := SET_BRANCH_WIDTH_HSBC;

      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBranchName2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBranchName3);
    end
    else
    begin
      ASSERT(Assigned(shpNewBankDetails));

      PDFFormFieldItemEdit.Edit.Top   := shpNewBankDetails.Top + 40;
      PDFFormFieldItemEdit.Edit.Left  := shpNewBankDetails.Left + 5;

      PDFFormFieldItemEdit.Edit.Width := SET_BANK_WIDTH;
    end;
  end;
  
  // Start Month
  PDFFormFieldItemComboBox := GetPDFFormFieldCombo(ukCAFStartMonth);
  if Assigned(PDFFormFieldItemComboBox) then
  begin
    PDFFormFieldItemComboBox.ComboBox.Clear;
    PDFFormFieldItemComboBox.ComboBox.AddItem('', nil);
    PDFFormFieldItemComboBox.ComboBox.AddItem('ASAP', nil);
    for MonthIndex := 1 to 12 do
      PDFFormFieldItemComboBox.ComboBox.AddItem(GetMonthName(MonthIndex), nil);
    PDFFormFieldItemComboBox.ComboBox.ItemIndex := 0;

    PDFFormFieldItemComboBox.OnChange := CAFStartMonthChange;
    PDFFormFieldItemComboBox.ComboBox.Style := csDropDownList;

    PDFFormFieldItemComboBox.ComboBox.ShowHint := true;
    PDFFormFieldItemComboBox.ComboBox.Hint := 'Enter the month in which you want to start collecting data';

    case fInstitution of
      istUKHSBC : begin
        PDFFormFieldItemComboBox.ComboBox.Left := PDFFormFieldItemComboBox.ComboBox.Left - 4;
        PDFFormFieldItemComboBox.ComboBox.Top  := PDFFormFieldItemComboBox.ComboBox.Top - 2;
        PDFFormFieldItemComboBox.AddLinkFieldByTitle(ukCAFStartMonth2);
      end;
    end;
  end;

  // Start Year
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCafStartYear);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 2;
    PDFFormFieldItemEdit.Edit.OnKeyPress := NumericKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the year in which you want to start collecting data';

    PDFFormFieldItemEdit.shpClear.Top    := PDFFormFieldItemEdit.Edit.Top - 7;
    PDFFormFieldItemEdit.shpClear.Height := PDFFormFieldItemEdit.Edit.Height + 14;
    PDFFormFieldItemEdit.shpClear.Left   := PDFFormFieldItemEdit.Edit.Left - 4;
    PDFFormFieldItemEdit.shpClear.Width  := PDFFormFieldItemEdit.Edit.Width + 8;

    PDFFormFieldItemEdit.Edit.Top    := PDFFormFieldItemEdit.Edit.Top + 1;
    PDFFormFieldItemEdit.Edit.Height := PDFFormFieldItemEdit.Edit.Height + 2;
    PDFFormFieldItemEdit.Edit.Left   := PDFFormFieldItemEdit.Edit.Left - 1;
    PDFFormFieldItemEdit.Edit.Width  := PDFFormFieldItemEdit.Edit.Width + 2;
    PDFFormFieldItemEdit.Edit.BorderStyle := bsSingle;

    PDFFormFieldItemEdit.shpClear.Brush.Color := clWhite;
    PDFFormFieldItemEdit.shpClear.Pen.Color   := clWhite;

    case fInstitution of
      istUKNormal : begin
        PDFFormFieldItemEdit.Edit.Width  := PDFFormFieldItemEdit.Edit.Width + 4;
      end;
      istUKHSBC : begin
        PDFFormFieldItemEdit.Edit.Left   := PDFFormFieldItemEdit.Edit.Left - 5;
        PDFFormFieldItemEdit.Edit.Top    := PDFFormFieldItemEdit.Edit.Top - 4;
        PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCafStartYear2);
      end;
    end;
  end;

  // Practice Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFPracticeName);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 60;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter your practice name';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFPracticeName2);

    // Default value
    PDFFormFieldItemEdit.Edit.Text := Adminsystem.fdFields.fdPractice_Name_for_Reports;
    PDFFormFieldItemEdit.Value := PDFFormFieldItemEdit.Edit.Text;
  end;

  // Practice Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFPracticeCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 8;
    PDFFormFieldItemEdit.Edit.CharCase := ecUpperCase;
    PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseTextKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter your practice code';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFPracticeCode2);

    // Default value
    PDFFormFieldItemEdit.Edit.Text := Adminsystem.fdFields.fdBankLink_Code;
    PDFFormFieldItemEdit.Value := PDFFormFieldItemEdit.Edit.Text;
  end;

  // Supply Provisional Accounts
  PDFFormFieldItemCheckBox := GetPDFFormFieldCheck(ukCAFSupplyProvisionalAccounts);
  if Assigned(PDFFormFieldItemCheckBox) then
  begin
    PDFFormFieldItemCheckBox.Checkbox.ShowHint := true;
    PDFFormFieldItemCheckBox.Checkbox.Hint := 'Supply Provisional Accounts';
    PDFFormFieldItemCheckBox.ShpClear.Width := PDFFormFieldItemCheckBox.ShpClear.Width + 615;
    PDFFormFieldItemCheckBox.Checkbox.Width := PDFFormFieldItemCheckBox.Checkbox.Width + 600;
    PDFFormFieldItemCheckBox.Checkbox.Caption :=
      'Please supply the account(s) above as a Provisional Account(s) if they are not available from the Bank';

    if fInstitution = istUKNormal then
      PDFFormFieldItemCheckBox.Checkbox.Font.Size := PDFFormFieldItemCheckBox.Checkbox.Font.Size - 1
    else if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemCheckBox.Checkbox.Font.Size := PDFFormFieldItemCheckBox.Checkbox.Font.Size + 1;
      PDFFormFieldItemCheckBox.AddLinkFieldByTitle(ukCAFSupplyProvisionalAccounts2);
    end;
  end;

  // Daily
  SetRadioValues(true, false, false);
  PDFFormFieldItemRadioButton := GetPDFFormFieldRadio(ukCAFDaily);
  if Assigned(PDFFormFieldItemRadioButton) then
  begin
    RadButtonTop := PDFFormFieldItemRadioButton.RadioButton.Top;
    PDFFormFieldItemRadioButton.RadioButton.OnClick := RadDailyOnClick;
    PDFFormFieldItemRadioButton.RadioButton.ShowHint := true;
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Monthly, Weekly or Daily for the data frequency on this account';
    PDFFormFieldItemRadioButton.ShpClear.Width := PDFFormFieldItemRadioButton.ShpClear.Width + 140;
    PDFFormFieldItemRadioButton.RadioButton.Width := PDFFormFieldItemRadioButton.RadioButton.Width + 125;
    PDFFormFieldItemRadioButton.RadioButton.Caption := 'Daily (where available)';

    if fInstitution = istUKNormal then
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size - 1
    else if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size + 1;
      PDFFormFieldItemRadioButton.RadioButton.Top := PDFFormFieldItemRadioButton.RadioButton.Top + 2;
      PDFFormFieldItemRadioButton.AddLinkFieldByTitle(ukCAFDaily2);
    end;
  end;

  // Weekly
  PDFFormFieldItemRadioButton := GetPDFFormFieldRadio(ukCAFWeekly);
  if Assigned(PDFFormFieldItemRadioButton) then
  begin
    PDFFormFieldItemRadioButton.RadioButton.Top := RadButtonTop;
    PDFFormFieldItemRadioButton.RadioButton.OnClick := RadWeeklyOnClick;
    PDFFormFieldItemRadioButton.RadioButton.ShowHint := true;
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Monthly, Weekly or Daily for the data frequency on this account';
    PDFFormFieldItemRadioButton.ShpClear.Width := PDFFormFieldItemRadioButton.ShpClear.Width + 170;
    PDFFormFieldItemRadioButton.RadioButton.Width := PDFFormFieldItemRadioButton.RadioButton.Width + 150;
    PDFFormFieldItemRadioButton.RadioButton.Caption := 'Weekly (where available)';

    if fInstitution = istUKNormal then
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size - 1
    else if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size + 1;
      PDFFormFieldItemRadioButton.RadioButton.Top := PDFFormFieldItemRadioButton.RadioButton.Top + 2;
      PDFFormFieldItemRadioButton.AddLinkFieldByTitle(ukCAFWeekly2);
    end;
  end;

  // Monthly
  PDFFormFieldItemRadioButton := GetPDFFormFieldRadio(ukCAFMonthly);
  if Assigned(PDFFormFieldItemRadioButton) then
  begin
    PDFFormFieldItemRadioButton.RadioButton.Top := RadButtonTop;
    PDFFormFieldItemRadioButton.RadioButton.OnClick := RadMonthlyOnClick;
    PDFFormFieldItemRadioButton.RadioButton.ShowHint := true;
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Monthly, Weekly or Daily for the data frequency on this account';
    PDFFormFieldItemRadioButton.ShpClear.Width := PDFFormFieldItemRadioButton.ShpClear.Width + 140;
    PDFFormFieldItemRadioButton.RadioButton.Width := PDFFormFieldItemRadioButton.RadioButton.Width + 125;
    PDFFormFieldItemRadioButton.RadioButton.Caption := 'Monthly';

    if fInstitution = istUKNormal then
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size - 1
    else if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemRadioButton.RadioButton.Font.Size := PDFFormFieldItemRadioButton.RadioButton.Font.Size + 1;
      PDFFormFieldItemRadioButton.RadioButton.Top := PDFFormFieldItemRadioButton.RadioButton.Top + 2;
      PDFFormFieldItemRadioButton.AddLinkFieldByTitle(ukCAFMonthly2);
    end;
  end;

  // Bank Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    case fInstitution of
      istUKNormal : begin
        PDFFormFieldItemEdit.Edit.MaxLength := 60;
        PDFFormFieldItemEdit.Edit.ShowHint := true;
        PDFFormFieldItemEdit.Edit.Hint := 'Enter the name of the bank and branch where the account is held';
      end;
      istUKHSBC : begin
        PDFFormFieldItemEdit.Edit.Text := 'HSBC';
        PDFFormFieldItemEdit.Edit.Enabled := false;
        PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBankName2);
      end;
    end;
  end;

  if fInstitution = istUKHSBC then
  begin
    // Account Signatory 1
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign1);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.Edit.CharCase := ecUpperCase;
      PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseOnlyTextKeyPress;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign1_2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign1_3);
    end;

    // Account Signatory 2
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign2);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.Edit.CharCase := ecUpperCase;
      PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseOnlyTextKeyPress;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign2_2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign2_3);
    end;

    // Address Line 1
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine1);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine1_2);
    end;

    // Address Line 2
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine2);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine2_2);
    end;

    // Address Line 3
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine3);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine3_2);
    end;

    // Address Line 4
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine4);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 60;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine4_2);
    end;

    // Postal Code
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCPostalCode);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.Edit.MaxLength := 8;
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCPostalCode2);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCaf.SetFocusForPDFControl;
var
  PDFFormFieldItemEdit : TPDFFormFieldItemEdit;
begin
  // Name of Account
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFNameOfAccount);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.SetFocus;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SetRadioValues(aDaily, aWeekly, aMonthly: boolean);
var
  RadDaily : TPDFFormFieldItemRadioButton;
  RadWeekly : TPDFFormFieldItemRadioButton;
  RadMonthly : TPDFFormFieldItemRadioButton;

  //----------------------------------------------------------------------------
  procedure SetRadValue(aField : TPDFFormFieldItemRadioButton; aValue : boolean);
  begin
    if aValue then
      aField.Value := 'Yes'
    else
      aField.Value := 'Off';
  end;
begin
  RadDaily := GetPDFFormFieldRadio(ukCAFDaily);
  if Assigned(RadDaily) then
    SetRadValue(RadDaily, aDaily);

  RadWeekly := GetPDFFormFieldRadio(ukCAFWeekly);
  if Assigned(RadWeekly) then
    SetRadValue(RadWeekly, aWeekly);

  RadMonthly := GetPDFFormFieldRadio(ukCAFMonthly);
  if Assigned(RadMonthly) then
    SetRadValue(RadMonthly, aMonthly);
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.RadDailyOnClick(Sender: TObject);
begin
  SetRadioValues(true, false, false);
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.RadWeeklyOnClick(Sender: TObject);
begin
  SetRadioValues(false, true, false);
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.RadMonthlyOnClick(Sender: TObject);
begin
  SetRadioValues(false, false, true);
end;

//------------------------------------------------------------------------------
procedure TfrmNewCaf.ResetFields;
var
  PDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;
  PDFFormFieldItemRadioButton : TPDFFormFieldItemRadioButton;
  PDFFormFieldItemCheckBox    : TPDFFormFieldItemCheckBox;
begin
  // Name of Account
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFNameOfAccount);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Bank Code / Sort Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Account Number
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFAccountNumber);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Client Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFClientCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Cost Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFCostCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Branch Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBranchName);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Value := '';
  end;

  // Start Month
  PDFFormFieldItemComboBox := GetPDFFormFieldCombo(ukCAFStartMonth);
  if Assigned(PDFFormFieldItemComboBox) then
  begin
    PDFFormFieldItemComboBox.ComboBox.ItemIndex := 0;
    PDFFormFieldItemComboBox.Value := '';
  end;

  // Start Year
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCafStartYear);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.Text := '';
    PDFFormFieldItemEdit.Edit.enabled := true;
  end;

  // Supply Provisional Accounts
  PDFFormFieldItemCheckBox := GetPDFFormFieldCheck(ukCAFSupplyProvisionalAccounts);
  if Assigned(PDFFormFieldItemCheckBox) then
    PDFFormFieldItemCheckBox.Checkbox.Checked := false;

  // Daily
  PDFFormFieldItemRadioButton := GetPDFFormFieldRadio(ukCAFDaily);
  if Assigned(PDFFormFieldItemRadioButton) then
    PDFFormFieldItemRadioButton.RadioButton.Checked := True;

  // Practice Name - don't reset this

  // Practice Code - don't reset this

  case fInstitution of
    istUKNormal : begin
      // Bank Name
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
        PDFFormFieldItemEdit.Edit.Enabled := false;
        cmbBankName.ItemIndex := -1;
        cmbBankName.Width := SET_BANK_WIDTH;
      end;
    end;
    istUKHSBC : begin
      // Account Signatory 1
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign1);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Account Signatory 2
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign2);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Address Line 1
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine1);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Address Line 2
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine2);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Address Line 3
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine3);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Address Line 4
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine4);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;

      // Postal Code
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCPostalCode);
      if Assigned(PDFFormFieldItemEdit) then
      begin
        PDFFormFieldItemEdit.Edit.Text := '';
        PDFFormFieldItemEdit.Value := '';
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SaveToFile;
var
  ReportFile, Title, Description, MsgStr: string;
  WebID, CatID, pdfInt: integer;
begin
  ReportFile := TProduct.BrandName + ' Customer Authority.PDF';
  
  pdfInt := rfPDF;
  Title := 'Save Report To File';
  Description := '';
  if GenerateReportTo(ReportFile, pdfInt, [ffPDF], Title, Description, WebID, CatID, True) then
  begin
    try
      PdfFieldEdit.SaveToFileFlattened(ReportFile);

      MsgStr := Format('Report saved to "%s".%s%sDo you want to view it now?',
                    [ReportFile, #13#10, #13#10]); // Need to pass the path of the PDF to this function

      if (AskYesNo(RptFileFormat.Names[rfPDF], MsgStr, DLG_YES, 0) = DLG_YES) then
        ShellExecute(0, 'open', PChar(ReportFile), nil, nil, SW_SHOWMAXIMIZED);
    except
      HelpfulErrorMsg('Error Saving ' + TProduct.BrandName + ' Customer Authority Form to - ' + ReportFile, 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SendPDFViaEmail;
var
  AttachmentSent: Boolean;
  ReportFile : string;
  FileCount: Integer;
begin
  AttachmentSent := True;

  try
    if not DirectoryExists(EmailOutboxDir) then
    begin
      if not CreateDir(PChar(EmailOutboxDir)) then
      begin
        HelpfulErrorMsg(Format('The email outbox directory %s does not exist and could not be created.', [EmailOutboxDir]), 0);

        Exit;
      end;
    end;

    ReportFile := Format('%sBankLink Customer Authority.PDF', [EmailOutboxDir]);

    FileCount := 1;

    while FileExists(ReportFile) do
    begin
      ReportFile := Format('%sBankLink Customer Authority (%s).PDF', [EmailOutboxDir, IntToStr(FileCount)]);

      Inc(FileCount);
    end;

    PdfFieldEdit.SaveToFileFlattened(ReportFile);
    try
      // TODO: Need to attach the third party authority PDF (see SendFileTo parameters in MailFrm)
      MailFrm.SendFileTo('Send Customer Authority Form', ClientEmail, '', ReportFile, AttachmentSent, False);
    finally
      SysUtils.DeleteFile(ReportFile);
    end;
  except
    HelpfulErrorMsg('Error Sending ' + TProduct.BrandName + ' Customer Authority Form via Email.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.PrintPDF;
var
  ReportFile : string;
  Guid : TGuid;
begin
  CreateGuid(Guid);
  ReportFile := DataDir + TProduct.BrandName + ' Customer Authority' + GUIDToString(Guid) + '.PDF';

  try
    PdfFieldEdit.SaveToFileFlattened(ReportFile);

    PrintDialog.MinPage  := 1;
    PrintDialog.MaxPage  := PdfFieldEdit.PageCount;
    PrintDialog.FromPage := 1;
    PrintDialog.ToPage   := PdfFieldEdit.PageCount;
    if PrintDialog.Execute then
    begin
      PdfFieldEdit.Print(ReportFile,
                         Printer.Printers[Printer.PrinterIndex],
                         PrintDialog.FromPage,
                         PrintDialog.ToPage,
                         PdfFieldEdit.PrintOptions(0, 1, bkBranding.PracticeProductName));
    end;
  except
    HelpfulErrorMsg('Error Printing ' + TProduct.BrandName + ' Customer Authority Form.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SetClientEmail(value: string);
begin
  FClientEmail := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.UpperCaseOnlyTextKeyPress(Sender: TObject; var Key: Char);
begin
  Key := UpCase(Key);
end;

procedure TfrmNewCAF.UpperCaseTextKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['a'..'z','A'..'Z','0'..'9',Chr(vk_Back)]) then
    Key := #0 // Discard the key
  else
    Key := UpCase(Key); // Upper case
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.NumericDashKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','-',Chr(vk_Back),Chr(vk_space)]) then
    Key := #0; // Discard the key
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.NumericKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',Chr(vk_Back)]) then
    Key := #0; // Discard the key
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnEmailClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    CreateQRCode;
    SendPDFViaEmail;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    CreateQRCode;
    SaveToFile;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    CreateQRCode;
    PrintPDF;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnResetFormClick(Sender: TObject);
begin
  ResetFields;
  CreateQRCode;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.CAFStartMonthChange(Sender: TObject);
var
  PDFFormFieldItemEdit : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox : TPDFFormFieldItemComboBox;
begin
  PDFFormFieldItemComboBox := GetPDFFormFieldCombo(ukCAFStartMonth);
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCafStartYear);

  if ((Assigned(PDFFormFieldItemEdit)) and
      (Assigned(PDFFormFieldItemComboBox))) then
  begin
    PDFFormFieldItemEdit.Edit.Enabled := not (PDFFormFieldItemComboBox.ComboBox.ItemIndex = 1);
    if not PDFFormFieldItemEdit.Edit.Enabled then
    begin
      PDFFormFieldItemEdit.Edit.text := '';
      PDFFormFieldItemEdit.Value := '';
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.CreateQRCode;
const
  QR_CODE_SIZE = 100;
  STANDARD_XPOS = 645;
  STANDARD_YPOS = 760;
   {$IFNDEF PRACTICE-7}
var

  CafQrCode  : TCafQrCode;
  CAFQRData  : TCAFQRData;
  CAFQRDataAccount : TCAFQRDataAccount;
  QrCodeImage : TImage;
  InstIndex : integer;
   {$ENDIF }
begin
  {$IFNDEF PRACTICE-7}
  if (Assigned(cmbBankName)) and
     (cmbBankName.ItemIndex < 1) then
    Exit;

  CAFQRData := TCAFQRData.Create(TCAFQRDataAccount);
  CafQrCode := TCafQrCode.Create;
  QrCodeImage := TImage.Create(nil);
  try
    // Day , Month , Year
    CAFQRData.SetStartDate(1,
                           GetPDFFormFieldCombo(ukCAFStartMonth).ComboBox.ItemIndex,
                           '20' + GetPDFFormFieldEdit(ukCAFStartYear).Edit.Text);

    CAFQRData.PracticeCode        := GetPDFFormFieldEdit(ukCAFPracticeCode).Value;
    CAFQRData.PracticeCountryCode := CountryText(AdminSystem.fdFields.fdCountry);

    CAFQRData.SetProvisional(GetPDFFormFieldCheck(ukCAFSupplyProvisionalAccounts).CheckBox.Checked);

    CAFQRData.SetFrequency(GetPDFFormFieldRadio(ukCAFMonthly).RadioButton.Checked,
                           GetPDFFormFieldRadio(ukCAFWeekly).RadioButton.Checked,
                           GetPDFFormFieldRadio(ukCAFDaily).RadioButton.Checked,
                           2);

    CAFQRData.TimeStamp := Now;

    if fInstitution = istUKHSBC then
    begin
      CAFQRData.InstitutionCode := 'HSBC';
      CAFQRData.InstitutionCountry := COUNTRY_CODE;
    end
    else
    begin
      InstIndex := cmbBankName.ItemIndex;
      CAFQRData.InstitutionCode := TInstitutionItem(cmbBankName.Items.Objects[InstIndex]).Code;
      CAFQRData.InstitutionCountry := TInstitutionItem(cmbBankName.Items.Objects[InstIndex]).CountryCode;
    end;

    CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
    CAFQRDataAccount.AccountName   := GetPDFFormFieldEdit(ukCAFNameOfAccount).Value;
    CAFQRDataAccount.AccountNumber := GetPDFFormFieldEdit(ukCAFBankCode).Value +
                                      GetPDFFormFieldEdit(ukCAFAccountNumber).Value;
    CAFQRDataAccount.ClientCode    := GetPDFFormFieldEdit(ukCAFClientCode).Value;
    CAFQRDataAccount.CostCode      := GetPDFFormFieldEdit(ukCAFCostCode).Value;
    CAFQRDataAccount.SMSF          := 'N'; // AU only

    CafQrCode.BuildQRCode(CAFQRData,
                          GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CAF_QRCODE,
                          QrCodeImage);

    PdfFieldEdit.SetQRCodeImage(QrCodeImage.Picture.Bitmap);

    if fInstitution = istUKHSBC then
      PdfFieldEdit.DrawQRCode(STANDARD_XPOS, STANDARD_YPOS, QR_CODE_SIZE, QR_CODE_SIZE, 2)
    else
      PdfFieldEdit.DrawQRCode(STANDARD_XPOS, STANDARD_YPOS, QR_CODE_SIZE, QR_CODE_SIZE, 1);

  finally
    FreeAndNil(QrCodeImage);
    FreeAndNil(CafQrCode);
    FreeAndNil(CAFQRData);
  end;
   {$ENDIF}
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.FormCreate(Sender: TObject);
begin
  Height := Application.MainForm.ClientHeight;
  Top    := Application.MainForm.top;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_ESCAPE) then
    btnCancel.Click;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.FormShow(Sender: TObject);
begin
  SetFocusForPDFControl;
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.ValidateForm: Boolean;
var
  PDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;

  procedure ValidateEmptyEditField(aFieldName : widestring; aMessage : string);
  begin
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(aFieldName);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      if trim(PDFFormFieldItemEdit.Edit.Text) = '' then
      begin
        Result := false;
        HelpfulErrorMsg(aMessage, 0);
        PDFFormFieldItemEdit.Edit.SetFocus;
      end;
    end;
  end;
begin
  Result := True;

  // Practice Name
  ValidateEmptyEditField(ukCAFPracticeName, 'You must enter a practice name.');
  if not Result then
    Exit;

  // Practice Code
  ValidateEmptyEditField(ukCAFPracticeCode, 'You must enter a practice code.');
  if not Result then
    Exit;

  // Start year and month
  PDFFormFieldItemComboBox := GetPDFFormFieldCombo(ukCAFStartMonth);
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCafStartYear);

  if Assigned(PDFFormFieldItemComboBox) and
     Assigned(PDFFormFieldItemEdit) then
  begin
    if (PDFFormFieldItemComboBox.ComboBox.ItemIndex = 0) and
       (PDFFormFieldItemEdit.Edit.Text <> '') then
    begin
      Result := false;
      HelpfulErrorMsg('You must choose a starting month.', 0);
      PDFFormFieldItemComboBox.ComboBox.SetFocus;
      Exit;
    end;

    if (PDFFormFieldItemComboBox.ComboBox.ItemIndex > 1) and
       (PDFFormFieldItemEdit.Edit.Text = '') then
    begin
      Result := false;
      HelpfulErrorMsg('You must enter a valid starting year.', 0);
      PDFFormFieldItemEdit.Edit.SetFocus;
      Exit;
    end;
  end;

  // Institution Name
  if Assigned(cmbBankName) then
  begin
    if Result and (cmbBankName.ItemIndex = -1) then
    begin
      HelpfulErrorMsg('You must choose a Bank Name.', 0);
      cmbBankName.SetFocus;
      Result := False;
    end;

    // Institution Other Name
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      if Result and (cmbBankName.ItemIndex = 0) and (PDFFormFieldItemEdit.edit.text = '') then
      begin
        HelpfulErrorMsg('You must enter a Bank Name.', 0);
        PDFFormFieldItemEdit.edit.SetFocus;
        Result := False;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  Message.MinMaxInfo^.ptMinTrackSize.X := 457;           {Minimum width}

  Message.Result := 0;                 {Tell windows you have changed minmaxinfo}
  inherited;
end;

end.
