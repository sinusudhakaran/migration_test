unit MaintainPracBankFrm;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  sysaccountsfme,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  ComCtrls,
  ToolWin,
  syDefs,
  StdCtrls,
  ExtCtrls,
  Math,
  ActnList,
  RzGroupBar,
  Menus,
  Globals,
  OSFont;

type
  TfrmMaintainPracBank = class(TForm)
    Panel1: TPanel;
    SysAccounts: TfmeSysAccounts;
    gbMain: TRzGroupBar;
    gbAccounts: TRzGroup;
    gbDetails: TRzGroup;
    rzgOptions: TRzGroup;
    actList: TActionList;
    actEdit: TAction;
    actDelete: TAction;
    actRemove: TAction;
    actNew: TAction;
    actCharge: TAction;
    actSendDelete: TAction;
    actPrint: TAction;
    actListBankAccounts: TAction;
    actListInactiveAccounts: TAction;
    Splitter1: TSplitter;
    btnOK: TButton;
    pmGrid: TPopupMenu;
    actSendFrequencyRequest: TAction;
    acCurrencies: TAction;
    acExchangeRates: TAction;
    acSendProvReq: TAction;
    acAddProvTrans: TAction;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbHelpClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure OnSelChange(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actListBankAccountsExecute(Sender: TObject);
    procedure actChargeExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure actNewExecute(Sender: TObject);
    procedure actSendDeleteExecute(Sender: TObject);
    procedure actPrintExecute(Sender: TObject);
    procedure actListInactiveAccountsExecute(Sender: TObject);
    procedure actRemoveExecute(Sender: TObject);
    procedure SysAccountsAccountTreeDblClick(Sender: TObject);
    procedure pmGridPopup(Sender: TObject);
    procedure actSendFrequencyRequestExecute(Sender: TObject);
    procedure acCurrenciesExecute(Sender: TObject);
    procedure acExchangeRatesExecute(Sender: TObject);
    procedure actSendProvReqExecute(Sender: TObject);
    procedure SendProvAccRequest;
    procedure acAddProvTransExecute(Sender: TObject);
    procedure ManuallyAddProvTrans(ForAccount: string);
    procedure SysAccountsbtnFilterClick(Sender: TObject);
    procedure WMDoRefresh (var message: TMessage); message BK_SYSTEMDB_LOADED;
  private
    { Private declarations }
    fChanged : boolean;
    procedure RefreshBankAccountList(Selected: string = '');
    procedure HandleDeletes(AsDoRequest: Boolean);
  public
  protected
    procedure UpdateActions; override;
    { Public declarations }
    function Execute(Mode: Integer) : boolean;
  end;

const // enum Type..
  mpba_Normal = 0;
  mpba_Inactive = 1;

function MaintainPracticeBankAccounts(Mode: Integer) : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  frmCurrencies,
  frmExchangeRates,
  bkBranding,
  rptSysAccounts,
  reportDefs,
  ModalProcessorDlg,
  DeleteRequestFrm,
  AttachNewDlg,
  Mailfrm,
  VirtualTrees,
  Admin32,
  bkDateutils,
  BKHelp,
  bkXPThemes,
  EditPracBankDlg,
  EnterPwdDlg,
  ErrorMoreFrm,
  Imagesfrm,
  LogUtil,
  LvUtils,
  WarningMorefrm,
  YesNoDlg,
  bkConst,
  GenUtils,
  FrequencyRequestFrm,
  SendProvAccRequestFrm,
  HistoricalDlg,
  AuditMgr,
  ClientHomePageFrm,
  bkUrls,
  bkContactInformation;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  SysAccounts.DoCreate(UserINI_SPA_Columns);
  SysAccounts.OnSelectionChanged := self.OnSelChange;
  SysAccounts.AccountTree.OnDblClick := SysAccountsAccountTreeDblClick;// set it back..
  SysAccounts.AccountTree.HintMode := hmHint;

  GBMain.GradientColorStop := bkBranding.GroupBackGroundStopColor;
  GBMain.GradientColorStart := bkBranding.GroupBackGroundStartColor;

  actRemove.Visible := GLOBALS.SuperUserLoggedIn;
  acCurrencies.Visible := (AdminSystem.fdFields.fdCountry = whUK);
  acExchangeRates.Visible := (AdminSystem.fdFields.fdCountry = whUK);

  acSendProvReq.Visible := False;

  //SetListViewColWidth(lvBank,1);
  SetUpHelp;
  fChanged := True;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.FormDestroy(Sender: TObject);
begin
  SysAccounts.DoDestroy(UserINI_SPA_Columns);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.SetUpHelp;
begin
  Self.ShowHint    := INI_ShowFormHints;
  Self.HelpContext := 0;
  //Components
  actEdit.Hint      :=
                   'Edit the details for the selected Bank Account|' +
                   'Edit the details for the selected Bank Account';
  actDelete.Hint    :=
                   'Mark the selected Bank Account as deleted';
  actRemove.Hint    :=
                   'Remove the selected Bank Account from the system';
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.SysAccountsAccountTreeDblClick(Sender: TObject);
var
  MousePos : TPoint;
  Node: PVirtualNode;
  Column : Integer;
begin
  // Just Check where it was clicked...
  MousePos := Mouse.CursorPos;
  MousePos := SysAccounts.AccountTree.ScreenToClient(MousePos);
  Node := SysAccounts.AccountTree.GetNodeAt(MousePos.x, MousePos.y, True,Column);

  if not assigned(Node) then
    Exit; // Header??

  if actedit.Enabled then
    actedit.Execute;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.SysAccountsbtnFilterClick(Sender: TObject);
begin
  SysAccounts.actFilterExecute(Sender);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.RefreshBankAccountList(Selected: string = '');
begin
  SysAccounts.ReloadAccounts(Selected);
  fChanged := True;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actDeleteExecute(Sender: TObject);
begin
  HandleDeletes(False);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actEditExecute(Sender: TObject);
var
  lSel : string;
begin
  if SysAccounts.Selected <> nil then
  begin
    lSel := SysAccounts.Selected.sbAccount_Number;
    //Have to keep the sell because the edit will reload the admin system
    if EditPracticeBankAccount(SysAccounts.Selected) then
    begin
      RefreshBankAccountList(lSel);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actListBankAccountsExecute(Sender: TObject);
begin
  DoModalReport(REPORT_ADMIN_ACCOUNTS,rdNone);
  RefreshBankAccountList; // Would have reloaded Admin System
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actListInactiveAccountsExecute(Sender: TObject);
begin
  DoModalReport(Report_Admin_Inactive_Accounts,rdNone);
  RefreshBankAccountList; // Would have reloaded Admin System
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actNewExecute(Sender: TObject);
var
  lSel: string;
begin
  lSel := SysAccounts.SelectedList;
  if AttachNewBankAccounts then
    RefreshBankAccountList(LSel);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actPrintExecute(Sender: TObject);
begin
  DoSysAccount(rdAsk, SysAccounts);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actRemoveExecute(Sender: TObject);
var
  ba                 : pSystem_Bank_Account_Rec;
  AcctNo             : String;
  PassGenCodeEntered : boolean;
begin
  if SysAccounts.Selected = nil then
    exit;
  if not SuperUserLoggedIn then
    exit;

  SysAccounts.BeginUpdate;
  try
    //get passgen password, turn off superuser temporarily so that password is required
    SuperUserLoggedIn := false;
    try
      PassGenCodeEntered := EnterRandomPassword('Delete System Bank Account');
      if not PassGenCodeEntered then
        exit;
    finally
      SuperUserLoggedIn := true;
    end;

    ba := SysAccounts.Selected;
    AcctNo := ba^.sbAccount_Number;

    //confirm delete
    if YesNoDlg.AskYesNo( 'Delete System Bank Account',
                          'You are about to delete a system bank account.  This is an '+
                          'irrecoverable action!'#13#13+
                          'Delete ' + ba^.sbAccount_Number + ' ' + ba^.sbAccount_Name + '?',
                          DLG_NO, 0) <> DLG_YES then
      exit;

    if LoadAdminSystem(true, 'RemoveClick') then
    begin
      //find bank account object after reloading the admin system
      ba := AdminSystem.fdSystem_Bank_Account_List.FindCode( AcctNo);
      if not Assigned( ba) then
      begin
        UnlockAdmin;
        HelpfulErrorMsg('Bank Account not found' , 0);
        exit;
      end;

      //delete from list
      AdminSystem.fdSystem_Bank_Account_List.DelFreeItem( ba);

      //*** Flag Audit ***
      SystemAuditMgr.FlagAudit(arSystemBankAccounts);

      SaveAdminSystem;

      LogUtil.LogMsg( lmInfo, 'DELETE_SYSTEM_BANK_ACCOUNT', 'User Deleted System Account ' + AcctNo);
    end
    else
      HelpfulErrorMsg('Admin System unavailable.', 0);

    RefreshBankAccountList;
  finally
    SysAccounts.EndUpdate;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.acAddProvTransExecute(Sender: TObject);
var
  Selected: PSystem_Bank_Account_Rec;
begin
  Selected := SysAccounts.Selected;
  if not Assigned(Selected) then
     Exit;
  ManuallyAddProvTrans(Selected.sbAccount_Number);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.acCurrenciesExecute(Sender: TObject);
begin
  MaintainCurrencies;
  RefreshBankAccountList;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.acExchangeRatesExecute(Sender: TObject);
begin
  if MaintainExchangeRates then
  begin
    if assigned(MyClient) then
      RefreshHomePage([HPR_ExchangeGainLoss_Rates]);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actChargeExecute(Sender: TObject);
var
  Selected: TStringList;
  I: integer;
  ba: pSystem_Bank_Account_Rec;
begin

  Selected := SysAccounts.GetStringList(SysAccounts.SelectedList);
  try
    if LoadAdminSystem(True, 'MaintainPracBank') then
    begin
      // The Syssacount list is no longer valid...
      for i := 0 to Selected.Count-1 do
      begin
        ba := AdminSystem.fdSystem_Bank_Account_List.FindCode(Selected[i]);
        if Assigned(ba) then
        begin
          //account found in reloaded admin so update
          ba^.sbNo_Charge_Account := actCharge.ImageIndex in [Manager_DoubleTick,Manager_SingleTick];
        end;
      end;

      //*** Flag Audit ***
      SystemAuditMgr.FlagAudit(arSystemBankAccounts);

      SaveAdminSystem;
    end;

    RefreshBankAccountList(Selected.DelimitedText);
  finally
    Selected.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actSendDeleteExecute(Sender: TObject);
begin
  HandleDeletes(True);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actSendFrequencyRequestExecute(Sender: TObject);
const
  ThisMethodName = 'actSendFrequencyRequestExecute';
var
  i, DropCount, DeletedCount: integer;
  Recipient, Body, AccountNo, SelAccounts: string;
  lACC: TSABaseItem;
  MailSent: Boolean;
  FrequencyRequestForm: TfrmFrequencyRequest;
  lNode: PVirtualNode;
  lBankAccount: PSystem_Bank_Account_Rec;
begin
  DeletedCount := 0;
  DropCount := 0;
  FrequencyRequestForm := TfrmFrequencyRequest.Create(Self);
  try
    FrequencyRequestForm.WebSite := TUrls.WebSites[Globals.AdminSystem.fdFields.fdCountry];

    //Add bank accounts
    lNode := SysAccounts.AccountTree.GetFirstSelected;
    while Assigned(lNode) do
    begin
      lAcc := SysAccounts.Accounts[lNode];
      if Assigned(lAcc.SysAccount) then
      begin
        if SysAccounts.Accounts[lNode].SysAccount.sbMark_As_Deleted then
          Inc(DeletedCount)
        else
          FrequencyRequestForm.AddBankAccount(SysAccounts.Accounts[lNode].SysAccount);
      end;
      lNode := SysAccounts.AccountTree.GetNextSelected(lNode);
    end;

    //Warnings
    DropCount := (SysAccounts.AccountTree.SelectedCount - DeletedCount) -
                  FrequencyRequestForm.BankAccountCount;
    //Case 15213
    if (DropCount = 1) and (SysAccounts.AccountTree.SelectedCount >
                            AdminSystem.fdSystem_Bank_Account_List.ItemCount) then
    begin
      //Select all selects 1 more row than the number visible
      DropCount := 0;
    end;

    if DropCount = SysAccounts.AccountTree.SelectedCount then
    begin
      MessageDlg('A change request cannot be sent because the current frequency ' +
                 'is unknown for the selected account(s).',
                 mtInformation, [mbOK], 0);
      Exit;
    end
    else if DropCount > 0 then
    begin
      if (SysAccounts.AccountTree.SelectedCount = (DeletedCount + DropCount)) then
      begin
        MessageDlg('A change request cannot be sent because the current frequency ' +
                   'is unknown for the selected accounts, or they are marked as deleted.',
                   mtInformation, [mbOK], 0);
        Exit;
      end
      else if DropCount = 1 then
        MessageDlg('One of the selected accounts is not included in the ' +
                   'change request because it''s current frequency is unknown.',
                    mtInformation, [mbOK], 0)
      else
        MessageDlg(Format('%d of the selected accounts are not included in ' +
                          'the change request because their current frequency ' +
                          'is unknown.',
                          [DropCount]), mtInformation, [mbOK], 0);
    end;
    if DeletedCount > 0 then
    begin
      if (SysAccounts.AccountTree.SelectedCount = DeletedCount) then
      begin
        MessageDlg('A change request cannot be sent because ' +
                   'the selected accounts are marked as deleted.',
                   mtInformation, [mbOK], 0);
        Exit;
      end
      else if DeletedCount = 1 then
        MessageDlg(Format('One of the selected accounts is not included in ' +
                          'the change request because it is marked as deleted.',
                          [DeletedCount]), mtInformation, [mbOK], 0)
      else
        MessageDlg(Format('%d of the selected accounts are not included in ' +
                          'the change request because they are marked as deleted.',
                          [DeletedCount]), mtInformation, [mbOK], 0);
    end;

    //*** Show dialog ***
    if FrequencyRequestForm.ShowModal = mrOk then
    begin
      //Send the frequency change request
      case AdminSystem.fdFields.fdCountry of
        whAustralia: Recipient := TContactInformation.ClientServicesEmail[whAustralia];
        whUK: Recipient := TContactInformation.ClientServicesEmail[whUK];
      else
        Recipient := TContactInformation.ClientServicesEmail[whNewZealand];
      end;

      Body := FrequencyRequestForm.GetBodyText(AdminSystem.fdFields.fdBankLink_Code);

      MailSent := SendMailTo(FREQUENCY_CHANGE_REQUEST,
                             Recipient,
                             Format('%s %s',
                                    [AdminSystem.fdFields.fdBankLink_Code,
                                    FREQUENCY_CHANGE_REQUEST]),
                             Body);
      if MailSent then
      begin
        for i := 0 to FrequencyRequestForm.memoMonthly.Lines.Count - 1 do
          LogUtil.LogMsg( lmInfo, 'REQUEST_FREQUENCY_CHANGE_SYSTEM_BANK_ACCOUNT',
                         'User Request Frequency Change System Account ' +
                         FrequencyRequestForm.memoMonthly.Lines[i] );

        //Update Pending Flag
        if FrequencyRequestForm.BankAccountCount > 0 then begin
          if LoadAdminSystem(true, ThisMethodName ) then
          begin
            for i := 0 to FrequencyRequestForm.BankAccountCount - 1 do begin
              AccountNo := FrequencyRequestForm.BankAccounts[i];
              lBankAccount := AdminSystem.fdSystem_Bank_Account_List.FindCode(AccountNo);
              if Assigned(lBankAccount) then begin
                lBankAccount.sbFrequency_Change_Pending := Byte(True);
                if (i = 0) then
                  SelAccounts := AccountNo
                else
                  SelAccounts := SelAccounts + ',' + AccountNo;
              end;
            end;

            //*** Flag Audit ***
            SystemAuditMgr.FlagAudit(arSystemBankAccounts);

            SaveAdminSystem;
            RefreshBankAccountList(SelAccounts);
          end;
        end;
      end;
    end;
  finally
    FrequencyRequestForm.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.actSendProvReqExecute(Sender: TObject);
begin
  SendProvAccRequest;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.btnOKClick(Sender: TObject);
begin
    ModalResult := mrOK;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.UpdateActions;

   procedure AddDetail(const Value: string);
   begin
       with gbDetails.Items.Add do begin
          Caption := StringReplace(Value, '&', '&&', [rfReplaceAll]);
       end;
   end;

   function UpdateAccountDetails(Value: PSystem_Bank_Account_Rec): Boolean;
   var acMap: pClient_Account_Map_Rec;
       client: pClient_File_Rec;
       lCount: Integer;
   begin
      // Only a single selection
      Result := False;
      lCount := 0;
      gbDetails.Items.BeginUpdate;
      try
         gbDetails.Items.Clear;
         if not Assigned(Value) then
            Exit;
         AddDetail(Value.sbAccount_Number);
         AddDetail(Value.sbAccount_Name);
         if not Value.sbAttach_Required then begin
            acMap := Adminsystem.fdSystem_Client_Account_Map.FindFirstClient(Value.sbLRN);
            while Assigned(acMap) do begin
               // Add any Clients
               client := AdminSystem.fdSystem_Client_File_List.FindLRN(acmap.amClient_LRN);
               if Assigned(client) then begin
                   inc(LCount);
                   if lCount > 4 then begin
                      AddDetail('    ...    ');
                      Break;
                   end;
                   AddDetail(format('%s, %s',[Client.cfFile_Code, Client.cfFile_Name]));
               end;
               acMap := Adminsystem.fdSystem_Client_Account_Map.FindNextClient(Value.sbLRN);
            end;
         end;

         // Since we know its only one..
         actDelete.Enabled := not Value.sbMark_As_Deleted;
         if value.sbNo_Charge_Account then
            actCharge.ImageIndex := Manager_SingleNoTick
         else
            actCharge.ImageIndex := Manager_SingleTick;
         actEdit.Enabled := True;

         actRemove.Enabled := True;
         actCharge.Enabled := True;
         actSendDelete.Enabled := True;
         actSendFrequencyRequest.Enabled := not Value.sbMark_As_Deleted;
         acAddProvTrans.Enabled := (Value.sbAccount_Type = sbtProvisional) and
                                   (Value.sbWas_On_Latest_Disk);

         Result := True;
      finally
         gbDetails.Items.EndUpdate;
      end;

   end;

   function UpdateAccountsDetails: Boolean;
   const MaxAccounts = 10;
   var lNode: pvirtualnode;
       DelCount,
       totCount,
       NoChargeCount: Integer;
       ba : TSABaseItem;
   begin
      //Multiple accounts selected
      Result := False;
      DelCount := 0;
      NoChargeCount:= 0;
      TotCount := 0;
      gbDetails.Items.BeginUpdate;
      try
         gbDetails.Items.Clear;
         lNode := SysAccounts.AccountTree.GetFirstSelected;
         while Assigned(lNode) do begin
            ba := SysAccounts.Accounts[lNode];
            if Assigned(ba.SysAccount) then begin
               inc(totCount);
               if totCount = MaxAccounts then
                  AddDetail('    ...    ')
               else if TotCount < MaxAccounts then
                  AddDetail(ba.SysAccount.sbAccount_Number);

               if ba.SysAccount.sbMark_As_Deleted then
                  inc(DelCount);

               if ba.SysAccount.sbNo_Charge_Account then
                  inc(NoChargeCount);
            end;
            lNode := SysAccounts.AccountTree.GetNextSelected(lNode);
         end;
      finally
        gbDetails.Items.EndUpdate;
      end;
      // Update some of the actions while we are here...
      if TotCount > 0 then begin
         actRemove.Enabled := True;
         actCharge.Enabled := True;
         actSendDelete.Enabled := True;
         actDelete.Enabled := (TotCount - delCount) > 0;

         if (TotCount- NoChargecount) > NoChargeCount then
            //Majority  has Charge..
            actCharge.ImageIndex := Manager_DoubleTick
         else
            actCharge.ImageIndex := Manager_DoubleNoTick;

         actEdit.Enabled := TotCount = 1;

         actSendFrequencyRequest.Visible := SysAccounts.AccountsHaveFrequencyInfo;
         actSendFrequencyRequest.Enabled := ((TotCount - delCount) > 0);
         acAddProvTrans.Enabled := false;
         Result := True;
      end;

   end;
begin
  inherited;
  if not fChanged then
     Exit;
  try

  if SysAccounts.AccountTree.SelectedCount > 0 then begin
      if SysAccounts.AccountTree.SelectedCount = 1 then begin

         if UpdateAccountDetails(SysAccounts.Selected) then
            Exit;
      end else begin
         if UpdateAccountsDetails then
            Exit;
      end;

  end;
  // Still here... Nothing usefull selected
  gbDetails.Items.Clear;
  actEdit.Enabled := False;
  actDelete.Enabled := False;
  actRemove.Enabled := False;
  actCharge.Enabled := False;
  actCharge.ImageIndex := Manager_SingleTick;
  actSendDelete.Enabled := False;
  actSendFrequencyRequest.Enabled := False;
  acAddProvTrans.Enabled := False;
  finally
     fChanged := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.WMDoRefresh(var message: TMessage);
begin
  RefreshBankAccountList;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin

  Handled := False;

  case Msg.CharCode of
    VK_DELETE : if not SysAccounts.EBFind.Focused then begin
                   if actRemove.Visible
                   and actRemove.Enabled then begin
                      actRemove.Execute;
                      Handled := True;
                   end else if actDelete.Enabled then begin
                      actDelete.Execute;
                      Handled := True;
                   end;
                end;


    VK_RETURN : if not SysAccounts.EBFind.Focused then
                   if actEdit.Enabled then begin
                      actEdit.Execute;
                      Handled := True;
                   end;
    VK_ESCAPE : modalResult := mrcancel;

  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.HandleDeletes(AsDoRequest: Boolean);
var
    lNode: PVirtualNode;
    lList: TStringList;
    ldlg: TfrmDeleteRequest;
    lACC: TSABaseItem;
    AllDeleted,
    AllInactive,
    AllOffsite: Boolean;

    function SendTheRequest: Boolean;
    var Recipient, Body: string;
        I: Integer;
    begin
        // Make up the parts...
        Result := False;
        case AdminSystem.fdFields.fdCountry of
           whAustralia: Recipient := TContactInformation.ClientServicesEmail[whAustralia];
           whUK: Recipient := TContactInformation.ClientServicesEmail[whUK];
           else Recipient := TContactInformation.ClientServicesEmail[whNewZealand];
        end;

         Body := format(
         'Please delete the following bank account(s) as at %s'#13#13'%s',
            [bkDate2Str(ldlg.EDate.AsOvcDate),ldlg.EAccounts.Lines.Text]);


         if SendMailTo ('Delete Request', Recipient,
                     Format('%s Delete Account Request',[AdminSystem.fdFields.fdBankLink_Code]),
                     Body) then begin
                        Result := True;
                        for I := 0 to ldlg.EAccounts.Lines.Count - 1 do
                           LogUtil.LogMsg( lmInfo, 'REQUEST_DELETE_SYSTEM_BANK_ACCOUNT',
                             'User Request Deleted System Account ' + ldlg.EAccounts.Lines[i] );

                     end;
    end;

    function DoTheDeletes: Boolean;
    var Selected : tStringList;
        I: Integer;
        ba: pSystem_Bank_Account_Rec;

        function PassOK: Boolean;
        begin
           Result := true;
           if ba^.sbAccount_Password <> '' then
              if not EnterPassword
              (
                 format('Edit Bank Account Details [%s]',[ba.sbAccount_Number]),
                 ba^.sbAccount_Password,0,false,true
              ) then begin
                 Result := False;
                 HelpfulErrorMsg
                          (Format('Invalid Password.'#13'Permission to delete account:'#13'%s, %s'#13'is denied.',[ba.sbAccount_Number, ba.sbAccount_Name]),0);
              end;
        end;
    begin //DoTheDeletes
       Result := False;
       Selected := SysAccounts.GetStringList(SysAccounts.SelectedList);

       try
          // Lock the 'Wrong' AccountList;
          SysAccounts.BeginUpdate;
          try
             if LoadAdminSystem(True, 'MaintainPracBank') then begin
                // The Syssacounts tree items are no longer valid...
                for i := 0 to Selected.Count-1 do begin
                   ba := AdminSystem.fdSystem_Bank_Account_List.FindCode(Selected[i]);
                   if Assigned(ba) then
                   if PassOK then begin
                      //account found in reloaded admin so update
                      ba^.sbMark_As_Deleted  := True;
                      Result := True; // Atleast one is sucsessful
                   end;
                end;
                //*** Flag Audit ***
                SystemAuditMgr.FlagAudit(arSystemBankAccounts);

                SaveAdminSystem;
             end;
             RefreshBankAccountList(Selected.DelimitedText);
          finally
             SysAccounts.EndUpdate;
          end;
       finally
          Selected.Free;
       end;
   end; //DoTheDeletes


begin
   ldlg := TfrmDeleteRequest.Create(self);
   with ldlg do try
      EAccounts.Lines.clear;
      lList := TStringList.Create; // So we can sort the list..
      try
         AllDeleted := True;
         AllInactive := True;
         AllOffsite := True;
         lNode := SysAccounts.AccountTree.GetFirstSelected;
         while Assigned(lNode) do begin
            lACC := SysAccounts.Accounts[lNode];
            if Assigned(lAcc.SysAccount) then begin
                 lList.Add( format('%s, %s',
                    [SysAccounts.Accounts[lNode].SysAccount.sbAccount_Number,
                     SysAccounts.Accounts[lNode].SysAccount.sbAccount_Name]));
                 if not lAcc.SysAccount.sbMark_As_Deleted then
                    AllDeleted := False;
                 if not lAcc.SysAccount.sbInActive then
                    AllInactive := False;
                 if not lAcc.IsOffsite then
                    AllOffsite := False;
            end;

            lNode := SysAccounts.AccountTree.GetNextSelected(lNode);
         end;
         lList.Sort;
         EAccounts.text := LList.Text;
      finally
         Llist.Free;
      end;

      // Configure the dialog.
      DoRequest := AsDoRequest;
      if AsDoRequest then begin
         if AllDeleted then
             PTop.Visible := False; // no point if they are already deleted..
      end else begin
         {if AllInactive then
             PTop.Visible := False;} // no point sending and email, If we already tolled them
      end;
      LDownload.Visible := not AllOffsite;

      //*** Run the Dialog ******
      if ShowModal = mrOK then begin
          if AsDoRequest then begin
             if SendTheRequest then
                 if Checkbox.Checked then // Check the other action
                    DoTheDeletes;
          end else begin
             if DoTheDeletes then
                if Checkbox.Checked then // Check the other action
                   SendTheRequest;
          end;
      end;
   finally
      FChanged := True;
      ldlg.Free;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.ManuallyAddProvTrans(ForAccount: string);
begin
   AddProvisionalData(ForAccount);
   // System refreshed...
   RefreshBankAccountList(ForAccount);
end;

//------------------------------------------------------------------------------
function TfrmMaintainPracBank.Execute(Mode: Integer): boolean;
const Offset = 30;
begin
   //Position the form..
   SetBounds(Application.Mainform.Left + Offset,Application.Mainform.Top + Offset,
             Application.Mainform.Width - Offset * 2, Application.Mainform.Height - Offset * 2);

   // set the mode
   case Mode of
    mpba_Inactive: SysAccounts.cbFilter.ItemIndex := cbf_Inactive;
    else SysAccounts.cbFilter.ItemIndex := cbf_All;
   end;
   // activate the mode
   SysAccounts.cbFilterChange(nil);

   ShowModal;
   Result := true;
end;

//------------------------------------------------------------------------------
function MaintainPracticeBankAccounts(Mode: Integer) : boolean;
var
  MyDlg : TfrmMaintainPracBank;
begin
  MyDlg := TfrmMaintainPracBank.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, BKH_Bank_Accounts);
    MyDlg.Execute(Mode);
    result := true;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.OnSelChange(Sender: TObject);
begin
   fChanged := true;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.pmGridPopup(Sender: TObject);

  procedure AddMenuItem(Value: tAction);
   var it: TMenuItem;
   begin
      if not Value.Enabled then
         Exit;
      it := TMenuItem.Create(Pmgrid);
      it.Action := Value;
      Pmgrid.Items.Add(it);
   end;
 procedure AddSep;
   var it: TMenuItem;
   begin
      it := TMenuItem.Create(Pmgrid);
      it.caption := '-';
      Pmgrid.Items.Add(it);
   end;

begin
   Pmgrid.Items.Clear;
   AddMenuItem(actNew);
   AddMenuItem(actEdit);
   AddMenuItem(actDelete);
   AddMenuItem(actremove);
   AddSep;

   AddMenuItem(actCharge);
   AddMenuItem(actSendDelete);
   AddSep;
   AddMenuItem(SysAccounts.actFilter);
   AddMenuItem(SysAccounts.actReset);
   AddSep;
   AddMenuItem(SysAccounts.actRestoreColumns);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPracBank.SendProvAccRequest;
var
  SendProvAccRequestForm: TfrmSendProvAccRequest;
  SystemAccount: pSystem_Bank_Account_Rec;
  lSel: string;
begin
  lsel := '';
  SendProvAccRequestForm := TfrmSendProvAccRequest.Create(Self);
  try
     if SendProvAccRequestForm.ShowModal = mrOk then begin
        // ShowMessage('ok');
        if LoadAdminSystem(true, 'Provisional Account') then begin
           // for all intended purposes, it can be trated as delivered..
           SystemAccount := AdminSystem.NewSystemAccount(SendProvAccRequestForm.AccountNumber, True);
           SystemAccount.sbAccount_Name := SendProvAccRequestForm.AccountName;
           SystemAccount.sbAccount_Type := sbtProvisional;
           SystemAccount.sbWas_On_Latest_Disk := True;
           SystemAccount.sbInstitution := SendProvAccRequestForm.Institution;
           SystemAccount.sbCurrency_Code := SendProvAccRequestForm.Currency;
           // So we can select it..
           lsel := SystemAccount.sbAccount_Number;

           //*** Flag Audit ***
           SystemAuditMgr.FlagAudit(arSystemBankAccounts);

           SaveAdminSystem;
        end;
     end;
  finally
     SendProvAccRequestForm.Free;
  end;

  RefreshBankAccountList(lSel);
  // Since it is a new one...
  SysAccounts.AccountTree.ScrollIntoView(SysAccounts.AccountTree.GetFirstSelected, true);

end;

end.
