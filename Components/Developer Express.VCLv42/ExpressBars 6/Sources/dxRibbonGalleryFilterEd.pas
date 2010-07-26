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

unit dxRibbonGalleryFilterEd;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, CheckLst, dxRibbonGallery;

type
  TfmGalleryFilterGroups = class(TForm)
    clbGroups: TCheckListBox;
    GroupBox1: TGroupBox;
    btnOk: TButton;
    btnCancel: TButton;
  public
    procedure Init(AFilterCategory: TdxRibbonGalleryFilterCategory);
    procedure Apply(AFilterCategory: TdxRibbonGalleryFilterCategory);
  end;

implementation

{$R *.dfm}

{ TfmGalleryFilterGroups }

procedure TfmGalleryFilterGroups.Apply(
  AFilterCategory: TdxRibbonGalleryFilterCategory);
var
  I: Integer;
begin
  AFilterCategory.Groups.Clear;
  for I := 0 to clbGroups.Items.Count - 1 do
    if clbGroups.Checked[I] then
      AFilterCategory.Groups.Add(TdxRibbonGalleryGroup(clbGroups.Items.Objects[I]));
end;

procedure TfmGalleryFilterGroups.Init(
  AFilterCategory: TdxRibbonGalleryFilterCategory);
var
  I: Integer;
  AGroup: TdxRibbonGalleryGroup;
begin
  Caption := Format('Editing %s.GalleryFilter.Categories[%d].Groups', [AFilterCategory.GalleryItem.Name,
    AFilterCategory.Index]);
  clbGroups.Clear;
  for I := 0 to AFilterCategory.GalleryItem.GalleryGroups.Count - 1 do
  begin
    AGroup := AFilterCategory.GalleryItem.GalleryGroups[I];
    clbGroups.Items.AddObject(Format('%d - "%s"', [I, AGroup.Header.Caption]), AGroup);
    clbGroups.Checked[I] := AFilterCategory.Groups.IndexOf(AGroup) >= 0;
  end;
end;

end.
