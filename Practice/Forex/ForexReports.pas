unit ForexReports;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

uses
  ReportDefs, PrintMgrObj, FaxParametersObj, OvcDate, moneydef, Classes,
    UBatchBase;

procedure DoListForexEntriesReport( Dest: TReportDest; RptBatch: TReportBase =
  nil ) ;

// ----------------------------------------------------------------------------
implementation
// ----------------------------------------------------------------------------

uses
  omniXML, CodeDateAccountDlg, NewReportObj, RepCols, TravList, SysUtils,
  bkConst, baObj32, bkDateUtils, GenUtils, Globals, RptParams, BKHelp, WarningMoreFrm, ReportTypes,
  NewReportUtils, baUtils, MoneyUtils, ForexHelpers;

Const
  NUMBER_FORMAT = '#,##0.00;(#,##0.00);-';
  MONEY_FORMAT = '#,##0.00;-#,##0.00;-';

type
  ForexParams = class (TRPTParameters)
  protected
     procedure ReadFromNode (Value : IXMLNode); override;
     procedure SaveToNode   (Value : IXMLNode); override;
  end;

  TListForexEntriesReport = class( TBKReport )
  private
    Params: ForexParams;
  protected
    LocalAmountCol         : TReportColumn;
    ForexAmountCol         : TReportColumn;
    RateCol                : TReportColumn;
    procedure BKPrint; override;
  end;

  TForexTravManager = class( TTravManager )
    OpForexBalAtBank       : Money;
    ClForexBalAtBank       : Money;
    OpForexBalInSystem     : Money;
    ClForexBalInSystem     : Money;
    OpLocalBalAtBank       : Money;
    ClLocalBalAtBank       : Money;
    OpLocalBalInSystem     : Money;
    ClLocalBalInSystem     : Money;
    CRForexTotal           : Money;
    DRForexTotal           : Money;
    CRLocalTotal           : Money;
    DRLocalTotal           : Money;
    ReportJob              : TBKReport;
  end;

  // ----------------------------------------------------------------------------

  // Is current bank account selected in the Advanced tab
  // Returns True if selected

function LE_IsBankAccountIncluded( ReportJob: TBkReport; Mgr: TForexTravManager ) : Boolean;
var
  i: Integer;
  BA: TBank_Account;
begin
  Result := False;
  for i := 0 to Pred( TListForexEntriesReport( ReportJob ).Params.AccountList.Count ) do
  begin
    BA := TListForexEntriesReport( ReportJob ) .Params.AccountList[ i ] ;
    if ( BA.baFields.baBank_Account_Number = Mgr.Bank_Account.baFields.baBank_Account_Number ) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

// ----------------------------------------------------------------------------

procedure LE_EnterAccount( Sender: TObject ) ;
var
  Mgr           : TForexTravManager;
  OpDate        : Integer;
  S             : String;
  Rate          : Extended;
  Rpt           : TListForexEntriesReport;
  BCode, CCode  : String[3];
begin
  Mgr := TForexTravManager( Sender ) ;
  Rpt := TListForexEntriesReport( Mgr.ReportJob );
  with Mgr, Rpt, Rpt.Params do
  begin
    if ( Bank_Account.baFields.baAccount_Type <> btBank ) then
       exit;
    if not LE_IsBankAccountIncluded( ReportJob, Mgr ) then
       exit;
    If not Bank_Account.IsAForexAccount then
       exit;
    if not Bank_Account.HasTransactionsWithin( Fromdate, Todate ) then
       exit;

    With Client.clFields, Bank_Account.baFields do
    Begin
      BCode := baCurrency_Code;
      CCode := Client.clExtra.ceLocal_Currency_Code;
//      if Bank_Account.baForex_Info = NIL then
//      Begin
//        S := Format( 'Client %s, Bank Account %s : Unable to find an exchange rate currency data source for converting %s to %s with the description %s (%s)',
//          [ clCode, baBank_Account_Number, BCode, CCode, baDefault_Forex_Description, baDefault_Forex_Source ] );
//        Raise Exception.CreateFmt( '%s - %s : %s', [ 'ForexReports', 'LE_EnterAccount_Pres', S ] );
//      end;
      ForexAmountCol.FormatString  := Bank_Account.FmtMoneyStr;
      LocalAmountCol.FormatString  := Client.FmtMoneyStr;
    end;

    NumOfAccounts := NumOfAccounts + 1;

    if ( NumOfAccounts > 1 ) and ReportTypeParams.NewPageforAccounts then
      ReportNewPage;

    With Bank_Account.baFields do
    Begin
      RenderTitleLine( Bank_Account.Title );
      RenderTextLine( baDefault_Forex_Description + ' ' + baDefault_Forex_Source );
    End;

    GetBalances( Bank_Account, D1, D2, OpForexBalAtBank, ClForexBalAtBank, OpForexBalInSystem, ClForexBalInSystem );

    OpDate := D1;
    if OpDate = 0 then
       OpDate := Bank_Account.baTransaction_List.FirstPresDate;

    ClForexBalAtBank := OpForexBalAtBank;

    if OpForexBalAtBank <> Unknown then
    begin
      Bank_Account.baFields.baTemp_Balance := OpForexBalAtBank;

      PutString( bkDate2Str( OpDate ) ) ;
      PutString( 'Opening Balance' );
      PutString( Bank_Account.baFields.baContra_Account_Code ) ;
      PutMoneyDontAdd( OPForexBalAtBank );
      Rate := Bank_Account.Default_Forex_Conversion_Rate( OpDate );
      if Rate <> 0.0 then
      Begin
        S := Trim( ForexRate2Str( Rate ) );
        PutString( S );
        OpLocalBalAtBank := Round( OpForexBalAtBank / Rate );
        PutMoneyDontAdd( OpLocalBalAtBank );
      End
      Else
      Begin
        OpLocalBalAtBank := 0;
        SkipColumn;
        SkipColumn;
      end;
      ClLocalBalAtBank := OpLocalBalAtBank;
      RenderDetailLine;
    end
    else
    Begin
      OpLocalBalAtBank := Unknown;
      ClLocalBalAtBank := Unknown;
    End;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_EnterEntry( Sender: TObject ) ;
var
  Mgr     : TForexTravManager;
  S       : String;
begin
  Mgr := TForexTravManager( Sender ) ;
  with Mgr, Mgr.ReportJob, TListForexEntriesReport( ReportJob ),
    TListForexEntriesReport( ReportJob ) .Params,
    Mgr.Transaction^ do
  begin
    if ( Bank_Account.baFields.baAccount_Type <> btBank ) then
       exit;
    If not Bank_Account.IsAForexAccount then
       exit;
    if not LE_IsBankAccountIncluded( ReportJob, Mgr ) then
       exit;

    ForexAmountCol.FormatString  := MONEY_FORMAT;
    LocalAmountCol.FormatString  := MONEY_FORMAT;

    PutString( bkDate2Str( txDate_Presented ) ) ;
    PutString( GetFormattedReference( Mgr.Transaction ) ) ;
    PutString( txAccount ) ;

//    PutMoney( Trunc( txForeign_Currency_Amount ) );
    PutMoney( Trunc( txAmount ) );

    S := Trim( ForexRate2Str( txForex_Conversion_Rate ) );
    if not Mgr.Transaction.Is_Default_Forex_Rate then
       S := S + '*';
    PutString( S );

    PutMoney( Trunc( txAmount ) );

    if ClForexBalAtBank <> Unknown then
//      ClForexBalAtBank := ClForexBalAtBank + txForeign_Currency_Amount;
      ClForexBalAtBank := ClForexBalAtBank + txAmount;

    if ClLocalBalAtBank <> Unknown then
      ClLocalBalAtBank := ClLocalBalAtBank + txAmount;

    RenderDetailLine;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure LE_ExitAccount( Sender: TObject ) ;
var
  Mgr: TForexTravManager;
  ClDate : Integer;
  Rate   : Extended;
  S : String;
  ClForexBalAsLocal : Money;
  ForexGainOrLoss   : Money;
  Rpt : TListForexEntriesReport;
begin
  Mgr := TForexTravManager( Sender );
  Rpt := TListForexEntriesReport( Mgr.ReportJob );
  with Mgr, Rpt, Rpt.Params do
  begin
    if ( Bank_Account.baFields.baAccount_Type <> btBank ) then
       exit;
    If not Bank_Account.IsAForexAccount then
       exit;
    if not LE_IsBankAccountIncluded( ReportJob, Mgr ) then
       exit;

    ForexAmountCol.TotalFormat  := Bank_Account.FmtMoneyStr;
    LocalAmountCol.TotalFormat  := Client.FmtMoneyStr;

    RenderDetailSubTotal( '' );

    if D2 = 0 then ClDate := Bank_Account.baTransaction_List.LastPresDate else ClDate := D2;

    ForexAmountCol.FormatString  := Bank_Account.FmtMoneyStr;
    LocalAmountCol.FormatString  := Client.FmtMoneyStr;

    if ClForexBalAtBank <> Unknown then
    begin
      Rpt.SingleUnderLine;
      PutString( bkDate2Str( ClDate ) ) ;
      PutString( 'Closing Balance' );
      SkipColumn;
      SkipColumn;
      SkipColumn;
      PutMoneyDontAdd( ClLocalBalAtBank );
      RenderDetailLine;
    end;

    ForexGainOrLoss   := Unknown;

    if ClForexBalAtBank <> Unknown then
    begin
      Rate := Bank_Account.Default_Forex_Conversion_Rate( ClDate );
      if Rate <> 0.0 then
      Begin
        ClForexBalAsLocal := Round( ClForexBalAtBank / Rate );
        if ClLocalBalAtBank <> Unknown then
          ForexGainOrLoss := ClForexBalAsLocal - ClLocalBalAtBank;
      end;
    end;

    if ForexGainOrLoss <> Unknown then
    Begin
      PutString( bkDate2Str( ClDate ) ) ;
      PutString( 'Calculated Forex Gain/Loss' );
      SkipColumn;
      SkipColumn;
      SkipColumn;
      PutMoneyDontAdd( ForexGainOrLoss );
      RenderDetailLine;
      Rpt.SingleUnderLine;
    end;

    ForexAmountCol.FormatString  := Bank_Account.FmtMoneyStr;
    LocalAmountCol.FormatString  := Client.FmtMoneyStr;

    if ClForexBalAtBank <> Unknown then
    begin
      PutString( bkDate2Str( ClDate ) ) ;
      PutString( 'Closing Balance' );
      PutString( Bank_Account.baFields.baContra_Account_Code ) ;

      PutMoneyDontAdd( ClForexBalAtBank );

      Rate := Bank_Account.Default_Forex_Conversion_Rate( ClDate );
      if Rate <> 0.0 then
      Begin
        S := Trim( ForexRate2Str( Rate ) );
        PutString( S );
        ClLocalBalAtBank := Round( ClForexBalAtBank / Rate );
        PutMoneyDontAdd( ClLocalBalAtBank );
      End
      Else
      Begin
        ClLocalBalAtBank := 0;
        SkipColumn;
        SkipColumn;
      end;
      RenderDetailLine;
    end
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TListForexEntriesReport.BKPrint;
var
  TravMgr: TForexTravManager;
begin
  TravMgr := TForexTravManager.Create;
  try
    TravMgr.Clear;
    TravMgr.SortType := csDatePresented;
    TravMgr.SelectionCriteria := TravList.twAllEntries;
    TravMgr.ReportJob := Self;
    TravMgr.OnEnterAccount := LE_EnterAccount;
    TravMgr.OnExitAccount := LE_ExitAccount;
    TravMgr.OnEnterEntry := LE_EnterEntry;
    TravMgr.TraverseAllAccounts( params.Fromdate, params.Todate ) ;
  finally
    TravMgr.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoListForexEntriesReport( Dest: TReportDest; RptBatch: TReportBase = nil ) ;
var
  Job: TListForexEntriesReport;
  S: string;
  cleft: Double;
  LParams: ForexParams;

  HasSomeEntries: Boolean;
  BA: TBank_Account;
  i : Integer;
  Dumy: Boolean;
  LCTitle : String;
begin
  LParams := ForexParams.Create(ord(Report_Foreign_Exchange) , MyClient, RptBatch, dPeriod ) ;
  try
    LParams.GetBatchAccounts;
    repeat
      HasSomeEntries := False;
      while not HasSomeEntries do
      begin
        if not lparams.BatchRun then
        begin
          // Get the Details..
          Lparams.ReportType := ord( REPORT_FOREIGN_EXCHANGE ) ;
          LParams.AccountFilter := [btForeign];
          if not EnterPrintDateAccountRange( 'List Foreign Currency Entries',
            'Enter the starting and finishing date for the entries you want to list.',
            [btForeign],
            LParams,
            BKH_List_entries,
            true,
            dumy) then
              exit;
        end;

        if LParams.RunBtn = BTN_SAVE then
        begin
          LParams.RptBatch.Title := Report_List_Names[REPORT_FOREIGN_EXCHANGE];
          lParams.SaveNodeSettings;
          Exit;
        end
        else if ( LParams.BatchRunMode = R_Normal ) then
          LParams.SaveClientSettings;

        case LParams.RunBtn of
          BTN_PRINT   : Dest := rdPrinter;
          BTN_PREVIEW : Dest := rdScreen;
          BTN_FILE    : Dest := rdFile;
          BTN_SAVE    : Dest := rdNone;
        else
          Exit;
        end;

        //check for entries
        HasSomeEntries := False;
        for i := 0 to Pred( LParams.AccountList.Count ) do
        begin
          ba := LParams.AccountList[ i ] ;
          if ba.HasTransactionsWithin( LParams.FromDate, LParams.Todate ) then
          begin
            HasSomeEntries := True;
            Break;
          end;
        end;

        if not HasSomeEntries then
          if LParams.BatchRun then
          begin
            RptBatch.RunResult := 'No Entries in date range , '
              + bkDate2Str( LParams.FromDate ) + ' to ' + bkDate2Str(
                LParams.Todate ) + '.';

            Exit;
            // Was meant to run direct... Just Exit
          end
          else
            HelpfulWarningMsg( 'There are no Entries for this client in the date range , '
              + bkDate2Str( LParams.FromDate ) + ' to ' + bkDate2Str(
                LParams.Todate ) + '.', 0 ) ;
      end; //While HasSomeEntries

      if Dest = rdNone then Continue;

      Job := TListForexEntriesReport.Create( ReportTypes.rptListings ) ;
      job.Params := LParams;
      try
        Job.LoadReportSettings( UserPrintSettings, Job.Params.MakeRptName( Report_List_Names[ REPORT_FOREIGN_EXCHANGE ] ) ) ;

        //Add Headers
        AddCommonHeader( Job ) ;

        S := 'FROM ';
        if Job.Params.FromDate = 0 then
          S := S + 'FIRST'
        else
          S := S + bkDate2Str( Job.Params.FromDate ) ;
        S := S + ' TO ';
        if Job.Params.ToDate = MaxLongInt then
          S := S + 'LAST'
        else
          S := S + bkDate2Str( Job.Params.ToDate ) ;

        AddJobHeader( Job, siTitle, 'LIST FOREIGN CURRENCY ENTRIES ' + S, true );


        S := 'BY DATE PRESENTED, ALL ENTRIES';
        AddJobHeader( Job, siSubtitle, S, true ) ;
        AddJobHeader( Job, siSubTitle, '', true ) ;
        //Build the columns
        with Job.Params, Client.clFields do
        begin
          CLeft := Gcleft;
          AddColAuto( Job, cleft, 6.3, Gcgap, 'Date', jtLeft ) ;
          AddColAuto( Job, cleft, 30,  Gcgap, 'Details', jtLeft ) ;
          AddColAuto( Job, cleft, 8.0, Gcgap, 'Account', jtLeft ) ;
          Job.ForexAmountCol  := AddFormatColAuto( Job, cleft, 11.0 + Gcgap, Gcgap, 'F/C Amount', jtRight, NUMBER_FORMAT, MONEY_FORMAT, true ) ;
          Job.RateCol         := AddColAuto( Job, cleft, 8.0, Gcgap, 'F/C Rate', jtLeft ) ;

          LCTitle := Format( 'Amount (%s)', [ MyClient.clExtra.ceLocal_Currency_Code ] );

          Job.LocalAmountCol  := AddFormatColAuto( Job, cleft, 11.0 + Gcgap, Gcgap, LCTitle, jtRight, NUMBER_FORMAT, MONEY_FORMAT, true ) ;
          AddCommonFooter( Job ) ;
        end;

        Job.Generate( Dest, Lparams ) ;

        if LParams.BatchRun then
          RptBatch.RunResult := 'Ok';
      finally
        Job.Free;
      end;

    until LParams.RunExit( dest ) ;
  finally
    lParams.Free;
  end;
end;

{ ForexParams }

procedure ForexParams.ReadFromNode(Value: IXMLNode);
begin
  inherited;
  GetBatchAccounts;
end;

procedure ForexParams.SaveToNode(Value: IXMLNode);
begin
  inherited;
  SaveBatchAccounts;
end;

end.

