unit ATOExportMandatoryDataDlg;

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
  TArrOfStr = Array of string;

  TATOWarningdlg = class(TForm)
    btnOk: TButton;
    lstWarnings: TListBox;
    lblHeadingLine: TLabel;
  private
  public
  end;

//------------------------------------------------------------------------------
procedure ShowATOWarnings(const aArrOfStr : TArrOfStr);

//------------------------------------------------------------------------------
implementation
{$R *.dfm}

//------------------------------------------------------------------------------
procedure ShowATOWarnings(const aArrOfStr : TArrOfStr);
var
  frmATOWarning : TATOWarningdlg;
  WaringIndex : integer;
begin
  frmATOWarning := TATOWarningdlg.Create( Application.Mainform);

  try
    for WaringIndex := 0 to length(aArrOfStr)-1 do
      frmATOWarning.lstWarnings.AddItem(aArrOfStr[WaringIndex], nil);

    frmATOWarning.showmodal;

  finally
    FreeAndNil(frmATOWarning);
  end;
end;

end.
