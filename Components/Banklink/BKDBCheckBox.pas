unit BKDBCheckBox;

interface

uses
  SysUtils, Classes, Controls, RzButton, RzRadChk, RzDBChk;

type
  TBKDBCheckBox = class(TRzDBCheckBox)
  private
    FChanged: boolean;

    function GetCurrentValue: boolean;
    procedure SetCurrentValue(const Value: boolean);
    { Private declarations }
  protected
    { Protected declarations }
    procedure Loaded; override;
    procedure Click; override;
  public
    { Public declarations }
    property Changed: boolean read FChanged write FChanged;
  published
    { Published declarations }
    property CurrentValue : boolean read GetCurrentValue write SetCurrentValue;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('BankLink', [TBKDBCheckBox]);
end;

{ TBKDBCheckBox }

function TBKDBCheckBox.GetCurrentValue: boolean;
begin
  Result := false;
  if Assigned (Field) then
    Result := Field.AsBoolean;
end;

procedure TBKDBCheckBox.SetCurrentValue(const Value: boolean);
begin
  if Assigned (Field) then
    if Field.AsBoolean <> Value then
      Field.AsBoolean := Value;
end;

procedure TBKDBCheckBox.Click;
begin
  inherited;

  FChanged:=True;
end;

procedure TBKDBCheckBox.Loaded;
begin
  inherited;

  FChanged:=False;
end;

end.
