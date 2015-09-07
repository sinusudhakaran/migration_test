// Used for updating groups and client types
unit EditGroupDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, sydefs, bkdefs,
  OsFont, ExtCtrls;

type
  TGroupType = (ftGroups, ftClientTypes, ftJobs);

type
  TdlgEditGroup = class(TForm)
    lblField: TLabel;
    eFullName: TEdit;
    Lcode: TLabel;
    eCode: TEdit;
    cbCompleted: TCheckBox;
    Panel1: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    Shape1: TShape;
    procedure FormCreate(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    StoredLRN : Integer;
    FormType: TGroupType;
  public
    { Public declarations }
    function Execute(Group: pGroup_Rec): Boolean; overload;
    function Execute(ClientType: pClient_Type_Rec): Boolean; overload;
    function Execute(JobHeader: pJob_Heading_Rec; DoAdd: Boolean): Boolean; overload;
  end;

var
  dlgEditGroup: TdlgEditGroup;

function EditGroup(LRN: Integer): boolean;
function EditClientType(LRN: Integer): boolean;
function EditJobHeading(Code: string): boolean;

function AddGroup: Integer;
function AddClientType: Integer;
function AddJobHeading: Integer;

implementation

uses
   bkXPThemes,
   Globals,
   sygrio,
   BKjhIO,
   StDate,
   syctio, bkhelp, admin32, ErrorMoreFrm;

{$R *.dfm}

function TdlgEditGroup.Execute(JobHeader: pJob_Heading_Rec; DoAdd: Boolean): Boolean;
begin
  Caption := 'Job Details';
  lblField.Caption := '&Job Name';
  FormType := ftJobs;
  lCode.Visible := True;
  eCode.Visible := True;
  cbCompleted.Visible := not DoAdd;
  if Assigned(JobHeader) then begin
     eFullName.Text := JobHeader.jhHeading;
     eCode.Text := JobHeader.jhCode;
     StoredLRN := Integer(JobHeader);
     cbCompleted.Checked := (JobHeader.jhDate_Completed <> 0);
  end else begin
     StoredLRN := -1;
     eFullName.Text := '';
     eCode.Text := '';
     cbCompleted.Checked := False;
  end;
  Result := ShowModal = mrOk;
end;

procedure TdlgEditGroup.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;
  StoredLRN := -1;
end;

procedure TdlgEditGroup.FormShow(Sender: TObject);
begin
   if ECode.Visible then
      ECode.SetFocus;

end;

procedure TdlgEditGroup.btnOKClick(Sender: TObject);
var
  i: Integer;
  pg: pGroup_Rec;
  pc: pClient_Type_Rec;
  pj: pJob_Heading_Rec;
  NewName,
  NewCode: string;
begin
  // disallow duplicates

  NewName := Trim(eFullName.Text);
  if (NewName = '')
  and (FormType <> ftJobs) then begin
    case FormType of
     ftGroups: HelpfulErrorMsg('Please enter a longer Group name ',0);
     ftClientTypes: HelpfulErrorMsg('Please enter a longer Client Type name ',0);
    end;
    Exit;
  end;

  NewCode := '';
  if (FormType = ftJobs) then begin
     NewCode := Trim(eCode.Text);
     if NewCode = '' then begin
        HelpfulErrorMsg('Please enter a longer Job code ',0);
        eCode.SetFocus;
        Exit;
     end;
  end;


  case FormType of
  ftGroups : begin
    for I := 0 to AdminSystem.fdSystem_Group_List.ItemCount - 1 do
    begin
      pg := Adminsystem.fdSystem_Group_List.Group_At(i);
      if (SameText(pg.grName,NewName))
      and (pg.grLRN <> StoredLRN) then
      begin
        HelpfulErrorMsg('There is already a Group named "' + eFullName.Text + '".'#13#13'Please choose a different Group name.', 0);
        exit;
      end;
    end;
  end;

  ftClientTypes :
  begin
    for I := 0 to AdminSystem.fdSystem_Client_Type_List.ItemCount - 1 do
    begin
      pc := Adminsystem.fdSystem_Client_Type_List.Client_Type_At(i);
      if (SameText(pc.ctName,NewName))
      and (pc.ctLRN <> StoredLRN) then
      begin
        HelpfulErrorMsg('There is already a Client Type named "' + eFullName.Text + '".'#13#13'Please choose a different Client Type name.', 0);
        exit;
      end;
    end;
  end;


  ftJobs: begin
      pj := MyClient.clJobs.FindCode(NewCode);
      if (pj <> nil) then
        if (integer(pj) <> StoredLRN) then begin
           HelpfulErrorMsg('There is already a Job with code "' + NewCode + '".'#13#13'Please choose a different Job code.', 0);
           eCode.SetFocus;
           exit;
        end;
  end;
  end;
  // Still Here... must be ok..
  ModalResult := mrOk;
end;

const
   CodeGap = 30;

function TdlgEditGroup.Execute(Group: pGroup_Rec): Boolean;
begin
  Caption := 'Group Details';
  lblField.Caption := '&Group Name';
  SetBounds(Left,Top,Width,Height-CodeGap);
  FormType := ftGroups;
  if Assigned(Group) then
  begin
    eFullName.Text := Group.grName;
    StoredLRN := Group.grLRN;
  end
  else
  begin
    StoredLRN := -1;
    eFullName.Text := '';
  end;
  Result := ShowModal = mrOk;
end;

function TdlgEditGroup.Execute(ClientType: pClient_Type_Rec): Boolean;
begin
  Caption := 'Client Type Details';
  lblField.Caption := '&Client Type name';
  SetBounds(Left,Top,Width,Height-CodeGap);
  FormType := ftClientTypes;
  if Assigned(ClientType) then
  begin
    eFullName.Text := ClientType.ctName;
    StoredLRN := ClientType.ctLRN;
  end
  else
  begin
    StoredLRN := -1;
    eFullName.Text := '';
  end;
  Result := ShowModal = mrOk;
end;

function EditGroup(LRN: Integer): Boolean;
const
   ThisMethodName = 'EditGroup';
var
  MyDlg       : TdlgEditGroup;
  eGroup      : pGroup_Rec;
  StoredName  : string;
  pg          : pGroup_Rec;
begin
  Result := false;

  eGroup := AdminSystem.fdSystem_Group_List.FindLRN(LRN);

  if not (Assigned(AdminSystem) and Assigned(eGroup)) Then
    exit;

  MyDlg := TdlgEditGroup.Create(Application.MainForm);
  Try
    BKHelpSetUp(MyDlg, BKH_Groups);

    If MyDlg.Execute(eGroup) then
    begin
      //get the group_rec again as the admin system may have changed in the mean time.
      eGroup := AdminSystem.fdSystem_Group_List.FindLRN(LRN);
      with MyDlg do
      begin
        StoredLRN := eGroup.grLRN;
        StoredName := eGroup.grName;

        if LoadAdminSystem(true, ThisMethodName) then
        begin
          pg := AdminSystem.fdSystem_Group_List.FindLRN(StoredLRN);
          if not Assigned(pg) then
          begin
             UnlockAdmin;
             HelpfulErrorMsg('The Group ' + StoredName + ' can no longer be found in the Admin System.', 0);
             exit;
          end;
          pg.grName := Trim(eFullName.text);
          SaveAdminSystem;
          Result := true;
        end
        else
           HelpfulErrorMsg('Could not update Group Details at this time. Admin System unavailable.', 0);
      end;
    end;
  finally
     MyDlg.Free;
  end
end;


function EditClientType(LRN: Integer): Boolean;
const
   ThisMethodName = 'EditClientType';
var
  MyDlg       : TdlgEditGroup;
  eClientType : pClient_Type_Rec;
  StoredName  : string;
  pc          : pClient_Type_Rec;
begin
  Result := false;

  eClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(LRN);

  if not (Assigned(AdminSystem) and Assigned(eClientType)) Then
    exit;

  MyDlg := TdlgEditGroup.Create(Application.MainForm);
  Try
    BKHelpSetUp(MyDlg, BKH_Client_Types);
    MyDlg.eFullName.Hint := 'Enter a description of the Client Type';

    If MyDlg.Execute(eClientType) then
    begin
      //get the group_rec again as the admin system may have changed in the mean time.
      eClientType := AdminSystem.fdSystem_Client_Type_List.FindLRN(LRN);
      with MyDlg do
      begin
        StoredLRN := eClientType.ctLRN;
        StoredName := eClientType.ctName;  

        if LoadAdminSystem(true, ThisMethodName) then
        begin
          pc := AdminSystem.fdSystem_Client_Type_List.FindLRN(StoredLRN);
          if not Assigned(pc) then
          begin
             UnlockAdmin;
             HelpfulErrorMsg('The ClientType ' + StoredName + ' can no longer be found in the Admin System.', 0);
             exit;
          end;
          pc.ctName := Trim(eFullName.text);
          SaveAdminSystem;
          Result := true;
        end
        else
           HelpfulErrorMsg('Could not update Client Type Details at this time. Admin System unavailable.', 0);
      end;
    end;
  finally
     MyDlg.Free;
  end
end;

function EditJobHeading(Code: string): boolean;
const
   ThisMethodName = 'EditJobHeading';
var
  MyDlg: TdlgEditGroup;
  eJob: pJob_Heading_Rec;

begin
  Result := false;
  if not assigned(MyClient) then
     Exit;
  eJob := Myclient.clJobs.FindCode(Code);

  if not (Assigned(eJob)) then
     Exit;

  MyDlg := TdlgEditGroup.Create(Application.Mainform);
  try
     BKHelpSetUp(MyDlg, BKH_jobs);

     if MyDlg.Execute(eJob, False) then begin
        Result := True;
        Myclient.clJobs.Delete(Ejob);
        eJob.jhHeading := Trim(MyDlg.eFullName.Text);
        eJob.jhCode := Trim(MyDlg.eCode.Text);
        // (May)Need to Re Sort
        Myclient.clJobs.Insert(Ejob);
        if MyDlg.cbCompleted.Checked then begin
           if eJob.jhDate_Completed = 0 then
              eJob.jhDate_Completed := CurrentDate;
        end else begin
           eJob.jhDate_Completed := 0;
        end;

     end;
  finally
     MyDlg.Free;
  end
end;

function AddGroup: Integer;
const
   ThisMethodName = 'AddGroup';
var
   MyDlg : TdlgEditGroup;
   pg    : pGroup_Rec;
begin
   Result := 0;
   if not Assigned(AdminSystem) then
     exit;

   MyDlg := TdlgEditGroup.Create(Application.MainForm);
   Try
      BKHelpSetUp(MyDlg, BKH_Groups);
      if MyDlg.Execute(pGroup_Rec(nil)) then begin
         with MyDlg do begin
           if LoadAdminSystem(true, ThisMethodName ) then begin
               pg := New_Group_Rec;

               if not Assigned(pg) Then begin
                  UnlockAdmin;
                  HelpfulErrorMsg('New Group cannot be created', 0);
                  exit;
               end;

               Inc(AdminSystem.fdFields.fdGroup_LRN_Counter);
               pg.grLRN := AdminSystem.fdFields.fdGroup_LRN_Counter;
               pg.grName := Trim(eFullName.text);

               AdminSystem.fdSystem_Group_List.Insert(pg);

               SaveAdminSystem;
               Result :=pg.grLRN ;
            end
            else
              HelpfulErrorMsg('Could not update Group Details at this time. Admin System unavailable.', 0);
         end;
      end;
   finally
      MyDlg.Free;
   end;
end;

function AddClientType: Integer;
const
   ThisMethodName = 'AddClientType';
var
   MyDlg : TdlgEditGroup;
   pc    : pClient_Type_Rec;
begin
   Result := 0;
   if not Assigned(AdminSystem) then
     exit;

   MyDlg := TdlgEditGroup.Create(Application.MainForm);
   Try
      MyDlg.eFullName.Hint := 'Enter a description of the Client Type';
      BKHelpSetUp(MyDlg, BKH_Client_Types);
      if MyDlg.Execute(pClient_Type_Rec(nil)) then begin
         with MyDlg do begin
            if LoadAdminSystem(true, ThisMethodName ) then begin
               pc := New_Client_Type_Rec;

               if not Assigned(pc) Then begin
                  UnlockAdmin;
                  HelpfulErrorMsg('New Client Type cannot be created', 0);
                  exit;
               end;

               Inc(AdminSystem.fdFields.fdClient_Type_LRN_Counter);
               pc.ctLRN := AdminSystem.fdFields.fdClient_Type_LRN_Counter;
               pc.ctName := Trim(eFullName.text);
               AdminSystem.fdSystem_Client_Type_List.Insert(pc);
               SaveAdminSystem;
               Result := pc.ctLRN;
            end else
              HelpfulErrorMsg('Could not update Client Type Details at this time. Admin System unavailable.', 0);
         end;
      end;
   finally
      MyDlg.Free;
   end;
end;


function AddJobHeading: Integer;
const
   ThisMethodName = 'AddJobHeading';
var
   MyDlg: TdlgEditGroup;
   NewJob: pJob_Heading_Rec;
begin
   Result := 0;
   if not Assigned(MyClient) then
      exit; // Nowhere to add, But dialog not up ?

   MyDlg := TdlgEditGroup.Create(Application.MainForm);
   try
      BKHelpSetUp(MyDlg, BKH_jobs);
      if MyDlg.Execute(pJob_Heading_Rec(nil), True) then begin
         with MyDlg do begin
           NewJob := New_Job_Heading_Rec;

           if not Assigned(NewJob) Then begin
              HelpfulErrorMsg('New Job title cannot be created', 0);
              exit;
           end;
           //newJob.jhLRN := MyClient.clJobs.NextLRN;
           NewJob.jhHeading := Trim(eFullName.Text);
           NewJob.jhCode := Trim(ECode.Text);
           if cbCompleted.Checked then
              NewJob.jhDate_Completed := CurrentDate;

           myclient.clJobs.Insert(NewJob);
           Result := Integer(NewJob);
         end
      end;
   finally
      MyDlg.Free;
   end;
end;


end.
