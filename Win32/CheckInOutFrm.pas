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

    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure chkAvailOnlyClick(Sender: TObject);
    procedure btnFolderClick(Sender: TObject);
    procedure ePathEnter(Sender: TObject);
    procedure ePathExit(Sender: TObject);
    procedure FormShow(Sender: TObject);

  private
    { Private declarations }
    DialogMode : TDialogMode;
    TempCheckinPath   : string;

    procedure FrameDblClick(Sender: TObject);
    procedure SetupFrame;
  public
    { Public declarations }
  end;

  function SelectCodesToCheckout( Title : string) : string;
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
  Virtualtrees;

{$R *.dfm}

procedure TfrmCheckInOut.FormCreate(Sender: TObject);
begin
  //create and align the frame
  bkXPThemes.ThemeForm(Self);
  ClientLookupFrame.DoCreate;
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);
end;
// - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmCheckInOut.FrameDblClick(Sender: TObject);
begin
  btnOK.Click;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectCodesToCheckout( Title : string) : string;
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
      SetupFrame;
      if ShowModal = mrOK then
      begin
        Globals.INI_CheckOutDir := AddSlash( ePath.Text);
        result := ClientLookupFrame.SelectedCodes;
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

      SetupFrame;
      ClientLookupFrame.SelectedCodes := DefaultCodes;

      if ShowModal = mrOK then
      begin
        Globals.INI_CheckInDir := AddSlash( ePath.Text);
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
procedure TfrmCheckInOut.SetupFrame;
var
  DefaultSort: TClientLookupCol;
begin
  with ClientLookupFrame do
  begin
    //add columns and build the grid
    ClearColumns;
    AddColumn( 'Code', 150, cluCode);
    AddColumn( 'Name', -1, cluName);
    AddColumn( 'Status', 150, cluStatus);
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
