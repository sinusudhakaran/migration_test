{*******************************************************************}
{                                                                   }
{       Developer Express Visual Component Library                  }
{       ExpressDocking                                              }
{                                                                   }
{       Copyright (c) 2002-2009 Developer Express Inc.              }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSDOCKING AND ALL ACCOMPANYING  }
{   VCL CONTROLS AS PART OF AN EXECUTABLE PROGRAM ONLY.             }
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

unit dxDockReg;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Forms, SysUtils, Graphics, Controls, ImgList,
{$IFDEF DELPHI6}
  DesignIntf, ComponentDesigner, DesignEditors, VCLEditors,
{$ELSE}
  DsgnIntf,
{$ENDIF}
  cxLibraryReg, cxPropEditors;

type
  TdxDockingComponentEditor = class(TcxComponentEditor)
  protected
    function GetProductName: string; override;
    function GetProductMajorVersion: string; override;
  end;

  TdxDockingImageIndexProperty = class(TImageIndexProperty)
  public
    function GetImages: TCustomImageList; override;
  end;

procedure Register;

implementation

uses
  dxDockControl, dxDockPanel, TypInfo, cxDesignWindows;

const
  dxProductName = 'ExpressDocking Library';
//  dxDockVersion = '5.24';
  dxDockMajorVersion = '5';

type

{$IFDEF DELPHI9}
  TdxSetElementProperty = class(TSetElementProperty)
  private
    FElement: Integer;
    FBit: TBit;
  protected
    constructor Create(Parent: TPropertyEditor; AElement: Integer); reintroduce;
    property Element: Integer read FElement;
    function GetIsDefault: Boolean; override;
  public
    function AllEqual: Boolean; override;
    function GetValue: string; override;
    procedure GetValues(Proc: TGetStrProc); override;
    procedure SetValue(const Value: string); override;
   end;

  TdxSetProperty = class(TSetProperty)
  public
    procedure GetProperties(Proc: TGetPropProc); override;
    function GetValue: string; override;
  end;
{$ENDIF}

{$IFDEF DELPHI10}
  TdxDockPanelGuidelines = class(TWinControlGuidelines)
  protected
    function GetCount: Integer; override;
  end;

  TdxFloatDockSiteGuidelines = class(TWinControlGuidelines)
  protected
    function GetCount: Integer; override;
  end;
{$ENDIF}

  { TdxDockDesignWindow }

  TdxDockDesignWindow = class(TcxGlobalDesignWindow)
  public
    procedure SelectionsChanged(const ASelection: TDesignerSelectionList); override;
  end;

var
  FdxDockDesignWindow: TdxDockDesignWindow;

{ TdxDockingComponentEditor }

function TdxDockingComponentEditor.GetProductName: string;
begin
  Result := dxProductName;
end;

function TdxDockingComponentEditor.GetProductMajorVersion: string;
begin
  Result := dxDockMajorVersion;
end;

{ TdxDockingImageIndexProperty  }

function TdxDockingImageIndexProperty.GetImages: TCustomImageList;
begin
  Result := TdxCustomDockSite(GetComponent(0)).Images;
end;

{ TdxDockDesignWindow }

procedure TdxDockDesignWindow.SelectionsChanged(const ASelection: TDesignerSelectionList);
var
  I: Integer;
begin
  for I := 0 to ASelection.Count - 1 do
  begin
    if (ASelection[I] is TdxCustomDockControl) and (TdxCustomDockControl(ASelection[I]).ParentDockControl = nil) then
      (ASelection[I] as TdxCustomDockControl).Repaint;
  end;
end;

{$IFDEF DELPHI9}
{ TdxSetElementProperty }

constructor TdxSetElementProperty.Create(Parent: TPropertyEditor; AElement: Integer);
//var
//  MinValue: integer;
begin
  inherited Create(Parent, AElement);
  FElement := AElement;
//  MinValue := GetTypeData(GetTypeData(GetPropType).CompType^).MinValue;
//  FBit := FElement - MinValue;
  FBit := FElement;
end;

function TdxSetElementProperty.AllEqual: Boolean;
var
  I: Integer;
  S: TIntegerSet;
  V: Boolean;
begin
  Result := False;
  if PropCount > 1 then
  begin
    Integer(S) := GetOrdValue;
    V := FElement in S;
    for I := 1 to PropCount - 1 do
    begin
      Integer(S) := GetOrdValueAt(I);
      if (FElement in S) <> V then Exit;
    end;
  end;
  Result := True;
end;

function TdxSetElementProperty.GetValue: string;
var
  S: TIntegerSet;
begin
  Integer(S) := GetOrdValue;
  Result := BooleanIdents[FBit in S];
end;

procedure TdxSetElementProperty.GetValues(Proc: TGetStrProc);
begin
  Proc(BooleanIdents[False]);
  Proc(BooleanIdents[True]);
end;

procedure TdxSetElementProperty.SetValue(const Value: string);
var
  S: TIntegerSet;
begin
  Integer(S) := GetOrdValue;
  if CompareText(Value, BooleanIdents[True]) = 0 then
    Include(S, FBit)
  else
    Exclude(S, FBit);
  SetOrdValue(Integer(S));
end;

function TdxSetElementProperty.GetIsDefault: Boolean;
var
  S: TIntegerSet;
  ShouldBeInSet: Boolean;
  HasStoredProc: Integer;
  ProcAsInt: Integer;
begin
  Result := False; // !!!
  if not Result then
  begin
    ProcAsInt := Integer(PPropInfo(GetPropInfo)^.StoredProc);
    HasStoredProc := ProcAsInt and $FFFFFF00;
    if HasStoredProc = 0 then
    begin
      Integer(S) := PPropInfo(GetPropInfo)^.Default;
      ShouldBeInSet := FBit in S;
      Integer(S) := GetOrdValue;
      if ShouldBeInSet then
        Result := FBit in S
      else
        Result := not (FBit in S);
    end;
  end;
end;

{ TdxSetProperty }

procedure TdxSetProperty.GetProperties(Proc: TGetPropProc);
var
  I: Integer;
  E: IProperty;
begin
  with GetTypeData(GetTypeData(GetPropType)^.CompType^)^ do
    for I := MinValue to MaxValue do
    begin
      { Fix addref problems by referencing it here }
      E := TdxSetElementProperty.Create(Self, I);
      Proc(E);
      E := nil;
    end;
end;

function TdxSetProperty.GetValue: string;
var
  S: TIntegerSet;
  TypeInfo: PTypeInfo;
  I{, MinValue}: Integer;
begin
  Integer(S) := GetOrdValue;
  TypeInfo := GetTypeData(GetPropType)^.CompType^;
//  MinValue := GetTypeData(TypeInfo).MinValue;
  Result := '[';
  for I := 0 to SizeOf(Integer) * 8 - 1 do
    if I in S then
    begin
      if Length(Result) <> 1 then Result := Result + ',';
      Result := Result + GetSetElementName(TypeInfo, I{ + MinValue});
    end;
  Result := Result + ']';
end;
{$ENDIF}

{$IFDEF DELPHI10}
{ TdxDockPanelGuidelines }

function TdxDockPanelGuidelines.GetCount: Integer;
begin
  if TdxDockPanel(Component).FloatDockSite <> nil then
    Result := 0
  else
    Result := inherited GetCount;
end;

{ TdxFloatDockSiteGuidelines }

function TdxFloatDockSiteGuidelines.GetCount: Integer;
begin
  Result := 0;
end;
{$ENDIF}

procedure Register;
begin
  RegisterComponents('ExpressBars', [TdxDockingManager, TdxDockPanel, TdxDockSite]);
{$IFDEF DELPHI5}
  RegisterPropertyEditor(TypeInfo(Integer), TdxCustomDockControl, 'ImageIndex',
    TdxDockingImageIndexProperty);
{$ENDIF}
  RegisterComponentEditor(TdxCustomDockControl, TdxDockingComponentEditor);
  RegisterComponentEditor(TdxDockingManager, TdxDockingComponentEditor);
{$IFDEF DELPHI9}
  // bug in Delphi 2005!
  // bug in QC=13930
  RegisterPropertyEditor(TypeInfo(TdxDockingTypes), nil, '', TdxSetProperty);
{$ENDIF}
{$IFDEF DELPHI10}
  RegisterComponentGuidelines(TdxDockPanel, TdxDockPanelGuidelines);
  RegisterComponentGuidelines(TdxFloatDockSite, TdxFloatDockSiteGuidelines);
{$ENDIF}
end;

type
  TdxCustomDockControlAccess = class(TdxCustomDockControl);

procedure RegisterDockControl(ASender: TObject);
begin
  if dxDockingController.DockControlCount = 1 then
    FdxDockDesignWindow := TdxDockDesignWindow.Create(nil);

  TdxCustomDockControlAccess(ASender).FDesignHelper := TcxDesignHelper.Create(TComponent(ASender));
end;

procedure UnregisterDockControl(ASender: TObject);
begin
  if (FdxDockDesignWindow <> nil) and (dxDockingController = nil) or (dxDockingController.DockControlCount = 1) then
  begin
    FdxDockDesignWindow.Release;
    FdxDockDesignWindow := nil;
  end;
 
  TdxCustomDockControlAccess(ASender).FDesignHelper := nil;
end;

initialization
  FOnRegisterDockControl := RegisterDockControl;
  FOnUnregisterDockControl := UnregisterDockControl;

end.
