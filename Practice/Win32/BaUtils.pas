Unit bautils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
   Title:    Bank Account Utils

   Description:

   Remarks:

   Author:

}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Interface
Uses
   Classes,
   MoneyDef,
   dateDef,
   baObj32,
   bkDefs,
   ovcDate,
   baList32,
   clObj32;


//
// Note: For a foreign currency account, the figures are returned in the foreign currency
//
Procedure GetBalances(b: TBank_Account; d1, d2: tStDate; Var BankOpBal,
   BankClBal, SystemOpBal, SystemClBal: money);


function GetHistoricalDataRange( ba : TBank_Account; var FirstDate : integer; var LastDate : integer) : boolean;

function MDEExpired(BAList: TBank_Account_List; LastUseDate: Integer; SkipTransCheck: Boolean = False): Boolean;
function GetMDEExpiryDate(BAList: TBank_Account_List): Integer;
function GetLatestTransDate(BAList: TBank_Account_List): Integer;
function MakeManualXMLString(atype, inst: string): string;
function HasManualAccounts(Client: TClientObj; ToSend: Boolean = False): Boolean;
function AnyAccountIsInAdmin(Client: TClientObj): Boolean;

procedure GetStatsForAccount( const bAccount : TBank_Account; const dFrom : integer; const dTo : integer;
                              var EntriesCount : integer; var FoundFrom : integer; var FoundTo : integer);
function CanBankAccountsBeCombined(BL: TBank_Account_List): Boolean;
function CanManualBankAccountsBeCombined(BL: TBank_Account_List): Boolean;
function GetValidBankAccountsForCombine(BL: TBank_Account_List): TStringList;
function GetValidManualBankAccountsForCombine(BL: TBank_Account_List): TStringList;
function StripM(ba: TBank_Account): string;

const
   UnitName = 'BAUTILS';

//******************************************************************************
Implementation
Uses
   bkconst,
   bkDateUtils,
   Globals,
   LogUtil,
   SyDefs;

//------------------------------------------------------------------------------

Procedure GetBalances( b: TBank_Account; d1, d2: tStDate; Var BankOpBal,
   BankClBal, SystemOpBal, SystemClBal: money);
Var
   E      : Integer;
   Amount : Money;
Begin { GetBalances }
   With b Do
   Begin
      BankOpBal := bafields.baCurrent_Balance;
      BankClBal := bafields.baCurrent_Balance;
      SystemOpBal := bafields.baCurrent_Balance;
      SystemClBal := bafields.baCurrent_Balance;

      If bafields.baCurrent_Balance = Unknown Then
      Begin
        exit
      End { bafields.baCurrent_Balance = Unknown };


      With baTransaction_List Do
      Begin
         For E := 0 to Pred(ItemCount) Do
         Begin
            With Transaction_At(E)^ Do
            Begin

               Amount := txAmount;

               If txDate_Presented <> 0 Then
               Begin
                  Case bkDateUtils.CompareDates(txDate_Presented, d1, d2) Of
                  Earlier:;
                  Within:
                  Begin
                     BankOpBal := BankOpBal - Amount;
                  End;
                  Later:
                  Begin
                     BankOpBal := BankOpBal - Amount;
                     BankClBal := BankClBal - Amount;
                  End;
                  End;

                  Case bkDateUtils.CompareDates(txDate_Effective, d1, d2) Of
                  Earlier:;
                  Within:
                  Begin
                     SystemOpBal := SystemOpBal - Amount;
                  End;
                  Later:
                  Begin
                     SystemOpBal := SystemOpBal - Amount;
                     SystemClBal := SystemClBal - Amount;
                  End;
                  End
               End { txDate_Presented <> 0 }
               Else
               Begin { Unpresented }
                  Case bkDateUtils.CompareDates(txDate_Effective, d1, d2) Of
                  Earlier:
                  Begin
                     SystemOpBal := SystemOpBal + Amount;
                     SystemClBal := SystemClBal + Amount;
                  End;
                  Within:
                  Begin
                     SystemClBal := SystemClBal + Amount
                  End;
                  Later:;
                  End
               End { not (txDate_Presented <> 0) };
            End { with Transaction_At(E)^ }
         End { for E }
      End { with baTransaction_List };
   End { with b };
End; { GetBalances }

//------------------------------------------------------------------------------

function GetHistoricalDataRange( ba : TBank_Account; var FirstDate : integer; var LastDate : integer) : boolean;
//get the dates of historical data, returns the presentation date
//returns false if no historical data entered

//requires reading the whole transaction list for the bank account
var
   e : integer;
   fDate, lDate : integer;
   trxFound     : boolean;
begin
   FDate := MaxInt;
   LDate  := 0;
   result := false;
   trxFound := false;

   with ba.baTransaction_List do begin
      for E := 0 to Pred(ItemCount) do begin
         with Transaction_At(E)^ do begin
            If ( txDate_Presented <> 0) and ( txSource = orHistorical) then begin
               trxFound := true;
               if txDate_Presented < FDate then
                  FDate := txDate_Presented;
               if txDate_Presented > LDate then
                  LDate  := txDate_Presented;
            end;
         end;
      end;
   end;

   if trxFound then begin
      FirstDate := fDate;
      LastDate  := lDate;
      result := true;
   end;
end;

//------------------------------------------------------------------------------

// Manual data entry has expired if the earliest MDE account has expired
// and no live data has been received into a live account in the last 4 months.
// MDE does not have this requirement if running in unrestricted mode
function MDEExpired(BAList: TBank_Account_List; LastUseDate: Integer; SkipTransCheck: Boolean = False): Boolean;
var
  ED, TD, CD: Integer;
begin
  Result := False;
  if Assigned(AdminSystem) and AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts] then
    exit;
  ED := GetMDEExpiryDate(BAList);
  TD := GetLatestTransDate(BAList);
  CD := IncDate(CurrentDate, 0, -4, 0); // check date is today minus 4 months
  // If we have received live data in the last 4 months then we skip the last use date check
  if (CurrentDate < LastUseDate) and (TD < CD) then
  begin
    Result := True;
    LogUtil.LogMsg( lmInfo, UnitName, 'MDE Error Code 1');
    exit;
  end;
  if ED = 0 then // no existing manual accounts
    ED := CurrentDate;
  // if the earliest account expiry is less than today - 4 months then its expired
  if ED < CurrentDate then // expired: now must have bank tx within last 4 months
  begin
    // skip this check when deleting the last live account
    Result := (TD < CD) or SkipTransCheck;
    if Result then
      LogUtil.LogMsg( lmInfo, UnitName, 'MDE Error Code 2: chk date=+ ' + bkdate2str(CD) + ', last tx=' + bkdate2str(TD));
  end;
end;

function GetMDEExpiryDate(BAList: TBank_Account_List): Integer;
var
  i: Integer;
  b: TBank_Account;
begin
  Result := 0;
  if Assigned(AdminSystem) and AdminSystem.fdFields.fdEnhanced_Software_Options[ sfUnlimitedDateTempAccounts] then
    exit;

  for i := BAList.First to BAList.Last do
  begin
    b := BAList.Bank_Account_At(i);
    if (b.baFields.baIs_A_Manual_Account) and ((b.baFields.baAccount_Expiry_Date < Result) or (Result = 0)) then
      Result := b.baFields.baAccount_Expiry_Date;
  end;
end;

function GetLatestTransDate(BAList: TBank_Account_List): Integer;
var
  i, t: Integer;
  b: TBank_Account;
  pT : pTransaction_Rec;
begin
  Result := 0;
  for i := BAList.First to BAList.Last do
  begin
    b := BAList.Bank_Account_At(i);
    if b.baFields.baAccount_Type = btBank then
    begin
      //find date of the last bank transaction for this account
      for t := b.baTransaction_List.First to b.baTransaction_List.Last do
      begin
        pT := b.baTransaction_List.Transaction_At(t);
        if (pT.txSource = orBank) and ( pT^.txDate_Presented > Result) then
          Result := pT^.txDate_Presented;
      end;
    end;
  end;
end;

function MakeManualXMLString(atype, inst: string): string;
begin
  Result := '<at>' + atype + '</at><institution>' + inst + '</institution>';
end;

function HasManualAccounts(Client: TClientObj; ToSend: Boolean = False): Boolean;
var
  i : integer;
begin
  Result := false;
  with Client.clBank_Account_List do begin
     for i := 0 to Pred( ItemCount ) do begin
        with Bank_Account_At( i ) do begin
           if baFields.baIs_A_Manual_Account and
              ( (ToSend and (not baFields.baManual_Account_Sent_To_Admin)) or (not ToSend) ) then
           begin
            Result := True;
            exit;
           end;
        end;
     end;
  end;
end;

procedure GetStatsForAccount( const bAccount : TBank_Account; const dFrom : integer; const dTo : integer;
                              var EntriesCount : integer; var FoundFrom : integer; var FoundTo : integer);
//given a bank account and a date range return the count of entries in that range,
//and also the actual dates of entries found in that range
var
   i : integer;
   FirstDate,
   LastDate  : integer;
   Count     : integer;
begin
   FirstDate := MaxInt;
   LastDate  := 0;
   Count     := 0;

   if not Assigned( bAccount) then exit;

   with bAccount.baTransaction_List do begin
      for i := 0 to Pred( ItemCount) do with Transaction_At( i)^ do begin
         if ( txDate_Effective >= dFrom) and ( txDate_Effective <= dTo) then begin
            if txDate_Effective > LastDate then
               LastDate := txDate_Effective;
            if txDate_Effective < FirstDate then
               FirstDate := txDate_Effective;
            Inc( Count);
         end;
         //list is sorted by date effective so if gone past end then break loop
         if txDate_Effective > dTo then break;
      end;
   end;
   FoundFrom := FirstDate;
   FoundTo   := LastDate;
   EntriesCount := Count;
end;

// See if it is possible for any two bank accounts to be combined
function CanBankAccountsBeCombined(BL: TBank_Account_List): Boolean;
var
  L: TStringList;
begin
  L := nil;
  try
    L := GetValidBankAccountsForCombine(BL);
    Result := L.Count > 0;
  finally
    if Assigned(L) then
      L.Free;
  end;
end;

function GetValidBankAccountsForCombine(BL: TBank_Account_List): TStringList;
var
  i, j: Integer;
  b1, b2: TBank_Account;
  Entries1, Entries2, D1, D2, D3, D4: Integer;
begin
  Result := TStringList.Create;
  // see if each account can be validly combined with any other account in the file
  for i := BL.First to BL.Last do
  begin
    b1 := BL.Bank_Account_At(i);
    if (b1.baFields.baAccount_Type <> btBank) or (b1.baFields.baIs_A_Manual_Account) then
      Continue;
    for j := BL.First to BL.Last do
    begin
      b2 := BL.Bank_Account_At(j);
      if (b2.baFields.baAccount_Type <> btBank)
      or (b2.baFields.baIs_A_Manual_Account) or (i = j) then
         Continue;
      GetStatsForAccount( b1, 0, MaxInt, Entries1, D1, D2);
      GetStatsForAccount( b2, 0, D2, Entries2, D3, D4);
      if ((Entries1 = 0) or (Entries2 = 0)) and (Result.IndexOf( b1.Title)= -1) then
        Result.AddObject( b1.Title, b1);
    end;
  end;
end;

// See if it is possible for any two manual bank accounts to be combined
function CanManualBankAccountsBeCombined(BL: TBank_Account_List): Boolean;
var
  L: TStringList;
begin
  L := nil;
  try
    L := GetValidManualBankAccountsForCombine(BL);
    Result := L.Count > 0;
  finally
    if Assigned(L) then
      L.Free;
  end;
end;

function GetValidManualBankAccountsForCombine(BL: TBank_Account_List): TStringList;
var
  i, j: Integer;
  b1, b2: TBank_Account;
  Entries1, Entries2, D1, D2, D3, D4: Integer;
begin
  Result := TStringList.Create;
  // see if each account can be validly combined with any other account in the file
  for i := BL.First to BL.Last do
  begin
    b1 := BL.Bank_Account_At(i);
    if (b1.IsAJournalAccount)
    or (not b1.IsManual) then
       Continue;

    // Have atleast one manual account (i)
    for j := BL.First to BL.Last do
    begin
      b2 := BL.Bank_Account_At(j);
      if (b2.IsAJournalAccount)
      or (not b2.IsManual)
      or (i = j) then  // the one I Have..
         Continue;

      GetStatsForAccount( b1, 0, MaxInt, Entries1, D1, D2);
      GetStatsForAccount( b2, 0, D2, Entries2, D3, D4);
      if ((Entries1 = 0) or (Entries2 = 0))
      and (Result.IndexOf( b1.Title)= -1) then
        Result.AddObject( b1.Title, b1);
    end;
  end;
end;

// strip M from manual accounts
function StripM(ba: TBank_Account): string;
begin
  Result := ba.baFields.baBank_Account_Number;
  if ba.baFields.baIs_A_Manual_Account then
  begin
    if (Pos('M', ba.baFields.baBank_Account_Number) = 1) then
    begin
     if Length(ba.baFields.baBank_Account_Number) = 1 then
       Result := ''
     else
       Result := Copy(ba.baFields.baBank_Account_Number, 2, Length(ba.baFields.baBank_Account_Number));
    end;
  end;
end;

function AnyAccountIsInAdmin(Client: TClientObj): Boolean;
var
  i: Integer;
  pSB: pSystem_Bank_Account_Rec;
  B: TBank_Account;
begin
  Result := False;
  if not Assigned(AdminSystem) then exit;
  for i := Client.clBank_Account_List.First to Client.clBank_Account_List.Last do
  begin
    B := Client.clBank_Account_List.Bank_Account_At(i);
    if (B.baFields.baIs_A_Manual_Account) or (B.baFields.baAccount_Type <> btBank) then Continue;
    pSB := AdminSystem.fdSystem_Bank_Account_List.FindCode( B.baFields.baBank_Account_Number );
    if Assigned(pSB) then
    begin
      Result := True;
      break;
    end;
  end;
end;

End.

