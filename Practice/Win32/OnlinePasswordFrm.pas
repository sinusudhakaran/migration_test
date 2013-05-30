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
  BankLinkOnlineServices, bkProduct;

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
procedure TfrmOnlinePassword.FormCreate(Sender: TObject);
begin
  Caption := TProduct.Rebrand(Caption);
  lblOnlineCaption01.Caption := TProduct.Rebrand(lblOnlineCaption01.Caption);
  lblOnlineCaption02.Caption := TProduct.Rebrand(lblOnlineCaption02.Caption);
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
end;

//------------------------------------------------------------------------------
procedure TfrmOnlinePassword.SetEmail(aEmail: string);
begin
  lblOnlineCaption02.Caption := Format(lblOnlineCaption02.Caption, [aEmail]);
  fEmail := aEmail;
end;

end.
