unit ToDoHandler;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
  Forms, ToDoListUnit, SyDefs, Controls, bkConst, Classes;

const
  ToDoMsg_ManualCodingReport = 'Coding Report sent for %s to %s on %s';
  ToDoMsg_Checkout           = 'File sent on %s';
  ToDoMsg_ScheduledReport    = 'Scheduled Report sent via %s for %s to %s on %s';
  ToDoMsg_ManualECoding      = bkConst.ECodingDisplayName + ' file sent for %s to %s on %s';
  ToDoMsg_Acclipse           = bkConst.WebXDisplayName + ' file sent for %s to %s on %s';
  ToDoMsg_Webnotes           = bkConst.WebNotesName + ' transactions sent for %s to %s on %s';
  ToDoMsg_QueryEmail         = 'Query Email sent for %s to %s on %s';
  ToDoMsg_CheckIn            = 'File updated on %s';

function  MaintainToDoItems( ClientCode : string; ClosingClient : boolean; OpenOnNotesPage : boolean = false) : boolean;
function  AddToDoForMultipleClients( ClientCodes: TStringList): boolean;
procedure AddAutomaticToDoItem( ClientCode : string; TaskType: Integer; Description : string; RemDate : integer = 0; FileNumber: Integer = 0; RefreshAdminSystem: Boolean = false); overload;
procedure AddAutomaticToDoItem( pCFRec : pClient_File_Rec; TaskType: Integer;  Description : string; RemDate : integer = 0; FileNumber: Integer = 0; RefreshAdminSystem: Boolean = false); overload;
procedure SyncCFRecWithToDoList( sysClientRec : pClient_File_Rec; aToDoList : TClientToDoList); overload;
procedure CloseCheckOutTask(pCFRec : pClient_File_Rec);
procedure CloseExportTask(ClientCode: string; TaskType: Integer; FileNumber: Integer);

//******************************************************************************
implementation
uses
  Admin32,
  AdminNotesForClient,
  InfoMorefrm,
  StDate, SysUtils,
  TasksFrm,
  ClientHomepageFrm,
  Globals, SysObj32, cfList32, ErrorMoreFrm;

procedure SyncCFRecWithToDoList( sysClientRec : pClient_File_Rec; aToDoList : TClientToDoList); overload;
//loads the to-do list can updates the cached information in the admin system
var
  NextItem     : pClientToDoItem;
begin
  sysClientRec^.cfPending_ToDo_Count := aToDoList.PendingCount;

  NextItem := aToDoList.GetNextItemDue;
  if Assigned( NextItem) then
  begin
    sysClientRec^.cfNext_ToDo_Desc     := NextItem^.tdDescription;
    sysClientRec^.cfNext_ToDo_Rem_Date := NextItem^.tdReminderDate;
  end
  else
  begin
    sysClientRec^.cfNext_ToDo_Desc     := '';
    sysClientRec^.cfNext_ToDo_Rem_Date := 0;

  end;

end;

procedure SyncAdminWithToDoList( ClientCode : string; aToDoList : TClientToDoList); overload;
//loads the to-do list can updates the cached information in the admin system
var
  sysClientRec : pClient_File_Rec;
begin
  Admin32.LoadAdminSystem( true, 'SyncAdminWithToDoList [' + ClientCode + ']');
  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  if not Assigned( sysClientRec) then
  begin
    Admin32.UnlockAdmin;
    Exit;
  end;

  SyncCFRecWithToDoList( sysClientRec, aToDoList);

  Admin32.SaveAdminSystem;
  RefreshHomepage([HPR_Tasks]);
end;

function AddToDoForMultipleClients( ClientCodes: TStringList): boolean;
var
  dlg: TfrmTasks;
  NewToDoList:  TClientToDoList;
  ClientToDoList: TClientToDoList;
  ClientCode: string;
  TemplateItem : pClientToDoItem;
  NewItem : pClientToDoItem;
  I: Integer;
  sysClientRec: pClient_File_Rec;
  ClientLRN: Integer;
begin
  Result := false;
  if not Assigned(ClientCodes) then
    Exit;
    
  dlg := TfrmTasks.Create(Application.mainForm);
  try
    //Set up the dialog without the controls that don't apply to multiple edits
    dlg.btnDelete.Visible := false;
    dlg.btnReport.Visible := false;
    dlg.chkShowClosed.Visible := false;
    dlg.tsNotes.TabVisible := false;
    dlg.lblClientName.Caption := Format('Adding Tasks for %d clients', [ClientCodes.Count]);
    //give the form an empty ToDoList
    NewToDoList := TClientToDoList.Create;
    try
      dlg.ToDoList := NewToDoList;
      dlg.LoadToDoList;
      //Get the user to add the new tassk
      if dlg.ShowModal = mrOk then
      begin
        Result := true;
        //Copy the tasks to each of the clients selected
        for ClientCode in ClientCodes do
        begin
          //Load the client ToDoList
          sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
          if not Assigned( sysClientRec) then
            Continue;

          ClientLRN := sysClientRec^.cfLRN;
          ClientToDoList := TClientToDoList.Create(ClientLRN);
          try
            for I := 0 to NewToDoList.Count - 1 do
            begin
              TemplateItem := NewToDoList[i];
              //Copy to a new item, otherwise the existing item is Freed when the Client list is destroyed
              NewItem := ClientToDoList.AddToDoItem;
              NewItem.tdDescription := TemplateItem.tdDescription;
              NewItem.tdReminderDate := TemplateItem.tdReminderDate;
              NewItem.tdEntered_By   := TemplateItem.tdEntered_By;
              NewItem.tdDate_Entered := TemplateItem.tdDate_Entered;
              NewItem.tdTime_Entered := TemplateItem.tdTime_Entered;
              NewItem.tdTemp_Edited  := TemplateItem.tdTemp_Edited;
              NewItem.tdTemp_Deleted := TemplateItem.tdTemp_Deleted;
              NewItem.tdIs_Completed := TemplateItem.tdIs_Completed;
              NewItem.tdDate_Completed := TemplateItem.tdDate_Completed;
            end;
            ClientToDoList.SaveToFile;
            SyncAdminWithToDoList( ClientCode, ClientToDoList);
          finally
            ClientToDoList.Free;
          end;
          
        end;
      end;
    finally
      NewToDoList.Free;
    end;
  finally
    dlg.Free;
  end;
end;

function MaintainToDoItems( ClientCode : string; ClosingClient : boolean; OpenOnNotesPage : boolean = false) : boolean;
var
  sysClientRec    : pClient_File_Rec;
  ClientLRN       : integer;
  ClientsToDoList : TClientToDoList;
  OldNotes        : string;
  NewNotes        : string;
begin
  result := false;
  RefreshAdmin;

  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  if not Assigned( sysClientRec) then
  begin
    HelpfulErrorMsg('Code '+ClientCode+' no longer exists in the admin system.',0);
    Exit;
  end;

  ClientLRN := sysClientRec^.cfLRN;

  with TfrmTasks.Create(Application.mainForm) do
  begin
    try
      if ClosingClient then
      begin

        Caption := 'Closing client ' + sysClientRec^.cfFile_Code + '...'
      end
      else
        Caption := 'Tasks and Comments for ' + sysClientRec^.cfFile_Code;

      lblClientName.Caption := sysClientRec^.cfFile_Code + ' : ' + sysClientRec^.cfFile_Name;
      MemNotes.Text         := GetNotesForClient( ClientLRN);
      OldNotes              := MemNotes.Text;

      //load tasks
      ClientsToDoList := TClientToDoList.Create( ClientLRN);
      try
        //list loaded, populate grid
        ToDoList := ClientsToDoList;
        ViewMode := vmOpen;
        ClientCode := sysClientRec^.cfFile_Code;

        if OpenOnNotesPage then
          pgToDo.ActivePage := tsNotes
        else
          pgToDo.ActivePage := tsToDo;

        LoadToDoList;

        if ShowModal = mrOK then
        begin
          //save tasks
          ClientsToDoList.SaveToFile;
          //save notes, if changed
          NewNotes := Trim( MemNotes.Text);
          if NewNotes <> OldNotes then
            UpdateNotesForClient( ClientLRN, NewNotes);

          //update next item in client rec
          Admin32.LoadAdminSystem( true, 'SyncAdminWithToDoList [' + ClientCode + ']');
          sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
          if not Assigned( sysClientRec) then
          begin
            Admin32.UnlockAdmin;
            Exit;
          end;

          SyncCFRecWithToDoList( sysClientRec, ClientsToDoList);
          sysClientRec^.cfHas_Client_Notes := NewNotes <> '';

          Admin32.SaveAdminSystem;
          RefreshHomepage([HPR_Tasks]);
          Result := True;
        end;
      finally
        ToDoList.Free;
      end;
    finally
      Free;
    end;
  end;
end;

procedure AddAutomaticToDoItem( ClientCode : string; TaskType: Integer; Description : string; RemDate : integer = 0; FileNumber: Integer = 0; RefreshAdminSystem: Boolean = false); overload;
//this routine reloads the admin system before synchronising to make sure the
//code exists, it then call a version of SyncAdminWithToDoList that loads and
//saves the admin system
var
  sysClientRec : pClient_File_Rec;
begin
  if not Assigned( AdminSystem) then
    exit;

  RefreshAdmin;

  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  AddAutomaticToDoItem(sysClientRec, TaskType, Description, RemDate, FileNumber, RefreshAdminSystem);
end;

procedure AddAutomaticToDoItem( pCFRec : pClient_File_Rec; TaskType: Integer;  Description : string; RemDate : integer = 0; FileNumber: Integer = 0; RefreshAdminSystem: Boolean = false); overload;
var
  ToDoList : TClientToDoList;
  Item     : pClientToDoItem;
  ClientLRN    : integer;
begin
  //make sure cfRec is assigned
  if not Assigned( pCFRec) then
    Exit;
  //make sure the user has selected this task type
  //only applies for auto tasks (this method could also be added for Mail Merge Tasks)
  if (TaskType >= ttyAutoMin) and (TaskType <= ttyAutoMax) and
    not AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[TaskType] then
    Exit;

  ClientLRN := pCFRec^.cfLRN;
  //add new item
  ToDoList := TClientToDoList.Create( ClientLRN);
  try
    Item := ToDoList.AddToDoItem;
    Item.tdDescription := Description;
    if ( RemDate = 0) and (TaskType >= ttyAutoMin) and (TaskType <= ttyAutoMax) and
     ( AdminSystem.fdFields.fdAutomatic_Task_Reminder_Delay[TaskType] > 0) then
      Item.tdReminderDate := StDate.CurrentDate + AdminSystem.fdFields.fdAutomatic_Task_Reminder_Delay[TaskType]
    else
      Item.tdReminderDate := RemDate;
    Item.tdEntered_By   := 'System';
    Item.tdDate_Entered := StDate.CurrentDate;
    Item.tdTime_Entered := stDate.CurrentTime;
    Item.tdTemp_Edited  := True;
    Item.tdTemp_Deleted := False;
    Item.tdTask_Type    := TaskType;
    Item.tdFile_Number  := FileNumber;
    Item.tdDate_Completed := 0;

    //lock, update, unlock
    ToDoList.SaveToFile;


    if RefreshAdminSystem then
      SyncAdminWithToDoList(pCFRec^.cfFile_Code, ToDoList)
    else
      SyncCFRecWithToDoList( pCFRec, ToDoList); //done as part of sync with admin    
  finally
    ToDoList.Free;
  end;
end;

procedure CloseCheckOutTask(pCFRec : pClient_File_Rec);
var
  ToDoList: TClientToDoList;
  Item: pClientToDoItem;
  I: Integer;
begin
  //first see if we should be closing any tasks
  if not AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[ttyCheckOut] or
    not AdminSystem.fdFields.fdAutomatic_Task_Closing_Flags[ttyCheckOut] then
    Exit;

  //Now find if there is a checkout task
  ToDoList := TClientToDoList.Create( pCFRec^.cfLRN);
  try
    //Go through list in reverse order to close most recent
    for I := ToDoList.Count - 1 downto 0 do
    begin
      Item := ToDoList.ToDoItemAt(I);
      if (Item^.tdDate_Completed <> 0) or (Item^.tdTask_Type <> ttyCheckOut) then
        Continue; //This is not the task we're looking for

      //Got the correct task
      Item^.tdDate_Completed := StDate.CurrentDate;
      Item^.tdTemp_Edited := true;
      ToDoList.SaveToFile;
      SyncAdminWithToDoList(pcfRec^.cfFile_Code, ToDoList);
      Break;
    end;
  finally
    ToDoList.Free;
  end;
end;

procedure CloseExportTask(ClientCode: string; TaskType: Integer; FileNumber: Integer);
var
  ToDoList: TClientToDoList;
  Item: pClientToDoItem;
  I: Integer;
  sysClientRec: pClient_File_Rec;
begin
  if not TaskType in [ttyExportWeb, ttyExportBNotes] then
    Exit;

  if not Assigned( AdminSystem) then
    exit;

  RefreshAdmin;

  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);

  //first see if we should be closing any tasks
  if not AdminSystem.fdFields.fdAutomatic_Task_Creation_Flags[TaskType] or
    not AdminSystem.fdFields.fdAutomatic_Task_Closing_Flags[TaskType] then
    Exit;

  ToDoList := TClientToDoList.Create(sysClientRec^.cfLRN);
  try
    for I := ToDoList.Count - 1 downto 0 do
    begin
      Item := ToDoList.ToDoItemAt(I);
      if (Item^.tdDate_Completed <> 0) or (Item^.tdTask_Type <> TaskType) then
        Continue; //task is completed or wrong type

      if Item^.tdFile_Number <> FileNumber then
        Continue; //task is open and the correct type, but for a different file

      Item^.tdDate_Completed := StDate.CurrentDate;
      Item^.tdTemp_Edited := true;
      ToDoList.SaveToFile;
      SyncAdminWithToDoList(ClientCode, ToDoList);
      Break;
    end;
  finally
    ToDoList.Free;
  end;
    
end;

end.
