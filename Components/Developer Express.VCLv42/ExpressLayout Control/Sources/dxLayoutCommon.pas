
{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           ExpressLayoutControl common routines                     }
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

unit dxLayoutCommon;

{$I cxVer.inc}

interface

uses
  SysUtils, TypInfo, Windows, Classes, Graphics, Forms;

type
  TdxLayoutSide = (sdLeft, sdRight, sdTop, sdBottom);

  IdxLayoutComponent = interface
    ['{F31C9078-5732-44D8-9347-3EA7B93837E3}']
    procedure SelectionChanged; stdcall;
  end;

  TdxLayoutDesigner = class(TComponent)
  public
    procedure RegisterComponent(AComponent: TComponent); virtual; abstract;
    procedure UnregisterComponent(AComponent: TComponent); virtual; abstract;

    procedure ComponentNameChanged(AComponent: TComponent); virtual; abstract;
    function GetDesigner(AComponent: TComponent): TCustomForm; virtual; abstract;
    function GetUniqueName(AComponent: TComponent; const ABaseName: string): string; virtual; abstract;
    function IsComponentSelected(AComponent: TComponent;
      APersistent: TPersistent): Boolean; virtual; abstract;
    function IsToolSelected: Boolean; virtual; abstract;
    procedure ItemsChanged(AComponent: TComponent); virtual; abstract;
    procedure SelectComponent(AComponent: TComponent; APersistent: TPersistent;
      AInvertSelection: Boolean); virtual; abstract;
  end;

function GetHotTrackColor: TColor;
function GetPlainString(const S: string): string;
procedure SetComponentName(AComponent: TComponent; const ABaseName: string;
  AIsDesigning, AIsLoading: Boolean);

var
  dxLayoutDesigner: TdxLayoutDesigner;

resourcestring
  dxLayoutNewGroupCaption = 'New Group';
  dxLayoutNewGroupDialogCaption = 'New Group';
  dxLayoutNewGroupDialogEditCaption = 'Enter a new group caption:';

  dxLayoutNewItemCaption = 'New Item';
  dxLayoutNewItemDialogCaption = 'New Item';
  dxLayoutNewItemDialogEditCaption = 'Enter a new item caption:';

implementation

uses
  cxClasses, dxCore;

{ routines }

function GetHotTrackColor: TColor;
begin
  Result := GetSysColor(COLOR_HOTLIGHT);
end;

function GetPlainString(const S: string): string;
const
  SpecialChars = [#10, #13];
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
    if dxCharInSet(Result[I], SpecialChars) then
      Delete(Result, I, 1);
end;

procedure SetComponentName(AComponent: TComponent; const ABaseName: string;
  AIsDesigning, AIsLoading: Boolean);

  function GetName: string;
  begin
    if AIsDesigning and not AIsLoading then
      Result := dxLayoutDesigner.GetUniqueName(AComponent, ABaseName)
    else
      Result := GetValidName(AComponent, ABaseName, True);
  end;

begin
  AComponent.Name := GetName;
end;

end.
