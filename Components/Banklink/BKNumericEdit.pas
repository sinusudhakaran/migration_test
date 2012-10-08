unit BKNumericEdit;

interface

uses
  Windows, Messages, Classes, StdCtrls, Clipbrd, SysUtils;

type
  TBKNumericEdit = class(TEdit)
  protected
    procedure KeyPress(var Key: Char); override;
    procedure WMPaste(var Message: TMessage); message WM_PASTE;
  end;
  
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKNumericEdit]);
end;

{ TBKNumericEdit }

procedure TBKNumericEdit.KeyPress(var Key: Char);
begin
  inherited KeyPress(Key);
  
  if not (Key in['0'..'9', #1, #3, #8, #22, #24, #26]) then
  begin
    Key := #0;
  end;
end;

procedure TBKNumericEdit.WMPaste(var Message: TMessage);
var
  Value: Integer;
begin
  Clipboard.Open;

  if TryStrToInt(Clipboard.AsText, Value) then
  begin
    Text := IntToStr(Value);
  end;

  Clipboard.Close;
end;

end.
