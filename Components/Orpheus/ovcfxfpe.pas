{*********************************************************}
{*                  OVCFXFPE.PAS 4.05                    *}
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

unit ovcfxfpe;
  {-Fixed font property editors}

interface

uses
  Classes, Graphics, Controls, Forms, Dialogs, SysUtils, TypInfo,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  OvcFxFnt;

type
  {fixed font name property editor}
  TOvcFixFontNameProperty = class(TStringProperty)
  public
    function GetAttributes : TPropertyAttributes;
      override;
    procedure GetValues(Proc : TGetStrProc);
      override;
  end;

  {fixed font property editor}
  TOvcFixFontProperty = class(TClassProperty)
  public
    procedure Edit;
      override;
    function GetAttributes : TPropertyAttributes;
      override;
  end;


implementation


{*** TOvcFixFontNameProperty ***}

function TOvcFixFontNameProperty.GetAttributes : TPropertyAttributes;
begin
  Result := [paMultiSelect, paValueList, paSortList];
end;

procedure TOvcFixFontNameProperty.GetValues(Proc : TGetStrProc);
var
  i : integer;
begin
  for i := 0 to pred(FixedFontNames.Count) do
    Proc(FixedFontNames[i]);
end;


{*** TOvcFixFontProperty ***}

procedure TOvcFixFontProperty.Edit;
var
  FF : TOvcFixedFont;
  FontDialog : TFontDialog;
begin
  FontDialog := nil;
  FF := nil;
  try
    FontDialog := TFontDialog.Create(Application);
    FF := TOvcFixedFont.Create;
    FF.Assign(TOvcFixedFont(GetOrdValue));
    FontDialog.Font := FF.Font;
    FontDialog.Options :=
        FontDialog.Options + [fdForceFontExist, fdFixedPitchOnly];
    if FontDialog.Execute then begin
      FF.Font.Assign(FontDialog.Font);
      SetOrdValue(Longint(FF));
    end;
  finally
    FontDialog.Free;
    FF.Free;
  end;
end;

function TOvcFixFontProperty.GetAttributes : TPropertyAttributes;
begin
  Result := [paMultiSelect, paSubProperties, paDialog, paReadOnly];
end;


end.
