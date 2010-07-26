unit Splash;
{-----------------------------------------------}
{ Banklink Splash Screen
{
{ Project source should be modified to create the
  form and destroy it just before running
}
{
  sample code:                     

  begin
  try
    frmSplash := TfrmSplash.Create(Application);
    frmSplash.show;
    frmSplash.Update;

    Application.Initialize;
    Application.ProcessMessages;
->    Application.CreateForm(TForm1, Form1);
->    Application.CreateForm(TForm2, Form2);
  finally
    frmSplash.Close;
    frmSplash.Free;
  end;
    Application.Run;
  end.
}
{-----------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, 
  StdCtrls, ExtCtrls, jpeg,
  OsFont;

type
  TfrmSplash = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    imgHeader: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;

implementation
{$R *.DFM}

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
   Label1.Font.Name := Font.Name;
   // Not Themed.. But no controls..
end;

end.
