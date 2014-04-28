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
  ExtDlgs, ComCtrls;

type
  TArrOfStr = Array of string;

  TATOWarningdlg = class(TForm)
    btnOk: TButton;
    lblHeadingLine: TLabel;
    lstWarnings: TListBox;
    procedure FormActivate(Sender: TObject);
  private
    procedure SetLBScrollExt(aListBox: TListBox);
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

//------------------------------------------------------------------------------
procedure TATOWarningdlg.FormActivate(Sender: TObject);
begin
  SetLBScrollExt(lstWarnings);
end;

//------------------------------------------------------------------------------
procedure TATOWarningdlg.SetLBScrollExt(aListBox: TListBox);
var
  index : integer;
  max   : integer;
  xpos  : integer;
begin
  if aListBox.Items.Count = 0 then
  begin
    max := -10
  end
  else
  begin
    max := 0;
    for index := 0 to aListBox.Items.Count -1 do
    begin
      xpos := aListBox.Canvas.TextWidth(aListBox.Items[index]);
      if xpos > max then max := xpos;
    end;
  end;
  // 10 / 8 is for the OSfont increase and the 10 is for spaces not includes
  max := trunc(max * (10/8)) - 10;

  aListBox.ScrollWidth := max;
end;

end.
