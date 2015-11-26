unit uMainFrm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  IdBaseComponent, IdComponent, IdTCPServer, IdHTTPServer, StdCtrls,
  ExtCtrls, HTTPApp, Buttons, IdCustomTCPServer, IdCustomHTTPServer, idContext,
  HTTPProd, SyDefs, BankLinkOnlineServices, ulkJson, ClientLookupFme, StDate,
  ClientCodingStatistics;

type
  TClientDetails = class(TCollectionItem)
  private
    FCode : string;
    FName: string;
    FGroup : string;
    FClientType : string;
    FStatus : string;
    FLastAccessed : TDateTime;

    FCoded : string;
    FFinalized: string;
    FTransferred : string;
    FDownloaded : string;
  public
    property Code : string read FCode write FCode;
    property Name : string read FName write FName;
    property Group : string read FGroup write FGroup;
    property ClientType : string read FClientType write FClientType;
    property Status : string read FStatus write FStatus;
    property LastAccessed : TDateTime read FLastAccessed write FLastAccessed;

    property Coded : string read FCoded write  FCoded;
    property Finalized: string read FFinalized write  FFinalized;
    property Transferred : string read FTransferred write  FTransferred;
    property Downloaded : string read FDownloaded write  FDownloaded;

    procedure Write(const aJson: TlkJSONobject);
  end;

  TClients = Class(TCollection)
  private
  public
    function ItemAs(aIndex : integer) : TClientDetails;
    procedure Write(const aJson: TlkJSONobject);
  end;

  TfrmServer = class(TForm)
    Label2: TLabel;
    HTTPServer: TIdHTTPServer;
    edtRootFolder: TEdit;
    btnGetFolder: TBitBtn;
    edtDefaultDoc: TEdit;
    Label1: TLabel;
    lstLog: TListBox;
    btnClearLog: TBitBtn;
    pgpEHTML: TPageProducer;
    btnConnect: TButton;
    Label3: TLabel;
    Label4: TLabel;
    edtHost: TEdit;
    edtPort: TEdit;
    procedure btnGetFolderClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure chkActiveClick(Sender: TObject);
    procedure btnClearLogClick(Sender: TObject);
    procedure pgpEHTMLHTMLTag(Sender: TObject; Tag: TTag;
      const TagString: string; TagParams: TStrings;
      var ReplaceText: string);
    procedure HTTPServerCommandGet(Context: TIdContext;
      RequestInfo: TIdHTTPRequestInfo; ResponseInfo: TIdHTTPResponseInfo);
    procedure btnConnectClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    SuperPwd : string;
    User : pUser_Rec;
    Password : string;
    StartServer : Boolean;
    ServerStarted : Boolean;
    ProcStatOffset : integer;
    function GetClientStat(sysClientRec: pClient_File_Rec; ForDate: TSTDate):ClientStat;
    procedure BuildClientList(var Response: TlkJSONobject);
    procedure Log(Data: string);
    procedure LogServerState;
    function Login(uName, pass: String; out Cancelled: Boolean): Boolean;
    class function LoginOnline(User: TUser_Rec; uName: String; var CurrentPassword: String; out Cancelled, OfflineAuthentication: Boolean; IgnoreOnlineUser: Boolean = False): Boolean; overload;
    class function LoginOnline(UserCode, uName: String; var CurrentPassword: String; out Cancelled, OfflineAuthentication: Boolean; IgnoreOnlineUser: Boolean = False): Boolean; overload;
  public
    function ValidatePracticeUser(Params : TStrings):Boolean;
  end;

var
  frmServer: TfrmServer;

implementation

uses
  ShlObj, FileCtrl, login32, Globals, WinUtils, WarningMoreFrm,
  bkConst, Admin32, SysObj32, INISettings, BlopiServiceFacade;

{$R *.DFM}

// copied from the last "Latium Software - Pascal Newsletter #33"

function BrowseCallbackProc(Wnd: HWND; uMsg: UINT;
  lParam, lpData: LPARAM): Integer stdcall;
var
  Buffer: array[0..MAX_PATH - 1] of char;
begin
  case uMsg of
    BFFM_INITIALIZED:
      if lpData <> 0 then
        SendMessage(Wnd, BFFM_SETSELECTION, 1, lpData);
    BFFM_SELCHANGED:
      begin
        SHGetPathFromIDList(PItemIDList(lParam), Buffer);
        SendMessage(Wnd, BFFM_SETSTATUSTEXT, 0, Integer(@Buffer));
      end;
  end;
  Result := 0;
end;

// copied from the last "Latium Software - Pascal Newsletter #33"

function BrowseForFolder(Title: string; RootCSIDL: integer = 0;
  InitialFolder: string = ''): string;
var
  BrowseInfo: TBrowseInfo;
  Buffer: array[0..MAX_PATH - 1] of char;
  ResultPItemIDList: PItemIDList;
begin
  with BrowseInfo do
  begin
    hwndOwner := Application.Handle;
    if RootCSIDL = 0 then
      pidlRoot := nil
    else
      SHGetSpecialFolderLocation(hwndOwner, RootCSIDL,
        pidlRoot);
    pszDisplayName := @Buffer;
    lpszTitle := PChar(Title);
    ulFlags := BIF_RETURNONLYFSDIRS or BIF_STATUSTEXT;
    lpfn := BrowseCallbackProc;
    lParam := Integer(Pointer(InitialFolder));
    iImage := 0;
  end;
  Result := '';
  ResultPItemIDList := SHBrowseForFolder(BrowseInfo);
  if ResultPItemIDList <> nil then
  begin
    SHGetPathFromIDList(ResultPItemIDList, Buffer);
    Result := Buffer;
    GlobalFreePtr(ResultPItemIDList);
  end;
  with BrowseInfo do
    if pidlRoot <> nil then
      GlobalFreePtr(pidlRoot);
end;

// clear log file

procedure TfrmServer.btnClearLogClick(Sender: TObject);
begin
  lstLog.Clear;
end;

// got http server root folder

procedure TfrmServer.btnGetFolderClick(Sender: TObject);
var
  NewFolder: string;
begin
  NewFolder := BrowseForFolder('Web Root Folder', 0, edtRootFolder.Text);
  if NewFolder <> '' then
    if DirectoryExists(NewFolder) then
      edtRootFolder.Text := NewFolder;
end;

procedure TfrmServer.BuildClientList(var Response: TlkJSONobject);
var
  ClientLookup: TfmeClientLookup;
  Clients : TClients;
  ClientObj : TClientDetails;
  i, j: Integer;
  ClientFile : pClient_File_Rec;
  ProcStatDate: integer;
begin
  if not Assigned(Response) then
    Exit;

  Clients := Nil;
  with AdminSystem, fdSystem_Client_File_List do
  begin
    if ItemCount > 0  then
      Clients := TClients.Create(TClientDetails);

    for i := 0 to Pred(itemCount) do
    begin
      ClientFile := Client_File_At(i);
      ClientObj := TClientDetails.Create(Clients); // local object

      if ClientFile.cfClient_Type = ctProspect then Continue;
      ProcStatDate := IncDate (CurrentDate, 0, - ProcStatOffset, 0);
      {get details}
      ClientObj.Code := ClientFile.cfFile_Code;
      ClientObj.Name := ClientFile.cfFile_Name;
      ClientObj.LastAccessed := StDateToDateTime(ClientFile.cfDate_Last_Accessed);

      if clientFile.cfFile_Status in [fsMin..fsMax] then
        ClientObj.Status := fsNames[clientFile.cfFile_Status ];

      with  GetClientStat(ClientFile,ProcStatDate) do
      begin
        ClientObj.Coded := '';
        for j := 1 to High(Coded) do
          ClientObj.Coded := ClientObj.Coded + IntToStr(Integer(Coded[j]));

        ClientObj.Finalized := '';
        for j := 1 to High(Finalized) do
          ClientObj.Finalized := ClientObj.Finalized + IntToStr(Integer(Finalized[j]));

        ClientObj.Transferred := '';
        for j := 1 to High(Transferred) do
          ClientObj.Transferred := ClientObj.Transferred + IntToStr(Integer(Transferred[j]));


        ClientObj.Downloaded := '';
        for j := 1 to High(Downloaded) do
          ClientObj.Downloaded := ClientObj.Downloaded + IntToStr(Integer(Downloaded[j]));
      end;
    end;
  end;

  if Assigned(Clients) then
    Clients.Write(Response);
end;

procedure TfrmServer.btnConnectClick(Sender: TObject);
begin
  if (StartServer) then
  begin
    // root folder must exists
    if AnsiLastChar(edtRootFolder.Text)^ = '\' then
      edtRootFolder.Text :=
        Copy(edtRootFolder.Text, 1, Pred(Length(edtRootFolder.Text)));
    if not DirectoryExists(edtRootFolder.Text) then
      ShowMessage('Root Folder does not exist.');
      
    with HTTPServer.Bindings.Add do
    begin
      IP := edtHost.Text;
      Port := StrToIntDef(edtPort.Text,0);
    end;
  end;
  
  // de-/activate server
  httpServer.Active := StartServer;
  ServerStarted := StartServer;
  if StartServer then
  begin
    btnConnect.Caption := 'Stop Server';
  end
  else
  begin
    btnConnect.Caption := 'Stop Server';
  end;
  StartServer := not StartServer;
  // log to list box
  LogServerState;
  // set interactive state for user fields
  edtRootFolder.Enabled := not ServerStarted;
  edtDefaultDoc.Enabled := not ServerStarted;
end;

// de-activate http server

procedure TfrmServer.chkActiveClick(Sender: TObject);
begin
end;

// prepare !

procedure TfrmServer.FormCreate(Sender: TObject);
begin
  try
    ProcStatOffset := 0;
    AdminSystem := nil;

    //Read Practice INI settings
    ReadPracticeINI;

    if AdminExists then
      LoadAdminSystem(True, ' ' );

    //Read Users INI file
    BK5ReadINI;
  finally
    edtRootFolder.Text := ExtractFilePath(Application.ExeName) + 'WebSite';
    ForceDirectories(edtRootFolder.Text);
    StartServer := True;
    btnConnectClick(Self);
  end;
end;

procedure TfrmServer.FormDestroy(Sender: TObject);
begin
  UnlockAdmin;
  FreeAndNil(AdminSystem);
end;

function TfrmServer.GetClientStat(sysClientRec: pClient_File_Rec;
  ForDate: TSTDate): ClientStat;
var
  Offset, P: Integer;

  function GetMonthsBetween(Date1, Date2: Integer): Integer;
  var
    D1, D2, M1, M2, Y1, Y2: Integer;
  begin
     StDatetoDMY(Date1, D1, M1, Y1);
     StDatetoDMY(Date2, D2, M2, Y2);
     Result := M2 - M1 + ((Y2 - Y1) * 12);
  end;

begin
  FillChar(Result,Sizeof(Result),rtNoData);
  if not Assigned(sysClientRec) then
    Exit;

  // how many months is the Client Rec out of step with the ForDate date...
  Offset := GetMonthsBetween(sysClientRec.cfLast_Processing_Status_Date, ForDate);
  Offset := Offset + 24;

  for P := 1 to 12 do
  begin
    if (P + Offset) in [1..36] then
    begin
      Result.Transferred[P] := TResultType(sysClientRec.cfTransferred[P + Offset]);
      Result.Finalized[P]   := TResultType(sysClientRec.cfFinalized [P + Offset]);
      Result.Coded[P]       := TResultType(sysClientRec.cfCoded [P + Offset]);
      Result.Downloaded[P]  := TResultType(sysClientRec.cfDownloaded [P + Offset]);
    end else if (P + Offset) < 1 then
    begin
      // May look better than NoData..
      Result.Transferred[P] := TResultType(sysClientRec.cfTransferred[1]);
      Result.Finalized[P]   := TResultType(sysClientRec.cfFinalized [1]);
      Result.Coded[P]       := TResultType(sysClientRec.cfCoded [1]);
      Result.Downloaded[P]  := TResultType(sysClientRec.cfDownloaded [1]);
    end;
  end;
end;

// incoming client request for download

procedure TfrmServer.httpServerCommandGet(Context: TIdContext;
  RequestInfo: TIdHTTPRequestInfo; ResponseInfo: TIdHTTPResponseInfo);
var
  I: Integer;
  RequestedDocument, FileName, CheckFileName: string;
  EHTMLParser: TPageProducer;
  ValidatedUser : Boolean;
  Response : TlkJSONobject;
begin
  ResponseInfo.ContentType := 'text/plain';
  // requested document
  RequestedDocument := RequestInfo.Document;

  // log request
  Log('Client: ' + RequestInfo.RemoteIP + ' request for: ' + RequestedDocument + '?' + RequestInfo.Params.Text);

  if (Pos('ValidateLogin' , RequestedDocument) > 0) then
  begin
    ValidatedUser := ValidatePracticeUser(RequestInfo.Params);

    if ValidatedUser then
    begin
      ResponseInfo.ContentText := 'User is valid';
      ResponseInfo.ResponseNo := 200;
    end
    else
    begin
      ResponseInfo.ResponseNo := 200;
      ResponseInfo.ContentText := 'User/Password is invalid';
    end;
  end
  else if (Pos('GetClients', RequestedDocument) > 0) then
  begin
    Response := TlkJSONobject.Create;
    BuildClientList(Response);
    ResponseInfo.ContentText := TlkJSON.GenerateText(Response);
    ResponseInfo.ResponseNo := 200;
  end;
  // 001
  if Copy(RequestedDocument, 1, 1) <> '/' then
    // invalid request
    raise Exception.Create('invalid request: ' + RequestedDocument);

  // 002
  // convert all '/' to '\'
  FileName := RequestedDocument;
  I := Pos('/', FileName);
  while I > 0 do
  begin
    FileName[I] := '\';
    I := Pos('/', FileName);
  end;
  // locate requested file
  FileName := edtRootFolder.Text + FileName;

  try
    // check whether file or folder was requested
    if AnsiLastChar(FileName)^ = '\' then
      // folder - reroute to default document
      CheckFileName := FileName + edtDefaultDoc.Text
    else
      // file - use it
      CheckFileName := FileName;
    if FileExists(CheckFileName) then
    begin
      // file exists
      if LowerCase(ExtractFileExt(CheckFileName)) = '.ehtm' then
      begin
        // Extended HTML - send through internal tag parser
        EHTMLParser := TPageProducer.Create(Self);
        try
          // set source file name
          EHTMLParser.HTMLFile := CheckFileName;
          // set event handler
          EHTMLParser.OnHTMLTag := pgpEHTMLHTMLTag;
          // parse !
          ResponseInfo.ContentText := EHTMLParser.Content;
        finally
          EHTMLParser.Free;
        end;
      end
      else
      begin
        // return file as-is
        // log
        Log('Returning Document: ' + CheckFileName);
        // open file stream
        ResponseInfo.ContentStream :=
          TFileStream.Create(CheckFileName, fmOpenRead or fmShareCompat);
      end;
    end;
  finally
    if Assigned(ResponseInfo.ContentStream) then
    begin
      // response stream does exist
      // set length
      ResponseInfo.ContentLength := ResponseInfo.ContentStream.Size;
      // write header
      ResponseInfo.WriteHeader;
      // return content
      ResponseInfo.WriteContent;
      // free stream
      ResponseInfo.ContentStream.Free;
      ResponseInfo.ContentStream := nil;
    end
    else if ResponseInfo.ContentText <> '' then
    begin
      // set length
      ResponseInfo.ContentLength := Length(ResponseInfo.ContentText);
      // write header
      ResponseInfo.WriteHeader;
      // return content
    end
    else
    begin
      if not ResponseInfo.HeaderHasBeenWritten then
      begin
        // set error code
        ResponseInfo.ResponseNo := 404;
        ResponseInfo.ResponseText := 'Document not found';
        // write header
        ResponseInfo.WriteHeader;
      end;
      // return content
      ResponseInfo.ContentText := 'The document requested is not availabe.';
      ResponseInfo.WriteContent;
    end;
  end;
end;

procedure TfrmServer.Log(Data: string);
begin
  lstLog.Items.Add(DateTimeToStr(Now) + ' - ' + Data);
end;

class function TfrmServer.LoginOnline(User: TUser_Rec; uName: String;
  var CurrentPassword: String; out Cancelled, OfflineAuthentication: Boolean;
  IgnoreOnlineUser: Boolean): Boolean;
begin

end;

class function TfrmServer.LoginOnline(UserCode, uName: String;
  var CurrentPassword: String; out Cancelled, OfflineAuthentication: Boolean;
  IgnoreOnlineUser: Boolean): Boolean;
begin

end;

function TfrmServer.Login(uName, pass: String; out Cancelled: Boolean): Boolean;
var
  OfflineAuthentication : Boolean;
begin
  Result := False;
  OfflineAuthentication := False;
  Password := pass;
  //Online enabled users must have a password
  if User.usAllow_Banklink_Online and (Trim(pass) = '') then
    Exit;

  if User.usAllow_Banklink_Online and ProductConfigService.ServiceActive then
  begin
    if LoginOnline(User^, uName, Password, Cancelled, OfflineAuthentication) then
      Result := True
    else
      Result := ValidateUserPassword(User^, Password);

    User := AdminSystem.fdSystem_User_List.FindCode(uName);
  end
  else
    Result := ValidateUserPassword(User^, Password);
end;

procedure TfrmServer.LogServerState;
begin
  if httpServer.Active then
    Log(httpServer.ServerSoftware + ' is active')
  else
    Log(httpServer.ServerSoftware + ' is not active');
end;

procedure TfrmServer.pgpEHTMLHTMLTag(Sender: TObject; Tag: TTag;
  const TagString: string; TagParams: TStrings; var ReplaceText: string);
var
  LTag: string;
begin
  LTag := LowerCase(TagString);
  if LTag = 'date' then
    ReplaceText := DateToStr(Now)
  else if LTag = 'time' then
    ReplaceText := TimeToStr(Now)
  else if LTag = 'datetime' then
    ReplaceText := DateTimeToStr(Now)
  else if LTag = 'server' then
    ReplaceText := httpServer.ServerSoftware;
end;

function TfrmServer.ValidatePracticeUser(Params : TStrings): Boolean;
var
  Cancelled: Boolean;
  uName, Pass : string;
  Index : Integer;
begin
  Result := False;
  {is this the superuser?}

  if Params.Count > 0 then
  begin
    if ((Pos('user', Params.Text) > 0) and (Pos('password', Params.Text) > 0)) then
    begin
      Index := Pos('=', Params.Strings[0]);
      uName := Copy(Params.Strings[0], Index + 1 , Length(Params.Strings[0]));
      Index := Pos('=', Params.Strings[1]);
      Pass := Copy(Params.Strings[1], Index + 1 , Length(Params.Strings[1]));
    end;
  end;

  if uName = SUPERUSER then
  begin
    user := nil;
    {validate special password - randomly g enerated}
    if (pass = SuperPwd) then
    begin
      Result := True;
      SuperUserLoggedIn := true;
      Exit;
    end;
  end;

  {first must find user in list}
  User := AdminSystem.fdSystem_User_List.FindCode( uName );
  if not Assigned(User) then
  begin
    WinUtils.ErrorSound;
    ShowMessage('Your Username and/or Password is invalid.  Please try again.');
    Exit;
  end;

  //UK only - don't allow login if the user doesn't have a password
  if (User.usPassword = '') and not User.usAllow_Banklink_Online then
  begin
   if AdminSystem.fdFields.fdCountry = whUK then begin
     ErrorSound;
     ShowMessage('You do not have a valid Password. Please see your administrator.');
     Close;
     Exit;
   end;
  end;

  if not Login(uName, pass, Cancelled) then
  begin
    if Cancelled then
    begin
      Exit;
    end
    else
    begin
      ErrorSound;
      ShowMessage('Your Username and/or Password is invalid.  Please try again.');
      Exit;
    end;
  end;
  Result := True;
end;

{ TClientDetails }
procedure TClientDetails.Write(const aJson: TlkJSONobject);
begin
  aJson.Add('code', FCode);
  aJson.Add('name', FName);
  aJson.Add('group', FGroup );
  aJson.Add('clienttype', FClientType);
  aJson.Add('status', FStatus);
  aJson.Add('lastaccessed', FloatToStr(FLastAccessed));
  aJson.Add('coded', FCoded);
  aJson.Add('finalized', FFinalized);
  aJson.Add('transferred', FTransferred);
  aJson.Add('downloaded', FDownloaded);
end;

{ TClients }

function TClients.ItemAs(aIndex: integer): TClientDetails;
begin
  Result := TClientDetails(Self.Items[aIndex]);
end;

procedure TClients.Write(const aJson: TlkJSONobject);
var
  Clients : TlkJSONlist;
  ClientJson : TlkJSONobject;
  ClientObj:  TClientDetails;
  i : Integer;
begin
  if Self.Count = 0 then
    Exit;

  Clients := TlkJSONlist.Create;
  aJson.Add('Clients', Clients);

  for i := 0 to Self.Count-1 do
  begin
    ClientJson := TlkJSONobject.Create;

    ClientObj := ItemAs(i);
    ClientObj.Write(ClientJson);

    Clients.Add(ClientJson);
  end;
end;

end.
