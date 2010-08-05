unit mxUtils;
//based on unit from BK5

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
INTERFACE USES ECDefs, MoneyDef, glConst, ECPayeeObj;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

TYPE
   SplitTotals = Array[ 1 .. glConst.Max_mx_Lines  ] of Money;

   PayeeSplitTotals = Array of Money;

Procedure PayeePercentageSplit( CONST Amount : Money; CONST Payee : TECPayee; Var PayeeSplit : PayeeSplitTotals );
// Summary:
//    Splits the amount up based on the percentages in the Payee.
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
  bkConst;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure PayeePercentageSplit( CONST Amount : Money; CONST Payee : TECPayee; Var PayeeSplit : PayeeSplitTotals );
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
  AmountToAllocate := Amount;
  TotalPerc        := 0;
  TotalAllocated   := 0;
  FirstPercLine := -1;

  for i := Payee.pdLines.First to Payee.pdLines.Last do
    PayeeSplit[i] := 0;

  //allocate fixed dollar amounts first
  for i := Payee.pdLines.First to Payee.pdLines.Last do
    begin
      PayeeLine := Payee.pdLines.PayeeLine_At(i);

      if ( PayeeLine.plLine_Type = BKCONST.pltDollarAmt) and ( PayeeLine.plAccount <> '') then
        begin
          PayeeSplit[i] := PayeeLine.plPercentage;
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
              Remainder := 0;

              TotalAllocated := TotalAllocated + PayeeSplit[i];
            end
          else
            begin
              Percentage := PayeeLine.plPercentage / 10000;
              Temp       := AmountToAllocate * Percentage / 100.0;
              PayeeSplit[i] := Round( Temp);
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
