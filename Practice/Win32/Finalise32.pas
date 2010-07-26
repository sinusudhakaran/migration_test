unit Finalise32;
//------------------------------------------------------------------------------
{
   Title:       Finalise Entries Unit

   Description: Hold routines for finalising or clearing finalised lock on
                a period of entries.

   Remarks:

   Author:

}
//------------------------------------------------------------------------------

interface
Type
   tLockInfo = ( ltAll, ltSome, ltNone, ltNoData );

Function  IsLocked( D1, D2 : LongInt ): tLockInfo;
Function  IsMonthLocked( D1 : LongInt ): tLockInfo;
Procedure LockEntries( D1, D2 : LongInt );
Procedure UnLockEntries( D1, D2 : LongInt );

function FinaliseAccountingPeriod : boolean;
function UnlockAccountingPeriod : boolean;

function AutoLockGSTPeriod(FromDate, ToDate : integer): boolean;

function Istransferred( D1, D2 : LongInt ): tLockInfo;
Function IsMonthTransferred( D1 : LongInt ): tLockInfo;


implementation
uses
  globals,
  bkdefs,
  infoMorefrm,
  bkhelp,
  UpdateMF,
  bkconst,
  bkDateutils,
  CodingFormCommands,
  CodeDateDlg;

Function IsLocked( D1, D2 : LongInt ): tLockInfo;

Var
   B, T : LongInt;
   SomeLocked     : Boolean;
   SomeUnlocked   : Boolean;
Begin
   Result := ltNoData;
   If not Assigned( MyClient ) then exit;

   SomeLocked     := FALSE;
   SomeUnlocked   := FALSE;

   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do
         With Bank_Account_At( B ).baTransaction_List do
            For T := 0 to Pred( itemCount ) do
               With Transaction_At( T )^ do
                  If ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) then
                  Begin
                     If txLocked then
                        SomeLocked := TRUE
                     else
                        SomeUnlocked := TRUE;
                  end;

   If ( SomeLocked and SomeUnlocked ) then Result := ltSome;
   If ( SomeLocked and not SomeUnlocked ) then Result := ltAll;
   If ( SomeUnlocked and not SomeLocked ) then Result := ltNone;
end;

Function  IsMonthLocked( D1 : LongInt ): tLockInfo;
begin
     Result := IsLocked(GetFirstDayOfMonth(D1), GetLastDayOfMonth(D1));
end;
{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

Procedure   LockEntries( D1, D2 : LongInt );
//mark all entries for all bank accounts in the date range as finalised
Var
   B, T : LongInt;
Begin
   If not Assigned( MyClient ) then exit;
   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do
         With Bank_Account_At( B ).baTransaction_List do
            For T := 0 to Pred( itemCount ) do
               With Transaction_At( T )^ do
                  If ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) then
                     txLocked := TRUE;
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

Procedure   UnLockEntries( D1, D2 : LongInt );
//mark all entries for all bank accounts in the date range as NOT finalised
Var
   B, T : LongInt;
Begin
   If not Assigned( MyClient ) then exit;
   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do
         With Bank_Account_At( B ).baTransaction_List do
            For T := 0 to Pred( itemCount ) do
               With Transaction_At( T )^ do
                  If ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) then
                     txLocked := FALSE;
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
function FinaliseAccountingPeriod : boolean;
Var
   D1, D2 : LongInt;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

      If not EnterDateRange( 'Lock Accounting Period',
         'Enter the starting and finishing date for the period you want to lock.',
         D1, D2, BKH_Finalise_accounting_period_for_GST_purposes, false, true ) then exit;

      Case IsLocked( D1, D2 ) of
         ltAll    :
            Begin
               HelpfulInfoMsg( 'These entries have already been locked.', 0 );
               exit;
            end;

         ltSome   :
            Begin
               result := true;
               LockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been locked.', 0 );
               //exit;
            end;
         ltNone   :
            Begin
               result := true;
               LockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been locked.', 0 );
               //exit;
            end;
         ltNoData :
            Begin
               HelpfulInfoMsg( 'There are no entries in this date range', 0 );
               exit;
            end;
      end;
      SendCmdToAllCodingWindows( ecRecodeTrans);
   end;
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }

function UnlockAccountingPeriod : boolean;
Var
   D1, D2 : LongInt;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

      If not EnterDateRange( 'Unlock an Accounting Period',
         'Enter the starting and finishing date for the period you want to unlock.',
         D1, D2, BKH_Finalise_accounting_period_for_GST_purposes,false,true ) then exit;

      Case IsLocked( D1, D2 ) of
         ltAll    :
            Begin
               result := true;
               UnLockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been unlocked.', 0 );
               //exit;
            end;

         ltSome   :
            Begin
               result := true;
               UnLockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been unlocked.', 0 );
               //exit;
            end;
         ltNone   :
            Begin
               HelpfulInfoMsg( 'These entries are not locked.', 0 );
               exit;
            end;
         ltNoData :
            Begin
               HelpfulInfoMsg( 'There are no entries in this date range', 0 );
               exit;
            end;
      end;
       SendCmdToAllCodingWindows( ecRecodeTrans);
   end;
end;


function AutoLockGSTPeriod(FromDate, ToDate : integer): boolean;
Var
   D1, D2 : LongInt;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      d1 := fromDate;
      d2 := toDate;

      Case IsLocked( D1, D2 ) of
         ltAll    :
            Begin
               HelpfulInfoMsg( 'These entries have already been finalised.', 0 );
               exit;
            end;

         ltSome   :
            Begin
               result := true;
               LockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been finalised.', 0 );
               //exit;
            end;
         ltNone   :
            Begin
               result := true;
               LockEntries( D1, D2 );
               HelpfulInfoMsg( 'The entries have been finalised.', 0 );
               //exit;
            end;
         ltNoData :
            Begin
               HelpfulInfoMsg( 'There are no entries in this date range', 0 );
               exit;
            end;
      end;
      SendCmdToAllCodingWindows( ecRecodeTrans);
   end;
end;


Function IsTransferred( D1, D2 : LongInt ): tLockInfo;

Var
   B, T : LongInt;
   SomeLocked     : Boolean;
   SomeUnlocked   : Boolean;
Begin
   Result := ltNoData;
   If not Assigned( MyClient ) then exit;

   SomeLocked     := FALSE;
   SomeUnlocked   := FALSE;

   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do
         With Bank_Account_At( B ).baTransaction_List do
            For T := 0 to Pred( itemCount ) do
               With Transaction_At( T )^ do
                  If ( txDate_Effective >=D1 )
                  and ( txDate_Effective <=D2 ) then
                  Begin
                     If txDate_Transferred <> 0 then
                        SomeLocked := TRUE
                     else
                        SomeUnlocked := TRUE;
                  end;

   If ( SomeLocked and SomeUnlocked ) then Result := ltSome;
   If ( SomeLocked and not SomeUnlocked ) then Result := ltAll;
   If ( SomeUnlocked and not SomeLocked ) then Result := ltNone;
end;

Function  IsMonthTransferred( D1 : LongInt ): tLockInfo;
begin
     Result := IsTransferred(GetFirstDayOfMonth(D1), GetLastDayOfMonth(D1));
end;


end.
