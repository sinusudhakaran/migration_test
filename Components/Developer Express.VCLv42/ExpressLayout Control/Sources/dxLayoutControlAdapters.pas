
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl control adapters                    }
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

unit dxLayoutControlAdapters;

{$I cxVer.inc}

interface

uses
  dxLayoutControl;

type
  TdxLayoutComboAdapter = class(TdxCustomLayoutControlAdapter)
  protected
    function AllowCheckSize: Boolean; override;
  end;

  TdxLayoutPanelAdapter = class(TdxCustomLayoutControlAdapter)
  protected
    function ShowBorder: Boolean; override;
    function UseItemColor: Boolean; override;
  end;

implementation

uses
  StdCtrls, ExtCtrls;

type
{$IFNDEF DELPHI6}
  TCustomCombo = TCustomComboBox;
{$ENDIF}
  TCustomComboAccess = class(TCustomCombo);

{ TdxLayoutComboAdapter }

function TdxLayoutComboAdapter.AllowCheckSize: Boolean;
begin
  Result := {$IFDEF DELPHI6}not TCustomComboAccess(Control).FDroppingDown{$ELSE}True{$ENDIF};
end;

{ TdxLayoutPanelAdapter }

function TdxLayoutPanelAdapter.ShowBorder: Boolean;
begin
  Result := False;
end;

function TdxLayoutPanelAdapter.UseItemColor: Boolean;
begin
  Result := True;
end;

initialization
  TdxLayoutComboAdapter.Register(TCustomCombo);
  TdxLayoutPanelAdapter.Register(TCustomPanel);

finalization
  TdxLayoutPanelAdapter.Unregister(TCustomPanel);
  TdxLayoutComboAdapter.Unregister(TCustomCombo);

end.
