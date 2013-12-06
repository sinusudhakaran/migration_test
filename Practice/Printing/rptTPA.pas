// Print the TPA in a form as close as possible to the PDF
//------------------------------------------------------------------------------
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
  Graphics,
  ReportTypes;

type
  TTPAReport = class(TAuthorityReport)
  private
    // pass the form so if text changes we may not have to change the report
    FValues   : TfrmTPA;
    TempDay   : string;
    TempMonth : string;
    TempYear  : string;
  protected
    procedure PrintForm; override;
    procedure ResetForm; override;
    procedure FillCollumn(C: TCell); override;
    function HaveNewdata: Boolean; override;
    procedure CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);
  public
    constructor Create(RptType: TReportType); Override;

    procedure BKPrint;  override;
    property Values : TfrmTPA read FVAlues write FValues;
  end;

//------------------------------------------------------------------------------
function DoTPAReport(Values: TfrmTPA; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;

//------------------------------------------------------------------------------
implementation

uses
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
  Job := TTPAReport.Create(ReportTypes.rptOther);
  try
    Job.Values     := Values;
    Job.Country    := whNewZealand;
    Job.WasPrinted := False;
    Job.LoadReportSettings(UserPrintSettings, Report_List_Names[Report_TPA]);
    Job.FileFormats := [ffPDF];

    // Check if we have anything to do..
    if Mode = AFImport then
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

    if Result and
      (Mode = AFEmail) then
    begin
      MailFrm.SendFileTo( 'Send Third Party Authority Form', Addr, '', Job.ReportFile, AttachmentSent, False, True);
      DeleteFile(PAnsiChar(Job.ReportFile));
    end;
  finally
    Job.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TTPAReport.Create(RptType: TReportType);
begin
  inherited create(RptType);

  TempDay   := '';
  TempMonth := '';
  TempYear  := '';
end;

//------------------------------------------------------------------------------
procedure TTPAReport.BKPrint;
begin
  if ImportMode then
    ImportFile(Values.ImportFile,True)
  else
    PrintForm;
end;

//------------------------------------------------------------------------------
procedure TTPAReport.FillCollumn(C : TCell);
  procedure FillDate();
  var
    Year, Month, Day : integer;
    StartDate : TDateTime;
  begin
    if (TempDay > '') and
       (TempMonth > '') and
       (TempYear > '') then
    begin
      if (TryStrToInt(TempDay, Day)) and
         (TryStrToInt(TempMonth, Month)) and
         (TryStrToInt(TempYear, Year)) then
      begin
        if TryEncodeDate(Year, Month, Day, StartDate) then
        begin
          Values.edtClientStartDte.asDateTime := StartDate;
        end;
      end;
    end;
  end;
begin
  if C.Col = fcAccountName then
    Values.edtNameOfAccount.Text := GetCellText(C)
  else if C.Col = fcAccountNo then
  begin
    Values.cmbInstitution.ItemIndex := 0;
    Values.edtAccountNumber.Text := GetCellText(C);
  end
  else if C.Col = fcCostCode then
    Values.edtCostCode.Text := GetCellText(C)
  else if C.Col = fcClientCode then
    Values.edtClientCode.Text := GetCellText(C)
  else if C.Col = fcDay then
  begin
    TempDay := GetCellText(C);
    FillDate();
  end
  else if C.Col = fcMonth then
  begin
    TempMonth := GetCellText(C);
    FillDate();
  end
  else if C.Col = fcYear then
  begin
    TempYear := GetCellText(C);
    FillDate();
  end
  else if C.Col = fcBank then
  begin
    Values.cmbInstitution.ItemIndex := 0;
    Values.edtInstitutionName.Text := GetCellText(C);
  end;
end;

//------------------------------------------------------------------------------
function TTPAReport.HaveNewdata: Boolean;
begin
  Result := (Values.edtNameOfAccount.Text > '')
         or (Values.AccountNumber > '');

  if not Result then
    ResetForm; // Clear the rest
end;

//------------------------------------------------------------------------------
procedure TTPAReport.ResetForm;
begin
  Values.btnClearClick(nil);
end;

//------------------------------------------------------------------------------
procedure TTPAReport.PrintForm;
Const
  MARGIN = 150;
var
  myCanvas : TCanvas;
  Year, Month, Day : Word;
  BankText : string;
  TempCurrYPos : integer;
  OutputLeft, OutputTop, OutputRight, OutputBottom : integer;
  CurrXPos : integer;
  BoxMargin2 : integer;
  XPosOneThirds, XPosTwoThirds : integer;
  XPosOneHalf : integer;
  YPosThreeQuaters : integer;
begin
  //assume we have a canvas of A4 proportions as per GST forms
  myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

  myCanvas.Font.Size := 22;
  myCanvas.Font.Style := [fsbold];
  myCanvas.Font.Name := 'Calibri';
  UserReportSettings.s7Orientation := BK_PORTRAIT;

  // Gets Output Area in form mm's and includes MARGIN const
  OutputLeft   := CanvasRenderEng.OutputBuilder.OutputAreaLeft + MARGIN;
  OutputTop    := CanvasRenderEng.OutputBuilder.OutputAreaTop + MARGIN;
  OutputRight  := CanvasRenderEng.OutputBuilder.OutputAreaLeft + CanvasRenderEng.OutputBuilder.OutputAreaWidth - MARGIN;
  OutputBottom := CanvasRenderEng.OutputBuilder.OutputAreaTop + CanvasRenderEng.OutputBuilder.OutputAreaHeight - MARGIN;

  // Initilizes CurYpos and Current Line Size
  CurrLineSize := GetCurrLineSizeNoInflation;//GetCurrLineSize;
  CurrYPos := OutputTop + BoxMargin;
  XPosTwoThirds    := OutputLeft + round((OutputRight - OutputLeft) * (2/3));
  XPosOneThirds    := OutputLeft + round((OutputRight - OutputLeft) * (1/3));
  XPosOneHalf      := OutputLeft + round((OutputRight - OutputLeft) / 2);
  YPosThreeQuaters := OutputTop +  round((OutputBottom - OutputTop) * 3/4);

  BoxMargin2 := BoxMargin * 2;

  //----------------------------------------------------------------------------
  TextLine('BankLink',OutputLeft + BoxMargin2, OutputRight);
  NewLine;
  myCanvas.Font.Size := 8;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('Incorporating BankLink Limited and Media Transfer Services Limited', OutputLeft + BoxMargin2, OutputRight);
  CurrYPos := OutputTop + BoxMargin;
  myCanvas.Font.Size := 10;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('Send completed form to:',XPosTwoThirds, OutputRight);
  NewLine;
  TextLine('BankLink, PO Box 56354,',XPosTwoThirds, OutputRight);
  NewLine;
  TextLine('Dominion Road, Auckland 1446',XPosTwoThirds, OutputRight);
  NewLine;
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 9;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextBox('Name of Account', Values.edtNameOfAccount.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Client Code', Values.edtClientCode.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);

  TextBox('Account Number', Values.AccountNumber, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Cost Code', Values.edtCostCode.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 16;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('THIRD PARTY AUTHORITY', OutputLeft + 100, OutputRight - 100, jtCenter);
  NewLine;
  DrawBox(XYSizeRect(OutputLeft, OutputTop, OutputRight, CurrYPos + BoxMargin2 + 10));

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 9;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('To:', OutputLeft, OutputRight);
  NewLine;
  TextLine('The Manager,', OutputLeft, OutputRight);
  TextLine('and', XPosTwoThirds-60, OutputRight);
  TextLine('The General Manager,', XPosTwoThirds+60, OutputRight);
  NewLine;
  TempCurrYPos := CurrYPos;
  TextLine('Media Transfer Services Limited', XPosTwoThirds+60, OutputRight);
  NewLine;
  TextLine('("BankLink")', XPosTwoThirds+60, OutputRight);
  NewLine;
  CurrYPos := TempCurrYPos;
  if Values.cmbInstitution.itemindex = 0 then
    BankText := Values.edtInstitutionName.text + '   ' + Values.edtBranch.Text
  else
    BankText := Values.cmbInstitution.text + '   ' + Values.edtBranch.Text;
  TextBox('', BankText, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft, XPosTwoThirds-120, CurrYPos, CurrYPos + BoxHeight);
  CurrYPos := GetTextYPos(CurrYPos);
  NewLine;
  HalfNewLine;
  CurrYPos := CurrYPos + 3;
  myCanvas.Font.Size := 8;
  TextLine('(Bank and Branch Name)', OutputLeft, OutputRight);
  myCanvas.Font.Size := 9;

  //----------------------------------------------------------------------------
  NewLine(2);

  if length(trim(Values.edtClientStartDte.Text)) <= 4 then
  begin
    TextBox('As from the', '', myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft, OutputLeft + 170, OutputLeft + 230, CurrYPos, CurrYPos + BoxHeight, true);
    TextBox('day of', '', myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft + 240, OutputLeft + 340, OutputLeft + 620, CurrYPos, CurrYPos + BoxHeight, true);
    TextBox('20', '', myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft + 640, OutputLeft + 680, OutputLeft + 740, CurrYPos, CurrYPos + BoxHeight, true);
  end
  else
  begin
    DecodeDate(Values.edtClientStartDte.AsDateTime, Year, Month, Day);
    TextBox('As from the', inttoStr(Day), myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft, OutputLeft + 170, OutputLeft + 230, CurrYPos, CurrYPos + BoxHeight, true);
    TextBox('day of', moNames[Month], myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft + 240, OutputLeft + 340, OutputLeft + 620, CurrYPos, CurrYPos + BoxHeight, true);
    TextBox('20', RightStr(inttoStr(Year),2), myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
            OutputLeft + 640, OutputLeft + 680, OutputLeft + 740, CurrYPos, CurrYPos + BoxHeight, true);
  end;

  NewLine;

  TextLine('you and each of you are hereby authorised to disclose and/or', OutputLeft + 760, OutputRight);
  NewLine;
  TextLine('make use of all data and information relating to my/our bank account designated above which may be required in', OutputLeft, OutputRight);
  NewLine;
  TextLine('connection with the performance of the processing services under any E.D.P. Services Contract which you or either of', OutputLeft, OutputRight);
  NewLine;
  TextLine('you may now or hereafter have with', OutputLeft, OutputRight);
  NewLine(2);
  TextBox('', Values.PracticeName, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft, XPosTwoThirds-300, CurrYPos, CurrYPos + BoxHeight);
  TextBox('', Values.PracticeCode, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds-100, XPosTwoThirds-100, XPosTwoThirds+400, CurrYPos, CurrYPos + BoxHeight);
  CurrYPos := GetTextYPos(CurrYPos);
  NewLine;
  HalfNewLine;
  CurrYPos := CurrYPos + 3;
  myCanvas.Font.Size := 8;
  TextLine('(my/our advisors)', OutputLeft, OutputRight);
  TextLine('(Practice Code)', XPosTwoThirds-100, OutputRight);
  myCanvas.Font.Size := 9;

  //----------------------------------------------------------------------------
  NewLine(2);
  TextLine('and neither of you shall be liable for delays, non-performance, failure to perform, processing errors or any other', OutputLeft, OutputRight);
  NewLine;
  TextLine('matter or thing arising out of this authority or the contract which occur for reasons beyond your control and under', OutputLeft, OutputRight);
  NewLine;
  TextLine('no circumstances shall your liability (either joint or several) include or extend to any special or consequential', OutputLeft, OutputRight);
  NewLine;
  TextLine('loss or damage.', OutputLeft, OutputRight);
  NewLine(2);
  TextLine('Any revocation of this authority by me/us will take effect fourteen (14) days after written notice is received by', OutputLeft, OutputRight);
  NewLine;
  TextLine('the Bank from BankLink.', OutputLeft, OutputRight);
  NewLine;

  //----------------------------------------------------------------------------
  // Footer works from the bottom up so we align with the bottom properly
  //----------------------------------------------------------------------------
  CurrYPos := OutputBottom;
  myCanvas.Font.Size := 8;
  NewLineUp(2);

  if (Values.cmbInstitution.ItemIndex > 0) and
     (TInstitutionItem(Values.cmbInstitution.Items.Objects[Values.cmbInstitution.ItemIndex]).HasRuralCode) then
  begin
    DrawRadio(myCanvas, XYSizeRect(OutputLeft + BoxMargin2*4, CurrYPos, OutputRight, CurrYPos+CurrLineSize), ' Re-date transactions to Payment Date', True, Values.radReDateTransactions.Checked);
    DrawRadio(myCanvas, XYSizeRect(XPosOneThirds + BoxMargin2*4, CurrYPos, OutputRight, CurrYPos+CurrLineSize), ' Date shown on statement (not re-dated)', True, Values.radDateShown.Checked);
  end
  else
  begin
    DrawRadio(myCanvas, XYSizeRect(OutputLeft + BoxMargin2*4, CurrYPos, OutputRight, CurrYPos+CurrLineSize), ' Re-date transactions to Payment Date', True, false);
    DrawRadio(myCanvas, XYSizeRect(XPosOneThirds + BoxMargin2*4, CurrYPos, OutputRight, CurrYPos+CurrLineSize), ' Date shown on statement (not re-dated)', True, false);
  end;

  NewLineUp;
  HalfNewLineUp;
  TextLine('Rural Institutions Only:', OutputLeft + BoxMargin2 , OutputRight);
  HalfNewLineUp;
  NewLineUp(2);
  TempCurrYPos := CurrYPos;
  CurrYPos := GetTextYPos(CurrYPos);
  DrawCheckbox(OutputLeft + BoxMargin2, CurrYPos, (Values.chkDataSecureExisting.Checked or Values.chkDataSecureNew.Checked));
  TextLine('Secure Client', OutputLeft + 80 , OutputRight);
  CurrYPos := TempCurrYPos;

  if Values.chkDataSecureExisting.Checked then
    TextBox('Existing Secure Code', Values.edtSecureCode.text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
            XPosOneThirds-30, XPosOneThirds + 280, XPosTwoThirds, CurrYPos, CurrYPos + BoxHeight)
  else
    TextBox('Existing Secure Code', '', myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
            XPosOneThirds-30, XPosOneThirds + 280, XPosTwoThirds, CurrYPos, CurrYPos + BoxHeight);

  NewLineUp;
  HalfNewLineUp;
  DrawCheckbox(OutputLeft + BoxMargin2, CurrYPos, (values.InstitutionType = inOther));
  TextLine('Please supply the account above as a Provisional Account if it is not available from the Bank', OutputLeft + 80 , OutputRight);
  NewLineUp;
  HalfNewLineUp;
  myCanvas.Font.Style := [fsBold];
  TextLine('Additional Information to assist BankLink processing', OutputLeft + BoxMargin2 , OutputRight);
  NewLineUp;
  DrawBox(XYSizeRect(OutputLeft, CurrYPos, OutputRight, OutputBottom));
  myCanvas.Font.Size := 9;

  //----------------------------------------------------------------------------
  CreateQRCode(MyCanvas, XYSizeRect(OutputRight-((OutputBottom-CurrYPos-40)+20), CurrYPos + 20, OutputRight-20, OutputBottom-20));

  //----------------------------------------------------------------------------
  NewLineUp(3);
  myCanvas.Font.Style := [];
  myCanvas.Font.Size := 8;
  TextLine('(Signature of Third Party)', OutputLeft, OutputRight);
  myCanvas.Font.Size := 9;
  NewLineUp;
  TextLine('....................................................................................................................', OutputLeft, OutputRight);
  NewLineUp(4);
  myCanvas.Font.Size := 8;
  TextLine('(Print name of Third Party)', OutputLeft, OutputRight);
  myCanvas.Font.Size := 9;
  NewLineUp;
  TextLine('....................................................................................................................', OutputLeft, OutputRight);
  NewLineUp(4);
  TextLine('Dated this ................. day of ..................................................... 20............', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  WasPrinted := True;
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
  if Values.InstitutionType <> inBLO then
    Exit;

  if (Values.chkDataSecureExisting.checked) or
     (Values.chkDataSecureNew.checked) then
    Exit;

{$IFNDEF PRACTICE-7}
  CAFQRData := TCAFQRData.Create(TCAFQRDataAccount);
  try
    CafQrCode := TCafQrCode.Create;
    try
      QrCodeImage := TImage.Create(nil);
      try
        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtNameOfAccount.text;
        CAFQRDataAccount.AccountNumber := Values.AccountNumber;
        CAFQRDataAccount.ClientCode    := Values.edtClientCode.Text;
        CAFQRDataAccount.CostCode      := Values.edtCostCode.Text;
        CAFQRDataAccount.SMSF          := 'N';

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := '';
        CAFQRDataAccount.AccountNumber := '';
        CAFQRDataAccount.ClientCode    := '';
        CAFQRDataAccount.CostCode      := '';
        CAFQRDataAccount.SMSF          := 'N';

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := '';
        CAFQRDataAccount.AccountNumber := '';
        CAFQRDataAccount.ClientCode    := '';
        CAFQRDataAccount.CostCode      := '';
        CAFQRDataAccount.SMSF          := 'N';

        // Day , Month , Year
        CAFQRData.StartDate := Values.edtClientStartDte.AsDateTime;

        CAFQRData.PracticeCode        := Values.PracticeCode;
        CAFQRData.PracticeCountryCode := CountryText(AdminSystem.fdFields.fdCountry);

        CAFQRData.SetProvisional(Values.InstitutionType = inOther);

        CAFQRData.Frequency := 'D';
        CAFQRData.TimeStamp := Now;

        // Institution Code and Country
        InstIndex := Values.cmbInstitution.ItemIndex;

        if (TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).HasRuralCode) and
           (Values.radDateShown.checked) then
          CAFQRData.InstitutionCode := TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).RuralCode
        else
          CAFQRData.InstitutionCode := TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).Code;

        // Exception code for ANZ and National Bank, removed National bank so must set to NAT when
        // ANZ is selected and Account bank is for national
        if Institutions.DoInstituionExceptionCode(Values.AccountNumber, CAFQRData.InstitutionCode) = ieNAT then
          CAFQRData.InstitutionCode := 'NAT';

        CAFQRData.InstitutionCountry := TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).CountryCode;

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
  end;
  {$ENDIF}
end;

end.
