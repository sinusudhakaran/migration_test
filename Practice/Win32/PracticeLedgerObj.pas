unit PracticeLedgerObj;

interface

uses CashbookMigration, sysUtils, CashbookMigrationRestData, uLkJSON,
    chList32, Classes, bkdefs, MoneyDef, TransactionUtils, bkchio, baObj32,
    bkutil32, bkConst;

type
  TTransType = (ttbank, ttJournals);
  {This class is same as practice ledger. This can be extended later in future.}
  TPracticeLedger = class(TCashbookMigration)
  private
    FNoOfLines          : LongInt;
    FDoQuantity         : Boolean;
    //used for processing the transactiosn to export
    FBankAcctsToExport : TBankAccountsData;
    FBankAcctToExport: TBankAccountData;
    FExportTerminated : Boolean;
    procedure PrepareTransAndJournalsToExport(Selected:TStringList;TypeOfTrans: TTransType;FromDate, ToDate : Integer);
    procedure UploadTransAndJournals(TypeOfTrans: TTransType);
  public
    constructor Create;override;

    procedure RefreshChartFromPLAPI;
    function FetchCOAFromAPI(NewChart: TChart):Boolean;
    function UploadTransactions(RequestData: TlkJSONobject;
            var aResponse: TlkJSONbase; var aRespStr, aError: string;
            aEncryptToken: Boolean; TypeOfTrans: TTransType):Boolean;

    function ExportDataToAPI(FromDate, ToDate : Integer;
        AllowUncoded : boolean = False;
        AllowBlankContra : boolean = False):Boolean;

    procedure AddTransactionToExpList;
  end;

const
  UnitName = 'PracticeLedgerObj';

var
  DebugMe : boolean = false;
  PracticeLedger: TPracticeLedger;
  NoOfEntries : LongInt;

  function CheckFormyMYOBTokens:Boolean;

  procedure DoTransaction;
  procedure DoDissection;

implementation

uses Globals, bkContactInformation, GSTCalc32, ErrorMoreFrm, WarningMoreFrm,
      LogUtil, progress, software, chartutils, ovcDate,
      Bk5Except, InfoMoreFrm, DlgSelect, bkDateUtils, Traverse, TravUtils,
      ContraCodeEntryfrm, StDateSt, GenUtils, FrmChartExportMapGSTClass,
      ChartExportToMYOBCashbook, Math;

function CheckFormyMYOBTokens:Boolean;
begin
  Result := False;
  { 1/180 to add extra 20 seconds, to get extra 20 seconds before expire.}
  if ((Trim(UserINI_myMYOB_Access_Token) <> '') and
      (Trim(UserINI_myMYOB_Random_Key) <> '') and
      (Trim(UserINI_myMYOB_Refresh_Token) <> '') and
      ((UserINI_myMYOB_Expires_TokenAt = 0) or (UserINI_myMYOB_Expires_TokenAt > (Now + 1/180) ) )) then
    Result := True;
end;
{ TPracticeLedger }

procedure TPracticeLedger.AddTransactionToExpList;
var
  S : ShortString;
  TransactionItem: TTransactionData;
  DissRec: pDissection_Rec;
  AllocationItem : TAllocationData;
  AccRec : pAccount_Rec;
  ShowGSTMapping: Boolean;

  procedure FixAllocationValues(aAllocationsData: TAllocationsData);
  var
    SumValue, i: Integer;
  begin
    SumValue := 0;
    for i := 0 to aAllocationsData.Count - 1 do
    begin
      SumValue := SumValue + aAllocationsData.ItemAs(i).Amount;
    end;

    if SumValue < 0 then
    begin
      for i := 0 to aAllocationsData.Count - 1 do
      begin
        aAllocationsData.ItemAs(i).Amount := -aAllocationsData.ItemAs(i).Amount;
        aAllocationsData.ItemAs(i).TaxAmount := -aAllocationsData.ItemAs(i).TaxAmount;
      end;
    end;
  end;
begin
  if not (Assigned(FBankAcctToExport) and Assigned(FBankAcctsToExport)) then
    Exit;

  with MyClient.clFields, Bank_Account.baFields, Transaction^ do
  begin
    txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

    if SkipZeroAmountExport(Transaction) then
       Exit; // Im done...

    {Get Practice and Online ledger GST mapping. Load it only once. Get saved in a file and load it from there each time}
    (*ShowGSTMapping := True;
    if (clCountry = whAustralia) then
    begin
      GSTMapCol := TGSTMapCol.Create(TGSTMapItem);
      GSTMapCol.PrevGSTFileLocation := MyClient.clExtra.ceCashbook_GST_Map_File_Location;
      FillGstMapCol(ChartExportCol, GSTMapCol, False);

      if GSTMapCol.PrevGSTFileLocation <> '' then
      begin
        if FileExists(GSTMapCol.PrevGSTFileLocation) then
        begin
          Filename := GSTMapCol.PrevGSTFileLocation;
          if not GSTMapCol.LoadGSTFile(Filename, ErrorStr) then
          begin
            if ShowGSTMapping then
            begin
              HelpfulErrorMsg(ErrorStr,0);
              LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
            end;
          end;
        end;
      end;

      if ShowGSTMapping then
        Res := ShowMapGSTClass(aPopupParent, fGSTMapCol)
      else
        Res := true;

      if Res then
      begin
        if (ShowGSTMapping) and
           (not (Filename = '')) then
          Res := GSTMapCol.SaveGSTFile(Filename, ErrorStr);

        if Res then
        begin
          if (GSTMapCol.PrevGSTFileLocation <> MyClient.clExtra.ceCashbook_GST_Map_File_Location) then
            MyClient.clExtra.ceCashbook_GST_Map_File_Location := GSTMapCol.PrevGSTFileLocation;
        end
        else
        begin
          if ShowGSTMapping then
          begin
            HelpfulErrorMsg(ErrorStr,0);
            LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + ErrorStr );
          end;
        end;
      end;
    end
    else if (Country = whNewZealand) then
    begin
      if not CheckNZGStTypes() then
      begin
        if ShowGSTMapping then
        begin
          ErrorStr := 'Please assign a GST type to all rates, Other Functions | GST Setup | Rates.';
          HelpfulWarningMsg(ErrorStr,0);
        end;
        Exit;
      end;
    end;*)

    Inc(NoOfEntries );
    if ( txFirst_Dissection = nIL ) then
    begin
      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
      if ( txGST_Class=0 ) then txGST_Amount := 0;
      // Check if Transaction is not finalized and not presented
      if (txDate_Transferred > 0) then
        Exit;

      TransactionItem := TTransactionData.Create(FBankAcctToExport.Transactions);
      TransactionItem.Date        := StDateToDateString('yyyy-mm-dd', txDate_Effective, true);
      TransactionItem.Description := txStatement_Details;
      TransactionItem.Amount      := trunc(txAmount);
      TransactionItem.Reference   := TrimLeadZ(txReference);

      if BKUTIL32.GetTransCoreID(Transaction) > 0 then
        TransactionItem.CoreTransactionId := InsFillerZeros(inttostr(BKUTIL32.GetTransCoreID(Transaction)),15)
      else
        TransactionItem.CoreTransactionId := '';

      TransactionItem.Quantity := txQuantity;
      TransactionItem.PayeeNumber := txPayee_Number;
      TransactionItem.JobCode := txJob_Code;

      // Dissection
      DissRec := txFirst_Dissection;
      if DissRec <> nil then
      begin
        While (DissRec <> nil ) do
        begin
          AllocationItem := TAllocationData.Create(TransactionItem.Allocations);

          if (Trim(Transaction.txAccount) = '') then
            AllocationItem.AccountNumber := ''
          else
          begin
            AccRec := MyClient.clChart.FindCode(DissRec^.dsAccount );
            if not Assigned(AccRec) then
              AllocationItem.AccountNumber := ''
            else
              AllocationItem.AccountNumber := DissRec^.dsAccount;
          end;

          AllocationItem.Description := DissRec^.dsGL_Narration;
          AllocationItem.Amount := Trunc(DissRec^.dsAmount);
          AllocationItem.TaxAmount := Trunc(DissRec^.dsGST_Amount);
          AllocationItem.TaxRate := GSTCalc32.GetGSTClassCode( MyClient, DissRec^.dsGST_Class);//GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);
          if Trim(AllocationItem.TaxRate) = '' then
            AllocationItem.TaxRate := 'NA';
          AllocationItem.Quantity := DissRec^.dsQuantity;
          AllocationItem.PayeeNumber := DissRec^.dsPayee_Number;
          AllocationItem.JobCode := DissRec^.dsJob_Code;

          DissRec := DissRec^.dsNext;
        end;
      end
      else
      begin
        if (Trim(txAccount) = '') and
           (txHas_Been_Edited = False) then
          Exit;

        AllocationItem := TAllocationData.Create(TransactionItem.Allocations);

        if (Trim(txAccount) = '') then
          AllocationItem.AccountNumber := ''
        else
        begin
          AccRec := MyClient.clChart.FindCode(txAccount);
          if not Assigned(AccRec) then
            AllocationItem.AccountNumber := ''
          else
            AllocationItem.AccountNumber := txAccount;
        end;

        AllocationItem.Description := txGL_Narration;
        AllocationItem.Amount := Trunc(txAmount);
        AllocationItem.TaxAmount := Trunc(txGST_Amount);
        AllocationItem.TaxRate := GSTCalc32.GetGSTClassCode( MyClient, txGST_Class);//GetCashBookGSTType(aGSTMapCol, txGST_Class);
        if Trim(AllocationItem.TaxRate) = '' then
          AllocationItem.TaxRate := 'NA';
        AllocationItem.Quantity := txQuantity;
        AllocationItem.PayeeNumber := txPayee_Number;
        AllocationItem.JobCode := txJob_Code;
      end;

      if TransactionItem.Allocations.Count > 0 then
        FixAllocationValues(TransactionItem.Allocations);
    end;
  end;
end;

constructor TPracticeLedger.Create;
begin
  inherited;
  FLicenseType := ltPracticeLedger;
end;

procedure DoDissection;
const
  ThisMethodName = 'DoDissection';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure DoTransaction;
const
  ThisMethodName = 'DoTransaction';
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  PracticeLedger.AddTransactionToExpList;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TPracticeLedger.ExportDataToAPI(FromDate, ToDate : Integer;
    AllowUncoded : boolean = False;
    AllowBlankContra : boolean = False): Boolean;
const
  ThisMethodName = 'ExportDataToAPI';
var
  BA: TBank_Account;
  Msg : String;
  i, j, FromIndex: Integer;
  Selected: TStringList;
  OK, DoBalance, IsJournal, DoBankAccount: boolean;
  ContraCode: string;
begin
  MappingsData.GetMappingFromClient(MyClient);

  FExportTerminated := False;
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Msg := 'Export data [Online Practice Ledger API] from ' + BkDate2Str(FromDate) +
    ' to ' + bkDate2Str(ToDate);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg);

  {if (TestAccountList <> nil) then
  begin
    Selected := TestAccountList;
  end else}
  begin
    Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
    if Selected = nil then
      Exit;
  end;

  try
    with MyClient.clFields do
    begin
      // Validate all bank transactions
      for i := 0 to Pred( Selected.Count ) do
      begin
        BA := TBank_Account(Selected.Objects[i]);

        with BA.baFields do
        begin
          if TravUtils.NumberAvailableForExport( BA, FromDate, ToDate  ) = 0 then
          begin
            HelpfulInfoMsg( 'There are no new entries to extract, for ' + baBank_Account_Number +', in the selected date range.',0);
            Exit;
          end;

          if ((not AllowUncoded) and (not TravUtils.AllCoded(BA, FromDate, ToDate))) then
          begin
            HelpfulInfoMsg( 'Account "'+ baBank_Account_Number+'" has uncoded entries. ' +
               'You must code all the entries before you can extract them.',  0 );
            Exit;
          end;

          if ((not AllowBlankContra) and (not AllowBlankContra)) then
          begin
            if BA.baFields.baContra_Account_Code = '' then
            begin
              if TfrmContraCodeEntry.EnterContraCode(BA.baFields.baBank_Account_Name, ContraCode) then
                BA.baFields.baContra_Account_Code := ContraCode
              else
              begin
                HelpfulInfoMsg( 'Before you can extract these entries, you must specify a contra account code for bank account "'+
                  baBank_Account_Number + '". To do this, go to the Other Functions|Bank Accounts option and edit the account', 0 );
                Exit;
              end;
            end;
          end;
        end;
      end;

      FBankAcctsToExport := TBankAccountsData.Create(TBankAccountData);
      FDoQuantity := Globals.PRACINI_ExtractQuantity;
      NoOfEntries := 0;

      //send bank transactions
      PrepareTransAndJournalsToExport(Selected, ttbank, FromDate, ToDate);
      UploadTransAndJournals(ttBank);

      FBankAcctsToExport.Clear;

      //send journals
      PrepareTransAndJournalsToExport(Selected, ttJournals, FromDate, ToDate);
      UploadTransAndJournals(ttJournals);

      if Not FExportTerminated then
      Begin
        Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were exported to Online Ledger Account',[NoOfEntries] );
        LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
        HelpfulInfoMsg( Msg, 0 );
      end;
    end; { Scope of MyClient }
  finally
    Selected.Free;
    if Assigned(FBankAcctsToExport) then
    begin
      FBankAcctsToExport.Clear;
      FreeAndNil(FBankAcctsToExport);
    end;
    if Assigned(MappingsData) then
    begin
      MappingsData.Clear;
      FreeAndNil(FMappingsData);
    end;
  end;

  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TPracticeLedger.FetchCOAFromAPI(NewChart: TChart): Boolean;
var
  Accounts : TChartOfAccountsData;
  sError: string;
  SupportNumber: string;
  UnknownGSTCodesFound: Boolean;
  i: Integer;
  Account: TChartOfAccountData;
  NewAccount  : pAccount_Rec;
const
  ThisMethodName = 'FetchCOAFromAPI';
begin
  Accounts := TChartOfAccountsData.Create(TChartOfAccountData);
  try
    RandomKey := UserINI_myMYOB_Random_Key;
    EncryptToken(UserINI_myMYOB_Access_Token);
    if not GetChartOfAccounts(MyClient.clExtra.cemyMYOBClientIDSelected, Accounts, sError) then
    begin
      SupportNumber := TContactInformation.SupportPhoneNo[ AdminSystem.fdFields.fdCountry ];
      HelpfulErrorMsg('Could not connect to my.MYOB service, please try again later. ' +
                      'If problem persists please contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.',
                      0, false, sError, true);
      Exit;
    end;
    UnknownGSTCodesFound := False;
    for i := 0 to Accounts.Count - 1 do
    begin
      Account := Accounts.ItemAs(i);
      if Assigned(Account) then
      begin
        if (NewChart.FindCode(Account.Code) <> nil) then
          LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+
            Account.Code +' found in MYOB online Ledger API' )
        else
        begin
          NewAccount := New_Account_Rec;
          NewAccount^.chAccount_Code := Account.Code;

          {At the moment we are guessing al accounts are normal accounts}
          NewAccount^.chAccount_Type        := Ord('N');
          NewAccount^.chPosting_Allowed     := True;//AccountType[1] <> 'C';
          NewAccount^.chAccount_Description := Account.Name;
          NewAccount^.chGST_Class := GSTCalc32.GetGSTClassNo( MyClient, Account.GstType);
          if ( NewAccount^.chGST_Class = 0 ) and ( Account.GstType <> '' ) then
          begin
             LogUtil.LogMsg(lmError, UnitName, 'Unknown GST Indicator ' + Account.GstType + ' found in MYOB Online Ledger: '+ Account.Code );
             UnknownGSTCodesFound := True;
          end;
          NewChart.Insert(NewAccount);
        end;
      end;
    end;
    if UnknownGSTCodesFound then
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : The new chart file contained unknown GST Indicators' );

    Result := True;
  finally
    Accounts.Clear;
    FreeAndNil(Accounts);
  end;
end;

procedure TPracticeLedger.PrepareTransAndJournalsToExport(Selected:TStringList;TypeOfTrans: TTransType;FromDate, ToDate : Integer);
var
  BA: TBank_Account;
  i: Integer;
begin
  for i := 0 to Pred(Selected.Count) do
  begin
    BA := TBank_Account(Selected.Objects[i]);
    if (((TypeOfTrans = ttbank) and (BA.baFields.baAccount_Type = btBank)) or
        ((TypeOfTrans = ttJournals) and (BA.baFields.baAccount_Type in [btCashJournals, btAccrualJournals]))) then
    begin
      FBankAcctToExport := TBankAccountData(FBankAcctsToExport.Add);
      FBankAcctToExport.BankAccountNumber := MappingsData.UpdateSysCode(BA.baFields.baContra_Account_Code);

      Traverse.Clear;
      Traverse.SetSortMethod( csDateEffective );
      Traverse.SetSelectionMethod( TRAVERSE.twAllNewEntries );

      Traverse.SetOnEHProc( DoTransaction );
      Traverse.SetOnDSProc( DoDissection );

      //Load all transactions to the Export transaction list
      Traverse.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
    end;
  end;
end;

procedure TPracticeLedger.RefreshChartFromPLAPI;
const
  ThisMethodName = 'RefreshChartFromPLAPI';
var
  ChartFileName     : string;
  HCtx              : integer;
  NewChart          : TChart;
  Msg               : string;
  FileType          : string;
  Extn              : string;
begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  if not Assigned(MyClient) then
     Exit;

  with MyClient.clFields do
  begin
    try
      NewChart := TChart.Create(MyClient.ClientAuditMgr);
      UpdateAppStatus('Loading Chart','Reading Chart',0);
      try
        if not FetchCOAFromAPI( NewChart ) then begin // Could not retreive the chart
          Msg := 'Please select a client to refresh the chart from, via Other Functions | Accounting System';
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Client not selected.'  );
          HelpfulErrorMsg( 'Please select a Client to refresh the chart from, ' +
            'via Other Functions | Accounting System' + #13+#13+
            'The existing chart has not been modified.', 0 );
          Exit;
        end;

        if NewChart.ItemCount > 0 then
        begin
           MergeCharts(NewChart,MyClient,False, False,false);

           clLoad_Client_Files_From := '';
           clChart_Last_Updated := CurrentDate;
        end
        else
        begin
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
          Exit;
      end;
    end;
  end;  {with}
end;

function TPracticeLedger.UploadTransactions(RequestData: TlkJSONobject;
  var aResponse: TlkJSONbase; var aRespStr, aError: string;
  aEncryptToken: Boolean; TypeOfTrans: TTransType): Boolean;
var
  sURL: string;
  JsonObject: TlkJSONObject;
  RespStr : string;
const
  ThisMethodName = 'UploadTransactions';
begin
  Result := False;

  try
    if TypeOfTrans = ttbank then    
      sURL := Format(PRACINI_PracticeLedgerAPITransactionsURL, [MyClient.clExtra.cemyMYOBClientIDSelected])
    else
      sURL := Format(PRACINI_PracticeLedgerAPIJournalsURL, [MyClient.clExtra.cemyMYOBClientIDSelected]);
    FDataRequestType := drtTransactions;

    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName, ThisMethodName + ': ' + TlkJSON.GenerateText(RequestData));

    if not DoHttpSecureJson(sURL, RequestData, aResponse, RespStr, aError) then
      Exit;

    //Wait til data gets transferred completely
    while (FDataTransferStarted) do
      ;

    aError := FDataError;
    if Assigned(FDataResponse) then
      aResponse := (FDataResponse as TlkJSONObject);
    aRespStr := TlkJSON.GenerateText(aResponse);
  except
    on E: Exception do
    begin
      aError := 'Exception running PracticeLedger.Getbusinesses, Error Message : ' + E.Message;
      LogUtil.LogMsg(lmError, UnitName, aError);
      Exit;
    end;
  end;

  Result := True;
end;

procedure TPracticeLedger.UploadTransAndJournals(TypeOfTrans: TTransType);
var
  i, j , FromIndex: Integer;
  RequestJson : TlkJSONobject;
  ErrorStr,RespStr : string;
  Response: TlkJSONbase;
begin
  if Assigned(FBankAcctsToExport) then
  begin
    for i := 0 to FBankAcctsToExport.Count - 1 do
    begin
      FBankAcctToExport := FBankAcctsToExport.ItemAs(i);
      if FBankAcctToExport.Transactions.Count <= 0 then
        Continue;

      FromIndex := 0;
      for j := 1 to Ceil(FBankAcctToExport.Transactions.Count / 200) do
      begin
        RequestJson :=  TlkJSONobject.Create();
        try

          FBankAcctToExport.Write(RequestJson,FromIndex,200);

          //send to api
          if not UploadTransactions(RequestJson,Response,RespStr, ErrorStr,False, TypeOfTrans) then
          begin
            LogUtil.LogMsg(lmError, UnitName, ErrorStr);
            HelpfulErrorMsg('Exception running PracticeLedger.ExportDataToAPI',0, false, ErrorStr, True);
            FExportTerminated := True;
            Break;
          end;
        finally
          FreeAndNil(RequestJson);
        end;
        FromIndex := FromIndex + 200;
      end;
    end;
  end;
end;

initialization
  PracticeLedger:= TPracticeLedger.Create;

finalization
  if Assigned(PracticeLedger) then
    FreeAndNil(PracticeLedger);


end.
