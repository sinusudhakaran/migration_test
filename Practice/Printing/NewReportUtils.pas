unit NewReportUtils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Provides additional utility routines for creating a report
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  Classes,
  ReportTypes,
  Graphics,
  NewReportObj,
  repcols,
  SYDEFS;

function AddJobHeader(CurrJob : TBKReport;
                      AStyle: TStyleTypes;
                      Caption : string;
                      NewLine : boolean;
                      Align   : TJustifyType = jtCenter;
                      WrapHeader: boolean = false): THeaderFooterLine; overload;

function AddJobHeader(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean;
                       WrapHeader : boolean = false): THeaderFooterLine; overload;

function AddJobFooter(CurrJob : TBKReport;
                      AStyle: TStyleTypes;
                      Caption : string;
                      NewLine : boolean;
                      Align   : TJustifyType = jtCenter ): THeaderFooterLine; overload;

function AddJobFooter(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean;
                       WrapHeader : boolean = false): THeaderFooterLine; overload;


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

procedure AddCommonHeader(Job : TBKReport; ClientTitle: string = '');
procedure AddCommonFooter(Job : TBKReport);

function AlignmentToJustification(Alignment : TAlignment) : TJustifyType;

//procedure AddClientHeader(Job : TBKReport);
//procedure AddClientFooter(Job : TBKReport);
//procedure AddCodingHeader(Job : TBKReport);
//procedure AddCodingFooter(Job : TBKReport);

procedure AddPrintHeader(Job : TBKReport; Parameters : TStringList);
procedure AddPrintFooter(Job : TBKReport; Parameters : TStringList);

function  ReportStatusLine2 : string;

function AreThereAnyPrinters : boolean;

const
  // So all the left aligns and gaps are the same...
  GCLeft  = 0.01;
  GCGap   = 0.1;



var
   ShowClientNameOnReportStatus :boolean = true;

//******************************************************************************
implementation

uses
  Printers, //access to application global printer object
  SysUtils,
  WinUtils,
  GenUtils,
  BKCONST,
  Globals;  //access to myClient for Common header

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function AddJobHF(CurrJob : TBKReport;
                  Align   : TJustifyType;
                  FF      : double;
                  Caption : string;
                  NewLine : boolean;
                  HF: THeaderFooterCollection;
                  WrapHeader : boolean = false) : THeaderFooterLine; overload;

begin
    Result := THeaderFooterLine.Create;
    with Result do begin
       Alignment := Align;
       FontFactor := FF;
       Text := Caption;
       DoNewLine := NewLine;
       WrapTextOn := WrapHeader;
    end;        { with }
    HF.Insert(Result);
end;

function AddJobHF(CurrJob : TBKReport;
                  AStyle: TStyleTypes;
                  Caption : string;
                  NewLine : boolean;
                  HF: THeaderFooterCollection;
                  anAlign : TJustifyType = jtCenter;
                  WrapHeader : boolean = false) : THeaderFooterLine; overload;
begin
    Result := THeaderFooterLine.Create;

    CurrJob.ReportStyle.Items[AStyle].AssignTo(Result);
    with Result do begin
       ReportStyle := AStyle;
       if anAlign <> jtCenter then
          Alignment := anAlign;
       Text := Caption;
       DoNewLine := NewLine;
       WrapTextOn := WrapHeader;
    end;        { with }
    HF.Insert(Result);
end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AddJobFooter(CurrJob : TBKReport;
                       AStyle: TStyleTypes;
                       Caption : string;
                       NewLine : boolean;
                       Align   : TJustifyType = jtCenter) : THeaderFooterLine;
begin
  Result := AddJobHF(CurrJob, AStyle, Caption, NewLine,CurrJob.Footer,Align);
end;

function AddJobFooter(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean;
                       WrapHeader : boolean = false) : THeaderFooterLine;

begin
  Result := AddJobHF(CurrJob, Align, FF, Caption,NewLine,CurrJob.Footer,WrapHeader);
end;

function AddJobHeader(CurrJob : TBKReport;
                      AStyle: TStyleTypes;
                      Caption : string;
                      NewLine : boolean;
                      Align   : TJustifyType = jtCenter;
                      WrapHeader: boolean = false) : THeaderFooterLine;
begin
  Result := AddJobHF(CurrJob, AStyle, Caption, NewLine,CurrJob.Header,Align, WrapHeader);
end;

function AddJobHeader(CurrJob : TBKReport;
                       Align   : TJustifyType;
                       FF      : double;
                       Caption : string;
                       NewLine : boolean;
                       WrapHeader : boolean = false) : THeaderFooterLine;

begin
  Result := AddJobHF(CurrJob, Align, FF, Caption,NewLine,CurrJob.Header,WrapHeader);
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
  if widthp <= 0 then
    widthp := 100.0 - (Currgap + Currleft);
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
  if widthp <= 0 then
    widthp := 100.0 - (Currgap + Currleft);
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
  if widthp <= 0 then
    widthp := 100.0 - (Currgap + Currleft);
  result := AddJobAverageColumn(CurrJob,Leftp,widthP,caption,align,format,tFormat,DoTotal,QuanCol,ValCol);
  CurrLeft := CurrLeft+WidthP+CurrGap;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddCommonHeader(Job : TBKReport; ClientTitle: string = '');
var
   TextLines: TStringList;
   i: Integer;
   HFLine: THeaderFooterLine;
   DidTypeHeader: Boolean;
   SuppressHeaderFooter: Byte;
begin
  SuppressHeaderFooter := CurrUser.SuppressHeaderFooter;

   DidTypeHeader := False;
   if {Job.ReportTypeParams.HF_Enabled} True then begin
      //Print User Defined Header Logo
      if (Job.ReportTypeParams.H_LogoFile <> '') and (SuppressHeaderFooter<>shfChecked) then begin
         AddJobHeader(Job,
            AlignmentToJustification(Job.ReportTypeParams.H_LogoFileAlignment),
            1, '<IMG '+ReportTypeNames[Job.ReportType]  +'_HEADER>', True).UserLine := True;
         DidTypeHeader := True;
      end;
      //Print User Defined Header Title
      if (Job.ReportTypeParams.H_Title <> '') and (SuppressHeaderFooter<>shfChecked) then begin
         // May need a gap to seperate from logo...
         if (Job.ReportTypeParams.H_TitleColor <> clNone)
         and DidTypeHeader then
            AddJobHeader(Job, jtLeft, 0.6, '', True).UserLine := True;
         DidTypeHeader := true;

         TextLines := TStringList.Create;
         try  // Is Wrong.. Title is one line...
            TextLines.Text := Job.ReportTypeParams.H_Title;
            for i := 0 to TextLines.Count - 1 do begin
               HFLine := THeaderFooterLine.Create;
               with HFLine do begin
                  UserLine := True;
                  Alignment := AlignmentToJustification(Job.ReportTypeParams.H_TitleAlignment );
                  Font.Assign(Job.ReportTypeParams.H_TitleFont);
                  LineType := hftCustom;
                  FontFactor := 0;
                  Text := TextLines[i];
                  DoNewLine := True;
                  WrapTextOn := True;
                  LineType := hftUnwrapped; //will be split into wrapped lines
                  if Job.ReportTypeParams.H_TitleColor <> clNone then begin
                     if DidTypeHeader then
                        AddJobHeader(Job, jtLeft, 0.6, '', True);
                     HFLine.Style.BackColor := Job.ReportTypeParams.H_TitleColor;
                  end;

               end;        { with }
               Job.AddHeader(HFLine);
            end;
         finally
            TextLines.Free;
         end;

      end;
      //Print User Defined Header Text
      if (Job.ReportTypeParams.H_Text <> '') and (SuppressHeaderFooter<>shfChecked) then begin
         if (Job.ReportTypeParams.H_TextColor <> clNone)
         and (Job.ReportTypeParams.H_LogoFile <> '')
         and (Job.ReportTypeParams.H_Title = '') then //add gap
            AddJobHeader(Job, jtLeft, 0.6, '', True).UserLine := True;;

         TextLines := TStringList.Create;
         try
            TextLines.Text := Job.ReportTypeParams.H_Text;
            DidTypeHeader := True;
            for i := 0 to TextLines.Count - 1 do begin
               HFLine := THeaderFooterLine.Create;
               with HFLine do begin
                  UserLine := True;
                  Alignment := AlignmentToJustification(Job.ReportTypeParams.H_TextAlignment );
                  Font.Assign(Job.ReportTypeParams.H_TextFont);
                  LineType := hftCustom;
                  FontFactor := 0;
                  Text := TextLines[i];
                  DoNewLine := True;
                  WrapTextOn := True;
                  LineType := hftUnwrapped; //will be split into wrapped lines
                  if Job.ReportTypeParams.H_TextColor <> clNone then
                     HFLine.Style.BackColor := Job.ReportTypeParams.H_TextColor;
               end;        { with }
               Job.AddHeader(HFLine);
            end;
         finally
            TextLines.Free;
         end;

      end;
      if DidTypeHeader then
        //Add a blank line to seperate custom header
        AddJobHeader( Job, jtLeft, 0.6, '', True).UserLine := True;
  end;
  if ClientTitle > '' then
     AddJobHeader(Job,siClientName,ClientTitle,True)
  else if Assigned(MyClient) then begin
     AddJobHeader(Job,siClientName,MyClient.clFields.clName,True);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddCommonFooter(Job : TBKReport);
var
   TextLines: TStringList;
   i: Integer;
   HFLine: THeaderFooterLine;
   DidFooterSpace: Boolean;
   SuppressHeaderFooter: Byte;
begin
  SuppressHeaderFooter := CurrUser.SuppressHeaderFooter;

   DidFooterSpace := False;
   if (SuppressHeaderFooter<>shfChecked) then begin
      if (Job.ReportTypeParams.HasCustomFooter) then begin
         AddJobFooter( Job, jtLeft, 1, '<RTFFOOTER>', True).UserLine := True;
      end;
      //report footer text
      if (Job.ReportTypeParams.F_Text <> '') then begin
         //Add a blank line to seperate custom header
         AddJobFooter( Job, jtLeft, 0.6, '', True).UserLine := True;
         DidFooterSpace := True;
         TextLines := TStringList.Create;
         try
            TextLines.Text := Job.ReportTypeParams.F_Text;

            for i := 0 to TextLines.Count - 1 do begin
               HFLine := THeaderFooterLine.Create;
               with HFLine do begin
                  Alignment := AlignmentToJustification(Job.ReportTypeParams.F_TextAlignment);
                  UserLine := True;
                  Font.Assign(Job.ReportTypeParams.F_TextFont);
                  FontFactor := 0;
                  Text := TextLines[i];
                  DoNewLine := True;
                  WrapTextOn := True;
                  LineType := hftUnwrapped; //will be split into wrapped lines
                  if Job.ReportTypeParams.F_TextColor <> clNone then begin
                     HFLine.Style.BackColor := Job.ReportTypeParams.F_TextColor;
                     DidFooterSpace := False; // need a gap
                  end;
               end;        { with }
               Job.AddFooter(HFLine);
            end;
         finally
            TextLines.Free;
         end;
      end;
      //report footer logo
      if (Job.ReportTypeParams.F_LogoFile <> '') and (SuppressHeaderFooter<>shfChecked) then begin
         if not DidFooterSpace then
            AddJobFooter( Job, jtLeft, 0.6, '', True).UserLine := True;

         AddJobFooter(Job,
            AlignmentToJustification(Job.ReportTypeParams.F_LogoFileAlignment),
            1, '<IMG '+ReportTypeNames[Job.ReportType]  +'_FOOTER>', True).UserLine := True;
      end;
  end;

  if Job.ReportTypeParams.HasFooterText then begin
     if not Job.IsAdmin then
        AddJobFooter(Job,siFooter,Job.ReportTypeParams.GetClientText, False,jtleft);
     AddJobFooter(Job,siFooter,Job.ReportTypeParams.GetPageText, False).BackFilled := not Job.IsAdmin;
     AddJobFooter(Job,siFooter,Job.ReportTypeParams.GetPrintedText,True,jtRight).BackFilled := True;
  end;


  if Globals.INI_ShowVersionInFooter then
     AddJobFooter( Job, jtLeft, 0.8, APPTITLE + ' ' + WinUtils.GetAppYearVersionStr, true, false);

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AlignmentToJustification(Alignment : TAlignment) : TJustifyType;
begin
  //nice of them to be different :(
  //TAlignment = (taLeftJustify, taRightJustify, taCenter);
  //TJustifyType = (jtLeft, jtCenter, jtRight)
  case TAlignment(Alignment) of
    taLeftJustify : Result := jtLeft;
    taRightJustify : Result := jtRight;
    taCenter : Result := jtCenter;
  else
    Result := jtLeft;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(*
procedure AddClientHeader(Job : TBKReport);
var
  Parameters : TStringList;
begin
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdClient_Report_Header_Footer) then
  begin
    Parameters := TStringList.Create;
    try
      Parameters.Add('CLIENT');
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Header_Logo_File);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdClient_Report_Header_Logo_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Header_Title);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdClient_Report_Header_Title_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Header_Title_Font);
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Header_Text);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdClient_Report_Header_Text_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Header_Text_Font);

      AddPrintHeader(Job, Parameters);
    finally
      Parameters.Free;
    end;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddClientFooter(Job : TBKReport);
var
  Parameters : TStringList;
begin
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdClient_Report_Header_Footer) then
  begin
    Parameters := TStringList.Create;
    try
      Parameters.Add('CLIENT');
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Footer_Logo_File);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdClient_Report_Footer_Logo_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Footer_Text);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdClient_Report_Footer_Text_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdClient_Report_Footer_Text_Font);

      AddPrintFooter(Job, Parameters);
    finally
      Parameters.Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddCodingHeader(Job : TBKReport);
var
  Parameters : TStringList;
begin
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Report_Header_Footer) then
  begin
    Parameters := TStringList.Create;
    try
      Parameters.Add('CODING');
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Header_Logo_File);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdCoding_Report_Header_Logo_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Header_Title);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdCoding_Report_Header_Title_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Header_Title_Font);
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Header_Text);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdCoding_Report_Header_Text_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Header_Text_Font);

      AddPrintHeader(Job, Parameters);
    finally
      Parameters.Free;
    end;
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddCodingFooter(Job : TBKReport);
var
  Parameters : TStringList;
begin
  if Assigned(AdminSystem) and (AdminSystem.fdFields.fdCoding_Report_Header_Footer) then
  begin
    Parameters := TStringList.Create;
    try
      Parameters.Add('CODING');
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Footer_Logo_File);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdCoding_Report_Footer_Logo_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Footer_Text);
      Parameters.Add(IntToStr(AdminSystem.fdFields.fdCoding_Report_Footer_Text_Alignment));
      Parameters.Add(AdminSystem.fdFields.fdCoding_Report_Footer_Text_Font);

      AddPrintFooter(Job, Parameters);
    finally
      Parameters.Free;
    end;
  end;
end;
*)
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddPrintHeader(Job : TBKReport; Parameters : TStringList);
const
  Header_Report_Type = 0;
  Header_Logo_File = 1;
  Header_Logo_Alignment = 2;
  Header_Title = 3;
  Header_Title_Alignment = 4;
  Header_Title_Font = 5;
  Header_Text = 6;
  Header_Text_Alignment = 7;
  Header_Text_Font = 8;
var
  JustifyType : TJustifyType;
  TextLines: TStringList;
  i : Integer;
  HFLine : THeaderFooterLine;
begin
  //report header logo
  if (Parameters[Header_Logo_File] <> '') then
  begin
    JustifyType := AlignmentToJustification(TAlignment(StrToInt(Parameters[Header_Logo_Alignment])));
    AddJobHeader(Job, JustifyType, 1, '<IMG '+Parameters[Header_Report_Type]+'_HEADER>', True);
  end;
  //report header title
  if (Parameters[Header_Title] <> '') then
  begin
    JustifyType := AlignmentToJustification(TAlignment(StrToInt(Parameters[Header_Title_Alignment])));
    HFLine := THeaderFooterLine.Create;
    with HFLine do
    begin
      Alignment := JustifyType;

      if (Parameters[Header_Title_Font] <> '') then
         StrToFont(Parameters[Header_Title_Font],Font);

      FontFactor := 0;
      Text := Parameters[Header_Title];
      DoNewLine := True;
      LineType := hftCustom;
    end;        { with }
    Job.AddHeader(HFLine);
  end;

  //report header text
  if (Parameters[Header_Text] <> '') then
  begin
    JustifyType := AlignmentToJustification(TAlignment(StrToInt(Parameters[Header_Text_Alignment])));
    TextLines := TStringList.Create;
    try
      TextLines.Text := Parameters[Header_Text];
      for i := 0 to TextLines.Count - 1 do
      begin
        HFLine := THeaderFooterLine.Create;
        with HFLine do
        begin
          Alignment := JustifyType;

          if (Parameters[Header_Text_Font] <> '') then
             StrToFont(Parameters[Header_Text_Font],Font);

          FontFactor := 0;
          Text := TextLines[i];
          DoNewLine := True;
          WrapTextOn := True;
          LineType := hftUnwrapped; //will be split into wrapped lines
        end;        { with }
        Job.AddHeader(HFLine);
      end;
    finally
      TextLines.Free;
    end;
    //Add a blank line to seperate custom header
    AddJobHeader( Job, jtLeft, 0.6, '', True);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure AddPrintFooter(Job : TBKReport; Parameters : TStringList);
const
  Footer_Report_Type = 0;
  Footer_Logo_File = 1;
  Footer_Logo_Alignment = 2;
  Footer_Text = 3;
  Footer_Text_Alignment = 4;
  Footer_Text_Font = 5;
var
  JustifyType : TJustifyType;
  TextLines: TStringList;
  i : Integer;
  HFLine : THeaderFooterLine;
begin
  //report footer text
  if (Parameters[Footer_Text] <> '') then
  begin
    //Add a blank line to seperate custom header
    AddJobHeader( Job, jtLeft, 0.6, '', True);

    JustifyType := AlignmentToJustification(TAlignment(StrToInt(Parameters[Footer_Text_Alignment])));
    TextLines := TStringList.Create;
    try
      TextLines.Text := Parameters[Footer_Text];

      for i := 0 to TextLines.Count - 1 do
      begin
        HFLine := THeaderFooterLine.Create;
        with HFLine do
        begin
          Alignment := JustifyType;

          if (Parameters[Footer_Text_Font] <> '') then
             StrToFont(Parameters[Footer_Text_Font],Font);

          FontFactor := 0;
          Text := TextLines[i];
          DoNewLine := True;
          WrapTextOn := True;
          LineType := hftUnwrapped; //will be split into wrapped lines
        end;        { with }
        Job.AddFooter(HFLine);
      end;
    finally
      TextLines.Free;
    end;
  end;
  //report footer logo
  if (Parameters[Footer_Logo_File] <> '') then
  begin
    JustifyType := AlignmentToJustification(TAlignment(StrToInt(Parameters[Footer_Logo_Alignment])));
    AddJobFooter(Job, JustifyType, 1, '<IMG '+Parameters[Footer_Report_Type]+'_FOOTER>', True);
  end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function  ReportStatusLine2 : string;
begin
  result := '';
  if ShowClientNameOnReportStatus and Assigned(MyClient) then
     result := MyClient.clExtendedName;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function AreThereAnyPrinters : boolean;
begin
  result := Printer.Printers.Count > 0;  {see if global printer object contains any printers}
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
