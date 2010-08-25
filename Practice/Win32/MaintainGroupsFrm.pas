// This is used for adding groups, client types and job Titles
unit MaintainGroupsFrm;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ToolWin, SyDefs,bkDefs, EditGroupDlg, StdCtrls, ExtCtrls,
  OsFont;

type
  TfrmMaintainGroups = class(TForm)
    lvGroups: TListView;
    ToolBar: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    Sep1: TToolButton;
    tbClose: TToolButton;
    Sep2: TToolButton;
    tbHelp: TToolButton;
    pDeleted: TPanel;
    cbCompleted: TCheckBox;
    btnAddJob: TButton;
    btnOK: TButton;
    procedure FormCreate(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure lvGroupsDblClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure cbCompletedClick(Sender: TObject);
    procedure lvGroupsColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvGroupsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvGroupsKeyPress(Sender: TObject; var Key: Char);
  private
    SortCol : integer;
    FormType: TGroupType;
    FDoSelect: Boolean;

    CurrentSearchKey: Shortstring;
    LastSearchTime: TDateTime;

    function DeleteGroupItem(LRN: Integer): boolean;
    function DeleteClientType(LRN: Integer): boolean;
    function DeleteJob(AJob: pJob_Heading_Rec): Boolean;
    procedure RefreshList(SelLRN: integer = 0);
    procedure SetDoSelect(const Value: Boolean);
    function DeleteMultipleGroups: boolean;
    function DeleteMultipleJobs: Boolean;
    function DeleteMultipleClientTypes: boolean;
    property DoSelect: Boolean read FDoSelect write SetDoSelect;
    procedure SetSortColumn(Value: Integer);
  protected
    procedure UpdateActions; override;
  public
    function Execute : boolean;
  end;



  function MaintainGroups : boolean;
  function MaintainClientTypes : boolean;
  function MaintainJobHeadings: boolean;

  function PickJob(var JobCode: string; ShowCompletedCB: Boolean = false;
    MultiSelect: Boolean = false; ShowAddButton: boolean = true): Boolean;

implementation

uses
CodingFormCommands,
UpdateMF,
imagesfrm,
Globals,stDateSt,stDate, LogUtil, ErrorMoreFrm, YesNoDlg, Admin32, BKHelp,
  bkXPThemes;

const
  C_Code = 0;
  C_Name = 1;
  C_Complete = 2;

{$R *.dfm}

procedure TfrmMaintainGroups.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  Self.ShowHint := INI_ShowFormHints;
  FormType := ftGroups;
end;

procedure TfrmMaintainGroups.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  i: Integer;
begin
  Handled := true;
  case Msg.CharCode of
    VK_INSERT : tbNew.click;
    VK_DELETE : tbDelete.click;
    VK_RETURN : if doSelect then
                   Modalresult := mrOk
                else
                   tbEdit.click;
    VK_ESCAPE : tbClose.click;
    65        : if (GetKeyState(VK_CONTROL) < 0) then //Ctrl-A Select All
                begin
                  for i := 0 to Pred(lvGroups.Items.Count) do
                    lvGroups.Items[i].Selected := true;
                end
                else
                  handled := false;
  else
    Handled := false;
  end;
end;

procedure TfrmMaintainGroups.FormShow(Sender: TObject);
begin
   if (lvGroups.Items.Count > 0)
   and (not assigned(LVGroups.Selected)) then begin
      //highlight the top item
      lvGroups.Items[0].Selected := True;
   end;
   LVGroups.SetFocus;
end;

procedure TfrmMaintainGroups.lvGroupsColumnClick(Sender: TObject;
  Column: TListColumn);
begin
   SetSortColumn(Column.Index);
end;

procedure TfrmMaintainGroups.lvGroupsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);

  
function CompareInt(I1,I2 : Integer): Integer;
{ compare two integers, return -1, 0 and 1 for I1<I2, I1=I2 and I1>I2 resp.}
asm
  sub eax, edx
end;


begin
    case SortCol of
    C_Code     : Compare := CompareText(Item1.Caption,Item2.Caption);
    C_Name     : Compare := CompareText(Item1.SubItems[0],Item2.SubItems[0]);
    C_Complete : Compare := CompareInt(
                      integer(Item1.SubItems.Objects[1]),
                      integer(Item2.SubItems.Objects[1])
                    )
    end;
    //compare := compare * SortDir
end;

procedure TfrmMaintainGroups.lvGroupsDblClick(Sender: TObject);
begin
  if DoSelect then
     modalresult := mrOK
  else
     tbEdit.Click;
end;

procedure TfrmMaintainGroups.lvGroupsKeyPress(Sender: TObject; var Key: Char);
var SaveSearchKey: Shortstring;
    ThisSreachTime: tDateTime;
const
   TypeAheadTimeout = 1.0 / SecsPerDay; // 1 sec

    procedure DoNewSearch;
    var StartIndex: Integer;
        Index: Integer;
        Looped: Boolean;
    begin
       Key := #0;//While we are here..
       if lvGroups.SelCount > 0 then
          StartIndex := lvGroups.Selected.Index
       else
           StartIndex := 0;
       Index := StartIndex;
       Looped := False;
       repeat
          if Index >= lvGroups.Items.Count then begin
             Index := 0;
             Looped := True;
          end;
          if Pos(CurrentSearchKey, UpperCase(lvGroups.Items[Index].SubItems[Pred(SortCol)] )) = 1 then begin
             if (Length(CurrentSearchKey) = 1)
             and (Index = StartIndex) then begin
                if Looped then
                   Exit;
             end else begin
                lvGroups.Selected := nil;
                lvGroups.Selected := lvGroups.Items[Index];
                Exit;
             end;
          end;

          Inc(Index);
       until Index = StartIndex;
    end;

begin
   case integer(key) of
    VK_RETURN : if DoSelect then
             ModalResult := mrOK
           else
             tbEdit.Click;

    VK_ESCAPE : ModalResult := mrCancel;
    VK_INSERT : tbNewClick(nil);
    else begin
       if SortCol = 0 then
          Exit; // works natively

       ThisSreachTime := Now;
       if (LastSearchTime > 0)
       and ((ThisSreachTime - LastSearchTime) > TypeAheadTimeout) then
       CurrentSearchKey := ''; // Too Old

       SaveSearchKey := CurrentSearchKey;
       LastSearchTime := ThisSreachTime;

       if ( ( Key = #8 )
       and ( CurrentSearchKey[0] > #0) ) then Begin
         CurrentSearchKey[ 0 ] := Pred( CurrentSearchKey[0] );
       end
       else
       if Upcase(key) = SaveSearchKey then begin
          DoNewSearch; // Same key.. Just move on..
       end else
       if Key in [ #32..#126 ] then
       Begin
          CurrentSearchKey := CurrentSearchKey + UpCase( Key );
       end;
       if CurrentSearchKey <> SaveSearchKey then begin
          DoNewSearch;
       end;
    end;

   end;
end;

procedure TfrmMaintainGroups.tbCloseClick(Sender: TObject);
begin
  Close;
end;


procedure TfrmMaintainGroups.tbDeleteClick(Sender: TObject);
begin
  if lvGroups.Selected <> nil then begin
    case FormType of
    ftGroups :
      begin
        if lvGroups.SelCount > 1 then
        begin
          if DeleteMultipleGroups then
            RefreshList;
        end
        else
        begin
         if DeleteGroupItem(Integer(lvGroups.Selected.Data)) then
            RefreshList;
        end;
      end;
    ftClientTypes:
      begin
        if lvGroups.SelCount > 1 then
        begin
          if DeleteMultipleClientTypes then
            RefreshList;
        end
        else
        begin
         if DeleteClientType(Integer(lvGroups.Selected.Data)) then
            RefreshList;
        end;
      end;
    ftJobs:
      begin
        if lvGroups.SelCount > 1 then
        begin
          if DeleteMultipleJobs then
            RefreshList;
        end
        else
        begin
          if DeleteJob(pJob_Heading_Rec(lvGroups.Selected.Data)) then
            RefreshList;
        end;
      end;
    end;
  end;
end;

procedure TfrmMaintainGroups.tbEditClick(Sender: TObject);
var
 wasLRN: Integer;
begin
  if lvGroups.Selected <> nil then begin
    WasLRN := Integer(lvGroups.Selected.Data);
    case FormType of
       ftGroups: EditGroup(wasLRN);
       ftClientTypes: EditClientType(wasLRN);
       ftJobs: EditJobHeading(LVGroups.Selected.Caption);
    end;
    RefreshList(wasLRN) ;  {must reload because the admin object was freed and recreated}
  end;
end;

procedure TfrmMaintainGroups.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

procedure TfrmMaintainGroups.tbNewClick(Sender: TObject);
var NewLRN: integer;
begin
   case FormType of
      ftGroups      : NewLRN := AddGroup;
      ftClientTypes : NewLRN := AddClientType;
      ftJobs        : NewLRN := AddJobHeading;
      else NewLRN := 0; // Keep the compiler happy
   end;
   if NewLRN <> 0 then
      RefreshList(NewLRN);
end;


procedure TfrmMaintainGroups.UpdateActions;
begin
  inherited;
  if assigned(lvGroups.Selected) then begin
     tbEdit.Enabled := True;
     tbDelete.Enabled := True;
  end else begin
     tbEdit.Enabled := False;
     tbDelete.Enabled := False;
  end;
end;

procedure TfrmMaintainGroups.cbCompletedClick(Sender: TObject);
var lSel: integer;
begin
   if cbCompleted.Checked then begin
      // Add the Completed Column
      lvGroups.Columns[C_Name].Width :=
         lvGroups.Width -
         lvGroups.Columns[C_Code].Width -
         155;
      lvGroups.Columns[C_Complete].Width := 150;
   end else begin
      // Remove the Completed Column
      lvGroups.Columns[C_Complete].Width := 0;
   end;
   lsel := 0;
   if assigned(lvGroups.Selected) then
      lsel := integer(lvGroups.Selected.Data);
   RefreshList(lsel);
end;

function TfrmMaintainGroups.DeleteClientType(LRN: Integer): boolean;
const
   ThisMethodName = 'TfrmMaintainGroups.DeleteItem';
var
  pu: pClient_Type_Rec;
begin
  Result := false;

  if LoadAdminSystem(true, ThisMethodName ) then begin
     pu := AdminSystem.fdSystem_Client_Type_List.FindLRN(LRN);
     if not Assigned(pu) then begin
        UnlockAdmin;
        Result := True; // I am deleting...
        exit;
     end;

     {delete from list}
     if AskYesNo('Delete Client Type','OK to delete client type '+pu^.ctName+'?',DLG_NO,0)= DLG_YES then begin
        AdminSystem.fdSystem_Client_Type_List.DelFreeItem(pu);
        SaveAdminSystem;
        result := true;
        LogUtil.LogMsg(lmDebug,'DeleteClientType','User Deleted Client Type '+Name);
     end else
         UnlockAdmin;
  end else
     HelpfulErrorMsg('Could not update Client Type Details at this time. Admin System unavailable.',0);
end;

function TfrmMaintainGroups.DeleteMultipleClientTypes: boolean;
const
   ThisMethodName = 'TfrmMaintainItem.DeleteMultipleClientTypes';
var
  i: Integer;
  pClientType: pClient_Type_Rec;
  ClientTypeLRN: Integer;
begin
  Result := false;
  if AskYesNo('Delete Client Types?','You have selected '+inttostr(lvGroups.SelCount)+' client types to DELETE.  Please confirm this is correct.',DLG_NO,0) <> DLG_YES then
    exit;

  for i := 0 to Pred(lvGroups.items.Count) do
  begin
    if lvGroups.Items[i].Selected then
    begin
      if LoadAdminSystem(true, ThisMethodName ) then
      begin
        ClientTypeLRN := Integer(lvGroups.Items[i].Data);
        pClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(ClientTypeLRN);
        if not Assigned(pClientType) then
        begin
          UnLockAdmin;
          Continue;
        end;
        AdminSystem.fdSystem_Client_Type_List.DelFreeItem(pClientType);
        SaveAdminSystem;
        Result := true;
        LogUtil.LogMsg(lmDebug,'DeleteClientType','User Deleted Client Type ' + Name);
      end
      else
        HelpfulErrorMsg('Could not update Group Details at this time. Admin System unavailable.',0);
    end;
  end;
end;

function TfrmMaintainGroups.DeleteGroupItem(LRN: Integer): boolean;
const
   ThisMethodName = 'TfrmMaintainItem.DeleteGroupItem';
var
  pu : pGroup_Rec;
begin
  Result := false;
  if LoadAdminSystem(true, ThisMethodName ) then begin
     pu := AdminSystem.fdSystem_Group_List.FindLRN(LRN);
     if not Assigned(pu) then begin
        Result := True;
        UnlockAdmin;
     end else begin
        if AskYesNo('Delete Group','OK to delete group '+pu^.grName+'?',DLG_NO,0) = DLG_YES then begin
           AdminSystem.fdSystem_Group_List.DelFreeItem(pu);
           SaveAdminSystem;
           Result := true;
           LogUtil.LogMsg(lmDebug,'DeleteGroup','User Deleted Group '+Name);
        end else
           UnlockAdmin;
     end;

  end else
     HelpfulErrorMsg('Could not update Group Details at this time. Admin System unavailable.',0);
end;

function TfrmMaintainGroups.DeleteMultipleGroups: boolean;
const
   ThisMethodName = 'TfrmMaintainItem.DeleteMultipleGroups';
var
  i: Integer;
  pGroupRec: pGroup_rec;
  GroupLRN: Integer;
begin
  Result := false;
  if AskYesNo('Delete Groups?','You have selected '+inttostr(lvGroups.SelCount)+' groups to DELETE.  Please confirm this is correct.',DLG_NO,0) <> DLG_YES then
    exit;

  for i := 0 to Pred(lvGroups.items.Count) do
  begin
    if lvGroups.Items[i].Selected then
    begin
      if LoadAdminSystem(true, ThisMethodName ) then
      begin
        GroupLRN := Integer(lvGroups.Items[i].Data);
        pGroupRec := AdminSystem.fdSystem_Group_List.FindLRN(GroupLRN);
        if not Assigned(pGroupRec) then
        begin
          UnLockAdmin;
          Continue;
        end;
        AdminSystem.fdSystem_Group_List.DelFreeItem(pGroupRec);
        SaveAdminSystem;
        Result := true;
        LogUtil.LogMsg(lmDebug,'DeleteGroup','User Deleted Group '+Name);
      end
      else
        HelpfulErrorMsg('Could not update Group Details at this time. Admin System unavailable.',0);
    end;
  end;
end;

function TfrmMaintainGroups.DeleteJob(AJob: pJob_Heading_Rec): Boolean;
var S: string;
begin
   Result := False;
   if not Assigned(AJob) then
      exit; // Nothing to delete
   S := AJob.jhCode;
   if AJob.jhHeading > '' then
      S := S + ', ' + AJob.jhHeading;

   if AskYesNo('Delete Job','OK to delete job: '+ s + ' ?',DLG_NO,0)= DLG_YES then begin
      LogUtil.LogMsg(lmDebug,'DeleteJob','User Deleted Job '+ S);
      MyClient.clJobs.DelFreeItem(AJob);
      Result := True;
   end;
end;

function TfrmMaintainGroups.DeleteMultipleJobs: Boolean;
var
  I: Integer;
  pJob: pJob_Heading_Rec;
begin
  Result := False;
  if AskYesNo('Delete Jobs?','You have selected '+inttostr(lvGroups.SelCount)+' jobs to DELETE.  Please confirm this is correct.',DLG_NO,0) <> DLG_YES then
    exit;

  for I := 0 to lvGroups.Items.Count - 1 do
  begin
    if lvGroups.Items[i].Selected then
    begin
      pJob := pJob_Heading_Rec(lvGroups.Items[i].Data);
      MyClient.clJobs.DelFreeItem(pJob);
      Result := True;
    end;
  end;
end;


function TfrmMaintainGroups.Execute: boolean;
begin
   Result := ShowModal = mrOK;
end;

procedure TfrmMaintainGroups.RefreshList(SelLRN: integer = 0);
var
   NewItem: TListItem;
   Group: pGroup_Rec;
   ClientType: pClient_Type_Rec;
   Job: pJob_Heading_Rec;
   i: integer;
begin
   lvGroups.Items.beginUpdate;
   try
     lvGroups.Items.Clear;

     case FormType of
     ftGroups : begin
       if not RefreshAdmin then exit;
       with AdminSystem, fdSystem_Group_List do
       for i := 0 to Pred(itemCount) do
       begin
          Group := Group_At(i);
          NewItem := lvGroups.Items.Add;
          NewItem.Imageindex := -1;
          NewItem.Caption := Group.grName;
          NewItem.SubItems.Add(Group.grName);
          NewItem.Data := pointer(Group.grLRN);
       end;
     end;
     ftClientTypes : begin
       if not RefreshAdmin then exit;
       with AdminSystem, fdSystem_Client_Type_List do
       for i := 0 to Pred(itemCount) do begin
          ClientType := Client_Type_At(i);
          NewItem := lvGroups.Items.Add;
          NewItem.Imageindex := -1;
          NewItem.Caption := ClientType.ctName;
          NewItem.SubItems.Add(ClientType.ctName);
          NewItem.Data := pointer(ClientType.ctLRN);
       end;
     end;
     ftJobs : begin
        with MyClient.clJobs do
           for i := 0 to Pred(itemCount) do begin
              Job := Job_At(I);
              if cbCompleted.Checked
              or (Job.jhDate_Completed = 0) then begin
                 NewItem := lvGroups.Items.Add;
                 NewItem.Imageindex := -1;
                 NewItem.Caption := Job.jhCode;
                 NewItem.Data := Job;
                 NewItem.SubItems.Add(Job.jhHeading);
                 if Job.jhDate_Completed <> 0 then
                    NewItem.SubItems.AddObject(
                        //stDateToDateString( 'dd nnn yyyy',  Job.jhDate_Completed, true),
                        'Yes',
                        TObject(Job.jhDate_Completed)
                    )
                 else
                     NewItem.SubItems.AddObject('',TObject(0));
              end;
           end;
     end;
     end;
   finally
      lvGroups.items.EndUpdate;
   end;
   if SelLRN <> 0 then begin
      lvGroups.Selected := lvGroups.FindData (0,pointer(SelLRN),true,true);
   end;
end;

procedure TfrmMaintainGroups.SetDoSelect(const Value: Boolean);
begin
  FDoSelect := Value;
end;

procedure TfrmMaintainGroups.SetSortColumn(Value: Integer);
var I: integer;
begin
  SortCol := value;
   with lvGroups do begin
      for i := 0 to Pred( Columns.Count ) do
         if ( i = SortCol ) then
            Columns[i].ImageIndex := MAINTAIN_COLSORT_BMP  //Triangle
         else
            Columns[i].ImageIndex := -1; //Blank
      AlphaSort;
   end;
   CurrentSearchKey := '';
end;

function MaintainGroups : boolean;
var
  MyDlg : TfrmMaintainGroups;
begin
  result := false;
  if not Assigned( AdminSystem) then exit;

  MyDlg := TfrmMaintainGroups.Create(Application.MainForm);
  try

    BKHelpSetUp(MyDlg, BKH_Groups);
    MyDlg.FormType := ftGroups;
    MyDlg.lvGroups.Columns[C_Code].Width := 0;
    MyDlg.lvGroups.Columns[C_Complete].Width := 0;
    MyDlg.Caption := 'Maintain Groups';
    MyDlg.RefreshList;
    MyDlg.SetSortColumn(C_name);
     
    MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

function MaintainClientTypes : boolean;
var
  MyDlg : TfrmMaintainGroups;
begin
  result := false;
  if not Assigned( AdminSystem) then exit;

  MyDlg := TfrmMaintainGroups.Create(Application.MainForm);
  try

    BKHelpSetUp(MyDlg, BKH_Client_Types);
    MyDlg.FormType := ftClientTypes;
    MyDlg.lvGroups.Columns[C_Code].Width := 0;
    MyDlg.lvGroups.Columns[C_Complete].Width := 0;
    MyDlg.Caption := 'Maintain Client Types';
    MyDlg.tbNew.Hint := 'Add a new Client Type';
    MyDlg.tbEdit.Hint := 'Edit the name for the selected Client Type';
    MyDlg.tbDelete.Hint := 'Delete the selected Client Type';

    MyDlg.RefreshList;
    MyDlg.SetSortColumn(C_name);
    MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

function MaintainJobHeadings: boolean;
var
  MyDlg : TfrmMaintainGroups;
begin
  result := false;
  if not Assigned(MyClient) then
     exit;

  MyDlg := TfrmMaintainGroups.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Jobs);
    MyDlg.FormType := ftJobs;
    MyDlg.Caption := 'Maintain Jobs';
    MyDlg.PDeleted.Visible := True;
    MyDlg.cbCompleted.Visible := True;
    MyDlg.lvGroups.Columns[C_Code].Width := 150;
    MyDlg.lvGroups.Columns[C_Complete].Width := 0;
    MyDlg.tbNew.Hint := 'Add a new Job';
    MyDlg.tbEdit.Hint := 'Edit the Code, Name and Completed for the selected Job';
    MyDlg.tbDelete.Hint := 'Delete the selected Job';
    MyDlg.RefreshList;
    MyDlg.SetSortColumn(C_Code);

    MyDlg.Execute;
  finally
    MyDlg.Free;
  end;
end;

function PickJob(var JobCode: string; ShowCompletedCB: Boolean = false;
  MultiSelect: Boolean = false; ShowAddButton: boolean = true): Boolean;
var
  MyDlg: TfrmMaintainGroups;
  JobList: TStringList;
  ItemIndex: Integer;
begin
  //Returns a tab seperated list of job codes

  Result := false;
  if not Assigned(MyClient) then
     exit;

  MyDlg := TfrmMaintainGroups.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Jobs);
    MyDlg.FormType := ftJobs;
    MyDlg.ToolBar.Visible := False;
    MyDlg.DoSelect := true;
    MyDlg.PDeleted.Visible := True;
    MyDlg.btnAddJob.Visible := ShowAddButton;
    MyDlg.Caption := 'Select Job';
    MyDlg.lvGroups.Columns[C_Code].Width := 150;
    MyDlg.lvGroups.Columns[C_Complete].Width := 0;
    MyDlg.cbCompleted.Visible := ShowCompletedCB;
    MyDlg.lvGroups.MultiSelect := MultiSelect;
    MyDlg.btnOK.Visible := True;
    MyDlg.RefreshList(Integer(MyClient.clJobs.FindCode(JobCode)));

    MyDlg.SetSortColumn(UserINI_Job_Lookup_Sort_Column);

    if MyDlg.Execute then
    begin
      if Assigned(MyDlg.lvGroups.Selected) then
      begin
        if MultiSelect then
        begin
          //use list here, even if only one is selected, because caller will
          //be expecting a seperated list, and this escapes spaces correctly
          JobList := TStringList.Create;
          try
            JobList.Delimiter := #9;
            for ItemIndex := 0 to MyDlg.lvGroups.Items.Count - 1 do
            begin
              if MyDlg.lvGroups.Items[ItemIndex].Selected then
                JobList.Add(MyDlg.lvGroups.Items[ItemIndex].Caption);
            end;
            JobCode := JobList.DelimitedText;
          finally
            JobList.Free;
          end;
        end
        else
        begin
          JobCode := MyDlg.lvGroups.Selected.Caption
        end;
        Result := True;
      end;
    end;
    UserINI_Job_Lookup_Sort_Column := MyDlg.SortCol;
  finally
    MyDlg.Free;
  end;
end;



end.
