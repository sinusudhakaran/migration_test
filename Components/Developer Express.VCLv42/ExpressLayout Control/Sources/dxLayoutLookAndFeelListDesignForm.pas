
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl Look & Feel design-time form        }
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

unit dxLayoutLookAndFeelListDesignForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,
  cxControls, dxLayoutControl, dxLayoutLookAndFeels, dxLayoutDesignCommon,
  {$IFDEF DELPHI6}Variants, DesignIntf{$ELSE}DsgnIntf{$ENDIF};

type
  TLookAndFeelListDesignForm = class(TdxLayoutDesignForm)
    lcMain: TdxLayoutControl;
    lbItems: TListBox;
    lcMainItem1: TdxLayoutItem;
    btnAdd: TButton;
    lcMainItem2: TdxLayoutItem;
    btnDelete: TButton;
    lcMainItem3: TdxLayoutItem;
    btnClose: TButton;
    lcMainItem4: TdxLayoutItem;
    lcMainGroup2: TdxLayoutGroup;
    lcMainGroup3: TdxLayoutGroup;
    lflMain: TdxLayoutLookAndFeelList;
    dxLayoutOfficeLookAndFeel1: TdxLayoutOfficeLookAndFeel;
    pnlPreview: TPanel;
    lcMainItem6: TdxLayoutItem;
    lcPreview: TdxLayoutControl;
    Edit1: TEdit;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    ListBox1: TListBox;
    dxLayoutControl1Group4: TdxLayoutGroup;
    dxLayoutGroup1: TdxLayoutGroup;
    dxLayoutItem1: TdxLayoutItem;
    dxLayoutControl1Item2: TdxLayoutItem;
    dxLayoutControl1Group2: TdxLayoutGroup;
    dxLayoutControl1Item3: TdxLayoutItem;
    dxLayoutControl1Item4: TdxLayoutItem;
    dxLayoutControl1Group3: TdxLayoutGroup;
    dxLayoutControl1Item5: TdxLayoutItem;
    lcMainGroup4: TdxLayoutGroup;
    procedure btnCloseClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
  private
    function GetList: TdxLayoutLookAndFeelList;
  protected
    function GetAddItemsButton(AIndex: Integer): TButton; override;
    function GetAddItemsButtonCount: Integer; override;
    function GetDeleteItemsButton: TButton; override;
    function GetItemsListBox: TListBox; override;
    function NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean; override;

    procedure RefreshItemsListBox; override;
  public
    constructor Create(AOwner: TComponent); override;
  {$IFDEF DELPHI6}
    procedure SelectionChanged(const ADesigner: IDesigner; const ASelection: IDesignerSelections); override;
  {$ELSE}
    procedure SelectionChanged(ASelection: TDesignerSelectionList); override;
  {$ENDIF}
    property List: TdxLayoutLookAndFeelList read GetList;
  end;

implementation

{$R *.dfm}

uses
  dxLayoutEditForm;

constructor TLookAndFeelListDesignForm.Create(AOwner: TComponent);
begin
  inherited;
{$IFDEF DELPHI9}
  PopupMode := pmExplicit;
{$ENDIF}
end;

function TLookAndFeelListDesignForm.GetList: TdxLayoutLookAndFeelList;
begin
  Result := TdxLayoutLookAndFeelList(Component);
end;

function TLookAndFeelListDesignForm.GetAddItemsButton(AIndex: Integer): TButton;
begin
  Result := btnAdd;
end;

function TLookAndFeelListDesignForm.GetAddItemsButtonCount: Integer;
begin
  Result := 1;
end;

function TLookAndFeelListDesignForm.GetDeleteItemsButton: TButton;
begin
  Result := btnDelete;
end;

function TLookAndFeelListDesignForm.GetItemsListBox: TListBox;
begin
  Result := lbItems;
end;

function TLookAndFeelListDesignForm.NeedRefreshItemsAfterDeleting(AComponent: TPersistent): Boolean;
begin
  Result := inherited NeedRefreshItemsAfterDeleting(AComponent) and
    (AComponent is TdxCustomLayoutLookAndFeel) and
    (TdxCustomLayoutLookAndFeel(AComponent).List = List);
end;

procedure TLookAndFeelListDesignForm.RefreshItemsListBox;
var
  I: Integer;
  AItem: TdxCustomLayoutLookAndFeel;
begin
  with lbItems.Items do
  begin
    BeginUpdate;
    try
      Clear;
      for I := 0 to List.Count - 1 do
      begin
        AItem := List[I];
        AddObject(AItem.Name, AItem);
      end;
    finally
      EndUpdate;
    end;
  end;
end;

{$IFDEF DELPHI6}
procedure TLookAndFeelListDesignForm.SelectionChanged(const ADesigner: IDesigner;
  const ASelection: IDesignerSelections);
{$ELSE}
procedure TLookAndFeelListDesignForm.SelectionChanged(ASelection: TDesignerSelectionList);
{$ENDIF}
var
  ASelections: TDesignerSelectionListAccess;
begin
  inherited;
  ASelections := GetSelectedItems;
  try
    lcPreview.Visible := ASelections.Count = 1;
    if lcPreview.Visible then
      lcPreview.LookAndFeel := TdxCustomLayoutLookAndFeel(ASelections[0]);
  finally
    ASelections.Free;
  end;
end;

procedure TLookAndFeelListDesignForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TLookAndFeelListDesignForm.btnAddClick(Sender: TObject);
var
  ADescription: string;
  ALookAndFeel: TdxCustomLayoutLookAndFeel;
  ALookAndFeelClass: TdxCustomLayoutLookAndFeelClass;

  function GetDescriptionsComboBox: TComboBox;
  var
    I: Integer;
  begin
    Result := TComboBox.Create(nil);
    with Result do
    begin
      Style := csDropDownList;
      Visible := False;
      Parent := Self;
      for I := 0 to dxLayoutLookAndFeelDefs.Count - 1 do
        Items.Add(dxLayoutLookAndFeelDefs[I].Description);
      if Items.Count <> 0 then ItemIndex := 0;
    end;
  end;

begin
  ADescription := '';
  if TLayoutEditForm.Run('New Look & Feel',
    'Choose a new look && feel style:', ADescription, GetDescriptionsComboBox) then
  begin
    ALookAndFeelClass := dxLayoutLookAndFeelDefs.GetItemByDescription(ADescription);
    ALookAndFeel := List.CreateItem(ALookAndFeelClass);
    Designer.SelectComponent(ALookAndFeel);
  end;
end;

end.
