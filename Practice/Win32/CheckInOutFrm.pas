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
  bkXPThemes,OsFont;

type
  TDialogMode = ( dmCheckout, dmCheckIn, dmSend);

type
  TfrmCheckInOut = class(TForm)
    pnlFooter: TPanel;
    pnlFrameHolder: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    chkAvailOnly: TCheckBox;
    lblDirLabel: TLabel;
    ePath: TEdit;
    btnFolder: TSpeedButton;
    ClientLookupFrame: TfmeClientLookup;
    pnSendOptions: TPanel;
    lblPreferredMethod: TLabel;
    rbStandard: TRadioButton;
    rbBankLinkOnline: TRadioButton;
    pnlPassword: TPanel;
    Label2: TLabel;
    eUsername: TEdit;
    Label3: TLabel;
    ePassword: TEdit;
    BitBtn1: TBitBtn;
    btnChangePassword: TButton;

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

  private
    { Private declarations }
    DialogMode : TDialogMode;
    TempCheckinPath   : string;

    procedure FrameDblClick(Sender: TObject);
    procedure SetupFrame;
    procedure SetupColumns;
    function GetSendMethod: byte;
  public
    { Public declarations }
    property SendMethod: byte read GetSendMethod;
  end;

  function SelectCodesToCheckout( Title : string; var ASendMethod: byte; SelectedCodes: string = '') : string;
  function SelectCodesToCheckin( Title : string; DefaultCodes : string = '') : string;
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
  BKConst,
  Virtualtrees,
  ChangePasswordFrm,
  IniSettings;

const
  MIN_STANDARD_WIDTH = 615;
  MIN_ONLINE_WIDTH = 1000;

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
  if (Shift = [ssCtrl]) then begin
    if Key in [Ord(66), Ord(98)] then
      rbBankLinkOnline.Checked := True
    else if Key in [Ord(83), Ord(115)] then
      rbStandard.Checked := True;
  end;
end;

// - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.FrameDblClick(Sender: TObject);
begin
  btnOK.Click;
end;
function TfrmCheckInOut.GetSendMethod: byte;
begin
  Result := smBankLinkOnline;
  if rbStandard.Checked then
    Result := smStandardFileTransfer;
end;

procedure TfrmCheckInOut.rbStandardClick(Sender: TObject);
begin
  SetupColumns;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToCheckout( Title : string; var ASendMethod: byte; SelectedCodes: string = '') : string;
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

      if Assigned( AdminSystem) then
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

      Caption                := Title;
      DialogMode             := dmCheckout;
      chkAvailOnly.Visible   := True;
      //chkAvailOnly.Checked   := True;
      ePath.Text             := Globals.INI_CheckOutDir;

      pnSendOptions.Visible    := True;
      rbBankLinkOnline.Enabled := True;
//      rbBankLinkOnline.Checked := True;
      pnlPassword.Visible := False;

      SetupFrame;

      if SelectedCodes <> '' then
        ClientLookupFrame.SelectedCodes := SelectedCodes;

      //Set the send method based in the send methods of the client files  
      case ClientLookupFrame.GetSendMethod of
        smBankLinkOnline       : rbBankLinkOnline.Checked := True;
        smStandardFileTransfer : rbStandard.Checked := True;
      end;

      if ShowModal = mrOK then
      begin
        Globals.INI_CheckOutDir := AddSlash( ePath.Text);
        ASendMethod := CheckInOut.SendMethod;
        Result := ClientLookupFrame.SelectedCodes;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToCheckin( Title : string; DefaultCodes : string = '') : string;
var
  CheckInOut : TfrmCheckInOut;
begin
  result := '';

  CheckInOut := TfrmCheckInOut.Create(Application.MainForm);
  with CheckInOut do
  begin
    try
      BKHelpSetup(CheckInOut, BKH_Check_in_facility);
      if Assigned( AdminSystem) then
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

      Caption                := Title;
      DialogMode             := dmCheckin;
      chkAvailOnly.Visible   := False;
      lblDirLabel.Caption    := '&Check files in from';

      ePath.Text             := Globals.INI_CheckInDir;
      TempCheckinPath        := ePath.Text;

      pnSendOptions.Visible := False;
      pnlPassword.Visible   := False;
      if not Assigned( AdminSystem) then begin
        pnSendOptions.Visible := True;
        lblPreferredMethod.Caption := 'Select the preferred method of importing the selected client(s)';
        pnlPassword.Visible := True;
        eUsername.Text := Globals.INI_BankLink_Online_Username;
        ePassword.Text := Globals.INI_BankLink_Online_Password;
      end;

      SetupFrame;
      ClientLookupFrame.SelectedCodes := DefaultCodes;

      if ShowModal = mrOK then
      begin
        Globals.INI_CheckInDir := AddSlash( ePath.Text);
        Globals.INI_BankLink_Online_Username := Trim(eUsername.Text);
        Globals.INI_BankLink_Online_Password := Trim(ePassword.Text);        
        result := ClientLookupFrame.SelectedCodes;
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
      if Assigned( AdminSystem) then
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

      Caption                := Title;
      DialogMode             := dmSend;
      chkAvailOnly.Visible   := True;
      lblDirLabel.Visible    := False;
      ePath.Visible          := false;
      btnFolder.Visible      := false;
      pnlFooter.Height       := pnlFooter.Height - 25;

      pnSendOptions.Visible    := True;
      rbStandard.Checked     := True;
      rbBankLinkOnline.Enabled := False;
      Width := MIN_STANDARD_WIDTH;
      pnlPassword.Visible := False;

      //chkAvailOnly.Checked   := True;
      ePath.Text             := '';
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
      chkAvailOnly.Visible   := True;
      lblDirLabel.Visible    := False;
      ePath.Visible          := false;
      btnFolder.Visible      := false;
      pnlFooter.Height       := pnlFooter.Height - 25;
      if not Multiple then
        ClientLookupFrame.SelectMode := smSingle;
      ePath.Text             := '';

      pnSendOptions.Visible := False;
      pnlPassword.Visible := False;      

      SetupFrame;
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
      if (DialogMode in [ dmCheckOut, dmSend]) and ( Codes = '') then
        Exit;

      //reload the tree if nothing selected during check in
      if ( DialogMode = dmCheckIn) and ( Codes = '') then
      begin
        ClientLookupFrame.FilesDirectory := SelectedDir;
        ClientLookupFrame.Reload;
        Exit;
      end;

      //check that the directory is valid
      if not (SelectedDir = 'A:\') then
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
  UserINI_Client_Lookup_Sort_Column := Ord(ClientLookupFrame.SortColumn);
  UserINI_Client_Lookup_Sort_Direction := Ord(ClientLookupFrame.SortDirection);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.btnChangePasswordClick(Sender: TObject);
var
  NewPassword: string;
begin
  if ChangePasswordFrm.ChangeBankLinkOnlinePassword(eUserName.Text, ePassword.Text, NewPassword) then begin
    ePassword.Text := NewPassword;
    Globals.INI_BankLink_Online_Password := NewPassword;
    IniSettings.BK5WriteINI;
  end;
end;

procedure TfrmCheckInOut.chkAvailOnlyClick(Sender: TObject);
begin
  if chkAvailOnly.checked then
    ClientLookupFrame.FilterMode := fmFilesForCheckOut
  else
    ClientLookupFrame.FilterMode := fmNoFilter;

  ClientLookupFrame.Reload;
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
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.SetupColumns;
var
  i: integer;
  Column: TCluColumnDefn;
  ShowDir: boolean;
begin
  for i := 0 to ClientLookupFrame.Columns.Count - 1 do begin
    Column := ClientLookupFrame.Columns.ColumnDefn_At(i);
    if Column.FieldID in [cluBankLinkOnline, cluModifiedBy, cluModifiedDate] then
      Column.Visible := rbBankLinkOnline.Checked;
  end;

  if rbBankLinkOnline.Checked then
    Constraints.MinWidth := MIN_ONLINE_WIDTH
  else begin
    Constraints.MinWidth := MIN_STANDARD_WIDTH;
    Width := MIN_STANDARD_WIDTH;
  end;

  //Show 'Check out files to'
  ShowDir := rbStandard.Checked and rbBankLinkOnline.Enabled;
  lblDirLabel.Visible := ShowDir;
  ePath.Visible := ShowDir;
  btnFolder.Visible := ShowDir;

  ClientLookupFrame.BuildGrid(ClientLookupFrame.SortColumn);
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
    AddColumn( 'BankLink Online', 245, cluBankLinkOnline);
    AddColumn( 'Modified By', 100, cluModifiedBy);
    AddColumn( 'Modified Date', 100, cluModifiedDate);

    SetupColumns;

    DefaultSort := TClientLookupCol(UserINI_Client_Lookup_Sort_Column);
    if Ord(DefaultSort) > Ord(cluStatus) then
      DefaultSort := cluStatus;
    BuildGrid( DefaultSort, TSortDirection(UserINI_Client_Lookup_Sort_Direction));
    //set the filter mode
    case DialogMode of
      dmCheckout, dmSend : FilterMode := fmFilesForCheckOut;
      dmCheckIn :
      begin
        FilterMode := fmFilesForCheckIn;
        FilesDirectory := Globals.INI_CheckInDir;
      end;
    end;
    //set the view mode, this will reload the data
    ViewMode   := vmAllFiles;
    //set up events
    OnGridDblClick     := FrameDblClick;

    //select current file is one is open
    if (DialogMode = dmCheckout) and ( Assigned( MyClient)) then
      LocateCode( MyClient.clFields.clCode);
  end;
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
