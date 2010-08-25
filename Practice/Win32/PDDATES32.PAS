Unit PDDATES32;
//------------------------------------------------------------------------------
{
   Title:       Period Dates Utility Routines

   Description:

   Remarks:     Used by GST101frm and SelectGSTPeriodDlg

   Author:

}
//------------------------------------------------------------------------------
INTERFACE USES stDate, bkDateUtils;

//Function Get_PEDate_Rpt( PD_Start_Date: TStDate ): TstDate;
//Function Get_Previous_PSDate_Rpt( PD_Start_Date: TstDate ): TstDate;
//Function Get_Next_PSDate_Rpt( PD_Start_Date: TstDate ): TstDate;

Function Get_PEDate_GST( PD_Start_Date: TstDate; PeriodType : byte ): TstDate;
Function Get_Previous_PSDate_GST( PD_Start_Date: TstDate; PeriodType : byte ): TstDate;
Function Get_Next_PSDate_GST( PD_Start_Date: TstDate; PeriodType : byte ): TstDate;
function GetGSTPeriod(AnyDate: Integer; GSTStartMonth, PeriodType, Country: Byte):TDateRange;
function GetGSTDueDateForPeriod(PD_Start_Date, PD_End_Date: TstDate; GSTPeriod: Byte; Country: Byte): TstDate;
function GetNextGSTDueDate(AnyDate: Integer; GSTStartMonth, GSTPeriodType, Country: Integer): Integer; 

function GetPeriodMonths(PD_Start_Date,  PD_End_Date: TstDate): Integer;


//******************************************************************************
IMPLEMENTATION
USES
   GLOBALS,
   BKCONST,
   bkDefs;
{  ------------------------------------------------------------------- }
(*
Function Get_PEDate_Rpt( PD_Start_Date: TStDate ): TStDate;

Var D, M, Y : Integer;

Begin
   With MyClient.clFields do
   Begin
      stDateToDMY( Pd_Start_Date, D, M, Y );
      Case clReporting_Period of
         roSendEveryMonth        :;
         roSendEveryTwoMonths    : Inc( M, 1 );
         roSendEveryThreeMonths  : Inc( M, 2 );
         roSendEveryFourMonths   : Inc( M, 3 );
         roSendEverySixMonths    : Inc( M, 5 );
         roSendAnnually          : Inc( M, 11 );
      end;
      If M>12 then Begin Dec( M, 12 ); Inc( Y, 1 ); end;
      D := DaysInMonth( M, Y , BKDATEEPOCH);
   end;
   Get_PEDate_Rpt := DMYTostDate( D, M, Y, BKDATEEPOCH );
end;
//------------------------------------------------------------------------------

Function Get_Previous_PSDate_Rpt( PD_Start_Date: TStDate ): TStDate;
Var
   D, M, Y : Integer;
Begin
   With MyClient.clFields do
   Begin
      stDateToDMY( PD_Start_Date, D, M, Y );
      Case clReporting_Period of
         roSendEveryMonth        : Dec( M, 1 );
         roSendEveryTwoMonths    : Dec( M, 2 );
         roSendEveryThreeMonths  : Dec( M, 3 );
         roSendEveryFourMonths   : Dec( M, 4 );
         roSendEverySixMonths    : Dec( M, 6 );
         roSendAnnually          : Dec( M, 12 );
      end;
      If M<=0 then Begin Inc( M, 12 ); Dec( Y, 1 ); end;
   end;
   Get_Previous_PSDate_Rpt := DMYTostDate( 1, M, Y, BKDATEEPOCH );
end;
//------------------------------------------------------------------------------

Function Get_Next_PSDate_Rpt( PD_Start_Date: TStDate ): TStDate;
Var
   D, M, Y : Integer;
Begin
   With MyClient.clFields do
   Begin
      stDateToDMY( PD_Start_Date, D, M, Y );
      Case clReporting_Period of
         roSendEveryMonth        : Inc( M, 1 );
         roSendEveryTwoMonths    : Inc( M, 2 );
         roSendEveryThreeMonths  : Inc( M, 3 );
         roSendEveryFourMonths   : Inc( M, 4 );
         roSendEverySixMonths    : Inc( M, 6 );
         roSendAnnually          : Inc( M, 12 );
      end;
      If M>12 then Begin Dec( M, 12 ); Inc( Y, 1 ); end;
   end;
   Get_Next_PSDate_Rpt := DMYTostDate( 1, M, Y , BKDATEEPOCH);
end;
*)
//------------------------------------------------------------------------------

function GetPeriodMonths(PD_Start_Date,  PD_End_Date: TstDate): Integer;
var D, M1, M2, Y1, Y2 : Integer;
begin
   Result := 0; // start somewhere..
   if PD_End_Date <= PD_Start_Date then
      Exit;
   stDateToDMY( PD_Start_Date, D, M1, Y1 );
   if D <> 1 then
      Exit; // not month start..
   stDateToDMY(PD_End_Date, D, M2, Y2 );
   if D <> DaysInMonth(M2,Y2,BKDATEEPOCH) then
       Exit; // not month End..
   if Y2 > Y1 then
      M2 := M2 + (Y2-Y1) * 12;
   Result := Succ(M2-M1);

end;


//------------------------------------------------------------------------------
Function Get_PEDate_GST( PD_Start_Date: TStDate; PeriodType : byte): TStDate;
//given a start date and a period return the end date of the period
Var
   D, M, Y : Integer;
Begin
   result := -1;
   if PeriodType = gpNone then exit;
   stDateToDMY( PD_Start_Date, D, M, Y );
   Case PeriodType of
      gpMonthly  :;
      gp2Monthly : Inc( M, 1 );
      gp6Monthly : Inc( M, 5 );
      gpQuarterly: Inc( M, 2 );
      gpAnnually : Inc( M, 11 );
   end;
   If M>12 then Begin Dec( M, 12 ); Inc( Y, 1 ); end;
   D := DaysInMonth( M, Y , BKDATEEPOCH);
   result := DMYTostDate( D, M, Y , BKDATEEPOCH);
end;
//------------------------------------------------------------------------------

Function Get_Previous_PSDate_GST( PD_Start_Date: TStDate; PeriodType : byte): TStDate;
//given a start date and a period type return the start date of the previous period
var
   D, M, Y : Integer;
Begin
   result := -1;
   if PeriodType = gpNone then exit;
   StDateToDMY( PD_Start_Date, D, M, Y );
   Case PeriodType of
      gpMonthly  : Dec( M, 1 );
      gp2Monthly : Dec( M, 2 );
      gp6Monthly : Dec( M, 6 );
      gpQuarterly: Dec( M, 3 );
      gpAnnually : Dec( Y, 1 );
   end;
   If M<=0 then Begin Inc( M, 12 ); Dec( Y, 1 ); end;
   result := dmyToStDate( 1, M, Y, BKDATEEPOCH );
end;
//------------------------------------------------------------------------------

Function Get_Next_PSDate_GST( PD_Start_Date: TStDate; PeriodType : byte): TStDate;
//given a start date and a period type return the start date of the next period
Var
   D, M, Y : Integer;
Begin
   result := -1;
   if PeriodType = gpNone then exit;
   StDateToDMY( PD_Start_Date, D, M, Y );
   Case PeriodType of
      gpMonthly  : Inc( M, 1 );
      gp2Monthly : Inc( M, 2 );
      gp6Monthly : Inc( M, 6 );
      gpQuarterly: Inc( M, 3 );
      gpAnnually : Inc( Y, 1 );
   end;
   If M>12 then Begin Dec( M, 12 ); Inc( Y, 1 ); end;
   result := DMYToStDate( 1, M, Y , BKDATEEPOCH);
end;
//------------------------------------------------------------------------------
function GetGSTPeriod(AnyDate: Integer; GSTStartMonth, PeriodType, Country: Byte):TDateRange;
var
  Dummy: Integer;
  Year, NextFromDate: Integer;
Begin
  if PeriodType = gpNone then
    Exit;
  StDateToDMY( AnyDate, Dummy, Dummy, Year );
  //Start by looking at the first month of the year
  Result.FromDate := DMYTostDate( 1, GSTStartMonth, Year , EPOCH);
  if Result.FromDate > Anydate then
  begin
    // Too late.. find earlier
    repeat
      Result.FromDate := Get_Previous_PSDate_GST( Result.FromDate,PeriodType );
    until  Result.FromDate < AnyDate;
  end
  else if Result.FromDate < AnyDate then
  begin
    // To small , but do we have the latest?
    repeat
      //See if the next period's from date is greater.
      //if it is, then we had the correct one
      NextFromDate := Get_Next_PSDate_GST( Result.FromDate,PeriodType );
      if NextFromDate <= AnyDate then
        Result.FromDate := NextFromDate;
    until  NextFromDate > AnyDate;
  end;

  //Got from date, so just need to get To Date
  Result.ToDate :=   Get_PEDate_GST( Result.FromDate,PeriodType);
end;

function GetGSTDueDateForPeriod(PD_Start_Date, PD_End_Date: TstDate; GSTPeriod: Byte; Country: Byte): TstDate;
var
  D, M, Y: Integer;
begin
  if Country = whNewZealand then
  begin
    // Work out the Return / Payment date
    StDateToDmy(PD_End_Date, d, m, y);
    //Find the next month (returns normally due in next month)
    Inc (m);
    if m > 12 then
    begin
       m := 1;
       Inc( y);
    end;
    if PD_Start_Date >= DMYToStDate(1, 3, 2007, BKDATEEPOCH) then
    begin
       // returns after 01/04/07 always 28th of the following month
       // except if due in Dec it becomes 15 Jan
       // except if due in Apr it becomes 7 May
       // for earlier dates returns are due on the last business day of the following month
       if m = 12 then //Dec Exception
          Result := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(15, 1, y + 1, BKDATEEPOCH))
       else if m = 4 then //Apr Exception
          Result := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(7, m + 1, y, BKDATEEPOCH))
       else //Normal 28th of Next Month
          Result := bkDateUtils.NextBusinessDay_NZ(DMYToStDate(28, m, y, BKDATEEPOCH));
    end
    else
    begin
      //Old Rules
      if m = 12 then
        Result := bkDateUtils.NextBusinessDay_NZ( DmyToStDate( 15, 1, y + 1, BKDATEEPOCH))
      else
        Result := bkDateUtils.LastBusinessDayInMth_NZ( m, y);
    end;
  end
  else //Aussie
  begin
    //Returns are due on the 28th of the next month after the end of the period
    //if quarterly.
    //Assume that ToDate is an EOM date, so add 28 days
    //The except is return which are due in jan.  These have an extra month.
    //NOTE: Annual statements are due 28 Feb the following year
    //      Is setup for monthly GST then amounts are always due 21st of next mth

    //if GST is monthly then form is due on 21st
    Result := IncDate(PD_End_Date,21,0,0);
    if GSTPeriod = gpQuarterly then
    begin
       //if GST is Quarterly then form is due on 28th
      Result := IncDate(PD_End_Date,28,0,0);
      StDateToDMY( Result, d, m, y);
      if ( m = 1) then
      begin
        //forms due in Jan have an extra month
        Result := DMYtoSTDate( d, 2, y, BKDATEEPOCH);
      end;
    end;
  end;
end;

function GetNextGSTDueDate(AnyDate: Integer; GSTStartMonth, GSTPeriodType, Country: Integer): Integer;
var
  PreviousDueDate: Integer;
  PreviousStartDate: Integer;
  SecPreviousStartDate: Integer;
  SecPreviousDueDate: Integer;
  CurrentGSTPeriod: TDateRange;
begin
   //Find current GST period and previous GST period.
   //Check to see if previous GST period is still due, if so use it, otherwise use current period
   if (GSTPeriodType <> gpNone) and (GSTStartMonth <> 0) then
   begin
     CurrentGSTPeriod := GetGSTPeriod(AnyDate, GSTStartMonth, GSTPeriodType, Country);
     PreviousStartDate := Get_Previous_PSDate_GST(CurrentGSTPeriod.FromDate, GSTPeriodType);
     PreviousDueDate := GetGSTDueDateForPeriod(PreviousStartDate, Get_PEDate_GST(PreviousStartDate, GSTPeriodType), GSTPeriodType, Country);
     if (GSTPeriodType = gpMonthly) and (Country = whNewZealand) then
     begin
       //If NZ and monthly we may have to look at 2nd Previous period because of extensions
       SecPreviousStartDate := Get_Previous_PSDate_GST(PreviousStartDate, GSTPeriodType);
       SecPreviousDueDate := GetGSTDueDateForPeriod(SecPreviousStartDate, Get_PEDate_GST(SecPreviousStartDate, GSTPeriodType), GSTPeriodType, Country);
       if (SecPreviousDueDate < PreviousDueDate) and (SecPreviousDueDate >= stDate.CurrentDate) then
       begin
         Result := SecPreviousDueDate;
         Exit;
       end;
        //if not then carry on with the checks of the previous due date
     end;
     if PreviousDueDate >= stDate.CurrentDate then
        Result := PreviousDueDate
     else
        Result := GetGSTDueDateForPeriod(CurrentGSTPeriod.FromDate, CurrentGSTPeriod.ToDate, GSTPeriodType, Country);
   end
   else
    Result := 0;
end;

END.
