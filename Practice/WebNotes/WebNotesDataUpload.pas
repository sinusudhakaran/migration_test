unit WebNotesDataUpload;
//------------------------------------------------------------------------------
{
   Title: WebNotesDataUpload

   Description:

   Author: Andre' Joosten

   Remarks:
      This is Upload to Webnotes only

}
//------------------------------------------------------------------------------
interface

uses
  CheckWebnotesData,
  SysUtils,
  XMLDoc,
  SchedRepUtils,
  XMLIntf,
  xmldom,
  Contnrs,
  stDate,
  MoneyDef,
  bkDefs,
  BaObj32,
  classes,
  clObj32,
  sysobj32;

type
  //----------------------------------------------------------------------------
  EWebNotesDataUploadError = class(Exception)
  end;

  //----------------------------------------------------------------------------
  TWebNotesDataUpload = class(TObject)
  private
    FDateTo: Integer;
    FIsScheduledReport: boolean;
    FDateFrom: Integer;
    FScheduledReportPrintAll: boolean;

    // Some local markers and counters
    AccFirstEntryDate,
    ReportStartDate,
    AccLastEntryDate: TStDate;
    AccountsFound: integer;
    AccountsExported: integer;


    FClient: TClientObj;

    EntriesCount: Integer;
    FReplyURL: string;
    FNotifyClient: Boolean;
    procedure Reset;
    function IncludeTrans(var Account: TBank_Account; Trans: pTransaction_Rec): boolean;
    function IncludeAccount(var Account: TBank_Account): Boolean;
    procedure SetClient(const Value: TClientObj);
    procedure SetDateFrom(const Value: Integer);
    procedure SetDateTo(const Value: Integer);
    procedure SetIsScheduledReport(const Value: boolean);
    procedure SetScheduledReportPrintAll(const Value: boolean);

    procedure AddClient(BatchNode: IXMLNode);
    procedure AddChart(ChartNode: IXMLNode);
    procedure AddJobs(JobsNode: IXMLNode);
    procedure AddPayees(PayeesNode: IXMLNode);
    function  AddAccount(Account: TBank_Account; var AccountsNode: IXMLNode): Boolean;


    procedure SetReplyURL(const Value: string);
    procedure SetNotifyClient(const Value: Boolean);
  public
    AccountList: TList;
    SchdSummaryList: TList;
    FirstSummaryRec: PSchdRepSummaryRec;
    constructor Create;
    destructor Destroy; override;
    property Client: TClientObj read FClient write SetClient;
    property IsScheduledReport : boolean read FIsScheduledReport write SetIsScheduledReport;
    property ScheduledReportPrintAll : boolean read FScheduledReportPrintAll write SetScheduledReportPrintAll;
    property DateFrom: Integer read FDateFrom write SetDateFrom;
    property DateTo: Integer read FDateTo write SetDateTo;

    property ReplyURL: string read FReplyURL write SetReplyURL;
    property NotifyClient: Boolean read FNotifyClient write SetNotifyClient;

    function GetBatchXML: string;

    function TestReply(Reply: string): Boolean;

    procedure FinaliseSheduled(Success: Boolean);
  end;

//------------------------------------------------------------------------------
function ExportWebNotesFile(const aClient : TClientObj;
                            const DateFrom : Integer; const DateTo : integer;
                            var EntriesCount : integer;
                            var EmailMessage: string;
                            var NotifyClient: Boolean;
                            const IsScheduledReport : boolean;

                            const ScheduledReportPrintAll : boolean;
                            const SchdSummaryList : TList;

                            const AccountList: TList;
                            const ReportStartDate: Integer = 0) : boolean;

//------------------------------------------------------------------------------
implementation

uses
  Math,
  bkDateUtils,
  ReportDefs,
  Progress,
  LogUtil,
  Software,
  IniSettings,
  stDatest,
  SyDefs,
  ClientUtils,
  bkConst,
  Globals,
  AutoCode32,
  WebNotesClient,
  GSTCALC32,
  WebNotesSchema,
  WebUtils,
  Admin32,
  BankLinkOnlineServices;

const
  UnitName = 'WebNotesDataUpload';

// Just some general Node, Field and Attribute Names
var
  DebugMe: Boolean = False;

//------------------------------------------------------------------------------
function ExportWebNotesFile(const aClient : TClientObj;
                            const DateFrom : Integer; const DateTo : integer;
                            var EntriesCount : integer;
                            var EmailMessage: string;
                            var NotifyClient: Boolean;
                            const IsScheduledReport : boolean;

                            const ScheduledReportPrintAll : boolean;
                            const SchdSummaryList : TList;

                            const AccountList: TList;
                            const ReportStartDate: Integer = 0) : boolean;
var
  WebClient : TWebNotesClient;
  Service: TWebNotesDataUpload;
  Reply,Batch: string;
  SubIndex     : integer;
  Subscription : TBloArrayOfguid;
  ClientReadDetail : TBloClientReadDetail;

  //----------------------------------------------
  procedure SaveUrl(NewUri: string);
  var
    p: integer;
  begin
    if NewUri = '' then
      Exit;
    p := Pos('?',NewUri);
    if P > 0 then
    begin
     // Found the start of any params...
      NewUri := Copy(NewUri,1,P-1);
    end;

    if Sametext(NewUri,PRACINI_OnlineLink) then
      Exit; // Nothing to save...

    PRACINI_OnlineLink := NewUri;
    // Still here ...
    WritePracticeINI_WithLock;
  end;

begin
  Result := False;
  EmailMessage := '';
  NotifyClient := False;
  UpdateAppStatus(Format('Export to %s', [wfNames[wfWebNotes]]),'Initializing', 5);
  WebClient := TWebNotesClient.CreateUsingIni(GetBK5Ini);
  service := TWebNotesDataUpload.Create;
  try
    try
      // Setup the basics..
      RefreshAdmin;
      WebClient.Country := CountryText(AdminSystem.fdFields.fdCountry);
      WebClient.PracticeCode := AdminSystem.fdFields.fdBankLink_Code;
      WebClient.PassWord := AdminSystem.fdFields.fdBankLink_Connect_Password;

      Service.DateFrom := DateFrom;
      Service.DateTo := DateTo;
      Service.Client := aClient;
      Service.AccountList := AccountList;
      Service.SchdSummaryList := SchdSummaryList;
      Service.IsScheduledReport := IsScheduledReport;
      Service.ScheduledReportPrintAll := ScheduledReportPrintAll;

      // Build the export data
      Batch := Service.GetBatchXML;

      if (Service.EntriesCount = 0) then
        raise Exception.Create('No entries found to export' );

      // The autocode may remove the Progressbar
      // So we just set it up again..
      UpdateAppStatus(Format('Export to %s', [wfNames[wfWebNotes]]),'Sending', 10);

      if WebClient.UpLoad(Batch, Reply) then
      begin
        // Deal with the reply...
        if Service.TestReply(Reply) then
        begin
          inc(EntriesCount, Service.EntriesCount);
          NotifyClient := Service.NotifyClient;

          if Service.NotifyClient and
            (Service.ReplyURL > '') then
            EmailMessage := format
              (#13#13'There are new %s transactions available click the link below to access %s and log in using your email address and password.'#13#13'%s'#13#13,
              [WebNotesName, BankLinkLiveName, Service.ReplyURL]);


          SaveUrl(Service.ReplyURL);

          Result := True;
          // Set a flag we did it atleast once
          UploadedToWebnotes;

          if aClient.clExtra.ceOnlineValuesStored then
          begin
            ProductConfigService.GetPractice;

            if ProductConfigService.Online then
            begin
              //Get client list (so that we can lookup the client code)
              ProductConfigService.LoadClientList;
              //Get client details
              ClientReadDetail := ProductConfigService.GetClientDetailsWithCode(aClient.clFields.clCode);

              try
                if Assigned(ClientReadDetail) then
                begin
                  SetLength(Subscription, aClient.clExtra.ceOnlineSubscriptionCount);
                  for SubIndex := 1 to aClient.clExtra.ceOnlineSubscriptionCount do
                    Subscription[SubIndex-1] := aClient.clExtra.ceOnlineSubscription[SubIndex];

                  Result := ProductConfigService.UpdateClient(ClientReadDetail,
                                                              aClient.clExtra.ceOnlineBillingFrequency,
                                                              aClient.clExtra.ceOnlineMaxOfflineDays,
                                                              TBloStatus(aClient.clExtra.ceOnlineStatus),
                                                              Subscription,
                                                              aClient.clExtra.ceOnlineUserEMail,
                                                              aClient.clExtra.ceOnlineUserFullName);
                end;
              finally
                FreeandNil(ClientReadDetail);
              end;
            end;
          end;
        end
        else
          raise Exception.Create('Wrong server response' );
      end;

    except
      on E:Exception do
      begin
        HandleWNException(e, UnitName,Format('Export to %s',[WebNotesName]), not IsScheduledReport);
        raise EWebNotesDataUploadError.Create( E.Message );
      end;
    end;
  finally
    WebClient.Free;
    if IsScheduledReport then
      Service.FinaliseSheduled(Result);
    Service.Free;
    ClearStatus;
  end;
end;

{ TWebNotesDataUpload }
//------------------------------------------------------------------------------
function TWebNotesDataUpload.AddAccount(Account: TBank_Account; var AccountsNode: IXMLNode): Boolean;
var
  ti : Integer;
  TransactionsNode,
  DissectionsNode,
  TransNode,
  DisstNode: IXMLNode;
  Trans: pTransaction_Rec;
  Disst: pDissection_Rec;
  LCount: Integer;
  NewSummaryRec: PSchdRepSummaryRec;

  //----------------------------------------
  function GetTransNode : IXMLNode;
  begin
    // Check we have a tranactions node first
    if TransactionsNode = nil then
    begin
      TransactionsNode := AccountsNode.AddChild(nAccount);
      TransactionsNode.Attributes[nName] :=  Account.baFields.baBank_Account_Name;
      TransactionsNode.Attributes[nNumber] :=  Account.baFields.baBank_Account_Number;
      TransactionsNode.Attributes[nCurrency] := Account.baFields.baCurrency_Code;
      TransactionsNode := TransactionsNode.AddChild(nTransactions);
    end;
    Result :=  TransactionsNode.AddChild(nTransaction);
  end;

begin

  if not(Assigned (AccountsNode)) then
    Exit;

  if Account.baTransaction_List.ItemCount <= 0 then
    Exit; // Nothing to send...

  // Reset Counters and date limits
  LCount := 0;

  TransactionsNode := nil;
  for ti := Account.baTransaction_List.First to Account.baTransaction_List.Last do
  begin
    Trans := Account.baTransaction_List.Transaction_At(ti);// Easier Debugging...

    (**********************************************************************)
    if IncludeTrans(Account,Trans) then
    begin
      //set  ID, this will be used to synchronise the transaction
      if Trans.txECoding_Transaction_UID = 0 then
      begin
        Inc(Account.baFields.baLast_ECoding_Transaction_UID);
        Trans.txECoding_Transaction_UID := Account.baFields.baLast_ECoding_Transaction_UID;
      end;
      // Got Something to do.. Make a XMLnode..
      TransNode := GetTransNode;

      // Do all the IDs first..
      TransNode.Attributes [nSequenceIndex] := Trans.txSequence_No;
      TransNode.Attributes [nExternalID] := Trans.txECoding_Transaction_UID;

      // Anny other Common Bits...
      SetSourceAttr(Transnode, nSource, Trans.txSource);
      SetMoneyAttr(TransNode, nAmount, Trans.txAmount);
      SetTextAttr(TransNode, nChartCode, Trans.txAccount);
      SetDateAttr(TransNode, nDateEffective, Trans.txDate_Effective);
      SetTextAttr(TransNode, nNarration, Trans.txGL_Narration);
      SetTextAttr(TransNode, nNotes, Trans.txNotes);
      SetTextAttr(TransNode, nReference, Trans.txReference);
      if Trans.txCheque_Number <> 0 then
        TransNode.Attributes [nChequeNumber] := Trans.txCheque_Number;
      SetCodeByAttr(TransNode,nCodedBy,Trans.txCoded_By);
      SetUPIState(TransNode,nUPIState,Trans.txUPI_State);

      // GST/ VAT
      SetMoneyAttr(TransNode, nTaxAmount, Trans.txGST_Amount);
      SetTextAttr(TransNode, nTaxCode, GetGSTClassCode(FClient,Trans.txGST_Class));
      SetBoolAttr(TransNode, nTaxEdited, Trans.txGST_Has_Been_Edited);
      if not FClient.clFields.clECoding_Dont_Show_TaxInvoice then
        SetBoolAttr(TransNode, nTaxInvoice, Trans.txTax_Invoice_Available );

      if not FClient.clFields.clECoding_Dont_Send_Payees then
        if Trans.txPayee_Number <> 0 then
          SetTextAttr(TransNode,nPayeeNumber,IntTostr(Trans.txPayee_Number));

      if (not fClient.clExtra.ceECoding_Dont_Send_Jobs) then
        SetTextAttr(TransNode, nJobCode, Trans.txJob_Code);

      if (not fClient.clFields.clECoding_Dont_Show_Quantity) then
        SetQtyAttr(TransNode, nQuantity, Trans.txQuantity);

      if FClient.clFields.clECoding_Send_Superfund and
        Software.CanUseSuperFundFields(FClient.clFields.clCountry,FClient.clFields.clAccounting_System_Used) then
      begin
        SetMoneyAttr(TransNode, nSFFranked, Trans.txSF_Franked);
        SetMoneyAttr(TransNode, nSFUnFranked, Trans.txSF_UnFranked);
        SetMoneyAttr(TransNode, nSFFrankingCredit, Trans.txSF_Imputed_Credit);
      end;

      //set code lock state
      SetBoolAttr(TransNode, nCodeLocked, ( Trans.txAccount <> '')
                  or ( Trans.txFirst_Dissection <> nil));

      //copy Dissections
      if Trans.txFirst_Dissection <> nil then
      begin
        Disst := Trans.txFirst_Dissection;
        // Make the Dissections node
        DissectionsNode := TransNode.AddChild(nDissections);
        while Disst <> nil do
        begin
          // Make the Dissection node
          DisstNode := DissectionsNode.AddChild(nDissection);

          // Common bits
          SetMoneyAttr(DisstNode, nAmount, Disst.dsAmount);
          SetTextAttr(DisstNode, nChartCode, Disst.dsAccount);
          SetTextAttr(DisstNode, nNarration, Disst.dsGL_Narration);
          SetTextAttr(DisstNode, nNotes, Disst.dsNotes);
          SetTextAttr(DisstNode, nReference, Disst.dsReference);

          // GST/ VAT
          SetMoneyAttr(DisstNode, nTaxAmount, Disst.dsGST_Amount);
          SetTextAttr(DisstNode, nTaxCode, GetGSTClassCode(FClient,Disst.dsGST_Class));
          SetBoolAttr(DisstNode, nTaxEdited, Disst.dsGST_Has_Been_Edited);
          if not FClient.clFields.clECoding_Dont_Show_TaxInvoice then
            SetBoolAttr(DisstNode, nTaxInvoice, Disst.dsTax_Invoice );

          // Job
          if not fClient.clExtra.ceECoding_Dont_Send_Jobs then
            SetTextAttr(DisstNode, nJobCode, Disst.dsJob_Code);

          // Quantity
          if not fClient.clFields.clECoding_Dont_Show_Quantity then
            SetQtyAttr(DisstNode,nQuantity, Disst.dsQuantity);

          // Superfund
          if FClient.clFields.clECoding_Send_Superfund and
            Software.CanUseSuperFundFields(FClient.clFields.clCountry,FClient.clFields.clAccounting_System_Used) then
          begin
            SetMoneyAttr(DisstNode, nSFFranked, Disst.dsSF_Franked);
            SetMoneyAttr(DisstNode, nSFUnFranked, Disst.dsSF_UnFranked);
            SetMoneyAttr(DisstNode, nSFFrankingCredit, Disst.dsSF_Imputed_Credit);
          end;

          // Next Dissection
          Disst := Disst.dsNext;
        end;//While Dissection
      end; // Do Dissections

      // Count the transactions...
      Inc(LCount);
    end;
  end;
  inc(EntriesCount,LCount);
  Result := (LCount > 0);

  (**********************************************************************)


  //now handle scheduled reports summary lines
  if Result and// Something to add
    IsScheduledReport and
    (SchdSummaryList <> nil) then
  begin
    Inc( AccountsExported);

    GetMem( NewSummaryRec, Sizeof( TSchdRepSummaryRec));
    with NewSummaryRec^ do
    begin
      ClientCode         := fClient.clFields.clCode;
      AccountNo          := Account.baFields.baBank_Account_Number;
      PrintedFrom        := accFirstEntryDate;
      PrintedTo          := accLastEntryDate;
      AcctsPrinted       := 0;
      AcctsFound         := 0;
      SendBy             := rdWebX;
      UserResponsible    := 0;
      Completed          := True;
      TxLastMonth        := (fClient.clFields.clReporting_Period = roSendEveryMonth)
                            and (AccFirstEntryDate < ReportStartDate)
                            and (not fClient.clFields.clCheckOut_Scheduled_Reports)
                            and (not fClient.clExtra.ceOnline_Scheduled_Reports);
    end;
    SchdSummaryList.Add( NewSummaryRec);
    //store a pointer to the first record so that we can update it with the
    //accounts printed and accounts found values.
    if FirstSummaryRec = nil then
    begin
      FirstSummaryRec := NewSummaryRec;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.AddChart(ChartNode: IXMLnode);
var
  I: Integer;
  EntryNode : IXMLnode;
begin
  if not(Assigned (ChartNode)) then
    Exit;

  SetTextAttr(ChartNode,nCodeMask, FClient.clFields.clAccount_Code_Mask);

  for I := FClient.clChart.First to FClient.clChart.Last do
    with FClient.clChart.Account_At(I)^ do
    begin
      // add The Node...
      EntryNode := ChartNode.AddChild(nChartEntry);

      // Add The details..
      SetTextAttr(EntryNode, nCode, chAccount_Code);
      SetTextAttr(EntryNode, nDescription, chAccount_Description);
      SetBoolAttr(EntryNode, nPosting, chPosting_Allowed);
      SetBoolAttr(EntryNode, nBasic, not chHide_In_Basic_Chart);

      SetTextAttr(EntryNode, nTaxCode, GetGSTClassCode(FCLient,chGST_Class));
      //SetRateAttr(EntryNode, nTaxRate, GetGSTClassPercent(FClient,DateTo,chGST_Class));
    end;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.AddClient(BatchNode: IXMLNode);
var
  lNode,
  TaxesNode: IXMLNode;
  acNo: Integer;
  ba: TBank_Account;

  //------------------------------------------------
  function NewTaxRateNode: IXMLNode;
  begin
    if TaxesNode = nil then
      TaxesNode :=  BatchNode.AddChild(nTaxrates);
    Result := TaxesNode.AddChild(nTaxRate);
  end;

  //------------------------------------------------
  procedure LAddCompanyTaxRates;
  var
    I, J: Integer;
    TaxNode: IXMLNode;
  begin
    TaxNode := nil;
    for I := low(FClient.clExtra.ceTAX_Rates) to High(FClient.clExtra.ceTAX_Rates) do
      for J := 1 to 5 do
        if FClient.clExtra.ceTAX_Rates[I,J] <> 0 then
        begin
          TaxNode := NewTaxRateNode;
          SetTextAttr(TaxNode, nCode, nCompanyTax);
          SetRateAttr(TaxNode, nRate, FClient.clExtra.ceTAX_Rates[I,J]);
          SetDateAttr(TaxNode, nAppliesFrom, FClient.clExtra.ceTAX_Applies_From [I,J] );
        end;
  end;

  //------------------------------------------------
  procedure LAddGSTTaxRates;  //GST or VAT
  var
    I, J: Integer;
    TaxNode: IXMLNode;
  begin
    TaxNode := nil;
    for I := low(FClient.clFields.clGST_Class_Codes) to High(FClient.clFields.clGST_Class_Codes) do
      if (FClient.clFields.clGST_Class_Codes[I] > '') then
      begin
        // Do at least the first rate..
        TaxNode := NewTaxRateNode;
        SetTextAttr(TaxNode, nCode, FClient.clFields.clGST_Class_Codes[I]);
        SetRateAttr(TaxNode, nRate, FClient.clFields.clGST_Rates[I,1]);
        SetDateAttr(TaxNode, nAppliesFrom, FClient.clFields.clGST_Applies_From[1]);
        for J := 2 to 5 do
          if (FClient.clFields.clGST_Rates [I,J] <> 0) or
            (FClient.clFields.clGST_Applies_From[J] <> 0) then
          begin
            // Add any more if required
            TaxNode := NewTaxRateNode;
            SetTextAttr(TaxNode, nCode, FClient.clFields.clGST_Class_Codes[I]);
            SetRateAttr(TaxNode, nRate, FClient.clFields.clGST_Rates[I,J]);
            SetDateAttr(TaxNode, nAppliesFrom, FClient.clFields.clGST_Applies_From[J]);
          end;
      end;
  end;

  //------------------------------------------------
  procedure AddCompany(ANode: IXMLNode);
  var
    lClientRec: pClient_File_Rec;
    lNode: IXMLNode;

    //------------------------------------------------
    procedure AddPracticeContact(Name, Email: string);
    begin
      lNode := ANode.AddChild(nPracticeContact);
      SetTextAttr(lNode, nName,  Name);
      SetTextAttr(lNode, nEmail, Email);
    end;

  begin
    SetTextAttr(ANode, nCode, FClient.clFields.clCode);
    SetTextAttr(ANode, nName, FClient.clFields.clName);
    SetTextAttr(ANode, nCountry,CountryText(FClient.clFields.clCountry));

    // Company Contact
    lNode := ANode.AddChild(nContact);
      SetTextAttr(lNode,nName,FClient.clFields.clContact_Name);
      SetTextAttr(lNode,nEmail,FClient.clFields.clClient_EMail_Address);

    lClientRec := AdminSystem.fdSystem_Client_File_List.FindCode(FClient.clFields.clCode);
    if Assigned(lClientRec) then
    begin
      SetBoolAttr(ANode,'PracticeNotification', (lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyMe) = 0 );
      // While we are here...
      NotifyClient := (lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyClient) = 0;

      if (lClientRec.cfWebNotes_Email_Notifications and wnDontNotifyMe) = 0 then
        case fClient.clFields.clContact_Details_To_Show of  // Send details on how to notify
          cdtPractice: AddPracticeContact('', FClient.clFields.clPractice_EMail_Address);

          cdtStaffMember: if (AdminSystem.fdFields.fdMagic_Number = FClient.clFields.clMagic_Number) then
                            AddPracticeContact(FClient.clFields.clStaff_Member_Name, FClient.clFields.clStaff_Member_EMail_Address)
                          else
                            AddPracticeContact('', AdminSystem.fdFields.fdPractice_EMail_Address );

          cdtCustom: AddPracticeContact(FClient.clFields.clCustom_Contact_Name, FClient.clFields.clCustom_Contact_EMail_Address);

        end;

    end;
  end; //AddCompany

begin // AddClient

  if not(Assigned (BatchNode)) then
    Exit;

  TaxesNode := nil;
  //Company Node..
  AddCompany(BatchNode.AddChild(nCompany));


  //Configuration Node..
  lNode := BatchNode.AddChild(nConfiguration);

  lNode := LNode.AddChild(nOptions);

  AddBooleanOption(lNode,nShowQuantity,    not FClient.clFields.clECoding_Dont_Show_Quantity);
  AddBooleanOption(lNode,nShowTax,         not FClient.clFields.clECoding_Dont_Show_GST);
  AddBooleanOption(lNode,nShowTaxInvoice,  not FClient.clFields.clECoding_Dont_Show_TaxInvoice);
  AddBooleanOption(lNode,nShowAccount,     not FClient.clFields.clECoding_Dont_Show_Account);
  AddBooleanOption(lNode,nRestrictUPI,     FClient.clFields.clECoding_Dont_Allow_UPIs);
  AddBooleanOption(lNode,nShowJob,         not FClient.clExtra.ceECoding_Dont_Send_Jobs);
  AddBooleanOption(lNode,nShowPayee,       not FClient.clFields.clECoding_Dont_Send_Payees);

  AddBooleanOption(lNode,nShowSuperfund,
    FClient.clFields.clECoding_Send_Superfund
    and Software.CanUseSuperFundFields(FClient.clFields.clCountry,FClient.clFields.clAccounting_System_Used));

  // are we going to need Tax Rates // Not just GST
  if FClient.clFields.clECoding_Send_Superfund and
    Software.CanUseSuperFundFields(FClient.clFields.clCountry,FClient.clFields.clAccounting_System_Used) then
  begin
    LAddCompanyTaxRates;
  end;

  LAddGSTTaxRates;

  // Chart...
  if (not FClient.clFields.clECoding_Dont_Send_Chart) and
    (FClient.clChart.ItemCount > 0) then
  begin
    AddChart(BatchNode.AddChild(nChart))
  end;

  // Payees
  if (not FClient.clFields.clECoding_Dont_Send_Payees) and
    (FClient.clPayee_List.ItemCount > 0) then
  begin
    AddPayees(BatchNode.AddChild(nPayees));
  end;

  // Jobs
  if (not FClient.clExtra.ceECoding_Dont_Send_Jobs) and
    (FClient.clJobs.ItemCount > 0) then
  begin
    AddJobs(BatchNode.AddChild(nJobs))
  end;

  // add The accounts...
  lnode := BatchNode.AddChild(nAccounts);
  for acNo := 0 to Pred(FClient.clBank_Account_List.ItemCount) do
  begin
    BA := FClient.clBank_Account_List.Bank_Account_At(acNo);

    //autocode all entries before exporting so that code/uncode set correctly
    AutoCode32.AutoCodeEntries( FClient, ba, AllEntries, DateFrom, DateTo);

    if IncludeAccount(BA) then
    begin
      if AddAccount(Ba,LNode) then ;
          //ReportAccount(Ba)
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.AddJobs(JobsNode: IXMLNode);
var
  I: Integer;
  JobNode : IXMLNode;
begin
  if not(Assigned (JobsNode)) then
    Exit;

  for I := FClient.clJobs.First to FClient.clJobs.last do
    with FClient.clJobs.Job_At(I)^ do
    begin
      JobNode := JobsNode.AddChild(nJob);

      SetTextAttr(JobNode, nCode, jhCode);
      if jhHeading <> '' then
        SetTextAttr(JobNode, nName, jhHeading)
      else
        SetTextAttr(JobNode, nName, jhCode);

      SetTextAttr(JobNode, nName, jhHeading);
      SetBoolAttr(JobNode, nAdded, False);
      SetBoolAttr(JobNode, nCompleted, jhDate_Completed <> 0);
    end;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.AddPayees(PayeesNode: IXMLNode);
var
  I, L: Integer;
  PayeeNode, PayeeLine : IXMLNode;
begin
  if not(Assigned (PayeesNode)) then
    Exit;

  for I := FClient.clPayee_List.First to FClient.clPayee_List.Last do
    with FClient.clPayee_List.Payee_At(I) do
    begin
      PayeeNode := PayeesNode.AddChild(nPayee);
      SetTextAttr(PayeeNode, nNumber, IntToStr(pdNumber));
      SetTextAttr(PayeeNode, nName, pdName);

      // add The line items...
      for L := pdLines.First to pdLines.Last do
        with pdLines.PayeeLine_At(L)^ do
        begin
          PayeeLine := PayeeNode.AddChild(nPayeeLine);

          SetTextAttr(PayeeLine, nIndex,IntToStr(L {+1??}));
          SetTextAttr(PayeeLine, nChartCode, plAccount);

          if plLine_Type = BKCONST.pltDollarAmt then
          begin
            SetTextAttr(PayeeLine, nValueType, nAmount);
            SetMoneyAttr(PayeeLine, nValue, plPercentage);
          end
          else
          begin
            SetTextAttr(PayeeLine, nValueType, nPercentage);
            SetRateAttr(PayeeLine, nValue, plPercentage);
          end;
          SetTextAttr(PayeeLine, nTaxCode,GetGSTClassCode(FClient, plGST_Class));
          SetRateAttr(PayeeLine, nTaxRate,GetGSTClassPercent(FClient,DateTo, plGST_Class));
          SetBoolAttr(PayeeLine, nTaxEdited, plGST_Has_Been_Edited);
          SetTextAttr(PayeeLine, nNarration, plGL_Narration);
        end;
    end;
end;

//------------------------------------------------------------------------------
constructor TWebNotesDataUpload.Create;
begin
  inherited Create;
  Reset;
end;

//------------------------------------------------------------------------------
destructor TWebNotesDataUpload.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.FinaliseSheduled(Success: Boolean);
var
  I: Integer;
begin
  if SchdSummaryList = nil then
    Exit;

  if Assigned(FirstSummaryRec) then
  begin
    FirstSummaryRec.AcctsFound := AccountsFound;
    if Success then
    begin
      FirstSummaryRec.AcctsPrinted := AccountsExported;
      FirstSummaryRec.Completed := True;
    end;
  end;

  // Find any of the others..
  for I := 0 to SchdSummaryList.Count - 1 do
  begin
    with PSchdRepSummaryRec(SchdSummaryList.Items[I])^ do if
      ClientCode = FClient.clFields.clCode then
        Completed := Success;
  end;
end;

//------------------------------------------------------------------------------
function TWebNotesDataUpload.GetBatchXML: string;
var
  lNode,
  LBatch: IXMLNode;
  lXMLDoc: IXMLDocument;
begin
  //setup XML Document
  lXMLDoc := XMLDoc.NewXMLDocument;
  lXMLDoc.Active := true;
  lXMLDoc.Options := [doNodeAutoIndent];
  lXMLDoc.version:= CreateBatchRequestVersion;
  lXMLDoc.encoding:= 'UTF-8'; // Have no choice for now, its not a WideString

  // Build the notes
  lNode := lXMLDoc.CreateNode(nUploadBatchRequest);

  LNode.Attributes[nVersion] := CreateBatchRequestVersion;
  LNode.DeclareNamespace('',CreateBatchRequestNameSpace);

  lXMLDoc.DocumentElement := lNode;

  lNode := lNode.AddChild(nItems,CreateBatchRequestNameSpace);

  lBatch := lNode.AddChild(nBatch);
  // Add the dates ..
  SetDateAttr(LBatch,nFromdate,DateFrom);
  SetDateAttr(LBatch,nEndDate,DateTo);

  // Add the current user
  lNode := LBatch.AddChild(nPRacticeContact);
  if CurrUser.FullName > '' then
    SetTextAttr(lNode,nName,CurrUser.FullName)
  else
    SetTextAttr(lNode,nName,CurrUser.Code);

  // Add the Client details..
  AddClient(lBatch);

  // Return the XML String...
  Result := lXMLDoc.XML.Text;
  { Debug Only
  lXMLDoc.SaveToFile('c:\bk5\send.xml');
  {}
  lXMLDoc := nil;
end;

//------------------------------------------------------------------------------
function TWebNotesDataUpload.IncludeAccount(var Account: TBank_Account): Boolean;
var
  CompareBA: TBank_Account;
  i: Integer;
  AdminBA : pSystem_Bank_Account_Rec;
  Lastdate: TStdate;
begin
  Result := False; // Asume

  if not (Account.baFields.baAccount_Type in [btBank]) then
    Exit;

  AccFirstEntryDate := MaxInt;
  AccLastEntryDate  := 0;
  if IsScheduledReport then
  begin
    //if scheduled reports then determine if acccount can be found in admin system
    //accounts found depends on no of admin accounts found
    Account.baFields.baTemp_Include_In_Scheduled_Coding_Report := false;
    Account.baFields.baTemp_New_Date_Last_Trx_Printed := 0;  //this value will be written in admin sytem
                                                             //see Scheduled.ProcessClient()
    //access the admin system and read date_of_last_transaction_printed.
    AdminBA := AdminSystem.fdSystem_Bank_Account_List.FindCode( Account.baFields.baBank_Account_Number);
    if Assigned(AdminBA) then
    begin
      Inc(AccountsFound);
      // Dont skip until we've included this account in the total
      if Pos(Account.baFields.baBank_Account_Number + ',', fClient.clFields.clExclude_From_Scheduled_Reports) > 0 then
        Exit;

      if ScheduledReportPrintAll then
        //set date so that all transactions will be included
        Account.baFields.baTemp_Date_Of_Last_Trx_Printed := 0
      else
      begin
        LastDate := ClientUtils.GetLastPrintedDate(fClient.clFields.clCode, AdminBA.sbLRN);
        if LastDate = 0 then
          Account.baFields.baTemp_Date_Of_Last_Trx_Printed := IncDate(ReportStartDate, -1, 0, 0)
        else if GetMonthsBetween(LastDate, ReportStartDate) > 1 then
          Account.baFields.baTemp_Date_Of_Last_Trx_Printed := GetFirstDayOfMonth(IncDate(ReportStartDate, 0, -1, 0))
        else
          Account.baFields.baTemp_Date_Of_Last_Trx_Printed := LastDate;
      end;
    end
    else
    begin
       //this account does not exist in the admin sytem, set date so that
       //no valid entries will ever be found
       Account.baFields.baTemp_Date_Of_Last_Trx_Printed := MaxInt;
    end;

    // Still here...
    Result := True // In By default..

  end
  else
  begin
    // Manual, Check the given list, to see if it is there..
    for i := 0 to Pred(AccountList.Count) do
    begin
      CompareBA := FClient.clBank_Account_List.Bank_Account_At(Integer(AccountList[i]));
      if (CompareBA.baFields.baBank_Account_Number = Account.baFields.baBank_Account_Number) then begin
        // Yeap, it's in the list...
        Result := True;
        Break;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TWebNotesDataUpload.IncludeTrans(var Account: TBank_Account; Trans: pTransaction_Rec): boolean;
begin
  Result := false;
  if not Assigned(Trans) then
    Exit; //Savety net

  if (Trans.txDate_Effective < DateFrom) then
    Exit;

  if (Trans.txDate_Effective > DateTo) then
    Exit;


  if (Client.clFields.clECoding_Entry_Selection = esUncodedOnly) and
     (Trans.txAccount > '') then
    Exit;

  //check date of last transaction sent if scheduled reports run
  if IsScheduledReport then
  begin
    if (Trans.txDate_Effective > Account.baFields.baTemp_Date_Of_Last_Trx_Printed) and // In the Range
      (not IsUPCFromPreviousMonth(Trans.txDate_Effective, Trans.txUPI_State, ReportStartDate)) or
      (ScheduledReportPrintAll) then
    begin
      // Keep Min and Max Date for the current account
      AccFirstEntryDate := Min(AccFirstEntryDate, Trans.txDate_Effective);
      AccLastEntryDate  := Max(AccLastEntryDate,  Trans.txDate_Effective);

      Account.baFields.baTemp_New_Date_Last_Trx_Printed := AccLastEntryDate;

      Account.baFields.baTemp_Include_In_Scheduled_Coding_Report := true; // One should be enough
    end
    else
       Exit;
  end;

  // Still Here...
  Result := True;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.Reset;
begin
  AccountsFound := 0;
  AccountsExported := 0;
  FirstSummaryRec := nil;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetClient(const Value: TClientObj);
begin
  FClient := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetDateFrom(const Value: Integer);
begin
  FDateFrom := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetDateTo(const Value: Integer);
begin
  FDateTo := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetIsScheduledReport(const Value: boolean);
begin
  FIsScheduledReport := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetNotifyClient(const Value: Boolean);
begin
  FNotifyClient := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetReplyURL(const Value: string);
begin
  FReplyURL := Value;
end;

//------------------------------------------------------------------------------
procedure TWebNotesDataUpload.SetScheduledReportPrintAll(const Value: boolean);
begin
  FScheduledReportPrintAll := Value;
end;

//------------------------------------------------------------------------------
function TWebNotesDataUpload.TestReply(Reply: string): Boolean;
var
  lNode,ReplyNode: IXMLNode;
  lXMLDoc : IXMLDocument;
begin
  //Fail by default;
  Result := False;

  if DebugMe then
    LogUtil.LogMsg(lmDebug,UnitName,format('Upload reply <%s>',[Reply] ));

  lXMLDoc := MakeXMLDoc(Reply);
  try

    ReplyNode := lXMLDoc.DocumentElement;

    if TestResponse(ReplyNode,'ResponseType') then
    begin
      LNode := ReplyNode.ChildNodes.FindNode('ClientURL');
      if Assigned(lNode) then
        ReplyURL  := LNode.NodeValue;
    end
    else
       Exit;

    // Still here... Must be OK
    Result := True;
  finally
    lXMLDoc := nil;
  end;
end;

//------------------------------------------------------------------------------
initialization
  DebugMe := DebugUnit(UnitName);
end.



