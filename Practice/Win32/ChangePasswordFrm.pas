unit ChangePasswordFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TChangePasswordForm = class(TForm)
    lblCurrent: TLabel;
    lblNew: TLabel;
    lblConfirm: TLabel;
    eCurrent: TEdit;
    eNew: TEdit;
    eNewConfirm: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure eNewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eNewConfirmKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    FPassword: string;
    FEmail: string;
    function ValidPassword: Boolean;

    procedure DoStatusProgress(APercentComplete : integer;
                               AMessage         : string);
  public
    { Public declarations }
  end;

  function ChangeBankLinkOnlinePassword(const AEmail, APassword: string; var ANewPassword: string): Boolean;

implementation

uses
  ErrorMoreFrm,
  WebCiCoClient,
  progress,
  Globals;

{$R *.dfm}

function ChangeBankLinkOnlinePassword(const AEmail, APassword: string; var ANewPassword: string): Boolean;
var
  ChangePasswordForm: TChangePasswordForm;
begin
  Result := False;
  ChangePasswordForm := TChangePasswordForm.Create(Application.MainForm);
  try
    ChangePasswordForm.FPassword := APassword;
    ChangePasswordForm.FEmail    := AEmail;
    if ChangePasswordForm.ShowModal = mrOk then begin
      ANewPassword := ChangePasswordForm.eNew.Text;
      Result := True;
    end;
  finally
    ChangePasswordForm.Free;
  end;
end;

{ TChangePasswordForm }

procedure TChangePasswordForm.eNewConfirmKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Length(eNewConfirm.Text) >= 12) then begin
    if eNewConfirm.CanFocus then
      eNewConfirm.SetFocus;
    HelpfulErrorMsg('Your password cannot be more then 12 characters.',0);
  end;
end;

procedure TChangePasswordForm.eNewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Length(eNew.Text) >= 12) then begin
    if eNew.CanFocus then
      eNew.SetFocus;
    HelpfulErrorMsg('Your password cannot be more then 12 characters.',0);
  end;
end;

procedure TChangePasswordForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOk then
    CanClose := ValidPassword;
end;

function TChangePasswordForm.ValidPassword: Boolean;
var
  i: integer;
  HasNumbers, HasLetters: Boolean;
  TempStr: string;
  ServerResponce : TServerResponce;
begin
  Result := False;
  //Password matches
  if eCurrent.Text <> FPassword then begin
     if eCurrent.CanFocus then
      eCurrent.SetFocus;
    HelpfulErrorMsg('The Current Password entered does not match the password for this username.',0);
    Exit;
  end;
  //Confirmed
  if (eNew.Text <> eNewConfirm.Text) then begin
    if eNew.CanFocus then
      eNew.SetFocus;
    HelpfulErrorMsg('The New and Confirm Passwords fields must match.',0);
    Exit;
  end;
  //Min length
  if (Length(eNew.Text) < 8) or (Length(eNew.Text) > 12) then begin
    if eNew.CanFocus then
      eNew.SetFocus;
    HelpfulErrorMsg('Your password must be between 8 and 12 characters.',0);
    Exit;
  end;
  //Not the same as current
  if (eNew.Text = FPassword) then begin
    if eNew.CanFocus then
      eNew.SetFocus;
    HelpfulErrorMsg('The Current and New Passwords must be different.',0);
    Exit;
  end;
  //Letters and numbers
  HasLetters := False;
  HasNumbers := False;
  TempStr := UpperCase(eNew.text);
  for i := 1 to Length(eNew.text) do begin
    if TempStr[i] in ['A'..'Z'] then
      HasLetters := True;
    if TempStr[i] in ['0'..'9'] then
      HasNumbers := True;
  end;
  if not (HasLetters and HasNumbers) then begin
    if eNew.CanFocus then
      eNew.SetFocus;
    HelpfulErrorMsg('The New Password must contain a combination of letters and numbers.',0);
    Exit;
  end;

  // Finally Contact the Service and Validate
  try
    StatusSilent := False;
    try
      UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 0);
      CiCoClient.OnProgressEvent := DoStatusProgress;

      CiCoClient.SetBooksUserPassword(FEmail, FPassword, eNew.Text, ServerResponce);
    finally
      StatusSilent := True;
      CiCoClient.OnProgressEvent := Nil;
      ClearStatus;
    end;
  except
    on E: exception do
      begin
        HelpfulErrorMsg(Format('Error changing %s User password: %s',
                               [BANKLINK_ONLINE_NAME, E.Message]), 0);
        Exit;
      end;
  End;

  if Not ((ServerResponce.Status = '200')
  and (Lowercase(ServerResponce.Description) = 'password changes')) then
  begin
    TempStr := Format('Error changing %s User password: %s',
                      [BANKLINK_ONLINE_NAME, ServerResponce.Description]);
    HelpfulErrorMsg(TempStr ,0);
    Exit;
  end;

  //Still here then...
  Result := True;
end;

procedure TChangePasswordForm.DoStatusProgress(APercentComplete : integer;
                                               AMessage         : string);
begin
  UpdateAppStatus(BANKLINK_ONLINE_NAME, AMessage, APercentComplete);
end;

end.
