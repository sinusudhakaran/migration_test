unit ImportExport;

interface

uses
  IOStream,
  sysutils,
  classes,
  ProcTypes,
  LogUtil;


procedure SetOutputFileProc (Value: OutputFile); stdcall;

procedure SetErrorProc (Value: OutputError); stdcall;



procedure ImportBooksFile(Code: PChar; Blob: pchar)stdcall;

procedure ExportBooksFile(Code: pChar; Blob: Pchar)stdcall;



// Theres are only exposed for the Debug EXE
function DecodeText(Value: PChar): TIOStream;
function EnCodetext(Value: Tstream): string;

implementation
uses
    listHelpers,
    CLObj32,

    OmniXMLUtils;



const
  XMLData = $00000000;
  BK5File = $00000001;


  ConfigError = $00000001;
  DataError   = $00000002;
  UnitName = 'ImportExport';


var
  OutputFileProc : OutputFile;

  ErrorProc: OutputError;

procedure SetOutputFileProc (Value: OutputFile);
begin
  LogMsg(lmInfo, UnitName, 'procedure SetOutputFileProc beginning');
  OutputFileProc := Value;

  LogMsg(lmInfo, UnitName, 'procedure SetOutputFileProc complete');
end;


procedure SetErrorProc (Value: OutputError);
begin
  LogMsg(lmInfo, UnitName, 'procedure SetErrorProc beginning');
  ErrorProc := Value;

  LogMsg(lmInfo, UnitName, 'procedure SetErrorProc complete');
end;


procedure DoError(Error: Integer; ErrorText: pChar);
begin
  LogMsg(lmInfo, UnitName, 'procedure DoError beginning');
  if Assigned(ErrorProc) then
      ErrorProc(Error, ErrorText);

  LogMsg(lmInfo, UnitName, 'procedure DoError complete');
end;

procedure DoException(E: Exception; Action : string);
begin
   LogMsg(lmInfo, UnitName, 'procedure DoException beginning');
   DoError(DataError ,pchar(format('Error: %s'#13#10'While: %s',[E.Message, action])));

   LogMsg(lmInfo, UnitName, 'procedure DoException complete');
end;


procedure DoOutputData(FileType: Integer; Filename: pChar; Data: PChar);
begin
   LogMsg(lmInfo, UnitName, 'procedure DoOutputData beginning');
   if Assigned(OutputFileProc) then
      // Got somthing to do..
      OutputFileProc(FileType, Filename, Data)
   else
      // Not that likely to work then....
      DoError(ConfigError,'OutputFileProc not set');

   LogMsg(lmInfo, UnitName, 'procedure DoOutputData complete');
end;



function DecodeText(Value: PChar): TIOStream;
var
   InStream : TStringStream;
begin
   Result := TIOStream.Create;
   InStream := TStringStream.Create (Value);
   try
      Base64Decode(InStream, Result);
      Result.Position := 0;
   finally
      FreeandNil(Instream);
   end;

   LogMsg(lmInfo, UnitName, 'procedure DeCodetext complete');
end;

function EnCodetext(Value: Tstream): string;
var
    OutStream: TStringStream;
begin
  LogMsg(lmInfo, UnitName, 'function EnCodetext beginning');
  Result := '';
  OutStream := TStringStream.Create('');
  try
     Base64Encode(Value, OutStream);
     //Instream is now the result..
     Result := OutStream.DataString;
  finally
     FreeandNil(Outstream);
  end;

  LogMsg(lmInfo, UnitName, 'function EnCodetext complete');
end;




procedure ImportBooksFile(Code: PChar;  Blob: Pchar);
// The incomming blob is the actual Client file stream...
var
   ClientStream : TIostream;
   Client: TClientObj;
   XML:  TXML_Helper;
begin
   LogMsg(lmInfo, UnitName, 'procedure ImportBooksFile beginning');
   ClientStream := nil;
   Client := nil;
   XML := nil;
   try
      try
        LogDebug('ImportStart');
        ClientStream := DecodeText(Blob);

      except
         on E: exception do  DoException(E,'Decoding Text');
      end;

      Client := TClientObj.Create;
      try
         LogDebug('read Client Start');
         Client.SimpleRead(Code, ClientStream);
      except
         on E: exception do  DoException(E,'Reading Client file');
      end;
      if not Assigned(Client) then
         LogMsg(lmInfo, UnitName, 'procedure ImportBooksFile: Client is nil');
       LogMsg(lmInfo, UnitName, 'procedure ImportBooksFile: reading client');
      // Conserve Mem
      FreeAndNil(clientStream);

      XML := TXML_Helper.Create;
      try
         LogDebug('Make XML Start');
         DoOutputData(XMLData,pchar( string(Client.clFields.clCode)), PChar(xml.MakeXML(Client)));
         LogDebug('Import done');
      except
         on E: exception do  DoException(E,'Serialising XML');
      end;
      LogMsg(lmInfo, UnitName, 'procedure ImportBooksFile: serialising client');

   finally
      // Clean up
      FreeAndNil(clientStream);
      FreeAndNil(Client);
      FreeAndNil(XML);
   end;

   LogMsg(lmInfo, UnitName, 'procedure ImportBooksFile complete');
end;

procedure ExportBooksFile(Code: pChar; Blob: Pchar);
// The incomming blob is expected to be the XML stream
var
   XMLHelper:  TXML_Helper;
   Client: TClientObj;
   Stream : TBigMemoryStream;
begin
//   LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile beginning');

//   Client := nil;
//   stream := nil;

   XMLHelper := TXML_Helper.Create;
//   LogMsg(lmInfo, UnitName, '3');
   try
       try
         Client := XMLHelper.ReadClient(string(Blob));
//         LogMsg(lmInfo, UnitName, '4');
       except
         on E: exception do  DoException(E,'Deserializing XML');
       end;
//       LogMsg(lmInfo, UnitName, '5');
//       if not Assigned(Client) then
//         LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile: Client is nil');
//       LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile: reading client');

       try
//         LogMsg(lmInfo, UnitName, '6');
         stream := Client.SaveClientToStream;
       except
         on E: exception do  DoException(E,'Saving Client file');
       end;
//       LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile: saving client file');

       try
//          LogMsg(lmInfo, UnitName, '7');
          DoOutputData(BK5File,pChar(string(Client.clFields.clCode)),pChar(EnCodetext(stream)) );
   //       Stream.SaveToFile(pChar(string(Client.clFields.clCode)) + '.bk5');
       except
         on E: exception do  DoException(E,'Encoding Client file');
       end;
//       LogMsg(lmInfo, UnitName, '8');
//       LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile: encoding client file');

   finally
      FreeAndNil(Client);
      FreeAndNil(XMLHelper);
      FreeAndNil(stream);
   end;

//   LogMsg(lmInfo, UnitName, 'procedure ExportBooksFile complete');
end;

end.

