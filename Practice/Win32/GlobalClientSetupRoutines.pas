unit GlobalClientSetupRoutines;
//------------------------------------------------------------------------------
{
   Title:       Global Client Setup Routines

   Description: Holds the calls for routines that set clients settings for
                one or more clients.  The routines expect a list of client codes

   Author:      Matthew Hopkins       Apr 2003
                Michael Foot

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  SyDefs;

function UpdateContactDetails( var ClientCode : string) : boolean;
function AssignStaffMember( ClientCodes : string) : boolean;
function AssignGroup( ClientCodes : string) : boolean;
function AssignClientType( ClientCodes : string) : boolean;
function ConfigureScheduledReports( ClientCodes : string) : boolean;
function CodingScreenLayout( ClientCodes : string) : boolean;
function AssignPracticeContact( ClientCodes : string) : boolean;
function ChangeFinancialYear( ClientCodes : string) : boolean;

function DeleteClientFile(ClientCode : string) : boolean;
function UnlockClientFile( ClientCodes : string) : Boolean;

function DeleteProspects(ClientCodes : string; Silent: Boolean = False; KeepFiles: Boolean = False) : boolean;

function ArchiveFiles( ClientCodes : string) : boolean;
//******************************************************************************
implementation

uses
  Classes,
  ComCtrls,
  Controls,
  Dialogs,
  BKHelp,
  DirUtils,
  ECollect,
  Forms,
  sysUtils,
  Admin32,
  baObj32,
  BKConst,
  stdate,
  ChooseContactDetailsDlg,
  ClientDetailCacheObj,
  ClientReportScheduleDlg,
  clObj32,
  CodingFormConst,
  EnterPwdDlg,
  ErrorMoreFrm,
  Files,
  FinancialYearStartsDlg,
  GenUtils,
  glConst,
  Globals,
  InfoMoreFrm,
  IniFiles,
  LogUtil,
  RadioOptionsDlg,
  SelectListDlg,
  ShellUtils,
  UpdateClientDetailsDlg,
  WarningMoreFrm,
  YesNoDlg,
  BKDEFS,
  WinUtils,
  progress,
  updatemf,
  Windows,
  ToDoHandler,
  AuditMgr,
  SYAUDIT;

procedure NotSynchronizedMsg;
begin
  HelpfulInfoMsg( 'You can only update these details for clients that are part '+
                  ' of your Practice Admin System.', 0);
end;

function CodeIsMyClient( aCode : string) : boolean;
begin
  result := false;
  if Assigned( MyClient) then
    result := MyClient.clFields.clCode = aCode;
end;

procedure CompletionMsg(SelectedCount, SuccessCount, CantOpenCount : Integer; ShowMyClientMsg : boolean = false);
var
  aMsg : String;
  NotPartOfAdminCount : integer;
begin
  if ( SuccessCount = SelectedCount) then
  begin
    //all ok
    aMsg := 'New settings have been applied,  ' + inttostr( SuccessCount) + ' client(s) updated';
  end
  else
  if ( SuccessCount = 0) then
  begin
    //nothing worked
    aMsg := 'The new settings could not be applied to the selected client(s):'#13#13;

    if CantOpenCount > 0 then
      aMsg := aMsg +  IntToStr( CantOpenCount) + ' client(s) could not be opened'#13;
  end
  else
  begin
    //some files were ok, some not
    aMsg := 'New settings have been applied:'#13#13+
            IntToStr( SuccessCount) + ' client(s) updated'#13#13;

    if CantOpenCount > 0 then
      aMsg := aMsg + IntToStr( CantOpenCount) + ' client(s) could not be opened'#13;

    NotPartOfAdminCount := ( SelectedCount - SuccessCount - CantOpenCount);

    if NotPartOfAdminCount > 0 then
      aMsg := aMsg + IntToStr( NotPartOfAdminCount) +
              ' unsynchronised client(s) selected'#13;
  end;

  if ShowMyClientMsg then
    aMsg := aMsg + #13#13+ 'Note: You currently have client file ' + MyClient.clFields.clCode + ' open, '+
                           'changes have been applied but may not appear until after this file has been saved.';

  HelpfulInfoMsg( aMsg, 0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function UpdateContactDetails( var ClientCode : string) : boolean;
//only works for a single code
var
  sysClientRec : pClient_File_Rec;
  ClientLRN    : integer;
  TempClient   : TClientObj;
  Success      : boolean;
  DetailsChanged : boolean;
  ContactDetails : TContactDetailsFrm;
  UsingMyClient : boolean;
  IsProspect: Boolean;
begin
  Success := False;
  DetailsChanged := False;

  RefreshAdmin;

  sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
  if Assigned( sysClientRec) then
  begin
    IsProspect := sysClientRec^.cfClient_Type = ctProspect;
    ClientLRN := sysClientRec^.cfLRN;
    Success := false;

    UsingMyClient := false;
    if Assigned( MyClient) and ( MyClient.clFields.clCode = ClientCode) then
    begin
      UsingMyClient := true;
      TempClient    := nil;  //prevent a copy of the file from being opened
    end
    else if (not IsProspect) then
      OpenAClient( sysClientRec.cfFile_Code, TempClient, True);

    if Assigned( TempClient) then
    begin
      //update the client directly
      ContactDetails := TContactDetailsFrm.Create( Application.MainForm);
      with ContactDetails do
      begin
        try
          BKHelpSetUp(ContactDetails, BKH_Edit_client_contact_details);
          eName.Text    := TempClient.clFields.clName;
          eAddr1.text   := TempClient.clFields.clAddress_L1;
          eAddr2.text   := TempClient.clFields.clAddress_L2;
          eAddr3.text   := TempClient.clFields.clAddress_L3;
          eContact.Text := TempClient.clFields.clContact_Name;
          ePhone.text   := TempClient.clFields.clPhone_No;
          eMobile.Text  := TempClient.clFields.clMobile_No;
          eSal.Text     := TempClient.clFields.clSalutation;
          eFax.text     := TempClient.clFields.clFax_No;
          eMail.Text    := TempClient.clFields.clClient_EMail_Address;
          UsesWebNotes  := (TempClient.clFields.clWeb_Export_Format = wfWebNotes);

          if ShowModal = mrOK then
          begin
            eMail.Text := Trim( eMail.Text);

            with TempClient.clFields do
            begin
              DetailsChanged := (
                        ( clname <> ename.text) or
                        ( clAddress_l1 <> eAddr1.text) or
                        ( clAddress_l2 <> eAddr2.Text) or
                        ( clAddress_l3 <> eAddr3.text) or
                        ( clContact_name <> econtact.text) or
                        ( clPhone_No <> ePhone.text) or
                        ( clMobile_No <> eMobile.text) or
                        ( clSalutation <> eSal.text) or
                        ( clFax_No <> eFax.text) or
                        ( clClient_EMail_Address <> eMail.text)
                        );
            end;
            //update fields
            if DetailsChanged then
            begin
              TempClient.clFields.clContact_Details_Edit_Date := StDate.CurrentDate;
              TempClient.clFields.clContact_Details_Edit_Time := StDate.CurrentTime;
            end;
            TempClient.clFields.clname               := ename.text;
            TempClient.clFields.clAddress_l1         := eAddr1.text;
            TempClient.clFields.clAddress_l2         := eAddr2.Text;
            TempClient.clFields.clAddress_l3         := eAddr3.text;
            TempClient.clFields.clContact_name       := econtact.text;
            TempClient.clFields.clPhone_No           := ePhone.text;
            TempClient.clFields.clMobile_No          := eMobile.text;
            TempClient.clFields.clSalutation         := eSal.Text;
            TempClient.clFields.clFax_No             := eFax.text;
            TempClient.clFields.clClient_EMail_Address := eMail.text;
          end;

          //*** Flag Audit ***
          TempClient.ClientAuditMgr.FlagAudit(arClientFiles);

        finally
          Free;
        end;
      end;
      CloseAClient( TempClient);
      Success := DetailsChanged;
    end
    else
    begin
      //update the cached information
      sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
      ContactDetails := TContactDetailsFrm.Create( Application.MainForm);
      with ContactDetails do
      begin
        try
          ClientType := sysClientRec^.cfClient_Type;
          cmbUsers.Visible := False;
          lblUser.Visible := False;
          BKHelpSetUp(ContactDetails, BKH_Edit_client_contact_details);
          ClientDetailsCache.Clear;
          ClientDetailsCache.Load( ClientLRN);

          if IsProspect then
            eCode.Text := ClientDetailsCache.Code;

          eName.Text    := ClientDetailsCache.Name;
          eAddr1.text   := ClientDetailsCache.Address_L1;
          eAddr2.text   := ClientDetailsCache.Address_L2;
          eAddr3.text   := ClientDetailsCache.Address_L3;
          eContact.Text := ClientDetailsCache.Contact_Name;
          ePhone.text   := ClientDetailsCache.Phone_No;
          eMobile.text  := ClientDetailsCache.Mobile_No;
          eSal.Text     := ClientDetailsCache.Salutation;
          eFax.text     := ClientDetailsCache.Fax_No;
          eMail.Text    := ClientDetailsCache.EMail_Address;

          if ShowModal = mrOK then
          begin
            eMail.Text := Trim( Email.Text);

            //reload the sys rec so we can set the changed field
            DetailsChanged := (
                        ( IsProspect and (ClientDetailsCache.Code <> ecode.text)) or
                        ( ClientDetailsCache.Name <> ename.text) or
                        ( ClientDetailsCache.Address_L1 <> eAddr1.text) or
                        ( ClientDetailsCache.Address_L2 <> eAddr2.Text) or
                        ( ClientDetailsCache.Address_L3 <> eAddr3.text) or
                        ( ClientDetailsCache.Contact_Name <> econtact.text) or
                        ( ClientDetailsCache.Phone_No <> ePhone.text) or
                        ( ClientDetailsCache.Mobile_No <> eMobile.text) or
                        ( ClientDetailsCache.salutation <> eSal.text) or
                        ( ClientDetailsCache.Fax_No <> eFax.text) or
                        ( ClientDetailsCache.EMail_Address <> eMail.text)
                        );

            //update fields
            if IsProspect then
              ClientDetailsCache.Code         := eCode.Text
            else
            begin
              ClientDetailsCache.Code         := ClientCode;
              // Update client so it reflects in the client dialogs
              if Assigned(MyClient) then
              begin
                MyClient.clFields.clFax_No := eFax.Text;
                MyClient.clFields.clClient_EMail_Address := eMail.Text;
              end;
            end;
            ClientDetailsCache.Name           := ename.text;
            ClientDetailsCache.Address_L1     := eAddr1.text;
            ClientDetailsCache.Address_L2     := eAddr2.Text;
            ClientDetailsCache.Address_L3     := eAddr3.text;
            ClientDetailsCache.Contact_Name   := econtact.text;
            ClientDetailsCache.Phone_No       := ePhone.text;
            ClientDetailsCache.Mobile_No      := eMobile.text;
            ClientDetailsCache.Salutation      := eSal.text;            
            ClientDetailsCache.Fax_No         := eFax.text;
            ClientDetailsCache.EMail_Address  := eMail.text;
          end;
        finally
          Free;
        end;

        if DetailsChanged then
        begin
          ClientDetailsCache.Save( ClientLRN);
          Success := True;

          LoadAdminSystem( true, 'Update Contact Details');
          sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode( ClientCode);
          if Assigned( sysClientRec) then
          begin
            if IsProspect and (ClientDetailsCache.Code <> ClientCode) then
            begin // update client code
              AdminSystem.fdSystem_Client_File_List.Delete( sysClientRec );
              sysClientRec^.cfFile_Code := ClientDetailsCache.Code;
              AdminSystem.fdSystem_Client_File_List.Insert( sysClientRec );
              ClientCode := ClientDetailsCache.Code;
            end;
            sysClientRec^.cfFile_Name := ClientDetailsCache.Name;
            sysClientRec^.cfContact_Details_Edit_Date := StDate.CurrentDate;
            sysClientRec^.cfContact_Details_Edit_Time := StDate.CurrentTime;

            //*** Flag Audit ***
            SystemAuditMgr.FlagAudit(arSystemClientFiles);

            SaveAdminSystem;
          end
          else
            UnlockAdmin;

          if UsingMyClient then
            HelpfulInfoMsg('Note: You currently have client file ' + ClientCode + ' open, '+
                           'changes have been applied but may not appear until after this file has been saved.', 0);

        end;
      end;
    end;
  end
  else
    HelpfulErrorMsg('Code '+ClientCode+' no longer exists in the admin system.',0);
  Result := Success;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FindFirstSynchronisedClient( SelectedList : TStringList) : pClient_File_Rec;
var
  Client : pClient_File_Rec;
  i      : integer;
begin
  result := nil;
  i := 0;
  while (i < SelectedList.Count) and ( Result = nil) do
  begin
    Client := AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
    if (Assigned(Client)) and (not Client.cfForeign_File) then
      Result := Client
    else
      Inc(i);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AssignStaffMember( ClientCodes : string) : boolean;
const
  ThisMethodName = 'AssignStaffMember';
var
  SelectedList  : TStringList;
  i             : integer;
  UserLRN       : Integer;
  StoredIndex   : integer;
  User          : pUser_Rec;

  UserName : string;
  UserEmail : string;
  UserDDial : string;

  Client        : pClient_File_Rec;
  NewItem       : TListItem;

  SuccessCount  : Integer;
  CantOpenCount : Integer;
  TempClient    : TClientObj;
  UseCurrentlyOpenClient   : boolean;
  CurrentClientUpdated : boolean;

  dlgSelectList : TdlgSelectList;
begin
  result := false;
  if ClientCodes = '' then exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) then
      NotSynchronizedMsg
    else
    begin
      TempClient := nil;
      UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);
      //open the first client to get some defaults from
      if not UseCurrentlyOpenClient then
        UserLRN := Client.cfUser_Responsible   //default to the user currently
      else
        UserLRN := MyClient.clFields.clStaff_Member_LRN;

      dlgSelectList := TdlgSelectList.Create( Application.MainForm);
      try
        with dlgSelectList do
        begin
          //set up the dialog
          Caption := 'Select User';
          with lvList do
          begin
            Columns.Clear;
            Columns.Add;
            Columns.Add;
            Column[0].Width := 100;
            Column[1].Width := lvList.ClientWidth - 100;
            Column[0].Caption := 'User Code';
            Column[1].Caption := 'User Name';
          end;

          lvList.Clear;
          //load none line
          NewItem := lvList.Items.Add;
          NewItem.Caption := '';
          NewItem.SubItems.Add('Not Allocated');
          NewItem.ImageIndex := -1;

          StoredIndex := 0;

          //load admin staff with full names
          with AdminSystem.fdSystem_User_List do
          begin
            for i := 0 to Pred(itemCount) do
            begin
              User := User_At(i);

              NewItem := lvList.Items.Add;
              NewItem.Caption := User^.usCode;
              NewItem.SubItems.Add(User^.usName);
              NewItem.ImageIndex := -1;

              if (User^.usLRN = UserLRN) then
                StoredIndex := lvList.Items.Count - 1;
            end;
          end;

          if StoredIndex <> - 1 then
            lvList.ItemIndex := StoredIndex;

          if (ShowModal = mrOK) and (lvList.SelCount > 0) then
          begin
            NewItem := lvList.Selected;

            User := Globals.AdminSystem.fdSystem_User_List.FindCode(NewItem.Caption);
            if Assigned( User) then
            begin
              //must store the values as the user point will be invalid after
              //the admin system has been reloaded
              UserLRN := User^.usLRN;
              UserName := User^.usName;
              UserEmail := User^.usEMail_Address;
              UserDDial := User^.usDirect_Dial;
            end
            else
            begin
              UserLRN := 0;
              Username := '';
              UserEmail := '';
              UserDDial := '';
            end;

            //at this point we have a user LRN to assign to each of the clients
            //in the list of codes
            SuccessCount  := 0;
            CantOpenCount := 0;

            TempClient    := nil;
            for i := 0 to SelectedList.Count-1 do
            begin
              Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
              if (Assigned(Client)) then
              begin
                if Client^.cfClient_Type = ctProspect then
                begin
                  if LoadAdminSystem(True, ThisMethodName ) then
                  begin
                    Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
                    Client^.cfUser_Responsible := UserLRN;

                    //*** Flag Audit ***
                    SystemAuditMgr.FlagAudit(arSystemClientFiles);

                    SaveAdminSystem;
                    Inc(SuccessCount);
                  end
                  else
                    Inc(CantOpenCount);
                end
                else if (not Client.cfForeign_File) then
                begin
                  UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

                  if UseCurrentlyOpenClient then
                    TempClient := MyClient
                  else
                    OpenAClient(Client.cfFile_Code, TempClient, True);

                  if Assigned(TempClient) then
                  begin
                    TempClient.clFields.clStaff_Member_LRN := UserLRN;
                    TempClient.clFields.clStaff_Member_Name := UserName;
                    TempClient.clFields.clStaff_Member_EMail_Address := UserEmail;
                    TempClient.clFields.clStaff_Member_Direct_Dial   := UserDDial;

                    if not UseCurrentlyOpenClient then
                      CloseAClient(TempClient)
                    else
                    begin
                      TempClient := nil;
                      CurrentClientUpdated := true;
                    end;
                    Inc(SuccessCount);
                  end else
                  begin
                    Inc(CantOpenCount);
                  end;
                end;
              end;
            end;
            CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);

            result := ( SuccessCount > 0);
          end;
        end;
      finally
        dlgSelectList.Free;
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;

function AssignGroup( ClientCodes : string) : boolean;
const
  ThisMethodName = 'AssignGroup';
var
  SelectedList  : TStringList;
  i             : integer;
  GroupLRN      : Integer;
  StoredIndex   : integer;
  Group         : pGroup_Rec;

  GroupName : string;

  Client        : pClient_File_Rec;
  NewItem       : TListItem;

  SuccessCount  : Integer;
  CantOpenCount : Integer;
  TempClient    : TClientObj;
  UseCurrentlyOpenClient   : boolean;
  CurrentClientUpdated : boolean;

  dlgSelectList : TdlgSelectList;
begin
  result := false;
  if ClientCodes = '' then exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) then
      NotSynchronizedMsg
    else
    begin
      TempClient := nil;
      UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);
      //open the first client to get some defaults from
      if not UseCurrentlyOpenClient then
        GroupLRN := Client.cfGroup_LRN   //default to the group currently
      else
        GroupLRN := MyClient.clFields.clGroup_LRN;

      dlgSelectList := TdlgSelectList.Create( Application.Mainform);
      try
        with dlgSelectList do
        begin
          //set up the dialog
          Caption := 'Select Group';
          with lvList do
          begin
            Columns.Clear;
            Columns.Add;
            Column[0].Width := lvList.ClientWidth;
            Column[0].Caption := 'Group Name';
            ShowColumnHeaders := False;
          end;

          lvList.Clear;
          //load none line
          NewItem := lvList.Items.Add;
          NewItem.Caption := 'Not Allocated';
          NewItem.ImageIndex := -1;

          StoredIndex := 0;

          //load admin group with full names
          with AdminSystem.fdSystem_Group_List do
          begin
            for i := 0 to Pred(itemCount) do
            begin
              Group := Group_At(i);

              NewItem := lvList.Items.Add;
              NewItem.Caption := Group^.grName;
              NewItem.ImageIndex := -1;

              if (Group^.grLRN = GroupLRN) then
                StoredIndex := lvList.Items.Count - 1;
            end;
          end;

          if StoredIndex <> - 1 then
            lvList.ItemIndex := StoredIndex;

          if (ShowModal = mrOK) and (lvList.SelCount > 0) then
          begin
            NewItem := lvList.Selected;

            Group := Globals.AdminSystem.fdSystem_Group_List.FindName(NewItem.Caption);
            if Assigned( Group) then
            begin
              //must store the values as the user point will be invalid after
              //the admin system has been reloaded
              GroupLRN := Group^.grLRN;
              GroupName := Group^.grName;
            end
            else
            begin
              GroupLRN := 0;
              GroupName := '';
            end;

            //at this point we have a user LRN to assign to each of the clients
            //in the list of codes
            SuccessCount  := 0;
            CantOpenCount := 0;

            TempClient    := nil;
            for i := 0 to SelectedList.Count-1 do
            begin
              Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
              if (Assigned(Client)) then
              begin
                if (not Client.cfForeign_File) then
                begin
                  UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

                  if UseCurrentlyOpenClient then
                    TempClient := MyClient
                  else
                    OpenAClient(Client.cfFile_Code, TempClient, True);

                  if Assigned(TempClient) then
                  begin
                    TempClient.clFields.clGroup_LRN := GroupLRN;
                    TempClient.clFields.clGroup_Name := GroupName;

                    if not UseCurrentlyOpenClient then
                      CloseAClient(TempClient)
                    else
                    begin
                      TempClient := nil;
                      CurrentClientUpdated := true;
                    end;
                    Inc(SuccessCount);
                  end else
                  begin
                    Inc(CantOpenCount);
                  end;
                end;
              end;
            end;
            CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);

            result := ( SuccessCount > 0);
          end;
        end;
      finally
        dlgSelectList.Free;
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;

function AssignClientType( ClientCodes : string) : boolean;
const
  ThisMethodName = 'AssignClientType';
var
  SelectedList  : TStringList;
  i             : integer;
  ClientTypeLRN : Integer;
  StoredIndex   : integer;
  ClientType    : pClient_Type_Rec;

  ClientTypeName : string;

  Client        : pClient_File_Rec;
  NewItem       : TListItem;

  SuccessCount  : Integer;
  CantOpenCount : Integer;
  TempClient    : TClientObj;
  UseCurrentlyOpenClient   : boolean;
  CurrentClientUpdated : boolean;

  dlgSelectList : TdlgSelectList;
begin
  result := false;
  if ClientCodes = '' then exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) then
      NotSynchronizedMsg
    else
    begin
      TempClient := nil;
      UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);
      //open the first client to get some defaults from
      if not UseCurrentlyOpenClient then
        ClientTypeLRN := Client.cfClient_Type_LRN   //default to the client type currently
      else
        ClientTypeLRN := MyClient.clFields.clClient_Type_LRN;

      dlgSelectList := TdlgSelectList.Create( Application.MainForm);
      try
        with dlgSelectList do
        begin
          //set up the dialog
          Caption := 'Select Client Type';
          with lvList do
          begin
            Columns.Clear;
            Columns.Add;
            Column[0].Width := lvList.ClientWidth;
            Column[0].Caption := 'Client Type Name';
            ShowColumnHeaders := False;
          end;

          lvList.Clear;
          //load none line
          NewItem := lvList.Items.Add;
          NewItem.Caption := 'Not Allocated';
          NewItem.ImageIndex := -1;

          StoredIndex := 0;

          //load admin group with full names
          with AdminSystem.fdSystem_Client_Type_List do
          begin
            for i := 0 to Pred(itemCount) do
            begin
              ClientType := Client_Type_At(i);

              NewItem := lvList.Items.Add;
              NewItem.Caption := ClientType^.ctName;
              NewItem.ImageIndex := -1;

              if (ClientType^.ctLRN = ClientTypeLRN) then
                StoredIndex := lvList.Items.Count - 1;
            end;
          end;

          if StoredIndex <> - 1 then
            lvList.ItemIndex := StoredIndex;

          if (ShowModal = mrOK) and (lvList.SelCount > 0) then
          begin
            NewItem := lvList.Selected;

            ClientType := Globals.AdminSystem.fdSystem_Client_Type_List.FindName(NewItem.Caption);
            if Assigned( ClientType) then
            begin
              //must store the values as the user point will be invalid after
              //the admin system has been reloaded
              ClientTypeLRN := ClientType^.ctLRN;
              ClientTypeName := ClientType^.ctName;
            end
            else
            begin
              ClientTypeLRN := 0;
              ClientTypeName := '';
            end;

            //at this point we have a user LRN to assign to each of the clients
            //in the list of codes
            SuccessCount  := 0;
            CantOpenCount := 0;

            TempClient    := nil;
            for i := 0 to SelectedList.Count-1 do
            begin
              Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
              if (Assigned(Client)) then
              begin
                if (not Client.cfForeign_File) then
                begin
                  UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

                  if UseCurrentlyOpenClient then
                    TempClient := MyClient
                  else
                    OpenAClient(Client.cfFile_Code, TempClient, True);

                  if Assigned(TempClient) then
                  begin
                    TempClient.clFields.clClient_Type_LRN := ClientTypeLRN;
                    TempClient.clFields.clClient_Type_Name := ClientTypeName;

                    if not UseCurrentlyOpenClient then
                      CloseAClient(TempClient)
                    else
                    begin
                      TempClient := nil;
                      CurrentClientUpdated := true;
                    end;
                    Inc(SuccessCount);
                  end else
                  begin
                    Inc(CantOpenCount);
                  end;
                end;
              end;
            end;
            CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);

            result := ( SuccessCount > 0);
          end;
        end;
      finally
        dlgSelectList.Free;
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ConfigureScheduledReports( ClientCodes : string) : boolean;
var
  SelectedList : TStringList;
  i            : integer;
  Client : pClient_File_Rec;
  TempDlgClient   : TClientObj;
  TemplistClient   : TClientObj;
  FirstClientFields : tClient_Rec;
  FirstClientExtra : TClientExtra_Rec;
  FirstClientFileRec : tClient_File_Rec;
  SchdRepDlg        : TdlgClientReportSchedule;
  SuccessCount : Integer;
  CantOpenCount : Integer;
  UseCurrentlyOpenClient  : boolean;
  CurrentClientUpdated : boolean;
begin
  result := false;
  if ClientCodes = '' then
    exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) then
      NotSynchronizedMsg
    else
    begin
      TempDlgClient := nil;
      TempListClient := nil;

      UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);
      //open the first client to get some defaults from
      if not UseCurrentlyOpenClient then
        OpenAClientForRead(Client.cfFile_Code, TempDlgClient)
      else
        TempDlgClient := MyClient;                                                          

      if Assigned(TempDlgClient) then
      begin
        try
          SchdRepDlg := TdlgClientReportSchedule.Create(Application.Mainform);
          try
            SchdRepDlg.ClientToUse := TempDlgClient;
            if SelectedList.Count <> 1 then
              SchdRepDlg.Options := [ crsDontUpdateClientSpecificFields];

            ReadClientSchedule(TempDlgClient, SchdRepDlg);

            FirstClientFileRec := AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[0])^;
            //default settings now loaded
            if ( SchdRepDlg.ShowModal = mrOK) then
            begin
              SuccessCount  := 0;
              CantOpenCount := 0;

              for i := 0 to SelectedList.Count-1 do
              begin
                Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
                if (Assigned(Client)) and (not Client.cfForeign_File) then
                begin
                  UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);
                  if not UseCurrentlyOpenClient then
                    OpenAClient(Client.cfFile_Code, TempListClient, True)
                  else
                    TempListClient := MyClient;

                  if Assigned(TempListClient) then
                  begin
                    // FirstClientFields stores a copy of the first clients clFields record, which is then
                    // passed into WriteClientSchedule where it is used to make sure we are only updating
                    // fields which have been changed.
                    // This is to fix the problem where, in cases where multiple clients have been selected,
                    // the Report Schedule shows the fields as they are currently set for the first client,
                    // and when OK is pressed will update all the clients to whatever is shown on the form;
                    // this is not the desired behaviour, we only want to update the fields which have been
                    // changed.
                    if (i = 0) then
                    begin
                      FirstClientFields := TempListClient.clFields;
                      FirstClientExtra := TempListClient.clExtra;
                    end;
                    WriteClientSchedule(TempListClient, SchdRepDlg, FirstClientFields, FirstClientExtra,
                                        @FirstClientFileRec);

                    if not UseCurrentlyOpenClient then
                      CloseAClient(TempListClient)
                    else
                    begin
                      TempListClient := nil;
                      CurrentClientUpdated := true;
                    end;

                    Inc(SuccessCount);
                  end else
                    Inc(CantOpenCount);
                end;
              end;
              CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);

              result := ( SuccessCount > 0);
            end;
          finally
            SchdRepDlg.Free;
          end;
        finally
          if UseCurrentlyOpenClient then
            TempDlgClient := nil
          else
            FreeAndNil( TempDlgClient);
        end;
      end
      else
      begin
        HelpfulInfoMsg( 'Cannot load default values from client ' + Client.cfFile_Code + '.  File cannot be opened.', 0);
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CodingScreenLayout( ClientCodes : string) : boolean;
const
  SECTION_HEADER = 'Settings';
  SECTION_COLUMN = 'Column';
var
  Column_Width           : Array[ 0..Max_CESColArraySize ] of Integer;
  Column_Order           : Array[ 0..Max_CESColArraySize ] of Integer;
  Column_Is_Hidden       : Array[ 0..Max_CESColArraySize ] of Boolean;
  Column_Is_Not_Editable : Array[ 0..Max_CESColArraySize ] of Boolean;
  Column_Settings_Read   : Array[ 0..Max_CESColArraySize ] of Boolean;

  SortOrder: Byte;

  procedure SetUpColumnDefaultsArrays;
  begin
    SortOrder := csDateEffective;
  end;

  procedure SetColumnsForClient(aClient : TClientObj);
  var
    i, j : Integer;
    BA : TBank_Account;
  begin
    for i := 0 to aClient.clBank_Account_List.ItemCount - 1 do
    begin
      BA := aClient.clBank_Account_List.Bank_Account_At( i);
      if (BA.baFields.baAccount_Type = btBank) then
      begin
        BA.baFields.baCoding_Sort_Order := SortOrder;
        //load the settings for each field id into the account settings
        for j := 0 to Max_CESColArraySize do
        begin
          if Column_Settings_Read[j] then
          begin
            BA.baFields.baColumn_Order[j] := Column_Order[j];
            BA.baFields.baColumn_Width[j] := Column_Width[j];
            BA.baFields.baColumn_Is_Hidden[j] := Column_Is_Hidden[j];
            //can't tell if col is allowed to be editable here, however that
            //will be checked when settings are loaded into CES columns list
            BA.baFields.baColumn_Is_Not_Editable[j] := Column_Is_Not_Editable[j];
          end
          else
            BA.baFields.baColumn_Width[j] := 0;
        end;
      end;
    end;
  end;

  procedure SetDefaultColumnsForClient(aClient : TClientObj);
  var
    i, j : Integer;
    BA : TBank_Account;
  begin
{    aClient.clFields.clCashJ_Sort_Order := -1;
    aClient.clFields.clAcrlJ_Sort_Order := -1;
    aClient.clFields.clStockJ_Sort_Order := -1;
    aClient.clFields.clYrEJ_Sort_Order := -1;
    aClient.clFields.clgstJ_Sort_Order := -1;
    for j := 0 to Max_CESColArraySize do
    begin
      aClient.clFields.clCashJ_Column_Width[j] := 0;
      aClient.clFields.clAcrlJ_Column_Width[j] := 0;
      aClient.clFields.clStockJ_Column_Width[j] := 0;
      aClient.clFields.clYrEJ_Column_Width[j] := 0;
      aClient.clFields.clgstJ_Column_Width[j] := 0;
    end;}
    for i := 0 to aClient.clBank_Account_List.ItemCount - 1 do
    begin
      BA := aClient.clBank_Account_List.Bank_Account_At( i);
      if (BA.baFields.baAccount_Type = btBank) then
      begin
        BA.baFields.baCoding_Sort_Order := SortOrder;
{        BA.baFields.baDIS_Sort_Order := -1;
        BA.baFields.baMDE_Sort_Order := 1;
        BA.baFields.baHDE_Sort_Order := 1;}
        for j := 0 to Max_CESColArraySize do
        begin
          BA.baFields.baColumn_Width[j] := 0;
{          BA.baFields.baDIS_Column_Width[j] := 0;
          BA.baFields.baMDE_Column_Width[j] := 0;
          BA.baFields.baHDE_Column_Width[j] := 0;}
        end;
      end;
    end;
  end;

var
  SelectedList : TStringList;
  Button : Integer;
  SuccessCount : Integer;
  CantOpenCount : Integer;
  i, j : Integer;
  dlgLoadCLS: TOpenDialog;
  INIFile : TMemINIFile;
  ColumnCount : Integer;
  Client : pClient_File_Rec;
  TempClient : TClientObj;
  UseCurrentlyOpenClient : boolean;
  CurrentClientUpdated : boolean;
begin
  result := false;
  if ClientCodes = '' then
    exit;

  //make sure all relative paths are relative to data dir after browse
  SysUtils.SetCurrentDir( Globals.DataDir);

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //create and show the layout options dialog
    Button := SelectFromRadioDialog('Code Entries Screen Layout',
      'This will allow you to pre-set the layout of the Code Entries Screen for each client you have selected.' +
      #13#10 + 'What do you want to do?',
      '&OK',
      'Cancel',
      0,
      'Load a Template',
      'Restore Default Layout');

    if (Button <> -1) then
    begin
      //Initialise Columns
      for i := Low( Column_Width) to High( Column_Width) do
      begin
        Column_Width[i] := 0;
        Column_Order[i] := 0;
        Column_Is_Hidden[i] := false;
        Column_Is_Not_Editable[i] := true;
        Column_Settings_Read[i] := false;
      end;
      //set up arrays for defaults
      SetUpColumnDefaultsArrays;

      SuccessCount  := 0;
      CantOpenCount := 0;

      if (Button = 1) then
      begin
        //load a template
        dlgLoadCLS := TOpenDialog.Create(Application.MainForm);
        try
          with dlgLoadCLS do
          begin
            Filename := '*.cls';
            Filter := 'Coding Layout Settings (*.cls)|*.cls';
            InitialDir := Globals.DataDir;

            if (Execute) then
            begin
              //read all the settings from the .cls file and copy into arrays
              INIFile := TMemINIFile.Create(dlgLoadCLS.FileName);
              try
                with INIFile do
                begin
                  SortOrder := ReadInteger(SECTION_HEADER, 'SortBy', SortOrder);
                  ColumnCount := ReadInteger(SECTION_HEADER, 'Columns', 0);
                  for i := 0 to ColumnCount-1 do
                  begin
                    j := ReadInteger(SECTION_COLUMN+IntToStr(i), 'FieldID', i);
                    if ( j in [0..Max_CESColArraySize]) then
                    begin
                      Column_Width[j] := ReadInteger(SECTION_COLUMN+IntToStr(i), 'Width', 60);
                      Column_Order[j] := ReadInteger(SECTION_COLUMN+IntToStr(i), 'Position', i);
                      Column_Is_Hidden[j] := ReadBool(SECTION_COLUMN+IntToStr(i), 'Hidden', True);
                      Column_Is_Not_Editable[j] := not ReadBool(SECTION_COLUMN+IntToStr(i), 'EditGeneral', False);
                      Column_Settings_Read[j] := true;
                    end;
                  end;
                end;
              finally
                INIFile.Free;
              end;

              //array is now filled with settings from the INI file
              //loop over each client selected and update fields from the array
              TempClient := nil;
              for i := 0 to SelectedList.Count-1 do
              begin
                Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
                if Assigned(Client) then
                begin
                  UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

                  if not UseCurrentlyOpenClient then
                    OpenAClient(Client.cfFile_Code, TempClient, True)
                  else
                  begin
                    CloseMDIChildren; // So that template updates can be reflected in CES
                    TempClient := MyClient;
                  end;

                  if Assigned(TempClient) then
                  begin
                    SetColumnsForClient(TempClient);

                    if not UseCurrentlyOpenClient then
                      CloseAClient(TempClient)
                    else
                    begin
                      TempClient := nil;
                      CurrentClientUpdated := true;
                    end;

                    Inc(SuccessCount);
                  end else
                    Inc(CantOpenCount);
                end;
              end;
              CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);
            end;
          end;
        finally
          dlgLoadCLS.Free;
        end;
      end else
      begin
        //restore default layout
        //loop over each client selected and update fields from the arrays
        TempClient := nil;
        for i := 0 to SelectedList.Count-1 do
        begin
          Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
          if Assigned(Client) then
          begin
            UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

            if not UseCurrentlyOpenClient then
              OpenAClient(Client.cfFile_Code, TempClient, True)
            else
            begin
              CloseMDIChildren; // So that template updates can be reflected in CES
              TempClient := MyClient;
            end;

            if Assigned(TempClient) then
            begin
              SetDefaultColumnsForClient(TempClient);
              if not UseCurrentlyOpenClient then
                CloseAClient(TempClient)
              else
              begin
                TempClient := nil;
                CurrentClientUpdated := true;
              end;

              Inc(SuccessCount);
            end else
              Inc(CantOpenCount);
          end;
        end;
        CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);
      end;
      result := ( SuccessCount > 0);
    end;
  finally
    SelectedList.Free;
    //make sure all relative paths are relative to data dir after browse
    SysUtils.SetCurrentDir( Globals.DataDir);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AssignPracticeContact( ClientCodes : string) : boolean;
var
  SelectedList : TStringList;
  i            : integer;
  Client       : pClient_File_Rec;
  TempClient   : TClientObj;
  SuccessCount : Integer;
  CantOpenCount : Integer;
  Contact_Details_To_Show : Integer;
  Contact_Name  : String;
  Contact_Phone : String;
  Contact_Email : String;
  UseCurrentlyOpenClient : boolean;
  CurrentClientUpdated : boolean;
begin
  result := false;
  if ClientCodes = '' then
    exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) then
      NotSynchronizedMsg
    else
    begin
      //read default from first client
      TempClient := nil;
      UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

      if not UseCurrentlyOpenClient then
        OpenAClientForRead(Client.cfFile_Code, TempClient)
      else
        TempClient := MyClient;

      if Assigned(TempClient) then
      begin
        try
          if ChooseContactDetails(TempClient) then
          begin
            //store details
            Contact_Details_To_Show := TempClient.clFields.clContact_Details_To_Show;
            Contact_Name  := TempClient.clFields.clCustom_Contact_Name;
            Contact_Phone := TempClient.clFields.clCustom_Contact_Phone;
            Contact_Email := TempClient.clFields.clCustom_Contact_EMail_Address;

            //no longer need temp client as can now save settings to each
            //selected client
            if not UseCurrentlyOpenClient then
              FreeAndNil(TempClient)
            else
              TempClient := nil;

            SuccessCount := 0;
            CantOpenCount := 0;

            //loop over clients and update them with the same details
            for i := 0 to SelectedList.Count-1 do
            begin
              Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);

              if (Assigned(Client)) and (not Client.cfForeign_File) then
              begin
                UseCurrentlyOpenClient := CodeIsMyClient( Client^.cfFile_Code);

                if not UseCurrentlyOpenClient then
                  OpenAClient(Client.cfFile_Code, TempClient, True)
                else
                  TempClient := MyClient;

                if Assigned(TempClient) then
                begin
                  TempClient.clFields.clContact_Details_To_Show := Contact_Details_To_Show;

                  TempClient.clFields.clCustom_Contact_Name     := Contact_Name;
                  TempClient.clFields.clCustom_Contact_Phone    := Contact_Phone;
                  TempClient.clFields.clCustom_Contact_EMail_Address := Contact_Email;

                  if not UseCurrentlyOpenClient then
                    CloseAClient(TempClient)
                  else
                  begin
                    TempClient := nil;
                    CurrentClientUpdated := true;
                  end;

                  Inc(SuccessCount);
                end else
                  Inc(CantOpenCount);
              end;
            end;
            CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);
            result := SuccessCount > 0;
          end else
            FreeAndNil(TempClient);
        finally
          TempClient.Free;
          TempClient := nil;
        end;
      end
      else
      begin
        HelpfulInfoMsg( 'Cannot load default values from client ' + Client.cfFile_Code + '.  File cannot be opened.', 0);
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ChangeFinancialYear( ClientCodes : string) : boolean;
var
  SelectedList : TStringList;
  i            : integer;
  Client       : pClient_File_Rec;
  TempClient   : TClientObj;
  YearStarts   : LongInt;
  SuccessCount : Integer;
  CantOpenCount : Integer;
  CurrentClientUpdated : boolean;
  UseCurrentlyOpenClient : boolean;
begin
  result := false;
  if ClientCodes = '' then
    exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) or (Client.cfForeign_File) then
      NotSynchronizedMsg
    else
    begin
      YearStarts := Client.cfFinancial_Year_Starts;

      if ChangeFinancialYearStart(YearStarts) then
      begin
        TempClient := nil;
        SuccessCount := 0;
        CantOpenCount := 0;
        for i := 0 to SelectedList.Count-1 do
        begin
          Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
          if (Assigned(Client)) then
          begin
            UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);

            if not UseCurrentlyOpenClient then
              OpenAClient(Client.cfFile_Code, TempClient, True)
            else
              TempClient := MyClient;

            if Assigned(TempClient) then
            begin
              TempClient.clFields.clFinancial_Year_Starts := YearStarts;
              if not UseCurrentlyOpenClient then
                CloseAClient(TempClient)
              else
              begin
                TempClient := nil;
                CurrentClientUpdated := true;
              end;

              Inc(SuccessCount);
            end else
              Inc(CantOpenCount);
          end;
        end;
        CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);
        result := SuccessCount > 0;
      end;
    end;
  finally
    SelectedList.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DeleteClientFile(ClientCode : string) : boolean;
const
  ThisMethodName = 'DeleteClientFile';
var
  ClientFile : pClient_File_Rec;
  User       : pUser_Rec;
  sUser      : string;
  msg        : string;
  Filename   : string;
  ClientLRN  : integer;
  pM: pClient_Account_Map_Rec;
  pS: pSystem_Bank_Account_Rec;
  i: Integer;
begin
  //can only delete one client at a time
  Result := false;

  //reload the admin system
  RefreshAdmin;
  //get the selected client from the admin system
  ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);

  if not Assigned( ClientFile) then
  begin
     if ClientCode = '' then
       Exit; // This has been moved here so you can attemt to remove 'Emty' Client files
             // There is no point, to point out, that you cannot find nothing...
     HelpfulErrorMsg('Client File ' + ClientCode + ' cannot be found!', 0);
     Exit;
  end
  else
  begin
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
         HelpfulInfoMsg( 'Sorry, User '+sUSer+' has sent this client file.', 0 );
         exit;
      end;

      fsOffsite: begin
         HelpfulInfoMsg('Sorry, this Client File is currently Off-site.',0);
         Exit;
      end;
    end; {case}

    {file is not open}

    //check password for file - if one doesnt exists then ask for DELETE as the password
    if ClientCode > '' then begin
       // Valid Client Code
       if (ClientFile.cfFile_Password = '')
       or (SuperUserLoggedIn) then
       begin
          if not EnterPassword('Enter the word DELETE in the box below to confirm deletion','DELETE',0, false,false) then
             exit;
       end else
          if not EnterPassword('Enter the Client File password to confirm deletion',ClientFile.cfFile_Password,0,false,true) then begin
             HelpfulInfoMsg('Incorrect password entered for this file.  You must enter the correct password before you can delete the file',0);
             exit;
          end;
    end; // Else.. Crap code anyway.. just cleanup

    ClientCode := ClientFile^.cfFile_Code;
    ClientLRN  := ClientFile^.cfLRN;

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

       if (ClientFile.cfFile_Status <> fsNormal)
       and (ClientCode > '')then //invalid Client Code
       begin
         UnlockAdmin;
         HelpfulErrorMsg('The client file for Client Code '+ClientCode+' is in use. (state <> fsNormal).',0);
         exit;
       end;

       {------------------------------------------------}
       {delete file from datadir}
       if BKFileExists(DATADIR + ClientFile.cfFile_Code + FILEEXTN) then
       begin
          LogUtil.LogMsg(lmInfo,ThisMethodName,'User Deleting Client with Code '+ClientCode+ ' from Admin System');

          if ShellUtils.DeleteFileToRecycleBin( DATADIR + ClientCode + FileExtn ) or
             // Bug in systools - reports failed even when it hasnt!
             (not BKFileExists(DATADIR + ClientCode + FileExtn)) then
             LogUtil.LogMsg(lmInfo,ThisMethodName,'File '+DATADIR+ClientCode+FILEEXTN+' DELETED Ok.')
          else
             LogUtil.LogMsg(lmInfo,ThisMethodName,'File '+DATADIR+ClientCode+FILEEXTN+' DELETED Failed.');

          //clean up the BAK file
          SysUtils.DeleteFile(DATADIR + ClientCode + BACKUPEXTN);
       end;

       // remove from client account map
       i := 0;
       while i < AdminSystem.fdSystem_Client_Account_Map.ItemCount do begin
          pM := AdminSystem.fdSystem_Client_Account_Map.Client_Account_Map_At(i);
          if pM.amClient_LRN = ClientLRN then begin // Delete this entry
             // keep the System account
             pS := AdminSystem.fdSystem_Bank_Account_List.FindLRN(pM.amAccount_LRN);
             // Delete the map entry
             AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
             // See if the system account is still attached elsewhere
             if Assigned(pS)
             and (not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pS.sbLRN))) then
                // its now unattached
                pS.sbAttach_Required := True;
          end else
             Inc(i);
       end;


       //remove from admin system
       AdminSystem.fdSystem_File_Access_List.Delete_Client_File( ClientLRN );
       AdminSystem.fdSystem_Client_File_List.DelFreeItem( ClientFile );
       LogUtil.LogMsg(lmInfo,'ThisMethodName','Client '+ClientCode+' deleted from Admin System OK');

       //*** Flag Audit ***
       SystemAuditMgr.FlagAudit(arSystemClientFiles);

       SaveAdminSystem;

       //delete contact details, task list and comments
       filename := DirUtils.GetTaskListFilename(ClientLRN);
       SysUtils.DeleteFile(filename);

       filename := DirUtils.GetClientNotesFilename(ClientLRN);
       SysUtils.DeleteFile(filename);

       filename := DirUtils.GetClientDetailsCacheFilename(ClientLRN);
       SysUtils.DeleteFile(filename);

       {------------------------------------------------}
       Result := True;
    end
    else
       HelpfulErrorMsg('Could not Delete Client File Details at this time. Admin System unavailable.',0);
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function UnlockClientFile( ClientCodes : string) : Boolean;
const
  ThisMethodName = 'UnlockClientFile';
var
  ClientFile : pClient_File_Rec;
  User       : pUser_Rec;
  sUser      : String;
  Status     : String;
  aMsg       : string;
  Proceed    : boolean;
  SelectedList: TStringList;
  ClientCode: string;
  i, ResetCount: Integer;
  UserCancel: Boolean;
  ErrorTotal: Integer;
begin
  Result := false;
  ResetCount := 0;
  ErrorTotal := 0;
  UserCancel := False;
  if ClientCodes = '' then
    exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := true;
    SelectedList.DelimitedText := ClientCodes;

    if SelectedList.Count > 1 then
    begin
      aMsg := 'This will reset the client file status for all selected clients. ' +
            'You should only do this if you have been advised to by a support person. ' + #13 + #13 +
            'Please confirm you want to do this.';

      if (AskYesNo('Reset Client File Status', aMsg, DLG_NO, 0) <> DLG_YES) then
        exit;

      UpdateAppStatus('Resetting client file status', 'Please wait...', 100, True);
    end;
    for i := 0 to Pred(SelectedList.Count) do
    begin
      if SelectedList.Count > 1 then
        UpdateAppStatusPerc( i / Pred(SelectedList.Count) * 100, True);
      ClientCode := SelectedList[i];

      //get the selected client from the admin system
      ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);

      if not Assigned( ClientFile) then
      begin
        HelpfulErrorMsg('Client File ' + ClientCode + ' cannot be found!', 0);
        Inc(ErrorTotal);
        Continue;
      end
      else
      begin
        if (ClientFile.cfFile_Status in [fsOpen, fsCheckedOut, fsOffsite]) then
        begin
          //the client file is currently open
          User := AdminSystem.fdSystem_User_List.FindLRN(ClientFile.cfCurrent_User);
          if Assigned(User) then
            sUser := User.usCode
          else
            sUser := '<unknown>';

          //make sure current user does not have the file open
          if Assigned( MyClient) and ( MyClient.clFields.clCode = ClientFile.cfFile_Code) then
          begin
            if SelectedList.Count = 1 then // else silent
            begin
              HelpfulWarningMsg('You cannot reset the file ' + ClientCode + ' because you currently have it open!', 0);
              UserCancel := True;
            end;
            Inc(ErrorTotal);
            Continue;
          end;

          Status := BKCONST.fsNames[ ClientFile.cfFile_Status];
          aMsg := 'The client file ' + ClientFile.cfFile_Code + ' is currently ' + status + '. ' +
            'This will reset the client file status. ' +
            'You should only do this if you have been advised to by a support person. ' + #13 + #13 +
            'Please confirm you want to do this.';

          if (SelectedList.Count > 1) or (AskYesNo('Reset Client File Status', aMsg, DLG_NO, 0) = DLG_YES) then
          begin
            if (ClientFile.cfFile_Status in [ fsCheckedOut, fsOffsite]) then
              Proceed := true
            else if SelectedList.Count = 1 then // do not allow reset of multiple open status
            begin
              Proceed := EnterPassword('Reset File Status', 'FILEOPEN', 0, true, false);
              if not Proceed then
                UserCancel := True;
            end
            else
              Proceed := false;

            if Proceed then
            begin
              if LoadAdminSystem(true, ThisMethodName ) then
              begin
                ClientFile := AdminSystem.fdSystem_Client_File_List.FindCode(ClientCode);
                if Assigned(ClientFile) then
                begin
                  ClientFile.cfFile_Status := fsNormal;
                  //clear the current user
                  ClientFile.cfCurrent_User := 0;

                  //*** Flag Audit ***
                  //Set audit info here so no system client file record
                  //needs to be saved to the audit table.
                  SystemAuditMgr.FlagAudit(arSystemClientFiles,
                                           ClientFile.cfAudit_Record_ID,
                                           aaNone,
                                           Format('Client Reset%sClient Code=%s',
                                                  [VALUES_DELIMITER,
                                                   ClientFile.cfFile_Code]));
                  SaveAdminSystem;

                  CloseCheckOutTask(ClientFile);
                  Inc(ResetCount);
                  LogUtil.LogMsg( lmInfo, ThisMethodName,
                            'User changed file status from ' + Status + ' to '+
                            fsNames[ fsNormal] + ' for client ' + ClientCode);
                  if SelectedList.Count = 1 then
                    HelpfulInfoMsg('The file status for ' + ClientCode + ' has been reset.', 0);
                  Result := True;
                end else
                begin
                  UnlockAdmin;
                  Inc(ErrorTotal);
                  HelpfulErrorMsg('The File for Client Code ' + ClientCode + ' cannot be found by the Admin System.', 0);
                end;
              end else
              begin
                HelpfulErrorMsg('Unable to update Admin Client File Record.  Cannot Access Admin System.', 0);
                Inc(ErrorTotal);
              end;
            end
            else
              Inc(ErrorTotal);
          end
          else
            UserCancel := True;
        end
        else
          Inc(ErrorTotal);
      end;
    end;
    if (not UserCancel) and (ResetCount = 0) then
    begin
      if SelectedList.Count = 1 then
        HelpfulInfoMsg('The selected client file does not require a reset.', 0)
      else
        HelpfulInfoMsg('None of the selected client files were reset.', 0)
    end
    else if SelectedList.Count > 1 then
      HelpfulInfoMsg('The file status for ' + IntToStr(ResetCount) + ' client file(s) has been reset,' + #13 +
                     IntToStr(ErrorTotal) + ' client file(s) were not reset.', 0);
  finally
    ClearStatus;
    SelectedList.Free;
  end;
end;

// Delete prospects
function DeleteProspects(ClientCodes : string; Silent: Boolean = False; KeepFiles: Boolean = False) : boolean;
const
  ThisMethodName = 'DeleteProspects';
var
  SelectedList: TStringList;
  i, success, fail: integer;
  ClientFile: pClient_File_Rec;
  msg, filename, ClientCode: string;
  ClientLRN: integer;
begin
  Result := False;
  success := 0;
  fail := 0;
  if ClientCodes = '' then exit;

  msg := 'Deleting the selected Prospects will PERMANENTLY REMOVE them from the Administration system.' + #13#13 +
         'Please confirm that you really want to delete the selected Prospects from ' + SHORTAPPNAME + '.';

  if (not Silent) and (AskYesNo('Delete Prospects', Msg, DLG_NO, 0) <> DLG_YES) then exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;
    if SelectedList.Count > 1 then
      UpdateAppStatus('Deleting Prospects', 'Please wait...', 100, True);
    for i := 0 to Pred(SelectedList.Count) do
    begin
      if SelectedList.Count > 1 then
        UpdateAppStatusPerc( i / Pred(SelectedList.Count) * 100, True);
      //get the selected client from the admin system
      ClientCode := SelectedList[i];
      ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);

      if not Assigned( ClientFile) then
      begin
        if not Silent then
          HelpfulErrorMsg('Prospect "' + ClientCode + '" cannot be found!', 0);
        Inc(fail);
        Continue;
      end
      else
      begin
        ClientCode := ClientFile^.cfFile_Code;
        ClientLRN  := ClientFile^.cfLRN;

        //now lock the admin system and delete the file, was locked check that status has not changed}
        if LoadAdminSystem(true, ThisMethodName ) then
        begin
          {reload new object}
          ClientFile := Adminsystem.fdSystem_Client_File_List.FindCode(ClientCode);
          if not Assigned(ClientFile) then
          begin
            UnlockAdmin;
            if not Silent then
              HelpfulErrorMsg('The client file for Client Code '+ClientCode+' can no longer be found in the admin system.',0);
            Inc(fail);
            Continue;
          end;

          if ClientFile.cfFile_Status <> fsNormal then
          begin
            UnlockAdmin;
            if not Silent then
              HelpfulErrorMsg('The client file for Client Code '+ClientCode+' is in use. (state <> fsNormal).',0);
            Inc(fail);
            Continue;
          end;

          //remove from admin system
          AdminSystem.fdSystem_File_Access_List.Delete_Client_File( ClientLRN );
          AdminSystem.fdSystem_Client_File_List.DelFreeItem( ClientFile );
          LogUtil.LogMsg(lmInfo,'ThisMethodName','Prospect '+ClientCode+' deleted from Admin System OK');

          //*** Flag Audit ***
          SystemAuditMgr.FlagAudit(arSystemClientFiles);

          SaveAdminSystem;

          //delete contact details, task list and comments
          if not KeepFiles then
          begin
            filename := DirUtils.GetTaskListFilename( ClientLRN);
            SysUtils.DeleteFile( filename);

            filename := DirUtils.GetClientNotesFilename( ClientLRN);
            SysUtils.DeleteFile( filename);

            filename := DirUtils.GetClientDetailsCacheFilename( ClientLRN);
            SysUtils.DeleteFile( filename);
          end;
          Inc(success);
        end
        else if not Silent then
          HelpfulErrorMsg('Could not Delete Prospect Details at this time. Admin System unavailable.',0);
      end;
    end;
    ClearStatus(True);
    if success = SelectedList.Count then // all ok
      msg := 'The Prospects have been deleted,  ' + inttostr(success) + ' client(s) deleted.'
    else if success = 0 then // nothing ok
      msg := 'The Prospects could not be deleted, ' + inttostr(SelectedList.Count) + ' client(s) failed to be deleted.'
    else
    begin //some files were ok, some not
      msg :=  'Prospects deleted:'#13#13+
              IntToStr(success) + ' client(s) deleted'#13#13;
      msg := msg + IntToStr(fail) + ' client(s) could not be deleted.';
   end;
   if not Silent then
     HelpfulInfoMsg(msg, 0);
  finally
    SelectedList.Free;
    ClearStatus(True);

  end;
  Result := success > 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ArchiveFiles( ClientCodes : string) : boolean;
var
  SelectedList : TStringList;
  i            : integer;
  Client       : pClient_File_Rec;
  TempClient   : TClientObj;
  SuccessCount : Integer;
  CantOpenCount : Integer;
  CurrentClientUpdated : boolean;
  UseCurrentlyOpenClient : boolean;
begin
  result := false;
  if ClientCodes = '' then
    exit;

  //reload the admin system
  RefreshAdmin;

  SelectedList := TStringList.Create;
  try
    SelectedList.Delimiter := GLOBALS.ClientCodeDelimiter;
    SelectedList.StrictDelimiter := True;
    SelectedList.DelimitedText := ClientCodes;

    CurrentClientUpdated := false;

    //search through the selected clients looking for the first file
    //that is part of our admin system
    Client := FindFirstSynchronisedClient( SelectedList);

    if not Assigned( Client) or (Client.cfForeign_File) then
      NotSynchronizedMsg
    else
    begin
      TempClient := nil;
      SuccessCount := 0;
      CantOpenCount := 0;
      for i := 0 to SelectedList.Count-1 do
      begin
        Client := Globals.AdminSystem.fdSystem_Client_File_List.FindCode(SelectedList[i]);
        if (Assigned(Client)) then
        begin
          UseCurrentlyOpenClient := CodeIsMyClient( Client.cfFile_Code);

          if not UseCurrentlyOpenClient then
            OpenAClient(Client.cfFile_Code, TempClient, True)
          else
            TempClient := MyClient;

          if Assigned(TempClient) then
          begin
            TempClient.clMoreFields.mcArchived := not TempClient.clMoreFields.mcArchived;
            if not UseCurrentlyOpenClient then begin
              //*** Flag Audit ***
              //Audit here so that an audit record isn't created every time a client file is opened
              SystemAuditMgr.FlagAudit(arSystemClientFiles);
              CloseAClient(TempClient)
            end else
            begin
              TempClient := nil;
              CurrentClientUpdated := true;
            end;

            Inc(SuccessCount);
          end else
            Inc(CantOpenCount);
        end;
      end;
      CompletionMsg(SelectedList.Count, SuccessCount, CantOpenCount, CurrentClientUpdated);
      result := SuccessCount > 0;
    end;
  finally
    SelectedList.Free;
  end;
end;

end.
