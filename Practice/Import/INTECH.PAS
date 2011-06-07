unit Intech;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, Windows, WarningMoreFrm, ChartUtils, 
  LogUtil, GenUtils, Progress, bkDateUtils, glConst, WinUtils;

const
  INT_EXTN  = 'LM.TXT';
  TEMPNAME  = 'INTCHART.TMP';
  UnitName  = 'INTECH';
  DebugMe   : Boolean = False;

//------------------------------------------------------------------------------

function WindowsTempPath : string;
Var
   DirLen  : DWord;
   TempDir : string;
Begin
   TempDir := GLOBALS.DATADIR;
   DirLen  := Windows.GetTempPath( 0, nil );
   if DirLen > 0 then 
   Begin
      SetLength( TempDir, Pred( DirLen ) );
      GetTempPath( DirLen, PChar( TempDir ) );
      TempDir := ExtractFilePath( TempDir );
   end;
   Result := TempDir;
end;

//var
//  TempPath : string;
//begin
//  SetLength(TempPath, MAX_PATH);
//  if GetTempPath(MAX_PATH, PChar(TempPath)) = 0 then
//    result := ''
//  else
//    result := tempPath;
//end;

//------------------------------------------------------------------------------
Procedure ConvertTabsToSpaces( InFileName, OutFileName : String );

const
   ThisMethodName = 'ConvertTabsToSpaces';
   
Var
   InFile   : TextFile;
   OutFile  : TextFile;
   Ch       : Char;
   p,l      : Byte;
   B        : Array[ 1..512 ] of Char;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   AssignFile(InFile, InFileName );
   Reset( InFile );
   try
     AssignFile(OutFile, OutFileName );
     Rewrite( OutFile );
     try
       l := 0;
       FillChar( B, Sizeof( B ), 0 );

       While not EOF( InFile ) do Begin
          Read( InFile, Ch );
          If ( Ch=#$0D ) then Begin
             { Do Nothing }
          end
          else If ( Ch=#$0A ) then Begin
             If l > 64 then l:= 64;
             For p := 1 to l do Write( OutFile, B[p] );
             Writeln( OutFile );
             l := 0;
             FillChar( B, Sizeof( B ), 0 );
          end
          else If ( Ch=#09 ) then Begin
             Repeat
                Inc( l );
                B[l] := ' ';
             Until ( l mod 8 ) = 0;
          end
          else Begin
             Inc( l );
             B[l] := Ch;
          end;
       end;
     finally
       CloseFile(outFile);
     end;
   finally
     CloseFile(InFile);
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure RefreshChart;
const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   f                 : TextFile;
   Line              : String;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;

   TempFilename      : string;
   TempPath          : string;

   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   ARate             : Integer;
   Msg               : string;
begin
if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do begin
    ChartFileName := clLoad_Client_Files_From;

    if DirectoryExists(ChartFileName) then // User only specified a directory - we need a filename
    begin
      ChartFileName := '';
      ChartFilePath := AddSlash(clLoad_Client_Files_From);
    end
    else
      ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      ChartFileName := clCode + INT_EXTN;  //add default name

      if not ChartUtils.LoadChartFrom(clCode,
                                      ChartFileName,
                                      ExtractFilePath(ChartFilePath),
                                      'Intect Export|*'+INT_EXTN,
                                      'TXT',
                                      0) then
        exit;
    end;

    try
      UpdateAppStatus('Loading Chart','Converting File Format',0);
      try
        {convert the file first}
        TempPath := WindowsTempPath;
        if TempPath <> '' then
          TempFileName := AddSlash(TempPath)+ TEMPNAME
        else
          TempFileName := DATADIR + TEMPNAME;

        ConvertTabsToSpaces( ChartFileName, TempFileName );

        {have a file to import - import into a new chart object}
        AssignFile(F,TempFileName);
        Reset(F);

        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
          UpdateAppStatusLine2('Reading');

          While not EOF( F ) do Begin
             Readln( F, Line );

             {get information from this line}
             If Length( Line ) >= 60 then Begin
                If ( Line[5]='1' ) and ( Line[58] in [ '0', '8' ] ) then Begin
                   ACode    := Trim( Copy( Line, 6, 5 ) );
                   ADesc    := Trim( Copy( Line, 17, 40 ) );
                   ARate    := Succ( Str2Long( Line[60] ) );

                   if not ( ARate in [ 1..MAX_GST_CLASS] ) then ARate := 0;

                   if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                      LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                   end
                   else Begin
                      {insert new account into chart}
                      NewAccount := New_Account_Rec;
                      with NewAccount^ do begin
                        chAccount_Code        := aCode;
                        chAccount_Description := aDesc;
                        chGST_Class           := aRate;
                        chPosting_Allowed     := true;
                      end;

                      NewChart.Insert(NewAccount);
                   end;
                end;
             end;
          end;

          if NewChart.ItemCount > 0 then begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ChartFileName;
             clChart_Last_Updated     := CurrentDate;

             clGST_Class_Names[1] := 'Expenditure';
             clGST_Class_Names[2] := 'Income';
             clGST_Class_Names[3] := 'Expenditure - No GST';
             clGST_Class_Names[4] := 'Income - No GST';
          end;
        finally
          NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
          CloseFile(f);
          SysUtils.DeleteFile(TempFileName);
        end;
      finally
        ClearStatus(True);
      end;
    except
      on E : EInOutError do begin //Normally EExtractData but File I/O only
          Msg := Format( 'Error Refreshing Chart %s. %s', [ChartFileName, E.Message ] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
          exit;
      end;
    end; {except}
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
