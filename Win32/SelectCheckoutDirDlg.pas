unit SelectCheckoutDirDlg;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons,
  bkXPThemes,
  OSFont;

type
  TdlgSelectCheckoutDir = class(TForm)
    lblDirLabel: TLabel;
    ePath: TEdit;
    btnFolder: TSpeedButton;
    btnOK: TButton;
    btnCancel: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnFolderClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function UpdateGlobalCheckoutDir : boolean;

//******************************************************************************
implementation
{$R *.dfm}
uses
  ImagesFrm,
  GenUtils,
  Globals,
  ShellUtils,
  WarningMoreFrm;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateGlobalCheckoutDir : boolean;
begin
  result := false;

  with  TdlgSelectCheckoutDir.Create(Application.Mainform ) do
  begin
    try
      ePath.Text  := Globals.INI_CheckOutDir;
      if ShowModal = mrOK then
      begin
        Globals.INI_CheckOutDir := ePath.Text;
        result := true;
      end;
    finally
      Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectCheckoutDir.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP,btnFolder.Glyph);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectCheckoutDir.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  SelectedDir : string;
begin
  if ModalResult = mrOK then
  begin
    CanClose := False;
    SelectedDir := Uppercase( AddSlash( ePath.Text));

    //make sure not trying to check in/out from the bk5 dir
    if SelectedDir = Uppercase( AddSlash( DATADIR)) then
    begin
      HelpfulWarningMsg( 'You cannot use the directory that contains your ' +
                         Globals.SHORTAPPNAME + ' data!'#13#13 +
                         'Please select another directory', 0);
      ePath.SetFocus;
      Exit;
    end;

    //check that the directory is valid
    if not (SelectedDir = 'A:\') then
    begin
      if not DirectoryExists(ePath.Text) then
      begin
        HelpfulWarningMsg( 'The Directory '+ePath.Text+' does not exist.'#13#13+
                           'Please enter a valid directory path.',0);
        ePath.Setfocus;
        exit;
      end;
    end;

    //nothing exited so allow to close
    ePath.Text := AddSlash( ePath.Text);
    CanClose := true;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgSelectCheckoutDir.btnFolderClick(Sender: TObject);
var
  SelectedDir : string;
begin
  SelectedDir := ePath.Text;
  //browse to a directory
  if BrowseFolder(SelectedDir, 'Select a folder' ) then
  begin
    ePath.Text        := SelectedDir;
  end;
end;

end.
