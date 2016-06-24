//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
unit MaintainChartfrm;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, bkdefs, ExtCtrls, StdCtrls, RzPanel, RzButton,
  OSFont;

type
  TfrmMaintainChart = class(TForm)
    lvChart: TListView;
    tmrKeyPress: TTimer;
    pnlQuickSet: TPanel;
    Label8: TLabel;
    Label9: TLabel;
    lblGroup: TLabel;
    lblSub: TLabel;
    lblGst: TLabel;
    lblDiv: TLabel;
    lblCode: TLabel;
    lblDesc: TLabel;
    cmbReportGroup: TComboBox;
    cmbSubGroup: TComboBox;
    cmbGST: TComboBox;
    Bevel1: TBevel;
    Panel1: TPanel;
    Bevel2: TBevel;
    chkPosting: TCheckBox;
    lblPosting: TLabel;
    pnlHinsts: TPanel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    lblDivisions: TLabel;
    RzToolbar1: TRzToolbar;
    tbNew: TRzToolButton;
    tbEdit: TRzToolButton;
    tbDelete: TRzToolButton;
    tbQuickSet: TRzToolButton;
    RzSpacer1: TRzSpacer;
    tbMerge: TRzToolButton;
    RzSpacer2: TRzSpacer;
    tbClose: TRzToolButton;
    tbHelpSep: TRzSpacer;
    tbHelp: TRzToolButton;
    lblBasic: TLabel;
    chkBasic: TCheckBox;
    lblItemCount: TLabel;
    Label2: TLabel;
    lblAltCodeName: TLabel;
    LblAltCode: TLabel;
    tbInactive: TRzToolButton;
    RzSpacer3: TRzSpacer;
    lblInactive: TLabel;
    chkInactive: TCheckBox;
    procedure tbCloseClick(Sender: TObject);
    procedure tbEditClick(Sender: TObject);
    procedure lvChartDblClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure tbNewClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure lvChartKeyPress(Sender: TObject; var Key: Char);
    procedure lvChartKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure lvChartColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tbMergeClick(Sender: TObject);
    procedure lvChartKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure tmrKeyPressTimer(Sender: TObject);
    procedure lvChartSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure cmbGSTChange(Sender: TObject);
    procedure cmbReportGroupChange(Sender: TObject);
    procedure cmbSubGroupChange(Sender: TObject);
    procedure btnHideQuickSetClick(Sender: TObject);
    procedure tbQuickSetClick(Sender: TObject);
    procedure cmbReportGroupDropDown(Sender: TObject);
    procedure cmbSubGroupDropDown(Sender: TObject);
    procedure cmbGSTDropDown(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure chkPostingClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure chkBasicClick(Sender: TObject);
    procedure tbInactiveClick(Sender: TObject);
    procedure chkInactiveClick(Sender: TObject);
  private
    { Private declarations }
    CheckAnyEdit     : Boolean;
    ChartChanged     : Boolean; //Adds or deletes
    ApplyGSTRequired : Boolean; //re apply GST
    LockRequired     : Boolean;
    KeyBuffer        : string;
    CurrShiftState   : TShiftState;
    KeyDownFired,
    GroupQuickKey    : boolean; //see note on keydown event
    CurrSortCol      : integer;
    cmbReportGroupWidth : Integer;
    cmbSubGroupWidth : Integer;
    cmbGSTWidth      : Integer;
    SearchTerm       : string;
    FTaxName         : String;
    FHasAlternativeCode: Boolean;
    AltCodeModifier: integer;
    fShowInactive: boolean;
    fFirstSelectedItem : TListItem;

    procedure RefreshChartList;

    procedure MergeChart;
    procedure RefreshItem(p : pAccount_Rec; item : TListItem);
    function  DeleteAccount(Account : pAccount_Rec): boolean;
    function  DeleteMultiple : boolean;
    procedure SetType(newType : integer; MoveAfter : boolean = True);
    procedure SetGSTClass(newClass : integer; MoveAfter : boolean = True);
    procedure SetDivision( divNo : integer; MoveAfter : boolean = True);
    procedure SetSubType(sTypeNo: integer; MoveAfter : boolean = True);
    procedure SetPosting(isPosting: Boolean; MoveAfter: Boolean = True);
    procedure SetBasic(HideInBasic: Boolean; MoveAfter: Boolean = True);
    procedure SetInactive(const aInactive: boolean; const aMoveAfter: boolean = true);
    procedure DoResort( ColToSortOn : integer);

    procedure ForceOnlyOneSelected;
    procedure MoveDownOne;

    procedure UpdateQuickSetWindow;

    procedure LoadCombos;
    function RepositionOnName(aPartialName: string): Boolean;
    procedure SortByKey(Key: Char);
    procedure SetHasAlternativeCode(const Value: Boolean);
    property HasAlternativeCode: Boolean read FHasAlternativeCode write SetHasAlternativeCode;
    function CorrectedColNum(ColNum: integer): integer;

    procedure UpdateInactiveColumn;
    procedure SetInActiveNoEvents(const aValue: boolean);
  public
    { Public declarations }
    function Execute : boolean;
  end;


  function MaintainChart(ReturnAnyEdit : Boolean; ContextID : Integer) : boolean;

//******************************************************************************
implementation

uses
  bkXPThemes,
  BKHelp,
  glConst,
  Globals,
  YesNoDlg,
  LogUtil,
  bkconst,
  EditAccountDlg,
  InfoMoreFrm,
  WarningMoreFrm,
  Software,
  WinUtils,
  LvUtils,
  StStrs,
  imagesfrm,
  CopyFromDlg,
  clObj32,
  canvasUtils,
  files,
  bkchio,
  updatemf,
  GenUtils,
  ComboUtils,
  Progress,
  CountryUtils,
  AuditMgr, MAINFRM,
  AccountInactive;


{$R *.DFM}

const
   UnitName = 'MAINTAINCHARTFRM';

   // Column Numbers
   c_Code = 0;
   c_Desc = 1;
   c_AltCode = 2;
   c_Group = 3;
   c_SubGroup = 4;
   c_GST = 5;
   c_Division = 6;
   c_Basic = 7;
   c_Post = 8;
   c_Inactive = 9;

   // Column width
   w_Inactive = 60;


{ TfrmMaintainChart }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ColSort( Item1, Item2, ColNo : Integer ) : Integer; stdcall;
// Called by List View CustomSort
var
   S1, S2 : String;
begin
   // Get Strings
   if ( ColNo = 0 ) then
   begin
     S1 := TListItem( Item1 ).Caption;
     S2 := TListItem( Item2 ).Caption;

     if UseXlonSort then
       result := XlonSort( S1, S2)
     else
       result := StStrS.CompStringS( S1, S2 );
   end
   else
   begin
     S1 := TListItem( Item1 ).SubItems[ ColNo - 1 ];
     S2 := TListItem( Item2 ).SubItems[ ColNo - 1 ];
     result := StStrS.CompStringS( S1, S2 );
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMaintainChart.DeleteAccount(Account: pAccount_Rec): boolean;
var
  Code,
  Name : string;
begin
  result := false;
  if AskYesNo('Delete Account?','OK to Delete Account '+Account.chAccount_Description+ '?',DLG_NO,0) <> DLG_YES then exit;

  Name := Account.chAccount_Description;
  Code := Account.chAccount_Code;

  MyClient.clChart.DelFreeItem(Account);
  result := true;

  //*** Flag Audit ***
  MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);

  LogUtil.LogMsg(lmInfo,UnitName,'User Deleted Account '+ Name + ' '+Code);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMaintainChart.Execute: boolean;

begin
   ApplyGSTRequired := False;
   ChartChanged := False;
   LockRequired := False;
   RefreshChartList;

   cmbReportGroupWidth := cmbReportGroup.Width;
   cmbSubGroupWidth := cmbSubGroup.Width;
   cmbGSTWidth := cmbGST.Width;

   LoadCombos;
   UpdateQuickSetWindow;

   //sort by default order
   DoResort( 0);

   ShowModal;
   if (CheckAnyEdit) then
     Result := (ChartChanged or ApplyGSTRequired)
   else
     //tells calling routine that GST will need to be applied to all entries.
     //is triggered by the gst class being edited for an account
     result := ApplyGSTRequired;

   //*** Flag Audit ***
   if ChartChanged then
     MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);

   with MyClient, MyClient.clFields do
   if (LockRequired)
   and (not clChart_Is_Locked) 
   and CanRefreshChart( clCountry, clAccounting_System_Used ) then
   begin
      If AskYesNo('Lock Client Chart','You have altered the client''s chart. '+
         'Do you want to lock the chart to prevent it being refreshed?', DLG_YES, 0 ) = DLG_YES then
      begin
         clChart_Is_Locked := TRUE;
         HelpfulInfoMsg( 'The client''s chart has been locked.  You can Unlock it '+
            'on the "Accounting System" menu option', 0 );
      end;
   end;

   if (not Result) and (ChartChanged) then
     frmMain.UpdateWindowsAfterChartRefresh;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.RefreshChartList;
var
  NewItem : TListItem;
  Account : pAccount_Rec;
  i : integer;
begin
  fFirstSelectedItem := nil;
  MsgBar('Loading Chart Codes',true);
  lvChart.Items.BeginUpdate;
  try

    lvChart.Items.Clear;

    if not Assigned(myClient) then
       Exit;

    with MyClient, MyClient.clChart do
    for i := 0 to Pred(itemCount) do
    begin
      Account := Account_At(i);
      if Assigned(AdminSystem) or not Account.chHide_In_Basic_Chart then
      begin
        if fShowInactive or (not Account.chInactive) then
        begin
          NewItem := lvChart.Items.Add;
          NewItem.ImageIndex := -1;
          NewItem.Caption := Account.chAccount_Code;
          NewItem.SubItems.AddObject('',TObject(Account));  {desc}
          NewItem.SubItems.Add('');                         {type}
          NewItem.SubItems.Add('');                         {Alt Code}
          NewItem.SubItems.Add('');                         {Subtype}
          NewItem.SubItems.Add('');                         {gst}
          NewItem.SubItems.Add('');                         {divisions}
          NewItem.SubItems.Add('');                         {basic}
          NewItem.SubItems.Add('');                         {posting}
          NewItem.SubItems.Add('');                         {inactive}
          RefreshItem(Account,NewItem);
        end;
      end;
    end;
    DoResort( CurrSortCol);

    if lvChart.Items.Count > 0 then
    begin
      lvChart.Selected := lvChart.Items[0];
      lvChart.Selected.Focused := true;
    end;
  finally
    lvChart.Items.EndUpdate;
    msgBar('',false);
    lblItemCount.Caption := IntToStr(lvChart.Items.Count);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.tbCloseClick(Sender: TObject);
begin
   close;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MaintainChart(ReturnAnyEdit : Boolean; ContextID : Integer) : boolean;
//will return true if ApplyGSTDefaults need to be called
var
  MaintainChart : TfrmMaintainChart;
begin
  MaintainChart := TfrmMaintainChart.Create(Application.mainForm);
   with MaintainChart do begin
      try
        //BKHelpSetUp(MaintainChart, ContextID);
        tbHelp.HelpContext := ContextID;

        CheckAnyEdit := ReturnAnyEdit;
        result := Execute;
      finally
        Free;
      end;
   end;

   //make sure there are no invalid account links
   MyClient.clChart.RefreshDependencies;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.tbEditClick(Sender: TObject);
const
   ThisMethodName = 'TfrmMaintainChart.tbEditClick';
var
  p : pAccount_Rec;
  cIndex : integer;   //index of pointer in collection
  WasCode, WasDesc : string;
  PreviousGSTClass : integer;
  WasPosting: Boolean;
  WasInactive: boolean;
begin
  if not tbEdit.Enabled then
    Exit; //if button isn't enabled then they can't edit (even if they double click or use enter);

  SearchTerm := '';
  if lvChart.Selected <> nil then
  begin
    //force only the first item to be selected
    ForceOnlyOneSelected;

    p        := pAccount_Rec(lvChart.Selected.SubItems.Objects[0]);
    cIndex   := MyClient.clChart.IndexOf(p); //need because key may change
    WasCode  := p^.chAccount_Code;
    WasDesc  := P^.chAccount_Description;
    WasPosting := P^.chPosting_Allowed;
    PreviousGSTClass := p^.chGST_Class;
    WasInactive := P^.chInactive;

    if EditChartAccount(p, tbNew.Enabled, chkInactive.Enabled) then begin
      ChartChanged := True;
      if ( WasCode <> p^.chAccount_Code ) then begin
         LockRequired := True;
         //list key has changed so remove item and readd it
         with MyClient.clChart do begin
            AtDelete(cIndex);
            Insert(p);
         end;
         LogUtil.LogMsg(lmInfo, UnitName, 'Changed code from '+WasCode+
                                          ' to ' + p^.chAccount_Code );
         RefreshChartList;

         //reposition list view on edited item
         lvUtils.SelectListViewItem(lvChart, lvChart.FindCaption(0,p^.chAccount_Code,false,true,true));
      end
      else begin
        if not fShowInactive and (WasInactive <> p^.chInactive) then
        begin
          RefreshChartList;
        end
        else
        begin
          RefreshItem(p,lvChart.Selected);
          lvChart.UpdateItems(lvChart.Selected.Index,lvChart.Selected.Index);
        end;
      end;

      //test for gst change
      if p^.chGST_Class <> PreviousGSTClass  then begin
         ApplyGSTRequired := True;
         LockRequired := True;
      end;

      if (WasDesc <> P^.chAccount_Description)
      or (WasPosting <> P^.chPosting_Allowed) then
          LockRequired := True;

    end;

    UpdateQuickSetWindow;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.lvChartDblClick(Sender: TObject);
begin
  tbEdit.click;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.FormShortCut(var Msg: TWMKey;
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
    65        : if (GetKeyState(VK_CONTROL) < 0) then  //Ctrl-A - Select All
                begin
                  for i := 0 to Pred(lvChart.Items.Count) do
                    lvChart.Items[i].Selected := true;
                end
                else
                  handled := false;

    {77        : if (GetKeyState(VK_CONTROL) < 0) then
                  tbMerge.Click  //CTRL-M
                else
                  handled := false;

    81        : if (GetKeyState(VK_CONTROL) < 0) then
                  tbQuickSet.Click  //CTRL-Q
                else
                  handled := false;}

    VK_F1..VK_F12 :
      if (GetKeyState(VK_SHIFT) < 0) then
      begin
        SetGSTClass( Msg.CharCode -111, true);
        Msg.CharCode := 0;
      end
      else
      begin
        //need to show help if F1 pressed, automatic handling has been disable
        //because if conflicts with SHIFT+F1 being pressed
        if Msg.CharCode = VK_F1 then
          BKHelpShowContext( tbHelp.HelpContext);
      end;

  else
    Handled := false;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.tbNewClick(Sender: TObject);
var
   p : pAccount_Rec;
begin
  if not tbNew.Enabled then
    Exit;
  
   SearchTerm := '';
   ForceOnlyOneSelected;
   if AddChartAccount(p) then
   begin
     ChartChanged := True;
     LockRequired := True;
     RefreshChartList;
     //reposition list view on edited item
     lvUtils.SelectListViewItem(lvChart, lvChart.FindCaption(0,p^.chAccount_Code,false,true,true));
   end;
   UpdateQuickSetWindow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.tbDeleteClick(Sender: TObject);
var
  p : pAccount_Rec;
  PrevSelectedIndex: Integer;
  PrevTopIndex: Integer;
begin
  if not tbDelete.Enabled then
    Exit;

  SearchTerm := '';
  if lvChart.SelCount = 0 then exit;
  PrevSelectedIndex := lvChart.Selected.Index;
  PrevTopIndex := lvChart.TopItem.Index;
  if lvChart.SelCount =1 then
  begin
    p := pAccount_Rec(lvChart.Selected.SubItems.Objects[0]);
    if DeleteAccount(p) then
    begin
      ChartChanged := True;
      LockRequired := True;
      RefreshChartList;
      ReselectAndScroll(lvChart, PrevSelectedIndex, PrevTopIndex);
    end;
  end
  else
  begin
    //user has selected multiple to delete
    if DeleteMultiple then
    begin
      ChartChanged := True;
      LockRequired := True;
      RefreshChartList;
      ReselectAndScroll(lvChart, PrevSelectedIndex, PrevTopIndex);      
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.lvChartKeyPress(Sender: TObject; var Key: Char);
var
  wasKey : Char;
begin
   wasKey := Key;
   Key    := #0;

   if not KeyDownFired then
      Exit;

   if GroupQuickKey  then begin
     if tbEdit.Enabled then

     case KeyBuffer[1] of
    //Can't use A for CurrentAsset as this conflicts with Select All, use U
//   'a','A'  : SetType( atCurrentAsset       );
     'b','B'  : SetType( atBankAccount        );
     'c','C'  : SetType( atCreditors          );
     'd','D'  : SetType( atDebtors            );
     'e','E'  : SetType( atExpense            );
     'f','F'  : SetType( atFixedAssets        );
     'g','G'  : SetType( atGSTPayable         );
     'h','H'  : SetType( atStockOnHand        );
     'i','I'  : SetType( atIncome             );
     'j','J'  : SetType( atOtherIncome        );
//   'k','K'  : SetType(                      );
     'l','L'  : SetType( atCurrentLiability   );
     'm','M'  : SetType( atLongTermLiabilitY  );
//   'n','N'  : SetType(                      );
     'o','O'  : SetType( atOtherExpense       );
     'p','P'  : SetType( atPurchases          );
     'q','Q'  : SetType( atEquity             );
     'r','R'  : SetType( atGSTReceivable      );
     's','S'  : SetType( atOpeningStock       );
     't','T'  : SetType( atClosingStock       );
     'u','U'  : SetType( atCurrentAsset       );
//   'v','V'  : SetType(                      );
//   'w','W'  : SetType(                      );
     'x','X'  : SetType( atDirectExpense      );
     'y','Y'  : SetType( atUnknownCR          );
     'z','Z'  : SetType( atUnknownDR          );
     else
       Key := wasKey;
     end
     else Key := WasKey;

   end else begin
      // Not a Group Key...
      Key := wasKey;
      if KeyBuffer > '' then begin

         if KeyBuffer[1] in ['0'..'9'] then
            Key := wasKey
         else
         begin
           SortByKey(Key);  
         end;

      end;
   end;
end;

procedure TfrmMaintainChart.SortByKey(Key: Char);
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
    DoResort(0);
    SearchTerm := '';
  end;
end;
//------------------------------------------------------------------------------
// Listview automatically looks up words bsed on first column only
// So we'll have to implement our own name lookup
function TfrmMaintainChart.RepositionOnName(aPartialName: string): Boolean;
var
   i: Integer;
   Possibles: TStringList;
begin
  Result := False;
  lvChart.OnSelectItem := nil;
  Possibles := TStringList.Create;
  try
    aPartialName := Lowercase(aPartialName);
    for i := 0 to Pred(lvChart.Items.Count) do
    begin
      if Pos(aPartialName, Lowercase(lvChart.Items[i].SubItems[0])) = 1 then
        Possibles.AddObject(lvChart.Items[i].SubItems[0], TObject(i));
    end;
    if Possibles.Count > 0 then
    begin
      Possibles.Sort;
      lvUtils.SelectListViewItem( lvChart, lvChart.Items[Integer(Possibles.Objects[0])]);
      DoResort(1);
      Result := True;
    end;
  finally
    lvChart.OnSelectItem := lvChartSelectItem;
    Possibles.Free;
  end;
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.SetType(newType: integer; MoveAfter : boolean);
//sets the account type, must clear the sub type because may be setup different
var
  p : pAccount_Rec;
  i : integer;
begin
  if not (newType in [atMin..atMax]) then
    Exit;

  //cycle through selected items
  for i := 0 to Pred( lvChart.Items.Count) do begin
     if lvChart.Items[ i].Selected then begin
        p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);

        if NewType <> p.chAccount_Type then begin
           p.chAccount_Type := NewType;
           RefreshItem(p,lvChart.Items[ i]);
           lvChart.UpdateItems( i,i );
        end;
     end;
  end;

  if (lvChart.SelCount = 1) and  MoveAfter then
     MoveDownOne;

  UpdateQuickSetWindow;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.RefreshItem(p: pAccount_Rec; item: TListItem);
Var
   j : Integer;
   s : string;
begin
  Item.Caption      := p.chAccount_Code;
  Item.SubItems[CorrectedColNum(c_Desc) - 1]  := p.chAccount_Description;
  if HasAlternativeCode then
    Item.SubItems[c_AltCode - 1]  := p.chAlternative_Code;

  if p.chAccount_Type in [atMin..atMax] then
    Item.SubItems[CorrectedColNum(c_Group) - 1] := Localise(MyClient.clFields.clCountry, atNames[p.chAccount_Type])
  else
    Item.SubItems[CorrectedColNum(c_Group) - 1] := '';

  if ( p.chAccount_Type in [atMin..atMax] ) and
     ( p.chSubType in [ 1..Max_SubGroups ] ) then
  Begin
     S := Trim(MyClient.clCustom_Headings_List.Get_SubGroup_Heading( p.chSubType));
     Item.SubItems[CorrectedColNum(c_SubGroup) - 1] := Inttostr( p.chSubType) + ': ' + S;
  end
  else
    Item.SubItems[CorrectedColNum(c_SubGroup) - 1] := '';

  with MyClient.clFields do begin
     If ( p.chGST_Class in GST_CLASS_RANGE ) then
       Item.SubItems[CorrectedColNum(c_GST) - 1] := clGST_Class_Codes[ p.chGST_Class] {+ ' ' + clGST_Class_Names[p.chGST_Class]}
     else
       Item.SubItems[CorrectedColNum(c_GST) - 1] := '';
  end;

  S := '';
  for j := 1 to Max_Divisions do begin
     if p.chPrint_in_Division[j] then begin
       if (S = '') then
         S := S + inttostr(j)
       else
         S := S + ', ' + inttostr(j);
     end;
  end;
  Item.SubItems[CorrectedColNum(c_Division) -1] := S;

  if p.chHide_In_Basic_Chart then
     item.SubItems[CorrectedColNum(c_Basic) -1] := ''
  else
    Item.SubItems[CorrectedColNum(c_Basic) -1] := 'Y';

  if p.chPosting_Allowed then
     item.SubItems[CorrectedColNum(c_Post) -1] := 'Y'
  else
    Item.SubItems[CorrectedColNum(c_Post) -1] := '';

  if p.chInactive then
    Item.SubItems[CorrectedColNum(c_Inactive) - 1] := 'Y'
  else
    Item.SubItems[CorrectedColNum(c_Inactive) - 1] := '';
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainChart.SetDivision(divNo: integer; MoveAfter : boolean);
var
  p : pAccount_Rec;
  i : integer;
begin
  if not (divNo in [0..Max_Divisions]) then
    exit;

  //cycle through selected items
  for i := 0 to Pred( lvChart.Items.Count) do begin
     if lvChart.Items[ i].Selected then begin
        p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);
        if DivNo = 0 then
           FillChar( p.chPrint_in_Division, SizeOf( p.chPrint_in_Division), #0)
        else
           p.chPrint_in_Division[ DivNo] := not p.chPrint_in_Division[ DivNo];
        RefreshItem(p,lvChart.Items[ i]);
        lvChart.UpdateItems( i,i );

        //*** Flag Audit ***
        MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);
     end;
  end;

  UpdateQuickSetWindow;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainChart.SetSubType( sTypeNo: integer; MoveAfter : boolean);
var
  p : pAccount_Rec;
  i : integer;
begin
  if not (sTypeNo in [0..Max_SubGroups]) then
    exit;

  //cycle through selected items
  for i := 0 to Pred( lvChart.Items.Count) do begin
     if lvChart.Items[ i].Selected then begin
        p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);
        if p.chAccount_Type in [ atMin .. atMax ] then begin
           p.chSubtype := sTypeNo;
           RefreshItem(p,lvChart.Items[ i]);
           lvChart.UpdateItems( i,i );
        end;

        //*** Flag Audit ***
        MyClient.ClientAuditMgr.FlagAudit(arChartOfAccounts);
     end;
  end;

  if (lvChart.SelCount = 1) and  MoveAfter then
     MoveDownOne;

  UpdateQuickSetWindow;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.lvChartKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
//the keydownfired boolean is set here to indicate that a key down event was received
//before the keypress event.  This is important here because it allows us to catch
//keystrokes that result from using ALT+nn when nn is a number typed on the numeric
//keypad.  A key down event is not fired when ALT+nn is used, key pressed is.
//We need to test this because we use ALT+nn to set sub groups, if the nn code
//results in a letter being added then the report group of the next line will
//also be set
var
  Ch : Char;
begin
  Ch := #0;
  GroupQuickKey := False;
  if Key in [ord('0')..ord('9')] then
    Ch := Chr( Key);
  if Key in [VK_NUMPAD0..VK_NUMPAD9] then
    Ch := Chr( Key - VK_NUMPAD0 + ord('0'));

  if Key in [VK_CONTROL,VK_MENU] then begin
    KeyBuffer := '';
    CurrShiftState := [];
  end;
  //division or sub group   Ctrl = Div  Alt = SG
  if ((Shift = [ssCtrl]) or ( Shift = [ssAlt])) and ( Key in [ord('0')..ord('9'), VK_NUMPAD0..VK_NUMPAD9]) then begin
     KeyBuffer := KeyBuffer + Ch;
     CurrShiftState := Shift;
     //reset timer
     tmrKeyPress.Enabled := false;
     tmrKeyPress.Enabled := true;
     key := 0;
  end else if (Shift = [ssCtrl]) and (key in [ord('a').. ord('z'), ord('A').. ord('Z')]) then begin
     GroupQuickKey := True;
     KeyBuffer := Upcase(Char(Key));
  end else if (Shift = []) and (Key in [ord('0')..ord('9'), VK_NUMPAD0..VK_NUMPAD9,ord('a').. ord('z'), ord('A').. ord('Z')]) then begin
     if Key in [ord('a').. ord('z'), ord('A').. ord('Z')] then
        KeyBuffer := KeyBuffer + Char(Key)
     else
        KeyBuffer := KeyBuffer + Ch;
     CurrShiftState := [];
  end;
  KeyDownFired := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.lvChartKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key in [VK_CONTROL,VK_MENU] then begin
     tmrKeyPress.OnTimer(nil);
  end;

  //need to reset this here
  KeyDownFired := false;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.SetGSTClass(newClass: integer; MoveAfter : boolean);
var
  p : pAccount_Rec;
  i : integer;
  LApplyGSTRequired: Boolean;
begin
  if not (newClass in [ 0..Max_GST_Class]) then
    Exit;

  if lvChart.SelCount < 1 then
    Exit;

  LApplyGSTRequired := false;

  //cycle thru all selected items to see if GST has changed on any of them
  for i := 0 to Pred( lvChart.Items.Count) do begin
    if lvChart.Items[ i].Selected then begin
      p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);

      if NewClass > 0 then begin
        //make sure this is a valid class
        if MyClient.clFields.clGST_Class_Names[ NewClass ]= '' then begin
          ErrorSound;
          exit;
        end;
      end;

      //see if class has changed
      if ( NewClass <> p^.chGST_class) then begin
         LApplyGSTRequired := True;
      end;
    end;
  end;

  if not LApplyGSTRequired then
     //nothing changed so exit
     Exit;

  if not INI_DontShowMe_EditChartGST then begin
    //Ask to user if the want to do this
    if AskYesNoCheck( 'Edit ' + FTaxName + ' Class for Account(s)',
                      'This will change the ' + FTaxName + ' Class and Amount for all Entries that '+
                      'are coded to this/these chart code(s), which are yet to be transferred or finalised. '#13#13+
                      'Entries where the ' + FTaxName + ' has been overriden will not be affected.'#13#13+
                      'Please confirm you want to do this?',
                      '&Dont Ask Me this again',
                      INI_DontShowMe_EditChartGST,
                      DLG_YES, 0) <> DLG_YES then exit;
  end;

  //cycle thru selected items setting new class and updating item
  for i := 0 to Pred( lvChart.Items.Count) do begin
    if lvChart.Items[ i].Selected then begin
      p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);
      p.chGST_Class := newClass;
      RefreshItem(p, lvChart.Items[ i]);
      lvChart.UpdateItems( i, i);
    end;
  end;
  ApplyGSTRequired := True;
  LockRequired := True;

  if (lvChart.SelCount = 1) and  MoveAfter then
    MoveDownOne;

  UpdateQuickSetWindow;
end;
procedure TfrmMaintainChart.SetHasAlternativeCode(const Value: Boolean);
begin
  FHasAlternativeCode := Value;
  if HasAlternativeCode then begin
     lblAltCodeName.Visible := True;
     lblAltCodeName.Caption := AlternativeChartCodeName(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);
     LblAltCode.Visible := True;
     lvChart.Columns[c_AltCode].Width := 120;
     lvChart.Columns[c_AltCode].MaxWidth := 0;
     lvChart.Columns[c_AltCode].Caption := lblAltCodeName.Caption;
     lblDesc.Top := 70;
     Label9.Top := 70;
     AltCodeModifier := 0;
     self.Width := self.Width + lvChart.Columns[c_AltCode].Width;
  end else begin
     lblAltCodeName.Visible := False;
     LblAltCode.Visible := False;
     lvChart.Columns[c_AltCode].Destroy;
     lblDesc.Top := 62;
     Label9.Top := 62;
     AltCodeModifier := 1; // we have removed the alternative code column, so some columns need to be adjusted by this amount
  end;

end;

procedure TfrmMaintainChart.SetInActiveNoEvents(const aValue: boolean);
var
  Event: TNotifyEvent;
begin
  // Workaround: we don't want OnCLick events to run with dialogs in some cases
  Event := chkInactive.OnClick;
  chkInactive.OnClick := nil;
  chkInactive.Checked := aValue;
  chkInactive.OnClick := Event;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.lvChartColumnClick(Sender: TObject;
  Column: TListColumn);
var
   ClickColNo : Integer;
begin
   ClickColNo := Column.Index;
   DoResort( ClickColNo);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  HasAlternativeCode :=
    HasAlternativeChartCode(MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);

  lvChart.Column[CorrectedColNum(c_Code)].Width := CalcAcctColWidth( lvChart.Canvas, lvChart.Font, 75);
  SetListViewColWidth(lvChart,1,150);

  lvChartColumnClick( Self, lvChart.Column[CorrectedColNum(c_Code)] ); //set down arrow
  CurrSortCol     := 0;
  tbMerge.Enabled := Assigned( AdminSystem)
                 and ( not CurrUser.HasRestrictedAccess);
  {$IFDEF SmartBooks}
     Self.Caption := 'Maintain File Codes';
  {$ENDIF}
  SetUpHelp;
  lblItemCount.Caption := '0';
  KeyBuffer := '';
  CurrShiftState := [];
  FTaxName := MyClient.TaxSystemNameUC;
  lvChart.Columns[ CorrectedColNum(c_GST) ].Caption := FTaxName;
  lblGST.Caption := FTaxName;
  //New, Edit Delete are enabled if in Practice, or if in Books and Allowed to edit Chart.
  tbNew.Enabled := Assigned(AdminSystem)
                or MyClient.clExtra.ceAllow_Client_Edit_Chart;
  tbDelete.Enabled := tbNew.Enabled;
  tbEdit.Enabled := tbNew.Enabled;
  tbQuickSet.Enabled := tbNew.Enabled;
  //Books can only see basic, so they shouldn't be allowed to change an item to the full chart
  chkBasic.Visible := Assigned(AdminSystem);
  lblBasic.Visible := chkBasic.Visible;
  //if the basic checkbox is hidden, move the posting checkbox up so it doesn't look funny
  if not chkBasic.Visible then
  begin
    chkInactive.Top := chkPosting.Top;
    lblInactive.Top := lblPosting.Top;
    chkPosting.Top := chkBasic.Top;
    lblPosting.Top := lblBasic.Top;
  end;
  chkInactive.Enabled := assigned(AdminSystem);
  lblInactive.Enabled := chkInactive.Enabled;

  // Inactive column
  fShowInactive := False; //assigned(AdminSystem);
  UpdateInactiveColumn;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   tbNew.Hint       :=
                    'Add new Account Code|' +
                    'Add new Account Code';
   tbEdit.Hint      :=
                    'Edit the highlighted Account Code|' +
                    'Edit the highlighted Account Code';
   tbDelete.Hint    :=
                    'Delete the highlighted Account Code(s)|' +
                    'Delete the highlighted Account Code(s)';
   tbMerge.Hint     :=
                    'Merge Chart of Accounts from another Client File|' +
                    'Merge another Client''s Chart of Accounts into this Chart of Accounts';

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.tbMergeClick(Sender: TObject);
begin
  SearchTerm := '';
  ForceOnlyOneSelected;
  MergeChart;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.MergeChart;
var
  Code          : string;
  FromClient    : TClientObj;
  i             : integer;
  j             : integer;
  nAccount      : pAccount_Rec;
  SourceAccount : pAccount_Rec;
  DestAccount   : pAccount_Rec;
  DivisionsSet  : boolean;
  MergeSubgroups : boolean;
  MergeDivisions : boolean;
begin
 if MergeChartSelectCopyFrom('Merge Chart of Accounts from...', Code, MergeSubgroups, MergeDivisions) then
 begin
   FromClient := nil;
   OpenAClient(Code,FromClient,false);
   try
     if not Assigned(FromClient) then
     begin
       HelpfulWarningMsg('Unable to open client '+code,0);
       exit;
     end;

     //have both clients open, begin copying.. only copy code if it doesnt exist in chart
     for i := 0 to Pred(FromClient.clChart.ItemCount) do
     begin
       SourceAccount := FromClient.clChart.Account_At(i);

       if (SourceAccount.chInactive) or (Trim(SourceAccount.chAccount_Code) = '') then
         continue;

       DestAccount   := MyClient.clChart.FindCode(SourceAccount.chAccount_Code);

       if (DestAccount = nil) then
       begin
         //account doesnt exist so add new one
         UpdateAppStatus('Merging Chart...','Adding '+SourceAccount.chAccount_Description,(i/FromClient.clChart.ItemCount)*100);

         //add the code
         nAccount := New_Account_Rec;
         nAccount.chAccount_Code        := SourceAccount.chAccount_Code;
         nAccount.chAccount_Description := SourceAccount.chAccount_Description;
         nAccount.chPosting_Allowed     := SourceAccount.chPosting_Allowed;
         nAccount.chGST_Class           := SourceAccount.chGST_Class;
         nAccount.chAccount_Type        := SourceAccount.chAccount_Type;
         nAccount.chHide_In_Basic_Chart := SourceAccount.chHide_In_Basic_Chart;
         //add subgroups
         if MergeSubgroups then begin
            nAccount.chSubType             := SourceAccount.chSubType;
         end;
         //add divisions
         if MergeDivisions then begin
            for j := 1 to Max_Divisions do begin
               nAccount.chPrint_in_Division[ j] := SourceAccount.chPrint_in_Division[ j];
            end;
         end;

         //merge links
         nAccount.chLinked_Account_OS   := SourceAccount.chLinked_Account_OS;
         nAccount.chLinked_Account_CS   := SourceAccount.chLinked_Account_CS;

         MyClient.clChart.Insert(nAccount);
       end
       else
       begin
         //account already exists, only copy empty fields  - GST Class / Account Type
         UpdateAppStatus('Merging Chart...','Updating '+SourceAccount.chAccount_Description,(i/FromClient.clChart.ItemCount)*100);

         //overwrite account type if not set or is marked as unknown
         if (DestAccount.chAccount_Type in [ atNone, atUnknownDR, atUnknownCR] )
            and ( SourceAccount.chAccount_Type <> 0)
         then
           DestAccount.chAccount_Type   := SourceAccount.chAccount_Type;

         if (DestAccount.chGST_Class = 0) then
           DestAccount.chGST_Class      := SourceAccount.chGST_Class;

         if MergeSubgroups then begin
            if (DestAccount.chSubType = 0) then
              DestAccount.chSubType   := SourceAccount.chSubType;
         end;

         if MergeDivisions then begin
            DivisionsSet := false;
            for j := 1 to Max_Divisions do begin
               if DestAccount.chPrint_in_Division[ j] then DivisionsSet := true;
            end;
            if not DivisionsSet then
               for j := 1 to Max_Divisions do
                  DestAccount.chPrint_in_Division[ j] := SourceAccount.chPrint_in_Division[ j];
         end;

         // override basic chart setting as it is in the destination
         DestAccount.chHide_In_Basic_Chart := SourceAccount.chHide_In_Basic_Chart;

         //merge links
         DestAccount.chLinked_Account_OS   := SourceAccount.chLinked_Account_OS;
         DestAccount.chLinked_Account_CS   := SourceAccount.chLinked_Account_CS;
       end;
     end;
   finally
     CloseAClient(FromClient);
     FromClient := nil;
     RefreshChartList;
     ClearStatus;
   end;
   ChartChanged := True;
   ApplyGSTRequired := True;
   LockRequired := True;
 end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TfrmMaintainChart.DeleteMultiple: boolean;
var
  i : integer;
  p : pAccount_Rec;
  accName, accCode : string;
begin
  result := false;
  if AskYesNo('Delete Accounts?','You have selected '+inttostr(lvChart.SelCount)+' accounts to DELETE.  Please confirm this is correct.',DLG_NO,0) <> DLG_YES then exit;

  for i := 0 to Pred(lvChart.items.Count) do
    if lvChart.Items[i].Selected then
    begin
      p := pAccount_Rec(lvChart.Items[i].SubItems.Objects[0]);

      accName := p^.chAccount_Description;
      accCode := p^.chAccount_Code;

      MyClient.clChart.DelFreeItem(p);
      Result := true;

      LogUtil.LogMsg(lmInfo,UnitName,'User Deleted Account '+ accName + ' '+accCode);
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.ForceOnlyOneSelected;
var
  FirstSelected : TlistItem;
begin
    if lvChart.SelCount > 1 then
    begin
      FirstSelected := lvChart.Selected;
      lvChart.Selected := nil;
      lvChart.Selected := FirstSelected;
      lvChart.Selected.Focused := true;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainChart.MoveDownOne;
var
  i : integer;
begin
  i := lvChart.Selected.Index;
  Inc(i);

  if i <= Pred(lvChart.Items.Count) then
    SelectListViewItem(lvChart,lvChart.Items[i]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmMaintainChart.tmrKeyPressTimer(Sender: TObject);
//set the division or sub group keyed by user
var
  Num : integer;
begin
  if CurrShiftState = [ ssCtrl] then begin
     Num := StrToIntDef( KeyBuffer, -1);
     if (Num >= 0)
     and (tbEdit.Enabled) then
       SetDivision( Num, true);
    KeyBuffer := '';
    CurrShiftState := [];
  end;
  if CurrShiftState = [ ssAlt] then begin
     Num := StrToIntDef( KeyBuffer, -1);
     if (Num >= 0)
     and (tbEdit.Enabled) then
        SetSubType( Num, True);
    KeyBuffer := '';
    CurrShiftState := [];
  end;

  tmrKeyPress.Enabled := false;
end;

procedure TfrmMaintainChart.lvChartSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  ItemIndex : integer;
begin
  SearchTerm := '';
  if lvChart.SelCount = 1 then
  begin
    for ItemIndex := 0 to lvChart.Items.Count - 1 do
    begin
      if lvChart.Items[ItemIndex].Selected then
      begin
        fFirstSelectedItem := lvChart.Items[ItemIndex];
        break;
      end;
    end;
  end;

  UpdateQuickSetWindow;
end;

procedure TfrmMaintainChart.UpdateQuickSetWindow;
var
  pAcct       : pAccount_Rec;
  pTest       : pAccount_Rec;
  i, j        : integer;
  RG_Same     : boolean;
  SG_Same     : boolean;
  GST_Same    : boolean;
  S           : string;
begin
  if (not pnlQuickSet.Visible) then
    Exit;

  //first first selected item
  i := 0;
  S := '';
  pAcct := nil;

  while ( i < lvChart.Items.Count) and ( pAcct = nil) do
  begin
    if lvChart.Items[ i].Selected then
    begin
      pAcct := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);
      if (Assigned(pAcct)) then
        S := S + pAcct^.chAccount_Code + ',';
    end;
    Inc(i);
  end;

  if Assigned(fFirstSelectedItem) and (lvChart.SelCount > 0) then
  begin
    pAcct := pAccount_Rec(fFirstSelectedItem.SubItems.Objects[0]);
  end;

  LblAltCode.Caption := '';

  if not Assigned( pAcct) then
  begin
    //blank everything
    lblCode.Caption := '';

    lblDesc.Caption := '';
    lblDivisions.Caption := '';
    chkPosting.Checked  := false;
    chkBasic.Checked := false;
    chkInactive.Checked := false;

    cmbReportGroup.ItemIndex := -1;
    cmbSubGroup.ItemIndex    := -1;
    cmbGST.ItemIndex         := -1;

    cmbReportGroup.Enabled   := false;
    cmbSubGroup.Enabled      := false;
    cmbGST.Enabled           := false;
  end
  else
  begin
    if lvChart.SelCount = 1 then
    begin
      lblCode.Caption := pAcct^.chAccount_Code;
      lblDesc.Caption := pAcct^.chAccount_Description;
      lblDesc.Enabled := true;
    end
    else
    begin
      lblCode.Caption := '';
      LblAltCode.Caption := '';
      lblDesc.Caption := 'multiple accounts';
    end;

    //enabled combos
    cmbReportGroup.Enabled   := true;
    cmbSubGroup.Enabled      := true;
    cmbGST.Enabled           := true;

    //report group
    if pAcct^.chAccount_Type in [atMin..atMax] then
      SetComboIndexByIntObject( pAcct^.chAccount_Type, cmbReportGroup)
    else
      cmbReportGroup.ItemIndex := 0;

    //sub group
    if pAcct^.chSubtype in [0..Max_SubGroups] then
      SetComboIndexByIntObject( pAcct^.chSubType, cmbSubGroup)
    else
      cmbSubGroup.ItemIndex := 0;

    //gst class
    if pAcct^.chGST_Class in [0..Max_GST_Class] then
      SetComboIndexByIntObject( pAcct^.chGST_Class, cmbGST)
    else
      cmbGST.ItemIndex := 0;

    //division
    S := '';
    for i := 1 to Max_Divisions do
    begin
      if pAcct.chPrint_in_Division[i] then
      begin
        if (S = '') then
          S := S + inttostr(i)
        else
          S := S + ', ' + inttostr(i);
      end;
    end;
    lblDivisions.Caption := S;

    //posting
    chkPosting.checked := pAcct^.chPosting_Allowed;
    if chkPosting.checked then
      chkPosting.caption := 'Yes'
    else
      chkPosting.caption := 'No';

    // Basic
    chkBasic.checked := not pAcct^.chHide_In_Basic_Chart;
    if chkBasic.checked then
      chkBasic.caption := 'Yes'
    else
      chkBasic.caption := 'No';

    // Inactive
    chkInactive.Checked := pAcct.chInactive;
    if chkInactive.Checked then
      chkInactive.Caption := 'Yes'
    else
      chkInactive.Caption := 'No';

    //see if items are all the same
    RG_Same := true;
    SG_Same := true;
    GST_Same := true;

    //no point in checking more selected items if we don't have to.
    j := lvChart.SelCount;
    i := 0;
    while (j > 0) and (i < lvChart.Items.Count) do
    begin
      if lvChart.Items[i].Selected then
      begin
        pTest := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);
        if Assigned( pTest) then
        begin
           RG_Same   := RG_Same and ( pTest.chAccount_Type  = pAcct.chAccount_Type);
           SG_Same   := SG_Same and ( pTest.chSubtype       = pAcct.chSubtype);
           GST_Same  := GST_Same and ( pTest.chGST_Class    = pAcct.chGST_Class);
           if LblAltCode.Caption = '' then
              LblAltCode.Caption := PTest.chAlternative_Code
           else
              if LblAltCode.Caption <> PTest.chAlternative_Code then
                 LblAltCode.Caption := 'Multiple';

        end;
        Dec(j);
      end;
      Inc(i);
    end;

    if RG_Same then
      cmbReportGroup.Font.Color  := clWindowText
    else
      cmbReportGroup.Font.Color  := clGrayText;

    if SG_Same then
      cmbSubGroup.Font.Color     := clWindowText
    else
      cmbSubGroup.Font.Color     := clGrayText;

    if GST_Same then
      cmbGST.Font.Color          := clWindowText
    else
      cmbGST.Font.Color          := clGrayText;

    //set hints
    lblCode.Hint := lblCode.Caption;
    lblDesc.Hint := lblDesc.Caption;
  end;
end;

procedure TfrmMaintainChart.LoadCombos;
const
  ReportGroupsToExclude = [ atRetainedPorL, atCurrentYearsEarnings, atUncodedCR, atUncodedDR ];
var
  i     : Integer;
  ReportGroup : byte;
  Desc  : String;
  NewWidth : Integer;
begin
  //report group
  cmbReportGroup.Items.Clear;
  cmbReportGroupWidth := cmbSubGroup.Width;

  for i := atMin to atMax do begin
     ReportGroup := ReportGroupsDisplayOrder[ i];
     if not( ReportGroup in ReportGroupsToExclude) then
     begin
       cmbReportGroup.Items.AddObject( Localise( MyClient.clFields.clCountry, atNames[ ReportGroup]),
                                       TObject( ReportGroup));
       NewWidth := cmbReportGroup.Canvas.TextWidth(cmbReportGroup.Items[cmbReportGroup.Items.Count-1]) +
                   (GetSystemMetrics(SM_CXVSCROLL) + 8);
       if (NewWidth > cmbReportGroupWidth) then
         cmbReportGroupWidth := NewWidth;
     end;
  end;
  cmbReportGroup.ItemIndex := 0;

  //sub group
  cmbSubGroup.Items.Clear;
  Desc := MyClient.clCustom_Headings_List.Get_SubGroup_Heading( 0);
  If Desc = '' then
     cmbSubGroup.Items.AddObject( 'Unallocated', TObject( 0))
  else
     cmbSubGroup.Items.AddObject( Desc, TObject( 0) );

  cmbSubGroupWidth := cmbSubGroup.Width;

  for i := 1 to Max_SubGroups do begin
     Desc := Format( '%d - %s', [ i, MyClient.clCustom_Headings_List.Get_SubGroup_Heading( i)]);
     cmbSubGroup.Items.AddObject( Desc, TObject( i));
     NewWidth := cmbSubGroup.Canvas.TextWidth(cmbSubGroup.Items[cmbSubGroup.Items.Count-1]) +
                 (GetSystemMetrics(SM_CXVSCROLL) + 8);
     if (NewWidth > cmbSubGroupWidth) then
       cmbSubGroupWidth := NewWidth;
  end;
  cmbSubGroup.ItemIndex := 0;

  //Load GST Types combo,  only load items that have a id and a description
  //Store the actual gst type in the object value of the item.
  //load 'not assigned' as the first item so it can be selected
  cmbGST.Items.Clear;
  cmbGST.Items.add('N/A');

  cmbGSTWidth := cmbGST.Width;

  with MyClient.clFields do begin
     for i := 1 to MAX_GST_CLASS do begin
        if ( clGST_Class_Names[i] <> '') and ( clGST_Class_Codes[i] <> '') then
        begin
          cmbGST.Items.AddObject( clGST_Class_Codes[i]+'  '+clGST_Class_Names[i], TObject( i));
          NewWidth := cmbGST.Canvas.TextWidth(cmbGst.Items[cmbGst.Items.Count-1]) +
                      (GetSystemMetrics(SM_CXVSCROLL) + 8);
          if (NewWidth > cmbGSTWidth) then
            cmbGSTWidth := NewWidth;
        end;
     end;
  end;
  cmbGST.ItemIndex := 0;

  //division - too hard at the moment
end;

procedure TfrmMaintainChart.cmbGSTChange(Sender: TObject);
var
  Setting : integer;
begin
  Setting := GetComboCurrentIntObject( cmbGST);
  if Setting >= 0 then
    SetGSTClass( Setting, false);

  cmbGST.Font.Color  := clWindowText;
end;

procedure TfrmMaintainChart.cmbReportGroupChange(Sender: TObject);
var
  Setting : integer;
begin
  Setting := GetComboCurrentIntObject( cmbReportGroup);
  if Setting >= 0 then
    SetType( Setting, false);

  cmbReportGroup.Font.Color  := clWindowText;
end;

procedure TfrmMaintainChart.cmbSubGroupChange(Sender: TObject);
var
  Setting : integer;
begin
  Setting := GetComboCurrentIntObject( cmbSubGroup);
  if Setting >= 0 then
    SetSubType( Setting, false);

  cmbSubGroup.Font.Color  := clWindowText;
end;

procedure TfrmMaintainChart.btnHideQuickSetClick(Sender: TObject);
begin
  pnlQuickSet.Visible := false;
end;

procedure TfrmMaintainChart.tbQuickSetClick(Sender: TObject);
begin
  pnlQuickSet.Visible := not pnlQuickSet.Visible;

  if pnlQuickSet.Visible then begin
    tbQuickSet.Caption := 'Hide &Quick Set';
    UpdateQuickSetWindow;
  end
  else
    tbQuickSet.Caption := 'Show &Quick Set';
end;

procedure TfrmMaintainChart.DoResort( ColToSortOn: integer);
var
  i: integer;
begin
  lvChart.CustomSort( ColSort, ColToSortOn );
  CurrSortCol := ColToSortOn;
  // Place Sort Indicator in Column
   with lvChart do begin
      for i := 0 to Pred( Columns.Count ) do begin
         if ( i = ColToSortOn ) then begin
            Columns[i].ImageIndex := MAINTAIN_COLSORT_BMP;  //Triangle
         end
         else begin
            Columns[i].ImageIndex := -1; //Blank
         end;
      end;
   end;
end;

procedure TfrmMaintainChart.cmbReportGroupDropDown(Sender: TObject);
begin
  //try to set default drop down width
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbReportGroupWidth, 0);
end;

procedure TfrmMaintainChart.cmbSubGroupDropDown(Sender: TObject);
begin
  //try to set default drop down width
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbSubGroupWidth, 0);
end;

// If the alternative code column has been removed, references to columns which are
// to the right of that column need to be adjusted
function TfrmMaintainChart.CorrectedColNum(ColNum: integer): integer;
begin
  if (ColNum > c_AltCode) then
    Result := ColNum - AltCodeModifier
  else
    Result := ColNum;
end;

procedure TfrmMaintainChart.cmbGSTDropDown(Sender: TObject);
begin
  //try to set default drop down width
  SendMessage(TComboBox(Sender).Handle, CB_SETDROPPEDWIDTH, cmbGSTWidth, 0);
end;

procedure TfrmMaintainChart.tbHelpClick(Sender: TObject);
begin
  BKHelpShowContext( tbHelp.HelpContext);
end;

procedure TfrmMaintainChart.tbInactiveClick(Sender: TObject);
begin
  fShowInactive := not fShowInactive;

  UpdateInactiveColumn;
  RefreshChartList;
end;

procedure TfrmMaintainChart.UpdateInactiveColumn;
var
  iColumn: integer;
begin
  iColumn := CorrectedColNum(c_Inactive);

  // Show inactive column?
  if fShowInactive then
  begin
    tbInactive.Caption := 'Hide &Inactive';

    lvChart.Columns[iColumn].Width := w_Inactive;
  end
  else
  begin
    tbInactive.Caption := 'Show &Inactive';

    lvChart.Columns[iColumn].Width := 0;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// #1823 - allow posting to be set using quickset
procedure TfrmMaintainChart.SetPosting(isPosting: Boolean; MoveAfter: Boolean = True);
//sets the posting type
var
  p : pAccount_Rec;
  i : integer;
begin
  //cycle through selected items
  for i := 0 to Pred( lvChart.Items.Count) do begin
     if lvChart.Items[ i].Selected then begin
        p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);

        if isPosting <> p.chPosting_Allowed then begin
           p.chPosting_Allowed := isPosting;
           RefreshItem(p,lvChart.Items[ i]);
           lvChart.UpdateItems( i,i );
        end;
     end;
  end;

  if (lvChart.SelCount = 1) and  MoveAfter then
     MoveDownOne;

  UpdateQuickSetWindow;
end;

procedure TfrmMaintainChart.SetBasic(HideInBasic: Boolean; MoveAfter: Boolean = True);
//sets the basic chart
var
  p : pAccount_Rec;
  i : integer;
begin
  //cycle through selected items
  for i := 0 to Pred( lvChart.Items.Count) do begin
     if lvChart.Items[ i].Selected then begin
        p := pAccount_Rec(lvChart.Items[ i].SubItems.Objects[0]);

        if HideInBasic <> p.chHide_In_Basic_Chart then begin
           p.chHide_In_Basic_Chart := HideInBasic;
           RefreshItem(p,lvChart.Items[ i]);
           lvChart.UpdateItems( i,i );
        end;
     end;
  end;

  if (lvChart.SelCount = 1) and  MoveAfter then
     MoveDownOne;

  UpdateQuickSetWindow;
end;

procedure TfrmMaintainChart.SetInactive(const aInactive: boolean;
  const aMoveAfter: boolean);
var
  p : pAccount_Rec;
  i : integer;
  Accounts : array of string;
  iCount: integer;
begin
  //cycle through selected items
  for i := 0 to Pred(lvChart.Items.Count) do
  begin
    if lvChart.Items[i].Selected then
    begin
      p := pAccount_Rec(lvChart.Items[i].SubItems.Objects[0]);

      if (aInactive <> p.chInactive) then
      begin
        p.chInactive := aInactive;
        RefreshItem(p, lvChart.Items[i]);
        lvChart.UpdateItems(i, i);

        if aInactive then
        begin
          iCount := Length(Accounts);
          SetLength(Accounts, iCount+1);
          Accounts[iCount] := p.chAccount_Code;
        end;
      end;
    end;
  end;

  // Display warnings
  DisplayMemorisationPayee_AccountUsed(Accounts);

  if (lvChart.SelCount = 1) and aMoveAfter then
    MoveDownOne;

  UpdateQuickSetWindow;
end;

procedure TfrmMaintainChart.chkPostingClick(Sender: TObject);
begin
  SetPosting(chkPosting.Checked, false);
end;

procedure TfrmMaintainChart.FormShow(Sender: TObject);
begin
  Width := Width - 1;
  Refresh
end;

procedure TfrmMaintainChart.chkBasicClick(Sender: TObject);
begin
  SetBasic(not chkBasic.Checked, False);
end;

procedure TfrmMaintainChart.chkInactiveClick(Sender: TObject);
begin
  SetInactive(chkInactive.Checked, false);
end;

end.

