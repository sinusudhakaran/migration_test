
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressStatusBar                                             }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSSTATUSBAR AND ALL              }
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

unit dxStatusIndicatorEditor;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils,
{$IFDEF DELPHI6}
  Variants,
{$ENDIF}
  Classes, Controls, Forms, StdCtrls, ExtCtrls, CheckLst,
  dxStatusBar;

type
  TdxStatusBarIndicatorEditor = class(TForm)
    BtnOK: TButton;
    BtnCancel: TButton;
    chlbIndicators: TCheckListBox;
    Bevel1: TBevel;
    BtnAdd: TButton;
    BtnDelete: TButton;
    BtnClear: TButton;
    cbItemTypes: TComboBox;
    GroupBox1: TGroupBox;
    imgExample: TImage;
    procedure FormShow(Sender: TObject);
    procedure BtnAddClick(Sender: TObject);
    procedure BtnDeleteClick(Sender: TObject);
    procedure BtnClearClick(Sender: TObject);
    procedure chlbIndicatorsClick(Sender: TObject);
    procedure chlbIndicatorsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure cbItemTypesChange(Sender: TObject);
  private
    procedure IndicatorChangeHandler(Sender: TObject);
    function IndicatorTypeToStr(const AIndicatorType: TdxStatusBarStateIndicatorType): string;
    function StrToIndicatorType(const AStr: string): TdxStatusBarStateIndicatorType;
    procedure SetControlsState;
    procedure SetItemType;
  public
    Indicators: TdxStatusBarStateIndicators;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure PrepareIndicators;
  end;

implementation

uses
  cxClasses;

{$R *.dfm}

constructor TdxStatusBarIndicatorEditor.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Indicators := TdxStatusBarStateIndicators.Create;
  Indicators.OnChange := IndicatorChangeHandler;
end;

destructor TdxStatusBarIndicatorEditor.Destroy;
begin
  if Assigned(Indicators) then FreeAndNil(Indicators);
  inherited;
end;

procedure TdxStatusBarIndicatorEditor.IndicatorChangeHandler(Sender: TObject);
begin
  {}
end;

function TdxStatusBarIndicatorEditor.IndicatorTypeToStr(
  const AIndicatorType: TdxStatusBarStateIndicatorType): string;
begin
  case AIndicatorType of
    sitYellow: Result := 'sitYellow';
    sitBlue: Result := 'sitBlue';
    sitGreen: Result := 'sitGreen';
    sitRed: Result := 'sitRed';
    sitTeal: Result := 'sitTeal';
    sitPurple: Result := 'sitPurple';
    else
      Result := 'sitOff';
  end;
end;

function TdxStatusBarIndicatorEditor.StrToIndicatorType(
  const AStr: string): TdxStatusBarStateIndicatorType;
begin
  if AStr = 'sitYellow' then
    Result := sitYellow
  else
    if AStr = 'sitBlue' then
      Result := sitBlue
    else
      if AStr = 'sitGreen' then
        Result := sitGreen
      else
        if AStr = 'sitRed' then
          Result := sitRed
        else
          if AStr = 'sitTeal' then
            Result := sitTeal
          else
            if AStr = 'sitPurple' then
              Result := sitPurple
            else
              Result := sitOff;
end;

procedure TdxStatusBarIndicatorEditor.FormShow(Sender: TObject);
var
  I: Integer;
begin
  chlbIndicators.Clear;
  for I := 0 to Indicators.Count - 1 do
  begin
    chlbIndicators.Items.Add(IndicatorTypeToStr(Indicators[I].IndicatorType));
    chlbIndicators.Checked[chlbIndicators.Items.Count-1] := Indicators[I].Visible;
  end;
  SetControlsState;
end;

procedure TdxStatusBarIndicatorEditor.BtnAddClick(Sender: TObject);
begin
  chlbIndicators.Items.Add('sitOff');
  chlbIndicators.Checked[chlbIndicators.Items.Count-1] := True;
  SetControlsState;
end;

procedure TdxStatusBarIndicatorEditor.SetControlsState;
begin
  BtnDelete.Enabled := (chlbIndicators.Items.Count > 0);
  BtnClear.Enabled := (chlbIndicators.Items.Count > 0);
  cbItemTypes.Enabled := (chlbIndicators.Items.Count > 0) and
    (chlbIndicators.ItemIndex <> -1);
  imgExample.Visible := (chlbIndicators.Items.Count > 0) and
    (chlbIndicators.ItemIndex <> -1);
  SetItemType;
end;

procedure TdxStatusBarIndicatorEditor.PrepareIndicators;
var
  I: Integer;
  FItem: TdxStatusBarStateIndicatorItem;
begin
  Indicators.Clear;
  for I := 0 to chlbIndicators.Items.Count - 1 do
  begin
    FItem := Indicators.Add;
    FItem.Visible := chlbIndicators.Checked[I];
    FItem.IndicatorType := StrToIndicatorType(chlbIndicators.Items[I]);
  end;
end;

procedure TdxStatusBarIndicatorEditor.BtnDeleteClick(Sender: TObject);
begin
  if (chlbIndicators.Items.Count > 0) and (chlbIndicators.ItemIndex <> -1) then
  begin
    chlbIndicators.Items.Delete(chlbIndicators.ItemIndex);
    SetControlsState;
  end;
end;

procedure TdxStatusBarIndicatorEditor.BtnClearClick(Sender: TObject);
begin
  chlbIndicators.Items.Clear;
  SetControlsState;
end;

procedure TdxStatusBarIndicatorEditor.SetItemType;
begin
  if (chlbIndicators.Items.Count > 0) and (chlbIndicators.ItemIndex <> -1) then
  begin
    cbItemTypes.ItemIndex := cbItemTypes.Items.IndexOf(chlbIndicators.Items[chlbIndicators.ItemIndex]);
    LoadIndicatorBitmap(imgExample.Picture.Bitmap, StrToIndicatorType(cbItemTypes.Text));
  end
  else
    cbItemTypes.Text := '';
end;

procedure TdxStatusBarIndicatorEditor.chlbIndicatorsClick(Sender: TObject);
begin
  SetControlsState;
end;

procedure TdxStatusBarIndicatorEditor.chlbIndicatorsKeyDown(
  Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  SetControlsState;
end;

procedure TdxStatusBarIndicatorEditor.cbItemTypesChange(Sender: TObject);
begin
  if (chlbIndicators.Items.Count > 0) and (chlbIndicators.ItemIndex <> -1) then
    chlbIndicators.Items[chlbIndicators.ItemIndex] :=
      cbItemTypes.Items[cbItemTypes.ItemIndex]
  else
    cbItemTypes.ItemIndex := -1;
  SetItemType;
end;

end.
