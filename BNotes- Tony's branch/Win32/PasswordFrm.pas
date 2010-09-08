unit PasswordFrm;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  BaseFrm, StdCtrls, Mask, RzEdit, ExtCtrls, RzBckgnd;

type
  TfrmPassword = class(TfrmBase)
    pnlPanel: TPanel;
    lblPassword: TLabel;
    rzPassword: TRzEdit;
    lblCase: TLabel;
    lblMessage: TLabel;
    pnlBack: TPanel;
    imgBankLinkB: TImage;
    btnOK: TButton;
    btnCancel: TButton;
    lblConfirm: TLabel;
    rzConfirm: TRzEdit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
    //Is256Color : Boolean;
    InCheckPasswordMode : boolean;
    RealPassword        : string;
  public
    { Public declarations }
  end;

  function EnterNewPassword( var NewPassword : string) : boolean;
  function EnterPassword( const Password : string) : boolean;

//******************************************************************************
implementation

  {$R *.DFM}

uses
  ecColors,
  ecMessageBoxUtils,
  WinUtils, ImagesFrm, MainFrm, INISettings, NotesHelp;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EnterNewPassword( var NewPassword : string) : boolean;
begin
  Result := false;
  with TfrmPassword.Create( Application) do
  begin
    try
      InCheckPasswordMode := false;
      lblMessage.caption  := 'Please enter the new password for access to this file. '+
                             'Leave the password blank to clear an existing password.';
      lblPassword.caption := '&New Password';
      rzPassword.PasswordChar := #$9F;
      rzConfirm.PasswordChar := #$9F;      
      if ShowModal = mrOK then
      begin
        NewPassword := rzPassword.Text;
        Result := true;
      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EnterPassword( const Password : string) : boolean;
begin
  Result := false;
  with TfrmPassword.Create( Application) do
  begin
    try
      InCheckPasswordMode := true;
      rzPassword.PasswordChar := '*';
      lblMessage.caption := 'A password is required to open this file.';
      lblPassword.caption := '&Enter Password';
      lblCase.Caption := '(Passwords are Case Sensitive)';
      rzPassword.PasswordChar := #$9F;
      rzPassword.MaxLength := 0;
      lblCase.Top := lblCase.Top - rzConfirm.Height;
      lblCase.Left := rzPassword.Left;
      RzConfirm.Visible := False;
      lblConfirm.visible := False;
      RealPassword        := Password;
      if ShowModal = mrOK then
        Result := true;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPassword.btnOKClick(Sender: TObject);
begin
  inherited;
  if not RzConfirm.Visible then
    ModalResult := mrOk
  else if rzConfirm.Text <> rzPassword.Text then
  begin
    ErrorMessage('The passwords you have entered do not match. Please re-enter them.');
    rzPassword.SetFocus;
  end
  else
    ModalResult := mrOk;
end;

procedure TfrmPassword.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if ModalResult = mrOK then
  begin
    if InCheckPasswordMode then
    begin
      if ( rzPassword.text <> RealPassword) then
      begin
         ErrorMessage( 'Password is incorrect.  This file cannot be opened '+
                      'without a valid password.');
         rzPassword.SetFocus;
         rzPassword.SelectAll;
         CanClose := false;
         exit;
      end;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmPassword.FormShow(Sender: TObject);
const
  FORMWIDTHMIN = 320;
  FORMWIDTHMAX = 480;
  FORMHEIGHTMIN = 240;
  FORMHEIGHTMAX = 640;
var
  ImageRatio : Double;
begin
  inherited;
  //set the global constant for color depth
  //Is256Color := (WinUtils.GetScreenColors( Self.Canvas.Handle) <= 256);
  if (AppImages.imgLogo.Picture.Width > 0) then
    imgBankLinkB.Picture := AppImages.imgLogo.Picture
  else
  begin
    if (frmMain.Is256Color) then
      imgBankLinkB.Picture := ImagesFrm.AppImages.imgBankLinkLogo256.Picture
   else
      imgBankLinkB.Picture := ImagesFrm.AppImages.imgBankLinkLogoHiColor.Picture;
  end;

  if (ImgBankLinkB.Picture.Width > FORMWIDTHMAX) or
    (ImgBankLinkB.Picture.Height > (FORMHEIGHTMAX - pnlPanel.Top + 16)) then
  begin
    if (imgBankLinkB.Picture.Height < imgBankLinkB.Picture.Width) then
      ImageRatio := (imgBankLinkB.Picture.Height/imgBankLinkB.Picture.Width)
    else
      ImageRatio := (imgBankLinkB.Picture.Width/imgBankLinkB.Picture.Height);

    ImgBankLinkB.AutoSize := False;
    ImgBankLinkB.Stretch := True;

    ImgBankLinkB.Width := Trunc(ImgBankLinkB.Picture.Width * ImageRatio);
    ImgBankLinkB.Height := Trunc(ImgBankLinkB.Picture.Height * ImageRatio);
  end else
  begin
    ImgBankLinkB.Width := ImgBankLinkB.Picture.Width;
    ImgBankLinkB.Height := ImgBankLinkB.Picture.Height;
  end;
  if (ImgBankLinkB.Width + 16 < FORMWIDTHMIN) then
    ClientWidth := FORMWIDTHMIN + 16
  else
    ClientWidth := ImgBankLinkB.Width + 16;
  if ((ImgBankLinkB.Height + pnlPanel.Height + 16) < (FORMHEIGHTMIN + 16)) then
    ClientHeight := FORMHEIGHTMIN + 16
  else
    ClientHeight := ImgBankLinkB.Height + pnlPanel.Height + 16;

  ImgBankLinkB.Top := 8;
  if (AppImages.imgLogo.Picture.Width > 0) then
    ImgBankLinkB.Left := (ClientWidth div 2) - (ImgBankLinkB.Width div 2)
  else
    ImgBankLinkB.Left := 0;

  lblMessage.Width := Width - 16;

  BKHelpSetUp(Self, BKH_Password_protecting_a_transaction_file);  
end;

end.
