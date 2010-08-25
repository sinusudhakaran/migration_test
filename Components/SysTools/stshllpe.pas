{*********************************************************}
{* SysTools: StShllPe.pas 3.03                           *}
{* Copyright (c) TurboPower Software Co 1996, 2001       *}
{* All rights reserved.                                  *}
{*********************************************************}
{* SysTools: Shell Property Editors                      *}
{*********************************************************}

{$I StDefine.inc}

unit StShllPe;

interface

{$IFDEF WIN16}
  !! Error: This unit cannot be compiled with Delphi 1
{$ENDIF}

uses
  Dialogs,
  Classes,
{$IFDEF VERSION6}
  DesignIntf,
  DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Forms,
  StBrowsr,
  TypInfo,
  StShBase;

{$Z+}
type
  TStDirectoryProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TStDropTargetProperty = class(TComponentProperty)
  public
    function GetAttributes : TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  TStSpecialFolderProperty = class(TEnumProperty)
  public
    //function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;
{$Z-}

implementation

{ TStDirectoryProperty }

function TStDirectoryProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog];
end;

procedure TStDirectoryProperty.Edit;
var
  Dlg : TStBrowser;
begin
  Dlg := TStBrowser.Create(Application);
  Dlg.SpecialRootFolder := sfDrives;
  try
    if Dlg.Execute then
      Value := Dlg.SelectedFolder;
  finally
    Dlg.Free;
  end;
end;

{ TStDropTargetProperty }

function TStDropTargetProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paValueList, paSortList];
end;

procedure TStDropTargetProperty.GetValues(Proc: TGetStrProc);
begin
  inherited GetValues(Proc);
  with GetComponent(0) as TComponent do
    Proc(Owner.Name);
end;

{ TStSpecialFolderProperty }

procedure TStSpecialFolderProperty.GetValues(Proc: TGetStrProc);
var
  I        : Integer;
  EnumType : PTypeInfo;
  S        : string;
begin
  EnumType := GetPropType;
  with GetTypeData(EnumType)^ do
    for I := MinValue to MaxValue do begin
      S := GetEnumName(EnumType, I);
      if S = 'sfNone' then
        S := '(sfNone)';
      Proc(S);
    end;
end;

procedure TStSpecialFolderProperty.SetValue(const Value: string);
begin
  if Value = '(sfNone)' then begin
    SetOrdValue(Ord(sfNone));
  end else
    inherited SetValue(Value);
end;

end.