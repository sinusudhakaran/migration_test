unit ReportOptionsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BaseFrm, StdCtrls;

type
  TfrmReportOptions = class(TfrmBase)
    btnOk: TButton;
    btnCancel: TButton;
    chkLine: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmReportOptions: TfrmReportOptions;

function GetReportOptions(var Line: Boolean): Integer;

implementation

{$R *.dfm}

function GetReportOptions(var Line: Boolean): Integer;
begin
  with TfrmReportOptions.Create(nil) do
    try         
      Result := ShowModal;
      Line := chkLine.Checked;
    finally
      Free;
    end;
end;

end.
