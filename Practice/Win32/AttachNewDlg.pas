unit AttachNewDlg;
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
  ImgList,
  ComCtrls,
  StdCtrls,
  ExtCtrls,
  Buttons,
  ToolWin,
  ActnList,
  AuditMgr,
  OSFont;

type
  TdlgAttachNew = class(TForm)
    lvFiles: TListView;
    lvBank: TListView;
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    tbAttach: TToolButton;
    ToolButton5: TToolButton;
    tbClose: TToolButton;
    Panel1: TPanel;
    chkIncludeAttached: TCheckBox;
    chkIncludeDeleted: TCheckBox;
    tbHelpSep: TToolButton;
    tbHelp: TToolButton;
    procedure btnCloseClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbAttachClick(Sender: TObject);
    procedure lvFilesCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvFilesColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvBankColumnClick(Sender: TObject; Column: TListColumn);
    procedure lvBankCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure FormResize(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Splitter1Moved(Sender: TObject);
    procedure chkIncludeAttachedClick(Sender: TObject);
    procedure chkIncludeDeletedClick(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    SortColC : integer;
    SortColB : integer;

    procedure SetUpHelp;
    procedure RefreshClientList;
    procedure RefreshBankList;
    procedure RefreshLists;

    procedure AttachAccountsToClient;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  function AttachNewBankAccounts : boolean;

//------------------------------------------------------------------------------
implementation
{$R *.DFM}

uses
  bkXPThemes,
  bkHelp,
  globals,
  admin32,
  sydefs,
  bkdefs,
  bkconst,
  imagesfrm,
  NewClientWiz,
  clObj32,
  Files,
  baobj32,
  LogUtil,
  bkbaio,
  ErrorMoreFrm,
  LvUtils,
  enterpwdDlg,
  infoMoreFrm,
  StStrS,
  MoneyDef,
  Math,
  syamio,
  ClientHomePageFrm,
  ClientUtils,
  BankLinkOnlineServices;

const
  UnitName = 'ATTACHNEWDLG';

var
  DebugMe : boolean = false;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  width := Round(application.Mainform.Monitor.Width * 0.9);
  if RefreshAdmin then begin
     if Adminsystem.HasMultiCurrency then
        with lvBank.Columns.Add do begin
           Caption := 'Currency';
           Width := 80;
        end;
  end;
  SetUpHelp;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   tbNew.Hint      :=
                    'Create a new Client File|' +
                    'Create a new Client File';
   tbAttach.Hint   :=
                    'Attach the selected Bank Accounts to the selected Client File|' +
                    'Attach the selected Bank Accounts to the selected Client File';
   chkIncludeAttached.Hint     :=
                    'Check to include attached Bank Accounts|' +
                    'Check to include Bank Accounts that have been attached to a client';
   chkIncludeDeleted.Hint :=
                    'Check to include deleted Bank Accounts|' +
                    'Check to include Bank Accounts that have been marked as deleted';

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.FormResize(Sender: TObject);
begin
  lvFiles.width  := Round(Width *0.45);
  chkIncludeAttached.left := lvBank.Left;
  chkIncludeDeleted.Left  := chkIncludeAttached.Left + chkIncludeAttached.Width + 50;

  LVUTILS.SetListViewColWidth(lvFiles,1);
  LVUTILS.SetListViewColWidth(lvBank,1);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.RefreshBankList;
var
   NewItem   : TListItem;
   BankAcct  : pSystem_Bank_Account_Rec;
   i         : integer;
begin
   lvBank.Items.beginUpdate;
   try
     lvBank.Items.Clear;
     if not RefreshAdmin then exit;

     with AdminSystem.fdSystem_Bank_Account_List do
     for i := 0 to Pred(itemCount) do
     begin
        BankAcct := System_Bank_Account_At(i);
        if BankAcct.sbAccount_Type = sbtOffsite then
            Continue;

        if not chkIncludeAttached.Checked then
           if (not BankAcct.sbAttach_Required) then
              Continue; // Skip the Non attached

        if not chkIncludeDeleted.Checked then
           if BankAcct.sbMark_As_Deleted then
              Continue; //Skip the Deleted

        NewItem := lvBank.Items.Add;
        NewItem.Caption := BankAcct.sbAccount_Number;

        //setup icons
        if BankAcct^.sbAccount_Password <> '' then
           NewItem.ImageIndex := MAINTAIN_LOCK_BMP
        else
           NewItem.ImageIndex := -1;

        //set state icon
        NewItem.StateIndex   := -1;

        if BankAcct.sbMark_As_Deleted then begin
           NewItem.StateIndex := STATES_DELETED_BMP;
        end else begin
           //account is not deleted, show attached state
           if BankAcct^.sbAttach_Required then begin
              if BankAcct^.sbNew_This_Month then
                 NewItem.StateIndex := STATES_NEW_ACCOUNT_BMP
              else
                 NewItem.StateIndex := STATES_UNATTACHED_BMP;
           end else
              NewItem.StateIndex := STATES_ATTACHED_BMP;
        end;

        NewItem.SubItems.Add(BankAcct.sbAccount_Name);
        NewItem.SubItems.Add(BankAcct.sbCurrency_Code);
     end;
   finally
     lvBank.items.EndUpdate;
   end;

   lvBank.AlphaSort;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.RefreshClientList;
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
      if ClientFile.cfClient_Type = ctProspect then Continue;
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
   end;

   finally
      lvFiles.items.EndUpdate;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.btnCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.AttachAccountsToClient;
var
  ClientRec : pClient_File_Rec;
  ToClient : TClientObj;
  i : integer;
  VendorIndex : integer;
  SelectedAccs  : TStringList;
  VendorNames   : TStringList;
  ClientVendors : TBloArrayOfGuid;
  ClientExportDataService : TBloDataPlatformSubscription;
  ClientID                : TBloGuid;

begin
  ClientRec := pClient_File_Rec(lvFiles.Selected.SubItems.Objects[0]);
  if not Assigned(clientRec) then exit;

  {open the client file and add new bank accounts to it}
  ToClient := nil;
  OpenAClient(ClientRec^.cfFile_Code,ToClient,false);
  if not Assigned(ToClient) then exit;

  if not ( ToClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number ) then
  begin
    HelpfulInfoMsg('This Client File belongs to another Admin system.  ' +
                   'You cannot attach Bank Accounts from one Admin system to a Client File from another Admin system.',0);
    CloseAClient(ToClient);
    exit;
  end;

  if not ( ToClient.clFields.clDownload_From = dlAdminSystem ) then
  begin
    HelpfulInfoMsg('This is an Off-site Client File.  '+
                   'You cannot attach Bank Accounts from the Admin System to an Off-site Client File.',0);

    CloseAClient(ToClient);
    exit;
  end;

  SelectedAccs := TStringList.Create;
  VendorNames  := TStringList.Create;
  Try
    for i := 0 to lvBank.items.count -1 do
    begin
      if lvBank.Items[i].Selected then
      begin
        SelectedAccs.Add(lvBank.Items[i].Caption);
      end;
    end;

    if ProductConfigService.IsExportDataEnabled then
    begin
      if ProductConfigService.GetClientGuid(ToClient.clFields.clCode, ClientID) then
      begin
        ClientExportDataService := ProductConfigService.GetClientVendorExports(ClientID);
        try
          if Assigned(ClientExportDataService) then
          begin
            SetLength(ClientVendors, length(ClientExportDataService.Current));
            for VendorIndex := 0 to high(ClientVendors) do
            begin
              ClientVendors[VendorIndex] := ClientExportDataService.Current[VendorIndex].Id;
              VendorNames.Add(Copy(ClientExportDataService.Current[VendorIndex].Name_, 1,
                                   length(ClientExportDataService.Current[VendorIndex].Name_)));
            end;
          end;
        finally
          FreeAndNil(ClientExportDataService);
        end;
      end;
    end;

    ClientUtils.AttachAccountsToClient(ToClient, SelectedAccs, ClientVendors, VendorNames, ClientID, DebugMe, False);
  Finally
    FreeAndNil(VendorNames);
    FreeAndNil(SelectedAccs);
  End;

  CloseAClient(ToClient);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.tbCloseClick(Sender: TObject);
begin
  Close;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.tbNewClick(Sender: TObject);
var
  StoredCode : string;
  SelectItem : TListItem;
  WndHandle : HWND;
begin
  if CreateClient(Self, false) then
  begin
    StoredCode := MyClient.clFields.clCode;

    //if we have just created one then we need to close it so we can attach bank accounts
    CloseClientHomePage;
    RefreshClientList;

    //TFS 13322 - The system bank account list grid has invalid data because the
    //system DB is reloaded by CreateClient. This message reloads the bank
    //accounts into the virtual treeview.
    WndHandle := FindWindow('TfrmMaintainPracBank', nil);
    PostMessage(WndHandle, BK_SYSTEMDB_LOADED, Handle, 0);

    //now find code in list and select it
    SelectItem := lvFiles.FindCaption(0,StoredCode,false,true,true);
    if Assigned(SelectItem) then
       LVUTILS.SelectListViewItem(lvFiles,SelectItem);
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  Handled := true;
  case Msg.CharCode of
    VK_INSERT : tbNew.click;
    VK_ESCAPE : tbClose.click;
  else
    Handled := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.tbAttachClick(Sender: TObject);
var
  PrevBankSelectedIndex : Integer;
  PrevBankTopItemIndex: Integer;
  PrevFilesSelectedIndex : Integer;
  PrevFilesTopItemIndex: Integer;
begin
  if lvBank.SelCount <= 0 then exit;
  if lvFiles.SelCount <= 0 then exit;

  PrevBankSelectedIndex := lvBank.Selected.Index;
  PrevBankTopItemIndex := lvBank.TopItem.Index;
  PrevFilesSelectedIndex := lvFiles.Selected.Index;
  PrevFilesTopItemIndex := lvFiles.TopItem.Index;

  AttachAccountsToClient;
  RefreshLists;
  ReselectAndScroll(lvBank, PrevBankSelectedIndex, PrevBankTopItemIndex);
  ReselectAndScroll(lvFiles, PrevFilesSelectedIndex, PrevFilesTopItemIndex);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.RefreshLists;
begin
   RefreshClientList;
   RefreshBankList;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.lvFilesCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : string;
begin
  case SortColC of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
    begin
       Key1 := Item1.SubItems.Strings[SortColC-1];
       Key2 := Item2.SubItems.Strings[SortColC-1];
    end;
  end;
  Compare := StStrS.CompStringS(Key1,Key2);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.lvFilesColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvFiles.columns.Count-1 do
    lvFiles.columns[i].ImageIndex := -1;
  column.ImageIndex := FILES_COLSORT_BMP;

  SortColC := Column.ID;
  lvFiles.AlphaSort;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.lvBankColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvBank.columns.Count-1 do
    lvBank.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortColB := Column.ID;
  lvBank.AlphaSort;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.lvBankCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : string;
begin
  case SortColB of  0:
     begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
     end;
  else
    begin
       Key1 := Item1.SubItems.Strings[SortColB -1];
       Key2 := Item2.SubItems.Strings[SortColB - 1];
    end;
  end;
  Compare := StStrs.CompStringS(Key1,Key2);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.Splitter1Moved(Sender: TObject);
begin
  chkIncludeAttached.left := lvBank.Left;
  chkIncludeDeleted.Left  := chkIncludeAttached.Left + chkIncludeAttached.Width + 50;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.chkIncludeAttachedClick(Sender: TObject);
begin
   RefreshBankList;
end;

//------------------------------------------------------------------------------
function TdlgAttachNew.Execute: boolean;
begin
   SortColC := 0;
   SortColB := 0;

   RefreshLists;
   lvfiles.AlphaSort;

   lvFiles.Columns[0].ImageIndex := FILES_COLSORT_BMP;
   lvBank.Columns[1].ImageIndex := MAINTAIN_COLSORT_BMP;

   ShowModal;
   result := true;
end;

//------------------------------------------------------------------------------
function AttachNewBankAccounts : boolean;
var
  Mydlg : tdlgAttachNew;
begin
  MyDlg := TDlgAttachNew.Create(Application.MainForm);
  try
    BKHelpSetup(MyDlg, BKH_Setting_up_new_accounts);
    result := MyDlg.Execute;
  finally
    Mydlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.chkIncludeDeletedClick(Sender: TObject);
begin
   RefreshBankList;
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

//------------------------------------------------------------------------------
procedure TdlgAttachNew.FormShow(Sender: TObject);
begin
  lvBankColumnClick(lvBank, lvBank.Columns[0]); // force sort by number
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.
