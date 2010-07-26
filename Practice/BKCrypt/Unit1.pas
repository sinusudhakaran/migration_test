unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    btnEnc: TButton;
    btnDec: TButton;
    btnExit: TButton;
    OpenDialog1: TOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure btnEncClick(Sender: TObject);
    procedure btnDecClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses Admin32, Globals;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  OpenDialog1.Execute;
end;

procedure TForm1.btnEncClick(Sender: TObject);
begin
  if not AdminExists then
  begin
    MessageDlg('The BankLink Admin System (SYSTEM.DB) cannot be found.'#13'Please make sure ' +
      ExtractFileName(Application.ExeName) + ' is running from your BankLink Data Directory.',
      mtError, [mbOk], 0);
    exit;
  end;
  try
    CopyFile(PChar(DATADIR + SYSFILENAME), PChar(DATADIR + ChangeFileExt(SYSFILENAME, '.DEC')), False);
    LoadAdminSystem(True, 'btnEncClick');
    SaveAdminSystem;
    ShowMessage('Encrypted successfully!');
  except
    ShowMessage('Failed to Encrypt!');
  end;
end;

procedure TForm1.btnDecClick(Sender: TObject);
begin
  if not AdminExists then
  begin
    MessageDlg('The BankLink Admin System (SYSTEM.DB) cannot be found.'#13'Please make sure ' +
      ExtractFileName(Application.ExeName) + ' is running from your BankLink Data Directory.',
      mtError, [mbOk], 0);
    exit;
  end;
  try
    CopyFile(PChar(DATADIR + SYSFILENAME), PChar(DATADIR + ChangeFileExt(SYSFILENAME, '.ENC')), False);
    LoadAdminSystem(True, 'btnDecClick');
    SaveAdminSystem(False);
    ShowMessage('Decrypted successfully!');
  except
    ShowMessage('Failed to Decrypt!');
  end;
end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  Close;
end;

end.
