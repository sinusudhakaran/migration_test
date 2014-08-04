unit AttachToReportDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,

  OSFont;

type
  TAttachToReportFrm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    edtReportName: TEdit;
    cmbFormat: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  function  ShowAttachToReportFrm(const aOwner: TComponent;
              var aReportFormat: integer; var sReportName: string): boolean;


implementation

{$R *.dfm}

uses
  bkConst,
  bkXPThemes;

function ShowAttachToReportFrm(const aOwner: TComponent;
  var aReportFormat: integer; var sReportName: string): boolean;
var
  Form: TAttachToReportFrm;
  mrResult: integer;
begin
  Form := TAttachToReportFrm.Create(aOwner);
  try
    mrResult := Form.ShowModal;

    result := (mrResult = mrOK);
    if not result then
      exit;

    aReportFormat := Form.cmbFormat.ItemIndex;
    sReportName := Form.edtReportName.Text;
  finally
    FreeAndNil(Form);
  end;
end;

procedure TAttachToReportFrm.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  bkXPThemes.ThemeForm(self);

  for i := rfMin to rfMax do
  begin
    cmbFormat.AddItem(rfNames[i], nil);
  end;

  // Default
  cmbFormat.ItemIndex := rfPDF;
end;


end.
