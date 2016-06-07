unit srvMain;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  Messages,
  SysUtils,
  Classes,
  Graphics,
  Controls,
  SvcMgr,
  Dialogs,
  UsageDataImporter;

type
  //----------------------------------------------------------------------------
  TMainService = class(TService)
    procedure ServiceBeforeInstall(Sender: TService);
    procedure ServiceBeforeUninstall(Sender: TService);
    procedure ServiceContinue(Sender: TService; var Continued: Boolean);
    procedure ServiceCreate(Sender: TObject);
    procedure ServiceDestroy(Sender: TObject);
    procedure ServiceExecute(Sender: TService);
    procedure ServicePause(Sender: TService; var Paused: Boolean);
    procedure ServiceShutdown(Sender: TService);
    procedure ServiceStart(Sender: TService; var Started: Boolean);
    procedure ServiceStop(Sender: TService; var Stopped: Boolean);
  private
    fUsageDataImporter : TUsageDataImporter;
  protected
    procedure ConfigureServer;
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

var
  MainService: TMainService;

//------------------------------------------------------------------------------
implementation

uses
  Forms,
  IniFiles,
  SysUtils;

const
  SERVICE_CONFIGURATION_FILE = 'UsageService.ini';

{$R *.DFM}
//------------------------------------------------------------------------------
procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  MainService.Controller(CtrlCode);
end;

//------------------------------------------------------------------------------
procedure TMainService.ConfigureServer;
var
  ConfigurationFile: TIniFile;
  FullPath: String;
begin
  FullPath := ExtractFileDir(Forms.Application.ExeName) + '\' + SERVICE_CONFIGURATION_FILE;

  if FileExists(FullPath) then
  begin
    ConfigurationFile := TIniFile.Create(FullPath);

    try
      fUsageDataImporter.HostName := ConfigurationFile.ReadInteger('Configuration', 'HostName', '');
      fUsageDataImporter.Database := ConfigurationFile.ReadInteger('Configuration', 'Database', '');
      fUsageDataImporter.UserName := ConfigurationFile.ReadInteger('Configuration', 'UserName', '');
      fUsageDataImporter.Password := ConfigurationFile.ReadInteger('Configuration', 'Password', '');
    finally
      ConfigurationFile.Free;
    end;
  end;
end;

//------------------------------------------------------------------------------
function TMainService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceBeforeInstall(Sender: TService);
begin
  fUsageDataImporter.Stop();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceBeforeUninstall(Sender: TService);
begin
  fUsageDataImporter.Stop();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceContinue(Sender: TService; var Continued: Boolean);
begin
  fUsageDataImporter.Start();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceCreate(Sender: TObject);
begin
  fUsageDataImporter := TUsageDataImporter.Create;
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceDestroy(Sender: TObject);
begin
  FreeAndNil(fUsageDataImporter);
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceExecute(Sender: TService);
begin
  fUsageDataImporter.Start();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServicePause(Sender: TService; var Paused: Boolean);
begin
  fUsageDataImporter.Stop();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceShutdown(Sender: TService);
begin
  fUsageDataImporter.Stop();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceStart(Sender: TService; var Started: Boolean);
begin
  fUsageDataImporter.Start();
end;

//------------------------------------------------------------------------------
procedure TMainService.ServiceStop(Sender: TService; var Stopped: Boolean);
begin
  fUsageDataImpoter.Stop();
end;

end.
