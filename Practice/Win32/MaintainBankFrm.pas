unit MaintainBankFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Maintain Client Bank Accounts
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, baObj32, ActnList,
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
    procedure tbAttachClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure actCreateExecute(Sender: TObject);
    procedure actAttachExecute(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
//    procedure lvBankKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    SortCol : integer;
    FUpdateRefNeeded: boolean;
    AccountChanged : Boolean;
    procedure RefreshBankAccountList;
    function DeleteBankAccount(BankAccount : TBank_Account) :boolean;
    procedure SetUpdateRefNeeded(const Value: boolean);

    {$IFNDEF SmartBooks}
    procedure CreateManualAccount;
    {$ENDIF}
  public
    { Public declarations }
    function Execute : boolean;
    property UpdateRefNeeded : boolean read FUpdateRefNeeded write SetUpdateRefNeeded;
  end;

function MaintainBankAccounts(ContextID : Integer) : boolean;

//******************************************************************************
implementation

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
  MoneyDef, InfoMoreFrm, BKDEFS, clObj32, BaList32, sydefs, ErrorMoreFrm,
  BKUtil32, BAUtils, Math;


{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmMaintainBank.FormCreate(Sender: TObject);
var
  CurrencyColumn: TListColumn;
begin
  bkXPThemes.ThemeForm( Self);

  tbAttach.Enabled  := Assigned( AdminSystem) and CurrUser.CanAccessAdmin and (not MyClient.clFields.clFile_Read_Only);
  tbDelete.Enabled  := CurrUser.CanAccessAdmin;

  actCreate.Enabled := (not MyClient.clFields.clFile_Read_Only) and ((not Assigned(AdminSystem)) or CurrUser.CanAccessAdmin);

  //Add currency column for UK multi-currency
  if (MyClient.clFields.clCountry = whUK) and (MyClient.HasForeignCurrencyAccounts) then begin
    CurrencyColumn := lvBank.Columns.Add;
    CurrencyColumn.Caption := 'Currency';
    CurrencyColumn.Width := 80;
  end;

  //Contra column
  CurrencyColumn := lvBank.Columns.Add;
  CurrencyColumn.Caption := 'Contra';
  CurrencyColumn.Width := 100;

  LVUTILS.SetListViewColWidth(lvBank,1);
  UpdateRefNeeded := false;
  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
procedure TfrmMaintainBank.RefreshBankAccountList;
var
   NewItem : TListItem;
   BankAcct  : TBank_Account;
   i : integer;
begin
   lvBank.Items.beginUpdate;
   try

   lvBank.Items.Clear;

   with MyClient, clBank_Account_List do
   for i := 0 to Pred(itemCount) do
   begin
      BankAcct :=  Bank_Account_At(i);

      //if not (BankAcct.IsAJournalAccount) then
      if BankAcct.baFields.baAccount_Type <> btStockBalances then      
      begin
        NewItem := lvBank.Items.Add;
        NewItem.Caption := BankAcct.baFields.baBank_Account_Number;

        if AccountVisible(BankAcct) then  {check if visible in coding window}
          NewItem.ImageIndex := MAINTAIN_PAGE_OPEN_BMP
        else
           NewItem.ImageIndex := MAINTAIN_PAGE_NORMAL_BMP;

//        if BankAcct.IsAForexAccount and ( BankAcct.baFields.baDefault_Forex_Source = '' ) then
//          NewItem.ImageIndex := MAINTAIN_ALERT;

        if ( BankAcct.baFields.baAccount_Type = btBank ) and
           ContraCodeRequired( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used )
           and ( BankAcct.baFields.baContra_Account_Code = '' ) then
            NewItem.ImageIndex := MAINTAIN_ALERT;

        NewItem.SubItems.AddObject(BankAcct.baFields.baBank_Account_Name,BankAcct);

        if (MyClient.clFields.clCountry = whUK) and (MyClient.HasForeignCurrencyAccounts) then 
          NewItem.SubItems.Add(BankAcct.baFields.baCurrency_Code);

        NewItem.SubItems.Add(BankAcct.baFields.baContra_Account_Code);
      end;
   end;
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

//procedure TfrmMaintainBank.lvBankKeyDown(Sender: TObject; var Key: Word;
//  Shift: TShiftState);
//
//  Procedure ChangeCurrency( B : TBank_Account; Code : String );
//  Var
//    pSB : pSystem_Bank_Account_Rec;
//  Begin
//    B.baFields.baCurrency_Code := Code;
//    If LoadAdminSystem( True, 'ChangingCurrencyHack!' ) then
//    Begin
//      pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( B.baFields.baBank_Account_Number );
//      if Assigned( pSB ) then pSB.sbCurrency_Code := Code;
//      SaveAdminSystem;
//    end;
//  end;
//
//var
//  B: TBank_Account;
//begin
//  if ( lvBank.Selected <> nil ) then
//  begin
//    B := TBank_Account(lvBank.Selected.SubItems.Objects[0]);
//
//    if Shift = [] then
//    Begin
//      if ( Chr( Key ) in [ 'n', 'N' ] ) then
//      Begin
//        ChangeCurrency( B, 'NZD' );
//        RefreshBankAccountList;
//        Key := 0;
//        exit;
//      End;
//
//      if ( Chr( Key ) in [ 'u', 'U' ] ) then
//      Begin
//        ChangeCurrency( B, 'USD' );
//        RefreshBankAccountList;
//        Key := 0;
//        exit;
//      End;
//
//      if ( Chr( Key ) in [ 'a', 'A' ] ) then
//      Begin
//        ChangeCurrency( B, 'AUD' );
//        RefreshBankAccountList;
//        Key := 0;
//        exit;
//      End;
//
//      if ( Chr( Key ) in [ 'e', 'E' ] ) then
//      Begin
//        ChangeCurrency( B, 'EUR' );
//        RefreshBankAccountList;
//        Key := 0;
//        exit;
//      End;
//
//      if ( Chr( Key ) in [ 'g', 'G' ] ) then
//      Begin
//        ChangeCurrency( B, 'GBP' );
//        RefreshBankAccountList;
//        Key := 0;
//        exit;
//      End;
//    End;
//  end;
//  Inherited;
//end;

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
        end;
        // Update unattached flag
        if not Assigned(AdminSystem.fdSystem_Client_Account_Map.FindFirstClient(pS^.sbLRN)) then
          pS.sbAttach_Required := True;
      end;
    end;
    SaveAdminSystem;
    result := true;
  end
  else
    HelpfulErrorMsg('Unable to Delete Bank Account.  Admin System cannot be loaded',0);

  LogUtil.LogMsg(lmInfo,'MAINTAINBANKFRM','User Delete Bank Account '+AcctNo+' - '+AcctName);
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainBank.tbEditClick(Sender: TObject);
var
  B: TBank_Account;
  Result: Boolean;
begin
  if lvBank.Selected <> nil then
  begin
    B := TBank_Account(lvBank.Selected.SubItems.Objects[0]);
    if B.IsManual then // a/c number may of changed - need to re-insert in the correct position
       MyClient.clBank_Account_List.Delete(B);

    Result := EditBankAccount(B);

    if B.IsManual then
       MyClient.clBank_Account_List.Insert(B);

    if Result then
    begin
      AccountChanged := True;
      RefreshBankAccountList;
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
procedure TfrmMaintainBank.tbAttachClick(Sender: TObject);
begin

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
      and (CountNonManualBankAccounts = 1)
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
   RefreshBankAccountList;

   SortCol := 0;
   lvBank.AlphaSort;

   ShowModal;
   result := true;
   RefreshHomepage([HPR_Coding]);
   //check if a bank account was added or deleted
   if UpdateRefNeeded then MyClient.UpdateRefs;
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
   DummyAccount := TBank_Account.Create;
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
   if EditBankAccount( DummyAccount, True) then begin
      //if user did not cancel add account to client
      MyClient.clBank_Account_List.Insert( DummyAccount);
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
    end;
  end;
end;

procedure TfrmMaintainBank.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

procedure TfrmMaintainBank.FormShow(Sender: TObject);
begin
  lvBankColumnClick(lvBank, lvBank.Columns[0]); // force sort by number
end;

procedure TfrmMaintainBank.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  UpdateMenus;
end;

end.
