unit RptStyleTest;

interface

procedure DoStyleTestReport;

implementation
uses
   ReportTypes,
   NewReportObj,
   RptParams,
   Globals,
   RepCols,
   stDate,
   Sysutils,
   bkdateutils,
   ReportDefs,
   NewReportUtils;
const
   SectionCount = 8;
   ItemCount = 15;

procedure ReportDetail(Sender:TObject);
var
   I,G: Integer;
   D: Integer;
begin
   D := CurrentDate - 60;
   with TBKReport(Sender) do begin
   for G := 0 to SectionCount do begin
      RenderTitleLine('Section Title' + intToStr(G));
      RenderTextLine ('Report Text');
      for I := 0 to ItemCount do begin
         PutString( '123456' );
         PutString( 'Description ' + intToStr(G) + '.' + intToStr(I) );
         PutString( bkDate2Str(D + I ));
         PutString( bkDate2Str(D + G - I ));
         PutCurrency( G * I );

         PutMoney( D + I);

         RenderDetailLine;
       end;

       RenderDetailSubTotal('Sub Total'+ intToStr(G));
    end;
  RenderDetailGrandTotal('Grand Total');
  end;
end;



procedure DoStyleTestReport;
var
   Job : TBKReport;
   Param : TRPTParameters;
begin
   Param := TRPTParameters.Create(ord(Report_Last),MyClient,nil);
   Job := TBKReport.Create(ReportTypes.rptOther);
   try

     Job.LoadReportSettings(UserPrintSettings,
        param.MakeRptName(  'Style Test Report'));

     //Add Headers
     AddJobHeader(Job,jtCenter,1.2,'Client Name',true);
     AddJobHeader(Job,jtCenter,1.6,'Just a Test report',true);

     {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
     AddJobColumn(Job,0.1,17 ,'Account Number',jtLeft);
     AddJobColumn(Job,19,25,'Account Name',jtLeft);
     AddJobColumn(Job,46,10,'Entries From',jtLeft);
     AddJobColumn(Job,58,10,'Entries To', jtLeft);
     AddJobFormatColumn(Job,69,10,'No. Entries',jtRight,'#,##','#,##',true);
     AddJobFormatColumn(Job,80,17,'Current Balance',jtRight,
       MoneyUtils.FmtBalanceStrNoSymbol, MoneyUtils.FmtBalanceStr( GlobalCache.cache_Country ),
       true );

     //Add Footers
     AddCommonFooter(Job);

     Job.OnBKPrint := ReportDetail;
     Job.Generate( rdScreen,Param);
   finally
    Job.Free;
    Param.Free;
   end;
end;


end.
