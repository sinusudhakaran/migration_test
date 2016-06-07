unit PracticeLedgerObj;

interface

uses CashbookMigration, sysUtils, CashbookMigrationRestData, PracticeLedgerRestData, uLkJSON,
    chList32, Classes, bkdefs, MoneyDef, TransactionUtils, bkchio, baObj32,
    bkutil32, bkConst, Templates;

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
    procedure BuildBankTransactionData;
    procedure BuildJournalData;
    procedure UploadTransAndJournals(Selected:TStringList;TypeOfTrans: TTransType);

    //Get COA from PL api and add to chart
    procedure SetTransferredFlag(Selected : TStringList;TypeOfTrans: TTransType;FromIndex:Integer);
    //Call Rollback api to rollback a batch of transaction
    function RollbackBatch(aBatchRef: string;
      var aRespStr, aErrorDescription: string;
      aEncryptToken: Boolean; TypeOfTrans: TTransType):Boolean;
  public
    //Couldn't make these private variables and add property since the getfirms and getbusiness need var list to be passed
    Firms : TFirms;// read FFirms write FFirms;
    Businesses : TBusinesses ;//read FBusinesses write FBusinesses;
    LoadingCOAForTheFirstTime : Boolean;

    constructor Create;override;
    destructor Destroy;override;

    //Refresh chart
    procedure RefreshChartFromPLAPI;
    function FetchCOAFromAPI(NewChart: TChart; var ErrMsg : string):Boolean;
    function ProcessChartOfAccounts(NewChart: TChart;Accounts: TChartOfAccountsData):Boolean;

    procedure ResetMyMYOBUserDetails;
    function CountEligibleFirms ( aRefreshPLFirms : boolean = false; aFilterCountry : boolean = true ) : integer;  // Fetches firms and returns count of Eligible Firms
    function MYOBUserHasAccesToFirm( aMYOBFirmID : String; aRefreshPLFirms : boolean; aFilterCountry : boolean = true  ) : boolean;  //Checks if the MYOBUser Has Access to a firm

    procedure PrepareTransAndJournalsToExport(Selected:TStringList;TypeOfTrans: TTransType;FromDate, ToDate : Integer);

    //Upload transactions
    function UploadToAPI(RequestData: TlkJSONobject;
            var aRespStr : string; var aErrorCode : integer; var aErrorDescription: string;
            aEncryptToken: Boolean; TypeOfTrans: TTransType):Boolean;

    //Export data to pl api
    function ExportDataToAPI(FromDate, ToDate : Integer;
        AllowUncoded : boolean = False;
        AllowBlankContra : boolean = False):Boolean;

    //This function will be called from DoTransaction which is a hooked event to Traverse to filter the export transactions
    procedure AddTransactionToExpList;
    function GetBankAccount(aIndex: Integer):TBankAccountData;

// Move to PracticeLedgerObj
    function GetBusinesses( aFirmID: string; LicenseType:TLicenceType;
               var aBusinesses: TBusinesses; var aErrorCode : integer;
               var aErrorDescription: string):Boolean; override;
// Move to PracticeLedgerObj
    function GetChartOfAccounts( aBusinessID:string;var aChartOfAccounts: TChartOfAccountsData;
               var aErrorCode : integer; var aErrorDescription:string):Boolean; override;

    function GetTaxCodeSplitUp(APLAcctType,APLTaxCode:string):Byte;
    function GetTaxCodeMerged(aGST_Class: byte): string;
    function LoadPLGSTTemplate(var aTemplateError : TTemplateError):Boolean;
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

  GSTIncome = 'GSTI';
  GSTOutcome = 'GSTO';
  GSTUnCategorised = 'NONE';

var
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

uses Globals, GSTCalc32, ErrorMoreFrm, WarningMoreFrm,
      LogUtil, progress, software, chartutils, ovcDate,
      Bk5Except, InfoMoreFrm, DlgSelect, bkDateUtils, Traverse, TravUtils,
      ContraCodeEntryfrm, StDateSt, GenUtils, FrmChartExportMapGSTClass,
      ChartExportToMYOBCashbook, Math, myMYOBSignInFrm, Forms, Controls,
      INISettings, GSTUTIL32, ipshttps;

var
  DebugMe : boolean = false;
  
function CheckFormyMYOBTokens(aUseRefreshToken:Boolean=True):Boolean;
var
  liErrorCode : integer;
  lsErrorDescription : string;
  InvalidPass : Boolean;
begin
  Result := False;

  { 1/180 to add extra 20 seconds, to get extra 20 seconds before expire.}
  if ((Trim(UserINI_myMYOB_Access_Token) <> '') and
      (Trim(UserINI_myMYOB_Random_Key) <> '')) then
  begin
    if ((UserINI_myMYOB_Expires_TokenAt = 0) or (UserINI_myMYOB_Expires_TokenAt > (Now))) then
    begin
      Result := True;
      PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
      PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
      PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;
    end
    else if (Trim(UserINI_myMYOB_Refresh_Token) <> '') then
    begin
      //Use refresh token to get access token
      if aUseRefreshToken and Assigned(PracticeLedger) then
      begin
        PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
        PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;

        if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
          Exit;

        if PracticeLedger.RefreshTheToken(liErrorCode, lsErrorDescription, InvalidPass) then
        begin
          Result := True;

          UserINI_myMYOB_Access_Token := PracticeLedger.UnEncryptedToken;
          UserINI_myMYOB_Random_Key := PracticeLedger.RandomKey;
          UserINI_myMYOB_Refresh_Token := PracticeLedger.RefreshToken;
          UserINI_myMYOB_Expires_TokenAt := PracticeLedger.TokenExpiresAt;
          WriteUsersINI(CurrUser.Code);
          PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
          PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
          PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;

        end
        else
        begin
          LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
          //Result := PracticeLedger.RefreshTheToken(sError, InvalidPass);
        end;
      end;
    end;
  end;
end;

procedure GetFirmsAndBusinesses(aIsLoadBusiness:Boolean);
begin
  //PracticeLedgerThread := TPracticeLedgerThread.CreateThread(False,aIsLoadBusiness);
  //Application.ProcessMessages;
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
const
  TheMethod = 'BuildBankTransactionData';
var
  TransactionItem: TTransactionData;
  DissRec: pDissection_Rec;
  AllocationItem : TAllocationData;
  AccRec : pAccount_Rec;
// P5-1068 Validation of Contra-Code  S : ShortString;
  NarrationLength : integer;

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
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  Inc(NoOfEntries );
  with MyClient.clFields, Bank_Account.baFields, Transaction^ do
  begin
    if (txDate_Transferred > 0) then
      Exit;

    //if ( txFirst_Dissection = nil ) then
    begin
      //txDate_Transferred := CurrentDate;
// P5-1068 Validation of Contra-Code      S :=  GetNarration(TransAction,Bank_Account.baFields.baAccount_Type);
      if ( txGST_Class=0 ) then txGST_Amount := 0;
      // Check if Transaction is not finalized and not presented
      if (txDate_Transferred > 0) then
        Exit;

      NarrationLength := length( txStatement_Details );
      if NarrationLength > 255 then
        NarrationLength := 255;


      TransactionItem := TTransactionData.Create(FBankAcctToExport.Transactions);
      TransactionItem.Date        := StDateToDateString('yyyy-mm-dd', txDate_Effective, true);
      TransactionItem.SequenceNo  := txSequence_No;

      TransactionItem.Description := copy( txStatement_Details, 1, NarrationLength );
      if length( TransactionItem.Description ) = 0 then
        TransactionItem.Description := '_';


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
              AllocationItem.AccountNumber := ''                            // Need to ensure that it is in the system
            else
              AllocationItem.AccountNumber := DissRec^.dsAccount;
          end;

          AllocationItem.Description := DissRec^.dsGL_Narration;
          if length( AllocationItem.Description ) = 0 then
            AllocationItem.Description := '_';
          
          AllocationItem.Amount := Trunc(DissRec^.dsAmount);
          AllocationItem.TaxAmount := Trunc(DissRec^.dsGST_Amount);
          AllocationItem.TaxRate := GetTaxCodeMerged(DissRec^.dsGST_Class);//GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);
          if Trim(AllocationItem.TaxRate) = '' then
            HelpfulErrorMsg( 'There are transactions without a GST code, ' +  // P5-1068 Validation of Contra-Code
              'please make sure your Chart of Accounts is up to date.', 0 );  // P5-1068 Validation of Contra-Code
// P5-1068 Validation of Contra-Code             AllocationItem.TaxRate := 'NA';


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
        AllocationItem.TaxRate := GetTaxCodeMerged( txGST_Class);//GetCashBookGSTType(aGSTMapCol, txGST_Class);
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
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
end;

procedure TPracticeLedger.BuildJournalData;
const
  TheMethod = 'BuildJournalData';
var
  JournalItem : TJournalData;
  LineItem : TLineData;
  AccRec : pAccount_Rec;
  DissRec: pDissection_Rec;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

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
    if length( JournalItem.Description ) = 0 then
      JournalItem.Description := '_';
    
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
      LineItem.TaxRate     := GetTaxCodeMerged( DissRec^.dsGST_Class);//GetCashBookGSTType(aGSTMapCol, DissRec^.dsGST_Class);
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

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
end;


constructor TPracticeLedger.Create;
begin
  inherited;
  FLicenseType := ltPracticeLedger;
  LoadingCOAForTheFirstTime := False;
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

  ContraCodeInChart  : pAccount_Rec;
  InvalidContraCodes : TStringlist;
  InvalidContras     : string;

begin
  Result := False;
  if Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '' then
  begin
    HelpfulErrorMsg('Online Firm should be associated before exporting data!',
                      0, false, 'Make sure admin user setup an Online ledger firm before you export data to ' +  GetAPIName , true);
    Exit;
  end;

  if Trim(MyClient.clExtra.cemyMYOBClientIDSelected) = '' then
  begin
    HelpfulErrorMsg('MYOB online client should be associated before exporting data!',
                      0, false, 'Make sure you select an Online ledger client before you export data to ' + GetAPIName, true);
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
                      0, false, 'Sign in to MYOB portal to get the access tokens to communicate to ' + GetAPIName, true);
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

  Msg := 'Export data [' + GetAPIName + ' API] from ' + BkDate2Str(FromDate) +
    ' to ' + bkDate2Str(ToDate);

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ' + Msg);

  Selected := dlgSelect.SelectBankAccountsForExport( FromDate, ToDate );
  if Selected = nil then
    Exit;

  try
    with MyClient.clFields do
    begin
      InvalidContraCodes := TStringlist.Create;
      try
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

            if (not AllowUncoded) then
            begin
              if (not TravUtils.AllGSTCoded(BA, FromDate, ToDate)) then
              begin
                HelpfulInfoMsg('We found some transactions with invalid GST codes in account "'+ baBank_Account_Number+'". ' +
                   'You need to update these codes before you can export data.',  0 );
                Exit;
              end;
              if (not TravUtils.AllCoded(BA, FromDate, ToDate)) then
              begin
                HelpfulInfoMsg( 'Account "'+ baBank_Account_Number+'" has uncoded entries. ' +
                   'You must code all the entries before you can extract them.',  0 );
                Exit;
              end;
            end;

  // P5-1068 Validation of Contra-Code https://myobconfluence.atlassian.net/wiki/display/BP/Validation+Changes         if ((not AllowBlankContra) and (not AllowBlankContra)) then
            if true then // // P5-1068 Validation of Contra-Code - force to true ((not AllowBlankContra) and (not AllowBlankContra)) then
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

          ContraCodeInChart := MyClient.clChart.FindCode( BA.baFields.baContra_Account_Code );
          if not assigned( ContraCodeInChart ) or      // Couldn't find the Contra code OR
                 ( assigned( ContraCodeInChart ) and   // Contra Code is found AND the
                   ContraCodeInChart.chInactive ) or   // Contra code is not active
                 ( length( BA.baFields.baContra_Account_Code ) > 255 ) then // Contra code is too long for MYOB Ledger (Max 255) 
          begin
            InvalidContraCodes.Add( BA.baFields.baBank_Account_Number );
          end;

        end;

        if InvalidContraCodes.Count > 0 then begin
          InvalidContras := InvalidContraCodes[ 0 ];
          for i := 1 to InvalidContraCodes.Count - 1 do
            InvalidContras := format( '%s, %s', [ InvalidContras, InvalidContraCodes[ i ] ] );

          if InvalidContraCodes.Count > 1 then
            Msg := format( 'Your contra codes for Bank Account numbers %s are ' +
                           'not valid. Please update under Other Functions ' +
                           '| Bank Accounts before exporting', [ InvalidContras ] )
          else
            Msg := format( 'Your contra code for Bank Account number %s is ' +
                           'not valid. Please update under Other Functions ' +
                           '| Bank Accounts before exporting', [ InvalidContras ] );

          HelpfulErrorMsg( Msg, 0, true );

          exit; // Some contra codes are invalid, need the user to correct
        end;
      finally
        freeAndNil( InvalidContraCodes );
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
        if Not FExportTerminated then
        begin
          PrepareTransAndJournalsToExport(Selected, ttJournals, FromDate, ToDate);
          UploadTransAndJournals(Selected, ttJournals);
        end;

        if Not FExportTerminated then
        Begin
          Result := True;
          Msg := SysUtils.Format( 'Extract Data Complete. %d Entries were exported to ' + GetAPIName + ' Account',[NoOfEntries] );
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
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends' );
  end;
end;

function TPracticeLedger.FetchCOAFromAPI(NewChart: TChart; var ErrMsg : string): Boolean;
var
  Accounts : TChartOfAccountsData;
  liErrorCode : integer;
  lsErrorDescription: string;
  UnknownGSTCodesFound : Boolean;
  SignInFrm : TmyMYOBSignInForm;
  TemplateError : TTemplateError;
const
  TheMethod = 'FetchCOAFromAPI';
begin
  Result := False;
  ErrMsg := '';
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  if not Assigned(AdminSystem) then
    Exit;

  if Trim(AdminSystem.fdFields.fdmyMYOBFirmID) = '' then
  begin
    //HelpfulErrorMsg('Online Firm should be associated before a refresh chart!',
        //              0, false, 'Make sure admin user setup an Online ledger firm before you do a refrsh chart', true);
    Exit;
  end;

  if Trim(MyClient.clExtra.cemyMYOBClientIDSelected) = '' then
  begin
    //HelpfulErrorMsg('MYOB online client should be associated before exporting data!',
        //              0, false, 'Make sure you select an Online ledger client before you export data to Online Ledger', true);
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
        ErrMsg := 'Establish a MYOB login before refresh chart';
        HelpfulErrorMsg(ErrMsg,
                      0, false, 'Sign in to MYOB portal to get the access tokens to communicate to ' + GetAPIName, true);
        Exit;
      end;
    finally
      Screen.Cursor := crDefault;
      FreeAndNil(SigninFrm);
    end;
  end;

  if not MYOBUserHasAccesToFirm( AdminSystem.fdFields.fdmyMYOBFirmID, True) then
  begin
    ErrMsg := 'Your MYOB Credential does not have access to the Firm. Please log in with a different MYOB Credential, ' +
      'or contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.' +
      'The existing chart has not been modified.';
    HelpfulWarningMsg( ErrMsg, 0 );
    Exit;
  end;

  Accounts := TPracticeLedgerChartOfAccountsData.Create(TPracticeLedgerChartOfAccountData, AdminSystem.fdFields.fdCountry);
  try
    RandomKey := UserINI_myMYOB_Random_Key;
    EncryptToken(UserINI_myMYOB_Access_Token);
    if not GetChartOfAccounts(MyClient.clExtra.cemyMYOBClientIDSelected, Accounts,
             liErrorCode, lsErrorDescription) then
    begin
      ErrMsg := 'Could not connect to my.MYOB service, please try again later. ' +
                'If problem persists please contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.';
      HelpfulErrorMsg(ErrMsg,
                      0, false, lsErrorDescription, true);
      Exit;
    end;

    {Load GST Setup only for the first time client set up business, do this ONLY for Australain clients at the moment}
    if LoadingCOAForTheFirstTime then
    begin
      if (AdminSystem.fdFields.fdCountry = whAustralia) then
      begin
        if not LoadPLGSTTemplate(TemplateError) then
        begin
          if TemplateError = trtDoesNotExist then
            ErrMsg := 'MYOBLedger.tpm does not exist'
          else
            ErrMsg := 'MYOBLedger.tpm has invalid data';

          HelpfulErrorMsg(ErrMsg + ', please contact ' + SHORTAPPNAME + ' support ' + SupportNumber + '.',
                          0, false);
          Exit;
        end;
      end
      else if (AdminSystem.fdFields.fdCountry = whNewZealand) then
      begin
        Template.LoadNZMYOBLedgerTemplate();
      end;
    end;

    UnknownGSTCodesFound := ProcessChartOfAccounts(NewChart, Accounts);

    if UnknownGSTCodesFound then
      LogUtil.LogMsg( lmError, UnitName, TheMethod + ' : The new chart file contained unknown GST Indicators' );

    Result := True;
  finally
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
    Accounts.Clear;
    FreeAndNil(Accounts);
  end;
end;

function TPracticeLedger.GetBankAccount(aIndex: Integer): TBankAccountData;
begin
  Result := Nil;
  if ((FBankAcctsToExport.Count > 0)  and (aIndex < FBankAcctsToExport.Count)) then
    Result := TBankAccountData(FBankAcctsToExport.ItemAs(aIndex));
end;

function TPracticeLedger.GetBusinesses(aFirmID: string; LicenseType:TLicenceType;
  var aBusinesses: TBusinesses; var aErrorCode : integer; var aErrorDescription: string): Boolean;
var
  sURL: string;
  JsonObject: TlkJSONObject;
  RespStr : string;
begin
  Result := False;
  JsonObject := nil;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    try
      sURL := PRACINI_CashbookAPIBusinessesURL;
      FDataRequestType := drtBusiness;

      if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
      begin
        HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
        Exit;
      end;

      if not DoHttpSecureJson(sURL, nil, RespStr, aErrorCode, aErrorDescription) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      if Assigned(FDataResponse) then
      begin
        JsonObject := (FDataResponse as TlkJSONObject);
        RespStr := TlkJSON.GenerateText(JsonObject);
      end;

      if DebugMe then
        LogUtil.LogMsg(lmInfo, UnitName, RespStr);

      if Assigned(aBusinesses) and Assigned(JsonObject) then
        aBusinesses.Read(aFirmID,LicenseType,JsonObject);

    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorCode        := E.Code;
        aErrorDescription := E.Message;
      end;
      on E: Exception do
      begin
        aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
        aErrorDescription := Format('Exception running %s.GetBusinesses, Error Message : ' + E.Message,[GetAPIName]);
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;

  Result := True;
end;

function TPracticeLedger.GetChartOfAccounts(aBusinessID: string; var aChartOfAccounts: TChartOfAccountsData;
           var aErrorCode : integer; var aErrorDescription: string): Boolean;
var
  sURL: string;
  JsonObject: TlkJSONObject;
  RespStr : string;
begin
  Result := False;
  JsonObject := nil;
  aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
  aErrorDescription := '';
  try
    try
      sURL := Format(PRACINI_CashbookAPICOAURL,[aBusinessID]);
      FDataRequestType := drtCOA;
      if not FileExists(GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN) then
      begin
        HelpfulWarningMsg('File ' + GLOBALS.PublicKeysDir + PUBLIC_KEY_FILE_CASHBOOK_TOKEN + ' is missing in the folder', 0);
        Exit;
      end;

      if not DoHttpSecureJson(sURL, nil, RespStr, aErrorCode, aErrorDescription) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;

      if Trim(FDataError) <> '' then
        Exit;

      if Assigned(FDataResponse) then
      begin
        JsonObject := (FDataResponse as TlkJSONObject);
        RespStr := TlkJSON.GenerateText(FDataResponse);
      end;
      if Assigned(aChartOfAccounts) and Assigned(JsonObject) then
      begin
        aChartOfAccounts.Read(aBusinessID,JsonObject);
      end;

    except
      on E: EipsHTTPS do  // ipsHttps Exception
      begin
        aErrorDescription := format ( 'Exception running %s.GetCOA, Error Code : %d, ' +
          'Error Message : ', [ GetAPIName, E.Code, E.Message ] );
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
      on E: Exception do
      begin
        aErrorCode        := low( integer ); // Ensure that the Errorcode reports Not Applicable
        aErrorDescription := 'Exception running ' + GetAPIName + '.GetCOA, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
  end;
  Result := True;
end;

function TPracticeLedger.GetTaxCodeSplitUp(APLAcctType,
  APLTaxCode: string): Byte;
var
  sTaxCodeSplit : string;
begin
  Result := 0;

  if not Assigned(MyClient) then
    Exit;

  if ((UpperCase(APLTaxCode) = 'GST') or (UpperCase(APLTaxCode) =  'NA')) then
  begin
    if ((LowerCase(APLAcctType) = AT_COSTOFSALES) or
      (LowerCase(APLAcctType) = AT_EXPENSE) or
      (LowerCase(APLAcctType) = AT_OTHEREXPENSE) or
      (LowerCase(APLAcctType) = AT_ASSET)) then
        sTaxCodeSplit := GSTIncome
    else if ((LowerCase(APLAcctType) = AT_INCOME) or
      (LowerCase(APLAcctType) = AT_OTHERINCOME) or
      (LowerCase(APLAcctType) = AT_LIABILITY) or
      (LowerCase(APLAcctType) = AT_EQUITY)) then
      sTaxCodeSplit := GSTOutcome
    else if ((LowerCase(APLAcctType) = AT_UNCATEGORISED) or (UpperCase(APLTaxCode) = 'NA' )) then
      sTaxCodeSplit := GSTUnCategorised;

    Result := GSTCalc32.GetGSTClassNo( MyClient, sTaxCodeSplit);
    {if GSTOutcome is GSTI or GSTO and it's missing in the GST setup , search for GST and use it}

    if ((Result = 0) and
        ((sTaxCodeSplit = GSTOutcome)  or  (sTaxCodeSplit = GSTIncome))
        )then
      Result := GSTCalc32.GetGSTClassNo( MyClient, 'GST');
  end
  else
  begin
    sTaxCodeSplit := APLTaxCode;
    Result := GSTCalc32.GetGSTClassNo( MyClient, sTaxCodeSplit);
  end;

end;

function TPracticeLedger.GetTaxCodeMerged(aGST_Class: byte): string;
var
  TaxCodeMerge : string;
begin
  Result := 'NA';

  if not Assigned(MyClient) then
    Exit;

  TaxCodeMerge := GSTCalc32.GetGSTClassCode( MyClient, aGST_Class);

  if ((UpperCase(TaxCodeMerge) = GSTIncome) or
      (UpperCase(TaxCodeMerge) = GSTOutcome)) then
    TaxCodeMerge := 'GST';

  Result := TaxCodeMerge;
end;

function TPracticeLedger.LoadPLGSTTemplate(var aTemplateError : TTemplateError): Boolean;
var
  TemplateFileName : string;
begin
  Result := False;

  TemplateFileName := IncludeTrailingPathDelimiter(GLOBALS.TemplateDir) + 'MYOBLedger.TPM';

  if Template.LoadTemplate( TemplateFilename, tpl_CreateChartFromTemplate, aTemplateError) then
  begin
    //HelpfulInfoMsg('MYOB Ledger GST template loaded from '+TemplateFileName, 0 );
    LogUtil.LogMsg(lmInfo, UnitName, 'MYOB Ledger GST template loaded automatically from ' + TemplateFileName);
    //now reload the gst defaults for the client
    GSTUTIL32.ApplyDefaultGST(false);
    Result := True;
  end;
end;

procedure TPracticeLedger.ResetMyMYOBUserDetails;
begin
  UserINI_myMYOB_Access_Token := '';
  UserINI_myMYOB_Random_Key := '';
  UserINI_myMYOB_Refresh_Token := '';
  UserINI_myMYOB_Expires_TokenAt := 0;

  WriteUsersINI(CurrUser.Code);
end;

function TPracticeLedger.CountEligibleFirms( aRefreshPLFirms : boolean = false; aFilterCountry : boolean = true ): integer;
var
  Firm        : TFirm;
  liLoop      : integer;

  liErrorCode: integer;
  lsErrorDescription: string;
begin
  result := 0;
  if aRefreshPLFirms then //Do we need to Refresh the PracticeLedger.Firms collection first?
    if ( not PracticeLedger.GetFirms( PracticeLedger.Firms, liErrorCode, lsErrorDescription ) ) then
    begin
      Exit;
    end;
  for liLoop := 0 to PracticeLedger.Firms.Count - 1 do
  begin
    Firm := PracticeLedger.Firms.GetItem( liLoop );

    if assigned( Firm ) then
    begin
      // Check for Practice Ledger
      if ( Pos( 'PL',Firm.EligibleLicense ) > 0 ) and
         ( aFilterCountry and                                                // Filter just for the current Region
           (whShortNames[ AdminSystem.fdFields.fdCountry ] = Firm.Region ) ) then // AND Firm is in the current Region
        inc( result );
    end;
  end;
end;

function TPracticeLedger.MYOBUserHasAccesToFirm( aMYOBFirmID: String; aRefreshPLFirms : boolean; aFilterCountry : boolean = true  ): boolean;
var
  Firm        : TFirm;
  liLoop      : integer;
begin
  result := false;
  if CountEligibleFirms( aRefreshPLFirms, aFilterCountry ) > 0 then 
  begin
    for liLoop := 0 to PracticeLedger.Firms.Count - 1 do
    begin
      Firm := PracticeLedger.Firms.GetItem( liLoop );

      if Assigned( Firm ) then
      begin
        // Check if this is the correct firm
        if ( Firm.ID = aMYOBFirmID ) then
        begin
          // Check if the Firm is a eligible PracticeLedger Firm
          if ( Pos( 'PL',Firm.EligibleLicense ) > 0 ) and
             ( aFilterCountry and                                                // Filter just for the current Region
               ( whShortNames[ AdminSystem.fdFields.fdCountry ] = Firm.Region ) ) then // AND Firm is in the current Region
          begin
            result := true;
            Break;
          end;
        end;
      end;
    end;
  end
end;

procedure TPracticeLedger.PrepareTransAndJournalsToExport(Selected:TStringList;TypeOfTrans: TTransType;FromDate, ToDate : Integer);
const
  TheMethod = 'PrepareTransAndJournalsToExport';
var
  BA: TBank_Account;
  i: Integer;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  for i := 0 to Pred(Selected.Count) do
  begin
    BA := TBank_Account(Selected.Objects[i]);
    if (((TypeOfTrans = ttbank) and (BA.baFields.baAccount_Type = btBank)) or
        ((TypeOfTrans = ttJournals) and (BA.baFields.baAccount_Type in [btCashJournals, btAccrualJournals]))) then
    begin
      if DebugMe then
        LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' bank account selected for extract: ' + BA.baFields.baBank_Account_Number);

      if (TypeOfTrans = ttbank) then
      begin
        if not Assigned(FBankAcctsToExport) then
          FBankAcctsToExport := TBankAccountsData.Create(TBankAccountData);
        FBankAcctToExport := TBankAccountData(FBankAcctsToExport.Add);
        FBankAcctToExport.BankAccountNumber := MappingsData.UpdateSysCode(BA.baFields.baContra_Account_Code);
        FBankAcctToExport.BankAccountName := BA.baFields.baBank_Account_Name;
      end;

      Traverse.Clear;
      Traverse.SetSortMethod( csDateEffective );
      Traverse.SetSelectionMethod( TRAVERSE.twAllNewEntries );

      Traverse.SetOnEHProc( DoTransaction );

      //Load all transactions to the Export transaction list
      Traverse.TraverseEntriesForAnAccount( BA, FromDate, ToDate );
    end;
  end;
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' end');
end;

function TPracticeLedger.ProcessChartOfAccounts(
  NewChart: TChart;Accounts: TChartOfAccountsData): Boolean;
var
  i: Integer;
  NewAccount  : pAccount_Rec;
  Account: TChartOfAccountData;
begin
  Result := False;
  for i := 0 to Accounts.Count - 1 do
  begin
    Account := Accounts.ItemAs(i);
    if Assigned(Account) then
    begin
      if (NewChart.FindCode(Account.Code) <> nil) then
        LogUtil.LogMsg( lmError, UnitName, 'Duplicate Code '+
          Account.Code +' found in ' + GetAPIName + ' API' )
      else
      begin
        NewAccount := New_Account_Rec;
        NewAccount^.chAccount_Code := Account.Code;

        {At the moment we are guessing al accounts are normal accounts}
        NewAccount^.chAccount_Type        := Ord('N');
        NewAccount^.chPosting_Allowed     := True;//AccountType[1] <> 'C';
        NewAccount^.chAccount_Description := Account.Name;
        NewAccount^.chGST_Class := 0;
        if not Account.IsSystemAccount then
          NewAccount^.chGST_Class := GetTaxCodeSplitUp(Account.AccountType, Account.GstType);
        if ( NewAccount^.chGST_Class = 0 ) and ( Account.GstType <> '' ) then
        begin
           LogUtil.LogMsg(lmError, UnitName, 'Unknown GST Indicator ' + Account.GstType + ' found in ' + GetAPIName + ': '+ Account.Code );
           Result := True;
        end;
        NewChart.Insert(NewAccount);
      end;
    end;
  end;
end;

procedure TPracticeLedger.RefreshChartFromPLAPI;
const
  ThisMethodName = 'RefreshChartFromPLAPI';
var
  ChartFileName: string;
  NewChart: TChart;
  Msg: string;
  sFinalMessage: string;
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
        if not FetchCOAFromAPI( NewChart, Msg ) then begin // Could not retreive the chart
          LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : Client not selected.'  );
          if Trim(Msg) =  '' then // If no message is already shown inside the functions, then show the below error message
          HelpfulErrorMsg( 'Please select a Client to refresh the chart from, ' +
            'via Other Functions | Accounting System' + #13+#13+
            'The existing chart has not been modified.', 0 );
          LoadingCOAForTheFirstTime := False;
          Exit;
        end;

        if NewChart.ItemCount > 0 then
        begin
           MergeCharts(NewChart, MyClient, False, True, false, True);

           clLoad_Client_Files_From := '';
           clChart_Last_Updated := CurrentDate;
        end
        else
        begin
           Msg := 'Cannot Read Clients Chart';
           LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' - ' + Msg );
           raise EExtractData.CreateFmt( '%s - %s : %s', [ UnitName, ThisMethodName, Msg ] );
        end;

        if LoadingCOAForTheFirstTime then begin
          sFinalMessage := 'Your chart of accounts and ' + QuotedStr('GST Setup') + ' have been updated.'#13#13;
          sFinalMessage := sFinalMessage  + 'You need to check a couple of things;' + #13;
          sFinalMessage := sFinalMessage  + '  1. Add missing control accounts in your GST setup.'+ #13;
          sFinalMessage := sFinalMessage  + '  2. Update contra codes for your bank accounts.';
        end
        else
          sFinalMessage := 'Your chart of accounts has been updated.'#13#13;


        HelpfulInfoMsg(sFinalMessage, 0 );
        ClearStatus(True);
      finally
        ClearStatus(True);
        NewChart.Free;
        LoadingCOAForTheFirstTime := False;
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
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' ends' );

end;

function TPracticeLedger.RollbackBatch(aBatchRef: string;
  var aRespStr, aErrorDescription: string;
  aEncryptToken: Boolean; TypeOfTrans: TTransType): Boolean;
var
  sURL: string;
  RespStr : string;
  RequestJson : TlkJSONobject;
  Response : TlkJSONObject;

  liErrorCode : integer;
const
  TheMethod = 'RollbackBatch';
begin
  Result := True;

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  if Trim(aBatchRef) = '' then
    Exit;
  try
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
        LogUtil.LogMsg(lmDebug,UnitName, TheMethod + ': ' + TlkJSON.GenerateText(RequestJson));

      if not DoDeleteSecureJson( sURL, RequestJson, RespStr, liErrorCode, aErrorDescription ) then
        Exit;

      //Wait til data gets transferred completely
      while (FDataTransferStarted) do
        ;

      aErrorDescription := FDataError;
      if Assigned(FDataResponse) then
      begin
        Response := FDataResponse as TlkJSONObject;
        aRespStr := TlkJSON.GenerateText(Response);
      end;
    except
      on E: Exception do
      begin
        aErrorDescription := 'Exception running ' + GetAPIName + '.RollbackBatch, Error Message : ' + E.Message;
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
    Result := True;
  finally
    SetDefaultTransferMethod;

    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
    if Assigned(RequestJson) then
      FreeAndNil(RequestJson);
  end;
end;

procedure TPracticeLedger.SetTransferredFlag(Selected : TStringList;TypeOfTrans: TTransType;FromIndex:Integer);
const
  TheMethod = 'SetTransferredFlag';
var
  i, k, ToIndex: Integer;
  stDate : TStDate;
  SeqNo: Integer;
  TransRec: pTransaction_Rec;
  BA : TBank_Account ;

  function GetABankAccount(aAcctNo, aAcctName : string):TBank_Account;
  var
    j: Integer;
  begin
    Result := nil;
    for j := 0 to Selected.Count - 1 do
    begin
      if ((TBank_Account(Selected.Objects[j]).baFields.baContra_Account_Code =  aAcctNo) and
          (TBank_Account(Selected.Objects[j]).baFields.baBank_Account_Name =  aAcctName))then
      begin
        Result := TBank_Account(Selected.Objects[j]);
        Break;
      end;
    end;
  end;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  if TypeOfTrans = ttbank then
  begin
    if FromIndex + MAXENTRIES > FBankAcctToExport.Transactions.Count then
      ToIndex := FBankAcctToExport.Transactions.Count
    else
      ToIndex := FromIndex + MAXENTRIES;

    BA := GetABankAccount(FBankAcctToExport.BankAccountNumber, FBankAcctToExport.BankAccountName);
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
      BA := GetABankAccount(TJournalData(FJournalsData.Items[i]).JournalContraCode, TJournalData(FJournalsData.Items[i]).JournalAccountName);

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

  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
end;

function TPracticeLedger.UploadToAPI(RequestData: TlkJSONobject;
  var aRespStr : string; var aErrorCode : integer; var aErrorDescription: string;
  aEncryptToken: Boolean; TypeOfTrans: TTransType): Boolean;
var
  sURL: string;
const
  TheMethod = 'UploadTransactions';
begin
  Result := False;
  aRespStr:= '';
  aErrorCode := 0;
  aErrorDescription := '';
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  try
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
        LogUtil.LogMsg(lmDebug,UnitName, TheMethod + ': ' + TlkJSON.GenerateText(RequestData));

      Result := DoHttpSecureJson(sURL, RequestData, aRespStr, aErrorCode, aErrorDescription);

      //Wait til data gets transferred completely
      //while (FDataTransferStarted) do
        //;

      (*if Assigned(FDataResponse) then  // Might have some error back
      begin
        Response := FDataResponse as TlkJSONObject; // This is like a create , so destroy at the end
        aRespStr := TlkJSON.GenerateText(Response);
        aError := ProcessErrorMessage(Response);
      end;*)
    except
      on E: Exception do
      begin
        aErrorDescription := format( 'Exception running %s. UploadToAPI, Error Message : %s', [ GetAPIName, E.Message ] );
        LogUtil.LogMsg(lmError, UnitName, aErrorDescription);
        Exit;
      end;
    end;
  finally
    if Assigned(FDataResponse) then
      FreeAndNil(FDataResponse);

    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
  end;
end;

procedure TPracticeLedger.UploadTransAndJournals(Selected:TStringList;TypeOfTrans: TTransType);
const
  TheMethod = 'UploadTransAndJournals';
var
  i, j , FromIndex: Integer;
  RequestJson : TlkJSONobject;
  liErrorCode : integer;
  lsErrorDescription,DelErrorStr, RespStr : string;
  SetTransferFlag: Boolean;
  //BankAcToExport: TBankAccountData;
begin
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins');

  if ((TypeOfTrans = ttbank) and Assigned(FBankAcctsToExport)) then
  begin
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ' Exporting bank transactions');

    for i := 0 to FBankAcctsToExport.Count - 1 do
    begin
      FBankAcctToExport := FBankAcctsToExport.ItemAs(i);
      if FBankAcctToExport.Transactions.Count <= 0 then
        Continue;

      FromIndex := 0;
      SetTransferFlag := True;
      for j := 1 to Ceil(FBankAcctToExport.Transactions.Count / MAXENTRIES) do
      begin
        RequestJson :=  TlkJSONobject.Create();
        try
          FBankAcctToExport.Write(RequestJson, FromIndex, MAXENTRIES);

          if DebugMe then
          begin
            LogUtil.LogMsg(lmDebug, UnitName, 'PL bank transactions from ' + IntToStr(FromIndex) + ' batch exported - ' + FBankAcctToExport.BatchRef);
            LogUtil.LogMsg(lmDebug, UnitName, 'Data exported :' + TlkJSON.GenerateText(RequestJson));
          end;

          //send to api
          if not  UploadToAPI( RequestJson, RespStr, liErrorCode, lsErrorDescription, False, TypeOfTrans) then
          begin
            LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
            //Rollback all batches transferred
            SetTransferFlag := False;
            if not RollbackBatch(FBankAcctToExport.BatchRef,RespStr, DelErrorStr,False, TypeOfTrans) then
            begin
              LogUtil.LogMsg(lmError, UnitName, DelErrorStr);
              //HelpfulErrorMsg('Exception in journal export in PracticeLedger.RollbackBatch',0, false, DelErrorStr, True);
            end;
            HelpfulErrorMsg('Exception in bank transaction export in ' + GetAPIName + '.ExportDataToAPI',0, false, lsErrorDescription, True);

            FExportTerminated := True;
            Exit;
          end;
        finally
          FreeAndNil(RequestJson);
        end;
        FromIndex := FromIndex + MAXENTRIES;
      end;
      if SetTransferFlag then
        SetTransferredFlag(Selected,TypeOfTrans, 0);
    end;
  end
  else if ((TypeOfTrans = ttJournals) and Assigned(FJournalsData)) then
  begin
    FromIndex := 0;
    if DebugMe then
      LogUtil.LogMsg(lmDebug, UnitName, ' Exporting journal transactions');

    SetTransferFlag := True;
    for i := 1 to Ceil(FJournalsData.ItemCount/MAXENTRIES) do
    begin
      RequestJson :=  TlkJSONobject.Create();
      try
        // Write will update a new batch ref and this will be used when
        FJournalsData.Write(RequestJson, FromIndex, MAXENTRIES);

        if DebugMe then
        begin
          LogUtil.LogMsg(lmDebug, UnitName, 'PL journal transactions from ' + IntToStr(FromIndex) + ' batch exported - ' + FJournalsData.BatchRef);
          LogUtil.LogMsg(lmDebug, UnitName, 'Data exported :' + TlkJSON.GenerateText(RequestJson));
        end;

        //send to api
        if not UploadToAPI(RequestJson, RespStr, liErrorCode, lsErrorDescription, False, TypeOfTrans) then
        begin
          LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
          //Rollback all batches transferred
          if not RollbackBatch(FJournalsData.BatchRef,RespStr, DelErrorStr,False, TypeOfTrans) then
          begin
            LogUtil.LogMsg(lmError, UnitName, DelErrorStr);
            //HelpfulErrorMsg('Exception in journal export in PracticeLedger.RollbackBatch',0, false, ErrorStr, True);
          end;
          SetTransferFlag := False;
          HelpfulErrorMsg('Exception in journal export in ' + GetAPIName + '.ExportDataToAPI',0, false, lsErrorDescription, True);

          FExportTerminated := True;
          Exit;
        end;
//        SetTransferredFlag(Selected, TypeOfTrans, FromIndex);
      finally
        FreeAndNil(RequestJson);
      end;
      FromIndex := FromIndex + MAXENTRIES;
    end;
    if SetTransferFlag then
      SetTransferredFlag(Selected,TypeOfTrans, 0);
  end;
  if DebugMe then
    LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends');
end;

{ PracticeLedgerThread }

constructor TPracticeLedgerThread.CreateThread(CreateSuspended,
  aIsLoadBusiness: Boolean);
begin
  inherited Create(CreateSuspended);
  IsDownloadBusiness := aIsLoadBusiness;
end;

procedure TPracticeLedgerThread.Execute;
const
  TheMethod = 'TPracticeLedgerThread.Execute';
var
  liErrorCode : integer;
  lsErrorDescription: string;
begin
  FreeOnTerminate := True;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' begins' );

  while not Terminated do
  begin
    PracticeLedger.UnEncryptedToken := UserINI_myMYOB_Access_Token;
    PracticeLedger.RandomKey := UserINI_myMYOB_Random_Key;
    PracticeLedger.RefreshToken := UserINI_myMYOB_Refresh_Token;

    if (CheckFormyMYOBTokens(False)) then
    begin
      PracticeLedger.Firms.Clear;
      PracticeLedger.Businesses.Clear;

      if not PracticeLedger.GetFirms( PracticeLedger.Firms, liErrorCode, lsErrorDescription ) then
        LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);

      if (IsDownloadBusiness and Assigned(AdminSystem) and (Trim(AdminSystem.fdFields.fdmyMYOBFirmID)<>'')) then
      begin
        if not PracticeLedger.GetBusinesses(AdminSystem.fdFields.fdmyMYOBFirmID,  ltPracticeLedger, PracticeLedger.Businesses, liErrorCode, lsErrorDescription) then
          LogUtil.LogMsg(lmError, UnitName, lsErrorDescription);
      end;
    end;

    Terminate;
    if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, TheMethod + ' ends' );
  end;
end;

initialization
  PracticeLedger:= TPracticeLedger.Create;
  DebugMe := LogUtil.DebugUnit( UnitName );

finalization
  if Assigned(PracticeLedger) then
    FreeAndNil(PracticeLedger);
end.
