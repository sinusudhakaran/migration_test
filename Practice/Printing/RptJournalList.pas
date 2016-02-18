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
  UBatchBase;

type
  //---------------------------------------------------------------------------
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

    property SortBy             : byte    read fSortBy             write fSortBy;
    property WrapNarration      : Boolean read fWrapNarration      write fWrapNarration;
    property ShowSummary        : Boolean read fShowSummary        write fShowSummary;
    property GroupByJournalType : Boolean read fGroupByJournalType write fGroupByJournalType;
  end;

  //---------------------------------------------------------------------------
  TListJournalsReport = class(TBKReport)
  private
    Params : TListJournalsParam;
    CRAmountCol : TReportColumn;
    DRAmountCol : TReportColumn;
    AmountCol   : TReportColumn;
    BalanceCol  : TReportColumn;
    TaxCol      : TReportColumn;
  protected
    procedure BKPrint;  override;
    procedure PutNotes(aNotes : string);
    procedure PutNarrationNotes(aJob: TBKReport; aNarration, aNotes : string; aShowBal: Boolean; aBal: Money);
    function SplitLine(aColIdx: Integer; var aTextList: TStringList) : Integer;
  end;

  procedure DoListJournalsReport(aDest : TReportDest; aRptBatch : TReportBase = nil);



implementation

uses
  SysUtils,
  bkConst,
  TravList,
  RptListings,
  baObj32,
  Globals,
  bkdateutils,
  WarningMoreFrm,
  InfoMoreFrm,
  NewReportUtils,
  ReportTypes,
  CountryUtils,
  BKHelp,
  JournalOptionsDlg;

//------------------------------------------------------------------------------
procedure DoListJournalsReport(aDest : TReportDest;
                               aRptBatch : TReportBase = nil);
//uses two column layout if set for coding report
var
  LParams : TListJournalsParam;
  HasSomeEntries : Boolean;
  BA : TBank_Account;
  AccountIndex , Button : Integer;
  ISOCodes : string;
  NonBaseCurrency : Boolean;
  MONEY_FORMAT : String;
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

          if not EnterJournalOptions('List Journals','Enter the starting and finishing date for the journals you want to list.',
                                LParams) then exit;

          AccountIndex := 0;
          while AccountIndex < LParams.AccountList.Count do
          begin
            ba := LParams.AccountList[AccountIndex];
            if  BA.baFields.baAccount_Type = btStockBalances then
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
          else          Exit;
        end;

        MONEY_FORMAT := MyClient.FmtMoneyStr;

        //check for entries
        HasSomeEntries := False;
        for AccountIndex := 0 to Pred(LParams.AccountList.Count) do
        begin
          ba := LParams.AccountList[AccountIndex];

          if BA.IsAJournalAccount and
             LE_HasTransactions(LParams.FromDate,LParams.Todate , BA) then
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

{ TListEntriesParam }
//------------------------------------------------------------------------------
procedure TListJournalsParam.DoJob(aDest : TReportDest);
var
  Job : TListJournalsReport;
  WorkStr : string;
  Country : Byte;
  cleft : Double;
  ExtraWidth : double;
  MONEY_FORMAT : String;
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

    {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
    CLeft := Gcleft;

    AddColAuto(Job,cleft, 5.3, Gcgap, 'Status', jtLeft);
    AddColAuto(Job,cleft, 6.3, Gcgap, 'Date', jtLeft);
    AddColAuto(Job,cleft, 10 + ExtraWidth, Gcgap, 'Reference', jtLeft);
    AddColAuto(Job,cleft, 8.0, Gcgap, 'Account'  , jtLeft);
    AddColAuto(Job,cleft, 20.0, Gcgap, 'A/c Desc', jtLeft);
    AddColAuto(Job,cleft, 23.0, Gcgap, 'Narration', jtLeft);

    Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Debit',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
    AddColAuto(Job,cleft, 1.0, Gcgap, '', jtLeft);
    Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Credit',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

    //Add Footers
    AddCommonFooter(Job);

    Job.Generate(aDest, Self);

  finally
    FreeAndNil(Job);
  end;
end;

//------------------------------------------------------------------------------
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

    if params.SortBy = csDateEffective then
    begin
     //csDateEffective;
     TravMgr.OnEnterAccount := LE_EnterAccount;
     TravMgr.OnExitAccount  := LE_ExitAccount;
     TravMgr.OnEnterEntry   := LE_EnterEntry;
    end
    else
    begin
     //csDatePresented
     TravMgr.OnEnterAccount := LE_EnterAccount_Pres;
     TravMgr.OnExitAccount  := LE_ExitAccount_Pres;
     TravMgr.OnEnterEntry   := LE_EnterEntry_Pres;
    end;

    TravMgr.OnExitEntry       := LE_ExitEntry;
    TravMgr.OnEnterDissection := LE_EnterDissect;

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
procedure TListJournalsReport.PutNotes(aNotes: string);
var
  NoteIndex, ColWidth, OldWidth, MaxNotesLines : Integer;
  ColsToSkip : integer;
  NotesList : TStringList;
begin
  if params.WrapNarration then
    MaxNotesLines := 10
  else
    MaxNotesLines := 1;

  if (aNotes = '') then
    SkipColumn
  else
  begin
    NotesList  := TStringList.Create;
    try
      NotesList.Text := aNotes;

      // Remove blank lines
      NoteIndex := 0;
      while NoteIndex < NotesList.Count do
      begin
        if NotesList[NoteIndex] = '' then
          NoteSList.Delete(NoteIndex)
        else
          Inc(NoteIndex);
      end;

      if NotesList.Count = 0 then
      begin
        SkipColumn;
        Exit;
      end;

      ColsToSkip := CurrDetail.Count;
      NoteIndex := 0;
      repeat
        ColWidth := RenderEngine.RenderColumnWidth(CurrDetail.Count, NotesList[ NoteIndex]);
        if (ColWidth < Length(NotesList[NoteIndex])) then
        begin
          //line needs to be split
          OldWidth := ColWidth; //store
          while (ColWidth > 0) and (NotesList[NoteIndex][ColWidth] <> ' ') do
            Dec(ColWidth);
          if (ColWidth = 0) then
            ColWidth := OldWidth; //unexpected!
          NotesList.Insert(NoteIndex + 1, Copy(NotesList[NoteIndex], ColWidth + 1, Length(NotesList[NoteIndex]) - ColWidth + 1));
          NotesList[NoteIndex] := Copy(NotesList[NoteIndex], 1, ColWidth);
        end;
        PutString( NotesList[ NoteIndex]);
        Inc( NoteIndex);
        //decide if need to call renderDetailLine
        if ( NoteIndex < notesList.Count) and ( NoteIndex < MaxNotesLines) then
        begin
          RenderDetailLine(False);
          //skip all other fields (reuse ColWidth)
          for ColWidth := 1 to ColsToSkip do
            SkipColumn;
        end;
      until ( NoteIndex >= NotesList.Count) or ( NoteIndex >= MaxNotesLines);
    finally
      FreeAndNil(NotesList);
    end;
  end;
end;

//------------------------------------------------------------------------------
// Outputs Narration and Notes columns but wraps text onto multiple lines
// if need be.
procedure TListJournalsReport.PutNarrationNotes(aJob: TBKReport; aNarration, aNotes : string; aShowBal: Boolean; aBal: Money);
const
  MaxLinesAllowed = 10;
var
  NotesList : TStringList;
  NarrList : TStringList;
  NoteLines, NarrLines : Integer;
  MaxLines : Integer;
  ColsToSkip, i, j : Integer;
begin
  NarrList := TStringList.Create;
  NotesList := TStringList.Create;
  try
    ColsToSkip := CurrDetail.Count;
    NarrList.Text := aNarration;
    NotesList.Text := aNotes;
    NarrLines := SplitLine(CurrDetail.Count, NarrList);
    NoteLines := SplitLine(Pred(Columns.ItemCount), NotesList);//notes is always the last column
    if (NarrLines > 1) and (not params.WrapNarration) then
      NarrLines := 1;
    if (NoteLines > 1) and (not params.WrapNarration) then
      NoteLines := 1;

    NoteLines := 0;

    MaxLines := NarrLines;
    if (NoteLines > NarrLines) then
      MaxLines := NoteLines;
    if (MaxLines > MaxLinesAllowed) then
      MaxLines := MaxLinesAllowed;

    if (MaxLines = 0) then
    begin
      SkipColumn;
      SkipColumn;
    end else
    begin
      for i := 0 to MaxLines-1 do
      begin
        if (i < NarrLines) then
          PutString(NarrList[i])
        else
          SkipColumn;
        {if params.ShowBalance then
        begin
          if aShowBal and (i = 0) then
            PutMoney(aBal)
          else
            SkipColumn;
        end;  }
        if (i < NoteLines) then
          PutString(NotesList[i])
        else
          SkipColumn;
        if (i < MaxLines-1) then
        begin
          RenderDetailLine(False);
          j := ColsToSkip;
          while (j > 0) do
          begin
            SkipColumn;
            Dec(j);
          end;
        end;
      end;
    end;
  finally
    FreeAndNil(NotesList);
    FreeAndNil(NarrList);
  end;
end;

//------------------------------------------------------------------------------
function TListJournalsReport.SplitLine(aColIdx: Integer; var aTextList: TStringList) : Integer;
const
  MaxLines = 10;
var
  j, ColWidth, OldWidth : Integer;
begin
  j := 0;
  while j < aTextList.Count do
  begin
    if aTextList[j] = '' then
      aTextList.Delete(j)
    else
      Inc(j);
  end;
  if (aTextList.Count = 0) then
    Result := 0
  else
  begin
    j := 0;
    repeat
      ColWidth := RenderEngine.RenderColumnWidth(aColIdx, aTextList[ j]);
      if (ColWidth < Length(aTextList[j])) then
      begin
        //line needs to be split
        OldWidth := ColWidth; //store
        while (ColWidth > 0) and (aTextList[j][ColWidth] <> ' ') do
          Dec(ColWidth);
        if (ColWidth = 0) then
          ColWidth := OldWidth; //unexpected!
        aTextList.Insert(j + 1, Copy(aTextList[j], ColWidth + 1, Length(aTextList[j]) - ColWidth + 1));
        aTextList[j] := Copy(aTextList[j], 1, ColWidth);
      end;
      Inc( j);
    until ( j >= aTextList.Count) or ( j >= MaxLines);
    Result := aTextList.Count;
    if Result > MaxLines then
      Result := MaxLines;
  end;
end;

end.
