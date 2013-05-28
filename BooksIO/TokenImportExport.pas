unit TokenImportExport;

interface
uses
  fastMM4,
  LogUtil,
  TokenProcTypes,
  sysutils;

// set the Callbacks
procedure SetOutputFileProc (value: OutputFileProc);export; stdcall;
procedure SetStatusProc (value: OutputStatusProc);export; stdcall;

// Actual Import Export
procedure ImportBooksFile(dataType: integer; aByteArray: PByteArray; size: integer)export; stdcall;
procedure ExportBooksFile(dataType: integer; aByteArray: PByteArray; size: integer)export; stdcall;


implementation
uses
windows,
  LockUtils,
  SHFolder,
  ErrorLog,
  CLObj32,
  CRCFileUtils,
  IOStream,
  logger;

const
  TokenStream = $00000000;
  BK5Stream = $00000001;


var
  FileOutputProc: OutputFileProc;
  DebugMe: Boolean = false;
  LogHere: Boolean = false;
  StatusProc: OutputStatusProc;

// Export versions
procedure SetOutputFileProc (Value: OutputFileProc);export; stdcall;
begin
   FileOutputProc := Value;
end;

procedure SetStatusProc (Value: OutputStatusProc);export; stdcall;
begin
   StatusProc := Value;
end;

// Local version we call
procedure DoStatus(Status: LogMsgType; StatusText: pChar);
begin
  if Assigned(StatusProc) then
      StatusProc(Integer(Status), StatusText);
end;

procedure DoOutput(DataType: integer; aByteArray: PByteArray; size: integer);
begin
   if assigned (FileOutputProc) then
       FileOutputProc(DataType, aByteArray, size);
end;


// Implementation for the logger
procedure MyLogMsg(msgType: logMsgType; logMsg: string);
begin

   //glMsg := logMsg + #0;
   case msgType of
     Info, Trace, Warning: begin
              DoStatus(msgType,pChar(logMsg));
              if LogHere then
                  LogUtil.LogMsg(lmInfo,'BooksTokenIO',logMsg );
           end;
     Debug: begin
               if DebugMe then
                  DoStatus(msgType,pChar(logMsg));
               if LogHere then
                  LogUtil.LogMsg(lmDebug,'BooksTokenIO',logMsg );
           end;
     Error: begin
               DoStatus(msgType,pChar(logMsg));
               if LogHere then
                  LogUtil.LogMsg(lmError,'BooksTokenIO',logMsg );
           end;
   end;
end;


// The incomming is the actual byte stream of the (disk) file
procedure ImportBooksFile(dataType: integer; aByteArray: PByteArray; size: integer)export; stdcall;
var
    clStream: TIOStream;
    Client: TClientObj;
    outArray : PByteArray;
begin
    clStream := TIOStream.Create;
    clstream.WriteBuffer(aByteArray^, size);
    clstream.Position := 0;
    try
        Client := TClientObj.Create;
        try
           // Read the file
           LogDebug('Import: read client file start');
           Client.SimpleRead('', ClStream);
        except
           on E: exception do begin
              LogException(E,'Import: reading client file');
              Exit;
           end;
        end;
        if not Assigned(Client) then begin
           LogError('Import: client is nil');
        end else begin
           clStream.Clear;
           // Now make the token stream
           try
              Client.SaveToDataStream(clStream);
              clStream.Position := 0;
           except
             on E: exception do begin
                LogException(E,'Import: writing client token stream');
                Exit;
             end;
           end;
           // Output the Token stream, as byte array
           getMem(outArray, clStream.Size);
           try try
              clStream.Read(outArray^, clStream.Size);
              doOutput(TokenStream,outArray,clStream.Size);
           except
              on E: exception do
                LogException(E,'Import: output token stream');
           end;
           finally
             freemem(outArray,clStream.Size);
           end;
        end;
     finally
        FreeAndNil(Client);
        FreeAndNil(clstream);
     end;
end;


// The incoming is a Token stream
procedure ExportBooksFile(dataType: integer; aByteArray: PByteArray; size: integer)export; stdcall;
var
    clStream: TIOStream;
    bigStream: TBigMemoryStream;
    Client: TClientObj;
    outArray : PByteArray;
begin
    bigStream := nil;
    clStream := TIOStream.Create;
    clstream.WriteBuffer(aByteArray^, size);
    clstream.Position := 0;

    LogDebug('Export: read token stream done');
    try
       Client := TClientObj.Create;
       try
          try
              Client.ReadFromDataStream(clStream);
          except
              on e: exception do begin
                 LogException(e, 'Read client from token stream');
                 Exit;
              end;
          end;
       finally
         FreeAndNil(clStream);
       end;

       LogDebug('Export: read client from token stream done');
       try
          bigStream := Client.SaveClientToStream;
       except
          on e: exception do  begin
              LogException(e, 'Export: save Client to file stream');
              exit;
          end;
       end;

       // Output the stream
       bigStream.Position := 0;
       getMem(outArray, bigStream.Size);
       try try
          bigStream.Read(outArray^, bigStream.Size);
          DoOutput(BK5Stream,outArray,bigStream.Size);
       except
           on E: exception do
                LogException(E,'Export: output file stream');
       end;
       finally
          freemem(outArray,bigStream.Size);
       end;
    finally
       FreeAndNil(bigStream);
       FreeAndNil(Client);
       FreeAndNil(clstream);
    end;
end;


procedure setPaths;
// Set Paths to a safe location
var
   AppData: PChar;
   path: String;
begin
  GetMem(AppData, MAX_PATH+1);
  if (AppData <> nil) then try

      SHGetFolderPath(0,CSIDL_APPDATA,0 , 0,AppData);
      path := string(AppData);
      SetLockingFileLocation(path);
      SysLog.LogPath := Path;
      SysLog.LogFilename := '\BooksTokenIO.log';
  finally
     FreeMem(AppData);
  end;
end;

initialization
   FileOutputProc := nil;
   StatusProc := nil;
   setPaths;
   logger.logMessageProcedure := MyLogMsg;

end.
