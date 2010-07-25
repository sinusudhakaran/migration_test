unit LicenseDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  bkXPThemes,
  OsFont, ExtCtrls;

type
  TDlgLicense = class(TForm)
    mmoEULA: TMemo;
    lRead: TLabel;
    lAccept: TLabel;
    pBtn: TPanel;
    btnNo: TButton;
    btnYes: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FAbout: Boolean;
    procedure SetAbout(Value: Boolean);
  public
    { Public declarations }
    property About: Boolean read FAbout write SetAbout;
  end;



implementation

{$R *.dfm}

procedure TDlgLicense.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  FAbout := False;
end;

procedure TDlgLicense.SetAbout(Value: Boolean);
begin
  if Value then
  begin
    btnYes.Visible := False;
    lRead.Visible := False;
    lAccept.Visible := False;
    btnNo.Caption := '&OK';

  end;
end;

end.
