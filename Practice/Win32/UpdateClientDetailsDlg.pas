{
  This form is used for:
  - update an active or prospective client details
  - add a new prospect
}
unit UpdateClientDetailsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls,
  OSFont;

type
  TContactDetailsFrm = class(TForm)
    btnOk: TButton;
    btnCancel: TButton;
    pnlMain: TPanel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label9: TLabel;
    Label13: TLabel;
    Label15: TLabel;
    lblUser: TLabel;
    lblCode: TLabel;
    Label1: TLabel;
    eName: TEdit;
    eContact: TEdit;
    eMail: TEdit;
    ePhone: TEdit;
    eFax: TEdit;
    eAddr1: TEdit;
    eAddr2: TEdit;
    eAddr3: TEdit;
    eMobile: TEdit;
    eCode: TEdit;
    cmbUsers: TComboBox;
    eSal: TEdit;
    Bevel1: TBevel;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FClientType: Byte;
    CurrentCode: string;
    procedure SetClientType(Value: Byte);
  public
    { Public declarations }
    UsesWebNotes: Boolean;
    property ClientType: Byte read FClientType write SetClientType;

  end;

//******************************************************************************
implementation

uses
  BKHelp,
  WarningMoreFrm,
  bkxpThemes,
  BKConst,
  ErrorMoreFrm,
  ClientUtils, bkBranding;

{$R *.dfm}

// Show/Hide GUI components depending on client type
procedure TContactDetailsFrm.SetClientType(Value: Byte);
begin
  FClientType := Value;
  case Value of
    ctProspect:
      begin
        BKHelpSetUp( Self, BKH_Adding_and_importing_Prospects);
        cmbUsers.Visible := True;
        lblUser.Visible := True;
        eCode.Visible := True;
        lblCode.Visible := True;
        lblCode.Caption := 'Prospect &Code';
        Label2.Caption := 'Prospect &Name';
      end;
    else
      begin
        BKHelpSetUp( Self, BKH_Editing_client_details);
        cmbUsers.Visible := False;
        lblUser.Visible := False;
        eCode.Visible := False;
        lblCode.Visible := False;
        lblCode.Caption := 'Client &Code';
        Label2.Caption := 'Client &Name';
      end;
  end;
end;

// Validate the form before allowing it to close
procedure TContactDetailsFrm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  NewCode, errors: string;
begin
  if ModalResult = mrOK then
  begin
    //check name
    if Trim(eName.Text) = '' then
    begin
       if FClientType = ctProspect then
         HelpfulWarningMsg('You must enter a prospect name. Please try again.',0)
       else
         HelpfulWarningMsg('You must enter a client name. Please try again.',0);
       eName.setfocus;
       CanClose := False;
       exit;
    end;
    // check code
    if FClientType = ctProspect then
    begin
      // if no code specified then we generate one based on the name
      if Trim(eCode.Text) = '' then
        NewCode := GenerateProspectCode(eCode.Text, eName.Text, CurrentCode)
      else
        NewCode := eCode.Text;
      // if the code is invalid then tell the user
      if not IsCodeValid(NewCode, errors, CurrentCode) then
      begin
        HelpfulErrorMsg('The Prospect Code "' + NewCode + '" cannot be used:' + #13 + errors + #13#13 +
          'Please choose an alternative code.', 0);
        CanClose := False;
        exit;
      end
      else
        eCode.Text := NewCode;
    end;

    // Web Export to BankLink test
    if UsesWebNotes then begin
      errors := format( 'You have selected'#13'Web export to %s,'#13'under Accounting System.'#13#13, [bkBranding.NotesOnlineProductName]);
      if EContact.Text = '' then begin
         HelpfulWarningMsg(errors + 'This requires a Contact Name.', 0);
         CanClose := False;
         EContact.SetFocus;
         Exit;
      end;
      if EMail.Text = '' then begin
         HelpfulWarningMsg(errors + 'This requires an Email address.', 0);
         CanClose := False;
         EMail.SetFocus;
         Exit;
      end;
  end;

  end;
end;

procedure TContactDetailsFrm.FormCreate(Sender: TObject);
begin
  ClientType := ctActive; // default client type
  bkXPThemes.ThemeForm( Self);
  UsesWebNotes := False;
end;

procedure TContactDetailsFrm.FormShow(Sender: TObject);
begin
  CurrentCode := eCode.Text;
end;

end.
