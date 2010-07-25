unit CheckBoxOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  OsFont;

type
  TdlgCheckBoxOptions = class(TForm)
    lblLine1: TLabel;
    lblLine2: TLabel;
    chkBox1: TCheckBox;
    chkBox2: TCheckBox;
    chkBox3: TCheckBox;
    chkBox4: TCheckBox;
    Panel1: TPanel;
    btnButton1: TButton;
    btnButton2: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

uses bkXPThemes;

{$R *.dfm}

procedure TdlgCheckBoxOptions.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
end;

procedure TdlgCheckBoxOptions.FormShow(Sender: TObject);
var
  Movement : Integer;
begin
  //move the controls to minimize empty space
  if (lblLine2.Caption = '') then
  begin
    Movement := (chkBox1.Top - lblLine2.Top);
    chkBox1.Top := chkBox1.Top - Movement;
    chkBox2.Top := chkBox2.Top - Movement;
    chkBox3.Top := chkBox3.Top - Movement;
    chkBox4.Top := chkBox4.Top - Movement;
  end else
    Movement := 0;

  if (not chkBox1.Visible) then
    Movement := Movement + (chkBox2.Top - chkBox1.Top);
  if (not chkBox2.Visible) then
    Movement := Movement + (chkBox3.Top - chkBox2.Top);
  if (not chkBox3.Visible) then
    Movement := Movement + (chkBox4.Top - chkBox3.Top);
  if (not chkBox4.Visible) then
    Movement := Movement + (chkBox4.Top - chkBox3.Top);

  Self.Height := Self.Height - Movement;
end;

end.
