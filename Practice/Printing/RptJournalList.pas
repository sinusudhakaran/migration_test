unit RptJournalList;

interface

uses
  Classes,
  NewReportObj,
  ReportTypes,
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
  TGSTTotal = record
    gstAccountName    : string[60];
    gstControlAccount : string[20];
    gstTotalAmount    : Money;
  end;
  pGSTTotal = ^TGSTTotal;

  //----------------------------------------------------------------------------
  TListJournalsReport = class(TBKReport)
  private
    Params       : TListJournalsParam;
    CRAmountCol  : TReportColumn;
    DRAmountCol  : TReportColumn;
    AmountCol    : TReportColumn;
    GSTAmountCol : TReportColumn;
    QuantityCol  : TReportColumn;
    GSTTotals    : TList;
  protected
    function AreCallbackParamsOK(aSender : Tobject) : boolean;

    procedure ClearGSTTotals();
    function FindControlAcc(aControlAcc : string; var aIndex : integer) : boolean;

    function IsBankAccountIncluded(aAccList : TList; aBankAccountNumber: String): Boolean;

    function ValidateCurrentItem(aSender: Tobject; aParam : TListJournalsParam): boolean;

    procedure EnterEntry(Sender : Tobject);
    procedure ExitEntry(Sender : Tobject);
    procedure EnterDissection(Sender : Tobject);
    procedure RenderGSTControlAccounts(Sender : Tobject);

    procedure BKPrint; override;
  public
    constructor Create (RptType: TReportType); override;
    destructor Destroy; override;
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
  CountryUtils,
  BKHelp,
  JournalOptionsDlg,
  BKDEFS,
  imagesfrm,
  Graphics,
  ReportImages,
  GenUtils,
  TransactionUtils,
  UserReportSettings,
  PayeeObj,
  chList32,
  LogUtil,
  MoneyUtils,
  BAutils;

Const
  UNIT_NAME = 'RptJournalList';
  TRANSFERED_IMG = 'Transfered_Icon';
  LOCKED_IMG = 'Locked_Icon';
  TRANSandLOCKED_IMG = 'TransAndLocked_Icon';

  COL_STATUS     = 0;
  COL_DATE       = 1;
  COL_REF        = 2;
  COL_ACCOUNT    = 3;
  COL_AC_DESC    = 4;
  COL_NARRATION  = 5;
  COL_DEBIT      = 6;
  COL_GAP1       = 7;
  COL_CREDIT     = 8;
  COL_GAP2       = 9;
  COL_PAYEE      = 10;
  COL_PAYEE_NAME = 11;
  COL_JOB        = 12;
  COL_JOB_NAME   = 13;
  COL_AMOUNT     = 14;
  COL_GST_ID     = 15;
  COL_GST_AMOUNT = 16;
  COL_QUANTITY   = 17;
  COL_MAX = COL_QUANTITY;

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

  COL_SIZES : Array[0..1,0..COL_MAX] of single =
  ((4.6,7.5,8  ,8  ,20  ,27.9,11 ,1  ,11 ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0  ,0),
   (3.6,4.8,5.1,4.6,10  ,14.5,6  ,0.6,6.3,0.6,3.6,6.4,2.9,6.4,6  ,5.6,6  ,6  ));

  NN_SORT        = 'Sort';
  NN_WRAP_NARR   = 'Wrap_Naration';
  NN_SHOW_SUM    = 'Show_Summary';
  NN_GRP_JNL_TYP = 'GroupBy_Journal_Type';

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

  if not assigned(MyClient) then
  begin
    LogUtil.LogMsg(lmError, UNIT_NAME, 'Client not assigned.');
    Exit;
  end;

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
  if SameText( csNames[csDateEffective],GetBatchText(NN_SORT, csNames[csDateEffective])) then
    SortBy := csDateEffective
  else
    SortBy := csDatePresented;

  WrapNarration := GetBatchBool(NN_WRAP_NARR, WrapNarration);
  ShowSummary   := GetBatchBool(NN_SHOW_SUM, ShowSummary);
  GroupByJournalType := GetBatchBool(NN_GRP_JNL_TYP, GroupByJournalType);

  GetBatchAccounts;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.SaveToNode(aValue: IXMLNode);
begin
  inherited;

  setBatchText(NN_SORT, csNames[SortBy]);
  SetBatchBool(NN_WRAP_NARR, WrapNarration);
  SetBatchBool(NN_SHOW_SUM, ShowSummary);
  SetBatchBool(NN_GRP_JNL_TYP, GroupByJournalType);

  SaveBatchAccounts;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.DoJob(aDest : TReportDest);
var
  Job : TListJournalsReport;
  WorkStr : string;
  Country : Byte;
  cleft : Double;
  ExtraWidth : double;
  Transfered, Locked, TransAndLocked : TPicture;
  Show_Detail : integer;
begin
  Job := TListJournalsReport.Create(ReportTypes.rptListings);
  try
    job.Params := Self;

    if not assigned(Job.Params.Client) then
    begin
      LogUtil.LogMsg(lmError, UNIT_NAME, 'Client not assigned.');
      Exit;
    end;

    Job.LoadReportSettings(UserPrintSettings,
    Job.Params.MakeRptName(Report_List_Names[Report_List_Journals]));

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

    if Job.Params.ShowSummary then
      Job.UserReportSettings.s7Orientation := BK_PORTRAIT
    else
      Job.UserReportSettings.s7Orientation := BK_LANDSCAPE;

    CLeft := Gcleft;

    if Job.Params.ShowSummary then
      Show_Detail := 0
    else
      Show_Detail := 1;

    // when Printing to file needs to not print the status column
    if not (RunBtn = BTN_FILE) then
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_STATUS], Gcgap, 'Status', jtLeft);

    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_DATE], Gcgap, 'Date', jtLeft);
    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_REF] + ExtraWidth, Gcgap, 'Reference', jtLeft);
    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_ACCOUNT], Gcgap, 'Account'  , jtLeft);
    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_AC_DESC], Gcgap, 'A/c Desc', jtLeft);
    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_NARRATION], Gcgap, 'Narration', jtLeft);

    Job.DRAmountCol := AddFormatColAuto(Job,cLeft,COL_SIZES[Show_Detail, COL_DEBIT],Gcgap,'Debit',jtRight,MONEY_FORMAT,MONEY_FORMAT,true);
    AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_GAP1], Gcgap, '', jtLeft);
    Job.CRAmountCol := AddFormatColAuto(Job,cLeft,COL_SIZES[Show_Detail, COL_CREDIT],Gcgap,'Credit',jtRight,MONEY_FORMAT,MONEY_FORMAT,true);

    if not Job.Params.ShowSummary then
    begin
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_GAP2], Gcgap, '', jtLeft);
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_PAYEE], Gcgap, 'Payee', jtLeft);
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_PAYEE_NAME], Gcgap, 'Payee Name', jtLeft);
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_JOB], Gcgap, 'Job', jtLeft);
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_JOB_NAME], Gcgap, 'Job Name', jtLeft);
      Job.AmountCol := AddFormatColAuto(Job,cLeft,COL_SIZES[Show_Detail, COL_AMOUNT],Gcgap,'Amount',jtRight,MONEY_FORMAT_SIGN,MONEY_FORMAT_SIGN,false);
      AddColAuto(Job,cleft, COL_SIZES[Show_Detail, COL_GST_ID], Gcgap, 'GST ID', jtLeft);
      Job.GSTAmountCol := AddFormatColAuto(Job,cLeft,COL_SIZES[Show_Detail, COL_GST_AMOUNT],Gcgap,'GST Amt',jtRight,MONEY_FORMAT_SIGN,MONEY_FORMAT_SIGN,false);
      Job.QuantityCol := AddFormatColAuto(Job,cLeft,COL_SIZES[Show_Detail, COL_QUANTITY],Gcgap,'Quantity',jtRight,QUANTITY_FORMAT,QUANTITY_FORMAT,false);
    end;

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
// TListJournalsReport
function TListJournalsReport.AreCallbackParamsOK(aSender: Tobject): boolean;
var
  Mgr : TTravManagerWithNewReport;
begin
  Result := false;
  if not assigned(aSender) then
    Exit;

  if not(aSender is TTravManagerWithNewReport) then
    Exit;

  Mgr := TTravManagerWithNewReport(aSender);

  if not assigned(Mgr.ReportJob) then
    Exit;

  if not(Mgr.ReportJob is TListJournalsReport) then
    Exit;

  Result := true;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.ClearGSTTotals;
var
  GSTIndex : integer;
begin
  for GSTIndex := 0 to Pred(GSTTotals.Count) do
    FreeMem( pGSTTotal(GSTTotals.Items[GSTIndex]), SizeOf( TGSTTotal ) );

  GSTTotals.Clear;
end;

//------------------------------------------------------------------------------
function TListJournalsReport.FindControlAcc(aControlAcc: string; var aIndex: integer): boolean;
var
  GSTIndex : integer;
begin
  aIndex := -1;
  Result := false;
  for GSTIndex := 0 to Pred(GSTTotals.Count) do
  begin
    if pGSTTotal(GSTTotals.Items[GSTIndex])^.gstControlAccount = aControlAcc then
    begin
      aIndex := GSTIndex;
      Result := true;
      Exit;
    end;
  end;
end;

//------------------------------------------------------------------------------
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
  if not AreCallbackParamsOK(Sender) then
    Exit;

  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );
  ClearGSTTotals();

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  // State Image
  // when Printing to file needs to not print the status column
  if not (Params.RunBtn = BTN_FILE) then
  begin
    if (Mgr.Transaction^.txDate_Transferred > 0) and (Mgr.Transaction^.txLocked) then
      Rpt.PutImage(TRANSandLOCKED_IMG, IMG_SCALE_UP_PERCENT)
    else if (Mgr.Transaction^.txDate_Transferred > 0) then
      Rpt.PutImage(TRANSFERED_IMG, IMG_SCALE_UP_PERCENT)
    else if (Mgr.Transaction^.txLocked) then
      Rpt.PutImage(LOCKED_IMG, IMG_SCALE_UP_PERCENT)
    else
      SkipColumn();
  end;

  PutString( bkDate2Str ( Mgr.Transaction^.txDate_Effective ), Rpt.Params.WrapNarration );
  PutString( GetFormattedReference( Mgr.Transaction), Rpt.Params.WrapNarration);
  PutStringMultipleColumns( Mgr.Transaction^.txGL_Narration, COL_SHOW_ALL);

  // Sets Line to Bold
  if Assigned(RendEngCanvas) then
  begin
    // Set font if the Rend Engine Canvas is accesable, there is none in CSV
    CanvasFont := TFont.Create;
    try
      CanvasFont.Assign(RendEngCanvas.Font);
      CanvasFont.Style := [fsbold];
      RenderDetailLine(true, siDetail, CanvasFont);
    finally
      FreeAndNil(CanvasFont);
    end;
  end
  else
    RenderDetailLine();

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
  if not AreCallbackParamsOK(Sender) then
    Exit;

  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  RenderGSTControlAccounts(Sender);

  if Assigned(RendEngCanvas) then
    RendEngCanvas.Font.Style := [];

  RenderDetailGrandTotal('');

  slNotes := WrapTextIntoStringList(GetFullNotes(Mgr.Transaction), 300);
  try
    if slNotes.Count > 0 then
      RenderEmptyLine;

    for NoteLineIndex := 0 to slNotes.Count - 1 do
    begin
      // when Printing to file needs to not print the status column
      if Params.RunBtn = BTN_FILE then
        SkipColumn
      else
        SkipColumns(2);

      PutStringMultipleColumns( slNotes.Strings[NoteLineIndex], COL_SHOW_ALL);

      if Assigned(RendEngCanvas) then
        RendEngCanvas.Font.Style := [];
      RenderDetailLine();
    end;
  finally
    FreeAndNil(slNotes);
  end;

  RenderEmptyLine;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.EnterDissection(Sender: Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
  gstControlAcc : string;
  gstAccountName : string;
  FoundIndex : integer;
  NewGSTTotal : pGSTTotal;
  Payee: TPayee;
  Job: PJob_Heading_Rec;
  ChartRec : pAccount_Rec;
begin
  if not AreCallbackParamsOK(Sender) then
    Exit;

  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if not ValidateCurrentItem(Sender, Rpt.Params) then
    Exit;

  // when Printing to file needs to not print the status column
  if Params.RunBtn = BTN_FILE then
    SkipColumn
  else
    SkipColumns(2);

  PutString(Mgr.Dissection^.dsReference, Rpt.Params.WrapNarration);
  PutString(Mgr.Dissection^.dsAccount, Rpt.Params.WrapNarration);
  PutString(Rpt.Params.Client.clChart.FindDesc(Mgr.Dissection^.dsAccount), Rpt.Params.WrapNarration);
  PutString(Mgr.Dissection^.dsGL_Narration, Rpt.Params.WrapNarration);

  if Mgr.Dissection^.dsAmount >= 0 then
  begin
    PutMoney( Trunc( Mgr.Dissection^.dsAmount - Mgr.Dissection^.dsGST_Amount ), true, true);
    SkipColumns(2);
  end
  else
  begin
    SkipColumns(2);
    PutMoney( Trunc( Mgr.Dissection^.dsAmount - Mgr.Dissection^.dsGST_Amount ), true, true );
  end;

  // Is there GST for this Journal Item
  GSTControlAcc := '';
  if (Mgr.Dissection^.dsGST_Amount <> 0) then
  begin
    gstControlAcc := Rpt.Params.Client.clFields.clGST_Account_Codes[Mgr.Dissection^.dsGST_Class];
    ChartRec := Rpt.Params.Client.clChart.SearchClosestCode(gstControlAcc);
    if Assigned(ChartRec) then
      gstAccountName := ChartRec^.chAccount_Description
    else
      gstAccountName := '';

    if trim(GSTControlAcc) <> '' then
    begin
      // Does the Control Account exist in the temp list
      if FindControlAcc(GSTControlAcc, FoundIndex) then
      begin
        // Update Total
        pGSTTotal(GSTTotals.Items[FoundIndex])^.gstTotalAmount :=
          pGSTTotal(GSTTotals.Items[FoundIndex])^.gstTotalAmount +
          Mgr.Dissection^.dsGST_Amount;
      end
      else
      begin
        // Add New Control Account
        GetMem( NewGSTTotal, SizeOf( TGSTTotal ) ) ;
        NewGSTTotal^.gstAccountName    := gstAccountName;
        NewGSTTotal^.gstControlAccount := gstControlAcc;
        NewGSTTotal^.gstTotalAmount    := Mgr.Dissection^.dsGST_Amount;

        GSTTotals.Add( NewGSTTotal ) ;
      end;
    end;
  end;

  if not Rpt.Params.ShowSummary then
  begin
    SkipColumn();
    // Payees
    if Mgr.Dissection^.dsPayee_Number > 0 then
    begin
      PutString(inttostr(Mgr.Dissection^.dsPayee_Number), Rpt.Params.WrapNarration);
      Payee := Rpt.Params.Client.clPayee_List.Find_Payee_Number(Mgr.Dissection^.dsPayee_Number);
      if Assigned(Payee) then
        PutString(Payee.pdFields.pdName, Rpt.Params.WrapNarration);
    end
    else
      SkipColumns(2);

    // Jobs
    PutString(trim(Mgr.Dissection^.dsJob_Code), Rpt.Params.WrapNarration);
    Job := Rpt.Params.Client.clJobs.FindCode(Mgr.Dissection^.dsJob_Code);
    if Assigned(Job) then
      PutString(trim(Job.jhHeading), Rpt.Params.WrapNarration)
    else
      SkipColumn();

    // Amounts and GST
    PutMoney( Trunc( Mgr.Dissection^.dsAmount ), true, true );
    if GSTControlAcc <> '' then
    begin
      PutString( Rpt.Params.Client.clFields.clGST_Class_Codes[Mgr.Dissection^.dsGST_Class], Rpt.Params.WrapNarration );
      PutMoney( Trunc( Mgr.Dissection^.dsGST_Amount ), true, true);
    end
    else
    begin
      PutString('None');
      PutString('-  ');
    end;

    // Quantity
    if Mgr.Dissection^.dsQuantity <> 0 then
      PutQuantity( Trunc( Mgr.Dissection^.dsQuantity ), true )
    else
      PutString('-   ');
  end;

  if Assigned(RendEngCanvas) then
    RendEngCanvas.Font.Style := [];
  RenderDetailLine();
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.RenderGSTControlAccounts(Sender: Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
  GSTIndex : integer;
  GSTTotal : TGSTTotal;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  for GSTIndex := 0 to Pred(GSTTotals.Count) do
  begin
    GSTTotal := pGSTTotal(GSTTotals.Items[GSTIndex])^;

    // when Printing to file needs to not print the status column
    if Params.RunBtn = BTN_FILE then
      SkipColumn
    else
      SkipColumns(2);

    PutString(Mgr.Transaction^.txReference, Rpt.Params.WrapNarration);
    PutString(GSTTotal.gstControlAccount, Rpt.Params.WrapNarration);
    PutString(GSTTotal.gstAccountName, Rpt.Params.WrapNarration);
    PutString(Mgr.Transaction^.txGL_Narration, Rpt.Params.WrapNarration);

    if GSTTotal.gstTotalAmount >= 0 then
    begin
      PutMoney( Trunc( GSTTotal.gstTotalAmount ) , true, true);
      SkipColumns(2);
    end
    else
    begin
      SkipColumns(2);
      PutMoney( Trunc( GSTTotal.gstTotalAmount ) , true, true);
    end;

    if not Rpt.Params.ShowSummary then
      SkipColumns(9);

    if Assigned(RendEngCanvas) then
      RendEngCanvas.Font.Style := [];
    RenderDetailLine();
  end;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.BKPrint;
var
  TravMgr : TTravManagerWithNewReport;
  AccountIndex : integer;
  BankAcc : TBank_Account;
begin
  inherited;

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

//------------------------------------------------------------------------------
constructor TListJournalsReport.Create(RptType: TReportType);
begin
  inherited;
  GSTTotals := TList.Create;
end;

//------------------------------------------------------------------------------
destructor TListJournalsReport.Destroy;
begin
  FreeAndNil(GSTTotals);
  inherited;
end;

end.
