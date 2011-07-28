unit EnterPwdDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
  OsFont, ClientWrapper;

type
  TdlgEnterPwd = class(TForm)
    lblPassword: TLabel;
    ePassword: TEdit;
    btnOK: TButton;
    btnCancel: TButton;
    Label2: TLabel;
    lblSupportMsg: TLabel;
    stCode: TStaticText;
    Panel1: TPanel;
    lblCaption: TLabel;
    procedure ePasswordKeyPress(Sender: TObject; var Key: Char);
    procedure ePasswordKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    okPressed : boolean;
    function GenerateSupportCode(Code : String) : string;
  public
    { Public declarations }
    function Execute : boolean;
  end;

CONST
   pwdSupportOption  = True;
   pwdNormal         = False;
   pwdHidePassword   = True;
   pwdEchoPassword   = False;

function EnterPassword(Title : string; password : string; ht : integer; RequiresSupport : boolean; Hidden : boolean): boolean;
function EnterHashedPassword(Title: string; HashedPassword: string): boolean;
function EnterRandomPassword( const Title : string) : boolean;

//******************************************************************************
implementation

uses
   WinUtils,
   bkXPThemes,
   pwdSeed,
   ovcDate,
   stDateSt,
   globals;

{$R *.DFM}
//------------------------------------------------------------------------------
procedure TdlgEnterPwd.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  SetUpHelp;
  lblCaption.Font.Name := Font.Name;
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPwd.ePasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if key = #13 then
  begin
     okPressed := true;
     close;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPwd.ePasswordKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
    13:
      begin
        okPressed := true;
        key := 0;
        Close;
      end;

    27:
      begin
        key := 0;
        Close;
      end;
  end;    // case
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPwd.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
procedure TdlgEnterPwd.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Close;
end;
//------------------------------------------------------------------------------
function TdlgEnterPwd.GenerateSupportCode(Code: string): string;
{generates a support code from the Practice Name and Date.  Banklink support will then
 reverse this code and give the password required}
var
  Seed : integer;
begin
  Seed := SeedFromString(Code+ stDateToDateString('ddmmyy',CurrentDate,true));
  stCode.Caption := inttostr(Seed);
  result := PasswordFromSeed(Seed);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgEnterPwd.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   ePassword.Hint   :=
                    'Enter the Password for this action|' +
                    'Enter the Password required to complete this action';
end;
//------------------------------------------------------------------------------
function TdlgEnterPwd.Execute : boolean;
begin
  okPressed := false;
  ShowModal;
  result := okPressed;
end;
//------------------------------------------------------------------------------
function EnterHashedPassword(Title: string; HashedPassword: string): boolean;
const
   Margin =25;
var
   Dlg     : TdlgEnterPwd;
begin
  result := false;
  Dlg := TdlgEnterPwd.Create(Application.MainForm);
  try
  if Title <> '' then
    dlg.lblCaption.caption := Title;

  Dlg.HelpContext := 0;

  SetPasswordFont(Dlg.ePassword);

  dlg.label2.visible := false;
  dlg.lblSupportMsg.Visible := false;
  dlg.stCode.Visible := false;

  dlg.ePassword.Top := dlg.lblSupportMsg.top;
  dlg.lblPassword.Top := dlg.lblSupportMsg.top;

  dlg.Height := dlg.ePassword.top + dlg.ePassword.height + dlg.btnOK.Height+Margin*2;


  if not Dlg.Execute then
    exit;

  result := CreatePasswordHash(dlg.ePassword.Text) = HashedPassword;
  if not result then
    WinUtils.ErrorSound;

  finally
   dlg.Free;
  end;

end;
//------------------------------------------------------------------------------
function EnterPassword(Title : string; password : string; ht : integer; RequiresSupport : boolean; Hidden : boolean): boolean;
const
   Margin =25;
var
   Dlg     : TdlgEnterPwd;
begin
   result := false;
   Dlg := TdlgEnterPwd.Create(Application.MainForm);
   try
     if Title <> '' then
       dlg.lblCaption.caption := Title;

     Dlg.HelpContext := ht;
     Dlg.Label2.Left := Dlg.lblPassword.Left;

     if Hidden then
     begin
       setpasswordFont(Dlg.ePassword);
     end;

     if not SuperUserLoggedIn then
     begin
       if not RequiresSupport then
       begin
         with Dlg do begin
            label2.visible := false;
            lblSupportMsg.Visible := false;
            stCode.Visible := false;

            ePassword.Top := lblSupportMsg.top;
            lblPassword.Top := lblSupportMsg.top;

            Height := ePassword.top + ePassword.height + btnOK.Height+Margin*2;
         end;
       end
       else
         Password := Dlg.GenerateSupportCode(Password);
     end
     else
         Password := '';

     if not Dlg.Execute then
        exit;

     result := (password = Dlg.ePassword.Text);
     if not result then
        WinUtils.ErrorSound;

   finally
     dlg.Free;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function EnterRandomPassword( const Title : string) : boolean;
const
   Margin =25;
var
   Dlg      : TdlgEnterPwd;
   Password : String;
   RndSeed  : integer;
begin
   result := false;
   Dlg := TdlgEnterPwd.Create(Application.MainForm);
   try
     if Title <> '' then dlg.lblCaption.caption := Title;

     Randomize;
     RndSeed  := Random(100000);
     Dlg.stCode.Caption := inttostr( RndSeed);
     Password           := PwdSeed.PasswordFromSeed( RndSeed);

     if SuperUserLoggedIn then begin
         Password := '';
     end;

     if not Dlg.Execute then exit;

     result := (password = Dlg.ePassword.Text);
     if not result then
        WinUtils.ErrorSound;
   finally
     dlg.Free;
   end;
end;
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
