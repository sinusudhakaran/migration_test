program Muddler;

uses
  Forms,
  Mainform in 'Mainform.pas' {formMain},
  Muddle in 'Muddle.pas',
  DataGenerator in 'DataGenerator.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Practice Data Muddler';
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
