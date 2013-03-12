unit baObj32;
//------------------------------------------------------------------------------
{
   Title:       BaObj32

   Description: Bank Account Object

   Remarks:

   Author:

}
//------------------------------------------------------------------------------
interface
uses
  bkdateutils,classes, bkdefs, iostream, trxList32, mxList32, moneydef, MatchedItemsList,
  MemorisationsObj, AuditMgr, glList32, frList32;

type
  pDailyBalancesRec = ^tDailyBalancesRec;
  tDailyBalancesRec = Array[ 0..366 ] of Money;

type
  TBank_Account = class
//    baClient : TObject;
    baFields : tBank_Account_Rec;
    baTransaction_List : tTransaction_List;
    baOld_Memorised_Transaction_List : tMemorised_Transaction_List_V53;
    baMemorisations_List : MemorisationsObj.TMemorisations_List;
    baExchange_Gain_Loss_List: TExchange_Gain_Loss_List;
    baFinalized_Exchange_Rate_List: TFinalized_Exchange_Rate_List;
  private
    FMatched_Items_List : tMatched_Items_List;
    FClient : TObject;
    procedure ApplyDefaultGST(pT: pTransaction_Rec);
    function GetAuditMgr: TAuditManager;
  public
    constructor  Create(AClient: TObject);
    destructor   Destroy; override;
    procedure    SaveToFile(var s: TIOStream);
    procedure    LoadFromFile(var s: TIOStream);
    procedure    CalculateBalances( YSD : LongInt );
    procedure    CalculatePDBalances( D1, D2 : LongInt; VAR OpBankBal, ClBankBal, OpCashbookBal, ClCashbookBal : Money );
    procedure    CalculatePDBalancesInLocalCurrency( D1, D2 : LongInt;
                    Out LocalOpBankBal, LocalClBankBal, LocalOpCashbookBal, LocalClCashbookBal,
                        LocalBankMovement, LocalCashbookMovement, LocalBankForexGainOrLoss, LocalCashbookForexGainOrLoss : Money );

    procedure    UpdateSequenceNumbers;

    function     IsAJournalAccount : boolean;

    function     FindOriginalItem( Match_ID : integer) : pTransaction_Rec;
    function     MatchChildCount( OrigTrans : pTransaction_Rec) : integer;

    function     MaxHistoricalDate: Integer;
    procedure    UpdateCRC(var CRC : LongWord);

    function MoneyStrNoSymbol( Const Amount : Money ): String;
    function MoneyStr( const Amount : Money ): String;
    function MoneyStrBrackets( const Amount : Money ): String;
    function BalanceStr( const Amount : Money ): String;
    function BalanceStrNoSymbol( const Amount : Money ): String;
    function DrCrStr( const Amount : Money ): String;
    function DrCrStrNoSymbol( const Amount : Money ): String;
    function FmtBalanceStr : String;
    function FmtMoneyStr : String;
    function FmtMoneyStrBrackets : String;
    function CurrencySymbol : String;
    function HasTransactionsWithin( StartDate, EndDate : Integer; SkipFinalizedOrTransferred: Boolean = False): Boolean;
    function IsAForexAccount : Boolean;
    function IsManual: Boolean;
    function CanEditTransactions: Boolean;
    function IsAnEldersAccount : Boolean;
    function Default_Forex_Conversion_Rate( ADate : Integer ): Double;
    function Default_Forex_Concersion_DateRange: TDateRange;
    function Local_Currency_Equivalent( const Foreign_Currency_Amount : Money; const AsAt : Integer; Out Rate : Double ): Money;
    function Title : String;
    function AccountName: string;
    function ValidPayeeCode(PayeeNumber: integer): Boolean;
    function HasExchangeRates(StartDate, EndDate: Integer; StoreRates: boolean = false; SkipFinalizedOrTransferred: Boolean = False): Boolean;
    procedure DoAudit(ABankAccountCopy: TBank_Account;
                      var AAuditTable: TAuditTable);

    function LastTransactionFinalizedOrTransferred(FirstDayOfMonth: Integer): Boolean;
    function AllFinalizedOrTransferred(StartDate, EndDate: Integer): Boolean;

    function FindTransaction(TransactionDate: Integer; out Transaction: pTransaction_Rec): Boolean;

    property AuditMgr: TAuditManager read GetAuditMgr;                  
  end;

const
   UserDefinedBankAccountDesc   = 'Manual Bank Account';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation
uses
   Tokens,
   LogUtil,
   bkbaio,
   dateDef,
   ovcDate,
   bkconst,
   SysUtils,
   Globals,
   MoneyUtils,
   clObj32,
   bkdbExcept,
   bkcrc,
   PayeeObj,
   InfoMoreFrm,
   ForExHelpers,
   ExchangeRateList,
   GSTCALC32;

const
  UnitName = 'BAOBJ32';

var
   DebugMe : Boolean = false;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TBank_Account.AccountName: string;
begin
 With baFields do Begin
    if IsAForexAccount then
      Result := Format( '%s (%s)', [ baBank_Account_Name, baCurrency_Code ] )
    else
      Result := baBank_Account_Name
  end;
end;

function TBank_Account.BalanceStr( const Amount : Money): String;
begin
  Result := MoneyUtils.BalanceStr( Amount, baFields.baCurrency_Code );
end;

function TBank_Account.BalanceStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStrNoSymbol( Amount );
end;

procedure TBank_Account.CalculateBalances( YSD : LongInt );
const
  ThisMethodName = 'TBank_Account.CalculateBalances';

   procedure SetBalances(var Accumulator : TLBRec; Balance : Money);
   var
     p : byte;
   begin
     for p := 1 to 12 do
     begin
       Accumulator.This_Year[p] := Balance;
       Accumulator.Last_Year[p] := Balance;
     end;
   end;


Var
   LastYearStartDate : LongInt;
   ThisYear : tPeriod_End_Dates; { in DATEDEF }
   LastYear : tPeriod_End_Dates; { in DATEDEF }
   D, M, Y  : Integer;
   p : Byte;
   E : LongInt;
   Amount : Money;
   Forex : Boolean;

   procedure ForexBalance(var Accumulator : TLBRec);
   var
      er: Double;
      p: byte;
   begin
      for p := 1 to 12 do begin
         Accumulator.This_Year[p] := Local_Currency_Equivalent(Accumulator.This_Year[p],ThisYear[p], er);
         Accumulator.Last_Year[p] := Local_Currency_Equivalent(Accumulator.Last_Year[p],LastYear[p], er);
      end;
   end;

Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );
   StDateToDMY( YSD, D, M, Y );
   LastYearStartDate := bkDateUtils.GetPrevYearStartDate( YSD );
   GetPEDates( YSD, ThisYear );
   GetPEDates( LastYearStartDate, LastYear );

   Forex := IsAForexAccount;

   {  ----------------------------------------------------------------  }

   With baFields do
   Begin
      SetBalances(baOpening_Bank_Balance,      baCurrent_Balance);
      SetBalances(baClosing_Bank_Balance,      baCurrent_Balance);
      SetBalances(baOpening_CashBook_Balance,  baCurrent_Balance);
      SetBalances(baClosing_CashBook_Balance,  baCurrent_Balance);

      FillChar(baBank_Movement, Sizeof( baBank_Movement ), 0 );
      FillChar(baCashBook_Movement, Sizeof( baCashBook_Movement ), 0 );

      {  ----------------------------------------------------------------  }

      With baTransaction_List do For E := 0 to Pred( itemCount ) do With Transaction_At( E )^ do
      Begin
         Amount := txAmount;

         If ( txDate_Presented <> 0 ) then
         Begin { It is a presented transaction }

            For p := 1 to 12 do
            Begin
               {  -------------------------------------------------------  }
               { Update the Bank Balance þ This Year                       }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Presented, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Within : baBank_Movement.This_Year[p] := baBank_Movement.This_Year[p] + Amount;
               end; { of Case }

               {  -------------------------------------------------------  }
               { Update the Bank Balance þ Last Year                       }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Presented, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Within : baBank_Movement.Last_Year[p] := baBank_Movement.Last_Year[p] + Amount;
               end; { of Case }

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ This Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Within : baCashBook_Movement.This_Year[p] := baCashBook_Movement.This_Year[p] + Amount;
               end;

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ Last Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Within : baCashBook_Movement.Last_Year[p] := baCashBook_Movement.Last_Year[p] + Amount;
               end;
            end;
         end
         else { It's an Unpresented Item, so just update the CashBook Balances }
         Begin
            For p := 1 to 12 do
            Begin
               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ This Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Within : baCashBook_Movement.This_Year[p] := baCashBook_Movement.This_Year[p] + Amount;
               end;

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ Last Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Within : baCashBook_Movement.Last_Year[p] := baCashBook_Movement.Last_Year[p] + Amount;
               end;
            end; { of p }
         end;
      end;

      {  ----------------------------------------------------------------  }

      If baCurrent_Balance = Unknown then
      begin
        if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Balance Unknown' );
        exit;
      end;

      {  ----------------------------------------------------------------  }

      With baTransaction_List do For E := 0 to Pred( itemCount ) do With Transaction_At( E )^ do
      Begin
         Amount := txAmount;

         If ( txDate_Presented <> 0 ) then
         Begin { It is a presented transaction }
            For p := 1 to 12 do
            Begin
               {  -------------------------------------------------------  }
               { Update the Bank Balance þ This Year                       }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Presented, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Earlier: ;
                  Within : baOpening_Bank_Balance.This_Year[p] := baOpening_Bank_Balance.This_Year[p] - Amount;
                  Later  : Begin
                              baOpening_Bank_Balance.This_Year[p] := baOpening_Bank_Balance.This_Year[p] - Amount;
                              baClosing_Bank_Balance.This_Year[p] := baClosing_Bank_Balance.This_Year[p] - Amount;
                           end;
               end; { of Case }

               {  -------------------------------------------------------  }
               { Update the Bank Balance þ Last Year                       }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Presented, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Earlier: ;
                  Within : baOpening_Bank_Balance.Last_Year[p] := baOpening_Bank_Balance.Last_Year[p] - Amount;
                  Later  : Begin
                              baOpening_Bank_Balance.Last_Year[p] := baOpening_Bank_Balance.Last_Year[p] - Amount;
                              baClosing_Bank_Balance.Last_Year[p] := baClosing_Bank_Balance.Last_Year[p] - Amount;
                           end;
               end; { of Case }

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ This Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Earlier : ;
                  Within : baOpening_CashBook_Balance.This_Year[p] := baOpening_CashBook_Balance.This_Year[p] - Amount;
                  Later  : Begin
                              baOpening_CashBook_Balance.This_Year[p] := baOpening_CashBook_Balance.This_Year[p] - Amount;
                              baClosing_CashBook_Balance.This_Year[p] := baClosing_CashBook_Balance.This_Year[p] - Amount;
                           end;
               end;

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ Last Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Earlier : ;
                  Within : baOpening_CashBook_Balance.Last_Year[p] := baOpening_CashBook_Balance.Last_Year[p] - Amount;
                  Later  : Begin
                              baOpening_CashBook_Balance.Last_Year[p] := baOpening_CashBook_Balance.Last_Year[p] - Amount;
                              baClosing_CashBook_Balance.Last_Year[p] := baClosing_CashBook_Balance.Last_Year[p] - Amount;
                           end;
               end;
            end; { p }
         end
         else { It's an Unpresented Item, so just update the CashBook Balances }
         Begin
            For p := 1 to 12 do
            Begin
               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ This Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, ThisYear[ p-1 ]+1, ThisYear[p] ) of
                  Earlier  :  Begin
                                 baOpening_CashBook_Balance.This_Year[p] := baOpening_CashBook_Balance.This_Year[p] + Amount;
                                 baClosing_CashBook_Balance.This_Year[p] := baClosing_CashBook_Balance.This_Year[p] + Amount;
                              end;
                  Within  :   baClosing_CashBook_Balance.This_Year[p] := baClosing_CashBook_Balance.This_Year[p] + Amount;
                  Later   : ;
               end;

               {  -------------------------------------------------------  }
               { Check The Cashbook Balances þ Last Year                   }
               {  -------------------------------------------------------  }

               Case CompareDates( txDate_Effective, LastYear[ p-1 ]+1, LastYear[p] ) of
                  Earlier  :  Begin
                                 baOpening_CashBook_Balance.Last_Year[p] := baOpening_CashBook_Balance.Last_Year[p] + Amount;
                                 baClosing_CashBook_Balance.Last_Year[p] := baClosing_CashBook_Balance.Last_Year[p] + Amount;
                              end;
                  Within  :   baClosing_CashBook_Balance.Last_Year[p] := baClosing_CashBook_Balance.Last_Year[p] + Amount;
                  Later   : ;
               end;
            end; { of p }
         end;
      end;
      if Forex then begin
         ForexBalance(baOpening_Bank_Balance);
         ForexBalance(baClosing_Bank_Balance);
         ForexBalance(baOpening_CashBook_Balance);
         ForexBalance(baClosing_CashBook_Balance);
         ForexBalance(baBank_Movement);
         ForexBalance(baCashBook_Movement);
      end;
   end;


   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end; { of Calculate Balances }

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TBank_Account.CalculatePDBalances( D1, D2 : LongInt;
   VAR OpBankBal, ClBankBal, OpCashbookBal, ClCashbookBal : Money );
const
  ThisMethodName = 'TBank_Account.CalculatePDBalances';
Var
   E : LongInt;
   Amount : Money;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );

   With baFields do
   Begin
      OpBankBal      := baCurrent_Balance;
      ClBankBal      := baCurrent_Balance;
      OpCashbookBal  := baCurrent_Balance;
      ClCashbookBal  := baCurrent_Balance;

      If baFields.baCurrent_Balance = Unknown then
      begin
        if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Balance Unknown');
        exit;
      end;

      With baTransaction_List do For E := 0 to Pred( itemCount ) do With Transaction_At( E )^ do
      Begin
         Amount := txAmount;

         If txDate_Presented <> 0 then
         Begin
            Case CompareDates( txDate_Presented, D1, D2 ) of
               Earlier: ;
               Within : Begin
                           OpBankBal := OpBankBal - Amount;
                        end;
               Later  : Begin
                           OpBankBal := OpBankBal - Amount;
                           ClBankBal := ClBankBal - Amount;
                        end;
            end;

            Case CompareDates( txDate_Effective, D1, D2 ) of
               Earlier : ;
               Within : Begin
                           OpCashbookBal := OpCashbookBal - Amount;
                        end;
               Later  : Begin
                           OpCashbookBal := OpCashbookBal - Amount;
                           ClCashbookBal := ClCashbookBal - Amount;
                        end;
            end;
         end
         else { Unpresented }
            Case CompareDates( txDate_Effective, D1, D2 ) of
               Earlier:  Begin
                            OpCashbookBal := OpCashbookBal + Amount;
                            ClCashbookBal := ClCashbookBal + Amount;
                         end;
               Within  : ClCashbookBal := ClCashbookBal + Amount;
               Later   : ;
            end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure TBank_Account.CalculatePDBalancesInLocalCurrency( D1, D2 : LongInt;
   Out LocalOpBankBal, LocalClBankBal, LocalOpCashbookBal, LocalClCashbookBal,
   LocalBankMovement, LocalCashbookMovement, LocalBankForexGainOrLoss, LocalCashbookForexGainOrLoss : Money );
const
  ThisMethodName = 'TBank_Account.CalculatePDBalancesInLocalCurrency';
Var
   E : Integer;
   OPRate : Double;
   ClRate : Double;
   ForeignOpBankBal, ForeignClBankBal, ForeignOpCashbookBal, ForeignClCashbookBal : Money;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );

   CalculatePDBalances( D1, D2, ForeignOpBankBal, ForeignClBankBal, ForeignOpCashbookBal, ForeignClCashbookBal );

   LocalOpBankBal     := Local_Currency_Equivalent( ForeignOpBankBal, D1, OpRate );
   LocalClBankBal     := Local_Currency_Equivalent( ForeignClBankBal, D2, ClRate );
   LocalOpCashbookBal := Local_Currency_Equivalent( ForeignOpCashbookBal, D1, OpRate );
   LocalClCashbookBal := Local_Currency_Equivalent( ForeignClCashbookBal, D2, ClRate );

   LocalBankMovement            := 0;
   LocalCashbookMovement        := 0;

   With baTransaction_List do For E := 0 to Pred( itemCount ) do With Transaction_At( E )^ do
   Begin
      If txDate_Presented <> 0 then
      Begin
         Case CompareDates( txDate_Presented, D1, D2 ) of
            Earlier: ;
            Within : Begin
                        LocalBankMovement := LocalBankMovement + txAmount;
                     end;
            Later  : ;
         end;
         Case CompareDates( txDate_Effective, D1, D2 ) of
            Earlier : ;
            Within : Begin
                        LocalCashbookMovement := LocalCashbookMovement + txAmount;
                     end;
            Later  : ;
         end;
      end
      else { Unpresented }
         Case CompareDates( txDate_Effective, D1, D2 ) of
            Earlier : ;
            Within  : Begin
                        LocalCashbookMovement := LocalCashbookMovement + txAmount;
                      End;
            Later   : ;
         end;
   end;

   LocalBankForexGainOrLoss := ( LocalClBankBal - LocalOpBankBal ) - LocalBankMovement;
   LocalCashbookForexGainOrLoss := ( LocalClCashbookBal - LocalOpCashbookBal ) - LocalCashbookMovement;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.CanEditTransactions: Boolean;
begin
   Result := IsManual;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TBank_Account.Create(AClient: TObject);
const
  ThisMethodName = 'TBank_Account.Create';
var
  Msg : string;
  AuditMgr: TClientAuditManager;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;

   if Assigned(AClient) and (AClient is TClientObj) then
     FClient := AClient;

   FillChar( baFields, Sizeof( baFields ), 0 );
   With baFields do
   Begin
      baRecord_Type := tkBegin_Bank_Account;
      baEOR := tkEnd_Bank_Account;
   end;

   baTransaction_List           := nil;
   baTransaction_List := TTransaction_List.Create( NIL, Self, NIL );
   If not Assigned( baTransaction_List ) then
   Begin
      Msg := Format( '%s : Unable to Allocate baTransaction_List',[ThisMethodName]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   FMatched_Items_List := tMatched_Items_List.Create( NIL, Self, NIL );   // No longer used

   AuditMgr := nil;
   if Assigned(FClient) then
     AuditMgr := TClientObj(FClient).ClientAuditMgr;

   baMemorisations_List := TMemorisations_List.Create(AuditMgr);
   baOld_Memorised_Transaction_List := TMemorised_Transaction_List_V53.Create;

   baExchange_Gain_Loss_List := TExchange_Gain_Loss_List.Create(AuditMgr);

   baFinalized_Exchange_Rate_List := TFinalized_Exchange_Rate_List.Create;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.CurrencySymbol: String;
begin
  Result := MoneyUtils.CurrencySymbol( baFields.baCurrency_Code );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account.Default_Forex_Concersion_DateRange: TDateRange;
begin
  Result.FromDate := MinValidDate;
  Result.ToDate := MaxValidDate;
end;

function TBank_Account.Default_Forex_Conversion_Rate(ADate: Integer): Double;
Var
  BCode : String[3];
  CCode : String[3];
  Client : TClientObj;
  IsoIndex: integer;
  ExchangeRate: TExchangeRecord;
begin
  Result := 0.0;
  if IsAForexAccount then
  Begin
    BCode := baFields.baCurrency_Code;
//    Client := TClientObj( baClient );
    Client := TClientObj( FClient );
    if Assigned(Client.ExchangeSource) then begin
      CCode := Client.clExtra.ceLocal_Currency_Code;
      IsoIndex := Client.ExchangeSource.GetISOIndex(BCode,
                                                    Client.ExchangeSource.Header);
      if IsoIndex <> 0 then begin
        ExchangeRate := Client.ExchangeSource.GetDateRates(ADate);
        if Assigned(ExchangeRate) then
          Result := ExchangeRate.Rates[IsoIndex];
      end;
    end;
  End;
end;

destructor TBank_Account.Destroy;
const
  ThisMethodName = 'TBank_Account.Destroy';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
   baTransaction_List.Free;
   baOld_Memorised_Transaction_List.Free;
   baMemorisations_List.Free;
   FreeAndNil(baExchange_Gain_Loss_List);
   FreeAndNil(baFinalized_Exchange_Rate_List);
   FMatched_Items_List.Free;
   BKBAIO.Free_Bank_Account_Rec_Dynamic_Fields( baFields);

   inherited Destroy;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

procedure TBank_Account.DoAudit(ABankAccountCopy: TBank_Account; 
  var AAuditTable: TAuditTable);
var
  TransactionList: TTransaction_List;
  MemorisationsList: TMemorisations_List;
  GainLossList: TExchange_Gain_Loss_List;
begin
  //Audit transactions
  TransactionList := nil;
  if Assigned(ABankAccountCopy) then
    TransactionList := ABankAccountCopy.baTransaction_List;
  baTransaction_List.DoAudit(TransactionList,
                             baFields.baAudit_Record_ID,
                             baFields.baAccount_Type,
                             AAuditTable);
  //Audit memorisations
  MemorisationsList := nil;
  if Assigned(ABankAccountCopy) then
    MemorisationsList := ABankAccountCopy.baMemorisations_List;
  baMemorisations_List.DoAudit(MemorisationsList,
                               baFields.baAudit_Record_ID,
                               AAuditTable);

  //Exchange Gain/Loss
  GainLossList := nil;
  if Assigned(ABankAccountCopy) then
    GainLossList := ABankAccountCopy.baExchange_Gain_Loss_List;
  baExchange_Gain_Loss_List.DoAudit(GainLossList,
                                    baFields.baAudit_Record_ID,
                                    AAuditTable);
end;

function TBank_Account.DrCrStr(const Amount: Money): String;
begin
  Result := MoneyUtils.DrCrStr( Amount, baFields.baCurrency_Code );
end;

function TBank_Account.DrCrStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.DrCrStrNoSymbol( Amount );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function TBank_Account.IsAForexAccount: Boolean;
begin
  if FClient = NIL then
     Result := False
  else
  begin
    Result := TClientObj(FClient).clExtra.ceLocal_Currency_Code <> baFields.baCurrency_Code;
  end;
end;

function TBank_Account.IsAJournalAccount: boolean;
const
  ThisMethodName = 'TBank_Account.IsAJournalAccount';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );

   With baFields do IsAJournalAccount := ( baAccount_Type<>btBank );

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.IsAnEldersAccount: Boolean;
var
  Client : TClientObj;
begin
  Result := False;
  if Assigned(FClient) then begin
    Client := TClientObj( FClient );
    Result := ( Client.clFields.clCountry = whAustralia ) and
              ( Copy( baFields.baBank_Account_Number, 1, 2 ) = BKconst.EldersPrefix );
  end;
end;

function TBank_Account.IsManual: Boolean;
begin
   result := baFields.baIs_A_Manual_Account;
end;

//------------------------------------------------------------------------------
function TBank_Account.LastTransactionFinalizedOrTransferred(FirstDayOfMonth: Integer): Boolean;
var
  LastDayOfMonth: Integer;
  Index: Integer;
  Transaction: pTransaction_Rec;
begin
  Result := False;
  
  LastDayOfMonth := GetLastDayOfMonth(FirstDayOfMonth);

  for Index := 0 to baTransaction_List.ItemCount - 1 do
  begin
    Transaction := baTransaction_List.Transaction_At(Index);

    if Transaction.txDate_Effective >= FirstDayOfMonth then
    begin
      if Index + 1 < baTransaction_List.ItemCount then
      begin
        if baTransaction_List.Transaction_At(Index + 1).txDate_Effective > LastDayOfMonth then
        begin
          Result := Transaction.Locked;
        end;
      end
      else
      begin
        Result := Transaction.Locked;
      end;
    end;
  end;
end;

procedure TBank_Account.LoadFromFile(var s : TIOStream);
const
  ThisMethodName = 'TBank_Account.LoadFromFile';
Var
   Token : Byte;
   Done : boolean;
   Msg : string;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   done := false;
   Token := tkBegin_Bank_Account;
   While ( Token <> tkEndSection ) and not Done do
   Begin
      Case Token of
         tkBegin_Bank_Account    : Read_Bank_Account_Rec ( baFields, S );
         tkBeginEntries          : baTransaction_List.LoadFromFile( S );
         tkBeginMemorisedEntries : baOld_Memorised_Transaction_List.LoadFromFile( S );
         tkBeginMatchedItems     : FMatched_Items_List.LoadFromFile( S);
         tkBeginMemorisationsList : baMemorisations_List.LoadFromStream(S);
         tkBeginExchange_Gain_Loss_List: baExchange_Gain_Loss_List.LoadFromFile(S);
         tkBeginFinalized_Exchange_Rate_List: baFinalized_Exchange_Rate_List.LoadFromFile(S);  
         else
         begin { Should never happen }
            Msg := Format( '%s : Unknown Token %d', [ ThisMethodName, Token ] );
            LogUtil.LogMsg(lmError, UnitName, Msg );
            raise ETokenException.CreateFmt( '%s - %s', [ UnitName, Msg ] );
         end;
      end; { of Case }
      Token := S.ReadToken;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.Local_Currency_Equivalent(
  const Foreign_Currency_Amount: Money; const AsAt: Integer;
  out Rate: Double): Money;
begin
  Rate := Default_Forex_Conversion_Rate( AsAt );
  if ( Foreign_Currency_Amount <> 0 ) and ( Rate <> 0.0 ) then
    Result := Round( Foreign_Currency_Amount / Rate )
  else
    Result := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account.SaveToFile(var s :TIOStream);
const
  ThisMethodName = 'TBank_Account.SaveToFile';
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   BKBAIO.Write_Bank_Account_Rec ( baFields, S );

   baTransaction_List.SaveToFile( S );
   baMemorisations_List.SaveToStream( S);
   baExchange_Gain_Loss_List.SaveToFile(S); 
   baFinalized_Exchange_Rate_List.SaveToFile(S);

   //as of version 60.5 this list is no longer used.  It should be removed
   //in future version.  It has only been left in to aid in upgrading from version
   //from 59 - 60.4 which were only released internally
   //baMatched_Items_List.SaveToFile( S);

   S.WriteToken( tkEndSection );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.Title: String;
begin
  With baFields do
  Begin
    if IsAJournalAccount then
       Result := baBank_Account_Name
    else if IsAForexAccount then
       Result := Format( '%s %s (%s)', [ baBank_Account_Number, baBank_Account_Name, baCurrency_Code ] )
    else
       Result := Format( '%s %s', [ baBank_Account_Number, baBank_Account_Name ] )
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TBank_Account.UpdateSequenceNumbers;
const
  ThisMethodName = 'TBank_Account.UpdateSequenceNumbers';
var
  t : integer;
(*
  c : Integer;
  d : pDissection_Rec;
*)

begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with baTransaction_List do
   Begin
      For T := 0 to Pred( ItemCount ) do
      Begin
         With Transaction_At( T )^ do
         Begin
            txBank_Seq := baFields.baNumber;
            (*
            D := txFirst_Dissection;
            C := 0;
            while ( D<>nil ) do
            Begin
               Inc( C );
               D^.dsSequence_No := C;
               D := D^.dsNext;
            end;
            *)
         end;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.ValidPayeeCode(PayeeNumber: integer): Boolean;
const
  SUPER_PAYEE_FUND_MISMATCH = 'This payee cannot be used because the ' +
                              '%s and payee fund types do not match';
var
  Payee: TPayee;
  PayeeLedgerID: integer;
  PayeeLedgerName: string;
  AccountType: string;
  procedure DoMessage;
  begin
    AccountType := 'bank account';
    if IsAJournalAccount  then
      AccountType := 'journal';
    HelpfulInfoMsg( Format(SUPER_PAYEE_FUND_MISMATCH,[AccountType]), 0 );
    Result := False;
  end;
begin
  Result := True;
  //TFS 3557
  case MyClient.clFields.clAccounting_System_Used of
    saDesktopSuper:
      begin
        Payee := MyClient.clPayee_List.Find_Payee_Number(PayeeNumber);
        if Assigned(Payee) and (Payee.pdLines.ItemCount > 0) then
          PayeeLedgerID := Payee.pdLines.PayeeLine_At(0).plSF_Ledger_ID;
          if (PayeeLedgerID <> -1) and
             (baFields.baDesktop_Super_Ledger_ID <> PayeeLedgerID) then
            DoMessage;
      end;
    saClassSuperIP:
      begin
        Payee := MyClient.clPayee_List.Find_Payee_Number(PayeeNumber);
        if Assigned(Payee) and (Payee.pdLines.ItemCount > 0) then
          PayeeLedgerName := Payee.pdLines.PayeeLine_At(0).plSF_Ledger_Name;
          if (PayeeLedgerName <> '') and
             (baFields.baSuperFund_Ledger_Code <> PayeeLedgerName) then
            DoMessage;
      end;
  end;
end;

//------------------------------------------------------------------------------

function TBank_Account.FindOriginalItem(Match_ID: integer): pTransaction_Rec;
//look thru the matched items list for this bank account and find the
//item with this match_id
var
   i : integer;
   t : pTransaction_Rec;
begin
   result := nil;
   if Match_ID = 0 then exit;

   with FMatched_Items_List do for i := 0 to Pred( ItemCount) do begin
      t := Transaction_At( i);
      with t^ do begin
         if txMatched_Item_ID = Match_ID then begin
            result := t;
            exit;
         end;
      end;
   end;
end;

function TBank_Account.FindTransaction(TransactionDate: Integer; out Transaction: pTransaction_Rec): Boolean;
var
  Index: Integer;
  Trans: pTransaction_Rec;
begin
  Result := False;
  
  for Index := 0 to baTransaction_List.ItemCount - 1 do
  begin
    Trans := baTransaction_List.Transaction_At(Index);

    if (Trans.txDate_Effective = TransactionDate) then
    begin            
      Transaction := Trans;
      
      Result := True;
    end;
  end;
end;

function TBank_Account.FmtBalanceStr: String;
begin
  Result := MoneyUtils.FmtBalanceStr( baFields.baCurrency_Code );
end;

function TBank_Account.FmtMoneyStr: String;
begin
  Result := MoneyUtils.FmtMoneyStr( baFields.baCurrency_Code );
end;

function TBank_Account.FmtMoneyStrBrackets: String;
begin
   Result := MoneyUtils.FmtMoneyStrBrackets( baFields.baCurrency_Code );
end;

function TBank_Account.GetAuditMgr: TAuditManager;
begin
  Result := nil;
  if Assigned(FClient) then
    Result := TClientObj(FClient).ClientAuditMgr;
end;

function TBank_Account.AllFinalizedOrTransferred(StartDate, EndDate: Integer): Boolean;
var
  Index: Integer;
  Trans: pTransaction_Rec;
begin
  Result := False;

  for Index := 0 to baTransaction_List.ItemCount - 1 do
  begin
    Trans := baTransaction_List.Transaction_At(Index);

    if (Trans.txDate_Effective >= StartDate) and (Trans.txDate_Effective <= EndDate) then
    begin
      if not Trans.Locked then
      begin
        Result := False;

        Exit;
      end;

      Result := True;
    end;
  end;
end;

procedure TBank_Account.ApplyDefaultGST(pT: pTransaction_Rec);
// This does the same as ApplyDefaultGST in GSTUTIL32 except it doesn't update
//memorisations or payees.
var
  pD : pDissection_Rec;
begin
  //see if locked or transfered, if so skip this entry
  if (pT^.txLocked) or (pT^.txDate_Transferred > 0) then Exit;

  //is it a dissection?
  if pT^.txFirst_Dissection = nil then begin
    if (not pT^.txGST_Has_Been_Edited) then begin
      CalculateGST( MyClient, pT^.txDate_Effective, pT^.txAccount, pT^.txTemp_Base_Amount, pT^.txGST_Class, pT^.txGST_Amount);
      pT^.txGST_Has_Been_Edited := false;
      if baFields.baAccount_Type in JournalsWithNoGSTSet then begin
        if pT^.txGST_Amount <> 0 then begin
          pT^.txGST_Amount := 0;
          pT^.txGST_Has_Been_Edited := True;
          pT^.txTransfered_To_Online := False;
        end;
      end;
    end;
  end else begin
    pD := pT^.txFirst_Dissection;
    while (pD <> nil) do begin
      if ( not pD^.dsGST_Has_Been_Edited) then begin
        if not (pD^.dsJournal_Type in [ jtReversed, jtReversal, jtProcessed]) then begin
          //only recalculate GST if it is not reversed or processed
          CalculateGST( MyClient, pT^.txDate_Effective, pD^.dsAccount, pD^.Local_Amount, pD^.dsGST_Class, pD^.dsGST_Amount);
          pD^.dsGST_Has_Been_Edited := false;
          pT^.txGST_Has_Been_Edited := false;

          if baFields.baAccount_Type in JournalsWithNoGSTSet then begin
            if pD^.dsGST_Amount <> 0 then begin
              pD^.dsGST_Amount := 0;
              pD^.dsGST_Has_Been_Edited := True;
              pT^.txGST_Has_Been_Edited := True;
              pT^.txTransfered_To_Online := False;
            end;
          end;
        end;
      end;
      pD := pD^.dsNext;
    end;
  end;
end;

function TBank_Account.HasExchangeRates(StartDate,
  EndDate: Integer; StoreRates: boolean; SkipFinalizedOrTransferred: Boolean): Boolean;
var
  i: Integer;
  Rate: double;
  T: pTransaction_Rec;
  D: pDissection_Rec;
begin
  Result := True;

  for i := 0 to Pred( baTransaction_List.ItemCount ) do
  begin
    T := baTransaction_List.Transaction_At(i);
    T.txTemp_Base_Amount := 0;
    T.txTemp_Forex_Rate := 0;

    if (T.txDate_Effective >= StartDate) and (T.txDate_Effective <= EndDate) then
    begin
      if (not SkipFinalizedOrTransferred) or not T.Locked then
      begin
        T.txTemp_Base_Amount := T.Local_Amount;
        //Store base amounts in dissection
        if StoreRates and (T.txFirst_Dissection <> nil) then begin
          D := T.txFirst_Dissection;
          while D <> nil do begin
            D.dsTemp_Base_Amount := D.Local_Amount;
            D := D.dsNext;
          end;
        end;
        //Store base amounts in transaction
        if IsAForexAccount then begin
          Rate := T.Default_Forex_Rate;
          T.txTemp_Forex_Rate := Rate;
          if (Rate = 0) then begin
            Result := False;
            if not StoreRates then
              Break; //No need to carry on if not storing rates
          end;
          //This needs to be done before reports are run incase the exchange rate
          //has changed and the base GST amount has not been updated.
          ApplyDefaultGST(T);
        end;
      end;
    end;
  end;
end;

function TBank_Account.HasTransactionsWithin(StartDate, EndDate: Integer; SkipFinalizedOrTransferred: Boolean): Boolean;
Var
  i: Integer;
  T: pTransaction_Rec;
begin
  for i := 0 to Pred( baTransaction_List.ItemCount ) do
  begin
    T := baTransaction_List.Transaction_At(i);

    if (T.txDate_Effective >= StartDate) and (T.txDate_Effective <= EndDate) then
    begin
      if (not SkipFinalizedOrTransferred) or not T.Locked then
      begin
        Result := True;

        Exit;
      end;
    end;
  end;
  Result := False;
end;

//------------------------------------------------------------------------------

function TBank_Account.MatchChildCount(OrigTrans: pTransaction_Rec): integer;
//count how many UPIs were matched against this transaction
var
   i : integer;
   t : pTransaction_Rec;
begin
   result := 0;
   if OrigTrans^.txMatched_Item_ID = 0 then exit;

   with baTransaction_List do for i := 0 to Pred( ItemCount) do begin
      t := Transaction_At( i);
      if t^.txMatched_Item_ID = OrigTrans^.txMatched_Item_ID then begin
         Inc( result);
      end;
   end;
end;

function TBank_Account.MaxHistoricalDate: Integer;
var I: Integer;
begin
   Result := MaxValidDate;
   if baFields.baAccount_Type<>btBank then
      Exit; // Journal..
   if IsManual then
      Exit;
   with baTransaction_List do
      for i := 0 to Pred(itemCount) do
          with Transaction_At(i)^ do
             if (txSource = orBank ) then
                if txDate_Presented > 0 then
                   if txDate_Presented < Result  then begin
                      Result := txDate_Presented -1;
                      Break;  // one should be enough..
                   end;
end;

function TBank_Account.MoneyStr(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStr( Amount, baFields.baCurrency_Code );
end;

function TBank_Account.MoneyStrBrackets(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStrBrackets( Amount, baFields.baCurrency_Code );

end;

function TBank_Account.MoneyStrNoSymbol(const Amount: Money): String;
begin
  Result := MoneyUtils.MoneyStrNoSymbol( Amount );
end;

//------------------------------------------------------------------------------

procedure TBank_Account.UpdateCRC(var CRC: LongWord);
begin
   bkCRC.UpdateCRC( baFields, CRC);
   baTransaction_List.UpdateCRC( CRC);
   baMemorisations_List.UpdateCRC( CRC);
end;

initialization
   DebugMe := DebugUnit(UnitName);
end.
