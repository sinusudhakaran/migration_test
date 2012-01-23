unit ClientHomePagefrm;
//------------------------------------------------------------------------------
{
   Title: Client HomePage form

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  CodingFormCommands,
  clientHomepageItems,Windows, Messages, SysUtils, Classes, Graphics, Controls,
  Forms, VirtualTrees, ExtCtrls, RzPanel, RzGroupBar,clObj32,ImagesFrm,
  ActnList, StdCtrls, Menus, Grids, RzButton,
  CheckWebNotesData,
  RzTabs,
  OSFont;

type
  THP_RefreshItem = (HRP_Init, HPR_Client, HPR_Coding, HPR_Tasks, HPR_Files, HPR_Status);
  THP_Refresh = set of THP_RefreshItem;
const
  THP_RefreshAll = [low(THP_RefreshItem) .. High(THP_RefreshItem)];

type
  TBaseClientHomepage = class(TForm)
  private
    //
  protected
    function GetTheClient : TClientObj; virtual; abstract;
    procedure SetTheClient(const Value: TClientObj); virtual; abstract;
    function GetRefreshRequest : THP_Refresh; virtual; abstract;
    procedure SetRefreshRequest(const Value: THP_Refresh); virtual; abstract;
    function GetAbandon : boolean; virtual; abstract;
    procedure SetAbandon(const Value: Boolean); virtual; abstract;
  public
    property TheClient: TClientObj read GetTheClient write SetTheClient;
    property RefreshRequest : THP_Refresh read GetRefreshRequest write SetRefreshRequest;
    property Abandon: Boolean read GetAbandon write SetAbandon;

    procedure Lock; virtual; abstract;
    procedure Unlock; virtual; abstract;
    procedure ProcessExternalCmd(Command : TExternalCmd); virtual; abstract;
  end;

type
  TfrmClientHomePage = class(TBaseClientHomepage)
    gbGroupBar: TRzGroupBar;
    GrpAction: TRzGroup;
    ActionList1: TActionList;
    acRunCoding: TAction;
    acTasks: TAction;
    acUpdate: TAction;
    acTransfer: TAction;
    acReports: TAction;
    Splitter1: TSplitter;
    gpClientDetails: TRzGroup;
    acClientEmail: TAction;
    acEditClientDetails: TAction;
    acWebImport: TAction;
    acNotes: TAction;
    pmNodes: TPopupMenu;
    Panel1: TPanel;
    PnlClient: TRzPanel;
    ClientTree: TVirtualStringTree;
    pnlLegend: TPanel;
    lblLegend: TLabel;
    tbtnClose: TRzToolButton;
    sgLegend: TStringGrid;
    acShowlegend: TAction;
    btnMonthleft: TButton;
    BtnMonthRight: TButton;
    BtnYearLeft: TButton;
    BtnYearRight: TButton;
    pnlTitle: TRzPanel;
    ImgLeft: TImage;
    lblClientName: TLabel;
    imgRight: TImage;
    acHelp: TAction;
    GrpReportSchedule: TRzGroup;
    GrpOptions: TRzGroup;
    acSchedule: TAction;
    acMems: TAction;
    acReport: TAction;
    pnlTabs: TPanel;
    tcWindows: TRzTabControl;
    NotesTimer: TTimer;
    acForexRatesMissing: TAction;

    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

    procedure FormCreate(Sender: TObject);

    procedure ClientTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure acTasksExecute(Sender: TObject);
    procedure acRunCodingExecute(Sender: TObject);
    procedure acUpdateExecute(Sender: TObject);
    procedure acTransferExecute(Sender: TObject);
    procedure acReportsExecute(Sender: TObject);

    procedure btnMonthLeftClick(Sender: TObject);
    procedure btnMonthRightClick(Sender: TObject);
    procedure btnYearLeftClick(Sender: TObject);
    procedure BtnYearRightClick(Sender: TObject);

    procedure acEditClientDetailsExecute(Sender: TObject);
    procedure acClientEmailExecute(Sender: TObject);
    procedure acWebImportExecute(Sender: TObject);
    procedure acNotesExecute(Sender: TObject);

    procedure ClientTreeHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
      Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode);
    procedure FormActivate(Sender: TObject);
    procedure sgLegendDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgLegendSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure acShowlegendExecute(Sender: TObject);
    procedure ClientTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure acHelpExecute(Sender: TObject);
    procedure acScheduleExecute(Sender: TObject);
    procedure acMemsExecute(Sender: TObject);
    procedure acReportExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure NotesTimerTimer(Sender: TObject);
    procedure tcWindowsTabClick(Sender: TObject);
    procedure UpdateWebNotes(var Msg: TMessage); message WEBNOTES_MESSAGE;
    procedure acForexRatesMissingExecute(Sender: TObject);
    procedure RefreshExchangeRates;
  private
    FTheClient: TClientObj;
    TreeList: TCHPBaseList;
    FClosing:  Boolean;
    FClosingClient: Boolean;
    FShowLegend: Boolean;
    MaxMindate: Integer;
    FLockCount: Integer;
    FRefreshRequest: THP_Refresh;
    FAbandon: Boolean;
    FBadForexFileName : String;
    fBadForexCurrencyCode : String;
    fBadForexAccountCode : String;

    procedure RefreshClient;
    procedure RefreshTodo;
    procedure RefreshFiles;
    procedure RefreshCoding;
    procedure RefreshMems;
    procedure RefreshMissingExchangeRateMsg;
    procedure SetShowLegend(const Value: Boolean);
    property ShowLegend : Boolean read FShowLegend write SetShowLegend;
    procedure UpdateRefresh;
    { Private declarations }
    procedure wmsyscommand( var msg: TWMSyscommand ); message wm_syscommand;
    procedure UpdateTabs(ActionedPage: string = '');
  protected
    procedure UpdateActions; override;
    function GetTheClient : TClientObj; override;
    procedure SetTheClient(const Value: TClientObj); override;
    function GetRefreshRequest : THP_Refresh; override;
    procedure SetRefreshRequest(const Value: THP_Refresh); override;
    function GetAbandon : boolean; override;
    procedure SetAbandon(const Value: Boolean); override;

  public
    procedure Lock; override;
    procedure Unlock; override;
    procedure ProcessExternalCmd(Command : TExternalCmd); override;
    { Public declarations }
  end;

function ClientHomePage: TBaseClientHomepage;
procedure SetClientHomePageToNil;   //called by SimpleUIHomepage

procedure RefreshHomepage (Value : THP_Refresh = THP_RefreshAll; ActionedPage: string = '');

procedure CloseClientHomepage;
procedure AbandonClientHomePage;

implementation

uses
  MadUtils,
  LogUtil,
  Merge32,
  BKHelp,
  VirtualTreeHandler,
  bkBranding,
  bkConst,
  ReportDefs,
  WebXUtils,
  WebNotesImportFrm,
  ECodingUtils,
  CodingFrm,
  MailFrm,
  ModalProcessorDlg,
  ClientReportScheduleDlg,
  Extract32,
  Globals,SYDEFS, ToDoListUnit,StDate,Math,MainFrm, BKdateUtils, UpdateMF,baObj32,
  ApplicationUtils, AutoSaveUtils, rptHome, ClientNotesFrm, Files, ClientManagerFrm, BudgetFrm,
  bkXPThemes, ShellAPI, SimpleUIHomepagefrm,
  ExchangeRateList, frmExchangeRates, GSTUTIL32;
{$R *.dfm}

var
  FClientHomePage: TBaseClientHomePage;
  DebugMe : boolean = false;

const
  UnitName = 'CLIENTHOME';

function ClientHomePage;

var
  ProcessFrm : TdlgModalProcessor;

begin
  if not assigned(FClientHomePage) then begin
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Create Homepage');
    ProcessFrm := TdlgModalProcessor.Create(Application);
    try
      ApplicationUtils.DisableMainForm;
      UpDateMF.LockMainForm;
      try
        try
          ProcessFrm.Show;
          //global var determine which UI to load
          if Active_UI_Style = UIS_Standard then
          begin
            FClientHomePage := TfrmClientHomePage.Create(MDIParentForm);
          end
          else
          begin
             FClientHomepage := TfrmSimpleUIHomepage.Create(MDIParentForm);
          end;
        except
          FClientHomePage := nil;
          if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Homepage Failed');
        end;
      finally
        UpDateMF.UnLockMainForm;
        ApplicationUtils.EnableMainForm;
      end;
    finally
      ProcessFrm.Free;
    end;
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Homepage Created');
  end;
  Result := FClientHomePage;
end;

procedure SetClientHomePageToNil;
//mh: called externally to so that function ClientHomePage returns nil
begin
   FClientHomePage := nil;
end;

procedure RefreshHomepage (Value : THP_Refresh = THP_RefreshAll; ActionedPage: string = '');
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshHomepage');
  if assigned(MyClient) then begin
     // Something to refresh..
     if assigned(FClientHomePage) then
     begin
        //already have a homepage, just queue the request
        FClientHomePage.RefreshRequest := Value;
     end
     else
     begin// have no Homepage but do have an open client file
        // But I DO want one...
        if HRP_Init in Value then
        begin
           ClientHomePage.TheClient := MyClient; //this triggers the form create
        end;
     end;

     //see if a client homepage was created
     if Assigned( FclientHomePage) then
     begin
       Assert((FClientHomePage is TfrmClientHomePage) OR (FClientHomePage is TfrmSimpleUIHomepage), 'Unknown homepage created');
       //special processing depending on version of homepage that was created
       if FClientHomePage is TfrmClientHomePage then
         TfrmClientHomePage(FClientHomePage).UpdateTabs(ActionedPage);
     end;
  end else
     //Should not have a Homepage...
     CloseClientHomepage;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshHomepage');
end;

procedure CloseClientHomepage;
var
  Temp : TBaseClientHomePage;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter CloseHomepage');
  if assigned(FClientHomePage) then begin
     Temp := FClientHomePage;
     FClientHomePage := NIL;
     Temp.Close;
     Temp.Free;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit CloseHomepage');
end;

procedure AbandonClientHomePage;
//called from files when user selects abandon changes
//Sets the abandon flag in the homepage form which tells it not to do the save
//on close
var
  Temp : TBaseClientHomePage;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter AbandonHomepage');
  if assigned(FClientHomePage) then begin
      Temp := FClientHomePage;
      FClientHomePage := nil;
      Temp.Abandon := True;
      Temp.Close;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit AbandonHomepage');
end;

{ TfrmClientHomePage }


procedure TfrmClientHomePage.RefreshCoding;
var
    i : integer;
    lbase : TTreebaseItem;

    SelAccount : Integer;
    SelJournal : Integer;
    SelGst : Boolean;

    CurParentNode : PVirtualNode;
    type TByteSet = set of byte;

    procedure AddAccount(Account : TBank_Account; CheckTypes : TByteSet; GroupID : Integer);
    var Lacc : TTreebaseItem;
    begin
        if not (account.baFields.baAccount_Type in CheckTypes) then Exit;
        Lacc := TreeList.FindItem(TreeList.TestAccount,Account);

        if assigned(Lacc) then
           //Lacc.Refresh  Done...
        else
           if btBank in CheckTypes then
              TreeList.AddNodeItem(CurParentNode,TCHAccountItem.Create(FTheClient,Account,'',GroupID))
           else
              TreeList.AddNodeItem(CurParentNode,TCHJournalItem.Create(FTheClient,Account,'',GroupID));
    end;




   procedure RefreshCodingPeriod;
   var s : string; // Update the caption once..
       lr : TRangeCount;
   begin
       Lr := TreeList.CodingMonths;
       if Lr.Count > 0 then begin
          AcRunCoding.Enabled := True;
          AcRunCoding.Visible := True;
          if Lr.Count = 1 then
             s :=  'There is 1 uncoded entry'
          else
             s := 'There are ' + IntToStr(Lr.Count) +' uncoded entries';
          AcRunCoding.Caption := s + #10'in '+
                                    GetDateRangeS(Lr.Range);
       end else begin
          AcRunCoding.Enabled := False;
          AcRunCoding.Visible := False;
       end;

       Lr := TreeList.TransferMonths;
       if (not Globals.CurrUser.HasRestrictedAccess)
       and (Lr.Count > 0)
       and (FTheClient.clFields.clAccounting_System_Used <> snOther)
       and (not FTheClient.clFields.clFile_Read_Only)
       and (Assigned(AdminSystem) or INI_BooksExtact) then begin
          if Lr.Count = 1 then
             s := 'There is 1 entry ready to transfer'
          else
             s := 'There are ' + intToStr(Lr.Count) + ' entries ready to transfer,';
          AcTransfer.Caption := s + #10'in ' + GetDateRangeS(Lr.Range);

          AcTransfer.Enabled := True;
          AcTransfer.Visible := True;
       end else begin
          AcTransfer.Enabled := False;
          AcTransfer.Visible := False;
       end;
   end;

   procedure AddAUGst;
   begin
      if (FTheClient.clFields.clGST_Period = 0)
      or (FTheClient.clFields.clGST_Start_Month = 0) then
         Exit;
      if (FTheClient.clFields.clGST_Period = gpMonthly)
      or (FTheClient.clFields.clBAS_PAYG_Withheld_Period  = gpMonthly) then
         TreeList.AddNodeItem(CurParentNode,TCHBASPeriodItem.Create(FTheClient,True))
      else begin
         TreeList.AddNodeItem(CurParentNode,TCHBASPeriodItem.Create(FTheClient,False));
      end;
   end;

   procedure Reselect;
      procedure SelectNode (ANode : PVirtualNode);
      begin
         if not assigned(ANode) then exit;
         ClientTree.Selected[ANode] := True;
         ClientTree.FocusedNode := ANode;
         ClientTree.ScrollIntoView(ANode,false);
      end;
   begin
      if SelGst then begin
        lbase := TreeList.FindItem (TreeList.TestGST,I{Dummy});
        if assigned(lBase) then
            SelectNode(lBase.Node);

      end else if SelJournal > 0 then begin
         lBase := TreeList.FindItem(TreeList.TestAccountType,SelJournal);
         if assigned(lBase) then
            SelectNode(lBase.Node);
      end else if SelAccount > 0 then begin
      end;
   end;

begin //RefreshCoding
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshCoding');
   RefreshMems;
   RefreshMissingExchangeRateMsg;

   ClientTree.BeginUpdate;
   try
      //ClientTree.Clear;
      ShowLegend := UserINI_CM_ShowLegend;
      SelAccount := -1;
      SelJournal := -1;
      SelGst := False;
      if ClientTree.SelectedCount > 0 then begin
         CurParentNode := ClientTree.GetFirstSelected;
         while Assigned(CurParentNode) do begin
            lbase := TreeList.GetNodeItem(CurParentNode);
            if assigned(lBase) then begin
              if lbase is TCHGSTPeriodItem then begin
                 SelGst := True;
                 Break;
              end else if lBase is TCHJournalItem then begin
                 selJournal := TCHJournalItem(LBase).AccountType;
                 Break;
              end else if lbase is TCHAccountItem then begin
                 SelAccount := ClientTree.AbsoluteIndex(CurParentNode);
                 Break;
              end;
            end;
            CurParentNode := ClientTree.GetNextSelected(CurParentNode);
         end;
      end;
      CurParentNode := nil;
      if Assigned(FTheClient) then begin
         // Have Something to show.

         if FTheClient.HasForeignCurrencyAccounts then
           ClientTree.Header.Columns[ 4 ].Options := ClientTree.Header.Columns[ 4 ].Options + [ coVisible ]
         else
           ClientTree.Header.Columns[ 4 ].Options := ClientTree.Header.Columns[ 4 ].Options - [ coVisible ];

         TreeList.Refresh;


         // Periods
         // Shouldrealy  move this..(Not showing..)

         Lbase := TreeList.FindItem(TreeList.TestYear,I{Dummy});
         if assigned(lBase) then Lbase.Refresh
         else TreeList.AddItem(TCHYearItem.Create
              (FTheClient,btnMonthLeft,btnMonthRight,btnYearLeft,BtnYearRight
              ));

         // bank accounts
         Lbase := TreeList.FindGroupID (grp_Banks);
         if assigned(lBase) then
            CurParentNode := Lbase.Node
         else
            CurParentNode := TreeList.AddNodeItem(nil, TCHPBaseItem.Create(FTheClient,'Bank Accounts',grp_Banks));
         CurParentNode := nil;
         {
         I := grp_Bank;
         TreeList.RemoveItems (TreeList.TestGroupID,I);
         }
         for I := FTheClient.clBank_Account_List.First to FTheClient.clBank_Account_List.Last do
            AddAccount(FTheClient.clBank_Account_List.Bank_Account_At(I), [btBank], grp_Bank);

         //ClientTree.Expanded[CurParentNode] := True;

         // Journals
         TreeList.RemoveItems (TreeList.TestBlanks,I{Dummy});
         {
         I := grp_Journal;
         TreeList.RemoveItems (TreeList.TestGroupID,I);
         }
         //LStat := stJournal;
         Lbase := TreeList.FindGroupID (grp_Journals);
         if assigned(lBase) then
            CurParentNode := Lbase.Node
         else
            CurParentNode := TreeList.AddNodeItem(nil, TCHPBaseItem.Create(FTheClient,'Journals',grp_Journals));

         for I := FTheClient.clBank_Account_List.First to FTheClient.clBank_Account_List.Last do
            AddAccount(FTheClient.clBank_Account_List.Bank_Account_At(I),
                [btCashJournals,btAccrualJournals,btGSTJournals,btStockJournals],
                grp_Journal);

         // Add them as blanks if they do not exist
         I :=  btCashJournals;
         if not assigned(TreeList.FindItem(TreeList.TestAccountType,i)) then
            TreeList.AddNodeItem(CurParentNode,TCHEmptyJournal.Create(FTheClient,I,btNames[I],grp_Journal));
         I :=  btAccrualJournals;
         if not assigned(TreeList.FindItem(TreeList.TestAccountType,i)) then
            TreeList.AddNodeItem(CurParentNode,TCHEmptyJournal.Create(FTheClient,I,btNames[I],grp_Journal));

         ClientTree.Expanded[CurParentNode] := True;

         // GST/Tax
         if (FTheClient.clFields.clGST_Period <> 0)
         and (FTheClient.clFields.clGST_Start_Month <> 0) then begin

            LBase := TreeList.FindGroupID(grp_Taxes);
            if assigned(lBase) then
               CurParentNode := Lbase.Node
            else // Nothing to refresh ...
               CurParentNode := TreeList.AddNodeItem(nil,TCHPBaseItem.Create(FTheClient, FTheClient.TaxSystemNameUC, grp_Taxes ));

            TreeList.RemoveItems (TreeList.TestGST,I{Dummy});

            case FTheClient.clFields.clCountry of
              whNewZealand : begin
                  if (FTheClient.clFields.clGST_Period <> 0)
                  and (FTheClient.clFields.clGST_Start_Month <> 0) then
                     TreeList.AddNodeItem(CurParentNode,TCHGSTPeriodItem.Create(FTheClient));
                end;
              whAustralia  : AddAUGst;
              whUK : begin
                  if (FTheClient.clFields.clGST_Period <> 0)
                  and (FTheClient.clFields.clGST_Start_Month <> 0) then
                     TreeList.AddNodeItem(CurParentNode,TCHVATPeriodItem.Create(FTheClient));
                end;
            end;
            ClientTree.Expanded[CurParentNode] := True;
         end else begin
            TreeList.RemoveItems (TreeList.TestGST,I{Dummy});
            I := grp_Taxes;
            TreeList.RemoveItems ( TreeList.TestGroupID, I);
         end;

         {
         Lbase := TreeList.FindGroupID (0);
         if assigned(lBase) then
            LBase.Refresh
         else
            TreeList.AddNodeItem(nil, TCHReportPeriodItem.Create(FTheClient));
         }

         // Finacial Ballances..
         // Only if we have any...
         CurParentNode := nil;
         I := grp_Financials;
         TreeList.RemoveItems (TreeList.TestGroup,I);
         I := grp_Financial;
         TreeList.RemoveItems (TreeList.TestGroup,I);

         for I := FTheClient.clBank_Account_List.First to FTheClient.clBank_Account_List.Last do
            AddAccount(FTheClient.clBank_Account_List.Bank_Account_At(I),
                  [btOpeningBalances,btYearEndAdjustments],
                  grp_Financial
            );

         Lbase := TreeList.FindGroupID (grp_Financial);
         if assigned(LBase) then begin

            Lbase := TreeList.FindGroupID (grp_Financials);
            if not assigned(lBase) then
               TreeList.AddNodeItem(nil, TCHPBaseItem.Create(FTheClient,'Financial Year',grp_Financials));
         end;

         RefreshCodingPeriod;
         {
          // Butget
         ANode := ClientTree.AddChild(nil);
         MStat := TCHPCodingStatItem.Create(FTheClient,TreeList.FillDate,stBlank);
         MStat.Title := 'Budgets';
         SetNodeItem(ANode,MStat,ClientTree);
         }
      end;

      with ClientTree.Header do
          ClientTree.SortTree( SortColumn, SortDirection);

      Reselect;


   finally
      ClientTree.EndUpdate;
   end;
    if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshCoding');
end;

procedure TfrmClientHomePage.RefreshExchangeRates;
var
  LExchangeRates: TExchangeRateList;
begin
  if not Assigned(TheClient) then
    Exit;

  if Assigned(AdminSystem) then begin
    //Books Secure Client file exchange rates do not get updated 
    if TheClient.HasForeignCurrencyAccounts and (TheClient.clFields.clDownload_From = dlAdminSystem) then begin
      LExchangeRates := GetExchangeRates;
      try
        TheClient.ExchangeSource.Assign(LExchangeRates.FindSource('Master'));
        ApplyDefaultGST(False);
      finally
        LExchangeRates.Free;
      end;
    end;
  end;
end;

procedure TfrmClientHomePage.FormActivate(Sender: TObject);
begin
  frmMain.mniFileExchangeRates.Visible := TheClient.HasForeignCurrencyAccounts;
   if not FClosing then
       RefreshRequest := [HPR_Coding];
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MINIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_RESTORE,
                  MF_BYCOMMAND or MFS_GRAYED );
  EnableMenuItem( GetSystemMenu( handle, False ),
                  SC_MAXIMIZE,
                  MF_BYCOMMAND or MFS_GRAYED );
end;

procedure TfrmClientHomePage.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if not FClosingClient then
  begin
    FClosingClient := True;
    if not FAbandon then
      CloseClient( True, False);
    RefreshClientManager;
    Action := caFree;
    exit;
  end;
  FClosing := True;
  Action := caFree;
end;

procedure TfrmClientHomePage.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := True;
  FClosing := True;
end;

procedure TfrmClientHomePage.FormCreate(Sender: TObject);
var I,lw : Integer;
const
   NoSelection : TGridRect = (Left:-1; Top:-1; Right:-1; Bottom:-1 );


begin
   bkXPThemes.ThemeForm(Self);
   BKHelpSetUp(self, BKH_The_Client_Home_Page);
   FClosing := True;
   FClosingClient := False;
   FShowLegend := True; // Visible by default..
   ShowLegend := UserINI_CM_ShowLegend;
   if UserINI_HP_GroupWidth > 0 then
       gbGroupbar.Width := UserINI_HP_GroupWidth;

   for lw := Low(UserINI_HP_Column_Widths) to high(UserINI_HP_Column_Widths) do begin
     if UserINI_HP_Column_Widths[lw] > 0 then
        ClientTree.Header.Columns[lw].Width := UserINI_HP_Column_Widths[lw];
   end;

   MaxMinDate := IncDate(MinValidDate -1, 0, 0, 1);


   sgLegend.ColWidths[0] := 0;//80;
   sgLegend.ColWidths[1] := 0;//80;
   lw := Sglegend.Canvas.TextWidth('Available') + 15;
   for I := 2 to 13 do
      if odd(I) then
         sgLegend.ColWidths[I] := lw // Text
      else
         sgLegend.ColWidths[I] := 23;
   sgLegend.ColWidths[13] := lw + 15;

   sgLegend.Selection := NoSelection;
   ClientTree.DefaultNodeHeight := lLedHeight;
   TreeList := TCHPBaseList.Create(ClientTree,fTheClient);
   TreeList.LEDWidth := lLedWidth;
   TreeList.LEDHeight := lLedHeight;
   TreeList.FillDate := CurrentDate;
   //TreeList.DetailGroup := DetailsGroup;
   TreeList.NodePopup :=  pmNodes;
   //TreeList.DetailActions := DetailActions;
   //ClientTree.StateImages := AppImages.Maintain;
   //imgLeft.Picture := frmMain.imgLogo.Picture;

   PnlTitle.GradientColorStart := bkBranding.TobBarStartColor;
   PnlTitle.GradientColorStop  := bkBranding.TopBarStopColor;
   lblClientName.Font.Color :=  TopTitleColor;
   imgLeft.Picture := AppImages.ImgLogo.Picture;

   if frmMain.UsingCustomPracticeLogo then begin
      imgRight.AutoSize := False;
      imgRight.Stretch := True;
      imgRight.Picture := frmMain.imgPracticeLogo.Picture;
      imgRight.Transparent := False;
      imgRight.Width := frmMain.imgPracticeLogo.Width;
      PnlTitle.Height := Max (imgLeft.Height ,  frmMain.imgPracticeLogo.Height);
   end else begin
      imgRight.Transparent := True;
      imgRight.Picture := bkBranding.ClientBanner;
      PnlTitle.Height := bkBranding.ClientBanner.Height;
   end;

   lblClientName.Font.Name := Self.Font.Name;
   lw := (LLEDWidth * 12) + (BtnWidth * 2) + 4;
   ClientTree.Header.Columns.Items[1].Width := lw;
   //GBGroupBar.GradientColorStop := MainFormBackgroundColor;
   GBGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
   GBGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;

   ClientTree.Header.Font := self.Font;
   ClientTree.Header.Height := MonthHeight * 2 + 4;
   FClosing := False;
   FAbandon := False;
   RegisterWebNotesUpdate(Self.Handle);
end;

procedure TfrmClientHomePage.FormDestroy(Sender: TObject);
var I : Integer;
begin
  UnRegisterWebNotesUpdate(Self.Handle);

  OutputDebugString( 'TfrmClientHomePage.FormDestroy' );
  for I := Low(UserINI_HP_Column_Widths) to high(UserINI_HP_Column_Widths) do begin
     if I < ClientTree.Header.Columns.Count then
        UserINI_HP_Column_Widths[I] := ClientTree.Header.Columns[I].Width;
  end;
  ClientTree.Clear;
  TreeList.Free;
  UserINI_HP_GroupWidth := gbGroupbar.Width;
  FClientHomePage := NIL;
end;




procedure TfrmClientHomePage.FormShow(Sender: TObject);
begin
  try
     
     ClientTree.SetFocus;

  except
  end;
end;

function TfrmClientHomePage.GetAbandon: boolean;
begin
  result := FAbandon;
end;

function TfrmClientHomePage.GetRefreshRequest: THP_Refresh;
begin
  result := FRefreshRequest;
end;

function TfrmClientHomePage.GetTheClient: TClientObj;
begin
   result := FTheClient;
end;

procedure TfrmClientHomePage.NotesTimerTimer(Sender: TObject);
begin
  if ShowClientNotesOnOpen then begin
     // Turn it all off ...
     ShowClientNotesOnOpen := False;
     NotesTimer.Enabled := False;
     // Show the notes..
     ClientNotesFrm.ShowClientNotes;
  end;
end;

procedure TfrmClientHomePage.Lock;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Lock');
  inc(FLockCount);
end;

procedure TfrmClientHomePage.ProcessExternalCmd(Command: TExternalCmd);
begin
   if not FClosing then
      RefreshRequest := [HPR_Coding]; // Should Check the command...
end;

procedure TfrmClientHomePage.RefreshClient;
 var S: string;
     Item: TRzGroupItem;
     I: Integer;


   procedure AddToString ( Value : string);
   begin
      if Value = '' then exit;
      if S <> '' then
         S  := S + #10;
      S  := S + Value;
   end;

   procedure AddDetail (Value : string; Prefix : string = '');
   begin
      if Value > ' ' then
         gpClientDetails.Items.Add.Caption :=
           StringReplace(Prefix + Value, '&', '&&', [rfReplaceAll]);
   end;



begin //called when the client details change
   if FClosing then exit;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshClient');
   lblClientName.Caption := FTheClient.clExtendedName;
   TreeList.Client := FtheClient;

   gpClientDetails.Items.BeginUpdate;
   try
      gpClientDetails.Items.Clear;
      AddDetail(FTheClient.clExtendedName);
      // Update the Madexcept Details
      if not Assigned(AdminSystem) then begin
         MadAddEmailBodyValue('CL-Practice-Code',FtheClient.clFields.clPractice_Code);
         MadAddEmailSubjectValue('CL-Practice-Code',FtheClient.clFields.clPractice_Code);
         MadAddEmailBodyValue('CL-Practice-Name',FtheClient.clFields.clPractice_Name);
         MadAddEmailBodyValue('CL-Practice-Email',FtheClient.clFields.clPractice_EMail_Address);
      end;
      MadAddEmailBodyValue('Last-Client-Code',FtheClient.clFields.clCode);
      MadAddEmailBodyValue('Last-Client-Name',FtheClient.clFields.clName);

      //Addresss
      S := '';
      AddToString(FtheClient.clFields.clAddress_L1);
      AddToString(FtheClient.clFields.clAddress_L2);
      AddToString(FtheClient.clFields.clAddress_L3);
      AddDetail(S);
      // Contact
      s := FtheClient.clFields.clContact_Name;
      if s > '' then begin
         if FTheClient.clFields.clSalutation > ''  then
           S := FTheClient.clFields.clSalutation + ' ' + S;
         AddDetail('Cn: ' + S);
      end;
      // Phone numbers
      AddDetail (FTheClient.clFields.clPhone_No, 'Ph: ');
      AddDetail (FTheClient.clFields.clFax_No,   'Fx: ');
      AddDetail (FTheClient.clFields.clMobile_No,'Mb: ');

      // Email
      S := FtheClient.clFields.clClient_EMail_Address;
      if (S <> '') then begin
         S := StringReplace(S, '&', '&&', [rfReplaceAll]);
         Item := gpClientDetails.Items.Add;
         if (not Globals.CurrUser.HasRestrictedAccess) then begin
            Item.Action  := acClientEmail;
            acClientEmail.Caption := S;
         end else
            Item.Caption := S;
      end;

      AddDetail ('-');
      // add Edit Client dedails
      Item := gpClientDetails.Items.Add;
      Item.Action := acEditClientDetails;


      // Add the notes
      s := '';
      for I := Low(FTheClient.clFields.clNotes)
      to High(FTheClient.clFields.clNotes) do
         if FTheClient.clFields.clNotes[I] > '' then begin
            if S > '' then s := S + #10;
            S := S + FTheClient.clFields.clNotes[I];
         end;

      if length (S) > 255 then
         S := copy(S,1,255) + '...';

      if S > '' then S := 'Notes: ' + S
      else  S := 'Notes';

      acNotes.Caption := StringReplace(S, '&', '&&', [rfReplaceAll]);

      AddDetail ('-');
      Item := gpClientDetails.Items.Add;
      Item.Action := acNotes;



   finally
      gpClientDetails.Items.EndUpdate;
   end;

   // While we are here..
   if Globals.CurrUser.HasRestrictedAccess
   or ( not assigned (adminSystem)) then begin
      GrpReportSchedule.Visible := False
   end else with FtheClient.clFields do begin
      if clReporting_Period in [roMin + 1..roMax] then begin
         if clBusiness_Products_Scheduled_Reports then begin
            if clBusiness_Products_Report_Format in [ bpMin.. bpMax] then
               S := bpNames[clBusiness_Products_Report_Format]
            else
               S := 'Business Product'
         end else if clCheckOut_Scheduled_Reports then
            S := 'Check Out and E-Mail'
         else if clEmail_Scheduled_Reports then begin
            if clEmail_Report_Format in [rfMin.. rfMax] then
               S := 'E-Mail ' + rfNames[clEmail_Report_Format]
            else S := 'E-Mail'
         end else if clWebX_Export_Scheduled_Reports then
            S := 'Web File'
         else if clCSV_Export_Scheduled_Reports and Globals.PRACINI_CSVExport then
            S := 'CSV File'
         else if clECoding_Export_Scheduled_Reports then
            S := 'BNotes File'
         else if clFax_Scheduled_Reports then
            S := 'Fax'
         else S := 'Print';
         acSchedule.Caption := S + #10 + roNames[clReporting_Period];
      end else
         acSchedule.Caption := 'Set up a Report Schedule';
      GrpReportSchedule.Visible := True;
   end;

   if FTheClient.clFields.clWeb_Export_Format =  wfWebNotes then
       CheckAvailableWebNotesData;

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshClient');
end;


procedure TfrmClientHomePage.RefreshFiles;
begin
  fBadForexFileName := '';
  fBadForexCurrencyCode := '';
  fBadForexAccountCode := '';

   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshFiles');
   if assigned (FTheClient) then begin
      if FtheClient.clFields.clFile_Read_Only then begin
         acUpdate.Visible := False;
         AcWebImport.Visible := False;
         acTransfer.Visible := False;
      end else begin
         case FTheClient.clFields.clDownload_From of
         dlFloppyDisk : begin
                 acUpdate.Caption := 'Update from Floppy';
                 acUpdate.Visible := True;
              end;
         dlBankLinkConnect : if Assigned(AdminSystem) then begin
                 acUpdate.Visible := False;
                 // Don't want to download secure in practice
              end else begin
                 acUpdate.Caption := 'Download new Data';
                 acUpdate.ImageIndex := 32;
                 acUpdate.Visible := True;
              end;

         dlAdminSystem : if Assigned(AdminSystem) then
              if (not FtheClient.clFields.clSuppress_Check_for_New_TXns)
              and (FtheClient.clFields.clMagic_Number = AdminSystem.fdFields.fdMagic_Number)
              and NewDataAvailable(FtheClient) then
              begin { There is new data available }
//                If FtheClient.HasForeignCurrencyAccounts then
//                Begin
//                  if HasRequiredForexSources( FTheClient, fBadForexCurrencyCode, fBadForexAccountCode ) then
//                  Begin
//                    If HasNewEntriesWithDatesOutsideTheCurrentForexDataRange( FTheClient, AdminSystem, fBadForexCurrencyCode, fBadForexFileName ) then
//                    Begin
//                      acForexRates.Visible := True;
//                      acForexRates.Caption := Format( 'Before you can retrieve new transaction data, please update the foreign currency conversion rates for %s in the file %s',
//                        [ fBadForexCurrencyCode, fBadForexFilename ] );
//                      acUpdate.Visible := False;
//                    End
//                    else
//                    Begin
//                      acUpdate.Caption := 'There are new transactions available';
//                      acUpdate.Visible := True;
//                    End;
//                  End
//                  Else
//                  Begin
//                    acForexSources.Caption := Format( 'Please specify a foreign currency conversion source for %s, account %s',
//                      [ fBadForexCurrencyCode, fBadForexAccountCode ] );
//                    acForexSources.Visible := True;
//                    acUpdate.Visible := False;
//                  End;
//                End
//                Else
//                Begin
                acUpdate.Caption := 'There are new transactions available';
                acUpdate.Visible := True;
//                End;
              end else begin
                 acUpdate.Visible := False;
              end
             else // No Admin ??
                 acUpdate.Visible := False;
         else //Case.. What then...
             acUpdate.Visible := False;
         end;

         case FTheClient.clFields.clWeb_Export_Format of
            wfWebX: if IsWebFileWaiting then begin
                       AcWebImport.Caption := format('Import %s file',[WebXDisplayName]);
                       AcWebImport.Visible := True;
                    end else
                       AcWebImport.Visible := False;

            wfWebNotes: begin
                       AcWebImport.Caption := WebNotesUpdateText;
                       AcWebImport.Visible := AcWebImport.Caption > '';
                    end;

            else AcWebImport.Visible := False;
         end;
      end;
   end else begin
     acUpdate.Visible := False;
     AcWebImport.Visible := False;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshFiles');
end;

procedure TfrmClientHomePage.RefreshMissingExchangeRateMsg;
const
  MISSING_EXCHANGE_RATES = 'There are entries without exchange rates for ';
var
  ISOCodes: string;
begin
  ISOCodes := '';
  acForexRatesMissing.Visible := False;

  //Only Books Secure users should get the missing exchange rates prompt
  if (not Assigned(AdminSystem)) and (TheClient.clFields.clDownload_From = dlAdminSystem) then
    Exit;

  if not TheClient.HasExchangeRates(ISOCodes) then begin
    acForexRatesMissing.Caption := MISSING_EXCHANGE_RATES + ISOCodes;
    acForexRatesMissing.Visible := True;
  end;
end;

procedure TfrmClientHomePage.RefreshMems;

  function  MemsWrong: Boolean;
  var A,I,J : Integer;
  begin
     Result := True;
     with fTheClient do
     for A := clBank_Account_List.First to clBank_Account_List.Last do
        with clBank_Account_List.Bank_Account_At(A) do
        for I := baMemorisations_List.First to baMemorisations_List.Last do
           with baMemorisations_List.Memorisation_At(I) do
           for J := mdLines.First to mdLines.Last do
              with mdLines.MemorisationLine_At(J)^ do
              if mlAccount <> '' then
                 if FTheClient.clChart.FindCode(mlaccount) = nil then
                      exit;
     // Still Here...
     Result := False; // All OK..
  end;

begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshMems');
   if MemsWrong then begin
      acMems.Visible := True;
   end else begin
      acMems.Visible := False;   
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshMems');
end;

procedure TfrmClientHomePage.RefreshTodo;
   function CheckAdmin : Boolean;
   var  ClientsToDoList : TClientToDoList;
        sysClientRec  : pClient_File_Rec;
        i,Open,OverDue  : integer;
        Today: Integer;
        S: string;
   begin
      Result := False;
      {$B-}

      if Globals.CurrUser.HasRestrictedAccess then exit;
      if Assigned(AdminSystem) then begin
         sysClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(FTheClient.clFields.clCode);
         if not Assigned(sysClientRec) then
            Exit;

         ClientsToDoList := TClientToDoList.Create(sysClientRec^.cfLRN);
         try
            Open := 0;
            OverDue := 0;//
            Today := CurrentDate;
            for i := 0 to ClientsToDoList.Count - 1 do
               with ClientsToDoList.ToDoItemAt( i)^ do
                  if ( not tdTemp_Deleted)
                  and (tdDate_Completed = 0) then begin
                     if (tdReminderDate >= Today)
                     or (tdReminderDate = 0) then
                        Inc(Open)
                     else
                        inc(OverDue);
                  end;

            if OverDue > 0 then begin
               if Overdue = 1 then
                  S := 'There is 1 Task overdue'
               else
                  S := 'There are ' + IntToStr(OverDue) + ' Tasks overdue';

            end else if Open > 0 then begin
               if Open = 1 then
                  S := 'There is 1 Task due'
               else
                  S := 'There are ' + IntToStr(Open) + ' Tasks due';
            end else
               S := 'Tasks';

            acTasks.Caption := S;
            Result := True;
         finally
            ClientsToDoList.Free;
         end;
      end;
   end;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter RefreshToDo');
   acTasks.Visible := CheckAdmin;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit RefreshToDo');
end;

procedure TfrmClientHomePage.SetAbandon(const Value: Boolean);
begin
  FAbandon := Value;
end;

procedure TfrmClientHomePage.SetRefreshRequest(const Value: THP_Refresh);
begin
  FRefreshRequest := FRefreshRequest + Value;
  if FLockCount = 0 then
     UpdateRefresh;

  if ShowClientNotesOnOpen then
     NotesTimer.Enabled := True;
end;

procedure TfrmClientHomePage.SetShowLegend(const Value: Boolean);

begin
  if FClosing then
     Exit;

  if FShowLegend <> Value then begin
     FShowLegend := Value;
     if FShowLegend then begin
        acShowLegend.ImageIndex := 21;
        pnlLegend.Visible := True;
     end else begin
        acShowLegend.ImageIndex := 22;
        pnlLegend.Visible := False;
     end;
     UserINI_CM_ShowLegend := FShowLegend;
  end;
end;

procedure TfrmClientHomePage.SetTheClient(const Value: TClientObj);
begin
  if FClosing then exit;
  FTheClient := Value;

  if assigned(FtheClient) then begin
     RefreshRequest := [HRP_Init];
     Self.Visible := True;
  end else begin
     FClosing := True;
     Self.Close;
  end;

end;


procedure TfrmClientHomePage.sgLegendDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);

  procedure DrawCellImgLED( const LEDColor : Integer );
  var R : TRect;
  begin
    R := sgLegend.CellRect(ACol, ARow);
    //R.Right := R.Left + ( R.Bottom - R.Top ) ; { Square at LH End }
    InflateRect( R, -6, -4 ) ; { Make it Smaller }
    sgLegend.Canvas.Brush.Color := LEDColor;
    sgLegend.Canvas.Pen.Color := clBtnShadow;
    sgLegend.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, ProcessCornerRadius, ProcessCornerRadius);
  end;

  procedure DrawCentreText(S: string);
  begin
    DrawText(sgLegend.Canvas.Handle, PChar(S), -1, Rect, DT_SINGLELINE or DT_VCENTER or DT_LEFT);
  end;

begin //TfrmClientHomePage.sgLegendDrawCell
 case ACol of
    //0: DrawCellFill(ColorCodingPeriod,'Coding Period' );
    //1: DrawCellFill(ColorFinancialYear,'Financial Year');
    2: DrawCellImgLED(ColorNoData );
    3: DrawCentreText('No Data');
    4: DrawCellImgLED(ColorDownloaded );
    5: DrawCentreText('Available');
    6: DrawCellImgLED(ColorUncoded );
    7: DrawCentreText('Uncoded');
    8: DrawCellImgLED(ColorCoded );
    9: DrawCentreText('Coded');
    10: DrawCellImgLED(ColorFinalised );
    11: DrawCentreText('Finalised');
    12: DrawCellImgLED(ColorTransferred );
    13: DrawCentreText('Transferred');

  end;
end;

procedure TfrmClientHomePage.sgLegendSelectCell(Sender: TObject; ACol,
  ARow: Integer; var CanSelect: Boolean);
begin
   ClientTree.SetFocus;
end;

procedure TfrmClientHomePage.Unlock;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'UnLock');
   Dec(FLockCount);
   if FLockCount = 0 then
      UpdateRefresh;

end;

procedure TfrmClientHomePage.UpdateActions;
   function ProcessInVisible : Boolean;
   var I: integer;
   begin
     Result := True;
     for I := 0 to ClientTree.Header.Columns.Count - 1 do
        if ClientTree.Header.Columns[I].Tag = Ord(CHPT_Processing) then begin
            // Found the column
            Result := (ClientTree.Header.Columns[I].Left > ClientTree.Width)
                   or (ClientTree.Header.Columns[I].Left + ClientTree.Header.Columns[I].Width < 0)
        end;
   end;
begin
  inherited;

   if BtnYearRight.Visible then
      if ProcessInVisible then begin
         BtnYearRight.Visible := False;
         BtnYearLeft.Visible := False;
         BtnMonthRight.Visible := False;
         BtnMonthLeft.Visible := False;
      end;


end;

procedure TfrmClientHomePage.UpdateRefresh;
var kc: TCursor;
       KeepTop: Integer;
begin
   if not Assigned(FTheClient) then
      Exit;
   if FClosing then
      Exit;
   if FRefreshRequest = [] then
      Exit;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter UpdateRefresh');
   kc := Screen.Cursor;
   KeepTop := GrpAction.Top;
   gbGroupBar.BeginUpdateLayout;
   Screen.Cursor := crHourGlass;
   try
      // Something to refresh..
      if ([HRP_Init,HPR_Coding,HPR_Files] * FRefreshRequest) <> [] then
         RefreshCoding;

      if ([HRP_Init,HPR_Client] * FRefreshRequest) <> [] then
         RefreshClient;

      if ([HRP_Init,HPR_Tasks] * FRefreshRequest) <> [] then
         RefreshToDo;

      if ([HRP_Init,HPR_Files] * FRefreshRequest) <> [] then
         RefreshFiles;

      if HRP_Init in FRefreshRequest then begin
         if (Self.WindowState = wsMinimized) then
            ShowWindow(Self.Handle, SW_RESTORE);
         Self.BringToFront;
      end;

      FRefreshRequest := [];
   finally
      Screen.Cursor := kc;

      gbGroupBar.EndUpdateLayout;
      if KeepTop <> GrpAction.Top then
         gbGroupBar.ScrollPosition := gbGroupBar.ScrollPosition + ( GrpAction.Top - KeepTop)
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit UpdateRefresh');
end;

procedure TfrmClientHomePage.acRunCodingExecute(Sender: TObject);
var DR : TRangeCount;
begin
   Lock;
   frmMain.Enabled := False;
   with TdlgModalProcessor.Create(nil)do
   try
      Show;
      CloseAllCodingForms;
      Dr := TreeList.CodingMonths;
      if Dr.Range.FromDate <> Dr.Range.ToDate then
         TreeList.CodeRange(Dr);
   finally
      Free;
      frmMain.Enabled := True;
      Unlock;
   end;
   frmMain.ActiveFormChange(self); // Should not need this...
                                   // But somehow when there is only one.
                                   // the toolbar is not instep..
end;

procedure TfrmClientHomePage.acScheduleExecute(Sender: TObject);
begin
   SetupClientSchedule(FTheClient, BKH_Scheduled_Reports);
end;

procedure TfrmClientHomePage.acShowlegendExecute(Sender: TObject);
begin
   Showlegend := not  Showlegend;
end;

procedure TfrmClientHomePage.acClientEmailExecute(Sender: TObject);
var
  unused: Boolean;
begin
  MailFrm.SendFileTo( 'Send Mail', acClientEmail.Caption, '', '', unused);
end;

procedure TfrmClientHomePage.acEditClientDetailsExecute(Sender: TObject);
begin
   lock;
   try
      frmMain.DoMainFormCommand( mf_mcClientDetails);
   finally
      Unlock;
   end;
end;

procedure TfrmClientHomePage.acForexRatesMissingExecute(Sender: TObject);
begin
  ApplicationUtils.DisableMainForm;
  try
    AutoSaveUtils.DisableAutoSave;
    try
      //Inc lock count
      Lock;
      try
        //Edit exchange rates
        if MaintainExchangeRates then begin
          RefreshExchangeRates;
          //Reload transactions
          SendCmdToAllCodingWindows(ecReloadTrans);
        end;
      finally
        UnLock;
      end;
    finally
      if not Globals.ApplicationIsTerminating then
        AutoSaveUtils.EnableAutoSave;
    end;
  finally
    ApplicationUtils.EnableMainForm;
  end;
end;

procedure TfrmClientHomePage.acHelpExecute(Sender: TObject);
begin
   BKHelpShow(Self);
end;

procedure TfrmClientHomePage.acMemsExecute(Sender: TObject);
begin
    frmMain.DoMainFormCommand(mf_mcMaintainMems);
end;

procedure TfrmClientHomePage.acNotesExecute(Sender: TObject);
begin
   Lock;
   try
     frmMain.DoMainFormCommand(mf_mcClientNotes);
   finally
      Unlock;
   end;
end;


procedure TfrmClientHomePage.acReportExecute(Sender: TObject);
begin
  DoHomeReport(rdAsk, TreeList);
end;

procedure TfrmClientHomePage.acReportsExecute(Sender: TObject);
begin
   frmMain.mniBatchReportsClick(Self);
end;

procedure TfrmClientHomePage.acTasksExecute(Sender: TObject);
begin
   lock;
   try
      frmMain.DoMainFormCommand(mf_mcDoTasks);
   finally
      Unlock;
   end;
end;

procedure TfrmClientHomePage.acTransferExecute(Sender: TObject);
var lr : TRangeCount;


procedure LockMainForm;
begin
   ApplicationUtils.DisableMainForm;
   AutoSaveUtils.DisableAutoSave;
end;

function UnLockmainForm:Boolean;
begin
   Result := ApplicationUtils.EnableMainForm;
   if not Globals.ApplicationIsTerminating then
       AutoSaveUtils.EnableAutoSave;
end;

begin
   lr := TreeList.TransferMonths;
   LockMainForm;
   Lock;
   try
      ExtractData(Lr.Range.FromDate,Lr.Range.ToDate);
      SendCmdToAllCodingWindows(ecReloadTrans);
   finally
      UnlockMainform;
      UnLock;
   end;
end;

procedure TfrmClientHomePage.acUpdateExecute(Sender: TObject);
begin
    if not assigned(TheClient) then Exit;
    lock;
    try
       case TheClient.clFields.clDownload_From of
          dlFloppyDisk : ModalProcessorDlg.DoModalCommand(mpcDoDownloadFromFloppy);
          dlBankLinkConnect : ModalProcessorDlg.DoModalCommand(mpcDoOffsiteDownload);

          dlAdminSystem : begin
             MergeNewDataYN(TheClient, False, False, False);
             RefreshRequest := [HPR_Files, HPR_Coding];
          end;
       end;
    finally
       Unlock;
    end;
end;

procedure TfrmClientHomePage.acWebImportExecute(Sender: TObject);
var FileName : string;
begin
   if not assigned(TheClient) then
      Exit;

   Lock;
   try
      case FTheClient.clFields.clWeb_Export_Format of
         wfWebX: begin
            FileName := '';
            ImportECodingFileFromFile(fTheClient, FileName,true, ecDestWebX);
         end;
         wfWebNotes: begin
            acWebImport.Caption := ImportWebNotesFile(fTheClient);
            acWebImport.Visible := acWebImport.Caption > '';
         end;
      end;
   finally
      Unlock;
   end;
end;

procedure TfrmClientHomePage.btnMonthLeftClick(Sender: TObject);
var ldate : Integer;
begin
   ldate :=  IncDate(TreeList.FillDate, 0, -1, 0);
   if ldate <= MaxMindate then begin
      Ldate := MaxMindate;
      btnMonthLeft.Enabled := False;
      btnYearLeft.Enabled := False;
   end;
   btnMonthRight.Enabled := True;
   btnYearRight.Enabled := True;
   TreeList.FillDate :=ldate;
   Refreshrequest := [HPR_Coding];
end;


procedure TfrmClientHomePage.btnMonthRightClick(Sender: TObject);
var ldate : Integer;
begin
   ldate :=  IncDate(TreeList.FillDate, 0, 1, 0);
   if ldate >= MaxValidDate then begin
      Ldate := MaxValidDate;
      btnMonthRight.Enabled := False;
      btnYearRight.Enabled := False;
   end;
   btnMonthLeft.Enabled := True;
   btnYearLeft.Enabled := True;
   TreeList.FillDate :=ldate;
   Refreshrequest := [HPR_Coding];
end;

procedure TfrmClientHomePage.btnYearLeftClick(Sender: TObject);
var ldate : Integer;
begin
   ldate :=  IncDate(TreeList.FillDate, 0, 0, -1);
   if ldate <= MaxMindate then begin
      Ldate := MaxMindate;
      btnMonthLeft.Enabled := False;
      btnYearLeft.Enabled := False;
   end;
   btnMonthRight.Enabled := True;
   btnYearRight.Enabled := True;
   TreeList.FillDate :=ldate;
   Refreshrequest := [HPR_Coding];
end;

procedure TfrmClientHomePage.BtnYearRightClick(Sender: TObject);
var ldate : Integer;
begin
   ldate :=  IncDate(TreeList.FillDate, 0, 0, 1);
   if ldate >= MaxValidDate then begin
      Ldate := MaxValidDate;
      btnMonthRight.Enabled := False;
      btnYearRight.Enabled := False;
   end;
   btnMonthLeft.Enabled := True;
   btnYearLeft.Enabled := True;
   TreeList.FillDate :=ldate;
   Refreshrequest := [HPR_Coding];
end;


procedure TfrmClientHomePage.ClientTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
//var
//  OldCol : TColumnIndex;
begin
  (*  // No sorting at this stage...
  if Button = mbRight then exit; // will show popup menu

  OldCol := ClientTree.Header.SortColumn;

  ClientTree.BeginUpdate;
  try

    if Column <> OldCol then begin
       ClientTree.Header.SortColumn           := Column;
       ClientTree.Header.SortDirection        := sdAscending;

       with ClientTree.Header do
          ClientTree.SortTree( SortColumn, SortDirection);
    end else begin
       //just reverse the direction as col hasn't changed
       if ClientTree.Header.SortDirection = sdAscending then
          ClientTree.Header.SortDirection := sdDescending
       else
          ClientTree.Header.SortDirection := sdAscending;

       with ClientTree.Header do
          ClientTree.SortTree( SortColumn, SortDirection);
    end;

  finally
    ClientTree.EndUpdate;
  end;
  *)
end;

procedure TfrmClientHomePage.ClientTreeHeaderDraw(Sender: TVTHeader;
  HeaderCanvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover,
  Pressed: Boolean; DropMark: TVTDropMarkMode);
var lbase : TTReeBaseItem;
    I : Integer;
begin
   Lbase := TreeList.FindItem(TreeList.TestYear,I{Dummy});
   // Cleanup the whole thing...


   if assigned(LBase) then
     lBase.AfterPaintCell(Column.Tag ,HeaderCanvas,R);


   btnMonthleft.Visible := true;
   BtnMonthRight.Visible := true;
   BtnYearLeft.Visible := true;
   BtnYearRight.Visible := true;
end;

procedure TfrmClientHomePage.ClientTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);

begin
   TreeList.OnKeyDown(Key,Shift);
   case Key of
   VK_RIGHT : if Assigned(ClientTree.FocusedNode) then begin
         btnMonthRightClick(nil);
         //TreeList.OnKeyDown(Key,Shift);
         Key := 0;
      end;
      
   VK_LEFT : if Assigned(ClientTree.FocusedNode) then begin
         btnMonthLeftClick(nil);
         //TreeList.OnKeyDown(Key,Shift);
         Key := 0;
      end;
   else inherited;
   end;
end;

procedure TfrmClientHomePage.wmsyscommand(var msg: TWMSyscommand);
begin
  if ((msg.CmdType and $FFF0) = SC_MINIMIZE) or
     ((msg.CmdType and $FFF0) = SC_RESTORE) then
    exit
  else
    inherited;
end;

procedure TfrmClientHomePage.UpdateTabs(ActionedPage: string = '');
var                                       
  i,x : Integer;
  s: string;
  l: TStringList;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Enter UpdateTabs');
  l := TStringList.Create;
  try
    tcWindows.TabIndex := -1;
    for i := Pred(tcWindows.Tabs.Count) downto 0 do
      tcWindows.Tabs.Delete(i);
    for i := 0 to Pred(frmMain.MDIChildCount) do
    begin
      if (frmMain.MDIChildren[i].Caption <> ActionedPage) and
         ((frmMain.MDIChildren[i] is TfrmCoding) or
          (frmMain.MDIChildren[i] is TfrmBudget)) then
      begin
        s := StringReplace(frmMain.MDIChildren[i].Caption, '&', '&&', [rfReplaceAll]);
        x := Pos('Code Entries', s);
        if x > 0 then
          s := Copy(s, 14, Length(s))
        else
        begin
          x := Pos('Edit Budget', s);
          if x > 0 then
            s := Copy(s, 13, Length(s));
        end;
        l.AddObject(s, frmMain.MDIChildren[i]);
      end;
    end;
    l.Sort;
    for i := 0 to Pred(l.Count) do
    begin
      with tcWindows.Tabs.Add do
      begin
        Caption := l.Strings[i];
        Tag := Integer(l.Objects[i]);
      end;
    end;
    pnlTabs.Visible := tcWindows.Tabs.Count > 0;
    tcWindows.TabIndex := -1;
  finally
    l.Free;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug,UnitName,'Exit UpdateTabs');
end;

procedure TfrmClientHomePage.UpdateWebNotes(var Msg: TMessage);
begin
   RefreshFiles;
end;

procedure TfrmClientHomePage.tcWindowsTabClick(Sender: TObject);
var
  obj : TObject;
begin
  obj := TObject(tcWindows.Tabs[tcWindows.TabIndex].Tag);
  if obj is TForm then
    TForm(obj).BringToFront;
end;

initialization
  DebugMe := DebugUnit(UnitName);
  FClientHomePage := nil;
finalization
  FreeAndNil(FClientHomePage);
end.


