{*********************************************************}
{*                  OVCFNPE.PAS 4.05                    *}
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

unit ovcfnpe;
  {-File name property editor}

interface

uses
  Dialogs,
  {$IFDEF VERSION6} DesignIntf, DesignEditors, {$ELSE} DsgnIntf, {$ENDIF}
  Forms;

type
  {property editor for ranges}
  TOvcFileNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes;
      override;
    function GetValue : string;
      override;
    procedure Edit;
      override;
  end;


implementation


{*** TOvcFileNameProperty ***}

function TOvcFileNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

function TOvcFileNameProperty.GetValue : string;
begin
  Result := inherited GetValue;
end;

procedure TOvcFileNameProperty.Edit;
var
  D : TOpenDialog;
begin
  D := TOpenDialog.Create(Application);
  try
    D.DefaultExt := '*.*';
    D.Filter := 'All Files (*.*)|*.*|Text Files (*.txt)|*.txt|Ini Files (*.ini)|*.ini';
    D.FilterIndex := 0;
    D.Options := [ofHideReadOnly];
    D.Title := 'Select File Name';
    D.FileName := Value;
    if D.Execute then
      Value := D.FileName;
  finally
    D.Free;
  end;
end;


end.
