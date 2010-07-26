{**************************************************************************}
{ TGradientStyle                                                           }
{ for Delphi & C++Builder                                                  }
{                                                                          }
{ Copyright © 2001 - 2006                                                  }
{   TMS Software                                                           }
{   Email : info@tmssoftware.com                                           }
{   Web : http://www.tmssoftware.com                                       }
{                                                                          }
{ The source code is given as is. The author is not responsible            }
{ for any possible damage done due to the use of this code.                }
{ The component can be freely used in any application. The complete        }
{ source code remains property of the author and may not be distributed,   }
{ published, given or sold in any form as such. No parts of the source     }
{ code can be included in any other component or application without       }
{ written authorization of the author.                                     }
{**************************************************************************}

unit AdvGradient;

{$I TMSDEFS.INC}

interface

uses
  Classes, Graphics;

type
  TGradientStyle = class(TPersistent)
  private
    FColorTo: TColor;
    FColorFrom: TColor;
    FBorderColor: TColor;
    FOnChange: TNotifyEvent;
    FDirection: Boolean;
    FColorMirrorFrom: TColor;
    FColorMirrorTo: TColor;
    procedure SetBorderColor(const Value: TColor);
    procedure SetColorFrom(const Value: TColor);
    procedure SetColorTo(const Value: TColor);
    procedure SetColorMirrorFrom(const Value: TColor);
    procedure SetColorMirrorTo(const Value: TColor);
  protected
    procedure Changed;
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BorderColor: TColor read FBorderColor write SetBorderColor default clHighLight;
    property ColorFrom: TColor read FColorFrom write SetColorFrom default clHighlight;
    property ColorTo: TColor read FColorTo write SetColorTo default clNone;
    property ColorMirrorFrom: TColor read FColorMirrorFrom write SetColorMirrorFrom default clNone;
    property ColorMirrorTo: TColor read FColorMirrorTo write SetColorMirrorTo default clNone;
    property Direction: Boolean read FDirection write FDirection default false;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;


implementation

{ TGradientStyle }

procedure TGradientStyle.Assign(Source: TPersistent);
begin
  if not (Source is TGradientStyle) then
    Exit;

  FBorderColor := (Source as TGradientStyle).BorderColor;
  FColorTo := (Source as TGradientStyle).ColorTo;
  FColorFrom := (Source as TGradientStyle).ColorFrom;
  FColorMirrorTo := (Source as TGradientStyle).ColorMirrorTo;
  FColorMirrorFrom := (Source as TGradientStyle).ColorMirrorFrom;
  Changed;
end;

procedure TGradientStyle.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

constructor TGradientStyle.Create;
begin
  {$IFDEF TMSDOTNET}
  inherited;
  {$ENDIF}

  FColorFrom := clHighLight;
  FColorTo := clNone;
  FColorMirrorFrom := clNone;
  FColorMirrorTo := clNone;
  FBorderColor := clHighLight;
end;

procedure TGradientStyle.SetBorderColor(const Value: TColor);
begin
  if (FBorderColor <> Value) then
  begin
    FBorderColor := Value;
    Changed;
  end;
end;

procedure TGradientStyle.SetColorFrom(const Value: TColor);
begin
  if (FColorFrom <> Value) then
  begin
    FColorFrom := Value;
    Changed;
  end;
end;

procedure TGradientStyle.SetColorMirrorFrom(const Value: TColor);
begin
  if (FColorMirrorFrom <> Value) then
  begin
    FColorMirrorFrom := Value;
    Changed;
  end;
end;

procedure TGradientStyle.SetColorMirrorTo(const Value: TColor);
begin
  if (FColorMirrorTo <> Value) then
  begin
    FColorMirrorTo := Value;
    Changed;
  end;
end;

procedure TGradientStyle.SetColorTo(const Value: TColor);
begin
  if (FColorTo <> Value) then
  begin
    FColorTo := Value;
    Changed;
  end;
end;


end.
