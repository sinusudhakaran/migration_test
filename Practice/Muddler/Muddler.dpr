program Muddler;

uses
  Forms,
  Mainform in 'Mainform.pas' {formMain},
  Muddle in 'Muddle.pas',
  DataGenerator in 'DataGenerator.pas',
  SysUtils;

var
  MuddlerTemp : TMuddler;

{$R *.res}
begin
  if ParamCount = 1 then
  begin
    MuddlerTemp := TMuddler.Create;
    try
      MuddlerTemp.AddBk5ExeToDataFile(ParamStr(1));
    finally
      FreeAndNil(MuddlerTemp);
    end;

    Exit;
  end;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Practice Data Muddler';
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
