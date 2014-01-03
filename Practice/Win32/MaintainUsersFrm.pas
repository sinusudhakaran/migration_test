unit MaintainUsersFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ToolWin,
  SyDefs,
  Math,
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
    procedure lvUsersCustomDrawSubItem(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure lvUsersMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    SortCol : integer;
    ShieldLeft, ShieldRight, ShieldTop, ShieldBottom: integer;
    bmpOnlineAdmin : TBitmap;
    PrimaryContactHint: THintWindow;
    Rect: TRect;
    procedure RefreshUserList;
    function DeleteUser(User : PUser_Rec) :boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  //-----------------------------------------
  function MaintainUsers(w_PopupParent: TForm) : boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

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
  InfoMoreFrm,
  WarningMoreFrm,
  StStrS,
  ErrorMoreFrm,
  LvUtils,
  AuditMgr,
  BankLinkOnlineServices,
  PickNewPrimaryUser,
  CommCtrl,
  strutils,
  bkProduct,
  bkBranding;

const
  UNITNAME = 'MaintainUsersFrm';
  ONLINE_NO        = 'a. Not Online';
  ONLINE_YES_ADMIN = 'b. Admin Online';
  ONLINE_YES       = 'c. Online';

//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetUpHelp;
  ShieldLeft := -1;
  ShieldRight := -1;
  ShieldTop := -1;
  ShieldBottom := -1;
  PrimaryContactHint := THintWindow.Create(nil);
end;

procedure TfrmMaintainUsers.FormDestroy(Sender: TObject);
begin
  FreeAndNil(PrimaryContactHint);
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

function TfrmMaintainUsers.DeleteUser(User: PUser_Rec): boolean;
const
  ThisMethodName = 'TfrmMaintainUsers.DeleteUser';
var
  Code : string;
  StoredLRN : integer;
  pu : pUser_Rec;
  DelMsg : String;
  HasDelOnline : Boolean;
  Name : String;
  aPractice : TBloPracticeRead;
begin
  HasDelOnline := False;
  Result := False;

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
  if User^.usAllow_Banklink_Online then
    DelMsg := 'This user will be deleted from both ' + bkBranding.PracticeProductName + ' and ' + bkBranding.ProductOnlineName + '.' + #13;

  DelMsg := DelMsg + 'OK to Delete User %s ?';

  if AskYesNo('Delete User',Format(DelMsg, [User^.uscode]), DLG_NO, 0) <> DLG_YES then
    exit;

  if User^.usAllow_Banklink_Online then
  begin
    try
      aPractice := ProductConfigService.GetPractice;
      if ProductConfigService.OnLine and ProductConfigService.IsPrimPracUser(User^.usCode, aPractice) then
      begin
        if not PickPrimaryUser(puaDelete, User^.usCode, aPractice) then
          exit;
      end;

      if not ProductConfigService.DeletePracUser(User^.usCode, '', aPractice) then
      begin
        HelpfulInfoMsg(bkBranding.PracticeProductName + ' was unable to remove this user from ' + bkbranding.ProductOnlineName, 0);
        exit;
      end;

      HasDelOnline := True;
    except
      on E : Exception do
      begin
        HelpfulErrorMsg(E.Message, 0);
        exit;
      end;
    end;
  end;

  Code := User^.usCode;
  StoredLRN := User^.usLRN;
  Name := User^.usName;

  if LoadAdminSystem(true, ThisMethodName ) then
  begin
    pu := AdminSystem.fdSystem_User_List.FindLRN(StoredLRN);
    if not Assigned(pu) then
    begin
      UnlockAdmin;
      HelpfulErrorMsg('The User ' + Code + ' can no longer be found in the Admin System.',0);
      exit;
    end;

    //delete from list
    AdminSystem.fdSystem_File_Access_List.Delete_User( pu.usLRN );
    AdminSystem.fdSystem_User_List.DelFreeItem(pu);

    //*** Flag Audit ***
    SystemAuditMgr.FlagAudit(arUsers);

    SaveAdminSystem;
    result := true;
    if HasDelOnline then
      HelpfulInfoMsg(Format('%s has been successfully deleted from ' + bkBranding.PracticeProductName + ' and ' + bkBranding.ProductOnlineName + '.', [Name]), 0 );

    LogUtil.LogMsg(lmInfo, UNITNAME,
                   Format('User %s was deleted by %s.', [Name, CurrUser.FullName]));
  end
  else
    HelpfulErrorMsg('Could not update User Details at this time. Admin System unavailable.',0);
end;

function TfrmMaintainUsers.Execute: boolean;
begin
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
  Online   : String;
  Prac     : TBloPracticeRead;
begin
  lvUsers.Items.beginUpdate;
  try
    lvUsers.Items.Clear;

    if not RefreshAdmin then
      exit;

    Prac := nil;
    if (not UseBankLinkOnline) then
    begin
      lvUsers.Column[4].Caption  := '';
      lvUsers.Column[4].Width    := 0;
      lvUsers.Column[4].MaxWidth := 0;
    end
    else
    begin
      Prac := ProductConfigService.GetPractice;
      if ProductConfigService.Online then
        ProductConfigService.UpdateUserAllowOnlineSetting;

      lvUsers.Column[4].Caption := TProduct.Rebrand(lvUsers.Column[4].Caption);
    end;

    with AdminSystem, fdSystem_User_List do
    begin
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

        if AdminSystem.fdSystem_File_Access_List.Restricted_User( User.usLRN ) then
        begin
          //count how many files the user has access to
          Count := 0;
          for j := 0 to Pred( AdminSystem.fdSystem_Client_File_List.ItemCount ) do
          begin
            scf := AdminSystem.fdSystem_Client_File_List.Client_File_At( j);
            If AdminSystem.fdSystem_File_Access_List.Allow_Access( User.usLRN, scf.cfLRN) then
              Inc( Count);
          end;

          If Count = 0 then
            FileAccess := 'None'
          else
            FileAccess := 'Selected';
        end
        else
        begin
          FileAccess := 'All';
        end;

        Online := '';
        if UseBankLinkOnline then
        begin
          if (User^.usAllow_Banklink_Online) then
          begin
            Assert(assigned(Prac));
            if (ProductConfigService.OnLine) and
               (ProductConfigService.IsPrimPracUser(User.usCode, Prac)) then
              Online := ONLINE_YES_ADMIN
            else
              Online := ONLINE_YES;
          end
          else
          begin
            Online := ONLINE_NO;
          end;
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
        NewItem.SubItems.Add(Online);
        NewItem.SubItems.Add(FileAccess);
      end;
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
procedure TfrmMaintainUsers.lvUsersCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);

  //------------------------------------------------------
  function GetSubItemLeft(aItemIndex : integer) : integer;
  var
    ItemIndex : integer;
  begin
    Result := 0;
    for ItemIndex := 0 to aItemIndex do
      Result := Result + lvUsers.Columns[ItemIndex].Width;
  end;

const
  ONLINE_SUBITEM = 3;
var
  ItemRect : TRect;
  SubItemRect : TRect;
  OutputText : String;
  SubItemIndex : integer;
  First : Boolean;
  SubItemLeft : integer;
  SubItemTop  : integer;
  bmpOnline : TBitmap;
  useOnlineAdmin : Boolean;
  useOnline : Boolean;
begin
  if (not assigned(Item)) or
    (not UseBankLinkOnline) then
    Exit;

  SubItemIndex := SubItem-1;

  DefaultDraw := false;

  SetBkMode(lvUsers.Canvas.Handle, TRANSPARENT);
  ListView_SetTextBkColor(lvUsers.Handle, ColorToRGB(clWindow));
  ListView_SetBKColor(lvUsers.Handle, ColorToRGB(clWindow));

  ItemRect := Item.DisplayRect(drBounds);
  SubItemRect := ItemRect;
  SubItemRect.left  := ItemRect.Left + GetSubItemLeft(SubItemIndex);
  SubItemRect.right := ItemRect.left + GetSubItemLeft(SubItemIndex+1);

  SubItemLeft := ItemRect.Left + GetSubItemLeft(SubItemIndex);
  SubItemTop  := ItemRect.Top + 2;

  case (SubItemIndex) of
    ONLINE_SUBITEM : begin
      if (Item.SubItems[SubItemIndex] = ONLINE_YES) then
      begin
        useOnlineAdmin := False;
        useOnline := True;
      end
      else if (Item.SubItems[SubItemIndex] = ONLINE_YES_ADMIN) then
      begin
        useOnlineAdmin := True;
        useOnline := True;
      end
      else
      begin
        useOnlineAdmin := False;
        useOnline := False;
      end;

      bmpOnline := TBitmap.Create;
      bmpOnlineAdmin := TBitmap.Create;
      Try
        If (cdsFocused  in State) or
           (cdsSelected in State) then
        begin
          if useOnlineAdmin then
            AppImages.Maintain.GetBitmap(MAINTAIN_SELECT, bmpOnlineAdmin);
          if useOnline then
            AppImages.Maintain.GetBitmap(MAINTAIN_SELECT, bmpOnline);
        end;

        if  (useOnlineAdmin)
        and (SubItemLeft+30 <= SubItemRect.Right) then
        begin
          AppImages.Maintain.GetBitmap(MAINTAIN_ONLINE_ADMIN, bmpOnlineAdmin);
          Sender.Canvas.Draw(SubItemLeft+20, SubItemTop, bmpOnlineAdmin);
          ShieldLeft := SubItemLeft + 20;
          ShieldRight := ShieldLeft + bmpOnlineAdmin.Width;
          ShieldTop := SubItemTop;
          ShieldBottom := ShieldTop + bmpOnlineAdmin.Height;
          Rect.Left := Self.Left + ShieldRight;
          Rect.Top := Self.Top + ShieldBottom + 10;
          Rect.Right := Rect.Left + Canvas.Textwidth('Primary Contact');
          Rect.Bottom := Rect.Top + 17;

          if assigned(PrimaryContactHint) then
            PrimaryContactHint.Color := clWhite;
        end;

        if useOnline
        and (SubItemLeft+50 <= SubItemRect.Right) then
        begin
          AppImages.Maintain.GetBitmap(MAINTAIN_ONLINE, bmpOnline);
          Sender.Canvas.Draw(SubItemLeft+40, SubItemTop, bmpOnline);
        end;

      Finally
        FreeAndNil(bmpOnlineAdmin);
        FreeAndNil(bmpOnline);
      End;
    end;
    0,1,2,4 : begin
      First := true;
      OutputText := Item.SubItems[SubItemIndex];

      while (Sender.Canvas.TextWidth(OutputText) >= (SubItemRect.Right - SubItemRect.Left)) and
            (length(OutputText) > 0) do
      begin
        if (First = True) then
        begin
          if length(OutputText) > 2 then
            OutputText := leftStr(OutputText,length(OutputText)-2) + '...'
          else
            OutputText := '';

          First := false;
        end
        else
        begin
          if length(OutputText) > 4 then
            OutputText := leftStr(OutputText,length(OutputText)-4) + '...'
          else
            OutputText := '';
        end;
      end;

      if not (OutputText = '') then
        Sender.Canvas.TextOut(SubItemLeft, SubItemTop, OutputText);
    end;
  end;
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

    EditUser(Self, p^.usCode);
    RefreshUserList;  {must reload because the admin object was freed and recreated}
    lvUsers.Selected := lvUsers.FindCaption(0,WasCaption,false,false,true);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.lvUsersDblClick(Sender: TObject);
begin
  tbEdit.Click;
end;

procedure TfrmMaintainUsers.lvUsersMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  HintPoint: TPoint;
begin
  if (X >= ShieldLeft) and (X <= ShieldRight) and (Y >= ShieldTop) and (Y <= ShieldBottom) then
  begin
    PrimaryContactHint.ActivateHint(Rect, 'Primary Contact');
    PrimaryContactHint.Show;
  end else
    PrimaryContactHint.Hide;
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
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.tbNewClick(Sender: TObject);
begin
  if AddUser(Self) then
    RefreshUserList;
end;

//------------------------------------------------------------------------------
function MaintainUsers(w_PopupParent: TForm) : boolean;
var
  MyDlg : TfrmMaintainUsers;
begin
  result := false;

  if not Assigned(AdminSystem) then
    exit;

  MyDlg := TfrmMaintainUsers.Create(Application.mainForm);
  try
    MyDlg.PopupParent := w_PopupParent;
    MyDlg.PopupMode := pmExplicit;
    
    BKHelpSetUp(MyDlg, BKH_Setting_up_BankLink_users);
    MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainUsers.FormShow(Sender: TObject);
begin
  RefreshUserList;

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
