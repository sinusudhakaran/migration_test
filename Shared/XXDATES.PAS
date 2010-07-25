{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

{ __revision_history__
1 DATES.PAS 10-Apr-97,10:47:08 RCS
  __revision_history__ }

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴�  }

unit xxDates;

{..$I COMPILER.PAS}

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }
INTERFACE
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

USES OpDate;

TYPE
   liDate = LongInt;

function Date2Str( D : Date ) : String;
function Date2LStr( D : Date ) : String;
function Str2Date( S : String ): Date;
function Time2Str( T : Time ): String;
function Str2Time( S : String ): Time;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }
IMPLEMENTATION
{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

{ __keyword_flag__ '%n v%v, %d' }
CONST CurrentVersionNo = 'DATES.PAS v1, 10-Apr-97';

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

CONST
   DateTemplate    = 'dd/mm/yy';
   TimeTemplate    = 'hh:mm:ss te';

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

FUNCTION Date2Str( D : Date ): String;
begin
   If D<>0 then
      Date2Str:=DatetoDateString( DateTemplate, D )
   else
      Date2Str:='';
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

function Date2LStr( D : Date ): String;
begin
   If D<>0 then
      Date2LStr:=DatetoDateString( 'dd nnn yyyy', D )
   else
      Date2LStr:='';
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

function Str2Date( S : String ): Date;
begin
   Str2Date:=0;
   If ( S='' ) then exit;
   Case Length( S ) of
      6 : If not ( DateStringisBlank(      'ddmmyy'    ,S ) ) then
             Str2Date:=DateStringtoDate(  'ddmmyy'    ,S );
      8 : If not ( DateStringisBlank(      'dd/mm/yy'  ,S ) ) then
             Str2Date:=DateStringtoDate(  'dd/mm/yy'  ,S );
     10 : If not ( DateStringisBlank(      'dd/mm/yyyy',S ) ) then
             Str2Date:=DateStringtoDate(  'dd/mm/yyyy',S );
   end;
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

function Time2Str( T : Time ): String;

Begin
   If T<>0 then
      Time2Str:=TimetoTimeString( TimeTemplate, T )
   else
      Time2Str:='';
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

function Str2Time( S : String ): Time;
begin
   Str2Time:=0;
   If ( S='' ) then exit;
   Case Length( S ) of
      6 : Str2Time:=TimeStringtoTime( 'hhmmss'        ,S );
      8 : Str2Time:=TimeStringtoTime( 'hh:mm:ss'      ,S );
     11 : Str2Time:=TimeStringtoTime( 'hh:mm:ss te'   ,S );
   end;
end;

{  컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴  }

END.
