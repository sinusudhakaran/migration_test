unit BatchReportFrm;

interface

uses
  //RptMenuLink,
  //reportNodes,
  stDate,
  YesNoDlg,
  DateUtils,
  Contnrs,
  PeriodUtils,
  GlobalCache,
  VirtualTreeHandler,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,StdCtrls, ComCtrls,reportdefs, UBatchBase, VirtualTrees, VTEditors,
  ActnList, Menus,SYSOBJ32,OmniXML, admin32, ExtCtrls, RzPanel, RzGroupBar,
  clObj32, Mask, RzEdit, RzDTP,  RzSpnEdt,
  ImagesFrm, ImgList,
  OSFont;


type
  TDlgMode = (Nothing, ByCLient, {ByBatch,}ByReport);
  TRunMode = (Running, Off , Done);


type
  TfrmBatchReports = class(TForm)
    PopupMenu1: TPopupMenu;
    AddBatch: TMenuItem;
    AddReport1: TMenuItem;
    ReportActionList: TActionList;
    acAddBatch: TAction;
    acAddReport: TAction;
    acRunNow: TAction;
    RunNow: TMenuItem;
    acSetup: TAction;
    acSetup1: TMenuItem;
    GBGroupBar: TRzGroupBar;
    ReportGroup: TRzGroup;
    RzPanel2: TRzPanel;
    Listpanel: TRzPanel;
    ReportTree: TVirtualStringTree;
    Runpanel: TRzPanel;
    LBstatus: TListBox;
    RunButton: TButton;
    DetailsGroup: TRzGroup;
    acDelReport: TAction;
    SettingsGroup: TRzGroup;
    Delete1: TMenuItem;
    acTitles: TAction;
    RenameReport: TMenuItem;
    ImageList1: TImageList;
    pnlClose: TPanel;
    Splitter1: TSplitter;
    btnClose: TButton;
    N1: TMenuItem;
    // Actions
    procedure acAddReportExecute(Sender: TObject);
//    procedure acAddClientExecute(Sender: TObject);
    procedure acAddBatchExecute(Sender: TObject);
    procedure acDelReportExecute(Sender: TObject);

    // Editor Handeling
    procedure ReportTreeNewText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; NewText: WideString);
    procedure ReportTreeCreateEditor(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
    procedure ReportTreeEditing(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; var Allowed: Boolean);

    procedure ReportTreeKeyAction(Sender: TBaseVirtualTree;
      var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);

    // Form Handeling
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Reload;

    // Report Actions
    procedure acRunNowExecute(Sender: TObject);
    procedure acSetupExecute(Sender: TObject);
    procedure RunButtonClick(Sender: TObject);
    procedure RunpanelResize(Sender: TObject);

    procedure ReportTreeGetImageIndex(Sender: TBaseVirtualTree;
      Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
      var Ghosted: Boolean; var ImageIndex: Integer);
    procedure ReportTreeHeaderClick(Sender: TVTHeader; Column: TColumnIndex;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure acTitlesExecute(Sender: TObject);
    procedure ReportTreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ReportTreeHeaderDraw(Sender: TVTHeader; HeaderCanvas: TCanvas;
      Column: TVirtualTreeColumn; R: TRect; Hover, Pressed: Boolean;
      DropMark: TVTDropMarkMode);

  private

    fClientBatchCombo : TComboEditLink;

    FDlgMode: TDlgMode;
    FRunMode: TRunMode;
    FAllSelected: Boolean;

    //FCurReport: TReportBase;

    //function RunBatchNode (ABatch : PVirtualNode; CountOnly : Boolean = False ) : Integer;
    procedure DeleteNodeReport (Node: PVirtualNode);
    procedure SetDlgMode(const Value: TDlgMode);
    procedure FillBatchCombo;
    procedure SetRunMode(const Value: TRunMode);
    //function  ColumnTag (Column : Integer) : Integer;
    //procedure SetCurReport(const Value: TReportBase);
    procedure BatchOnStatus(Value: TObject);
    procedure SetAllSelected(const Value: Boolean);
    //procedure OnDocChange(Value: TObject);
    //procedure SetCurReport(const Value: TReportBase);
    { Private declarations }
  protected
    procedure UpdateActions; override;
  public


    ReportList : TTreeBaseList;
    property DlgMode : TDlgMode read FDlgMode write SetDlgMode;
    property RunMode : TRunMode read FRunMode write SetRunMode;
    //property CurReport : TReportBase read FCurReport write SetCurReport;

    property AllSelected: Boolean read FAllSelected write SetAllSelected;
    function RunReportBase (AReport : TReportBase): Boolean;
    procedure SetupReport (AReport : TReportBase);
    function GetNodeLevel (Node: PVirtualNode) : Integer;
    procedure DoOnPrint(const Destination: TReportDest);
    { Public declarations }
  end;

procedure RunBatchReports (Mode :TDlgMode);

implementation

uses
  UsageUtils,
  GraphDefs,
  frmAddReport,
  bkBranding,
  ShellAPI,
  PDFViewerFrm,
  dlgSaveBatch,
  UpdateMF,
  Themes,
  ErrorMoreFrm,
  StDateSt, bkDateUtils, bkConst,
  OmniXMLUtils,XmlSave, Reports, Globals, Files, bkhelp, bkXPThemes,
  CustomDocEditorFrm;

  {$R *.dfm}
const
  NameCol = 2;


procedure RunBatchReports(Mode :TDlgMode);
var frmBatchReports : TfrmBatchReports;
begin
    BatchReports.ClearSelection;
    frmBatchReports := TfrmBatchReports.Create(Application.MainForm);
    try
       frmBatchReports.DlgMode := Mode;
       try
          frmBatchReports.ShowModal;


       except // Dont Need to Crash out..
       end;
    finally
       frmBatchReports.Free;
       BatchReports.OnReportStatus := nil;
       UpdateMF.UpdateMenus;
    end;
end;


procedure TfrmBatchReports.acAddBatchExecute(Sender: TObject);
var Node: PVirtualNode;
    nr : TReportBase;
begin
    if DlgMode in [Nothing] then
       Exit;

    nr := BatchReports.AddChild(nil,BatchReports);
    nr.Title := 'New Group';
    BatchReports.Changed := true;

    Node := ReportList.AddNodeItem(nil,nr);

    if DlgMode = ByClient then begin
       // New Batch, Must have the current Client as well
       nr := TReportClient(nr).AddChild(nil,BatchReports);
       nr.Title := MyClient.clFields.clCode;
       nr.Name := MyClient.clFields.clName; // While we are here..
    end;
    ReportTree.EditNode(Node,0);

    BatchReports.Changed := true;

end;


procedure TfrmBatchReports.acAddReportExecute(Sender: TObject);
begin
   with TAddReportFrm.Create(Self) do try
     if ShowModal = mrOK then
        acTitlesExecute(nil);
   finally
     Free;
   end;
end;


procedure TfrmBatchReports.acDelReportExecute(Sender: TObject);
begin
    case GetReportLevel(TReportBase(ReportList.CurBaseItem)) of
       L_Report :  begin
                    if (AskYesNo('Delete report',
                                 'Are you sure you want to Delete:'#13
                                 + ReportList.CurBaseItem.GetTagText(gt_FullName),DLG_NO,0) = DLG_YES) then
                        DeleteNodeReport(ReportList.CurBaseItem.Node);
                   end
       else exit;
    end;
end;


procedure TfrmBatchReports.DoOnPrint(const Destination: TReportDest);
var Lrpt : TReportBase;
    I : Integer;

begin
    for I := 0 to BatchReports.Selected.Count-1 do begin
       Lrpt := TReportBase(BatchReports.Selected[I]);
            // Savety check...
            if (Lrpt.RunFileName > '')
            {and FileExists(Lrpt.RunFileName)} then begin
              case Destination of
                 rdPrinter: begin
                    incUsage(Get_ReportName(Get_ReportType(lrpt.Title)) + '(Generate)(Print)');
                    Lrpt.RunDestination := Get_DestinationText(Destination);
                 end;

                 rdEmail: begin
                    incUsage(Get_ReportName(Get_ReportType(lrpt.Title)) + '(Generate)(Email)');
                    Lrpt.RunDestination := Get_DestinationText(Destination);
                 end;

              end;
             
            end;
    end;
    BatchOnStatus(nil); // May have changed...
end;



procedure TfrmBatchReports.acRunNowExecute(Sender: TObject);
var Lrpt : TReportBase;
    I : Integer;

begin
     // Findout what is selected..
   if BatchReports.Selected.Count = 0 then begin
      ///
   end {else if Fselected.Count = 1 then begin
      BatchReports.BatchRunMode := R_Setup;
      BatchReports.RunReport(TReportBase(Fselected[0]));
   end} else begin

      //Add to Report List merge field
      CustomDocManager.ClearReportListMergeField;
      for i := 0 to Pred(BatchReports.Selected.Count) do begin
        Lrpt := TReportBase(BatchReports.Selected[I]);
        CustomDocManager.AddToReportListMergeField(Lrpt.Name);
      end;

      I := 0;
      BatchReports.BatchRunMode := R_Batch;
      // Prep the PDF Files...
      repeat
          Lrpt := TReportBase(BatchReports.Selected[I]);
          BatchReports.RunReport(Lrpt);
          case Lrpt.RunBtn of
            BTN_Save : if I > 0 then begin // Cancel
                        Dec(I); // We are running this again...
                        Lrpt := TReportBase(BatchReports.Selected[I]);
                        DeleteFile(Lrpt.RunFileName); // Cleanup..
                     end else
                        Exit; // Cancel the lot...
            Btn_Print : Inc(I);
            else exit; // Cancel...
          end;
      until I > Pred(BatchReports.Selected.Count);


      with TPDFViewFrm.Create(nil) do try

         for I := 0 to BatchReports.Selected.Count-1 do begin
            Lrpt := TReportBase(BatchReports.Selected[I]);
            // Savety check...
            if (Lrpt.RunFileName > '')
            and FileExists(Lrpt.RunFileName) then
              FileList.Add(ExpandFileName(Lrpt.RunFileName));
         end;
         Caption := 'Report Viewer';
         OnPrint := DoOnPrint;
         ShowModal;
      finally
         Free;
      end;

      for I := 0 to BatchReports.Selected.Count-1 do begin
         Lrpt := TReportBase(BatchReports.Selected[I]);
         DeleteFile(Lrpt.RunFileName); // Cleanup..
      end;

      (*
      // Still Here.. Do the view...
      Filename := GetBatchDestination(MyClient);
      if Filename = '' then
          Exit;

      PDFViewer.Clear;
      for I := 0 to Fselected.Count-1 do begin
         Lrpt := TReportBase(Fselected[I]);
         PDFViewer.AppendFromFile(Lrpt.RunFileName);
         DeleteFile(Lrpt.RunFileName); // Cleanup..
      end;
      PDFViewer.CommandEx(500, 14968101);
      PDFViewer.CommandStr(501, Filename);

      PDFViewer.Clear;
      for I := 0 to Fselected.Count-1 do begin
         Lrpt := TReportBase(Fselected[I]);
         //PDFViewer.AppendFromFile(Lrpt.RunFileName);
         DeleteFile(Lrpt.RunFileName); // Cleanup..
      end;


      //PDFViewer.Visible := true;
      //determine full path name of report
      if ExtractFilePath(Filename) = '' then begin
         //the filename has no path info so add the current path
         Filename := GetCurrentDir + '\' + Filename;
      end;
      PDFViewerFrm.ViewPDFFile(Filename);
      //ShellExecute(0, 'open', PChar(FileName), nil, nil, SW_SHOWMAXIMIZED);
      *)
   end;



    (*

    Node := ReportTree.GetFirstSelected;
    if Not Assigned(Node) then
       Exit;

    lrpt := ReportList.GetNodeItem(Node);

    if not assigned(lrpt) then
       Exit;

    //lrpt.SetupOnly := False;

    case GetReportLevel(Lrpt) of
          {
          L_Batch  : case DlgMode of
                 Nothing : ;
                 ByClient : RunBatchNode(Node);
                 //ByBatch : RunbatchReport(TReportBatch(lrpt));
               end;
          }

          L_Client : case DlgMode of
                 Nothing : ;
                 ByClient :;// Not available..
                 {ByBatch :begin
                    if setclient (Lrpt.Title) then
                          RunClientReport(TReportClient(Lrpt));
                 end; }
               end;


          L_Report : case DlgMode of
                 Nothing : ;
                 ByClient,
                 ByReport : RunReportBase(TReportBase(lRpt));
                 {ByBatch : if setclient (Lrpt.Title) then
                                 RunReportBase(Lrpt);}
               end;

          else  Exit; // ??
       end;
    *)
    ReportTree.Invalidate; //Nodes would have changed..
    //CurReport := Lrpt;
end;

procedure TfrmBatchReports.acSetupExecute(Sender: TObject);
begin
    case DlgMode of
       Nothing : ;
       ByClient,
       ByReport : if assigned(MyClient) then
            if GetReportLevel(TReportBase(ReportList.CurBaseItem))= L_Report then
               SetupReport(TReportBase(ReportList.CurBaseItem) );

    end;
end;


procedure TfrmBatchReports.acTitlesExecute(Sender: TObject);
var LNode : PVirtualNode;
begin
   lNode := ReportTree.FocusedNode;
   if not assigned(lNode) then exit;
   ReportTree.EditNode(LNode,NameCol);
end;

procedure TfrmBatchReports.BatchOnStatus(Value: TObject);

  procedure addGroupItem (ToItems : TRzGroupItems; Name,Value :string);
    var ng : TRZGroupItem;
        P : Integer;
    begin
       if Value <> '' then begin
          if Sametext(Value, 'No')
          or Sametext(Value, 'False')
          or Sametext(Value, 'None')
          or Sametext(Value, 'Ok')
          or Sametext(Value, '0') then
             Exit;

          repeat
             P := Pos('_', Name);
             if P > 0 then
                Name[P] := ' ';
          until (P = 0);



          ng := ToItems.Add;
          if sametext(Value, 'Yes')
          or sametext(Value, 'True') then
             ng.Caption := Name
          else begin
            repeat
               P := Pos('_', Value);
               if P > 0 then
                  Value[P] := ' ';
            until (P = 0);
            if Name > '' then
               ng.Caption := Name + ': ' + Value
            else
               ng.Caption := Value;
          end;
       end;
    end;

    procedure AddNodeNode (Value : IXMLNode);
    var nxn : IXMLNode;
    begin
      if not Assigned(Value) then
         Exit;
      if Sametext(Value.NodeName,ReportGUID) then
         Exit; // Not usefull
      
      if Sametext(Value.NodeName,'Codes') then begin
         addGroupItem( SettingsGroup.Items,'','Selected Chart Codes');
         Exit;
      end;
      if Sametext(Value.NodeName,'Payees') then begin
         addGroupItem( SettingsGroup.Items,'','Selected Payees');
         Exit;
      end;
      //Correct spelling of Transferring
      if Sametext(Value.NodeName,'Show_Non_Transfering_Journals') then begin
         nxn := Value.FirstChild;
         if assigned(nxn) then
           if Sametext(nxn.NodeValue, 'Yes') then
             addGroupItem( SettingsGroup.Items,'','Show Non Transferring Journals');
         Exit;
      end;
      //Add space LastYear
      if Sametext(Value.NodeName,'YTD_with_LastYear') then begin
         nxn := Value.FirstChild;
         if assigned(nxn) then
           if Sametext(nxn.NodeValue, 'Yes') then
             addGroupItem( SettingsGroup.Items,'','YTD with Last Year');
         Exit;
      end;
      //Correct spelling of Quantities
      if Sametext(Value.NodeName,'Show_Budget_Quantaties') then begin
         nxn := Value.FirstChild;
         if assigned(nxn) then
           if Sametext(nxn.NodeValue, 'Yes') then
             addGroupItem( SettingsGroup.Items,'','Show Budget Quantities');
         Exit;
      end;
      nxn := Value.FirstChild;
      while assigned(nxn) do begin
          if (nxn.NodeType in [TEXT_NODE])
          and (Length(nxn.ParentNode.NodeName) > 0)
          and (nxn.ParentNode.NodeName[1] <> '_') then begin //So we can 'Hide' them
             addGroupItem( SettingsGroup.Items, nxn.ParentNode.NodeName,nxn.NodeValue);
          end;
          AddNodeNode (nxn);
          nxn := nxn.NextSibling;
      end;
    end;
    procedure SetHaveReport (Value : Boolean);
    begin
       acDelReport.Enabled := Value;
       acRunNow.Enabled := Value;
       acSetup.Enabled  := Value;
       acTitles.Enabled := Value;
    end;
begin
   DetailsGroup.Items.BeginUpdate;
   try
      DetailsGroup.Items.Clear;
      if assigned(ReportList.CurBaseItem ) then begin
         addGroupItem(DetailsGroup.Items, 'Last Run',   ReportList.CurBaseItem.GetTagText(GT_LastRun));
         addGroupItem(DetailsGroup.Items, 'For Dates',  ReportList.CurBaseItem.GetTagText(GT_dates));
         addGroupItem(DetailsGroup.Items, 'By',         ReportList.CurBaseItem.GetTagText(GT_User));
         addGroupItem(DetailsGroup.Items, 'Result',     ReportList.CurBaseItem.GetTagText(GT_Result));
         addGroupItem(DetailsGroup.Items, 'Destination',ReportList.CurBaseItem.GetTagText(gt_RunDest));
      end;
   finally
      DetailsGroup.Items.EndUpdate;
   end;

   SettingsGroup.Items.BeginUpdate;
   try   try
      SettingsGroup.Items.Clear;
      if assigned(ReportList.CurBaseItem) then
         AddNodeNode(TReportBase(ReportList.CurBaseItem).Settings);
   except

   end;
   finally
      SettingsGroup.Items.EndUpdate;
   end;

   SetHaveReport (assigned(ReportList.CurBaseItem));
end;


procedure TfrmBatchReports.DeleteNodereport(Node: PVirtualNode);
var lrpt : TReportBase;
    Prev : PVirtualNode;
begin
    if not Assigned(Node) then
       Exit;

    lrpt := TReportBase(ReportList.GetNodeItem(Node));
    if not assigned(lrpt) then begin
       // fine.. but still need to remove the node...
       ReportTree.DeleteNode(Node);
       Exit;
    end;

    case GetReportLevel (Lrpt) of
       L_Report :  begin
                     Prev := Node.PrevSibling;
                     if Prev = nil then
                        Prev := Node.Parent;
                     if (Prev = ReportTree.RootNode)
                     or (Prev = nil) then
                        Prev := Node.NextSibling;

                     // Stop CurReport from pointing to nowhere
                     ReportList.CurBaseItem := nil;

                     ReportList.RemoveItem(Lrpt);

                     if Assigned(Lrpt.Parent) then
                     with TReportClient(Lrpt.Parent).List do
                        Delete (IndexOf(lrpt));
                     // no longer need to keep it..

                     // Select Left-over node...
                     if (Prev <> nil)
                     and (Prev <> ReportTree.RootNode) then begin
                        ReportTree.Selected[Prev] := True;
                        ReportTree.FocusedNode := Prev;
                     end;
                   end
       else exit;
    end;
    //UpdateMF.UpdateMenus;
end;


procedure TfrmBatchReports.FillBatchCombo;
var lList : TStringList;
    I : Integer;
begin
   lList := TStringList.Create;
   try
      for I := 0 to BatchReports.List.Count - 1 do
         LList.Add(BatchReports.Child[I].Title);

      FClientBatchCombo.PickList := LList;
      FClientBatchCombo.Style := csSimple;
   finally
      lList.Free;
   end;
end;


procedure TfrmBatchReports.FormCreate(Sender: TObject);
var lList : TStringList;

begin
   bkXPThemes.ThemeForm(Self);
   BKHelpSetUp(Self, BKH_Favourite_Reports);
   ReportTree.Header.Font := Font;
   ReportTree.Header.Height := Abs(ReportTree.Header.Font.height) * 10 div 6;
   ReportTree.DefaultNodeHeight := Abs(Self.Font.Height * 15 div 8); //So the editor fits

   RunMode := Off;
   GBGroupBar.GradientColorStop := bkBranding.GroupBackGroundStopColor;
   GBGroupBar.GradientColorStart := bkBranding.GroupBackGroundStartColor;

   ReportList := TTreeBaseList.Create(ReportTree);
   ReportList.OwnsObjects := False; // ReportTree Owns them...
   ReportList.OnCurBaseItemChange := BatchOnStatus;
   lList := TStringList.Create;
   try
      //Batchreports.XMLString := MyClient.clFields.clFavourite_Report_XML;
      // Get the settings as well than...
      if UserINI_FR_GroupWidth  > 0 then
         GBGroupBar.width := UserINI_FR_GroupWidth;

      //ReadPosition(Self,BatchReports.Settings);
      // Setup the Tree List
      ReportTree.StateImages := AppImages.Maintain;

      // set up the editors..

      LList.Clear;
      fClientBatchCombo := TComboEditLink.Create(LList, csDropDownList);;
   finally
     lList.Free;
   end;

end;

procedure TfrmBatchReports.FormDestroy(Sender: TObject);
var I : integer;
begin
   case DlgMode of
     Nothing: ;
     ByCLient,
     ByReport:  for i := Low(UserINI_FR_Column_Widths) to high(UserINI_FR_Column_Widths) do begin
        if I < Pred(ReportTree.Header.Columns.Count) then
           UserINI_FR_Column_Widths[I] := ReportTree.Header.Columns[succ(I)].Width;
      end;

   end;
   UserINI_FR_GroupWidth := GBGroupBar.width;
   //MyClient.clFields.clFavourite_Report_XML := Batchreports.XMLString;
   // More for Debug at the moment...
   BatchReports.Changed := True;

   fClientBatchCombo.Free;
   ReportList.Free;
end;



function TfrmBatchReports.GetNodeLevel(Node: PVirtualNode): Integer;
var lBase: TTreeBaseItem;
begin
   Result := L_Root;
   LBase :=  ReportList.GetNodeItem(Node);
   if not assigned(LBase) then exit;

   Result := GetReportLevel (LBase);
end;

(*
procedure TfrmBatchReports.OnDocChange(Value: TObject);
begin
   with TPDFViewFrm(Value) do
     if (Doc > 0) // Doc is 1..count
     and (Doc <= BatchReports.Selected.Count) then begin
       Caption :=
          TReportBase(BatchReports.Selected[Pred(Doc)]).Title + ' [' +
          TReportBase(BatchReports.Selected[Pred(Doc)]).Name + ']';
     end;

end;
*)
procedure TfrmBatchReports.Reload;
var
  J: Integer;
  ShowFinReports: Boolean;
  CustomDoc: TReportBase;

    function addReport (Value: TReportBase; ToNode: PVirtualNode): PVirtualNode;
    begin
      result := nil;
      if ShowFinReports or not
        TBatchReportList.IsReportFinancialReport(Get_ReportListType(Value.Title)) then
       result := ReportList.AddNodeItem(ToNode,Value);
    end;

    function addClient (Value: TReportClient; ToNode: PVirtualNode): PVirtualNode;
    var i : integer;
    begin
       result := addreport(Value,ToNode);
       for i := 0 to Value.List.Count - 1 do
         addReport(Value.Child[i],result);
    end;

    procedure CheckClient (Value : TReportClient; ToNode  :PVirtualNode);
    var i : integer;
    begin
       for i  := 0 to Value.List.Count - 1 do begin
         //Check that custom doc esists
         if Value.Child[i].GetGUID <> '' then begin
           CustomDoc := CustomDocManager.GetReportByGUID(Value.Child[i].GetGUID);
           if Assigned(CustomDoc) then begin
             //Update title - name of doc may have changed
             Value.Child[i].Title := Format('%s - %s', [CUSTOM_DOC_TITLE, CustomDoc.Name]);
             addReport(Value.Child[i],ToNode);
           end;
         end else
           addReport(Value.Child[i],ToNode);
       end;
    end;
begin
  ShowFinReports := (Assigned(MyClient)  //Client File is open
        and MyClient.clExtra.ceBook_Gen_Finance_Reports //Allow Generate Financial REports
        and not Assigned(AdminSystem))  //Books User
        or
        (
        Assigned(MyClient)  //Client File is open
          and Assigned(AdminSystem) //Practice User
        );
   ReportTree.BeginUpdate;
   try
      ReportTree.Clear;

      case FDlgMode of
       ByClient,
       ByReport : begin
          if not assigned(MyClient) then
             exit;

          for j := 0 to pred(BatchReports.List.Count) do begin
            CheckClient( TReportClient(BatchReports.Child[j]),nil );
          end;
       end;
      end;


   finally
      ReportTree.EndUpdate;
   end;
   ReportTree.FocusedNode := ReportTree.GetFirstVisible;
   if Assigned(ReportTree.FocusedNode) then
      ReportTree.Selected [ReportTree.FocusedNode] := True;
end;


type

  TTextEditLink = class(TStringEditLink)
  public
    constructor Create( const len : Integer);
  end;
  constructor TTextEditLink.Create( const len : Integer);
  begin
     inherited Create;
     Edit.MaxLength := Len;
  end;

procedure TfrmBatchReports.ReportTreeCreateEditor(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; out EditLink: IVTEditLink);
begin
   //We can only get here if 'Allowed' in ReportTreeEditing
   //So we MUST set EditLink
   case ReportList.GetColumnTag(column) of

   gt_Title  : case getNodeLevel(Node) of
               L_Client : EditLink := fClientBatchCombo.Link;
               //L_Report : EditLink := FMenuLink {fReportCombo.Link};
               L_Batch : case DlgMode  of
                           ByCLient: EditLink := fClientBatchCombo.Link;
                           {ByBatch: EditLink := TStringEditLink.Create;}
                         end;
               else EditLink := TStringEditLink.Create;
               end;

   gt_Name : begin
              EditLink := TTextEditLink.Create(80);
      end;
          {
   gt_Frequency,
   gt_Period,
   gt_Dates,
   gt_EndMonth   :  EditLink := fFreq;
         }
   else EditLink := TStringEditLink.Create; //Save...
   end;

end;

procedure TfrmBatchReports.ReportTreeEditing(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; var Allowed: Boolean);
begin
   Allowed := false;
   if DlgMode = Nothing then
      Exit;
   if not assigned(Node) then
      Exit;

   case ReportList.GetColumnTag(column) of

   gt_Title       : Allowed := GetNodeLevel(Node)
                             in [ l_Batch {, l_Report,l_Client }];

   gt_Name        : Allowed := GetNodeLevel(Node) = L_Report;
   end;
end;

procedure TfrmBatchReports.ReportTreeGetImageIndex(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Kind: TVTImageKind; Column: TColumnIndex;
  var Ghosted: Boolean; var ImageIndex: Integer);
begin
   if Node = nil then exit;
   if Column <> 0 then exit;
   if Kind <> ikState then exit;
     (*
   case GetNodeLevel (Node)  of
   L_Root :;
   L_setting :;
   L_Report : ImageIndex := 6;
   else   if (vsExpanded in node.States) then
              ImageIndex := 5
          else
              ImageIndex := 4;
   end;
       *)
end;

procedure TfrmBatchReports.ReportTreeHeaderClick(Sender: TVTHeader;
  Column: TColumnIndex; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
var
  OldCol : TColumnIndex;
begin
  if Button = mbRight then exit; // will show popup menu

  OldCol := ReportTree.Header.SortColumn;

  ReportTree.BeginUpdate;
  try
    if Column = 0 then begin
       AllSelected := not Allselected;

    end else
    if Column <> OldCol then begin
       ReportTree.Header.SortColumn           := Column;
       ReportTree.Header.SortDirection        := sdAscending;

       with ReportTree.Header do
          ReportTree.SortTree( SortColumn, SortDirection);
    end else begin
       //just reverse the direction as col hasn't changed
       if ReportTree.Header.SortDirection = sdAscending then
          ReportTree.Header.SortDirection := sdDescending
       else
          ReportTree.Header.SortDirection := sdAscending;

       with ReportTree.Header do
          ReportTree.SortTree( SortColumn, SortDirection);
    end;

  finally
    ReportTree.EndUpdate;
  end;

end;


procedure TfrmBatchReports.ReportTreeHeaderDraw(Sender: TVTHeader;
  HeaderCanvas: TCanvas; Column: TVirtualTreeColumn; R: TRect; Hover,
  Pressed: Boolean; DropMark: TVTDropMarkMode);
  

// XP style header button legacy code. This procedure is only used on non-XP systems to simulate the themed
// header style.
// Note: the theme elements displayed here only correspond to the standard themes of Windows XP

const
  XPMainHeaderColorUp = $DBEAEB;       // Main background color of the header if drawn as being not pressed.
  XPMainHeaderColorDown = $D8DFDE;     // Main background color of the header if drawn as being pressed.
  XPMainHeaderColorHover = $F3F8FA;    // Main background color of the header if drawn as being under the mouse pointer.
  XPDarkSplitBarColor = $B2C5C7;       // Dark color of the splitter bar.
  XPLightSplitBarColor = $FFFFFF;      // Light color of the splitter bar.
  XPDarkGradientColor = $B8C7CB;       // Darkest color in the bottom gradient. Other colors will be interpolated.
  XPDownOuterLineColor = $97A5A5;      // Down state border color.
  XPDownMiddleLineColor = $B8C2C1;     // Down state border color.
  XPDownInnerLineColor = $C9D1D0;      // Down state border color.

  
  procedure FillHeaderRect (ButtonR : TRect);
  var Details: TThemedElementDetails;
      PaintBrush: HBRUSH;
      Pen,
      OldPen: HPEN;
      PenColor,
      FillColor: COLORREF;
      dRed, dGreen, dBlue: Single;

  begin
     if tsUseThemes in Sender.Treeview.TreeStates then begin
        Details := ThemeServices.GetElementDetails(thHeaderItemNormal);
        ThemeServices.DrawElement(HeaderCanvas.Handle, Details, ButtonR, @ButtonR);
     end else begin
        inc( ButtonR.Left);
        FillColor := XPMainHeaderColorUp;
        PaintBrush := CreateSolidBrush(FillColor);
        FillRect(HeaderCanvas.Handle, ButtonR, PaintBrush);
        DeleteObject(PaintBrush);

        // One solid pen for the dark line...
        Pen := CreatePen(PS_SOLID, 1, XPDarkSplitBarColor);
        OldPen := SelectObject(HeaderCanvas.Handle, Pen);
        MoveToEx(HeaderCanvas.Handle, ButtonR.Right - 2, ButtonR.Top + 3, nil);
        LineTo(HeaderCanvas.Handle, ButtonR.Right - 2, ButtonR.Bottom - 5);
        // ... and one solid pen for the light line.
        Pen := CreatePen(PS_SOLID, 1, XPLightSplitBarColor);
        DeleteObject(SelectObject(HeaderCanvas.Handle, Pen));
        MoveToEx(HeaderCanvas.Handle, ButtonR.Right - 1, ButtonR.Top + 3, nil);
        LineTo(HeaderCanvas.Handle, ButtonR.Right - 1, ButtonR.Bottom - 5);
        SelectObject(HeaderCanvas.Handle, OldPen);
        DeleteObject(Pen);

        // There is a three line gradient near the bottom border which transforms from the button color to a dark,
        // clBtnFace like color (here XPDarkGradientColor).
        PenColor := XPMainHeaderColorUp;
        dRed := ((PenColor and $FF) - (XPDarkGradientColor and $FF)) / 3;
        dGreen := (((PenColor shr 8) and $FF) - ((XPDarkGradientColor shr 8) and $FF)) / 3;
        dBlue := (((PenColor shr 16) and $FF) - ((XPDarkGradientColor shr 16) and $FF)) / 3;

        // First line:
        PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
        Pen := CreatePen(PS_SOLID, 1, PenColor);
        OldPen := SelectObject(HeaderCanvas.Handle, Pen);
        MoveToEx(HeaderCanvas.Handle, ButtonR.Left, ButtonR.Bottom - 3, nil);
        LineTo(HeaderCanvas.Handle, ButtonR.Right, ButtonR.Bottom - 3);

        // Second line:
        PenColor := PenColor - Round(dRed) - Round(dGreen) shl 8 - Round(dBlue) shl 16;
        Pen := CreatePen(PS_SOLID, 1, PenColor);
        DeleteObject(SelectObject(HeaderCanvas.Handle, Pen));
        MoveToEx(HeaderCanvas.Handle, ButtonR.Left, ButtonR.Bottom - 2, nil);
        LineTo(HeaderCanvas.Handle, ButtonR.Right, ButtonR.Bottom - 2);

        // Third line:
        Pen := CreatePen(PS_SOLID, 1, XPDarkGradientColor);
        DeleteObject(SelectObject(HeaderCanvas.Handle, Pen));
        MoveToEx(HeaderCanvas.Handle, ButtonR.Left, ButtonR.Bottom - 1, nil);
        LineTo(HeaderCanvas.Handle, ButtonR.Right, ButtonR.Bottom - 1);

        // Housekeeping:
        DeleteObject(SelectObject(HeaderCanvas.Handle, OldPen));
    end;
  end;



begin
  if Column.Index = 0 then begin
    FillHeaderRect(R);
    if AllSelected then
       AppImages.ilFileActions_ClientMgr.Draw(HeaderCanvas, R.Left, R.Top, 30)
    else
       AppImages.ilFileActions_ClientMgr.Draw(HeaderCanvas, R.Left, R.Top, 31);
  end;
end;

procedure TfrmBatchReports.ReportTreeKeyAction(Sender: TBaseVirtualTree;
  var CharCode: Word; var Shift: TShiftState; var DoDefault: Boolean);
var Node: PVirtualNode; Column: TColumnIndex;
begin
   DoDefault := false;
   case CharCode of
   //VK_Insert : acAddBatchExecute(nil);
   VK_Delete : acDelReportExecute(nil);
   VK_F6,  // Edit...
   VK_F2 : begin
         Node := ReportTree.FocusedNode;
         if not assigned(Node) then
             exit;
         Column := ReportTree.FocusedColumn;
         if Column < 0 then Exit;

         ReportTree.EditNode(Node,Column);
     end;
   else Dodefault := True;
   end;
end;

procedure TfrmBatchReports.ReportTreeKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case ord(key) of
     VK_ESCAPE : begin
        Key := 0;
        close;
     end;
     VK_RETURN : begin
        if not assigned(ReportTree.EditLink) then
        if assigned(ReportList.CurBaseItem) then begin
           Key := 0;
           RunReportBase(TReportBase(ReportList.CurBaseItem));
        end;
     end;
     VK_SPACE : begin
        if not assigned(ReportTree.EditLink) then
        if assigned(ReportList.CurBaseItem) then begin
           Key := 0;
           TReportBase(ReportList.CurBaseItem).Selected := not
              TReportBase(ReportList.CurBaseItem).Selected;
           ReportTree.Invalidate;
        end;
     end;
  end;
end;

procedure TfrmBatchReports.ReportTreeNewText(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex; NewText: WideString);

var Lr, Tr: TReportBase;
begin
  Lr :=  TReportBase(ReportList.GetNodeItem(Node));
  if not assigned(Lr) then
     Exit; // Nowhere to go..

  case reportList.GetColumnTag(Column) of

   gt_Title :  case GetReportlevel(Lr) of
                 l_batch  : Lr.Title := Trim(NewText);
                 else exit;
               end;

   gt_Name  :  case GetReportlevel(Lr) of
                 l_Report  : begin
                      NewText := Trim(NewText);
                      if NewText < ' ' then begin
                         HelpfulErrorMsg('Please enter valid name.', 0, False);
                         Exit;
                      end;
                      Tr := BatchReports.FindReportName(NewText);
                      if (Tr <> nil)
                      and(Tr <> Lr) then begin
                         HelpfulErrorMsg(
                             'A favourite named'#10'"'+ NewText + '"'#10'already exists.'#10 +
                             'Please enter a different name.',0 , False);
                         acTitlesExecute(nil);    
                         Exit;
                      end;
                      Lr.Name := NewText;
                      //UpdateMF.UpdateMenus;
                   end
                 else Lr.Name := Trim(NewText);
               end;


   else exit;
  end;

  BatchReports.Changed := True;
end;

(*
function TfrmBatchReports.RunBatchNode(ABatch: PVirtualNode;CountOnly : Boolean = False): Integer;
var ReportNode : PVirtualNode;
    BatchReport : TReportBatch;
    EachReport : TReportBase;
begin
   // Only run in "ByClient"
   Result := 0;
   if not assigned(ABatch) then
      exit;

   BatchReport := TReportBatch (ReportList.GetNodeItem (ABatch));
   ReportNode := ABatch.FirstChild;
   while assigned(ReportNode) do begin
      EachReport := TReportBase(ReportList.GetNodeItem(ReportNode));
      Inc(Result);
      if Not CountOnly then begin

         BatchReport.Passon (EachReport);

         if not RunReportBase ( EachReport) then
            Exit;
      end;
      ReportNode := ReportNode.NextSibling;
   end;
end;
*)

(*
function TfrmBatchReports.RunBatchReport(ABatch: TReportBatch;CountOnly : Boolean = False ):integer;
var I,R : integer;
begin
   // Only run in "ByBatch"
   Result := 0;
   if not assigned(ABatch) then
      exit;
   // Run trough its clients run all reports
   for I := 0 to pred(ABatch.List.Count) do
      if CountOnly then
         Inc(Result,runClientReport( TReportClient(ABatch.Child[I]),true))
      else  begin
        if SetClient (ABatch.Child[I].Title) then begin
           ABatch.Passon( ABatch.Child[I]);
           R := runClientReport( TReportClient(ABatch.Child[I]));
           if R >= 0 then inc(Result,R)
           else begin
               Abatch.Runresult := 'Reports for '
                             + ABatch.Child[I].Title
                             + ' failed';
               exit;
           end;
         end else begin
            Result := -1;
            Abatch.Runresult := 'Could not open '
                             + ABatch.Child[I].Title
                             + ' Client file';
            exit;
         end;
      end;
   if not CountOnly then begin

      ABatch.RunResult := 'OK';
      ABatch.LastRun := Now;
      ABatch.User :=  GetUserCode;
   end;
end;
*)
procedure TfrmBatchReports.RunButtonClick(Sender: TObject);
begin
   case runMode of
      Off     : ;
      Running : {Cancel};
      Done    : RunMode := Off;
   end;
end;

(*
function TfrmBatchReports.RunClientReport(AClient: TReportClient;CountOnly : Boolean = False): Integer;
var i : integer;
begin // Only applies to ByBatch
   Result := 0;
   if not assigned(AClient) then
     exit;
   if CountOnly then begin
      Result := AClient.List.Count;
   end else begin
      for I := 0 to pred(AClient.List.Count) do begin

         AClient.PassOn(AClient.Child[I]);
         if not runReportBase(AClient.Child[I]) then begin
            AClient.RunResult := AClient.Child[I].Title + ' Failed.';
            exit;
         end;
         Inc(Result);
      end;
      AClient.RunResult := 'Ok';
      AClient.LastRun := Now;
      AClient.User := GetUserCode;
      BatchReports.Changed := true;
   end;
end;
*)


procedure TfrmBatchReports.RunpanelResize(Sender: TObject);
const hb = 14;
      vb = 8;
begin
   lbStatus.SetBounds(hb,vb, RunPanel.Width - hb*2,
                             RunPanel.Height - vb*2 - RunButton.Height);
   RunButton.SetBounds(RunPanel.Width - RunButton.Width - hb,
                       RunPanel.Height - RunButton.Height - vb,
                       RunButton.Width ,RunButton.Height );
end;

function TfrmBatchReports.RunReportBase(AReport: TReportBase): Boolean;
begin
   Result := False;
   try
   try
     SetupReport(AReport);
     Result := true;
      (*
    //  AReport.SetupOnly := False; // Is doubled up ...
      AReport.SetupOnly := True;
      Areport.RunDate := 0;
      AReport.RunResult := 'Start';
      DoReport(Get_ReportListType(AReport.Title),rdScreen {TReportDest(AReport.destination)},0,Areport);
      BatchReports.Changed := true;

      if AReport.RunResult = 'Start' then // So we dont have to OK them all..
         AReport.RunResult := 'Ok';

      AReport.LastRun := Now;
      Areport.User :=  GetUserCode;
      Result := true;
      *)
   except
      on e : Exception do AReport.RunResult := 'Error: ' + E.Message;
   end;
   finally
   end;
end;

(*
function TfrmBatchReports.SetClient(const Value: string): Boolean;
begin
  if assigned (MyClient ) then begin
    if SameText(MyClient.clFields.clCode, Value)  then begin
       // Have correct client already
       Result := true;
       exit;
    end else begin
       // Wrong one, close first..
       CloseClient(true);
    end;
  end;

  OpenClient(Value);

  Result := Assigned(MyClient);

end;
*)


(*
procedure TfrmBatchReports.SetCurReport(const Value: TReportBase);

    procedure addGroupItem (ToItems : TRzGroupItems; Name,Value :string);
    var ng : TRZGroupItem;
        P : Integer;
    begin
       if Value <> '' then begin
          if Sametext(Value, 'No')
          or Sametext(Value, 'False')
          or Sametext(Value, 'Ok') then
             Exit;

          repeat
             P := Pos('_', Name);
             if P > 0 then
                Name[P] := ' ';
          until (P = 0);

          ng := ToItems.Add;
          if sametext(Value, 'Yes')
          or sametext(Value, 'True') then
             ng.Caption := Name
          else
             ng.Caption := Name + ': ' + Value;
       end;
    end;

    procedure AddNodeNode (Value : IXMLNode);
    var nxn : IXMLNode;
    begin
      if not Assigned(Value) then
         Exit;
      nxn := Value.FirstChild;
      while assigned(nxn) do begin
          if (nxn.NodeType in [TEXT_NODE])
          and (Length(nxn.ParentNode.NodeName) > 0)
          and (nxn.ParentNode.NodeName[1] <> '_') then begin //So we can 'Hide' them
             addGroupItem( SettingsGroup.Items, nxn.ParentNode.NodeName,nxn.NodeValue);
          end;
          AddNodeNode (nxn);
          nxn := nxn.NextSibling;
      end;
    end;
    procedure SetHaveReport (Value : Boolean);
    begin
       acDelReport.Enabled := Value;
       acRunNow.Enabled := Value;
       acSetup.Enabled := Value;
    end;
begin
   FCurReport := Value;
   DetailsGroup.Items.BeginUpdate;
   try
      DetailsGroup.Items.Clear;
      if assigned(FCurReport) then begin
         addGroupItem(DetailsGroup.Items, 'Last Run',   FCurReport.GettagText(GT_LastRun));
         addGroupItem(DetailsGroup.Items, 'For Dates',  FCurReport.GetTagText(GT_dates));
         addGroupItem(DetailsGroup.Items, 'By',         FCurReport.GettagText(GT_User));
         addGroupItem(DetailsGroup.Items, 'Result',     FCurReport.GettagText(GT_Result));
         addGroupItem(DetailsGroup.Items, 'Destination',FCurReport.GetTagText(gt_RunDest));
      end;
   finally
      DetailsGroup.Items.EndUpdate;
   end;

   SettingsGroup.Items.BeginUpdate;
   try   try
      SettingsGroup.Items.Clear;
      if assigned(FCurReport) then
         AddNodeNode(FCurReport.Settings);
   except

   end;
   finally
      SettingsGroup.Items.EndUpdate;
   end;
   SetHaveReport (assigned(FCurReport));

end;

*)



procedure TfrmBatchReports.SetAllSelected(const Value: Boolean);
begin
  if FAllSelected <> Value then begin
     FAllSelected := Value;
     if FAllSelected then
        BatchReports.SelectAll
     else BatchReports.ClearSelection;

     ReportTree.Invalidate;
  end;
end;

procedure TfrmBatchReports.SetDlgMode(const Value: TDlgMode);
var cid : integer;
    ct  : string;
const
    RunWidth = 20;
    function AddColumn (const ATitle: string; const aWidth, ATag: integer): TVirtualTreeColumn;
    begin
        Result := ReportTree.Header.Columns.Add;
        if (cid in [0.. MAX_FAVOURITE_REPORTS_COLUMNS]) // savety..
        and (UserINI_FR_Column_Widths[cid] > 0) then
           Result.Width := UserINI_FR_Column_Widths[cid]
        else
           Result.Width := aWidth;
        inc (cid);
        Result.Tag   := ATag;
        Result.Text  := ATitle;
    end;

begin
   if FDlgMode <> Value then begin
      FDlgMode := Value;
      ReportTree.Header.Columns.Clear;
      with AddColumn(' ', RunWidth, gt_Selected) do begin
         MaxWidth := RunWidth;
         MinWidth := RunWidth;
         Options := [coAllowClick,coEnabled, coParentBidiMode, coParentColor, coVisible];
         Style := vsOwnerDraw;
      end;
      cid := 0;
      case FDlgMode of
       ByClient  :  begin
          if Assigned (MyClient) then begin
             Self.Caption := 'Favourite Reports For ' +
                              MyClient.clExtendedName;

             FillBatchCombo;
             ct := 'CCol';
             AddColumn('Group/Report',250, gt_Title);
          end else begin
             // Dont wory.. should not hapen..
             FDlgMode := Nothing;
             Self.Caption := 'No Client Open';
             ReportTree.Header.Columns.Clear;
             Exit;
          end;
       end;
       ByReport  :  begin
          if Assigned (MyClient) then begin
             Self.Caption := 'Favourite Reports For ' +
                              MyClient.clExtendedName;

             // FillBatchCombo;
             acAddbatch.Visible := False;
             AcAddbatch.Enabled := False;
             ct := 'CCol';
             AddColumn('Report',250, gt_Title);

          end else begin
             // Dont wory.. should not hapen..
             FDlgMode := Nothing;
             Self.Caption := 'No Client Open';
             ReportTree.Header.Columns.Clear;
             Exit;
          end;
       end;
       {ByBatch : begin
              Self.Caption := 'Saved Reports';

              FillClientCombo;
              acAddClient.Visible := True;
              acAddClient.Enabled := True;
              ct := 'BCol';
              AddColumn('Group/Client/Report',250, gt_Title);

       end;}
      end;

       AddColumn('Name',250, gt_Name);
       //AddColumn('Dates',250, gt_Dates);
       AddColumn('Created by',100, gt_CreatedBy);
       AddColumn('On',100, gt_CreatedOn);
      Reload;
   end;
end;


procedure TfrmBatchReports.SetRunMode(const Value: TRunMode);
   procedure Bottompanel (Value : Boolean);
   begin
      if Value then
         Runpanel.Height := 200
      else
         Runpanel.Height := 0;
      ReportTree.Enabled := not Value;
      RunButton.Enabled := Value;
      ReportGroup.Enabled := not Value;
   end;

begin
   if FRunMode <> Value then begin
      FRunMode := Value;
      case FRunmode of
      Off       : BottomPanel(False);
      Running   : begin
             LBStatus.Clear;
             BatchReports.OnReportStatus := BatchOnStatus;
             BottomPanel(True);
             RunButton.Caption := 'Cancel';
         end;
      Done  : begin
             BottomPanel(True);
             RunButton.Caption := 'Ok';
         end;
      end;
   end;
end;

procedure TfrmBatchReports.SetupReport(AReport: TReportBase);
begin
   BatchReports.OnReportStatus := BatchOnStatus;
   BatchReports.BatchRunMode := R_Setup;
   AReport.Saved := False;
   BatchReports.RunReport(AReport);
end;



procedure TfrmBatchReports.UpdateActions;
var Node : PVirtualNode;
    Lrpt : TReportBase;
begin
   BatchReports.Selected.Clear;

   Node := ReportTree.GetFirst;
   while Assigned(Node) do begin
      lrpt := TReportBase(ReportList.GetNodeItem(Node));
      if Assigned(lrpt) then
      if GetReportLevel(Lrpt) = L_Report then
      if Lrpt.Selected then
         BatchReports.Selected.Add(Lrpt);
      Node := ReportTree.GetNext(Node);
   end;

   if BatchReports.Selected.Count = 0 then begin
      acRunNow.Enabled := False;
      //acRunNow.Caption := 'Generate Reports';
   end else if BatchReports.Selected.Count = 1 then begin
      acRunNow.Enabled := True;
      //acRunNow.Caption := 'Generate Report';
   end else begin
      acRunNow.Enabled := True;
      //acRunNow.Caption := 'Generate Reports';
   end;

  inherited;
end;

end.
