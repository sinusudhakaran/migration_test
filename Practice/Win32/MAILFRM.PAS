Unit MailFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:   Mail Form

  Written:
  Authors:

  Purpose:  Send Email to specified address, may contain attachments

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Interface

Uses
  Windows, Classes, Graphics, Controls, forms, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, ImgList, SendEmail,
  Menus, RzButton, ActnList,wpDefActions,SchedRepUtils,
    Admin32,
    SYDEFS,
  WPRTEDefs, WPCTRMemo, WPCTRRich, WPRuler, WPTbar,
   OsFont, RTFEditFme, ApplicationUtils, DirUtils;

Type
  TfrmMail = Class (Tform)
    sbMail       : TStatusBar;
    ImageList1: TImageList;
    OpenDialog1: TOpenDialog;
    popAttachments: TPopupMenu;
    AttachOtherFile1: TMenuItem;
    N1: TMenuItem;
    pmiDelete: TMenuItem;
    pnlFooter: TPanel;
    chkCheckout: TCheckBox;
    btnSend: TButton;
    btnCancel: TButton;
    ActionList1: TActionList;
    actClientFile: TAction;
    actAttach: TAction;
    pmTo: TPopupMenu;
    pmCC: TPopupMenu;
    pnlMessage: TPanel;
    pcTop: TPageControl;
    TSEMail: TTabSheet;
    TSEdit: TTabSheet;
    pnlHeader: TPanel;
    lblMailTo: TLabel;
    lblReturn: TLabel;
    lblSubject: TLabel;
    lblCC: TLabel;
    Image1: TImage;
    lblAttachments: TLabel;
    txtRecipient: TEdit;
    eReturnAddr: TEdit;
    txtSubject: TEdit;
    txtCC: TEdit;
    btnAttach: TButton;
    btnAttachClient: TButton;
    btnMailTo: TRzMenuButton;
    btnCC: TRzMenuButton;
    lvAttach: TListView;
    Editor: TfmeEditRTF;
    lvClientFiles: TListView;
    lblClientFiles: TLabel;
    popClientFiles: TPopupMenu;
    MenuItem1: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;

    procedure btnSelectClick(Sender: TObject);
    procedure formCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnSendClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure lvAttachKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
    procedure sbtnAttachClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actClientFileExecute(Sender: TObject);
    procedure actAttachExecute(Sender: TObject);
    procedure pmiDeleteClick(Sender: TObject);
    procedure popAttachmentsPopup(Sender: TObject);
    procedure lvAttachEnter(Sender: TObject);
    procedure pmSelectEmail(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure txtRecipientExit(Sender: TObject);
    procedure lvAttachDblClick(Sender: TObject);
    procedure ERichTextMailMergeGetText(Sender: TObject; const inspname: string; Contents: TWPMMInsertTextContents);
    procedure lvClientFilesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvClientFilesEnter(Sender: TObject);
    procedure popClientFilesPopup(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure TSEditContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure EditorERTFHyperLinkEvent(Sender: TObject; text, url: string;
      IgnoredNumber: Integer);


  Private
      { Private declarations }
    MailObj     : TMailModule;
    MailSentOK  : boolean;
    SendingMail : boolean;
    FShowPracDetails: Boolean;
    AttachmentList : TStringList;

    fBodyText: TStringList;
    BNotesAttachSent: Boolean;
    BNotesFile: string;
    ClientList: TStringList;
    FAllowCheckOutToSupport: Boolean;

    ClientFileExpected, FHideDropDowns : boolean;
    FEditMode: Boolean;
    FAutomatic: Boolean;
    fBodyMerged: Boolean;
    FMultipleRecipientsList: TStringList;
    procedure DisableForm;
    procedure EnableForm;
    procedure DoAttachClientFile;
    procedure DoDeleteSelected(AListView: TListView);
    procedure DoAttachFile;
    procedure DoSendMail;
    function SignatureFilename: string;
    procedure DoSave;

    function OffsiteSendMail( BK5Files, OtherAttachments : TStringList; CheckoutClientFiles : boolean; WasOpenCode: string) : boolean;
    function PracticeSendMail( BK5Files, OtherAttachments : TStringList; CheckoutClientFiles : boolean; WasOpenCode: string) : boolean;
    function CreateMailObjectAndSend(ToAddresses, CCAddresses, ReplyTo,
                                     aSubject,MessageBody: string; AttachmentsList: TStringList;
                                     StatusChangeMethod: TStatusChangeMeth): boolean;
    function SendEmail64Bit(const aCmdLineParams : string) : Cardinal;
    function GenerateRndFileName : string;                                     
    procedure SetupUI;
    procedure SaveFailedEmail(Attachments: TStringList);

    procedure LoadSignature;
    procedure SetBodyText(const Value: string);
    procedure SetEditMode(const Value: Boolean);
    procedure MergeText;

    procedure HideClientFiles;

  protected
    procedure AddBitmap(aImageList: TImageList; aBmp: TBitmap; aBkColor: TColor);

    function IsEmailAddressSupport(aEmail : string) : boolean;

  Public
    procedure ReplaceMailBodyConstants(ReplaceStrings: TStringList);
    procedure UpdateStatus(Sender : TObject; Status: string);
    { Public declarations }
    function Execute: boolean;
    property EditMode: Boolean read FEditMode write SetEditMode;
    property HideDropDowns: Boolean read FHideDropDowns write FHideDropDowns;
    property AllowCheckOutToSupport: Boolean read FAllowCheckOutToSupport write FAllowCheckOutToSupport;
    property BodyText: string write SetBodyText;
    procedure AddLine(Value: string);
    procedure NewMessage;
  end;

function SendClientFileTo(Recipient: string; CodesToSend: string = '') : boolean;

function SendMailToSupport(Recipient: string) : boolean;

function SendMailTo (Title: string; Recipient: string; Subject: string;
                     Body: string; Attachment: string = '';
                     ShowPracDetails: Boolean = True;
                     MultipleRecipients: string = '') : boolean;

function SendFilesTo(Title: string; Recipient: string; Subject: string; Body: string; Attachments: TStringlist) : boolean;

function SendClientAndOtherFilesTo(Title: string; Recipient: string; Subject: string; Body: string;
                                   Attachments: TStringlist;
                                   BK5Attachments: TStringList;
                                   CheckOut: Boolean) : boolean;

function SendFileTo(Title: string; Recipient: string; Subject: string;
                    Filename: string; var AttachSent: Boolean; CanSelectClient:
                    boolean = true; HideClientEmail: Boolean = False;
                    GetTemplateFromRes:Boolean=False;
                    ReplaceStrings:TStringList=nil): boolean;

function EditSignature: Boolean;

function SendSceduledEmail(EmailList: tList; srOptions : TSchReportOptions): Boolean;

function GetSupportEmailAddress : string;

resourcestring
  rsMAPI_X64EXE_NOT_FOUND = 'Unable to email as the mapi64bit.exe application could '#13#10'not be found in the Practice directory.'#13#10#13#10 +
                            'Please contact Support for assistance.';

//******************************************************************************
Implementation

Uses
  strUtils,
  Clipbrd,
  GlobalMergeFields,
  UBatchBase,
  StatusFrm,
  UsageUtils,
  SysUtils,
  BK5Except,
  BKHelp,
  bkXPThemes,
  ShellAPI,
  CheckInOutFrm,
  Globals,
  GlobalCache,
  ClientDetailCacheObj,
  glConst,
  Progress,
  imagesfrm,
  ErrorMoreFrm,
  WarningMoreFrm,
  InfoMoreFrm,
  bkUtil32,
  YesNoDlg,
  PracticeLogo,
  ToDoHandler,
  files,
  Merge32,
  ChkProgressFrm,
  clObj32,
  bkconst,
  LogUtil,
  WinUtils,
  BKDEFS,
  StDate,
  bkDateUtils,
  ClientHomePageFrm,
  ThirdPartyHelper,
  bkBranding,
  bkProduct,
  bkContactInformation;

{$R *.DFM}

Const
   UnitName = 'MAILFRM';
   tmpExt = '.rtf';  // Template extention

Var
   DebugMe : boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetSupportEmailAddress : string;
//banklink support should only be used if is being run by a practice,
//otherwise use accountants address
begin
   result := '';

   if Assigned( AdminSystem) then
     result := TContactInformation.SupportEmail[ AdminSystem.fdFields.fdCountry ]
   else
   if ThirdPartyDLLDetected and ( ThirdPartySupportName <> '') then
   begin
     result := ThirdPartySupportEmail;
   end
   else
   begin
      if Assigned( MyClient) then begin
         result := MyClient.clFields.clPractice_EMail_Address;
      end;
   end;
end;

// If sending fails then save it and recover next time
procedure TfrmMail.SaveFailedEmail(Attachments: TStringList);
begin
  Email_Saved := True;
  Email_To := txtRecipient.Text;
  Email_From := eReturnAddr.Text;
  Email_Cc := txtCC.Text;
  Email_Body := Editor.ERTF .AsANSIString('RTF');
  Email_Attachments := Attachments.Text;
  Email_Subject := txtSubject.Text;
  Email_Checkout_File := chkCheckout.Checked;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TfrmMail.CreateMailObjectAndSend( ToAddresses, CCAddresses, ReplyTo, aSubject, MessageBody : string;
                                   AttachmentsList : TStringList;
                                   StatusChangeMethod : TStatusChangeMeth) : boolean;
var
  i : integer;
  sMsg : string;

begin
  Email_Saved := False;
  Email_Body := '';// Less memory 
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //Create Mail Object and message
  //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  if DebugMe then
     LogUtil.LogMsg(lmInfo, UnitName, 'Create MailModule');

  MailObj := TMailModule.Create(Application);
  try
     with MailObj do begin
        //Assign Status Procedural Pointer
        OnStatusChangeMeth := StatusChangeMethod;
        //Build Message
        NewMessage;
        with AdminSystem.fdFields do begin
           FromName  := GlobalCache.cache_Current_Username;
           FromAddr  := ReplyTo;
           //split string into lines
           ParseRecipients( ToAddresses, Recipients);
           if CCAddresses <> '' then
             ParseRecipients( CCAddresses, CarbonCopy);

           Subject := aSubject;
           Email   := Editor.ERTF;
           //Add additional lines with version info and practice/client details. If we can find the version
           //string in the email text then this means we're attempting to resend a message which failed
           //earlier, which means we don't need to add a signature because it will already have it
           if FShowPracDetails and (AnsiPos(WinUtils.GetAppVersionStr, MailObj.Email.Text) = 0) then begin
                AddLine(' ');
                AddLine(' ');
                AddLine(APPTITLE + ' ' + WinUtils.GetAppVersionStr);
                //see if email is being sent to support. If so add practice code and name
                if IsEmailAddressSupport( ToAddresses) then
                begin
                   AddLine('Path '+ExecDir);
                   if RefreshAdmin then begin   //refresh will fail if no admin exists
                      with AdminSystem.fdFields do
                         AddLine('Practice '+fdBankLink_Code+' '+fdPractice_Name_for_Reports);
                   end
                end
                //add client of info
                else begin
                   if Assigned(MyClient) then with MyClient.clFields do begin
                      AddLine('Client of: '+clPractice_Name);
                   end;
                end;
           end;
           //Attach files
           for i := 0 to AttachmentsList.Count - 1 do begin
              Attachments.Add(AttachmentsList[i]);
           end;
        end;

    //Send the mail
    result := false;
    try
       SendingMail         := true;
       Screen.Cursor       := crHourGlass;
       DisableForm;
       try
          //Connect, Send Mail, Disconnect
          if Connect then begin
             //Send Message(s)
             SendMail;
             // processmessages is needed for Windows XP and Office XP
             // to stop this application from locking up
             Application.ProcessMessages;
             result := true;
             Disconnect;
          end
          else begin
             //Should only get here if Connect failed without causing an exception
             //Could be because User aborted the connect, raise so that will be handled
             //like all the others
             raise EMailConnectFailed.Create('');
          end;
       finally
          Screen.Cursor       := crDefault;
          SendingMail         := false;
          EnableForm;
       end;
    //Handle exceptions from Mail Object
    except
       on e: EMailConnectFailed do begin
          sMsg := 'Unable to Send Mail. Connection Failed:'#13+ e.Message ;
          LogUtil.LogMsg( lmError, UnitName, sMsg);
          HelpfulErrorMsg( sMsg,0,false);
          SaveFailedEmail(AttachmentsList);
       end;
       on e: EMailDisconnectFailed do begin
          //Just log it.  Don't need to tell user.  Connection should be
          //terminated when object is freed
          sMsg := 'Disconnect Failed:'#13 + e.Message;
          LogUtil.LogMsg( lmError, UnitName, sMsg);
       end;
       //if mail cannot be sent an exception will be raised
       on e: EMailSendFailed do begin
          sMsg := 'Unable to Send Mail:'#13+e.Message;
          LogUtil.LogMsg( lmError, UnitName, sMsg);
          HelpfulErrorMsg( sMsg,0, false);
          SaveFailedEmail(AttachmentsList);
       end;
    end;
  end;
  finally
    MailObj.Free;
    MailObj := nil;
    Screen.Cursor := crDefault;
  end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.formCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  AttachmentList := TStringList.Create;
  FMultipleRecipientsList := TStringList.Create;
  fBodyText := TStringList.Create;
  FHideDropDowns := False;
  lvAttach.items.Clear;
  lvClientFiles.Clear;
  //MessageText.Lines.Clear;

  lblReturn.visible   := (INI_Mail_Type = SMTP_MAIL);
  eReturnAddr.visible := (INI_Mail_Type = SMTP_MAIL);
  eReturnAddr.text    := INI_SMTP_From;
  lblSubject.Top := 69;
  txtSubject.Top := 66;
  if lblReturn.Visible then
  begin
    {For giving space to lblreturn}
    lblSubject.Top := 69 + 2;
    txtSubject.Top := 66 + 2;
  end;

  if not eReturnAddr.Visible then begin
    pcTop.Height := PCTop.Height - 24;
  end;

  txtSubject.text     := '';
  txtRecipient.text   := '';
  txtCC.text := '';

  BNotesAttachSent := False;
  BNotesFile := '';

  FShowPracDetails := True;
  FAllowCheckOutToSupport := False;

  if TProduct.ProductBrand = btBankLink then
  begin
    ImageList1.Add(Image1.Picture.Bitmap, nil);
  end
  else
  begin
    AddBitmap(ImageList1, bkBranding.ProductIcon16x16.Bitmap, clWhite);
  end;

  SetUpHelp;
  FAutomatic := False;
 
  LoadSignature;
  ClientList := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.SetupUI;
var
  ContactName,
  ContactEmail,
  ContactPhone,
  WebsiteAddress, Code : string;
  mi : TMenuItem;
  i: Integer;
  SysClientRec : pClient_File_Rec;
  TempClient : TClientObj;
begin
  //build pop up
  if Assigned(ClientList)
  and Assigned(AdminSystem) then // Add all client emails
     begin
    btnMailTo.Visible := true;
    btnCC.Visible := true;

    lblMailTo.Visible := false;
    lblMailTo.Enabled := false;
    lblCC.Visible := false;
    lblCC.Enabled := false;

    if (ClientList.Count = 1) then // single client - add practice details from the client
    begin
      OpenAClientForRead( ClientList[0], TempClient);
      if Assigned( TempClient) then
      begin
        bkUtil32.GetPracticeContactDetails( TempClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);
        if ContactEmail <> '' then
        begin
          mi := TMenuItem.Create(pmTo);
          mi.Name := 'pmiContactEmail';
          mi.Caption := ContactName + #9 + '  ' + ContactEmail;
          mi.OnClick := pmSelectEmail;
          pmTo.Items.Add( mi);
        end;

        if ( TempClient.clFields.clPractice_EMail_Address <> '') and ( TempClient.clFields.clPractice_EMail_Address <> ContactEmail) then
        begin
          mi := TMenuItem.Create(pmTo);
          mi.Name := 'pmiPracticeEmail';
          mi.Caption := TempClient.clFields.clPractice_Name + #9 + '  ' + TempClient.clFields.clPractice_EMail_Address;
          mi.OnClick := pmSelectEmail;
          pmTo.Items.Add( mi);
        end;
        TempClient.Free;
        TempClient := nil;
        mi := TMenuItem.Create(pmTo);
        mi.Name := 'pmiN2';
        mi.Caption := '-';
        pmTo.Items.Add( mi);
      end;
    end;

    for i := 0 to Pred(ClientList.Count) do
    begin
      Code := ClientList[i];
      sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code);
      if Assigned( sysClientRec) then
        with ClientDetailsCache do
        begin
          Load( sysClientRec.cfLRN);
          if Email_Address <> '' then
          begin
            mi := TMenuItem.Create(pmTo);
            mi.Caption := Name + #9 + '  ' + EMail_Address;
            mi.Name := 'pmiClientEmail' + IntToStr(i);
            mi.OnClick := pmSelectEmail;
            pmTo.Items.Add( mi);
          end;
        end;
    end;

    if Assigned( AdminSystem) then
    begin
      if pmTo.Items.Count > 0 then
      begin
        mi := TMenuItem.Create(pmTo);
        mi.Name := 'pmiN1';
        mi.Caption := '-';
        pmTo.Items.Add( mi);
      end;

      mi := TMenuItem.Create(pmTo);
      mi.Caption := '&'+SHORTAPPNAME + ' Support'#9 +'  ' + GetSupportEmailAddress;
      mi.Name := 'pmiSupportEmail';
      mi.OnClick := pmSelectEmail;
      pmTo.Items.Add( mi);
    end;
   //create same menu structure for the cc button
   for i := 0 to pmTo.Items.Count - 1 do
   begin
     mi := TMenuItem.Create(pmCC);
     mi.Caption := pmTo.Items[i].Caption;
     mi.Name := pmTo.Items[i].Name + '_cc';
     mi.OnClick := pmSelectEmail;

     pmCC.Items.Add( mi);
   end;
  end
  else if (not Assigned(ClientList)) and Assigned( MyClient) and (not HideDropDowns) then
  begin
    btnMailTo.Visible := true;
    btnCC.Visible := true;

    lblMailTo.Visible := false;
    lblMailTo.Enabled := false;
    lblCC.Visible := false;
    lblCC.Enabled := false;

    bkUtil32.GetPracticeContactDetails( MyClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);

    if ContactEmail <> '' then
    begin
      mi := TMenuItem.Create(pmTo);
      mi.Name := 'pmiContactEmail';
      mi.Caption := ContactName + #9 + '  ' + ContactEmail;
      mi.OnClick := pmSelectEmail;
      pmTo.Items.Add( mi);
    end;

    if ( MyClient.clFields.clPractice_EMail_Address <> '') and ( MyClient.clFields.clPractice_EMail_Address <> ContactEmail) then
    begin
      mi := TMenuItem.Create(pmTo);
      mi.Name := 'pmiPracticeEmail';
      mi.Caption := MyClient.clFields.clPractice_Name + #9 + '  ' + MyClient.clFields.clPractice_EMail_Address;
      mi.OnClick := pmSelectEmail;
      pmTo.Items.Add( mi);
    end;

    if MyClient.clFields.clClient_EMail_Address <> '' then
    begin
      if pmTo.Items.Count > 0 then
      begin
        mi := TMenuItem.Create(pmTo);
        mi.Name := 'pmiN2';
        mi.Caption := '-';
        pmTo.Items.Add( mi);
      end;

      mi := TMenuItem.Create(pmTo);
      mi.Caption := MyClient.clFields.clName + #9 + '  ' + MyClient.clFields.clClient_EMail_Address;
      mi.Name := 'pmiClientEmail';
      mi.OnClick := pmSelectEmail;
      pmTo.Items.Add( mi);
    end;

    if Assigned( AdminSystem) then
    begin
      if pmTo.Items.Count > 0 then
      begin
        mi := TMenuItem.Create(pmTo);
        mi.Name := 'pmiN1';
        mi.Caption := '-';
        pmTo.Items.Add( mi);
      end;

      mi := TMenuItem.Create(pmTo);
      mi.Caption := '&'+SHORTAPPNAME + ' Support'#9 +'  ' + GetSupportEmailAddress;
      mi.Name := 'pmiSupportEmail';
      mi.OnClick := pmSelectEmail;
      pmTo.Items.Add( mi);
    end;

   {
    mi := TMenuItem.Create(Self);
    mi.Name := 'pmiOutlook';
    mi.Caption := 'Outlook Address Book...';
    pmTo.Items.Add( mi);
   }

   //create same menu structure for the cc button
   for i := 0 to pmTo.Items.Count - 1 do
   begin
     mi := TMenuItem.Create(pmCC);
     mi.Caption := pmTo.Items[i].Caption;
     mi.Name := pmTo.Items[i].Name + '_cc';
     mi.OnClick := pmSelectEmail;

     pmCC.Items.Add( mi);
   end;

  end else if (FMultipleRecipientsList.Count > 1) then begin
    //Banklink Online - Multiple client files sent from Books with conflicting email addresses
    if (FMultipleRecipientsList.Count = 1) then
      txtRecipient.Text := FMultipleRecipientsList[0]
    else
      for i := 0 to FMultipleRecipientsList.Count - 1 do begin
        mi := TMenuItem.Create(pmTo);
        mi.Name := 'pmiPracticeEmail' + IntToStr(i);
        mi.Caption := FMultipleRecipientsList.Strings[i];
        mi.OnClick := pmSelectEmail;
        pmTo.Items.Add( mi);
      end;
    //create same menu structure for the cc button
    for i := 0 to pmTo.Items.Count - 1 do
    begin
      mi := TMenuItem.Create(pmCC);
      mi.Caption := pmTo.Items[i].Caption;
      mi.Name := pmTo.Items[i].Name + '_cc';
      mi.OnClick := pmSelectEmail;
      pmCC.Items.Add( mi);
    end;
    btnMailTo.Visible := true;
    btnCC.Visible := true;
  end else begin
    btnMailTo.Visible := false;
    lblMailTo.Visible := true;
  end;


  ClientFileExpected := false;
end;
function TfrmMail.SignatureFilename: string;
begin
   Result:= Emaildir + 'Signature' +tmpExt;
end;

procedure TfrmMail.TSEditContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.FormDestroy(Sender: TObject);
begin
  FMultipleRecipientsList.Free;
  AttachmentList.Free;
  fBodyText.Free;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMail.SendEmail64Bit(const aCmdLineParams: string): Cardinal;
const
  MAPI64BIT = 'mapi64bit.exe';
var
  Rlst: LongBool;
  StartUpInfo: TStartUpInfo;
  ProcessInfo: TProcessInformation;
  s64bitAppPath : string;
begin
  Result := 1000;
  if FileExists(MAPI64BIT) then
  begin
    FillChar(StartUpInfo, SizeOf(TStartUpInfo), #0);
    with StartUpInfo do
    begin
      cb := SizeOf(TStartUpInfo);
      dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
      wShowWindow := SW_HIDE;
    end;

    s64bitAppPath := ExtractFileDir(Application.ExeName) + '\' + MAPI64BIT;
    s64bitAppPath := s64bitAppPath + aCmdLineParams;
    Rlst := CreateProcess(nil, PChar(s64bitAppPath + aCmdLineParams), nil, nil, false, REALTIME_PRIORITY_CLASS, nil, nil, StartUpInfo, ProcessInfo);
    if Rlst then
    with ProcessInfo do
    begin
      if WaitForSingleObject(hProcess, INFINITE) <> WAIT_TIMEOUT then
      begin
        GetExitCodeProcess(ProcessInfo.hProcess, Result);
        CloseHandle(hThread);
        CloseHandle(hProcess);
      end else
      begin
        Win32Check(Windows.TerminateProcess(hProcess,0));
        OpenProcess(PROCESS_TERMINATE, False, ProcessInfo.dwProcessId);
      end;
    end;
  end else
    HelpfulErrorMsg('Failed to send the email!', 0, False, rsMAPI_X64EXE_NOT_FOUND, True);
end;

procedure TfrmMail.SetBodyText(const Value: string);
begin
   fBodyText.Text := Value;
end;

procedure TfrmMail.SetEditMode(const Value: Boolean);
begin
  FEditMode := Value;
  Editor.EditMode := FEditMode;
  TSEdit.TabVisible := False;
  TSEMail.TabVisible := False;
  if FEditMode then begin
     pcTop.ActivePage := TSEdit;
     pcTop.Height := 0; // Could have some controls here...
     chkCheckout.Visible := False;
     btnSend.Caption := 'Save';
     HelpContext := BKH_Adding_and_editing_your_practice_email_signature;
  end else begin
     pcTop.ActivePage := TSEMail;
     chkCheckout.Visible := True;
     btnSend.Caption := 'Send';
     HelpContext := 0;
  end;
end;

procedure TfrmMail.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowformHints;
   Self.HelpContext := 0;
   //Components
   txtRecipient.Hint     :=
                         'Enter recipient''s Email address|' +
                         'Enter the Email address of the person who you want to send this Email to';
   txtSubject.Hint       :=
                         'Enter the subject of the Email|' +
                         'Enter the subject of the Email, this is optional';
   eReturnAddr.Hint      :=
                         'Enter your Return Email Address|' +
                         'Enter your Return Email Address in case the recipient wants to reply to you';
   btnAttach.Hint        :=
                         'Attach a file to this Email|' +
                         'Attach a file to this Email';
   Editor.ERTF.Hint      :=
                         'Enter your message here|' +
                         'Enter your message here';
   btnAttachClient.Hint        :=
                         'Attach a Client File(s) to this Email';
   chkCheckOut.Hint      :=
                         'Flag the selected Client File(s) as read-only in your system after sending|' +
                         'Flag the selected Client File(s) as read-only in your system after sending';
   btnSend.Hint          :=
                         'Send this Email|' +
                         'Send this Email';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.btnSelectClick(Sender: TObject);
begin

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.DoAttachClientFile;
Var
   CodeList : TStringList;
   i        : Integer;
   NewItem  : TListItem;
begin
   begin
      CodeList := TStringList.Create;
      try
        CodeList.Delimiter :=  ClientCodeDelimiter;
        CodeList.StrictDelimiter := True;
        CodeList.DelimitedText := SelectCodesToAttach( 'Select Client File(s) to Send');
        if CodeList.DelimitedText = '' then
          exit;

        //now have a list of clients, add each one to the list of attachments
        for i := 0 to CodeList.Count - 1 do
        begin
          if lvClientFiles.FindCaption(0, CodeList[i], false, true, false) = Nil then
          begin
            //not already in list
            NewItem := lvClientFiles.items.Add;
            NewItem.caption := CodeList[i];
            NewItem.SubItems.Add( DataDir + CodeList[i] + FILEEXTN); //full filename
            NewItem.SubItems.Add( FileExtn);
            NewItem.ImageIndex := FILES_NORMAL_BMP;
            IncUsage('Send Books');
          end;
        end;
      finally
        CodeList.Free;
      end { try };
   end;
   lvClientFiles.SetFocus;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMail.UpdateStatus(Sender : TObject; Status: string);
begin
   if Assigned(sbMail) then begin
      sbMail.simpleText := Status + ' ...';
      sbMail.Repaint;
   end;

   if DebugMe then begin
      LogUtil.LogMsg(lmDebug, UnitName, 'Send Mail Status ' + Status)
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMail.OffsiteSendMail( BK5Files, OtherAttachments : TStringList; CheckoutClientFiles : boolean; WasOpenCode: string) : boolean;
var
  Code, Msg : string;
  i, CheckOutDisabled : integer;
  Attachments : TStringList;
  MailSentOK : boolean;
  TempClient : TClientObj;
begin
  //add all bk5 attachments and other attachments into one list
  Attachments := TStringList.Create;
  try
    for i := 0 to Bk5Files.Count -1 do
      Attachments.Add( DataDir + bk5Files[i] + FILEEXTN);
    for i := 0 to OtherAttachments.Count -1 do
      Attachments.Add( OtherAttachments[i]);

    //send mail
    MailSentOK := CreateMailObjectAndSend( txtRecipient.Text, txtCC.Text, eReturnAddr.text, txtSubject.text,
                              Editor.ERTF.Text, Attachments, UpdateStatus);
  finally
    Attachments.Free;
  end;

  //after send mail
  Msg := '';
  CheckOutDisabled := 0;
  if MailSentOK then begin
    //Reopen bk5 files and mark as read only
    for i := 0 to BK5Files.Count - 1 do begin
      Code := BK5Files[i];
      IncUsage('Check Out Send');
      OpenAClient( Code, TempClient, true, false, true);
      if Assigned( TempClient) then begin
        if CheckoutClientFiles and TempClient.clFields.clDisable_Offsite_Check_Out then begin
          //Falg as read-only is diabled for this Client
          CloseAClient(TempClient);
          if Msg <> '' then
            Msg := Msg + #13;
          Msg := Msg + Code;
          Inc(CheckOutDisabled);
          LogUtil.LogMsg( lmInfo, Unitname, 'Cannot mark client file ' + CODE +
                         ' as read-only because the option is disabled');
        end else if (CheckoutClientFiles and not TempClient.clFields.clFile_Read_Only) or
                    TempClient.clFields.clForce_Offsite_Check_Out then begin
          //Close MyClient so that file has to be opened again as read-only
          if Assigned(MyClient) then
            if (TempClient.clFields.clCode = MyClient.clFields.clCode) then
              CloseClient;
          TempClient.clFields.clFile_Read_Only := true;
          //Decrement the file save count so it matches the sent file
          Dec(TempClient.clFields.clFile_Save_Count);
          //Save the Client file so that read only flag is saved
          CloseAClient( TempClient, True);
          LogUtil.LogMsg( lmInfo, Unitname, Code + ' Sent via email. File marked as read-only');
        end else if CheckoutClientFiles or TempClient.clFields.clForce_Offsite_Check_Out then begin
          //Client file already marked as read-only
          CloseAClient( TempClient);
          LogUtil.LogMsg( lmInfo, Unitname, Code + ' Sent via email. File marked as read-only');
        end else begin
          //Copy sent
          CloseAClient( TempClient);
          LogUtil.LogMsg( lmInfo, Unitname, Code + ' Sent copy via email');
        end;
      end else if CheckoutClientFiles then
        LogUtil.LogMsg(lmInfo,UnitName,' Could not mark ' + Code + ' as read-only');
    end;
  end;

  if CheckOutDisabled = 1 then
    HelpfulErrorMsg('Cannot mark client file ' + Msg + ' as read-only because the option is disabled', 0)
  else if CheckOutDisabled > 1 then
    HelpfulErrorMsg('The following client files cannot be marked as read-only because the option is disabled:' + #13 + Msg, 0);
  result := MailSentOK;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMail.PracticeSendMail( BK5Files, OtherAttachments : TStringList; CheckoutClientFiles : boolean; WasOpenCode: string) : boolean;
const
  ThisMethodName = 'PracticeSendMail';
var
  ProgressFrm : TFrmChkProgress;
  EncodedLogoString : string;
  Code : string;
  TempClient : TClientObj;
  CFRec : pClient_File_Rec;
  Attachments : TStringList;
  MailSentOK : boolean;
  i : integer;
  SkippedCount : integer;
  aMsg : string;

  //create process variables
  CmdString : string;
  AttachmentsStr : string;
  RTFFileBodyToSendPath : string;
begin
  //before send mail
  result := false;
  MailSentOK := false;
  SkippedCount := 0;

  //mark selected bk5 files as checkedout, embed logo if required
  ProgressFrm := TfrmChkProgress.Create(self);
  try
    ProgressFrm.Caption := 'Sending...';
    ProgressFrm.btnOK.Enabled := false;

    RefreshAdmin;
    if BK5Files.Count > 0 then begin
      EncodedLogoString := PracticeLogo.EncodePracticeLogo( AdminSystem.fdFields.fdPractice_Logo_Filename);
      if EncodedLogoString <> '' then
        SetUsage('Practice Logo', 1); 
    end else
      EncodedLogoString := '';

    Attachments := TStringList.Create;
    try
      if bk5Files.Count > 0 then
      begin
        if CheckoutClientFiles then
        begin
          i := 0;
          while ( i < BK5Files.Count) do
          begin
            Code := bk5Files[i];
            TempClient := nil;
            StatusSilent := true;
            try
              //open the client file so we can synchronise it before sending
              OpenAClient( Code, TempClient, true, false, True);
              if Assigned( TempClient) then
              begin
                SyncClientToAdmin( TempClient, false, true, true);
                SyncMasterMemorised( TempClient);
                EmbedCustomLogo( TempClient, EncodedLogoString);
                //store a marker to indicate that file is offsite, this allows
                //us to set the file status correctly for the admin system
                bk5Files.Objects[i] := TObject( TempClient.clFields.clDownload_From);

                //Make sure we sent the transfer method to email so that it works correctly when checked into books.
                TempClient.clExtra.ceFile_Transfer_Method := ftmEmail;

                CloseAClient( TempClient);
                //file ok, move on to next code
                i := i + 1;
              end
              else
              begin
                aMsg := 'Cannot open client ' + Code;
                ProgressFrm.mProgress.Lines.Add('Skipped ' + Code + ' ' + aMsg);

                LogUtil.logmsg( lmError, Unitname, ThisMethodname + ':' + aMsg);
                bk5Files.Delete(i); //remove from list of files to send
                Inc( SkippedCount);
              end;
            finally
              StatusSilent := false;
              TempClient.Free;
            end;
          end;

          //show progress window of any of the client files where skipped
          if SkippedCount > 0 then
          begin
            ProgressFrm.mProgress.Lines.Add( 'Errors occurred, abandoning send.');
            ProgressFrm.btnOK.Enabled := true;
            ProgressFrm.Hide;
            ProgressFrm.ShowModal;
            Exit;
          end;

          //mark each as read-only
          LoadAdminSystem( true, ThisMethodName);
          for i := 0 to BK5Files.Count - 1 do
          begin
            Code := bk5Files[i];
            CFRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code);
            if not Assigned( CFRec) then
              Raise EAdminSystem.Create( 'Could not find CFRec for ' + Code + ' [' + ThisMethodName + ']');
            //mark client file as read-only in admin system
            CFRec.cfCurrent_User := CurrUser.LRN;
            if Byte(bk5Files.Objects[i]) <> dlAdminSystem then
              CFRec.cfFile_Status := fsOffsite
            else
              CFRec.cfFile_Status := fsCheckedOut;
            AddAutomaticToDoItem( CFRec, ttyCheckOut, Format(ToDoMsg_Checkout, [bkDate2Str(CurrentDate)]));

            LogMsg( lmInfo, Unitname, ThisMethodName + ':' + Code + ' sent and marked as read-only');
          end;
          SaveAdminSystem;
        end;
      end;

      //send mail
      for i := 0 to BK5Files.Count - 1 do
        Attachments.Add( DataDir + BK5Files[i] + FileExtn);
      for i := 0 to OtherAttachments.Count -1 do
        Attachments.Add( OtherAttachments[i]);

      //send mail
      if (not IsWoW64) or (INI_Mail_Type = SMTP_MAIL) then
        MailSentOK := CreateMailObjectAndSend( txtRecipient.Text, txtCC.Text, eReturnAddr.text, txtSubject.text,
                                Editor.ERTF.Text, Attachments, UpdateStatus)
      else
      begin
        CmdString := '';
        if Trim(txtRecipient.Text) <> '' then
          CmdString := CmdString + ' -to '+ txtRecipient.Text;
        if Trim(txtCC.Text) <> '' then
          CmdString := CmdString + ' -cc '+ txtCC.Text;
        if Trim(txtSubject.text) <> '' then
          CmdString := CmdString + ' -subject ' + txtSubject.text;
        if Trim(Editor.ERTF.Text) <> '' then
        begin
          RTFFileBodyToSendPath := GenerateRndFileName;
          if FileExists(RTFFileBodyToSendPath) then
          begin
            DeleteFile(RTFFileBodyToSendPath);
            RTFFileBodyToSendPath := GenerateRndFileName;
          end;
          Editor.ERTF.SaveToFile(RTFFileBodyToSendPath);
          //Save the body to RTF to load it from external EXE and add it to body.
          //The file will be removed in external EXE
          CmdString := CmdString + ' -rtf '+ RTFFileBodyToSendPath;
        end;
        CmdString := CmdString + ' -ole true;';

        AttachmentsStr := '';
        if Attachments.Count > 0 then
        begin
          for i := 0 to Attachments.Count - 1 do
            AttachmentsStr := AttachmentsStr + Attachments.Strings[i] + ';';
        end;
        if AttachmentsStr <> '' then
          CmdString := CmdString + ' -att '+ AttachmentsStr;

      MailSentOK := SendEmail64Bit(PChar(CmdString)) = 0;
      end;
    finally
      Attachments.Free;
    end;

    //after send mail
    if (not MailSentOK) and (CheckoutClientFiles) and( bk5Files.Count > 0) then
    begin
      //undo the read-only out status for this bk5 files
      LoadAdminSystem( true, ThisMethodName);
        for i := 0 to bk5Files.Count - 1 do
        begin
          Code := bk5Files[i];
          cfRec := AdminSystem.fdSystem_Client_File_List.FindCode( Code);
          if Assigned( cfRec) then
          begin
            cfRec.cfFile_Status := fsNormal;
            cfRec.cfCurrent_User := 0;
            LogMsg( lmInfo, Unitname, ThisMethodName + ':' + Code + ' read-only reversed');
          end;
        end;
      SaveAdminSystem;
    end;

    result := MailSentOK;
  finally
    ProgressFrm.Release;
  end;
end;

{ReplaceStrings data should have a code=value format. So the function search
for each code and replace it with the value}
procedure TfrmMail.ReplaceMailBodyConstants(ReplaceStrings: TStringList);
var
  i, Position : integer;
  sCode, sValue : string;
begin
  if ((Not Assigned(ReplaceStrings)) or (ReplaceStrings.Count = 0))  then
    Exit;

  for i := 0 to ReplaceStrings.Count - 1 do
  begin
    Position := Pos('=', ReplaceStrings.Strings[i]);
    if (Position > 0) then
    begin
      sCode := Copy(ReplaceStrings.Strings[i], 1, Position - 1);
      sValue := Copy(ReplaceStrings.Strings[i], Position + 1, Length(ReplaceStrings.Strings[i]));
      if Trim(sCode) <> '' then
        Editor.ERTF.DisplayedText.RtfText.AsString
          := StringReplace(Editor.ERTF.DisplayedText.RtfText.AsANSIString, sCode, sValue,[rfReplaceAll, rfIgnoreCase]);
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.DoSave;
begin
   if Editor.ERTF.IsEmpty then begin
      // Dont save an empty file..
      if BkFileExists(SignatureFilename) then
         Deletefile(SignatureFilename);
   end else
      Editor.ERTF.saveToFile(SignatureFilename, false, '.rtf');
   Close;
end;

procedure TfrmMail.DoSendMail;
var
  BK5Attachments : TStringList;
  OtherAttachments : TStringList;
  i : integer;
  li : TListITem;
  aMsg, ClientWasOpen : string;
  TempClient: TClientObj;
begin
  //Initialise
  MailSentOk := False;
  //Verify all required fields are available
  aMsg := txtRecipient.text;
  if aMsg = '' then begin
     HelpfulWarningMsg('Please specify at least one recipient.', 0);
     txtRecipient.SetFocus;
     Exit;
  end { txtRecipient.text = '' };


  If pos('@',aMsg) = 0 then begin
      HelpfulWarningMsg('Please enter a valid email address, with one ''@''.',0);
      txtRecipient.SetFocus;
      Exit;
  end;
  If pos('.',aMsg) = 0 then begin
      HelpfulWarningMsg('Please enter a valid email address, with a ''.''.',0);
      txtRecipient.SetFocus;
      Exit;
  end;

  if eReturnAddr.Visible then begin
     if ( Trim(eReturnAddr.text) = '') then begin
        HelpfulWarningMsg('Please specify a return address.', 0);
        Exit;
     end { eReturnAddr.text = '' }
  end;

  if (((IsWoW64) or (INI_Mail_Type = MAPI_MAIL)) and (Trim(txtSubject.text) = '')) then
  begin
    HelpfulWarningMsg('Please specify a subject.', 0);
    txtSubject.SetFocus;
    Exit;
  end;

  //verify that all attachments are available
  aMsg := '';
  //Client files
  for i := 0 to lvClientFiles.Items.Count - 1 do
  begin
    li := lvClientFiles.Items[i];
    if not FileExists( li.SubItems[0]) then
      aMsg := aMsg + li.subItems[0] + #13;
  end;
  //Other attachments
  for i := 0 to lvAttach.Items.Count - 1 do
  begin
    li := lvAttach.Items[i];
    if not FileExists( li.SubItems[0]) then
      aMsg := aMsg + li.subItems[0] + #13;
  end;

  if aMsg <> '' then
  begin
    HelpfulWarningMsg( 'The following attachments could not be found: '#13#13 + aMsg, 0);
    Exit;
  end;

  //construct lists
  BK5Attachments := TStringList.Create;
  OtherAttachments := TStringList.Create;
  try
     //we need two lists at this point because BK5 files are treated differently
     //to standard attachments
     for i := 0 to lvAttach.Items.Count - 1 do begin
        li := lvAttach.Items[i];
        if li.SubItems.Strings[1] = FileExtn then
           BK5Attachments.Add( li.Caption) //client code - BK5 File may be added as attachment
        else
           OtherAttachments.Add( li.SubItems.Strings[0]); //filename
        if li.SubItems.Strings[0] = BNotesFile then
           BNotesAttachSent := True;
     end;
     for i := 0 to lvClientFiles.Items.Count - 1 do begin
        li := lvClientFiles.Items[i];
           BK5Attachments.Add(li.Caption); //client code
        if li.SubItems.Strings[0] = BNotesFile then
           BNotesAttachSent := True;
     end;

     //see if we are sending the current client, if we are then save it now
     //so that we send the latest edits
     ClientWasOpen := '';
     BK5Attachments.Sorted := True; // Find only works on a sorted list!
     if Assigned( MyClient)
     and BK5Attachments.Find( MyClient.clFields.clCode, i) then begin
        if chkCheckout.Checked then begin
           ClientWasOpen := MyClient.clFields.clCode;
           CloseClientHomePage;
        end else
           SaveClient(false);
     end;

     //Get available transactions for each client file
     if Assigned( AdminSystem) then begin
       for i := 0 to lvClientFiles.Items.Count - 1 do begin
         li := lvClientFiles.Items[i];
         if FileExists(li.SubItems[0]) then begin
           TempClient := nil;
           //Open client file
           Files.OpenAClient(li.Caption, TempClient, True);
           try
             //Merge new transactions
             if Assigned(TempClient) then begin
               MergeNewDataYN(TempClient, False, True);
             end;
           finally
             CloseAClient(TempClient);
           end;
         end;
       end;
     end;

     DisableForm;
     try
       if Assigned( AdminSystem) then
         MailSentOK := PracticeSendMail( BK5Attachments, OtherAttachments, chkCheckout.Checked, ClientWasOpen)
       else
         MailSentOK := OffsiteSendMail( BK5Attachments, OtherAttachments, chkCheckout.Checked, ClientWasOpen);
     finally
       EnableForm;
     end;

  finally
     BK5Attachments.Free;
     OtherAttachments.Free;
  end;

  if MailSentOk then begin
     HelpfulInfoMsg('Mail has been sent.', 0);
     Self.Close
  end else
     UpdateStatus(Self, 'Send failed.');
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.btnSendClick(Sender: TObject);
begin
   if EditMode then
      DoSave
   else
      DoSendMail;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.btnCancelClick(Sender: TObject);
begin
   if SendingMail
   and Assigned( MailObj) then begin
       MailObj.Abort;
   end
   else Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.DoDeleteSelected(AListView: TListView);
var
  i, j, SelectedNo  : Integer;
begin { TfrmMail.lvAttachKeyUp }
  if (AListView.SelCount = 0) then
    //don't allow deletes if nothing is selected
    exit;

  SelectedNo := -1;
  i := 0;
  while (i <= (AListView.items.Count - 1)) do
  begin
     if AListView.items[i].Selected then
     begin
       SelectedNo := i;

       //search through the attachment list
       j := 0;
       while (j < AttachmentList.Count) and (ExtractFilename(AttachmentList[j]) <> AListView.items[SelectedNo].Caption) do
         Inc(j);
       if (j < AttachmentList.Count) then
         //delete the attachment from the internal list
         AttachmentList.Delete(j);
       AListView.items[SelectedNo].Delete;
     end else
       Inc(i);
  end; 

  if (SelectedNo <> -1) then
  begin
    if (AListView.Items.Count > i) then
      AListView.Items[SelectedNo].Selected := True
    else
      if (AListView.Items.Count > 0) then
        AListView.Items[AListView.Items.Count - 1].Selected := True;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.lvAttachKeyUp(Sender: TObject; Var Key: Word; Shift: TShiftState);
begin
  if (Key = VK_DELETE) then
    DoDeleteSelected(lvAttach);
end;


procedure TfrmMail.lvClientFilesEnter(Sender: TObject);
begin
  if (lvClientFiles.Items.Count > 0)
  and (lvClientFiles.SelCount = 0) then
  begin
    lvClientFiles.Items[0].Focused := True;
    lvClientFiles.Items[0].Selected := True;
  end;
end;

procedure TfrmMail.lvClientFilesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key = VK_DELETE) then
    DoDeleteSelected(lvClientFiles);
end;

procedure TfrmMail.MenuItem4Click(Sender: TObject);
begin
  DoDeleteSelected(lvClientFiles);
end;

procedure TfrmMail.MergeText;
var par : TParagraph;
begin
    fBodyMerged := False; // set before we merge

    Editor.ERTF.MergeText;

    if (not fBodyMerged) // Still have to add any Body text
    and (fBodyText.Count > 0) then begin
       // Still need to add this somehow
       // Insert a Paragraph at the front
       par := Editor.ERTF.FirstPar;
       par := par.SplitAt(0);
       // Set To 'Plain text'
       Editor.ERTF.WritingAttr.Clear;
       Editor.ERTF.WritingAttr.SetFontName('Arial');
       Editor.ERTF.WritingAttr.SetFontSize(900);
       // Insert the text
       par.Insert(0, fBodyText.Text, Editor.ERTF.WritingAttr.CharAttr );


       Editor.ERTF.ReformatAll;
    end;
end;

procedure TfrmMail.NewMessage;
begin
     Editor.ERTF.Clear;
    AttachmentList.Clear;
    fBodyText.Clear;
    lvAttach.items.Clear;
    lvClientFiles.items.Clear;
end;

{ TfrmMail.lvAttachKeyUp }
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.DoAttachFile;
var
  aSHFi: TSHFileInfo;
  NewItem : TListItem;
begin
  with OpenDialog1 do
  begin
    DefaultExt   := '*.*';
    Filename     := '*.*';
    Filter       := 'All Files|*.*';
    Options      := [ ofHideReadOnly,  ofFileMustExist, ofEnableSizing, ofNoChangeDir ];
    Title        := 'Insert File';
    if Execute then
    begin
      //comparisons need to be in the same case because Windows takes the path
      //from the Shortcut. If they are different cases, the test will fail.
      if (Uppercase(ExtractFilePath(Filename)) = Uppercase(DataDir))
      and (Uppercase(ExtractFileExt(Filename)) = FILEEXTN) then
        HelpfulErrorMsg('You must use Attach Client File to attach *.BK5 files.',0)
      else
      begin
        //causes the icon to be retrieved
        SHGetFileInfo(PChar(Filename), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON );
        Image1.Picture.Icon.Handle := aSHFi.hIcon;
        ImageList1.AddIcon(Image1.Picture.Icon);

        NewItem            := lvAttach.Items.Add;
        NewItem.Caption    := ExtractFilename( Filename);
        NewItem.SubItems.Add( Filename);
        NewItem.SubItems.Add( ExtractFileExt( Filename));

        NewItem.ImageIndex := ImageList1.Count-1;
      end;
    end;
  end;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir( Globals.DataDir);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.sbtnAttachClick(Sender: TObject);
begin

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMail.Execute: boolean;
var
   ErrorMsg : string;
   i: Integer;
   A: TStringList;
   aSHFi: TSHFileInfo;
   NewItem : TListItem;
begin
   if not CheckMailSetup( ErrorMsg) then begin
      HelpfulErrorMsg( ErrorMsg,0);
      Result := false;
   end else begin
      {$B-}
      if Email_Saved
      and (AskYesNo('Recover Failed Email', 'The last time you sent an email it failed to send.' + #13 +
             'Would you like to recover the previous email and try again now?', DLG_NO, 0) = DLG_YES) then begin
          txtRecipient.Text := Email_To;
          eReturnAddr.Text := Email_From;
          txtCC.Text := Email_Cc;
           Editor.ERTF.AsString := Email_Body;
          AttachmentList.Text := Email_Attachments;
          A := TStringList.Create;
          try
            A.Text := Email_Attachments;
            lvAttach.Clear;
            lvClientFiles.Clear;
            for i := 0 to Pred(A.Count) do
            begin
               if ExtractFileExt(A[i]) = FILEEXTN then begin
                 //Client files
                 NewItem := lvClientFiles.Items.Add;
                 NewItem.ImageIndex := FILES_NORMAL_BMP;
                 NewItem.Caption := Copy(ExtractFilename(A[i]), 1, Length(ExtractFilename(A[i]))-4);
                 NewItem.SubItems.Add(A[i]);
                 NewItem.SubItems.Add(ExtractFileExt(A[i]));
                 NewItem.ImageIndex := ImageList1.Count-1;
               end else begin
                 //Other attachments
                 NewItem := lvAttach.Items.Add;
                 SHGetFileInfo(PChar(A[i]), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON );
                 Image1.Picture.Icon.Handle := aSHFi.hIcon;
                 ImageList1.AddIcon(Image1.Picture.Icon);
                 NewItem.Caption := ExtractFilename(A[i]);
                 NewItem.SubItems.Add(A[i]);
                 NewItem.SubItems.Add(ExtractFileExt(A[i]));
                 NewItem.ImageIndex := ImageList1.Count-1;
               end;
            end;
          finally
            A.Free;
          end;
          txtSubject.Text := Email_Subject;
          chkCheckout.Checked := Email_Checkout_File;
      end else
         MergeText;

      ShowModal;

      Result := MailSentOK;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EditSignature;
var SendDlg : TfrmMail;
begin
   SendDlg := TfrmMail.Create(Application.MainForm);
   try
      SendDlg.EditMode := True;
      SendDlg.Caption := 'Edit Signature';
      Result := SendDlg.ShowModal = mrOK;
   finally
      SendDlg.Release;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendClientFileTo(Recipient: string; CodesToSend: string = '') : boolean;
Var
   SendDlg : TfrmMail;
   NewItem : TListItem;
   ContactName, ContactPhone, ContactEmail, WebsiteAddress : string;
   CodeList    : TStringList;
   i: Integer;
begin
   SendDlg := TfrmMail.Create(Application.MainForm);
   CodeList := TStringList.Create;
   Try
      CodeList.Delimiter := ClientCodeDelimiter;
      CodeList.StrictDelimiter := true;
      With SendDlg do begin
         EditMode := False;
         if CodesToSend <> '' then
         begin
           CodeList.DelimitedText := CodesToSend;
           ClientList := CodeList;
         end;
         Caption := 'Send Client File(s)';
         ClientFileExpected := True;
         BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);

         //prefill the address with saved information
         //if at the practice use the last email address entered by the practice
         if (CodesToSend = '') and ( Recipient = '') and Assigned( MyClient) then
         begin
           if Assigned( AdminSystem) then
             txtRecipient.Text := MyClient.clFields.clClient_EMail_Address
           else
           begin
             bkUtil32.GetPracticeContactDetails( MyClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);
             txtRecipient.Text := ContactEmail;
           end;
         end
         else
           txtRecipient.text := Recipient;

         if (Assigned(AdminSystem)) then
         begin
           chkCheckout.Visible := CurrUser.CanAccessAdmin or (not PRACINI_OSAdminOnly);
         end
         else
         begin
           if PRACINI_DisableCheckInCheckOut or (not INI_AllowCheckOut) or (Assigned(MyClient) and MyClient.clFields.clDisable_Offsite_Check_Out) then
             chkCheckout.Visible := False
           else if Assigned(MyClient) and MyClient.clFields.clForce_Offsite_Check_Out then
           begin
             chkCheckout.Visible := True;
             chkCheckout.Enabled := (IsEmailAddressSupport(txtRecipient.Text)) and (not FAllowCheckOutToSupport);
           end
           else
             chkCheckout.Visible := True;
         end;

         //set the default checkout flag status
         chkCheckout.Checked := chkCheckout.Visible;

         if (IsEmailAddressSupport(txtRecipient.Text)) and (not FAllowCheckOutToSupport) then
           chkCheckout.checked := False
         else if (CodeList.Count = 0) and Assigned( MyClient) and (MyClient.clFields.clFile_Read_Only) then
           chkCheckout.Checked := False;

         //from client manager
         if CodeList.Count > 0 then
         begin
           for i := 0 to Pred(CodeList.Count) do
             With lvClientFiles do begin
                NewItem := items.Add;
                NewItem.caption := CodeList[i];
                NewItem.SubItems.Add( DataDir + NewItem.Caption + FileExtn);
                NewITem.SubItems.Add( FileExtn);
                NewItem.ImageIndex := FILES_NORMAL_BMP;

                if chkCheckout.Checked then
                   IncUsage('Check Out Send')
                else
                   IncUsage('Send ClientFile')
             end; { with lvAttach }
         end
         //do we have a client open.. if so automatically put in list
         else if Assigned(MyClient) then
         begin
             With lvClientFiles do begin
                NewItem := items.Add;
                NewItem.caption := MyClient.clFields.clCode;
                NewItem.SubItems.Add( DataDir + NewItem.Caption + FileExtn);
                NewITem.SubItems.Add( FileExtn);
                NewItem.ImageIndex := FILES_NORMAL_BMP;

                if chkCheckout.Checked then
                   IncUsage('Check Out Send')
                else
                   IncUsage('Send ClientFile')
             end; { with lvAttach }

             //no point checking out if read only
             if MyClient.clFields.clFile_Read_Only then
               chkCheckout.Checked := False;
         end;

        //Default email subject
        if (CodeList.Count > 0) then begin
          if (CodeList.Count > 1) then
            txtSubject.Text := Format(bkBranding.BooksProductName + ' Files for %s', [CodeList.CommaText])
          else
            txtSubject.Text := Format(bkBranding.BooksProductName + ' File for %s', [CodeList.CommaText]);
        end else if Assigned( MyClient) then
          txtSubject.Text := Format(bkBranding.BooksProductName + ' File for %s',[MyClient.clFields.clCode]);

        //Default message
        if (fBodyText.Text = '') and (CodesToSend <> '') then
          BodyText := Format('The following Client File(s) are now available: %s', [CodesToSend]);
        
      end { with SendDlg };

      Result := SendDlg.Execute;
   Finally
      SendDlg.Free;
      CodeList.Free;
   end { try };
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendMailTo(Title: string; Recipient: string; Subject: string;
  Body: string; Attachment: string = ''; ShowPracDetails: Boolean = True;
  MultipleRecipients: string = '') : boolean;
Var
   SendDlg : TfrmMail;
   NewItem : TListItem;
   aSHFi: TSHFileInfo;
begin
   SendDlg := TfrmMail.Create(Application.MainForm);
   Try
      With SendDlg do begin
         EditMode := False;
         FShowPracDetails := ShowPracDetails;
         FMultipleRecipientsList.StrictDelimiter := True;
         FMultipleRecipientsList.Delimiter := VALUES_DELIMITER;
         FMultipleRecipientsList.DelimitedText := MultipleRecipients;
//         btnAttachClient.Visible := False;
         HideClientFiles;
         chkCheckout.Checked := False;
         chkCheckout.Visible := False;
         BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);
         txtRecipient.text := Recipient;
         txtSubject.text := Subject;
         caption := Title;
         BodyText := Body;
         if Attachment <> '' then
         begin
           //causes the icon to be retrieved
           SHGetFileInfo(PChar(Attachment), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON );
           Image1.Picture.Icon.Handle := aSHFi.hIcon;
           ImageList1.AddIcon(Image1.Picture.Icon);

           if (ExtractFileExt(Attachment) = FILEEXTN) then
             NewItem := lvClientFiles.Items.Add
           else
             NewItem := lvAttach.Items.Add;
           if Assigned(NewItem) then begin
             NewItem.Caption    := ExtractFilename( Attachment);
             NewItem.SubItems.Add( Attachment);
             NewItem.SubItems.Add( ExtractFileExt( Attachment));
             NewItem.ImageIndex := ImageList1.Count-1;
           end;
         end;
      end { with SendDlg };

      Result := SendDlg.Execute;
   Finally
      SendDlg.Free;
   end { try };
end;

function SendClientAndOtherFilesTo(Title: string; Recipient: string; Subject: string; Body: string;
                                   Attachments: TStringlist;
                                   BK5Attachments: TStringList;
                                   CheckOut: Boolean) : boolean;
Var
   SendDlg: TfrmMail;
   NewItem: TListItem;
   aSHFi: TSHFileInfo;
   I: Integer;

   procedure AttachFile(filename: string);
   begin
     with SendDlg do begin
       //causes the icon to be retrieved
       SHGetFileInfo(PChar(FileName), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON );
       Image1.Picture.Icon.Handle := aSHFi.hIcon;
       ImageList1.AddIcon(Image1.Picture.Icon);
       NewItem            := lvAttach.Items.Add;
       NewItem.Caption    := ExtractFilename(FileName);
       //OK for here... But mail need s afull path....
       if ExtractFilepath(FileName) = '' then
         NewItem.SubItems.Add( IncludeTrailingbackslash(GetCurrentDir) + FileName)
       else
         NewItem.SubItems.Add(FileName);
       NewItem.SubItems.Add(ExtractFileExt(FileName));
       NewItem.ImageIndex := ImageList1.Count-1;
     end;
   end; { with lvAttach }

   procedure AttachBK5File(filename: string);
   begin
     with SendDlg do begin
       NewItem := lvClientFiles.items.Add;
       NewItem.caption := filename;
       NewItem.SubItems.Add( DataDir + ExtractFilename(FileName) + FileExtn); //full filename
       NewItem.SubItems.Add( FileExtn);
       NewItem.ImageIndex := FILES_NORMAL_BMP;
     end;
   end;

begin
   SendDlg := TfrmMail.Create(Application.MainForm);
   Try
      With SendDlg do begin
         EditMode := False;
//         btnAttachClient.Visible := False;
         HideClientFiles;
         AllowCheckOutToSupport := CheckOut;
         chkCheckout.Checked := CheckOut;
         chkCheckout.Visible := True;
         BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);
         txtRecipient.text := Recipient;
         txtSubject.text := Subject;
         caption := Title;
         BodyText := Body;
         if Attachments.Count > 0 then
            for I := 0 to Attachments.Count - 1 do
              AttachFile(Attachments[I]);
         if BK5Attachments.Count > 0 then
            for I := 0 to BK5Attachments.Count - 1 do
              AttachBK5File(BK5Attachments[I]);

      end { with SendDlg };

      Result := SendDlg.Execute;
   Finally
      SendDlg.Free;
   end { try };
end;

function SendFilesTo(Title: string; Recipient: string; Subject: string; Body: string; Attachments: TStringlist) : boolean;
Var
   SendDlg: TfrmMail;
   NewItem: TListItem;
   aSHFi: TSHFileInfo;
   I: Integer;

   procedure AttachFile(filename: string);
   var
     ExtendedFileName: string;
   begin
     with SendDlg do begin
       //Get filename with full path
       ExtendedFileName := FileName;
       if ExtractFilepath(ExtendedFileName) = '' then
         ExtendedFileName := IncludeTrailingbackslash(GetCurrentDir) + FileName;

       //Causes the icon to be retrieved
       SHGetFileInfo(PChar(FileName), 0, aSHFi, sizeOf(aSHFi), SHGFI_ICON);
       Image1.Picture.Icon.Handle := aSHFi.hIcon;
       ImageList1.AddIcon(Image1.Picture.Icon);

       if ExtractFileExt(FileName) = FILEEXTN then begin
         NewItem            := lvClientFiles.Items.Add;
         NewItem.SubItems.Add(ExtendedFileName);
         NewItem.Caption    := ExtractFilename(FileName);
         NewItem.SubItems.Add(ExtractFileExt(FileName));
         NewItem.ImageIndex := ImageList1.Count-1;
       end else begin
         NewItem            := lvAttach.Items.Add;
         NewItem.SubItems.Add(ExtendedFileName);
         NewItem.Caption    := ExtractFilename(FileName);
         NewItem.SubItems.Add(ExtractFileExt(FileName));
         NewItem.ImageIndex := ImageList1.Count-1;
       end;
     end;
   end;

begin
   SendDlg := TfrmMail.Create(Application.MainForm);
   Try
      With SendDlg do begin
         EditMode := False;
//         btnAttachClient.Visible := False;
         HideClientFiles;
         chkCheckout.Checked := False;
         chkCheckout.Visible := False;
         BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);
         txtRecipient.text := Recipient;
         txtSubject.text := Subject;
         caption := Title;
         BodyText := Body;
         if Attachments.Count > 0 then
            for I := 0 to Attachments.Count - 1 do
              AttachFile(Attachments[I]);

      end { with SendDlg };

      Result := SendDlg.Execute;
   Finally
      SendDlg.Free;
   end { try };
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SendMailToSupport(Recipient: string) : boolean;
Var
   SendDlg : TfrmMail;
begin
   SendDlg := TfrmMail.Create(Application.mainform);
   Try
      With SendDlg do begin
         EditMode := False;
         BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);
         txtRecipient.text := Recipient;
         caption := 'Email Support';
         chkCheckout.Checked := false;
         if (not Assigned(AdminSystem)) then
         begin
           if PRACINI_DisableCheckInCheckOut or (not INI_AllowCheckOut) or (Assigned(MyClient) and MyClient.clFields.clDisable_Offsite_Check_Out) then
             chkCheckout.Visible := False
           else
             chkCheckout.Visible := True;
         end
         else
           chkCheckout.Visible := CurrUser.CanAccessAdmin or (not PRACINI_OSAdminOnly);
      end { with SendDlg };

      Result := SendDlg.Execute;
   Finally
      SendDlg.Free;
   end { try };
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ReplaceStrings data should be of the format CODETOREPLACE=STRINGValue}
function SendFileTo( Title : string; Recipient : string; Subject: string;
  Filename : string; var AttachSent: Boolean; CanSelectClient : boolean = true;
  HideClientEmail: Boolean = False;GetTemplateFromRes:Boolean=False;
  ReplaceStrings:TStringList=nil) : boolean;
var
  SendDlg : TfrmMail;
  NewItem : TListItem;
  ResStream : TResourceStream;
  tempMemo : TMemo;
begin
  AttachSent := False;
  SendDlg := TfrmMail.Create(Application.MainForm);
  try
    with SendDlg do begin
      EditMode := False;
      HideDropDowns := HideClientEmail;
      if GetTemplateFromRes then
      begin
        ResStream := TResourceStream.Create(hinstance, 'MailBodyTemplate', RT_RCDATA);
        tempMemo := TMemo.Create(Application);
        try
          ResStream.Position := 0;
          Editor.ERTF.LoadFromStream(ResStream);
          ReplaceMailBodyConstants(ReplaceStrings);
        finally
          ResStream.Free;
          tempMemo.Free;
        end;
      end;

      BNotesFile := Filename;
      BKHelpSetUp(SendDlg, BKH_Sending_a_client_file_via_email);
      txtRecipient.text := Recipient;
      txtSubject.Text := Subject;
      Caption := Title;
      chkCheckout.Checked := False;
      if (not Assigned(AdminSystem)) then begin
        if PRACINI_DisableCheckInCheckOut or (not INI_AllowCheckOut) or
           (Assigned(MyClient) and MyClient.clFields.clDisable_Offsite_Check_Out) then
          chkCheckout.Visible := False
        else
          chkCheckout.Visible := True;
      end else
        chkCheckout.Visible := CurrUser.CanAccessAdmin or (not PRACINI_OSAdminOnly);

      //Set to read-only by default (TFS 34290)
      chkCheckout.Checked := chkCheckout.Visible;
      if (IsEmailAddressSupport(txtRecipient.Text)) and (not FAllowCheckOutToSupport) then
        chkCheckout.Checked := False;

      if not CanSelectClient then begin
        actAttach.Caption := 'Attac&h...';
        actClientFile.Visible := false;
        chkCheckout.Visible := false;
        ClientFileExpected := false;
        HideClientFiles;
      end;

      if Filename <> '' then begin
        if (ExtractFileExt(FileName) = FILEEXTN) and CanSelectClient then
          NewItem := lvClientFiles.Items.Add
        else
          NewItem := lvAttach.Items.Add;
        if Assigned(NewItem) then begin
          NewItem.caption    := ExtractFilename( Filename);
          NewItem.SubItems.Add( Filename);
          NewItem.SubItems.Add( ExtractFileExt( Filename));
          NewItem.ImageIndex := 0; //FILES_NORMAL_BMP;
        end;
      end;
    end { with SendDlg };

    Result := SendDlg.Execute;
    AttachSent := SendDlg.BNotesAttachSent;
  finally
    SendDlg.Free;
  end { try };
end;

procedure MailStatusChange ( Sender : TObject; sMsg : string);
//receives status updates during email
begin
   UpdateAppStatusLine2( sMsg, ProcessMessages_On);
end;

function GetEmailSubject(EmailInfo: TClientEmailInfo; aSubject: string): string;
const
  CODING_REPORT = 'Coding Report';
  NOTES_FILE    = 'Notes File';
  BOOKS_FILE    = 'Books File';

  BUSINESS_FILE = 'Business Product File';
begin
  if aSubject <> '' then
     // Use the Custom one...
     Result := Format('[%s] %s',[EmailInfo.ClientCode, aSubject])
  else begin
    case EmailInfo.EmailType of
      EMAIL_MESSAGE          : Result := CODING_REPORT;
      EMAIL_ECODING          : Result := NOTES_FILE;
      EMAIL_CHECKOUT,
      EMAIL_BANKLINK_ONLINE  : Result := BOOKS_FILE;
      EMAIL_WEBNOTES         : begin
                                  Result := format('New %s transactions are available', [bkBranding.NotesOnlineProductName]);
                                  Exit;
                               end;
      EMAIL_BUSINESS_PRODUCT : Result := BUSINESS_FILE;
    end;
    Result := Format(TProduct.BrandName + ' %s for %s',
                     [Result,
                      EmailInfo.ClientCode]);
    if (EmailInfo.DateFrom <> 0) and (EmailInfo.DateTo <> 0) then
      Result := Format('%s (%s to %s)',
                       [Result,
                        bkDate2Str(EmailInfo.DateFrom),
                        bkDate2Str(EmailInfo.DateTo)])
  end;
end;

function SendSceduledEmail(EmailList: tList; srOptions : TSchReportOptions ): Boolean;
const
  ThisMethodName = 'SendReportsViaEmail';
var
   SendDlg: TfrmMail;
   I, J: Integer;
   EmailInfo: TClientEmailInfo;
   sMsg: string;
   SomeFailed: boolean;
   cfRec: pClient_File_Rec;
   cmdLine : string;
   counter : Integer;
   cmdLineHlp : string;
   RTFFileBodyToSendPath : string;

   function RenameAttachment(OldName: string; NewName: string) : boolean;
   begin
      if BKFileExists(NewName) then
         SysUtils.DeleteFile(NewName);
      Result := SysUtils.RenameFile(OldName, NewName);
      if Result then
         SendDlg.MailObj.Attachments.Add(NewName)
   end;

   procedure AddAttachmentList(Value: string);
   var AttachedList: TStringList;
       I: Integer;

       function TestNotCustomDoc(Value:string): Boolean;
       var FileName: string;
       begin
          Result := True;
          FileName := ExtractFilename(Value);
          if Pos('[',Filename) <> 1 then
             Exit;
          if Pos(']',Filename) <> 6 then
             Exit;
          Result := not RenameAttachment(Value,
             ExtractFilePath(Value) + Copy(FileName,7,Length(Value)));
       end;
   begin
      AttachedList := TStringList.Create;
      try
         AttachedList.StrictDelimiter := true;
         AttachedList.Delimiter := ',';
         AttachedList.DelimitedText := Value;
         for I := 0 to AttachedList.Count - 1 do begin
            if TestNotCustomDoc(AttachedList[I]) then
               SendDlg.MailObj.Attachments.Add(AttachedList[I]);
         end;
      finally
         AttachedList.Free;
      end;
   end;


begin //SendSceduledEmail
   SendDlg := TfrmMail.Create(Application.MainForm);
   try
      with SendDlg do begin
         MailObj := TMailModule.Create(Application);
         MailObj.Email := SendDlg.Editor.ERTF;
         SomeFailed := False;
         EditMode := False;
         FShowPracDetails := False;
         MailObj.OnStatusChangeProc := MailStatusChange;
         //btnAttachClient.Visible := False; Not Shown anyway...
         //chkCheckout.Checked := False;
         //chkCheckout.Visible := False;
         try
           //if MailObj.Connect then begin
           begin
             if (not IsWoW64) or (INI_Mail_Type = SMTP_MAIL) then
               MailObj.Connect;
           for I := 0 to EmailList.Count - 1 do begin
             //check if cancel button pressed
             if Status_Cancel_Pressed then begin
                //exit the for loop and disconnect
                Break;
             end;
             //get email info for client
             EmailInfo := EmailList[i];
             NewMessage;
             MailObj.NewMessage;
             //Update app status
             UpdateAppStatus( 'Email Reports to '+ EmailInfo.ClientCode, '', -1, ProcessMessages_On);

             //Build Message
             with AdminSystem.fdFields, EmailInfo do begin
                MailObj.FromName := GlobalCache.cache_Current_Username;

                //use the practise email as the default return address
                //if this has not been specified try the smtp from address
                if fdPractice_EMail_Address <> '' then begin
                   MailObj.UsingAddr := 'Practice';
                   MailObj.FromAddr := fdPractice_EMail_Address
                end else begin
                   MailObj.UsingAddr := 'Internet Mail Return';
                   MailObj.FromAddr := INI_SMTP_From;
                end;

                MailObj.Recipients.Add(EmailAddress);
                if (CCEmailAddress <> '') then
                   ParseRecipients(CCEmailAddress, MailObj.CarbonCopy);

                case EmailType of

                EMAIL_MESSAGE : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_Email_Subject);

                    if (fdSched_Rep_Email_Message <> '') then
                       ClientMessage := ClientMessage + #13
                                     + fdSched_Rep_Email_Message;
                end;

                EMAIL_ECODING : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_BNotes_Subject);

                    if (fdSched_Rep_BNotes_Message <> '') then
                       ClientMessage := ClientMessage + #13 + fdSched_Rep_BNotes_Message;
                end;

                EMAIL_CHECKOUT : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_CheckOut_Subject);

                    if (fdSched_Rep_CheckOut_Message <> '') then
                                  ClientMessage := ClientMessage + #13 + fdSched_Rep_CheckOut_Message;
                end;

                EMAIL_BANKLINK_ONLINE : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_Online_Subject);

                    if (ClientMessage <> '') then
                      ClientMessage := ClientMessage + #13#13;
                    ClientMessage := ClientMessage +
                                     Format('The Client File %s is now available via %s. ' +
                                            'To access this client file select ‘Get Client Files | from %s’.',
                                            [EmailInfo.ClientCode, bkBranding.ProductOnlineName,
                                             bkBranding.ProductOnlineName]);

                    if EmailInfo.IsFirstPracUpload then
                    begin
                      ClientMessage := ClientMessage + #10#10 +
                         'Subdomain: ' + GetBankLinkOnlineSubDomain +  #10 +
                         'Username: ' + EmailInfo.EmailAddress + #10#10 +
                         'If you are new to ' + bkBranding.ProductOnlineName + ', you will receive ' +
                         'an email shortly which will help you complete the ' +
                         'setup process. Please wait for this email before continuing.';
                    end;

                    if (fdSched_Rep_Online_Message <> '') then
                                  ClientMessage := ClientMessage + #13#13 + fdSched_Rep_Online_Message;
                end;

                EMAIL_WEBNOTES : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_WebNotes_Subject);

                    if (fdSched_Rep_webNotes_Message <> '') then
                                  ClientMessage := ClientMessage + #13 + fdSched_Rep_webNotes_Message;
                end;

                EMAIL_BUSINESS_PRODUCT : begin
                    MailObj.Subject := GetEmailSubject(EmailInfo, fdSched_Rep_Business_Products_Subject);

                    if (fdSched_Rep_Business_Products_Message <> '') then
                       ClientMessage := ClientMessage + #13 + fdSched_Rep_Business_Products_Message;
                end;

                else begin
                    MailObj.Subject   := '[' + ClientCode + ']';
                end;
                end; //Case EMail Type

                BodyText := ClientMessage;
                LoadSignature;
                MergeText;
                //Rename reports to common names, then attach to email
                RenameAttachment(EmailOutboxDir + ClientCode + '.COD',
                                 EmailOutboxDir + 'CODING.TXT');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CDC',
                                  EmailOutboxDir + 'CODING.CSV');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CDP',
                                  EmailOutboxDir + 'CODING.PDF');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CDX',
                                  EmailOutboxDir + 'CODING.XLS');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CHT',
                                  EmailOutboxDir + 'CHART.TXT');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CHC',
                                  EmailOutboxDir + 'CHART.CSV');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CHP',
                                  EmailOutboxDir + 'CHART.PDF');

                RenameAttachment( EmailOutboxDir + ClientCode + '.CHX',
                                  EmailOutboxDir + 'CHART.XLS');

                RenameAttachment( EmailOutboxDir + ClientCode + '.PAY',
                                  EmailOutboxDir + 'PAYEES.TXT');

                RenameAttachment( EmailOutboxDir + ClientCode + '.PYC',
                                  EmailOutboxDir + 'PAYEES.CSV');

                RenameAttachment( EmailOutboxDir + ClientCode + '.PYP',
                                  EmailOutboxDir + 'PAYEES.PDF');

                RenameAttachment( EmailOutboxDir + ClientCode + '.PYX',
                                  EmailOutboxDir + 'PAYEES.XLS');

                RenameAttachment( EmailOutboxDir + ClientCode + '.JBY',
                                  EmailOutboxDir + 'JOBS.TXT');

                RenameAttachment( EmailOutboxDir + ClientCode + '.JBC',
                                  EmailOutboxDir + 'JOBS.CSV');

                RenameAttachment( EmailOutboxDir + ClientCode + '.JBP',
                                  EmailOutboxDir + 'JOBS.PDF');

                RenameAttachment( EmailOutboxDir + ClientCode + '.JBX',
                                  EmailOutboxDir + 'JOBS.XLS');

                if (ECodingFilename <> '') and (EmailType <> EMAIL_BANKLINK_ONLINE) then
                   SendDlg.MailObj.Attachments.Add( EmailOutboxDir + EcodingFilename);

                if (EmailInfo.AttachmentList <> '') then
                   //send the specified attached files
                   AddAttachmentList(EmailInfo.AttachmentList);

             end;//AdminSystem.fdFields, EmailInfo

             //Send Message(s), if the send fails move on to the next file
             if (not IsWoW64) or (INI_Mail_Type = SMTP_MAIL) then
             begin
               try try
                     MailObj.SendMail;
                     // processmessages is needed for Windows XP and Office XP
                     // to stop this application from locking up
                     Application.ProcessMessages;
                     //log succesful send of mail
                     sMsg := Format( 'Mail Sent to %s (%s', [ EmailInfo.ClientCode,
                                                                      EmailInfo.EmailAddress ]);
                     if (EmailInfo.CCEmailAddress <> '') then
                        sMsg := sMsg + Format(',%s)', [EmailInfo.CCEmailAddress])
                     else
                        sMsg := sMsg + ')';
                     LogUtil.LogMsg( lmInfo, UnitName, sMsg);

                     // add to do item once email sent
                     if EmailInfo.EmailType in [EMAIL_CHECKOUT, EMAIL_BANKLINK_ONLINE] then begin
                        if LoadAdminSystem( true, ThisMethodName +' '+ EmailInfo.ClientCode) then begin
                           cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(EmailInfo.ClientCode);
                           if Assigned(cfRec) then
                              AddAutomaticToDoItem( CFRec, ttyCheckOut, Format(ToDoMsg_Checkout, [bkDate2Str(CurrentDate)]));
                           SaveAdminSystem;
                        end;
                     end;

               except
                     //if mail cannot be sent an exception will be raised
                     on e: EMailSendFailed do begin
                        //find all occurances of this client in the list and set completed to false.
                        for j := 0 to srOptions.srSummaryInfoList.Count-1 do begin
                           if (pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).ClientCode = EmailInfo.ClientCode) then begin
                              pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).EmailSendFail := True;
                              pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).Completed := False;
                           end;
                        end;

                        sMsg := Format( 'Unable to Send Mail to %s (%s)', [ EmailInfo.ClientCode,
                                                                                   E.Message ]);
                        LogUtil.LogMsg( lmError, UnitName, sMsg);
                        SomeFailed := true;
                        // Undo checkout
                        if (EmailInfo.EmailType = EMAIL_CHECKOUT) then // check back in
                           //Note: If we get to this stage for a BankLink Online file then it has
                           //been uploaded - so we don't need to undo the checkout
                           CheckInClient(EmailInfo.ClientCode, EmailOutboxDir, nil, True);
                        // Decrement ecoding sequence
                        if EmailInfo.EmailType = EMAIL_ECODING then begin
                           OpenAClient(EmailInfo.ClientCode, MyClient, True);
                           if Assigned(MyClient) then begin
                              Dec(MyClient.clFields.clECoding_Last_File_No);
                              Files.DoClientSave( TRUE, MyClient);
                           end;
                           MyClient.Free;
                           MyClient := nil;
                           BatchReports.XMLString := '';
                        end;
                     end;
               end;

               finally
                     //clean up any ecoding files
                     if EmailInfo.ECodingFilename <> '' then
                        SysUtils.DeleteFile( EmailOutboxDir + EmailInfo.ECodingFilename);
               end;
             end else
             //sending email thru the 64bit application
             begin
               try
                 cmdLine := '';
                 cmdLineHlp := '';
                 if MailObj.Recipients.Count > 0 then
                 begin
                   for counter := 0 to MailObj.Recipients.Count - 1 do
                   begin
                     if SameStr(cmdLineHlp, '') then
                       cmdLineHlp := MailObj.Recipients[counter] + ';'
                     else
                       cmdLineHlp := cmdLineHlp + MailObj.Recipients.Strings[counter];
                   end;
                   
                   cmdLine := cmdLine + ' -to ' +cmdLineHlp;
                   if not SameStr(MailObj.Subject, '')  then
                     cmdLine := cmdLine + ' -subject ' + MailObj.Subject;

                   //in order to send RTF let's use OLE  
                   cmdLine := cmdLine + ' -ole true;';
                   if not SameStr(MailObj.EMail.Text, '') then
                   begin
                     RTFFileBodyToSendPath := GenerateRndFileName;
                     if FileExists(RTFFileBodyToSendPath) then
                     begin
                       DeleteFile(RTFFileBodyToSendPath);
                       RTFFileBodyToSendPath := GenerateRndFileName;
                     end;
                     MailObj.EMail.SaveToFile(RTFFileBodyToSendPath);
                     cmdLine := cmdLine + ' -rtf '+ RTFFileBodyToSendPath;
                   end;                   

                   if MailObj.Attachments.Count > 0 then
                   begin
                     cmdLineHlp := '';
                     for counter := 0 to MailObj.Attachments.Count - 1 do
                     begin
                       if SameStr(cmdLineHlp, '') then
                         cmdLineHlp := MailObj.Attachments.Strings[counter] + ';'
                       else
                        cmdLineHlp := cmdLineHlp + MailObj.Attachments.Strings[counter] + ';';
                     end;
                     cmdLine := cmdLine + ' -att ' + cmdLineHlp;
                   end;
                 end;
                 
                 SendEmail64Bit(cmdLine);
                 try
                   if EmailInfo.EmailType in [EMAIL_CHECKOUT, EMAIL_BANKLINK_ONLINE] then
                   begin
                     if LoadAdminSystem( true, ThisMethodName +' '+ EmailInfo.ClientCode) then
                     begin
                       cfRec := AdminSystem.fdSystem_Client_File_List.FindCode(EmailInfo.ClientCode);
                       if Assigned(cfRec) then
                         AddAutomaticToDoItem( CFRec, ttyCheckOut, Format(ToDoMsg_Checkout, [bkDate2Str(CurrentDate)]));
                         SaveAdminSystem;
                     end;
                   end;
                  finally
                    if EmailInfo.ECodingFilename <> '' then
                     SysUtils.DeleteFile( EmailOutboxDir + EmailInfo.ECodingFilename);
                 end;
               except
                 on e: EMailSendFailed do
                 begin
                 //find all occurances of this client in the list and set completed to false.
                   for j := 0 to srOptions.srSummaryInfoList.Count-1 do begin
                     if (pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).ClientCode = EmailInfo.ClientCode) then
                     begin
                       pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).EmailSendFail := True;
                       pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).Completed := False;
                     end;
                   end;

                   sMsg := Format( 'Unable to Send Mail to %s (%s)', [ EmailInfo.ClientCode,
                                                                                   E.Message ]);
                   LogUtil.LogMsg( lmError, UnitName, sMsg);
                   SomeFailed := true;
                   // Undo checkout
                   if (EmailInfo.EmailType = EMAIL_CHECKOUT) then // check back in
                   //Note: If we get to this stage for a BankLink Online file then it has
                   //been uploaded - so we don't need to undo the checkout
                     CheckInClient(EmailInfo.ClientCode, EmailOutboxDir, nil, True);
                   // Decrement ecoding sequence
                   if EmailInfo.EmailType = EMAIL_ECODING then
                   begin
                     OpenAClient(EmailInfo.ClientCode, MyClient, True);
                     if Assigned(MyClient) then
                     begin
                       Dec(MyClient.clFields.clECoding_Last_File_No);
                       Files.DoClientSave( TRUE, MyClient);
                     end;
                     MyClient.Free;
                     MyClient := nil;
                     BatchReports.XMLString := '';
                   end;
                 end;
               end;
             end;

           end; // for EmailList Loop

           //Disconnect from mail server
           if (not IsWoW64) or (INI_Mail_Type = SMTP_MAIL) then
             MailObj.Disconnect;

           //Report if sending mail failed for some clients
           if SomeFailed then begin
              HelpfulErrorMsg( 'Unable to Send Mail for some clients.  See Log for details.',0);
           end;

           //Clean up files from directory
           SysUtils.DeleteFile( EmailOutboxDir + 'CODING.TXT');
           SysUtils.DeleteFile( EmailOutboxDir + 'CODING.CSV');
           SysUtils.DeleteFile( EmailOutboxDir + 'CODING.PDF');
           SysUtils.DeleteFile( EmailOutboxDir + 'CHART.TXT');
           SysUtils.DeleteFile( EmailOutboxDir + 'CHART.CSV');
           SysUtils.DeleteFile( EmailOutboxDir + 'CHART.PDF');
           SysUtils.DeleteFile( EmailOutboxDir + 'PAYEE.TXT');
           SysUtils.DeleteFile( EmailOutboxDir + 'PAYEE.CSV');
           SysUtils.DeleteFile( EmailOutboxDir + 'PAYEE.PDF');
         end; //else begin
            //Should only get here if Connect failed without causing an exception
            //Could be because User aborted the connect
            //HelpfulErrorMsg('Unable to Send Mail. Connection Failed',0);
         //end;

         //Handle exceptions from Mail Object
         except
            on e: EMailConnectFailed do begin
               sMsg := 'Unable to Send Mail. Connection Failed ('+ e.Message +')';
               LogUtil.LogMsg( lmError, UnitName, sMsg);
               HelpfulErrorMsg( sMsg,0);
            end;
            on e: EMailDisconnectFailed do begin
               //Just log it.  Don't need to tell user.  Connection should be
               //terminated when object is freed
               sMsg := 'Disconnect Failed (' + e.Message + ')';
               LogUtil.LogMsg( lmError, UnitName, sMsg);
            end;
            on e: Exception do
            begin
              for I := 0 to EmailList.Count - 1 do 
              begin
                EmailInfo := EmailList[I];

                // Undo checkout
                if (EmailInfo.EmailType = EMAIL_CHECKOUT) then // check back in
                begin
                  //Note: If we get to this stage for a BankLink Online file then it has
                  //been uploaded - so we don't need to undo the checkout
                  CheckInClient(EmailInfo.ClientCode, EmailOutboxDir, nil, True);
                end;
              
                // Decrement ecoding sequence
                if EmailInfo.EmailType = EMAIL_ECODING then 
                begin
                  OpenAClient(EmailInfo.ClientCode, MyClient, True);

                  if Assigned(MyClient) then 
                  begin
                    Dec(MyClient.clFields.clECoding_Last_File_No);
                    Files.DoClientSave( TRUE, MyClient);
                  end;

                  MyClient.Free;

                  MyClient := nil;         
                end;

                for j := 0 to srOptions.srSummaryInfoList.Count-1 do 
                begin
                  if (pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).ClientCode = EmailInfo.ClientCode) then 
                  begin
                    pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).EmailSendFail := True;
                    pSchdRepSummaryRec(srOptions.srSummaryInfoList.Items[j]).Completed := False;
                  end;
                end;  
              end;
                      
              sMsg := 'Unable to Send Mail. Connection Failed ('+ e.Message +')';

              LogUtil.LogMsg( lmError, UnitName, sMsg);

              HelpfulErrorMsg( 'Unable to Send Mail for some clients.  See Log for details.',0);
            end;
         end;
         //
      end;

   Finally
      SendDlg.MailObj.Free;
      SendDlg.Free;
   end;
end;


procedure TfrmMail.DisableForm;
//need to turn of access to controls on form as process messages
//may be called during close of client file
begin
  pnlHeader.Enabled := false;
  pnlMessage.Enabled := false;
  chkCheckout.Enabled := false;

  btnAttach.Enabled := false;
  btnAttachClient.Enabled := false;
  btnSend.Enabled := false;
end;


procedure TfrmMail.EditorERTFHyperLinkEvent(Sender: TObject; text, url: string;
  IgnoredNumber: Integer);
begin
  ShellExecute(0, 'OPEN', PChar(url), '', '', SW_SHOWNORMAL);
end;

procedure TfrmMail.EnableForm;
begin
  pnlHeader.Enabled := true;
  pnlMessage.Enabled := true;
  chkCheckout.Enabled := true;

  btnAttach.Enabled := true;
  btnAttachClient.Enabled := true;

  btnSend.Enabled := true;
end;

procedure TfrmMail.actClientFileExecute(Sender: TObject);
begin
  DoAttachClientFile;
end;


procedure TfrmMail.AddLine(Value: string);
var  par: TParagraph;
begin
   par :=  Editor.ERTF.Activetext.AppendPar;
   par.SetText(Value + #13);
end;

procedure TfrmMail.actAttachExecute(Sender: TObject);
begin
  DoAttachFile;
end;

procedure TfrmMail.pmiDeleteClick(Sender: TObject);
begin
  DoDeleteSelected(lvAttach);
end;

procedure TfrmMail.popAttachmentsPopup(Sender: TObject);
begin
  pmiDelete.Enabled := lvAttach.SelCount > 0;
end;

procedure TfrmMail.popClientFilesPopup(Sender: TObject);
begin
  pmiDelete.Enabled := lvClientFiles.SelCount > 0;
end;

procedure TfrmMail.lvAttachDblClick(Sender: TObject);
var
  ext: string;
begin
  if Assigned(lvAttach.Selected) then
  begin
    ext := Lowercase(ExtractFileExt(lvAttach.Selected.Caption));

    if (ext = '.doc') or (ext = '.pdf') then
    begin
      if lvAttach.Selected.SubItems.Count > 0 then
      begin
        ShellExecute(0, 'open', PChar(lvAttach.Selected.SubItems[0]), nil, nil, SW_NORMAL);
      end
      else
      begin
        ShellExecute(0, 'open', PChar(lvAttach.Selected.Caption), nil, nil, SW_NORMAL);
      end;
    end;
  end;
end;

// #1498 - if there is something in the listview then focus it
procedure TfrmMail.lvAttachEnter(Sender: TObject);
begin
  if (lvAttach.Items.Count > 0)
  and (lvAttach.SelCount = 0) then
  begin
    lvAttach.Items[0].Focused := True;
    lvAttach.Items[0].Selected := True;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.pmSelectEmail(Sender: TObject);
var
  s : string;
begin
  s := TMenuItem( Sender).Caption;
  s := Trim( Copy( s, Pos( #9, s) + 2, length( s)));

  if TMenuItem( Sender).Owner.Name = 'pmTo' then
  begin
    txtRecipient.Text := S;
    //see if this is a banklink address, if so clear the read-only flag
    if (IsEmailAddressSupport(txtRecipient.Text)) and chkCheckout.Visible then
    begin
      chkCheckout.checked := false;
      chkCheckout.Enabled := true;
    end
    else if Assigned(MyClient) and MyClient.clFields.clForce_Offsite_Check_Out then
    begin
      chkCheckout.Checked := true;
      chkCheckout.Enabled := false;
    end;
  end
  else
    txtCC.Text := S;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.FormShow(Sender: TObject);
begin
  SetupUI;
  Editor.FullPageMode := False;

  if Editmode then
     Editor.AddMergeMenuItem(MergeFieldNames[mf_Body], Ord(mf_Body))
  else begin
     if txtRecipient.Text <> '' then
        txtSubject.SetFocus
     else
       txtRecipient.SetFocus;
  end;
  Editor.LoadGlobalMergeMenues;
end;

function TfrmMail.GenerateRndFileName: string;
const
  CharArr : array [0..25] of char = ('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z') ;
  Capacity = 25;
var
  smbAmount : integer;
  smbToGet : integer;
  i : integer;
  sCurrentUsrDir : string;
begin
  Result := '';
  Randomize;
  smbAmount := Random(Capacity);
  for i := 0 to smbAmount do
  begin
    smbToGet := Random(Capacity);
    Result := Result + CharArr[smbToGet];
  end;
  sCurrentUsrDir := UserDir + RTFTemp;
  if not DirectoryExists(sCurrentUsrDir) then
  begin
    if not CreateDir(sCurrentUsrDir) then
      Result := ExtractFileDir(Application.ExeName) +'\'+ Result + '.rtf'
    else
      Result := sCurrentUsrDir + '\' + Result + '.rtf';
  end
  else
    Result := sCurrentUsrDir + '\' + Result + '.rtf';
end;

procedure TfrmMail.HideClientFiles;
begin
  //Hide client files components
  lvClientFiles.Visible := False;
  lblClientFiles.Visible := False;
  btnAttachClient.Visible := False;
  //Move and resize attachments components
  lvAttach.Height := lvAttach.Height + (lblClientFiles.Height +
                     //plus gap
                     (lvAttach.Top - (lblClientFiles.Top + lblClientFiles.Height)));
  lvAttach.Top := lvClientFiles.Top;
  lblAttachments.Top := lblClientFiles.Top;
  btnAttach.Top := btnAttachClient.Top;
end;

procedure TfrmMail.AddBitmap(aImageList: TImageList; aBmp: TBitmap; aBkColor: TColor);
var
  mask : TBitmap;
begin
  mask := TBitmap.Create;
  try
    mask.Assign(aBmp);
    mask.Canvas.Brush.Color := aBkColor;
    mask.Monochrome := true;

    aImageList.Add(aBmp, mask);
  finally
    mask.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMail.IsEmailAddressSupport(aEmail: string): boolean;
begin
  {$IFDEF SmartBooks}
    Result := (Pos('@SMARTBOOKS', Uppercase( aEmail)) > 0);
  {$ELSE}
    Result := (Pos( '@' + Uppercase(BRAND_SHORT_NAME), Uppercase( aEmail)) > 0) or
              (Pos( '@' + Uppercase(BRAND_SHORT_NAME_MAIN), Uppercase( aEmail)) > 0);
  {$ENDIF}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.LoadSignature;
begin
   if bkFileExists(SignatureFilename)then
      try
         Editor.ERTF.LoadFromFile(Emaildir + 'Signature' + tmpExt,True);
         SetUsage('Email Signature', 1);
      except
         on E:Exception do
           LogUtil.LogMsg( lmError, UnitName, 'Error loading email signature: ' + E.Message);
      end
   else begin
      Editor.Clear;
      SetUsage('Email Signature', 0);
   end;
end;



//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMail.ERichTextMailMergeGetText(Sender: TObject;
  const inspname: string; Contents: TWPMMInsertTextContents);

  function GetMergeText(Value: string): string;
  begin
     Result := '';
     if sametext(Value , MergeFieldNames[mf_Body]) then begin
        Result := fBodyText.Text; // yea right..
        fBodyMerged := true;
     end else
        Result := GetGlobalMergeText(Value);
  end;

begin
   Contents.StringValue := GetMergeText(inspname);
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMail.txtRecipientExit(Sender: TObject);
begin
  //see if this is a banklink address, if so clear the read-only flag
  if (IsEmailAddressSupport(txtRecipient.Text))
  and chkCheckout.Visible
  and (not FAllowCheckOutToSupport) then begin
     chkCheckout.checked := false;
     chkCheckout.Enabled := true;
  end else if Assigned(MyClient)
           and MyClient.clFields.clForce_Offsite_Check_Out then begin
     chkCheckout.Checked := true;
     chkCheckout.Enabled := false;
  end;
end;

Initialization
   DebugMe := DebugUnit(UnitName);


end.
