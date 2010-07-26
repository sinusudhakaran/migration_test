
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       Express side bar store component editor                     }
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
{   THIS SOURCE CODE and ALL RESULTING INTERMEDIATE FILES           }
{   (DCU, OBJ, DLL, ETC.) ARE CONFIDENTIAL and PROPRIETARY TRADE    }
{   SECRETS OF DEVELOPER EXPRESS INC. THE REGISTERED DEVELOPER IS   }
{   LICENSED TO DISTRIBUTE THE EXPRESSBARS and ALL ACCOMPANYING VCL }
{   CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.                 }
{                                                                   }
{   THE SOURCE CODE CONTAINED WITHIN THIS FILE and ALL RELATED      }
{   FILES OR ANY PORTION OF ITS CONTENTS SHALL AT NO TIME BE        }
{   COPIED, TRANSFERRED, SOLD, DISTRIBUTED, OR OTHERWISE MADE       }
{   AVAILABLE TO OTHER INDIVIDUALS WITHOUT EXPRESS WRITTEN CONSENT  }
{   and PERMISSION FROM DEVELOPER EXPRESS INC.                      }
{                                                                   }
{   CONSULT THE END USER LICENSE AGREEMENT FOR INFORMATION ON       }
{   ADDITIONAL RESTRICTIONS.                                        }
{                                                                   }
{*******************************************************************}

unit dxsbarcs;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, dximctrl, ExtCtrls, dxsbar;

type
  TfrmSideBarCustomize = class(TdxSideBarStoreCustomizeForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ListBox: TListBox;
    Panel4: TPanel;
    Button: TButton;
    ImageListBox: TdxImageListBox;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxClick(Sender: TObject);
    procedure ImageListBoxStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure ImageListBoxEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure ButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ImageListBoxDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure ImageListBoxDragDrop(Sender, Source: TObject; X, Y: Integer);
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

procedure  SideBarCustomize(AStore : TdxSideBarStore);

implementation

uses dxreginf, dxsbstrs;

Var
  AForm : TfrmSideBarCustomize;

procedure  SideBarCustomize(AStore : TdxSideBarStore);

  function IsCategoryVisible(Index : Integer) : Boolean;
  var
    i : Integer;
    List : TList;
  begin
    List := TList.Create;
    AStore.GetItemsByCategory(AStore.Categories[Index], List);
    Result := False;
    for i := 0 to List.Count - 1 do
      if TdxStoredSideItem(List[i]).AvailableInCustomizeForm then
      begin
        Result := True;
        Break;
      end;
    List.Free;
  end;

var
  i : Integer;
begin
  if AForm = nil then
  begin
    AForm := TfrmSideBarCustomize.Create(nil);
    with AForm do
    begin
      for i := 0 to AStore.Categories.Count - 1 do
        if IsCategoryVisible(i) then
          ListBox.Items.AddObject(AStore.Categories[i], TObject(i));
      ImageListBox.ImageList := AStore.LargeImages;
      if (ListBox.Items.Count > 0) then
        ListBox.ItemIndex := 0;
    end;
  end;
  AForm.Store := AStore;
  AForm.ListBoxClick(nil);
  AForm.BeginCustomizing;

  AForm.Show;
end;

{$R *.DFM}

constructor TfrmSideBarCustomize.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := dxSideBarGetResourceString(@DXSB_CUSTOMIZE);
  Button.Caption := dxSideBarGetResourceString(@DXSB_CUSTOMIZECLOSEBUTTON);
  Constraints.MinWidth := 350;
  Constraints.MinHeight := 250;
  Constraints.MaxWidth := Constraints.MinWidth;
  Constraints.MaxHeight := Constraints.MinHeight;
end;

procedure TfrmSideBarCustomize.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  StoreExpressFormsInformation(self);
  Action := caFree;
  EndCustomizing;
  AForm := nil;
end;

procedure TfrmSideBarCustomize.ListBoxClick(Sender: TObject);
Var
  List : TList;
  i : Integer;
  item : TdxStoredSideItem;
begin
  ImageListBox.Items.Clear;
  if (ListBox.ItemIndex > -1) and (ListBox.Items.Count > 0) then
  begin
    List := TList.Create;
    Store.GetItemsByCategory(Store.Categories[Integer(ListBox.Items.Objects[ListBox.ItemIndex])], List);
    for i := 0 to List.Count - 1 do
      if TdxStoredSideItem(List[i]).AvailableInCustomizeForm then
      begin
        Item := TdxStoredSideItem(List[i]);
        ImageListBox.AddItem(Item.Caption, Item.LargeImage)
    end;
    List.Free;
  end;
  if ImageListBox.Items.Count > 1 then
    ImageListBox.ItemIndex := 0;
end;

procedure TfrmSideBarCustomize.ImageListBoxStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if (ImageListBox.ItemIndex > -1) and (ImageListBox.Items.Count > 0) then
    dxSideBarDragObject := TdxSideBarDragObject.Create(ImageListBox, DragObject, nil,
      Store.GetItemByCategory(ListBox.Items[ListBox.ItemIndex], ImageListBox.ItemIndex));
end;

procedure TfrmSideBarCustomize.ImageListBoxEndDrag(Sender,
  Target: TObject; X, Y: Integer);
begin
  if (dxSideBarDragObject <> nil) then
    dxSideBarDragObject.EndDrag(Target, X, Y);
end;

procedure TfrmSideBarCustomize.ButtonClick(Sender: TObject);
begin
  AForm.Close;
end;

procedure TfrmSideBarCustomize.FormCreate(Sender: TObject);
begin
  RestoreExpressFormsInformation(self);
end;

procedure TfrmSideBarCustomize.ImageListBoxDragOver(Sender,
  Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  if (dxSideBarDragObject <> nil) and (Source is TdxSideBar) then begin
    dxSideBarDragObject.DeleteItem := True;
    Accept := True;
  end;
end;

procedure TfrmSideBarCustomize.ImageListBoxDragDrop(Sender,
  Source: TObject; X, Y: Integer);
begin
  if (dxSideBarDragObject <> nil) and (Source is TdxSideBar) then begin
    dxSideBarDragObject.Item.Free;
  end;
end;

end.
