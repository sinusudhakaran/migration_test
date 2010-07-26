
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl design-time common classes          }
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

unit dxLayoutDesignCommon;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Forms, StdCtrls, dxLayoutCommon, dxLayoutControl, dxLayoutLookAndFeels,
  {$IFDEF DELPHI6}DesignIntf, DesignEditors, ComponentDesigner, VCLEditors, DesignWindows{$ELSE}
  DsgnIntf, LibIntf, DsgnWnds{$ENDIF};

type
  TFormDesigner = {$IFDEF DELPHI6}IDesigner{$ELSE}IFormDesigner{$ENDIF};
{$IFDEF DELPHI6}
  TDesignerSelectionList = TDesignerSelections;
{$ENDIF}
  TDesignerSelectionListAccess = class(TDesignerSelectionList)
  public
    property Count;
    property Items;
  end;

  TdxLayoutDesignFormClass = class of TdxLayoutDesignForm;

  TdxLayoutDesignForm = class(TDesignWindow)
  private
    FComponent: TComponent;
    FDeletingComponents: Boolean;
    FSelectingComponents: Boolean;
  protected
    procedure DoClose(var Action: TCloseAction); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    function UniqueName(Component: TComponent): string; override;

    function CalculateListBoxItemHeight(AListBox: TListBox = nil): Integer;
    function CanModify: Boolean; virtual;
    procedure DeleteItemsButtonClick(Sender: TObject);
    function GetAddItemsButton(AIndex: Integer): TButton; virtual; abstract;
    function GetAddItemsButtonCount: Integer; virtual; abstract;
    function GetDeleteItemsButton: TButton; virtual; abstract;
    function GetItemsListBox: TListBox; virtual; abstract;
    function GetSelectedItems(AListBox: TListBox = nil): TDesignerSelectionListAccess;
    procedure ItemsListBoxClick(Sender: TObject); virtual;
    function NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean; virtual;
    procedure RefreshEnableds; virtual;
    procedure RefreshItemsListBox; virtual; abstract;
    procedure SetComponent(Value: TComponent); virtual;

    property DeletingComponents: Boolean read FDeletingComponents write FDeletingComponents;
    property SelectingComponents: Boolean read FSelectingComponents write FSelectingComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AfterConstruction; override;

  {$IFDEF DELPHI6}
    procedure ItemDeleted(const ADesigner: IDesigner; Item: TPersistent); override;
  {$ELSE}
    procedure ComponentDeleted(Component: IPersistent); override;
  {$ENDIF}
  {$IFDEF DELPHI6}
    procedure SelectionChanged(const ADesigner: IDesigner; const ASelection: IDesignerSelections); override;
  {$ELSE}
    procedure SelectionChanged(ASelection: TDesignerSelectionList); override;
  {$ENDIF}

    procedure RefreshCaption; virtual;
    procedure RefreshItems; virtual;
    property Component: TComponent read FComponent write SetComponent;
  end;

  PDesignFormRecord = ^TDesignFormRecord;
  TDesignFormRecord = record
    Component: TComponent;
    Form: TdxLayoutDesignForm;
  end;

  TdxLayoutRealDesigner = class(TdxLayoutDesigner{$IFDEF DELPHI6}, IDesignNotification{$ENDIF})
  private
    FComponents: TList;
    FDesignFormRecords: TList;
    FLayoutControlDesignFormBounds: TRect;
    FLayoutLookAndFeelListDesignFormBounds: TRect;
    function GetComponent(Index: Integer): TComponent;
    function GetComponentCount: Integer;
    function GetDesignFormBounds(ADesignForm: TdxLayoutDesignForm): TRect;
    function GetDesignFormRecordCount: Integer;
    function GetDesignFormRecord(Index: Integer): PDesignFormRecord;
    procedure SetDesignFormBounds(ADesignForm: TdxLayoutDesignForm; const Value: TRect);
    //procedure ClearDesignFormRecords;
    procedure DeleteDesignFormRecord(ADesignFormRecord: PDesignFormRecord);
  protected
  {$IFDEF DELPHI6}
    // IDesignNotification
    procedure ItemDeleted(const ADesigner: IDesigner; AItem: TPersistent);
    procedure ItemInserted(const ADesigner: IDesigner; AItem: TPersistent);
    procedure ItemsModified(const ADesigner: IDesigner);
    procedure SelectionChanged(const ADesigner: IDesigner;
      const ASelection: IDesignerSelections);
    procedure DesignerOpened(const ADesigner: IDesigner; AResurrecting: Boolean);
    procedure DesignerClosed(const ADesigner: IDesigner; AGoingDormant: Boolean);
  {$ENDIF}

    function FindDesignFormRecord(AComponent: TComponent): PDesignFormRecord;
    function GetFormDesigner(AComponent: TComponent): TFormDesigner;
    function GetDesignForm(AComponent: TComponent): TdxLayoutDesignForm;
    function GetDesignFormClass(AComponent: TComponent): TdxLayoutDesignFormClass;

    property ComponentCount: Integer read GetComponentCount;
    property Components[Index: Integer]: TComponent read GetComponent;
    property DesignFormBounds[ADesignForm: TdxLayoutDesignForm]: TRect
      read GetDesignFormBounds write SetDesignFormBounds;
    property DesignFormRecordCount: Integer read GetDesignFormRecordCount;
    property DesignFormRecords[Index: Integer]: PDesignFormRecord read GetDesignFormRecord;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure RegisterComponent(AComponent: TComponent); override;
    procedure UnregisterComponent(AComponent: TComponent); override;

    procedure ComponentNameChanged(AComponent: TComponent); override;
    function GetDesigner(AComponent: TComponent): TCustomForm; override;
    function GetUniqueName(AComponent: TComponent; const ABaseName: string): string; override;
    function IsComponentSelected(AComponent: TComponent; APersistent: TPersistent): Boolean; override;
    function IsToolSelected: Boolean; override;
    procedure ItemsChanged(AComponent: TComponent); override;
    procedure SelectComponent(AComponent: TComponent; APersistent: TPersistent;
      AInvertSelection: Boolean); override;

    procedure HideDesignForm(AComponent: TComponent);
    procedure ShowDesignForm(AComponent: TComponent; AFormDesigner: TFormDesigner);
  end;

implementation

uses
  SysUtils, Controls, Graphics, dxLayoutDesignForm, dxLayoutLookAndFeelListDesignForm;

{ TdxLayoutDesignForm }

constructor TdxLayoutDesignForm.Create(AOwner: TComponent);
begin
  inherited;
  BorderIcons := [biSystemMenu];
end;

destructor TdxLayoutDesignForm.Destroy;
begin
  if not (csDestroying in Component.ComponentState) then
    Designer.SelectComponent(Component);
  TdxLayoutRealDesigner(dxLayoutDesigner).HideDesignForm(Component);
  inherited;
end;

procedure TdxLayoutDesignForm.DoClose(var Action: TCloseAction);
begin
  Action := caFree;
  inherited;
end;

procedure TdxLayoutDesignForm.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = Component) then
    Free;
end;

function TdxLayoutDesignForm.UniqueName(Component: TComponent): string;
begin
  Result := Designer.UniqueName(Component.ClassName);
end;

function TdxLayoutDesignForm.CalculateListBoxItemHeight(AListBox: TListBox): Integer;
begin
  if AListBox = nil then
    AListBox := GetItemsListBox;
  Result := 2 + AListBox.Canvas.TextHeight('Qq') + 2;
end;

function TdxLayoutDesignForm.CanModify: Boolean;
begin
  Result := not Designer.IsSourceReadOnly and
    not (csInline in FComponent.Owner.ComponentState);
end;

procedure TdxLayoutDesignForm.DeleteItemsButtonClick(Sender: TObject);
var
  ASelections: TDesignerSelectionListAccess;
  I: Integer;
begin
  FDeletingComponents := True;
  try
    ASelections := GetSelectedItems;
    try
      if ASelections.Count <> 0 then
        try
          Designer.SelectComponent(Component);
          for I := 0 to ASelections.Count - 1 do
            ASelections[I].Free;
        finally
          RefreshItemsListBox;
          Designer.Modified;
        end;
    finally
      ASelections.Free;
    end;
  finally
    FDeletingComponents := False;
  end;
end;

function TdxLayoutDesignForm.GetSelectedItems(AListBox: TListBox): TDesignerSelectionListAccess;
var
  I: Integer;
begin
  if AListBox = nil then
    AListBox := GetItemsListBox;
  Result := TDesignerSelectionListAccess.Create;
  with AListBox, Items do
    for I := 0 to Count - 1 do
      if Selected[I] and (Objects[I] <> nil) then
        Result.Add(TPersistent(Objects[I]));
end;

procedure TdxLayoutDesignForm.ItemsListBoxClick(Sender: TObject);
var
  ASelections: TDesignerSelectionListAccess;
begin
  ASelections := GetSelectedItems(Sender as TListBox);
  with ASelections do
    if Count = 0 then Add(Component);
  FSelectingComponents := True;
  try
    Designer.SetSelections(ASelections);
  finally
    FSelectingComponents := False;
    RefreshEnableds;
  end;
end;

function TdxLayoutDesignForm.NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean;
begin
  Result := not (csDestroying in Component.ComponentState);
end;

procedure TdxLayoutDesignForm.RefreshEnableds;
var
  ASelections: TDesignerSelectionListAccess;
  I: Integer;
begin
  ASelections := GetSelectedItems;
  try
    for I := 0 to GetAddItemsButtonCount - 1 do
      GetAddItemsButton(I).Enabled := CanModify;
    GetDeleteItemsButton.Enabled := CanModify and (ASelections.Count <> 0);
  finally
    ASelections.Free;
  end;
end;

procedure TdxLayoutDesignForm.SetComponent(Value: TComponent);
begin
  FComponent := Value;
  FComponent.FreeNotification(Self);
  RefreshCaption;
  RefreshItemsListBox;
  RefreshEnableds;
end;

procedure TdxLayoutDesignForm.AfterConstruction;
begin
  inherited;
  with GetItemsListBox do
  begin
    ItemHeight := CalculateListBoxItemHeight;
    OnClick := ItemsListBoxClick;
  end;
  GetDeleteItemsButton.OnClick := DeleteItemsButtonClick;
end;

{$IFDEF DELPHI6}
procedure TdxLayoutDesignForm.ItemDeleted(const ADesigner: IDesigner; Item: TPersistent);
{$ELSE}
procedure TdxLayoutDesignForm.ComponentDeleted(Component: IPersistent);
{$ENDIF}
var
  AComponent: TPersistent;
begin
  inherited;
  if FDeletingComponents then Exit;
{$IFDEF DELPHI6}
  AComponent := Item;
{$ELSE}
  AComponent := ExtractPersistent(Component);
{$ENDIF}
  if NeedRefreshItemsAfterDeleting(AComponent) then
    RefreshItems;
end;

{$IFDEF DELPHI6}
procedure TdxLayoutDesignForm.SelectionChanged(const ADesigner: IDesigner; const ASelection: IDesignerSelections);
{$ELSE}
procedure TdxLayoutDesignForm.SelectionChanged(ASelection: TDesignerSelectionList);
{$ENDIF}
var
  I, AIndex: Integer;
{$IFNDEF DELPHI6}
  ALayoutComponent: IdxLayoutComponent;
{$ENDIF}
begin
  inherited;
{$IFNDEF DELPHI6}
  if Component.GetInterface(IdxLayoutComponent, ALayoutComponent) then
    ALayoutComponent.SelectionChanged;
{$ENDIF}
  if FSelectingComponents then Exit;
  with GetItemsListBox, Items do
  begin
    BeginUpdate;
    try
      for I := 0 to Count - 1 do
        Selected[I] := False;
      if ASelection <> nil then
        for I := 0 to ASelection.Count - 1 do
        begin
          AIndex := IndexOfObject(ASelection[I]);
          if AIndex <> -1 then
            Selected[AIndex] := True;
        end;
    finally
      EndUpdate;
      RefreshEnableds;
    end;
  end;
end;

procedure TdxLayoutDesignForm.RefreshCaption;
begin
  Caption := 'Designer - ' + FComponent.Name;
end;

procedure TdxLayoutDesignForm.RefreshItems;
var
  ASelections: IDesignerSelections;
begin
  ASelections := CreateSelectionList;
  Designer.GetSelections(ASelections);
  RefreshItemsListBox;
{$IFDEF DELPHI6}
  SelectionChanged(Designer, ASelections);
{$ELSE}
  SelectionChanged(ASelections);
{$ENDIF}
end;

{ TdxLayoutRealDesigner }

constructor TdxLayoutRealDesigner.Create(AOwner: TComponent);
begin
  inherited;
  FComponents := TList.Create;
  FDesignFormRecords := TList.Create;
{$IFDEF DELPHI6}
  RegisterDesignNotification(Self);
{$ENDIF}
end;

destructor TdxLayoutRealDesigner.Destroy;
begin
{$IFDEF DELPHI6}
  UnregisterDesignNotification(Self);
{$ENDIF}  
  FComponents.Free;
  //ClearDesignFormRecords;
  FDesignFormRecords.Free;
  inherited;
end;

function TdxLayoutRealDesigner.GetComponent(Index: Integer): TComponent;
begin
  Result := FComponents[Index];
end;

function TdxLayoutRealDesigner.GetComponentCount: Integer;
begin
  Result := FComponents.Count;
end;

function TdxLayoutRealDesigner.GetDesignFormBounds(ADesignForm: TdxLayoutDesignForm): TRect;
begin
  if ADesignForm is TDesignForm then
    Result := FLayoutControlDesignFormBounds
  else
    if ADesignForm is TLookAndFeelListDesignForm then
      Result := FLayoutLookAndFeelListDesignFormBounds
    else
      SetRectEmpty(Result);
end;

function TdxLayoutRealDesigner.GetDesignFormRecordCount: Integer;
begin
  Result := FDesignFormRecords.Count;
end;

function TdxLayoutRealDesigner.GetDesignFormRecord(Index: Integer): PDesignFormRecord;
begin
  Result := FDesignFormRecords[Index];
end;

procedure TdxLayoutRealDesigner.SetDesignFormBounds(ADesignForm: TdxLayoutDesignForm;
  const Value: TRect);
begin
  if ADesignForm is TDesignForm then
    FLayoutControlDesignFormBounds := Value
  else
    if ADesignForm is TLookAndFeelListDesignForm then
      FLayoutLookAndFeelListDesignFormBounds := Value;
end;

{procedure TdxLayoutRealDesigner.ClearDesignFormRecords;
var
  I: Integer;
begin
  for I := DesignFormRecordCount - 1 downto 0 do
    DeleteDesignFormRecord(DesignFormRecords[I]);
end;}

procedure TdxLayoutRealDesigner.DeleteDesignFormRecord(ADesignFormRecord: PDesignFormRecord);
begin
  FDesignFormRecords.Remove(ADesignFormRecord);
  Dispose(ADesignFormRecord);
end;

{$IFDEF DELPHI6}

procedure TdxLayoutRealDesigner.ItemDeleted(const ADesigner: IDesigner; AItem: TPersistent);
begin
end;

procedure TdxLayoutRealDesigner.ItemInserted(const ADesigner: IDesigner; AItem: TPersistent);
begin
end;

procedure TdxLayoutRealDesigner.ItemsModified(const ADesigner: IDesigner);
begin
end;

procedure TdxLayoutRealDesigner.SelectionChanged(const ADesigner: IDesigner;
  const ASelection: IDesignerSelections);
var
  I: Integer;
  ALayoutComponent: IdxLayoutComponent;

  function HasAsOwner(AComponent, AOwner: TComponent): Boolean;
  begin
    repeat
      Result := AComponent.Owner = AOwner;
      AComponent := AComponent.Owner;
    until Result or (AComponent = nil);
  end;

begin
  for I := 0 to ComponentCount - 1 do
    if ((ADesigner = nil) or HasAsOwner(Components[I], ADesigner.GetRoot)) and
      Components[I].GetInterface(IdxLayoutComponent, ALayoutComponent) then
      ALayoutComponent.SelectionChanged;
end;

procedure TdxLayoutRealDesigner.DesignerOpened(const ADesigner: IDesigner;
  AResurrecting: Boolean);
begin
end;

procedure TdxLayoutRealDesigner.DesignerClosed(const ADesigner: IDesigner;
  AGoingDormant: Boolean);
begin
end;

{$ENDIF}

function TdxLayoutRealDesigner.FindDesignFormRecord(AComponent: TComponent): PDesignFormRecord;
var
  I: Integer;
begin
  for I := 0 to DesignFormRecordCount - 1 do
  begin
    Result := DesignFormRecords[I];
    if Result^.Component = AComponent then Exit;
  end;
  Result := nil;
end;

function TdxLayoutRealDesigner.GetFormDesigner(AComponent: TComponent): TFormDesigner;
begin
  Result := FindRootDesigner(AComponent) as TFormDesigner;
end;

function TdxLayoutRealDesigner.GetDesignForm(AComponent: TComponent): TdxLayoutDesignForm;
var
  ADesignFormRecord: PDesignFormRecord;
begin
  ADesignFormRecord := FindDesignFormRecord(AComponent);
  if ADesignFormRecord = nil then
    Result := nil
  else
    Result := ADesignFormRecord^.Form;
end;

function TdxLayoutRealDesigner.GetDesignFormClass(AComponent: TComponent): TdxLayoutDesignFormClass;
begin
  if AComponent is TdxCustomLayoutControl then
    Result := TDesignForm
  else
    if AComponent is TdxLayoutLookAndFeelList then
      Result := TLookAndFeelListDesignForm
    else
      Result := nil;
end;

procedure TdxLayoutRealDesigner.RegisterComponent(AComponent: TComponent);
begin
  FComponents.Add(AComponent);
end;

procedure TdxLayoutRealDesigner.UnregisterComponent(AComponent: TComponent);
begin
  FComponents.Remove(AComponent);
end;

procedure TdxLayoutRealDesigner.ComponentNameChanged(AComponent: TComponent);
var
  ADesignForm: TdxLayoutDesignForm;
begin
  ADesignForm := GetDesignForm(AComponent);
  if ADesignForm <> nil then ADesignForm.RefreshCaption;
end;

function TdxLayoutRealDesigner.GetDesigner(AComponent: TComponent): TCustomForm;
begin
  Result := GetDesignForm(AComponent);
end;

function TdxLayoutRealDesigner.GetUniqueName(AComponent: TComponent;
  const ABaseName: string): string;
begin
  Result := GetFormDesigner(AComponent).UniqueName(ABaseName);
end;

function TdxLayoutRealDesigner.IsComponentSelected(AComponent: TComponent;
  APersistent: TPersistent): Boolean;
var
  ASelections: IDesignerSelections;
  I: Integer;
begin
  if GetFormDesigner(AComponent) = nil then
    Result := False
  else
  begin
    ASelections := CreateSelectionList;
    GetFormDesigner(AComponent).GetSelections(ASelections);
    for I := 0 to ASelections.Count - 1 do
    begin
      Result :=
        {$IFNDEF DELPHI6}ExtractPersistent{$ENDIF}(ASelections[I]) = APersistent;
      if Result then Exit;
    end;
    Result := False;
  end;  
end;

function TdxLayoutRealDesigner.IsToolSelected: Boolean;
begin
  Result := {$IFDEF DELPHI9}(ActiveDesigner <> nil) and{$ENDIF}
    {$IFDEF DELPHI6}ActiveDesigner.Environment{$ELSE}DelphiIDE{$ENDIF}.GetToolSelected;
end;

procedure TdxLayoutRealDesigner.ItemsChanged(AComponent: TComponent);
var
  ADesignForm: TdxLayoutDesignForm;
begin
  ADesignForm := GetDesignForm(AComponent);
  if ADesignForm <> nil then ADesignForm.RefreshItems;
end;

procedure TdxLayoutRealDesigner.SelectComponent(AComponent: TComponent;
  APersistent: TPersistent; AInvertSelection: Boolean);
var
  ASelections, ANewSelections: IDesignerSelections;
  I: Integer;
  ASelection: TPersistent;
begin
  if AInvertSelection then
  begin
    ASelections := CreateSelectionList;
    GetFormDesigner(AComponent).GetSelections(ASelections);
    ANewSelections := CreateSelectionList;
    for I := 0 to ASelections.Count - 1 do
    begin
      ASelection := {$IFNDEF DELPHI6}ExtractPersistent{$ENDIF}(ASelections[I]);
      if (ASelection <> AComponent) and (ASelection <> APersistent) then
        ANewSelections.Add(ASelections[I]);
    end;
    if IsComponentSelected(AComponent, APersistent) then
      if ANewSelections.Count = 0 then
        ANewSelections.Add({$IFNDEF DELPHI6}MakeIPersistent{$ENDIF}(AComponent))
      else
    else
      ANewSelections.Add({$IFNDEF DELPHI6}MakeIPersistent{$ENDIF}(APersistent));
    GetFormDesigner(AComponent).SetSelections(ANewSelections);
  end
  else
    GetFormDesigner(AComponent).SelectComponent(APersistent);
end;

procedure TdxLayoutRealDesigner.HideDesignForm(AComponent: TComponent);
var
  ADesignFormRecord: PDesignFormRecord;
begin
  ADesignFormRecord := FindDesignFormRecord(AComponent);
  DesignFormBounds[ADesignFormRecord.Form] := ADesignFormRecord.Form.BoundsRect;
  DeleteDesignFormRecord(ADesignFormRecord);
end;

procedure TdxLayoutRealDesigner.ShowDesignForm(AComponent: TComponent;
  AFormDesigner: TFormDesigner);
var
  ADesignForm: TdxLayoutDesignForm;
  ADesignFormBounds: TRect;
  ADesignFormRecord: PDesignFormRecord;
begin
  ADesignForm := GetDesignForm(AComponent);
  if ADesignForm = nil then
  begin
    ADesignForm := GetDesignFormClass(AComponent).Create(nil);
    ADesignForm.Designer := AFormDesigner;
    ADesignForm.Component := AComponent;

    New(ADesignFormRecord);
    with ADesignFormRecord^ do
    begin
      Component := AComponent;
      Form := ADesignForm;
    end;
    FDesignFormRecords.Add(ADesignFormRecord);

    ADesignForm.Show;

    ADesignFormBounds := DesignFormBounds[ADesignForm];
    if not IsRectEmpty(ADesignFormBounds) then
      ADesignForm.BoundsRect := ADesignFormBounds;
  end
  else
    ADesignForm.BringToFront;
end;

initialization
  dxLayoutDesigner := TdxLayoutRealDesigner.Create(nil);

finalization
  FreeAndNil(dxLayoutDesigner);

end.
