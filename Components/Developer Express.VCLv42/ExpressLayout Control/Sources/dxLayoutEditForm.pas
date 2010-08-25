
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl edit form                           }
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

unit dxLayoutEditForm;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, dxLayoutControl, cxControls;

type
  TLayoutEditForm = class(TForm)
    LayoutControl: TdxLayoutControl;
    edMain: TEdit;
    LayoutControlItemEdit: TdxLayoutItem;
    dxLayoutControl1Group1: TdxLayoutGroup;
    btnOK: TButton;
    dxLayoutControl1Item2: TdxLayoutItem;
    btnCancel: TButton;
    dxLayoutControl1Item3: TdxLayoutItem;
  public
    constructor Create(AOwner: TComponent); override;
    class function Run(const ACaption, AEditCaption: string; var Value: string;
      AEditControl: TWinControl = nil): Boolean;
  end;

var
  LayoutEditForm: TLayoutEditForm;

resourcestring
  dxLayoutEditFormOK = 'OK';
  dxLayoutEditFormCancel = 'Cancel';

implementation

{$R *.DFM}

uses
  cxClasses;

type
  TControlAccess = class(TControl);

constructor TLayoutEditForm.Create(AOwner: TComponent);
begin
  inherited;
  btnOK.Caption := cxGetResourceString(@dxLayoutEditFormOK);
  btnCancel.Caption := cxGetResourceString(@dxLayoutEditFormCancel);
end;

class function TLayoutEditForm.Run(const ACaption, AEditCaption: string;
  var Value: string; AEditControl: TWinControl = nil): Boolean;
begin
  with Self.Create(nil) do
    try
      Caption := ACaption;
      LayoutControlItemEdit.Caption := AEditCaption;

      if AEditControl = nil then
        edMain.Text := Value
      else
      begin
        LayoutControlItemEdit.Control := AEditControl;
        edMain.Visible := False;
        ActiveControl := AEditControl;
        TControlAccess(AEditControl).Text := Value;
      end;

      Result := ShowModal = mrOk;
      
      if AEditControl = nil then
        Value := edMain.Text
      else
        Value := TControlAccess(AEditControl).Text;
    finally
      Free;
    end;
end;

end.
