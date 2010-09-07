unit MailSettingsFrm;
//------------------------------------------------------------------------------
{
   Title:       Mail Settings Screen

   Description:

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  BaseFrm, StdCtrls, Mask, RzEdit, ExtCtrls;

type
  TfrmMailSettings = class(TfrmBase)
    Label1: TLabel;
    rbMAPI: TRadioButton;
    rbSMTP: TRadioButton;
    pnlSMTPUserInfo: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    rzName: TRzEdit;
    rzAddress: TRzEdit;
    pnlSMTPServerInfo: TPanel;
    Label12: TLabel;
    Label13: TLabel;
    lblUser: TLabel;
    lblPassword: TLabel;
    chkAuthReq: TCheckBox;
    rzsmtp: TRzEdit;
    rzuserId: TRzEdit;
    rzPassword: TRzEdit;
    btnCancel: TButton;
    btnOK: TButton;
    Label5: TLabel;
    rnSMTPPort: TRzNumericEdit;
    Label6: TLabel;
    rnTimeout: TRzNumericEdit;
    Label7: TLabel;
    procedure rbMAPIClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkAuthReqClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    procedure SetDesktopTheme;
    { Private declarations }
  public
    { Public declarations }
  end;

  function ConfigureMail : boolean;

//******************************************************************************
implementation
{$R *.DFM}
uses
   IniSettings,
   ecColors,
   ecMessageBoxUtils,
   NotesHelp;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMailSettings.SetDesktopTheme;
begin
  //pnlTop.Color := clBorderColor;
  //pnlLeft.Color := clBorderColor;
  //pnlRight.Color := clBorderColor;
  //pnlBottom.Color := clBorderColor;

  //Panel1.Color := eCColors.clLightPanel;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ConfigureMail : boolean;
begin
  Result := false;

  with TfrmMailSettings.Create( nil) do
  begin
    try
      SetDesktopTheme;

      //load all text boxes
      pnlSMTPUserInfo.Visible     := ( INI_MAIL_TYPE = mtSMTP);
      pnlSMTPServerInfo.visible   := ( INI_MAIL_TYPE = mtSMTP);
      rzName.Text      := INI_SMTP_FROMNAME;
      rzAddress.Text   := INI_SMTP_FROMADDR;
      rzsmtp.Text      := INI_SMTP_HOST;
      rnSMTPPort.IntValue := INI_SMTP_PORT;
      rnTimeout.IntValue  := INI_SMTP_TIMEOUT;
      chkAuthReq.Checked := INI_SMTP_PWDReqd;
      rzuserId.Text    := INI_SMTP_USERID;
      rzPassword.Text  := INI_SMTP_PWD;
      rzuserId.Enabled := chkAuthReq.Checked;
      rzPassword.Enabled := chkAuthReq.Checked;
      lblUser.enabled    :=chkAuthReq.Checked;
      lblPassword.enabled := chkAuthReq.Checked;

      rbMAPI.Checked   := ( INI_MAIL_TYPE = mtMAPI);
      rbSMTP.Checked   := ( INI_MAIL_TYPE = mtSMTP);

      if ( ShowModal = mrOK) then
      begin
        //save all text boxes
        if rbMAPI.Checked then
          INI_MAIL_TYPE := mtMAPI
        else
          INI_MAIL_TYPE := mtSMTP;

        //SMTP settings
        INI_SMTP_FROMNAME    := rzName.Text;
        INI_SMTP_FROMADDR    := rzAddress.Text;
        INI_SMTP_HOST        := rzsmtp.Text;
        INI_SMTP_PWDReqd     := chkAuthReq.Checked;
        INI_SMTP_PORT        := Round( rnSMTPPort.IntValue);
        INI_SMTP_TIMEOUT     := Round( rnTimeout.IntValue);

        if chkAuthReq.Checked then begin
          INI_SMTP_USERID   := rzuserId.Text;
          INI_SMTP_PWD      := rzPassword.Text;
        end
        else begin
          INI_SMTP_USERID   := '';
          INI_SMTP_PWD      := '';
        end;

        //MAPI Settings

      end;
    finally
      Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMailSettings.rbMAPIClick(Sender: TObject);
begin
   pnlSMTPUserInfo.Visible    := rbSMTP.Checked;
   pnlSMTPServerInfo.visible  := rbSMTP.Checked;

   if ( Self.visible) and (pnlSMTPServerInfo.visible) then
      rzName.SetFocus
   else
      ;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMailSettings.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
   if ModalResult = mrOK then begin
      if rbSMTP.Checked then begin
         if rzsmtp.text = '' then begin
            WarningMessage('You must specify the address of your mail server');
            rzsmtp.Setfocus;
            CanClose := false;
            exit;
         end;

         if rzAddress.text = '' then begin
            WarningMessage('You must specify an e-mail address');
            rzAddress.Setfocus;
            CanClose := false;
            exit;
         end;
      end;
   end;
end;
procedure TfrmMailSettings.FormCreate(Sender: TObject);
begin
  inherited;
  BKHelpSetUp(Self, BKH_Emailing_from_BankLink_Notes);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMailSettings.chkAuthReqClick(Sender: TObject);
begin
   rzUserId.enabled := chkAuthReq.Checked;
   rzPassword.Enabled := chkAuthReq.Checked;
   lblUser.enabled    :=chkAuthReq.Checked;
   lblPassword.enabled := chkAuthReq.Checked;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
