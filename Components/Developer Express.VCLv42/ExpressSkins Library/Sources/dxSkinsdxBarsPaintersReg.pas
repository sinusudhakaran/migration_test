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

unit dxSkinsdxBarsPaintersReg;

{$I cxVer.inc}

interface

uses
  Classes, DesignIntf, dxSkinsDesignHelperReg, dxRibbon, dxBar, dxDockControl, dxStatusBar, 
  dxSkinsdxBarPainter, dxSkinsdxRibbonPainter, dxSkinsdxStatusBarPainter, 
  dxSkinsdxDockControlPainter;

procedure Register;

implementation

type
  TdxSkinsdxBarsSelectionEditor = class(TdxSkinsBaseSelectionEditor)
  public
    procedure RequiresProductsUnits(Proc: TGetStrProc); override;
  end;

  TdxSkinsdxStatusBarSelectionEditor = class(TdxSkinsBaseSelectionEditor)
  public
    procedure RequiresProductsUnits(Proc: TGetStrProc); override;
  end;

  TdxSkinsdxRibbonSelectionEditor = class(TdxSkinsBaseSelectionEditor)
  public
    procedure RequiresProductsUnits(Proc: TGetStrProc); override;
  end;

  TdxSkinsdxDockingSelectionEditor = class(TdxSkinsBaseSelectionEditor)
  public
    procedure RequiresProductsUnits(Proc: TGetStrProc); override;
  end;

{ TdxSkinsdxBarsSelectionEditor }

procedure TdxSkinsdxBarsSelectionEditor.RequiresProductsUnits(Proc: TGetStrProc);
begin
  inherited RequiresProductsUnits(Proc);
  Proc('dxSkinsdxBarPainter');
end;

{ TdxSkinsdxStatusBarSelectionEditor }

procedure TdxSkinsdxStatusBarSelectionEditor.RequiresProductsUnits(Proc: TGetStrProc);
begin
  inherited RequiresProductsUnits(Proc);
  Proc('dxSkinsdxStatusBarPainter');
end;

{ TdxSkinsdxRibbonSelectionEditor }

procedure TdxSkinsdxRibbonSelectionEditor.RequiresProductsUnits(Proc: TGetStrProc);
begin
  inherited RequiresProductsUnits(Proc);
  Proc('dxSkinsdxRibbonPainter');
end;

{ TdxSkinsdxDockingSelectionEditor }

procedure TdxSkinsdxDockingSelectionEditor.RequiresProductsUnits(Proc: TGetStrProc);
begin
  inherited RequiresProductsUnits(Proc);
  Proc('dxSkinsdxDockControlPainter');
end;

procedure Register;
begin
{$IFDEF DELPHI9}
  ForceDemandLoadState(dlDisable);
{$ENDIF}
  RegisterSelectionEditor(TdxBarManager, TdxSkinsdxBarsSelectionEditor);
  RegisterSelectionEditor(TdxStatusBar, TdxSkinsdxStatusBarSelectionEditor);
  RegisterSelectionEditor(TdxRibbon, TdxSkinsdxRibbonSelectionEditor);
  RegisterSelectionEditor(TdxDockingManager, TdxSkinsdxDockingSelectionEditor);
end;

end.
