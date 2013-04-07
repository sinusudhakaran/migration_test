program Muddler;

{$DEFINE Practice-7}

uses
  Forms,
  Mainform in 'Mainform.pas' {formMain},
  Muddle in 'Muddle.pas',
  DataGenerator in 'DataGenerator.pas',
  SysUtils,
  LockUtils;

var
  MuddlerTemp : TMuddler;

{$R *.res}
begin
  if ParamCount = 1 then
  begin
    // A full path of the New BK5Exe is passed and the Muddler will add it
    // into the Muddler.dat file
    MuddlerTemp := TMuddler.Create;
    try
      MuddlerTemp.AddBk5ExeToDataFile(ParamStr(1));
    finally
      FreeAndNil(MuddlerTemp);
    end;

    Exit;
  end;

  InitLocking;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Practice Data Muddler';
  Application.CreateForm(TformMain, formMain);
  Application.Run;
end.
