unit TimeUtils;

{
   Title: Timer Utilities

   Description: This is the EventTimer code from APRO OOMISC.PAS.

   Author:      Steve 01/2000
}
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

interface uses Windows;

Type
  EventTimer = record
    StartTicks  : LongInt;  {Tick count when timer was initialized}
    ExpireTicks : LongInt; {Tick count when timer will expire}
  end;
  
const
  MaxTicks    = 39045157;   {Max ticks, 24.8 days}  {!!.01}

  {Clock frequency of 1193180/65536 is reduced to 1675/92. This}
  {allows longint conversions of Ticks values upto TicksPerDay}
  TicksFreq = 1675;
  SecsFreq  = 92;

function Ticks2Secs(Ticks : LongInt) : LongInt;
function Secs2Ticks(Secs : LongInt) : LongInt;
procedure NewTimer(var ET : EventTimer; Ticks : LongInt);
procedure NewTimerSecs(var ET : EventTimer; Secs : LongInt);
function TimerExpired(ET : EventTimer) : Boolean;
function ElapsedTime(ET : EventTimer) : LongInt;
function ElapsedTimeInSecs(ET : EventTimer) : LongInt;
function RemainingTime(ET : EventTimer) : LongInt;
function RemainingTimeInSecs(ET : EventTimer) : LongInt;
Procedure DelayTicks(Ticks: LongInt; Yield : Boolean );
Procedure DelayMS( MS : Cardinal; Yield : Boolean );

// Matt's High Precision Timer Code

Procedure StartTimer;
Procedure StopTimer;
Function  ElapsedTimeMS : Integer;

implementation
uses WinTypes, WinProcs, Messages;

  Procedure SafeYield;
    {-Allow other processes a chance to run}
  var
    Msg : TMsg;
  begin
    if PeekMessage(Msg, 0, 0, 0, PM_REMOVE) then begin
      if Msg.Message = wm_Quit then
        {Re-post quit message so main message loop will terminate}
        PostQuitMessage(Msg.WParam)
      else begin
        TranslateMessage(Msg);
        DispatchMessage(Msg);
      end;
    end;
  end;

  function Ticks2Secs(Ticks : LongInt) : LongInt;
    {-Returns seconds value for Ticks Ticks}
  begin
    Ticks2Secs := ((Ticks + 9) * SecsFreq) div TicksFreq;
  end;

  function Secs2Ticks(Secs : LongInt) : LongInt;
    {-Returns Ticks value for Secs seconds}
  begin
    Secs2Ticks := (Secs * TicksFreq) div SecsFreq;
  end;

  procedure NewTimer(var ET : EventTimer; Ticks : LongInt);
    {-Returns a set EventTimer that will expire in Ticks}
  begin
    {Max acceptable value is MaxTicks}
    if Ticks > MaxTicks then
      Ticks := MaxTicks;

    with ET do begin
      StartTicks := GetTickCount div 55;
      ExpireTicks := StartTicks + Ticks;
    end;
  end;

  procedure NewTimerSecs(var ET : EventTimer; Secs : LongInt);
    {-Returns a set EventTimer}
  begin
    NewTimer(ET, Secs2Ticks(Secs));
  end;

  function TimerExpired(ET : EventTimer) : Boolean;
    {-Returns True if ET has expired}
  var
    CurTicks : LongInt;
  begin
    with ET do begin
      {Get current Ticks; assume timer has expired}
      CurTicks := GetTickCount div 55;
      TimerExpired := True;

      {Check normal expiration}
      if CurTicks > ExpireTicks then
        Exit;
      {Check wrapped CurTicks}
      if (CurTicks < StartTicks) and
         ((CurTicks + MaxTicks) > ExpireTicks) then
        Exit;

      {If we get here, timer hasn't expired yet}
      TimerExpired := False;
    end;
  end;

  function ElapsedTime(ET : EventTimer) : LongInt;
    {-Returns elapsed time, in Ticks, for this timer}
  var
    CurTicks : LongInt;
  begin
    with ET do begin
      CurTicks := GetTickCount div 55;
      if CurTicks >= StartTicks then
        {No wrap yet}
        ElapsedTime := CurTicks - StartTicks
      else
        {Got a wrap, account for it}
        ElapsedTime := (MaxTicks - StartTicks) + CurTicks;
    end;
  end;

  function ElapsedTimeInSecs(ET : EventTimer) : LongInt;
    {-Returns elapsed time, in seconds, for this timer}
  begin
    ElapsedTimeInSecs := Ticks2Secs(ElapsedTime(ET));
  end;

  function RemainingTime(ET : EventTimer) : LongInt;
    {-Returns remaining time, in Ticks, for this timer}
  var
    CurTicks : LongInt;
    RemainingTicks : LongInt;
  begin
    with ET do begin
      CurTicks := GetTickCount div 55;
      if CurTicks >= StartTicks then
        {No wrap yet}
        RemainingTicks := ExpireTicks - CurTicks
      else
        {Got a wrap, account for it}
        RemainingTicks := (ExpireTicks - MaxTicks) - CurTicks;
    end;
    if RemainingTicks < 0 then
      RemainingTime := 0
    else
      RemainingTime := RemainingTicks;
  end;

  function RemainingTimeInSecs(ET : EventTimer) : LongInt;
    {-Returns remaining time, in seconds, for this timer}
  begin
    RemainingTimeInSecs := Ticks2Secs(RemainingTime(ET));
  end;

  Procedure DelayTicks(Ticks : LongInt; Yield : Boolean );
    {-Delay for Ticks ticks}
  var
    ET : EventTimer;
  begin
    if Ticks <= 0 then Exit;

    if Ticks > MaxTicks then
      Ticks := MaxTicks;

    NewTimer(ET, Ticks);
    repeat
      if Yield then SafeYield;
    until TimerExpired(ET);
  end;

  Procedure DelayMS( MS : Cardinal; Yield : Boolean );
  var
    CDelay: Cardinal;
    CTime: Cardinal;
    LTime: Cardinal;
  begin
    LTime  := GetTickCount;
    CDelay := 0;
    repeat
      CTime := GetTickCount;
      CDelay := CDelay + (CTime - LTime);
      LTime := CTime;
      if Yield then SafeYield;
    until ( CDelay >= MS );
  end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// High Precision Timer
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

VAR
   StartTime  : TLargeInteger;
   StopTime   : TLargeInteger;
   Frequency  : TLargeInteger;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure StartTimer;
Begin
   Windows.QueryPerformanceCounter( StartTime );
   StopTime := StartTime;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Procedure StopTimer;
Begin
   Windows.QueryPerformanceCounter( StopTime );
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Function  ElapsedTimeMS : Integer;
Begin
   If Frequency > 0 then 
      Result := 1000 * ( StopTime - StartTime ) div Frequency
   else
      Result := 0;
end;

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


initialization
   QueryPerformanceFrequency( Frequency );
end.

