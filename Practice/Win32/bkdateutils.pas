Unit bkdateutils;

{..$.DEFINE DATE_UTILS_TEST} // Uncomment this to run the test code.

// -----------------------------------------------------------------------------
Interface Uses dateDef, StDate, StDateSt;
// -----------------------------------------------------------------------------

Const
   Epoch = 1970;  //Ignores Globals setting for this value

Type
   PEDateRec       = Array [0..12] of Integer;
   DateCompareType = ( None, Earlier, Within, Later  );
   TMonthEndDates = Array[ 0..12 ] of Integer;
   // Month 0 is used to get a valid startdate for month [1]
   TDateRange = Record
     FromDate : Integer;
     ToDate   : Integer;
   end;

   TDateList = array of Integer;

Function  GetYearEndDate( CONST YearStartDate: Integer ) : Integer;
Function  GetPrevYearStartDate( CONST ThisYearStartDate: Integer) : Integer;
Function  GetPrevYearEndDate( CONST ThisYearStartDate: Integer) : Integer;
Function  GetYearStartDate( CONST YearEndDate: Integer) : Integer;
Procedure GetPEDates( CONST YearStartDate: Integer; Var PEDates: tPeriod_End_Dates);
Function  GetPeriodNo( CONST ADate: Integer; CONST PEDates: tPeriod_End_Dates) : Integer;
Function  bkStr2Date( CONST DateStr: string) : Integer;
Function  bkDate2Str( CONST ADate: Integer) : string;
Function  IsTheLastDayofTheMonth( CONST ADate: Integer) : boolean;
Function  IsTheFirstDayOfTheMonth( CONST ADate: Integer) : boolean;
Function  GetLastDayOfMonth( CONST ADate: Integer) : Integer;
Function  GetFirstDayOfMonth( CONST ADate: Integer) : Integer;
function  GetMonthDateRange(const ADate: Integer): TDateRange;
Function  GetMonthsBetween(Date1, Date2: Integer): Integer;
Function  BLastMth : Integer;
Function  ELastMth : Integer;
Function  CompareDates( CONST aDate, aPeriodStartDate, aPeriodEndDate : Integer ) : DateCompareType;
Function  GetMonthName( CONST ADate: Integer) : string;
Function  GetMonthNumber( CONST ADate: Integer) : Integer;
Function  Date2Str( CONST ADate: Integer; CONST APicture : ShortString) : ShortString;
Function  Str2Date( CONST ADateStr: String; CONST APicture : ShortString) : Integer;
Function  BKNull2St( CONST ADate : Integer ) : Integer;
Function  StNull2BK( CONST ADate : Integer ) : Integer;
Procedure DecMY( Var Month, Year : Integer; Const NoOfMOnths : Integer = 1 );
Procedure IncMY( Var Month, Year : Integer; Const NoOfMOnths : Integer = 1 );

function LastBusinessDayInMth_NZ( aMonth, aYear : integer) : integer;
function IsABusinessDay_NZ( aDate : integer) : boolean;
function NextBusinessDay_NZ( aDate : integer) : integer;

Function MakeDateRange( Const StartDate, EndDate : Integer ): TDateRange;
Function GetMonthEndDates( Const YSD : Integer ): TMonthEndDates;
Function GetDateRangeS( CONST FromDate, ToDate: Integer ) : ShortString; overload;
function GetDateRangeS( const DR : TDateRange): ShortString; overload;
function GetPeriodsBetween(FromDate, ToDate: Integer; ReturnLastDay: Boolean = False): TDateList;
function BkDate2XSDate(ADate: Integer): String;
function GetLastDayOfLastMonth(Date: TStDate): TStDate;
function TryConvertStrMonthToInt(aStrMonth : string; var aMonth : integer) : boolean;

// -----------------------------------------------------------------------------
Implementation
// -----------------------------------------------------------------------------
uses
  SysUtils, Holidays, XSBuiltIns, StrUtils, bkConst;  // <- Only links to StDate

{19xx will be applied to dates until more than 30years less that today}

function BkDate2XSDate(ADate: Integer): String;
var
  XSDate: TXSDate;
begin
  XSDate := TXSDate.Create;

  try
    XSDate.AsDate := StDateToDateTime(ADate);

    Result := XSDate.NativeToXS;
  finally
    XSDate.Free;
  end;
end;

Function GetYearEndDate( CONST YearStartDate: Integer) : Integer;
Var
  Day,
  Month,
  Year  : Integer;
Begin
  If ( YearStartDate <=0 ) then
    Result := -1
  else
  Begin
    StDatetoDMY(YearStartDate, Day, Month, Year);
    Assert( Day = 1 ); { D should always be 1 }
    Result := DMYtoStDate(1, Month, Year + 1, Epoch) - 1;
  end;
end;

// -----------------------------------------------------------------------------

Function GetPrevYearStartDate( CONST ThisYearStartDate: Integer) : Integer;
Var
  Day,
  Month,
  Year  : Integer;
Begin
  If ThisYearStartDate <=0 then
    Result := -1
  else
  Begin
    StDatetoDMY(ThisYearStartDate, Day, Month, Year);
    Assert( Day = 1 ); { D should always be 1 }
    Result := DMYtoStDate( 1, Month, Pred( Year ), Epoch);
  end;
end;

// -----------------------------------------------------------------------------

Function GetPrevYearEndDate( CONST ThisYearStartDate: Integer) : Integer;
Begin
  If (ThisYearStartDate <=0 ) then
    Result := -1
  else
    Result := Pred( ThisYearStartDate );
end;

// -----------------------------------------------------------------------------

Function GetYearStartDate( CONST YearEndDate: Integer) : Integer;
Var
  Day,
  Month,
  Year           : Integer;
  NextYearStarts : Integer;
Begin
  If (YearEndDate <= 0 ) then
     Result := -1
  else
  Begin
    NextYearStarts := YearEndDate + 1;
    StDatetoDMY(NextYearStarts, Day, Month, Year); { D should always be 1 }
    Assert(Day = 1); { D should always be 1 }
    Result := DMYtoStDate(1, Month, Year - 1, Epoch);
  end;
end;

// -----------------------------------------------------------------------------

Procedure GetPEDates( CONST YearStartDate: Integer; Var PEDates: tPeriod_End_Dates );
Var
  Period     : Word;
  PeriodEnds : Integer;
  Day        : Integer;
  Month      : Integer;
  Year       : Integer;
Begin
  FillChar( PEDates, Sizeof( PEDates ), 0 );
  If YearStartDate > 0 then
  Begin
    PeriodEnds := YearStartDate - 1;
    For Period := 0 to 12 Do
    Begin
      PEDates[Period] := Periodends;
      StDatetoDMY(Periodends, Day, Month, Year);
      IncMY( Month, Year );
      Day := DaysInMonth(Month, Year, Epoch);
      PeriodEnds := DMYtoStDate(Day, Month, Year, Epoch);
    end;
  end;
end;

// -----------------------------------------------------------------------------

Function GetPeriodNo( CONST ADate: Integer; CONST PEDates: tPeriod_end_Dates) : Integer;
Var
  Period : Integer;
Begin
  Result := 0;
  For Period := 1 to 12 Do
  Begin
    If (ADate > PEDates[Period - 1]) and (ADate <= PEDates[Period]) then
    Begin
      Result := Period;
      exit;
    end;
  end;
end;

// -----------------------------------------------------------------------------

Function bkStr2Date( CONST DateStr: string ) : Integer;
   { Returns 0 for a null date, -1 for an invalid date }
Begin
  If DateStr = '' then
    Result := 0
  else
    Result := StDateSt.DateStringToStDate( 'dd/mm/yy', DateStr, Epoch );
end;

// -----------------------------------------------------------------------------

Function bkDate2Str( CONST ADate: Integer) : string;
begin
  bkDate2Str := Date2Str( ADate, 'dd/mm/yy' );
end;

// -----------------------------------------------------------------------------

Function BLastMth : Integer;
// Returns the first day in the previous month.
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY( CurrentDate, Day, Month, Year );
  DecMY( Month, Year );
  Result := DMYtoStDate(1, Month, Year, Epoch);
end;

// -----------------------------------------------------------------------------

Function ELastMth : Integer;
// Returns the last day in the previous month
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin { ELastMth }
  StDatetoDMY(CurrentDate, Day, Month, Year);
  DecMY( Month, Year );
  Day := DaysInMonth(Month, Year, Epoch);
  Result := DMYtoStDate(Day, Month, Year, Epoch);
end;

// -----------------------------------------------------------------------------

Function IsTheLastDayofTheMonth( CONST ADate: Integer) : boolean;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY( ADate, Day, Month, Year );
  Result := ( Day = DaysInMonth( Month, Year, Epoch ) );
end;

function  IsTheFirstDayOfTheMonth( CONST ADate: Integer) : boolean;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY( ADate, Day, Month, Year );
  
  Result := ( Day = 1 );
end;
// -----------------------------------------------------------------------------

Function GetLastDayOfMonth( CONST ADate: Integer) : Integer;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY(ADate, Day, Month, Year);
  Day := DaysInMonth(Month, Year, Epoch);
  Result := DMYtoStDate(Day, Month, Year, Epoch);
end;

// -----------------------------------------------------------------------------

Function  GetFirstDayOfMonth( CONST ADate: Integer) : Integer;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY(ADate, Day, Month, Year);
  Result := DMYtoStDate(1, Month, Year, Epoch);
end;

// -----------------------------------------------------------------------------

function  GetMonthDateRange(const ADate: Integer): TDateRange;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY(ADate, Day, Month, Year);
  Result.FromDate := DMYtoStDate(1, Month, Year, Epoch);
  Day := DaysInMonth(Month, Year, Epoch);
  Result.ToDate := DMYtoStDate(Day, Month, Year, Epoch);
end;

// -----------------------------------------------------------------------------

Function GetMonthsBetween(Date1, Date2: Integer): Integer;
var
  D1, D2, M1, M2, Y1, Y2: Integer;
begin
  StDatetoDMY(Date1, D1, M1, Y1);
  StDatetoDMY(Date2, D2, M2, Y2);
  if Date1 > Date2 then
    Result := M1 - M2 + ((Y1 - Y2) * 12)
  else
    Result := M2 - M1 + ((Y2 - Y1) * 12);
end;

// -----------------------------------------------------------------------------

Function  CompareDates( CONST aDate, aPeriodStartDate, aPeriodEndDate : Integer ) : DateCompareType;
Begin
  If aDate = 0  then CompareDates := None
  else If aDate < aPeriodStartDate then CompareDates := Earlier
  else If aDate > aPeriodEndDate   then CompareDates := Later
  else CompareDates := Within;                   
end;

// -----------------------------------------------------------------------------

Function GetMonthName( CONST ADate: Integer) : string;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY(ADate, Day, Month, Year);
  Result := StDateSt.MonthToString(Month);
end;

Function GetMonthNumber( CONST ADate: Integer) : Integer;
Var
  Day   : Integer;
  Month : Integer;
  Year  : Integer;
Begin
  StDatetoDMY(ADate, Day, Month, Year);
  Result := Month;
end;

// -----------------------------------------------------------------------------

Function Date2Str( CONST ADate: Integer; Const APicture : ShortString) : ShortString;
Begin
  If ADate <= 0 then
    Result := '' { Bad date or null date }
  else
    Result := StDateSt.StDateToDateString( APicture, ADate, False );
end;

// -----------------------------------------------------------------------------

Function Str2Date( CONST ADateStr: String; CONST APicture : ShortString) : Integer;
Begin
  If ADateStr = '' then
    Result := 0
  else
    Result := StDateSt.DateStringToStDate( APicture, ADateStr, Epoch );
end;

// -----------------------------------------------------------------------------

function BKNull2St( CONST ADate : Integer ) : Integer;
// Converts BK Null Date (0) to Orpheus Null Date (-1)
begin
  Result := ADate;
  if ADate = 0 then
    Result := -1;
end;

// -----------------------------------------------------------------------------

function StNull2BK( CONST ADate : Integer ) : Integer;
// Converts an Orpheus Null Date (-1) to BK Null Date (0)
begin
  Result := ADate;
  if ADate = -1 then
     Result := 0;
end;

// -----------------------------------------------------------------------------

Procedure IncMY( Var Month, Year : Integer; Const NoOfMOnths : Integer = 1 );
Begin
  Assert( Month in [ 1..12 ] );
  Assert( Year > 0 );
  Inc( Month, NoOfMonths );
  If Month > 12 then
  Begin
    Dec( Month, 12 );
    Inc( Year );
  end;
end;

// -----------------------------------------------------------------------------

Procedure DecMY( Var Month, Year : Integer; Const NoOfMOnths : Integer = 1 );
Begin
  Assert( Month in [ 1..12 ] );
  Assert( Year > 0 );
  Dec( Month, NoOfMonths );
  If Month <= 0 then
  Begin
    Inc( Month, 12 );
    Dec( Year );
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function IsABusinessDay_NZ( aDate : integer) : boolean;
//is monday = friday and not a public holiday
begin
  result := false;

  //is this a mon-fri day
  if StDate.DayOfWeek( aDate) in [ Sunday, Saturday] then
    Exit;

  //is this a public holiday
  if Holidays.IsAPublicHoliday_NZ( aDate) then
    Exit;

  //ok
  result := true;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function NextBusinessDay_NZ( aDate : integer) : integer;
var
  Found : boolean;
begin
  Result := aDate;
  repeat
    Found := IsABusinessDay_NZ( Result);
    if not Found then
      Inc( result);
  until Found;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function LastBusinessDayInMth_NZ( aMonth, aYear : integer) : integer;
var
  Found     : boolean;
  TestDate  : integer;
begin
  TestDate := DMYToSTDate( DaysInMonth( aMonth, aYear, Epoch), aMonth, aYear, Epoch);
  repeat
    Found    := IsABusinessDay_NZ( TestDate);
    if not Found then
      Dec( TestDate);
  until Found;

  result := TestDate;
end;
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Function MakeDateRange( Const StartDate, EndDate : Integer ): TDateRange;  
Begin
  Result.FromDate := StartDate;
  Result.ToDate   := EndDate;
end;

function GetMonthEndDates( const YSD : Integer ): TMonthEndDates;
var
  i : Integer;
  D, M, Y : Integer;
begin
  for i := low(Result) to High(Result)
     do Result[ i ] := -1;
  if YSD <= 0 then exit;
  StDateToDMY( YSD, D, M, Y );
  for i := 12 downto 0 do
  begin
    Result[ i ] := DMYToStDate( DaysInMonth( M, Y, Epoch ), M, Y, Epoch );
    DecMY( M, Y );
  end;
end;

Function GetDateRangeS( CONST FromDate, ToDate: Integer ): ShortString;
var
  D1, M1, Y1: Integer;
  D2, M2, Y2: Integer;
begin
  StDateToDMY( FromDate, D1, M1, Y1 );
  StDateToDMY( ToDate, D2, M2, Y2 );

  { Same month, show as XXX nnnn }

  If ( M1=M2 ) and ( Y1=Y2 ) and ( D1=1 ) and ( D2 = DaysInMonth( M2, Y2, Epoch ) ) then
  Begin
    Result := Format( '%s %0.4d', [ ShortMonthNames[ M1 ], Y1 ] );
    exit;
  end;

  { Same year, Show as XXX nnnn to YYY nnnn }

  If ( D1=1 ) and ( D2 = DaysInMonth( M2, Y2, Epoch ) ) then
  Begin
    If Y1 = Y2 then
    Begin
      Result := Format( '%s to %s %0.4d', [ ShortMonthNames[ M1 ], ShortMonthNames[ M2 ], Y2 ] );
      exit;
    end;

    Result := Format( '%s %0.4d to %s %0.4d',
      [ ShortMonthNames[ M1 ], Y1,
        ShortMonthNames[ M2 ], Y2 ] );
    exit;
  end;
  Result := Format( '%s to %s', [ Date2Str( FromDate, 'dd nnn yyyy' ), Date2Str( ToDate, 'dd nnn yyyy' ) ] );
end;

function GetDateRangeS( const DR : TDateRange): ShortString;
begin
   result := GetDateRangeS(DR.Fromdate, DR.Todate);
end;

function GetPeriodsBetween(FromDate, ToDate: Integer; ReturnLastDay: Boolean): TDateList;
var
  MonthsBetween: Integer;
  FromMonth: Integer;
  FromYear: Integer;
  TempDay: Integer;
  Month: Integer;
begin
  MonthsBetween := GetMonthsBetween(FromDate, ToDate);

  SetLength(Result, MonthsBetween + 1);

  StDateToDMY(FromDate, TempDay, FromMonth, FromYear);

  for Month := 0 to MonthsBetween do
  begin
    if ReturnLastDay then
    begin
      Result[Month] := DMYToStDate(DaysInMonth(FromMonth, FromYear, Epoch), FromMonth, FromYear, Epoch);
    end
    else
    begin
      Result[Month] := DMYToStDate(1, FromMonth, FromYear, Epoch);
    end;
    
    Inc(FromMonth, 1);

    if FromMonth > 12 then
    begin
      Inc(FromYear, 1);

      FromMonth := 1;
    end;
  end;
end;

function GetLastDayOfLastMonth(Date: TStDate): TStDate;
var
  Day: Integer;
  Month: Integer;
  Year: Integer;
  MaxDays: TStDate;
begin
  StDateToDMY(Date, Day, Month, Year);

  DecMY(Month, Year, 1);

  MaxDays := DaysInMonth(Month, Year, Epoch);

  Result := DMYToStDate(MaxDays, Month, Year, Epoch);
end;

//------------------------------------------------------------------------------
function TryConvertStrMonthToInt(aStrMonth : string; var aMonth : integer) : boolean;
var
  MonthIndex : integer;
  MonthName : string;
begin
  Result := true;

  if length(aStrMonth) = 0 then
  begin
    Result := false;
    Exit;
  end;

  if TryStrToInt(aStrMonth, aMonth) then
  begin
    if (aMonth <= 0) or
       (aMonth > 12) then
    begin
      Result := false;
      Exit;
    end;
  end
  else
  begin
    if length(aStrMonth) = 3 then
    begin
      for MonthIndex := 1 to 12 do
      begin
        MonthName := moNames[MonthIndex];
        if LeftStr(UpperCase(MonthName),3) = UpperCase(aStrMonth) then
        begin
          aMonth := MonthIndex;
          Exit;
        end;
      end;
      Result := false;
      Exit;
    end
    else
    begin
      for MonthIndex := 1 to 12 do
      begin
        MonthName := moNames[MonthIndex];
        if UpperCase(MonthName) = UpperCase(aStrMonth) then
        begin
          aMonth := MonthIndex;
          Exit;
        end;
      end;
      Result := false;
      Exit;
    end;
  end;
end;

{$IFDEF DATE_UTILS_TEST}
Var
  Month, Year : Integer;

Initialization
  Assert( GetYearEndDate( bkStr2Date( '01/04/00' ) ) = bkStr2Date( '31/03/01' ) );

  Assert( GetPrevYearStartDate( bkStr2Date( '01/04/00' ) ) = bkStr2Date( '01/04/99' ) );

  Assert( GetPrevYearEndDate( bkStr2Date( '01/04/00' ) ) = bkStr2Date( '31/03/00' ) );

  Assert( IsTheLastDayOfTheMonth( bkStr2Date( '31/03/99' ) ) );
  Assert( IsTheLastDayOfTheMonth( bkStr2Date( '30/03/99' ) ) =False );

  Assert( CompareDates( 0, bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = None );
  Assert( CompareDates( bkStr2Date( '01/02/99' ), bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = Earlier );
  Assert( CompareDates( bkStr2Date( '01/03/99' ), bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = Within );
  Assert( CompareDates( bkStr2Date( '10/03/99' ), bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = Within );
  Assert( CompareDates( bkStr2Date( '30/03/99' ), bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = Within );
  Assert( CompareDates( bkStr2Date( '31/03/99' ), bkStr2Date( '01/03/99' ), bkStr2Date( '30/03/99' ) ) = Later );

  Assert( bkDate2Str( bkStr2Date( '01/03/01' ) ) = '01/03/01' );

  Month := 1;  Year  := 2001; IncMY( Month, Year ); Assert( ( Month = 2 ) and ( Year = 2001 ) );
  Month := 12; Year  := 2001; IncMY( Month, Year ); Assert( ( Month = 1 ) and ( Year = 2002 ) );
  Month := 1;  Year  := 2001; IncMY( Month, Year, 3 ); Assert( ( Month = 4 ) and ( Year = 2001 ) );
  Month := 12; Year  := 2001; IncMY( Month, Year, 3 ); Assert( ( Month = 3 ) and ( Year = 2002 ) );

  Month := 1;  Year  := 2001; DecMY( Month, Year ); Assert( ( Month = 12 ) and ( Year = 2000 ) );
  Month := 12; Year  := 2001; DecMY( Month, Year ); Assert( ( Month = 11 ) and ( Year = 2001 ) );
  Month := 1;  Year  := 2001; DecMY( Month, Year, 3 ); Assert( ( Month = 10 ) and ( Year = 2000 ) );
  Month := 12; Year  := 2001; DecMY( Month, Year, 3 ); Assert( ( Month = 9 ) and ( Year = 2001 ) );

{$ENDIF DATE_UTILS_TEST}

end.
