unit CSUtils;

// -----------------------------------------------------------------------------
interface uses Windows;
// -----------------------------------------------------------------------------

Type
   IProfiler = Interface
      ['{35BD3818-1CF0-4190-89FB-65CF94B5D4B1}']
   end;

   TProfiler = Class( TInterfacedObject, IProfiler )
   Private
      FStartTime : TLargeInteger;
      FStopTime  : TLargeInteger;
      FProcName  : ShortString;
   Public
      Constructor Create( AProcName : ShortString );
      Destructor Destroy; Override;
   end;

// -----------------------------------------------------------------------------
implementation uses CSINTF, SysUtils;
// -----------------------------------------------------------------------------

Var
   Frequency : TLargeInteger;

Constructor TProfiler.Create( AProcName : ShortString );
Begin
   FProcName := AProcName;
   Windows.QueryPerformanceCounter( FStartTime );
   CodeSite.EnterMethod( FProcName );
end;

Destructor TProfiler.Destroy;
Var
   Elapsed : Integer;
Begin
   Windows.QueryPerformanceCounter( FStopTime );
   If Frequency > 0 then
      Elapsed := 1000 * ( FStopTime - FStartTime ) div Frequency
   else
      Elapsed := 0;
   CodeSite.ExitMethod( FProcName + ', elapsed time (ms) = ' + IntToStr( Elapsed ) );
   Inherited;
end;

initialization
   QueryPerformanceFrequency( Frequency );
end.

