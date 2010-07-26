unit ClientLookupExFrm;
//------------------------------------------------------------------------------
{
   Title:       Client File Lookup

   Description:

   Author:      Matthew Hopkins Mar 2003

   Remarks:     Uses the client lookup frame

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ClientLookupFme, ExtCtrls, RzGroupBar, StdCtrls,
  OSFont;

type
  TCluOption = (
    coHideStatusColumn,    //hide the status column, cols shown code and name
    coHideViewButtons,     //dont allow the user to select view all/my files
    coAllowMultiSelected,  //allow multi select
    coShowAssignedToColumn
  );
  TCluOptions = set of TCluOption;

type
  TfrmClientLookup = class(TForm)
    pnlFrameHolder: TPanel;
    pnlButtons: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    rbAllFiles: TRadioButton;
    rbMyFiles: TRadioButton;
    ClientLookupFrame: TfmeClientLookup;

    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure rbAllFilesClick(Sender: TObject);
    procedure rbMyFilesClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure SelectionChanged( Sender : TObject);
    procedure FrameDblClick( Sender : TObject);
  private
    { Private declarations }
    FShowPopMenu: Boolean;
    procedure SetShowPopMenu(Value: Boolean);
  public
    { Public declarations }
    property ShowPopMenu: Boolean read FShowPopMenu write SetShowPopMenu;
  end;

const OpenCaption = '&Open';

function LookupClientCodes( Title         : string;
                            DefaultCode   : string;
                            luOptions     : TCluOptions;
                            OKCaption     : string = OpenCaption) : string;
//******************************************************************************
implementation

uses
  bkXPThemes, Globals, AppUserObj, Admin32, BKHelp, InfoMoreFrm, bkconst, VirtualTrees;

{$R *.dfm}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.FormShow(Sender: TObject);
begin
  ClientLookupFrame.SetFocusToGrid;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  ClientLookupFrame.DoCreate;
  ClientLookupFrame.ShowPopMenu := False;
  ShowPopMenu := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.FrameDblClick(Sender: TObject);
begin
  btnOK.Click;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.rbAllFilesClick(Sender: TObject);
begin
  ClientLookupFrame.ViewMode := vmAllFiles;
  if Self.Visible then
    ClientLookupFrame.SetFocusToGrid;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.rbMyFilesClick(Sender: TObject);
begin
  ClientLookupFrame.ViewMode := vmMyFiles;

  if ClientLookupFrame.vtClients.RootNodeCount = 0 then
  begin
    HelpfulInfoMsg( 'No files have been assigned to your user code, switching back to everyone''s files.',0);
    rbAllFilesClick( nil);
    rbAllFiles.Checked := true;
    rbMyFiles.Checked  := false;
  end
  else
    if Self.Visible then
      ClientLookupFrame.SetFocusToGrid;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
//cannot close using ok if nothing selected
begin
  if ModalResult = mrOK then
  begin
    if ( ClientLookupFrame.FirstSelectedCode = '') then
    begin
      CanClose := false;
      Exit;
    end;
  end;
  UserINI_Client_Lookup_Sort_Column := Ord(ClientLookupFrame.SortColumn);
  UserINI_Client_Lookup_Sort_Direction := Ord(ClientLookupFrame.SortDirection);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.SelectionChanged(Sender: TObject);
begin
  //
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmClientLookup.SetShowPopMenu(Value: Boolean);
begin
  if Assigned(ClientLookupFrame) then
    ClientLookupFrame.ShowPopMenu := Value;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LookupClientCodes( Title         : string;
                            DefaultCode   : string;
                            luOptions     : TCluOptions;
                            OKCaption     : string = OpenCaption) : string;
//returns a delimited list of client codes with quotes if in multi select mode
//or a single code if in single select mode
var
  ClientLookup : TfrmClientLookup;
  HideViewButtons : boolean;
  DefaultSort     : TClientLookupCol;
begin
  result := '';

  ClientLookup := TfrmClientLookup.Create( Application.MainForm);
  with ClientLookup do
  begin
    try
      BKHelpSetUp(ClientLookup, BKH_Opening_a_client_file);
      //load a snapshot of the admin system, if there is one
      if Assigned( Globals.AdminSystem) then
        Admin32.ReloadAdminAndTakeSnapshot( ClientLookupFrame.AdminSnapshot);

      Caption  := Title;
      ShowPopMenu := OKCaption = OpenCaption;
      //Set default width and height
      Height  := Round( Screen.WorkAreaHeight * 0.8);
      Width   := Round( Screen.WorkAreaWidth * 0.8 );
      //Position window
      Top     := ( Screen.WorkAreaHeight - Height ) div 2;
      Left    := ( Screen.WorkAreaWidth - Width ) div 2;

      with ClientLookupFrame do
      begin
        //restricted users cannot select all/visible because list would be
        //identical
        HideViewButtons := ( CurrUser.HasRestrictedAccess) or ( coHideViewButtons in luOptions);
        rbAllFiles.Visible    := ( not HideViewButtons) and ( Assigned( ClientLookupFrame.AdminSnapshot));
        rbMyFiles.Visible     := rbAllFiles.Visible;
        btnOK.Caption         := OKCaption;

        //set the view mode
        if coAllowMultiSelected in luOptions then
          SelectMode := smMultiple
        else
          SelectMode := smSingle;

        //add columns and build the grid
        ClearColumns;
        AddColumn( 'Code', 150, cluCode);
        AddColumn( 'Name', -1, cluName);

        DefaultSort := TClientLookupCol(UserINI_Client_Lookup_Sort_Column);

        if not ( coHideStatusColumn in luOptions) then
        begin
          AddColumn( 'Status', 200, cluStatus);
          if (Ord(DefaultSort) > Ord(cluStatus)) then
            DefaultSort := cluStatus;
        end;

        if ( coShowAssignedToColumn in luOptions) then
        begin
          AddColumn( 'Assigned To', 100, cluUser);
          if (Ord(DefaultSort) > Ord(cluUser)) or (Ord(DefaultSort) = Ord(cluStatus)) then
            DefaultSort := cluCode;
        end;

        BuildGrid( DefaultSort, TSortDirection(UserINI_Client_Lookup_Sort_Direction));
        //set the view mode, this will build reload the data
        if not HideViewButtons then
        begin
          case UserINI_CM_Default_View of
            0 : begin
              rbAllFiles.Checked := true;
            end;
            1 : begin
              rbMyFiles.Checked := true;
            end;
          else
            ViewMode := vmAllFiles;
          end;
        end
        else
          ViewMode   := vmAllFiles;

        //find the last mru code
        LocateCode( DefaultCode);
        //set up events
        OnSelectionChanged := SelectionChanged;
        OnGridDblClick     := FrameDblClick;


      end;

      if ShowModal = mrOK then
      begin
        if coAllowMultiSelected in luOptions then
          result := ClientLookupFrame.SelectedCodes
        else
          result := ClientLookupFrame.FirstSelectedCode;
      end;

      case ClientLookupFrame.ViewMode of
        vmAllFiles : UserINI_CM_Default_View := 0;
        vmMyFiles : UserINI_CM_Default_View := 1;
      else
        UserINI_CM_Default_View := 0;
      end;

    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
