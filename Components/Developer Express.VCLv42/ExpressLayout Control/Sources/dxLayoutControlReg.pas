
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl registering unit                    }
{                                                                    }
{           Copyright (c) 2001-2009 Developer Express Inc.           }
{           ALL RIGHTS RESERVED                                      }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSLAYOUTCONTROL AND ALL          }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM       }
{   ONLY.                                                            }
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

unit dxLayoutControlReg;

{$I cxVer.inc}

interface

procedure Register;

implementation

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls,
  {$IFDEF DELPHI6}
    DesignIntf, DesignEditors, DesignMenus, VCLEditors,
  {$ELSE}
    DsgnIntf, DsgnWnds, Menus,
  {$ENDIF}
  dxRegEd, cxLibraryReg,
  dxLayoutCommon, dxLayoutControl, dxLayoutLookAndFeels, dxLayoutDesignCommon, dxLayoutEditForm;

const
  dxLayoutControlMajorVersion = '1';
  dxLayoutControlProductName = 'ExpressLayoutControl';

type
  TControlAccess = class(TControl);
  TLabelAccess = class(TCustomLabel);
  TStaticTextAccess = class(TCustomStaticText);

{ TdxLayoutControlEditor }

type
  TdxLayoutControlEditor = class(TcxComponentEditor)
  private
    function GetControl: TdxLayoutControl;
  protected
    function GetProductMajorVersion: string; override;
    function GetProductName: string; override;
    function InternalGetVerb(AIndex: Integer): string; override;
    function InternalGetVerbCount: Integer; override;
    procedure InternalExecuteVerb(AIndex: Integer); override;

    procedure DoImport;
    property Control: TdxLayoutControl read GetControl;
  public
    procedure PrepareItem(Index: Integer; const AItem: {$IFDEF DELPHI6}IMenuItem{$ELSE}TMenuItem{$ENDIF}); override;
  end;

function TdxLayoutControlEditor.GetControl: TdxLayoutControl;
begin
  Result := TdxLayoutControl(Component);
end;

function TdxLayoutControlEditor.GetProductMajorVersion: string;
begin
  Result := dxLayoutControlMajorVersion;
end;

function TdxLayoutControlEditor.GetProductName: string;
begin
  Result := dxLayoutControlProductName;
end;

function TdxLayoutControlEditor.InternalGetVerb(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'Designer...';
    1: Result := 'Customize...';
    2: Result := 'Import...';
  end;
end;

function TdxLayoutControlEditor.InternalGetVerbCount: Integer;
begin
  Result := 3;
end;

procedure TdxLayoutControlEditor.InternalExecuteVerb(AIndex: Integer);
begin
  case AIndex of
    0: TdxLayoutRealDesigner(dxLayoutDesigner).ShowDesignForm(Control, Designer);
    1: Control.Customization := True;
    2: DoImport;
  end;
end;

procedure TdxLayoutControlEditor.DoImport;
var
  AControlName: string;
  AControlCaptions: TStringList;
  ACaptionLayouts: TList;
  R: TRect;

  function GetRoot: TWinControl;
  begin
    Result := Control.Owner as TWinControl;
  end;

  function CanExport(AControl: TControl): Boolean;
  begin
    Result := (AControl <> Control) and
      not (csNoDesignVisible in AControl.ControlStyle){$IFDEF DELPHI6} and
      not (csSubComponent in AControl.ComponentStyle){$ENDIF};
  end;

  function GetControlsCombo: TComboBox;

    function AddItems(AControl: TWinControl; AStrings: TStrings;
      AInsertionIndex: Integer): Boolean;
    var
      I: Integer;
    begin
      with AControl do
      begin
        Result := CanExport(AControl) and (csAcceptsControls in ControlStyle);
        if Result then
        begin
          AStrings.Insert(AInsertionIndex, Name);
          AInsertionIndex := AStrings.Count;
          for I := 0 to ControlCount - 1 do
            if Controls[I] is TWinControl then
              if AddItems(TWinControl(Controls[I]), AStrings, AInsertionIndex) then
                Inc(AInsertionIndex);
        end;
      end;  
    end;

  begin
    Result := TComboBox.Create(nil);
    with Result do
    begin
      Visible := False;
      Parent := GetParentForm(Control);
      DropDownCount := 15;
      Style := csDropDownList;
      AddItems(GetRoot, Items, 0);
      if Items.Count <> 0 then
        ItemIndex := 0;
    end;
  end;

  function GetControl: TWinControl;
  begin
    if GetRoot.Name = AControlName then
      Result := GetRoot
    else
      Result := GetRoot.FindComponent(AControlName) as TWinControl;
  end;

  function ExportControl(AControl: TControl; AGroup: TdxLayoutGroup;
    out AControlBounds: TRect): Boolean;
  var
    AControlCaption: string;
    AItem: TdxCustomLayoutItem;

    function IsControlGroup: Boolean;
    begin
      Result := (AControl = GetRoot) or
        (AControl is TCustomGroupBox) or (AControl is TCustomPanel);
    end;

    procedure ExportGroupControl;

      procedure ExportChildren;
      var
        AFirstBounds, ABounds: TRect;
        AIsLayoutDirectionAssigned: Boolean;
        I: Integer;

        function GetLayoutDirection(const R1, R2: TRect): TdxLayoutDirection;
        begin
          if (R1.Right <= R2.Left) or (R2.Right <= R1.Left) then
            Result := ldHorizontal
          else
            Result := ldVertical;
        end;

      begin
        SetRectEmpty(AFirstBounds);
        AIsLayoutDirectionAssigned := False;
        I := 0;
        while I < TWinControl(AControl).ControlCount do
        begin
          if not ExportControl(TWinControl(AControl).Controls[I], TdxLayoutGroup(AItem), ABounds) then
            Inc(I);
          if not IsRectEmpty(ABounds) then
            if IsRectEmpty(AFirstBounds) then
              AFirstBounds := ABounds
            else
              if not AIsLayoutDirectionAssigned then
              begin
                TdxLayoutGroup(AItem).LayoutDirection := GetLayoutDirection(AFirstBounds, ABounds);
                AIsLayoutDirectionAssigned := True;
              end;
        end;
      end;

    begin
      if AControl = GetRoot then
        AItem := AGroup
      else
      begin
        AItem := AGroup.CreateGroup;
        TdxLayoutGroup(AItem).Hidden := AControl is TCustomPanel;
        AItem.Caption := AControlCaption;
      end;
      ExportChildren;
    end;

    procedure ExportNonGroupControl;
    var
      AFocusControl: TWinControl;
      ACaptionIndex: Integer;
      AControlItem: TdxLayoutItem;
      ACaptionLayout: TdxCaptionLayout;

      function GetFocusControl: TWinControl;
      begin
        if AControl is TCustomLabel then
          Result := TLabelAccess(AControl).FocusControl
        else
          if AControl is TCustomStaticText then
            Result := TStaticTextAccess(AControl).FocusControl
          else
            Result := nil;
      end;

      function IsLabel: Boolean;
      begin
        Result := (AControl is TCustomLabel) or (AControl is TCustomStaticText);
      end;

      function GetCaptionLayout: TdxCaptionLayout;
      begin
        if AControl.BoundsRect.Right <= AFocusControl.BoundsRect.Left then
          Result := clLeft
        else
          if AControl.BoundsRect.Left >= AFocusControl.BoundsRect.Right then
            Result := clRight
          else
            if AControl.BoundsRect.Bottom <= AFocusControl.BoundsRect.Top then
              Result := clTop
            else
              Result := clBottom;
      end;

      procedure AssignItemCaptionData(AItem: TdxLayoutItem;
        const ACaption: string; ACaptionLayout: TdxCaptionLayout);
      begin
        AItem.Caption := ACaption;
        AItem.CaptionOptions.Layout := ACaptionLayout;
      end;

    begin
      if IsLabel then
        SetRectEmpty(AControlBounds);
      AFocusControl := GetFocusControl;
      if AFocusControl = nil then
      begin
        if {$IFDEF DELPHI6}(AControl is TCustomLabeledEdit) or {$ENDIF}IsLabel then Exit;
        Result := True;
        AItem := AGroup.CreateItemForControl(AControl);
        ACaptionIndex := AControlCaptions.IndexOfObject(AControl);
        if ACaptionIndex <> -1 then
          AssignItemCaptionData(TdxLayoutItem(AItem), AControlCaptions[ACaptionIndex],
            TdxCaptionLayout(ACaptionLayouts[ACaptionIndex]));
      end
      else
      begin
        AControlItem := Control.FindItem(AFocusControl);
        ACaptionLayout := GetCaptionLayout;
        if AControlItem <> nil then
          AssignItemCaptionData(AControlItem, AControlCaption, ACaptionLayout)
        else
        begin
          AControlCaptions.AddObject(AControlCaption, AFocusControl);
          ACaptionLayouts.Add(Pointer(ACaptionLayout));
        end;
      end;
    end;

    procedure ProcessAnchors;
    const
      AlignHorzs: array[Boolean, Boolean] of TdxLayoutAlignHorz =
        ((ahLeft, ahRight), (ahLeft, ahClient));
      AlignVerts: array[Boolean, Boolean] of TdxLayoutAlignVert =
        ((avTop, avBottom), (avTop, avClient));
    begin
      if (AItem = nil) or AItem.IsRoot then Exit;
      with AControl do
      begin
        AItem.AlignHorz := AlignHorzs[akLeft in Anchors, akRight in Anchors];
        AItem.AlignVert := AlignVerts[akTop in Anchors, akBottom in Anchors];
      end;
    end;

  begin
    Result := False;
    SetRectEmpty(AControlBounds);
    if not CanExport(AControl) then Exit;
    AControlCaption := TControlAccess(AControl).Caption;
    AControlBounds := AControl.BoundsRect;
    AItem := nil;
    if IsControlGroup then
      ExportGroupControl
    else
      ExportNonGroupControl;
    ProcessAnchors;
  end;

begin
  AControlName := '';
  if not TLayoutEditForm.Run('Import', 'Choose a control to import data from:',
    AControlName, GetControlsCombo) then Exit;
  AControlCaptions := TStringList.Create;
  ACaptionLayouts := TList.Create;
  try
    Control.BeginUpdate;
    try
      ExportControl(GetControl, Control.Items, R);
      Control.Items.Pack;
    finally
      Control.EndUpdate;
    end;
  finally
    ACaptionLayouts.Free;
    AControlCaptions.Free;
  end;
end;

procedure TdxLayoutControlEditor.PrepareItem(Index: Integer;
  const AItem: {$IFDEF DELPHI6}IMenuItem{$ELSE}TMenuItem{$ENDIF});
begin
  inherited;
  if Index in [1, 2] then
    AItem.Enabled := not IsInInlined;
end;

{ TdxLayoutLookAndFeelListEditor }

type
  TdxLayoutLookAndFeelListEditor = class(TComponentEditor)
  private
    function GetLookAndFeelList: TdxLayoutLookAndFeelList;
  protected
    property LookAndFeelList: TdxLayoutLookAndFeelList read GetLookAndFeelList;
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

function TdxLayoutLookAndFeelListEditor.GetLookAndFeelList: TdxLayoutLookAndFeelList;
begin
  Result := TdxLayoutLookAndFeelList(Component);
end;

procedure TdxLayoutLookAndFeelListEditor.ExecuteVerb(Index: Integer);
begin
  case Index of
    0: TdxLayoutRealDesigner(dxLayoutDesigner).ShowDesignForm(LookAndFeelList, Designer);
  end;
end;

function TdxLayoutLookAndFeelListEditor.GetVerb(Index: Integer): string;
begin
  case Index of
    0: Result := 'Designer...';
  end;
end;

function TdxLayoutLookAndFeelListEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TdxLayoutColorProperty }

const
  DefaultColorText = 'clDefault';

type
  TdxLayoutColorProperty = class(TColorProperty)
  public
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
    procedure ListDrawValue(const Value: string; ACanvas: TCanvas;
      const ARect: TRect; ASelected: Boolean); {$IFNDEF DELPHI6}override;{$ENDIF}
    procedure PropDrawValue(ACanvas: TCanvas; const ARect: TRect;
      ASelected: Boolean);  {$IFNDEF DELPHI6}override;{$ENDIF}
  end;

function TdxLayoutColorProperty.GetValue: string;
begin
  if GetOrdValue = clDefault then
    Result := DefaultColorText
  else
    Result := inherited GetValue;
end;

procedure TdxLayoutColorProperty.GetValues(Proc: TGetStrProc);
begin
  Proc(DefaultColorText);
  inherited;
end;

procedure TdxLayoutColorProperty.SetValue(const Value: string);
begin
  if SameText(Value, DefaultColorText) then
    SetOrdValue(clDefault)
  else
    inherited;
end;

procedure TdxLayoutColorProperty.ListDrawValue(const Value: string;
  ACanvas: TCanvas; const ARect: TRect; ASelected: Boolean);
begin
  if Value = DefaultColorText then
    with ARect do
      ACanvas.TextRect(ARect, Left + (Bottom - Top) + 1, Top + 1, Value)
  else
    inherited;
end;

procedure TdxLayoutColorProperty.PropDrawValue(ACanvas: TCanvas;
  const ARect: TRect; ASelected: Boolean);
begin
  if GetVisualValue = DefaultColorText then
    with ARect do
      ACanvas.TextRect(ARect, Left + 1, Top + 1, GetVisualValue)
  else
    inherited;
end;

{ TdxLayoutRegistryPathProperty }

type
  TdxLayoutRegistryPathProperty = class(TStringProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
  end;

procedure TdxLayoutRegistryPathProperty.Edit;
var
  AControl: TdxLayoutControl;
  S: string;
begin
  AControl := TdxLayoutControl(GetComponent(0));
  S := AControl.RegistryPath;
  if dxGetRegistryPath(S) then
  begin
    AControl.RegistryPath := S;
    Designer.Modified;
  end;
end;

function TdxLayoutRegistryPathProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
end;

procedure Register;
begin
  RegisterComponentEditor(TdxLayoutControl, TdxLayoutControlEditor);
  RegisterComponentEditor(TdxLayoutLookAndFeelList, TdxLayoutLookAndFeelListEditor);

  RegisterPropertyEditor(TypeInfo(TColor), TdxCustomLayoutLookAndFeelOptions, '',
    TdxLayoutColorProperty);
  RegisterPropertyEditor(TypeInfo(TColor), TdxLayoutLookAndFeelCaptionOptions, '',
    TdxLayoutColorProperty);

  RegisterPropertyEditor(TypeInfo(string), TdxLayoutControl, 'RegistryPath',
    TdxLayoutRegistryPathProperty);

  RegisterNoIcon([TdxLayoutItem, TdxLayoutGroup, TdxLayoutAlignmentConstraint,
    TdxLayoutStandardLookAndFeel, TdxLayoutOfficeLookAndFeel, TdxLayoutWebLookAndFeel]);
  RegisterComponents('ExpressLayoutControl', [TdxLayoutControl, TdxLayoutLookAndFeelList])
end;

end.
