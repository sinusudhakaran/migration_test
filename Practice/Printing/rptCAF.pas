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
    fProvisional : boolean;
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
  ExtractCommon,
  bkDateUtils;

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
      if (Values.InstitutionCode = 'AMEX') then
        Job.ReportFile := '';

      if Values.LoadMailTemplateFromResource then
      begin
        AttachmentSent := False;

        MailFrm.SendFileTo( 'Send Client Authority Form', Addr, Values.MailSubject, Job.ReportFile, AttachmentSent,
                    False, True,
                    Values.LoadMailTemplateFromResource,Values.MailReplaceStrings);
      end
      else
        MailFrm.SendFileTo( 'Send Client Authority Form', Addr, Values.MailSubject, Job.ReportFile, AttachmentSent, False, True);
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
      if (TryConvertStrMonthToInt(TempMonth, Month)) and
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
  begin
    Values.edtNameOfAccount1.Text := GetCellText(C);
    Values.AccountNumber1 := '';
  end
  else if C.Col = fcBSB then
  begin
    Values.AccountNumber1 := GetCellText(C) + Values.AccountNumber1;
  end
  else if C.Col = fcAccountNo then
  begin
    Values.AccountNumber1 := Values.AccountNumber1 + GetCellText(C);
    Values.edtClientStartDte.ClearContents();
    fProvisional := true;
  end
  else if C.Col = fcCostCode then
    Values.edtCostCode1.Text := GetCellText(C)
  else if C.Col = fcClientCode then
    Values.edtClientCode1.Text := GetCellText(C)
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
  end
  else if C.Col = fcProvisional then
  begin
    if (GetCellText(C) = 'N') then
      fProvisional := false
    else
      fProvisional := true;
  end;
end;

//------------------------------------------------------------------------------
function TCAFReport.HaveNewdata: Boolean;
begin
  Result := (Values.AccountNumber1 > '');

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
  BoxMargin2 : integer;
  XPosOneThirds, XPosTwoThirds : integer;
  XPosOneHalf : integer;
  YPosThreeQuaters : integer;
  NumColumn : integer;
  IndentColumn : integer;
  TextWidth : integer;
  Point2StartTest : string;
  XPosDateBox : integer;
begin
  //assume we have a canvas of A4 proportions as per GST forms
  myCanvas     := CanvasRenderEng.OutputBuilder.Canvas;

  myCanvas.Font.Size := 28;
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
  TextLine(BRAND_FULL_NAME,OutputLeft + BoxMargin2, OutputRight);
  NewLine;
  myCanvas.Font.Size := 7;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;

  CurrYPos := OutputTop + BoxMargin;
  myCanvas.Font.Size := 10;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('Send completed form to:',XPosTwoThirds, OutputRight);
  NewLine;
  TextLine(BRAND_FULL_NAME,XPosTwoThirds, OutputRight);
  NewLine;
  TextLine('Reply Paid 86472, Sydney 2001, NSW',XPosTwoThirds, OutputRight);
  NewLine;
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  myCanvas.Font.Size := 8;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation;
  CurrLineSize := CurrLineSize - 8;
  NewLine;
  CurrLineSize := CurrLineSize + 8;
  // Account 1
  TextBox('Name of Account', Values.edtNameOfAccount1.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Client Code', Values.edtClientCode1.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(2);
  CurrYPos := CurrYPos + 19;

  TextBox('Account Number', Values.AccountNumber1, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Cost Code', Values.edtCostCode1.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin - 20);

  // Account 2
  CurrYPos := CurrYPos + 9;
  TextBox('Name of Account', Values.edtNameOfAccount2.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);
  TextBox('Client Code', Values.edtClientCode2.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(2);
  HalfNewLine;

  TextBox('Account Number', Values.AccountNumber2, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Cost Code', Values.edtCostCode2.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(3);
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin - 20);

  // Account 3
  CurrYPos := CurrYPos + 9;
  TextBox('Name of Account', Values.edtNameOfAccount3.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);
  TextBox('Client Code', Values.edtClientCode3.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(2);
  HalfNewLine;

  TextBox('Account Number', Values.AccountNumber3, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          OutputLeft + BoxMargin2, OutputLeft + BoxMargin + 270, XPosTwoThirds - BoxMargin, CurrYPos, CurrYPos + BoxHeight);

  TextBox('Cost Code', Values.edtCostCode3.Text, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosTwoThirds + BoxMargin, XPosTwoThirds + BoxMargin + 175, OutputRight - BoxMargin2, CurrYPos, CurrYPos + BoxHeight);

  NewLine(2);
  HalfNewLine;
  DrawLineAtPos(OutputLeft+2, OutputRight-2, CurrYPos + BoxMargin);

  //----------------------------------------------------------------------------
  myCanvas.Font.Size := 8;
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  HalfNewLine;
  myCanvas.Font.Size := 12;
  myCanvas.Font.Style := [fsBold];
  CurrLineSize := GetCurrLineSizeNoInflation;
  TextLine('CLIENT AUTHORITY', OutputLeft + 100, OutputRight - 100, jtCenter);
  myCanvas.Font.Size := 8;
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  NewLine;
  DrawBox(XYSizeRect(OutputLeft, OutputTop, OutputRight, CurrYPos + BoxMargin2 + 10));

  //----------------------------------------------------------------------------
//  NewLine;
  myCanvas.Font.Size := 8;
  myCanvas.Font.Style := [];
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  NewLine;
  HalfNewLine;
  TextLine('To:', NumColumn, OutputRight);
  TextLine('The Manager,', OutputLeft, OutputRight);
  TextLine('and', XPosTwoThirds-60, OutputRight);
  TextLine('The General Manager,', XPosTwoThirds+60, OutputRight);
  NewLine;
  TempCurrYPos := CurrYPos;
  TextLine('MYOB Australia Pty Ltd', XPosTwoThirds+60, OutputRight);
  NewLine;
  TextLine('("' + BRAND_FULL_NAME + '")', XPosTwoThirds+60, OutputRight);
  NewLine;
  myCanvas.Font.Size := 7;
  CurrYPos := TempCurrYPos;
  if Values.cmbInstitution.itemindex = 0 then
    BankText := Values.edtInstitutionName.text + '   ' + Values.edtBranch.Text
  else
    BankText := Values.cmbInstitution.text + '   ' + Values.edtBranch.Text;
  TextBox('', BankText, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft, XPosTwoThirds-120, CurrYPos, CurrYPos + BoxHeight);
  CurrYPos := GetTextYPos(CurrYPos);
  myCanvas.Font.Size := 8;
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  NewLine(1);
  HalfNewLine;
  myCanvas.Font.Size := 7;
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  CurrYPos := CurrYPos + 3;
  TextLine('(Supplier Name)', OutputLeft, OutputRight);
  NewLine;
  TextLine('("the Supplier")', OutputLeft, OutputRight);
  myCanvas.Font.Size := 8;

  //----------------------------------------------------------------------------
  NewLine;
  DecodeDate(Values.edtClientStartDte.AsDateTime, Year, Month, Day);
  Point2StartTest := 'I/We hereby AUTHORISE the Supplier and ' + BRAND_FULL_NAME + ' as at and from the first of';
  TextWidth := CanvasRenderEng.GetTextLength(Point2StartTest);
  CurrYPos := CurrYPos - 18;

  XPosDateBox := OutputLeft + TextWidth + CanvasRenderEng.GetTextLength(' SEPTEMBER ');

  if length(trim(Values.edtClientStartDte.Text)) <= 4 then
  begin
    TextBox(
      Point2StartTest,
      '',
      myCanvas.Font.Size,
      myCanvas.Font.Size + 1,
      jtLeft,
      jtCenter,
      OutputLeft,
      OutputLeft + TextWidth + 20,
      XPosDateBox + 70,
      CurrYPos,
      CurrYPos + BoxHeight - 6,
      true);

    TextBox(
      '20',
      '',
      myCanvas.Font.Size,
      myCanvas.Font.Size + 1,
      jtLeft,
      jtCenter,
      XPosDateBox + 80,
      XPosDateBox + 120,
      XPosDateBox + 190,
      CurrYPos,
      CurrYPos + BoxHeight - 6,
      true);
  end
  else
  begin
    TextBox(
      Point2StartTest,
      UpperCase(moNames[Month]),
      myCanvas.Font.Size,
      myCanvas.Font.Size + 1,
      jtLeft,
      jtCenter,
      OutputLeft,
      OutputLeft + TextWidth + 20,
      XPosDateBox + 70,
      CurrYPos,
      CurrYPos + BoxHeight - 6,
      true);

    TextBox(
      '20',
      RightStr(inttoStr(Year),2),
      myCanvas.Font.Size,
      myCanvas.Font.Size + 1,
      jtLeft,
      jtCenter,
      XPosDateBox + 80,
      XPosDateBox + 120,
      XPosDateBox + 190,
      CurrYPos,
      CurrYPos + BoxHeight - 6,
      true);
  end;

  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  NewLine;
  TextLine('1.', NumColumn, OutputRight);
  TextLine('to forward all data', XPosDateBox + 200, OutputRight);
  NewLine;
  TextLine('and information (whether in written, computer readable or any other format) relating to my/our account(s) designated above', OutputLeft, OutputRight);
  NewLine;
  TextLine('to each other and to', OutputLeft, OutputRight);
  myCanvas.Font.Size := 7;
  CurrLineSize := GetCurrLineSizeNoInflation + 3;
  NewLine;
  HalfNewLine;
  TextBox('', Values.PracticeName, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          0, OutputLeft, XPosDateBox-300, CurrYPos, CurrYPos + BoxHeight);
  TextBox('', Values.PracticeCode, myCanvas.Font.Size, myCanvas.Font.Size + 1, jtLeft, jtLeft,
          XPosDateBox-100, XPosDateBox-100, XPosDateBox+400, CurrYPos, CurrYPos + BoxHeight);
  CurrYPos := GetTextYPos(CurrYPos);
  NewLine(1);
  HalfNewLine;
  CurrYPos := CurrYPos + 5;
  TextLine('("my/our authorised recipients")', OutputLeft, OutputRight);
  TextLine('(Practice Code)', XPosDateBox-100, OutputRight);
  myCanvas.Font.Size := 8;

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('2.', NumColumn, OutputRight);
  TextLine('I/We UNDERSTAND that:', OutputLeft, OutputRight);
  NewLine;
  TextLine('a)', OutputLeft, OutputRight);
  TextLine('no agency, partnership, joint venture or any other type of similar relationship exists between the Supplier and ' + BRAND_FULL_NAME + ' and', IndentColumn, OutputRight);
  NewLine;
  TextLine('that the Supplier accepts no responsibility for the actions of ' + BRAND_FULL_NAME + ', my/our authorised recipients or any other third party;', IndentColumn, OutputRight);
  NewLine;
  TextLine('b)', OutputLeft, OutputRight);
  TextLine('unless otherwise required or prohibited by any applicable law (including the Australian Consumer Law), neither the Supplier nor', IndentColumn, OutputRight);
  NewLine;
  TextLine(BRAND_FULL_NAME + ' will be liable for delays, non-performance, failure to perform, processing errors or any other matter or thing arising', IndentColumn, OutputRight);
  NewLine;
  TextLine('out of this authority or any agreement which the Supplier or ' + BRAND_FULL_NAME + ' may have with my/our authorised recipients and which', IndentColumn, OutputRight);
  NewLine;
  TextLine('occur for reasons beyond the control of respectively the Supplier or ' + BRAND_FULL_NAME + ', as the case may be, nor will the liability of the', IndentColumn, OutputRight);
  NewLine;
  TextLine('Supplier and/or ' + BRAND_FULL_NAME + ' (whether jointly, severally or jointly and severally) include or extend to any special or consequential', IndentColumn, OutputRight);
  NewLine;
  TextLine('loss or damage suffered by me/us.', IndentColumn, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('3.', NumColumn, OutputRight);
  TextLine('I/We ACKNOWLEDGE that the Supplier may receive a commission from ' + BRAND_FULL_NAME + ' for disclosing the data and information referred to', OutputLeft, OutputRight);
  NewLine;
  TextLine('above, and that the Supplier is under no obligation to me/us to supply the data and information referred to above to ' + BRAND_FULL_NAME + ', and', OutputLeft, OutputRight);
  NewLine;
  TextLine('may cease to do so without notice to me/us.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('4.', NumColumn, OutputRight);
  TextLine('This authority is terminable by any or both of the Supplier or ' + BRAND_FULL_NAME + ' at any time where seven (7) days notice is given to me/us on', OutputLeft, OutputRight);
  NewLine;
  TextLine('any grounds thought fit, without rendering the Supplier and/or ' + BRAND_FULL_NAME + ' liable in any way.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('5.', NumColumn, OutputRight);
  TextLine('Any revocation of this authority by me/us will not take effect until 14 days after written notice of the revocation is received by the ', OutputLeft, OutputRight);
  NewLine;
  TextLine('Supplier from me/us.', OutputLeft, OutputRight);

  //----------------------------------------------------------------------------
  NewLine;
  HalfNewLine;
  TextLine('6.', NumColumn, OutputRight);
  TextLine('By signing below I/we acknowledge that my/our personal information may be collected, stored, used and disclosed by', OutputLeft, OutputRight);
  NewLine;
  TextLine(BRAND_FULL_NAME + ' in accordance with the ' + BRAND_GROUP_NAME + ' Privacy Disclosure Statement (www.myob.com.au/privacy-disclosure)', OutputLeft, OutputRight);
  NewLine;
  TextLine('and the ' + BRAND_GROUP_NAME + ' Privacy Policy (www.myob.com/privacy).', OutputLeft, OutputRight);

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
  DrawCheckbox(OutputLeft + BoxMargin2, CurrYPos, (((values.InstitutionType = inOther) and (values.chkSupplyAsProvisional.Checked)) or (fProvisional)));
  TextLine('Please supply the account(s) above as Provisional Account(s) if they are not available from the Supplier', OutputLeft + 80 , OutputRight);
  NewLineUp(2);
  myCanvas.Font.Style := [fsBold];
  TextLine('Additional Information to assist ' + BRAND_FULL_NAME + ' processing', OutputLeft + BoxMargin2 , OutputRight);
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
  NewLineUp(2);
  HalfNewLineUp;
  myCanvas.Font.Size := 7;
  TextLine('(Account signatory)', OutputLeft, OutputRight);
  TextLine('(Account signatory)', OutputRight - 200, OutputRight);
  myCanvas.Font.Size := 8;
  NewLineUp;
  TextLine('........................................................................................................', OutputLeft, OutputRight);
  TextLine('........................................................................................................', XPosOneHalf + 100, OutputRight);
  NewLineUp(3);
  HalfNewLineUp;
  TextLine('Dated this ................. day of ..................................................... 20............', OutputLeft, OutputRight);


  WasPrinted := True;

  if ImportMode then
    Values.AccountNumber1 := '';
end;

//------------------------------------------------------------------------------
procedure TCAFReport.CreateQRCode(aCanvas : TCanvas; aDestRect : TRect);
 {$IFNDEF PRACTICE-7}
const
  BLANK_YEAR = 1899;
var
  CafQrCode  : TCafQrCode;
  CAFQRData  : TCAFQRData;
  CAFQRDataAccount : TCAFQRDataAccount;
  QrCodeImage : TImage;
  InstIndex : integer;
  Day, Month, Year : word;
{$ENDIF}
begin
  // Check if the Mapping File is set to ignore Validation
  if (Values.cmbInstitution.ItemIndex > 0) and
     (Assigned(Values.cmbInstitution.Items.Objects[Values.cmbInstitution.ItemIndex])) and
     (Values.cmbInstitution.Items.Objects[Values.cmbInstitution.ItemIndex] is TInstitutionItem) then
  begin
    if (TInstitutionItem(Values.cmbInstitution.Items.Objects[Values.cmbInstitution.ItemIndex]).IgnoreValidation) or
       (TInstitutionItem(Values.cmbInstitution.Items.Objects[Values.cmbInstitution.ItemIndex]).NoValidationRules) then
      Exit;
  end;

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
        InstIndex := Values.cmbInstitution.ItemIndex;
        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtNameOfAccount1.text;
        if Institutions.DoInstituionExceptionCode(Values.AccountNumber1,
                                                  TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).Code) = ieBOQ then
          CAFQRDataAccount.AccountNumber := Institutions.PadQueensLandAccWithZeros(Values.AccountNumber1)
        else
          CAFQRDataAccount.AccountNumber := Values.AccountNumber1;

        CAFQRDataAccount.ClientCode    := Values.edtClientCode1.Text;
        CAFQRDataAccount.CostCode      := Values.edtCostCode1.Text;
        CAFQRDataAccount.SMSF          := 'N';

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtNameOfAccount2.text;
        if Institutions.DoInstituionExceptionCode(Values.AccountNumber2,
                                                  TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).Code) = ieBOQ then
          CAFQRDataAccount.AccountNumber := Institutions.PadQueensLandAccWithZeros(Values.AccountNumber2)
        else
          CAFQRDataAccount.AccountNumber := Values.AccountNumber2;
        CAFQRDataAccount.ClientCode    := Values.edtClientCode2.Text;
        CAFQRDataAccount.CostCode      := Values.edtCostCode2.Text;
        CAFQRDataAccount.SMSF          := 'N';

        CAFQRDataAccount := TCAFQRDataAccount.Create(CAFQRData);
        CAFQRDataAccount.AccountName   := Values.edtNameOfAccount3.text;
        if Institutions.DoInstituionExceptionCode(Values.AccountNumber3,
                                                  TInstitutionItem(Values.cmbInstitution.Items.Objects[InstIndex]).Code) = ieBOQ then
          CAFQRDataAccount.AccountNumber := Institutions.PadQueensLandAccWithZeros(Values.AccountNumber3)
        else
          CAFQRDataAccount.AccountNumber := Values.AccountNumber3;
        CAFQRDataAccount.ClientCode    := Values.edtClientCode3.Text;
        CAFQRDataAccount.CostCode      := Values.edtCostCode3.Text;
        CAFQRDataAccount.SMSF          := 'N';

        // Always set day to 1 for Caf
        DecodeDate(Values.edtClientStartDte.AsDateTime, Year, Month, Day);

        if Year = BLANK_YEAR then
          DecodeDate(now(), Year, Month, Day);

        CAFQRData.StartDate := EncodeDate(Year, Month, 1);

        CAFQRData.PracticeCode        := Values.PracticeCode;
        CAFQRData.PracticeCountryCode := CountryText(AdminSystem.fdFields.fdCountry);

        CAFQRData.SetProvisional(Values.InstitutionType = inOther);

        CAFQRData.Frequency := 'D';
        CAFQRData.TimeStamp := Now;

        // Institution Code and Country
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
