{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{                    ExpressSkins Library                            }
{                                                                    }
{           Copyright (c) 2006-2009 Developer Express Inc.           }
{                     ALL RIGHTS RESERVED                            }
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

unit dxSkinsDefaultPainters;

{$I cxVer.inc}

interface

uses
  Windows, SysUtils, Classes, dxGDIPlusApi, cxLookAndFeelPainters, dxSkinsCore,
  dxSkinsLookAndFeelPainter, dxSkinsStrs;

const
  sdxDefaultUserSkinData = 'DefaultUserSkinData';
  sdxSkinsUserSkinName = 'UserSkin';

type

  { TdxSkinsUserSkinPainter }

  TdxSkinsUserSkinPainter = class(TdxSkinLookAndFeelPainter)
  protected
    class function CacheData: TdxSkinLookAndFeelPainterInfo; override;
  public
    class function InternalUnitName: string; override;
  end;

procedure dxSkinsPopulateSkinResources(AModule: HMODULE; AResNames, ASkinNames: TStringList);
function dxSkinsUserSkinLoadFromFile(const AFileName: string; const ASkinName: string = ''): Boolean;
function dxSkinsUserSkinLoadFromStream(AStream: TStream; const ASkinName: string = ''): Boolean;
function dxSkinsUserSkinPopulateSkinNames(AStream: TStream; AList: TStrings): Boolean; overload;
function dxSkinsUserSkinPopulateSkinNames(const AFileName: string; AList: TStrings): Boolean; overload;

implementation

uses
  dxCore, dxSkinInfo, cxLookAndFeels;

{$R dxSkinsDefaultPainters.res}

type

  { TdxSkinUserLookAndFeelPainterInfo }

  TdxSkinUserLookAndFeelPainterInfo = class(TdxSkinLookAndFeelPainterInfo)
  protected
    procedure SkinChanged(Sender: TdxSkin); override;
  end;

procedure TdxSkinUserLookAndFeelPainterInfo.SkinChanged(Sender: TdxSkin);
begin
  inherited SkinChanged(Sender);
  RootLookAndFeel.Refresh;
end;

var
  CachedPainterData: TdxSkinUserLookAndFeelPainterInfo;

function ReadStringFromStream(AStream: TStream): string;
var
  L: Integer;
  ATemp: AnsiString;
begin
  AStream.Read(L, SizeOf(L));
  SetLength(ATemp, L);
  if L > 0 then
    AStream.ReadBuffer(ATemp[1], L);
  Result := dxAnsiStringToString(ATemp);
end;

type
  TdxListPair = class
  public
    ResNames, SkinNames: TStringList;
  end;

function EnumResNameProc(hModule: HMODULE; lpszType: LPCTSTR;
  lpszName: LPTSTR; AData: TdxListPair): Boolean; stdcall;

  function IsSkinResource(var ASkinName: string): Boolean;
  var
    AStream: TStream;
    AVersion: Double;
  begin
    AStream := TResourceStream.Create(hModule, lpszName, lpszType);
    try
      Result := dxSkinCheckSignature(AStream, AVersion);
      if Result then
      begin
        ASkinName := ReadStringFromStream(AStream);
        Result := Result and
          (AData.ResNames.IndexOf(lpszName) = -1) and
          (AData.SkinNames.IndexOf(ASkinName) = -1);
      end;
    finally
      AStream.Free;
    end;
  end;

var
  ASkinName: string;
begin
  Result := True;
  if IsSkinResource(ASkinName) then
  begin
    AData.SkinNames.AddObject(ASkinName,
      TObject(AData.ResNames.AddObject(lpszName, TObject(hModule))));
  end;
end;

procedure dxSkinsPopulateSkinResources(AModule: HMODULE; AResNames, ASkinNames: TStringList);
var
  AData: TdxListPair;
begin
  AResNames.Clear;
  ASkinNames.Clear;
  AData := TdxListPair.Create;
  try
    AData.ResNames := AResNames;
    AData.SkinNames := ASkinNames; 
    Windows.EnumResourceNames(AModule, PChar(sdxResourceType), @EnumResNameProc, Integer(AData));
    ASkinNames.Sort;
  finally
    AData.Free; 
  end;
end;

function dxSkinsUserSkinLoadFromFile(const AFileName: string;
  const ASkinName: string = ''): Boolean;
var
  AFileStream: TFileStream;
begin
  AFileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := dxSkinsUserSkinLoadFromStream(AFileStream, ASkinName);
  finally
    AFileStream.Free;
  end;
end;

function LoadUserSkinDataFromStream(AStream: TStream; APosition: Int64 = 0): Boolean;
begin
  AStream.Position := APosition;
  CachedPainterData.Skin.LoadFromStream(AStream);
  Result := True;
end;

function dxSkinsUserSkinLoadFromStream(AStream: TStream; const ASkinName: string = ''): Boolean;
var
  ASavedPosition: Int64;
  ASkinCount: Integer;
  ASkinSize: Integer;
  AVersion: Double;
  I: Integer;
begin
  Result := dxSkinCheckSignature(AStream, AVersion) and (AVersion > 1.00);
  if Result then
  begin
    Result := AStream.Read(ASkinCount, SizeOf(ASkinCount)) = SizeOf(ASkinCount);
    if not Result then Exit;
    for I := 0 to ASkinCount - 1 do
    begin
      AStream.Read(ASkinSize, SizeOf(ASkinSize));
      ASavedPosition := AStream.Position;
      Result := not dxSkinCheckSignature(AStream, AVersion) and
        LoadUserSkinDataFromStream(AStream);
      if Result then Break;
      Result := ((ASkinName = '') or
        SameText(ReadStringFromStream(AStream), ASkinName)) and
        LoadUserSkinDataFromStream(AStream, ASavedPosition);
      if Result then Break;
      AStream.Position := ASavedPosition + ASkinSize;
    end;
  end;
end;

function dxSkinsUserSkinPopulateSkinNames(AStream: TStream; AList: TStrings): Boolean;
var
  ASavedPosition: Int64;
  ASkinCount: Integer;
  ASkinSize: Integer;
  AVersion: Double;
  I: Integer;
begin
  Result := dxSkinCheckSignature(AStream, AVersion) and (AVersion > 1.00);
  if Result then
  begin
    Result := AStream.Read(ASkinCount, SizeOf(ASkinCount)) = SizeOf(ASkinCount);
    if not Result then Exit;      
    for I := 0 to ASkinCount - 1 do
    begin
      AStream.Read(ASkinSize, SizeOf(ASkinSize));
      ASavedPosition := AStream.Position;
      Result := dxSkinCheckSignature(AStream, AVersion);
      if not Result then Exit;
      AList.Add(ReadStringFromStream(AStream));
      AStream.Position := ASavedPosition + ASkinSize;      
    end;
  end;
end;

function dxSkinsUserSkinPopulateSkinNames(const AFileName: string; AList: TStrings): Boolean;
var
  AFileStream: TFileStream;
begin
  AFileStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := dxSkinsUserSkinPopulateSkinNames(AFileStream, AList);
  finally
    AFileStream.Free;
  end;
end;

{ TdxSkinsUserSkinPainter }

class function TdxSkinsUserSkinPainter.CacheData: TdxSkinLookAndFeelPainterInfo;
begin
  Result := CachedPainterData;
end;

class function TdxSkinsUserSkinPainter.InternalUnitName: string;
begin
  Result := 'dxSkinsDefaultPainters';
end;

//

procedure RegisterPainters;
begin
  if CheckGdiPlus then
  begin
    CachedPainterData := TdxSkinUserLookAndFeelPainterInfo.Create(
      TdxSkin.Create(sdxDefaultUserSkinData, True, HInstance));
    GetExtendedStylePainters.Register(sdxSkinsUserSkinName, TdxSkinsUserSkinPainter,
      CachedPainterData);
  end;
end;

procedure UnregisterPainters;
begin
  if GetExtendedStylePainters <> nil then
    GetExtendedStylePainters.UnRegister(sdxSkinsUserSkinName);
end;

initialization
  dxUnitsLoader.AddUnit(@RegisterPainters, @UnregisterPainters);

finalization
  dxUnitsLoader.RemoveUnit(@UnregisterPainters);

end.
