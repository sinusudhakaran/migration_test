unit RptBankRec;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//Bank Reconciliation Report
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

uses
  RptParams,
  UBatchbase,
  ReportDefs;

procedure DoBankRecReport( Destination: TreportDest; Detailed: boolean; RptBatch: TReportBase = nil ) ;
procedure DoUnpresentedItemsReport( Dest: TReportDest; RptBatch: TReportBase = nil ) ;
procedure DoMissingChequesReport( Dest: TReportDest; RptBatch: TReportBase = nil ) ;

//******************************************************************************
implementation

uses
  ReportTypes,
  Classes,
  malloc,
  bkhelp,
  SysUtils,
  AccsDlg,
  RepCols,
  BaObj32,
  MoneyDef,
  bkDefs,
  Globals,
  bkDateUtils,
  GenUtils,
  baUtils,
  InfoMoreFrm,
  CurrencyConversions,
  CodeDateDlg,
  CodeDateAccountDlg,
  CodeDateChequeDlg,
  bkConst,
  NewReportObj,
  OmniXml,
  OmniXmlUtils,
  NewReportUtils, trxList32,
  ueList32, ECollect;

type
  TBankRecReport = class( TBKReport )
  private
    {totals etc}
    C: TReportColumn; {used for overriding the totals}
    Bank_Account: TBank_Account;
    SystemOpBal,
      SystemClBal,
      BankOpBal,
      BankClBal,
      T,
      Cheques,
      deposits,
      upCheques,
      upWithdrawals,
      upDeposits: money;

    parameters: TrptParameters;

    Detailed: boolean;
    WrapNarration: Boolean;
  end;

type
  TMissingChequesReport = class( TBankRecReport )
  private
    ChequeRangesArray: tChqArray;
    IncludeUPCs: boolean;
  end;

type
  TExistingChequeInfo = record
    ecChequeNo: integer;
    ecPresented: boolean;
  end;
  pExistingChequeInfo = ^TExistingChequeInfo;

  //This object is used to get information back about cheque ranges
  //It will return a delimited list of missing cheque ranges given dates and
  //a cheque number range to search within

  TChequeRangeInterrogator = class
    constructor Create;
    destructor Destory;
  private
    ChequesInRange: TList;
  public
    FirstCheque: integer;
    LastCheque: integer;
    TreatUPCsAsFound: boolean;

    function GetMissingChequesString( Ba: TBank_Account;
      FromDate, ToDate: Integer;
      FromCheque, ToCheque: integer ) : string; overload;
    function GetMissingChequesString( Ba: TBank_Account;
      FromDate, ToDate: Integer ) : string; overload;
  end;

  //------------------------------------------------------------------------------

procedure BankRecDetail( Sender: Tobject ) ;

  procedure PutWrappedNarration( Notes, EDT, Ref: string; Amount: Money; PDT:
    string ) ;
  const
    MaxNotesLines: Integer = 10;
  var
    j, ColWidth, OldWidth: Integer;
    ColsToSkip: integer;
    NotesList: TStringList;
  begin
    with TBankRecReport( Sender ) do
    begin
      NotesList := TStringList.Create;
      try
        NotesList.Text := Notes;
        // Remove blank lines
        j := 0;
        while j < NotesList.Count do
        begin
          if NotesList[ j ] = '' then
            NoteSList.Delete( j )
          else
            Inc( j ) ;
        end;
        if NotesList.Count = 0 then
        begin
          SkipColumn;
          Exit;
        end;
        ColsToSkip := CurrDetail.Count;
        j := 0;
        repeat
          ColWidth := RenderEngine.RenderColumnWidth( CurrDetail.Count,
            NotesList[ j ] ) ;
          if ( ColWidth < Length( NotesList[ j ] ) ) then
          begin
            //line needs to be split
            OldWidth := ColWidth; //store
            while ( ColWidth > 0 ) and ( NotesList[ j ] [ ColWidth ] <> ' ' ) do
              Dec( ColWidth ) ;
            if ( ColWidth = 0 ) then
              ColWidth := OldWidth; //unexpected!
            NotesList.Insert( j + 1, Copy( NotesList[ j ] , ColWidth + 1,
              Length( NotesList[ j ] ) - ColWidth + 1 ) ) ;
            NotesList[ j ] := Copy( NotesList[ j ] , 1, ColWidth ) ;
          end;
          PutString( NotesList[ j ] ) ;
          if j = 0 then // put other values
          begin
            PutString( EDT ) ;
            PutString( Ref ) ;
            PutMoney( Amount ) ;
            PutString( PDT ) ;
          end
          else
          begin
            SkipColumn;
            SkipColumn;
            SkipColumn;
            SkipColumn;
          end;
          Inc( j ) ;
          //decide if need to call renderDetailLine
          if ( j < notesList.Count ) and ( j < MaxNotesLines ) then
          begin
            RenderDetailLine;
            //skip all other fields (reuse ColWidth)
            for ColWidth := 1 to ColsToSkip do
              SkipColumn;
          end;
        until ( j >= NotesList.Count ) or ( j >= MaxNotesLines ) ;
      finally
        NotesList.Free;
      end;
    end;
  end;

var
  i, no: integer;
  S: string;
  NumAccounts: integer;
  pT: pTransaction_Rec;
  Amount: Money;
  Forex : Boolean;
begin
  NumAccounts := 0;

  with TBankRecReport( Sender ) , Parameters, Client, Client.clFields do
  begin
    with AccountList do
      for No := 0 to Pred( Count ) do
      begin
        Bank_Account := AccountList[ No ] ;
        Forex := Bank_Account.IsAForexAccount;
        with Bank_Account, baFields do
          if not ( IsAJournalAccount ) then
          begin
            Inc( NumAccounts ) ;
            if ( NumAccounts > 1 ) and ( ReportTypeParams.NewPageforAccounts ) then
              ReportNewPage;


            GetBalances( Bank_Account, Fromdate, Todate, BankOpBal, BankClBal, SystemOpBal, SystemClBal ) ;

            RenderTitleLine( Bank_Account.Title );

            C.TotalFormat := Bank_Account.FmtBalanceStr;

            PutString( 'Opening Balance' ) ;
            PutString( bkDate2Str( Fromdate ) ) ;
            SkipColumn;
            PutMoneyTotal( SystemOpBal ) ;
            SkipColumn;
            RenderDetailLine;

            RenderTextLine( '' ) ;
            RenderTitleLine( 'Plus: Deposits' ) ;
            Deposits := 0;

            with baTransaction_List do
            begin
              for i := 0 to Pred( itemCount ) do
              begin
                pT := Transaction_At( i ) ;
                if Forex then
                  Amount := pT.txForeign_Currency_Amount
                else
                  Amount := pT.txAmount;
                with pT^ do
                begin
                  if ( Amount < 0 ) and ( CompareDates( txDate_Effective,
                    Fromdate, ToDate ) = Within ) then
                  begin
                    if Detailed then
                    begin
                      if ( txGL_Narration <> '' ) and WrapNarration then
                        PutWrappedNarration( txGL_Narration, bkDate2Str(
                          txDate_Effective ) ,
                          GetFormattedReference( pT ) , -Amount, bkDate2Str(
                          txDate_Presented ) )
                      else
                      begin
                        PutString( txGL_Narration ) ;
                        PutString( bkDate2Str( txDate_Effective ) ) ;
                        PutString( GetFormattedReference( pT ) ) ;
                        PutMoney( -Amount ) ;
                        PutString( bkDate2Str( txDate_Presented ) ) ;
                      end;
                      RenderDetailLine;
                    end;
                    Deposits := Deposits + Amount;
                  end;
                end;
              end;
            end;

            if not Detailed then
            begin
              S := 'Total of all deposits from ' + bkDate2Str( Fromdate ) +
                ' to ' + bkDate2Str( Todate ) ;
              PutString( S ) ;
              SkipColumn;
              SkipColumn;
              PutMoney( -Deposits ) ;
              SkipColumn;
              RenderDetailLine;
            end;

            C.TotalFormat := Bank_Account.FmtMoneyStr;
            C.SubTotal := -Deposits / 100;
            if Detailed then
              RenderDetailSubTotal( '' ) ;

            RenderTextLine( '' ) ;
            RenderTitleLine( 'Less: Withdrawals Incl Cheques' ) ;
            Cheques := 0;

            with baTransaction_List do
              for i := 0 to Pred( itemCount ) do
              begin
                pT := Transaction_At( i ) ;
                if Forex then
                  Amount := pT.txForeign_Currency_Amount
                else
                  Amount := pT.txAmount;

                with pT^ do
                begin
                  if ( Amount > 0 ) and ( CompareDates( txDate_Effective,
                    Fromdate, ToDate ) = Within ) then
                  begin
                    if Detailed then
                    begin
                      if ( txGL_Narration <> '' ) and WrapNarration then
                        PutWrappedNarration( txGL_Narration, bkDate2Str(
                          txDate_Effective ) ,
                          GetFormattedReference( pT ) , Amount, bkDate2Str(
                          txDate_Presented ) )
                      else
                      begin
                        PutString( txGL_Narration ) ;
                        PutString( bkDate2Str( txDate_Effective ) ) ;
                        PutString( GetFormattedReference( pT ) ) ;
                        PutMoney( Amount ) ;
                        PutString( bkDate2Str( txDate_Presented ) ) ;
                      end;
                      RenderDetailLine;
                    end;
                    Cheques := Cheques + Amount;
                  end;
                end;
              end;

            if not Detailed then
            begin
              S := 'Total of all withdrawals from ' + bkDate2Str( Fromdate ) +
                ' to ' + bkDate2Str( ToDate ) ;
              PutString( S ) ;
              SkipColumn;
              SkipColumn;
              PutMoney( Cheques ) ;
              SkipColumn;
              RenderDetailLine;
            end;

            C.SubTotal := Cheques / 100;
            if Detailed then
              RenderDetailSubTotal( '' ) ;

            RenderTextLine( '' ) ;
            RendertextLine( '' ) ;
            PutString( 'Closing Balance' ) ;
            SkipColumn;
            SkipColumn;
            C.TotalFormat := Bank_Account.FmtBalanceStr;
            T := SystemOpBal + Deposits + Cheques;
            PutMoneyTotal( t ) ;
            SkipColumn;
            RenderDetailLine;

            RenderTextLine( '' ) ;

            UPCheques := 0;
            RenderTitleLine( 'Plus: Unpresented Cheques' ) ;

            with baTransaction_List do
              for i := 0 to Pred( itemCount ) do
              begin
                pT := Transaction_At( i ) ;

                if Forex then
                  Amount := pT.txForeign_Currency_Amount
                else
                  Amount := pT.txAmount;

                with pT^ do
                begin
                  if ( Amount > 0 ) and ( pT^.txUPI_State in [ upUPC,
                    upMatchedUPC, upBalanceOfUPC, upReversedUPC, upReversalOfUPC
                      ]
                      ) and
                    ( ( CompareDates( txDate_Effective, Fromdate, ToDate ) =
                    Within )
                    or ( CompareDates( txDate_Effective, Fromdate, ToDate ) =
                    Earlier ) ) and
                    ( ( txDate_Presented = 0 ) or ( CompareDates(
                    txDate_Presented, Fromdate, ToDate ) = Later ) ) then
                  begin
                    if ( txGL_Narration <> '' ) and WrapNarration then
                      PutWrappedNarration( txGL_Narration, bkDate2Str(
                        txDate_Effective ) ,
                        GetFormattedReference( pT ) , Amount, bkDate2Str(
                        txDate_Presented ) )
                    else
                    begin
                      PutString( txGL_Narration ) ;
                      PutString( bkDate2Str( txDate_Effective ) ) ;
                      PutString( GetFormattedReference( pT ) ) ;
                      PutMoney( Amount ) ;
                      PutString( bkDate2Str( txDate_Presented ) ) ;
                    end;
                    RenderDetailLine;
                    UPCheques := UPCheques + Amount;
                  end;
                end;
              end;
            C.TotalFormat := Bank_Account.FmtMoneyStr;
            C.SubTotal := UPCheques / 100;
            RenderDetailSubTotal( '' ) ;

            UPWithdrawals := 0;
{$IFNDEF SmartBooks}
            RenderTitleLine( 'Plus: Unpresented Withdrawals' ) ;

            with baTransaction_List do
              for i := 0 to Pred( itemCount ) do
              begin
                pT := Transaction_At( i ) ;

                if Forex then
                  Amount := pT.txForeign_Currency_Amount
                else
                  Amount := pT.txAmount;

                with pT^ do
                begin
                  if ( pT^.txUPI_State in [ upUPW, upMatchedUPW, upBalanceOfUPW,
                    upReversedUPW, upReversalOfUPW ] ) and
                    ( ( CompareDates( txDate_Effective, FromDate, ToDate ) =
                    Within )
                    or ( CompareDates( txDate_Effective, FromDate, ToDate ) =
                    Earlier ) ) and
                    ( ( txDate_Presented = 0 ) or ( CompareDates(
                    txDate_Presented, FromDate, ToDate ) = Later ) ) then
                  begin
                    if ( txGL_Narration <> '' ) and WrapNarration then
                      PutWrappedNarration( txGL_Narration, bkDate2Str(
                        txDate_Effective ) ,
                        GetFormattedReference( pT ) , Amount, bkDate2Str(
                        txDate_Presented ) )
                    else
                    begin
                      PutString( txGL_Narration ) ;
                      PutString( bkDate2Str( txDate_Effective ) ) ;
                      PutString( GetFormattedReference( pT ) ) ;
                      PutMoney( Amount ) ;
                      PutString( bkDate2Str( txDate_Presented ) ) ;
                    end;
                    RenderDetailLine;
                    UPWithdrawals := UPWithdrawals + Amount;
                  end;
                end;
              end;
            C.SubTotal := UPWithdrawals / 100;
            RenderDetailSubTotal( '' ) ;
            RenderTextLine( '' ) ;
{$ENDIF}

            UPDeposits := 0;
{$IFNDEF SmartBooks}
            RenderTitleLine( 'Less: Unpresented Deposits' ) ;

            with baTransaction_List do
              for i := 0 to Pred( itemCount ) do
              begin
                pT := Transaction_At( i ) ;
                if Forex then
                  Amount := pT.txForeign_Currency_Amount
                else
                  Amount := pT.txAmount;
                with pT^ do
                begin
                  if ( pT^.txUPI_State in [ upUPD, upMatchedUPD, upBalanceOfUPD,
                    upReversedUPD, upReversalOfUPD ] ) and
                    ( ( CompareDates( txDate_Effective, FromDate, ToDate ) =
                    Within )
                    or ( CompareDates( txDate_Effective, FromDate, ToDate ) =
                    Earlier ) ) and
                    ( ( txDate_Presented = 0 ) or ( CompareDates(
                    txDate_Presented, FromDate, ToDate ) = Later ) ) then
                  begin
                    if ( txGL_Narration <> '' ) and WrapNarration then
                      PutWrappedNarration( txGL_Narration, bkDate2Str(
                        txDate_Effective ) ,
                        GetFormattedReference( pT ) , -Amount, bkDate2Str(
                        txDate_Presented ) )
                    else
                    begin
                      PutString( txGL_Narration ) ;
                      PutString( bkDate2Str( txDate_Effective ) ) ;
                      PutString( GetFormattedReference( pT ) ) ;
                      PutMoney( -Amount ) ;
                      PutString( bkDate2Str( txDate_Presented ) ) ;
                    end;
                    RenderDetailLine;
                    UPDeposits := UPDeposits + Amount;
                  end;
                end;
              end;
            C.SubTotal := -UPDeposits / 100;
            RenderDetailSubTotal( '' ) ;
            RenderTextLine( '' ) ;
{$ENDIF}
            T := SystemOpBal + Deposits + Cheques - UPCheques - UPDeposits -
              UPWithdrawals;
            PutString( 'Bank Statement Balance' ) ;
            PutString( bkDate2Str( ToDate ) ) ;
            SkipColumn;
            C.TotalFormat := Bank_Account.FmtBalanceStr;
            PutMoneyTotal( T ) ;
            SkipColumn;
            RenderDetailLine;
            DoubleUnderLine;
          end;
      end;
  end;
end;

//------------------------------------------------------------------------------

procedure DoBankRecReport( Destination: TreportDest;
  Detailed: boolean;
  RptBatch: TReportBase = nil ) ;
var
  NeedsBalance: boolean;
  i: integer;
  Job: TBankRecReport;
  Title: string;
  WrapNarration: Boolean;
  Params: TRptParameters;
  cLeft: Double;
begin
  Params := TRptParameters.Create( ord( Report_BankRec_Detail ) , MyClient,
    RptBatch, DPeriod ) ;
  try
    Params.AccountFilter := [ btBank ] ;
    Params.GetBatchAccounts;
    WrapNarration := Params.GetBatchBool( 'Wrap_Narration', False ) ;
    repeat
      with Params do
      begin
        // Not sure about the syquence here...
        NeedsBalance := false;
        with Client.clBank_Account_List do
          for i := 0 to Pred( itemCount ) do
            with Bank_Account_At( i ) do
              if ( baFields.baCurrent_balance = unknown ) then
              begin
                NeedsBalance := true;
                Break; // need only one...
              end;

        if BatchRun then
        begin
          if needsBalance then
          begin
            RptBatch.RunResult := ( 'No Bank Account Balances available.' ) ;
            Exit;
          end;

        end
        else
        begin

          if needsBalance then
          begin
            HelpfulInfoMsg(
              'You need to enter the Bank Account Balances before doing this.', 0
              ) ;
            Params.RunBtn := BTN_NONE;
            exit;
          end;

          if Detailed then
            title := 'Bank Reconciliation - Detailed'
          else
            title := 'Bank Reconciliation - Summarised';

          try
            if not EnterPrintDateAccountRange( Title,
              'Enter the starting and finishing date for Reconciliation Report.',
              [ btBank ] ,
              params,
              BKH_Bank_reconciliation_report,
              false, WrapNarration, True ) then
            begin
              Exit;
            end;

            if Params.BatchSave then
            begin
              SaveNodeSettings;
              SetBatchBool( 'Wrap_Narration', WrapNarration ) ;
              SaveBatchAccounts;
              Exit;
            end;

          except
            Exit;
          end;
        end;

        case Params.RunBtn of
          BTN_PRINT: Destination := rdPrinter;
          BTN_PREVIEW: Destination := rdScreen;
          BTN_FILE: Destination := rdFile;
        else
          Destination := rdAsk;
        end;

        Job := TBankRecReport.Create( ReportTypes.rptOther ) ;
        try
          Job.parameters := params;
          Job.WrapNarration := WrapNarration;
          if Detailed then
            Job.LoadReportSettings( UserPrintSettings, Params.MakeRptName(
              Report_List_Names[ REPORT_BANKREC_DETAIL ] ) )
          else
            Job.LoadReportSettings( UserPrintSettings, Params.MakeRptName(
              Report_List_Names[ REPORT_BANKREC_SUM ] ) ) ;

          //Add Headers
          AddCommonHeader( Job ) ;

          if Detailed then
            title := 'BANK RECONCILIATION REPORT - DETAILED'
          else
            title := 'BANK RECONCILIATION REPORT - SUMMARISED';

          AddJobHeader( Job, siTitle, Title, true ) ;
          AddjobHeader( Job, siSubTitle, 'For the period from ' + bkdate2Str(
            Fromdate )
            + ' to ' + bkDate2Str( Todate ) , true ) ;

          cLeft := GCLeft;
          AddColAuto( Job, cLeft, 40, GcGap, 'Details', jtLeft ) ;
          AddColAuto( Job, cLeft, 10, GcGap, 'Effective Date', jtLeft ) ;
          AddColAuto( Job, cLeft, 25, GcGap, 'Reference', jtLeft ) ;

          Job.c := AddFormatColAuto( Job, cLeft, 15, GcGap, 'Amount', jtRight,
            Client.FmtMoneyStrBracketsNoSymbol,
            Client.FmtMoneyStrBrackets,
            true ) ;

          AddColAuto( Job, cLeft, 10, GcGap, 'BS Date', jtRight ) ;

          //AddClientFooter(Job);

          //Add Footers
          AddCommonFooter( Job ) ;

          Job.OnBKPrint := BankRecDetail;
          Job.Detailed := detailed;

          Job.Generate( Destination, params ) ;
        finally
          Job.Free;
        end;

      end;
    until Params.RunExit( Destination ) ;
  finally
    Params.Free;
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UnpresentedItemsDetail( Sender: TObject ) ;

  procedure PutWrappedNarration( Notes, DT, Ref: string; Amount: Money ) ;
  const
    MaxNotesLines: Integer = 10;
  var
    j, ColWidth, OldWidth: Integer;
    ColsToSkip: integer;
    NotesList: TStringList;
  begin
    with TBankRecReport( Sender ) do
    begin
      NotesList := TStringList.Create;
      try
        NotesList.Text := Notes;
        // Remove blank lines
        j := 0;
        while j < NotesList.Count do
        begin
          if NotesList[ j ] = '' then
            NoteSList.Delete( j )
          else
            Inc( j ) ;
        end;
        if NotesList.Count = 0 then
        begin
          SkipColumn;
          Exit;
        end;
        ColsToSkip := CurrDetail.Count;
        j := 0;
        repeat
          ColWidth := RenderEngine.RenderColumnWidth( CurrDetail.Count,
            NotesList[ j ] ) ;
          if ( ColWidth < Length( NotesList[ j ] ) ) then
          begin
            //line needs to be split
            OldWidth := ColWidth; //store
            while ( ColWidth > 0 ) and ( NotesList[ j ] [ ColWidth ] <> ' ' ) do
              Dec( ColWidth ) ;
            if ( ColWidth = 0 ) then
              ColWidth := OldWidth; //unexpected!
            NotesList.Insert( j + 1, Copy( NotesList[ j ] , ColWidth + 1,
              Length( NotesList[ j ] ) - ColWidth + 1 ) ) ;
            NotesList[ j ] := Copy( NotesList[ j ] , 1, ColWidth ) ;
          end;
          PutString( NotesList[ j ] ) ;
          if j = 0 then // put other values
          begin
            PutString( DT ) ;
            PutString( Ref ) ;
            PutMoney( Amount ) ;
          end
          else
          begin
            SkipColumn;
            SkipColumn;
            SkipColumn;
          end;
          Inc( j ) ;
          //decide if need to call renderDetailLine
          if ( j < notesList.Count ) and ( j < MaxNotesLines ) then
          begin
            RenderDetailLine;
            //skip all other fields (reuse ColWidth)
            for ColWidth := 1 to ColsToSkip do
              SkipColumn;
          end;
        until ( j >= NotesList.Count ) or ( j >= MaxNotesLines ) ;
      finally
        NotesList.Free;
      end;
    end;
  end;

  procedure PrintItems( upState: integer; DateFrom: integer; DateTo: integer;
    BA: TBank_Account ) ;
  var
    tNo: integer;
    pT: pTransaction_Rec;
    Amount : Money;
    Forex : Boolean;
  begin
    with TBankRecReport( Sender ), Parameters do
    Begin
      Forex := BA.IsAForexAccount;
      for tNo := BA.baTransaction_List.First to BA.baTransaction_List.Last do
      begin
        pT := BA.baTransaction_List.Transaction_At( tNo ) ;
        if Forex then
          Amount := pT.txForeign_Currency_Amount
        else
          Amount := pT.txAmount;

        if ( CompareDates( pT^.txDate_Effective, DateFrom, DateTo ) = Within )
          and
          ( pT^.txUPI_State = upState ) then
        begin
          if WrapNarration and ( pT^.txGL_Narration <> '' ) then
            PutWrappedNarration( pT^.txGL_Narration, bkDate2Str(
              pT^.txDate_Effective ) ,
              GetFormattedReference( pT ) , Amount )
          else
          begin
            PutString( pT^.txGL_Narration ) ;
            PutString( bkDate2Str( pT^.txDate_Effective ) ) ;
            PutString( GetFormattedReference( pT ) ) ;
            PutMoney( Amount ) ;
          end;
          RenderDetailLine;
        end;
      end;
    End;
  end;

var
  no: integer;
  tNo: integer;
  NumAccounts: integer;
  pT: pTransaction_Rec;
  NoOfUPC: integer;
  NoOfUPD: integer;
  NoOfUPW: integer;
  NoOfReversedUPC: integer;
  NoOfReversedUPD: integer;
  NoOfReversedUPW: integer;
  Rpt : TBankRecReport;
begin
  NumAccounts := 0;
  Rpt := TBankRecReport( Sender );

  with Rpt, parameters, Client, Client.clFields do
    with AccountList do
      for No := 0 to Pred( Count ) do
      begin
        Bank_Account := AccountList[ no ] ;
        with Bank_Account, baFields do
          if not ( IsAJournalAccount ) then
          begin
            NoOfUPC := 0;
            NoOfUPD := 0;
            NoOfUPW := 0;
            NoOfReversedUPC := 0;
            NoOfReversedUPD := 0;
            NoOfReversedUPW := 0;

            //see if should print account
            for tNo := baTransaction_List.First to baTransaction_List.Last do
            begin
              pT := baTransaction_List.Transaction_At( tNo ) ;

              if ( CompareDates( pT^.txDate_Effective, FromDate, ToDate ) =
                Within ) then
              begin
                case pT^.txUPI_State of
                  upUPC: Inc( NoOfUPC ) ;
                  upUPW: Inc( NoOfUPW ) ;
                  upUPD: Inc( NoOfUPD ) ;
                  upReversedUPC: Inc( NoOfReversedUPC ) ;
                  upReversedUPD: Inc( NoOfReversedUPD ) ;
                  upReversedUPW: Inc( NoOfReversedUPW ) ;
                end;
              end;
            end;

            if ( NoOfUPC > 0 ) or ( NoOfUPD > 0 ) or ( NoOfUPW > 0 ) or
              ( NoOfReversedUPC > 0 ) or ( NoOfReversedUPD > 0 ) or (
              NoOfReversedUPW > 0 ) then
            begin
              Inc( NumAccounts ) ;
              if ( NumAccounts > 1 ) and ( ReportTypeParams.NewPageforAccounts )
                then
                ReportNewPage;

              RenderTitleLine( Bank_Account.Title );

              C.TotalFormat := Bank_Account.FmtMoneyStr;

              //list all unpresented cheques, txUPI_State = upUPC
              if ( NoOfUPC > 0 ) then
              begin
                RenderTitleLine( 'Unpresented Cheques' ) ;
                PrintItems( upUPC, Fromdate, ToDate, Bank_Account ) ;
              end;

              //list all unpresented withdrawals
              if ( NoOfUPW > 0 ) then
              begin
                RenderTitleLine( 'Unpresented Withdrawals' ) ;
                PrintItems( upUPW, Fromdate, ToDate, Bank_Account ) ;
              end;

              //list all unpresented deposits
              if ( NoOfUPD > 0 ) then
              begin
                RenderTitleLine( 'Unpresented Deposits' ) ;
                PrintItems( upUPD, FromDate, ToDate, Bank_Account ) ;
              end;

              //list all cancelled cheques
              if ( NoOfReversedUPC > 0 ) then
              begin
                RenderTitleLine( 'Cancelled Cheques' ) ;
                PrintItems( upReversedUPC, FromDate, ToDate, Bank_Account ) ;
              end;

              //list all cancelled withdrawals
              if ( NoOfReversedUPD > 0 ) then
              begin
                RenderTitleLine( 'Cancelled Withdrawals' ) ;
                PrintItems( upReversedUPW, FromDate, ToDate, Bank_Account ) ;
              end;

              //list all cancelled deposits
              if ( NoOfReversedUPD > 0 ) then
              begin
                RenderTitleLine( 'Cancelled Deposits' ) ;
                PrintItems( upReversedUPD, FromDate, ToDate, Bank_Account ) ;
              end;
            end;
          end;
      end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoUnpresentedItemsReport( Dest: TReportDest; RptBatch: TReportBase =
  nil ) ;
//this report has similar layout to the bank rec
var
  Job: TBankRecReport;
  WrapNarration: Boolean;
  Params: TRptParameters;
  cLeft: Double;
begin
  Params := TRptParameters.Create( ord( REPORT_UNPRESENTED_ITEMS ) , MyClient,
    RptBatch, DPeriod ) ;
  with Params do
    try
      AccountFilter := [ btBank ] ;
      WrapNarration := GetBatchBool( 'Wrap_Narration', False ) ;
      GetBatchAccounts;
      repeat
        try
          if not EnterPrintDateAccountRange( 'Unpresented Items',
            'Enter the starting and finishing dates for the Unpresented Items report.',
            [ btBank ] ,
            Params,
            BKH_List_unpresented_items_report,
            false,
            WrapNarration,
            True ) then
            Exit;
        except
          Exit;
        end;

        if Params.Runbtn = Btn_save then
        begin

          SaveNodeSettings;
          SetBatchBool( 'Wrap_Narration', WrapNarration ) ;
          SaveBatchAccounts;
          Exit;
        end;

        {if (Dest = rdNone)
        or Batchsetup then}
        case Params.RunBtn of
          BTN_PRINT: Dest := rdPrinter;
          BTN_PREVIEW: Dest := rdScreen;
          BTN_FILE: Dest := rdFile;
        else
          Dest := rdScreen;
        end;

        Job := TBankRecReport.Create( ReportTypes.rptOther ) ;
        try
          Job.Parameters := params;
          Job.WrapNarration := WrapNarration;
          Job.LoadReportSettings( UserPrintSettings, Params.MakeRptName(
            Report_List_Names[ REPORT_UNPRESENTED_ITEMS ] ) ) ;

          //Add Headers
          AddCommonHeader( Job ) ;

          AddJobHeader( Job, SiTitle, 'UNPRESENTED ITEMS', True ) ;
          AddjobHeader( Job, SiSubTitle, 'For the period from ' + bkdate2Str(
            Params.FromDate ) +
            ' to ' + bkDate2Str( Params.ToDate ) , true ) ;

          {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
          cLeft := GcLeft;
          AddColAuto( Job, cLeft, 35, GcGap, 'Details', jtLeft ) ;
          AddColAuto( Job, cLeft, 10, GcGap, 'Effective Date', jtLeft ) ;
          AddColAuto( Job, cLeft, 20, GcGap, 'Reference', jtLeft ) ;

          Job.c := AddFormatColAuto( Job, cLeft, 15, GcGap, 'Amount', jtRight,
            Client.FmtMoneyStrBracketsNoSymbol,
            Client.FmtMoneyStrBrackets,
            true ) ;

          //Add Footers
          AddCommonFooter( Job ) ;

          Job.OnBKPrint := UnpresentedItemsDetail;

          Job.Generate( Dest, params ) ;
        finally
          Job.Free;
        end;
      until Params.RunExit( Dest ) ;
    finally
      Params.Free;
    end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TChequeRangeInterrogator }

function ChequeCompare( pA, pB: Pointer ) : Integer;
// Compares Cheque no of A and B
// Returns -1 if A < B, 0 if A = B, 1 if A > B
//used by GetMissingChequesString()
var
  p1, p2: pExistingChequeInfo;
begin
  Result := 0; //Default to equal
  p1 := pExistingChequeInfo( pA ) ;
  p2 := pExistingChequeInfo( pB ) ;
  if p1^.ecChequeNo < p2^.ecChequeNo then
    Result := -1;
  if p1^.ecChequeNo > p2^.ecChequeNo then
    Result := 1;
end;

constructor TChequeRangeInterrogator.Create;
begin
  inherited Create;

  ChequesInRange := TList.Create;
  TreatUPCsAsFound := false;
  //treat upcs as real cheques or consider them missing
end;

destructor TChequeRangeInterrogator.Destory;
var
  i: integer;
begin
  //free all cheque pointers
  for i := 0 to ChequesInRange.Count - 1 do
    FreeMem( pExistingChequeInfo( ChequesInRange.Items[ i ] ) , SizeOf(
      TExistingChequeInfo ) ) ;

  inherited Destroy;
end;

function TChequeRangeInterrogator.GetMissingChequesString(
  Ba: TBank_Account; FromDate, ToDate, FromCheque,
  ToCheque: integer ) : string;
var
  tNo: integer;
  pT: pTransaction_Rec;
  FirstChequeNo: integer;
  LastChequeNo: integer;
  pECInfo: pExistingChequeInfo;
  RangesList: TStringList;
  S: string;
  i: integer;
begin
  Self.FirstCheque := FromCheque;
  Self.LastCheque := ToCheque;

  //load all cheques within date and number ranges
  ChequesInRange.Clear;
  for tNo := ba.baTransaction_List.First to ba.baTransaction_List.Last do
  begin
    //loop over all transactions in this account
    pT := ba.baTransaction_List.Transaction_At( tNo ) ;

    if ( pT^.txCheque_Number > 0 ) and ( CompareDates( pT^.txDate_Effective,
      FromDate, ToDate ) = Within ) then
    begin
      if ( ( pT.txUPI_State in [ upNone, upMatchedUPC, upReversedUPC,
        upReversalOfUPC ] ) or TreatUPCsAsFound )
        and ( pT.txCheque_Number >= FromCheque ) and ( pT.txCheque_Number <=
        ToCheque ) then
      begin
        GetMem( pECInfo, SizeOf( TExistingChequeInfo ) ) ;
        with pECInfo^ do
        begin
          ecChequeNo := pT^.txCheque_Number;
          ecPresented := pT^.txDate_Presented > 0;
        end;
        ChequesInRange.Add( pECInfo ) ;
      end;
    end;

    //sort list
    ChequesInRange.Sort( ChequeCompare ) ;
  end;

  RangesList := TStringList.Create;
  try
    //now have a list of cheques that exist within the range
    //return a TStringList to say what is missing
    FirstChequeNo := FromCheque;

    //move through list looking for a gap
    for i := 0 to ChequesInRange.Count - 1 do
    begin
      //gap will
      pECInfo := pExistingChequeInfo( ChequesInRange.Items[ i ] ) ;
      if pECInfo.ecChequeNo > FirstChequeNo then
      begin
        LastChequeNo := pECInfo.ecChequeNo - 1;
        if FirstChequeNo = LastChequeNo then
          S := IntToStr( FirstChequeNo )
        else
          S := IntToStr( FirstChequeNo ) + '-' + IntToStr( LastChequeNo ) ;

        RangesList.Add( S ) ;
      end;
      FirstChequeNo := pECInfo.ecChequeNo + 1;
    end;

    //test for the last range
    if ToCheque >= FirstChequeNo then
    begin
      if FirstChequeNo = ToCheque then
        S := IntToStr( FirstChequeNo )
      else
        S := IntToStr( FirstChequeNo ) + '-' + IntToStr( ToCheque ) ;

      RangesList.Add( S ) ;
    end;

    Result := RangesList.Text;
  finally
    RangesList.Free;
  end;
end;

function TChequeRangeInterrogator.GetMissingChequesString(
  Ba: TBank_Account; FromDate, ToDate: Integer ) : string;
//only called with account and dates, the cheque number range will be filled
//automatically using the first and last cheque # found in the range
var
  tNo: integer;
  pT: pTransaction_Rec;
  LowestChequeNumber, HighestChequeNumber: integer;
begin
  LowestChequeNumber := MaxInt;
  HighestChequeNumber := 0;

  //set range to the first and last cheque number found
  for tNo := ba.baTransaction_List.First to ba.baTransaction_List.Last do
  begin
    //loop over all transactions in this account
    pT := ba.baTransaction_List.Transaction_At( tNo ) ;

    if ( pT^.txCheque_Number > 0 ) and ( CompareDates( pT^.txDate_Effective,
      FromDate, ToDate ) = Within ) then
    begin
      //transaction date is within the specified range
      //store the first and last cheque numbers
      if pT^.txCheque_Number < LowestChequeNumber then
        LowestChequeNumber := pT^.txCheque_Number;

      if pT^.txCheque_Number > HighestChequeNumber then
        HighestChequeNumber := pT^.txCheque_Number;
    end;
  end;

  result := GetMissingChequesString( Ba, FromDate, ToDate, LowestChequeNumber,
    HighestChequeNumber ) ;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure PrintChequeRange( MissingChequesReport: TMissingChequesReport;
  FromCheque, ToCheque: integer ) ;
var
  RangeInterogator: TChequeRangeInterrogator;
  Lines: TStringList;
  i: integer;
begin
  RangeInterogator := TChequeRangeInterrogator.Create;
  try
    RangeInterogator.TreatUPCsAsFound := not MissingchequesReport.IncludeUPCs;

    Lines := TStringList.Create;
    try
      if ( FromCheque <> 0 ) or ( ToCheque <> 0 ) then
        Lines.Text := RangeInterogator.GetMissingChequesString(
          MissingChequesReport.Bank_Account,
          MissingChequesReport.parameters.FromDate,
          MissingChequesReport.parameters.ToDate,
          FromCheque,
          ToCheque )
      else
        Lines.Text := RangeInterogator.GetMissingChequesString(
          MissingChequesReport.Bank_Account,
          MissingChequesReport.Parameters.FromDate,
          MissingChequesReport.Parameters.ToDate ) ;

      MissingChequesReport.RenderTitleLine( 'Missing Cheques in range ' +
        IntToStr( RangeInterogator.FirstCheque ) + '-' +
        IntToStr( RangeInterogator.LastCheque ) + ':' ) ;

      if Lines.Count = 0 then
      begin
        MissingChequesReport.PutString( 'None' ) ;
        MissingChequesReport.RenderDetailLine;
      end
      else
      begin
        for i := 0 to Lines.Count - 1 do
        begin
          MissingChequesReport.PutString( Lines[ i ] ) ;
          MissingChequesReport.RenderDetailLine;
        end;
      end;
    finally
      Lines.Free;
    end;
  finally
    RangeInterogator.Free;
  end;
end;

procedure MissingChequesDetail( Sender: TObject ) ;
//print a report section for each range entered, if no range entered then
//automatically set range
var
  RangeNo: integer;
  RangeFound: Boolean;
begin
  with TMissingChequesReport( Sender ) do
  begin
    RenderTitleLine( Bank_Account.baFields.baBank_Account_Number + ' : ' +
      Bank_Account.baFields.baBank_Account_Name ) ;

    //see if user selected any ranges
    RangeFound := false;
    for RangeNo := Low( ChequeRangesArray ) to High( ChequeRangesArray ) do
    begin
      if ( ChequeRangesArray[ RangeNo ] .SN1 <> 0 ) or ( ChequeRangesArray[
        RangeNo ] .SN2 <> 0 ) then
      begin
        RangeFound := true;
        PrintChequeRange( TMissingChequesReport( Sender ) ,
          ChequeRangesArray[ RangeNo ] .SN1,
          ChequeRangesArray[ RangeNo ] .SN2 ) ;
      end;
    end;

    if not RangeFound then
    begin
      //user did not enter any ranges so show for all cheques
      PrintChequeRange( TMissingChequesReport( Sender ) , 0, 0 ) ;
    end;
  end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure DoMissingChequesReport( Dest: TReportDest; RptBatch: TReportBase = nil
  ) ;
var
  Job: TMissingChequesReport;
  BankAccount: TBank_Account;
  DataArray: tChqArray;
  IncludeUPCs: boolean;
  params: tRptParameters;
  I: Integer;
  s: string;
  cLeft: Double;

  procedure SaveCheques( Value: IXMLNode ) ;
  var
    NN, AN: IXMLNode;
    I: Integer;
  begin
    NN := nil;
    AN := nil;
    for I := Low( DataArray ) to High( DataArray ) do
    begin
      if ( DataArray[ i ] .SN1 <> 0 )
        or ( DataArray[ i ] .SN2 <> 0 ) then
      begin
        // Got one..
        if AN = nil then
        begin
          AN := EnsureNode( Value, 'Cheques' ) ;
          AN.Text := '';
        end;
        NN := AppendNode( AN, 'Range' ) ;
        SetNodeTextInt( NN, 'From', DataArray[ i ] .SN1 ) ;
        SetNodeTextInt( NN, 'To', DataArray[ i ] .SN2 )
      end;
    end;
  end;

  procedure GetCheques( Value: IXMLNode ) ;
  var
    NN: IXMLNode;
    LList: IXMLNodeList;
    I: Integer;
  begin
    NN := FindNode( Value, 'Cheques' ) ;
    if not assigned( NN ) then
      exit;
    LList := FilterNodes( NN, 'Range' ) ;
    if not assigned( LList ) then
      exit;
    if LList.Length = 0 then
      exit;
    for I := 0 to LList.Length - 1 do
    begin
      if I >= High( DataArray ) then
        exit;
      // Found at least one..
      DataArray[ Succ( i ) ] .SN1 := GetNodeTextInt( LList.Item[ I ] , 'From', 0
        ) ;
      DataArray[ Succ( i ) ] .SN2 := GetNodeTextInt( LList.Item[ I ] , 'To', 0 )
    end;
  end;

begin
  FillChar( DataArray, SizeOf( DataArray ) , #0 ) ;
  params := tRptParameters.Create( ord( REPORT_MISSING_CHEQUES ) , MyClient,
    RptBatch ) ;
  with Params do
    try
      if HaveSettings then
      begin
        GetCheques( RptBatch.settings ) ;
        s := GetBatchText( '_Account' ) ;

        if s <> '' then
          with Client.clBank_Account_List do
            for i := 0 to Pred( itemCount ) do
              with Bank_Account_At( i ) do
              begin
                if ( baFields.baAccount_Type = btBank )
                  and sametext( s, baFields.baBank_Account_Number ) then
                  BankAccount := Bank_Account_At( i ) ;
              end;
      end;
      repeat
        try
          if not EnterPrintDateAccountChequeRange( 'Missing Cheques Report',
            'Enter the starting and finishing dates for the Missing Cheques report.',
            [ btBank ] ,
            FromDate,
            ToDate,
            BankAccount,
            BKH_List_missing_cheques_report,
            False, @DataArray,
            Params,
            IncludeUPCs ) then
          begin
            Exit;
          end;
        except
          Exit;
        end;

        if Params.RunBtn = Btn_save then
        begin
          SaveNodeSettings;
          SaveCheques( RptBatch.Settings ) ;
          if assigned( BankAccount ) then
          begin
            SetBatchText( '_Account', BankAccount.baFields.baBank_Account_Number
              ) ;
            SetBatchText( 'Account', BankAccount.baFields.baBank_Account_Name )
              ;
          end;
          Exit;

        end;

        {if (Dest = rdNone)
        or Batchsetup then}
        case Params.RunBtn of
          BTN_PRINT: Dest := rdPrinter;
          BTN_PREVIEW: Dest := rdScreen;
          BTN_FILE: Dest := rdFile;
        else
          Dest := rdScreen;
        end;

        Job := TMissingChequesReport.Create( ReportTypes.rptOther ) ;
        try
          Job.LoadReportSettings( UserPrintSettings, Params.MakeRptName(
            Report_List_Names[ REPORT_MISSING_CHEQUES ] ) ) ;

          //Add Headers
          AddCommonHeader( Job ) ;

          AddJobHeader( Job, SiTitle, 'MISSING CHEQUES', True ) ;
          AddjobHeader( Job, SiSubTitle, 'For the period from ' + bkdate2Str(
            FromDate ) +
            ' to ' + bkDate2Str( ToDate ) , true ) ;

          {Add Columns: Job,Left Percent, Width Percent, Caption, Alignment}
          cLeft := GCLeft;
          AddColAuto( Job, cLeft, 35, GcGap, '', jtLeft ) ;

          //Add Footers
          if not IncludeUPCs then
            AddJobFooter( Job, siFootNote,
              'NOTE: Any Unpresented Cheques that have been entered are excluded from this report', true
              )
          else
            AddJobFooter( Job, siFootNote,
              'NOTE: Any Unpresented Cheques that have been entered are displayed as missing cheques', true
              ) ;

          AddCommonFooter( Job ) ;

          Job.Bank_Account := BankAccount;
          Job.ChequeRangesArray := DataArray;
          Job.OnBKPrint := MissingChequesDetail;
          Job.parameters := Params;
          Job.IncludeUPCs := IncludeUPCs;

          Job.Generate( Dest, params ) ;
        finally
          Job.Free;
        end;

      until RunExit( Dest ) ;
    finally
      Params.Free;
    end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

end.

