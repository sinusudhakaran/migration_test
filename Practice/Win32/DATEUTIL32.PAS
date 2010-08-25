unit DATEUTIL32;

'NO LONGER USED !!!!!'

{  -----------------------------------------------------  }
INTERFACE USES ovcDate, datedef;
{  -----------------------------------------------------  }

TYPE
   PEDateRec = Array[ 0..12 ] of TStDate;

Function    GetYearStartDate( YEDate : TStDate ): TStDate;
Function    GetYearEndDate( YSDate : TStDate ): TStDate;
Procedure   GetPEDates( YSDate : TStDate; VAR PEDates : tPeriod_End_Dates );
Function    GetPeriodNo( D : LongInt; PEDates : tPeriod_End_Dates ): Byte;

{  -----------------------------------------------------  }
IMPLEMENTATION
{  -----------------------------------------------------  }

USES glConst;

Function GetYearEndDate( YSDate : TStDate ): TStDate;
Var
   D, M, Y : Integer;
Begin
   If ( YSDate = -1 ) or ( YSDate=0 ) then
      GetYearEndDate := -1
   else
   Begin
      STDateToDMY( YSDate, D, M, Y ); { D should always be 1 }
      GetYearEndDate := DMYTostDate( 1, M, Y+1, BKDATEEPOCH )-1;
   end;
end;

{  -----------------------------------------------------  }

Function GetYearStartDate( YEDate : TStDate ): TStDate;
Var
   D, M, Y : Integer; YS : TStDate;
Begin
   If ( YEDate = -1 ) or ( YEDate=0 ) then
      GetYearStartDate := -1
   else
   Begin
      YS := YEDate + 1;
      stDateToDMY( YS, D, M, Y ); { D should always be 1 }
      GetYearStartDate := DMYTostDate( 1, M, Y-1 ,BKDATEEPOCH);
   end;
end;

{  -----------------------------------------------------  }

Procedure GetPEDates( YSDate : TStDate; VAR PEDates : tPeriod_End_Dates );
Var
   Pd : Word;
   PE : LongInt;
   D, M, Y : Integer;
Begin
   FillChar( PEDates, Sizeof( PEDates ), 0 );
   PE := YSDate-1;
   If ( YSDate<>0 ) then For Pd := 0 to 12 do
   Begin
      PEDates[ Pd ] := PE;
      StDateToDMY( PE, D, M, Y );
      Inc( M );
      If M > 12 then
      Begin
         Inc( Y );
         M := M-12;
      End;
      D := DaysInMonth( M, Y, BKDATEEPOCH );
      PE := DMYTostDate( D, M, Y, BKDATEEPOCH );
   end;
end;

Function GetPeriodNo( D : LongInt; PEDates : tPeriod_End_Dates ): Byte;

Var
   Pd,j : Byte;
Begin
   Pd := 0;
   For j := 1 to 12 do
      If ( D > PEDates[ j-1 ] ) and
         ( D <= PEDates[ j ] ) then
            Pd := j;
   GetPeriodNo := Pd;
end;

END.


