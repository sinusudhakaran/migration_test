unit ImportBudgetDlg;

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
  StdCtrls,
  Buttons, ExtDlgs;

type
  TfrmImportBudget = class(TForm)
    edtBudgetFile: TEdit;
    lblFilename: TLabel;
    btnToFile: TSpeedButton;
    btnOk: TButton;
    btnCancel: TButton;
    OpenTextFileDialog: TOpenTextFileDialog;
    procedure btnToFileClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    fBudgetFilePath : string;
    fBudgetName: string;
    procedure SetBudgetFilePath(const Value: string);
  public
    property BudgetFilePath : string read fBudgetFilePath write SetBudgetFilePath;
    property BudgetName : string read fBudgetName write fBudgetName;
  end;

var
  frmImportBudget: TfrmImportBudget;

//------------------------------------------------------------------------------
function DoImportBudget(var aBudgetFilePath : string; aBudgetName : string) : boolean;

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
function DoImportBudget(var aBudgetFilePath : string; aBudgetName : string) : boolean;
var
  frmImportBudget : TfrmImportBudget;
begin
  frmImportBudget := TfrmImportBudget.Create( Application.Mainform);

  try
    frmImportBudget.BudgetFilePath := aBudgetFilePath;
    frmImportBudget.BudgetName     := aBudgetName;

    Result := IsPositiveResult(frmImportBudget.showmodal);

    if Result then
      aBudgetFilePath := frmImportBudget.BudgetFilePath;
  finally
    FreeAndNil(frmImportBudget);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  ImagesFrm.AppImages.Misc.GetBitmap(MISC_FINDFOLDER_BMP, btnToFile.Glyph);
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.SetBudgetFilePath(const Value: string);
begin
  fBudgetFilePath := Value;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.btnToFileClick(Sender: TObject);
begin
  OpenTextFileDialog.InitialDir := ExtractFilePath(edtBudgetFile.Text);
  OpenTextFileDialog.Filename := ExtractFilename(edtBudgetFile.Text);
  if OpenTextFileDialog.Execute then
    edtBudgetFile.Text := OpenTextFileDialog.Filename;
end;

//------------------------------------------------------------------------------
procedure TfrmImportBudget.btnOkClick(Sender: TObject);
begin
  if not fileexists(edtBudgetFile.Text) then
  begin
    HelpfulErrorMsg('The file you have selected does not exist, please re-enter the file.', 0);
    edtBudgetFile.SetFocus;
    exit;
  end;

  if AskYesNo('Import Budget', 'All figures in budget ' + fBudgetName +
                               ' will be replaced by those in the selected file.' +
                               #13#10 + #13#10 + 'Please confirm that you wish to do this?',
              DLG_YES, 0) <> DLG_YES then
  begin
    exit;
  end;

  fBudgetFilePath := edtBudgetFile.Text;

  ModalResult := mrOK;
end;

end.
