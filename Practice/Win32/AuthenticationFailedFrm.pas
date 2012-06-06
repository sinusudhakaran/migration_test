unit AuthenticationFailedFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OsFont;

type
  TfrmAuthenticationFailed = class(TForm)
    lblText: TLabel;
    btnReset: TButton;
    btnCancel: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    class function Prompt(DispMsg : string; HelpCtx : Word): TModalResult; static;
  end;


implementation

{$R *.DFM}

uses
  bkXPThemes,
  Globals, imagesfrm;

const
  MAX_WIDTH = 500;
  MIN_WIDTH = 300;

class function TfrmAuthenticationFailed.Prompt(DispMsg : string; HelpCtx : word): TModalResult;
Const
  MARGIN = 10;
var
  MyForm : TfrmAuthenticationFailed;
  CapHeight : integer;
  MinHeight : integer;
  dlgWidth : integer;
begin
  MyForm := TfrmAuthenticationFailed.Create(Application.MainForm);
  try
    MyForm.lblText.caption := DispMsg;

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyForm do
    begin
      lblText.Left := Image1.Left + Image1.Width + Margin;
      if (lblText.Height+Margin) < (Image1.height) then
        MinHeight := Image1.Height+Margin
      else
        MinHeight := lblText.Height+2*Margin;

      Height     := CapHeight+ MinHeight + btnReset.Height + 2*Margin;
      btnReset.Top := MinHeight+Margin;
      btnCancel.Top  := btnReset.Top;

      //set width
      dlgWidth := lblText.left + lblText.Width+2*Margin;

      if dlgWidth < MIN_WIDTH then dlgWidth := MIN_WIDTH;
      if dlgWidth > MAX_WIDTH then dlgWidth := MAX_WIDTH;

      Width := dlgWidth;
    end;

    MyForm.HelpContext := helpCtx;
    MessageBeep(MB_ICONWARNING);
    
    Result := MyForm.ShowModal;
  finally
     MyForm.Free;
  end;
end;

procedure TfrmAuthenticationFailed.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  Image1.Picture := AppImages.WarningBmp.Picture;
  lblText.width := 425;
  self.width    := MAX_WIDTH;
end;

end.
