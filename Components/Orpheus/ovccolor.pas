{*********************************************************}
{*                  OVCCOLOR.PAS 4.05                    *}
{*     Copyright (c) 1995-200 TurboPower Software Co     *}
{*                 All rights reserved.                  *}
{*********************************************************}

{$I OVC.INC}

{$B-} {Complete Boolean Evaluation}
{$I+} {Input/Output-Checking}
{$P+} {Open Parameters}
{$T-} {Typed @ Operator}
{.W-} {Windows Stack Frame}                                          {!!.02}
{$X+} {Extended Syntax}

unit ovccolor;
  {-Color selection class}

interface

uses
  Windows, Classes, Graphics;

type
  TOvcColors = class(TPersistent)
  {.Z+}
  protected {private}
    {property variables}
    FBackColor     : TColor;   {background color}
    FTextColor     : TColor;   {text or font color}
    FUseDefault    : Boolean;  {true to use defaults}

    {event variables}
    FOnColorChange : TNotifyEvent;

    {internal variables}
    cDefBackColor  : TColor;   {default background}
    cDefTextColor  : TColor;   {default text color}

    {property methods}
    procedure SetBackColor(Value: TColor);
      {-set the color used for the background}
    procedure SetTextColor(Value: TColor);
      {-set the color used for the foreground}
    procedure SetUseDefault(Value: Boolean);
      {-set the flag to reset colors to parent default values}

    procedure ReadUseDefault(Reader : TReader);
      {-read the UseDefault property. for backward compatibility only}

  protected
    procedure DefineProperties(Filer : TFiler);
      override;

    procedure DoOnColorChange;
      {-notify onwing object that a color has changed}
      dynamic;

    procedure ResetToDefaultColors;
      {-assign default color values}
      dynamic;

  public
    procedure Assign(Source : TPersistent);
      override;
    constructor Create(FG, BG : TColor);
      virtual;
  {.Z-}

    property OnColorChange : TNotifyEvent
      read FOnColorChange
      write FOnColorChange;

  published
    property BackColor : TColor
      read FBackColor
      write SetBackColor;

    property TextColor : TColor
      read FTextColor
      write SetTextColor;

    property UseDefault : Boolean
      read FUseDefault
      write SetUseDefault
      stored False;
  end;


implementation


{*** TOvcColors ***}

procedure TOvcColors.Assign(Source : TPersistent);
var
  C : TOvcColors absolute Source;
begin
  if (Source <> nil) and (Source is TOvcColors) then begin
    BackColor  := C.BackColor;
    TextColor  := C.TextColor;
  end else
    inherited Assign(Source);
end;

constructor TOvcColors.Create(FG, BG : TColor);
begin
  inherited Create;

  cDefBackColor := BG;
  cDefTextColor := FG;
  FUseDefault   := True;

  {initialize to these colors}
  ResetToDefaultColors;
end;

procedure TOvcColors.DefineProperties(Filer : TFiler);
begin
  inherited DefineProperties(Filer);
  {define a UseDefault property for compatibility with eariler versions}
  Filer.DefineProperty('UseDefault', ReadUseDefault, nil, False);
end;

procedure TOvcColors.DoOnColorChange;
  {-notify onwing object that a color has changed}
begin
  if Assigned(FOnColorChange) then
    FOnColorChange(Self);
end;

procedure TOvcColors.ReadUseDefault(Reader : TReader);
begin
  {read property and discard it}
  Reader.ReadBoolean;
end;

procedure TOvcColors.ResetToDefaultColors;
  {-obtain default color values}
begin
  FBackColor := cDefBackColor;
  FTextColor := cDefTextColor;
end;

procedure TOvcColors.SetBackColor(Value: TColor);
  {-set the color used for the background}
begin
  if Value <> FBackColor then begin
    if Value <> cDefBackColor then
      FUseDefault := False;
    FBackColor := Value;
    DoOnColorChange;
  end;
end;

procedure TOvcColors.SetTextColor(Value: TColor);
  {-set the color used for the foreground}
begin
  if Value <> FTextColor then begin
    if Value <> cDefTextColor then
      FUseDefault := False;
    FTextColor := Value;
    DoOnColorChange;
  end;
end;

procedure TOvcColors.SetUseDefault(Value: Boolean);
  {-set the flag to reset colors to parent default values}
begin
  FUseDefault := Value;
  if FUseDefault then begin
    ResetToDefaultColors;  {assign default values}
    DoOnColorChange;
  end;
end;


end.
