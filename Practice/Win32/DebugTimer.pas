unit DebugTimer;

interface

uses
  Windows;

type
  {-----------------------------------------------------------------------------
    IDebugTimer
  -----------------------------------------------------------------------------}
  IDebugTimer = interface(IUnknown)
  ['{7D89C8AC-3AB0-4BD3-8363-7ADA6DC0D271}']
  end;


  {-----------------------------------------------------------------------------
    TDebugTimer
  -----------------------------------------------------------------------------}
  TDebugTimer = class(TInterfacedObject, IDebugTimer)
  private
    fName: string;
    fStart: DWORD;

  public
    constructor Create(const aName: string);
    destructor  Destroy; override;

  private

  end;


  {-----------------------------------------------------------------------------
    TStat
  -----------------------------------------------------------------------------}
  TStat = record
    Name: string;
    Duration: DWORD;
    Count: integer;
    Max: integer;
  end;


  {-----------------------------------------------------------------------------
    TDebugStats
  -----------------------------------------------------------------------------}
  TDebugStats = class(TObject)
  private
    fStats: array of TStat;

  public
    procedure RecordDuration(const aName: string; const aDuration: DWORD);

    procedure LogStats;

  private
    function  GetPadString(const aValue: string; const aCount: integer): string;

  end;


  {-----------------------------------------------------------------------------
    TDebugStats
  -----------------------------------------------------------------------------}
  function  CreateDebugTimer(const aName: string): IDebugTimer;


implementation

uses
  SysUtils,
  MMSystem,
  Classes,
  Math;

const
  UnitName = 'DebugTimer';

var
  u_Stats: TDebugStats;

function DebugStats: TDebugStats;
begin
  if not assigned(u_Stats) then
    u_Stats := TDebugStats.Create;

  result := u_Stats;
end;

{-------------------------------------------------------------------------------
  TDebugTimer
-------------------------------------------------------------------------------}
constructor TDebugTimer.Create(const aName: string);
begin
  fName := aName;
  fStart := timeGetTime;
end;

//------------------------------------------------------------------------------
destructor TDebugTimer.Destroy;
var
  dwDuration: DWORD;
begin
  dwDuration := timeGetTime - fStart;

  DebugStats.RecordDuration(fName, dwDuration);

  inherited; // LAST
end;


{-------------------------------------------------------------------------------
  TDebugStats
-------------------------------------------------------------------------------}
function CreateDebugTimer(const aName: string): IDebugTimer;
begin
  result := TDebugTimer.Create(aName);
end;


{-------------------------------------------------------------------------------
  TDebugStats
-------------------------------------------------------------------------------}
procedure TDebugStats.RecordDuration(const aName: string;
  const aDuration: DWORD);
var
  i: integer;
  iCount: integer;
begin
  // Add to existing
  for i := 0 to High(fStats) do
  begin
    with fStats[i] do
    begin
      if (Name = aName) then
      begin
        Duration := Duration + aDuration;
        Inc(Count);
        Max := Math.Max(Max, aDuration);

        exit;
      end;
    end;
  end;

  // Add new
  iCount := Length(fStats);
  SetLength(fStats, iCount+1);
  with fStats[iCount] do
  begin
    Name := aName;
    Duration := aDuration;
    Count := 1;
    Max := aDuration;
  end;
end;

//------------------------------------------------------------------------------
function TDebugStats.GetPadString(const aValue: string; const aCount: integer
  ): string;
begin
  result := aValue;

  while (Length(result) < aCount) do
    result := result + ' ';
end;

//------------------------------------------------------------------------------
procedure TDebugStats.LogStats;
var
  i: integer;
  iPad: integer;
  dwTotal: DWORD;
  iAvg: DWORD;
  iPercent: DWORD;
  sMsg: string;
  sName: string;
  Output: TStringList;
begin
  // Totals
  iPad := 0;
  dwTotal := 0;
  for i := 0 to High(fStats) do
  begin
    iPad := Max(iPad, Length(fStats[i].Name));
    dwTotal := dwTotal + fStats[i].Duration;
  end;

  // Log
  Output := TStringList.Create;
  try
    // Log lines
    for i := 0 to High(fStats) do
    begin
      with fStats[i] do
      begin
        sName := GetPadString(Name, iPad);
        iAvg := Round(Duration / Count);
        iPercent := Round(100 * Duration / dwTotal);

        sMsg := Format('%8d x %s | %7d ms | Avg = %4d ms | Max = %4d ms | Percent = %2d %%',
          [Count, sName, Duration, iAvg, Max, iPercent]);

        Output.Add(sMsg);
      end;
    end;

    // Try to save
    try
      Output.SaveToFile('BK5WIN.STATS');
    except
      ; // Ignore
    end;
  finally
    FreeAndNil(Output);
  end;
end;


//------------------------------------------------------------------------------
initialization
begin
end;


//------------------------------------------------------------------------------
finalization
begin
  // Note: LogUtil.Log will not work from here

  if assigned(u_Stats) then
    u_Stats.LogStats;

  FreeAndNil(u_Stats);
end;


end.