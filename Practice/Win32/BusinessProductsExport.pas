unit BusinessProductsExport;

interface

uses Classes, clobj32, ReportDefs, SchedRepUtils;

function DoExportScheduledBusinessProduct(const aClient : TClientObj; const OutputDest: TReportDest;
  var srOptions : TSchReportOptions; var EmailList: TList) : boolean;

function DoExtractBusinessProduct(const SD: Integer ; const TD: Integer;
  const Path: string) : boolean;

function QIFFilesExist(Path: string; tDate: Integer): Boolean;

implementation

uses SysUtils, baObj32, bkConst, MoneyDef, bkDateUtils, GenUtils, glConst, syDefs,
  bkDefs, Globals, StatusFrm, RptDateUtils, LogUtil, Reports, WinUtils, AutoCode32,
  ClientUtils, ComObj, StDate, StDateSt, InfoMoreFrm, TransactionUtils, dlgSelect;

Const
   UnitName = 'BUSINESSPRODUCTSEXPORT';
   mnOFXXMLSymbols : Array[ whMin..whMax ] of String[3] = ( 'NZD', 'AUD', 'GBP' );

function isOFXV1( Const Country, System : Byte ): Boolean;
Const
  whOFX1ID : Array[ whMin..whMax ] of Byte = ( snOFXV1, saOFXV1, suOFXV1 );
Begin
  Result := ( whOFX1ID[ Country ] = System );
End;

function isOFXV2( Const Country, System : Byte ): Boolean;
Const
  whOFX2ID : Array[ whMin..whMax ] of Byte = ( snOFXV2, saOFXV2, suOFXV2 );
Begin
  Result := ( whOFX2ID[ Country ] = System );
End;

function isOFXV1orV2( Const Country, System : Byte ): Boolean;
Begin
  Result := isOFXV1( Country, System ) or isOFXV2( Country, System );
End;

Var
   DebugMe : boolean = false;
   NoOfEntries: Integer = 0;
   HDESkipped: Boolean = False;

function DoBusinessProduct(const aClient : TClientObj;
  const OutputDest: TReportDest; var srOptions : TSchReportOptions; var EmailList: TList;
  const FD: Integer; const TD: Integer; var Path: string; const IsScheduledReports: Boolean;
  Selected: TStringList) : boolean;
//if called with Dest = rdScreen then reports will be previewed,
//otherwise file will be created
//export folder is the email outbox folder
const
  ThisMethodName = 'DoExportScheduledBusinessProduct';
var
  BPFile          : TextFile;

  function IncludeThisAccount( BA : TBank_Account) : boolean;
  begin
    if Assigned(Selected) then
      Result := Selected.IndexOf(BA.baFields.baBank_Account_Number) > -1
    else
      Result := BA.baFields.baAccount_Type in [btBank];
  end;

  function MaxStringLength(S: string; Max: Integer): string;
  begin
    if Length(S) > Max then
      Result := Copy(S, 1, Max)
    else
      Result := S;
  end;

  procedure QIFWrite(aEffDate   : integer;
                     aAmount    : Money;
                     aReference : ShortString;
                     aDetails   : string;
                     aNarration : string);
  begin
    WriteLn(BPFile, 'D', bkDateUtils.Date2Str( aEffDate, 'dd/mm/yyyy'));
    WriteLn(BPFile, 'T', FormatFloat('0.00', -aAmount/ 100));
    if aReference <> '' then
      WriteLn(BPFile, 'N', aReference);
    if aDetails <> '' then
      WriteLn(BPFile, 'M', aDetails)
    else if aNarration <> '' then
      WriteLn(BPFile, 'M', aNarration);
    WriteLn(BPFile, '^');
  end;

  procedure WriteOFXFileHeader;
  begin
    if (IsScheduledReports and (aClient.clFields.clBusiness_Products_Report_Format = bpOFXV2)) or
       ((not IsScheduledReports) and
         ((aClient.clFields.clCountry = whNewZealand) and (aClient.clFields.clAccounting_System_Used = snOFXV2)) or
         ((aClient.clFields.clCountry = whAustralia) and (aClient.clFields.clAccounting_System_Used = saOFXV2))) or
         ((aClient.clFields.clCountry = whUK) and (aClient.clFields.clAccounting_System_Used = suOFXV2)) then
    begin
      WriteLn(BPFile, '<?xml version="1.0"?>');
      WriteLn(BPFile, '<?OFX OFXHEADER="200" VERSION="202" SECURITY="NONE" OLDFILEUID="NONE" NEWFILEUID="NONE"?>');
    end
    else
    begin
      WriteLn(BPFile, 'OFXHEADER:100');
      WriteLn(BPFile, 'DATA:OFXSGML');
      WriteLn(BPFile, 'VERSION:102');
      WriteLn(BPFile, 'SECURITY:NONE');
      WriteLn(BPFile, 'ENCODING:USASCII');
      WriteLn(BPFile, 'CHARSET:1252');
      WriteLn(BPFile, 'COMPRESSION:NONE');
      WriteLn(BPFile, 'NEWFILEUID:NONE');
      WriteLn(BPFile, 'OLDFILEUID:NONE');
    end;

    WriteLn(BPFile, '<OFX>');
    WriteLn(BPFile, '<SIGNONMSGSRSV1>');
    WriteLn(BPFile, '<SONRS>');
    WriteLn(BPFile, '<STATUS>');
    WriteLn(BPFile, '<CODE>0</CODE>');
    WriteLn(BPFile, '<SEVERITY>INFO</SEVERITY>');
    WriteLn(BPFile, '</STATUS>');
    WriteLn(BpFile, '<DTSERVER>' + bkDateUtils.Date2Str( CurrentDate, 'yyyymmdd') +
      StTimeToTimeString( 'hhmmss', CurrentTime, False ) + '</DTSERVER>');
    WriteLn(BPFile, '<LANGUAGE>ENG</LANGUAGE>');
    WriteLn(BPFile, '</SONRS>');
    WriteLn(BPFile, '</SIGNONMSGSRSV1>');
    WriteLn(BPFile, '<BANKMSGSRSV1>');
  end;

  procedure WriteOFXFileFooter;
  begin
    WriteLn(BPFile, '</BANKMSGSRSV1>');
    WriteLn(BPFile, '</OFX>');
  end;

  procedure WriteOFXAccountHeader(aNumber: string);
  var
    TranID: string;
    aDate: Integer;
  begin
    WriteLn(BPFile, '<STMTTRNRS>');
    TranID := CreateClassID;
    TranID := StringReplace(TranID, '{', '', [rfReplaceAll]);
    TranID := StringReplace(TranID, '}', '', [rfReplaceAll]);
    TranID := StringReplace(TranID, '-', '', [rfReplaceAll]);
    WriteLn(BPFile, '<TRNUID>' + MaxStringLength(TranID, 32) + '</TRNUID>');
    WriteLn(BPFile, '<STATUS>');
    WriteLn(BPFile, '<CODE>0</CODE>');
    WriteLn(BPFile, '<SEVERITY>INFO</SEVERITY>');
    WriteLn(BPFile, '</STATUS>');
    WriteLn(BPFile, '<STMTRS>');
    Writeln( BPFile,'<CURDEF>', mnOFXXMLSymbols[ aClient.clFields.clCountry ], '</CURDEF>');
    WriteLn(BPFile, '<BANKACCTFROM>');
    WriteLn(BPFile, '<BANKID>0</BANKID>');
    WriteLn(BPFile, '<ACCTID>' + MaxStringLength(aNumber, 22) + '</ACCTID>');
    WriteLn(BPFile, '<ACCTTYPE>CHECKING</ACCTTYPE>');
    WriteLn(BPFile, '</BANKACCTFROM>');
    WriteLn(BPFile, '<BANKTRANLIST>');
    if IsScheduledReports then
      aDate := srOptions.srTrxFromDate
    else
      aDate := FD;
    WriteLn(BPFile, '<DTSTART>' + bkDateUtils.Date2Str( aDate, 'yyyymmdd') + '</DTSTART>');
    if IsScheduledReports then
      aDate := srOptions.srTrxToDate
    else
      aDate := TD;
    WriteLn(BPFile, '<DTEND>' + bkDateUtils.Date2Str( aDate, 'yyyymmdd') + '</DTEND>');
  end;

  procedure WriteOFXAccountFooter(Bal: Money);
  var
    aDate :Integer;
  begin
    WriteLn(BPFile, '</BANKTRANLIST>');
    WriteLn(BPFile, '<LEDGERBAL>');
    WriteLn(BPFile, '<BALAMT>' + FormatFloat('0.00', Bal/ 100) + '</BALAMT>');
    if IsScheduledReports then
      aDate := srOptions.srTrxToDate
    else
      aDate := TD;
    WriteLn(BPFile, '<DTASOF>' + bkDateUtils.Date2Str( aDate, 'yyyymmdd') + '</DTASOF>');
    WriteLn(BPFile, '</LEDGERBAL>');
    WriteLn(BPFile, '</STMTRS>');
    WriteLn(BPFile, '</STMTTRNRS>');
  end;

  function ReplaceXMLChars(s: string): string;
  begin
    Result := StringReplace( s, '"', '&quot;', [ rfReplaceAll]);
    Result := StringReplace( Result, '&', '&amp;', [ rfReplaceAll]);
    Result := StringReplace( Result, '<', '&lt;', [ rfReplaceAll]);
    Result := StringReplace( Result, '>', '&gt;', [ rfReplaceAll]);
    Result := StringReplace( Result, '''', '&apos;', [ rfReplaceAll]);
  end;

  procedure WriteOFXTransaction(aEffDate : integer;
                             aPresDate   : integer;
                             aAmount     : Money;
                             aUID        : ShortString;
                             aDetails    : string;
                             aNarration  : string;
                             aReference  : string;
                             aTrnType    : Integer);
  var
    tt: string;
  begin
    WriteLn(BPFile, '<STMTTRN>');
    // Use recognised TranTypes
    tt := '';
    if aClient.clFields.clCountry = whNewZealand then
    begin
      case aTrnType of
        17, 67, 72: tt := 'INT';
        61: tt := 'DIV';
        2, 16, 19, 20, 24, 79: tt := 'FEE';
        11, 13, 22: tt := 'SRVCHG';
        35, 85: tt := 'ATM';
        28, 36, 37, 51, 62, 83, 86: tt := 'XFER';
        0, 4, 5, 6, 7, 8, 9: tt := 'CHECK';
        65: tt := 'DIRECTDEP';
        15: tt := 'REPEATPMT';
      end;
    end
    else if aClient.clFields.clCountry in [ whAustralia, whUK ] then
    begin
      case aTrnType of
        11: tt := 'INT';
        12: tt := 'DIV';
        7, 8: tt := 'FEE';
        1: tt := 'CHECK';
        3: tt := 'REPEATPMT';
      end;
    end;
    if tt = '' then // use generic trantype
    begin
      if aAmount <= 0 then
        tt := 'CREDIT'
      else
        tt := 'DEBIT';
    end;
    WriteLn(BPFile, '<TRNTYPE>' + tt + '</TRNTYPE>');    
    WriteLn(BPFile, '<DTPOSTED>' + bkDateUtils.Date2Str( aEffDate, 'yyyymmdd') + '</DTPOSTED>');
    WriteLn(BPFile, '<DTUSER>' + bkDateUtils.Date2Str( aPresDate, 'yyyymmdd') + '</DTUSER>');
    WriteLn(BPFile, '<TRNAMT>' + FormatFloat('0.00', -aAmount/ 100) + '</TRNAMT>');
    WriteLn(BPFile, '<FITID>' + aUID + '</FITID>');
    if aReference <> '' then
      WriteLn(BPFile, '<CHECKNUM>' + ReplaceXMLChars(aReference) + '</CHECKNUM>');
    if Length(aDetails) > 32 then // put it in memo
      WriteLn(BPFile, '<MEMO>' + ReplaceXMLChars(aDetails) + '</MEMO>')
    else if aDetails <> '' then // ideally in name
      WriteLn(BPFile, '<NAME>' + ReplaceXMLChars(aDetails) + '</NAME>')
    else if Length(aNarration) > 32 then
      WriteLn(BPFile, '<MEMO>' + ReplaceXMLChars(aNarration) + '</MEMO>')
    else if aNarration <> '' then
      WriteLn(BPFile, '<NAME>' + ReplaceXMLChars(aNarration) + '</NAME>');
    WriteLn(BPFile, '</STMTTRN>');
  end;
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
var
  BA: TBank_Account;
  AdminBA: pSystem_Bank_Account_Rec;
  T, FirstT: pTransaction_Rec;
  BPFilename, BPExportPath, aMsg: string;
  NewSummaryRec, FirstSummaryRec: pSchdRepSummaryRec;
  AccountsFound, AccountsExported, FirstEntryDate, LastEntryDate, EntriesCount,
  EntriesForThisAccount, acNo, Tno, FirstEntryDateForClient, sDate, tDate,
  LastEntryDateForClient, LastDate: integer;
  RptPeriodToUse: byte;
  pCF : pClient_File_Rec;
  LastAcNumber: ShortString;
  EmailInfo : TClientEmailInfo;
  FileIsOpen, SkipTransaction, OFXExtract: Boolean;
  FileList: TStringList;
  BPBuffer        : array[ 1..8192 ] of Byte;
  CurrentBalance, TransTotal: Money;
begin //DoBusinessProduct
  result := false;
  CurrentBalance := 0;
  OFXExtract := False;
  Assert( OutputDest in [ rdPrinter, rdScreen ], 'DoExportScheduledBusinessProduct.OutputDest in [ rdPrinter, rdScreen ]');
  if (not Assigned( aClient)) or StatusFrm.Status_Cancel_Pressed then
  begin
     exit
  end;

  if IsScheduledReports and (not Assigned(AdminSystem)) then
    exit;

  With aClient, clFields Do
  Begin
    // set the reporting period dates
    if IsScheduledReports then
    begin
      if not AdminSystem.fdFields.fdSched_Rep_Include_Business_Products then
        exit;
      If not ( clReporting_Period in [ roSendEveryMonth .. roSendEveryTwoMonthsMonth ] ) then
        exit;

      pCF := AdminSystem.fdSystem_Client_File_List.FindCode( clCode);
      RptPeriodToUse := GetReportingPeriodToUse( clReporting_Period,
                                                 clReport_Start_Date,
                                                 pCF^.cfLast_Print_Reports_Up_To,
                                                 AdminSystem.fdFields.fdPrint_Reports_Up_To,
                                                 srOptions.srPrintAll);

      srOptions.srTrxFromDate := Get_Reporting_Period_Start_Date( AdminSystem.fdFields.fdPrint_Reports_Up_To, RptPeriodToUse );
      srOptions.srTrxToDate   := AdminSystem.fdFields.fdPrint_Reports_Up_To;
      sDate := srOptions.srTrxFromDate;
      tDate := srOptions.srTrxToDate;
      //the only time that the reporting period will be different is when it has been
      //overriden by Get Reporting Period To Use, this will happen if the period is MMQ or MQ
      srOptions.srPrintAllForThisClient := srOptions.srPrintAll or ( RptPeriodToUse <> clReporting_Period);
    end
    else
    begin
      sDate := FD;
      tDate := TD;
    end;

    if DebugMe then
    begin
       LogUtil.LogMsg( lmDebug, UnitName, 'Exporting to Business Product from ' +
                                          bkDate2Str( sDate) +
                                          ' to ' +
                                          bkDate2Str( tDate) +
                                          ' for ' + clCode);
    end;

    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    // For a Preview, set the ClientDest to rdScreen }
    //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
    If ( OutputDest <> rdPrinter ) and IsScheduledReports then
    begin
      Result := DoScheduledReport(REPORT_CODING, rdScreen, srOptions);

      If StatusFrm.Status_Cancel_Pressed then
      begin
        Exit;
      end;
    end
    else
    begin
     FileList := TStringList.Create;
     try
       //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       //                BEGIN EXPORTING TO EXPORT FILE
       //- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
       if IsScheduledReports then
         BPExportPath := EmailOutBoxDir
       else
         BPExportPath := Path;
       // OFX one file for all accounts
       if IsScheduledReports and
          ((clBusiness_Products_Report_Format = bpOFXV1) or (clBusiness_Products_Report_Format = bpOFXV2)) then
       begin
         BPFilename := clCode + '_' + bkDateUtils.Date2Str( srOptions.srTrxToDate, 'ddmmyy') + bpFileExtn[clBusiness_Products_Report_Format];
         OFXExtract := True;
       end
       else if (not IsScheduledReports) and
         ((clCountry = whNewZealand) and ((clAccounting_System_Used = snOFXV1) or (clAccounting_System_Used = snOFXV2))) or
         ((clCountry = whAustralia) and ((clAccounting_System_Used = saOFXV1) or (clAccounting_System_Used = saOFXV2))) or
         ((clCountry = whUK) and ((clAccounting_System_Used = suOFXV1) or (clAccounting_System_Used = suOFXV2))) then
       begin
         BPFilename := '';
         OFXExtract := True;
         Path := BPExportPath;
       end;
       if OFXExtract then
       begin
         FileList.Add(BPExportPath + BPFilename);
         AssignFile( BPFile, BPExportPath + BPFilename);
         SetTextBuf( BPFile, BPBuffer );
         Rewrite( BPFile );
       end;
       // QIF has seperate files per account
       try
         // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
         //write transactions out to file
         AccountsFound       := 0;
         AccountsExported    := 0;
         EntriesCount        := 0;
         FirstSummaryRec     := nil;
         FirstEntryDateForClient := MaxInt;
         LastEntryDateForClient  := 0;
         LastAcNumber := '';
         FileIsOpen := False;
         //export for each bank account
         for acNo := aClient.clBank_Account_List.First to aClient.clBank_Account_List.Last do
         begin
           BA := aClient.clBank_Account_List.Bank_Account_At(acNo);
           //auto code all entries before exporting
           AutoCode32.AutoCodeEntries( aClient, BA, AllEntries, sDate, tDate);

           FirstEntryDate := MaxInt;
           LastEntryDate  := 0;
           EntriesForThisAccount := 0;
           CurrentBalance := 0;

           if IncludeThisAccount( BA) then
           begin
             if IsScheduledReports then
             begin
               BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := False;
               BA.baFields.baTemp_New_Date_Last_Trx_Printed          := 0;  //this value is written back
                                                                            //to admin in ProcessClient()
               AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( BA.BaFields.baBank_Account_Number);
               if Assigned( AdminBA) then
               begin
                 Inc( AccountsFound);

                 if srOptions.srPrintAllForThisClient then
                   BA.baFields.baTemp_Date_Of_Last_Trx_Printed := 0
                 else
                 begin
                  LastDate := ClientUtils.GetLastPrintedDate(aClient.clFields.clCode, AdminBA.sbLRN);
                  if LastDate = 0 then
                    BA.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(srOptions.srDisplayFromDate, -1, 0, 0)
                  else if GetMonthsBetween(LastDate, srOptions.srDisplayFromDate) > 1 then
                    BA.baFields.baTemp_Date_Of_Last_Trx_Printed := GetFirstDayOfMonth(IncDate(srOptions.srDisplayFromDate, 0, -1, 0))
                  else
                    BA.baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
                 end;
               end
               else
               begin
                 //account cannot be found in admin, see date so nothing exported
                 BA.baFields.baTemp_Date_Of_Last_Trx_Printed := MaxInt;
               end;
             end;

             if OFXExtract then
             begin
               //Find the first transaction that will be printed and
               //calculate the closing balance of the account prior to that transaction
               FirstT      := nil;
               TransTotal  := 0;
               if BA.baFields.baCurrent_Balance <> Unknown then
               begin
                 for TNo := Ba.baTransaction_List.First to BA.baTransaction_List.Last do
                 begin
                   T := BA.baTransaction_List.Transaction_At( TNo);
                   //see if transaction is outside date range or earlier than last printed date
                   if ( ( T.txDate_Effective >= sDate) and
                        ( T.txDate_Effective <= tDate) and
                        ((not IsScheduledReports) or
                        (IsScheduledReports and (T.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                          (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, srOptions.srDisplayFromDate))))) then
                   begin
                     //transaction list is sorted in effect date or so first entry found
                     //will be the first to print
                     FirstT := T;
                   end;

                   //if we have found the starting point then add up transaction
                   //amounts from this point on
                   if Assigned( FirstT) then
                     TransTotal := TransTotal + T^.txAmount;
                 end;
                 //the balance prior to the first transaction will be
                 //the closing balance less the total above
                 CurrentBalance := Ba.baFields.baCurrent_Balance - TransTotal;
               end;
             end;

             //begin exporting transactions
             for TNo := Ba.baTransaction_List.First to BA.baTransaction_List.Last do
             begin
               T := BA.baTransaction_List.Transaction_At( TNo);
               SkipTransaction := False;

               //see if transaction is outside date range or earlier than last printed date
               if ( ( T.txDate_Effective >= sDate) and
                    ( T.txDate_Effective <= tDate) and
                    ((not IsScheduledReports) or
                    (IsScheduledReports and (T.txDate_Effective > BA.baFields.baTemp_Date_Of_Last_Trx_Printed) and
                     (not IsUPCFromPreviousMonth(T.txDate_Effective, T.txUPI_State, srOptions.srDisplayFromDate))))) then
               begin
                 //transaction is in range
                 if T.txDate_Effective < FirstEntryDate then
                   FirstEntryDate := T.txDate_Effective;

                 if T.txDate_Effective > LastEntryDate then
                   LastEntryDate  := T.txDate_Effective;

                 if IsScheduledReports then
                 begin
                   BA.baFields.baTemp_New_Date_Last_Trx_Printed := T.txDate_Effective;
                   BA.baFields.baTemp_Include_In_Scheduled_Coding_Report := True;
                 end;
               end
               else
               begin
                 //transaction is out of range
                 SkipTransaction := True;
               end;

               if not SkipTransaction then
               begin
                 if (T.txSource = orHistorical) then
                   HDESkipped := True;

                 if (T^.txSource <> orBank)
                 or (T^.txDate_Transferred <> 0) then
                   Continue;

                 // Even for Sceduled, the file is not saved anyway...
                 T^.txDate_Transferred := CurrentDate;

                 if SkipZeroAmountExport(T) then
                    Continue;

                 Inc(NoOfEntries);
                 CurrentBalance := CurrentBalance + T^.txAmount;

                 if OFXExtract then
                 begin
                   if LastAcNumber = '' then
                     WriteOFXFileHeader;
                   if LastAcNumber <> BA.baFields.baBank_Account_Number then
                   begin
                     if LastAcNumber <> '' then
                       WriteOFXAccountFooter(CurrentBalance);
                     LastAcNumber := BA.baFields.baBank_Account_Number;
                     WriteOFXAccountHeader(BA.baFields.baBank_Account_Number);
                   end;
                   CheckExternalGUID(T);
                   WriteOFXTransaction( T^.txDate_Effective,
                                        T^.txDate_Presented,
                                        T^.txAmount,
                                        TrimGUID(T^.txExternal_GUID),
                                        T^.txStatement_Details,
                                        T^.txGL_Narration,
                                        T^.txReference,
                                        T^.txType);
                 end
                 else // QIF
                 begin
                  if LastAcNumber <> BA.baFields.baBank_Account_Number then // new file
                  begin
                    LastAcNumber := BA.baFields.baBank_Account_Number;
                    BPFilename := clCode + '_' + BA.baFields.baBank_Account_Number + '_' +
                       bkDateUtils.Date2Str( tDate, 'ddmmyy') + bpFileExtn[bpQIF];
                    Path := BPExportPath;
                    FileList.Add(BPExportPath + BPFilename);
                    AssignFile( BPFile, BPExportPath + BPFilename);
                    SetTextBuf( BPFile, BPBuffer );
                    Rewrite( BPFile );
                    FileIsOpen := True;
                    WriteLn(BPFile, '!Type:Bank');
                  end;
                  QIFWrite( T^.txDate_Effective,
                            T^.txAmount,
                            GetFormattedReference(T),
                            T^.txStatement_Details,
                            T^.txGL_Narration);
                 end;
                 Inc( EntriesCount);
                 Inc( EntriesForThisAccount);
               end;
             end; //for each transaction
             //need to add summary account info for each account printed
             if (EntriesForThisAccount > 0) and IsScheduledReports then
             begin
               Inc( AccountsExported);
               GetMem( NewSummaryRec, SizeOf( TSchdRepSummaryRec));
               with NewSummaryRec^ do
               begin
                 ClientCode     := aClient.clFields.clCode;
                 AccountNo      := BA.baFields.baBank_Account_Number;
                 PrintedFrom    := FirstEntryDate;
                 PrintedTo      := LastEntryDate;

                 AcctsPrinted   := 0;  //these will be filled at the end
                 AcctsFound     := 0;

                 UserResponsible := 0;  //will be filled in during summary report
                 Completed      := True;
               end;
               srOptions.srSummaryInfoList.Add( NewSummaryRec);

               if FirstSummaryRec = nil then
               begin
                 FirstSummaryRec := NewSummaryRec;
               end;

               if FirstEntryDate < FirstEntryDateForClient then
                 FirstEntryDateForClient := FirstEntryDate;

               if LastEntryDate > LastEntryDateForClient then
                 LastEntryDateForClient  := LastEntryDate;
             end;
           end;
           If FileIsOpen then
           begin
             FileIsOpen := False;
             CloseFile(BPFile);
           end;
         end; //for each bank account

         //now update first rec details
         if Assigned( FirstSummaryRec) then
         begin
           FirstSummaryRec.AcctsPrinted := AccountsExported;
           FirstSummaryRec.AcctsFound   := AccountsFound;
           FirstSummaryRec.SendBy       := rdBusinessProduct;
           result := True;
         end;
         // Add email
         if IsScheduledReports then
         begin
           EmailInfo := TClientEmailInfo.Create;
           with EmailInfo do
           begin
             EmailType       := EMAIL_BUSINESS_PRODUCT;
             ClientCode      := aClient.clFields.clCode;
             EmailAddress    := Trim( aClient.clFields.clClient_EMail_Address);
             CCEmailAddress  := Trim( aClient.clFields.clClient_CC_EMail_Address);
             ECodingFilename := '';
             ClientMessage   := aClient.clFields.clScheduled_Client_Note_Message;
             AttachmentList := FileList.CommaText;
           end;
           EmailList.Add( EmailInfo);
         end;
         //file written ok
         Result := True;
       except
         on E : Exception do
         begin
           LogUtil.LogError( unitname, 'Export failed for ' + clCode + ' to ' +
                             BPExportPath + BPFilename + ' [' + E.Message + ']');
           exit;
         end;
       end;

       if Result then
       begin
         aMsg := 'Exported entries for ' + clCode + ' to ' + BPExportPath + BPFilename + ' ' +
                inttostr( EntriesCount) + ' entries ';

         if EntriesCount > 0 then
           aMsg := aMsg + 'from ' + bkDate2Str( FirstEntryDateForClient) +
                          ' to ' + bkDate2Str( LastEntryDateForClient);

         LogUtil.LogMsg( lmInfo, unitname, aMsg);
       end;
     finally
      if OFXExtract then
      begin
        if LastAcNumber <> '' then
          WriteOFXAccountFooter(CurrentBalance);
        WriteOFXFileFooter;
        CloseFile(BPFile);
      end;
      FileList.Free;
     end;
    end; //if exporting
  end;  // with aClient, adminsystem...
end; //DoBusinessProduct

function DoExportScheduledBusinessProduct(const aClient : TClientObj;
  const OutputDest: TReportDest; var srOptions : TSchReportOptions; var EmailList: TList) : boolean;
var
  Path: string;
begin
  Result := DoBusinessProduct(aClient, OutputDest, srOptions, EMailList, -1, -1, Path, True, nil);
end;

function DoExtractBusinessProduct(const SD: Integer; const TD: Integer; const Path: string) : boolean;
const
   ThisMethodName = 'DoExtractBusinessProduct';
var
  DummyOptions : TSchReportOptions;
  DummyList: TList;
  Msg, ExportPath: string;
  Selected     : TStringList;
begin
  Result := False;
  DummyList := TList.Create;
  ExportPath := Path;
  try
    NoOfEntries := 0;
    HDESkipped := False;
    Selected  := dlgSelect.SelectBankAccountsForExport( SD, TD, [btBank] );
    if Selected = NIL then exit;
    try
      Result := DoBusinessProduct(MyClient, rdPrinter, DummyOptions, DummyList, SD, TD, ExportPath, False, Selected);
    finally
      Selected.Free;
    end;
    if Result then Begin
       if ExportPath = '' then
          ExportPath := DATADIR;
       if NoOfEntries = 0 then begin
          Msg := 'No valid Entries found in the extract period.';
          if HDESkipped then
             Msg := Msg + #13#13 + 'Note: The Historical Entries in the extract period can not be extracted.';
       end else begin
          Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were saved in %s',[ NoOfEntries, ExportPath ] );
          if HDESkipped then
             Msg := Msg + #13#13 + 'Note: The Historical Entries in the extract period were not extracted.';
       end;
       LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
       HelpfulInfoMsg( Msg, 0 );
    end;
  finally
    DummyList.Free;
  end;
end;

function QIFFilesExist(Path: string; tDate: Integer): Boolean;
var
  i: Integer;
  BA: TBank_Account;
begin
  Result := False;
  for i := MyClient.clBank_Account_List.First to MyClient.clBank_Account_List.Last do
  begin
    BA := MyClient.clBank_Account_List.Bank_Account_At(i);
    if BKFileExists(Path + MyClient.clFields.clCode + '_' + BA.baFields.baBank_Account_Number + '_' +
          bkDateUtils.Date2Str( tDate, 'ddmmyy') + bpFileExtn[bpQIF]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

Initialization
   DebugMe := DebugUnit(UnitName);

end.
