unit Beyond;

{...$I DEBUGME}

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
  GenUtils, bkDateUtils, BKUtil32, glConst, WinUtils;

Const
   UnitName = 'Beyond';
   DebugMe  : Boolean = False;
   
//------------------------------------------------------------------------------

procedure RefreshChart;

const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   HCtx              : integer;
   F                 : TextFile;
   Buffer            : array[ 1..8192 ] of Byte;
   Line              : String;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   i                 : integer;
   p                 : integer;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   Msg               : string;
   OK                : Boolean;
   GSTInfo           : Boolean;
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
           ChartFileName,
           ExtractFilePath(ChartFilePath), { Initial Directory }
           'Exported Charts|*.*',
           '*',
           HCtx ) then
           exit;
     end;

     try
        //have a file to import - import into a new chart object
        AssignFile( F,ChartFileName );
        SetTextBuf( F, Buffer );
        Reset( F );
        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
           While not EOF( F ) do Begin
              Readln( F, Line );
              ACode := '';
              ADesc := '';
              p := Pos( '","', Line );
              If p>0 then Begin
                 ACode := TrimSpacesAndQuotes( Copy( Line, 1, p ) ); { 388/ }
                 Line := Copy( Line, p+3, 255 );
                 ADesc := TrimSpacesAndQuotes( Line );
              end;
              
              if ( ACode<>'' ) then Begin
                 if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                    LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                 end
                 else Begin
                    NewAccount := New_Account_Rec;
                    with NewAccount^ do begin
                       chAccount_Code        := aCode;
                       chAccount_Description := aDesc;
                       chGST_Class           := 0;
                       chPosting_Allowed     := true;
                    end;
                    NewChart.Insert(NewAccount);
                 end;
              end;
           end;
           
           if NewChart.ItemCount > 0 then begin
              MergeCharts(NewChart, MyClient);

              clLoad_Client_Files_From := ChartFileName;
              clChart_Last_Updated     := CurrentDate;

              GSTInfo := FALSE;
              For i := 1 to MAX_GST_CLASS do If clGST_Class_Names[i]<>'' then GSTInfo := TRUE;
              if not GSTInfo then
              Begin
                 clGST_Class_Names[1]  := 'Purchases';
                 clGST_Rates[ 1, 1 ]   := 125000;
                 clGST_Class_Types[1]  := gtInputTax;
                 clGST_Class_Codes[1]  := '1';

                 clGST_Class_Names[2]  := 'Sales';
                 clGST_Rates[ 2, 1 ]   := 125000;
                 clGST_Class_Types[2]  := gtOutputTax;
                 clGST_Class_Codes[2]  := '2';

                 clGST_Class_Names[3]  := 'Exempt';
                 clGST_Class_Types[3]  := gtExempt;

                 clGST_Class_Names[4]  := 'Zero-Rated';
                 clGST_Class_Types[3]  := gtZeroRated;
              end;
              OK := True;
           end;
        finally
           NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
           CloseFile(f);
           if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
        end;
     except
        on E : EInOutError do begin //Normally EExtractData but File I/O only
           Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
           HelpfulErrorMsg( Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
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

 
