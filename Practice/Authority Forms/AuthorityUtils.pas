// Utility methods for CAF/TPA forms
unit AuthorityUtils;

interface

uses
   XLSFormatStr,
   XLSFile,
   XLSWorkbook,
   Variants,
   Types,
   rptGST101;

function GetTaskBarHeight: Integer;
function GetTaskBarWidth: Integer;
function IsTaskbarAutoHideOn: Boolean;
function GetTaskBarRect: TRect;
function IsTaskbarHorizontal: Boolean;

const // for reporting
   {columns specs in 0.1mm ie. 10=1mm}
   BoxMargin     = 10;
   BoxHeight     = 75;
   Col0          = 70;
   Col1          = 120;
   Col2          = 1325;
   ColBoxRight   = Col0 + 1850 + (BoxMargin*2);
   RowStart      = 100;

   BTN_IMPORT    = 7;

type
  // Report modes
  TAFMode = (AFNormal , AFEmail, AFImport);

type
  TAuthorityReport = class(TGST101Report)
  protected
    // Import Mode..
    fHeaderRow: Integer;
    fCurRow: Integer;
    fcAccountName,
    fcBSB,
    fcAccountNo,
    fcClientCode,
    fcCostCode,
    fcBank,
    fcDay,
    fcMonth,
    fcYear : Integer;
    fcProvisional, fcFrequency: integer;
    fImportCount: Integer;
    fFailedDateCount: Integer;
    fNeedNewpage: Boolean;
    fXLSFile: TXLSFile;
    fCurSheet: TSheet;
    Country : Integer;
    ImportMode : Boolean;
    function ColumnsFound: Boolean;
    procedure ResetImport;
    procedure TestColumnTitles(C: TCell);
    function GetCellText(C: TCell): string;
    procedure TestRow(NewRow: Integer; DoPrint: Boolean);
    procedure PrintForm; virtual; abstract;
    procedure ResetForm; virtual; abstract;
    procedure FillCollumn(C: TCell); virtual; abstract;
    function HaveNewdata: Boolean; virtual; abstract;
    procedure PrintNewData;
    function ImportFile(Filename: string; DoPrint: Boolean): Boolean;

    //Actual Printing bits..
    procedure RenderSplitText(const txt: string; const AtCol: Integer; const MoreSpacing: Boolean = False); // when the form label has split lines
    procedure PrintAccount(const name, bsb, number, client, cost: string;
      const cname, cnumber, cclient, ccost: string; const AcNumPos: Integer; const BSBSep: Boolean = False); // print an account section
    procedure DrawLine; // draw a line across the screen at the current Y position
    procedure DrawCheckbox(aX, aY: integer; Checked: boolean);
    function GetCurrLineSizeNoInflation: Integer; // sometimes requires less line spacing
    function XYPoint(aX, aY: Integer): TPoint;
  end;




implementation

uses
   bkConst,
   ErrorMoreFrm,
   InfoMoreFrm,
   Windows,
   ShellAPI,
   Classes,
   SysUtils,
   RepCols,
   Graphics;

const // Import Column Titles
  ct_AccountName = 'Account Name';
  ct_BSB = 'BSB';
  ct_AccountNo = 'Account No';
  ct_ClientCode = 'Client Code';
  ct_CostCode = 'Cost Code';
  ct_Bank = 'Bank / Branch';
  ct_Day = 'Day';
  ct_Month = 'Month';
  ct_Year = 'Year';
  ct_Frequency = 'Frequency';
  ct_Provisional = 'Provisional Accounts';

// The forms are quite big so resize to fit the screen, minus the taskbar

function IsTaskbarAutoHideOn: Boolean;
var
  ABData: TAppBarData;
begin
  ABData.cbSize := SizeOf(ABData);
  Result := (SHAppBarMessage(ABM_GETSTATE, ABData) and ABS_AUTOHIDE) > 0;
end;

function GetTaskBarHeight: Integer;
var
  hTaskBarWindow : HWnd;
  Rect           : TRect;
begin
  if IsTaskbarAutoHideOn then
    Result := 0
  else
  begin
    hTaskBarWindow:=FindWindow('Shell_TrayWnd',nil);
    GetWindowRect( hTaskBarWindow, Rect );
    Result := Rect.Bottom - Rect.Top;
  end;
end;

function GetTaskBarWidth: Integer;
var
  hTaskBarWindow : HWnd;
  Rect           : TRect;
begin
  if IsTaskbarAutoHideOn then
    Result := 0
  else
  begin
    hTaskBarWindow:=FindWindow('Shell_TrayWnd',nil);
    GetWindowRect( hTaskBarWindow, Rect );
    Result := Rect.Right - Rect.Left;
  end;
end;

function GetTaskBarRect: TRect;
var
  hTaskBarWindow : HWnd;
  Rect           : TRect;
begin
  hTaskBarWindow:=FindWindow('Shell_TrayWnd',nil);
  GetWindowRect( hTaskBarWindow, Rect );
  Result := Rect;
end;

function IsTaskbarHorizontal: Boolean;
var
  TaskbarRect: TRect;
  TaskbarWidth: Integer;
  TaskbarHeight: Integer;
begin
  TaskbarRect := GetTaskbarRect;

  TaskbarWidth := TaskbarRect.Right - TaskbarRect.Left;
  TaskbarHeight := TaskbarRect.Bottom - TaskbarRect.Top;

  Result := TaskbarWidth > TaskbarHeight;
end;

// Split up a TLabel into its individual lines and print them
procedure TAuthorityReport.RenderSplitText(const txt: string; const AtCol: Integer; const MoreSpacing: Boolean = False);
var
  line: string;
  x: Integer;
  s: TStringList;
  AddSpace: Boolean;
begin
  s := TStringList.Create;
  try
    line := txt;
    s.Clear;
    x := Pos(#$D, line);
    while x > 0 do
    begin
      s.Add(Copy(line, 1, x-1));
      line := Copy(line, x+1, Length(line));
      x := Pos(#$D, line);
    end;
    if Trim(line) <> '' then // add last one if not blank
      s.Add(line);

    Addspace := True;
    for x := 0 to Pred(s.Count) do
    begin
      if (s[x] = '') and MoreSpacing and AddSpace then
      begin
        AddSpace := False;
        NewLine;
      end
      else if s[x] <> '' then
        AddSpace := True;
      RenderText(s[x], Rect(AtCol, CurrYPos, ColBoxRight, CurrYPos+CurrLineSize),jtLeft);
      NewLine;
    end;
  finally
    s.Free;
  end;
end;

procedure TAuthorityReport.ResetImport;
begin
    //Reset The Column indexes
    fHeaderRow := -1;
    fCurRow := -1;
    fcAccountName := -1;
    fcBSB := -1;
    fcAccountNo := -1;
    fcClientCode := -1;
    fcCostCode := -1;
    fcBank := -1;
    fcDay := -1;
    fcMonth := -1;
    fcYear := -1;
    fcProvisional := -1;
    fcFrequency := -1;

    //Reset The counters
    fImportCount := 0;
    fFailedDateCount := 0;
end;

procedure TAuthorityReport.TestColumnTitles(C: TCell);
var Title: string;

   function TestTitle(const Value: string; var Column: Integer): Boolean;
   begin
      Result := Sametext(Value,Title);
      if Result then
         Column := C.Col;
   end;

begin //TestColumnTitles
   if (VarType(C.Value) = varString)
   or (VarType(C.Value) = varOleStr) then begin
      Title := Trim(c.ValueAsString); // Remove any spaces
      if TestTitle(ct_AccountName,fcAccountName) then exit;
      if TestTitle(ct_AccountNo,fcAccountNo) then Exit;
      if TestTitle(ct_ClientCode,fcClientCode) then exit;
      if TestTitle(ct_Bank,fcBank) then exit;
      if TestTitle(ct_Month,fcMonth) then exit;
      if TestTitle(ct_Year,fcYear) then exit;
      if TestTitle(ct_Provisional,fcProvisional) then exit;
      if TestTitle(ct_Frequency,fcFrequency) then exit;
      if TestTitle(ct_CostCode,fcCostCode) then exit;
      case Country of
         whAustralia : begin
            if TestTitle(ct_BSB,fcBSB) then exit;
         end;
         whNewZealand: begin
            if TestTitle(ct_Day,fcDay) then exit;
         end;
      end;
   end;
end;

procedure TAuthorityReport.TestRow(NewRow: Integer; DoPrint: Boolean);
begin
   if NewRow <> fCurRow then
      try
         // We have a new row
         if FHeaderRow >= 0 then begin
            if DoPrint
            and HaveNewdata then
                  PrintNewData;
         end else begin
            if ColumnsFound then begin
               // Found enough titles in the header..
               fHeaderRow := fCurRow;
               // But I am also moving to the next line
               // So make sure its printed if not blank
               if DoPrint
               and HaveNewdata then
                  PrintNewData;
            end;
         end;
      finally
         fCurRow := NewRow;
      end;
end;

// Draw line at current Y pos

function TAuthorityReport.ColumnsFound: Boolean;
begin
   Result := (fCurRow >= 0) and (fcAccountName >= 0) and (fcAccountNo>= 0) and (fcBank >= 0);
end;

procedure TAuthorityReport.DrawCheckbox(aX, aY: integer; Checked: boolean);
const
  MARGIN = 5;
var
  T: TPoint;
  XWidth, XMargin: integer;
begin
  DrawBox(XYSizeRect(aX, aY, aX + CurrLineSize, aY + CurrLineSize));
  if Checked then begin
    CanvasRenderEng.OutputBuilder.Canvas.Pen.Width := 2;
    //Tick (looks too small on printout)
//    T := XYPoint(aX + 4, aY + (CurrLineSize div 2) );
//    CanvasRenderEng.OutputBuilder.Canvas.MoveTo(T.X, T.Y);
//    T := XYPoint(aX + 12, aY + CurrLineSize - 7);
//    CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);
//    T := XYPoint(aX + CurrLineSize - 9, aY + 7);
//    CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);

    //Cross
    XWidth := CurrLineSize - (MARGIN * 2);
    XMargin := (CurrLineSize - XWidth) div 2;
    T := XYPoint(aX + XMargin, aY + XMargin);
    CanvasRenderEng.OutputBuilder.Canvas.MoveTo(T.X, T.Y);
    T := XYPoint(aX + CurrLineSize - XMargin, aY + CurrLineSize - XMargin);
    CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);
    T := XYPoint(aX + CurrLineSize - XMargin, aY + XMargin);
    CanvasRenderEng.OutputBuilder.Canvas.MoveTo(T.X, T.Y);
    T := XYPoint(aX + XMargin, aY + CurrLineSize - XMargin);
    CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);

    CanvasRenderEng.OutputBuilder.Canvas.Pen.Width := 1;
  end;
end;

procedure TAuthorityReport.DrawLine;
var
  T: TPoint;
begin
  T := XYPoint(Col0 - BoxMargin, CurrYPos);
  CanvasRenderEng.OutputBuilder.Canvas.MoveTo(T.X, T.Y);
  T := XYPoint(ColBoxRight + BoxMargin, CurrYPos);
  CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);
end;

// Print account info
procedure TAuthorityReport.PrintAccount(const name, bsb, number, client, cost: string;
  const cname, cnumber, cclient, ccost: string; const AcNumPos: Integer; const BSBSep: Boolean = False);
var
  T: TPoint;
  HalfLine: Integer;

  function GetTextYPos(BoxTop: integer): integer;
  var
    BoxCentre: integer;
    TextHeight: integer;
  begin
    Result := BoxTop + (BoxHeight div 2);
    Result := Result - (GetCurrLineSizeNoInflation div 2);
  end;
begin
  HalfLine := Round(CurrLineSize/2);
  CurrYPos := CurrYPos - BoxMargin;
  // Name
  RenderText(cname, Rect(Col0, GetTextYPos(CurrYPos), ColBoxRight, GetTextYPos(CurrYPos) + CurrLineSize), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size + 1;
  RenderText(name, Rect(Col1+200+BoxMargin, CurrYPos+HalfLine, 1300, CurrYPos+CurrLineSize+HalfLine), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size - 1;
  DrawBox(XYSizeRect(Col1 + 200, CurrYPos, 1300, CurrYPos + BoxHeight));
  // Client
  RenderText(cclient, Rect(Col2, GetTextYPos(CurrYPos), Col2 + 550, GetTextYPos(CurrYPos) + CurrLineSize), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size + 1;
  RenderText(client, Rect(Col2+200+BoxMargin, CurrYPos+HalfLine, Col2 + 600, CurrYPos+CurrLineSize+HalfLine), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size - 1;
  DrawBox(XYSizeRect(Col2 + 200, CurrYPos, Col2 + 600, CurrYPos + BoxHeight));
  CurrYPos := CurrYPos + BoxMargin;
  // Number
  NewLine;
  CurrYPos := CurrYPos + HalfLine;
  RenderText(cnumber, Rect(Col0, GetTextYPos(CurrYPos+BoxMargin*2), ColBoxRight, GetTextYPos(CurrYPos+BoxMargin*2)+CurrLineSize), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size + 1;
  RenderText(bsb, Rect(Col1+200+BoxMargin, CurrYPos+CurrLineSize, 1300, CurrYPos+(CurrLineSize*2)), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size - 1;
  if BSBSep then
  begin
    T := XYPoint(Col1+450+BoxMargin, CurrYPos+BoxMargin*2);
    CanvasRenderEng.OutputBuilder.Canvas.MoveTo(T.X, T.Y);
    T := XYPoint(Col1+450+BoxMargin, CurrYPos+BoxHeight+BoxMargin*2);
    CanvasRenderEng.OutputBuilder.Canvas.LineTo(T.X, T.Y);
  end;
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size + 1;
  RenderText(number, Rect(AcNumPos, CurrYPos+CurrLineSize, 1300, CurrYPos+(CurrLineSize*2)), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size - 1;
  DrawBox(XYSizeRect(Col1 + 200, CurrYPos+BoxMargin*2, 1300, CurrYPos + BoxHeight + BoxMargin*2));
  // Cost
  RenderText(ccost, Rect(Col2, GetTextYPos(CurrYPos+BoxMargin*2), ColBoxRight, GetTextYPos(CurrYPos+BoxMargin*2)+CurrLineSize), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size + 1;
  RenderText(cost, Rect(Col2+BoxMargin+200, CurrYPos+CurrLineSize, Col2 + 600, CurrYPos+(CurrLineSize*2)), jtLeft);
  CanvasRenderEng.OutputBuilder.Canvas.Font.Size := CanvasRenderEng.OutputBuilder.Canvas.Font.Size - 1;
  DrawBox(XYSizeRect(Col2 + 200, CurrYPos+BoxMargin*2, Col2 + 600, CurrYPos + BoxHeight + BoxMargin*2));
  NewLine(3);
  DrawLine;
end;

procedure TAuthorityReport.PrintNewData;
begin
   if fNeedNewPage then
      CanvasRenderEng.ReportNewPage;
   // Print the current form
   PrintForm;
   Inc(fImportCount);
   // Get reay for the next one..
   ResetForm;
   // Only False the first time..
   fNeedNewPage := True;
end;

function TAuthorityReport.GetCellText(C: TCell): string;
var I,Cd: Integer;
    YD,M : Word;

    procedure IntegerMonth(Value: Integer);
    begin
       if (Value in [1..12]) then
          Result := LongMonthnames[Value]
       else
          Result := '';
    end;

    function LocalFormat(Value: Double): string;
    // When the numer has too many trailing zeros,
    // it remains as a scientific number
    // This way it will always be a non scientific number
    const MaxDigits = 25; // Excel would have converted it to text by now..
    var Res: array [1..MaxDigits] of Byte;
        I: Integer;

        function Mod10(X: double): Integer;
        begin
           Value := Trunc(X / 10); // Dont tell anybody... x = value  ...
           Result := Trunc(X - Value * 10);
        end;

    begin
       I := 0;
       repeat
          inc(I);
          Res[I] := Mod10(Value);

          if I >= Maxdigits then
             Break
       until Value = 0;
       Result := '';
       for I := 1 to I do
          Result :=  Char(byte('0') + Res[I]) + Result;
    end;

begin
   Result := Trim(C.Value); // Its a goood save start
     if Result = '' then
         Exit; // Don't fail a Blank..

   if (C.Col = fcAccountNo)
   or (C.Col = fcClientCode)
   or (C.Col = fcCostCode)
   or (C.Col = fcBSB) then begin
       if (VarType(C.Value) = varSingle)
       or (VarType(C.Value) = varDouble)
       or (VarType(C.Value) = varCurrency) then
          Result := LocalFormat(C.Value);
   end else if C.Col = fcMonth then begin
      // Check the Month Field

      if (VarType(C.Value) = varDate) then begin
         //It's a (full) Date, just pick up the Month then
         DecodeDate(C.Value, YD,M,YD);
         IntegerMonth(M);
      end else begin
         Val(result,I,cd);
         if (cd = 0) then
            // Seems to be a valid number..
            IntegerMonth(I)
         else begin
            // Test the text..
            for I := 1 to 12 do begin
               if Sametext(ShortMonthNames[I], Result) then begin
                  Result := LongMonthnames[I];
                  Exit;
               end else if Sametext(LongMonthNames[I], Result) then
                  Exit;
            end;
            Result := '';
            Inc(fFailedDateCount);
         end
      end;
   end else if c.Col = fcYear then begin
      // Check the Year Field
      if (VarType(C.Value) = varDate) then begin
         //It's a (full) Date, just pick up the Year then
         DecodeDate(C.Value, YD,M,M);
         Result := IntToStr(YD);
      end;

      Val(Result,I,cd);
      if (cd = 0) then begin
         if (I > 0)
         and (I <= 99) then
             Exit // Fine..
         else if (I > 2000)
         and (I < 2100) then begin
            Result := Copy(Result,3,2);
            Exit;
         end;
      end;
      Inc(fFailedDateCount);
      Result := '';

   end else if c.Col = fcDay then begin

      // Check the Day Field

      if (VarType(C.Value) = varDate) then begin
         //It's a (full) Date, just pick up the Day then
         DecodeDate(C.Value, M,M,YD);
         Result := IntToStr(YD);
         Exit;
      end;

      Val(Result,I,cd);
      if (cd = 0) then begin
         if (I >= 1)
         and (I <= 31) then begin
            Result := IntToStr(I);
            Exit; // Fine..
         end;
      end;
      Inc(fFailedDateCount);
      Result := '';
   end else if c.Col = fcFrequency then begin
     Result := UpperCase(Copy(Result,1,1));
   end else if c.Col = fcProvisional then begin
     Result := UpperCase(Copy(Result,1,1));
   end;

end;

function TAuthorityReport.GetCurrLineSizeNoInflation: Integer;
begin
  Result := Round(CanvasRenderEng.OutputBuilder.HeightOfText('A'));
end;

function TAuthorityReport.ImportFile(Filename: string; DoPrint: Boolean): Boolean;
var
   S: Integer;
   ResStr: string;

   function PassWorksheet(Value: TSheet): Boolean;
   var I: Integer;

      function RowTest(C: TCell): Boolean;
      begin
         Result := true; //Assume success
         if C.Col = fcAccountName then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcBSB then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcAccountNo then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcCostCode then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcClientCode then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcBank then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcFrequency then begin
            if GetCellText(C) > '' then
               Exit;
         end else if C.Col = fcProvisional then begin
            if GetCellText(C) > '' then
               Exit;
         end;
         //Nothing usefull found
         Result := False;
      end;


   begin
      // Reset the columns
      fCurSheet := Value;
      ResetImport;
      for I := 0 to Value.cells.Count - 1 do begin
         TestRow(Value.cells.Item[I].Row, DoPrint);
         if fHeaderRow < 0 then
            TestColumnTitles(Value.cells.Item[I])
         else begin
            if DoPrint then
               FillCollumn(Value.cells.Item[I])
            else begin
               if RowTest(Value.cells.Item[I]) then begin
                  fImportCount := 1;
                  Break; // Parsing Only.. 1 is enough...
               end;
            end;
         end;
      end;
      Result := fImportCount > 0;
      fCurSheet := nil;
   end;

begin //ImportFile
  Result := False;
  fXLSFile := TXLSFile.Create;
  try
     try
     fXLSFile.OpenFile(Filename);
     if fXLSFile.Workbook.Sheets.Count = 0 then begin
        HelpfulErrorMsg(format('No sheets found in:'#13'%s',[Filename]), 0, False);
        Exit;
     end;
     fNeedNewpage := False; // Assume Blank start
     for S := 0 to  fXLSFile.Workbook.Sheets.Count - 1 do begin
       if PassWorksheet(fXLSFile.Workbook.Sheets[S]) then begin
          Result := True;
          Break; // Do All Sheets ??
       end;
     end;

     Result := fImportCount > 0;

     if DoPrint then begin
        // Actula Print cycle..
        // Do any outstanting forms
        if HaveNewdata then
           PrintNewData;

        // Build the result string
        if fImportCount = 0 then
           ResStr := 'No valid data found.'
        else if fImportCount = 1 then
           ResStr := '1 form imported.'
        else
           ResStr := format( '%d forms imported.',[fImportCount]);

        if fFailedDateCount > 0 then
           ResStr :=  ResStr + format( #13'%d date entries rejected.',[fFailedDateCount]);

        HelpfulInfoMsg(ResStr, 0);

     end else begin
        // Just parsing..
        if not result then
           HelpfulErrorMsg(format('No valid data found in:'#13'%s',[Filename]), 0, False);
     end;

     except
       on E: Exception do
         HelpfulErrorMsg(format('Error %s '#13'importing %s',[E.Message,Filename]), 0, False);
     end;
  finally
    fXLSFile.Free;
  end;
end; //ImportFile

function TAuthorityReport.XYPoint(aX, aY: Integer): TPoint;
//returns are point in device coordinates ( pixels). Expects to be passed coords
//in 0.1 mm units
begin
   with CanvasRenderEng.OutputBuilder do begin
       Result := ConvertToDC( Point( aX, aY));
   end;
end;

end.
