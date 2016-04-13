unit travutils;

// These routines operate on the global MyClient object.
// SPA, 21-05-99

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface uses BaOBJ32, StDate, MoneyDef;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function AllCoded( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
function AllGSTCoded( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
function CalculateBankContra( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Money;
function HasRequiredGSTContraCodes( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
function HasRequiredGSTTypes( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
function NumberAvailableForExport( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Longint;
function HasAnyGST( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;

procedure CountTransactionStatus( const AnAccount : TBank_Account; var NumCoded, NumUncoded, NumInvalid : integer;
                                  From_Date, To_Date : TStDate);

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation uses Traverse, glConst, Globals, BKUtil32, BKConst, LogUtil;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Const
   UnitName = 'TRAVUTILS';
   DebugMe  : Boolean = False;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check that all the entries have been coded by counting the ones that are
// still uncoded.
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   NumberUncoded : LongInt;
   NumberCoded : integer;
   NumberInvalid : integer;
   NumberGSTUncoded : LongInt;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CountUncodedEntries;
const
   ThisMethodName = 'CountUncodedEntries';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Inc( NumberUncoded );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CountGSTUncodedEntries;
const
   ThisMethodName = 'CountGSTUncodedEntries';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Inc( NumberGSTUncoded );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function AllGSTCoded( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
const
   ThisMethodName = 'AllGSTCoded';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   NumberGSTUncoded := 0;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllGSTUncoded );
   Traverse.SetOnEHProc( CountGSTUncodedEntries );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );
   AllGSTCoded := ( NumberGSTUncoded = 0 );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function AllCoded( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;
const
   ThisMethodName = 'AllCoded';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   NumberUncoded := 0;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewUncodedEntries );
   Traverse.SetOnEHProc( CountUncodedEntries );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );
   AllCoded := ( NumberUncoded = 0 );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure UpdateStatusCount;
Begin
  if bkUtil32.IsCoded( Transaction) then
    NumberCoded := NumberCoded + 1
  else
  begin
    //see if is uncoded or invalid
    if (Transaction.txAccount = '') and (Transaction^.txGST_Class = 0) then
      NumberUncoded := NumberUncoded + 1
    else
      NumberInvalid := NumberInvalid + 1;
  end;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CountTransactionStatus( const AnAccount : TBank_Account; var NumCoded, NumUncoded, NumInvalid : integer;
                                  From_Date, To_Date : TStDate);
begin
  NumberCoded := 0;
  NumberUncoded := 0;
  NumberInvalid := 0;

  Traverse.Clear;
  Traverse.SetSortMethod( csDateEffective );
  Traverse.SetSelectionMethod( twAllEntries );
  Traverse.SetOnEHProc( UpdateStatusCount );
  Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );

  NumCoded := NumberCoded;
  NumUncoded := NumberUncoded;
  NumInvalid := NumberInvalid;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add up all the new entries to find the bank account contra total
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   Contra : Money;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure AddToContra;
const
   ThisMethodName = 'AddToContra';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Transaction^ do Contra := Contra + txAmount;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CalculateBankContra( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Money;
const
   ThisMethodName = 'CalculateBankContra';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Contra := 0;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewEntries );
   Traverse.SetOnEHProc( AddToContra );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );
   Result := -Contra;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Check which GST Classes have been used
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   GST_Class_Used : array[ 1..MAX_GST_CLASS ] of Boolean;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckTransactionGSTClass;
const
   ThisMethodName = 'CheckTransactionGSTClass';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Transaction^ do
   Begin
      if ( txGST_Class in [ 1..MAX_GST_CLASS ] ) and ( txGST_Amount<>0 ) then
         GST_Class_Used[ txGST_Class ] := True;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure CheckDissectionGSTClass;
const
   ThisMethodName = 'CheckDissectionGSTClass';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   with Dissection^ do
   Begin
      if ( dsGST_Class in [ 1..MAX_GST_CLASS ] ) and ( dsGST_Amount<>0 ) then
         GST_Class_Used[ dsGST_Class ] := True;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function HasRequiredGSTContraCodes( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;

const
   ThisMethodName = 'HasRequiredGSTContraCodes';
Var
   i : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   for i := 1 to MAX_GST_CLASS do GST_Class_Used[i] := False;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewEntries );
   Traverse.SetOnEHProc( CheckTransactionGSTClass );
   Traverse.SetOnDSProc( CheckDissectionGSTClass );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );

   Result := True;
   with MyClient.clFields do
   Begin
      for i := 1 to MAX_GST_CLASS do
      Begin
         if GST_Class_Used[ i ] and ( clGST_Account_Codes[i]='' ) then
            Result := False;
      end;
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function HasRequiredGSTTypes( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;

//checks that a gst type has been assigned to any gst class that is used.
const
   ThisMethodName = 'HasRequiredGSTTypes';
Var
   i : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   for i := 1 to MAX_GST_CLASS do GST_Class_Used[i] := False;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewEntries );
   Traverse.SetOnEHProc( CheckTransactionGSTClass );
   Traverse.SetOnDSProc( CheckDissectionGSTClass );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );

   Result := True;
   
   with MyClient.clFields do
   Begin
      Case clCountry of
         whAustralia, whUK  : exit; { This is meaningless for OZ because we don't use these figures for GST }
         whNewZealand : Begin
                           for i := 1 to MAX_GST_CLASS do begin
                              if GST_Class_Used[ i ] and ( clGST_Class_Types[i] = gtUndefined ) then Result := False;
                           end;
                        end;
      end; { of Case }
   end;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Count the number of transaction and dissections that could be exported,
// whether they are coded or not.
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Var
   NumberAvailable : LongInt;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

procedure CountTransactions;
const
   ThisMethodName = 'CountTransactions';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Inc( NumberAvailable );
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function NumberAvailableForExport( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Longint;
const
   ThisMethodName = 'NumberAvailableForExport';
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   NumberAvailable := 0;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewEntries );
   Traverse.SetOnEHProc( CountTransactions );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );
   Result := NumberAvailable;
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function HasAnyGST( const AnAccount : TBank_Account; From_Date, To_Date : TStDate ): Boolean;

const
   ThisMethodName = 'HasAnyGST';
Var
   i : Word;
Begin
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Begins' );
   Result := False;
   for i := 1 to MAX_GST_CLASS do GST_Class_Used[i] := False;
   Traverse.Clear;
   Traverse.SetSortMethod( csDateEffective );
   Traverse.SetSelectionMethod( twAllNewEntries );
   Traverse.SetOnEHProc( CheckTransactionGSTClass );
   Traverse.SetOnDSProc( CheckDissectionGSTClass );
   Traverse.TraverseEntriesForAnAccount( AnAccount, From_Date, To_Date );

   for i := 1 to MAX_GST_CLASS do begin
      if GST_Class_Used[ i ] then Result := True;
   end;
   
   if DebugMe then LogUtil.LogMsg(lmDebug, UnitName, ThisMethodName + ' Ends' );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Initialization
   DebugMe := LogUtil.DebugUnit( UnitName );
end.

