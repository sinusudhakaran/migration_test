unit CAFOutputSelectorFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, OSFont, CAFImporter;

type
  TfrmCAFOutputSelector = class(TForm)
    cmbFileFormat: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    edtSaveTo: TEdit;
    btnSave: TButton;
    btnCancel: TButton;
    btnToFolder: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnSaveClick(Sender: TObject);
    procedure btnToFolderClick(Sender: TObject);
  private
    fImportType: TCAFImportType;

    function ValidateForm: Boolean;
    function GetFileFormat: TCAFFileFormat;
    function GetOutputFolder: String;
  public
    class function SelectOutput(Owner: TComponent; PopupParent: TCustomForm; out FileFormat: TCAFFileFormat; out OutputFolder: String; aImportType: TCAFImportType): Boolean; static;

    property FileFormat: TCAFFileFormat read GetFileFormat;
    property OutputFolder: String read GetOutputFolder;
  end;

var
  frmCAFOutputSelector: TfrmCAFOutputSelector;

implementation

uses
  YesNoDlg,
  ShellUtils,
  Imagesfrm,
  ErrorMoreFrm,
  StdHints,
  Globals,
  GenUtils,
  BKHelp;

{$R *.dfm}

procedure TfrmCAFOutputSelector.btnSaveClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    ModalResult := mrOK;
  end;
end;

procedure TfrmCAFOutputSelector.btnToFolderClick(Sender: TObject);
var
  Path: String;
begin
  if BrowseFolder( Path, 'Select the Folder to Save Entries To' ) then
  begin
    edtSaveTo.Text := Path;
  end;
end;

procedure TfrmCAFOutputSelector.FormCreate(Sender: TObject);
begin
  cmbFileFormat.ItemIndex := 0;

  ActiveControl := edtSaveTo;
  
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP, btnToFolder.Glyph);

  btnToFolder.Hint := DirButtonHint;
end;

procedure TfrmCAFOutputSelector.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
  begin
    ModalResult := mrCancel;
  end
  else if Key = VK_RETURN then
  begin
    if ValidateForm then
    begin
      ModalResult := mrOK;
    end;
  end;
end;

function TfrmCAFOutputSelector.GetFileFormat: TCAFFileFormat;
begin
  Result := TCAFFileFormat(cmbFileFormat.ItemIndex);
end;

function TfrmCAFOutputSelector.GetOutputFolder: String;
begin
  Result := edtSaveTo.Text;
end;

class function TfrmCAFOutputSelector.SelectOutput(Owner: TComponent; PopupParent: TCustomForm; out FileFormat: TCAFFileFormat; out OutputFolder: String; aImportType: TCAFImportType): Boolean;
var
  OutputSelector: TfrmCAFOutputSelector; 
begin
  OutputSelector := TfrmCAFOutputSelector.Create(Owner);
  OutputSelector.fImportType := aImportType;
  try
    if OutputSelector.ShowModal = mrOK then
    begin
      FileFormat := OutputSelector.FileFormat;
      OutputFolder := OutputSelector.OutputFolder;

      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    OutputSelector.Free;
  end;
end;

function TfrmCAFOutputSelector.ValidateForm: Boolean;
begin
  Result := False;

  if Trim(edtSaveTo.Text) = '' then
  begin
    HelpfulErrorMsg('The Save To field cannot be blank. Please specify Save To path.', 0);

    edtSaveTo.SetFocus;

    Exit;
  end;

  //This should always be called last
  if not DirectoryExists(edtSaveTo.Text) then
  begin
    if AskYesNo('Create directory', 'The specified directory does not exist. ' + #10#13#10#13 + 'Create the directory automatically?', DLG_NO, 0) = DLG_YES then
    begin
      CreateDir(edtSaveTo.Text);

      if not DirectoryExists(edtSaveTo.Text) then
      begin
        HelpfulErrorMsg('The specified directory path could not be created. Please make sure you have the required permissions.', 0);
      end;
    end
    else
    begin
      edtSaveTo.SetFocus;

      Exit;
    end;
  end;

  if ((fImportType = cafHSBCUK)     and (FindFilesLike(edtSaveTo.Text, 'HSBC Customer Authority*.pdf'))) or
     ((fImportType = cafStandardUK) and (FindFilesLike(edtSaveTo.Text, 'Customer Authority*.pdf')))      then
  begin
    if AskYesNo('Overwrite File', 'This process may overwrite existing Customer Authority Forms in this folder. ' + #10#13#10#13 + 'Are you sure you want to continue?', DLG_NO, 0) = DLG_NO then
    begin
      cmbFileFormat.SetFocus;
      Exit;
    end;
  end;

  Result := True;
end;

end.
