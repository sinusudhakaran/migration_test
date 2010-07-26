{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       Express side bar controls registration                      }
{                                                                   }
{       Copyright (c) 1998-2009 Developer Express Inc.              }
{       ALL RIGHTS RESERVED                                         }
{                                                                   }
{   The entire contents of this file is protected by U.S. and       }
{   International Copyright Laws. Unauthorized reproduction,        }
{   reverse-engineering, and distribution of all or any portion of  }
{   the code contained in this file is strictly prohibited and may  }
{   result in severe civil and criminal penalties and will be       }
{   prosecuted to the maximum extent possible under the law.        }
{                                                                   }
{   RESTRICTIONS                                                    }
{                                                                   }
{   THIS SOURCE CODE AND ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL AND PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS AND ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE AND ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   AND PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxsbreg;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

procedure Register;

implementation

uses dximctrl, dximcted, dxsppred, dxsbar, dxsbared, dxsbrsed, dxRegEd, ShellAPI, cxLibraryReg;

const
  dxSBMajorVersion = '5';
  dxSBProductName = 'ExpressSideBar';

{TSideBarStoreEditor}
type
  TSideBarComponentEditor = class(TcxComponentEditor)
  protected
    function GetProductMajorVersion: string; override;
    function GetProductName: string; override;
  end;

{ TSideBarStoreEditor }

function TSideBarComponentEditor.GetProductMajorVersion: string;
begin
  Result := dxSBMajorVersion;
end;

function TSideBarComponentEditor.GetProductName: string;
begin
  Result := dxSBProductName;
end;

type
  TSideBarStoreEditor = class(TSideBarComponentEditor)
  protected
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;
  end;

procedure TSideBarStoreEditor.InternalExecuteVerb(AIndex: Integer);
begin
  ShowSideBarStoreEditor(TdxSideBarStore(Component), Designer);
end;

function TSideBarStoreEditor.InternalGetVerb(AIndex: Integer): string;
begin
  Result := 'Edit...';
end;

function TSideBarStoreEditor.InternalGetVerbCount: Integer;
begin
  Result := 1;
end;

{TSideBarEditor}
type
  TSideBarEditor = class(TSideBarStoreEditor)
  protected
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;
  end;

procedure TSideBarEditor.InternalExecuteVerb(AIndex: Integer);
begin
  if ShowSideBarEditor(TdxSideBar(Component)) then
    Designer.Modified;
end;

function TSideBarEditor.InternalGetVerb(AIndex: Integer): string;
begin
  Result := 'Edit...';
end;

function TSideBarEditor.InternalGetVerbCount: Integer;
begin
  Result := 1;
end;

{TSideBarStoreGroupsPropertyEditor}
type
TSideBarStoreGroupsPropertyEditor = class(TPropertyEditor)
public
  function GetValue: string; override;
  function GetAttributes: TPropertyAttributes; override;
  procedure Edit; override;
end;

function TSideBarStoreGroupsPropertyEditor.GetValue: string;
begin
  Result := Format('(%s)', [TStrings.ClassName]);
end;

function TSideBarStoreGroupsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog];
end;

procedure TSideBarStoreGroupsPropertyEditor.Edit;
begin
  ShowSideBarStoreEditor(GetComponent(0) as TdxSideBarStore, Designer);
end;

{TSideBarGroupsPropertyEditor}
type
TSideBarGroupsPropertyEditor = class(TPropertyEditor)
public
  function GetValue: string; override;
  function GetAttributes: TPropertyAttributes; override;
  procedure Edit; override;
end;

function TSideBarGroupsPropertyEditor.GetValue: string;
begin
  Result := Format('(%s)', [TdxSideGroups.ClassName]);
end;

function TSideBarGroupsPropertyEditor.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog];
end;

procedure TSideBarGroupsPropertyEditor.Edit;
begin
  if ShowSideBarEditor(GetComponent(0) as TdxSideBar) then
    Modified;
end;

type
TdxImageControlItemProperties = class(TPropertyEditor)
public
  function GetValue: string; override;
  function GetAttributes: TPropertyAttributes; override;
  procedure Edit; override;
end;

function TdxImageControlItemProperties.GetValue: string;
begin
  Result := Format('(%s)', [TStrings.ClassName]);
end;

function TdxImageControlItemProperties.GetAttributes: TPropertyAttributes;
begin
  Result := [paMultiSelect, paDialog];
end;

procedure TdxImageControlItemProperties.Edit;
begin
  if(ExpressImageItemsPropEditor(GetComponent(0) as TWinControl)) then
    Modified;
end;

type
TdxSpinImageItemsProperties = class(TClassProperty)
public
  function GetAttributes: TPropertyAttributes; override;
  procedure Edit; override;
end;

function TdxSpinImageItemsProperties.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

procedure TdxSpinImageItemsProperties.Edit;
begin
  if(ExpressSpinImageItemsPropEditor(GetComponent(0) as TdxCustomSpinImage)) then
    Modified;
end;

{ TdxRegistryPathProperty }

type
  TdxRegistryPathProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TdxRegistryPathProperty.Edit;
var
  Bar: TdxSideBar;
  S: string;
begin
  Bar := TdxSideBar(GetComponent(0));
  S := Bar.RegistryPath;
  if dxGetRegistryPath(S) then
  begin
    Bar.RegistryPath := S;
    Designer.Modified;
  end;
end;

function TdxRegistryPathProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

procedure Register;
begin
  RegisterComponents('ExpressBars', [TdxSideBarStore, TdxSideBar, TdxSideBarPopupMenu]);
  RegisterNoIcon([TdxStoredSideItem]);

  RegisterComponents('ExpressBars', [TdxImageListBox, TdxImageComboBox, TdxSpinImage]);

  RegisterPropertyEditor(TypeInfo(TStrings), TdxCustomImageListBox, 'Items', TdxImageControlItemProperties);
  RegisterPropertyEditor(TypeInfo(TStrings), TdxImageComboBox, 'Items', TdxImageControlItemProperties);
  RegisterPropertyEditor(TypeInfo(TdxSpinImageItems), TdxCustomSpinImage, 'Items', TdxSpinImageItemsProperties);
  RegisterPropertyEditor(TypeInfo(TStrings), TdxSideBarStore, 'Groups', TSideBarStoreGroupsPropertyEditor);
  RegisterPropertyEditor(TypeInfo(TdxSideGroups), TdxSideBar, 'Groups', TSideBarGroupsPropertyEditor);

  RegisterPropertyEditor(TypeInfo(string), TdxSideBar, 'RegistryPath', TdxRegistryPathProperty);

  RegisterComponentEditor(TdxSideBarStore, TSideBarStoreEditor);
  RegisterComponentEditor(TdxSideBar, TSideBarEditor);
end;

end.
