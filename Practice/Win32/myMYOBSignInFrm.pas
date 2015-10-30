unit myMYOBSignInFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, PracticeLedgerObj, CashbookMigrationRestData, OSFont;

type
  TFormShowType = (fsSignIn, fsSelectFirm, fsSelectClient);

  TmyMYOBSignInForm = class(TForm)
    pnlLogin: TPanel;
    lblEmail: TLabel;
    lblPassword: TLabel;
    lblForgotPassword: TLabel;
    edtEmail: TEdit;
    edtPassword: TEdit;
    btnSignIn: TButton;
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
    procedure btnSignInClick(Sender: TObject);
    procedure lblForgotPasswordClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FFirms : TFirms;
    FBusinesses : TBusinesses;
    FFormShowType : TFormShowType;
    FShowFirmSelection : Boolean;

    FSelectedName: string;
    FSelectedID: string;

    procedure ShowConnectionError(aError : string);
    procedure LoadFirms;
    procedure LoadBusinesses;
  public
    { Public declarations }
    property FormShowType : TFormShowType read FFormShowType write FFormShowType;
    property ShowFirmSelection : Boolean read FShowFirmSelection write FShowFirmSelection;
    property SelectedID: string read FSelectedID write FSelectedID;
    property SelectedName : string read FSelectedName write FSelectedName;
  end;

var
  myMYOBSignInForm: TmyMYOBSignInForm;

const
  UNITNAME = 'myMYOBSignInFrm';

implementation

uses ShellApi, Globals, CashbookMigration, WarningMoreFrm, bkContactInformation,
  ErrorMoreFrm, SYDEFS, Admin32, LogUtil, AuditMgr, IniSettings;

{$R *.dfm}

procedure TmyMYOBSignInForm.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TmyMYOBSignInForm.btnOKClick(Sender: TObject);
var
  Firm : TFirm;
  Business : TBusinessData;
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
  end
  else if (FormShowType = fsSelectClient) then
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
  end;
  ModalResult := mrOk;
end;

procedure TmyMYOBSignInForm.btnSignInClick(Sender: TObject);
var
  sError: string;
  OldCursor: TCursor;
  InvalidPass: boolean;
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    if UserINI_myMYOB_EmailAddress <> Trim(edtEmail.Text) then
    begin
      UserINI_myMYOB_EmailAddress := Trim(edtEmail.Text);
      WriteUsersINI(CurrUser.Code);
    end;
    PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
    PracticeLedger.EncryptToken(UserINI_myMYOB_Access_Token);

    // my.MYOB login
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
      UserINI_myMYOB_Access_Token := PracticeLedger.UnEncryptedToken;
      UserINI_myMYOB_Random_Key := PracticeLedger.RandomKey;
      UserINI_myMYOB_Refresh_Token := PracticeLedger.RefreshToken;
      UserINI_myMYOB_Expires_TokenAt := PracticeLedger.TokenExpiresAt;
      WriteUsersINI(CurrUser.Code);
      if (FormShowType = fsSignIn) and (ShowFirmSelection) then
      begin
        // Get Firms
        FormShowType := fsSelectFirm;
        if not PracticeLedger.GetFirms(FFirms, sError) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        //pnlLogin.Visible := False;
        pnlFirmSelection.Visible := True;
        Self.Height := 300;
        btnOK.Visible := True;

        LoadFirms;
      end
      else if (FormShowType = fsSignIn) and (not ShowFirmSelection) then
      begin // means show client - for a normal user
        // Get Businesses
        FormShowType := fsSelectClient;
        if not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID ,FBusinesses, sError) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        //pnlLogin.Visible := False;
        pnlClientSelection.Visible := True;
        Self.Height := 300;
        btnOK.Visible := True;

        LoadBusinesses;
      end;
    end;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TmyMYOBSignInForm.FormCreate(Sender: TObject);
begin
  FFirms := TFirms.Create;
  FBusinesses := TBusinesses.Create;
end;

procedure TmyMYOBSignInForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FFirms) then
  begin
    FFirms.Clear;
    FreeAndNil(FFirms);
  end;
  if Assigned(FBusinesses) then
  begin
    FBusinesses.Clear;
    FreeAndNil(FBusinesses);
  end;
end;

procedure TmyMYOBSignInForm.FormShow(Sender: TObject);
var
  sError: string;
  OldCursor: TCursor;
begin
  edtPassword.Text := '';
  edtEmail.Text := UserINI_myMYOB_EmailAddress;
  if Trim(edtEmail.Text)= '' then
    edtEmail.Text := CurrUser.EmailAddress;

  pnlClientSelection.Visible := False;
  pnlFirmSelection.Visible := False;
  pnlLogin.Visible := False;
  btnOK.Visible := True;

  case FormShowType of
    fsSignIn :
    begin
      pnlLogin.Visible := True;
      Self.Height := 250;
      btnOK.Visible := False;
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
        if not PracticeLedger.GetFirms(FFirms, sError) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        LoadFirms;
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
        if not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID, FBusinesses, sError) then
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

  if not Assigned(FBusinesses) then
    Exit;

  if FBusinesses.Count = 0 then
    ModalResult := mrCancel;

  for i := 0 to FBusinesses.Count - 1 do
  begin
    Business := FBusinesses.GetItem(i);
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
  i, Index: Integer;
  Firm : TFirm;
begin
  cmbSelectFirm.Items.Clear;
  Index := 0;
  if not Assigned(FFirms) then
    Exit;

  if FFirms.Count = 0 then
    ModalResult := mrCancel;

  for i := 0 to FFirms.Count - 1 do
  begin
    Firm := FFirms.GetItem(i);
    if Assigned(Firm) then
    begin
      // Check for Practice Ledger 
      if Pos('PL',Firm.EligibleLicense) > 0 then
      begin
        if (Firm.ID = AdminSystem.fdFields.fdmyMYOBFirmID) then
          Index := i;
        cmbSelectFirm.Items.AddObject(Firm.Name, TObject(Firm));
      end;
    end;
  end;
  cmbSelectFirm.ItemIndex := Index;
  cmbSelectFirm.SetFocus;
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

end.
