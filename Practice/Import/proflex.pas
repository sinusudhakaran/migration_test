unit proflex;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst, chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, classes, LogUtil, ChartUtils, 
  GenUtils, Progress, bkDateUtils, glConst, WinUtils;

Const
   UnitName = 'ProFlex';
   DebugMe  : Boolean = False;
   
//------------------------------------------------------------------------------

procedure RefreshChart;

const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   HCtx              : integer;
   f                 : TextFile;
   Line              : ShortString;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   p                 : integer;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   APost             : String[10];
   AGSTClass         : String[10];
   GSTInd            : Integer;
   Msg               : string;
   OK                : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then exit;

   OK := False;

   with MyClient.clFields do begin
      ChartFileName := clLoad_Client_Files_From;

      if DirectoryExists(ChartFileName) then // User only specified a directory - we need a filename
      begin
        ChartFileName := '';
        ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end
      else
        ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

     //check file exists, ask for a new one if not
     if not BKFileExists( ChartFileName ) then begin
        HCtx := 0;
        ChartFileName := RemoveSlash(ChartFileName);
        if not LoadChartFrom(
           clCode,
           ChartFileName,                                { Var Result }
           ExtractFilePath(ChartFilePath),  { Initial Directory }
           'Proflex Chart Files (*.CHT)|*.CHT',          { Filter }
           'CHT',
           HCtx ) then
           exit;
     end;

     if not BKFileExists( ChartFileName ) then exit;
     
     try
        UpdateAppStatus('Loading Chart','',0);
        try
           //have a file to import - import into a new chart object
           AssignFile(F,ChartFileName);
           Reset(F);
           NewChart := TChart.Create(MyClient.ClientAuditMgr);
           try
              UpdateAppStatusLine2('Reading');
              While not EOF( F ) do Begin
                 Readln( F, Line );

                 ACode     := '';
                 ADesc     := '';
                 APost     := '';
                 AGSTClass := '';
                 
                 p := Pos( ',', Line );
                 if p>0 then Begin
                    ACode := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); 
                    Line := Copy( Line, p+1, 255 );
                 end;
                 
                 p := Pos( '",', Line );
                 if p>0 then Begin
                    ADesc := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); 
                    Line := Copy( Line, p+2, 255 );
                 end;
                 
                 p := Pos( '",', Line );
                 if p>0 then Begin
                    APost := TrimSpacesAndQuotes( Copy( Line, 1, p-1 ) ); 
                    Line := Copy( Line, p+2, 255 );
                 end;

                 AGSTClass := TrimSpacesAndQuotes( Line );
                 GSTInd    := StrToIntSafe( AGSTClass );

                 if ACode<>'' then Begin
                    if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                       LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                    end
                    else Begin
                       {insert new account into chart}
                       NewAccount := New_Account_Rec;
                       with NewAccount^ do begin
                          chAccount_Code        := aCode;
                          chAccount_Description := aDesc;
                          chPosting_Allowed     := ( APost = 'Y' );
                          chGST_Class           := 0;
                          if GSTInd in [ 1..MAX_GST_CLASS ] then chGST_Class := GSTInd;
                       end;
                       NewChart.Insert(NewAccount);
                    end;
                 end;
              end;

              if NewChart.ItemCount > 0 then begin
                 MergeCharts(NewChart, MyClient);
                 clLoad_Client_Files_From := ChartFileName;
                 clChart_Last_Updated     := CurrentDate;

{                 HasGSTInfo := false;
                 for i := 1 to MAX_GST_CLASS do if clGST_Class_Names[i]<>'' then HasGSTInfo := true;

                 if not HasGSTInfo then begin
                     (*
                     1 Output Taxed Rate 1
                     2 Output Taxed Rate2
                     3 Exempt from Output
                     4 Zero Rated Output
                     5 Input Tax Rate 1
                     6 Input Tax Rate 2
                     7 Exempt from Input
                     8 Zero Rated Input
                     *)
                     //gst has not been setup, so put in some defaults
}
                 OK := True;
              end;
              ClearStatus(True);
           finally
              NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
              CloseFile(f);
              if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
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

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.


