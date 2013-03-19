unit ForexReports;

// ----------------------------------------------------------------------------
interface
// ----------------------------------------------------------------------------

uses
  ReportDefs, PrintMgrObj, FaxParametersObj, OvcDate, moneydef, Classes,
  UBatchBase, ExchangeGainLoss, ExchangeRateList;

procedure DoListForexEntriesReport( Dest: TReportDest; RptBatch: TReportBase =
  nil; MonthEndStr: string = ''; ReportInfo: Pointer = nil);

// ----------------------------------------------------------------------------
implementation
// ----------------------------------------------------------------------------

uses
  omniXML, CodeDateAccountDlg, NewReportObj, RepCols, TravList, SysUtils,
  bkConst, baObj32, bkDateUtils, GenUtils, Globals, RptParams, BKHelp, WarningMoreFrm, ReportTypes,
  NewReportUtils, baUtils, MoneyUtils, ForexHelpers, DateUtils, ExchangeGainLossCodeEntryfrm, glObj32,
  YesNoDlg, BKDEFS, Contnrs, StDate, frObj32;

Const
  NUMBER_FORMAT = '#,##0.00;(#,##0.00);-';
  MONEY_FORMAT = '#,##0.00;-#,##0.00;-';

type
  ForexParams = class (TRPTParameters)
  private
    FUsePrecalculatedGainLoss: Boolean;
    FCalculatedGainLossEntries: TMonthEndings;
    
    procedure SetUsePrecalculatedGainLoss(const Value: Boolean);
    procedure SetCalculatedGainLossEntries(const Value: TMonthEndings);
  protected
     procedure ReadFromNode (Value : IXMLNode); override;
     procedure SaveToNode   (Value : IXMLNode); override;
  public
    property UsePrecalculatedGainLoss: Boolean read FUsePrecalculatedGainLoss write SetUsePrecalculatedGainLoss;
    property CalculatedGainLossEntries: TMonthEndings read FCalculatedGainLossEntries write SetCalculatedGainLossEntries;
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
    OpBalAtBank        : Money;
    ClBalAtBank        : Money;
    OpBalInSystem      : Money;
    ClBalInSystem      : Money;
    OpBaseBalAtBank    : Money;
    ClBaseBalAtBank    : Money;
    OpBaseBalInSystem  : Money;
    ClBaseBalInSystem  : Money;
    CRTotal            : Money;
    DRTotal            : Money;
    CRBaseTotal        : Money;
    DRBaseTotal        : Money;
    ReportJob          : TBKReport;
  end;

  // ----------------------------------------------------------------------------

  // Is current bank account selected in the Advanced tab
  // Returns True if selected

function GetLastTransactionDate(BankAccount: TBank_Account): TStDate;
var
  Index: Integer;
begin
  Result := GetLastDayOfLastMonth(CurrentDate);
  
  for Index := BankAccount.baTransaction_List.ItemCount -1 downto 0 do
  begin
    if BankAccount.baTransaction_List.Transaction_At(Index).txDate_Presented <= CurrentDate then
    begin
      if BankAccount.baTransaction_List.Transaction_At(Index).txDate_Presented >= GetFirstDayOfMonth(CurrentDate) then
      begin
        Result := BankAccount.baTransaction_List.Transaction_At(Index).txDate_Presented;
      end;

      Exit;
    end;
  end;
end;

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
  EndOfLastPeriod: Integer;
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
    if (not Bank_Account.HasTransactionsWithin(Fromdate, Todate)) and not Bank_Account.baExchange_Gain_Loss_List.HasEntriesPostedBetween(FromDate, ToDate) then
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
//      RenderTextLine( baDefault_Forex_Description + ' ' + baDefault_Forex_Source );
    End;

    GetBalances( Bank_Account, D1, D2, OpBalAtBank, ClBalAtBank, OpBalInSystem, ClBalInSystem );

    OpDate := D1;
    if OpDate = 0 then
       OpDate := Bank_Account.baTransaction_List.FirstPresDate;

    ClBalAtBank := OpBalAtBank;

    if OpBalAtBank <> Unknown then
    begin
      Bank_Account.baFields.baTemp_Balance := OpBalAtBank;

      PutString( bkDate2Str( OpDate ) ) ;
      PutString( 'Opening Balance' );
      PutString( Bank_Account.baFields.baContra_Account_Code ) ;

      PutMoneyDontAdd( OpBalAtBank );

      Rate := GetLastDayExchangeRate(Bank_Account, GetLastDayOfMonth(IncDate(OpDate, 0, -1, 0)), psUnknown);

      if Rate <> 0.0 then
      Begin
        S := Trim( ForexRate2Str( Rate ) ) + '*';

        PutString( S );
        OpBaseBalAtBank := Round( OpBalAtBank / Rate );
        PutMoneyDontAdd( OpBaseBalAtBank );
      End
      Else
      Begin
        OpBaseBalAtBank := 0;
        SkipColumn;
        SkipColumn;
      end;
      ClBaseBalAtBank := OpBaseBalAtBank;
      RenderDetailLine;
      RenderTextLine('');
    end
    else
    Begin
      OpBaseBalAtBank := Unknown;
      ClBaseBalAtBank := Unknown;
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
    if (not Bank_Account.HasTransactionsWithin( Fromdate, Todate )) and not Bank_Account.baExchange_Gain_Loss_List.HasEntriesPostedBetween(FromDate, ToDate)  then
       exit;
    if Mgr.Transaction^.txUPI_State in [upUPC, upUPD, upUPW, upReversedUPC, upReversalOfUPC, upReversedUPD, upReversalOfUPD, upReversedUPW, upReversalOfUPW] then
       exit;

    ForexAmountCol.FormatString  := MONEY_FORMAT;
    LocalAmountCol.FormatString  := MONEY_FORMAT;

    PutString( bkDate2Str( txDate_Presented ) ) ;
    PutString( txGL_Narration ) ;
    PutString( txAccount ) ;

    //Transaction amount
    PutMoney( Trunc( txAmount ) );

    //Exchange rate

    S := Trim(ForexRate2Str(Mgr.Transaction^.GainLossExchangeRate));
    (*
      if not Mgr.Transaction.Is_Default_Forex_Rate then
         S := S + '*';
    *)
    
    PutString( S );

    //Base amount
    PutMoney( Trunc(  Mgr.Transaction.GainLossLocalAmount ) );

    if ClBalAtBank <> Unknown then
      ClBalAtBank := ClBalAtBank + txAmount;

    if ClBaseBalAtBank <> Unknown then
      ClBaseBalAtBank := ClBaseBalAtBank + Mgr.Transaction.GainLossLocalAmount;

    RenderDetailLine;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SumGainLossEntries(BankAccount: TBank_Account; FromDate, ToDate: Integer; out TotalGainLoss: Double; out PeriodCount: Integer): Boolean;
var
  Periods: TDateList;
  GainLossEntry: TExchange_Gain_Loss;
  Period: Integer;
begin
  Result := False;

  TotalGainLoss := 0;
  
  Periods := GetPeriodsBetween(FromDate, ToDate);

  for Period := 0 to Length(Periods) - 1 do
  begin
    GainLossEntry := BankAccount.baExchange_Gain_Loss_List.GetPostedEntry(Periods[Period]);

    if GainLossEntry <> nil then
    begin
      TotalGainLoss := TotalGainLoss + GainLossEntry.As_pRec.glAmount;

      Result := True;
    end;
  end;

  PeriodCount := Length(Periods);
end;

procedure LE_ExitAccount( Sender: TObject ) ;
var
  Mgr: TForexTravManager;
  ClDate : Integer;
  Rate   : Double;
  S : String;
  ClForexBalAsLocal : Money;
  ForexGainOrLoss   : Money;
  Rpt : TListForexEntriesReport;
  GainLossEntry: TExchange_Gain_Loss;
  GainLossSum: Double;
  NumPeriodsReported: Integer;
  BankAccountEntry: PMonthEndingBankAccount;
  Account: pAccount_Rec;
  PeriodsBetween: TDateList;
  Period: Integer;
  HasEntries: Boolean;
  PartialToDate: TStDate;
  GainLossCalculator: TCalculateGainLoss;
  PartialGainLoss: Money;
  ContainsMultiplePeriods: Boolean;
  ExchangeGainLossCodes: TStringList;
begin
  Mgr := TForexTravManager( Sender );
  Rpt := TListForexEntriesReport( Mgr.ReportJob );

  ExchangeGainLossCodes := TStringList.Create;

  try
    with Mgr, Rpt, Rpt.Params do
    begin
      if ( Bank_Account.baFields.baAccount_Type <> btBank ) then
         exit;
      If not Bank_Account.IsAForexAccount then
         exit;
      if not LE_IsBankAccountIncluded( ReportJob, Mgr ) then
         exit;
      if (not Bank_Account.HasTransactionsWithin(Fromdate, Todate)) and not Bank_Account.baExchange_Gain_Loss_List.HasEntriesPostedBetween(FromDate, ToDate) then
         exit;

      ForexAmountCol.TotalFormat  := Bank_Account.FmtMoneyStr;
      LocalAmountCol.TotalFormat  := Client.FmtMoneyStr;

      RenderDetailSubTotal( '' );

      if IsPartialPeriod(ToDate) then
      begin
        PartialToDate := Bank_Account.baTransaction_List.LastPresDate;
      end
      else
      begin
        PartialToDate := ToDate;
      end;

      if PartialToDate = 0 then ClDate := Bank_Account.baTransaction_List.LastPresDate else ClDate := PartialToDate;

      ForexAmountCol.FormatString  := Bank_Account.FmtMoneyStr;
      LocalAmountCol.FormatString  := Client.FmtMoneyStr;

      if ClBalAtBank <> Unknown then
      begin
        Rpt.SingleUnderLine;
        PutString( bkDate2Str( ClDate ) ) ;
        PutString( 'Closing Balance' );
        SkipColumn;
        SkipColumn;
        SkipColumn;
        PutMoneyDontAdd( ClBaseBalAtBank );
        RenderDetailLine;
      end;

      ContainsMultiplePeriods := GetMonthsBetween(Params.FromDate, Params.ToDate) > 0;
    
      HasEntries := False;

      ForexGainOrLoss := 0;

      if UsePrecalculatedGainLoss then
      begin
        PeriodsBetween := GetPeriodsBetween(Params.FromDate, Params.ToDate);

        for Period := 0 to Length(PeriodsBetween) - 1 do
        begin
          BankAccountEntry := CalculatedGainLossEntries.FindBankAccountEntry(Bank_Account, GetLastDayOfMonth(PeriodsBetween[Period]));

          if Assigned(BankAccountEntry) then
          begin
            ForexGainOrLoss := ForexGainOrLoss + BankAccountEntry.GainLoss;

            HasEntries := True;
          end;
        end;
      end
      else
      begin
        SetLength(PeriodsBetween, 0);

        PartialGainLoss := 0;
      
        if IsPartialPeriod(Params.ToDate) then
        begin
          if GetMonthsBetween(Params.FromDate, Params.ToDate) > 0 then
          begin
            PeriodsBetween := GetPeriodsBetween(Params.FromDate, GetLastDayOfLastMonth(Params.ToDate));
          end;

          GainLossCalculator := TCalculateGainLoss.Create;

          try
            GainLossCalculator.Calculate(Bank_Account, GetFirstDayOfMonth(Params.ToDate), PartialToDate, PartialGainLoss);

            if PartialGainLoss <> 0 then
            begin
              HasEntries := True;
            end;
          finally
            GainLossCalculator.Free;
          end;
        end
        else
        begin
          PeriodsBetween := GetPeriodsBetween(Params.FromDate, Params.ToDate);
        end;

        for Period := 0 to Length(PeriodsBetween) - 1 do
        begin
          GainLossEntry := Bank_Account.baExchange_Gain_Loss_List.GetPostedEntry(GetLastDayOfMonth(PeriodsBetween[Period]));

          if Assigned(GainLossEntry) then
          begin
            ForexGainOrLoss := ForexGainOrLoss + GainLossEntry.glFields.glAmount;

            if ExchangeGainLossCodes.IndexOf(GainLossEntry.glFields.glAccount) < 0 then
            begin
              ExchangeGainLossCodes.Add(GainLossEntry.glFields.glAccount);
            end;

            HasEntries := True;
          end;
        end;

        ForexGainOrLoss := ForexGainOrLoss + PartialGainLoss;
      end;

      if HasEntries then
      begin
        PutString( bkDate2Str( ClDate ) ) ;

        if ExchangeGainLossCodes.Count > 1 then
        begin
          if ContainsMultiplePeriods then
          begin
            PutString('Exchange Gain/Loss**');
          end
          else
          begin
            PutString('Exchange Gain/Loss');
          end;

          SkipColumn;
        end
        else
        begin
          if ExchangeGainLossCodes.Count > 0 then
          begin
            Account := Chart.FindCode(ExchangeGainLossCodes[0]);
          end
          else
          begin
            Account := Chart.FindCode(Bank_Account.baFields.baExchange_Gain_Loss_Code);
          end;

          if Assigned(Account) then
          begin
            if ContainsMultiplePeriods then
            begin
              PutString(Account.chAccount_Description + '**');

              PutString(Account.chAccount_Code);
            end
            else
            begin
              PutString(Account.chAccount_Description);

              PutString(Account.chAccount_Code);
            end;
          end
          else
          begin
            if ContainsMultiplePeriods then
            begin
              PutString('Exchange Gain/Loss**');
            end
            else
            begin
              PutString('Exchange Gain/Loss');
            end;
            
            SkipColumn;
          end;
        end;

        SkipColumn;
        SkipColumn;
                    
        PutMoneyDontAdd(ForexGainOrLoss);

        RenderDetailLine;

        Rpt.SingleUnderLine;
      end;

      ForexAmountCol.FormatString  := Bank_Account.FmtMoneyStr;
      LocalAmountCol.FormatString  := Client.FmtMoneyStr;

      if ClBalAtBank <> Unknown then
      begin
        PutString( bkDate2Str( ClDate ) ) ;
        PutString( 'Closing Balance' );
        PutString( Bank_Account.baFields.baContra_Account_Code ) ;

        PutMoneyDontAdd( ClBalAtBank );

        Rate := GetLastDayExchangeRate(Bank_Account, CLDate, psUnknown);
        
        if Rate <> 0.0 then
        Begin
          S := Trim( ForexRate2Str( Rate ) );
          PutString( S );
          ClBaseBalAtBank := Round( ClBalAtBank / Rate );
          PutMoneyDontAdd( ClBaseBalAtBank );
        End
        Else
        Begin
          ClBaseBalAtBank := 0;
          SkipColumn;
          SkipColumn;
        end;
        RenderDetailLine;
      end
    end;
  finally
    ExchangeGainLossCodes.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TListForexEntriesReport.BKPrint;
var
  TravMgr: TForexTravManager;
  RateDate: TDateTime;
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

    RenderTextLine('');
    RenderTextLine('');

    RateDate := StDateToDateTime(GetLastDayOfLastMonth(Params.FromDate));

    RenderTextLine(Format('* Opening balances have been calculated using the foreign currency rate as at %s',[FormatDateTime('DD/MM/YY', RateDate)]));

    if GetMonthsBetween(Params.FromDate, Params.ToDate) > 0 then
    begin
      RenderTextLine('** This exchange gain/loss entry has been calculated using the sum of all exchange gain/loss entries for the period');
    end;
  finally
    TravMgr.Free;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CheckExchangeGainLossCodes(ReportParams: ForexParams) : Boolean;
var
  Index: Integer;
  IIndex: Integer;
  BankAccount: TBank_Account;
  ExchangeGainLossCode: String;
begin
  Result := True;

  for Index := 0 to ReportParams.AccountList.Count - 1 do
  begin
    BankAccount := TBank_Account(ReportParams.AccountList[Index]);

    if not TfrmExchangeGainLossCodeEntry.ValidateExchangeGainLossCode(Trim(BankAccount.baFields.baExchange_Gain_Loss_Code)) then
    begin
      ExchangeGainLossCode := BankAccount.baFields.baExchange_Gain_Loss_Code;

      if TfrmExchangeGainLossCodeEntry.EnterExchangeGainLossCode(BankAccount.baFields.baBank_Account_Name, BankAccount.baFields.baCurrency_Code, ExchangeGainLossCode) then
      begin
        BankAccount.baFields.baExchange_Gain_Loss_Code := ExchangeGainLossCode;
      end
      else
      begin
        Result := False;

        Exit;
      end;
    end;
  end;
end;

function ValidateExchangeGainLossEntries(Params: ForexParams; ErrorOccurred: Boolean): Boolean;
var
  Index: Integer;
  BankAccount: TBank_Account;
  CalculatedGainLoss: Money;
  GainLossCalculator: TCalculateGainLoss;
  PeriodsBetween: TDateList;
  PeriodIndex: Integer;
  GainLossEntry: TExchange_Gain_Loss;
  LastDayOfPeriod: TStDate;
begin
  ErrorOccurred := False;
  
  Result := True;

  SetLength(PeriodsBetween, 0);

  if IsPartialPeriod(Params.ToDate) then
  begin
    if GetMonthsBetween(Params.FromDate, Params.ToDate) > 0 then
    begin
      PeriodsBetween := GetPeriodsBetween(Params.FromDate, GetLastDayOfLastMonth(Params.ToDate));
    end;
  end
  else
  begin
    PeriodsBetween := GetPeriodsBetween(Params.FromDate, Params.ToDate);
  end;

  if Length(PeriodsBetween) > 0 then
  begin
    GainLossCalculator := TCalculateGainLoss.Create;

    try
      for Index := 0 to Params.AccountList.Count - 1 do
      begin
        BankAccount := TBank_Account(Params.AccountList[Index]);

        for PeriodIndex := 0 to Length(PeriodsBetween) - 1 do
        begin
          LastDayOfPeriod := GetLastDayOfMonth(PeriodsBetween[PeriodIndex]);
          
          if (BankAccount.GetNrTransactions(PeriodsBetween[PeriodIndex], LastDayOfPeriod) = 0) or
             BankAccount.HasTransactionsWithin(PeriodsBetween[PeriodIndex], LastDayOfPeriod, True) then
          begin
            if not BankAccount.LastTransactionFinalizedOrTransferred(PeriodsBetween[PeriodIndex]) then
            begin
              try
                GainLossCalculator.Calculate(BankAccount, PeriodsBetween[PeriodIndex], LastDayOfPeriod, CalculatedGainLoss);

                GainLossEntry := BankAccount.baExchange_Gain_Loss_List.GetPostedEntry(LastDayOfPeriod);

                if Assigned(GainLossEntry) then
                begin
                  if (CalculatedGainLoss <> GainLossEntry.glFields.glAmount) or (GainLossEntry.glFields.glAccount <> BankAccount.baFields.baExchange_Gain_Loss_Code) then
                  begin
                    Result := False;

                    Exit;
                  end;
                end
                else
                begin
                  if CalculatedGainLoss <> 0 then
                  begin
                    Result := False;

                    Exit;
                  end;
                end;
              except
                on E: Exception do
                begin
                  HelpfulWarningMsg(E.Message, 0);

                  ErrorOccurred := True;

                  Exit;
                end;
              end;
            end;
          end;
        end;
      end;
    finally
      GainLossCalculator.Free;
    end;
  end;
end;

function CheckExchangeRatesExist(ExchangeSource: TExchangeSource; ReportParams: ForexParams; RptBatch: TReportBase): Boolean;

  function PeriodFullyLocked(BankAccount: TBank_Account; FirstDayOfPeriod, LastDayOfPeriod: TStDate; PartialPeriod: Boolean): Boolean;
  begin
    if PartialPeriod then //Partial period cannot be considered as fully finalized/transferred even if all transactions upto the current date are
    begin
      Result := False;
    end
    else
    begin
      Result := BankAccount.AllFinalizedOrTransferred(FirstDayOfPeriod, LastDayOfPeriod); 
    end;
  end;

  function CheckTransactionExchangeRates(BankAccount: TBank_Account; IsoIndex: Integer; FromDate, ToDate: TStDate): Boolean;
  var
    Index: Integer;
    Transaction: pTransaction_Rec;
    ExchangeRecord: TExchangeRecord;
  begin
    Result := True;
    
    for Index := 0 to BankAccount.baTransaction_List.ItemCount - 1 do
    begin
      Transaction := BankAccount.baTransaction_List.Transaction_At(Index);

      if not (Transaction.txUPI_State in[upUPC, upUPD, upUPW, upReversedUPC, upReversalOfUPC, upReversedUPD, upReversalOfUPD, upReversedUPW, upReversalOfUPW])  then
      begin
        if (Transaction.GainLossForexDate >= FromDate) and (Transaction.GainLossForexDate <= ToDate) then
        begin
          if not Transaction.Locked then
          begin
            ExchangeRecord := ExchangeSource.GetDateRates(Transaction.GainLossForexDate);

            if Assigned(ExchangeRecord) then
            begin
              if ExchangeRecord.Rates[IsoIndex] = 0 then
              begin
                Result := False;

                Exit;
              end;
            end
            else
            begin
              Result := False;

              Exit;
            end;
          end;
        end;
      end;
    end;
  end;

var
  BankAccount: TBank_Account;
  LastDayOfLastPeriod: Integer;
  Index: Integer;
  MissingRateList: TStringList;
  CurrencyList: String;
  ToDate: TStDate;
  PeriodList: TDateList;
  FirstDayOfCurrentPeriod: TStDate;
  PeriodIndex: Integer;
  LastDayOfCurrentPeriod: TStDate;
  PartialPeriod: Boolean;
  IsoIndex: Integer;
begin
  MissingRateList := TStringList.Create;

  try
    PeriodList := GetPeriodsBetween(ReportParams.FromDate, ReportParams.ToDate);

    for Index := 0 to Pred( ReportParams.AccountList.Count ) do
    begin
      BankAccount := ReportParams.AccountList[Index];

      if BankAccount.HasTransactionsWithin(ReportParams.FromDate, ReportParams.ToDate, False) then
      begin
        PartialPeriod := False;

        IsoIndex := ExchangeSource.GetISOIndex(BankAccount.baFields.baCurrency_Code, ExchangeSource.Header); 

        for PeriodIndex := 0 to Length(PeriodList) - 1 do
        begin
          FirstDayOfCurrentPeriod := PeriodList[PeriodIndex];

          LastDayOfCurrentPeriod := GetLastDayOfMonth(FirstDayOfCurrentPeriod);

          LastDayOfLastPeriod := GetLastDayOfLastMonth(FirstDayOfCurrentPeriod);
          
          if IsPartialPeriod(LastDayOfCurrentPeriod) then
          begin
            ToDate := GetLastTransactionDate(BankAccount);

            PartialPeriod := True;
          end
          else
          begin
            ToDate := LastDayOfCurrentPeriod;
          end;

          if GetLastDayExchangeRate(BankAccount, IsoIndex, ExchangeSource, LastDayOfLastPeriod, False, psUnknown) <> 0 then //Rate of opening balance
          begin
            if not PeriodFullyLocked(BankAccount, FirstDayOfCurrentPeriod, LastDayOfCurrentPeriod, PartialPeriod) then //If fully finalized/transferred then skip checking the transaction rates
            begin
              if GetLastDayExchangeRate(BankAccount, IsoIndex, ExchangeSource, ToDate, PartialPeriod, psNotFullyLocked) <> 0 then //Rate of closing balance
              begin
                if not CheckTransactionExchangeRates(BankAccount, IsoIndex, FirstDayOfCurrentPeriod, ToDate) then //Rate of all transactions for the period excluding finalized/transferred
                begin
                  if MissingRateList.IndexOf(BankAccount.baFields.baCurrency_Code) < 0 then
                  begin
                    MissingRateList.Add(BankAccount.baFields.baCurrency_Code);
                  end;
                end;
              end
              else
              begin
                if MissingRateList.IndexOf(BankAccount.baFields.baCurrency_Code) < 0 then
                begin
                  MissingRateList.Add(BankAccount.baFields.baCurrency_Code);
                end;
              end;
            end
            else
            begin
              if GetLastDayExchangeRate(BankAccount, IsoIndex, ExchangeSource, LastDayOfCurrentPeriod, False, psFullyLocked) = 0 then //Closing balance rate. Fully finalized/transferred but may not have a transaction on the last day
              begin
                if MissingRateList.IndexOf(BankAccount.baFields.baCurrency_Code) < 0 then
                begin
                  MissingRateList.Add(BankAccount.baFields.baCurrency_Code);
                end;              
              end;
            end;
          end
          else
          begin
            if MissingRateList.IndexOf(BankAccount.baFields.baCurrency_Code) < 0 then
            begin
              MissingRateList.Add(BankAccount.baFields.baCurrency_Code);
            end;      
          end;
        end;
      end;
    end;

    if MissingRateList.Count > 0 then
    begin
      for Index := 0 to MissingRateList.Count - 1 do
      begin
        if CurrencyList <> '' then
        begin
          if Index + 1 < MissingRateList.Count then
          begin
            CurrencyList := CurrencyList + ', ';
          end
          else
          begin
            CurrencyList := CurrencyList + ' and ';
          end;
        end;

        CurrencyList := CurrencyList + MissingRateList[Index];
      end;

      if ReportParams.BatchRun then
      begin
        RptBatch.RunResult := 'There are missing exchange rates for '
          + CurrencyList + ' in the date range '
          + bkDate2Str(GetLastDayOfLastMonth(ReportParams.FromDate)) + ' to ' + bkDate2Str(ReportParams.ToDate) + '.';
      end
      else
      begin
        HelpfulWarningMsg( 'There are missing exchange rates for '
          + CurrencyList + ' in the date range '
          + bkDate2Str(GetLastDayOfLastMonth(ReportParams.FromDate)) + ' to ' + bkDate2Str(ReportParams.ToDate) + '.', 0 ) ;
      end;

      Result := False;
    end
    else
    begin
      Result := True;
    end;
  finally
     MissingRateList.Free;
  end;
end;

procedure DoListForexEntriesReport( Dest: TReportDest; RptBatch: TReportBase = nil;
                                    MonthEndStr: string = ''; ReportInfo: Pointer = nil) ;
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
  DT: TDateTime;
  MonthStartInt, MonthEndInt: integer;
  RateFromDate: Integer;
  ErrorOccurred: Boolean;
  PeriodList: TDateList;
  PeriodIndex: Integer;
  ExchangeSource: TExchangeSource;
begin
  ExchangeSource := CreateExchangeSource;

  try
    LParams := ForexParams.Create(ord(Report_Foreign_Exchange) , MyClient, RptBatch, dPeriod ) ;

    if (MonthEndStr <> '') then
    begin
      MonthEndInt := bkStr2Date(MonthEndStr);
      DT := StrToDate(MonthEndStr);
      DT := IncDay(DT, 1);
      DT := IncMonth(DT, -1);
      MonthStartInt := DateTimeToStDate(DT);
      LParams.FromDate := MonthStartInt;
      LParams.ToDate := MonthEndInt;
    end;

    if ReportInfo <> nil then
    begin
      LParams.CalculatedGainLossEntries := TMonthEndings(ReportInfo);
      LParams.UsePrecalculatedGainLoss := True;
    end
    else
    begin
      LParams.UsePrecalculatedGainLoss := False;
    end;

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
              dumy,
              False,
              True) then
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
              RptBatch.RunResult := 'No Entries in date range, '
                + bkDate2Str( LParams.FromDate ) + ' to ' + bkDate2Str(
                  LParams.Todate ) + '.';

              Exit;
              // Was meant to run direct... Just Exit
            end
            else
            begin
              HelpfulWarningMsg( 'There are no Entries for this client in the date range, '
                + bkDate2Str( LParams.FromDate ) + ' to ' + bkDate2Str(
                  LParams.Todate ) + '.', 0 ) ;
                
              Continue;
            end;


          { Check for exchange rates
            Note: in theory this can be replaced with MyClient.HasExchangeRates,
            so that RefreshExchangeSource doesn't need to be called explicitly
            anymore. Unfortunately I'm not sure how LParams.AccountList is
            build up. It may just be a subset of "all" bank accounts (the default
            for MyClient.HasExchangeRates).
          }
          MyClient.RefreshExchangeSource;

          if not LParams.UsePrecalculatedGainLoss then
          begin
            if not CheckExchangeRatesExist(ExchangeSource, LParams, RptBatch) then
            begin
              Exit;
            end;
          end;

        end; //While HasSomeEntries

        if not LParams.UsePrecalculatedGainLoss then
        begin
          if not CheckExchangeGainLossCodes(LParams) then
          begin
            Exit;
          end;
        end;

        if not LParams.UsePrecalculatedGainLoss then
        begin
          if not ValidateExchangeGainLossEntries(LParams, ErrorOccurred) then
          begin
            if not ErrorOccurred then
            begin
              if AskYesNo('Generate Exchange Gain/Loss entries', 'In order to run this report Exchange Gain/Loss entries are required to be generated.' + #10#13#10#13 + 'Would you like ' + ShortAppName + ' to generate the Exchange Gain/Loss entries now?', DLG_YES, 0) = DLG_YES then
              begin
                if IsPartialPeriod(LParams.ToDate) then
                begin
                  PeriodList := GetPeriodsBetween(LParams.FromDate, GetLastDayOfLastMonth(LParams.ToDate));
                end
                else
                begin
                  PeriodList := GetPeriodsBetween(LParams.FromDate, LParams.ToDate);
                end;

                for PeriodIndex := 0 to Length(PeriodList) - 1 do
                begin
                  if not PostGainLossEntries(LParams.Client, PeriodList[PeriodIndex], GetLastDayOfMonth(PeriodList[PeriodIndex])) then
                  begin
                    Exit;
                  end;
                end;
              end
              else
              begin
                Continue;
              end;
            end
            else
            begin
              Exit;
            end;
          end;
        end;
        
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
            AddColAuto( Job, cleft, 12.0, Gcgap, 'Account', jtLeft ) ;
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
  finally
    FreeAndNil(ExchangeSource);
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

procedure ForexParams.SetCalculatedGainLossEntries(const Value: TMonthEndings);
begin
  FCalculatedGainLossEntries := Value;
end;

procedure ForexParams.SetUsePrecalculatedGainLoss(const Value: Boolean);
begin
  FUsePrecalculatedGainLoss := Value;
end;

end.
