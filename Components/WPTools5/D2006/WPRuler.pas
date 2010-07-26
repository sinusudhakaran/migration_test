{ -----------------------------------------------------------------------------
  WPRuler          - Copyright (C) 2004 by wpcubed GmbH -  all rigths reserved!
  Author: Julian Ziersch
  info: http://www.wptools.de                         mailto:support@wptools.de
  *****************************************************************************
  License:
    You may use this components if you are a registered user of WPTools V4
  -----------------------------------------------------------------------------
  Summary:
  WPRuler, WPVertRuler - Components to display ruler to set tabstops,
  indents and page margins in the memo control TWPRichText
  These controls were entirely rewritten for WPTools V5 to make it possible
  to move tabstops and show inherited properties shaded.
  -----------------------------------------------------------------------------
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY
  KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
  ----------------------------------------------------------------------------- }

{ Ruler functionality:
    Change Page Margins
    Change Indents
    Create Tabstops
    Move Tabstops
    -
    If the user presses "ALT" the intervalls are not used
    With "SHIFT" the first indent is not changed together with the left indent
    With "CTRL" the indents are not changed. This makes it possible to change
    tab stops of margins which are hidden by the indent markers }

// Written: 6.9.2004 by Julian Ziersch, last update 7.11.2005

unit WPRuler;

interface
{$I WPINC.INC}

{$IFDEF WPDEMO}{$UNDEF USETBX}{$ENDIF}

{.$DEFINE NORULERSHADE}

{$DEFINE NOCOLRESIZE} // for now ...
{$DEFINE NOTABCURSOR} // for now ...

{$DEFINE ASSIGNDEFSIZE} // Set width/height to 26
{--$DEFINE RULERDOESNTUSELOGPAGE}//OFF

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Math, WPRTEDefs, WPCTRMemo, StdCtrls, WPUtil, ExtCtrls;


const
  WPRUL_TOPMARG = 4;
  WPRUL_BOTMARG = 7;
  WPRUL_CENTEROFF = 3;

{$IFDEF NOTABCURSOR}
  WPRUL_TABDEL_CURSOR = crDrag; // Number for Cursor !
{$ELSE}
  WPRUL_TABDEL_CURSOR = 1185; // Number for Cursor !
{$ENDIF}

type
  TWPRuler = class;
  TWPCustomRuler = class;

  // You can add more designs by adding additional rows in RES file WPRulerRes
  TWPRulerDesign = (wpRulerSimple, wpRulerNorm, wpRulerBlue);

{$IFNDEF T2H}
  TWPRulerMargin = (
    wprulMarginNone,
    wprulMarginLeft,
    wprulMarginRight,
    wprulMarginTop,
    wprulMarginBottom);

  TWPRulerMargins = set of
    (wpStartMargin, wpEndMargin);


  TWPRulerItemType = (
    wprulLeftIndent,
    wprulLeftIndentSimple,
    wprulFirstIndent,
    wprulRightIndent,
    wprulTabCenter,
    wprulTabRight,
    wprulTabDecimal,
    wprulTabLeft,
    wprulTabBar,
    wprulTableColumn,
    wprulTableBorder);
{$ENDIF}

  TWPRulerUnit = (wrCentimeter, wrInch);

  TWPRulerElement = (
    wprulerLeftIndent,
    wprulerFirstIndent,
    wprulerRightIndent,
    wprulerTab,
    wprulerMarginLeft,
    wprulerMarginRight,
    wprulerMarginTop,
    wprulerMarginBottom
    );

  TWPRulerChangingEvent = procedure(Sender: TObject; Element: TWPRulerElement; var Proceed: Boolean) of object;

  TWPRulerChangedEvent = procedure(Sender: TObject; Element: TWPRulerElement) of object;

  TWPRulerDrawOptions = set of (wrUseSmallNumbers, wrShow3DLines, wrShadedBackground);

  TWPRulerOptions = set of (
    wrShowTabSelector,
    wrShowTabStops,
    wrShowIndents,
    wpUseIntervalls,
    wpNoVertRulerAttached, // should be enabled when you use a vertical ruler
    wpRulerReadOnly, // Don't allow draging of indent merkers
    wpPageMarginsReadOnly // Do not change margins of the page
    );

  TWPRulerItemMode = set of
    (wprulDisabled,
    wprulTempHidden,
    wprulNotMouseActive);

  TWPRulerItem = record
    FTyp: TWPRulerItemType;
    FValue: Integer; //<-- always (!) TWIP value from left border of page!
    FMode: TWPRulerItemMode;
    FId, FMin, FMax: Integer;
    r: TRect;
  end;

  TWPRulerDrawBackgroundEvent = procedure(
    Sender: TWPCustomRuler;
    toCanvas: TCanvas;
    DrawRec: TRect) of object;


  TWPCustomRuler = class(TCustomControl)
  private
{$IFNDEF T2H}
    FMargins: TWPRulerMargins;
    FColorPaper, FColorBack, FColorMargin, FColorBorder, FColorLines, FColorTableMarker: TColor;
    p1, p2: TPoint;
    ShowLine: Boolean;
    FDrawOptions: TWPRulerDrawOptions;
    FOnChanging: TWPRulerChangingEvent;
    FOnChanged: TWPRulerChangedEvent;
    procedure SetColorPaper(x: TColor);
    procedure SetColorBack(x: TColor);
    procedure SetColorMargin(x: TColor);
    procedure SetColorBorder(x: TColor);
    procedure SetColorLines(x: TColor);
    procedure SetColorTableMarker(x: TColor);
    procedure SetMargins(x: TWPRulerMargins);
    procedure SetUnits(x: TWPRulerUnit);
    procedure SetDrawOptions(x: TWPRulerDrawOptions);
  protected
    FUnits: TWPRulerUnit;
    FOnPaint: TWPRulerDrawBackgroundEvent;
    FOffset: Integer; // Offset to Page area  in pixel
    FZoom: Extended; // Zoom Factor
    FCurrSource: TWPRTFDataCollection;
    FCurrControl: TControl;
    FLocked: Boolean;
    function GetPageProps: TWPRTFSectionProps;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Line(x, y, x1, y1: Integer; Show: Boolean);
    function Changing(element: TWPRulerElement): Boolean; virtual;
    procedure Changed(element: TWPRulerElement); virtual;
{$ENDIF}
  public
    constructor Create(aOwner: TComponent); override;
    property DrawOptions: TWPRulerDrawOptions read FDrawOptions write SetDrawOptions;
    procedure UpdateFrom(Source: TWPRTFDataCollection; Control: TControl; par: TWPTextStyle = nil); virtual;
    property ColorMargin: TColor read FColorMargin write SetColorMargin default clBtnFace;
    property ColorPaper: TColor read FColorPaper write SetColorPaper default clWhite;
    property ColorBack: TColor read FColorBack write SetColorBack default clAppWorkSpace;
    property ColorLines: TColor read FColorLines write SetColorLines default clBlack;
    property ColorBorder: TColor read FColorBorder write SetColorBorder default clBtnShadow;
    property ColorTableMarker: TColor read FColorTableMarker write SetColorTableMarker default clBtnFace;
    property Margins: TWPRulerMargins read FMargins write SetMargins;
    property Units: TWPRulerUnit read FUnits write SetUnits;
    property Offset: Integer read FOffset write FOffset;
    property Zoom: Extended read FZoom write FZoom;
    property OnPaint: TWPRulerDrawBackgroundEvent read FOnPaint write FOnPaint;
    //:: This event is triggered before a change
    property OnChanging: TWPRulerChangingEvent read FOnChanging write FOnChanging;
    //:: This event is triggered after a change
    property OnChanged: TWPRulerChangedEvent read FOnChanged write FOnChanged;
  end;


  TWPVertRuler = class(TWPCustomRuler)
  private
{$IFNDEF T2H}
    FBuffer: TBitmap;
    FTopMargin, FBottomMargin, FPageHeight: Integer;
    FTopMarginY, FBottomMarginY: Integer;
    FMouseDown: Boolean;
    FCurrentMargin: TWPRulerMargin;
    procedure Normalize;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    function TheTopMargin: Integer;
    function TheBottomMargin: Integer;
    procedure PaintScale(x, y: Integer);
{$ENDIF}
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure Paint; override;
    procedure Loaded; override;
    procedure UpdateFrom(Source: TWPRTFDataCollection; Control: TControl; par: TWPTextStyle = nil); override;
  published
    property Units;
    property DrawOptions;
    property ColorMargin default clBtnFace;
    property ColorPaper default clWhite;
    property ColorBack default clAppWorkSpace;
    property ColorLines default clBlack;
    property ColorBorder default clBtnShadow;
    property ColorTableMarker default clBtnFace;
    property OnPaint;
    property Width;
    property Height;
    property Left;
    property Top;
    property Anchors;
    property Align;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property Enabled;
    property OnChanging;
    property OnChanged;
  end;

  TWPRuler = class(TWPCustomRuler)
  private
{$IFNDEF T2H}
    FDesign: TWPRulerDesign;
    FImages, FMask: TBitmap;
    FTabKind: TTabKind;
    FOptions: TWPRulerOptions;
    FBuffer: TBitmap;
    LockForMove: Cardinal;
    FItems: array of TWPRulerItem;
    FItemCount: Integer;
    FLeftMargin: Integer; // in twips
    FRightMargin: Integer; // in twips
    FPageWidth: Integer; // in twips
    FIsTable: Boolean;
    FCellLeft: Integer; // in twips
    FCellRight: Integer; // in twips
    // For Pagegin Change
    FLeftMarginX, FRightMarginX: Integer;
    FTabSelectorR: TRect;
    FCurrentItem: Integer;
    FCurrentMargin: TWPRulerMargin;
    FMouseDown, FShiftMode: Boolean;
    FMouseX, FMouseY: Integer;
    // -------------------------------------------------------------------------
    function GetCurrValue(index: TWPRulerItemType): Integer;
    procedure SetCurrValue(index: TWPRulerItemType; Value: Integer);
    procedure SetDesign(x: TWPRulerDesign);
    procedure SetTabKind(x: TTabKind);
    procedure SetOptions(x: TWPRulerOptions);
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DeleteItem(nr: Integer);
    procedure Normalize;
    procedure PaintItem(nr: Integer);
    procedure PaintScale(x, y: Integer);
    procedure PaintSelector;
    function TheLeftMargin: Integer;
    function TheRightMargin: Integer;
    procedure CalcItemLeft(var x, y, h: Integer; Typ: TWPRulerItemType);
    property CurrValue[index: TWPRulerItemType]: Integer read GetCurrValue write SetCurrValue;
    function AddItem(Typ: TWPRulerItemType; Value: Integer; aEnabled: Boolean; Id: Integer; minv, maxv: Integer): Integer;
{$ENDIF}
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    function ItemAtXY(x, y: Integer; IgnoreIndents: Boolean = FALSE): Integer;
    procedure Click; override;
    procedure DblClick; override;
    procedure Paint; override;
    procedure Loaded; override;
    procedure UpdateFrom(Source: TWPRTFDataCollection; Control: TControl; par: TWPTextStyle = nil); override;
  published
    property Design: TWPRulerDesign read FDesign write SetDesign default wpRulerNorm;
    property Units;
    property DrawOptions;
    property TabKind: TTabKind read FTabKind write SetTabKind;
    property Options: TWPRulerOptions read FOptions write SetOptions;
    property ColorMargin default clBtnFace;
    property ColorPaper default clWhite;
    property ColorBack default clAppWorkSpace;
    property ColorLines default clBlack;
    property ColorBorder default clBtnShadow;
    property ColorTableMarker default clBtnFace;
    property OnPaint;
    property Width;
    property Height;
    property Left;
    property Top;
    property Anchors;
    property Align;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseUp;
    property OnMouseMove;
    property Enabled;
    property OnChanging;
    property OnChanged;
  end;

implementation

{$R WPRulerRes.RES}

constructor TWPRuler.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FItems := nil;
  FItemCount := 0;
  FImages := TBitmap.Create;
  FMask := TBitmap.Create;
  FBuffer := TBitmap.Create;
  FImages.LoadFromResourceName(HInstance, 'WPRULERIMG');
  FMask.LoadFromResourceName(HInstance, 'MASK_RULIMG');

  Width := 100;
  Height := 26;
  // Align := alTop;

  Options := [wrShowTabSelector, wrShowTabStops, wrShowIndents,
    wpUseIntervalls,
    wpNoVertRulerAttached];

  FCurrentItem := -1;
  FCurrentMargin := wprulMarginNone;
  FOffset := 30;
  FDesign := wpRulerNorm;
  FLeftMargin := WPCentimeterToTwips(2);
  FRightMargin := WPCentimeterToTwips(2);
  FPageWidth := WPCentimeterToTwips(21);
end;

destructor TWPRuler.Destroy;
begin
  FItems := nil;
  FImages.Free;
  FMask.Free;
  FBuffer.Free;
  inherited Destroy;
end;

constructor TWPCustomRuler.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FZoom := 1;
  FColorBack := clBtnFace;
  FColorPaper := clWhite;
  FColorMargin := clAppWorkSpace;
  FColorTableMarker := clBtnFace;
  FColorBorder := clBtnShadow;
  FColorLines := clBlack;
  FMargins := [wpStartMargin, wpEndMargin];
end;

function TWPCustomRuler.GetPageProps: TWPRTFSectionProps;
begin
  if FCurrSource = nil then Result := nil
  else {$IFDEF RULERDOESNTUSELOGPAGE}Result := Source.GetCurrPageProps; {$ELSE}
    Result := FCurrSource.GetLogicalPageProps; {$ENDIF}
end;

procedure TWPCustomRuler.UpdateFrom(Source: TWPRTFDataCollection;
  Control: TControl; par: TWPTextStyle = nil);
begin
  FCurrSource := Source;
  if FCurrControl <> Control then
  begin
    FCurrControl := Control;
    if FCurrControl <> nil then FCurrControl.FreeNotification(Self);
  end;
end;

function TWPCustomRuler.Changing(element: TWPRulerElement): Boolean;
begin
  Result := TRUE;
  if Assigned(FOnChanging) then
    FOnChanging(Self, Element, Result);
end;

procedure TWPCustomRuler.Changed(element: TWPRulerElement);
begin
  if Assigned(FOnChanged) then FOnChanged(Self, Element);
  if FCurrSource <> nil then FCurrSource.Modified := TRUE;
end;

procedure TWPCustomRuler.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) then
  begin
    if (FCurrControl <> nil) and
      (AComponent = FCurrControl) then
    begin FCurrControl := nil;
      FCurrSource := nil;
    end;
  end;
end;

procedure TWPCustomRuler.Line(x, y, x1, y1: Integer; Show: Boolean);
var
  can: TControlCanvas;
begin
  if FCurrControl <> nil then
  begin
    can := TControlCanvas.Create;
    can.Control := FCurrControl;
    try
      can.Pen.Width := 0;
      can.Pen.Color := clBlack;
      can.Pen.Style := psDot;
      can.Pen.Mode := pmXor;
      if ShowLine then
      begin
        can.MoveTo(p1.x, p1.y);
        can.LineTo(p2.x, p2.y);
      end;
      ShowLine := Show;
      if Show then
      begin
        p1.x := x;
        p1.y := y;
        p2.x := x1;
        p2.y := y1;
        can.MoveTo(p1.x, p1.y);
        can.LineTo(p2.x, p2.y);
      end;
    finally
      can.Control := nil;
      can.Free
    end;
  end;
end;

procedure TWPCustomRuler.SetColorPaper(x: TColor);
begin
  if FColorPaper <> x then
  begin
    FColorPaper := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetColorBack(x: TColor);
begin
  if FColorBack <> x then
  begin
    FColorBack := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetColorMargin(x: TColor);
begin
  if FColorMargin <> x then
  begin
    FColorMargin := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetColorBorder(x: TColor);
begin
  if FColorBorder <> x then
  begin
    FColorBorder := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetColorLines(x: TColor);
begin
  if FColorLines <> x then
  begin
    FColorLines := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetColorTableMarker(x: TColor);
begin
  if FColorTableMarker <> x then
  begin
    FColorTableMarker := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetMargins(x: TWPRulerMargins);
begin
  if FMargins <> x then
  begin
    FMargins := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetUnits(x: TWPRulerUnit);
begin
  if FUnits <> x then
  begin
    FUnits := x;
    invalidate;
  end;
end;

procedure TWPCustomRuler.SetDrawOptions(x: TWPRulerDrawOptions);
begin
  if FDrawOptions <> x then
  begin
    FDrawOptions := x;
    invalidate;
  end;
end;

procedure TWPRuler.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (FCurrentMargin <> wprulMarginNone) or
    (FCurrentItem >= 0) then
    LockForMove := GetTickCount + 500;
  FMouseX := x;
  FMouseY := y;
  inherited MouseDown(Button, Shift, X, y);
  FMouseDown := TRUE;
  FShiftMode := ssShift in Shift;
end;

procedure TWPRuler.MouseMove(Shift: TShiftState; X, Y: Integer);
var nr, MargExtra, tw, xx, off: Integer;
  aHeader: TWPRTFSectionProps;
  function TWToX(aTW: Integer): Integer;
  var pa, pb: TPoint;
  begin
    pa := Self.ScreenToClient(Point(0, 0));
    pb := FCurrControl.ScreenToClient(Point(0, 0));
    Result := pa.x - pb.x;
    if (aHeader <> nil) and not (wpStartMargin in Margins) then
      dec(aTW, aHeader.LeftMargin);
    Result := FOffset - Result + Round(aTW / 1440 * FZoom * WPScreenPixelsPerInch);
  end;
begin
  if FCurrSource = nil then // V5.11.1
    aHeader := nil
  else aHeader := GetPageProps;
  FMouseX := x;
  FMouseY := y;
  inherited MouseMove(Shift, X, y);
  if not (wpRulerReadOnly in Options) then
  begin
  // Margins
    if FMouseDown and (FCurrentMargin <> wprulMarginNone) then
    begin
      tw := Round((x - FOffset) / WPScreenPixelsPerInch / FZoom * 1440);
      if tw < 0 then tw := 0;
      if FCurrentMargin = wprulMarginLeft then
      begin
        if tw < FPageWidth - FRightMargin - 720 then
          FLeftMargin := tw;
      end
      else if FCurrentMargin = wprulMarginRight then
      begin
        if tw > FLeftMargin + 720 then
          FRightMargin := FPageWidth - tw;
        if FRightMargin < 0 then FRightMargin := 0;
      end;
      if FCurrControl <> nil then
      begin
        xx := TwToX(tw);
        Line(xx, 2, xx, FCurrControl.Height - 2, true);
      end;
      Paint;
    end else // Indents, Tabs
      if FMouseDown and (FCurrentItem >= 0) then
      begin
        tw := Round((x - FOffset) / WPScreenPixelsPerInch / FZoom * 1440) - TheLeftMargin;

        if (wpUseIntervalls in FOptions) and not (ssAlt in Shift) then
        begin
          if FUnits = wrCentimeter then
            tw := Round(((Trunc(tw / 1440 * 2.54 * 100) div 25) * 25) / 100 * 1440 / 2.54)
          else tw := Round(((Trunc(tw / 1440 * 1000) div 125) * 125) / 1000 * 1440);
        end;

        if tw < FItems[FCurrentItem].FMin then tw := FItems[FCurrentItem].FMin;
        if tw > FItems[FCurrentItem].FMax then tw := FItems[FCurrentItem].FMax;
        if tw < -TheLeftMargin then tw := -TheLeftMargin;
        if tw > FPageWidth - TheLeftMargin - TheRightMargin then tw := FPageWidth - TheLeftMargin - TheRightMargin;


        if FItems[FCurrentItem].FTyp in [wprulTabCenter,
          wprulTabRight, wprulTabDecimal, wprulTabLeft, wprulTabBar] then
        begin
          if FMouseY > Height + 3 then
          begin
            include(FItems[FCurrentItem].FMode, wprulTempHidden);
            Screen.Cursor := WPRUL_TABDEL_CURSOR;
          end
          else
          begin
            exclude(FItems[FCurrentItem].FMode, wprulTempHidden);
            Screen.Cursor := crDrag;
          end;
        end;

        if (FItems[FCurrentItem].FValue <> tw) then
        begin

          if FCurrControl <> nil then
          begin
            xx := TwToX(tw + FLeftMargin);
            Line(xx, 2, xx, FCurrControl.Height - 2, true);
          end;

          if FItems[FCurrentItem].FTyp in [wprulLeftIndent, wprulLeftIndentSimple] then
          begin
            if tw > CurrValue[wprulRightIndent] then
              tw := CurrValue[wprulRightIndent];

            if y < (Self.Height div 2) + 3 then //V5.13.5
              FShiftMode := TRUE;

            if not FShiftMode then
            begin
              off := FItems[FCurrentItem].FValue - CurrValue[wprulFirstIndent];
              CurrValue[wprulFirstIndent] := tw - off;
            end;
          end
          else if FItems[FCurrentItem].FTyp = wprulRightIndent then
          begin
            if tw < CurrValue[wprulLeftIndent] + 140 then
              tw := CurrValue[wprulLeftIndent] + 140;
          end;

          FItems[FCurrentItem].FValue := tw;

          Paint;
        end;
      end
      else
      begin
        nr := ItemAtXY(x, y, ssCtrl in Shift);

        if FIsTable then MargExtra := 10
        else MargExtra := 2;

        if nr >= 0 then
        begin
          if FItems[nr].FTyp in [wprulTabCenter,
            wprulTabRight, wprulTabDecimal, wprulTabLeft, wprulTabBar] then
            Screen.Cursor := crDrag
          else
            Screen.Cursor := crSizeWE;
          FCurrentItem := nr;
          MouseCapture := TRUE;
        end
        else if not (wpPageMarginsReadOnly in Options) and
          not FIsTable and (x <= FLeftMarginX) and (x >= FLeftMarginX - MargExtra)
          and (wpStartMargin in Margins) then
        begin
          FCurrentMargin := wprulMarginLeft;
          Screen.Cursor := crSizeWE;
          MouseCapture := TRUE;
        end else
          if not (wpPageMarginsReadOnly in Options) and
            not FIsTable and (x >= FRightMarginX) and (x <= FRightMarginX + MargExtra)
            and (wpEndMargin in Margins) then
          begin
            FCurrentMargin := wprulMarginRight;
            Screen.Cursor := crSizeWE;
            MouseCapture := TRUE;
          end
          else Normalize;
      end;
  end;
end;

procedure TWPRuler.Normalize;
begin
  if ((FCurrentItem >= 0) or (FCurrentMargin <> wprulMarginNone)) then
  begin
    Screen.Cursor := Cursor;
    MouseCapture := FALSE;
    FCurrentItem := -1;
    FCurrentMargin := wprulMarginNone;
  end;
end;

function TWPRuler.GetCurrValue(index: TWPRulerItemType): Integer;
var i: Integer;
begin
  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp = index then
    begin
      Result := FItems[i].FValue;
      exit;
    end;
  if index in [wprulFirstIndent, wprulLeftIndentSimple] then
    Result := CurrValue[wprulLeftIndent]
  else
    if index in [wprulLeftIndent, wprulLeftIndentSimple] then
      Result := 0
    else if index = wprulRightIndent then
      Result := FPageWidth - FRightMargin - FLeftMargin
    else Result := 0;

end;

procedure TWPRuler.SetDesign(x: TWPRulerDesign);
begin
  if FDesign <> x then
  begin FDesign := x;
    Invalidate;
  end;
end;

procedure TWPRuler.SetTabKind(x: TTabKind);
begin
  if FTabKind <> x then
  begin FTabKind := x;
    Invalidate;
  end;
end;

procedure TWPRuler.SetOptions(x: TWPRulerOptions);
begin
  if FOptions <> x then
  begin FOptions := x;
    Invalidate;
  end;
end;

procedure TWPRuler.SetCurrValue(index: TWPRulerItemType; Value: Integer);
var i: Integer;
begin
  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp = index then
    begin
      FItems[i].FValue := Value;
      exit;
    end;
  AddItem(index, Value, true, 0, -FLeftMargin, FPageWidth - FLeftMargin);
end;

procedure TWPRuler.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var v, off: Integer;
  aHeader: TWPRTFSectionProps;
begin
  if (FCurrentMargin <> wprulMarginNone) or
    (FCurrentItem >= 0) then
    LockForMove := GetTickCount + 500;
  FMouseX := x;
  FMouseY := y;
  FLocked := TRUE;
  try
    inherited MouseUp(Button, Shift, X, y);
    FMouseDown := FALSE;
    Line(0, 0, 0, 0, false);
    if FCurrentMargin <> wprulMarginNone then
    begin
      Screen.Cursor := Cursor;
      MouseCapture := FALSE;
      if FCurrSource <> nil then
      begin
        aHeader := GetPageProps;
        if FIsTable then
        begin
          //TODO

        end else
          if {$IFDEF RULERDOESNTUSELOGPAGE}aHeader.MarginMirror and ((FCurrSource.Cursor.active_page and 1) = 0){$ELSE}false{$ENDIF} then
          begin
            if (FCurrentMargin = wprulMarginLeft) and Changing(wprulerMarginLeft) then
            begin
              aHeader.RightMargin := FLeftMargin;
              Changed(wprulerMarginLeft);
            end
            else
              if (FCurrentMargin = wprulMarginRight) and Changing(wprulerMarginRight) then
              begin
                aHeader.LeftMargin := FRightMargin;
                Changed(wprulerMarginRight);
              end;
          end else
          begin
            if (FCurrentMargin = wprulMarginLeft) and Changing(wprulerMarginLeft) then
            begin
              aHeader.LeftMargin := FLeftMargin;
              Changed(wprulerMarginLeft);
            end
            else
              if (FCurrentMargin = wprulMarginRight) and Changing(wprulerMarginRight) then
              begin
                aHeader.RightMargin := FRightMargin;
                Changed(wprulerMarginRight);
              end;
          end;
        UpdateFrom(FCurrSource, FCurrControl);
      end;
      FCurrentMargin := wprulMarginNone;
    end else
      if FCurrentItem >= 0 then
      begin
        if (FItems[FCurrentItem].FTyp in [wprulTabCenter,
          wprulTabRight, wprulTabDecimal, wprulTabLeft, wprulTabBar])
          and Changing(wprulerTab) then
        begin
          if FMouseY > Height + 3 then
          begin
            if FCurrSource <> nil then
            begin
              FCurrSource.NewUndolevel;
              FCurrSource.Cursor.CurrAttribute.TabstopDelete(FItems[FCurrentItem].FId);
            // Make sure the TabstopDiff array is read agaian!
              if FCurrSource.Cursor.IsSelected then
                FCurrSource.Cursor.CurrAttribute.Clear;
              UpdateFrom(FCurrSource, FCurrControl);
              Changed(wprulerTab);
            end else
            begin
              DeleteItem(FCurrentItem);
              Changed(wprulerTab);
            end;
          end
          else
          begin
            if FCurrSource <> nil then
            begin
              FCurrSource.NewUndolevel;
              FCurrSource.Cursor.CurrAttribute.TabstopMove(FItems[FCurrentItem].FId,
                FItems[FCurrentItem].FValue - FCellLeft);
              UpdateFrom(FCurrSource, FCurrControl);
              Changed(wprulerTab);
            end else
              exclude(FItems[FCurrentItem].FMode, wprulTempHidden);
          end;

          Screen.Cursor := Cursor;
          MouseCapture := FALSE;
          FCurrentItem := -1;
        end else
        begin
          if FCurrSource <> nil then
          begin
            case FItems[FCurrentItem].FTyp of
              wprulLeftIndent,
                wprulLeftIndentSimple:
                if Changing(wprulerLeftIndent) then
                begin
                  if FShiftMode then
                  begin
                    off := CurrValue[wprulFirstIndent] - FItems[FCurrentItem].FValue;
                    FCurrSource.Cursor.CurrAttribute.ASet(WPAT_IndentFirst, off);
                  end;
                  FCurrSource.Cursor.CurrAttribute.ASet(
                    WPAT_IndentLeft, FItems[FCurrentItem].FValue - FCellLeft);
                  Changed(wprulerLeftIndent);
                end;
              wprulFirstIndent:
                if Changing(wprulerFirstIndent) then
                begin
                  FCurrSource.Cursor.CurrAttribute.ASet(
                    WPAT_IndentFirst, FItems[FCurrentItem].FValue - CurrValue[wprulLeftIndent]);
                  Changed(wprulerFirstIndent);
                end;
              wprulRightIndent:
                if Changing(wprulerRightIndent) then
                begin
                  if FCellRight <> 0 then
                    v := FCellRight - FItems[FCurrentItem].FValue
                  else
                    v := FPageWidth - FLeftMargin - FRightMargin - FItems[FCurrentItem].FValue;
                  FCurrSource.Cursor.CurrAttribute.ASet(WPAT_IndentRight, v);
                  Changed(wprulerRightIndent);
                end;
            end;
            UpdateFrom(FCurrSource, FCurrControl);
          end;

          Screen.Cursor := Cursor;
          MouseCapture := FALSE;
          FCurrentItem := -1;
        end;
      end else
        if (x >= FTabSelectorR.Left) and (x < FTabSelectorR.Right) and
          (y > FTabSelectorR.Top) and (y < FTabSelectorR.Bottom) then
        begin
          case FTabKind of
            tkLeft: FTabKind := tkRight;
            tkRight: FTabKind := tkCenter;
            tkCenter: FTabKind := tkDecimal;
            tkDecimal: FTabKind := tkLeft;
          end;
          Paint;
        end;
  finally
    FLocked := FALSE;
  end;
end;

procedure TWPRuler.Click;
var tw: Integer;
const tab: array[TTabKind] of TWPRulerItemType =
  (wprulTabLeft, wprulTabRight, wprulTabCenter, wprulTabDecimal, wprulTabBar);
begin
  inherited Click;
  if FCurrSource <> nil then
    tw := Round((FMouseX - FOffset) / WPScreenPixelsPerInch / FZoom * 1440) +
      (-TheLeftMargin - FCellLeft) else exit;
  inherited Click;
  if (tw > 0) and (tw < FPageWidth - FRightMargin) and (FCurrentItem < 0) and
    (FCurrentMargin = wprulMarginNone) and
    (GetTickCount > LockForMove) and
    Changing(wprulerTab)
    then
  begin
    if FCurrSource <> nil then
    begin
      FCurrSource.NewUndolevel;
      FCurrSource.Cursor.CurrAttribute.TabstopAdd(
        tw, FTabKind, tkNoFill, 0);
      UpdateFrom(FCurrSource, FCurrControl);
      Changed(wprulerTab);
      Paint;
    end else
    begin
      AddItem(tab[FTabKind], tw, true, 0, 0, MaxInt);
      Changed(wprulerTab);
      Paint;
    end;
  end;
end;

procedure TWPRuler.DblClick;
begin
  inherited DblClick;
end;

procedure TWPCustomRuler.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TWPRuler.Paint;
var i: Integer;
  r, r2: TRect;
  res: Integer;
begin
  inherited Paint;
  if (Width <= 0) or (Height <= 0) then exit;
  if FBuffer.Width < Width then FBuffer.Width := Width;
  if FBuffer.Height < Height then FBuffer.Height := Height;
  res := Screen.PixelsPerInch;
      // Background
  r.Left := 0;
  r.Right := Width;
  FBuffer.Canvas.Brush.Color := FColorBorder;
  r.Top := Height - 2;
  r.Bottom := Height;
  FBuffer.Canvas.FillRect(r);

  FBuffer.Canvas.Brush.Color := FColorBack;

  if not (wpNoVertRulerAttached in FOptions) then
  begin
    if wrShadedBackground in FDrawOptions then
      FBuffer.Canvas.Brush.Color := $BABABA;
    r2 := r;
    r2.Right := 24;
    FBuffer.Canvas.FillRect(r2);
  end;

  r.Bottom := r.Top;
  r.Top := 0;
  if wrShadedBackground in FDrawOptions then
    WPGradientFill(FBuffer.Canvas.Handle, r, $BABABA, $F0F0EC, true)
  else
    FBuffer.Canvas.FillRect(r);

      // Paper Area
  r.Left := FOffset;
  r.Right := FOffset + Round((FPageWidth - TheRightMargin) / 1440 * res * FZoom);
  r.Top := WPRUL_TOPMARG;
  r.Bottom := Height - WPRUL_BOTMARG;
  FBuffer.Canvas.Brush.Color := FColorPaper;
  FBuffer.Canvas.FillRect(r);

  if (FCellLeft <> 0) or (FCellRight <> 0) then
  begin
    r2 := r;
    { Simple blue lines
    FBuffer.Canvas.Brush.Style := bsClear;
    FBuffer.Canvas.Pen.Style := psSolid;
    FBuffer.Canvas.Pen.Width := 0;
    FBuffer.Canvas.Pen.Color := clBlue;
    r2.Left := FOffset + Round((FCellLeft + FLeftMargin) / 1440 * res * FZoom); ;
    r2.Right := FOffset + Round((FLeftMargin + FCellRight) / 1440 * res * FZoom);
    FBuffer.Canvas.Rectangle(r2.left, r2.top, r2.Right, r2.Bottom); }
    r2.Left := FOffset + Round((TheLeftMargin) / 1440 * res * FZoom);
    r2.Right := FOffset + Round((FCellLeft + TheLeftMargin) / 1440 * res * FZoom);
    FBuffer.Canvas.Brush.Style := bsSolid;
    FBuffer.Canvas.Brush.Color := FColorMargin;
    FBuffer.Canvas.FillRect(r2);

    r2.Left := FOffset + Round((FCellRight + TheLeftMargin) / 1440 * res * FZoom);
    r2.Right := r.Right;
    FBuffer.Canvas.FillRect(r2);
  end;

      // Margins
  if wpStartMargin in Margins then
  begin
    FBuffer.Canvas.Brush.Color := FColorMargin;
    r.Left := FOffset;
    r.Right := FOffset + Round((FLeftMargin) / 1440 * res * FZoom);
    FBuffer.Canvas.FillRect(r);
    r.Left := r.Right - 2;
    FLeftMarginX := r.Left + 1;
    FBuffer.Canvas.Brush.Color := FColorBorder;
    FBuffer.Canvas.FillRect(r);
  end;

  if wpEndMargin in Margins then
  begin
    FBuffer.Canvas.Brush.Color := FColorMargin;
    r.Left := FOffset + Round((FPageWidth - FRightMargin) / 1440 * res * FZoom); ;
    r.Right := FOffset + Round((FPageWidth) / 1440 * res * FZoom);
    FBuffer.Canvas.FillRect(r);
    r.Right := r.Left + 2;
    FRightMarginX := r.Right - 1;
    FBuffer.Canvas.Brush.Color := FColorBorder;
    FBuffer.Canvas.FillRect(r);
  end;

  if assigned(FOnPaint) then
    FOnPaint(Self, FBuffer.Canvas, ClientRect);

      // Paint Scale
  PaintScale(FOffset, height div 2 - WPRUL_CENTEROFF);


  if wrShowTabSelector in FOptions then
    PaintSelector;

  // Items
  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp = wprulTableBorder then
    begin
      include(FItems[i].FMode, wprulNotMouseActive);
      if FItems[i].FId = 0 then
        FItems[i].FValue := 0
      else FItems[i].FValue := FPageWidth - FLeftMargin - FRightMargin;
      PaintItem(i);
    end;

  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp = wprulTableColumn then
    begin
{$IFDEF NOCOLRESIZE}
      include(FItems[i].FMode, wprulNotMouseActive);
{$ENDIF}
      PaintItem(i);
    end;

  if (wrShow3DLines in FDrawOptions) then
    with FBuffer.Canvas do
    begin
        // Top
      Pen.Width := 0;
      Pen.Color := clWhite;
      MoveTo(0, 0);
      LineTo(Width, 0);
      Pen.Color := clBtnFace;
      MoveTo(0, 1);
      LineTo(Width, 1);
      Pen.Color := clBtnShadow;
      MoveTo(0, 2);
      LineTo(Width, 2);
        // Bottom
      Pen.Color := clWhite;
      MoveTo(0, Height - 5);
      LineTo(Width, Height - 5);
      Pen.Color := clBtnFace;
      MoveTo(0, Height - 4);
      LineTo(Width, Height - 4);
      Pen.Color := clBtnShadow;
      MoveTo(0, Height - 3);
      LineTo(Width, Height - 3);
    end;

  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp in [wprulTabCenter, wprulTabRight,
      wprulTabDecimal, wprulTabLeft, wprulTabBar] then
      PaintItem(i);

  for i := 0 to FItemCount - 1 do
    if FItems[i].FTyp in [wprulLeftIndent,
      wprulLeftIndentSimple, wprulFirstIndent, wprulRightIndent] then
      PaintItem(i);

  Canvas.Draw(0, 0, FBuffer);
end;

function TWPRuler.ItemAtXY(x, y: Integer; IgnoreIndents: Boolean = FALSE): Integer;
var i: Integer;
begin
  Result := -1;
  for i := 0 to FItemCount - 1 do
  begin
    if not (wprulNotMouseActive in FItems[i].FMode) and
      (not IgnoreIndents or
      not (FItems[i].FTyp in [wprulLeftIndent,
      wprulLeftIndentSimple, wprulFirstIndent, wprulRightIndent])) and
      (FItems[i].r.Left <= x) and
      (FItems[i].r.Right > x) and
      (FItems[i].r.Top <= y) and
      (FItems[i].r.Bottom > y) then
    begin
      Result := i;
      exit;
    end;
  end;
end;

function TWPRuler.TheLeftMargin: Integer;
begin
  if wpStartMargin in Margins then
    Result := FLeftMargin
  else Result := 0;
end;

function TWPRuler.TheRightMargin: Integer;
begin
  if wpStartMargin in Margins then
    Result := 0
  else Result := FRightMargin + FLeftMargin;
end;

procedure TWPRuler.PaintSelector;
var
  r: TRect;
begin
  inherited Paint;
  if not Visible then exit;
  with FBuffer.Canvas do
  begin
    r.Left := 2;
    r.Right := r.Left + 17;
    r.Top := (Height - 17) div 2 - 1;
    r.Bottom := r.Top + 17;

    FTabSelectorR := r;

    Pen.Color := clBtnShadow;
    Pen.Width := 0;
    Pen.Style := psSolid;
    Brush.Color := clBtnFace;
    Brush.Style := bsSolid;
    InflateRect(r, -1, -1);
    Rectangle(r.Left, r.Top, R.Right, r.Bottom);
    InflateRect(r, -1, -1);
    Pen.Color := clWhite;
    MoveTo(R.Left, R.Bottom - 1);
    LineTo(R.Left, R.Top);
    LineTo(R.Right, R.Top);
    Pen.Color := clBtnShadow;
    LineTo(R.Right, R.Bottom);
    LineTo(R.Left, R.Bottom);

    Inc(r.Left, 2);
    Inc(r.Top, 2);
    Dec(r.Right, 3);
    Dec(r.Bottom, 3);

    Pen.Color := clBlack;
    Pen.Width := 0;
    Pen.Style := psSolid;
    case FTabkind of
      tkRight:
        begin
          MoveTo(r.Right, r.Top + 1);
          LineTo(r.Right, r.Bottom);
          LineTo(r.Left - 1, r.Bottom);
          MoveTo(r.Right - 1, r.Top + 1);
          LineTo(r.Right - 1, r.Bottom - 1);
          LineTo(r.Left - 1, r.Bottom - 1);
        end; { _| }
      tkCenter,
        tkDecimal: begin
          Pen.Width := 1;
          MoveTo((r.Right + r.Left) div 2, r.Top + 1);
          LineTo((r.Right + r.Left) div 2, r.Bottom);
          MoveTo((r.Right + r.Left) div 2 + 1, r.Top + 1);
          LineTo((r.Right + r.Left) div 2 + 1, r.Bottom);
          MoveTo(r.Left, r.Bottom - 1); LineTo(r.Right + 1, r.Bottom - 1); { _|_ }
          MoveTo(r.Left, r.Bottom); LineTo(r.Right + 1, r.Bottom); { _|_ }
          Pen.Width := 2;
          if FTabkind = tkDecimal then
          begin
            MoveTo(r.Right, r.Top + 1);
            LineTo(r.Right, r.Top + 2);
          end;
        end;
      tkLeft:
        begin
          MoveTo(r.Left + 1, r.Top + 1);
          LineTo(r.Left + 1, r.Bottom - 1);
          LineTo(r.Right + 1, r.Bottom - 1);
          MoveTo(r.Left, r.Top + 1);
          LineTo(r.Left, r.Bottom);
          LineTo(r.Right + 1, r.Bottom);
        end; { |_ }
    end;
  end;
end;

procedure TWPRuler.Loaded;
begin
  inherited Loaded;
{$IFDEF ASSIGNDEFSIZE}Height := 26; {$ENDIF}
end;

procedure TWPRuler.PaintScale(x, y: Integer);
var xo, xomax, xostep, res, fHigh, aZoom: Extended;
  ax, axstart, w, h: Integer;
  s: string;
  procedure DrawIt(Direction: Integer);
  begin
    xo := 0;
    with FBuffer.Canvas do
    begin
      Pen.Color := FColorLines;
      Pen.Width := 0;
      while xo < xomax do
      begin
        ax := axstart + Direction * Round(xo * res * aZoom);
        if (FZoom > 0.3) and (xo > 0) and (Frac(xo) < 0.001) then
        begin
          s := IntToStr(Trunc(xo + 0.001));
          w := TextWidth(s);
          TextOut(ax - w div 2, y - h + 1, s);
        end else
          if (xo > 0) and (Abs(Frac(xo - fHigh)) < 0.001) then
          begin
            MoveTo(ax, y - 3);
            LineTo(ax, y + 3);
          end else
          begin
            MoveTo(ax, y - 2);
            LineTo(ax, y + 2);
          end;
        xo := xo + xostep;
      end;
    end;
  end;
begin
  res := WPScreenPixelsPerInch;
  if FUnits = wrInch then
  begin
    xostep := 0.125; // 1/8
    aZoom := FZoom;
    fHigh := 0.5;
  end else
  begin
    xostep := 0.25; // 1/4
    aZoom := FZoom / 2.54;
    fHigh := 0.5;
  end;

  if res * xostep * FZoom < 4 then xostep := 1;
  if res * xostep * FZoom < 4 then xostep := 2.5;
  if res * xostep * FZoom < 4 then xostep := 5;
  if res * xostep * FZoom < 4 then xostep := 10;

  FBuffer.Canvas.Font.Name := 'Tahoma';
  if wrUseSmallNumbers in DrawOptions then
    FBuffer.Canvas.Font.Height := -9
  else FBuffer.Canvas.Font.Height := -12;
  FBuffer.Canvas.Brush.Style := bsClear;
  h := FBuffer.Canvas.TextHeight('1') div 2 + 1;

  axstart := x + Round(TheLeftMargin / 1440 * res * FZoom);
  if FUnits = wrInch then
    xomax := (FPageWidth - TheLeftMargin) / 1440
  else xomax := (FPageWidth - TheLeftMargin) / 1440 * 2.54;
  DrawIt(1); // Positive

  if wpStartMargin in Margins then
  begin
    if FUnits = wrInch then
      xomax := (FLeftMargin) / 1440
    else xomax := (FLeftMargin) / 1440 * 2.54;
    DrawIt(-1); // Negative
  end;
end;

procedure TWPRuler.CalcItemLeft(var x, y, h: Integer; Typ: TWPRulerItemType);
const ImgWidth = 5;
  TabOff = 2;
begin
  h := 9;
  case Typ of
    wprulLeftIndent:
      begin
        if FDesign = wpRulerSimple then
        begin
          inc(y);
          h := 6;
        end else
        begin
          dec(x, ImgWidth);
          h := 15;
        end;
      end;
    wprulLeftIndentSimple:
      begin
        if FDesign = wpRulerSimple then
        begin
          inc(y);
          h := 6;
        end else
        begin
          dec(x, ImgWidth);
        end;
      end;
    wprulFirstIndent:
      begin
        if FDesign = wpRulerSimple then
        begin
          dec(y, 8);
        end else
        begin
          dec(x, ImgWidth);
          dec(y, 10);
        end;
      end;
    wprulRightIndent:
      begin
        if FDesign = wpRulerSimple then
        begin
          dec(x, 8);
          dec(y, 8);
        end else
        begin
          dec(x, ImgWidth);
          dec(y, 10);
        end;
      end;
    wprulTabCenter:
      begin
        inc(y, TabOff);
        dec(x, 5);
      end;
    wprulTabRight:
      begin
        inc(y, TabOff);
        dec(x, 10);
      end;
    wprulTabDecimal:
      begin
        inc(y, TabOff);
        dec(x, 5);
      end;
    wprulTabLeft:
      begin
        inc(y, TabOff);
        dec(x, 4);
      end;
    wprulTabBar:
      begin
        inc(y, TabOff);
        dec(x, ImgWidth);
      end;
    wprulTableColumn:
      begin
        dec(x, ImgWidth);
        dec(y, 5);
      end;
    wprulTableBorder:
      begin
        dec(x, ImgWidth);
        dec(y, 4);
      end;
  end;
end;

procedure TWPRuler.DeleteItem(nr: Integer);
var i: Integer;
begin
  if (nr >= 0) and (nr < FItemCount) then
  begin
    i := nr;
    while i < FItemCount - 1 do
    begin
      Fitems[i] := Fitems[i + 1];
      inc(i);
    end;
    dec(FItemCount);
    Invalidate;
  end;
end;

procedure TWPRuler.PaintItem(nr: Integer);
var x, y: Integer;
  h, masky: Integer;
  res, val: Extended;
  r: TRect;
  typ: TWPRulerItemType;
  IsOffScreen: Boolean;
begin
  res := WPScreenPixelsPerInch;
  if (nr < 0) or (nr > FItemCount) or (wprulTempHidden in FItems[nr].FMode) then exit;

  val := FItems[nr].FValue;

  if val < -TheLeftMargin then
  begin
    if FItems[nr].FTyp < wprulTabCenter then
      val := -TheLeftMargin;
    IsOffScreen := TRUE;
  end else
    if val > FPageWidth - TheLeftMargin - TheRightMargin then
    begin
      if FItems[nr].FTyp < wprulTabCenter then
        val := FPageWidth - TheLeftMargin;
      IsOffScreen := TRUE;
    end
    else IsOffScreen := FALSE;

  x := FOffset + Round((val + TheLeftMargin) / 1440 * res * FZoom);

  y := Height div 2 - WPRUL_CENTEROFF;
  typ := FItems[nr].FTyp;
  CalcItemLeft(x, y, h, typ);

  if typ = wprulTableBorder then
  begin
    if FItems[nr].FId = 0 then dec(x, 6)
    else inc(x, 6);
  end;

  r.Left := 11 * Integer(typ);
  r.Right := 11 * (Integer(typ) + 1);
  if FDesign = wpRulerSimple then
  begin
    r.Top := 0;
    r.Bottom := 15;
  end else
    if IsOffScreen or (wprulDisabled in FItems[nr].FMode) then
    begin
      r.Top := 15;
      r.Bottom := 30;
    end else
    begin
      r.Top := 30 + (Integer(FDesign) - 1) * 15;
      r.Bottom := 45 + (Integer(FDesign) - 1) * 15;
    end;

  if typ = wprulTableColumn then
  begin
    FBuffer.Canvas.Brush.Color := FColorTableMarker;
    FBuffer.Canvas.FillRect(
      Rect(x - 1, 0, x + 11 + 1, Height - 2));
  end;

  // FBuffer.Canvas.CopyRect(Rect(x,y,x+11,y+15), FImages.Canvas, r);
  if FDesign = wpRulerSimple then masky := 15 else masky := 0;
  TransparentStretchBlt(
    FBuffer.Canvas.Handle, x, y, 11, 15, // Dest, X,Y, W, H
    FImages.Canvas.Handle, r.Left, r.Top, 11, 15, // Source
    FMask.Canvas.Handle, r.Left, masky // Mask
    );
  FItems[nr].r.Left := x;
  FItems[nr].r.Right := x + 11;
  FItems[nr].r.Top := y;
  FItems[nr].r.Bottom := y + h;
end;

    // procedure   InitFromPar( par : TParagraph );

function TWPRuler.AddItem(
  Typ: TWPRulerItemType;
  Value: Integer;
  aEnabled: Boolean;
  Id: Integer;
  minv, maxv: Integer): Integer;
begin
  if FItemCount + 10 > Length(FItems) then
    SetLength(FItems, Length(FItems) + 10);
  FItems[FItemCount].FTyp := Typ;
  FItems[FItemCount].FValue := Value;
  FItems[FItemCount].FMin := minv;
  FItems[FItemCount].FMax := maxv;
  if aEnabled then FItems[FItemCount].FMode := []
  else FItems[FItemCount].FMode := [wprulDisabled];
  FItems[FItemCount].FId := Id;
  Result := FItemCount;
  inc(FItemCount);
end;



procedure TWPRuler.UpdateFrom(Source: TWPRTFDataCollection; Control: TControl; par: TWPTextStyle = nil);
var v, v1, i, ami, amx: Integer;
  defined: Boolean;
  TabValue: Integer;
  Kind: TTabKind;
  FillMode: TTabFill;
  FillColor: Integer;
  aHeader: TWPRTFSectionProps;
  aPar, row, cell, table: TParagraph;
  FCurrInterface: TWPSelectedTextAttrInterface;
const tab: array[TTabKind] of TWPRulerItemType =
  (wprulTabLeft, wprulTabRight, wprulTabCenter, wprulTabDecimal, wprulTabBar);
begin
  FItemCount := 0;
  inherited UpdateFrom(Source, Control, par);

  if not FMouseDown and (Source <> nil) then
  begin
    FCurrInterface := Source.Cursor.CurrAttribute;

    if par = nil then
      par := Source.Cursor.active_paragraph;

    aHeader := GetPageProps;
    // 1. Margins
    if {$IFDEF RULERDOESNTUSELOGPAGE}aHeader.MarginMirror and ((Source.Cursor.active_page and 1) = 0){$ELSE}false{$ENDIF} then
    begin
      FRightMargin := aHeader.LeftMargin;
      FLeftMargin := aHeader.RightMargin;
    end else
    begin
      FLeftMargin := aHeader.LeftMargin;
      FRightMargin := aHeader.RightMargin;
    end;
    FPageWidth := aHeader.PageWidth;

    FIsTable := FALSE;
    if not FLocked and not FMouseDown then
    begin
      FCellLeft := 0;
      FCellRight := 0;
    end;
    ami := -FLeftMargin;
    amx := FPageWidth - FLeftMargin - FRightMargin;

    // 2. Tables
    if (par <> nil) and (par is TParagraph) then
    begin
      row := TParagraph(par).ParentRow;
      if row <> nil then
      begin
        cell := TParagraph(par).Cell;
        table := row.ParentTable;
        if table <> nil then
        begin
          v := 0;
          table.AGet(WPAT_BoxMarginLeft, v);
          FLeftMargin := FLeftMargin + v;

          if table.AGet(WPAT_BoxWidth, v) then
          begin
            FRightMargin := FPageWidth - FLeftMargin - v;
          end else
            if table.AGet(WPAT_BoxMarginRight, v) then
              FRightMargin := v + FRightMargin
                ; //V5.19.5  else FRightMargin := FRightMargin - (FLeftMargin - aHeader.LeftMargin);
          if FRightMargin < 0 then FRightMargin := 0;

          FIsTable := TRUE;

          AddItem(wprulTableBorder, 0, true, 0, -FLeftMargin, FRightMargin);
          AddItem(wprulTableBorder, FPageWidth - FRightMargin, true, 1,
            0, FPageWidth);
        end;


        aPar := row.ChildPar;
        v := 0;
        i := 0;
        while aPar <> nil do
        begin
          if aPar = cell then
          begin
            if not FLocked then
            begin
              FCellLeft := v;
              FCellRight := v + aPar._ActCellWidth;
            end;
            ami := FCellLeft;
            amx := FCellRight;
          end;
          inc(v, aPar._IsWidthTw);
          inc(i);
          if aPar.NextPar <> nil then
            AddItem(wprulTableColumn, v, true, i, v - aPar._IsWidthTw, v + aPar.NextPar._IsWidthTw);
          aPar := aPar.NextPar;
        end;
      end;
    end;
    // 3. Indents
    if par <> nil then
    begin
      if wrShowIndents in FOptions then
      begin
        defined := FCurrInterface.AGetInherited(WPAT_IndentLeft, v);
        AddItem(wprulLeftIndent, v + FCellLeft, defined, 0, ami, amx);

        defined := FCurrInterface.AGetInherited(WPAT_IndentFirst, v1) or defined;
        AddItem(wprulFirstIndent, v + v1 + FCellLeft, defined, 0, ami, amx);

        defined := FCurrInterface.AGetInherited(WPAT_IndentRight, v);
        AddItem(wprulRightIndent, amx - v, defined, 0, ami, amx
          + FRightMargin);
      end;

      if wrShowTabStops in FOptions then
      begin
        for i := 0 to FCurrInterface.TabstopCount - 1 do
        begin
          FCurrInterface.TabstopGet(i, TabValue, Kind, FillMode, FillColor);
          AddItem(tab[Kind], TabValue + FCellLeft, true, TabValue, ami, amx);
        end;

        for i := 0 to FCurrInterface.TabstopDiffCount - 1 do
        begin
          FCurrInterface.TabstopDiffGet(i, TabValue, Kind, FillMode, FillColor);
          AddItem(tab[Kind], TabValue + FCellLeft, false, TabValue, ami, amx);
        end;
      end;
    end;
  end;
  Invalidate;
end;

// -----------------------------------------------------------------------------
// TWPVertRuler
// -----------------------------------------------------------------------------

procedure TWPVertRuler.UpdateFrom(Source: TWPRTFDataCollection; Control: TControl; par: TWPTextStyle = nil);
var aHeader: TWPRTFSectionProps;
begin
  inherited UpdateFrom(Source, Control, par);
  if Source <> nil then
  begin
    aHeader := GetPageProps;
    FTopMargin := aHeader.TopMargin;
    FBottomMargin := aHeader.BottomMargin;
    FPageHeight := aHeader.PageHeight;
    Invalidate;
  end;
end;

procedure TWPVertRuler.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FMouseDown := TRUE;
end;

procedure TWPVertRuler.MouseMove(Shift: TShiftState; X, Y: Integer);
var tw: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if FMouseDown and (FCurrentMargin <> wprulMarginNone) then
  begin
    tw := Round((y - FOffset) / WPScreenPixelsPerInch / FZoom * 1440);

    if FCurrControl <> nil then
    begin
      Line(2, y, FCurrControl.Width - 2, y, true);
    end;

    if tw < 0 then tw := 0;
    if FCurrentMargin = wprulMarginTop then
    begin
      if tw < FPageHeight - FBottomMargin - 720 then
        FTopMargin := tw;
    end
    else if FCurrentMargin = wprulMarginBottom then
    begin
      if tw > FTopMargin + 720 then
        FBottomMargin := FPageHeight - tw;
      if FBottomMargin < 0 then FBottomMargin := 0;
    end;
    Paint;
  end else
    if (y <= FTopMarginY) and (y >= FTopMarginY - 4)
      and (wpStartMargin in Margins) then
    begin
      FCurrentMargin := wprulMarginTop;
      Screen.Cursor := crSizeNS;
      MouseCapture := TRUE;
    end else
      if (y >= FBottomMarginY) and (y <= FBottomMarginY + 4)
        and (wpEndMargin in Margins) then
      begin
        FCurrentMargin := wprulMarginBottom;
        Screen.Cursor := crSizeNS;
        MouseCapture := TRUE;
      end
      else Normalize;
end;

procedure TWPVertRuler.Normalize;
begin
  if FCurrentMargin <> wprulMarginNone then
  begin
    Screen.Cursor := Cursor;
    MouseCapture := FALSE;
    FCurrentMargin := wprulMarginNone;
  end;
end;

procedure TWPVertRuler.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var aHeader: TWPRTFSectionProps;
begin
  inherited MouseUp(Button, Shift, X, Y);
  FMouseDown := FALSE;
  if FCurrentMargin <> wprulMarginNone then
  begin
    Screen.Cursor := Cursor;
    MouseCapture := FALSE;
    if FCurrSource <> nil then
    begin
      aHeader := GetPageProps;
      Line(0, 0, 0, 0, false);
      if (FCurrentMargin = wprulMarginTop) and Changing(wprulerMarginTop) then
      begin
        aHeader.TopMargin := FTopMargin;
        Changed(wprulerMarginTop);
      end
      else
        if (FCurrentMargin = wprulMarginBottom) and Changing(wprulerMarginBottom) then
        begin
          aHeader.BottomMargin := FBottomMargin;
          Changed(wprulerMarginBottom);
        end;
      UpdateFrom(FCurrSource, FCurrControl);
    end;
    FCurrentMargin := wprulMarginNone;
  end;
end;

constructor TWPVertRuler.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FBuffer := TBitmap.Create;
  FPageHeight := WPCentimeterToTwips(29.7);
  FTopMargin := WPCentimeterToTwips(2);
  FBottomMargin := WPCentimeterToTwips(2);
  FOffset := 20;
  Height := 100;
  Width := 26;
  Align := alLeft;
end;

destructor TWPVertRuler.Destroy;
begin
  FBuffer.Free;
  inherited Destroy;
end;

procedure TWPVertRuler.Loaded;
begin
  inherited Loaded;
{$IFDEF ASSIGNDEFSIZE}Width := 26; {$ENDIF}
end;

procedure TWPVertRuler.PaintScale(x, y: Integer);
var xo, xomax, xostep, res, fHigh, aZoom: Extended;
  ax, axstart, w, h: Integer;
  oldfont, newfont: HFONT;
  s: string;
  procedure DrawIt(Direction: Integer);
  begin
    xo := 0;
    with FBuffer.Canvas do
    begin
      Pen.Color := FColorLines;
      Pen.Width := 0;
      while xo < xomax do
      begin
        ax := axstart + Direction * Round(xo * res * aZoom);
        if (FZoom > 0.3) and (xo > 0) and (Frac(xo) < 0.001) then
        begin
          s := IntToStr(Trunc(xo + 0.001));
          w := TextWidth(s);
          TextOut(y - h + 1, ax + w div 2, s);
        end else
          if (xo > 0) and (Abs(Frac(xo - fHigh)) < 0.001) then
          begin
            MoveTo(y - 3, ax);
            LineTo(y + 3, ax);
          end else
          begin
            MoveTo(y - 2, ax);
            LineTo(y + 2, ax);
          end;
        xo := xo + xostep;
      end;
    end;
  end;
begin
  res := WPScreenPixelsPerInch;
  if FUnits = wrInch then
  begin
    xostep := 0.125; // 1/8
    aZoom := FZoom;
    fHigh := 0.5;
  end else
  begin
    xostep := 0.25; // 1/4
    aZoom := FZoom / 2.54;
    fHigh := 0.5;
  end;

  if res * xostep * FZoom < 4 then xostep := 1;
  if res * xostep * FZoom < 4 then xostep := 2.5;
  if res * xostep * FZoom < 4 then xostep := 5;
  if res * xostep * FZoom < 4 then xostep := 10;

  FBuffer.Canvas.Brush.Style := bsClear;

  if wrUseSmallNumbers in DrawOptions then
    newfont := CreateFont(-9, 0, 900, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Tahoma')
  else newfont := CreateFont(-12, 0, 900, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Tahoma');

  oldfont := SelectObject(FBuffer.Canvas.Handle, newfont);
  try
    h := FBuffer.Canvas.TextHeight('1') div 2 + 1;

    axstart := x + Round(TheTopMargin / 1440 * res * FZoom);
    if FUnits = wrInch then
      xomax := (FPageHeight - TheTopMargin - TheBottomMargin) / 1440
    else xomax := (FPageHeight - TheTopMargin - TheBottomMargin) / 1440 * 2.54;
    DrawIt(1); // Positive

    if wpStartMargin in Margins then
    begin
      if FUnits = wrInch then
        xomax := (FTopMargin) / 1440
      else xomax := (FTopMargin) / 1440 * 2.54;
      DrawIt(-1); // Negative
    end;

  finally
    if oldfont <> 0 then SelectObject(FBuffer.Canvas.Handle, oldfont);
    DeleteObject(newfont);
  end;

end;

function TWPVertRuler.TheTopMargin;
begin
  if wpStartMargin in Margins then
    Result := FTopMargin
  else Result := 0;
end;

function TWPVertRuler.TheBottomMargin: Integer;
begin
  if wpStartMargin in Margins then
    Result := 0
  else Result := FTopMargin + FBottomMargin;
end;

procedure TWPVertRuler.Paint;
var
  r: TRect;
  res: Integer;
begin
  inherited Paint;
  if (Width <= 0) or (Height <= 0) then exit;
  if FBuffer.Width < Width then FBuffer.Width := Width;
  if FBuffer.Height < Height then FBuffer.Height := Height;
  res := Screen.PixelsPerInch;

  // Background
  r.Left := Width - 2;
  r.Right := Width;
  FBuffer.Canvas.Brush.Color := FColorBorder;
  r.Top := 0;
  r.Bottom := Height;
  FBuffer.Canvas.FillRect(r);

  r.Right := r.Left;
  r.Left := 0;
  if wrShadedBackground in FDrawOptions then
    WPGradientFill(FBuffer.Canvas.Handle, r, $BABABA, $F0F0EC, false)
  else
  begin
    FBuffer.Canvas.Brush.Color := FColorBack;
    FBuffer.Canvas.Brush.Style := bsSolid;
    FBuffer.Canvas.FillRect(r);
  end;

  // Paper Area
  r.Top := FOffset;
  r.Bottom := FOffset + Round((FPageHeight - TheBottomMargin) / 1440 * res * FZoom);
  r.Left := WPRUL_TOPMARG;
  r.Right := Width - WPRUL_BOTMARG;
  FBuffer.Canvas.Brush.Color := FColorPaper;
  FBuffer.Canvas.FillRect(r);

      // Margins
  if wpStartMargin in Margins then
  begin
    FBuffer.Canvas.Brush.Color := FColorMargin;
    r.Top := FOffset;
    r.Bottom := FOffset + Round((FTopMargin) / 1440 * res * FZoom);
    FBuffer.Canvas.FillRect(r);
    r.Top := r.Bottom - 2;
    FTopMarginY := r.Top + 1;
    FBuffer.Canvas.Brush.Color := FColorBorder;
    FBuffer.Canvas.FillRect(r);
  end;

  if wpEndMargin in Margins then
  begin
    FBuffer.Canvas.Brush.Color := FColorMargin;
    r.Top := FOffset + Round((FPageHeight - FBottomMargin) / 1440 * res * FZoom); ;
    r.Bottom := FOffset + Round(FPageHeight / 1440 * res * FZoom);
    FBuffer.Canvas.FillRect(r);
    r.Bottom := r.Top + 2;
    FBottomMarginY := r.Bottom - 1;
    FBuffer.Canvas.Brush.Color := FColorBorder;
    FBuffer.Canvas.FillRect(r);
  end;

  if (wrShow3DLines in FDrawOptions) then
    with FBuffer.Canvas do
    begin
        // Top
      Pen.Width := 0;
      Pen.Color := clWhite;
      MoveTo(0, 0);
      LineTo(0, Height);
      Pen.Color := clBtnFace;
      MoveTo(1, 0);
      LineTo(1, Height);
      Pen.Color := clBtnShadow;
      MoveTo(2, 0);
      LineTo(2, Height);
        // Bottom
      Pen.Color := clWhite;
      MoveTo(Width - 5, 0);
      LineTo(Width - 5, Height);
      Pen.Color := clBtnFace;
      MoveTo(Width - 4, 0);
      LineTo(Width - 4, Height);
      Pen.Color := clBtnShadow;
      MoveTo(Width - 3, 0);
      LineTo(Width - 3, Height);
    end;

  if assigned(FOnPaint) then
    FOnPaint(Self, FBuffer.Canvas, ClientRect);

  PaintScale(FOffset, (Width div 2) - WPRUL_CENTEROFF);

  Canvas.Draw(0, 0, FBuffer);
end;

{$IFNDEF NOTABCURSOR}
var h: Integer;

initialization

  h := LoadCursor(HINSTANCE, 'WPRUL_TABDEL');
  if h <> 0 then Screen.cursors[WPRUL_TABDEL_CURSOR] := h;

finalization

  if Screen.cursors[WPRUL_TABDEL_CURSOR] <> 0 then
    Screen.cursors[WPRUL_TABDEL_CURSOR] := 0;
  // VCL Code: DeleteCursor(Index);
  //           if Handle <> 0 then InsertCursor(Index, Handle);
{$ENDIF}

end.

