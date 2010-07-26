program bkmap;

uses
  Forms,
  frmMapChecker in 'frmMapChecker.pas' {MainForm},
  imagesfrm in '..\imagesfrm.pas' {AppImages};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'BK Map';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TAppImages, AppImages);
  Application.Run;
end.
