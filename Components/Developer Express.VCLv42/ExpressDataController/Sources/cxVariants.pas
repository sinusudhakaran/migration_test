
{********************************************************************}
{                                                                    }
{       Developer Express Visual Component Library                   }
{       ExpressDataController                                        }
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
{   LICENSED TO DISTRIBUTE THE EXPRESSDATACONTROLLER AND ALL         }
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

unit cxVariants;

{$I cxVer.inc}

interface

uses
  SysUtils, Classes, dxCore{$IFDEF DELPHI6}, Variants{$ENDIF};

type
  LargeInt = Int64;
  {$IFNDEF DELPHI6}
  TVarType = Word;
  {$ENDIF}
  TVariantArray = array of Variant;

  { Read/Write }

  TcxFiler = class
  private
    FIsUnicode: Boolean;
    FStream: TStream;
  public
    constructor Create(AStream: TStream);

    property Stream: TStream read FStream;
    property IsUnicode: Boolean read FIsUnicode;
  end;

  TcxReader = class(TcxFiler)
  public
    function ReadAnsiString: AnsiString;
    function ReadBoolean: Boolean;
    function ReadByte: Byte;
    function ReadCardinal: Cardinal;
    function ReadChar: Char;
    function ReadCurrency: Currency;
    function ReadDateTime: TDateTime;
    function ReadFloat: Extended;
    function ReadInteger: Integer;
    function ReadLargeInt: LargeInt;
    function ReadShortInt: ShortInt;
    function ReadSingle: Single;
    function ReadSmallInt: SmallInt;
    function ReadString_: string;
    function ReadVariant: Variant;
    function ReadWideString: WideString;
    function ReadWord: Word;
  end;

  TcxWriter = class(TcxFiler)
  public
    procedure WriteAnsiString(const S: AnsiString);
    procedure WriteBoolean(AValue: Boolean);
    procedure WriteByte(AValue: Byte);
    procedure WriteCardinal(AValue: Cardinal);
    procedure WriteChar(AValue: Char);
    procedure WriteCurrency(AValue: Currency);
    procedure WriteDateTime(AValue: TDateTime);
    procedure WriteFloat(AValue: Extended);
    procedure WriteInteger(AValue: Integer);
    procedure WriteLargeInt(AValue: LargeInt);
    procedure WriteShortInt(AValue: ShortInt);
    procedure WriteSingle(AValue: Single);
    procedure WriteSmallInt(AValue: SmallInt);
    procedure WriteVariant(const AValue: Variant);
    procedure WriteWideString(const S: WideString);
    procedure WriteWord(AValue: Word);
  end;

function VarCompare(const V1, V2: Variant): Integer;
function VarEquals(const V1, V2: Variant): Boolean;
function VarEqualsExact(const V1, V2: Variant): Boolean;
function VarEqualsSoft(const V1, V2: Variant): Boolean;
function VarIndex(const AList: TVariantArray; const AValue: Variant): Integer;
function VarIsDate(const AValue: Variant): Boolean;
function VarIsNumericEx(const AValue: Variant): Boolean;
function VarIsSoftNull(const AValue: Variant): Boolean;
function VarToStrEx(const V: Variant): string;
function VarTypeIsCurrency(AVarType: TVarType): Boolean;
{$IFNDEF DELPHI6}
function FindVarData(const V: Variant): PVarData;
function VarIsFloat(const AValue: Variant): Boolean;
function VarIsNumeric(const AValue: Variant): Boolean;
function VarIsOrdinal(const AValue: Variant): Boolean;
function VarIsStr(const AValue: Variant): Boolean;
function VarIsType(const AValue: Variant; AVarType: TVarType): Boolean;
function VarSameValue(const V1, V2: Variant): Boolean;
{$ENDIF}
function VarBetweenArrayCreate(const AValue1, AValue2: Variant): Variant;
function VarListArrayCreate(const AValue: Variant): Variant;
procedure VarListArrayAddValue(var Value: Variant; const AValue: Variant);

function ReadAnsiStringFunc(AStream: TStream): AnsiString;
procedure ReadAnsiStringProc(AStream: TStream; var S: AnsiString);
procedure WriteAnsiStringProc(AStream: TStream; const S: AnsiString);

function ReadWideStringFunc(AStream: TStream): WideString;
procedure ReadWideStringProc(AStream: TStream; var S: WideString);
procedure WriteWideStringProc(AStream: TStream; const S: WideString);

function ReadVariantFunc(AStream: TStream): Variant;
procedure ReadVariantProc(AStream: TStream; var Value: Variant);
procedure WriteVariantProc(AStream: TStream; const AValue: Variant);

function ReadBooleanFunc(AStream: TStream): Boolean;
procedure ReadBooleanProc(AStream: TStream; var Value: Boolean);
procedure WriteBooleanProc(AStream: TStream; AValue: Boolean);

function ReadCharFunc(AStream: TStream): Char;
procedure ReadCharProc(AStream: TStream; var Value: Char);
procedure WriteCharProc(AStream: TStream; AValue: Char);

function ReadFloatFunc(AStream: TStream): Extended;
procedure ReadFloatProc(AStream: TStream; var Value: Extended);
procedure WriteFloatProc(AStream: TStream; AValue: Extended);

function ReadSingleFunc(AStream: TStream): Single;
procedure ReadSingleProc(AStream: TStream; var Value: Single);
procedure WriteSingleProc(AStream: TStream; AValue: Single);

function ReadCurrencyFunc(AStream: TStream): Currency;
procedure ReadCurrencyProc(AStream: TStream; var Value: Currency);
procedure WriteCurrencyProc(AStream: TStream; AValue: Currency);

function ReadDateTimeFunc(AStream: TStream): TDateTime;
procedure ReadDateTimeProc(AStream: TStream; var Value: TDateTime);
procedure WriteDateTimeProc(AStream: TStream; AValue: TDateTime);

function ReadIntegerFunc(AStream: TStream): Integer;
procedure ReadIntegerProc(AStream: TStream; var Value: Integer);
procedure WriteIntegerProc(AStream: TStream; AValue: Integer);

function ReadLargeIntFunc(AStream: TStream): LargeInt;
procedure ReadLargeIntProc(AStream: TStream; var Value: LargeInt);
procedure WriteLargeIntProc(AStream: TStream; AValue: LargeInt);

function ReadByteFunc(AStream: TStream): Byte;
procedure ReadByteProc(AStream: TStream; var Value: Byte);
procedure WriteByteProc(AStream: TStream; AValue: Byte);

function ReadSmallIntFunc(AStream: TStream): SmallInt;
procedure ReadSmallIntProc(AStream: TStream; var Value: SmallInt);
procedure WriteSmallIntProc(AStream: TStream; AValue: SmallInt);

function ReadCardinalFunc(AStream: TStream): Cardinal;
procedure ReadCardinalProc(AStream: TStream; var Value: Cardinal);
procedure WriteCardinalProc(AStream: TStream; AValue: Cardinal);

function ReadShortIntFunc(AStream: TStream): ShortInt;
procedure ReadShortIntProc(AStream: TStream; var Value: ShortInt);
procedure WriteShortIntProc(AStream: TStream; AValue: ShortInt);

function ReadWordFunc(AStream: TStream): Word;
procedure ReadWordProc(AStream: TStream; var Value: Word);
procedure WriteWordProc(AStream: TStream; AValue: Word);

implementation

uses
{$IFNDEF NONDB}
  {$IFDEF DELPHI6}
  FMTBcd, SqlTimSt,
  {$ENDIF}
{$ENDIF}
  Windows, cxDataConsts;

function VarArrayCompare(const V1, V2: Variant): Integer;
var
  I: Integer;
begin
  if VarIsArray(V1) and VarIsArray(V2) then
  begin
    Result := VarArrayHighBound(V1, 1) - VarArrayHighBound(V2, 1);
    if Result = 0 then
    begin
      for I := 0 to VarArrayHighBound(V1, 1) do
      begin
        Result := VarCompare(V1[I], V2[I]);
        if Result <> 0 then
          Break;
      end;
    end;
  end
  else
    if VarIsArray(V1) then
      Result := 1
    else
      if VarIsArray(V2) then
        Result := -1
      else
        Result := VarCompare(V1, V2);
end;

function VarCompare(const V1, V2: Variant): Integer;

  function CompareValues(const V1, V2: Variant): Integer;
  begin
    try
      if VarIsEmpty(V1) then
        if VarIsEmpty(V2) then
          Result := 0
        else
          Result := -1
      else
        if VarIsEmpty(V2) then
          Result := 1
        else
          if V1 = V2 then
            Result := 0
          else
            {$IFDEF DELPHI6}
            if VarIsNull(V1) then
              Result := -1
            else
              if VarIsNull(V2) then
                Result := 1
              else
            {$ENDIF}
                if V1 < V2 then
                  Result := -1
                else
                  Result := 1;
    except
      on EVariantError do
        Result := -1;
    end;
  end;

begin
{$IFDEF DELPHI6}
  {$IFNDEF DELPHI7}
  if (VarType(V1) = varString) and (VarType(V2) = varString) then
    Result := CompareStr(V1, V2)
  else
    if (VarType(V1) = varDate) and (VarType(V2) = varDate) then
      Result := CompareValues(Double(V1), Double(V2))
    else
  {$ENDIF}
{$ENDIF}
      if VarIsArray(V1) or VarIsArray(V2) then
        Result := VarArrayCompare(V1, V2)
      else
        Result := CompareValues(V1, V2);
end;

function VarEquals(const V1, V2: Variant): Boolean;
begin
  Result := VarCompare(V1, V2) = 0;
end;

function VarEqualsExact(const V1, V2: Variant): Boolean;
var
  AVarType1, AVarType2: Integer;
  AValue1, AValue2: Variant;
begin
  AVarType1 := VarType(V1);
  AVarType2 := VarType(V2);
  if (AVarType1 = varNull) or (AVarType2 = varNull) or
    ((AVarType1 <> varBoolean) and (AVarType2 <> varBoolean)) then
    Result := VarEquals(V1, V2)
  else
    try
      VarCast(AValue1, V1, varString);
      VarCast(AValue2, V2, varString);
      Result := AValue1 = AValue2;
    except
      on EVariantError do
        Result := False;
    end;
end;

function VarEqualsSoft(const V1, V2: Variant): Boolean;
begin
  Result := VarEquals(V1, V2) or (VarIsSoftNull(V1) and VarIsSoftNull(V2));
end;

function VarIndex(const AList: TVariantArray; const AValue: Variant): Integer;
begin
  for Result := 0 to Length(AList) - 1 do
    if VarEquals(AList[Result], AValue) then Exit;
  Result := -1;
end;

{$IFNDEF DELPHI6}
function FindVarData(const V: Variant): PVarData;
begin
  Result := @TVarData(V);
  while Result.VType = varByRef or varVariant do
    Result := PVarData(Result.VPointer);
end;
{$ENDIF}

function VarIsDate(const AValue: Variant): Boolean;

  function VarTypeIsDate(const AVarType: TVarType): Boolean;
  begin
    Result := (AVarType = varDate)
      {$IFNDEF NONDB}{$IFDEF DELPHI6} or (AVarType = VarSQLTimeStamp){$ENDIF}{$ENDIF};
  end;

begin
  Result := VarTypeIsDate(FindVarData(AValue)^.VType);
end;

function VarIsNumericEx(const AValue: Variant): Boolean;
begin
  Result := VarIsNumeric(AValue)
    {$IFNDEF NONDB}{$IFDEF DELPHI6} or
      (FindVarData(AValue)^.VType = VarFMTBcd)
    {$ENDIF}{$ENDIF};
end;

{$IFNDEF DELPHI6}

function VarIsType(const AValue: Variant; AVarType: TVarType): Boolean;
begin
  Result := FindVarData(AValue)^.VType = AVarType;
end;

function VarTypeIsOrdinal(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSmallInt, varInteger, varBoolean, varByte];
end;

function VarIsOrdinal(const AValue: Variant): Boolean;
begin
  Result := VarTypeIsOrdinal(FindVarData(AValue)^.VType);
end;

function VarTypeIsFloat(const AVarType: TVarType): Boolean;
begin
  Result := AVarType in [varSingle, varDouble, varCurrency];
end;

function VarIsFloat(const AValue: Variant): Boolean;
begin
  Result := VarTypeIsFloat(FindVarData(AValue)^.VType);
end;

function VarTypeIsNumeric(const AVarType: TVarType): Boolean;
begin
  Result := VarTypeIsOrdinal(AVarType) or VarTypeIsFloat(AVarType);
end;

function VarIsNumeric(const AValue: Variant): Boolean;
begin
  Result := VarTypeIsNumeric(FindVarData(AValue)^.VType);
end;

function VarTypeIsStr(const AVarType: TVarType): Boolean;
begin
  Result := (AVarType = varString) or (AVarType = varOleStr){$IFDEF DELPHI12}or varUString{$ENDIF};
end;

function VarIsStr(const AValue: Variant): Boolean;
begin
  Result := VarTypeIsStr(FindVarData(AValue)^.VType);
end;

function VarSameValue(const V1, V2: Variant): Boolean;
var
  D1, D2: TVarData;
begin
  D1 := FindVarData(V1)^;
  D2 := FindVarData(V2)^;
  if D1.VType = varEmpty then
    Result := D2.VType = varEmpty
  else
    if D1.VType = varNull then
      Result := D2.VType = varNull
    else
      if D2.VType in [varEmpty, varNull] then
        Result := False
      else
        Result := V1 = V2;
end;

{$ENDIF}

function VarIsSoftNull(const AValue: Variant): Boolean;
begin
  Result := VarIsNull(AValue) or
    ({(VarType(AValue) = varString)}VarIsStr(AValue) and (AValue = ''));
end;

function VarToStrEx(const V: Variant): string;
begin
  Result := VarToStr(V);
{$IFNDEF DELPHI6}
  if VarType(V) = varDouble then
    Result := StringReplace(Result, GetLocaleChar(GetThreadLocale, LOCALE_SDECIMAL, '.'),
      DecimalSeparator, []);
{$ENDIF}
end;

function VarTypeIsCurrency(AVarType: TVarType): Boolean;
begin
  Result := (AVarType = varCurrency)
  {$IFNDEF NONDB}
    {$IFDEF DELPHI6} or (AVarType = VarFMTBcd){$ENDIF}
  {$ENDIF};
end;

function VarBetweenArrayCreate(const AValue1, AValue2: Variant): Variant;
begin
  Result := VarArrayCreate([0, 1], varVariant);
  Result[0] := AValue1;
  Result[1] := AValue2;
end;

function VarListArrayCreate(const AValue: Variant): Variant;
begin
  Result := VarArrayCreate([0, 0], varVariant);
  Result[0] := AValue;
end;

procedure VarListArrayAddValue(var Value: Variant; const AValue: Variant);
var
  V: Variant;
  I, C: Integer;
begin
  C := VarArrayHighBound(Value, 1) - VarArrayLowBound(Value, 1) + 2;
  V := VarArrayCreate([0, C - 1], varVariant);
  for I := VarArrayLowBound(Value, 1) to VarArrayHighBound(Value, 1) do
    V[I] := Value[I];
  V[C - 1] := AValue;
  Value := V;
end;

// Stream routines

function ReadAnsiStringFunc(AStream: TStream): AnsiString;
begin
  ReadAnsiStringProc(AStream, Result);
end;

procedure ReadAnsiStringProc(AStream: TStream; var S: AnsiString);
var
  L: Integer;
begin
  AStream.ReadBuffer(L, SizeOf(L));
  SetLength(S, L);
  AStream.ReadBuffer(Pointer(S)^, L);
end;

procedure WriteAnsiStringProc(AStream: TStream; const S: AnsiString);
var
  L: Integer;
begin
  L := Length(S);
  AStream.WriteBuffer(L, SizeOf(L));
  AStream.WriteBuffer(S[1], L);
end;

function ReadWideStringFunc(AStream: TStream): WideString;
begin
  ReadWideStringProc(AStream, Result); 
end;

procedure ReadWideStringProc(AStream: TStream; var S: WideString);
var
  L: Integer;
begin
  AStream.ReadBuffer(L, SizeOf(L));
  SetLength(S, L);
  AStream.ReadBuffer(Pointer(S)^, L * 2);
end;

procedure WriteWideStringProc(AStream: TStream; const S: WideString);
var
  L: Integer;
begin
  L := Length(S);
  AStream.WriteBuffer(L, SizeOf(L));
  AStream.WriteBuffer(Pointer(S)^, L * 2);
end;

function ReadVariantFunc(AStream: TStream): Variant;
begin
  ReadVariantProc(AStream, Result);
end;

procedure ReadVariantProc(AStream: TStream; var Value: Variant);
const
  ValTtoVarT: array[TValueType] of Integer = (varNull, varError,
    {$IFNDEF DELPHI6}varByte{$ELSE}varShortInt{$ENDIF},
    varSmallInt, varInteger, varDouble, varString, varError, varBoolean,
    varBoolean, varError, varError, varString, varEmpty, varError, varSingle,
    varCurrency, varDate, varOleStr,
    {$IFDEF DELPHI6}varInt64{$ELSE}varError{$ENDIF}
    {$IFDEF DELPHI6}, varError {$IFDEF DELPHI8}, varDouble{$ENDIF}{$ENDIF});
var
  ValType: TValueType;

  function ReadValue: TValueType;
  var
    B: Byte;
  begin
    AStream.ReadBuffer(B, SizeOf(Byte));
    Result := TValueType(B);
  end;

  function ReadInteger: LargeInt;
  var
    SH: Shortint;
    SM: Smallint;
    I: Integer;
  begin
    case ValType of
      vaInt8:
        begin
          AStream.ReadBuffer(SH, SizeOf(SH));
          Result := SH;
        end;
      vaInt16:
        begin
          AStream.ReadBuffer(SM, SizeOf(SM));
          Result := SM;
        end;
  {$IFDEF DELPHI6}
      vaInt32:
  {$ELSE}
    else
  {$ENDIF}
      begin
        AStream.ReadBuffer(I, SizeOf(I));
        Result := I;
      end
  {$IFDEF DELPHI6}
    else  // vaInt64
      AStream.ReadBuffer(Result, SizeOf(Result));
  {$ENDIF}
    end;
  end;

  function ReadFloat: Extended;
  begin
    AStream.ReadBuffer(Result, SizeOf(Result));
  end;

  function ReadSingle: Single;
  begin
    AStream.ReadBuffer(Result, SizeOf(Result));
  end;

  function ReadCurrency: Currency;
  begin
    ReadCurrencyProc(AStream, Result);
  end;

  function ReadDate: TDateTime;
  begin
    ReadDateTimeProc(AStream, Result);
  end;

  function ReadAnsiString: AnsiString;
  var
    L: Integer;
  begin
    L := 0;
    case ValType of
      vaString:
        AStream.ReadBuffer(L, SizeOf(Byte));
    else {vaLString}
      AStream.ReadBuffer(L, SizeOf(Integer));
    end;
    SetLength(Result, L);
    AStream.ReadBuffer(Pointer(Result)^, L);
  end;

  function ReadWideString: WideString;
  begin
    ReadWideStringProc(AStream, Result);
  end;

  procedure ReadArrayProc(var Value: Variant);
  var
    I, C: Integer;
    V: Variant;
  begin
    // read size
    ValType := ReadValue; // len
    C := ReadInteger;
    // read values
    Value := VarArrayCreate([0, C - 1], varVariant);
    for I := 0 to C - 1 do
    begin
      ReadVariantProc(AStream, V);
      Value[I] := V;
    end;
  end;

begin
  ValType := ReadValue;
  if ValType = vaList then
  begin
    ReadArrayProc(Value);
    Exit;
  end;
  case ValType of
    vaNil:
      VarClear(Value);
    vaNull:
      Value := Null;
    vaInt8:
      {$IFNDEF DELPHI6}
      TVarData(Value).VByte := Byte(ReadInteger);
      {$ELSE}
      TVarData(Value).VShortInt := ShortInt(ReadInteger);
      {$ENDIF}
    vaInt16:
      TVarData(Value).VSmallint := Smallint(ReadInteger);
    vaInt32:
      TVarData(Value).VInteger := ReadInteger;
  {$IFDEF DELPHI6}
    vaInt64:
      TVarData(Value).VInt64 := ReadInteger;
  {$ENDIF}
    vaExtended:
      TVarData(Value).VDouble := ReadFloat;
    vaString, vaLString:
      Value := ReadAnsiString;
    vaFalse, vaTrue:
      TVarData(Value).VBoolean := ValType = vaTrue;
    vaWString:
      Value := ReadWideString;
    vaSingle:
      TVarData(Value).VSingle := ReadSingle;
    vaCurrency:
      TVarData(Value).VCurrency := ReadCurrency;
    vaDate:
      TVarData(Value).VDate := ReadDate;
  else
    raise EReadError.Create(cxSDataReadError);
  end;
  TVarData(Value).VType := ValTtoVarT[ValType];
end;

procedure WriteVariantProc(AStream: TStream; const AValue: Variant);

  procedure WriteValue(Value: TValueType);
  begin
    AStream.WriteBuffer(Byte(Value), SizeOf(Byte));
  end;

  procedure WriteInteger(Value: {$IFDEF DELPHI6}LargeInt{$ELSE}Integer{$ENDIF});
  var
    SH: Shortint;
    SM: Smallint;
    I: Integer;
  begin
    if (Value >= Low(ShortInt)) and (Value <= High(ShortInt)) then
    begin
      WriteValue(vaInt8);
      SH := Value;
      AStream.WriteBuffer(SH, SizeOf(SH));
    end
    else
      if (Value >= Low(SmallInt)) and (Value <= High(SmallInt)) then
      begin
        WriteValue(vaInt16);
        SM := Value;
        AStream.WriteBuffer(SM, SizeOf(SM));
      end
      else
      {$IFDEF DELPHI6}
        if (Value >= Low(Integer)) and (Value <= High(Integer)) then
      {$ENDIF}
        begin
          WriteValue(vaInt32);
          I := Value;
          AStream.WriteBuffer(I, SizeOf(I));
        end
      {$IFDEF DELPHI6}
        else
        begin
          WriteValue(vaInt64);
          AStream.WriteBuffer(Value, SizeOf(Value));
        end;
      {$ENDIF}
  end;

  procedure WriteAnsiString(const Value: AnsiString);
  var
    B: Byte;
    L: Integer;
  begin
    L := Length(Value);
    if L <= 255 then
    begin
      WriteValue(vaString);
      B := L;
      AStream.WriteBuffer(B, SizeOf(B));
    end
    else
    begin
      WriteValue(vaLString);
      AStream.WriteBuffer(L, SizeOf(L));
    end;
    AStream.WriteBuffer(Pointer(Value)^, L);
  end;

  procedure WriteFloat(const Value: Extended);
  begin
    WriteValue(vaExtended);
    AStream.WriteBuffer(Value, SizeOf(Extended));
  end;

  procedure WriteSingle(const Value: Single);
  begin
    WriteValue(vaSingle);
    AStream.WriteBuffer(Value, SizeOf(Single));
  end;
  
  procedure WriteCurrency(const Value: Currency);
  begin
    WriteValue(vaCurrency);
    WriteCurrencyProc(AStream, Value);
  end;
  
  procedure WriteDate(const Value: TDateTime);
  begin
    WriteValue(vaDate);
    WriteDateTimeProc(AStream, Value);
  end;

  procedure WriteWideString(const Value: WideString);
  begin
    WriteValue(vaWString);
    WriteWideStringProc(AStream, Value);
  end;

  procedure WriteArrayProc(const Value: Variant);
  var
    I, L, H: Integer;
  begin
    if VarArrayDimCount(Value) <> 1 then
      raise EWriteError.Create(cxSDataWriteError);
    L := VarArrayLowBound(Value, 1);
    H := VarArrayHighBound(Value, 1);
    WriteValue(vaList);
    WriteInteger(H - L + 1);
    for I := L to H do
      WriteVariantProc(AStream, Value[I]);
  end;

var
  VType: Integer;
begin
  if VarIsArray(AValue) then
  begin
    WriteArrayProc(AValue);
    Exit;
  end;
  VType := VarType(AValue);
  case VType and varTypeMask of
    varEmpty:
      WriteValue(vaNil);
    varNull:
      WriteValue(vaNull);
    varString:
      WriteAnsiString(dxVariantToAnsiString(AValue));
  {$IFDEF DELPHI6}
    varShortInt, varWord, varLongWord, varInt64,
  {$ENDIF}
    varByte, varSmallInt, varInteger:
      WriteInteger(AValue);
    varDouble:
      WriteFloat(AValue);
    varBoolean:
      if AValue then
        WriteValue(vaTrue)
      else
        WriteValue(vaFalse);
  {$IFDEF DELPHI12}
    varUString,
  {$ENDIF}
    varOleStr:
      WriteWideString(AValue);
    varSingle:
      WriteSingle(AValue);
    varCurrency:
      WriteCurrency(AValue);
    varDate:
      WriteDate(AValue);
  else
{$IFDEF DELPHI6}
  {$IFNDEF NONDB}
    if VType = VarSQLTimeStamp then
      WriteVariantProc(AStream, TDateTime(AValue))
    else
  {$ENDIF}
{$ENDIF}
    try
      WriteAnsiString(dxVariantToAnsiString(AValue));
    except
      raise EWriteError.Create(cxSDataWriteError);
    end;
  end;
end;

function ReadBooleanFunc(AStream: TStream): Boolean;
begin
  ReadBooleanProc(AStream, Result);
end;

procedure ReadBooleanProc(AStream: TStream; var Value: Boolean);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteBooleanProc(AStream: TStream; AValue: Boolean);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadCharFunc(AStream: TStream): Char;
begin
  ReadCharProc(AStream, Result);
end;

procedure ReadCharProc(AStream: TStream; var Value: Char);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteCharProc(AStream: TStream; AValue: Char);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadFloatFunc(AStream: TStream): Extended;
begin
  ReadFloatProc(AStream, Result);
end;

procedure ReadFloatProc(AStream: TStream; var Value: Extended);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteFloatProc(AStream: TStream; AValue: Extended);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadSingleFunc(AStream: TStream): Single;
begin
  ReadSingleProc(AStream, Result);
end;

procedure ReadSingleProc(AStream: TStream; var Value: Single);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteSingleProc(AStream: TStream; AValue: Single);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadCurrencyFunc(AStream: TStream): Currency;
begin
  ReadCurrencyProc(AStream, Result);
end;

procedure ReadCurrencyProc(AStream: TStream; var Value: Currency);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteCurrencyProc(AStream: TStream; AValue: Currency);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadDateTimeFunc(AStream: TStream): TDateTime;
begin
  ReadDateTimeProc(AStream, Result);
end;

procedure ReadDateTimeProc(AStream: TStream; var Value: TDateTime);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteDateTimeProc(AStream: TStream; AValue: TDateTime);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadIntegerFunc(AStream: TStream): Integer;
begin
  ReadIntegerProc(AStream, Result);
end;

procedure ReadIntegerProc(AStream: TStream; var Value: Integer);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteIntegerProc(AStream: TStream; AValue: Integer);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadLargeIntFunc(AStream: TStream): LargeInt;
begin
  ReadLargeIntProc(AStream, Result);
end;

procedure ReadLargeIntProc(AStream: TStream; var Value: LargeInt);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteLargeIntProc(AStream: TStream; AValue: LargeInt);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadByteFunc(AStream: TStream): Byte;
begin
  ReadByteProc(AStream, Result);
end;

procedure ReadByteProc(AStream: TStream; var Value: Byte);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteByteProc(AStream: TStream; AValue: Byte);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadSmallIntFunc(AStream: TStream): SmallInt;
begin
  ReadSmallIntProc(AStream, Result);
end;

procedure ReadSmallIntProc(AStream: TStream; var Value: SmallInt);
begin
  AStream.ReadBuffer(Value, SizeOf(Value));
end;

procedure WriteSmallIntProc(AStream: TStream; AValue: SmallInt);
begin
  AStream.WriteBuffer(AValue, SizeOf(AValue));
end;

function ReadCardinalFunc(AStream: TStream): Cardinal;
begin
  ReadCardinalProc(AStream, Result);
end;

procedure ReadCardinalProc(AStream: TStream; var Value: Cardinal);
begin
  Value := ReadIntegerFunc(AStream);
end;

procedure WriteCardinalProc(AStream: TStream; AValue: Cardinal);
begin
  WriteIntegerProc(AStream, AValue);
end;

function ReadShortIntFunc(AStream: TStream): ShortInt;
begin
  ReadShortIntProc(AStream, Result);
end;

procedure ReadShortIntProc(AStream: TStream; var Value: ShortInt);
begin
  Value := ReadByteFunc(AStream);
end;

procedure WriteShortIntProc(AStream: TStream; AValue: ShortInt);
begin
  WriteByteProc(AStream, AValue);
end;

function ReadWordFunc(AStream: TStream): Word;
begin
  ReadWordProc(AStream, Result);
end;

procedure ReadWordProc(AStream: TStream; var Value: Word);
begin
  Value := ReadSmallIntFunc(AStream);
end;

procedure WriteWordProc(AStream: TStream; AValue: Word);
begin
  WriteSmallIntProc(AStream, AValue);
end;

{ TcxFiler }

constructor TcxFiler.Create(AStream: TStream);
begin
  inherited Create;
  FIsUnicode := dxIsUnicodeStream(AStream);
  FStream := AStream;
end;

{ TcxReader }

function TcxReader.ReadAnsiString: AnsiString;
begin
  ReadAnsiStringProc(Stream, Result);
end;

function TcxReader.ReadBoolean: Boolean;
begin
  ReadBooleanProc(Stream, Result);
end;

function TcxReader.ReadByte: Byte;
begin
  ReadByteProc(Stream, Result);
end;

function TcxReader.ReadCardinal: Cardinal;
begin
  ReadCardinalProc(Stream, Result);
end;

function TcxReader.ReadChar: Char;
begin
  ReadCharProc(Stream, Result);
end;

function TcxReader.ReadCurrency: Currency;
begin
  ReadCurrencyProc(Stream, Result);
end;

function TcxReader.ReadDateTime: TDateTime;
begin
  ReadDateTimeProc(Stream, Result);
end;

function TcxReader.ReadFloat: Extended;
begin
  ReadFloatProc(Stream, Result);
end;

function TcxReader.ReadInteger: Integer;
begin
  ReadIntegerProc(Stream, Result);
end;

function TcxReader.ReadLargeInt: LargeInt;
begin
  ReadLargeIntProc(Stream, Result);
end;

function TcxReader.ReadShortInt: ShortInt;
begin
  ReadShortIntProc(Stream, Result);
end;

function TcxReader.ReadSingle: Single;
begin
  ReadSingleProc(Stream, Result);
end;

function TcxReader.ReadSmallInt: SmallInt;
begin
  ReadSmallIntProc(Stream, Result);
end;

function TcxReader.ReadString_: string;
begin
  Result := dxReadStr(Stream, IsUnicode);
end;

function TcxReader.ReadVariant: Variant;
begin
  ReadVariantProc(Stream, Result);
end;

function TcxReader.ReadWideString: WideString;
begin
  ReadWideStringProc(Stream, Result);
end;

function TcxReader.ReadWord: Word;
begin
  ReadWordProc(Stream, Result);
end;

{ TcxWriter }

procedure TcxWriter.WriteAnsiString(const S: AnsiString);
begin
  WriteAnsiStringProc(Stream, S);
end;

procedure TcxWriter.WriteBoolean(AValue: Boolean);
begin
  WriteBooleanProc(Stream, AValue);
end;

procedure TcxWriter.WriteByte(AValue: Byte);
begin
  WriteByteProc(Stream, AValue);
end;

procedure TcxWriter.WriteCardinal(AValue: Cardinal);
begin
  WriteCardinalProc(Stream, AValue);
end;

procedure TcxWriter.WriteChar(AValue: Char);
begin
  WriteCharProc(Stream, AValue);
end;

procedure TcxWriter.WriteCurrency(AValue: Currency);
begin
  WriteCurrencyProc(Stream, AValue);
end;

procedure TcxWriter.WriteDateTime(AValue: TDateTime);
begin
  WriteDateTimeProc(Stream, AValue);
end;

procedure TcxWriter.WriteFloat(AValue: Extended);
begin
  WriteFloatProc(Stream, AValue);
end;

procedure TcxWriter.WriteInteger(AValue: Integer);
begin
  WriteIntegerProc(Stream, AValue);
end;

procedure TcxWriter.WriteLargeInt(AValue: LargeInt);
begin
  WriteLargeIntProc(Stream, AValue);
end;

procedure TcxWriter.WriteShortInt(AValue: ShortInt);
begin
  WriteShortIntProc(Stream, AValue);
end;

procedure TcxWriter.WriteSingle(AValue: Single);
begin
  WriteSingleProc(Stream, AValue);
end;

procedure TcxWriter.WriteSmallInt(AValue: SmallInt);
begin
  WriteSmallIntProc(Stream, AValue);
end;

procedure TcxWriter.WriteVariant(const AValue: Variant);
begin
  WriteVariantProc(Stream, AValue);
end;

procedure TcxWriter.WriteWideString(const S: WideString);
begin
  WriteWideStringProc(Stream, S);
end;

procedure TcxWriter.WriteWord(AValue: Word);
begin
  WriteWordProc(Stream, AValue);
end;

end.
