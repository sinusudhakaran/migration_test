unit AppTime;
{--------------------------------------------}
{ high precision timer unit for windows      }
{                                            }
{ adapted from example given in              }
{ 'The Tomes of Delphi3"                     }
{                                            }
{ written by Matthew Hopkins Apr98           }
{--------------------------------------------}

interface
uses
  Windows, SysUtils;

  procedure StartTime;
  procedure StopTime;
  function  GetElapsed : Extended;
  function  GetElapsedStr : string;

{--------------------------------------------}
implementation
var
   StartCount,
   EndCount,
   Frequency : TLargeInteger;

   ElapsedTime,
   WasElapsed  : Extended;

   TimeStopped : boolean;

{--------------------------------------------}
procedure StartTime;
begin
   timeStopped := false;
   QueryPerformanceCounter(StartCount);
end;

{--------------------------------------------}
procedure StopTime;
begin
   WasElapsed  := GetElapsed;
   timeStopped := true;
end;

{--------------------------------------------}
function GetElapsed : Extended;
begin
   if TimeStopped then
      result := WasElapsed
   else
   begin
      QueryPerformanceCounter(EndCount);
      //  Delphi 3
      //      ElapsedTime := (EndCount.QuadPart-StartCount.QuadPart)/Frequency.QuadPart;

      ElapsedTime := (EndCount-StartCount)/Frequency;
      result := ElapsedTime;
   end;
end;

{--------------------------------------------}
function GetElapsedStr : string;
begin
   result := FloatToStr(GetElapsed)+' sec.';
end;

{--------------------------------------------}
initialization
   QueryPerformanceFrequency(Frequency);
   QueryPerformanceCounter(StartCount);
   TimeStopped := false;
end.
