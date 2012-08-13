unit upgServiceUpgrader;

interface

uses upgDownloaderService, upgObjects;

type
  TDownloadServiceResult = (
    dsrSuccess,
    dsrError,
    dsrCancelled
  );

  TServiceUpgrader = class
  private
    FDownloaderService: TDownloaderService;
    FHttpDownloader: TbkUpgHTTPDownloader;
    FConfig: string;
    FStatusObserver: TbkUpgObserver;
    FCallInProgress: Boolean;
    FDownloadInProgress: Boolean;
    FCopyInProgress: Boolean;
    FCancelDownload: Boolean;
    FParserChecked: Boolean;
    FWriteErrorInfo: boolean;
    FLastErrorCode: string;
    function GetWindowsVersionString: string;
    function GetIdentInfo(aHandle: Cardinal; ApplicationID: Integer; ApplicationTitle, Version: string; var BConnectCode: string): string;
    function ExtractUrlFileName(const AUrl: string): string;
    function GetOperationInProgress: Boolean;
    procedure SetStatusObserver(const Value: TbkUpgObserver);
    procedure WriteErrorToIni(ErrorMessage: string);
    procedure SetErrorCode(PositionCode: integer; ErrorCode: integer);
  public
    Constructor Create(Config: string);
    Destructor Destroy; override;
    function IsUpdateAvailable(aHandle : THandle; ApplicationTitle: string; AppToUpdateID : integer; HostAppID: Integer;
      caMajorVer, caMinorVer, caRelease, caBuild : word; Country : byte; var IsNewVersion: boolean;
      var NewVersionNumber: string; var NewVersionDescription: string; var DetailsHref: string): TDownloadServiceResult;
    class function TranslationCountryIDToDBID(CountryID: byte): byte; static;
    function DownloadUpdateXML(aHandle: THandle; ApplicationTitle: string; AppToUpdateID: integer; HostAppID: integer;
      VersionString: string; Country: byte; OldVersionString: string; var ScriptCRC: Cardinal): TDownloadServiceResult;
    function DownloadFilesFromXML(ApplicationID: integer; CopyWhenFinished: boolean): TDownloadServiceResult;
    procedure CancelOperation;
    property StatusObserver: TbkUpgObserver read FStatusObserver write
      SetStatusObserver;
    property OperationInProgress: Boolean read GetOperationInProgress;
    property LastErrorCode: string read FLastErrorCode;
  end;

implementation

uses Classes, Windows, SysUtils, upgConstants, AppParser,
  Forms, omniXML, omniXMLUtils, CRCFileUtils, ipshttps, IniFiles, upgCommon;
{ TServiceUpgrader }

class function TServiceUpgrader.TranslationCountryIDToDBID(CountryID: byte): byte;
begin
  case CountryID of
    coNewZealand: Result := dbcoNewZealand;
    coAustralia: Result := dbcoAustralia;
    coUnitedKingdom: Result := dbcoUnitedKingdom;
  else
    Result := CountryID;
  end;
end;

procedure TServiceUpgrader.WriteErrorToIni(ErrorMessage: string);
var
  UpgradeIni: TIniFile;
  ErrorString: string;
begin
  if not FWriteErrorInfo then
    Exit;

  ErrorString := Format('Code: %s, Msg: %s',[LastErrorCode, ErrorMessage]);

  UpgradeIni := TIniFile.Create(ExtractFilePath(GetDllPath) + bkupgIniFile);
  try
    UpgradeIni.WriteString(IniDownloaderSection, 'DownloaderServiceError', ErrorString);
  finally
    UpgradeIni.Free;
  end;
end;

function TServiceUpgrader. ExtractUrlFileName(const AUrl: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('/', AUrl);
  Result := Copy(AUrl, i + 1, Length(AUrl) - (i));
end;

function TServiceUpgrader.GetIdentInfo(aHandle: Cardinal; ApplicationID: Integer;
  ApplicationTitle, Version: string; var BConnectCode: string): string;
var
  //List: TStringList;
  Output: string;
  DLLResult: Integer;
  FromURL: string;
  ToURL: string;
  BCIndex: Integer;
  List: TStringList;
  NewCRC: LongWord;
  ParserDLLName: string;
  NeedNewParser: Boolean;
  CurrentCRC: Cardinal;
begin
  BConnectCode := '';
  Output := '';
  //First Check to see if there's a new parser (but only want to check once
  if (not FParserChecked) then
  begin
    FCallInProgress := True;
    try
      FromURL := FDownloaderService.GetAppParser(ApplicationID, Version, GetWindowsVersionString, NewCRC);
    finally
      FCallInProgress := false;
    end;

    if (FromURL <> '') and (FromURL <> '0') then
    begin
      FParserChecked := true;
      //do we have a dll?
      ParserDLLName := GetParserDLLName(ApplicationID);
      if FileExists(ParserDLLName) then
      begin
        CurrentCRC := CRCFileUtils.CalculateCRC(ParserDLLName);
        NeedNewParser := CurrentCRC <> NewCRC;
      end
      else
        NeedNewParser := true;

      if NeedNewParser then
      begin
        ToURL := ExtractFilePath(Application.ExeName) + ExtractUrlFileName(FromURL);
        FDownloadInProgress := True;
        try
          if FHttpDownloader.GetFile(FromURL, ToURL, NewCRC) <> 1 then
            raise EServiceError.Create('Failed to Download Parser from ' + FromURL, deParserDownloadError);
        finally
          FDownloadInProgress := False;
        end;
      end;
    end;

  end;

  DllResult := ParserApp(ApplicationTitle, aHandle, ApplicationID, Output);
  if DllResult = -4 then
    raise EServiceError.Create('Failed to Parser Ident Info.'  + Output, deParserDLLError + -DllResult);
  if DLLResult < 0 then
    raise EServiceError.Create('Failed to Parser Ident Info.', deParserDLLError + -DllResult);


  //Need to seperate out the BConnect Code here
  if ApplicationID in [aidBK5_Practice, aidBK5_Offsite] then
  begin
    List := TStringList.Create;
    try
      List.StrictDelimiter := True;
      List.DelimitedText := Output;
      BCIndex := List.IndexOfName(eiBankLinkCode);
      if (BCIndex <> -1) then
      begin
        BConnectCode := List.ValueFromIndex[BCIndex];
        List.Delete(BCIndex);
      end;
      Result := List.DelimitedText;
    finally
      List.Free;
    end;
  end
  else
    Result := Output;
end;

function TServiceUpgrader.GetOperationInProgress: Boolean;
begin
  Result := FCallInProgress or FDownloadInProgress or FCopyInProgress;
end;

function TServiceUpgrader.GetWindowsVersionString: string;
var
 OSVersionInfo32: OSVERSIONINFO;
begin
  OSVersionInfo32.dwOSVersionInfoSize := SizeOf(OSVersionInfo32);
  GetVersionEx(OSVersionInfo32);
  Result := Format('%d.%d',[OSVersionInfo32.dwMajorVersion,OSVersionInfo32.dwMinorVersion]);
end;

function TServiceUpgrader.IsUpdateAvailable(aHandle: THandle;
  ApplicationTitle: string; AppToUpdateID: Integer; HostAppID: Integer; caMajorVer, caMinorVer, caRelease, caBuild: word;
  Country: byte; var IsNewVersion: boolean; var NewVersionNumber: string; var NewVersionDescription: string; var DetailsHref: string): TDownloadServiceResult;
var
  ExtraIdentInfo: string;
  ExtraInfo: string;
  VersionString: string;
  BConnectCode: string;
  SubAppDetails: string; //Not Used at the moment

begin
  VersionString := Format('%d.%d.%d.%d',[caMajorVer, caMinorVer, caRelease, caBuild]);
  ExtraInfo := Format('%s=%s',[eiWinVersion,GetWindowsVersionString]);
  StatusObserver.UpdateProgress('Checking for Updates', 50);
  try
    ExtraIdentInfo := GetIdentInfo(aHandle, HostAppID, ApplicationTitle, VersionString, BConnectCode);
  except
    on Ex: Exception do //Keep going on exceptions, with blank information.
      WriteErrorToIni('IsUpdateAvailable: ' + Ex.Message);
  end;

  try
    FCallInProgress := True;
    try
      IsNewVersion := FDownloaderService.IsUpdateAvailable(AppToUpdateID, VersionString, BConnectCode, TranslationCountryIDToDBID(Country),
        extraIdentInfo, ExtraInfo, NewVersionNumber, NewVersionDescription, DetailsHref, SubAppDetails);
    finally
      FCallInProgress := False;
    end;
    Result := dsrSuccess;
  except
    on SvcEx: EServiceError do
    begin
      SetErrorCode(dsUpdateAvailable + AppToUpdateID, SvcEx.ErrorCode);
      Result := dsrError;
      WriteErrorToIni('IsUpdateAvailable: ' + SvcEx.Message);
    end;
    on Ex: Exception do
    begin
      SetErrorCode(dsUpdateAvailable + AppToUpdateID, deUnknown);
      Result := dsrError;
      WriteErrorToIni('IsUpdateAvailable: ' + Ex.Message);
    end;
  end;
end;


procedure TServiceUpgrader.SetErrorCode(PositionCode, ErrorCode: integer);
begin
  FLastErrorCode := Format('%.3d-%.3d',[PositionCode, ErrorCode]);
end;

procedure TServiceUpgrader.SetStatusObserver(const Value: TbkUpgObserver);
begin
  FStatusObserver := Value;
  FHttpDownloader.RegisterObserver(FStatusObserver);
end;

function TServiceUpgrader.DownloadUpdateXML(aHandle: THandle; ApplicationTitle: string;
  AppToUpdateID: integer; HostAppID: integer; VersionString: string;
  Country: byte; OldVersionString: string; var ScriptCRC: Cardinal): TDownloadServiceResult;
var
  ExtraIdentInfo: string;
  AppXML: string;
  ExtraInfo: string;
  XMLFile: TextFile;
  FileName: string;
  BConnectCode: string;
begin
  try
    ExtraIdentInfo := GetIdentInfo(aHandle, HostAppID, ApplicationTitle, VersionString, BConnectCode);
  except
    on Ex: Exception do //Keep going on exceptions, with blank information.
      WriteErrorToIni('IsUpdateAvailable: ' + Ex.Message);
  end;

  try
    ExtraInfo := Format('%s=%s,%s=%s',[eiWinVersion,GetWindowsVersionString,eiPreviousVersion, OldVersionString]);
    StatusObserver.UpdateProgress('Getting Update XML', 20);
    FCallInProgress := true;
    try
      AppXML := FDownloaderService.GetVersion(AppToUpdateID, BConnectCode, TranslationCountryIDToDBID(Country), ExtraIdentInfo, VersionString, ExtraInfo);
    finally
      FCallInProgress := False;
    end;
    //Got the XML. Save it to a location.
    if AppXML <> '' then
    begin
      FileName := ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR + Format('%d.XML',[AppToUpdateID]);
      AssignFile(XMLFile, FileName);
      Rewrite(XMLFile);
      Write(XMLFile, AppXML);
      CloseFile(XMLFile);
      ScriptCRC := CRCFileUtils.CalculateCRC(FileName);
      Result := dsrSuccess;
    end
    else
    begin
      SetErrorCode(dsDownloadVersionXML + AppToUpdateID, deAppXMLEmpty);
      Result := dsrError;
      WriteErrorToIni('DownloadUpdateXML - XML is empty');
    end;
  except
    on SvcEx: EServiceError do
    begin
      SetErrorCode(dsDownloadVersionXML + AppToUpdateID, SvcEx.ErrorCode);
      Result := dsrError;
      WriteErrorToIni('IsUpdateAvailable: ' + SvcEx.Message);
    end;
    on Ex: Exception do
    begin
      SetErrorCode(dsDownloadVersionXML + AppToUpdateID, deUnknown);
      Result := dsrError;
      WriteErrorToIni('IsUpdateAvailable: ' + Ex.Message);
    end;
  end;
end;

procedure TServiceUpgrader.CancelOperation;
begin
  if FCallInProgress then
    FDownloaderService.Interupt;
  if FDownloadInProgress then
  begin
    FCancelDownload := True;
    FHttpDownloader.CancelDownload;
  end;
  if FCopyInProgress then
    FCancelDownload := True;

end;

constructor TServiceUpgrader.Create(Config: string);
var
  IniFileName: string;
  UpgradeIni: TIniFile;
begin
  FParserChecked := false;
  FConfig := Config;
  FDownloaderService := TDownloaderService.Create(Config);
  FHttpDownloader := TbkUpgHTTPDownloader.Create;
  FHttpDownloader.LoadConfig(Config);

  IniFileName := ExtractFilePath(GetDllPath) + bkupgIniFile;
  if FileExists(IniFileName) then
  begin
    UpgradeIni := TIniFile.Create(IniFileName);
    try
      FWriteErrorInfo := UpgradeIni.ReadBool(IniDownloaderSection, WriteErrorInfoKey, false);
    finally
      UpgradeIni.Free;
    end;
  end
  else
    FWriteErrorInfo := false;
end;

destructor TServiceUpgrader.Destroy;
begin
  FreeAndNil(FDownloaderService);
  FreeAndNil(FHttpDownloader);
  inherited;
end;

function TServiceUpgrader.DownloadFilesFromXML(ApplicationID: integer; CopyWhenFinished: boolean): TDownloadServiceResult;
var
  XMLFileName: String;
  xmlParser: IXMLDocument;
  RootNode: IXMLNode;
  FileList: IXMLNodeList;
  I: Integer;
  URL: string;
  ComponentNode: IXMLNode;
  CRC: cardinal;
  ToLocation: string;
  FileName: string;
  FromLocation: string;
  CopySuccess: boolean;
  LastError: String;
begin
  try
    XMLFileName := ExtractFilePath( Application.ExeName) + DEFAULT_TEMP_DIR + Format('\%d.XML',[ApplicationID]);

    xmlParser := CreateXMLDoc;
    try
      xmlParser.PreserveWhiteSpace := false;
      xmlParser.Load(XMLFileName);
      RootNode := xmlParser.SelectSingleNode('files');
      FileList := FilterNodes(RootNode, 'component');
      FDownloadInProgress := True;
      try
        for I := 0 to FileList.Length - 1 do
        begin
          if FCancelDownload then
          begin
            FCancelDownload := false;
            Result := dsrCancelled;
            Exit;
          end;
          ComponentNode := FileList.Item[i];
          URL := GetNodeTextStr(ComponentNode, 'DownloadURL', '');
          ToLocation := ExtractFilePath(Application.ExeName) + DEFAULT_TEMP_DIR + GetNodeTextStr(ComponentNode, 'filename', '');
          CRC := GetNodeTextInt64(ComponentNode, 'crc', 0);

          if FHttpDownloader.GetFile(URL, ToLocation, CRC) <> 1 then
          begin
            //failure
            if FCancelDownload then
              Result := dsrCancelled
            else
            begin
              SetErrorCode(dsDownloadFiles + ApplicationID, 0);
              WriteErrorToIni('DownloadFilesFromXML - Error downloading ' + URL);
              Result := dsrError;
            end;
            Exit;
          end;
        end;
      finally
        FDownloadInProgress := False;
      end;

      //Now copy the files if needed.
      if CopyWhenFinished then
      begin
        FCopyInProgress := True;
        try
          StatusObserver.UpdateProgress('Copying Files', 0);
          for I := 0 to FileList.Length - 1 do
          begin
            if FCancelDownload then
            begin
              FCancelDownload := false;
              Result := dsrCancelled;
              Exit;
            end;
            ComponentNode := FileList.Item[i];
            FileName := GetNodeTextStr(ComponentNode, 'filename', '');
            StatusObserver.UpdateProgress('Copying ' + FileName, MulDiv(I, 100, FileList.Length));
            FromLocation :=  ExtractFilePath(Application.ExeName) + DEFAULT_TEMP_DIR + FileName;
            ToLocation := ExtractFilePath(Application.ExeName) + FileName;
            repeat
              CopySuccess := CopyFile(PChar(FromLocation), PChar(ToLocation), false);
              if not CopySuccess then
              begin
                LastError := SysErrorMessage(GetLastError);
                case
                  Application.MessageBox(PChar('Could not file copy to ' +
                    ToLocation +#13'[' + LastError +']'#13'Please make sure it is not in use'), 'Confirm',
                  MB_RETRYCANCEL + MB_ICONERROR)
                of
                  idRetry: ;
                  idCancel:
                    begin
                      Result := dsrCancelled;
                      Exit;
                    end;
                end;
              end;
            until (CopySuccess);
          end;
        finally
          FCopyInProgress := False;
        end;
      end;
    finally
      xmlParser := nil;
    end;
    Result := dsrSuccess;
  except
    on Ex: Exception do
    begin
      SetErrorCode(dsDownloadFiles + ApplicationID, deUnknown);
      Result := dsrError;
      WriteErrorToIni('DownloadFilesFromXML - ' + Ex.Message);
    end;
  end;

end;


end.
