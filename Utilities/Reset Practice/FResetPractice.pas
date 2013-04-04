unit FResetPractice;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons;

type
  TfrmResetPractice = class(TForm)
    Button1: TButton;
    edtPath: TEdit;
    SpeedButton1: TSpeedButton;
    FileOpenDialog1: TFileOpenDialog;
    Label1: TLabel;
    Label2: TLabel;
    edtPracticeCode: TEdit;
    edtPasswordHash: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    cmbCountryCode: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    procedure ResetPractice(const PracticeDataDir: String; CountryCode: Integer; const PracticeCode, PracticeHash: String);
  public
    { Public declarations }
  end;

var
  frmResetPractice: TfrmResetPractice;

implementation

uses
  Admin32, Globals, SysObj32, SYDEFS;

{$R *.dfm}

{ TForm1 }

procedure TfrmResetPractice.Button1Click(Sender: TObject);
var
  t_Path: String;
begin
  t_Path := edtPath.text;

  if t_Path[Length(t_Path)] <> '\' then
  begin
    t_Path := t_Path + '\';
  end;

  ResetPractice(t_Path, cmbCountryCode.ItemIndex, edtPracticeCode.text, edtPasswordHash.Text);

  MessageDlg('Done', mtInformation, [mbOk], 0);
end;

procedure TfrmResetPractice.SpeedButton1Click(Sender: TObject);
begin
  if FileOpenDialog1.Execute then
  begin
    edtPath.Text := FileOpenDialog1.FileName;
  end;
end;


procedure TfrmResetPractice.ResetPractice(const PracticeDataDir: String;
  CountryCode: Integer; const PracticeCode, PracticeHash: String);
var
  DummySnapShot: TSystemObj;
  Index: Integer;
  SystemBankAccount: pSystem_Bank_Account_Rec;
  User:  pUser_Rec;
begin
  Globals.DataDir := PracticeDataDir;

  if LockAndLoadAdminSystem(True, 'SUPERVIS', False, DummySnapShot) then
  begin
    try
      AdminSystem.fdFields.fdCountry := CountryCode;
      AdminSystem.fdFields.fdBankLink_Code := PracticeCode;
      AdminSystem.fdFields.fdBankLink_Connect_Password := PracticeHash;

      SaveAdminSystem;
    finally
      FreeAndNil(AdminSystem);
    end;
  end;
end;

end.
