unit MaintainUsersFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, SyDefs, Math,
  OSFont;

type
  TfrmMaintainUsers = class(TForm)
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    ToolButton5: TToolButton;
    tbClose: TToolButton;
    lvUsers: TListView;
    ToolButton1: TToolButton;
    tnHelp: TToolButton;
    procedure tbCloseClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure lvUsersColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvUsersCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure tbEditClick(Sender: TObject);
    procedure lvUsersDblClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormShow(Sender: TObject);
    procedure tnHelpClick(Sender: TObject);
  private
    { Private declarations }
    SortCol : integer;
    procedure RefreshUserList;
    function DeleteUser(User : PUser_Rec) :boolean;
    Function PracticeCanUseBankLinkOnline : Boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  function MaintainUsers : boolean;

//******************************************************************************
implementation

uses
  Admin32,
  BKConst,
  BKHelp,
  bkXPThemes,
  Globals,
  GlobalCache,
  YesNoDlg,
  LogUtil,
  imagesfrm,
  EditUserDlg,
  WarningMoreFrm,
  StStrS,
  ErrorMoreFrm,
  LvUtils,
  AuditMgr;

{$R *.DFM}

const
  UNITNAME = 'MaintainUsersFrm';

//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm( Self);
   SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tbNew.Hint       :=
                    'Add a new User|' +
                    'Add a new User';
   tbEdit.Hint      :=
                    'Edit the details for the selected User|' +
                    'Edit the details for the selected User';
   tbDelete.Hint    :=
                    'Delete the selected User|' +
                    'Delete the selected User';
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tbCloseClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  Handled := true;
  case Msg.CharCode of
    VK_INSERT : tbNew.click;
    VK_DELETE : tbDelete.click;
    VK_RETURN : tbEdit.click;
    VK_ESCAPE : tbClose.click;
  else
    Handled := false;
  end;
end;
//------------------------------------------------------------------------------
function TfrmMaintainUsers.DeleteUser(User: PUser_Rec): boolean;
const
   ThisMethodName = 'TfrmMaintainUsers.DeleteUser';
var
  Code : string;
  StoredLRN : integer;
  pu : pUser_Rec;
  DelMsg : String;
begin
  result := false;

  if User^.usCode = GlobalCache.cache_Current_Username then
  begin
     HelpfulWarningMsg('Cannot delete the user you are logged in as.',0);
     exit;
  end;

  if User^.usLogged_In then
  begin
     HelpfulWarningMsg('Cannot delete user ' + user^.usCode + ' because user is still logged in.',0);
     exit;
  end;

  DelMsg := '';
  if (User^.usAllow_Banklink_Online) and
     (PracticeCanUseBankLinkOnline) then
    DelMsg := 'This user will be deleted from both Banklink Practice and Banklink Online.' + #13;

  DelMsg := DelMsg + 'OK to Delete User $s ?';

  if AskYesNo('Delete User',Format(DelMsg, [User^.uscode]), DLG_NO, 0) <> DLG_YES then
    exit;

  Code := User^.usCode;
  StoredLRN := User^.usLRN;

  if LoadAdminSystem(true, ThisMethodName ) then
  begin
     pu := AdminSystem.fdSystem_User_List.FindLRN(StoredLRN);
     if not Assigned(pu) then
     begin
       UnlockAdmin;
       HelpfulErrorMsg('The User ' + Code + ' can no longer be found in the Admin System.',0);
       exit;
     end;

     {delete from list}
     AdminSystem.fdSystem_File_Access_List.Delete_User( pu.usLRN );
     AdminSystem.fdSystem_User_List.DelFreeItem(pu);

     //*** Flag Audit ***
     SystemAuditMgr.FlagAudit(arUsers);

     SaveAdminSystem;
     result := true;
     LogUtil.LogMsg(lmDebug,'EDITUSERDLG','User Deleted  User '+Code);
  end
  else
     HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.',0);
end;

//------------------------------------------------------------------------------
function TfrmMaintainUsers.PracticeCanUseBankLinkOnline : Boolean;
begin
  Result := True;
end;

//------------------------------------------------------------------------------
function TfrmMaintainUsers.Execute: boolean;
begin
   RefreshUserList;

   SortCol := 2;
   lvUsers.AlphaSort;

   ShowModal;
   result := true;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.RefreshUserList;
var
   NewItem  : TListItem;
   User     : pUser_Rec;
   UserType : string;
   Status   : string;
   FileAccess: string;
   scf      : pClient_File_Rec;
   Count    : integer;
   i,j      : integer;
begin
   lvUsers.Items.beginUpdate;
   try

   lvUsers.Items.Clear;
   if not RefreshAdmin then exit;

   with AdminSystem, fdSystem_User_List do
   for i := 0 to Pred(itemCount) do
   begin
      User := User_At(i);
      if User.usLogged_In then
         Status := 'Logged In'
      else
         Status := '';

      if User.usSystem_Access then
         UserType := ustNames[ustSystem] //'System'
      else if User.usIs_Remote_User then
         UserType := ustNames[ustRestricted] //'Restricted'
      else
         UserType := ustNames[ustNormal]; //'Normal';

      if AdminSystem.fdSystem_File_Access_List.Restricted_User( User.usLRN ) then begin
         //count how many files the user has access to
         Count := 0;
         for j := 0 to Pred( AdminSystem.fdSystem_Client_File_List.ItemCount ) do begin
            scf := AdminSystem.fdSystem_Client_File_List.Client_File_At( j);
            If AdminSystem.fdSystem_File_Access_List.Allow_Access( User.usLRN, scf.cfLRN) then
               Inc( Count);
         end;

         If Count = 0 then
            FileAccess := 'None'
         else
            FileAccess := 'Selected';
      end
      else begin
         FileAccess := 'All';
      end;

      NewItem := lvUsers.Items.Add;
      NewItem.Caption := User.usCode;
      if User.usLogged_In then
        NewItem.ImageIndex := MAINTAIN_USER_BMP
      else
        NewItem.ImageIndex := -1;

      NewItem.SubItems.AddObject(User.usName,TObject(User));
      NewItem.SubItems.Add(Status);
      NewItem.subITems.Add(UserType);
      NewItem.SubItems.Add(FileAccess);         
   end;

   finally
      lvUsers.items.EndUpdate;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.lvUsersColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvUsers.columns.Count-1 do
    lvUsers.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortCol := Column.ID;
  LvUsers.AlphaSort;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.lvUsersCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
begin
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;

  1,4: begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
     end;

  2,3: begin  {reverse sort so logged in users appear at top}
       Key2 := Item1.SubItems.Strings[SortCol-1];
       Key1 := Item2.SubItems.Strings[SortCol-1];
     end;
  end;

  Compare := StStrS.CompStringS(Key1,Key2);
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tbEditClick(Sender: TObject);
var
  p : pUser_Rec;
  wasCaption : string;
begin
  if lvUsers.Selected <> nil then
  begin
    p := pUser_Rec(lvUsers.Selected.SubItems.Objects[0]);
    WasCaption := p^.usCode;

    EditUser(p^.usCode);
    RefreshUserList;  {must reload because the admin object was freed and recreated}
    lvUsers.Selected := lvUsers.FindCaption(0,WasCaption,false,false,true);
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.lvUsersDblClick(Sender: TObject);
begin
  tbEdit.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tbDeleteClick(Sender: TObject);
var
  p : pUser_Rec;
  PrevSelectedIndex : Integer;
  PrevTopItemIndex: Integer;
begin
  if lvUsers.Selected <> nil then
  begin
    PrevSelectedIndex := lvUsers.Selected.Index;
    PrevTopItemIndex := lvUsers.TopItem.Index;
    p := pUser_Rec(lvUsers.Selected.SubItems.Objects[0]);
    if DeleteUser(p) then
    begin
      RefreshUserList;
      ReselectAndScroll(lvUsers, PrevSelectedIndex, PrevTopItemIndex);
      LogUtil.LogMsg(lmInfo, UNITNAME,
                     Format('User $s was deleted by $s.', [p.usName, CurrUser.FullName]));
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tbNewClick(Sender: TObject);
begin
  if AddUser then RefreshUserList;
end;
//------------------------------------------------------------------------------
function MaintainUsers : boolean;
var
  MyDlg : TfrmMaintainUsers;
begin
  result := false;
  if not Assigned( AdminSystem) then exit;

  MyDlg := TfrmMaintainUsers.Create(Application.mainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.FormShow(Sender: TObject);
begin
   if (lvUsers.Items.Count > 0) then
   begin
     //highlight the top user
     lvUsers.Items[0].Selected := True;
     lvUsers.Items[0].Focused := True;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tnHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

end.
