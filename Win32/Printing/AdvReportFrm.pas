unit AdvReportFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, OvcBase, OvcEF, OvcPB, OvcNF, ExtCtrls,
   bkXPThemes,
  OSFont;

type
  TfrmAdvReport = class(TForm)
    OvcController1: TOvcController;
    btnOK: TButton;
    btnCancel: TButton;
    Label3: TLabel;
    Label4: TLabel;
    nfTop: TOvcNumericField;
    Label2: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    nfRight: TOvcNumericField;
    nfLeft: TOvcNumericField;
    nfBottom: TOvcNumericField;
    Label6: TLabel;
    Label5: TLabel;
    Label7: TLabel;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

implementation
{$R *.DFM}

procedure TfrmAdvReport.btnCancelClick(Sender: TObject);
begin
   okPressed := false;
   Close;
end;

function TfrmAdvReport.Execute: boolean;
begin
   okPressed := false;
   Self.ShowModal;
   result := okPressed;
end;

procedure TfrmAdvReport.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

procedure TfrmAdvReport.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;

end.
