unit OnlinePasswordFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls;

type
  TfrmOnlinePassword = class(TForm)
    Button1: TButton;
    Button2: TButton;
    edtPassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    function GetPassword: String;
    { Private declarations }
  public
    class function PromptUser(out Password: String): Boolean;

    property Password: String read GetPassword;
  end;

var
  frmOnlinePassword: TfrmOnlinePassword;

implementation

{$R *.dfm}

{ TfrmBankLinkOnlinePassword }

function TfrmOnlinePassword.GetPassword: String;
begin
  Result := edtPassword.Text;
end;

class function TfrmOnlinePassword.PromptUser(out Password: String): Boolean;
var
  PasswordPrompt: TfrmOnlinePassword;
begin
  PasswordPrompt := TfrmOnlinePassword.Create(nil);

  if Screen.ActiveForm <> nil then
  begin
    PasswordPrompt.PopupParent := Screen.ActiveForm;
    PasswordPrompt.PopupMode := pmExplicit;
  end;

  if PasswordPrompt.ShowModal = mrOk then
  begin
    Password := PasswordPrompt.Password;
    Result := True;
  end
  else
  begin
    Result := False;
  end;
end;

end.
