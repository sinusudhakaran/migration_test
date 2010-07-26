
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

unit cxFormats;

{$I cxVer.inc}

interface

uses
  Windows, Messages,
  Classes, cxDateUtils, cxClasses, dxCore;

type
  IcxFormatControllerListener = interface
    ['{A7F2F6D3-1A7D-4295-A6E6-9297BD83D0DE}']
    procedure FormatChanged;
  end;

  IcxFormatControllerListener2 = interface
  ['{5E33A2A7-0C77-415F-A359-112103E54937}']
    procedure TimeChanged;
  end;

  TcxDateTimeEditMaskKind = (dtmkDate, dtmkTime, dtmkDateTime);

  TcxDateTimeFormatItemKind = (
    dtikString,
    dtikYear,          // YY YYYY
    dtikMonth,         // M MM MMM MMMM
    dtikDay,           // D DD DDD DDDD
    dtikHour,          // 12H 12HH 24H 24HH
    dtikMin,           // N NN
    dtikSec,           // S SS
    dtikMSec,          // Z ZZ ZZZ
    dtikTimeSuffix,    // A/P AM/PM AMPM (lower, upper, or mixed case)
    dtikDateSeparator,
    dtikTimeSeparator
  );

  TcxTimeSuffixKind = (tskAP, tskAMPM, tskAMPMString);

  TcxDateTimeFormatItem = record
    Kind: TcxDateTimeFormatItemKind;
    Data: string;
  end;

  TcxDateTimeFormatInfo = record
    DefinedItems: array[TcxDateTimeFormatItemKind] of Boolean;
    Items: array of TcxDateTimeFormatItem;
  end;

  TcxDateTimeFormatItemInfo = record
    Kind: TcxDateTimeFormatItemKind;
    ItemZoneStart, ItemZoneLength: Integer;
    TimeSuffixKind: TcxTimeSuffixKind;
  end;

  { TcxFormatController }

  TcxFormatController = class(TcxIUnknownObject, IdxLocalizerListener)
  private
    FAssignedCurrencyFormat: Boolean;
    FAssignedRegExprDateEditMask: Boolean;
    FAssignedRegExprDateTimeEditMask: Boolean;
    FAssignedStandardDateEditMask: Boolean;
    FAssignedStandardDateTimeEditMask: Boolean;
    FAssignedStartOfWeek: Boolean;
    FCurrencyFormat: string;
    FDateEditFormat: string;
    FDateEditMask: string;
    FDateFormatInfo: TcxDateTimeFormatInfo;
    FDateTimeFormatInfo: TcxDateTimeFormatInfo;
    FFirstWeekOfYear: TcxFirstWeekOfYear;
    FList: TList;
    FLockCount: Integer;
    FMaskedDateEditFormat: string;
    FMaskedDateTimeEditFormat: string;
    FRegExprDateEditMask: string;
    FRegExprDateTimeEditMask: string;
    FStandardDateEditMask: string;
    FStandardDateTimeEditMask: string;
    FStartOfWeek: TDayOfWeek;
    FTimeFormatInfo: TcxDateTimeFormatInfo;
    FUseDelphiDateTimeFormats: Boolean;
    procedure CalculateDateEditMasks(AUseSmartInputWhenRegExpr: Boolean);
    function GetCurrencyFormat: string;
    function GetDateEditFormat(AIsMasked: Boolean): string;
    function GetDateTimeDisplayFormat(AMaskKind: TcxDateTimeEditMaskKind): string;
    class function GetDateTimeFormatItemStandardMaskZoneLength(
      const AItem: TcxDateTimeFormatItem): Integer;
    function GetStartOfWeek: TDayOfWeek;
    function InternalGetDateTimeEditRegExprMask(
      AFormatInfo: TcxDateTimeFormatInfo;
      AMaskKind: TcxDateTimeEditMaskKind): string;
    function InternalGetDateTimeEditStandardMask(
      AFormatInfo: TcxDateTimeFormatInfo;
      AMaskKind: TcxDateTimeEditMaskKind): string;
    function InternalGetMaskedDateEditFormat(
      AFormatInfo: TcxDateTimeFormatInfo): string;
    procedure SetAssignedCurrencyFormat(Value: Boolean);
    procedure SetAssignedRegExprDateEditMask(Value: Boolean);
    procedure SetAssignedRegExprDateTimeEditMask(Value: Boolean);
    procedure SetAssignedStandardDateEditMask(Value: Boolean);
    procedure SetAssignedStandardDateTimeEditMask(Value: Boolean);
    procedure SetAssignedStartOfWeek(Value: Boolean);
    procedure SetCurrencyFormat(const Value: string);
    procedure SetFirstWeekOfYear(Value: TcxFirstWeekOfYear);
    procedure SetRegExprDateEditMask(const Value: string);
    procedure SetRegExprDateTimeEditMask(const Value: string);
    procedure SetStandardDateEditMask(const Value: string);
    procedure SetStandardDateTimeEditMask(const Value: string);
    procedure SetStartOfWeek(Value: TDayOfWeek);
    procedure SetUseDelphiDateTimeFormats(Value: Boolean);
  protected
    FWindow: HWND;
    procedure MainWndProc(var Message: TMessage);
    procedure WndProc(var Message: TMessage); virtual;
    procedure FormatChanged;
    procedure TimeChanged;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddListener(AListener: IcxFormatControllerListener); virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure GetFormats;
    class function GetDateTimeFormatItemStandardMaskInfo(
      const AFormatInfo: TcxDateTimeFormatInfo; APos: Integer;
      out AItemInfo: TcxDateTimeFormatItemInfo): Boolean;
    function GetDateTimeStandardMaskStringLength(
      const AFormatInfo: TcxDateTimeFormatInfo): Integer;
    procedure NotifyListeners;
    procedure RemoveListener(AListener: IcxFormatControllerListener); virtual;

    //  IdxLocalizerListener
    procedure TranslationChanged;

    property AssignedCurrencyFormat: Boolean read FAssignedCurrencyFormat write SetAssignedCurrencyFormat;
    property AssignedRegExprDateEditMask: Boolean read FAssignedRegExprDateEditMask write SetAssignedRegExprDateEditMask;
    property AssignedRegExprDateTimeEditMask: Boolean read FAssignedRegExprDateTimeEditMask write SetAssignedRegExprDateTimeEditMask;
    property AssignedStandardDateEditMask: Boolean read FAssignedStandardDateEditMask write SetAssignedStandardDateEditMask;
    property AssignedStandardDateTimeEditMask: Boolean read FAssignedStandardDateTimeEditMask write SetAssignedStandardDateTimeEditMask;
    property AssignedStartOfWeek: Boolean read FAssignedStartOfWeek write SetAssignedStartOfWeek;
    property CurrencyFormat: string read FCurrencyFormat write SetCurrencyFormat;
    property DateEditFormat: string read FDateEditFormat;
    property DateEditMask: string read FDateEditMask;
    property DateFormatInfo: TcxDateTimeFormatInfo read FDateFormatInfo;
    property DateTimeFormatInfo: TcxDateTimeFormatInfo read FDateTimeFormatInfo;
    property FirstWeekOfYear: TcxFirstWeekOfYear read FFirstWeekOfYear write SetFirstWeekOfYear; 
    property MaskedDateEditFormat: string read FMaskedDateEditFormat;
    property MaskedDateTimeEditFormat: string read FMaskedDateTimeEditFormat;
    property RegExprDateEditMask: string read FRegExprDateEditMask write SetRegExprDateEditMask;
    property RegExprDateTimeEditMask: string read FRegExprDateTimeEditMask write SetRegExprDateTimeEditMask;
    property StandardDateEditMask: string read FStandardDateEditMask write SetStandardDateEditMask;
    property StandardDateTimeEditMask: string read FStandardDateTimeEditMask write SetStandardDateTimeEditMask;
    property StartOfWeek: TDayOfWeek read FStartOfWeek write SetStartOfWeek;
    property TimeFormatInfo: TcxDateTimeFormatInfo read FTimeFormatInfo;
    property UseDelphiDateTimeFormats: Boolean read FUseDelphiDateTimeFormats write SetUseDelphiDateTimeFormats;
  end;

function cxFormatController: TcxFormatController;
function GetCharString(C: Char; ACount: Integer): string;

implementation

uses
  SysUtils, Forms;

var
  FcxFormatController: TcxFormatController;

function GetCharString(C: Char; ACount: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ACount do
    Result := Result + C;
end;

function CharLength(const S: string; Index: Integer): Integer;
begin
  Result := 1;
  assert((Index > 0) and (Index <= Length(S)));
  if SysLocale.FarEast and dxCharInSet(S[Index], LeadBytes) then
    Result := cxStrCharLength(S, Index);
end;

procedure GetDateTimeFormatInfo(const AFormat: string;
  var AFormatInfo: TcxDateTimeFormatInfo);
var
  A12HourFormat: Boolean;

  procedure AddFormatItem(AItemKind: TcxDateTimeFormatItemKind;
    const AItemData: string);
  begin
    if not(AItemKind in [dtikString, dtikDateSeparator, dtikTimeSeparator]) and
      AFormatInfo.DefinedItems[AItemKind] then
        Exit;
    AFormatInfo.DefinedItems[AItemKind] := True;
    SetLength(AFormatInfo.Items, Length(AFormatInfo.Items) + 1);
    with AFormatInfo.Items[Length(AFormatInfo.Items) - 1] do
    begin
      Kind := AItemKind;
      Data := AItemData;
    end;
  end;

  procedure AppendChars(const S: string; AStartIndex, ACount: Integer);
  begin
    if (Length(AFormatInfo.Items) = 0) or
      (AFormatInfo.Items[Length(AFormatInfo.Items) - 1].Kind <> dtikString) then
        AddFormatItem(dtikString, '');
    with AFormatInfo.Items[Length(AFormatInfo.Items) - 1] do
      Data := Data + Copy(S, AStartIndex, ACount);
  end;

  function GetCount(const AFormat: string; var AStartIndex: Integer;
    AStartSymbol: Char): Integer;
  begin
    Result := 1;
    while (AStartIndex <= Length(AFormat)) and (AFormat[AStartIndex] = AStartSymbol) do
    begin
      Inc(AStartIndex);
      Inc(Result);
    end;
  end;

  function ParseFormat(const AFormat: string; ARecursionDepth: Integer): Boolean;
  var
    ACount, APrevI, I: Integer;
    AFormatItemData: string;
    ALastToken, AStartSymbol, AToken: Char;
    AThereIsHourItem, AThereIsTimeSuffixItem: Boolean;
  begin
    Result := True;
    if (AFormat = '') or (ARecursionDepth = 2) then
      Exit;
    Inc(ARecursionDepth);
    ALastToken := ' ';
    AThereIsHourItem := False;
    AThereIsTimeSuffixItem := False;
    I := 1;
    while I <= Length(AFormat) do
    begin
      AStartSymbol := AFormat[I];
      if dxCharInSet(AStartSymbol, LeadBytes) then
      begin
        AppendChars(AFormat, I, CharLength(AFormat, I));
        Inc(I, CharLength(AFormat, I));
        ALastToken := ' ';
        Continue;
      end;
      Inc(I, CharLength(AFormat, I));
      AToken := AStartSymbol;
      if dxCharInSet(AToken, ['a'..'z']) then
        Dec(AToken, 32);
      if dxCharInSet(AToken, ['A'..'Z']) then
      begin
        if (AToken = 'M') and (ALastToken = 'H') then
          AToken := 'N';
        ALastToken := AToken;
      end;
      case AToken of
        'E', 'Y':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount <= 2 then
              AFormatItemData := 'YY'
            else
              AFormatItemData := 'YYYY';
            AddFormatItem(dtikYear, AFormatItemData);
          end;
        'G':
          begin
            Result := False;
            Break;
          end;
        'M':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount > 4 then
              ACount := 4;
            AddFormatItem(dtikMonth, GetCharString('M', ACount));
          end;
        'D':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            case ACount of
              1..4:
                AddFormatItem(dtikDay, GetCharString('D', ACount));
              5:
                Result := ParseFormat(ShortDateFormat, ARecursionDepth);
              else
                Result := ParseFormat(LongDateFormat, ARecursionDepth);
            end;
            if not Result then
              Break;
          end;
        'H':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount > 2 then
              ACount := 2;
            AddFormatItem(dtikHour, GetCharString('H', ACount));
            AThereIsHourItem := True;
          end;
        'N':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount > 2 then
              ACount := 2;
            AddFormatItem(dtikMin, GetCharString('N', ACount));
          end;
        'S':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount > 2 then
              ACount := 2;
            AddFormatItem(dtikSec, GetCharString('S', ACount));
          end;
        'T':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount = 1 then
              Result := ParseFormat(ShortTimeFormat, ARecursionDepth)
            else
              Result := ParseFormat(LongTimeFormat, ARecursionDepth);
            if not Result then
              Break;
          end;
        'Z':
          begin
            ACount := GetCount(AFormat, I, AStartSymbol);
            if ACount > 3 then
              ACount := 3;
            AddFormatItem(dtikMSec, GetCharString('Z', ACount));
          end;
        'A':
          begin
            if SameText(Copy(AFormat, I - 1, 5), 'AM/PM') then
            begin
              AddFormatItem(dtikTimeSuffix, Copy(AFormat, I - 1, 5));
              Inc(I, 4);
              AThereIsTimeSuffixItem := True;
            end
            else if SameText(Copy(AFormat, I - 1, 3), 'A/P') then
            begin
              AddFormatItem(dtikTimeSuffix, Copy(AFormat, I - 1, 3));
              Inc(I, 2);
              AThereIsTimeSuffixItem := True;
            end
            else if SameText(Copy(AFormat, I - 1, 4), 'AMPM') then
            begin
              AddFormatItem(dtikTimeSuffix, 'AMPM');
              Inc(I, 3);
              AThereIsTimeSuffixItem := True;
            end
            else if SameText(Copy(AFormat, I - 1, 3), 'AAA') then
            begin
              if SameText(Copy(AFormat, I - 1, 4), 'AAAA') then
                ACount := 4
              else
                ACount := 3;
              AddFormatItem(dtikDay, GetCharString('D', ACount));
              Inc(I, ACount - 1);
            end
            else
              AppendChars(AStartSymbol, 1, 1);
          end;
        'C':
          begin
            GetCount(AFormat, I, AStartSymbol);
            Result := ParseFormat(ShortDateFormat, ARecursionDepth);
            if not Result then
              Break;
            AppendChars(' ', 1, 1);
            Result := ParseFormat(LongTimeFormat, ARecursionDepth);
            if not Result then
              Break;
          end;
        '/':
          AddFormatItem(dtikDateSeparator, '');
        ':':
          AddFormatItem(dtikTimeSeparator, '');
        '''', '"':
          begin
            APrevI := I;
            while (I <= Length(AFormat)) and (AFormat[I] <> AStartSymbol) do
              if dxCharInSet(AFormat[I], LeadBytes) then
                Inc(I, CharLength(AFormat, I))
              else
                Inc(I);
            AppendChars(AFormat, APrevI, I - APrevI);
            if I <= Length(AFormat) then
              Inc(I);
          end;
      else
        AppendChars(AStartSymbol, 1, 1);
      end;
    end;
    if AThereIsHourItem then
      A12HourFormat := AThereIsTimeSuffixItem;
  end;

  procedure ClearFormatInfo;
  var
    AFormatItemKind: TcxDateTimeFormatItemKind;
  begin
    SetLength(AFormatInfo.Items, 0);
    for AFormatItemKind := Low(TcxDateTimeFormatItemKind) to High(TcxDateTimeFormatItemKind) do
      AFormatInfo.DefinedItems[AFormatItemKind] := False;
  end;

  procedure ProcessHourItem;
  var
    I: Integer;
  begin
    if AFormatInfo.DefinedItems[dtikHour] then
    begin
      for I := 0 to Length(AFormatInfo.Items) - 1 do
        if AFormatInfo.Items[I].Kind = dtikHour then
          with AFormatInfo.Items[I] do
          begin
            if A12HourFormat then
              Data := '12' + Data
            else
              Data := '24' + Data;
            Break;
          end;
    end
    else
      if AFormatInfo.DefinedItems[dtikTimeSuffix] then
        for I := 0 to Length(AFormatInfo.Items) - 1 do
          if AFormatInfo.Items[I].Kind = dtikTimeSuffix then
          begin
            AFormatInfo.DefinedItems[dtikTimeSuffix] := False;
            if I < Length(AFormatInfo.Items) - 1 then
              Move(AFormatInfo.Items[I + 1], AFormatInfo.Items[I],
                SizeOf(TcxDateTimeFormatItem) * Length(AFormatInfo.Items) - 1 - I);
            Break;
          end;
  end;

var
  ARes: Boolean;
begin
  ClearFormatInfo;
  if AFormat <> '' then
    ARes := ParseFormat(AFormat, 0)
  else
    ARes := ParseFormat('C', 0);
  if not ARes then
    ClearFormatInfo
  else
    ProcessHourItem;
end;

{ TcxFormatController }

constructor TcxFormatController.Create;
begin
  inherited Create;
  FList := TList.Create;
  FFirstWeekOfYear := fwySystem;
  FUseDelphiDateTimeFormats := False;
  GetFormats;
  dxResourceStringsRepository.AddListener(Self);
end;

destructor TcxFormatController.Destroy;
begin
  dxResourceStringsRepository.RemoveListener(Self);
  FList.Free;
  if FWindow <> 0 then
  {$IFDEF DELPHI6}
    Classes.DeallocateHWnd(FWindow);
  {$ELSE}
    Forms.DeallocateHWnd(FWindow);
  {$ENDIF}
  inherited Destroy;
end;

procedure TcxFormatController.CalculateDateEditMasks(
  AUseSmartInputWhenRegExpr: Boolean);
begin
  GetDateTimeFormatInfo(GetDateTimeDisplayFormat(dtmkDate), FDateFormatInfo);
  GetDateTimeFormatInfo(GetDateTimeDisplayFormat(dtmkTime), FTimeFormatInfo);
  GetDateTimeFormatInfo(GetDateTimeDisplayFormat(dtmkDateTime),
    FDateTimeFormatInfo);

  FDateEditMask := InternalGetDateTimeEditStandardMask(FDateFormatInfo,
    dtmkDate);
  if not FAssignedStandardDateEditMask then
    FStandardDateEditMask := FDateEditMask;

  if not FAssignedRegExprDateEditMask then
  begin
    FRegExprDateEditMask := InternalGetDateTimeEditRegExprMask(FDateFormatInfo, dtmkDate);
    if AUseSmartInputWhenRegExpr then
      AddDateRegExprMaskSmartInput(FRegExprDateEditMask, False);
  end;

  if not FAssignedRegExprDateTimeEditMask then
  begin
    FRegExprDateTimeEditMask := InternalGetDateTimeEditRegExprMask(
      FDateFormatInfo, dtmkDate);
    FRegExprDateTimeEditMask := FRegExprDateTimeEditMask + ' '' ''(' +
      InternalGetDateTimeEditRegExprMask(FTimeFormatInfo, dtmkTime) + ')?';
    if AUseSmartInputWhenRegExpr then
      AddDateRegExprMaskSmartInput(FRegExprDateTimeEditMask, True);
  end;

  if not FAssignedStandardDateTimeEditMask then
    FStandardDateTimeEditMask := InternalGetDateTimeEditStandardMask(
      FDateTimeFormatInfo, dtmkDateTime);

  FMaskedDateEditFormat := InternalGetMaskedDateEditFormat(FDateFormatInfo);
  FMaskedDateTimeEditFormat := InternalGetMaskedDateEditFormat(FDateTimeFormatInfo);
end;

function TcxFormatController.GetCurrencyFormat: string;

  function GetPositiveCurrencyFormat(const AFormat, ACurrStr: string): string;
  begin
    case Sysutils.CurrencyFormat of
      0: Result := ACurrStr + AFormat; { '$1' }
      1: Result := AFormat + ACurrStr; { '1$' }
      2: Result := ACurrStr + ' ' + AFormat; { '$ 1' }
      3: Result := AFormat + ' ' + ACurrStr; { '1 $' }
    end;
  end;

  function GetNegativeCurrencyFormat(const AFormat, ACurrStr: string): string;
  begin
    case Sysutils.NegCurrFormat of
      0: Result := '(' + ACurrStr + AFormat + ')';
      1: Result := '-' + ACurrStr + AFormat;
      2: Result := ACurrStr + '-' + AFormat;
      3: Result := ACurrStr + AFormat + '-';
      4: Result := '(' + AFormat + ACurrStr + ')';
      5: Result := '-' + AFormat + ACurrStr;
      6: Result := AFormat + '-' + ACurrStr;
      7: Result := AFormat + ACurrStr + '-';
      8: Result := '-' + AFormat + ' ' + ACurrStr;
      9: Result := '-' + ACurrStr + ' ' + AFormat;
      10: Result := AFormat + ' ' + ACurrStr + '-';
      11: Result := ACurrStr + ' ' + AFormat + '-';
      12: Result := ACurrStr + ' ' + '-' + AFormat;
      13: Result := AFormat + '-' + ' ' + ACurrStr;
      14: Result := '(' + ACurrStr + ' ' + AFormat + ')';
      15: Result := '(' + AFormat + ' ' + ACurrStr + ')';
    end;
  end;

var
  ACurrStr: string;
  I: Integer;
  C: Char;
begin
  if CurrencyDecimals > 0 then
    Result := GetCharString('0', CurrencyDecimals)
  else
    Result := '';
  Result := ',0.' + Result;
  ACurrStr := '';
  for I := 1 to Length(CurrencyString) do
  begin
    C := CurrencyString[I];
    if (C = ',') or (C = '.') then
      ACurrStr := ACurrStr + '''' + C + ''''
    else
      ACurrStr := ACurrStr + C;
  end;
  Result := GetPositiveCurrencyFormat(Result, ACurrStr) + ';' +
    GetNegativeCurrencyFormat(Result, ACurrStr);
end;

function TcxFormatController.GetDateEditFormat(AIsMasked: Boolean): string;

  procedure CorrectForMaskEdit(var S: string);
  var
    APos, AStartPos: Integer;
  begin
    APos := Pos('M', S);
    if APos <> 0 then
    begin
      AStartPos := APos;
      while APos <= Length(S) do
        if S[APos] = 'M' then
          Inc(APos)
        else
          Break;
      if APos - AStartPos > 3 then
        Delete(S, AStartPos + 3, APos - AStartPos - 3);
    end;
  end;

var
  Format: string;
  I: Integer;
  ExistFirst: Boolean;
begin
  Format := ShortDateFormat;
  Result := '';
  for I := 1 to Length(Format) do
  begin
    if (Format[I] = 'd') then
    begin
      ExistFirst := True;
      if (1 < I) and (Format[I - 1] = 'd') then ExistFirst := False;
      if (I < Length(Format)) and (Format[I + 1] = 'd') then ExistFirst := False;
      if ExistFirst then Result := Result + 'd';
    end;
    if (Format[I] = 'M') then
    begin
      ExistFirst := True;
      if (1 < I) and (Format[I - 1] = 'M') then ExistFirst := False;
      if (I < Length(Format)) and (Format[I + 1] = 'M') then ExistFirst := False;
      if ExistFirst then Result := Result + 'M';
    end;
    Result := Result + Format[I];
  end;
  if AIsMasked then CorrectForMaskEdit(Result);
end;

function TcxFormatController.GetDateTimeDisplayFormat(
  AMaskKind: TcxDateTimeEditMaskKind): string;
begin
  case AMaskKind of
    dtmkDate:
      Result := ShortDateFormat;
    dtmkTime:
      Result := LongTimeFormat;
    dtmkDateTime:
      Result := ShortDateFormat + ' ' + LongTimeFormat;
  end;
end;

class function TcxFormatController.GetDateTimeFormatItemStandardMaskZoneLength(
  const AItem: TcxDateTimeFormatItem): Integer;
begin
  case AItem.Kind of
    dtikString:
      Result := Length(AItem.Data);
    dtikYear:
      if Length(AItem.Data) = 2 then
        Result := 2
      else
        Result := 4;
    dtikMonth, dtikDay:
      if Length(AItem.Data) < 3 then
        Result := 2
      else
        Result := 3;
    dtikHour, dtikMin, dtikSec:
      Result := 2;
//        dtikMSec:
    dtikTimeSuffix:
      begin
        if UpperCase(AItem.Data) = 'A/P' then
          Result := 1
        else if UpperCase(AItem.Data) = 'AM/PM' then
          Result := 2
        else
        begin
          Result := Length(TimeAMString);
          if Length(TimePMString) > Result then
            Result := Length(TimePMString);
        end;
      end;
    dtikDateSeparator, dtikTimeSeparator:
      Result := 1;
    else
      Result := 0;
  end;
end;

function TcxFormatController.GetStartOfWeek: TDayOfWeek;
begin
  Result := cxDateUtils.GetStartOfWeek;
end;

function TcxFormatController.InternalGetDateTimeEditRegExprMask(
  AFormatInfo: TcxDateTimeFormatInfo;
  AMaskKind: TcxDateTimeEditMaskKind): string;

  procedure AddChar(var S: string; C: Char);
  begin
    if C = ' ' then
      S := S + ''' '''
    else
      S := S + '\' + C;
  end;

  procedure AddString(var ADst: string; const ASrc: string);
  begin
    ADst := ADst + '''' + ASrc + '''';
  end;

  procedure ProcessDateItem(var S: string;
    const AFormatItem: TcxDateTimeFormatItem);
  const
    reTwoDigitYearMask = '\d\d';
    reFourDigitYearMask = '\d\d\d\d';
    reMonthMask = '(0?[1-9]|1[012])';
    reDayMask = '([012]?[1-9]|[123]0|31)';
  var
    AUseLongMonthNames: Boolean;
    I: Integer;
  begin
    with AFormatItem do
      case Kind of
        dtikString:
          AddString(S, Data);
        dtikYear:
          if Length(Data) = 2 then
            Result := S + reTwoDigitYearMask
          else
            Result := S + reFourDigitYearMask;
        dtikMonth:
          begin
            S := S + '(' + reMonthMask + '|(';
            AUseLongMonthNames := Length(Data) = 4;
            if AUseLongMonthNames then
              AddString(S, LongMonthNames[1])
            else
              AddString(S, ShortMonthNames[1]);
            for I := 2 to 12 do
            begin
              S := S + '|';
              if AUseLongMonthNames then
                AddString(S, LongMonthNames[I])
              else
                AddString(S, ShortMonthNames[I]);
            end;
            S := S + '))';
          end;
        dtikDay:
          S := S + reDayMask;
        dtikDateSeparator:
          if DateSeparator <> #0 then
            AddChar(S, DateSeparator);
      end;
  end;

  procedure ProcessTimeItem(var S: string;
    const AFormatItem: TcxDateTimeFormatItem);
  begin
    with AFormatItem do
      case Kind of
        dtikString:
          AddString(S, Data);
        dtikHour:
          begin
            if Copy(Data, 1, 2) = '12' then
              S := S + '(0?[1-9]|1[012])'
            else
              S := S + '([01]?\d|2[0-3])';
          end;
        dtikMin:
          S := S + '[0-5]?\d';
        dtikSec:
          S := S + '[0-5]?\d';
//        dtikMSec:
        dtikTimeSuffix:
          begin
            if UpperCase(Data) = 'A/P' then
              S := S + '(A|P)?'
            else if UpperCase(Data) = 'AM/PM' then
              S := S + '(AM|PM)?'
            else
              if (TimeAMString <> '') or (TimePMString <> '') then
              begin
                S := S + '(''';
                if (TimeAMString <> '') and (TimePMString <> '') then
                  S := S + TimeAMString + '''|''' + TimePMString
                else
                  if TimeAMString <> '' then
                    S := S + TimeAMString
                  else
                    S := S + TimePMString;
                S := S + ''')?';
              end;
          end;
        dtikTimeSeparator:
          if TimeSeparator <> #0 then
            AddChar(S, TimeSeparator);
      end;
  end;

var
  I: Integer;
begin
  Result := '';
  if (AMaskKind = dtmkDateTime) or (Length(AFormatInfo.Items) = 0) then
    Exit;
  for I := 0 to Length(AFormatInfo.Items) - 1 do
    if AMaskKind = dtmkDate then
      ProcessDateItem(Result, AFormatInfo.Items[I])
    else
      ProcessTimeItem(Result, AFormatInfo.Items[I]);
end;

function TcxFormatController.InternalGetDateTimeEditStandardMask(
  AFormatInfo: TcxDateTimeFormatInfo;
  AMaskKind: TcxDateTimeEditMaskKind): string;

  procedure AddChar(var S: string; C: Char);
  begin
    S := S + '\' + C;
  end;

var
  I, J: Integer;
begin
  Result := '';
  if Length(AFormatInfo.Items) = 0 then
    Exit;
  if AMaskKind <> dtmkTime then
    Result := '!';
  for I := 0 to Length(AFormatInfo.Items) - 1 do
    with AFormatInfo.Items[I] do
      case Kind of
        dtikString:
          for J := 1 to Length(Data) do
            AddChar(Result, Data[J]);
        dtikYear:
          if Length(Data) = 2 then
            Result := Result + '99'
          else
            Result := Result + '9999';
        dtikMonth:
          if Length(Data) < 3 then
            Result := Result + '99'
          else
            Result := Result + 'lll';
        dtikDay:
          if Length(Data) < 3 then
            Result := Result + '99'
          else
            Result := Result + 'lll';
        dtikHour, dtikMin, dtikSec:
          if AMaskKind = dtmkTime then
            Result := Result + '00'
          else
            Result := Result + '99';
//        dtikMSec:
        dtikTimeSuffix:
          begin
            if UpperCase(Data) = 'A/P' then
              Result := Result + 'c'
            else if UpperCase(Data) = 'AM/PM' then
              Result := Result + 'cc'
            else
            begin
              J := Length(TimeAMString);
              if Length(TimePMString) > J then
                J := Length(TimePMString);
              Result := Result + GetCharString('c', J);
            end;
          end;
        dtikDateSeparator:
          Result := Result + '/';
        dtikTimeSeparator:
          Result := Result + ':';
      end;
  if AMaskKind = dtmkTime then
    Result := Result + ';1;0'
  else
    Result := Result + ';1; ';
end;

function TcxFormatController.InternalGetMaskedDateEditFormat(
  AFormatInfo: TcxDateTimeFormatInfo): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Length(AFormatInfo.Items) - 1 do
    with AFormatInfo.Items[I] do
      case Kind of
        dtikString:
          Result := Result + '''' + Data + '''';
        dtikYear:
          Result := Result + LowerCase(Data);
        dtikMonth:
          if Length(Data) < 3 then
            Result := Result + 'mm'
          else
            Result := Result + 'mmm';
        dtikDay:
          if Length(Data) < 3 then
            Result := Result + 'dd'
          else
            Result := Result + 'ddd';
        dtikHour:
          Result := Result + 'hh';
        dtikMin:
          Result := Result + 'nn';
        dtikSec:
          Result := Result + 'ss';
//        dtikMSec:
        dtikTimeSuffix:
          Result := Result + LowerCase(Data);
        dtikDateSeparator:
          Result := Result + '/';
        dtikTimeSeparator:
          Result := Result + ':';
      end;
end;

procedure TcxFormatController.AddListener(
  AListener: IcxFormatControllerListener);
begin
  with FList do
    if IndexOf(Pointer(AListener)) = -1 then
    begin
      if Count = 0 then
      {$IFDEF DELPHI6}
        FWindow := Classes.AllocateHWnd(MainWndProc);
      {$ELSE}
        FWindow := Forms.AllocateHWnd(MainWndProc);
      {$ENDIF}
      Add(Pointer(AListener));
    end;
end;

procedure TcxFormatController.RemoveListener(
  AListener: IcxFormatControllerListener);
begin
  FList.Remove(Pointer(AListener));
  if FList.Count = 0 then
  begin
  {$IFDEF DELPHI6}
    Classes.DeallocateHWnd(FWindow);
  {$ELSE}
    Forms.DeallocateHWnd(FWindow);
  {$ENDIF}
    FWindow := 0;
  end;
end;

procedure TcxFormatController.TranslationChanged;
begin
  FormatChanged;
end;

procedure TcxFormatController.GetFormats;
begin
  if FcxFormatController = nil then // to avoid stack overflow
    FcxFormatController := Self;
  if not FAssignedCurrencyFormat then
    FCurrencyFormat := GetCurrencyFormat;
  if not FAssignedStartOfWeek then
    FStartOfWeek := GetStartOfWeek;

  CalculateDateEditMasks(True);
  FDateEditFormat := GetDateEditFormat(False);
end;

class function TcxFormatController.GetDateTimeFormatItemStandardMaskInfo(
  const AFormatInfo: TcxDateTimeFormatInfo; APos: Integer;
  out AItemInfo: TcxDateTimeFormatItemInfo): Boolean;

  function GetTimeSuffixKind(const AFormatItemData: string): TcxTimeSuffixKind;
  begin
    if UpperCase(AFormatItemData) = 'A/P' then
      Result := tskAP
    else if UpperCase(AFormatItemData) = 'AM/PM' then
      Result := tskAMPM
    else
      Result := tskAMPMString;
  end;

var
  AItemZoneStart, I: Integer;
  AItemZoneStarts: array of Integer;
begin
  Result := False;
  if (APos < 1) or (Length(AFormatInfo.Items) = 0) then
    Exit;
  SetLength(AItemZoneStarts, Length(AFormatInfo.Items));
  AItemZoneStart := 1;
  for I := 0 to Length(AFormatInfo.Items) - 1 do
  begin
    AItemZoneStarts[I] := AItemZoneStart;
    Inc(AItemZoneStart, GetDateTimeFormatItemStandardMaskZoneLength(AFormatInfo.Items[I]));
    if APos < AItemZoneStart then
    begin
      AItemInfo.Kind := AFormatInfo.Items[I].Kind;
      AItemInfo.ItemZoneStart := AItemZoneStarts[I];
      AItemInfo.ItemZoneLength := AItemZoneStart - AItemZoneStarts[I];
      if AItemInfo.Kind = dtikTimeSuffix then
        AItemInfo.TimeSuffixKind := GetTimeSuffixKind(AFormatInfo.Items[I].Data);
      Result := True;
      Break;
    end;
  end;
end;

function TcxFormatController.GetDateTimeStandardMaskStringLength(
  const AFormatInfo: TcxDateTimeFormatInfo): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Length(AFormatInfo.Items) - 1 do
    Inc(Result, GetDateTimeFormatItemStandardMaskZoneLength(AFormatInfo.Items[I]));
end;

procedure TcxFormatController.NotifyListeners;
var
  I: Integer;
begin
  for I := 0 to FList.Count - 1 do
    IcxFormatControllerListener(FList[I]).FormatChanged;
end;

procedure TcxFormatController.MainWndProc(var Message: TMessage);
begin
  try
    WndProc(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TcxFormatController.WndProc(var Message: TMessage);
begin
  if (Message.Msg = WM_SETTINGCHANGE) and ((Message.WParam = 0) and
    (PChar(Message.LParam) = 'intl')) and
    Application.UpdateFormatSettings then
  begin
    SysUtils.GetFormatSettings;
    GetFormats;
    NotifyListeners;
    Message.Result := 0;
    Exit;
  end;
  if Message.Msg = WM_TIMECHANGE then
  begin
    TimeChanged;
    Message.Result := 0;
    Exit;
  end;
  with Message do Result := DefWindowProc(FWindow, Msg, wParam, lParam);
end;

procedure TcxFormatController.BeginUpdate;
begin
  Inc(FLockCount);
end;

procedure TcxFormatController.EndUpdate;
begin
  Dec(FLockCount);
  if FLockCount = 0 then
    NotifyListeners;
end;

procedure TcxFormatController.FormatChanged;
begin
  if FLockCount = 0 then
  begin
    GetFormats;
    NotifyListeners;
  end;
end;

procedure TcxFormatController.TimeChanged;
var
  I: Integer;
  AIntf: IcxFormatControllerListener2;
begin
  for I := 0 to FList.Count - 1 do
    if Supports(IcxFormatControllerListener(FList[I]),
      IcxFormatControllerListener2, AIntf) then
        AIntf.TimeChanged;
end;

function cxFormatController: TcxFormatController;
begin
  if FcxFormatController = nil then
    FcxFormatController := TcxFormatController.Create;
  Result := FcxFormatController;
end;

procedure TcxFormatController.SetAssignedCurrencyFormat(Value: Boolean);
begin
  if FAssignedCurrencyFormat <> Value then
  begin
    FAssignedCurrencyFormat := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetAssignedRegExprDateEditMask(Value: Boolean);
begin
  if FAssignedRegExprDateEditMask <> Value then
  begin
    FAssignedRegExprDateEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetAssignedRegExprDateTimeEditMask(Value: Boolean);
begin
  if FAssignedRegExprDateTimeEditMask <> Value then
  begin
    FAssignedRegExprDateTimeEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetAssignedStandardDateEditMask(Value: Boolean);
begin
  if FAssignedStandardDateEditMask <> Value then
  begin
    FAssignedStandardDateEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetAssignedStandardDateTimeEditMask(Value: Boolean);
begin
  if FAssignedStandardDateTimeEditMask <> Value then
  begin
    FAssignedStandardDateTimeEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetAssignedStartOfWeek(Value: Boolean);
begin
  if FAssignedStartOfWeek <> Value then
  begin
    FAssignedStartOfWeek := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetCurrencyFormat(const Value: string);
begin
  FAssignedCurrencyFormat := True;
  if FCurrencyFormat <> Value then
  begin
    FCurrencyFormat := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetFirstWeekOfYear(Value: TcxFirstWeekOfYear);
begin
  if Value <> FFirstWeekOfYear then
  begin
    FFirstWeekOfYear := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetRegExprDateEditMask(const Value: string);
begin
  FAssignedRegExprDateEditMask := True;
  if FRegExprDateEditMask <> Value then
  begin
    FRegExprDateEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetRegExprDateTimeEditMask(const Value: string);
begin
  FAssignedRegExprDateTimeEditMask := True;
  if FRegExprDateTimeEditMask <> Value then
  begin
    FRegExprDateTimeEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetStandardDateEditMask(const Value: string);
begin
  FAssignedStandardDateEditMask := True;
  if FStandardDateEditMask <> Value then
  begin
    FStandardDateEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetStandardDateTimeEditMask(const Value: string);
begin
  FAssignedStandardDateTimeEditMask := True;
  if FStandardDateTimeEditMask <> Value then
  begin
    FStandardDateTimeEditMask := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetStartOfWeek(Value: TDayOfWeek);
begin
  FAssignedStartOfWeek := True;
  if FStartOfWeek <> Value then
  begin
    FStartOfWeek := Value;
    FormatChanged;
  end;
end;

procedure TcxFormatController.SetUseDelphiDateTimeFormats(Value: Boolean);
begin
  if FUseDelphiDateTimeFormats <> Value then
  begin
    FUseDelphiDateTimeFormats := Value;
    FormatChanged;
  end;
end;

initialization

finalization
  FcxFormatController.Free;
  FcxFormatController := nil;
  
end.
