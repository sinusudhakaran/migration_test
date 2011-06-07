unit MYOB;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, WarningMoreFrm, stDateSt,
  classes, LogUtil, bk5Except, ChartUtils, GenUtils, bkDateUtils, WinUtils;

const
  MYOB_EXTN = 'CHT';
  MYOB_MASK = '#-####';
  UnitName  = 'MYOB';
  DebugMe   : Boolean = False;
  
//------------------------------------------------------------------------------

procedure RefreshChart;
const
   ThisMethodName      = 'RefreshChart';
var
   ChartFileName       : string;
   ChartFilePath       : string;
   HCtx                : integer;
   F                   : TextFile;
   Buffer              : array[ 1..8192 ] of Byte;
   Line                : String;
   NewChart            : TChart;
   NewAccount          : pAccount_Rec;

   p                   : integer;
   ACode               : Bk5CodeStr;
   ADesc, AType        : String[80];
   Msg : string;  
   OK                  : Boolean;
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

    if not BKFileExists(ChartFileName) then begin
      HCtx := 0;   //      hcMYOB001
      ChartFileName := RemoveSlash(ChartFileName);
      if not LoadChartFrom( clCode,
                            ChartFileName,
                            ExtractFilePath(ChartFilePath),
                            'MYOB Chart|*.CHT;*.TXT',
                            'CHT',
                            HCtx ) then
        exit;
    end;

    try {except}
       AssignFile(F,ChartFileName);
       SetTextBuf( F, Buffer );
       Reset(F);
       NewChart := TChart.Create(MyClient.ClientAuditMgr);
       
       try

         While not EOF( F ) do Begin
            Readln( F, Line );

            {get information from this line}
            If Line[1] in ['0'..'9'] then Begin
               p := Pos(#09, Line );
               If p=0 then Begin
                  Msg := Format( 'The File %s is not in Tab-Delimited format.',[ ChartFileName ] );
                  LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
                  Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
               end;
               ACode := Copy( Line, 1, p-1 );

               //older versions of myob require us to add the dash for chart codes
               if Pos( '-', ACode) = 0 then
               begin
                 ACode := ACode[1]+'-'+Copy( ACode,2, 10 );
               end;

               Line := Copy( Line, p+1, 255 );

               p := Pos(#09, Line );
               If p>0 then Begin
                  ADesc := Copy( Line, 1, p-1 );
                  Line := Copy( Line, p+1, 255 );

                  p := Pos(#09, Line );
                  If p>0 then Begin
                     AType := Copy( Line, 1, p-1 ); { "Leasing" }

                     if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                        LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                     end
                     else Begin
                        {insert new account into chart}
                        NewAccount := New_Account_Rec;
                        with NewAccount^ do begin
                          chAccount_Code        := aCode;
                          chAccount_Description := aDesc;
                          chGST_Class           := 0;
                          chPosting_Allowed     := (AType<>'H');
                        end;
                        NewChart.Insert(NewAccount);
                     end;
                  end;
               end;
            end;
         end;

         if NewChart.ItemCount > 0 then begin
            MergeCharts(NewChart, MyClient);

            clLoad_Client_Files_From := ChartFileName;
            clChart_Last_Updated     := CurrentDate;

            If clAccount_Code_Mask = '' then
                 clAccount_Code_Mask := MYOB_MASK;
            OK := True;
         end;
       finally
          NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
          CloseFile( F );
          if OK then HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
       end;
    except
      on E : EInOutError do begin //Normally EExtractData but File I/O only
          Msg := Format( 'Error Refreshing Chart %s. %s', [ChartFileName, E.Message ] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
          exit;
      end;
    end;
  end;  {with }
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
