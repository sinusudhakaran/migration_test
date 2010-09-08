unit SysLog;
//------------------------------------------------------------------------------
{
   Title:       System Log

   Description: System Log unit

   Remarks:     Uses the getTicks style locking because we have had less
                problems with it compared to the locking used for admin
                system (windows file locking).  This software should be
                a single user app so I think this method is sufficent.

   Author:      Matthew Hopkins Jul 01

}
//------------------------------------------------------------------------------

interface

type
  TECMessageType = ( lmException, lmError, lmDebug, lmInfo );

type
   TSystemLogger = class
      constructor Create( const LogFilename : string); virtual;
      destructor  Destroy; override;
   private
      FLogfilename   : string;
      FLockfilename  : string;
      FComputerName  : string;
      FUsername      : string;
   protected
      function  LockSystemLog : boolean;
      procedure UnlockSystemLog;
   public
      procedure LogMsg( const MsgType : TEcMessageType; const sMsg : string);
      procedure LogError( const ErrorMsg : string);
      procedure LogInfo( const InfoMsg : string);

      procedure LogInfoFromObject( const Sender : TObject; const sLogMsg : String); //see ecGlobalTypes
   end;

var
   ApplicationLog : TSystemLogger;  //global variable

//******************************************************************************
implementation
uses
   Windows,
   Forms,
   WinUtils,   //used to get computer and user names
   SysUtils;

const
   LOCK_EXTN   = '.$$$';

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
{ TSystemLogger }
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
constructor TSystemLogger.Create(const LogFilename: string);
begin
   inherited Create;

   FLogfilename            := Logfilename;
   FLockfilename           := FLogfilename + LOCK_EXTN;
   FComputername           := WinUtils.ReadComputerName;
   FUsername               := WinUtils.ReadUserName;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
destructor TSystemLogger.Destroy;
begin
   inherited;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function TSystemLogger.LockSystemLog: boolean;
const
   MAXTICKDIFF = 5000;  //5 sec
var
   F  : File;
   StartTick : DWORD;
   TimeElapsed : integer;
begin
   if fileExists(fLockFileName) then begin
      StartTick := GetTickCount;
      Repeat
         Application.ProcessMessages;
         TimeElapsed := GetTicksSince(StartTick);
      Until ( not FileExists( fLockFileName ) ) OR (TimeElapsed>MaxTickDiff);
   end;

   If not FileExists(fLockFileName ) then Begin
      AssignFile( F, fLockFileName );
      Rewrite( F );
      CloseFile( F );
      Result := true;
   end
   else begin
      //have waited long enough. assume lock is erroneous return true
      Result := true;
   end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemLogger.LogError(const ErrorMsg: string);
begin
   LogMsg( lmError, ErrorMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemLogger.LogInfo(const InfoMsg: string);
begin
   LogMsg( lmInfo, InfoMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemLogger.LogInfoFromObject( const Sender : TObject; const sLogMsg : String);
begin
   LogMsg( lmInfo, Sender.ClassName + ': ' + sLogMsg);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemLogger.LogMsg(const MsgType: TEcMessageType;
  const sMsg: string);
var
   f : TextFile;
   ExtMsg : string;
begin
    ExtMsg := DateToStr(Now)+' '+TimeToStr(Now)+',';
    case msgType of
       lmException  : ExtMsg := ExtMsg + 'EXCEPT';
       lmError      : ExtMsg := ExtMsg + 'ERROR,';
       lmDebug      : ExtMsg := ExtMsg + 'DEBUG,';
       lmInfo       : ExtMsg := ExtMsg + 'INFO,';
    end;        { case }
    ExtMsg := ExtMsg + FComputerName + ',' + FUserName + ',"' + sMsg + '"';
    //lock system log
    if LockSystemLog then begin
       try
          AssignFile(F, FLogFileName);
          try
             if not FileExists(FLogFileName) then
                Rewrite(f)
             else
                Append(F);
             //write message
             Writeln(F,ExtMsg);
          finally
	    CloseFile(F);     { Close file, save changes }
	 end;
       finally
            UnlockSystemLog;
       end;
    end;
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
procedure TSystemLogger.UnlockSystemLog;
begin
   DeleteFile( FLockfilename);
end;
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
initialization
   ApplicationLog := TSystemLogger.Create( ChangeFileExt( Application.ExeName, '.LOG'));

finalization
   ApplicationLog.Free;
   ApplicationLog := nil;
end.
