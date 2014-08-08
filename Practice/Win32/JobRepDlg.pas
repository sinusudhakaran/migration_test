unit JobRepDlg;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Select the parameters for the Job Spending Reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, OvcEF,  ExtCtrls, DateSelectorFme, RzLstBox, RzChkLst,
  Grids_ts, TSGrid, TSMask, RPTParams, clObj32, OmniXML, OSFont, UBatchbase;

const
  MinJobRanges = 9;

type

 TJobParameters = class (TRPTParameters)
 protected
   procedure Reset; override;
   procedure ReadFromNode (Value : IXMLNode); override;
   procedure SaveToNode   (Value : IXMLNode); override;
 public
   SummaryReport: Boolean;
   ShowAllCodes: Boolean;
   RangesList: TStringList;
   WrapNarration: Boolean;
   ShowGrossGST: Boolean;
   constructor Create(aType: Integer; aClient: TClientObj;
                      batch: TReportBase; const ADateMode: tDateMode = dNone);
   destructor Destroy; override;
 end;

  TdlgJobRep = class(TForm)
    btnOK: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    pnlAccounts: TPanel;
    rbAllCodes: TRadioButton;
    rbSelectedCodes: TRadioButton;
    pnlDates: TPanel;
    DateSelector: TfmeDateSelector;
    pnlOptions: TPanel;
    rbDetailed: TRadioButton;
    rbSummarised: TRadioButton;
    pnlSelectedCodes: TPanel;
    Label6: TLabel;
    pnlAllCodes: TPanel;
    Label3: TLabel;
    Label1: TLabel;
    tgRanges: TtsGrid;
    btnJob: TSpeedButton;
    tsMaskDefs1: TtsMaskDefs;
    Label9: TLabel;
    chkWrap: TCheckBox;
    btnSaveTemplate: TButton;
    btnLoad: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    btnSave: TBitBtn;
    chkGross: TCheckBox;
    btnEmail: TButton;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SetUpHelp;
    procedure btnPreviewClick(Sender: TObject);
    procedure btnFileClick(Sender: TObject);
    procedure rbSummarisedClick(Sender: TObject);
    procedure rbSelectedCodesClick(Sender: TObject);
    procedure rbAllCodesClick(Sender: TObject);
    procedure tgRangesCellLoaded(Sender: TObject; DataCol,
      DataRow: Integer; var Value: Variant);
    procedure tgRangesEndCellEdit(Sender: TObject; DataCol,
      DataRow: Integer; var Cancel: Boolean);
    procedure btnJobClick(Sender: TObject);
    procedure tgRangesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure rbDetailedClick(Sender: TObject);
    procedure btnSaveTemplateClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    FDataFrom, FDataTo : integer;
    okPressed : boolean;
    FPressed: integer;
    RemovingMask : boolean;
    FJobParameters: TJobParameters;
    function CheckOK (Skipdates : Boolean = False) : boolean;
    procedure SetPressed(const Value: integer);
    procedure SetJobParameters(const Value: TJobParameters);
    procedure ClearJobGrid(RowCount: integer);
  public
    JobCodeList: TStringList;
    function  Execute : boolean;
    property  Pressed : integer read FPressed write SetPressed;
    property  JobParameters: TJobParameters read FJobParameters write SetJobParameters;
  end;

function GetPRParameters(params : TJobParameters) : boolean;

//******************************************************************************
implementation

uses
  MaintainGroupsFrm,
  BKHelp,
  globals,
  InfoMoreFrm,
  ErrorMoreFrm,
  ImagesFrm,
  bkDateUtils,
  ClDateUtils,
  StdHints,
  ReportDefs,
  OmniXMLUtils,
  bkXPThemes,
  Jobobj,
  CountryUtils;

{$R *.DFM}

//------------------------------------------------------------------------------
procedure TdlgJobRep.FormCreate(Sender: TObject);
begin
  bkXPThemes.ThemeForm( Self);

  fDataFrom := ClDateUtils.BAllData( MyClient );
  fDataTo   := ClDateUtils.EAllData( MyClient );

  removingMask := False;

  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( fDataFrom, fDataTo, rbDetailed);

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_JOB_BMP,btnJob.Glyph);

  JobCodeList := TStringList.Create;
  tgRanges.Rows := MinJobRanges;

  //align panels so they occupy the same space
  pnlAllCodes.Left := pnlSelectedCodes.Left;
  pnlAllCodes.Width := pnlSelectedCodes.Width;

  {$IFDEF SmartBooks}
  LastYear1.Visible := false;
  AllData1.Visible  := false;
  {$ENDIF}

  chkGross.Caption := Localise( MyClient.clFields.clCountry, chkGross.Caption);

  SetUpHelp;
end;

//------------------------------------------------------------------------------
procedure TdlgJobRep.FormDestroy(Sender: TObject);
begin
  JobCodeList.Free;
end;

//------------------------------------------------------------------------------
procedure TdlgJobRep.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := BKH_Coding_by_job_report;
   //Components
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
procedure TdlgJobRep.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
procedure TdlgJobRep.btnOKClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_PRINT;
     okPressed := true;
     close;
   end;
end;
//------------------------------------------------------------------------------
function TdlgJobRep.CheckOK(Skipdates: Boolean): boolean;
var
  i : integer;
  AtLeastOneRangeEntered : boolean;
begin
  result := false;
  {now check the values are ok}
  if not Skipdates then begin

    if (not DateSelector.ValidateDates) then begin
       dateselector.eDateFrom.SetFocus;
       Exit;
    end;

    if (DateSelector.eDateFrom.AsStDate > DateSelector.eDateTo.AsStDate) then
    begin
       HelpfulInfoMsg('"From" Date is later than "To" Date.  Please select valid dates.',0);
       dateselector.eDateTo.SetFocus;
       Exit;
    end;
  end;
  //check ranges, if user reported on selected codes then at least one range
  //must be entered
  if rbSelectedCodes.Checked then
  begin
    tgRanges.EndEdit( False);
    AtLeastOneRangeEntered := false;
    for i := 0 to JobCodeList.Count - 1 do 
    begin
      //Check Jobs valid
      if JobCodeList[i] <> '' then
      begin
        AtLeastOneRangeEntered := True;
        if not Assigned(MyClient.clJobs.FindCode(JobCodeList[i])) then
        begin
          HelpfulInfoMsg(Format('The Job Code %s is invalid.'#13#13'Please select a valid Job Code',[JobCodeList[i]]), 0);
          tgRanges.SetFocus;
          Exit;
        end;
      end;
    end;

    if not AtLeastOneRangeEntered then
    begin
     HelpfulInfoMsg( 'You must enter at least one Job', 0);
     tgRanges.SetFocus;
     Exit;
    end;
  end;
  result := true;
end;

//------------------------------------------------------------------------------
procedure TdlgJobRep.ClearJobGrid(RowCount: integer);
begin
  JobCodeList.Clear;
  tgRanges.DeleteRows(1, tgRanges.Rows);
  tgRanges.Rows := MinJobRanges;
  if (RowCount > MinJobRanges) then
    tgRanges.Rows := RowCount;
end;

//------------------------------------------------------------------------------
procedure TdlgJobRep.SetJobParameters(const Value: TJobParameters);
begin
  FJobParameters := Value;
  if Assigned(FJobParameters) then begin
     FJobParameters.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,Btnsave,BtnOk);
     if Assigned(FJobParameters.RptBatch) then
        Caption := Caption + ' [' + FJobParameters.RptBatch.Name + ']';
  end;
end;

procedure TdlgJobRep.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
procedure TdlgJobRep.btnPreviewClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_PREVIEW;
     okPressed := true;
     close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgJobRep.btnEmailClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_EMAIL;
     okPressed := true;
     close;
   end;
end;

procedure TdlgJobRep.btnFileClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_FILE;
     okPressed := true;
     close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TdlgJobRep.rbSummarisedClick(Sender: TObject);
begin

end;
//------------------------------------------------------------------------------
function TdlgJobRep.Execute: boolean;
begin
   okPressed := false;
   Pressed := BTN_NONE;

   {display}
   Self.ShowModal;
   result := okPressed;
end;
//------------------------------------------------------------------------------
function GetPRParameters(Params : TJobParameters) : boolean;
var
  Mydlg : TdlgJobRep;
begin
  result := false;
  Mydlg := TdlgJobRep.Create(Application.MainForm);
  try
     Params.RunBtn := BTN_NONE;
     Mydlg.JobParameters := Params;
     MyDlg.rbSummarised.Checked := Params.SummaryReport;
     MyDlg.rbDetailed.Checked := not Params.SummaryReport;
     MyDlg.rbAllCodes.Checked := Params.ShowAllCodes;
     MyDlg.rbSelectedCodes.Checked := not Params.ShowAllCodes;
     MyDlg.chkWrap.Checked := Params.WrapNarration;
     MyDlg.chkGross.Checked := Params.ShowGrossGST;

     //populate job list
     MyDlg.JobCodeList.Assign(Params.RangesList);

     if ( Params.Fromdate <> 0) and ( Params.ToDate <> 0) then
     begin
       MyDlg.DateSelector.eDateFrom.AsStDate := Params.FromDate;
       MyDlg.DateSelector.eDateTo.AsStDate := Params.ToDate;
     end
     else
     begin
       {use default date}
       MyDlg.DateSelector.eDateFrom.asStDate := BkNull2St(MyClient.clFields.clPeriod_Start_Date);
       MyDlg.DateSelector.eDateTo.asStDate := BkNull2St(MyClient.clFields.clPeriod_End_Date);
     end;

     if MyDlg.Execute then
     begin
        Params.FromDate := StNull2Bk(MyDlg.DateSelector.eDateFrom.AsStDate);
        Params.ToDate := StNull2Bk(MyDlg.DateSelector.eDateTo.AsStDate);
        Params.SummaryReport := MyDlg.rbSummarised.Checked;
        Params.ShowAllCodes := MyDlg.rbAllCodes.Checked;
        Params.WrapNarration := MyDlg.chkWrap.Checked;
        Params.ShowGrossGST := MyDlg.chkGross.Checked;
        //populate job list
        if not Params.ShowAllCodes then
          Params.RangesList.Assign(MyDlg.JobCodeList);

        if Params.Todate = 0 then
          Params.ToDate := MaxInt;

        Params.RunBtn := MyDlg.Pressed;
        Result := true;
     end;
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TdlgJobRep.rbSelectedCodesClick(Sender: TObject);
begin
  pnlSelectedCodes.Visible := true;
  pnlAllCodes.Visible := false;
  if Visible then
    tgRanges.SetFocus; // Enter editing state  
end;

procedure TdlgJobRep.rbAllCodesClick(Sender: TObject);
begin
  pnlAllCodes.Visible := true;
  pnlSelectedCodes.Visible := false;
end;

procedure TdlgJobRep.tgRangesCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
begin
  Value := '';
  if JobCodeList.Count > (DataRow - 1) then
    Value := JobCodeList[DataRow - 1];
  if (Value <> '') and not Assigned(MyClient.clJobs.FindCode(Value)) then
    tgRanges.CellColor[DataCol, DataRow] := clRed
  else
    tgRanges.CellColor[DataCol, DataRow] := clNone;
end;

procedure TdlgJobRep.tgRangesEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  Value : string;
begin
  Value := tgRanges.CurrentCell.Value;
  if JobCodeList.Count > (DataRow - 1) then
    JobCodeList[DataRow - 1] := Value
  else
    JobCodeList.Add(Value);

  //Set Edit Mode
  tgRanges.EditMode := emEdit;
  if (DataRow >= tgRanges.Rows) then
    tgRanges.EditMode := emEditInsert;
end;

procedure TdlgJobRep.btnJobClick(Sender: TObject);
var
  Code : string;
  CodeList: TStringList;
  CodeIndex: Integer;
begin
  if PickJob(Code, True, True, False) then
  begin
    //if get here then have a code which can be posted to from picklist
    CodeList := TStringList.Create;
    try
      CodeList.Delimiter := #9;
      CodeList.DelimitedText := Code;

      {ClearJobGrid(CodeList.Count); - We probably don't need to clear the grid when adding a job}
      for CodeIndex := 0 to CodeList.Count - 1 do
      begin
        tgRanges.CurrentCell.Value := CodeList[CodeIndex];
        tgRanges.CurrentDataRow := tgRanges.CurrentDataRow + 1;
      end;
    finally
      CodeList.Free;
    end;
    tgRanges.CurrentCell.PutInView;
    tgRanges.SetFocus;
  end;
end;

procedure TdlgJobRep.tgRangesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 116 then //F5
  begin
    Key := 0;
    btnJob.Click;
  end;
end;

procedure TdlgJobRep.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
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

procedure TdlgJobRep.rbDetailedClick(Sender: TObject);
begin
  chkWrap.Enabled := rbDetailed.Checked;
  if chkWrap.Checked and rbSummarised.Checked then
    chkWrap.Checked := False;
end;

procedure TdlgJobRep.btnSaveTemplateClick(Sender: TObject);
var
  i: integer;
begin
  SaveDialog1.InitialDir := Globals.DataDir;
  if SaveDialog1.Execute then begin
    //Remove any blank rows
    for i := tgRanges.Rows downto 1 do
      if tgRanges.Cell[1, i] = '' then
        tgRanges.DeleteRows(i, i);
    tgRanges.SaveToFile(SaveDialog1.FileName, True);
  end;
end;

procedure TdlgJobRep.btnSaveClick(Sender: TObject);
begin
   if checkOK (True) then
   begin
     if not FJobParameters.CheckForBatch then
         Exit;
     Pressed  := BTN_SAVE;
     okPressed := true;
     close;
   end;
end;

procedure TdlgJobRep.btnLoadClick(Sender: TObject);
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
        HelpfulErrorMsg('The selected file is not a valid Job Report Template file', 0);
        exit;
      end;
    end;
    JobCodeList.Clear;
    for i := 1 to tgRanges.Rows do
      JobCodeList.Add(tgRanges.Cell[1, i]);
    tgRanges.OnCellLoaded := tgRangesCellLoaded;
  end;
end;

{ TJobParameters }

const
  t_JobList = 'Jobs';


constructor TJobParameters.Create(aType: Integer; aClient: TClientObj;
  batch: TReportBase; const ADateMode: tDateMode);
begin
  RangesList := TStringList.Create; 
  inherited Create(aType, aClient, batch, ADateMode);
end;

destructor TJobParameters.Destroy;
begin
  RangesList.Clear;
  RangesList.Free;
  inherited;
end;

procedure TJobParameters.ReadFromNode(Value: IXMLNode);
  function NoCodes : Boolean;
  var
    NN: IXMLNode;
    LList: IXMLNodeList;
    I: Integer;
  begin
    Result := True;
    NN := FindNode(Value,t_JobList);
    if not assigned(NN) then exit;
    LList := FilterNodes(NN,'Code');
    if not assigned(LList) then exit;
    if LList.Length = 0 then exit;
    for I := 0 to LList.Length - 1 do begin
      // Found at least one..
      Result := False;
      RangesList.Add(GetNodeTextStr(LList.Item[I],'JobCode'));
    end;
  end;

begin
  inherited;
  SummaryReport := GetNodeBool(Value,'Summarised',False);
  WrapNarration := GetNodeBool(Value,'Wrap_Narration',True);
  ShowGrossGST     := GetNodeBool(Value,'Show_Gross_and_GST',False);
  ShowAllCodes  := NoCodes;
end;

procedure TJobParameters.Reset;
begin
  inherited;
  RangesList.Clear;
  ShowAllCodes := True;
end;


procedure TJobParameters.SaveToNode(Value: IXMLNode);
  function NoCodes : Boolean;
  var
    NN,AN : IXMLNode;
    I : Integer;
  begin
    Result := True;
    NN := nil;
    AN := nil;
    for I := 0 to RangesList.Count - 1 do begin
      if (RangesList[i] <> '') then begin
        // Got one..
        if Result then begin
          Result := False;
          AN := EnsureNode(Value,t_JobList);
          AN.Text := '';
        end;
        NN := AppendNode(AN,'Code');
        SetNodeTextStr(NN, 'JobCode', RangesList[i]);
      end;
    end;
  end;

begin
  if SummaryReport then
      rptBatch.Title := Report_List_Names [Report_Job_Summary]
  else
      rptBatch.Title := Report_List_Names [Report_Job_Detailed];

  inherited;
  SetNodeBool(Value,'Summarised',SummaryReport);
  SetNodeBool(Value,'Wrap_Narration',WrapNarration);
  SetNodeBool(Value,'Show_Gross_and_GST',ShowGrossGST);
  if NoCodes then
    ClearSetting(Value,t_JobList);
end;

end.
