unit OptionsScreenFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, PromoDisplayForm, StdCtrls, Buttons, OSFont, ExtCtrls,
  Globals, PromoContentFme, WinUtils, SyDefs,
  ComCtrls, sysobj32, appuserobj, INISettings, PromoWindowObj;

type
  TFrmOptionsScreen = class(TForm)
    pnlControls: TPanel;
    btnPromos: TBitBtn;
    ShapeBorder: TShape;
    gbContentTypes: TGroupBox;
    gbUserTypes: TGroupBox;
    Label2: TLabel;
    edtVersionFrom: TEdit;
    gbCountry: TGroupBox;
    Label3: TLabel;
    edtVersionTo: TEdit;
    dtDate: TDateTimePicker;
    rbFirstLogin: TRadioButton;
    rbSecondLogin: TRadioButton;
    rbNZ: TRadioButton;
    rbAU: TRadioButton;
    rbAdmin: TRadioButton;
    rbRestricted: TRadioButton;
    rbNormal: TRadioButton;
    rbBooks: TRadioButton;
    btnClose: TBitBtn;
    Label1: TLabel;
    procedure btnPromosClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmOptionsScreen: TFrmOptionsScreen;

implementation

{$R *.dfm}

procedure TFrmOptionsScreen.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmOptionsScreen.btnPromosClick(Sender: TObject);
var
  Promos : TPromoDisplayFrm;
  UserRec : pUser_Rec;
  procedure DisplayPromoScreen;
  begin
    Promos := TPromoDisplayFrm.Create(Nil);
    try
      Promos.ShowModal;
    finally
      FreeAndNil(Promos);
    end;
  end;
begin
  //UserRec := AdminSystem.fdSystem_User_List.FindCode(edtLogUser.Text);
  CurrUser := TAppUser.Create;
  if rbAdmin.Checked then
  begin
    CurrUser.CanAccessAdmin := True;
    CurrUser.HasRestrictedAccess := False;
  end
  else if rbNormal.Checked then
  begin
    CurrUser.CanAccessAdmin := False;
    CurrUser.HasRestrictedAccess := False;
  end
  else if rbRestricted.Checked then
  begin
    CurrUser.CanAccessAdmin := False;
    CurrUser.HasRestrictedAccess := True;
  end;

  AdminSystem := nil;
  if Not rbBooks.Checked then
  begin
    AdminSystem := TSystemObj.Create();
    if rbNZ.Checked then
      AdminSystem.fdFields.fdCountry := 0
    else
      AdminSystem.fdFields.fdCountry := 1;
  end;

  if ({(DisplayPromoContents.TotalContents > 0) and}
      (Globals.StartupParam_UserPassword = '') and
      (Globals.StartupParam_UserToLoginAs = '')) then
  begin
    DisplayPromoContents.UpgradeVersionFrom := edtVersionFrom.Text;
    DisplayPromoContents.UpgradeVersionTo := edtVersionTo.Text + ' Build ';
    DisplayPromoContents.DateToValidate := dtDate.Date;

    if rbFirstLogin.Checked then
      DisplayPromoContents.DisplayTypes := [ctAll,ctUpgrade, ctMarketing, ctTechnical]
    else if rbSecondLogin.Checked then
      DisplayPromoContents.DisplayTypes := [ctAll,ctMarketing, ctTechnical];

    DisplayPromoContents.ListValidContents;
    if DisplayPromoContents.Count > 0 then
      DisplayPromoScreen
    else
      ShowMessage('No Content');
  end;
end;

procedure TFrmOptionsScreen.FormCreate(Sender: TObject);
begin
  dtDate.Date := Now;
end;

initialization
  ReadPracticeINI;

end.

