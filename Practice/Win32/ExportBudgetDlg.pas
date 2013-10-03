unit ExportBudgetDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  OSFont,
  StdCtrls,
  Buttons,
  ExtDlgs;

type
  TfrmExportBudget = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    lblFilename: TLabel;
    edtBudgetFile: TEdit;
    btnToFile: TSpeedButton;
    chkIncludeUnusedChartCodes: TCheckBox;
    SaveTextFileDialog: TSaveTextFileDialog;
    procedure FormCreate(Sender: TObject);
    procedure btnToFileClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    fBudgetFilePath : string;
    fIncludeUnusedChartCodes : boolean;

    procedure SetBudgetFilePath(aFilePath : string);
  public
    property BudgetFilePath : string read fBudgetFilePath write SetBudgetFilePath;
    property IncludeUnusedChartCodes : boolean read fIncludeUnusedChartCodes write fIncludeUnusedChartCodes;
  end;

var
  frmExportBudget: TfrmExportBudget;

//------------------------------------------------------------------------------
function DoExportBudget(var BudgetFilePath : string;
                        var IncludeUnusedChartCodes : boolean) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ImagesFrm,
  bkXPThemes,
  YesNoDlg,
  Globals,
  ErrorMoreFrm;

//------------------------------------------------------------------------------
function DoExportBudget(var BudgetFilePath : string;
                        var IncludeUnusedChartCodes : boolean) : boolean;
var
  frmExportBudget : TfrmExportBudget;
begin
  frmExportBudget := TfrmExportBudget.Create( Application.Mainform);

  try
    frmExportBudget.BudgetFilePath := BudgetFilePath;
    Result := IsPositiveResult(frmExportBudget.showmodal);

    if Result then
    begin
      BudgetFilePath          := frmExportBudget.BudgetFilePath;
      IncludeUnusedChartCodes := frmExportBudget.IncludeUnusedChartCodes;
    end;
  finally
    FreeAndNil(frmExportBudget);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmExportBudget.SetBudgetFilePath(aFilePath: string);
begin
  fBudgetFilePath := aFilePath;
  edtBudgetFile.Text := aFilePath;
end;

//------------------------------------------------------------------------------
procedure TfrmExportBudget.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP, btnToFile.Glyph);
end;

//------------------------------------------------------------------------------
procedure TfrmExportBudget.btnToFileClick(Sender: TObject);
begin
  SaveTextFileDialog.InitialDir := ExtractFilePath(edtBudgetFile.Text);
  SaveTextFileDialog.Filename := ExtractFilename(edtBudgetFile.Text);
  if SaveTextFileDialog.Execute then
    edtBudgetFile.Text := SaveTextFileDialog.Filename;
end;

//------------------------------------------------------------------------------
procedure TfrmExportBudget.btnOkClick(Sender: TObject);
var
  DirPath : string;
begin
  DirPath := ExtractFilePath(edtBudgetFile.Text);

  if not DirectoryExists(DirPath) then
  begin
    if AskYesNo('Create Directory',
                'The folder '+DirPath +' does not exist. Do you want to Create it?',
                 DLG_YES,0) <> DLG_YES then
    begin
      Exit;
    end;

    ForceDirectories(DirPath);

    if not DirectoryExists(DirPath) then
    begin
      HelpfulErrorMsg('Cannot Create Extract Data Directory '+DirPath,0);
      Exit;
    end;
  end;

  if fileexists(edtBudgetFile.Text) then
  begin
    if AskYesNo('Overwrite File', 'The file ' + ExtractFileName(edtBudgetFile.Text) + ' already exists. Overwrite?',
      DLG_YES, 0) <> DLG_YES then
    begin
      edtBudgetFile.SetFocus;
      exit;
    end;
  end;

  fBudgetFilePath := edtBudgetFile.Text;
  fIncludeUnusedChartCodes := chkIncludeUnusedChartCodes.Checked;

  ModalResult := mrOK;
end;

end.
