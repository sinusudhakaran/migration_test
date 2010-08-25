unit WPCTRLabel;
//******************************************************************************
// WPTools V5 - THE word processing component for VCL and .NET
// Copyright (C) 2004 by WPCubed GmbH and Julian Ziersch, all rights reserved
// WEB: http://www.wpcubed.com   mailto: support@wptools.de
//******************************************************************************
// WPCTRLabel - WPTools 5 RTF Label
//******************************************************************************

{$I WPINC.INC}

interface

uses
  Windows, Forms, SysUtils, StdCtrls, ExtCtrls, Messages, 
  Classes, Controls, Graphics, WPRTEDefs, WPRTEPaint, WPIO;

type
  TWPCustomRtfLabel = class(TWPRTFEnginePaint)
  private
    FStretched, FTransparent: Boolean;
    FRTFText: TWPRTFBlobContents;
    FClientMouseX, FClientMouseY: Integer;
    FMouseX, FMouseY, FMousePage: Integer;
    FMouseClickFrameBorder: TWPFrameBorder;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
    FMouse_aRTFData: TWPRTFDataBlock;
    FMouse_par: TParagraph;
    FMouse_pos_in_par: Integer;
    FMouse_SizerElement: TWPPaintSizerRects;
    FMouse_openhyper: TWPTextObj;
    FTextObjectUnderMouse: TWPTextObj;
    FHyperLinkEvent: THyperLinkEvent;
    FOneClickHyperlink: Boolean;
    FHyperLinkCursor: TCursor;
    procedure SetStretched(x: Boolean);
    function GetRTFText: TWPRTFBlobContents;
    procedure SetRTFText(x: TWPRTFBlobContents);
    procedure SetTransparent(x: Boolean);
    procedure SetOnRequestStyle(x: TWPOnRequestStyleEvent);
    function GetOnRequestStyle: TWPOnRequestStyleEvent;
    procedure SetOnRequestHTTPString(x: TWPRequestHTTPStringEvent);
    function GetOnRequestHTTPString: TWPRequestHTTPStringEvent;
    procedure SetOnRequestHTTPImage(x: TWPRequestHTTPImageEvent);
    function GetOnRequestHTTPImage: TWPRequestHTTPImageEvent;
    function GetWordWrap: Boolean;
    procedure SetWordWrap(x: Boolean);
    function GetAsString: string;
    procedure SetAsString(const x: string);
    function GetFormatOptions: TWPFormatOptions;
    procedure SetFormatOptions(x: TWPFormatOptions);
    function GetFormatOptionsEx: TWPFormatOptionsEx;
    procedure SetFormatOptionsEx(x: TWPFormatOptionsEx);
  protected
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
    procedure DblClick; override;
    function CalcMousePageAtXY(WindowX, WindowY: Integer): Integer;
    function CodeInsideOf(par: TParagraph; posinpar: Integer;
      ObjType: TWPTextObjType): TWPTextObj;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;
    procedure BroadcastMsg(Code: Integer; Param: TObject); override;
    procedure Loaded; override;
    function Memo: TWPRTFEnginePaint;
    function Header: TTextHeader;
    procedure Paint; override;
    procedure Resize; override;
    procedure ReformatAll(InitializeAll: Boolean = FALSE; SpellcheckAll: Boolean = FALSE); override;
    procedure Clear;
    function LoadFromFile(const FileName: string; WithClear: Boolean = FALSE): Boolean;
    function GetBodyText: TWPRTFDataBlock;
    property BodyText: TWPRTFDataBlock read GetBodyText;
    property Stretched: Boolean read FStretched write SetStretched default FALSE;
    property RTFText: TWPRTFBlobContents read GetRTFText write SetRTFText;
    property AsString: string read GetAsString write SetAsString;
    property Transparent: Boolean read FTransparent write SetTransparent default TRUE;
    property MouseX: Integer read FMouseX;
    property MouseY: Integer read FMouseY;
    property MousePage: Integer read FMousePage;
    property FormatOptions: TWPFormatOptions read GetFormatOptions write SetFormatOptions;
    property FormatOptionsEx: TWPFormatOptionsEx read GetFormatOptionsEx write SetFormatOptionsEx;
    property OnRequestStyle: TWPOnRequestStyleEvent read GetOnRequestStyle write SetOnRequestStyle;
    property OnRequestHTTPString: TWPRequestHTTPStringEvent read GetOnRequestHTTPString write SetOnRequestHTTPString;
    property OnRequestHTTPImage: TWPRequestHTTPImageEvent read GetOnRequestHTTPImage write SetOnRequestHTTPImage;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default FALSE;
    property HyperLinkCursor: TCursor read FHyperLinkCursor write FHyperLinkCursor default crArrow;
    property OneClickHyperlink: Boolean read FOneClickHyperlink write FOneClickHyperlink default TRUE;
    property HyperLinkEvent: THyperLinkEvent read FHyperLinkEvent write FHyperLinkEvent;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

  TWPRichTextLabel = class(TWPCustomRtfLabel)
  published
    property Stretched;
    property RTFText;
    {:: Only 'normal' layout mode may be used !}
    property LayoutMode;
    property PageColumns;
    property PageRows;
    property AutoZoom;
    property Align;
    property Anchors;
    property Left;
    property Width;
    property Height;
    property Top;
    property Color;
    property Font;
    property Zooming;
    property ViewOptions;
    property FormatOptions;
    property FormatOptionsEx;
    property Visible;
    property Transparent;
    property PaperColor;
    property DeskColor;
    property OnRequestStyle;
    property OnRequestHTTPString;
    property OnRequestHTTPImage;
    property WordWrap;
    property Hint;
    property ShowHint;
    property HyperLinkCursor;
    property OnMouseEnter;
    property OnMouseLeave;
    property OneClickHyperlink;
    property HyperLinkEvent;
    property TextSaveFormat;
    property TextLoadFormat;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property Resizing;
  end;


implementation

constructor TWPCustomRtfLabel.Create(aOwner: TComponent);
begin
  inherited Create(aOwner);
  FRTFText := TWPRTFBlobContents.Create(Self);
  RTFData.RTFProps._SpecialRefCanvas := Canvas;
  // Standard Hyperlink
  RTFData.SpecialTextAttr[wpHyperlink].TextColor := clBlue;
  RTFData.SpecialTextAttr[wpHyperlink].HotUnderlineColor := clred;
  RTFData.SpecialTextAttr[wpHyperlink].HotTextColor := clred;
  ViewOptions := [wpHideSelection];
  DisplayedText := Body;
  LayoutMode := wplayNormal;
  Body.FirstPar.SetText('');
  // Do not skip first page in dual page mode
  FHyperLinkCursor := crArrow;
  FOneClickHyperlink := TRUE;
  FDualPageViewAlternate := TRUE;
  FTransparent := TRUE;
  Resize;
end;

destructor TWPCustomRtfLabel.Destroy;
begin
  FRTFText.Free;
  if RTFData.RTFProps._SpecialRefCanvas = Canvas then
    RTFData.RTFProps._SpecialRefCanvas := nil;
  try
    inherited Destroy;
  except
  end;
end;

procedure TWPCustomRtfLabel.SetTransparent(x: Boolean);
begin
  if FTransparent <> x then
  begin
    FTransparent := x;
    invalidate;
  end;
end;

procedure TWPCustomRtfLabel.SetOnRequestStyle(x: TWPOnRequestStyleEvent);
begin
  RTFData.OnRequestStyle := x;
end;

function TWPCustomRtfLabel.GetOnRequestStyle: TWPOnRequestStyleEvent;
begin
  Result := RTFData.OnRequestStyle;
end;

procedure TWPCustomRtfLabel.SetOnRequestHTTPString(x: TWPRequestHTTPStringEvent);
begin
  RTFData.OnRequestHTTPString := x;
end;

function TWPCustomRtfLabel.GetOnRequestHTTPString: TWPRequestHTTPStringEvent;
begin
  Result := RTFData.OnRequestHTTPString;
end;

procedure TWPCustomRtfLabel.SetOnRequestHTTPImage(x: TWPRequestHTTPImageEvent);
begin
  RTFData.OnRequestHTTPImage := x;
end;

function TWPCustomRtfLabel.GetOnRequestHTTPImage: TWPRequestHTTPImageEvent;
begin
  Result := RTFData.OnRequestHTTPImage;
end;

function TWPCustomRtfLabel.GetFormatOptions: TWPFormatOptions;
begin
  Result := RTFData.FormatOptions;
end;

procedure TWPCustomRtfLabel.SetFormatOptions(x: TWPFormatOptions);
begin
  // x := x + [wpfAlwaysFormatWithScreenRes];
  if RTFData.FormatOptions <> x then
  begin
    RTFData.FormatOptions := x;
    if not (csLoading in ComponentState) then
      ReformatAll;
  end;
end;

function TWPCustomRtfLabel.GetFormatOptionsEx: TWPFormatOptionsEx;
begin
  Result := RTFData.FormatOptionsEx;
end;

procedure TWPCustomRtfLabel.SetFormatOptionsEx(x: TWPFormatOptionsEx);
begin
  if RTFData.FormatOptionsEx <> x then
  begin
    RTFData.FormatOptionsEx := x;
    if not (csLoading in ComponentState) then
      ReformatAll;
  end;
end;

procedure TWPCustomRtfLabel.Loaded;
begin
  inherited Loaded;
  if not RTFText.Empty then
  begin
    RTFText.Apply;
    Resize;
  end;
end;

function TWPCustomRtfLabel.GetRTFText: TWPRTFBlobContents;
begin
  Result := FRTFText;
end;

procedure TWPCustomRtfLabel.SetRTFText(x: TWPRTFBlobContents);
begin
  FRTFText.Assign(x);
end;

procedure TWPCustomRtfLabel.SetStretched(x: Boolean);
begin
  if FStretched <> x then
  begin
    FStretched := x;
    invalidate;
  end;
end;

function TWPCustomRtfLabel.GetWordWrap: Boolean;
begin
  Result := wpemLimitTextWidth in EditBoxModes;
end;

procedure TWPCustomRtfLabel.SetWordWrap(x: Boolean);
begin
  if x <> GetWordWrap then
  begin
    if x then EditBoxModes := EditBoxModes + [wpemLimitTextWidth]
    else EditBoxModes := EditBoxModes - [wpemLimitTextWidth];
    ReformatAll;
    Invalidate;
  end;
end;

function TWPCustomRtfLabel.GetAsString: string;
var f: TStringStream;
begin
  f := TStringStream.Create('');
  try
    SaveToStream(f, TextSaveFormat);
    Result := f.DataString;
  finally
    f.Free;
  end;
end;

function TWPCustomRtfLabel.CalcMousePageAtXY(WindowX, WindowY: Integer): Integer;
begin
  FClientMouseX := WindowX;
  FClientMouseY := WindowY;
  if Stretched then
  begin
    WindowX := Round(WindowX / FCurrentStretchValue);
    WindowY := Round(WindowY / FCurrentStretchValue);
  end;
  Result := GetPageAtXY(WindowX, WindowY);
  FMouseX := WindowX;
  FMouseY := WindowY;
  FMousePage := Result;
end;

function TWPCustomRtfLabel.CodeInsideOf(par: TParagraph; posinpar: Integer;
  ObjType: TWPTextObjType): TWPTextObj;
var obj: TWPTextObj;
  level: Integer;
  first: Boolean;
  aPar: TParagraph;
  aposinpar: Integer;
begin
  Result := nil;
  level := 0;
  first := TRUE;
  aPar := par;
  aposinpar := posinpar;
  try
    while par <> nil do
    begin
      if par.HasObjects(false, [ObjType]) then
      begin
        while posinpar >= 0 do
        begin
          obj := par.ObjectRef[posinpar];
          if (obj <> nil) and (obj.ObjType = ObjType) then
          begin
            if (wpobjIsClosing in obj.Mode) then inc(level) else
              if not first and (wpobjIsOpening in obj.Mode) then
              begin

                if level = 0 then
                begin
                  Result := obj;
                  exit;
                end else dec(level);
              end;
          end;
          first := FALSE;
          dec(posinpar);
        end;
      end;
      first := FALSE;
      par := par.prev;
      if par <> nil then posinpar := par.CharCount - 1;
    end;
  // We don't want to find it if we are sitting on it !
  finally
    if (Result <> nil) and
      (aPar.ObjectRef[aposinpar] = Result) then Result := nil;
  end;
end;

procedure TWPCustomRtfLabel.Click;
var aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par: Integer;
  SizerElement: TWPPaintSizerRects;
  openObj: TWPTextObj;
  CurrentLink : TObject;
begin
  inherited Click;
  GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
    par, pos_in_par, FMouseClickFrameBorder, FTextObjectUnderMouse, SizerElement, CurrentLink);
  if par <> nil then
  begin
    openObj := CodeInsideOf(par, pos_in_par, wpobjHyperlink);
    if FOneClickHyperlink and assigned(FHyperLinkEvent) and (openObj <> nil) then
    begin
      FHyperLinkEvent(Self, openObj.EmbeddedText, openObj.Source, 0);
    end;
  end;
end;

// We coold use the FMouse_ values here but it is save to recalculate them

procedure TWPCustomRtfLabel.DblClick;
var aRTFData: TWPRTFDataBlock;
  par: TParagraph;
  pos_in_par: Integer;
  SizerElement: TWPPaintSizerRects;
  openObj: TWPTextObj;
  CurrentLink : TObject;
begin
  inherited DblClick;
  GetRTFPositionAtXY(MousePage, MouseX, MouseY, aRTFData,
    par, pos_in_par, FMouseClickFrameBorder, FTextObjectUnderMouse, SizerElement, CurrentLink);
  if par <> nil then
  begin
    openObj := CodeInsideOf(par, pos_in_par, wpobjHyperlink);
    if not FOneClickHyperlink and assigned(FHyperLinkEvent) and (openObj <> nil) then
    begin
      FHyperLinkEvent(Self, openObj.EmbeddedText, openObj.Source, 0);
    end;
  end;
end;

procedure TWPCustomRtfLabel.MouseMove(Shift: TShiftState; X, Y: Integer);
var et: TWPTextObj;
    CurrentLink : TObject;
begin
  CalcMousePageAtXY(X, Y);
  GetRTFPositionAtXY(MousePage, MouseX, MouseY, FMouse_aRTFData,
    FMouse_par, FMouse_pos_in_par,
    FMouseClickFrameBorder,
    FTextObjectUnderMouse,
    FMouse_SizerElement, CurrentLink);
  if FMouse_par <> nil then
  begin
    FMouse_openhyper := CodeInsideOf(FMouse_par, FMouse_pos_in_par, wpobjHyperlink);
  end else FMouse_openhyper := nil;
  if (FMouse_openhyper <> nil) and
    (FHyperLinkCursor <> crDefault) then
  begin
    Screen.Cursor := FHyperLinkCursor;
    et := FMouse_openhyper.EndTag;
    if (et <> nil) and
      SetHOTStyle(FMouse_openhyper.ParentPar,
      et.ParentPar, FMouse_openhyper.ParentPosInPar, et.ParentPosInPar, 1)
      then Invalidate;
  end
  else
  begin
    if SetHOTStyle(nil, nil, 0, 0, 0) then Invalidate;
    Screen.Cursor := crDefault;
  end;
  inherited MouseMove(Shift, X, Y);
end;

procedure TWPCustomRtfLabel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TWPCustomRtfLabel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if (FMouse_openhyper <> nil) and
    (FHyperLinkCursor <> crDefault) then
  begin
    if SetHOTStyle(nil, nil, 0, 0, 0) then Invalidate;
    Screen.Cursor := crDefault;
  end;
  if assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TWPCustomRtfLabel.SetAsString(const x: string);
var f: TStringStream;
begin
  f := TStringStream.Create(x);
  try
    LoadFromStream(f, false, 'AUTO');
  finally
    f.Free;
  end;
end;

function TWPCustomRtfLabel.GetBodyText: TWPRTFDataBlock;
begin
  Result := Body;
  if Result = nil then raise Exception.Create('The text has no body yet');
end;

procedure TWPCustomRtfLabel.BroadcastMsg(Code: Integer; Param: TObject);
begin
  case Code of
    WPBROADCAST_REPAINT:
      begin
        Invalidate;
        exit;
      end;
  end;
  inherited BroadcastMsg(Code, Param);
end;

procedure TWPCustomRtfLabel.Paint;
begin
  inherited Paint;
  if (Width < 0) or (Height < 0) then exit;
  if Empty and (csDesigning in ComponentState) then
  begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 0;
    Canvas.Pen.Color := clBtnShadow;
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(0, 0, Width - 1, Height - 1);
  end;
  FLastScreenCanvas := Canvas;
  if FStretched then
  begin
    if FTransparent then
      PaintRTFPage(PageNumber, 0, 0, Width, Height, Canvas, [wppShowHotStyles, wppNoPageBackground],
        0, 0, -1, -1, [wpUseProvidedWidthHeight])
    else PaintRTFPage(PageNumber, 0, 0, Width, Height, Canvas, [wppShowHotStyles],
        0, 0, -1, -1, [wpUseProvidedWidthHeight]);
  end
  else if FTransparent then
    PaintDesktop(Canvas, Width, Height, [wpDontUseDoubleBuffer, wpDontUseDoubleBuffer, wpDontClearBackground])
  else PaintDesktop(Canvas, Width, Height, [wpDontUseDoubleBuffer]);
end;

function TWPCustomRtfLabel.Memo: TWPRTFEnginePaint;
begin
  Result := Self;
end;

function TWPCustomRtfLabel.Header: TTextHeader;
begin
  Result := RTFData.Header;
end;

procedure TWPCustomRtfLabel.ReformatAll(InitializeAll: Boolean = FALSE; SpellcheckAll: Boolean = FALSE);
begin
  inherited ReformatAll(InitializeAll, SpellcheckAll);
  InitializePaintPages;
  ReorderPaintPages;
  RePaint;
end;

procedure TWPCustomRtfLabel.Resize;
var ww, wh: Integer;
begin
  inherited Resize;
  ww := Width;
  wh := Height;
  if (ww <> WindowWidth) or (wh <> WindowHeight) then
  begin
    WindowWidth := ww;
    WindowHeight := wh;
    if WordWrap then ReformatAll;
    ReorderPaintPages;
  end else
  begin
    WindowWidth := ww;
    WindowHeight := wh;
  end;
end;

procedure TWPCustomRtfLabel.Clear;
begin
  if HASData then RTFData.Clear;
end;

function TWPCustomRtfLabel.LoadFromFile(const FileName: string; WithClear: Boolean = FALSE): Boolean;
var f: TFileStream;
  IsBody: Boolean;
begin
  f := TFileStream.Create(FileName, fmOpenRead);
  try
    IsBody := (Memo.DisplayedText <> nil) and (Memo.DisplayedText.Kind = wpIsBody);
    if WithClear then Clear;
    Memo.FileLoadPath := ExtractFilePath(FileName);
    Result := LoadFromStream(f, false, ExtractFileExt(FileName));
    if IsBody then
      Memo.DisplayedText := Memo.Body;
    ReformatAll;
  finally
    f.Free;
  end;
end;

end.

