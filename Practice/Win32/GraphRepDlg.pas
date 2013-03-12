unit GraphRepDlg;

//------------------------------------------------------------------------------
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, OvcABtn, OvcBase, OvcEF, OvcPB, OvcPF,
  BudObj32,Rptparams, ComCtrls, PeriodUtils, Mask, RzEdit, RzSpnEdt,
  OSFont, AccountSelectorFme, OmniXML;


type



   TGraphParams = class (TGenRptParameters)
   public
      ShowLastYear,
      ShowBudget: Boolean;

      ShowSales,
      ShowGrossProfit,
      ShowNettProfit: Boolean;
      procedure SaveToNode   (Value : IXMLNode); override;
   end;


type
  TdlgGraphRep = class(TForm)
    btnOK: TButton;
    OvcController1: TOvcController;
    btnCancel: TButton;
    btnSave: TBitBtn;
    pcGraph: TPageControl;
    tsOptions: TTabSheet;
    tsAdvanced: TTabSheet;
    Panel1: TPanel;
    Label3: TLabel;
    lblLast: TLabel;
    lblReportingYearStartDate: TLabel;
    Label1: TLabel;
    cmbPeriod: TComboBox;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Panel2: TPanel;
    lblBudget: TLabel;
    lblDivision: TLabel;
    chkGST: TCheckBox;
    cmbBudget: TComboBox;
    cmbDivision: TComboBox;
    plInclude: TPanel;
    Label2: TLabel;
    cbLastYear: TCheckBox;
    cbBudget: TCheckBox;
    plTrading: TPanel;
    Label4: TLabel;
    fmeAccountSelector1: TfmeAccountSelector;
    ckSales: TCheckBox;
    ckGrossProfit: TCheckBox;
    ckNettProfit: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cmbPeriodDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbStartMonthChange(Sender: TObject);
    procedure spnStartYearChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure cmbBudgetChange(Sender: TObject);
  private
    { Private declarations }
    okPressed : boolean;
    FPressed: integer;
    MonthArray : TMonthArray;
    FParams: TGraphParams;
    procedure RecalcDates;
    procedure SetPressed(const Value: integer);
    procedure LoadDivisionList;
    procedure LoadBudgetCombo;
    procedure SetParams(const Value: TGraphParams);
    procedure LoadAccountsDialog;
  public
    { Public declarations }
    function Execute : boolean;
    property Pressed : Integer read FPressed write SetPressed;
    property Params: TGraphParams read FParams write SetParams;
  end;

function GetGYearParameters(Title: string;
                            var StartDate: integer;
                            AllowBudgetSelection: boolean;
                            AllowGSTSelection: boolean;
                            ShowInclude: Boolean;
                            ShowTrade: Boolean;
                            ContextID: Integer;
                            RptParams: TGraphParams): boolean;

//******************************************************************************
implementation

uses
  bkconst,
  bkDateUtils,
  bkDefs,
  BKHelp,
  bkXPThemes,
  glConst,
  globals,
  imagesfrm,
  ovcDate,
  SelectDate,
  stDatest,
  stdHints,
  baObj32,
  GraphDefs,
  UBatchBase;

{$R *.DFM}

var
  changing  : boolean;

//------------------------------------------------------------------------------
procedure TdlgGraphRep.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);
  Changing := false;
{$IFDEF SmartBooks}
  lblReportingYearStartDate.Visible := True;
  cmbStartMonth.Visible := False;
  spnStartYear..Visible := False;
{$ELSE}
  lblReportingYearStartDate.Visible := False;
  cmbStartMonth.Visible := True;
  spnStartYear.Visible := True;
{$ENDIF}
  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;
  SetUpHelp;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbStartMonth.Hint := STDHINTS.RptFinYearStartHint;
   spnStartYear.Hint  := STDHINTS.RptFinYearStartHint;

   chkGST.Hint         := Format('Include %s in the graph figures|' + 'Include %s in the graph figures', [MyClient.TaxSystemNameUC, MyClient.TaxSystemNameUC]);
   cmbBudget.Hint      :=
                       'Select a Budget to include in the Graph|' +
                       'Select a Budget to include as a line in the Graph';
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.RecalcDates;
type
   tState = ( Coded, Uncoded, NoData );
var
  d,m,y,pd : integer;
  State : tState;

  MaxCoded : integer;
  MaxPeriods : integer;

  tmpYearStarts : integer;
  tmpYearEnds   : integer;
begin
   //get the year starts date from the combo and spin box
   d := 1;
   m := cmbStartMonth.ItemIndex + 1;
   y := spnStartYear.IntValue;
   tmpYearStarts := DmyToStDate( d,m,y, bkDateEpoch);
   tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);

   with MyClient.clFields do
   begin
      MaxCoded   := 0;

      //clReporting_Year_Starts := StNull2BK( edtReportingYearStartDate.asStDate );
      MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( MyClient, tmpYearStarts, tmpYearEnds, true, frpMonthly,
                                                            clTemp_Period_Details_This_Year);
      //need to resize the months array to the correct size
      cmbPeriod.Items.Clear;
      SetLength( MonthArray, MaxPeriods + 1);

      {add items to window}
      for pd := 1 to MaxPeriods do
      begin
         cmbPeriod.Items.Add('');

         MonthArray[pd].Day   := stDateToDateString( 'dd',  clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Month := stDateToDateString( 'nnn',  clTemp_Period_Details_This_Year[pd].Period_End_Date, true );
         MonthArray[pd].Year  := stDateToDateString( 'yyyy', clTemp_Period_Details_This_Year[pd].Period_End_Date, true );

         MonthArray[pd].PeriodStartDate := clTemp_Period_Details_This_Year[pd].Period_Start_Date;
         MonthArray[pd].PeriodEndDate   := clTemp_Period_Details_This_Year[pd].Period_End_Date;

         State := NoData;
         If clTemp_Period_Details_This_Year[pd].HasData then begin

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
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.btnOKClick(Sender: TObject);
begin
   okPressed := true;
   Pressed := BTN_PRINT;
   Close;
end;
procedure TdlgGraphRep.btnSaveClick(Sender: TObject);
begin
   if not FParams.CheckForBatch then
      Exit;

   okPressed := true;
   Pressed := BTN_SAVE;
   Close;
end;

//------------------------------------------------------------------------------
procedure TdlgGraphRep.btnCancelClick(Sender: TObject);
begin
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.btn1Click(Sender: TObject);
begin
   RecalcDates;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.SetParams(const Value: TGraphParams);
begin
  FParams := Value;
  if assigned(FParams) then begin
     FParams.SetDlgButtons(nil,nil,BtnSave,BtnOk);
     if Assigned(FParams.RptBatch) then //Assumes is set only once
        Caption := Caption + ' [' + FParams.RptBatch.Name + ']';
  end else
     BtnSave.Hide;
end;

procedure TdlgGraphRep.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.Button1Click(Sender: TObject);
begin
   okPressed := true;
   Pressed := BTN_PREVIEW;
   Close;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.LoadDivisionList;
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
//------------------------------------------------------------------------------

procedure TdlgGraphRep.LoadBudgetCombo;
var
  clM : Integer;
  buD, buM, buY : Integer;
  i : Integer;
  Budget : TBudget;
  S : string;
begin

  clM := cmbStartMonth.ItemIndex + 1;

  {load budget combo}
  cmbBudget.Items.Clear;
  cmbBudget.Items.AddObject('<none>',nil);

  for i := MyClient.clBudget_List.ItemCount-1 downto 0 do
  begin
     Budget := MyClient.clBudget_List.Budget_At(i);
     StDateToDMY(Budget.buFields.buStart_Date, buD, buM, buY );
     if (buM = clM) then
     begin
       s := Budget.buFields.buName+ ' ('+ bkDate2Str(Budget.buFields.buStart_Date) +')';
       cmbBudget.Items.AddObject(s,Budget);
     end;
  end;
  {$IFDEF SmartBooks}
    cmbBudget.ItemIndex   := 1; //Only one budget for SmartBook
  {$ELSE}
    cmbBudget.ItemIndex   := 0;
  {$ENDIF}
end;
//------------------------------------------------------------------------------
function TdlgGraphRep.Execute: boolean;
begin
   Pressed := BTN_NONE;

   Self.ShowModal;

   Result := okPressed;
end;

procedure TdlgGraphRep.LoadAccountsDialog;
begin
  fmeAccountSelector1.LoadAccounts( MyClient, BKCONST.TransferringJournalsSet);
  fmeAccountSelector1.btnSelectAllAccounts.Click;
end;

//------------------------------------------------------------------------------
function GetGYearParameters(Title: string;
                            var StartDate: integer;
                            AllowBudgetSelection: boolean;
                            AllowGSTSelection: boolean;
                            ShowInclude: Boolean;
                            ShowTrade: Boolean;
                            ContextID: Integer;
                            RptParams: TGraphParams): boolean;
var
  MyDlg : TdlgGraphRep;
  wasDate : tStDate;
  i,d,m,y,j : Integer;
  tmpYearStarts : Integer;

begin
  Result := false;
  wasDate := MyClient.clFields.clReporting_Year_Starts;
  //Budget  := nil;
  if RptParams.ReportType = (GraphBase + Ord(GRAPH_BANK_BALANCE)) then
    RptParams.GetBatchAccounts;

  MyDlg:= TDlgGraphRep.Create(Application.MainForm);
  try
    BKHelpSetup(MyDlg, ContextID);
    Mydlg.Caption := Title;

    with MyDlg do begin
       //Total Bank Balance Graph
       tsAdvanced.TabVisible := false; //RptParams.ReportType = (GraphBase + Ord(GRAPH_BANK_BALANCE));
       { See Case 2071}
       tsOptions.TabVisible := false;
       PCGraph.ActivePage := tsOptions;
       Height := Height - 24;
       { **** }


       LoadAccountsDialog;

       chkGST.Visible := (AllowGSTSelection);
       chkGST.Caption := 'Print &' + MyClient.TaxSystemNameUC + ' Inclusive';
       if not chkGST.visible then
       begin
         Panel2.Height := Panel2.Height - chkGST.height - 8;
         Height := Height - chkGST.height - 8;
       end;
       MyDlg.Params := RptParams;

       cmbBudget.Visible := AllowBudgetSelection;
       lblBudget.Visible := AllowBudgetSelection;

       cbBudget.Visible := AllowBudgetSelection;
       if AllowBudgetSelection then begin
          // Filled later...
       end else begin
          Panel2.Height := Panel2.Height - cmbBudget.height - 8;
          Height := Height - cmbBudget.height - 8;
       end;


       if RptParams.Division < 0 then begin
          lblDivision.visible := false;
          cmbDivision.visible := false;
          RptParams.Division := 0;
       end else begin
          LoadDivisionList;
          cmbDivision.ItemIndex := cmbDivision.Items.IndexOfObject(Tobject(RptParams.Division));
       end;


       if (not AllowGSTSelection)
       and (not AllowBudgetSelection)
       and (not lblDivision.visible) then begin
          Panel2.Visible := False;
          plInclude.Top := Panel2.Top;
          PlTrading.Top := plInclude.Top + plInclude.Height + 5;
          Height := Height - Panel2.Height;
       end;

       if ShowInclude then begin
          CbLastYear.Checked := RptParams.ShowLastYear;
          if AllowBudgetSelection then
             cbBudget.Checked := RptParams.ShowBudget;
       end else begin
          plInclude.Visible := False;
          PlTrading.Top := plInclude.Top;
          Height := Height - plInclude.Height;
       end;

       if ShowTrade then begin
          ckSales.Checked := RptParams.ShowSales;
          ckGrossProfit.Checked := RptParams.ShowGrossProfit;
          ckNettProfit.Checked := RptParams.ShowNettProfit;
       end else begin
          PlTrading.Visible := False;

          Height := Height - PlTrading.Height;
       end;
    if RptParams.ReportType = (GraphBase + Ord(GRAPH_BANK_BALANCE)) then
    begin
      Height := 260;

    end;
    pcGraph.Height := Height-65;

    if Assigned(MyClient) then begin
      //load report year starts months
      cmbStartMonth.Items.Clear;
      for i := ( moMin + 1) to moMax do
         cmbStartMonth.Items.Add( moNames[ i]);
      //set default
      cmbStartMonth.ItemIndex := 0;

      //set the reporting year starts fields
      tmpYearStarts := MyClient.clFields.clReporting_Year_Starts;
      StDateToDMY( tmpYearStarts, d, m, y);

      spnStartYear.Value := y;
      cmbStartMonth.ItemIndex := m - 1;

      lblReportingYearStartDate.Caption
        := StDateToDateString( 'DD/MM/yyyy', BKNull2St( MyClient.clFields.clReporting_Year_Starts ), True );

      if AllowBudgetSelection then begin

         LoadBudgetCombo;
         if assigned(RptParams.Budget) then
            cmbBudget.ItemIndex := cmbBudget.Items.IndexOfObject(RptParams.Budget)
         else begin // Wrong for smartbooks
            cbBudget.Checked := False;
            cbBudget.Enabled := False;

         end;
      end;


      chkGST.checked     := Rptparams.ShowGST;
      RecalcDates;

      if Params.Period > 0 then
         cmbPeriod.ItemIndex := Params.Period -1;

   end;

   end;

    if RptParams.AccountList.Count>0 then
      for J := 0 to myDlg.fmeAccountSelector1.AccountCheckBox.Items.Count-1 do
      begin
        myDlg.fmeAccountSelector1.AccountCheckBox.Checked[J] := False;
      end;

    for I := 0 to RptParams.AccountList.Count-1 do begin
      for J := 0 to myDlg.fmeAccountSelector1.AccountCheckBox.Items.Count-1 do
        if myDlg.fmeAccountSelector1.AccountCheckBox.Items.Objects[J] = RptParams.AccountList[I] then begin
          myDlg.fmeAccountSelector1.AccountCheckBox.Checked[J] := True;
          Break;
        end;
    end;
    RptParams.AccountList.Clear;

    //****************************
    if MyDlg.Execute then begin
    //****************************
       //get the year starts date from the combo and spin box
       d := 1;
       m := MyDlg.cmbStartMonth.ItemIndex + 1;
       y := MyDlg.spnStartYear.IntValue;
       StartDate := DmyToStDate( d,m,y, bkDateEpoch);

       RptParams.Period := MyDlg.cmbPeriod.ItemIndex+1;
       RptParams.ToDate := MyClient.clFields.clTemp_Period_Details_This_Year[RptParams.Period].Period_End_Date;

       //check that user did not clear the date field
       if StartDate = 0 then
          StartDate := wasDate;
       MyClient.clFields.clReporting_Year_Starts := StartDate;


       RptParams.ShowGst   := Mydlg.chkGST.checked;
       Rptparams.Budget    := nil;
       if AllowBudgetSelection then
         if MyDlg.cmbBudget.ItemIndex <> -1 then
            Rptparams.Budget := TBudget(MyDlg.cmbBudget.Items.Objects[MyDlg.cmbBudget.itemIndex]);

       RptParams.ShowLastYear := Mydlg.cbLastYear.Checked;
       RptParams.ShowBudget := Mydlg.cbBudget.Checked;

       RptParams.ShowSales := Mydlg.ckSales.Checked;
       RptParams.ShowGrossProfit := Mydlg.ckGrossProfit.Checked;
       RptParams.ShowNettProfit := Mydlg.ckNettProfit.Checked;



       if MyDlg.cmbDivision.ItemIndex >= 0 then
          RptParams.Division := Integer( MyDlg.cmbDivision.Items.Objects[ MyDlg.cmbDivision.ItemIndex]);

       //add selected bank accounts to a tlist for used by report
       for i := 0 to MyDlg.fmeAccountSelector1.AccountCheckBox.Count-1 do
          if MyDlg.fmeAccountSelector1.AccountCheckBox.Checked[i] then
          begin
             Rptparams.AccountList.Add(MyDlg.fmeAccountSelector1.AccountCheckBox.Items.Objects[i]);
          end else
            TBank_Account(MyDlg.fmeAccountSelector1.AccountCheckBox.Items.Objects[i]).baFields.baTemp_Include_In_Report := False;

       Result := Rptparams.DlgResult(MyDlg.Pressed);

    end
    else
      MyClient.clFields.clReporting_Year_Starts := wasDate;  {restore date}
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.FormDestroy(Sender: TObject);
begin
  MonthArray := nil;
end;
//------------------------------------------------------------------------------
procedure TdlgGraphRep.cmbBudgetChange(Sender: TObject);
   procedure EnableBudget(Value: Boolean);
   begin
      cbBudget.Enabled := Value;
      if not Value then begin
         cbBudget.Checked := False;
      end;
   end;
begin
   EnableBudget(cmbBudget.ItemIndex <> 0);
end;

procedure TdlgGraphRep.cmbPeriodDrawItem(Control: TWinControl;
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

procedure TdlgGraphRep.cmbStartMonthChange(Sender: TObject);
begin
  if not changing then
  begin
    RecalcDates;
    LoadBudgetCombo;
  end;
end;

procedure TdlgGraphRep.spnStartYearChange(Sender: TObject);
begin
  if not changing then
    RecalcDates;
end;

{ TGraphParams }

procedure TGraphParams.SaveToNode(Value: IXMLNode);
begin
  inherited;
  if ReportType = (GraphBase + Ord(GRAPH_BANK_BALANCE)) then
    SaveAccounts(Value);
end;

end.
