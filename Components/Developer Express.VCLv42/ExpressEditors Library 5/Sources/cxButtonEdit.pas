
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

unit cxButtonEdit;

{$I cxVer.inc}

interface

uses
  Classes, cxContainer, cxEdit, cxMaskEdit;

type
  { TcxCustomButtonEditProperties }

  TcxCustomButtonEditProperties = class(TcxCustomMaskEditProperties)
  public
    constructor Create(AOwner: TPersistent); override;
    class function GetContainerClass: TcxContainerClass; override;
  end;

  { TcxButtonEditProperties }

  TcxButtonEditProperties = class(TcxCustomButtonEditProperties)
  published
    property Alignment;
    property AssignedValues;
    property AutoSelect;
    property BeepOnError;
    property Buttons;
    property CaseInsensitive;
    property CharCase;
    property ClearKey;
    property ClickKey;
    property EchoMode;
    // deprecated
    property HideCursor;
    property HideSelection;
    property IgnoreMaskBlank;
    property ImeMode;
    property ImeName;
    property IncrementalSearch;
    property LookupItems;
    property LookupItemsSorted;
    property MaskKind;
    property EditMask;
    property MaxLength;
    property OEMConvert;
    property PasswordChar;
    property ReadOnly;
    property UseLeftAlignmentOnEditing;
    property ValidateOnEnter;
    property ViewStyle;
    property OnButtonClick;
    property OnChange;
    property OnEditValueChanged;
    property OnNewLookupDisplayText;
    property OnValidate;
  end;

  { TcxCustomButtonEdit }

  TcxCustomButtonEdit = class(TcxCustomMaskEdit)
  private
    function GetProperties: TcxCustomButtonEditProperties;
    function GetActiveProperties: TcxCustomButtonEditProperties;
    procedure SetProperties(Value: TcxCustomButtonEditProperties);
  protected
    function InternalGetNotPublishedStyleValues: TcxEditStyleValues; override;
    function SupportsSpelling: Boolean; override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxCustomButtonEditProperties
      read GetActiveProperties;
    property Properties: TcxCustomButtonEditProperties read GetProperties
      write SetProperties;
  end;

  { TcxButtonEdit }

  TcxButtonEdit = class(TcxCustomButtonEdit)
  private
    FAreButtonsLoaded: Boolean;
    function GetActiveProperties: TcxButtonEditProperties;
    function GetProperties: TcxButtonEditProperties;
    procedure SetProperties(Value: TcxButtonEditProperties);
  protected
    procedure ReadState(Reader: TReader); override;
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxButtonEditProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property Constraints;
    property DragMode;
    property Enabled;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxButtonEditProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop;
    property Text;
  {$IFDEF DELPHI12}
    property TextHint;
  {$ENDIF}
    property Visible;
    property DragCursor;
    property DragKind;
    property ImeMode;
    property ImeName;
    property OnClick;
{$IFDEF DELPHI5}
    property OnContextPopup;
{$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnEndDock;
    property OnStartDock;
  end;

implementation

uses
  cxEditConsts;

{ TcxCustomButtonEditProperties }

constructor TcxCustomButtonEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  Buttons.Add;
  Buttons[0].Kind := bkEllipsis;
  Buttons[0].Default := True;
end;

class function TcxCustomButtonEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxButtonEdit;
end;

{ TcxCustomButtonEdit }

class function TcxCustomButtonEdit.GetPropertiesClass: TcxCustomEditPropertiesClass; 
begin
  Result := TcxCustomButtonEditProperties;
end;

function TcxCustomButtonEdit.InternalGetNotPublishedStyleValues: TcxEditStyleValues;
begin
  Result := inherited InternalGetNotPublishedStyleValues -
    [svButtonStyle, svButtonTransparency, svGradientButtons];
end;

function TcxCustomButtonEdit.SupportsSpelling: Boolean;
begin
  Result := IsTextInputMode;
end;

function TcxCustomButtonEdit.GetProperties: TcxCustomButtonEditProperties;
begin
  Result := TcxCustomButtonEditProperties(FProperties);
end;

function TcxCustomButtonEdit.GetActiveProperties: TcxCustomButtonEditProperties;
begin
  Result := TcxCustomButtonEditProperties(InternalGetActiveProperties);
end;

procedure TcxCustomButtonEdit.SetProperties(Value: TcxCustomButtonEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxButtonEdit }

class function TcxButtonEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxButtonEditProperties;
end;

procedure TcxButtonEdit.ReadState(Reader: TReader);
begin
  if not FAreButtonsLoaded then
  begin
    Properties.Buttons.Clear;
    ActiveProperties.Buttons.Clear;
    FAreButtonsLoaded := True;
  end;
  inherited ReadState(Reader);
end;

function TcxButtonEdit.GetActiveProperties: TcxButtonEditProperties;
begin
  Result := TcxButtonEditProperties(InternalGetActiveProperties);
end;

function TcxButtonEdit.GetProperties: TcxButtonEditProperties;
begin
  Result := TcxButtonEditProperties(FProperties);
end;

procedure TcxButtonEdit.SetProperties(Value: TcxButtonEditProperties);
begin
  FProperties.Assign(Value);
end;

initialization
  GetRegisteredEditProperties.Register(TcxButtonEditProperties, scxSEditRepositoryButtonItem);

end.
