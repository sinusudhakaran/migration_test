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


procedure RefreshChart;

//******************************************************************************
implementation

uses
  Globals, sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMoreFrm, dbaseReader, stDateSt, WarningMoreFrm, 
  ChartUtils, GenUtils, bkDateUtils, Progress, LogUtil, bk5Except, WinUtils;

const
  SF_FILE  = 'CHART.DBF';
  SF_EXTN  = 'DBF';
  UnitName = 'SIMPLEFUND';
  DebugMe  : Boolean = False;

//------------------------------------------------------------------------------

procedure ReadDBaseFile(ClientRef : string; FilePath : string; Chart : TChart);
const
  ThisMethodName = 'ReadDBaseFile';
var
 DBaseFile               : tDBaseFile;
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
 if not BKFileExists(FilePath + SF_FILE) then begin
    Msg := Format('Cannot Find The Account File %s%s', [ FilePath, SF_FILE ]);
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
    raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
 end;
 ACode1 := '';

 try
   DBaseFile := tDBaseFile.Create(FilePath + SF_FILE);
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
                LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+Code+' found in '+FilePath + SF_FILE );
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
     HelpfulInfoMsg( Format('Cannot Load The Account File %s%s', [ FilePath, SF_FILE ]), 0 );
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
   LoadFromPath      : string;
   Msg               : string;
   FileType          : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then 
     Exit;

  with MyClient.clFields do begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + SF_FILE;
    //check file exists, ask for a new one if not
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0; //hcSFUND001;
      if clAccounting_System_Used = saBGLSimpleLedger then
        FileType := 'Simple Ledger File'
      else
        FileType := 'Simple Fund File';
      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,FileType + '|'+SF_FILE,SF_EXTN,HCtx) then
        Exit;
    end;
    LoadFromPath := ExtractFilePath(ChartFileName);
    try
      NewChart := TChart.Create;
      UpdateAppStatus('Loading Chart','Reading Chart',0);
      try
        ReadDBaseFile(clCode, LoadFromPath, NewChart);
        If NewChart.ItemCount > 0 then begin              //  Assigned( NewChart ) then  {new chart will be nil if no accounts or an error occured}
           MergeCharts(NewChart,MyClient);
           clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
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

//------------------------------------------------------------------------------

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
