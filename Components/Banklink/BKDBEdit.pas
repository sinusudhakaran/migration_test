unit BKDBEdit;

interface

uses
  SysUtils, Classes, Controls, StdCtrls, Mask, RzEdit, RzDBEdit, Windows, DB;

type
  TBKDBEdit = class(TRzDBEdit)
  protected
    procedure CMExit( var Msg: TCMExit ); message cm_Exit;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKDBEdit]);
end;

{ TBKDBEdit }

{Case 8129 - Allow the user to clear the masked field!!!}

procedure TBKDBEdit.CMExit(var Msg: TCMExit);
begin
  if Assigned(Field) and (Self.EditMask <> '') and (Self.Text = '') then
  begin
    if Field.IsNull = False then
      Field.Clear;
  end;

  Inherited;
end;

end.
