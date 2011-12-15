unit PickNewPrimaryUser;
//------------------------------------------------------------------------------
{
   Title:       Pick New Primary User Dialog

   Description: Picks a new Primary BankLink Online User

   Author:      Ralph Austen

   Remarks:

}
//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  BankLinkOnlineServices,
  OsFont;

type
  TPickNewPrimaryUser = class(TForm)
    Image1  : TImage;
    btnYes  : TButton;
    btnNo   : TButton;
    lblText : TLabel;
    Label1  : TLabel;
    Label2  : TLabel;
    cmbPrimaryContact: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    FHelpContext : integer;
  public
  end;

  function PickPrimaryUser(aUserCode: string = '';
                           aPractice : Practice = Nil) : Boolean;

//------------------------------------------------------------------------------
implementation

{$R *.dfm}

uses
  bkXPThemes,
  imagesfrm,
  WarningMoreFrm;

//------------------------------------------------------------------------------
function PickPrimaryUser(aUserCode : string = '';
                         aPractice : Practice = Nil) : Boolean;
var
  MyDlg        : TPickNewPrimaryUser;
  CurrPractice : Practice;
  UserIndex    : integer;
begin
  Result := False;
  try
    if not Assigned(aPractice) then
      aPractice := ProductConfigService.GetPractice;

    MyDlg := TPickNewPrimaryUser.Create(Application);
    Try
      MyDlg.cmbPrimaryContact.Clear;

      // Go through users adding to Combo if not current user
      for UserIndex := 0 to high(aPractice.Users) do
      begin
        if not (aPractice.Users[UserIndex].Id = ProductConfigService.GetUserGuid(aUserCode, aPractice)) then
        begin
          MyDlg.cmbPrimaryContact.AddItem(aPractice.Users[UserIndex].FullName,
                                          aPractice.Users[UserIndex]);
        end;
      end;

      // show error if no users
      if MyDlg.cmbPrimaryContact.Items.Count = 0 then
      begin
        HelpfulWarningMsg('BankLink Practice is unable to delete the user as it is the primary contact ' +
                          'for this practice. (' + CurrPractice.DisplayName + ')', 0 );
        Exit;
      end;

      MyDlg.cmbPrimaryContact.ItemIndex := 0;

      if MyDlg.ShowModal = mrYes then
      begin
        // Save Default Admin User
        aPractice.DefaultAdminUserId := User(MyDlg.cmbPrimaryContact.Items.Objects[MyDlg.cmbPrimaryContact.ItemIndex]).Id;
        ProductConfigService.SavePractice;
        Result := True;
      end;

    Finally
      FreeAndNil(MyDlg);
    End;
  except
    on E : Exception do
    begin
      raise Exception.Create('BankLink Practice was unable to connect to BankLink Online. ' + #13#13 + E.Message );
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TPickNewPrimaryUser.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  FHelpContext := 0;
  Image1.Picture := AppImages.QuestionBmp.Picture;
  {$IFDEF SmartBooks}
  self.Color := clBtnFace;
  {$ENDIF}

  Self.Position := poMainFormCenter;
end;

end.
