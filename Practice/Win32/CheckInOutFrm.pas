unit CheckInOutFrm;
//------------------------------------------------------------------------------
{
   Title:       Check In / Check Out files dialog

   Description:

   Author:      Matthew Hopkins  Apr 2003

   Remarks:     Now uses client lookup frame

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, ClientLookupFme,
  bkXPThemes, BKConst, OsFont;

type
  TDialogMode = ( dmCheckout, dmCheckIn, dmSend);

type
  TfrmCheckInOut = class(TForm)
    pnlFooter: TPanel;
    pnlFrameHolder: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    chkAvailOnly: TCheckBox;
    ClientLookupFrame: TfmeClientLookup;
    pnlPassword: TPanel;
    btnRefresh: TBitBtn;
    btnChangePassword: TButton;
    pnlBrowseDir: TPanel;
    lblDirLabel: TLabel;
    ePath: TEdit;
    btnFolder: TSpeedButton;
    cbFlagReadOnly: TCheckBox;
    cbEditEmail: TCheckBox;
    cbSendEmail: TCheckBox;
    btnEditConnection: TButton;
    Panel1: TPanel;
    lblBankLinkOnline: TLabel;

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkAvailOnlyClick(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure ePathEnter(Sender: TObject);
    procedure ePathExit(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure rbStandardClick(Sender: TObject);
    procedure btnChangePasswordClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnEditConnectionClick(Sender: TObject);

  private
    { Private declarations }
    DialogMode : TDialogMode;
    TempCheckinPath   : string;
    FFileTransferMethod: Byte;

    procedure FrameDblClick(Sender: TObject);
    procedure SetupFrame;
    procedure SetupColumns;
    procedure CloseupCheckboxes;
    procedure SetCheckBoxOptions;
    procedure ShowBanklinkOnlineStatus;
  public
    { Public declarations }
  end;

  function SelectCodesToSend(Title : string; ASendMethod: Byte; var AFirstUpload: boolean;
                             var AFlagReadOnly, AEditEmail, ASendEmail: boolean;
                             SelectedCodes: string = '') : string;
  function SelectCodesToGet( Title : string; ASendMethod: Byte; DefaultCodes : string = '') : string;
  function SelectCodesToAttach( Title : string) : string;
  function SelectCodeToLookup( Title : string; DefaultCode: string = ''; Multiple: Boolean = True) : string;

//******************************************************************************
implementation

uses
  ShellUtils,
  Admin32,
  BKHelp,
  Globals,
  GenUtils,
  ImagesFrm,
  WarningMoreFrm,
  Virtualtrees,
  IniSettings,
  BankLinkOnline,
  ErrorMoreFrm,
  InfoMoreFrm;

const
//  MIN_STANDARD_WIDTH = 615; //Original dialog width
  MIN_STANDARD_WIDTH = 900;
  MIN_ONLINE_WIDTH = 900;

{$R *.dfm}

procedure TfrmCheckInOut.FormCreate(Sender: TObject);
begin
  //create and align the frame
  bkXPThemes.ThemeForm(Self);
  ClientLookupFrame.DoCreate;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);
end;

procedure TfrmCheckInOut.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin

end;

// - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.FrameDblClick(Sender: TObject);
begin
  btnOK.Click;
end;

procedure TfrmCheckInOut.rbStandardClick(Sender: TObject);
begin
  SetupColumns;
  ClientLookupFrame.Reload;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToSend( Title : string; ASendMethod: Byte; var AFirstUpload: boolean;
  var AFlagReadOnly, AEditEmail, ASendEmail: boolean; SelectedCodes: string = '') : string;
//the path is the path to check the files out to
var
  CheckInOut : TfrmCheckInOut;
begin
  result := '';

  CheckInOut := TfrmCheckInOut.Create(Application.MainForm);
  with CheckInOut do
  begin
    try
      BKHelpSetup(CheckInOut, BKH_Check_out_facility);

      FFileTransferMethod := ASendMethod;
      Caption                := Title;
      DialogMode             := dmCheckout;
      lblDirLabel.Caption    := 'Send &files to';
      ePath.Text             := Globals.INI_CheckOutDir;

      if Assigned( AdminSystem) then begin
        //Practice
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);
        chkAvailOnly.Visible   := True;
        cbFlagReadOnly.Visible := false;
        cbEditEmail.Visible    := False;
        cbSendEmail.Visible    := (FFileTransferMethod = ftmOnline);
        pnlPassword.Visible := False;
      end else begin
        //Books
        chkAvailOnly.Visible   := True;
        cbFlagReadOnly.Visible := not (FFileTransferMethod in [ftmFile]);
        cbEditEmail.Visible := (FFileTransferMethod = ftmOnline);
        cbSendEmail.Visible := False;
        pnlPassword.Visible := True;
      end;

      SetCheckBoxOptions;
      CloseupCheckboxes;
      SetupFrame;

      //Don't show dialog for BankLink Online if no connection
      if (FFileTransferMethod = ftmOnline) and ClientLookupFrame.NoOnlineConnection then
        Exit;

      ShowBanklinkOnlineStatus;

      if (FFileTransferMethod = ftmOnline) then
        btnOK.Caption := '&Upload';

      if SelectedCodes <> '' then
        ClientLookupFrame.SelectedCodes := SelectedCodes;

      if ShowModal = mrOK then
      begin
        Globals.INI_CheckOutDir := AddSlash( ePath.Text);
        //Setting
        AFirstUpload := ClientLookupFrame.FirstUpload;
        //Only change the flag as read-only default if this option is visible (TFS 36509)
        AFlagReadOnly := True;
        if cbFlagReadOnly.Visible then
          AFlagReadOnly := cbFlagReadOnly.Checked;
        AEditEmail := cbEditEmail.Checked;
        ASendEmail := cbSendEmail.Checked;
        Result := ClientLookupFrame.SelectedCodes;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToGet( Title : string; ASendMethod: Byte; DefaultCodes : string = '') : string;
var
  CheckInOut : TfrmCheckInOut;
begin
  result := '';

  CheckInOut := TfrmCheckInOut.Create(Application.MainForm);
  with CheckInOut do
  begin
    try
      BKHelpSetup(CheckInOut, BKH_Check_in_facility);
      FFileTransferMethod    := ASendMethod;
      Caption                := Title;
      DialogMode             := dmCheckin;
      chkAvailOnly.Visible   := False;
      lblDirLabel.Caption    := '&Get files from';
      ePath.Text             := Globals.INI_CheckInDir;
      TempCheckinPath        := ePath.Text;

      if Assigned( AdminSystem) then begin
        //practice
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);
        chkAvailOnly.Visible   := False;
        cbFlagReadOnly.Visible := False;
        cbEditEmail.Visible    := False;
        cbSendEmail.Visible    := False;
        pnlPassword.Visible    := False;
      end else begin
        //Books
        chkAvailOnly.Visible   := False;
        cbFlagReadOnly.Visible := False;
        cbEditEmail.Visible    := False;
        cbSendEmail.Visible    := False;
        pnlPassword.Visible    := True;
      end;

      SetCheckBoxOptions;
      CloseupCheckboxes;
      SetupFrame;

      //Don't show dialog for BankLink Online if no connection
      if (FFileTransferMethod = ftmOnline) and ClientLookupFrame.NoOnlineConnection then
        Exit;
      ShowBanklinkOnlineStatus;

      ClientLookupFrame.SelectedCodes := DefaultCodes;

      if ShowModal = mrOK then
      begin
        Globals.INI_CheckInDir := AddSlash( ePath.Text);
        Result := ClientLookupFrame.SelectedCodes;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToAttach( Title : string) : string;
begin
  result := '';

  with TfrmCheckInOut.Create(Application.MainForm) do
  begin
    try
      FFileTransferMethod := ftmEmail;
      Caption                := Title;
      DialogMode             := dmSend;
      pnlBrowseDir.Visible   := False;
      pnlPassword.Visible := False;
      Width := MIN_STANDARD_WIDTH;

      if Assigned(AdminSystem) then begin
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);
        chkAvailOnly.Visible   := True;
        cbFlagReadOnly.Visible := False;
        cbEditEmail.Visible    := False;
        cbSendEmail.Visible    := False
      end else begin
        chkAvailOnly.Visible   := True;
        cbFlagReadOnly.Visible := False;
        cbEditEmail.Visible := False;
        cbSendEmail.Visible := False;
      end;

      ePath.Text             := '';

      SetCheckBoxOptions;
      CloseupCheckboxes;
      SetupFrame;
      
      if ShowModal = mrOK then
      begin
        result := ClientLookupFrame.SelectedCodes;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodeToLookup( Title : string; DefaultCode: string = ''; Multiple: Boolean = True) : string;
begin
  result := '';

  with TfrmCheckInOut.Create(Application.MainForm) do
  begin
    try
      if Assigned( AdminSystem) then
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

      Caption                := Title;
      DialogMode             := dmSend;

      if not Multiple then
        ClientLookupFrame.SelectMode := smSingle;
      ePath.Text             := '';

      //Don't show any checkbox option for scheduled reports
      chkAvailOnly.Visible   := False;
      cbFlagReadOnly.Visible := False;
      cbEditEmail.Visible    := False;
      cbSendEmail.Visible    := False;

      chkAvailOnly.checked := False;
      ClientLookupFrame.FilterMode := fmNoFilter;
      //SetCheckBoxOptions; - Don't set for scheduled reports
      CloseupCheckboxes;
      SetupFrame;

      pnlPassword.Visible := False;
      pnlBrowseDir.Visible := False;

      ClientLookupFrame.SelectedCodes := DefaultCode;
      if ShowModal = mrOK then
        result := ClientLookupFrame.SelectedCodes;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Codes : string;
  SelectedDir : string;
begin
  if ModalResult = mrOK then
  begin
    CanClose := False;
    Codes := ClientLookupFrame.SelectedCodes;

    if (DialogMode <> dmSend) then
    begin
      SelectedDir := Uppercase( AddSlash( ePath.Text));

      //make sure exit event fired for path
      ePathExit( Self);

      //make sure not trying to check in/out from the bk5 dir
      if SelectedDir = Uppercase( AddSlash( DATADIR)) then
      begin
        HelpfulWarningMsg( 'You cannot use the directory that contains your ' +
                           Globals.SHORTAPPNAME + ' data!'#13#13 +
                           'Please select another directory', 0);
        ePath.SetFocus;
        Exit;
      end;

      //must select something if using checkout
      if (DialogMode in [ dmCheckOut, dmSend]) and ( Codes = '') then begin
        if (FFileTransferMethod = ftmOnline) then
          HelpfulWarningMsg('Please select a client to send to ' + BANKLINK_ONLINE_NAME, 0);
        Exit;
      end;

      //reload the tree if nothing selected during check in
      if ( DialogMode = dmCheckIn) and ( Codes = '') then
      begin
        if (FFileTransferMethod = ftmOnline) then
          HelpfulWarningMsg('Please select a client to update from ' + BANKLINK_ONLINE_NAME, 0)
        else begin
          ClientLookupFrame.FilesDirectory := SelectedDir;
          ClientLookupFrame.Reload;
        end;
        Exit;
      end;

      //check that the directory is valid
      if not (SelectedDir = 'A:\') and (FFileTransferMethod <> ftmOnline) then
      begin
        if not DirectoryExists( SelectedDir) then
        begin
          HelpfulWarningMsg( 'The Directory '+ SelectedDir+' does not exist.'#13#13+
                             'Please enter a valid directory path.',0);
          ePath.Setfocus;
          exit;
        end;
      end;

      //nothing exited so allow to close
      ePath.Text := AddSlash( ePath.Text);
    end;
    CanClose := true;
  end;
  UserINI_Client_Lookup_Sort_Column    := Ord(ClientLookupFrame.SortColumn);
  UserINI_Client_Lookup_Sort_Direction := Ord(ClientLookupFrame.SortDirection);
//  UserINI_Client_Lookup_Available_Only := chkAvailOnly.Checked;
  UserINI_Client_Lookup_Flag_Read_Only := cbFlagReadOnly.Checked;
  UserINI_Client_Lookup_Edit_Email     := cbEditEmail.Checked;
  UserINI_Client_Lookup_Send_Email     := cbSendEmail.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.btnRefreshClick(Sender: TObject);
begin
  ClientLookupFrame.Reload;
  ShowBanklinkOnlineStatus;
end;

procedure TfrmCheckInOut.btnEditConnectionClick(Sender: TObject);
begin
  ClientLookupFrame.EditBooksBankLinkOnlineLogin;
  ShowBanklinkOnlineStatus
end;

procedure TfrmCheckInOut.btnChangePasswordClick(Sender: TObject);
begin
  try
    if ClientLookupFrame.CheckBooksLogin then
      ClientLookupFrame.ChangeBooksPassword;
  except
    on E: exception do
      begin
        HelpfulErrorMsg('Unable to change password: ' + E.Message, 0);
        Exit;
      end;
  end;
  ShowBanklinkOnlineStatus;  
end;

procedure TfrmCheckInOut.chkAvailOnlyClick(Sender: TObject);
begin
  if chkAvailOnly.checked then begin
    case DialogMode of
      dmCheckout,
      dmSend    : ClientLookupFrame.FilterMode := fmFilesForCheckOut;
      dmCheckIn : ClientLookupFrame.FilterMode := fmFilesForCheckIn;
    end;
  end else
    ClientLookupFrame.FilterMode := fmNoFilter;

  ClientLookupFrame.Reload;
end;

procedure TfrmCheckInOut.CloseupCheckboxes;
var
  CheckBoxHeight: integer;
  MinimumHeight: integer;
begin
  //Close-up check boxes
  CheckBoxHeight := (cbFlagReadOnly.Top - chkAvailOnly.Top);
  MinimumHeight := btnOK.Height + chkAvailOnly.Height;

  if not chkAvailOnly.Visible then begin
    pnlFooter.Height := (pnlFooter.Height - CheckBoxHeight);
    cbFlagReadOnly.Top := chkAvailOnly.Top;
  end;
  if not cbFlagReadOnly.Visible then begin
    pnlFooter.Height := (pnlFooter.Height - CheckBoxHeight);
    cbEditEmail.Top := cbFlagReadOnly.Top;
  end;
  if not cbEditEmail.Visible then begin
    pnlFooter.Height := (pnlFooter.Height - CheckBoxHeight);
    cbSendEmail.Top := cbEditEmail.Top;
  end;
  if not cbSendEmail.Visible then
    pnlFooter.Height := (pnlFooter.Height - CheckBoxHeight);

  if (pnlFooter.Height < MinimumHeight) then
    pnlFooter.Height := MinimumHeight;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.btnFolderClick(Sender: TObject);
var
  SelectedDir : string;
begin
  SelectedDir := ePath.Text;
  //browse to a directory
  if BrowseFolder(SelectedDir, 'Select a folder' ) then
  begin
    ePath.Text        := SelectedDir;
    TempCheckInPath   := SelectedDir;

    if DialogMode = dmCheckIn then
    begin
      ClientLookupFrame.FilesDirectory := SelectedDir;
      ClientLookupFrame.Reload;
    end;
  end;
end;
procedure TfrmCheckInOut.btnOKClick(Sender: TObject);
begin

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.SetCheckBoxOptions;
begin
  chkAvailOnly.Checked := (not chkAvailOnly.Visible) or
                          (not (ClientLookupFrame.FilterMode = fmNoFilter)) or
                          (DialogMode in [dmSend, dmCheckOut]);
  if chkAvailOnly.checked then begin
    case DialogMode of
      dmCheckout,
      dmSend    : ClientLookupFrame.FilterMode := fmFilesForCheckOut;
      dmCheckIn : ClientLookupFrame.FilterMode := fmFilesForCheckIn;
    end;
  end else
    ClientLookupFrame.FilterMode := fmNoFilter;

  cbFlagReadOnly.Checked := UserINI_Client_Lookup_Flag_Read_Only;
  cbEditEmail.Checked    := UserINI_Client_Lookup_Edit_Email;
  cbSendEmail.Checked    := UserINI_Client_Lookup_Send_Email;
end;

procedure TfrmCheckInOut.SetupColumns;
var
  i: integer;
  Column: TCluColumnDefn;
begin
  for i := 0 to ClientLookupFrame.Columns.Count - 1 do begin
    Column := ClientLookupFrame.Columns.ColumnDefn_At(i);
    if Column.FieldID in [cluBankLinkOnline, cluModifiedDate] then
      Column.Visible := (FFileTransferMethod = ftmOnline);
  end;

  if (FFileTransferMethod = ftmOnline) then begin
    Constraints.MinWidth := MIN_ONLINE_WIDTH
  end else begin
    Constraints.MinWidth := MIN_STANDARD_WIDTH;
    Width := MIN_STANDARD_WIDTH;
  end;

  //Show 'Check out files to'
  pnlBrowseDir.Visible := not (FFileTransferMethod in [ftmOnline, ftmEmail]);

  //Hide username and password in Books for standard file transfer
  if not Assigned(AdminSystem) then
    pnlPassword.Visible := (FFileTransferMethod = ftmOnline);

  ClientLookupFrame.BuildGrid(ClientLookupFrame.SortColumn);

  //Set a flag in the frame to say what it's being used for
  ClientLookupFrame.FrameUseMode := fumNone;
  case FFileTransferMethod of
    ftmOnline:
      case DialogMode of
        dmCheckout,
        dmSend   : ClientLookupFrame.FrameUseMode := fumSendOnline;
        dmCheckIn: ClientLookupFrame.FrameUseMode := fumGetOnline;
      end;
    ftmFile,
    ftmEmail:
      case DialogMode of
        dmCheckout,
        dmSend   : ClientLookupFrame.FrameUseMode := fumSendFile;
        dmCheckIn: ClientLookupFrame.FrameUseMode := fumGetFile;
      end;
  end;

end;

procedure TfrmCheckInOut.SetupFrame;
var
  DefaultSort: TClientLookupCol;
begin
  with ClientLookupFrame do
  begin
    ClearColumns;
    AddColumn( 'Code', 110, cluCode);
    AddColumn( 'Name', -1, cluName);
    AddColumn( 'Status', 150, cluStatus);
    AddColumn( BANKLINK_ONLINE_NAME + ' Status', 245, cluBankLinkOnline);
    AddColumn( 'Modified Date', 100, cluModifiedDate);

    SetupColumns;

    DefaultSort := TClientLookupCol(UserINI_Client_Lookup_Sort_Column);
    if Ord(DefaultSort) > Ord(cluStatus) then
      DefaultSort := cluStatus;
    BuildGrid( DefaultSort, TSortDirection(UserINI_Client_Lookup_Sort_Direction));
    //set the filter mode
//    case DialogMode of
//      dmCheckout, dmSend : FilterMode := fmFilesForCheckOut;
//      dmCheckIn :
//      begin
//        FilterMode := fmFilesForCheckIn;
//        FilesDirectory := Globals.INI_CheckInDir;
//      end;
//    end;

    if (DialogMode = dmCheckIn) then
      FilesDirectory := Globals.INI_CheckInDir;

    //set the view mode, this will reload the data
    ViewMode   := vmAllFiles;

    //set up events
    OnGridDblClick     := FrameDblClick;

    //select current file is one is open
    if (DialogMode = dmCheckout) and ( Assigned( MyClient)) then
      LocateCode( MyClient.clFields.clCode);
  end;
end;

procedure TfrmCheckInOut.ShowBanklinkOnlineStatus;
begin
  if Assigned(AdminSystem) then Exit;

  if ClientLookupFrame.NoOnlineConnection then
    lblBankLinkOnline.Caption := BANKLINK_ONLINE_NAME + ' Status: NOT CONNECTED'
  else
    lblBankLinkOnline.Caption := BANKLINK_ONLINE_NAME + ' Status: CONNECTED';
  lblBankLinkOnline.Caption := lblBankLinkOnline.Caption + #10 + 'Subdomain: ' +
                               Globals.INI_BankLink_Online_SubDomain;
  lblBankLinkOnline.Caption := lblBankLinkOnline.Caption + #10 + 'Username: ' +
                               Globals.INI_BankLink_Online_Username;
end;

procedure TfrmCheckInOut.ePathEnter(Sender: TObject);
begin
  TempCheckinPath := ePath.Text;
end;

procedure TfrmCheckInOut.ePathExit(Sender: TObject);
begin
  if DialogMode = dmCheckIn then
  begin
    //need to detect if the user changed the path
    if ( TempCheckInPath <> ePath.Text) then
    //path has changed, clear the selection to force ok to reload list
    begin
      ClientLookupFrame.ClearSelection;
      TempCheckInPath := ePath.Text;
      ClientLookupFrame.FilesDirectory := TempCheckInPath;
      ClientLookupFrame.Reload;
    end;
  end;
end;

procedure TfrmCheckInOut.FormShow(Sender: TObject);
begin
  ClientLookupFrame.SetFocusToGrid;
end;


end.
