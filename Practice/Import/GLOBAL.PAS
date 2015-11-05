unit Global;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, ChartUtils, GenUtils, Progress, 
  bkDateUtils, classes, LogUtil, MoneyDef, glConst, WinUtils;

const
  GLOBAL_EXTN = 'CHT';
  UnitName    = 'GLOBAL';
  DebugMe     : Boolean = False;
  
//------------------------------------------------------------------------------  

procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
var
   ChartFileName     : string;
   HCtx              : integer;
   f                 : TextFile;
   Line              : String;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   i                 : integer;

   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   ARate             : Integer;
   APost             : boolean;

   GST_Rates         : Array[ 1..MAX_GST_CLASS] of Money;       { Stored }
   GST_Rate_Names    : Array[ 1..MAX_GST_CLASS] of String[20];
   Msg               : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + clCode + '.'+ GLOBAL_EXTN;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;  //hcGLOBAL001

      if not LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'Global Export|*.'+GLOBAL_EXTN,GLOBAL_EXTN,HCtx) then
        exit;
    end;

    {store existing GST Details}
    For i := 1 to MAX_GST_CLASS do GST_Rates[i]      := clGST_Rates[i,1];
    For i := 1 to MAX_GST_CLASS do GST_Rate_Names[i] := clGST_Class_Names[i];

    try
      UpdateAppStatus('Loading Chart','',0);
      try
        {have a file to import - import into a new chart object}
        AssignFile(F,ChartFileName);
        Reset(F);

        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
          UpdateAppStatusLine2('Reading');

          While not EOF( F ) do Begin
             Readln( F, Line );

             {get information from this line}
             If Line<>'' then
               Case Line[1] of
                  'G':  Begin
                           ARate := Str2Byte( Line[2] );
                           If ( ARate in [1..MAX_GST_CLASS] ) then Begin
                              GST_Rates[ ARate ]      := Double2GSTRate( StrToFloat( Trim( Copy( Line, 23, 5 ) ) ) );
                              GST_Rate_Names[ ARate ] := Trim( Copy( Line, 3, 20 ) );
                           end;
                        end;
                  'A':  Begin
                           ACode := Trim( Copy( Line,  2,  10 ) );
                           ADesc := Trim( Copy( Line, 12,  60 ) );
                           APost := ( Line[72] = 'Y' );
                           ARate := Str2Byte(Line[73]);

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
                                 chPosting_Allowed     := aPost;
                              end;
                              NewChart.Insert(NewAccount);
                           end;
                        end;
               end; { of Case }
          end;

          if NewChart.ItemCount > 0 then begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
             clChart_Last_Updated     := CurrentDate;

             {replace new GST Rates}
             For i := 1 to MAX_GST_CLASS do clGST_Rates[i,1]     := GST_Rates[i];
             For i := 1 to MAX_GST_CLASS do clGST_Class_Names[i] := GST_Rate_Names[i];
          end;
        finally
          NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
          CloseFile(f);
        end;
      finally
        ClearStatus(True);
      end;
    except
      on E : EInOutError do begin //Normally EExtractData but File I/O only
          Msg := Format( 'Error Refreshing Chart %s.', [ChartFileName] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.'#13, 0, false, E.Message, True);
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
