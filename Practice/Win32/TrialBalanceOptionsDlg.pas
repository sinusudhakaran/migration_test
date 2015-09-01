unit TrialBalanceOptionsDlg;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, clObj32, StdCtrls, ExtCtrls, Mask, RzEdit, RzSpnEdt, PeriodUtils,
  RptParams,
  UbatchBase, Buttons,
  OSFont;

type
  TdlgTrialBalanceOptions = class(TForm)
    Label1: TLabel;
    cmbStartMonth: TComboBox;
    spnStartYear: TRzSpinEdit;
    Label4: TLabel;
    cmbPeriod: TComboBox;
    pnlButtons: TPanel;
    btnPrint: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    lblLast: TLabel;
    chkIncludeCodes: TCheckBox;
    chkGSTInclusive: TCheckBox;
    btnSave: TBitBtn;
    btnEmail: TButton;
    BevelBorder: TBevel;

    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cmbPeriodDrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure cmbStartMonthChange(Sender: TObject);
    procedure spnStartYearChange(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    ThisClient           : TClientObj;
    MonthArray           : TMonthArray;
    LastPeriodOfActualData : integer;
    tmpYearStarts        : Integer;
    Params : TGenRptParameters;
    procedure RecalcDates;
    procedure LoadClientSettings;
    procedure SaveClientSettings;

    function  VerifyForm : boolean;

    procedure GenerateReport;
  public
    { Public declarations }
  end;

  function UpdateTrialBalanceReportOptions(const aClient: TClientObj;
                                           RptBatch: TReportBase = nil ): integer;

implementation

uses
  UxTheme,
  bkConst,
  bkDateUtils,
  BKHelp,
  bkXPThemes,
  Globals,
  imagesfrm,
  JnlUtils32,
  Reports,
  ReportDefs,
  RptTrialBalance,
  StDate,
  StDateSt,
  WarningMoreFrm,
  YesNoDlg, BKDEFS;

{$R *.dfm}

function UpdateTrialBalanceReportOptions( const aClient : TClientObj;RptBatch : TReportBase = nil) : integer;
//all of the reporting variables are now stored in Client.clFields...
//most of the settings are persistent so that the user will see their last
//settings when they reenter the dialog.
//returns the value of the button pressed
var
  TrialBalanceOptions : TdlgTrialBalanceOptions;

  procedure CheckToDate;
  var i : integer;
  begin with TrialBalanceOptions, params do begin
     if Todate = 0 then
        exit;
     for i := Low(MonthArray) to High(MonthArray) do
        if MonthArray[i].PeriodEndDate >= Todate then begin
           cmbPeriod.ItemIndex := Pred(i); // ? Pred
           Break;
        end;
  end;end;
begin
  TrialBalanceOptions := TdlgTrialBalanceOptions.Create(Application.MainForm);
   with TrialBalanceOptions do begin
      try
        Params := TGenRptParameters.Create(ord(Report_TrialBalance),AClient,RptBatch,dYear);
        BKHelpSetUp(TrialBalanceOptions, BKH_Trial_balance_report);


        ThisClient := aClient;
        LoadClientSettings;

        if Params.BatchSetup then begin

           CheckToDate;
        end;

        Params.SetDlgButtons(btnPreview,BtnFile,BtnEmail,BtnSave,BtnPrint);
        if Assigned(RptBatch) then
           Caption := Caption + ' [' + RptBatch.Name + ']';

        //************
        ShowModal;
        //************

        if Params.RunBtn <> BTN_NONE then begin  // Has run..
           SaveClientSettings;
        end;
        result := Params.RunBtn;
      finally
        Free;
      end;
   end;
end;

procedure TdlgTrialBalanceOptions.btnPreviewClick(Sender: TObject);
begin
  if VerifyForm then begin
    Params.RunBtn := Globals.BTN_PREVIEW;
    GenerateReport;
  end;
end;

procedure TdlgTrialBalanceOptions.btnEmailClick(Sender: TObject);
begin
  if VerifyForm then begin
    Params.RunBtn := Globals.BTN_EMAIL;
    GenerateReport;
  end;
end;

procedure TdlgTrialBalanceOptions.btnFileClick(Sender: TObject);
begin
  if VerifyForm then begin
    Params.RunBtn := Globals.BTN_FILE;
    GenerateReport;
  end;
end;

procedure TdlgTrialBalanceOptions.btnPrintClick(Sender: TObject);
begin
  if VerifyForm then begin
    Params.RunBtn := Globals.BTN_PRINT;
    GenerateReport;
    if Params.BatchRunMode = R_Batch then
         Close

  end;
end;

procedure TdlgTrialBalanceOptions.btnSaveClick(Sender: TObject);
begin
   Params.RunBtn := Globals.BTN_SAVE;
   if Params.BatchRunMode = R_Batch then
         Close
   else begin
      if VerifyForm then begin
         if not Params.CheckForBatch('Trial Balance') then
            Exit;



         Params.ChartCodes := chkIncludeCodes.Checked;
         Params.ShowGST    := chkGSTInclusive.Checked;
         Params.SaveNodeSettings;
         {if Params.WasNewBatch then begin
            Params.SetDlgButtons(btnPreview,BtnFile,BtnSave,BtnPrint);
            Caption := Caption + ' [' + Params.RptBatch.Name + ']';
         end else}
           Close;
      end;
   end;
end;

procedure TdlgTrialBalanceOptions.btnCancelClick(Sender: TObject);
begin
   Params.RunBtn := Globals.BTN_NONE;
   Close;
end;

procedure TdlgTrialBalanceOptions.FormCreate(Sender: TObject);
var
  i : integer;
begin
  bkXPThemes.ThemeForm( Self);
  Params := nil;
  //load report year starts months
  cmbStartMonth.Items.Clear;
  for i := ( moMin + 1) to moMax do
     cmbStartMonth.Items.Add( moNames[ i]);
   //set default
  cmbStartMonth.ItemIndex := 0;

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;
end;

procedure TdlgTrialBalanceOptions.FormDestroy(Sender: TObject);
begin
  if assigned(Params) then
     FreeAndNil(Params)
end;

procedure TdlgTrialBalanceOptions.LoadClientSettings;
var
   d,m,y : integer;
begin
   //set the reporting year starts fields
   tmpYearStarts := ThisClient.clFields.clReporting_Year_Starts;

   chkIncludeCodes.Checked := params.ChartCodes;
   chkGSTInclusive.Caption := '&' + ThisClient.TaxSystemNameUC + ' Inclusive';
   chkGSTInclusive.Checked := params.ShowGST;

   StDateToDMY( tmpYearStarts, d, m, y);

   spnStartYear.Value      := y;
   cmbStartMonth.ItemIndex := m - 1;

   //fill the ending combo box with valid months no that have set
   RecalcDates;
end;

procedure TdlgTrialBalanceOptions.SaveClientSettings;
begin
  with ThisClient.clFields do begin
     clReporting_Year_Starts              := tmpYearStarts;
     clTemp_FRS_Last_Period_To_Show       := cmbPeriod.ItemIndex + 1;
     clTemp_FRS_Last_Actual_Period_To_Use := clTemp_FRS_Last_Period_To_Show;
     clFRS_Print_Chart_Codes              := chkIncludeCodes.Checked;
     clGST_Inclusive_Cashflow             := chkGSTInclusive.Checked;

     Params.FromDate := clReporting_Year_Starts;
     Params.Todate   := MonthArray[clTemp_FRS_Last_Period_To_Show].PeriodEndDate;
     Params.Period   := clTemp_FRS_Last_Period_To_Show;
  end;
end;

procedure TdlgTrialBalanceOptions.RecalcDates;
type
   tState = ( Coded, Uncoded, NoData );
var
   d,m,y,pd : integer;
   State    : tState;
   MaxCoded : integer;
   PeriodType : integer;

   MaxPeriods : integer;

   tmpYearEnds : integer;
begin
   //get the year starts date from the combo and spin box
   d := 1;
   m := cmbStartMonth.ItemIndex + 1;
   y := spnStartYear.IntValue;
   tmpYearStarts := DmyToStDate( d,m,y, bkDateEpoch);
   tmpYearEnds   := bkDateUtils.GetYearEndDate( tmpYearStarts);

   with ThisClient.clFields do
   begin
      MaxCoded   := 0;
      LastPeriodOfActualData := 0;
      PeriodType := frpMonthly;                                                                   //cash only//
      MaxPeriods := PeriodUtils.LoadPeriodDetailsIntoArray( ThisClient, tmpYearStarts, tmpYearEnds, false, PeriodType,
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

function TdlgTrialBalanceOptions.VerifyForm: boolean;
begin
  result := true;
end;


procedure TdlgTrialBalanceOptions.cmbPeriodDrawItem(Control: TWinControl;
  Index: Integer; Rect: TRect; State: TOwnerDrawState);

begin
  //This ensures the correct highlite color is used
  cmbPeriod.canvas.fillrect(rect);
  //This line draws the actual bitmap

  AppImages.Period.Draw(cmbPeriod.Canvas,rect.left,rect.top,MonthArray[index+1].ImageIndex);
  //This line writes the text after the bitmap
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+2,rect.top,  MonthArray[index+1].Day);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+20,rect.top,  MonthArray[index+1].Month);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+60,rect.top, MonthArray[index+1].Year);
  cmbPeriod.canvas.textout(rect.left+AppImages.Period.width+100,rect.top, MonthArray[index+1].Status);
end;


procedure TdlgTrialBalanceOptions.GenerateReport;
var
  ErrorMsg : string;
  Destination : TReportDest;
begin
  SaveClientSettings;

  case Params.RunBtn of
    BTN_PRINT   : Destination := rdPrinter;
    BTN_PREVIEW : Destination := rdScreen;
    BTN_FILE    : Destination := rdFile;
    BTN_EMAIL   : Destination := rdEmail;
  else
    Destination := rdScreen;
  end;

  RptTrialBalance.VerifyPreConditions( ThisClient, ErrorMsg);
  if ErrorMsg <> '' then begin
    HelpfulWarningMsg('You cannot produce a Trial Balance Report at this time '+
                      'because of the following errors: '#13 + ErrorMsg , 0);
    Params.RunBtn := BTN_None;
    Exit;
  end;

  if not JnlUtils32.CheckForOpeningBalance( ThisClient, ThisClient.clFields.clReporting_Year_Starts) then begin
    //warn the user that there are no balances
    if not Globals.INI_DontShowMe_NoOpeningBalances then begin
      if YesNoDlg.AskYesNoCheck( 'Generate Report',
                              'You have not entered opening balances on the '+
                              'selected Reporting Year Start date (' + bkDate2Str(ThisClient.clFields.clReporting_Year_Starts) + ').'#13#13 +
                              'Do you still want to generate this report?',
                              'Don''t ask me this again',
                              INI_DontShowMe_NoOpeningBalances,
                              DLG_NO ,0) <> DLG_YES then begin
                                 Params.RunBtn := BTN_None;
                                 Exit;
                              end;

    end;
  end;
  Reports.DoReport( REPORT_TRIALBALANCE, Destination,0,Params.RpTbatch);
end;

procedure TdlgTrialBalanceOptions.cmbStartMonthChange(Sender: TObject);
begin
  RecalcDates;
end;

procedure TdlgTrialBalanceOptions.spnStartYearChange(Sender: TObject);
begin
  RecalcDates;
end;

end.
