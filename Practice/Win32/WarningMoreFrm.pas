unit WarningMoreFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OsFont;

type
  TfrmWarnMore = class(TForm)
    lblText: TLabel;
    btnOK: TButton;
    btnMore: TButton;
    Image1: TImage;
    procedure btnOKClick(Sender: TObject);
    procedure btnMoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure HelpfulWarningMsg(DispMsg : string; HelpCtx : Word; ButtonText : string = '&OK';
                              CustomWidth: integer = -1 );

implementation

{$R *.DFM}

uses
  bkXPThemes,
  Globals,
  imagesfrm,
  Math;

const
  MAX_WIDTH = 500;
  MIN_WIDTH = 300;

procedure HelpfulWarningMsg(DispMsg : string; HelpCtx : word; ButtonText : string = '&OK';
                            CustomWidth: integer = -1 );
Const
  MARGIN = 10;
var
  MyForm : TfrmWarnMore;
  CapHeight : integer;
  MinHeight : integer;
  dlgWidth : integer;
begin
  MyForm := TfrmWarnMore.Create(Application.MainForm);
  try
    MyForm.lblText.caption := DispMsg;
    if HelpCtx = 0 then MyForm.btnMore.visible := false;

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyForm do
    begin
      lblText.Left := Image1.Left + Image1.Width + Margin;
      if (lblText.Height+Margin) < (Image1.height) then
        MinHeight := Image1.Height+Margin
      else
        MinHeight := lblText.Height+2*Margin;

      Height     := CapHeight+ MinHeight + btnOK.Height + 2*Margin;
      btnOK.Top := MinHeight+Margin;
      btnOK.Caption := ButtonText;
      btnMore.Top  := btnOK.Top;

      //set width
      if (CustomWidth > -1) then
      begin
        Width := CustomWidth;
        lblText.Width := CustomWidth - (2 * Max(lblText.Left, Margin));
      end
      else
      begin
        dlgWidth := lblText.left + lblText.Width+2*Margin;

        if dlgWidth < MIN_WIDTH then dlgWidth := MIN_WIDTH;
        if dlgWidth > MAX_WIDTH then dlgWidth := MAX_WIDTH;

        Width := dlgWidth;
      end;
    end;

    MyForm.HelpContext := helpCtx;
    MessageBeep(MB_ICONWARNING);
    MyForm.ShowModal;
  finally
     MyForm.Free;
  end;
end;

procedure TfrmWarnMore.btnOKClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmWarnMore.btnMoreClick(Sender: TObject);
begin
   //AppHelpForm.ShowHelp(AppHELPFILENAME,helpContext);
end;

procedure TfrmWarnMore.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  Image1.Picture := AppImages.WarningBmp.Picture;
  lblText.width := 425;
  self.width    := MAX_WIDTH;
end;

procedure TfrmWarnMore.FormResize(Sender: TObject);
begin
  //position buttons;
  btnOK.left := (self.width - btnOk.width) div 2;
  btnMore.left := self.width - btnMore.width - 20;
end;

end.
