
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
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

unit cxExtEditReg;

{$I cxVer.inc}

interface

uses
  Classes;

procedure Register;

implementation

uses
{$IFDEF DELPHI6}
    DesignIntf, DesignEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  Controls, Forms, Graphics, ImgList, StdCtrls, SysUtils, TypInfo, cxCheckBox,
  cxCheckComboBox, cxCheckGroup, cxCheckGroupStatesEditor, cxCheckListBox,
  cxClasses, cxColorComboBox, cxContainer, cxDBCheckComboBox, cxDBCheckGroup,
  cxDBCheckListBox, cxDBColorComboBox, cxDBFontNameComboBox, cxDBLabel,
  cxDBProgressBar, cxDBRichEdit, cxDBTrackBar, cxEdit, cxEditPropEditors,
  cxEditRepositoryEditor, cxExtEditConsts, cxExtEditRepositoryItems,
  cxFontNameComboBox, cxHeader, cxHint, cxHintEditor, cxLabel, cxListView,
  cxLookAndFeels, cxMCListBox, cxProgressBar, cxPropEditors, cxRichEdit,
  cxScrollBar, cxSpinButton, cxSplitter, cxSplitterEditor, cxTrackBar,
  cxTreeView;

const
  cxEditorsRestoreStyleCaption = 'Restore style';
  cxEditorsRestoreLookAndFeelCaption = 'Restore LookAndFeel';
  cxEditComponentEditorVerbS: array[0..0] of string = (cxEditorsRestoreStyleCaption);
  cxEditComponentEditorVerbL: array[0..0] of string = (cxEditorsRestoreLookAndFeelCaption);
  cxSplitterStyleControllerVerb = 'Splitter Editor...';
  cxHintStyleControllerVerb = 'Hints Editor...';

type
  TcxCustomEditAccess = class(TcxCustomEdit);

type
  { TcxHotZoneStyleProperty }

  TcxHotZoneStyleProperty = class(TClassProperty)
  protected
    function HasSubProperties: Boolean;
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
  end;

  { TcxCustomHeaderComponentEditor }

  TcxCustomHeaderComponentEditor = class(TcxEditorsLibraryComponentWithoutStylesEditor)
  protected
    function GetLookAndFeel: TcxLookAndFeel; override;
  public
    procedure Edit; override;
  end;

  { TcxSplitterComponentEditor }

  TcxSplitterComponentEditor = class(TcxEditorsLibraryComponentEditorEx)
  protected
    function GetEditItemCaption: string; override;
    procedure ExecuteEditAction; override;
  end;

  { TcxHintStyleComponentEditor }

  TcxHintStyleComponentEditor = class(TcxEditorsLibraryComponentEditorEx)
  protected
    function GetEditItemCaption: string; override;
    procedure ExecuteEditAction; override;
  end;

  { TcxHotZoneStyleEventsProperty }

  TcxHotZoneStyleEventsProperty = class(TcxNestedEventProperty)
  protected
    function GetInstance: TPersistent; override;
  end;

  { TcxHeaderSectionImageIndexProperty }

  TcxHeaderSectionImageIndexProperty = class(TImageIndexProperty)
  public
    function GetImages: TCustomImageList; override;
  end;

  { TcxChecksControlStatesItemsProperty }

  TcxChecksControlStatesItemsProperty = class(TPropertyEditor)
  protected
    procedure InitializeDlg(ADialog: TcxCheckGroupStatesEditorDlg); virtual;
    procedure SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg); virtual;
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetName: string; override;
    function GetValue: string; override;
  end;

  { TcxCheckGroupStatesItemsProperty }

  TcxCheckGroupStatesItemsProperty = class(TcxChecksControlStatesItemsProperty)
  protected
    procedure InitializeDlg(ADialog: TcxCheckGroupStatesEditorDlg); override;
    procedure SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg); override;
  end;

  { TcxCheckComboBoxStatesItemsProperty }

  TcxCheckComboBoxStatesItemsProperty = class(TcxChecksControlStatesItemsProperty)
  protected
    procedure InitializeDlg(ADialog: TcxCheckGroupStatesEditorDlg); override;
    procedure SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg); override;
  end;

  { TcxCheckGroupComponentEditor }

  TcxCheckGroupComponentEditor = class(TcxEditComponentEditor)
  public
    procedure Edit; override;
  end;

{$IFDEF DELPHI6}
  TcxCommonControlsSelectionEditor = class(TSelectionEditor)
  public
    procedure RequiresUnits(Proc: TGetStrProc); override;
  end;
{$ENDIF}

  { TcxCheckListBoxItemImageIndexProperty }

  TcxCheckListBoxItemImageIndexProperty = class(TImageIndexProperty)
  public
    function GetImages: TCustomImageList; override;
  end;
  
{ TcxHotZoneStyleProperty }

function TcxHotZoneStyleProperty.HasSubProperties: Boolean;
var
  I: Integer;
begin
  for I := 0 to PropCount - 1 do
  begin
    Result := TcxCustomSplitter(GetComponent(I)).HotZone <> nil;
    if not Result then Exit;
  end;
  Result := True;
end;

function TcxHotZoneStyleProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes;
  if not HasSubProperties then
    Exclude(Result, paSubProperties);
  Result := Result - [paReadOnly] +
    [paValueList, paSortList, paRevertable{$IFDEF DELPHI6}, paVolatileSubProperties{$ENDIF}];
end;

function TcxHotZoneStyleProperty.GetValue: string;
begin
  if HasSubProperties then
    Result := GetRegisteredHotZoneStyles.GetDescriptionByClass(
      TcxCustomSplitter(GetComponent(0)).HotZone.ClassType)
  else
    Result := '';
end;

procedure TcxHotZoneStyleProperty.GetValues(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 0 to GetRegisteredHotZoneStyles.Count - 1 do
    Proc(GetRegisteredHotZoneStyles.Descriptions[I]);
end;

procedure TcxHotZoneStyleProperty.SetValue(const Value: string);
var
  FHotZoneStyleClass: TcxHotZoneStyleClass;
  I: Integer;
begin
  FHotZoneStyleClass := TcxHotZoneStyleClass(GetRegisteredHotZoneStyles.FindByClassName(Value));
  if FHotZoneStyleClass = nil then
    FHotZoneStyleClass := TcxHotZoneStyleClass(GetRegisteredHotZoneStyles.FindByDescription(Value));

  for I := 0 to PropCount - 1 do
    TcxCustomSplitter(GetComponent(I)).HotZoneStyleClass := FHotZoneStyleClass;
  Modified;
end;

{ TcxHotZoneStyleEventsProperty }

function TcxHotZoneStyleEventsProperty.GetInstance: TPersistent;
begin
  Result := TcxCustomSplitter(GetComponent(0)).HotZone;
end;

{ TcxHeaderSectionImageIndexProperty }

function TcxHeaderSectionImageIndexProperty.GetImages: TCustomImageList;
begin
  Result := nil;
  if GetComponent(0) is TcxHeaderSection then
    Result := TCustomImageList(TcxHeaderSection(GetComponent(0)).HeaderControl.Images);
end;

{ TcxCustomHeaderComponentEditor }

procedure TcxCustomHeaderComponentEditor.Edit;
begin
end;

function TcxCustomHeaderComponentEditor.GetLookAndFeel: TcxLookAndFeel;
begin
  Result := TcxCustomHeader(Component).LookAndFeel;
end;

{ TcxSplitterComponentEditor }

function TcxSplitterComponentEditor.GetEditItemCaption: string;
begin
  Result := cxSplitterStyleControllerVerb;
end;

procedure TcxSplitterComponentEditor.ExecuteEditAction;
begin
  ShowSplitterEditor(Component as TcxSplitter);
end;

{ TcxHintStyleComponentEditor }

function TcxHintStyleComponentEditor.GetEditItemCaption: string;
begin
  Result := cxHintStyleControllerVerb;
end;

procedure TcxHintStyleComponentEditor.ExecuteEditAction;
begin
  ShowHintStyleEditor(Component as TcxHintStyleController);
end;

{ TcxChecksControlStatesItemsProperty }

procedure TcxChecksControlStatesItemsProperty.Edit;
var
  ADialog: TcxCheckGroupStatesEditorDlg;
begin
  ADialog := TcxCheckGroupStatesEditorDlg.Create(Application);
  try
    InitializeDlg(ADialog);
    if ADialog.ShowModal = mrOK then
    begin
      SynchronizeControlCheckStates(ADialog);
      Modified;
    end;
  finally
    ADialog.Free;
  end;
end;

function TcxChecksControlStatesItemsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TcxChecksControlStatesItemsProperty.GetName: string;
begin
  Result := 'States';
end;

function TcxChecksControlStatesItemsProperty.GetValue: string;
begin
  Result := '';
end;

procedure TcxChecksControlStatesItemsProperty.InitializeDlg(ADialog: TcxCheckGroupStatesEditorDlg);
begin
end;

procedure TcxChecksControlStatesItemsProperty.SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg);
begin
end;

{ TcxCheckGroupStatesItemsProperty }

procedure TcxCheckGroupStatesItemsProperty.InitializeDlg(
  ADialog: TcxCheckGroupStatesEditorDlg);
var
  ACheckGroup: TcxCustomCheckGroup;
  AItem: TcxCheckListBoxItem;
  I: Integer;
begin
  ADialog.Caption := cxGetResourceString(@
    cxSCheckGroupStatesItemsPropertyDlgCaption);
  ADialog.clbStates.Items.Clear;
  ACheckGroup := TcxCustomCheckGroup(GetComponent(0));
  ADialog.clbStates.AllowGrayed := ACheckGroup.ActiveProperties.AllowGrayed and
    (ACheckGroup.ActiveProperties.EditValueFormat <> cvfInteger);
  for I := 0 to ACheckGroup.ActiveProperties.Items.Count - 1 do
  begin
    AItem := TcxCheckListBoxItem(ADialog.clbStates.Items.Add);
    AItem.Text := ACheckGroup.ActiveProperties.Items[I].Caption;
    AItem.State := ACheckGroup.States[I];
  end;
end;

procedure TcxCheckGroupStatesItemsProperty.SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg);
var
  I: Integer;
begin
  with TcxCustomCheckGroup(GetComponent(0)) do
    for I := 0 to ADialog.clbStates.Items.Count - 1 do
      States[I] := ADialog.clbStates.Items[I].State;
end;

{ TcxCheckComboBoxStatesItemsProperty }

procedure TcxCheckComboBoxStatesItemsProperty.InitializeDlg(ADialog: TcxCheckGroupStatesEditorDlg);
var
  ACheckComboBox: TcxCustomCheckComboBox;
  AItem: TcxCheckListBoxItem;
  I: Integer;
begin
  ADialog.Caption := cxGetResourceString(@
    cxSCheckComboBoxStatesItemsPropertyDlgCaption);
  ADialog.clbStates.Items.Clear;
  ACheckComboBox := TcxCustomCheckComboBox(GetComponent(0));
  ADialog.clbStates.AllowGrayed := False;
  for I := 0 to ACheckComboBox.ActiveProperties.Items.Count - 1 do
  begin
    AItem := TcxCheckListBoxItem(ADialog.clbStates.Items.Add);
    AItem.Text := ACheckComboBox.ActiveProperties.Items[I].Description;
    AItem.State := ACheckComboBox.States[I];
  end;
end;

procedure TcxCheckComboBoxStatesItemsProperty.SynchronizeControlCheckStates(ADialog: TcxCheckGroupStatesEditorDlg);
var
  I: Integer;
begin
  with TcxCustomCheckComboBox(GetComponent(0)) do
    for I := 0 to ADialog.clbStates.Items.Count - 1 do
      States[I] := ADialog.clbStates.Items[I].State;
end;

{ TcxCheckGroupComponentEditor }

procedure TcxCheckGroupComponentEditor.Edit;
const
  AMethodParams: array[0..0] of TMethodParam =
    ((Flags: [pfAddress]; Name: 'Sender'; TypeName: 'TObject'));
begin
  ShowEventMethod(Designer, TcxCustomEditAccess(Component).Properties,
    'OnChange', Component.Name + 'PropertiesChange', AMethodParams);
end;

{$IFDEF DELPHI6}
procedure TcxCommonControlsSelectionEditor.RequiresUnits(Proc: TGetStrProc);
begin
  Proc('ComCtrls');
end;
{$ENDIF}

{ TcxCheckListBoxItemImageIndexProperty }

function TcxCheckListBoxItemImageIndexProperty.GetImages: TCustomImageList;
begin
  Result := TcxCustomInnerCheckListBox(GetPersistentOwner(
    TcxCheckListBoxItem(GetComponent(0)).Collection)).Container.Images;
end;

procedure RegisterEditRepositoryItems;
begin
  RegisterEditRepositoryItem(TcxEditRepositoryLabel, scxSEditRepositoryLabelItem);
  RegisterEditRepositoryItem(TcxEditRepositoryFontNameComboBox, scxSEditRepositoryFontNameComboBoxItem);
  RegisterEditRepositoryItem(TcxEditRepositoryColorComboBox, scxSEditRepositoryColorComboBoxItem);
  RegisterEditRepositoryItem(TcxEditRepositoryProgressBar, scxSEditRepositoryProgressBarItem);
  RegisterEditRepositoryItem(TcxEditRepositoryTrackBar, scxSEditRepositoryTrackBarItem);
  RegisterEditRepositoryItem(TcxEditRepositoryCheckComboBox, scxSEditRepositoryCheckComboBox);
  RegisterEditRepositoryItem(TcxEditRepositoryCheckGroupItem, scxSEditRepositoryCheckGroupItem);
  RegisterEditRepositoryItem(TcxEditRepositoryRichItem, scxSEditRepositoryRichEditItem);
end;

procedure UnregisterEditRepositoryItems;
begin
  UnregisterEditRepositoryItem(TcxEditRepositoryLabel);
  UnregisterEditRepositoryItem(TcxEditRepositoryFontNameComboBox);
  UnregisterEditRepositoryItem(TcxEditRepositoryColorComboBox);
  UnregisterEditRepositoryItem(TcxEditRepositoryProgressBar);
  UnregisterEditRepositoryItem(TcxEditRepositoryTrackBar);
  UnregisterEditRepositoryItem(TcxEditRepositoryCheckComboBox);
  UnregisterEditRepositoryItem(TcxEditRepositoryCheckGroupItem);
  UnregisterEditRepositoryItem(TcxEditRepositoryRichItem);
end;

procedure Register;
begin
{$IFDEF DELPHI9}
  ForceDemandLoadState(dlDisable);
{$ENDIF}  

  RegisterComponents('Express Editors 6', [TcxLabel, TcxProgressBar, TcxTrackBar,
    TcxCheckListBox, TcxColorComboBox, TcxFontNameComboBox, TcxCheckComboBox,
    TcxCheckGroup, TcxRichEdit]);
  RegisterComponents('Express DBEditors 6', [TcxDBLabel, TcxDBProgressBar, TcxDBTrackBar,
    TcxDBCheckListBox, TcxDBColorComboBox, TcxDBFontNameComboBox, TcxDBCheckComboBox,
    TcxDBCheckGroup, TcxDBRichEdit]);
  RegisterComponents('Express Utilities', [TcxHintStyleController, TcxSpinButton,
    TcxMCListBox, TcxListView, TcxTreeView, TcxHeader, TcxSplitter]);

  RegisterPropertyEditor(TypeInfo(string), TcxCustomSplitter, 'HotZoneClassName', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomSplitter, 'ResizeIgnoreSnap', nil);
  RegisterPropertyEditor(TypeInfo(TcxHotZoneStyle), TcxCustomSplitter, 'HotZone', TcxHotZoneStyleProperty);
  RegisterPropertyEditor(TypeInfo(TNotifyEvent), TcxCustomSplitter, 'HotZoneEvents', TcxHotZoneStyleEventsProperty);
  RegisterPropertyEditor(TypeInfo(TcxEditValue), TcxCustomCheckGroup, 'EditValue', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomCheckGroup, 'StatesItems', TcxCheckGroupStatesItemsProperty);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomCheckComboBox, 'StatesItems', TcxCheckComboBoxStatesItemsProperty);
  RegisterPropertyEditor(TypeInfo(TcxEditValue), TcxCustomCheckListBox, 'EditValue', nil);
  RegisterPropertyEditor(TypeInfo(TMeasureItemEvent), TcxCustomCheckListBox, 'OnMeasureItem', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxLabelProperties, 'ShowEndEllipsis', nil);
  RegisterPropertyEditor(TypeInfo(TcxEditValue), TcxCustomCheckComboBox, 'EditValue', nil);
  RegisterPropertyEditor(TypeInfo(Variant), TcxCustomCheckComboBox, 'Value', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomSpinButton, 'AutoSize', nil);
  RegisterPropertyEditor(TypeInfo(TTabOrder), TcxCustomLabel, 'TabOrder', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomLabel, 'TabStop', nil);
  RegisterPropertyEditor(TypeInfo(Boolean), TcxCustomCheckComboBoxProperties,
    'AllowGrayed', nil);
  RegisterPropertyEditor(TypeInfo(TcxProgressBarPropertiesValues), TcxCustomProgressBarProperties, 'AssignedValues', nil);
{$IFDEF DELPHI6}
  RegisterPropertyEditor(TypeInfo(Integer), TcxCustomListView, 'ItemIndex', nil);
  RegisterSelectionEditor(TcxCustomListView, TcxCommonControlsSelectionEditor);
  RegisterSelectionEditor(TcxCustomTreeView, TcxCommonControlsSelectionEditor);  
{$ENDIF}

  RegisterPropertyEditor(TypeInfo(TImageIndex), TcxCheckListBoxItem, 'ImageIndex', TcxCheckListBoxItemImageIndexProperty);
  RegisterPropertyEditor(TypeInfo(TImageIndex), TcxHeaderSection, 'ImageIndex', TcxHeaderSectionImageIndexProperty);

  RegisterComponentEditor(TcxCheckListBox, TcxContainerComponentEditor);
  RegisterComponentEditor(TcxCustomCheckGroup, TcxCheckGroupComponentEditor);
  RegisterComponentEditor(TcxCustomHeader, TcxCustomHeaderComponentEditor);
  RegisterComponentEditor(TcxDBCheckListBox, TcxContainerComponentEditor);
  RegisterComponentEditor(TcxHintStyleController, TcxHintStyleComponentEditor);
  RegisterComponentEditor(TcxListView, TcxContainerComponentEditor);
  RegisterComponentEditor(TcxMCListBox, TcxContainerComponentEditor);
  RegisterComponentEditor(TcxSplitter, TcxSplitterComponentEditor);
  RegisterComponentEditor(TcxTreeView, TcxContainerComponentEditor);
end;

initialization
  RegisterEditRepositoryItems;

finalization
  UnregisterEditRepositoryItems;

end.
