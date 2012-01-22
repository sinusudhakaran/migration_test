unit EditUserPassword;
//------------------------------------------------------------------------------
{
   Title:       Edit User Password Dialog

   Description: Changes the password for a user, this dialog is only accessable
                if the current user has access to BankLink Online

   Author:      Ralph Austen

   Remarks:

}
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
  OsFont,
  SyDefs;       

type
  TEditUserPassword = class(TForm)
    edtOldPassword: TEdit;
    edtNewPassword: TEdit;
    lblOldPassword: TLabel;
    lblNewPassword: TLabel;
    chkOnlineAndPracticeSamePass: TCheckBox;
    btnOk: TButton;
    btnCancel: TButton;
    lblConfirmPassword: TLabel;
    edtConfirmPassword: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    fUser_Rec : pUser_Rec;

    function Validate : boolean;
    function UpdateOnline : Boolean;
    function UpdateSystemAdmin : Boolean;
  public
    function Initlize : Boolean;
  end;

function ChangeUserPassword : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  Globals,
  bkXPThemes,
  BankLinkOnlineServices,
  RegExprUtils,
  WarningMoreFrm,
  InfoMoreFrm,
  ErrorMoreFrm,
  Admin32,
  LogUtil;

const
  UNITNAME = 'EditUserPassword';

//------------------------------------------------------------------------------
function ChangeUserPassword : boolean;
var
  MyDlg : TEditUserPassword;
begin
  result := false;

  if not Assigned( AdminSystem) then
    exit;

  MyDlg := TEditUserPassword.Create(Application.mainForm);
  try
    //BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    if MyDlg.Initlize then
      MyDlg.ShowModal;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TEditUserPassword.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

//------------------------------------------------------------------------------
procedure TEditUserPassword.btnOkClick(Sender: TObject);
begin
  BtnOk.ModalResult := mrNone;
  If Validate Then
  begin
    if chkOnlineAndPracticeSamePass.checked then
      if not UpdateOnline then
        Exit;

    if not UpdateSystemAdmin then
      Exit;

    BtnOk.ModalResult := mrOk;
    Close;
  end;
end;

//------------------------------------------------------------------------------
function TEditUserPassword.Validate : boolean;
begin
  Result := false;

  if (Trim(Uppercase(edtOldPassword.text)) <> fUser_Rec.usPassword) then
  begin
    HelpfulWarningMsg('Practice old user password is not correct', 0 );
    edtOldPassword.SetFocus;
    exit;
  end; { (Trim(edtOldPassword.text) <> fUser_Rec.usPassword) }

  if (Trim(edtNewPassword.text) = '') then
  begin
    HelpfulWarningMsg('BankLink Online users must have a Password.', 0 );
    edtNewPassword.SetFocus;
    exit;
  end; { (Trim(edtNewPassword.text) = '') }

  if (edtNewPassword.text <> edtConfirmPassword.text) then
  begin
    HelpfulWarningMsg('BankLink Online users Password and Confirm Password must be the same.', 0 );
    edtNewPassword.SetFocus;
    exit;
  end; { (edtNewPassword.text <> edtConfirmPassword.text) }

  if not RegExIsPasswordValid(edtNewPassword.text) then
  begin
    HelpfulWarningMsg('BankLink Online users must have a Password that contains 8-12 characters, including atleast 1 digit.', 0 );
    edtNewPassword.SetFocus;
    exit;
  end; { not RegExIsPasswordValid(edtNewPassword.text) }

  Result := True;
end;

//------------------------------------------------------------------------------
function TEditUserPassword.Initlize: Boolean;
begin
  Result := Assigned(CurrUser);
  if not Result then
  begin
    HelpfulErrorMsg('There is no User logged onto BankLink Practice', 0);
    Exit;
  end;

  fUser_Rec := AdminSystem.fdSystem_User_List.FindLRN(CurrUser.LRN);

  Result := Assigned(fUser_Rec);
  if not Result then
  begin
    HelpfulErrorMsg('The User ' + CurrUser.FullName + ' can no longer be found in the Admin System.', 0);
    Exit;
  end;

  chkOnlineAndPracticeSamePass.Checked := fUser_Rec.usUse_Practice_Password_Online;

  SetPasswordFont(edtOldPassword);
  SetPasswordFont(edtNewPassword);
  SetPasswordFont(edtConfirmPassword);
end;

//------------------------------------------------------------------------------
function TEditUserPassword.UpdateOnline: Boolean;
begin
  Result := False;
  try
    if ProductConfigService.ChangePracUserPass(fUser_Rec.usCode,
                                               Trim(Uppercase(edtNewPassword.text))) then
    begin
      Result := True;
    end;
  Except
    on E : Exception do
    begin
      HelpfulErrorMsg(E.Message, 0);
    end;
  End;
end;

//------------------------------------------------------------------------------
function TEditUserPassword.UpdateSystemAdmin: Boolean;
begin
  Result := false;
  If LoadAdminSystem(true, UNITNAME ) Then
  begin
    fUser_Rec := AdminSystem.fdSystem_User_List.FindLRN(CurrUser.LRN);
    If not Assigned(fUser_Rec) Then
    begin
      UnlockAdmin;
      HelpfulErrorMsg('The User ' + CurrUser.FullName + ' can no longer be found in the Admin System.', 0);
      exit;
    End;

    fUser_Rec.usPassword := edtNewPassword.text;

    SaveAdminSystem;
    Result := true;

    LogUtil.LogMsg(lmInfo, UNITNAME, Format('User %s password was changed.', [fUser_Rec^.usName]));
    HelpfulInfoMsg('The User Password has been successfully Updated.', 0 );
  End { LoadAdminSystem(true) }
  Else
  begin
    HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
  End;
end;

end.
