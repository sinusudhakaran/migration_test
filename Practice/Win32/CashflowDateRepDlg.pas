unit CashflowDateRepDlg;
// Derived from CashflowRepDlg
// Allows selection of date range for CashFlowDate Report
interface

uses
  rptparams,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, OvcABtn, OvcBase, OvcEF, OvcPB, OvcPF, Menus,
  StDate, DateSelectorFme,
  OsFont;

type
  TdlgCashFlowDateRep = class(TForm)
    btnPrint: TButton;
    btnPreview: TButton;
    btnCancel: TButton;
    gbxReportPeriod: TGroupBox;
    gbxOptions: TGroupBox;
    chkChartCodes: TCheckBox;
    chkGST: TCheckBox;
    lblData: TLabel;
    lblDivision: TLabel;
    cmbDivision: TComboBox;
    btnFile: TButton;
    chkLYVariance: TCheckBox;
    DateSelector: TfmeDateSelector;
    btnSave: TBitBtn;
    btnEmail: TButton;
    Bevel1: TBevel;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure DateFieldKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DateFieldChange(Sender: TObject);
    procedure DateFieldError(Sender: TObject; ErrorCode: Word; ErrorMsg: String);
    procedure popDateClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FDataFrom, FDataTo : integer;
    OkPressed : boolean;
    Pressed   : Integer;
    SmartOn   : Boolean;
    FRptParameters: TGenRptParameters;  //Detects BackSpace or Delete Key on Date Entry and auto Tabs
    function  CheckOK: boolean;
    procedure SetDateFromTo( DFrom, DTo : tSTDate );

    procedure LoadDivisionList;
    procedure SetRptParameters(const Value: TGenRptParameters);
  public
    { Public declarations }
    function Execute : boolean;
    property RptParameters: TGenRptParameters read FRptParameters write SetRptParameters;
  end;

//var
//  dlgCashFlowDateRep: TdlgCashFlowDateRep;

function GetCFDateParameters( Title : string;
                              Params :TGenRptParameters) : boolean;

//******************************************************************************
implementation

uses
  BKHelp,
  bkXPThemes,
  SelectDate,
  globals,
  dlgAddFavourite,
  UBatchBase,
  bkDateUtils,
  bkDefs,
  glConst,
  ClDateUtils,
  stDatest,
  bkConst,
  ReportDefs,
  imagesfrm,
  InfoMoreFrm,
  StdHints;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  chkGST.Caption := '&' + MyClient.TaxSystemNameUC + ' Inclusive';

  fDataFrom := ClDateUtils.BAllData( MyClient );
  fDataTo   := ClDateUtils.EAllData( MyClient );
  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( fDataFrom, fDataTo, chkChartCodes);

  lblData.caption := 'Transactions from: ' +
    bkDate2Str(fDataFrom) + ' to ' + bkDate2Str(fDataTo);

{$IFDEF SmartBooks}
   DateSelector.eDateFrom.Enabled     := False; //Restricts dates to Period Start and End dates
   DateSelector.eDateTo.Enabled       := False; //for calculating the CashBooks Balances
   DateSelector.LastYear1.Visible     := False;
   DateSelector.AllData1.Visible      := False;
{$ENDIF}

   SetUpHelp;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   chkChartCodes.Hint := STDHINTS.RptIncludeCodesHint;

   if MyClient.clFields.clCountry = whUK then
     chkGST.Hint        := STDHINTS.RptIncludeVATHint
   else
     chkGST.Hint        := STDHINTS.RptIncludeGSTHint;

   chkLYVariance.Hint := 'Show Last Year and Variance columns in report';

   btnPreview.Hint    := STDHINTS.PreviewHint;

   btnPrint.Hint      := STDHINTS.PrintHint;

   btnFile.Hint       := STDHINTS.PrintToFileHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.FormShow(Sender: TObject);
begin
   gCodingDateFrom := MyClient.clFields.clPeriod_Start_Date;
   gCodingDateTo   := Myclient.clFields.clPeriod_End_Date;
  // SetDateFromTo( gCodingDateFrom, gCodingDateTo );
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.FormShortCut(var Msg: TWMKey;
  var Handled: Boolean);
begin
  case Msg.CharCode of
    109: begin                    // Minus
           DateSelector.btnPrev.Click;
           Handled := true;
         end;
    107: begin                    // Plus
           DateSelector.btnNext.click;
           Handled := true;
         end;
    VK_MULTIPLY : begin           // *
           DateSelector.btnQuik.click;
           handled := true;
         end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
procedure TdlgCashFlowDateRep.btnPreviewClick(Sender: TObject);
begin
   if CheckOk then begin
      okPressed := true;
      Pressed := BTN_PREVIEW;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.btnPrintClick(Sender: TObject);
begin
   if CheckOk then begin
      okPressed := true;
      Pressed := BTN_PRINT;
      Close;
   end;
end;
procedure TdlgCashFlowDateRep.btnSaveClick(Sender: TObject);
begin
   if not RptParameters.CheckForBatch(Self.Caption,REPORT_LIST_NAMES[Report_Cashflow_Date]) then
      Exit;

   okPressed := True;                      
   Pressed := BTN_SAVE;
   Close;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.btnEmailClick(Sender: TObject);
begin
   if CheckOk then begin
      okPressed := true;
      Pressed := BTN_EMAIL;
      Close;
   end;
end;

procedure TdlgCashFlowDateRep.btnFileClick(Sender: TObject);
begin
   if CheckOk then begin
      okPressed := true;
      Pressed := BTN_FILE;
      Close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.btnCancelClick(Sender: TObject);
begin
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
function TdlgCashFlowDateRep.CheckOK: boolean;
begin
   Result := True;
   {now check the values are ok}
   if (not DateSelector.ValidateDates) then
   begin
      Result := False;
      exit;
   end;
     
   if (DateSelector.eDateFrom.AsStDate > DateSelector.eDateTo.AsStDate) and
     not (DateSelector.eDateTo.asStDate = -1) then begin
      HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
      Result := False;
   end;   
end;   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.SetDateFromTo( DFrom, DTo : tSTDate );
// Sets the value of the Date Edit Boxes to the Popup selected values
begin
  DateSelector.eDateFrom.AsStDate := BKNull2St( DFrom );
  DateSelector.eDateTo.AsStDate   := BKNull2St( DTo );
end;  
procedure TdlgCashFlowDateRep.SetRptParameters(const Value: TGenRptParameters);
begin
  FRptParameters := Value;
  if assigned(FRptParameters) then begin
     FRptParameters.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,BtnSave,BtnPrint);
     if Assigned(FRptParameters.RptBatch) then
        Caption := Caption + ' [' + FRptParameters.RptBatch.Name + ']';
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
procedure TdlgCashFlowDateRep.popDateClick(Sender: TObject);
begin
   if Sender is TComponent then begin
      with Sender as TComponent do begin
         case Tag of
            1 : begin  // Last Month
               SetDateFromTo( BLastMth, ELastMth );
            end;
            2 : begin  // This Year
               SetDateFromTo( BThisYear( MyClient ), EThisYear( MyClient ) );
            end;
            3 : begin  // Last Year
               SetDateFromTo( BLastYear( MyClient ), ELastYear( MyClient ) );
            end;      
            4 : begin  // All Data
               SetDateFromTo( fDataFrom, fDataTo);
            end; 
         end;
      end;
   end;   
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
procedure TdlgCashFlowDateRep.DateFieldKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   SmartOn := not((key = 8) or (key=46));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
procedure TdlgCashFlowDateRep.DateFieldChange(Sender: TObject);
begin
   if smartOn then begin
      if TOvcPictureField(Sender).CurrentPos = length(BKDATEFORMAT) then begin
         if TOvcPictureField(Sender).Name = 'eDateFrom' then
           DateSelector.eDateTo.SetFocus
         else
           btnPrint.SetFocus;
      end;      
   end;      
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
procedure TdlgCashFlowDateRep.DateFieldError(Sender: TObject; ErrorCode: Word;
  ErrorMsg: String);
begin
   ShowDateError(Sender);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  
function TdlgCashFlowDateRep.Execute: boolean;
begin
   (*
   if Assigned(MyClient) then
   begin
      chkGST.checked     := MyClient.clFields.clGST_Inclusive_Cashflow;
      chkChartCodes.Checked := MyClient.clFields.clFRS_Print_Chart_Codes;
   end;
   chkLYVariance.checked := false;
   *)
   Pressed := BTN_NONE;

   //LoadDivisionList;

   Self.ShowModal;
   result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetCFDateParameters( Title : string;
                              Params :TGenRptParameters) : boolean;
var
  CashFlowDateRep : TDlgCashFlowDateRep;
begin
  Result := false;
  Params.RunBtn := BTN_NONE;
  CashFlowDateRep := TDlgCashFlowDateRep.Create(Application.MainForm);
  with CashFlowDateRep, Params do begin
    try
      BKHelpSetUp(CashFlowDateRep, BKH_From_date_to_date);
      Caption := Title;
      SetDateFromTo(Fromdate,Todate);
      chkGST.checked        := ShowGst;
      chkChartCodes.Checked := ChartCodes;
      chkLYVariance.checked := SpareBool;

      LoadDivisionList;
      if BatchSetup then begin
         cmbDivision.ItemIndex := Division;
      end;
      RptParameters := Params;



      if Execute then begin
         Fromdate := StNull2BK( DateSelector.eDateFrom.AsStDate );
         ToDate   := StNull2BK( DateSelector.eDateTo.AsStDate );
         if ToDate   = 0 then
            ToDate   := MaxInt;

         ShowGst    := chkGST.checked;
         ChartCodes := chkChartCodes.Checked;
         SpareBool  := chkLYVariance.checked;

         MyClient.clFields.clFRS_Print_Chart_Codes := chkChartCodes.Checked;
         RunBtn := Pressed;
         Division := Integer( cmbDivision.Items.Objects[ cmbDivision.ItemIndex]);
         Result := True;
      end;
    finally
       CashFlowDateRep.Free;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowDateRep.LoadDivisionList;
var
  i : integer;
  dNo : integer;
  pA  : pAccount_Rec;
  Division_Used : Array [ 1..Max_Divisions] of boolean;
begin
  //load divisions combo
  cmbDivision.Items.Clear;
  cmbDivision.Items.AddObject( 'All', TObject(0));

  //only load divisions that have been used in the clients chart
  FillChar( Division_Used, SizeOf( Division_Used), #0);

  with MyClient do begin
     //set a flag to tell us if a particular division has been used
     for i := clChart.First to clChart.Last do begin
        pA := clChart.Account_At(i);
        for dNo := 1 to Max_Divisions do
           if pA^.chPrint_in_Division[dNo] then
              Division_Used[dNo] := true;
     end;
     //now load the divisions into the list
     for dNo := 1 to Max_Divisions do begin
        if Division_Used[ dNo] then
           cmbDivision.Items.AddObject( inttostr( dNo) + ' - ' + clCustom_Headings_List.Get_Division_Heading( dNo), TObject( dNo));
     end;
  end;
  cmbDivision.ItemIndex := 0;  //set to all by default
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
