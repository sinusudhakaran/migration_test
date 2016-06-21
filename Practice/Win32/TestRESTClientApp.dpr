program TestRESTClientApp;

uses
  Forms,
  UFrmTestRESTClient in 'UFrmTestRESTClient.pas' {Form4},
  BaseRESTClient in 'BaseRESTClient.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm4, Form4);
  Application.Run;
end.
