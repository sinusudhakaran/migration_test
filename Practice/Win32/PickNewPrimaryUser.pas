unit PickNewPrimaryUser;

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
  BlopiServiceFacade;

type
  TPickNewPrimaryUser = class(TForm)
    Image1: TImage;
    btnYes: TButton;
    btnNo: TButton;
    lblText: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    cmbPrimaryContact: TComboBox;
    procedure FormCreate(Sender: TObject);
  private
    FHelpContext : integer;
  public
  end;

  procedure PickPrimaryUser(CurrentUser : Guid = '');

//------------------------------------------------------------------------------
implementation

{$R *.dfm}

uses
  bkXPThemes,
  imagesfrm,
  BankLinkOnlineServices,
  WarningMoreFrm;

//------------------------------------------------------------------------------
procedure PickPrimaryUser(CurrentUser : Guid = '');
var
  MyDlg : TPickNewPrimaryUser;
  CurrPractice : Practice;
  UserIndex : integer;
begin
  try
    CurrPractice := ProductConfigService.GetPractice;

    MyDlg := TPickNewPrimaryUser.Create(Application);
    Try
      MyDlg.cmbPrimaryContact.Clear;
      for UserIndex := 0 to high(CurrPractice.Users) do
      begin
        if not (CurrPractice.Users[UserIndex].Id = CurrentUser) then
        begin
          MyDlg.cmbPrimaryContact.AddItem(CurrPractice.Users[UserIndex].FullName,
                                          CurrPractice.Users[UserIndex]);
        end;
      end;

      if MyDlg.cmbPrimaryContact.Items.Count = 0 then
      begin
        HelpfulWarningMsg('BankLink Practice is unable to delete the user as it is the primary contact' +
                          'for this practice. (' + CurrPractice.DisplayName + ')', 0 );
        Exit;
      end;

      MyDlg.cmbPrimaryContact.ItemIndex := 0;

      if MyDlg.ShowModal = mrYes then
      begin
        CurrPractice.DefaultAdminUserId := User(MyDlg.cmbPrimaryContact.Items.Objects[MyDlg.cmbPrimaryContact.ItemIndex]).Id;
        ProductConfigService.SavePractice;
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
