
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressCoreLibrary                                           }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSCORELIBRARY AND ALL            }
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

unit dxCore;

{$I cxVer.inc}

interface

uses
  Windows, Classes, SysUtils, Variants, Contnrs;

const
  dxUnicodePrefix: Word = $FEFF;

type
{$IFNDEF DELPHI12}
  TBytes = array of Byte;
  TRecordBuffer = PAnsiChar;
  TValueBuffer = Pointer;
{$ENDIF}

  IdxLocalizerListener = interface
  ['{2E98333B-1A56-4599-8A85-C2540E182031}']
    procedure TranslationChanged;
  end;

  TdxAnsiCharSet = set of AnsiChar;

  { TdxStream }

  TdxStream = class(TStream)
  private
    FIsUnicode: Boolean;
    FStream: TStream;
  protected
  {$IFDEF DELPHI7}
    function GetSize: Int64; override;
  {$ENDIF}
  public
    constructor Create(AStream: TStream); virtual;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;

    property IsUnicode: Boolean read FIsUnicode;
    property Stream: TStream read FStream;
  end;

  TdxProductResourceStrings = class;

  TdxAddResourceStringsProcedure = procedure(AProduct: TdxProductResourceStrings);

  TdxProductResourceStrings = class
  private
    FName: string;
    FInitializeProc: TdxAddResourceStringsProcedure;
    FResStringNames: TStrings;

    function GetNames(AIndex: Integer): string;
    function GetResStringsCount: Integer;
    procedure SetTranslation(AIndex: Integer);
    function GetValues(AIndex: Integer): string;
    procedure InitializeResStringNames;
  protected
    procedure Translate;
  public
    constructor Create(const AName: string; AInitializeProc: TdxAddResourceStringsProcedure); virtual;
    destructor Destroy; override;
    procedure Add(const AResStringName: string; AResStringAddr: Pointer);
    procedure Clear;
    function GetIndexByName(const AName: string): Integer;

    property Name: string read FName;
    property Names[AIndex: Integer]: string read GetNames;
    property ResStringsCount: Integer read GetResStringsCount;
    property Values[AIndex: Integer]: string read GetValues;
  end;

  TdxLocalizationTranslateResStringEvent = procedure(const AResStringName: string; AResString: Pointer) of object;

  TdxResourceStringsRepository = class
  private
    FListeners: TList;
    FProducts: TObjectList;
    FOnTranslateResString: TdxLocalizationTranslateResStringEvent;

    function GetProducts(AIndex: Integer): TdxProductResourceStrings;
    function GetProductsCount: Integer;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    procedure AddListener(AListener: IdxLocalizerListener);
    procedure RemoveListener(AListener: IdxLocalizerListener);
    procedure NotifyListeners;

    procedure RegisterProduct(const AProductName: string; AAddStringsProc: TdxAddResourceStringsProcedure);
    function GetProductIndexByName(AName: string): Integer;
    function GetOriginalValue(const AName: string): string;
    procedure Translate;
    procedure UnRegisterProduct(const AProductName: string);

    property Products[Index: Integer]: TdxProductResourceStrings read GetProducts;
    property ProductsCount: Integer read GetProductsCount;
    property OnTranslateResString: TdxLocalizationTranslateResStringEvent read FOnTranslateResString write FOnTranslateResString;
  end;

  EdxException = class(Exception);

//string functions  
function cxBinToHex(const ABuffer: AnsiString): AnsiString; overload;
function cxBinToHex(const ABuffer: PAnsiChar; ABufSize: Integer): AnsiString; overload;
function cxHexToBin(const AText: AnsiString): AnsiString; overload;
function cxHexToBin(const AText: PAnsiChar): AnsiString; overload;
function dxCharInSet(C: Char; const ACharSet: TdxAnsiCharSet): Boolean; {$IFDEF DELPHI9} inline;{$ENDIF}
function dxStringSize(const S: string): Integer; {$IFDEF DELPHI9} inline;{$ENDIF}

// string conversions
function dxAnsiStringToWideString(const ASource: AnsiString; ACodePage: Cardinal = CP_ACP;
  ASrcLength: Integer = -1): WideString;
function dxWideStringToAnsiString(const ASource: WideString; ACodePage: Cardinal = CP_ACP;
  ASrcLength: Integer = -1): AnsiString;

function dxAnsiStringToString(const S: AnsiString; ACodePage: Integer = CP_ACP): string; {$IFDEF DELPHI9} inline;{$ENDIF}
function dxStringToAnsiString(const S: string; ACodePage: Integer = CP_ACP): AnsiString; {$IFDEF DELPHI9} inline;{$ENDIF}

function dxShortStringToString(const S: ShortString): string; {$IFDEF DELPHI9} inline;{$ENDIF}
function dxStringToShortString(const S: string): ShortString; {$IFDEF DELPHI9} inline;{$ENDIF}

function dxStringToWideString(const S: string; ACodePage: Integer = CP_ACP): WideString; {$IFDEF DELPHI9} inline;{$ENDIF}
function dxWideStringToString(const S: WideString; ACodePage: Integer = CP_ACP): string; {$IFDEF DELPHI9} inline;{$ENDIF}

function dxVariantToAnsiString(const V: Variant): AnsiString;
function dxVarIsBlob(const V: Variant): Boolean;

function dxConcatenateStrings(const AStrings: array of PChar): string;
procedure dxStringToBytes(const S: string; var Buf);

function dxUTF8StringToAnsiString(const S: UTF8String): AnsiString;
function dxUTF8StringToWideString(const S: UTF8String): WideString;
function dxAnsiStringToUTF8String(const S: AnsiString): UTF8String;
function dxWideStringToUTF8String(const S: WideString): UTF8String;


// streaming
function dxIsUnicodeStream(AStream: TStream): Boolean;
procedure dxWriteStandardEncodingSignature(AStream: TStream);
procedure dxWriteStreamType(AStream: TStream);

function dxReadStr(Stream: TStream; AIsUnicode: Boolean): string;
procedure dxWriteStr(Stream: TStream; const S: string);

function dxResourceStringsRepository: TdxResourceStringsRepository;

function dxGetStringTypeW(dwInfoType: DWORD; const lpSrcStr: PWideChar;
  cchSrc: Integer; var lpCharType): BOOL;
function dxGetWideCharCType1(Ch: WideChar): Word;

//memory functions
procedure cxZeroMemory(ADestination: Pointer; ACount: Integer);
function cxAllocMem(Size: Cardinal): Pointer;
procedure cxFreeMem(P: Pointer);

procedure cxCopyData(ASource, ADestination: Pointer; ACount: Integer); overload;
procedure cxCopyData(ASource, ADestination: Pointer; ASourceOffSet, ADestinationOffSet, ACount: Integer); overload;
function ReadBoolean(ASource: Pointer; AOffset: Integer = 0): WordBool;
function ReadByte(ASource: Pointer; AOffset: Integer = 0): Byte;
function ReadInteger(ASource: Pointer; AOffset: Integer = 0): Integer;
function ReadPointer(ASource: Pointer): Pointer;
function ReadWord(ASource: Pointer; AOffset: Integer = 0): Word;
procedure WriteBoolean(ADestination: Pointer; AValue: WordBool; AOffset: Integer = 0);
procedure WriteByte(ADestination: Pointer; AValue: Byte; AOffset: Integer = 0);
procedure WriteInteger(ADestination: Pointer; AValue: Integer; AOffset: Integer = 0);
procedure WritePointer(ADestination: Pointer; AValue: Pointer);
procedure WriteWord(ADestination: Pointer; AValue: Word; AOffset: Integer = 0);

function ReadBufferFromStream(AStream: TStream; ABuffer: Pointer; Count: Integer): Boolean;
function ReadStringFromStream(AStream: TStream; out AValue: AnsiString): Longint;
function WriteBufferToStream(AStream: TStream; ABuffer: Pointer; ACount: Longint): Longint;
function WriteCharToStream(AStream: TStream; AValue: AnsiChar): Longint;
function WriteDoubleToStream(AStream: TStream; AValue: Double): Longint;
function WriteIntegerToStream(AStream: TStream; AValue: Integer): Longint;
function WriteSmallIntToStream(AStream: TStream; AValue: SmallInt): Longint;
function WriteStringToStream(AStream: TStream; const AValue: AnsiString): Longint;

procedure ExchangeLongWords(var AValue1, AValue2);
procedure Shift(var P: Pointer; AOffset: Integer);

// platform info
var
  IsWin9X: Boolean;
  IsWin95, IsWin98, IsWinMe: Boolean;

  IsWinNT: Boolean;
  IsWin2K, IsWin2KOrLater: Boolean;
  IsWinXP, IsWinXPOrLater: Boolean;
  IsWin2KOrXP: Boolean;

  IsWinVista, IsWinVistaOrLater: Boolean;

implementation

type
  TdxStreamHeader = array[0..5] of AnsiChar;

const
  StreamFormatANSI: TdxStreamHeader = 'DXAFMT';
  StreamFormatUNICODE: TdxStreamHeader = 'DXUFMT';

var
  FdxResourceStringsRepository: TdxResourceStringsRepository;

function GetStringTypeW(dwInfoType: DWORD; const lpSrcStr: PWideChar;
  cchSrc: Integer; var lpCharType): BOOL; stdcall; external kernel32 name 'GetStringTypeW';

function cxBinToHex(const ABuffer: AnsiString): AnsiString;
begin
  Result := cxBinToHex(PAnsiChar(ABuffer), Length(ABuffer));
end;

function cxBinToHex(const ABuffer: PAnsiChar; ABufSize: Integer): AnsiString;
begin
  SetLength(Result, ABufSize * 2);
  BinToHex(ABuffer, PAnsiChar(Result), ABufSize);
end;

function cxHexToBin(const AText: AnsiString): AnsiString;
begin
  Result := cxHexToBin(PAnsiChar(AText));
end;

function cxHexToBin(const AText: PAnsiChar): AnsiString;
begin
  SetLength(Result, Length(AText) div 2);
  HexToBin(AText, PAnsiChar(Result), Length(Result));
end;

function dxCharInSet(C: Char; const ACharSet: TdxAnsiCharSet): Boolean;
begin
  {$IFDEF DELPHI12}
    Result := CharInSet(C, ACharSet);
  {$ELSE}
    Result := C in ACharSet;
  {$ENDIF}
end;

function dxStringSize(const S: string): Integer;
begin
  Result := Length(S) * SizeOf(Char);
end;

function dxAnsiStringToWideString(const ASource: AnsiString; ACodePage: Cardinal = CP_ACP;
  ASrcLength: Integer = -1): WideString;
var
  ADestLength: Integer;
begin
  Result := '';
  if ASource = '' then Exit;
  if ACodePage = CP_UTF8 then //CP_UTF8 not supported on Windows 95
    {$IFDEF DELPHI12}
      Result := UTF8ToString(ASource)
    {$ELSE}
      Result := UTF8Decode(ASource)
    {$ENDIF}
  else
  begin
    if ASrcLength < 0 then
      ASrcLength := Length(ASource);
    ADestLength := MultiByteToWideChar(ACodePage, 0, PAnsiChar(ASource), ASrcLength, nil, 0);
    SetLength(Result, ADestLength);
    MultiByteToWideChar(ACodePage, MB_PRECOMPOSED, PAnsiChar(ASource), ASrcLength, PWideChar(Result), ADestLength);
  end;
end;

function dxWideStringToAnsiString(const ASource: WideString; ACodePage: Cardinal = CP_ACP;
  ASrcLength: Integer = -1): AnsiString;
var
  ADestLength: Integer;
begin
  Result := '';
  if ASource = '' then Exit;
  if ACodePage = CP_UTF8 then //CP_UTF8 not supported on Windows 95
      Result := UTF8Encode(ASource)
  else
  begin
    if ASrcLength < 0 then
      ASrcLength := Length(ASource);
    ADestLength := WideCharToMultiByte(ACodePage, 0, PWideChar(ASource), ASrcLength, nil, 0, nil, nil);
    SetLength(Result, ADestLength);
    WideCharToMultiByte(ACodePage, 0, PWideChar(ASource), ASrcLength, PAnsiChar(Result), ADestLength, nil, nil);
  end;
end;

function dxStringToWideString(const S: string; ACodePage: Integer = CP_ACP): WideString;
begin
  Result := {$IFDEF DELPHI12} S {$ELSE} dxAnsiStringToWideString(S, ACodePage) {$ENDIF};
end;

function dxWideStringToString(const S: WideString; ACodePage: Integer = CP_ACP): string;
begin
  Result := {$IFDEF DELPHI12} S {$ELSE} dxWideStringToAnsiString(S, ACodePage) {$ENDIF};
end;

function dxConcatenateStrings(const AStrings: array of PChar): string;
var
  I: Integer;
begin
  for I := 0 to High(AStrings) - 1 do
    Result := Result + AStrings[I];
end;

procedure dxStringToBytes(const S: string; var Buf);
begin
  if Length(S) > 0 then
    Move(S[1], Buf, dxStringSize(S));
end;

function dxUTF8StringToAnsiString(const S: UTF8String): AnsiString;
begin
  Result := {$IFDEF DELPHI12}dxWideStringToAnsiString{$ENDIF}(Utf8ToAnsi(S));
end;

function dxUTF8StringToWideString(const S: UTF8String): WideString;
begin
  Result := {$IFDEF DELPHI12}UTF8ToWideString{$ELSE}UTF8Decode{$ENDIF}(S);
end;

function dxAnsiStringToUTF8String(const S: AnsiString): UTF8String;
begin
  Result := UTF8Encode({$IFDEF DELPHI12}dxAnsiStringToWideString{$ENDIF}(S));
end;

function dxWideStringToUTF8String(const S: WideString): UTF8String;
begin
  Result := UTF8Encode(S);
end;

function dxAnsiStringToString(const S: AnsiString; ACodePage: Integer = CP_ACP): string;
begin
  Result := {$IFDEF DELPHI12} dxAnsiStringToWideString(S, ACodePage) {$ELSE} S {$ENDIF};
end;

function dxStringToAnsiString(const S: string; ACodePage: Integer = CP_ACP): AnsiString;
begin
  Result := {$IFDEF DELPHI12} dxWideStringToAnsiString(S, ACodePage) {$ELSE} S {$ENDIF};
end;

function dxVariantToAnsiString(const V: Variant): AnsiString;
var
  ASize: Integer;
begin
  if VarIsArray(V) and (VarArrayDimCount(V) = 1) then
  begin
    ASize := VarArrayHighBound(V, 1) - VarArrayLowBound(V, 1) + 1;
    SetLength(Result, ASize);
    Move(VarArrayLock(V)^, Result[1], ASize);
    VarArrayUnlock(V);
  end
  else
    Result := dxStringToAnsiString(VarToStr(V))
end;

function dxVarIsBlob(const V: Variant): Boolean;
begin
  Result := VarIsStr(V) or (VarIsArray(V) and (VarArrayDimCount(V) = 1));
end;

function dxShortStringToString(const S: ShortString): string;
begin
  Result := {$IFDEF DELPHI12}UTF8ToString{$ENDIF}(S);
end;

function dxStringToShortString(const S: string): ShortString;
begin
  Result := {$IFDEF DELPHI12}UTF8EncodeToShortString{$ENDIF}(S);
end;

function dxIsUnicodeStream(AStream: TStream): Boolean;
var
  B: TdxStreamHeader;
begin
  Result := False;
  if (AStream.Size - AStream.Position) > SizeOf(TdxStreamHeader) then
  begin
    AStream.ReadBuffer(B, SizeOf(TdxStreamHeader));
    Result := B = StreamFormatUNICODE;
    if not Result and (B <> StreamFormatANSI) then
      AStream.Position := AStream.Position - SizeOf(TdxStreamHeader);
  end;
end;

procedure dxWriteStandardEncodingSignature(AStream: TStream);
begin
{$IFDEF DELPHI12}
  AStream.WriteBuffer(dxUnicodePrefix, SizeOf(dxUnicodePrefix));
{$ENDIF}
end;

procedure dxWriteStreamType(AStream: TStream);
begin
{$IFNDEF STREAMANSIFORMAT}
  {$IFDEF DELPHI12}
     AStream.WriteBuffer(StreamFormatUNICODE, SizeOf(TdxStreamHeader));
  {$ELSE}
     AStream.WriteBuffer(StreamFormatANSI, SizeOf(TdxStreamHeader));
  {$ENDIF}
{$ENDIF}
end;

function dxReadStr(Stream: TStream; AIsUnicode: Boolean): string;
var
  L: Word;
  SA: AnsiString;
  SW: WideString;
begin
  Stream.ReadBuffer(L, SizeOf(Word));
  if AIsUnicode then
  begin
    SetLength(SW, L);
    if L > 0 then Stream.ReadBuffer(SW[1], L * 2);
    Result := SW;
  end
  else
  begin
    SetLength(SA, L);
    if L > 0 then Stream.ReadBuffer(SA[1], L);
  {$IFDEF DELPHI12}
    Result := UTF8ToWideString(SA);
  {$ELSE}
    Result := SA;
  {$ENDIF}
  end;
end;

procedure dxWriteStr(Stream: TStream; const S: string);
var
  L: Integer;
{$IFDEF STREAMANSIFORMAT}
  SA: AnsiString;
{$ENDIF}
begin
  L := Length(S);
  if L > $FFFF then L := $FFFF;
  Stream.WriteBuffer(L, SizeOf(Word));
  if L > 0 then
  begin
  {$IFDEF STREAMANSIFORMAT}
    {$IFDEF DELPHI12}
      SA := UTF8Encode(S);
    {$ELSE}
      SA := S;
    {$ENDIF}
    Stream.WriteBuffer(SA[1], L);
  {$ELSE}
    Stream.WriteBuffer(S[1], L * SizeOf(Char));
  {$ENDIF}
  end;
end;

function dxResourceStringsRepository: TdxResourceStringsRepository;
begin
  if FdxResourceStringsRepository = nil then
    FdxResourceStringsRepository := TdxResourceStringsRepository.Create;
  Result := FdxResourceStringsRepository;
end;

function dxGetStringTypeW(dwInfoType: DWORD; const lpSrcStr: PWideChar;
  cchSrc: Integer; var lpCharType): BOOL;
begin
  Result := GetStringTypeW(dwInfoType, lpSrcStr, cchSrc, lpCharType);
end;

function dxGetWideCharCType1(Ch: WideChar): Word;
begin
  if not dxGetStringTypeW(CT_CTYPE1, @Ch, 1, Result) then
    Result := 0;
end;

procedure cxZeroMemory(ADestination: Pointer; ACount: Integer);
begin
  ZeroMemory(ADestination, ACount);
end;

function cxAllocMem(Size: Cardinal): Pointer;
begin
  GetMem(Result, Size);
  cxZeroMemory(Result, Size);
end;

procedure cxFreeMem(P: Pointer);
begin
  FreeMem(P);
end;

procedure cxCopyData(ASource, ADestination: Pointer; ACount: Integer);
begin
  Move(ASource^, ADestination^, ACount);
end;

procedure cxCopyData(ASource, ADestination: Pointer; ASourceOffSet, ADestinationOffSet, ACount: Integer);
begin
  if ASourceOffSet > 0 then
    Shift(ASource, ASourceOffSet);
  if ADestinationOffSet > 0 then
    Shift(ADestination, ADestinationOffSet);
  cxCopyData(ASource, ADestination, ACount);
end;

function ReadBoolean(ASource: Pointer; AOffset: Integer = 0): WordBool;
begin
  cxCopyData(ASource, @Result, AOffset, 0, SizeOf(WordBool));
end;

function ReadByte(ASource: Pointer; AOffset: Integer = 0): Byte;
begin
  cxCopyData(ASource, @Result, AOffset, 0, SizeOf(Byte));
end;

function ReadInteger(ASource: Pointer; AOffset: Integer = 0): Integer;
begin
  cxCopyData(ASource, @Result, AOffset, 0, SizeOf(Integer));
end;

function ReadPointer(ASource: Pointer): Pointer;
begin
  Result := Pointer(ASource^);
end;

function ReadWord(ASource: Pointer; AOffset: Integer = 0): Word;
begin
  cxCopyData(ASource, @Result, AOffset, 0, SizeOf(Word));
end;

procedure WriteBoolean(ADestination: Pointer; AValue: WordBool; AOffset: Integer = 0);
begin
  cxCopyData(@AValue, ADestination, 0, AOffset, SizeOf(WordBool));
end;

procedure WriteByte(ADestination: Pointer; AValue: Byte; AOffset: Integer = 0);
begin
  cxCopyData(@AValue, ADestination, 0, AOffset, SizeOf(Byte));
end;

procedure WriteInteger(ADestination: Pointer; AValue: Integer; AOffset: Integer = 0);
begin
  cxCopyData(@AValue, ADestination, 0, AOffset, SizeOf(Integer));
end;

procedure WritePointer(ADestination: Pointer; AValue: Pointer);
begin
  Pointer(ADestination^) := AValue;
end;

procedure WriteWord(ADestination: Pointer; AValue: Word; AOffset: Integer = 0);
begin
  cxCopyData(@AValue, ADestination, 0, AOffset, SizeOf(Word));
end;

function ReadBufferFromStream(AStream: TStream; ABuffer: Pointer; Count: Integer): Boolean;
begin
  Result := AStream.Read(ABuffer^, Count) = Count;
end;

function ReadStringFromStream(AStream: TStream; out AValue: AnsiString): Longint;
begin
  SetLength(AValue, AStream.Size);
  Result := AStream.Read(AValue[1], AStream.Size);
end;

function WriteBufferToStream(AStream: TStream; ABuffer: Pointer; ACount: Longint): Longint;
var
  AData: TBytes;
begin
  SetLength(AData, ACount);
  if ABuffer <> nil then
    cxCopyData(ABuffer, AData, ACount);

  Result := AStream.Write(AData[0], ACount);
end;

function WriteCharToStream(AStream: TStream; AValue: AnsiChar): Longint;
begin
  Result := AStream.Write(AValue, 1);
end;

function WriteDoubleToStream(AStream: TStream; AValue: Double): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(Double));
end;

function WriteIntegerToStream(AStream: TStream; AValue: Integer): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(Integer));
end;

function WriteSmallIntToStream(AStream: TStream; AValue: SmallInt): Longint;
begin
  Result := AStream.Write(AValue, SizeOf(SmallInt));
end;

function WriteStringToStream(AStream: TStream; const AValue: AnsiString): Longint;
begin
  Result := AStream.Write(PAnsiChar(AValue)^, Length(AValue));
end;

procedure ExchangeLongWords(var AValue1, AValue2);
var
  ATempValue: LongWord;
begin
  ATempValue := LongWord(AValue1);
  LongWord(AValue1) := LongWord(AValue2);
  LongWord(AValue2) := ATempValue;
end;

procedure Shift(var P: Pointer; AOffset: Integer);
begin
  P := Pointer(Integer(P) + AOffset);
end;

{ TdxStream }

constructor TdxStream.Create(AStream: TStream);
begin
  FIsUnicode := dxIsUnicodeStream(AStream);
  FStream := AStream;
end;

{$IFDEF DELPHI7}

function TdxStream.GetSize: Int64;
begin
  Result := FStream.Size;
end;

{$ENDIF}

function TdxStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FStream.Read(Buffer, Count);
end;

function TdxStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  Result := FStream.Seek(Offset, Origin);
end;

function TdxStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FStream.Write(Buffer, Count);
end;

  { TdxProductResourceStrings }

constructor TdxProductResourceStrings.Create(const AName: string; AInitializeProc: TdxAddResourceStringsProcedure);
begin
  FName := AName;
  FResStringNames := TStringList.Create;
  TStringList(FResStringNames).Sorted := True;
  FInitializeProc := AInitializeProc;
  InitializeResStringNames;
end;

destructor TdxProductResourceStrings.Destroy;
begin
  FInitializeProc := nil;
  FResStringNames.Free;
end;

procedure TdxProductResourceStrings.Add(const AResStringName: string; AResStringAddr: Pointer);
begin
  FResStringNames.AddObject(AResStringName, AResStringAddr);
end;

procedure TdxProductResourceStrings.Clear;
begin
  FResStringNames.Clear;
end;

function TdxProductResourceStrings.GetIndexByName(const AName: string): Integer;
begin
  if not TStringList(FResStringNames).Find(AName, Result) then
    Result := -1;
end;

procedure TdxProductResourceStrings.Translate;
var
  I: Integer;
begin
  for I := 0 to ResStringsCount - 1 do
    SetTranslation(I);
end;

function TdxProductResourceStrings.GetNames(AIndex: Integer): string;
begin
  Result := FResStringNames[AIndex];
end;

function TdxProductResourceStrings.GetResStringsCount: Integer;
begin
  Result := FResStringNames.Count;
end;

procedure TdxProductResourceStrings.SetTranslation(AIndex: Integer);
begin
  dxResourceStringsRepository.OnTranslateResString(Names[AIndex], FResStringNames.Objects[AIndex]);
end;

function TdxProductResourceStrings.GetValues(AIndex: Integer): string;
begin
  Result := LoadResString(PResStringRec(FResStringNames.Objects[AIndex]));
end;

procedure TdxProductResourceStrings.InitializeResStringNames;
begin
  if Assigned(FInitializeProc) then
    FInitializeProc(Self);
end;

 { TdxResourceStringsRepository }

constructor TdxResourceStringsRepository.Create;
begin
  FProducts := TObjectList.Create;
  FListeners := TList.Create;
end;

destructor TdxResourceStringsRepository.Destroy;
begin
  FListeners.Free;
  FProducts.Free;
end;

procedure TdxResourceStringsRepository.AddListener(AListener: IdxLocalizerListener);
begin
  if FListeners.IndexOf(Pointer(AListener)) = -1 then
    FListeners.Add(Pointer(AListener));
end;

procedure TdxResourceStringsRepository.RemoveListener(AListener: IdxLocalizerListener);
begin
  FListeners.Remove(Pointer(AListener));
end;

procedure TdxResourceStringsRepository.NotifyListeners;
var
  I: Integer;
begin
  for I := 0 to FListeners.Count - 1 do
    IdxLocalizerListener(FListeners[I]).TranslationChanged;
end;

procedure TdxResourceStringsRepository.RegisterProduct(const AProductName: string; AAddStringsProc: TdxAddResourceStringsProcedure);
begin
  FProducts.Add(TdxProductResourceStrings.Create(AProductName, AAddStringsProc));
end;

function TdxResourceStringsRepository.GetProductIndexByName(AName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to ProductsCount - 1 do
    if Products[I].Name = AName then
    begin
      Result := I;
      Break;
    end;
end;

function TdxResourceStringsRepository.GetOriginalValue(const AName: string): string;
var
  I, AIndex: Integer;
begin
  Result := '';
  for I := 0 to ProductsCount - 1 do
  begin
    AIndex := Products[I].GetIndexByName(AName);
    if AIndex <> -1 then
    begin
      Result := Products[I].Values[AIndex];
      Break;
    end;
  end;
end;

procedure TdxResourceStringsRepository.Translate;
var
  I: Integer;
begin
  if Assigned(FOnTranslateResString) then
  begin
    for I := 0 to ProductsCount - 1 do
      Products[I].Translate;
  end;
end;

procedure TdxResourceStringsRepository.UnRegisterProduct(const AProductName: string);
var
  AIndex: Integer;
begin
  AIndex := GetProductIndexByName(AProductName);
  if AIndex <> -1 then
    FProducts.Delete(AIndex);
end;

function TdxResourceStringsRepository.GetProducts(AIndex: Integer): TdxProductResourceStrings;
begin
  Result := TdxProductResourceStrings(FProducts[AIndex]);
end;

function TdxResourceStringsRepository.GetProductsCount: Integer;
begin
  Result := FProducts.Count;
end;

procedure InitPlatformInfo;
begin
  IsWin9X := Win32Platform = VER_PLATFORM_WIN32_WINDOWS;

  IsWin95 := IsWin9X and (Win32MinorVersion = 0);
  IsWin98 := IsWin9X and (Win32MinorVersion = 10);
  IsWinMe := IsWin9X and (Win32MinorVersion = 90);

  IsWinNT := Win32Platform = VER_PLATFORM_WIN32_NT;

  IsWin2K := IsWinNT and (Win32MajorVersion = 5) and (Win32MinorVersion = 0);
  IsWin2KOrLater := IsWinNT and (Win32MajorVersion >= 5);
  IsWinXP := IsWinNT and (Win32MajorVersion = 5) and (Win32MinorVersion > 0);
  IsWinXPOrLater := IsWinNT and (Win32MajorVersion >= 5) and not IsWin2K;
  IsWin2KOrXP := IsWin2K or IsWinXP;

  IsWinVista := IsWinNT and (Win32MajorVersion = 6);
  IsWinVistaOrLater := IsWinNT and (Win32MajorVersion >= 6);
end;

initialization
  InitPlatformInfo;

finalization
  FreeAndNil(FdxResourceStringsRepository);

end.
