{*******************************************************************}
{                                                                   }
{       Developer Express Cross Platform Component Library          }
{       Express Cross Platform Library classes                      }
{                                                                   }
{       Copyright (c) 2001-2009 Developer Express Inc.              }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL  }
{   ACCOMPANYING VCL AND CLX CONTROLS AS PART OF AN EXECUTABLE      }
{   PROGRAM ONLY.                                                   }
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
unit cxPropertiesStoreEditor;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ToolWin, ExtCtrls, StdCtrls, cxPropertiesStore, cxStorage, ActnList,
{$IFDEF DELPHI6}
  DesignIntf,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  cxControls, ImgList, cxDesignWindows;

type
  TfrmPropertiesStoreFilter = (psfNone, psfStored, psfUnStored);
  TfrmPropertiesStoreGrouping = (psgComponents, psgProperties);

  PfrmPropertiesStoreRecord = ^TfrmPropertiesStoreRecord;
  TfrmPropertiesStoreRecord = record
    Persistent: TPersistent;
    PropertyName: string;
    Stored: Boolean;
  end;

  TfrmPropertiesStoreEditor = class(TForm)
    pnlClient: TPanel;
    ToolBar: TToolBar;
    pnlLeftTree: TPanel;
    pnlLeftTreeTop: TPanel;
    Tree: TTreeView;
    pnlButtons: TPanel;
    lblFindComponent: TLabel;
    edFindComponent: TEdit;
    btnGroupByComponents: TToolButton;
    btnGroupByProperties: TToolButton;
    ToolButton3: TToolButton;
    btnReset: TToolButton;
    btnCheckAll: TToolButton;
    btnUncheckAll: TToolButton;
    ActionList1: TActionList;
    actGroupByComponents: TAction;
    actGroupByProperties: TAction;
    Panel1: TPanel;
    Panel2: TPanel;
    btnOK: TButton;
    btnCancel: TButton;
    btnInvertChecking: TToolButton;
    ImageList1: TImageList;
    procedure TreeDeletion(Sender: TObject; Node: TTreeNode);
    procedure TreeCustomDrawItem(Sender: TCustomTreeView; Node: TTreeNode;
      State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure actGroupByComponentsExecute(Sender: TObject);
    procedure actGroupByPropertiesExecute(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure TreeKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCheckAllClick(Sender: TObject);
    procedure btnUncheckAllClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure btnInvertCheckingClick(Sender: TObject);
    procedure edFindComponentKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TreeContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
  private
    FFilter: TfrmPropertiesStoreFilter;
    FGrouping: TfrmPropertiesStoreGrouping;
    FPropertiesStore: TcxPropertiesStore;
    FOwnerComponent: TComponent;
    FDesigner: IDesigner;
    procedure SetOwnerComponent(const Value: TComponent);
    procedure SetFilter(const Value: TfrmPropertiesStoreFilter);
    procedure SetGrouping(const Value: TfrmPropertiesStoreGrouping);
    procedure SetFindText;
    procedure ChangeCheckState(ANode: TTreeNode);
    procedure CheckNode(ANode: TTreeNode; AWithChildren: Boolean = True; AWithParents: Boolean = True);
    procedure UncheckNode(ANode: TTreeNode; AWithChildren: Boolean = True; AWithParents: Boolean = True);
    procedure InvertCheck;
    procedure LoadFromPropertiesStore(APropertiesStore: TcxPropertiesStore);
    procedure SaveToPropertiesStore(APropertiesStore: TcxPropertiesStore);
    function IsNodeChecked(ANode: TTreeNode): Boolean;
    function IsNodeFullChecked(ANode: TTreeNode): Boolean;
    procedure BeginUpdate;
    procedure EndUpdate;
    function FindNode(const AText: string): TTreeNode;
    procedure Reset;
    procedure CheckAll;
    procedure UncheckAll;
    procedure InvertChecking;
  protected
    procedure RefreshTree;
  public
    property Filter: TfrmPropertiesStoreFilter read FFilter write SetFilter;
    property Grouping: TfrmPropertiesStoreGrouping read FGrouping write SetGrouping;
    property OwnerComponent: TComponent read FOwnerComponent write SetOwnerComponent;
    property PropertiesStore: TcxPropertiesStore read FPropertiesStore write FPropertiesStore;
    Property Designer: IDesigner read FDesigner write FDesigner;
  end;

const
  scxFindComponent = 'Find Component:';
  scxFindProperty = 'Find Property:';

procedure ShowPropertiesStoreEditor(APropertiesStore: TcxPropertiesStore;
  AOwnerComponent: TComponent; ADesigner: IDesigner);

implementation

{$R *.dfm}

uses
  TypInfo, cxClasses, dxCore;

procedure ShowPropertiesStoreEditor(APropertiesStore: TcxPropertiesStore;
  AOwnerComponent: TComponent; ADesigner: IDesigner);
var
  AForm: TfrmPropertiesStoreEditor;
begin
  AForm := TfrmPropertiesStoreEditor.Create(nil);
  {$IFDEF DELPHI9}
  AForm.PopupMode := pmAuto;
  {$ENDIF}
  AForm.OwnerComponent := AOwnerComponent;
  AForm.PropertiesStore := APropertiesStore;
  AForm.Designer := ADesigner;
  try
    AForm.ShowModal;
  finally
    AForm.Free;
  end;
end;

{ TfrmPropertiesStoreEditor }

procedure TfrmPropertiesStoreEditor.RefreshTree;
var
  ANullLevelNodeList: TList;

  function AddPropertyNode(const APropertyName: string; AParentNode: TTreeNode = nil): TTreeNode;
  var
    I: Integer;
    ANode: TTreeNode;
    AUpperCasePropertyName: string;
    AData: PfrmPropertiesStoreRecord;
  begin
    Result := nil;
    AUpperCasePropertyName := UpperCase(APropertyName);
    for I := 0 to ANullLevelNodeList.Count - 1 do
    begin
      ANode := TTreeNode(ANullLevelNodeList[I]);
      if UpperCase(ANode.Text) = AUpperCasePropertyName then
      begin
        Result := ANode;
        Break;
      end;
    end;
    if Result = nil then
    begin
      Result := Tree.Items.AddChild(nil, APropertyName);
      New(AData);
      Result.Data := AData;
      AData.Stored := False;
      ANullLevelNodeList.Add(Result);
    end;
  end;

  procedure AddPersistent(APersistent: TPersistent; const AName: string;
    AParentNode: TTreeNode = nil; APersistentObject: TPersistent = nil);
  var
    APersistentNode, ANode: TTreeNode;
    APropList: PPropList;
    APropCount, I: Integer;
    AData: PfrmPropertiesStoreRecord;
    AObject: TObject;
  begin
    {$IFDEF DELPHI6}
    APropCount := GetPropList(APersistent, APropList);
    {$ELSE}
    APropCount := GetTypeData(PTypeInfo(APersistent.ClassInfo))^.PropCount;
    GetMem(APropList,  APropCount * SizeOf(Pointer));
    GetPropInfos(PTypeInfo(APersistent.ClassInfo), APropList);
    {$ENDIF}
    try
      if Grouping = psgComponents then
      begin
        APersistentNode := Tree.Items.AddChild(AParentNode, AName);
        New(AData);
        APersistentNode.Data := AData;
        if APersistentObject = nil then
          AData.Persistent := APersistent
        else
          AData.Persistent := APersistentObject;
        AData.PropertyName := '';
        AData.Stored := False;
//        if APersistent is TCollection then
//          with TCollection(APersistent) do
//            for I := 0 to Count - 1 do
//              AddPersistent(Items[I], IntToStr(I), APersistentNode);
        for I := 0 to APropCount - 1 do
          if APropList[I].PropType^.Kind <> tkMethod then
          begin
            if APropList[I].PropType^.Kind = tkClass then
            begin
              AObject := GetObjectProp(APersistent, APropList[I]);
              if (AObject is TPersistent) and not (AObject is TComponent) then
              begin
                AddPersistent(AObject as TPersistent, dxShortStringToString(APropList[I].Name),
                  APersistentNode);
                Continue;
              end;
            end;
            ANode := Tree.Items.AddChild(APersistentNode, dxShortStringToString(APropList[I].Name));
            New(AData);
            ANode.Data := AData;
            AData.Persistent := APersistent;
            AData.PropertyName := dxShortStringToString(APropList[I].Name);
            AData.Stored := False;
          end
      end
      else if Grouping = psgProperties then
      begin
        for I := 0 to APropCount - 1 do
          if APropList[I].PropType^.Kind <> tkMethod then
          begin
            ANode := AddPropertyNode(dxShortStringToString(APropList[I].Name));
            if APropList[I].PropType^.Kind = tkClass then
            begin
              AObject := GetObjectProp(APersistent, APropList[I]);
              if (AObject is TPersistent) and not (AObject is TComponent) then
              begin
                FGrouping := psgComponents;
                try
                  AddPersistent(AObject as TPersistent, AName, ANode, APersistent);
                finally
                  FGrouping := psgProperties;
                end;
                Continue;
              end;
            end;
            APersistentNode := Tree.Items.AddChild(ANode, AName);
            New(AData);
            APersistentNode.Data := AData;
            AData.Persistent := APersistent;
            AData.PropertyName := dxShortStringToString(APropList[I].Name);
            AData.Stored := False;
          end;
      end;
    finally
      if APropCount > 0 then
      	{$IFNDEF DELPHI5}
        FreeMem(APropList, APropCount * SizeOf(Pointer));
        {$ELSE}
        FreeMem(APropList);
        {$ENDIF}
    end;
  end;

var
  I: Integer;
begin
  Tree.Items.Clear;
  ANullLevelNodeList := TList.Create;
  try
    Tree.SortType := stNone;
    if FOwnerComponent <> nil then
    begin
      AddPersistent(FOwnerComponent, FOwnerComponent.Name);
      for I := 0 to FOwnerComponent.ComponentCount - 1 do
        AddPersistent(FOwnerComponent.Components[I], FOwnerComponent.Components[I].Name);
    end;
    Tree.SortType := stText;
  finally
    ANullLevelNodeList.Free;
  end;
end;

procedure TfrmPropertiesStoreEditor.SetFilter(
  const Value: TfrmPropertiesStoreFilter);
begin
  if Filter <> Value then
  begin
    FFilter := Value;
    RefreshTree;
  end;
end;

procedure TfrmPropertiesStoreEditor.SetGrouping(
  const Value: TfrmPropertiesStoreGrouping);
var
  APropertiesStore: TcxPropertiesStore;
  ALastValue: TfrmPropertiesStoreGrouping;
begin
  if Grouping <> Value then
  begin
    APropertiesStore := TcxPropertiesStore.Create(nil);
    try
      SaveToPropertiesStore(APropertiesStore);
      ALastValue := FGrouping;
      FGrouping := Value;
      try
        RefreshTree;
        LoadFromPropertiesStore(APropertiesStore);
        SetFindText;
      except
        FGrouping := ALastValue;
        raise;
      end;
    finally
      APropertiesStore.Free;
    end;
  end;
end;

procedure TfrmPropertiesStoreEditor.ChangeCheckState(ANode: TTreeNode);
begin
  if ANode.Data <> nil then
  begin
    if PfrmPropertiesStoreRecord(ANode.Data)^.Stored then
      UnCheckNode(ANode)
    else
      CheckNode(ANode);
  end;
end;

procedure TfrmPropertiesStoreEditor.CheckNode(ANode: TTreeNode;
  AWithChildren: Boolean; AWithParents: Boolean);
var
  I: Integer;
  AParentNode: TTreeNode;
begin
  PfrmPropertiesStoreRecord(ANode.Data)^.Stored := True;
  if AWithChildren then
    for I := 0 to ANode.Count - 1 do
      CheckNode(ANode[I], True, False);
  if AWithParents then
  begin
    AParentNode := ANode.Parent;
    if AParentNode <> nil then
      CheckNode(AParentNode, False, True);
  end;
end;

procedure TfrmPropertiesStoreEditor.UncheckNode(ANode: TTreeNode;
  AWithChildren: Boolean; AWithParents: Boolean);
var
  I: Integer;
  AParentNode: TTreeNode;
  ANeedUncheckParent: Boolean;
begin
  PfrmPropertiesStoreRecord(ANode.Data)^.Stored := False;
  if AWithChildren then
    for I := 0 to ANode.Count - 1 do
      UncheckNode(ANode[I], True, False);
  if AWithParents then
  begin
    AParentNode := ANode.Parent;
    if AParentNode <> nil then
    begin
      ANeedUncheckParent := True;
      for I := 0 to AParentNode.Count - 1 do
        if AParentNode[I].Data <> nil then
          if PfrmPropertiesStoreRecord(AParentNode[I].Data)^.Stored then
          begin
            ANeedUncheckParent := False;
            Break;
          end;
      if ANeedUncheckParent then
        UncheckNode(AParentNode, False, True);
    end;
  end;
end;

procedure TfrmPropertiesStoreEditor.SetOwnerComponent(
  const Value: TComponent);
begin
  if FOwnerComponent <> Value then
  begin
    FOwnerComponent := Value;
    try
      BeginUpdate;
      RefreshTree;
    finally
      EndUpdate;
    end;
  end;
end;

procedure TfrmPropertiesStoreEditor.TreeDeletion(Sender: TObject;
  Node: TTreeNode);
begin
  if (Node.Data <> nil) then
    Dispose(PfrmPropertiesStoreRecord(Node.Data));
end;

procedure TfrmPropertiesStoreEditor.TreeCustomDrawItem(
  Sender: TCustomTreeView; Node: TTreeNode; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  with Tree.Canvas do
  begin
    if Node.Data <> nil then
    begin
      if PfrmPropertiesStoreRecord(Node.Data)^.Stored then
      begin
        if Node.Selected and Tree.Focused then
          Font.Color := RGB(255, 255, 255)
        else
          Font.Color := RGB(0, 0, 255);
        Font.Style := [fsBold];
      end;
    end;
  end;
end;

procedure TfrmPropertiesStoreEditor.FormCreate(Sender: TObject);
begin
  FGrouping := psgComponents;
end;

procedure TfrmPropertiesStoreEditor.actGroupByComponentsExecute(
  Sender: TObject);
begin
  BeginUpdate;
  try
    Grouping := psgComponents;
  finally
    EndUpdate;
  end;
end;

procedure TfrmPropertiesStoreEditor.actGroupByPropertiesExecute(
  Sender: TObject);
begin
  BeginUpdate;
  try
    Grouping := psgProperties;
  finally
    EndUpdate;
  end;
end;

procedure TfrmPropertiesStoreEditor.btnOKClick(Sender: TObject);
begin
  SaveToPropertiesStore(nil);
  Designer.Modified;
  Close;
end;

procedure TfrmPropertiesStoreEditor.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPropertiesStoreEditor.TreeKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  if TranslateKey(Key) = VK_RETURN then
    if Tree.Selected <> nil then
    begin
      BeginUpdate();
      try
        ChangeCheckState(Tree.Selected);
      finally
        EndUpdate();
      end;
    end;
end;

procedure TfrmPropertiesStoreEditor.btnCheckAllClick(Sender: TObject);
begin
  CheckAll;
end;

procedure TfrmPropertiesStoreEditor.btnUncheckAllClick(Sender: TObject);
begin
  UncheckAll;
end;

procedure TfrmPropertiesStoreEditor.LoadFromPropertiesStore(
  APropertiesStore: TcxPropertiesStore);

  function ExtractName(var AName: string): string;
  var
    AIndex: Integer;
  begin
    Result := '';
    AIndex := Pos('.', AName);
    if AIndex > 0 then
    begin
      if AIndex > 1 then
        Result := Copy(AName, 1, AIndex - 1);
      Delete(AName, 1, AIndex);
    end
    else
    begin
      Result := AName;
      AName := '';
    end;
  end;

  function GetPropertyNode(APersistentNode: TTreeNode; const APropertyName: string): TTreeNode;
  var
    AName: string;
    AUpperCaseCurrentName: string;
    ACurrentName: string;
    I: Integer;
  begin
    Result := nil;
    AName := APropertyName;
    ACurrentName := ExtractName(AName);
    if ACurrentName <> '' then
    begin
      AUpperCaseCurrentName := UpperCase(ACurrentName);
      for I := 0 to APersistentNode.Count - 1 do
        if UpperCase(APersistentNode[I].Text) = AUpperCaseCurrentName then
        begin
          Result := APersistentNode[I];
          Break;
        end;
      if Result <> nil then
      begin
        if AName <> '' then
          Result := GetPropertyNode(Result, AName);
      end;
    end;
  end;

  function GetPersistentNode(APersistent: TPersistent): TTreeNode;
  var
    ANode: TTreeNode;
  begin
    Result := nil;
    ANode := Tree.Items.GetFirstNode;
    while ANode <> nil do
    begin
      if ANode.Data <> nil then
        with PfrmPropertiesStoreRecord(ANode.Data)^ do
          if (Persistent = APersistent) and (PropertyName = '') then
          begin
            Result := ANode;
            Break;
          end;
      ANode := ANode.getNextSibling;
    end;
  end;

  function GetPersistentNodeByProperty(var APropertyName: string; APersistent: TPersistent): TTreeNode;
  var
    APropertyNode: TTreeNode;
    AName: string;
    AUpperCaseName: string;
    I: Integer;
  begin
    Result := nil;
    if (APropertyName = '') or (APersistent = nil) then
      Exit;
    AName := ExtractName(APropertyName);
    if AName <> '' then
    begin
      AUpperCaseName := UpperCase(AName);
      APropertyNode := Tree.Items.GetFirstNode;
      while APropertyNode <> nil do
      begin
        if AUpperCaseName = UpperCase(APropertyNode.Text) then
          for I := 0 to APropertyNode.Count - 1 do
            if APropertyNode[I].Data <> nil then
              if PfrmPropertiesStoreRecord(APropertyNode[I].Data)^.Persistent = APersistent then
              begin
                Result := APropertyNode[I];
                Exit;
              end;
        APropertyNode := APropertyNode.getNextSibling;
      end;
    end;
  end;

var
  APS: TcxPropertiesStore;
  I, J: Integer;
  APersistentNode: TTreeNode;
  APropertyNode: TTreeNode;
  APropertyName: string;
begin
  if APropertiesStore = nil then
    APS := PropertiesStore
  else
    APS := APropertiesStore;
  if APS <> nil then
  begin
    for I := 0 to APS.Components.Count - 1 do
      with APS.Components[I] do
      begin
        if Grouping = psgComponents then
        begin
          APersistentNode := GetPersistentNode(Component);
          if APersistentNode <> nil then
          begin
            for J := 0 to Properties.Count - 1 do
            begin
              APropertyNode := GetPropertyNode(APersistentNode, Properties[J]);
              if APropertyNode <> nil then
                if APropertyNode.Data <> nil then
                  CheckNode(APropertyNode);
            end;
          end;
        end
        else if Grouping = psgProperties then
        begin
          for J := 0 to Properties.Count - 1 do
          begin
            APropertyName := Properties[J];
            APersistentNode := GetPersistentNodeByProperty(APropertyName, Component);
            if APersistentNode <> nil then
            begin
              if APropertyName <> '' then
              begin
                APropertyNode := GetPropertyNode(APersistentNode, APropertyName);
                if APropertyNode <> nil then
                  CheckNode(APropertyNode);
              end
              else
                CheckNode(APersistentNode);
            end;
          end;
        end;
      end;
  end;
end;

procedure TfrmPropertiesStoreEditor.FormShow(Sender: TObject);
begin
  LoadFromPropertiesStore(nil);
end;

procedure TfrmPropertiesStoreEditor.btnResetClick(Sender: TObject);
begin
  Reset;
end;

procedure TfrmPropertiesStoreEditor.SaveToPropertiesStore(
  APropertiesStore: TcxPropertiesStore);
var
  APS: TcxPropertiesStore;

  procedure SaveComponentProperties(APSC: TcxPropertiesStoreComponent;
    ANode: TTreeNode; const AName: string);
  var
    I: Integer;
  begin
    for I := 0 to ANode.Count - 1 do
    begin
      if IsNodeFullChecked(ANode[I]) then
        APSC.Properties.Add(AName + '.' + ANode[I].Text)
      else
      begin
        if IsNodeChecked(ANode[I]) then
          SaveComponentProperties(APSC, ANode[I], AName + '.' + ANode[I].Text);
      end;
    end;
  end;

  procedure SaveComponent(APersistentNode: TTreeNode);
  var
    APSC: TcxPropertiesStoreComponent;
    APersistent: TPersistent;
    I: Integer;
  begin
    APersistent := PfrmPropertiesStoreRecord(APersistentNode.Data)^.Persistent;
    if APersistent is TComponent then
    begin
      APSC := APS.Components.Add as TcxPropertiesStoreComponent;
      APSC.Component := APersistent as TComponent;
      for I := 0 to APersistentNode.Count - 1 do
      begin
        if IsNodeFullChecked(APersistentNode[I]) then
          APSC.Properties.Add(APersistentNode[I].Text)
        else
        begin
          if IsNodeChecked(APersistentNode[I]) then
            SaveComponentProperties(APSC, APersistentNode[I], APersistentNode[I].Text);
        end;
      end;
    end;
  end;

  function GetPropertiesStoreComponent(AComponent: TComponent): TcxPropertiesStoreComponent;
  var
    I: Integer;
  begin
    Result := nil;
    for I := 0 to APS.Components.Count - 1 do
      if APS.Components[I].Component = AComponent then
      begin
        Result := APS.Components[I];
        Break;
      end;
    if Result = nil then
    begin
      Result := APS.Components.Add as TcxPropertiesStoreComponent;
      Result.Component := AComponent;
    end;
  end;

  procedure SaveComponentByProperty(APropertyNode: TTreeNode);
  var
    APropertyName: string;
    I: Integer;
    APSC: TcxPropertiesStoreComponent;
    APersistent: TPersistent;
  begin
    APropertyName := APropertyNode.Text;
    for I := 0 to APropertyNode.Count - 1 do
    begin
      if IsNodeChecked(APropertyNode[I]) then
      begin
        APersistent := PfrmPropertiesStoreRecord(APropertyNode[I].Data)^.Persistent;
        if APersistent is TComponent then
        begin
          APSC := GetPropertiesStoreComponent(APersistent as TComponent);
          if IsNodeFullChecked(APropertyNode[I]) then
            APSC.Properties.Add(APropertyName)
          else
            SaveComponentProperties(APSC, APropertyNode[I], APropertyName);
        end;
      end;
    end;
  end;

var
  ANode: TTreeNode;
begin
  if APropertiesStore = nil then
    APS := PropertiesStore
  else
    APS := APropertiesStore;
  if APS <> nil then
  begin
    APS.Components.Clear;
    ANode := Tree.Items.GetFirstNode;
    while ANode <> nil do
    begin
      if IsNodeChecked(ANode) then
      begin
        if ANode.Data <> nil then
        begin
          if Grouping = psgComponents then
            SaveComponent(ANode)
          else if Grouping = psgProperties then
            SaveComponentByProperty(ANode);
        end;
      end;
      ANode := ANode.getNextSibling;
    end;
  end;
end;

function TfrmPropertiesStoreEditor.IsNodeFullChecked(
  ANode: TTreeNode): Boolean;
var
  I: Integer;
begin
  Result := PfrmPropertiesStoreRecord(ANode.Data)^.Stored;
  if Result then
  begin
    for I := 0 to ANode.Count - 1 do
      Result := Result and IsNodeFullChecked(ANode[I]);
  end;
end;

function TfrmPropertiesStoreEditor.IsNodeChecked(
  ANode: TTreeNode): Boolean;
begin
  Result := PfrmPropertiesStoreRecord(ANode.Data)^.Stored;
end;

procedure TfrmPropertiesStoreEditor.BeginUpdate;
begin
  Tree.Items.BeginUpdate;
end;

procedure TfrmPropertiesStoreEditor.EndUpdate;
begin
  Tree.Items.EndUpdate;
end;

procedure TfrmPropertiesStoreEditor.InvertCheck;

  procedure InvertCheckNode(ANode: TTreeNode);
  var
    I: Integer;
  begin
    for I := 0 to ANode.Count - 1 do
    begin
      if IsNodeChecked(ANode[I]) then
      begin
        if IsNodeFullChecked(ANode[I]) then
          UncheckNode(ANode[I])
        else
          InvertCheckNode(ANode[I]);
      end
      else
        CheckNode(ANode[I]);
    end;
  end;

var
  ANode: TTreeNode;
begin
  ANode := Tree.Items.GetFirstNode;
  while ANode <> nil do
  begin
    if IsNodeChecked(ANode) then
    begin
      if IsNodeFullChecked(ANode) then
        UncheckNode(ANode)
      else
        InvertCheckNode(ANode);
    end
    else
      CheckNode(ANode);
    ANode := ANode.getNextSibling;
  end;
end;

procedure TfrmPropertiesStoreEditor.btnInvertCheckingClick(Sender: TObject);
begin
  InvertChecking;
end;

procedure TfrmPropertiesStoreEditor.SetFindText;
begin
  if Grouping = psgComponents then
    lblFindComponent.Caption := scxFindComponent
  else if Grouping = psgProperties then
    lblFindComponent.Caption := scxFindProperty;
  edFindComponent.Left := lblFindComponent.Left + lblFindComponent.Width + 9;
  edFindComponent.Width := Tree.Left + Tree.Width - edFindComponent.Left - 7;
end;

procedure TfrmPropertiesStoreEditor.edFindComponentKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  ANode: TTreeNode;
begin
  if TranslateKey(Key) = VK_RETURN then
  begin
    ANode := FindNode(edFindComponent.Text);
    if ANode <> nil then
    begin
      Tree.Selected := ANode;
      Tree.SetFocus;
    end;
  end;
end;

function TfrmPropertiesStoreEditor.FindNode(const AText: string): TTreeNode;
var
  I: Integer;
  ANode: TTreeNode;
  ANodeText: string;
  AFindText: string;
  ACount, ACount1: Integer;
begin
  AFindText := UpperCase(AText);
  ANode := Tree.Items.GetFirstNode;
  ACount1 := -1;
  Result := nil;
  while ANode <> nil do
  begin
    ACount := 0;
    ANodeText := UpperCase(ANode.Text);
    for I := 1 to Length(AFindText) do
    begin
      if I > Length(ANodeText) then
        Break;
      if AFindText[I] = ANodeText[I] then
        Inc(ACount)
      else
        Break;
    end;
    if ACount > ACount1 then
    begin
      ACount1 := ACount;
      Result := ANode;
    end;
    ANode := ANode.getNextSibling;
  end;
end;

procedure TfrmPropertiesStoreEditor.CheckAll;
var
  ANode: TTreeNode;
begin
  BeginUpdate;
  try
    ANode := Tree.Items.GetFirstNode;
    while ANode <> nil do
    begin
      CheckNode(ANode, True, False);
      ANode := ANode.getNextSibling;
    end;
  finally
    EndUpdate;
  end;
end;

procedure TfrmPropertiesStoreEditor.InvertChecking;
begin
  BeginUpdate;
  try
    InvertCheck;
  finally
    EndUpdate;
  end;
end;

procedure TfrmPropertiesStoreEditor.Reset;
begin
  BeginUpdate;
  try
    RefreshTree;
    LoadFromPropertiesStore(nil);
  finally
    EndUpdate;
  end;
end;

procedure TfrmPropertiesStoreEditor.UncheckAll;
var
  ANode: TTreeNode;
begin
  BeginUpdate;
  try
    ANode := Tree.Items.GetFirstNode;
    while ANode <> nil do
    begin
      if PfrmPropertiesStoreRecord(ANode.Data)^.Stored then
        UncheckNode(ANode, True, False);
      ANode := ANode.getNextSibling;
    end;
  finally
    EndUpdate;
  end;

end;

procedure TfrmPropertiesStoreEditor.TreeContextPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  if Tree.Selected <> nil then
  begin
    BeginUpdate;
    try
      ChangeCheckState(Tree.Selected);
    finally
      EndUpdate;
    end;
  end;
end;

end.
