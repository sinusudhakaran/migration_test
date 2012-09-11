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

    procedure UpperCaseTextKeyPress(Sender: TObject; var Key: Char);
    procedure NumericDashKeyPress(Sender: TObject; var Key: Char);
    procedure NumericKeyPress(Sender: TObject; var Key: Char);

    procedure CostCodeChange(Sender: TObject);
    procedure WMGetMinMaxInfo( var Message :TWMGetMinMaxInfo ); message WM_GETMINMAXINFO;
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
  ShellAPI;

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
    //Todo  //BKHelpSetUp(frmNewCAF, ----);

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

  PDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;
  PDFFormFieldItemRadioButton : TPDFFormFieldItemRadioButton;
  PDFFormFieldItemCheckBox    : TPDFFormFieldItemCheckBox;
begin
  Result := false;

  if not DirectoryExists( GLOBALS.TemplateDir ) then
  begin
    HelpfulErrorMsg('Can''t find Templates Direcotry - ' + GLOBALS.TemplateDir, 0);
    Exit;
  end;

  PDFFilePath := GLOBALS.TemplateDir + istUKTemplateFileNames[fInstitution];

  if not FileExists( PDFFilePath ) then
  begin
    HelpfulErrorMsg('Can''t find Template - ' + PDFFilePath, 0);
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
end;

//------------------------------------------------------------------------------
procedure TfrmNewCaf.InitFields;
var
  MonthIndex : integer;
  RadButtonTop : integer;

  PDFFormFieldItemEdit        : TPDFFormFieldItemEdit;
  PDFFormFieldItemComboBox    : TPDFFormFieldItemComboBox;
  PDFFormFieldItemRadioButton : TPDFFormFieldItemRadioButton;
  PDFFormFieldItemCheckBox    : TPDFFormFieldItemCheckBox;
begin
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
    PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseTextKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the cost code your practice uses for this client';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFCostCode2);
  end;

  // Branch Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBranchName);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 60;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the name of the bank and branch where the account is held';

    if fInstitution = istUKHSBC then
    begin
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBranchName2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFBranchName3);
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

    PDFFormFieldItemComboBox.ComboBox.OnChange := CostCodeChange;
    PDFFormFieldItemComboBox.ComboBox.Style := csDropDownList;

    PDFFormFieldItemComboBox.ComboBox.ShowHint := true;
    PDFFormFieldItemComboBox.ComboBox.Hint := 'Enter the year in which you want to start collecting data';

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
    PDFFormFieldItemEdit.Edit.Hint := 'Enter the month in which you want to start collecting data';

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
    PDFFormFieldItemEdit.Edit.MaxLength := 80;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter your practice name';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFPracticeName2);
  end;

  // Practice Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFPracticeCode);
  if Assigned(PDFFormFieldItemEdit) then
  begin
    PDFFormFieldItemEdit.Edit.MaxLength := 8;
    PDFFormFieldItemEdit.Edit.OnKeyPress := UpperCaseTextKeyPress;
    PDFFormFieldItemEdit.Edit.ShowHint := true;
    PDFFormFieldItemEdit.Edit.Hint := 'Enter your practice code';

    if fInstitution = istUKHSBC then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFPracticeCode2);
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
      'Please supply the account above as a Provisional Account if it is not available from the Bank';

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
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Daily, Weekly or Monthly for the data frequency on this account';
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
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Daily, Weekly or Monthly for the data frequency on this account';
    PDFFormFieldItemRadioButton.ShpClear.Width := PDFFormFieldItemRadioButton.ShpClear.Width + 170;
    PDFFormFieldItemRadioButton.RadioButton.Width := PDFFormFieldItemRadioButton.RadioButton.Width + 125;
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
    PDFFormFieldItemRadioButton.RadioButton.Hint := 'Select Daily, Weekly or Monthly for the data frequency on this account';
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
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign1_2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign1_3);
    end;

    // Account Signatory 2
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign2);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign2_2);
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAccountSign2_3);
    end;

    // Address Line 1
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine1);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine1_2);

    // Address Line 2
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine2);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine2_2);

    // Address Line 3
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine3);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine3_2);

    // Address Line 4
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine4);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCAddressLine4_2);

    // Postal Code
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCPostalCode);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.AddLinkFieldByTitle(ukCAFHSBCPostalCode2);
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
    PDFFormFieldItemEdit.Edit.Text := '';

  // Bank Code / Sort Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankCode);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := '';

  // Account Number
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFAccountNumber);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := '';

  // Client Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFClientCode);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := '';

  // Cost Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFCostCode);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := '';

  // Branch Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBranchName);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := '';

  // Cost Code
  PDFFormFieldItemComboBox := GetPDFFormFieldCombo(ukCAFStartMonth);
  if Assigned(PDFFormFieldItemComboBox) then
    PDFFormFieldItemComboBox.ComboBox.ItemIndex := 0;

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

  // Practice Code
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFPracticeCode);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := Adminsystem.fdFields.fdBankLink_Code;

  // Practice Name
  PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFPracticeName);
  if Assigned(PDFFormFieldItemEdit) then
    PDFFormFieldItemEdit.Edit.Text := Adminsystem.fdFields.fdPractice_Name_for_Reports;

  case fInstitution of
    istUKNormal : begin
      // Bank Name
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';
    end;
    istUKHSBC : begin
      // Account Signatory 1
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign1);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Account Signatory 2
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAccountSign2);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Address Line 1
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine1);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Address Line 2
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine2);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Address Line 3
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine3);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Address Line 4
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCAddressLine4);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';

      // Postal Code
      PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFHSBCPostalCode);
      if Assigned(PDFFormFieldItemEdit) then
        PDFFormFieldItemEdit.Edit.Text := '';
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SaveToFile;
var
  ReportFile, Title, Description, MsgStr: string;
  WebID, CatID, pdfInt: integer;
begin
  ReportFile := 'BankLink Customer Authority.PDF';
  pdfInt := rfPDF;
  Title := 'Save Report To File';
  Description := '';
  if GenerateReportTo(ReportFile, pdfInt, [ffPDF], Title, Description, WebID, CatID, True) then
  begin
    try
      PdfFieldEdit.SaveToFileFlattened(ReportFile);

      MsgStr := Format('Report saved to "%s".%s%sDo you want to view it now?',
                    [ReportFile, #13#10, #13#10]); // Need to pass the path of the PDF to this function

      if (AskYesNo(rfNames[rfPDF], MsgStr, DLG_YES, 0) = DLG_YES) then
        ShellExecute(0, 'open', PChar(ReportFile), nil, nil, SW_SHOWMAXIMIZED);
    except
      HelpfulErrorMsg('Error Saving BankLink Customer Authority Form to - ' + ReportFile, 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SendPDFViaEmail;
var
  AttachmentSent: Boolean;
  ReportFile : string;
  Guid : TGuid;
begin
  AttachmentSent := True;

  try
    CreateGuid(Guid);
    ReportFile := DataDir + 'BankLink Customer Authority' + GUIDToString(Guid) + '.PDF';
    PdfFieldEdit.SaveToFileFlattened(ReportFile);
    try
      // TODO: Need to attach the third party authority PDF (see SendFileTo parameters in MailFrm)
      if MailFrm.SendFileTo('Send Customer Authority Form', ClientEmail, '', ReportFile, AttachmentSent, False) then
      begin
        HelpfulInfoMsg('Mail has been sent.', 0);
      end;
    finally
      SysUtils.DeleteFile(ReportFile);
    end;
  except
    HelpfulErrorMsg('Error Sending BankLink Customer Authority Form via Email.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.PrintPDF;
var
  ReportFile : string;
  Guid : TGuid;
begin
  CreateGuid(Guid);
  ReportFile := DataDir + 'BankLink Customer Authority' + GUIDToString(Guid) + '.PDF';

  try
    PdfFieldEdit.SaveToFileFlattened(ReportFile);

    PrintDialog.MinPage := 1;
    PrintDialog.MaxPage := PdfFieldEdit.PageCount;
    PrintDialog.FromPage := 1;
    PrintDialog.ToPage := PdfFieldEdit.PageCount;
    if PrintDialog.Execute then
    begin
      PdfFieldEdit.Print(ReportFile,
                         Printer.Printers[Printer.PrinterIndex],
                         PrintDialog.FromPage,
                         PrintDialog.ToPage,
                         PdfFieldEdit.PrintOptions(0, 1, 'BankLink Practice'));
    end;
  except
    HelpfulErrorMsg('Error Printing BankLink Customer Authority Form.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.SetClientEmail(value: string);
begin
  FClientEmail := Value;
end;

//------------------------------------------------------------------------------
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
  if not (Key in ['0'..'9','-',Chr(vk_Back)]) then
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
    SendPDFViaEmail;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnFileClick(Sender: TObject);
begin
  if ValidateForm then
    SaveToFile;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnPrintClick(Sender: TObject);
begin
  if ValidateForm then
    PrintPDF;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnResetFormClick(Sender: TObject);
begin
  ResetFields;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.CostCodeChange(Sender: TObject);
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
  end;
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
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.WMGetMinMaxInfo(var Message: TWMGetMinMaxInfo);
begin
  Message.MinMaxInfo^.ptMinTrackSize.X := 457;           {Minimum width}

  Message.Result := 0;                 {Tell windows you have changed minmaxinfo}
  inherited;
end;

end.
