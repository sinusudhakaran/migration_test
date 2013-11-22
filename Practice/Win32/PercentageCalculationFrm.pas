unit PercentageCalculationFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TfrmPercentageCalculation = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    lblAccountCode: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmPercentageCalculation: TfrmPercentageCalculation;

implementation

{$R *.dfm}

end.
