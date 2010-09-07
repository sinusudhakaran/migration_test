unit NewReportUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Provides additional utility routines for creating a report and checking printer
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
  ECReportObj,
  repcols,
  ecReportDefs;

procedure AddJobHeader(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);

procedure AddJobFooter(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);

function AddJobColumn(CurrJob : TBKReport;
                       LeftP   : double;
                       WidthP  : double;
                       CCaption : string;
                       Align   : TJustifyType) : TReportColumn;

function AddColAuto(CurrJob : TBKReport;
                     var CurrLeft : double;
                     WidthP : double;
                     CurrGap : double;
                     Caption : string;
                     Align : TJustifyType) : TReportColumn;

function AddJobFormatColumn(CurrJob : TBKReport;
                             LeftP   : double;
                             WidthP  : double;
                             CCaption : string;
                             Align   : TJustifyType;
                             Format  : string;
                             TFormat : string;
                             DoTotal : boolean) : TReportColumn;

function AddJobAverageColumn(CurrJob : TBKReport;
                             LeftP   : double;
                             WidthP  : double;
                             CCaption : string;
                             Align   : TJustifyType;
                             Format  : string;
                             TFormat : string;
                             DoTotal : boolean;
                             QuanCol : TReportColumn;
                             ValCol  : TReportColumn) : TReportColumn;

function AddAverageColAuto(CurrJob : TBKReport;
                          var CurrLeft : double;
                          WidthP : double;
                          CurrGap : double;
                          Caption : string;
                          Align : TJustifyType;
                          Format  : string;
                          TFormat : string;
                          DoTotal : boolean;
                          QuanCol : TReportColumn;
                          ValCol  : TReportColumn) : TReportColumn;

function AddFormatColAuto(CurrJob : TBKReport;
                          var CurrLeft : double;
                          WidthP : double;
                          CurrGap : double;
                          Caption : string;
                          Align : TJustifyType;
                          Format  : string;
                          TFormat : string;
                          DoTotal : boolean) : TReportColumn;

procedure AddCommonHeader(Job : TBKReport);

function  ReportStatusLine2 : string;

function  AreThereAnyPrinters : boolean;

function  FindPrinterIndex(DeviceName : string) : integer;

function  FindPrinterDeviceName(index : integer) : string;

//******************************************************************************
implementation
uses
   Printers, //access to application global printer object
   SysUtils,
   PrntInfo;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddJobHeader(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);
var
    HFLine : THeaderFooterLine;
begin
    HFLine := THeaderFooterLine.Create;
    with HFLine do
    begin
      Alignment := Align;
      FontFactor := FF;
      Text := Caption;
      DoNewLine := NewLine;
     end;        { with }
     CurrJob.AddHeader(HFLine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddJobFooter(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean);
var
    HFLine : THeaderFooterLine;
begin
    HFLine := THeaderFooterLine.Create;
    with HFLine do
    begin
      Alignment := Align;
      FontFactor := FF;
      Text := Caption;
      DoNewLine := NewLine;
     end;        { with }
     CurrJob.AddFooter(HFLine);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddJobColumn(CurrJob : TBKReport;
                       LeftP   : double;
                       WidthP  : double;
                       CCaption : string;
                       Align   : TJustifyType) : TReportColumn;
var
    ACol   : TReportColumn;
begin
   {Init Report Columns}
    ACol := TReportColumn.Create;
    with ACol do begin
       LeftPercent := Leftp;
       WidthPercent := Widthp;
       Caption := CCaption;
       Alignment := Align;
    end;        { with }
    CurrJob.AddColumn(ACol);
    result := ACol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddColAuto(CurrJob : TBKReport;
                     var CurrLeft : double;
                     WidthP : double;
                     CurrGap : double;
                     Caption : string;
                     Align : TJustifyType) : TReportColumn;
var
  LeftP : double;
begin
  LeftP := CurrLeft;
  result := AddJobColumn(CurrJob,Leftp,widthP,caption,align);
  CurrLeft := CurrLeft+WidthP+CurrGap;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddJobFormatColumn(CurrJob : TBKReport;
                             LeftP   : double;
                             WidthP  : double;
                             CCaption : string;
                             Align   : TJustifyType;
                             Format  : string;
                             TFormat : string;
                             DoTotal : boolean) : TReportColumn;
var
    ACol   : TReportColumn;
begin
   {Init Report Columns}
    ACol := TReportColumn.Create;
    with ACol do begin
       LeftPercent := Leftp;
       WidthPercent := Widthp;
       Caption := CCaption;
       Alignment := Align;
       isTotalCol := DoTotal;
       FormatString := Format;
       TotalFormat  := tFormat;
    end;        { with }
    CurrJob.AddColumn(ACol);
    result := ACol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddFormatColAuto(CurrJob : TBKReport;
                          var CurrLeft : double;
                          WidthP : double;
                          CurrGap : double;
                          Caption : string;
                          Align : TJustifyType;
                          Format  : string;
                          TFormat : string;
                          DoTotal : boolean) : TReportColumn;
var
  LeftP : double;
begin
  LeftP := CurrLeft;
  result := AddJobFormatColumn(CurrJob,Leftp,widthP,caption,align,format,tFormat,DoTotal);
  CurrLeft := CurrLeft+WidthP+CurrGap;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddJobAverageColumn(CurrJob : TBKReport;
                             LeftP   : double;
                             WidthP  : double;
                             CCaption : string;
                             Align   : TJustifyType;
                             Format  : string;
                             TFormat : string;
                             DoTotal : boolean;
                             QuanCol : TReportColumn;
                             ValCol  : TReportColumn) : TReportColumn;
var
    ACol   : TReportColumn;
begin
   {Init Report Columns}
    ACol := TReportColumn.Create;
    with ACol do begin
       LeftPercent := Leftp;
       WidthPercent := Widthp;
       Caption := CCaption;
       Alignment := Align;
       isTotalCol := DoTotal;
       FormatString := Format;
       TotalFormat  := tFormat;
       ColQuantity  := QuanCol;
       ColValue     := ValCol;
    end;        { with }
    CurrJob.AddColumn(ACol);
    result := ACol;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddAverageColAuto(CurrJob : TBKReport;
                          var CurrLeft : double;
                          WidthP : double;
                          CurrGap : double;
                          Caption : string;
                          Align : TJustifyType;
                          Format  : string;
                          TFormat : string;
                          DoTotal : boolean;
                          QuanCol : TReportColumn;
                          ValCol  : TReportColumn) : TReportColumn;
var
  LeftP : double;
begin
  LeftP := CurrLeft;
  result := AddJobAverageColumn(CurrJob,Leftp,widthP,caption,align,format,tFormat,DoTotal,QuanCol,ValCol);
  CurrLeft := CurrLeft+WidthP+CurrGap;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddCommonHeader(Job : TBKReport);
begin
//     AddJobHeader(Job,jtLeft,0.8, 'DATE  <DATE>',true);
//     AddJobHeader(Job,jtCenter,1.2,MyClient.clFields.clName,true);
//     AddJobFooter(Job,jtLeft,0.8,'CODE: '+MyClient.clFields.clCode,false);
     AddJobFooter(Job,jtCenter,0.8,'PAGE  <PAGE>',false);
     AddJobFooter(Job,jtRight,0.8,'Printed ' + DateTimeToStr(Now), true);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  ReportStatusLine2 : string;
begin
  result := '';
//  if ShowClientNameOnReportStatus and Assigned(MyClient) then
//     result := MyClient.clExtendedName;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AreThereAnyPrinters : boolean;
begin
  result := Printer.Printers.Count > 0;  {see if global printer object contains any printers}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FindPrinterIndex(DeviceName : string) : integer;
var
  i : integer;
begin
   result := -1; {default}
   if (DeviceName = DEFAULT_PRINTER_ID) then exit;

   for i := 0 to Pred(Printer.Printers.Count) do
     if (GetPrinterName(i) = DeviceName) then
     begin
       result := i;
       break;
     end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function FindPrinterDeviceName(index : integer) : string;
var
  DName : string;
begin
   result := DEFAULT_PRINTER_ID;
   if (index = -1) then exit;

   dName := GetPrinterName(index);
   if dName <> '' then
     result := dNAme;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.
