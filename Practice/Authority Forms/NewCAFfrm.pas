unit NewCAFfrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    lblCompleteTheDetailsBelow: TLabel;
    lbl20: TLabel;
    Label1: TLabel;
    lblServiceStartMonthAndYear: TLabel;
    edtAccountName: TEdit;
    cmbServiceStartMonth: TComboBox;
    edtServiceStartYear: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
