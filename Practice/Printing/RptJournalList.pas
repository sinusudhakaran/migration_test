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
  protected
    procedure LoadFromClient(aValue : TClientObj); override;
    procedure SaveToClient(aValue : TClientObj); override;
    procedure ReadFromNode(aValue : IXMLNode); override;
    procedure SaveToNode(aValue : IXMLNode); override;
  public
    JournalOnly : boolean;
    SortBy      : byte;
    Include     : byte;
    TwoColumn   : boolean;
    ShowBalance : boolean;
    ShowNotes   : boolean;
    WrapNarration: Boolean;
    ShowOP      : boolean;
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
  CodeDateDlg,
  bkdateutils,
  WarningMoreFrm,
  InfoMoreFrm,
  NewReportUtils,
  ReportTypes,
  CountryUtils,
  BKHelp;

//------------------------------------------------------------------------------
procedure DoListJournalsReport(aDest : TReportDest;
                               aRptBatch : TReportBase = nil);
//uses two column layout if set for coding report
var
  Job : TListJournalsReport;
  WorkStr : string;
  cleft : Double;
  LParams : TListJournalsParam;
  ExtraWidth : double;  //available if coding style is single col
  HasSomeEntries : Boolean;
  BA : TBank_Account;
  AccountIndex , Button : Integer;
  MONEY_FORMAT : String;
  ISOCodes : string;
  NonBaseCurrency : Boolean;
  Country : Byte;
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
          // Get the Details..

          Lparams.ReportType := ord(REPORT_LIST_JOURNALS);

          // If Batchless.. this is more or less meaningless
          if not EnterPrintDateRangeOptions('List Journals','Enter the starting and finishing date for the journals you want to list.',
                                LParams.FromDate, LParams.ToDate, BKH_List_journals, true,
                                [], Button, LParams, LParams.WrapNarration, NonBaseCurrency, True, False,[btCashJournals..btStockBalances]) then exit;
          // Is a bid odd..
          LParams.TwoColumn := (LParams.Client.clFields.clCoding_Report_Style = rsTwoColumn);
          LParams.SortBy := csDateEffective; // Just to be sure...
          Lparams.Include :=  esAllEntries;
          LParams.ShowNotes := False;
          LParams.ShowBalance := False;

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

      Job := TListJournalsReport.Create(ReportTypes.rptListings);
      job.Params := LParams;
      try
        if not job.Params.ShowNotes then
        begin
          Job.LoadReportSettings(UserPrintSettings,
            Job.Params.MakeRptName(Report_List_Names[REPORT_LIST_ENTRIES]));
          job.Params.JournalOnly := false;
        end
        else
        begin
          Job.LoadReportSettings(UserPrintSettings,
             Job.Params.MakeRptName(Report_List_Names[Report_List_Entries_With_Notes]));
          Job.Params.JournalOnly := false;
        end;


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

        if not Job.Params.ShowNotes then
          AddJobHeader(Job,siTitle,'LIST ENTRIES '+WorkStr, true)
        else
          AddJobHeader(Job,siTitle,'LIST ENTRIES (incl Notes) '+WorkStr, true);

        if (Job.Params.SortBy <> csDateEffective) then
          WorkStr := 'BY DATE PRESENTED'
        else
          WorkStr := 'BY DATE EFFECTIVE';

        if (Job.Params.Include = esAllEntries) then
          WorkStr := WorkStr + ', ALL ENTRIES'
        else
          WorkStr := WorkStr + ', UNCODED/INVALIDLY CODED ENTRIES';

        AddJobHeader(Job,siSubtitle,WorkStr,true);

        AddJobHeader(Job,siSubTitle,'',true);
        //Build the columns
        Country := Job.Params.Client.clFields.clCountry;
        if not Job.Params.ShowNotes then
        begin
          {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
          CLeft := Gcleft;

          //extra 10% if available if not showing two columns
          ExtraWidth := 0.0;
          case Country of
            whNewZealand : Begin
              if not Job.Params.ShowBalance then
                ExtraWidth := ExtraWidth + 3.0;
              if not Job.Params.TwoColumn then
                ExtraWidth := ExtraWidth + 3.0;

              AddColAuto(Job,cleft,2.7 ,Gcgap,'Tfr',jtLeft);
              AddColAuto(Job,cleft,6.3 ,Gcgap, 'Date'     , jtLeft);
              AddColAuto(Job,cleft,10 + ExtraWidth ,Gcgap, 'Reference', jtLeft);
              AddColAuto(Job,cleft,9.0 + ExtraWidth ,Gcgap, 'Analysis' , jtLeft);
              AddColAuto(Job,cleft,8.0 ,Gcgap, 'Account'  , jtLeft);

              if Job.Params.TwoColumn then  {these should be totalled on}
              begin
                Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
              end
              else
                Job.AmountCol := AddFormatColAuto(Job,cleft,11.0 + Gcgap,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

              Job.TaxCol := AddFormatColAuto( Job, cLeft, 8, Gcgap, 'GST', jtRight,MONEY_FORMAT,MONEY_FORMAT, true);

              if Job.Params.ShowOp then
              begin
                AddColAuto(Job,cleft,14.0 + ExtraWidth ,Gcgap,'Other Party',jtLeft);
                AddColAuto(Job,cleft,9.0 + ExtraWidth,Gcgap,'Particulars',jtLeft);
              end
              else
                AddColAuto(Job,cleft,23 + ( 2 * ExtraWidth),Gcgap,'Narration',jtLeft);

              if Job.Params.ShowBalance then
                Job.BalanceCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);
            end;
            whAustralia, whUK :
            Begin
              if not Job.Params.ShowBalance then
                ExtraWidth := ExtraWidth + 4.0;
              if not Job.Params.TwoColumn then
                ExtraWidth := ExtraWidth + 4.0;

              AddColAuto(Job,cleft,2.7 ,Gcgap,'Tfr',jtLeft);
              AddColAuto(Job,cleft,6.3 ,Gcgap,'Date', jtLeft);
              AddColAuto(Job,cleft,10 + ExtraWidth ,Gcgap,'Reference',jtLeft);
              AddColAuto(Job,cleft,8.0,Gcgap,'Account',jtLeft);

              if Job.Params.TwoColumn then  {these should be totalled on}
              begin
                Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
              end
              else
                Job.AmountCol := AddFormatColAuto(Job,cleft,11.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

              Job.TaxCol := AddFormatColAuto( Job, cLeft, 8, Gcgap, Localise( Country, 'GST') , jtRight,MONEY_FORMAT,MONEY_FORMAT, true);
              AddColAuto(Job,cLeft, 23.8 + ( 2 * ExtraWidth ),Gcgap, 'Narration',jtLeft);

              if Job.Params.ShowBalance then
                Job.BalanceCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);
            end;
          end; { Case Country }
        end
        else
        begin
          //do list entries report with notes, this report is landscape by default
          {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
          CLeft := GcLeft;
          ExtraWidth := 0.0;

          case Country of
            whNewZealand : begin
              if not Job.Params.ShowBalance then
                ExtraWidth := ExtraWidth + 8.6/5;
              if not Job.Params.TwoColumn then
                ExtraWidth := ExtraWidth + 8.6/5;

              AddColAuto(Job,cleft,2.0 ,GcGap,'Tfr',jtLeft);
              AddColAuto(Job,cleft,4.5 ,GcGap, 'Date'     , jtLeft);
              AddColAuto(Job,cleft,8.0 + ExtraWidth ,GcGap, 'Reference', jtLeft);
              AddColAuto(Job,cleft,7.0 + ExtraWidth ,GcGap, 'Analysis' , jtLeft);
              AddColAuto(Job,cleft,7.0 ,Gcgap, 'Account'  , jtLeft);

              if Job.Params.TwoColumn then  {these should be totalled on}
              begin
                Job.CRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                Job.DRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
              end
              else
                Job.AmountCol := AddFormatColAuto(Job,cleft,8.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

              if Job.Params.ShowOp then begin
                 AddColAuto(Job,cleft,10.0 + ExtraWidth,Gcgap,'Other Party',jtLeft);
                 AddColAuto(Job,cleft,8.0 + ExtraWidth,Gcgap,'Particulars',jtLeft);
              end
              else
                 AddColAuto(Job,cleft,18 + ( 2 * ExtraWidth),Gcgap,'Narration',jtLeft);

              if Job.Params.ShowBalance then
                Job.BalanceCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);

              AddColAuto(Job,cLeft, 25 + ExtraWidth, Gcgap, 'Notes', jtLeft);
            end;
            whAustralia, whUK : begin
              if not Job.Params.ShowBalance then
                ExtraWidth := ExtraWidth + 3.0;
              if not Job.Params.TwoColumn then
                ExtraWidth := ExtraWidth + 3.0;

              AddColAuto(Job,cleft,2.0 ,Gcgap,'Tfr',jtLeft);
              AddColAuto(Job,cleft,4.5 ,Gcgap,'Date', jtLeft);
              AddColAuto(Job,cleft,8.0 + ExtraWidth ,Gcgap,'Reference',jtLeft);
              AddColAuto(Job,cleft,6.2,Gcgap,'Account',jtLeft);

              if Job.Params.TwoColumn then  {these should be totalled on}
              begin
                Job.CRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Withdrawals',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
                Job.DRAmountCol := AddFormatColAuto(Job,cLeft,8.0,Gcgap,'Deposits',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
              end
              else
                Job.AmountCol := AddFormatColAuto(Job,cleft,8.0,Gcgap,'Amount',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);

              Job.TaxCol := AddFormatColAuto( Job, cLeft, 7, Gcgap, Localise( Country, 'GST' ), jtRight,MONEY_FORMAT,MONEY_FORMAT, true);
              AddColAuto(Job,cLeft, 19 + ( 2 * ExtraWidth ),Gcgap, 'Narration',jtLeft);

              if Job.Params.ShowBalance then
                Job.BalanceCol := AddFormatColAuto(Job,cLeft,9.0 ,Gcgap,'Balance',jtRight,BAL_FORMAT,BAL_FORMAT,false);

              AddColAuto(Job,cLeft, 23 ,Gcgap ,'Notes', jtLeft);
            end;
          end; { Case Country }
        end;

        //Add Footers
        AddCommonFooter(Job);

        Job.Generate(aDest, Lparams);

        if LParams.BatchRun then
          aRptBatch.RunResult := 'Ok';

      finally
        FreeAndNil(Job);
      end;

    until LParams.RunExit(aDest);

  finally
    FreeAndNil(lParams);
  end;
end;

{ TListEntriesParam }
//------------------------------------------------------------------------------
procedure TListJournalsParam.LoadFromClient(aValue: TClientObj);
begin
  inherited;

  SortBy        := aValue.clExtra.ceList_Entries_Sort_Order;
  Include       := aValue.clExtra.ceList_Entries_Include;
  TwoColumn     := aValue.clExtra.ceList_Entries_Two_Column;
  ShowBalance   := aValue.clExtra.ceList_Entries_Show_Balance;
  ShowNotes     := aValue.clExtra.ceList_Entries_Show_Notes;
  WrapNarration := aValue.clExtra.ceList_Entries_Wrap_Narration;
  ShowOp        := aValue.clExtra.ceList_Entries_Show_Other_Party;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.SaveToClient(aValue: TClientObj);
begin
  aValue.clExtra.ceList_Entries_Sort_Order       := SortBy;
  aValue.clExtra.ceList_Entries_Include          := Include;
  aValue.clExtra.ceList_Entries_Two_Column       := TwoColumn;
  aValue.clExtra.ceList_Entries_Show_Balance     := ShowBalance;
  aValue.clExtra.ceList_Entries_Show_Notes       := ShowNotes;
  aValue.clExtra.ceList_Entries_Wrap_Narration   := WrapNarration;
  aValue.clExtra.ceList_Entries_Show_Other_Party := ShowOp;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.ReadFromNode(aValue: IXMLNode);
begin
  if SameText( csNames[csDateEffective],GetBatchText('Sort', csNames[csDateEffective])) then
    SortBy := csDateEffective
  else
    SortBy := csDatePresented;

  if SameText( esNames[esAllEntries],GetBatchText('Include', esNames[esAllEntries]))then
    Include := esAllEntries
  else
    Include := esUncodedOnly;

  ShowOp        := GetBatchBool('Show_Other_Party',ShowOp);
  ShowNotes     := GetBatchBool('Show_Notes',ShowNotes);
  TwoColumn     := GetBatchBool('Show_Two_Columns',TwoColumn);
  ShowBalance   := GetBatchBool('Show_Balance',ShowBalance);
  WrapNarration := GetBatchBool('Wrap_Naration',WrapNarration);

  GetBatchAccounts;
end;

//------------------------------------------------------------------------------
procedure TListJournalsParam.SaveToNode(aValue: IXMLNode);
begin
  inherited;

  setBatchText('Sort',csNames[SortBy]);
  SetBatchText('Include',esNames[Include]);
  SetBatchBool('Show_Other_Party',ShowOp);
  SetBatchBool('Show_Notes',ShowNotes);
  SetBatchBool('Show_Two_Columns',TwoColumn);
  SetBatchBool('Show_Balance',ShowBalance);
  SetBatchBool('Wrap_Naration',WrapNarration);

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

    if params.Include = esUncodedOnly then
      TravMgr.SelectionCriteria := TravList.twAllUncoded
    else
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

    if params.JournalOnly then
    begin
      for AccountIndex := 0 to params.AccountList.Count - 1 do
      begin
        BankAcc := TBank_Account(params.AccountList[AccountIndex]);

        if BankAcc.IsaJournalAccount then
          TravMgr.TraverseAccount(BankAcc, params.Fromdate, params.ToDate);
      end;
    end
    else
    begin
      TravMgr.TraverseAllAccounts(params.Fromdate, params.Todate);
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

    if not params.ShowNotes then
      NoteLines := 0;

    MaxLines := NarrLines;
    if (NoteLines > NarrLines) then
      MaxLines := NoteLines;
    if (MaxLines > MaxLinesAllowed) then
      MaxLines := MaxLinesAllowed;

    if (MaxLines = 0) then
    begin
      SkipColumn;
      if params.ShowBalance then
      begin
        if aShowBal then
          PutMoney(aBal)
        else
          SkipColumn;
      end;
      SkipColumn;
    end else
    begin
      for i := 0 to MaxLines-1 do
      begin
        if (i < NarrLines) then
          PutString(NarrList[i])
        else
          SkipColumn;
        if params.ShowBalance then
        begin
          if aShowBal and (i = 0) then
            PutMoney(aBal)
          else
            SkipColumn;
        end;
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
