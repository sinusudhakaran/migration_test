unit RequestRegFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, ImagesFrm, OSFont;

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
    procedure btnSubmitClick(Sender: TObject);
  private
    { Private declarations }
    function VerifyForm: Boolean;
    procedure SetupForm;
  public
    { Public declarations }
  end;

  function RequestBankLinkOnlineregistration: Boolean;

implementation

uses
  Globals,
  SYDEFS,
  WarningMoreFrm,
  MailFrm;

{$R *.dfm}

function RequestBankLinkOnlineregistration: Boolean;
var
  RequestRegForm: TRequestregForm;
begin
  RequestRegForm := TRequestregForm.Create(Application.MainForm);
  try
    RequestRegForm.SetupForm;
    Result := (RequestRegForm.ShowModal = mrOK);
  finally
    RequestRegForm.Free;
  end;
end;

procedure TRequestregForm.btnSubmitClick(Sender: TObject);
const
  ONE_LINE = #10;
  TWO_LINES = #10#10;
var
  Msg: string;
begin
  Msg := Format('Please register this practice on BankLink Online%s' +
                'Practice Name: %s%s' +
                'Practice Code: %s%s' +
                'The BankLink Online Administrator (Primary Contact) for the practice%s' +
                'Name: %s%s' +
                'Phone Number: %s%s' +
                'Email Address: %s%s',
                [TWO_LINES,
                 edtPracticeName.Text, ONE_LINE,
                 edtSecureCode.Text, TWO_LINES, TWO_LINES,
                 cbAdminName.Items[cbAdminName.ItemIndex], ONE_LINE,
                 edtPh.Text, ONE_LINE,
                 edtEmail.Text, TWO_LINES]);

  SendMailTo('BankLink Online Registration', GetSupportEmailAddress,
             'BankLink Online Registration', Msg);
end;

procedure TRequestregForm.cbAdminNameChange(Sender: TObject);
begin
  //Practice user selected
  edtPh.Text := '';
  edtEmail.Text := '';
  if (cbAdminName.ItemIndex > 0) then begin
    if (Trim(edtPh.Text) = '') and (Trim(edtEmail.Text) = '') then begin
      edtPh.Text := pUser_Rec(cbAdminName.Items.Objects[cbAdminName.ItemIndex]).usDirect_Dial;
      edtEmail.Text := pUser_Rec(cbAdminName.Items.Objects[cbAdminName.ItemIndex]).usEMail_Address;
    end;
  end;
end;

procedure TRequestregForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  if (ModalResult = mrOk) then
    CanClose := VerifyForm;
end;

procedure TRequestregForm.FormShow(Sender: TObject);
begin
  if edtPracticeName.CanFocus then
    edtPracticeName.SetFocus;
end;

procedure TRequestregForm.SetupForm;
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
end;

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

  //Email
  if edtEmail.Enabled and (Trim(edtEmail.Text) = '') then begin
    if edtEmail.CanFocus then
      edtEmail.SetFocus;
    HelpfulWarningMsg('A valid administrator email address is required for this request. '  +
                      'Please try again.',0);
    Exit;
  end;

  Result := True;
end;

end.
