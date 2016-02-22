unit RptJournalList;

interface

uses
  Classes,
  NewReportObj,
  RptParams,
  Repcols,
  MONEYDEF,
  clObj32,
  OmniXML,
  ReportDefs,
  TravList,
  baObj32,
  UBatchBase;

type
  //----------------------------------------------------------------------------
  TListJournalsParam = class(TRPTParameters)
  private
    fSortBy             : byte;
    fWrapNarration      : Boolean;
    fShowSummary        : Boolean;
    fGroupByJournalType : Boolean;
  protected
    procedure LoadFromClient(aValue : TClientObj); override;
    procedure SaveToClient(aValue : TClientObj); override;
    procedure ReadFromNode(aValue : IXMLNode); override;
    procedure SaveToNode(aValue : IXMLNode); override;
  public
    procedure DoJob(aDest : TReportDest);
    function HasTransactions(aBA: TBank_Account): Boolean;

    property SortBy             : byte    read fSortBy             write fSortBy;
    property WrapNarration      : Boolean read fWrapNarration      write fWrapNarration;
    property ShowSummary        : Boolean read fShowSummary        write fShowSummary;
    property GroupByJournalType : Boolean read fGroupByJournalType write fGroupByJournalType;
  end;

  //----------------------------------------------------------------------------
  TListJournalsReport = class(TBKReport)
  private
    Params : TListJournalsParam;
    CRAmountCol : TReportColumn;
    DRAmountCol : TReportColumn;
    AmountCol   : TReportColumn;
    BalanceCol  : TReportColumn;
    TaxCol      : TReportColumn;
  protected
    function IsBankAccountIncluded(aAccList : TList; aBankAccountNumber: String): Boolean;

    function ValidateCurrentItem(aSender: Tobject; aParam : TListJournalsParam): boolean;

    procedure EnterEntry(Sender : Tobject);
    procedure ExitEntry(Sender : Tobject);
    procedure EnterDissection(Sender : Tobject);

    procedure BKPrint;  override;
  end;

  //----------------------------------------------------------------------------
  procedure DoListJournalsReport(aDest : TReportDest; aRptBatch : TReportBase = nil);

implementation

uses
  SysUtils,
  bkConst,
  RptListings,
  Globals,
  bkdateutils,
  WarningMoreFrm,
  InfoMoreFrm,
  NewReportUtils,
  ReportTypes,
  CountryUtils,
  BKHelp,
  JournalOptionsDlg,
  BKDEFS,
  imagesfrm,
  Graphics,
  ReportImages,
  GenUtils,
  TransactionUtils,
  BAutils;

Const
  TRANSFERED_IMG = 'Transfered_Icon';
  LOCKED_IMG = 'Locked_Icon';
  TRANSandLOCKED_IMG = 'TransAndLocked_Icon';
  COL_NARRATION = 5;
  COL_SHOW_ALL = 99;

  btJournalRptNames : Array[ btMin..btMax ] of String[ 25 ] =
  ( 'Bank Account',
    'Cash',
    'Accrual',
    'GST Journals',
    'Stock/Adjustment',
    'Opening Balances',
    'Year End Adjustments',
    'Stock Balances',
    'Exchange Gains/Losses');

//------------------------------------------------------------------------------
// Main Entry point into Report
procedure DoListJournalsReport(aDest : TReportDest;
                               aRptBatch : TReportBase = nil);
const
  JNL_DLG_TITLE = 'List Journals';
  JNL_DLG_MSG = 'Enter the starting and finishing date for the journals you want to list.';
var
  LParams : TListJournalsParam;
  HasSomeEntries : Boolean;
  BankAcc : TBank_Account;
  AccountIndex , Button : Integer;
  ISOCodes : string;
  NonBaseCurrency : Boolean;
begin
  NonBaseCurrency := False;
  LParams := TListJournalsParam.Create(ord(Report_Last), MyClient, aRptBatch,dPeriod );
  try
    LParams.GetBatchAccounts;
    repeat
      HasSomeEntries := False;

      while not HasSomeEntries do
      begin
        if not lparams.BatchRun then
        begin
          Lparams.ReportType := ord(REPORT_LIST_JOURNALS);

          // Present the Journal Options Dialog to the User for Input
          if not EnterJournalOptions(JNL_DLG_TITLE, JNL_DLG_MSG, LParams) then
            exit;

          AccountIndex := 0;
          while AccountIndex < LParams.AccountList.Count do
          begin
            BankAcc := LParams.AccountList[AccountIndex];
            if  BankAcc.baFields.baAccount_Type = btStockBalances then
              LParams.AccountList.Delete(AccountIndex)
            else
              Inc(AccountIndex);
          end;
        end;

        if LParams.RunBtn = BTN_SAVE then
        begin
          lParams.SaveNodeSettings;
          Exit;
        end
        else if (LParams.BatchRunMode = R_Normal) then
          LParams.SaveClientSettings;

        case LParams.RunBtn of
          BTN_PRINT   : aDest := rdPrinter;
          BTN_PREVIEW : aDest := rdScreen;
          BTN_FILE    : aDest := rdFile;
          BTN_SAVE    : aDest := rdNone;
          BTN_EMAIL   : aDest := rdEmail;
        else
          exit;
        end;

        //check for entries
        HasSomeEntries := False;
        for AccountIndex := 0 to Pred(LParams.AccountList.Count) do
        begin
          BankAcc := LParams.AccountList[AccountIndex];

          if (BankAcc.IsAJournalAccount) and
            (LParams.HasTransactions(BankAcc)) then
          begin
            HasSomeEntries := True;
            Break;
          end;
        end;

        if not HasSomeEntries then
        begin
          if LParams.BatchRun then
          begin
            aRptBatch.RunResult := 'No Entries in date range , ' +
                                   bkDate2Str(LParams.FromDate) + ' to ' +
                                   bkDate2Str(LParams.Todate) + '.';

            Exit; // Was meant to run direct... Just Exit
          end
          else
            HelpfulWarningMsg('There are no Entries for this client in the date range , ' +
                              bkDate2Str(LParams.FromDate) + ' to ' +
                              bkDate2Str(LParams.Todate) + '.', 0);
        end;
      end; //While HasSomeEntries


      if aDest = rdNone then
        Continue;

      //Flag bank accounts included in the report
      for AccountIndex := 0 to Pred(MyClient.clBank_Account_List.ItemCount) do
        MyClient.clBank_Account_List.Bank_Account_At(AccountIndex).baFields.baTemp_Include_In_Report := False;

      for AccountIndex := 0 to Pred(LParams.AccountList.Count) do
        TBank_Account(LParams.AccountList[AccountIndex]).baFields.baTemp_Include_In_Report := True;

      //Check exchange rates
      if not MyClient.HasExchangeRates(ISOCodes, LParams.FromDate, LParams.ToDate, True, False) then
      begin
        HelpfulInfoMsg('The report could not be run because there are missing exchange rates for ' + ISOCodes + '.',0);
        Continue;
      end;

      LParams.DoJob(aDest);

      if LParams.BatchRun then
        aRptBatch.RunResult := 'Ok';

    until LParams.RunExit(aDest);

  finally
    FreeAndNil(lParams);
  end;
end;

//------------------------------------------------------------------------------
// TListJournalsParam
procedure TListJournalsParam.LoadFromClient(aValue: TClientObj);
begin
  inherited;

  SortBy             := aValue.clExtra.ceList_Entries_Sort_Order;
  WrapNarration      := aValue.clExtra.ceList_Entries_Wrap_Narration;
  ShowSummary        := aValue.clExtra.ceList_Entries_Show_Summary;
  GroupByJournalType := aValue.clExtra.ceList_Entries_GroupBy_Journal_Type;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.SaveToClient(aValue: TClientObj);
begin
  aValue.clExtra.ceList_Entries_Sort_Order           := SortBy;
  aValue.clExtra.ceList_Entries_Wrap_Narration       := WrapNarration;
  aValue.clExtra.ceList_Entries_Show_Summary         := ShowSummary;
  aValue.clExtra.ceList_Entries_GroupBy_Journal_Type := GroupByJournalType;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.ReadFromNode(aValue: IXMLNode);
begin
  if SameText( csNames[csDateEffective],GetBatchText('Sort', csNames[csDateEffective])) then
    SortBy := csDateEffective
  else
    SortBy := csDatePresented;

  WrapNarration := GetBatchBool('Wrap_Naration',WrapNarration);
  ShowSummary   := GetBatchBool('Show_Summary',ShowSummary);
  GroupByJournalType := GetBatchBool('GroupBy_Journal_Type',GroupByJournalType);

  GetBatchAccounts;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.SaveToNode(aValue: IXMLNode);
begin
  inherited;

  setBatchText('Sort',csNames[SortBy]);
  SetBatchBool('Wrap_Naration',WrapNarration);
  SetBatchBool('Show_Summary',ShowSummary);
  SetBatchBool('GroupBy_Journal_Type',GroupByJournalType);

  SaveBatchAccounts;
end;

//------------------------------------------------------------------------------
// TListJournalsReport
function TListJournalsReport.IsBankAccountIncluded(aAccList : TList; aBankAccountNumber: String): Boolean;
var
  AccIndex : Integer;
  BankAcc  : TBank_Account;
begin
  Result := False;
  for AccIndex := 0 to Pred(aAccList.Count) do
  begin
    BankAcc := aAccList[AccIndex];
    if (BankAcc.baFields.baBank_Account_Number = aBankAccountNumber) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TListJournalsReport.ValidateCurrentItem(aSender: Tobject; aParam : TListJournalsParam): boolean;
var
  Mgr : TTravManagerWithNewReport;
begin
  Result := false;
  Mgr := TTravManagerWithNewReport(aSender);

  // Validate if we should process
  if not Mgr.Bank_Account.IsAJournalAccount then
    Exit;

  if (not IsBankAccountIncluded(aParam.AccountList, Mgr.Bank_Account.baFields.baBank_Account_Number)) then
    Exit;

  if not aParam.HasTransactions(Mgr.Bank_Account) then
    Exit;

  Result := true;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.EnterEntry(Sender : Tobject);
Const
  IMG_SCALE_UP_PERCENT = 150;
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
  CanvasFont : TFont;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  // State Image
  if (Mgr.Transaction^.txDate_Transferred > 0) and (Mgr.Transaction^.txLocked) then
    Rpt.PutImage(TRANSandLOCKED_IMG, IMG_SCALE_UP_PERCENT)
  else if (Mgr.Transaction^.txDate_Transferred > 0) then
    Rpt.PutImage(TRANSFERED_IMG, IMG_SCALE_UP_PERCENT)
  else if (Mgr.Transaction^.txLocked) then
    Rpt.PutImage(LOCKED_IMG, IMG_SCALE_UP_PERCENT)
  else
    Rpt.SkipColumn;

  PutString( bkDate2Str ( Mgr.Transaction^.txDate_Effective ) );
  PutString( GetFormattedReference( Mgr.Transaction));
  PutStringMultipleColumns( Mgr.Transaction^.txGL_Narration, COL_SHOW_ALL);

  // Sets Line to Bold
  CanvasFont := TFont.Create;
  try
    CanvasFont.Assign(RendEngCanvas.Font);
    CanvasFont.Style := [fsbold];
    RenderDetailLine(true, siDetail, CanvasFont);
  finally
    FreeAndNil(CanvasFont);
  end;

  RenderEmptyLine;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.ExitEntry(Sender: Tobject);
const
  JNL_TYPE = 'Journal Type: ';
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
  slNotes : TStringList;
  NoteLineIndex : integer;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  RendEngCanvas.Font.Style := [];
  RenderDetailGrandTotal('');
  RenderEmptyLine;

  slNotes := TStringList.Create;
  try
    slNotes := WrapTextIntoStringList(GetFullNotes(Mgr.Transaction), 300);
    for NoteLineIndex := 0 to slNotes.Count - 1 do
    begin
      Rpt.SkipColumn;
      Rpt.SkipColumn;
      PutStringMultipleColumns( slNotes.Strings[NoteLineIndex], COL_SHOW_ALL);
      RendEngCanvas.Font.Style := [];
      RenderDetailLine();
    end;
  finally
    slNotes.Free;
  end;

  Rpt.SkipColumn;
  Rpt.SkipColumn;
  PutStringMultipleColumns(JNL_TYPE + btJournalRptNames[Mgr.Bank_Account.baFields.baAccount_Type], COL_SHOW_ALL);
  RendEngCanvas.Font.Style := [];
  RenderDetailLine();

  RenderEmptyLine;
  RenderEmptyLine;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.EnterDissection(Sender: Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
  ExtraLines : TStringList;
  ExtraIndex : integer;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  SkipColumn;
  SkipColumn;

  PutString(Mgr.Dissection^.dsReference);
  PutString(Mgr.Dissection^.dsAccount);
  PutString(Rpt.Params.Client.clChart.FindDesc(Mgr.Dissection^.dsAccount));

  // Wraps the Narration if the option is Set
  ExtraLines := TStringList.Create();
  try
    WrapText(COL_NARRATION, Mgr.Dissection^.dsGL_Narration, ExtraLines);

    if Rpt.Params.WrapNarration then
    begin
      for ExtraIndex := 0 to ExtraLines.Count-1 do
      begin
        SkipColumn;
        SkipColumn;
        SkipColumn;

        RendEngCanvas.Font.Style := [];
        RenderDetailLine();

        SkipColumn;
        SkipColumn;
        SkipColumn;
        SkipColumn;
        SkipColumn;

        PutString(ExtraLines.Strings[ExtraIndex]);
      end;
    end;

  finally
    FreeAndNil(ExtraLines);
  end;

  if Mgr.Dissection^.dsAmount >= 0 then
  begin
    SkipColumn;
    SkipColumn;
    PutMoney( Trunc( Mgr.Dissection^.dsAmount ) );
  end
  else
  begin
    PutMoney( Trunc( Mgr.Dissection^.dsAmount ) );
    SkipColumn;
    SkipColumn;
  end;

  RendEngCanvas.Font.Style := [];
  RenderDetailLine();
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.DoJob(aDest : TReportDest);
var
  Job : TListJournalsReport;
  WorkStr : string;
  Country : Byte;
  cleft : Double;
  ExtraWidth : double;
  MONEY_FORMAT : String;
  Transfered, Locked, TransAndLocked : TPicture;
begin
  Job := TListJournalsReport.Create(ReportTypes.rptListings);
  job.Params := Self;
  try
    Job.LoadReportSettings(UserPrintSettings,
    Job.Params.MakeRptName(Report_List_Names[REPORT_LIST_ENTRIES]));

    //Add Headers
    AddCommonHeader(Job);

    WorkStr := 'FROM ';

    If Job.Params.FromDate =0 then
      WorkStr := WorkStr + 'FIRST'
    else
      WorkStr := WorkStr + bkDate2Str( Job.Params.FromDate );
    WorkStr := WorkStr + ' TO ';

    If Job.Params.ToDate=MaxLongInt then
      WorkStr := WorkStr + 'LAST'
    else
      WorkStr := WorkStr + bkDate2Str( Job.Params.ToDate );

    AddJobHeader(Job,siTitle,'LIST JOURNALS '+WorkStr, true);

    case Job.Params.SortBy of
      csDateEffective    : WorkStr := 'BY DATE';
      csDateAndReference : WorkStr := 'BY DATE AND REFERENCE';
      csReference        : WorkStr := 'BY REFERENCE';
    end;

    AddJobHeader(Job,siSubtitle,WorkStr,true);

    AddJobHeader(Job,siSubTitle,'',true);
    //Build the columns
    Country := Job.Params.Client.clFields.clCountry;

    CLeft := Gcleft;

    AddColAuto(Job,cleft, 4.5, Gcgap, 'Status', jtLeft);
    AddColAuto(Job,cleft, 7.5, Gcgap, 'Date', jtLeft);
    AddColAuto(Job,cleft, 12 + ExtraWidth, Gcgap, 'Reference', jtLeft);
    AddColAuto(Job,cleft, 8.0, Gcgap, 'Account'  , jtLeft);
    AddColAuto(Job,cleft, 20.0, Gcgap, 'A/c Desc', jtLeft);
    AddColAuto(Job,cleft, 25.0, Gcgap, 'Narration', jtLeft);

    MONEY_FORMAT := '#,##0.00;#,##0.00';

    Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Debit',jtRight,MONEY_FORMAT,MONEY_FORMAT,true);
    AddColAuto(Job,cleft, 1.0, Gcgap, '', jtLeft);
    Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Credit',jtRight,MONEY_FORMAT,MONEY_FORMAT,true);

    //Add Footers
    AddCommonFooter(Job);

    //create report and image list
    CreateReportImageList;
    try
      //will be destroyed when list is cleared
      Transfered := TPicture.Create;
      Locked := TPicture.Create;
      TransAndLocked := TPicture.Create;

      Transfered.Assign(ImagesFrm.AppImages.imgTick.Picture);
      Locked.Assign(ImagesFrm.AppImages.imgLock.Picture);
      TransAndLocked.Assign(ImagesFrm.AppImages.imgTickLock.Picture);

      AddPictureToReportImageList( Transfered, TRANSFERED_IMG, 0, 0);
      AddPictureToReportImageList( Locked, LOCKED_IMG, 0, 0);
      AddPictureToReportImageList( TransAndLocked, TRANSandLOCKED_IMG, 0, 0);

      Job.Generate(aDest, Self);
    finally
      DestroyReportImageList;
    end;

  finally
    FreeAndNil(Job);
  end;
end;

//------------------------------------------------------------------------------
function TListJournalsParam.HasTransactions(aBA: TBank_Account): Boolean;
var
  TranIndex: Integer;
  Trans: pTransaction_Rec;
begin
  for TranIndex := 0 to Pred(aBA.baTransaction_List.ItemCount) do
  begin
    Trans := aBA.baTransaction_List.Transaction_At(TranIndex);
    if (Trans.txDate_Effective >= FromDate) and
       (Trans.txDate_Effective <= ToDate) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.BKPrint;
var
  TravMgr : TTravManagerWithNewReport;
  AccountIndex : integer;
  BankAcc : TBank_Account;
begin
  TravMgr := TTravManagerWithNewReport.Create;
  try
    TravMgr.Clear;
    TravMgr.SortType := params.SortBy;

    TravMgr.SelectionCriteria := TravList.twAllEntries;

    TravMgr.ReportJob := Self;

    TravMgr.OnEnterEntryExt := EnterEntry;
    TravMgr.OnExitEntryExt := ExitEntry;
    TravMgr.OnEnterDissectionExt := EnterDissection;

    for AccountIndex := 0 to params.AccountList.Count - 1 do
    begin
      BankAcc := TBank_Account(params.AccountList[AccountIndex]);

      if BankAcc.IsaJournalAccount then
        TravMgr.TraverseAccount(BankAcc, params.Fromdate, params.ToDate);
    end;
  finally
    FreeAndNil(TravMgr);
  end;
end;

end.
