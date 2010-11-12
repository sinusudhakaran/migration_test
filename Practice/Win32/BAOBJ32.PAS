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
   MemorisationsObj;

type
   pDailyBalancesRec = ^tDailyBalancesRec;
   tDailyBalancesRec = Array[ 0..366 ] of Money;

type
   TBank_Account = class
      baClient : TObject;
      baFields : tBank_Account_Rec;
      baTransaction_List : tTransaction_List;
      baOld_Memorised_Transaction_List : tMemorised_Transaction_List_V53;
      baMemorisations_List : MemorisationsObj.TMemorisations_List;

      constructor  Create;

      destructor   Destroy; override;
  private
      baMatched_Items_List     : tMatched_Items_List;
//      fForex_Info : TExchangeRateFileInfo;
//      function GetForexInfo: TExchangeRateFileInfo;
  public
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


      Function MoneyStrNoSymbol( Const Amount : Money ): String;
      Function MoneyStr( Const Amount : Money ): String;
      Function MoneyStrBrackets( Const Amount : Money ): String;
      Function BalanceStr( Const Amount : Money ): String;
      Function BalanceStrNoSymbol( Const Amount : Money ): String;
      Function DrCrStr( Const Amount : Money ): String;
      Function DrCrStrNoSymbol( Const Amount : Money ): String;
      Function FmtBalanceStr : String;
      Function FmtMoneyStr : String;
      Function FmtMoneyStrBrackets : String;
      Function CurrencySymbol : String;
      Function HasTransactionsWithin( StartDate, EndDate : Integer ): Boolean;
      Function IsAForexAccount : Boolean;
      Function IsAnEldersAccount : Boolean;
      Function Default_Forex_Conversion_Rate( ADate : Integer ): Double;
      function Default_Forex_Concersion_DateRange: TDateRange;
//      Property baForex_Info : TExchangeRateFileInfo read GetForexInfo write fForex_Info;
      Function Local_Currency_Equivalent( Const Foreign_Currency_Amount : Money; Const AsAt : Integer; Out Rate : Double ): Money;
      Function Title : String;
      function AccountName: string;
      function ValidPayeeCode(PayeeNumber: integer): Boolean;
      function HasMissingExchageRates(StartDate, EndDate: Integer): Boolean;
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
   bkConst,
   SysUtils,
   Globals,
   MoneyUtils,
   clObj32,
   bkdbExcept,
   bkcrc,
   PayeeObj,
   InfoMoreFrm,
   ForExHelpers,
   ExchangeRateList;

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
//         if Forex then  // accumulated as forex
//            Amount := txForeign_Currency_Amount
//         else
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
//        if Forex then
//          Amount := txForeign_Currency_Amount
//        else
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
   Forex : Boolean;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Called' );

   Forex := IsAForexAccount;

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
//         if Forex then
//           Amount := txForeign_Currency_Amount
//         else
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

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

constructor TBank_Account.Create;
const
  ThisMethodName = 'TBank_Account.Create';
var
  Msg : string;
begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   inherited Create;

   FillChar( baFields, Sizeof( baFields ), 0 );
   With baFields do
   Begin
      baRecord_Type := tkBegin_Bank_Account;
      baEOR := tkEnd_Bank_Account;
   end;

//   fForex_Info := NIL;

   baTransaction_List           := nil;
   baTransaction_List := TTransaction_List.Create( NIL, Self );
   If not Assigned( baTransaction_List ) then
   Begin
      Msg := Format( '%s : Unable to Allocate baTransaction_List',[ThisMethodName]);
      LogUtil.LogMsg(lmError, UnitName, Msg );
      raise EInsufficientMemory.CreateFmt( '%s - %s', [ UnitName, Msg ] );
   end;

   baMatched_Items_List := tMatched_Items_List.Create( NIL, Self );   // No longer used
   baMemorisations_List := TMemorisations_List.Create;
   baOld_Memorised_Transaction_List := TMemorised_Transaction_List_V53.Create;

   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

function TBank_Account.CurrencySymbol: String;
begin
  Result := MoneyUtils.CurrencySymbol( baFields.baCurrency_Code );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TBank_Account.Default_Forex_Concersion_DateRange: TDateRange;
begin
//   if IsAForexAccount then begin
//      Result.FromDate := baForex_Info.FromDate;
//      Result.ToDate := baForex_Info.ToDate;
//   end else begin
      Result.FromDate := MinValidDate;
      Result.ToDate := MaxValidDate;
//   end;
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
    Client := TClientObj( baClient );
    CCode := Client.clExtra.ceLocal_Currency_Code;
//    Result := baForex_Info.Rate( BCode, CCode, ADate );
    IsoIndex := Client.ExchangeSource.GetISOIndex(BCode,
                                                  Client.ExchangeSource.Header);
    if IsoIndex <> 0 then begin
      ExchangeRate := Client.ExchangeSource.GetDateRates(ADate);
      if Assigned(ExchangeRate) then
        Result := ExchangeRate.Rates[IsoIndex];
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
   baMatched_Items_List.Free;
   BKBAIO.Free_Bank_Account_Rec_Dynamic_Fields( baFields);
//   fForex_Info := NIL;
   inherited Destroy;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
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
  if baClient = NIL then
     Result := False
  else
     Result := TClientObj(baClient).clExtra.ceLocal_Currency_Code <> baFields.baCurrency_Code;
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
  Client := TClientObj( baClient );
  Result := ( Client.clFields.clCountry = whAustralia ) and
    ( Copy( baFields.baBank_Account_Number, 1, 2 ) = BKConst.EldersPrefix );
end;

//------------------------------------------------------------------------------
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
         tkBeginMatchedItems     : baMatched_Items_List.LoadFromFile( S);
         tkBeginMemorisationsList : baMemorisations_List.LoadFromStream(S);
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

   with baMatched_Items_List do for i := 0 to Pred( ItemCount) do begin
      t := Transaction_At( i);
      with t^ do begin
         if txMatched_Item_ID = Match_ID then begin
            result := t;
            exit;
         end;
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

{function TBank_Account.GetForexInfo : TExchangeRateFileInfo;
var
  Client : TClientObj;
  BCode, CCode : String[3];
  ForexSource : TExchangeRateSource;
begin
  Result := NIL;
  if not IsAForexAccount then exit;

  if fForex_Info = NIL then
  Begin
    Client := TClientObj( baClient );
    Assert ( Assigned( Client ), 'Client is NIL in TBank_Account.GetForexInfo!' );
    CCode := Client.clExtra.ceLocal_Currency_Code;
    BCode := baFields.baCurrency_Code;

    With ExchangeRateFinder.SuggestSources( BCode, CCode ), baFields do
    Try
      ForexSource := FindSourceByDescriptionAndDataSource( baDefault_Forex_Description, baDefault_Forex_Source );
      if Assigned( ForexSource ) then
        fForex_Info := ForexSource.ForexInfo;
    Finally
      Free;
    End;
  End;
  Result := fForex_Info;
end; }

function TBank_Account.HasMissingExchageRates(StartDate,
  EndDate: Integer): Boolean;
var
  i: Integer;
  T: pTransaction_Rec;
begin
  Result := False;

  if not IsAForexAccount then Exit;

  for i := 0 to Pred( baTransaction_List.ItemCount ) do
  begin
    T := baTransaction_List.Transaction_At(i);
    if (T.txDate_Effective >= StartDate) and
       (T.txDate_Effective <= EndDate) then
    begin
      if (T.Default_Forex_Rate = 0) then begin
        Result := True;
        Break;
      end;
    end;
  end;
end;

function TBank_Account.HasTransactionsWithin(StartDate, EndDate: Integer): Boolean;
Var
  i: Integer;
  T: pTransaction_Rec;
begin
  for i := 0 to Pred( baTransaction_List.ItemCount ) do
  begin
    T := baTransaction_List.Transaction_At(i);
    if (T.txDate_Effective >= StartDate) and
       (T.txDate_Effective <= EndDate) then
    begin
      Result := True;
      Exit;
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
   if baFields.baIs_A_Manual_Account then
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
