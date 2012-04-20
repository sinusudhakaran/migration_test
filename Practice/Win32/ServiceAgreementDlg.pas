unit ServiceAgreementDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls, ComCtrls;

type
  TfrmServiceAgreement = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
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
  //memServiceAgreement.Text := ProductConfigService.GetServiceAgreement;

  if ShowModal = mrYes then
    Result := True;
end;

procedure TfrmServiceAgreement.FormResize(Sender: TObject);
begin
  self.Caption := inttostr(self.Width);
end;

end.
