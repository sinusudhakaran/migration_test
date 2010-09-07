unit SendFrm;
//------------------------------------------------------------------------------
{
   Title:       Send Form

   Description: Send Mail form

   Remarks:

   Author:      Matthew Hopkins  Aug 2001

}
//------------------------------------------------------------------------------

interface

uses
  StdCtrls, Graphics, Classes, Mask, ExtCtrls, Forms, SysUtils, //Dialogs,
  BaseFrm, ipscore, ipssmtps, ImgList, Controls, RzSndMsg, ComCtrls,
  RzListVw, RzEdit, ecObj, ipsimaps, Dialogs;

type
  TfrmSend = class(TfrmBase)
    RzSendMessage1: TRzSendMessage;
    ImageList1: TImageList;
    pnlMailBody: TPanel;
    pnlToEtc: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    rzTo: TRzEdit;
    rzSubject: TRzEdit;
    rbAttachfile: TRadioButton;
    rbJustSendText: TRadioButton;
    rzMemo: TRzMemo;
    rzAttachmentsView: TRzListView;
    pnlFooter: TPanel;
    lblStatus: TLabel;
    ipsSMTPS1: TipsSMTPS;        
    pnlTop: TPanel;
    pnlLeft: TPanel;
    pnlRight: TPanel;
    pnlBottom: TPanel;
    pnlHeader: TPanel;
    btnSettings: TButton;
    btnSend: TButton;
    btnClose: TButton;
    btnAttachFile: TButton;
    OpenDialog1: TOpenDialog;
    Image1: TImage;
    procedure rbtSendClick(Sender: TObject);
    procedure rbAttachFileClick(Sender: TObject);
    procedure rbtCloseCancelClick(Sender: TObject);
    procedure btnSettingsClick(Sender: TObject);
    procedure IdSMTP1Connected(Sender: TObject);
    procedure IdSMTP1Disconnected(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbtViewSentItemsClick(Sender: TObject);
    procedure btnAttachFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rzAttachmentsViewKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
    MyClientFile : TEcClient;
    SendWasOK    : boolean;
    CancelActive : boolean;
    AttachmentList : TStringList;
    FFileSubject: string;
    FMessageSubject: string;
    procedure SetDesktopTheme;
    procedure UpdateMailStatusText( aMsg : string);
  public
    { Public declarations }
  end;

  function SendMail(aClient: TEcClient; aSubject: string = ''): boolean;

//******************************************************************************
implementation

uses
   //IdException,
   Windows,
   ShellAPI,
   MAPI,
   INISettings,
   MailSettingsFrm,
   SysLog,
   ecColors,
   ecMessageBoxUtils,
   SentItems,
   DIMimeStreams,
   ecGlobalConst, ECDEFS, NotesHelp;

const
  CRLF = #13#10;

{$R *.DFM}

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.SetDesktopTheme;
begin
  pnlTop.Color := clBorderColor;
  pnlLeft.Color := clBorderColor;
  pnlRight.Color := clBorderColor;
  pnlBottom.Color := clBorderColor;
  //pnlToEtc.Color := ecColors.clLightPanel;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendMail(aClient: TEcClient; aSubject: string): boolean;
var
  NewItem : TListItem;
begin
  with TFrmSend.Create( Application) do
  begin
    MyClientFile               := aClient;
    rzTo.text                  := MyClientFile.ecFields.ecContact_EMail_Address;
    FFileSubject               := aSubject;
    rzSubject.Text             := FFileSubject;
    rbAttachFile.Checked       := true;
    rzAttachmentsView.Items.Clear;
    NewItem                    := rzAttachmentsView.Items.Add;
    NewItem.Caption            := ExtractFilename( MyClientFile.ecFields.ecFilename);
    NewItem.ImageIndex         := 0;
    SetDeskTopTheme;
    WindowState                := wsMaximized;

    ShowModal;

    result := SendWasOK;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.rbtSendClick(Sender: TObject);
var
  i : Integer;
  EMsg, AttachmentName : String;
  Separator : String;
  InputStream : TMemoryStream;
  AttachStream : TStringStream;
  sMessage : string;
  sHeader : string;
begin
   //verify required fields are present
   if (rzTo.Text = '') then begin
      ErrorMessage('There must be at least one name in the To box.');
      rzTo.SetFocus;
      exit;
   end;

   btnSend.Enabled          := false;
   btnAttachFile.Enabled    := false;
   btnSettings.Enabled      := false;
   btnClose.Caption         := '&Cancel';
   CancelActive             := true;
   pnlMailBody.Enabled      := false;
   EMsg                     := '';
   SendWasOK                := false;
   try
      if ( INI_MAIL_TYPE = mtMAPI) then begin
         with rzSendMessage1 do begin
            ClearLists;
            Review := false;
            ToRecipients.Add( rzTo.Text);
            Subject := rzSubject.Text;
            if rbAttachFile.Checked then begin
              Attachments.Add( MyClientFile.ecFields.ecFilename);
            end;

            for i := 0 to AttachmentList.Count-1 do
              Attachments.Add( AttachmentList[i]);

            try
               Send;

               Application.ProcessMessages;

               Logoff;
               SendWasOK := true;
            except
               on E : EMapiError do begin
                  case E.ErrorCode of
                     MAPI_E_UNKNOWN_RECIPIENT,
                     MAPI_E_BAD_RECIPTYPE,
                     MAPI_E_AMBIGUOUS_RECIPIENT,
                     MAPI_E_INVALID_RECIPS : begin
                        EMsg := 'Recipient List is not valid';
                     end;
                     MAPI_E_NOT_SUPPORTED : begin
                        EMsg := 'You do not have a MAPI compliment application (such as Outlook) '+
                                'installed on your workstation.'#13#13 +
                                'You should click "Settings" above an change your preferred mail '+
                                'method to SMTP';
                     end;
                  else
                     EMsg := E.Message;
                  end;
               end;

               on E : EInOutError do begin
                  EMsg := 'File exception ' + E.Message;
               end;
            end;

            if not SendWasOK then begin
               ErrorMessage( 'Send failed because of error - ' +#13#13+ EMsg);
               SysLog.ApplicationLog.LogError( 'Send Mail Error - ' + EMsg)
            end
            else begin
               InfoMessage('Mail successfully placed in outbox');
               Close;
            end;
         end;
      end else
      begin
        //setup SMTP component;
        try
          ipsSMTPS1.ResetHeaders;
          ipsSMTPS1.SSLStartMode := ipssmtps.sslNone;  //turn OFF SSL
          ipsSMTPS1.MailServer := INI_SMTP_HOST;  //will cause dns lookup

          if INI_SMTP_PORT <= 0 then
            INI_SMTP_PORT := 25;
          if INI_SMTP_TIMEOUT <= 0 then
            INI_SMTP_TIMEOUT := 60;
          ipsSMTPS1.MailPort := INI_SMTP_PORT;
          if INI_SMTP_PWDReqd then
          begin
            ipsSMTPS1.User := INI_SMTP_USERID;
            ipsSMTPS1.Password := INI_SMTP_PWD;
          end else
          begin
            ipsSMTPS1.User := '';
            ipsSMTPS1.Password := '';
          end;

          //build message
          ipsSMTPS1.Subject := rzSubject.Text;
          ipsSMTPS1.SendTo := rzTo.Text;
          ipsSMTPS1.From := INI_SMTP_FROMADDR;
          sMessage := '';
          sHeader := '';
          if rbAttachFile.Checked then
          begin
            //Message has attachments, need to construct a separtor string
            //additional header lines are required to tell system that this
            //is a multi part message

            //make a random separator string
            Separator := '--=_nextpart_';
            Randomize;
            i := 10 + Random(10); //at least 10 characters
            while (i > 0) do
            begin
              Separator := Separator + Chr(48 + Random(10));
              Dec(i);
            end;

            sHeader := 'MIME-Version: 1.0' + CRLF +
                    'Content-Type: multipart/mixed; boundary="' + Separator + '"' + CRLF +
                    'X-Mailer: ' + APP_NAME + CRLF +
                    CRLF +
                    'This is a multi-part message in MIME format.'+ CRLF +
                    CRLF;

            //build message text
            sMessage := '--' + Separator + CRLF +
                        'Content-Type: text/plain' + CRLF +
                        'Content-Transfer-Encoding: quoted-printable' + CRLF + CRLF +
                        rzMemo.Text;

            InputStream := TMemoryStream.Create;
            try
              AttachmentList.Add(MyClientFile.ecFields.ecFilename);
              //attach files
              for i := 0 to AttachmentList.Count-1 do
              begin
                AttachStream := TStringStream.Create('');
                try
                  InputStream.Clear;
                  InputStream.LoadFromFile(AttachmentList[i]);
                  MimeEncodeStream(InputStream, AttachStream);
                  sMessage := sMessage + CRLF +
                              '--' + Separator + CRLF +
                              'Content-Type: application/octet-stream; name="' +  ExtractFilename(AttachmentList[i]) + '"' + CRLF +
                              'Content-Transfer-Encoding: base64' + CRLF +
                              CRLF +
                              AttachStream.DataString;
                finally
                  AttachStream.Free;
                end;
              end;
            finally
              InputStream.Free;
            end;
            //add closing separator
            sMessage := sMessage +CRLF +
                        CRLF +
                        '--' + Separator + '--' + CRLF;
          end
          else
          begin
            //no attachments, just send body
            sHeader := 'MIME-Version: 1.0' + CRLF +
                       'Content-Type: text/plain; Content-Transfer-Encoding: quoted-printable'+ CRLF +
                       'X-Mailer: ' + APP_NAME + CRLF +
                       CRLF;
            sMessage := rzMemo.Text;
          end;
        except
          //exceptions could be raised constructing the email, or setting
          //server.  this will cause a dns lookup to get the ip address
          On E : EipsSMTPS do
          begin
            if E.Code = 11004 then
              EMsg := 'Could not find "' + INI_SMTP_HOST + '".  Please ensure this is a valid address.'
            else
              EMsg := 'Error connecting to mail server. ' + E.message + ' [' +
                      E.ClassName+ ']';

            ErrorMessage( EMsg);
            SysLog.ApplicationLog.LogError( 'Send Mail Error - ' + EMsg);
            Exit;
          end;

          On E : Exception do
          begin
            EMsg := 'Error preparing email message. ' + E.message + ' [' +
                      E.ClassName+ ']';

            ErrorMessage( EMsg);
            SysLog.ApplicationLog.LogError( 'Send Mail Error - ' + EMsg);
            Exit;
          end;
        end;

        //smtp component initialised, message has been constructed
        //send message
        UpdateMailStatusText( 'Connecting');
        EMsg := '';
        try
          try
            ipsSMTPS1.Timeout := INI_SMTP_TIMEOUT; //60 sec
        //*******************
            ipsSMTPS1.Connect;
        //*******************
            if (ipsSMTPS1.Connected) then
            begin
              UpdateMailStatusText( 'Sending Message 1 of 1');

              //set timeout to 30 min, effectively no timeout so that email is
              //sent in time
              ipsSMTPS1.Timeout := 1800; //60 sec
              ipsSMTPS1.OtherHeaders := sHeader;
              ipsSMTPS1.MessageText := sMessage;
              ipsSMTPS1.Send;
              SendWasOK := true;
            end;
          except
            on E : EipsSMTPS do
            begin
              case E.Code of
                162 : EMsg := 'Cannot connect to the specified mail server (' +
                                  INI_SMTP_HOST  + ')';
              else
                EMsg := E.Message + ' [' + E.Classname + ']';
              end;
            end;
            //file exceptions
            on E : EInOutError do begin
              EMsg := E.Message + '[' + E.Classname + ']';
            end;
          end;
        finally
          if ipsSMTPS1.Connected then
          begin
            UpdateMailStatusText( 'Disconnecting');
            ipsSMTPS1.Timeout := INI_SMTP_TIMEOUT; //60 sec
            ipsSMTPS1.Disconnect;
          end;
          ipsSMTPS1.Interrupt;

          if not SendWasOK then begin
            ErrorMessage( 'Send failed because of error - ' + EMsg);
            SysLog.ApplicationLog.LogError( 'Send Mail Error - ' + EMsg);

            if rbAttachFile.checked then
              AttachmentName := ExtractFilename( MyClientFile.ecfields.ecFilename)
            else
              AttachmentName := '';

          end
          else begin
            InfoMessage( 'Mail sent successfully');
            //update the sent items list
            Close;
          end;
          //Log outcome
          SentItems.AddToSendItemsFolder( rzTo.Text,
                                          rzSubject.Text,
                                          rzMemo.Text,
                                          AttachmentName,
                                          SendWasOK,
                                          EMsg);
        end;
      end;
   finally
      UpdateMailStatusText( '');
      pnlMailBody.Enabled      := true;
      btnSend.Enabled          := true;
      btnSettings.Enabled      := true;
      btnClose.Caption         := '&Close';
      btnClose.Cancel          := false;
      btnAttachFile.Enabled    := true;
      CancelActive             := false;

      if EMsg = '' then btnClose.SetFocus;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.rbAttachFileClick(Sender: TObject);
begin
  //rzAttachmentsView.Visible := rbAttachFile.Checked;
  if (rbAttachFile.Checked) then
  begin
    TListItem(rzAttachmentsView.Items[0]).Caption := ExtractFilename( MyClientFile.ecFields.ecFilename);
    TListItem(rzAttachmentsView.Items[0]).ImageIndex := 0;
    FMessageSubject := rzSubject.Text;
    rzSubject.Text := FFileSubject;
  end else
  begin
    TListItem(rzAttachmentsView.Items[0]).Caption := '';
    TListItem(rzAttachmentsView.Items[0]).ImageIndex := -1;
    FFileSubject := rzSubject.Text;
    rzSubject.Text := FMessageSubject;    
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.rbtCloseCancelClick(Sender: TObject);
begin
  inherited;
  if CancelActive then begin
    if ipsSMTPS1.Connected then
      ipsSMTPS1.Disconnect
    else
      ipsSMTPS1.Interrupt;
  end
  else
     Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.btnSettingsClick(Sender: TObject);
begin
  ConfigureMail;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.IdSMTP1Connected(Sender: TObject);
begin
   UpdateMailStatusText( 'Connected');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.UpdateMailStatusText(aMsg: string);
begin
   if aMsg <> '' then
      lblStatus.caption := aMsg + '...'
   else
      lblStatus.caption := '';
   lblStatus.Refresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.IdSMTP1Disconnected(Sender: TObject);
begin
   UpdateMailStatusText( 'Disconnected');
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmSend.FormCreate(Sender: TObject);
begin
  inherited;
  AttachmentList := TStringList.Create;
  CancelActive := false;
  BKHelpSetUp(Self, BKH_Chapter_4_Returning_Notes_files);
  FFileSubject := '';
  FMessageSubject := '';
end;

procedure TfrmSend.rbtViewSentItemsClick(Sender: TObject);
begin
   //ShowMessage('View Send Items');
end;

procedure TfrmSend.btnAttachFileClick(Sender: TObject);
var
  aSHFi: TSHFileInfo;
  NewItem : TListItem;
begin
  inherited;
  with OpenDialog1 do
  begin
    DefaultExt   := '*.*';
    Filename     := '*.*';
    Filter       := 'All Files|*.*';
    Options      := [ ofHideReadOnly, ofShowHelp, ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
    Title        := 'Insert File';
    if Execute then
    begin
      AttachmentList.Add(Filename);
      //causes the icon to be retrieved
      SHGetFileInfo(PChar(Filename), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON );
      Image1.Picture.Icon.Handle := aSHFi.hIcon;
      ImageList1.AddIcon(Image1.Picture.Icon);

      NewItem                    := rzAttachmentsView.Items.Add;
      NewItem.Caption            := ExtractFilename( Filename);
      NewItem.ImageIndex         := ImageList1.Count-1;
    end;
  end;
end;

procedure TfrmSend.FormDestroy(Sender: TObject);
begin
  inherited;
  AttachmentList.Free;
end;

procedure TfrmSend.rzAttachmentsViewKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  i : Integer;
begin
  inherited;
  case Key of
    VK_DELETE, VK_BACK :
      begin
        //don't delete the first file as this is the BNotes work file
        if (TRzListView(Sender).Items.Count > 1) and (TRzListView(Sender).SelCount > 0) then
        begin
          i := TListItem(TRzListView(Sender).Selected).Index;
          AttachmentList.Delete(i-1);
          while (i < TRzListView(Sender).Items.Count -1) do
          begin
            TListItem(TRzListView(Sender).Items[i]).Caption := TListItem(TRzListView(Sender).Items[i+1]).Caption;
            TListItem(TRzListView(Sender).Items[i]).ImageIndex := TListItem(TRzListView(Sender).Items[i+1]).ImageIndex;
            Inc(i);
          end;
          TListItem(TRzListView(Sender).Items[i]).Delete;
        end;
      end;
  end;
end;

end.
