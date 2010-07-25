//------------------------------------------------------------------------------
//
// Title:       Choose contact details dialog
//
// Description: Used by the client manager to change the contact details
//
//  Author         Version Date       Comments
//  Michael Foot   1.00    03/04/2003 Initial version
//
//------------------------------------------------------------------------------
unit ChooseContactDetailsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  clObj32,
  OsFont;

type
  TdlgChooseContactDetails = class(TForm)
    Label1: TLabel;
    radPractice: TRadioButton;
    radStaffMember: TRadioButton;
    radCustom: TRadioButton;
    lblContactName: TLabel;
    eName: TEdit;
    lblPhone: TLabel;
    ePhone: TEdit;
    lblEmail: TLabel;
    eMail: TEdit;
    btnOK: TButton;
    btnCancel: TButton;

    procedure radPracticeClick(Sender: TObject);
    procedure radCustomClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

  private
    { Private declarations }
    procedure HideCustomClientDetails;
    procedure ShowCustomClientDetails;
  public
    { Public declarations }
  end;



function ChooseContactDetails(aClient : TClientObj) : Boolean;

implementation

uses
  BKCONST,
  BKHelp,
  bkXPThemes;

{$R *.dfm}

function ChooseContactDetails(aClient : TClientObj) : Boolean;
var
  dlgChooseContactDetails: TdlgChooseContactDetails;
begin
  Result := False;
  if (Assigned(aClient)) then
  begin
    dlgChooseContactDetails := TdlgChooseContactDetails.Create(Application.MainForm);
    try
      with dlgChooseContactDetails do
      begin
        BKHelpSetUp(dlgChooseContactDetails, BKH_Assigning_the_practice_contact);
        case aClient.clFields.clContact_Details_To_Show of
          cdtPractice:
            radPractice.Checked := True;
          cdtStaffMember:
            radStaffMember.Checked := True;
          cdtCustom:
            radCustom.Checked := True;
        else
          radPractice.Checked := True;
        end;
        eName.Text := aClient.clFields.clCustom_Contact_Name;
        ePhone.Text := aClient.clFields.clCustom_Contact_Phone;
        eMail.Text := aClient.clFields.clCustom_Contact_EMail_Address;

        ShowModal;
        if (ModalResult = mrOK) then
        begin
          if (radPractice.Checked) then
            aClient.clFields.clContact_Details_To_Show := cdtPractice
          else if (radStaffMember.Checked) then
            aClient.clFields.clContact_Details_To_Show := cdtStaffMember
          else if (radCustom.Checked) then
            aClient.clFields.clContact_Details_To_Show := cdtCustom;

          aClient.clFields.clCustom_Contact_Name := eName.Text;
          aClient.clFields.clCustom_Contact_Phone := ePhone.Text;
          aClient.clFields.clCustom_Contact_EMail_Address := eMail.Text;
          Result := True;
        end;
      end;
    finally
      dlgChooseContactDetails.Free;
    end;
  end;
end;

procedure TdlgChooseContactDetails.radPracticeClick(Sender: TObject);
begin
  HideCustomClientDetails;
end;

procedure TdlgChooseContactDetails.radCustomClick(Sender: TObject);
begin
  ShowCustomClientDetails;
end;

procedure TdlgChooseContactDetails.HideCustomClientDetails;
begin
  lblContactName.Visible := False;
  lblPhone.Visible := False;
  lblEmail.Visible := False;
  eName.Visible := False;
  ePhone.Visible := False;
  eMail.Visible := False;
end;

procedure TdlgChooseContactDetails.ShowCustomClientDetails;
begin
  lblContactName.Visible := True;
  lblPhone.Visible := True;
  lblEmail.Visible := True;
  eName.Visible := True;
  ePhone.Visible := True;
  eMail.Visible := True;
end;

procedure TdlgChooseContactDetails.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;


end.
