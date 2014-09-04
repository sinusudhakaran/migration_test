unit MaintainPayeesFrm;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Maintain the payees for this client
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, ToolWin, bkDefs,
  PayeeObj,
  OSFont, StdCtrls, ExtCtrls;

type
  TfrmMaintainPayees = class(TForm)
    ToolBar1: TToolBar;
    tbNew: TToolButton;
    tbEdit: TToolButton;
    tbDelete: TToolButton;
    lvPayees: TListView;
    tbClose: TToolButton;
    ToolButton5: TToolButton;
    tbMerge: TToolButton;
    ToolButton2: TToolButton;
    tbHelpSep: TToolButton;
    tbHelp: TToolButton;
    pnlInactive: TPanel;
    chkShowInactive: TCheckBox;
    procedure tbCloseClick(Sender: TObject);
    procedure tbNewClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure lvPayeesDblClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbDeleteClick(Sender: TObject);
    procedure lvPayeesColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tbMergeClick(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure lvPayeesKeyPress(Sender: TObject; var Key: Char);
    procedure lvPayeesSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure chkShowInactiveClick(Sender: TObject);
  private
    { Private declarations }
    CurrentSortCol : integer;
    SearchTerm: string;

    procedure RefreshPayeeList;
    function  DeletePayee(Payee : TPayee): boolean;
    function  DeleteMultiple : boolean;

    procedure MergePayees;
    procedure ForceOnlyOneSelected;
    procedure DoSortByColNo(ClickColNo: integer);
    procedure RepositionOnNumber( aNumber : string);
    function RepositionOnName(aPartialName: string): Boolean;
  public
    { Public declarations }
    function Execute : boolean;
  end;

function MaintainPayees(ContextID : Integer) : boolean;

//******************************************************************************
implementation

uses
  bkXPThemes,
  BKHelp,
  glConst,
  Globals,
  PayeeDetailDlg,
  YesNoDlg,
  LogUtil,
  imagesfrm,
  clObj32,
  copyFromDlg,
  files,
  WarningMoreFrm,
  bkpyio,
  updatemf,
  LvUtils,
  admin32,
  Progress,
  BKPLIO,
  GSTCalc32,
  GenUtils,
  AuditMgr;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  SearchTerm := '';
  CurrentSortCol := 0;
  DoSortByColNo( 0);
  tbMerge.Enabled := Assigned( AdminSystem) and ( not CurrUser.HasRestrictedAccess);
  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tbNew.Hint       :=
                    'Add a new Payee|' +
                    'Add a new Payee';
   tbEdit.Hint      :=
                    'Edit details for the selected Payee|' +
                    'Edit details for the selected Payee';
   tbDelete.Hint    :=
                    'Delete the selected Payee(s)|' +
                    'Delete the selected Payee(s)';
   tbMerge.Hint     :=
                    'Merge this list with the payee list from another Client File|' +
                    'Merge this list with the payee list from another Client File';

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.RefreshPayeeList;
var
   NewItem : TListItem;
   Payee : TPayee;
   i : integer;
begin
   lvPayees.Items.beginUpdate;
   try
     MsgBar('Load Payees',true);
     lvPayees.Items.Clear;

     if not Assigned(myClient) then exit;

     // Show inactive column?
     if chkShowInactive.Checked then
       lvPayees.Columns[2].Width := 90
     else
       lvPayees.Columns[2].Width := 0;

     with MyClient, clPayee_List do
     for i := 0 to Pred(itemCount) do
     begin
        Payee := Payee_At(i);

        if Payee.pdFields.pdInactive and not chkShowInactive.Checked then
          continue;

        NewItem := lvPayees.Items.Add;

        NewItem.Caption := inttostr(Payee.pdNumber);
        NewItem.Imageindex := -1;
        NewItem.SubItems.AddObject(Payee.pdName,TObject(Payee));

        if chkShowInactive.Checked then
        begin
          if Payee.pdFields.pdInactive then
            NewItem.SubItems.Add('Yes')
          else
            NewItem.SubItems.Add('No');
        end
        else
          NewItem.SubItems.Add('');
     end;

     DoSortByColNo( CurrentSortCol);

     if lvPayees.Items.Count > 0 then
     begin
       lvPayees.Selected := lvPayees.Items[0];
       lvPayees.Selected.Focused := true;
     end;
   finally
     lvPayees.items.EndUpdate;
     MsgBar('',false);
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.tbCloseClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.tbNewClick(Sender: TObject);
var
  p : TPayee;
begin
  SearchTerm := '';
  ForceOnlyOneSelected;
  if AddPayee(p) then
  begin
    RefreshPayeeList;
    DoSortByColNo( CurrentSortCol);
    RepositionOnNumber(IntToStr(p.pdFields.pdNumber));
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.tbEditClick(Sender: TObject);
var
  p: TPayee;
begin
  SearchTerm := '';
  if lvPayees.Selected <> nil then
  begin
    //Force only the first item to be selected
    ForceOnlyOneSelected;
    p := TPayee(lvPayees.Selected.SubItems.Objects[0]);
    if EditPayeeDetail(p) then begin
      //Flag Audit
      MyClient.ClientAuditMgr.FlagAudit(arPayees);
      //Reload payees
      MyClient.clPayee_List.Sort(PayeeCompare);
      RefreshPayeeList;
      RepositionOnNumber(IntToStr(p.pdFields.pdNumber));
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.lvPayeesDblClick(Sender: TObject);
begin
   tbEdit.Click;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
var
  i : integer;
begin
  Handled := true;
  case Msg.CharCode of
    VK_INSERT : tbNew.click;
    VK_DELETE : tbDelete.click;
    VK_RETURN : tbEdit.click;
    VK_ESCAPE : tbClose.click;
    65        : if (GetKeyState(VK_CONTROL) < 0) then
                begin
                  for i := 0 to Pred(lvPayees.Items.Count) do
                    lvPayees.Items[i].Selected := true;
                end
                else
                  handled := false;

    77        : if (GetKeyState(VK_CONTROL) < 0) then
                  tbMerge.Click  //CTRL-M
                else
                  handled := false;

  else
    Handled := false;
  end;
end;
//------------------------------------------------------------------------------
function TfrmMaintainPayees.DeletePayee(Payee: TPayee): boolean;
var
   Name : string;
   Num  : integer;
begin
   Result := False;

   if AskYesNo('Delete Payee?','OK to delete payee '+Payee.pdName+ '?',DLG_NO,0) <> DLG_YES then exit;

   Name := Payee.pdName;
   Num  := Payee.pdNumber;

   MyClient.clPayee_List.DelFreeItem(Payee);
   Result := True;

   LogUtil.LogMsg(lmInfo,'MAINTAINPAYEESFRM','User Deleted Payee '+ Name + ' '+inttostr(Num));
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.tbDeleteClick(Sender: TObject);
var
  p : TPayee;
  PrevSelectedIndex: Integer;
  PrevTopIndex: Integer;
begin
  SearchTerm := '';
  if lvPayees.SelCount = 0 then exit;
  PrevSelectedIndex := lvPayees.Selected.Index;
  PrevTopIndex := lvPayees.TopItem.Index;
  if lvPayees.SelCount =1 then
  begin
    p := TPayee(lvPayees.Selected.SubItems.Objects[0]);
    if DeletePayee(p) then
    begin
      RefreshPayeeList;
      ReselectAndScroll(lvPayees, PrevSelectedIndex, PrevTopIndex);
    end;
  end
  else
  begin
    //user has selected multiple to delete
    if DeleteMultiple then
    begin
      RefreshPayeeList;
      ReselectAndScroll(lvPayees, PrevSelectedIndex, PrevTopIndex);      
    end;
  end;

  //Flag Audit
  MyClient.ClientAuditMgr.FlagAudit(arPayees);
end;
//------------------------------------------------------------------------------
function ColSort( Item1, Item2, ColNo : Integer ) : Integer; stdcall;
// Called by List View CustomSort
var
   S1, S2 : String;
   D1, D2 : integer;
begin
   // Get Strings
   if ( ColNo = 1 ) then begin
     S1 := Lowercase(TListItem( Item1 ).SubItems[ ColNo - 1 ]);
     S2 := Lowercase(TListItem( Item2 ).SubItems[ ColNo - 1 ]);
   end
   else
   if ( ColNo = 0) then begin
     //sort by payee number
     S1 := Lowercase(TListItem( Item1 ).Caption);
     S2 := Lowercase(TListItem( Item2 ).Caption);

     D1 := StrToIntDef( S1, 0);
     D2 := StrToIntDef( S2, 0);

     if D1 < D2 then
       result := -1
     else if D1 > D2 then
       result := 1
     else
       result := 0;

     Exit;
   end
   else begin
      S1 := Lowercase(TListItem( Item1 ).SubItems[ ColNo - 1 ]);
      S2 := Lowercase(TListItem( Item2 ).SubItems[ ColNo - 1 ]);
   end;

   //sort by string
   Result := 0;
   if ( S1 < S2 ) then begin
      Result := -1;
      Exit;
   end;
   if ( S1 > S2 ) then begin
      Result := 1;
      Exit;
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.lvPayeesColumnClick(Sender: TObject;
  Column: TListColumn);
var
   ClickColNo : Integer;
begin
   ClickColNo := Column.Index;
   if CurrentSortCol = ClickColNo then exit;

   DoSortByColNo( ClickColNo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainPayees.DoSortByColNo( ClickColNo : integer);
var
   i : Integer;
begin
   lvPayees.CustomSort( ColSort, ClickColNo );
   CurrentSortCol := ClickColNo;
   // Place Sort Indicator in Column
   with lvPayees do begin
      for i := 0 to Pred( Columns.Count ) do begin
         if ( i = ClickColNo ) then begin
            Columns[i].ImageIndex := MAINTAIN_COLSORT_BMP;  //Triangle
         end
         else begin
            Columns[i].ImageIndex := -1; //Blank
         end;
      end;
   end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.chkShowInactiveClick(Sender: TObject);
begin
  RefreshPayeeList;
end;

//------------------------------------------------------------------------------
function TfrmMaintainPayees.DeleteMultiple: boolean;
var
  i : integer;
  p : TPayee;
  pName : string;
  pNum  : integer;
begin
  result := false;
  if AskYesNo('Delete Payees?','You have selected '+inttostr(lvPayees.SelCount)+' payees to DELETE.  Please confirm this is correct.',DLG_NO,0) <> DLG_YES then exit;

  for i := 0 to Pred(lvPayees.items.Count) do
    if lvPayees.Items[i].Selected then
    begin
      p := TPayee(lvPayees.Items[i].SubItems.Objects[0]);
      pName := p.pdName;
      pNum  := p.pdNumber;
      MyClient.clPayee_List.DelFreeItem(p);
      result := true;

      LogUtil.LogMsg(lmInfo,'MAINTAINPAYEESFRM','User Deleted Payee '+ pName + ' '+inttostr(pNum));
    end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.tbMergeClick(Sender: TObject);
begin
  SearchTerm := '';
  ForceOnlyOneSelected;
  MergePayees;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.MergePayees;
var
  Code : string;
  FromClient : TClientObj;
  GSTTablesEqual : Boolean;
  i,j : integer;
  nPayee : TPayee;
  SourcePayee : TPayee;
  DuplicateFound : boolean;
  SourcePayeeLine : pPayee_Line_Rec;
  NewPayeeLine : pPayee_Line_Rec;
begin
 if SelectCopyFrom('Merge Payees from...',Code) then
 begin
   FromClient := nil;
   OpenAClient(Code,FromClient,false);
   try
     if not Assigned(FromClient) then
     begin
       HelpfulWarningMsg('Unable to open client '+code,0);
       exit;
     end;

     //check to see if the GST tables are the same for both clients
     if (FromClient.clPayee_List.ItemCount > 0) then
     begin
       GSTTablesEqual := True;
       i := 1;
       while (i <= Length(MyClient.clFields.clGST_Class_Names)) and (GSTTablesEqual) do
       begin
         if (MyClient.clFields.clGST_Class_Types[i] <> FromClient.clFields.clGST_Class_Types[i]) then
           GSTTablesEqual := False;
         for j := 1 to Length(MyClient.clFields.clGST_Rates[i]) do
         begin
           if (MyClient.clFields.clGST_Rates[i, j] <> FromClient.clFields.clGST_Rates[i, j]) then
             GSTTablesEqual := False;
         end;
         if (MyClient.clFields.clGST_Class_Codes[i] <> FromClient.clFields.clGST_Class_Codes[i]) then
           GSTTablesEqual := False;
         if (MyClient.clFields.clGST_Business_Percent[i] <> FromClient.clFields.clGST_Business_Percent[i]) then
           GSTTablesEqual := False;
         Inc(i);
       end;
     end else
       GSTTablesEqual := False;

     //have both clients open, begin copying.. only copy code if it doesnt exist in chart
     for i := FromClient.clPayee_List.First to FromClient.clPayee_List.Last do
     begin
       SourcePayee    := FromClient.clPayee_List.Payee_At(i);
       DuplicateFound :=  Assigned( MyClient.clPayee_List.Find_Payee_Number(SourcePayee.pdNumber))
                          or Assigned( MyClient.clPayee_List.Find_Payee_Name( SourcePayee.pdName));

       if not DuplicateFound then begin
         UpdateAppStatus('Merging Payees...',SourcePayee.pdName,(i/FromClient.clPayee_List.ItemCount)*100);

         //add the payee
         nPayee := TPayee.Create;

         nPayee.pdFields.pdNumber                   := SourcePayee.pdNumber;
         nPayee.pdFields.pdName                     := SourcePayee.pdName;
         nPayee.pdFields.pdABN                      := SourcePayee.pdFields.pdABN;
         nPayee.pdFields.pdContractor               := SourcePayee.pdFields.pdContractor;
         nPayee.pdFields.pdSurname                  := SourcePayee.pdFields.pdSurname;
         nPayee.pdFields.pdGiven_Name               := SourcePayee.pdFields.pdGiven_Name;
         nPayee.pdFields.pdOther_Name               := SourcePayee.pdFields.pdOther_Name;
         nPayee.pdFields.pdBusinessName             := SourcePayee.pdFields.pdBusinessName;
         nPayee.pdFields.pdTradingName              := SourcePayee.pdFields.pdTradingName;
         nPayee.pdFields.pdAddress                  := SourcePayee.pdFields.pdAddress;
         nPayee.pdFields.pdAddressLine2             := SourcePayee.pdFields.pdAddressLine2;
         nPayee.pdFields.pdTown                     := SourcePayee.pdFields.pdTown;
         nPayee.pdFields.pdState                    := SourcePayee.pdFields.pdState;
         nPayee.pdFields.pdStateId                  := SourcePayee.pdFields.pdStateId;
         nPayee.pdFields.pdPost_Code                := SourcePayee.pdFields.pdPost_Code;
         nPayee.pdFields.pdCountry                  := SourcePayee.pdFields.pdCountry;
         nPayee.pdFields.pdPhone_Number             := SourcePayee.pdFields.pdPhone_Number;
         nPayee.pdFields.pdInstitutionBSB           := SourcePayee.pdFields.pdInstitutionBSB;
         nPayee.pdFields.pdInstitutionAccountNumber := SourcePayee.pdFields.pdInstitutionAccountNumber;
         nPayee.pdFields.pdIsIndividual             := SourcePayee.pdFields.pdIsIndividual;
         nPayee.pdFields.pdContractor               := SourcePayee.pdFields.pdContractor;

         for j := SourcePayee.pdLines.First to SourcePayee.pdLines.Last do
         begin
           SourcePayeeLine := SourcePayee.pdLines.PayeeLine_At(j);
           NewPayeeLine := New_Payee_Line_Rec;

           NewPayeeLine.plAccount    := SourcePayeeLine.plAccount;
           NewPayeeLine.plPercentage := SourcePayeeLine.plPercentage;
           NewPayeeLine.plLine_Type := SourcePayeeLine.plLine_Type;
           NewPayeeLine.plGL_Narration := SourcePayeeLine.plGL_Narration;

           if (GSTTablesEqual) then
           begin
             NewPayeeLine.plGST_Class := SourcePayeeLine.plGST_Class;
             //see if gst class matches the default in the current chart
             NewPayeeLine.plGST_Has_Been_Edited :=
                (SourcePayeeLine.plGST_Class <> MyClient.clChart.GSTClass( SourcePayeeLine.plAccount));
           end
           else
           begin
             NewPayeeLine.plGST_Class := 0;
             NewPayeeLine.plGST_Has_Been_Edited := false;
           end;

           nPayee.pdLines.Insert(NewPayeeLine, MyClient.ClientAuditMgr);
         end;

         MyClient.clPayee_List.Insert(nPayee);

         //Flag Audit
         MyClient.ClientAuditMgr.FlagAudit(arPayees);
       end;
     end;
   finally
     CloseAClient(FromClient);
     FromClient := nil;
     RefreshPayeeList;
     ClearStatus;
   end;
 end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.RepositionOnNumber(aNumber: string);
var
   LItem : TListItem;
begin
   LItem := lvPayees.FindCaption( 0, aNumber, false, true, false);
   if Assigned( LItem) then begin
      lvUtils.SelectListViewItem( lvPayees, LItem);
   end;
end;
//------------------------------------------------------------------------------
// Listview automatically looks up words bsed on first column only
// So we'll have to implement our own name lookup
function TfrmMaintainPayees.RepositionOnName(aPartialName: string): Boolean;
var
   i: Integer;
   Possibles: TStringList;
begin
  Result := False;
  lvPayees.OnSelectItem := nil;
  Possibles := TStringList.Create;
  try
    aPartialName := Lowercase(aPartialName);
    for i := 0 to Pred(lvPayees.Items.Count) do
    begin
      if Pos(aPartialName, Lowercase(lvPayees.Items[i].SubItems[0])) = 1 then
        Possibles.AddObject(lvPayees.Items[i].SubItems[0], TObject(i));
    end;
    if Possibles.Count > 0 then
    begin
      Possibles.Sort;
      lvUtils.SelectListViewItem( lvPayees, lvPayees.Items[Integer(Possibles.Objects[0])]);
      DoSortByColNo(1);
      Result := True;
    end;
  finally
    lvPayees.OnSelectItem := lvPayeesSelectItem;
    Possibles.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainPayees.ForceOnlyOneSelected;
var
  FirstSelected : TListItem;
begin
    if lvPayees.SelCount > 1 then
    begin
      FirstSelected := lvPayees.Selected;
      lvPayees.Selected := nil;
      lvPayees.Selected := FirstSelected;
      lvPayees.Selected.Focused := true;
    end;
end;
//------------------------------------------------------------------------------
function TfrmMaintainPayees.Execute: boolean;
begin
   result := false;
   RefreshPayeeList;
   ShowModal;
end;
//------------------------------------------------------------------------------
function MaintainPayees(ContextID : Integer) : boolean;
var
  MyDlg : TfrmMaintainPayees;
begin
  MyDlg := TfrmMaintainPayees.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, ContextID);
    MyDlg.Execute;
    result := True;
  finally
    MyDlg.Free;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainPayees.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

procedure TfrmMaintainPayees.lvPayeesKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not IsNumeric(Key) then
  begin
    SearchTerm := SearchTerm + Key;
    if not RepositionOnName(SearchTerm) then
    begin
      SearchTerm := '';
      if RepositionOnName(Key) then
        SearchTerm := Key;
    end;
  end
  else // numeric - switch sort order
  begin
    DoSortByColNo(0);
    SearchTerm := '';
  end;
end;

procedure TfrmMaintainPayees.lvPayeesSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  SearchTerm := '';
end;

end.
