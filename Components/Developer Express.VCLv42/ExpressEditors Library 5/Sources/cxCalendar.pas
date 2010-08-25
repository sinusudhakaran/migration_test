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

unit cxCalendar;

{$I cxVer.inc}

interface

uses
  Windows, Messages, ComCtrls,
{$IFDEF DELPHI6}
  Types, Variants, DateUtils,
{$ENDIF}
  SysUtils, Classes, Graphics, Controls, Forms, StdCtrls, Clipbrd,
  cxClasses, cxGraphics, cxControls, cxContainer, cxDataStorage, cxDataUtils,
  cxEdit, cxDropDownEdit, cxTextEdit, cxMaskEdit, cxButtons, cxDateUtils,
  cxEditConsts, cxFormats, cxTimeEdit, cxFilterControlUtils, cxLookAndFeels;

type
  TCalendarButton = (btnClear, btnNow, btnToday, btnOk);
  TDateButton = btnClear..btnToday;
  TDateButtons = set of TDateButton;

  TcxCalendarArrow = (caPrevMonth, caNextMonth, caPrevYear, caNextYear);
  TcxCalendarHotTrackRegion = (chrNone, chrMonth, chrYear);
  TcxCalendarKind = (ckDate, ckDateTime);
  TcxCustomCalendar = class;

  { TcxClock }

  TcxClock = class(TcxControl)
  private
    FMinuteDotColor: TColor;
    FTime: TTime;
    procedure SetMinuteDotColor(Value: TColor);
    procedure SetTime(Value: TTime);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color;
    property MinuteDotColor: TColor read FMinuteDotColor write SetMinuteDotColor
      default clWindow;
    property Time: TTime read FTime write SetTime;
  end;

{ TcxMonthListBox - Bug in Delphi5: Must be in the interface part }

  TcxMonthListBox = class(TcxCustomPopupWindow)
  private
    FCurrentDate: TcxDateTime;
    FOrigin: TPoint;
    FTopMonthDelta: Integer;
    FItemHeight: Integer;
    FItemIndex: Integer;
    FItemCount: Integer;
    FTimer: TcxTimer;
    FSign: Integer;
    procedure DoTimer(Sender: TObject);
    function GetCalendar: TcxCustomCalendar;
    function GetCalendarTable: TcxCustomCalendarTable;
    function GetDate: TDateTime;
    function GetShowYears: Boolean;
    procedure SetItemIndex(Value: Integer);
    procedure SetTopMonthDelta(Value: Integer);
  protected
    function CalculatePosition: TPoint; override;
    procedure Click; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoShowed; override;
    procedure FontChanged;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    property Calendar: TcxCustomCalendar read GetCalendar;
    property CalendarTable: TcxCustomCalendarTable read GetCalendarTable;
    property ItemHeight: Integer read FItemHeight;
    property ItemIndex: Integer read FItemIndex write SetItemIndex;
    property ShowYears: Boolean read GetShowYears;
    property TopMonthDelta: Integer read FTopMonthDelta write SetTopMonthDelta;
  public
    constructor Create(AOwnerControl: TWinControl); override;
    destructor Destroy; override;
    procedure CloseUp; override;
    procedure Popup(AFocusedControl: TWinControl); override;
    property Date: TDateTime read GetDate;
  end;

  { TcxCustomCalendar }

  TcxCalendarViewInfo = record
    ArrowRects: array[TcxCalendarArrow] of TRect;
    CalendarRect: TRect;
    CurrentDateRegion: TRect;
    HeaderRegion: TRect;
    LastVisibleArrow: TcxCalendarArrow;
    MonthRegion: TRect;
    YearRegion: TRect;
  end;

  TcxCustomCalendar = class(TcxControl, IcxMouseTrackingCaller)
  private
    FArrowsForYear: Boolean;
    FButtonsHeight: Integer;
    FButtonsOffset: Integer;
    FButtonsRegionHeight: Integer;
    FButtonWidth: Integer;
    FCalendarButtons: TDateButtons;
    FCalendarTable: TcxCustomCalendarTable;
    FClearButton: TcxButton;
    FClock: TcxClock;
    FClockSize: Integer;
    FColWidth: Integer;
    FDateRegionWidth: Integer;
    FDaysOfWeekHeight: Integer;
    FFirstDate: Double;
    FFlat: Boolean;
    FHeaderHeight: Integer;
    FHotTrackRegion: TcxCalendarHotTrackRegion;
    FKind: TcxCalendarKind;
    FMonthListBox: TcxMonthListBox;
    FNowButton: TcxButton;
    FOKButton: TcxButton;
    FPrevCursor: TCursor;
    FRowHeight: Integer;
    FSelectDate: Double;
    FSideWidth: Integer;
    FSpaceWidth: Integer;
    FTimeEdit: TcxTimeEdit;
    FTimer: TcxTimer;
    FTodayButton: TcxButton;
    FViewInfo: TcxCalendarViewInfo;
    FWeekNumbers: Boolean;
    FWeekNumberWidth: Integer;
    FYearsInMonthList: Boolean;
    FOnDateTimeChanged: TNotifyEvent;
    procedure AdjustCalendarControlsPosition;
    procedure ButtonClick(Sender: TObject);
    procedure CalculateViewInfo;
    procedure CreateButtons;
    procedure CorrectHeaderTextRect(var R: TRect);
    procedure DoDateTimeChanged;
    procedure DoScrollArrow(Sender: TObject);
    procedure DrawHeader;
    function GetDateFromCell(X, Y: Integer): Double;
    function GetDateHeaderFrameColor: TColor;
    function GetDateTimeHeaderFrameColor: TColor;
    function GetHeaderColor: TColor;
    function GetHeaderOffset: TRect;
    function GetLookAndFeel: TcxLookAndFeel;
    function GetShowButtonsRegion: Boolean;
    function GetTimeEditWidth: Integer;
    function GetTimeFormat: TcxTimeEditTimeFormat;
    function GetUse24HourFormat: Boolean;
    function GetWeekNumbersRegionWidth: Integer;
    procedure GetVisibleButtonList(AList: TList);
    procedure SetArrowsForYear(Value: Boolean);
    procedure SetCalendarButtons(Value: TDateButtons);
    procedure SetFlat(Value: Boolean);
    procedure SetHotTrackRegion(Value: TcxCalendarHotTrackRegion);
    procedure SetKind(Value: TcxCalendarKind);
    procedure SetTimeFormat(Value: TcxTimeEditTimeFormat);
    procedure SetUse24HourFormat(Value: Boolean);
    procedure SetWeekNumbers(Value: Boolean);
    procedure TimeChanged(Sender: TObject);
    procedure UpdateCalendarButtonCaptions;
  protected
    procedure DblClick; override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure FontChanged; override;
    function HasBackground: Boolean; override;
    procedure InitControl; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseEnter(AControl: TControl); override;
    procedure MouseLeave(AControl: TControl); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure Calculate; virtual;
    function CanResize(var NewWidth, NewHeight: Integer): Boolean;
      override;
    procedure CheckHotTrack; virtual;
    procedure DoStep(AArrow: TcxCalendarArrow);
    function GetButtonsRegionOffset: Integer; virtual;
    function GetLastDate: Double; virtual;
    function GetMonthCalendarOffset: TPoint; virtual;
    function GetRealFirstDate: Double; virtual;
    function GetRealLastDate: Double; virtual;
    function GetSize: TSize; virtual;
    procedure HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason); virtual;
    procedure InternalSetSelectDate(Value: Double; ARepositionVisibleDates: Boolean);
    function PosToDateTime(P: TPoint): Double; virtual;
    procedure SetFirstDate(Value: Double); virtual;
    procedure SetSelectDate(Value: Double); virtual;
    procedure SetSize;
    procedure StepToFuture;
    procedure StepToPast;

    // IcxMouseTrackingCaller
    procedure MouseTrackingMouseLeave;
    procedure IcxMouseTrackingCaller.MouseLeave = MouseTrackingMouseLeave;

    property CalendarTable: TcxCustomCalendarTable read FCalendarTable;
    property HotTrackRegion: TcxCalendarHotTrackRegion read FHotTrackRegion
      write SetHotTrackRegion;
    property LookAndFeel: TcxLookAndFeel read GetLookAndFeel;
    property ShowButtonsRegion: Boolean read GetShowButtonsRegion;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    // IdxLocalizerListener
    procedure TranslationChanged; override;
    
    property ArrowsForYear: Boolean read FArrowsForYear write SetArrowsForYear
      default True;
    property CalendarButtons: TDateButtons
      read FCalendarButtons write SetCalendarButtons;
    property FirstDate: Double read FFirstDate write SetFirstDate;
    property Flat: Boolean read FFlat write SetFlat default True;
    property Font;
    property Kind: TcxCalendarKind read FKind write SetKind default ckDate;
    property SelectDate: Double read FSelectDate write SetSelectDate;
    property TimeFormat: TcxTimeEditTimeFormat read GetTimeFormat
      write SetTimeFormat default tfHourMinSec;
    property Use24HourFormat: Boolean read GetUse24HourFormat
      write SetUse24HourFormat default True;
    property WeekNumbers: Boolean read FWeekNumbers write SetWeekNumbers
      default False;
    property YearsInMonthList: Boolean read FYearsInMonthList
      write FYearsInMonthList default True;
    property OnDateTimeChanged: TNotifyEvent read FOnDateTimeChanged
      write FOnDateTimeChanged;
  end;

  { TcxPopupCalendar }

  TcxCustomDateEdit = class;

  TcxPopupCalendar = class(TcxCustomCalendar)
  private
    FEdit: TcxCustomDateEdit;
    FOnHidePopup: TcxEditClosePopupEvent;
  protected
    procedure CheckHotTrack; override;
    procedure HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
  public
    property Edit: TcxCustomDateEdit read FEdit write FEdit;
    property OnHidePopup: TcxEditClosePopupEvent read FOnHidePopup write FOnHidePopup;
  end;

  TcxPopupCalendarClass = class of TcxPopupCalendar;

  { TcxDateEditPropertiesValues }

  TcxDateEditPropertiesValues = class(TcxTextEditPropertiesValues)
  private
    FDateButtons: Boolean;
    FInputKind: Boolean;
    function GetMaxDate: Boolean;
    function GetMinDate: Boolean;
    function IsMaxDateStored: Boolean;
    function IsMinDateStored: Boolean;
    procedure SetDateButtons(Value: Boolean);
    procedure SetInputKind(Value: Boolean);
    procedure SetMaxDate(Value: Boolean);
    procedure SetMinDate(Value: Boolean);
  public
    procedure Assign(Source: TPersistent); override;
    procedure RestoreDefaults; override;
  published
    property DateButtons: Boolean read FDateButtons write SetDateButtons
      stored False;
    property InputKind: Boolean read FInputKind write SetInputKind stored False;
    property MaxDate: Boolean read GetMaxDate write SetMaxDate stored IsMaxDateStored;
    property MinDate: Boolean read GetMinDate write SetMinDate stored IsMinDateStored;
  end;

  { TcxCustomDateEditProperties }

  TDateOnError = (deNoChange, deToday, deNull);
  TcxInputKind = (ikStandard, ikMask, ikRegExpr);

  TcxCustomDateEditProperties = class(TcxCustomPopupEditProperties)
  private
    FArrowsForYear: Boolean;
    FDateButtons: TDateButtons;
    FDateOnError: TDateOnError;
    FInputKind: TcxInputKind;
    FKind: TcxCalendarKind;
    FSaveTime: Boolean;
    FShowTime: Boolean;
    FWeekNumbers: Boolean;
    FYearsInMonthList: Boolean;
    procedure BuildEditMask;
    function GetAssignedValues: TcxDateEditPropertiesValues;
    function GetDateButtons: TDateButtons;
    function GetDefaultDateButtons: TDateButtons;
    function GetDefaultInputKind: TcxInputKind;
    function GetInputKind: TcxInputKind;
    function GetMaxDate: TDateTime;
    function GetMinDate: TDateTime;
    function IsDateButtonsStored: Boolean;
    function IsInputKindStored: Boolean;
    function NeedShowTime(ADate: TDateTime; AIsFocused: Boolean): Boolean;
    procedure SetArrowsForYear(Value: Boolean);
    procedure SetAssignedValues(Value: TcxDateEditPropertiesValues);
    procedure SetDateButtons(Value: TDateButtons);
    procedure SetDateOnError(Value: TDateOnError);
    procedure SetInputKind(Value: TcxInputKind);
    procedure SetKind(Value: TcxCalendarKind);
    procedure SetMaxDate(Value: TDateTime);
    procedure SetMinDate(Value: TDateTime);
    procedure SetSaveTime(Value: Boolean);
    procedure SetShowTime(Value: Boolean);
    procedure SetWeekNumbers(Value: Boolean);
    procedure SetYearsInMonthList(Value: Boolean);
  protected
    function GetAlwaysPostEditValue: Boolean; override;
    class function GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass; override;
    function GetDisplayFormatOptions: TcxEditDisplayFormatOptions; override;
    function GetModeClass(AMaskKind: TcxEditMaskKind): TcxMaskEditCustomModeClass; override;
    class function GetPopupWindowClass: TcxCustomEditPopupWindowClass; override;
    function IsEditValueNumeric: Boolean; override;
    function IsValueBoundDefined(ABound: TcxEditValueBound): Boolean; override;
    function IsValueBoundsDefined: Boolean; override;
    function PopupWindowAcceptsAnySize: Boolean; override;
    function GetEmptyDisplayValue(AEditFocused: Boolean): string;
    function GetStandardMaskBlank(APos: Integer): Char; virtual;
    function GetTimeZoneInfo(APos: Integer;
      out AInfo: TcxTimeEditZoneInfo): Boolean; virtual;
    procedure InternalPrepareEditValue(ADisplayValue: string;
      out EditValue: TcxEditValue);
    property AssignedValues: TcxDateEditPropertiesValues read GetAssignedValues
      write SetAssignedValues;
  public
    constructor Create(AOwner: TPersistent); override;
    procedure Assign(Source: TPersistent); override;
    procedure Changed; override;
    class function GetContainerClass: TcxContainerClass; override;
    function GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource; override;
    function IsDisplayValueValid(var DisplayValue: TcxEditValue;
      AEditFocused: Boolean): Boolean; override;
    function IsEditValueValid(var EditValue: TcxEditValue;
      AEditFocused: Boolean): Boolean; override;
    procedure PrepareDisplayValue(const AEditValue: TcxEditValue;
      var DisplayValue: TcxEditValue; AEditFocused: Boolean); override;
    procedure ValidateDisplayValue(var ADisplayValue: TcxEditValue;
      var AErrorText: TCaption; var AError: Boolean;
      AEdit: TcxCustomEdit); override;
    // !!!
    property ArrowsForYear: Boolean read FArrowsForYear
      write SetArrowsForYear default True;
    property DateButtons: TDateButtons read GetDateButtons write SetDateButtons
      stored IsDateButtonsStored;
    property DateOnError: TDateOnError read FDateOnError write SetDateOnError
      default deNoChange;
    property ImmediateDropDown default False;
    property InputKind: TcxInputKind read GetInputKind write SetInputKind
      stored IsInputKindStored;
    property Kind: TcxCalendarKind read FKind write SetKind default ckDate;
    property MaxDate: TDateTime read GetMaxDate write SetMaxDate;
    property MinDate: TDateTime read GetMinDate write SetMinDate;
    property SaveTime: Boolean read FSaveTime write SetSaveTime default True;
    property ShowTime: Boolean read FShowTime write SetShowTime default True;
    property WeekNumbers: Boolean read FWeekNumbers write SetWeekNumbers
      default False;
    property YearsInMonthList: Boolean read FYearsInMonthList
      write SetYearsInMonthList default True;
  end;

  { TcxDateEditProperties }

  TcxDateEditProperties = class(TcxCustomDateEditProperties)
  published
    property Alignment;
    property ArrowsForYear;
    property AssignedValues;
    property AutoSelect;
    property ButtonGlyph;
    property ClearKey;
    property DateButtons;
    property DateOnError;
    property ImeMode;
    property ImeName;
    property ImmediatePost;
    property InputKind;
    property Kind;
    property MaxDate;
    property MinDate;
    property PostPopupValueOnTab;
    property ReadOnly;
    property SaveTime;
    property ShowTime;
    property UseLeftAlignmentOnEditing;
    property ValidateOnEnter;
    property WeekNumbers;
    property YearsInMonthList;
    property OnChange;
    property OnCloseUp;
    property OnEditValueChanged;
    property OnInitPopup;
    property OnPopup;
    property OnValidate;
  end;

  { TcxDateEditPopupWindow }

  TcxDateEditPopupWindow = class(TcxPopupEditPopupWindow)
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function IsPopupCalendarKey(Key: Word; Shift: TShiftState): Boolean; virtual;
  public
    constructor Create(AOwnerControl: TWinControl); override;
  end;

  { TcxDateEditMaskStandardMode }

  TcxDateEditMaskStandardMode = class(TcxMaskEditStandardMode)
  protected
    function GetBlank(APos: Integer): Char; override;
  end;

  { TcxCustomDateEdit }

  TcxCustomDateEdit = class(TcxCustomPopupEdit)
  private
    FDateDropDown: TDateTime;
    FSavedTime: TDateTime;
    procedure DateChange(Sender: TObject);
    function GetActiveProperties: TcxCustomDateEditProperties;
    function GetCurrentDate: TDateTime;
    function GetProperties: TcxCustomDateEditProperties;
    function GetRecognizableDisplayValue(ADate: TDateTime): TcxEditValue;
    procedure SetProperties(Value: TcxCustomDateEditProperties);
  protected
    FCalendar: TcxPopupCalendar;
    function CanSynchronizeModeText: Boolean; override;
    procedure CheckEditorValueBounds; override;
    procedure CreatePopupWindow; override;
//    procedure DoEditKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DropDown; override;
    procedure Initialize; override;
    procedure InitializePopupWindow; override;
    function InternalGetEditingValue: TcxEditValue; override;
    function InternalGetText: string; override;
    procedure InternalSetEditValue(const Value: TcxEditValue;
      AValidateEditValue: Boolean); override;
    function InternalSetText(const Value: string): Boolean; override;
    procedure InternalValidateDisplayValue(const ADisplayValue: TcxEditValue); override;
    function IsCharValidForPos(var AChar: Char; APos: Integer): Boolean; override;
    procedure PopupWindowClosed(Sender: TObject); override;
    procedure PopupWindowShowed(Sender: TObject); override;
    procedure UpdateTextFormatting; override;
    procedure CreateCalendar; virtual;
    function GetCalendarClass: TcxPopupCalendarClass; virtual;
    function GetDate: TDateTime; virtual;
    function GetDateFromStr(const S: string): TDateTime;
    procedure SetDate(Value: TDateTime); virtual;
    procedure SetupPopupWindow; override;
    property Calendar: TcxPopupCalendar read FCalendar;
  public
    destructor Destroy; override;
    procedure Clear; override;
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    procedure PrepareEditValue(const ADisplayValue: TcxEditValue;
      out EditValue: TcxEditValue; AEditFocused: Boolean); override;
    property ActiveProperties: TcxCustomDateEditProperties read GetActiveProperties;
    property CurrentDate: TDateTime read GetCurrentDate;
    property Date: TDateTime read GetDate write SetDate stored False;
    property Properties: TcxCustomDateEditProperties read GetProperties
      write SetProperties;
  end;

  { TcxDateEdit }

  TcxDateEdit = class(TcxCustomDateEdit)
  private
    function GetActiveProperties: TcxDateEditProperties;
    function GetProperties: TcxDateEditProperties;
    procedure SetProperties(Value: TcxDateEditProperties);
  public
    class function GetPropertiesClass: TcxCustomEditPropertiesClass; override;
    property ActiveProperties: TcxDateEditProperties read GetActiveProperties;
  published
    property Anchors;
    property AutoSize;
    property BeepOnEnter;
    property BiDiMode;
    property Constraints;
    property DragCursor;
    property DragKind;
    property Date;
    property DragMode;
    property EditValue;
    property Enabled;
    property ImeMode;
    property ImeName;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Properties: TcxDateEditProperties read GetProperties
      write SetProperties;
    property ShowHint;
    property Style;
    property StyleDisabled;
    property StyleFocused;
    property StyleHot;
    property TabOrder;
    property TabStop default True;
  {$IFDEF DELPHI12}
    property TextHint;
  {$ENDIF}
    property Visible;
    property OnClick;
  {$IFDEF DELPHI5}
    property OnContextPopup;
  {$ENDIF}
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEditing;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDrag;
    property OnStartDock;
  end;

  { TcxFilterDateEditHelper }

  TcxFilterDateEditHelper = class(TcxFilterDropDownEditHelper)
  public
    class function GetFilterEditClass: TcxCustomEditClass; override;
    class function GetSupportedFilterOperators(
      AProperties: TcxCustomEditProperties;
      AValueTypeClass: TcxValueTypeClass;
      AExtendedSet: Boolean = False): TcxFilterControlOperators; override;
    class procedure InitializeProperties(AProperties,
      AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean); override;
  end;

function VarIsNullDate(const AValue: Variant): Boolean;
  
implementation

uses
  Math,
  dxOffice11, dxThemeConsts, dxThemeManager, dxUxTheme,
  cxEditPaintUtils, cxEditUtils, cxLookAndFeelPainters,
  cxSpinEdit, cxVariants, cxGeometry;

type
  TDelimiterOffset = record
    Left, Right: Integer;
  end;

const
  cxEditTimeFormatA: array [TcxTimeEditTimeFormat, Boolean] of string = (
    ('hh:nn:ss ampm', 'hh:nn:ss'),
    ('hh:nn ampm', 'hh:nn'),
    ('hh ampm', 'hh')
  );
  DateNavigatorTime = 200;
  Office11HeaderOffset = 2;

  WeekNumbersDelimiterOffset: TDelimiterOffset = (Left: 3; Right: 1);
  WeekNumbersDelimiterWidth = 1;

function VarIsNullDate(const AValue: Variant): Boolean;
begin
  Result := (VarIsDate(AValue) or VarIsNumericEx(AValue)) and (AValue = NullDate);
end;
  
function cxEncodeDate(AYear, AMonth, ADay: Word): Double;
begin
  if (AYear < MinYear) or (AYear > MaxYear) or
    (AMonth < 1) or (AMonth > 12) or
    (ADay < 1) or (ADay > DaysInAMonth(AYear, AMonth)) then
    Result := InvalidDate
  else
    Result := EncodeDate(AYear, AMonth, ADay);
end;

procedure GetTimeFormat(const ADateTimeFormatInfo: TcxDateTimeFormatInfo;
  out ATimeFormat: TcxTimeEditTimeFormat; out AUse24HourFormat: Boolean);

  function GetFormatInfoItemIndex(
    AItemKind: TcxDateTimeFormatItemKind): Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to Length(ADateTimeFormatInfo.Items) - 1 do
      if ADateTimeFormatInfo.Items[I].Kind = AItemKind then
      begin
        Result := I;
        Break;
      end;
  end;

var
  AFormatInfoItemIndex: Integer;
begin
  if GetFormatInfoItemIndex(dtikSec) <> -1 then
    ATimeFormat := tfHourMinSec
  else if GetFormatInfoItemIndex(dtikMin) <> -1 then
    ATimeFormat := tfHourMin
  else if GetFormatInfoItemIndex(dtikHour) <> -1 then
    ATimeFormat := tfHour
  else
    ATimeFormat := tfHourMinSec;

  AFormatInfoItemIndex := GetFormatInfoItemIndex(dtikHour);
  if AFormatInfoItemIndex <> -1 then
    AUse24HourFormat := Copy(ADateTimeFormatInfo.Items[AFormatInfoItemIndex].Data, 1, 2) = '24'
  else
    AUse24HourFormat := False;
end;

procedure TrueTextRect(ACanvas: TCanvas; R: TRect; X, Y: Integer;
  const Text: WideString);
begin
  ACanvas.TextRect(R, X, Y, Text);
end;

{ TcxClock }

constructor TcxClock.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinuteDotColor := clWindow;
end;

procedure TcxClock.Paint;
begin
  LookAndFeel.Painter.DrawClock(Canvas, ClientRect, TDateTime(FTime), Color);
end;

procedure TcxClock.SetMinuteDotColor(Value: TColor);
begin
  if Value <> FMinuteDotColor then
  begin
    FMinuteDotColor := Value;
    Invalidate;
  end;
end;

procedure TcxClock.SetTime(Value: TTime);
begin
  Value := Frac(Value);
  if Value <> FTime then
  begin
    FTime := Value;
    Invalidate;
  end;
end;

{ TcxMonthListBox }

constructor TcxMonthListBox.Create(AOwnerControl: TWinControl);
begin
  inherited Create(AOwnerControl);
  ControlStyle := [csCaptureMouse, csOpaque];
  if not ShowYears then
    ControlStyle := ControlStyle + [csClickEvents];
  FTimer := TcxTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.Interval := 200;
  FTimer.OnTimer := DoTimer;
  Adjustable := False;
  BorderStyle := pbsFlat;
end;

destructor TcxMonthListBox.Destroy;
begin
  FreeAndNil(FTimer);
  inherited Destroy;
end;

procedure TcxMonthListBox.CloseUp;
var
  ADate: TDateTime;
begin
  if GetCaptureControl = Self then
    SetCaptureControl(nil);
  if not Visible then
    Exit;
  inherited CloseUp;
  FTimer.Enabled := False;
  if ShowYears then
  begin
    ADate := GetDate;
    if ADate <> NullDate then
      Calendar.SetFirstDate(ADate);
  end;
end;

procedure TcxMonthListBox.Popup(AFocusedControl: TWinControl);
var
  R: TRect;
begin
  FCurrentDate := CalendarTable.FromDateTime(Calendar.FirstDate);
  if ShowYears then
    FItemCount := 7
  else
    FItemCount := CalendarTable.GetMonthsInYear(FCurrentDate.Year);
  Font := Calendar.Font;
  FontChanged;
  if ShowYears then
    TopMonthDelta := -3
  else
    TopMonthDelta := 1 - FCurrentDate.Month;
  R := Calendar.FViewInfo.MonthRegion;
  R.TopLeft := Calendar.ClientToScreen(R.TopLeft);
  R.BottomRight := Calendar.ClientToScreen(R.BottomRight);
  FOrigin.X := R.Left + (R.Right - R.Left - Self.Width) div 2;
  FOrigin.Y := (R.Top + R.Bottom) div 2 - Self.Height div 2;
  FItemIndex := -1;
  inherited Popup(AFocusedControl);
end;

procedure TcxMonthListBox.DoTimer(Sender: TObject);
begin
  TopMonthDelta := TopMonthDelta + FSign;
end;

function TcxMonthListBox.GetCalendar: TcxCustomCalendar;
begin
  Result := TcxCustomCalendar(OwnerControl);
end;

function TcxMonthListBox.GetCalendarTable: TcxCustomCalendarTable;
begin
  Result := TcxCustomCalendar(OwnerControl).CalendarTable;
end;

function TcxMonthListBox.GetDate: TDateTime;
var
  ADate: TcxDateTime;
begin
  if ItemIndex = -1 then Result := NullDate
  else
    with CalendarTable do
    begin
      ADate := FromDateTime(AddMonths(FCurrentDate, TopMonthDelta + ItemIndex));
      ADate.Day := 1;
      Result := ToDateTime(ADate);
    end;
end;

function TcxMonthListBox.GetShowYears: Boolean;
begin
  Result := not Calendar.ArrowsForYear or Calendar.YearsInMonthList;
end;

procedure TcxMonthListBox.SetItemIndex(Value: Integer);

  procedure InvalidateItemRect(AIndex: Integer);
  var
    R: TRect;
  begin
    if AIndex <> -1 then
    begin
      R.Left := BorderWidths[bLeft];
      R.Top := AIndex * ItemHeight + BorderWidths[bTop];
      R.Right := Width - BorderWidths[bRight];
      R.Bottom := R.Top + ItemHeight;
      cxInvalidateRect(Handle, R, False);
    end;
  end;

var
  APrevItemIndex: Integer;
begin
  if not HandleAllocated then Exit;
  if FItemIndex <> Value then
  begin
    if FItemIndex <> Value then
    begin
      begin
        APrevItemIndex := FItemIndex;
        FItemIndex := Value;
        InvalidateItemRect(APrevItemIndex);
        InvalidateItemRect(FItemIndex);
      end
    end;
  end;
end;

procedure TcxMonthListBox.SetTopMonthDelta(Value: Integer);
begin
  if FTopMonthDelta <> Value then
  begin
    FTopMonthDelta := Value;
    Repaint;
  end;
end;

function TcxMonthListBox.CalculatePosition: TPoint;
begin
  Result := FOrigin;
end;

procedure TcxMonthListBox.Click;
var
  ADate: TcxDateTime;
begin
  inherited Click;
  CloseUp;
  ADate := CalendarTable.FromDateTime(CalendarTable.AddMonths(FCurrentDate, -FCurrentDate.Month + 1));
  ADate.Day := 1;
  if ItemIndex <> -1 then
    Calendar.SetFirstDate(CalendarTable.AddMonths(CalendarTable.ToDateTime(ADate),
      ItemIndex));
end;

procedure TcxMonthListBox.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params do
    WindowClass.Style := WindowClass.Style or CS_SAVEBITS;
end;

procedure TcxMonthListBox.DoShowed;
begin
  if ShowYears then
    SetCaptureControl(Self)
  else
    SetCaptureControl(nil);
end;

procedure TcxMonthListBox.FontChanged;
begin
  Canvas.Font := Font;
  with Calendar do
  begin
    FItemHeight := FHeaderHeight - 2;
    Self.Width := 6 * FColWidth + 2;
    Self.Height := FItemCount * FItemHeight + 2;
  end;
end;

procedure TcxMonthListBox.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseUp(Button, Shift, X, Y);
  if ShowYears then
    CloseUp;
end;

procedure TcxMonthListBox.MouseMove(Shift: TShiftState; X, Y: Integer);
const
  Times: array[0..3] of UINT = (500, 250, 100, 50);
var
  Delta: Integer;
  Interval: Integer;
begin
  if PtInRect(ClientRect, Point(X, Y)) then
  begin
    FTimer.Enabled := False;
    ItemIndex := Y div ItemHeight;
  end
  else
  begin
    ItemIndex := -1;
    if Y < 0 then Delta := Y
    else
      if Y >= ClientHeight then
        Delta := 1 + Y - ClientHeight
      else
      begin
        FTimer.Enabled := False;
        Exit;
      end;
    FSign := Delta div Abs(Delta);
    Interval := Abs(Delta) div ItemHeight;
    if Interval > 3 then Interval := 3;
    if not FTimer.Enabled or (Times[Interval] <> FTimer.Interval) then
    begin
      FTimer.Interval := Times[Interval];
      FTimer.Enabled := True;
    end;
  end;
end;

procedure TcxMonthListBox.Paint;

  function GetItemColor(ASelected: Boolean): TColor;
  begin
    if ASelected then
      Result := clWindowText
    else
      Result := Calendar.Color;
  end;

var
  ASelected: Boolean;
  R: TRect;
  I: Integer;
  S: string;
  ADate: TcxDateTime;
  AConvertDate: TDateTime;
begin
  Canvas.FrameRect(GetControlRect(Self), clBlack);
  R := Rect(1, 1, Width - 1, ItemHeight + 1);
  ADate := CalendarTable.FromDateTime(CalendarTable.AddMonths(FCurrentDate, TopMonthDelta));
  for I := 0 to FItemCount - 1 do
  begin
    ASelected := I = ItemIndex;
    Canvas.Font.Color := GetItemColor(not ASelected);
    Canvas.Brush.Color := GetItemColor(ASelected);
    Canvas.FillRect(R);
    if CalendarTable.IsValidYear(ADate.Era, ADate.Year) then
    begin
      AConvertDate := CalendarTable.ToDateTime(ADate);
      if ShowYears then
        S := cxGetLocalMonthYear(AConvertDate, CalendarTable)
      else
        S := cxGetLocalMonthName(CalendarTable.ToDateTime(ADate), CalendarTable);
      Canvas.DrawText(S, R, cxAlignCenter or cxSingleLine, True);
    end;
    ADate := CalendarTable.FromDateTime(CalendarTable.AddMonths(ADate, 1));
    OffsetRect(R, 0, ItemHeight);
  end;
end;

{ TcxCustomCalendar }

constructor TcxCustomCalendar.Create(AOwner: TComponent);
var
  ADate: TcxDateTime;
begin
  inherited Create(AOwner);
  ControlStyle := [csCaptureMouse, csOpaque];
  FArrowsForYear := True;
  FHotTrackRegion := chrNone;
  FSelectDate := Date;
  FCalendarTable := cxGetLocalCalendar;
  ADate := FCalendarTable.FromDateTime(FSelectDate);
  ADate.Day := 1;
  FFirstDate := FCalendarTable.ToDateTime(ADate);
  Width := 20;
  Height := 20;
  FTimer := TcxTimer.Create(nil);
  with FTimer do
  begin
    Enabled := False;
    Interval := DateNavigatorTime;
    OnTimer := DoScrollArrow;
  end;
  FMonthListBox := TcxMonthListBox.Create(Self);
  FMonthListBox.CaptureFocus := False;
  FMonthListBox.IsTopMost := True;
  FMonthListBox.OwnerParent := Self;
  Keys := [kAll, kArrows, kChars, kTab];
  CreateButtons;
  FKind := ckDate;
  SetCalendarButtons([btnClear, btnToday]);
  FFlat := True;
  FYearsInMonthList := True;
end;

destructor TcxCustomCalendar.Destroy;
begin
  FreeAndNil(FTimer);
  EndMouseTracking(Self);
  FreeAndNil(FMonthListBox);
  FreeAndNil(FCalendarTable);
  inherited Destroy;
end;

procedure TcxCustomCalendar.TranslationChanged;
begin
  UpdateCalendarButtonCaptions;
  Calculate;
end;

procedure TcxCustomCalendar.AdjustCalendarControlsPosition;

  function GetTodayButtonRect: TRect;
  begin
    Result :=
    {$IFDEF DELPHI6}
      Types.Bounds(
    {$ELSE}
      Classes.Bounds(
    {$ENDIF}
        (Width - FButtonWidth - Byte(FClearButton.Visible) * FButtonWidth) div
         (3 - Byte(not FClearButton.Visible)),
        ClientHeight - FButtonsRegionHeight + FButtonsOffset,
        FButtonWidth + 1, FButtonsHeight);
  end;

  function GetClearButtonRect: TRect;
  begin
    Result :=
    {$IFDEF DELPHI6}
      Types.Bounds(
    {$ELSE}
      Classes.Bounds(
    {$ENDIF}
        Width - FButtonWidth -
        (Width - Byte(FTodayButton.Visible) * FButtonWidth - FButtonWidth) div
         (3 - Byte(not FTodayButton.Visible)),
        ClientHeight - FButtonsRegionHeight + FButtonsOffset,
        FButtonWidth + 1, FButtonsHeight);
  end;

  procedure SetButtonsPosition;
  var
    AButtonLeft, AButtonsOffset, AButtonsTop, I: Integer;
    AList: TList;
  begin
    AList := TList.Create;
    try
      GetVisibleButtonList(AList);

      AButtonsTop := Height - FButtonsRegionHeight + 1 +
        (FButtonsRegionHeight - 1 - FButtonsHeight) div 2;
      AButtonsOffset := MulDiv(Font.Size, 5, 4);

      TButton(AList[AList.Count - 1]).SetBounds(Width - AButtonsOffset -
        FButtonWidth - 1, AButtonsTop, FButtonWidth + 1, FButtonsHeight);
      if AList.Count > 1 then
        if AList.Count = 2 then
          TButton(AList[0]).SetBounds(TButton(AList[1]).Left - AButtonsOffset -
            FButtonWidth - 1, AButtonsTop, FButtonWidth + 1, FButtonsHeight)
        else
        begin
          AButtonLeft := AButtonsOffset;
          for I := 0 to AList.Count - 2 do
          begin
            TButton(AList[I]).SetBounds(AButtonLeft, AButtonsTop,
              FButtonWidth + 1, FButtonsHeight);
            Inc(AButtonLeft, AButtonsOffset + FButtonWidth + 1);
          end;
        end;
    finally
      AList.Free;
    end;
  end;

var
  R: TRect;
  AButtonVOffset: Integer;
begin
  if not HandleAllocated then
    Exit;

  FClearButton.Visible := btnClear in CalendarButtons;
  FNowButton.Visible := (Kind = ckDateTime) and (btnNow in CalendarButtons);
  FOKButton.Visible := Kind = ckDateTime;
  FTodayButton.Visible := btnToday in CalendarButtons;

  FClock.Visible := FOKButton.Visible;
  FTimeEdit.Visible := FOKButton.Visible;

  if Kind = ckDate then
  begin
    R := GetTodayButtonRect;
    FTodayButton.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    R := GetClearButtonRect;
    FClearButton.SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
  end
  else
  begin
    SetButtonsPosition;

    AButtonVOffset := (FButtonsRegionHeight - 1 - FButtonsHeight) div 2;
    FTimeEdit.Top := (Height - FButtonsRegionHeight - FTimeEdit.Height) -
      AButtonVOffset;
    FTimeEdit.Width := GetTimeEditWidth;
    FTimeEdit.Left := Width - (GetMonthCalendarOffset.X + FClockSize + AButtonVOffset * 2) div 2 - FTimeEdit.Width div 2 -
      FSpaceWidth;
    FTimeEdit.SelStart := 0; // refit text
    FClock.SetBounds(Width - GetMonthCalendarOffset.X - AButtonVOffset - FClockSize - FSpaceWidth,
      FHeaderHeight + GetMonthCalendarOffset.Y + AButtonVOffset, FClockSize,
      FClockSize);
  end;
end;

procedure TcxCustomCalendar.ButtonClick(Sender: TObject);
var
  ADate: TDateTime;
begin
  case TCalendarButton(Integer(TcxButton(Sender).Tag)) of
    btnNow: ADate := Now;
    btnToday: ADate := Date + cxSign(Date) * FClock.Time;
    btnClear: ADate := NullDate;
  else
    ADate := SelectDate + cxSign(SelectDate) * FClock.Time;
  end;
  FClock.Time := TTime(TimeOf(ADate));
  FTimeEdit.Time := FClock.Time;
  SelectDate := ADate;
  DoDateTimeChanged;
  HidePopup(Self, crEnter);
end;

procedure TcxCustomCalendar.CalculateViewInfo;

  function GetCurrentDateRegion: TRect;
  begin
    Result := Rect(0, 0, Width, FHeaderHeight);
    if LookAndFeel.Painter = TcxOffice11LookAndFeelPainter then
    begin
      Inc(Result.Left, Office11HeaderOffset);
      Inc(Result.Top, Office11HeaderOffset);
      Dec(Result.Right, Office11HeaderOffset);
    end;
  end;

  function GetMonthCalendarPosition: TPoint;
  begin
    if Kind = ckDateTime then
    begin
      Result := GetMonthCalendarOffset;
      Inc(Result.Y, FViewInfo.CurrentDateRegion.Bottom);
    end
    else
      Result := Point(0, 0);
    Inc(Result.X, FSpaceWidth);
  end;

  procedure OffsetMonthCalendar;
  var
    AArrow: TcxCalendarArrow;
    AOffset: TPoint;
  begin
    AOffset := GetMonthCalendarPosition;
    with FViewInfo do
    begin
      for AArrow := Low(TcxCalendarArrow) to LastVisibleArrow do
        OffsetRect(ArrowRects[AArrow], AOffset.X, AOffset.Y);
      OffsetRect(CalendarRect, AOffset.X, AOffset.Y);
      if Kind = ckDateTime then
        OffsetRect(HeaderRegion, AOffset.X, AOffset.Y);
      OffsetRect(MonthRegion, AOffset.X, AOffset.Y);
      OffsetRect(YearRegion, AOffset.X, AOffset.Y);
    end;
  end;

  function GetHeaderBorderWidth: Integer;
  begin
    if Kind = ckDateTime then
      Result := 1
    else
      Result := Integer(not FFlat);
  end;

  procedure CalculateTwoArrowsViewInfo;
  var
    ABorderWidth: Integer;
    AHeaderOffset: TRect;
  begin
    ABorderWidth := GetHeaderBorderWidth;
    AHeaderOffset := GetHeaderOffset;
    with FViewInfo do
    begin
      ArrowRects[caPrevMonth] := Rect(AHeaderOffset.Left + ABorderWidth,
        AHeaderOffset.Top + ABorderWidth,
        AHeaderOffset.Left + ABorderWidth + FColWidth - 2, AHeaderOffset.Top + FHeaderHeight - 1);
      ArrowRects[caNextMonth] := Rect(FDateRegionWidth - FColWidth + 2 - ABorderWidth - AHeaderOffset.Right,
        AHeaderOffset.Top + ABorderWidth, FDateRegionWidth - ABorderWidth - AHeaderOffset.Right,
        AHeaderOffset.Top + FHeaderHeight - 1);
      MonthRegion := Rect(ArrowRects[caPrevMonth].Right, AHeaderOffset.Top,
        ArrowRects[caNextMonth].Left, AHeaderOffset.Top + FHeaderHeight);
    end;
  end;

  procedure CalculateFourArrowsViewInfo;
  var
    ABorderWidth: Integer;
    AHeaderOffset: TRect;
    AMaxMonthNameWidth, AMonthNameWidth, ASpaceWidth: Integer;
    AYearTextWidth, AMaxYearTextWidth, I: Integer;
    AMonthRegionWidth: Integer;
    AConvertDate: TcxDateTime;
  begin
    ABorderWidth := GetHeaderBorderWidth;
    AHeaderOffset := GetHeaderOffset;
    AMaxMonthNameWidth := 0;
    Canvas.Font := Font;
    AMaxYearTextWidth := 0;
    AConvertDate := CalendarTable.FromDateTime(FirstDate);
    for I := 1 to CalendarTable.GetMonthsInYear(AConvertDate.Era, AConvertDate.Year) do
    begin
      AMonthNameWidth := Canvas.TextWidth(
        cxGetLocalMonthName(CalendarTable.AddMonths(FirstDate, I), CalendarTable));
      if AMonthNameWidth > AMaxMonthNameWidth then
        AMaxMonthNameWidth := AMonthNameWidth;
      AYearTextWidth := Canvas.TextWidth(
        cxGetLocalYear(CalendarTable.AddYears(FirstDate, I), CalendarTable));
      AMaxYearTextWidth := Max(AMaxYearTextWidth, AYearTextWidth);
    end;

    ASpaceWidth := FDateRegionWidth - ABorderWidth * 2 - AHeaderOffset.Left -
      AHeaderOffset.Right - AMaxMonthNameWidth - AMaxYearTextWidth - 4 * (FColWidth - 2);
    with FViewInfo do
    begin
      ArrowRects[caPrevMonth] := Rect(AHeaderOffset.Left + ABorderWidth,
        AHeaderOffset.Top + ABorderWidth,
        AHeaderOffset.Left + ABorderWidth + FColWidth - 2, AHeaderOffset.Top + FHeaderHeight - 1);
      ArrowRects[caNextYear] := Rect(FDateRegionWidth - FColWidth + 2 - ABorderWidth - AHeaderOffset.Right,
        AHeaderOffset.Top + ABorderWidth, FDateRegionWidth - ABorderWidth - AHeaderOffset.Right,
        AHeaderOffset.Top + FHeaderHeight - 1);
    end;
    AMonthRegionWidth := AMaxMonthNameWidth + ASpaceWidth * AMaxMonthNameWidth div
      (AMaxMonthNameWidth + AMaxYearTextWidth);
    with FViewInfo.ArrowRects[caNextMonth] do
    begin
      Left := FViewInfo.ArrowRects[caPrevMonth].Right + AMonthRegionWidth;
      Top := FViewInfo.ArrowRects[caPrevMonth].Top;
      Right := Left + FColWidth - 2;
      Bottom := FViewInfo.ArrowRects[caPrevMonth].Bottom;
    end;
    with FViewInfo do
    begin
      ArrowRects[caPrevYear] := ArrowRects[caNextMonth];
      OffsetRect(ArrowRects[caPrevYear], FColWidth - 2, 0);

      MonthRegion := Rect(ArrowRects[caPrevMonth].Right, AHeaderOffset.Top,
        ArrowRects[caNextMonth].Left, AHeaderOffset.Top + FHeaderHeight);
      YearRegion := Rect(ArrowRects[caPrevYear].Right, AHeaderOffset.Top,
        ArrowRects[caNextYear].Left, AHeaderOffset.Top + FHeaderHeight);
    end;
  end;

  function GetCalendarRect: TRect;
  begin
    with Result do
    begin
      Left := 0;
      Top := FViewInfo.MonthRegion.Bottom + 1;
      Right := FDateRegionWidth;
      Bottom := Top + FDaysOfWeekHeight + 6 * FRowHeight + 1;
    end;
  end;

var
  AHeaderWidth: Integer;
begin
  if Kind = ckDateTime then
  begin
    FViewInfo.CurrentDateRegion := GetCurrentDateRegion;
    AHeaderWidth := FDateRegionWidth;
  end
  else
    AHeaderWidth := Width;
  if ArrowsForYear then
  begin
    FViewInfo.LastVisibleArrow := caNextYear;
    CalculateFourArrowsViewInfo;
  end
  else
  begin
    FViewInfo.LastVisibleArrow := caNextMonth;
    CalculateTwoArrowsViewInfo;
  end;
  with FViewInfo do
    HeaderRegion := Rect(0, MonthRegion.Top, AHeaderWidth,
      MonthRegion.Bottom);
  FViewInfo.CalendarRect := GetCalendarRect;
  OffsetMonthCalendar;
end;

procedure TcxCustomCalendar.CreateButtons;

  function CreateButton(ATabOrder: Integer;
    ATag: TCalendarButton; ADefault: Boolean = False): TcxButton;
  begin
    Result := TcxButton.Create(Self);
    Result.TabOrder := ATabOrder;
    Result.UseSystemPaint := False;
    Result.OnClick := ButtonClick;
    Result.Tag := Integer(ATag);
    Result.Default := ADefault;
  end;

begin
  FTodayButton := CreateButton(1, btnToday);
  FNowButton := CreateButton(2, btnNow);
  FClearButton := CreateButton(3, btnClear);
  FOKButton := CreateButton(4, btnOk, True);
  UpdateCalendarButtonCaptions;

  FTimeEdit := TcxTimeEdit.Create(Self);
  with FTimeEdit do
  begin
    ActiveProperties.Circular := True;
    ActiveProperties.OnChange := TimeChanged;
    TabOrder := 0;
  end;

  FClock := TcxClock.Create(Self);
  FClock.TabStop := False;
  FClock.LookAndFeel.MasterLookAndFeel := LookAndFeel;
end;

procedure TcxCustomCalendar.CorrectHeaderTextRect(var R: TRect);
begin
    if Kind = ckDateTime then
      Inc(R.Top)
    else
      Inc(R.Top, Integer(not Flat));
    Dec(R.Bottom);
end;

procedure TcxCustomCalendar.DoDateTimeChanged;
begin
  if Assigned(FOnDateTimeChanged) then FOnDateTimeChanged(Self);
end;

procedure TcxCustomCalendar.DoScrollArrow(Sender: TObject);
var
  AArrow: TcxCalendarArrow;
  P: TPoint;
begin
  P := ScreenToClient(InternalGetCursorPos);
  for AArrow := caPrevMonth to FViewInfo.LastVisibleArrow do
    if PtInRect(FViewInfo.ArrowRects[AArrow], P) then
      DoStep(AArrow);
end;

procedure TcxCustomCalendar.DrawHeader;
const
  HeaderBorders: array[Boolean] of TcxBorders = ([bBottom], cxBordersAll);
var
  ADate: TcxDateTime;
  AHeaderRect: TRect;
  AIsTransparent: Boolean;
  ASkinPainter: TcxCustomLookAndFeelPainterClass;

  procedure DrawArrows;
  const
    AArrowDirectionMap: array[TcxCalendarArrow] of TcxArrowDirection =
      (adLeft, adRight, adLeft, adRight);
  var
    AArrow: TcxCalendarArrow;
    P: TcxArrowPoints;
    R: TRect;
  begin
    for AArrow := caPrevMonth to FViewInfo.LastVisibleArrow do
    begin
      R := FViewInfo.ArrowRects[AArrow];
      if not AIsTransparent then
      begin
        if FFlat and (Kind = ckDate) then
          InternalPolyLine(Canvas, [Point(R.Left, R.Top), Point(R.Right - 1, R.Top)],
            GetHeaderColor, True);
        InternalPolyLine(Canvas, [Point(R.Left, R.Bottom - 1),
          Point(R.Right - 1, R.Bottom - 1)], GetHeaderColor, True);
        if FFlat and (Kind = ckDate) and (LookAndFeel.Painter <> TcxOffice11LookAndFeelPainter) then
          Inc(R.Top);
        Dec(R.Bottom);
      end;

      if not AIsTransparent then
        cxEditFillRect(Canvas.Handle, R, GetSolidBrush(GetHeaderColor));
      TcxUltraFlatLookAndFeelPainter.CalculateArrowPoints(R, P, AArrowDirectionMap[AArrow], False);
      Canvas.Brush.Color := clBtnText;
      Canvas.Pen.Color := clBtnText;
      Canvas.Polygon(P);

      Canvas.ExcludeClipRect(FViewInfo.ArrowRects[AArrow]);
    end;
  end;

  procedure DrawHeaderText(const S: string; R: TRect; AIsHighlighted: Boolean);
  var
    ATextSize: TSize;
  begin
    if AIsHighlighted then
      Canvas.Font.Color := GetHotTrackColor
    else
      Canvas.Font.Color := LookAndFeel.Painter.DefaultHeaderTextColor;
      
    CorrectHeaderTextRect(R);
    ATextSize := Canvas.TextExtent(S);
    with R do
      TrueTextRect(Canvas.Canvas, R, Left + (Right - Left - ATextSize.cx) div 2,
        Top + (Bottom - Top - ATextSize.cy) div 2, S);
  end;

begin
  ASkinPainter := LookAndFeel.SkinPainter;
  AIsTransparent := (ASkinPainter <> nil) or (LookAndFeel.Painter = TcxWinXPLookAndFeelPainter);
  if ASkinPainter <> nil then
  begin
    ASkinPainter.DrawHeader(Canvas, FViewInfo.HeaderRegion, cxEmptyRect, [],
      HeaderBorders[Kind = ckDateTime], cxbsNormal, taCenter, vaCenter, False,
      False, '', Font, 0, 0);
  end
  else
    if LookAndFeel.Painter = TcxWinXPLookAndFeelPainter then
      DrawThemeBackground(OpenTheme(totHeader), Canvas.Handle, HP_HEADERITEMLEFT,
        HIS_NORMAL, FViewInfo.HeaderRegion)
    else
      if not AIsTransparent then
        cxEditFillRect(Canvas.Handle, FViewInfo.HeaderRegion, GetSolidBrush(GetHeaderColor));
  DrawArrows;

  ADate := CalendarTable.FromDateTime(FirstDate);
  Canvas.Font.Color  := LookAndFeel.Painter.DefaultHeaderTextColor;
  Canvas.Brush.Color := GetHeaderColor;

  if AIsTransparent then
    Canvas.Brush.Style := bsClear;
  if ArrowsForYear then
  begin
    DrawHeaderText(cxGetLocalMonthName(FirstDate, CalendarTable),
      FViewInfo.MonthRegion, HotTrackRegion = chrMonth);
    DrawHeaderText(cxGetLocalYear(FirstDate, CalendarTable),
      FViewInfo.YearRegion, HotTrackRegion = chrYear);
  end
  else
    DrawHeaderText(cxGetLocalMonthYear(FirstDate, CalendarTable),
      FViewInfo.MonthRegion, HotTrackRegion = chrMonth);
  Canvas.Brush.Style := bsSolid;

  AHeaderRect := FViewInfo.HeaderRegion;
  if not AIsTransparent then
    if not FFlat then
      Canvas.DrawEdge(AHeaderRect, False, False, cxBordersAll)
    else
      if Kind = ckDateTime then
        Canvas.FrameRect(AHeaderRect, GetDateTimeHeaderFrameColor)
      else
        if LookAndFeel.Painter = TcxOffice11LookAndFeelPainter then
          Canvas.FrameRect(Rect(AHeaderRect.Left, AHeaderRect.Top - Office11HeaderOffset,
            AHeaderRect.Right, AHeaderRect.Bottom + Office11HeaderOffset - 1),
            Color, Office11HeaderOffset)
        else
          InternalPolyLine(Canvas, [Point(AHeaderRect.Left, AHeaderRect.Bottom - 1),
            Point(AHeaderRect.Right - 1, AHeaderRect.Bottom - 1)],
            GetDateHeaderFrameColor, True);
          
  Canvas.ExcludeClipRect(AHeaderRect);
end;

function TcxCustomCalendar.GetDateHeaderFrameColor: TColor;
begin
  if LookAndFeel.Painter = TcxOffice11LookAndFeelPainter then
    Result := Color
  else
    Result := clBtnText;
end;

function TcxCustomCalendar.GetDateFromCell(X, Y: Integer): Double;
begin
  Result := FirstDate - DayOfWeekOffset(FirstDate) + Y * 7 + X;
  if (DayOfWeekOffset(FirstDate) = 0) and (FirstDate > cxMinDateTime) then
    Result := Result - 7;
end;

function TcxCustomCalendar.GetDateTimeHeaderFrameColor: TColor;
begin
  if LookAndFeel.Painter = TcxOffice11LookAndFeelPainter then
    Result := Color
  else
    Result := clBtnShadow;
end;

function TcxCustomCalendar.GetHeaderColor: TColor;
begin
  if LookAndFeel.Painter = TcxOffice11LookAndFeelPainter then
    Result := TcxOffice11LookAndFeelPainter.DefaultDateNavigatorHeaderColor
  else
    Result := LookAndFeel.Painter.DefaultHeaderColor;
end;

function TcxCustomCalendar.GetHeaderOffset: TRect;
begin
  if (Kind = ckDate) and (LookAndFeel.Painter = TcxOffice11LookAndFeelPainter) then
    Result := Rect(Office11HeaderOffset, Office11HeaderOffset, Office11HeaderOffset, 0)
  else
    Result := cxEmptyRect;
end;

function TcxCustomCalendar.GetLookAndFeel: TcxLookAndFeel;
begin
  Result := FOKButton.LookAndFeel;
end;

function TcxCustomCalendar.GetShowButtonsRegion: Boolean;
begin
  Result := (Kind = ckDateTime) or FTodayButton.Visible
    or FClearButton.Visible;
end;

function TcxCustomCalendar.GetTimeEditWidth: Integer;
var
  AEditSizeProperties: TcxEditSizeProperties;
begin
  AEditSizeProperties := DefaultcxEditSizeProperties;
  AEditSizeProperties.MaxLineCount := 1;
  Result := FTimeEdit.ActiveProperties.GetEditSize(Canvas, FTimeEdit.Style,
    True, 0, AEditSizeProperties).cx + Canvas.TextWidth('0');
end;

function TcxCustomCalendar.GetTimeFormat: TcxTimeEditTimeFormat;
begin
  Result := FTimeEdit.ActiveProperties.TimeFormat;
end;

function TcxCustomCalendar.GetUse24HourFormat: Boolean;
begin
  Result := FTimeEdit.ActiveProperties.Use24HourFormat;
end;

function TcxCustomCalendar.GetWeekNumbersRegionWidth: Integer;
begin
  if WeekNumbers then
    Result := FWeekNumberWidth + WeekNumbersDelimiterOffset.Left +
      WeekNumbersDelimiterWidth + WeekNumbersDelimiterOffset.Right
  else
    Result := 0;
end;

procedure TcxCustomCalendar.GetVisibleButtonList(AList: TList);
begin
  if btnToday in CalendarButtons then
    AList.Add(FTodayButton);
  if (Kind = ckDateTime) and (btnNow in CalendarButtons) then
    AList.Add(FNowButton);
  if btnClear in CalendarButtons then
    AList.Add(FClearButton);
  if Kind = ckDateTime then
    AList.Add(FOKButton);
end;

procedure TcxCustomCalendar.SetArrowsForYear(Value: Boolean);
begin
  if Value <> FArrowsForYear then
  begin
    FArrowsForYear := Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.SetCalendarButtons(Value: TDateButtons);
begin
  if Value <> FCalendarButtons then
  begin
    FCalendarButtons := Value;
    FClearButton.Visible := btnClear in Value;
    FNowButton.Visible := btnNow in Value;
    FTodayButton.Visible := btnToday in Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.SetFlat(Value: Boolean);
begin
  if FFlat <> Value then
  begin
    FFlat := Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.SetHotTrackRegion(Value: TcxCalendarHotTrackRegion);

  function GetHotTrackRegion(AHotTrackRegion: TcxCalendarHotTrackRegion): TRect;
  begin
    if AHotTrackRegion = chrMonth then
      Result := FViewInfo.MonthRegion
    else
      Result := FViewInfo.YearRegion;
  end;

begin
  if Value <> FHotTrackRegion then
  begin
    if FHotTrackRegion <> chrNone then
      InvalidateRect(GetHotTrackRegion(FHotTrackRegion), False);
    FHotTrackRegion := Value;
    if FHotTrackRegion <> chrNone then
      InvalidateRect(GetHotTrackRegion(FHotTrackRegion), False);

    if Value = chrNone then
      Screen.Cursor := FPrevCursor
    else
    begin
      FPrevCursor := Screen.Cursor;
//      Screen.Cursor := crcxEditMouseWheel;
    end;
  end;
end;

procedure TcxCustomCalendar.SetKind(Value: TcxCalendarKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Calculate;
    if Value = ckDate then
      ControlStyle := ControlStyle - [csDoubleClicks, csClickEvents]
    else
      ControlStyle := ControlStyle + [csDoubleClicks, csClickEvents];
  end;
end;

procedure TcxCustomCalendar.SetTimeFormat(Value: TcxTimeEditTimeFormat);
begin
  if Value <> TimeFormat then
  begin
    FTimeEdit.ActiveProperties.TimeFormat := Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.SetUse24HourFormat(Value: Boolean);
begin
  if Value <> Use24HourFormat then
  begin
    FTimeEdit.ActiveProperties.Use24HourFormat := Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.SetWeekNumbers(Value: Boolean);
begin
  if Value <> FWeekNumbers then
  begin
    FWeekNumbers := Value;
    Calculate;
  end;
end;

procedure TcxCustomCalendar.TimeChanged(Sender: TObject);
var
  R: TRect;
begin
  FClock.Time := FTimeEdit.Time;
  R := Rect(0, 0, Width, FHeaderHeight - 1);
  if not FFlat then
    InflateRect(R, -1, -1);
  InvalidateRect(R, False);
end;

procedure TcxCustomCalendar.UpdateCalendarButtonCaptions;
begin
  FTodayButton.Caption := cxGetResourceString(@cxSDatePopupToday);
  FNowButton.Caption := cxGetResourceString(@cxSDatePopupNow);
  FClearButton.Caption := cxGetResourceString(@cxSDatePopupClear);
  FOKButton.Caption := cxGetResourceString(@cxSDatePopupOK);
end;

procedure TcxCustomCalendar.FontChanged;
begin
  inherited FontChanged;
  Calculate;
end;

procedure TcxCustomCalendar.DblClick;
var
  ADate: TDateTime;
begin
  inherited DblClick;
  if Kind = ckDateTime then
  begin
    ADate := PosToDateTime(ScreenToClient(InternalGetCursorPos));
    if ADate <> NullDate then
    begin
      SelectDate := ADate;
      DoDateTimeChanged;
      HidePopup(Self, crEnter);
    end;
  end;
end;

function TcxCustomCalendar.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
const
  AArrowMap: array[Boolean, Boolean] of TcxCalendarArrow =
    ((caPrevMonth, caNextMonth), (caPrevYear, caNextYear));
begin
  Result := inherited DoMouseWheel(Shift, WheelDelta, MousePos);
  MousePos := ScreenToClient(MousePos);
  if not Result and not FMonthListBox.IsVisible and (PtInRect(FViewInfo.MonthRegion, MousePos) or
    PtInRect(FViewInfo.YearRegion, MousePos)) then
  begin
    Result := True;
    DoStep(AArrowMap[PtInRect(FViewInfo.YearRegion, MousePos), WheelDelta < 0]);
  end;
end;

function TcxCustomCalendar.HasBackground: Boolean;
begin
  // for correctly work with manifest
  Result := FTodayButton.LookAndFeel.NativeStyle and AreVisualStylesAvailable;
end;

procedure TcxCustomCalendar.InitControl;
begin
  inherited InitControl;
  FClearButton.Parent := Self;
  FOKButton.Parent := Self;
  FNowButton.Parent := Self;
  FTodayButton.Parent := Self;
  FClock.Parent := Self;
  FTimeEdit.Parent := Self;
  FontChanged;
end;

procedure TcxCustomCalendar.KeyDown(var Key: Word; Shift: TShiftState);
var
  ADate: TcxDateTime;

  procedure MoveByMonth(AForward: Boolean);
  begin
    ADate := CalendarTable.FromDateTime(SelectDate);
    if AForward then
      SelectDate := CalendarTable.AddMonths(SelectDate, 1)
    else
      SelectDate := CalendarTable.AddMonths(SelectDate, -1);
  end;

begin
  ADate := CalendarTable.FromDateTime(SelectDate);
  case Key of
    VK_LEFT:
        SelectDate := SelectDate - 1;
    VK_RIGHT: SelectDate := SelectDate + 1;
    VK_UP:
      if not (Shift = [ssAlt]) then SelectDate := SelectDate - 7;
    VK_DOWN:
      if not (Shift = [ssAlt]) then SelectDate := SelectDate + 7;
    VK_HOME:
      if Shift = [ssCtrl] then
      begin
        ADate.Day := 1;
        SelectDate := CalendarTable.ToDateTime(ADate);
      end
      else
        SelectDate := SelectDate - DayOfWeekOffset(SelectDate);
    VK_END:
      if Shift = [ssCtrl] then
      begin
        ADate.Day := CalendarTable.GetDaysInMonth(ADate.Era, ADate.Year, ADate.Month);
        SelectDate := CalendarTable.ToDateTime(ADate);
      end
      else SelectDate := SelectDate + (6 - DayOfWeekOffset(SelectDate));
    VK_PRIOR: MoveByMonth(False);
    VK_NEXT: MoveByMonth(True)
  end;
  inherited KeyDown(Key, Shift);
end;

procedure TcxCustomCalendar.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

  function GetMonthPopupRect: TRect;
  begin
    Result := FViewInfo.MonthRegion;
    CorrectHeaderTextRect(Result);
  end;

var
  ADate: Double;
  AArrow: TcxCalendarArrow;
  P: TPoint;
begin
  inherited MouseDown(Button, Shift, X, Y);
  CheckHotTrack;
  if Button <> mbLeft then
    Exit;
  P := Point(X, Y);
  ADate := PosToDateTime(P);
  if ADate <> NullDate then
    InternalSetSelectDate(ADate, False)
  else
  begin
    for AArrow := caPrevMonth to FViewInfo.LastVisibleArrow do
      if PtInRect(FViewInfo.ArrowRects[AArrow], P) then
      begin
        DoStep(AArrow);
        FTimer.Enabled := True;
        Exit;
      end;
    if PtInRect(GetMonthPopupRect, P) then
      FMonthListBox.Popup(Self);
  end;
end;

procedure TcxCustomCalendar.MouseEnter(AControl: TControl);
begin
  inherited MouseEnter(AControl);
  CheckHotTrack;
  BeginMouseTracking(Self, GetControlRect(Self), Self);
end;

procedure TcxCustomCalendar.MouseLeave(AControl: TControl);
begin
  inherited MouseLeave(AControl);
  CheckHotTrack;
  EndMouseTracking(Self);
end;

procedure TcxCustomCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ADate: Double;
begin
  CheckHotTrack;
  BeginMouseTracking(Self, GetControlRect(Self), Self);
  if FTimer.Enabled then
    Exit;
  ADate := NullDate;
  if ssLeft in Shift then
    ADate := PosToDateTime(Point(X, Y));
  inherited MouseMove(Shift, X, Y);
  if (ssLeft in Shift) and (ADate <> NullDate) then
    InternalSetSelectDate(ADate, False);
end;

procedure TcxCustomCalendar.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);

  function GetMonthRegion: TRect;
  begin
    Result := FViewInfo.MonthRegion;
    CorrectHeaderTextRect(Result);
  end;

  function GetYearRegion: TRect;
  begin
    Result := FViewInfo.YearRegion;
    CorrectHeaderTextRect(Result);
  end;

var
  P: TPoint;
begin
  inherited MouseUp(Button, Shift, X, Y);
  CheckHotTrack;
  if FTimer.Enabled then
  begin
    FTimer.Enabled := False;
    Exit;
  end;
  P := Point(X, Y);
  if (Kind = ckDate) and PtInRect(ClientRect, P) and
    not PtInRect(GetMonthRegion, P) and not PtInRect(GetYearRegion, P) then
  begin
    if PosToDateTime(P) <> NullDate then
      DoDateTimeChanged;
    HidePopup(Self, crEnter);
  end;
  if (Kind = ckDateTime) and (SelectDate <> NullDate) then
    FirstDate := DateOf(SelectDate);
end;

procedure TcxCustomCalendar.Paint;  

  procedure DrawCurrentDateRegion;
  var
    ATextSize: TSize;
    R: TRect;
    S: string;
  begin
    R := FViewInfo.CurrentDateRegion;
    if LookAndFeel.SkinPainter <> nil then
    begin
      InflateRect(R, 1, 0);
      LookAndFeel.Painter.DrawHeader(Canvas, R, cxEmptyRect, [], [], cxbsNormal, taCenter,
        vaCenter, False, False, '', Font, 0, 0)
    end    
    else
      if LookAndFeel.Painter = TcxWinXPLookAndFeelPainter then
        DrawThemeBackground(OpenTheme(totHeader), Canvas.Handle,
          HP_HEADERITEMLEFT, HIS_NORMAL, R)
      else
        if LookAndFeel.Painter <> TcxOffice11LookAndFeelPainter then
        begin
          if FFlat then
          begin
            with R do
              InternalPolyLine(Canvas, [Point(Left, Bottom - 1),
                Point(Right - 1, Bottom - 1)], clBtnText, True);
            Dec(R.Bottom);
          end
          else
          begin
            Canvas.DrawEdge(R, False, False, cxBordersAll);
            InflateRect(R, -1, -1);
          end;
        end;
        
    S := cxDateToLocalFormatStr(SelectDate + cxSign(SelectDate) * FTimeEdit.Time);
    Canvas.Font := Font;
    Canvas.Font.Color := LookAndFeel.Painter.DefaultHeaderTextColor;
    Canvas.Brush.Color := GetHeaderColor;
    ATextSize := Canvas.TextExtent(S);
    if (LookAndFeel.SkinPainter <> nil) or (LookAndFeel.Painter = TcxWinXPLookAndFeelPainter) then
      Canvas.Brush.Style := bsClear;
    TrueTextRect(Canvas.Canvas, R, R.Left + (R.Right - R.Left - ATextSize.cx) div 2,
      R.Top + (R.Bottom - R.Top - ATextSize.cy) div 2, S);
    Canvas.Brush.Style := bsSolid;
    Canvas.ExcludeClipRect(FViewInfo.CurrentDateRegion);
  end;

  procedure DrawWeekNumbers;
  var
    I: Integer;
    R: TRect;
  begin
    if not WeekNumbers then
      Exit;
    Canvas.Brush.Color := Color;
    Canvas.Font := Font;
    Canvas.Font.Size := MulDiv(Canvas.Font.Size, 2, 3);
    for I := 0 to 5 do
    begin
      if not cxIsDateValid(GetDateFromCell(0, I)) then
        Continue;
      R.Left := FViewInfo.CalendarRect.Left + FSideWidth;
      R.Top := FViewInfo.CalendarRect.Top + FDaysOfWeekHeight + FRowHeight * I;
      R.Right := R.Left + FWeekNumberWidth;
      R.Bottom := R.Top + FRowHeight;

      Canvas.DrawTexT(IntToStr(CalendarTable.GetWeekNumber(GetDateFromCell(0, I),
        TDay(cxFormatController.StartOfWeek), cxFormatController.FirstWeekOfYear)),
        R, cxAlignRight or cxAlignVCenter);
    end;
    Canvas.Font := Font;
  end;

  procedure DrawMonth;
  var
    ACurDate, ADate, ALastDate: Double;
    ASelected: Boolean;
    ASideRect, ATextRect, R: TRect;
    ASize: TSize;
    AWeekNumbersDelimiterPos, I, J: Integer;
    S: string;
  begin
    ACurDate := Date;
    ALastDate := GetLastDate;
    with Canvas do
    begin
      // write first letters of day's names
      Brush.Color := Self.Color;
      R := FViewInfo.CalendarRect;
      with ATextRect do
      begin
        Left := R.Left + FSideWidth + GetWeekNumbersRegionWidth;
        Right := R.Right - FSideWidth;
        Top := R.Top;
        Bottom := Top + FDaysOfWeekHeight - 2;
        FillRect(Rect(Left - 8, Top, Left, Bottom + 2));
        FillRect(Rect(Right, Top, Right + 8, Bottom + 2));

        InternalPolyLine(Self.Canvas, [Point(Left, Bottom),
          Point(Right - 1, Bottom)], clBtnShadow, True);
        InternalPolyLine(Self.Canvas, [Point(Left, Bottom + 1),
          Point(Right - 1, Bottom + 1)], clWindow, True);
        if (Kind = ckDate) and ShowButtonsRegion then
          InternalPolyLine(Self.Canvas, [Point(Left, ClientHeight - FButtonsRegionHeight - 1),
            Point(Right - 1, ClientHeight - FButtonsRegionHeight - 1)], clBtnShadow, True);
        if WeekNumbers then
        begin
          AWeekNumbersDelimiterPos := R.Left + FSideWidth + FWeekNumberWidth + WeekNumbersDelimiterOffset.Left;
          Brush.Color := Self.Color;
          FillRect(Rect(R.Left, Top, AWeekNumbersDelimiterPos, R.Bottom));
          InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos, R.Top),
            Point(AWeekNumbersDelimiterPos, Bottom - 1)], Self.Color, True);
          if (Kind = ckDate) and ShowButtonsRegion then
          begin
            InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos, Bottom),
              Point(AWeekNumbersDelimiterPos, ClientHeight - FButtonsRegionHeight - 1)], clBtnShadow, True);
            InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos + 1, ClientHeight - FButtonsRegionHeight - 1),
              Point(AWeekNumbersDelimiterPos + 1, ClientHeight - FButtonsRegionHeight - 1)], clBtnShadow, True);
          end
          else
          begin
            InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos, Bottom),
              Point(AWeekNumbersDelimiterPos, R.Bottom - 3)], clBtnShadow, True);
            InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos, R.Bottom - 2),
              Point(AWeekNumbersDelimiterPos, R.Bottom - 2)], Self.Color, True);
          end;
          InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos + 1, Bottom),
            Point(AWeekNumbersDelimiterPos + 1, Bottom)], clBtnShadow, True);
          InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos + 1, Bottom + 1),
            Point(AWeekNumbersDelimiterPos + 1, Bottom + 1)], clWindow, True);
          InternalPolyLine(Self.Canvas, [Point(AWeekNumbersDelimiterPos + 1, Bottom + 2),
            Point(AWeekNumbersDelimiterPos + 1, R.Bottom - 2)], Self.Color, True);
        end;

        Right := Left;
      end;
      Font.Color := clBtnText;
      for I := cxFormatController.StartOfWeek to cxFormatController.StartOfWeek + 6 do
      begin
        ATextRect.Left := ATextRect.Right;
        ATextRect.Right := ATextRect.Left + FColWidth;
        J := I;
        if J > 7 then
          Dec(J, 7)
        else
          if J <= 0 then
            Inc(J, 7);
        S := cxGetDayOfWeekName(J, Font.Charset);
        ASize := TextExtent(S);
        TrueTextRect(Canvas, ATextRect, ATextRect.Right - 3 - ASize.cx, (ATextRect.Top + ATextRect.Bottom - ASize.cy) div 2, S);
      end;
      // write numbers of days
      for I := 0 to 6 do
        for J := 0 to 5 do
        begin
          ATextRect.Left := R.Left + FSideWidth + GetWeekNumbersRegionWidth + I * FColWidth;
          ATextRect.Top := R.Top + FDaysOfWeekHeight + J * FRowHeight;
          ATextRect.Right := ATextRect.Left + FColWidth;
          ATextRect.Bottom := ATextRect.Top + FRowHeight;
          ADate := GetDateFromCell(I, J);
          ASelected := (ADate = FSelectDate) or
            ((FSelectDate = NullDate) and (ADate = ACurDate));
          ASideRect := ATextRect;
          // draw frame around current date
          if (ADate = ACurDate) or (ACurDate = NullDate) then
          begin
            FrameRect(ATextRect, clMaroon);
            InflateRect(ATextRect, -1, -1);
          end;
          if ASelected then
            Brush.Color := LookAndFeel.Painter.DefaultDateNavigatorSelectionColor
          else
            Brush.Color := Self.Color;
          // draw text of day's number
          if not ASelected and ((ADate < FirstDate) or (ADate > ALastDate)) then
            Font.Color :=  clGrayText
          else
            if ASelected then
              Font.Color := LookAndFeel.Painter.DefaultDateNavigatorSelectionTextColor
            else
              Font.Color := clWindowText;
          if CalendarTable.IsValidDate(ADate) then
            S := cxDayNumberToLocalFormatStr(ADate)
          else
            S := '';
          ASize := TextExtent(S);
          TrueTextRect(Canvas, ATextRect, ASideRect.Right - 3 - ASize.cx, (ASideRect.Top + ASideRect.Bottom - ASize.cy) div 2, S);
        end;

      DrawWeekNumbers;

      ExcludeClipRect(Rect(R.Left + FSideWidth, R.Top, R.Right - FSideWidth, R.Bottom - 1));
    end;
  end;

  procedure DrawButtonsRegion;
  var
    R, R1: TRect;
    ABorderColor: TColor;
  begin
    R := Rect(0, Height - FButtonsRegionHeight, Width, Height);
    R1 := R;
    ABorderColor := LookAndFeel.Painter.GetContainerBorderColor(False);
    if ABorderColor = clDefault then
      ABorderColor := clBtnText;
    with R1 do
      InternalPolyLine(Canvas, [Point(Left, Top), Point(Right - 1, Top)],
        ABorderColor, True);
    Inc(R1.Top);
    if not FFlat then
    begin
      Canvas.DrawEdge(R1, False, False, cxBordersAll);
      InflateRect(R1, -1, -1);
    end;
    cxEditFillRect(Canvas.Handle, R1, GetSolidBrush(Color));
    Canvas.ExcludeClipRect(R);
  end;

  procedure DrawDateTimeRegionsDelimiter;
  var
    X: Integer;
  begin
    X := FViewInfo.CalendarRect.Right + FColWidth div 2 + FSpaceWidth;
    InternalPolyLine(Canvas, [Point(X, FViewInfo.CalendarRect.Top), Point(X, FTimeEdit.Top + FTimeEdit.Height - 1)], clBtnShadow, True);
  end;

var
  R: TRect;
begin
    with Canvas do
    begin
      if Kind = ckDateTime then
        DrawCurrentDateRegion;
      DrawHeader;
      DrawMonth;
      if (Kind = ckDate) and ShowButtonsRegion then
      begin
        R := cxRectBounds(FSideWidth + FSpaceWidth, ClientHeight - FButtonsRegionHeight - 1,
          FDateRegionWidth - FSideWidth * 2, 1);
        ExcludeClipRect(R);
      end;
      if Kind = ckDateTime then
        DrawButtonsRegion;
      Brush.Color := Self.Color;
      FillRect(ClientRect);
      if Kind = ckDateTime then
        DrawDateTimeRegionsDelimiter;
    end;
{$IFDEF DELPHI7}
  Canvas.SetClipRegion(TcxRegion.Create(GetControlRect(Self)), roSet);
{$ENDIF}
end;

procedure TcxCustomCalendar.Calculate;

  procedure AdjustCalendarControls;
  var
    AHasKeyboardNavigation: Boolean;
  begin
    AHasKeyboardNavigation := Kind = ckDateTime;

    FTodayButton.TabStop := AHasKeyboardNavigation;
    FTodayButton.TabOrder := 1;

    FNowButton.TabStop := AHasKeyboardNavigation;
    FNowButton.TabOrder := 2;

    FClearButton.TabStop := AHasKeyboardNavigation;
    FClearButton.TabOrder := 3;

    FOKButton.TabStop := AHasKeyboardNavigation;
    FOKButton.TabOrder := 4;

    FTimeEdit.TabStop := AHasKeyboardNavigation;
    FTimeEdit.TabOrder := 0;
    if AHasKeyboardNavigation then
      Keys := Keys - [kTab]
    else
      Keys := Keys + [kTab];
  end;

  procedure CalculateButtonWidth;
  var
    AVisibleButtonList: TList;
    I: Integer;
  begin
    AVisibleButtonList := TList.Create;
    try
      GetVisibleButtonList(AVisibleButtonList);
      FButtonWidth := 0;
      for I := 0 to AVisibleButtonList.Count - 1 do
        FButtonWidth := Max(FButtonWidth,
          Canvas.TextWidth(TcxButton(AVisibleButtonList[I]).Caption));
      Inc(FButtonWidth, FColWidth);
    finally
      AVisibleButtonList.Free;
    end;
  end;

begin
  if not HandleAllocated then
    Exit;

  AdjustCalendarControls;

  Canvas.Font := Font;
  Canvas.Font.Size := MulDiv(Canvas.Font.Size, 2, 3);
  FWeekNumberWidth := Canvas.TextWidth('99');
  Canvas.Font := Font;

  FColWidth := 3 * Canvas.TextWidth('0');
  FSideWidth := 2 * Canvas.TextWidth('0');
  FRowHeight := Canvas.TextHeight('0') + 2;
  FHeaderHeight := FRowHeight + 3;
  if (Kind = ckDate) and (LookAndFeel.Painter = TcxOffice11LookAndFeelPainter) then
    Dec(FHeaderHeight);
  FDaysOfWeekHeight := FRowHeight + 1;

  CalculateButtonWidth;

  FButtonsOffset := Font.Size div 2;
  FButtonsHeight := MulDiv(Canvas.TextHeight('Wg'), 20, 13) + 1;
  if Kind = ckDateTime then
  begin
    FButtonsRegionHeight := MulDiv(Font.Size, 5, 4) + 1;
    if not Odd(FButtonsRegionHeight) then
      Inc(FButtonsRegionHeight);
    Inc(FButtonsRegionHeight, FButtonsHeight);
  end
  else
    FButtonsRegionHeight := FButtonsOffset + (FButtonsHeight - 1) +
      MulDiv(Font.Size, 3, 4);

  SetSize;
  CalculateViewInfo;
  Invalidate;
end;

function TcxCustomCalendar.CanResize(var NewWidth, NewHeight: Integer): Boolean;
var
  ASize: TSize;
begin
  ASize := GetSize;
  NewWidth := ASize.cx;
  NewHeight := ASize.cy;
  Result := True;
end;

procedure TcxCustomCalendar.CheckHotTrack;
var
  P: TPoint;
begin
  if FMonthListBox.IsVisible then
    HotTrackRegion := chrNone
  else
    if GetCaptureControl = nil then
    begin
      P := ScreenToClient(InternalGetCursorPos);
      if PtInRect(FViewInfo.MonthRegion, P) then
        HotTrackRegion := chrMonth
      else
        if PtInRect(FViewInfo.YearRegion, P) then
          HotTrackRegion := chrYear
        else
          HotTrackRegion := chrNone
    end
    else
      HotTrackRegion := chrNone;
end;

procedure TcxCustomCalendar.DoStep(AArrow: TcxCalendarArrow);
begin
  FirstDate := InvalidDate;
  case AArrow of
    caPrevMonth:
      FirstDate := CalendarTable.AddMonths(FirstDate, -1);
    caNextMonth:
      FirstDate := CalendarTable.AddMonths(FirstDate, 1);
    caPrevYear:
      FirstDate := CalendarTable.AddYears(FirstDate, -1);
    caNextYear:
      FirstDate := CalendarTable.AddYears(FirstDate, 1);
  end;
end;

function TcxCustomCalendar.GetButtonsRegionOffset: Integer;
begin
  Result := Font.Size div 2;
end;

function TcxCustomCalendar.GetLastDate: Double;
var
  ADate: TcxDateTime;
begin
  ADate := CalendarTable.FromDateTime(FirstDate);
  ADate.Day := CalendarTable.GetDaysInMonth(ADate.Year, ADate.Month);
  Result := CalendarTable.ToDateTime(ADate);
end;

function TcxCustomCalendar.GetMonthCalendarOffset: TPoint;
begin
  Result.X := MulDiv(Font.Size, 3, 4);
  Result.Y := Result.X;
end;

function TcxCustomCalendar.GetRealFirstDate: Double;
var
  ACol: Integer;
begin
  Result := FirstDate;
  ACol := DayOfWeekOffset(FirstDate);
  if ACol = 0 then
    Result := Result - 7
  else
    Result := Result - ACol;
end;

function TcxCustomCalendar.GetRealLastDate: Double;
var
  Year, Month, Day: Word;
  ACol: Integer;
begin
  Result := GetLastDate;
  DecodeDate(Result, Year, Month, Day);
  ACol := DayOfWeekOffset(EncodeDate(Year, Month, 1));
  Result := Result + 6 * 7 - DaysPerMonth(Year, Month) - ACol;
  if ACol = 0 then Result := Result - 7;
end;

function TcxCustomCalendar.GetSize: TSize;

  function GetButtonsWidth: Integer;
  var
    AVisibleButtonList: TList;
  begin
    AVisibleButtonList := TList.Create;
    try
      GetVisibleButtonList(AVisibleButtonList);
      Result := (FButtonWidth + FColWidth) * AVisibleButtonList.Count + FColWidth;
    finally
      AVisibleButtonList.Free;
    end;
  end;

  function GetTimeRegionWidth: Integer;
  var
    AButtonVOffset, ATimeEditWidth: Integer;
  begin
    AButtonVOffset := (FButtonsRegionHeight - 1 - FButtonsHeight) div 2;

    FClockSize := Height - FHeaderHeight - GetMonthCalendarOffset.Y -
      FButtonsRegionHeight - FTimeEdit.Height - AButtonVOffset * 3;
    Result := FClockSize;
    ATimeEditWidth := GetTimeEditWidth;
    if Result < ATimeEditWidth then
      Result := ATimeEditWidth;
    Inc(Result, AButtonVOffset * 2);
  end;

begin
  Result.cy := (FHeaderHeight + 1) + (FDaysOfWeekHeight + 6 * FRowHeight);
  if ShowButtonsRegion then
    Result.cy := Result.cy + FButtonsRegionHeight;
  if Kind = ckDateTime then
    Result.cy := Result.cy + FHeaderHeight + GetMonthCalendarOffset.Y +
      GetButtonsRegionOffset
  else
    Result.cy := Result.cy + 1;
  Result.cy := Result.cy + GetHeaderOffset.Top;

  FDateRegionWidth := 2 * FSideWidth + 7 * FColWidth + GetWeekNumbersRegionWidth;
  Result.cx := FDateRegionWidth;
  if Kind = ckDateTime then
    Result.cx := Result.cx + GetMonthCalendarOffset.X * 2 + FColWidth +
      GetTimeRegionWidth;
  if Result.cx < GetButtonsWidth then
  begin
    FSpaceWidth := (GetButtonsWidth - Result.cx) div 2;
    if Kind = ckDateTime then
      FSpaceWidth := FSpaceWidth div 2;
    Result.cx := GetButtonsWidth;
  end
  else
    FSpaceWidth := 0;
end;

procedure TcxCustomCalendar.HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason);
begin
  FTimer.Enabled := False;
  FMonthListBox.FTimer.Enabled := False;
  if FMonthListBox.Showing then FMonthListBox.CloseUp;
end;

procedure TcxCustomCalendar.InternalSetSelectDate(Value: Double;
  ARepositionVisibleDates: Boolean);
var
  R: TRect;
begin
  if (FSelectDate <> Value) and cxIsDateValid(Value) then
  begin
    FSelectDate := Value;
    if ARepositionVisibleDates and (Value <> NullDate) then
      FirstDate := DateOf(FSelectDate);
    if ARepositionVisibleDates or (Kind = ckDateTime) then
      Repaint
    else
    begin
      R := FViewInfo.CalendarRect;
      Inc(R.Top, FDaysOfWeekHeight);
      InvalidateRect(R, False);
    end;
  end;
end;

function TcxCustomCalendar.PosToDateTime(P: TPoint): Double;
var
  X, Y: Integer;
  R: TRect;
begin
  if PtInRect(ClientRect, P) then
  begin
    R := FViewInfo.CalendarRect;
    with R do
    begin
      Inc(Top, FDaysOfWeekHeight);
      Inc(Left, FSideWidth + GetWeekNumbersRegionWidth);
      Dec(Right, FSideWidth);
      Bottom := Top + 6 * FRowHeight;
      if PtInRect(R, P) then
      begin
        Dec(P.X, Left);
        Dec(P.Y, Top);
        X := P.X div FColWidth;
        Y := P.Y div FRowHeight;
        Result := GetDateFromCell(X, Y);
      end
      else Result := NullDate;
    end;
  end
  else Result := NullDate;
end;

procedure TcxCustomCalendar.SetFirstDate(Value: Double);
var
  ADate: TcxDateTime;
begin
  if not cxIsDateValid(Value) then
    Exit;
  ADate := CalendarTable.FromDateTime(Value);
  ADate.Day := 1;
  Value := CalendarTable.ToDateTime(ADate);
  if FFirstDate <> Value then
  begin
    FFirstDate := Value;
    Repaint;
  end;
end;

procedure TcxCustomCalendar.SetSelectDate(Value: Double);
begin
  InternalSetSelectDate(Value, True);
end;

procedure TcxCustomCalendar.SetSize;
var
  ASize: TSize;
begin
  ASize := GetSize;
  SetBounds(Left, Top, ASize.cx, ASize.cy);
  AdjustCalendarControlsPosition;
end;

procedure TcxCustomCalendar.StepToFuture;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FirstDate, Year, Month, Day);
  IncMonth(Year, Month);
  FirstDate := EncodeDate(Year, Month, 1);
end;

procedure TcxCustomCalendar.StepToPast;
var
  Year, Month, Day: Word;
begin
  DecodeDate(FirstDate, Year, Month, Day);
  DecMonth(Year, Month);
  FirstDate := EncodeDate(Year, Month, 1);
end;

// IcxMouseTrackingCaller
procedure TcxCustomCalendar.MouseTrackingMouseLeave;
begin
  CheckHotTrack;
  EndMouseTracking(Self);
end;

{ TcxPopupCalendar }

procedure TcxPopupCalendar.CheckHotTrack;
begin
  if not Edit.HasPopupWindow then
    HotTrackRegion := chrNone
  else
    inherited CheckHotTrack;
end;

procedure TcxPopupCalendar.HidePopup(Sender: TcxControl; AReason: TcxEditCloseUpReason);
begin
  inherited HidePopup(Sender, AReason);
  if Assigned(FOnHidePopup) then FOnHidePopup(Self, AReason);
end;

procedure TcxPopupCalendar.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  case Key of
    VK_ESCAPE:
      if not FMonthListBox.ShowYears and FMonthListBox.IsVisible then
        FMonthListBox.CloseUp
      else
        HidePopup(Self, crCancel);
    VK_F4:
      if not (ssAlt in Shift) then
        HidePopup(Self, crClose);
    VK_UP, VK_DOWN:
      if Shift = [ssAlt] then
        HidePopup(Self, crClose);
    VK_RETURN:
      if not FMonthListBox.Showing then
      begin
        DoDateTimeChanged;
        HidePopup(Self, crEnter);
      end;
    VK_TAB:
      if TcxCustomDateEditProperties(Edit.Properties).Kind = ckDate then
      begin
        if Edit.ActiveProperties.PostPopupValueOnTab then
          DoDateTimeChanged;
        Edit.DoEditKeyDown(Key, Shift);
      end;
  end;
end;

procedure TcxPopupCalendar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  R: TRect;
begin
  inherited MouseMove(Shift, X, Y);
  if FTimer.Enabled then Exit;
  if (ssLeft in Shift) and not PtInRect(ClientRect, Point(X, Y)) then
  begin
    FSelectDate := TcxCustomDateEdit(Edit).Date;
    R := FViewInfo.CalendarRect;
    Inc(R.Top, FDaysOfWeekHeight);
    InvalidateRect(R, False);
  end;
end;

{ TcxDateEditPropertiesValues }

procedure TcxDateEditPropertiesValues.Assign(Source: TPersistent);
begin
  if Source is TcxDateEditPropertiesValues then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxDateEditPropertiesValues(Source) do
      begin
        Self.DateButtons := DateButtons;
        Self.InputKind := InputKind;
      end;
    finally
      EndUpdate;
    end;
  end
  else
    inherited Assign(Source);
end;

procedure TcxDateEditPropertiesValues.RestoreDefaults;
begin
  BeginUpdate;
  try
    inherited RestoreDefaults;
    DateButtons := False;
    InputKind := False;
  finally
    EndUpdate;
  end;
end;

function TcxDateEditPropertiesValues.GetMaxDate: Boolean;
begin
  Result := MaxValue;
end;

function TcxDateEditPropertiesValues.GetMinDate: Boolean;
begin
  Result := MinValue;
end;

function TcxDateEditPropertiesValues.IsMaxDateStored: Boolean;
begin
  Result := IsMaxValueStored;
end;

function TcxDateEditPropertiesValues.IsMinDateStored: Boolean;
begin
  Result := IsMinValueStored;
end;

procedure TcxDateEditPropertiesValues.SetDateButtons(Value: Boolean);
begin
  if Value <> FDateButtons then
  begin
    FDateButtons := Value;
    Changed;
  end;
end;

procedure TcxDateEditPropertiesValues.SetInputKind(Value: Boolean);
begin
  if Value <> FInputKind then
  begin
    FInputKind := Value;
    Changed;
  end;
end;

procedure TcxDateEditPropertiesValues.SetMaxDate(Value: Boolean);
begin
  MaxValue := Value;
end;

procedure TcxDateEditPropertiesValues.SetMinDate(Value: Boolean);
begin
  MinValue := Value;
end;

{ TcxCustomDateEditProperties }

constructor TcxCustomDateEditProperties.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner);
  FArrowsForYear := True;
  FDateOnError := deNoChange;
  CaseInsensitive := True;
  FKind := ckDate;
  FSaveTime := True;
  FShowTime := True;
  FYearsInMonthList := True;
  ImmediateDropDown := False;
  PopupSizeable := False;
  BuildEditMask;
end;

procedure TcxCustomDateEditProperties.Assign(Source: TPersistent);
begin
  if Source is TcxCustomDateEditProperties then
  begin
    BeginUpdate;
    try
      inherited Assign(Source);
      with TcxCustomDateEditProperties(Source) do
      begin
        Self.ArrowsForYear := ArrowsForYear;

        Self.AssignedValues.DateButtons := False;
        if AssignedValues.DateButtons then
          Self.DateButtons := DateButtons;

        Self.DateOnError := DateOnError;

        Self.AssignedValues.InputKind := False;
        if AssignedValues.InputKind then
          Self.InputKind := InputKind;

        Self.Kind := Kind;
        Self.SaveTime := SaveTime;
        Self.ShowTime := ShowTime;
        Self.WeekNumbers := WeekNumbers;
        Self.YearsInMonthList := YearsInMonthList;
      end;
    finally
      EndUpdate
    end
  end
  else
    inherited Assign(Source);
end;

procedure TcxCustomDateEditProperties.Changed;
begin
  if not ChangedLocked then
  begin
    BeginUpdate;
    try
      BuildEditMask;
    finally
      EndUpdate(False);
    end;
  end;
  inherited Changed;
end;

procedure TcxCustomDateEditProperties.BuildEditMask;
begin
  LockUpdate(True);
  try
    case InputKind of
      ikMask:
        begin
          MaskKind := emkStandard;
          if Kind = ckDateTime then
            EditMask := cxFormatController.StandardDateTimeEditMask
          else
            EditMask := cxFormatController.StandardDateEditMask;
        end;
      ikRegExpr:
        begin
          MaskKind := emkRegExprEx;
          if Kind = ckDateTime then
            EditMask := cxFormatController.RegExprDateTimeEditMask
          else
            EditMask := cxFormatController.RegExprDateEditMask;
        end;
      else
        EditMask := '';
    end;
  finally
    LockUpdate(False);
  end;
end;

function TcxCustomDateEditProperties.GetAssignedValues: TcxDateEditPropertiesValues;
begin
  Result := TcxDateEditPropertiesValues(FAssignedValues);
end;

function TcxCustomDateEditProperties.GetDateButtons: TDateButtons;
begin
  if AssignedValues.DateButtons then
    Result := FDateButtons
  else
    Result := GetDefaultDateButtons;
end;

function TcxCustomDateEditProperties.GetDefaultDateButtons: TDateButtons;
begin
  if Kind = ckDate then
    Result := [btnClear, btnToday]
  else
    Result := [btnClear, btnNow];
end;

function TcxCustomDateEditProperties.GetDefaultInputKind: TcxInputKind;
begin
  if Kind = ckDate then
    Result := ikRegExpr
  else
    Result := ikMask;
end;

function TcxCustomDateEditProperties.GetInputKind: TcxInputKind;
begin
  if not cxIsGregorianCalendar then
  begin
    Result := ikStandard;
    Exit;
  end;
  if AssignedValues.InputKind then
    Result := FInputKind
  else
    Result := GetDefaultInputKind;
end;

function TcxCustomDateEditProperties.GetMaxDate: TDateTime;
begin
  Result := inherited MaxValue;
end;

function TcxCustomDateEditProperties.GetMinDate: TDateTime;
begin
  Result := inherited MinValue;
end;

function TcxCustomDateEditProperties.IsDateButtonsStored: Boolean;
begin
  Result := AssignedValues.DateButtons;
end;

function TcxCustomDateEditProperties.IsInputKindStored: Boolean;
begin
  Result := AssignedValues.InputKind;
end;

function TcxCustomDateEditProperties.NeedShowTime(ADate: TDateTime;
  AIsFocused: Boolean): Boolean;
begin
  if AIsFocused then
  begin
    if Kind = ckDateTime then
      Result := not((TimeOf(ADate) = 0) and (InputKind <> ikMask))
    else
      Result := ShowTime and (TimeOf(ADate) <> 0) and (InputKind = ikStandard);
  end
  else
    Result := not((Kind = ckDate) and not ShowTime);
end;

procedure TcxCustomDateEditProperties.SetArrowsForYear(Value: Boolean);
begin
  if Value <> FArrowsForYear then
  begin
    FArrowsForYear := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetAssignedValues(
  Value: TcxDateEditPropertiesValues);
begin
  FAssignedValues.Assign(Value);
end;

procedure TcxCustomDateEditProperties.SetDateButtons(Value: TDateButtons);
begin
  if AssignedValues.DateButtons and (Value = FDateButtons) then
    Exit;

  AssignedValues.FDateButtons := True;
  FDateButtons := Value;
  Changed;
end;

procedure TcxCustomDateEditProperties.SetDateOnError(Value: TDateOnError);
begin
  if Value <> FDateOnError then
  begin
    FDateOnError := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetInputKind(Value: TcxInputKind);
begin
  if AssignedValues.InputKind and (Value = FInputKind) then
    Exit;
  AssignedValues.FInputKind := True;
  FInputKind := Value;
  Changed;
end;

procedure TcxCustomDateEditProperties.SetKind(Value: TcxCalendarKind);
begin
  if Value <> FKind then
  begin
    FKind := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetMaxDate(Value: TDateTime);
begin
  inherited MaxValue := Value;
end;

procedure TcxCustomDateEditProperties.SetMinDate(Value: TDateTime);
begin
  inherited MinValue := Value;
end;

procedure TcxCustomDateEditProperties.SetSaveTime(Value: Boolean);
begin
  if Value <> FSaveTime then
  begin
    FSaveTime := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetShowTime(Value: Boolean);
begin
  if Value <> FShowTime then
  begin
    FShowTime := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetWeekNumbers(Value: Boolean);
begin
  if Value <> FWeekNumbers then
  begin
    FWeekNumbers := Value;
    Changed;
  end;
end;

procedure TcxCustomDateEditProperties.SetYearsInMonthList(Value: Boolean);
begin
  if Value <> FYearsInMonthList then
  begin
    FYearsInMonthList := Value;
    Changed;
  end;
end;

function TcxCustomDateEditProperties.GetAlwaysPostEditValue: Boolean;
begin
  Result := True;
end;

class function TcxCustomDateEditProperties.GetAssignedValuesClass: TcxCustomEditPropertiesValuesClass;
begin
  Result := TcxDateEditPropertiesValues;
end;

function TcxCustomDateEditProperties.GetDisplayFormatOptions: TcxEditDisplayFormatOptions;
begin
  Result := [dfoSupports, dfoNoCurrencyValue];
end;

function TcxCustomDateEditProperties.GetModeClass(
  AMaskKind: TcxEditMaskKind): TcxMaskEditCustomModeClass;
begin
  if AMaskKind = emkStandard then
    Result := TcxDateEditMaskStandardMode
  else
    Result := inherited GetModeClass(AMaskKind);
end;

class function TcxCustomDateEditProperties.GetPopupWindowClass: TcxCustomEditPopupWindowClass;
begin
  Result := TcxDateEditPopupWindow;
end;

function TcxCustomDateEditProperties.IsEditValueNumeric: Boolean;
begin
  Result := True;
end;

function TcxCustomDateEditProperties.IsValueBoundDefined(
  ABound: TcxEditValueBound): Boolean;
begin
  if (MinValue <> 0) and (MaxValue <> 0) then
    Result := MinValue < MaxValue
  else
    if ABound = evbMin then
      Result := MinValue <> 0
    else
      Result := MaxValue <> 0;
end;

function TcxCustomDateEditProperties.IsValueBoundsDefined: Boolean;
begin
  if (MinValue <> 0) and (MaxValue <> 0) then
    Result := MinValue < MaxValue
  else
    Result := (MinValue <> 0) or (MaxValue <> 0);
end;

function TcxCustomDateEditProperties.PopupWindowAcceptsAnySize: Boolean;
begin
  Result := False;
end;

function TcxCustomDateEditProperties.GetEmptyDisplayValue(
  AEditFocused: Boolean): string;
var
  ATimeStringLength: Integer;
  S: string;
begin
  Result := GetEmptyString;
  if AEditFocused and (Kind = ckDateTime) and (InputKind = ikMask) and
    not cxFormatController.AssignedStandardDateTimeEditMask then
  begin
    S := DateTimeToTextEx(0, True, True);
    ATimeStringLength := cxFormatController.GetDateTimeStandardMaskStringLength(
      cxFormatController.TimeFormatInfo);
    Delete(Result, Length(Result) - ATimeStringLength + 1, ATimeStringLength);
    Result := Result + Copy(S, Length(S) - ATimeStringLength + 1, ATimeStringLength);
  end;
end;

function TcxCustomDateEditProperties.GetStandardMaskBlank(APos: Integer): Char;
var
  ATimeZoneInfo: TcxTimeEditZoneInfo;
begin
  if not GetTimeZoneInfo(APos, ATimeZoneInfo) then
    Result := ' '
  else
    if ATimeZoneInfo.Kind = tzTimeSuffix then
      Result := #0
    else
      Result := '0';
end;

function TcxCustomDateEditProperties.GetTimeZoneInfo(APos: Integer;
  out AInfo: TcxTimeEditZoneInfo): Boolean;
const
  ATimeZoneKindMap: array[TcxDateTimeFormatItemKind] of TcxTimeEditZoneKind =
    (tzHour, tzHour, tzHour, tzHour, tzHour, tzMin, tzSec, tzHour, tzTimeSuffix,
      tzHour, tzHour);
var
  AItemInfo: TcxDateTimeFormatItemInfo;
begin
  Result := False;
  if (Kind <> ckDateTime) or (InputKind <> ikMask) or
    cxFormatController.AssignedStandardDateTimeEditMask then
      Exit;
  Result := cxFormatController.GetDateTimeFormatItemStandardMaskInfo(
    cxFormatController.DateTimeFormatInfo, APos, AItemInfo);
  Result := Result and (AItemInfo.Kind in [dtikHour, dtikMin, dtikSec, dtikTimeSuffix]);
  if Result then
  begin
    AInfo.Kind := ATimeZoneKindMap[AItemInfo.Kind];
    AInfo.Start := AItemInfo.ItemZoneStart;
    AInfo.Length := AItemInfo.ItemZoneLength;
    AInfo.TimeSuffixKind := AItemInfo.TimeSuffixKind;
    AInfo.Use24HourFormat := not cxFormatController.DateTimeFormatInfo.DefinedItems[dtikTimeSuffix];
  end;
end;

procedure TcxCustomDateEditProperties.InternalPrepareEditValue(
  ADisplayValue: string; out EditValue: TcxEditValue);
var
  ADate: TDateTime;
begin
  EditValue := Null;
  if not InternalCompareString(ADisplayValue, GetEmptyString, True) and
    not InternalCompareString(ADisplayValue, GetEmptyDisplayValue(True), True) then
  begin
// TODO
//    if (TimeFormat = tfHour) and Use24HourFormat then
//      ADisplayValue := ADisplayValue + ':00';
    cxStrToDateTime(ADisplayValue, not cxFormatController.UseDelphiDateTimeFormats,
      ADate);
    if ADate <> NullDate then
      EditValue := ADate
    else
      if DateOnError = deToday then
        if Kind = ckDate then
          EditValue := SysUtils.Date
        else
          EditValue := SysUtils.Now;
  end;
end;

class function TcxCustomDateEditProperties.GetContainerClass: TcxContainerClass;
begin
  Result := TcxDateEdit;
end;

function TcxCustomDateEditProperties.GetEditValueSource(AEditFocused: Boolean): TcxDataEditValueSource;
begin
  Result := GetValueEditorEditValueSource(AEditFocused);
end;

function TcxCustomDateEditProperties.IsDisplayValueValid(var DisplayValue: TcxEditValue;
  AEditFocused: Boolean): Boolean;
var
  ADate: TDateTime;
begin
  // TODO optional symbols
  if InputKind = ikStandard then
  begin
    cxStrToDateTime(VarToStr(DisplayValue),
      not cxFormatController.UseDelphiDateTimeFormats, ADate);
    Result := ADate <> NullDate;
  end
  else
    Result := inherited IsDisplayValueValid(DisplayValue, AEditFocused);
end;

function TcxCustomDateEditProperties.IsEditValueValid(
  var EditValue: TcxEditValue; AEditFocused: Boolean): Boolean;
var
  AValue: TcxEditValue;
begin
  if VarIsStr(EditValue) then
  begin
    try
      InternalPrepareEditValue(EditValue, AValue);
      Result := not VarIsNull(AValue) and not VarIsNullDate(AValue);
    except
      Result := False;
    end
  end
  else
    Result := VarIsSoftNull(EditValue) or VarIsDate(EditValue) or
      VarIsNumericEx(EditValue);
end;

procedure TcxCustomDateEditProperties.PrepareDisplayValue(
  const AEditValue: TcxEditValue; var DisplayValue: TcxEditValue;
  AEditFocused: Boolean);

  function GetDisplayValue: string;
  var
    AValue: TcxEditValue;
  begin
    if VarIsSoftNull(AEditValue) or VarIsNullDate(AEditValue) then
      Result := GetEmptyDisplayValue(AEditFocused)
    else
      if not(VarIsStr(AEditValue) or VarIsDate(AEditValue) or VarIsNumericEx(AEditValue)) then
        raise EConvertError.CreateFmt(cxGetResourceString(@cxSEditDateConvertError), [])
      else
      begin
        if VarIsStr(AEditValue) then
        begin
          InternalPrepareEditValue(AEditValue, AValue);
          if VarIsNull(AValue) or VarIsNullDate(AValue) then
            raise EConvertError.CreateFmt(cxGetResourceString(@cxSEditDateConvertError), [])
        end
        else
          AValue := AEditValue;
        if not NeedShowTime(AValue, AEditFocused) then
          AValue := DateOf(AValue);
        if AEditFocused then
          Result := DateTimeToTextEx(AValue, InputKind = ikMask, Kind = ckDateTime)
        else
          Result := DateTimeToTextEx(AValue, False);
        Result := TrimRight(Result);
      end;
  end;

begin
  DisplayValue := GetDisplayValue;
  if AEditFocused and IsMasked then
    inherited PrepareDisplayValue(DisplayValue, DisplayValue, AEditFocused);
end;

procedure TcxCustomDateEditProperties.ValidateDisplayValue(
  var ADisplayValue: TcxEditValue; var AErrorText: TCaption;
  var AError: Boolean; AEdit: TcxCustomEdit);

  function DateToDisplayValue(var ADate: TDateTime): TcxEditValue;
  begin
    Result := DateTimeToTextEx(ADate, InputKind = ikMask, Kind = ckDateTime);
    Result := TrimRight(Result);
  end;

  procedure ConvertToDate(const ADisplayValue: TcxEditValue;
    out ADate: TDateTime; out AError: Boolean);
  begin
    AError := not TextToDateEx(ADisplayValue, ADate);
  end;

  procedure CorrectError(var ADate: TDateTime; var AError: Boolean);
  begin
    if DateOnError = deNoChange then
      Exit;
    case DateOnError of
      deToday:
        if Kind = ckDate then
          ADate := SysUtils.Date
        else
          ADate := SysUtils.Now;
      deNull:
        ADate := NullDate;
    end;
    AError := False;
  end;

  function GetDate(var ADisplayValue: TcxEditValue; out AError: Boolean;
    out AErrorText: TCaption): TDateTime;
  // AError
  // NullDate - from CorrectError
  // ADisplayValue = GetEmptyString
  // Result
  var
    AIsUserErrorDisplayValue: Boolean;
  begin
    AError := False;
    AErrorText := cxGetResourceString(@cxSDateError);
    AIsUserErrorDisplayValue := False;
    try
      try
        if ADisplayValue <> GetEmptyDisplayValue(True) then
          ConvertToDate(ADisplayValue, Result, AError);
        if TcxCustomDateEdit(AEdit).IsOnValidateEventAssigned then
        begin
          if (ADisplayValue <> GetEmptyDisplayValue(True)) and not AError then
            ADisplayValue := DateToDisplayValue(Result(*, False*));
          DoValidate(ADisplayValue, AErrorText, AError, AEdit,
            AIsUserErrorDisplayValue);
          if not AError and (ADisplayValue <> GetEmptyDisplayValue(True)) then
            ConvertToDate(ADisplayValue, Result, AError);
        end
        else
          if AError then
            CorrectError(Result, AError);
      except
        AError := True;
      end;
    finally
      if AError and not AIsUserErrorDisplayValue then
        ADisplayValue := TcxCustomDateEdit(AEdit).DisplayValue;
    end;
  end;

  procedure ValidateEmptyDisplayValue(AIsNullDate: Boolean);

    function SaveSavedTime: Boolean;
    begin
      Result := not AIsNullDate and (Kind = ckDate) and
        (TcxCustomDateEdit(AEdit).FSavedTime <> 0) and SaveTime;
    end;

  var
    ADateEdit: TcxCustomDateEdit;
    AEditValueChanged: Boolean;
  begin
    ADateEdit := TcxCustomDateEdit(AEdit);
    if SaveSavedTime then
    begin
      AEditValueChanged := not InternalVarEqualsExact(
        ADateEdit.FEditValue, ADateEdit.FSavedTime);
      ADateEdit.FEditValue := ADateEdit.FSavedTime;
      ADisplayValue := DateToDisplayValue(ADateEdit.FSavedTime);
    end
    else
    begin
      AEditValueChanged := not VarIsNull(ADateEdit.FEditValue);
      ADateEdit.FEditValue := Null;
      ADateEdit.FSavedTime := 0;
      ADisplayValue := GetEmptyDisplayValue(True);
    end;
    if AEditValueChanged then
      ADateEdit.DoEditValueChanged;
  end;

  procedure CheckDate(ADate: TDateTime; var AErrorText: TCaption;
    var AError: Boolean);
  var
    ATempValue: TcxEditValue;
  begin
    if IsValueBoundsDefined then
    begin
      ATempValue := ADate;
      CheckEditorValueBounds(ATempValue, AErrorText, AError, AEdit);
    end;
  end;

var
  ADate: TDateTime;
  ADateEdit: TcxCustomDateEdit;
begin
// TODO
//  if (TimeFormat = tfHour) and Use24HourFormat then
//    ADisplayValue := ADisplayValue + ':00';
  ADate := GetDate(ADisplayValue, AError, AErrorText);
  if AError then
    Exit;

  ADateEdit := TcxCustomDateEdit(AEdit);
  try
    try
      if (ADate = NullDate) or (ADisplayValue = GetEmptyDisplayValue(True)) then
        ValidateEmptyDisplayValue(ADate = NullDate)
      else
      begin
        CheckDate(ADate, AErrorText, AError);
        if AError then
          Exit;
        // support for time in the SmartInput

        if Kind = ckDate then
          if TimeOf(ADate) <> 0 then
            ADateEdit.FSavedTime := TimeOf(ADate)
          else
            if SaveTime then
            begin
              if ADate >= 0 then
                ADate := ADate + ADateEdit.FSavedTime
              else
                ADate := ADate - ADateEdit.FSavedTime;
            end
            else
              ADateEdit.FSavedTime := 0;
        ADisplayValue := DateToDisplayValue(ADate);
      end;
    except
      AError := True;
    end;
  finally
    if AError then
      ADisplayValue := TcxCustomDateEdit(AEdit).DisplayValue;
  end;
end;

{ TcxDateEditPopupWindow }

constructor TcxDateEditPopupWindow.Create(AOwnerControl: TWinControl);
begin
  inherited Create(AOwnerControl);
  KeyPreview := True;
end;

procedure TcxDateEditPopupWindow.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if IsPopupCalendarKey(Key, Shift) then
    TcxCustomDateEdit(Edit).Calendar.KeyDown(Key, Shift);
end;

function TcxDateEditPopupWindow.IsPopupCalendarKey(Key: Word;
  Shift: TShiftState): Boolean;

  function CanEscape: Boolean;
  var
    AContainer: TcxContainer;
  begin
    Result := ActiveControl is TcxButton;
    if not Result then
    begin
      AContainer := GetcxContainer(ActiveControl);
      Result := (AContainer is TcxTimeEdit) and not TcxTimeEdit(AContainer).ModifiedAfterEnter;
    end;
  end;

begin
  Result := (Key = VK_ESCAPE) and CanEscape or
  ((Key = VK_UP) or (Key = VK_DOWN)) and (ssAlt in Shift) or
  (Key = VK_F4) and not (ssAlt in Shift);
end;

{ TcxDateEditMaskStandardMode }

function TcxDateEditMaskStandardMode.GetBlank(APos: Integer): Char;
begin
  Result := TcxCustomDateEditProperties(Properties).GetStandardMaskBlank(APos);
end;

{ TcxCustomDateEdit }

destructor TcxCustomDateEdit.Destroy;
begin
  FreeAndNil(FCalendar);
  inherited Destroy;
end;

procedure TcxCustomDateEdit.Clear;
begin
  Date := NullDate;
end;

procedure TcxCustomDateEdit.DateChange(Sender: TObject);
var
  ADate: Double;
  ADisplayValue: TcxEditValue;
begin
  FCloseUpReason := crEnter;
  ADate := Calendar.SelectDate;
  if ActiveProperties.Kind = ckDateTime then
    ADate := DateOf(ADate) + cxSign(ADate) * TimeOf(TDateTime(Calendar.FTimeEdit.Time))
  else
    if ActiveProperties.SaveTime and (ADate <> NullDate) then
      if ADate >= 0 then
        ADate := ADate + TimeOf(FDateDropDown)
      else
        ADate := ADate - TimeOf(FDateDropDown);
  ADisplayValue := GetRecognizableDisplayValue(ADate);
  if ((Date <> ADate) or not InternalCompareString(DisplayValue, VarToStr(ADisplayValue), True)) and
    DoEditing then
  begin
    LockChangeEvents(True);
    try
      Date := ADate;
      ModifiedAfterEnter := True;
      SetInternalDisplayValue(ADisplayValue);
      SelectAll;
    finally
      LockChangeEvents(False);
    end;
  end;
end;

function TcxCustomDateEdit.GetActiveProperties: TcxCustomDateEditProperties;
begin
  Result := TcxCustomDateEditProperties(InternalGetActiveProperties);
end;

function TcxCustomDateEdit.GetCurrentDate: TDateTime;
begin
  if Focused and not IsEditValidated and ModifiedAfterEnter then
    Result := GetDateFromStr(DisplayValue)
  else
    Result := Date;
end;

function TcxCustomDateEdit.GetProperties: TcxCustomDateEditProperties;
begin
  Result := TcxCustomDateEditProperties(FProperties);
end;

function TcxCustomDateEdit.GetRecognizableDisplayValue(
  ADate: TDateTime): TcxEditValue;

  function NeedDisplayValueCorrection(ADate: TDateTime): Boolean;
  var
    ADisplayValue, AEditValue: TcxEditValue;
  begin
    Result := False;
    if (ActiveProperties.InputKind = ikStandard) and (ADate <> NullDate) then
    begin
      PrepareDisplayValue(ADate, ADisplayValue, True);
      PrepareEditValue(ADisplayValue, AEditValue, True);
      Result := DateOf(ADate) <> DateOf(AEditValue);
    end;
  end;

begin
  if NeedDisplayValueCorrection(ADate) then
  begin
    if not ActiveProperties.NeedShowTime(ADate, True) then
      ADate := DateOf(ADate);
    Result := DateTimeToTextEx(ADate, False, ActiveProperties.Kind = ckDateTime, True);
    Result := TrimRight(Result);
  end
  else
    PrepareDisplayValue(ADate, Result, True);
end;

procedure TcxCustomDateEdit.SetProperties(Value: TcxCustomDateEditProperties);
begin
  FProperties.Assign(Value);
end;

function TcxCustomDateEdit.CanSynchronizeModeText: Boolean;
begin
  Result := Focused or IsEditValidating;
end;

procedure TcxCustomDateEdit.CheckEditorValueBounds;
begin
  if Date = NullDate then
    Exit;
  KeyboardAction := ModifiedAfterEnter;
  try
    if ActiveProperties.IsValueBoundDefined(evbMin) and
      (Date < ActiveProperties.MinValue) then
        Date := ActiveProperties.MinValue
    else
      if ActiveProperties.IsValueBoundDefined(evbMax) and
        (Date > ActiveProperties.MaxValue) then
          Date := ActiveProperties.MaxValue;
  finally
    KeyboardAction := False;
  end;
end;

procedure TcxCustomDateEdit.CreatePopupWindow;
begin
  inherited;
  PopupWindow.ModalMode := False;
end;

(*procedure TcxCustomDateEdit.DoEditKeyDown(var Key: Word; Shift: TShiftState);

  function IsArrowIncrementPosition: Boolean;
  begin
    Result := False;
    if (ActiveProperties.Kind <> ckDateTime) or (ActiveProperties.InputKind <> ikMask) then
      Exit;
    Result := SelStart + SelLength >= 11;
  end;

  procedure Increment(AButton: TcxSpinEditButton);
  var
    ATimeZone: TcxTimeEditZone;
  begin
    ATimeZone := GetTimeZone;
  end;

var
  AButton: TcxSpinEditButton;
begin
  if ((Key = VK_UP) or (Key = VK_DOWN) or (Key = VK_NEXT) or (Key = VK_PRIOR)){ and
    not (ActiveProperties.UseCtrlIncrement and not (ssCtrl in Shift))} and
    IsArrowIncrementPosition then
  begin
    if not DataBinding.Modified and not DoEditing then
      Exit;
    case Key of
      VK_UP:
        AButton := sebForward;
      VK_DOWN:
        AButton := sebBackward;
      VK_PRIOR:
        AButton := sebFastForward;
      else
        AButton := sebFastBackward;
    end;
    Increment(AButton);
    DoAfterKeyDown(Key, Shift);
    Key := 0;
  end;
  if Key <> 0 then
    inherited DoEditKeyDown(Key, Shift);
end;*)

procedure TcxCustomDateEdit.DropDown;
begin
  if Calendar = nil then
    CreateCalendar;
  ActiveProperties.PopupControl := Calendar;
  inherited DropDown;
end;

procedure TcxCustomDateEdit.Initialize;
begin
  inherited Initialize;
  ControlStyle := ControlStyle - [csSetCaption];
  FDateDropDown := NullDate;
end;

procedure TcxCustomDateEdit.InitializePopupWindow;
var
  ADate: TDateTime;
  ATimeFormat: TcxTimeEditTimeFormat;
  AUse24HourFormat: Boolean;
begin
  inherited InitializePopupWindow;
  with Calendar do
  begin
    HandleNeeded;
    Color := Self.ActiveStyle.Color;
    Flat := Self.PopupControlsLookAndFeel.Kind in [lfFlat,
      lfUltraFlat, lfOffice11];
    CalendarButtons := ActiveProperties.DateButtons;
    OnDateTimeChanged := nil;
    FDateDropDown := Self.CurrentDate;
    if FDateDropDown = NullDate then
      ADate := SysUtils.Date
    else
      ADate := FDateDropDown;
    if ActiveProperties.Kind = ckDateTime then
      FTimeEdit.Time := TTime(TimeOf(ADate));
    ADate := DateOf(ADate);
    FirstDate := ADate;
    SelectDate := ADate;
    Font.Assign(Self.ActiveStyle.GetVisibleFont);
    Font.Color := clBtnText;
    SetSize; // force recalculate size
    OnDateTimeChanged := DateChange;
    ArrowsForYear := ActiveProperties.ArrowsForYear;
    Kind := ActiveProperties.Kind;

    cxCalendar.GetTimeFormat(cxFormatController.DateTimeFormatInfo, ATimeFormat,
      AUse24HourFormat);
    TimeFormat := ATimeFormat;
    Use24HourFormat := AUse24HourFormat;

    WeekNumbers := ActiveProperties.WeekNumbers;
    YearsInMonthList := ActiveProperties.YearsInMonthList;
  end;
end;

function TcxCustomDateEdit.InternalGetEditingValue: TcxEditValue;
begin
  PrepareEditValue(Text, Result, True);
end;

function TcxCustomDateEdit.InternalGetText: string;
begin
  Result := DisplayValue;
end;

procedure TcxCustomDateEdit.InternalSetEditValue(const Value: TcxEditValue;
  AValidateEditValue: Boolean);

  procedure SaveTime;
  var
    ADate: TDateTime;
  begin
    if not ActiveProperties.SaveTime or not(VarIsStr(Value) or VarIsNumericEx(Value) or VarIsDate(Value)) then
      FSavedTime := 0
    else
      if VarIsStr(Value) then
      begin
        cxStrToDateTime(Value, not cxFormatController.UseDelphiDateTimeFormats, ADate);
        if ADate = NullDate then
          FSavedTime := 0
        else
          FSavedTime := TimeOf(ADate);
      end
      else
        FSavedTime := TimeOf(Value);
  end;

begin
  if IsDestroying then
    Exit;
  if ActiveProperties.Kind = ckDate then
    SaveTime;
  inherited InternalSetEditValue(Value, AValidateEditValue);
end;

function TcxCustomDateEdit.InternalSetText(const Value: string): Boolean;
begin
  Result := SetDisplayText(Value);
end;

procedure TcxCustomDateEdit.InternalValidateDisplayValue(
  const ADisplayValue: TcxEditValue);
begin
  if VarIsStr(ADisplayValue) then
    inherited InternalValidateDisplayValue(ADisplayValue)
  else
  begin
    SaveModified;
    try
      InternalEditValue := ADisplayValue;
    finally
      RestoreModified;
    end;
  end;
end;

function TcxCustomDateEdit.IsCharValidForPos(var AChar: Char;
  APos: Integer): Boolean;
var
  ATimeZoneInfo: TcxTimeEditZoneInfo;
begin
  if not ActiveProperties.GetTimeZoneInfo(APos, ATimeZoneInfo) then
    Result := True
  else
    Result := IsCharValidForTimeEdit(Self, AChar, APos, ATimeZoneInfo);
end;

procedure TcxCustomDateEdit.PopupWindowClosed(Sender: TObject);
begin
  inherited PopupWindowClosed(Sender);
  if Calendar <> nil then
    Calendar.CheckHotTrack;
end;

procedure TcxCustomDateEdit.PopupWindowShowed(Sender: TObject);
begin
  inherited PopupWindowShowed(Sender);
  Calendar.Calculate;
  Calendar.CheckHotTrack;
end;

procedure TcxCustomDateEdit.UpdateTextFormatting;
begin
end;

procedure TcxCustomDateEdit.CreateCalendar;
begin
  FCalendar := GetCalendarClass.Create(Self);
  FCalendar.FEdit := Self;
  FCalendar.Parent := PopupWindow;
  FCalendar.OnHidePopup := HidePopup;
  FCalendar.FClearButton.LookAndFeel.MasterLookAndFeel := PopupControlsLookAndFeel;
  FCalendar.FOKButton.LookAndFeel.MasterLookAndFeel := PopupControlsLookAndFeel;
  FCalendar.FNowButton.LookAndFeel.MasterLookAndFeel := PopupControlsLookAndFeel;
  FCalendar.FTodayButton.LookAndFeel.MasterLookAndFeel := PopupControlsLookAndFeel;
  FCalendar.FTimeEdit.Style.LookAndFeel.MasterLookAndFeel := PopupControlsLookAndFeel;
end;

function TcxCustomDateEdit.GetCalendarClass: TcxPopupCalendarClass;
begin
  Result := TcxPopupCalendar;
end;

function TcxCustomDateEdit.GetDate: TDateTime;
begin
  if VarIsNull(EditValue) then
    Result := NullDate
  else if VarIsNumericEx(EditValue) or VarIsDate(EditValue) then
    Result := EditValue
  else if VarIsStr(EditValue) then
    Result := GetDateFromStr(EditValue)
  else
    Result := NullDate;
end;

function TcxCustomDateEdit.GetDateFromStr(const S: string): TDateTime;
var
  AValue: TcxEditValue;
begin
  PrepareEditValue(S, AValue, Focused);
  if VarIsNull(AValue) then
    Result := NullDate
  else
    Result := AValue;
end;

procedure TcxCustomDateEdit.SetDate(Value: TDateTime);
begin
  if Value = NullDate then
    InternalEditValue := Null
  else
  begin
    if ActiveProperties.Kind = ckDate then
      if TimeOf(Value) = 0 then
        if ActiveProperties.SaveTime then
          Value := Int(Value) + cxSign(Value) * FSavedTime
        else
          Value := Int(Value);
    InternalEditValue := Value;
  end;
end;

procedure TcxCustomDateEdit.SetupPopupWindow;
begin
  inherited SetupPopupWindow;
  with Calendar, ViewInfo do
  begin
    FClearButton.LookAndFeel.SkinPainter := Painter;
    FOKButton.LookAndFeel.SkinPainter := Painter;
    FNowButton.LookAndFeel.SkinPainter := Painter;
    FTodayButton.LookAndFeel.SkinPainter := Painter;
    FTimeEdit.Style.LookAndFeel.SkinPainter := Painter;
  end;
end;

class function TcxCustomDateEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxCustomDateEditProperties;
end;

procedure TcxCustomDateEdit.PrepareEditValue(
  const ADisplayValue: TcxEditValue; out EditValue: TcxEditValue;
  AEditFocused: Boolean);
var
  ATempValue: TDateTime;
begin
  try
    ActiveProperties.InternalPrepareEditValue(ADisplayValue, EditValue);
  finally
    if not VarIsNull(EditValue) then
    begin
      if not VarIsNullDate(EditValue) and
        (ActiveProperties.Kind = ckDate) and ActiveProperties.SaveTime then
        begin
          ATempValue := Int(EditValue) + cxSign(EditValue) * FSavedTime;
          EditValue := ATempValue; // restore varDate type
        end;
      if not cxFormatController.UseDelphiDateTimeFormats then
        try
          EditValue := VarAsType(EditValue, varDate);
        except
          on EVariantError do
            ;
        end;
    end;
  end;
end;

{ TcxDateEdit }

class function TcxDateEdit.GetPropertiesClass: TcxCustomEditPropertiesClass;
begin
  Result := TcxDateEditProperties;
end;

function TcxDateEdit.GetActiveProperties: TcxDateEditProperties;
begin
  Result := TcxDateEditProperties(InternalGetActiveProperties);
end;

function TcxDateEdit.GetProperties: TcxDateEditProperties;
begin
  Result := TcxDateEditProperties(FProperties);
end;

procedure TcxDateEdit.SetProperties(Value: TcxDateEditProperties);
begin
  FProperties.Assign(Value);
end;

{ TcxFilterDateEditHelper }

class function TcxFilterDateEditHelper.GetFilterEditClass: TcxCustomEditClass;
begin
  Result := TcxDateEdit;
end;

class function TcxFilterDateEditHelper.GetSupportedFilterOperators(
  AProperties: TcxCustomEditProperties;
  AValueTypeClass: TcxValueTypeClass;
  AExtendedSet: Boolean = False): TcxFilterControlOperators;
begin
  Result := [fcoEqual, fcoNotEqual, fcoLess, fcoLessEqual, fcoGreater,
    fcoGreaterEqual, fcoBlanks, fcoNonBlanks];
  if AExtendedSet then
    Result := Result + [fcoBetween, fcoNotBetween, fcoInList, fcoNotInList,
      fcoYesterday, fcoToday, fcoTomorrow,
      fcoLast7Days, fcoLastWeek, fcoLast14Days, fcoLastTwoWeeks, fcoLast30Days, fcoLastMonth, fcoLastYear, fcoInPast,
      fcoThisWeek, fcoThisMonth, fcoThisYear,
      fcoNext7Days, fcoNextWeek, fcoNext14Days, fcoNextTwoWeeks, fcoNext30Days, fcoNextMonth, fcoNextYear, fcoInFuture];
end;

class procedure TcxFilterDateEditHelper.InitializeProperties(AProperties,
  AEditProperties: TcxCustomEditProperties; AHasButtons: Boolean);
begin
  inherited InitializeProperties(AProperties, AEditProperties, AHasButtons);
  with TcxCustomDateEditProperties(AProperties) do
  begin
    DateButtons := [btnToday, btnClear];
    DateOnError := deNull;
    InputKind := ikRegExpr;
    SaveTime := True;
  end;
end;

initialization
  GetRegisteredEditProperties.Register(TcxDateEditProperties, scxSEditRepositoryDateItem);
  FilterEditsController.Register(TcxDateEditProperties, TcxFilterDateEditHelper);

finalization
  FilterEditsController.Unregister(TcxDateEditProperties, TcxFilterDateEditHelper);
  
end.

