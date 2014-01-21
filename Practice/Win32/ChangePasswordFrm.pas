unit ChangePasswordFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, OSFont, WebCiCoClient;

type
  TBankLinkOnlineLoginState = (blsInitialLogin, blsChangePasswordRequired,
                               blsChangePassword, blsSucessful);

  TChangePasswordForm = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    eCurrent: TEdit;
    eNew: TEdit;
    eNewConfirm: TEdit;
    eSubDomain: TEdit;
    eUsername: TEdit;
    gbxNote: TGroupBox;
    lblConfirm: TLabel;
    lblCurrent: TLabel;
    lblNew: TLabel;
    lblNote: TLabel;
    lblSubdomain: TLabel;
    lblUsername: TLabel;
    pnlCurrent: TPanel;
    pnlDomainAndUser: TPanel;
    pnlNewAndConfirm: TPanel;
    pnlNote: TPanel;
    pnlOkCancel: TPanel;
    procedure eNewConfirmKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure eNewKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FLoginState: TBankLinkOnlineLoginState;    
    FServerResponse: TServerResponse;
    FClientStatusList: TClientStatusList;
    function CanLogin: Boolean;
    function ChangePassword: Boolean;
    function ValidateLoginDetails: Boolean;
    function ValidCurrentPassword: Boolean;
    function ValidNewPassword: Boolean;
    procedure AddNoteToUser(ANote: string);
    procedure DoStatusProgress(APercentComplete: integer; AMessage: string);
    procedure DoRebranding();
  public
    { Public declarations }
  end;

  function ChangeBankLinkOnlinePassword(AServerResponce: TServerResponse;
                                        AClientStatusList: TClientStatusList): Boolean;
  function LoginToBankLinkOnline(var AServerResponce: TServerResponse;
                                 var AClientStatusList: TClientStatusList;
                                 Edit: Boolean = False;
                                 CheckUser: Boolean = False): Boolean;

implementation

uses
  ErrorMoreFrm,
  InfoMoreFrm,
  progress,
  Globals,
  IniSettings,
  bkBranding,
  bkProduct,
  bkConst;

{$R *.dfm}

function ChangeBankLinkOnlinePassword(AServerResponce: TServerResponse;
  AClientStatusList: TClientStatusList): Boolean;
var
  ChangePasswordForm: TChangePasswordForm;
begin
  //Change password
  Result := False;
  ChangePasswordForm := TChangePasswordForm.Create(Application.MainForm);
  try
    ChangePasswordForm.FLoginState := blsChangePassword;
    ChangePasswordForm.FServerResponse := AServerResponce;
    ChangePasswordForm.FClientStatusList := AClientStatusList;
    if ChangePasswordForm.ShowModal = mrOk then begin
      IniSettings.BK5WriteINI;
      HelpfulInfoMsg('The password change has been successful!',0);
      Result := True;
    end;
  finally
    ChangePasswordForm.Free;
  end;
end;

function LoginToBankLinkOnline(var AServerResponce: TServerResponse;
  var AClientStatusList: TClientStatusList; Edit: Boolean = False;
  CheckUser: Boolean = False): Boolean;
var
  ChangePasswordForm: TChangePasswordForm;
begin
  //Login
  Result := False;
  ChangePasswordForm := TChangePasswordForm.Create(Application.MainForm);
  try
    ChangePasswordForm.FLoginState := blsInitialLogin;
    ChangePasswordForm.FServerResponse := AServerResponce;
    ChangePasswordForm.FClientStatusList := AClientStatusList;
    if CheckUser then begin
      Result := ChangePasswordForm.CanLogin;
    end else if Edit then begin
      if ChangePasswordForm.ShowModal = mrOk then
        Result := True;
    end else begin
      if ChangePasswordForm.CanLogin then
        Result := True
      else if ChangePasswordForm.FServerResponse.Status > '114' then
        //Don't show login form if not a login error
        Exit
      else if ChangePasswordForm.ShowModal = mrOk then
        Result := True;
    end;
    AServerResponce := ChangePasswordForm.FServerResponse;
    AClientStatusList := ChangePasswordForm.FClientStatusList;
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
  if ModalResult = mrOk then begin
    case FLoginState of
      blsInitialLogin: begin
                         Globals.INI_BankLink_Online_SubDomain := eSubDomain.Text;
                         Globals.INI_BankLink_Online_Username := eUsername.Text;
                         Globals.INI_BankLink_Online_Password := eCurrent.Text;
                       end;
    end;
    CanClose := ValidateLoginDetails;
  end;
end;

procedure TChangePasswordForm.FormCreate(Sender: TObject);
begin
  DoRebranding();
end;

procedure TChangePasswordForm.FormShow(Sender: TObject);
begin
  //Setup the dialog
  case FLoginState of
    blsInitialLogin:
      begin
        //Initial login
        Caption := 'Login to ' + bkBranding.ProductOnlineName;
        eSubDomain.Text := Globals.INI_BankLink_Online_SubDomain;
        eUsername.Text := Globals.INI_BankLink_Online_Username;
        eCurrent.Text := Globals.INI_BankLink_Online_Password;
        //Hide change password
        if pnlNewAndConfirm.Visible then begin
          pnlNewAndConfirm.Visible := False;
          Height := Height - pnlNewAndConfirm.Height;
        end;
        lblCurrent.Caption := '&Password';
        AddNoteToUser('Enter login details.');
      end;
    blsChangePasswordRequired:
      begin
        //Reset password
        Caption := 'Reset ' + bkBranding.ProductOnlineName + ' Password';
        //Hide subdomain and username
        if pnlDomainAndUser.Visible then begin
          pnlDomainAndUser.Visible := False;
          Height := Height - pnlDomainAndUser.Height;
        end;
        //Show new and confirm
        if not pnlNewAndConfirm.Visible then begin
          pnlNewAndConfirm.Visible := True;
          Height := Height + pnlNewAndConfirm.Height;
        end;
        lblCurrent.Caption := 'Temporary &Password';
        AddNoteToUser('Reset password.');
      end;
    blsChangePassword:
      begin
        //Change password
        Caption := 'Change ' + bkBranding.ProductOnlineName + ' Password';
        //Hide subdomain and username
        if pnlDomainAndUser.Visible then begin
          pnlDomainAndUser.Visible := False;
          Height := Height - pnlDomainAndUser.Height;
        end;
        lblCurrent.Caption := 'Current &Password';        
        AddNoteToUser('Change password.');
      end;
  end;
end;

function TChangePasswordForm.ValidCurrentPassword: Boolean;
var
  i: integer;
  HasNumbers, HasLetters: Boolean;
  TempStr: string;
begin
  Result := False;
  //Min length
  if (Length(eCurrent.Text) < 8) or (Length(eCurrent.Text) > 12) then begin
    if eCurrent.CanFocus then
      eCurrent.SetFocus;
    HelpfulErrorMsg('Your password must be between 8 and 12 characters.',0);
    Exit;
  end;
  //Letters and numbers
  HasLetters := False;
  HasNumbers := False;
  TempStr := UpperCase(eCurrent.text);
  for i := 1 to Length(eCurrent.text) do begin
    if TempStr[i] in ['A'..'Z'] then
      HasLetters := True;
    if TempStr[i] in ['0'..'9'] then
      HasNumbers := True;
  end;
  if not (HasLetters and HasNumbers) then begin
    if eCurrent.CanFocus then
      eCurrent.SetFocus;
    HelpfulErrorMsg('Your password must contain a combination of letters and numbers.',0);
    Exit;
  end;
  Result := True;
end;

function TChangePasswordForm.ValidNewPassword: Boolean;
var
  i: integer;
  HasNumbers, HasLetters: Boolean;
  TempStr: string;
begin
  Result := False;

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
  if (eNew.Text = eCurrent.Text) then begin
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

  //If all ok then change the password
  if ChangePassword then begin
    Globals.INI_BankLink_Online_Password := eNew.text;
    Result := True;
  end;
end;

function TChangePasswordForm.ValidateLoginDetails: Boolean;
begin
  Result := False;

  //Check subdomain
  if (Globals.INI_BankLink_Online_SubDomain = '') then begin
    if eSubDomain.CanFocus then
      eSubDomain.SetFocus;
    HelpfulErrorMsg('Please enter the subdomain from the email with your login details.',0);
    Exit;
  end;

  //Check username
  if (Globals.INI_BankLink_Online_Username = '') then begin
    if eUsername.CanFocus then
      eUsername.SetFocus;
    HelpfulErrorMsg('Please enter the username from the email with your login details.',0);
    Exit;
  end;

  //Check password
  if (Globals.INI_BankLink_Online_Password = '') then begin
    if eCurrent.CanFocus then
      eCurrent.SetFocus;
    HelpfulErrorMsg('Please enter your ' + bkBranding.ProductOnlineName + ' password.',0);
    Exit;
  end;

  case FLoginState of
    blsInitialLogin: if not ValidCurrentPassword then Exit;
    blsChangePasswordRequired,
    blsChangePassword: if not ValidNewPassword then Exit;
  end;

  //Try to login
  Result := CanLogin;
end;

procedure TChangePasswordForm.AddNoteToUser(ANote: string);
begin
  if ANote <> '' then begin
    lblNote.Caption := ANote;
    if not pnlNote.Visible then
      Height := Height + pnlNote.Height;
    pnlNote.Visible := True;
  end else begin
    if pnlNote.Visible then
      Height := Height - pnlNote.Height;
    lblNote.Caption := '';
    pnlNote.Visible := False;
  end;
end;

function TChangePasswordForm.CanLogin: Boolean;
begin
  Result := False;

  //Check we have all the login details
  if (Globals.INI_BankLink_Online_SubDomain = '') or
     (Globals.INI_BankLink_Online_Username = '') or
     (Globals.INI_BankLink_Online_Password = '') then
    Exit;

  //Login to BankLink Online
  try
    StatusSilent := False;
    try
      UpdateAppStatus(bkBranding.ProductOnlineName, 'Connecting', 0);
      CiCoClient.OnProgressEvent := DoStatusProgress;

//      CiCoClient.GetBooksUserExists(Globals.INI_BankLink_Online_Username,
//                                    Globals.INI_BankLink_Online_Password,
//                                    FServerResponse);
      CiCoClient.GetClientFileStatus(FServerResponse, FClientStatusList);

      if (FServerResponse.Status = '200') then begin
        //Sucessful
        FLoginState := blsSucessful;
        Result := True;
      end else if FServerResponse.Status = '114' then begin
        //Reset password
        FLoginState := blsChangePasswordRequired;
        FormShow(Self);
        Exit;
      end else if FServerResponse.Status = '104' then begin
        HelpfulErrorMsg('This process requires a valid subdomain. Please try ' +
                        'again or contact your accountant for assistance.', 0);
        Exit;
      end else if (FServerResponse.Status = '106') then begin
        HelpfulErrorMsg(Format(bkBranding.ProductOnlineName + ' could not find user %s. ' +
                               'Please try again or contact your accountant ' +
                               'for assistance.',
                               [Globals.INI_BankLink_Online_Username]), 0);
        Exit;
      end else if (FServerResponse.Status = '107') then begin
        HelpfulErrorMsg('This process requires a valid username and password. ' +
                        'Please try again or contact your accountant for assistance.', 0);
        Exit;
      end else
        //Some other error
        raise Exception.Create(FServerResponse.Description);
    finally
      StatusSilent := True;
      CiCoClient.OnProgressEvent := nil;
      ClearStatus;
    end;
  except
    on E: Exception do begin
      HelpfulErrorMsg('Unable to connect to ' +
                       bkBranding.ProductOnlineName + ': ' + E.Message, 0);
      Exit;
    end;
  end;

  //Still here... then can login
  Result := True;
end;

function TChangePasswordForm.ChangePassword: Boolean;
var
  TempStr: string;
begin
  //Contact the Service and Validate
  Result := False;
  try
    StatusSilent := False;
    try
      UpdateAppStatus(bkBranding.ProductOnlineName, 'Connecting', 0);
      CiCoClient.OnProgressEvent := DoStatusProgress;
      CiCoClient.SetBooksUserPassword(Globals.INI_BankLink_Online_Username,
                                      eCurrent.Text,
                                      eNew.Text,
                                      FServerResponse);

      if FServerResponse.Status = '200' then
        Result := True;
    finally
      StatusSilent := True;
      CiCoClient.OnProgressEvent := Nil;
      ClearStatus;
    end;
  except
    on E: exception do
      begin
        HelpfulErrorMsg(Format('Error changing %s User password: %s',
                               [bkBranding.ProductOnlineName, E.Message]), 0);
        Exit;
      end;
  end;
  if not ((FServerResponse.Status = '200') and
          (Lowercase(FServerResponse.Description) = 'password changes')) then begin
    TempStr := Format('Error changing %s User password: %s',
                      [bkBranding.ProductOnlineName, FServerResponse.Description]);
    HelpfulErrorMsg(TempStr ,0);
    Exit;
  end;
end;

procedure TChangePasswordForm.DoRebranding;
begin
  lblNote.Caption := 'Note: Note to user about entering their ' + BRAND_ONLINE + ' Login details.';
end;

procedure TChangePasswordForm.DoStatusProgress(APercentComplete : integer;
                                               AMessage         : string);
begin
  UpdateAppStatus(bkBranding.ProductOnlineName, AMessage, APercentComplete);
end;

end.
