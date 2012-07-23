unit logger;

{
   Poor mans attempt to seperate the implementaion from its usage
   I.e. this unit only allows you to use logging, it does not do anything iself
   You have to implement a logMessageProcedure

}


interface
uses sysutils;

type

  LogMsgType =
     (

      Trace = 0,
      Debug = 1,
      Info = 2,
      Audit = 3,
      Warning = 4,
      Error = 5

     );

  LogProc = procedure (msgType: LogMsgType; logMsg: string);
  LogObjectProc = procedure (msgType: LogMsgType; logMsg: string) of object;

  procedure logMessage(msgType: LogMsgType; logMsg: string);

  procedure LogTrace(logMsg: string);
  procedure LogInfo(logMsg: string);
  procedure LogWarning(logMsg: string);
  procedure LogAudit(logMsg: string);
  procedure LogDebug(logMsg: string);
  procedure LogError(logMsg: string);
  procedure LogException(e: Exception; Action: string);

  // Either one needs to be set by application
  var logMessageProcedure: logProc;
  var  logObjectMessageProcedure: LogObjectProc;

implementation

   // Main 'port of call'
   procedure logMessage(msgType: LogMsgType; logMsg: string);
   begin
       if Assigned(logMessageProcedure) then try
          logMessageProcedure(msgType, logMsg);
       except

       end;

       if Assigned(logObjectMessageProcedure) then try
          logObjectMessageProcedure(msgType, logMsg);
       except

       end;
   end;

   procedure LogInfo(logMsg: string);
   begin
       logMessage(Info, logMsg);
   end;

   procedure LogError(logMsg: string);
   begin
       logMessage(Error, logMsg);
   end;

   procedure LogTrace(logMsg: string);
   begin
       logMessage(Trace, logMsg);
   end;

   procedure LogWarning(logMsg: string);
   begin
       logMessage(Warning, logMsg);
   end;

   procedure LogAudit(logMsg: string);
   begin
       logMessage(Audit, logMsg);
   end;

   procedure LogException(e: Exception; action: string);
   begin
       logError(format('%s'#10#13' While: %s',[e.Message, action]));
   end;

   procedure LogDebug(logMsg: string);
   begin
       logMessage(Debug, logMsg);
   end;

initialization
   logMessageProcedure := nil;
   logObjectMessageProcedure := nil;
end.
