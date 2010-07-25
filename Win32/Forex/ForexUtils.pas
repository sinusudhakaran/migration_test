unit ForexUtils;

{------------------------------------------------------------------}
interface uses clObj32, baObj32, sysObj32;
{------------------------------------------------------------------}

function HasRequiredForexSources( aClient : TClientObj; out CurrencyCode, BankAccountNumber : String ) : boolean;

function HasNewEntriesWithDatesOutsideTheCurrentForexDataRange( aClient : TClientObj; aSystem : TSystemObj ; out ForexCurrencyCode, ForexFileName : String ) : boolean;

{------------------------------------------------------------------}
implementation
uses
   CurrencyConversions, SyDefs, SysUtils, LogUtil;
{------------------------------------------------------------------}

Const
  UnitName = 'ForexUtils';
  DebugMe : Boolean = False;

// ----------------------------------------------------------------------------

function HasRequiredForexSources( aClient : TClientObj; out CurrencyCode, BankAccountNumber : String ) : boolean;
Var
  I        : LongInt;
  Bank_Account : tBank_Account;
Begin
  Result := False;
  CurrencyCode := '';
  BankAccountNumber := '';

  With aClient.clBank_Account_List do
  begin
    for I := 0 to Pred( itemCount ) do
    begin
      Bank_Account := Bank_Account_At( I );
      If Bank_Account.IsAForexAccount then
      Begin
        With Bank_Account, baFields do
        Begin
          CurrencyCode := baCurrency_Code;
          BankAccountNumber := baBank_Account_Number;
          if ( baFields.baDefault_Forex_Source = '' ) then
             exit; // Haven't entered a source yet
          if baForex_Info = NIL then
             exit; // Couldn't find the source
        End;
      End;
    end;
  end;
  Result := True;
End;

{------------------------------------------------------------------}

function HasNewEntriesWithDatesOutsideTheCurrentForexDataRange( aClient : TClientObj; aSystem : TSystemObj ; out ForexCurrencyCode, ForexFileName : String ) : boolean;

const
  ThisMethodName = 'HasNewEntriesWithDatesOutsideTheCurrentForexDataRange';
Var
  I        : LongInt;
  pSB      : pSystem_Bank_Account_Rec;
  MaxLRN   : LongInt;
  Bank_Account : tBank_Account;
  FirstForexDate : Integer;
  LastForexDate  : Integer;
Begin
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
  Result := False;

  ForexCurrencyCode  := '';
  ForexFileName      := '';

  With aClient.clBank_Account_List do
  begin
    for I := 0 to Pred( itemCount ) do
    begin
      Bank_Account := Bank_Account_At( I );
      With Bank_Account, baFields do
      begin
        if Bank_Account.baFields.baIs_A_Manual_Account then
          Continue;
        if Bank_Account.IsAForexAccount then
        Begin
          FirstForexDate := baForex_Info.FromDate;
          LastForexDate := baForex_Info.ToDate;

          MaxLRN := baHighest_LRN;  //baTransaction_List.HighestLRN;
          pSB := aSystem.fdSystem_Bank_Account_List.FindCode( baBank_Account_Number );
          If Assigned( pSB ) then
          begin
            If ( pSB.sbLast_Transaction_LRN > MaxLRN ) and ( pSB.sbLast_Entry_Date > LastForexDate ) then
            Begin // New Entries and Outside the Range
              Result := True;
              ForexCurrencyCode := baCurrency_Code;
              ForexFileName     := baForex_Info.Filename;
              exit;
            End;
          end;
        end;
      end;
    end;
  end;
  if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

{------------------------------------------------------------------}

Initialization
  DebugMe := DebugUnit( UnitName );
end.


