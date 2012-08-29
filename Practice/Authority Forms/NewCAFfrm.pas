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
    procedure edtClientCodeKeyPress(Sender: TObject; var Key: Char);
    procedure edtServiceStartYearKeyPress(Sender: TObject; var Key: Char);
    procedure edtCostCodeKeyPress(Sender: TObject; var Key: Char);
    procedure cmbServiceStartMonthChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnFileClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnResetFormClick(Sender: TObject);
    procedure edtAccountNumberKeyPress(Sender: TObject; var Key: Char);
  private
    FButton: Byte;
    FClientEmail: string;

  protected
    procedure SetClientEmail(value: string);

    procedure UpperCaseTextKeyPress(Sender: TObject; var Key: Char);
    procedure NumericDashKeyPress(Sender: TObject; var Key: Char);
    procedure NumericKeyPress(Sender: TObject; var Key: Char);

    function ValidateForm: Boolean;

    function GetPDFFormFieldEdit(aTitle : WideString) : TPDFFormFieldItemEdit;
    function InitPDF(aCountry, aInstitution : integer) : boolean;
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
  MailFrm;

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
    frmNewCAF.PopupMode := pmExplicit;
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

  if not (aCountry = whUK) then
    Exit;

  if aInstitution = istUKNone then
    Exit;

  if not InitPDF(aCountry, aInstitution) then
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
function TfrmNewCAF.InitPDF(aCountry, aInstitution: integer): boolean;
var
  PDFFilePath : Widestring;
  PDFFormFieldItemEdit : TPDFFormFieldItemEdit;
begin
  Result := false;

  if not DirectoryExists( GLOBALS.TemplateDir ) then
  begin
    HelpfulErrorMsg('Can''t find Templates Direcotry - ' + GLOBALS.TemplateDir, 0);
    Exit;
  end;

  PDFFilePath := GLOBALS.TemplateDir + istUKTemplateFileNames[aInstitution];

  if not FileExists( PDFFilePath ) then
  begin
    HelpfulErrorMsg('Can''t find Template - ' + PDFFilePath, 0);
    Exit;
  end;

  try
    PdfFieldEdit.PDFFilePath := PDFFilePath;
    PdfFieldEdit.Zoom := 3;
    PdfFieldEdit.Active := true;

    {ukCAFNameOfAccount = 'NameOfAccount';
   ukCAFClientCode    = 'ClientCode';
   ukCAFBankCode      = 'BankCode';
   ukCAFAccountNumber = 'AccountNumber';
   ukCAFCostCode      = 'CostCode';
   ukCAFBankName      = 'BankName';
   ukCAFBranchName    = 'BranchName';
   ukCAFStartMonth    = 'cmbStartMonth';
   ukCAFStartYear     = 'StartYear';
   ukCAFPracticeName  = 'PracticeName';
   ukCAFPracticeCode  = 'PracticeCode';
   ukCAFSupplyProvisionalAccounts = 'chkSupplyProvisionalAccounts';
   ukCAFMonthly       = 'radMonthly';
   ukCAFWeekly        = 'radWeekly';
   ukCAFDaily         = 'radDaily';
   ukCAFAccountSign1  = 'AccountSignatory1';
   ukCAFAccountSign1  = 'AccountSignatory2';
   ukCAFAddressLine1  = 'AddressLine1';
   ukCAFAddressLine2  = 'AddressLine2';
   ukCAFAddressLine3  = 'AddressLine3';
   ukCAFAddressLine4  = 'AddressLine4';
   ukCAFPostalCode    = 'PostalCode';}

    // Name of Account
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFNameOfAccount);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.MaxLength := 60;

    // Client Code
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFClientCode);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.MaxLength := 8;
      PDFFormFieldItemEdit.OnKeyPressed := UpperCaseTextKeyPress;
    end;

    // Bank Code
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankCode);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.MaxLength := 8;
      PDFFormFieldItemEdit.OnKeyPressed := NumericDashKeyPress;
    end;

    // Account Number
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFAccountNumber);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.MaxLength := 22;

    // Cost Code
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFCostCode);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.MaxLength := 8;
      PDFFormFieldItemEdit.OnKeyPressed := UpperCaseTextKeyPress;
    end;

    // Bank Name
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBankName);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.MaxLength := 60;

    // Branch Name
    PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCAFBranchName);
    if Assigned(PDFFormFieldItemEdit) then
      PDFFormFieldItemEdit.MaxLength := 60;

    // Start Year
    {PDFFormFieldItemEdit := GetPDFFormFieldEdit(ukCafStartYear);
    if Assigned(PDFFormFieldItemEdit) then
    begin
      PDFFormFieldItemEdit.MaxLength := 2;
      PDFFormFieldItemEdit.OnKeyPressed := NumericKeyPress;
    end; }

    Result := True;
  except
    on E : Exception do
      HelpfulErrorMsg('Error loading Customer Authority form - ' +  e.Message , 0);
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
var
  AttachmentSent: Boolean;
begin
  if ValidateForm then
  begin
    AttachmentSent := True;
    // TODO: Need to attach the third party authority PDF (see SendFileTo parameters in MailFrm)
    try
      MailFrm.SendFileTo('Send Customer Authority Form', ClientEmail, '', '', AttachmentSent, False);
    finally
      HelpfulInfoMsg('Mail has been sent.', 0);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnFileClick(Sender: TObject);
var
  ReportFile, Title, Description, MsgStr: string;
  WebID, CatID, pdfInt: integer;
begin
//  if ValidateForm then
// TODO: generate the report.
  ReportFile := 'BankLink Customer Authority.PDF';
  pdfInt := rfPDF;
  Title := 'Save Report To File';
  Description := '';
  {if GenerateReportTo(ReportFile, pdfInt, [ffPDF], Title, Description, WebID, CatID, True) then
  begin
    MsgStr := Format('Report saved to "%s".%s%sDo you want to view it now?',
                    [ReportFile, #13#10, #13#10]); // Need to pass the path of the PDF to this function
    if (AskYesNo(rfNames[rfPDF], MsgStr, DLG_YES, 0) = DLG_YES) then
      ShellExecute(0, 'open', PChar(ReportFile), nil, nil, SW_SHOWMAXIMIZED);
  end; }
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnPrintClick(Sender: TObject);
begin
//  if ValidateForm then
// TODO: Print
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.btnResetFormClick(Sender: TObject);
begin
  {edtAccountName.Text := '';
  edtSortCode.Text := '';
  edtAccountNumber.Text := '';
  edtClientCode.Text := '';
  edtCostCode.Text := '';
  if edtBank.Enabled then // We don't want to clear this field if this is an HSBC CAF
    edtBank.Text := '';
  edtBranch.Text := '';
  cmbServiceStartMonth.ItemIndex := -1;
  edtServiceStartYear.Text := '';
  chkSupplyAccount.Checked := False;
  rbDaily.Checked := True;}
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.cmbServiceStartMonthChange(Sender: TObject);
begin
  //edtServiceStartYear.Enabled := (cmbServiceStartMonth.Text <> 'ASAP');
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.edtAccountNumberKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','-',Chr(vk_Back)]) then
    Key := #0; // Discard the key
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.edtClientCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['a'..'z','A'..'Z','0'..'9',Chr(vk_Back)]) then
    Key := #0 // Discard the key
  else
    Key := UpCase(Key); // Upper case
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.edtCostCodeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['a'..'z','A'..'Z','0'..'9',Chr(vk_Back)]) then
    Key := #0 // Discard the key
  else
    Key := UpCase(Key); // Upper case
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.edtServiceStartYearKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not (Key in ['0'..'9',Chr(vk_Back)]) then
    Key := #0; // Discard the key
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssAlt in Shift) then
  begin
    case Key of
      69: btnEmail.Click; // Alt + E
      70: btnFile.Click; // Alt + F
      80: btnPrint.Click; // Alt + P
    end;
  end;
  if (Key = VK_ESCAPE) then
    btnCancel.Click;  
end;

//------------------------------------------------------------------------------
procedure TfrmNewCAF.FormShow(Sender: TObject);
begin
  //edtAccountName.SetFocus;
end;

//------------------------------------------------------------------------------
function TfrmNewCAF.ValidateForm: Boolean;
var
  ErrorStr, DateErrorStr: string;
begin
  {DateErrorStr := '';
  if (cmbServiceStartMonth.ItemIndex = -1) then
  begin
    if (edtServiceStartYear.Text = '') then
      DateErrorStr := DateErrorStr + 'You must enter a starting date'
    else
      DateErrorStr := DateErrorStr + 'You must choose a starting month';
  end else
    if (Length(edtServiceStartYear.Text) < 2) then
      DateErrorStr := DateErrorStr + 'You must enter a valid starting year';

  ErrorStr := '';}


//  HelpfulErrorMsg(DateErrorStr, 0);

  Result := True;              
end;

end.
