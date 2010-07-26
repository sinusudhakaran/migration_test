unit ChkProgressFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,bkXPThemes,
  OsFont;

type
  TfrmChkProgress = class(TForm)
    mProgress: TMemo;
    btnOK: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure ActivateApplication(Sender: TObject);
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TfrmChkProgress.btnOKClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmChkProgress.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  btnOk.left := (Self.Width - btnOK.Width) div 2;
  Application.OnActivate := Self.ActivateApplication;
end;

procedure TfrmChkProgress.FormResize(Sender: TObject);
begin
  btnOk.left := (Self.Width - btnOK.Width) div 2;
end;

procedure TfrmChkProgress.ActivateApplication(Sender: TObject);
begin
  Application.BringToFront;
  if Self.Visible and Self.Enabled then
  begin
    Self.BringToFront;
    Self.SetFocus;
  end;
end;

procedure TfrmChkProgress.FormDestroy(Sender: TObject);
begin
  Application.OnActivate := nil;
end;

end.
