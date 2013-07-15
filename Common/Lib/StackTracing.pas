unit StackTracing;

//------------------------------------------------------------------------------
interface

uses
  MadStackTrace;

function GetStackTrace() : TStackTrace;
procedure LogStackTrace(aUnitName, aFunctionName: string; aStackTrace: TStackTrace; aStat_ID : byte = 0);
procedure GetAndLogStackTrace(aUnitName, aFunctionName: string; aStat_ID : byte = 0);

//------------------------------------------------------------------------------
implementation

uses
  SysUtils,
  Logutil;

//------------------------------------------------------------------------------
function GetStackTrace() : TStackTrace;
begin
  StackTrace(True,  false, false, @Result, nil,
             false, false, 0,     0,       nil,
             nil,   nil,   nil,   nil,     0,
             false, false, nil,   nil,     nil,
             nil,   nil,   nil,   false);
end;

//------------------------------------------------------------------------------
procedure LogStackTrace(aUnitName, aFunctionName: string; aStackTrace: TStackTrace; aStat_ID : byte = 0);
var
  Index: Integer;
  Exit : boolean;
begin
  LogMsg(lmDebug, aUnitName, '-------------' + UpperCase(aFunctionName) + ' BEGIN STACK TRACE----------------', aStat_ID, false);
  Exit := false;
  Index := 0;

  while (Exit = false) and (Index < Length(StackTrace)) do
  begin
    try
      if (aStackTrace[Index].Addr = nil) then
        Exit := true
      else
        LogMsg(lmDebug, aUnitName, Format('%p',[aStackTrace[Index].Addr]) + ' ' +
                                                IntToStr(aStackTrace[Index].relLine) + ' ' +
                                                aStackTrace[Index].ModuleName + ' ' +
                                                aStackTrace[Index].UnitName + ' ' +
                                                aStackTrace[Index].FunctionName, aStat_ID, false);
    except
      Exit := true;
    end;

    inc(Index);
  end;

  LogMsg(lmDebug, aUnitName, '-------------' + UpperCase(aFunctionName) + 'END STACK TRACE----------------', aStat_ID, false);
end;

//------------------------------------------------------------------------------
procedure GetAndLogStackTrace(aUnitName, aFunctionName: string; aStat_ID : byte = 0);
var
  StackTrace : TStackTrace;
begin
  StackTrace := GetStackTrace();
  LogStackTrace(aUnitName, aFunctionName, StackTrace, aStat_ID);
end;

end.
