unit ErrorMoreFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

type
  TfrmErrorMore = class(TForm)
    lblText: TLabel;
    btnOK: TButton;
    Image1: TImage;
    memDetails: TMemo;
    lblDetails: TLabel;
    procedure btnOKClick(Sender: TObject);
    procedure btnMoreClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure HelpfulErrorMsg(DispMsg : string; HelpCtx : Word;
                            UpdateLog : boolean = true; Details: string = '';
                            ShowDetails: Boolean = False);

implementation

{$R *.DFM}

uses
  bkXPThemes, Globals, ImagesFrm, LogUtil;

const
  MAX_WIDTH = 500;
  MIN_WIDTH = 300;
  MIN_HEIGHT = 130;

procedure HelpfulErrorMsg(DispMsg : string; HelpCtx : Word; UpdateLog : boolean = true;
  Details: string = ''; ShowDetails: Boolean = False);
const
  MARGIN = 10;
var
  MyForm : TfrmErrorMore;
  CapHeight,MinHeight : integer;
  dlgWidth : integer;
begin
  if UpdateLog then
    LogUtil.LogMsg(lmError,'ERRORMOREFRM',DispMsg);

  MyForm := TfrmErrorMore.Create(Application.MainForm);
  try
    //MyForm.lblText.caption := StringReplace(DispMsg, '&', '&&', [rfReplaceAll]);
    MyForm.lblText.caption := DispMsg; // case 8261
    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyForm do
    begin
      lblText.Left := Image1.Left + Image1.Width + Margin;
      if (lblText.Height+Margin) < (Image1.height) then
        MinHeight := Image1.Height+Margin
      else
        MinHeight := lblText.ClientHeight+2*Margin;

      Height     := CapHeight+ MinHeight + btnOK.Height + 2*Margin;

      //set width
      dlgWidth := lblText.left + lblText.ClientWidth+2*Margin;

      if dlgWidth < MIN_WIDTH then dlgWidth := MIN_WIDTH;
      if dlgWidth > MAX_WIDTH then dlgWidth := MAX_WIDTH;

      Width := dlgWidth;

      //Details
      if ShowDetails then begin
        Width := MAX_WIDTH;
        lblDetails.Left := lblText.Left;
        memDetails.Left := lblDetails.Left;
        Height := Height + (memDetails.Top + memDetails.Height + 2*Margin) - lblDetails.Top;
        memDetails.Text := Details;
        memDetails.Visible := True;
        lblDetails.Visible := True;
      end;

      //center the ok button
      btnok.Left := (ClientWidth - btnOK.Width) div 2;
    end;

    MyForm.HelpContext := helpCtx;
    MessageBeep(MB_ICONEXCLAMATION);
    MyForm.ShowModal;
  finally
     MyForm.Free;
  end;
end;

procedure TfrmErrorMore.btnOKClick(Sender: TObject);
begin
   Close;
end;

procedure TfrmErrorMore.btnMoreClick(Sender: TObject);
begin
   // AppHelpForm.ShowHelp(AppHELPFILENAME,helpContext);
end;

procedure TfrmErrorMore.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  Image1.Picture := AppImages.ErrorBmp.Picture;
  lblText.width := 425;
  Self.width    := MAX_WIDTH;
  Self.Height   := MIN_HEIGHT;
end;

end.
