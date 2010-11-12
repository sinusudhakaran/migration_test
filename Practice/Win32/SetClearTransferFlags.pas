unit SetClearTransferFlags;
//------------------------------------------------------------------------------
{
   Title:       Unit for setting and clear transfer flags

   Description:

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface

function ClearTransferFlagsForPeriod : boolean;
function SetTransferFlagsForPeriod: Boolean;
function UpdateExchangeRates: boolean;

//******************************************************************************
implementation
uses
   BKUtil32,
   BKCONST,
   bkhelp,
   InfoMoreFrm,
   CodeDateDlg,
   CodingFormCommands,
   UpdateMF,
   Globals,
   YesNoDlg;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function UpdateExchangeRates: boolean;
const
  FOREX_WARNING = 'Clearing the transfer flags will apply any exchange rate ' +
                  'changes to transactions. Are you sure you want to continue?';
begin
  Result := false;
  if AskYesNo('Clear Transfer Flags', FOREX_WARNING, DLG_NO, 0) = DLG_YES then
    Result := true;
end;

function ClearTransferFlagsForPeriod : boolean;
Var
   i: integer;
   D1, D2 : LongInt;
   EntriesFound : boolean;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

      //Show warning if ForEx account
      for i := 0 to Pred(clBank_Account_List.ItemCount) do begin
        if clBank_Account_List.Bank_Account_At(i).IsAForexAccount then begin
          if not UpdateExchangeRates then
            Exit;
          Break; //Only needs to show once
        end;
      end;

      If not EnterDateRange( 'Clear the Transfer Flags for a period',
         'Enter the starting and finishing date for the period you want to clear ' +
         'the transfer flags for.',
         D1, D2, BKH_Flagging_transactions, false, true )
      then
         Exit;

      //Clear transfer flags for all accounts and journals
      SetOrClearTransferFlags( false,
                               D1,
                               D2,
                               [ btBank.. btStockBalances],
                               EntriesFound);

      if EntriesFound then begin
         result := true;
         SendCmdToAllCodingWindows( ecRecodeTrans);
         HelpfulInfoMsg( 'The transfer flags have been cleared.', 0);
      end
      else
         HelpfulInfoMsg( 'There are no entries in this date range.', 0);
   end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function SetTransferFlagsForPeriod : boolean;
Var
   D1, D2 : LongInt;
   EntriesFound : boolean;
Begin
   Result := false;
   if not Assigned(MyClient) then
      Exit;

   With MyClient do begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

      if not EnterDateRange( 'Set the Transfer Flags for a period',
         'Enter the starting and finishing date for the period you want to set ' +
         'the transfer flags for.',
         D1, D2, BKH_Flagging_transactions, false, true )
      then
         Exit;

      //Clear transfer flags for all accounts and journals
      SetOrClearTransferFlags( True,
                               D1,
                               D2,
                               [btBank.. btStockBalances],
                               EntriesFound);

      if EntriesFound then begin
         result := true;
         SendCmdToAllCodingWindows( ecRecodeTrans);
         HelpfulInfoMsg( 'The transfer flags have been set.', 0);
      end else
         HelpfulInfoMsg( 'There are no entries in this date range.', 0);
   end;
end;

end.
