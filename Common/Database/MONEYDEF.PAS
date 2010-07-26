Unit MONEYDEF;
//------------------------------------------------------------------------------
{
   Title:

   Description:

   Author:

   Remarks:

}
//------------------------------------------------------------------------------
INTERFACE

TYPE
   Money = Comp;

   pTLBRec = ^TLBRec;

   { TODO 4 : Remove TlbRec and replace with TDynamic_Balances_Array}

   TLBRec = Record
      This_Year : Array[ 0..12 ] of Money; { 0 = Opening Balance }
      Last_Year : Array[ 0..12 ] of Money; { 0 = Opening Balance }
      Budget    : Array[ 0..12 ] of Money; { 0 = Opening Balance }
   end;

   DynamicMoneyArray = Array of Money;
   DynamicBooleanArray = Array of Boolean;

   TDynamic_Balances_Rec = Record
      This_Year : DynamicMoneyArray;
      Last_Year : DynamicMoneyArray;
      Budget    : DynamicMoneyArray;
      Is_Stock_Bal : DynamicBooleanArray;
      Is_Stock_Bal_Last_Year : DynamicBooleanArray;
      Budget_Unit_Price : DynamicMoneyArray;
   end;

CONST
   Unknown : Money = 0;

procedure DBR_SetLength( var Rec : TDynamic_Balances_Rec; Value : integer);
function  DMA_Sum( var Rec : DynamicMoneyArray) : Money;
procedure DBR_ClearValues( var Rec : TDynamic_Balances_Rec);

//******************************************************************************
IMPLEMENTATION
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DBR_SetLength( var Rec : TDynamic_Balances_Rec; Value : integer);
//need to set the length for each individual dynamic array
begin
   SetLength( Rec.This_Year, Value);
   SetLength( Rec.Last_Year, Value);
   SetLength( Rec.Budget,    Value);
   SetLength( Rec.Is_Stock_Bal, Value);
   SetLength( Rec.Is_Stock_Bal_Last_Year, Value);
   SetLength( Rec.Budget_Unit_Price, Value);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure DBR_ClearValues( var Rec : TDynamic_Balances_Rec);
var
  i : integer;
begin
  for i := Low( Rec.This_Year) to High( Rec.This_Year) do
    Rec.This_Year[i] := 0;
  for i := Low( Rec.Last_Year) to High( Rec.Last_Year) do
    Rec.Last_Year[i] := 0;
  for i := Low( Rec.Budget) to High( Rec.Budget) do
    Rec.Budget[i] := 0;
  for i := Low( Rec.Is_Stock_Bal) to High( Rec.Is_Stock_Bal) do
    Rec.Is_Stock_Bal[i] := False;
  for i := Low( Rec.Is_Stock_Bal_Last_Year) to High( Rec.Is_Stock_Bal_Last_Year) do
    Rec.Is_Stock_Bal_Last_Year[i] := False;
  for I := Low(Rec.Budget_Unit_Price) to High(Rec.Budget_Unit_Price) do
    Rec.Budget_Unit_Price[i] := 0;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function DMA_Sum( var Rec : DynamicMoneyArray) : Money;
var i : Integer ;
begin
  Result := 0 ;
  for i := Low( Rec ) to High( Rec ) do Result := Result + Rec[ i ] ;
end ;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Var
   UA : Array[1..8] of Byte absolute Unknown;
Begin
   FillChar( UA, Sizeof( UA ), $FF );
   UA[8]:=$7F;
END.

