unit frmAddReport;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, UBatchBase,
  OsFont;

type
  TReportNode = class(TObject)
  private
    FRptGUID: string;
    FRptID: integer;
    procedure SetRptGUID(const Value: string);
    procedure SetRptID(const Value: integer);
  published
  public
    property RptID: integer read FRptID write SetRptID;
    property RptGUID: string read FRptGUID write SetRptGUID;
  end;

  TAddReportFrm = class(TForm)
    tvMenu: TTreeView;
    btnCancel: TButton;
    btnOk: TButton;
    procedure tvMenuChange(Sender: TObject; Node: TTreeNode);
    procedure FormCreate(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure tvMenuDblClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure tvMenuKeyPress(Sender: TObject; var Key: Char);
    procedure tvMenuCollapsing(Sender: TObject; Node: TTreeNode;
      var AllowCollapse: Boolean);
    procedure FormDestroy(Sender: TObject);
  private
    FCountry: integer;
    FRptId: Integer;
    FRptGuid: string;
    procedure SetCountry(const Value: integer);
    procedure FillMenu;
    procedure SetRptId(const Value: Integer);
    procedure DoAdd;
    procedure LoadCustomDocs(ATreeNode: TTreeNode);
    procedure LoadCustomDoc(var AReport: TReportBase; ARptGUID: string);
    procedure SetRptGuid(const Value: string);
    procedure ClearTreeViewObjects;
    { Private declarations }
  public
    { Public declarations }
    property Country : integer read FCountry write SetCountry;
    property RptId : Integer read FRptId write SetRptId;
    property RptGuid : string read FRptGuid write SetRptGuid;
  end;


implementation


uses
   Winutils,
   uxTheme,
   graphDefs,
   VirtualTrees,
   //ReportNodes,
   Globals,
   BatchReportFrm,
   bkConst,
   ReportDefs, bkhelp, bkXPThemes, CountryUtils,
   CustomDocEditorFrm, OmniXML, OmniXMLUtils;
{$R *.dfm}



procedure TAddReportFrm.btnOkClick(Sender: TObject);
begin
   DoAdd;
end;

procedure TAddReportFrm.ClearTreeViewObjects;
var
  i: integer;
begin
  for i := 0 to Pred(tvMenu.Items.Count) do
    if Assigned(tvMenu.Items[i].Data) then
      TReportNode(tvMenu.Items[i].Data).Free;
end;

procedure TAddReportFrm.btnCancelClick(Sender: TObject);
begin
   ModalResult := mrCancel;
end;

procedure TAddReportFrm.DoAdd;
var LNewReport : TReportBase;
    s : string;
    ReportsForm : TfrmBatchReports;
    Node: PVirtualNode;
    ReportClient : TReportClient;


    function FindNodeClient (Frombatch :TReportClient) : TReportbase;
    var I: Integer;
    begin
       for I := 0 to Frombatch.List.Count - 1 do
          if sametext(Frombatch.Child[i].Title, MyClient.clFields.clCode) then begin
             Result := Frombatch.Child[i];
             Exit; // Bingo..
          end;
       // Did not Find it, Add it now..
       Result := FromBatch.AddChild(Nil,BatchReports);
       Result.Title := MyClient.clFields.clCode;
    end;

begin
   if RptId < 0 then
      Exit;
   ReportsForm := TfrmBatchReports(Owner);


   ReportClient := nil;
   Node := ReportsForm.ReportTree.GetFirstSelected;

   case ReportsForm.DlgMode of
      Nothing: Exit;
      ByClient: begin
         if not Assigned(Node) then
             Exit;
         case ReportsForm.getNodelevel(Node) of
            L_Client : Exit; // No Customers in the list...
            L_Report : Node := Node.Parent;
            L_Batch  : ;
            L_Setting : repeat
                  Node := Node.Parent;
                  if Not Assigned(Node) then
                          Exit;
                until (ReportsForm.getNodelevel(Node) = L_Batch)

            else Exit; // ??
          end;
          // So now Node should be the correct batch node...
          ReportClient := TReportClient(FindNodeClient (TReportClient(
              ReportsForm.ReportList.GetNodeItem( Node ))));
         end;// ByCustomer


      ByReport: begin
         Node := ReportsForm.ReportTree.RootNode;
         //can start with 'Nothing'
         if BatchReports.List.Count > 0 then begin
            LNewReport := BatchReports.Child[0];
         end else begin
            // Add the Base Batch
            LNewReport := BatchReports.AddChild(nil, BatchReports);
            LNewReport.Title := 'Reports';
            //LNewReport.Name  := 'Default';
            // Start at the Top
         end;
         ReportClient := TReportClient(LNewReport);// TReportClient(FindNodeClient (TReportClient(LNewReport)));

      end;
    end;

    if not Assigned(ReportClient) then
       Exit; // nowhere to put it..

   if (RptID = CUSTOM_DOC_BASE) then begin
     //Custom document
     LoadCustomDoc(LNewReport, RptGUID);
     if Assigned(LNewReport) then
       LNewReport.Saved := True;
   end else begin
      if (RptId >= GraphBase)  then //Graph
         if RptID < (GraphBase + Ord(Graph_Last)) then
            S := Graph_List_Names[GRAPH_LIST_TYPE(RptID-GraphBase)]
          else
            Exit
      else //Normal report
        s := Get_ReportText(RptId);
     LNewReport := TReportBase.Create;
     // setup some defaults
     LNewReport.Lock;
     LNewReport.Title := s;
     LNewReport.Createdby := Globals.CurrUser.Code;
     LNewReport.Createdon := Now;
     LNewReport.Name := BatchReports.NewName(Get_ReportName(RptID));
     LNewreport.Settings := BatchReports.Document.CreateElement('Settings');
      // Run the setup
     if  REPORT_LIST_TYPE(RptID) in
       [Report_BAS,
        Report_GST101,
        REPORT_BASSUMMARY,
        Report_GST372
       ]  then
        LNewReport.Saved := True
     else
        ReportsForm.SetupReport (LNewReport);
   end;

   if LNewReport.Saved then begin
      // Ok to add...
      // Link it in..
      LNewReport.Parent := ReportClient;
      ReportClient.List.Add(LNewReport);

      // Add to Tree...
      ReportsForm.ReportTree.Expanded[Node] := True;
      Node := ReportsForm.ReportList.AddNodeItem(node,LNewReport);

      ReportsForm.ReportTree.Selected[Node] := true;
      ReportsForm.ReportTree.FocusedNode := Node;

      LNewReport.Unlock;
      with ReportsForm.ReportTree, Header do
         SortTree(SortColumn, SortDirection);

      Self.ModalResult := mrOK;
   end else begin
       // Must have canceled;
      LNewReport.Free;
   end;
end;

procedure TAddReportFrm.FillMenu;
var CT : TTreeNode;
   FinancialReportsEnabled : Boolean;
   
   function  Addmenu (parent: TTreeNode; Title : string; LID : Integer):TTreeNode;
   var
      ReportNode: TReportNode;
   begin
      ReportNode := TReportNode.Create;
      ReportNode.RptID := LID;
      ReportNode.RptGUID := '';
      Result := tvMenu.Items.AddChildObject(Parent,Title,Pointer(ReportNode));
   end;

begin
  tvMenu.Items.BeginUpdate;
  try
    tvMenu.Items.Clear;
    Addmenu(nil,'Coding Report',Ord(Report_Coding));
    Addmenu(nil,'Ledger Report',Ord(Report_List_Ledger));

    FinancialReportsEnabled :=
      (Assigned(MyClient)  //Client File is open
        and MyClient.clExtra.ceBook_Gen_Finance_Reports //Allow Generate Financial REports
        and not Assigned(AdminSystem))  //Books User
        or
        (
        Assigned(MyClient)  //Client File is open
          and Assigned(AdminSystem) //Practice User
        );

{    FinancialReportsEnabled :=
      (Assigned(MyClient)
      and Assigned(AdminSystem) and Assigned(CurrUser) and CurrUser.CanAccessAdmin)
      or (Assigned(AdminSystem) and Assigned(CurrUser) and not(CurrUser.CanAccessAdmin)
      and MyClient.clExtra.ceBook_Gen_Finance_Reports);}

    if FinancialReportsEnabled then
    begin
      CT := Addmenu(nil,'Cash Flow Reports', -1 );
        Addmenu(CT,'1 Actual',Ord(Report_Cashflow_Act));
        Addmenu(CT,'2 Actual and Budget',Ord(Report_Cashflow_Actbud));
        Addmenu(CT,'3 Actual, Budget and Variance',Ord(Report_Cashflow_ActBudVar));
        Addmenu(CT,'4 12 Months Actual',Ord(Report_Cashflow_12Act));
        Addmenu(CT,'5 12 Months Budget',Ord(REPORT_BUDGET_12CASHFLOW));
        Addmenu(CT,'6 12 Months Actual or Budget',Ord(Report_Cashflow_12ActBud));
        Addmenu(CT,'7 From Date to Date',Ord(Report_Cashflow_Date));
        Addmenu(CT,'8 Budget Remaining',Ord(Report_Cashflow_BudRem));
        Addmenu(CT,'9 This Year, Last Year and Variance',Ord(Report_Cashflow_ActLastYVar));
        Addmenu(CT,'10 Custom',Ord(Report_Cashflow_Multiple));


      CT := Addmenu(nil,'Profit and Loss Reports',-1);
        Addmenu(CT,'1 Actual',Ord(REPORT_Profit_ACT));
        Addmenu(CT,'2 Actual and Budget',Ord(Report_Profit_ActBud));
        Addmenu(CT,'3 Actual, Budget and Variance',Ord(Report_Profit_ActBudVar));
        Addmenu(CT,'4 12 Months Actual',Ord(Report_Profit_12Act));
        Addmenu(CT,'5 12 Months Actual or Budget',Ord(Report_Profit_12ActBud));
        Addmenu(CT,'6 Custom',Ord(Report_ProfitandLoss_Single));

      Addmenu(nil,'Trial Balance',Ord(Report_TrialBalance));
      Addmenu(nil,'Balance Sheet',Ord(REPORT_BALANCESHEET_MULTIPLE));
    end;

    CT := Addmenu(nil,'Bank Reconciliation',-1);
      Addmenu(CT,'Summarised',Ord(Report_BankRec_Sum));
      Addmenu(CT,'Detailed',Ord(Report_BankRec_Detail));
      if assigned(MyClient)
      and MyClient.HasForeignCurrencyAccounts then
         Addmenu(CT,'Foreign Exchange',Ord(Report_Foreign_Exchange));
      Addmenu(CT,'List Unpresented Items',Ord(REPORT_UNPRESENTED_ITEMS));



    CT := Addmenu(nil, Localise(Country, 'GST Reports'), -1);

    case Country of
      whAustralia:
        begin
          Addmenu(CT,'Business/Instalment Activity Statements',Ord(Report_BAS));
          Addmenu(CT,'GST Audit Trail',Ord(Report_GST_Audit));
          Addmenu(CT,'GST Summary',Ord(Report_GST_Summary));
          Addmenu(CT,'GST Reconciliation',Ord(REPORT_GST_SUMMARY_12));
          Addmenu(CT,'GST Overrides',Ord(Report_GST_Overrides));
          Addmenu(CT,'Annual GST information report',ord(REPORT_BASSUMMARY));
          Addmenu(CT,'Annual GST Return',ord(Report_GST372));
          Addmenu(CT,'Business Norm Percentages',Ord(Report_GST_BusinessNorms));
        end;
      whNewZealand:
        begin
          Addmenu(CT,'GST Return', Ord(Report_GST101));
          Addmenu(CT,'GST Audit Trail',Ord(Report_GST_Audit));
          Addmenu(CT,'GST Summary',Ord(Report_GST_Summary));
          if PRACINI_PaperSmartBooks then
            Addmenu(CT,'GST Allocation Summary',Ord(Report_GST_AllocationSummary));
          Addmenu(CT,'GST Reconciliation',Ord(REPORT_GST_SUMMARY_12));
          Addmenu(CT,'GST Overrides',Ord(Report_GST_Overrides));
        end;
      whUK:
        begin
          Addmenu(CT,'VAT Return', Ord(Report_GST101));
          Addmenu(CT,'VAT Audit Trail',Ord(Report_GST_Audit));
          Addmenu(CT,'VAT Summary',Ord(Report_GST_Summary));
          Addmenu(CT,'VAT Overrides',Ord(Report_GST_Overrides));
        end;
    end;

    Addmenu(nil,'Spending by Payee',Ord(Report_Payee_Spending));
    Addmenu(nil,'Coding by Job',Ord(Report_Job_Summary));
    Addmenu(nil,'Exception Report',Ord(Report_Exception));


    //offsite download
    if (MyClient.clFields.clDownload_From <> dlAdminSystem) then begin
       Addmenu(nil,'Download Log Report',ord(REPORT_DOWNLOAD_LOG_OFFSITE));
    end;



    CT := Addmenu(nil,'Listings', -1);
       Addmenu(CT,'List Bank Accounts',Ord(Report_List_BankAccts));
       Addmenu(CT,'List Chart of Accounts',Ord(Report_List_Chart));
       Addmenu(CT,'List Divisions',Ord(Report_List_Divisions));
       Addmenu(CT,'List Jobs',Ord(Report_List_Jobs));
       Addmenu(CT,'List Entries',Ord(Report_List_Entries));

       Addmenu(CT,Localise(Country, 'List GST Details'),Ord(Report_List_GST_Details));
       Addmenu(CT,'List Journals',Ord(Report_List_Journals));
       Addmenu(CT,'List Memorisations',Ord(Report_List_Memorisations));
       Addmenu(CT,'List Missing Cheques', Ord(Report_Missing_Cheques));

       Addmenu(CT,'List Payees',Ord(Report_List_Payee));
       Addmenu(CT,'List Sub-groups',Ord(Report_List_SubGroups));

    CT := Addmenu(nil,'Graphs', -1);
       Addmenu(CT,'Sales',Ord(GRAPH_TRADING_SALES)+ GraphBase);
       Addmenu(CT,'Payments',Ord(GRAPH_TRADING_PAYMENTS)+ GraphBase);
       Addmenu(CT,'Trading Results',Ord(GRAPH_TRADING_RESULTS)+ GraphBase);
       Addmenu(CT,'Total Bank Balance',Ord(GRAPH_BANK_BALANCE)+ GraphBase);
       Addmenu(CT,'One Page Summary',Ord(GRAPH_SUMMARY)+ GraphBase);

    if Assigned(AdminSystem) then begin
      CT := Addmenu(nil,'Custom Documents', -1);
        LoadCustomDocs(CT);
    end;

   finally
      tvMenu.Items.EndUpdate;
   end;
end;

procedure TAddReportFrm.FormCreate(Sender: TObject);
begin
   bkXPThemes.ThemeForm(Self);
   SetVistaTreeView(TVmenu.Handle);
   BKHelpSetUp(Self, BKH_Adding_reports_to_the_Favourite_reports_list);
   Country := MyClient.clFields.clCountry;
   FillMenu;
end;

procedure TAddReportFrm.FormDestroy(Sender: TObject);
begin
  ClearTreeViewObjects;
end;

procedure TAddReportFrm.FormKeyPress(Sender: TObject; var Key: Char);
begin
   case ord(Key) of
     VK_ESCAPE : begin
        Key := #0;
        modalresult := mrCancel;
     end;
   end;
end;

procedure TAddReportFrm.LoadCustomDoc(var AReport: TReportBase; ARptGUID: string);
var
  CustomDoc: TReportBase;
  GUIDXmlNode: IXMLNode;
begin
  CustomDoc := CustomDocManager.GetReportByGUID(ARptGUID);
  if Assigned(CustomDoc) then begin
    AReport := TReportBase.Create;
    AReport.Lock;
//    AReport.Title := CustomDoc.Title;
    AReport.Title := Format('%s - %s', [CUSTOM_DOC_TITLE, CustomDoc.Name]);
    AReport.CreatedBy := CustomDoc.CreatedBy;
    AReport.CreatedOn := CustomDoc.CreatedOn;
    AReport.Name := CustomDoc.Name;
    //CustomDoc GUID is in Settings
    AReport.Settings := BatchReports.Document.CreateElement('Settings');
    CustomDoc.Settings.SelectSingleNode(ReportGUID, GUIDXmlNode);
    if Assigned(GUIDXmlNode) then
      SetNodeTextStr(AReport.Settings, ReportGUID, GUIDXmlNode.Text);
  end;
end;


procedure TAddReportFrm.LoadCustomDocs(ATreeNode: TTreeNode);
var
  i: integer;
  CustomDoc: TReportBase;
  ReportNode: TReportNode;
begin
  //Refresh list before load
  CustomDocManager.SaveReports;
 
  for i := 0 to Pred(CustomDocManager.ReportList.Count) do begin
    CustomDoc := TReportBase(CustomDocManager.ReportList.Items[i]);
    if Assigned(CustomDoc) then begin
      ReportNode := TReportNode.Create;
      ReportNode.RptID := CUSTOM_DOC_BASE;
      ReportNode.RptGUID := CustomDoc.GetGUID;
      tvMenu.Items.AddChildObject(ATreeNode, CustomDoc.Name, Pointer(ReportNode));
    end;
  end;
end;

procedure TAddReportFrm.SetCountry(const Value: integer);
begin
  FCountry := Value;
end;

procedure TAddReportFrm.SetRptGuid(const Value: string);
begin
  FRptGuid := Value;
end;

procedure TAddReportFrm.SetRptId(const Value: Integer);
begin
  FRptId := Value;
  BtnOK.Enabled := FRptId >= 0;
end;

procedure TAddReportFrm.tvMenuChange(Sender: TObject; Node: TTreeNode);
begin
  RptID := -1;
  RptGUID := '';
  if Assigned(Node) then begin
    if Node.Selected then begin
       RptID := TReportNode(Node.Data).RptID;
       RptGUID := TReportNode(Node.Data).RptGUID;
     end;
  end;
end;

procedure TAddReportFrm.tvMenuCollapsing(Sender: TObject; Node: TTreeNode;
  var AllowCollapse: Boolean);
begin
  if assigned(Node) then begin
     // Fix Double click on icon problem..
     Node.Selected := True;
  end;
end;

procedure TAddReportFrm.tvMenuDblClick(Sender: TObject);
begin
   DoAdd;
end;

procedure TAddReportFrm.tvMenuKeyPress(Sender: TObject; var Key: Char);
begin
   case ord(Key) of
     VK_ESCAPE : begin
        Key := #0;
        modalresult := mrCancel;
     end;
     VK_RETURN : DoAdd;
   end;
end;

{ TReportNode }

procedure TReportNode.SetRptGUID(const Value: string);
begin
  FRptGUID := Value;
end;

procedure TReportNode.SetRptID(const Value: integer);
begin
  FRptID := Value;
end;

end.
