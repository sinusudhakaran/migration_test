unit ErrorLog;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{   Author:   Matthew Hopkins
    Date:     Nov 97


    Purpose:
    Provides a centralised error/system log object.
    Allows min and max sizes to be set on the log file.
    Default log file name is taken from the exe name and exe path.
    If the object is unable to get a lock on the file it will store the current
    message and write that message out when it gets the next message.

    Nov 98 Extended to override an existing lock file if it has been locked
           for more than 15 seconds.  This assumes that there has been a problem and
           a lock file exists that shouldnt.

           A conditional compile directive has been added for displaying status
           in BK5.

    INITIALISATION:
    ---------------
    ErrorLog.Pas must be declared in the project source uses statment before
    any of the units that call it.  This is so that the global syslog object
    is initialised.

    USE IN UNITS:
    -------------

    **Units that use ErrorLog should have the following lines in their initialisation

    initialization

    if Assigned(SysLog) then
       DebugMe := SysLog.IsInDebugList('<unit name>');

    ** Calls to log a debug message should be of the format:

    if DebugMe then SysLog.SysLogMessage(slDebug,'<unit name>', <message>);

    NOTE: DebugMe should be a local variable in the unit
    var
       DebugMe : boolean = false;}

//------------------------------------------------------------------------------
// May 99 - Removed Code for Compression, Storing if can't write, and Status Update
//
// Nov 01 - Reintroduced modified compression code
//
// Feb 02 - Uses the LockUtils code for locking, removed some unused code.
//------------------------------------------------------------------------------
interface

uses
  classes,
  dialogs,
  fcopy,
  forms,
  sysutils,
  windows;

const
  stat_None = 0;
  stat_Min = 1;

  stat_Login = 1;
  stat_Logout = 2;
  stat_ResetStatsFile = 3;
  stat_UnhandledError = 4;
  stat_LockError = 5;

  stat_Max = 5;

const
  secGeneral = 'General';

type
  TSysLogType = (slError, slDebug, slMsg);

  TSystemLog = class
  private
    FLogMin : integer;
    FLogMax : integer;            //size in bytes
    FLogPath : string;

    FLogName : string;
    FListName : string;
    FStatsName : string;

    FLogFileName : string;
    FListFileName : string;
    FStatsFilename : string;

    FDebugList : TStringList;

    Active        : boolean;

    FComputerName : string;
    FUserName     : string;

    FLock: TRTLCriticalSection;

    procedure SetName ( LogName : string);
    procedure SetPath ( LogPath : string);
    procedure SetMin  ( min : integer);
    procedure SetMax  ( max : integer);

    procedure UpdateStats( Statistic_ID : byte; aMsg : string);
  protected
    procedure LoadDebugList;
    procedure LockSystemLog;
    procedure UnlockSystemLog;
  public
    constructor Create; virtual;
    destructor  Destroy; override;

    function  IsInDebugList( unitName : string) : boolean;
    procedure SysLogStart;
    procedure SysLogNew;
    procedure SysLogStop;
    procedure Archive( const OldLogsDir : string; const FilenamePrefix : string);
    function  ArchiveNeeded : boolean;
    function  GetStatistics : string;

    procedure SaveCopyTo( const NewFilename : string);

    property LogPath : string read FLogPath write SetPath;
    property LogFilename : string read FLogName write SetName;
    property MinSize : integer read FLogMin write SetMin;
    property MaxSize : integer read FLogMax write SetMax;
    property ComputerName : string read FComputerName;
    property UserName     : string read FUserName;
    property StatsFilename : string read FStatsFilename;

    procedure SysLogMessage( msgType : TSysLogType; unitName : string; Msg : string; Statistic_ID : byte = 0);
    procedure SysLogMessageNoLock( msgType : TSysLogType; unitName : string; Msg : string; Statistic_ID : byte = 0);

    procedure SyslogTextBlock(Name: string; Block:AnsiString);
  end;

var
  SysLog : TSystemLog;   //global object

//------------------------------------------------------------------------------
implementation

uses
  WinUtils,
  LockUtils,
  strutils,
  IniFiles;
//DONT USE ANY OTHER BANKLINK UNITS AS THEY WILL CAUSE OTHER UNITS TO INITIALIZE BEFORE THIS ONE

const
  LOG_EXTN        = 'LOG';
  DEBUG_LIST_EXTN = 'LST';
  STATS_EXTN      = 'sta';
  TEMPLOGNAME     = 'TEMPLOG.TXT';

//------------------------------------------------------------------------------
function StripReturnCharsFromString( const Source : string; ReplaceWith : string) : string;
//remove #13 and #10 chars from source string, replace with|
var
  p : integer;
  WorkingText : string;
begin
  WorkingText := Source;

  if ReplaceWith = '' then
    ReplaceWith := ' ';

  //remove #13#10 first
  p := Pos( #13 + #10, WorkingText);
  while ( p > 0) do begin
     WorkingText := Copy( WorkingText, 1, p - 1) + ReplaceWith +
                    Copy( WorkingText, p + 2, length( WorkingText));
     p := Pos( #13 + #10, WorkingText);
  end;
  //remove #13's
  p := Pos( #13, WorkingText);
  while ( p > 0) do begin
     WorkingText := Copy( WorkingText, 1, p - 1) + ReplaceWith +
                    Copy( WorkingText, p + 1 , length( WorkingText));
     p := Pos( #13, WorkingText);
  end;
  //now remove #10
  p := Pos( #10, WorkingText);
  while ( p > 0) do begin
     WorkingText := Copy( WorkingText, 1, p - 1) +
                    Copy( WorkingText, p + 1, length( WorkingText));
     p := Pos( #10, WorkingText);
  end;
  result := WorkingText;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SetName ( LogName : string);
var
  extn : string;
begin
  extn := ExtractFileExt(LogName);
  if extn = '' then
  begin
    FLogName := LogName + '.'+ LOG_EXTN;
    FListName := LogName + '.' + DEBUG_LIST_EXTN;
    FStatsName := LogName + '.' + STATS_EXTN;
  end
  else
  begin  {strip extn if has one}
    FLogName := copy(LogName,0,pos(extn,LogName)) + LOG_EXTN;
    FListName := copy(LogName,0,pos(extn,LogName)) + DEBUG_LIST_EXTN;
    FStatsName := copy(LogName,0,pos(extn,LogName)) + STATS_EXTN;
  end;

  {set extended name}
  fLogFileName  := fLogPath+fLogName;   {store here so faster later}
  fListFileName := fLogPath+fListName;
  FStatsFilename := FLogPath + FStatsName;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SetPath ( LogPath : string);
begin
  FLogPath := LogPath;

  {set extended name}
  fLogFileName := fLogPath+fLogName;   {store here so faster later}
  fListFileName := fLogPath+fListName;
  FStatsFilename := FLogPath + FStatsName;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SetMin  ( min : integer);
{min must be +ve, if greater than max then set max = 0, this disables Archive
 until a suitable value is set for max}
begin
  if min < 0 then min := 0;
  if (FLogMax > 0) and (min >= FLogMax) then
    FLogMax := 0;

  FLogMin := min;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SetMax  ( max : integer);
{max must be +ve and greater than min}
begin
  if (max < 0) or (max <= FLogMin) then
    max := 0;

  FLogMax := max;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.LoadDebugList;
begin
  FDebugList.Clear;
  if BKFileExists(fListFileName) then
    FDebugList.LoadFromFile(fListFileName);
end;

//------------------------------------------------------------------------------
function TSystemLog.IsInDebugList( unitName : string) : boolean;
begin
  if FDebugList.Count = 0 then
  begin
    result := false;
    exit;
  end;
  if FDebugList.Strings[0]  = 'ALL' then
  begin
    //true for all, except is they appear in subsequent lines
    Result := (FDebugList.IndexOf(upperCase(UnitName)) = -1);
    exit;
  end;
  Result := (FDebugList.IndexOf(upperCase(UnitName))>=0);
end;

//------------------------------------------------------------------------------
function TSystemLog.ArchiveNeeded : boolean;
begin
  Result := false;
  //check that sizes are valid
  if ( FLogMax = 0) or ( FLogMax <= FLogMin) then
    exit;

  Result := GetFileSize( FLogFileName ) > FLogMax;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.Archive( const OldLogsDir : string; const FilenamePrefix : string);
var
  LogFileStream : TFileStream;
  NewStream     : TFileStream;
  OldPortionStream : TFileStream;
  OldLogFilename : string;
  i             : integer;
  fSize         : integer;
  CurrPos       : integer;
  TestBuff      : Array[0..1] of Char;
  found         : boolean;
  ArchiveOK     : boolean;
begin
  ArchiveOK := false;

  //check that sizes are valid
  if ( FLogMax = 0) or ( FLogMin >= FLogMax) then
    exit;

  if (not DirectoryExists(OldLogsDir)) and
     (not CreateDir(OldLogsDir)) then
  begin
    SysLogMessage( slError, 'ErrorLog', 'Unable to Create Directory '+ OldLogsDir +
                                           ' Log not archived');
    Exit;
  end;

  //log existing file and begin
  LockSystemLog;

  try
    LogFileStream := TFileStream.Create( FLogFileName, fmShareExclusive);
    try
      fSize := LogFileStream.Size;

      if fSize > FLogMax then
      begin
        //see if should trim file or copy whole file to archive
        if FLogMin > 0 then
        begin
          //File is too big so pick off bytes at beginning find the
          //previous last ODOA before the min pos
          LogFileStream.Seek( -FLogMin, soFromEnd);

          CurrPos := LogFileStream.Position - 2;    //2 bytes ODOA
          Found := false;

          //count back from min position to find previous ODOA
          while (CurrPos > 0) and (not Found) do
          begin
            LogFileStream.ReadBuffer(TestBuff,2);
            if (TestBuff[0] = #13) and (TestBuff[1] = #10) then
              found := true
            else
            begin
              CurrPos := CurrPos - 1;
              LogFileStream.Seek(CurrPos,soFromBeginning);
            end;
          end;        { while }

          if not Found then
          begin
            //reach beginning of file so copy would copy whole file,
            //no need to do that
            Exit;
          end
          else
            CurrPos := CurrPos + 2;

          //currpos should now be at the beginning of that last line
          //before the min size position
          LogFileStream.Seek(currPos,soFromBeginning);
          NewStream := TFileStream.Create(TEMPLOGNAME,fmCreate);
          try
             NewStream.CopyFrom(LogFileStream,fSize-CurrPos);
          finally
             NewStream.Free;
          end;
        end
        else
        begin
          //whole file should be archived, create 0 length new log file
          CurrPos := LogFileStream.Size;
          NewStream := TFileStream.Create(TEMPLOGNAME,fmCreate);
          NewStream.Free;
        end;

        //backup the front portion of the log file
        LogFileStream.Seek( 0, soFromBeginning);
        OldLogFilename := OldLogsDir + FilenamePrefix +
                          FormatDateTime( 'yymmdd', Now) + '.LOG';
        i := 0;
        while BKFileExists( OldLogFilename) do
        begin
          Inc( i);
          OldLogFilename := OldLogsDir + FilenamePrefix +
                            FormatDateTime( 'yymmdd', Now) + inttostr( i) + '.LOG';
        end;

        OldPortionStream := TFileStream.Create( OldLogfilename, fmCreate);
        try
          OldPortionStream.CopyFrom( LogFileStream, CurrPos);
        finally
          OldPortionStream.Free;
        end;

        ArchiveOK := true;
      end;
    finally
      LogFileStream.Free;
      if ArchiveOK then
      begin
        {kill original log file and rename new one}
        DeleteFile(pchar(LogFileName));
        RenameFile(TEMPLOGNAME,LogFileName);
      end;
    end;
  finally
    UnlockSystemLog;
    if ArchiveOK then
    begin
      SysLogMessage( slMsg, 'ErrorLog', 'Archive Log Completed  Archived to ' + OldLogFilename)
    end
    else
    begin
      //clean up temp files
      DeleteFile( pChar( OldLogFilename));
      DeleteFile( pChar( TempLogName));
    end;
  end;  {finally}
end;

//------------------------------------------------------------------------------
Procedure TSystemLog.LockSystemLog;
Begin
  FileLocking.ObtainLock( ltSystemLog, 180 );
end;

//------------------------------------------------------------------------------
procedure TSystemLog.UnlockSystemLog;
begin
  FileLocking.ReleaseLock( ltSystemLog );
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SysLogMessage( msgType : TSysLogType; unitName : string; Msg : string; Statistic_ID : byte = 0);
//write the message to the log file
//note: lockSystemLog still returns true even if lock exists after 5 seconds.
var
  f : TextFile;
  ExtMsg : string;
  aMsg   : string;

  //------------------------------------------------------------------------------
  procedure LogWriteLn(aMsg: string);
  const
    MAX_LINE_LEN = 200;
  var
    LenStr : integer;
    Chunks : integer;
    Index : integer;
    LeftOver : integer;
    writeStr : string;
  begin
    LenStr := Length(aMsg);
    Chunks := trunc(LenStr/MAX_LINE_LEN);
    for Index := 0 to Chunks-1 do
    begin
      writeStr := midstr(aMsg, 1 + (Index*MAX_LINE_LEN), MAX_LINE_LEN);
      Writeln(f, writeStr);
    end;

    LeftOver := (LenStr - (Chunks*MAX_LINE_LEN))-1;
    if LeftOver > 0 then
    begin
      writeStr := midstr(aMsg, LenStr-LeftOver, LeftOver);
      Writeln(f, writeStr);
    end;
  end;
begin
  if not Active then exit;

  ExtMsg := FormatDateTime('dd/mm/yy hh:mm:ss.zzz', Now) + ',';
  case msgType of
    slError: ExtMsg := ExtMsg  +'ERROR,';
    slDebug: ExtMsg := ExtMsg  +'DEBUG,';
    slMsg:   ExtMsg := ExtMsg  +'INFO,';
  end;        { case }

  Msg := StripReturnCharsFromString(Msg, ' ');
  ExtMsg := ExtMsg + FComputerName + ',' + FUserName + ',' + UnitName + ',"' + Msg + '"';

  LockSystemLog;
  try
    try
      AssignFile(F, FLogFileName);
      if not BKFileExists(FLogFileName) then
        Rewrite(f)
      else
        Append(F);

      try
        LogWriteLn(ExtMsg);
      finally
        CloseFile( F );     { Close file, save changes }
      end;
    except
      //let system know that this was a log file exception, at least the user
      //should get to see this
      on e : exception do
      begin
        aMsg := E.message + ' [' + E.ClassName + '] ' +
                 'occurred during SysLogMessage. Message was ' + Msg;
        raise Exception.Create( aMsg);
      end;
    end;

    //update stats file
    try
      if Statistic_ID in [ stat_Min..stat_Max] then
        UpdateStats( Statistic_ID, Msg);
    except
      ; //ignore error
    end;
  finally
    UnlockSystemLog;
  end;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SysLogMessageNoLock(msgType: TSysLogType; unitName, Msg: string; Statistic_ID: byte);
var
  f : TextFile;
  ExtMsg : string;
  aMsg   : string;

  //------------------------------------------------------------------------------
  procedure LogWriteLn(aMsg: string);
  const
    MAX_LINE_LEN = 200;
  var
    LenStr : integer;
    Chunks : integer;
    Index : integer;
    LeftOver : integer;
    writeStr : string;
  begin
    LenStr := Length(aMsg);
    Chunks := trunc(LenStr/MAX_LINE_LEN);
    for Index := 0 to Chunks-1 do
    begin
      writeStr := midstr(aMsg, 1 + (Index*MAX_LINE_LEN), MAX_LINE_LEN);
      Writeln(f, writeStr);
    end;

    LeftOver := (LenStr - (Chunks*MAX_LINE_LEN))-1;
    if LeftOver > 0 then
    begin
      writeStr := midstr(aMsg, LenStr-LeftOver, LeftOver);
      Writeln(f, writeStr);
    end;
  end;

begin
  if not Active then
    exit;

  EnterCriticalSection(FLock);

  try
    ExtMsg := FormatDateTime('dd/mm/yy hh:mm:ss.zzz', Now) + ',';
    case msgType of
      slError: ExtMsg := ExtMsg  +'ERROR,';
      slDebug: ExtMsg := ExtMsg  +'DEBUG,';
      slMsg:   ExtMsg := ExtMsg  +'INFO,';
    end;        { case }

    Msg := StripReturnCharsFromString(Msg, ' ');
    ExtMsg := ExtMsg + FComputerName + ',' + FUserName + ',' + UnitName + ',"' + Msg + '"';

    try
      AssignFile(F, FLogFileName);
      if not BKFileExists(FLogFileName) then
        Rewrite(f)
      else
        Append(F);

      try
        LogWriteLn(ExtMsg);
      finally
        CloseFile( F );     { Close file, save changes }
      end;
    except
      //let system know that this was a log file exception, at least the user
      //should get to see this
      on e : exception do
      begin
        aMsg := E.message + ' [' + E.ClassName + '] ' +
                'occurred during SysLogMessage. Message was ' + Msg;
        raise Exception.Create( aMsg);
      end;
    end;

    //update stats file
    try
      if Statistic_ID in [ stat_Min..stat_Max] then
        UpdateStats( Statistic_ID, Msg);
    except
      ; //ignore error
    end;
  finally
    LeaveCriticalSection(FLock);
  end;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SysLogNew;
begin
  LockSystemLog;
  try
    DeleteFile(PChar(FLogFileName));
  finally
    UnlockSystemLog;
  end;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SysLogStart;
begin
  Active := true;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SysLogStop;
begin
  Active := false;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SyslogTextBlock(Name: string; Block: AnsiString);
var
  f : TextFile;
  aMsg   : string;
begin
  LockSystemLog;
  try
    try
      AssignFile(F, FLogFileName);
      if not BKFileExists(FLogFileName) then
        Rewrite(f)
      else
        Append(F);

      try
        WriteLn(F,'***********************************************************');
        WriteLn(F,Name);
        WriteLn(F,'***********************************************************');
        WriteLn(F,Block);
        WriteLn(F,'***********************************************************');
      finally
        CloseFile( F );     { Close file, save changes }
      end;
    except
      //let system know that this was a log file exception, at least the user
      //should get to see this
      on e : exception do begin
        aMsg := E.message + ' [' + E.ClassName + '] ' +
                            'occurred during SysLogMessage.';
        raise Exception.Create( aMsg);
      end;
    end;

  finally
    UnlockSystemLog;
  end;
end;

//------------------------------------------------------------------------------
constructor TSystemLog.Create;
var
  ExeName : string;
  Extn    : string;
  ComputerName : string;
begin
  inherited Create;

  InitializeCriticalSection(FLock);
  ExeName         := ExtractFileName(Application.ExeName);
  Extn            := ExtractFileExt (Application.ExeName);
  flogPath        := ExtractFilePath(Application.ExeName);
  fLogMin         := 0;
  fLogMax         := 0;

  ComputerName := ReadComputerName(false);

  fLogName        := copy(exeName,0,pos(extn,exeName)) + LOG_EXTN;

  // adds computer name to log file.
  //fLogName        := copy(exeName,0,pos(extn,exeName)-1) + '-' + ComputerName + '.' + LOG_EXTN;

  fListName       := copy(exeName,0,pos(extn,exeName)) + DEBUG_LIST_EXTN;
  FStatsName      := copy(exeName,0,pos(extn,exeName)) + STATS_EXTN;
  fLogFileName    := fLogPath+fLogName;   {store here so faster later}
  fListFileName   := fLogPath+fListName;
  FStatsFilename  := FLogPath + FStatsName;
  FComputerName   := ReadComputerName;
  FUserName       := ReadUserName;
  FDebugList      := TStringList.Create;
  Active          := false;
  LoadDebugList;
end;

//------------------------------------------------------------------------------
destructor TSystemLog.Destroy;
begin
  FDebugList.Free;

  DeleteCriticalSection(FLock);

  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.SaveCopyTo(const NewFilename: string);
begin
  LockSystemLog;
  try
    FCopy.CopyFile( FLogFilename, NewFilename );
  finally
    UnlockSystemLog;
  end;
end;

//------------------------------------------------------------------------------
procedure TSystemLog.UpdateStats( Statistic_ID : byte; aMsg : string);
var
  StatsFile : TMemIniFile;
  LoginCount : integer;
  LogoutCount : integer;
  LockErrorCount : integer;
  UnHandledErrorCount : integer;

  CreationDate : string;
begin
  //update the stats file so that we can quickly get stats without reading the
  //whole log file
  if Statistic_ID = stat_ResetStatsFile then
  begin
    SysUtils.DeleteFile( FStatsFilename);
    Exit;
  end;

  StatsFile := TMemIniFile.Create( FStatsFilename);
  try
    CreationDate := StatsFile.ReadString( secGeneral, 'Created', '');
    if CreationDate = '' then
      StatsFile.WriteString( secGeneral, 'Created', FormatDateTime('dd/mm/yy', Now));

    case Statistic_ID of
      stat_Login : begin
        LoginCount := StatsFile.ReadInteger( secGeneral, 'Logins', 0);
        Inc( LogInCount);
        StatsFile.WriteInteger( secGeneral, 'Logins', LoginCount);
      end;

      stat_Logout : begin
        LogoutCount := StatsFile.ReadInteger( secGeneral, 'Logouts', 0);
        Inc( LogoutCount);
        StatsFile.WriteInteger( secGeneral, 'Logouts', LogoutCount);
      end;

      stat_UnHandledError : begin
        UnHandledErrorCount := StatsFile.ReadInteger( secGeneral, 'UnHandledErrors', 0);
        Inc( UnHandledErrorCount);
        StatsFile.WriteInteger( secGeneral, 'UnHandledErrors', UnHandledErrorCount);

        //identify specific errors
        if Pos('LockFile',aMsg) > 0 then
        begin
          LockErrorCount := StatsFile.ReadInteger( secGeneral, 'LockErrors', 0);
          Inc( LockErrorCount);
          StatsFile.WriteInteger( secGeneral, 'LockErrors', LockErrorCount);
        end;
      end;
    end;
  finally
    StatsFile.UpdateFile;
    StatsFile.Free;
  end;
end;

//------------------------------------------------------------------------------
function TSystemLog.GetStatistics: string;
var
  StatsFile : TMemIniFile;
  SectionData : TStringList;
begin
  LockSystemLog;
  try
    StatsFile := TMemIniFile.Create( FStatsFilename);
    SectionData := TStringList.Create;
    try
      StatsFile.ReadSectionValues( secGeneral, SectionData);
      result := SectionData.Text;
    finally
      SectionData.Free;
      StatsFile.Free;
    end;
  finally
    UnlockSystemLog;
  end;
end;

//------------------------------------------------------------------------------
initialization
  SysLog := TSystemLog.Create;
  SysLog.SysLogStart;   //start log so that other units can log events during initialization

//------------------------------------------------------------------------------
finalization
  SysLog.Free;

end.
