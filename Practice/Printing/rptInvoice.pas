unit rptInvoice;
//------------------------------------------------------------------------------
{
   Title:        BankLink Invoice Report

   Description:  Converts the Reports.xxx file into a pdf document

   Author:       Matthew Hopkins Aug 2005

   Remarks:      First converts any old format disk images into the html format
                 Contain a very rudimentary html parser, ie will only work if the
                 documents are in expected format

                 Note: each line can only be rendered with one font per line

                 Uses a freeware html parser  jsHTMLUtil
   Revisions:

}

//------------------------------------------------------------------------------
//NOTE : Any changes made here should be checked with Core Statements, we both print the same doc
//------------------------------------------------------------------------------
interface

uses
  ReportDefs,
  ReportTypes,
  RptParams,
  SysUtils,
  Classes,
  htmlUtils,
  NewReportObj,
  Globals,
  Graphics,
  NewReportUtils,
  ReportToCanvas,
  repcols,
  reportImages,
  imagesfrm,
  bkConst,
  jsFastHTMLParser,
  ErrorMoreFrm,
  bkProduct,
  Windows,
  bkBranding,
  bkUrls,
  GenUtils;

type
  TLineStyle = ( lsNone, lsNormal, lsFixedWidth, lsCode, lsNewPage, lsBig, lsBold, lsSmall);

type
  TBillingReport = class( TbkReport)
  private
    BodyFound : boolean;
    OutputText : string;
    CurrentStyle : TLineStyle;
    ReportDetail : TStringList;
    bkHtmlVersion : byte;
    bkHtmlSubVersion : byte;
    fNewPage: boolean;

    fCurrYPos : integer;
    fCurrLineSize : int64;

    procedure ReplaceSpecialChars( var original : string);
    procedure UpdateCurrentLineSize();
    procedure NextLine();

    procedure RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);

    procedure WantNewpage;
    function GetCanvasRE: TRenderToCanvasEng;
  protected
    procedure BillingReportTagFound(Sender: TObject; Tag: string);
    procedure BillingReportTextFound(Sender: TObject; Text: string);

    procedure SetStyle( aStyle : TLineStyle);

    property CanvasRenderEng : TRenderToCanvasEng read GetCanvasRE;

  public
    property CurrYPos : integer read fCurrYPos write fCurrYPos;
    property CurrLineSize : int64 read fCurrLineSize write fCurrLineSize;
  end;

  function DoInvoiceReport( Dest : TReportDest; Doc: string; SourceFilename : string; DestFilename : string = '') : boolean;

//------------------------------------------------------------------------------
//NOTE : Any changes made here should be checked with Core Statements, we both print the same doc
//------------------------------------------------------------------------------
implementation

const
  PAGE_TEXT_START = 200;

//------------------------------------------------------------------------------
{ TBillingReport }
//replace special strings in the html with their original characters
procedure TBillingReport.ReplaceSpecialChars( var original : string);
var
  s : string;
begin
  s := Original;
  s := StringReplace( s, '&quot;', '"', [ rfReplaceAll]);
  s := StringReplace( s, '&amp;', '&', [ rfReplaceAll]);
  s := StringReplace( s, '&lt;', '<', [ rfReplaceAll]);
  s := StringReplace( s, '&gt;', '>', [ rfReplaceAll]);
  Original := s;
end;

//------------------------------------------------------------------------------
procedure TBillingReport.SetStyle(aStyle: TLineStyle);
begin
  case aStyle of
    lsNormal     : UseCustomFont( 'Times New Roman', 10, [], 0);
    lsFixedWidth : UseCustomFont( 'Courier New',     10,  [], 34);
    lsBig        : UseCustomFont( 'Times New Roman', 15, [fsBold], 0);
    lsBold       : UseCustomFont( 'Times New Roman', 10, [fsBold], 0);
    lscode       : UseCustomFont( 'Lucida Console',  7,  [], 0);
    lsSmall      : UseCustomFont( 'Courier New',     8,  [], 0);
  end;
  UpdateCurrentLineSize();
end;

//------------------------------------------------------------------------------
procedure TBillingReport.UpdateCurrentLineSize();
begin
  fCurrLineSize := Round(CanvasRenderEng.OutputBuilder.HeightOfText('A'));
end;

//------------------------------------------------------------------------------
procedure TBillingReport.NextLine();
begin
  fCurrYPos := fCurrYPos + fCurrLineSize;
end;

//------------------------------------------------------------------------------
procedure TBillingReport.RenderText(textValue: string; textRect: TRect; Justify: TJustifyType);
//Canvas Font should be set before rendering text
//Canvas color will be changed to render sytle and then reset
var
   RenderRect : TRect;
   TextWidth, TextHeight : longint;
   wasColor   : TColor;
   wasFColor  : TColor;
begin
   //process the text value looking for special markers
   if TextValue = SKIPFIELD then exit;

   with CanvasRenderEng.OutputBuilder do
   begin
       TextWidth := Canvas.TextWidth(textValue);
       TextHeight := Canvas.TextHeight(textValue) * 12 div 10;

       //convert from 0.1mm to pixels
       with TextRect do begin
          TopLeft     := ConvertToDC( TopLeft);
          BottomRight := ConvertToDC( BottomRight);
       end;        // with

       //first sort out top and bottom
       if TextHeight >= (textRect.Bottom - textRect.Top) then begin
          //Height of text is bigger than box so use top
          RenderRect.Top := textRect.Top;
          RenderRect.Bottom := textRect.Bottom;
       end
       else begin
          RenderRect.Top := textRect.Top + ((textRect.Bottom - textRect.top) - TextHeight);
          RenderRect.Bottom := textRect.Bottom;
       end;

       //now sortout left right
       if TextWidth >= (textRect.Right - textRect.Left) then  begin
          //width is greater than box so use left
          RenderRect.Left := textRect.Left;
          RenderRect.Right  := textRect.Right;
       end
       else begin
          case Ord(Justify) of
             Ord(jtLeft): begin
                RenderRect.left := textRect.Left;
                RenderRect.Right := RenderRect.Left + textwidth;
             end;
             ord(jtCenter): begin
                RenderRect.Left := textRect.Left + (textRect.Right - textRect.Left) div 2 - textwidth div 2;
                RenderRect.Right := RenderRect.Left + textwidth;
             end;
             ord(jtRight): begin
                RenderRect.Right := textRect.Right;
                RenderRect.Left := RenderRect.Right - textWidth;
             end;
          end;        // case
       end;             //begin

       //Store Current Brush Color
       wasColor := Canvas.Brush.Color;
       wasFColor := Canvas.Font.Color;

       Canvas.TextRect(RenderRect,RenderRect.Left, RenderRect.top, textValue);
       Canvas.Brush.Color := wasColor;
       Canvas.Font.Color  := wasFColor;
   end;        // with
end;

//------------------------------------------------------------------------------
procedure TBillingReport.WantNewpage;
begin
  fNewPage := true;
  fCurrYPos := PAGE_TEXT_START;
end;

//------------------------------------------------------------------------------
function TBillingReport.GetCanvasRE: TRenderToCanvasEng;
begin
  result := TRenderToCanvasEng( RenderEngine);
end;

//------------------------------------------------------------------------------
procedure TBillingReport.BillingReportTagFound(Sender: TObject; Tag: string);
begin
  if Tag = '<body>' then
  begin
    BodyFound := true;
    CurrentStyle := lsNormal;
  end;

  if BodyFound then
  begin
    //only process the following tags once we are in the body of the report
    if Tag = '<br>' then
    begin
      //remove special html strings such as &quot;
      ReplaceSpecialChars(OutputText);
      //set text to use then render the line
      if fNewPage then begin
         ReportNewPage;
         fNewPage := false;
      end;
      SetStyle(currentStyle);

      if Length(trim(OutputText)) > 0 then
      begin
        if (CurrentStyle = lsBig) then
        begin
          RenderText(' ' + TrimNonCharValues(OutputText) + ' ', Rect(CanvasRenderEng.OutputBuilder.OutputAreaLeft + 50, CurrYPos, CanvasRenderEng.OutputBuilder.OutputAreaWidth, CurrYPos + CurrLineSize), jtCenter)
        end
        else
          RenderText(OutputText + ' ', Rect(300, CurrYPos, CanvasRenderEng.OutputBuilder.OutputAreaWidth, CurrYPos + CurrLineSize), jtLeft);
      end;

      NextLine();

      //RenderTextLine(OutputText);
      OutputText := '';
    end
    else
    if Tag = '<!-- BLPrn_NewPage -->' then
      WantNewPage
    else
    if Tag = '<big>' then
      CurrentStyle := lsBig
    else
    if Tag = '<tt>' then
      CurrentStyle := lsFixedWidth
    else
    if Tag = '<b>' then
      CurrentStyle := lsBold
    else
    if Tag = '<code>' then
      CurrentStyle := lsCode
    else
    if Tag = '<small>' then
      CurrentStyle := lsSmall
    else
    if (Tag = '</big>')
    or (Tag = '</tt>')
    or (Tag = '</b>')
    or (Tag = '</code>')
    or (Tag = '</small>') then
      CurrentStyle := lsNormal;
  end;
end;

//------------------------------------------------------------------------------
procedure TBillingReport.BillingReportTextFound(Sender: TObject;
  Text: string);
var
  s : string;
begin
  if BodyFound then
  begin
    //strip any ODOA from string
    s := StringReplace( Text, #13#10 , '', [ rfReplaceAll]);
    OutputText := OutputText + s;
  end;
end;

//------------------------------------------------------------------------------
procedure GenerateReportDetail(Sender : TObject);
var
  BillingReport : TBillingReport;
  Parser : tjsFastHTMLParser;
  footerIndex : integer;
begin
  //parse lines and show on report
  BillingReport := TBillingReport( Sender);
  BillingReport.BodyFound := false;
  BillingReport.OutputText := '';
  BillingReport.CurrentStyle := lsNormal;

  for footerIndex := 0 to BillingReport.Footer.ItemCount-1 do
  begin
    BillingReport.Footer.HFLine_At(footerIndex).Font.Color := BkBranding.BankLinkColor;
    BillingReport.Footer.HFLine_At(footerIndex).Font.Size  := 7;
  end;

  Parser := tjsFastHTMLParser.Create(Pchar( BillingReport.ReportDetail.Text));
  try
    Parser.OnFoundTag := BillingReport.BillingReportTagFound;
    Parser.OnFoundText := BillingReport.BillingReportTextFound;
    Parser.Execute;
  finally
    Parser.Free;
  end;
end;

//------------------------------------------------------------------------------
function DoInvoiceReport( Dest : TReportDest; Doc: string; SourceFilename : string; DestFilename : string = '') : boolean;
//convert a reports.000 file into a document
var
  ReportLines : TStringList;
  TagStream : TFileStream;
  HtmlStream : TMemoryStream;
  Job : TBillingReport;
  Logo : TPicture;
  s : string;
  i : integer;
  EndOfHeaderFound : boolean;

  NzFooter : string;
  AuFooter : string;
  UKFooter : string;
  lParams: TRptParameters;
begin
  result := false;

  if not FileExists( sourceFilename) then
    exit;

  TagStream := TFileStream.Create( sourceFilename, fmOpenRead);
  HtmlStream := TMemoryStream.Create;
  ReportLines := TStringList.Create;
  try
    //need to determine the format of the file, only convert to html if required
    SetLength( s, 4);
    TagStream.Read( pointer(s)^, 4);
    if s = '<doc' then
    begin
      TagStream.Position := 0;
      HtmlUtils.ConvertPrintTagsToHTML_Stream( TagStream, htmlStream, SourceFilename,'doc title');
    end
    else
      HtmlStream.LoadFromStream( TagStream);

    //no longer need file stream
    FreeAndNil( TagStream);

    //create report and image list
    CreateReportImageList;
    Job := TBillingReport.Create(rptOther);
    lParams:= TRptParameters.Create(ord(Report_Billing),MyClient,nil);
    try
      //load report lines from html stream
      Job.CurrYPos := PAGE_TEXT_START;
      Job.ReportStyle.Name := '';
      Job.ReportStyle.Load;
      htmlStream.Position := 0;
      ReportLines.LoadFromStream( htmlStream);

      //can now parse the header of the stream to extract the banklink billing
      //address details and encoded logo
      Job.bkHtmlVersion := 1;
      Job.bkHtmlSubVersion := 1;  //1.1

      if TProduct.ProductBrand = btMYOBBankLink then
      begin
        NzFooter := 'MYOB BankLink New Zealand   PO Box 56-354 Dominion Rd Auckland 1446 NZ   Freephone 0800 226 554   Fax 09 623 4051   www.banklink.co.nz | www.myob.co.nz';
        AuFooter := 'MYOB BankLink Australia   GPO Box 4608 Sydney NSW 2001 Australia   Freephone 1800 123 242   Freefax 1800 123 807   www.banklink.com.au | www.myob.com.au';
      end
      else
      begin
        NzFooter := 'MYOB BankLink New Zealand PO Box 56-354 Dominion Rd Auckland NZ. Freephone 0800 226 554 Fax 09 630 2759 www.banklink.co.nz';
        AuFooter := 'MYOB BankLink Australia GPO Box 4608 Sydney NSW 2001 Australia. Freephone 1800 123 242 Freefax 1800 123 807 www.banklink.com.au';
      end;

      i := 0;
      EndOfHeaderFound := false;
      while ( i < ReportLines.Count) and ( not EndOfHeaderFound) do
      begin
        s := ReportLines[i];
        if Pos( 'Converted from', s) > 0 then
          Job.bkHtmlSubVersion := 0;

        if Pos('<!-- NZ_Addr=', s) > 0 then
        begin
           //extract text between <!-- NZ_Addr=Address goes here -->
           //                     12345678901234
           NZFooter := Copy( s, 14, length(s)-16);
        end;

        if Pos('<!-- AU_Addr=', s) > 0 then
        begin
           //extract text between <!-- AU_Addr=Address goes here -->
           //                     12345678901234
           AUFooter := Copy( s, 14, length(s)-16);
        end;

        if Pos('<!-- UK_Addr=', s) > 0 then
        begin
           //extract text between <!-- UK_Addr=Address goes here -->
           //                     12345678901234
           UKFooter := Copy( s, 14, length(s)-16);
        end;

        EndOfHeaderFound := (pos( '</head>', s) > 0);
        i := i + 1;
      end;

      //need to add the banklink logo into the report image list so can
      //display on each page
      Logo := TPicture.Create;  //will be destroyed when list is cleared

      Logo.Assign(bkBranding.ReportLogo);

      //AddPictureToReportImageList( Logo, 'banklink_logo', 56, 15);
      //AddPictureToReportImageList( Logo, 'banklink_logo', 70, 17);
      AddPictureToReportImageList( Logo, 'banklink_logo', 70, 14);

      //set up report
      Job.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_Billing]);
      Job.UserReportSettings.s7Base_Font_Name := 'Times New Roman';
      Job.UserReportSettings.s7Base_Font_Size := 9;

      //add billing header, clear the autolineSize setting so that the text
      //is rendered as if no image was expected, otherwise the first line
      //on the report will be positioned too far down the page
      AddJobHeader(Job, jtLeft, 1, '<IMG banklink_logo>', False).AutoLineSize := False;
      //add billing footer
      AddJobFooter( Job, jtCenter, 0.8,  AuFooter, true);
      AddJobFooter( Job, jtCenter, 0.8,  NzFooter, true);
      AddJobFooter( Job, jtCenter, 0.8,  UKFooter, true);
      //AddJobFooter(Job,jtCenter,0.8,'PAGE  <PAGE>',false);  Already has page numbers

      Job.ReportDetail := ReportLines;
      Job.OnBKPrint := GenerateReportDetail;

      //report will be generated as a pdf if a filename is supplied
      if DestFilename <> '' then
        result := Job.GenerateToFile( DestFilename, rfPDF)
      else
      begin
        Job.Generate(dest,lParams);
        result := true;
      end;
      if not Result then
        HelpfulErrorMsg('Error generating document "' + Doc + '".' + #13#13 +
         'Please check that the file "wPDF200A.DLL" exists on your computer.', 0);
    finally
      Job.Free;
      DestroyReportImageList;
      lParams.Free;
    end;
  finally
    FreeAndNil( ReportLines);
    HtmlStream.Free;
    TagStream.Free;
  end;
end;

end.

