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
  CodeDateDlg,
  baObj32,
  YesNoDlg,
  BKUTIL32;

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
   BA : TBank_Account;
Begin
   If not Assigned( MyClient ) then exit;
   With MyClient.clBank_Account_List do
      For B := 0 to Pred( itemCount ) do begin
         BA := Bank_Account_At( B );
         With BA.baTransaction_List do
            For T := 0 to Pred( itemCount ) do
               With Transaction_At( T )^ do
                  If ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) then begin
                     //Save ForEx rate for locked transactions
                     if (not txLocked) and (txDate_Transferred =0) then
                       txForex_Conversion_Rate := BA.Default_Forex_Conversion_Rate( txDate_Effective );
                     txLocked := TRUE;
                  end;
      end;
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
                  If ( txDate_Effective >=D1 ) and ( txDate_Effective <=D2 ) then begin
                     txLocked := FALSE;
                     txForex_Conversion_Rate := 0;
                  end;
end;

function HasUnCodedGSTEntries(D1, D2: LongInt): Boolean;
var
  CodedCount, UnCodedCount: integer;
begin
  Result := False;
  CodedCount := 0;
  UnCodedCount := 0;
  BKUTIL32.CountCodedGSTTrans(MyClient, d1, d2, CodedCount, UnCodedCount,
                              MyClient.clFields.clGST_on_Presentation_Date);
  Result := (UnCodedCount > 0);
end;

{  - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  }
function FinaliseAccountingPeriod : boolean;
Var
   D1, D2 : LongInt;
   HasUncoded: Boolean;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      D1 := clFields.clPeriod_Start_Date;
      D2 := clFields.clPeriod_End_Date;

      HasUncoded := True;
      while HasUncoded do begin
        If not EnterDateRange( 'Lock Accounting Period',
           'Enter the starting and finishing date for the period you want to lock.',
           D1, D2, BKH_Finalise_accounting_period_for_GST_purposes, false, true ) then exit;
        //Check that all transactions are coded for the UK
        HasUncoded := False;
        if MyClient.clFields.clCountry = whUK then
          if HasUnCodedGSTEntries(D1, D2) then begin
            HelpfulInfoMsg( 'There are uncoded entries in the selected period. ' +
                            'Please code these entries before finalising the period.', 0 );
            HasUncoded := True;
          end;
      end;

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
const
  FOREX_WARNING = 'Unlocking this period will apply any exchange rate ' +
                  'changes to transactions or journals in this period. Are ' +
                  'you sure you want to continue?';
Var
   i: integer;
   D1, D2 : LongInt;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      //Show warning if ForEx account
      if Assigned(AdminSystem) or (MyClient.clFields.clDownload_From <> dlAdminSystem) then begin
        for i := 0 to Pred(clBank_Account_List.ItemCount) do begin
          if clBank_Account_List.Bank_Account_At(i).IsAForexAccount then begin
            if AskYesNo('Unlock an Accounting Period', FOREX_WARNING, DLG_NO, 0) in [DLG_NO, 0] then
              Exit;
            Break; //Only needs to show once
          end;
        end;
      end;

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
   CodedCount, UnCodedCount: integer;
Begin
   result := false;
   If not Assigned( MyClient ) then exit;
   With MyClient do
   Begin
      d1 := fromDate;
      d2 := toDate;

      //Check that all transactions are coded for the UK
      if MyClient.clFields.clCountry = whUK then
        if HasUnCodedGSTEntries(D1, D2) then begin
          HelpfulInfoMsg( 'There are uncoded entries in this period which prevents ' +
                          'the VAT Return period from being finalised.', 0 );
          Exit;
        end;

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
