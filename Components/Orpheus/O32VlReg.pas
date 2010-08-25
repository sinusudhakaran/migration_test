{*********************************************************}
{*                    O32VLREG.PAS 4.05                  *}
{*     COPYRIGHT (C) 1995-2002 TurboPower Software Co    *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit o32vlreg;
  {Registration unit for the Orpheus Validator components.}

interface

uses
  Classes, O32Vldtr;

var
  ValidatorList: TStrings;

procedure RegisterValidator(ValidatorClass: TValidatorClass);
procedure UnRegisterValidator(ValidatorClass: TValidatorClass);
procedure GetRegisteredValidators(aList: TStrings);

implementation

procedure RegisterValidator(ValidatorClass: TValidatorClass);
begin
  if ValidatorClass.InheritsFrom(TO32BaseValidator) then begin
    if ValidatorList.IndexOf(ValidatorClass.ClassName) = -1 then begin
      RegisterClass(TPersistentClass(ValidatorClass));
      ValidatorList.Add(ValidatorClass.ClassName);
    end;
  end;
end;
{=====}

procedure UnRegisterValidator(ValidatorClass: TValidatorClass);
var
  i: Integer;
begin
  i := ValidatorList.IndexOf(ValidatorClass.ClassName);
  if i > -1 then begin
    ValidatorList.Delete(i);
    UnRegisterClass(TPersistentClass(ValidatorClass));
  end;
end;
{=====}

procedure GetRegisteredValidators(aList: TStrings);
begin
  Assert(Assigned(ValidatorList));
  Assert(Assigned(aList));

  aList.Clear;
  aList.BeginUpdate;
  aList.Assign(ValidatorList);
  aList.EndUpdate;
end;

initialization

  ValidatorList := TStringList.Create;
  ValidatorList.Add('None');


finalization

  ValidatorList.Free;

end.
