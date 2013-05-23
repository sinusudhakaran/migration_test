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
  OsFont, dxGDIPlusClasses, Globals;

type
  TfrmSplash = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    imgBankstreamSplash: TImage;
    imgBankLinkSplash: TImage;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSplash: TfrmSplash;

implementation

uses
  bkBranding, bkConst;
  
{$R *.DFM}

procedure TfrmSplash.FormCreate(Sender: TObject);
begin
   Label1.Font.Name := Font.Name;

   if bkBranding.GetProductBrand = btBankstream then
   begin
     Self.imgBankLinkSplash.Visible := False;
   end
   else
   begin
     Self.imgBankstreamSplash.Visible := False;
   end;

   // Not Themed.. But no controls..
end;

end.
