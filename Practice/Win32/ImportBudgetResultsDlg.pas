//------------------------------------------------------------------------------
unit ImportBudgetResultsDlg;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ExtCtrls,
  StdCtrls,
  WinUtils,
  bkXPThemes,
  OsFont;

//------------------------------------------------------------------------------
type
  TImportBudgetResultsDlg = class(TForm)
    lblImported: TLabel;
    InfoBmp: TImage;
    lblFile: TLabel;
    Label1: TLabel;
    pnlRejects: TPanel;
    lblRejected: TLabel;
    btnView: TButton;
    btnYes: TButton;
    btnNo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
  private
    fFilename : string;
  public
    property Filename : string read fFilename write fFilename;
  end;

  //----------------------------------------------------------------------------
  function VerifyBudgetImport(aBudgetFilename : string;
                              aErrorFilename : string;
                              aRowsImported : integer;
                              aRowsNotImported : integer) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

uses
  ShellAPI,
  bkConst;

//------------------------------------------------------------------------------
function VerifyBudgetImport(aBudgetFilename : string;
                            aErrorFilename : string;
                            aRowsImported : integer;
                            aRowsNotImported : integer) : boolean;
var
  DlgImportBudgetResults : TImportBudgetResultsDlg;
begin
  DlgImportBudgetResults := TImportBudgetResultsDlg.Create( Application.Mainform);
  try
    DlgImportBudgetResults.lblImported.Caption := InttoStr(aRowsImported) + ' Account(s) will be updated';
    DlgImportBudgetResults.lblRejected.Caption := InttoStr(aRowsNotImported) + ' Account(s) rejected';

    if aRowsNotImported = 0 then
    begin
      DlgImportBudgetResults.pnlRejects.Visible := false;
      DlgImportBudgetResults.Height := DlgImportBudgetResults.Height - (DlgImportBudgetResults.pnlRejects.Height + 20);
    end;

    DlgImportBudgetResults.lblFile.Caption := 'From File : ' + ExtractFileName(aBudgetFilename);
    DlgImportBudgetResults.Filename := aErrorFilename;

    Result := IsPositiveResult(DlgImportBudgetResults.showmodal);
  finally
    FreeAndNil(DlgImportBudgetResults);
  end;
end;

//------------------------------------------------------------------------------
procedure TImportBudgetResultsDlg.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

//------------------------------------------------------------------------------
procedure TImportBudgetResultsDlg.btnViewClick(Sender: TObject);
begin
  if BKFileExists( filename) then
    ShellExecute(Handle, 'open', pChar('notepad.exe'), PChar( filename) , nil, SW_SHOWNORMAL);
end;

end.
