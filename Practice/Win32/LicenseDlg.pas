unit LicenseDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  bkXPThemes,
  OsFont, ExtCtrls, ComCtrls,
  bkProduct;

type
  TDlgLicense = class(TForm)
    mmoEULA: TMemo;
    lRead: TLabel;
    lAccept: TLabel;
    pBtn: TPanel;
    btnNo: TButton;
    btnYes: TButton;
    mmoBankstream: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FAbout: Boolean;
    procedure SetAbout(Value: Boolean);
    procedure DoRebranding();
  public
    { Public declarations }
    property About: Boolean read FAbout write SetAbout;
  end;

implementation
{$R *.dfm}

uses
  bkConst;

procedure TDlgLicense.DoRebranding;
begin
  lAccept.Caption := 'Do you accept all the terms of the preceding Licence Agreement? ' +
                     'If you choose No, you will not be able to login. To use ' +
                     BRAND_FULL_PRACTICE + ' you must accept this agreement.';
end;

procedure TDlgLicense.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  FAbout := False;
  mmoEULA.WordWrap := True;

  if TProduct.ProductBrand = btBankstream then
  begin
    mmoEULA.Visible := False;
    mmoBankstream.Visible := True;
  end
  else
  begin
    mmoBankstream.Visible := False;
    mmoEULA.Visible := True;
  end;

  DoRebranding();
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
