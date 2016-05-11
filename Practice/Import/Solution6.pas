unit Solution6;
//------------------------------------------------------------------------------
{
   Title:        Solution 6 MAS chart import

   Description:  Solution 6 MAS chart import routines

   Author:       Stephen Agnew

   Remarks:

   Revisions:    SOL 6 COM interface added Sep 2005

   Author        Matthew Hopkins

                 This interface requires the S6BNK.DLL file to be installed on
                 the workstation.  If the com interface is available BK5 will
                 use it, otherwise the standard MAS interface will be used.

                 The COM interface does not produce or use any intermediate files.
                 All information such as the chart or extracted data is exchanged
                 via XML strings.

}
//------------------------------------------------------------------------------
interface
//------------------------------------------------------------------------------
uses chList32;

procedure RefreshChart;

{$IFDEF BK_UNITTESTINGON}
procedure ProcessXMLChart( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
{$ENDIF}


//------------------------------------------------------------------------------
implementation
//------------------------------------------------------------------------------

uses
  Globals, sysutils, InfoMoreFrm, bkconst, bkchio, bkdefs, ovcDate,
  ErrorMoreFrm, Windows,stStrs, YesNoDlg, BK5Except, ChartUtils, LogUtil, stDateSt,
  GenUtils, Progress, BaUtils, bkDateUtils, Templates, GSTCalc32, WinUtils,

  Software,
  Select_Mas_GlFrm,
  Sol6_Const,
  Sol6_Utils,
  OmniXML,
  OmniXMLUtils,
  XMLUtils;

const
  UnitName     = 'SOLUTION6';
  COM_TIMEOUT  = 120000;  {ms.  = 2 minutes}
  S6COM_FILE   = 'S6BNK.COM';
var
  DebugMe      : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GSTCodesInChart( ChtFileName : String ): Boolean;

Var
   InFile : Text;
   InBuf  : Array[ 1..8192 ] of Byte;
   Line   : ShortString;
   Fields : Array[ 1..3 ] of ShortString;
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
         For i := 1 to 3 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );
         If StrToIntSafe( Fields[ 3 ] ) > 0 then
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

function ExecCmd(sExecutableFilePath : string ): boolean;
const
   ThisMethodName = 'ExecCmd';
Var
   pi: TProcessInformation;
   si: TStartupInfo;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called with '+sExecutableFilePath );

   FillMemory( @si, sizeof( si ), 0 );
   si.cb := sizeof( si );
   result := CreateProcess( Nil,PChar( sExecutableFilePath ),Nil, Nil, False, NORMAL_PRIORITY_CLASS, Nil, Nil, si, pi );

  //Wait Until Finished
   WaitforSingleObject(pi.hProcess,COM_TIMEOUT);
   CloseHandle( pi.hProcess );
   CloseHandle( pi.hThread );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function GetS6RootDir : String ;
Begin
   Result := '';
   If Assigned( AdminSystem ) then 
      With AdminSystem.fdFields do
         If ( fdAccounting_System_Used in 
             [ 
               snSolution6CLS3   ,
               snSolution6CLS4   ,
               snSolution6MAS41  ,
               snSolution6MAS42  ,
               snSolution6CLSY2K
             ] )
         then
            Result := fdLoad_Client_Files_From;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure InsertIntoChart( newChart : TChart; aCode : bk5CodeStr; aDesc : string; aGST_Class : integer; aPosting : boolean; var HasDuplicates : boolean);
var
  NewAccount : pAccount_Rec;
begin
  //check if this is a duplicate code
  if newChart.FindCode( aCode) = nil then
  begin
     //insert new account into chart
     NewAccount := New_Account_Rec;
     with NewAccount^ do
     begin
       chAccount_Code        := aCode;
       chAccount_Description := aDesc;
       chGST_Class           := aGST_Class;
       chPosting_Allowed     := aPosting;

       if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, Format(' Inserting Code %s %s',[ aCode, aDesc]));
       newChart.Insert(NewAccount);
     end;
  end
  else
  begin
     HasDuplicates := true;
     LogUtil.LogMsg(lmInfo, UnitName, Format('Duplicate Code Found %s %s',[ aCode, aDesc ]));
  end;
end;

// - - - - - - - - - - - - -- - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ReadChartFromS6BNK( ClientRef : string; ChartFilename : string; aChart : TChart );
const
  ThisMethodName = 'ReadChartFromS6BNK';
var
  Com_File : string;
  f : textfile;
  InBuf             : Array[ 1..8192 ] of Byte;
  Line              : String;
  TempFileName      : string;
  ACode             : Bk5CodeStr;
  ADesc             : String[80];
  AGSTInd           : String[10];
  Parameters        : string;
  Msg               : String;
  TemplateFileName  : String;
  Fields            : Array[ 1..3 ] of ShortString;
  i                 : integer;
  HasDuplicates     : boolean;
  TemplateError : TTemplateError;
begin
  COM_FILE := EXECDIR + S6COM_FILE;

  if not BKFileExists( COM_FILE ) then
  begin
     Msg := Format( 'Unable to Import Chart. %s does not exist', [ COM_FILE ] );
     LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
     Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
  end;

  UpdateAppStatus('Loading Chart','',0);

  TempFileName := ClientRef + '.CHT';
  SysUtils.DeleteFile( TempFileName );

  Parameters      := ChartFileName + ' ' + TempFileName;

  UpdateAppStatusLine2('Extracting Chart');

  {run external program and wait for it to finish}
  ExecCmd( COM_FILE+' '+Parameters);   {solution 6 provided com file to extract their chart}
  try
    if BKFileExists( TempFileName ) then
    begin

      If ( MyClient.clFields.clCountry = whAustralia ) and GSTCodesInChart( TempFileName ) and not ( MyClient.GSTHasBeenSetup ) then
      Begin
         TemplateFileName := GLOBALS.TemplateDir + 'SOL6.TPM';
         If BKFileExists( TemplateFileName ) then
           Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
      end;

      {have a file to import - import into a new chart object}

      AssignFile( F, TempFileName );
      SetTextBuf( F, InBuf );
      Reset( F );
      try
        UpdateAppStatusLine2('Reading');

        While not EOF( F ) do
        Begin
           Readln( F, Line );
           For i := 1 to 3 do Fields[ i ] := TrimSpacesAndQuotes( ExtractAsciiS( i, Line, ',', '"' ) );

           {get information from this line}

           ACode   := Fields[1];
           ADesc   := Fields[2];
           AGSTInd := Fields[3];

           InsertIntoChart( aChart, aCode, aDesc, GSTCalc32.GetGSTClassNo( MyClient, AGSTInd ), true, hasDuplicates);
        end;
      finally
        CloseFile(f);
      end;
    end
    else begin
       Msg := Format( 'Unable to Import Chart. %s %s did not produce a Chart File',[ COM_FILE, Parameters ] );
       LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
       Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
    end;
  finally
    sysUtils.DeleteFile(TempFileName);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure SetMAS3Names( var ChartFilename, Filter : string);
Begin
  with MyClient.clFields do
  begin
     If ( clLoad_Client_Files_From = '' ) then
       clLoad_Client_Files_From := AddSlash( GetS6RootDir ) + AddSlash( clCode );

     ChartFileName := AddSlash(clLoad_Client_Files_From) + 'DZZMA010';
     Filter        := 'Solution 6 MAS3 Chart File (DZZMA010)|DZZMA010';
  end;
end;

procedure SetMAS4Names( var ChartFilename, Filter : string);
Begin
  with MyClient.clFields do
  begin
     If ( clLoad_Client_Files_From = '' ) then
       clLoad_Client_Files_From := AddSlash( GetS6RootDir ) + AddSlash( clCode );

     ChartFileName := AddSlash(clLoad_Client_Files_From) + 'DZZMP100';
     Filter        := 'Solution 6 MAS4 Chart File (DZZMP100)|DZZMP100';
  end;
end;

procedure SetMASExtdNames( var ChartFilename, Filter : string);
//mas 6 provided the users with the ability to see 10 character ledger names,
var
  CodeToUse : string;
Begin
  with MyClient.clFields do
  begin
     //set default code if blank
     if ( clLoad_Client_Files_From = '' ) then
     begin
       if clUse_Alterate_ID_for_extract then
         CodeToUse := clAlternate_Extract_ID
       else
         CodeToUse := clCode;

       clLoad_Client_Files_From := AddSlash( GetS6RootDir ) + AddSlash( CodeToUse );

     end;

     ChartFileName := AddSlash(clLoad_Client_Files_From) + 'DZZMP100';
     Filter        := 'Solution 6 MAS4 Chart File (DZZMP100)|DZZMP100';
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

{ sample :
- <xml>
- <status>
  <code>0</code> 
  <message>OK</message>
  </status>
- <chart>
    <account>638</account>
    <description>Retained Profits - Beginning of Year</description>
    <gstid />
    <posting>N</posting>
    <account>639</account>
    <description>Profits Earned This Year</description>
    <gstid />
    <posting>Y</posting>
    <account>969</account>
    <description>SUSPENSE ACCOUNT (Balance Sheet)</description>
    <gstid />
    <posting>N</posting>
  </chart>
  </xml>
}


procedure ProcessXMLChart( xmlChart : string; NewChart: TChart; var HasDuplicates : boolean);
var
  xmlParser : IXMLDocument;
  ChartNode, n : IXmlNode;
  ChartList : IXmlNodeList;
  i : integer;
  acCode : bk5CodeStr;
  acDesc : string;
  acGSTClass : integer;
  acGSTIndicator : string;
  isPosting : boolean;
  ChartCount : integer;
  InChartCode : boolean;
  s : string;
begin
  //initialise
  HasDuplicates := false;

  //translate xml chart into bk5 chart structure
  xmlParser := CreateXMLDoc;
  try
    xmlParser.PreserveWhiteSpace := false;
    if XMLLoadFromString( xmlParser, xmlChart) then
    begin
      n := bkSelectChildNode( xmlParser.FirstChild, 'chart');
      ChartList := n.ChildNodes;
      try
        ChartCount := 0;
        InChartCode := false;
        acCode := '';
        acDesc := '';
        acGSTClass := 0;
        acGSTIndicator := '';
        isPosting := false;

        for i := 0 to ChartList.Length - 1 do
        begin
          //the list of nodes consists of lines for account, desc, gst, posting
          ChartNode := ChartList.Item[i];
          if ChartNode.NodeName = 'account' then
          begin
            ChartCount := ChartCount + 1;
            if ChartCount > 1 then
            begin
              //add existing chart to list before storing data for next
              InsertIntoChart( NewChart, acCode, acDesc, acGSTClass, IsPosting, HasDuplicates);
            end;

            InChartCode := true;
            acCode :=  GetNodeText( ChartNode);
            acDesc := '';
            acGSTClass := 0;
            acGSTIndicator := '';
            isPosting := true;
          end;

          if ChartNode.NodeName = 'description' then
          begin
            acDesc := GetNodeText( ChartNode);
          end;

          if ChartNode.NodeName = 'gstid' then
          begin
            acGSTIndicator := GetNodeText( ChartNode);
            acGSTClass := GSTCalc32.GetGSTClassNo( MyClient, acGSTIndicator );
          end;

          if ChartNode.NodeName = 'posting' then
          begin
            s := GetNodeText( ChartNode);
            if not (( s = 'Y') or ( s = 'N')) then
              raise EBkXMLError.Create( 'Unexpected boolean identifier "' + s + '" ( Count = ' + inttostr( ChartCount) + ')');

            isPosting := (s = 'Y');
          end;
        end;

        //insert last chart code
        if InChartCode then
        begin
          //add existing chart to list
          InsertIntoChart( NewChart, acCode, acDesc, acGSTClass, IsPosting, HasDuplicates);
        end;
      finally
        ChartList := nil;
      end;
    end
    else
      raise EBkXMLError.Create( 'XML parse error: ' + xmlParser.ParseError.Reason);
  finally
    xmlParser := nil;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ReadChartFromS6BNK_DLL( ClientCode : string; LedgerPath : string; aChart : TChart);
const
  ThisMethodName = 'ReadChartFromS6BNK_DLL';
var
  XmlChart : string;
  HasDuplicates : boolean;
  TemplateFilename : string;
  TemplateError : TTemplateError;
begin
  try
    //get the chart in xml format from bclink
    xmlchart := Sol6_utils.GetXMLChart( ClientCode, LedgerPath);

    if DebugMe then
      SaveXMLStringToFile( xmlChart, DataDir + 'mas_chart_' +  ClientCode + '.xml');

    //convert the xml into a banklink chart
    ProcessXMLChart( xmlChart, aChart, HasDuplicates);

    //set up bas rules
    if ( MyClient.clFields.clCountry = whAustralia ) and (not MyClient.GSTHasBeenSetup ) then
    begin
       TemplateFileName := GLOBALS.TemplateDir + 'SOL6.TPM';
       if BKFileExists( TemplateFileName ) then
         Template.LoadTemplate( TemplateFilename, tpl_DontCreateChart, TemplateError );
    end;
  except
    on E : ERefreshAbandoned do
    begin
      //let refresh code know that user abandoned so exist gracefully
      raise ERefreshAbandoned.Create('');
    end;

    on E : Exception do
    begin
      raise EExtractData.Create( ThisMethodName + ' failed: ' + E.Message );
    end;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
Var
   LoadFromPath      : string;
   NewChart          : TChart;
   i                 : integer;
   This,Next         : pAccount_Rec;
   ThisCode, NextCode: string;
   ExtraData         : string;
   Msg               : string;
   ChartFileName     : string;
   Filter            : string;
   r                 : integer;
   IsCOMInterface    : boolean;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then
    exit;

  IsCOMInterface := Software.IsSol6_COM_Interface( MyClient.clFields.clCountry, MyClient.clFields.clAccounting_System_Used);

  if not IsCOMInterface  then
  begin
    case MyClient.clFields.clCountry of
      whNewZealand :
         case MyClient.clFields.clAccounting_System_Used of
            snSolution6CLS3   : SetMAS3Names( ChartFilename, Filter);
            snSolution6CLS4   : SetMAS4Names( ChartFilename, Filter);
            snSolution6MAS41  : SetMAS4Names( ChartFilename, Filter);
            snSolution6MAS42  : SetMASExtdNames( ChartFilename, Filter);
            snSolution6CLSY2K : SetMAS4Names( ChartFilename, Filter);
         end;
      whAustralia  :
         case MyClient.clFields.clAccounting_System_Used of
            saSolution6CLS3   : SetMAS3Names( ChartFilename, Filter);
            saSolution6CLS4   : SetMAS4Names( ChartFilename, Filter);
            saSolution6MAS41  : SetMAS4Names( ChartFilename, Filter);
            saSolution6MAS42  : SetMASExtdNames( ChartFilename, Filter);
            saSolution6CLSY2K : SetMAS4Names( ChartFilename, Filter);
         end;
    end;

    {check file exists, ask for a new one if not}

    if not BKFileExists(ChartFileName) then
    begin
      If not ChartUtils.LoadChartFrom( MyClient.clFields.clCode,
                                       ChartFileName,
                                       MyClient.clFields.clLoad_Client_Files_From,
                                       Filter, '', 0 ) then exit;
    end;
  end
  else
  begin
    //com based interface, chart will be returned as an xml string
    LoadFromPath := MyClient.clFields.clLoad_Client_Files_From;

    if LoadFromPath = '' then
    begin
      r := SelectMAS_GL_Path( LoadFromPath, INI_SOL6_SYSTEM_PATH);
      case r of
         bkS6_COM_Refresh_Supported_User_Selected_Ledger : ChartFilename := LoadFromPath;
         bkS6_COM_Refresh_Supported_User_Cancelled : Exit;
      else
        begin
          HelpfulErrorMsg( 'Could not access the list of ' + GetS6MAS_Name(MyClient.clFields.clCountry) +
                           ' ledger paths', 0);
          Exit;
        end;
      end;

    end;
  end;

  //have load from path, now retrieve chart and merge it
  with MyClient.clFields do
  begin
    try
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      UpdateAppStatus('Loading Chart', 'Reading Chart', 0);
      try
        if IsCOMInterface then
        begin
          ReadChartFromS6BNK_DLL( clCode, LoadFromPath, NewChart);
        end
        else
        begin
          ReadChartFromS6BNK(clCode, ChartFilename, NewChart);
        end;

        //have new chart, process it and merge
        if NewChart.ItemCount > 0 then
        begin
           {mark which accounts are posting accounts}
           for i := 0 to Pred(NewChart.ItemCount) do
           begin
             This := NewChart.Account_At(i);
             ThisCode := This.chAccount_Code;

             if (i+1) < newChart.ItemCount then
             begin
               Next := NewChart.Account_At(i+1);
               NextCode := Copy(Next.chAccount_Code,1,length(ThisCode));
               ExtraData := Copy(Next.chAccount_Code,Length(ThisCode)+1,10);

               if not IsCOMInterface then
               begin
                 //try to identify header accounts for old format
                 if (Length( ThisCode) = 3) and (NextCode = ThisCode) and IsNumeric(ExtraData) then
                   This.chPosting_Allowed := false;
               end;
             end;
           end;
           MergeCharts(NewChart, MyClient);

           if IsComInterface then
             clLoad_Client_Files_From := LoadFromPath
           else
             clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
           clChart_Last_Updated     := CurrentDate;

           ClearStatus(True);
           HelpfulInfoMsg( 'The clients chart of accounts has been refreshed.', 0 );           
        end;
      finally
        ClearStatus( True);
        NewChart.Free;
      end;
    except
      on E : ERefreshAbandoned do
      begin
        //user abandoned refresh, go quietly
        exit;
      end;

      on E : EExtractData do begin
        //error occured during refresh
        Msg := Format( 'Error refreshing chart %s. ', [ChartFileName] );
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulErrorMsg(Msg+#13'The existing chart has not been modified.', 0, False, E.Message, True);
      end;
    end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
