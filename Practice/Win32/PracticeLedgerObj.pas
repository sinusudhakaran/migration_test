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
    FDoQuantity         : Boolean;

    //used for processing the transactiosn to export
    FBankAcctsToExport : TBankAccountsData;
    FBankAcctToExport: TBankAccountData;

    // used for processing the journals to export
    FJournalsData : TJournalsData;
    FExportTerminated : Boolean;

    //Export data functions
    procedure PrepareTransAndJournalsToExport(Selected:TStringList;TypeOfTrans: TTransType;FromDate, ToDate : Integer);
    procedure BuildBankTransactionData;
    procedure BuildJournalData;
    procedure UploadTransAndJournals(Selected:TStringList;TypeOfTrans: TTransType);
    function UploadToAPI(RequestData: TlkJSONobject;
            var aRespStr, aError: string;
            aEncryptToken: Boolean; TypeOfTrans: TTransType):Boolean;

    //Get COA from PL api and add to chart
    function FetchCOAFromAPI(NewChart: TChart):Boolean;
    procedure SetTransferredFlag(Selected : TStringList;TypeOfTrans: TTransType;FromIndex:Integer);
    //Call Rollback api to rollback a batch of transaction
    function RollbackBatch(aBatchRef: string;
      var aRespStr, aError: string;
      aEncryptToken: Boolean; TypeOfTrans: TTransType):Boolean;
  public
    //Couldn't make these private variables and add property since the getfirms and getbusiness need var list to be passed
    Firms : TFirms;// read FFirms write FFirms;
    Businesses : TBusinesses ;//read FBusinesses write FBusinesses;

    constructor Create;override;
    destructor Destroy;override;
    //Refresh chart
    procedure RefreshChartFromPLAPI;

    //Export data to pl api
    function ExportDataToAPI(FromDate, ToDate : Integer;
        AllowUncoded : boolean = False;
        AllowBlankContra : boolean = False):Boolean;

    //This function will be called from DoTransaction which is a hooked event to Traverse to filter the export transactions
    procedure AddTransactionToExpList;
  end;

  TPracticeLedgerThread = class(TThread)
  private
    FIsDownloadBusiness : Boolean;
  public
    constructor CreateThread(CreateSuspended: Boolean;aIsLoadBusiness:Boolean);
    property IsDownloadBusiness : Boolean read FIsDownloadBusiness write FIsDownloadBusiness;

    procedure Execute;override;
  end;

const
  UnitName = 'PracticeLedgerObj';
  MAXENTRIES = 200; // Max entries (journal/ bank) can sent to a api at a time

var
  DebugMe : boolean = false;
  PracticeLedger: TPracticeLedger;
  NoOfEntries : LongInt;
  PracticeLedgerThread : TPracticeLedgerThread;

  //Validate tokens
  function CheckFormyMYOBTokens(aUseRefreshToken:Boolean=True):Boolean;

  // this function invokes a thread to retrieve firms and businesses so that there wont be any delay while showing them to screen
  procedure GetFirmsAndBusinesses(aIsLoadBusiness:Boolean);

  // This is the global function called for each transaction from Traverse unit once it's filtered for extract
  procedure DoTransaction;

implementation

uses Globals, bkContactInformation, GSTCalc32, ErrorMoreFrm, WarningMoreFrm,
      LogUtil, progress, software, chartutils, ovcDate,
      Bk5Except, InfoMoreFrm, DlgSelect, bkDateUtils, Traverse, TravUtils,
      ContraCodeEntryfrm, StDateSt, GenUtils, FrmChartExportMapGSTClass,
      ChartExportToMYOBCashbook, Math, myMYOBSignInFrm, Forms, Controls,
      INISettings;

function CheckFormyMYOBTokens(aUseRefreshToken:Boolean=True):Boolean;
var
  sError : string;
  InvalidPass : Boolean;
begin
  Result := False;

  { 1/180 to add extra 20 seconds, to get extra 20 seconds before expire.}
  if ((Trim(UserINI_myMYOB_Access_Token) <> '') and
      (Trim(UserINI_myMYOB_Random_Key) <> '')) then
  begin
    if ((UserINI_myMYOB_Expires_TokenAt = 0) or (UserINI_myMYOB_Expires_TokenAt > (Now + 1/180))) then
      Result := True
    else if (Trim(UserINI_myMYOB_Refresh_Token) <> '') then
    begin
      //Use refresh token to get access token
      if aUseRefreshToken and Assigned(PracticeLedger) then
      begin
        PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
        PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;
        if PracticeLedger.RefreshTheToken(sError, InvalidPass) then
        begin
          Result := True;
          
          UserINI_myMYOB_Access_Token := PracticeLedger.UnEncryptedToken;
          UserINI_myMYOB_Random_Key := PracticeLedger.RandomKey;
          UserINI_myMYOB_Refresh_Token := PracticeLedger.RefreshToken;
          UserINI_myMYOB_Expires_TokenAt := PracticeLedger.TokenExpiresAt;
          WriteUsersINI(CurrUser.Code);
        end
        else
        begin
          LogUtil.LogMsg(lmError, UnitName, sError);
          //Result := PracticeLedger.RefreshTheToken(sError, InvalidPass);
        end;
      end;
    end;
  end;
end;

procedure GetFirmsAndBusinesses(aIsLoadBusiness:Boolean);
begin
  PracticeLedgerThread := TPracticeLedgerThread.CreateThread(False,aIsLoadBusiness);
  Application.ProcessMessages;
end;
{ TPracticeLedger }

procedure TPracticeLedger.AddTransactionToExpList;
begin
  with MyClient.clFields, Bank_Account.baFields, Transaction^ do
  begin
    txForex_Conversion_Rate := Bank_Account.Default_Forex_Conversion_Rate(txDate_Effective);

    if SkipZeroAmountExport(Transaction) then
       Exit; // Im done...

    if (Bank_Account.baFields.baAccount_Type = btBank) then
      BuildBankTransactionData
    else if Bank_Account.baFields.baAccount_Type in [btCashJournals, btAccrualJournals] then
      BuildJournalData;
  end;
end;

procedure TPracticeLedger.BuildBankTransactionData;
var
  TransactionItem: TTransactionData;
  DissRec: pDissection_Rec;
  AllocationItem : TAllocationData;
  AccRec : pAccount_Rec;
  S : ShortString;

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
  Inc(NoOfEntries );
  with MyClient.clFields, Bank_Account.baFields, Transaction^ do
  begin
    if (txDate_Transferred > 0) then
      Exit;

    if ( txFirst_Dissection = nil ) then
    begin
      //txDate_Transferred := CurrentDate;
      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
      if ( txGST_Class=0 ) then txGST_Amount := 0;
      // Check if Transaction is not finalized and not presented
      if (txDate_Transferred > 0) then
        Exit;

      TransactionItem := TTransactionData.Create(FBankAcctToExport.Transactions);
      TransactionItem.Date        := StDateToDateString('yyyy-mm-dd', txDate_Effective, true);
      TransactionItem.SequenceNo  := txSequence_No;
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
        while (DissRec <> nil ) do
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

procedure TPracticeLedger.BuildJournalData;
var
  JournalItem : TJournalData;
  LineItem : TLineData;
  AccRec : pAccount_Rec;
  DissRec: pDissection_Rec;
begin
  Inc(NoOfEntries );
  with MyClient.clFields,Bank_Account.baFields, Transaction^ do
  begin
    //Check if Transaction is not finalized and not presented
    if (txDate_Transferred > 0) then
      Exit;

    JournalItem := TJournalData.Create();
    JournalItem.Date        := StDateToDateString('yyyy-mm-dd', txDate_Effective, true);
    JournalItem.SequenceNo  := txSequence_No;
    JournalItem.Description := txGL_Narration;
    JournalItem.Reference   := TrimLeadZ(txReference);
    JournalItem.JournalAccountName := Bank_Account.baFields.baBank_Account_Number;
    JournalItem.JournalContraCode := Bank_Account.baFields.baContra_Account_Code;

    DissRec := txFirst_Dissection;
    while (DissRec <> nil ) do
    begin
      LineItem := TLineData.Create(JournalItem.Lines);

      if trim(DissRec^.dsAccount) = '' then
        LineItem.AccountNumber := txAccount
      else
        LineItem.AccountNumber := DissRec^.dsAccount;
      AccRec := MyClient.clChart.FindCode( LineItem.AccountNumber );
      if not Assigned(AccRec) then
        LineItem.AccountNumber := '';

      LineItem.Description := DissRec^.dsGL_Narration;
      LineItem.Reference   := TrimLeadZ(DissRec^.dsReference);
      LineItem.TaxAmount   := trunc(DissRec^.dsGST_Amount);
      LineItem.TaxRate     := GSTCalc32.GetGSTClassCode( MyClient, DissRec^.dsGST_Class);//GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);
      if Trim(LineItem.TaxRate) = '' then
        LineItem.TaxRate := 'NA';

      LineItem.Amount := abs(trunc(DissRec^.dsAmount));
      if trunc(DissRec^.dsAmount) < 0 then
        LineItem.IsCredit := true
      else
        LineItem.IsCredit := false;

      LineItem.Quantity := DissRec^.dsQuantity;
      LineItem.PayeeNumber := DissRec^.dsPayee_Number;
      LineItem.JobCode := DissRec^.dsJob_Code;

      DissRec := DissRec^.dsNext;
    end;

    FJournalsData.Insert(JournalItem);
  end;

  if FJournalsData.ItemCount > 1 then
    FJournalsData.Sort();
end;


constructor TPracticeLedger.Create;
begin
  inherited;
  FLicenseType := ltPracticeLedger;

  Firms := TFirms.Create;
  Businesses := TBusinesses.Create;
end;

destructor TPracticeLedger.Destroy;
begin
  if Assigned(Firms) then
  begin
    Firms.Clear;
    FreeAndNil(Firms);
  end;
  if Assigned(Businesses) then
  begin
    Businesses.Clear;
    FreeAndNil(Businesses);
  end;

  inherited;
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
  i: Integer;
  Selected: TStringList;
  ContraCode: string;
  SignInFrm : TmyMYOBSignInForm;
begin
  Result := False;
  if Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '' then
  begin
    HelpfulErrorMsg('Online Firm should be associated before exporting data!',
                      0, false, 'Make sure admin user setup an Online ledger firm before you export data to Online Ledger', true);
    Exit;
  end;

  if Trim(MyClient.clExtra.cemyMYOBClientIDSelected) = '' then
  begin
    HelpfulErrorMsg('MYOB online client should be associated before exporting data!',
                      0, false, 'Make sure you select an Online ledger client before you export data to Online Ledger', true);
    Exit;
  end;

  if not (CheckFormyMYOBTokens) then
  begin
    SignInFrm := TmyMYOBSignInForm.Create(Nil);
    Screen.Cursor := crHourGlass;
    try
      SignInFrm.FormShowType := fsSignIn;
      if SignInFrm.ShowModal <> mrOK then
      begin
        HelpfulErrorMsg('Establish a MYOB login before export data',
                      0, false, 'Sign in to MYOB portal to get the access tokens to communicate to Online Ledger', true);
        Exit;
      end;
    finally
      Screen.Cursor := crDefault;
      FreeAndNil(SigninFrm);
    end;
  end;

  MappingsData.GetMappingFromClient(MyClient);

  FExportTerminated := False;
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

  Msg := 'Export data [Online Practice Ledger API] from ' + BkDate2Str(FromDate) +
    ' to ' + bkDate2Str(ToDate);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg);

  Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
  if Selected = nil then
    Exit;

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
      FJournalsData := TJournalsData.Create;
      try
        FJournalsData.Duplicates := True;
        FDoQuantity := Globals.PRACINI_ExtractQuantity;
        NoOfEntries := 0;

        //send bank transactions
        PrepareTransAndJournalsToExport(Selected, ttbank, FromDate, ToDate);
        UploadTransAndJournals(Selected, ttBank);

        //send journals
        PrepareTransAndJournalsToExport(Selected, ttJournals, FromDate, ToDate);
        UploadTransAndJournals(Selected, ttJournals);

        if Not FExportTerminated then
        Begin
          Result := True;
          Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were exported to Online Ledger Account',[NoOfEntries] );
          LogUtil.LogMsg(lmInfo, UnitName, ThisMethodName + ' : ' + Msg );
          HelpfulInfoMsg( Msg, 0 );
        end;
      finally
        if Assigned(FBankAcctsToExport) then
        begin
          FBankAcctsToExport.Clear;
          FreeAndNil(FBankAcctsToExport);
        end;
        if Assigned(FJournalsData) then
        begin
          FJournalsData.FreeAll;
          FreeAndNil(FJournalsData);
        end;
      end;
    end;
  finally
    Selected.Clear;
    Selected.Free;
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

  SignInFrm : TmyMYOBSignInForm;
const
  ThisMethodName = 'FetchCOAFromAPI';
begin
  Result := False;

  if not Assigned(AdminSystem) then
    Exit;
    
  if Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '' then
  begin
    HelpfulErrorMsg('Online Firm should be associated before a refresh chart!',
                      0, false, 'Make sure admin user setup an Online ledger firm before you do a refrsh chart', true);
    Exit;
  end;

  if Trim(MyClient.clExtra.cemyMYOBClientIDSelected) = '' then
  begin
    HelpfulErrorMsg('MYOB online client should be associated before exporting data!',
                      0, false, 'Make sure you select an Online ledger client before you export data to Online Ledger', true);
    Exit;
  end;

  if not (CheckFormyMYOBTokens) then
  begin
    SignInFrm := TmyMYOBSignInForm.Create(Nil);
    Screen.Cursor := crHourGlass;
    try
      SignInFrm.FormShowType := fsSignIn;
      if SignInFrm.ShowModal <> mrOK then
      begin
        HelpfulErrorMsg('Establish a MYOB login before refresh chart',
                      0, false, 'Sign in to MYOB portal to get the access tokens to communicate to Online Ledger', true);
        Exit;
      end;
    finally
      Screen.Cursor := crDefault;
      FreeAndNil(SigninFrm);
    end;
  end;

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
            Account.Code +' found in MYOB Ledger API' )
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
             LogUtil.LogMsg(lmError, UnitName, 'Unknown GST Indicator ' + Account.GstType + ' found in MYOB Ledger: '+ Account.Code );
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
      if (TypeOfTrans = ttbank) then
      begin
        FBankAcctToExport := TBankAccountData(FBankAcctsToExport.Add);
        FBankAcctToExport.BankAccountNumber := MappingsData.UpdateSysCode(BA.baFields.baContra_Account_Code);
      end;

      Traverse.Clear;
      Traverse.SetSortMethod( csDateEffective );
      Traverse.SetSelectionMethod( TRAVERSE.twAllNewEntries );

      Traverse.SetOnEHProc( DoTransaction );

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
  NewChart          : TChart;
  Msg               : string;
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
           MergeCharts(NewChart,MyClient,False, True,false);

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

function TPracticeLedger.RollbackBatch(aBatchRef: string;
  var aRespStr, aError: string;
  aEncryptToken: Boolean; TypeOfTrans: TTransType): Boolean;
var
  sURL: string;
  RespStr : string;
  RequestJson : TlkJSONobject;
  Response : TlkJSONObject;
const
  ThisMethodName = 'RollbackBatch';
begin
  Result := True;
  if Trim(aBatchRef) = '' then
    Exit;
  RequestJson :=  TlkJSONobject.Create();
  try
    RequestJson.Add('batch_ref', aBatchRef);
    if TypeOfTrans = ttbank then
    begin
      sURL := Format(PRACINI_CashbookAPITransactionsURL, [MyClient.clExtra.cemyMYOBClientIDSelected]);
      FDataRequestType := drtRollback;
    end
    else
    begin
      sURL := Format(PRACINI_CashbookAPIJournalsURL, [MyClient.clExtra.cemyMYOBClientIDSelected]);
      FDataRequestType := drtRollback;
    end;

    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName, ThisMethodName + ': ' + TlkJSON.GenerateText(RequestJson));

    if not DoDeleteSecureJson(sURL, RequestJson,RespStr, aError) then
      Exit;

    //Wait til data gets transferred completely
    while (FDataTransferStarted) do
      ;

    aError := FDataError;
    if Assigned(FDataResponse) then
    begin
      Response := FDataResponse as TlkJSONObject;
      aRespStr := TlkJSON.GenerateText(Response);
    end;
  except
    on E: Exception do
    begin
      aError := 'Exception running PracticeLedger.RollbackBatch, Error Message : ' + E.Message;
      LogUtil.LogMsg(lmError, UnitName, aError);
      Exit;
    end;
  end;
  if Assigned(Response) then
    FreeAndNil(Response);
  Result := True;
end;

procedure TPracticeLedger.SetTransferredFlag(Selected : TStringList;TypeOfTrans: TTransType;FromIndex:Integer);
var
  i, k, ToIndex: Integer;
  stDate : TStDate;
  SeqNo: Integer;
  TransRec: pTransaction_Rec;
  BA : TBank_Account ;

  function GetBankAccount(aAcctNo : string):TBank_Account;
  var
    j: Integer;
  begin
    Result := nil;
    for j := 0 to Selected.Count - 1 do
    begin
      if TBank_Account(Selected.Objects[j]).baFields.baContra_Account_Code =  aAcctNo then
        Result := TBank_Account(Selected.Objects[j]);
    end;
  end;
begin
  if TypeOfTrans = ttbank then
  begin
    if FromIndex + MAXENTRIES > FBankAcctToExport.Transactions.Count then
      ToIndex := FBankAcctToExport.Transactions.Count
    else
      ToIndex := FromIndex + MAXENTRIES;

    BA := GetBankAccount(FBankAcctToExport.BankAccountNumber);
    if Assigned(BA) then
    begin
      for i := FromIndex to ToIndex - 1 do
      begin
        stDate := DateStringToStDate('yyyy-mm-dd', FBankAcctToExport.Transactions.ItemAs(i).Date, Epoch);
        SeqNo := FBankAcctToExport.Transactions.ItemAs(i).SequenceNo;

        for k := 0 to BA.baTransaction_List.ItemCount - 1 do
        begin
          TransRec := BA.baTransaction_List.Transaction_At(k);
          if ((TransRec^.txDate_Effective = stDate) and (TransRec^.txSequence_No = SeqNo)) then
          begin
            TransRec^.txDate_Transferred := CurrentDate;
            TransRec^.txHas_Been_Edited := True;
          end;
        end;
      end;
    end;
  end
  else if TypeOfTrans = ttJournals then
  begin
    if FromIndex + MAXENTRIES > FJournalsData.ItemCount then
      ToIndex := FJournalsData.ItemCount
    else
      ToIndex := FromIndex + MAXENTRIES;

    for i := FromIndex to  ToIndex - 1 do
    begin
      stDate := DateStringToStDate('yyyy-mm-dd', TJournalData(FJournalsData.Items[i]).Date, Epoch);
      SeqNo := TJournalData(FJournalsData.Items[i]).SequenceNo;
      BA := GetBankAccount(TJournalData(FJournalsData.Items[i]).JournalContraCode);
      
      if Assigned(BA) then
      begin
        for k := 0 to BA.baTransaction_List.ItemCount - 1 do
        begin
          TransRec := BA.baTransaction_List.Transaction_At(k);
          if ((TransRec^.txDate_Effective = stDate) and (TransRec^.txSequence_No = SeqNo)) then
          begin
            TransRec^.txDate_Transferred := CurrentDate;
            TransRec^.txHas_Been_Edited := True;
          end;
        end;
      end;
    end;
  end;
end;

function TPracticeLedger.UploadToAPI(RequestData: TlkJSONobject;
  var aRespStr, aError: string;
  aEncryptToken: Boolean; TypeOfTrans: TTransType): Boolean;
var
  sURL: string;
  RespStr : string;
  Response : TlkJSONObject;
const
  ThisMethodName = 'UploadTransactions';
begin
  Result := False;

  try
    if TypeOfTrans = ttbank then
    begin
      sURL := Format(PRACINI_CashbookAPITransactionsURL, [MyClient.clExtra.cemyMYOBClientIDSelected]);
      FDataRequestType := drtTransactions;
    end
    else
    begin
      sURL := Format(PRACINI_CashbookAPIJournalsURL, [MyClient.clExtra.cemyMYOBClientIDSelected]);
      FDataRequestType := drtJournals;
    end;

    if DebugMe then
      LogUtil.LogMsg(lmDebug,UnitName, ThisMethodName + ': ' + TlkJSON.GenerateText(RequestData));

    if not DoHttpSecureJson(sURL, RequestData, RespStr, aError) then
      Exit;

    //Wait til data gets transferred completely
    while (FDataTransferStarted) do
      ;

    aError := FDataError;
    if Assigned(FDataResponse) then
    begin
      Response := FDataResponse as TlkJSONObject; // This is like a create , so destroy at the end
      aRespStr := TlkJSON.GenerateText(Response);
    end;
  except
    on E: Exception do
    begin
      aError := 'Exception running PracticeLedger.UploadToAPI, Error Message : ' + E.Message;
      LogUtil.LogMsg(lmError, UnitName, aError);
      Exit;
    end;
  end;
  if Assigned(Response) then
    FreeAndNil(Response);
  Result := True;
end;

procedure TPracticeLedger.UploadTransAndJournals(Selected:TStringList;TypeOfTrans: TTransType);
var
  i, j , FromIndex: Integer;
  RequestJson : TlkJSONobject;
  ErrorStr,RespStr : string;
  BankAcToExport: TBankAccountData;
begin
  if ((TypeOfTrans = ttbank) and Assigned(FBankAcctsToExport)) then
  begin
    for i := 0 to FBankAcctsToExport.Count - 1 do
    begin
      BankAcToExport := FBankAcctsToExport.ItemAs(i);
      if BankAcToExport.Transactions.Count <= 0 then
        Continue;

      FromIndex := 0;

      for j := 1 to Ceil(BankAcToExport.Transactions.Count / MAXENTRIES) do
      begin
        RequestJson :=  TlkJSONobject.Create();
        try
          BankAcToExport.Write(RequestJson, FromIndex, MAXENTRIES);
          if DebugMe then
            LogUtil.LogMsg(lmInfo, UnitName, 'PL bank transactions batch exported - ' + BankAcToExport.BatchRef);

          //send to api
          if not UploadToAPI(RequestJson,RespStr, ErrorStr,False, TypeOfTrans) then
          begin
            LogUtil.LogMsg(lmError, UnitName, ErrorStr);
            HelpfulErrorMsg('Exception in bank transaction export in PracticeLedger.ExportDataToAPI',0, false, ErrorStr, True);
            //Rollback all batches transferred

            if not RollbackBatch(BankAcToExport.BatchRef,RespStr, ErrorStr,False, TypeOfTrans) then
            begin
              LogUtil.LogMsg(lmError, UnitName, ErrorStr);
              HelpfulErrorMsg('Exception in journal export in PracticeLedger.RollbackBatch',0, false, ErrorStr, True);
            end;

            FExportTerminated := True;
            Exit;
          end;
          SetTransferredFlag(Selected,TypeOfTrans, FromIndex);
        finally
          FreeAndNil(RequestJson);
        end;
        FromIndex := FromIndex + MAXENTRIES;
      end;
    end;
  end
  else if ((TypeOfTrans = ttJournals) and Assigned(FJournalsData)) then
  begin
    FromIndex := 0;
    for i := 1 to Ceil(FJournalsData.ItemCount/MAXENTRIES) do
    begin
      RequestJson :=  TlkJSONobject.Create();
      try
        // Write will update a new batch ref and this will be used when
        FJournalsData.Write(RequestJson, FromIndex, MAXENTRIES);
        if DebugMe then
          LogUtil.LogMsg(lmInfo, UnitName, 'PL journal batch exported - ' + FJournalsData.BatchRef);

        //send to api
        if not UploadToAPI(RequestJson, RespStr, ErrorStr, False, TypeOfTrans) then
        begin
          LogUtil.LogMsg(lmError, UnitName, ErrorStr);
          HelpfulErrorMsg('Exception in journal export in PracticeLedger.ExportDataToAPI',0, false, ErrorStr, True);

          //Rollback all batches transferred
          if not RollbackBatch(FJournalsData.BatchRef,RespStr, ErrorStr,False, TypeOfTrans) then
          begin
            LogUtil.LogMsg(lmError, UnitName, ErrorStr);
            HelpfulErrorMsg('Exception in journal export in PracticeLedger.RollbackBatch',0, false, ErrorStr, True);
          end;

          FExportTerminated := True;
          Exit;
        end;
        SetTransferredFlag(Selected, TypeOfTrans, FromIndex);
      finally
        FreeAndNil(RequestJson);
      end;
      FromIndex := FromIndex + MAXENTRIES;
    end;
  end;
end;

{ PracticeLedgerThread }

constructor TPracticeLedgerThread.CreateThread(CreateSuspended,
  aIsLoadBusiness: Boolean);
begin
  inherited Create(CreateSuspended);
  IsDownloadBusiness := aIsLoadBusiness;
end;

procedure TPracticeLedgerThread.Execute;
var
  sError: string;
begin
  FreeOnTerminate := True;

  while not Terminated do
  begin
    PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
    PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
    PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;

    if (CheckFormyMYOBTokens(False)) then
    begin
      PracticeLedger.Firms.Clear;
      PracticeLedger.Businesses.Clear;
      
      if not PracticeLedger.GetFirms(PracticeLedger.Firms, sError) then
        LogUtil.LogMsg(lmError,UnitName, sError);

      if (IsDownloadBusiness and Assigned(AdminSystem) and (Trim(AdminSystem.fdFields.fdmyMYOBFirmID)<>'')) then
      begin
        if not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID,  ltPracticeLedger,PracticeLedger.Businesses, sError) then
          LogUtil.LogMsg(lmError,UnitName, sError);
      end;
    end;

    Terminate;
  end;
end;

initialization
  PracticeLedger:= TPracticeLedger.Create;
  DebugMe := LogUtil.DebugUnit( UnitName );

finalization
  if Assigned(PracticeLedger) then
    FreeAndNil(PracticeLedger);
end.
