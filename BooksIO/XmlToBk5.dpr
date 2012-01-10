library XmlToBk5;

{ Important note about DLL memory management: ShareMem must be the
  first unit in your library's USES clause AND your project's (select
  Project-View Source) USES clause if your DLL exports any procedures or
  functions that pass strings as parameters or function results. This
  applies to all strings passed to and from your DLL--even those that
  are nested in records and classes. ShareMem is the interface unit to
  the BORLNDMM.DLL shared memory manager, which must be deployed along
  with your DLL. To avoid using BORLNDMM.DLL, pass string information
  using PChar or ShortString parameters. }

uses
  SysUtils,
  Classes,
  Dialogs,
  OmniXMLUtils,
  IOStream,
  ClObj32,
  ListHelpers;

{$R *.res}

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

procedure ConvertBK5ToXML(EncodedBK5File: PChar; Len: integer; out XMLFile: PChar); stdcall;
var
  ClientStream : TIostream;
  Client: TClientObj;
  XML:  TXML_Helper;
  XMLString: string;
  BuffSize: Integer;
begin
  try
    GetMem(XMLFile, Len + 1);
    FillChar(XMLFile^, Len + 1, 0);
    Move(EncodedBK5File^, XMLFile^, Len);
    ClientStream := DecodeText(XMLFile);
    try
      try
        Client := TClientObj.Create;
        try
          LogDebug('read Client Start');
          Client.SimpleRead('', ClientStream);
          try
            XML := TXML_Helper.Create;
            try
              LogDebug('Make XML Start');
              XMLString := XML.MakeXML(Client);
              BuffSize := SizeOf(Char)*(Length(XMLString) + 1);//+1 for null-terminator
              GetMem(XMLFile, BuffSize);
              FillChar(XMLFile^, BuffSize, 0);
              Move(PChar(XMLString)^, XMLFile^, BuffSize);
              LogDebug('Import done');
            finally
              XML.Free;
            end;
          except
            on E: Exception do ShowMessage('Serialising XML: ' + E.Message);
          end;
        finally
          Client.Free;
        end;
      except
        on E: Exception do ShowMessage('Reading Client file: ' + E.Message);
      end;
    finally
      ClientStream.Free;
    end;
  except
    on E: Exception do ShowMessage('Decoding Text: ' + E.Message);
  end;
end;

procedure ConvertXMLToBK5(pIn: PChar; Len: integer; out pOut: PChar); stdcall;
var
  XMLHelper:  TXML_Helper;
  Client: TClientObj;
  Stream : TBigMemoryStream;
  EncodedBK5: string;
  BuffSize: Integer;
begin
  GetMem(pOut, Len + 1);
  FillChar(pOut^, Len + 1, 0);
  Move(pIn^, pOut^, Len);

  XMLHelper := TXML_Helper.Create;
  try
    try
      Client := XMLHelper.ReadClient(string(pOut));
      try
        try
          Stream := Client.SaveClientToStream;
          try
            try
              EncodedBK5 := EnCodetext(Stream);
              BuffSize := SizeOf(Char)*(Length(EncodedBK5)+1);//+1 for null-terminator
              GetMem(pOut, BuffSize);
              FillChar(pOut^, BuffSize, 0);
              Move(PChar(EncodedBK5)^, pOut^, BuffSize);
            except
              on E: Exception do ShowMessage('Encoding Client file: ' + E.Message);
            end;
          finally
            Stream.Free;
          end;
        except
          on E: Exception do ShowMessage('Saving Client file: ' + E.Message);
        end;
      finally
        Client.Free;
      end;
    except
      on E: Exception do ShowMessage('Deserializing XML: ' + E.Message);
    end;
  finally
    FreeAndNil(XMLHelper);
  end;
end;

procedure BlockFree(p: Pointer); stdcall;
begin
  FreeMem(p);//safe to call when p=nil
end;

exports
  ConvertXMLToBK5,
  ConvertBK5ToXML,
  BlockFree;

begin

end.
