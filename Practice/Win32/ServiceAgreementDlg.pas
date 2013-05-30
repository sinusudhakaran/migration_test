unit ServiceAgreementDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OSFont, StdCtrls, ComCtrls, RzEdit, BKRichEdit;

type
  TfrmServiceAgreement = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    memServiceAgreement: TBKRichEdit;
    Label3: TLabel;
    chkConfirmation: TCheckBox;
    edtSigneeTitle: TEdit;
    edtSigneeName: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormResize(Sender: TObject);
    procedure chkConfirmationClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    function Execute(out Version, SigneeName, SigneeTitle: String): Boolean;

    function ValidateSignature: Boolean;
  public
    { Public declarations }
  end;

function ServiceAgreementAccepted(out Version, SigneeName, SigneeTitle: String): Boolean;

implementation

{$R *.dfm}

uses
  BankLinkOnlineServices, LogUtil, ErrorMoreFrm, bkProduct;

function ServiceAgreementAccepted(out Version, SigneeName, SigneeTitle: String): Boolean;
var
  ServiceAgreementForm: TfrmServiceAgreement;
begin
  ServiceAgreementForm := TfrmServiceAgreement.Create(Application.MainForm);
  try
    Result := ServiceAgreementForm.Execute(Version, SigneeName, SigneeTitle);
  finally
    ServiceAgreementForm.Free;
  end;
end;

{ TfrmServiceAgreement }


function TfrmServiceAgreement.ValidateSignature: Boolean;
begin
  if (Trim(edtSigneeName.Text) = '') or (Trim(edtSigneeTitle.Text) = '') then
  begin
    HelpfulErrorMsg('The Name and Title fields are required to complete the registration process. Please try again.', 0);

    if (Trim(edtSigneeName.Text) = '') then
    begin
      edtSigneeName.SetFocus;
    end
    else
    begin
      edtSigneeTitle.SetFocus;
    end;
    
    Result := False;
  end
  else
  begin
    Result := True;
  end;
end;

procedure TfrmServiceAgreement.btnOKClick(Sender: TObject);
begin
  if ValidateSignature then
  begin
    ModalResult := mrYes;
  end;
end;

procedure TfrmServiceAgreement.chkConfirmationClick(Sender: TObject);
begin
  btnOk.Enabled := chkConfirmation.Checked;
end;

function TfrmServiceAgreement.Execute(out Version, SigneeName, SigneeTitle: String): Boolean;
begin
  Result := False;
  //Get text for service agreement
  Version := ProductConfigService.GetServiceAgreementVersion();
  memServiceAgreement.Text := ProductConfigService.GetServiceAgreement();

  if ShowModal = mrYes then
  begin
    SigneeName := edtSigneeName.Text;
    SigneeTitle := edtSigneeTitle.Text;
    
    Result := True;
  end;
end;

procedure TfrmServiceAgreement.FormCreate(Sender: TObject);
begin
  Label2.Caption := TProduct.Rebrand(Label2.Caption);
end;

procedure TfrmServiceAgreement.FormResize(Sender: TObject);
begin
  self.Caption := inttostr(self.Width);
end;

end.
