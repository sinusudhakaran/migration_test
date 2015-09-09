unit YesNoDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OSFont;

type
  TdlgYesNo = class(TForm)
    lblText: TLabel;
    Image1: TImage;
    CheckBox1: TCheckBox;
    btnCancel: TButton;
    btnYes: TButton;
    btnNo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure btnNoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
    FHelpContext : integer;
    FDefButton   : integer;
    FMessage     : string;
    procedure SetDefButton( button : integer);
  public
    { Public declarations }
    response : integer;
    property DefButton : integer write SetDefButton;
    property Text : string read FMessage write FMessage;

    function Execute : integer;
  end;

  function AskYesNo(Title : string; Msg: string; defButton : integer; HelpCtx : word; ShowCancel: Boolean = False) : integer;
  function AskYesNoCheck(Title : string; Msg: string; CheckMsg: string; var CheckState : boolean;
                         defButton : integer; HelpCtx : word) : integer;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes,
  bkHelp,
  glConst,
  LogUtil,
  imagesfrm,
  GenUtils;

const
   UnitName =  'YESNODLG';

var
   DebugMe : boolean = false;

procedure TdlgYesNo.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);


  FHelpContext := 0;
  FDefButton   := DLG_NO;
  FMessage     := '';
  Image1.Picture := AppImages.QuestionBmp.Picture;
  {$IFDEF SmartBooks}
  self.Color := clBtnFace;
  {$ENDIF}

  if Application.MainForm.Tag = 99999 then
    Self.Position := poScreenCenter
  else
    Self.Position := poMainFormCenter;
end;

procedure TdlgYesNo.SetDefButton(button:integer);
begin
   FDefButton := button;
end;

function TdlgYesNo.Execute : integer;
begin
   Self.ShowModal;
   result := response;
end;

procedure TdlgYesNo.btnYesClick(Sender: TObject);
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,'YESNODLG','Q='+lblText.caption+' A=Yes');
   response := DLG_YES;
   Close;
end;

procedure TdlgYesNo.btnCancelClick(Sender: TObject);
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,'YESNODLG','Q='+lblText.caption+' A=Cancel');
   response := DLG_CANCEL;
   Close;
end;

procedure TdlgYesNo.btnNoClick(Sender: TObject);
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,'YESNODLG','Q='+lblText.caption+' A=No');
   response := DLG_NO;
   Close;
end;

procedure TdlgYesNo.FormShow(Sender: TObject);
begin
   case FDefButton of
   DLG_YES : begin
                btnYes.Default := true;
                btnNo.Default  := false;
                btnCancel.Default := false;
                btnYes.SetFocus;
            end;
   DLG_NO  : begin
                btnNo.Default := true;
                btnYes.Default := false;
                btnCancel.Default := false;
                btnNo.SetFocus;
             end;
   DLG_CANCEL  : begin
                btnNo.Default := false;
                btnYes.Default := false;
                btnCancel.Default := True;
                btnNo.SetFocus;
             end;
   end;
   Self.BringToFront;
end;

function AskYesNo(Title : string; Msg: string; defButton : integer; HelpCtx : word; ShowCancel: Boolean = False) : integer;
{just wraps everything up to make it easier to call}
const
  MarginWidth = 25;
  MarginHeight = 10;
var
  MyDlg : TdlgYesNo;
  CapHeight: integer;
  l: Integer;
begin
  MyDlg := TDlgYesNo.Create(Application.MainForm);
  try
    if ShowCancel then
    begin
      MyDlg.btnCancel.Visible := True;
      l := MyDlg.btnCancel.Left;
      MyDlg.btnCancel.Left := MyDlg.btnNo.Left;
      MyDlg.btnNo.Left := MyDlg.btnYes.Left;
      MyDlg.btnYes.Left := l;
      MyDlg.btnNo.Cancel := False;
    end;
    MyDlg.Caption     := Title;
    MyDlg.lblText.caption := WrapText(Msg, (MyDlg.lblText.width div 5));
    MyDlg.CheckBox1.Visible := false;

    bkHelp.BKHelpSetUp( MyDlg, HelpCtx);

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyDlg do
    begin
      lblText.Left := Image1.Left + Image1.Width + MarginWidth;
      if lblText.Width > Width - lblText.Left - MarginWidth then
        Width := lblText.Width + lblText.Left + MarginWidth;
      lblText.Width := Width - lblText.Left - MarginWidth;

      Height     := CapHeight+ lblText.Height + btnYes.Height + 4*MarginHeight;
      btnYes.Top := lblText.Height+3*MarginHeight;
      btnNo.Top  := btnYes.Top;
      btnCancel.Top := btnYes.Top;
    end;
    MyDlg.DefButton   := defButton;
    MyDlg.HelpContext := HelpCtx;
    result            := MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

function AskYesNoCheck(Title : string; Msg: string; CheckMsg: string; var CheckState : boolean;
                         defButton : integer; HelpCtx : word) : integer;
{just wraps everything up to make it easier to call}
const
  MarginWidth = 25;
  MarginHeight = 10;
var
  MyDlg : TdlgYesNo;
  CapHeight: integer;
begin
  MyDlg := TDlgYesNo.Create(Application.MainForm);
  try
    MyDlg.Caption     := Title;
    MyDlg.lblText.caption := Msg;

    MyDlg.CheckBox1.Visible := true;
    MyDlg.CheckBox1.Caption := WrapText(CheckMsg, (MyDlg.lblText.width div 5));
    MyDlg.CheckBox1.Checked := CheckState;

    {set up the size of the form}
    CapHeight := GetSystemMetrics(SM_CYCAPTION)+ GetSystemMetrics(SM_CYEDGE);
    with MyDlg do
    begin
      lblText.Left := Image1.Left + Image1.Width + MarginWidth;
      if lblText.Width > Width - lblText.Left - MarginWidth then
        Width := lblText.Width + lblText.Left + MarginWidth;
      lblText.Width := Width - lblText.Left - MarginWidth;

      Height     := CapHeight+ lblText.Height + btnYes.Height + 4*MarginHeight+ CheckBox1.Height;
      btnYes.Top := lblText.Height+3*MarginHeight;
      btnNo.Top  := btnYes.Top;
    end;
    MyDlg.DefButton   := defButton;
    MyDlg.HelpContext := HelpCtx;
    result            := MyDlg.Execute;
    CheckState        := MyDlg.CheckBox1.Checked;
  finally
    MyDlg.Free;
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);

end.
