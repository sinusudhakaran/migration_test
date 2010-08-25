{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{       Copyright (c) 2006-2009 Developer Express Inc.               }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSSKINS AND ALL ACCOMPANYING     }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.              }
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

unit dxSkinsDesignHelperReg;

{$I cxVer.inc}

interface

uses
  Windows, SysUtils, Classes, Controls, cxControls, cxLookAndFeels, Dialogs,
  Types, cxLookAndFeelPainters, dxSkinsLookAndFeelPainter, DesignIntf, Menus,
  DesignEditors, dxSkinsStrs, dxSkinsForm, ToolIntF, ExptIntf, ToolsApi;

type
  { TdxSkinsBaseSelectionEditor }

  TdxSkinsBaseSelectionEditor = class(TSelectionEditor)
  public
    procedure RequiresProductsUnits(Proc: TGetStrProc); virtual;
    procedure RequiresSkinsUnits(Proc: TGetStrProc); virtual;
    procedure RequiresUnits(Proc: TGetStrProc); override;
  end;

procedure Register;

implementation

uses
  dxSkinsDesignHelper, dxSkinsReg;

{ TdxSkinsBaseSelectionEditor }

procedure TdxSkinsBaseSelectionEditor.RequiresProductsUnits(Proc: TGetStrProc);
begin
end;

procedure TdxSkinsBaseSelectionEditor.RequiresSkinsUnits(Proc: TGetStrProc);
var
  I: Integer;
begin
  for I := 0 to dxSkinsUnitStateList.Count - 1 do
  begin
    if dxSkinsUnitStateList.Item[I].Enabled then
      Proc(dxSkinsUnitStateList.Item[I].UnitName);
  end;
end;

procedure TdxSkinsBaseSelectionEditor.RequiresUnits(Proc: TGetStrProc);
begin
  inherited RequiresUnits(Proc);
  dxSkinsUnitStateList.UpdateActiveProjectSettings;
  if dxSkinsUnitStateList.Enabled then
  begin
    Proc('dxSkinsCore');
    RequiresProductsUnits(Proc);
    RequiresSkinsUnits(Proc);
  end;
end;

procedure Register;
begin
{$IFDEF DELPHI9}
  ForceDemandLoadState(dlDisable);
{$ENDIF}
  RegisterSelectionEditor(TcxControl, TdxSkinsBaseSelectionEditor);
  RegisterSelectionEditor(TcxLookAndFeelController, TdxSkinsBaseSelectionEditor);
end;

initialization
  dxSkinListFilterProc := dxSkinsListFilter;
  dxSkinModifyProjectOptionsProc := dxSkinsShowProjectOptionsDialog;

finalization
  dxSkinListFilterProc := nil;
  dxSkinModifyProjectOptionsProc := nil;

end.
