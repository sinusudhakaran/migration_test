unit LedgerRepDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Select the parameters for the Ledger Report
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  RptParams, UBatchBase, OmniXML, OmniXMLUtils, Windows, Messages, SysUtils,
  Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons,
  ExtCtrls, clobj32, DateSelectorFme, RzLstBox, RzChkLst, ComCtrls,
  TSGrid, AccountSelectorFme, OSFont, Grids_ts,
  BKLedgerRptColumnManager, CustomColumnFme;

const
  MaxListLedgerRanges = 20;

type
  TLedgerRange = record
    FromCode : string;
    ToCode : string;
  end;

  TListLedgerRangesArray = Array[ 0..MaxListLedgerRanges -1] of TLedgerRange;

  TLRParameters = class (TRPTParameters)
  private
    FColManager: TLedgerReportColumnList;
    FShowSuperDetails: Boolean;
    procedure SetShowSuperDetails(const Value: Boolean);
 protected
   procedure Reset; override;
   procedure LoadFromClient ( Value : TClientObj); override;
   procedure SaveToClient  (Value : TClientObj);override;
 public
   // if someone has nothing to do for a bit..
   // make them properties..
   ShowQuantity : boolean;
   SummaryReport : Boolean;
   IncludeNonTransferring : Boolean;
   ShowAllCodes : boolean;
   RangesArray : TListLedgerRangesArray;
   PrintEmptyCodes: Boolean;
   ShowNotes: Boolean;
   ShowBalances: Boolean;
   SpanYear : Boolean;
   BankContra: Byte;
   GSTContra: Byte;
   GrossGst: Boolean;
   WrapNarration: Boolean;
   SuperfundTitle: Widestring;
   constructor Create(aType: Integer; aClient: TClientObj;
                      aReportBase : TReportBase;
                      const aDateMode : tDateMode = dNone);
   destructor Destroy; override;
   procedure LoadCustomReportXML(CustomReportXML: WideString); overload;
   procedure LoadCustomReportXML; overload;
   procedure SaveCustomReportXML(var CustomReportXML: WideString); overload;
   procedure SaveCustomReportXML; overload;
   procedure ReadFromNode (Value : IXMLNode); override;
   procedure SaveToNode   (Value : IXMLNode); override;
   property ColManager: TLedgerReportColumnList read FColManager;
   property ShowSuperDetails: Boolean read FShowSuperDetails write SetShowSuperDetails;
 end;

type
  TdlgLedgerRep = class(TForm)
    PageControl1: TPageControl;
    tsOptions: TTabSheet;
    tsAdvanced: TTabSheet;
    pnlButtons: TPanel;
    btnPreview: TButton;
    btnFile: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    GroupBox1: TGroupBox;
    GroupBox3: TGroupBox;
    fmeAccountSelector1: TfmeAccountSelector;
    GroupBox4: TGroupBox;
    rbSummarised: TRadioButton;
    rbDetailed: TRadioButton;
    chkBalances: TCheckBox;
    GroupBox5: TGroupBox;
    Label1: TLabel;
    rbAllCodes: TRadioButton;
    rbSelectedCodes: TRadioButton;
    GroupBox6: TGroupBox;
    DateSelector: TfmeDateSelector;
    pnlSelectedCodes: TGroupBox;
    pnlAllCodes: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    btnChart: TSpeedButton;
    tgRanges: TtsGrid;
    Label3: TLabel;
    rbGSTContraAll: TRadioButton;
    rbGSTContraTotal: TRadioButton;
    Label5: TLabel;
    chkQuantity: TCheckBox;
    chkNotes: TCheckBox;
    chkGross: TCheckBox;
    Label9: TLabel;
    Panel1: TPanel;
    rbBankContraTotal: TRadioButton;
    rbBankContraAll: TRadioButton;
    chkEmptyCodes: TCheckBox;
    chkIncludeNonTransferring: TCheckBox;
    cbBankContra: TCheckBox;
    cbGSTContra: TCheckBox;
    chkWrap: TCheckBox;
    btnSaveTemplate: TButton;
    btnLoad: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    btnSave: TBitBtn;
    tbsSuperDetails: TTabSheet;
    fmeCustomColumn1: TfmeCustomColumn;
    chkSuperfundDetails: TCheckBox;
    pTitle: TPanel;
    Pleft: TPanel;
    pRight: TPanel;
    PRtitle: TPanel;
    Panel3: TPanel;
    pUTitle: TPanel;
    ETitle: TEdit;
    Label2: TLabel;
    btnEmail: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure rbSelectedCodesClick(Sender: TObject);
    procedure rbAllCodesClick(Sender: TObject);
    procedure tgRangesCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgRangesEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure btnChartClick(Sender: TObject);
    procedure tgRangesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure rbDetailedClick(Sender: TObject);
    procedure tgRangesKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbBankContraClick(Sender: TObject);
    procedure cbGSTContraClick(Sender: TObject);
    procedure btnSaveTemplateClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);
    procedure tgRangesResize(Sender: TObject);
    procedure chkSuperfundDetailsClick(Sender: TObject);
    procedure chkWrapClick(Sender: TObject);
    procedure chkBalancesClick(Sender: TObject);
    procedure chkNotesClick(Sender: TObject);
    procedure chkQuantityClick(Sender: TObject);
    procedure chkGrossClick(Sender: TObject);
    procedure fmeCustomColumn1btnSaveTemplateClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FDataFrom, FDataTo : integer;
    okPressed : boolean;
    FPressed: integer;
    RemovingMask : boolean;
    FReportParams: TLRParameters;
    function CheckOK(DoDates : Boolean = True) : boolean;
    procedure SetPressed(const Value: integer);
    procedure ActivateApplication(Sender: TObject);
    procedure SetReportParams(const Value: TLRParameters);
    procedure UpdateContraSettings;
  public
    { Public declarations }
    CodesArray : TListLedgerRangesArray;
    procedure loadParam  (Value : TLRParameters;const Previewed : Boolean = False);
    procedure ReadParams (Value : TLRParameters);
    procedure ApplyColumnSettings;
    procedure SaveColumnSettings;
    function UpdateColManager: boolean;
    function  Execute : boolean;
    property  Pressed : integer read FPressed write SetPressed;
    property ReportParams: TLRParameters read FReportParams write SetReportParams;
  end;

function GetLRParameters( Param : TLRParameters;
                          const Previewed: Boolean) : boolean;

//******************************************************************************
implementation

uses
  AccountLookupFrm,
  BKHelp,
  SelectDate,
  globals,
  InfoMoreFrm,
  ErrorMoreFrm,
  ImagesFrm,
  ReportDefs,
  bkDateUtils,
  ClDateUtils,
  bkMaskUtils,
  StdHints, StDate, BKDefs,
  BKConst,bkXPThemes, baObj32, WarningMoreFrm,
  Software,
  BKReportColumnManager,
  UserReportSettings;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgLedgerRep.FormCreate(Sender: TObject);
var
  TaxName : String;
begin
  bkXPThemes.ThemeForm(Self);


  fDataFrom := ClDateUtils.BAllData( MyClient );
  fDataTo   := ClDateUtils.EAllData( MyClient );

  removingMask := False;

  TaxName := MyClient.TaxSystemNameUC;

  chkGross.Caption := '&Gross and ' + TaxName + ' Amounts';
  chkGross.Hint := 'Check to show Gross Amount and ' + TaxName + ' Amount in the Report';

  cbGSTContra.Caption := TaxName + ' Control Acco&unt(s)';

  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( fDataFrom, fDataTo, btnPreview);

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_CHART_BMP,btnChart.Glyph);

  FillChar( CodesArray, SizeOf( TListLedgerRangesArray), #0);
  tgRanges.Rows := MaxListLedgerRanges;

  //align panels so they occupy the same space
  pnlAllCodes.Left := pnlSelectedCodes.Left;
  pnlAllCodes.Width := pnlSelectedCodes.Width;

  tgRanges.Col[1].MaxLength := bkconst.MaxBK5CodeLen;
  tgRanges.Col[2].MaxLength := bkconst.MaxBK5CodeLen;

  PRtitle.Font.Style := PRtitle.Font.Style  + [fsBold];
  PUtitle.Font.Style := PUtitle.Font.Style  + [fsBold];

  {$IFDEF SmartBooks}
  LastYear1.Visible := false;
  AllData1.Visible  := false;
  {$ENDIF}

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;

  //load lists
  fmeAccountSelector1.LoadAccounts( MyClient, BKCONST.TransferringJournalsSet);
  fmeAccountSelector1.btnSelectAllAccounts.Click;
  PageControl1.ActivePage := tsOptions;
  SetUpHelp;

  btnLoad.Enabled := not CurrUser.HasRestrictedAccess;
  btnSaveTemplate.Enabled := not CurrUser.HasRestrictedAccess;
end;
//------------------------------------------------------------------------------
procedure TdlgLedgerRep.ActivateApplication(Sender: TObject);
begin
  // There are strange focus problems on some machines - try to always bring the
  // whole app back when it gets activated...
  Application.BringToFront;
end;
//------------------------------------------------------------------------------
procedure TdlgLedgerRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   chkQuantity.Hint    :=
                       'Check to show quantity and average figures in the Report|' +
                       'Check to show quantity and average figures in the Report';
   rbSummarised.Hint   :=
                       'Only show summary totals on Report';
   rbDetailed.Hint     :=
                       'Show detailed information on Report';
   btnPreview.Hint     :=
                       STDHINTS.PreviewHint;
   btnOK.Hint          :=
                       STDHINTS.PrintHint;
end;

//------------------------------------------------------------------------------
procedure TdlgLedgerRep.ApplyColumnSettings;
var
  SaveFromDate, SaveToDate: integer;
begin
  //Don't load the from/to dates from a template
  SaveFromDate := DateSelector.eDateFrom.AsStDate;
  SaveToDate   := DateSelector.eDateTo.AsStDate;

  LoadParam(FReportParams);

  DateSelector.eDateFrom.AsStDate := SaveFromDate;
  DateSelector.eDateTo.AsStDate := SaveToDate;

  //Orientation
  fmeCustomColumn1.rbLandscape.Checked := Boolean(FReportParams.ColManager.Orientation);
  fmeCustomColumn1.rbportrait.Checked := not fmeCustomColumn1.rbLandscape.Checked;

  if not UpdateColManager then begin
    FReportParams.FColManager.UpdateColumns;
    //Load custom columns frame;
    fmeCustomColumn1.LoadCustomColumns;
  end;
end;

procedure TdlgLedgerRep.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
procedure TdlgLedgerRep.btnOKClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_PRINT;
     okPressed := true;
     close;
   end;
end;
//------------------------------------------------------------------------------
function TdlgLedgerRep.CheckOK(DoDates : Boolean = True): boolean;
var
  i : integer;
  AtLeastOneRangeEntered : boolean;
begin
   result := false;
   {now check the values are ok}
   if DoDates then begin
      if (not DateSelector.ValidateDates) then
         Exit;

      if (DateSelector.eDateFrom.AsStDate > DateSelector.eDateTo.AsStDate) then
      begin
         HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
         PageControl1.ActivePage := tsOptions;
         DateSelector.SetFocus;
         Exit;
      end;
   end;

   if not chkIncludeNonTransferring.Checked then // Don't have to select accounts if non-trf selected
   begin
     //check if any accounts have been selected
     with fmeAccountSelector1 do
     begin
       i := 0;
       while (i < AccountCheckBox.Items.Count) and (not Result) do
       begin
         if (AccountCheckBox.Checked[i]) then
           Result := True;
         Inc(i);
       end;
       if (not Result) then
       begin
         HelpfulWarningMsg('No accounts have been selected.',0);
         PageControl1.ActivePage := tsAdvanced;
         fmeAccountSelector1.chkAccounts.SetFocus;
         Exit;
       end;
     end;
   end;

   //check ranges, if user reported on selected codes then at least one range
   //must be entered
   if rbSelectedCodes.Checked then
   begin
     tgRanges.EndEdit( False);

     AtLeastOneRangeEntered := false;
     for i := Low(CodesArray) to High(CodesArray) do
     begin
       if (CodesArray[i].FromCode <> '') or ( CodesArray[i].ToCode <> '') then
       begin
         AtLeastOneRangeEntered := true;
         //make sure that from code < to code
         if ( CodesArray[i].ToCode <> '') and (MyClient.AccountCodeCompare(CodesArray[i].FromCode, CodesArray[i].ToCode) > 0 ) then
         begin
            HelpfulInfoMsg(  'The range ' + CodesArray[i].FromCode + ' to ' +
                           CodesArray[i].ToCode + ' is invalid. '+
                           #13#13'Please select a valid range.', 0);
            PageControl1.ActivePage := tsOptions;
            tgRanges.SetFocus;
            result := False;
            Exit;
         end;
       end;
     end;

     if not AtLeastOneRangeEntered then
     begin
       HelpfulInfoMsg( 'You must enter codes for at least one account range.', 0);
       PageControl1.ActivePage := tsOptions;
       tgRanges.SetFocus;
       Result := False;
       exit;
     end;
   end;

   result := true;
end;

procedure TdlgLedgerRep.chkBalancesClick(Sender: TObject);
begin
  UpdateColManager;
end;

procedure TdlgLedgerRep.chkGrossClick(Sender: TObject);
begin
  UpdateColManager;
end;

procedure TdlgLedgerRep.chkNotesClick(Sender: TObject);
begin
  UpdateColManager;
end;

procedure TdlgLedgerRep.chkQuantityClick(Sender: TObject);
begin
  UpdateColManager;
end;

procedure TdlgLedgerRep.chkSuperfundDetailsClick(Sender: TObject);
begin
  FReportParams.ShowSuperDetails := chkSuperfundDetails.Checked;
  tbsSuperDetails.TabVisible := FReportParams.ShowSuperDetails;
  UpdateContraSettings;
end;

procedure TdlgLedgerRep.chkWrapClick(Sender: TObject);
begin
  UpdateColManager;
end;

procedure TdlgLedgerRep.UpdateContraSettings;
var
  DetailedSuperRpt: Boolean;
  EnableBankContraSettings: Boolean;
  EnableGSTContraSettings: Boolean;
begin
  DetailedSuperRpt := (chkSuperfundDetails.Checked and rbDetailed.Checked);
  EnableBankContraSettings := cbBankContra.Checked and (not DetailedSuperRpt);
  EnableGSTContraSettings := cbGSTContra.Checked and (not DetailedSuperRpt);
  //Enable/Disabled
  rbBankContraTotal.Enabled := EnableBankContraSettings;
  rbBankContraAll.Enabled := EnableBankContraSettings;
  rbGSTContraTotal.Enabled := EnableGSTContraSettings;
  rbGSTContraAll.Enabled := EnableGSTContraSettings;
  //Total only for superfund
  if DetailedSuperRpt then begin
    rbBankContraTotal.Checked := True;
    rbGSTContraTotal.Checked := True;
  end;
  rbBankContraAll.Checked := not rbBankContraTotal.Checked;
  rbGSTContraAll.Checked := not rbGSTContraTotal.Checked;
end;

//------------------------------------------------------------------------------
procedure TdlgLedgerRep.SaveColumnSettings;
begin
  if Assigned(FReportParams) then
    ReadParams(FReportParams);
end;

procedure TdlgLedgerRep.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;

procedure TdlgLedgerRep.SetReportParams(const Value: TLRParameters);
begin
  FReportParams := Value;
  if assigned(FReportParams) then begin
     FReportParams.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,BtnSave,BtnOK);
     if Assigned(FReportParams.RptBatch) then
        Caption := Caption + ' [' + FReportParams.RptBatch.Name + ']';
  end else
    BtnSave.Hide;
end;

//------------------------------------------------------------------------------
procedure TdlgLedgerRep.btnPreviewClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed := BTN_PREVIEW;
     okPressed := true;
     close;
   end;
end;

procedure TdlgLedgerRep.BtnSaveClick(Sender: TObject);
begin
   if checkOK then begin
      if not FReportParams.CheckForBatch('Ledger', Self.Caption) then
         Exit;

      Pressed  := BTN_SAVE;
      okPressed := true;
      close;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgLedgerRep.btnFileClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_FILE;
     okPressed := true;
     close;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgLedgerRep.btnEmailClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_EMAIL;
     okPressed := true;
     close;
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgLedgerRep.ReadParams(Value: TLRParameters);
var i : Integer;
begin with Value do begin
   Reset;

   FromDate        := StNull2Bk(DateSelector.eDateFrom.AsStDate);
   Todate          := StNull2Bk(DateSelector.eDateTo.AsStDate);

   ShowQuantity    := chkQuantity.Checked;
   GrossGST        := chkGross.Checked;
   SummaryReport   := rbSummarised.Checked;
   IncludeNonTransferring := chkIncludeNonTransferring.Checked;
   ShowAllCodes    := rbAllCodes.Checked;
   PrintEmptyCodes := chkEmptyCodes.Checked;
   ShowNotes       := chkNotes.Checked;
   ShowBalances    := chkBalances.Checked;
   ShowSuperDetails := chkSuperfundDetails.Checked;
   SuperFundTitle  := ETitle.Text;
   tbsSuperDetails.TabVisible := FReportParams.ShowSuperDetails;

   WrapNarration   := chkWrap.Checked;
   if not cbBankContra.Checked then
      BankContra := Byte(bcNone)
   else if rbBankContraAll.Checked then
      BankContra := Byte(bcAll)
   else
      BankContra := Byte(bcTotal);

   if not cbGSTContra.Checked then
      GSTContra := Byte(gcNone)
   else if rbGSTContraAll.Checked then
      GSTContra := Byte(gcAll)
   else
      GSTContra := Byte(gcTotal);

   if ShowAllcodes then
      FillChar(RangesArray,Sizeof(RangesArray),0)
   else
      //Copy the array
      for i := Low(RangesArray) to High(RangesArray) do begin
         RangesArray[i].FromCode := CodesArray[i].FromCode;
         RangesArray[i].ToCode := CodesArray[i].ToCode;
      end;

   if ToDate = 0 then
      ToDate   := MaxInt;

   //add selected bank accounts to a tlist for used by report
   for i := 0 to fmeAccountSelector1.AccountCheckBox.Count-1 do
      if fmeAccountSelector1.AccountCheckBox.Checked[i] then
         AccountList.Add(fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);

   UpdateContraSettings;
end;end;

//------------------------------------------------------------------------------
function TdlgLedgerRep.Execute: boolean;
begin
   okPressed := false;
   Pressed := BTN_NONE;

   {display}
   Self.ShowModal;
   result := okPressed;
end;
procedure TdlgLedgerRep.fmeCustomColumn1btnSaveTemplateClick(Sender: TObject);
begin
  fmeCustomColumn1.btnSaveTemplateClick(Sender);

end;

//------------------------------------------------------------------------------

{ TLRParameters }

const
   t_ShowQuantity = 'Show_Quantities';
   t_SummaryReport = 'Summarised';
   t_IncludeNonTransferring = 'Show_Non_Transfering_Journals';
   //t_ShowAllCodes = ;
   t_PrintEmptyCodes = 'Include_Accounts_With_No_Movement';
   t_ShowNotes = 'Show_Notes';
   t_ShowBalances =  'Show_Opening_and_Closing_Balances';
   t_ShowSuperDetails =  'Show_Superfund_Details';   

   t_BankContra ='Bank_Contras';
   t_GSTContra ='GST_Control_Accounts';
   t_GrossGst = 'Show_Gross_and_GST';
   t_WrapNarration = 'Wrap_Narration';

   t_SuperfundTitle = 'User_Title';


constructor TLRParameters.Create(aType: Integer; aClient: TClientObj;
  aReportBase: TReportBase; const aDateMode: tDateMode);
begin
  //Need to do the follwing before inherited create
  FColManager := TLedgerReportColumnList.Create(aClient);

  inherited Create(aType, aClient, aReportBase, aDateMode);

  FColManager.UpdateColumns;
end;

destructor TLRParameters.Destroy;
begin
  FreeAndNil(FColManager);

  inherited;
end;

procedure TLRParameters.LoadCustomReportXML(CustomReportXML: WideString);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  Document := CreateXMLDoc;
  try
    Document.LoadXML(CustomReportXML);
    if Document.XML <> '' then begin
      Node := Document.FirstChild;
      if Node.NodeName = 'LedgerReportLayout' then
        ReadFromNode(Node);
    end;
  finally
    Document := nil;
  end;
end;

procedure TLRParameters.LoadCustomReportXML;
begin
  LoadCustomReportXML(Client.clExtra.ceCustom_Ledger_Report_XML);
end;

procedure TLRParameters.LoadFromClient(Value : TClientObj);
begin
   Reset;
   ShowSuperDetails := Value.clExtra.ceCustom_Ledger_Report;
   if ShowSuperDetails then
     LoadCustomReportXML
   else
     with Value.clFields, Value.clExtra do begin
        ShowQuantity := clLedger_Report_Show_Quantities;
        SummaryReport := clLedger_Report_Summary;
        IncludeNonTransferring := clLedger_Report_Show_Non_Trf;
        ShowAllCodes := True; //By default

        PrintEmptyCodes :=  clLedger_Report_Show_Inactive_Codes;
        ShowNotes := clLedger_Report_Show_Notes;
        ShowBalances := clLedger_Report_Show_Balances;
        BankContra := clLedger_Report_Bank_Contra;
        GSTContra := clLedger_Report_GST_Contra;
        GrossGst := clLedger_Report_Show_Gross_And_Gst;
        WrapNarration := clLedger_Report_Wrap_Narration;

        SuperFundTitle := Value.clExtra.ceCustom_SFLedger_Titles[1];
     end;
end;

procedure TLRParameters.ReadFromNode(Value: IXMLNode);

  function NoCodes : Boolean;
  var NN : IXMLNode;
      LList : IXMLNodeList;
      I : Integer;
  begin
     Result := True;
     NN := FindNode(Value,'Codes');
     if not assigned(NN) then exit;
     LList := FilterNodes(NN,'Code');
     if not assigned(LList) then exit;
     if LList.Length = 0 then exit;
     for I := 0 to LList.Length - 1 do begin
         if I > High(RangesArray) then exit;
         // Found at least one..
         Result := False;
         RangesArray[i].FromCode := GetNodeTextStr(LList.Item[I],'From','');
         RangesArray[i].ToCode   := GetNodeTextStr(LList.Item[I],'To','')
     end;
  end;

begin

   //Reset;  Uses Clent as default..

   ShowQuantity    :=  GetNodeBool(Value,t_ShowQuantity,ShowQuantity);
   SummaryReport   :=  GetNodeBool(Value,t_SummaryReport,SummaryReport);
   IncludeNonTransferring :=  GetNodeBool(Value,t_IncludeNonTransferring,IncludeNonTransferring);

   ShowAllCodes := NoCodes;

   PrintEmptyCodes :=  GetNodeBool(Value,t_PrintEmptyCodes,PrintEmptyCodes);
   ShowNotes       :=  GetNodeBool(Value,t_ShowNotes,ShowNotes);
   ShowBalances    :=  GetNodeBool(Value,t_ShowBalances,ShowBalances);

   BankContra  := GetContra(GetNodeTextStr(Value,t_BankContra,GetContraText(BankContra)));
   GSTContra   := GetContra(GetNodeTextStr(Value,t_GSTContra,GetContraText(GSTContra)));
   GrossGst    := GetNodeBool(Value,t_GrossGst,GrossGst);
   WrapNarration:=  GetNodeBool(Value,t_WrapNarration,WrapNarration);

   //Super Details
   ShowSuperDetails :=  GetNodeBool(Value,t_ShowSuperDetails,ShowSuperDetails);
   if ShowSuperDetails then begin
      ColManager.ReadFromNode(Value);
      GetNodeText(Value,t_SuperfundTitle,SuperFundTitle);
   end;
end;

procedure TLRParameters.Reset;
begin
   inherited;
   FillChar( RangesArray, SizeOf( TListLedgerRangesArray), #0);
end;

procedure TLRParameters.SaveCustomReportXML(var CustomReportXML: WideString);
var
  Document: IXMLDocument;
  Node: IXMLNode;
begin
  CustomReportXML := '';
  Document := CreateXMLDoc;
  try
    Document.Text := '';
    Node := Document.AppendChild(Document.CreateElement('LedgerReportLayout'));
    SaveToNode(Node);
    CustomReportXML := Document.XML;
  finally
    Document := nil;
  end;
end;

procedure TLRParameters.SaveCustomReportXML;
var
  TempWideStr: WideString;
begin
  SaveCustomReportXML(TempWideStr);
  Client.clExtra.ceCustom_Ledger_Report_XML := TempWideStr;
end;

procedure TLRParameters.SaveToClient(Value: TClientObj);
begin
  if ShowSuperDetails then begin
    Value.clExtra.ceCustom_Ledger_Report := true;
    if (RunBtn <> BTN_None) then  //Don't save if cancel clicked
      SaveCustomReportXML;
  end else
   with Value.clFields, Value.clExtra do begin
      clLedger_Report_Show_Quantities := ShowQuantity;
      clLedger_Report_Summary := SummaryReport;
      clLedger_Report_Show_Non_Trf := IncludeNonTransferring;
      //ShowAllCodes : boolean;
      //RangesArray : TListLedgerRangesArray;

      clLedger_Report_Show_Inactive_Codes := PrintEmptyCodes;
      clLedger_Report_Show_Notes := ShowNotes;
      clLedger_Report_Show_Balances := ShowBalances;
      ceCustom_Ledger_Report := ShowSuperDetails;
      //AccountList : TList;
      clLedger_Report_Bank_Contra := BankContra;
      clLedger_Report_GST_Contra := GSTContra;
      clLedger_Report_Show_Gross_And_Gst := GrossGst;
      clLedger_Report_Wrap_Narration := WrapNarration;
      if ShowSuperDetails then
         Value.clExtra.ceCustom_SFLedger_Titles[1] := SuperFundTitle;
   end;
end;

procedure TLRParameters.SaveToNode(Value: IXMLNode);

  function NoCodes : Boolean;
  var NN,AN : IXMLNode;
      I : Integer;
  begin
     Result := True;
     NN := nil;
     AN := nil;
     for I := Low(rangesArray) to High(RangesArray) do begin
         if (RangesArray[i].FromCode <> '')
         or (RangesArray[i].ToCode <> '') then begin
            // Got one..
            if Result  then begin
               Result := False;
               AN := EnsureNode(Value,'Codes');
               AN.Text := '';
            end;
            NN := AppendNode(AN,'Code');
            SetNodeTextStr(NN,'From',RangesArray[i].FromCode);
            SetNodeTextStr(NN,'To',RangesArray[i].ToCode)
         end;
     end;
  end;
begin
   inherited;


   SetNodeBool(Value,t_ShowQuantity,ShowQuantity);
   setNodeBool(Value,t_SummaryReport,SummaryReport);

   setNodeBool(Value,t_IncludeNonTransferring,IncludeNonTransferring);

   SetNodeBool(Value,t_PrintEmptyCodes,PrintEmptyCodes);
   SetNodeBool(Value,t_ShowNotes,ShowNotes);
   SetNodeBool(Value,t_ShowBalances,ShowBalances);

   SetNodeTextStr(Value,t_BankContra,GetContraText(BankContra));
   SetNodeTextStr(Value,t_GSTContra,GetContraText(GSTContra));
   SetNodeBool(Value,t_GrossGst,GrossGst);
   SetNodeBool(Value,t_WrapNarration,WrapNarration);
   if NoCodes then
      ClearSetting(Value,'Codes');
   saveAccounts(Value);

   SetNodeBool(Value,t_ShowSuperDetails,ShowSuperDetails);
   if ShowSuperDetails then begin
      ColManager.SaveToNode(Value);
      SetNodeText(Value,t_SuperfundTitle,SuperFundTitle);
   end;
end;

procedure TLRParameters.SetShowSuperDetails(const Value: Boolean);
begin
  FShowSuperDetails := Value;
end;

function GetLRParameters( Param : TLRParameters;
                          const Previewed: Boolean) : boolean;



  function RunDialog : Integer;
  var Mydlg : TdlgLedgerRep;
      I: Integer;
      ba: TBank_Account;
  begin
     Mydlg := TdlgLedgerRep.Create(Application.MainForm);
     Param.SpanYear := False;
     try
        BKHelpSetUp(MyDlg, BKH_Ledger_Report);

        //Custom coding report settings
        Mydlg.fmeCustomColumn1.CustomReportType := crSuper;
        Mydlg.fmeCustomColumn1.ReportParams := Param;
        Mydlg.fmeCustomColumn1.OnApplySettings := Mydlg.ApplyColumnSettings;
        Mydlg.fmeCustomColumn1.OnSaveSettings  := Mydlg.SaveColumnSettings;
        Mydlg.fmeCustomColumn1.LoadCustomColumns;
        case Param.ColManager.Orientation of
          BK_PORTRAIT  : MyDlg.fmeCustomColumn1.rbPortrait.Checked := True;
          BK_LANDSCAPE : MyDlg.fmeCustomColumn1.rbLandscape.Checked := True;
        end;
        Mydlg.tbsSuperDetails.TabVisible := False;
        Mydlg.chkSuperfundDetails.Visible :=
          CanUseSuperFundFields(param.Client.clFields.clCountry,
                                param.Client.clFields.clAccounting_System_Used);


        if not Previewed then
           Application.OnActivate := MyDlg.ActivateApplication;

        Mydlg.loadParam(Param, Previewed);

        if MyDlg.Execute then begin
           Result := MyDlg.Pressed;
           MyDlg.ReadParams(Param);
           MyDlg.fmeAccountSelector1.SaveAccounts(Param.Client,Param);
           if MyDlg.chkIncludeNonTransferring.Checked then begin
               with param.Client.clBank_Account_List do
                  for i := 0 to Pred( ItemCount) do begin
                     Ba := Bank_Account_At(i);
                     if ba.baFields.baAccount_Type in NonTrfJournalsLedgerSet then
                        // These did not show in the selector, so won't be on..
                        Ba.baFields.baTemp_Include_In_Report := True;
                  end;
           end;
           //Orientation
           if MyDlg.fmeCustomColumn1.rbPortrait.Checked then
             Param.ColManager.Orientation :=  BK_PORTRAIT
           else
             Param.ColManager.Orientation :=  BK_LANDSCAPE;
        end else
           Result := BTN_NONE;
     finally
        MyDlg.Free;
        Application.OnActivate := nil;
     end;
  end;

var
   Df, Mf, Yf: Integer;
   Dp, Mp, Yp: Integer;
   NextYearStart: Integer;

begin
  Result := False;
  Param.Runbtn   := BTN_NONE;
  if Param.BatchRun then begin
     Param.Runbtn := BTN_Print;
  end else begin
     // Need to run the Dialog..
      Param.Runbtn := RunDialog;

      case Param.BatchRunMode of
           R_Normal : begin
                  Param.SaveClientSettings;
                  Result := Param.RunBtn <> BTN_None;
               end;
           R_Setup,
           R_BatchAdd : if Param.Runbtn = BTN_SAVE then begin
                  Result := False;
                  Param.RunBtn := BTN_NONE;

                  if param.SummaryReport then
                     Param.RptBatch.Title := Report_List_Names[REPORT_SUMMARY_LIST_LEDGER]
                  else
                     Param.RptBatch.Title := Report_List_Names[REPORT_LIST_LEDGER];
                  Param.SaveNodeSettings;

              end else begin
                  // Run as is..
                  Param.SaveClientSettings;
                  Result := Param.RunBtn <> BTN_None;
              end;

           R_Batch : if Param.Runbtn= BTN_SAVE then begin
                       // Previous
                  Result := False;
               end else begin
                  Param.SaveClientSettings;
                  Result := Param.RunBtn <> BTN_None;
               end;
      end;//Case



  end;


  if Result then
  // Fill in temp fields for use with CalculateAccountTotals and AccountInfo object
     with param.Client.clFields do begin
        // One custom period
        clFRS_Reporting_Period_Type     := frpCustom;
        clTemp_FRS_Last_Period_To_Show  := 1;
        clTemp_FRS_Last_Actual_Period_To_Use := clTemp_FRS_Last_Period_To_Show;

        // From date should be start of last financial year to get opening balances
        // To date should be day prior to report start date to get movement up to that point
        // (or special case, if report start = financial year start then make them the same)
        StDatetoDMY(clFinancial_Year_Starts, Df, Mf, Yf);
        StDatetoDMY(StNull2BK( Param.FromDate), Dp, Mp, Yp);
          // special case start date = financial year start
          if (Df = Dp) and (Mf = Mp) then
            clTemp_FRS_To_Date              := DMYtoStDate(Dp, Mp, Yp, Epoch) //selected date
          else // otherwise we go up to the previous day
            clTemp_FRS_To_Date := IncDate(param.FromDate, -1, 0, 0);
          //go back to last financial year if report month less than year start month
          //ie. if report date is 1/2/2005 then fin start is 1/4/2004 (NZ example)
          if Mp < Mf then
            Yp := Yp - 1;
          cltemp_FRS_from_Date := DMYtoStDate(Df, Mf, Yp, Epoch);

          // Does it span a financial year?
          NextYearStart := DMYtoStDate(Df, Mf, Yp + 1, Epoch);

          if param.ShowBalances
          and (NextYearStart <= Param.ToDate) then
            Param.SpanYear := True;

          clTemp_FRS_Account_Totals_Cash_Only := False;
          clTemp_FRS_Division_To_Use := 0;
          clTemp_FRS_Job_To_Use  := '';
          clTemp_FRS_Budget_To_Use := '';
          clTemp_FRS_Budget_To_Use_Date := -1;
          clTemp_FRS_Use_Budgeted_Data_If_No_Actual := False;
     end;
end;
//------------------------------------------------------------------------------

procedure TdlgLedgerRep.rbSelectedCodesClick(Sender: TObject);
begin
  pnlSelectedCodes.Visible := true;
  pnlAllCodes.Visible := false;
  if Visible then
    tgRanges.SetFocus; // Enter editing state
end;

procedure TdlgLedgerRep.rbAllCodesClick(Sender: TObject);
begin
  pnlAllCodes.Visible := true;
  pnlSelectedCodes.Visible := false;
end;

procedure TdlgLedgerRep.tgRangesCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
var
  p: pAccount_Rec;
begin
  if DataCol = 1 then
    Value := CodesArray[ DataRow -1].FromCode
  else
    Value := CodesArray[ DataRow -1].ToCode;
  p := MyClient.clChart.FindCode(Value);
  if (Value = '') or (Assigned(p) and p.chPosting_Allowed) then
    tgRanges.CellColor[DataCol, DataRow] := clNone
  else
    tgRanges.CellColor[DataCol, DataRow] := clRed;
end;

procedure TdlgLedgerRep.tgRangesEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  EditText, Value : string;
  MaskChar: Char;
  p: pAccount_Rec;
begin
  EditText := Copy(tgRanges.CurrentCell.Value, 1, Length(tgRanges.CurrentCell.Value) - 1);
  if MyClient.clChart.AddMaskCharToCode(EditText, MyClient.clFields.clAccount_Code_Mask, MaskChar) then
     tgRanges.CurrentCell.Value := EditText;

  Value := Trim(tgRanges.CurrentCell.Value);

  if DataCol = 1 then
  begin
    CodesArray[ DataRow -1].FromCode := Value;
  end
  else
    CodesArray[ DataRow -1].ToCode := Value;
  p := MyClient.clChart.FindCode(Value);
  if (Value = '') or (Assigned(p) and p.chPosting_Allowed) then
    tgRanges.CellColor[DataCol, DataRow] := clNone
  else
    tgRanges.CellColor[DataCol, DataRow] := clRed;
end;

procedure TdlgLedgerRep.btnChartClick(Sender: TObject);
var
  Code : string;
  p: pAccount_rec;
  HasChartBeenRefreshed : boolean;
begin
  // If in TO field then automatically select whatever is in the FROM field if TO is blank (#1713)
  Code := tgRanges.CurrentCell.Value;
  if (tgRanges.CurrentDataCol = 2) and (Code = '') then
    Code := CodesArray[tgRanges.CurrentDataRow - 1].FromCode;

  // If code doesn't exist then guess next one
  p := MyClient.clChart.GuessNextCode(Code);
  if Assigned(p) then
    Code := p^.chAccount_Code
  else
    Code := '';

  if PickAccount(Code, HasChartBeenRefreshed) then
  begin
    //if get here then have a code which can be posted to from picklist
    tgRanges.CurrentCell.Value := Code;
    if tgRanges.CurrentDataCol = 1 then
      tgRanges.CurrentDataCol := 2
    else
    begin
      tgRanges.CurrentDataCol := 1;
      tgRanges.CurrentDataRow := tgRanges.CurrentDataRow + 1;
    end;
    tgRanges.CurrentCell.PutInView;
    tgRanges.SetFocus;
  end;
end;

procedure TdlgLedgerRep.tgRangesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 113 then
  begin
    Key := 0;
    btnChart.Click;
  end;
end;

procedure TdlgLedgerRep.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  if not tgRanges.IsFocused then // Only if not entering ranges (#1734)
    case Msg.CharCode of
      109: begin
             DateSelector.btnPrev.Click;
             Handled := true;
           end;
      107: begin
             DateSelector.btnNext.click;
             Handled := true;
           end;
      VK_MULTIPLY : begin
             DateSelector.btnQuik.click;
             handled := true;
           end;
    end;
end;

procedure TdlgLedgerRep.loadParam(Value: TLRParameters;const Previewed : Boolean);
var I,J : Integer;
begin with Value do begin
   ReportParams := Value;
   chkIncludeNonTransferring.Checked := IncludeNonTransferring;
   chkEmptyCodes.Checked := PrintEmptyCodes;
   chkQuantity.Checked := ShowQuantity;
   rbSummarised.Checked := SummaryReport;
   chkGross.Checked := GrossGST;
   rbDetailed.Checked := not SummaryReport;
   rbAllCodes.Checked := ShowAllCodes;
   rbSelectedCodes.Checked := not ShowAllCodes;
   chkNotes.Checked := ShowNotes;
   chkNotes.Enabled := rbDetailed.Checked;
   chkBalances.Checked := ShowBalances;
   chkSuperfundDetails.Checked := ShowSuperDetails;
   chkWrap.Checked := WrapNarration;

   ETitle.Text := SuperFundTitle; 
   case BankContra of
      Byte(bcNone): cbBankContra.Checked := False;
      Byte(bcAll): begin
            rbBankContraAll.Checked := True;
            cbBankContra.Checked := True;
         end;

      else begin
         rbBankContraTotal.Checked := True;
         cbBankContra.Checked := True;
      end;
   end;
   cbBankContraClick(nil);

   case GSTContra of
      Byte(gcNone): cbGSTContra.Checked := False;
      Byte(gcAll): begin
         rbGSTContraAll.Checked := True;
         cbGSTContra.Checked := True;
      end

      else begin
         rbGSTContraTotal.Checked := True;
         cbGSTContra.Checked := True;
      end;
   end;
   cbGSTContraClick(nil); 

   // Fill the DlgArray
   FillChar(CodesArray, SizeOf( CodesArray), #0);
   for i := Low(RangesArray) to High(RangesArray) do begin
     CodesArray[i].FromCode := RangesArray[i].FromCode;
     CodesArray[i].ToCode := RangesArray[i].ToCode;
   end;

   if ( Fromdate <> 0)
   and ( Todate <> 0) then begin
       DateSelector.eDateFrom.AsStDate := FromDate;
       DateSelector.eDateTo.AsStDate := ToDate;
   end else if assigned (Client) then begin
      //use stored date}
       DateSelector.eDateFrom.asStDate := BkNull2St(Client.clFields.clPeriod_Start_Date);
       DateSelector.eDateTo.asStDate   := BkNull2St(Client.clFields.clPeriod_End_Date);
   end;

   {if (AccountList.Count > 0)}
   //if (Previewed) then begin
      // Make sure they are all off
      for I := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Items.Count) do
         fmeAccountSelector1.AccountCheckBox.Checked[i] := False;

      for I := 0 to Pred(AccountList.Count) do begin
         for J := 0 to Pred(fmeAccountSelector1.AccountCheckBox.Items.Count) do
            if fmeAccountSelector1.AccountCheckBox.Items.Objects[J] = AccountList[I] then begin
               fmeAccountSelector1.AccountCheckBox.Checked[J] := True;
               Break;
            end;
      end;
   //end;

   //Super
   if ShowSuperDetails then begin
     if CanUseSuperFundFields(Client.clFields.clCountry, Client.clFields.clAccounting_System_Used) then begin
       if not ColManager.CompatableSuperfund(Client.clFields.clAccounting_System_Used) then begin
         HelpfulWarningMsg('Non-matching superfund - default column settings will be loaded.',0);
         ColManager.SetupColumns;
         ColManager.IsSummarised := rbSummarised.Checked;
         ColManager.UpdateColumns;
         fmeCustomColumn1.LoadCustomColumns;
       end;
     end else
       ShowSuperDetails := False;
   end;

   chkSuperfundDetails.Checked := ShowSuperDetails;
   tbsSuperDetails.TabVisible := ShowSuperDetails;
   UpdateContraSettings;
end;end;

procedure TdlgLedgerRep.rbDetailedClick(Sender: TObject);
begin
  chkNotes.Enabled := rbDetailed.Checked;
  chkWrap.Enabled := rbDetailed.Checked;
  if chkNotes.Checked and rbSummarised.Checked then
    chkNotes.Checked := False;
  if chkWrap.Checked and rbSummarised.Checked then
    chkWrap.Checked := False;
  //Update Superfund columns
  UpdateColManager;
  UpdateContraSettings;
end;

procedure TdlgLedgerRep.tgRangesKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  MaskChar: Char;
  lCode: ShortString;
begin
  if (Key = VK_UP) or (Key = VK_DOWN) or (Key = VK_LEFT) or (Key = VK_RIGHT) or
     (Key = VK_BACK) or (Key = VK_DELETE) or (Key = 113) or (Key = VK_RETURN) then
    Exit;
  if MyClient.clChart.AddMaskCharToCode(tgRanges.CurrentCell.Value, MyClient.clFields.clAccount_Code_Mask, MaskChar) then
  begin
    tgRanges.CurrentCell.Value := tgRanges.CurrentCell.Value + MaskChar;
    tgRanges.CurrentCell.SelStart := Length(tgRanges.CurrentCell.Value);
  end;

  lCode := tgRanges.CurrentCell.Value;
  if MyClient.clChart.CanPressEnterNow(lCode) then
  begin
    tgRanges.CurrentCell.Value := lCode;
    if tgRanges.CurrentDataCol = 1 then
      tgRanges.CurrentDataCol := 2
    else
    begin
      tgRanges.CurrentDataCol := 1;
      tgRanges.CurrentDataRow := tgRanges.CurrentDataRow + 1;
    end;
    tgRanges.CurrentCell.PutInView;
    tgRanges.SetFocus;
  end;
end;

procedure TdlgLedgerRep.tgRangesResize(Sender: TObject);
var
  GridWidth, ColWidth: integer;
begin
  GridWidth := (tgRanges.Width - tgRanges.VertScrollBarWidth);
  if tgRanges.BorderStyle = bsSingle then
    GridWidth := GridWidth - (2 * GetSystemMetrics(SM_CXBORDER));
  ColWidth := (GridWidth div 2);
  if tgRanges.GridLines in  [glVertLines, glBoth] then
    ColWidth := (ColWidth - 1); //Gridlines
  tgRanges.Col[1].Width := ColWidth;
  tgRanges.Col[2].Width := ColWidth;
end;

function TdlgLedgerRep.UpdateColManager: boolean;
begin
  Result := False;
  //Only update columns if parameters have changed
  if (FReportParams.FColManager.ShowBalances <> chkBalances.Checked) or
     (FReportParams.FColManager.ShowQuantity <> chkQuantity.Checked) or
     (FReportParams.FColManager.WrapColumns  <> chkWrap.Checked) or
     (FReportParams.FColManager.IsSummarised <> rbSummarised.Checked) or
     (FReportParams.FColManager.ShowGrossGST <> chkGross.Checked) or
     (FReportParams.FColManager.ShowNotes    <> chkNotes.Checked) then begin
    //Save Params to ColManager
    FReportParams.FColManager.ShowBalances := chkBalances.Checked;
    FReportParams.FColManager.ShowQuantity := chkQuantity.Checked;
    FReportParams.FColManager.WrapColumns  := chkWrap.Checked;
    FReportParams.FColManager.IsSummarised := rbSummarised.Checked;
    FReportParams.FColManager.ShowGrossGST := chkGross.Checked;
    FReportParams.FColManager.ShowNotes    := chkNotes.Checked;
    //Update columns
    FReportParams.FColManager.UpdateColumns;
    fmeCustomColumn1.LoadCustomColumns;
    Result := True;
  end;
end;

procedure TdlgLedgerRep.cbBankContraClick(Sender: TObject);
begin
  UpdateContraSettings;
end;

procedure TdlgLedgerRep.cbGSTContraClick(Sender: TObject);
begin
  UpdateContraSettings;
end;

procedure TdlgLedgerRep.btnSaveTemplateClick(Sender: TObject);
begin
  SaveDialog1.InitialDir := Globals.DataDir;
  if SaveDialog1.Execute then
    tgRanges.SaveToFile(SaveDialog1.FileName, True);
end;

procedure TdlgLedgerRep.btnLoadClick(Sender: TObject);
var
  i: Integer;
begin
  OpenDialog1.InitialDir := Globals.DataDir;
  if OpenDialog1.Execute then
  begin
    tgRanges.OnCellLoaded := nil;
    try
      tgRanges.LoadFromFile(OpenDialog1.FileName, cmaNone);
    except
     begin
      HelpfulErrorMsg('The selected file is not a valid Ledger Report Template file', 0);
      exit;
     end;
    end;
    for i := 1 to tgRanges.Rows do
    begin
      CodesArray[i-1].FromCode := Trim( tgRanges.Cell[1, i]);
      CodesArray[i-1].ToCode := Trim( tgRanges.Cell[2, i]);
    end;
    tgRanges.OnCellLoaded := tgRangesCellLoaded;
  end;
end;

end.
