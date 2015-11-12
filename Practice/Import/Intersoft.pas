unit Intersoft;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, stStrs, stDateSt, LogUtil, ChartUtils, 
  Genutils, bkDateUtils, Progress, glConst, WinUtils;

const
  INT_EXTN = 'CSV';
  INT_FILE = 'ACCOUNTS.CSV';
  UnitName = 'INTERSOFT';
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
   i                 : integer;

   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   ARate             : Integer;
   aPost             : boolean;
   GSTInfo           : boolean;
   S                 : ShortString;
   Msg               : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + clCode + '\'+ INT_FILE;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;  //hcintersft001

      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'Intersoft Export|'+INT_FILE,INT_EXTN,HCtx) then
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

  (*

  CODE,DESCRIPTION,ACCOUNTTYPE,RATIO,HEADING,LEVEL,DEBIT/CREDIT,USECASHFLOW,USEQUANTITIES,INPUT/OUTPUT,TAXTYPE,DEPARTMENT

  1000,Revenue,Sales,0,Group,2,Credit,Y,N,Output,E,
  1100,Sales ( Product A ),Sales,70,,4,Credit,Y,N,Output,I,
  1200,Sales ( Product B ),Sales,70,,4,Credit,Y,N,Output,I,
  1300,Sales ( Product C ),Sales,70,,4,Credit,Y,N,Output,I,
  1500,Cost of Sales,Cost of Sales,0,Group,2,Debit,Y,N,Input,E,
  1510,Cost of Sales ( Product A ),Cost of Sales,70,,4,Debit,Y,N,Input,E,

  *)

          While not EOF( F ) do Begin
             Readln( F, Line );

             {get information from this line}
             If ( Line[1] in ['1'..'9'] ) and ( AsciiCountS(Line,',','"') = 12 ) then Begin
                ACode := Trim( ExtractAsciiS(1,Line,',','"'));
                ADesc := Trim( ExtractAsciiS(2,Line,',','"'));
                S     := Trim( ExtractAsciiS(11,Line,',','"'));

                ARate := 0;
                If S = 'I' then ARate := 1
                else If S='E' then ARate := 2;

                S     := Trim(ExtractAsciiS(5,Line,',','"'));
                APost := ( S='' );

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
          end;

          if NewChart.ItemCount > 0 then begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
             clChart_Last_Updated     := CurrentDate;

             {fill in gst details if empty}
             GSTInfo := FALSE;
             For i := 1 to MAX_GST_CLASS do if clGST_Rates[i,1]<>0 then GSTInfo := TRUE;

             If not GSTInfo then Begin
                clGST_Applies_From[1]  := DMYtoStDate(1,1,80,BKDATEEPOCH);

                clGST_Class_Names[1]  := 'GST Income';
                clGST_Rates[1,1]      := 125000;
                clGST_Class_Types[1]  := gtIncomeGST; {i}

                clGST_Class_Names[2]  := 'GST Expenditure';
                clGST_Rates[2,1]      := 125000;
                clGST_Class_Types[2]  := gtExpenditureGST; {e}

                clGST_Class_Names[3]  := 'Exempt';
                clGST_Rates[3,1]      := 0;
                clGST_Class_Types[3]   := gtExempt; {x}
             end;

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
          HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0 , False, E.Message, True);
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
