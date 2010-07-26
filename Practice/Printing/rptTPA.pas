// Print the TPA in a form as close as possible to the PDF
unit rptTPA;

interface

uses
   XLSFile,
   XLSWorkbook,
   Variants,
   AuthorityUtils,
   TPAfrm,
   ReportDefs;

type
  TTPAReport = class(TAuthorityReport)
  private
    FValues: TfrmTPA; // pass the form so if text changes we may not have to change the report
  protected
    procedure PrintForm; override;
    procedure ResetForm; override;
    procedure FillCollumn(C: TCell); override;
    function HaveNewdata: Boolean; override;
  public
    procedure BKPrint;  override;
    property Values : TfrmTPA read FVAlues write FValues;
  end;

function DoTPAReport(Values: TfrmTPA; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;

implementation

uses
   ReportTypes,
   Windows, Globals, MailFrm, bkConst, Graphics, Types, RepCols, UserReportSettings;

function DoTPAReport(Values: TfrmTPA; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;
var
   Job : TTPAReport;
   AttachmentSent, AskOpen: Boolean;
begin
   Result := False;
   Job := TTPAReport.Create(ReportTypes.rptOther);
   try
      Job.Values := Values;
      Job.Country := whNewZealand;
      Job.WasPrinted := False;
      Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_TPA]);
      Job.FileFormats := [ffPDF];

      // Check if we have anything to do..
      if Mode =  AFImport then
         if not Job.ImportFile(Values.ImportFile,False) then
            Exit;

      Job.ImportMode := False;
      AskOpen := True;
      case Mode of
         AFEmail: begin
               Job.FileDest := rfPDF; //Dont ask for Destination
               AskOpen := False;      //Dont ask to look at it
            end;
         AFImport: begin
               Job.ImportMode := True;
            end;
      end;

      if Destination in [rdScreen, rdPrinter, rdFile] then
         Job.Generate( Destination, nil, True, AskOpen);

      Result := Job.WasPrinted;

      if Result
      and (Mode = AFEmail) then begin
         MailFrm.SendFileTo( 'Send Client Authority Form', Addr, '', Job.ReportFile, AttachmentSent, False, True);
         DeleteFile(PAnsiChar(Job.ReportFile));
      end;
   finally
      Job.Free;
   end;
end;

procedure TTPAReport.BKPrint;
begin
  if ImportMode then
     ImportFile(Values.ImportFile,True)
  else
     PrintForm;
end;


procedure TTPAReport.FillCollumn(C: TCell);
begin
    if C.Col = fcAccountName then
      Values.edtName1.Text := GetCellText(C)
   else if C.Col = fcAccountNo then
      Values.edtNumber1.Text := GetCellText(C)
   else if C.Col = fcCostCode then
      Values.edtCost1.Text := GetCellText(C)
   else if C.Col = fcClientCode then
      Values.edtClient1. Text := GetCellText(C)
   else if C.Col = fcBank then
      Values.edtBank.Text := GetCellText(C)
   else if C.Col = fcMonth then
      Values.cmbMonth.ItemIndex :=
        Values.cmbMonth.Items.IndexOf(GetCellText(C))
   else if C.Col = fcYear then
      Values.edtYear.Text := GetCellText(C)
   else if C.Col = fcDay then
      Values.cmbDay.ItemIndex := Values.cmbDay.Items.IndexOf(GetCellText(C))
   else if C.Col = fcFrequency then begin
      Values.rbMonthly.Checked := (GetCellText(C) = 'M');
      Values.rbWeekly.Checked  := (GetCellText(C) = 'W');
      Values.rbDaily.Checked   := (GetCellText(C) = 'D');
   end;

end;

function TTPAReport.HaveNewdata: Boolean;
begin
   Result := (Values.edtName1.Text > '')
          or (Values.edtNumber1.Text > '')
          or (Values.edtName2.Text > '')
          or (Values.edtNumber2.Text > '')
          or (Values.edtName3.Text > '')
          or (Values.edtNumber3.Text > '');

   if not Result then
      ResetForm; // Clear the rest
end;

procedure TTPAReport.PrintForm;
var
   myCanvas : TCanvas;
   i : integer;
begin
   {assume we have a canvas of A4 proportions as per GST forms}
   myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
   //*** Form heading
   myCanvas.Font.Size := 18;
   myCanvas.Font.Style := [fsbold];
   myCanvas.Font.Name := 'Bookman Old Style';
   UserReportSettings.s7Orientation := BK_PORTRAIT;
   CurrLineSize := GetCurrLineSize;
   CurrYPos := RowStart - BoxMargin;
   RenderText(Values.lblTitle.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   myCanvas.Font.Size := 7;
   myCanvas.Font.Style := [];
   CurrLineSize := GetCurrLineSizeNoInflation;
   RenderText(Values.lblSubtitle.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   //*** Send To Address
   CurrYPos := 100;
   myCanvas.Font.Size := 10;
   myCanvas.Font.Style := [fsBold];
   CurrLineSize := GetCurrLineSizeNoInflation;
   RenderSplitText(Values.lblAddress.Caption, Col2 - 165);
   //*** Account info
   myCanvas.Font.Size := 7;
   myCanvas.Font.Style := [];
//   CurrLineSize := GetCurrLineSize;
   CurrLineSize := 40;
   DrawLine;
   NewLine;
   PrintAccount(Values.edtName1.Text, '', Values.edtNumber1.Text, Values.edtClient1.Text, Values.edtCost1.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+200+BoxMargin);
   NewLine;
   PrintAccount(Values.edtName2.Text, '', Values.edtNumber2.Text, Values.edtClient2.Text, Values.edtCost2.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+200+BoxMargin);
   NewLine;
   PrintAccount(Values.edtName3.Text, '', Values.edtNumber3.Text, Values.edtClient3.Text, Values.edtCost3.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+200+BoxMargin);   
   //*** Form name
   myCanvas.Font.Size := 14;
   myCanvas.Font.Style := [];
   CurrLineSize := GetCurrLineSize;
   RenderText(Values.lblForm.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   //*** Bank info
   NewLine;
   DrawBox(XYSizeRect(Col0 - BoxMargin, RowStart - BoxMargin, ColBoxRight + BoxMargin, CurrYPos + BoxMargin));
   NewLine;
   myCanvas.Font.Size := 7;
   myCanvas.Font.Style := [];
   CurrLineSize := GetCurrLineSizeNoInflation;
   RenderText(Values.lblTo.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.edtBank.Text, Rect(Col0+BoxMargin, CurrYPos+BoxMargin, 1100, CurrYPos+CurrLineSize+(BoxMargin*2)), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;   
   DrawBox(XYSizeRect(Col0, CurrYPos, 1100, CurrYPos + BoxHeight));
   NewLine(3);
   RenderText(Values.lblPos.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine(2);
   RenderSplitText(Values.lblPos1.Caption, Col0);
   NewLine(2);
   //*** Clauses and space for signatures
   i := CurrYPos - CurrLineSize*3;
   RenderSplitText(Values.lblClause1.Caption, Col0);
   CurrYPos := CurrYPos - CurrLineSize*2 - BoxMargin;
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.cmbDay.Text, Rect(Col1 + 120, i, Col1 + 160, CurrYPos-CurrLineSize), jtLeft);
   RenderText(Values.cmbMonth.Text, Rect(Col1 + 300, i, Col1 + 480, CurrYPos-CurrLineSize), jtLeft);
   RenderText(Values.edtYear.Text, Rect(Col1 + 560, i, Col1 + 600, CurrYPos-CurrLineSize), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;
   CurrYPos := CurrYPos + CurrLineSize*2 + BoxMargin;
   i := CurrYPos-CurrLineSize*5-Round(CurrLineSize/2);
   // day box
   DrawBox(XYSizeRect(Col1 + 110,i, Col1 + 185, i + BoxHeight));
   // month box
   DrawBox(XYSizeRect(Col1 + 290, i, Col1 + 490, i + BoxHeight));
   // year box
   DrawBox(XYSizeRect(Col1 + 545, i, Col1 + 605, i + BoxHeight));
   // advisors box
   DrawBox(XYSizeRect(Col0, CurrYPos, Col1 + 900, CurrYPos + BoxHeight));
   // practice box
   DrawBox(XYSizeRect(Col2 - 190, CurrYPos, ColBoxRight - 390, CurrYPos + BoxHeight));
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.edtAdvisors.Text, Rect(Col0+BoxMargin, CurrYPos+BoxMargin, 1015, CurrYPos+CurrLineSize+(BoxMargin*2)), jtLeft);
   RenderText(Values.edtPractice.Text, Rect(Col2 - 185, CurrYPos+BoxMargin, Col2+BoxMargin+100, CurrYPos+CurrLineSize + BoxMargin), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;
   NewLine(3);
   RenderText(Values.lblPos2.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   RenderText(Values.lblPracticeCode.Caption, Rect(Col2 - 190, CurrYPos, Col2 + 100, CurrYPos+CurrLineSize), jtLeft);
   NewLine(2);
   RenderSplitText(Values.lblClause2.Caption, Col0);
   NewLine(2);
   //Date
   RenderSplitText(Values.lblDate.Caption, Col0, True);
   NewLine(4);
   //Name - keep same y pos for signature
   i := CurrYPos;
   RenderSplitText(Values.lblName.Caption, Col0, True);
   CurrYPos := i;
   //Signature
   RenderSplitText(Values.lblSign.Caption, Col1 + 720, True);
   NewLine(2);
   DrawBox(XYSizeRect(Col0 - BoxMargin, CurrYPos, ColBoxRight + BoxMargin, CurrYPos + CurrLineSize*7));
   NewLine;
   myCanvas.Font.Style := [fsBold];
   RenderText(Values.lblAdditional.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine(2);
   myCanvas.Font.Style := [];
   //Frequency
   RenderText(Values.lblMonthly.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   DrawRadio(myCanvas, XYSizeRect(Col1 + 400, CurrYPos, Col1 + 800, CurrYPos+CurrLineSize), ' ' + Values.rbMonthly.Caption, True, Values.rbMonthly.Checked);
   DrawRadio(myCanvas, XYSizeRect(Col1 + 800, CurrYPos, Col1 + 1400, CurrYPos+CurrLineSize), ' ' + Values.rbWeekly.Caption, True, Values.rbWeekly.Checked);
   DrawRadio(myCanvas, XYSizeRect(Col1 + 1400, CurrYPos, Col1 + 1800, CurrYPos+CurrLineSize), ' ' + Values.rbDaily.Caption, True, Values.rbDaily.Checked);
   NewLine(2);
   //Rural Inst
   RenderText(Values.lblRural.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   DrawRadio(myCanvas, XYSizeRect(Col1 + 400, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), ' ' + Values.rbReDate.Caption, True, Values.rbReDate.Checked);
   DrawRadio(myCanvas, XYSizeRect(Col2, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), ' ' + Values.rbDate.Caption, True, Values.rbDate.Checked);
   WasPrinted := True;   
end;

procedure TTPAReport.ResetForm;
begin
   Values.btnClearClick(nil);
end;

end.
