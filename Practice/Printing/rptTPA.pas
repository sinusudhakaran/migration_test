// Print the TPA in a form as close as possible to the PDF
unit rptTPA;

//------------------------------------------------------------------------------
interface

uses
   XLSFile,
   XLSWorkbook,
   Variants,
   AuthorityUtils,
   TPAfrm,
   ReportDefs,
   windows,
   Graphics;

type
  TTPAReport = class(TAuthorityReport)
  private
    FValues: TfrmTPA; // pass the form so if text changes we may not have to change the report
  protected
    procedure PrintForm; override;
    procedure ResetForm; override;
    procedure FillCollumn(C: TCell); override;
    function HaveNewdata: Boolean; override;
    procedure CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);
  public
    procedure BKPrint;  override;
    property Values : TfrmTPA read FVAlues write FValues;
  end;

function DoTPAReport(Values: TfrmTPA; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  ReportTypes,
  Globals,
  MailFrm,
  bkConst,
  Types,
  RepCols,
  UserReportSettings,
  {$IFNDEF PRACTICE-7}
  CafQrCode,
  {$ENDIF}
  ExtCtrls,
  Sysutils,
  webutils,
  InstitutionCol,
  StrUtils;

//------------------------------------------------------------------------------
function DoTPAReport(Values: TfrmTPA; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;
var
   Job : TTPAReport;
   AttachmentSent, AskOpen: Boolean;
begin
   Result := False;
   {Job := TTPAReport.Create(ReportTypes.rptOther);
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

         MailFrm.SendFileTo( 'Send Third Party Authority Form', Addr, '', Job.ReportFile, AttachmentSent, False, True);
         DeleteFile(PAnsiChar(Job.ReportFile));
      end;
   finally
      Job.Free;
   end;   }
end;

//------------------------------------------------------------------------------
procedure TTPAReport.BKPrint;
begin
  {if ImportMode then
     ImportFile(Values.ImportFile,True)
  else
     PrintForm;}
end;

//------------------------------------------------------------------------------
procedure TTPAReport.FillCollumn(C: TCell);
begin
  {if C.Col = fcAccountName then
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
  else if C.Col = fcFrequency then
  begin
    Values.rbMonthly.Checked := (GetCellText(C) = 'M');
    Values.rbWeekly.Checked  := (GetCellText(C) = 'W');
    Values.rbDaily.Checked   := (GetCellText(C) = 'D');
  end
  else if C.Col = fcProvisional then
  begin
    Values.cbProvisional.Checked := True;
    if (GetCellText(C) = 'N') then
      Values.cbProvisional.Checked := False;
  end;}
end;

//------------------------------------------------------------------------------
function TTPAReport.HaveNewdata: Boolean;
begin
  {Result := (Values.edtName1.Text > '')
         or (Values.edtNumber1.Text > '')
         or (Values.edtName2.Text > '')
         or (Values.edtNumber2.Text > '')
         or (Values.edtName3.Text > '')
         or (Values.edtNumber3.Text > '');

  if not Result then
     ResetForm; // Clear the rest}
end;

//------------------------------------------------------------------------------
procedure TTPAReport.PrintForm;
var
  myCanvas : TCanvas;
  i : integer;
  BankText : string;
begin
  {assume we have a canvas of A4 proportions as per GST forms}
  {myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;
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

  if Values.cmbInstitutionName.itemindex = 0 then
    BankText := Values.edtInstitutionName.text + '   ' + Values.edtBank.Text
  else
    BankText := Values.cmbInstitutionName.text + '   ' + Values.edtBank.Text;

  RenderText(BankText, Rect(Col0+BoxMargin, CurrYPos+BoxMargin, 1100, CurrYPos+CurrLineSize+(BoxMargin*2)), jtLeft);

  myCanvas.Font.Size := myCanvas.Font.Size - 1;
  DrawBox(XYSizeRect(Col0, CurrYPos, 1100, CurrYPos + BoxHeight));
  NewLine(3);
  RenderText('(Bank and Branch Name)', Rect(Col0, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
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

  CreateQRCode(MyCanvas, XYSizeRect(ColBoxRight-250, CurrYPos-250, ColBoxRight, CurrYPos));

  //Name - keep same y pos for signature
  i := CurrYPos;
  RenderSplitText(Values.lblName.Caption, Col0, True);
  CurrYPos := i;
  //Signature
  RenderSplitText(Values.lblSign.Caption, Col1 + 720, True);
  NewLine;
  DrawBox(XYSizeRect(Col0 - BoxMargin, CurrYPos, ColBoxRight + BoxMargin, CurrYPos + CurrLineSize*8));
  NewLine;
  myCanvas.Font.Style := [fsBold];
  CurrYPos := CurrYPos - 10;
  RenderText(Values.lblAdditional.Caption, Rect(Col1, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
  NewLine;
  //Provisional
  CurrYPos := CurrYPos + 20;
  myCanvas.Font.Style := [];
  DrawCheckbox(Col1, CurrYPos, Values.cbProvisional.Checked);
  RenderText(Values.cbProvisional.Caption, Rect(Col1 + CurrLineSize + 10, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize), jtLeft);
  NewLine(2);
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
  WasPrinted := True;}
end;

//------------------------------------------------------------------------------
procedure TTPAReport.ResetForm;
begin
  //Values.btnClearClick(nil);
end;

//------------------------------------------------------------------------------
procedure TTPAReport.CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);
{$IFNDEF PRACTICE-7}
var
  CafQrCode  : TCafQrCode;
  CAFQRData  : TCAFQRData;
  CAFQRDataAccount : TCAFQRDataAccount;
  QrCodeImage : TImage;
  InstIndex : integer;
  InstCode : string;
  InstSlashPos : integer;
  IsRuralInstSelected : boolean;
{$ENDIF}
begin
  // don't draw QRCode if institution is set to other or not set
  {if Values.cmbInstitutionName.ItemIndex < 1 then
    Exit;}
{$IFNDEF PRACTICE-7}
  {CAFQRData := TCAFQRData.Create(TCAFQRDataAccount);
  try
    CafQrCode := TCafQrCode.Create;
    try
      QrCodeImage := TImage.Create(nil);
      try
        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName1.text;
        CAFQRDataAccount.AccountNumber := Values.edtNumber1.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient1.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost1.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName2.text;
        CAFQRDataAccount.AccountNumber := Values.edtNumber2.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient2.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost2.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtName3.text;
        CAFQRDataAccount.AccountNumber := Values.edtNumber3.text;
        CAFQRDataAccount.ClientCode    := Values.edtClient3.Text;
        CAFQRDataAccount.CostCode      := Values.edtCost3.Text;
        CAFQRDataAccount.SMSF          := 'N'; // AU only

        // Day , Month , Year
        CAFQRData.SetStartDate(Values.cmbDay.ItemIndex,
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

        // Institution Code and Country
        InstIndex := Values.cmbInstitutionName.ItemIndex;

        InstCode := TInstitutionItem(Values.cmbInstitutionName.Items.Objects[InstIndex]).Code;
        InstSlashPos := Pos('/',InstCode);

        if (InstSlashPos > 0) and (Values.rbDate.Checked) then
          CAFQRData.InstitutionCode := RightStr(InstCode, (length(InstCode) - InstSlashPos))
        else if (InstSlashPos > 0) then
          CAFQRData.InstitutionCode := LeftStr(InstCode, InstSlashPos - 1)
        else
          CAFQRData.InstitutionCode := InstCode;

        CAFQRData.InstitutionCountry := TInstitutionItem(Values.cmbInstitutionName.Items.Objects[InstIndex]).CountryCode;

        CafQrCode.BuildQRCode(CAFQRData,
                              GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CAF_QRCODE,
                              QrCodeImage);

        aCanvas.StretchDraw(aDestRect, QrCodeImage.Picture.Graphic);
        if OriginalDestination = rdPrinter then
          aCanvas.StretchDraw(aDestRect, QrCodeImage.Picture.Graphic);

      finally
        FreeAndNil(QrCodeImage);
      end;
    finally
      FreeAndNil(CafQrCode);
    end;
  finally
    FreeAndNil(CAFQRData);
  end; }
  {$ENDIF}
end;

end.
