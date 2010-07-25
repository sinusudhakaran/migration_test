unit dlgFaxDetails;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  bkXPThemes,
  OsFont;

type
  TFaxDetailsDlg = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    Button2: TButton;
    edtToName: TEdit;
    edtFaxNumber: TEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  function GetFaxDetails( var aName : string; var aNumber : string) : boolean;

implementation

{$R *.dfm}

function GetFaxDetails( var aName : string; var aNumber : string) : boolean;
begin
  result := false;
  with TFaxDetailsDlg.Create(Application.MainForm) do
  begin
    try
      if ShowModal = mrOK then
      begin
        aName := edtToName.Text;
        aNumber := edtFaxNumber.Text;
        result := true;
      end;
    finally
      Free;
    end;
  end;
end;


procedure TFaxDetailsDlg.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

end.
