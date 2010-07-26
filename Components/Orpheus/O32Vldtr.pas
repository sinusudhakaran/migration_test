{*********************************************************}
{*                    O32VLDTR.PAS 4.05                  *}
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

unit o32vldtr;
  {-Base classes for the TO32Validator and descendant components}

{
TO32BaseValidator is the abstract ancestor for all Orpheus Validator components
Descendants must override SetInput, SetMask, GetValid and IsValid plus define
the validation to provide full functionality.

Descendant classes which call the RegisterValidator and UnRegisterValidator
procedures in their unit's Initialization and Finalization sections will be
available as a selection in the ValidatorType property of components that use
validators internally.
}

interface

uses
  Windows, Classes, OvcBase;

type
  TValidationEvent = (veOnChange, veOnEnter, veOnExit);

  TValidatorErrorEvent =
    procedure(Sender: TObject; const ErrorMsg: string) of object;

  TValidatorClass = class of TO32BaseValidator;

  TO32BaseValidator = class(TO32Component)
  protected {private}
    {property variables}
    FBeforeValidation   : TNotifyEvent;
    FAfterValidation    : TNotifyEvent;
    FOnUserValidation   : TNotifyEvent;
    FOnErrorEvent       : TValidatorErrorEvent;

    FInput              : string;
    FMask               : string;
    FValid              : boolean ;
    FErrorCode          : Word;
    FSampleMaskLength   : Word;
    FSampleMasks        : TStringList;

    procedure SetAbout(const Value: string);
    procedure SetInput(const Value: string); virtual; abstract;
    procedure SetMask(const Value: string); virtual; abstract;
    procedure SetValid(Value: boolean);
    function  GetAbout: string;
    function  GetValid: Boolean; virtual; abstract;
    function  GetSampleMasks: TStringList; virtual; abstract;
    procedure DoOnUserValidation;
    procedure DoBeforeValidation;
    procedure DoAfterValidation;
    procedure DoOnError(Sender: TObject; const ErrorMsg: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    {Public Methods}
    function IsValid: Boolean; virtual; abstract;
    function SampleMaskLength: integer;

    {Public Properties}
    property Input : string read FInput
      write SetInput;
    property Mask : string read FMask write SetMask;
    property Valid : boolean read GetValid;
    property ErrorCode: Word read FErrorCode;
    property SampleMasks: TStringList read GetSampleMasks;

    {Public Events}
    property BeforeValidation : TNotifyEvent
      read FBeforeValidation write FBeforeValidation;
    property AfterValidation : TNotifyEvent
      read FAfterValidation write FAfterValidation;
    property OnValidationError : TValidatorErrorEvent
      read FOnErrorEvent write FOnErrorEvent;

  published
    property About : string read GetAbout write SetAbout
      stored False;                                                   {!!.05}
  end;

implementation

uses
  {$IFDEF TRIALRUN} OrTrial, {$ENDIF} OvcVer;

{$IFDEF TRIALRUN}                                                     {!!.01}
{$I ORTRIALF.INC}                                                     {!!.01}
{$ENDIF}                                                              {!!.01}

{===== TO32BaseValidator ===========================================}
constructor TO32BaseValidator.Create(AOwner: TComponent);
{$IFDEF TRIALRUN}
var
  X : Integer;
{$ENDIF}
begin
{$IFDEF TRIALRUN}
  X := _CC_;
  if (X < ccRangeLow) or (X > ccRangeHigh) then Halt;
  X := _VC_;
  if (X < ccRangeLow) or (X > ccRangeHigh) then Halt;
{$ENDIF}
  inherited Create(AOwner);
  FSampleMaskLength := 0;
  FSampleMasks := TStringList.Create;
end;
{=====}

destructor TO32BaseValidator.Destroy;
begin
  FSampleMasks.Clear;
  FSampleMasks.Free;
  inherited Destroy;
end;
{=====}

function TO32BaseValidator.SampleMaskLength: integer;
begin
  result := FSampleMaskLength;
end;
{=====}

function TO32BaseValidator.GetAbout : string;
begin
  Result := OrVersionStr;
end;
{=====}

procedure TO32BaseValidator.SetAbout(const Value : string);
begin
end;
{=====}

procedure TO32BaseValidator.SetValid(Value: boolean);
begin
  if FValid <> Value then
    FValid := Value;
end;
{=====}

procedure TO32BaseValidator.DoOnUserValidation;
begin
  if Assigned(FOnUserValidation) then
    FOnUserValidation(Self);
end;
{=====}

procedure TO32BaseValidator.DoBeforeValidation;
begin
  if Assigned(FBeforeValidation) then
    FBeforeValidation(Self);
end;
{=====}

procedure TO32BaseValidator.DoAfterValidation;
begin
  if Assigned(FAfterValidation) then
    FAfterValidation(Self);
end;
{=====}

procedure TO32BaseValidator.DoOnError(Sender: TObject; const ErrorMsg: string);
begin
  if Assigned(FOnErrorEvent) then
    FOnErrorEvent(Self, ErrorMsg);
end;

end.
