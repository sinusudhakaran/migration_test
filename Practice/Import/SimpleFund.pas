unit SimpleFund;
//------------------------------------------------------------------------------
{
   Title:         BGL Simple Fund Chart Refresh

   Description:

   Remarks:       GST Class information is not included in the chart file.
                  The default gst info is set automatically in SimpleFund using a function
                  so cannot be exported.

   Author:

}
//------------------------------------------------------------------------------

interface

uses
  chList32;


procedure RefreshChart;
procedure ReadCSVFile(FilePath: string; NewChart: TChart);
function FetchCOSFromAPI(NewChart: TChart) : boolean;
//******************************************************************************
implementation

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, dbaseReader, stDateSt, WarningMoreFrm, 
  ChartUtils, GenUtils, bkDateUtils, Progress, LogUtil, bk5Except, WinUtils,
  Classes, glConst, uBGLServer;

const
  SF_FILE  = 'CHART.DBF';
  SF360_File = 'CHART.CSV';
  SF_EXTN  = 'DBF';
  SF360_EXTN = 'CSV';
  UnitName = 'SIMPLEFUND';
  DebugMe  : Boolean = False;

var
  SFFileName : string;

//------------------------------------------------------------------------------

procedure ReadDBaseFile(ClientRef : string; FilePath : string; Chart : TChart);
const
  ThisMethodName = 'ReadDBaseFile';
var
 DBaseFile            : tDBaseFile;
 i                    : integer;
 Deleted              : boolean;
 Code                 : Bk5CodeStr;
 Name                 : ShortString;
 return               : integer;
 NewAccount           : pAccount_Rec;
 ACode1,ACode2, AType,
 ASXCode : ShortString;
 Msg                  : string;

begin
 if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

 //check for existence of both files}
 if not BKFileExists(FilePath + SFFileName) then begin
    Msg := Format('Cannot Find The Account File %s%s', [ FilePath, SFFileName ]);
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
    raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
 end;
 ACode1 := '';

 try
   DBaseFile := tDBaseFile.Create(FilePath + SFFileName);
   for I := 0 to DBaseFile.FieldList.ItemCount - 1 do
       ACode1 := ACode1 + ', ' + TDBaseField(DBaseFile.FieldList.Items[i]).FieldName ;
   try
     for i := 1 to DBaseFile.Header.NrOfRecs do begin
       DBaseFile.gotoRecord(i);
       return := DBaseFile.GetField(DelMarkName, BooleanCType, Deleted);
       if (return = 0)
       and (not Deleted) then begin
          ACode1      := '';
          ACode2      := '';
          AType       := ' ';
          Name       := '';

          DBaseFile.GetField( 'ACODE1', StringCType, ACode1 );
          ACode1 := Trim( ACode1 );

          DBaseFile.GetField( 'ACODE2', StringCType, ACode2 );
          ACode2 := Trim( ACode2 );

          DBaseFile.GetField( 'ATYPE', CharCType, AType );

          DBaseFile.GetField( 'ANAME', StringCType, Name );
          Name := Trim(Name);

          DBaseFile.GetField( 'ASXCODE', StringCType, ASXCode );
          ASXCode := Trim(ASXCode);

          Code := ACode1;
          If ACode2<>'' then
              Code := ACode1 + '/'+ACode2;


          { Simple Fund Chart Types are
             C = Control Account
             N = Normal Account
             S = Subaccount }

          if Code <> '' then begin
             if (Chart.FindCode( Code )<> NIL ) then Begin
                LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+Code+' found in '+FilePath + SFFileName );
             end else Begin
                //insert new account into chart
                NewAccount := New_Account_Rec;
                with NewAccount^ do begin
                  chAccount_Code        := Code;
                  chAccount_Description := Name;
                  chGST_Class           := 0;
                  chPosting_Allowed     := (AType <> 'C');
                  if ASXCode > '' then
                     chAlternative_Code  :=  ACode1 + '/' + AnsiUppercase(ASXCode);
                end;
                Chart.Insert(NewAccount);
             end;
          end;
       end;
     end;
   finally
     DBaseFile.Free;
   end;
 except
   on E: Exception do begin
     HelpfulInfoMsg( Format('Cannot Load The Account File %s%s', [ FilePath, SFFileName ]), 0 );
   end;
 end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------

procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';  
var
   ChartFileName     : string;
   HCtx              : integer;
   NewChart          : TChart;
   Msg               : string;
   FileType          : string;
   Extn              : string;
   UsingBGL360       : boolean;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then
     Exit;

  with MyClient.clFields do begin
    if (clAccounting_System_Used <> saBGL360) then //BGL360 fetches from API and no longer from CSV File
    begin
      SFFileName := SF_File;
      Extn       := SF_EXTN;

      if clLoad_Client_Files_From = '' then
        ChartFileName := ''
      else if DirectoryExists(clLoad_Client_Files_From) then
        ChartFileName := AddSlash(clLoad_Client_Files_From) + SFFileName
      else
        ChartFileName := clLoad_Client_Files_From;
      //check file exists, ask for a new one if not
      if not BKFileExists(ChartFileName) then begin
        HCtx := 0; //hcSFUND001;
        if clAccounting_System_Used = saBGLSimpleLedger then
          FileType := 'Simple Ledger File'
        else
          FileType := 'Simple Fund File';
        if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,FileType + '|'+'*.'+Extn,Extn,HCtx) then
          Exit;
      end;
    end;

    try
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      UpdateAppStatus('Loading Chart','Reading Chart',0);
      try
        if (clAccounting_System_Used = saBGL360) then
//BGL360 fetches from API and no longer from CSV File          ReadCSVFile(ChartFileName, NewChart)
          if not FetchCOSFromAPI( NewChart ) then begin // Could not retreive the chart
            Msg := 'Please select a Fund to refresh the chart from, via Other Functions | Accounting System';
            LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Fund not selected.'  );
            HelpfulErrorMsg( 'Please select a Fund to refresh the chart from, ' +
              'via Other Functions | Accounting System' + #13+#13+
              'The existing chart has not been modified.', 0 );
            exit;
          end
          else 
        else
          ReadDBaseFile(clCode, ExtractFilePath(ChartFileName), NewChart);
        If NewChart.ItemCount > 0 then begin              //  Assigned( NewChart ) then  {new chart will be nil if no accounts or an error occured}
           UsingBGL360 := clAccounting_System_Used = saBGL360;
           MergeCharts(NewChart,MyClient,false,UsingBGL360,false);
           if not UsingBGL360 then                        //BGL360 fetches from API and no longer from CSV File
             clLoad_Client_Files_From := ChartFileName;
           clChart_Last_Updated := CurrentDate;
        end
        else begin
           Msg := 'Cannot Read Clients Chart';
           LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
           raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
        end;
        ClearStatus(True);
        HelpfulInfoMsg( 'The clients chart of accounts has been refreshed.', 0 );
      finally
        ClearStatus(True);
        NewChart.Free;
      end;
   except
      on E : EInOutError do begin //Normally EExtractData but File I/O only
          Msg := Format( 'Error Refreshing Chart %s. %s', [ChartFileName, E.Message ] );
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
          exit;
      end;
   end;
 end;  {with}
end;

procedure ReadCSVFile(FilePath: string; NewChart: TChart);
const
  ThisMethodName = 'ReadCSVFile';
var
  AccountType : string;
  CSVFile     : TextFile;
  FieldList   : TStringList;
  Line        : string;
  Msg         : string;
  NewAccount  : pAccount_Rec;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins');

  // Check if chart file exists
  if not BKFileExists(FilePath) then
  begin
    Msg := Format('Cannot Find The Account File %s%s', [ FilePath ]);
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
    raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
  end;

  try
    UpdateAppStatus('Loading Chart','',0);
    try
      AssignFile(CSVFile, FilePath);
      Reset(CSVFile);
      try
        UpdateAppStatusLine2('Reading');
        ReadLn(CSVFile, Line); // just skipping past the headers
        FieldList := TStringList.Create;
        while not EOF(CSVFile) do
        begin
          ReadLn(CSVFile, Line);
          FieldList.Delimiter := ',';
          FieldList.StrictDelimiter := True;
          FieldList.DelimitedText := Line;
          if (NewChart.FindCode(FieldList.Strings[0]) <> nil) then
            LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+FieldList.Strings[0]+' found in '+FilePath )
          else
          begin
            NewAccount := New_Account_Rec;
            NewAccount^.chAccount_Code := FieldList.Strings[0];
            AccountType := FieldList.Strings[1];
            NewAccount^.chAccount_Type := ord(AccountType[1]);
            NewAccount^.chPosting_Allowed := (FieldList.Strings[1] <> 'H');
            NewAccount^.chAccount_Description := FieldList.Strings[2];

            NewChart.Insert(NewAccount);
          end;
        end;
        
      finally
        CloseFile(CSVFile);
      end;
    finally
      ClearStatus(True);
    end;
  except
    on E : EInOutError do //Normally EExtractData but File I/O only
    begin
      Msg := Format( 'Error Refreshing Chart %s. %s', [FilePath, E.Message ] );
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
      HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
      exit;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//------------------------------------------------------------------------------
function FetchCOSFromAPI(NewChart: TChart) : boolean;
const
  ThisMethodName = 'FetchCOSFromAPI';
var
  AccountType : string;
  Msg         : string;
  NewAccount  : pAccount_Rec;
  RESTServer : TBGLServer;
  i          : integer;
begin
  result := false;
  RESTServer := TBGLServer.Create( nil, PRACINI_BGL360_Client_ID,
    PRACINI_BGL360_Client_Secret, PRACINI_BGL360_API_URL );
  try
    if assigned( MyClient ) then
      RestServer.Set_Auth_Tokens( AdminSystem.fdFields.fdBGLAccessToken,
        AdminSystem.fdFields.fdBGLTokenType, AdminSystem.fdFields.fdBGLRefreshToken,
        AdminSystem.fdFields.fdBGLTokenExpiresAt );

      if RestServer.CheckForAuthentication then begin
      
        if RESTServer.Get_Chart_Of_Accounts( MyClient.clExtra.ceBGLFundIDSelected ) then begin
          for i := 0 to pred( RESTServer.Chart_of_Accounts.Count ) do begin

            if (NewChart.FindCode( RESTServer.Chart_of_Accounts[ i ].Code ) <> nil) then
              LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+
                RESTServer.Chart_of_Accounts[ i ].Code +' found in BGL360 API' )
            else
//DN BGL360-SubAccount Change              if ( RESTServer.Chart_of_Accounts[ i ].accountClass[ 1 ] in
//DN BGL360-SubAccount Change                     [ 'C', 'N' ] ) then begin // Sub-Account not handled

              if ( RESTServer.Chart_of_Accounts[ i ].accountClass = 'Control' ) or
                 ( RESTServer.Chart_of_Accounts[ i ].accountClass = 'Normal' ) or
                 ( RESTServer.Chart_of_Accounts[ i ].accountClass = 'Sub Account' ) then begin

                NewAccount := New_Account_Rec;

                NewAccount^.chAccount_Code        :=
                  RESTServer.Chart_of_Accounts[ i ].Code;

                AccountType                       :=
                  RESTServer.Chart_of_Accounts[ i ].accountClass[ 1 ];
                NewAccount^.chAccount_Type        := ord(AccountType[1]);
                NewAccount^.chPosting_Allowed     := AccountType[1] <> 'C';
                NewAccount^.chAccount_Description :=
                  RESTServer.Chart_of_Accounts[ i ].Name; //FieldList.Strings[2];

                NewChart.Insert(NewAccount);
              end;
          end;
          result := true;
        end;
      end
      else begin
        Msg := 'Error Refreshing Chart the Service could not be reached, please try again later.';
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
      end;

  finally
    freeAndNil( RESTServer );
  end;
end;

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
