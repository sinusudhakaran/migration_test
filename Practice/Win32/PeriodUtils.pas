unit PeriodUtils;
//------------------------------------------------------------------------------
{
   Title:       Period Utilities

   Description: Load periods information into dynamic array structure
                specified in DateDef.pas

   Author:     Matthew Hopkins

   Remarks:

}
//------------------------------------------------------------------------------

interface
uses
   clObj32, stDate, dateDef;

type
  TMonthInfoRec = record
                    Day     : string;
                    Month   : string;
                    Year    : string;
                    Status  : string;
                    ImageIndex      : integer;
                    PeriodStartDate : integer;
                    PeriodEndDate   : integer;
                  end;

  TMonthArray = Array of TMonthInfoRec;

function LoadPeriodDetailsIntoArray( aClient : TClientObj;
                                     StartDate : integer;
                                     EndDate : integer;
                                     CashOnly : boolean;
                                     PeriodType : byte;
                                     var DetailsArray : TPeriod_Details_Array) : integer;


function GetPeriodNo( const ADate : Integer ;
                      const DetailsArray : TPeriod_Details_Array) : Integer ;

//******************************************************************************
implementation
uses
   baObj32,
   bkConst,
   bkDateUtils,
   bkDefs, ECollect, BaList32, trxList32;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LoadPeriodDetailsIntoArray( aClient : TClientObj;
                                     StartDate : integer;
                                     EndDate : integer;
                                     CashOnly : boolean;
                                     PeriodType : byte;
                                     var DetailsArray : TPeriod_Details_Array) : integer;
//returns the number of periods in the array

//currently all parameters are passed in, this is so that the real settings do
//not have to be set in the client file while they are still be choosen.
var
   MaxPeriods        : integer;
   PeriodEnds        : integer;
   PeriodNo          : integer;
   i                 : integer;
   Day, Month, Year  : integer;

   BA                : TBank_Account;
   pT                : pTransaction_Rec;
   pD                : pDissection_Rec;
   b                 : integer;
   t                 : integer;

   InPeriodNo        : integer;
begin
   //test preconditions
   if PeriodType in [frpWeekly, frpFortnightly, frpFourWeekly, frpCustom] then
      Assert( EndDate <> 0, 'Must specify an end date for weekly or custom types');

   result      := 0;
   MaxPeriods  := 0;
   //set period dates
   case PeriodType of
      frpMonthly, frp2Monthly, frpQuarterly,
      frp6Monthly,frpYearly : begin
         MaxPeriods := pdMaximumNoOfPeriods[ PeriodType ] ;
         //We need one extra for the zero'th element
         SetLength( DetailsArray, ( MaxPeriods + 1 ) ) ;
         for i := 0 to MaxPeriods do begin
            DetailsArray[i].Period_Start_Date := 0;
            DetailsArray[i].Period_End_Date   := 0;
            DetailsArray[i].HasData           := false;
            DetailsArray[i].HasUncodedEntries := false;
         end;
         PeriodEnds := StartDate - 1 ;
         for PeriodNo := 0 to MaxPeriods do
         begin
            DetailsArray[ PeriodNo].Period_End_Date := PeriodEnds;
            StDatetoDMY( PeriodEnds, Day, Month, Year ) ;
            IncMY( Month, Year, IncBy[ PeriodType ] ) ;
            Day := DaysInMonth( Month, Year, Epoch ) ;
            PeriodEnds := DMYtoStDate( Day, Month, Year, Epoch ) ;
         end ;
         //return the number of periods
         result := MaxPeriods;
      end ;

      frpCustom : begin
         MaxPeriods := pdMaximumNoOfPeriods[ PeriodType ] ;
         //We need one extra for the zero'th element
         SetLength( DetailsArray, ( MaxPeriods + 1 ) ) ;
         for i := 0 to MaxPeriods do begin
            DetailsArray[i].Period_Start_Date := 0;
            DetailsArray[i].Period_End_Date   := 0;
            DetailsArray[i].HasData           := false;
            DetailsArray[i].HasUncodedEntries := false;
         end;
         DetailsArray[ 0].Period_End_Date := StartDate - 1;
         DetailsArray[ 1].Period_End_Date := EndDate;
         //return the number of periods
         result := MaxPeriods;
      end;

      frpWeekly, frpFortnightly, frpFourWeekly : begin
         PeriodEnds := StartDate - 1 ;
         MaxPeriods := 0;
         Repeat
            Inc( MaxPeriods );
            Inc( PeriodEnds, IncBy[ PeriodType ] ) ;
         Until ( PeriodEnds >= EndDate );
         //We need one extra for the zero'th element
         SetLength( DetailsArray, ( MaxPeriods + 1 ) ) ;
         for i := 0 to MaxPeriods do begin
            DetailsArray[i].Period_Start_Date := 0;
            DetailsArray[i].Period_End_Date   := 0;
            DetailsArray[i].HasData           := false;
            DetailsArray[i].HasUncodedEntries := false;
         end;

         PeriodEnds := StartDate - 1 ;
         For PeriodNo := 0 to MaxPeriods do begin
            DetailsArray[ PeriodNo ].Period_End_Date := PeriodEnds;
            If ( PeriodEnds > EndDate ) then
               DetailsArray[ PeriodNo ].Period_End_Date := EndDate;
            Inc( PeriodEnds, IncBy[ PeriodType ] ) ;
         end;
         //return the number of periods
         result := MaxPeriods;
      end ;
   end ;
   //period end dates have now been set, fill in period start date
   //note: remember that period 0 for opening balance so that start,end dates
   //      are not valid for period 0
   for PeriodNo := 1 to MaxPeriods do begin
      DetailsArray[ PeriodNo].Period_Start_Date := DetailsArray[ PeriodNo -1].Period_End_Date + 1;
   end;

   //Need to cycle through all bank accounts and then all transactions,
   //Test to see if can find code
   for b := 0 to Pred( aClient.clBank_Account_List.ItemCount) do begin
      Ba := aClient.clBank_Account_List.Bank_Account_At( b);

      if ( not CashOnly) or ( CashOnly and ( ba.baFields.baAccount_Type in bkconst.CashAccountsSet)) then
      begin
         for t:= 0 to Pred( BA.baTransaction_List.ItemCount) do begin
            pT := ba.baTransaction_List.Transaction_At( t);

            //find which period this transaction is in
            InPeriodNo := 0;
            PeriodNo   := 1;
            While ( PeriodNo <= MaxPeriods) and ( InPeriodNo = 0) do begin
               if ( pT.txDate_Effective >= DetailsArray[ PeriodNo].Period_Start_Date) and
                  ( pT.txDate_Effective <= DetailsArray[ PeriodNo].Period_End_Date) then begin
                  InPeriodNo := PeriodNo;
               end
               else
                  Inc( PeriodNo);
            end;

            //set the has data and has uncoded flags
            if InPeriodNo <> 0 then begin
               DetailsArray[ InPeriodNo].HasData := true;
               if pT.txFirst_Dissection = nil then begin
                  if aClient.clChart.FindCode( pT^.txAccount) = nil then
                     DetailsArray[ InPeriodNo].HasUncodedEntries := true;
               end
               else begin
                  pD := pT.txFirst_Dissection;
                  while ( pD <> nil) and ( not DetailsArray[ InPeriodNo].HasUncodedEntries) do begin
                     if aClient.clChart.FindCode( pD^.dsAccount) = nil then
                        DetailsArray[ InPeriodNo].HasUncodedEntries := true;
                     pD := pD.dsNext;
                  end;
               end;
            end;
         end; //for t := 0...
      end;
   end; //for b := ...

   //test post conditions
   If EndDate > 0 then
      Assert( DetailsArray[ High( DetailsArray ) ].Period_End_Date = EndDate);
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function GetPeriodNo( const ADate : Integer ;
                      const DetailsArray : TPeriod_Details_Array) : Integer ;
var
  Period        : Integer ;
begin
  Result := -1 ;
  for Period := Low( DetailsArray ) + 1 to High( DetailsArray ) do
  begin
    if ( ADate >= DetailsArray[ Period ].Period_Start_Date ) and ( ADate <= DetailsArray[ Period ].Period_End_Date ) then
    begin
      Result := Period ;
      Exit ;
    end ;
  end ;
end ;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
end.
