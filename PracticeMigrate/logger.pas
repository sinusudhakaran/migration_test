unit logger;



interface
uses
   Types,
   classes;


// Trivial attempt to disconnect the implementation from the Definition..
type
  TLogMsgType = (Audit, Info, Warning);
  TlogMessageProc = procedure (const msgType: TLogMsgType;  const logMsg: string) of object;

procedure LogMessage(const msgType: TLogMsgType;  const logMsg: string);

var logMessageProc: TlogMessageProc;


// Helper for some Common log data...
type
 TLogData = class (TObject)
  private
    fProcsessName: string;
    fMachineName: string;
    fUserName: string;
    fProcessID: DWORD;
    FLogFileName: string;
    fTimeStamp: TDateTime;
    function GetProcsessName: string;
    function GetMachineName: string;
    function getUserName: string;
    function GetProcessID: Integer;
    procedure SetLogFileName(const Value: string);

    function GetTimeStamp: TDateTime;
  public
     property LogFileName: string read FLogFileName write SetLogFileName;
     procedure StampTime;
     property TimeStamp: TDateTime read GetTimeStamp;
     property ProcsessName : string read GetProcsessName;
     property MachineName : string read GetMachineName;
     property UserName: string read GetUserName;
     property ProcessID: Integer read GetProcessID;
     function TypeToText(value :TLogMsgType): string;

     procedure LogToFile(const msgType: TLogMsgType;  const logMsg: string);
  end;

function LogData: TLogData;

implementation

uses
 
  SysUtils,
  Forms,
  Windows,
  Winutils;


procedure LogMessage(const msgType: TLogMsgType;  const logMsg: string);
begin
   if Assigned(logMessageProc) then
      logMessageProc(msgType, logMsg);
end;

var FLogData : TLogData;

function LogData: TLogData;
begin
   if not Assigned(FLogData) then
      FLogData := TLogData.Create;
   result := FLogData;
end;

{ TLogData }


function TLogData.GetMachineName: string;
begin
   if fMachineName = '' then
      fMachineName := ReadComputerName(false);
   result := fMachineName;
end;

function TLogData.GetProcessID: Integer;

begin
   if fProcessID = 0 then
      GetWindowThreadProcessID(Application.MainFormHandle, @fProcessID);

   result := fProcessID;
end;

function TLogData.GetProcsessName: string;
begin
   if fProcsessName = '' then
      fProcsessName := ParamStr(0);
   result := fProcsessName;
end;

function TLogData.GetTimeStamp: TDateTime;
begin
    if FTimeStamp = 0 then
      StampTime;

    Result := FTimeStamp;
end;

function TLogData.GetUserName: string;
begin
   if fUserName = '' then
      fUserName := ReadUserName;
   result := fUserName;
end;



procedure TLogData.SetLogFileName(const Value: string);
begin
   FLogFileName := Value;
end;

procedure TLogData.StampTime;
begin
   fTimeStamp := Now;
end;

function TLogData.TypeToText(value: TLogMsgType): string;
begin
   case value of
     Audit :   result := 'Audit';
     Info :    result := 'Info';
     Warning : result := 'Warning';
   end;
end;

procedure TLogData.LogToFile(const msgType: TLogMsgType;  const logMsg: string);
var LogFile: text;
begin
  if LogFileName > '' then begin
      AssignFile(logFile, LogFileName);
      if BKFileExists(LogFileName) then
         system.Append(logFile)
      else
         system.Rewrite(logFile);

      try

         WriteLn(logFile, FormatDateTime('"Timestamp: "dd/mm/yyyy  hh:nn:ss am/pm',timeStamp));
         WriteLn(logFile, 'Message: Information');
         WriteLn(logFile, format('Category: %s', [TypeToText(msgType)]));
         WriteLn(logFile, format('Machine: %s', [MachineName]));
         WriteLn(logFile, 'Area - Data Migration');
         WriteLn(logFile, format('Details - %s', [logMsg]));

         WriteLn(logFile,'');
      finally
         // Close the file
         CloseFile(logFile);
      end;
   end;
end;

initialization
   FLogData := nil;
   logMessageProc := nil;
finalization
   FreeAndNil(FLogData);
end.
