unit CodingRepDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:    Coding Report Settings Dlg

  Written:  1998
  Authors:  Matthew

  Purpose:  Allows the user to select options and date range for the coding report

  Notes:    Uses new report object which allows print to file
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface
//------------------------------------------------------------------------------

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, OvcABtn, OvcBase, OvcEF, OvcPB, OvcPF, Menus, OvcDate,clObj32,
  ExtCtrls, ComCtrls, AccountSelectorFme, OmniXML,UBatchBase, DateSelectorFme, RptParams,
  OsFont, CheckLst, BKReportColumnManager, UserReportSettings, CustomColumnFme;


type
  TCodingReportSettings = class (TRPTParameters)
  protected
    procedure LoadFromClient (Value : TClientObj); override;
    procedure SaveToClient (Value : TClientObj); override;
  private
    FColManager: TCodingReportColumnList;
    FRuleLineBetweenColumns: Boolean;
    FCustomReport: Boolean;
    FInitialLoad: Boolean;
    procedure SetRuleLineBetweenColumns(const Value: Boolean);
    procedure SetCustomReport(const Value: Boolean);
  public
    Style        : byte;
    Sort         : byte;
    Include      : byte;
    Leave        : byte;
    Rule         : boolean;
    TaxInvoice   : boolean;
    ShowOtherParty : boolean;
    WrapNarration : boolean;
    constructor Create(aType: Integer; aClient: TClientObj;
                       batch : TReportBase; const ADateMode : tDateMode = dNone);
    destructor Destroy; override;
    procedure LoadCustomReportXML(CustomReportXML: WideString); overload;
    procedure LoadCustomReportXML; overload;
    procedure ReadFromNode(Value : IXMLNode); override;
    procedure SaveCustomReportXML(var CustomReportXML: WideString); overload;
    procedure SaveCustomReportXML; overload;
    procedure SaveToNode(Value : IXMLNode); override;
    property ColManager: TCodingReportColumnList read FColManager;
    property CustomReport: Boolean read FCustomReport write SetCustomReport;
    property RuleLineBetweenColumns: Boolean read FRuleLineBetweenColumns write SetRuleLineBetweenColumns;
  end;

  TdlgCodingRep = class(TForm)
    PageControl1: TPageControl;
    tbsOptions: TTabSheet;
    tbsAdvanced: TTabSheet;
    pnlButtons: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnPrint: TButton;
    btnCancel: TButton;
    Panel2: TPanel;
    lblData: TLabel;
    eDateSelector: TfmeDateSelector;
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    chkRuleLine: TCheckBox;
    cmbStyle: TComboBox;
    cmbSort: TComboBox;
    cmbInclude: TComboBox;
    cmbLeave: TComboBox;
    chkTaxInvoice: TCheckBox;
    Panel3: TPanel;
    fmeAccountSelector1: TfmeAccountSelector;
    chkWrap: TCheckBox;
    BtnSave: TBitBtn;
    chkRuleVerticalLine: TCheckBox;
    pnlNZOnly: TPanel;
    lblDetailsToShow: TLabel;
    rbShowNarration: TRadioButton;
    rbShowOtherParty: TRadioButton;
    dlgLoadCRL: TOpenDialog;
    dlgSaveCRL: TSaveDialog;
    tbsColumns: TTabSheet;
    fmeCustomColumn1: TfmeCustomColumn;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnFileClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure cmbStyleChange(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
  private
    { Private declarations }
    FDataFrom, FDataTo : integer;
    okPressed : boolean;
    FPressed: integer;
    FReportParams: TCodingReportSettings;

    function CheckOK(DoDates: Boolean = True) :boolean;
    procedure ApplyCRSettings(CRSettings : TCodingReportSettings);
    procedure SetPressed(const Value: integer);
    procedure SetDateFromTo( DFrom, DTo : tSTDate );
    procedure SetReportParams(const Value: TCodingReportSettings);
    procedure SaveDlgValuesToParams;
  protected
    procedure UpdateActions; override;
  public
    { Public declarations }
    function Execute:boolean;
    procedure ApplySettings;
    property Pressed : integer read FPressed write SetPressed;
    property ReportParams: TCodingReportSettings read FReportParams write SetReportParams;
  end;


function GetCRParameters(var CRSettings : TCodingReportSettings): boolean;


//******************************************************************************
implementation

uses
  DlgAddFavourite,
  dlgSaveBatch,
  bkConst,
  BKHelp,
  bkXPThemes,
  SelectDate,
  globals,
  ReportDefs,
  bkDateUtils,
  ClDateUtils,
  InfoMoreFrm,
  WarningMoreFrm,
  ComboUtils,
  baObj32,
  omnixmlUtils,
  Imagesfrm,
  StdHints,
  WinUtils;

{$R *.DFM}

//------------------------------------------------------------------------------
function CheckAcc(CRSettings: TCodingReportSettings; Value : Pointer): Boolean;
var
  j : Integer;
begin
  Result := False;
  for j := 0 to Pred(CRSettings.AccountList.Count) do
    if (Value = CRSettings.AccountList.Items[j]) then begin
      Result := True;
      Exit;
    end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.FormCreate(Sender: TObject);
var
  i : integer;
begin
  bkXPThemes.ThemeForm( Self);

  okPressed := false;

  //load lists
  fmeAccountSelector1.LoadAccounts( MyClient, BKCONST.TransferringJournalsSet);
  fmeAccountSelector1.btnSelectAllAccounts.Click;

  for i := 0 to rsMax do cmbStyle.Items.Add(rsNames[i]);
  for i := 0 to esMax do cmbInclude.Items.Add(esNames[i]);

  cmbSort.Clear;
  for i := csMin to csMax do
  begin
    case csSortByOrder[i] of
      csDateEffective, csReference, csChequeNumber, csDatePresented,
      csAccountCode, csByValue :
        begin
          cmbSort.Items.AddObject(csNames[csSortByOrder[i]], TObject(csSortByOrder[i]));
        end;

      csByNarration :
        begin
          if MyClient.clFields.clCountry = whNewZealand then
            cmbSort.Items.AddObject('Narration/Other Party', TObject(csSortByOrder[i]))
          else
            cmbSort.Items.AddObject(csNames[csSortByOrder[i]], TObject(csSortByOrder[i]));
        end;
    end;
  end;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
      btnSave.Hide;

  SetUpHelp;
  PageControl1.ActivePage := tbsOptions;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCodingRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbStyle.Hint                   :=
                                   'Select the layout/style for the report|' +
                                   'Select the layout/style for the report';
   cmbSort.Hint                    :=
                                   'Select the Sort Order for the transactions|' +
                                   'Select the Sort Order in which the transactions will be reported';
   cmbInclude.Hint                 :=
                                   'Select which transactions to include|' +
                                   'Include all or uncoded or invalidly coded transactions or transactions with invalid GST Rate';
   cmbLeave.Hint                   :=
                                   'Leave this number of blank line(s) between printed lines|' +
                                   'Leave lines to provide room for writing coding information';
   chkRuleLine.hint                :=
                                   'Rule a line after each entry|' +
                                   'Rule a line after each entry to visually separate the entries';
   chkTaxInvoice.hint              :=
                                   'Show a tax invoice check box|'+
                                   'Show a check box which can be ticked if a tax invoice exists for the entry';
   chkWrap.hint                    :=
                                   'Wrap narration text|'+
                                   'Wrap narration text to show the entire narration';
   btnPreview.Hint                 :=
                                   STDHINTS.PreviewHint;
   btnPrint.Hint                   :=
                                   STDHINTS.PrintHint;
end;

procedure TdlgCodingRep.UpdateActions;
begin
  inherited;
  fmeCustomColumn1.UpdateActions;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.FormShow(Sender: TObject);
begin
  eDateSelector.eDateFrom.SetFocus;
  cmbStyleChange(Sender);
end;

procedure TdlgCodingRep.PageControl1Change(Sender: TObject);
begin
   case PageControl1.ActivePageIndex of
   2: self.HelpContext := BKH_Setting_up_a_custom_Coding_Report;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.btnPrintClick(Sender: TObject);
begin
   if checkOK then
   begin
      Pressed := BTN_PRINT;
      okPressed := true;
      close;
   end;
end;
procedure TdlgCodingRep.BtnSaveClick(Sender: TObject);
begin
   if checkOK(False) then begin

      if not FReportParams.CheckForBatch('Coding',Self.Caption) then
         Exit;

      Pressed := BTN_SAVE;
      okPressed := true;
      close;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.ApplyCRSettings(CRSettings: TCodingReportSettings);
var
  i: Integer;
  TmpPointer: Pointer;
begin
  with  CRSettings do begin
    // Apply the settings to the dialog
    FDataFrom := ClDateUtils.BAllData( Client );
    fDataTo   := ClDateUtils.EAllData( Client );
    eDateSelector.ClientObj := Client;
    eDateSelector.InitDateSelect( fDataFrom,
                                  fDataTo,
                                  cmbStyle);
    lblData.caption := 'There are entries from ' +
                                 bkDate2Str(fDataFrom) + ' to ' +
                                 bkDate2Str(fDataTo);
    with Client.clFields do begin
      case clCountry of
        whAustralia :
          begin
            pnlNZOnly.Visible := False;
            chkTaxInvoice.Caption := 'Show &Tax Invoice check box and GST Amount';
            ComboUtils.SetComboIndexByIntObject(Sort, cmbSort);
            rbShowNarration.checked  := True;
            rbShowOtherParty.checked := False;
          end;

        whUK : begin
           pnlNZOnly.Visible := False;
           chkTaxInvoice.Caption := 'Show &Tax Invoice check box and VAT Amount';
           ComboUtils.SetComboIndexByIntObject(Sort, cmbSort);
           rbShowNarration.checked  := True;
           rbShowOtherParty.checked := False;
        end;

        whNewZealand:
          begin
            pnlNZOnly.Visible := True;
            chkTaxInvoice.Caption := 'Show &Tax Invoice check box';
            //NZ clients may have choosen to view other party.  In this case the
            //sort order will have been changed from narration so we need to change it
            //back so that it appears in the list.

            if Sort = csByOtherParty then
              ComboUtils.SetComboIndexByIntObject(csByNarration, cmbSort)
            else
              ComboUtils.SetComboIndexByIntObject(Sort, cmbSort);
            rbShowNarration.checked  := not ShowOtherParty;
            rbShowOtherParty.checked := ShowOtherParty;
          end;
        end;
        //gCodingDateFrom := clPeriod_Start_Date;
        //gCodingDateTo   := clPeriod_End_Date;
     end;
     SetDateFromTo(Fromdate, ToDate );

     cmbInclude.ItemIndex := Include;
     cmbLeave.ItemIndex := Leave;
     chkRuleLine.Checked := Rule;
     chkTaxInvoice.Checked := TaxInvoice;
     cmbStyle.ItemIndex := Style;
     chkWrap.Checked := WrapNarration;
     chkRuleVerticalLine.Checked := CRSettings.RuleLineBetweenColumns;
     //Orientation
     fmeCustomColumn1.rbLandscape.Checked := Boolean(CRSettings.ColManager.Orientation);
     fmeCustomColumn1.rbportrait.Checked := not fmeCustomColumn1.rbLandscape.Checked;

     //Load custom columns frame;
     fmeCustomColumn1.LoadCustomColumns;

     ReportParams := CRSettings;
  end;
  //Select Accounts
  for i := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Count) do begin
    TmpPointer := fmeAccountSelector1.AccountCheckBox.Items.Objects[i];
    if not CheckAcc(CRSettings, TmpPointer) then begin
      fmeAccountSelector1.AccountCheckBox.Checked[i] := False;
    end;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgCodingRep.ApplySettings;
begin
  //ApplySettings method with no params for callback from custom column frame
  ApplyCRSettings(FReportParams);
end;

procedure TdlgCodingRep.btnCancelClick(Sender: TObject);
begin
   close;
end;
//------------------------------------------------------------------------------
procedure TdlgCodingRep.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin
           eDateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin
           eDateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin
           eDateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;
//------------------------------------------------------------------------------
function TdlgCodingRep.Execute: boolean;
begin
   Pressed := BTN_NONE;
   Self.ShowModal;
   result := okPressed;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.SaveDlgValuesToParams;
begin
  if Assigned(FReportParams) then begin
    FReportParams.Style := cmbStyle.ItemIndex;
    FReportParams.ShowOtherParty := rbShowOtherParty.Checked;
    //Sort
    FReportParams.Sort := ComboUtils.GetComboCurrentIntObject(cmbSort);
    if FReportParams.ShowOtherParty and (FReportParams.Sort = csByNarration) then
      FReportParams.Sort := csByOtherParty
    else if not (FReportParams.Sort in [csDateEffective, csReference, csChequeNumber,
                                        csDatePresented, csAccountCode, csByValue,
                                        csByNarration]) then
      FReportParams.Sort := csDateEffective;
    //Include
    FReportParams.Include := cmbInclude.ItemIndex;
    //Leave lines
    FReportParams.Leave := cmbLeave.ItemIndex;
    //Horizontal line
    FReportParams.Rule := chkRuleLine.Checked;
    //Rule line between columns
    FReportParams.RuleLineBetweenColumns := chkRuleVerticalLine.Checked;
    //Show tax invoice box
    FReportParams.TaxInvoice := chkTaxInvoice.Checked;
    //Wrap
    FReportParams.WrapNarration := chkWrap.Checked;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.SetDateFromTo( DFrom, DTo : tSTDate );
// Sets the value of the Date Edit Boxes to the Popup selected values
begin
  eDateSelector.eDateFrom.AsStDate := BKNull2St( DFrom );
  eDateSelector.eDateTo.AsStDate   := BKNull2St( DTo );
end;
//------------------------------------------------------------------------------
function TdlgCodingRep.CheckOK(DoDates: Boolean = True): boolean;
var
  i : Integer;
begin
   Result := false;
   {now check the values are ok}
   if Dodates then begin
     if (not eDateSelector.ValidateDates) then begin
        Pagecontrol1.ActivePage := tbsOptions;
        eDateSelector.eDateFrom.SetFocus;
        Exit;
     end;

     if (eDateSelector.eDateFrom.AsStDate > eDateSelector.eDateTo.AsStDate)
     and not (eDateSelector.eDateTo.asStDate = -1) then begin
        HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
        Pagecontrol1.ActivePage := tbsOptions;
        eDateSelector.eDateTo.SetFocus;
        Exit;
     end;
   end;
     //check if any accounts have been selected
   with fmeAccountSelector1 do
     for I := 0 to AccountCheckBox.Items.Count - 1 do
       if (AccountCheckBox.Checked[i]) then begin
           Result := True;
           break;
       end;

   if (not Result) then begin
      HelpfulWarningMsg('No accounts have been selected.',0);
      Pagecontrol1.ActivePage := tbsAdvanced;
      fmeAccountSelector1.chkAccounts.SetFocus;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.cmbStyleChange(Sender: TObject);
begin
  with FReportParams do begin
    CustomReport := (cmbStyle.ItemIndex = rsCustom);
    if FReportParams.BatchRunMode = R_Normal then begin
      LoadFromClient(MyClient);
      Style := cmbStyle.ItemIndex; //save selected style
      ApplyCRSettings(FReportParams);
    end;

    //Set control states
    tbsColumns.TabVisible := CustomReport;
//    chkWrap.Visible := not CustomReport;
    chkTaxInvoice.Visible := not CustomReport;
    lblDetailsToShow.Visible := not CustomReport;
    rbShowNarration.Visible := not CustomReport;
    rbShowOtherParty.Visible := not CustomReport;
  end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.SetReportParams(const Value: TCodingReportSettings);
begin
  FReportParams := Value;
  if assigned(FReportParams) then begin
     FReportParams.SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnPrint);
     if Assigned(FReportParams.RptBatch) then
        Caption := 'Coding Report [' +FReportParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.btnPreviewClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed := BTN_PREVIEW;
     okPressed := true;
     close;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgCodingRep.btnFileClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed := BTN_FILE;
     okPressed := true;
     close;
   end;
end;

//------------------------------------------------------------------------------
function GetCRParameters(var CRSettings : TCodingReportSettings) : boolean;
var
  CodingRep : TdlgCodingRep;
  i         : integer;
begin
   // Fill the Settings from the Client..

   if CRSettings.BatchRun  then begin
      CRSettings.RunBtn := BTN_PRINT;
      Result := true;
      exit;
   end;

   // Still here, run the dialog..

   Result := false;
   CRSettings.RunBtn := BTN_NONE;
   CodingRep := TdlgCodingRep.Create(Application.MainForm);
   with CodingRep do begin
      try
        BKHelpSetup(CodingRep, BKH_Producing_a_coding_report);

        //Custom coding report settings
        fmeCustomColumn1.CustomReportType := crCoding;
        fmeCustomColumn1.ReportParams := CRSettings;
        fmeCustomColumn1.OnApplySettings := CodingRep.ApplySettings;
        fmeCustomColumn1.OnSaveSettings := CodingRep.SaveDlgValuesToParams;        

        //Apply setting to dialog
        CodingRep.ApplyCRSettings(CRSettings);

        //*******************
        if Execute then begin
        //*******************
           with CRSettings do begin
              // Get the settings from the dialog..
              SaveDlgValuesToParams;

              //Dates
              Fromdate := StNull2BK( eDateSelector.eDateFrom.AsStDate );
              Todate   := StNull2BK( eDateSelector.eDateTo.AsStDate );
              if ToDate   = 0 then
                 ToDate   := MaxInt;

              //Orientation
              CRSettings.ColManager.Orientation :=  BK_PORTRAIT;
              if fmeCustomColumn1.rbLandscape.Checked then
                CRSettings.ColManager.Orientation :=  BK_LANDSCAPE;
           end;

           CRSettings.AccountList.Clear;
           //add selected bank accounts to a tlist for used by coding report
           for i := 0 to fmeAccountSelector1.AccountCheckBox.Count-1 do
             if fmeAccountSelector1.AccountCheckBox.Checked[i] then
             begin
               CRSettings.AccountList.Add(fmeAccountSelector1.AccountCheckBox.Items.Objects[i])
             end;

           CRSettings.RunBtn := Pressed;

           case CRSettings.BatchRunMode of
           R_Normal : begin
                  CRSettings.SaveClientSettings;
                  Result := true;
               end;
           R_Setup,
           R_BatchAdd : if pressed = BTN_SAVE then begin
                  Result := False;
                  CRSettings.RunBtn := BTN_NONE;
                  case CRSettings.Style of // Update the title..
                  rsStandard   : CRSettings.RptBatch.Title := Report_List_Names[REPORT_CODING_STANDARD];
                  rsTwoColumn  : CRSettings.RptBatch.Title := Report_List_Names[REPORT_CODING_TWOCOL];
                  rsStandardWithNotes  : CRSettings.RptBatch.Title := Report_List_Names[Report_Coding_Standard_With_Notes];
                  rsTwoColumnWithNotes : CRSettings.RptBatch.Title := Report_List_Names[REPORT_CODING_TWOCOL_WITH_NOTES];
                  rsCustom : CRSettings.RptBatch.Title := Report_List_Names[REPORT_CODING];
                  end;

                   // Just save it to the node..
                  CRSettings.SaveNodeSettings;

              end else begin
                  // Run as is..
                  Result := True;
              end;

           R_Batch : if pressed = BTN_SAVE then begin
                       // Previous
                  Result := False;
               end else begin
                  CRSettings.SaveClientSettings;
                  Result := True;
               end;
           end;//Case

        end;// Execute
      finally
        Free;
      end;
   end;
end;

//------------------------------------------------------------------------------

{ TCodingReportSettings }

constructor TCodingReportSettings.Create(aType: Integer; aClient: TClientObj;
  batch: TReportBase; const ADateMode: tDateMode);
begin
  //Need to do the follwing before inherited create - not sure why yet?
  FColManager := TCodingReportColumnList.Create(aClient);
  FInitialLoad := True;

  inherited Create(aType, aClient, batch, ADateMode);
end;
//------------------------------------------------------------------------------
destructor TCodingReportSettings.Destroy;
begin
  FColManager.Free;
  inherited;
end;

//------------------------------------------------------------------------------
procedure TCodingReportSettings.LoadCustomReportXML;
begin
  LoadCustomReportXML(Client.clExtra.ceCustom_Coding_Report_XML);
end;

//------------------------------------------------------------------------------
procedure TCodingReportSettings.LoadCustomReportXML(CustomReportXML: WideString);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  Document := CreateXMLDoc;
  try
    Document.LoadXML(CustomReportXML);
    if Document.XML <> '' then begin
      Node := Document.FirstChild;
      if Node.NodeName = 'CodingReportLayout' then
        ReadFromNode(Node);
    end;
  finally
    Document := nil;
  end;
end;

procedure TCodingReportSettings.LoadFromClient(Value: TClientObj);
begin
  with Value.clFields do begin
    //Load initial report style and settings
    if FInitialLoad then begin
      FInitialLoad := False;
      //Keep the date settings if report is toggled between std and custom
      Fromdate := clPeriod_Start_Date;
      Todate   := clPeriod_End_Date;
      CustomReport := Value.clExtra.ceCustom_Coding_Report;
      if not CustomReport then
        Style := clCoding_Report_Style;
    end;

    //Load or re-load Settings
    if CustomReport then
      LoadCustomReportXML
    else begin
      Sort       := clCoding_Report_Sort_Order;
      Include    := clCoding_Report_Entry_Selection;
      Leave      := clCoding_Report_Blank_Lines;
      Rule       := clCoding_Report_Rule_Line;
      RuleLineBetweenColumns := Value.clExtra.ceCoding_Report_Column_Line;
      TaxInvoice := clCoding_Report_Print_TI;
      ShowOtherParty := clCoding_Report_Show_OP;
      WrapNarration := clCoding_Report_Wrap_Narration;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TCodingReportSettings.SaveCustomReportXML;
var
  TempWideStr: WideString;
begin
  SaveCustomReportXML(TempWideStr);
  Client.clExtra.ceCustom_Coding_Report_XML := TempWideStr;
end;

//------------------------------------------------------------------------------
procedure TCodingReportSettings.SaveCustomReportXML(
  var CustomReportXML: WideString);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  CustomReportXML := '';
  Document := CreateXMLDoc;
  try
    Document.Text := '';
    Node := Document.AppendChild(Document.CreateElement('CodingReportLayout'));
    SaveToNode(Node);
    CustomReportXML := Document.XML;
  finally
    Document := nil;
  end;
end;

procedure TCodingReportSettings.SaveToClient(Value: TClientObj);
begin
  Client.clExtra.ceCustom_Coding_Report := CustomReport;
  if CustomReport then begin
    SaveCustomReportXML;
    Client.clFields.clCoding_Report_Style := rsCustom;
  end else
    with Client.clFields do begin
      clCoding_Report_Style           := Style;
      clCoding_Report_Sort_Order      := Sort;
      clCoding_Report_Entry_Selection := Include;
      clCoding_Report_Blank_Lines     := Leave;
      clCoding_Report_Rule_Line       := Rule;
      clCoding_Report_Print_TI        := TaxInvoice;
      clCoding_Report_Show_OP         := ShowOtherParty;
      clCoding_Report_Wrap_Narration  := WrapNarration;
      Client.clExtra.ceCoding_Report_Column_Line := RuleLineBetweenColumns;
    end;
end;

//------------------------------------------------------------------------------
procedure TCodingReportSettings.ReadFromNode(Value: IXMLNode);
var s : string;
    i : integer;
begin
  s :=  GetNodeTextStr(Value,'Style',rsNames[Style]);
  for i := 0 to rsMax do
    if SameText(s,rsNames[i]) then begin
       Style := i;
       Break;
    end;

  s :=  GetNodeTextStr(Value,'Sort',csNames[sort]);
  for i := 0 to csMax do
     {if (i = csByNarration)
     and(Client.clFields.clCountry = whNewZealand) then
        if sametext( 'Narration/Other Party', s) then begin
           Sort := i;
           Break;
        end else} if SameText(s,csNames[i]) then begin
           Sort := i;
           Break;
        end;

  s :=  GetNodeTextStr(Value,'Include',esNames[Include]);
  for i := 0 to esMax do
    if SameText(s,Trim(esNames[i])) then begin
       Include := i;
       Break;
    end;


  Leave := GetNodeTextInt(Value,'Leave_Lines',Leave);
  //Upgraded Xml node name
  if FindNode(Value, 'Rule_a_Line') <> nil then
    Rule := GetNodeBool(Value, 'Rule_a_Line', Rule)
  else
    Rule := GetNodeBool(Value, 'Rule_Line_Between_Entries', Rule);
  TaxInvoice := GetNodeBool(Value,'Show_Tax_Invoice',TaxInvoice);
  ShowOtherParty := GetNodeBool(Value,'Show_Other_Party',ShowOtherParty);
  WrapNarration := GetNodeBool(Value,'Wrap_Narration',WrapNarration);
  RuleLineBetweenColumns := GetNodeBool(Value,'Rule_Line_Between_Columns',FRuleLineBetweenColumns);
  ColManager.ReadFromNode(Value);
end;
//------------------------------------------------------------------------------
procedure TCodingReportSettings.SaveToNode(Value: IXMLNode);
begin
  inherited;
  SetNodeTextStr(Value,'Style',rsNames[Style]);
  SetNodeTextStr(Value,'Sort',csNames[Sort]);
  SetNodeTextStr(Value,'Include',esNames[Include]);
  SetNodeTextInt(Value,'Leave_Lines',Leave);
  SetNodeBool(Value,'Rule_Line_Between_Entries',Rule);
  SetNodeBool(Value,'Show_Tax_Invoice',TaxInvoice);
  SetNodeBool(Value,'Show_Other_Party',ShowOtherParty);
  SetNodeBool(Value,'Wrap_Narration',WrapNarration);
  SetNodeBool(Value,'Rule_Line_Between_Columns',FRuleLineBetweenColumns);
  ColManager.SaveToNode(Value);
  SaveAccounts(Value);
end;

procedure TCodingReportSettings.SetCustomReport(const Value: Boolean);
begin
  FCustomReport := Value;
end;

procedure TCodingReportSettings.SetRuleLineBetweenColumns(const Value: Boolean);
begin
  FRuleLineBetweenColumns := Value;
end;

end.
