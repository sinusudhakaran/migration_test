unit RequestRegFrm;

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
  ExtCtrls,
  StdCtrls,
  ImagesFrm,
  OSFont;

type
  TRequestregForm = class(TForm)
    btnSubmit: TButton;
    btnCancel: TButton;
    Bevel10: TBevel;
    imgInfo: TImage;
    lblPleaseAllow: TLabel;
    lblInfo: TLabel;
    lblPracticeName: TLabel;
    lblSecureCode: TLabel;
    Label5: TLabel;
    lblAdminName: TLabel;
    lblPh: TLabel;
    lblEmail: TLabel;
    Bevel1: TBevel;
    edtPracticeName: TEdit;
    edtSecureCode: TEdit;
    edtPh: TEdit;
    edtEmail: TEdit;
    cbAdminName: TComboBox;
    Label9: TLabel;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure cbAdminNameChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    m_ServiceAgreementVersion: String;
    m_ServiceAgreementSignee: String;
    m_ServiceAgreementSigneeTitle: String;
    
    function VerifyForm: Boolean;
    procedure SetupForm(ServiceAgreementVersion, ServiceAgreementSignee, ServiceAgreementSigneeTitle: String);
    function SendEmail: Boolean;
    procedure DoRebranding();
  public
    { Public declarations }
  end;

  function RequestBankLinkOnlineregistration(ServiceAgreementVersion, ServiceAgreementSignee, ServiceAgreementSigneeTitle: String) : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  Globals,
  SYDEFS,
  WarningMoreFrm,
  MailFrm,
  LogUtil,
  Admin32,
  bkProduct,
  bkBranding,
  bkConst;

{$R *.dfm}
//------------------------------------------------------------------------------
function RequestBankLinkOnlineregistration(ServiceAgreementVersion, ServiceAgreementSignee, ServiceAgreementSigneeTitle: String): Boolean;
var
  RequestRegForm: TRequestregForm;
begin
  RequestRegForm := TRequestregForm.Create(Application.MainForm);
  try
    RequestRegForm.SetupForm(ServiceAgreementVersion, ServiceAgreementSignee, ServiceAgreementSigneeTitle);
    
    Result := (RequestRegForm.ShowModal = mrOK);
  finally
    RequestRegForm.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TRequestregForm.cbAdminNameChange(Sender: TObject);
begin
  //Practice user selected
  if (cbAdminName.ItemIndex > 0) then
  begin
    if (Trim(edtPh.Text) = '') then
      edtPh.Text := pUser_Rec(cbAdminName.Items.Objects[cbAdminName.ItemIndex]).usDirect_Dial;

    if (Trim(edtEmail.Text) = '') then
      edtEmail.Text := pUser_Rec(cbAdminName.Items.Objects[cbAdminName.ItemIndex]).usEMail_Address;
  end;
end;

//------------------------------------------------------------------------------
procedure TRequestregForm.DoRebranding;
begin
  Caption := 'Request ' + BRAND_ONLINE + ' Registration';
  lblSecureCode.Caption := BRAND_SECURE + ' Code';
  lblInfo.Caption := 'When your secure area has been created, a member of the ' +
                     BRAND_SUPPORT + ' Team will contact the above ' + BRAND_ONLINE + ' ' +
                     'Administrator to provide assistance with using the ' + BRAND_ONLINE + ' service.';
end;

//------------------------------------------------------------------------------
procedure TRequestregForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if (ModalResult = mrOk) then
  begin
    CanClose := VerifyForm;
    if CanClose then
    begin
      if SendEmail then
      begin
        if LoadAdminSystem(True, 'RequestRegForm') then
        begin
          try
            AdminSystem.fdFields.fdLast_Agreed_To_BLOSA := m_ServiceAgreementVersion;

            SaveAdminSystem;

            LogUtil.LogMsg(lmInfo, 'ServiceAgreementDlg', Format('BankLink Online service agreement accepted by - SigneeName: %s; SigneeTile: %s; Service Agreement Version: %s', [m_ServiceAgreementSignee, m_ServiceAgreementSigneeTitle, m_ServiceAgreementVersion]), 0);
          except
            if AdminIsLocked then
            begin
              UnLockAdmin;
            end;

            raise;
          end;
        end;
      end;
    end;
  end;
end;

procedure TRequestregForm.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

//------------------------------------------------------------------------------
procedure TRequestregForm.FormShow(Sender: TObject);
begin
  if edtPracticeName.CanFocus then
    edtPracticeName.SetFocus;
end;

//------------------------------------------------------------------------------
function TRequestregForm.SendEmail: Boolean;
const
  ONE_LINE = #10;
  TWO_LINES = #10#10;
var
  Msg: string;
begin
  Msg := Format('Please register this practice on ' + bkBranding.ProductOnlineName + '%s' +
                'Practice Name: %s%s' +
                'Practice Code: %s%s' +
                'The ' + bkBranding.ProductOnlineName + ' Administrator (Primary Contact) for the practice%s' +
                'Name: %s%s' +
                'Phone Number: %s%s' +
                'Email Address: %s%s' +
                'I confirm that I am authorised to bind the Customer to this Service Agreement (including the terms and conditions), I have read the Service Agreement and terms and conditions and I confirm the Customer’s acceptance of them. %s' +
                'Signee Name: %s%s' +
                'Signee Title: %s%s' +
                'Service Agreement Version: %s%s', 
                [TWO_LINES,
                 edtPracticeName.Text, ONE_LINE,
                 edtSecureCode.Text, TWO_LINES, TWO_LINES,
                 cbAdminName.Items[cbAdminName.ItemIndex], ONE_LINE,
                 edtPh.Text, ONE_LINE,
                 edtEmail.Text, TWO_LINES,
                 ONE_LINE,
                 m_ServiceAgreementSignee, ONE_LINE,
                 m_ServiceAgreementSigneeTitle, ONE_LINE,
                 m_ServiceAgreementVersion, TWO_LINES]);

  Result := SendMailTo(bkBranding.ProductOnlineName + ' Registration', GetSupportEmailAddress, bkBranding.ProductOnlineName +  ' Registration', Msg);
end;

//------------------------------------------------------------------------------
procedure TRequestregForm.SetupForm(ServiceAgreementVersion, ServiceAgreementSignee, ServiceAgreementSigneeTitle: String);
var
  i: integer;
  User: pUser_Rec;
begin
  //Image
  ImgInfo.Picture := AppImages.InfoBmp.Picture;
  //Practice details
  if Trim(AdminSystem.fdFields.fdPractice_Name_for_Reports) <> '' then begin
    edtPracticeName.Text := AdminSystem.fdFields.fdPractice_Name_for_Reports;
    edtPracticeName.Enabled := False;
  end;
  edtSecureCode.Text := AdminSystem.fdFields.fdBankLink_Code;
  edtSecureCode.Enabled := False;
  //Admin details
  cbAdminName.Items.Add('');  //Default to blank
  for i := AdminSystem.fdSystem_User_List.First to AdminSystem.fdSystem_User_List.Last do begin
    User := AdminSystem.fdSystem_User_List.User_At(i);
    if User.usSystem_Access then
      cbAdminName.Items.AddObject(User.usName, TObject(User));
  end;
  cbAdminName.ItemIndex := 0;

  m_ServiceAgreementVersion := ServiceAgreementVersion;
  m_ServiceAgreementSignee := ServiceAgreementSignee;
  m_ServiceAgreementSigneeTitle := ServiceAgreementSigneeTitle;
end;

//------------------------------------------------------------------------------
function TRequestregForm.VerifyForm: Boolean;
begin
  Result := False;

  //Practice name
  if edtPracticeName.Enabled and (Trim(edtPracticeName.Text) = '') then begin
    if edtPracticeName.CanFocus then
      edtPracticeName.SetFocus;
    HelpfulWarningMsg('A valid practice name is required for this request. '  +
                      'Please try again.',0);
    Exit;
  end;

  //Admin name
  if (cbAdminName.ItemIndex = 0) then begin
    if cbAdminName.CanFocus then
      cbAdminName.SetFocus;
    HelpfulWarningMsg('A valid administrator name is required for this request. '  +
                      'Please try again.',0);
    Exit;
  end;

  //Telephone
  if (Trim(edtPh.Text) = '') then begin
    if edtPh.CanFocus then
      edtPh.SetFocus;
    HelpfulWarningMsg('A valid administrator phone number is required for this request. '  +
                      'Please try again.',0);
    Exit;
  end;

  //Email
  if (Trim(edtEmail.Text) = '') then begin
    if edtEmail.CanFocus then
      edtEmail.SetFocus;
    HelpfulWarningMsg('A valid administrator email address is required for this request. '  +
                      'Please try again.',0);
    Exit;
  end;

  Result := True;
end;

end.
