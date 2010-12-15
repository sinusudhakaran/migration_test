library DownloadConverter;

uses
  ComServ,
  DownloadConverter_TLB in 'DownloadConverter_TLB.pas',
  FileConverter in 'FileConverter.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer;

{$R *.TLB}

{$R *.RES}

begin
end.
