unit MaskValidateEdit;

//------------------------------------------------------------------------------
interface

uses
  Windows,
  SysUtils,
  Classes,
  StdCtrls,
  ExtCtrls,
  Mask;

type
  TValidateError = procedure (var aRaiseError : Boolean) of object;
  TValidateEdit = procedure (var aRunExistingValidate : Boolean) of object;

  //----------------------------------------------------------------------------
  TMaskValidateEdit = class(TMaskEdit)
  private
    fValidateError : TValidateError;
    fValidateEdit : TValidateEdit;
  protected
    procedure ValidateError; Override;
  public
    procedure ValidateEdit; Override;

    function DoValidation : boolean;
  published
    property OnValidateError : TValidateError read fValidateError write fValidateError;
    property OnValidateEdit  : TValidateEdit  read fValidateEdit  write fValidateEdit;
  end;

//------------------------------------------------------------------------------
procedure Register;

//------------------------------------------------------------------------------
implementation

//------------------------------------------------------------------------------
procedure Register;
begin
  RegisterComponents('BankLink', [TMaskValidateEdit]);
end;

{ TMaskValidateEdit }
//------------------------------------------------------------------------------
function TMaskValidateEdit.DoValidation : boolean;
var
  Str: string;
  Pos: Integer;
begin
  Result := false;
  Str := EditText;
  if IsMasked and Modified then
  begin
    if not Validate(Str, Pos) then
      Result := true;
  end;
end;

//------------------------------------------------------------------------------
procedure TMaskValidateEdit.ValidateEdit;
var
  RunExistingValidate : Boolean;
begin
  RunExistingValidate := true;

  if Assigned(fValidateEdit) then
    fValidateEdit(RunExistingValidate);

  if RunExistingValidate then
    inherited;
end;

//------------------------------------------------------------------------------
procedure TMaskValidateEdit.ValidateError;
var
  RaiseError : Boolean;
begin
  RaiseError := true;

  if Assigned(fValidateError) then
    fValidateError(RaiseError);

  if RaiseError then
    inherited;
end;

end.
