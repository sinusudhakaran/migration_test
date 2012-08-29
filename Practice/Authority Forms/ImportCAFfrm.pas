unit ImportCAFfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmImportCAF = class(TForm)
    lblInstitution: TLabel;
    lblImportFrom: TLabel;
    cmbInstitution: TComboBox;
    edtImportFrom: TEdit;
    btnImport: TButton;
    btnBrowse: TButton;
    btnCancel: TButton;
    procedure btnBrowseClick(Sender: TObject);
    procedure btnImportClick(Sender: TObject);
  private
    FClientEmail: string;
  public
    procedure SetClientEmail(value: string);
    property ClientEmail: string read FClientEmail write SetClientEmail;
  end;

var
  frmImportCAF: TfrmImportCAF;

implementation

{$R *.dfm}

procedure TfrmImportCAF.btnBrowseClick(Sender: TObject);
var
  OpenDialog1: TOpenDialog;
begin
  OpenDialog1 := TOpenDialog.Create(nil);
  OpenDialog1.DefaultExt := '*.CSV';
  OpenDialog1.Filter := 'CSV Files (*.csv)|*.csv';
  OpenDialog1.InitialDir := ExtractFileDir( edtImportFrom.Text);

  if OpenDialog1.Execute then
    edtImportFrom.Text := OpenDialog1.FileName;
end;

procedure TfrmImportCAF.btnImportClick(Sender: TObject);
begin
  // TODO
end;

procedure TfrmImportCAF.SetClientEmail(value: string);
begin
  FClientEmail := value;
end;

end.
