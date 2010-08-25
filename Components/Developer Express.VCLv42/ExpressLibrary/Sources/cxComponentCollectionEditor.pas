{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressCommonLibrary                                         }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCOMMONLIBRARY AND ALL          }
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

unit cxComponentCollectionEditor;

{$I cxVer.inc}

interface

uses
{$IFDEF DELPHI6}
  Types,
  DesignIntf, DesignWindows, ComponentDesigner, DesignConst, DesignEditors, ColnEdit,
{$ELSE}
  DsgnWnds, DsgnIntf, LibIntf, DesignConst, ColnEdit,
{$ENDIF}
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, Menus, ExtCtrls, ComCtrls, ImgList, ActnList, ToolWin,
  cxClasses, cxDesignWindows;

type

  { TfrmComponentCollectionEditor }

  TfrmComponentCollectionEditor = class(TcxDesignFormEditor)
    acAdd: TAction;
    acDelete: TAction;
    acMoveDown: TAction;
    acMoveUp: TAction;
    acSelectAll: TAction;
    acTextLabels: TAction;
    acToolbar: TAction;
    ImageList: TImageList;
    ListView1: TListView;
    miAdd: TMenuItem;
    miDelete: TMenuItem;
    miMoveDown: TMenuItem;
    miMoveUp: TMenuItem;
    miTextLabels: TMenuItem;
    miToolbar: TMenuItem;
    N1: TMenuItem;
    Panel: TPanel;
    PopupMenu1: TPopupMenu;
    PopupMenu2: TPopupMenu;
    Toolbar1: TToolbar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ActionList: TActionList;
    SelectAll1: TMenuItem;
    procedure acAddExecute(Sender: TObject);
    procedure acDeleteExecute(Sender: TObject);
    procedure acMoveDownExecute(Sender: TObject);
    procedure acMoveUpExecute(Sender: TObject);
    procedure acSelectAllExecute(Sender: TObject);
    procedure acTextLabelsExecute(Sender: TObject);
    procedure acToolbarExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormShow(Sender: TObject);
    procedure ListView1Change(Sender: TObject; Item: TListItem; Change: TItemChange);
    procedure ListView1DragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure ListView1DragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure ListView1KeyDown(Sender: TObject; var Key: word; Shift: TShiftState);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure SelectAllCommandUpdate(Sender: TObject);
    procedure SelectionUpdate(Sender: TObject);
    procedure acToolbarUpdate(Sender: TObject);
  private
    FAddedItemIDList: TList;
    FCollectionClassName: string;
    FSelectionError: Boolean;
    FColOptions: TColOptions;
    procedure AMDeferUpdate(var Msg); message AM_DeferUpdate;
    function GetCollection: TcxComponentCollection;
    function GetRegKey: string;
    procedure SetColOptions(Value: TColOptions);
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
  protected
    procedure Activated; override;
    function  CanAdd(Index: Integer): Boolean; virtual;
    procedure InitFormEditor; override;
    procedure SelectAll(DoUpdate: Boolean = True);
    procedure SelectNone(DoUpdate: Boolean = True);
    procedure UpdateCaption; override;
    procedure UpdateContent; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure DoItemsModified; override;
    function GetItemName(ItemIndex: Integer): string;
    procedure GetSelection;
    procedure SelectionsChanged(const ASelection: TDesignerSelectionList); override;
    procedure SetSelection;
    procedure UpdateListbox;

    property Collection: TcxComponentCollection read GetCollection;
    property CollectionPropertyName: string read ComponentPropertyName;
    property Options: TColOptions read FColOptions write SetColOptions
      default [coAdd, coDelete, coMove];
  end;

  { TcxComponentCollectionProperty }

  TcxComponentCollectionEditorClass = class of TfrmComponentCollectionEditor;

  TcxComponentCollectionProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function GetAttributes: TPropertyAttributes; override;
    function GetEditorClass: TcxComponentCollectionEditorClass; virtual;
    function GetColOptions: TColOptions; virtual;
  end;

implementation

{$R *.dfm}

uses
  Registry, TypInfo, dxCore;

type
  TPersistentAccess = class(TPersistent); // used for protected method access

{ TcxComponentCollectionProperty }

procedure TcxComponentCollectionProperty.Edit;
var
  Obj: TPersistent;
begin
  Obj := GetComponent(0);
  while (Obj <> nil) and not (Obj is TComponent) do
    Obj := TPersistentAccess(Obj).GetOwner;
  TfrmComponentCollectionEditor(ShowFormEditorClass(Designer, TComponent(Obj),
    TcxComponentCollection(GetOrdValue), GetName, GetEditorClass)).Options := GetColOptions;
end;

function TcxComponentCollectionProperty.GetAttributes: TPropertyAttributes;
begin
  Result := [paDialog, paReadOnly];
end;

function TcxComponentCollectionProperty.GetEditorClass: TcxComponentCollectionEditorClass;
begin
  Result := TfrmComponentCollectionEditor;
end;

function TcxComponentCollectionProperty.GetColOptions: TColOptions;
begin
  Result := [coAdd, coDelete, coMove];
end;

{ TfrmComponentCollectionEditor }

constructor TfrmComponentCollectionEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColOptions := [coAdd, coDelete, coMove];
end;

procedure TfrmComponentCollectionEditor.acAddExecute(Sender: TObject);
var
  Item: TListItem;
  PrevCount, PrevListCount: Integer;
begin
  BeginUpdate;
  SelectNone(False);
  Collection.BeginUpdate;
  try
    PrevCount := Collection.Count + 1;
    PrevListCount := ListView1.Items.Count;
    Collection.Add;
    { Take into account collections that free items }
    if (PrevCount <> Collection.Count) then
      UpdateListBox
    else
      if ListView1.Items.Count > PrevListCount then
        ListView1.Items[ListView1.Items.Count - 1].Selected := True
      else
        ListView1.Selected := ListView1.Items.Add;
  finally
    Collection.EndUpdate;
  end;
  CancelUpdate;
  SetSelection;
  if csAncestor in Component.ComponentState then
  begin
    if FAddedItemIDList = nil then
      FAddedItemIDList := TList.Create;
    FAddedItemIDList.Add(Pointer(Collection.Items[Collection.Count - 1].ID));
  end;
  Item := ListView1.Items[ListView1.Items.Count-1];
  Item.Focused := True;
  Item.MakeVisible(False);
end;

procedure TfrmComponentCollectionEditor.acDeleteExecute(Sender: TObject);
var
  I, J, K: Integer;
  Item: TcxComponentCollectionItem;
  Found: Boolean;
begin
  BeginUpdate;
  Collection.BeginUpdate;
  try
    Designer.SetSelections(nil);
    if ListView1.Selected <> nil then
      J := ListView1.Selected.Index
    else
      J := -1;
    if (ListView1.SelCount = Collection.Count) and ((csAncestor in Component.ComponentState) = False) then
      Collection.Clear
    else if ListView1.SelCount > 0 then
      for I := ListView1.Items.Count - 1 downto 0 do
        if ListView1.Items[I].Selected then
        begin
          Found := False;
          if (FAddedItemIDList <> nil) and (FAddedItemIDList.Count > 0) then
          for K := 0 to FAddedItemIDList.Count -1 do
          begin
            Item := Collection.FindItemByID(Integer(FAddedItemIDList[K]));
            if Item = Collection.Items[i] then
            begin
              FAddedItemIDList.Delete(K);
              Found := True;
              Break;
            end
            else Found := False;
          end;
          if (not Found) and (csAncestor in Component.ComponentState) then
            raise EdxException.Create(SCantDeleteAncestor)
          else
            Collection.Items[I].Free;
        end;
  finally
    Collection.EndUpdate;
    CancelUpdate;
  end;
  UpdateListbox;
  if J >= ListView1.Items.Count then
    J := ListView1.Items.Count - 1;
  if (J > -1) and (J < ListView1.Items.Count) then
    ListView1.Selected := ListView1.Items[J];
  SetSelection;
end;

procedure TfrmComponentCollectionEditor.acMoveDownExecute(Sender: TObject);
var
  I, InsPos: Integer;
begin
  if (ListView1.SelCount = 0) or
    (ListView1.SelCount = Collection.Count) then Exit;

  InsPos := ListView1.Items.Count - 1;
  while not ListView1.Items[InsPos].Selected do
    Dec(InsPos);
  if InsPos < (ListView1.Items.Count -1) then Inc(InsPos);

  Collection.BeginUpdate;
  try
     for I := ListView1.Items.Count - 1 downto 0 do
       if ListView1.Items[I].Selected then
       begin
         Collection.Items[I].Index := InsPos;
         Dec(InsPos);
       end;
  finally
    Collection.EndUpdate;
  end;
  Designer.Modified;
  UpdateContent;
end;

procedure TfrmComponentCollectionEditor.acMoveUpExecute(Sender: TObject);
var
  I, InsPos: Integer;
begin
  if (ListView1.SelCount = 0) or
    (ListView1.SelCount = Collection.Count) then Exit;

  InsPos := 0;
  while not ListView1.Items[InsPos].Selected do
    Inc(InsPos);
  if InsPos > 0 then Dec(InsPos);

  Collection.BeginUpdate;
  try
     for I := 0 to ListView1.Items.Count - 1 do
       if ListView1.Items[I].Selected then
       begin
         Collection.Items[I].Index := InsPos;
         Inc(InsPos);
       end;
  finally
    Collection.EndUpdate;
  end;
  Designer.Modified;
  UpdateContent;
end;

procedure TfrmComponentCollectionEditor.acSelectAllExecute(Sender: TObject);
begin
  SelectAll;
end;

procedure TfrmComponentCollectionEditor.acTextLabelsExecute(Sender: TObject);
begin
  with acTextLabels do
  begin
    Checked := not Checked;
    Toolbar1.ShowCaptions := Checked;
    if not Checked then
    begin
      Toolbar1.ButtonHeight := 24;
      Toolbar1.ButtonWidth := 24;
    end;
  end;
end;

procedure TfrmComponentCollectionEditor.acToolbarExecute(Sender: TObject);
begin
  with acToolbar do
  begin
    Checked := not Checked;
    Toolbar1.Visible := Checked;
  end;
end;

procedure TfrmComponentCollectionEditor.acToolbarUpdate(Sender: TObject);
begin
  (Sender as TAction).Checked := Toolbar1.Visible;  
end;

procedure TfrmComponentCollectionEditor.SetColOptions(Value: TColOptions);
begin
  FColOptions := Value;
  acAdd.Enabled := coAdd in Value;
end;

procedure TfrmComponentCollectionEditor.WMActivate(var Message: TWMActivate);
begin
  inherited;
  if (Message.Active <> WA_INACTIVE) and (Collection <> nil) then
    SetSelection;
end;

procedure TfrmComponentCollectionEditor.DoItemsModified;
begin
  if Collection <> nil then
  begin
    UpdateListbox;
    GetSelection;
  end;
end;

function TfrmComponentCollectionEditor.GetItemName(ItemIndex: Integer): string;
var
  AName: string;
begin
  AName := Collection.Items[ItemIndex].DisplayName;
  if AName = '' then
    AName := '<?>';
  Result := Format('%d - %s',[ItemIndex, AName])
end;

function TfrmComponentCollectionEditor.GetCollection: TcxComponentCollection;
begin
  Result := TcxComponentCollection(ComponentProperty);
end;

function TfrmComponentCollectionEditor.GetRegKey: string;
begin
  Result := GetBaseRegKey + '\ComponentCollection Editor';
end;

procedure TfrmComponentCollectionEditor.GetSelection;
var
  I: Integer;
  Item: TcxComponentCollectionItem;
  List: {$IFDEF DELPHI6}IDesignerSelections{$ELSE}TDesignerSelectionList{$ENDIF};
begin
  BeginUpdate;
  try
    ListView1.Selected := nil;
  finally
    CancelUpdate;
  end;
{$IFDEF DELPHI6}
  List := CreateSelectionList;
{$ELSE}
  List := TDesignerSelectionList.Create;
  try
{$ENDIF}
    Designer.GetSelections(List);
    if (List.Count = 0) or (List.Count > Collection.Count) then Exit;
    if not ((List[0] = Component) or (List[0] = Collection)
      or (TcxComponentCollectionItem(List[0]).Collection = Collection)) then Exit;
    if List.Count > ListView1.Items.Count then
      UpdateListbox;
    BeginUpdate;
    try
    {$IFDEF DELPHI6}
      ListView1.ClearSelection;
    {$ELSE}
      for I := 0 to ListView1.Items.Count - 1 do
        ListView1.Items[I].Selected := False;
    {$ENDIF}
      for I := 0 to List.Count - 1 do
      begin
        if List[I] is TcxComponentCollectionItem then
        begin
          Item := TcxComponentCollectionItem(List[I]);
          ListView1.Items[Item.Index].Selected := True
        end;
      end;
    finally
      CancelUpdate;
    end;
{$IFNDEF DELPHI6}
  finally
    List.Free;
  end;
{$ENDIF}
end;

procedure TfrmComponentCollectionEditor.SelectionsChanged(const ASelection: TDesignerSelectionList);
begin
  UpdateContent;
end;

procedure TfrmComponentCollectionEditor.SetSelection;
var
  I: Integer;
  List: {$IFDEF DELPHI6}IDesignerSelections{$ELSE}TDesignerSelectionList{$ENDIF};
begin
  if csAncestor in Component.ComponentState then
    UpdateListBox;
  if FSelectionError then Exit;
  try
    if ListView1.SelCount > 0 then
    begin
    {$IFDEF DELPHI6}
      List := CreateSelectionList;
    {$ELSE}
      List := TDesignerSelectionList.Create;
      try
    {$ENDIF}
        for I := 0 to ListView1.Items.Count - 1 do
          if ListView1.Items[I].Selected then
            List.Add(Collection.Items[I]);
        Designer.SetSelections(List);
    {$IFNDEF DELPHI6}
      finally
        List.Free;
      end;
    {$ENDIF}
    end
    else
      Designer.SelectComponent(Collection);
  except
    FSelectionError := True;
    Application.HandleException(ExceptObject);
    Close;
  end;
end;

procedure TfrmComponentCollectionEditor.UpdateListbox;

  procedure FetchItems(List: TStrings);
  var
    I: Integer;
  begin
    if Collection <> nil then
      for I := 0 to Collection.Count - 1 do
        if CanAdd(I) then
          List.AddObject(GetItemName(I), nil);
  end;

  function ItemsEqual(ListItems: TListItems; Items: TStrings): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    if ListItems.Count <> Items.Count then Exit;
    for I := 0 to ListItems.Count - 1 do
    begin
      if ListItems[I].Caption <> Items[I] then
        Exit;
    end;
    Result := True;
  end;

var
  I: Integer;
  TmpItems: TStringList;
begin
  if Collection = nil then Exit;
  BeginUpdate;
  try
    TmpItems := TStringList.Create;
    FetchItems(TmpItems);
    try
      if (TmpItems.Count = 0) or not ItemsEqual(ListView1.Items, TmpItems) then
      begin
        ListView1.Items.BeginUpdate;
        try
          ListView1.Items.Clear;
          for I := 0 to TmpItems.Count - 1 do
            with ListView1.Items.Add do
              Caption := TmpItems[I];
        finally
          ListView1.Items.EndUpdate;
        end;
      end;
    finally
      TmpItems.Free;
    end;
  finally
    CancelUpdate;
  end;
end;

procedure TfrmComponentCollectionEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Component <> nil then
    Designer.SelectComponent(Component);
  with TRegIniFile.Create(GetRegKey) do
  try
    EraseSection(FCollectionClassName);
    WriteInteger(FCollectionClassName, 'Left', Left);
    WriteInteger(FCollectionClassName, 'Top', Top);
    WriteInteger(FCollectionClassName, 'Width', Width);
    WriteInteger(FCollectionClassName, 'Height', Height);
    WriteBool(FCollectionClassName, 'TextLabels', acTextLabels.Checked);
    WriteBool(FCollectionClassName, 'Toolbar', ToolBar1.Visible);
  finally
    Free;
  end;
  BeginUpdate;
  inherited;
end;

procedure TfrmComponentCollectionEditor.FormDestroy(Sender: TObject);
begin
  if FAddedItemIDList <> nil then
    FreeAndNil(FAddedItemIDList);
  inherited;
end;

procedure TfrmComponentCollectionEditor.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_PROCESSKEY then
  {$IFDEF DELPHI6}
    ComponentDesigner.Environment.ModalEdit(#0,Self);
  {$ELSE}
    DelphiIDE.ModalEdit(#0, Self);
  {$ENDIF}
end;

procedure TfrmComponentCollectionEditor.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  {$IFDEF DELPHI6}
    ComponentDesigner.Environment.ModalEdit(#0,Self);
  {$ELSE}
    DelphiIDE.ModalEdit(#0, Self);
  {$ENDIF}
end;

procedure TfrmComponentCollectionEditor.FormShow(Sender: TObject);

  procedure UpdateSizes;
  begin
    with TRegIniFile.Create(GetRegKey) do
    try
      Top := ReadInteger(FCollectionClassName, 'Top', 100);
      Left := ReadInteger(FCollectionClassName, 'Left', 100);
      Width := ReadInteger(FCollectionClassName, 'Width', Width);
      Height := ReadInteger(FCollectionClassName, 'Height', Height);
      ToolBar1.Visible := ReadBool(FCollectionClassName, 'Toolbar', True);
      acTextLabels.Checked := ReadBool(FCollectionClassName, 'TextLabels', False);
    finally
      Free;
    end;
  end;

{$IFNDEF DELPHI6}
var
  ALeft: Integer;
  ATop: Integer;
{$ENDIF}
begin
  UpdateSizes;
{$IFNDEF DELPHI6}
  ALeft := Left;
  ATop := Top;
  if Left + Width > Monitor.Left + Monitor.Width then
    ALeft := Monitor.Left + Monitor.Width - Width;
  if Left < Monitor.Left then
    ALeft := Monitor.Left;
  if Top + Height > Monitor.Top + Monitor.Height then
    ATop := Monitor.Top + Monitor.Height - Height;
  if Top < Monitor.Top then
    ATop := Monitor.Top;
  SetBounds(ALeft, ATop, Width, Height);
{$ELSE}
  MakeFullyVisible;
{$ENDIF}
end;

procedure TfrmComponentCollectionEditor.ListView1Change(Sender: TObject;
  Item: TListItem; Change: TItemChange);
var
  Msg: TMsg;
begin
  if (Change = ctState) and (LockCount = 0) then
    if not PeekMessage(Msg, Handle, AM_DeferUpdate, AM_DeferUpdate, PM_NOREMOVE) then
      PostMessage(Handle, AM_DeferUpdate, 0, 0);
end;

procedure TfrmComponentCollectionEditor.ListView1DragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  Item: TListItem;
  I, J, InsPos: Integer;
  L: TList;
begin
  Item := ListView1.GetItemAt(X, Y);
  if Item <> nil then
    InsPos := Item.Index
  else Exit;
  L := TList.Create;
  try
    for I := 0 to ListView1.Items.Count - 1 do
      if ListView1.Items[I].Selected then
        L.Add(Collection.Items[I]);

    Collection.BeginUpdate;
    try
      for I := 0 to L.Count - 1 do
      with TcxComponentCollectionItem(L[I]) do
      begin
        J := Index;
        Index := InsPos;
        if (J > InsPos) and (InsPos < Collection.Count) then
          Inc(InsPos);
      end;
    finally
      Collection.EndUpdate;
    end;
  finally
    L.Free;
  end;
  GetSelection;
end;

procedure TfrmComponentCollectionEditor.ListView1DragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  Item: TListItem;
begin
  Item := ListView1.GetItemAt(X, Y);
  Accept := (Item <> nil) and (Source = ListView1) and
    (not Item.Selected);
end;

procedure TfrmComponentCollectionEditor.ListView1KeyDown(Sender: TObject; var Key: word;
  Shift: TShiftState);
begin
  if Key = VK_PROCESSKEY then
  {$IFDEF DELPHI6}
    ComponentDesigner.Environment.ModalEdit(#0,Self);
  {$ELSE}
    DelphiIDE.ModalEdit(#0, Self);
  {$ENDIF}
end;

procedure TfrmComponentCollectionEditor.ListView1KeyPress(Sender: TObject;
  var Key: Char);
begin
  if dxCharInSet(Key, ['!'..'~']) then
  begin
  {$IFDEF DELPHI6}
    ComponentDesigner.Environment.ModalEdit(Key,Self);
  {$ELSE}
    DelphiIDE.ModalEdit(Key, Self);
  {$ENDIF}
    Key := #0;
  end;
end;

procedure TfrmComponentCollectionEditor.SelectAllCommandUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := (ListView1.Items.Count > 0) and
    (ListView1.SelCount <> ListView1.Items.Count);
end;

procedure TfrmComponentCollectionEditor.AMDeferUpdate(var Msg);
begin
  if LockCount = 0 then
  begin
    if TMessage(Msg).WParam = 0 then
      SetSelection
    else
      ItemsModified(nil);
  end
  else
    PostMessage(Handle, AM_DeferUpdate, TMessage(Msg).WParam, TMessage(Msg).LParam);
end;

procedure TfrmComponentCollectionEditor.SelectionUpdate(Sender: TObject);
var
  Enabled: Boolean;
begin
  Enabled := ListView1.Selected <> nil;
  if Enabled then
    if Sender = acDelete then
      Enabled := coDelete in Options
    else
      if (Sender = acMoveUp) or (Sender = acMoveDown) then
        Enabled := coMove in Options;
  (Sender as TAction).Enabled := Enabled;
end;

procedure TfrmComponentCollectionEditor.SelectAll(DoUpdate: Boolean);
var
  I: Integer;
begin
  BeginUpdate;
  ListView1.Items.BeginUpdate;
  try
    for I := 0 to Listview1.Items.Count-1 do
      Listview1.Items[I].Selected := True;
  finally
    ListView1.Items.EndUpdate;
    CancelUpdate;
    if DoUpdate then SetSelection;
  end;
end;

procedure TfrmComponentCollectionEditor.SelectNone(DoUpdate: Boolean);
var
  I: Integer;
begin
  BeginUpdate;
  ListView1.Items.BeginUpdate;
  try
    for I := 0 to Listview1.Items.Count-1 do
      Listview1.Items[I].Selected := False;
  finally
    ListView1.Items.EndUpdate;
    CancelUpdate;
    if DoUpdate then SetSelection;
  end;
end;

procedure TfrmComponentCollectionEditor.UpdateCaption;
begin
  Caption := Format('Editing %s%s%s', [Component.Name, DotSep, ComponentPropertyName]);
end;

procedure TfrmComponentCollectionEditor.UpdateContent;
begin
  UpdateListbox;
  GetSelection;
end;

procedure TfrmComponentCollectionEditor.Activated;
begin
  inherited;
  SetSelection;
end;

function TfrmComponentCollectionEditor.CanAdd(Index: Integer): Boolean;
begin
  Result := True;
end;

procedure TfrmComponentCollectionEditor.InitFormEditor;
begin
  FCollectionClassName := Collection.ClassName;
  UpdateListbox;
  inherited InitFormEditor;
  Options := FColOptions; //refresh
end;

end.
