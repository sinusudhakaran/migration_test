
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressXPThemeManager                                        }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSXPTHEMEMANAGER AND ALL         }
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

unit dxThemeManager;

{$I cxVer.inc}

interface

uses
  Windows, Messages, SysUtils, Controls, Forms, dxUxTheme;

type
  TdxThemedObjectType = (
    totButton,
    totClock,
    totComboBox,
    totEdit,
    totExplorerBar,
    totHeader,
    totListBox,
    totListView,
    totMenu,
    totPage,
    totProgress,
    totRebar,
    totScrollBar,
    totSpin,
    totStartPanel,
    totStatus,
    totTab,
    totTaskBand,
    totTaskBar,
    totToolBar,
    totToolTip,
    totTrackBar,
    totTrayNotify,
    totTreeview,
    totWindow
  );

  TdxThemedObjectTypes = set of TdxThemedObjectType;

  { TdxThemeChangedNotificator }

  TdxThemeChangedEvent = procedure of object;

  TdxThemeChangedNotificator = class
  private
    FOnThemeChanged: TdxThemeChangedEvent;
  public
    constructor Create;
    destructor Destroy; override;
    property OnThemeChanged: TdxThemeChangedEvent read FOnThemeChanged write FOnThemeChanged;
  end;

function AreVisualStylesAvailable(ANeededThemedObjectType: TdxThemedObjectType): Boolean; overload;
function AreVisualStylesAvailable(ANeededThemedObjectTypes: TdxThemedObjectTypes = []): Boolean; overload;
procedure CloseAllThemes;
function CloseTheme(AThemedObjectType: TdxThemedObjectType): HRESULT;
function IsStandardTheme: Boolean;
function OpenTheme(AThemedObjectType: TdxThemedObjectType;
  APClassNameList: PWideChar = nil): TdxTheme;

implementation

uses
  Classes, dxThemeConsts;

type
  TdxThemeData = record
    Theme: TdxTheme;
    ClassNameList: WideString;
  end;

  { TdxThemeChangedEventReceiver }

  TdxThemeChangedEventReceiver = class
  private
    FWindowHandle: HWND;
    procedure WndProc(var Msg: TMessage);
    procedure WMThemeChanged(var Message: TMessage); message WM_THEMECHANGED;
  public
    constructor Create;
    destructor Destroy; override;
  end;

const
  dxThemedObjectNameA: array[TdxThemedObjectType] of WideString = (
    'Button',
    'Clock',
    'ComboBox',
    'Edit',
    'ExplorerBar',
    'Header',
    'ListBox',
    'ListView',
    'Menu',
    'Page',
    'Progress',
    'Rebar',
    'ScrollBar',
    'Spin',
    'StartPanel',
    'Status',
    'Tab',
    'TaskBand',
    'TaskBar',
    'ToolBar',
    'ToolTip',
    'TrackBar',
    'TrayNotify',
    'TreeView',
    'Window'
  );

var
  FIsGlobalThemeActive: Boolean = False;
  FThemeDataA: array[TdxThemedObjectType] of TdxThemeData;
  FThemeChangedEventReceiver: TdxThemeChangedEventReceiver = nil;
  FThemeChangedNotificatorList: TList;

function AreVisualStylesAvailable(ANeededThemedObjectType: TdxThemedObjectType): Boolean;
begin
  Result := FIsGlobalThemeActive and IsThemeLibraryLoaded and
    (OpenTheme(ANeededThemedObjectType) <> TC_NONE);
end;

function AreVisualStylesAvailable(ANeededThemedObjectTypes: TdxThemedObjectTypes = []): Boolean;
var
  AThemedObjectType: TdxThemedObjectType;
begin
  Result := FIsGlobalThemeActive and IsThemeLibraryLoaded;
  if Result and (ANeededThemedObjectTypes <> []) then
    for AThemedObjectType := Low(TdxThemedObjectType) to High(TdxThemedObjectType) do
      if (AThemedObjectType in ANeededThemedObjectTypes) and (OpenTheme(AThemedObjectType) = TC_NONE) then
      begin
        Result := False;
        Break;
      end;
end;

function CloseTheme(AThemedObjectType: TdxThemedObjectType): HRESULT;
var
  ATheme: TdxTheme;
begin
  Result := S_FALSE;
  if not AreVisualStylesAvailable then Exit;
  Result := S_OK;
  ATheme := FThemeDataA[AThemedObjectType].Theme;
  if ATheme <> 0 then
  begin
    Result := CloseThemeData(ATheme);
    FThemeDataA[AThemedObjectType].Theme := 0; // TODO ???
    FThemeDataA[AThemedObjectType].ClassNameList := ''; // TODO ???
  end;
end;

procedure CloseAllThemes;
var
  ATheme: TdxTheme;
  AThemedObjectType: TdxThemedObjectType;
begin
  for AThemedObjectType := Low(TdxThemedObjectType) to High(TdxThemedObjectType) do
  begin
    ATheme := FThemeDataA[AThemedObjectType].Theme;
    if ATheme <> 0 then
    begin
      CloseThemeData(ATheme);
      FThemeDataA[AThemedObjectType].Theme := 0;
    end;
  end;
end;

function IsStandardTheme: Boolean;
const
  SZ_MAX_CHARS = 1024;
  StandardThemeFileNames: array[0..1] of string = ('LUNA.MSSTYLES', 'ROYALE.MSSTYLES');
var
  AThemeFileName: PWideChar;
  I: Integer;
  S: string;
begin
  Result := False;
  if AreVisualStylesAvailable then
  begin
    AThemeFileName := AllocMem(2 * SZ_MAX_CHARS);
    try
      if GetCurrentThemeName(AThemeFileName, SZ_MAX_CHARS, nil, 0, nil, 0) = S_OK then
      begin
        S := UpperCase(ExtractFileName(AThemeFileName));
        for I := 0 to High(StandardThemeFileNames) do
        begin
          Result := S = StandardThemeFileNames[I];
          if Result then
            Break;
        end;
      end;
    finally
      FreeMem(AThemeFileName);
    end;
  end;
end;

function OpenTheme(AThemedObjectType: TdxThemedObjectType;
  APClassNameList: PWideChar = nil): TdxTheme;

  function InternalCompareString(const S1, S2: TCaption): Boolean;
  begin
    Result := AnsiUpperCase(S1) = AnsiUpperCase(S2);
  end;

begin
  Result := 0;
  if not AreVisualStylesAvailable then Exit;
  with FThemeDataA[AThemedObjectType] do
  begin
    if Theme <> 0 then
      if (APClassNameList = nil) or
          InternalCompareString(ClassNameList, APClassNameList) then
      begin
        Result := Theme;
        Exit;
      end
      else
        CloseTheme(AThemedObjectType);

      if APClassNameList = nil then
        if Length(ClassNameList) = 0 then
          APClassNameList := PWideChar(dxThemedObjectNameA[AThemedObjectType])
        else
          APClassNameList := PWideChar(ClassNameList);
      Result := OpenThemeData(0, APClassNameList);
      if Result <> 0 then
      begin
        Theme := Result;
        ClassNameList := WideString(APClassNameList);
      end
      else
        ClassNameList := ''; // TODO
    end;
end;

{ TdxThemeChangedNotificator }

constructor TdxThemeChangedNotificator.Create;
begin
  inherited Create;
  if IsThemeLibraryLoaded and (FThemeChangedNotificatorList <> nil) then
    FThemeChangedNotificatorList.Add(Self);
end;

destructor TdxThemeChangedNotificator.Destroy;
begin
  if IsThemeLibraryLoaded and (FThemeChangedNotificatorList <> nil) then
    FThemeChangedNotificatorList.Remove(Self);
  inherited Destroy;
end;

{ TdxThemeChangedEventReceiver }

constructor TdxThemeChangedEventReceiver.Create;
begin
  inherited Create;
{$IFDEF DELPHI6}
  FWindowHandle := Classes.AllocateHWnd(WndProc);
{$ELSE}
  FWindowHandle := Forms.AllocateHWnd(WndProc);
{$ENDIF}
end;

destructor TdxThemeChangedEventReceiver.Destroy;
begin
  FIsGlobalThemeActive := False;
{$IFDEF DELPHI6}
  Classes.DeallocateHWnd(FWindowHandle);
{$ELSE}
  Forms.DeallocateHWnd(FWindowHandle);
{$ENDIF}
  inherited Destroy;
end;

procedure TdxThemeChangedEventReceiver.WndProc(var Msg: TMessage);
var
  I: Integer;
begin
  with Msg do
    if Msg = WM_THEMECHANGED then
      try
        CloseAllThemes;
        DefWindowProc(FWindowHandle, Msg, wParam, lParam);
        FIsGlobalThemeActive := IsThemeActive;
        Result := 0;
        if FThemeChangedNotificatorList <> nil then
          for I := 0 to FThemeChangedNotificatorList.Count - 1 do
            with TdxThemeChangedNotificator(FThemeChangedNotificatorList[I]) do
              if Assigned(FOnThemeChanged) then
                FOnThemeChanged;
      except
        Application.HandleException(Self);
      end
    else
      Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

procedure TdxThemeChangedEventReceiver.WMThemeChanged(var Message: TMessage);
var
  I: Integer;
begin
  CloseAllThemes;
  inherited;
  FIsGlobalThemeActive := IsThemeActive;
  Message.Result := 0;
  if FThemeChangedNotificatorList <> nil then
    for I := 0 to FThemeChangedNotificatorList.Count - 1 do
      with TdxThemeChangedNotificator(FThemeChangedNotificatorList[I]) do
        if Assigned(FOnThemeChanged) then
          FOnThemeChanged;
end;

{$IFNDEF DELPHI5}
procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;
{$ENDIF}

initialization
  if IsThemeLibraryLoaded then
  begin
    FIsGlobalThemeActive := IsThemeActive;
    FThemeChangedEventReceiver := TdxThemeChangedEventReceiver.Create;
    FThemeChangedNotificatorList := TList.Create;
  end;

finalization
  if IsThemeLibraryLoaded then
  begin
    FreeAndNil(FThemeChangedEventReceiver);
    CloseAllThemes;
    FreeAndNil(FThemeChangedNotificatorList);
  end;

end.
