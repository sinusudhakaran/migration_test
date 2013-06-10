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

interface
uses
  ReportDefs,
  ReportTypes,
  bkUrls;

function DoInvoiceReport( Dest : TReportDest; Doc: string; SourceFilename : string; DestFilename : string = '') : boolean;
//convert a reports.000 file into a document


//******************************************************************************
implementation
uses
  RptParams,
  SysUtils, Classes, htmlUtils, NewReportObj, Globals, Graphics, NewReportUtils,
  repcols, reportImages, imagesfrm, bkConst,  jsFastHTMLParser, ErrorMoreFrm,
  bkProduct,
  bkBranding;

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
    procedure WantNewpage;   
  protected
    procedure BillingReportTagFound(Sender: TObject; Tag: string);
    procedure BillingReportTextFound(Sender: TObject; Text: string);

    procedure SetStyle( aStyle : TLineStyle);
  end;


procedure ReplaceSpecialChars( var original : string);
//replace special strings in the html with their original characters
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

{ TBillingReport }
procedure TBillingReport.SetStyle(aStyle: TLineStyle);
begin
  (*
  case aStyle of
    lsNormal : UseCustomFont( 'Times New Roman', 10, [], 42);
    lsFixedWidth : UseCustomFont( 'Courier New', 10, [], 40);
    lsBig : UseCustomFont( 'Times New Roman', 15, [ fsBold], 70);
    lsBold : UseCustomFont( 'Times New Roman', 10, [ fsBold], 46);
    lscode : UseCustomFont( 'Lucida Console', 8, [], 31);
    lsSmall : UseCustomFont( 'Courier New', 8, [], 35);
  end;
  *)
  case aStyle of
    lsNormal : UseCustomFont( 'Times New Roman', 8, [], 0);
    lsFixedWidth : UseCustomFont( 'Courier New', 8, [], 34);
    lsBig : UseCustomFont( 'Times New Roman', 13, [ fsBold], 0);
    lsBold : UseCustomFont( 'Times New Roman', 8, [ fsBold], 0);
    lscode : UseCustomFont( 'Lucida Console',6, [], 0);
    lsSmall : UseCustomFont( 'Courier New', 6, [], 0);
  end;

end;

procedure TBillingReport.WantNewpage;
begin
   fNewPage := true;
end;

procedure TBillingReport.BillingReportTagFound(Sender: TObject;
  Tag: string);
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
      RenderTextLine(OutputText);
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

procedure GenerateReportDetail(Sender : TObject);
var
  BillingReport : TBillingReport;
  Parser : tjsFastHTMLParser;
begin
  //parse lines and show on report
  BillingReport := TBillingReport( Sender);
  BillingReport.BodyFound := false;
  BillingReport.OutputText := '';
  BillingReport.CurrentStyle := lsNormal;

  Parser := tjsFastHTMLParser.Create(Pchar( BillingReport.ReportDetail.Text));
  try
    Parser.OnFoundTag := BillingReport.BillingReportTagFound;
    Parser.OnFoundText := BillingReport.BillingReportTextFound;
    Parser.Execute;
  finally
    Parser.Free;
  end;
end;

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
      Job.ReportStyle.Name := '';
      Job.ReportStyle.Load;
      htmlStream.Position := 0;
      ReportLines.LoadFromStream( htmlStream);

      //can now parse the header of the stream to extract the banklink billing
      //address details and encoded logo
      Job.bkHtmlVersion := 1;
      Job.bkHtmlSubVersion := 1;  //1.1

      if TProduct.ProductBrand <> btBankstream then
      begin
        NzFooter := 'BankLink New Zealand PO Box 56-354 Dominion Rd Auckland NZ. Freephone 0800 226 554 Fax 09 630 2759 www.banklink.co.nz';
        AuFooter := 'BankLink Australia GPO Box 4608 Sydney NSW 2001 Australia. Freephone 1800 123 242 Freefax 1800 123 807 www.banklink.com.au';
      end
      else
      begin
        UKFooter := TProduct.BrandName + ' United Kingdom 9 Devonshire Square, London EC2M 4YF. Freephone 0800 500 3084 ' + TUrls.WebSites[whUK];
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

      AddPictureToReportImageList( Logo, 'banklink_logo', 56, 15);

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
