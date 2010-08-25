{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars components                                      }
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

unit dxRibbonReg;

{$I cxVer.inc}

interface

procedure Register;

implementation

uses
  ColnEdit,
{$IFDEF DELPHI6}
  DesignEditors, DesignIntf,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Classes, Graphics, cxLibraryReg, dxBarReg, dxRibbon, ComCtrls, cxClasses,
  cxDesignWindows, dxBarSkin, dxRibbonSkins, dxStatusBar, dxRibbonStatusBar,
  TypInfo, dxBar, cxComponentCollectionEditor, cxPropEditors;

type
  { TdxRibbonDesignEditor }

  TdxRibbonDesignEditor = class(TdxBarComponentEditor)
  private
    function GetRibbon: TdxCustomRibbon;
  protected
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;
  public
    property Ribbon: TdxCustomRibbon read GetRibbon;
  end;

  { TdxRibbonColorSchemeNameProperty }

  TdxRibbonColorSchemeNameProperty = class(TStringProperty)
  protected
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  { TdxRibbonQuickAccessGroupButtonToolbarProperty }

  TdxRibbonQuickAccessGroupButtonToolbarProperty = class(TComponentProperty)
  private
    function GetRibbon: TdxCustomRibbon;
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure GetValues(Proc: TGetStrProc); override;
  end;

  { TdxRibbonStatusBarEditor }

  TdxRibbonStatusBarEditor = class(TdxBarComponentEditor)
  protected
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;
  end;

{$IFDEF DELPHI6}
  TdxRibbonStatusBarSelectionEditor = class(TSelectionEditor)
  public
    procedure RequiresUnits(Proc: TGetStrProc); override;
  end;
{$ENDIF}

  { TdxBarProperty }

  TdxBarProperty = class(TComponentProperty)
  private
    FProc: TGetPropProc;
    procedure GetPropProc({$IFNDEF DELPHI6}Prop: TPropertyEditor{$ELSE}const Prop: IProperty{$ENDIF});
  public
    procedure GetProperties(Proc: TGetPropProc); override;
  end;

  { TdxExtraPaneEventEditor }

  TdxExtraPaneEventEditor = class(TcxNestedEventProperty)
  protected
    function GetInstance: TPersistent; override;
  public
    function GetName: string; override;
  end;

procedure Register;
begin
{$IFDEF DELPHI9}
  ForceDemandLoadState(dlDisable);
{$ENDIF}
  RegisterComponents('ExpressBars', [TdxRibbon, TdxRibbonPopupMenu, TdxBarApplicationMenu, TdxRibbonStatusBar]);
  RegisterNoIcon([TdxRibbonGroupsDockControl, TdxRibbonQuickAccessGroupButton, TdxRibbonTab]);
  RegisterComponentEditor(TdxCustomRibbon, TdxRibbonDesignEditor);
  RegisterComponentEditor(TdxRibbonStatusBar, TdxRibbonStatusBarEditor);
  RegisterPropertyEditor(TypeInfo(string), TdxCustomRibbon, 'ColorSchemeName',
    TdxRibbonColorSchemeNameProperty);
  RegisterPropertyEditor(TypeInfo(TdxBar), TdxRibbonQuickAccessGroupButton, 'Toolbar',
    TdxRibbonQuickAccessGroupButtonToolbarProperty);
  RegisterPropertyEditor(TypeInfo(TBitmap), TdxRibbonApplicationButton, 'Glyph', TcxBitmapProperty);
  RegisterPropertyEditor(TypeInfo(TdxBar), nil, '', TdxBarProperty);
  RegisterPropertyEditor(TypeInfo(TNotifyEvent), TdxBarApplicationMenu, 'ExtraPaneEvents', TdxExtraPaneEventEditor);

    // ExtraPane
  HideClassProperties(TdxBarApplicationMenu, ['ExtraPaneWidthRatio',
    'ExtraPaneSize', 'ExtraPaneItems', 'ExtraPaneHeader', 'OnExtraPaneItemClick']);

  HideClassProperties(TdxRibbonQuickAccessGroupButton, ['Action', 'Align',
    'Caption', 'Category', 'Description', 'Hint', 'MergeKind', 'MergeOrder',
    'Style']);
end;

{ TdxRibbonColorSchemeNameProperty }

function TdxRibbonColorSchemeNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [{paReadOnly,} paValueList, paRevertable]
    -[paReadOnly];
end;

procedure TdxRibbonColorSchemeNameProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 0 to SkinManager.SkinCount - 1 do
    if SkinManager[I] is TdxCustomRibbonSkin then
      Proc(SkinManager[I].Name);
end;

procedure TdxRibbonColorSchemeNameProperty.SetValue(const Value: string);
var
  I: Integer;
begin
  for I := 0 to PropCount - 1 do
  begin
    TdxCustomRibbon(GetComponent(I)).ColorSchemeName := Value;
  end;
end;

{ TdxRibbonDesignEditor }

function TdxRibbonDesignEditor.InternalGetVerb(AIndex: Integer): string;
begin
  Result := 'Tabs Editor...';;
end;

function TdxRibbonDesignEditor.InternalGetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TdxRibbonDesignEditor.InternalExecuteVerb(AIndex: Integer);
begin
  ShowFormEditorClass(Designer, Component, Ribbon.Tabs, 'Tabs', TfrmComponentCollectionEditor);
end;

function TdxRibbonDesignEditor.GetRibbon: TdxCustomRibbon;
begin
  Result := Component as TdxCustomRibbon;
end;

{ TdxRibbonQuickAccessGroupButtonToolbarProperty }

function TdxRibbonQuickAccessGroupButtonToolbarProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes - [paMultiSelect];
end;

procedure TdxRibbonQuickAccessGroupButtonToolbarProperty.GetValues(Proc: TGetStrProc);
var
  AGroupButton: TdxRibbonQuickAccessGroupButton;
  AList: TStringList;
  ARibbon: TdxCustomRibbon;
  AToolbar: TdxBar;
  I, J: Integer;
begin
  ARibbon := GetRibbon;
  if ARibbon = nil then
    Exit;
  AGroupButton := TdxRibbonQuickAccessGroupButton(GetComponent(0));
  AList := TStringList.Create;
  try
    for I := 0 to ARibbon.TabCount - 1 do
      for J := 0 to ARibbon.Tabs[I].Groups.Count - 1 do
      begin
        AToolbar := ARibbon.Tabs[I].Groups[J].Toolbar;
        if (AToolbar <> nil) and (AList.IndexOf(AToolbar.Name) = -1) and AGroupButton.IsToolbarAcceptable(AToolbar) then
          AList.Add(AToolbar.Name);
      end;
    if (AGroupButton.Toolbar <> nil) and (AList.IndexOf(AGroupButton.Toolbar.Name) = -1) then
      AList.Add(AGroupButton.Toolbar.Name);
    for I := 0 to AList.Count - 1 do
      Proc(AList[I]);
  finally
    AList.Free;
  end;
end;

function TdxRibbonQuickAccessGroupButtonToolbarProperty.GetRibbon: TdxCustomRibbon;
var
  AGroupButton: TdxRibbonQuickAccessGroupButton;
begin
  AGroupButton := TdxRibbonQuickAccessGroupButton(GetComponent(0));
  if AGroupButton.LinkCount = 0 then
    Result := nil
  else
    Result := TdxRibbonQuickAccessBarControl(AGroupButton.Links[0].BarControl).Ribbon;
end;

{ TdxRibbonStatusBarEditor }

function TdxRibbonStatusBarEditor.InternalGetVerb(AIndex: Integer): string;
begin
  Result := 'Panels Editor...';
end;

function TdxRibbonStatusBarEditor.InternalGetVerbCount: Integer;
begin
  Result := 1;
end;

procedure TdxRibbonStatusBarEditor.InternalExecuteVerb(AIndex: Integer);
begin
  ShowCollectionEditor(Designer, Component, (Component as TdxRibbonStatusBar).Panels, 'Panels');
end;

{$IFDEF DELPHI6}
procedure TdxRibbonStatusBarSelectionEditor.RequiresUnits(Proc: TGetStrProc);
begin
  Proc('cxGraphics');
  Proc('dxRibbon');
end;
{$ENDIF}

{ TdxBarProperty }

procedure TdxBarProperty.GetProperties(Proc: TGetPropProc);
begin
  FProc := Proc;
  inherited GetProperties(GetPropProc);
end;

procedure TdxBarProperty.GetPropProc(
  {$IFNDEF DELPHI6}Prop: TPropertyEditor{$ELSE}const Prop: IProperty{$ENDIF});
const
  PropertiesToHide =
    ' AllowClose AllowCustomizing AllowQuickCustomizing AllowReset ' +
    'BorderStyle Color DockControl DockedDockControl DockedDockingStyle ' +
    'DockedLeft DockedTop DockingStyle FloatLeft FloatTop FloatClientWidth ' +
    'FloatClientHeight Font Hidden IsMainMenu MultiLine NotDocking OldName ' +
    'OneOnRow RotateWhenVertical Row ShowMark SizeGrip UseOwnFont ' +
    'UseRecentItems UseRestSpace WholeRow BackgroundBitmap AlphaBlendValue ';
var
  I: Integer;
begin
  if (GetComponent(0) is TdxRibbonQuickAccessToolbar) or
    (GetComponent(0) is TdxStatusBarToolbarPanelStyle) or
    (GetComponent(0) is TdxRibbonTabGroup) then
  begin
    for I := 0 to PropCount - 1 do
      if Pos(' ' + Prop.GetName + ' ', PropertiesToHide) > 0 then Exit;
  end;
  FProc(Prop);
end;

{ TdxExtraPaneEventEditor }

function TdxExtraPaneEventEditor.GetName: string;
begin
  Result := 'ExtraPane';
end;

function TdxExtraPaneEventEditor.GetInstance: TPersistent;
begin
  Result := TdxBarApplicationMenu(GetComponent(0)).ExtraPane;
end;

end.
