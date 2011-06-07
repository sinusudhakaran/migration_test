unit Sage50;

interface

procedure RefreshChart;

implementation


uses
   BKchIO,
   Bk5Except,
   stdate,
   bkdefs,
   ErrorMoreFrm,
   InfoMoreFrm,
   ChartUtils,
   GenUtils,
   Winutils,
   SysUtils,
   Globals,
   LogUtil,
   chList32,
   classes;

const
   UnitName = 'Sage50';
   DebugMe  : Boolean = False;

   colCode = 0;
   colDesc = 1;

function LoadSage50Chart(FromFile: TFileName): TChart;
const
   ThisMethodName = 'LoadSage50Chart';
var
   Msg: string;
   lFile,
   lLine : TStringList;
   I: Integer;
   aCode: string[20];
   aDesc: string[60];

   NewAccount: pAccount_Rec;
begin
   Result := nil;
   if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not BKFileExists(FromFile) then begin
      Msg := Format('The file %s does not exist', [FromFile]);
      LogUtil.LogMsg(lmError, UnitName, format('%s : %s', [ThisMethodName, Msg]));
      raise ERefreshFailed.Create(Msg);
   end;
   Result := TChart.Create(MyClient.ClientAuditMgr);
   lFile := TStringList.Create;
   lLine := TStringList.Create;
   try
      lLine.Delimiter := ',';
      lLine.StrictDelimiter := True;
      try
         lfile.LoadFromFile(FromFile);
      except
         on E: Exception do
            raise ERefreshFailed.Create( Format('Cannot read file %s : %s', [FromFile, e.Message]));
      end;

      if lFile.Count < 1 then
          raise ERefreshFailed.Create( Format('File %s is empty', [FromFile]));


      for I := 0 to lFile.Count - 1 do begin
         LLine.DelimitedText := lFile[I];
         if (LLine.Count < colDesc ) then
            Continue; // Maybe just a blank line at the end...
             //raise ERefreshFailed.Create( Format('File %s is the wrong format', [FromFile]));

         aCode := Trim(lLine[colCode]);
         aDesc := Trim(lLine[colDesc]);

         if (aCode > '') then begin
            if (Result.FindCode(ACode) <> nil) then
               LogUtil.LogMsg(lmError, UnitName,format('Duplicate Code %s found in %s',[ACode, FromFile]))
            else begin
               //insert new account into chart
               NewAccount := New_Account_Rec;
               with NewAccount^ do begin
                  chAccount_Code  := ACode;
                  chAccount_Description := ADesc;
                  chPosting_Allowed := True;
               end;
               Result.Insert(NewAccount);
            end;
         end;
      end;


   finally
      FreeAndNil(LFile);
      FreeAndNil(lLine);
   end;
end;



procedure RefreshChart;
const
   ThisMethodName    = 'RefreshChart';
var
   Sage50FileName : String;
   ChartFilePath : string;
   NewChart : TChart;
   Msg : string;
begin
   if DebugMe then
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then
      Exit;

   with MyClient.clFields do begin

      Sage50FileName := clLoad_Client_Files_From;

      if DirectoryExists(Sage50FileName) then begin// User only specified a directory - we need a filename
         Sage50FileName := '';
         ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end else
         ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

      if not BKFileExists( Sage50FileName ) then Begin
         Sage50FileName := ChartUtils.GetChartFileName(
               clCode,
               ExtractFilePath(ChartFilePath),
               'Sage50 Files|*.CSV',
               'CSV',
                0 );
         if Sage50FileName = '' then
            Exit;
      end;

      try
         NewChart := LoadSage50Chart(Sage50FileName);

         if NewChart.ItemCount > 0 then begin
            MergeCharts(NewChart, MyClient);
            clLoad_Client_Files_From := Sage50FileName;
            clChart_Last_Updated  := CurrentDate;
            HelpfulInfoMsg( 'The client''s chart of accounts has been refreshed.', 0 );
         end;

         NewChart.Free;

      except
         on E : ERefreshFailed do begin
            Msg := Format( 'Error Refreshing Chart: %s', [ E.Message ] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
            exit;
         end;
         on E : EInOutError do begin //Normally EExtractData but File I/O only
            Msg := Format( 'Error Refreshing Chart %s. %s', [ Sage50FileName, E.Message ] );
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
            HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
            exit;
         end;
      end; {except}
   end; {with}
   if DebugMe then
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

Initialization
   DebugMe := LogUtil.DebugUnit(UnitName);
end.
