
{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressBars name editor                                     }
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

unit dxBarNameEd;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, dxBar;

type
  TdxBarNameEd = class(TForm)
    EName: TEdit;
    BOK: TButton;
    BCancel: TButton;
    LName: TLabel;
    procedure ENameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  public
    Kind: Integer;
    BarManager: TdxBarManager;
    Bar: TdxBar;
  end;

function dxBarEditName(var AName: string; Kind1, Kind2: Integer;
  ABarManager: TdxBarManager; ABar: TdxBar): Boolean;

implementation

{$R *.DFM}

uses
  dxBarCustomCustomizationForm, dxBarStrs, cxClasses;

function dxBarEditName(var AName: string; Kind1, Kind2: Integer;
  ABarManager: TdxBarManager; ABar: TdxBar): Boolean;
var
  AForm: TdxBarNameEd;
begin
  AForm := TdxBarNameEd.Create(nil);
  AForm.ParentWindow := GetActiveWindow;
  PrepareCustomizationFormFont(AForm, ABarManager);
  with AForm do
  begin
    Kind := Kind1;
    BarManager := ABarManager;
    Bar := ABar;
    if Kind1 = 0 then
    begin
      case Kind2 of
        0: Caption := cxGetResourceString(@dxSBAR_TOOLBARADD);
        1: Caption := cxGetResourceString(@dxSBAR_TOOLBARRENAME);
      end;
      LName.Caption := cxGetResourceString(@dxSBAR_TOOLBARNAME);
    end
    else
    begin
      case Kind2 of
        0: Caption := cxGetResourceString(@dxSBAR_CATEGORYADD);
        1: Caption := cxGetResourceString(@dxSBAR_CATEGORYINSERT);
        2: Caption := cxGetResourceString(@dxSBAR_CATEGORYRENAME);
      end;
      LName.Caption := cxGetResourceString(@dxSBAR_CATEGORYNAME);
    end;
    EName.Text := AName;
    BOK.Caption := cxGetResourceString(@dxSBAR_OK);
    BOK.Enabled := EName.Text <> '';
    BCancel.Caption := cxGetResourceString(@dxSBAR_CANCEL);
    ActiveControl := EName;
    Result := ShowModal = mrOk;
    if Result then AName := EName.Text;
    Free;
  end;
end;

procedure TdxBarNameEd.ENameChange(Sender: TObject);
begin
  BOk.Enabled := EName.Text <> '';
end;

procedure TdxBarNameEd.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  ABar: TdxBar;
begin
  if (ModalResult = mrOk) and (Kind = 0) then
  begin
    ABar := BarManager.BarByCaption(EName.Text);
    CanClose := (ABar = nil) or (ABar = Bar);
    if not CanClose then
      dxBarMessageBox(Format(cxGetResourceString(@dxSBAR_TOOLBAREXISTS), [EName.Text]),
        MB_ICONSTOP or MB_OK);
  end;
end;
                     
end.
