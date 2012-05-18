 Unit EditUserDlg;
//------------------------------------------------------------------------------
{
   Title:       Edit User Dialog

   Description: Allows editing and set up for system users

   Author:      Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------
Interface

Uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  SYDEFS,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  CheckLst,
  AuditMgr,
  OsFont,
  BankLinkOnlineServices;

Type
  TUserValues = record
    FullName : String;
    Email : String;
    DirectDial : String;
    Password : String;
    CanCreateEditMasterMems : Boolean;
    ShowPrinter : Boolean;
    SuppressHeaderFooter : Boolean;
    ShowPracticeLogo : Boolean;
    CanAccessBankLinkOnline : Boolean;
    UsePracPassInOnline : Boolean;
    UserType : Integer;
  end;

  TUI_Modes = (uimBasic, uimOnline, uimOnlineUnlinked, uimOnlineShowUser);

  TdlgEditUser = Class(TForm)
    btnOK        : TButton;
    btnCancel    : TButton;
    pcMain: TPageControl;
    tsDetails: TTabSheet;
    tsFiles: TTabSheet;
    Label6: TLabel;
    rbAllFiles: TRadioButton;
    rbSelectedFiles: TRadioButton;
    pnlSelected: TPanel;
    lvFiles: TListView;
    btnAdd: TButton;
    btnRemove: TButton;
    btnRemoveAll: TButton;
    pnlMain: TPanel;
    chkShowPracticeLogo: TCheckBox;
    CBSuppressHeaderFooter: TCheckBox;
    CBPrintDialogOption: TCheckBox;
    chkMaster: TCheckBox;
    Label7: TLabel;
    Label8: TLabel;
    cmbUserType: TComboBox;
    lblUserType: TLabel;
    Label5: TLabel;
    eConfirmPass: TEdit;
    ePass: TEdit;
    Label4: TLabel;
    Label9: TLabel;
    eDirectDial: TEdit;
    eMail: TEdit;
    Label3: TLabel;
    Label2: TLabel;
    eFullName: TEdit;
    eUserCode: TEdit;
    Label1: TLabel;
    LblPasswordValidation: TLabel;
    stUserName: TLabel;
    pnlUserIsLoggedOn: TPanel;
    pnlSpecial: TPanel;
    chkLoggedIn: TCheckBox;
    pnlOnline: TPanel;
    pnlOnlineLeft: TPanel;
    pnlOnlineRight: TPanel;
    pnlOnlineMid: TPanel;
    pnlAllowAccess: TPanel;
    chkCanAccessBankLinkOnline: TCheckBox;
    pnlUnlinked: TPanel;
    radCreateNewOnlineUser: TRadioButton;
    radLinkExistingOnlineUser: TRadioButton;
    cmbLinkExistingOnlineUser: TComboBox;
    pnlOnlineUser: TPanel;
    Label10: TLabel;
    eOnlineUser: TEdit;
    lblPrimaryContact: TLabel;

    Procedure btnCancelClick(Sender: TObject);
    Procedure btnOKClick(Sender: TObject);
    Procedure chkLoggedInClick(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    Procedure FormShow(Sender: TObject);
    procedure btnRemoveAllClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure rbAllFilesClick(Sender: TObject);
    procedure rbSelectedFilesClick(Sender: TObject);
    procedure cmbUserTypeSelect(Sender: TObject);
    procedure chkCanAccessBankLinkOnlineClick(Sender: TObject);
    procedure radCreateNewOnlineUserClick(Sender: TObject);
    procedure radLinkExistingOnlineUserClick(Sender: TObject);
  Private
    fOldValues : TUserValues;

    fUserGuid     : TBloGuid;
    fIsCreateUser : boolean;
    fIsPrimaryUser : Boolean;
    fokPressed  : boolean;
    fformLoaded : boolean;
    fEditChk    : boolean;
    fUIMode     : TUI_Modes;

    FIsLoggedIn: Boolean;

    function UserLoggedInChanged: Boolean;
    
    procedure StoreOldValues;
    function HasUserValueChanged : Boolean;
    function GetCurrentCode : string;
    procedure OnlineControlSetup(aUIMode : TUI_Modes);
    Function OKtoPost : boolean;
    Function PosttoBankLinkOnline : Boolean;
    Procedure UpdateAdminFileAccessList( UserLRN : integer);
    Function IsBankLinkOnlineUser : Boolean;
    procedure SetOnlineUIMode(var aUIMode : TUI_Modes; aPractice: TBloPracticeRead);

    property okPressed  : boolean read fokPressed  write fokPressed;
    property formLoaded : boolean read fformLoaded write fformLoaded;
    property EditChk    : boolean read fEditChk    write fEditChk;
  Public
    Function Execute(User: pUser_Rec) : boolean;

    property UserGuid     : TBloGuid    read fUserGuid     write fUserGuid;
    property IsCreateUser : boolean read fIsCreateUser write fIsCreateUser;
  End;

Function EditUser(w_PopupParent: TForm; User_Code: String) : boolean;
Function AddUser(w_PopupParent: TForm) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  Admin32,
  bkconst,
  BKHelp,
  bkXPThemes,
  ClientLookUpExFrm,
  ErrorMoreFrm,
  InfoMoreFrm,
  Globals,
  ImagesFrm,
  LogUtil,
  SyUSIO,
  WarningMoreFrm,
  YesNoDlg,
  RegExprUtils,
  PickNewPrimaryUser,
  progress;

Const
  UNITNAME = 'EDITUSERDLG';
  COMP_VERT_DIFF = 60;

//------------------------------------------------------------------------------
procedure TdlgEditUser.FormCreate(Sender: TObject);
var
  UserTypeIndex : Integer;
begin
  bkXPThemes.ThemeForm( Self);

  formLoaded := false;
  SetUpHelp;
  pcMain.ActivePage := tsDetails;

  SetpasswordFont(ePass);
  SetpasswordFont(eConfirmPass);

  cmbUserType.Clear;
  for UserTypeIndex := ustmin to ustMax do
    cmbUserType.Items.Add(ustNames[UserTypeIndex]);
End;

//------------------------------------------------------------------------------
procedure TdlgEditUser.SetOnlineUIMode(var aUIMode : TUI_Modes; aPractice: TBloPracticeRead);
var
  BloUserRead : TBloUserRead;
  BloArrayOfUserRead : TBloArrayOfUserRead;

  //----------------------------
  procedure CheckForUnlinked;
  var
    index : integer;
  begin
    BloArrayOfUserRead := ProductConfigService.GetUnLinkedOnlineUsers(aPractice);
    // Are there unlinked online users to link to?
    if (assigned(BloArrayOfUserRead)) and
       (high(BloArrayOfUserRead) >= 0) then
    begin
      aUIMode := uimOnlineUnlinked;
      cmbLinkExistingOnlineUser.Clear;
      for index := 0 to high(BloArrayOfUserRead) do
      begin
        cmbLinkExistingOnlineUser.AddItem(BloArrayOfUserRead[index].EMail, BloArrayOfUserRead[index]);
      end;
    end
    else
      aUIMode := uimOnline;
  end;

begin
  // is the user marked as online?
  if chkCanAccessBankLinkOnline.Checked then
  begin
    If fOldValues.CanAccessBankLinkOnline then
    begin
      // Is online user linked to practice user?
      BloUserRead := ProductConfigService.GetOnlineUserLinkedToCode(GetCurrentCode, aPractice);

      if Assigned(BloUserRead) then
      begin
        // Linked
        if Trim(Uppercase(BloUserRead.EMail)) = Trim(Uppercase(eMail.text)) then
          aUIMode := uimOnline
        else
        begin
          // Differant user name to email
          aUIMode := uimOnlineShowUser;
          eOnlineUser.text := BloUserRead.EMail;
        end;
      end
      else
        CheckForUnlinked;
    end
    else
      CheckForUnlinked;
  end
  else
    fUIMode := uimOnline;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.SetUpHelp;
begin
  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;
  //Components
  eUserCode.Hint      :=
                     'Enter a User Code for logging in to '+SHORTAPPNAME+'|' +
                     'Enter a User Code for logging in to '+SHORTAPPNAME;
  eFullName.Hint      :=
                     'Enter the user''s full name|' +
                     'Enter the user''s full name';
  eMail.Hint          :=
                     'Enter the user''s E-mail address|' +
                     'Enter the user''s E-mail address';
  ePass.Hint          :=
                     'Enter a login password|' +
                     'Enter a password that this User must use when logging in. (Required if user has Administrator rights)';
  eConfirmPass.Hint   :=
                     'Confirm the password entered above|' +
                     'Re-enter the password above to confirm it is correct';
  chkMaster.Hint      :=
                     'Check to allow user to memorise transactions at master level|' +
                     'Check to allow user to memorise transactions at master level';
  //chkSystem.Hint      :=
  //                    'Check to give the user Administrator rights|' +
  //                    'Check to give the user Administrator rights';

  cmbUserType.Hint    :=
                     'Select users access rights|' +
                     'Select users access rights';

  chkLoggedIn.hint    :=
                     'Check to alter the user''s login status|' +
                     'Uncheck to reset the user''s status if the user has crashed out of the program';

  CBPrintDialogOption.Hint :=
                      'Always show printer options before printing|' +
                      'Always show printer options before printing';

  CBSuppressHeaderFooter.Hint := 'Check to Hide Headers and Footers on Reports for this User';

  chkShowPracticeLogo.Hint := 'Display the practice logo when this user is logged in';

  chkCanAccessBankLinkOnline.Hint := 'Allows a Banklink User to Access Banklink Online';
end;

//------------------------------------------------------------------------------
Procedure TdlgEditUser.FormShow(Sender: TObject);
begin
  formLoaded := true;
End;

//------------------------------------------------------------------------------
function TdlgEditUser.IsBankLinkOnlineUser: Boolean;
begin
  Result := (UseBankLinkOnline and chkCanAccessBankLinkOnline.Checked);
end;

//------------------------------------------------------------------------------
Procedure TdlgEditUser.btnCancelClick(Sender: TObject);
begin { TdlgEditUser.btnCancelClick }
  okPressed := false;
  Close;
End; { TdlgEditUser.btnCancelClick }

//------------------------------------------------------------------------------
Procedure TdlgEditUser.btnOKClick(Sender: TObject);
begin { TdlgEditUser.btnOKClick }
  If OKtoPost Then
  begin

    if (HasUserValueChanged) and
       ((fOldValues.CanAccessBankLinkOnline = true) or
       (chkCanAccessBankLinkOnline.Checked = true)) then
    begin
      If AskYesNo('User Details Changed', 'The details for this user have changed ' +
                  'and will be updated to BankLink Online.' + #13#10 + #13#10 +
                  'Are you sure you want to continue?', DLG_NO, 0) <> DLG_YES Then
        Exit;
    end;

    if HasUserValueChanged or not UserLoggedInChanged then
    begin
     if not PosttoBankLinkOnline then
       Exit;
    end;
    
    okPressed := true;
    Close;
  End { OKtoPost };
End; { TdlgEditUser.btnOKClick }

//------------------------------------------------------------------------------
procedure TdlgEditUser.StoreOldValues;
begin
  fOldValues.FullName                := eFullName.text;
  fOldValues.Email                   := eMail.text;
  fOldValues.DirectDial              := eDirectDial.Text;
  fOldValues.Password                := ePass.text;
  fOldValues.ShowPrinter             := cbPrintDialogOption.Checked;
  fOldValues.SuppressHeaderFooter    := CBSuppressHeaderFooter.Checked;
  fOldValues.ShowPracticeLogo        := chkShowPracticeLogo.Checked;
  fOldValues.CanAccessBankLinkOnline := chkCanAccessBankLinkOnline.Checked;
  fOldValues.UserType                := cmbUserType.ItemIndex;
end;

//------------------------------------------------------------------------------
function TdlgEditUser.HasUserValueChanged: Boolean;
begin
  Result := not((fOldValues.FullName                = eFullName.text) and
                (fOldValues.Email                   = eMail.text) and
                (fOldValues.DirectDial              = eDirectDial.Text) and
                (fOldValues.Password                = ePass.text) and
                (fOldValues.CanCreateEditMasterMems = chkMaster.Checked) and
                (fOldValues.ShowPrinter             = cbPrintDialogOption.Checked) and
                (fOldValues.SuppressHeaderFooter    = CBSuppressHeaderFooter.Checked) and
                (fOldValues.ShowPracticeLogo        = chkShowPracticeLogo.Checked) and
                (fOldValues.CanAccessBankLinkOnline = chkCanAccessBankLinkOnline.Checked) and
                (fOldValues.UserType                = cmbUserType.ItemIndex));
end;

//------------------------------------------------------------------------------
function TdlgEditUser.GetCurrentCode: string;
begin
  if IsCreateUser then
    Result := eUserCode.text
  else
    Result := stUserName.Caption;
end;

//------------------------------------------------------------------------------
Procedure TdlgEditUser.OnlineControlSetup(aUIMode : TUI_Modes);
begin
  case aUIMode of
    uimBasic :
    Begin
      pnlOnline.Visible := False;
      Self.Height := 458;
    End;
    uimOnline :
    Begin
      pnlOnlineMid.BevelInner := bvNone;
      pnlOnlineMid.BevelOuter := bvNone;
      pnlOnline.Visible := True;
      pnlUnlinked.Visible := False;
      pnlOnlineUser.Visible := False;
      Self.Height := 524;
      chkCanAccessBankLinkOnline.Left := 13;
      chkCanAccessBankLinkOnline.Top  := 10;
    End;
    uimOnlineUnlinked :
    Begin
      pnlOnlineMid.BevelInner := bvLowered;
      pnlOnlineMid.BevelOuter := bvRaised;
      pnlOnline.Visible := True;
      pnlUnlinked.Visible := True;
      pnlOnlineUser.Visible := False;
      Self.Height := 600;
      chkCanAccessBankLinkOnline.Left := 11;
      chkCanAccessBankLinkOnline.Top  := 8;
    End;
    uimOnlineShowUser :
    Begin
      pnlOnlineMid.BevelInner := bvLowered;
      pnlOnlineMid.BevelOuter := bvRaised;
      pnlOnline.Visible := True;
      pnlUnlinked.Visible := False;
      pnlOnlineUser.Visible := True;
      Self.Height := 552;
      chkCanAccessBankLinkOnline.Left := 11;
      chkCanAccessBankLinkOnline.Top  := 8;
    End;
  end;

  if (aUIMode = uimBasic) or (chkCanAccessBankLinkOnline.Checked = false) then
  begin
    lblPasswordValidation.Caption  := '(Maximum 12 characters)'
  end
  else
  begin
    lblPasswordValidation.Caption  := '(8-12 characters, including at least 1 digit)';

    lblPrimaryContact.Visible      := fIsPrimaryUser;
  end;
end;

//------------------------------------------------------------------------------
Function TdlgEditUser.OKtoPost : boolean;
Var
  URec : pUser_Rec;
begin { TdlgEditUser.OKtoPost }
  Result := false;

  if eUserCode.visible Then
  begin
    if (Trim(eUserCode.text) = '') Then
    begin
      HelpfulWarningMsg('You must enter a user code.', 0);
      pcMain.ActivePage := tsDetails;
      eUserCode.SetFocus;
      exit;
    End; { (Trim(eUserCode.text) = '') };

    {check for duplicate login name}
    URec := AdminSystem.fdSystem_User_List.FindCode(eUserCode.text);
    If Assigned(URec) or (eUserCode.text = SUPERUSER) Then
    begin
      HelpfulWarningMsg( Format( 'The user code "%s" already exists.  Please use a different code.', [ eUserCode.Text ] ), 0 );
      pcMain.ActivePage := tsDetails;
      eUserCode.SetFocus;
      exit;
    End; { Assigned(URec) or (eUserCode.text = SUPERUSER) };
  End; { eUserCode.visible };

  if IsBankLinkOnlineUser then
  begin
    if (Trim(eFullName.text) = '') Then
    begin
      HelpfulWarningMsg('BankLink Online users must have a User Name.', 0);
      pcMain.ActivePage := tsDetails;
      eFullName.SetFocus;
      exit;
    end; { (Trim(eUserName.text) = '') };

    If not RegExIsEmailValid(eMail.text) Then
    begin
      HelpfulWarningMsg('BankLink Online users must have a valid Email Address.', 0 );
      pcMain.ActivePage := tsDetails;
      eMail.SetFocus;
      exit;
    end; { ValidEmail(eMail.text) }

    if (Trim(ePass.text) = '') then
    begin
      HelpfulWarningMsg('BankLink Online users must have a Password.', 0 );
      pcMain.ActivePage := tsDetails;
      ePass.SetFocus;
      exit;
    end; { (Trim(ePass.text) = '') }

    if (ePass.text <> eConfirmPass.text) then
    begin
      HelpfulWarningMsg('BankLink Online users Password and Confirm Password must be the same.', 0 );
      pcMain.ActivePage := tsDetails;
      ePass.SetFocus;
      exit;
    end; { (ePass.text <> eConfirmPass.text) }

    if not RegExIsPasswordValid(ePass.text) then
    begin
      HelpfulWarningMsg('BankLink Online users must have a Password that contains 8-12 characters, including atleast 1 digit.', 0 );
      pcMain.ActivePage := tsDetails;
      ePass.SetFocus;
      exit;
    end; { ValidPassword }

    if (radLinkExistingOnlineUser.Checked) and
       (cmbLinkExistingOnlineUser.ItemIndex = -1) and
       (fUIMode = uimOnlineUnlinked) then
    begin
      HelpfulWarningMsg('An existing user on BankLink Online must be selected.', 0 );
      pcMain.ActivePage := tsDetails;
      cmbLinkExistingOnlineUser.SetFocus;
      exit;
    end;
  end  { IsBankLinkOnlineUser }
  else
  begin
    if AdminSystem.fdFields.fdCountry = whUK then
    begin
    //All UK users must have a password TFS 19605
      if (ePass.Text = '') then
      begin
        HelpfulWarningMsg('Users must have a password.', 0);
        pcMain.ActivePage := tsDetails;
        ePass.SetFocus;
        exit;
      end;
    end;

    if not (ePass.text = eConfirmPass.text) Then
    begin
      HelpfulWarningMsg('The passwords you have entered do not match. Please re-enter them.', 0);
      pcMain.ActivePage := tsDetails;
      ePass.SetFocus;
      exit;
    end; { not (ePass.text = eConfirmPass.text) };
  end;

  case cmbUserType.ItemIndex of
    ustRestricted :
      begin
        if (rbSelectedFiles.Checked) and (lvFiles.Items.Count = 0) then
        begin
          HelpfulWarningMsg('Users with Restricted Access MUST be allowed to access at least one file.', 0);
          pcMain.ActivePage := tsFiles;
          btnAdd.SetFocus;
          Exit;
        end;
      end;
    ustNormal :
      begin
        if (rbSelectedFiles.Checked) and (lvFiles.Items.Count = 0) then
        begin
          HelpfulWarningMsg('Users with Normal Access MUST be allowed to access at least one file.', 0);
          pcMain.ActivePage := tsFiles;
          btnAdd.SetFocus;
          Exit;
        end;
      end;
    ustSystem :
      begin
        if (ePass.Text = '') then
        begin
          HelpfulWarningMsg('Users with System Menu Access MUST have a password.', 0);
          pcMain.ActivePage := tsDetails;
          ePass.SetFocus;
          exit;
        end;
      end;
  end;

  Result := true;
End; { TdlgEditUser.OKtoPost }

//------------------------------------------------------------------------------
Function TdlgEditUser.PosttoBankLinkOnline : Boolean;
var
  RoleNames         : TBloArrayOfstring;
  MsgCreateorUpdate : string;
  UserCode          : string;
  UserEmail         : String;
  BloUserRead       : TBloUserRead;
begin
  Result := True;

  UserCode := GetCurrentCode;

  // if User was on Banklink Online and now is removed delete user on Banklink online
  Try
    if  (fOldValues.CanAccessBankLinkOnline = True)
    and (chkCanAccessBankLinkOnline.Checked = False) then
    begin
      if UserGuid = '' then
        Result := ProductConfigService.DeletePracUser(UserCode, '')
      else
      begin
        // if user is the primary user and been deleted pick a new primary user
        if fIsPrimaryUser then
        begin
          Result := PickPrimaryUser(puaDelete, UserCode);
          if not Result then
            Exit;
        end;

        Result := ProductConfigService.DeletePracUser('', UserGuid);
      end;

      if Result then
        HelpfulInfoMsg(Format('%s has been successfully deleted from BankLink Online.', [eFullName.Text]), 0 )
      else
        HelpfulInfoMsg('BankLink Practice was unable to remove this user from BankLink Online', 0);
    end;

    if  (chkCanAccessBankLinkOnline.Checked)
    and (chkCanAccessBankLinkOnline.Visible) then
    begin
      // if user is the primary user and been set to a non supervisor then pick a new primary user
      if (fIsPrimaryUser) and
         (cmbUserType.ItemIndex in [ustRestricted, ustNormal]) then
      begin
        Result := PickPrimaryUser(puaRoleChange, UserCode);
        if not Result then
          Exit;
      end;

      // Check if the the user is unlinked and a user from the list is being picked
      if (fUIMode = uimOnlineUnlinked) and
         (radLinkExistingOnlineUser.Checked) and
         (cmbLinkExistingOnlineUser.ItemIndex > -1) then
      begin
        BloUserRead := TBloUserRead(cmbLinkExistingOnlineUser.Items.Objects[cmbLinkExistingOnlineUser.ItemIndex]);

        if assigned(BloUserRead) then
        begin
          UserEmail := BloUserRead.EMail;
          fUserGuid := BloUserRead.Id;
        end;
      end
      else
        UserEmail := eMail.Text;

      Result := ProductConfigService.AddEditPracUser(fUserGuid,
                                                     UserEmail,
                                                     eFullName.Text,
                                                     GetCurrentCode,
                                                     cmbUserType.ItemIndex,
                                                     fIsCreateUser,
                                                     true,
                                                     fOldValues.Password,
                                                     ePass.Text);

      if Result then
      begin
        if IsCreateUser then
          MsgCreateorUpdate := 'created on'
        else
          MsgCreateorUpdate := 'updated to';

        HelpfulInfoMsg(Format('%s has been successfully %s BankLink Online.', [eFullName.Text, MsgCreateorUpdate]), 0 );
      end
      else
      begin
        if fIsCreateUser then
          HelpfulInfoMsg(Format('BankLink Practice was unable to create %s on BankLink Online', [eFullName.Text]), 0)
        else
          HelpfulInfoMsg(Format('BankLink Practice was unable to update %s on BankLink Online', [eFullName.Text]), 0);
      end;
    end;
  Except
    on E : Exception do
    begin
      HelpfulErrorMsg(E.Message, 0);
      Result := False;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.chkCanAccessBankLinkOnlineClick(Sender: TObject);
var
  MsgCreateorUpdate : String;
  MsgAddorUpdate    : String;
  Practice          : TBloPracticeRead;
begin
  If formLoaded Then
  begin
    If (not chkCanAccessBankLinkOnline.Checked)
    and (fOldValues.CanAccessBankLinkOnline) then
    begin
      If AskYesNo('Deleted BankLink User', 'This user will be Deleted on BankLink Online.' + #13
                + 'Are you sure you want to continue?', DLG_NO, 0) <>
        DLG_YES Then
      begin
        chkCanAccessBankLinkOnline.Checked := Not chkCanAccessBankLinkOnline.Checked;
      End;
    end
    else If (chkCanAccessBankLinkOnline.Checked)
        and not (fOldValues.CanAccessBankLinkOnline) then
    begin
      if IsCreateUser then
      begin
        MsgCreateorUpdate := 'created on';
        MsgAddorUpdate := 'Add'
      end
      else
      begin
        MsgCreateorUpdate := 'updated to';
        MsgAddorUpdate := 'Update'
      end;

      If AskYesNo(MsgAddorUpdate + ' BankLink User', 'This user will be ' + MsgCreateorUpdate + ' BankLink Online.' + #13
                + 'Are you sure you want to do this?', DLG_NO, 0) <>
        DLG_YES Then
      begin
        chkCanAccessBankLinkOnline.Checked := Not chkCanAccessBankLinkOnline.Checked;
      end;
    End;

    Practice := ProductConfigService.GetPractice;
    SetOnlineUIMode(fUIMode, Practice);
    OnlineControlSetup(fUIMode);
  End; { formLoaded };
end;

//------------------------------------------------------------------------------
Procedure TdlgEditUser.chkLoggedInClick(Sender: TObject);
begin { TdlgEditUser.chkLoggedInClick }
  If formLoaded Then
  begin
    If EditChk Then
    begin
      exit;
    End; {already editing}

    If AskYesNo('Reset User Status', 'This will reset the User''s login status and reset the Client File '
       + 'open status for any files the user had open.  You should only do this '
       + 'if the user has been unexpectedly disconnected from ' + SHORTAPPNAME+'.'
       + #13 + #13 + 'Please confirm you want to do this.', DLG_NO, 0) <>
       DLG_YES Then
    begin
      EditChk := true;
      chkLoggedIn.Checked := not chkLoggedIn.Checked;
      EditChk := false;
    End
       { AskYesNo('Reset User Status', 'This will reset the Users login status and reset the Client File '  };
  End { formLoaded };
End;

{ TdlgEditUser.chkLoggedInClick }

//------------------------------------------------------------------------------
Procedure TdlgEditUser.UpdateAdminFileAccessList( UserLRN : integer);
var
  CLRN : integer;
  i    : integer;
begin
  //Clear out the existing information, this will allow access to all files
  AdminSystem.fdSystem_File_Access_List.Delete_User( UserLRN );

  //set access if selected files checked
  if rbSelectedFiles.Checked then
  begin
    if lvFiles.Items.Count = 0 then
    begin
      //create a dummy client LRN so that file access will be denied
      AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( UserLRN, 0 )
    end
    else
    begin
      for i := 0 to Pred( lvFiles.Items.Count ) do
      begin
        CLRN := Integer( lvFiles.Items[ i].SubItems.Objects[ 0]);
        AdminSystem.fdSystem_File_Access_List.Insert_Access_Rec( UserLRN, CLRN );
      end;
    end;
  end;
end;

function TdlgEditUser.UserLoggedInChanged: Boolean;
begin
  if FIsLoggedIn then
  begin
    Result := FIsLoggedIn <> chkLoggedIn.Checked;
  end
  else
  begin
    Result := False;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.btnRemoveAllClick(Sender: TObject);
begin
  lvFiles.Items.Clear;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.btnAddClick(Sender: TObject);
Var
  Codes  : TStringList;
  pCF    : pClient_File_Rec;
  Found  : Boolean;
  i, j   : Integer;
  NewLVItem : TListItem;
begin
  Codes := TStringList.Create;
  try
    Codes.Delimiter := ClientCodeDelimiter;
    Codes.StrictDelimiter := True;
    //ask the user for a list of codes, will reload admin system
    Codes.DelimitedText :=
      LookupClientCodes( 'Select Files',
                         '',
                         [ coHideStatusColumn, coHideViewButtons, coAllowMultiSelected, coShowAssignedToColumn],
                         'Add');

    for i := 0 to Codes.Count - 1 do
    begin
      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( Codes[i] );
      if Assigned( pCF ) then
      begin
        Found := False;
        //check that is not already in the list
        for j := 0 to Pred( lvFiles.Items.Count ) do
          If Integer( lvFiles.Items[ j].SubItems.Objects[ 0]) = pCF.cfLRN then
            Found := True;

        if not Found then
        begin
           NewLVItem := lvFiles.Items.Add;
           NewLVItem.caption := pCF^.cfFile_Code;
           NewLVItem.SubItems.AddObject( pCF^.cfFile_Name, Pointer( pCF^.cfLRN ));
           NewLVItem.ImageIndex := 0;
        end;
      end;
    end;
  finally
    Codes.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.btnRemoveClick(Sender: TObject);
Var
  i : Integer;
begin
  If lvFiles.SelCount > 0 then
  begin
    For i := Pred( lvFiles.Items.Count ) downto 0 do
    begin
      If lvFiles.Items[ i].Selected then
         lvFiles.Items[ i].Delete;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.radCreateNewOnlineUserClick(Sender: TObject);
begin
  cmbLinkExistingOnlineUser.enabled := false;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.radLinkExistingOnlineUserClick(Sender: TObject);
begin
  cmbLinkExistingOnlineUser.enabled := true;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.rbAllFilesClick(Sender: TObject);
begin
  pnlSelected.Visible := rbSelectedFiles.Checked;
end;

//------------------------------------------------------------------------------
procedure TdlgEditUser.rbSelectedFilesClick(Sender: TObject);
begin
  pnlSelected.Visible := rbSelectedFiles.Checked;
end;

//------------------------------------------------------------------------------
// cmbUserTypeSelect
//
// Triggered when the User Type combobox is changed. The caption next to the
// combobox is updated and the various controls on the form are set.
//
procedure TdlgEditUser.cmbUserTypeSelect(Sender: TObject);
begin
  case TComboBox(Sender).ItemIndex of
    ustRestricted :
      begin
        lblUserType.Caption := 'Limited functionality : Access to selected files only';
        chkMaster.Checked := False;
        chkMaster.Enabled := False;
        rbAllFiles.Checked := False;
        rbAllFiles.Enabled := False;
        rbSelectedFiles.Checked := True;
        rbSelectedFiles.Enabled := True;
        chkShowPracticeLogo.Enabled := True;
      end;
    ustNormal :
      begin
        lblUserType.Caption := 'Standard functionality : Access to all or selected files';
        chkMaster.Enabled := True;
        rbAllFiles.Checked := True;
        rbAllFiles.Enabled := True;
        rbSelectedFiles.Checked := False;
        rbSelectedFiles.Enabled := True;
        chkShowPracticeLogo.Enabled := False;
        chkShowPracticeLogo.Checked := False;
      end;
    ustSystem :
      begin
        lblUserType.Caption := 'Administrator rights : Access to all files';
        chkMaster.Enabled := True;
        rbAllFiles.Checked := True;
        rbAllFiles.Enabled := True;
        rbSelectedFiles.Checked := False;
        rbSelectedFiles.Enabled := False;
        chkShowPracticeLogo.Enabled := False;
        chkShowPracticeLogo.Checked := False;
      end;
  else
    lblUserType.Caption := '';
  end;
end;

//------------------------------------------------------------------------------
Function TdlgEditUser.Execute( User: pUser_Rec ) : boolean;
Const
  ACCESS_ONLINE_CHK_HEIGHT = 30;
Var
  i : Integer;
  NewLVItem : TListItem;
  Practice : TBloPracticeRead;
  pCF : pClient_File_Rec;
begin { TdlgEditUser.Execute }
  FIsLoggedIn := False;
  
  lvFiles.Items.Clear;

  if (UseBankLinkOnline or
      (Assigned(User) and User.usAllow_Banklink_Online)) then
    Practice := ProductConfigService.GetPractice(true);

  if Assigned(User) then
  begin
    FIsLoggedIn := User.usLogged_In;
    
    //user type
    if (User.usSystem_Access) then
      cmbUserType.ItemIndex := ustSystem
    else if (User.usIs_Remote_User) then
      cmbUserType.ItemIndex := ustRestricted
    else
      cmbUserType.ItemIndex := ustNormal;

    cmbUserTypeSelect(cmbUserType);

    //see if user is restricted
    if AdminSystem.fdSystem_File_Access_List.Restricted_User( User^.usLRN) then
    begin
      rbSelectedFiles.Checked := true;

      //load selected files into list view
      lvFiles.Items.BeginUpdate;
      try
        For i := 0 to AdminSystem.fdSystem_Client_File_List.ItemCount-1 do
        begin
          pCF := AdminSystem.fdSystem_Client_File_List.Client_File_At( i );

          If AdminSystem.fdSystem_File_Access_List.Allow_Access( User^.usLRN, pCF^.cfLRN ) then
          begin
            NewLVItem := lvFiles.Items.Add;
            NewLVItem.caption := pCF^.cfFile_Code;
            NewLVItem.SubItems.AddObject( pCF^.cfFile_Name, Pointer( pCF^.cfLRN ));
            NewLVItem.ImageIndex := 0;
          end;
        end;
      finally
        lvFiles.Items.EndUpdate;
      end;
    end
    else
      rbAllFiles.Checked := true;

    eUserCode.Visible  := false;
    stUserName.Caption := User.usCode;
    eFullName.Text     := User.usName;
    eMail.Text         := User.usEMail_Address;
    eDirectDial.Text   := User.usDirect_Dial;
    ePass.Text         := User.usPassword;
    eConfirmPass.Text  := User.usPassword;
    chkLoggedIn.Checked := User.usLogged_In;
    cbPrintDialogOption.Checked := User.usShow_Printer_Choice;
    cbSuppressHeaderFooter.Checked := (User.usSuppress_HF = shfChecked);
    chkShowPracticeLogo.Checked := User.usShow_Practice_Logo;
    chkCanAccessBankLinkOnline.Checked := User.usAllow_Banklink_Online;

    if User.usAllow_Banklink_Online then
    begin
      Screen.Cursor := crHourGlass;
      Progress.StatusSilent := False;
      Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Connecting', 10);

      try
        if ProductConfigService.Online then
        begin
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Sending Data to ' + BANKLINK_ONLINE_NAME, 50);
          UserGuid := ProductConfigService.GetPracUserGuid(User.usCode, Practice);
          fIsPrimaryUser := ProductConfigService.IsPrimPracUser(User.usCode, Practice);
          Progress.UpdateAppStatus(BANKLINK_ONLINE_NAME, 'Finnished', 100);
        end
        else
        begin
          UserGuid := '';
          fIsPrimaryUser := False;
        end;
      finally
        Progress.StatusSilent := True;
        Progress.ClearStatus;
        Screen.Cursor := crDefault;
      end;
    end
    else
    begin
      UserGuid := '';
      fIsPrimaryUser := False;
    end;

    if User.usWorkstation_Logged_In_At <> '' then
      chkLoggedIn.Caption := 'User is &Logged In  (on ' + User.usWorkstation_Logged_In_At +')';

    chkMaster.Checked     := User.usMASTER_Access;
  end { Assigned(User) }
  else
  begin
    {new user}
    stUserName.visible := false;
    eUserCode.text := '';
    eFullName.text := '';
    eMail.text := '';
    ePass.text := '';
    eDirectDial.Text := '';
    eConfirmPass.text := '';
    cmbUserType.ItemIndex := ustNormal;
    cmbUserTypeSelect(cmbUserType);
    chkLoggedIn.Checked := false;
    chkLoggedIn.Enabled := false;
    chkMaster.Checked := false;
    cbPrintDialogOption.Checked := false;
    cbSuppressHeaderFooter.Checked := false;
    rbAllFiles.Checked := true;
    chkCanAccessBankLinkOnline.Checked := false;
    UserGuid := '';
  end { not (Assigned(User)) };

  StoreOldValues;

  // Checks what User View to show
  // is the view online?
  if (UseBankLinkOnline or chkCanAccessBankLinkOnline.Checked) then
    SetOnlineUIMode(fUIMode, Practice)
  else
    fUIMode := uimBasic;

  OnlineControlSetup(fUIMode);

  pnlSelected.Visible := rbSelectedFiles.Checked;
  rbAllFiles.Enabled := (cmbUserType.ItemIndex <> ustRestricted);

  EditChk := false;
  ShowModal;
  Result := okPressed;
End; { TdlgEditUser.Execute }

//------------------------------------------------------------------------------
Function EditUser(w_PopupParent: TForm; User_Code: String) : boolean;
const
  ThisMethodName = 'EditUser';
Var
  MyDlg       : TdlgEditUser;
  eUser       : pUser_Rec;
  StoredLRN   : Integer;
  StoredName  : string;
  YN          : string;
  pu          : pUser_Rec;
  WasLoggedIn : boolean;
  i           : integer;
  Prac        : TBloPracticeRead;
begin { EditUser }
  Result := false;

  eUser := AdminSystem.fdSystem_User_List.FindCode(User_Code);

  If not (Assigned(AdminSystem) and Assigned(eUser)) Then
    exit;

  MyDlg := TdlgEditUser.Create(Application);
  Try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode := pmExplicit;
    
    MyDlg.IsCreateUser := False;

    BKHelpSetUp(MyDlg, BKH_Adding_and_maintaining_users);
    if Assigned(CurrUser) Then
    begin
      if (CurrUser.LRN = eUser.usLRN) or (not eUser.usLogged_In) then
      begin
        MyDlg.chkLoggedIn.Enabled   := false;
        MyDlg.cmbUserType.ItemIndex := ustNormal;
      end; { CurrUser.LRN = eUser.usLRN }
    end;
    WasLoggedIn := eUser^.usLogged_In;
    
    If MyDlg.Execute(eUser) Then
    begin
      //get the user_rec again as the admin system may have changed in the mean time.
      eUser := AdminSystem.fdSystem_User_List.FindCode(User_Code);
      With MyDlg Do
      begin
        StoredLRN := eUser.usLRN; {user pointer about to be destroyed}
        StoredName := eUser.usCode;

        If LoadAdminSystem(true, ThisMethodName ) Then
        begin
          pu := AdminSystem.fdSystem_User_List.FindLRN(StoredLRN);
          If not Assigned(pu) Then
          begin
            UnlockAdmin;
            HelpfulErrorMsg('The User ' + StoredName + ' can no longer be found in the Admin System.', 0);
            exit;
          End;

          pu.usName           := eFullName.text;
          pu.usPassword       := ePass.text;
          pu.usEMail_Address  := Trim( eMail.text);
          pu.usDirect_Dial    := eDirectDial.Text;
          pu.usShow_Printer_Choice := cbPrintDialogOption.Checked;

          if CBSuppressHeaderFooter.Checked then
            pu.usSuppress_HF := shfChecked
          else
            pu.usSuppress_HF := shfUnChecked;

          pu.usShow_Practice_Logo := chkShowPracticeLogo.Checked;
          pu.usAllow_Banklink_Online := chkCanAccessBankLinkOnline.Checked;

          case cmbUserType.ItemIndex of
            ustRestricted :
              begin
                pu.usSystem_Access  := False;
                pu.usIs_Remote_User := True;
              end;
            ustSystem :
              begin
                pu.usSystem_Access  := True;
                pu.usIs_Remote_User := False;
              end;
            ustNormal :
              begin
                pu.usSystem_Access  := False;
                pu.usIs_Remote_User := False;
              end;
            else
              begin
                pu.usSystem_Access  := False;
                pu.usIs_Remote_User := False;
              end;
          end;

          pu.usMASTER_Access  := chkMaster.Checked;
//          pu.usBankLink_Online_Guid := UserGuid;

          If pu.usLogged_In <> chkLoggedIn.Checked Then
          begin
            If chkLoggedIn.Checked Then
              YN := 'YES'
            Else
              YN := 'NO';

            LogUtil.LogMsg(lmInfo, UNITNAME,
                          'User ' + StoredName + ' Logged In reset to ' + YN);
            pu.usLogged_In := chkLoggedIn.Checked;

            //have changed to not logged in ( logged out). ie reset user status, so now reset any open files
            If (not (chkLoggedIn.Checked) and WasLoggedIn) Then
            begin
              //clear the workstation identifier
              pu.usWorkstation_Logged_In_At := '';
              With AdminSystem.fdSystem_Client_File_List Do
              begin
                For i := 0 to Pred(ItemCount) Do
                begin
                  With Client_File_At(i)^ Do
                  begin
                    If (cfFile_Status = fsOpen) and (cfCurrent_User = pu^.usLRN) Then
                    begin
                      //reset the file status for files that this user may have open
                      cfFile_Status := fsNormal;
                      cfCurrent_User := 0;
                    End;
                  End;
                End;
              End;
            End;
          End;

          UpdateAdminFileAccessList( pu^.usLRN);

          //*** Flag Audit ***
          SystemAuditMgr.FlagAudit(arUsers);

          SaveAdminSystem;
          Result := true;

          LogUtil.LogMsg(lmInfo, UNITNAME,
                         Format('User %s was edited by %s.', [pu^.usName, CurrUser.FullName]));

          If Assigned(CurrUser) Then
          begin
            If CurrUser.LRN = pu.usLRN Then
            begin
              CurrUser.CanMemoriseToMaster := pu.usMASTER_Access;
              CurrUser.FullName := pu.usName;
              CurrUser.ShowPrinterDialog := pu.usShow_Printer_Choice;
              CurrUser.AllowBanklinkOnline := pu.usAllow_Banklink_Online;
            End; { CurrUser.LRN = pu.usLRN }
          End;
        End { LoadAdminSystem(true) }
        Else
        begin
          HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
        End;
      End; { with MyDlg }
    End;
  Finally
    MyDlg.Free;
  End; { try };
End; { EditUser }

//------------------------------------------------------------------------------
Function AddUser(w_PopupParent: TForm) : boolean;
const
  ThisMethodName = 'AddUser';
Var
  MyDlg : TdlgEditUser;
  pu    : pUser_Rec;
begin { AddUser }
  Result := false;
  If not Assigned(AdminSystem) Then
    exit;

  MyDlg := TdlgEditUser.Create(Application);
  Try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode := pmExplicit;
    
    MyDlg.IsCreateUser := True;
    BKHelpSetUp(MyDlg, BKH_Adding_and_maintaining_users);
    If MyDlg.Execute(Nil) Then
    begin
      With MyDlg Do
      begin
        If LoadAdminSystem(true, ThisMethodName ) Then
        begin
          pu := New_User_Rec;

          if not Assigned(pu) Then
          begin
            UnlockAdmin;
            HelpfulErrorMsg('New User cannot be created', 0);
            exit;
          end { not Assigned(pu) };

          Inc(AdminSystem.fdFields.fdUser_LRN_Counter);
          pu.usCode           := eUserCode.text;
          pu.usName           := eFullName.text;
          pu.usPassword       := ePass.text;
          pu.usEMail_Address  := Trim( eMail.text);
          pu.usDirect_Dial    := eDirectDial.Text;
          pu.usShow_Printer_Choice := cbPrintDialogOption.Checked;
          if CBSuppressHeaderFooter.Checked then
            pu.usSuppress_HF := shfChecked
          else
            pu.usSuppress_HF := shfUnChecked;

          pu.usShow_Practice_Logo := chkShowPracticeLogo.Checked;
          pu.usAllow_Banklink_Online := chkCanAccessBankLinkOnline.Checked;

          case cmbUserType.ItemIndex of
           ustRestricted :
             begin
               pu.usSystem_Access  := False;
               pu.usIs_Remote_User := True;
             end;
           ustSystem :
             begin
               pu.usSystem_Access  := True;
               pu.usIs_Remote_User := False;
             end;
           ustNormal :
             begin
               pu.usSystem_Access  := False;
               pu.usIs_Remote_User := False;
             end;
           else
             begin
               pu.usSystem_Access  := False;
               pu.usIs_Remote_User := False;
             end;
          end;

          pu.usMASTER_Access  := chkMaster.Checked;
          pu.usLogged_In      := false;
          pu.usLRN            := AdminSystem.fdFields.fdUser_LRN_Counter;
          //               pu.usBankLink_Online_Guid := UserGuid;

          AdminSystem.fdSystem_User_List.Insert( pu );

          UpdateAdminFileAccessList( pu^.usLRN);

          //*** Flag Audit ***
          SystemAuditMgr.FlagAudit(arUsers);

          SaveAdminSystem;
          Result := true;

          LogUtil.LogMsg(lmInfo, UNITNAME,
                        Format('User %s was added by %s.', [pu^.usName, CurrUser.FullName]));
        End { LoadAdminSystem(true) }
        Else
        begin
           HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.', 0)
        End;
      End; { with MyDlg }
    End;
  Finally
    MyDlg.Free;
  End; { try };
End; { AddUser }

End.
