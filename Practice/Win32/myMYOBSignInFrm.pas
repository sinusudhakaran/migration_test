unit myMYOBSignInFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, PracticeLedgerObj, CashbookMigrationRestData,
  OSFont, contnrs;

type
  TFormShowType = (fsSignIn, fsSelectFirm, fsSelectClient, fsFirmForceSignIn);

  TmyMYOBSignInForm = class(TForm)
    pnlLogin: TPanel;
    lblEmail: TLabel;
    lblPassword: TLabel;
    lblForgotPassword: TLabel;
    edtEmail: TEdit;
    edtPassword: TEdit;
    pnlClientSelection: TPanel;
    ShapeBorder: TShape;
    Label1: TLabel;
    cmbSelectClient: TComboBox;
    pnlControls: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Shape2: TShape;
    pnlFirmSelection: TPanel;
    Label6: TLabel;
    Shape1: TShape;
    cmbSelectFirm: TComboBox;
    btnSignIn: TButton;

    procedure btnSignInClick(Sender: TObject);
    procedure lblForgotPasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure cmbSelectFirmChange(Sender: TObject);
    procedure cmbSelectFirmEnter(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FFormShowType : TFormShowType;
    FShowFirmSelection : Boolean;
    FProcessingLogin : Boolean;
    FSelectedName: string;
    FSelectedID: string;
    FOldFirmID : string;
    FForcedSignInSucceed : Boolean;
    FShowClientSelection : Boolean;
    FIsSignIn : Boolean;
//    FValidateClientAgainstFirm : Boolean;
    procedure ShowConnectionError(aError : string);
    procedure LoadFirms;
    procedure LoadBusinesses;
    procedure SaveUser;
    procedure UpdateControls;
    procedure SaveMyMYOBUserDetails;
    procedure ResetMyMYOBUserDetails;
  public
    { Public declarations }
    property FormShowType : TFormShowType read FFormShowType write FFormShowType;
    property ShowFirmSelection : Boolean read FShowFirmSelection write FShowFirmSelection;
    property ShowClientSelection : Boolean read FShowClientSelection write FShowClientSelection;
//    property ValidateClientAgainstFirm : Boolean read FValidateClientAgainstFirm write FValidateClientAgainstFirm;

    property SelectedID: string read FSelectedID write FSelectedID;
    property SelectedName : string read FSelectedName write FSelectedName;
  end;

var
  myMYOBSignInForm: TmyMYOBSignInForm;

const
  UNITNAME = 'myMYOBSignInFrm';

implementation

uses ShellApi, Globals, CashbookMigration, WarningMoreFrm, bkContactInformation,
  ErrorMoreFrm, SYDEFS, Admin32, LogUtil, AuditMgr, IniSettings,
  SelectBusinessFrm, YesNoDlg;

{$R *.dfm}

procedure TmyMYOBSignInForm.btnCancelClick(Sender: TObject);
begin
  if not FProcessingLogin then  
    ModalResult := mrCancel;
end;

procedure TmyMYOBSignInForm.btnOKClick(Sender: TObject);
var
  Firm : TFirm;
begin
  if (FormShowType = fsSelectFirm) then
  begin
    if ((Trim(cmbSelectFirm.Items.Text) <> '') and (cmbSelectFirm.ItemIndex >= 0)) then
    begin
      Firm := TFirm(cmbSelectFirm.Items.Objects[cmbSelectFirm.ItemIndex]);
      if Assigned(Firm) then
      begin
        FSelectedID := Firm.ID;
        FSelectedName := Firm.Name;
      end;
    end;
  end;
  (*else if (FormShowType = fsSelectClient) then
  begin
    if ((Trim(cmbSelectClient.Items.Text) <> '') and (cmbSelectClient.ItemIndex >= 0)) then
    begin
      Business := TBusinessData(cmbSelectClient.Items.Objects[cmbSelectClient.ItemIndex]);
      if Assigned(Business) then
      begin
        FSelectedID := Business.ID;
        FSelectedName := Business.Name;
      end;
    end;
  end;*)
  ModalResult := mrOk;
end;

procedure TmyMYOBSignInForm.btnSignInClick(Sender: TObject);
var
  sError: string;
  OldCursor: TCursor;
  InvalidPass: boolean;
  BusinessFrm : TSelectBusinessForm;
  ClientFirms : TFirms;
  Firm : TFirm;
  ClientHasAccessToFirm : Boolean;
  i : Integer;
begin
  if Not FIsSignIn then
  begin
    FIsSignIn := not FIsSignIn;
    UpdateControls;
    Exit;
  end;

  UpdateControls;
  Application.ProcessMessages;
  FProcessingLogin := True;
  FForcedSignInSucceed := False;
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    if CurrUser.MYOBEmailAddress <> Trim(edtEmail.Text) then
    begin
      SaveUser;

      PracticeLedger.Firms.Clear;
      PracticeLedger.Businesses.Clear;
    end;

    if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
    begin
      HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
      Exit;
    end;

    PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
    PracticeLedger.EncryptToken(UserINI_myMYOB_Access_Token);

    //my.MYOB login
    if not PracticeLedger.Login(edtEmail.Text, edtPassword.Text, sError, InvalidPass) then
    begin
      Screen.Cursor := OldCursor;

      if InvalidPass then
        HelpfulWarningMsg(sError, 0)
      else
        ShowConnectionError(sError);
      edtEmail.SetFocus;
    end
    else
    begin
      lblForgotPassword.Visible := True;
      FIsSignIn := not FIsSignIn;
      UpdateControls;
      SaveMyMYOBUserDetails;
      btnSignIn.Default := False;
      if (FormShowType in [fsSignIn, fsFirmForceSignIn, fsSelectFirm]) and (ShowFirmSelection) then
      begin
        // Get Firms
        if ((PracticeLedger.Firms.Count = 0) and (not PracticeLedger.GetFirms(PracticeLedger.Firms, sError))) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        //pnlLogin.Visible := False;
        if (FormShowType = fsFirmForceSignIn) then
        begin
          ModalResult := mrOk;
          Exit;
        end;

        FormShowType := fsSelectFirm;
        pnlFirmSelection.Visible := True;
        Self.Height := 250;
        btnOK.Visible := True;
        FForcedSignInSucceed := True;
        LoadFirms;
      end;

(*****      
////////////////////////////////// Dave moved this code to outside on the AccoutingSytemFrm //////////////////////////////////////////
      if (FormShowType = fsSignIn) then // and (ValidateClientAgainstFirm) then
      begin
        ClientFirms := TFirms.Create;

        if (not PracticeLedger.GetFirms(ClientFirms, sError)) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ResetMyMYOBUserDetails;
          ModalResult := mrCancel;
        end;
        ClientHasAccessToFirm := False;
        for i := 0 to ClientFirms.Count - 1 do
        begin
          Firm := ClientFirms.GetItem(i);

          if Assigned(Firm) then
          begin
            // Check for Practice Ledger
            if Pos('PL',Firm.EligibleLicense) > 0 then
            begin
              if (Firm.ID = AdminSystem.fdFields.fdmyMYOBFirmID) then
              begin
                ClientHasAccessToFirm := True;
                Break;
              end;
            end;
          end;
        end;
        ClientFirms.Clear;
        FreeAndNil(ClientFirms);
        if not ClientHasAccessToFirm then 
//        if not PracticeLedger.MYOBUserHasAccesToFirm( AdminSystem.fdFields.fdmyMYOBFirmID, false ) then
        begin
          Screen.Cursor := OldCursor;
          sError := 'Your MYOB Credential does not have access to the Firm. Please log in with a different MYOB Credential, or contact support.';
          HelpfulWarningMsg( sError, 0 );
          ResetMyMYOBUserDetails;
          ModalResult := mrCancel;
          Exit;
        end;
      end;
////////////////////////////////// Dave Move this code to outside on the AccoutingSytemFrm //////////////////////////////////////////
*********)

      if not PracticeLedger.MYOBUserHasAccesToFirm( AdminSystem.fdFields.fdmyMYOBFirmID, false ) then
        begin
          Screen.Cursor := OldCursor;
          sError := 'Your MYOB Credential does not have access to the Firm. Please log in with a different MYOB Credential, or contact support.';
          HelpfulWarningMsg( sError, 0 );
          ResetMyMYOBUserDetails;
          ModalResult := mrCancel;
          Exit;
        end;
        
      if (FormShowType = fsSignIn) and (ShowClientSelection) then
      begin // means show client - for a normal user
        // Get Businesses
        if ((PracticeLedger.Businesses.Count = 0) and (not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID , ltPracticeLedger ,PracticeLedger.Businesses, sError))) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        FormShowType := fsSelectClient;
        BusinessFrm := TSelectBusinessForm.Create(Self);
        try
          if BusinessFrm.ShowModal = mrOk then
          begin
            FSelectedID := BusinessFrm.SelectedBusinessID;
            FSelectedName := BusinessFrm.SelectedBusinessName;

            btnOKClick(Self);
          end
          else
            ModalResult := mrCancel;
        finally
          FreeAndNil(BusinessFrm);
        end;
        //pnlLogin.Visible := False;
        //pnlClientSelection.Visible := True;
        //Self.Height := 300;
        //btnOK.Visible := True;
      end
      else if (FormShowType = fsSignIn) then
        btnOKClick(Self);
    end;
    edtPassword.Enabled := edtEmail.Enabled;
    lblEmail.Enabled := edtEmail.Enabled;
    lblPassword.Enabled := edtEmail.Enabled;

  finally
    Screen.Cursor := OldCursor;
    FProcessingLogin := False;
  end;
end;

procedure TmyMYOBSignInForm.cmbSelectFirmChange(Sender: TObject);
var
  Firm : TFirm;
  iOldFirmIndex: Integer;
begin
  if cmbSelectFirm.Items.Count <= 0 then
    Exit;
    
  iOldFirmIndex := -1;

  Firm := TFirm(cmbSelectFirm.Items.Objects[cmbSelectFirm.ItemIndex]);
  iOldFirmIndex := cmbSelectFirm.ItemIndex;
  
  if not Assigned(Firm) then
    Exit;

  if FOldFirmID = Firm.ID then
    Exit;

  if FForcedSignInSucceed then
    Exit;

  if ((Trim(FSelectedID) <> '') and
      (Trim(FSelectedID) <> Firm.ID))
  then
  begin
    if not (AskYesNo('Change Firm',
                 'This change will affect the MYOB client setup done for all clients.'#13#13 +
                 'You need a MYOB sign in before changing the Firm.'#13#13+
                 'Do you want to continue?',DLG_YES, 0) = DLG_YES) then
    begin
      cmbSelectFirm.ItemIndex := iOldFirmIndex;
      Exit;
    end;
    SelectedID := Firm.ID;
    SelectedName := Firm.Name;
    cmbSelectFirm.Enabled := False;
    FormShowType := fsFirmForceSignIn;
    FOldFirmID := SelectedID;
    FormShow(Self);
  end;
end;

procedure TmyMYOBSignInForm.cmbSelectFirmEnter(Sender: TObject);
var
  Firm : TFirm;
begin
  Firm := TFirm(cmbSelectFirm.Items.Objects[cmbSelectFirm.ItemIndex]);
  if not Assigned(Firm) then
    Exit;

  FOldFirmID := Firm.ID;
end;

procedure TmyMYOBSignInForm.FormCreate(Sender: TObject);
begin
  ShowClientSelection := False;
  ShowFirmSelection := False;
//  ValidateClientAgainstFirm := False;
end;

procedure TmyMYOBSignInForm.FormShow(Sender: TObject);
var
  sError: string;
  OldCursor: TCursor;
begin
  FIsSignIn := True;
  FProcessingLogin := False;
  edtPassword.Text := '';
  edtEmail.Text := CurrUser.MYOBEmailAddress;
  if Trim(edtEmail.Text)= '' then
    edtEmail.Text := CurrUser.EmailAddress;

  pnlClientSelection.Visible := False;
  pnlFirmSelection.Visible := False;
  pnlLogin.Visible := False;
  btnOK.Visible := True;
  lblForgotPassword.Visible := True;
  case FormShowType of
    fsSignIn :
    begin
      pnlLogin.Visible := True;
      Self.Height := 185;
      btnOK.Visible := False;
      //lblForgotPassword.Visible := False;
    end;
    fsFirmForceSignIn :
    begin
      pnlLogin.Visible := True;
      pnlFirmSelection.Visible := True;
      Self.Height := 250;
      btnOK.Visible := False;
      edtPassword.SetFocus;
    end;
    fsSelectFirm :
    begin
      pnlFirmSelection.Visible := True;
      Self.Height := 150;
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      try
        PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
        PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
        PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;
        Application.ProcessMessages;
        // Get Firms
        if ((PracticeLedger.Firms.Count = 0) and (not PracticeLedger.GetFirms(PracticeLedger.Firms, sError))) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        LoadFirms;

        if ( cmbSelectFirm.Items.Count = 0 ) then // There was no entitlement for any firms
        begin

        end;
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
    fsSelectClient :
    begin
      pnlClientSelection.Visible := True;
      Self.Height := 150;
      OldCursor := Screen.Cursor;
      Screen.Cursor := crHourglass;
      try
        PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
        PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
        PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;
        Application.ProcessMessages;
        // Get Businesses
        if ((PracticeLedger.Businesses.Count = 0) and (not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID, ltPracticeLedger,PracticeLedger.Businesses, sError))) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        LoadBusinesses;
      finally
        Screen.Cursor := OldCursor;
      end;
    end;
  end;
end;

procedure TmyMYOBSignInForm.lblForgotPasswordClick(Sender: TObject);
var
  link : string;
  OldCursor: TCursor;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;

  try
    link := PRACINI_DefaultCashbookForgotPasswordURL;

    if length(link) = 0 then
      exit;

    ShellExecute(0, 'open', PChar(link), nil, nil, SW_NORMAL);
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TmyMYOBSignInForm.LoadBusinesses;
var
  i, Index: Integer;
  Business : TBusinessData;
begin
  cmbSelectClient.Items.Clear;
  Index := 0;

  if not Assigned(PracticeLedger.Businesses) then
    Exit;

  if PracticeLedger.Businesses.Count = 0 then
    ModalResult := mrCancel;

  for i := 0 to PracticeLedger.Businesses.Count - 1 do
  begin
    Business := PracticeLedger.Businesses.GetItem(i);
    if Assigned(Business) then
    begin
      if Business.ID = MyClient.clExtra.cemyMYOBClientIDSelected then
        Index := i;
      cmbSelectClient.Items.AddObject(Business.Name, TObject(Business));
    end;
  end;
  cmbSelectClient.ItemIndex := Index;
  cmbSelectClient.SetFocus;
end;

procedure TmyMYOBSignInForm.LoadFirms;
var
  i, Index, Row: Integer;
  Firm : TFirm;
  sSelectedID: string;
begin
  cmbSelectFirm.Items.Clear;
  Index := 0;
  if not Assigned(PracticeLedger.Firms) then
    Exit;

  if PracticeLedger.Firms.Count = 0 then
    ModalResult := mrCancel;
  Row := 0;
  for i := 0 to PracticeLedger.Firms.Count - 1 do
  begin
    Firm := PracticeLedger.Firms.GetItem(i);
    if Assigned(Firm) then
    begin
      // Check for Practice Ledger
      if Pos('PL',Firm.EligibleLicense) > 0 then
      begin
        if (Firm.ID = FSelectedID) then
          Index := Row;
        cmbSelectFirm.Items.AddObject(Firm.Name, TObject(Firm));
        Inc(Row);
      end;
    end;
  end;
  cmbSelectFirm.ItemIndex := Index;
  FOldFirmID := FSelectedID;
  cmbSelectFirm.SetFocus;
end;

procedure TmyMYOBSignInForm.ResetMyMYOBUserDetails;
begin
  UserINI_myMYOB_Access_Token := '';
  UserINI_myMYOB_Random_Key := '';
  UserINI_myMYOB_Refresh_Token := '';
  UserINI_myMYOB_Expires_TokenAt := 0;

  WriteUsersINI(CurrUser.Code);
end;

procedure TmyMYOBSignInForm.SaveMyMYOBUserDetails;
begin
  UserINI_myMYOB_Access_Token := PracticeLedger.UnEncryptedToken;
  UserINI_myMYOB_Random_Key := PracticeLedger.RandomKey;
  UserINI_myMYOB_Refresh_Token := PracticeLedger.RefreshToken;
  UserINI_myMYOB_Expires_TokenAt := PracticeLedger.TokenExpiresAt;
  WriteUsersINI(CurrUser.Code);
end;

procedure TmyMYOBSignInForm.SaveUser;
const
  ThisMethodName = 'SaveMYOBEmail';
var
  eUser: pUser_Rec;
  StoredLRN   : Integer;
  StoredName  : string;
  pu          : pUser_Rec;
begin
  //get the user_rec again as the admin system may have changed in the mean time.
  if Assigned(CurrUser) then
  begin
    eUser := AdminSystem.fdSystem_User_List.FindCode(CurrUser.Code);
    if Assigned(eUser) then
    begin
      StoredLRN := eUser.usLRN; {user pointer about to be destroyed}
      StoredName := eUser.usCode;

      if LoadAdminSystem(true, ThisMethodName ) Then
      begin
        pu := AdminSystem.fdSystem_User_List.FindLRN(StoredLRN);

        if not Assigned(pu) Then
        begin
          UnlockAdmin;
          HelpfulErrorMsg('The User ' + StoredName + ' can no longer be found in the Admin System.', 0);
          Exit;
        end;
        pu^.usMYOBEMail := Trim(edtEmail.Text);
        CurrUser.MYOBEmailAddress := Trim(edtEmail.Text);
        SaveAdminSystem;
      end;
    end;
  end;
end;

procedure TmyMYOBSignInForm.ShowConnectionError(aError: string);
var
  SupportNumber : string;
begin
  SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
  HelpfulErrorMsg('Could not connect to MYOB service, please try again later. ' +
                  'If problem persists please contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.',
                  0, false, aError, true);
end;

procedure TmyMYOBSignInForm.UpdateControls;
begin
  if FIsSignIn then
  begin
    edtEmail.Enabled := True;
    btnSignIn.Caption := 'Login';
  end
  else
  begin
    edtEmail.Enabled := False;
    btnSignIn.Caption := 'Logout';
  end;

  edtPassword.Enabled := edtEmail.Enabled;
  lblEmail.Enabled := edtEmail.Enabled;
  lblPassword.Enabled := edtEmail.Enabled;
  //lblForgotPassword.Visible := (not FIsSignIn);
end;

end.
