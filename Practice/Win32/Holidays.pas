unit Holidays;
//------------------------------------------------------------------------------
{
   Title:       Holidays Unit

   Description: This unit provide routines to tell if a particular date is
                a public holiday

   Author:      Matthew Hopkins  Aug 2002

   Remarks:

   New Zealand has some national public holiday dates that are the same from
   year to year, and others that change.

   Holiday	    Actual Date	       Notes
   New Year's Day   1 January	       If New Year's Day is either a Monday,
                                       Tuesday, Wednesday or Thursday, then it
                                       is observed on that day and the following
                                       day is also observed as a holiday.
                                       If New Year's Day is a Friday, the Friday
                                       becomes a holiday, and also the following
                                       Monday.If New Year's Day is either a
                                       Saturday or a Sunday, then a public
                                       holiday is held on the following Monday
                                       and Tuesday.

   Day after New Year's Day	2 January

   Waitangi Day	    February 6	         Always observed 6 February.

   Good Friday	    varies
   Easter Monday    varies

   ANZAC Day	    25 April	         Always observed on 25 April.
   Queen's Birthday 1st Monday in June	 The date that New Zealand observes the Queen's birthday. Queen Elizabeth II's actual birthday is 21 April 1926.
   Labour Day	    4th Monday in October

   Christmas Day    25 December	         Christmas Day and Boxing Day have the
                                         same observance rules as New Year's Day
                                         and Day after New Year's Day.
   Boxing Day	    26 December


}
//------------------------------------------------------------------------------

interface

function IsAPublicHoliday_NZ( aDate : integer) : boolean;

//******************************************************************************
implementation
uses
  StDate;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Const
   Epoch = 1970;  //Ignores Globals setting for this value

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function NthDayInMonth( N : integer; Day : TStDayType; MonthNo : integer; Year : integer) : integer;
//return the nth day in the month, ie 3rd Monday
var
  Count : integer;
  TestDate : integer;
  StopDate : integer;
begin
  Count := 0;
  //make sure we don't get into an endless loop
  StopDate := DmyToStDate( DaysInMonth( MonthNo, Year, Epoch) , MonthNo, Year, Epoch);
  //start from the day before so we can use a repeat loop
  TestDate := DmyToStDate( 1, MonthNo, Year, Epoch) -1;

  repeat
    TestDate := TestDate + 1;
    if DayOfWeek( TestDate) = Day then
      Count := Count + 1;
  until ( Count = N) or ( TestDate > StopDate);

  if TestDate > StopDate then
    result := -1
  else
    result := TestDate;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsAPublicHoliday_NZ( aDate : integer) : boolean;
const
   GoodFridayDates : Array[0..11] of Integer =(
                                    145466,     //10 Apr 1998
                                    145823,     //02 Apr 1999
                                    146802,     //21 Apr 2000
                                    146565,     //13 Apr 2001
                                    146915,     //29 Mar 2002
                                    147300,     //18 Apr 2003
                                    147657,     //09 Apr 2004
                                    148007,     //25 Mar 2005
                                    148392,     //14 Apr 2006
                                    148749,     //06 Apr 2007
                                    149099,     //21 Mar 2008
                                    149484      //10 Apr 2009
                                   );
var
  i          : integer;
  d,m,y      : integer;
  Holiday    : integer;
  Christmas  : integer;
  BoxingDay  : integer;
  NewYears   : integer;
  DayAfterNewYear : integer;
begin
  result := true;
  StDateToDMY( aDate, d,m,y);

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //first test easy dates that don't change
  //Waitangi Day
  if ( d = 6) and ( m = 2) then
    Exit;

  //Anzac Day
  if ( d = 25) and ( m = 4) then
    Exit;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //test calculated dates
  //Queens Birthday  1st Monday in June
  Holiday := NthDayInMonth( 1, Monday, 6, y);
  if ( aDate = Holiday) then
    Exit;

  //Labour Day	    4th Monday in October
  Holiday := NthDayInMonth( 4, Monday, 10, y);
  if ( aDate = Holiday) then
    Exit;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //now for the difficult dates
  //Christmas
  Christmas := DMYtoSTDate( 25,12,y,Epoch);
  BoxingDay := Christmas + 1;

  case DayOfWeek( Christmas) of
    Monday, Tuesday, Wednesday, Thursday :
      BoxingDay := Christmas + 1;

    Friday :
      BoxingDay := Christmas + 3;  //following monday

    Saturday :
    begin
      Christmas := Christmas + 2;
      BoxingDay := Christmas + 1;
    end;

    Sunday :
    begin
      Christmas := Christmas + 1;
      BoxingDay := Christmas + 1;
    end;
  end;

  if (aDate = Christmas) or (aDate = BoxingDay) then
    Exit;

  //New Years
  NewYears := DMYtoSTDate( 1, 1 ,y, Epoch);
  DayAfterNewYear := NewYears + 1;

  case DayOfWeek( NewYears) of
    Monday, Tuesday, Wednesday, Thursday :
      DayAfterNewYear := NewYears + 1;

    Friday :
      DayAfterNewYear := NewYears + 3;  //following monday

    Saturday :
    begin
      NewYears        := NewYears + 2;
      DayAfterNewYear := NewYears + 1;
    end;

    Sunday :
    begin
      NewYears        := NewYears + 1;
      DayAfterNewYear := NewYears + 1;
    end;
  end;

  if (aDate = NewYears) or (aDate = DayAfterNewYear) then
    Exit;

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //Good Friday - could not find a equation for this day, check hard coded dates
  for i := Low(GoodFridayDates) to High(GoodFridayDates) do
  begin
    if aDate = GoodFridayDates[i] then
      Exit;

    //Easter Monday - could not find a equation for this day
    if (aDate - 3) = GoodFridayDates[i] then
      Exit;
  end;

  //no holiday dates detected
  Result := False;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

(*
initialization
  //check dates for 2003
  Assert( IsAPublicHoliday_NZ( DMYToSTDate( 1, 1, 03,  Epoch)), 'New Years Day');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate( 2, 1, 03,  Epoch)), 'Day After New Years Day');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate( 6, 2, 03,  Epoch)), 'Waitangi');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate(18, 4, 03,  Epoch)), 'Good Friday');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate(21, 4, 03,  Epoch)), 'Easter Monday');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate(25, 4, 03,  Epoch)), 'Anzac');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate( 2, 6, 03,  Epoch)), 'Queens Birthday');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate(27,10, 03,  Epoch)), 'Labour Day');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate(25,12, 03,  Epoch)), 'Christmas');
  Assert( IsAPublicHoliday_NZ( DMYToSTDate( 1, 1, 03,  Epoch)), 'Boxing Day');
*)
end.
