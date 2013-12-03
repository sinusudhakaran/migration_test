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
  windows,
  Graphics,
  ReportTypes;

type
  TCAFReport = class(TAuthorityReport)
  private
    FValues: TfrmCAF; // pass the form so if text changes we may not have to change the report
    TempMonth : string;
    TempYear  : string;
  protected
    procedure PrintForm; override;
    procedure ResetForm; override;
    procedure FillCollumn(C: TCell); override;
    function HaveNewdata: Boolean; override;
  public
    constructor Create(RptType: TReportType); Override;
    procedure CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);   
    procedure BKPrint;  override;
    
	property Values : TfrmCAF read FVAlues write FValues;
  end;

function DoCAFReport(Values: TfrmCAF; Destination : TReportDest; Mode: TAFMode; Addr: string = '') : Boolean;

//------------------------------------------------------------------------------
implementation

uses
  Globals,
  MailFrm,
  bkConst,
  Types,
  RepCols,
  UserReportSettings,
  BKPrintJob,
  Printers,
  {$IFNDEF PRACTICE-7}
  CafQrCode,
  {$ENDIF}
  ExtCtrls,
  Sysutils,
  webutils,
  InstitutionCol,
  StrUtils,
  ExtractCommon;

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
    if (Mode = AFImport) and
       (not Job.ImportFile(Values.ImportFile,False)) then
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

    if (Result) and (Mode = AFEmail) then
    begin
      MailFrm.SendFileTo( 'Send Client Authority Form', Addr, '', Job.ReportFile, AttachmentSent, False, True);
      DeleteFile(PAnsiChar(Job.ReportFile));
    end;
  finally
    Job.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TCAFReport.Create(RptType: TReportType);
begin
  inherited create(RptType);

  TempMonth := '';
  TempYear  := '';
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
procedure TCAFReport.FillCollumn(C : TCell);
  procedure FillDate();
  var
    Year, Month, Day : integer;
    StartDate : TDateTime;
  begin
    if (TempMonth > '') and
       (TempYear > '') then
    begin
      if (TryStrToInt(TempMonth, Month)) and
         (TryStrToInt(TempYear, Year)) then
      begin
        Day := 1;
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
  else if C.Col = fcBSB then
  begin
    Values.cmbInstitution.ItemIndex := 0;
    Values.edtAccountNumber.Text := GetCellText(C) + Values.edtAccountNumber.Text;
  end
  else if C.Col = fcAccountNo then
  begin
    Values.cmbInstitution.ItemIndex := 0;
    Values.edtAccountNumber.Text := Values.edtAccountNumber.Text + GetCellText(C);
  end
  else if C.Col = fcCostCode then
    Values.edtCostCode.Text := GetCellText(C)
  else if C.Col = fcClientCode then
    Values.edtClientCode.Text := GetCellText(C)
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
function TCAFReport.HaveNewdata: Boolean;
begin
  Result := (Values.edtNameOfAccount.Text > '')
         or (Values.AccountNumber > '');

  if not Result then
    ResetForm; // Clear the rest
end;

//------------------------------------------------------------------------------
procedure TCAFReport.ResetForm;
begin
  Values.btnClearClick(nil);
end;

//------------------------------------------------------------------------------
procedure TCAFReport.PrintForm;
Const
  MARGIN_HORZ = 150;
  MARGIN_VERT = 100;
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
  NumColumn : integer;
  IndentColumn : integer;
  TextWidth : integer;
  DispBSB, DispAccNum : string;
begin
  //assume we have a canvas of A4 proportions as per GST forms
  myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

  myCanvas.Font.Size := 22;
  myCanvas.Font.Style := [fsbold];
  myCanvas.Font.Name := 'Calibri';
  UserReportSettings.s7Orientation := BK_PORTRAIT;

  // Gets Output Area in form mm's and includes MARGIN const
  OutputLeft   := CanvasRenderEng.OutputBuilder.OutputAreaLeft + MARGIN_HORZ;
  OutputTop    := CanvasRenderEng.OutputBuilder.OutputAreaTop + MARGIN_VERT;
  OutputRight  := CanvasRenderEng.OutputBuilder.OutputAreaLeft + CanvasRenderEng.OutputBuilder.OutputAreaWidth - MARGIN_HORZ;
  OutputBottom := CanvasRenderEng.OutputBuilder.OutputAreaTop + CanvasRenderEng.OutputBuilder.OutputAreaHeight - MARGIN_VERT;

  // Initilizes CurYpos and Current Line Size
  CurrLineSize := GetCurrLineSizeNoInflation;//GetCurrLineSize;
  CurrYPos := OutputTop + BoxMargin;
  XPosTwoThirds    := OutputLeft + round((OutputRight - OutputLeft) * (2/3));
  XPosOneThirds    := OutputLeft + round((OutputRight - OutputLeft) * (1/3));
  XPosOneHalf      := OutputLeft + round((OutputRight - OutputLeft) / 2);
  YPosThreeQuaters := OutputTop +  round((OutputBottom - OutputTop) * 3/4);
  NumColumn        := OutputLeft - 60;
  IndentColumn     := OutputLeft + 60;

  BoxMargin2 := BoxMargin * 2;

  //----------------------------------------------------------------------------
  TextLine('BankLink',OutputLeft + BoxMargin2, OutputRight);
  NewLine;
  myCanvas.Font.Size := 7;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('(A Division of Media Transfer Services Limited)', OutputLeft + BoxMargin2, OutputRight);

  CurrYPos := OutputTop + BoxMargin;
  myCanvas.Font.Size := 10;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('Send completed form to:',XPosTwoThirds, OutputRight);
  NewLine;
  TextLine('BankLink',XPosTwoThirds, OutputRight);
  NewLine;
  TextLine('GPO Box 4608, Sydney 2001, NSW',XPosTwoThirds, OutputRight);
  NewLine;
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 8;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextBox('Name of Account', Values.edtNameOfAccount.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Client Code', Values.edtClientCode.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);

  // Separate the account number into BSB and Accnumber
  ProcessDiskCode(Values.AccountNumber, DispBSB, DispAccNum);
  if DispBSB = '000000' then
    DispBSB := '';

  if DispAccNum = '' then
  begin
    DispAccNum := DispBSB;
    DispBSB := '';
  end;

  TextBox('Account Number', DispBSB, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, OutputLeft + BoxMargin + 550, CurrYPos, CurrYPos + BoxHeight);
  TextBox('', DispAccNum, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft + BoxMargin + 560, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Cost Code', Values.edtCostCode.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 16;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('BANKLINK CLIENT AUTHORITY', OutputLeft + 100, OutputRight - 100, jtCenter);
  NewLine;
  DrawBox(XYSizeRect(OutputLeft, OutputTop, OutputRight, CurrYPos + BoxMargin2 + 10));

  //----------------------------------------------------------------------------
  NewLine;
  myCanvas.Font.Size := 8;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('To:', NumColumn, OutputRight);
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
  myCanvas.Font.Size := 7;
  TextLine('(Bank)', OutputLeft, OutputRight);
  TextLine('(Branch)', OutputLeft+300, OutputRight);
  NewLine;
  TextLine('("the Bank")', OutputLeft, OutputRight);
  myCanvas.Font.Size := 8;

  //----------------------------------------------------------------------------
  NewLine;
  DecodeDate(Values.edtClientStartDte.AsDateTime, Year, Month, Day);

  TextWidth := CanvasRenderEng.GetTextLength('I/We hereby AUTHORISE the Bank and BankLink as at and from the first of');

  TextBox('I/We hereby AUTHORISE the Bank and BankLink as at and from the first of',
          moNames[Month], myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
          OutputLeft, OutputLeft + TextWidth + 20, XPosTwoThirds + 20, CurrYPos, CurrYPos + BoxHeight, true);
  TextBox('20', RightStr(inttoStr(Year),2), myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtCenter,
          XPosTwoThirds + 30, XPosTwoThirds + 70, XPosTwoThirds + 140, CurrYPos, CurrYPos + BoxHeight, true);
  NewLine;
  TextLine('1.', NumColumn, OutputRight);
  TextLine('to forward all data and', XPosTwoThirds + 150, OutputRight);
  NewLine;
  CurrYPos := CurrYPos + 8;
  TextLine('information (whether in written, computer readable or any other format) relating to my/our banks account/s designated above to each', OutputLeft, OutputRight);
  NewLine;
  TextLine('other and to', OutputLeft, OutputRight);
  NewLine;
  HalfNewLine;
  TextBox('', Values.PracticeName, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft, XPosTwoThirds-300, CurrYPos, CurrYPos + BoxHeight);
  TextBox('', Values.PracticeCode, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds-100, XPosTwoThirds-100, XPosTwoThirds+400, CurrYPos, CurrYPos + BoxHeight);
  CurrYPos := GetTextYPos(CurrYPos);
  NewLine;
  HalfNewLine;
  CurrYPos := CurrYPos + 5;
  myCanvas.Font.Size := 7;
  TextLine('(my/our advisors)', OutputLeft, OutputRight);
  TextLine('(Practice Code)', XPosTwoThirds-100, OutputRight);
  myCanvas.Font.Size := 8;

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('2.', NumColumn, OutputRight);
  TextLine('I/We UNDERSTAND that:', OutputLeft, OutputRight);
  NewLine;
  TextLine('a)', OutputLeft, OutputRight);
  TextLine('no agency, partnership, joint venture or any other type of similar relationship exists between the Bank and BankLink and that the', IndentColumn, OutputRight);
  NewLine;
  TextLine('Bank accepts no responsibility for the actions of BankLink, my/our advisors or any other third party;', IndentColumn, OutputRight);
  NewLine;
  HalfNewLine;
  TextLine('b)', OutputLeft, OutputRight);
  TextLine('unless otherwise required or prohibited by any applicable law (including the Australian Consumer Law), neither the Bank nor', IndentColumn, OutputRight);
  NewLine;
  TextLine('BankLink will be liable for delays, non-performance, failure to perform, processing errors or any other matter or thing arising out', IndentColumn, OutputRight);
  NewLine;
  TextLine('of this authority or any agreement which the Bank or BankLink may have with my/our advisors and which occur for reasons beyond', IndentColumn, OutputRight);
  NewLine;
  TextLine('the control of respectively the Bank or BankLink, as the case may be, nor will the liability of the Bank and/or BankLink (whether', IndentColumn, OutputRight);
  NewLine;
  TextLine('jointly, severally or jointly and severally) include or extend to any special or consequential loss or damage suffered by me/us.', IndentColumn, OutputRight);
  NewLine;
  TextLine('', IndentColumn, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('3.', NumColumn, OutputRight);
  TextLine('I/We ACKNOWLEDGE that the Bank will receive a commission from BankLink for disclosing the data and information referred to above,', OutputLeft, OutputRight);
  NewLine;
  TextLine('and that the Bank is under no obligation to me/us to supply the data and information referred to above to BankLink, and may cease', OutputLeft, OutputRight);
  NewLine;
  TextLine('to do so without notice to me/us.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('4.', NumColumn, OutputRight);
  TextLine('This authority is terminable by any or both of the Bank or BankLink at any time where seven (7) days notice is given to me/us on', OutputLeft, OutputRight);
  NewLine;
  TextLine('any grounds thought fit, without rendering the Bank and/or BankLink liable in any way.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('5.', NumColumn, OutputRight);
  TextLine('Any revocation of this authority by me/us will not take effect until 14 days after written notice of the revocation is received by the ', OutputLeft, OutputRight);
  NewLine;
  TextLine('Bank from me/us.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('6.', NumColumn, OutputRight);
  TextLine('By signing below I/we agree that my/our personal information may be collected, stored, used and disclosed by', OutputLeft, OutputRight);
  NewLine;
  TextLine('BankLink in accordance with the BankLink Privacy Policy [http://www.banklink.com.au/index.php/privacy]', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  // Footer works from the bottom up so we align with the bottom properly
  //----------------------------------------------------------------------------
  CurrYPos := OutputBottom;
  NewLineUp(3);
  TempCurrYPos := CurrYPos;
  CurrYPos := GetTextYPos(CurrYPos);
  DrawCheckbox(OutputLeft + BoxMargin2, CurrYPos, (Values.chkDataSecureExisting.Checked or Values.chkDataSecureNew.Checked));
  TextLine('Secure Client', OutputLeft + 80 , OutputRight);
  CurrYPos := TempCurrYPos;
  
  if (Values.chkDataSecureExisting.checked) then
    TextBox('Existing Secure Code', Values.edtSecureCode.text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
            XPosOneThirds-30, XPosOneThirds + 280, XPosTwoThirds, CurrYPos, CurrYPos + BoxHeight)
  else
    TextBox('Existing Secure Code', '', myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
            XPosOneThirds-30, XPosOneThirds + 280, XPosTwoThirds, CurrYPos, CurrYPos + BoxHeight);


  NewLineUp(2);
  DrawCheckbox(OutputLeft + BoxMargin2, CurrYPos, (values.InstitutionType = inOther));
  TextLine('Please supply the account above as Provisional Account if it is not available from the Bank', OutputLeft + 80 , OutputRight);
  NewLineUp(2);
  myCanvas.Font.Style := [fsBold];
  TextLine('Additional Information to assist BankLink processing', OutputLeft + BoxMargin2 , OutputRight);
  NewLineUp;
  DrawBox(XYSizeRect(OutputLeft, CurrYPos, OutputRight, OutputBottom));

  CreateQRCode(MyCanvas, XYSizeRect(OutputRight-((OutputBottom-CurrYPos-40)+20), CurrYPos + 20, OutputRight-20, OutputBottom-20));

  //----------------------------------------------------------------------------
  NewLineUp(2);
  myCanvas.Font.Style := [];
  myCanvas.Font.Size := 7;
  TextLine('(Account signatory)', OutputLeft, OutputRight);
  TextLine('(Account signatory)', OutputRight - 200, OutputRight);
  myCanvas.Font.Size := 8;
  NewLineUp;
  TextLine('........................................................................................................', OutputLeft, OutputRight);
  TextLine('........................................................................................................', XPosOneHalf + 100, OutputRight);
  NewLineUp(4);
  myCanvas.Font.Size := 7;
  TextLine('(Account signatory)', OutputLeft, OutputRight);
  TextLine('(Account signatory)', OutputRight - 200, OutputRight);
  myCanvas.Font.Size := 8;
  NewLineUp;
  TextLine('........................................................................................................', OutputLeft, OutputRight);
  TextLine('........................................................................................................', XPosOneHalf + 100, OutputRight);
  NewLineUp(4);
  TextLine('Dated this ................. day of ..................................................... 20............', OutputLeft, OutputRight);


  WasPrinted := True;
end;

//------------------------------------------------------------------------------
procedure TCAFReport.CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);
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
        CAFQRData.InstitutionCode := TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).Code;

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
