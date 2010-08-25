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

unit cxDateUtils;

{$I cxVer.inc}

interface

uses
  Variants, SysUtils,
  Windows, Controls, Classes, Graphics, cxClasses;

type
  TDay = (dSunday, dMonday, dTuesday, dWednesday, dThursday, dFriday, dSaturday);
  TDays = set of TDay;
  TDayOfWeek = 0..6;
  TcxDateElement = (deYear, deMonth, deDay);
  TcxFirstWeekOfYear = (fwySystem, fwyJan1, fwyFirstFullWeek, fwyFirstFourDays);

const
  DATE_YEARMONTH  = $00000008;  // use year month picture
  {$EXTERNALSYM DATE_YEARMONTH}
  DATE_LTRREADING = $00000010;  // add marks for left to right reading order layout
  {$EXTERNALSYM DATE_LTRREADING}
  DATE_RTLREADING = $00000020;  // add marks for right to left reading order layout
  {$EXTERNALSYM DATE_RTLREADING}

  NullDate = -700000;
  InvalidDate = NullDate + 1;
  SmartTextToDateFunc: function(const AText: string; var ADate: TDateTime): Boolean = nil;

{$IFNDEF DELPHI7}
  ApproxDaysPerMonth: Double = 30.4375;
  ApproxDaysPerYear: Double  = 365.25;
  DaysPerWeek = 7;
  WeeksPerFortnight = 2;
  MonthsPerYear = 12;
  YearsPerDecade = 10;
  YearsPerCentury = 100;
  YearsPerMillennium = 1000;
  HoursPerDay   = 24;
  MinsPerHour   = 60;
  SecsPerMin    = 60;
  MSecsPerSec   = 1000;
  MinsPerDay    = HoursPerDay * MinsPerHour;
  SecsPerDay    = MinsPerDay * SecsPerMin;
  MSecsPerDay   = SecsPerDay * MSecsPerSec;
  DayMonday = 1;
  DayTuesday = 2;
  DayWednesday = 3;
  DayThursday = 4;
  DayFriday = 5;
  DaySaturday = 6;
  DaySunday = 7;
{$ENDIF}

const
  CAL_GREGORIAN                   = 1;  //Gregorian (localized) calendar
  {$EXTERNALSYM CAL_GREGORIAN}
  CAL_GREGORIAN_US                = 2;  //Gregorian (U.S.) calendar
  {$EXTERNALSYM CAL_GREGORIAN_US}
  CAL_JAPAN                       = 3;  // Japanese Emperor Era calendar
  {$EXTERNALSYM CAL_JAPAN}
  CAL_TAIWAN                      = 4;  // Republic of China Era calendar
  {$EXTERNALSYM CAL_TAIWAN}
  CAL_KOREA                       = 5;  // Korean Tangun Era calendar
  {$EXTERNALSYM CAL_KOREA}
  CAL_HIJRI                       = 6;  // Hijri (Arabic Lunar) calendar
  {$EXTERNALSYM CAL_HIJRI}
  CAL_THAI                        = 7;  // Thai calendar
  {$EXTERNALSYM CAL_THAI}
  CAL_HEBREW                      = 8;  // Hebrew calendar
  {$EXTERNALSYM CAL_HEBREW}
  CAL_GREGORIAN_ME_FRENCH         = 9;  // Gregorian Middle East French calendar
  {$EXTERNALSYM CAL_GREGORIAN_ME_FRENCH}
  CAL_GREGORIAN_ARABIC            = 10; // Gregorian Arabic calendar
  {$EXTERNALSYM CAL_GREGORIAN_ARABIC}
  CAL_GREGORIAN_XLIT_ENGLISH      = 11; // Gregorian Transliterated English calendar
  {$EXTERNALSYM CAL_GREGORIAN_XLIT_ENGLISH}
  CAL_GREGORIAN_XLIT_FRENCH       = 12; // Gregorian Transliterated French calendar
  {$EXTERNALSYM CAL_GREGORIAN_XLIT_FRENCH}
  CAL_JULIAN                      = 13; // Julian calendar
  {$EXTERNALSYM CAL_JULIAN}
  CAL_JAPANESELUNISOLAR           = 14; // Japanes Lunar/Solar calendar
  {$EXTERNALSYM CAL_JAPANESELUNISOLAR}
  CAL_CHINESELUNISOLAR            = 15; // Chinese Lunar/Solar calendar
  {$EXTERNALSYM CAL_CHINESELUNISOLAR}
  CAL_SAKA                        = 16; // reserved to match Office but not implemented in our code
  {$EXTERNALSYM CAL_SAKA}
  CAL_LUNAR_ETO_CHN               = 17; // reserved to match Office but not implemented in our code
  {$EXTERNALSYM CAL_LUNAR_ETO_CHN}
  CAL_LUNAR_ETO_KOR               = 18; // reserved to match Office but not implemented in our code
  {$EXTERNALSYM CAL_LUNAR_ETO_KOR}
  CAL_LUNAR_ETO_ROKUYOU           = 19; // reserved to match Office but not implemented in our code
  {$EXTERNALSYM CAL_LUNAR_ETO_ROKUYOU}
  CAL_KOREANLUNISOLAR             = 20; // Korean Lunar/Solar calendar
  {$EXTERNALSYM CAL_KOREANLUNISOLAR}
  CAL_TAIWANLUNISOLAR             = 21; // Taiwan Lunar/Solar calendar
  {$EXTERNALSYM CAL_TAIWANLUNISOLAR}
  CAL_PERSIAN                     = 22; // Persian calendar
  {$EXTERNALSYM CAL_PERSIAN}
  CAL_UMALQURA                    = 23; // UmAlQura Hijri (Arabic Lunar) calendar }
  {$EXTERNALSYM CAL_UMALQURA}

  CAL_SSHORTESTDAYNAME1   = $00000060;  // Windows Vista or later: Short native name of the first day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME1}
  CAL_SSHORTESTDAYNAME2   = $00000061;  // Windows Vista or later: Short native name of the second day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME2}
  CAL_SSHORTESTDAYNAME3   = $00000062;  // Windows Vista or later: Short native name of the third day of the week.\
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME3}
  CAL_SSHORTESTDAYNAME4   = $00000063;  // Windows Vista or later: Short native name of the fourth day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME4}
  CAL_SSHORTESTDAYNAME5   = $00000064;  // Windows Vista or later: Short native name of the fifth day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME5}
  CAL_SSHORTESTDAYNAME6   = $00000065;  // Windows Vista or later: Short native name of the sixth day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME6}
  CAL_SSHORTESTDAYNAME7   = $00000066;  // Windows Vista or later: Short native name of the seventh day of the week.
  {$EXTERNALSYM CAL_SSHORTESTDAYNAME7}

  CAL_RETURN_NUMBER     = $20000000;  // Windows 98/Me, Windows 2000 and later: Returns the result from GetCalendarInfo as a number instead of a string. This is only valid for CALTYPES beginning with CAL_I.
  {$EXTERNALSYM CAL_RETURN_NUMBER}
  CAL_ITWODIGITYEARMAX  = $00000030;  // Windows 98/Me, Windows 2000 and later: An integer value indicating the upper boundary of the two-digit year range.
  {$EXTERNALSYM CAL_ITWODIGITYEARMAX}
  CAL_SYEARMONTH        = $0000002F;  // Windows 98/Me, Windows 2000 and later: Enumerates the year/month formats for the specified calendars.
  {$EXTERNALSYM CAL_SYEARMONTH}

type
{$IFNDEF DELPHI7}
  TFormatSettings = record
    CurrencyFormat: Byte;
    NegCurrFormat: Byte;
    ThousandSeparator: Char;
    DecimalSeparator: Char;
    CurrencyDecimals: Byte;
    DateSeparator: Char;
    TimeSeparator: Char;
    ListSeparator: Char;
    CurrencyString: string;
    ShortDateFormat: string;
    LongDateFormat: string;
    TimeAMString: string;
    TimePMString: string;
    ShortTimeFormat: string;
    LongTimeFormat: string;
    ShortMonthNames: array[1..12] of string;
    LongMonthNames: array[1..12] of string;
    ShortDayNames: array[1..7] of string;
    LongDayNames: array[1..7] of string;
    TwoDigitYearCenturyWindow: Word;
  end;
{$ENDIF}

  {$EXTERNALSYM TcxCALID}
  TcxCALID = DWORD;    { Calendar ID. }

  TcxCalendarAlgorithmType = (catUnknown, catSolarCalendar, catLunarCalendar,
    catLunarSolarCalendar);

  TcxDateTime = record
    Era: Integer;
    Year: Cardinal;
    Month: Cardinal;
    Day: Cardinal;
    Hours: Byte;
    Minutes: Byte;
    Seconds: Byte;
    Milliseconds: Word;
  end;

  TcxDate = record
    Era: Integer;
    Year: Cardinal;
    Month: Cardinal;
    Day: Cardinal;
  end;

  TcxTime = record
    Hours: Cardinal;
    Minutes: Cardinal;
    Seconds: Cardinal;
    Miliseconds: Cardinal;
  end;

  TcxEra = class(TPersistent)
  private
    FEra: Integer;
    FMaxEraYear: Integer;
    FMinEraYear: Integer;
    FStartDate: TDateTime;
    FYearOffset: Integer;
  public
    constructor Create(AEra: Integer; AStartDate: TDateTime;
      AYearOffset, AMinEraYear, AMaxEraYear: Integer);
    procedure Assign(Source: TPersistent); override;

    property Era: Integer read FEra write FEra;
    property MaxEraYear: Integer read FMaxEraYear write FMaxEraYear;
    property MinEraYear: Integer read FMinEraYear write FMinEraYear;
    property StartDate: TDateTime read FStartDate write FStartDate;
    property YearOffset: Integer read FYearOffset write FYearOffset;
  end;

  TcxEras = class(TcxObjectList)
  private
    function GetItem(AIndex: Integer): TcxEra;
    procedure SetItem(AIndex: Integer; AValue: TcxEra);
  public
    property Items[Index: Integer]: TcxEra read GetItem write SetItem; default;
  end;

  { TcxCustomCalendarTable }

  TcxCustomCalendarTable = class
  protected
    FEras: TcxEras;
    procedure AdjustYear(var AYear, AEra: Integer); overload; virtual;
    procedure AdjustYear(var AYear, AEra: Integer; AMonth, ADay: Integer); overload; virtual;
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; virtual; abstract;
    function GetCalendarID: TcxCALID; virtual; abstract;
    function GetDefaultEra: TcxEra; virtual; abstract;
    function GetMaxSupportedDate: TDateTime; virtual; abstract;
    function GetMinSupportedDate: TDateTime; virtual; abstract;
    procedure CheckDateTime(var ADateTime: TDateTime); virtual;
    function GetMaxSupportedYear: Integer; virtual; abstract;
    function GetMinSupportedYear: Integer; virtual; abstract;
    function IsNotValid(ADate: TcxDateTime; out AResult: TDateTime): Boolean;
    procedure YearToGregorianYear(var AYear: Cardinal; AEra: Integer);
  public
    constructor Create; virtual;
    destructor Destroy; override;

    function AddDays(ADate: TcxDateTime; ACountDays: Integer): TDateTime; overload; virtual;

    function AddMonths(ADate: TDateTime; ACountMonths: Integer): TDateTime; overload; virtual;
    function AddMonths(ADate: TcxDateTime; ACountMonths: Integer): TDateTime; overload; virtual;

    function AddYears(ADate: TDateTime; ACountYears: Integer): TDateTime; overload; virtual;
    function AddYears(ADate: TcxDateTime; ACountYears: Integer): TDateTime; overload; virtual;

    function AddWeeks(ADate: TDateTime; ACountWeeks: Integer): TDateTime; overload; virtual;
    function AddWeeks(ADate: TcxDateTime; ACountWeeks: Integer): TDateTime; overload; virtual;

    function FromDateTime(ADate: TDateTime): TcxDateTime; overload; virtual; abstract;
    function FromDateTime(AYear, AMonth, ADay: Cardinal): TcxDateTime; overload; virtual;
    function FromDateTime(AYear, AMonth, ADay: Cardinal; AHours, AMinutes, ASeconds: Byte;
      AMilliseconds: Word): TcxDateTime; overload; virtual;
    function GetDayOfYear(ADate: TDateTime): Cardinal; overload; virtual;
    function GetDayOfYear(ADate: TcxDateTime): Cardinal; overload; virtual;
    function GetDaysInMonth(AYear, AMonth: Cardinal): Cardinal; overload; virtual;
    function GetDaysInMonth(AEra: Integer; AYear, AMonth: Cardinal): Cardinal; overload; virtual; abstract;
    function GetDaysInYear(AYear: Cardinal): Cardinal; overload; virtual;
    function GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal; overload; virtual; abstract;
    function GetEra(AYear: Integer): Integer; overload; virtual;
    function GetEra(AYear, AMonth, ADay: Integer): Integer; overload; virtual;
    function GetFirstDayOfWeek(ADate: TDateTime): TDateTime; overload; virtual;
    function GetFirstDayOfWeek(ADate: TDateTime; AStartDayOfWeek: TDay): TDateTime; overload; virtual;
    function GetFirstDayOfWeek(ADate: TcxDateTime): TcxDateTime; overload; virtual;
    function GetFirstDayOfWeek(ADate: TcxDateTime; AStartDayOfWeek: TDay): TcxDateTime; overload; virtual;
    function GetFirstWeekDay: Byte; virtual; abstract;
    function GetFullWeeksInYear(AYear: Cardinal): Cardinal; virtual; abstract;
    function GetMonthsInYear(AYear: Cardinal): Cardinal; overload; virtual;
    function GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal; overload; virtual; abstract;
    function GetYear(ADate: TDateTime): Cardinal; overload; virtual;
    function GetYear(ADate: TcxDate): Cardinal; overload; virtual;
    function GetYear(ADate: TcxDateTime): Cardinal; overload; virtual;
    function GetWeekDay(ADate: TDateTime): Byte; overload; virtual;
    function GetWeekDay(ADate: TcxDateTime): Byte; overload; virtual;
    function GetWeekNumber(ADate: TDateTime; AStartOfWeek: TDay;
      AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal; overload; virtual;
    function GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
      AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal; overload; virtual; abstract;
    function IsLeapDay(AYear, AMonth, ADay: Cardinal): Boolean; overload; virtual;
    function IsLeapDay(AEra: Integer; AYear, AMonth, ADay: Cardinal): Boolean; overload; virtual; abstract;
    function IsLeapMonth(AYear, AMonth: Cardinal): Boolean; overload; virtual;
    function IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean; overload; virtual; abstract;
    function IsLeapYear(AYear: Cardinal): Boolean; overload; virtual;
    function IsLeapYear(AEra: Integer; Year: Cardinal): Boolean; overload; virtual; abstract;

    function IsValidYear(AYear: Cardinal): Boolean; overload; virtual;
    function IsValidYear(AEra: Integer; AYear: Cardinal): Boolean; overload; virtual;
    function IsValidMonth(AYear, AMonth: Cardinal): Boolean; overload; virtual;
    function IsValidMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean; overload; virtual;
    function IsValidDay(AYear, AMonth, ADay: Cardinal): Boolean; overload; virtual;
    function IsValidDay(AEra: Integer; AYear, AMonth, ADay: Cardinal): Boolean; overload; virtual;
    function IsValidDate(ADate: TDateTime): Boolean; virtual;

    function ToDateTime(ADate: TcxDate): TDateTime; overload; virtual;
    function ToDateTime(AYear, AMonth, ADay: Cardinal): TDateTime; overload; virtual;
    function ToDateTime(AYear, AMonth, ADay: Cardinal; AHours, AMinutes, ASeconds: Byte;
      AMilliseconds: Word): TDateTime; overload; virtual;
    function ToDateTime(ADateTime: TcxDateTime): TDateTime; overload; virtual; abstract;

    function GetDayNumber(const S: string): Integer; virtual;
    function GetMonthNumber(AYear: Integer; const S: string): Integer; virtual;
    function GetYearNumber(const S: string): Integer; virtual;

    property AlgorithmType: TcxCalendarAlgorithmType read GetCalendarAlgorithmType;
    property CalendarID: TcxCALID read GetCalendarID;
    property DefaultEra: TcxEra read GetDefaultEra;
    property Eras: TcxEras read FEras;
    property MaxSupportedDate: TDateTime read GetMaxSupportedDate;
    property MinSupportedDate: TDateTime read GetMinSupportedDate;
  end;

  { TcxGregorianCalendarTable }

  TcxGregorianCalendarTableType = (gctLocalized = 1, gctUSEnglish = 2, gctMiddleEastFrench = 9,
    gctArabic = 10, gctTransliteratedEnglish = 11, gctTransliteratedFrench = 12);

  TcxGregorianCalendarTable = class(TcxCustomCalendarTable)
  private
    FDefaultEra: TcxEra;
    FGregorianCalendarType: TcxGregorianCalendarTableType;
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMaxSupportedDate: TDateTime; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function FromDateTime(ADate: TDateTime): TcxDateTime; overload; override;
    function GetFirstWeekDay: Byte; override;
    function GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
      AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal; overload; override;
    function GetDaysInMonth(AEra: Integer; AYear, AMonth: Cardinal): Cardinal; override;
    function GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function GetFullWeeksInYear(AYear: Cardinal): Cardinal; override;
    function GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function IsLeapDay(AEra: Integer; AYear, AMonth, ADay: Cardinal): Boolean; override;
    function IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean; override;
    function IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean; override;
    function ToDateTime(ADateTime: TcxDateTime): TDateTime; overload; override;

    property GregorianCalendarType: TcxGregorianCalendarTableType read
      FGregorianCalendarType write FGregorianCalendarType;
  end;

  { TcxJapaneseCalendarTable }

  TcxJapaneseCalendarTable = class(TcxGregorianCalendarTable)
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMaxSupportedDate: TDateTime; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;

    function FromDateTime(ADate: TDateTime): TcxDateTime; overload; override;
    function GetFirstWeekDay: Byte; override;
    function ToDateTime(ADateTime: TcxDateTime): TDateTime; overload; override;
  end;

  { TcxTaiwanCalendarTable }

  TcxTaiwanCalendarTable = class(TcxJapaneseCalendarTable)
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
  end;

  { TcxKoreanCalendarTable }

  TcxKoreanCalendarTable = class(TcxJapaneseCalendarTable)
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
  end;

  { TcxHijriCalendarTable }

  TcxHijriCalendarTable = class(TcxCustomCalendarTable)
  private
    FDefaultEra: TcxEra;
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMaxSupportedDate: TDateTime; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function FromDateTime(ADate: TDateTime): TcxDateTime; overload; override;
    function GetFirstWeekDay: Byte; override;
    function GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
      AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal; overload; override;
    function GetDaysInMonth(AEra: Integer; AYear, AMonth: Cardinal): Cardinal; override;
    function GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function GetFullWeeksInYear(AYear: Cardinal): Cardinal; override;
    function GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function IsLeapDay(AEra: Integer; AYear, AMonth, ADay: Cardinal): Boolean; override;
    function IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean; override;
    function IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean; override;
    function ToDateTime(ADateTime: TcxDateTime): TDateTime; overload; override;

    function GetMonthNumber(AYear: Integer; const S: string): Integer; override;
  end;

  { TcxThaiCalendarTable }

  TcxThaiCalendarTable = class(TcxJapaneseCalendarTable)
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
  end;

  { TcxHebrewCalendar }

  TcxHebrewCalendarTableTypeYear = (hctyDeficient = 1, hctyNormal = 2, hctyPerfect = 3);

  TcxHebrewCalendarTable = class(TcxCustomCalendarTable)
  private
    FDefaultEra: TcxEra;
    function GetDayDifference(ALunarYearType, AMonth, ADay,
      ALunarMonth, ALunarDay: Integer): Integer;
    function HebrewNumber(const S: string): Integer;
    procedure GetLunarMonthDay(AYear: Integer; var ADate: TcxDate);
  protected
    function GetCalendarAlgorithmType: TcxCalendarAlgorithmType; override;
    function GetCalendarID: TcxCALID; override;
    function GetDefaultEra: TcxEra; override;
    function GetMaxSupportedDate: TDateTime; override;
    function GetMinSupportedDate: TDateTime; override;
    function GetMaxSupportedYear: Integer; override;
    function GetMinSupportedYear: Integer; override;
  public
    constructor Create; override;
    destructor Destroy; override;

    function FromDateTime(ADate: TDateTime): TcxDateTime; overload; override;
    function GetFirstWeekDay: Byte; override;
    function GetYearType(AYear: Cardinal): TcxHebrewCalendarTableTypeYear;
    function GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
      AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal; overload; override;
    function GetDaysInMonth(AEra: Integer; AYear, AMonth: Cardinal): Cardinal; override;
    function GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function GetFullWeeksInYear(AYear: Cardinal): Cardinal; override;
    function GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal; override;
    function IsLeapDay(AEra: Integer; AYear, AMonth, ADay: Cardinal): Boolean; override;
    function IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean; override;
    function IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean; override;
    function ToDateTime(ADateTime: TcxDateTime): TDateTime; overload; override;

    function GetDayNumber(const S: string): Integer; override;
    function GetMonthNumber(AYear: Integer; const S: string): Integer; override;
    function GetYearNumber(const S: string): Integer; override;
  end;

  TcxGetCalendarInfo = function (Locale: LCID; Calendar: CALID;
    CalendType: CALTYPE; lpCalData : PChar;
    cchData: Integer; lpValue: lpDWord): Integer; stdcall;

function cxGetCalendarInfo(Locale: LCID; Calendar: CALID;
  CalendType: CALTYPE; lpCalData: PChar; cchData: Integer;
  lpValue: PDWORD): Integer;

function cxDateToLocalFormatStr(ADate: TDateTime): string;
function cxDateToStr(ADate: TDateTime): string; overload;
function cxDateToStr(ADate: TDateTime; AFormat: TFormatSettings): string; overload;
function cxDayNumberToLocalFormatStr(ADate: TDateTime): string; overload;
function cxDayNumberToLocalFormatStr(ADay: Integer; ACalendar: TcxCustomCalendarTable = nil): string; overload;
function cxGetCalendar(ACalendType: CALTYPE): TcxCustomCalendarTable;
function cxGetLocalCalendarID: TcxCALID;
function cxGetLocalCalendar: TcxCustomCalendarTable;
function cxGetDateSeparator: Char;
function cxGetLocalFormatSettings: TFormatSettings;
function cxGetLocalLongDateFormat: string;
function cxGetLocalLongTimeFormat: string;
function cxGetLocalMonthName(ADate: TDateTime; ACalendar: TcxCustomCalendarTable): string; overload;
function cxGetLocalMonthName(AYear, AMonth: Integer; ACalendar: TcxCustomCalendarTable): string; overload;
function cxGetLocalMonthYear(ADate: TDateTime; ACalendar: TcxCustomCalendarTable = nil): string;
function cxGetLocalShortDateFormat: string;
function cxGetLocalTimeAMString: string;
function cxGetLocalTimePMString: string;
function cxGetLocalTimeSeparator: Char;
function cxGetLocalYear(ADate: TDateTime; ACalendar: TcxCustomCalendarTable  = nil): string;
function cxGetDayOfWeekName(I: Integer; AFontCharset: TFontCharset): string;
function cxIsGregorianCalendar(ACalendar: TcxCustomCalendarTable = nil): Boolean;
function cxLocalFormatStrToDate(const ADateStr: string): TDateTime;
function cxStrToDate(const ADateStr: string;
  ACalendar: TcxCustomCalendarTable = nil): TcxDateTime; overload;
function cxStrToDate(const ADateStr: string;
  AFormat: TFormatSettings;
  ACalendar: TcxCustomCalendarTable = nil): TcxDateTime; overload;
function cxStrToDate(const ADateString: string; const AFormat: TFormatSettings;
  ACALTYPE: CALTYPE): TDate; overload;
function cxTimeToStr(ATime: TDateTime): string; overload;
function cxTimeToStr(ATime: TDateTime; ATimeFormat: string): string; overload;
function cxTimeToStr(ATime: TDateTime; AFormatSettings: TFormatSettings): string; overload;


var
  MinYear: Integer = 100;
  MaxYear: Integer = 9999;
  cxMaxDateTime: Double = 2958465.99999; // 12/31/9999 11:59:59.999 PM
  cxUseSingleCharWeekNames: Boolean = True;

procedure AddDateRegExprMaskSmartInput(var AMask: string; ACanEnterTime: Boolean);
procedure DecMonth(var AYear, AMonth: Word);
procedure IncMonth(var AYear, AMonth: Word); overload;
procedure ChangeMonth(var AYear, AMonth: Word; Delta: Integer);
function GetMonthNumber(const ADate: TDateTime): Integer;
function GetDateElement(ADate: TDateTime; AElement: TcxDateElement;
  ACalendar: TcxCustomCalendarTable = nil): Integer;
function IsLeapYear(AYear: Integer): Boolean;
function DaysPerMonth(AYear, AMonth: Integer): Integer;
function CheckDay(AYear, AMonth, ADay: Integer): Integer;
function TimeOf(const AValue: TDateTime): TDateTime;
function DateOf(const AValue: TDateTime): TDateTime;
function DayOfWeekOffset(const AValue: TDateTime): TDayOfWeek;

function GetStartDateOfMonth(const ADate: TDateTime): TDateTime;
function GetStartOfWeek: Integer;
function GetEndDateOfMonth(const ADate: TDateTime; AIgnoreTime: Boolean): TDateTime;
function GetStartDateOfYear(const ADate: TDateTime): TDateTime;
function GetEndDateOfYear(const ADate: TDateTime; AIgnoreTime: Boolean): TDateTime;

function cxGetDateFormat(ADate: TDateTime; out AFormatDate: string; AFlags: Integer; AFormat: string = ''): Boolean;
function DateToLongDateStr(ADate: TDateTime): string;
function GetWeekNumber(ADate: TDateTime; AStartOfWeek: TDay;
  AFirstWeekOfYear: TcxFirstWeekOfYear): Integer;

{$IFNDEF DELPHI6}
function HourOf(ADateTime: TDateTime): Word;
function IsPM(const AValue: TDateTime): Boolean;
function EncodeDateWeek(const AYear, AWeekOfYear: Word;
  const ADayOfWeek: Word): TDateTime;
procedure DecodeDateWeek(const AValue: TDateTime; out AYear, AWeekOfYear,
  ADayOfWeek: Word);
function DaysInAMonth(const AYear, AMonth: Word): Word;
function DaysInMonth(const AValue: TDateTime): Word;
function DayOf(const AValue: TDateTime): Word;
function DayOfTheMonth(const AValue: TDateTime): Word;
function DayOfTheWeek(const AValue: TDateTime): Word;
procedure DecodeDateTime(const AValue: TDateTime; out AYear, AMonth, ADay,
  AHour, AMinute, ASecond, AMilliSecond: Word);
function EncodeDateTime(const AYear, AMonth, ADay, AHour, AMinute, ASecond,
  AMilliSecond: Word): TDateTime;
procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
function MinuteOf(const AValue: TDateTime): Word;
function MonthOf(const AValue: TDateTime): Word;
function StartOfTheYear(const AValue: TDateTime): TDateTime;
function StartOfTheMonth(const AValue: TDateTime): TDateTime;
function YearOf(const AValue: TDateTime): Word;
function YearsBetween(const ANow, AThen: TDateTime): Integer;
function MonthsBetween(const ANow, AThen: TDateTime): Integer;
function WeeksBetween(const ANow, AThen: TDateTime): Integer;
function DaysBetween(const ANow, AThen: TDateTime): Integer;
function IncYear(const AValue: TDateTime;
  const ANumberOfYears: Integer = 1): TDateTime;
function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer): TDateTime; overload;
function IncWeek(const AValue: TDateTime;
  const ANumberOfWeeks: Integer = 1): TDateTime;
function IncDay(const AValue: TDateTime;
  const ANumberOfDays: Integer = 1): TDateTime;
function IncHour(const AValue: TDateTime; const ANumberOfHours: Int64 = 1): TDateTime;
function IncMinute(const AValue: TDateTime; const ANumberOfMinutes: Int64 = 1): TDateTime;
function WeekOfTheMonth(const AValue: TDateTime): Word;
function WeekOf(AValue: TDateTime): Word;
function WeekOfTheYear(const AValue: TDateTime): Word;
function DayOfTheYear(AValue: TDateTime): Word;
function EndOfTheYear(AValue: TDateTime): TDateTime;
{$ENDIF}

function cxDateTimeToText(ADate: TDateTime; AFourDigitYearNeeded: Boolean = False; AUseDelphiDateTimeFormats: Boolean = False): string;
function cxTextToDateTime(const AText: string; AUseDelphiDateTimeFormats: Boolean = False): TDateTime;
function DateTimeToText(ADate: TDateTime; AFourDigitYearNeeded: Boolean = False): string;
function DateTimeToTextEx(const ADate: TDateTime; AIsMasked: Boolean;
  AIsDateTimeEdit: Boolean = False; AFourDigitYearNeeded: Boolean = False): string;
function TextToDateEx(const AText: string; var ADate: TDateTime): Boolean;
function StrToDateDef(const ADateStr: string; ADefDate: TDateTime): TDateTime;
function SmartTextToDate(const AText: string; var ADate: TDateTime): Boolean;
function cxMinDateTime: Double;
function cxStrToDateTime(S: string; AUseOleDateFormat: Boolean;
  out ADate: TDateTime): Boolean;

function cxIsDateValid(ADate: Double): Boolean;

implementation

uses
  DateUtils, cxFormats, cxLibraryStrs, cxControls, cxGraphics, dxCore;

type
  TcxDateEditSmartInput = (deiToday, deiYesterday, deiTomorrow,
    deiSunday, deiMonday, deiTuesday, deiWednesday, deiThursday, deiFriday, deiSaturday,
    deiFirst, deiSecond, deiThird, deiFourth, deiFifth, deiSixth, deiSeventh,
    deiBOM, deiEOM, deiNow);

var
  scxDateEditSmartInput: array [TcxDateEditSmartInput] of string;

const
  cxHebrewTable: array [0..1315] of Integer =
    (7,3,17,3,                 // 1583-1584  (Hebrew year: 5343 - 5344)
    0,4,11,2,21,6,1,3,13,2,   // 1585-1589
    25,4,5,3,16,2,27,6,9,1,   // 1590-1594
    20,2,0,6,11,3,23,4,4,2,   // 1595-1599
    14,3,27,4,8,2,18,3,28,6,  // 1600
    11,1,22,5,2,3,12,3,25,4,  // 1605
    6,2,16,3,26,6,8,2,20,1,   // 1610
    0,6,11,2,24,4,4,3,15,2,   // 1615
    25,6,8,1,19,2,29,6,9,3,   // 1620
    22,4,3,2,13,3,25,4,6,3,   // 1625
    17,2,27,6,7,3,19,2,31,4,  // 1630
    11,3,23,4,5,2,15,3,25,6,  // 1635
    6,2,19,1,29,6,10,2,22,4,  // 1640
    3,3,14,2,24,6,6,1,17,3,   // 1645
    28,5,8,3,20,1,32,5,12,3,  // 1650
    22,6,4,1,16,2,26,6,6,3,   // 1655
    17,2,0,4,10,3,22,4,3,2,   // 1660
    14,3,24,6,5,2,17,1,28,6,  // 1665
    9,2,19,3,31,4,13,2,23,6,  // 1670
    3,3,15,1,27,5,7,3,17,3,   // 1675
    29,4,11,2,21,6,3,1,14,2,  // 1680
    25,6,5,3,16,2,28,4,9,3,   // 1685
    20,2,0,6,12,1,23,6,4,2,   // 1690
    14,3,26,4,8,2,18,3,0,4,   // 1695
    10,3,21,5,1,3,13,1,24,5,  // 1700
    5,3,15,3,27,4,8,2,19,3,   // 1705
    29,6,10,2,22,4,3,3,14,2,  // 1710
    26,4,6,3,18,2,28,6,10,1,  // 1715
    20,6,2,2,12,3,24,4,5,2,   // 1720
    16,3,28,4,8,3,19,2,0,6,   // 1725
    12,1,23,5,3,3,14,3,26,4,  // 1730
    7,2,17,3,28,6,9,2,21,4,   // 1735
    1,3,13,2,25,4,5,3,16,2,   // 1740
    27,6,9,1,19,3,0,5,11,3,   // 1745
    23,4,4,2,14,3,25,6,7,1,   // 1750
    18,2,28,6,9,3,21,4,2,2,   // 1755
    12,3,25,4,6,2,16,3,26,6,  // 1760
    8,2,20,1,0,6,11,2,22,6,   // 1765
    4,1,15,2,25,6,6,3,18,1,   // 1770
    29,5,9,3,22,4,2,3,13,2,   // 1775
    23,6,4,3,15,2,27,4,7,3,   // 1780
    19,2,31,4,11,3,21,6,3,2,  // 1785
    15,1,25,6,6,2,17,3,29,4,  // 1790
    10,2,20,6,3,1,13,3,24,5,  // 1795
    4,3,16,1,27,5,7,3,17,3,   // 1800
    0,4,11,2,21,6,1,3,13,2,   // 1805
    25,4,5,3,16,2,29,4,9,3,   // 1810
    19,6,30,2,13,1,23,6,4,2,  // 1815
    14,3,27,4,8,2,18,3,0,4,   // 1820
    11,3,22,5,2,3,14,1,26,5,  // 1825
    6,3,16,3,28,4,10,2,20,6,  // 1830
    30,3,11,2,24,4,4,3,15,2,  // 1835
    25,6,8,1,19,2,29,6,9,3,   // 1840
    22,4,3,2,13,3,25,4,7,2,   // 1845
    17,3,27,6,9,1,21,5,1,3,   // 1850
    11,3,23,4,5,2,15,3,25,6,  // 1855
    6,2,19,1,29,6,10,2,22,4,  // 1860
    3,3,14,2,24,6,6,1,18,2,   // 1865
    28,6,8,3,20,4,2,2,12,3,   // 1870
    24,4,4,3,16,2,26,6,6,3,   // 1875
    17,2,0,4,10,3,22,4,3,2,   // 1880
    14,3,24,6,5,2,17,1,28,6,  // 1885
    9,2,21,4,1,3,13,2,23,6,   // 1890
    5,1,15,3,27,5,7,3,19,1,   // 1895
    0,5,10,3,22,4,2,3,13,2,   // 1900
    24,6,4,3,15,2,27,4,8,3,   // 1905
    20,4,1,2,11,3,22,6,3,2,   // 1910
    15,1,25,6,7,2,17,3,29,4,  // 1915
    10,2,21,6,1,3,13,1,24,5,  // 1920
    5,3,15,3,27,4,8,2,19,6,   // 1925
    1,1,12,2,22,6,3,3,14,2,   // 1930
    26,4,6,3,18,2,28,6,10,1,  // 1935
    20,6,2,2,12,3,24,4,5,2,   // 1940
    16,3,28,4,9,2,19,6,30,3,  // 1945
    12,1,23,5,3,3,14,3,26,4,  // 1950
    7,2,17,3,28,6,9,2,21,4,   // 1955
    1,3,13,2,25,4,5,3,16,2,   // 1960
    27,6,9,1,19,6,30,2,11,3,  // 1965
    23,4,4,2,14,3,27,4,7,3,   // 1970
    18,2,28,6,11,1,22,5,2,3,  // 1975
    12,3,25,4,6,2,16,3,26,6,  // 1980
    8,2,20,4,30,3,11,2,24,4,  // 1985
    4,3,15,2,25,6,8,1,18,3,   // 1990
    29,5,9,3,22,4,3,2,13,3,   // 1995
    23,6,6,1,17,2,27,6,7,3,   // 2000 - 2004
    20,4,1,2,11,3,23,4,5,2,   // 2005 - 2009
    15,3,25,6,6,2,19,1,29,6,  // 2010
    10,2,20,6,3,1,14,2,24,6,  // 2015
    4,3,17,1,28,5,8,3,20,4,   // 2020
    1,3,12,2,22,6,2,3,14,2,   // 2025
    26,4,6,3,17,2,0,4,10,3,   // 2030
    20,6,1,2,14,1,24,6,5,2,   // 2035
    15,3,28,4,9,2,19,6,1,1,   // 2040
    12,3,23,5,3,3,15,1,27,5,  // 2045
    7,3,17,3,29,4,11,2,21,6,  // 2050
    1,3,12,2,25,4,5,3,16,2,   // 2055
    28,4,9,3,19,6,30,2,12,1,  // 2060
    23,6,4,2,14,3,26,4,8,2,   // 2065
    18,3,0,4,10,3,22,5,2,3,   // 2070
    14,1,25,5,6,3,16,3,28,4,  // 2075
    9,2,20,6,30,3,11,2,23,4,  // 2080
    4,3,15,2,27,4,7,3,19,2,   // 2085
    29,6,11,1,21,6,3,2,13,3,  // 2090
    25,4,6,2,17,3,27,6,9,1,   // 2095
    20,5,30,3,10,3,22,4,3,2,  // 2100
    14,3,24,6,5,2,17,1,28,6,  // 2105
    9,2,21,4,1,3,13,2,23,6,   // 2110
    5,1,16,2,27,6,7,3,19,4,   // 2115
    30,2,11,3,23,4,3,3,14,2,  // 2120
    25,6,5,3,16,2,28,4,9,3,   // 2125
    21,4,2,2,12,3,23,6,4,2,   // 2130
    16,1,26,6,8,2,20,4,30,3,  // 2135
    11,2,22,6,4,1,14,3,25,5,  // 2140
    6,3,18,1,29,5,9,3,22,4,   // 2145
    2,3,13,2,23,6,4,3,15,2,   // 2150
    27,4,7,3,20,4,1,2,11,3,   // 2155
    21,6,3,2,15,1,25,6,6,2,   // 2160
    17,3,29,4,10,2,20,6,3,1,  // 2165
    13,3,24,5,4,3,17,1,28,5,  // 2170
    8,3,18,6,1,1,12,2,22,6,   // 2175
    2,3,14,2,26,4,6,3,17,2,   // 2180
    28,6,10,1,20,6,1,2,12,3,  // 2185
    24,4,5,2,15,3,28,4,9,2,   // 2190
    19,6,33,3,12,1,23,5,3,3,  // 2195
    13,3,25,4,6,2,16,3,26,6,  // 2200
    8,2,20,4,30,3,11,2,24,4,  // 2205
    4,3,15,2,25,6,8,1,18,6,   // 2210
    33,2,9,3,22,4,3,2,13,3,   // 2215
    25,4,6,3,17,2,27,6,9,1,   // 2220
    21,5,1,3,11,3,23,4,5,2,   // 2225
    15,3,25,6,6,2,19,4,33,3,  // 2230
    10,2,22,4,3,3,14,2,24,6,  // 2235
    6,1);                     // 2240 (Hebrew year: 6000)

  cxHebrewLunarMonthLen: array [0..6,0..13] of Integer = (
    (0,00,00,00,00,00,00,00,00,00,00,00,00,0),
    (0,30,29,29,29,30,29,30,29,30,29,30,29,0),     // 3 common year variations
    (0,30,29,30,29,30,29,30,29,30,29,30,29,0),
    (0,30,30,30,29,30,29,30,29,30,29,30,29,0),
    (0,30,29,29,29,30,30,29,30,29,30,29,30,29),    // 3 leap year variations
    (0,30,29,30,29,30,30,29,30,29,30,29,30,29),
    (0,30,30,30,29,30,30,29,30,29,30,29,30,29));

  cxHebrewYearOf1AD = 3760;
  cxHebrewFirstGregorianTableYear = 1583;
  cxHebrewLastGregorianTableYear = 2239;
  cxHebrewTableYear = cxHebrewLastGregorianTableYear - cxHebrewFirstGregorianTableYear;

type
  TcxDateOrder = (doMDY, doDMY, doYMD);
  TcxMonthView = (mvName, mvDigital, mvNone);
  TcxYearView = (yvFourDigitals, yvTwoDigitals, yvNone);

function GetDateOrder(const ADateFormat: string): TcxDateOrder;
var
  I: Integer;
begin
  Result := doMDY;
  I := 1;
  while I <= Length(ADateFormat) do
  begin
    case Chr(Ord(ADateFormat[I]) and $DF) of
      'E': Result := doYMD;
      'Y': Result := doYMD;
      'M': Result := doMDY;
      'D': Result := doDMY;
    else
      Inc(I);
      Continue;
    end;
    Exit;
  end;
  Result := doMDY;
end;

function cxDateToStrByFormat(const ADate: TDateTime; const ADateFormat: string; const ADateSeparator: Char): string;

  function AddZeros(const S: string; ALength: Integer): string;
  begin
    Result := S;
    if ALength <= Length(S) then
      Exit;
    Result := StringOfChar('0', ALength - Length(Result)) + Result;
  end;

  function GetCountChar(const S: string; Ch: Char; var APos: Integer): Integer;
  begin
    Result := APos;
    while (APos <= Length(S)) and (S[APos] = Ch)do
      Inc(APos);
    Result := APos - Result;
  end;

  function GetMonthView(const ADateFormat: string; var APos: Integer): TcxMonthView;
  var
    ACount: Integer;
  begin
    ACount := GetCountChar(AnsiLowerCase(ADateFormat), 'm', APos);
    if ACount = 4 then
      Result := mvName
    else
      if ACount = 0 then
        Result := mvNone
      else
        Result := mvDigital;
  end;

  function GetYearView(const ADateFormat: string; var APos: Integer): TcxYearView;
  var
    ACount: Integer;
  begin
    ACount := GetCountChar(AnsiLowerCase(ADateFormat), 'y', APos);
    if ACount = 4 then
      Result := yvFourDigitals
    else
      if ACount = 0 then
        Result := yvNone
      else
        Result := yvTwoDigitals;
  end;

  function MonthToStr(AMonth: Integer; AView: TcxMonthView): string;
  begin
    case AView of
      mvName:
        Result := LongMonthNames[AMonth];
      mvDigital:
        Result := AddZeros(IntToStr(AMonth), 2);
      else
        Result := '';
    end;
  end;

  function YearToStr(AYear: Integer; AView: TcxYearView): string;
  begin
    if AView = yvNone then
    begin
      Result := '';
      Exit;
    end;
    Result := IntToStr(AYear);
    if Length(Result) > 4 then
      Result := Copy(Result, Length(Result) - 3, 4);
    Result := AddZeros(Result, 4);
    if AView = yvTwoDigitals then
      Result := Copy(Result, Length(Result) - 1, 2);
  end;

  function FindNextAllowChar(const S: string; var APos: Integer): Boolean;
  begin
    while (APos <= Length(S)) and not dxCharInSet(AnsiLowerCase(S[APos])[1], ['d', 'm', 'y']) do
      Inc(APos);
    Result := (APos <= Length(S)) and dxCharInSet(AnsiLowerCase(S[APos])[1], ['d', 'm', 'y']);
  end;

  procedure AddToDateParth(var ADateString: string; const AParth: string; const ASeparator: string);
  begin
    if Length(ADateString) > 0 then
      if ADateSeparator <> '' then
        ADateString := ADateString + ADateSeparator
      else
        ADateString := ADateString + ASeparator;
    ADateString := ADateString + AParth;
  end;

var
  ASystemDate: TSystemTime;
  APos: Integer;
  ACurrentSeparator: string;
  ACountChar: Integer;
  ADayOfWeek: Integer;
begin
  Result := '';
  DateTimeToSystemTime(ADate, ASystemDate);
  ADayOfWeek := ASystemDate.wDayOfWeek;
  Inc(ADayOfWeek);
  if ADayOfWeek > 7 then
    Dec(ADayOfWeek, 7);
  APos := 1;
  ACurrentSeparator := '';
  FindNextAllowChar(ADateFormat, APos);
  while APos <= Length(ADateFormat) do
  begin
    case AnsiLowerCase(ADateFormat[APos])[1] of
      'd':
        begin
          ACountChar := GetCountChar(ADateFormat, 'd', APos);
          if ACountChar = 3 then
            AddToDateParth(Result, ShortDayNames[ADayOfWeek], ACurrentSeparator)
          else
            if ACountChar = 4 then
              AddToDateParth(Result, LongDayNames[ADayOfWeek], ACurrentSeparator)
            else
              if ACountChar = 2 then
                AddToDateParth(Result, AddZeros(IntToStr(ASystemDate.wDay), 2), ACurrentSeparator)
              else
                AddToDateParth(Result, IntToStr(ASystemDate.wDay), ACurrentSeparator);
          ACurrentSeparator := '';
        end;
      'y':
        begin
          AddToDateParth(Result, YearToStr(ASystemDate.wYear, GetYearView(ADateFormat, APos)), ACurrentSeparator);
          ACurrentSeparator := '';
        end;
      'm':
        begin
          AddToDateParth(Result, MonthToStr(ASystemDate.wMonth, GetMonthView(ADateFormat, APos)), ACurrentSeparator);
          ACurrentSeparator := '';
        end;
      'e':
        begin
          FindNextAllowChar(ADateFormat, APos);
          ACurrentSeparator := '';
        end;
      else
        begin
          ACurrentSeparator := ACurrentSeparator + ADateFormat[APos];
          Inc(APos);
        end;
      end;
  end;
end;

procedure ScanBlanks(const S: string; var APos: Integer);
var
  I: Integer;
begin
  I := APos;
  while (I <= Length(S)) and (S[I] = ' ') do Inc(I);
  APos := I;
end;

function cxDateToLocalFormatStr(ADate: TDateTime): string;
var
  ATime: TTime;
begin
  cxGetDateFormat(ADate, Result, 0, cxGetLocalShortDateFormat);
  ATime := TimeOf(ADate);
  if ATime > 0 then
    Result := Result + ' ' + TimeToStr(ATime);
end;

function cxDateToStr(ADate: TDateTime): string;
begin
  Result := cxDateToStrByFormat(ADate, ShortDateFormat, DateSeparator);
end;

function cxDateToStr(ADate: TDateTime; AFormat: TFormatSettings): string;
begin
  Result := cxDateToStrByFormat(ADate, AFormat.ShortDateFormat, AFormat.DateSeparator);
end;

function cxDayNumberToLocalFormatStr(ADate: TDateTime): string;
var
  AOldFormatShortDate: string;
begin
  if not cxGetDateFormat(ADate, Result, 0, 'd') then
  begin
    AOldFormatShortDate := ShortDateFormat;
    ShortDateFormat := 'd';
    try
      Result := DateToStr(ADate);
    finally
      ShortDateFormat := AOldFormatShortDate;
    end;
  end;
end;

function cxDayNumberToLocalFormatStr(ADay: Integer; ACalendar: TcxCustomCalendarTable = nil): string;
var
  ADate: TcxDate;
  ANeedFreeAndNilCalendar: Boolean;
begin
  if ACalendar = nil then
  begin
    ACalendar := cxGetLocalCalendar;
    ANeedFreeAndNilCalendar := True;
  end
  else
    ANeedFreeAndNilCalendar := False;
  try
    with ADate do
    begin
      Year := ACalendar.GetMinSupportedYear;
      Month := 1;
      Day := ADay;
    end;
    Result := cxDayNumberToLocalFormatStr(ACalendar.ToDateTime(ADate));
  finally
    if ANeedFreeAndNilCalendar then
      FreeAndNil(ACalendar);
  end;
end;

function cxGetCalendar(ACalendType: CALTYPE): TcxCustomCalendarTable;
begin
  case ACalendType of
    CAL_GREGORIAN, CAL_GREGORIAN_US, CAL_GREGORIAN_ME_FRENCH, CAL_GREGORIAN_ARABIC,
    CAL_GREGORIAN_XLIT_ENGLISH, CAL_GREGORIAN_XLIT_FRENCH:
      begin
        Result := TcxGregorianCalendarTable.Create;
        TcxGregorianCalendarTable(Result).GregorianCalendarType := TcxGregorianCalendarTableType(ACalendType);
      end;
    CAL_JAPAN:
      Result := TcxJapaneseCalendarTable.Create;
    CAL_TAIWAN:
      Result := TcxTaiwanCalendarTable.Create;
    CAL_KOREA:
      Result := TcxKoreanCalendarTable.Create;
    CAL_HIJRI:
      Result := TcxHijriCalendarTable.Create;
    CAL_THAI:
      Result := TcxThaiCalendarTable.Create;
    CAL_HEBREW:
      Result := TcxHebrewCalendarTable.Create;
    else
    begin
      Result := TcxGregorianCalendarTable.Create;
    end;
  end;
end;

function InternalGetLocaleInfo(Locale: LCID; LCType: LCTYPE): string;
var
  ABuf: array [0..255] of Char;
begin
  GetLocaleInfo(Locale, LCType, ABuf, Length(ABuf));
  Result := ABuf;
end;

function cxGetLocalCalendarID: TcxCALID;
begin
  GetLocaleInfo(GetThreadLocale, LOCALE_ICALENDARTYPE or CAL_RETURN_NUMBER,
    @Result, SizeOf(Result));
end;

function cxGetLocalCalendar: TcxCustomCalendarTable;
begin
  Result := cxGetCalendar(cxGetLocalCalendarID);
end;

function cxGetDateSeparator: Char;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_SDATE)[1];
end;

function cxGetLocalFormatSettings: TFormatSettings;
begin
  Result.DateSeparator := cxGetDateSeparator;
  Result.ShortDateFormat := cxGetLocalShortDateFormat;
  Result.LongDateFormat := cxGetLocalLongDateFormat;

  Result.TimeSeparator := cxGetLocalTimeSeparator;
  Result.LongTimeFormat := cxGetLocalLongTimeFormat;
  Result.TimeAMString := cxGetLocalTimeAMString;
  Result.TimePMString := cxGetLocalTimePMString;

  Result.ListSeparator := ListSeparator;
end;

function cxGetLocalLongDateFormat: string;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_SLONGDATE);
end;

function cxGetLocalLongTimeFormat: string;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_STIMEFORMAT);
end;

function cxGetLocalMonthName(ADate: TDateTime; ACalendar: TcxCustomCalendarTable): string;
var
  AFormat: string;
  AConvertDate: TcxDateTime;
begin
  AConvertDate := ACalendar.FromDateTime(ADate);
  AConvertDate.Day := 1;
  AFormat := 'MMMM';
  if (cxIsGregorianCalendar(ACalendar) and cxFormatController.UseDelphiDateTimeFormats) or
      not cxGetDateFormat(ACalendar.ToDateTime(AConvertDate), Result,
      0, AFormat) then
    Result := LongMonthNames[AConvertDate.Month];
end;

function cxGetLocalMonthName(AYear, AMonth: Integer; ACalendar: TcxCustomCalendarTable): string;
var
  ADate: TcxDate;
begin
  if cxIsGregorianCalendar(ACalendar) and cxFormatController.UseDelphiDateTimeFormats then
  begin
    Result := LongMonthNames[AMonth];
  end
  else
  begin
    ADate.Year := AYear;
    ADate.Month := AMonth;
    ADate.Day := 1;
    if ACalendar.IsValidMonth(ADate.Year, ADate.Month) then
      Result := cxGetLocalMonthName(ACalendar.ToDateTime(ADate), ACalendar)
    else
      Result := '';
  end;
end;

function cxGetLocalMonthYear(ADate: TDateTime; ACalendar: TcxCustomCalendarTable = nil): string;
var
  AFormat: string;
  AConvertDate: TcxDateTime;
  ABuf: array [0..255] of Char;
  ANeedFreeAndNilCalendar: Boolean;
begin
  if cxIsGregorianCalendar(ACalendar) and cxFormatController.UseDelphiDateTimeFormats then
  begin
    Result := cxDateToStrByFormat(ADate, 'mmmm yyyy', ' ');
    Exit;
  end;
  if ACalendar = nil then
  begin
    ACalendar := cxGetLocalCalendar;
    ANeedFreeAndNilCalendar := True;
  end
  else
    ANeedFreeAndNilCalendar := False;
  try
    AConvertDate := ACalendar.FromDateTime(ADate);
    AConvertDate.Day := 1;
    cxGetCalendarInfo(GetThreadLocale, ACalendar.GetCalendarID, CAL_SYEARMONTH, ABuf, Length(ABuf), nil);
    AFormat := ABuf;
    if not cxGetDateFormat(ACalendar.ToDateTime(AConvertDate), Result, 0, AFormat) then
      Result := cxGetLocalMonthName(AConvertDate.Year, AConvertDate.Month, ACalendar) + ' ' +
        cxGetLocalYear(ADate, ACalendar);
  finally
    if ANeedFreeAndNilCalendar then
      FreeAndNil(ACalendar);
  end;
end;

function cxGetLocalShortDateFormat: string;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_SSHORTDATE);
end;

function cxGetLocalTimeAMString: string;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_S1159);
end;

function cxGetLocalTimePMString: string;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_S2359);
end;

function cxGetLocalTimeSeparator: Char;
begin
  Result := InternalGetLocaleInfo(GetThreadLocale, LOCALE_STIME)[1];
end;

function cxGetLocalYear(ADate: TDateTime; ACalendar: TcxCustomCalendarTable = nil): string;
var
  AFormat: string;
  AConvertDate: TcxDateTime;
  ANeedFreeAndNilCalendar: Boolean;
begin
  if ACalendar = nil then
  begin
    ACalendar := cxGetLocalCalendar;
    ANeedFreeAndNilCalendar := True;
  end
  else
    ANeedFreeAndNilCalendar := False;
  try
    AConvertDate := ACalendar.FromDateTime(ADate);
    AConvertDate.Day := 1;
    AFormat := 'yyyy';
    if not cxGetDateFormat(ACalendar.ToDateTime(AConvertDate), Result,
        0, AFormat) then
      Result := IntToStr(AConvertDate.Year);
  finally
    if ANeedFreeAndNilCalendar then
      FreeAndNil(ACalendar);
  end;
end;

function cxGetDayOfWeekName(I: Integer; AFontCharset: TFontCharset): string;
const
  cxDayNameLCType: array [Boolean, 1..7] of Cardinal =
    ((LOCALE_SABBREVDAYNAME1, LOCALE_SABBREVDAYNAME2, LOCALE_SABBREVDAYNAME3,
    LOCALE_SABBREVDAYNAME4, LOCALE_SABBREVDAYNAME5, LOCALE_SABBREVDAYNAME6,
    LOCALE_SABBREVDAYNAME7),
    (CAL_SSHORTESTDAYNAME1, CAL_SSHORTESTDAYNAME2, CAL_SSHORTESTDAYNAME3,
    CAL_SSHORTESTDAYNAME4, CAL_SSHORTESTDAYNAME5, CAL_SSHORTESTDAYNAME6,
    CAL_SSHORTESTDAYNAME7));
begin
  if (I < 1) or (I > 7) then
  begin
    Result := '';
    Exit;
  end;
  if cxIsGregorianCalendar and cxFormatController.UseDelphiDateTimeFormats then
  begin
    Inc(I);
    if I > 7 then
      Dec(I, 7);
    Result := ShortDayNames[I];
  end
  else
    Result := InternalGetLocaleInfo(GetThreadLocale, cxDayNameLCType[IsWinVista, I]);
  if cxUseSingleCharWeekNames then
    if cxGetWritingDirection(AFontCharset, Result) = coRightToLeft then
      Result := AnsiLastChar(Result)
    else
    begin
      Result := WideString(Result)[1];
    end;
end;

function cxIsGregorianCalendar(ACalendar: TcxCustomCalendarTable = nil): Boolean;
var
  ANeedFreeAndNilCalendar: Boolean;
begin
  if ACalendar = nil then
  begin
    ACalendar := cxGetLocalCalendar;
    ANeedFreeAndNilCalendar := True;
  end
  else
    ANeedFreeAndNilCalendar := False;
  try
    Result := ACalendar.GetCalendarID in [CAL_GREGORIAN, CAL_GREGORIAN_US, CAL_GREGORIAN_ME_FRENCH,
      CAL_GREGORIAN_ARABIC, CAL_GREGORIAN_XLIT_ENGLISH, CAL_GREGORIAN_XLIT_FRENCH];
  finally
    if ANeedFreeAndNilCalendar then
      FreeAndNil(ACalendar);
  end;
end;

function cxLocalFormatStrToDate(const ADateStr: string): TDateTime;
var
  D: TcxDateTime;
  ACalendar: TcxCustomCalendarTable;
begin
  case cxGetLocalCalendarID of
    CAL_JAPAN, CAL_TAIWAN, CAL_KOREA, CAL_HIJRI, CAL_THAI, CAL_HEBREW:
      begin
        ACalendar := cxGetLocalCalendar;
        try
          D := cxStrToDate(ADateStr, ACalendar);
          Result := ACalendar.ToDateTime(D);
        finally
          FreeAndNil(ACalendar);
        end;
      end;
    else
      TextToDateEx(ADateStr, Result);
  end;
end;

function cxStrToDate(const ADateStr: string;
  ACalendar: TcxCustomCalendarTable = nil): TcxDateTime;
begin
  Result := cxStrToDate(ADateStr, cxGetLocalFormatSettings, ACalendar);
end;

function cxStrToDate(const ADateStr: string;
  AFormat: TFormatSettings;
  ACalendar: TcxCustomCalendarTable = nil): TcxDateTime; overload;
var
  APart1, APart2, APart3: string;
  H, M, S, MS: Word;
  ATime: TTime;
  APos: Integer;
  ANeedFreeAndNilCalendar: Boolean;
  AEraName : string;
  AEraYearOffset: Integer;

  function GetEraYearOffset(const Name: string): Integer;
  var
    I: Integer;
  begin
    Result := 0;
    for I := Low(EraNames) to High(EraNames) do
    begin
      if EraNames[I] = '' then Break;
      if AnsiStrPos(PChar(EraNames[I]), PChar(Name)) <> nil then
      begin
        Result := EraYearOffsets[I];
        Exit;
      end;
    end;
  end;

  procedure ScanToNumber(const S: string; var Pos: Integer);
  begin
    while (Pos <= Length(S)) and not dxCharInSet(S[Pos], ['0'..'9']) do
    begin
      if dxCharInSet(S[Pos], LeadBytes) then
        Pos := NextCharIndex(S, Pos)
      else
        Inc(Pos);
    end;
  end;

  function ScanPart(AEndScan: Char): string;
  begin
    Result := '';
    Inc(APos);
    while (APos <= Length(ADateStr)) and (ADateStr[APos] <> AEndScan) do
    begin
      Result := Result + ADateStr[APos];
      Inc(APos);
    end;
  end;

  function NeedMoreScanMonthStr: Boolean;
  begin
    ScanBlanks(ADateStr, APos);
    Result := (AFormat.DateSeparator = ' ') and
      ((APos < Length(ADateStr)) and not dxCharInSet(ADateStr[APos], ['0'..'9']));
  end;

begin
  APos := 0;
  AEraYearOffset := 0;
  if (AFormat.ShortDateFormat <> '') and (AFormat.ShortDateFormat[1] = 'g') then  // skip over prefix text
  begin
    ScanToNumber(ADateStr, APos);
    AEraName := Trim(Copy(ADateStr, 1, APos-1));
    AEraYearOffset := GetEraYearOffset(AEraName);
    Dec(APos);
  end
  else
    if AnsiPos('e', AFormat.ShortDateFormat) > 0 then
      AEraYearOffset := EraYearOffsets[1];
  APart1 := ScanPart(AFormat.DateSeparator);
  APart2 := ScanPart(AFormat.DateSeparator);
  APart3 := ScanPart(' ');
  Result.Era := -1;
  if ACalendar = nil then
  begin
    ACalendar := cxGetLocalCalendar;
    ANeedFreeAndNilCalendar := True;
  end
  else
    ANeedFreeAndNilCalendar := False;
  try
    case GetDateOrder(AFormat.ShortDateFormat) of
      doMDY:
        begin
          if NeedMoreScanMonthStr then
          begin
            APart1 := APart1 + ' ' + APart2;
            APart2 := APart3;
            Dec(APos);
            APart3 := ScanPart(' ');
          end;
          Result.Year := ACalendar.GetYearNumber(APart3);
          Result.Month := ACalendar.GetMonthNumber(Result.Year, APart1);
          Result.Day := ACalendar.GetDayNumber(APart2);
        end;
      doDMY:
        begin
          if NeedMoreScanMonthStr then
          begin
            APart2 := APart2 + ' ' + APart3;
            Dec(APos);
            APart3 := ScanPart(' ');
          end;
          Result.Year := ACalendar.GetYearNumber(APart3);
          Result.Month := ACalendar.GetMonthNumber(Result.Year, APart2);
          Result.Day := ACalendar.GetDayNumber(APart1);
        end;
      doYMD:
        begin
          if NeedMoreScanMonthStr then
          begin
            APart2 := APart2 + ' ' + APart3;
            Dec(APos);
            APart3 := ScanPart(' ');
          end;
          Result.Year := ACalendar.GetYearNumber(APart1);
          Result.Month := ACalendar.GetMonthNumber(Result.Year, APart2);
          Result.Day := ACalendar.GetDayNumber(APart3);
        end;
    end;
    Result.Era := ACalendar.GetEra(AEraYearOffset + 1);
  finally
    if ANeedFreeAndNilCalendar then
      FreeAndNil(ACalendar);
  end;
  H := 0;
  M := 0;
  S := 0;
  MS := 0;
  if APos < Length(ADateStr) then
  begin
    ATime := StrToTime(Copy(ADateStr, APos, Length(ADateStr) - APos + 1));
    DecodeTime(ATime, H, M, S, MS);
  end;
  with Result do
  begin
    Hours := H;
    Minutes := M;
    Seconds := S;
    Milliseconds := MS;
  end;
end;

function cxStrToDate(const ADateString: string; const AFormat: TFormatSettings;
  ACALTYPE: CALTYPE): TDate;
var
  ACalendar: TcxCustomCalendarTable;
  ADate: TcxDateTime;
begin
  ACalendar := cxGetCalendar(ACALTYPE);
  try
    ADate := cxStrToDate(ADateString, AFormat, ACalendar);
    Result := ACalendar.ToDateTime(ADate);
  finally
    FreeAndNil(ACalendar);
  end;
end;

function cxTimeToStr(ATime: TDateTime): string;
begin
  Result := cxTimeToStr(ATime, cxGetLocalFormatSettings);
end;

function cxTimeToStr(ATime: TDateTime; ATimeFormat: string): string;
var
  AFormatSettings: TFormatSettings;
begin
  AFormatSettings := cxGetLocalFormatSettings;
  with AFormatSettings do
  begin
    LongTimeFormat := ATimeFormat;
    TimeSeparator := SysUtils.TimeSeparator;
  end;
  Result := cxTimeToStr(ATime, AFormatSettings);
end;

function cxTimeToStr(ATime: TDateTime; AFormatSettings: TFormatSettings): string;
begin
  DateTimeToString(Result, AFormatSettings.LongTimeFormat, TimeOf(ATime));
end;

function cxGetCalendarInfo(Locale: LCID; Calendar: CALID;
  CalendType: CALTYPE; lpCalData: PChar; cchData: Integer;
  lpValue: PDWORD): Integer;
var
  AKernelDLL : Integer;
  AGetCalendarInfo: TcxGetCalendarInfo;
begin
  Result:= 0;
  AKernelDLL:= LoadLibrary('Kernel32');
  if AKernelDLL <> 0 then
  try
  {$IFDEF DELPHI12}
    AGetCalendarInfo := GetProcAddress(AKernelDll, 'GetCalendarInfoW');
  {$ELSE}
    AGetCalendarInfo := GetProcAddress(AKernelDll, 'GetCalendarInfoA');
  {$ENDIF}
    if Assigned(AGetCalendarInfo) then
      Result:= AGetCalendarInfo(Locale, Calendar, CalendType,
        lpCalData, cchData, lpValue);
  finally
    FreeLibrary(AKernelDLL);
  end;
end;

function cxGetLocaleChar(ALocaleType: Integer; const ADefaultValue: Char): string;
begin
  Result := cxGetLocaleInfo(GetThreadLocale, ALocaleType, ADefaultValue)[1];
end;

function cxGetLocaleStr(ALocaleType: Integer; const ADefaultValue: string = ''): string;
begin
  Result := cxGetLocaleInfo(GetThreadLocale, ALocaleType, ADefaultValue);
end;

procedure CorrectTextForDateTimeConversion(var AText: string;
  AOleConversion: Boolean);

  procedure InternalStringReplace(var S: WideString; ASubStr: WideString);
  begin
    S := StringReplace(S, ASubStr, GetCharString(' ', Length(ASubStr)),
      [rfIgnoreCase, rfReplaceAll]);
  end;

  procedure GetSpecialStrings(AList: TStringList);
  var
    I: Integer;
  begin
    if AOleConversion then
    begin
      AList.Add(cxGetLocaleStr(LOCALE_SDATE)[1]);
      AList.Add(cxGetLocaleStr(LOCALE_STIME)[1]);
      AList.Add(cxGetLocaleStr(LOCALE_S1159, 'am'));
      AList.Add(cxGetLocaleStr(LOCALE_S2359, 'pm'));
    end
    else
    begin
      AList.Add(DateSeparator);
      AList.Add(TimeSeparator);
      AList.Add(TimeAMString);
      AList.Add(TimePMString);
    end;
    for I := 0 to AList.Count - 1 do
      AList[I] := AnsiUpperCase(Trim(AList[I]));
  end;

  procedure RemoveStringsThatInFormatInfo(var S: WideString;
    const ADateTimeFormatInfo: TcxDateTimeFormatInfo);
  var
    ASpecialStrings: TStringList;
    ASubStr: string;
    I: Integer;
  begin
    ASpecialStrings := TStringList.Create;
    try
      GetSpecialStrings(ASpecialStrings);
      for I := 0 to High(ADateTimeFormatInfo.Items) do
        if ADateTimeFormatInfo.Items[I].Kind = dtikString then
        begin
          ASubStr := AnsiUpperCase(Trim(ADateTimeFormatInfo.Items[I].Data));
          if (ASubStr <> '') and (ASpecialStrings.IndexOf(ASubStr) = -1) then
            InternalStringReplace(S, ASubStr);
        end;
    finally
      ASpecialStrings.Free;
    end;
  end;

  procedure RemoveUnnecessarySpaces(var S: WideString);
  var
    I: Integer;
  begin
    S := Trim(S);
    I := 2;
    while I < Length(S) - 1 do
      if (S[I] <= ' ') and (S[I + 1] <= ' ') then
        Delete(S, I, 1)
      else
        Inc(I);
  end;

var
  S: WideString;
begin
  S := AText;
  RemoveStringsThatInFormatInfo(S, cxFormatController.DateFormatInfo);
  RemoveStringsThatInFormatInfo(S, cxFormatController.TimeFormatInfo);
  RemoveUnnecessarySpaces(S);
  if AOleConversion then
    InternalStringReplace(S, cxGetLocaleStr(LOCALE_SDATE)[1]);
  AText := S;
end;

procedure InitSmartInputConsts;
begin
  scxDateEditSmartInput[deiToday] := cxGetResourceString(@cxSDateToday);
  scxDateEditSmartInput[deiYesterday] := cxGetResourceString(@cxSDateYesterday);
  scxDateEditSmartInput[deiTomorrow] := cxGetResourceString(@cxSDateTomorrow);
  scxDateEditSmartInput[deiSunday] := cxGetResourceString(@cxSDateSunday);
  scxDateEditSmartInput[deiMonday] := cxGetResourceString(@cxSDateMonday);
  scxDateEditSmartInput[deiTuesday] := cxGetResourceString(@cxSDateTuesday);
  scxDateEditSmartInput[deiWednesday] := cxGetResourceString(@cxSDateWednesday);
  scxDateEditSmartInput[deiThursday] := cxGetResourceString(@cxSDateThursday);
  scxDateEditSmartInput[deiFriday] := cxGetResourceString(@cxSDateFriday);
  scxDateEditSmartInput[deiSaturday] := cxGetResourceString(@cxSDateSaturday);
  scxDateEditSmartInput[deiFirst] := cxGetResourceString(@cxSDateFirst);
  scxDateEditSmartInput[deiSecond] := cxGetResourceString(@cxSDateSecond);
  scxDateEditSmartInput[deiThird] := cxGetResourceString(@cxSDateThird);
  scxDateEditSmartInput[deiFourth] := cxGetResourceString(@cxSDateFourth);
  scxDateEditSmartInput[deiFifth] := cxGetResourceString(@cxSDateFifth);
  scxDateEditSmartInput[deiSixth] := cxGetResourceString(@cxSDateSixth);
  scxDateEditSmartInput[deiSeventh] := cxGetResourceString(@cxSDateSeventh);
  scxDateEditSmartInput[deiBOM] := cxGetResourceString(@cxSDateBOM);
  scxDateEditSmartInput[deiEOM] := cxGetResourceString(@cxSDateEOM);
  scxDateEditSmartInput[deiNow] := cxGetResourceString(@cxSDateNow);
end;

procedure AddDateRegExprMaskSmartInput(var AMask: string; ACanEnterTime: Boolean);

  procedure AddString(var AMask: string; const S: string);
  var
    I: Integer;
  begin
    I := 1;
    while I <= Length(S) do
      if S[I] = '''' then
      begin
        AMask := AMask + '\''';
        Inc(I);
      end
      else
      begin
        AMask := AMask + '''';
        repeat
          AMask := AMask + S[I];
          Inc(I);
        until (I > Length(S)) or (S[I] = '''');
        AMask := AMask + '''';
      end;
  end;

var
  I: TcxDateEditSmartInput;
begin
  InitSmartInputConsts;
  AMask := '(' + AMask + ')|(';
  I := Low(TcxDateEditSmartInput);
  if not ACanEnterTime and (I = deiNow) then
    Inc(I);
  AddString(AMask, scxDateEditSmartInput[I]);
  while I < High(TcxDateEditSmartInput) do
  begin
    Inc(I);
    if not(not ACanEnterTime and (I = deiNow)) then
    begin
      AMask := AMask + '|';
      AddString(AMask, scxDateEditSmartInput[I]);
    end;
  end;
  AMask := AMask + ')((\+|-)\d(\d(\d\d?)?)?)?';
end;

procedure DecMonth(var AYear, AMonth: Word);
begin
  if AMonth = 1 then
  begin
    Dec(AYear);
    AMonth := 12;
  end
  else Dec(AMonth);
end;

procedure IncMonth(var AYear, AMonth: Word);
begin
  if AMonth = 12 then
  begin
    Inc(AYear);
    AMonth := 1;
  end
  else Inc(AMonth);
end;

procedure ChangeMonth(var AYear, AMonth: Word; Delta: Integer);
var
  Month: Integer;
begin
  Inc(AYear, Delta div 12);
  Month := AMonth;
  Inc(Month, Delta mod 12);
  if Month < 1 then
  begin
    Dec(AYear);
    Month := 12 + Month;
  end;
  if Month > 12 then
  begin
    Inc(AYear);
    Month := Month - 12;
  end;
  AMonth := Month;
end;

function GetMonthNumber(const ADate: TDateTime): Integer;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(ADate, AYear, AMonth, ADay);
  Result := (AYear - 1) * 12 + AMonth;
end;

function GetDateElement(ADate: TDateTime; AElement: TcxDateElement;
  ACalendar: TcxCustomCalendarTable = nil): Integer;
var
  ACalendarDate: TcxDateTime;
  AYear, AMonth, ADay: Word;
begin
  if ACalendar = nil then
    DecodeDate(ADate, AYear, AMonth, ADay)
  else
  begin
    ACalendarDate := ACalendar.FromDateTime(ADate);
    with ACalendarDate do
    begin
      AYear := Year;
      AMonth := Month;
      ADay := Day;
    end;
  end;
  case AElement of
    deYear:
      Result := AYear;
    deMonth:
      Result := AMonth;
    else
      Result := ADay;
  end;
end;

function IsLeapYear(AYear: Integer): Boolean;
begin
  Result := (AYear mod 4 = 0) and ((AYear mod 100 <> 0) or (AYear mod 400 = 0));
end;

function DaysPerMonth(AYear, AMonth: Integer): Integer;
const
  ADaysInMonth: array[1..12] of Integer = (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
begin
  Result := ADaysInMonth[AMonth];
  if (AMonth = 2) and IsLeapYear(AYear) then Inc(Result);
end;

function CheckDay(AYear, AMonth, ADay: Integer): Integer;
begin
  if ADay < 1 then
    Result := 1
  else
    if ADay > DaysPerMonth(AYear, AMonth) then
      Result := DaysPerMonth(AYear, AMonth)
    else
      Result := ADay;
end;

function TimeOf(const AValue: TDateTime): TDateTime;
begin
  Result := DateTimeToTimeStamp(AValue).Time / MSecsPerDay;
end;

function DateOf(const AValue: TDateTime): TDateTime;
begin
  Result := DateTimeToTimeStamp(AValue).Date - DateDelta;
end;

function DayOfWeekOffset(const AValue: TDateTime): TDayOfWeek;
var
  AOffset: Integer;
begin
  AOffset := DayOfWeek(AValue) - 1 - cxFormatController.StartOfWeek;
  if AOffset < 0 then
    Inc(AOffset, 7);
  Result := AOffset;
end;

function GetStartDateOfMonth(const ADate: TDateTime): TDateTime;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(ADate, AYear, AMonth, ADay);
  Result := EncodeDate(AYear, AMonth, 1);
end;

function GetStartOfWeek: Integer;
begin
  Result := StrToInt(cxGetLocaleInfo(GetThreadLocale, LOCALE_IFIRSTDAYOFWEEK, '0')) + 1;
  if Result > 6 then
    Result := 0;
end;

function GetEndDateOfMonth(const ADate: TDateTime; AIgnoreTime: Boolean): TDateTime;
var
  AYear, AMonth, ADay: Word;
begin
  DecodeDate(ADate, AYear, AMonth, ADay);
  Result := EncodeDate(AYear, AMonth, MonthDays[IsLeapYear(AYear), AMonth]);
  if not AIgnoreTime then
    Result := Result + EncodeTime(23, 59, 59, 999);
end;

function GetStartDateOfYear(const ADate: TDateTime): TDateTime;
begin
  Result := EncodeDate(GetDateElement(ADate, deYear), 1, 1);
end;

function GetEndDateOfYear(const ADate: TDateTime; AIgnoreTime: Boolean): TDateTime;
begin
  Result := EncodeDate(GetDateElement(ADate, deYear), 12, 31);
  if not AIgnoreTime then
    Result := Result + EncodeTime(23, 59, 59, 999);
end;

{!!! TODO: adapt to .net}
function cxGetDateFormat(ADate: TDateTime; out AFormatDate: string; AFlags: Integer; AFormat: string = ''): Boolean;
var
  L: Integer;
  P: PChar;
  ASystemDate: TSystemTime;
  Buffer: array[0..255] of Char;
begin
  if cxIsGregorianCalendar and cxFormatController.UseDelphiDateTimeFormats then
  begin
    Result := True;
    if Length(AFormat) = 0 then
      AFormatDate := cxDateToStrByFormat(ADate, LongDateFormat, #0)
    else
      AFormatDate := cxDateToStrByFormat(ADate, AFormat, #0);
  end
  else
  begin
    DateTimeToSystemTime(ADate, ASystemDate);
    if Length(AFormat) = 0 then P := nil else P := PChar(AFormat);
    L := GetDateFormat(GetThreadLocale, AFlags, @ASystemDate, P, Buffer, Length(Buffer));
    Result := L > 0;
    if Result then SetString(AFormatDate, Buffer, L - 1) else AFormatDate := '';
  end;
end;

function DateToLongDateStr(ADate: TDateTime): string;
begin
  if not cxGetDateFormat(ADate, Result, DATE_LONGDATE) then
    Result := FormatDateTime('dddddd', Date);
end;

function GetWeekNumber(ADate: TDateTime; AStartOfWeek: TDay;
  AFirstWeekOfYear: TcxFirstWeekOfYear): Integer;

  function FindFirstDayOfWeekDate(ADate: TDateTime): TDateTime;
  var
    ADayOfWeek: TDay;
    ADelta: Integer;
  begin
    ADayOfWeek := TDay(DayOfWeek(ADate) - 1);
    ADelta := Ord(ADayOfWeek) - Ord(AStartOfWeek);
    if ADelta < 0 then Inc(ADelta, 7);
    Result := Trunc(ADate) - ADelta;
  end;

var
  AYear, AMonth, ADay: Word;
  AStartWeekDate: TDateTime;
  AStart: TDateTime;
begin
  if AFirstWeekOfYear = fwySystem then
    AFirstWeekOfYear := TcxFirstWeekOfYear(
      StrToInt(cxGetLocaleChar(LOCALE_IFIRSTWEEKOFYEAR, '0')) + 1);
  AStart := FindFirstDayOfWeekDate(StartOfTheYear(ADate));
  DecodeDate(ADate, AYear, AMonth, ADay);
  case AFirstWeekOfYear of
    fwyFirstFourDays:
      if YearOf(AStart + 3) < AYear then AStart := AStart + 7;
    fwyFirstFullWeek:
      if YearOf(AStart) < AYear then AStart := AStart + 7;
  end;
  //DELPHI8! check Trunc()
  Result := Trunc(Trunc(ADate) - AStart) div 7 + 1;
  if AMonth = 12 then
  begin
    AStartWeekDate := FindFirstDayOfWeekDate(ADate);
    case AFirstWeekOfYear of
      fwyJan1:
        if MonthOf(AStartWeekDate + 6) = 1 then
          Result := 1;
      fwyFirstFourDays:
        if MonthOf(AStartWeekDate + 3) = 1 then
          Result := 1;
    end;
  end;
end;

{$IFNDEF DELPHI6}
function HourOf(ADateTime: TDateTime): Word;
var
  AMin, ASec, AMilliSec: Word;
begin
  DecodeTime(ADateTime, Result, AMin, ASec, AMilliSec);
end;

function IsPM(const AValue: TDateTime): Boolean;
begin
  Result := HourOf(AValue) >= 12;
end;

function DaysInAMonth(const AYear, AMonth: Word): Word;
begin
  Result := MonthDays[(AMonth = 2) and IsLeapYear(AYear), AMonth];
end;

function DaysInMonth(const AValue: TDateTime): Word;
begin
  Result := DaysInAMonth(YearOf(AValue), MonthOf(AValue));
end;

function DayOf(const AValue: TDateTime): Word;
var
  AYear, AMonth: Word;
begin
  DecodeDate(AValue, AYear, AMonth, Result);
end;

function DayOfTheMonth(const AValue: TDateTime): Word;
begin
  Result := DayOf(AValue);
end;

function DayOfTheWeek(const AValue: TDateTime): Word;
begin
  Result := (DateTimeToTimeStamp(AValue).Date - 1) mod 7 + 1;
end;

procedure DecodeDateTime(const AValue: TDateTime; out AYear, AMonth, ADay,
  AHour, AMinute, ASecond, AMilliSecond: Word);
begin
  DecodeDate(AValue, AYear, AMonth, ADay);
  DecodeTime(AValue, AHour, AMinute, ASecond, AMilliSecond);
end;

function EncodeDateTime(const AYear, AMonth, ADay, AHour, AMinute, ASecond,
  AMilliSecond: Word): TDateTime;
begin
  Result := EncodeDate(AYear, AMonth, ADay) +
    EncodeTime(AHour, AMinute, ASecond, AMilliSecond);
end;

procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
var
  DayTable: PDayTable;
  Sign: Integer;
begin
  if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
  Year := Year + (NumberOfMonths div 12);
  NumberOfMonths := NumberOfMonths mod 12;
  Inc(Month, NumberOfMonths);
  if Word(Month-1) > 11 then    // if Month <= 0, word(Month-1) > 11)
  begin
    Inc(Year, Sign);
    Inc(Month, -12 * Sign);
  end;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if Day > DayTable^[Month] then Day := DayTable^[Month];
end;

function MinuteOf(const AValue: TDateTime): Word;
var
  AHour, ASecond, AMilliSecond: Word;
begin
  DecodeTime(AValue, AHour, Result, ASecond, AMilliSecond);
end;

function MonthOf(const AValue: TDateTime): Word;
var
  AYear, ADay: Word;
begin
  DecodeDate(AValue, AYear, Result, ADay);
end;

function StartOfTheYear(const AValue: TDateTime): TDateTime;
begin
  Result := EncodeDate(YearOf(AValue), 1, 1);
end;

function StartOfTheMonth(const AValue: TDateTime): TDateTime;
begin
  Result := EncodeDate(YearOf(AValue), MonthOf(AValue), 1);
end;

function YearOf(const AValue: TDateTime): Word;
var
  AMonth, ADay: Word;
begin
  DecodeDate(AValue, Result, AMonth, ADay);
end;

const
  DayMap: array [1..7] of Word = (7, 1, 2, 3, 4, 5, 6);

procedure DivMod(Dividend: Integer; Divisor: Word;
  var Result, Remainder: Word);
asm
        PUSH    EBX
        MOV     EBX,EDX
        MOV     EDX,EAX
        SHR     EDX,16
        DIV     BX
        MOV     EBX,Remainder
        MOV     [ECX],AX
        MOV     [EBX],DX
        POP     EBX
end;

function DecodeDateFully(const DateTime: TDateTime; var Year, Month, Day, DOW: Word): Boolean;
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var
  Y, M, D, I: Word;
  T: Integer;
  DayTable: PDayTable;
begin
  T := DateTimeToTimeStamp(DateTime).Date;
  if T <= 0 then
  begin
    Year := 0;
    Month := 0;
    Day := 0;
    DOW := 0;
    Result := False;
  end else
  begin
    DOW := T mod 7 + 1;
    Dec(T);
    Y := 1;
    while T >= D400 do
    begin
      Dec(T, D400);
      Inc(Y, 400);
    end;
    DivMod(T, D100, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    DivMod(D, D4, I, D);
    Inc(Y, I * 4);
    DivMod(D, D1, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    Result := IsLeapYear(Y);
    DayTable := @MonthDays[Result];
    M := 1;
    while True do
    begin
      I := DayTable^[M];
      if D < I then Break;
      Dec(D, I);
      Inc(M);
    end;
    Year := Y;
    Month := M;
    Day := D + 1;
  end;
end;

procedure DecodeDateWeek(const AValue: TDateTime; out AYear, AWeekOfYear,
  ADayOfWeek: Word);
var
  ADayOfYear: Integer;
  AMonth, ADay: Word;
  AStart: TDateTime;
  AStartDayOfWeek, AEndDayOfWeek: Word;
  ALeap: Boolean;
begin
  ALeap := DecodeDateFully(AValue, AYear, AMonth, ADay, ADayOfWeek);
  ADayOfWeek := DayMap[ADayOfWeek];
  AStart := EncodeDate(AYear, 1, 1);
  ADayOfYear := Trunc(AValue - AStart + 1);
  AStartDayOfWeek := DayOfTheWeek(AStart);
  if AStartDayOfWeek in [DayFriday, DaySaturday, DaySunday] then
    Dec(ADayOfYear, 8 - AStartDayOfWeek)
  else
    Inc(ADayOfYear, AStartDayOfWeek - 1);
  if ADayOfYear <= 0 then
    DecodeDateWeek(AStart - 1, AYear, AWeekOfYear, ADay)
  else
  begin
    AWeekOfYear := ADayOfYear div 7;
    if ADayOfYear mod 7 <> 0 then
      Inc(AWeekOfYear);
    if AWeekOfYear > 52 then
    begin
      AEndDayOfWeek := AStartDayOfWeek;
      if ALeap then
      begin
        if AEndDayOfWeek = DaySunday then
          AEndDayOfWeek := DayMonday
        else
          Inc(AEndDayOfWeek);
      end;
      if AEndDayOfWeek in [DayMonday, DayTuesday, DayWednesday] then
      begin
        Inc(AYear);
        AWeekOfYear := 1;
      end;
    end;
  end;
end;

function EncodeDateWeek(const AYear, AWeekOfYear: Word;
  const ADayOfWeek: Word): TDateTime; 
var
  ADayOfYear: Integer;
  AStartDayOfWeek: Word;
begin
  Result := EncodeDate(AYear, 1, 1);
  AStartDayOfWeek := DayOfTheWeek(Result);
  ADayOfYear := (AWeekOfYear - 1) * 7 + ADayOfWeek - 1;
  if AStartDayOfWeek in [DayFriday, DaySaturday, DaySunday] then
    Inc(ADayOfYear, 8 - AStartDayOfWeek)
  else
    Dec(ADayOfYear, AStartDayOfWeek - 1);
  Result := Result + ADayOfYear;
end;

function SpanOfNowAndThen(const ANow, AThen: TDateTime): TDateTime;
begin
  if ANow < AThen then
    Result := AThen - ANow
  else
    Result := ANow - AThen;
end;

function DaySpan(const ANow, AThen: TDateTime): Double;
begin
  Result := SpanOfNowAndThen(ANow, AThen);
end;

function YearSpan(const ANow, AThen: TDateTime): Double;
begin
  Result := DaySpan(ANow, AThen) / ApproxDaysPerYear;
end;

function MonthSpan(const ANow, AThen: TDateTime): Double;
begin
  Result := DaySpan(ANow, AThen) / ApproxDaysPerMonth;
end;

function WeekSpan(const ANow, AThen: TDateTime): Double;
begin
  Result := DaySpan(ANow, AThen) / DaysPerWeek;
end;

function YearsBetween(const ANow, AThen: TDateTime): Integer;
begin
  Result := Trunc(YearSpan(ANow, AThen));
end;

function MonthsBetween(const ANow, AThen: TDateTime): Integer;
begin
  Result := Trunc(MonthSpan(ANow, AThen));
end;

function WeeksBetween(const ANow, AThen: TDateTime): Integer;
begin
  Result := Trunc(WeekSpan(ANow, AThen));
end;

function DaysBetween(const ANow, AThen: TDateTime): Integer;
begin
  Result := Trunc(DaySpan(ANow, AThen));
end;

function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  IncAMonth(Year, Month, Day, NumberOfMonths);
  Result := EncodeDate(Year, Month, Day);
  ReplaceTime(Result, DateTime);
end;

function IncYear(const AValue: TDateTime;
  const ANumberOfYears: Integer): TDateTime;
begin
  Result := IncMonth(AValue, ANumberOfYears * MonthsPerYear);
end;

function IncWeek(const AValue: TDateTime;
  const ANumberOfWeeks: Integer): TDateTime;
begin
  Result := AValue + ANumberOfWeeks * DaysPerWeek;
end;

function IncDay(const AValue: TDateTime;
  const ANumberOfDays: Integer): TDateTime;
begin
  Result := AValue + ANumberOfDays;
end;

function IncHour(const AValue: TDateTime; const ANumberOfHours: Int64): TDateTime;
begin
  Result := ((AValue * HoursPerDay) + ANumberOfHours) / HoursPerDay;
end;

function IncMinute(const AValue: TDateTime; const ANumberOfMinutes: Int64): TDateTime;
begin
  Result := ((AValue * MinsPerDay) + ANumberOfMinutes) / MinsPerDay;
end;

procedure DecodeDateMonthWeek(const AValue: TDateTime;
  out AYear, AMonth, AWeekOfMonth, ADayOfWeek: Word);
var
  LDay, LDaysInMonth: Word;
  LDayOfMonth: Integer;
  LStart: TDateTime;
  LStartDayOfWeek, LEndOfMonthDayOfWeek: Word;
begin
  DecodeDateFully(AValue, AYear, AMonth, LDay, ADayOfWeek);
  ADayOfWeek := DayMap[ADayOfWeek]; 
  LStart := EncodeDate(AYear, AMonth, 1);
  LStartDayOfWeek := DayOfTheWeek(LStart);
  LDayOfMonth := LDay;
  if LStartDayOfWeek in [DayFriday, DaySaturday, DaySunday] then
    Dec(LDayOfMonth, 8 - LStartDayOfWeek)
  else
    Inc(LDayOfMonth, LStartDayOfWeek - 1);
  if LDayOfMonth <= 0 then
    DecodeDateMonthWeek(LStart - 1, AYear, AMonth, AWeekOfMonth, LDay)
  else
  begin
    AWeekOfMonth := LDayOfMonth div 7;
    if LDayOfMonth mod 7 <> 0 then
      Inc(AWeekOfMonth);
    LDaysInMonth := DaysInAMonth(AYear, AMonth);
    LEndOfMonthDayOfWeek := DayOfTheWeek(EncodeDate(AYear, AMonth, LDaysInMonth));
    if (LEndOfMonthDayOfWeek in [DayMonday, DayTuesday, DayWednesday]) and
       (LDaysInMonth - LDay < LEndOfMonthDayOfWeek) then
    begin
      Inc(AMonth);
      if AMonth = 13 then
      begin
        AMonth := 1;
        Inc(AYear);
      end;
      AWeekOfMonth := 1;
    end;
  end;
end;

function WeekOfTheMonth(const AValue: TDateTime): Word;
var
  LYear, LMonth, LDayOfWeek: Word;
begin
  DecodeDateMonthWeek(AValue, LYear, LMonth, Result, LDayOfWeek);
end;

function WeekOf(AValue: TDateTime): Word;
var
  AYear, ADay: Word;
begin
  DecodeDateWeek(AValue, AYear, Result, ADay);
end;

function WeekOfTheYear(const AValue: TDateTime): Word;
var
  AYear, ADayOfWeek: Word;
begin
  DecodeDateWeek(AValue, AYear, Result, ADayOfWeek);
end;

function DayOfTheYear(AValue: TDateTime): Word;
begin
  Result := Trunc(AValue - StartOfTheYear(AValue)) + 1;
end;

function EndOfTheYear(AValue: TDateTime): TDateTime;
begin
  Result := EncodeDateTime(YearOf(AValue), 12, 31, 23, 59, 59, 999)
end;
{$ENDIF}

function StrToDateDef(const ADateStr: string; ADefDate: TDateTime): TDateTime;
begin
  try
    Result := StrToDate(ADateStr)
  except
    Result := ADefDate
  end;
end;

function SICompare(List: TStringList; Index1, Index2: Integer): Integer;
var
  S1, S2: string;
begin
  S1 := List[Index1];
  S2 := List[Index2];
  if Length(S1) > Length(S2) then
    Result := -1
  else
    if Length(S1) < Length(S2) then
      Result := 1
    else
      Result := -AnsiCompareText(S1, S2);
end;

function SmartTextToDate(const AText: string; var ADate: TDateTime): Boolean;

  function GetSmartInputKind(const AText: string;
    var Kind: TcxDateEditSmartInput): Boolean;
  var
    I: TcxDateEditSmartInput;
    J: Integer;
    S: string;
  begin
    Result := False;
    with TStringList.Create do
    try
      for I := Low(TcxDateEditSmartInput) to High(TcxDateEditSmartInput) do
        AddObject(scxDateEditSmartInput[I], TObject(I));
      CustomSort(SICompare);
      for J := 0 to Count - 1 do
      begin
        S := Strings[J];
        if AnsiCompareText(S, Copy(AText, 1, Length(S))) = 0 then
        begin
          Kind := TcxDateEditSmartInput(Objects[J]);
          Result := True;
          Break;
        end;
      end;
    finally
      Free;
    end;
  end;

var
  I: TcxDateEditSmartInput;
  L, Delta: Integer;
  S: string;
  Y, M, D: Word;
  
begin
  InitSmartInputConsts;
  Result := False;
  S := Trim(AText);
  if GetSmartInputKind(S, I) then
  begin
    case I of
      deiToday:
        ADate := Date;
      deiYesterday:
        ADate := Date - 1;
      deiTomorrow:
        ADate := Date + 1;
      deiSunday, deiMonday, deiTuesday, deiWednesday, deiThursday, deiFriday, deiSaturday:
        begin
          ADate := Date;
          Delta := Integer(I) - Integer(deiSunday) + 1 - DayOfWeek(ADate);
          if Delta >= 0 then
            ADate := ADate + Delta
          else
            ADate := ADate + 7 + Delta;
        end;
      deiFirst..deiSeventh:
        begin
          ADate := Date;
          Delta := DayOfWeekOffset(ADate) - (Integer(I) - Integer(deiFirst));
          ADate := ADate - Delta;
        end;
      deiBOM:
        begin
          DecodeDate(Date, Y, M, D);
          ADate := EncodeDate(Y, M, 1);
        end;
      deiEOM:
        begin
          DecodeDate(Date, Y, M, D);
          ADate := EncodeDate(Y, M, MonthDays[IsLeapYear(Y), M]);
        end;
      deiNow:
        ADate := Now;
    end;
    L := Length(scxDateEditSmartInput[I]);
    S := Trim(Copy(AText, L + 1, Length(AText)));
    if (Length(S) >= 2) and ((S[1] = '+') or (S[1] = '-')) then
    begin
      if S[1] = '+' then L := 1
      else L := -1;
      S := Trim(Copy(S, 2, Length(S)));
      try
        ADate := ADate + L * StrToInt(S);
      except
        on EConvertError do;
      end;
    end;
    Result := True;
  end;
  if not Result and Assigned(SmartTextToDateFunc) then
    Result := SmartTextToDateFunc(AText, ADate);
end;

function TextToDateEx(const AText: string; var ADate: TDateTime): Boolean;
begin
  ADate := cxTextToDateTime(AText, cxFormatController.UseDelphiDateTimeFormats);
  Result := ADate <> NullDate;
end;

function cxDateTimeToText(ADate: TDateTime; AFourDigitYearNeeded: Boolean = False; AUseDelphiDateTimeFormats: Boolean = False): string;

  function GetDateTimeFormat: string;
  var
    I: Integer;
    S: string;
  begin
    if AUseDelphiDateTimeFormats then
    begin
      Result := ShortDateFormat;
      if TimeOf(ADate) <> 0 then
        Result := Result + ' ' + LongTimeFormat;
    end
    else
      Result := cxGetLocaleStr(LOCALE_SSHORTDATE);
    if AFourDigitYearNeeded then
    begin
      S := LowerCase(Result);
      if (Pos('yyy', S) = 0) and (Pos('yy', S) > 0) then
      begin
        I := Pos('yy', S);
        Insert(Result[I], Result, I + 2);
        Insert(Result[I], Result, I + 3);
      end;
    end;
  end;

var
  SystemTime: TSystemTime;
  PS: array[0..100] of Char;
begin
  if ADate = NullDate then
    Result := ''
  else
    if AUseDelphiDateTimeFormats then
      DateTimeToString(Result, GetDateTimeFormat, ADate)
    else
    begin
      DateTimeToSystemTime(ADate, SystemTime);
      if GetDateFormat(GetThreadLocale, 0, @SystemTime,
        PChar(GetDateTimeFormat), PS, 100) <> 0 then
      begin
        Result := PS;
        if TimeOf(ADate) <> 0 then
        begin
          GetTimeFormat(GetThreadLocale, 0, @SystemTime, nil, PS, 100);
          Result := Result + ' ' + PS;
        end;
      end
      else
        try
          Result := VarFromDateTime(ADate);
        except
          on EVariantError do
            Result := '';
        end;
    end;
end;

function cxTextToDateTime(const AText: string; AUseDelphiDateTimeFormats: Boolean = False): TDateTime;
var
  ADay, AMonth, AYear: Word;
  S: string;
begin
  try
    S := Trim(AText);
    if S = '' then
      Result := NullDate
    else
    begin
      if cxIsGregorianCalendar then
      begin
        // Smart Date
        if not SmartTextToDate(S, Result) then
        begin
          CorrectTextForDateTimeConversion(S, not AUseDelphiDateTimeFormats);
          if AUseDelphiDateTimeFormats then
            Result := StrToDateTime(S)
          else
            Result := VarToDateTime(S);
        end;
        DecodeDate(Result, AYear, AMonth, ADay);
        if (Result >= MaxInt) or (Result <= -MaxInt - 1) or (ADay <= 0) or (AYear > MaxYear) then
          Result := NullDate;
      end
      else
        Result := cxLocalFormatStrToDate(S);
    end;
  except
    Result := NullDate;
  end;
end;

function DateTimeToText(ADate: TDateTime; AFourDigitYearNeeded: Boolean = False): string;
begin
  Result := cxDateTimeToText(ADate, AFourDigitYearNeeded, cxFormatController.UseDelphiDateTimeFormats);
end;

function DateTimeToTextEx(const ADate: TDateTime; AIsMasked: Boolean;
  AIsDateTimeEdit: Boolean = False; AFourDigitYearNeeded: Boolean = False): string;
begin
  if ADate = NullDate then
    Result := ''
  else
  begin
    if cxIsGregorianCalendar then
    begin
      if AIsMasked then
      begin
        if AIsDateTimeEdit then
          Result := FormatDateTime(cxFormatController.MaskedDateTimeEditFormat, ADate)
        else
          Result := FormatDateTime(cxFormatController.MaskedDateEditFormat, DateOf(ADate));
      end
      else
        Result := DateTimeToText(ADate, AFourDigitYearNeeded);
    end
    else
      Result := cxDateToLocalFormatStr(ADate);
  end;
end;

function cxMinDateTime: Double;
begin
  Result := EncodeDate(MinYear, 1, 1);
end;

function cxStrToDateTime(S: string; AUseOleDateFormat: Boolean;
  out ADate: TDateTime): Boolean;
begin
  Result := False;
  ADate := NullDate;
  try
    if cxIsGregorianCalendar then
    begin
      CorrectTextForDateTimeConversion(S, AUseOleDateFormat);
      if AUseOleDateFormat then
        ADate := VarToDateTime(S)
      else
        ADate := StrToDateTime(S);
    end
    else
      ADate := cxLocalFormatStrToDate(S);
    Result := True;
  except
    on Exception(*EConvertError*) do
      ADate := NullDate;
  end;
end;

{ TcxEra }

constructor TcxEra.Create(AEra: Integer; AStartDate: TDateTime;
  AYearOffset, AMinEraYear, AMaxEraYear: Integer);
begin
  Era := AEra;
  StartDate := AStartDate;
  YearOffset := AYearOffset;
  MinEraYear := AMinEraYear;
  MaxEraYear := AMaxEraYear;
end;

procedure TcxEra.Assign(Source: TPersistent);
begin
  inherited Assign(Source);
  if Source is TcxEra then
    with Source as TcxEra do
    begin
      Self.Era := Era;
      Self.FMaxEraYear := MaxEraYear;
      Self.FMinEraYear := MinEraYear;
      Self.FStartDate := StartDate;
      Self.FYearOffset := YearOffset;
    end;
end;

{ TcxEras }

function TcxEras.GetItem(AIndex: Integer): TcxEra;
begin
  Result := TcxEra(inherited Items[AIndex]);
end;

procedure TcxEras.SetItem(AIndex: Integer; AValue: TcxEra);
begin
  TcxEra(inherited Items[AIndex]).Assign(AValue);
end;

{ TcxCustomCalendarTable }

constructor TcxCustomCalendarTable.Create;
begin
  FEras := TcxEras.Create;
end;

destructor TcxCustomCalendarTable.Destroy;
begin
  FEras.Clear;
  FreeAndNil(FEras);
  inherited Destroy;
end;

procedure TcxCustomCalendarTable.AdjustYear(var AYear, AEra: Integer);
begin
  AdjustYear(AYear, AEra, 1, 1);
end;

procedure TcxCustomCalendarTable.AdjustYear(var AYear, AEra: Integer; AMonth, ADay: Integer);
var
  ACurrentYear: Cardinal;
begin
  ACurrentYear := AYear;
  YearToGregorianYear(ACurrentYear, AEra);
  AEra := GetEra(ACurrentYear, AMonth, ADay);
  if AEra > 0 then
    AYear := Integer(ACurrentYear) - Eras[AEra].YearOffset;
end;

procedure TcxCustomCalendarTable.CheckDateTime(var ADateTime: TDateTime);
begin
  if ADateTime < MinSupportedDate then
    ADateTime := MinSupportedDate;
  if ADateTime > MaxSupportedDate then
    ADateTime := MaxSupportedDate;
end;

function TcxCustomCalendarTable.IsNotValid(ADate: TcxDateTime; out AResult: TDateTime): Boolean;
begin
  with ADate do
    Result := not IsValidDay(Era, Year, Month, Day);
  if Result then
    AResult := MinSupportedDate;
end;

procedure TcxCustomCalendarTable.YearToGregorianYear(var AYear: Cardinal;
  AEra: Integer);
begin
  if AEra = -1 then
    AYear := Integer(AYear) + DefaultEra.YearOffset
  else
    if (AEra >= 0) and (AEra < Eras.Count) then
      AYear := Integer(AYear) + Eras[AEra].YearOffset;
end;

function TcxCustomCalendarTable.AddDays(ADate: TcxDateTime;
  ACountDays: Integer): TDateTime;
begin
  Result := ToDateTime(ADate) + ACountDays;
  CheckDateTime(Result);
end;

function TcxCustomCalendarTable.AddMonths(ADate: TDateTime;
  ACountMonths: Integer): TDateTime;
begin
  Result := AddMonths(FromDateTime(ADate), ACountMonths);
end;

function TcxCustomCalendarTable.AddMonths(ADate: TcxDateTime;
  ACountMonths: Integer): TDateTime;
var
  ASwap: Integer;
  ACurrentMonth: Integer;
  ACurrentYear: Integer;
  ACurrentEra: Integer;
begin
  if IsNotValid(ADate, Result) then
    Exit;
  ACurrentEra := ADate.Era;
  ACurrentMonth := ADate.Month;
  ACurrentYear := ADate.Year;
  Inc(ACurrentMonth, ACountMonths);
  if ACurrentMonth > Integer(GetMonthsInYear(ACurrentEra, ACurrentYear)) then
    ASwap := -1
  else
    ASwap := 1;
  while (ACurrentMonth > Integer(GetMonthsInYear(ACurrentEra, ACurrentYear))) or (ACurrentMonth <= 0) do
  begin
    if ASwap > 0 then
      Inc(ACurrentMonth, ASwap * Integer(GetMonthsInYear(ACurrentEra, ACurrentYear - 1)))
    else
      Inc(ACurrentMonth, ASwap * Integer(GetMonthsInYear(ACurrentEra, ACurrentYear)));
    Inc(ACurrentYear, -ASwap);
  end;
  if not IsValidDay(ACurrentEra, ACurrentYear, ACurrentMonth, ADate.Day) then
    ADate.Day := GetDaysInMonth(ACurrentEra, ACurrentYear, ACurrentMonth);
  AdjustYear(ACurrentYear, ACurrentEra, ACurrentMonth, ADate.Day);
  ADate.Era := ACurrentEra;
  ADate.Year := ACurrentYear;
  ADate.Month := ACurrentMonth;
  if IsNotValid(ADate, Result) then
    Exit;
  Result := ToDateTime(ADate);
  CheckDateTime(Result);
end;

function TcxCustomCalendarTable.AddWeeks(ADate: TDateTime;
  ACountWeeks: Integer): TDateTime;
begin
  Result := AddWeeks(FromDateTime(ADate), ACountWeeks);
end;

function TcxCustomCalendarTable.AddWeeks(ADate: TcxDateTime;
  ACountWeeks: Integer): TDateTime;
begin
  Result := AddDays(ADate, ACountWeeks * 7);
  CheckDateTime(Result);
end;

function TcxCustomCalendarTable.AddYears(ADate: TDateTime;
  ACountYears: Integer): TDateTime;
begin
  Result := AddYears(FromDateTime(ADate), ACountYears);
end;

function TcxCustomCalendarTable.AddYears(ADate: TcxDateTime;
  ACountYears: Integer): TDateTime;
var
  ACurrentYaer: Integer;
  ACurrentEra: Integer;
begin
  if IsNotValid(ADate, Result) then
    Exit;
  ACurrentYaer := Integer(ADate.Year) + ACountYears;
  ACurrentEra := ADate.Era;
  AdjustYear(ACurrentYaer, ACurrentEra);
  if not IsValidYear(ACurrentEra, ACurrentYaer) then
  begin
    Result := MinSupportedDate;
    Exit;
  end;
  if not IsValidMonth(ACurrentEra, ACurrentYaer, ADate.Month) then
    ADate.Month := GetMonthsInYear(ACurrentEra, ACurrentYaer);
  if not IsValidDay(ACurrentEra, ACurrentYaer, ADate.Month, ADate.Day) then
    ADate.Day := GetDaysInMonth(ACurrentEra, ACurrentYaer, ADate.Month);
  AdjustYear(ACurrentYaer, ACurrentEra, ADate.Month, ADate.Day);
  ADate.Year := ACurrentYaer;
  ADate.Era := ACurrentEra;
  Result := ToDateTime(ADate);
  CheckDateTime(Result);
end;

function TcxCustomCalendarTable.FromDateTime(AYear, AMonth,
  ADay: Cardinal): TcxDateTime;
begin
  Result := FromDateTime(AYear, AMonth, ADay, 0, 0, 0, 0);
end;

function TcxCustomCalendarTable.FromDateTime(AYear, AMonth,
  ADay: Cardinal; AHours, AMinutes, ASeconds: Byte;
  AMilliseconds: Word): TcxDateTime;
begin
  Result := FromDateTime(EncodeDateTime(AYear, AMonth, ADay, AHours, AMinutes, ASeconds, AMilliseconds));
end;

function TcxCustomCalendarTable.GetDayOfYear(ADate: TDateTime): Cardinal;
begin
  Result := GetDayOfYear(FromDateTime(ADate));
end;

function TcxCustomCalendarTable.GetDayOfYear(ADate: TcxDateTime): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to ADate.Month - 1 do
    Result := Result + GetDaysInMonth(ADate.Year, I);
  Inc(Result, ADate.Day);
end;

function TcxCustomCalendarTable.GetDaysInMonth(AYear, AMonth: Cardinal): Cardinal;
begin
  Result := GetDaysInMonth(-1, AYear, AMonth);
end;

function TcxCustomCalendarTable.GetDaysInYear(AYear: Cardinal): Cardinal;
begin
  Result := GetDaysInYear(-1, AYear);
end;

function TcxCustomCalendarTable.GetEra(AYear: Integer): Integer;
begin
  Result := GetEra(AYear, 1, 1);
end;

function TcxCustomCalendarTable.GetEra(AYear, AMonth, ADay: Integer): Integer;
var
  I: Integer;
  ADate: TDateTime;
begin
  Result := -1;
  if Eras.Count = 0 then
    Exit;
  ADate := EncodeDate(AYear, AMonth, ADay);
  for I := 0 to Eras.Count - 1 do
    with Eras[I] do
      if (ADate >= StartDate) then
        Result := I;
end;

function TcxCustomCalendarTable.GetFirstDayOfWeek(ADate: TDateTime): TDateTime;
begin
  Result := ToDateTime(GetFirstDayOfWeek(FromDateTime(ADate)));
end;

function TcxCustomCalendarTable.GetFirstDayOfWeek(ADate: TDateTime; AStartDayOfWeek: TDay): TDateTime;
var
  ADays: Integer;
begin
  ADays := Byte(AStartDayOfWeek) - GetWeekDay(ADate);
  if ADays > 0 then
    Dec(ADays, 7);
  Result := ADate + ADays;
end;

function TcxCustomCalendarTable.GetFirstDayOfWeek(
  ADate: TcxDateTime): TcxDateTime;
var
  I: Integer;
begin
  I := GetFirstWeekDay - GetWeekDay(ADate);
  if I > 0 then
    Dec(I, 7);
  Result := FromDateTime(AddDays(ADate, I));
end;

function TcxCustomCalendarTable.GetFirstDayOfWeek(ADate: TcxDateTime; AStartDayOfWeek: TDay): TcxDateTime;
begin
  Result := FromDateTime(GetFirstDayOfWeek(ToDateTime(ADate), AStartDayOfWeek));
end;

function TcxCustomCalendarTable.GetMonthsInYear(AYear: Cardinal): Cardinal;
begin
  Result := GetMonthsInYear(-1, AYear);
end;

function TcxCustomCalendarTable.GetYear(ADate: TDateTime): Cardinal;
begin
  Result := FromDateTime(ADate).Year;
end;

function TcxCustomCalendarTable.GetYear(ADate: TcxDate): Cardinal;
begin
  Result := ADate.Year;
end;

function TcxCustomCalendarTable.GetYear(ADate: TcxDateTime): Cardinal;
begin
  Result := ADate.Year;
end;

function TcxCustomCalendarTable.GetWeekDay(ADate: TDateTime): Byte;
begin
  Result := DayOfWeek(ADate) - 1;
end;

function TcxCustomCalendarTable.GetWeekDay(ADate: TcxDateTime): Byte;
begin
  Result := GetWeekDay(ToDateTime(ADate));
end;

function TcxCustomCalendarTable.GetWeekNumber(ADate: TDateTime; AStartOfWeek: TDay;
  AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal;
begin
  Result := GetWeekNumber(FromDateTime(ADate), AStartOfWeek, AFirstWeekOfYear);
end;

function TcxCustomCalendarTable.IsLeapDay(AYear, AMonth, ADay: Cardinal): Boolean;
begin
  Result := IsLeapDay(-1, AYear, AMonth, ADay);
end;

function TcxCustomCalendarTable.IsLeapMonth(AYear, AMonth: Cardinal): Boolean;
begin
  Result := IsLeapMonth(-1, AYear, AMonth);
end;

function TcxCustomCalendarTable.IsLeapYear(AYear: Cardinal): Boolean;
begin
  Result := IsLeapYear(-1, AYear);
end;

function TcxCustomCalendarTable.IsValidDay(AYear, AMonth,
  ADay: Cardinal): Boolean;
begin
  Result := IsValidDay(-1, AYear, AMonth, ADay);
end;

function TcxCustomCalendarTable.IsValidDay(AEra: Integer;AYear, AMonth,
  ADay: Cardinal): Boolean;
begin
  Result := IsValidMonth(AEra, AYear, AMonth) and
    (ADay > 0) and (ADay <= GetDaysInMonth(AEra, AYear, AMonth));
end;

function TcxCustomCalendarTable.IsValidDate(ADate: TDateTime): Boolean;
var
  AConvertDate: TcxDateTime;
begin
  AConvertDate := FromDateTime(ADate);
  with AConvertDate do
    Result := IsValidDay(Year, Month, Day);
end;

function TcxCustomCalendarTable.IsValidMonth(AYear,
  AMonth: Cardinal): Boolean;
begin
  Result := IsValidMonth(-1, AYear, AMonth);
end;

function TcxCustomCalendarTable.IsValidMonth(AEra: Integer; AYear,
  AMonth: Cardinal): Boolean;
begin
  Result := IsValidYear(AEra, AYear) and
    (AMonth > 0) and (AMonth <= GetMonthsInYear(AEra, AYear));
end;

function TcxCustomCalendarTable.IsValidYear(AYear: Cardinal): Boolean;
begin
  Result := IsValidYear(-1, AYear);
end;

function TcxCustomCalendarTable.IsValidYear(AEra: Integer; AYear: Cardinal): Boolean;
begin
  Result := (Integer(AYear) >= GetMinSupportedYear) and
    (Integer(AYear) <= GetMaxSupportedYear);
end;

function TcxCustomCalendarTable.ToDateTime(ADate: TcxDate): TDateTime;
var
  ADateTime: TcxDateTime;
begin
  with ADateTime do
  begin
    Year := ADate.Year;
    Month := ADate.Month;
    Day := ADate.Day;
    Hours := 0;
    Minutes := 0;
    Seconds := 0;
    Milliseconds := 0;
  end;
  Result := ToDateTime(ADateTime);
end;

function TcxCustomCalendarTable.ToDateTime(AYear, AMonth,
  ADay: Cardinal): TDateTime;
begin
  Result := ToDateTime(AYear, AMonth, ADay, 0, 0, 0, 0);
end;

function TcxCustomCalendarTable.ToDateTime(AYear, AMonth, ADay: Cardinal;
  AHours, AMinutes, ASeconds: Byte; AMilliseconds: Word): TDateTime;
var
  ADateTime: TcxDateTime;
begin
  with ADateTime do
  begin
    Era := -1;
    Year := AYear;
    Month := AMonth;
    Day := ADay;
    Hours := AHours;
    Minutes := AMinutes;
    Seconds := ASeconds;
    Milliseconds := AMilliseconds;
  end;
  Result := ToDateTime(ADateTime);
end;

function TcxCustomCalendarTable.GetDayNumber(const S: string): Integer;
begin
  Result := StrToInt(S);
end;

function TcxCustomCalendarTable.GetMonthNumber(AYear: Integer; const S: string): Integer;
var
  I: Integer;
begin
  for I := 1 to 12 do
  begin
    if (AnsiCompareText(S, LongMonthNames[I]) = 0) or
      (AnsiCompareText(S, ShortMonthNames[I]) = 0) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := StrToInt(S);
end;

function TcxCustomCalendarTable.GetYearNumber(const S: string): Integer;
var
  ATwoDigitYearMax: Integer;
  ARightDigitYear: Integer;
  AAge: Integer;
begin
  Result := StrToInt(S);
  if Length(S) <= 2 then
  begin
    cxGetCalendarInfo(GetThreadLocale, GetCalendarID, CAL_ITWODIGITYEARMAX or
      CAL_RETURN_NUMBER, nil, 0, @ATwoDigitYearMax);
    AAge := ATwoDigitYearMax div 100;
    ARightDigitYear := ATwoDigitYearMax - AAge * 100;
    if Result <= ARightDigitYear then
      Result := Result + AAge * 100
    else
      Result := Result + (AAge - 1) * 100
  end;
end;

{ TcxGregorianCalendarTable }

constructor TcxGregorianCalendarTable.Create;
begin
  inherited Create;
  FDefaultEra := TcxEra.Create(-1, NullDate, 0, 1, 9999);
  FGregorianCalendarType := gctLocalized;
end;

destructor TcxGregorianCalendarTable.Destroy;
begin
  FreeAndNil(FDefaultEra);
  inherited Destroy;
end;

function TcxGregorianCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catSolarCalendar;
end;

function TcxGregorianCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := TcxCALID(FGregorianCalendarType);
end;

function TcxGregorianCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := FDefaultEra;
end;

function TcxGregorianCalendarTable.GetMaxSupportedDate: TDateTime;
begin
  Result := MaxDateTime;
end;

function TcxGregorianCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := MinDateTime;
end;

function TcxGregorianCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := MaxYear;
end;

function TcxGregorianCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := MinYear;
end;

function TcxGregorianCalendarTable.FromDateTime(ADate: TDateTime): TcxDateTime;
var
  Y, M, D: Word;
  H, MN, S, MS: Word;
begin
  DecodeDateTime(ADate, Y, M, D, H, MN, S, MS);
  with Result do
  begin
    Year := Y;
    Month := M;
    Day := D;
    Hours := H;
    Minutes := MN;
    Seconds := S;
    Milliseconds := MS;
  end;
end;

function TcxGregorianCalendarTable.GetFirstWeekDay: Byte;
var
  ADay: TDay;
begin
  case FGregorianCalendarType of
    gctArabic:
      ADay := dSaturday;
    gctMiddleEastFrench, gctTransliteratedEnglish,
    gctTransliteratedFrench:
      ADay := dMonday;
    else
      ADay := dSunday;
  end;
  Result := Byte(ADay);
end;

function TcxGregorianCalendarTable.GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
  AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal;
begin
  Result := cxDateUtils.GetWeekNumber(ToDateTime(ADate), AStartOfWeek, AFirstWeekOfYear);
end;

function TcxGregorianCalendarTable.GetDaysInMonth(AEra: Integer; AYear,
  AMonth: Cardinal): Cardinal;
begin
  case AMonth of
    2:
      begin
        if IsLeapYear(AEra, AYear) then
          Result := 29
        else
          Result := 28;
      end;
    4, 6, 9, 11:
      Result := 30;
    else
      Result := 31;
  end;
end;

function TcxGregorianCalendarTable.GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  if IsLeapYear(AEra, AYear) then
    Result := 366
  else
    Result := 365;
end;

function TcxGregorianCalendarTable.GetFullWeeksInYear(AYear: Cardinal): Cardinal;
var
  ADate: TcxDateTime;
  ADay: Integer;
begin
  Result := 52;
  ADate.Year := AYear;
  ADate.Month := 1;
  ADate.Day := 1;
  ADate.Hours := 0;
  ADate.Minutes := 0;
  ADate.Seconds := 0;
  ADate.Milliseconds := 0;
  ADay := GetWeekDay(ADate) - GetFirstWeekDay;
  if ADay < 0 then
    Inc(ADay, 7);
  if (IsLeapYear(AYear) and (ADay >= 5)) or (ADay >= 6) then
    Result := 53;
end;

function TcxGregorianCalendarTable.GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  Result := 12;
end;

function TcxGregorianCalendarTable.IsLeapDay(AEra: Integer; AYear, AMonth,
  ADay: Cardinal): Boolean;
begin
  Result := IsLeapMonth(AEra, AYear, ADay) and (ADay = 29);
end;

function TcxGregorianCalendarTable.IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean;
begin
  Result := IsLeapYear(AEra, AYear) and (AMonth = 2);
end;

function TcxGregorianCalendarTable.IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean;
begin
  YearToGregorianYear(AYear, AEra);
  Result := (AYear mod 4 = 0) and ((AYear mod 100 <> 0) or (AYear mod 400 = 0));
end;

function TcxGregorianCalendarTable.ToDateTime(ADateTime: TcxDateTime): TDateTime;
begin
  with ADateTime do
    Result := EncodeDateTime(Year, Month, Day, Hours, Minutes, Seconds, Milliseconds);
end;

{ TcxJapaneseCalendarTable }

constructor TcxJapaneseCalendarTable.Create;
begin
  FEras := TcxEras.Create;
  FEras.Add(TcxEra.Create(1, EncodeDate(1868, 9, 8), 1867, 1, 1912 - 1867));    // Meiji
  FEras.Add(TcxEra.Create(2, EncodeDate(1912, 7, 30), 1911, 1, 1926 - 1911));   // Taisho
  FEras.Add(TcxEra.Create(3, EncodeDate(1926, 12, 25), 1925, 1, 1989 - 1925));  // Showa
  FEras.Add(TcxEra.Create(4, EncodeDate(1989, 1, 8), 1988, 1, 9999 - 1988));    // Heisei. Most recent
end;

function TcxJapaneseCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catSolarCalendar;
end;

function TcxJapaneseCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_JAPAN;
end;

function TcxJapaneseCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := Eras[3];
end;

function TcxJapaneseCalendarTable.GetMaxSupportedDate: TDateTime;
begin
  Result := EncodeDate(9999, 12, 31);
end;

function TcxJapaneseCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := EncodeDate(1868, 09, 08);
end;

function TcxJapaneseCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := 8011; // Heisei 8011/12/31
end;

function TcxJapaneseCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := 1;
end;

function TcxJapaneseCalendarTable.FromDateTime(ADate: TDateTime): TcxDateTime;
var
  Y, M, D, H, Mn, S, MS: Word;
begin
  DecodeDate(ADate, Y, M, D);
  DecodeTime(ADate, H, Mn, S, MS);
  with Result do
  begin
    Era := GetEra(Y, M, D);
    if Era = -1 then
      Year := Y - DefaultEra.YearOffset
    else
      Year := Y - Eras[Era].YearOffset;
    Month := M;
    Day := D;
    Hours := H;
    Minutes := Mn;
    Seconds := S;
    Milliseconds := MS;
  end;
end;

function TcxJapaneseCalendarTable.GetFirstWeekDay: Byte;
begin
  Result := 0;
end;

function TcxJapaneseCalendarTable.ToDateTime(ADateTime: TcxDateTime): TDateTime;
var
  AYear: Cardinal;
begin
  with ADateTime do
  begin
    if IsNotValid(ADateTime, Result) then
      Exit;
    AYear := Year;
    YearToGregorianYear(AYear, Era);
    Result := EncodeDate(AYear, Month, Day) +
      EncodeTime(Hours, Minutes, Seconds, Milliseconds);
  end;
end;

{ TcxTaiwanCalendarTable }

constructor TcxTaiwanCalendarTable.Create;
begin
  FEras := TcxEras.Create;
  FEras.Add(TcxEra.Create(1, EncodeDate(1912, 1, 1), 1911, 1, 9999 - 1911)); //
end;

function TcxTaiwanCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catSolarCalendar;
end;

function TcxTaiwanCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_TAIWAN;
end;

function TcxTaiwanCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := FEras[0];
end;

function TcxTaiwanCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := DefaultEra.StartDate;
end;

function TcxTaiwanCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := DefaultEra.MaxEraYear;
end;

function TcxTaiwanCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := DefaultEra.MinEraYear;
end;

{ TcxKoreanCalendarTable }

constructor TcxKoreanCalendarTable.Create;
begin
  FEras := TcxEras.Create;
  FEras.Add(TcxEra.Create(0, EncodeDate(1, 1, 1), -2333, 2334, 9999 + 2333));
end;

function TcxKoreanCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catSolarCalendar;
end;

function TcxKoreanCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_KOREA;
end;

function TcxKoreanCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := Eras[0];
end;

function TcxKoreanCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := DefaultEra.StartDate;
end;

function TcxKoreanCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := DefaultEra.MaxEraYear;
end;

function TcxKoreanCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := DefaultEra.MinEraYear;
end;

{ TcxHijriCalendarTable }

constructor TcxHijriCalendarTable.Create;
begin
  inherited Create;
  FDefaultEra := TcxEra.Create(-1, NullDate, 0, 1, 9999);
end;

destructor TcxHijriCalendarTable.Destroy;
begin
  FreeAndNil(FDefaultEra);
  inherited Destroy;
end;

function TcxHijriCalendarTable.FromDateTime(
  ADate: TDateTime): TcxDateTime;
var
  I: Integer;
  H, M, S, MS: Word;
  ACountDays: Integer;
  ACurrentYear: Integer;
begin
  with Result do
  begin
    DecodeTime(ADate, H, M, S, MS);
    Hours := H;
    Minutes := M;
    Seconds := S;
    Milliseconds := MS;
    ACountDays := Trunc(ADate - EncodeDate(1, 1, 1) + 1) - 227013;
    Year := ((ACountDays * 30) div 10631) + 1;
    ACurrentYear := Year;
    ACountDays := ACountDays - (ACurrentYear - 1) * 354;
    ACountDays := ACountDays - ((ACurrentYear - 1) div 30) * 11;
    for I := 1 to (ACurrentYear - 1) mod 30 do
      if IsLeapYear(I) then
        ACountDays := ACountDays - 1;
    Year := ACurrentYear;
    Month := 1;
    while ACountDays > Integer(GetDaysInMonth(Year, Month)) do
    begin
      ACountDays := ACountDays - Integer(GetDaysInMonth(Year, Month));
      Month := Month + 1;
      if Month > GetMonthsInYear(Year) then
      begin
        Month := 1;
        Year := Year + 1;
      end;
    end;
    if ACountDays = 0 then
    begin
      Year := Year - 1;
      Month := GetMonthsInYear(Year);
      Day := GetDaysInMonth(Year, Month);
    end
    else
      Day := ACountDays;
  end;
end;

function TcxHijriCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catLunarCalendar;
end;

function TcxHijriCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_HIJRI;
end;

function TcxHijriCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := FDefaultEra;
end;

function TcxHijriCalendarTable.GetFirstWeekDay: Byte;
begin
  Result := 6;
end;

function TcxHijriCalendarTable.GetDaysInMonth(AEra: Integer; AYear,
  AMonth: Cardinal): Cardinal;
begin
  if IsLeapMonth(AYear, AMonth) then
    Result := 30
  else
    if AMonth in [2, 4, 6, 8, 10, 12] then
      Result := 29
    else
      Result := 30;
end;

function TcxHijriCalendarTable.GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  if IsLeapYear(AYear) then
    Result := 355
  else
    Result := 354;
end;

function TcxHijriCalendarTable.GetFullWeeksInYear(
  AYear: Cardinal): Cardinal;
begin
  Result := 50;
end;

function TcxHijriCalendarTable.GetMaxSupportedDate: TDateTime;
begin
  Result := EncodeDate(9666, 4, 3);
end;

function TcxHijriCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := EncodeDate(0622, 7, 16);
end;

function TcxHijriCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := 9666;
end;

function TcxHijriCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := 1;
end;

function TcxHijriCalendarTable.GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  Result := 12;
end;

function TcxHijriCalendarTable.GetWeekNumber(ADate: TcxDateTime; AStartOfWeek: TDay;
  AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal;
var
  AStartWeekDate: TDateTime;
  AStart: TDateTime;
  ATmpDate: TcxDateTime;
begin
  if AFirstWeekOfYear = fwySystem then
    AFirstWeekOfYear := TcxFirstWeekOfYear(
      StrToInt(cxGetLocaleInfo(GetThreadLocale, LOCALE_IFIRSTWEEKOFYEAR, '0')) + 1);
  with ATmpDate do
  begin
    Year := ADate.Year;
    Month := 1;
    Day := 1;
    Hours := 0;
    Minutes := 0;
    Seconds := 0;
    Milliseconds := 0;
  end;
  AStart := GetFirstDayOfWeek(ToDateTime(ATmpDate));
  case AFirstWeekOfYear of
    fwyFirstFourDays:
      if FromDateTime(AStart + 3).Year < ADate.Year then AStart := AStart + 7;
    fwyFirstFullWeek:
      if FromDateTime(AStart).Year < ADate.Year then AStart := AStart + 7;
  end;
  Result := Trunc(Trunc(ToDateTime(ADate)) - AStart) div 7 + 1;
  if ADate.Month = GetMonthsInYear(ADate.Year) then
  begin
    AStartWeekDate := ToDateTime(GetFirstDayOfWeek(ADate));
    case AFirstWeekOfYear of
      fwyJan1:
        if FromDateTime(AStartWeekDate + 6).Month = 1 then
          Result := 1;
      fwyFirstFourDays:
        if FromDateTime(AStartWeekDate + 3).Month = 1 then
          Result := 1;
    end;
  end;
end;

function TcxHijriCalendarTable.IsLeapDay(AEra: Integer; AYear, AMonth,
  ADay: Cardinal): Boolean;
begin
  Result := IsLeapMonth(AYear, AMonth) and (ADay = 30);
end;

function TcxHijriCalendarTable.IsLeapMonth(AEra: Integer; AYear,
  AMonth: Cardinal): Boolean;
begin
  Result := IsLeapYear(AYear) and (AMonth = 12);
end;

function TcxHijriCalendarTable.IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean;
begin
  Result := (AYear mod 30) in [2, 5, 7, 10, 13, 15, 18, 21, 24, 26, 29];
end;

function TcxHijriCalendarTable.ToDateTime(
  ADateTime: TcxDateTime): TDateTime;
var
  I: Integer;
begin
  Result := 227013;
  Result := Result + (ADateTime.Year - 1) * 354;
  Result := Result + ((ADateTime.Year - 1) div 30) * 11;
  for I := 1 to (ADateTime.Year - 1) mod 30 do
    if IsLeapYear(I) then
      Result := Result + 1;
  Result := Result + GetDayOfYear(ADateTime);
  Result := Result + EncodeDate(1, 1, 1) - 1;
  Result := Result + EncodeTime(ADateTime.Hours, ADateTime.Minutes, ADateTime.Seconds, ADateTime.Milliseconds);
end;

function TcxHijriCalendarTable.GetMonthNumber(AYear: Integer; const S: string): Integer;
var
  I: Integer;
begin
  for I := 1 to 12 do
  begin
    if AnsiCompareText(S, cxGetLocalMonthName(AYear, I, Self)) = 0 then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := inherited GetMonthNumber(AYear, S);
end;

{ TcxThaiCalendarTable }

constructor TcxThaiCalendarTable.Create;
begin
  FEras := TcxEras.Create;
  FEras.Add(TcxEra.Create(0, EncodeDate(1, 1, 1), -543, 544, 9999 + 543));
end;

function TcxThaiCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catSolarCalendar;
end;

function TcxThaiCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_THAI;
end;

function TcxThaiCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := Eras[0];
end;

function TcxThaiCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := DefaultEra.StartDate;
end;

function TcxThaiCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := DefaultEra.MaxEraYear;
end;

function TcxThaiCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := DefaultEra.MinEraYear;
end;

{ TcxHebrewCalendarTable }

constructor TcxHebrewCalendarTable.Create;
begin
  inherited Create;
  FDefaultEra := TcxEra.Create(-1, NullDate, 0, 1, 9999);
end;

destructor TcxHebrewCalendarTable.Destroy;
begin
  FreeAndNil(FDefaultEra);
  inherited Destroy;
end;

function TcxHebrewCalendarTable.FromDateTime(ADate: TDateTime): TcxDateTime;
var
  AYear, AMonth, ADay: Word;
  H, M, S, MS: Word;
  ADays: Integer;
begin
  if ADate > MaxSupportedDate then
  begin
    Result := FromDateTime(MaxSupportedDate);
    Exit;
  end;
  if ADate < MinSupportedDate then
  begin
    Result := FromDateTime(MinSupportedDate);
    Exit;
  end;
  DecodeDateTime(ADate, AYear, AMonth, ADay, H, M, S, MS);
  AYear := AYear + 3760;
  AMonth := 1;
  ADays := Trunc(ADate - ToDateTime(AYear, AMonth, 1)) + 1;
  with Result do
  begin
    Year := AYear;
    Month := AMonth;
    Day := 1;
    Hours := H;
    Minutes := M;
    Seconds := S;
    Milliseconds := MS;
  end;
  if ADays = 0 then
    Exit;
  while (ADays < 0) or (ADays > Integer(GetDaysInMonth(AYear, AMonth))) do
  begin
    if ADays < 0 then
    begin
      Dec(AMonth);
      if AMonth <= 0 then
      begin
        Dec(AYear);
        AMonth := GetMonthsInYear(AYear);
      end;
    end
    else
    begin
      Inc(AMonth);
      if AMonth > GetMonthsInYear(AYear) then
      begin
        AMonth := 1;
        Inc(AYear);
      end;
    end;
    ADays := Trunc(ADate - ToDateTime(AYear, AMonth, 1)) + 1;
  end;
  with Result do
  begin
    Year := AYear;
    Month := AMonth;
    Day := ADays;
  end;
end;

function TcxHebrewCalendarTable.GetCalendarAlgorithmType: TcxCalendarAlgorithmType;
begin
  Result := catLunarSolarCalendar;
end;

function TcxHebrewCalendarTable.GetCalendarID: TcxCALID;
begin
  Result := CAL_HEBREW;
end;

function TcxHebrewCalendarTable.GetDefaultEra: TcxEra;
begin
  Result := FDefaultEra;
end;

function TcxHebrewCalendarTable.GetDaysInMonth(AEra: Integer; AYear,
  AMonth: Cardinal): Cardinal;
var
  AYearIndex: Integer;
begin
  if not IsValidMonth(AYear, AMonth) then
  begin
    Result := 0;
    Exit;
  end;
  AYearIndex := Integer(GetYearType(AYear));
  if IsLeapYear(AYear) then
    Inc(AYearIndex, 3);
  Result := cxHebrewLunarMonthLen[AYearIndex, AMonth];
end;

function TcxHebrewCalendarTable.GetDaysInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  if not IsValidYear(AYear) then
  begin
    Result := 0;
    Exit;
  end;
  Result := 353;
  case GetYearType(AYear) of
    hctyNormal:
      Result := 354;
    hctyPerfect:
      Result := 355;
  end;
  if IsLeapYear(AYear) then
    Inc(Result, 30);
end;

function TcxHebrewCalendarTable.GetFirstWeekDay: Byte;
begin
  Result := 0;
end;

function TcxHebrewCalendarTable.GetYearType(
  AYear: Cardinal): TcxHebrewCalendarTableTypeYear;
var
  AIndex: Integer;
  ATypeYear: Integer;
begin
  AIndex := AYear - cxHebrewFirstGregorianTableYear - cxHebrewYearOf1AD;
  if (AIndex < 0) or (AIndex > cxHebrewTableYear) then
  begin
    Result := TcxHebrewCalendarTableTypeYear(0);
    Exit;
  end;
  AIndex := AIndex * 2 + 1;
  ATypeYear := cxHebrewTable[AIndex];
  if IsLeapYear(AYear) then
    Dec(ATypeYear, 3);
  Result := TcxHebrewCalendarTableTypeYear(ATypeYear);
end;

function TcxHebrewCalendarTable.GetFullWeeksInYear(AYear: Cardinal): Cardinal;
begin
  Result := GetDaysInYear(AYear) div 7;
end;

function TcxHebrewCalendarTable.GetMaxSupportedDate: TDateTime;
begin
  Result := EncodeDateTime(2239, 9, 29, 23, 59, 59, 999);
end;

function TcxHebrewCalendarTable.GetMinSupportedDate: TDateTime;
begin
  Result := EncodeDate(1583, 1, 1);
end;

function TcxHebrewCalendarTable.GetMaxSupportedYear: Integer;
begin
  Result := 5999;
end;

function TcxHebrewCalendarTable.GetMinSupportedYear: Integer;
begin
  Result := 5343;
end;

function TcxHebrewCalendarTable.GetMonthsInYear(AEra: Integer; AYear: Cardinal): Cardinal;
begin
  if IsLeapYear(AYear) then
    Result := 13
  else
    Result := 12;
end;

function TcxHebrewCalendarTable.GetWeekNumber(ADate: TcxDateTime;
  AStartOfWeek: TDay; AFirstWeekOfYear: TcxFirstWeekOfYear): Cardinal;
var
  AStartWeekDate: TDateTime;
  AStart: TDateTime;
  ATmpDate: TcxDateTime;
begin
  if AFirstWeekOfYear = fwySystem then
    AFirstWeekOfYear := TcxFirstWeekOfYear(
      StrToInt(cxGetLocaleInfo(GetThreadLocale, LOCALE_IFIRSTWEEKOFYEAR, '0')) + 1);
  with ATmpDate do
  begin
    Year := ADate.Year;
    Month := 1;
    Day := 1;
    Hours := 0;
    Minutes := 0;
    Seconds := 0;
    Milliseconds := 0;
  end;
  AStart := GetFirstDayOfWeek(ToDateTime(ATmpDate));
  case AFirstWeekOfYear of
    fwyFirstFourDays:
      if FromDateTime(AStart + 3).Year < ADate.Year then AStart := AStart + 7;
    fwyFirstFullWeek:
      if FromDateTime(AStart).Year < ADate.Year then AStart := AStart + 7;
  end;
  Result := Trunc(Trunc(ToDateTime(ADate)) - AStart) div 7 + 1;
  if ADate.Month = GetMonthsInYear(ADate.Year) then
  begin
    AStartWeekDate := ToDateTime(GetFirstDayOfWeek(ADate));
    case AFirstWeekOfYear of
      fwyJan1:
        if FromDateTime(AStartWeekDate + 6).Month = 1 then
          Result := 1;
      fwyFirstFourDays:
        if FromDateTime(AStartWeekDate + 3).Month = 1 then
          Result := 1;
    end;
  end;
end;

function TcxHebrewCalendarTable.IsLeapDay(AEra: Integer; AYear, AMonth,
  ADay: Cardinal): Boolean;
begin
  Result := IsValidDay(AYear, AMonth, ADay) and IsLeapMonth(AYear, AMonth);
end;

function TcxHebrewCalendarTable.IsLeapMonth(AEra: Integer; AYear, AMonth: Cardinal): Boolean;
begin
  Result := IsValidMonth(AYear, AMonth) and IsLeapYear(AYear) and (AMonth = 7);
end;

function TcxHebrewCalendarTable.IsLeapYear(AEra: Integer; AYear: Cardinal): Boolean;
var
  AIndex: Integer;
begin
  AIndex := AYear - cxHebrewFirstGregorianTableYear - cxHebrewYearOf1AD;
  if (AIndex < 0) or (AIndex > cxHebrewTableYear) then
  begin
    Result := False;
    Exit;
  end;
  AIndex := AIndex * 2 + 1;
  Result := cxHebrewTable[AIndex] >= 4;
end;

function TcxHebrewCalendarTable.ToDateTime(ADateTime: TcxDateTime): TDateTime;
var
  AYear, ADays: Integer;
  ALunarDate: TcxDate;
  ALunarYearType: Integer;
begin
  if IsNotValid(ADateTime, Result) then
    Exit;
  ALunarYearType := Integer(GetYearType(ADateTime.Year));
  if IsLeapYear(ADateTime.Year) then
    Inc(ALunarYearType, 3);
  AYear := ADateTime.Year - cxHebrewYearOf1AD;
  GetLunarMonthDay(AYear, ALunarDate);
  Result := EncodeDateTime(AYear, 1, 1, ADateTime.Hours, ADateTime.Minutes,
    ADateTime.Seconds, ADateTime.Milliseconds);
  if (ADateTime.Month = ALunarDate.Month) and (ADateTime.Day = ALunarDate.Day) then
    Exit;
  ADays := GetDayDifference(ALunarYearType, ADateTime.Month, ADateTime.Day,
    ALunarDate.Month, ALunarDate.Day);
  Result := Result + ADays;
end;

function TcxHebrewCalendarTable.GetDayNumber(const S: string): Integer;
begin
  Result := HebrewNumber(S);
  if Result = 0 then
    Result := inherited GetYearNumber(S);
end;

function TcxHebrewCalendarTable.GetMonthNumber(AYear: Integer; const S: string): Integer;
var
  I: Integer;
begin
  Result := HebrewNumber(S);
  if IsValidMonth(AYear, Result) then
    Exit;
  for I := 1 to 13 do
  begin
    if (AnsiCompareText(S, cxGetLocalMonthName(AYear, I, Self)) = 0) or
      (AnsiCompareText(S, cxDayNumberToLocalFormatStr(I, Self)) = 0) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := inherited GetMonthNumber(AYear, S);
end;

function TcxHebrewCalendarTable.GetYearNumber(const S: string): Integer;
begin
  Result := HebrewNumber(S);
  if Result = 0 then
    Result := inherited GetYearNumber(S)
  else
    Result := Result + 5000;
end;

function TcxHebrewCalendarTable.GetDayDifference(ALunarYearType, AMonth, ADay,
  ALunarMonth, ALunarDay: Integer): Integer;
var
  ASwap: Boolean;
  ATmpDay, ATmpMonth: Integer;
begin
  if AMonth = ALunarMonth then
  begin
    Result := ADay - ALunarDay;
    Exit;
  end;
  ASwap := AMonth > ALunarMonth;
  if ASwap then
  begin
    ATmpMonth := AMonth;
    AMonth := ALunarMonth;
    ALunarMonth := ATmpMonth;
    ATmpDay := ADay;
    ADay := ALunarDay;
    ALunarDay := ATmpDay;
  end;
  Result := cxHebrewLunarMonthLen[ALunarYearType, AMonth] - ADay;
  Inc(AMonth);
  while AMonth < ALunarMonth do
  begin
    Result := Result + cxHebrewLunarMonthLen[ALunarYearType, AMonth];
    Inc(AMonth);
  end;
  Result := Result + ALunarDay;
  if not ASwap then
    Result := - Result;
end;

function TcxHebrewCalendarTable.HebrewNumber(const S: string): Integer;
var
  I, AOrd: Integer;
  ACh: Char;
begin
  Result := 0;
  for I := 1 to Length(S) do
  begin
    ACh := S[I];
    AOrd := Ord(ACh);
    AOrd := AOrd - 223;
    if AOrd <= 0 then
      AOrd := 0;
    case AOrd of
      12:
        AOrd := 20;
      13:
        AOrd := 30;
      14, 15:
        AOrd := 40;
      16, 17:
        AOrd := 50;
      18:
        AOrd := 60;
      19:
        AOrd := 70;
      21, 22:
        AOrd := 80;
      23:
        AOrd := 90;
      24:
        AOrd := 100;
      25:
        AOrd := 200;
      26:
        AOrd := 300;
      27:
        AOrd := 400;
      else
        if AOrd > 10 then
          AOrd := 0;
    end;
    Result := Result + AOrd;
  end;
end;

procedure TcxHebrewCalendarTable.GetLunarMonthDay(AYear: Integer; var ADate: TcxDate);
var
  AIndex: Integer;
begin
  AIndex := AYear - cxHebrewFirstGregorianTableYear;
  AIndex := AIndex * 2;
  ADate.Day := cxHebrewTable[AIndex];
  case (ADate.Day) of
    0:
      begin
        ADate.Day := 1;
        ADate.Month := 5;
      end;
    30:
      ADate.Month := 3;
    31:
      begin
        ADate.Day := 2;
        ADate.Month := 5;
      end;
    32:
      begin
        ADate.Day := 3;
        ADate.Month := 5;
      end;
    33:
      begin
        ADate.Day := 29;
        ADate.Month := 3;
      end;
    else
      ADate.Month := 4;
  end;
end;

function cxIsDateValid(ADate: Double): Boolean;
begin
  Result := (ADate = NullDate) or
    ((ADate >= cxMinDateTime) and (ADate <= cxMaxDateTime));
end;

end.

