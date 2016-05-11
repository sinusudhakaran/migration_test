unit CSVChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Type
   TGSTIndType = ( iNumeric, iText );

Function RefreshChart( Const ASuffix, ATemplate : ShortString; 
                       Const GSTIndType : TGSTIndType ): Boolean;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  Globals, sysutils, InfoMoreFrm, bkconst, chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, classes, LogUtil, ChartUtils, 
  GenUtils, bkDateUtils, glConst, StStrS, Templates, GSTCalc32, WinUtils;

Const
   UnitName = 'CSVChart';
   DebugMe  : Boolean = False;
   
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GSTCodesInChart( ChtFileName : String ): Boolean;

Var
   InFile : Text;
   InBuf  : Array[ 1..8192 ] of Byte;
   Line   : ShortString;
   Fields : Array[ 1..4 ] of ShortString;
   i      : Byte;
Begin
   Result := False;

   AssignFile( InFile, ChtFileName ); 
   SetTextBuf( InFile, InBuf );
   Reset( InFile ); 
   
   Try
      While not EOF( InFile) Do
      Begin 
         Readln( InFile, Line ); 
         FillChar( Fields, Sizeof( Fields ), 0 );
         For i := 1 to 4 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );
         If Fields[ 4 ] <> '' then 
         Begin
            Result := True;
            exit;
         end;
      end;
   Finally
      Close( InFile );
   end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function RefreshChart( Const ASuffix, ATemplate : ShortString; 
                       Const GSTIndType : TGSTIndType ): Boolean;

const
   ThisMethodName    = 'RefreshChart';
var
   ChartFileName     : string;
   ChartFilePath     : string;
   HCtx              : integer;
   F                 : TextFile;
   Buffer            : array[ 1..8192 ] of Byte;
   Line              : String;
   Fields            : Array[ 1..4 ] of ShortString;
   NewChart          : TChart;
   NewAccount        : pAccount_Rec;
   i                 : integer;
   ACode             : Bk5CodeStr;
   ADesc             : String[80];
   APostOK           : String[10];
   AGSTInd           : String[10];
   Msg               : string;
   OK                : Boolean;
   TemplateFileName  : ShortString;
   UnknownGSTCodesFound : Boolean;
   TemplateError     : TTemplateError;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False;
   if not Assigned(MyClient) then exit;

   OK := False;
   UnknownGSTCodesFound := False;
   
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
           'Exported Charts ('+ ASuffix+')|' + ASuffix,
           ASuffix,
           HCtx ) then
           exit;
     end;

     If GSTCodesInChart( ChartFileName ) and ( not MyClient.GSTHasBeenSetup ) then
     Begin
        TemplateFileName := GLOBALS.TemplateDir + ATemplate;
        // make sure chart is not a directory!
        If BKFileExists( TemplateFileName ) and (not DirectoryExists(TemplateFileName)) then
          Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
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
              FillChar( Fields, Sizeof( Fields ), 0 );
              For i := 1 to 4 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );

              aCode    := Fields[1];
              aDesc    := Fields[2];
              aPostOK  := Fields[3];
              aGSTInd  := Fields[4];

              If ( aCode <> '' ) and ( UpperCase( aCode ) <> 'CODE' ) then
              Begin
                 If (NewChart.FindCode(ACode) <> Nil) Then
                     LogUtil.LogMsg(lmError, UnitName, 'Duplicate Code ' + ACode
                        + ' found in ' + ChartFileName)
                 Else
                 Begin
                    {insert new account into chart}
                    NewAccount := New_Account_Rec;
                    With NewAccount^ Do
                    Begin
                       chAccount_Code        := ACode;
                       chAccount_Description := ADesc;

                       If ( GSTIndType = iNumeric ) then
                       Begin
                          i := StrToIntSafe( aGSTInd );
                          If ( i in GST_CLASS_RANGE ) then chGST_Class := i;
                       end
                       else
                       Begin
                          chGST_Class := GSTCalc32.GetGSTClassNo( MyClient, aGSTInd );
                          if ( chGST_Class = 0 ) and ( aGSTInd <> '' ) then
                          begin
                             LogUtil.LogMsg(lmError, UnitName, 'Unknown GST Indicator ' + AGSTInd + ' found in ' + ChartFileName + ': '+ Line );
                             UnknownGSTCodesFound := True;
                          end;
                       end;
                       chPosting_Allowed := ( (aPostOK = 'Y') or (aPostOK = 'y') );
                    End;
                    NewChart.Insert(NewAccount);
                 End; { not ((NewChart.FindCode(ACode) <> Nil)) }
              End;
           end;
           if NewChart.ItemCount > 0 then begin
              MergeCharts(NewChart, MyClient);
              clLoad_Client_Files_From := ChartFileName;
              clChart_Last_Updated     := CurrentDate;
              OK := True;
           end;
        finally
           NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
           CloseFile(f);

           if OK then
           begin
             Msg := 'The client''s chart of accounts has been refreshed.';
             HelpfulInfoMsg( Msg, 0 );
           end;

           if UnknownGSTCodesFound then
           begin
             Msg := 'The new chart file contained unknown GST Indicators';
             LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
           end;
           Result := True;
        end;
     except
        on E : EInOutError do begin // File I/O only
           Msg := Format( 'Error refreshing chart %s.', [ChartFileName] );
           LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
           HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
           Exit;
        end;
     end; {except}
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

