unit dlgNewBank;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Allows the user to attach bank accounts
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
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
  StdCtrls,
  ComCtrls,
  ExtCtrls,
  AuditMgr,
  OsFont,
  BankLinkOnlineServices;

type
  TdlgAddNewBank = class(TForm)
    lblClientAccts: TLabel;
    lblPracticeAccts: TLabel;
    lvBank: TListView;
    lvAdminBank: TListView;
    btnAttach: TButton;
    btnClose: TButton;
    Label3: TLabel;
    stClient: TStaticText;
    Bevel1: TBevel;
    Bevel2: TBevel;
    Splitter1: TSplitter;
    chkIncludeAttached: TCheckBox;
    chkIncludeDeleted: TCheckBox;
    procedure btnCloseClick(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure btnAttachClick(Sender: TObject);
    procedure lvBankCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvAdminBankCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvAdminBankColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvBankColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure FormResize(Sender: TObject);
    procedure chkIncludeAttachedClick(Sender: TObject);
    procedure chkIncludeDeletedClick(Sender: TObject);
  private
    { Private declarations }
    AttachPressed : boolean;
    SortColA, SortColB : integer;
    fClientVendors : TBloArrayOfGuid;
    fClientID      : TBloGuid;

    procedure RefreshBankAccountList;
    procedure RefreshAdminAccountList;

    procedure AttachAccounts;
  public
    { Public declarations }
    function Execute : boolean;
    property ClientID : TBloGuid read fClientID write fClientID;
    property ClientVendors : TBloArrayOfGuid read fClientVendors write fClientVendors;
  end;

function AddNewAccountToClient(aClientVendors : TBloArrayOfGuid;
                               aClientID      : TBloGuid) : boolean;

//******************************************************************************
implementation
{$R *.DFM}
uses
  Admin32,
  baobj32,
  bkXPThemes,
  globals,
  sydefs,
  LogUtil,
  InfoMorefrm,
  ErrorMoreFrm,
  ImagesFrm,
  LvUtils,
  StStrS,
  Enterpwddlg,
  BkConst,
  MoneyDef,
  SYamio,
  ClientUtils;

const
  UnitName = 'DLGNEWBANK';

var
   DebugMe : boolean = false;
    
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm(Self);
  Width := Round(Application.Mainform.Monitor.Width * 0.9);  //90% of avail width

  if RefreshAdmin then begin
     if Adminsystem.HasMultiCurrency then
        with lvAdminBank.Columns.Add do begin
           Caption := 'Currency';
           Width := 80;
        end;

        with lvBank.Columns.Add do begin
           Caption := 'Currency';
           Width := 80;
        end;
       
  end;

  SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   chkIncludeAttached.Hint     :=
                    'Check to include attached Bank Accounts|' +
                    'Check to include Bank Accounts that have been attached to a client';
   chkIncludeDeleted.Hint :=
                    'Check to include deleted Bank Accounts|' +
                    'Check to include Bank Accounts that have been marked as deleted';
   btnAttach.Hint   :=
                    'Attach the selected Accounts to this Client File|' +
                    'Attach the selected Accounts to this Client File';
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.FormResize(Sender: TObject);
begin
  lvBank.width  := Round(Width *0.45);
  chkIncludeAttached.left := lvAdminBank.Left;
  chkIncludeDeleted.Left  := chkIncludeAttached.Left + chkIncludeAttached.Width + 50;

  lblPracticeAccts.left := lvAdminBank.Left;

  LVUTILS.SetListViewColWidth(lvBank,1);
  LVUTILS.SetListViewColWidth(lvAdminBank,1);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.btnCloseClick(Sender: TObject);
begin
   Close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.RefreshAdminAccountList;
var
   NewItem   : TListItem;
   BankAcct  : pSystem_Bank_Account_Rec;
   i         : integer;
   IncludeAccount : boolean;
begin
   lvAdminBank.Items.beginUpdate;
   try
     lvAdminBank.Items.Clear;
     if not RefreshAdmin then exit;

     with AdminSystem.fdSystem_Bank_Account_List do
     for i := 0 to Pred(itemCount) do
     begin
        BankAcct := System_Bank_Account_At(i);
        if not(BankAcct.sbAccount_Type in [sbtData, sbtProvisional]) then
           Continue;
        //include non attached and not deleted
        IncludeAccount := (BankAcct.sbAttach_Required) and (not BankAcct.sbMark_As_Deleted);
        if (not IncludeAccount) then
          //include deleted
          IncludeAccount := (chkIncludeDeleted.Checked and BankAcct.sbMark_As_Deleted);
        if (not IncludeAccount) then
          //include attached if not deleted
          IncludeAccount := (chkIncludeAttached.Checked and not BankAcct.sbAttach_Required) and
                            (not BankAcct.sbMark_As_Deleted);

        //add account to list if needed
        if IncludeAccount then begin
          NewItem := lvAdminBank.Items.Add;
          NewItem.Caption := BankAcct.sbAccount_Number;

          if BankAcct^.sbAccount_Password <> '' then
            NewItem.ImageIndex := MAINTAIN_LOCK_BMP
          else
            NewItem.ImageIndex := -1;

          if BankAcct^.sbMark_As_Deleted then
             NewItem.StateIndex := STATES_DELETED_BMP
          else begin
             if BankAcct^.sbAttach_Required then begin
               if BankAcct^.sbNew_This_Month then
                 NewItem.StateIndex := STATES_NEW_ACCOUNT_BMP
               else
                 NewItem.StateIndex := STATES_UNATTACHED_BMP;
             end
             else
               NewItem.StateIndex := STATES_ATTACHED_BMP;
          end;

          NewItem.SubItems.Add(BankAcct.sbAccount_Name);
          NewItem.SubItems.Add(BankAcct.sbCurrency_Code );
        end;
     end;
   finally
     lvAdminBank.items.EndUpdate;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.RefreshBankAccountList;
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

      if not (BankAcct.IsAJournalAccount) then
      begin
        NewItem := lvBank.Items.Add;
        NewItem.Caption := BankAcct.baFields.baBank_Account_Number;
        NewItem.ImageIndex := MAINTAIN_PAGE_NORMAL_BMP;
        NewItem.SubItems.AddObject(BankAcct.baFields.baBank_Account_Name ,BankAcct);
        NewItem.SubItems.Add(BankAcct.baFields.baCurrency_Code  );
        //NewItem.SubItems.Add(BankAcct.baFields.baContra_Account_Code);
      end;
   end;
   finally
      lvBank.items.EndUpdate;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.Splitter1Moved(Sender: TObject);
begin
   lblPracticeAccts.Left   := lvAdminBank.Left;
   chkIncludeAttached.left := lvAdminBank.Left;
   chkIncludeDeleted.Left  := chkIncludeAttached.Left + chkIncludeAttached.Width + 50;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.chkIncludeAttachedClick(Sender: TObject);
begin
   RefreshAdminAccountList;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.chkIncludeDeletedClick(Sender: TObject);
begin
   RefreshAdminAccountList;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.btnAttachClick(Sender: TObject);
var
  PrevSelectedIndex : Integer;
  PrevTopIndex: Integer;
begin
   if lvAdminBank.SelCount > 0 then
   begin
     PrevSelectedIndex := lvAdminBank.Selected.Index;
     PrevTopIndex := lvAdminBank.TopItem.Index;
     AttachPressed := true;
     AttachAccounts;
     RefreshBankAccountList;
     RefreshAdminAccountList;
     ReselectAndScroll(lvAdminBank, PrevSelectedIndex, PrevTopIndex);
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.AttachAccounts;
var
  i : integer;
  SelectedAccs : TStringList;
  AdminBankAccount : pSystem_Bank_Account_Rec;
begin
  SelectedAccs := TStringList.Create;
  Try
    for i := 0 to lvAdminBank.items.count -1 do
    begin
      if lvAdminBank.Items[i].Selected then
      begin
        SelectedAccs.Add(lvAdminBank.Items[i].Caption);
      end;
    end;

    ClientUtils.AttachAccountsToClient(MyClient, SelectedAccs , fClientVendors, ClientID, DebugMe);
  Finally
    FreeAndNil(SelectedAccs);
  End;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.lvBankCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
begin
  case SortColA of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortColA-1];
       Key2 := Item2.SubItems.Strings[SortColA-1];
     end;
  end; {case}
  Compare := StStrS.CompStringS(Key1,Key2);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.lvAdminBankCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
begin
  case SortColB of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortColB-1];
       Key2 := Item2.SubItems.Strings[SortColB-1];
     end;
  end; {case}
  Compare := StStrS.CompStringS(Key1,Key2);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.lvAdminBankColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvAdminBank.columns.Count-1 do
    lvAdminBank.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortColB := Column.ID;
  lvAdminBank.AlphaSort;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAddNewBank.lvBankColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvBank.columns.Count-1 do
    lvBank.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortColA := Column.ID;
  lvBank.AlphaSort;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgAddNewBank.Execute: boolean;
//returns true if new accounts were attached
begin
   result := false;

   if (not Assigned(MyClient)) or (not RefreshAdmin) then exit;
   stClient.caption := MyClient.clFields.clCode+ ' : '+ MyClient.clFields.clName;

   SortColA := 0;
   SortColB := 0;

   RefreshBankAccountlist;
   RefreshAdminAccountList;

   lvBank.AlphaSort;
   lvAdminBank.AlphaSort;

   ShowModal;
   result := attachPressed;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddNewAccountToClient(aClientVendors : TBloArrayOfGuid;
                               aClientID      : TBloGuid) : boolean;
var
  MyDlg : TdlgAddNewBank;
begin
  result := false;
  if not (RefreshAdmin and Assigned(MyClient)) then exit;

  //check that client belongs to this admin system, otherwise no point adding
  if not ( MyClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number ) then begin
    HelpfulInfoMsg('This Client File belongs to another Admin system.  '
       +'You cannot attach Bank Accounts from one Admin system to a Client File from another Admin system.',0);
    exit;
  end;

  //check that is not an off-site client
  if not (MyClient.clFields.clDownload_From = dlAdminSystem) then begin
     HelpfulInfoMsg('This is an Off-site Client File.  '+
        'You cannot attach Bank Accounts from the Admin System to an Off-site Client File.',0);
     exit;
  end;

  MyDlg := TDlgAddNewBank.Create(Application.MainForm);
  try
    if (Assigned(aClientVendors)) and
       (aClientID <> '') then
    begin
      MyDlg.ClientVendors := aClientVendors;
      MyDlg.ClientID      := aClientID;
    end;

    result := MyDlg.Execute; //returns true if new account added
  finally
    MyDlg.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

initialization
   DebugMe := DebugUnit(UnitName);
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
