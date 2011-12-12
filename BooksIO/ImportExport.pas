unit ImportExport;

interface

uses
  IOStream,
  sysutils,
  classes,
  ProcTypes;


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


var
  OutputFileProc : OutputFile;

  ErrorProc: OutputError;

procedure SetOutputFileProc (Value: OutputFile);
begin
  OutputFileProc := Value;
end;


procedure SetErrorProc (Value: OutputError);
begin
  ErrorProc := Value;
end;


procedure DoError(Error: Integer; ErrorText: pChar);
begin
  if Assigned(ErrorProc) then
      ErrorProc(Error, ErrorText);
end;

procedure DoException(E: Exception; Action : string);
begin
   DoError(DataError ,pchar(format('Error: %s'#13#10'While: %s',[E.Message, action])));
end;


procedure DoOutputData(FileType: Integer; Filename: pChar; Data: PChar);
begin
   if Assigned(OutputFileProc) then
      // Got somthing to do..
      OutputFileProc(FileType, Filename, Data)
   else
      // Not that likely to work then....
      DoError(ConfigError,'OutputFileProc not set');
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
end;

function EnCodetext(Value: Tstream): string;
var
    OutStream: TStringStream;
begin
  Result := '';
  OutStream := TStringStream.Create('');
  try
     Base64Encode(Value, OutStream);
     //Instream is now the result..
     Result := OutStream.DataString;
  finally
     FreeandNil(Outstream);
  end;
end;




procedure ImportBooksFile(Code: PChar;  Blob: Pchar);
// The incomming blob is the actual Client file stream...
var
   ClientStream : TIostream;
   Client: TClientObj;
   XML:  TXML_Helper;
begin
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

   finally
      // Clean up
      FreeAndNil(clientStream);
      FreeAndNil(Client);
      FreeAndNil(XML);
   end;

end;

procedure ExportBooksFile(Code: pChar; Blob: Pchar);
// The incomming blob is expected to be the XML stream
var
   XMLHelper:  TXML_Helper;
   Client: TClientObj;
   Stream : TBigMemoryStream;

begin
   Client := nil;
   stream := nil;
   XMLHelper := TXML_Helper.Create;
   try
       try
         Client := XMLHelper.ReadClient(string(Blob));
       except
         on E: exception do  DoException(E,'Deserializing XML');
       end;

       try
         stream := Client.SaveClientToStream;
       except
         on E: exception do  DoException(E,'Saving Client file');
       end;

       try
          DoOutputData(BK5File,pChar(string(Client.clFields.clCode)),pChar(EnCodetext(stream)) );
       except
         on E: exception do  DoException(E,'Encoding Client file');
       end;

   finally
      FreeAndNil(Client);
      FreeAndNil(XMLHelper);
      FreeAndNil(stream);
   end;
end;



end.

