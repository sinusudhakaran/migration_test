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
   Globals;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function ClearTransferFlagsForPeriod : boolean;
Var
   D1, D2 : LongInt;
   EntriesFound : boolean;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

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
