unit InfoMoreFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OsFont;

type
  TfrmInfoMore = class(TForm)
    lblText: TLabel;
    btnOK: TButton;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure HelpfulInfoMsg(DispMsg : string; HelpCtx : Word );

implementation

{$R *.DFM}

uses
  bkXPThemes, globals, imagesfrm;

procedure HelpfulInfoMsg(DispMsg : string; HelpCtx : Word );
const
   Margin = 10;
   MAX_WIDTH = 500;
   MIN_WIDTH = 300;

var
   MyForm   : TfrmInfoMore;
   CapHeight, MinHeight: integer;
   DlgWidth : integer;
begin
   MyForm := TfrmInfoMore.Create(Application.MainForm);
   try
      with MyForm do
      begin
         lblText.width   := 425;
         lblText.caption := DispMsg;
         Image1.Picture  := AppImages.InfoBmp.Picture;
         width           := 500;

         //set up the size of the form
         
         CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
         lblText.Left := Image1.Left + Image1.Width + Margin;
         if (lblText.Height+Margin) < (Image1.height) then
            MinHeight := Image1.Height+Margin
         else
           MinHeight := lblText.Height+2*Margin;

         Height     := CapHeight+ MinHeight + btnOK.Height + 2*Margin;

         // set the dialog width
         
         dlgWidth := lblText.left + lblText.Width+2*Margin;

         if dlgWidth < MIN_WIDTH then dlgWidth := MIN_WIDTH;
         if dlgWidth > MAX_WIDTH then dlgWidth := MAX_WIDTH;

         Width := dlgWidth;

         // Center the OK button 
      
         btnOK.Top  := MinHeight+Margin;
         btnOK.Left := ( ( ClientWidth - btnOK.Width ) div 2 );
         
         HelpContext := helpCtx;
      end;
      MessageBeep(MB_ICONINFORMATION);
      MyForm.ShowModal;
   finally
      MyForm.Free;
   end;
end;

procedure TfrmInfoMore.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
