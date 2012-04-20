unit ServiceAgreementDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls, ComCtrls, cxGraphics, cxControls, cxLookAndFeels,
  cxLookAndFeelPainters, cxContainer, cxEdit, dxSkinsCore, dxSkinBlack,
  dxSkinBlue, dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinFoggy, dxSkinGlassOceans, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinPumpkin, dxSkinSeven,
  dxSkinSharp, dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinXmas2008Blue, cxTextEdit,
  cxMemo, cxRichEdit;

type
  TfrmServiceAgreement = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    memServiceAgreement: TcxRichEdit;
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
    function Execute: Boolean;
  public
    { Public declarations }
  end;

function ServiceAgreementAccepted: Boolean;

implementation

{$R *.dfm}

uses
  BankLinkOnlineServices;

function ServiceAgreementAccepted: Boolean;
var
  ServiceAgreementForm: TfrmServiceAgreement;
begin
  ServiceAgreementForm := TfrmServiceAgreement.Create(Application.MainForm);
  try
    Result := ServiceAgreementForm.Execute;
  finally
    ServiceAgreementForm.Free;
  end;
end;

{ TfrmServiceAgreement }


function TfrmServiceAgreement.Execute: Boolean;
begin
  Result := False;
  //Get text for service agreement
  memServiceAgreement.Text := ProductConfigService.GetServiceAgreement;

  if ShowModal = mrYes then
    Result := True;
end;

procedure TfrmServiceAgreement.FormResize(Sender: TObject);
begin
  self.Caption := inttostr(self.Width);
end;

end.
