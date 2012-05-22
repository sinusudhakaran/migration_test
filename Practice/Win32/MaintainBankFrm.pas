unit MaintainBankFrm;

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
  baObj32,
  ActnList,
  AuditMgr,
  BankLinkOnlineServices,
  OsFont;

type
  TfrmMaintainBank = class(TForm)
    ToolBar1: TToolBar;
    tbAttach: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    tbClose: TToolButton;
    lvBank: TListView;
    tbAddNew: TToolButton;
    ActionList1: TActionList;
    actCreate: TAction;
    actAttach: TAction;
    tbHelpSep: TToolButton;
    tbHelp: TToolButton;
    procedure tbCloseClick(Sender: TObject);
    procedure lvBankCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvBankColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvBankDblClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tbEditClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbDeleteClick(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);
    procedure actAttachExecute(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure lvBankCustomDrawSubItem(Sender: TCustomListView;
                                      Item: TListItem;
                                      SubItem: Integer;
                                      State: TCustomDrawState;
                                      var DefaultDraw: Boolean);
  private
    fOnlineVendorStartCol : integer;
    fOnlineVendorEndCol : integer;
    fClientAccVendors : TClientAccVendors;
    fExportDataEnabled : Boolean;
    SortCol : integer;
    FUpdateRefNeeded: boolean;
    AccountChanged : Boolean;
    CurrencyColumnShowing: boolean;

    procedure UpdateLastVendorsUsedByAccounts;
    function GetAccountIndexOnVendorList(aAccountNumber : string) : integer;
    procedure ShowCurrencyColumn;
    procedure HideCurrencyColumn;
    procedure RefreshExportVendors;
    procedure AddOnlineExportVendors;
    procedure RefreshBankAccountList;
    function DeleteBankAccount(BankAccount : TBank_Account) :boolean;
    procedure SetUpdateRefNeeded(const Value: boolean);
    procedure UpdateISOCodes;

    {$IFNDEF SmartBooks}
    procedure CreateManualAccount;
    {$ENDIF}
  public
    function Execute : boolean;
    property UpdateRefNeeded : boolean read FUpdateRefNeeded write SetUpdateRefNeeded;
  end;

function MaintainBankAccounts(ContextID : Integer) : boolean;

//------------------------------------------------------------------------------
implementation

{$R *.DFM}

uses
  ClientHomepageFrm,
  BKHelp,
  bkXPThemes,
  globals,
  StStrS,
  StDate,
  bkDateUtils,
  admin32,
  imagesfrm,
  EditBankDlg,
  dlgNewBank,
  WarningMorefrm,
  YesNoDlg,
  LogUtil,
  EnterPwdDlg,
  merge32,
  LvUtils,
  bkConst,
  Software,
  UpdateMF,
  MoneyDef,
  InfoMoreFrm,
  BKDEFS,
  clObj32,
  BaList32,
  sydefs,
  ErrorMoreFrm,
  BKUtil32,
  BAUtils,
  Math,
  CommCtrl,
  strutils,
  genutils,
  GLConst;

const
  COL_ACCOUNT_NO    = 0;
  COL_ACCOUNT_NAME  = 1;
  COL_CURRENCY      = 2;
  COL_CHART_CODE    = 3;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.FormCreate(Sender: TObject);
var
  ContraColumn: TListColumn;
begin
  bkXPThemes.ThemeForm( Self);

  tbAttach.Enabled  := Assigned( AdminSystem) and CurrUser.CanAccessAdmin and (not MyClient.clFields.clFile_Read_Only);
  tbDelete.Enabled  := CurrUser.CanAccessAdmin;

  actCreate.Enabled := (not MyClient.clFields.clFile_Read_Only) and ((not Assigned(AdminSystem)) or CurrUser.CanAccessAdmin);

  //Add currency column for UK multi-currency
  if (MyClient.clFields.clCountry = whUK) and (MyClient.HasForeignCurrencyAccounts)
    then ShowCurrencyColumn
    else HideCurrencyColumn;

  //Contra column
  ContraColumn := lvBank.Columns.Add;
  ContraColumn.Caption := 'Contra';
  ContraColumn.Width := 100;

  fExportDataEnabled := ProductConfigService.IsExportDataEnabled;

  if fExportDataEnabled then
    AddOnlineExportVendors;

  LVUTILS.SetListViewColWidth(lvBank,1);
  UpdateRefNeeded := false;
  SetUpHelp;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tbAttach.Hint    :=
                    'Attach a new Bank Account to this Client File|' +
                    'Attach a new Bank Account to this Client File';
   tbEdit.Hint      :=
                    'Edit the Bank Account details for the selected Account|' +
                    'Edit the Bank Account details for the selected Account';
   tbDelete.Hint    :=
                    'Delete the selected Bank Account|' +
                    'Delete the selected Bank Account';
   tbAddNew.hint    :=
                    'Create a ' + UserDefinedBankAccountDesc + '|'+
                    'Create a ' + UserDefinedBankAccountDesc + ' to enter Manual Entries into';

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.ShowCurrencyColumn;
begin
  lvBank.Columns.Items[COL_CURRENCY].Width := 80;
  CurrencyColumnShowing := true;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.HideCurrencyColumn;
begin
  lvBank.Columns.Items[COL_CURRENCY].Width := 0;
  CurrencyColumnShowing := false;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.RefreshExportVendors;
begin
  // Blopi Call
  ProductConfigService.GetClientAccountsVendors(MyClient.clFields.clCode, '', fClientAccVendors, True);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.AddOnlineExportVendors;
var
  NewColumn    : TListColumn;
  VendorIndex  : integer;
  BankAccIndex : integer;
begin
  // Service Call
  RefreshExportVendors;

  // Adds Needed Columns
  if fClientAccVendors.ClientID <> '' then
  begin
    for VendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
    begin
      NewColumn := lvBank.Columns.Add;
      NewColumn.Caption := fClientAccVendors.ClientVendors[VendorIndex].Name_;
      NewColumn.Width := 120;

      if VendorIndex = 0 then
        fOnlineVendorStartCol := NewColumn.Index;

      if VendorIndex = high(fClientAccVendors.ClientVendors) then
        fOnlineVendorEndCol := NewColumn.Index;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.RefreshBankAccountList;
var
  NewItem  : TListItem;
  BankAcct : TBank_Account;
  i : integer;
  CurrencyColumn: TListColumn;
  ColumnStrings: TStrings;
  ClientVendorIndex : integer;
  AccountVendorIndex : integer;
  Found : Boolean;
  SubItemIndex : integer;
  AccVendorIndex : integer;
  VendorFirstIndex : integer;
begin
  if (MyClient.clFields.clCountry = whUK) and (MyClient.HasForeignCurrencyAccounts) then
  begin
    if not CurrencyColumnShowing then
      ShowCurrencyColumn;
  end
  else
  begin
    if CurrencyColumnShowing then
      HideCurrencyColumn;
  end;

  lvBank.Items.beginUpdate;
  try
    lvBank.Items.Clear;

    for i := 0 to Pred(MyClient.clBank_Account_List.itemCount) do
    begin
      BankAcct := MyClient.clBank_Account_List.Bank_Account_At(i);

      if BankAcct.baFields.baAccount_Type <> btStockBalances then
      begin
        NewItem := lvBank.Items.Add;
        NewItem.Caption := BankAcct.baFields.baBank_Account_Number;

        if AccountVisible(BankAcct) then  {check if visible in coding window}
          NewItem.ImageIndex := MAINTAIN_PAGE_OPEN_BMP
        else
          NewItem.ImageIndex := MAINTAIN_PAGE_NORMAL_BMP;

        if ( BankAcct.baFields.baAccount_Type = btBank ) and
           ContraCodeRequired( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used ) and
           ( BankAcct.baFields.baContra_Account_Code = '' ) then
          NewItem.ImageIndex := MAINTAIN_ALERT;

        NewItem.SubItems.AddObject(BankAcct.baFields.baBank_Account_Name,BankAcct);

        if (MyClient.clFields.clCountry = whUK) and (MyClient.HasForeignCurrencyAccounts) then
        begin
          if CurrencyColumnShowing then
          begin
            NewItem.SubItems.Add(BankAcct.baFields.baCurrency_Code);
            NewItem.SubItems.Add(BankAcct.baFields.baContra_Account_Code);
          end
          else
          begin
            NewItem.SubItems.Add(BankAcct.baFields.baCurrency_Code);
            NewItem.SubItems.Add(BankAcct.baFields.baContra_Account_Code);
          end;
        end
        else
          NewItem.SubItems.Add(''); // blank currency code

        NewItem.SubItems.Add(BankAcct.baFields.baContra_Account_Code);
      end;

      // For this account Get the Vendor data and updates extra columns
      if (fExportDataEnabled) then
      begin
        for ClientVendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
          if ClientVendorIndex = 0 then
            VendorFirstIndex := NewItem.SubItems.Add('0')
          else
            NewItem.SubItems.Add('0');
      end;


      if (fExportDataEnabled) and
         (fClientAccVendors.ClientID <> '') then
      begin
        AccVendorIndex := GetAccountIndexOnVendorList(BankAcct.baFields.baBank_Account_Number);
        if (ProductConfigService.IsExportDataEnabledFoAccount(BankAcct)) and
           (AccVendorIndex > -1) then
        begin
          for ClientVendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
          begin
            Found := False;
            for AccountVendorIndex := 0 to High(fClientAccVendors.AccountsVendors[AccVendorIndex].AccountVendors.Current) do
            begin
              if fClientAccVendors.AccountsVendors[AccVendorIndex].AccountVendors.Current[AccountVendorIndex].Id =
                 fClientAccVendors.ClientVendors[ClientVendorIndex].Id then
              begin
                Found := True;
                break;
              end;
            end;

            if Found then
              NewItem.SubItems.Strings[VendorFirstIndex + ClientVendorIndex] := '1';
          end;
        end;
      end;
    end;
    UpdateLastVendorsUsedByAccounts;

  finally
    lvBank.items.EndUpdate;
  end;

  if lvBank.items.count > 0 then
  begin
    lvBank.selected := lvBank.items[0];
    lvBank.selected.Focused := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.tbCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.lvBankCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
begin
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
     end;
  end; {case}

  Compare := StStrS.CompStringS(Key1,Key2);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.lvBankCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);

  //------------------------------------------------------
  function GetSubItemLeft(aItemIndex : integer) : integer;
  var
    ItemIndex : integer;
  begin
    Result := 0;
    for ItemIndex := 0 to aItemIndex do
      Result := Result + lvBank.Columns[ItemIndex].Width;
  end;

var
  ItemRect : TRect;
  SubItemRect : TRect;
  OutputText : String;
  SubItemIndex : integer;
  First : Boolean;
  SubItemLeft : integer;
  SubItemTop  : integer;
  bmpSelected : TBitmap;
begin
  if not assigned(Item) then
    Exit;

  SubItemIndex := SubItem-1;

  DefaultDraw := false;

  SetBkMode(lvBank.Canvas.Handle, TRANSPARENT);
  ListView_SetTextBkColor(lvBank.Handle, CLR_NONE);
  ListView_SetBKColor(lvBank.Handle, CLR_NONE);

  ItemRect := Item.DisplayRect(drBounds);
  SubItemRect := ItemRect;
  SubItemRect.left  := ItemRect.Left + GetSubItemLeft(SubItemIndex);
  SubItemRect.right := ItemRect.left + GetSubItemLeft(SubItemIndex+1);

  SubItemLeft := ItemRect.Left + GetSubItemLeft(SubItemIndex);
  SubItemTop  := ItemRect.Top + 2;

  if (SubItem >= fOnlineVendorStartCol) and
     (SubItem <= fOnlineVendorEndCol) then
  begin
    bmpSelected := TBitmap.create;
    try
      If (cdsFocused  in State) and
         (cdsSelected in State) then
        AppImages.Maintain.GetBitmap(MAINTAIN_SELECT, bmpSelected);

      if Item.SubItems[SubItemIndex] = '1' then
        AppImages.Maintain.GetBitmap(MAINTAIN_ONLINE, bmpSelected);

      Sender.Canvas.Draw(SubItemLeft+30, SubItemTop, bmpSelected);
    finally
      FreeandNil(bmpSelected);
    end;
  end
  else
  begin
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

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.lvBankColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvBank.columns.Count-1 do
    lvBank.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortCol := Column.ID;
  LvBank.AlphaSort;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.lvBankDblClick(Sender: TObject);
begin
  tbEdit.Click;
end;

//------------------------------------------------------------------------------
function TfrmMaintainBank.DeleteBankAccount(
  BankAccount: TBank_Account): boolean;
var
  AcctNo : string;
  AcctName : string;
  aMsg : string;
  Title : string;
  pS: pSystem_Bank_Account_Rec;
  i: Integer;
  pF: pClient_File_Rec;
  AccVendorIndex : integer;
  DlgResult : integer;
  fRemoveVendorsFromClient : boolean;
  fRemoveVendorsFromClientList : TBloArrayOfGuid;
  CurrentVendors : TBloArrayOfGuid;
  IsExportDataEnabledFoAccount : Boolean;

  //------------------------------------------------------------------------------
  function AllAccountsHaveOneVendorSelected(aAccVendorIndex : integer;
                                            out aMessage : string) : Boolean;
  var
    VendorIndex : integer;
    VendorId : TBloGuid;
    VendorNames : Array of String;
    VendorStr : String;
    AccountVendors : TAccountVendors;
  begin
    Result := false;
    SetLength(VendorNames, 0);
    aMessage := '';
    AccountVendors := fClientAccVendors.AccountsVendors[aAccVendorIndex];

    Setlength(fRemoveVendorsFromClientList,0);
    for VendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
    begin
      if AccountVendors.IsLastAccForVendors[VendorIndex] then
      begin
        SetLength(VendorNames, length(VendorNames)+1);
        VendorNames[High(VendorNames)] := AccountVendors.AccountVendors.Available[VendorIndex].Name_;
      end
      else
      begin
        Setlength(fRemoveVendorsFromClientList, length(fRemoveVendorsFromClientList) + 1);
        fRemoveVendorsFromClientList[high(fRemoveVendorsFromClientList)] :=
          AccountVendors.AccountVendors.Available[VendorIndex].Id;
      end;
    end;

    VendorStr := GetCommaSepStrFromList(VendorNames);

    if Length(VendorNames) > 0 then
    begin
      aMessage := 'Client ' + MyClient.clFields.clCode + ' no longer has any bank accounts using ' + VendorStr + '.' + #10 +
                  'Would you like BankLink Practice to remove ' + VendorStr + ' for this client?';
      Result := True;
    end;
  end;

begin
  result := false;

  {check that is not showing in coding screen}
  if AccountVisible(BankAccount) then
  begin
    HelpfulWarningMsg('You cannot delete this Bank Account because you are currently Coding Entries for it.',0);
    exit;
  end;

  if (BankAccount.baFields.baAccount_Type = btBank) then
  begin
     if BankAccount.IsManual then
       aMsg := 'Deleting a ' + UserDefinedBankAccountDesc + ' will remove all transactions and coding information.'

     else
        aMsg := 'Deleting a Bank Account will remove all transactions and coding '+
                'information for the Account.  A copy of these transactions is stored in the Admin system, '+
                'however no Coding Information, or Unpresented Items are stored.  ';

     aMsg := aMsg + #13#13+
             'This is a CRITICAL operation.  Are you sure '+
             'you want to delete the following Account from this Client File?';

     aMsg := aMsg + #13+#13+ BankAccount.baFields.baBank_Account_Number+ ' - ' +
                 BankAccount.AccountName;
     Title := 'Delete Client Bank Account';
  end
  else
  begin
     //is a journal
     aMsg := 'Deleting a Journal Account will remove all journals and coding '+
            'information for this Journal type.'+#13+#13+

            'This is a CRITICAL operation.  Are you sure '+
            'you want to delete the following Journal Account from this Client File?';
     aMsg := aMsg + #13+#13+ BankAccount.baFields.baBank_Account_Number+ ' - ' +
                 BankAccount.AccountName;
     Title := 'Delete Journal Account';
  end;

  if (AskYesNo(Title,aMsg,DLG_NO,0) = DLG_YES) then
  begin
    if not EnterPassword('Enter the word DELETE in the box below to confirm deletion','DELETE',0, false,false) then exit;
  end
  else
    exit;

  IsExportDataEnabledFoAccount := ProductConfigService.IsExportDataEnabledFoAccount(BankAccount);
  fRemoveVendorsFromClient := false;
  if IsExportDataEnabledFoAccount then
  begin
    AccVendorIndex := GetAccountIndexOnVendorList(BankAccount.baFields.baBank_Account_Number);
    if (AccVendorIndex > -1) then
    begin
      if AllAccountsHaveOneVendorSelected(AccVendorIndex, aMsg) then
      begin
        DlgResult := AskYesNo('Export Options removed', aMsg, DLG_YES, 0, true);

        case DlgResult of
          DLG_YES : begin
            fRemoveVendorsFromClient := true;
          end;
          DLG_CANCEL : begin
            Exit;
          end;
        end;
      end;
    end;
  end;

  {do the deletion}
  if LoadAdminSystem(true, 'TfrmMaintainBank.tbDeleteClick' ) then
  begin
    AcctNo := BankAccount.baFields.baBank_Account_Number;
    AcctName := BankAccount.baFields.baBank_Account_Name;
    MyClient.clBank_Account_List.DelFreeItem(BankAccount);
    // Delete from client-account map
    if not MyClient.clFields.clFile_Read_Only then
    begin
      pS := AdminSystem.fdSystem_Bank_Account_List.FindCode(AcctNo);
      if Assigned(pS) then
      begin
        pF := AdminSystem.fdSystem_Client_File_List.FindCode(MyClient.clFields.clCode);
        if Assigned(pF) then
        begin
          i := AdminSystem.fdSystem_Client_Account_Map.FindIndexOf(pS^.sbLRN, pF^.cfLRN);
          if i > -1 then
            AdminSystem.fdSystem_Client_Account_Map.AtDelete(i);
          //Update ISO Code list
          AdminSystem.HasCurrencyBankAccount('');
        end;
        // Update unattached flag
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pS^.sbLRN)) then
          pS.sbAttach_Required := True;
      end;
    end;

    //*** Flag Audit ***
    SystemAuditMgr.FlagAudit(arAttachBankAccounts);

    SaveAdminSystem;
    result := true;
  end
  else
    HelpfulErrorMsg('Unable to Delete Bank Account.  Admin System cannot be loaded',0);

  if (Result) and
     (IsExportDataEnabledFoAccount) then
  begin
    if fRemoveVendorsFromClient then
    begin
      try
        Result := ProductConfigService.SaveClientVendorExports(fClientAccVendors.ClientID,
                                                               fRemoveVendorsFromClientList,
                                                               true,
                                                               true,
                                                               False);
      finally
        fRemoveVendorsFromClient := false;
      end;

      if Result then
      begin
        // Remove All Vendor Columns
        for i := 0 to high(fClientAccVendors.ClientVendors) do
          lvBank.Columns.Delete(lvBank.Columns.Count-1);

        AddOnlineExportVendors;
      end;
    end;

    if Result then
    begin
      SetLength(CurrentVendors, 0);
      Result := ProductConfigService.SaveAccountVendorExports(fClientAccVendors.ClientID,
                                                              AcctNo,
                                                              CurrentVendors,
                                                              True);
    end;
  end;

  LogUtil.LogMsg(lmInfo,'MAINTAINBANKFRM','User Delete Bank Account '+AcctNo+' - '+AcctName);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.tbEditClick(Sender: TObject);
var
  B: TBank_Account;
  Result: Boolean;
  AccIndex : integer;
  VendorIndex : integer;
begin
  if lvBank.Selected <> nil then
  begin
    B := TBank_Account(lvBank.Selected.SubItems.Objects[0]);
    if B.IsManual then // a/c number may of changed - need to re-insert in the correct position
       MyClient.clBank_Account_List.Delete(B);

    AccIndex := GetAccountIndexOnVendorList(B.baFields.baBank_Account_Number);
    Result := EditBankAccount(B, fClientAccVendors.AccountsVendors[AccIndex], fClientAccVendors.ClientId);

    if B.IsManual then
       MyClient.clBank_Account_List.Insert(B);

    if Result then
    begin
      // if the Client Vendors have been changed the window will need a refresh of the data
      if fClientAccVendors.AccountsVendors[AccIndex].ClientNeedRefresh then
      begin
        fClientAccVendors.AccountsVendors[AccIndex].ClientNeedRefresh := false;

        // Remove All Vendor Columns
        for VendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
          lvBank.Columns.Delete(lvBank.Columns.Count-1);

        AddOnlineExportVendors;
      end;

      AccountChanged := True;
      RefreshBankAccountList;

      //*** Flag Audit ***
      MyClient.FClientAuditMgr.FlagAudit(arClientBankAccounts);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  Handled := true;
  case Msg.CharCode of
    //VK_INSERT : Handled by action list!!!
    VK_DELETE : tbDelete.click;
    VK_RETURN : tbEdit.click;
    VK_ESCAPE : tbClose.click;
  else
    Handled := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.tbDeleteClick(Sender: TObject);
var
  BASelected : TBank_Account;
  PrevSelectedIndex: Integer;
  PrevTopIndex: Integer;
begin
  if (CurrUser.CanAccessAdmin) then
  begin
    if lvBank.Selected <> nil then
    begin
      BASelected := TBank_Account(lvBank.Selected.SubItems.Objects[0]);
      if (baSelected.baFields.baAccount_Type = btBank)
      and (CountManualBankAccounts > 0)
      and (not baSelected.IsManual)
      and (CountDeliveredBankAccounts = 1)
      and MDEExpired(MyClient.clBank_Account_List, MyClient.clFields.clLast_Use_Date, True) then // must have a live bank account
      begin
         HelpfulWarningMsg('You cannot delete this bank account until you have removed all of your ' + UserDefinedBankAccountDesc + 's.', 0);
         exit;
      end;
      PrevSelectedIndex := lvBank.Selected.Index;
      PrevTopIndex := lvBank.TopItem.Index;
      if DeleteBankAccount( BASelected) then
      begin
       UpdateRefNeeded := true;
       AccountChanged := True;
       RefreshBankAccountList;

       //*** Flag Audit ***
       MyClient.FClientAuditMgr.FlagAudit(arClientBankAccounts);

       //Update ISO Codes in Client_File_Rec
       UpdateISOCodes;
       ReselectAndScroll(lvBank, PrevSelectedIndex, PrevTopIndex);
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.SetUpdateRefNeeded(const Value: boolean);
begin
  FUpdateRefNeeded := Value;
end;

//------------------------------------------------------------------------------
function TfrmMaintainBank.Execute: boolean;
begin
  SortCol := 0;
  lvBank.AlphaSort;

  ShowModal;
  result := true;
  RefreshHomepage([HPR_Coding]);
  //check if a bank account was added or deleted
  if UpdateRefNeeded then
    MyClient.UpdateRefs;
end;

//------------------------------------------------------------------------------
function MaintainBankAccounts(ContextID : Integer) : boolean;
//always return true at this stage
var
  MyDlg : TfrmMaintainBank;
begin
  MyDlg := TfrmMaintainBank.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, ContextID);
    MyDlg.AccountChanged := False;
    MyDlg.Execute;
    Result := MyDlg.AccountChanged;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.actCreateExecute(Sender: TObject);
begin
{$IFDEF Smartbooks}
   if AddBankAccount then
   begin
     AccountChanged := True;
     RefreshBankAccountList;
   end;
{$ELSE}
   CreateManualAccount;
{$ENDIF}
end;

//------------------------------------------------------------------------------
{$IFNDEF SmartBooks}
procedure TfrmMaintainBank.CreateManualAccount;
var
  DummyAccount          : TBank_Account;
  aMsg                  : string;
  AllowUnlimitedDate    : boolean;
  ExpiryDate, ED, TD    : integer;
  DummyAccVendor        : TAccountVendors;
begin
  if MDEExpired(MyClient.clBank_Account_List, MyClient.clFields.clLast_Use_Date) then
  begin
     HelpfulWarningMsg( 'You cannot add ' + UserDefinedBankAccountDesc + 's to this client file ' +
                     'because your ' + UserDefinedBankAccountDesc + 's have expired.'#13#13 +
                     'You must receive live data into this client file to continue using ' + UserDefinedBankAccountDesc + 's.',0);
     exit;
  end;

  ED := GetMDEExpiryDate(MyClient.clBank_Account_List);
  TD := GetLatestTransDate(MyClient.clBank_Account_List);
  if TD = 0 then // no live data, based on manual a/c expiry
    ExpiryDate := ED
  else // live data
  begin
    if ED = 0 then
      ED := IncDate( CurrentDate, 0, MaxHDETempMths ,0) - 1;
    ExpiryDate := Max(ED, IncDate( TD, 0, MaxHDETempMths ,0) - 1);
  end;
  if ExpiryDate = 0 then // e.g. no accounts
    ExpiryDate := IncDate( CurrentDate, 0, MaxHDETempMths ,0) - 1;
    
  if RefreshAdmin then begin
    AllowUnlimitedDate := AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts];
  end
  else
    AllowUnlimitedDate := false;

  aMsg := 'This will add a ' + UserDefinedBankAccountDesc + ' to this Client File.'#13#13+
          'Please note:  This account CANNOT be used to retrieve bank entries!';

   if not AllowUnlimitedDate then begin
      aMsg := aMsg + #13#13 + 'This account will expire on ' + bkDate2Str( ExpiryDate) +' unless you receive live data into this client file.';
   end;

   aMsg := aMsg + #13#13+ 'Do you wish to proceed?';

   If AskYesNo( 'Add ' + UserDefinedBankAccountDesc, aMsg, DLG_NO ,0) <> DLG_YES then
     exit;

   MyClient.clFields.clHighest_Manual_Account_No := MyClient.clFields.clHighest_Manual_Account_No + 1;

   //create a dummy bank account
   DummyAccount := TBank_Account.Create(MyClient);
   with DummyAccount.baFields do begin
      baBank_Account_Number := '';
      baCurrent_Balance     := UNKNOWN;
      baAccount_Expiry_Date := ExpiryDate;
      baIs_A_Manual_Account := True;
      baCurrent_Balance := 0;
      baDesktop_Super_Ledger_ID := -1;
      baCurrency_Code         := MyClient.clExtra.ceLocal_Currency_Code;
   end;

   //call add dummy account
   if EditBankAccount( DummyAccount, DummyAccVendor, '', True) then begin
      //if user did not cancel add account to client
      MyClient.clBank_Account_List.Insert( DummyAccount);
      //Update ISO Codes in Client_File_Rec
      UpdateISOCodes;
      RefreshBankAccountList;
      AccountChanged := True;
   end
   else begin
      //user cancelled so destroy account
      DummyAccount.Free;
   end;
end;
{$ENDIF}

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.actAttachExecute(Sender: TObject);
begin
  if (CurrUser.CanAccessAdmin) and (not MyClient.clFields.clFile_Read_Only) then
  begin
    if AddNewAccountToClient then
    begin
      UpdateRefNeeded := true;
      AccountChanged := True;
      RefreshBankAccountList;

      //try to download any new transactions into the client
      SyncClientToAdmin(MyClient,false);

      //*** Flag Audit ***
      MyClient.FClientAuditMgr.FlagAudit(arClientBankAccounts);
      //Have to save Client file if bank account is provisional so that
      //transactions cannot be altered before audit.
      if MyClient.ClientAuditMgr.ProvisionalAccountAttached then begin
        MyClient.Save;
        MyClient.ClientAuditMgr.ProvisionalAccountAttached := False;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.UpdateISOCodes;
var
  i: integer;
  b: TBank_Account;
  pF: pClient_File_Rec;
begin
  if MyClient.clFields.clFile_Read_Only then Exit;

  if Assigned(AdminSystem) then begin
    //Save
    if LoadAdminSystem(true, 'TfrmMaintainBank.UpdateISOCodes' ) then begin
      pF := AdminSystem.fdSystem_Client_File_List.FindCode(MyClient.clFields.clCode);
      if Assigned(pF) then begin
        AdminSystem.ClearISOCodes(pF);
        for i := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do begin
          b := MyClient.clBank_Account_List.Bank_Account_At(i);
          AdminSystem.AddISOCode(pF, b.baFields.baCurrency_Code);
        end;
      end;
      SaveAdminSystem;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.FormShow(Sender: TObject);
begin
  RefreshBankAccountList;

  lvBankColumnClick(lvBank, lvBank.Columns[0]); // force sort by number
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.UpdateLastVendorsUsedByAccounts;
var
  AccountIndex : integer;
  VendorIndex : integer;
  VendorGuid : TBloGuid;
  CurrentId : Integer;
  VendorCount : integer;
  AccSelIndex : integer;
begin

  // Clears the IsLastAccForVendors Array
  for AccountIndex := 0 to high(fClientAccVendors.AccountsVendors) do
  begin
    SetLength(fClientAccVendors.AccountsVendors[AccountIndex].IsLastAccForVendors,
              length(fClientAccVendors.ClientVendors));

    for VendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
      fClientAccVendors.AccountsVendors[AccountIndex].IsLastAccForVendors[VendorIndex] := false;
  end;

  for VendorIndex := 0 to high(fClientAccVendors.ClientVendors) do
  begin
    VendorGuid := fClientAccVendors.ClientVendors[VendorIndex].Id;
    VendorCount := 0;

    // Searches for Vendors through all Valid Accounts and if there is only one
    // left in the Current Vendor Set the Flag
    for AccountIndex := 0 to high(fClientAccVendors.AccountsVendors) do
    begin
      if fClientAccVendors.AccountsVendors[AccountIndex].ExportDataEnabled then
      begin
        for CurrentId := 0 to high(fClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current) do
        begin
          if VendorGuid = fClientAccVendors.AccountsVendors[AccountIndex].AccountVendors.Current[CurrentId].Id then
          begin
            inc(VendorCount);
            AccSelIndex := AccountIndex;
          end;
        end;
      end;
    end;

    if VendorCount = 1 then
    begin
      fClientAccVendors.AccountsVendors[AccSelIndex].IsLastAccForVendors[VendorIndex] := True;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TfrmMaintainBank.GetAccountIndexOnVendorList(aAccountNumber: string) : integer;
var
  AccountIndex : integer;
begin
  // uses the AccountNumber to get the Index
  Result := -1;
  for AccountIndex := 0 to high(fClientAccVendors.AccountsVendors) do
  begin
    if aAccountNumber = fClientAccVendors.AccountsVendors[AccountIndex].AccountNumber then
    begin
      Result := AccountIndex;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  UpdateMenus;
end;

end.
