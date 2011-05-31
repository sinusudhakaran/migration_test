// Interface to Acclipse WebXOffice format
unit WebXOffice;

interface

uses Classes, clObj32, sysObj32, baObj32;

function GetWebXDataPath: string; overload;
function GetWebXDataPath(SubFolder: string): string; overload;
procedure ReadSecureAreas(var List: TStrings);
procedure ReadCategories(const SearchID: Integer; var List: TStrings);
function ExportAccount( const aClient: TClientObj; const aSystem : TSystemObj;
    const Filename: string; Const DateFrom, DateTo : Integer; const BA: TBank_Account;
    const IsScheduledReport: Boolean; const SchdSummaryList: TList; const ScheduledReportPrintAll : Boolean;
    const AccountList: TList; ReportStartDate: Integer = 0): Integer;
function ImportFile( const aClient: TClientObj; const FileName: string;
    var ImportedCount, RejectedCount : integer; var ShowDialog: Boolean; var FileSequence: Integer): Boolean;
function IsBankAccountInScheduledReport(const aClient: TClientObj; const BA: TBank_Account;
    const ScheduledReportPrintAll: Boolean; const DateFrom, DateTo, ReportDate: Integer): Boolean;
procedure NotifyQueue(Filename: string; WebID, CatID, Title, Desc: string; Prefix: string = '');

implementation 

uses Windows, SysUtils, Registry, glConst, Globals, WebXUtils, StStrS, StStrL,
  BkDateUtils, PayeeObj, syDefs, bkDefs, scheduled, LogUtil, BkConst, ReportDefs,
  baList32, InfoMoreFrm, YesNoDlg, GlobalDirectories, ErrorMoreFrm, ECodingImportResultsFrm,
  AutoCode32, WinUtils, ClientUtils, SchedRepUtils, bkUtil32, StDate;

var
  DebugMe: Boolean = false;

const
  UnitName = 'WebXOffice';

{..$DEFINE CRLF}

// Get the WebXOffice path
// Returns full path to WebXOffice folder, include backslash
function GetWebXDataPath: string;
const
  ThisMethodName = 'GetWebXDataPath';
begin
  Result := '';
  // Get the path from the registry
  with TRegistry.Create(KEY_READ) do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      OpenKey(WEBX_REGISTRY_KEY, False);
      if ValueExists(WEBX_REGISTRY_VALUE) then
        Result := IncludeTrailingPathDelimiter(ReadString(WEBX_REGISTRY_VALUE));
    finally
      CloseKey;
      Free;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' read datapath: ' + Result);
end;

// Get the WebXOffice subfolder
// SubFolder - the subfolder name underneath 'Datapath'
// Returns full path to subfolder, include backlslash
function GetWebXDataPath(SubFolder: string): string;
const
  ThisMethodName = 'GetWebXDataPath';
begin
  Result := GetWebXDatapath;
  // Default data path if no reg entry
  if Result = '' then
    Result := IncludeTrailingPathDelimiter(Globals.DataDir)
  else
    Result := Result + SubFolder + '\';
  // Create subfolder if it doesnt exist
  if not DirectoryExists(Result) then
    CreateDir(Result);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' read datapath: ' + Result);
end;

// Use escaped values cos its XML
Function QS( Const S : String ): String;
Var
  Count : Cardinal;
  i : Integer;
Begin
  Result := S;
  For i := 1 to Length( S ) do
    If ( S[i]<' ' ) or ( S[i]>'~' ) then Result[i] := ' ';
  Count := 1;
  Result := ReplaceStringAllL( Result, '&', '&amp;', Count );
  Count := 1;
  Result := ReplaceStringAllL( Result, '<', '&lt;', Count );
  Count := 1;
  Result := ReplaceStringAllL( Result, '>', '&gt;', Count );
  Count := 1;
  Result := ReplaceStringAllL( Result, '"', '&quot;', Count );
  Count := 1;
  Result := ReplaceStringAllL( Result, '''', '&apos;', Count );
end;

// Tell WebXOffice there is a new export file
// Filename - full path to where export file was placed
procedure NotifyQueue(Filename: string; WebID, CatID, Title, Desc: string; Prefix: string = '');
const
  ThisMethodName = 'NotifyQueue';
var
  F: TextFile;
  QFilename, FileWithExt, FileNoExt: string;
  i: Integer;
begin
  // Find a unique filename
  FileWithExt := ExtractFilename(Filename);
  FileNoExt := ChangeFileExt(FileWithExt, '');
  QFilename := GetWebXDatapath(WEBX_QUEUE_FOLDER) + Prefix + FileNoExt + '.' + WEBX_QUEUE_EXTN;
  if BKFileExists(Filename) then
  begin
    i := 1;
    QFilename := GetWebXDatapath(WEBX_QUEUE_FOLDER) + Prefix + FileNoExt + '_' +
      IntToStr(i) + '.' + WEBX_QUEUE_EXTN;
    while BKFileExists(QFilename) do
    begin
      Inc(i);
      QFilename := GetWebXDatapath(WEBX_QUEUE_FOLDER) + Prefix + FileNoExt + '_' +
        IntToStr(i) + '.' + WEBX_QUEUE_EXTN;
    end;
  end;
  Assign(F, QFilename);
  Rewrite(F);
  try
    // Delphi Pro deosnt have the builtin XML components
    // We could use msmxl but that would require yet another DLL!
    // The XML we handle is pretty simple so we just write/read it manually.
    Write(F, '<xml>');
    Write(F, '<webspaceid>' + WebID + '</webspaceid>');
    Write(F, '<categoryid>' + CatID + '</categoryid>');
    Write(F, '<title>' + QS(Title) + '</title>');
    Write(F, '<description>' + QS(Desc) + '</description>');
    Write(F, '<masterfilename>' + QS(FileWithExt) + '</masterfilename>');
    Write(F, '</xml>');
  finally
    CloseFile(F);
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName +
    'Upload to webspace:' + WebID + ' folder:' + CatID + ' file: ' + Filename);
end;

// Read in a list of Webspaces from the WebXOffice info file
// List will contain a list of webspaces with the objects being their ID
procedure ReadSecureAreas(var List: TStrings);
const
  ThisMethodName = 'ReadSecureAreas';
var
  F: TextFile;
  Filename, NextLine, ID, WName: string;
begin
  List.Clear;
  Filename := GetWebXDatapath + WEBX_FOLDERINFO_FILE;
  if FileExists(Filename) then
  begin
    Assign(F, Filename);
    Reset(F);
    while not EOF(F) do
    begin
      ReadLn(F, NextLine);
      if Pos('<webspace', NextLine) > 0 then
      begin
        ID := CopyWithinS(NextLine, 'id="', True);
        ID := Copy(ID, 1, Pos('"', ID)-1);
        WName := CopyWithinS(NextLine, 'name="', True);
        WName := Copy(WName, 1, Pos('"', WName)-1);
        if (ID <> '') and (WName <> '') then
          List.AddObject(WName, TObject(StrToInt(ID)));
      end;
    end;
    CloseFile(F);
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + List.Text);
end;

// Read in a list of Categories from the WebXOffice info file
// List will contain a list of categories with the objects being their ID
// SearchID parameter is the secure area for which to read associated categories
procedure ReadCategories(const SearchID: Integer; var List: TStrings);
const
  ThisMethodName = 'ReadCategories';
var
  F: TextFile;
  Filename, NextLine, ID, WName: string;
begin
  List.Clear;
  Filename := GetWebXDatapath + WEBX_FOLDERINFO_FILE;
  Assign(F, Filename);
  Reset(F);
  while not EOF(F) do
  begin
    ReadLn(F, NextLine);
    if Pos('<webspace', NextLine) > 0 then
    begin
      ID := CopyWithinS(NextLine, 'id="', True);
      if Copy(ID, 1, Pos('"', ID)-1) = IntToStr(SearchID) then
      begin
        ReadLn(F, NextLine);
        // Read up to eof or until the end of the current webspace
        while (not EOF(F)) and (Pos('<webspace', NextLine) = 0) do
        begin
          if Pos('<folder', NextLine) > 0 then
          begin
            ID := CopyWithinS(NextLine, 'id="', True);
            ID := Copy(ID, 1, Pos('"', ID)-1);
            WName := CopyWithinS(NextLine, 'name="', True);
            WName := Copy(WName, 1, Pos('"', WName)-1);
            if (ID <> '') and (WName <> '') then
              List.AddObject(WName, TObject(StrToInt(ID)));
          end;
          ReadLn(F, NextLine);
        end;
        break;
      end;
    end;
  end;
  CloseFile(F);
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + List.Text);
end;

// Check to see if a bank account has reports due
function IsBankAccountInScheduledReport(const aClient: TClientObj; const BA: TBank_Account;
  const ScheduledReportPrintAll: Boolean; const DateFrom, DateTo, ReportDate: Integer): Boolean;
var
  i: Integer;
  Transaction : bkDefs.pTransaction_Rec;
begin
  Result := False;
  For i := 0 to BA.baTransaction_List.ItemCount-1 do
  Begin
    Transaction := BA.baTransaction_List.Transaction_At(i);
    If (CompareDates(Transaction.txDate_Effective, DateFrom, DateTo) = Within) and
       ((aClient.clFields.clECoding_Entry_Selection = esAllEntries) or
       ((aClient.clFields.clECoding_Entry_Selection = esUncodedOnly) and (Transaction.txAccount = ''))) then
    Begin
      if (((Transaction.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and (not IsUPCFromPreviousMonth(Transaction.txDate_Effective, Transaction.txUPI_State, ReportDate)))
         or ScheduledReportPrintAll) then
      begin
        Result := True;
        exit;
      end;
    end;
  end;
end;

// Export transactions to WDDX file
// aClient - client to export
// aSystem - system object
// Filename - full path to export file (always overwritten if exists)
// DateFrom -> DateTo - date range of transactions to export
// BA - bank account to export. pass nil to export all acounts in the same file.
// IsScheduledReport - boolean to indicate if called from SR
// SchdSummaryList - summary info for SR
// Returns number of transactions exported
function ExportAccount( const aClient: TClientObj; const aSystem : TSystemObj;
  const Filename: string; Const DateFrom, DateTo : Integer; const BA: TBank_Account;
  const IsScheduledReport: Boolean; const SchdSummaryList: TList; const ScheduledReportPrintAll : Boolean;
  const AccountList: TList; ReportStartDate: Integer = 0): Integer;
const
  ThisMethodName = 'ExportFile';
var
  F: TextFile;

  Procedure CRLF;
  Begin
    {$IFDEF CRLF} Writeln( F ); {$ENDIF}
  end;

  // Write a string
  procedure WS( const VarValue: string ); overload;
  Var
    S : String;
  begin
    S := Trim( VarValue );
    If Length( S ) > 0 then
      Write( F, '<string>', QS( S ), '</string>' )
    else
      Write( F, '<string />' );
    CRLF;
  end;

  // Write a string variable
  procedure WS( const VarName, VarValue: string ); overload;
  begin
    Write( F, '<var name="', VarName, '">' );                   CRLF;
    WS( VarValue );
    Write( F, '</var>' );                                       CRLF;
  end;

  // Write a boolean (converts to string)
  procedure WB( const VarValue: Boolean ); overload;
  begin
    if VarValue then
      Write( F, '<string>1</string>' )
    else
      Write( F, '<string>0</string>' );
    CRLF;
  end;

  // Write a boolean variable
  procedure WB( const VarName: string; const VarValue: Boolean ); overload;
  begin
    Write( F, '<var name="', VarName, '">' );                 CRLF;
    WB( VarValue );
    Write( F, '</var>' );                                     CRLF;
  end;

  // Write a number
  procedure WN( const VarValue: Integer );
  begin
    Write( F, '<number>', VarValue, '</number>' );            CRLF;
  end;

  // Write a monetary value
  procedure WM( const VarValue: Comp );
  begin
    If VarValue = 0 then
      Write( F, '<number>0</number>' )
    else
      Write( F, '<number>', VarValue / 100.0:0:2 , '</number>' );
    CRLF;
  end;

  // Write a gst rate value
  procedure WG( const VarValue: Comp );
  begin
    If VarValue = 0 then
      Write( F, '<number>0</number>' )
    else
      Write( F, '<number>', VarValue / 10000.0:0:4 , '</number>' );
    CRLF;
  end;

  // Write a quantity value
  procedure WQ( const VarValue: Comp );
  begin
    If VarValue = 0 then
      Write( F, '<number>0</number>' )
    else
      Write( F, '<number>', VarValue / 10000.0:0:4 , '</number>' );
    CRLF;
  end;

  // Write a percentage value
  procedure WP( const VarValue: Comp );
  begin
    If VarValue = 0 then
      Write( F, '<number>0</number>' )
    else
      Write( F, '<number>', VarValue / 10000.0:0:4 , '</number>' );
    CRLF;
  end;

  // Write a date
  procedure WD( const VarValue: Integer ); Overload;
  begin
    Write( F, '<string>', Date2Str( VarValue, 'dd/mm/yyyy' ), '</string>' ); CRLF;
  end;

  // Write a date variable
  procedure WD( const VarName: string; const VarValue: Integer ); overload;
  begin
    Write( F, '<var name="', VarName, '">' );                                 CRLF;
    WD( VarValue );
    Write( F, '</var>' );                                                     CRLF;
  end;

  function IncludeThisAccount( BA : TBank_Account) : boolean;
  var
    CompareBA: TBank_Account;
    i: Integer;
  begin
    Result := False;
    for i := 0 to Pred(AccountList.Count) do
    begin
      CompareBA := aClient.clBank_Account_List.Bank_Account_At(Integer(AccountList[i]));
      if (CompareBA.baFields.baBank_Account_Number = BA.baFields.baBank_Account_Number) then
      begin
        Result := True;
        Break;
      end;
    end;
  end;

Var
  OutBuf: array[ 1..8192 ] of Byte;
  i, j, FieldNo, LineNo : integer;
  Payee : TPayee;
  Bank_Account: TBank_Account;
  SBA: pSystem_Bank_Account_Rec;
  Transaction : bkDefs.pTransaction_Rec;
  Dissection : bkDefs.pDissection_Rec;
  pPL : bkDefs.pPayee_Line_Rec;
  Count, txCount, dsCount, gCount, AccountsFound, cCount, LastDate : Integer;
  FNames : String;
  IncludedAccountList: TStringList;
  NewSummaryRec: pSchdRepSummaryRec;
  WebSiteAddress, ContactName, ContactPhone, ContactEmail : string;

begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Assert( Assigned( aClient ), 'aClient is NIL!' );
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Exporting ' +
    Filename + ' for client ' + aClient.clFields.clCode );

  txCount := 0;
  Assign( F, Filename );
  SetTextBuf( F, OutBuf );
  Rewrite( F );
  AccountsFound := 0;
  IncludedAccountList := TStringList.Create;
  try
    Write( F, '<wddxPacket version="1.0">' );
    Write( F, '<header />' );
    Write( F, '<data><struct>' );

    // -------------------------------------------------------------------------
    // Client info
    // -------------------------------------------------------------------------

    with aClient.clFields do
    begin
      WS( 'CLIENT CODE', clCode );
      WS( 'CLIENT NAME', clName );
      WS( 'COUNTRY', whNames[ clCountry ] );
      WD( 'START DATE', DateFrom );
      WD( 'END DATE', DateTo );
      WB( 'ALLOW UPI ENTRY', not clECoding_Dont_Allow_UPIs );
      WB( 'ACCOUNT COLUMN VISIBLE', not clECoding_Dont_Show_Account );
      WB( 'QUANTITY COLUMN VISIBLE', not clECoding_Dont_Show_Quantity );
      WB( 'PAYEE COLUMN VISIBLE', not ( ( aClient.clPayee_List.ItemCount = 0 ) or clECoding_Dont_Show_Payees ) );
      WB( 'GST COLUMN VISIBLE', not clECoding_Dont_Show_GST );
      WB( 'TAX INVOICE COLUMN VISIBLE', not clECoding_Dont_Show_TaxInvoice );
      WS( 'FILE SEQUENCE', IntToStr( clECoding_Last_File_No + 1 ) );
      WD( 'GST START DATE 1', clGST_Applies_From[ 1 ] );
      WD( 'GST START DATE 2', clGST_Applies_From[ 2 ] );
      WD( 'GST START DATE 3', clGST_Applies_From[ 3 ] );
      WD( 'GST START DATE 4', clGST_Applies_From[ 4 ] );
      WD( 'GST START DATE 5', clGST_Applies_From[ 5 ] );
      WB( 'EXPORTED', True ); // This identifies it as an exported file - we won't allow it to be directly imported
      WS( 'ManagersName', clStaff_Member_Name);
      WS( 'ManagersEmail', clStaff_Member_EMail_Address);
      bkUtil32.GetPracticeContactDetails( aClient, ContactName, ContactPhone, ContactEmail, WebsiteAddress);
      WS( 'PracticeContactName', ContactName);
      WS( 'PracticeContactEmail', ContactEmail);
    end;

    // -------------------------------------------------------------------------
    // GST class names
    // -------------------------------------------------------------------------

    gCount := 0;
    For i := 1 to 99 do if Trim( aClient.clFields.clGST_Class_Names[ i ] ) <> '' then inc( gCount );

    CRLF;

    FNames :='GST_CLASS,GST_CLASS_NAME,RATE1,RATE2,RATE3,RATE4,RATE5';

    Write( F, '<var name = "GST Classes">' );
    Write( F, '<recordset rowCount="', gCount, '" fieldNames="', FNames, '">' );

    For FieldNo := 1 to 7 do
    Begin
      Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' ); CRLF;
      for i := 1 to 99 do
      Begin
        If Trim( aClient.clFields.clGST_Class_Names[ i ] ) <> '' then
        Begin
          Case FieldNo of
            1 : WN( i );
            2 : WS( aClient.clFields.clGST_Class_Names[ i ] );
            3 : WG( aClient.clFields.clGST_Rates[ i, 1 ] );
            4 : WG( aClient.clFields.clGST_Rates[ i, 2 ] );
            5 : WG( aClient.clFields.clGST_Rates[ i, 3 ] );
            6 : WG( aClient.clFields.clGST_Rates[ i, 4 ] );
            7 : WG( aClient.clFields.clGST_Rates[ i, 5 ] );
          end;
        end;
      end;
      Write( F, '</field>' ); CRLF;
    end;
    Write( F, '</recordset></var>' ); CRLF;

    // -------------------------------------------------------------------------
    // Chart of Accounts
    // -------------------------------------------------------------------------

    if not aClient.clFields.clECoding_Dont_Send_Chart then
    begin
      FNames := 'CHART_CODE,DESCRIPTION,GST_CLASS,POSTING';

      CRLF;
      Write( F, '<var name = "Chart of Accounts">' ); CRLF;
      cCount := 0;
      for i := 0 to aClient.clChart.ItemCount - 1 do
      Begin
        with aClient.clChart.Account_At( I )^ do
        Begin
          if not chHide_In_Basic_Chart then
            Inc(cCount);
        end;
      end;
      Write( F, '<recordset rowCount="', cCount, '" fieldNames="', FNames, '">' ); CRLF;
      For FieldNo := 1 to 4 do
      Begin
        Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' ); CRLF;
        for i := 0 to aClient.clChart.ItemCount - 1 do
        Begin
          with aClient.clChart.Account_At( I )^ do
          Begin
            if chHide_In_Basic_Chart then
              Continue;
            Case FieldNo of
              1 : WS( chAccount_Code );
              2 : WS( chAccount_Description );
              3 : WN( chGST_Class );
              4 : WB( chPosting_Allowed );
            end;
          end;
        end;
        Write( F, '</field>' ); CRLF;
      end;
      Write( F, '</recordset></var>' ); CRLF;
    end;

    // -------------------------------------------------------------------------
    // Payee List
    // -------------------------------------------------------------------------

    if not aClient.clFields.clECoding_Dont_Send_Payees then
    begin
      FNames := 'PAYEE_NUMBER,PAYEE_NAME';

      Write( F, '<var name = "Payee List">' ); CRLF;
      Write( F, '<recordset rowCount="', aClient.clPayee_List.ItemCount, '" fieldNames="', FNames, '">' ); CRLF;

      Count := 0;
      For FieldNo := 1 to 2 do
      Begin
        Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' ); CRLF;
        For i := 0 to aClient.clPayee_List.ItemCount-1 do
        Begin
          Payee := aClient.clPayee_List.Payee_At( I );
          Case FieldNo of
            1 : Begin
                  WN( Payee.pdNumber );
                  Count := Count + Payee.pdLinesCount;
                end;
            2 : WS( Payee.pdName );
          end;
        end;
        Write( F, '</field>' ); CRLF;
      end;
      Write( F, '</recordset></var>' ); CRLF;

      // -------------------------------------------------------------------------
      // Payee Coding Details
      // -------------------------------------------------------------------------

      FNames := 'PAYEE_NUMBER,LINE_NUMBER,ACCOUNT_CODE,PERCENTAGE_OR_AMOUNT,GST_CLASS,' +
                'GST_AMOUNT,GST_HAS_BEEN_EDITED,GL_NARRATION,LINE_TYPE';

      Write( F, '<var name = "Payee Coding Details">' ); CRLF;
      Write( F, '<recordset rowCount="', Count, '" fieldNames="', FNames, '">' ); CRLF;

      For FieldNo := 1 to 9 do
      Begin
        Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' ); CRLF;
        For i := 0 to aClient.clPayee_List.ItemCount-1 do
        Begin
          Payee := aClient.clPayee_List.Payee_At( I );
          For j := 0 to Payee.pdLinesCount-1 do
          Begin
            pPL := Payee.pdLines.PayeeLine_At( j );
            Case FieldNo of
              1 : WN( Payee.pdNumber );
              2 : WN( j + 1 );
              3 : WS( pPL.plAccount );
              4 : if pPL.plLine_Type = pltPercentage then WP( pPL.plPercentage ) else WM( pPL.plPercentage );
              5 : WN( pPL.plGST_Class );
              6 : WM( pPL.plGST_Amount );
              7 : WB( pPL.plGST_Has_Been_Edited );
              8 : WS( pPL.plGL_Narration );
              9 : Case pPL.plLine_Type of
                    pltPercentage : WS( 'Percentage' );
                    pltDollarAmt  : WS( 'Fixed Amount' );
                  end;
            end;
          end;
        end;
        Write( F, '</field>' ); CRLF;
      end;
      Write( F, '</recordset></var>' ); CRLF;
    end;

    // -------------------------------------------------------------------------
    // Bank Accounts
    // -------------------------------------------------------------------------

    Write( F, '<var name = "Bank Account List">' ); CRLF;

    if BA = nil then
    begin
      Count := 0;
      For i := 0 to aClient.clBank_Account_List.ItemCount-1 do
      Begin
        Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
        If ( Bank_Account.baFields.baAccount_Type <> btBank ) then Continue;
        if (not (IsScheduledReport)) and (not IncludeThisAccount(Bank_Account)) then
          Continue;
        If Assigned( aSystem ) then
        Begin
          SBA := aSystem.fdSystem_Bank_Account_List.FindCode( Bank_Account.baFields.baBank_Account_Number );
          If not Assigned( SBA ) then Continue;
          if IsScheduledReport then
          begin
            if (Pos(Bank_Account.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0) or
               (not IsBankAccountInScheduledReport(aClient, Bank_Account, ScheduledReportPrintAll, DateFrom, DateTo, ReportStartDate)) then
              Dec(Count)
            else
            begin
              //if scheduled reports then determine if acccount can be found in admin system
              //accounts found depends on no of admin accounts found
              Bank_Account.baFields.baTemp_Include_In_Scheduled_Coding_Report := false;
              Bank_Account.baFields.baTemp_New_Date_Last_Trx_Printed := 0;  //this value will be written in admin sytem
                                                                            //see Scheduled.ProcessClient()
              //access the admin system and read date_of_last_transaction_printed.
              if ScheduledReportPrintAll then
                //set date so that all transactions will be included
                Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed := 0
              else
              begin
                LastDate := ClientUtils.GetLastPrintedDate(aClient.clFields.clCode, SBA.sbLRN);
                if LastDate = 0 then
                  Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(ReportStartDate, -1, 0, 0)
                else if GetMonthsBetween(LastDate, ReportStartDate) > 1 then
                  Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed := GetFirstDayOfMonth(IncDate(ReportStartDate, 0, -1, 0))
                else
                  Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
              end;
            end;
          end;
        end;
        AutoCode32.AutoCodeEntries( aClient, Bank_Account, AllEntries, DateFrom, DateTo);
        Inc( Count );
      end
    end
    else
      Count := 1;

    FNames := 'ACCOUNT_UID,ACCOUNT_NUMBER,ACCOUNT_NAME';

    Write( F, '<recordset rowCount="', Count, '" fieldNames="', FNames, '">' ); CRLF;

    For FieldNo := 1 to 3 do
    Begin
      Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' );  CRLF;
      For i := 0 to aClient.clBank_Account_List.ItemCount-1 do
      Begin
        Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
        If ( Bank_Account.baFields.baAccount_Type <> btBank ) then Continue;
        if (BA <> nil) and (Bank_Account.baFields.baBank_Account_Number <> BA.baFields.baBank_Account_Number) then
          Continue;
        if IsScheduledReport and
           ((Pos(Bank_Account.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0) or
            (not IsBankAccountInScheduledReport(aClient, Bank_Account, ScheduledReportPrintAll, DateFrom, DateTo, ReportStartDate))) then
          Continue;
        if (not (IsScheduledReport)) and (not IncludeThisAccount(Bank_Account)) then
          Continue;
        If Assigned( aSystem ) then
        Begin
          SBA := aSystem.fdSystem_Bank_Account_List.FindCode( Bank_Account.baFields.baBank_Account_Number );
          If not Assigned( SBA ) then Continue;
        end;
        if Bank_Account.baFields.baECoding_Account_UID = 0 then
        begin
          Inc(aClient.clFields.clLast_ECoding_Account_UID);
          Bank_Account.baFields.baECoding_Account_UID := aClient.clFields.clLast_ECoding_Account_UID;
        end;
        Case FieldNo of
          1 : WN( Bank_Account.baFields.baECoding_Account_UID );
          2 : WS( Bank_Account.baFields.baBank_Account_Number );
          3 : WS( Bank_Account.baFields.baBank_Account_Name );
        end;
      end;
      Write( F, '</field>' ); CRLF;
    end;
    Write( F, '</recordset></var>' ); CRLF;

    // -------------------------------------------------------------------------
    // TRANSACTIONS
    // -------------------------------------------------------------------------

    Write( F, '<var name = "Transactions">' ); CRLF;
    txCount := 0;
    dsCount := 0;

    For i := 0 to aClient.clBank_Account_List.ItemCount-1 do
    Begin
      Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
      If ( Bank_Account.baFields.baAccount_Type <> btBank ) then Continue;
      if (BA <> nil) and (Bank_Account.baFields.baBank_Account_Number <> BA.baFields.baBank_Account_Number) then
        Continue;
      If Assigned( aSystem ) then
      Begin
        SBA := aSystem.fdSystem_Bank_Account_List.FindCode( Bank_Account.baFields.baBank_Account_Number );
        If not Assigned( SBA ) then Continue;
        Inc(AccountsFound);
      end;
      if IsScheduledReport and (Pos(Bank_Account.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0) then
        Continue;
      if (not (IsScheduledReport)) and (not IncludeThisAccount(Bank_Account)) then
        Continue;
      For j := 0 to Bank_Account.baTransaction_List.ItemCount-1 do
      Begin
        Transaction := Bank_Account.baTransaction_List.Transaction_At( j );
        If (CompareDates( Transaction.txDate_Effective, DateFrom, DateTo ) = Within) and
           ((aClient.clFields.clECoding_Entry_Selection = esAllEntries) or
            ((aClient.clFields.clECoding_Entry_Selection = esUncodedOnly) and (Transaction.txAccount = ''))) then
        Begin
          Inc( txCount );
          If (Transaction.txFirst_Dissection = NIL) and
             (Transaction.txAccount <> '') then
            Inc( dsCount )
          else
          Begin
            Dissection := Transaction.txFirst_Dissection;
            While ( Dissection <> NIL ) do
            Begin
              Inc( dsCount );
              Dissection := Dissection.dsNext;
            end;
          end;
        end;
      end;
    end;

    FNames :=  'ACCOUNT_UID,' +
               'TRANSACTION_UID,' +
               'DATE_EFFECTIVE,' +
               'DATE_PRESENTED,' +
               'AMOUNT,' +
               'GST_CLASS,' +
               'GST_AMOUNT,' +
               'HAS_BEEN_EDITED,' +
               'QUANTITY,' +
               'CHEQUE_NUMBER,' +
               'REFERENCE,' +
               'PAYEE_NUMBER,' +
               'GST_HAS_BEEN_EDITED,' +
               'NARRATION,' +
               'NOTES,' +
               'TAX_INVOICE_AVAILABLE,' +
               'CODE_LOCKED,' +
               'DISPLAY_CODE';

    Write( F, '<recordset rowCount="', txCount, '" fieldNames="', FNames, '">' ); CRLF;

    For FieldNo := 1 to 18 do
    Begin
      Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' );  CRLF;
      For i := 0 to aClient.clBank_Account_List.ItemCount-1 do
      Begin
        Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
        If ( Bank_Account.baFields.baAccount_Type <> btBank ) then Continue;
        if (BA <> nil) and (Bank_Account.baFields.baBank_Account_Number <> BA.baFields.baBank_Account_Number) then
          Continue;
        if IsScheduledReport and (Pos(Bank_Account.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0) then
          Continue;
        if (not (IsScheduledReport)) and (not IncludeThisAccount(Bank_Account)) then
          Continue;
        If Assigned( aSystem ) then
        Begin
          SBA := aSystem.fdSystem_Bank_Account_List.FindCode( Bank_Account.baFields.baBank_Account_Number );
          If not Assigned( SBA ) then Continue;
        end;

        For j := 0 to Bank_Account.baTransaction_List.ItemCount-1 do
        Begin
          Transaction := Bank_Account.baTransaction_List.Transaction_At( j );
          If (CompareDates( Transaction.txDate_Effective, DateFrom, DateTo ) = Within) and
             ((aClient.clFields.clECoding_Entry_Selection = esAllEntries) or
             ((aClient.clFields.clECoding_Entry_Selection = esUncodedOnly) and (Transaction.txAccount = ''))) then
          Begin
            if IsScheduledReport then
            begin
              if (((Transaction.txDate_Effective > Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                   (not IsUPCFromPreviousMonth(Transaction.txDate_Effective, Transaction.txUPI_State, ReportStartDate)))
                   or ScheduledReportPrintAll) then
              begin
                if IncludedAccountList.IndexOf(Bank_Account.baFields.baBank_Account_Number) = -1 then
                  IncludedAccountList.Add(Bank_Account.baFields.baBank_Account_Number);
                if Transaction.txDate_Effective > Bank_Account.baFields.baTemp_New_Date_Last_Trx_Printed then
                  Bank_Account.baFields.baTemp_New_Date_Last_Trx_Printed := Transaction.txDate_Effective;
                Bank_Account.baFields.baTemp_Include_In_Scheduled_Coding_Report := true;
              end
              else
                Continue;
            end;

            Case FieldNo of
              1 : WN( Bank_Account.baFields.baECoding_Account_UID );
              2 : Begin
                    If Transaction.txECoding_Transaction_UID = 0 then
                    Begin
                      Inc( Bank_Account.baFields.baLast_ECoding_Transaction_UID );
                      Transaction.txECoding_Transaction_UID := Bank_Account.baFields.baLast_ECoding_Transaction_UID;
                    end;
                    WN( Transaction.txECoding_Transaction_UID );
                  end;
              3 : WD( Transaction.txDate_Effective );
              4 : WD( Transaction.txDate_Presented );
              5 : WM( Transaction.txAmount );
              6 : WN( Transaction.txGST_Class );
              7 : WM( Transaction.txGST_Amount );
              8 : WB( Transaction.txHas_Been_Edited );
              9 : WP( Transaction.txQuantity );
              10: WN( Transaction.txCheque_Number );
              11: WS( Transaction.txReference );
              12: WN( Transaction.txPayee_Number );
              13: WB( Transaction.txGST_Has_Been_Edited );
              14: WS( Transaction.txGL_Narration );
              15: WS( Transaction.txNotes );
              16: WB( Transaction.txTax_Invoice_Available );
              17: WB( Transaction.txAccount <> '' );
              18: if Transaction.txAccount = '' then
                    WS ('')
                  else if Transaction.txFirst_Dissection = NIL then
                    WS(Transaction.txAccount)
                  else
                    WS('DISSECT');
            end;
          end;
        end;
      end;
      Write( F, '</field>' );  CRLF;
    end;
    Write( F, '</recordset></var>' ); CRLF;

    // -------------------------------------------------------------------------
    // TRANSACTION DETAILS AND DISSECTIONS
    // -------------------------------------------------------------------------

    FNames := 'ACCOUNT_UID,' +
              'TRANSACTION_UID,' +
              'SEQUENCE_NUMBER,' +
              'CHART_CODE,' +
              'AMOUNT,' +
              'GST_CLASS,' +
              'GST_AMOUNT,' +
              'HAS_BEEN_EDITED,' +
              'QUANTITY,' +
              'PAYEE_NUMBER,' +
              'GST_HAS_BEEN_EDITED,' +
              'NARRATION,' +
              'NOTES,' +
              'TAX_INVOICE_AVAILABLE';

    Write( F, '<var name = "Transaction Detail">' ); CRLF;
    Write( F, '<recordset rowCount="', dsCount, '" fieldNames="', FNames, '">' );

    if aClient.clFields.clECoding_Entry_Selection = esAllEntries then
    begin
      For FieldNo := 1 to 14 do
      Begin
        Write( F, '<field name="', ExtractWordL( FieldNo, FNames, ',' ) ,'">' );  CRLF;
        For i := 0 to aClient.clBank_Account_List.ItemCount-1 do
        Begin
          Bank_Account := aClient.clBank_Account_List.Bank_Account_At( i );
          If ( Bank_Account.baFields.baAccount_Type <> btBank ) then Continue;
          if (BA <> nil) and (Bank_Account.baFields.baBank_Account_Number <> BA.baFields.baBank_Account_Number) then
            Continue;
          if IsScheduledReport and (Pos(Bank_Account.baFields.baBank_Account_Number + ',', aClient.clFields.clExclude_From_Scheduled_Reports) > 0) then
            Continue;
          if (not (IsScheduledReport)) and (not IncludeThisAccount(Bank_Account)) then
            Continue;
          If Assigned( aSystem ) then
          Begin
            SBA := aSystem.fdSystem_Bank_Account_List.FindCode( Bank_Account.baFields.baBank_Account_Number );
            If not Assigned( SBA ) then Continue;
          end;

          For j := 0 to Bank_Account.baTransaction_List.ItemCount-1 do
          Begin
            Transaction := Bank_Account.baTransaction_List.Transaction_At( j );
            If (CompareDates( Transaction.txDate_Effective, DateFrom, DateTo ) = Within) and
               (Transaction.txAccount <> '') then
            Begin
              if IsScheduledReport then
              begin
                if not (((Transaction.txDate_Effective > Bank_Account.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                        (not IsUPCFromPreviousMonth(Transaction.txDate_Effective, Transaction.txUPI_State, ReportStartDate)))
                     or ScheduledReportPrintAll) then
                  Continue;
              end;
              If Transaction.txFirst_Dissection = NIL then
              Begin
                Case FieldNo of
                  1 : WN( Bank_Account.baFields.baECoding_Account_UID );
                  2 : WN( Transaction.txECoding_Transaction_UID );
                  3 : WN( 1 );
                  4 : WS( Transaction.txAccount );
                  5 : WM( Transaction.txAmount );
                  6 : WN( Transaction.txGST_Class );
                  7 : WM( Transaction.txGST_Amount );
                  8 : WB( Transaction.txHas_Been_Edited );
                  9 : WQ( Transaction.txQuantity );
                  10: WN( Transaction.txPayee_Number );
                  11: WB( Transaction.txGST_Has_Been_Edited );
                  12: WS( Transaction.txGL_Narration );
                  13: WS( Transaction.txNotes );
                  14: WB( Transaction.txTax_Invoice_Available );
                end;
              end
              else
              Begin
                Dissection := Transaction.txFirst_Dissection;
                LineNo := 0;
                While Dissection <> NIL do
                Begin
                  Inc( LineNo );
                  Case FieldNo of
                    1 : WN( Bank_Account.baFields.baECoding_Account_UID );
                    2 : WN( Transaction.txECoding_Transaction_UID );
                    3 : WN( LineNo );
                    4 : WS( Dissection.dsAccount );
                    5 : WM( Dissection.dsAmount );
                    6 : WN( Dissection.dsGST_Class );
                    7 : WM( Dissection.dsGST_Amount );
                    8 : WB( Dissection.dsHas_Been_Edited );
                    9 : WQ( Dissection.dsQuantity );
                    10: WN( Dissection.dsPayee_Number );
                    11: WB( Dissection.dsGST_Has_Been_Edited );
                    12: WS( Dissection.dsGL_Narration );
                    13: WS( Dissection.dsNotes );
                    14: WB( Transaction.txTax_Invoice_Available );
                  end;
                  Dissection := Dissection.dsNext;
                end;
              end;
            end;
          end; { j }
        end;
        Write( F, '</field>' ); CRLF;
      end;
    end;

    Write( F, '</recordset></var>' ); CRLF;
    Write( F, '</struct></data>' ); CRLF;
    Write( F, '</wddxPacket>' ); CRLF;

    //now handle scheduled reports summary lines
    if IsScheduledReport and ( SchdSummaryList <> nil) then
    begin
      for i := 0 to Pred(IncludedAccountList.Count) do
      begin
        GetMem( NewSummaryRec, Sizeof( TSchdRepSummaryRec));
        with NewSummaryRec^ do begin
           ClientCode         := aClient.clFields.clCode;
           AccountNo          := IncludedAccountList[i];
           PrintedFrom        := DateFrom;
           PrintedTo          := DateTo;
           AcctsPrinted       := IncludedAccountList.Count;
           AcctsFound         := AccountsFound;
           SendBy             := rdWebX;
           UserResponsible    := 0;
           Completed          := True;
           TxLastMonth        := (aClient.clFields.clReporting_Period = roSendEveryMonth) and (DateFrom < ReportStartDate) and
               (not aClient.clFields.clCheckOut_Scheduled_Reports);
        end;
        SchdSummaryList.Add( NewSummaryRec);
     end;
  end;
  finally
    IncludedAccountList.Free;
    Result := txCount;
    CloseFile( F );
    aClient.clFields.clWeb_Export_Format := wfWebX;
    NotifyQueue(Filename, IntToStr(aClient.clFields.clECoding_WebSpace), '0', 'Banklink Transactions',
      'Banklink Transactions for ' + aClient.clFields.clName);
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
  end;
end;

// Verify the WebXOffice incoming transactions
// Returns true if verify failed and user aborted import
function VerifyWebXOfficeFile( BAList: TBank_Account_List; aClient : TClientObj; filename : string) : boolean;
var
  acNo, TNo: integer;
  wxBA, BA: TBank_Account;
  T, BKT: bkDefs.pTransaction_Rec;
  RejectedLines    : TStringList;
  EMsg, RejectMsg, RejectedLogFilename: string;
  ImportedCount, RejectedCount: integer;
begin
  Result := False;

  ImportedCount := 0;
  RejectedCount := 0;

  LogUtil.LogMsg( lmInfo, UnitName, 'Verifying file ' + filename);

  RejectedLines := TStringList.Create;
  try
    try
       //cycle thru each bank account and find matching bk5 account
       for acNo := 0 to Pred(BAList.ItemCount) do
       begin
          wxBA := BAList.Bank_Account_At(acNo);
          BA := aClient.clBank_Account_List.FindAccountFromECodingUID(wxBA.baFields.baECoding_Account_UID);
          if not Assigned( BA) then //rejected bank account
             LogUtil.LogError( Unitname, 'Rejected account UID ' + wxBa.baFields.baBank_Account_Number);
          //now import transactions
          for TNo := 0 to Pred(wxBA.baTransaction_List.ItemCount) do
          begin
             BKT := wxBA.baTransaction_List.Transaction_At(TNo);
             if BKT^.txECoding_Transaction_UID <> 0 then
             begin
                //find matching bk5 transaction
                if Assigned(BA) then
                begin
                  T := BA.baTransaction_List.FindTransactionFromECodingUID(BKT.txECoding_Transaction_UID);
                  //see if match found and is valid
                  if ValidateTransactionForImport(BKT, T, RejectMsg) then
                     Inc(ImportedCount)
                  else
                  begin
                     RejectTransaction(aClient, BKT, RejectMsg, RejectedLines);
                     Inc(RejectedCount);
                  end;
                end
                else
                begin
                  RejectTransaction(aClient, BKT, 'Bank account missing, UID ' + wxBa.baFields.baBank_Account_Number, RejectedLines);
                  Inc(RejectedCount);
                end;
             end
             else
             begin
                //a transaction found with no match
                //cannot add new transactions through WebXOffice
                RejectMsg := 'New transactions not supported';
                RejectTransaction(aClient, BKT, RejectMsg, RejectedLines);
                Inc( RejectedCount);
             end;
          end;
       end;

       //save list of rejected transactions
       try
          if RejectedLines.Count > 0 then
          begin
             RejectedLogFilename := glDataDir + ExtractFilename( filename) + '.log';
             RejectedLines.SaveToFile( RejectedLogFilename);
          end;
       except
          on E :Exception do
          begin
             //crash the system because the client will have been updated
             EMsg := 'Cannot save list of rejected transactions to ' + RejectedLogFilename + '. ' + E.Message;
             HelpfulErrorMsg( eMsg, 0);
             RejectedLogFilename := '';
          end;
       end;

       LogUtil.LogMsg( lmInfo, UnitName, 'File verified ' +
                    inttostr( ImportedCount) + ' transaction(s) will be updated '+
                    inttostr( RejectedCount) + ' rejected transaction(s)');

       if not ConfirmImport( filename, ImportedCount, -1, RejectedCount, RejectedLogFilename)
       then
       begin
          LogUtil.LogMsg( lmInfo, unitname, 'User aborted import');
          exit;
       end;

       //user has ok'ed file for importing
       Result := True;

    except
       on E : Exception do
       begin
          eMsg := 'An error occurred verifying the file.  The import will not continue.' +
                  ' [' + E.Message + ']';
          HelpfulErrorMsg( eMsg, 0);
          Exit;
       end;
    end;
  finally
    RejectedLines.Free;
  end;
end;

// Import transactions from a WDDX file
// aClient - client to import to
// Filename - full path to import file
// ImportedCount, NewCount, RejectedCount - counters are filled acording to import success/failure
// Returns true if import completed, false if there was no import
function ImportFile( const aClient: TClientObj; const FileName: string;
  var ImportedCount, RejectedCount : integer; var ShowDialog: Boolean; var FileSequence: Integer): Boolean;
const
  ThisMethodName = 'ImportFile';
var
  BAList: TBank_Account_List;
  EMsg, ClientCode, ClientName, StartDate, EndDate: string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  //initialise counters
  RejectedCount     := 0;
  ImportedCount     := 0;
  Result := False;
  ShowDialog := False;

  //check file exists
  if not BKFileExists(Filename) then
  begin
    HelpfulInfoMsg('The selected file does not exist. ' + #13 + Filename, 0);
    Showdialog := True;
    exit;
  end;

  // check not trying to import bkx
  if (Uppercase( ExtractFileExt(Filename)) = '.' + WEBX_DEFAULT_EXTN) or
     (WebXUtils.IsExportFile(Filename)) then
  begin
     HelpfulInfoMsg('You cannot import from a ' + WEBX_GENERIC_APP_NAME + ' Export File (.' + WEBX_DEFAULT_EXTN + ')', 0 );
     Showdialog := True;
     exit;
  end;

  BAList := TBank_Account_List.Create( NIL, aClient.FClientAuditMgr );
  try
    //get the client details
    try
      WebXUtils.ParseWDDXClientDetails(Filename, ClientCode, ClientName, StartDate,
                                     EndDate, FileSequence);
    except on E: EFOpenError do
    begin
      HelpfulErrorMsg('Cannot import file ' + filename  + '. ' + E.Message, 0);
      Showdialog := True;
      exit;
    end
    else
    begin
      HelpfulErrorMsg('The selected file is not a valid ' + WEBX_GENERIC_APP_NAME + ' format.', 0);
      Showdialog := True;
      exit;
    end;
    end;

    //check client code
    if aClient.clFields.clCode <> ClientCode then
    begin
      HelpfulInfoMsg('The selected file is for a different client code. [ ' + ClientCode + ']', 0);
      Showdialog := True;
      exit;
    end;

    //check that this is not an older file
    if ( FileSequence < aClient.clFields.clECoding_Last_File_No_Imported) then begin
       EMsg := 'This file is older than the last file you have imported.  It '+
               'contains transactions from ' + StartDate +
               ' to ' + EndDate + '. '#13#13+

               'Please confirm that you wish to import this file?';
        if AskYesNo( 'Import file', eMsg, DLG_NO, 0) <> DLG_YES then
          exit;
    end;

    //prompt the user if this is an old file
    if ( FileSequence = aClient.clFields.clECoding_Last_File_No_Imported) then begin
       EMsg := 'You have already imported this file.  If you import it again any '+
               'new transactions will be duplicated'#13#13+
               'Please confirm that you wish to do this?';

       if AskYesNo( 'Import file', eMsg, DLG_NO, 0) <> DLG_YES then
        exit;
    end;

    //get the transactions
    try
      WebXUtils.ParseWDDXTransactions(aClient, Filename, BAList);
    except
      HelpfulErrorMsg('The selected file is not a valid ' + WEBX_GENERIC_APP_NAME + ' format.', 0);
      Showdialog := True;
      exit;
    end;

    //File successfully opened, read to verify
    if not VerifyWebXOfficeFile( BAList, aClient, Filename) then
      Exit;

    LogUtil.LogMsg( lmInfo, Unitname, 'Importing file ' + filename);
    try
       ProcessECodingFile( BAList, aClient, ImportedCount, RejectedCount);
    except
      //crash system because client file will have been updated
      On E : Exception do
      begin
        EMsg := 'An error occured during the import of ' + filename +'. ' + E.Message;
        Raise Exception.Create( EMsg);
        Exit;
      end;
    end;
    aClient.clFields.clECoding_Last_File_No_Imported := FileSequence;
    Result := True;
  finally
    BAList.FreeAll;
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
  end;
end;

initialization
   DebugMe := DebugUnit(UnitName);

end.


