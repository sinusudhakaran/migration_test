Unit cldateutils;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{
  Title:

  Written:
  Authors:

  Purpose:

  Notes:
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Interface

Uses
   clObj32, ovcDate;

Function BThisYear(aClient: TClientObj) : tStDate;

Function EThisYear(aClient: TClientObj) : tStDate;

Function BLastYear(aClient: TClientObj) : tStDate;

Function ELastYear(aClient: TClientObj) : tStDate;

function BThisQuarter(aClient: TClientObj) : tStDate;
function EThisQuarter(aClient: TClientObj) : tStDate;

Function BAllData(aClient: TClientObj)  : tStDate;

Function EAllData(aClient: TClientObj)  : tStDate;

Function BBankData(aClient :TClientObj) : tStDate;

Function EBankData(aClient :TClientObj) : tStDate;

//******************************************************************************
Implementation

Uses
  SysUtils,
  BK5Except, bkDateUtils, LogUtil, bkdefs, bkConst;

Const
   UnitName = 'CLDATEUTILS';

type
   ATTypeSet = set of byte;


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function BThisYear(aClient: TClientObj) : tStDate;
Const
   ThisMethodName = 'BThisYear';
Var
   Msg : String;
Begin { BThisYear }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };
   Result := aClient.clFields.clFinancial_Year_Starts;
End; { BThisYear }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function EThisYear(aClient: TClientObj) : tStDate;
Const
   ThisMethodName = 'EThisYear';
Var
   Msg : String;
Begin { EThisYear }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };
   Result := bkDateUtils.GetYearEndDate(aClient.clFields.clFinancial_Year_Starts);
End; { EThisYear }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function BLastYear(aClient: TClientObj) : tStDate;
Const
   ThisMethodName = 'BLastYear';
Var
   Msg   : String;
   Day,
   Month,
   Year  : Integer;
Begin { BLastYear }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };
   stDatetoDMY(aClient.clFields.clFinancial_Year_Starts, Day, Month, Year); { D should always be 1 }
   Result := DMYtoStDate(Day, Month, Year - 1, Epoch);
End; { BLastYear }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function ELastYear(aClient: TClientObj) : tStDate;
Const
   ThisMethodName = 'ELastYear';
Var
   Msg : String;
Begin { ELastYear }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };
   Result := aClient.clFields.clFinancial_Year_Starts - 1;
End; { ELastYear }

// -----------------------------------------------------------------------------
//
// Returns the first day in the current quarter
//
function BThisQuarter(aClient: TClientObj) : tStDate;
var
  CurrentDay, CurrentMonth, CurrentYear : Word;
  StartDay, StartMonth, StartYear : Integer;
  MonthDiv : Integer;
begin
  if (CurrentDate < aClient.clFields.clFinancial_Year_Starts) then
    // whoops, should not happen
    Result := aClient.clFields.clFinancial_Year_Starts
  else begin
    // break up the current date
    DecodeDate(Date, CurrentYear, CurrentMonth, CurrentDay);
    // break up the financial year start date
    StDatetoDMY( aClient.clFields.clFinancial_Year_Starts, StartDay, StartMonth, StartYear);

    if (CurrentYear > StartYear) then
      // year wrap around
      CurrentMonth := CurrentMonth + 12 * (CurrentYear -StartYear);

    // find the number of whole 3 month periods
    MonthDiv := ((CurrentMonth - StartMonth) div 3);

    // calculate the new date
    Result := IncDate(aClient.clFields.clFinancial_Year_Starts, 0, (MonthDiv * 3), 0);
  end;
end;

// -----------------------------------------------------------------------------
//
// Returns the last day in the current quarter
//
function EThisQuarter(aClient: TClientObj) : tStDate;
begin
  // find the beginning of the financial quarter
  Result := BThisQuarter(aClient);
  // increase date by 3 months and decrement by 1 day
  Result := IncDate(Result, -1, 3, 0);
end;

{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function GetFirstTransactionDate(aClient: TClientObj; AccountTypes : ATTypeSet) : tStDate;
Const
   ThisMethodName = 'BAllData';
Var
   Msg : String;
   Earliest : tStDate;
   i        : Integer;
   p        : pTransaction_Rec;
Begin { BAllData }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };

   Earliest := 0;
   With aClient.clBank_Account_List Do
   Begin
      For i := 0 to Pred(ItemCount) Do
      Begin
         With Bank_Account_At(i) Do
         Begin
            If (baTransaction_List.ItemCount > 0) and (baFields.baAccount_Type in AccountTypes) Then
            Begin
               p := baTransaction_List.Transaction_At(0);
               If Earliest = 0 Then
               Begin
                  Earliest := p^.txDate_Effective;
               End { Earliest = 0 }
               Else
               Begin
                  If p^.txDate_Effective < Earliest Then
                  Begin
                     Earliest := p^.txDate_Effective;
                  End { p^.txDate_Effective < Earliest }
               End;
            End { baTransaction_List.ItemCount > 0 };
         End { with Bank_Account_At(i) }
      End;
   End { with aClient.clBank_Account_List };
   Result := Earliest;
End; { BAllData }


{sc-----------------------------------------------------------------------
-----------------------------------------------------------------------sc}
Function GetLastTransactionDate(aClient: TClientObj; AccountTypes : ATTypeSet) : tStDate;
Const
   ThisMethodName = 'EAllData';
Var
   Msg : String;
   Oldest : tStDate;
   p      : pTransaction_Rec;
   i      : Integer;
Begin { EAllData }
   If not Assigned(aClient) Then
   Begin
      Msg := 'AClient is NIL';
      LogUtil.LogMsg(lmError, UnitName, ThisMethodName + ' : ' + Msg);
      Raise EInvalidCall.CreateFmt('%s - %s : %s', [UnitName, ThisMethodName,
         Msg]);
   End { not Assigned(aClient) };

   Oldest := 0;
   With aClient.clBank_Account_List Do
   Begin
      For i := 0 to Pred(ItemCount) Do
      Begin
         With Bank_Account_At(i), baTransaction_List Do
         Begin
            if (ItemCount > 0) and (baFields.baAccount_Type in AccountTypes) Then
            Begin
               p := Transaction_At( Pred( ItemCount ) );
               If p^.txDate_Effective > Oldest Then
                  Oldest := p^.txDate_Effective;
            end ;
         end;
      End;
   end ;
   Result := Oldest;
End; { EAllData }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function BBankData(aClient :TClientObj) : tStDate;
begin
   result := GetFirstTransactionDate(aClient, [btBank]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function EBankData(aClient :TClientObj) : tStDate;
begin
   result := GetLastTransactionDate(aClient, [btBank]);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function EAllData(aClient: TClientObj) : tStDate;
begin
   result := GetLastTransactionDate(aClient, [ btBank,
                                               btCashJournals,
                                               btAccrualJournals,
                                               btGSTJournals,
                                               btStockJournals,
                                               btOpeningBalances]);

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function BAllData(aClient: TClientObj) : tStDate;
begin
   result := GetFirstTransactionDate(aClient, [ btBank,
                                               btCashJournals,
                                               btAccrualJournals,
                                               btGSTJournals,
                                               btStockJournals,
                                               btOpeningBalances]);

end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
End.
