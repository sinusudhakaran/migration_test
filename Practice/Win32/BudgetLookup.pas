unit BudgetLookup;
{--------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, budobj32, ovcDate,
  ComCtrls, ExtCtrls, StdCtrls, ImgList, ToolWin,
  OSFont;

{--------------------------------------------------------------}
type
  TfrmBudgetLook = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    Bevel1: TBevel;
    lvBudget: TListView;
    tbarMaintain: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    tbClose: TToolButton;
    btnSelect: TButton;
    btnClear: TButton;
    btnPreview: TButton;
    Sep1: TToolButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject) ;
    procedure tbEditClick(Sender: TObject);
    procedure tbCloseClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure lvBudgetDblClick(Sender: TObject);
    procedure btnSelectClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure tbPrintPreviewClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
//    okPressed : boolean;
    FSelectedBudget: TBudget;
    FYearStart: integer;
    FCheckedList: TStringList;
    FPressed: integer;

    procedure SetSelectedBudget(const Value: TBudget);
    procedure SetYearStart(const Value: integer);
    function  DeleteBudgets : boolean;
    procedure SelectAll;
    procedure DeselectAll;
    procedure SetCheckedList(const Value: TStringList);
    procedure SetPressed(const Value: integer);
  public
    { Public declarations }
    function Execute : boolean;
    function ExecuteMultiple : boolean;
    property SelectedBudget : TBudget read FSelectedBudget write SetSelectedBudget;
    property YearStart : integer read FYearStart write SetYearStart;
    procedure RefreshList;
    procedure RefreshReposition(Pos : TBudget; Select : boolean);
    property CheckedList : TStringList read FCheckedList write SetCheckedList;

    property Pressed : integer read FPressed write SetPressed;
  end;

function SelectBudget(Title : string; StartDate : TstDate = 0; ShowToolbar : boolean = false) : tBudget;
function SelectBudgets(Title: string; SelectedList : TstringList) : boolean;

function SelectBudgetToPrint(Title :string; var Btn : integer) : tBudget;

//******************************************************************************
implementation

{$R *.DFM}

uses
   Globals,
   BKConst,
   bkDateUtils,
   bkXPThemes,
   bkHelp,
   //Mainfrm,
   BudgetFrm,
   YesNoDlg,
   LogUtil,
   BudgetDetailDlg,
   UpdateMF,
   imagesfrm,
   infoMoreFrm,
   bkutil32,
   ReportDefs;

//------------------------------------------------------------------------------
procedure TfrmBudgetLook.FormShow(Sender: TObject);
begin
   lvBudget.Columns[0].Width := 50;

   keybd_event(vk_down,0,0,0);
   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmBudgetLook.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   BKHelpSetUp( Self, BKH_Chapter_9_Budgets);

   //Components
   tbNew.Hint       :=
                    'Create a new budget|'+
                    'Create a new budget';
   tbEdit.Hint      :=
                    'Edit Budget(s) with a check mark next to them|'+
                    'Edit Budget(s) with a check mark next to them';
   tbDelete.Hint    :=
                    'Delete Budget(s) with a check mark next to them|'+
                    'Delete Budget(s) with a check mark next to them';
   btnSelect.Hint   :=
                    'Set the "Select" check marks for all Budgets|'+
                    'Set the "Select" check marks for all Budgets';
   btnClear.Hint    :=
                    'Clear the "Select" check marks for all Budgets|'+
                    'Clear the "Select" check marks for all Budgets';
   lvBudget.Hint    :=
                    'Select a Budget for editing by checking the "Select" box next to it|'+
                    'Select a Budget for editing by checking the "Select" box next to it';
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.SetSelectedBudget(const Value: TBudget);
begin
  FSelectedBudget := Value;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.SetYearStart(const Value: integer);
begin
  FYearStart := Value;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.btnOKClick(Sender: TObject);
begin
   Pressed   := BTN_OKPRINT;  // in case we are requesting a budget to print
   Close;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.tbEditClick(Sender: TObject);
begin
  btnOk.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.tbCloseClick(Sender: TObject);
begin
   btnCancel.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.RefreshList;
var
   i,j : integer;
   Budget : TBudget;
   NewITem : TListItem;
   KillCheckedList : boolean;
begin
   KillCheckedList := false;
   if not Assigned(CheckedList) then
   begin
     CheckedList := TStringList.Create;
     KillCheckedList := true;
   end;

  try
     {store check marks for current}
     CheckedList.Clear;
     for i := 0 to lvBudget.Items.Count -1 do
       if lvBudget.Items[i].Selected then
       begin
         Budget :=  tBudget(lvBudget.items[i].SubItems.Objects[0]);
         CheckedList.AddObject(Budget.buFields.buName,Budget);
       end;

     lvBudget.Items.BeginUpdate;
     try
       lvBudget.Items.Clear;
       {add available accounts}
       with MyClient.clBudget_List do
       for i := ItemCount-1 downto 0 do
       begin
         with Budget_At(i) do
         begin
            NewItem := lvBudget.Items.Add;
            NewItem.Caption := ' ';
            NewItem.ImageIndex := -1;
            NewItem.SubItems.AddObject(buFields.buName,Budget_At(i));
            NewItem.SubItems.Add(bkDate2Str(buFields.buStart_Date));

         end;
       end;

       {check any that are already selected}
       for i := 0 to CheckedList.Count-1 do
       begin
         for j := 0 to lvBudget.items.count -1 do
           if TBudget(CheckedList.Objects[i]) = TBudget(lvBudget.items[j].subitems.objects[0]) then
            lvBudget.items[j].checked := true;
       end;
     finally
       CheckedList.Clear;
       lvBudget.items.EndUpdate;
     end;
   finally
     if KillCheckedList then
     begin
       CheckedList.Free;
       CheckedList := nil;
     end;
   end;
end;
//------------------------------------------------------------------------------
function TfrmBudgetLook.DeleteBudgets: boolean;
var
  i : Integer;
  s: string;
  OKToDelete : Boolean;
  Budget : TBudget;
begin
  Result := False;

  if (CheckedList.Count = 1) then
    s := 'OK to delete Budget '+TBudget(CheckedList.Objects[0]).buFields.buName+ '?'
  else
    s := 'OK to delete selected Budgets?';
  if AskYesNo('Delete Budget?',s,DLG_NO,0) <> DLG_YES then exit;

  for i := 0 to CheckedList.Count - 1 do
  begin
    OKToDelete := False;
    Budget := TBudget(CheckedList.Objects[i]);
    if BudgetVisible(Budget) then
    begin
      s := 'Budget ' + Budget.buFields.buName + ' is currently being edited. ' +
           ' Do you want to close and delete it?';
      if AskYesNo('Delete Budget?',s,DLG_NO,0) = DLG_YES then
      begin
        CloseBudgetScreen(Budget);
        OKToDelete := True;
      end;
    end else
      OKToDelete := True;

    if (OKToDelete) then
      MyClient.clBudget_List.DelFreeItem(Budget);
  end;

  Result := true;

  LogUtil.LogMsg(lmInfo,'BUDGETLOOKUP','User Deleted Budget '+ Name);
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.tbDeleteClick(Sender: TObject);
var
  i : Integer;
  KillCheckedList : boolean;
begin
  KillCheckedList := false;
  if not Assigned(CheckedList) then
  begin
    CheckedList := TStringList.Create;
    KillCheckedList := true;
  end;

  try
    CheckedList.Clear;
    if (Globals.Active_UI_Style = UIS_Simple) then
    begin
      for i := 0 to lvBudget.items.Count-1 do
        with lvBudget.Items[i] do
          if Selected then
            CheckedList.AddObject(SubItems[0],lvBudget.items[i].SubItems.Objects[0]);
    end else
    begin
      for i := 0 to lvBudget.items.Count-1 do
        with lvBudget.Items[i] do
          if Checked then
            CheckedList.AddObject(SubItems[0],lvBudget.items[i].SubItems.Objects[0]);
    end;

    if (CheckedList.Count > 0) then
    begin
      //b := TBudget(lvBudget.Selected.SubItems.Objects[0]);
      //if DeleteBudget(b) then RefreshList;
      if DeleteBudgets then RefreshList;
    end;
  finally
    if KillCheckedList then
    begin
      CheckedList.Free;
      CheckedList := nil;
    end;
  end;

end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.tbNewClick(Sender: TObject);
var
   b : TBudget;
begin
   if AddBudget(b) then
   begin
     RefreshReposition(b,true);
     tbEdit.Click;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if tbarMaintain.Visible then
  begin
    Handled := true;
    case Msg.CharCode of
      VK_INSERT : tbNew.click;
      VK_DELETE : tbDelete.click;
      VK_RETURN : tbEdit.click;
      VK_ESCAPE : tbClose.click;
    else
      Handled := false;
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.lvBudgetDblClick(Sender: TObject);
begin
  if tbarMaintain.Visible then
  begin  {multiple selection}
    if Assigned(lvBudget.Selected) then
      lvBudget.Selected.Checked := not lvBudget.Selected.Checked;
  end
  else   {single line selection}
    if btnPreview.Visible then
      btnPreview.Click
    else
      btnOK.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.SelectAll;
var i: Integer;
begin
   for i := 0 to lvBudget.Items.Count-1 do
      lvBudget.items[i].checked := true;
   lvBudget.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.DeselectAll;
var i: Integer;
begin
   for i := 0 to lvBudget.Items.Count-1 do
      lvBudget.items[i].checked := false;
   lvBudget.SetFocus;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.btnSelectClick(Sender: TObject);
begin
  SelectAll;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.btnClearClick(Sender: TObject);
begin
  DeselectAll;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.SetCheckedList(const Value: TStringList);
begin
  FCheckedList := Value;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.btnPreviewClick(Sender: TObject);
begin
  Pressed := BTN_PREVIEW;
  close;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.tbPrintPreviewClick(Sender: TObject);
//var
//  b : TBudget;
begin
//  if lvBudget.Selected <> nil then
//  begin
//    b := TBudget(lvBudget.Selected.SubItems.Objects[0]);
//    DoSpecifiedBudgetReport(b,rdScreen);
//  end;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.RefreshReposition(pos : TBudget; Select : boolean);
var
  i : integer;
begin
  RefreshList;

  //now find pointer again
  if Assigned(pos) then
  begin
    for i := 0 to Pred(lvBudget.items.Count) do
      if TBudget(lvBudget.Items[i].SubItems.Objects[0]) = pos then
      begin
        lvBudget.Items[i].selected := true;
        lvBudget.Items[i].Focused  := true;
        lvBudget.Items[i].Checked  := Select;
      end
      else
        lvBudget.Items[i].checked := false;
  end;
end;
//------------------------------------------------------------------------------
function TfrmBudgetLook.Execute: boolean;
begin
//   result := false;
   Pressed := BTN_NONE;

   Self.ShowModal;
   result := (Pressed = BTN_OKPRINT) or (Pressed = BTN_PREVIEW);
end;
//------------------------------------------------------------------------------
function TfrmBudgetLook.ExecuteMultiple: boolean;
begin
   Caption := 'Select Budget(s) to Edit';

   tbarMaintain.Visible := true;
   bevel1.Visible := false;
   btnOk.visible  := false;
   btnCancel.visible := false;

   Pressed := BTN_NONE;
   ShowModal;
   result := (Pressed = BTN_OKPRINT) or (Pressed = BTN_PREVIEW);
end;
//------------------------------------------------------------------------------
function SelectBudget(Title : string; StartDate : TstDate = 0; ShowToolbar : boolean = false) : tBudget;
var
  rpD, rpM, rpY : Integer;
  buD, buM, buY : Integer;
  MyDlg : TfrmBudgetLook;
  i : integer;
  NewItem : TListItem;
begin
  result := nil;

  //exit straight away if not budgets
  if not ShowToolbar then
    if not HasBudgets then exit;

  if (StartDate = 0) then
    rpM := 0
  else
    StDateToDMY(StartDate, rpD, rpM, rpY);

  MyDlg := TfrmBudgetLook.Create(Application.Mainform);
  try
     with MyDlg do begin
       Caption := Title;
       lvBudget.Checkboxes := false;
       btnSelect.visible := false;
       btnClear.visible := false;
       tbarMaintain.Visible := ShowToolbar;

       {add available accounts}
       with MyClient.clBudget_List do
       for i := ItemCount-1 downto 0 do
       begin
         with Budget_At(i) do
         begin
           if (rpM = 0) then
             buM := 0
           else
             StDateToDMY(buFields.buStart_Date, buD, buM, buY);
           if (rpM = 0) or (buM = rpM) then
           begin
             lvBudget.Columns[0].Width := 0;
             NewItem := lvBudget.Items.Add;
             NewItem.Caption := ' ';
             NewItem.ImageIndex := -1;
             NewItem.SubItems.AddObject(buFields.buName,Budget_At(i));
             NewItem.SubItems.Add(bkDate2Str(buFields.buStart_Date));
           end;
         end;
       end;

       if ( lvBudget.Items.Count = 0 ) and ( not ShowToolbar) then begin
          HelpfulInfoMsg('There are no budgets available for ' + moNames[rpM], 0);
          Exit;
       end;

       if ( lvBudget.Items.Count = 1 ) and ( not ShowToolbar) then begin
         result := tBudget(lvBudget.items[0].SubItems.Objects[0]);
         exit;
       end;

       if Execute then
       begin
         if lvBudget.Selected <> nil then
           result := tBudget(lvBudget.Selected.SubItems.Objects[0])
         else
           result := nil;
       end
       else
         result := nil;
     end; {with}
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
function SelectBudgetToPrint(Title :string; var Btn : integer) : tBudget;
var
  MyDlg : TfrmBudgetLook;
  i : integer;
  NewItem : TListItem;
begin
  result := nil;
  Btn    := BTN_NONE;

  if not Assigned(MyClient) then exit;

  MyDlg := TfrmBudgetLook.Create(Application.MainForm);
  try
     with MyDlg do begin
       Caption := Title;
       lvBudget.Checkboxes := false;
       btnSelect.visible := false;
       btnClear.visible := false;
       tbarMaintain.Visible := false;

       //setup print buttons
       btnPreview.left := btnSelect.Left;
       btnPreview.visible := true;
       btnPreview.Default := true;
       btnOK.Caption := '&Print';
       btnOK.default := false;

       //add available accounts
       with MyClient.clBudget_List do
       for i := ItemCount-1 downto 0 do
       begin
         with Budget_At(i) do
         begin
            lvBudget.Columns[0].Width := 0;
            NewItem := lvBudget.Items.Add;
            NewItem.Caption := ' ';
            NewItem.ImageIndex := -1;
            NewItem.SubItems.AddObject(buFields.buName,Budget_At(i));
            NewItem.SubItems.Add(bkDate2Str(buFields.buStart_Date));
         end;
       end;

       //---------
       if Execute then
       begin
         if lvBudget.Selected <> nil then
           result := tBudget(lvBudget.Selected.SubItems.Objects[0])
         else
           result := nil;

         btn := Pressed;
       end
         else
           result := nil;
     end; {with}
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
function SelectBudgets(Title: string; SelectedList : TstringList) : boolean;
var
  MyDlg : TfrmBudgetLook;
  i,j : integer;
  NewItem : TListItem;
begin
  result := false;
  if not (Assigned(MyClient) and Assigned(SelectedList)) then exit;

  MyDlg := TfrmBudgetLook.Create(Application.MainForm);
  try
     with MyDlg do begin
       Caption := Title;
       lvBudget.Checkboxes  := true;
       tbarMaintain.Visible := true;
       CheckedList          := SelectedList;

      {add available accounts}
       with MyClient.clBudget_List do
       for i := ItemCount-1 downto 0  do
       begin
         with Budget_At(i) do
         begin
            NewItem := lvBudget.Items.Add;
            NewItem.Caption := ' ';
            NewItem.ImageIndex := -1;
            NewItem.SubItems.AddObject(buFields.buName,Budget_At(i));
            NewItem.SubItems.Add(bkDate2Str(buFields.buStart_Date));
         end;
       end;

       {check any that are already selected}
       for i := 0 to CheckedList.Count-1 do
       begin
         for j := 0 to lvBudget.items.count -1 do
           if TBudget(CheckedList.Objects[i]) = TBudget(lvBudget.items[j].subitems.objects[0]) then
            lvBudget.items[j].checked := true;
       end;
       CheckedList.Clear;

       {choose relevant budgets}
       if Execute then
       begin
         for i := 0 to lvBudget.items.Count-1 do with lvBudget.Items[i] do
         if Checked then
            CheckedList.AddObject(SubItems[0],SubItems.Objects[0]);  {add account no and object}

         result := true;
       end;
     end; {with}
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmBudgetLook.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
end;
//------------------------------------------------------------------------------
end.
