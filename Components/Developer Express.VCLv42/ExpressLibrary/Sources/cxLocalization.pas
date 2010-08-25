{********************************************************************}
{                                                                    }
{           Developer Express Visual Component Library               }
{           Express Cross Platform Library classes                   }
{                                                                    }
{           Copyright (c) 2000-2009 Developer Express Inc.           }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCROSSPLATFORMLIBRARY AND ALL   }
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

unit cxLocalization;

{$I cxVer.inc}

interface

uses
  Windows, Classes, Forms, SysUtils, cxClasses, IniFiles;

const
  ANoActiveLanguage = 'English (Original translation)';

type

  TcxLocalizerStorage = class;
  TcxLocalizerStorageClass = class of TcxLocalizerStorage;

  TcxLanguage = class(TCollectionItem)
  private
    FDictionary: TStrings;
    FLocaleID: Cardinal;

    function GetName: string;
    procedure SetDictionary(AValue: TStrings);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    function FindTranslation(const AResStringName: string; out AValue: string): Boolean;
    procedure ResetValue(const AResStringName: string);
    procedure SetTranslation(const AResStringName, AValue: string);

    property Name: string read GetName;
    property Dictionary: TStrings read FDictionary write SetDictionary;
    property LocaleID: Cardinal read FLocaleID write FLocaleID;
  end;

  TcxLanguages = class(TCollection)
  private
    FActiveLanguage: Integer;
    FCustomResStrings: TStrings;
    FOnLanguagesChanged: TNotifyEvent;
    FOwner: TPersistent;

    procedure SetActiveLanguage(AValue: Integer);
    procedure TranslateResString(const AResStringName: string; AResString: Pointer);
  protected
    function GetItem(Index: Integer): TcxLanguage;
    function GetOwner: TPersistent; override;
    function GetLocalizedString(const AResStringName: string; out AValue: string): Boolean;
    procedure SetItem(Index: Integer; Value: TcxLanguage);
    procedure Translate;
    procedure Update(Item: TCollectionItem); override;

    property ActiveLanguage: Integer read FActiveLanguage write SetActiveLanguage;
    property OnLanguagesChanged: TNotifyEvent read FOnLanguagesChanged write FOnLanguagesChanged;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    function Add: TcxLanguage;
    function GetLanguageByName(AName: string): Integer;
    procedure SetCustomResStringOriginalValue(const AResStringName, AValue: string);

    property CustomResStrings: TStrings read FCustomResStrings;
    property Items[Index: Integer]: TcxLanguage read GetItem write SetItem; default;
  end;

  TcxLocalizerTranslateEvent = procedure(const AResStringName: string;
    var AResStringValue: string; out AHandled: Boolean) of object;

  TcxLocalizer = class(TComponent)
  private
    FActive: Boolean;
    FFileName: TFileName;
    FLanguages: TcxLanguages;
    FLoadedActive: Boolean;
    FLoadedLanguage: string;
    FStorage: TcxLocalizerStorage;
    FOnTranslate: TcxLocalizerTranslateEvent;
    function GetLanguage: string;
    function GetLanguageIndex: Integer;
    function GetLocale: Cardinal;
    procedure InternalLoadFromStream(AStream: TStream);
    function IsLanguageIndexValid: Boolean;
    function IsLocaleStored: Boolean;
    procedure RecreateStorage;
    procedure SetActive(AValue: Boolean);
    procedure SetFileName(AValue: TFileName);
    procedure SetLanguage(AValue: string);
    procedure SetLanguageIndex(AValue: Integer);
    procedure SetLocale(AValue: Cardinal);
  protected
    procedure Clear;
    function DoCustomTranslate(const AResStringName: string; out ALocalizedValue: string): Boolean;
    function GetStorageClassType: TcxLocalizerStorageClass;
    procedure LanguagesChanged(ASender: TObject);
    procedure Loaded; override;
    procedure UpdateDependentComponents;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;

    procedure LoadFromStream(AStream: TStream);
    procedure LoadFromFile(const AFileName: TFileName = '');
    procedure SaveToFile(const AFileName: TFileName{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});
    procedure SaveToStream(AStream: TStream{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});

    procedure Translate;

    property LanguageIndex: Integer read GetLanguageIndex write SetLanguageIndex;
    property Language: string read GetLanguage write SetLanguage;
    property Languages: TcxLanguages read FLanguages;
  published
    property Active: Boolean read FActive write SetActive default False;
    property FileName: TFileName read FFileName write SetFileName;
    property Locale: Cardinal read GetLocale write SetLocale stored IsLocaleStored;
    property OnTranslate: TcxLocalizerTranslateEvent read FOnTranslate write FOnTranslate;
  end;

  TcxLocalizerStorage = class(TPersistent)
  private
{$IFDEF DELPHI12}
    function GetEndcodingFromLocaleID(ALocaleID: Integer): TEncoding;
{$ENDIF}
  public
     procedure LoadFromStream(AStream: TStream; ALanguages: TcxLanguages);
     procedure SaveToStream(AStream: TStream; ALanguages: TcxLanguages{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});
  end;

implementation

uses
  Math, Dialogs, Controls, dxCore;

const
  ACustomResourceStrings = 'Custom Resource Strings';

type
  TcxLocalizerDictionary = class(TStringList)
  private
    function GetValue(const Name: string): string;
    procedure SetValue(const Name, Value: string);
  {$IFNDEF DELPHI7}
    function GetNameValueSeparator: Char;
    function GetValueFromIndex(Index: Integer): string;
  {$ENDIF}
  protected
    function CompareStrings(const S1, S2: string): Integer; override;
  public
  {$IFNDEF DELPHI7}
    property NameValueSeparator: Char read GetNameValueSeparator;
    property ValueFromIndex[Index: Integer]: string read GetValueFromIndex;
  {$ENDIF}
    property Values[const Name: string]: string read GetValue write SetValue;
  end;

{ TcxLocalizerDictionary }

function TcxLocalizerDictionary.CompareStrings(const S1, S2: string): Integer;
var
  AS1, AS2: string;
begin
  AS1 := ExtractName(S1);
  if AS1 = '' then
    AS1 := S1;
  AS2 := ExtractName(S2);
  if AS2 = '' then
    AS2 := S2;
  Result := inherited CompareStrings(AS1, AS2);
end;

function TcxLocalizerDictionary.GetValue(const Name: string): string;
var
  I: Integer;
begin
  if Find(Name, I) then
    Result := Copy(Get(I), Length(Name) + 2, MaxInt)
  else
    Result := '';
end;

procedure TcxLocalizerDictionary.SetValue(const Name, Value: string);
var
  I: Integer;
  AObject: TObject;
begin
  BeginUpdate;
  AObject := nil;
  if Find(Name, I) then
  begin
    AObject := GetObject(I);
    Delete(I);
  end;
  InsertItem(I, Name + NameValueSeparator + Value, AObject);
  EndUpdate;
end;

{$IFNDEF DELPHI7}
function TcxLocalizerDictionary.GetNameValueSeparator: Char;
begin
  Result := '=';
end;

function TcxLocalizerDictionary.GetValueFromIndex(Index: Integer): string;
begin
  if Index >= 0 then
    Result := Copy(Get(Index), Length(Names[Index]) + 2, MaxInt) else
    Result := '';
end;
{$ENDIF}

{ TcxLanguage }

constructor TcxLanguage.Create(Collection: TCollection);
begin
  inherited;
  FDictionary := TcxLocalizerDictionary.Create;
  TStringList(FDictionary).Sorted := True;
end;

destructor TcxLanguage.Destroy;
begin
  FreeAndNil(FDictionary);
  inherited;
end;

procedure TcxLanguage.Assign(Source: TPersistent);
begin
  if Source is TcxLanguage then
  begin
    LocaleID := TcxLanguage(Source).LocaleID;
    Dictionary := TcxLanguage(Source).Dictionary;
  end
  else
    inherited;
end;

function TcxLanguage.FindTranslation(const AResStringName: string; out AValue: string): Boolean;
var
  AIndex: Integer;
begin
  Result := TStringList(FDictionary).Find(AResStringName, AIndex);
  if Result then
    AValue := TcxLocalizerDictionary(FDictionary).ValueFromIndex[AIndex]
  else
    AValue := '';
end;

procedure TcxLanguage.ResetValue(const AResStringName: string);
var
  I: Integer;
begin
  if TStringList(FDictionary).Find(AResStringName, I) then
    FDictionary.Delete(I);
end;

procedure TcxLanguage.SetTranslation(const AResStringName, AValue: string);
begin
  if AResStringName <> '' then
    TcxLocalizerDictionary(FDictionary).Values[AResStringName] := AValue;
end;

function TcxLanguage.GetName: string;
begin
  Result := Languages.NameFromLocaleID[LocaleID];
end;

procedure TcxLanguage.SetDictionary(AValue: TStrings);
begin
  FDictionary.Assign(AValue)
end;

{ TcxLanguages }

constructor TcxLanguages.Create(AOwner: TPersistent);
begin
  inherited Create(TcxLanguage);
  FActiveLanguage := -1;
  FOwner := AOwner;
  FCustomResStrings := TcxLocalizerDictionary.Create;
  TStringList(FCustomResStrings).Sorted := True;
end;

destructor TcxLanguages.Destroy;
begin
  FCustomResStrings.Free;
  inherited;
end;

function TcxLanguages.Add: TcxLanguage;
begin
  Result := TcxLanguage(inherited Add);
end;

function TcxLanguages.GetLanguageByName(AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
    if Items[I].Name = AName then
    begin
      Result := I;
      Break;
    end;
end;

procedure TcxLanguages.SetCustomResStringOriginalValue(const AResStringName, AValue: string);
begin
  if AResStringName <> '' then
    TcxLocalizerDictionary(FCustomResStrings).Values[AResStringName] := AValue;
end;

function TcxLanguages.GetItem(Index: Integer): TcxLanguage;
begin
  Result := TcxLanguage(inherited GetItem(Index));
end;

function TcxLanguages.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

function TcxLanguages.GetLocalizedString(const AResStringName: string; out AValue: string): Boolean;
begin
  AValue := '';
  Result := False;
  if (0 <= ActiveLanguage) and (ActiveLanguage < Count) then
    Result := Items[ActiveLanguage].FindTranslation(AResStringName, AValue);
end;

procedure TcxLanguages.SetItem(Index: Integer; Value: TcxLanguage);
begin
  inherited SetItem(Index, Value);
end;

procedure TcxLanguages.Translate;
var
  APreviousHandler: TdxLocalizationTranslateResStringEvent;
begin
  cxClearResourceStrings;
  APreviousHandler := dxResourceStringsRepository.OnTranslateResString;
  dxResourceStringsRepository.OnTranslateResString := TranslateResString;
  dxResourceStringsRepository.Translate;
  dxResourceStringsRepository.OnTranslateResString := APreviousHandler;
end;

procedure TcxLanguages.Update(Item: TCollectionItem);
begin
  if Assigned(FOnLanguagesChanged) then
    FOnLanguagesChanged(Self); 
end;

procedure TcxLanguages.SetActiveLanguage(AValue: Integer);
begin
  if FActiveLanguage <> AValue then
    FActiveLanguage := AValue;
end;

procedure TcxLanguages.TranslateResString(const AResStringName: string; AResString: Pointer);
var
  ALocalizedValue: string;
begin
  if TcxLocalizer(FOwner).DoCustomTranslate(AResStringName, ALocalizedValue) or
    GetLocalizedString(AResStringName, ALocalizedValue) then
    cxSetResourceString(AResString, ALocalizedValue);
end;

{ TcxLocalizer }

constructor TcxLocalizer.Create(AOwner: TComponent);
begin
  inherited;
  FLanguages := TcxLanguages.Create(Self);
  FLanguages.OnLanguagesChanged := LanguagesChanged;
  RecreateStorage;
end;

destructor TcxLocalizer.Destroy;
begin
  FreeAndNil(FLanguages);
  FreeAndNil(FStorage);
  inherited;
end;

procedure TcxLocalizer.Assign(Source: TPersistent);
var
  ALocalizer: TcxLocalizer;
begin
  if Source is TcxLocalizer then
  begin
    ALocalizer := TcxLocalizer(Source);
    FileName := ALocalizer.FileName;
    Locale := ALocalizer.Locale;
  end
  else
    inherited;
end;

procedure TcxLocalizer.LoadFromStream(AStream: TStream);
begin
  Active := False;
  InternalLoadFromStream(AStream);
end;

procedure TcxLocalizer.LoadFromFile(const AFileName: TFileName = '');
var
  AFileStream: TFileStream;
begin
  Active := False;
  if AFileName <> '' then
    FFileName := AFileName;
  AFileStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyNone);
  try
    InternalLoadFromStream(AFileStream);
  finally
    AFileStream.Free;
  end;
end;

procedure TcxLocalizer.SaveToFile(const AFileName: TFileName{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});
var
  AFileStream: TFileStream;
begin
  if AFileName = '' then Exit;
  AFileStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(AFileStream{$IFDEF DELPHI12}, AIsAnsiSaveFormat{$ENDIF});
  finally
    AFileStream.Free;
  end;
  if FileExists(AFileName) then
    FFileName := AFileName;
end;

procedure TcxLocalizer.SaveToStream(AStream: TStream{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});
begin
  FStorage.SaveToStream(AStream, Languages{$IFDEF DELPHI12}, AIsAnsiSaveFormat{$ENDIF});
end;

procedure TcxLocalizer.Translate;
begin
  FLanguages.Translate;
  UpdateDependentComponents;
end;

procedure TcxLocalizer.Clear;
begin
  Languages.Clear;
  Languages.CustomResStrings.Clear;
end;

function TcxLocalizer.DoCustomTranslate(const AResStringName: string; out ALocalizedValue: string): Boolean;
begin
  Result := False;
  if Assigned(FOnTranslate) then
  begin
    ALocalizedValue := dxResourceStringsRepository.GetOriginalValue(AResStringName);
    FOnTranslate(AResStringName, ALocalizedValue, Result);
  end;
end;

function TcxLocalizer.GetStorageClassType: TcxLocalizerStorageClass;
begin
  Result := TcxLocalizerStorage;
end;

procedure TcxLocalizer.LanguagesChanged(ASender: TObject);
begin
  LanguageIndex := Min(LanguageIndex, Languages.Count - 1);
end;

procedure TcxLocalizer.Loaded;
begin
  inherited;
  try
    Active := FLoadedActive;
  except
    if csDesigning in ComponentState then
      if Assigned(Classes.ApplicationHandleException) then
        Classes.ApplicationHandleException(ExceptObject)
      else
        ShowException(ExceptObject, ExceptAddr)
    else
      raise;
  end;
  Language := FLoadedLanguage;
end;

procedure TcxLocalizer.UpdateDependentComponents;
begin
  dxResourceStringsRepository.NotifyListeners;
end;

function TcxLocalizer.GetLanguage: string;
begin
  if IsLanguageIndexValid then
    Result := Languages[LanguageIndex].Name
  else
    Result := ANoActiveLanguage;
end;

function TcxLocalizer.GetLanguageIndex: Integer;
begin
  Result := FLanguages.ActiveLanguage;
end;

function TcxLocalizer.GetLocale: Cardinal;
begin
  if IsLanguageIndexValid then
    Result := Languages[LanguageIndex].LocaleID
  else
    Result := 0;
end;

procedure TcxLocalizer.InternalLoadFromStream(AStream: TStream);
begin
  FStorage.LoadFromStream(AStream, Languages);
  FActive := True;
end;

function TcxLocalizer.IsLanguageIndexValid: Boolean;
begin
  Result := (0 <= LanguageIndex) and (LanguageIndex < Languages.Count);
end;

function TcxLocalizer.IsLocaleStored: Boolean;
begin
  Result := LanguageIndex <> -1;
end;

procedure TcxLocalizer.RecreateStorage;
begin
  FStorage := GetStorageClassType.Create;
end;

procedure TcxLocalizer.SetActive(AValue: Boolean);
begin
  if csLoading in ComponentState then
    FLoadedActive := AValue
  else
    if FActive <> AValue then
    begin
      FActive := AValue;
      if AValue then
        LoadFromFile
      else
        Clear;
    end;
end;

procedure TcxLocalizer.SetFileName(AValue: TFileName);
begin
  if FFileName <> AValue then
  begin
    FFileName := AValue;
    if not (csLoading in ComponentState) then
      Active := False;
  end;
end;

procedure TcxLocalizer.SetLanguage(AValue: string);
begin
  if csLoading in ComponentState then
    FLoadedLanguage := AValue
  else
    LanguageIndex := Languages.GetLanguageByName(AValue);
end;

procedure TcxLocalizer.SetLanguageIndex(AValue: Integer);
begin
  AValue := Min(Max(AValue, -1), Languages.Count - 1);
  if FLanguages.ActiveLanguage <> AValue then
  begin
    FLanguages.ActiveLanguage := AValue;
    Translate;
  end;
end;

procedure TcxLocalizer.SetLocale(AValue: Cardinal);
begin
  Language := SysUtils.Languages.NameFromLocaleID[AValue];
end;

{ TcxLocalizerStorage }

procedure TcxLocalizerStorage.LoadFromStream(AStream: TStream; ALanguages: TcxLanguages);

{$IFDEF DELPHI12}
  function IsUnicode(AStream: TStream): Boolean;
  var
    ASize: Integer;
    ABuffer: TBytes;
    AEncoding: TEncoding;
  begin
    ASize := AStream.Size - AStream.Position;
    SetLength(ABuffer, ASize);
    AStream.Read(ABuffer[0], ASize);
    AEncoding := nil;
    TEncoding.GetBufferEncoding(ABuffer, AEncoding);
    Result := AEncoding = TEncoding.Unicode;
  end;
{$ENDIF}

  procedure ReadSectionValues(AIniFile: TCustomIniFile; const ASectionName: string; AList: TStrings);
  var
    I: Integer;
    AName, AValue: string;
  begin
    AIniFile.ReadSectionValues(ASectionName, AList);
    AList.BeginUpdate;
    try
      for I := 0 to AList.Count - 1 do
      begin
        AValue := TcxLocalizerDictionary(AList).ValueFromIndex[I];
        AValue := StringReplace(AValue, ' \n', #13#10, [rfReplaceAll, rfIgnoreCase]);
        AValue := StringReplace(AValue, '\\n', '\n', [rfReplaceAll, rfIgnoreCase]);
        Delete(AValue, 1, 1);
        Delete(AValue, Length(AValue), 1);
        AName := AList.Names[I];
        TcxLocalizerDictionary(AList).Values[AName] := AValue;
      end;
    finally
      AList.EndUpdate;
    end;
  end;

var
  AList, ASections: TStringList;
  AMemIniFile: TMemIniFile;
  ASectionName: string;
  ALanguage: TcxLanguage;
  I: Integer;
{$IFDEF DELPHI12}
  AEncoding: TEncoding;
  AIsUnicode: Boolean;
  AStartPos: Integer;
{$ENDIF}
begin
  AMemIniFile := TMemIniFile.Create('');
  AList := TStringList.Create;
  ASections := TStringList.Create;
{$IFDEF DELPHI12}AStartPos := AStream.Position;{$ENDIF}
  try
    AList.LoadFromStream(AStream);
    AMemIniFile.SetStrings(AList);
    AMemIniFile.ReadSections(ASections);
  {$IFDEF DELPHI12}
    AStream.Position := AStartPos;
    AIsUnicode := IsUnicode(AStream);
  {$ENDIF}
    for I := 0 to ASections.Count - 1 do
    begin
      ASectionName := ASections[I];
      if ASectionName <> ACustomResourceStrings then
      begin
        ALanguage := ALanguages.Add;
        ALanguage.LocaleID := StrToInt(ASectionName);
      {$IFDEF DELPHI12}
        if not AIsUnicode then
        begin
          AEncoding := GetEndcodingFromLocaleID(StrToInt(ASectionName));
          try
            AStream.Position := AStartPos;
            AList.LoadFromStream(AStream, AEncoding);
            AMemIniFile.SetStrings(AList);
          finally
            FreeAndNil(AEncoding);
          end;
        end;
      {$ENDIF}
        ReadSectionValues(AMemIniFile, ASectionName, ALanguage.Dictionary);
      end
      else
        ReadSectionValues(AMemIniFile, ASectionName, ALanguages.CustomResStrings);
    end;
  finally
    FreeAndNil(AList);
    FreeAndNil(ASections);
    FreeAndNil(AMemIniFile);
  end;
end;

procedure TcxLocalizerStorage.SaveToStream(AStream: TStream;
  ALanguages: TcxLanguages{$IFDEF DELPHI12}; AIsAnsiSaveFormat: Boolean{$ENDIF});

  procedure WriteSection(AIniFile: TCustomIniFile; const ASectionName: string; AList: TStrings);
  var
    I: Integer;
    AName, AValue: string;
  begin
    for I := 0 to AList.Count - 1 do
    begin
      AName := AList.Names[I];
      AValue := AList.Values[AName];
      AValue := StringReplace(AValue, '\n', '\\n', [rfReplaceAll, rfIgnoreCase]);
      AValue := StringReplace(AValue, #13#10, ' \n', [rfReplaceAll, rfIgnoreCase]);
      AValue := '"' + AValue + '"';
      AIniFile.WriteString(ASectionName, AName, AValue);
    end;
  end;

var
  AList: TStringList;
  AMemIniFile: TMemIniFile;
  {$IFDEF DELPHI12}AEncoding: TEncoding;{$ENDIF}
  I: Integer;
begin
  AMemIniFile := TMemIniFile.Create('');
  AList := TStringList.Create;
  try
    for I := 0 to ALanguages.Count - 1 do
    begin
      WriteSection(AMemIniFile, IntToStr(ALanguages[I].LocaleID), ALanguages[I].Dictionary);
    {$IFDEF DELPHI12}
      if AIsAnsiSaveFormat then
      begin
        AEncoding := GetEndcodingFromLocaleID(ALanguages[I].LocaleID);
        try
          AMemIniFile.GetStrings(AList);
          AMemIniFile.Clear;
          AList.SaveToStream(AStream, AEncoding);
          AList.Clear;
        finally
          FreeAndNil(AEncoding);
        end;
      end;
    {$ENDIF}
    end;
    WriteSection(AMemIniFile, ACustomResourceStrings, ALanguages.CustomResStrings);
    AMemIniFile.GetStrings(AList);
    {$IFDEF DELPHI12}if AIsAnsiSaveFormat then AEncoding := nil else AEncoding := TEncoding.Unicode;{$ENDIF}
    AList.SaveToStream(AStream{$IFDEF DELPHI12}, AEncoding{$ENDIF});
  finally
    FreeAndNil(AList);
    FreeAndNil(AMemIniFile);
  end;
end;

{$IFDEF DELPHI12}
function TcxLocalizerStorage.GetEndcodingFromLocaleID(ALocaleID: Integer): TEncoding;
var
  ACodePage: Integer;
  ABuffer: array [0..6] of Char;
begin
  GetLocaleInfo(ALocaleID, LOCALE_IDEFAULTANSICODEPAGE, ABuffer, SizeOf(ABuffer));
  ACodePage := StrToIntDef(ABuffer, GetACP);
  Result := TEncoding.GetEncoding(ACodePage);
end;
{$ENDIF}

end.
