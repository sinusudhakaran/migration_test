unit ChangePwdDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  OSFont;

type
  TdlgChangePwd = class(TForm)
    edtCurrent: TEdit;
    lblCurrent: TLabel;
    edtNew: TEdit;
    lblNew: TLabel;
    edtConfirm: TEdit;
    lblConfirm: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    Label20: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FCurrentPassword: string;
    FTries: Integer;
    procedure SetCurrentPassword(Value: string);
    function GetNewPassword: string;
  public
    { Public declarations }
    property CurrentPassword: string write SetCurrentPassword;
    property NewPassword: string read GetNewPassword;
  end;

var
  dlgChangePwd: TdlgChangePwd;

implementation

uses ErrorMoreFrm, Globals, bkXPThemes;

{$R *.dfm}

procedure TdlgChangePwd.btnOKClick(Sender: TObject);
begin
  if edtCurrent.Text <> FCurrentPassword then
  begin
    if FTries >= MAXLOGINATTEMPTS then
    begin
      HelpfulErrorMsg( 'You have not entered a correct password after ' + IntToStr(MAXLOGINATTEMPTS) + ' tries.'+#13+#13+
                       'Please contact your ' + SHORTAPPNAME + ' Administrator.', 0);
      ModalResult := mrCancel;
    end
    else
    begin
      HelpFulErrorMsg('The password is incorrect.'#13#13'You must enter the correct current password in order to change the password.', 0);
      Inc(FTries);
      edtCurrent.SetFocus;
    end;
  end
  else if edtNew.Text <> edtConfirm.Text then
  begin
    HelpFulErrorMsg('The passwords you have entered do not match. Please re-enter them.', 0);
    edtNew.SetFocus;
  end
  else
    ModalResult := mrOk;
end;

procedure TdlgChangePwd.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  FCurrentPassword := '';
  FTries := 0;
  // Weirdness...it won't set this at design time :S
  // (same problem happens in enterpwddlg.pas)
  SetPasswordFont(edtCurrent);
  SetPasswordFont(edtNew);
  SetPasswordFont(edtConfirm);

end;

procedure TdlgchangePwd.SetCurrentPassword(Value: string);
begin
  FCurrentPassword := Value;
  lblCurrent.Enabled := Value <> '';
  edtCurrent.Enabled := Value <> '';
end;

function TdlgChangePwd.GetNewPassword: string;
begin
  Result := edtNew.Text;
end;

end.
