unit Master2000;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, moneydef, BK5Except, ChartUtils,
  GenUtils, Progress, bkDateUtils, LogUtil, glConst, WinUtils;

const
  MASTER_EXTN = 'xxx';
  Ch          = '³';
  UnitName    = 'MASTER2000';
  DebugMe     : Boolean = False;

TYPE
   GRec = Record
      GA : Array[1..7] of Char;
      GR : Array[1..5] of Char;
   end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
var
   ChartFileName : string;
   HCtx : integer;
   f    : TextFile;
   Line          : String;
   NewChart      : TChart;
   NewAccount    : pAccount_Rec;
   i             : integer;
   Msg           : String;
   ACode         : Bk5CodeStr;
   ADesc         : String[80];
   ARate         : Integer;
   
   Header : Record
     ID : Char;
     CC : Array[1..7] of Char;
     CN : Array[1..60] of Char;
     GST : Array[1..9] of GRec;
   end;
   
   GST_Rates         : Array[ 1..MAX_GST_CLASS  ] of Money;
   GST_Rate_Names    : Array[ 1..MAX_GST_CLASS ] of String[20];

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do
  begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + clCode + '.'+ MASTER_EXTN;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;   //hcM200001
      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'Master 2000 Export|*.'+MASTER_EXTN,MASTER_EXTN,HCtx) then
         Exit;
    end;

    {store existing GST Details}
    for i := 1 to MAX_GST_CLASS do GST_Rates[i]      := clGST_Rates[i,1];
    for i := 1 to MAX_GST_CLASS do GST_Rate_Names[i] := clGST_Class_Names[i];

    try
      UpdateAppStatus('Loading Chart','',0);
      try
        {have a file to import - import into a new chart object}
        AssignFile(F,ChartFileName);
        Reset(F);

        NewChart := TChart.Create(MyClient.ClientAuditMgr);
        try
          UpdateAppStatusLine2('Reading');

          While not EOF( F ) do
          Begin
             Readln( F, Line );

             {get information from this line}
             Case Line[1] of
                'C':  If Length( Line ) = Sizeof( Header ) then
                      Begin
                         Move( Line[1], Header, Sizeof( Header ) );
                         With Header do for i:=1 to 9 do  {must use 9 because is in header record}
                         Begin
                            GST_Rates[ i ] := Double2GSTRate( StrToFloat( GST[i].GR ) );
                            If GST_Rate_Names[i] = '' then
                               GST_Rate_Names[i] := Money2Str( GST_Rates[ i ])+'%';
                         end;
                      end;

                'A':  Begin
                         ACode := Trim( Copy( Line,  10,  8 ) );
                         ADesc := Trim( Copy( Line, 18,  30 ) );
                         ARate := Byte(Line[48]);

                         if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                            LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                         end
                         else Begin
                            {insert new account into chart}
                            NewAccount := New_Account_Rec;
                            with NewAccount^ do
                            begin
                              chAccount_Code        := aCode;
                              chAccount_Description := aDesc;
                              chGST_Class           := aRate;
                              chPosting_Allowed     := true;
                            end;
                            NewChart.Insert(NewAccount);
                         end;
                      end;
              end; {case}
          end;

          if NewChart.ItemCount > 0 then
          begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
             clChart_Last_Updated     := CurrentDate;

             {replace new GST Rates}
             for i := 1 to MAX_GST_CLASS do clGST_Rates[i,1]     := GST_Rates[i];
             for i := 1 to MAX_GST_CLASS do clGST_Class_Names[i] := GST_Rate_Names[i];
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
          Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
      end;
    end; {except}
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
