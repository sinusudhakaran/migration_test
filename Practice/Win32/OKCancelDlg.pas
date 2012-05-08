unit OKCancelDlg;

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
  StdCtrls,
  ExtCtrls,
  OSFont;

type
  TdlgOkCancel = class(TForm)
    Image1: TImage;
    lblText: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FHelpContext : integer;
    FDefButton   : integer;
    FTextMsg     : string;
    procedure SetDefButton( button : integer);
  public
    response : integer;
    property DefButton : integer write SetDefButton;
    property TextMsg : string read FTextMsg write FTextMsg;
    function Execute : integer;
  end;

function AskOkCancel(Title : string; TextMsg: string; defButton : integer; HelpCtx : word) : integer;

//------------------------------------------------------------------------------
implementation
{$R *.dfm}


uses
  bkXPThemes,
  bkHelp,
  glConst,
  LogUtil,
  imagesfrm;

const
   UnitName =  'YESNODLG';

var
   DebugMe : boolean = false;

{ TdlgOkCancel }
//------------------------------------------------------------------------------
procedure TdlgOkCancel.btnOkClick(Sender: TObject);
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'Q='+lblText.caption+' A=Ok');
  response := DLG_OK;
  Close;
end;

//------------------------------------------------------------------------------
procedure TdlgOkCancel.btnCancelClick(Sender: TObject);
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, 'Q='+lblText.caption+' A=Cancel');
  response := DLG_CANCEL;
  Close;
end;

//------------------------------------------------------------------------------
function TdlgOkCancel.Execute: integer;
begin
  Self.ShowModal;
  result := response;
end;

//------------------------------------------------------------------------------
procedure TdlgOkCancel.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  FHelpContext := 0;
  FDefButton   := DLG_OK;
  FTextMsg     := '';
  Image1.Picture := AppImages.QuestionBmp.Picture;
  {$IFDEF SmartBooks}
  self.Color := clBtnFace;
  {$ENDIF}

  if Application.MainForm.Tag = 99999 then
    Self.Position := poScreenCenter
  else
    Self.Position := poMainFormCenter;
end;

//------------------------------------------------------------------------------
procedure TdlgOkCancel.SetDefButton(button:integer);
begin
  FDefButton := button;
end;

//------------------------------------------------------------------------------
procedure TdlgOkCancel.FormShow(Sender: TObject);
begin
  case FDefButton of
    DLG_YES : begin
      btnOk.Default := true;
      btnCancel.Default := false;
      btnOk.SetFocus;
    end;
    DLG_CANCEL  : begin
      btnOk.Default := false;
      btnCancel.Default := True;
      btnCancel.SetFocus;
    end;
  end;
  Self.BringToFront;
end;

//------------------------------------------------------------------------------
function AskOkCancel(Title : string; TextMsg: string; defButton : integer; HelpCtx : word) : integer;
const
  Margin=10;
var
  MyDlg : TdlgOkCancel;
  CapHeight: integer;
  l: Integer;
begin
  MyDlg := TdlgOkCancel.Create(Application.MainForm);
  try
    MyDlg.Caption     := Title;
    MyDlg.lblText.caption := TextMsg;

    bkHelp.BKHelpSetUp( MyDlg, HelpCtx);

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyDlg do
    begin
      lblText.Left := Image1.Left + Image1.Width + Margin;
      lblText.Width := Width - lblText.Left - Margin;
      Height     := CapHeight+ lblText.Height + btnOK.Height + 4*Margin;
      btnOK.Top := lblText.Height+3*Margin;
      btnCancel.Top := btnOK.Top;
    end;
    MyDlg.DefButton   := defButton;
    MyDlg.HelpContext := HelpCtx;
    result            := MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);

end.
