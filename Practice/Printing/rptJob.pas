unit RptJob;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Job Reports
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface
uses
   ReportDefs,UBatchBase;

procedure DoJobSpendingReport(Destination : TReportDest; RptBatch :TReportBase = nil);

//******************************************************************************
implementation

uses
  ReportTypes,
  Classes,
  SysUtils,
  NewReportObj,
  RepCols,
  Globals,
  bkDefs,
  baObj32,
  GenUtils,
  NewReportUtils,
  bkDateUtils,
  JobRepDlg, MoneyDef,
  RptParams,
  JobObj, clObj32, balist32, trxList32, bkbaio, bktxio, bkdsio, stdate, bkconst;

type
   TJobSpendingReport = class(TBKReport)
  private
    procedure AddSummerisedJob(Job: pJob_Heading_Rec);
    procedure AddDetailedJob(Job: pJob_Heading_Rec);
    procedure CopyTransactions(Transaction_List: TTransaction_List);
    procedure AddTransactionAndDissection(Job: pJob_Heading_Rec;
      Account: pAccount_Rec; Transaction: pTransaction_Rec;
      var AccountGross, AccountGST: Money; var AccountNameRendered,
      JobNameRendered: Boolean);
    procedure AddTransaction(Job: pJob_Heading_Rec; Account: pAccount_Rec;
      Transaction: pTransaction_Rec; IncludeJobName, IncludeAccountName,
      IncludeNarration: Boolean);
    procedure PutJobNarration(Notes: string);
    procedure AddAccountHeading(Account: pAccount_Rec);
    procedure AddJobHeading(Job: pJob_Heading_Rec);
    function IsTransactionIncluded(ReportJob: pJob_Heading_Rec;
      ReportAccount: pAccount_Rec; txJobCode, txAccountCode: string): boolean;
    function IsDissectionIncluded(ReportJob: pJob_Heading_Rec;
      ReportAccount: pAccount_Rec; txJobCode: string; txAccountCode: string;
      dsJobCode: string; dsAccountCode: string): boolean;
   public
     Params : TJobParameters;
     function ShowJobOnReport(JobCode : string): boolean;
   end;


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TJobSpendingReport.PutJobNarration(Notes: string);
var
  j, ColWidth, OldWidth : Integer;
  ColsToSkip : integer;
  NotesList  : TStringList;
  MaxNotesLines: Integer;
begin
  if Params.WrapNarration then
     MaxNotesLines := 10
  else
     MaxNotesLines := 1;
  if (Notes = '') then
     SkipColumn
  else
  begin
    NotesList := TStringList.Create;
    try
      NotesList.Text := Notes;
      // Remove blank lines
      j := 0;
      while j < NotesList.Count do
      begin
        if NotesList[j] = '' then
          NoteSList.Delete(j)
        else
          Inc(j);
      end;
      if NotesList.Count = 0 then
      begin
        SkipColumn;
        Exit;
      end;
      ColsToSkip := CurrDetail.Count;
      j := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[ j]);
        if (ColWidth < Length(NotesList[j])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (NotesList[j][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          NotesList.Insert(j + 1, Copy(NotesList[j], ColWidth + 1, Length(NotesList[j]) - ColWidth + 1));
          NotesList[j] := Copy(NotesList[j], 1, ColWidth);
        end;
        PutString( NotesList[ j]);
        Inc(j);
        //decide if need to call renderDetailLine
        if ( j < notesList.Count)
        and ( j < MaxNotesLines) then
        begin

          // Skip till the end of the report..
          while CurrDetail.Count < Columns.ItemCount do
             SkipColumn;

          RenderDetailLine(False);
          // Go back to the column we where in
          for ColWidth := 1 to ColsToSkip do
            SkipColumn;
        end;
      until ( j >= NotesList.Count) or ( j >= MaxNotesLines);
    finally
       NotesList.Free;
    end;
  end;
end;

procedure TJobSpendingReport.CopyTransactions(Transaction_List: TTransaction_List);
var
  Client: TClientObj;
  BankAccountIndex: Integer;
  BankAccount: TBank_Account;
  TransactionIndex: Integer;
  OldTransaction: pTransaction_Rec;
  NewTransaction: pTransaction_Rec;
  OldDissection: pDissection_Rec;
  NewDissection: pDissection_Rec;
  DissectionJobCode: string;
begin
  Client := params.Client;
  //Copy transactions to a new list
  //(will be sorted by date regardless of bank account)
  for BankAccountIndex := 0 to Pred(Client.clBank_Account_List.itemCount) do
  begin
    BankAccount := Client.clBank_Account_List.Bank_Account_At(BankAccountIndex);
    for TransactionIndex := 0 to Pred(BankAccount.baTransaction_List.itemCount) do
    begin
      OldTransaction := BankAccount.baTransaction_List.Transaction_At(TransactionIndex);
      if (OldTransaction^.txDate_Effective >= Params.Fromdate) and (OldTransaction^.txDate_Effective <= Params.Todate) then
      begin
        NewTransaction := BankAccount.baTransaction_List.New_Transaction;
        //with OldTransaction^ do
        //begin
        NewTransaction.txType := OldTransaction.txType;
        NewTransaction.txDate_Presented := OldTransaction.txDate_Presented;
        NewTransaction.txDate_Effective := OldTransaction.txDate_Effective;
        NewTransaction.txAmount := OldTransaction.txAmount;
        NewTransaction.txGST_Amount := OldTransaction.txGST_Amount;
        NewTransaction.txReference := OldTransaction.txReference;
        NewTransaction.txAccount := OldTransaction.txAccount;
        NewTransaction.txJob_Code := OldTransaction.txJob_Code;
        NewTransaction.txGL_Narration := OldTransaction.txGL_Narration;
        NewTransaction.txUPI_State := OldTransaction.txUPI_State;
        //copy dissections
        OldDissection := OldTransaction.txFirst_Dissection;
        if Assigned(OldDissection) then
        begin
          if NewTransaction.txJob_Code = '' then
            DissectionJobCode := OldDissection.dsJob_Code
          else
            DissectionJobCode := '';
          while Assigned(OldDissection) do
          begin
            if DissectionJobCode <> '' then
              if SameText(DissectionJobCode, OldDissection.dsJob_Code) then
                DissectionJobCode := '';
            NewDissection := bkdsio.New_Dissection_Rec;
            NewDissection.dsAccount := OldDissection.dsAccount;
            NewDissection.dsReference := OldDissection.dsReference;
            NewDissection.dsAmount := OldDissection.dsAmount;
            NewDissection.dsGST_Amount := OldDissection.dsGST_Amount;
            NewDissection.dsJob_Code := OldDissection.dsJob_Code;
            NewDissection.dsGL_Narration := OldDissection.dsGL_Narration;
            NewDissection.dsAccount := OldDissection.dsAccount;
            trxlist32.AppendDissection(NewTransaction, NewDissection);
            OldDissection := OldDissection.dsNext;
          end;
          if DissectionJobCode <> '' then
            NewTransaction.txJob_Code := DissectionJobCode;
        end;
        //end;
        Transaction_List.Insert_Transaction_Rec(NewTransaction);
      end;
    end;
  end;
end;

procedure TJobSpendingReport.AddAccountHeading(Account: pAccount_Rec);
begin
  if Assigned(Account) then
    RenderTextLine(Format('%s - %s',[Account.chAccount_Code, Account.chAccount_Description]), True)
  else
    RenderTextLine('Uncoded', True);
end;

procedure TJobSpendingReport.AddJobHeading(Job: pJob_Heading_Rec);
begin
  if Assigned(Job) then
    RenderTitleLine(Format('%s (%s)',[Job.jhHeading, Job.jhCode]))
  else
    RenderTitleLine('No Job Allocated');
end;

procedure TJobSpendingReport.AddTransaction(Job: pJob_Heading_Rec;
  Account: pAccount_Rec; Transaction: pTransaction_Rec; IncludeJobName: Boolean;
  IncludeAccountName: Boolean; IncludeNarration: Boolean);
begin
  if IncludeJobName then
    AddJobHeading(Job);

  if IncludeAccountName then
    AddAccountHeading(Account);

  PutString(bkDate2Str(Transaction.txDate_Effective));
  PutString(GetFormattedReference( Transaction));
  if IncludeNarration then
    PutJobNarration(Transaction.txGL_Narration)
  else
    SkipColumn;

  if Params.ShowGrossGST then begin
     PutMoney(Transaction.txAmount);
     PutMoney(Transaction.txGST_Amount);
  end;
  PutMoney(Transaction.txAmount- Transaction.txGST_Amount);


  RenderDetailLine;
end;

function TJobSpendingReport.IsTransactionIncluded(ReportJob: pJob_Heading_Rec;
  ReportAccount: pAccount_Rec; txJobCode: string; txAccountCode: string): boolean;
var
  JobMatches: Boolean;
  AccountMatches: Boolean;
begin
  JobMatches := (Assigned(ReportJob) and SameText(txJobCode, ReportJob.jhCode))
    or (not Assigned(ReportJob) and (txJobCode = ''));
  AccountMatches :=  (Assigned(ReportAccount) and SameText(txAccountCode, ReportAccount.chAccount_Code))
    or (not Assigned(ReportAccount) and (txAccountCode = ''));
  Result := JobMatches and AccountMatches;
end;

function TJobSpendingReport.IsDissectionIncluded(ReportJob: pJob_Heading_Rec;
  ReportAccount: pAccount_Rec; txJobCode: string; txAccountCode: string;
  dsJobCode: string; dsAccountCode: string): boolean;
var
  txJobMatches: Boolean;
  //dsJobMatches: Boolean;
  txAccountMatches: Boolean;
  dsAccountMatches: Boolean;
begin
  {A dissection is include if either the parent transaction or the dissection is
  of the right job, AND the parent transaction or the dissection is coded to the
  right account }
  if Assigned(ReportJob) then begin
     // Must match ..
     if txJobCode > '' then
        txJobMatches := SameText(txJobCode, ReportJob.jhCode)
     else
        txJobMatches := SameText(dsJobCode, ReportJob.jhCode)
  end else begin
     // Must be Blank
     txJobMatches := not ((txJobCode > '') or (dsJobCode > ''));
  end;


  txAccountMatches :=  (Assigned(ReportAccount) and SameText(txAccountCode, ReportAccount.chAccount_Code))
                   or (not Assigned(ReportAccount) and (txAccountCode = ''));
  dsAccountMatches :=  (Assigned(ReportAccount) and SameText(dsAccountCode, ReportAccount.chAccount_Code))
                   or (not Assigned(ReportAccount) and (dsAccountCode = ''));
  Result := (txJobMatches)
         and (txAccountMatches or dsAccountMatches);
  //Check that account code is not assigned for Uncoded (TFS 4396)
  if Result and (not Assigned(ReportAccount)) then
    Result := (dsAccountCode = '');
end;

procedure TJobSpendingReport.AddTransactionAndDissection(Job: pJob_Heading_Rec;
  Account: pAccount_Rec; Transaction: pTransaction_Rec;
  var AccountGross, AccountGST: Money; var AccountNameRendered: Boolean; var JobNameRendered: Boolean);
var
  Ref: string;
  IncludeAllDissectionLines: Boolean;
  Dissection: pDissection_Rec;
begin
  //only show transaction that match this account account
  //see if transaction is dissected
  Dissection := Transaction.txFirst_Dissection;
  if Assigned(Dissection) then
  begin
    IncludeAllDissectionLines := IsTransactionIncluded(Job, Account, Transaction.txJob_Code, Transaction.txAccount);

    //Check that dissection account = transaction account TFS 4396
    if IncludeAllDissectionLines and (not Assigned(Account)) then
      IncludeAllDissectionLines := (Dissection^.dsAccount =  Transaction.txAccount);

    //show main transaction if all lines are coded to job
    if IncludeAllDissectionLines then
    begin
      AddTransaction(Job, Account, Transaction, not JobNameRendered,
        not AccountNameRendered, False);
      JobNameRendered := True;
      AccountNameRendered := True;
      AccountGross := AccountGross + Transaction.txAmount;
      AccountGST := AccountGST + Transaction.txGST_Amount;
    end;
    while Assigned(Dissection) do
    begin
      if IncludeAllDissectionLines or
        IsDissectionIncluded(Job, Account, Transaction.txJob_Code, Transaction.txAccount,
          Dissection.dsJob_Code, Dissection.dsAccount) then
      begin
        if not JobNameRendered then
        begin
          AddJobHeading(Job);
          JobNameRendered := True;
        end;

        if not AccountNameRendered then
        begin
          AddAccountHeading(Account);
          AccountNameRendered := True;
        end;

        PutString(bkDate2Str(Transaction.txDate_Effective));
        if Dissection.dsReference > '' then
          Ref := Dissection^.dsReference
        else
          Ref := '/' + IntToStr(Dissection.dsSequence_No);
        PutString(REF);
        PutJobNarration(Dissection.dsGL_Narration);

        if IncludeAllDissectionLines then begin
          //amount will have been added above
          if Params.ShowGrossGST then begin
             PutMoneyDontAdd(Dissection.dsAmount);
             PutMoneyDontAdd(Dissection.dsGST_Amount);
          end;
          PutMoneyDontAdd(Dissection.dsAmount - Dissection.dsGST_Amount);

        end else begin
           if Params.ShowGrossGST then begin
             PutMoney(Dissection.dsAmount);
             PutMoney(Dissection.dsGST_Amount);
           end;
           PutMoney(Dissection.dsAmount- Dissection.dsGST_Amount);
           AccountGross := AccountGross + Dissection.dsAmount;
           AccountGST := AccountGST + Dissection.dsGST_Amount;
        end;


        RenderDetailLine;
      end;
      Dissection := Dissection.dsNext;
    end;
  end
  else
  begin
    //transaction is not dissected, see if assigned to this Job
    if IsTransactionIncluded(Job, Account, Transaction.txJob_Code, Transaction.txAccount) then
    begin
      AddTransaction(Job, Account, Transaction, not JobNameRendered,
        not AccountNameRendered, True);
      JobNameRendered := True;
      AccountNameRendered := True;
      AccountGross := AccountGross + Transaction.txAmount;
      AccountGST := AccountGST + Transaction.txGST_Amount;
    end;
  end;
end;

procedure TJobSpendingReport.AddSummerisedJob(Job: pJob_Heading_Rec);
var
  JobNameRendered: Boolean;
  Client: TClientObj;
  BankAccIndex: Integer;
  TransactionIndex: Integer;
  Transaction: pTransaction_Rec;
  BankAccount: TBank_Account;
  Account: pAccount_Rec;
  Dissection: pDissection_Rec;
  AccountGross, JobGross: Money;
  AccountGST, JobGST: Money;
  AccountIndex: Integer;
begin
  //For summerised reports, group by Job and have a line for each account
  JobNameRendered := False;
  Client := Params.Client;
  JobGross := 0;
  JobGST := 0;
  //Group by Accounts. Go one over the end, since we need to show uncoded transactions
  for AccountIndex := 0 to Client.clChart.ItemCount do
  begin
    if AccountIndex < Client.clChart.ItemCount then
      Account := Client.clChart.Account_At(AccountIndex)
    else
      Account := nil;
    AccountGross := 0;
    AccountGST := 0;

    for BankAccIndex := Client.clBank_Account_List.First to Client.clBank_Account_List.Last do
    begin
      BankAccount := Client.clBank_Account_List.Bank_Account_At(BankAccIndex);
      for TransactionIndex := 0 to BankAccount.baTransaction_List.itemCount - 1 do
      begin
        Transaction := BankAccount.baTransaction_List.Transaction_At(TransactionIndex);
        if ( Transaction^.txDate_Effective >= Params.Fromdate ) and (Transaction^.txDate_Effective <= Params.Todate ) then
        begin
          if IsTransactionIncluded(Job, Account, Transaction.txJob_Code, Transaction.txAccount) then
          begin
            //Either is dissected with entire transaction coded to this job and account, or not dissected.
            AccountGross := AccountGross + Transaction.txAmount;
            AccountGST := AccountGST + Transaction.txGST_Amount;
          end
          else
          begin
            //It's still possible that we should include some dissections
            Dissection := Transaction.txFirst_Dissection;
            while Assigned(Dissection) do
            begin
              if IsDissectionIncluded(Job, Account, Transaction.txJob_Code,
                Transaction.txAccount, Dissection.dsJob_Code, Dissection.dsAccount) then begin
                   AccountGross := AccountGross + Dissection.dsAmount;
                   AccountGST := AccountGST + Dissection.dsGST_Amount;
                end;
              Dissection := Dissection.dsNext;
            end;
          end;
        end;
      end; //for Transactions
    end; //for Bank Accounts

    if (AccountGross <> 0)
    or (AccountGST <> 0)then
    begin
      if not JobNameRendered then
      begin
        AddJobHeading(Job);
        JobNameRendered := True;
      end;
      if Assigned(Account) then
      begin
        PutString(Account.chAccount_Code);
        PutString(Account.chAccount_Description);
      end
      else
      begin
        PutString('-');
        PutString('Uncoded');
      end;

      if Params.ShowGrossGST then begin
         PutMoney(AccountGross);
         PutMoney(AccountGST);
      end;
      PutMoney(AccountGross - AccountGST);

      RenderDetailLine;
      JobGross := JobGross + AccountGross;
      JobGST := JobGST + AccountGST;
    end;
  end; //End for accounts

  if JobNameRendered then
  begin
    //Add SubTotal
    RenderDetailSubTotal('Total');
  end;
end;


procedure TJobSpendingReport.AddDetailedJob(Job: pJob_Heading_Rec);
var
  Client: TClientObj;
  JobNameRendered: Boolean;
  TransactionIndex: LongInt;
  Transaction_List: TTransaction_List;
  Transaction: pTransaction_Rec;
  AccountIndex: Integer;
  AccountNameRendered: Boolean;
  Account: pAccount_Rec;
  AccountGross: Money;
  AccountGST: Money;
begin
  JobNameRendered := False;
  Client := Params.Client;

  Transaction_List := TTransaction_List.Create( NIL, NIL );
  try
    //Copy the transactions for the reporting client into a new list,
    //include only transaction inside the reporting dates.
    CopyTransactions(Transaction_List);

    //Group by Accounts. Go one over the end, since we need to show uncoded transactions
    for AccountIndex := 0 to Client.clChart.ItemCount do
    begin
      AccountNameRendered := False;
      AccountGross := 0;
      AccountGST := 0;
      if AccountIndex < Client.clChart.ItemCount then
        Account := Client.clChart.Account_At(AccountIndex)
      else
        Account := Nil;

      for TransactionIndex := 0 to Pred(Transaction_List.ItemCount) do
      begin
        Transaction := Transaction_List.Transaction_At( TransactionIndex );
        Assert(Transaction <> nil);
        AddTransactionAndDissection(Job, Account, Transaction,
          AccountGross, AccountGST, AccountNameRendered, JobNameRendered);
      end;  //end for transactions

      //Draw Sub Total
      if AccountNameRendered then
      begin
        RenderDetailSectionTotal('Account Total');
      end;
    end; //end for accounts


  finally
     Transaction_List.Free;
  end;

  if (JobNameRendered) then
  begin
    RenderDetailSubTotal('Total');
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DetailedSpendingDetail(Sender : TObject);
Var
   JobIndex: Integer;
   Report: TJobSpendingReport;
   Job: pJob_Heading_Rec;
begin
  Report := TJobSpendingReport(Sender);

  //see if this Job should be included on the report
  for JobIndex := Report.params.Client.clJobs.First to Report.params.Client.clJobs.Last do
  begin
   Job := Report.params.Client.clJobs.Job_At(JobIndex);
   if Report.ShowJobOnReport(Job.jhCode) then
     Report.AddDetailedJob(Job);
  end;

  if Report.Params.ShowAllCodes then
    Report.AddDetailedJob(nil);

  Report.RenderDetailGrandTotal('Grand Total');
end;

procedure SpendingSummary(Sender : TObject);
var
  Report: TJobSpendingReport;
  JobIndex: Integer;
  Job: pJob_Heading_Rec;
Begin
  Report := TJobSpendingReport(Sender);

  for JobIndex := Report.params.Client.clJobs.First to Report.params.Client.clJobs.Last do
  begin
    Job := Report.Params.Client.clJobs.Job_At(JobIndex);
    if Report.ShowJobOnReport(Job.jhCode) then
      Report.AddSummerisedJob(Job);
  end;

  if Report.Params.ShowAllCodes then
    Report.AddSummerisedJob(nil);

  Report.RenderDetailGrandTotal('Grand Total');
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GenerateDetailedJobSpendingReport( Dest : TReportDest; Report : TJobSpendingReport);
var
  CLeft : Double;
  TaxName : String;
begin
  Report.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_Job_Detailed]);
  TaxName := Report.Params.Client.TaxSystemNameUC;

  //Add Headers
  AddCommonHeader(Report);

  AddJobHeader(Report,siTitle,'DETAILED CODING BY JOB',true);
  AddjobHeader(Report,siSubTitle,'For the period from ' +
                         bkdate2Str( Report.Params.Fromdate) + ' to '+
                         bkDate2Str( Report.Params.ToDate),true);
  AddjobHeader(Report,siSubTitle,'',True);

  CLeft  := GcLeft;

  AddColAuto(Report,cLeft, 8.5,Gcgap,'Date', jtLeft);
  AddColAuto(Report,cLeft, 11.5,Gcgap,'Reference', jtLeft);
  AddColAuto(Report,cLeft, 50.0,Gcgap,'Narration', jtLeft);
  if Report.Params.ShowGrossGST then begin
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Gross', jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,TaxName,  jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Net',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
  end else
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Net', jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);

  //Add Footers
  AddCommonFooter(Report);

  Report.OnBKPrint := DetailedSpendingDetail;
  Report.Generate(Dest,Report.params);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure GenerateSummaryJobSpendingReport( Dest : TReportDest; Report : TJobSpendingReport);
var
  cLeft: Double;
  TaxName: string;
begin
  Report.LoadReportSettings(UserPrintSettings,Report_List_Names[Report_Job_Summary]);
  TaxName := Report.Params.Client.TaxSystemNameUC;

  //Add Headers
  AddCommonHeader(Report);

  AddJobHeader(Report,siTitle,'SUMMARISED CODING BY JOB',true);
  AddjobHeader(Report,siSubTitle,'For the period from ' +
                                  bkdate2Str( Report.Params.FromDate) + ' to '+
                                  bkDate2Str( Report.Params.ToDate),true);

  {Add Columns: Report,Left Percent, Width Percent, Caption, Alignment}
  cLeft := GcLeft;
  AddFormatColAuto(Report,cLeft,10,GcGap,'Account',jtLeft,'##','',false);
  AddColAuto(Report,cLeft, 44,GcGap,'Descrpition', jtLeft);
  if Report.Params.ShowGrossGST then begin
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Gross', jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,TaxName,  jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Net',jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);
  end else
     AddFormatColAuto(Report,cLeft, 10.0, Gcgap,'Net', jtRight,'#,##0.00;(#,##0.00);-',MyClient.FmtMoneyStrBrackets,true);

  //Add Footers
  AddCommonFooter(Report);

  Report.OnBKPrint := SpendingSummary;
  Report.Generate(Dest,Report.params);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DoJobSpendingReport(Destination : TReportDest; RptBatch :TReportBase = nil);
//report can be printed in detailed or summary style
var
   JobReport: TJobSpendingReport;
   Params: TJobParameters;
begin
  //set defaults

  Params := TJobParameters.Create(ord(Report_Job_Summary), MyClient,Rptbatch,DYear);
  with params do try
    Params.FromDate := 0;
    Params.ToDate := 0;

    repeat
      if not GetPRParameters(Params) then
        exit;

      if RunBtn = BTN_SAVE then begin
        SaveNodeSettings;
        Exit;
      end;

      case RunBtn of
        BTN_PRINT   : Destination := rdPrinter;
        BTN_PREVIEW : Destination := rdScreen;
        BTN_FILE    : Destination := rdFile;
      else
         Destination := rdAsk;
      end;

      JobReport := TJobSpendingReport.Create(rptOther);;
      try
        //set parameters
        JobReport.Params := Params;

        if SummaryReport then
          GenerateSummaryJobSpendingReport(Destination, JobReport)
        else
          GenerateDetailedJobSpendingReport(Destination, JobReport);

      finally
        JobReport.Free;
      end;

        //Destination := rdNone;
    until Params.RunExit(Destination);
  finally
    Params.Free;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TJobSpendingReport }

function TJobSpendingReport.ShowJobOnReport(JobCode: string): boolean;
var
  i : integer;
begin
  Result := False;
  if Params.ShowAllCodes then
    Result := True
  else
  begin
    for i := 0 to Params.RangesList.Count - 1 do
      if SameText(Params.RangesList[i], JobCode) then
      begin
        Result := True;
        Break;
      end;
  end;
end;

end.
