
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl dxEditors adapters                  }
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

unit dxLayoutdxEditAdapters;

interface

uses
  dxLayoutControl, dxLayoutLookAndFeels, dxCntner, dxExEdtr;

type
  TdxLayoutdxEditAdapter = class(TdxCustomLayoutControlAdapter)
  private
    function GetControl: TdxInplaceEdit;
    function GetControlStyle: TdxEditStyle;
  protected
    property Control: TdxInplaceEdit read GetControl;
    property ControlStyle: TdxEditStyle read GetControlStyle;
  public
    procedure LookAndFeelChanged; override;
  end;

  TdxLayoutdxDropDownEditAdapter = class(TdxLayoutdxEditAdapter)
  private
    function GetControl: TdxInplaceDropDownEdit;
  protected
    property Control: TdxInplaceDropDownEdit read GetControl;
  public
    procedure LookAndFeelChanged; override;
  end;

implementation

type
  TdxInplaceDropDownEditAccess = class(TdxInplaceDropDownEdit);

{ TdxLayoutdxEditAdapter }

function TdxLayoutdxEditAdapter.GetControl: TdxInplaceEdit;
begin
  Result := TdxInplaceEdit(inherited Control);
end;

function TdxLayoutdxEditAdapter.GetControlStyle: TdxEditStyle;
begin
  Result := Control.Style;
end;

procedure TdxLayoutdxEditAdapter.LookAndFeelChanged;
const
  BorderStyles: array[TdxLayoutBorderStyle] of TdxEditBorderStyle =
    (xbsNone, xbsSingle, xbsFlat, xbs3D);
  ButtonStyles: array[TdxLayoutBorderStyle] of TdxEditButtonViewStyle =
    (btsSimple, btsSimple, btsFlat, bts3D);
begin
  inherited;
  with LookAndFeel.ItemOptions, ControlStyle do
  begin
    if DefaultBorderStyle <> xbsNone then
    begin
      BorderColor := GetControlBorderColor;
      BorderStyle := BorderStyles[ControlBorderStyle];
    end;
    ButtonStyle := ButtonStyles[ControlBorderStyle];
  end;
end;

{ TdxLayoutdxDropDownEditAdapter }

function TdxLayoutdxDropDownEditAdapter.GetControl: TdxInplaceDropDownEdit;
begin
  Result := TdxInplaceDropDownEdit(inherited Control);
end;

procedure TdxLayoutdxDropDownEditAdapter.LookAndFeelChanged;
const
  PopupBorders: array[TdxLayoutBorderStyle] of TdxPopupBorder =
    (pbSingle, pbSingle, pbFlat, pbFrame3D);
begin
  inherited;
  with LookAndFeel.ItemOptions do
  begin
    if ControlBorderStyle in [lbsNone, lbsSingle] then
      ControlStyle.ButtonStyle := btsHotFlat;
    TdxInplaceDropDownEditAccess(Control).PopupBorder := PopupBorders[ControlBorderStyle];
  end;
end;

initialization
  TdxLayoutdxEditAdapter.Register(TdxInplaceEdit);
  TdxLayoutdxDropDownEditAdapter.Register(TdxInplaceDropDownEdit);

finalization
  TdxLayoutdxDropDownEditAdapter.Unregister(TdxInplaceDropDownEdit);
  TdxLayoutdxEditAdapter.Unregister(TdxInplaceEdit);

end.
