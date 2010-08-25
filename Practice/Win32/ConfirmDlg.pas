unit ConfirmDlg;
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,
  OSFont;

type
  TdlgConfirm = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lblMsg: TLabel;
    Image1: TImage;
    btnProcess: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    okPressed : boolean;                 
  public
    { Public declarations }
    function Execute : boolean;
  end;

function ConfirmOKCancel(Title: string; Msg : string) : integer;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes,
  ImagesFrm,
  Globals;

//------------------------------------------------------------------------------
procedure TdlgConfirm.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  Image1.Picture := AppImages.driveBmp.Picture;
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgConfirm.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   btnProcess.Hint   :=
                     'Process the transactions contained in your '+SHORTAPPNAME+' data file(s)|' +
                     'Process the transactions contained in your '+SHORTAPPNAME+' data file(s)';
end;
//------------------------------------------------------------------------------
function TdlgConfirm.Execute: boolean;
begin
   ShowModal;
   result := okPressed;
end;
//------------------------------------------------------------------------------
function ConfirmOKCancel(Title: string; Msg : string) : integer;
const
  MARGIN = 10;
var
  myDlg : TdlgConfirm;
  CapHeight, MinHeight : integer;
begin
//  result := mrCancel;
  MyDlg := TdlgConfirm.Create(Application.MainForm);
  try
    MyDlg.Caption := title;
    MyDlg.lblMsg.Caption := Msg;

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyDlg do
    begin
      if (lblMsg.Height+Margin) < (Image1.height) then
        MinHeight := Image1.Height+Margin
      else
        MinHeight := lblMsg.Height+2*Margin;

      Height     := CapHeight+ MinHeight + btnOK.Height + 2*Margin;
      btnOK.Top := MinHeight+Margin;
      btnCancel.Top  := btnOK.Top;
      btnProcess.top := btnOK.Top;
    end;

    MyDlg.Execute;
    result := MyDlg.ModalResult;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
