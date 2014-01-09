unit UpgradeReminder;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  ipshttps;

type
  TUpgradeReminder = class
  private
    fPracticeLatestVersion : string;
    fUpgradeReminderVersion : string;
    fHtmlReminder : string;

  protected
    function TryDecodeVersion(aVersion : String; var aMajor, aMinor, aBuild, aRevision : integer) : boolean;
    procedure WriteStreamInt(Stream : TStream; Num : integer);
    function ReadStreamInt(Stream : TStream; var Num : integer) : boolean;
    function LoadFromFile(aFileName : string) : boolean;
    function SaveToFile(aFileName : string) : boolean;
    function CanShowDependingOnVersion() : boolean;
    procedure Show();

    function TryGetLocalHTMLReminder() : boolean;

  public
    function SaveLocalHTMLReminder() : boolean;

    function TryGetOnlineHTMLReminder() : boolean;
    function TryGetandShowHTMLReminder() : boolean;
    procedure LoadFromTextFile();

    property PracticeLatestVersion : string read fPracticeLatestVersion write fPracticeLatestVersion;
    property UpgradeReminderVersion : string read fUpgradeReminderVersion write fUpgradeReminderVersion;
    property HtmlReminder : string read fHtmlReminder write fHtmlReminder;

  end;

  function UpgradeReminderMsg: TUpgradeReminder;

var
  UpgradeReminderSinglton : TUpgradeReminder;

implementation

uses
  UpgradeReminderFrm,
  WinUtils,
  Globals,
  LogUtil,
  BankLinkOnlineServices;

Const
  UnitName = 'UpgradeReminder';

//------------------------------------------------------------------------------
function UpgradeReminderMsg : TUpgradeReminder;
begin
  if not Assigned(UpgradeReminderSinglton) then
    UpgradeReminderSinglton := TUpgradeReminder.Create;

  Result := UpgradeReminderSinglton;
end;

{ TUpgradeReminder }
//------------------------------------------------------------------------------
procedure TUpgradeReminder.WriteStreamInt(Stream : TStream; Num : integer);
begin
  Stream.Write(Num, SizeOf(integer));
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.ReadStreamInt(Stream : TStream; var Num : integer) : boolean;
begin
  Result := (Stream.Read(Num, SizeOf(integer)) = SizeOf(integer));
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.TryDecodeVersion(aVersion: String; var aMajor, aMinor, aBuild, aRevision: integer) : Boolean;
var
  DelimeterList : TStringList;

begin
  Result := false;
  DelimeterList := TStringList.Create();
  try
    DelimeterList.Delimiter := '.';
    DelimeterList.StrictDelimiter := True;
    DelimeterList.DelimitedText := aVersion;

    Result := (DelimeterList.Count = 4);

    if Result then
      Result := TryStrToInt(DelimeterList.Strings[0], aMajor);
    if Result then
      Result := TryStrToInt(DelimeterList.Strings[1], aMinor);
    if Result then
      Result := TryStrToInt(DelimeterList.Strings[2], aBuild);
    if Result then
      Result := TryStrToInt(DelimeterList.Strings[3], aRevision);

  finally
    FreeAndNil(DelimeterList);
  end;
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.CanShowDependingOnVersion: boolean;
var
  Major : integer;
  Minor : integer;
  Build : integer;
  Revision : integer;
begin
  Result := TryDecodeVersion(fUpgradeReminderVersion, Major, Minor, Build, Revision);

  if not Result then
    Exit;

  Result := (Major > VersionInfo.AppVerMajor);
  if (Result) or (Major < VersionInfo.AppVerMajor) then
    Exit;

  Result := (Minor > VersionInfo.AppVerMinor);
  if (Result) or (Minor < VersionInfo.AppVerMinor) then
    Exit;

  Result := (Build > VersionInfo.AppVerRelease);
  if (Result) or (Build < VersionInfo.AppVerRelease) then
    Exit;

  Result := (Revision > VersionInfo.AppVerBuild);
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.LoadFromFile(aFileName: string) : boolean;
var
  FileStream      : TFileStream;
  PracticeVersion : TStringStream;
  ReminderVersion : TStringStream;
  HtmlReminder    : TStringStream;
  PracticeVersionSize : integer;
  ReminderVersionSize : integer;
  HtmlReminderSize    : integer;
begin
  Result := false;
  FileStream := TFileStream.Create(aFileName, fmOpenRead);
  try
    PracticeVersion := TStringStream.Create('');
    try
      ReminderVersion := TStringStream.Create('');
      try
        HtmlReminder := TStringStream.Create('');
        try
          FileStream.Position := 0;

          ReadStreamInt(FileStream, PracticeVersionSize);
          ReadStreamInt(FileStream, ReminderVersionSize);
          ReadStreamInt(FileStream, HtmlReminderSize);

          PracticeVersion.CopyFrom(FileStream, PracticeVersionSize);
          ReminderVersion.CopyFrom(FileStream, ReminderVersionSize);
          HtmlReminder.CopyFrom(FileStream, HtmlReminderSize);

          fPracticeLatestVersion := PracticeVersion.DataString;
          fUpgradeReminderVersion := ReminderVersion.DataString;
          fHtmlReminder := HtmlReminder.DataString;
          Result := true;
        finally
          FreeAndNil(HtmlReminder);
        end;
      finally
        FreeAndNil(ReminderVersion);
      end;
    finally
      FreeAndNil(PracticeVersion);
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.SaveToFile(aFileName: string) : boolean;
var
  FileStream      : TFileStream;
  PracticeVersion : TStringStream;
  ReminderVersion : TStringStream;
  HtmlReminder    : TStringStream;
  PracticeVersionSize : integer;
  ReminderVersionSize : integer;
  HtmlReminderSize    : integer;
begin
  Result := false;
  FileStream := TFileStream.Create(aFileName, fmCreate);
  try
    PracticeVersion := TStringStream.Create(fPracticeLatestVersion);
    try
      ReminderVersion := TStringStream.Create(fUpgradeReminderVersion);
      try
        HtmlReminder := TStringStream.Create(fHtmlReminder);
        try
          PracticeVersionSize := PracticeVersion.Size;
          ReminderVersionSize := ReminderVersion.Size;
          HtmlReminderSize    := HtmlReminder.Size;

          WriteStreamInt(FileStream, PracticeVersionSize);
          WriteStreamInt(FileStream, ReminderVersionSize);
          WriteStreamInt(FileStream, HtmlReminderSize);

          FileStream.CopyFrom(PracticeVersion, 0);
          FileStream.CopyFrom(ReminderVersion, 0);
          FileStream.CopyFrom(HtmlReminder, 0);
          Result := true;
        finally
          FreeAndNil(HtmlReminder);
        end;
      finally
        FreeAndNil(ReminderVersion);
      end;
    finally
      FreeAndNil(PracticeVersion);
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

//------------------------------------------------------------------------------
procedure TUpgradeReminder.Show();
begin
  ShowUpgradeReminder(HtmlReminder);
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.SaveLocalHTMLReminder: boolean;
const
  ThisMethodName = 'SaveLocalHTMLReminder';
begin
  try
    Result := SaveToFile(DataDir + REMINDER_VERSION_FILENAME);
  except
    On E : Exception do
    begin
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + E.Message);
      Result := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.TryGetLocalHTMLReminder: boolean;
const
  ThisMethodName = 'TryGetLocalHTMLReminder';
begin
  try
    Result := FileExists(DataDir + REMINDER_VERSION_FILENAME);

    if Result then
      Result := LoadFromFile(DataDir + REMINDER_VERSION_FILENAME);

  except
    On E : Exception do
    begin
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + E.Message);
      Result := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.TryGetOnlineHTMLReminder: boolean;
const
  ThisMethodName = 'TryGetOnlineHTMLReminder';
var
  PracLatestVersion, UpgReminderVersion, HtmlRemind : string;
begin
  try
    Result := (ProductConfigService.GetPracUpgReminderMsg(PracLatestVersion, UpgReminderVersion, HtmlRemind, true) in [bloSuccess, bloFailedNonFatal]);

    if Result then
    begin
      if (length(trim(PracLatestVersion)) = 0) or
         (length(trim(UpgReminderVersion)) = 0) or
         (length(trim(HtmlRemind)) = 0) then
      begin
        Result := false;
      end
      else
      begin
        fPracticeLatestVersion := PracLatestVersion;
        fUpgradeReminderVersion := UpgReminderVersion;
        fHtmlReminder := HtmlRemind;
      end;
    end;

    if Result then
      Result := SaveLocalHTMLReminder();
  except
    On E : Exception do
    begin
      LogUtil.LogMsg( lmError, UnitName, ThisMethodName + ' : ' + E.Message);
      Result := false;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TUpgradeReminder.TryGetandShowHTMLReminder: boolean;
begin
  Result := TryGetOnlineHTMLReminder();

  if not Result then
    Result := TryGetLocalHTMLReminder();

  if (Result) and (CanShowDependingOnVersion()) then
    Show();
end;

//------------------------------------------------------------------------------
procedure TUpgradeReminder.LoadFromTextFile;
var
  FileStream   : TFileStream;
  StringStream : TStringStream;
begin
  FileStream := TFileStream.Create('C:\My Documents\Projects\Html Test App\html.txt', fmOpenRead);
  try
    StringStream := TStringStream.Create('');
    try
      StringStream.CopyFrom(FileStream, FileStream.Size);

      fPracticeLatestVersion  := '5.35.1.100';
      fUpgradeReminderVersion := '5.35.0.0';
      fHtmlReminder           := StringStream.DataString;

    finally
      FreeAndNil(StringStream);
    end;
  finally
    FreeAndNil(FileStream);
  end;
end;

//------------------------------------------------------------------------------
initialization
  UpgradeReminderSinglton := nil;

//------------------------------------------------------------------------------
finalization
  FreeAndNil(UpgradeReminderSinglton);

end.
