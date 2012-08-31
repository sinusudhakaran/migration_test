unit CAFImportSelectorFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls, Buttons, CAFImporter;

type
  TfrmCAFImportSelector = class(TForm)
    cmbInstitution: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    edtImportFile: TEdit;
    btnImport: TButton;
    btnCancel: TButton;
    btnToFolder: TSpeedButton;
    dlgOpen: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure btnToFolderClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
  private
    function ValidateForm: Boolean;
    function GetImportFile: String;
    function GetImportType: TCAFImportType;
  public
    class function SelectImport(Owner: TComponent; PopupParent: TCustomForm; out ImportType: TCAFImportType; out ImportFile: String): Boolean; static;

    property ImportType: TCAFImportType read GetImportType;
    property ImportFile: String read GetImportFile;
  end;

var
  frmCAFImportSelector: TfrmCAFImportSelector;

implementation

uses
  ErrorMoreFrm, Imagesfrm, StdHints, Globals, BKConst;

{$R *.dfm}

procedure TfrmCAFImportSelector.btnImportClick(Sender: TObject);
begin
  if ValidateForm then
  begin
    ModalResult := mrOK;
  end;
end;

procedure TfrmCAFImportSelector.btnToFolderClick(Sender: TObject);
begin
  if dlgOpen.Execute then
  begin
    edtImportFile.Text := dlgOpen.FileName;
  end;
end;

procedure TfrmCAFImportSelector.FormCreate(Sender: TObject);
begin
  cmbInstitution.ItemIndex := 0;

  ActiveControl := cmbInstitution;
  
  AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP, btnToFolder.Glyph);

  btnToFolder.Hint := DirButtonHint;
end;

procedure TfrmCAFImportSelector.FormKeyDown(Sender: TObject; var Key: Word;
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

function TfrmCAFImportSelector.GetImportFile: String;
begin
  Result := edtImportFile.Text;
end;

function TfrmCAFImportSelector.GetImportType: TCAFImportType;
begin
  Result := TCAFImportType(cmbInstitution.ItemIndex);
end;

class function TfrmCAFImportSelector.SelectImport(Owner: TComponent; PopupParent: TCustomForm; out ImportType: TCAFImportType; out ImportFile: String): Boolean;
var
  ImportSelector: TfrmCAFImportSelector;
begin
  ImportSelector := TfrmCAFImportSelector.Create(Owner);

  try
    if ImportSelector.ShowModal = mrOK then
    begin
      ImportType := ImportSelector.ImportType;
      ImportFile := ImportSelector.ImportFile;

      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    ImportSelector.Free;
  end;
end;

function TfrmCAFImportSelector.ValidateForm: Boolean;

  function ValidateFieldCount(CAFSource: TCAFSource): Boolean;
  begin
    Result := True;

    if ImportType = cafHSBC then
    begin
      if AdminSystem.fdFields.fdCountry = whUK then
      begin
        Result := CAFSource.FieldCount >= 17;
      end;
    end;
  end;
  
var
  CAFSource: TCAFSource;
begin
  Result := False;
  
  if Trim(edtImportFile.Text) = '' then
  begin
    HelpfulErrorMsg('The import file field cannot be blank. Please specify a valid import file.', 0);

    edtImportFile.SetFocus;
  end
  else
  if not FileExists(edtImportFile.Text) then
  begin
    HelpfulErrorMsg('The specified import file could not be found. Please specify a valid import file.', 0);

    edtImportFile.SetFocus;  
  end
  else
  begin
    CAFSource := TCAFImporter.CreateCAFSource(edtImportFile.Text);

    try
      if not ValidateFieldCount(CAFSource) then
      begin
        HelpfulErrorMsg('The specified import file does not have the required number of fields. Please specify a valid import file', 0);

        edtImportFile.SetFocus;       
      end
      else
      if CAFSource.Count < 1 then
      begin
        HelpfulErrorMsg('The specified import file must have atleast one bank record. Please specify a valid import file', 0);

        edtImportFile.SetFocus;       
      end
      else
      begin
        Result := True;
      end;
    finally
      CAFSource.Free;
    end;
  end;
end;

end.
