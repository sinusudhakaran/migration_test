unit mxUtils;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES bkDefs, MoneyDef, glConst, PayeeObj, MemorisationsObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function CanMemorise( CONST T : pTransaction_Rec;
                      CONST M : TMemorisation ): Boolean;
// Summary:
//    Does this transaction match this memorised transaction?
// Parameters:
//    T -      Pointer to a Transaction_Rec.
//    M -      Pointer to a Memorised_Transaction_Rec.
// Returns:
//    TRUE if the transaction matches the memorised transaction.
//    FALSE if the transaction does not match the memorised transaction.


TYPE
   MemSplitTotals = Array of Money;
   MemSplitPercentages = Array of Money;

   PayeeSplitTotals = Array of Money;
   PayeeSplitPercentages = Array of Money;

procedure MemorisationSplit( const Amount : Money;
                             const MX : TMemorisation;
                             var Split : MemSplitTotals;
                             var SplitPercentages: MemSplitPercentages );
// Summary:
//    Deducts all fixed amounts, then splits the remainder on a percentage basis
// Parameters:
//    Amount -      The amount to be split.
//    MX - A pointer to the Memorised Transaction.
//    Split - An Array of money with the amounts for each dissection.
// Notes:
//   Each line has a type that indicates whether it is a percentage or dollar amt
//   percentage of the remainder, with any rounding discrepancy going back into
//   split[1].


Procedure PayeePercentageSplit( CONST Amount : Money; CONST Payee : TPayee;
    Var PayeeSplit : PayeeSplitTotals; var SplitPercentages: PayeeSplitPercentages );
// Summary:
//    Splits the amount up based on the percentages and dollar amounts in the Payee.
// Parameters:
//    Amount - The amount to be split.
//    Payee - A pointer to the Payee record.
//    Split - An Array of money with the amounts for each dissection.
// Notes:
//    The number of lines required is defined by the no of payee lines
//    The array will be resized to fit
//    Used by autocode when matching analysis coded cheques

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
implementation

uses
  ForexHelpers,
  MATCHES,
  BKConst;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function CanMemorise ( CONST T : pTransaction_Rec;
                       CONST M : TMemorisation ): Boolean;

var
   TempShortStr : ShortString;
   First40 : String[ 40];
Begin
   Result := FALSE;

   With T^, M.mdFields^ do
   Begin
      If mdType <> txType then exit;

      // Check the date
      if txDate_Effective < mdFrom_Date then exit; // still ok, even if not set..
      if mdUntil_date > 0 then
         if txDate_Effective > mdUntil_Date then exit;

      //Amount



      If ( mdMatch_on_Amount = mxAmtEqual ) then
         If ( Statement_Amount <> mdAmount ) then exit;
      If ( mdMatch_On_Amount = mxAmtGreaterThan) then
         if ( Statement_Amount <= mdAmount) then exit;
      If ( mdMatch_On_Amount = mxAmtGreaterOrEqual) then
         if ( Statement_Amount < mdAmount) then exit;
      If ( mdMatch_On_Amount = mxAmtLessThan) then
         if ( Statement_Amount >= mdAmount) then exit;
      If ( mdMatch_On_Amount = mxAmtLessOrEqual) then
         if ( Statement_Amount > mdAmount) then exit;

      //test for zero value transactions, dont memorise unless match on amount is none or Equal To
      if ( mdMatch_On_Amount in [ mxAmtGreaterThan, mxAmtGreaterOrEqual, mxAmtLessThan, mxAmtLessOrEqual]) and
         ( Statement_Amount = 0 ) then
         Exit;

      If mdMatch_on_Refce  then If not WildCardMatch( mdReference, txReference ) then exit;

      If mdMatch_on_Particulars then If not WildCardMatch( mdParticulars, txParticulars ) then exit;

      If mdMatch_on_Analysis then If not WildCardMatch( mdAnalysis, txAnalysis ) then exit;

      If mdMatch_on_Other_Party then If not WildCardMatch( mdOther_Party, txOther_Party ) then exit;

      If mdMatch_On_Statement_Details then begin
        //try match on first 40 characters so that existing memorisation continue
        //to work
        First40 := Copy( txStatement_Details, 1, 40);
        if not WildCardMatch( mdStatement_Details, First40) then
        begin
          //match not found in first 40, try whole narration
          TempShortStr := txStatement_Details;
          If not WildCardMatch( mdStatement_Details, TempShortStr ) then exit;
        end;
      end;

      if mdMatch_on_Notes then begin  //need to convert ansi string to short string for comparison
         TempShortStr := txNotes;
         if not WildCardMatch( mdNotes, TempShortStr) then exit;
      end;

      Result := TRUE;
   end;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure MemorisationSplit( const Amount : Money;
                             const MX : TMemorisation;
                             var Split : MemSplitTotals;
                             var SplitPercentages: MemSplitPercentages );
Var
   i : Integer;
   TotalPerc, Remainder : Money;
   Percentage     : Extended;
   Temp           : Extended;
   AmountToAllocate : Money;
   TotalAllocated   : Money;
   MemLine : pMemorisation_Line_Rec;
   FirstPercLine : integer;
begin
  Assert( mx.mdLines.ItemCount > 0, 'Memorisation does not have any lines in MemorisationSplit');

  SetLength(Split, mx.mdLines.ItemCount);
  SetLength(SplitPercentages, mx.mdLines.ItemCount);
  AmountToAllocate := Amount;
  TotalPerc        := 0;
  TotalAllocated   := 0;
  FirstPercLine    := -1;

  for i := MX.mdLines.First to MX.mdLines.Last do
  begin
    Split[i] := 0;
    SplitPercentages[i] := 0;
  end;


  //allocate fixed dollar amounts first
  for i := MX.mdLines.First to MX.mdLines.Last do
    begin
      MemLine := MX.mdLines.MemorisationLine_At(i);

      if ( MemLine.mlLine_Type = BKCONST.mltDollarAmt) and ( MemLine.mlAccount <> '') then
        begin
          Split[i] := MemLine.mlPercentage;
          SplitPercentages[i] := 0;
          AmountToAllocate := AmountToAllocate - Split[i];

          TotalAllocated := TotalAllocated + Split[i];
        end;
    end;

  //allocate remainder using percentages
  Remainder := AmountToAllocate;
  for i := MX.mdLines.First to MX.mdLines.Last do
    begin
      MemLine := MX.mdLines.MemorisationLine_At(i);

      if ( MemLine.mlLine_Type = BKCONST.mltPercentage) and ( MemLine.mlAccount <> '') then
        begin
          if FirstPercLine = -1 then
            FirstPercLine := i;

          //keep track of total perc
          TotalPerc := TotalPerc + MemLine.mlPercentage;
          if ( TotalPerc = 1000000) then
            begin
              Split[i] := Remainder;
              SplitPercentages[i] := MemLine.mlPercentage;
              Remainder := 0;

              TotalAllocated := TotalAllocated + Split[i];
            end
          else
            begin
              Percentage := MemLine.mlPercentage / 10000;
              Temp       := AmountToAllocate * Percentage / 100.0;
              Split[i] := Round( Temp);
              SplitPercentages[i] := MemLine.mlPercentage;
              Remainder := Remainder - Split[i];

              TotalAllocated := TotalAllocated + Split[i];
            end;
        end;
    end;

  //put any leftover into first perc line
  if FirstPercLine = -1 then
    //no perc line found so just put into first line
    FirstPercLine := 0;

  Split[ FirstPercLine] := Split[ FirstPercLine] + ( Amount - TotalAllocated);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


Procedure PayeePercentageSplit( CONST Amount : Money; CONST Payee : TPayee;
  Var PayeeSplit : PayeeSplitTotals; var SplitPercentages: PayeeSplitPercentages  );
//assumes that the payee has lines
Var
  i : Integer;
  TotalPerc, Remainder : Money;
  Percentage     : Extended;
  Temp           : Extended;
  PayeeLine      : pPayee_Line_Rec;
  TotalAllocated : Money;
  AmountToAllocate : Money;
  FirstPercLine : integer;
Begin
  Assert( Payee.pdLines.ItemCount > 0, 'Payee does not have any lines in PayeePercentageSplit');

  SetLength(PayeeSplit, Payee.pdLines.ItemCount);
  SetLength(SplitPercentages, Payee.pdLines.ItemCount);
  AmountToAllocate := Amount;
  TotalPerc        := 0;
  TotalAllocated   := 0;
  FirstPercLine := -1;

  for i := Payee.pdLines.First to Payee.pdLines.Last do
  begin
    PayeeSplit[i] := 0;
    SplitPercentages[i] := 0;
  end;

  //allocate fixed dollar amounts first
  for i := Payee.pdLines.First to Payee.pdLines.Last do
    begin
      PayeeLine := Payee.pdLines.PayeeLine_At(i);

      if ( PayeeLine.plLine_Type = BKCONST.pltDollarAmt) and ( PayeeLine.plAccount <> '') then
        begin
          PayeeSplit[i] := PayeeLine.plPercentage;
          SplitPercentages[i] := 0;
          AmountToAllocate := AmountToAllocate - PayeeSplit[i];

          TotalAllocated := TotalAllocated + PayeeSplit[i];
        end;
    end;

  //allocate remainder using percentages
  Remainder := AmountToAllocate;
  for i := Payee.pdLines.First to Payee.pdLines.Last do
    begin
      PayeeLine := Payee.pdLines.PayeeLine_At(i);
      if ( PayeeLine.plLine_Type = BKCONST.pltPercentage) and ( PayeeLine.plAccount <> '') then
        begin
          if FirstPercLine = -1 then
            FirstPercLine := i;

          //keep track of total perc
          TotalPerc := TotalPerc + PayeeLine.plPercentage;
          if ( TotalPerc = 1000000) then
            begin
              PayeeSplit[i] := Remainder;
              SplitPercentages[i] := PayeeLine.plPercentage;
              Remainder := 0;

              TotalAllocated := TotalAllocated + PayeeSplit[i];
            end
          else
            begin
              Percentage := PayeeLine.plPercentage / 10000;
              Temp       := AmountToAllocate * Percentage / 100.0;
              PayeeSplit[i] := Round( Temp);
              SplitPercentages[i] := PayeeLine.plPercentage;
              Remainder := Remainder - PayeeSplit[i];

              TotalAllocated := TotalAllocated + PayeeSplit[i];
            end;
        end;
    end;

  //put any leftover into first perc line
  if FirstPercLine = -1 then
    //no perc line found so just put into first line
    FirstPercLine := 0;

  PayeeSplit[ FirstPercLine] := PayeeSplit[ FirstPercLine] + ( Amount - TotalAllocated);
end;

end.
