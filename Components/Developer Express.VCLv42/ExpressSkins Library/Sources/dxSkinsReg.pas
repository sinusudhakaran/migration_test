{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{       Copyright (c) 2006-2009 Developer Express Inc.               }
{       ALL RIGHTS RESERVED                                          }
{                                                                    }
{   The entire contents of this file is protected by U.S. and        }
{   International Copyright Laws. Unauthorized reproduction,         }
{   reverse-engineering, and distribution of all or any portion of   }
{   the code contained in this file is strictly prohibited and may   }
{   result in severe civil and criminal penalties and will be        }
{   prosecuted to the maximum extent possible under the law.         }
{                                                                    }
{   RESTRICTIONS                                                     }
{                                                                    }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES            }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE     }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS    }
{   LICENSED TO DISTRIBUTE THE EXPRESSSKINS AND ALL ACCOMPANYING     }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.              }
{                                                                    }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED       }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE         }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE        }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT   }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                       }
{                                                                    }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON        }
{   ADDITIONAL RESTRICTIONS.                                         }
{                                                                    }
{********************************************************************}

unit dxSkinsReg;

{$I cxVer.inc}

interface

uses
  Windows, Classes, cxClasses, Forms,
{$IFDEF DELPHI6}
  Types, DesignIntf, DesignEditors,  VCLEditors,
{$ELSE}
  DsgnWnds, DsgnIntf,
{$ENDIF}
  SysUtils, TypInfo, cxLibraryReg, cxLookAndFeels, cxLookAndFeelPainters,
  dxSkinsCore, dxSkinsLookAndFeelPainter, dxSkinsDefaultPainters, dxSkinsForm;

const
  dxSkinsMajorVersion = '1';
  dxSkinsProductName = 'ExpressSkins';

type
  TdxSkinListFilterProc = function (const ASkinName: string): Boolean;
  TdxSkinModifyProjectOptionsProc = procedure;

  { TdxSkinNameProperty }

  TdxSkinNameProperty = class(TStringProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

var
  dxSkinListFilterProc: TdxSkinListFilterProc;
  dxSkinModifyProjectOptionsProc: TdxSkinModifyProjectOptionsProc;

procedure Register;

implementation

uses
  cxControls;

function CanUseSkin(const ASkin: string): Boolean;
begin
  Result := not Assigned(dxSkinListFilterProc) or dxSkinListFilterProc(ASkin);
end;

{ TdxSkinNameProperty }

function TdxSkinNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes - [paReadOnly] + [paValueList];
end;

procedure TdxSkinNameProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 0 to GetExtendedStylePainters.Count - 1 do
  begin
    if CanUseSkin(GetExtendedStylePainters.Names[I]) then
      Proc(GetExtendedStylePainters.Names[I]);
  end;
end;

type

  { TdxSkinControllerEditor }

  TdxSkinControllerEditor = class(TcxComponentEditor)
  protected
    function GetProductMajorVersion: string; override;
    function GetProductName: string; override;
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;
  public
    procedure Edit; override;
    procedure ResetControllerState;
  end;

{  TdxSkinControllerEditor }

procedure TdxSkinControllerEditor.Edit;
begin
  if Assigned(dxSkinModifyProjectOptionsProc) then
    dxSkinModifyProjectOptionsProc;
end;

function TdxSkinControllerEditor.InternalGetVerb(AIndex: Integer): string;
begin
  if Assigned(dxSkinModifyProjectOptionsProc) and (AIndex = 0) then
    Result := 'Modify Project Skin Options'
  else
    Result := 'Reset';
end;

function TdxSkinControllerEditor.InternalGetVerbCount: Integer;
const
  VerbsCountMap: array[Boolean] of Integer = (1, 2);
begin
  Result := VerbsCountMap[Assigned(dxSkinModifyProjectOptionsProc)];
end;

procedure TdxSkinControllerEditor.InternalExecuteVerb(AIndex: Integer);
begin
  if Assigned(dxSkinModifyProjectOptionsProc) and (AIndex = 0) then
    dxSkinModifyProjectOptionsProc
  else
    ResetControllerState;
end;

procedure TdxSkinControllerEditor.ResetControllerState;
begin
  with TdxSkinController(Component) do
  begin
    Kind := cxDefaultLookAndFeelKind;
    NativeStyle := cxDefaultLookAndFeelNativeStyle;
    SkinName := '';
    UseSkins := True;
  end;
  Designer.Modified;
end;

function TdxSkinControllerEditor.GetProductMajorVersion: string;
begin
  Result := dxSkinsMajorVersion;
end;

function TdxSkinControllerEditor.GetProductName: string;
begin
  Result := dxSkinsProductName;
end;

procedure Register;
begin
  IsDesigning := True;
{$IFDEF DELPHI9}
  ForceDemandLoadState(dlDisable);
{$ENDIF}
  RegisterComponents('Dev Express', [TdxSkinController]);
  RegisterClasses([TdxSkinController]);
  RegisterPropertyEditor(TypeInfo(TdxSkinName),
    nil, 'SkinName', TdxSkinNameProperty);
  RegisterComponentEditor(TdxSkinController, TdxSkinControllerEditor);
end;

end.
