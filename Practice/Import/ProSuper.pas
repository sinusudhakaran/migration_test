unit ProSuper;
// Based on CSV chart but does not have GST info
interface

function RefreshChart( const ASuffix: ShortString ): Boolean;

implementation

uses
  Globals, sysutils, InfoMoreFrm, bkconst, chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, classes, LogUtil, ChartUtils,
  GenUtils, bkDateUtils, glConst, StStrS, Templates, GSTCalc32, WinUtils;

const
  UNIT_NAME = 'ProSuper';
  DEBUG_ME  : Boolean = False;

function RefreshChart( const ASuffix: ShortString ): Boolean;
const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   HCtx              : integer;
   F                 : TextFile;
   Buffer            : array[ 1..8192 ] of Byte;
   Line              : String;
   Fields            : Array[ 1..4 ] of ShortString;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   i                 : integer;
   AChartID          : Integer;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   APostOK           : String[10];
   Msg               : string;
   OK                : Boolean;
   FieldList: TStringList;
   TemplateFileName: string;
   TemplateError : TTemplateError;
begin
   if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Begins' );
   Result := False;
   if not Assigned(MyClient) then exit;

   OK := False;

   with MyClient.clFields do begin
      ChartFileName := AddSlash(clLoad_Client_Files_From) + DESKTOP_SUPER_CHART_FILENAME;

     //check file exists, ask for a new one if not
     if not BKFileExists( ChartFileName ) then begin
        HCtx := 0;
        ChartFileName := RemoveSlash(ChartFileName);
        if not LoadChartFrom(
           clCode,
           ChartFileName,
           ExtractFilePath(ChartFilePath), { Initial Directory }
           'Exported Charts ('+ ASuffix+')|' + ASuffix,
           ASuffix,
           HCtx ) then
           exit;
        clLoad_Client_Files_From := SysUtils.ExtractFileDir(ChartFileName);
     end;

     if (not MyClient.GSTHasBeenSetup) then begin
        TemplateFileName := GLOBALS.TemplateDir + 'GENERIC.TPM';
        // make sure chart is not a directory!
        if BKFileExists(TemplateFileName) and (not DirectoryExists(TemplateFileName)) then
          Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
     end;

     FieldList := TStringList.Create;
     try
       FieldList.Delimiter := ',';
       FieldList.StrictDelimiter := True;
       try
          //have a file to import - import into a new chart object
          AssignFile( F,ChartFileName );
          SetTextBuf( F, Buffer );
          Reset( F );
          NewChart := TChart.Create(MyClient.ClientAuditMgr);
          try
             While not EOF( F ) do Begin
                Readln( F, Line );
                FillChar( Fields, Sizeof( Fields ), 0 );
                FieldList.CommaText := Line;
                for i := 1 to 4 do
                  Fields[ i ] := TrimSpacesAndQuotes(FieldList[i-1]);

                aChartId := StrToIntDef(Fields[1], -1);
                if aChartId = -1 then
                begin
                  LogUtil.LogMsg(lmError, UNIT_NAME, 'Invalid Chart ID ' + Fields[1]
                    + ' found in ' + ChartFileName);
                  Continue;
                end;
                if Fields[2] <> '' then
                  aCode    := Fields[1] + '-' + Fields[2]
                else
                  aCode    := Fields[1];
                aDesc    := Fields[3];
                aPostOK  := UpperCase(Fields[4]);

                If ( aCode <> '' ) and ( UpperCase( aCode ) <> 'CODE' ) then
                Begin
                   If (NewChart.FindCode(ACode) <> Nil) Then
                       LogUtil.LogMsg(lmError, UNIT_NAME, 'Duplicate Code ' + ACode
                          + ' found in ' + ChartFileName)
                   Else
                   Begin
                      {insert new account into chart}
                      NewAccount := New_Account_Rec;
                      With NewAccount^ Do
                      Begin
                         chAccount_Code        := ACode;
                         chAccount_Description := ADesc;
                         chPosting_Allowed := ( (aPostOK = 'N') or (aPostOK = 'S') );
                         chChart_ID := IntToStr(AChartID);
                      End;
                      NewChart.Insert(NewAccount);
                   End; { not ((NewChart.FindCode(ACode) <> Nil)) }
                End;
             end;
             if NewChart.ItemCount > 0 then begin
                MergeCharts(NewChart, MyClient, True);
                clChart_Last_Updated     := CurrentDate;
                OK := True;
             end;
          finally
             NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
             CloseFile(f);

             if OK then
             begin
               Msg := 'The client''s chart of accounts has been refreshed.';
               HelpfulInfoMsg( Msg, 0 );
             end;

             Result := True;
          end;
       except
          on E : EInOutError do begin // File I/O only
             Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
             LogUtil.LogMsg( lmError, UNIT_NAME, ThisMethodName + ' : ' + Msg );
             HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
             exit;
          end;
       end; {except}
     finally
       FieldList.Free;
     end;
  end; {with}
  if DEBUG_ME then LogUtil.LogMsg(lmDebug, UNIT_NAME, ThisMethodName + ' Ends' );
end;

Initialization
   DEBUG_ME := LogUtil.DebugUnit( UNIT_NAME );
end.

