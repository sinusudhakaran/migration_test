unit myMYOBSignInFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, PracticeLedgerObj, CashbookMigrationRestData,
  OSFont, contnrs;

type
  TFormShowType = (fsSignIn, fsSelectFirm, fsSelectClient);

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
  private
    { Private declarations }
    FFormShowType : TFormShowType;
    FShowFirmSelection : Boolean;

    FSelectedName: string;
    FSelectedID: string;

    procedure ShowConnectionError(aError : string);
    procedure LoadFirms;
    procedure LoadBusinesses;
    procedure SaveUser;
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
  ErrorMoreFrm, SYDEFS, Admin32, LogUtil, AuditMgr, IniSettings, SelectBusinessFrm;

{$R *.dfm}

procedure TmyMYOBSignInForm.btnCancelClick(Sender: TObject);
begin
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
begin
  OldCursor := Screen.Cursor;
  Screen.Cursor := crHourglass;
  try
    if CurrUser.MYOBEmailAddress <> Trim(edtEmail.Text) then
    begin
      SaveUser;
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
        if ((PracticeLedger.Firms.Count = 0) and (not PracticeLedger.GetFirms(PracticeLedger.Firms, sError))) then
        begin
          Screen.Cursor := OldCursor;
          ShowConnectionError(sError);
          ModalResult := mrCancel;
        end;
        //pnlLogin.Visible := False;
        pnlFirmSelection.Visible := True;
        Self.Height := 250;
        btnOK.Visible := True;

        LoadFirms;
      end
      else if (FormShowType = fsSignIn) and (not ShowFirmSelection) then
      begin // means show client - for a normal user
        // Get Businesses
        if ((PracticeLedger.Businesses.Count = 0) and (not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID ,PracticeLedger.Businesses, sError))) then
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
      end;
    end;
  finally
    Screen.Cursor := OldCursor;
  end;
end;

procedure TmyMYOBSignInForm.FormShow(Sender: TObject);
var
  sError: string;
  OldCursor: TCursor;
begin
  edtPassword.Text := '';
  edtEmail.Text := CurrUser.MYOBEmailAddress;
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
      Self.Height := 185;
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
        if ((PracticeLedger.Firms.Count = 0) and (not PracticeLedger.GetFirms(PracticeLedger.Firms, sError))) then
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
        if ((PracticeLedger.Businesses.Count = 0) and (not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID, PracticeLedger.Businesses, sError))) then
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
        if (Firm.ID = AdminSystem.fdFields.fdmyMYOBFirmID) then
          Index := Row;
        cmbSelectFirm.Items.AddObject(Firm.Name, TObject(Firm));
        Inc(Row);
      end;
    end;
  end;
  cmbSelectFirm.ItemIndex := Index;
  cmbSelectFirm.SetFocus;
end;

procedure TmyMYOBSignInForm.SaveUser;
const
  ThisMethodName = 'SaveMYOBEmail';
var
  eUser: pUser_Rec;
  StoredLRN   : Integer;
  StoredName  : string;
  pu          : pUser_Rec;
  pCF    : pClient_File_Rec;
  FileList : TStringList;
  i: Integer;
begin
  //get the user_rec again as the admin system may have changed in the mean time.
  eUser := AdminSystem.fdSystem_User_List.FindCode(CurrUser.Code);
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

    FileList := TStringList.Create;
    try
      if AdminSystem.fdSystem_Client_File_List.ItemCount > 0  then
      begin
        //Create a dummy client LRN so that file access will be denied
        for i := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
        begin
          pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i );

          if AdminSystem.fdSystem_File_Access_List.Allow_Access( pu^.usLRN, pCF^.cfLRN ) then
          begin
            FileList.Add(IntToStr( pCF^.cfLRN ));
            {NewLVItem := lvFiles.Items.Add;
            NewLVItem.caption := pCF^.cfFile_Code;
            NewLVItem.SubItems.AddObject( pCF^.cfFile_Name, Pointer( pCF^.cfLRN ));
            NewLVItem.ImageIndex := 0;}
          end;
        end;
      end;

      //Clear out the existing information, this will allow access to all files
      AdminSystem.fdSystem_File_Access_List.Delete_User( pu^.usLRN );
      if FileList.Count > 0 then
      begin
        for i := 0 to Pred(FileList.Count ) do
          AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( pu^.usLRN, StrToInt(Trim (FileList.Strings[i])) );
      end
      else //create a dummy client LRN so that file access will be denied
        AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec(  pu^.usLRN, 0 )
    finally
      if Assigned(FileList) then
      begin
        FileList.Clear;
        FreeAndNil(FileList);
      end;
    end;

    //*** Flag Audit ***
    SystemAuditMgr.FlagAudit(arUsers);
    SaveAdminSystem;
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

end.
