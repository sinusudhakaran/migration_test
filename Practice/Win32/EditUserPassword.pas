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
    btnOk: TButton;
    btnCancel: TButton;
    lblConfirmPassword: TLabel;
    edtConfirmPassword: TEdit;
    LblPasswordValidation: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    fUser_Rec : pUser_Rec;
    FUserCode : String;

    function Validate : boolean;
    function UpdateOnline : Boolean;
    function UpdateSystemAdmin : Boolean;
    function GetNewPassword: String;
  public
    function Initlize : Boolean; overload;
    function Initlize(UserCode: String; CurrentPassword: String) : Boolean; overload;

    property NewPassword: String read GetNewPassword;
  end;

function ChangeUserPassword : boolean; overload;
function ChangeUserPassword(UserCode: String; var CurrentPassword: String): Boolean; overload;

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
  LogUtil,
  BKHelp;

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
    BKHelpSetUp(MyDlg, BKH_Changing_your_password_to_match_BankLink_Online);
    if MyDlg.Initlize then
      MyDlg.ShowModal;
  finally
    MyDlg.Free;
  end;
end;

function ChangeUserPassword(UserCode: String; var CurrentPassword: String): Boolean; overload;
var
  MyDlg : TEditUserPassword;
begin
  Result := false;

  if not Assigned( AdminSystem) then
    exit;

  MyDlg := TEditUserPassword.Create(Application.mainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Changing_your_password_to_match_BankLink_Online);

    if MyDlg.Initlize(UserCode, CurrentPassword) then
    begin
      if MyDlg.ShowModal = mrOk then
      begin
        CurrentPassword := MyDlg.Newpassword;

        Result := True;
      end;
    end;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TEditUserPassword.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

function TEditUserPassword.GetNewPassword: String;
begin
  Result := edtNewPassword.Text;
end;

function TEditUserPassword.Initlize(UserCode: String; CurrentPassword: String): Boolean;
begin
  FUserCode := UserCode;
  
  fUser_Rec := AdminSystem.fdSystem_User_List.FindCode(UserCode);

  if Assigned(fUser_Rec) then
  begin
    SetPasswordFont(edtOldPassword);
    SetPasswordFont(edtNewPassword);
    SetPasswordFont(edtConfirmPassword);

    edtOldPassword.Text := CurrentPassword;

    ActiveControl := edtNewPassword;

    Result := True;
  end
  else
  begin
    HelpfulErrorMsg('The User ' + UserCode + ' can not be found in the Admin System.', 0);
  end;
end;

//------------------------------------------------------------------------------
procedure TEditUserPassword.btnOkClick(Sender: TObject);
begin
  If Validate Then
  begin
    if not UpdateOnline then
      Exit;

    if not UpdateSystemAdmin then
      Exit;

    ModalResult := mrOk;
  end;
end;

//------------------------------------------------------------------------------
function TEditUserPassword.Validate : boolean;
begin
  Result := false;
  
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

  SetPasswordFont(edtOldPassword);
  SetPasswordFont(edtNewPassword);
  SetPasswordFont(edtConfirmPassword);
end;

//------------------------------------------------------------------------------
function TEditUserPassword.UpdateOnline: Boolean;
var
  OldPassword: String;
begin
  Result := False;
  try
    OldPassword := edtOldPassword.Text;

    if ProductConfigService.ChangePracUserPass(fUser_Rec.usCode,
                                               Trim(OldPassword),
                                               Trim(edtNewPassword.text)) then
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
    if Assigned(CurrUser) then
    begin
      fUser_Rec := AdminSystem.fdSystem_User_List.FindLRN(CurrUser.LRN);

      If not Assigned(fUser_Rec) Then
      begin
        UnlockAdmin;
        HelpfulErrorMsg('The User ' + CurrUser.FullName + ' can no longer be found in the Admin System.', 0);
        exit;
      End;
    end
    else
    begin
      fUser_Rec := AdminSystem.fdSystem_User_List.FindCode(FUserCode);

      If not Assigned(fUser_Rec) Then
      begin
        UnlockAdmin;
        HelpfulErrorMsg('The User ' + FUserCode + ' can no longer be found in the Admin System.', 0);
        exit;
      End;    
    end;

    if FUser_Rec.usUsing_Secure_Authentication then
    begin
      UpdateUserDataBlock(FUser_Rec, edtNewPassword.text);

      if Assigned(CurrUser) then
      begin
        CurrUser.Password := edtNewPassword.text;
      end;
    end
    else
    begin
      fUser_Rec.usPassword := edtNewPassword.text;
    end;

    SaveAdminSystem;

    Result := true;

    LogUtil.LogMsg(lmInfo, UNITNAME, Format('User %s password was changed.', [fUser_Rec^.usName]));
    
    HelpfulInfoMsg(Format('Password for %s has been successfully updated.', [fUser_Rec.usName]), 0 );
  End { LoadAdminSystem(true) }
  Else
  begin
    HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
  End;
end;

end.
