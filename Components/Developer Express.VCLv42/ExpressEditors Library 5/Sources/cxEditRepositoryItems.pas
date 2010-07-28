
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressEditors                                               }
{                                                                    }
{       Copyright (c) 1998-2009 Developer Express Inc.               }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSEDITORS AND ALL                }
{   ACCOMPANYING VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY. }
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

unit cxEditRepositoryItems;

{$I cxVer.inc}

interface

uses
  Windows, Messages, ComCtrls, Classes, SysUtils, Graphics, Controls, StdCtrls,
  Forms, cxClasses, cxEdit, cxTextEdit, cxButtonEdit, cxDropDownEdit, cxImage,
  cxMaskEdit, cxCalendar, cxCurrencyEdit, cxSpinEdit, cxMemo, cxImageComboBox,
  cxBlobEdit, cxCalc, cxCheckBox, cxTimeEdit, cxHyperLinkEdit, cxMRUEdit,
  cxRadioGroup;

type

  { TcxEditRepositoryTextItem }

  TcxEditRepositoryTextItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxTextEditProperties;
    procedure SetProperties(Value: TcxTextEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxTextEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryButtonItem }

  TcxEditRepositoryButtonItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxButtonEditProperties;
    procedure SetProperties(Value: TcxButtonEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxButtonEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryImageItem }

  TcxEditRepositoryImageItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxImageProperties;
    procedure SetProperties(Value: TcxImageProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxImageProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryComboBoxItem }

  TcxEditRepositoryComboBoxItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxComboBoxProperties;
    procedure SetProperties(Value: TcxComboBoxProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxComboBoxProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryMaskItem }

  TcxEditRepositoryMaskItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxMaskEditProperties;
    procedure SetProperties(Value: TcxMaskEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxMaskEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryPopupItem }

  TcxEditRepositoryPopupItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxPopupEditProperties;
    procedure SetProperties(Value: TcxPopupEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxPopupEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryCalcItem }

  TcxEditRepositoryCalcItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxCalcEditProperties;
    procedure SetProperties(Value: TcxCalcEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxCalcEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryDateItem }

  TcxEditRepositoryDateItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxDateEditProperties;
    procedure SetProperties(Value: TcxDateEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxDateEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryCurrencyItem }

  TcxEditRepositoryCurrencyItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxCurrencyEditProperties;
    procedure SetProperties(Value: TcxCurrencyEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxCurrencyEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositorySpinItem }

  TcxEditRepositorySpinItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxSpinEditProperties;
    procedure SetProperties(Value: TcxSpinEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxSpinEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryMemoItem }

  TcxEditRepositoryMemoItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxMemoProperties;
    procedure SetProperties(Value: TcxMemoProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxMemoProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryImageComboBoxItem }

  TcxEditRepositoryImageComboBoxItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxImageComboBoxProperties;
    procedure SetProperties(Value: TcxImageComboBoxProperties);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxImageComboBoxProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryBlobItem }

  TcxEditRepositoryBlobItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxBlobEditProperties;
    procedure SetProperties(Value: TcxBlobEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxBlobEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryCheckBoxItem }

  TcxEditRepositoryCheckBoxItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxCheckBoxProperties;
    procedure SetProperties(Value: TcxCheckBoxProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxCheckBoxProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryTimeItem }

  TcxEditRepositoryTimeItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxTimeEditProperties;
    procedure SetProperties(Value: TcxTimeEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxTimeEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryMRUItem }

  TcxEditRepositoryMRUItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxMRUEditProperties;
    procedure SetProperties(Value: TcxMRUEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxMRUEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryHyperLinkItem }

  TcxEditRepositoryHyperLinkItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxHyperLinkEditProperties;
    procedure SetProperties(Value: TcxHyperLinkEditProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxHyperLinkEditProperties read GetProperties write SetProperties;
  end;

  { TcxEditRepositoryRadioGroupItem }

  TcxEditRepositoryRadioGroupItem = class(TcxEditRepositoryItem)
  private
    function GetProperties: TcxRadioGroupProperties;
    procedure SetProperties(Value: TcxRadioGroupProperties);
  public
    class function GetEditPropertiesClass: TcxCustomEditPropertiesClass; override;
  published
    property Properties: TcxRadioGroupProperties read GetProperties write SetProperties;
  end;

implementation

{ TcxEditRepositoryTextItem }

class function TcxEditRepositoryTextItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxTextEditProperties;
end;

function TcxEditRepositoryTextItem.GetProperties: TcxTextEditProperties;
begin
  Result := inherited Properties as TcxTextEditProperties;
end;

procedure TcxEditRepositoryTextItem.SetProperties(Value: TcxTextEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryButtonItem }

class function TcxEditRepositoryButtonItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxButtonEditProperties;
end;

function TcxEditRepositoryButtonItem.GetProperties: TcxButtonEditProperties;
begin
  Result := inherited Properties as TcxButtonEditProperties;
end;

procedure TcxEditRepositoryButtonItem.SetProperties(Value: TcxButtonEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryImageItem }

class function TcxEditRepositoryImageItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxImageProperties;
end;

function TcxEditRepositoryImageItem.GetProperties: TcxImageProperties;
begin
  Result := inherited Properties as TcxImageProperties;
end;

procedure TcxEditRepositoryImageItem.SetProperties(Value: TcxImageProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryComboBoxItem }

class function TcxEditRepositoryComboBoxItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxComboBoxProperties;
end;

function TcxEditRepositoryComboBoxItem.GetProperties: TcxComboBoxProperties;
begin
  Result := inherited Properties as TcxComboBoxProperties;
end;

procedure TcxEditRepositoryComboBoxItem.SetProperties(Value: TcxComboBoxProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryMaskItem }

class function TcxEditRepositoryMaskItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMaskEditProperties;
end;

function TcxEditRepositoryMaskItem.GetProperties: TcxMaskEditProperties;
begin
  Result := inherited Properties as TcxMaskEditProperties;
end;

procedure TcxEditRepositoryMaskItem.SetProperties(Value: TcxMaskEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryPopupItem }

class function TcxEditRepositoryPopupItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxPopupEditProperties;
end;

function TcxEditRepositoryPopupItem.GetProperties: TcxPopupEditProperties;
begin
  Result := inherited Properties as TcxPopupEditProperties;
end;

procedure TcxEditRepositoryPopupItem.SetProperties(Value: TcxPopupEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryCalcItem }

class function TcxEditRepositoryCalcItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCalcEditProperties;
end;

function TcxEditRepositoryCalcItem.GetProperties: TcxCalcEditProperties;
begin
  Result := inherited Properties as TcxCalcEditProperties;
end;

procedure TcxEditRepositoryCalcItem.SetProperties(Value: TcxCalcEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryDateItem }

class function TcxEditRepositoryDateItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxDateEditProperties;
end;

function TcxEditRepositoryDateItem.GetProperties: TcxDateEditProperties;
begin
  Result := inherited Properties as TcxDateEditProperties;
end;

procedure TcxEditRepositoryDateItem.SetProperties(Value: TcxDateEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryCurrencyItem }

class function TcxEditRepositoryCurrencyItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCurrencyEditProperties;
end;

function TcxEditRepositoryCurrencyItem.GetProperties: TcxCurrencyEditProperties;
begin
  Result := inherited Properties as TcxCurrencyEditProperties;
end;

procedure TcxEditRepositoryCurrencyItem.SetProperties(Value: TcxCurrencyEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositorySpinItem }

class function TcxEditRepositorySpinItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxSpinEditProperties;
end;

function TcxEditRepositorySpinItem.GetProperties: TcxSpinEditProperties;
begin
  Result := inherited Properties as TcxSpinEditProperties;
end;

procedure TcxEditRepositorySpinItem.SetProperties(Value: TcxSpinEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryMemoItem }

class function TcxEditRepositoryMemoItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMemoProperties;
end;

function TcxEditRepositoryMemoItem.GetProperties: TcxMemoProperties;
begin
  Result := inherited Properties as TcxMemoProperties;
end;

procedure TcxEditRepositoryMemoItem.SetProperties(Value: TcxMemoProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryImageComboBoxItem }

class function TcxEditRepositoryImageComboBoxItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxImageComboBoxProperties;
end;

function TcxEditRepositoryImageComboBoxItem.GetProperties: TcxImageComboBoxProperties;
begin
  Result := inherited Properties as TcxImageComboBoxProperties;
end;

procedure TcxEditRepositoryImageComboBoxItem.SetProperties(Value: TcxImageComboBoxProperties);
begin
  inherited Properties := Value;
end;

procedure TcxEditRepositoryImageComboBoxItem.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and not (csDestroying in ComponentState) then
    with TcxImageComboBoxProperties(Properties) do
    begin
      if AComponent = Images then Images := nil;
      if AComponent = LargeImages then LargeImages := nil;
    end;
end;

{ TcxEditRepositoryBlobItem }

class function TcxEditRepositoryBlobItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxBlobEditProperties;
end;

function TcxEditRepositoryBlobItem.GetProperties: TcxBlobEditProperties;
begin
  Result := inherited Properties as TcxBlobEditProperties;
end;

procedure TcxEditRepositoryBlobItem.SetProperties(Value: TcxBlobEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryCheckBoxItem }

class function TcxEditRepositoryCheckBoxItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCheckBoxProperties;
end;

function TcxEditRepositoryCheckBoxItem.GetProperties: TcxCheckBoxProperties;
begin
  Result := inherited Properties as TcxCheckBoxProperties;
end;

procedure TcxEditRepositoryCheckBoxItem.SetProperties(Value: TcxCheckBoxProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryTimeItem }

class function TcxEditRepositoryTimeItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxTimeEditProperties;
end;

function TcxEditRepositoryTimeItem.GetProperties: TcxTimeEditProperties;
begin
  Result := inherited Properties as TcxTimeEditProperties;
end;

procedure TcxEditRepositoryTimeItem.SetProperties(Value: TcxTimeEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryMRUItem }

class function TcxEditRepositoryMRUItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxMRUEditProperties;
end;

function TcxEditRepositoryMRUItem.GetProperties: TcxMRUEditProperties;
begin
  Result := inherited Properties as TcxMRUEditProperties;
end;

procedure TcxEditRepositoryMRUItem.SetProperties(Value: TcxMRUEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryHyperLinkItem }

class function TcxEditRepositoryHyperLinkItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxHyperLinkEditProperties;
end;

function TcxEditRepositoryHyperLinkItem.GetProperties: TcxHyperLinkEditProperties;
begin
  Result := inherited Properties as TcxHyperLinkEditProperties;
end;

procedure TcxEditRepositoryHyperLinkItem.SetProperties(Value: TcxHyperLinkEditProperties);
begin
  inherited Properties := Value;
end;

{ TcxEditRepositoryRadioGroupItem }

class function TcxEditRepositoryRadioGroupItem.GetEditPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxRadioGroupProperties;
end;

function TcxEditRepositoryRadioGroupItem.GetProperties: TcxRadioGroupProperties;
begin
  Result := inherited Properties as TcxRadioGroupProperties;
end;

procedure TcxEditRepositoryRadioGroupItem.SetProperties(Value: TcxRadioGroupProperties);
begin
  inherited Properties := Value;
end;

initialization
  RegisterClasses([TcxEditRepositoryItem, TcxEditRepositoryTextItem,
    TcxEditRepositoryButtonItem, TcxEditRepositoryImageItem,
    TcxEditRepositoryComboBoxItem, TcxEditRepositoryMaskItem,
    TcxEditRepositoryPopupItem, TcxEditRepositoryCalcItem,
    TcxEditRepositoryDateItem, TcxEditRepositoryCurrencyItem,
    TcxEditRepositorySpinItem, TcxEditRepositoryMemoItem,
    TcxEditRepositoryImageComboBoxItem, TcxEditRepositoryBlobItem,
    TcxEditRepositoryCheckBoxItem, TcxEditRepositoryTimeItem,
    TcxEditRepositoryMRUItem, TcxEditRepositoryHyperLinkItem,
    TcxEditRepositoryRadioGroupItem]);
  {$IFDEF DELPHI6}
  StartClassGroup(TControl);
  GroupDescendentsWith(TcxEditRepositoryItem, TControl);
  GroupDescendentsWith(TcxEditRepository, TControl);
  {$ENDIF}

end.
