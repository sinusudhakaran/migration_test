unit AttacheNZ;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, stDatest, LogUtil, ChartUtils, 
  GenUtils, Progress, bkDateUtils, WinUtils;

const
  ATT_EXTN = 'CHT';
  UnitName = 'ATTACHENZ';
  DebugMe  : Boolean = False;
  
//------------------------------------------------------------------------------

procedure RefreshChart;
const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   HCtx              : integer;
   f                 : TextFile;
   Line              : String;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   Msg               : string;
   OK                : Boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   OK := False;
   
   if not Assigned(MyClient) then exit;

   with MyClient.clFields do begin
    ChartFileName := AddSlash( clLoad_Client_Files_From ) + clCode + '.'+ ATT_EXTN;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then
    begin
      HCtx := 0;   // hcATTACHE001

      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'Attache Export |*.'+ATT_EXTN,ATT_EXTN,HCtx) then
        exit;
    end;

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
             If ( Copy( Line, 56, 4 )='Post' ) OR ( Copy( Line, 56, 4 )='Bank' ) then Begin
               ACode := Trim(Copy( Line,  5,  12 ) );
               ADesc := Trim(Copy( Line, 20,  30 ) );

               if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                  LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
               end
               else Begin
                   {insert new account into chart}
                   NewAccount := New_Account_Rec;
                   with NewAccount^ do begin
                      chAccount_Code        := aCode;
                      chAccount_Description := aDesc;
                      chGST_Class           := 1;
                      chPosting_Allowed     := true;
                   end;

                   NewChart.Insert(NewAccount);
                end;
             end;
          end;

          if NewChart.ItemCount > 0 then begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
             clChart_Last_Updated     := CurrentDate;
             OK                       := True;
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
    if OK then HelpfulInfoMsg( 'The Chart of Accounts has been refreshed.', 0 );
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
