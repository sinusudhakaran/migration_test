unit CASystemsOZ;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

uses
  Globals,  sysutils, InfoMoreFrm, bkconst,   chList32, bkchio,
  bkdefs, ovcDate, ErrorMorefrm, dBaseReader, WarningMorefrm, ChartUtils,
  classes, LogUtil, YesNoDlg, bk5Except, GenUtils, bkDateUtils, Progress, CAUtils,
  BKUtil32, glConst, WinUtils;

const
   GLMAN_CONFIG = 'GL_CONFG.DBF';          
   GLMAN_FILE   = 'GL_ACCT.DBF';
   GLMAN_EXTN   = 'DBF';
   GLMAN_MASK   = '####';

   UnitName     = 'CASYSTEMSOZ';
   DebugMe  : Boolean = False;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure ReadDBaseFile(ClientRef : string; FilePath : string; Chart : TChart);
const
   ThisMethodName = 'ReadDBaseFile';
var
  reader        : tDBaseFile;
  i,j           : integer;
  Deleted       : boolean;
  Code          : Bk5CodeStr;
  Name          : ShortString;
  GSTInd        : Char;
  GST_Class     : integer;
  return        : integer;
  ID            : ShortString;
  Rate          : single;
  NewAccount    : pAccount_Rec;
  Msg           : String;
  HasGSTInfo    : Boolean;
  HasDuplicates : boolean;   //has duplicate accounts codes in the dbase file
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

 {check for existence of both files}

 if not BKFileExists(FilePath + GLMAN_CONFIG) then begin
    Msg := Format( 'The Configuration File %s%s cannot be found.',[ FilePath, GLMAN_CONFIG ] );
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
    Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
 end;

 if not BKFileExists(FilePath + GLMAN_FILE) then begin
    Msg := Format( 'The Account File %s%s cannot be found.',[ FilePath, GLMAN_FILE ] );
    LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
    Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
 end;

 reader := tDBaseFile.Create(FilePath + GLMAN_CONFIG);
 try
   with Reader do begin
     GotoRecord(1);
     Return := GetField('BANKMANID',StringCType,ID);

     if Return <> 0 then begin
        Msg := Format( 'Cannot find BANKMANID field in GL-MAN file %s%s.',[ FilePath, GLMAN_CONFIG ] );
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
        Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
     end;

     id := Trim(id);
     if ID = '' then begin
        Msg := Format( 'The BANKMANID field is Blank in GL-MAN file %s%s.',[ FilePath, GLMAN_CONFIG ] );
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
        Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
     end;

     if ID <> ClientRef then begin
        Msg := Format( 'The Current client is %s. GL-MAN file %s%s is for client %s.',[ ClientRef, FilePath, GLMAN_CONFIG, ID ] );
        LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
        Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
     end;

     {get gst rates}
     
     HasGSTInfo := false;
     for i := 1 to MAX_GST_CLASS do with MyClient.clFields do
       if clGST_Rates[i,1] <> 0 then HasGSTInfo := true;
     
     if not HasGSTInfo then With MyClient.clFields do begin
       //gst has not been setup, so put in some defaults
       clGST_Class_Names[1] := 'Acquisitions';
       clGST_Class_Codes[1] := 'I';

       clGST_Class_Names[2] := 'Sales';
       clGST_Class_Codes[2] := 'O';

       clGST_Class_Names[3] := 'Exempt';
       clGST_Class_Codes[3] := 'E';

       clGST_Class_Names[4] := 'GST Free';
       clGST_Class_Codes[4] := 'Z';

       clGST_Class_Names[5] := 'Special 1';
       clGST_Class_Codes[5] := '1';
       
       clGST_Class_Names[6] := 'Special 2';
       clGST_Class_Codes[6] := '2';
       
       clGST_Class_Names[7] := 'Special 3';
       clGST_Class_Codes[7] := '3';
       
       clGST_Class_Names[8] := 'Special 4';
       clGST_Class_Codes[8] := '4';
       
       clGST_Class_Names[9] := 'Not Assigned';
       clGST_Class_Codes[9] := 'N';
       
       Return := GetField('GST_RATE1',SingleCType,Rate);
       if (return = 0) then begin
         clGST_Rates[1,1] := Double2GSTRate(Rate);
         clGST_Rates[2,1] := Double2GSTRate(Rate);
       end;
     end;
   end;
 finally
   reader.Free;
 end;

 HasDuplicates := false;
 reader := tDBaseFile.Create(FilePath + GLMAN_FILE);
 try
   with reader do for i := 1 to Header.NrOfRecs do begin
     gotoRecord(i);
     return := GetField(DelMarkName, BooleanCType, Deleted);
     if (return = 0) and not Deleted then begin
       code   := '';
       Name   := '';
       GSTInd := ' ';

       GetField('ACC_NO',StringCType,Code);
       Code := Trim(Code);
       While(Code<>'') and not (Code[Length(Code)] in ['0'..'9']) do Code[0] := Pred(Code[0]);

       if Code<>'' then begin
         GetField('ACC_DESC',StringCType,Name);
         Name   := Trim(Name);

         GetField( 'ACC_GSTIND',CharCType,GSTInd );

         GST_Class := 0; 
         With MyClient.clFields do 
           For j := 1 to MAX_GST_CLASS do 
             If ( GSTInd = clGST_Class_Codes[ j ] ) then 
               GST_Class := j;

         //check if this is a duplicate code
         if Chart.FindCode(Code) = nil then begin
            //insert new account into chart
            NewAccount := New_Account_Rec;
            with NewAccount^ do begin
              chAccount_Code        := Code;
              chAccount_Description := Name;
              chGST_Class           := GST_Class;
              chPosting_Allowed     := true;

              if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName+ Format(' Inserting Code %s %s',[Code,Name]));
              Chart.Insert(NewAccount);
            end;
         end
         else begin
            HasDuplicates := true;
            LogUtil.LogMsg(lmInfo, UnitName, Format('%s Duplicate Code Found %s %s',
                                                    [ ThisMethodName, Code, Name ]));
         end;
       end;
     end;
   end;
 finally
   reader.Free;
 end;
 if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );

 if HasDuplicates then begin
    HelpfulWarningMsg( 'There were duplicate Account Codes in the select chart file. '#13#13+
                       SHORTAPPNAME + ' has ignored these codes.  A list of the duplicate codes has been '+
                       'written to the System Log.',0);
 end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure RefreshChart;
const
   ThisMethodName = 'RefreshChart';
var
   ChartFileName : string;
   HCtx : integer;
   NewChart          : TChart;

   TempAccount       : pAccount_Rec;
   Next              : pAccount_Rec;
   i                 : integer;
   ThisCode          : string;
   NextCode          : string;
   LoadFromPath      : string;
   Msg               : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then exit;

  with MyClient.clFields do begin
    ChartFileName := AddSlash(clLoad_Client_Files_From) + GLMAN_FILE;

    {check file exists, ask for a new one if not}
    if not BKFileExists(ChartFileName) then begin
      HCtx := 0; //hcGLMAN001;
      if not ChartUtils.LoadChartFrom(clCode,ChartFileName,clLoad_Client_Files_From,'CA Chart File ('+glman_File+')|'+GLMAN_FILE,GLMAN_EXTN,HCtx) then
        exit;
    end;

    LoadFromPath := AddSlash(ExtractFilePath(ChartFileName));

    try
      NewChart := TChart.Create;
      UpdateAppStatus('Loading Chart','Reading Chart',0);
      try
        ReadDBaseFile(clCode, LoadFromPath, NewChart);

        //  Assigned( NewChart ) then  {new chart will be nil if no accounts or an error occured}
        If NewChart.ItemCount > 0 then Begin
           {flag accounts as posting accounts}
           For i := 0 to NewChart.ItemCount - 1 do Begin
              TempAccount := NewChart.Account_At(i);
              TempAccount.chPosting_Allowed := true;

              ThisCode := TempAccount.chAccount_Code;

              If ( i+1 ) < NewChart.ItemCount then Begin
                 Next := NewChart.Account_At(i+1);
                 NextCode    := Copy( Next.chAccount_Code, 1, Length( ThisCode ) );
                 If ( NextCode = ThisCode ) then TempAccount.chPosting_Allowed := FALSE;
              end;
           end;

           MergeCharts(NewChart,MyClient);

           clLoad_Client_Files_From := ExtractFilePath(ChartFileName);
           clChart_Last_Updated := CurrentDate;
           If clAccount_Code_Mask = '' then
               clAccount_Code_Mask := GLMAN_MASK;

           ClearStatus(True);
           HelpfulInfoMsg( 'The Clients Chart of Accounts has been refreshed.', 0 );
        end
        else begin
           Msg := Format( 'Could not read Client Chart %s.',[ ChartFileName ] );
           LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg );
           Raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
        end; 
      finally
        ClearStatus(True);
        NewChart.Free;
      end;
    except
      on E : EExtractData do begin
        Msg := Format( 'Error Refreshing Chart %s. %s', [ChartFileName, E.Message ] );
        LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulErrorMsg( Msg + #13+#13+'The existing chart has not been modified.', 0 );
      end;
    end;
  end;  {with}
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.
