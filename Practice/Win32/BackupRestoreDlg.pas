unit BackupRestoreDlg;
//------------------------------------------------------------------------------
{
   Title:       Dialog for Backups

   Description: Allows the user to select a location to save an offsite backup to

   Author:      Matthew Hopkins  Jan 2004

   Remarks:     Validates the directory and makes sure media exists
                Cannot write directly to cd-rw drives, must use staging folder in XP

   Revisions:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,
  OSFont;

type
  TdlgBackupRestore = class(TForm)
    btnFolder: TSpeedButton;
    edtDir: TEdit;
    btnOk: TButton;
    btnCancel: TButton;
    chkOverwrite: TCheckBox;
    Label8: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnFolderClick(Sender: TObject);
  private
    { Private declarations }
    FClientCode : string;
  public
    { Public declarations }
  end;

  function GetBackupOptions( var aDir : string; var Overwrite : boolean; const ClientCode : string) : boolean;

//******************************************************************************
implementation
uses
  Backup,
  bkXPThemes,
  ImagesFrm,
  GlobalDirectories,
  Globals,
  InfoMoreFrm,
  WarningMoreFrm,
  WinUtils,
  ShellUtils,
  BkHelp;

{$R *.dfm}

function GetBackupOptions( var aDir : string;  var Overwrite : boolean; const ClientCode : string) : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:    return the options for backing up
//
// Parameters: aDir - default directory
//
// Result:     true if user selects a valid path
//- - - - - - - - - - - - - - - - - - - -
begin
  result := false;

  with TdlgBackupRestore.Create(Application.MainForm) do
  begin
    edtDir.Text := aDir;
    chkOverwrite.Checked := Overwrite;
    Caption := 'Backup Client File ' + ClientCode;
    FClientCode := ClientCode;

    if Assigned(Screen.ActiveForm) then
    begin
      PopupParent := Screen.ActiveForm;
      PopupMode := pmExplicit;
    end;
    
    if ShowModal = mrOK then
    begin
      aDir := edtDir.Text;
      Overwrite := chkOverwrite.Checked;
      result := true;
    end;
  end;
end;

procedure TdlgBackupRestore.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);
  BKHelpSetUp(Self, BKH_Backing_up_and_restoring_BankLink_Books_files);
end;

procedure TdlgBackupRestore.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  ErrorMsg : string;
  BackupFilename : string;
  EstimatedSize : int64;
  ErrorType : byte;
begin
  edtDir.Text := IncludeTrailingPathDelimiter( Trim( edtDir.Text));
  BackupFilename := FClientCode + Globals.OffsiteBackupExtn;

  SetCurrentDir( GlobalDirectories.glDataDir);
  EstimatedSize := WinUtils.GetFileSize( FClientCode + Globals.FILEEXTN) + 128;

  if ModalResult = mrOK then
  begin
    if not VerifyDirectory( edtDir.Text, chkOverwrite.Checked, False, ErrorMsg, ErrorType, BackupFilename, EstimatedSize) then
    begin
      if ErrorType = bkErrorMedia then
        HelpfulWarningMsg( ErrorMsg, 0, 'Cancel')
      else
        HelpfulWarningMsg( ErrorMsg, 0);
      CanClose := false;
      exit;
    end;
  end;
end;

procedure TdlgBackupRestore.btnFolderClick(Sender: TObject);
var
  test : string;
begin
  test := edtDir.Text;

  if BrowseFolder( test, 'Select a folder to backup this file to' ) then
    edtDir.Text := test;
end;

end.
