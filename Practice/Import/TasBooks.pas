unit TasBooks;

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
   UnitName = 'TasBooks';
   DebugMe  : Boolean = False;

   hCode = 'Account No';
   hDesc = 'Description';
   hActive = 'Active?';


function LoadTasBookChart(FromFile: TFileName): TChart;
const
   ThisMethodName = 'LoadTasBookChart';
var
   Msg: string;
   lFile,
   lLine : TStringList;
   I: Integer;
   aCode: string[20];
   aDesc: string[60];
   colCode,
   colDesc,
   colActive: integer;
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
   Result := TChart.Create;
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
      colCode := -1;
      colDesc := -1;
      colActive := -1;
      LLine.DelimitedText := LFile[0]; // read the Header
      for I := 0 to lLine.Count - 1 do begin
          if SameText(hCode,lLine[i]) then
             colCode := i
          else if SameText(hDesc,lLine[i]) then
             colDesc := i
          else if SameText(hActive,lLine[i]) then
             colActive := i
      end;

      if (colCode < 0)
      or (colDesc < 0)then
          raise ERefreshFailed.Create(Format('File %s is the wrong format', [FromFile]));

      for I := 1 to lFile.Count - 1 do begin// Skip The HeaderLine
         LLine.DelimitedText := lFile[I];
         if (colCode >= LLine.Count)
         or (colDesc >= LLine.Count) then
            continue; // Maybe jus a blank line at the end...
            //raise ERefreshFailed.Create(Format('File %s is the wrong format', [FromFile]));

         aCode := Trim(lLine[colCode]);
         aDesc := trim(lLine[colDesc]);

         if (aCode > '') then begin

            if aCode[1] = '*' then
               Break; // Footer Block

            if (result.FindCode(ACode) <> nil) then
               LogUtil.LogMsg(lmError, UnitName,format('Duplicate Code %s found in %s',[ACode, FromFile]))
            else begin
               {insert new account into chart}
               NewAccount := New_Account_Rec;
               with NewAccount^ do begin
                  chAccount_Code := ACode;
                  chAccount_Description := ADesc;
                  chPosting_Allowed := True; //Default

                  if (colActive > -1)
                  and (colActive < LLine.Count) then begin
                     ACode := Uppercase(LLine[colActive]);
                     if (ACode > '')
                     and (ACode[1] <> 'Y') then
                        chPosting_Allowed := False;
                  end;

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
   TasBookFileName : String;
   ChartFilePath : string;
   NewChart : TChart;
   Msg : string;
begin
   if DebugMe then
       LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   if not Assigned(MyClient) then
      Exit;

   with MyClient.clFields do begin

      TasBookFileName := clLoad_Client_Files_From;

      if DirectoryExists(TasBookFileName) then begin// User only specified a directory - we need a filename
         TasBookFileName := '';
         ChartFilePath := AddSlash(clLoad_Client_Files_From);
      end else
         ChartFilePath := RemoveSlash(clLoad_Client_Files_From);

      if not BKFileExists( TasBookFileName ) then Begin
         TasBookFileName := ChartUtils.GetChartFileName(
               clCode,
               ExtractFilePath(ChartFilePath),
               'TasBook Files|*.CSV',
               'IIF',
                0 );
         if TasBookFileName = '' then
            Exit;
      end;

      try
         NewChart := LoadTasBookChart(TasBookFileName);

         if NewChart.ItemCount > 0 then begin
            MergeCharts(NewChart, MyClient);
            clLoad_Client_Files_From := TasBookFileName;
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
            Msg := Format( 'Error Refreshing Chart %s. %s', [ TasBookFileName, E.Message ] );
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
