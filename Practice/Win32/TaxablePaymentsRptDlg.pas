unit TaxablePaymentsRptDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  OvcBase, StdCtrls, ActnList, Buttons, OvcABtn, OvcEF, OvcPB, OvcPF, Menus,
  ExtCtrls, DateSelectorFme, RzLstBox, RzChkLst, ComCtrls, Grids, Grids_ts,
  TSGrid, TSMask,RPTParams,clObj32,OmniXML,
  OSFont;

const
  MaxPayeeRanges = 20;

type
  TPayeeRange = record
    FromCode : integer;
    ToCode : integer;
  end;

  TPayeeRangesArray = Array[ 0..MaxPayeeRanges -1] of TPayeeRange;

  TPayeeParameters = class (TRPTParameters)
  protected
    procedure Reset; override;
    procedure ReadFromNode (Value : IXMLNode); override;
    procedure SaveToNode   (Value : IXMLNode); override;
  public
    SummaryReport: Boolean;
    ShowAllCodes: Boolean;
    RangesArray: TPayeeRangesArray;
    WrapColumnText: Boolean;
  end;
 
  TfrmTaxablePaymentsRptDlg = class(TForm)
    pnlAllCodes: TPanel;
    Label3: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    btnPreview: TButton;
    btnFile: TButton;
    pnlAccounts: TPanel;
    Label1: TLabel;
    rbAllCodes: TRadioButton;
    rbSelectedCodes: TRadioButton;
    pnlDates: TPanel;
    DateSelector: TfmeDateSelector;
    pnlOptions: TPanel;
    Label9: TLabel;
    rbDetailed: TRadioButton;
    rbSummarised: TRadioButton;
    pnlSelectedCodes: TPanel;
    Label6: TLabel;
    Label7: TLabel;
    btnPayee: TSpeedButton;
    tgRanges: TtsGrid;
    btnSaveTemplate: TButton;
    btnLoad: TButton;
    btnSave: TBitBtn;
    tsMaskDefs1: TtsMaskDefs;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    chkWrapColumnText: TCheckBox;
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
    procedure btnPayeeClick(Sender: TObject);
    procedure tgRangesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure btnSaveTemplateClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure tgRangesResize(Sender: TObject);
    procedure btnEmailClick(Sender: TObject);
  private
    { Private declarations }
    FDataFrom, FDataTo : integer;
    okPressed : boolean;
    FPressed: integer;
    RemovingMask : boolean;
    FPayeeParameters: TPayeeParameters;
    function CheckOK (Skipdates : Boolean = False) : boolean;
    procedure SetPressed(const Value: integer);
    procedure SetPayeeParameters(const Value: TPayeeParameters);
  public
    { Public declarations }
    CodesArray : TPayeeRangesArray;

    function  Execute : boolean;
    property  Pressed : integer read FPressed write SetPressed;
    property  PayeeParameters: TPayeeParameters read FPayeeParameters write SetPayeeParameters;
  end;

var
  frmTaxablePaymentsRptDlg: TfrmTaxablePaymentsRptDlg;

function GetPRParameters(params : TPayeeParameters) : boolean;

implementation

uses
  PayeeLookupFrm,
  BKHelp,
  SelectDate,
  globals,
  InfoMoreFrm,
  ErrorMoreFrm,
  ImagesFrm,
  bkDateUtils,
  ClDateUtils,
  bkMaskUtils,
  StdHints,
  ReportDefs,
  UBatchbase,
  OmniXMLUtils,
  BKConst, bkXPThemes,
  pysl, payeeobj;
  
{$R *.dfm}

procedure TfrmTaxablePaymentsRptDlg.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  bkXPThemes.ThemeForm( Self);

  fDataFrom := ClDateUtils.BAllData( MyClient );
  fDataTo   := ClDateUtils.EAllData( MyClient );

  removingMask := False;

  DateSelector.ClientObj := MyClient;
  DateSelector.InitDateSelect( fDataFrom, fDataTo, rbDetailed);

  ImagesFrm.AppImages.Coding.GetBitmap(CODING_PAYEE_BMP,btnPayee.Glyph);

  FillChar( CodesArray, SizeOf( TPayeeRangesArray), #0);
  tgRanges.Rows := MaxPayeeRanges;

  //align panels so they occupy the same space
  pnlAllCodes.Left := pnlSelectedCodes.Left;
  pnlAllCodes.Width := pnlSelectedCodes.Width;

  {$IFDEF SmartBooks}
  LastYear1.Visible := false;
  AllData1.Visible  := false;
  {$ENDIF}

  SetUpHelp;

  bkHelpSetup( Self, BKH_Taxable_Payments_Report);

  //favorite reports functionality is disabled in simpleUI
  if Active_UI_Style = UIS_Simple then
     btnSave.Hide;
end;
//------------------------------------------------------------------------------
procedure TfrmTaxablePaymentsRptDlg.SetUpHelp;
begin
   Self.ShowHint    := INI_ShowFormHints;
   Self.HelpContext := 0;
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
procedure TfrmTaxablePaymentsRptDlg.btnCancelClick(Sender: TObject);
begin
  Close;
end;
//------------------------------------------------------------------------------
procedure TfrmTaxablePaymentsRptDlg.btnOKClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_PRINT;
     okPressed := true;
     close;
   end;
end;
//------------------------------------------------------------------------------
function TfrmTaxablePaymentsRptDlg.CheckOK(Skipdates: Boolean): boolean;
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
         exit;
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
       if (CodesArray[i].FromCode <> 0) or ( CodesArray[i].ToCode <> 0) then
       begin
         AtLeastOneRangeEntered := true;
         //make sure that from code < to code
         if ( CodesArray[i].ToCode <> 0) and (CodesArray[i].FromCode > CodesArray[i].ToCode) then
         begin
           HelpfulInfoMsg( 'The range ' + IntToStr( CodesArray[i].FromCode) + ' to ' +
                           IntToStr( CodesArray[i].ToCode) + ' is invalid. '+
                           #13#13'Please select a valid range.', 0);
           tgRanges.SetFocus;
           Exit;
         end;
       end;
     end;

     if not AtLeastOneRangeEntered then
     begin
       HelpfulInfoMsg( 'You must enter at least one payee range.', 0);
       tgRanges.SetFocus;
       exit;
     end;
   end;

   result := true;
end;
//------------------------------------------------------------------------------
procedure TfrmTaxablePaymentsRptDlg.SetPayeeParameters(const Value: TPayeeParameters);
begin
  FPayeeParameters := Value;
  if Assigned(FPayeeParameters) then begin
     FPayeeParameters.SetDlgButtons(BtnPreview,BtnFile,BtnEmail,Btnsave,BtnOk);
     if Assigned(FPayeeParameters.RptBatch) then
        Caption := Caption + ' [' + FPayeeParameters.RptBatch.Name + ']';
  end;
end;

procedure TfrmTaxablePaymentsRptDlg.SetPressed(const Value: integer);
begin
  FPressed := Value;
end;
//------------------------------------------------------------------------------
procedure TfrmTaxablePaymentsRptDlg.btnPreviewClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_PREVIEW;
     okPressed := true;
     close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmTaxablePaymentsRptDlg.btnEmailClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_EMAIL;
     okPressed := true;
     close;
   end;
end;

procedure TfrmTaxablePaymentsRptDlg.btnFileClick(Sender: TObject);
begin
   if checkOK then
   begin
     Pressed  := BTN_FILE;
     okPressed := true;
     close;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TfrmTaxablePaymentsRptDlg.rbSummarisedClick(Sender: TObject);
begin
end;
//------------------------------------------------------------------------------
function TfrmTaxablePaymentsRptDlg.Execute: boolean;
begin
   okPressed := false;
   Pressed := BTN_NONE;

   {display}
   Self.ShowModal;
   result := okPressed;
end;
//------------------------------------------------------------------------------
function GetPRParameters(params : TPayeeParameters) : boolean;
var
  Mydlg : TfrmTaxablePaymentsRptDlg;
  i : integer;
begin
  result := false;
  Mydlg := TfrmTaxablePaymentsRptDlg.Create(Application);
  With Params do try
     RunBtn := BTN_NONE;
     Mydlg.PayeeParameters := Params;
     MyDlg.rbSummarised.Checked := SummaryReport;
     MyDlg.rbDetailed.Checked := not SummaryReport;
     MyDlg.rbAllCodes.Checked := ShowAllCodes;
     MyDlg.rbSelectedCodes.Checked := not ShowAllCodes;
     MyDlg.chkWrapColumnText.Checked := WrapColumnText;

     //populate array
     FillChar( MyDlg.CodesArray, SizeOf( TPayeeRangesArray), #0);
     for i := Low(RangesArray) to High(RangesArray) do
     begin
       MyDlg.CodesArray[i].FromCode := RangesArray[i].FromCode;
       MyDlg.CodesArray[i].ToCode := RangesArray[i].ToCode;
     end;

     if ( Fromdate <> 0) and ( ToDate <> 0) then
     begin
       MyDlg.DateSelector.eDateFrom.AsStDate := FromDate;
       MyDlg.DateSelector.eDateTo.AsStDate := ToDate;
     end
     else
     begin
       {use default date}
       MyDlg.DateSelector.eDateFrom.asStDate := MyClient.clFields.clFinancial_Year_Starts;
       MyDlg.DateSelector.eDateTo.asStDate := GetYearEndDate(MyClient.clFields.clFinancial_Year_Starts);
     end;

     if MyDlg.Execute then
     begin
        FromDate        := StNull2Bk(MyDlg.DateSelector.eDateFrom.AsStDate);
        ToDate          := StNull2Bk(MyDlg.DateSelector.eDateTo.AsStDate);
        SummaryReport   := MyDlg.rbSummarised.Checked;
        ShowAllCodes := MyDlg.rbAllCodes.Checked;
        WrapColumnText := MyDlg.chkWrapColumnText.Checked;

        //populate array
        FillChar( RangesArray, SizeOf( TPayeeRangesArray), #0);
        if not ShowAllCodes then
        for i := Low(RangesArray) to High(RangesArray) do
        begin
          RangesArray[i].FromCode := MyDlg.CodesArray[i].FromCode;
          RangesArray[i].ToCode := MyDlg.CodesArray[i].ToCode;
        end;

        if Todate   = 0 then
          ToDate   := MaxInt;

        RunBtn := MyDlg.Pressed;
        result := true;
     end;
  finally
     MyDlg.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TfrmTaxablePaymentsRptDlg.rbSelectedCodesClick(Sender: TObject);
begin
  pnlSelectedCodes.Visible := true;
  pnlAllCodes.Visible := false;
  if Visible then
    tgRanges.SetFocus; // Enter editing state  
end;

procedure TfrmTaxablePaymentsRptDlg.rbAllCodesClick(Sender: TObject);
begin
  pnlAllCodes.Visible := true;
  pnlSelectedCodes.Visible := false;
end;

procedure TfrmTaxablePaymentsRptDlg.tgRangesCellLoaded(Sender: TObject; DataCol,
  DataRow: Integer; var Value: Variant);
begin
  if DataCol = 1 then
  begin
    Value := IntToStr( CodesArray[ DataRow -1].FromCode);
  end
  else
  begin
    Value := IntToStr( CodesArray[ DataRow -1].ToCode);
  end;

  if Value = '0' then
  begin
    Value := '';
  end;
  
  if (StrToIntDef( Trim( Value), 0) > 0) and
     (not Assigned(MyClient.clPayee_List.Find_Contractor_Payee_Number(StrToIntDef( Trim( Value), 0)))) then
    tgRanges.CellColor[DataCol, DataRow] := clRed
  else
    tgRanges.CellColor[DataCol, DataRow] := clNone;
end;

procedure TfrmTaxablePaymentsRptDlg.tgRangesEndCellEdit(Sender: TObject; DataCol,
  DataRow: Integer; var Cancel: Boolean);
var
  Value : string;
begin
  Value := tgRanges.CurrentCell.Value;

  if DataCol = 1 then
  begin
    CodesArray[ DataRow -1].FromCode := StrToIntDef( Trim( Value), 0);
  end
  else
  begin
    CodesArray[ DataRow -1].ToCode := StrToIntDef( Trim( Value), 0);
  end;

  if (StrToIntDef( Trim( Value), 0) > 0) and
     (not Assigned(MyClient.clPayee_List.Find_Contractor_Payee_Number(StrToIntDef( Trim( Value), 0)))) then
    tgRanges.CellColor[DataCol, DataRow] := clRed
  else
    tgRanges.CellColor[DataCol, DataRow] := clNone;
end;

procedure TfrmTaxablePaymentsRptDlg.btnPayeeClick(Sender: TObject);
var
  Code : integer;
  p: TPayee;
begin
  // If in TO field then automatically select whatever is in the FROM field if TO is blank (#1713)
  Code := StrToIntDef(tgRanges.CurrentCell.Value, 0);
  if (tgRanges.CurrentDataCol = 2) and (Code = 0) then
    Code := CodesArray[tgRanges.CurrentDataRow - 1].FromCode;

  // If code doesn't exist then guess next one
  if (tgRanges.CurrentDataCol = 2) then
  begin
    p := MyClient.clPayee_List.Guess_Next_Contractor_Payee_Number(Code);
    if Assigned(p) then
      Code := p.pdNumber
    else
      Code := 0;
  end;

  if PayeeLookupFrm.PickPayee( Code, pmContractors, [paInactivePayees]) then
  begin
    //if get here then have a code which can be posted to from picklist
    tgRanges.CurrentCell.Value := IntToStr(Code);
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

procedure TfrmTaxablePaymentsRptDlg.tgRangesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 114 then
  begin
    Key := 0;
    btnPayee.Click;
  end;
end;

procedure TfrmTaxablePaymentsRptDlg.tgRangesResize(Sender: TObject);
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

procedure TfrmTaxablePaymentsRptDlg.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
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

procedure TfrmTaxablePaymentsRptDlg.btnSaveTemplateClick(Sender: TObject);
begin
  SaveDialog1.InitialDir := Globals.DataDir;
  if SaveDialog1.Execute then
    tgRanges.SaveToFile(SaveDialog1.FileName, True);
end;

procedure TfrmTaxablePaymentsRptDlg.btnSaveClick(Sender: TObject);
begin
   if checkOK (True) then
   begin
     if not FPayeeParameters.CheckForBatch then
         Exit;
     Pressed  := BTN_SAVE;
     okPressed := true;
     close;
   end;
end;

procedure TfrmTaxablePaymentsRptDlg.btnLoadClick(Sender: TObject);
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
      HelpfulErrorMsg('The selected file is not a valid Payee Report Template file', 0);
      exit;
     end;
    end;
    for i := 1 to tgRanges.Rows do
    begin
      CodesArray[i-1].FromCode := StrToIntDef( Trim( tgRanges.Cell[1, i]), 0);
      CodesArray[i-1].ToCode := StrToIntDef( Trim( tgRanges.Cell[2, i]), 0);
    end;
    tgRanges.OnCellLoaded := tgRangesCellLoaded;
  end;
end;

{ TPayeeParameters }

const
  t_PayeeList = 'Payees';

procedure TPayeeParameters.ReadFromNode(Value: IXMLNode);
var s : string;
  function NoCodes : Boolean;
  var NN : IXMLNode;
      LList : IXMLNodeList;
      I : Integer;
  begin
     Result := True;
     NN := FindNode(Value,t_PayeeList);
     if not assigned(NN) then exit;
     LList := FilterNodes(NN,'Code');
     if not assigned(LList) then exit;
     if LList.Length = 0 then exit;
     for I := 0 to LList.Length - 1 do begin
         if I > High(RangesArray) then exit;
         // Found at least one..
         Result := False;
         RangesArray[i].FromCode := GetNodeTextInt(LList.Item[I],'From',0);
         RangesArray[i].ToCode   := GetNodeTextInt(LList.Item[I],'To',0)
     end;
  end;



begin
  inherited;
   SummaryReport := GetNodeBool(Value,'Summarised',False);
   WrapColumnText := GetNodeBool(Value,'Wrap_Column_Text',True);
   ShowAllCodes  :=  NoCodes;
end;

procedure TPayeeParameters.Reset;
begin
  inherited;
  FillChar( RangesArray, SizeOf( RangesArray), #0);
  ShowAllCodes := True;
end;


procedure TPayeeParameters.SaveToNode(Value: IXMLNode);

  function NoCodes : Boolean;
  var
    NN, AN : IXMLNode;
    I : Integer;
  begin
     Result := True;

     NN := nil;
     AN := nil;

     for I := Low(rangesArray) to High(RangesArray) do
     begin
       if (RangesArray[i].FromCode <> 0) or (RangesArray[i].ToCode <> 0) then
       begin
         // Got one..
         if Result  then
         begin
           Result := False;
           AN := EnsureNode(Value,t_PayeeList);
           AN.Text := '';
         end;

         NN := AppendNode(AN,'Code');
         SetNodeTextInt(NN,'From',RangesArray[i].FromCode);
         SetNodeTextInt(NN,'To',RangesArray[i].ToCode)
       end;
     end;
  end;
  
begin
  if SummaryReport then
  begin
    rptBatch.Title := Report_List_Names[Report_Taxable_Payments];
  end
  else
  begin
    rptBatch.Title := Report_List_Names[Report_Taxable_Payments_Detailed];
  end;

  inherited;

  SetNodeBool(Value,'Summarised',SummaryReport);
  SetNodeBool(Value,'Wrap_Column_Text',WrapColumnText);

  if NoCodes then
  begin
    ClearSetting(Value,t_PayeeList);
  end;
end;
end.
