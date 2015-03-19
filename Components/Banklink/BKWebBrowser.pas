unit BKWebBrowser;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  SHDocVw;


type
  //----------------------------------------------------------------------------
  TBKWebBrowser = class(TWebBrowser)
  private
  protected
    procedure InternalLoadDocumentFromStream(const aStream: TStream);
    procedure InternalSaveDocumentToStream(const aStream: TStream);
  public
    procedure NavigateToURL(const aURL: string);
    procedure LoadFromStream(const aStream: TStream);
    procedure LoadFromFile(const aFileName: string);
    procedure LoadFromString(const aHtmlStr : string);

    procedure SaveToStream(const aStream: TStream);
    procedure SaveToFile(const aFileName: string);
    function SaveToString: string;
  published
  end;

//------------------------------------------------------------------------------
procedure Register;

//------------------------------------------------------------------------------
implementation

uses
  ActiveX,
  strutils,
  Forms;

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('BankLink', [TBKWebBrowser]);
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.InternalLoadDocumentFromStream(const aStream: TStream);
var
  PersistStreamInit: IPersistStreamInit;
  StreamAdapter: IStream;
begin
  if not Assigned(Document) then
    Exit;

  // Get IPersistStreamInit interface on document object
  if Document.QueryInterface(IPersistStreamInit, PersistStreamInit) = S_OK then
  begin
    // Clear document
    if PersistStreamInit.InitNew = S_OK then
    begin
      // Get IStream interface on stream
      StreamAdapter:= TStreamAdapter.Create(aStream);
      // Load data from Stream into WebBrowser
      PersistStreamInit.Load(StreamAdapter);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.InternalSaveDocumentToStream(const aStream: TStream);
var
  StreamAdapter: IStream;
  PersistStreamInit: IPersistStreamInit;
begin
  if not Assigned(Document) then
    Exit;

  if Document.QueryInterface(IPersistStreamInit, PersistStreamInit) = S_OK then
  begin
    StreamAdapter := TStreamAdapter.Create(aStream);
    PersistStreamInit.Save(StreamAdapter, True);
  end;
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.NavigateToURL(const aURL: string);
  // ---------------------------------------------------------------------------
  procedure Pause(const ADelay: Cardinal);
  var
    StartTC: Cardinal;  // tick count when routine called
  begin
    StartTC := Windows.GetTickCount;
    repeat
      Forms.Application.ProcessMessages;
    until Int64(Windows.GetTickCount) - Int64(StartTC) >= ADelay;
  end;
var
  Flags: OleVariant;  // flags that determine action
  LocalLoad : boolean;
begin
  LocalLoad := false;

  // Don't record in history
  Flags := navNoHistory;
  if AnsiStartsText('res://', aURL) or AnsiStartsText('file://', aURL)
    or AnsiStartsText('about:', aURL) or AnsiStartsText('javascript:', aURL)
    or AnsiStartsText('mailto:', aURL) then
  begin
    // don't use cache for local files
    Flags := Flags or navNoReadFromCache or navNoWriteToCache;
    LocalLoad := true;
  end;

  // Do the navigation and wait for it to complete
  Navigate(aURL, Flags);

  //while not (ReadyState in [READYSTATE_COMPLETE, READYSTATE_LOADED, READYSTATE_INTERACTIVE]) do
  //  Pause(5);
end;
//------------------------------------------------------------------------------
procedure TBKWebBrowser.LoadFromStream(const aStream: TStream);
begin
  NavigateToURL('about:blank');
  InternalLoadDocumentFromStream(aStream);
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.LoadFromFile(const aFileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(aFileName, fmOpenRead or fmShareDenyNone);
  try
    LoadFromStream(FileStream);
  finally
    FreeAndNil(FileStream);
  end;
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.LoadFromString(const aHtmlStr: string);
var
  StrStream: TStringStream;
begin
  StrStream := TStringStream.Create(aHtmlStr);
  try
    LoadFromStream(StrStream);
  finally
    FreeAndNil(StrStream);
  end;
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.SaveToStream(const aStream: TStream);
begin
  InternalSaveDocumentToStream(aStream);
end;

//------------------------------------------------------------------------------
procedure TBKWebBrowser.SaveToFile(const aFileName: string);
var
  FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(aFileName, fmCreate);
  try
    SaveToStream(FileStream);
  finally
    FileStream.Free;
  end;
end;

//------------------------------------------------------------------------------
function TBKWebBrowser.SaveToString: string;
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create('');
  try
    SaveToStream(StringStream);
    Result := StringStream.DataString;
  finally
    StringStream.Free;
  end;
end;


end.
