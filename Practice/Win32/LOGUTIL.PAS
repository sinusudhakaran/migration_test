unit LogUtil;
//------------------------------------------------------------------------------
{
   Title:          System Log Engine Wrapper

   Description:

   Author:

   Remarks:        written to provide compatibility  with TVision unit.
                   just wraps the syslog object into a unit

   Revisions:      LOOKUPDLL conditional define added so can compile
                   bkLookup.dll and not hook in all loging code

}
//------------------------------------------------------------------------------

{$IFDEF LOOKUPDLL}
  {$DEFINE NOLOGGING}
{$ENDIF}

{$IFDEF NOLOGGING}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
interface

type
  TMessageType = (lmError,lmDebug,lmInfo);

procedure LogMsg( MsgType : TMessageType; UnitName, msg : string; Stat_ID : byte = 0; LockLog: Boolean = True);
function  DebugUnit( unitname:string) :boolean;


//******************************************************************************
implementation

procedure LogMsg( MsgType : TMessageType; UnitName, msg : string; Stat_ID : byte = 0; LockLog: Boolean = True);
begin
  //
end;
function  DebugUnit( unitname:string) :boolean;
begin
  result := false;
end;

{$ELSE}
//----------------------------------------------------------------------------
//
//       MAIN CODE GOES HERE...
//
//----------------------------------------------------------------------------

interface
   
type
  TMessageType = (lmError,lmDebug,lmInfo);

procedure LogMsg( MsgType : TMessageType; UnitName, msg : string; Stat_ID : byte = 0; LockLog: Boolean = True);
procedure LogError (Unitname, msg: string);
function  DebugUnit( unitname:string) :boolean;
function  TokenToStr( b : byte):string;
function  LogFileName : string;

implementation
{----------------------------------}
uses
   ErrorLog, SysUtils, bkProduct;
{----------------------------------}
procedure LogMsg( MsgType : TMessageType; UnitName, msg : string; Stat_ID : byte = 0; LockLog: Boolean = True);
var
   SysLogType : TSysLogType;
begin
   case MsgType of
      lmError : sysLogType :=  slError;
      lmDebug : sysLogType :=  slDebug;
      lmInfo  : sysLogType :=  slMsg;
   else
      sysLogType := slMsg;
   end;

   if Assigned(SysLog) then
   begin
     if LockLog then
     begin
       SysLog.SysLogMessage(sysLogType,unitName, msg, Stat_ID);
     end
     else
     begin
       SysLog.SysLogMessageNoLock(sysLogType,unitName, msg, Stat_ID);
     end;
   end;
end;

{----------------------------------}
procedure LogError (Unitname, msg: string);
begin
   if Assigned(SysLog) then
      SysLog.SysLogMessage(slError,UnitName,msg);
end;

{----------------------------------}
function DebugUnit( unitname:string) :boolean;
begin
   if Assigned(SysLog) then
      result := sysLog.IsInDebugList(unitname)
   else
      result := false;
end;

{----------------------------------}
function TokenToStr( b : byte):string;
var
  S : string[10];
begin
  Str(B,S);
  result := S;
end;
{----------------------------------}
function  LogFileName : string;
begin
   if Assigned( SysLog) then
      result := SysLog.LogFilename
   else
      result := 'unknown.log';
end;
{----------------------------------}

{$ENDIF}
end.
