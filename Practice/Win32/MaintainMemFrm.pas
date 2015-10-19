unit MaintainMemFrm;

//------------------------------------------------------------------------------
interface                                                         

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ImgList, ComCtrls, ToolWin, ExtCtrls, baObj32, bkdefs, balist32, StdCtrls,
  bkConst, MemorisationsObj,
  OSFont, RzButton;

type
  TMasterMemInfoRec = record
    AuditID: integer;
    SequenceNumber: integer;
  end;

  TfrmMaintainMem = class(TForm)
    Splitter1: TSplitter;
    ToolBar1: TToolBar;
    tbDelete: TToolButton;
    ToolButton5: TToolButton;
    tbClose: TToolButton;
    Panel1: TPanel;
    lvMemorised: TListView;
    tbMoveUp: TToolButton;
    tbMoveDown: TToolButton;
    tbEdit: TToolButton;
    ToolButton1: TToolButton;
    tbCopyTo: TToolButton;
    tbHelpSep: TToolButton;
    tbHelp: TToolButton;
    Panel2: TPanel;
    trvAccountView: TTreeView;
    pnlSearch: TPanel;
    Label1: TLabel;
    tbtnClose: TRzToolButton;
    EBFind: TEdit;
    btnFind: TButton;
    SearchTimer: TTimer;
    tbFind: TToolButton;
    ToolButton3: TToolButton;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Panel3: TPanel;
    stTitle: TStaticText;
    Shape6: TShape;
    Shape5: TShape;
    procedure tbEditClick(Sender: TObject);
    procedure tbDeleteClick(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure lvMemorisedDblClick(Sender: TObject);
    procedure trvAccountViewChange(Sender: TObject; Node: TTreeNode);
    procedure tbCloseClick(Sender: TObject);
    procedure lvMemorisedCompare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure lvMemorisedColumnClick(Sender: TObject; Column: TListColumn);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure tbMoveUpClick(Sender: TObject);
    procedure tbMoveDownClick(Sender: TObject);
    procedure lvMemorisedSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure tbCopyToClick(Sender: TObject);
    procedure tbHelpClick(Sender: TObject);
    procedure tbtnCloseClick(Sender: TObject);
    procedure EBFindChange(Sender: TObject);
    procedure EBFindKeyPress(Sender: TObject; var Key: Char);
    procedure btnFindClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SearchTimerTimer(Sender: TObject);
    procedure tbFindClick(Sender: TObject);
    procedure stTitleClick(Sender: TObject);
  private
    { Private declarations }
    BankAccountCount      : integer;
    SortCol               : integer;
    MastersOnly           : boolean;
    WorkingOnMasterPrefix : BankPrefixStr;
    FMemorisationChanged  : boolean;  //needed so that CES reloads edited transactions
    BA: TBank_Account;

    FSearchText: string;
    procedure SetSearchText(const Value: string);

    function TestText(const Value: string; aSearchText : string): Boolean;
    function FindTextInItem(aItem : TListItem; aSearchText : string) : Boolean;
    procedure Refresh();

    procedure LoadAccounts;
    function LoadMemorisations(Bank_Account : TBank_Account): integer;
    procedure LoadMasters( BankPrefix : ShortString);
    function  DeleteMemorised(MemorisedList : TMemorisations_List;
      Mem : TMemorisation; Multiple : Boolean; Prefix: string = ''; ShowPrompt: boolean = true) : boolean;
    procedure MoveItem(MoveItemUp : boolean);
    procedure EditSelectedMemorisation;
    procedure SetSearchVisible(const Value: Boolean);
    function GetSearchVisible: Boolean;
  public
    { Public declarations }
    property MemorisationChanged : boolean read FMemorisationChanged;
    function Execute : boolean;
    property SearchText: string read FSearchText write SetSearchText;
    property SearchVisible: Boolean read GetSearchVisible write SetSearchVisible;
  end;

function MaintainMemorised : boolean;
function MaintainMasters   : boolean;

//******************************************************************************
implementation

uses
  Software,
  MoneyUtils,
  bkdateutils,
  BKHelp,
  bkXPThemes,
  GenUtils,
  glConst,
  globals,
  LogUtil,
  LvUtils,
  StStrS,
  BKMLIO,
  CopyMemorisationsDlg,
  imagesfrm,
  InfoMoreFrm,
  mxFiles32,
  admin32,
  BaUtils,
  ErrorMoreFrm,
  MemoriseDlg,
  Math,
  yesnodlg, clObj32, ECollect, AppUserObj, MoneyDef, WinUtils,
  AuditMgr,
  SYDEFS,
  memutils,
  SystemMemorisationList, MAINFRM;


{$R *.DFM}

const
  colCodedTo     = 0;
  colEntryType   = 1;
  colReference   = 2;
  colAnalysis    = 3;
  colStatementDetails = 4;
  colParticulars = 5;
  colOtherParty = 6;
  colValue = 7;
  colNotes = 8;
  colLastApplied = 9;
  colAppliesFrom = 10;
  colAppliesTo = 11;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  CriteriaStr(S : string; b : boolean) : string;
begin
   if b then result := s else result := '';
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function ValueCriteriaStr( V : Money; MatchType : byte; CurrencyCode: string) : string;
var
  S : string;
begin
  S := '';
  if MatchType <> mxNo then
    begin
      if V < 0 then
      begin
        //we need to reverse the match on amount type for -ve entries because
        //we display all values as positive amounts
        case MatchType of
          mxAmtGreaterThan    : MatchType := mxAmtLessThan;
          mxAmtGreaterOrEqual : MatchType := mxAmtLessOrEqual;
          mxAmtLessThan       : MatchType := mxAmtGreaterThan;
          mxAmtLessOrEqual    : MatchType := mxAmtGreaterOrEqual;
        end;
      end;

      S := BKCONST.mxSymbols[ MatchType] + ' ' +  MoneyUtils.DrCrStr(V,CurrencyCode);
    end;

  result := S;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TfrmMaintainMem.FormCreate(Sender: TObject);
var
   Country : Byte;
   i       : integer;
begin
  bkXPThemes.ThemeForm( Self);
  StTitle.Font.Name := Font.name;
  width := Min( 1024, Round(Screen.WorkAreawidth * 0.95));
  height := Max( 440, Round( Screen.WorkAreaHeight * 0.7));

  // Determine client's country
  if Assigned( MyClient ) then
     Country := MyClient.clFields.clCountry
  else
     Country := AdminSystem.fdFields.fdCountry;

  // Adjust columns depending on the country
  // Note: this needs to be here in addition to LoadMemorisations so that
  // System.Memorisations also works.
  case Country of
     whNewZealand :
       // Note: Columns for New Zealand are also changed in LoadMemorisations,
       // but some of these are at the bank account level, so leave "as is" for
       // now.
       ;
     whAustralia, whUK  :
        Begin
           lvMemorised.columns[colAnalysis].Caption  := 'Bank Type';  //NZ Analysis Col
           lvMemorised.Columns[colParticulars].MaxWidth := 1;  //Particulars Col
           lvMemorised.columns[colParticulars].width    := 0;
           lvMemorised.columns[colParticulars].Caption  := '';
           lvMemorised.Columns[colOtherParty].MaxWidth := 1;  //Other Party Col
           lvMemorised.columns[colOtherParty].width    := 0;
           lvMemorised.columns[colOtherParty].Caption  := '';
        end;
  end;

  WorkingOnMasterPrefix := '';
  FMemorisationChanged  := false;
  SortCol               := 1;
  lvMemorisedColumnClick( Self, lvMemorised.Column[1] );
  SetUpHelp;

  //only enable the Copy To button if there are more than 1 bank account
  BankAccountCount := 0;
  if Assigned( MyClient) then
  begin
    for i := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
    begin
      if MyClient.clBank_Account_List.Bank_Account_At(i).baFields.baAccount_Type = btBank then
        Inc( BankAccountCount);
    end;
  end;

  tbEdit.Enabled     := False;
  tbDelete.Enabled   := False;
  tbMoveUp.Enabled   := False;
  tbMoveDown.Enabled := False;
  tbCopyTo.Enabled   := False;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.SearchTimerTimer(Sender: TObject);
begin
  SearchTimer.Enabled := False;
  SearchText := EBFind.Text;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.SetSearchText(const Value: string);
begin
  btnFind.Enabled := Value > '';
  if not SameText (FSearchText, Value) then
  begin
    FSearchText := uppercase(Value);
    Refresh();
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.SetSearchVisible(const Value: Boolean);
begin
  pnlSearch.Visible := Value;

  UserINI_MEM_Show_Find := Value;

  if (Value) and (EBFind.Visible) then
    EBFind.SetFocus
  else if lvMemorised.Visible then
    lvMemorised.SetFocus;

  tbFind.Down := Value;

  if not Value then
  begin
    EBFind.Text := '';
    SearchTimerTimer(nil);
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   tbHelp.Visible := bkHelp.BKHelpFileExists;
   tbHelpSep.Visible := tbHelp.Visible;

   //Components
   tbMoveUp.Hint    :=
                    'Increase the priority of the selected Memorisation|' +
                    'This affects the order in which memorisations with the same entry type are applied to data';
   tbMoveDown.Hint  :=
                    'Decrease the priority of the selected Memorisation|' +
                    'This affects the order in which memorisations with the same entry type are applied to data';
   tbDelete.Hint    :=
                    'Delete the selected Memorisation|' +
                    'Delete the selected Memorisation';
end;

procedure TfrmMaintainMem.stTitleClick(Sender: TObject);
begin

end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.LoadAccounts;
var
  i           : integer;
  NewNode1    : TTreeNode;
  NewNode2    : TTreeNode;
  FirstAcc    : TTreeNode;
  b           : tBank_Account;
  HideMasters : boolean;

  PrefixList       : TStringList;
  Prefix           : String;
  MasterMemFound   : Boolean;
//  FileSearchMask   : string;
//  CountryPrefix    : string2;
//  FilePrefixLength : integer;
//  SearchRec        : TSearchRec;
//  Found            : Integer;
  
  SystemMemorisation: pSystem_Memorisation_List_Rec;

  function AccountState  (Ba : tBank_Account ): Integer;
  var
    I,J     : Integer;
    IsActive: boolean;
  begin
     IsActive := True;
     Result := STATES_ALERT;
     for I := Ba.baMemorisations_List.First to ba.baMemorisations_List.Last do
     begin
       with ba.baMemorisations_List.Memorisation_At(I) do
       begin
          for J := mdLines.First to mdLines.Last do
          begin
             with mdLines.MemorisationLine_At(J)^ do
             begin
                if mlAccount <> '' then
                begin
                   if not MyClient.clChart.CanCodeto(mlaccount, IsActive, HasAlternativeChartCode (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used)) then
                     exit;
                   if not IsActive then
                     exit;
                end;
             end;
          end;
       end;
     end;
     // Still Here...
     Result := 0;
  end;


begin
   FirstAcc       := nil;
   HideMasters    := false;
   MasterMemFound := false;

   with trvAccountView.Items do
   begin
       clear;

       //load client bank accounts
       if (not MastersOnly) and Assigned(myClient) then begin
         NewNode1 := trvAccountView.Items.Add(nil,'Memorisations');
         NewNode1.ImageIndex    := MAINTAIN_MEMORISE_BMP;
         NewNode1.SelectedIndex := MAINTAIN_MEMORISE_BMP;
         NewNode1.OverlayIndex := 0;
         NewNode1.SelectedIndex := -1;
         with MyClient.clBank_Account_List do
            for i := 0 to Pred(itemCount) do
            begin
              b := Bank_Account_At(i);

              if not (b.isAJournalAccount) then
              begin
                NewNode2 := AddChildObject(NewNode1, b.Title,b);
                NewNode2.ImageIndex    := MAINTAIN_FOLDER_CLOSED_BMP;
                NewNode2.SelectedIndex := MAINTAIN_FOLDER_OPEN_BMP;
                NewNode2.OverlayIndex := 0;
                NewNode2.StateIndex := AccountState(b);
                if FirstAcc = nil then FirstAcc := NewNode2;
              end;
            end;

         //Dont show the Master Memorisations if the are irrelevant to this client
         if Assigned( AdminSystem) then begin
            HideMasters := (MyClient.clFields.clMagic_Number <> AdminSystem.fdFields.fdMagic_Number)
                           or (MyClient.clFields.clDownload_From <> dlAdminSystem);
         end;
       end;

       //load MASTER memorisations
{       if Assigned( AdminSystem) and (not HideMasters )then begin
         NewNode1 := trvAccountView.Items.Add(nil,'MASTER Memorisations');
         NewNode1.ImageIndex    := MAINTAIN_MASTER_MEM_PAGE_BMP;
         NewNode1.SelectedIndex := MAINTAIN_MASTER_MEM_PAGE_BMP;

         //need to read memorisation files from disk if there is no open client
         if MastersOnly or ( not Assigned( MyClient)) then begin
            CountryPrefix  := whShortNames[ AdminSystem.fdFields.fdCountry ];
            FileSearchMask := mmxPrefix + CountryPrefix + '*' + mmxExtn;
            FilePrefixLength := Length( mmxPrefix) + Length( CountryPrefix);

            Found := FindFirst(DATADIR + FileSearchMask, faAnyFile, SearchRec);
            try
               while Found = 0 do begin
                  //note:  searching for *.mxl will also return *.mxlold - Windows??!!@
                  if lowercase( ExtractFileExt( SearchRec.Name)) = lowercase(mmxExtn) then
                  begin
                    Prefix := Copy( SearchRec.Name, FilePrefixLength + 1,
                                    Pos( '.', SearchRec.Name) - FilePrefixLength -1 );
                    MasterMemFound := true;
                    NewNode2       := AddChild( NewNode1, Prefix);
                    NewNode2.ImageIndex    := MAINTAIN_FOLDER_CLOSED_BMP;
                    NewNode2.SelectedIndex := MAINTAIN_FOLDER_OPEN_BMP;
                    NewNode2.OverlayIndex := 1;
                    NewNode2.StateIndex   := 0;
                    //NewNode2.StateIndex    := 1;
                    if FirstAcc = nil then FirstAcc := NewNode2;
                  end;
                  Found := FindNext(SearchRec);
               end;
            finally
               FindClose(SearchRec);
            end;
         end
         else begin
            //only show master memorisations that are relevant for this client
            //load master memorisations for accounts, load prefix as caption
            //first build a list of unique prefixs
            PrefixList := TStringList.Create;
            try
               with MyClient.clBank_Account_List do begin
                  for i := 0 to Pred(itemCount) do begin
                    b := Bank_Account_At(i);
                    if not (b.isAJournalAccount) then begin
                       Prefix := mxFiles32.GetBankPrefix( b.baFields.baBank_Account_Number);
                       if PrefixList.IndexOf( Prefix) = - 1 then
                          PrefixList.Add( Prefix);
                    end;
                  end;
               end;

               for i := 0 to Pred( PrefixList.Count) do begin
                  //now see if master mems exists for each prefix
                 if BKFileExists( MasterFileName( PrefixList[ i])) then begin
                    MasterMemFound := true;
                    NewNode2 := AddChild( NewNode1, PrefixList[ i]);
                    NewNode2.ImageIndex    := MAINTAIN_FOLDER_CLOSED_BMP;
                    NewNode2.SelectedIndex := MAINTAIN_FOLDER_OPEN_BMP;
                    NewNode2.OverlayIndex := 1;
                    NewNode2.StateIndex := 0;
                    //NewNode2.StateIndex    := 1;
                    if FirstAcc = nil then FirstAcc := NewNode2;
                 end;
               end;
            finally
               PrefixList.Free;
            end;
         end;

         //see if any found, if not there removed parent node
         if not MasterMemFound then
            trvAccountView.Items.Delete( NewNode1);
       end;    }


       //load MASTER memorisations
       if Assigned(AdminSystem) and (not HideMasters) then begin
         NewNode1 := trvAccountView.Items.Add(nil,'MASTER Memorisations');
         NewNode1.ImageIndex    := MAINTAIN_MASTER_MEM_PAGE_BMP;
         NewNode1.SelectedIndex := MAINTAIN_MASTER_MEM_PAGE_BMP;
         //Load all system memorisations if there is no open client
         if MastersOnly or ( not Assigned( MyClient)) then begin
           for i := AdminSystem.SystemMemorisationList.First to AdminSystem.SystemMemorisationList.Last do begin
             Prefix := AdminSystem.SystemMemorisationList.System_Memorisation_At(i).smBank_Prefix;
             MasterMemFound := true;
             NewNode2       := AddChild( NewNode1, Prefix);
             NewNode2.ImageIndex    := MAINTAIN_FOLDER_CLOSED_BMP;
             NewNode2.SelectedIndex := MAINTAIN_FOLDER_OPEN_BMP;
             NewNode2.OverlayIndex := 1;
             NewNode2.StateIndex   := 0;
             if FirstAcc = nil then 
               FirstAcc := NewNode2;
           end;
         end
         else begin
           //only show system memorisations that are relevant for this client
           //load system memorisations for accounts, load prefix as caption
           PrefixList := TStringList.Create;
           try
             //first build a list of unique prefixs
             with MyClient.clBank_Account_List do begin
               for i := 0 to Pred(itemCount) do begin
                 b := Bank_Account_At(i);
                 if not (b.isAJournalAccount) then begin
                   Prefix := mxFiles32.GetBankPrefix( b.baFields.baBank_Account_Number);
                   if PrefixList.IndexOf( Prefix) = - 1 then
                     PrefixList.Add( Prefix);
                 end;
               end;
             end;

             for i := 0 to Pred(PrefixList.Count) do begin
               SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(PrefixList[i]);
               if Assigned(SystemMemorisation) then begin
                 MasterMemFound := true;
                 NewNode2 := AddChild( NewNode1, PrefixList[ i]);
                 NewNode2.ImageIndex    := MAINTAIN_FOLDER_CLOSED_BMP;
                 NewNode2.SelectedIndex := MAINTAIN_FOLDER_OPEN_BMP;
                 NewNode2.OverlayIndex := 1;
                 NewNode2.StateIndex := 0;
                 if FirstAcc = nil then 
                   FirstAcc := NewNode2;
               end;
             end;
           finally
             PrefixList.Free;
           end;
         end;

         //see if any found, if not there removed parent node
         if not MasterMemFound then
            trvAccountView.Items.Delete( NewNode1);
       end;

       //now select first account in list
       trvAccountView.Selected := FirstAcc;
   end;
end;

//------------------------------------------------------------------------------

function TfrmMaintainMem.LoadMemorisations(Bank_Account: TBank_Account): Integer;
var
   i,j            : integer;
   m              : TMemorisation;
   newItem        : TListItem;
   CodedTo        : string;
   EntryType      : string;
   Rev            : boolean;
   Invalid        : boolean;
   Country        : Byte;
   MemLine        : pMemorisation_Line_Rec;
   IsActive       : boolean;
   LineIsInvalid  : boolean;
begin
   IsActive := True;
   //check if we were working on a MASTER file and if we need to save it.
   Result := 0;
//   CheckMasterSaveNeeded;
   WorkingOnMasterPrefix := '';
   BA := Bank_Account;
   //update client memorisations
   lvMemorised.Items.BeginUpdate;
   try
     lvMemorised.items.Clear;

     if ( not Assigned( myClient ) ) or MastersOnly then exit;

     if Assigned( MyClient ) then
        Country := MyClient.clFields.clCountry
     else
        Country := AdminSystem.fdFields.fdCountry;

     Rev := False;

     case Country of
        whNewZealand :
           Begin
              Rev := ReverseFields( Bank_Account.baFields.baBank_Account_Number );
              if Rev then
              begin
                 lvMemorised.columns[colParticulars].caption := 'Particulars';
                 lvMemorised.columns[colOtherParty].caption := 'Other Party';
              end
              else
              begin
                 lvMemorised.columns[colParticulars].caption := 'Other Party';
                 lvMemorised.columns[colOtherParty].caption := 'Particulars';
              end;
           end;
        whAustralia, whUK  :
           Begin
              lvMemorised.columns[colAnalysis].Caption  := 'Bank Type';  //NZ Analysis Col
              lvMemorised.Columns[colParticulars].MaxWidth := 1;  //Particulars Col
              lvMemorised.columns[colParticulars].width    := 0;
              lvMemorised.columns[colParticulars].Caption  := '';
              lvMemorised.Columns[colOtherParty].MaxWidth := 1;  //Other Party Col
              lvMemorised.columns[colOtherParty].width    := 0;
              lvMemorised.columns[colOtherParty].Caption  := '';
           end;
     end;

     //add client memorisations

     for i := Bank_Account.baMemorisations_List.Last downto Bank_Account.baMemorisations_List.First do
     begin
       m := Bank_Account.baMemorisations_List.Memorisation_At(i);
       CodedTo := '';
       Invalid := False;
       for j := m.mdLines.First to m.mdLines.Last do
       begin
         MemLine := m.mdLines.MemorisationLine_At(j);
         if MemLine^.mlAccount <> '' then begin
            CodedTo := CodedTo + MemLine^.mlaccount+ ' ';
            LineIsInvalid := False;
            if not MyClient.clChart.CanCodeTo(MemLine^.mlaccount, IsActive, HasAlternativeChartCode (MyClient.clFields.clCountry,MyClient.clFields.clAccounting_System_Used) ) then
              LineIsInvalid := True
            else if (m.mdFields.mdUntil_Date = 0) and not IsActive then
              LineIsInvalid := True;
            if LineIsInvalid then
            begin
              Invalid := True;
              Result := STATES_ALERT;
            end;
         end;
       end;

       if CodedTo <> '' then begin
          newItem := lvMemorised.items.Add;
          newItem.Caption := CodedTo;

          if m.mdFields.mdFrom_Master_List then
             newItem.ImageIndex := MAINTAIN_MASTER_MEM_PAGE_BMP
          else
             newItem.ImageIndex := MAINTAIN_PAGE_NORMAL_BMP;

          if Invalid then
             newItem.StateIndex := STATES_ALERT
          else
             newItem.StateIndex := -1;

          EntryType := IntToStr(m.mdFields.mdType);
          EntryType := Copy('  ', 1, 2 - Length(EntryType)) + EntryType +
                      ':' + MyClient.clFields.clShort_Name[m.mdFields.mdType];

          if m.mdFields.mdFrom_Master_List then
            EntryType := 'M '+EntryType;

          with NewItem.SubItems do begin
             AddObject(EntryType,TObject(m));
            Add(CriteriaStr(m.mdFields.mdReference, m.mdFields.mdMatch_on_Refce));

            case Country of
              whNewZealand : begin
                    Add(CriteriaStr(m.mdFields.mdAnalysis,m.mdFields.mdMatch_on_Analysis));
                    Add(CriteriaStr(m.mdFields.mdStatement_Details, m.mdFields.mdMatch_On_Statement_Details));
                    if Rev then
                    begin
                       Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                       Add(CriteriaStr(m.mdFields.mdOther_Party,m.mdFields.mdMatch_on_Other_Party));
                    end
                    else
                    begin
                       Add(CriteriaStr(m.mdFields.mdOther_Party,m.mdFields.mdMatch_on_Other_Party));
                       Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                    end;
                 end;
              whAustralia, whUK  :
                 Begin
                    Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                    Add(CriteriaStr(m.mdFields.mdStatement_Details,m.mdFields.mdMatch_On_Statement_Details));
                    Add('');  //blank for particulars
                    Add('');  //blank for other party
                 end;
            end;

            Add( ValueCriteriaStr( m.mdFields.mdAmount, m.mdFields.mdMatch_On_Amount,Bank_Account.baFields.baCurrency_Code ));
            Add( CriteriaStr( m.mdFields.mdNotes, m.mdFields.mdMatch_on_Notes));

            AddObject(bkDate2Str( m.mdFields.mdDate_Last_Applied),tobject(m.mdFields.mdDate_Last_Applied));
            AddObject(bkDate2Str( m.mdFields.mdFrom_Date),tobject(m.mdFields.mdFrom_Date));
            AddObject(bkDate2Str( m.mdFields.mduntil_Date),tobject(m.mdFields.mduntil_Date))
          end;

          if length(fSearchText) > 0 then
            if not FindTextinItem(NewItem, fSearchText) then
              lvMemorised.items.Delete(lvMemorised.items.Count-1);
       end;
     end;
   finally
     lvMemorised.items.EndUpdate;
   end;

   //auto size columns
   //LVUTILS.SetListViewColWidth( lvMemorised, 0);

   if lvMemorised.Items.count > 0 then
   begin
//     lvMemorised.SetFocus;
     SelectListViewItem(lvMemorised,lvMemorised.Items[0]);
   end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbEditClick(Sender: TObject);
var
  pM: TMemorisation;
  MemorisedList : TMemorisations_List;
  Accsel        : TTreeNode;
  I, MasterMemToDelete: Integer;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  Prefix: string;
  SystemMem: TMemorisation;
  DeleteSelectedMem: boolean;
  Sequence_No : integer;
begin
  if(lvMemorised.Selected = nil) then
     Exit; // nothing selected

  Accsel := trvAccountView.Selected;
  if not Assigned(AccSel) then
     Exit; // Don't know what it is..

  //get the memorised transaction list, will need this later when reloading the list view
  MemorisedList := nil;
  case AccSel.OverlayIndex of
    0 : MemorisedList := tBank_Account(AccSel.Data).baMemorisations_List;
//    1 : MemorisedList := Master_Mem_Lists_Collection.FindPrefix(AccSel.Text);
    1 : begin
          SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(AccSel.Text);
          if Assigned(SystemMemorisation) then
            MemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
        end;
  end;

  //check that a valid list
  if ( MemorisedList = nil ) then
     Exit;

  with lvMemorised do
  begin
    Prefix := '';
    if AccSel.OverlayIndex = 1 then
      Prefix := AccSel.Text;
    pM := TMemorisation( Selected.SubItems.Objects[0] );
    DeleteSelectedMem := False;
    Sequence_No := pM.mdFields^.mdSequence_No;

    if EditMemorisation(BA, MemorisedList, pM, DeleteSelectedMem, False, Prefix, -1) then
    begin
      if DeleteSelectedMem then
      begin
        MasterMemToDelete := -1;
        if Assigned(AdminSystem) then
        begin
          SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
          if Assigned(SystemMemorisation) then
          begin
            for i := 0 to TMemorisations_List(SystemMemorisation.smMemorisations).ItemCount - 1 do
            begin
              if (TMemorisation(TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(i)).mdFields.mdSequence_No =
                 pM.mdFields^.mdSequence_No) then
              begin
                MasterMemToDelete := i;
                Break;
              end;
            end;

            if (DeleteSelectedMem and (MasterMemToDelete > -1)) then
            begin
              SystemMem := TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(MasterMemToDelete);
              DeleteMem(MemorisedList, BA, SystemMem, Prefix);
            end;
          end;
        end;
      end;

      //Set changed to true so that CES reloads edited transactions
      FMemorisationChanged := True;
      //if the edit was succesful we need to reload the memorisations to display them
      //correctly in the list view
      case AccSel.OverlayIndex of
         0: AccSel.StateIndex := LoadMemorisations(tBank_Account(AccSel.Data));
         1: LoadMasters(AccSel.Text);
      end; //case

      if Assigned(lvMemorised.Selected) then
      begin
        // See if we can find the last edited one..
        for I := 0 to lvMemorised.items.Count - 1 do
        begin
          if (TMemorisation(lvMemorised.Items[I].SubItems.Objects[0]).mdFields^.mdSequence_No = Sequence_No) then
          begin
            lvMemorised.Selected := nil; //Deselect all..
            lvMemorised.Selected := lvMemorised.Items[I];
            lvMemorised.Selected.Focused := True;
            Break;
          end;
        end;
      end;

      if (AccSel.OverlayIndex = 1) then
        LoadMasters(Prefix);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbFindClick(Sender: TObject);
begin
  SearchVisible := not SearchVisible;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbDeleteClick(Sender: TObject);
var
  m : TMemorisation;
  PrevSelectedIndex : Integer;
  PrevTopItemIndex: Integer;
  MemorisedList : TMemorisations_List;
  AccSel : TTreeNode;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  Prefix: string;
begin
  Prefix := '';
  AccSel := trvAccountView.Selected;
  if not Assigned(AccSel) then Exit;
  if ( lvMemorised.Selected = nil ) then Exit;

  //get the memorised transaction list
  MemorisedList := nil;
  case trvAccountView.Selected.OverlayIndex {StateIndex} of
      0 : MemorisedList := tBank_Account(AccSel.Data).baMemorisations_List;
//      1 : MemorisedList := Master_Mem_Lists_Collection.FindPrefix(AccSel.Text);
    1 : begin
          SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(AccSel.Text);
          if Assigned(SystemMemorisation) then begin
            MemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
            Prefix := AccSel.Text;
          end;
        end;
  end; //case

  if ( MemorisedList = nil ) then Exit;

  m := TMemorisation( lvMemorised.Selected.SubItems.Objects[0] );
  PrevSelectedIndex := lvMemorised.Selected.Index;
  PrevTopItemIndex := lvMemorised.TopItem.Index;
  if DeleteMemorised( MemorisedList, m, (lvMemorised.SelCount > 1), Prefix) then
  begin
    case AccSel.OverlayIndex {StateIndex} of
       0: AccSel.StateIndex :=  LoadMemorisations (tBank_Account(AccSel.Data));
       1: LoadMasters( trvAccountView.selected.text);
    end; //case

    //select item after the one we just deleted
    if ( lvMemorised.Items.Count > 0 ) then
    begin
      lvMemorised.ClearSelection;
      ReselectAndScroll(lvMemorised, PrevSelectedIndex, PrevTopItemIndex);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.btnFindClick(Sender: TObject);
begin
  EBFind.Text := '';
  SearchTimerTimer(nil);
end;

//------------------------------------------------------------------------------
function TfrmMaintainMem.DeleteMemorised(MemorisedList : TMemorisations_List;
  Mem: TMemorisation; Multiple : Boolean; Prefix: string = ''; ShowPrompt: boolean = true): boolean;
const
  ThisMethodName = 'DeleteMemorised';
var
  i, j, DeletedSeqNo : integer;
  CodedTo,
  MemDesc   : string;
  CodeType  : string;
  MasterMsg : string;
  MasterMsgSpace : string;
  ExtraMsg  : string;
  Country   : Byte;
  Item: TListItem;
  MemLine : pMemorisation_Line_Rec;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  SystemMem: TMemorisation;
  MasterMemInfoRec: TMasterMemInfoRec;
begin
   Result := false;
   MasterMsg := '';
   ExtraMsg := '';

   if (Multiple) then
   begin
     if ShowPrompt then
       if AskYesNo('Delete Memorisations?','OK to Delete Multiple Memorisations?',DLG_YES,0) <> DLG_YES then exit;
     //delete the multiple entries
     Item := lvMemorised.Selected;
     while Item <> nil do
     begin
       Mem := TMemorisation( Item.SubItems.Objects[0] );
       MemorisedList.DelFreeItem(Mem);
       Item := lvMemorised.GetNextItem(Item, sdAll, [isSelected]);
     end;
   end else begin
     //Single delete
     CodedTo := '';
     for j := Mem.mdLines.First to Mem.mdLines.Last do begin
       MemLine := Mem.mdLines.MemorisationLine_At(j);
       if MemLine^.mlAccount <> '' then
         CodedTo := CodedTo + MemLine^.mlaccount+ ' ';
     end;
     if (not mem.mdFields.mdFrom_Master_List) or (not Assigned( AdminSystem)) then begin
       CodeType := MyClient.clFields.clShort_Name[mem.mdFields.mdType];
       if (not Assigned( AdminSystem)) and (mem.mdFields.mdFrom_Master_List) then begin
         MasterMsg := 'MASTER';
         ExtraMsg := #13+#13+'This will only delete the MASTER memorisation TEMPORARILY.  To delete it permanently it must be deleted at the PRACTICE.';
       end;
     end else begin
       CodeType := AdminSystem.fdFields.fdShort_Name[mem.mdFields.mdType];
       MasterMsg := 'MASTER';
       ExtraMsg := #13+#13+'NOTE: This will apply to ALL clients in your practice that have accounts with this bank and use MASTER memorisations.';
     end;

     if Assigned( MyClient ) then
        Country := MyClient.clFields.clCountry
     else
        Country := AdminSystem.fdFields.fdCountry;

     MemDesc := #13 +'Coded To '+CodedTo + #13 + 'Entry Type is '+IntToStr(mem.mdFields.mdType) + ':' + CodeType;

     { build list of things that match }

     case Country of
        whNewZealand :
           Begin
              if mem.mdFields.mdMatch_on_Refce then        MemDesc := MemDesc + #13 + 'Reference is ' + mem.mdFields.mdReference;
              if mem.mdFields.mdMatch_on_Analysis then     MemDesc := MemDesc + #13 + 'Analysis is ' + mem.mdFields.mdAnalysis;
              if mem.mdFields.mdMatch_On_Statement_Details then MemDesc := MemDesc + #13 + 'Stmt Details are ' + mem.mdFields.mdStatement_Details;
              if mem.mdFields.mdMatch_on_Particulars then  MemDesc := MemDesc + #13 + 'Particulars are ' + mem.mdFields.mdParticulars;
              if mem.mdFields.mdMatch_on_Other_Party then  MemDesc := MemDesc + #13 + 'Other Party is ' + mem.mdFields.mdOther_Party;
              if mem.mdFields.mdMatch_on_notes then        MemDesc := MemDesc + #13 + 'Notes is ' + mem.mdFields.mdNotes;
              if Assigned(BA) then
                if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, BA.baFields.baCurrency_Code)
              else
                if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, whCurrencyCodes[Country])
           end;
        whAustralia, whUK :
           Begin
              if mem.mdFields.mdMatch_on_Refce then       MemDesc := MemDesc + #13 + 'Reference is ' + mem.mdFields.mdReference;
              if mem.mdFields.mdMatch_on_Particulars then MemDesc := MemDesc + #13 + 'Bank Type is ' + mem.mdFields.mdParticulars;
              if mem.mdFields.mdMatch_On_Statement_Details then MemDesc := MemDesc + #13 + 'Stmt Details are ' + mem.mdFields.mdStatement_Details;
              if mem.mdFields.mdMatch_on_notes then       MemDesc := MemDesc + #13 + 'Notes is ' + mem.mdFields.mdNotes;
              if Assigned(BA) then
                if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, BA.baFields.baCurrency_Code)
              else
                if (mem.mdFields.mdMatch_on_Amount > 0) then MemDesc := MemDesc + #13 + 'Value is ' + mxNames[mem.mdFields.mdMatch_on_Amount] + ' ' + MoneyStr(mem.mdFields.mdAmount, whCurrencyCodes[Country])
           end;
     end; { Case clCountry }

     if (MasterMSG = '') then
       MasterMsgSpace := ''
     else
       MasterMsgSpace := ' ';
     if ShowPrompt then
       if AskYesNo('Delete Memorisation?','OK to Delete '+MasterMSG+MasterMsgSpace+'Memorisation?'+#13+MemDesc+ExtraMsg,DLG_YES,0) <> DLG_YES then exit;
     if Assigned(AdminSystem) and (Prefix <> '') then begin
       //---DELETE MASTER MEM---
       MasterMemInfoRec.AuditID := Mem.mdFields.mdAudit_Record_ID;
       MasterMemInfoRec.SequenceNumber := Mem.mdFields.mdSequence_No;
       if LoadAdminSystem(true, ThisMethodName) then begin
         //Get mem list
         SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(Prefix);
         if not Assigned(SystemMemorisation) then
           UnlockAdmin
         else if not Assigned(SystemMemorisation.smMemorisations) then
           UnlockAdmin
         else begin
           SystemMem := nil;
           //Delete memorisation
           for i := TMemorisations_List(SystemMemorisation.smMemorisations).First to TMemorisations_List(SystemMemorisation.smMemorisations).Last do begin
             SystemMem := TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(i);
             if Assigned(SystemMem) then begin
//               if (SystemMem.mdFields.mdAudit_Record_ID = MasterMemInfoRec.AuditID) and
//                  (SystemMem.mdFields.mdSequence_No = MasterMemInfoRec.SequenceNumber) then begin
               //Don't care about the sequence for deletes?
               if (SystemMem.mdFields.mdAudit_Record_ID = MasterMemInfoRec.AuditID) then begin
                 DeletedSeqNo := SystemMem.mdFields.mdSequence_No;
                 TMemorisations_List(SystemMemorisation.smMemorisations).DelFreeItem(SystemMem);
                 Result := True;

                 // Need to subtract one from the sequence number for any memorisations after the deleted one
                 for j := TMemorisations_List(SystemMemorisation.smMemorisations).First to
                          TMemorisations_List(SystemMemorisation.smMemorisations).Last do
                 begin
                   if (TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(j).mdFields.mdSequence_No > DeletedSeqNo) then
                     Dec(TMemorisations_List(SystemMemorisation.smMemorisations).Memorisation_At(j).mdFields.mdSequence_No);
                 end;
                 Break;
               end;
             end;
           end;
           if Assigned(SystemMem) and (not Result) then
             HelpfulErrorMsg('Could not delete master memorisation because it has been changed by another user.', 0);
           //Delete pSystem_Memorisation_List_Rec if there are no memorisations
          if TMemorisations_List(SystemMemorisation.smMemorisations).ItemCount = 0 then
             AdminSystem.SystemMemorisationList.Delete(SystemMemorisation);
           //*** Flag Audit ***
           SystemAuditMgr.FlagAudit(arMasterMemorisations);
           SaveAdminSystem;
         end;
       end else
         HelpfulErrorMsg('Could not delete master memorisation at this time. Admin System unavailable.', 0);
       //---END DELETE MASTER MEM---
     end else
       MemorisedList.DelFreeItem(Mem);
   end;

   FMemorisationChanged := True;
   Result := True;

   LogUtil.LogMsg(lmInfo,'MAINTAINMEMFRM','User Deleted '+MasterMSG+' Memorisation '+ MemDesc);
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if ((EBFind.Focused) or btnFind.Focused) and
     (Msg.CharCode <> VK_ESCAPE) then
  begin
    Exit;
    Handled := false;
  end;

  Handled := true;
  If (Msg.charcode = Ord('F')) and (GetKeyState(VK_CONTROL) < 0) Then
  begin
    if not SearchVisible then
      SearchVisible := true;
    EBFind.SetFocus;
    Exit;
  end;

  case Msg.CharCode of
    VK_DELETE   : if tbDelete.Enabled then
      tbDelete.click;
    VK_ADD      : if tbMoveDown.Enabled then
      tbMoveDown.Click;
    VK_SUBTRACT : if tbMoveUp.Enabled then
      tbMoveUp.Click;
    VK_RETURN   : EditSelectedMemorisation;
    VK_ESCAPE   : tbClose.click;
  else
    Handled := false;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.FormShow(Sender: TObject);
begin
  SearchVisible := UserINI_MEM_Show_Find;
  trvAccountView.SetFocus;
  lvMemorised.SetFocus;
end;

//------------------------------------------------------------------------------
function TfrmMaintainMem.GetSearchVisible: Boolean;
begin
  result := PnlSearch.Visible;
end;

//------------------------------------------------------------------------------
function TfrmMaintainMem.TestText(const Value: string; aSearchText : string): Boolean;
begin
  Result := False;
  if Value = '' then
    Exit;
  Result := Pos(aSearchText, Uppercase(Value)) > 0;
end;

//------------------------------------------------------------------------------
function TfrmMaintainMem.FindTextInItem(aItem : TListItem; aSearchText : string) : Boolean;
var
  SubItemIndex : integer;
begin
  Result := false;

  Result := TestText(aItem.Caption, aSearchText);
  if Result then
    Exit;

  for SubItemIndex := 0 to aItem.SubItems.Count  - 1 do
  begin
    Result := TestText(aItem.SubItems.Strings[SubItemIndex], aSearchText);
    if Result then
      Exit;
  end;
end;

//------------------------------------------------------------------------------
(*
procedure TfrmMaintainMem.tbViewClick(Sender: TObject);
var
  m : pMemorised_Transaction_Rec;
begin
  if (lvMemorised.Selected <> nil) then
  begin
     m := pMemorised_Transaction_Rec(lvMemorised.Selected.SubItems.Objects[0]);
     DisplayMemorisation(m);
  end;
end;
*)
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.lvMemorisedDblClick(Sender: TObject);
begin
  EditSelectedMemorisation;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.trvAccountViewChange(Sender: TObject;
  Node: TTreeNode);
  var SelNode: TTreeNode;
begin
  tbEdit.Enabled := False;
  tbDelete.Enabled := False;
  tbCopyTo.Enabled := False;
  tbMoveUp.Enabled := False;
  tbMoveDown.Enabled := False;
  SelNode := trvAccountView.selected;
  if Assigned(SelNode) then
  begin
     if SelNode.ImageIndex = MAINTAIN_FOLDER_CLOSED_BMP then
     begin

       //was closed, now open this node
       case SelNode.OverlayIndex{StateIndex} of
       0: begin   //client memorisations
            SelNode.StateIndex := LoadMemorisations(tBank_Account(SelNode.Data));
            stTitle.Caption := ' Memorisations for '+tBank_Account(SelNode.data).AccountName;
          end;

       1: begin  //MASTER memorisations
            LoadMasters( trvAccountView.selected.text);
            stTitle.caption := ' MASTER Memorisations for '+ SelNode.text;
          end;
       end; //case
     end else
     begin
       //was open, now close this node and clear the details panel
//       CheckMasterSaveNeeded;

       stTitle.caption := ' ';
       lvMemorised.Items.BeginUpdate;
       try
         lvMemorised.items.Clear;
       finally
         lvMemorised.Items.EndUpdate;
       end;
     end;
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbCloseClick(Sender: TObject);
begin
//   CheckMasterSaveNeeded;
   close;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.lvMemorisedCompare(Sender: TObject; Item1,
  Item2: TListItem; Data: Integer; var Compare: Integer);
var
  m1,m2 : TMemorisation;
begin
  case SortCol of
    colCodedTo: begin // Caption, not subitems
          Compare := StStrS.CompStringS(Item1.Caption,Item2.Caption);
       end;
    colLastApplied, colAppliesFrom, colAppliesTo: begin // Dates..
          Compare := Math.CompareValue( Integer( Item1.SubItems.Objects[SortCol-1]), Integer( Item2.SubItems.Objects[SortCol-1]));
       end;
    else begin // Just text...
          Compare := StStrS.CompStringS( Item1.SubItems.Strings[SortCol-1],Item2.SubItems.Strings[SortCol-1]);
         end;
  end;

  if Compare = 0 then begin
     //now put into sequence number order so can see priority
     m1 := TMemorisation(Item1.SubItems.Objects[0]);
     m2 := TMemorisation(Item2.SubItems.Objects[0]);
     Compare := - Math.CompareValue(m1.mdFields.mdSequence_No, m2.mdFields.mdSequence_No);
  end;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.lvMemorisedColumnClick(Sender: TObject;
  Column: TListColumn);
var
 i : integer;
begin
  for i := 0 to lvMemorised.columns.Count-1 do
    lvMemorised.columns[i].ImageIndex := -1;
  column.ImageIndex := MAINTAIN_COLSORT_BMP;

  SortCol := Column.ID;
  lvMemorised.AlphaSort;
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbMoveUpClick(Sender: TObject);
begin
   MoveItem(True);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbtnCloseClick(Sender: TObject);
begin
  EBFind.Text := '';
  SearchTimerTimer(nil);
  SearchVisible := False;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.tbMoveDownClick(Sender: TObject);
begin
  MoveItem(false);
end;
//------------------------------------------------------------------------------
procedure TfrmMaintainMem.MoveItem(MoveItemUp: boolean);
//provides ability to change the priority of a memorisation.  The priority can
//only be change for memorisations of the same entry type
const
  ThisMethodName = 'MoveItem';
var
  i: integer;
  m1, m2 : TMemorisation;
  SelIndex : integer;
  MemorisedList : TMemorisations_List;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
  MasterMemInfoRec1, MasterMemInfoRec2: TMasterMemInfoRec;
  Swapped: Boolean;

  procedure SetMemsToSwap;
  begin
    m1 := nil;
    m2 := nil;
    SelIndex := lvMemorised.Items.IndexOf(lvMemorised.Selected);
    if (MoveItemUp and (SelIndex=0)) or ((not MoveItemUp) and (SelIndex >= lvMemorised.items.Count-1)) then
      Exit;

    //select items to move from list
    if MoveItemUp then
    begin
      m1 := TMemorisation(lvMemorised.Selected.SubItems.Objects[0]);
      m2 := TMemorisation(lvMemorised.Items[SelIndex-1].SubItems.Objects[0]);
    end else begin
      m1 := TMemorisation(lvMemorised.Items[SelIndex+1].SubItems.Objects[0]);
      m2 := TMemorisation(lvMemorised.Selected.SubItems.Objects[0]);
    end;
  end;

  function SwapItems: Boolean;
  begin
    Result := False;
    //should now have the items and the list that they belong to
    if Assigned(lvMemorised.Selected) and Assigned(MemorisedList) then
    begin
       SetMemsToSwap;
       if Assigned(m1) and Assigned(m2) then begin
         //check are the same transaction type
         if m1.mdFields.mdType <> m2.mdFields.mdType then Exit;
         //check that not master and normal mem
         if m1.mdFields.mdFrom_Master_List <> m2.mdFields.mdFrom_Master_List then Exit;
         //at this point we have m1,m2 which are the memorisations to swap
         MemorisedList.SwapItems(m1,m2);
         FMemorisationChanged := true;
         Result := True;
         lvMemorised.Alphasort;
       end;
    end;
  end;
begin
  Swapped := False;
  //must have the items sorted by EntryType and SeqNo to perform this
  if not (SortCol = 1) then
  begin
    HelpfulInfoMsg('The Memorisations must be sorted by Entry Type before they can be moved. '
                    + SHORTAPPNAME+ ' will now resort the memorisations.',0);

    lvMemorisedColumnClick(lvMemorised, lvMemorised.Column[1]);
    exit;
  end;

  //get the memorised transaction list
  MemorisedList := nil;
  if Assigned(trvAccountView.Selected) then
  begin
    case trvAccountView.Selected.OverlayIndex{StateIndex} of
      0 : begin
            MemorisedList := tBank_Account(trvAccountView.selected.Data).baMemorisations_List;
            SwapItems;
          end;
      1 : begin
            SetMemsToSwap;
            if Assigned(m1) and Assigned(m2) then begin
              //Save Audit ID and Seq of mems to swap
              MasterMemInfoRec1.AuditID := m1.mdFields.mdAudit_Record_ID;
              MasterMemInfoRec1.SequenceNumber := m1.mdFields.mdSequence_No;
              MasterMemInfoRec2.AuditID := m2.mdFields.mdAudit_Record_ID;
              MasterMemInfoRec2.SequenceNumber := m2.mdFields.mdSequence_No;
              //Lock and load the system db
              if LoadAdminSystem(true, ThisMethodName) then begin
                SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(trvAccountView.selected.Text);
                if Assigned(SystemMemorisation) then begin
                  MemorisedList := TMemorisations_List(SystemMemorisation.smMemorisations);
                  if Assigned(MemorisedList) then begin
                    //Reload master mems
                    LoadMasters(trvAccountView.selected.Text);
                    //Select mems to swap
                    m1 := nil;
                    m2 := nil;
                    SelIndex := -1;
                    for i := 0 to Pred(lvMemorised.Items.Count) do begin
                      if (MasterMemInfoRec1.AuditID = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdAudit_Record_ID) and
                         (MasterMemInfoRec1.SequenceNumber = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdSequence_No) then begin
                        m1 := TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]);
                        if not MoveItemUp then SelIndex := i;
                      end;
                      if (MasterMemInfoRec2.AuditID = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdAudit_Record_ID) and
                         (MasterMemInfoRec2.SequenceNumber = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdSequence_No) then begin
                        m2 := TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]);
                        if MoveItemUp then SelIndex := i;
                      end;
                    end;
                    if Assigned(m1) and Assigned(m2) then begin
                      //They must be in the same order if the sequence numbers still match
                     if m1.mdFields.mdType = m2.mdFields.mdType then begin
                       //at this point we have m1,m2 which are the memorisations to swap
                       MemorisedList.SwapItems(m1,m2);
                       FMemorisationChanged := true;
                       lvMemorised.Alphasort;
                       if SelIndex <> -1 then
                         lvMemorised.Items[SelIndex].Selected := True;
                       //*** Flag Audit ***
                       SystemAuditMgr.FlagAudit(arMasterMemorisations);
                       SaveAdminSystem;
                       Swapped := True;                       
                     end;
                    end;
                  end;
                end;
              end;
              if (not Swapped) then begin
                UnlockAdmin;
                if Assigned(m1) and Assigned(m2) then
                  if m1.mdFields.mdType = m2.mdFields.mdType then //Fix 15433
                    //This should be the only reason for the memorisations not being swapped
                    HelpfulErrorMsg('Could not move master memorisation because they have been changed by another user.', 0);
                //Select item
                for i := 0 to Pred(lvMemorised.Items.Count) do
                  if MoveItemUp then begin
                    if (MasterMemInfoRec1.AuditID = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdAudit_Record_ID) then
                      lvMemorised.Items[i].Selected := True;
                  end else begin
                    if (MasterMemInfoRec2.AuditID = TMemorisation(lvMemorised.Items[i].SubItems.Objects[0]).mdFields.mdAudit_Record_ID) then
                      lvMemorised.Items[i].Selected := True;
                  end;
              end;
            end;
          end;
    end; //case
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.Refresh;
var
  SelNode: TTreeNode;
begin
  tbEdit.Enabled := False;
  tbDelete.Enabled := False;
  tbCopyTo.Enabled := False;
  tbMoveUp.Enabled := False;
  tbMoveDown.Enabled := False;
  SelNode := trvAccountView.selected;
  if Assigned(SelNode) then
  begin
    if SelNode.ImageIndex = MAINTAIN_FOLDER_CLOSED_BMP then
    begin

      //was closed, now open this node
      case SelNode.OverlayIndex{StateIndex} of
        0 : begin   //client memorisations
          SelNode.StateIndex := LoadMemorisations(tBank_Account(SelNode.Data));
          stTitle.Caption := ' Memorisations for '+tBank_Account(SelNode.data).AccountName;
        end;

        1 : begin  //MASTER memorisations
          LoadMasters( trvAccountView.selected.text);
          stTitle.caption := ' MASTER Memorisations for '+ SelNode.text;
        end;
      end; //case
    end
    else
    begin
      stTitle.caption := ' ';
      lvMemorised.Items.BeginUpdate;
      try
        lvMemorised.items.Clear;
      finally
        lvMemorised.Items.EndUpdate;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.LoadMasters(BankPrefix : ShortString);
var
  i,j : integer;
  m : TMemorisation;
  newItem : TListItem;
  CodedTo : string;
  EntryType : string;
  rev       : boolean;
  Country   : Byte;

//  MemList : TMaster_Memorisations_List;
  MemList : TMemorisations_List;
  MemLine : pMemorisation_Line_Rec;
  SystemMemorisation: pSystem_Memorisation_List_Rec;
begin
   if (not Assigned(AdminSystem)) then
      Exit;  //should only be used with admin system present
   BA := nil;

   if Assigned( MyClient ) then
      Country := MyClient.clFields.clCountry
   else
      Country := AdminSystem.fdFields.fdCountry;

   //load items
   lvMemorised.Items.BeginUpdate;
   try
     lvMemorised.items.Clear;

     //check that columns are displayed correctly
     Rev := ( BankPrefix = '70');

     case Country of
        whNewZealand :
           Begin
              if Rev then
              begin
                 lvMemorised.columns[colParticulars].caption := 'Particulars';
                 lvMemorised.columns[colOtherParty].caption := 'Other Party';
              end
              else
              begin
                 lvMemorised.columns[colParticulars].caption := 'Other Party';
                 lvMemorised.columns[colOtherParty].caption := 'Particulars';
              end;
           end;
        whAustralia  :
           Begin
              lvMemorised.columns[colAnalysis].Caption  := 'Bank Type';  //NZ Analysis Col
              lvMemorised.Columns[colParticulars].MaxWidth := 1;  //Particulars Col
              lvMemorised.columns[colParticulars].width    := 0;
              lvMemorised.columns[colParticulars].Caption  := '';
              lvMemorised.Columns[colOtherParty].MaxWidth := 1;  //Other Party Col
              lvMemorised.columns[colOtherParty].width    := 0;
              lvMemorised.columns[colOtherParty].Caption  := '';
           end;
     end;

     //get MASTER memorisations
     SystemMemorisation := AdminSystem.SystemMemorisationList.FindPrefix(BankPrefix);
     if SystemMemorisation = nil then exit;

     MemList := TMemorisations_List(SystemMemorisation.smMemorisations);
     if MemList = nil then exit;

     WorkingOnMasterPrefix := BankPrefix;

     for i := MemList.Last downto MemList.First do
     begin
       m := MemList.Memorisation_At(i);
       CodedTo := '';
       for j := m.mdLines.First to m.mdLines.Last do
       begin
         MemLine := m.mdLines.MemorisationLine_At(j);
         if MemLine^.mlAccount <> '' then
           CodedTo := CodedTo + MemLine^.mlaccount+ ' ';
       end;

       if CodedTo <> '' then
       begin
         newItem := lvMemorised.items.Add;
         newItem.Caption := CodedTo;
         if m.mdFields.mdFrom_Master_List then
           newItem.ImageIndex := MAINTAIN_MASTER_MEM_PAGE_BMP
         else
           newItem.ImageIndex := MAINTAIN_PAGE_NORMAL_BMP;

         EntryType := IntToStr(m.mdFields.mdType);
         EntryType := Copy('  ', 1, 2 - Length(EntryType)) + EntryType +
                      ':' + AdminSystem.fdFields.fdShort_Name[m.mdFields.mdType];

         if m.mdFields.mdFrom_Master_List then
           EntryType := 'M '+EntryType;

         with NewItem.SubItems do
         begin
           AddObject(EntryType,TObject(m));

           Add(CriteriaStr(m.mdFields.mdReference, m.mdFields.mdMatch_on_Refce));

           case Country of
              whNewZealand :
                 Begin
                    Add(CriteriaStr(m.mdFields.mdAnalysis,m.mdFields.mdMatch_on_Analysis));
                    Add(CriteriaStr(m.mdFields.mdStatement_Details,m.mdFields.mdMatch_On_Statement_Details));
                    if Rev then
                    begin
                       Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                       Add(CriteriaStr(m.mdFields.mdOther_Party,m.mdFields.mdMatch_on_Other_Party));
                    end
                    else
                    begin
                       Add(CriteriaStr(m.mdFields.mdOther_Party,m.mdFields.mdMatch_on_Other_Party));
                       Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                    end;
                 end;
              whAustralia,whUK  :
                 Begin
                    Add(CriteriaStr(m.mdFields.mdParticulars,m.mdFields.mdMatch_on_Particulars));
                    Add(CriteriaStr(m.mdFields.mdStatement_Details,m.mdFields.mdMatch_On_Statement_Details));
                    Add('');  //blank for particulars column
                    Add('');  //blank for other party column
                 end;
           end;

           Add( ValueCriteriaStr( m.mdFields.mdAmount, m.mdFields.mdMatch_On_Amount, AdminSystem.CurrencyCode ));
           Add( CriteriaStr( m.mdFields.mdNotes, m.mdFields.mdMatch_on_notes));
           AddObject('',tobject(0));
           AddObject(bkDate2Str( m.mdFields.mdFrom_Date),tobject(m.mdFields.mdFrom_Date));
           AddObject(bkDate2Str( m.mdFields.mduntil_Date),tobject(m.mdFields.mduntil_Date))


         end;

         if length(fSearchText) > 0 then
           if not FindTextinItem(NewItem, fSearchText) then
             lvMemorised.items.Delete(lvMemorised.items.Count-1);
       end;
     end;
   finally
     lvMemorised.items.EndUpdate;
   end;
end;

//------------------------------------------------------------------------------
function TfrmMaintainMem.Execute: boolean;
{returns true if memorisations changed}
begin
   LoadAccounts;
   ShowModal;
   result := true;
end;
//------------------------------------------------------------------------------
function MaintainMemorised : boolean;
var
  MyDlg : tfrmMaintainMem;
begin
  MyDlg := tFrmMaintainMem.Create(Application.MainForm);
  try
    BKHelpSetup(MyDlg, BKH_Viewing_editing_and_deleting_memorisations);
    MyDlg.MastersOnly := false;
    MyDlg.Execute;
    result := MyDlg.MemorisationChanged;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
function MaintainMasters : boolean;
//- - - - - - - - - - - - - - - - - - - -
// Purpose:    Launches the maintain screen with just master mems loaded
//
// Parameters: none
//
// Result:     Returns true if master mems edited
//- - - - - - - - - - - - - - - - - - - -
var
  MyDlg : tfrmMaintainMem;
begin
  MyDlg := tFrmMaintainMem.Create(Application.MainForm);
  try
    BKHelpSetup(MyDlg, BKH_Master_memorised_entries);
    MyDlg.MastersOnly := true;
    //last applied col is irrelevant to master mems so hide it
    MyDlg.lvMemorised.Columns[colLastApplied].MaxWidth := 1;
    MyDlg.lvMemorised.columns[colLastApplied].width    := 0;
    MyDlg.lvMemorised.columns[colLastApplied].Caption  := '';

    MyDlg.Execute;
    result := MyDlg.MemorisationChanged;
  finally
    MyDlg.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.EBFindChange(Sender: TObject);
begin
  // restart the search timer..
  SearchTimer.Enabled := False;
  SearchTimer.Enabled := True;
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.EBFindKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
    SearchTimerTimer(nil);
end;

//------------------------------------------------------------------------------
procedure TfrmMaintainMem.EditSelectedMemorisation;
begin
  if Assigned( MyClient) and ( tbEdit.Enabled) then
    tbEdit.Click;
end;

procedure TfrmMaintainMem.lvMemorisedSelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  OnlyOneSelected : Boolean;
begin
  OnlyOneSelected := (lvMemorised.SelCount = 1);

  if Assigned( trvAccountView.Selected) then
    case trvAccountView.Selected.OverlayIndex{StateIndex} of
      //client
      0 : begin
        tbEdit.Enabled := OnlyOneSelected;

        tbDelete.Enabled   := OnlyOneSelected;
        tbMoveUp.Enabled   := OnlyOneSelected;
        tbMoveDown.Enabled := OnlyOneSelected;

        tbCopyTo.Enabled := ( BankAccountCount > 1) and ( lvMemorised.SelCount > 0);
      end;
      //master
      1 : begin
        tbEdit.Enabled := OnlyOneSelected and CurrUser.CanMemoriseToMaster and Assigned( MyClient);

        tbDelete.Enabled   := OnlyOneSelected and CurrUser.CanAccessAdmin;
        tbMoveUp.Enabled   := OnlyOneSelected and CurrUser.CanAccessAdmin;
        tbMoveDown.Enabled := OnlyOneSelected and CurrUser.CanAccessAdmin;

        tbCopyTo.Enabled := False;
      end;
    end;
end;

procedure TfrmMaintainMem.tbCopyToClick(Sender: TObject);
var
  i, j : Integer;
  BATo : tBank_Account;
  MemFrom, MemTo : TMemorisation;
  MemLineFrom, MemLineTo : pMemorisation_Line_Rec;
  Item : TListitem;

  dlgCopyMemorisations : TdlgCopyMemorisations;
begin
  if (trvAccountView.SelectionCount > 0) then
  begin
    dlgCopyMemorisations := TdlgCopyMemorisations.Create(Self);
    try
      dlgCopyMemorisations.Setup(tBank_Account(trvAccountView.selected.Data));
      dlgCopyMemorisations.ShowModal;

      if (dlgCopyMemorisations.ModalResult = mrOK) then
      begin
        if ((dlgCopyMemorisations.cmbMemorisations.ItemIndex) = -1) then
          Exit;

        BATo := TBank_Account(dlgCopyMemorisations.cmbMemorisations.Items.Objects[dlgCopyMemorisations.cmbMemorisations.ItemIndex]);
        if (dlgCopyMemorisations.radCopyAll.Checked) then
        begin
          //copy all
          //items at the top have a higher sequence number
          for i := lvMemorised.Items.Count-1 downto 0 do
          begin
            MemFrom := TMemorisation( lvMemorised.Items.Item[i].SubItems.Objects[0]);
            MemTo := TMemorisation.Create(BATo.AuditMgr);
            MemTo.mdFields^ := MemFrom.mdFields^;
            for j := MemFrom.mdLines.First to MemFrom.mdLines.Last do
            begin
              MemLineFrom := MemFrom.mdLines.MemorisationLine_At(j);
              MemLineTo := BKMLIO.New_Memorisation_Line_Rec;
              MemLineTo^ := MemLineFrom^;
              //MemLineTo^.mlAccount           := MemLineFrom^.mlAccount;
              //MemLineTo^.mlPercentage        := MemLineFrom^.mlPercentage;
              //MemLineTo^.mlGst_Class         := MemLineFrom^.mlGst_Class;
              //MemLineTo^.mlGST_Has_Been_Edited := MemLineFrom^.mlGST_Has_Been_Edited;
              //MemLineTo^.mlGL_Narration      := MemLineFrom^.mlGL_Narration;
              //MemLineTo^.mlLine_Type         := MemLineFrom^.mlLine_Type
              MemTo.mdLines.Insert(MemLineTo)
            end;
            MemTo.mdFields.mdFrom_Master_List := False;
            MemTo.mdFields.mdSequence_No := 0;
            BATo.baMemorisations_List.Insert_Memorisation(MemTo);
          end;
        end else
        begin
          //copy selected
          //items at the top have a higher sequence number
          //Item := lvMemorised.Selected;
          //while Item <> nil do
          //begin
          for i := lvMemorised.Items.Count-1 downto 0 do
          begin
            Item := lvMemorised.Items.Item[i];
            if (Item.Selected) then
            begin
              MemFrom := TMemorisation( Item.SubItems.Objects[0]);
              MemTo := TMemorisation.Create(BATo.AuditMgr);
              MemTo.mdFields^ := MemFrom.mdFields^;
              for j := MemFrom.mdLines.First to MemFrom.mdLines.Last do
              begin
                MemLineFrom := MemFrom.mdLines.MemorisationLine_At(j);
                MemLineTo := BKMLIO.New_Memorisation_Line_Rec;
                MemLineTo^ := MemLineFrom^;
                //MemLineTo^.mlAccount           := MemLineFrom^.mlAccount;
                //MemLineTo^.mlPercentage        := MemLineFrom^.mlPercentage;
                //MemLineTo^.mlGst_Class         := MemLineFrom^.mlGst_Class;
                //MemLineTo^.mlGST_Has_Been_Edited := MemLineFrom^.mlGST_Has_Been_Edited;
                //MemLineTo^.mlGL_Narration      := MemLineFrom^.mlGL_Narration;
                //MemLineTo^.mlLine_Type         := MemLineFrom^.mlLine_Type
                MemTo.mdLines.Insert(MemLineTo)
              end;
              MemTo.mdFields.mdFrom_Master_List := False;
              MemTo.mdFields.mdSequence_No := 0;
              BATo.baMemorisations_List.Insert_Memorisation(MemTo);
            end;
           // Item := lvMemorised.GetNextItem(Item, sdAll, [isSelected]);
          end;
        end;
        //Set changed to true so that CES reloads edited transactions
        FMemorisationChanged := True;
      end;
    finally
      dlgCopyMemorisations.Free;
    end;
  end;
end;

procedure TfrmMaintainMem.tbHelpClick(Sender: TObject);
begin
  BKHelpShow(Self);
end;

end.
