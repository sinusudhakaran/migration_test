unit ExceptRepDlg;
//------------------------------------------------------------------------------
{
   Title:       Exception Report Options Dialog

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, OvcABtn, OvcBase, OvcEF, OvcPB, OvcPF,
  ImgList, clObj32, PeriodUtils,RzSpnEdt, RptParams, OmniXml, Mask, RzEdit,
  OsFont;

type
   TExceptParam = class (TGenRptParameters)
   protected
      procedure LoadFromClient (Value : TClientObj); override;
      procedure SaveToClient (Value : TClientObj); override;
      procedure ReadFromNode (Value : IXMLNode); override;
      procedure SaveToNode   (Value : IXMLNode); override;
   public
      Options   : word;
   end;

const
    exYTD_vs_BudgetYTD = $0001;
    exYTD_vs_LastYrYTD = $0002;           
    exThisPd_vs_Budget = $0004;
    exThisPd_vs_LastYr = $0008;

type
  TdlgExceptRpt = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    Panel1: TPanel;
    chkGST: TCheckBox;
    Panel2: TPanel;
    Label3: TLabel;
    CmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Panel3: TPanel;
    lblLast: TLabel;
    cmbPeriod: TComboBox;
    OvcController1: TOvcController;
    Label1: TLabel;
    Panel4: TPanel;
    chkYTDBud: TCheckBox;
    chkYTDLast: TCheckBox;
    chkThisPeriodBud: TCheckBox;
    chkThisPeriodLY: TCheckBox;
    cmbBudget: TComboBox;
    Label2: TLabel;
    Label4: TLabel;
    btnSave: TBitBtn;
    btnEmail: TButton;

    procedure edtFinancialYearStartDateChange(Sender: TObject);
    procedure edtFinancialYearStartDateKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure edtFinancialYearStartDateError(Sender: TObject; ErrorCode: Word;
      ErrorMsg: String);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btnPreviewClick(Sender: TObject);
    procedure cmbPeriodDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure FormShow(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure CmbStartMonthChange(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);

  private
    SmartOn,changing  : boolean;
    okPressed : boolean;
    FPressed: integer;
    FClient : TClientObj;
    LastPeriodOfActualData : integer;
    MonthArray : TMonthArray;
    FParams: TExceptParam;
    procedure LoadBudgetList;
    procedure RecalcDates;
    procedure SetPressed(const Value: integer);
    function  CheckOK : boolean;
    procedure SetParams(const Value: TExceptParam);
    { Private declarations }
  public
    property Pressed : integer read FPressed write SetPressed;
    property params: TExceptParam read Fparams write Setparams;
    { Public declarations }
  end;

function GetExceptOpt(eOptions: TExceptParam) : boolean;

//******************************************************************************
implementation

uses
  bkConst,
  bkDateUtils,
  BKHelp,
  bkXPThemes,
  SelectDate,
  ovcDate,
  globals,
  stDatest,
  BUDOBJ32,
  InfoMoreFrm,
  imagesFrm,
  StdHints, BKDEFS;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgExceptRpt.FormCreate(Sender: TObject);
var I : Integer;
begin
  bkXPThemes.ThemeForm( Self);
  Changing := false;
  //edtFinancialYearStartDate.Epoch       := BKDATEEPOCH;
  //edtFinancialYearStartDate.PictureMask := BKDATEFORMAT;
{$IFDEF SmartBooks}
  lblFinancialYearStartDate.Visible := True;
  edtFinancialYearStartDate.Visible := False;
{$ELSE}
  //lblFinancialYearStartDate.Visible := False;
  //edtFinancialYearStartDate.Visible := True;
{$ENDIF}
  SetUpHelp;

  cmbStartMonth.Items.Clear;
  for I := ( moMin + 1) to moMax do
     cmbStartMonth.Items.Add( moNames[ I]);
     //set default
  cmbStartMonth.ItemIndex := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExceptRpt.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
   //Components
   cmbStartMonth.Hint := STDHINTS.RptFinYearStartHint;
   spnStartYear.Hint  := STDHINTS.RptFinYearStartHint;

   
   cmbPeriod.Hint           :=
                            STDHINTS.RPTPERIODHINT;
   chkThisPeriodLY.Hint     :=
                            'Compare the figures against the same period Last Year|' +
                            'Compare the selected period''s figures against the same period Last Year';
   chkThisPeriodBud.Hint    :=
                            'Compare the figures against this period Budget|' +
                            'Compare the selected period''s figures against the budgeted figures';
   chkYTDLast.Hint          :=
                            'Compare the YTD figures against last year''s YTD figures|' +
                            'Compare the YTD figures against last year''s YTD figures';
   chkYTDBud.Hint           :=
                            'Compare the YTD figures against YTD budgeted figures|' +
                            'Compare the YTD figures against YTD budgeted figures';
   btnPreview.Hint          :=
                            STDHINTS.PreviewHint;
   btnOK.Hint               :=
                            STDHINTS.PrintHint;
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.FormShow(Sender: TObject);
begin
   // Financial Year not usually changed
   cmbPeriod.SetFocus;
end;

procedure TdlgExceptRpt.LoadBudgetList;
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
      if (buM = clM) then
      begin
        S := buFields.buName + ' (' + bkDate2Str(buFields.buStart_Date) + ')';
        cmbBudget.Items.AddObject(S, clBudget_List.Budget_At(i));
      end;
    end;
  end;
  if cmbBudget.Items.Count > 0 then
     cmbBudget.ItemIndex := 0;  //set to latest by default
end;


//------------------------------------------------------------------------------
procedure TdlgExceptRpt.edtFinancialYearStartDateKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
   SmartOn := not((key = 8) or (key=46));
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExceptRpt.RecalcDates;
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
   //get the year starts date
   Changing := true;
   try

      d := 1;
      m := cmbStartMonth.ItemIndex + 1;
      y := spnStartYear.IntValue;
      tmpYearStarts := DmyToStDate( d,m,y, bkDateEpoch);
      tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);
   finally
     Changing := false;
   end;

   with FClient.clFields do
   begin
      MaxCoded   := 0;
      LastPeriodOfActualData := 0;

      PeriodType := frpMonthly;
      MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( FClient, tmpYearStarts, tmpYearEnds, False, PeriodType,
                                                            clTemp_Period_Details_This_Year);
      //need to resize the months array to the correct size
      cmbPeriod.Items.Clear;
      SetLength( MonthArray, MaxPeriods + 1);

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
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TdlgExceptRpt.edtFinancialYearStartDateChange(Sender: TObject);
begin
  (*
  if smartOn and not changing then
  if (TOvcPictureField(Sender).CurrentPos = length(BKDATEFORMAT))
  and DateIsValid(edtFinancialYearStartDate.AsString) then
  begin
     RecalcDates;
  end;
  *)
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.edtFinancialYearStartDateError(Sender: TObject; ErrorCode: Word; ErrorMsg: String);
begin
   ShowDateError(Sender);
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btnOKClick(Sender: TObject);
begin
   if CheckOK then
   begin
     Pressed := BTN_PRINT;
     okPressed := true;
     Close;
   end;
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btnCancelClick(Sender: TObject);
begin
   Close;
end;

//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btnEmailClick(Sender: TObject);
begin
   if CheckOK then
   begin
     Pressed := BTN_EMAIL;
     okPressed := true;
     Close;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btn1Click(Sender: TObject);
begin
   RecalcDates;
end;

//------------------------------------------------------------------------------
function GetExceptOpt(EOptions : TExceptParam) : boolean;
var
  MyDlg : TdlgExceptRpt;
  wasDate : tStDate;
  d,m,y : integer;
begin
  result := false;
  wasDate := EOptions.Client.clFields.clReporting_Year_Starts;
  EOptions.RunBtn := btn_none;

  MyDlg:= TdlgExceptRpt.Create(Application);
  try
    BKHelpSetUp(MyDlg, BKH_Exception_report);

    with MyDlg, EOptions do begin
       FClient := Client;
       Params := EOptions;
       chkGST.Caption := 'Print &' + Client.TaxSystemNameUC + ' Inclusive';

       StDateToDMY( Fromdate, d, m, y);
       spnStartYear.Value := y;
       cmbStartMonth.ItemIndex := m - 1;

      // lblFinancialYearStartDate.Caption
      //  := StDateToDateString( 'DD/MM/yyyy', BKNull2St( tmpYearStarts ), True );

        (*
       edtFinancialYearStartDate.AsStDate := BkNull2St(Fromdate);
       lblFinancialYearStartDate.Caption  :=
         StDateToDateString( 'DD/MM/yyyy', BKNull2St( Fromdate ), True );
         *)

       chkYTDBud.checked         := (Options and exYTD_vs_BudgetYTD) = exYTD_vs_BudgetYTD;
       chkYTDLast.Checked        := (Options and exYTD_vs_LastYrYTD) = exYTD_vs_LastYrYTD;
       chkThisPeriodBud.Checked  := (Options and exThisPd_vs_Budget) = exThisPd_vs_Budget;
       chkThisPeriodLY.Checked   := (Options and exThisPd_vs_LastYr) = exThisPd_vs_LastYr;
       chkGST.Checked            := ShowGst;

       RecalcDates;
       if Period > 0 then
         cmbPeriod.ItemIndex := Pred(Period);

       LoadBudgetList;

       if assigned(Budget) then  begin
          d := cmbBudget.Items.IndexOfObject(Budget);
          // debug...
          cmbBudget.ItemIndex := d;
       end;


       Pressed := BTN_NONE;
       //***********
       ShowModal;
       //***********

       if okPressed then begin

          d := 1;
          m := cmbStartMonth.ItemIndex + 1;
          y := spnStartYear.IntValue;
          FromDate := DmyToStDate( d,m,y, bkDateEpoch);

          //check that user did not clear the date field
          if FromDate = 0 then
              FromDate := wasDate;
          EOptions.Client.clFields.clReporting_Year_Starts := FromDate;
          Period  := Succ(cmbPeriod.ItemIndex);
          ToDate := MonthArray[ Period ].PeriodEndDate;

          ShowGst := chkGST.checked;
          Options   := 0;
          if chkYTDBud.Checked then Options := Options or exYTD_vs_BudgetYTD;
          if chkYTDLast.checked then Options := Options or exYTD_vs_LastYrYTD;
          if chkThisPeriodBud.checked then Options := Options or exThisPd_vs_Budget;
          if chkThisPeriodLY.checked then Options := Options or exThisPd_vs_LastYr;

          Budget := nil;
          if chkYTDBud.checked
          or chkThisPeriodBud.Checked then
             if cmbBudget.ItemIndex >= 0 then
               Budget :=  TBudget(MyDlg.cmbBudget.Items.Objects[MyDlg.cmbBudget.ItemIndex]);

          if Batchless then begin
             EOptions.Client.clFields.clException_Options := Options;
             EOptions.Client.clFields.clGST_Inclusive_Cashflow := chkGST.checked;
          end;
          RunBtn := Mydlg.Pressed;
          result := true;
       end else
          Client.clFields.clReporting_Year_Starts := wasDate;  {restore date}
    end;
  finally
    MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.Setparams(const Value: TExceptParam);
begin
  FParams := Value;
  if assigned(FParams) then begin
     FParams.SetDlgButtons(btnPreview, btnFile, btnEmail, btnSave, btnOk);
     if assigned(FParams.RptBatch) then
        Caption := Caption + ' [' + FParams.RptBatch.Name + ']';
  end else
     btnSave.Hide;
end;

procedure TdlgExceptRpt.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
function TdlgExceptRpt.CheckOK: boolean;
begin
  result := false;
  if not(chkYTDBud.checked
         or chkYTDLast.Checked
         or chkThisPeriodBud.Checked
         or chkThisPeriodLY.Checked) then begin
     HelpfulInfoMsg('Please select what you want to compare',0);
     exit;
  end;


  if chkYTDBud.checked
  or chkThisPeriodBud.Checked then begin
     // Must have a budget
     if cmbBudget.ItemIndex < 0 then

        if cmbBudget.Items.Count > 0 then begin
           HelpfulInfoMsg( 'Please select a budget to use.', 0);
           cmbBudget.SetFocus;
           Exit;
        end else begin
           HelpfulInfoMsg( 'Please select a period with a budget.', 0);
           cmbStartMonth.SetFocus;
           Exit;
        end;

  end;

  // Still here
  result := true;
end;
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btnPreviewClick(Sender: TObject);
begin
   if CheckOK then
   begin
     Pressed := BTN_PREVIEW;
     okPressed := true;
     Close;
   end;
end;

procedure TdlgExceptRpt.btnSaveClick(Sender: TObject);
begin
   if CheckOK then
   begin
     if not FParams.CheckForBatch then
         Exit;
     Pressed := BTN_SAVE;
     okPressed := true;
     Close;
   end;
end;

//------------------------------------------------------------------------------
procedure TdlgExceptRpt.cmbPeriodDrawItem(Control: TWinControl;
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

procedure TdlgExceptRpt.CmbStartMonthChange(Sender: TObject);
begin
   if not Changing then
     LoadBudgetList;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
procedure TdlgExceptRpt.btnFileClick(Sender: TObject);
begin
   if CheckOK then
   begin
     Pressed := BTN_FILE;
     okPressed := true;
     Close;
   end;
end;

{ TExceptParam }

procedure TExceptParam.LoadFromClient(Value: TClientObj);
begin
  inherited;
  Options := Client.clFields.clException_Options;
end;

procedure TExceptParam.ReadFromNode(Value: IXMLNode);
begin
  inherited;
  Options := 0;
   if GetBatchBool('YTD_with_Budget')    then Options := Options or exYTD_vs_BudgetYTD;
   if GetBatchBool('YTD_with_LastYear')  then Options := Options or exYTD_vs_LastYrYTD;
   if GetBatchBool('This_period_with_Budget')   then Options := Options or exThisPd_vs_Budget;
   if GetBatchBool('This_period_with_Last_Year') then Options := Options or exThisPd_vs_LastYr;

end;

procedure TExceptParam.SaveToClient(Value: TClientObj);
begin
  inherited;
  Client.clFields.clException_Options := Options;
end;

procedure TExceptParam.SaveToNode(Value: IXMLNode);
begin
  inherited;
  SetBatchBool('YTD_with_Budget',    (Options and exYTD_vs_BudgetYTD)<>0);
  SetBatchBool('YTD_with_LastYear',  (Options and exYTD_vs_LastYrYTD)<>0);
  SetBatchBool('This_period_with_Budget',   (Options and exThisPd_vs_Budget)<>0);
  SetBatchBool('This_period_with_Last_Year', (Options and exThisPd_vs_LastYr)<>0);
end;

end.
