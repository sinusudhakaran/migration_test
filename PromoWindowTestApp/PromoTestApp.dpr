program PromoTestApp;

uses
  Forms,
  OptionsScreenFrm in 'OptionsScreenFrm.pas' {FrmOptionsScreen};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmOptionsScreen, FrmOptionsScreen);
  Application.Run;
end.
