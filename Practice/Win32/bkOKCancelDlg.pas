unit bkOKCancelDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,
  OSFont, ExtCtrls;

type
  TbkOKCancelDlgForm = class(TForm)
    pnlBottomControls: TPanel;
    ShapeBotBorder: TShape;
    btnCancel: TButton;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation
uses
  bkXPThemes;

{$R *.DFM}

procedure TbkOKCancelDlgForm.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;

end.
