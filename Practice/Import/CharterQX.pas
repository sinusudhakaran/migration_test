unit CharterQX;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio, bkdefs, ovcDate,
  ErrorMoreFrm, ChartUtils, LogUtil, GenUtils, Progress, glConst, WinUtils;

const
  UnitName  = 'CHARTERQX';
  CQX_EXTN  = 'TXT';
  DebugMe   : Boolean = False;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function MakeQXCode( Const S1,S2 : ShortString ): ShortString;

Var
   N1, N2 : Word;
   i : Byte;
   V1, V2 : String[4];
Begin
   N1 := Str2Word( S1 );
   N2 := Str2Word( S2 );
   Str( N1:4, V1 ); For i:=1 to 4 do if V1[i]=' ' then V1[i]:='0';
   Str( N2:2, V2 ); For i:=1 to 2 do if V2[i]=' ' then V2[i]:='0';
   MakeQXCode := V1+'.'+V2;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function CountChar( Const S : String; C : Char ): Byte;
Var
   i      : Byte;
Begin
   Result := 0;
   For i := 1 to Length( S ) do if ( S[i] = C ) then Inc( Result );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
var
   ChartFileName : string;
   HCtx : integer;
   f    : TextFile;
   Line           : String;
   NewChart       : TChart;
   NewAccount     : pAccount_Rec;
   i              : integer;

   ACode          : Bk5CodeStr;
   ADesc          : String[80];
   ARate          : Integer;
   Found          : boolean;
   p              : integer;
   Fields         : Array[1..5] of String[30];
   Msg            : String;

begin
if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + clCode + '.'+ CQX_EXTN;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;   //hcCHARTER001
      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'Charter QX Export|*.'+CQX_EXTN,CQX_EXTN,HCtx) then
         Exit;
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

          While not EOF( F ) do begin
             Readln( F, Line );

             {get information from this line}
             If CountChar( Line, ',' )=4 then
             Begin (* it's an account record *)
                Line := Line + ',';
                FillChar( Fields, Sizeof( Fields ), 0 );
                For i := 1 to 5 do
                Begin
                   p := Pos( ',', Line );
                   If p>1 then Fields[i] := Copy( Line, 1, p-1 );
                   Fields[i] := TrimSpacesAndQuotes( Fields[i] );
                   System.Delete( Line, 1, p );
                end;
                ACode := MakeQXCode( Fields[1], Fields[2] );
                ADesc := Fields[3];
                ARate := 1+Str2Byte( Fields[5] );
                If not ( ARate in [ 1..MAX_GST_CLASS ] ) then ARate := 0;

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
          end;

          if NewChart.ItemCount > 0 then begin
             MergeCharts(NewChart, MyClient);

             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
             clChart_Last_Updated     := CurrentDate;

             {update gst rates if all values are blank}
             Found := FALSE;
             For i := 1 to MAX_GST_CLASS do if clGST_Class_Names[i] <>'' then Found := TRUE;
             If not Found then Begin
                clGST_Applies_From[1]  := DMYtoStDate(1,1,80,BKDATEEPOCH);

                clGST_Class_Names[1]   := 'Exempt';
                clGST_Rates[1,1]       := 0;
                clGST_Class_Types[1]   := gtExempt; {x}

                clGST_Class_Names[2]   := 'Purchases';
                clGST_Rates[2,1]       := 1250;
                clGST_Class_Types[1]   := gtExpenditureGST; {e}

                clGST_Class_Names[3]   := 'Sales';
                clGST_Rates[3,1]       := 1250;
                clGST_Class_Types[1]   := gtIncomeGST; {i}
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
      on E : EInOutError do begin  //Normally EDataExtract but only File I/O here
         Msg := Format( 'Error Refreshing Chart %s.', [ChartFileName] );
         LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
         HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.'#13, 0 , False,E.Message, true);
      end;
    end; {except}
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
