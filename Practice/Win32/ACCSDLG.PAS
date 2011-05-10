unit AccsDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//main dialog for selecting Bank Accounts to use
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, checklst, ExtCtrls, OvcCkLb, ImgList, ComCtrls, baobj32,
  OSFont;

type
  TdlgAccounts = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    lvAccounts: TListView;
    Bevel1: TBevel;
    btnSelect: TButton;
    btnClear: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure lvAccountsDblClick(Sender: TObject);
    procedure lvAccountsEditing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure FormShow(Sender: TObject);
    procedure lvAccountsCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvAccountsColumnClick(Sender: TObject; Column: TListColumn);
  private
    { Private declarations }
    SortCol : integer;
    procedure SelectAll;
    procedure DeselectAll;
  public
    { Public declarations }
    function Execute : boolean;
  end;

  function SelectBankAccount(Title:string; SelectType:byte; d1,d2: integer;
                             IncludeJournals: boolean; HelpCtx : integer;
                             var ABankAccount: TBank_Account) : TModalResult;

  function SelectBankAccounts(Title: string; SelectedList : TstringList; SelectType : byte;
                              d1,d2 : integer; IncludeJournals : boolean;
                              HelpCtx : integer) : boolean;

const
  SelectAllTrx     = 0;
  SelectWithTrx    = 1;
  SelectForTrans   = 2;
  SelectManual     = 3;
  SelectDeliveredTrx  = 4;
  selectWithUncodedTrx = 5;

//******************************************************************************
implementation
uses
   bkXPThemes,
   bkHelp,
   bkUtil32,
   clObj32,
   globals,
   imagesfrm,
   StStrS,
   GenUtils,
   bkConst,
   bkDefs;

{$R *.DFM}
var
  okPressed : boolean;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
   lvAccounts.items.clear;
   okPressed := false;
   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   btnSelect.Hint   :=
                    'Set the "Select" check marks for all Accounts|'+
                    'Set the "Select" check marks for all Accounts';
   btnClear.Hint    :=
                    'Clear the "Select" check marks for all Accounts|'+
                    'Clear the "Select" check marks for all Accounts';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.FormShow(Sender: TObject);
begin
  lvAccounts.Columns[0].Width := 50;
  keybd_event(vk_down,0,0,0);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.btnOKClick(Sender: TObject);
begin
   OKPressed := true;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.btnCancelClick(Sender: TObject);
begin
   OKPressed := false;
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.btnSelectClick(Sender: TObject);
begin
  SelectAll;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.btnClearClick(Sender: TObject);
begin
  DeselectAll;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.lvAccountsCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  Key1,Key2 : ShortString;
  Num1, Num2 : integer;
begin
  case SortCol of
  0: begin
       Key1 := Item1.Caption;
       Key2 := Item2.Caption;
       Compare := StStrS.CompStringS(Key1,Key2);
     end;
  3: begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];

       Num1 := Str2Long(Key1);
       Num2 := Str2Long(Key2);

       if num1 > num2 then Compare := -1 else
       if num1 < num2 then Compare := 1 else
       Compare := 0;
     end;
  else
     begin
       Key1 := Item1.SubItems.Strings[SortCol-1];
       Key2 := Item2.SubItems.Strings[SortCol-1];
       Compare := StStrS.CompStringS(Key1,Key2);
     end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.lvAccountsColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  if column.id > 0 then
  begin
    for i := 0 to lvAccounts.columns.Count-1 do
      lvAccounts.columns[i].ImageIndex := -1;

    column.ImageIndex := MAINTAIN_COLSORT_BMP;

    SortCol := Column.ID;
    lvAccounts.AlphaSort;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.SelectAll;
var i: Integer;
begin
   for i := 0 to lvAccounts.Items.Count-1 do
      lvAccounts.items[i].checked := true;
   lvAccounts.SetFocus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.DeselectAll;
var i: Integer;
begin
   for i := 0 to lvAccounts.Items.Count-1 do
      lvAccounts.items[i].checked := false;
   lvAccounts.SetFocus;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CountTrx(ba : TBank_Account; SelType: byte;d1,d2 : integer) : integer;
var
  j : integer;
  pT : pTransaction_Rec;
  foundUncoded: Boolean;
begin
  result := 0;

  //If no date range set then count all?
  if (d1 = 0) and (d2 = 0)then
    d2 := MaxInt;

  case SelType of
    SelectAllTrx,
    SelectManual : result := ba.baTransaction_List.ItemCount;
    SelectDeliveredTrx :  with ba do
        for j := 0 to Pred(baTransaction_List.ItemCount) do
        begin
          pT := baTransaction_List.Transaction_At(j);
          with pT^ do begin
            if (txDate_Effective < d1) then
               continue;
            if (txDate_Effective > d2) then
               break;  {sorted so no more to be found}
            if baTransaction_List.Transaction_At(j).txSource <> orBank then
               Continue;

            Inc(result);
          end;
        end;

    SelectWithTrx :
      with ba do
        for j := 0 to Pred(baTransaction_List.ItemCount) do
        begin
          pT := baTransaction_List.Transaction_At(j);
          with pT^ do
            if (txDate_Effective >= d1) then
            begin
              if (txDate_Effective > d2) then break;  {sorted so no more to be found}
              Inc(result);
            end;
        end;

   SelectForTrans :
      with ba do
        for j := 0 to Pred(baTransaction_List.ItemCount) do
          with baTransaction_List.Transaction_At(j)^ do
            if (txDate_Effective >= d1) and (txDate_Transferred = 0) then
            begin
              if (txDate_Effective > d2) then break;  {sorted so no more to be found}
              Inc(result);
            end;

   SelectWithUncodedTrx :
      with ba do
        for j := 0 to Pred(baTransaction_List.ItemCount) do
        begin
          pT := baTransaction_List.Transaction_At(j);
          with pT^ do
            if (txDate_Effective >= d1) then
            begin
              if (txDate_Effective > d2) then break;  {sorted so no more to be found}
              if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
                foundUnCoded := IsUncoded(pT)
              else
                foundUnCoded := (pT.txAccount = '');
              if foundUncoded then
                Inc(result);
            end;
        end;
  end; {case}
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.lvAccountsDblClick(Sender: TObject);
begin
  if Assigned(lvAccounts.Selected) then
    lvAccounts.Selected.Checked := not lvAccounts.Selected.Checked;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgAccounts.lvAccountsEditing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit := false;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgAccounts.Execute : boolean;
begin
   SortCol := 1;
   OKPressed := false;
   ShowModal;
   result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectBankAccounts(Title: string; SelectedList : TstringList;
                            SelectType : byte;
                            d1,d2 : integer;
                            IncludeJournals : boolean;
                            HelpCtx : integer) : boolean;
var
  MyDlg : TdlgAccounts;
  i,j : integer;
  Include : boolean;
  NewItem : TListItem;
begin
  result := false;
  if not (Assigned(MyClient) and Assigned(SelectedList)) then exit;

  MyDlg := TdlgAccounts.Create(Application.MainForm);
  try
     with MyDlg do begin
       Caption := Title;
       BKHelpSetUp( MyDlg, HelpCtx);

       lvAccounts.Hint    :=
          'Select an Account by checking the "Select" box next to it|'+
          'Select an Account by checking the "Select" box next to it';

       {add available accounts}
       with MyClient.clBank_Account_List do
       for i := 0 to Pred(ItemCount) do
       if (IncludeJournals and Bank_Account_At(i).IsAJournalAccount) or (not Bank_Account_At(i).IsAJournalAccount) then
       begin
         Include := false;

         case SelectType of
           SelectAllTrx : Include := true;

           SelectWithTrx :
             with Bank_Account_At(i) do
               for j := 0 to Pred(baTransaction_List.ItemCount) do
                 with baTransaction_List.Transaction_At(j)^ do
                   if (txDate_Effective >= d1) and (txDate_Effective <= d2) then
                   begin
                     Include := true;
                     break;
                   end;

           SelectForTrans :  //only allow transferable accounts to be selected from list
             with Bank_Account_At(i) do
               if baFields.baAccount_Type in [btBank, btCashJournals, btAccrualJournals] then
                 for j := 0 to Pred(baTransaction_List.ItemCount) do
                   with baTransaction_List.Transaction_At(j)^ do
                     if (txDate_Effective >= d1) and (txDate_Effective <= d2) and (txDate_Transferred = 0) then
                     begin
                       Include := true;
                       break;
                     end;

           SelectManual: include := Bank_Account_At(i).IsManual;

           SelectDeliveredTrx:
               if not Bank_Account_At(i).IsManual then
                 with Bank_Account_At(i) do
                   if baFields.baAccount_Type in [btBank, btCashJournals, btAccrualJournals] then
                     for j := 0 to Pred(baTransaction_List.ItemCount) do
                       with baTransaction_List.Transaction_At(j)^ do
                         if (txSource = orBank) then
                         begin
                           Include := true;
                           break;
                         end;

           SelectWithUncodedTrx:
             with Bank_Account_At(i) do
               for j := 0 to Pred(baTransaction_List.ItemCount) do
                 with baTransaction_List.Transaction_At(j)^ do
                   if (txDate_Effective >= d1) and (txDate_Effective <= d2) then
                   begin
                     if MyClient.clChart.itemCount > 0 then //check to see if a chart exists
                       Include := IsUncoded(baTransaction_List.Transaction_At(j))
                     else
                       Include := (txAccount = '');
                     if Include then
                       break;
                   end;
         end; {case}

         if Include then  {add account to available list}
         with Bank_Account_At(i) do
         begin
            NewItem := lvAccounts.Items.Add;
            NewItem.Caption := ' ';
            NewItem.ImageIndex := -1;
            NewItem.SubItems.AddObject(baFields.baBank_Account_Number,Bank_Account_At(i));
            NewItem.SubItems.Add(AccountName);
            NewItem.SubItems.Add(inttostr(CountTrx(Bank_Account_At(i),SelectType,d1,d2)));
            NewItem.Checked := false;
            if SelectType = SelectForTrans then NewItem.Checked := True;
         end;
       end;

       {check any that are already selected}
       for i := 0 to SelectedList.Count-1 do
       begin
         for j := 0 to lvAccounts.items.count -1 do
           if TBank_Account(SelectedList.Objects[i]) = TBank_Account(lvAccounts.items[j].subitems.objects[0]) then
            lvAccounts.items[j].checked := true;
       end;
       SelectedList.Clear;

       if lvAccounts.Items.Count > 1 then
       begin
         if Execute then
         begin
           for i := 0 to lvAccounts.items.Count-1 do with lvAccounts.Items[i] do
           if Checked then
              SelectedList.AddObject(SubItems[0],SubItems.Objects[0]);  {add account no and object}

           if SelectedList.Count = 0 then
           Begin
              Result := False; { Nothing was selected }
           end
           else
           Begin
              Result := true;
           end;
         end;
       end
       else
       begin
         {only 1 item in the list, so select it automatically}
         if lvAccounts.Items.Count =1 then with lvAccounts.Items[0] do
            SelectedList.AddObject(SubItems[0],SubItems.Objects[0]);  {add account no and object}

         result := true;
       end;
     end; {with}
  finally
     MyDlg.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function SelectBankAccount(Title:string; SelectType:byte; d1,d2: integer;
  IncludeJournals: boolean; HelpCtx : integer; var ABankAccount: TBank_Account) : TModalResult;
var
  MyDlg : TdlgAccounts;
  i,j : integer;
  Include : boolean;
  NewItem : TListItem;
begin
  ABankAccount := nil;
  Result := mrNone;
  if not Assigned(MyClient) then exit;

  MyDlg := TdlgAccounts.Create(Application.MainForm);
  try
     with MyDlg do begin
       Caption := Title;
       with lvAccounts do begin
          Checkboxes := False;
          OnDblClick := btnOKClick; //Double Click selects Bank Account
       end;
       btnSelect.visible := false;
       btnClear.visible := false;

       lvAccounts.Hint    :=
           'Select an Account|'+
           'Select an Account';

       BKHelpSetUp( MyDlg, HelpCtx);

       {add available accounts}
       with MyClient.clBank_Account_List do
       for i := 0 to Pred(ItemCount) do
       if (IncludeJournals and Bank_Account_At(i).IsAJournalAccount) or (not Bank_Account_At(i).IsAJournalAccount) then
       begin
         Include := false;

         case SelectType of
           SelectAllTrx : Include := true;

           SelectWithTrx :
             with Bank_Account_At(i) do
               for j := 0 to Pred(baTransaction_List.ItemCount) do
                 with baTransaction_List.Transaction_At(j)^ do
                   if (txDate_Effective >= d1) and (txDate_Effective <= d2) then
                   begin
                     Include := true;
                     break;
                   end;

           SelectForTrans :
             with Bank_Account_At(i) do
               for j := 0 to Pred(baTransaction_List.ItemCount) do
                 with baTransaction_List.Transaction_At(j)^ do
                   if (txDate_Effective >= d1) and (txDate_Effective <= d2) and (txDate_Transferred = 0) then
                   begin
                     Include := true;
                     break;
                   end;

           SelectManual: include := Bank_Account_At(i).IsManual;

           SelectDeliveredTrx:
               if not Bank_Account_At(i).IsManual then
                 with Bank_Account_At(i) do
                   if baFields.baAccount_Type in [btBank, btCashJournals, btAccrualJournals] then
                     for j := 0 to Pred(baTransaction_List.ItemCount) do
                       with baTransaction_List.Transaction_At(j)^ do
                         if (txSource = orBank) then
                         begin
                           Include := true;
                           break;
                         end;

         end; {case}

         if Include then  {add account to available list}
         with Bank_Account_At(i) do
         begin
            lvAccounts.Columns[0].Width := 0;
            NewItem := lvAccounts.Items.Add;
            NewItem.Caption := ' ';
            NewItem.ImageIndex := -1;
            NewItem.SubItems.AddObject(baFields.baBank_Account_Number,Bank_Account_At(i));
            NewItem.SubItems.Add(AccountName);
            NewItem.SubItems.Add(inttostr(CountTrx(Bank_Account_At(i),SelectType,d1,d2)));
         end;
       end;

       if lvAccounts.Items.Count > 1 then
       begin
         if Execute then
         begin
           Result := mrOk;
           if lvAccounts.Selected <> nil then
             ABankAccount := TBank_Account(lvAccounts.Selected.SubItems.Objects[0])
           else
             ABankAccount := nil;
         end
         else begin
           Result := mrCancel;
           ABankAccount := nil;
         end;
       end
       else
       begin
         if lvAccounts.Items.Count =1 then
           ABankAccount := TBank_Account(lvAccounts.items[0].SubItems.Objects[0]);
       end;

     end; {with}
  finally
     MyDlg.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
