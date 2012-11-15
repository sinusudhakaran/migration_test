// Print the CAF in a form as close as possible to the PDF
unit rptCAF;

//------------------------------------------------------------------------------
interface

uses
   XLSFile,
   XLSWorkbook,
   Variants,
   AuthorityUtils,
   CAFfrm,
   ReportDefs,
   Windows;

type
  TCAFReport = class(TAuthorityReport)
  private
    FValues: TfrmCAF; // pass the form so if text changes we may not have to change the report
  protected
    procedure PrintForm; override;
    procedure ResetForm; override;
    procedure FillCollumn(C: TCell); override;
    function HaveNewdata: Boolean; override;
  public
    property Values : TfrmCAF read FVAlues write FValues;
    procedure BKPrint;  override;
    procedure CreateQRCode(aDestRect : TRect);
  end;

function DoCAFReport(Values: TfrmCAF; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  ReportTypes,
  Globals,
  MailFrm,
  bkConst,
  Graphics,
  Types,
  RepCols,
  UserReportSettings,
  BKPrintJob,
  Printers,
  CafQrCode,
  ExtCtrls,
  Sysutils,
  webutils;

//------------------------------------------------------------------------------
function DoCAFReport(Values: TfrmCAF; Destination : TReportDest;  Mode: TAFMode; Addr: string = '') : Boolean;
var
   Job : TCAFReport;
   AttachmentSent, AskOpen: Boolean;
begin
   Result := False;
   Job := TCAFReport.Create(ReportTypes.rptOther);
   try
      Job.Values := Values;
      Job.Country := whAustralia;
      Job.WasPrinted := False;
      Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_CAF]);
      Job.FileFormats := [ffPDF];

      // Check if we have anything to do..
      if Mode =  AFImport then
         if not Job.ImportFile(Values.ImportFile,False) then
            Exit;

      Job.ImportMode := False;
      AskOpen := True;
      case Mode of
         AFEmail: begin
               Job.FileDest := rfPDF;
               AskOpen := False;
            end;
         AFImport: begin
               Job.ImportMode := True;
            end;
      end;

      if Destination in [rdScreen, rdPrinter, rdFile] then
         Job.Generate(Destination, nil, True, AskOpen);

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

//------------------------------------------------------------------------------
procedure TCAFReport.BKPrint;
begin
  if ImportMode then
     ImportFile(Values.ImportFile,True)
  else
     PrintForm;
end;

//------------------------------------------------------------------------------
procedure TCAFReport.CreateQRCode(aDestRect : TRect);
var
  CafQrCode  : TCafQrCode;
  CAFQRData  : TCAFQRData;
  CAFQRDataAccount : TCAFQRDataAccount;
  QrCodeImage : TImage;
begin
  CAFQRData := TCAFQRData.Create(TCAFQRDataAccount);
  try
    CafQrCode := TCafQrCode.Create;
    try
      QrCodeImage := TImage.Create(nil);
      try
        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName1.text;
        CAFQRDataAccount.AccountNumber := Values.edtBSB1.Text +
                                          Values.edtNumber1.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient1.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost1.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName2.text;
        CAFQRDataAccount.AccountNumber := Values.edtBSB2.Text +
                                          Values.edtNumber2.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient2.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost2.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName3.text;
        CAFQRDataAccount.AccountNumber := Values.edtBSB3.Text +
                                          Values.edtNumber3.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient3.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost3.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        // Day , Month , Year
        CAFQRData.SetStartDate(1,
                               Values.cmbMonth.ItemIndex,
                               '20' + Values.edtYear.Text);

        CAFQRData.PracticeCode        := Values.edtPractice.text;
        CAFQRData.PracticeCountryCode := CountryText(AdminSystem.fdFields.fdCountry);

        CAFQRData.SetProvisional(Values.cbProvisional.Checked);

        CAFQRData.SetFrequency(Values.rbMonthly.Checked,
                               Values.rbWeekly.Checked,
                               Values.rbDaily.Checked,
                               0);

        CAFQRData.TimeStamp := Now;
        CAFQRData.InstitutionCode := Values.edtBank.Text;
        CAFQRData.InstitutionCountry := '';

        CafQrCode.BuildQRCode(CAFQRData,
                              GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CAF_QRCODE,
                              QrCodeImage);

        DrawImage(aDestRect, QrCodeImage);

      finally
        FreeAndNil(QrCodeImage);
      end;
    finally
      FreeAndNil(CafQrCode);
    end;
  finally
    FreeAndNil(CAFQRData);
  end;
end;

//------------------------------------------------------------------------------
procedure TCAFReport.PrintForm;
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
   RenderSplitText(Values.lblAddress.Caption, Col2 - BoxMargin*3);
   //*** Account info
   myCanvas.Font.Size := 7;
   myCanvas.Font.Style := [];
   CurrLineSize := 40;
   DrawLine;
   NewLine;
   PrintAccount(Values.edtName1.Text, Values.edtBSB1.Text, Values.edtNumber1.Text, Values.edtClient1.Text, Values.edtCost1.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+470+BoxMargin, True);
   NewLine;
   PrintAccount(Values.edtName2.Text, Values.edtBSB2.Text, Values.edtNumber2.Text, Values.edtClient2.Text, Values.edtCost2.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+470+BoxMargin, True);
   NewLine;
   PrintAccount(Values.edtName3.Text, Values.edtBSB3.Text, Values.edtNumber3.Text, Values.edtClient3.Text, Values.edtCost3.Text,
    Values.lblAcName.Caption, Values.lblAcNum.Caption, Values.lblClient.Caption, Values.lblCost.Caption, Col1+470+BoxMargin, True);
   //*** Form name
   myCanvas.Font.Size := 14;
   myCanvas.Font.Style := [];
   CurrLineSize := GetCurrLineSize;
   RenderText(Values.lblForm.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   DrawBox(XYSizeRect(Col0 - BoxMargin, RowStart - BoxMargin, ColBoxRight + BoxMargin, CurrYPos + BoxMargin));
   //*** Bank info
   myCanvas.Font.Size := 7;
   myCanvas.Font.Style := [];
   CurrLineSize := GetCurrLineSizeNoInflation;
   NewLine;
   RenderText(Values.lblTo.Caption, Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   RenderText(Values.lblManager.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   RenderText(Values.lblTheGeneralManager.Caption, Rect(Col2+75, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.edtBank.Text, Rect(Col1+BoxMargin, CurrYPos+BoxMargin, 1250, CurrYPos+CurrLineSize+(BoxMargin*2)), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;
   // manager box
   DrawBox(XYSizeRect(Col1, CurrYPos, 1250, CurrYPos + BoxHeight));
   RenderSplitText(Values.lblBankLink.Caption, Col2 + 75);
   NewLine;
   RenderText(Values.lblPos.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine;
   RenderText(Values.lblPos1.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   NewLine(3);
   //*** Clauses and space for signatures
   i := CurrYPos - CurrLineSize;
   RenderSplitText(Values.lblClause1.Caption, Col0);
   CurrYPos := CurrYPos - CurrLineSize*2 - BoxMargin;
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.cmbMonth.Text, Rect(Col2 - 250, i, Col2 + 500, CurrYPos), jtLeft);
   RenderText(Values.edtYear.Text, Rect(Col2+15, i, Col2 + 105, CurrYPos), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;
   CurrYPos := CurrYPos + 61;
   // month box
   DrawBox(XYSizeRect(Col2 - 255, CurrYPos-CurrLineSize*4, Col2 - 75, CurrYPos + BoxHeight - CurrLineSize*4));
   // year box
   DrawBox(XYSizeRect(Col2 + 5, CurrYPos-CurrLineSize*4, Col2 + 95, CurrYPos + BoxHeight - CurrLineSize*4));
   NewLine;
   // advisors box
   DrawBox(XYSizeRect(Col1, CurrYPos, 1250, CurrYPos + BoxHeight));
   // practice box
   DrawBox(XYSizeRect(Col2 + 5, CurrYPos, Col2 + 405, CurrYPos + BoxHeight));
   myCanvas.Font.Size := myCanvas.Font.Size + 1;
   RenderText(Values.edtAdvisors.Text, Rect(Col1+BoxMargin, CurrYPos+BoxMargin, 1250, CurrYPos+CurrLineSize+(BoxMargin*2)), jtLeft);
   RenderText(Values.edtPractice.Text, Rect(Col2 + 15, CurrYPos+BoxMargin, Col2 + 400, CurrYPos+CurrLineSize + BoxMargin), jtLeft);
   myCanvas.Font.Size := myCanvas.Font.Size - 1;
   NewLine(3);
   RenderText(Values.lblPos2.Caption, Rect(Col1, CurrYPos, Col1 + 990, CurrYPos+CurrLineSize), jtLeft);
   RenderText(Values.lblPracticeCode.Caption, Rect(Col2 + 5, CurrYPos, Col2 + 400, CurrYPos+CurrLineSize), jtLeft);
   NewLine(2);
   RenderSplitText(Values.lblClause2.Caption, Col0);
   NewLine;
   RenderSplitText(Values.lblClause3.Caption, Col0);
   NewLine;
   RenderSplitText(Values.lblClause45.Caption, Col0);
   NewLine(2);

   CreateQRCode(XYSizeRect(ColBoxRight-240, CurrYPos-155, ColBoxRight+10, CurrYPos+95));

   RenderSplitText(Values.lblSign.Caption, Col0, True);
   CurrYPos := CurrYPos + CurrLineSize + BoxMargin;
   //Additional information to assist BankLink
   DrawBox(XYSizeRect(Col0 - BoxMargin, CurrYPos - BoxMargin, ColBoxRight + BoxMargin, CurrYPos + 150));
   NewLine;
   myCanvas.Font.Style := [fsbold];
   RenderText(Values.lblAdditionalInfo.Caption, Rect(Col1, CurrYPos - CurrLineSize, Col1 + 600, CurrYPos), jtLeft);
   //Provisional
   CurrYPos := CurrYPos + 20;
   myCanvas.Font.Style := (myCanvas.Font.Style - [fsbold]);
   DrawCheckbox(Col1, CurrYPos, Values.cbProvisional.Checked);
   RenderText(Values.cbProvisional.Caption, Rect(Col1 + CurrLineSize + 10, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
   CurrYPos := CurrYPos + 20;
   NewLine;
   //Frequency
   DrawRadio(MyCanvas, XYSizeRect(Col1 + 300, CurrYPos, Col1 + 700, CurrYPos+CurrLineSize), ' ' + Values.rbMonthly.Caption, True, Values.rbMonthly.Checked);
   DrawRadio(MyCanvas, XYSizeRect(Col1 + 700, CurrYPos, Col1 + 1300, CurrYPos+CurrLineSize), ' ' + Values.rbWeekly.Caption, True, Values.rbWeekly.Checked);
   DrawRadio(MyCanvas, XYSizeRect(Col1 + 1300, CurrYPos, Col1 + 1800, CurrYPos+CurrLineSize), ' ' + Values.rbDaily.Caption, True, Values.rbDaily.Checked);
   RenderText(Values.lblServiceFrequency.Caption, Rect(Col1, CurrYPos, Col1 + 250, CurrYPos + CurrLineSize), jtLeft);
   NewLine(5);

   WasPrinted := True;
end;

//------------------------------------------------------------------------------
procedure TCAFReport.ResetForm;
begin
   Values.btnClearClick(nil);
end;

//------------------------------------------------------------------------------
procedure TCAFReport.FillCollumn(C: TCell);
begin
   if C.Col = fcAccountName then
      Values.edtName1.Text := GetCellText(C)
   else if C.Col = fcBSB then
      Values.edtBSB1.Text := GetCellText(C)
   else if C.Col = fcAccountNo then
      Values.edtNumber1.Text := GetCellText(C)
   else if C.Col = fcCostCode then
      Values.edtCost1.Text := GetCellText(C)
   else if C.Col = fcClientCode then
      Values.edtClient1. Text := GetCellText(C)
   else if C.Col = fcBank then
      Values.edtBank.Text := GetCellText(C)
   else if C.Col = fcMonth then begin
      Values.cmbMonth.ItemIndex :=
        Values.cmbMonth.Items.IndexOf(GetCellText(C))
   end else if C.Col = fcYear then begin
      Values.edtYear.Text := GetCellText(C)
   end else if C.Col = fcFrequency then begin
      Values.rbMonthly.Checked := (GetCellText(C) = 'M');
      Values.rbWeekly.Checked  := (GetCellText(C) = 'W');
      Values.rbDaily.Checked   := (GetCellText(C) = 'D');
   end else if C.Col = fcProvisional then begin
      Values.cbProvisional.Checked := True;
      if (GetCellText(C) = 'N') then
        Values.cbProvisional.Checked := False;
   end;
end;

//------------------------------------------------------------------------------
function TCAFReport.HaveNewdata: Boolean;
begin
   Result := (Values.edtName1.Text > '')
          or (Values.edtBSB1.Text > '')
          or (Values.edtNumber1.Text > '')
          or (Values.edtName2.Text > '')
          or (Values.edtBSB2.Text > '')
          or (Values.edtNumber2.Text > '')
          or (Values.edtName3.Text > '')
          or (Values.edtBSB3.Text > '')
          or (Values.edtNumber3.Text > '');
   if not Result then
      ResetForm; // Clear the rest..
end;

end.
