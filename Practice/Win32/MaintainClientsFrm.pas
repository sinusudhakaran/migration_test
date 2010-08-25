unit MaintainClientsFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Maintain the Clients at a Practice Level
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!! No longer used in 5.3



interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, sydefs;

type
  TfrmMaintainClients = class(TForm)
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    ToolButton5: TToolButton;
    tbClose: TToolButton;
    lvFiles: TListView;
    procedure tbCloseClick(Sender: TObject);
    procedure lvFilesColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvFilesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure tbEditClick(Sender: TObject);
    procedure lvFilesDblClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
  private
    { Private declarations }
    SortCol : integer;
    procedure RefreshClientList;
    function DeleteClient(ClientFile : pClient_File_Rec) :boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  function MaintainClients : boolean;

//******************************************************************************
implementation

{$R *.DFM}

uses
  bkXPThemes,
  globals,
  admin32,
  bkconst,
  imagesfrm,
  viewClientFileDlg,
  stDateSt,
  YesNoDlg,
  ErrorMoreFrm,
  InfoMoreFrm,
  EnterPwdDlg,
  LogUtil,
  NewClientWiz,
  lvUtils,
  StStrS,
  bkDateUtils,
  ShellUtils;

const
  UnitName = 'MAINTAINCLIENTSFRM';
var
   DebugMe : boolean = false;

//------------------------------------------------------------------------------
procedure TfrmMaintainClients.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SetListViewColWidth(lvFiles,1);
  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   tbNew.Hint       :=
                    'Add a new Client File|' +
                    'Add a new Client File';
   tbEdit.Hint      :=
                    'View the details for the selected Client File|' +
                    'View the details for the selected Client File';
   tbDelete.Hint    :=
                    'Delete the selected Client File|' +
                    'Delete the selected Client File';
end;
//------------------------------------------------------------------------------
function TfrmMaintainClients.DeleteClient(ClientFile: pClient_File_Rec): boolean;
const
   ThisMethodName = 'TfrmMaintainClients.DeleteClient';
var
  clientCode : string;
  User       : pUser_Rec;
  sUser      : string;
  msg        : string;
begin
  result := false;
  ClientCode := ClientFile^.cfFile_Code;
  if not RefreshAdmin then exit;

  {reload from new admin system to make sure looking at latest}
  ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);
  if not Assigned(ClientFile) then
  begin
    HelpfulErrorMsg('The client file for Client Code '+ClientCode+' can no longer be found in the admin system.',0);
    exit;
  end;

  User := AdminSystem.fdSystem_User_List.FindLRN(ClientFile.cfCurrent_User);
  if Assigned(User) then
    sUser := User.usCode
  else
    sUser := '<unknown>';

  {check status of file}
  case ClientFile.cfFile_Status of
    fsOpen : begin
      HelpfulInfoMsg( 'Sorry, User '+sUser+' is currently working on this client file.', 0 );
      exit;
    end;

    fsCheckedOut : begin
       HelpfulInfoMsg( 'Sorry, User '+sUSer+' has checked out this client file.', 0 );
       exit;
    end;

    fsOffsite: begin
       HelpfulInfoMsg('Sorry, this Client File is currently Off-site.',0);
       Exit;
    end;
  end; {case}

  {file is not open}
  msg := 'Deleting this Client will delete ALL TRANSACTIONS in the Client File and REMOVE '
        +'the Client File from the Administration System.'+#13+#13+
        'Please confirm that you really want to delete Client '+#13+#13+clientFile^.cfFile_Code+ ': '+clientfile^.cfFile_Name
                 +' from '+SHORTAPPNAME+'.';

  if (AskyesNo('Delete Client',Msg,DLG_NO,0) <> DLG_YES) then exit;

  //check password for file - if one doesnt exists then ask for DELETE as the password
  if (ClientFile.cfFile_Password = '') or (SuperUserLoggedIn) then
  begin
    if not EnterPassword('Enter the word DELETE in the box below to confirm deletion','DELETE',0, false,false) then
       exit;
  end
  else
    if not EnterPassword('Enter the Client File password to confirm deletion',ClientFile.cfFile_Password,0,false,true) then
    begin
      HelpfulInfoMsg('Incorrect password entered for this file.  You must enter the correct password before you can delete the file',0);
      exit;
    end;

  //now lock the admin system and delete the file, was locked check that status has not changed}
  if LoadAdminSystem(true, ThisMethodName ) then
  begin
     {reload new object}
     ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);
     if not Assigned(ClientFile) then
     begin
       UnlockAdmin;
       HelpfulErrorMsg('The client file for Client Code '+ClientCode+' can no longer be found in the admin system.',0);
       exit;
     end;

     if ClientFile.cfFile_Status <> fsNormal then
     begin
       UnlockAdmin;
       HelpfulErrorMsg('The client file for Client Code '+ClientCode+' is in use. (state <> fsNormal).',0);
       exit;
     end;

     {------------------------------------------------}
     {delete file from datadir}
     if BKFileExists(DATADIR + ClientFile.cfFile_Code + FILEEXTN) then
     begin
        LogUtil.LogMsg(lmInfo,'MAINTAINCLIENTSFRM','User Deleting Client with Code '+ClientCode+ ' from Admin System');

        if ShellUtils.DeleteFileToRecycleBin( DATADIR + ClientCode + FileExtn ) then
           LogUtil.LogMsg(lmInfo,'MAINTAINCLIENTSFRM','File '+DATADIR+ClientCode+FILEEXTN+' DELETED Ok.')
        else
           LogUtil.LogMsg(lmInfo,'MAINTAINCLIENTSFRM','File '+DATADIR+ClientCode+FILEEXTN+' DELETED Failed.');

        //clean up the BAK file   
        SysUtils.DeleteFile(DATADIR + ClientCode + BACKUPEXTN);
     end;

     {remove from admin system}

     AdminSystem.fdSystem_File_Access_List.Delete_Client_File( ClientFile.cfLRN );
     AdminSystem.fdSystem_Client_File_List.DelFreeItem( ClientFile );
     LogUtil.LogMsg(lmInfo,'MAINTAINCLIENTSFRM','Client '+ClientCode+' deleted from Admin System OK');
     SaveAdminSystem;
     {------------------------------------------------}
  end
  else
     HelpfulErrorMsg('Could not Delete Client File Details at this time. Admin System unavailable.',0);

   result := true;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.RefreshClientList;
var
   NewItem : TListItem;
   ClientFile : pClient_File_Rec;
   i : integer;
   User, Status : string;
   pu : pUser_Rec;
begin
   lvFiles.Items.beginUpdate;
   try

   lvFiles.Items.Clear;
   if not RefreshAdmin then exit;

   with AdminSystem, fdSystem_Client_File_List do
   for i := 0 to Pred(itemCount) do
   begin
      ClientFile := Client_File_At(i);

      {get details}
      User := '';
      Status := '';
      pU := fdSystem_User_List.FindLRN( clientFile.cfCurrent_User );
      If Assigned( pU ) then User := pu^.usCode;
      If clientFile.cfFile_Status in [fsMin..fsMax] then
        Status := fsNames[clientFile.cfFile_Status ];

      NewItem := lvFiles.Items.Add;
      NewItem.Caption := ClientFile.cfFile_Code;
      NewItem.ImageIndex := ClientFile.cfFile_Status;
      NewItem.SubItems.AddObject(ClientFile.cfFile_Name,TObject(ClientFile));
      NewItem.SubItems.Add(Status);
      NewItem.subITems.Add(User);

      if ClientFile.cfDate_Last_Accessed <> 0 then
        NewItem.subitems.Add(bkDate2Str(clientFile.cfDate_Last_Accessed))
      else
        NewItem.subitems.Add('unknown');
   end;

   finally
      lvFiles.items.EndUpdate;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.tbCloseClick(Sender: TObject);
begin
   close;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.lvFilesColumnClick(Sender: TObject; Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvFiles.columns.Count-1 do
    lvFiles.columns[i].ImageIndex := -1;
  column.ImageIndex := FILES_COLSORT_BMP;

  SortCol := Column.ID;
  lvFiles.AlphaSort;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.lvFilesCompare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
  Date1,Date2 : integer;
begin
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;

  3: begin
       Date1 := bkStr2Date(ITem1.SubItems.Strings[SortCol-1]);
       Date2 := bkStr2Date(ITem2.SubItems.Strings[SortCol-1]);

       Compare := 0;
       if Date1 < Date2 then Compare := -1
       else if Date1 > Date2 then Compare := 1;
       exit;
     end;
  else
    begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
    end;
  end;
  Compare := StStrS.CompStringS( Key1,Key2);
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.tbEditClick(Sender: TObject);
var
  p : pClient_File_Rec;
begin
  if lvFiles.Selected <> nil then
  begin
    p := pClient_file_Rec(lvFiles.Selected.SubItems.Objects[0]);
    if ViewEditClientFileDetails(p) then
      RefreshClientList;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.lvFilesDblClick(Sender: TObject);
begin
  tbEdit.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.FormShortCut(var Msg: TWMKey;
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
procedure TfrmMaintainClients.tbDeleteClick(Sender: TObject);
var
  p : pClient_File_Rec;
begin
  if lvFiles.Selected <> nil then
  begin
    p := pClient_File_Rec(lvFiles.Selected.SubItems.Objects[0]);
    if DeleteClient(p) then RefreshClientList;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainClients.tbNewClick(Sender: TObject);
begin
  if CreateClient(true) then
    RefreshClientList;
end;
//------------------------------------------------------------------------------
function TfrmMaintainClients.Execute: boolean;
begin
   RefreshClientList;

   SortCol := 0;
   lvfiles.AlphaSort;

   ShowModal;
   result := true;
end;
//------------------------------------------------------------------------------
function MaintainClients : boolean;
var
  MyDlg : TfrmMaintainClients;
begin
  result := false; 
  if not Assigned( AdminSystem) then exit;

  MyDlg := TfrmMaintainClients.Create(Application);
  try
     MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
initialization
   DebugMe := DebugUnit(UnitName);
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
end.
