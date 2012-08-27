unit login32;
//------------------------------------------------------------------------------
// handles the user logging into app
//
//  Login will be done automatically if possible using the current
//  windows user name.  This can only occur if the password is blank.
//
//  If the username and password combination can be validated
//  then a current user global object will be created CURRUSER.
//
//  The Admin system will be notified that the user has logged in.
//
//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, sydefs, pwdSeed, Mask, jpeg,osFont;

type
  TfrmLogin = class(TForm)
    pnlBackground: TPanel;
    pnlLogin: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    lblSeed: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    pnlImageBorder: TPanel;
    imgLoginBanner: TImage;
    eUsername: TEdit;
    ePassword: TEdit;
    pnlStandardLogin: TPanel;
    Image1: TImage;
    lblVersion: TLabel;
    lblCustomVersion: TLabel;
    Shape1: TShape;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure eUserNameChange(Sender: TObject);
    procedure eUserNameEnter(Sender: TObject);
    procedure eUserNameKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    okPressed : boolean;
    User      : pUser_Rec;
    Tries     : integer;
    SuperPwd  : string;
    FPassword: String;

    function Login(uName, pass: String; out Cancelled: Boolean): Boolean;
    class procedure UpdateLocalSecurePassword(UserCode: String; const Password: String);
    
    function ValidateUser(uName : string; pass : string) : boolean;
    procedure WMQueryEndSession(var Msg : TWMQueryEndSession); message WM_QueryEndSession;
    procedure WMEndSession(var Msg : TWMEndSession); message WM_ENDSESSION;
  public
    { Public declarations }
    function Execute : boolean;

    class function LoginOnline(User: TUser_Rec; uName: String; var CurrentPassword: String; out Cancelled, ConnectionError: Boolean): Boolean; overload;
    class function LoginOnline(UserCode, uName, pass: String; out Cancelled, ConnectionError: Boolean): Boolean; overload;

    property Password: String read FPassword;
  end;

function LoginUser(TryUserName : string): boolean;
function LogoutUser : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  MadUtils,
  admin32,
  bkXPThemes,
  globals,
  imagesfrm,
  ErrorMoreFrm,
  ErrorLog,
  LogUtil,
  WinUtils,
  PrintMgrObj,
  AppUserObj,
  INISettings,
  WarningMoreFrm,
  GlobalCache,
  YesNoDlg,
  bkconst,
  LicenseDlg, ClientManagerFrm,
  BanklinkOnlineServices,
  EditUserPassword;

const
  UnitName = 'LOGIN32';

var
  DebugMe : boolean = false;


// Do a tidy close if windows is shutting down

procedure TfrmLogin.WMQueryEndSession(var Msg : TWMQueryEndSession);
begin
   LogUtil.LogMsg(lmInfo, UnitName, 'Windows is shutting down while on login screen');
   Globals.ApplicationIsTerminating := True;
   btnCancel.Click;
   Msg.Result := 1;
end;

procedure TfrmLogin.WMEndSession(var Msg : TWMEndSession);
begin
  inherited;
end; 

//------------------------------------------------------------------------------
procedure TfrmLogin.FormCreate(Sender: TObject);
const
  MaxPictureWidth = 550;
  MaxPictureHeight= 275;
var
  newWidth : integer;
  newHeight : integer;

  AspectRatio : double;
begin
  bkXPThemes.ThemeForm( Self);
  lblVersion.Font.Name := Font.Name;
  Caption := SHORTAPPNAME + ' Login';
  lblVersion.Caption := ShortAppname + ' ' + WINUTILS.GetAppYearVersionStr;
  lblCustomVersion.Caption := lblVersion.Caption;
  SetPasswordFont(ePassword);


  SuperPwd := '';
  SetUpHelp;

  if not AppImages.CustomLoginBitmapLoaded then
  begin
    pnlStandardLogin.Visible := true;
    pnlImageBorder.Visible := false;

    image1.Picture := AppImages.imgLogin.Picture;
  end
  else
  begin
    //Self.BorderStyle := bsSingle;

    pnlStandardLogin.Visible := false;
    //now position graphic, may be custom graphic defined by user
    //so make sure size is correct
    imgLoginBanner.Picture     := AppImages.imgCustomLogin.Picture;
    imgLoginBanner.Width       := AppImages.imgCustomLogin.Width;
    imgLoginBanner.Height      := AppImages.imgCustomLogin.Height;

    //calculate aspect ratio
    if imgLoginBanner.Height > 0 then
      AspectRatio := imgLoginBanner.Width / imgLoginBanner.Height
    else
      AspectRatio := 1.0;

    if AspectRatio <= 0 then
      AspectRatio := 1.0;
                                                   
    //make sure not bigger than max
    if ( imgLoginBanner.Width > MaxPictureWidth) or ( imgLoginBanner.Height > MaxPictureHeight) then
    begin
      if AspectRatio >= ( MaxPictureWidth / MaxPictureHeight) then
      begin
        //scale width, then adjust height
        imgLoginBanner.Width    := MaxPictureWidth;
        imgLoginBanner.Height   := Round( imgLoginBanner.Width / AspectRatio);

        imgLoginBanner.AutoSize := False;
        imgLoginBanner.Stretch  := True;
      end
      else
      begin
        //scale height, then adjust width
        imgLoginBanner.Height   := MaxPictureHeight;
        imgLoginBanner.Width    := Round( imgLoginBanner.Height * AspectRatio);

        imgLoginBanner.AutoSize := False;
        imgLoginBanner.Stretch  := True;
      end;
    end;
    imgLoginBanner.Top         := 4;
    imgLoginBanner.Left        := 5;

    //resize panel
    pnlImageBorder.Width       := imgLoginBanner.Width  + 10;
    pnlImageBorder.Height      := imgLoginBanner.Height + 10;

    //calculate new height for form
    newWidth  := pnlImageBorder.Width + 20;
    newHeight := pnlImageBorder.Height + 20 + pnlLogin.Height;

    if NewWidth < 450 then
      NewWidth := 450;

    if NewHeight < 125 then
      NewHeight := 125;

    Self.ClientWidth := NewWidth;
    Self.ClientHeight := NewHeight;

    //center the picture panel
    pnlImageBorder.Top         := 5;
    pnlImageBorder.Left        := (( Self.Width - pnlImageBorder.Width) div 2);
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmLogin.FormShow(Sender: TObject);
begin
   caption := SHORTAPPNAME+' Login';

   if Assigned(Adminsystem) then
   begin
     caption := AdminSystem.fdFields.fdPractice_Name_for_Reports+' '+SHORTAPPNAME+' Login';
   end;

   if eUserName.text <> '' then
     ePassword.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TfrmLogin.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   eUserName.Hint   :=
                    'Enter your '+SHORTAPPNAME+' User Code|' +
                    'Enter your User Code for logging in to '+SHORTAPPNAME;
   ePassword.Hint   :=
                    'Enter your '+SHORTAPPNAME+' Password|' +
                    'Enter the password for your User Code';
end;

class procedure TfrmLogin.UpdateLocalSecurePassword(UserCode: String; const Password: String);
var
  User: pUser_Rec;
begin
  if LockAdmin('LoginOnline') then
  begin
    try
      User := AdminSystem.fdSystem_User_List.FindCode(UserCode);

      if Assigned(User) then
      begin
        UpdateUserDataBlock(User, Password);
      end;

      SaveAdminSystem;
    except
      UnlockAdmin;

      raise;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmLogin.btnOKClick(Sender: TObject);
var
   S : String;
   pwd : string;
begin
  //only take the first 8 char of the password as this is the length that
  //is stored, however we don't want to advertise the max no of characters
  //ST:but must still validate against whole entered string! #3679
//  pwd := Copy( ePassword.text, 1, 8);
  pwd := ePassword.text;

  if ValidateUser(eUsername.Text, pwd) then
  begin
    okPressed := true;
    close;
  end
  else begin
    LogUtil.LogMsg(lmInfo,UnitName,'Bad User Login ('+inttostr(Tries)+') USER='+eUserName.Text);
    ePassword.SetFocus;
    ePassword.SelectAll;
  end;

  if Tries >= MAXLOGINATTEMPTS then
  begin
    okPressed := false;
    S := Format( 'You have not entered a correct UserName/Password after %d tries.'+#13+#13+
                 'Please contact your '+SHORTAPPNAME+' Administrator.',
                 [ MAXLOGINATTEMPTS ] );
    HelpfulErrorMsg( S, 0 );
    close;
  end;
end;

function TfrmLogin.Login(uName, pass: String; out Cancelled: Boolean): Boolean;
var
  ConnectionError: Boolean;
begin
  Result := False;

  Cancelled := False;

  FPassword := pass;
  
  if User.usAllow_Banklink_Online and Adminsystem.fdFields.fdUse_BankLink_Online then
  begin
    if LoginOnline(User^, uName, FPassword, Cancelled, ConnectionError) then
    begin
      Result := True;
    end
    else
    begin
      if ConnectionError then
      begin
        Result := ValidateUserPassword(User^, FPassword);
      end;
    end;

    User := AdminSystem.fdSystem_User_List.FindCode(uName);
  end
  else
  begin
    Result := ValidateUserPassword(User^, FPassword);
  end;
end;

class function TfrmLogin.LoginOnline(UserCode, uName, pass: String; out Cancelled, ConnectionError: Boolean): Boolean;
var
  User: pUser_Rec;
begin
  Result := False;
  Cancelled := False;
  ConnectionError := False;
  
  if Assigned(AdminSystem) then
  begin
    User := AdminSystem.fdSystem_User_List.FindCode(UserCode);

    if Assigned(User) then
    begin
      Result := LoginOnline(User^, uName, pass, Cancelled, ConnectionError);
    end;
  end;
end;

class function TfrmLogin.LoginOnline(User: TUser_Rec; uName: String; var CurrentPassword: String; out Cancelled, ConnectionError: Boolean): Boolean;
var
  PromptPasswordChange: Boolean;
  FullName: String;
  pUser: pUser_Rec;
begin
  Result := False;

  Cancelled := False;

  FullName := User.usName;

  if ProductConfigService.AuthenticateUser(AdminSystem.fdFields.fdBankLink_Code, User.usEMail_Address, CurrentPassword, PromptPasswordChange, ConnectionError) then
  begin
    if PromptPasswordChange then
    begin
      Cancelled := not ChangeUserPassword(User.usCode, CurrentPassword);

      if not Cancelled then
      begin
         pUser := AdminSystem.fdSystem_User_List.FindCode(User.usCode);

        if Assigned( pUser) then
        begin
          User := pUser^;
        end
        else
        begin
          HelpfulErrorMsg('The User ' + User.usCode + ' can no longer be found in the Admin System.', 0);

          Exit;
        end;
      end;
    end;

    if not Cancelled then
    begin
      if not User.usUsing_Secure_Authentication then
      begin
        UpdateLocalSecurePassword(User.usCode, CurrentPassword);
      end
      else
      if not ValidateUserPassword(User, CurrentPassword) then
      begin
        UpdateLocalSecurePassword(User.usCode, CurrentPassword);
      end;

      Result := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmLogin.btnCancelClick(Sender: TObject);
begin
  okPressed := false;
  Close;
end;
//------------------------------------------------------------------------------
function AcceptLicense(User: pUser_Rec; O: TComponent): Boolean;
var
  f: TDlgLicense;
begin
  Result := True;
  {EULA differs - must accept}
  if User.usEULA_Version <> WinUtils.GetAppVersionStr then
  begin
    f := TDlgLicense.Create(O);
    try
      if f.ShowModal <> mrYes then
      begin
        ErrorSound;
        HelpfulWarningMsg('You must accept the Licence Agreement to login.',0);
        Result := False;
        exit;
      end;
    finally
      f.Free;
    end;
  end;
end;

function TfrmLogin.ValidateUser(uName, pass: string): boolean;
var
  Cancelled: Boolean;
begin
  result := false;
  Inc(Tries);

  {is this the superuser?}
  If uName = SUPERUSER then
  begin
    user := nil;
    {validate special password - randomly generated}
    if (pass = SuperPwd) then
    begin
      result := true;
      SuperUserLoggedIn := true;
      exit;
    end;
  end;

  {first must find user in list}
  User := AdminSystem.fdSystem_User_List.FindCode( uName );
  if not Assigned(User) then
  begin
    WinUtils.ErrorSound;
    HelpfulWarningMsg('Your Username and/or Password is invalid.  Please try again.',0);
    exit;
  end;

  //UK only - don't allow login if the user doesn't have a password
  if (User.usPassword = '') and not User.usUsing_Secure_Authentication then
  begin
   if AdminSystem.fdFields.fdCountry = whUK then begin
     ErrorSound;
     HelpfulWarningMsg('You do not have a valid Password. Please see your administrator.',0);
     okPressed := false;
     Close;
     Exit;
   end;
  end;
  {user found now check password}
  if not Login(uName, pass, Cancelled) then
  begin
    if Cancelled then
    begin
      Exit;
    end
    else
    begin
      ErrorSound;
      HelpfulWarningMsg('Your Username and/or Password is invalid.  Please try again.',0);
      exit;
    end;
  end;

  if AcceptLicense(User, Self) then
    Result := True;
end;
//------------------------------------------------------------------------------
procedure TfrmLogin.eUserNameChange(Sender: TObject);
var
   RndSeed : integer;
begin
   if eUserName.Text = SUPERUSER then
   begin
     Randomize;
     RndSeed := Random(100000);
     SuperPwd := PasswordFromSeed(RndSeed);
     lblSeed.Transparent := False;
     lblSeed.Font.Color := clwhite;
     lblSeed.Caption := inttostr(RndSeed);
     lblSeed.visible := true;
   end
   else
     lblSeed.visible := false;
end;
//------------------------------------------------------------------------------
procedure TfrmLogin.eUserNameEnter(Sender: TObject);
begin
 eUserName.SelectAll;
end;
//------------------------------------------------------------------------------
procedure TfrmLogin.eUserNameKeyPress(Sender: TObject; var Key: Char);
begin
  If (Sender Is TCustomEdit) and not Odd(GetKeyState(VK_INSERT)) Then
  With TCustomEdit(Sender) Do
    If SelLength = 0 Then
    Case Key of
      ' '..#126, #128..#255: begin
          SelLength := 1;
          If (SelLength > 0) and (SelText[1] = #13) Then
            SelLength := 2;
        End;
    End;
end;
//------------------------------------------------------------------------------
function TfrmLogin.Execute: boolean;
begin
  result := false;
  if not Assigned(AdminSystem) then exit;

  okPressed := false;
  Tries := 0;
  if (EuserName.Text > '')
  and (StartupParam_UserPassword > '') then
     if ValidateUser(eUsername.Text,StartupParam_UserPassword) then begin
        Result := true;
        Exit;
     end else begin
        // Startup Login failed, No action
        StartupParam_Action := 0;
     end;
      
  

  ShowModal;
  result := okPressed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure ResetUser( var aUser : pUser_Rec);
//resets any files they may have had open
//there is no need to reset the users logged in status because it is about to
//be set to logged in anyway
const
   ThisMethodName = 'ResetUser';
var
   i        : integer;
   UsersLRN : integer;
begin
   LogUtil.LogMsg(lmInfo, UnitName, 'Reseting User Status for ' + aUser^.usCode);
   //need to store this because pUser_Rec points to memory in the admin system
   //so it will be changed after the admin system is reloaded.
   UsersLRN := aUser^.usLRN;
   if LoadAdminSystem(true, ThisMethodName ) then begin
      aUser := AdminSystem.fdSystem_User_List.FindLRN( UsersLRN);
      Inc(aUser.usReset_Count);
      //reset any open files
      with AdminSystem.fdSystem_Client_File_List do begin
         for i := 0 to Pred(ItemCount) do begin
            with Client_File_At(i)^ do begin
               if (cfFile_Status = fsOpen) and (cfCurrent_User = UsersLRN) then begin
                  //reset the file status for files that this user may have open
                  cfFile_Status := fsNormal;
                  cfCurrent_User := 0;
               end;
            end;
         end;
      end;
      SaveAdminSystem;
   end;
   //update the user record point after reloading the admin system
   aUser := AdminSystem.fdSystem_User_List.FindLRN( UsersLRN)
end;
//------------------------------------------------------------------------------
function CreateUser(Code : string; Name : string; UserPassword: String; SysAccess : boolean; LRN : integer; MasterMemorise : boolean; User : pUser_Rec) : boolean;
const
   ThisMethodName = 'CreateUser';
var
  pUser : pUser_Rec;
  CurrentWorkstation : string[20];
begin
  result := false;
  CurrentWorkStation := WinUtils.ReadComputerName;

  //setup user
  GlobalCache.cache_Current_Username := Code;  //update global username variable

  if Assigned(User) then begin
    if (User^.usLogged_In) then begin
       //in most cases this will occur when a user has crashed out of banklink.
       //if this is the case they can be given the option to reset their user status
       //and mark any open files as no longer open.
       //the other case where this would happen is if the try to login at another terminal
       //with the same login.
       //test to see which computer the user was last logged in at
       if ( User^.usWorkstation_Logged_In_At = CurrentWorkStation) then begin
          if AskYesNo( 'User Already Logged In',
                       'User ' + User^.usCode + ' is already logged in!'#13#13+
                       'YOU MUST NOT LOGIN AS THE SAME USER MORE THAN ONCE! '+#13#13+
                       'If you have been locked out of ' + ShortAppName + ' '+
                       'you can reset your user status and unlock any '+
                       'client files that you had open.'#13#13+
                       'Do you want to reset your user status?',
                       DLG_NO, 0) <> DLG_YES then exit;
          //User wants to reset user status
          ResetUser( User);
       end
       else begin
          HelpfulErrorMsg( 'Sorry, User '+ User^.usCode + ' is already logged in '+
                           'at workstation '+ User^.usWorkstation_Logged_In_At+'. '+#13#13+
                           'You cannot login more than once. '+
                           'Please contact a '+SHORTAPPNAME+' Administrator.',0);
          exit;
       end;
    end;
  end;

  LogUtil.LogMsg(lmInfo,UnitName,'Logging in User: ' + Code +
    ' (' + WinUtils.GetShortAppVersionStr + ')', ErrorLog.stat_Login);

  CurrUser := TAppUser.Create;
//try
     CurrUser.Code := Code;
     CurrUser.LRN := LRN;

     with CurrUser do begin
       FullName            := Name;
       CanAccessAdmin      := SysAccess;
       CanMemoriseToMaster := MasterMemorise;
       if User = nil then begin
          HasRestrictedAccess  := false;
          ShowCMOnOpen         := false;
          ShowPrinterDialog    := false;
          SuppressHeaderFooter := shfUndefined;
          ShowPracticeLogo     := False;
          AllowBanklinkOnline  := False;
       end else begin
          HasRestrictedAccess  := User^.usIs_Remote_User;
          ShowCMOnOpen         := (not HasRestrictedAccess) and Assigned(AdminSystem);
          if Assigned(CurrUser) and Assigned(AdminSystem) and CurrUser.HasRestrictedAccess then
             CloseClientManager;
          ShowPrinterDialog    := User^.usShow_Printer_Choice;
          SuppressHeaderFooter := User^.usSuppress_HF;
          ShowPracticeLogo     := User^.usShow_Practice_Logo;
          AllowBanklinkOnline  := User^.usAllow_Banklink_Online;
          EmailAddress         := User^.usEMail_Address;
          Password             := UserPassword;
       end;
     end;

{$IFNDEF TESTLOCKING}
     //load settings for this user - should have been freed by logout
     UserPrintSettings := TPrintManagerObj.Create;
     UserPrintSettings.FileName := DATADIR + Code + USERPRINTEXTN;
     UserPrintSettings.Open;
{$ENDIF}

     //tell admin that user is logged in
     if Assigned( AdminSystem) then begin
        if LoadAdminSystem(true, ThisMethodName ) then begin
           pUser := AdminSystem.fdSystem_User_List.FindCode(Code);
           if Assigned(pUser) then begin
             pUser.usLogged_In := true;
             pUser.usWorkstation_Logged_In_At := WinUtils.ReadComputerName;
             pUser.usEULA_Version := WinUtils.GetAppVersionStr;
             Inc(pUser.usLogin_Count);
             SaveAdminSystem;
           end
           else
             UnlockAdmin;
        end;
     end;

     //everything completed ok
     result := true;
//except
//  on e : exception do begin
//    CurrUser.Free;
//    CurrUser := nil;
//  end;
//end;
end;
//------------------------------------------------------------------------------
function RequestLogin(var TryUserName : string; var UserRec : pUser_Rec; out Password: String) : boolean;
var
  MyDlg : TfrmLogin;
begin
  result := false;

  MyDlg := TfrmLogin.Create(Application);
  try
    MyDlg.User := UserRec;
    MyDlg.eUserName.Text := TryUserName;

    if MyDlg.Execute then
    begin
       UserRec := MyDlg.User;
       TryUserName := UpperCase(MyDlg.eUserName.Text);  {just in case it changed}
       Password := MyDlg.Password;
       result := true;
    end;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
function LoginUser(TryUserName : string): boolean;
const
  ThisMethodName = 'LoginUser';
var
  User : pUser_Rec;
  ShiftKeyDown : boolean;
  v : integer;
  Password: String;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' begins' );

  result :=false;
  User   := nil;

  if Assigned(CurrUser) then begin
     HelpfulErrorMsg('The current user must logout before a new user can login.',0);
     exit;
  end;

  //check for admin system, free lock when done

  if Assigned( AdminSystem) then begin
     if not RefreshAdmin then begin
       HelpfulErrorMsg('The Admin system has not been loaded. You cannot be authenticated',0);
       exit;
     end;

     //try automatic login - detect if SHIFT is pressed and abandon auto login
     v := GetKeyState( VK_SHIFT);
     ShiftKeyDown := v < 0;

     If (not ShiftKeyDown) and ( TryUserName <> '' ) and not AdminSystem.fdFields.fdForce_Login then begin
       User := AdminSystem.fdSystem_User_List.FindCode( TryUserName );
       If Assigned( User ) then With User^ do begin
         If (usPassword = '') and not User.usUsing_Secure_Authentication then
         begin
            //We can log in automatically
            //if they accept the EULA
            if AcceptLicense(User, Application.MainForm)
            and CreateUser( usCode, usName, usPassword, usSystem_Access, usLRN, usMASTER_Access, User ) then begin
               if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+' Auto Login no password');
               INISettings.ReadUsersINI(CurrUser.Code);
               MadAddEmailBodyValue('User-Code',CurrUser.Code  );
               MadAddEmailBodyValue('User-Name',CurrUser.FullName  );
               result := true;
               exit;
            end;
            //else  Autologin failed - password required
         end;
       end;
     end;

     //manual login
     if RequestLogin(TryUserName, User, Password) then
     begin
       if Assigned(User) then begin
         with User^ do begin
           result := CreateUser(usCode, usName, Password, usSystem_Access, usLRN, usMaster_access, User )
         end
       end
       else begin
         //the only other way this could success is that the superuser code has been
         //used
         result := CreateUser( SuperUserCode,'SuperUser', '', true,0,false,nil);
       end;
     end;
  end
  else
  begin
    //admin system doesnt exist so cant validate user, login as a default user
    if TryUserName = '' then
       TryUserName := 'USER';

    result := CreateUser(TryUserName,'', '',false,0,false, nil);
    If assigned(CurrUser) then CurrUser.ShowPrinterDialog := INI_ShowPrintOptions;
  end;

  if (result) then begin

    if (CurrUser.Code <> SuperUserCode) then begin
       INISettings.ReadUsersINI( CurrUser.Code);
       MadAddEmailBodyValue('User-Code',CurrUser.Code  );
       MadAddEmailBodyValue('User-Name',CurrUser.FullName  );
    end else
       MadAddEmailBodyValue('User-Name','SuperUser');
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//------------------------------------------------------------------------------
function LogoutUser : boolean;
{uses the global USERNAME variable that is set by create user}
const
   ThisMethodName = 'LogoutUser';
var
  pUser : pUser_Rec;
  UserCode: string;
begin
  result := false;
  try
    if not Assigned(CurrUser) then exit;
    UserCode := CurrUser.Code;
    LogUtil.LogMsg(lmInfo,UnitName,'Logging out User: '+ UserCode, ErrorLog.stat_Logout);

    {tell admin that user is logged out}
    if Assigned( AdminSystem) then
       if LoadAdminSystem(true, ThisMethodName ) then begin
          pUser := AdminSystem.fdSystem_User_List.FindCode(UserCode);
          if Assigned(pUser) then begin
            pUser.usLogged_In := false;
            pUser.usWorkstation_Logged_In_At := '';
            SaveAdminSystem;
          end
          else
            UnlockAdmin;
       end;
    result := true;

{$IFNDEF TESTLOCKING}
    //clear users print settings
    if Assigned(UserPrintSettings) then UserPrintSettings.Save;
{$ENDIF}
    //write users ini
    if ( UserCode <> SuperUserCode) then
      INISettings.WriteUsersINI( UserCode);

  finally  {free objects}
{$IFNDEF TESTLOCKING}
    UserPrintSettings.Free;
    UserPrintSettings := nil;
{$ENDIF}

    CurrUser.Free;
    CurrUser := nil;
  end;
end;
//------------------------------------------------------------------------------

initialization
   DebugMe := DebugUnit(UnitName);
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.


