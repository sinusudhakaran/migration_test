unit OnlinePasswordFrm;

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
  OSFont,
  StdCtrls;

type
  //----------------------------------------------------------------------------
  TfrmOnlinePassword = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    edtPassword: TEdit;
    Label1: TLabel;
    lblOnlineCaption01: TLabel;
    lblOnlineCaption02: TLabel;
    btnResetPassword: TButton;
    procedure btnResetPasswordClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fEmail : String;
    fPasswordReset : boolean;
    function GetPassword: String;
    procedure DoRebranding();
  public
    class function PromptUser(out Password: String; aUserEmail : string; out aPasswordReset : Boolean): Boolean;

    procedure SetEmail(aEmail : string);
    property Password: String read GetPassword;
    property PasswordReset : Boolean read fPasswordReset write fPasswordReset;
  end;

var
  frmOnlinePassword: TfrmOnlinePassword;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  BankLinkOnlineServices,
  bkProduct,
  bkConst;

{ TfrmBankLinkOnlinePassword }
//------------------------------------------------------------------------------
procedure TfrmOnlinePassword.btnResetPasswordClick(Sender: TObject);
begin
  if ProductConfigService.ResetPracticeUserPasswordUnSecure(fEmail) then
  begin
    PasswordReset := true;
    btnResetPassword.ModalResult := mrok;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmOnlinePassword.DoRebranding;
begin
  Caption := BRAND_ONLINE + ' Password';
  lblOnlineCaption01.Caption := 'Practice is unable to authenticate with ' +
                                BRAND_ONLINE + ' because your ' + BRAND_PRACTICE_SHORT_NAME + ' ' +
                                'password does not match your ' + BRAND_ONLINE + ' password.' +
                                #13#10 + #13#10 +
                                'Enter your ' + BRAND_ONLINE + ' password here then click OK:';
  lblOnlineCaption02.Caption := 'If required, you can request a temporary password to be sent to ' +
                                '%s using the Reset button below.' + #13#10 + #13#10 +
                                'Contact ' + BRAND_SUPPORT + ' if you require assistance.';
end;

//------------------------------------------------------------------------------
procedure TfrmOnlinePassword.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

function TfrmOnlinePassword.GetPassword: String;
begin
  Result := edtPassword.Text;
end;

//------------------------------------------------------------------------------
class function TfrmOnlinePassword.PromptUser(out Password: String; aUserEmail : string; out aPasswordReset : Boolean): Boolean;
var
  PasswordPrompt: TfrmOnlinePassword;
begin
  PasswordPrompt := TfrmOnlinePassword.Create(nil);

  try
    if Screen.ActiveForm <> nil then
    begin
      PasswordPrompt.PopupParent := Screen.ActiveForm;
      PasswordPrompt.PopupMode := pmExplicit;
    end;

    PasswordPrompt.SetEmail(aUserEmail);
    PasswordPrompt.PasswordReset := false;

    if PasswordPrompt.ShowModal = mrOk then
    begin
      aPasswordReset := PasswordPrompt.PasswordReset;
      Password := PasswordPrompt.Password;
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    FreeAndNil(PasswordPrompt);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmOnlinePassword.SetEmail(aEmail: string);
begin
  lblOnlineCaption02.Caption := Format(lblOnlineCaption02.Caption, [aEmail]);
  fEmail := aEmail;
end;

end.
