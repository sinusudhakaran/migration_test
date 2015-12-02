unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  PracticeServer;

const
  SERVER_CONFIGURATION_FILE = 'PracticeApplicationService.ini';
  
type
  TPracticeApplicationServer = class(TService)
    procedure ServiceAfterInstall(Sender: TService);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
    procedure ServiceShutdown(Sender: TService);
  private
    m_PracticeServer: TPracticeServer;

    procedure ConfigureServer;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  PracticeApplicationServer: TPracticeApplicationServer;

implementation

uses
  Registry, IniFiles, StrUtils, Forms;

{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  PracticeApplicationServer.Controller(CtrlCode);
end;

procedure TPracticeApplicationServer.ConfigureServer;
var
  ConfigurationFile: TIniFile;
  FullPath: String;
begin
  FullPath := ExtractFileDir(Forms.Application.ExeName) + '\' + SERVER_CONFIGURATION_FILE;

  if FileExists(FullPath) then
  begin
    ConfigurationFile := TIniFile.Create(FullPath);

    try
      m_PracticeServer.Port := ConfigurationFile.ReadInteger('Configuration', 'ServerPort', 0);
      m_PracticeServer.DiscoveryPort := ConfigurationFile.ReadInteger('Configuration', 'DiscoveryPort', 0);
      m_PracticeServer.MaxConnections := ConfigurationFile.ReadInteger('Configuration', 'MaxConnections', 0);
      m_PracticeServer.ListenQueueSize := ConfigurationFile.ReadInteger('Configuration', 'ListenQueueSize', 15);
    finally
      ConfigurationFile.Free;
    end;
  end;
end;

function TPracticeApplicationServer.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TPracticeApplicationServer.ServiceAfterInstall(Sender: TService);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_READ or KEY_WRITE);
  
  try
    Reg.RootKey := HKEY_LOCAL_MACHINE;
    
    if Reg.OpenKey('\SYSTEM\CurrentControlSet\Services\' + Name, false) then
    begin
      Reg.WriteString('Description', 'Practice Application Service.');
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure TPracticeApplicationServer.ServiceCreate(Sender: TObject);
begin
  m_PracticeServer := TPracticeServer.Create;
end;

procedure TPracticeApplicationServer.ServiceDestroy(Sender: TObject);
begin
  m_PracticeServer.Free;
end;

procedure TPracticeApplicationServer.ServiceShutdown(Sender: TService);
begin
  m_PracticeServer.Stop;
end;

procedure TPracticeApplicationServer.ServiceStart(Sender: TService;
  var Started: Boolean);
begin
  ConfigureServer;

  m_PracticeServer.Start;
end;

procedure TPracticeApplicationServer.ServiceStop(Sender: TService;
  var Stopped: Boolean);
begin
  m_PracticeServer.Stop;
end;

end.
