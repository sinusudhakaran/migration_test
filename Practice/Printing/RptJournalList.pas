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
    procedure EnterAccount(Sender : TObject);
    procedure EnterEntry(Sender : Tobject);
    procedure EnterDissection(Sender : Tobject);

    procedure ExitEntry(Sender : Tobject);

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
  JournalOptionsDlg,
  BKDEFS,
  imagesfrm,
  Graphics,
  ReportImages,
  GenUtils,
  BAutils;

Const
  TRANSFERED_IMG = 'Transfered_Icon';
  LOCKED_IMG = 'Locked_Icon';
  TRANSandLOCKED_IMG = 'TransAndLocked_Icon';

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

    {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
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

    TravMgr.OnEnterEntryExt := EnterEntry;
    TravMgr.OnExitEntryExt := ExitEntry;
    TravMgr.OnEnterDissectionExt := EnterDissection;

    {if params.SortBy = csDateEffective then
    begin
     //csDateEffective;
     //TravMgr.OnEnterAccountExt := EnterAccount;
     TravMgr.OnEnterEntryExt := EnterEntry;
     TravMgr.OnEnterDissectionExt := EnterDissection;


     TravMgr.OnEnterAccount := EnterAccount;
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
    TravMgr.OnEnterDissection := LE_EnterDissect;}

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

//------------------------------------------------------------------------------
function IsBankAccountIncluded(aAccList : TList; aBankAccountNumber: String): Boolean;
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
function HasTransactions(StartDate, EndDate: Integer; BA: TBank_Account): Boolean;
var
  TranIndex: Integer;
  Trans: pTransaction_Rec;
begin
  for TranIndex := 0 to Pred(BA.baTransaction_List.ItemCount) do
  begin
    Trans := BA.baTransaction_List.Transaction_At(TranIndex);
    if (Trans.txDate_Effective >= StartDate) and
       (Trans.txDate_Effective <= EndDate) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

//------------------------------------------------------------------------------
procedure TListJournalsReport.EnterAccount(Sender : TObject);
var
  Mgr : TTravManagerWithNewReport;
  Rpt : TListJournalsReport;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if (not IsBankAccountIncluded(Rpt.Params.AccountList, Mgr.Bank_Account.baFields.baBank_Account_Number)) then
    Exit;

  if not HasTransactions(Rpt.Params.Fromdate, Rpt.Params.Todate, Mgr.Bank_Account) then
    Exit;

  Mgr.NumOfAccounts := Mgr.NumOfAccounts + 1;
  if (Mgr.NumOfAccounts > 2) and Rpt.ReportTypeParams.NewPageforAccounts then
    Rpt.ReportNewPage;

  Rpt.RenderTitleLine( Mgr.Bank_Account.Title );

  if (Mgr.Bank_Account.IsAForexAccount) and
     ( Rpt.TaxCol <> NIL ) then
    Rpt.TaxCol.FormatString := Rpt.Params.Client.FmtMoneyStr;

  if ( Rpt.CRAmountCol  <> NIL ) then
    Rpt.CRAmountCol.FormatString := Mgr.Bank_Account.FmtMoneyStr;
  if ( Rpt.DRAmountCol  <> NIL ) then
    Rpt.DRAmountCol.FormatString := Mgr.Bank_Account.FmtMoneyStr;

  //if (Mgr.Bank_Account.baFields.baAccount_Type = btBank) then
  //begin
    {GetBalances( Mgr.Bank_Account,
                 Rpt.Params.FromDate,
                 Rpt.Params.Todate,
                 Mgr.OpBalAtBank,
                 Mgr.ClBalAtBank,
                 Mgr.OpBalInSystem,
                 Mgr.ClBalInSystem );}

   // If Mgr.OpBalInSystem <> Unknown then
  //  Begin
       //Mgr.Bank_Account.baFields.baTemp_Balance := Mgr.OpBalInSystem;

           {AddColAuto(Job,cleft, 5.3, Gcgap, 'Status', jtLeft);
    AddColAuto(Job,cleft, 6.3, Gcgap, 'Date', jtLeft);
    AddColAuto(Job,cleft, 10 + ExtraWidth, Gcgap, 'Reference', jtLeft);
    AddColAuto(Job,cleft, 8.0, Gcgap, 'Account'  , jtLeft);
    AddColAuto(Job,cleft, 20.0, Gcgap, 'A/c Desc', jtLeft);
    AddColAuto(Job,cleft, 23.0, Gcgap, 'Narration', jtLeft);

    Job.DRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Debit',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);
    AddColAuto(Job,cleft, 1.0, Gcgap, '', jtLeft);
    Job.CRAmountCol := AddFormatColAuto(Job,cLeft,11.0,Gcgap,'Credit',jtRight,NUMBER_FORMAT,MONEY_FORMAT,true);}

       Rpt.SkipColumn;
       Rpt.SkipColumn;
       Rpt.SkipColumn;
       Rpt.PutString('Account enter');
       Rpt.SkipColumn;
       Rpt.SkipColumn;
       Rpt.SkipColumn;
       Rpt.SkipColumn;
       Rpt.SkipColumn;
   // End;

       {AddPictureToReportImageList( Transfered, TRANSFERED_IMG, 8, 8);
       AddPictureToReportImageList( Locked, LOCKED_IMG, 8, 8);
       AddPictureToReportImageList( TransAndLocked, TRANSandLOCKED_IMG, 8, 8);

                     if (pT^.txDate_Transferred > 0) and (pT^.txLocked) then
               data := pointer(ImagesFrm.AppImages.imgTickLock.Picture.Bitmap)
              else if pT^.txDate_Transferred > 0 then
                data := pointer(ImagesFrm.AppImages.imgTick.Picture.Bitmap)
              else if pT^.txLocked then
                data := pointer(ImagesFrm.AppImages.imgLock.Picture.Bitmap);}


       //Rpt.PutString(IMGFIELD + '' + '>');

       {case Rpt.Params.Client.clFields.clCountry of
          whNewZealand :
             Begin
                Rpt.SkipColumn;   //trx
                Rpt.PutString( bkDate2Str (D1) );
                Rpt.PutString( 'Op Bal' );
                Rpt.SkipColumn;
                Rpt.PutString( Bank_Account.baFields.baContra_Account_Code );

                If TwoColumn then
                Begin
                   If OpBalInSystem >= 0 then
                   Begin
                      PutMoneyDontAdd( OpBalInSystem );
                      SkipColumn;
                   end
                   else
                   Begin
                      SkipColumn;
                      PutMoneyDontAdd( OpBalInSystem );
                   end;
                end
                else
                   PutMoneyDontAdd( OpBalInSystem );

                if ShowOP then
                begin
                  SkipColumn;   //other
                  SkipColumn;   //part
                end
                else
                  SkipColumn;   //narr

                if ShowBalance then
                  SkipColumn;

                if ShowNotes then
                  SkipColumn;   //notes

             end;
          whAustralia, whUK :
             Begin
                SkipColumn; //trx
                PutString( bkDate2Str ( D1 ) );
                PutString( 'Op Bal' );
                PutString( Bank_Account.baFields.baContra_Account_Code );

                If TwoColumn then
                Begin
                   If OpBalInSystem >= 0 then
                   Begin
                      PutMoneyDontAdd( OpBalInSystem );
                      SkipColumn;
                   end
                   else
                   Begin
                      SkipColumn;
                      PutMoneyDontAdd( OpBalInSystem );
                   end;
                end
                else
                   PutMoneyDontAdd( OpBalInSystem );

                SkipColumn; //gst
                SkipColumn; //narration

                if ShowBalance then
                  SkipColumn;

                if ShowNotes then
                  SkipColumn;   //notes
             end;
       end; // Case clCountry}
       Rpt.RenderDetailLine;
    {end
    else
      Mgr.Bank_Account.baFields.baTemp_Balance := Unknown;}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_ExitAccount(Sender : TObject);
{var
   Rpt : TListEntriesReport;
   Mgr : TTravManagerWithNewReport;}
begin
   {Mgr := TTravManagerWithNewReport(Sender);
   Rpt := TListEntriesReport( Mgr.ReportJob );
   With  Mgr, Rpt, Rpt.Params do
   Begin
      if (not JournalOnly) and (not LE_IsBankAccountIncluded(ReportJob, Mgr)) then exit;

      if not LE_HasTransactions(Fromdate, ToDate, Bank_Account) then exit;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .FormatString := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .FormatString := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .FormatString := Bank_Account.FmtMoneyStr;

      if ( CRAmountCol  <> NIL ) then  CRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( DRAmountCol  <> NIL ) then  DRAmountCol .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( AmountCol    <> NIL ) then  AmountCol   .TotalFormat := Bank_Account.FmtMoneyStr;
      if ( BalanceCol   <> NIL ) then  BalanceCol  .TotalFormat := Bank_Account.FmtMoneyStr;
//      if ( CRAmountCol  <> NIL ) then  CRAmountCol .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( DRAmountCol  <> NIL ) then  DRAmountCol .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( AmountCol    <> NIL ) then  AmountCol   .TotalFormat := Bank_Account.FmtMoneyStrBrackets;
//      if ( BalanceCol   <> NIL ) then  BalanceCol  .TotalFormat := Bank_Account.FmtMoneyStrBrackets;

      RenderDetailSubTotal('');

      if ( Bank_Account.baFields.baAccount_Type = btBank)  then
      begin
        If OpBalInSystem <> Unknown then
        Begin
           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( '' );

                    PutString( Bank_Account.baFields.baContra_Account_Code);

                    If TwoColumn then
                    Begin
                       If ClBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalInSystem );

                    if ShowOP then
                    begin
                      SkipColumn;
                      SkipColumn;
                    end
                    else
                      SkipColumn;

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;
                 end;
              whAustralia, whUK :
                 Begin
                    SkipColumn;
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal' );
                    PutString( Bank_Account.baFields.baContra_Account_Code);

                    If TwoColumn then
                    Begin
                       If ClBalInSystem >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalInSystem );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalInSystem );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalInSystem );

                    SkipColumn;
                    SkipColumn;

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;
                 end;
           end;

           RenderDetailLine;
           case Client.clFields.clCountry of
              whNewZealand :
                 Begin
                    SkipColumn;
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal At Bank' );
                    PutString( '' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    if ShowOP then
                    begin
                      SkipColumn;
                      SkipColumn;
                    end
                    else
                      SkipColumn;

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;

                 end;

              whAustralia, whUK :
                 Begin
                    SkipColumn;
                    If D2 < MaxLongInt then
                       PutString( bkDate2Str ( D2 ) )
                    else
                       PutString( '' );
                    PutString( 'Cl Bal At Bank' );
                    PutString( Bank_Account.baFields.baContra_Account_Code );

                    If TwoColumn then
                    Begin
                       If ClBalAtBank >= 0 then
                       Begin
                          PutMoneyDontAdd( ClBalAtBank );
                          SkipColumn;
                       end
                       else
                       Begin
                          SkipColumn;
                          PutMoneyDontAdd( ClBalAtBank );
                       end;
                    end
                    else
                       PutMoneyDontAdd( ClBalAtBank );

                    SkipColumn;
                    SkipColumn;

                    if ShowBalance then
                      SkipColumn;

                    if ShowNotes then
                      SkipColumn;
                 end;
           end;
           RenderDetailLine;
        end;
      end;
   end;}
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TListJournalsReport.EnterEntry(Sender : Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Bal: Money;
  ShowBal: Boolean;
  Rpt : TListJournalsReport;
  OldFontStyle : TFontStyles;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if (not IsBankAccountIncluded(Rpt.Params.AccountList, Mgr.Bank_Account.baFields.baBank_Account_Number)) then
    Exit;

  if (Mgr.Transaction^.txDate_Transferred > 0) and (Mgr.Transaction^.txLocked) then
    Rpt.PutImage(TRANSandLOCKED_IMG, 150)
  else if (Mgr.Transaction^.txDate_Transferred > 0) then
    Rpt.PutImage(TRANSFERED_IMG, 150)
  else if (Mgr.Transaction^.txLocked) then
    Rpt.PutImage(LOCKED_IMG, 150)
  else
    Rpt.SkipColumn;

  PutString( bkDate2Str ( Mgr.Transaction^.txDate_Effective ) );
  PutString( GetFormattedReference( Mgr.Transaction));
  PutStringMultipleColumns( Mgr.Transaction^.txGL_Narration, 6);

  OldFontStyle := RenderFont.Style;
  try
    RenderFont.Style := [fsBold];
    RenderDetailLine(true);
  finally
    RenderFont.Style := OldFontStyle;
  end;

  RenderEmptyLine;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TListJournalsReport.ExitEntry(Sender: Tobject);
begin
  RenderDetailGrandTotal('');
  RenderEmptyLine;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TListJournalsReport.EnterDissection(Sender: Tobject);
var
  Mgr : TTravManagerWithNewReport;
  Bal: Money;
  ShowBal: Boolean;
  Rpt : TListJournalsReport;
begin
  Mgr := TTravManagerWithNewReport(Sender);
  Rpt := TListJournalsReport( Mgr.ReportJob );

  if (not IsBankAccountIncluded(Rpt.Params.AccountList, Mgr.Bank_Account.baFields.baBank_Account_Number)) then
    Exit;

  Rpt.SkipColumn;
  Rpt.SkipColumn;

  PutString(Mgr.Dissection^.dsReference);
  PutString(Mgr.Dissection^.dsAccount);
  PutString(Rpt.Params.Client.clChart.FindDesc(Mgr.Dissection^.dsAccount));
  PutString(Mgr.Dissection^.dsGL_Narration);

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

  RenderDetailLine;
end;

end.
