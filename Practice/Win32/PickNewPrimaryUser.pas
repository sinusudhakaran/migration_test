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
                           aPractice : TBloPracticeRead = Nil) : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  LOGUTIL,
  imagesfrm,
  bkXPThemes,
  WarningMoreFrm,
  BkConst;

{$R *.dfm}

const
  UNIT_NAME = 'PickNewPrimaryUser';

//------------------------------------------------------------------------------
function PickPrimaryUser(aUserCode : string = '';
                         aPractice : TBloPracticeRead = Nil) : Boolean;
var
  MyDlg         : TPickNewPrimaryUser;
  UserIndex     : integer;
  AdminRollName : Widestring;
  RoleIndex     : integer;
  UserCode      : string;
begin
  Result := False;
  try
    if not Assigned(aPractice) then
      aPractice := ProductConfigService.GetPractice;

    AdminRollName := aPractice.GetRoleFromPracUserType(ustSystem, aPractice).RoleName;

    MyDlg := TPickNewPrimaryUser.Create(Application);
    Try
      MyDlg.cmbPrimaryContact.Clear;

      // Go through users adding to Combo if not current user
      for UserIndex := 0 to high(aPractice.Users) do
      begin
        if not (aPractice.Users[UserIndex].Id = ProductConfigService.GetPracUserGuid(aUserCode, aPractice)) then
        begin
          for RoleIndex := Low(aPractice.Users[UserIndex].RoleNames) to
                          High(aPractice.Users[UserIndex].RoleNames) do
          begin
            // Add only Admin User Types
            if aPractice.Users[UserIndex].RoleNames[RoleIndex] = AdminRollName then
            begin
              MyDlg.cmbPrimaryContact.AddItem(aPractice.Users[UserIndex].FullName,
                                          aPractice.Users[UserIndex]);
              break;
            end;
          end;
        end;
      end;

      // show error if no users
      if MyDlg.cmbPrimaryContact.Items.Count = 0 then
      begin
        HelpfulWarningMsg('BankLink Practice is unable to delete the user as it is the primary contact user ' +
                          'for this practice. (' + aPractice.DisplayName + ')', 0 );
        Exit;
      end;

      MyDlg.cmbPrimaryContact.ItemIndex := 0;

      if MyDlg.ShowModal = mrYes then
      begin
        // Save Default Admin User
        aPractice.DefaultAdminUserId := TBloUserRead(MyDlg.cmbPrimaryContact.Items.Objects[MyDlg.cmbPrimaryContact.ItemIndex]).Id;
        Result := ProductConfigService.SavePractice;

        UserCode := TBloUserRead(MyDlg.cmbPrimaryContact.Items.Objects[MyDlg.cmbPrimaryContact.ItemIndex]).UserCode;
        LogUtil.LogMsg(lmInfo, UNIT_NAME, UserCode + ' has been successfully set to the Default Admin on BankLink Online.');
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

