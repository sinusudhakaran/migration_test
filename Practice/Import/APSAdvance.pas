//------------------------------------------------------------------------------
//
// APSAdvance
//
// APS Personal Accounts import interface
//
unit APSAdvance;

//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------

procedure RefreshChart;

//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  ComObj, IniFiles, Registry, SysUtils, Variants, Windows, 
  Globals, InfoMoreFrm, bkconst, chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, classes, LogUtil, ChartUtils,
  GenUtils, bkDateUtils, glConst, Templates, StStrS, GSTCalc32, YesNoDlg, WinUtils;

Const
  UnitName = 'APSAdvance';
  DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GSTCodesInChart( ChtFileName : String ): Boolean;

var
   InFile : Text;
   InBuf  : Array[ 1..8192 ] of Byte;
   Line   : ShortString;
   Fields : Array[ 1..4 ] of ShortString;
   i      : Byte;
begin
   Result := False;

   AssignFile( InFile, ChtFileName );
   SetTextBuf( InFile, InBuf );
   Reset( InFile ); 
   
   Try
      While not EOF( InFile) Do 
      Begin
         Readln( InFile, Line ); 
         If Line[1] in [ '0'..'9' ] then
         Begin
            FillChar( Fields, Sizeof( Fields ), 0 );
            For i := 1 to 3 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );
            //Check that GST Code is included
            If ( StrToIntSafe( Fields[ 3 ] ) > 0 ) then
            Begin
               Result := True;
               exit;
            end;
         end;
      end;
   Finally
      Close( InFile );
   end;
end;


procedure RefreshChartFromInterface(PALgr : OleVariant);
const
  ThisMethodName = 'RefreshChartFromInterface';
var
  OK         : Boolean;
  PAchart    : Variant;
  lX, i      : Integer;
  NewChart   : TChart;
  NewAccount : pAccount_Rec;
  ACode      : Bk5CodeStr;
  ADesc      : String[80];
  AGSTInd    : String[10];
  MainStr, SubStr : String[10];
  TemplateFileName : String;
  ChartFilename    : string;
  aMsg : string;
  TemplateError : TTemplateError;
begin
  ChartFilename := MyClient.clFields.clLoad_Client_Files_From;

  if DirectoryExists(ChartFileName) then // User only specified a directory - we need a filename
    ChartFileName := '';

  if Trim( ChartFilename) <> '' then
    begin
      //something is in the chart filename field
      aMsg := 'The client''s Chart will be refreshed using ' +
               ExtractFileName( ChartFilename) + '.'+#13#13+'Please confirm this is the '+
               'correct ledger to use.';

      if AskYesNo( 'Refresh Chart', aMsg, dlg_Yes, 0) <> dlg_Yes then
        begin
          //don't want to use this ledger, force dialog from dll
          ChartFilename := '';
        end;
    end;

  //try to connect to the specified MDB, if dll can't locate it then
  //a dialog window will be shown
  OK := PALgr.Connect(ChartFileName);
  if (OK) then
  begin
    OK := False;

    PAchart := PALgr.Chart; //retrieve the chart from PA file

    if ((VarType(PAchart) and varArray) = varArray) then
    begin
      //look for gst template file
      if (MyClient.clFields.clCountry = whAustralia ) and (not MyClient.GSTHasBeenSetup) then
      begin
        TemplateFileName := GLOBALS.TemplateDir + 'APS.TPM';
        if BKFileExists(TemplateFileName) then
          Template.LoadTemplate(TemplateFilename, tpl_DontCreateChart, TemplateError);
      end;

      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      try
        //Subscript 1 (values 0 to 3) identifies the fields
        //Subscript 2 is dimensioned to the number of accounts returned (values 1 to recordcount)
        for lX := VarArrayLowBound(PAchart, 2) to VarArrayHighBound(PAchart, 2) do
        begin
          //rows
          MainStr := VarToStr(PAchart[0, lX]);
          MainStr := Trim(MainStr);
          SubStr  := VarToStr(PAchart[1, lX]);
          SubStr  := Trim(SubStr);

          {see if is a main account - ie can't post}
          if ( SubStr <> '' ) then begin
             for i := 0 to Pred(NewChart.ItemCount) do begin
                with NewChart.Account_At(i)^ do begin
                   if chAccount_Code = MainStr then
                     chPosting_Allowed := FALSE;
                end;
             end;
          end;

          if ( SubStr = '' ) then
            ACode := MainStr
          else
            ACode := MainStr + '/' + SubStr;

          ADesc := VarToStr(PAchart[2, lX]); { "Leasing" }

          //The remaining data contains the GST Code, however
          //the numbers come thru as 01, 02 instead of just 1,2.  Need to strip
          //off leading zero's
          //Match this up to the codes in the table

          //mjch Jun 2004 - #1480  Set the GST class in the chart to N/A if
          //                the rate in the PA chart is not set
          if VarIsNull( PAChart[3, lX]) then
          begin
            AGSTInd := ''
          end
          else
            AGSTInd := VarToStr(PAchart[3, lX]);

          if ( NewChart.FindCode( ACode )<> NIL ) then Begin
            LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ PALgr.ConnectedDB);
          end else
          begin
            {insert new account into chart}
            NewAccount := New_Account_Rec;
            with NewAccount^ do begin
              chAccount_Code        := aCode;
              chAccount_Description := aDesc;
              if (AGSTInd = '') then
                chGST_Class := bkFORCE_GST_CLASS_TO_ZERO  //force the GST Class to be cleared during merge even if set
              else
                chGST_Class := GSTCalc32.GetGSTClassNo( MyClient, AGSTInd );

              chPosting_Allowed     := true;
            end;
            NewChart.Insert(NewAccount);
          end;
        end;

        if (NewChart.ItemCount > 0) then
        begin
          if not MergeCharts(NewChart, MyClient) then
            Exit;

          with MyClient.clFields do
          begin
            clLoad_Client_Files_From := PALgr.ConnectedDB;
            clChart_Last_Updated     := CurrentDate;

            if clAccount_Code_Mask = '' then
              clAccount_Code_Mask := '###/###';
          end;
          OK := True;
        end;
      finally
         NewChart.Free;   {free is ok because Merge charts will have set NewChart to nil}
         if OK then HelpfulInfoMsg( 'The client''s Chart has been refreshed.', 0 );
      end;
    end;
  end;
end;

procedure RefreshChartFromFile;
const
  ThisMethodName = 'RefreshChartFromFile';
var
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
   AGSTInd           : String[10];
   MainStr, SubStr   : String[10];
   Msg               : string;
   OK                : Boolean;
   TemplateFileName  : String;
   ChartFilename     : string;
   ChartFilePath     : string;
   TemplateError     : TTemplateError;
begin
  OK := False;

  with MyClient.clFields do
  begin
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
           'Exported Charts|*.EXP',
           'EXP',
           HCtx ) then
           exit;
     end;

     If ( clCountry = whAustralia ) and GSTCodesInChart( ChartFileName ) and ( not MyClient.GSTHasBeenSetup ) then
     Begin
        TemplateFileName := GLOBALS.TemplateDir + 'APS.TPM';
        If BKFileExists( TemplateFileName ) then
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

              //get information from this line
              If Line[1] in ['0'..'9'] then Begin
                 p := Pos( ',"', Line );
                 ACode := Copy( Line, 1, p-1 ); { 388/ }
                 Line := Copy( Line, p+1, 255 );

                 p := Pos( '/', ACode );
                 MainStr := Copy( ACode, 1, p-1 );
                 SubStr  := Copy( ACode, p+1, 255 );

                 {see if is a main account - ie can't post}
                 if ( SubStr <> '' ) then begin
                    For i:=0 to Pred(NewChart.ItemCount) do begin
                       With NewChart.Account_At(i)^ do begin
                          If chAccount_Code = MainStr then chPosting_Allowed := FALSE;
                       end;
                    end;
                 end;

                 If ( SubStr = '' ) then
                    ACode := MainStr
                 else
                    ACode := MainStr + '/' + SubStr;

                 p := Pos( '",', Line );
                 ADesc := Copy( Line, 1, p ); { "Leasing" }
                 Line := Copy( Line, p+2, 255 );

                 If ADesc[1]= '"' then System.Delete( ADesc, 1, 1 );
                 If ADesc[ Length( ADesc )]='"' then ADesc[0] := Pred( ADesc[0] );

                 //The remaining data in the line contains the GST Code, however
                 //the numbers come thru as 01, 02 instead of just 1,2.  Need to strip
                 //off leading zero's
                 //Match this up to the codes in the table
                 AGSTInd := IntToStr( StrToIntDef(Line, 0));

                 if ( NewChart.FindCode( ACode )<> NIL ) then Begin
                    LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+ACode+' found in '+ChartFileName );
                 end
                 else Begin
                    {insert new account into chart}
                    NewAccount := New_Account_Rec;
                    with NewAccount^ do begin
                       chAccount_Code        := aCode;
                       chAccount_Description := aDesc;
                       if (AGSTInd = '-1') then
                         chGST_Class := bkFORCE_GST_CLASS_TO_ZERO  //force the GST Class to be cleared during merge even if set
                       else
                         chGST_Class := GSTCalc32.GetGSTClassNo( MyClient, AGSTInd );

                       chPosting_Allowed     := true;
                    end;
                    NewChart.Insert(NewAccount);
                 end;
              end;
           end;

           if NewChart.ItemCount > 0 then begin
              if not MergeCharts(NewChart, MyClient) then
                Exit;

              clLoad_Client_Files_From := ChartFileName;
              clChart_Last_Updated     := CurrentDate;

              If clAccount_Code_Mask = '' then
                 clAccount_Code_Mask := '###/###';
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
           HelpfulErrorMsg( Msg+#13'The existing chart has not been modified.', 0, false, E.Message, True);
           Exit;
        end;
     end; {except}
  end; {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure RefreshChart;
const
  ThisMethodName = 'RefreshChart';
var
  PALgr : OleVariant;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then
    exit;

  //test to see if PA chart dll exists
  try
    PALgr := CreateOLEObject('aPALedger.advLedger');
  except
  //invalid class string
  PALgr := UnAssigned;
  end;

  //if cannot connect to the APS interface DLL, use existing File based transfer
  if (VarIsEmpty(PALgr)) then
    RefreshChartFromFile
  else
    try
      RefreshChartFromInterface(PALgr);
    finally
      PALgr := UnAssigned;
    end;
end;
//------------------------------------------------------------------------------


Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

