
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars item editor                                     }
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

unit dxBarItemEd;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, dxBar;

type
  TdxBarItemAddEditor = class(TForm)
    LName: TLabel;
    LCaption: TLabel;
    LType: TLabel;
    LCategory: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    BOk: TButton;
    BCancel: TButton;
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure BOkClick(Sender: TObject);
  private
    ABarItem: TdxBarItem;
    BarManager: TdxBarManager;
  end;

function dxBarItemAddEditor(ABarManager: TdxBarManager; ACategoryIndex: Integer): TdxBarItem;

implementation

{$R *.DFM}

uses
  TypInfo, dxBarCustomCustomizationForm, dxBarStrs;

function dxBarItemAddEditor(ABarManager: TdxBarManager; ACategoryIndex: Integer): TdxBarItem;
var
  AForm: TdxBarItemAddEditor;
  I: Integer;
begin
  Result := nil;
  AForm := TdxBarItemAddEditor.Create(nil);
  with AForm do
  begin
    BarManager := ABarManager;
    Font := dxBarCustomizingForm.Font;

    for I := 0 to BarManager.Categories.Count - 1 do
      ComboBox2.Items.Add(BarManager.Categories[I]);
    if (0 <= ACategoryIndex) and (ACategoryIndex < BarManager.Categories.Count) then
      ComboBox2.ItemIndex := ACategoryIndex
    else
      ComboBox2.ItemIndex := 0;

    for I := 0 to RegdxItemList.VisibleItemCount - 1 do
      ComboBox1.Items.Add(RegdxItemList.VisibleItemClass[I].ClassName);
    ComboBox1.ItemIndex := 0;
    ComboBox1Click(nil);

    if ShowModal = mrOK then Result := ABarItem;
    Free;
  end;
end;

procedure TdxBarItemAddEditor.FormShow(Sender: TObject);
begin
  Edit1.SetFocus;
end;

procedure TdxBarItemAddEditor.ComboBox1Click(Sender: TObject);
begin
  Edit1.Text := BarManager.GetUniqueItemName(RegdxItemList.VisibleItemClass[ComboBox1.ItemIndex]);
end;

procedure TdxBarItemAddEditor.BOkClick(Sender: TObject);
begin
  ABarItem := RegdxItemList.VisibleItemClass[ComboBox1.ItemIndex].Create(BarManager.Owner);
  try
    ABarItem.Name := Edit1.Text;
    ABarItem.Category := ComboBox2.ItemIndex;
    ABarItem.Caption := Edit2.Text;
  except
    ABarItem.Free;
    ComboBox1Click(Sender);
    ModalResult := mrNone;
  end;
end;

end.
