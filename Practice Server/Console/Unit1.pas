unit Unit1;

interface

uses
  Windows, Messages, SysUtils, StrUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, Contnrs, TypInfo,
  PracticeTCPClient, Menus, IdBaseComponent, IdWship6, IdWinSock2;

const
  SETTINGS_SECTION = 'SETTINGS';
  
  DEFAULT_DISCOVERY_PORT = 4323;
  DEFAULT_STATISTICS_INTERVAL = 500;
  DEFAULT_STATISTICS_ENABLED = False;
  DEFAULT_AUTOCONNECT = False;
  DEFAULT_AUTODISCOVERY = True;

  UM_AFTERSHOW = WM_USER + 1;
  
type
  TForm1 = class(TForm)
    StatusBar: TStatusBar;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Label2: TLabel;
    Label3: TLabel;
    btnConnect: TButton;
    chkStatistics: TCheckBox;
    chkEnableLogging: TCheckBox;
    edtStatsInterval: TEdit;
    edtDiscoveryPort: TEdit;
    Timer1: TTimer;                   
    Panel2: TPanel;
    lvConnectionList: TListView;
    Label1: TLabel;
    Panel3: TPanel;
    lvLockQueue: TListView;
    Label5: TLabel;
    Label4: TLabel;
    MainMenu1: TMainMenu;
    ools1: TMenuItem;
    Clearlockqueue1: TMenuItem;
    Disconnectionallusers1: TMenuItem;
    Releaseallheldlocks1: TMenuItem;
    Disconnectselecteduser1: TMenuItem;
    Removeselectedlock1: TMenuItem;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    RemoveLock1: TMenuItem;
    Disconnectselecteduser2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure chkStatisticsClick(Sender: TObject);
    procedure chkEnableLoggingClick(Sender: TObject);
    procedure Disconnectionallusers1Click(Sender: TObject);
    procedure Releaseallheldlocks1Click(Sender: TObject);
    procedure Clearlockqueue1Click(Sender: TObject);
    procedure Disconnectselecteduser1Click(Sender: TObject);
    procedure Removeselectedlock1Click(Sender: TObject);
    procedure Disconnectselecteduser2Click(Sender: TObject);
    procedure RemoveLock1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    m_Client: TPracticeTCPClient;

    m_Disconnecting: Boolean;

    m_AutoConnect: Boolean;
    m_AutoDiscovery: Boolean;
    m_ServerAddress: String;
    m_ServerPort: Integer;

    FLockSection: TRTLCriticalSection;

    function ConnectToServer: Boolean;

    function GetSettingsFileName: String;
    function LoadSettings: Boolean;
    procedure SaveSettings;

    function ResolveHostName: string;

    procedure DoDisconnect;

    procedure SendUserInfo;
    procedure SyncWithServerSettings;

    procedure RefreshStatistics;

    procedure OnDisconnected(Sender: TObject);

    procedure UMAfterShow(var Message: TMessage); message UM_AFTERSHOW;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  PracticeClientServer, DateUtils, Math, IniFiles;

{$R *.dfm}

procedure TForm1.btnConnectClick(Sender: TObject);
var
  DiscoveryPort: Integer;
begin
  btnConnect.Enabled := False;

  try
    Application.ProcessMessages;
    
    if not m_Client.Connected then
    begin
      StatusBar.Panels[0].Text := 'Connecting...';

      try
        Application.ProcessMessages;

        if not TryStrToInt(edtDiscoveryPort.Text, DiscoveryPort) then
        begin
          DiscoveryPort := DEFAULT_DISCOVERY_PORT;

          edtDiscoveryPort.Text := IntToStr(DEFAULT_DISCOVERY_PORT);
        end;

        m_Client.UDPPort := DiscoveryPort;

        m_Client.OnDisconnected := OnDisconnected;

        if ConnectToServer then
        begin
          edtDiscoveryPort.Enabled := False;

          SendUserInfo;

          SyncWithServerSettings;

          btnConnect.Caption := 'Disconnect';

          StatusBar.Panels[0].Text := Format('Connected to %s (%s:%s)', [ResolveHostName, m_Client.Host, IntToStr(m_Client.Port)]);

          chkEnableLogging.Enabled := True;

          if chkStatistics.Checked then
          begin
            RefreshStatistics;
          end;

          Timer1.Enabled := chkStatistics.Checked;
        end;
      finally
        if not m_Client.Connected then
        begin
          StatusBar.Panels[0].Text := 'Disconnected';
        end;
      end;
    end
    else
    begin
      EnterCriticalSection(FLockSection);

      try
        m_Disconnecting := True;

        try
          m_Client.Disconnect;
        finally
          m_Disconnecting := False;
        end;
      finally
        LeaveCriticalSection(FLockSection);
      end;
    end;
  finally
    btnConnect.Enabled := True;
  end;
end;

procedure TForm1.chkStatisticsClick(Sender: TObject);
var
  Interval: Integer;
begin
  if chkStatistics.Checked then
  begin
    if TryStrToInt(edtStatsInterval.Text, Interval) then
    begin
      Timer1.Interval := Interval;
    end
    else
    begin
      Timer1.Interval := DEFAULT_STATISTICS_INTERVAL;

      edtStatsInterval.Text := IntToStr(DEFAULT_STATISTICS_INTERVAL);
    end;

    RefreshStatistics;
  end
  else
  begin
    lvLockQueue.Clear;
    lvConnectionList.Clear;
  end;

  edtStatsInterval.Enabled := not chkStatistics.Checked;

  Timer1.Enabled := chkStatistics.Checked;
end;

procedure TForm1.chkEnableLoggingClick(Sender: TObject);
var
  Request: TRequest;
begin
  if m_Client.Connected then
  begin
    Request.RequestType := rtLoggingRequest;
    Request.LoggingEnabled := chkEnableLogging.Checked;

    m_Client.SendRequest(0, Request);
  end;
end;

procedure TForm1.Clearlockqueue1Click(Sender: TObject);
begin
  if m_Client.Connected then
  begin
    if MessageDlg('This remove all aquired and waiting locks from the queue.  Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      m_Client.SendRequest(0, rtClearLockQueue);
    end;
  end
  else
  begin
  end;
end;

function TForm1.ConnectToServer: Boolean;
begin
  if m_AutoDiscovery then
  begin
    Result := m_Client.Connect;
  end
  else
  begin
    Result := m_Client.Connect(m_ServerAddress, m_ServerPort);
  end;
end;

procedure TForm1.Disconnectionallusers1Click(Sender: TObject);
begin
  if m_Client.Connected then
  begin
    if MessageDlg('This will disconnect all users from the server.  Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      m_Client.SendRequest(0, rtDisconnectAllUsers);
    end;
  end
  else
  begin
  end;
end;

procedure TForm1.Disconnectselecteduser1Click(Sender: TObject);
var
  Request: TRequest;
begin
  if m_Client.Connected then
  begin
    if MessageDlg('This will disconnect the selected user from the server.  Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      EnterCriticalSection(FLockSection);

      try
        if Assigned(lvConnectionlist.Selected) then
        begin
          Request.RequestType := rtDisconnectUser;
          Request.DisconnectionUserCommand.Identifier := ULongLong(lvConnectionList.Selected.Data);

          m_Client.SendRequest(0, Request);
        end;
      finally
        LeaveCriticalSection(FLockSection);
      end;
    end;
  end
  else
  begin
  end;
end;

procedure TForm1.Disconnectselecteduser2Click(Sender: TObject);
begin
  Disconnectselecteduser1Click(Sender);
end;

procedure TForm1.DoDisconnect;
begin
  Timer1.Enabled := False;
  
  lvLockQueue.Clear;
  lvConnectionList.Clear;

  btnConnect.Caption := 'Connect';

  StatusBar.Panels[0].Text := 'Disconnected';
  StatusBar.Panels[1].Text := 'Queue Count: 0';
  StatusBar.Panels[2].Text := 'Connection Count: 0';

  edtDiscoveryPort.Enabled := True;

  chkEnableLogging.Enabled := False;

  lvConnectionList.Clear;
  lvLockQueue.Clear;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  InitializeCriticalSection(FLockSection);
  
  m_Client := TPracticeTCPClient.Create;

  m_Client.AppVersion := '1.0.0.0';

  m_Disconnecting := False;

  m_AutoDiscovery := DEFAULT_AUTODISCOVERY;
  m_ServerAddress := '';
  m_ServerPort := 0;

  m_AutoConnect := DEFAULT_AUTOCONNECT;

  LoadSettings;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  SaveSettings;

  m_Client.Free;

  DeleteCriticalSection(FLockSection);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  PostMessage(Handle, UM_AFTERSHOW, 0, 0);
end;

function TForm1.GetSettingsFileName: String;
begin
  Result := ReplaceStr(Application.ExeName, '.exe', '.ini');
end;

function TForm1.LoadSettings: Boolean;
var
  SettingsFileName: String;
  SettingsFile: TIniFile;
begin
  Result := False;
  
  SettingsFileName := GetSettingsFileName;
  
  if FileExists(SettingsFileName) then
  begin
    SettingsFile := TIniFile.Create(SettingsFileName);

    try
      if SettingsFile.SectionExists(SETTINGS_SECTION) then
      begin
        edtDiscoveryPort.Text := IntToStr(SettingsFile.ReadInteger(SETTINGS_SECTION, 'DiscoveryPort', DEFAULT_DISCOVERY_PORT));
        edtStatsInterval.Text := IntToStr(SettingsFile.ReadInteger(SETTINGS_SECTION, 'StatisticsInterval', DEFAULT_STATISTICS_INTERVAL));
        chkStatistics.Checked := SettingsFile.ReadBool(SETTINGS_SECTION, 'StatisticsEnabled', DEFAULT_STATISTICS_ENABLED);
        
        m_AutoConnect := SettingsFile.ReadBool(SETTINGS_SECTION, 'AutoConnect', DEFAULT_AUTOCONNECT);
        m_AutoDiscovery := SettingsFile.ReadBool(SETTINGS_SECTION, 'AutoDiscovery', DEFAULT_AUTODISCOVERY);
        m_ServerAddress := SettingsFile.ReadString(SETTINGS_SECTION, 'TCPServerIP', '');
        m_ServerPort := SettingsFile.ReadInteger(SETTINGS_SECTION, 'TCPServerPort', 0);

        Result := True;
      end;
    finally
      SettingsFile.Free;
    end;
  end;
end;

procedure TForm1.OnDisconnected(Sender: TObject);
begin
  DoDisconnect;
end;

procedure TForm1.RefreshStatistics;

var
  ConnectionList: array of ULongLong;
  LockList: array of ULongLong;

  function NewConnection(Identifier: ULongLong): TListItem;
  var
    Index: Integer;
    Item: TListItem;
  begin
    Result := nil;

    for Index := 0 to lvConnectionList.Items.Count - 1 do
    begin
      Item := lvConnectionList.Items[Index];

      if ULongLong(Item.Data) = Identifier then
      begin
        Result := Item;

        Break;
      end;
    end;
  end;

  function ConnectionDisconnected(Identifier: ULongLong): Boolean;
  var
    Index : Integer;
  begin
    Result := True;

    for Index := 0 to Length(ConnectionList) - 1 do
    begin
      if ConnectionList[Index] = Identifier then
      begin
        Result := False;

        Break;
      end;
    end;
  end;

  function FindLock(Identifier: UlongLong): TListItem;
  var
    Index: Integer;
    Item: TListItem;
  begin
    Result := nil;

    for Index := 0 to lvLockQueue.Items.Count - 1 do
    begin
      Item := lvLockQueue.Items[Index];

      if ULongLong(Item.Data) = Identifier then
      begin
        Result := Item;

        Break;
      end;
    end;
  end;

  function LockReleased(Identifier: ULongLong): Boolean;
  var
    Index : Integer;
  begin
    Result := True;

    for Index := 0 to Length(LockList) - 1 do
    begin
      if LockList[Index] = Identifier then
      begin
        Result := False;

        Break;
      end;
    end;
  end;

var
  Index: Integer;
  Item: TListItem;
  Request: TRequest;
  Response: TResponse;
  Statistics: TStream;
  ConnectionInfo: TConnectionInfo;
  LockInfo: TLockInfo;
  WaitTime: Integer;
  RequestId: DWord;
begin
  if TryEnterCriticalSection(FLockSection) then
  begin
    try
      if m_Client.Connected and not m_Disconnecting then
      begin
        try
          Request.RequestType := rtStatisticsRequest;

          m_Client.SendRequest(0, Request);

          m_Client.ReceiveResponse(RequestId, Response);

          if Response.ResponseType = rtStatisticsResponse then
          begin
            Statistics := TMemoryStream.Create;

            try
              m_Client.ReceiveStream(Statistics, Response.StreamSize);

              if Statistics.Size > 0 then
              begin
                Statistics.Position := 0;

                SetLength(ConnectionList, Response.ConnectionCount);

                for Index := 0 to Response.ConnectionCount - 1 do
                begin
                  Statistics.Read(ConnectionInfo, SizeOf(ConnectionInfo));

                  if CompareText(ConnectionInfo.UserCode, 'Console') <> 0 then
                  begin
                    Item :=  NewConnection(ConnectionInfo.Identifier);

                    if Item = nil then
                    begin
                      Item := lvConnectionList.Items.Add;

                      Item.Caption := ConnectionInfo.IpAddress;

                      Item.Data := Pointer(ConnectionInfo.Identifier);
                    end;

                    Item.SubItems.Clear;

                    Item.SubItems.Add(ConnectionInfo.UserCode);
                    Item.SubItems.Add(ConnectionInfo.WorkstationName);
                    Item.SubItems.Add(ConnectionInfo.GroupId); 

                    ConnectionList[Index] := ConnectionInfo.Identifier;
                  end;
                end;

                Index := 0;

                while (Index < lvConnectionList.Items.Count) and (lvConnectionList.Items.Count > 0) do
                begin
                  if ConnectionDisconnected(ULongLong(lvConnectionList.Items[Index].Data)) then
                  begin
                    lvConnectionList.Items.Delete(Index);
                  end
                  else
                  begin
                    Inc(Index);
                  end;
                end;

                SetLength(LockList, Response.LockQueueCount);
              
                for Index := 0 to Response.LockQueueCount - 1 do
                begin
                  Statistics.Read(LockInfo, SizeOf(TLockInfo));

                  Item := FindLock(LockInfo.Identifier);

                  if Item = nil then
                  begin
                    Item := lvLockQueue.Items.Add;

                    Item.Caption := LockInfo.IpAddress;

                    Item.Data := Pointer(LockInfo.Identifier);
                  end;

                  Item.SubItems.Clear;

                  Item.SubItems.Add(LockInfo.GroupId); 
                  Item.SubItems.Add(IntToStr(LockInfo.LockType));
                  Item.SubItems.Add(GetEnumName(TypeInfo(TLockStatus), Integer(LockInfo.LockStatus)));

                  if LockInfo.LockStatus = lsAquired then
                  begin
                    WaitTime := MillisecondsBetween(LockInfo.TimeAquired, LockInfo.TimeCreated);
                  end
                  else
                  begin
                    WaitTime := MillisecondsBetween(Now, LockInfo.TimeCreated);
                  end;

                  Item.SubItems.Add(IntToStr(WaitTime));

                  LockList[Index] := LockInfo.Identifier;
                end;

                Index := 0;

                while (Index < lvlockQueue.Items.Count) and (lvlockQueue.Items.Count > 0) do
                begin
                  if LockReleased(ULongLong(lvlockQueue.Items[Index].Data)) then
                  begin
                    lvlockQueue.Items.Delete(Index);
                  end
                  else
                  begin
                    Inc(Index);
                  end;
                end;

                StatusBar.Panels[1].Text := Format('Queue Count: %s', [IntToStr(Response.LockQueueCount)]);

                StatusBar.Panels[2].Text := Format('Connection Count: %s', [IntToStr(lvConnectionList.Items.Count)]);
              end;
            finally
              Statistics.Free;
            end;
          end;
        except
          m_Client.Disconnect;
        end;
      end;
    finally
      LeaveCriticalSection(FLockSection);
    end;
  end;
end;

procedure TForm1.Releaseallheldlocks1Click(Sender: TObject);
begin
  if m_Client.Connected then
  begin
    if MessageDlg('This will release all aquired locks.  Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      m_Client.SendRequest(0, rtReleaseAllLocks);
    end;
  end
  else
  begin
  end;
end;

procedure TForm1.RemoveLock1Click(Sender: TObject);
begin
  Removeselectedlock1Click(Sender);
end;

procedure TForm1.Removeselectedlock1Click(Sender: TObject);
var
  Request: TRequest;
begin
  if m_Client.Connected then
  begin
    if MessageDlg('This will remove the selected lock from the server.  Continue?', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      EnterCriticalSection(FLockSection);

      try
        if Assigned(lvLockQueue.Selected) then
        begin
          Request.RequestType := rtRemoveLock;
          Request.RemoveLockCommand.Identifier := ULongLong(lvLockQueue.Selected.Data);
      
          m_Client.SendRequest(0, Request);
        end;
      finally
        LeaveCriticalSection(FLockSection);
      end;
    end;
  end
  else
  begin
  end;
end;                                                                

function TForm1.ResolveHostName: string;
var
  Host: PHostEnt;
  LAddr: u_long;
begin
  LAddr := inet_addr(PChar(m_Client.Host));

  Host := GetHostByAddr(@LAddr, SizeOf(LAddr), AF_INET);

  if Host <> nil then
  begin
    Result := Host^.h_name;
  end;
end;

procedure TForm1.SaveSettings;
var
  SettingsFile: TIniFile;
begin
  SettingsFile := TIniFile.Create(GetSettingsFileName); 

  try
    SettingsFile.WriteInteger(SETTINGS_SECTION, 'DiscoveryPort', StrToIntDef(edtDiscoveryPort.Text, DEFAULT_DISCOVERY_PORT));
    SettingsFile.WriteInteger(SETTINGS_SECTION, 'StatisticsInterval', StrToIntDef(edtStatsInterval.Text, DEFAULT_STATISTICS_INTERVAL));
    SettingsFile.WriteBool(SETTINGS_SECTION, 'StatisticsEnabled', chkStatistics.Checked);
    SettingsFile.WriteBool(SETTINGS_SECTION, 'AutoConnect', m_Client.Connected);
  finally
    SettingsFile.Free;
  end;
end;

procedure TForm1.SendUserInfo;
var
  Request: TRequest;
begin
  Request.RequestType := rtUserLogin;
  Request.UserLoginCommand.UserCode := 'Console';

  StringToCharArray(GetWorkstationName, Request.UserLoginCommand.Workstation);

  m_Client.SendRequest(0, Request);
end;

procedure TForm1.SyncWithServerSettings;
var
  Response: TResponse;
  RequestId: DWord;
begin
  if m_Client.Connected then
  begin
    if m_Client.SendRequest(0, rtSettingsRequest) then
    begin
      if m_Client.ReceiveResponse(RequestId, Response) then
      begin
        chkEnableLogging.Checked := Response.SettingsResult.LoggingEnabled;
      end;
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  try
    RefreshStatistics;
  finally
    Timer1.Enabled := True;
  end;
end;

procedure TForm1.UMAfterShow(var Message: TMessage);
begin
  if m_AutoConnect then
  begin
    btnConnect.Click();
  end;
end;

end.
