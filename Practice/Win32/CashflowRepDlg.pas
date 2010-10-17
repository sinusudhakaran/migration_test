unit CashflowRepDlg;
//------------------------------------------------------------------------------
{
   Title:       Basic Cash flow Report options dlg

   Description:

   Author:     Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  RptParams,OmniXML, budobj32,
  ReportDefs,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, OvcABtn, OvcBase, OvcEF, OvcPB, OvcPF, clObj32,
  PeriodUtils, Mask, RzEdit, RzSpnEdt,
  OsFont;

type


  TProfitRptParameters = class (TGenRptParameters)
    protected
      procedure LoadFromClient (Value : TClientObj); override;
      procedure SaveToClient   (Value : TClientObj); override;
      procedure ReadFromNode   (Value : IXMLNode); override;
      procedure SaveToNode     (Value : IXMLNode); override;
    public
      PercentageIncome: Boolean;
      PeriodType: Integer;
      //ReportType: string;
    end;


  TdlgCashFlowRep = class(TForm)

    btnOK: TButton;
    OvcController1: TOvcController;
    btnPreview: TButton;
    btnCancel: TButton;
    btnFile: TButton;
    pnlDivision: TPanel;
    lblDivision: TLabel;
    cmbDivision: TComboBox;
    Panel2: TPanel;
    chkChartCodes: TCheckBox;
    chkGST: TCheckBox;
    PnlBudget: TPanel;
    cmbBudget: TComboBox;
    Label2: TLabel;
    cbPercentage: TCheckBox;
    BtnSave: TBitBtn;
    pnlDateSelection: TPanel;
    pnlPeriodSelection: TPanel;
    Panel5: TPanel;
    Label1: TLabel;
    lblLast: TLabel;
    Label3: TLabel;
    lblFinancialYearStartDate: TLabel;
    cmbPeriod: TComboBox;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Label4: TLabel;
    cmbPeriodLength: TComboBox;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure cmbPeriodDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbStartMonthChange(Sender: TObject);
    procedure spnStartYearChange(Sender: TObject);
    procedure BtnSaveClick(Sender: TObject);

  private
    { Private declarations }
    FClient    : TClientObj;
    Changing   : Boolean;
    LastPeriodOfActualData : integer;
    MonthArray : TMonthArray;
    okPressed  : boolean;
    FPressed   : integer;
    FProfitRptParameters: TProfitRptParameters;
    FShowAllBudgets: Boolean;
    procedure RecalcDates;
    procedure SetPressed(const Value: integer);
    procedure LoadDivisionList;
    procedure LoadBudgetList;
    procedure LoadPeriodLengthList;
    function CheckBudget : Boolean;
    procedure SetProfitRptParameters(const Value: TProfitRptParameters);
  public
    { Public declarations }
    function Execute : boolean;
    property Pressed : integer read FPressed write SetPressed;
    property ProfitRptParameters: TProfitRptParameters read FProfitRptParameters write SetProfitRptParameters;
  end;




function GetFYearParameters(Title : string;
                            Params : TProfitRptParameters;
                            ContextID : Integer = 0;
                            IsProfitReport : boolean = false;
                            ShowChartCodesGST : Boolean = True;
                            ShowBudget : Boolean = False;
                            ShowPeriodLength: Boolean = False;
                            ShowDateSelection: Boolean = True;
                            ShowDivision: Boolean = True;
                            ShowAllBudgets: Boolean = False) : boolean;

//******************************************************************************
implementation

uses
  dlgAddFavourite,
  bkdefs,
  BKHelp,
  bkXPThemes,
  glconst,
  SelectDate,
  ovcDate,
  UBatchBase,
  globals,
  stDatest,
  bkConst,
  imagesfrm,
  WarningMoreFrm,
  bkDateUtils,
  StdHints;

{$R *.DFM}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.FormCreate(Sender: TObject);
var I : Integer;
begin
   bkXPThemes.ThemeForm( Self);

   Changing := false;

{$IFDEF SmartBooks}
   chkChartCodes.Caption := 'Print Account Codes';
   lblFinancialYearStartDate.Visible := True;
   cmbStartMonth.Visible := False;
   spnStartYear.Visible := False;
{$ELSE}
   lblFinancialYearStartDate.Visible := False;
   cmbStartMonth.Visible := True;
   spnStartYear.Visible := True;
{$ENDIF}

   SetUpHelp;
   //load report year starts months
   cmbStartMonth.Items.Clear;
   for I := ( moMin + 1) to moMax do
      cmbStartMonth.Items.Add( moNames[ I]);
     //set default
   cmbStartMonth.ItemIndex := 0;

   //favorite reports functionality is disabled in simpleUI
   if Active_UI_Style = UIS_Simple then
      btnSave.Hide;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.RecalcDates;
type
   tState = ( Coded, Uncoded, NoData );
var
   d,m,y,pd : integer;
   State    : tState;
   MaxCoded : integer;
   PeriodType : integer;

   MaxPeriods : integer;

   tmpYearEnds : integer;
   tmpYearStarts : integer;
begin
   //get the year starts date from the combo and spin box
   d := 1;
   m := cmbStartMonth.ItemIndex + 1;
   y := spnStartYear.IntValue;
   tmpYearStarts := DmyToStDate( d,m,y, bkDateEpoch);
   tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);

   with FClient.clFields do
   begin
      MaxCoded   := 0;
      LastPeriodOfActualData := 0;

      PeriodType := frpMonthly;
      MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( FClient, tmpYearStarts, tmpYearEnds, true, PeriodType,
                                                            clTemp_Period_Details_This_Year);
      //need to resize the months array to the correct size
      cmbPeriod.Items.Clear;
      SetLength( MonthArray, MaxPeriods + 1);

      for pd := 1 to MaxPeriods do
      begin
         cmbPeriod.Items.Add('');

         MonthArray[pd].Day   := stDateToDateString( 'dd',   clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Month := stDateToDateString( 'nnn',  clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Year  := stDateToDateString( 'yyyy', clTemp_Period_Details_This_Year[pd].Period_End_Date, true );

         MonthArray[pd].PeriodStartDate := clTemp_Period_Details_This_Year[pd].Period_Start_Date;
         MonthArray[pd].PeriodEndDate   := clTemp_Period_Details_This_Year[pd].Period_End_Date;

         State := NoData;
         If clTemp_Period_Details_This_Year[pd].HasData then begin
           LastPeriodOfActualData := pd;

           if not( clTemp_Period_Details_This_Year[pd].HasUncodedEntries) then
             State := Coded
           else
             State := Uncoded;
         end;

         Case State of
           Coded    : begin
                        MonthArray[pd].Status := 'CODED';
                        MonthArray[pd].imageIndex := 0;
                      end;

           Uncoded  : begin
                        MonthArray[pd].Status := 'Uncoded';
                        MonthArray[pd].imageIndex := 1;
                      end;

           NoData   : begin
                        MonthArray[pd].Status := '';
                        MonthArray[pd].imageIndex := -1;
                      end;
         end;

         if (State = Coded) and (pd > MaxCoded) then MaxCoded := pd;
      end;

      if MaxCoded > 0 then
        lblLast.caption := 'The last period of CODED data ends '+ MonthArray[MaxCoded].Day + ' '
                                                                 + MonthArray[MaxCoded].Month + ' '
                                                                 + MonthArray[MaxCoded].Year
      else
      begin
        lblLast.caption := 'There is no period which is completely CODED.';
        MaxCoded := 1;
      end;
      //move to the last coded field by default
      cmbPeriod.ItemIndex := MaxCoded -1;
   end;
   LoadBudgetList;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;

   //Components
   cmbStartMonth.Hint := STDHINTS.RptFinYearStartHint;
   spnStartYear.Hint  := STDHINTS.RptFinYearStartHint;

   cmbPeriod.Hint     := STDHINTS.RptPeriodHint;

   chkChartCodes.Hint := STDHINTS.RptIncludeCodesHint;

   chkGST.Hint        := STDHINTS.RptIncludeGSTHint;

   btnPreview.Hint    := STDHINTS.PreviewHint;

   btnOK.Hint         := STDHINTS.PrintHint;

   btnFile.Hint      := STDHINTS.PrintToFileHint;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.FormShow(Sender: TObject);
begin
  // Financial Year not usually changed
  if pnlDateSelection.Visible then  
    cmbPeriod.SetFocus
  else if pnlDivision.Visible then
    cmbDivision.SetFocus
  else if PnlBudget.Visible then
    cmbBudget.SetFocus;

end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.btnOKClick(Sender: TObject);
begin
   if CheckBudget  then begin
      okPressed := true;
      Pressed := BTN_PRINT;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.btnCancelClick(Sender: TObject);
begin
   Close;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgCashFlowRep.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
procedure TdlgCashFlowRep.SetProfitRptParameters(
  const Value: TProfitRptParameters);
begin
  FProfitRptParameters := Value;
  if assigned(FProfitRptParameters) then begin
     FProfitRptParameters.SetDlgButtons(BtnPreview,BtnFile,BtnSave,BtnOk);
     if Assigned(FProfitRptParameters.RptBatch) then
        Caption := Caption + ' [' + FProfitRptParameters.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.btnPreviewClick(Sender: TObject);
begin
   if CheckBudget  then begin
      okPressed := true;
      Pressed := BTN_PREVIEW;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.BtnSaveClick(Sender: TObject);
begin
   if CheckBudget  then begin

      if not ProfitRptParameters.CheckForBatch(Self.Caption) then
         Exit;

     
      okPressed := true;
      Pressed := BTN_SAVE;
      Close;
   end;
end;

function TdlgCashFlowRep.CheckBudget: Boolean;
begin
   if PnlBudget.Visible then begin
       // need to check
       Result := cmbBudget.ItemIndex >= 0;
       if not result then
          if cmbBudget.Items.Count > 0 then begin
             HelpfulWarningMsg( 'Please select a budget to use.', 0);
             cmbBudget.SetFocus;
          end else begin
             HelpfulWarningMsg( 'Please select a period with a budget.', 0);
             cmbStartMonth.SetFocus;
          end;
   end else
      Result := True;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.cmbPeriodDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);
begin
  (* This ensures the correct highlite color is used *)
  cmbPeriod.canvas.fillrect(rect);

  (* This line draws the actual bitmap*)
  AppImages.Period.Draw(cmbPeriod.Canvas,rect.left,rect.top,MonthArray[index+1].ImageIndex);

  (*  This line writes the text after the bitmap*)
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+2,rect.top,  MonthArray[index+1].Month);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+40,rect.top, MonthArray[index+1].Year);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+80,rect.top, MonthArray[index+1].Status);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TdlgCashFlowRep.Execute: boolean;
begin
   Pressed := BTN_NONE;

   Self.ShowModal;

   result := okPressed;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SetComboIndexByIntObject( const Value : integer; const aCombo : TComboBox);
//used for location the item index of a combo by matching up an integer that
//has been stored in the Objects[] property.
var
   i : integer;
begin
   for i := 0 to Pred( aCombo.Items.Count) do
      if Integer( aCombo.Items.Objects[ i]) = Value then begin
         aCombo.ItemIndex := i;
         exit;
      end;
end;

function GetFYearParameters(Title : string;
                            Params : TProfitRptParameters;
                            ContextID : Integer = 0;
                            IsProfitReport : boolean = False;
                            ShowChartCodesGST : Boolean = True;
                            ShowBudget : Boolean = False;
                            ShowPeriodLength: Boolean = False;
                            ShowDateSelection: Boolean = True;
                            ShowDivision: Boolean = True;
                            ShowAllBudgets: Boolean = False) : boolean;
//note IsProfitReport parameter is OPTIONAL.  Is only set by profit and loss reports
var
  MyDlg : TdlgCashFlowRep;
  wasDate : tStDate;
  tmpYearStarts : tStdate;
  d,m,m2,y   : Integer;
begin
  result  := false;
  wasDate := Params.Client.clFields.clReporting_Year_Starts;
  Params.Runbtn     := BTN_NONE;

  MyDlg:= TDlgCashFlowRep.Create(Application.MainForm);
  try
    BKHelpSetUp(MyDlg, ContextID);
    MyDlg.FClient := Params.Client;
    Mydlg.Caption := Title;
    Mydlg.ProfitRptParameters := Params;
    MyDlg.Panel2.Visible := ShowChartCodesGST;
    MyDlg.pnlDateSelection.Visible := ShowDateSelection;
    MyDlg.chkGST.Caption := '&' + Params.Client.TaxSystemNameUC + ' Inclusive';
    if Params.Client.clFields.clCountry = whUK then
      MyDlg.chkGST.Hint        := STDHINTS.RptIncludeVATHint;
    MyDlg.pnlDivision.Visible := ShowDivision;
    MyDlg.FShowAllBudgets := ShowAllBudgets;
    if ShowChartCodesGST then
      if IsProfitReport then
         MyDlg.cbPercentage.Checked := params.PercentageIncome
      else begin
         MyDlg.cbPercentage.Visible := False;
         MyDlg.Panel2.Height := MyDlg.Panel2.Height - 20;
         MyDlg.Height := MyDlg.Height - 20;
      end;

    MyDlg.pnlPeriodSelection.Visible := ShowPeriodLength;
    MyDlg.LoadPeriodLengthList;

    MyDlg.LoadDivisionList;
    SetComboIndexByIntObject(Params.Division , MyDlg.cmbDivision);
    if MyDlg.cmbDivision.ItemIndex < 0 then
       MyDlg.cmbDivision.ItemIndex := 0;

    MyDlg.cmbPeriod.ItemIndex := Params.Period; //? and devision
    Mydlg.chkGST.checked := Params.ShowGst;
    MyDlg.chkChartCodes.Checked := Params.ChartCodes;

    //MyDlg.chkGST.Visible := not IsProfitReport;   reintroduced Nov 2002


    //set the reporting year starts fields
    tmpYearStarts := Params.Fromdate;
    StDateToDMY( tmpYearStarts, d, m, y);

    MyDlg.spnStartYear.Value := y;
    MyDlg.cmbStartMonth.ItemIndex := m - 1;

    MyDlg.lblFinancialYearStartDate.Caption
        := StDateToDateString( 'DD/MM/yyyy', BKNull2St( tmpYearStarts ), True );

    MyDlg.RecalcDates;
    if Params.ToDate <> 0  then begin
       StDateToDMY(Params.ToDate, d, m2, y);
       d := m2 - m;
       if d < 1  then
         d := d + 12;
       MyDlg.cmbPeriod.ItemIndex := d;
    end;

    if ShowBudget then begin
       MyDlg.LoadBudgetList;
       if assigned(params.Budget) then  begin
          d := MyDlg.cmbBudget.Items.IndexOfObject(params.Budget);
          // debug...
          MyDlg.cmbBudget.ItemIndex := d;
       end else
         if MyDlg.cmbBudget.Items.Count > 0 then
           MyDlg.cmbBudget.ItemIndex := 0;
    end else begin
       MyDlg.PnlBudget.Visible := False;
       MyDlg.Panel2.Top := MyDlg.Panel2.Top - 44;
       MyDlg.Height := MyDlg.Height - 44;
    end;


    if MyDlg.Execute then
    begin
       //get the year starts date from the combo and spin box
       d := 1;
       m := MyDlg.cmbStartMonth.ItemIndex + 1;
       y := MyDlg.spnStartYear.IntValue;
       Params.FromDate := DmyToStDate( d,m,y, bkDateEpoch);

       //check that user did not clear the date field
       if Params.FromDate = 0 then
          Params.FromDate := wasDate;
       Params.Client.clFields.clReporting_Year_Starts := Params.FromDate; // Should be on the other side.

       Params.PeriodType := Integer( MyDlg.cmbPeriodLength.Items.Objects[MyDlg.cmbPeriodLength.ItemIndex]);

       Params.Period    := MyDlg.cmbPeriod.ItemIndex + 1;
       Params.ShowGst   := Mydlg.chkGST.checked;

       Params.ChartCodes := MyDlg.chkChartCodes.Checked;

       Params.Division := Integer( MyDlg.cmbDivision.Items.Objects[ MyDlg.cmbDivision.ItemIndex]);
       Params.ToDate := MyDlg.MonthArray[ Params.Period ].PeriodEndDate;

       if ShowBudget then begin
          if MyDlg.cmbBudget.ItemIndex >= 0 then
             Params.Budget :=  TBudget(MyDlg.cmbBudget.Items.Objects[MyDlg.cmbBudget.ItemIndex])
          else Params.Budget := nil;
       end;

       if IsProfitReport then begin
          params.PercentageIncome := MyDlg.cbPercentage.Checked;
          Params.Client.clFields.clProfit_Report_Show_Percentage := params.PercentageIncome;
       end;
       Params.RunBtn := MyDlg.Pressed;
       case Params.BatchRunMode of
           R_Normal : begin
                  Params.SaveClientSettings;
                  Result := true;
               end;
           R_Setup,
           R_BatchAdd : if Params.Runbtn = BTN_SAVE then begin
                  Params.SaveNodeSettings;
                  Result := False;
              end else begin
                  // Run as is..
                  Params.SaveClientSettings;
                  Result := True;
              end;

           R_Batch : if Params.Runbtn = BTN_SAVE then begin
                       // Previous
                  Result := False;
               end else begin
                  Params.SaveClientSettings;
                  Result := True;
               end;
      end;//Case

    end;
  finally
    MyDlg.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.LoadBudgetList;
var
  clM : Integer;
  buD, buM, buY : Integer;
  i : integer;
  S : string;
begin
  clM := cmbStartMonth.ItemIndex + 1;
  //load budget combo
  cmbBudget.Items.Clear;
  with FClient do begin
    for i:= clBudget_List.ItemCount-1 downto 0 do
    with clBudget_List.Budget_At(i) do begin
      StDateToDMY(buFields.buStart_Date, buD, buM, buY );
      if FShowAllBudgets or (buM = clM) then
      begin
        S := buFields.buName + ' (' + bkDate2Str(buFields.buStart_Date) + ')';
        cmbBudget.Items.AddObject(S, clBudget_List.Budget_At(i));
      end;
    end;
  end;
  if cmbBudget.Items.Count > 0 then
     cmbBudget.ItemIndex := 0 // select latest by default.
  else
     cmbBudget.ItemIndex := -1;
end;

procedure TdlgCashFlowRep.LoadDivisionList;
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

  with FClient do begin
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

procedure TdlgCashFlowRep.LoadPeriodLengthList;
var
  i: Integer;
  PeriodTypeToSelect: Integer;
begin
  cmbPeriodLength.Items.Clear;
  for i := frpMonthly to frpYearly do begin
    cmbPeriodLength.Items.AddObject( frpNames[ i], TObject(i));
  end;

  if ProfitRptParameters.PeriodType = 0 then
  begin //if not running from favourite reports select the GST Period as the default reporting period
    //translate GST Periods to Reporting periods.
    case FClient.clFields.clGST_Period of
      gp2Monthly:  PeriodTypeToSelect := frp2Monthly;
      gpQuarterly: PeriodTypeToSelect := frpQuarterly;
      gp6Monthly:  PeriodTypeToSelect := frp6Monthly;
      gpAnnually:  PeriodTypeToSelect := frpYearly;
      else
        PeriodTypeToSelect := frpMonthly;
    end;
  end
  else
    PeriodTypeToSelect := ProfitRptParameters.PeriodType;

  for i := 0 to Pred( cmbPeriodLength.Items.Count) do
  begin
     if Integer( cmbPeriodLength.Items.Objects[i]) = PeriodTypeToSelect then
     begin
        cmbPeriodLength.ItemIndex := i;
        break;
     end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.btnFileClick(Sender: TObject);
begin
   if CheckBudget  then begin
      okPressed := true;
      Pressed := BTN_FILE;
      Close;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.FormDestroy(Sender: TObject);
begin
   MonthArray := nil;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgCashFlowRep.cmbStartMonthChange(Sender: TObject);
begin
  if not changing then
    RecalcDates;
end;

procedure TdlgCashFlowRep.spnStartYearChange(Sender: TObject);
begin
  if not changing then
    RecalcDates;
end;



{ TProfitRptParameters }

procedure TProfitRptParameters.LoadFromClient(Value: TClientObj);
begin
  inherited;
  PercentageIncome := Value.clFields.clProfit_Report_Show_Percentage;
end;

procedure TProfitRptParameters.ReadFromNode(Value: IXMLNode);
begin
  inherited;
  PercentageIncome :=  GetBatchBool('Show_Percentage',PercentageIncome);
  PeriodType := GetBatchInteger('Period_Type', PeriodType);
end;

procedure TProfitRptParameters.SaveToClient(Value: TClientObj);
begin
  inherited;
  Value.clFields.clProfit_Report_Show_Percentage := PercentageIncome;
  Value.clFields.clTemp_FRS_Split_By_Division := False;
  Value.clFields.clTemp_FRS_Division_To_Use := 0;
  SetLength(Value.clFields.clTemp_FRS_Divisions, 0);
  //Prevent printing of non-posting chart code titles
  Value.clExtra.ceFRS_Print_NP_Chart_Code_Titles := False;
  Value.clExtra.ceFRS_NP_Chart_Code_Detail_Type :=  cflReport_Detailed;
end;

procedure TProfitRptParameters.SaveToNode(Value: IXMLNode);
begin
  inherited;
  SetBatchBool('Show_Percentage',PercentageIncome);
  SetBatchInteger('Period_Type', PeriodType);
end;



end.
